package com.memexlab.memex.channels

import android.app.Activity
import io.flutter.embedding.engine.FlutterEngine

/**
 * Central registration point for all MethodChannel handlers.
 *
 * Each channel has its own handler class that encapsulates parameter parsing,
 * business logic, and result dispatch.
 *
 * To add a new channel:
 * 1. Create a handler in channels/
 * 2. Call its register() here.
 */
object ChannelRegistrar {
    fun registerAll(flutterEngine: FlutterEngine, activity: Activity) {
        WebViewChannelHandler.register(flutterEngine, activity)
        AudioConverterChannelHandler.register(flutterEngine, activity)
        SystemActionsChannelHandler.register(flutterEngine, activity)
        AppUpdateChannelHandler.register(flutterEngine, activity)
    }
}
