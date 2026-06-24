import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';

class SuperAgentLoopDetector implements LoopDetector {
  SuperAgentLoopDetector({
    this.toolLoopThreshold = 5,
  });

  final int toolLoopThreshold;
  final List<_ToolCallEntry> _recentToolCalls = [];

  @override
  Future<LoopDetectorResult> detect(ModelMessage chunkMessage) async {
    if (chunkMessage.functionCalls.isEmpty) {
      return LoopDetectorResult(isLoop: false);
    }

    _updateToolCalls(chunkMessage.functionCalls);
    return _checkToolCallLoop();
  }

  void _updateToolCalls(List<FunctionCall> calls) {
    for (final call in calls) {
      final signature = _signature(call);
      if (_recentToolCalls.isNotEmpty && _recentToolCalls.last.id == call.id) {
        _recentToolCalls.last.signature = signature;
        continue;
      }

      _recentToolCalls.add(_ToolCallEntry(call.id, signature));
      if (_recentToolCalls.length > toolLoopThreshold) {
        _recentToolCalls.removeAt(0);
      }
    }
  }

  LoopDetectorResult _checkToolCallLoop() {
    if (_recentToolCalls.length < toolLoopThreshold) {
      return LoopDetectorResult(isLoop: false);
    }

    final firstSignature = _recentToolCalls.first.signature;
    final allSame = _recentToolCalls.every(
      (entry) => entry.signature == firstSignature,
    );
    if (!allSame) {
      return LoopDetectorResult(isLoop: false);
    }

    return LoopDetectorResult(
      isLoop: true,
      message:
          'Tool call loop detected: same tool called $toolLoopThreshold times.',
    );
  }

  String _signature(FunctionCall call) {
    return '${call.name}:${_canonicalArguments(call.arguments)}';
  }

  String _canonicalArguments(String arguments) {
    try {
      return jsonEncode(_sortJson(jsonDecode(arguments)));
    } catch (_) {
      return arguments.trim();
    }
  }

  Object? _sortJson(Object? value) {
    if (value is Map) {
      final sorted = <String, Object?>{};
      final keys = value.keys.map((key) => key.toString()).toList()..sort();
      for (final key in keys) {
        sorted[key] = _sortJson(value[key]);
      }
      return sorted;
    }
    if (value is List) {
      return value.map(_sortJson).toList(growable: false);
    }
    return value;
  }
}

class _ToolCallEntry {
  _ToolCallEntry(this.id, this.signature);

  final String id;
  String signature;
}
