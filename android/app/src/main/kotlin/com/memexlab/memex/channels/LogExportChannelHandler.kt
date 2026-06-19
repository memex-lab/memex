package com.memexlab.memex.channels

import android.app.Activity
import android.app.DownloadManager
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException

/**
 * Saves exported log files to the public Downloads folder.
 */
class LogExportChannelHandler(private val activity: Activity) {

    companion object {
        private const val TAG = "LogExportChannelHandler"
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
            deleteExistingDownload(fileName)

            val savedPath = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                try {
                    saveWithMediaStore(fileName, bytes)
                } catch (mediaStoreError: Exception) {
                    Log.w(TAG, "MediaStore save failed, trying DownloadManager", mediaStoreError)
                    saveWithDownloadManager(fileName, bytes)
                }
            } else {
                saveLegacy(fileName, bytes)
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
                !verifyDownloadExists(fileName)
            ) {
                throw IOException("File not visible in public Downloads after save")
            }

            Log.i(TAG, "Saved log to public Downloads: $savedPath")
            result.success(savedPath)
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", e.message, null)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to save log to Downloads", e)
            result.error("SAVE_ERROR", e.message, null)
        }
    }

    private fun saveWithMediaStore(fileName: String, bytes: ByteArray): String {
        val resolver = activity.contentResolver
        val collection = MediaStore.Downloads.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)

        val contentValues = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
            put(MediaStore.MediaColumns.MIME_TYPE, "text/plain")
            put(MediaStore.MediaColumns.RELATIVE_PATH, "${Environment.DIRECTORY_DOWNLOADS}/")
            put(MediaStore.MediaColumns.IS_PENDING, 1)
        }

        val uri = resolver.insert(collection, contentValues)
            ?: throw IOException("MediaStore insert returned null")

        try {
            resolver.openOutputStream(uri)?.use { stream ->
                stream.write(bytes)
                stream.flush()
            } ?: throw IOException("Failed to open MediaStore output stream")
        } catch (e: Exception) {
            resolver.delete(uri, null, null)
            throw e
        }

        val publishValues = ContentValues().apply {
            put(MediaStore.MediaColumns.IS_PENDING, 0)
        }
        resolver.update(uri, publishValues, null, null)

        return publicDownloadsPath(fileName)
    }

    private fun saveWithDownloadManager(fileName: String, bytes: ByteArray): String {
        val context = activity.applicationContext
        val exportDir = File(context.cacheDir, "log_exports")
        if (!exportDir.exists() && !exportDir.mkdirs()) {
            throw IOException("Failed to create export cache directory")
        }

        val sourceFile = File(exportDir, fileName)
        sourceFile.writeBytes(bytes)

        val authority = "${context.packageName}.fileprovider"
        val sourceUri = FileProvider.getUriForFile(context, authority, sourceFile)

        context.grantUriPermission(
            "com.android.providers.downloads",
            sourceUri,
            Intent.FLAG_GRANT_READ_URI_PERMISSION,
        )

        val request = DownloadManager.Request(sourceUri).apply {
            setTitle(fileName)
            setDescription("Memex log export")
            setMimeType("text/plain")
            setNotificationVisibility(
                DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED,
            )
            setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, fileName)
        }

        val downloadManager =
            context.getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
        downloadManager.enqueue(request)

        return publicDownloadsPath(fileName)
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

    private fun deleteExistingDownload(fileName: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val resolver = activity.contentResolver
            val collection = MediaStore.Downloads.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
            resolver.delete(
                collection,
                "${MediaStore.MediaColumns.DISPLAY_NAME} = ?",
                arrayOf(fileName),
            )
            return
        }

        @Suppress("DEPRECATION")
        val legacyFile = File(
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
            fileName,
        )
        if (legacyFile.exists()) {
            legacyFile.delete()
        }
    }

    private fun verifyDownloadExists(fileName: String): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            @Suppress("DEPRECATION")
            return File(
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
                fileName,
            ).exists()
        }

        val resolver = activity.contentResolver
        val collection = MediaStore.Downloads.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        resolver.query(
            collection,
            arrayOf(MediaStore.MediaColumns._ID),
            "${MediaStore.MediaColumns.DISPLAY_NAME} = ?",
            arrayOf(fileName),
            null,
        )?.use { cursor ->
            return cursor.moveToFirst()
        }
        return false
    }

    @Suppress("DEPRECATION")
    private fun publicDownloadsPath(fileName: String): String {
        return File(
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
            fileName,
        ).absolutePath
    }
}
