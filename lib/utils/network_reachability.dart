import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/domain/models/task_exceptions.dart';

/// Task status for work that is saved and waiting until the device is online.
const waitingNetworkTaskStatus = 'waiting_network';

/// Best-effort check that the device can resolve a public DNS name.
///
/// Captive portals and firewalls can still block an LLM API after this
/// succeeds. A failure parks the turn; a manual retry runs it anyway.
Future<bool> canReachPublicInternet({
  Duration timeout = const Duration(seconds: 2),
}) async {
  try {
    final result = await InternetAddress.lookup('one.one.one.one').timeout(
      timeout,
    );
    return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}

/// True when [error] is a connectivity failure rather than a model or
/// application error. Walks agent and task wrappers so a host-lookup buried
/// in `AgentException.error` still counts.
bool looksLikeNetworkError(Object error) {
  final actual = unwrapNetworkError(error);
  if (actual is SocketException ||
      actual is HandshakeException ||
      actual is HttpException ||
      actual is TlsException ||
      actual is WaitingForNetworkException) {
    return true;
  }

  final text = '${error.toString()}\n${actual.toString()}';
  return text.contains('SocketException') ||
      text.contains('HandshakeException') ||
      text.contains('HttpException') ||
      text.contains('TlsException') ||
      text.contains('Failed host lookup') ||
      text.contains('Network is unreachable') ||
      text.contains('Connection refused') ||
      text.contains('Connection reset') ||
      text.contains('Connection closed before full header') ||
      text.contains('ClientException') ||
      text.contains('The connection errored');
}

Object unwrapNetworkError(Object error) {
  var current = error;
  for (var i = 0; i < 6; i++) {
    if (current is WaitingForNetworkException) {
      current = current.cause;
      continue;
    }
    if (current is AgentException && current.error != null) {
      current = current.error!;
      continue;
    }
    if (current is NonRetryableLlmException && current.originalError != null) {
      current = current.originalError!;
      continue;
    }
    break;
  }
  return current;
}
