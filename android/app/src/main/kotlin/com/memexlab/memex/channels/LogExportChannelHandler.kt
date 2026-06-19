package com.memexlab.memex.channels

import android.app.Activity
import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException

/**
 * Saves exported files to the public Downloads folder via MediaStore (API 29+)
 * or legacy external storage (API 26-28).
 */
class LogExportChannelHandler(private val activity: Activity) {

    companion object {
        private const val CHANNEL = "com.memexlab.memex/log_export"

        fun register(flutterEngine: FlutterEngine, activity: Activity) {
            val handler = LogExportChannelHandler(activity)
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "saveToPublicDownloads" -> {
                            val fileName = call.argument<String>("fileName")
                            val bytes = call.argument<ByteArray>("bytes")
                            if (fileName.isNullOrBlank() || bytes == null) {
                                result.error(
                                    "INVALID_ARGUMENTS",
                                    "fileName and bytes are required",
                                    null,
                                )
                                return@setMethodCallHandler
                            }
                            handler.saveToPublicDownloads(fileName, bytes, result)
                        }
                        else -> result.notImplemented()
                    }
                }
        }
    }

    private fun saveToPublicDownloads(
        fileName: String,
        bytes: ByteArray,
        result: MethodChannel.Result,
    ) {
        try {
            val savedPath = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                saveWithMediaStore(fileName, bytes)
            } else {
                saveLegacy(fileName, bytes)
            }
            result.success(savedPath)
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", e.message, null)
        } catch (e: IOException) {
            result.error("SAVE_ERROR", e.message, null)
        } catch (e: Exception) {
            result.error("SAVE_ERROR", e.message, null)
        }
    }

    private fun saveWithMediaStore(fileName: String, bytes: ByteArray): String {
        val resolver = activity.contentResolver
        val contentValues = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, fileName)
            put(MediaStore.Downloads.MIME_TYPE, "text/plain")
            put(MediaStore.Downloads.RELATIVE_PATH, "${Environment.DIRECTORY_DOWNLOADS}/")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.Downloads.IS_PENDING, 1)
            }
        }

        val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
            ?: throw IOException("Failed to create Downloads entry")

        resolver.openOutputStream(uri)?.use { stream ->
            stream.write(bytes)
            stream.flush()
        } ?: throw IOException("Failed to open Downloads output stream")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val publishValues = ContentValues().apply {
                put(MediaStore.Downloads.IS_PENDING, 0)
            }
            resolver.update(uri, publishValues, null, null)
        }

        @Suppress("DEPRECATION")
        val downloadsDir =
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        return File(downloadsDir, fileName).absolutePath
    }

    @Suppress("DEPRECATION")
    private fun saveLegacy(fileName: String, bytes: ByteArray): String {
        val downloadsDir =
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        if (!downloadsDir.exists() && !downloadsDir.mkdirs()) {
            throw IOException("Failed to create Downloads directory")
        }
        val targetFile = File(downloadsDir, fileName)
        targetFile.writeBytes(bytes)
        return targetFile.absolutePath
    }
}
