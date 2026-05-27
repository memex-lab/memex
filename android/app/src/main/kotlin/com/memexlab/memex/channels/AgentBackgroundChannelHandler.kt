package com.memexlab.memex.channels

import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.core.content.ContextCompat
import com.memexlab.memex.AgentBackgroundService
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

object AgentBackgroundChannelHandler {
    private const val CHANNEL = "com.memexlab.memex/agent_background"
    const val ACTION_OPEN_AGENT_ACTIVITY = "com.memexlab.memex.OPEN_AGENT_ACTIVITY"

    private var channel: MethodChannel? = null
    private var pendingOpenAgentActivity = false

    fun register(flutterEngine: FlutterEngine, activity: Activity) {
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "updateAgentStatus" -> {
                    startOrUpdateService(activity, call)
                    result.success(null)
                }
                "finishAgentStatus" -> {
                    startOrUpdateService(activity, call)
                    result.success(null)
                }
                "stopAgentStatus" -> {
                    stopService(activity)
                    result.success(null)
                }
                "consumeInitialAgentAction" -> {
                    if (pendingOpenAgentActivity) {
                        pendingOpenAgentActivity = false
                        result.success("agent_activity")
                    } else {
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    fun handleIntent(intent: Intent?) {
        if (intent?.action != ACTION_OPEN_AGENT_ACTIVITY &&
            intent?.getStringExtra("memex_action") != "agent_activity"
        ) {
            return
        }

        val currentChannel = channel
        if (currentChannel == null) {
            pendingOpenAgentActivity = true
        } else {
            currentChannel.invokeMethod("openAgentActivity", null)
        }
    }

    private fun startOrUpdateService(context: Context, call: MethodCall) {
        val args = call.arguments as? Map<*, *> ?: emptyMap<String, Any?>()
        val intent = Intent(context, AgentBackgroundService::class.java).apply {
            action = AgentBackgroundService.ACTION_UPDATE
            putExtra("state", args["state"] as? String ?: "active")
            putExtra("title", args["title"] as? String ?: "Memex is processing")
            putExtra("stage", args["stage"] as? String ?: "Processing")
            putExtra("detail", args["detail"] as? String ?: "")
            putExtra("remainingTasks", (args["remainingTasks"] as? Number)?.toInt() ?: 0)
            putExtra("pending", (args["pending"] as? Number)?.toInt() ?: 0)
            putExtra("processing", (args["processing"] as? Number)?.toInt() ?: 0)
            putExtra("retrying", (args["retrying"] as? Number)?.toInt() ?: 0)
        }
        ContextCompat.startForegroundService(context, intent)
    }

    private fun stopService(context: Context) {
        val intent = Intent(context, AgentBackgroundService::class.java).apply {
            action = AgentBackgroundService.ACTION_STOP
        }
        context.stopService(intent)
    }
}
