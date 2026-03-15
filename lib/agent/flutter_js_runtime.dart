import 'dart:convert';
import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:flutter_js/flutter_js.dart' as flutter_js;

/// Flutter (flutter_js) implementation of [JavaScriptRuntime] for RunJavaScript
/// in file-system Skills. Uses QuickJS (Android/Linux/Windows) or JavaScriptCore
/// (iOS/macOS) under the hood via the `flutter_js` package.
class FlutterJavaScriptRuntime implements JavaScriptRuntime {
  final flutter_js.JavascriptRuntime runtime;

  /// [runtime] defaults to [flutter_js.getJavascriptRuntime] which already
  /// calls `enableHandlePromises()`. When a custom runtime is supplied the
  /// caller must ensure promise support is enabled.
  FlutterJavaScriptRuntime({flutter_js.JavascriptRuntime? runtime})
      : runtime = runtime ?? flutter_js.getJavascriptRuntime();

  @override
  Future<JavaScriptExecutionResult> executeFile({
    required String scriptPath,
    Map<String, dynamic>? args,
    Duration? timeout,
    required JavaScriptBridgeRegistry bridgeRegistry,
    required JavaScriptBridgeContext bridgeContext,
  }) async {
    final scriptFile = File(scriptPath);
    if (!scriptFile.existsSync()) {
      return JavaScriptExecutionResult(
        success: false,
        error: 'JavaScript file not found: $scriptPath',
      );
    }

    final scriptSource = await scriptFile.readAsString();
    final execId = DateTime.now().microsecondsSinceEpoch.toString();
    final bridgeChannel = '__dart_agent_bridge_$execId';
    final resultChannel = '__dart_agent_result_$execId';
    final timeoutDuration = timeout ?? const Duration(seconds: 30);

    final stderrBuffer = StringBuffer();

    // Register bridge-call handler so JS scripts can call back into Dart.
    runtime.onMessage(bridgeChannel, (dynamic raw) async {
      final packet = _decode(raw);
      if (packet == null) return;
      final requestId = packet['id']?.toString();
      final channel = packet['channel']?.toString();
      final payload = (packet['payload'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};
      if (requestId == null || channel == null) return;

      try {
        final value =
            await bridgeRegistry.invoke(channel, payload, bridgeContext);
        final js =
            "globalThis.__dartAgentBridgeResolve(${jsonEncode(requestId)}, ${jsonEncode(value)});";
        final eval = runtime.evaluate(js);
        if (eval.isError) stderrBuffer.writeln(eval.stringResult);
      } catch (e) {
        final js =
            "globalThis.__dartAgentBridgeReject(${jsonEncode(requestId)}, ${jsonEncode(e.toString())});";
        final eval = runtime.evaluate(js);
        if (eval.isError) stderrBuffer.writeln(eval.stringResult);
      }
    });

    final bootstrap = _buildBootstrap(
      scriptSource: scriptSource,
      args: args ?? const <String, dynamic>{},
      bridgeChannel: bridgeChannel,
      resultChannel: resultChannel,
    );

    // --- flutter_js async execution protocol ---
    // 1) evaluateAsync  – parse & start execution (returns a Promise handle)
    // 2) executePendingJob – kick the QuickJS job queue once
    // 3) handlePromise    – poll executePendingJob() every ~20 ms until the
    //                        Promise settles (resolve / reject / timeout)
    final evalResult = await runtime.evaluateAsync(bootstrap);
    if (evalResult.isError) {
      return JavaScriptExecutionResult(
          success: false, error: evalResult.stringResult);
    }

    runtime.executePendingJob();

    try {
      await runtime.handlePromise(evalResult, timeout: timeoutDuration);
    } catch (_) {
      // Promise rejected or timed out – fall through to read the result that
      // the bootstrap already wrote to globalThis.__dartAgentLastResult.
    }

    // The bootstrap always writes its outcome to __dartAgentLastResult before
    // the Promise settles, so this read should succeed for both success and
    // error cases.
    final result = _readLastResultFromRuntime(
      stderr: stderrBuffer.toString(),
    );
    if (result != null) return result;

    return JavaScriptExecutionResult(
      success: false,
      error:
          'JavaScript execution completed but no result was captured '
          '(timeout: ${timeoutDuration.inMilliseconds}ms)',
      stderr: stderrBuffer.toString(),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic>? _decode(dynamic raw) {
    try {
      if (raw is Map<String, dynamic>) return raw;
      if (raw is Map) return raw.cast<String, dynamic>();
      if (raw is List && raw.isNotEmpty) {
        final first = raw.first;
        if (first is String && first.isNotEmpty) {
          final decoded = jsonDecode(first);
          if (decoded is Map<String, dynamic>) return decoded;
          if (decoded is Map) return decoded.cast<String, dynamic>();
        }
      }
      if (raw is String && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return decoded.cast<String, dynamic>();
      }
    } catch (_) {}
    return null;
  }

  JavaScriptExecutionResult? _readLastResultFromRuntime({
    required String stderr,
  }) {
    final result = runtime.evaluate(
      'JSON.stringify(globalThis.__dartAgentLastResult ?? null)',
    );
    if (result.isError) return null;
    final raw = result.stringResult;
    if (raw.isEmpty || raw == 'null' || raw == 'undefined') return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final packet = decoded.cast<String, dynamic>();
      final type = packet['type']?.toString();
      if (type == 'result') {
        return JavaScriptExecutionResult(
          success: true,
          result: packet['result'],
          stderr: stderr,
        );
      }
      if (type == 'error') {
        return JavaScriptExecutionResult(
          success: false,
          error: (packet['error'] ?? 'Unknown JavaScript error').toString(),
          stderr: stderr,
        );
      }
    } catch (_) {}
    return null;
  }

  // ---------------------------------------------------------------------------
  // Bootstrap JS
  // ---------------------------------------------------------------------------

  String _buildBootstrap({
    required String scriptSource,
    required Map<String, dynamic> args,
    required String bridgeChannel,
    required String resultChannel,
  }) {
    final encodedScript = jsonEncode(scriptSource);
    final encodedArgs = jsonEncode(args);
    final encodedBridgeChannel = jsonEncode(bridgeChannel);
    final encodedResultChannel = jsonEncode(resultChannel);
    return '''
(function () {
  const __bridgeChannel = $encodedBridgeChannel;
  const __resultChannel = $encodedResultChannel;
  const __script = $encodedScript;
  const __args = $encodedArgs;
  globalThis.__dartAgentLastResult = null;

  globalThis.__dartAgentBridgePending = globalThis.__dartAgentBridgePending || {};
  globalThis.__dartAgentBridgeCall = function(channel, payload) {
    return new Promise(function(resolve, reject) {
      var id = "req_" + Date.now() + "_" + Math.floor(Math.random() * 1000000);
      globalThis.__dartAgentBridgePending[id] = { resolve: resolve, reject: reject };
      sendMessage(__bridgeChannel, JSON.stringify({ id: id, channel: channel, payload: payload || {} }));
    });
  };
  globalThis.__dartAgentBridgeResolve = function(id, value) {
    var pending = globalThis.__dartAgentBridgePending[id];
    if (!pending) return;
    delete globalThis.__dartAgentBridgePending[id];
    pending.resolve(value);
  };
  globalThis.__dartAgentBridgeReject = function(id, error) {
    var pending = globalThis.__dartAgentBridgePending[id];
    if (!pending) return;
    delete globalThis.__dartAgentBridgePending[id];
    pending.reject(new Error(error || "bridge_error"));
  };

  return (async function () {
    try {
      (0, eval)(__script);
      var entry =
        (typeof run === "function" && run) ||
        (typeof main === "function" && main) ||
        (typeof globalThis["default"] === "function" && globalThis["default"]);
      if (typeof entry !== "function") {
        throw new Error("Script must define a function: run(ctx) or main(ctx)");
      }
      var result = await entry({ args: __args, bridge: { call: globalThis.__dartAgentBridgeCall } });
      globalThis.__dartAgentLastResult = { type: "result", result: result };
      return result;
    } catch (e) {
      var message = (e && e.stack) ? String(e.stack) : String(e);
      globalThis.__dartAgentLastResult = { type: "error", error: message };
    }
  })();
})();
''';
  }
}
