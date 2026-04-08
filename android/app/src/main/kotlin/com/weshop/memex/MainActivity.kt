package com.memexlab.memex

import android.webkit.WebView
import android.view.View
import android.view.ViewGroup
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val WEBVIEW_CHANNEL = "com.memexlab.memex/webview"

    private var liteRtLmPlugin: LiteRtLmPlugin? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // WebView scrolling helper
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            WEBVIEW_CHANNEL,
        ).setMethodCallHandler { call, result ->
            if (call.method == "disableScrolling") {
                disableWebViewScrolling()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        // LiteRT-LM official Kotlin API plugin
        liteRtLmPlugin = LiteRtLmPlugin(
            context = applicationContext,
            messenger = flutterEngine.dartExecutor.binaryMessenger,
        )
    }

    override fun onDestroy() {
        liteRtLmPlugin?.dispose()
        liteRtLmPlugin = null
        super.onDestroy()
    }

    private fun disableWebViewScrolling() {
        val rootView = window.decorView.rootView
        disableScrollingInView(rootView)
    }

    private fun disableScrollingInView(view: View) {
        if (view is WebView) {
            view.isVerticalScrollBarEnabled = false
            view.isHorizontalScrollBarEnabled = false
            view.overScrollMode = View.OVER_SCROLL_NEVER
        }
        if (view is ViewGroup) {
            for (i in 0 until view.childCount) {
                disableScrollingInView(view.getChildAt(i))
            }
        }
    }
}
