package com.memexlab.memex.channels

import android.app.Activity
import android.content.ContentResolver
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

/**
 * Handles non-.memex files opened through Android ACTION_VIEW.
 *
 * Shared files from ACTION_SEND are still handled by share_handler. This
 * channel is for file-manager "Open with Memex" flows.
 */
object ExternalFileImportChannelHandler {
    private const val METHOD_CHANNEL = "com.memexlab.memex/external_file_import"
    private const val EVENT_CHANNEL = "com.memexlab.memex/external_file_import_events"

    @Volatile
    private var pendingFilePaths: List<String>? = null
    private var eventSink: EventChannel.EventSink? = null

    fun register(flutterEngine: FlutterEngine, activity: Activity) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialFilePaths" -> result.success(pendingFilePaths)
                    "clearInitialFilePaths" -> {
                        pendingFilePaths = null
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    pendingFilePaths?.let { eventSink?.success(it) }
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })
    }

    fun handleIntent(activity: Activity, intent: Intent?) {
        if (intent?.action != Intent.ACTION_VIEW) return
        val uri = intent.data ?: return
        val resolver = activity.contentResolver
        val displayName = getDisplayName(resolver, uri)
        if (looksLikeMemexBackup(uri, displayName, intent.type ?: resolver.getType(uri))) {
            return
        }

        Thread {
            val copiedPath = copyToCache(activity, resolver, uri, displayName)
            if (copiedPath != null) {
                pendingFilePaths = listOf(copiedPath)
                activity.runOnUiThread {
                    eventSink?.success(listOf(copiedPath))
                }
            }
        }.start()
    }

    private fun looksLikeMemexBackup(
        uri: Uri,
        displayName: String?,
        mimeType: String?
    ): Boolean {
        return mimeType == "application/x-memex-backup" ||
            displayName?.endsWith(".memex", ignoreCase = true) == true ||
            uri.lastPathSegment?.endsWith(".memex", ignoreCase = true) == true
    }

    private fun copyToCache(
        activity: Activity,
        resolver: ContentResolver,
        uri: Uri,
        displayName: String?
    ): String? {
        return try {
            val importDir = File(activity.cacheDir, "external_file_imports")
            if (!importDir.exists()) importDir.mkdirs()
            val destination = File(importDir, uniqueFileName(importDir, displayName ?: uri.lastPathSegment))

            resolver.openInputStream(uri)?.use { input ->
                FileOutputStream(destination).use { output ->
                    val buffer = ByteArray(8 * 1024)
                    while (true) {
                        val read = input.read(buffer)
                        if (read == -1) break
                        output.write(buffer, 0, read)
                    }
                }
            } ?: return null

            destination.absolutePath
        } catch (_: Exception) {
            null
        }
    }

    private fun getDisplayName(resolver: ContentResolver, uri: Uri): String? {
        var cursor: Cursor? = null
        return try {
            cursor = resolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)
            if (cursor != null && cursor.moveToFirst()) {
                val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (index >= 0) cursor.getString(index) else null
            } else {
                null
            }
        } catch (_: Exception) {
            null
        } finally {
            cursor?.close()
        }
    }

    private fun uniqueFileName(directory: File, rawName: String?): String {
        val fallback = "import_${System.currentTimeMillis()}"
        val baseName = rawName
            ?.substringAfterLast('/')
            ?.replace(Regex("[^A-Za-z0-9._-]"), "_")
            ?.takeIf { it.isNotBlank() }
            ?: fallback
        var candidate = baseName
        val stem = baseName.substringBeforeLast('.', baseName)
        val extension = baseName.substringAfterLast('.', "")
        var counter = 1
        while (File(directory, candidate).exists()) {
            candidate = if (extension.isNotEmpty()) {
                "${stem}_$counter.$extension"
            } else {
                "${stem}_$counter"
            }
            counter += 1
        }
        return candidate
    }
}
