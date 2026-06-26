package com.memexlab.memex

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat
import androidx.lifecycle.LiveData
import androidx.lifecycle.Observer
import androidx.work.WorkInfo
import androidx.work.WorkManager
import com.memexlab.memex.channels.AgentBackgroundChannelHandler

class AgentBackgroundService : Service() {
    companion object {
        const val ACTION_UPDATE = "com.memexlab.memex.agent_background.UPDATE"
        const val ACTION_STOP = "com.memexlab.memex.agent_background.STOP"
        const val EXTRA_WATCH_BACKGROUND_WORK = "watchBackgroundWork"

        private const val CHANNEL_ID = "agent_background"
        private const val CHANNEL_NAME = "Memex Agent"
        private const val BACKGROUND_WORK_UNIQUE_NAME = "agent_queue_drain"
        private const val WORK_MONITOR_DELAY_MS = 2_000L
        private const val WORK_MONITOR_GRACE_MS = 10_000L
        const val NOTIFICATION_ID = 188

        fun clear(context: Context) {
            val intent = Intent(context, AgentBackgroundService::class.java).apply {
                action = ACTION_STOP
            }
            context.stopService(intent)
            val manager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.cancel(NOTIFICATION_ID)
        }
    }

    private val handler = Handler(Looper.getMainLooper())
    private val stopRunnable = Runnable {
        stopForegroundCompat(removeNotification = false)
        stopSelf()
    }
    private val workMonitorRunnable = Runnable { checkBackgroundDrainWork() }
    private var watchBackgroundWork = false
    private var workMonitorStartedAtMs = 0L
    private var workInfosLiveData: LiveData<List<WorkInfo>>? = null
    private var workInfoObserver: Observer<List<WorkInfo>>? = null
    private var lastStatusIntent: Intent? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        createNotificationChannel()

        if (intent == null) {
            clearAndStop(startId)
            return START_NOT_STICKY
        }

        if (intent.action == ACTION_STOP) {
            clearAndStop(startId)
            return START_NOT_STICKY
        }

        val state = intent.getStringExtra("state") ?: "active"
        if (state == "completed" || state == "idle") {
            clearAndStop(startId)
            return START_NOT_STICKY
        }
        lastStatusIntent = Intent(intent)

        watchBackgroundWork =
            state == "active" && intent.getBooleanExtra(EXTRA_WATCH_BACKGROUND_WORK, false)
        if (watchBackgroundWork && workMonitorStartedAtMs == 0L) {
            workMonitorStartedAtMs = System.currentTimeMillis()
        }

        val notification = buildNotification(intent, state)
        startForegroundCompat(notification)

        handler.removeCallbacks(stopRunnable)
        if (state == "failed") {
            handler.postDelayed(stopRunnable, 5000)
        }
        scheduleOrCancelWorkMonitor()

