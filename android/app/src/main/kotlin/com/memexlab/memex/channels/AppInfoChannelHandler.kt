package com.memexlab.memex.channels

import android.app.Activity
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Handles `com.memexlab.memex/app_info` MethodChannel.
 */
class AppInfoChannelHandler(private val activity: Activity) {

    companion object {
        private const val CHANNEL = "com.memexlab.memex/app_info"

        fun register(flutterEngine: FlutterEngine, activity: Activity) {
            val handler = AppInfoChannelHandler(activity)
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "getInstallerSource" -> result.success(handler.getInstallerSource())
                        else -> result.notImplemented()
                    }
                }
        }
    }

    private fun getInstallerSource(): String? {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                val sourceInfo = activity.packageManager.getInstallSourceInfo(activity.packageName)
                sourceInfo.installingPackageName ?: sourceInfo.initiatingPackageName
            } else {
                @Suppress("DEPRECATION")
                activity.packageManager.getInstallerPackageName(activity.packageName)
            }
        } catch (_: Exception) {
            null
        }
    }
}
