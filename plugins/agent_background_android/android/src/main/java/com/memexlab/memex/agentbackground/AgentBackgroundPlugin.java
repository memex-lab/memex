package com.memexlab.memex.agentbackground;

import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.Map;

public final class AgentBackgroundPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {
  private static final String CHANNEL = "com.memexlab.memex/agent_background";
  private static final String SERVICE_CLASS = "com.memexlab.memex.AgentBackgroundService";
  private static final String ACTION_UPDATE = "com.memexlab.memex.agent_background.UPDATE";
  private static final String ACTION_STOP = "com.memexlab.memex.agent_background.STOP";
  private static final String EXTRA_WATCH_BACKGROUND_WORK = "watchBackgroundWork";
  private static final int NOTIFICATION_ID = 188;

  private Context applicationContext;
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    applicationContext = binding.getApplicationContext();
    channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL);
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    if (channel != null) {
      channel.setMethodCallHandler(null);
      channel = null;
    }
    applicationContext = null;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    if (applicationContext == null) {
      result.error("unavailable", "Application context is unavailable", null);
      return;
    }

    switch (call.method) {
      case "updateAgentStatus":
        startOrUpdateService(call);
        result.success(null);
        break;
      case "finishAgentStatus":
        finishService(call);
        result.success(null);
        break;
      case "stopAgentStatus":
        clearService();
        result.success(null);
        break;
      case "consumeInitialAgentAction":
        result.success(null);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void startOrUpdateService(MethodCall call) {
    Map<?, ?> args = call.arguments instanceof Map ? (Map<?, ?>) call.arguments : null;
    Intent intent = serviceIntent(ACTION_UPDATE);
    putStringExtra(intent, args, "state", "active");
    putStringExtra(intent, args, "title", "Memex Agent");
    putStringExtra(intent, args, "stage", "Processing");
    putStringExtra(intent, args, "detail", "");
    putStringExtra(intent, args, "summary", "");
    putStringExtra(intent, args, "taskSummary", "");
    putStringExtra(intent, args, "statusText", "");
    putStringExtra(intent, args, "runId", "");
    putStringExtra(intent, args, "factId", "");
    putIntExtra(intent, args, "progressCompleted");
    putIntExtra(intent, args, "progressTotal");
    putIntExtra(intent, args, "remainingTasks");
    putIntExtra(intent, args, "pending");
    putIntExtra(intent, args, "processing");
    putIntExtra(intent, args, "retrying");
    intent.putExtra(EXTRA_WATCH_BACKGROUND_WORK, booleanArg(args, "isInBackground", false));
    startForegroundServiceCompat(intent);
  }

  private void finishService(MethodCall call) {
    Map<?, ?> args = call.arguments instanceof Map ? (Map<?, ?>) call.arguments : null;
    String state = stringArg(args, "state", "");
    if ("completed".equals(state) || "idle".equals(state)) {
      clearService();
      return;
    }
    startOrUpdateService(call);
  }

  private Intent serviceIntent(String action) {
    Intent intent = new Intent();
    intent.setClassName(applicationContext, SERVICE_CLASS);
    intent.setAction(action);
    return intent;
  }

  private void startForegroundServiceCompat(Intent intent) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      applicationContext.startForegroundService(intent);
    } else {
      applicationContext.startService(intent);
    }
  }

  private void clearService() {
    applicationContext.stopService(serviceIntent(ACTION_STOP));
    NotificationManager manager =
        (NotificationManager) applicationContext.getSystemService(Context.NOTIFICATION_SERVICE);
    if (manager != null) {
      manager.cancel(NOTIFICATION_ID);
    }
  }

  private static void putStringExtra(
      Intent intent, Map<?, ?> args, String key, String fallback) {
    intent.putExtra(key, stringArg(args, key, fallback));
  }

  private static void putIntExtra(Intent intent, Map<?, ?> args, String key) {
    Object value = args == null ? null : args.get(key);
    intent.putExtra(key, value instanceof Number ? ((Number) value).intValue() : 0);
  }

  private static String stringArg(Map<?, ?> args, String key, String fallback) {
    Object value = args == null ? null : args.get(key);
    return value instanceof String ? (String) value : fallback;
  }

  private static boolean booleanArg(Map<?, ?> args, String key, boolean fallback) {
    Object value = args == null ? null : args.get(key);
    return value instanceof Boolean ? (Boolean) value : fallback;
  }
}