        return START_NOT_STICKY
    }

    override fun onDestroy() {
        handler.removeCallbacks(stopRunnable)
        handler.removeCallbacks(workMonitorRunnable)
        removeWorkInfoObserver()
        super.onDestroy()
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        if (!watchBackgroundWork) {
            clearAndStop()
        }
        super.onTaskRemoved(rootIntent)
    }

    private fun buildNotification(intent: Intent?, state: String): Notification {
        val title = intent?.getStringExtra("title") ?: "Memex Agent"
        val stage = intent?.getStringExtra("stage") ?: "Processing"
        val detail = intent?.getStringExtra("detail") ?: ""
        val summary = intent?.getStringExtra("summary") ?: ""
        val remainingTasks = intent?.getIntExtra("remainingTasks", 0) ?: 0
        val taskSummary = intent?.getStringExtra("taskSummary")
            ?.takeIf { it.isNotBlank() }
            ?: taskSummaryFromCounts(
                pending = intent?.getIntExtra("pending", 0) ?: 0,
                processing = intent?.getIntExtra("processing", 0) ?: 0,
                retrying = intent?.getIntExtra("retrying", 0) ?: 0,
            )
        val localizedStatusText = intent?.getStringExtra("statusText")
            ?.takeIf { it.isNotBlank() }
        val progressCompleted = intent?.getIntExtra("progressCompleted", 0) ?: 0
        val progressTotal = intent?.getIntExtra("progressTotal", 0) ?: 0

        val openIntent = Intent(this, MainActivity::class.java).apply {
            action = AgentBackgroundChannelHandler.ACTION_OPEN_AGENT_ACTIVITY
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("memex_action", "agent_activity")
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val fallbackText = when (state) {
            "failed" -> {
                if (remainingTasks > 0) {
                    "Needs attention - $taskSummary"
                } else {
                    "Needs attention"
                }
            }
            "paused" -> {
                if (remainingTasks <= 0) {
                    "Paused - will continue later"
                } else {
                    "Paused - $taskSummary"
                }
            }
            else -> {
                if (remainingTasks > 0) {
                    taskSummary
                } else {
                    "Processing"
                }
            }
        }
        val contentText = localizedStatusText
            ?: summary.takeIf { it.isNotBlank() }
            ?: fallbackText
        val body = listOf(
            stage,
            taskSummary.takeIf { remainingTasks > 0 },
            detail,
        ).filterNotNull().filter { it.isNotBlank() }.joinToString("\n")
        val bigText = body.ifBlank { contentText }

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_quick_note)
            .setContentTitle(title)
            .setContentText(contentText)
            .setStyle(NotificationCompat.BigTextStyle().bigText(bigText))
            .setContentIntent(pendingIntent)
            .setOngoing(state == "active")
            .setAutoCancel(state == "failed")
            .setOnlyAlertOnce(true)
            .setCategory(NotificationCompat.CATEGORY_PROGRESS)
            .setPriority(NotificationCompat.PRIORITY_LOW)

        if ((state == "active" || state == "paused") && progressTotal > 0) {
            builder.setProgress(progressTotal, progressCompleted.coerceIn(0, progressTotal), false)
        } else if (state == "active" && remainingTasks > 0) {
            builder.setProgress(0, 0, true)
        }

        return builder.build()
    }

    private fun taskSummaryFromCounts(pending: Int, processing: Int, retrying: Int): String {
        return "Running $processing, Pending $pending, Retry $retrying"
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val manager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Shows Memex agent background processing status"
            setShowBadge(false)
        }
        manager.createNotificationChannel(channel)
    }

    private fun scheduleOrCancelWorkMonitor() {
        handler.removeCallbacks(workMonitorRunnable)
        if (watchBackgroundWork) {
            handler.postDelayed(workMonitorRunnable, WORK_MONITOR_DELAY_MS)
        } else {
            workMonitorStartedAtMs = 0L
        }
    }

    private fun checkBackgroundDrainWork() {
        if (!watchBackgroundWork) return

        removeWorkInfoObserver()
        val liveData =
            WorkManager.getInstance(applicationContext)
                .getWorkInfosForUniqueWorkLiveData(BACKGROUND_WORK_UNIQUE_NAME)
        val observer =
            object : Observer<List<WorkInfo>> {
                override fun onChanged(infos: List<WorkInfo>) {
                    removeWorkInfoObserver()
                    val hasLiveWork = infos.any { info ->
                        info.state == WorkInfo.State.ENQUEUED ||
                            info.state == WorkInfo.State.RUNNING ||
                            info.state == WorkInfo.State.BLOCKED
                    }
                    if (hasLiveWork) {
                        scheduleOrCancelWorkMonitor()
                        return
                    }

                    val waitedLongEnough =
                        System.currentTimeMillis() - workMonitorStartedAtMs >=
                            WORK_MONITOR_GRACE_MS
                    if (waitedLongEnough) {
                        pauseNotificationAfterDetachedWork()
                    } else {
                        scheduleOrCancelWorkMonitor()
                    }
                }
            }
        workInfosLiveData = liveData
        workInfoObserver = observer
        liveData.observeForever(observer)
    }

    private fun clearAndStop(startId: Int? = null) {
        watchBackgroundWork = false
        workMonitorStartedAtMs = 0L
        handler.removeCallbacks(stopRunnable)
        handler.removeCallbacks(workMonitorRunnable)
        removeWorkInfoObserver()
        stopForegroundCompat(removeNotification = true)
        val manager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.cancel(NOTIFICATION_ID)
        if (startId == null) {
            stopSelf()
        } else {
            stopSelf(startId)
        }
    }

    private fun removeWorkInfoObserver() {
        val observer = workInfoObserver ?: return
        workInfosLiveData?.removeObserver(observer)
        workInfoObserver = null
        workInfosLiveData = null
    }

    private fun pauseNotificationAfterDetachedWork() {
        val lastIntent = lastStatusIntent
        if (lastIntent == null) {
            clearAndStop()
            return
        }

        watchBackgroundWork = false
        handler.removeCallbacks(workMonitorRunnable)
        removeWorkInfoObserver()

        val pausedIntent = Intent(lastIntent).apply {
            putExtra("state", "paused")
            putExtra("stage", "Paused")
            putExtra("detail", "Background execution paused. Memex will continue later.")
        }
        lastStatusIntent = pausedIntent
        startForegroundCompat(buildNotification(pausedIntent, "paused"))
    }

    private fun startForegroundCompat(notification: Notification) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun stopForegroundCompat(removeNotification: Boolean) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(
                if (removeNotification) {
                    STOP_FOREGROUND_REMOVE
                } else {
                    STOP_FOREGROUND_DETACH
                },
            )
        } else {
            @Suppress("DEPRECATION")
            stopForeground(removeNotification)
        }
    }
}
