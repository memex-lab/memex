import 'dart:async';

import 'package:flutter/services.dart';
import 'package:memex/data/services/agent_background_status.dart';

abstract class AgentBackgroundPlatform {
  Stream<String> get actionStream;

  Future<void> updateStatus(AgentBackgroundStatus status);

  Future<void> finishStatus(AgentBackgroundStatus status);

  Future<void> stopStatus();

  Future<String?> consumeInitialAction();
}

class MethodChannelAgentBackgroundPlatform implements AgentBackgroundPlatform {
  MethodChannelAgentBackgroundPlatform({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName) {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static const String _channelName = 'com.memexlab.memex/agent_background';

  final MethodChannel _channel;
  final _actionController = StreamController<String>.broadcast();

  @override
  Stream<String> get actionStream => _actionController.stream;

  @override
  Future<void> updateStatus(AgentBackgroundStatus status) {
    return _channel.invokeMethod<void>(
      'updateAgentStatus',
      status.toPlatformMap(),
    );
  }

  @override
  Future<void> finishStatus(AgentBackgroundStatus status) {
    return _channel.invokeMethod<void>(
      'finishAgentStatus',
      status.toPlatformMap(),
    );
  }

  @override
  Future<void> stopStatus() {
    return _channel.invokeMethod<void>('stopAgentStatus');
  }

  @override
  Future<String?> consumeInitialAction() {
    return _channel.invokeMethod<String>('consumeInitialAgentAction');
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'openAgentActivity') {
      _actionController.add('agent_activity');
    }
  }
}
