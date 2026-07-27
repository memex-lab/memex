package com.memexlab.memex.channels

import android.app.Activity
import android.content.ContentValues
import android.provider.CalendarContract
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

/**
 * Handles `com.memexlab.memex/system_actions` MethodChannel.
 * Supports: addCalendarEvent, addReminder.
 *
 * Android has no common standalone reminders store. Reminders are represented
 * as short calendar events with an alarm at the requested time.
 */
class SystemActionsChannelHandler(private val activity: Activity) {

    companion object {
        private const val CHANNEL = "com.memexlab.memex/system_actions"

        fun register(flutterEngine: FlutterEngine, activity: Activity) {
            val handler = SystemActionsChannelHandler(activity)
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "addCalendarEvent" -> handler.addCalendarEvent(call.arguments, result)
                        "addReminder" -> handler.addReminder(call.arguments, result)
                        else -> result.notImplemented()
                    }
                }
        }
    }

    private fun addCalendarEvent(arguments: Any?, result: MethodChannel.Result) {
        val args = arguments as? Map<*, *>
        val title = args?.get("title") as? String
        val startMs = (args?.get("startTime") as? Number)?.toLong()
        val endMs = (args?.get("endTime") as? Number)?.toLong()

        if (title == null || startMs == null || endMs == null) {
            result.error("INVALID_ARGUMENTS", "Invalid arguments for addCalendarEvent", null)
            return
        }

        val location = args["location"] as? String
        val notes = args["notes"] as? String

        try {
            val calendarId = getDefaultCalendarId()
            if (calendarId == null) {
                result.error("NO_CALENDAR", "No calendar account found on device", null)
                return
            }

            val values = ContentValues().apply {
                put(CalendarContract.Events.CALENDAR_ID, calendarId)
                put(CalendarContract.Events.TITLE, title)
                put(CalendarContract.Events.DTSTART, startMs)
                put(CalendarContract.Events.DTEND, endMs)
                put(CalendarContract.Events.EVENT_TIMEZONE, TimeZone.getDefault().id)
                if (location != null) put(CalendarContract.Events.EVENT_LOCATION, location)
                if (notes != null) put(CalendarContract.Events.DESCRIPTION, notes)
            }

            val uri = activity.contentResolver.insert(CalendarContract.Events.CONTENT_URI, values)
            if (uri != null) {
                // Add a default 10-minute reminder
                val eventId = uri.lastPathSegment?.toLongOrNull()
                if (eventId != null) {
                    addReminderAlarm(eventId, 10)
                }
                result.success(true)
            } else {
                result.error("SAVE_ERROR", "Failed to insert calendar event", null)
            }
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", "Calendar permission denied", null)
        } catch (e: Exception) {
            result.error("SAVE_ERROR", e.message, null)
        }
    }

    private fun addReminder(arguments: Any?, result: MethodChannel.Result) {
        val args = arguments as? Map<*, *>
        val title = args?.get("title") as? String
        val dueMs = (args?.get("dueDate") as? Number)?.toLong()

        if (title == null || dueMs == null) {
            result.error("INVALID_ARGUMENTS", "Invalid arguments for addReminder", null)
            return
        }

        val notes = args["notes"] as? String

        try {
            val calendarId = getDefaultCalendarId()
            if (calendarId == null) {
                result.error("NO_CALENDAR", "No calendar account found on device", null)
                return
            }

            // Android has no common reminders store. Represent the reminder
            // as a short calendar event with an alarm at its start time.
            val startMs = dueMs
            val endMs = startMs + 60_000

            val values = ContentValues().apply {
                put(CalendarContract.Events.CALENDAR_ID, calendarId)
                put(CalendarContract.Events.TITLE, title)
                put(CalendarContract.Events.DTSTART, startMs)
                put(CalendarContract.Events.DTEND, endMs)
                put(CalendarContract.Events.EVENT_TIMEZONE, TimeZone.getDefault().id)
                if (notes != null) put(CalendarContract.Events.DESCRIPTION, notes)
            }

            val uri = activity.contentResolver.insert(CalendarContract.Events.CONTENT_URI, values)
            if (uri != null) {
                val eventId = uri.lastPathSegment?.toLongOrNull()
                if (eventId != null) {
                    // Remind exactly at event time
                    addReminderAlarm(eventId, 0)
                }
                result.success(true)
            } else {
                result.error("SAVE_ERROR", "Failed to insert reminder", null)
            }
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", "Calendar permission denied", null)
        } catch (e: Exception) {
            result.error("SAVE_ERROR", e.message, null)
        }
    }

    // -- Helpers --

    private fun getDefaultCalendarId(): Long? {
        val projection = arrayOf(
            CalendarContract.Calendars._ID,
            CalendarContract.Calendars.IS_PRIMARY,
        )
        val cursor = activity.contentResolver.query(
            CalendarContract.Calendars.CONTENT_URI,
            projection,
            "${CalendarContract.Calendars.VISIBLE} = 1",
            null,
            "${CalendarContract.Calendars.IS_PRIMARY} DESC"
        ) ?: return null

        cursor.use {
            if (it.moveToFirst()) {
                return it.getLong(it.getColumnIndexOrThrow(CalendarContract.Calendars._ID))
            }
        }
        return null
    }

    private fun addReminderAlarm(eventId: Long, minutesBefore: Int) {
        val values = ContentValues().apply {
            put(CalendarContract.Reminders.EVENT_ID, eventId)
            put(CalendarContract.Reminders.MINUTES, minutesBefore)
            put(CalendarContract.Reminders.METHOD, CalendarContract.Reminders.METHOD_ALERT)
        }
        activity.contentResolver.insert(CalendarContract.Reminders.CONTENT_URI, values)
    }
}
