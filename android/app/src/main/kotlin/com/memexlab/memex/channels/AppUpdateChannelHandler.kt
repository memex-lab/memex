package com.memexlab.memex.channels

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Handles `com.memexlab.memex/app_update` MethodChannel.
 *
 * Android does not allow silent APK installs for normal apps. The "install"
 * operation opens the system package installer after the APK has been
 * downloaded by Dart.
 */
class AppUpdateChannelHandler(private val activity: Activity) {

    companion object {
        private const val CHANNEL = "com.memexlab.memex/app_update"

        fun register(flutterEngine: FlutterEngine, activity: Activity) {
            val handler = AppUpdateChannelHandler(activity)
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "isWifiConnected" -> result.success(handler.isWifiConnected())
                        "canInstallApk" -> result.success(handler.canInstallApk())
                        "openInstallPermissionSettings" -> {
                            handler.openInstallPermissionSettings()
                            result.success(null)
                        }
                        "installApk" -> {
                            val apkPath = call.argument<String>("apkPath")
                            if (apkPath.isNullOrBlank()) {
                                result.error("INVALID_ARGUMENTS", "Missing apkPath", null)
                                return@setMethodCallHandler
                            }
                            try {
                                handler.installApk(apkPath)
                                result.success(null)
                            } catch (e: ActivityNotFoundException) {
                                result.error("NO_INSTALLER", "No package installer found", null)
                            } catch (e: IllegalArgumentException) {
                                result.error("INVALID_APK", e.message, null)
                            } catch (e: Exception) {
                                result.error("INSTALL_ERROR", e.message, null)
                            }
                        }
                        else -> result.notImplemented()
                    }
                }
        }
    }

    private fun isWifiConnected(): Boolean {
        val connectivityManager =
            activity.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val network = connectivityManager.activeNetwork ?: return false
        val capabilities = connectivityManager.getNetworkCapabilities(network) ?: return false
        return capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
    }

    private fun canInstallApk(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            activity.packageManager.canRequestPackageInstalls()
        } else {
            true
        }
    }

    private fun openInstallPermissionSettings() {
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Intent(
                Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                Uri.parse("package:${activity.packageName}")
            )
        } else {
            Intent(Settings.ACTION_SECURITY_SETTINGS)
        }
        activity.startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
    }

    private fun installApk(apkPath: String) {
        val apkFile = File(apkPath)
        require(apkFile.exists() && apkFile.isFile) {
            "APK file does not exist: $apkPath"
        }
        require(apkFile.extension.equals("apk", ignoreCase = true)) {
            "File is not an APK: $apkPath"
        }

        val uri = FileProvider.getUriForFile(
            activity,
            "${activity.packageName}.fileprovider",
            apkFile
        )

        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "application/vnd.android.package-archive")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        activity.startActivity(intent)
    }
}
