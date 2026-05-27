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
import com.memexlab.memex.channels.AgentBackgroundChannelHandler

class AgentBackgroundService : Service() {
    companion object {
        const val ACTION_UPDATE = "com.memexlab.memex.agent_background.UPDATE"
        const val ACTION_STOP = "com.memexlab.memex.agent_background.STOP"

        private const val CHANNEL_ID = "agent_background"
        private const val CHANNEL_NAME = "Agent processing"
        private const val NOTIFICATION_ID = 188
    }

    private val handler = Handler(Looper.getMainLooper())
    private val stopRunnable = Runnable {
        stopForegroundCompat(removeNotification = true)
        stopSelf()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        createNotificationChannel()

        if (intent == null) {
            stopSelf(startId)
            return START_NOT_STICKY
        }

        if (intent.action == ACTION_STOP) {
            stopForegroundCompat(removeNotification = true)
            stopSelf(startId)
            return START_NOT_STICKY
        }

        val state = intent.getStringExtra("state") ?: "active"
        val notification = buildNotification(intent, state)
        startForegroundCompat(notification)

        handler.removeCallbacks(stopRunnable)
        if (state == "completed" || state == "failed" || state == "idle") {
            handler.postDelayed(stopRunnable, 5000)
        }

        return START_NOT_STICKY
    }

    override fun onDestroy() {
        handler.removeCallbacks(stopRunnable)
        super.onDestroy()
    }

    private fun buildNotification(intent: Intent?, state: String): Notification {
        val title = intent?.getStringExtra("title") ?: "Memex is processing"
        val stage = intent?.getStringExtra("stage") ?: "Processing"
        val detail = intent?.getStringExtra("detail") ?: ""
        val remainingTasks = intent?.getIntExtra("remainingTasks", 0) ?: 0
        val pending = intent?.getIntExtra("pending", 0) ?: 0
        val processing = intent?.getIntExtra("processing", 0) ?: 0
        val retrying = intent?.getIntExtra("retrying", 0) ?: 0

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

        val subText = when (state) {
            "completed" -> "All tasks finished"
            "failed" -> "Tap to review"
            else -> "$remainingTasks remaining"
        }
        val body = listOf(
            stage,
            detail,
            "running $processing · waiting $pending · retrying $retrying",
        ).filter { it.isNotBlank() }.joinToString("\n")

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_quick_note)
            .setContentTitle(title)
            .setContentText(subText)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setContentIntent(pendingIntent)
            .setOngoing(state == "active")
            .setAutoCancel(state != "active")
            .setOnlyAlertOnce(true)
            .setCategory(NotificationCompat.CATEGORY_PROGRESS)
            .setPriority(NotificationCompat.PRIORITY_LOW)

        if (state == "active" && remainingTasks > 0) {
            builder.setProgress(0, 0, true)
        }

        return builder.build()
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
