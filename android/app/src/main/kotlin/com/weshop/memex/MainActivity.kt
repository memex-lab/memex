package com.memexlab.memex

import android.content.Intent
import com.memexlab.memex.channels.AgentBackgroundChannelHandler
import com.memexlab.memex.channels.BackupImportChannelHandler
import com.memexlab.memex.channels.BackupStorageChannelHandler
import com.memexlab.memex.channels.ChannelRegistrar
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        // If the Activity is being recreated (system killed it in background),
        // clear the stale shortcut extra so the quick_actions plugin won't
        // re-deliver an already-consumed action on the next attach cycle.
        if (savedInstanceState != null) {
            intent?.removeExtra("some unique action key")
        }
        super.onCreate(savedInstanceState)
        BackupImportChannelHandler.handleIntent(this, intent)
        AgentBackgroundChannelHandler.handleIntent(intent)
    }

    override fun onNewIntent(intent: android.content.Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        BackupImportChannelHandler.handleIntent(this, intent)
        AgentBackgroundChannelHandler.handleIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register all MethodChannel handlers
        ChannelRegistrar.registerAll(flutterEngine, this)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (BackupStorageChannelHandler.handleActivityResult(requestCode, resultCode, data)) {
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }
}
