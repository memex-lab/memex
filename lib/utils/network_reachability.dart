import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/domain/models/task_exceptions.dart';
import 'package:memex/utils/user_storage.dart';

/// Task status for work that is saved and waiting until the device is online.
const waitingNetworkTaskStatus = 'waiting_network';

/// Best-effort check that the device can resolve a public DNS name.
///
/// Used when the configured model host is unknown. A local or private model
/// endpoint does not use this probe.
Future<bool> canReachPublicInternet({
  Duration timeout = const Duration(seconds: 2),
}) {
  return _lookupHost('one.one.one.one', timeout);
}

/// Endpoint the chat agent will call, including a provider default when the
/// saved base URL is empty.
Future<String?> readActiveModelEndpoint() async {
  try {
    final config = await UserStorage.getAgentLLMConfig(
      AgentDefinitions.chatAgent,
      defaultClientKey: LLMConfig.defaultClientKey,
    );
    final base = config.baseUrl.trim();
    if (base.isNotEmpty) return base;
    final fallback = LLMConfig.defaultBaseUrl(config.type).trim();
    return fallback.isEmpty ? null : fallback;
  } catch (_) {
    return null;
  }
}

/// True for loopback, mDNS `.local`, and RFC1918 hosts.
///
/// These can answer without public DNS, so a failed lookup of a public
/// resolver must not park the turn.
bool isPrivateModelEndpoint(String? endpoint) {
  final host = modelEndpointHost(endpoint);
  if (host == null) return false;
  return _isPrivateHost(host);
}

/// Host of a model base URL. Accepts a full URL or `host:port`.
String? modelEndpointHost(String? endpoint) {
  final raw = endpoint?.trim();
  if (raw == null || raw.isEmpty) return null;
  final withScheme = raw.contains('://') ? raw : 'http://$raw';
  final uri = Uri.tryParse(withScheme);
  if (uri == null) return null;
  var host = uri.host.trim().toLowerCase();
  while (host.endsWith('.')) {
    host = host.substring(0, host.length - 1);
  }
  return host.isEmpty ? null : host;
}

/// Whether a send should run now.
///
/// Private endpoints skip the probe and are parked only if the request itself
/// fails with an offline or name-resolution error. Public endpoints are
/// resolved directly. [whenPublic] replaces that lookup in tests.
Future<bool> canReachActiveModelEndpoint({
  Future<bool> Function()? whenPublic,
  Duration timeout = const Duration(seconds: 2),
}) async {
  final endpoint = await readActiveModelEndpoint();
  if (isPrivateModelEndpoint(endpoint)) return true;
  if (whenPublic != null) return whenPublic();
  final host = modelEndpointHost(endpoint);
  if (host == null) return canReachPublicInternet(timeout: timeout);
  return _lookupHost(host, timeout);
}

Future<bool> _lookupHost(String host, Duration timeout) async {
  try {
    final result = await InternetAddress.lookup(host).timeout(timeout);
    return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}

bool _isPrivateHost(String host) {
  if (host == 'localhost' || host.endsWith('.localhost')) return true;
  if (host.endsWith('.local')) return true;

  final address = InternetAddress.tryParse(host);
  if (address == null) return false;
  if (address.isLoopback) return true;
  if (address.type == InternetAddressType.IPv4) {
    return _isPrivateIpv4(address.rawAddress);
  }
  if (address.type == InternetAddressType.IPv6) {
    return _isPrivateIpv6(address.rawAddress);
  }
  return false;
}

bool _isPrivateIpv4(List<int> bytes) {
  if (bytes.length != 4) return false;
  final a = bytes[0];
  final b = bytes[1];
  if (a == 0 || a == 10 || a == 127) return true;
  if (a == 192 && b == 168) return true;
  if (a == 172 && b >= 16 && b <= 31) return true;
  return false;
}

bool _isPrivateIpv6(List<int> bytes) {
  if (bytes.length != 16) return false;
  // Unique local fc00::/7 and link-local fe80::/10.
  if ((bytes[0] & 0xfe) == 0xfc) return true;
  if (bytes[0] == 0xfe && (bytes[1] & 0xc0) == 0x80) return true;
  return false;
}

/// True when [error] is an offline or name-resolution failure.
///
/// Connection refused, connection reset, and a generic client failure are
/// not parked. Those use the normal retry limit and can end as failed, which
/// is what a down local server needs.
bool looksLikeNetworkError(Object error) {
  if (error is WaitingForNetworkException) return true;

  final actual = unwrapNetworkError(error);
  if (actual is WaitingForNetworkException) return true;
  if (actual is SocketException && _isOfflineOrNameResolution(actual)) {
    return true;
  }

  final text = '${error.toString()}\n${actual.toString()}'.toLowerCase();
  return _offlineOrDnsText(text);
}

bool _isOfflineOrNameResolution(SocketException error) {
  final text = '${error.message} ${error.osError?.message ?? ''}'.toLowerCase();
  return _offlineOrDnsText(text);
}

bool _offlineOrDnsText(String text) {
  return text.contains('failed host lookup') ||
      text.contains('network is unreachable') ||
      text.contains('network unreachable') ||
      text.contains('no address associated with hostname') ||
      text.contains('nodename nor servname') ||
      text.contains('name or service not known') ||
      text.contains('temporary failure in name resolution') ||
      text.contains('no such host');
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
