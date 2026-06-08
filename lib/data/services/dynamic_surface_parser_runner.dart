import 'dart:convert';
import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/flutter_js_runtime.dart';

class DynamicSurfaceParserException implements Exception {
  final String message;

  const DynamicSurfaceParserException(this.message);

  @override
  String toString() => message;
}

class DynamicSurfaceParserRunner {
  DynamicSurfaceParserRunner({
    JavaScriptRuntime Function()? runtimeFactory,
    this.timeout = const Duration(seconds: 1),
    this.maxOutputBytes = 1024 * 1024,
  }) : _runtimeFactory = runtimeFactory ?? FlutterJavaScriptRuntime.new;

  final JavaScriptRuntime Function() _runtimeFactory;
  final Duration timeout;
  final int maxOutputBytes;

  Future<Object?> parse({
    required String scriptPath,
    required String entry,
    required Map<String, dynamic> input,
  }) async {
    final scriptFile = File(scriptPath);
    if (!await scriptFile.exists()) {
      throw DynamicSurfaceParserException(
        'Dynamic Surface parser not found: $scriptPath',
      );
    }
    if (!scriptPath.toLowerCase().endsWith('.js')) {
      throw const DynamicSurfaceParserException(
        'Dynamic Surface parser must be a .js file.',
      );
    }
    if (!RegExp(r'^[A-Za-z_$][0-9A-Za-z_$]*$').hasMatch(entry)) {
      throw DynamicSurfaceParserException(
        'Dynamic Surface parser entry must be a JavaScript identifier: $entry',
      );
    }

    final parserSource = await scriptFile.readAsString();
    final wrapperDir =
        await Directory.systemTemp.createTemp('memex_surface_parser_');
    final wrapperPath = '${wrapperDir.path}${Platform.pathSeparator}runner.js';
    final wrapperFile = File(wrapperPath);
    await wrapperFile.writeAsString(_buildWrapper(parserSource));

    try {
      final runtime = _runtimeFactory();
      final args = {
        'entry': entry,
        'input': _jsonRoundTrip(input),
      };
      final result = await runtime.executeFile(
        scriptPath: wrapperPath,
        args: args,
        timeout: timeout,
        bridgeRegistry: JavaScriptBridgeRegistry(),
        bridgeContext: JavaScriptBridgeContext(
          agentName: 'dynamic_surface_parser',
          sessionId: 'dynamic_surface_parser',
          scriptPath: wrapperPath,
          scriptArgs: args,
        ),
      );
      if (!result.success) {
        throw DynamicSurfaceParserException(
          'Dynamic Surface parser failed: ${result.error ?? 'unknown error'}',
        );
      }
      final parsed = _jsonRoundTrip(result.result);
      final encoded = jsonEncode(parsed);
      if (utf8.encode(encoded).length > maxOutputBytes) {
        throw DynamicSurfaceParserException(
          'Dynamic Surface parser output exceeds $maxOutputBytes bytes.',
        );
      }
      return parsed;
    } finally {
      if (await wrapperDir.exists()) {
        await wrapperDir.delete(recursive: true);
      }
    }
  }

  Object? _jsonRoundTrip(Object? value) {
    try {
      return jsonDecode(jsonEncode(value));
    } catch (e) {
      throw DynamicSurfaceParserException(
        'Dynamic Surface parser input/output must be JSON serializable: $e',
      );
    }
  }

  String _buildWrapper(String parserSource) {
    final encodedSource = jsonEncode(parserSource);
    return '''
async function run(ctx) {
  const parserSource = $encodedSource;
  const input = ctx.args.input || {};
  const entry = ctx.args.entry || "parse";
  if (!/^[A-Za-z_\$][0-9A-Za-z_\$]*\$/.test(entry)) {
    throw new Error("Invalid parser entry: " + entry);
  }
  (0, eval)(parserSource + "\\n//# sourceURL=dynamic-surface-parser.js");
  const parser = globalThis[entry];
  if (typeof parser !== "function") {
    throw new Error("parser.js must define function " + entry + "(input)");
  }
  let result;
  try {
    result = await parser(input);
  } catch (error) {
    const message = error && error.message ? error.message : String(error);
    throw "parser.js error: " + message;
  }
  if (result === undefined) {
    throw new Error("parser.js returned undefined");
  }
  return result;
}
''';
  }
}
