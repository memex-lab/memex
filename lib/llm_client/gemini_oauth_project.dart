import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../data/services/gemini_auth_service.dart';

const _codeAssistEndpoint = 'https://cloudcode-pa.googleapis.com';
const _codeAssistHeaders = {
  'X-Goog-Api-Client': 'gl-node/22.17.0',
  'Client-Metadata':
      'ideType=IDE_UNSPECIFIED,platform=PLATFORM_UNSPECIFIED,pluginType=GEMINI',
};

final Logger _logger = Logger('GeminiOAuthProject');

/// Resolves and caches the GCP project ID required by Cloud Code Assist.
/// Mirrors the opencode-gemini-auth `project/context.ts` logic.
class GeminiOAuthProject {
  static String? _cachedProjectId;

  /// User-Agent matching gemini-cli so Code Assist backend accepts the request.
  static String get geminiCliUserAgent {
    final os = Platform.isAndroid
        ? 'android'
        : Platform.isIOS
            ? 'ios'
            : Platform.operatingSystem;
    final arch = Platform.version.contains('arm') ? 'arm64' : 'x64';
    return 'GeminiCLI/1.0.0/gemini-code-assist ($os; $arch)';
  }

  /// Returns a valid project ID, resolving via loadCodeAssist if needed.
  static Future<String> ensureProjectId() async {
    if (_cachedProjectId != null && _cachedProjectId!.isNotEmpty) {
      return _cachedProjectId!;
    }

    // Try persisted value first
    final saved = await GeminiAuthService.getProjectId();
    if (saved != null && saved.isNotEmpty) {
      _cachedProjectId = saved;
      return saved;
    }

    final accessToken = await GeminiAuthService.getValidAccessToken();
    if (accessToken == null) throw Exception('Gemini OAuth not authorized.');

    final projectId = await _resolveProjectId(accessToken);
    if (projectId == null || projectId.isEmpty) {
      throw Exception('Could not resolve a GCP project for Gemini Code Assist. '
          'Please ensure your Google account has access to Gemini Code Assist.');
    }

    _cachedProjectId = projectId;
    await GeminiAuthService.saveProjectId(projectId);
    return projectId;
  }

  static void invalidateCache() {
    _cachedProjectId = null;
  }

  static Future<String?> _resolveProjectId(String accessToken) async {
    try {
      final payload = await _loadCodeAssist(accessToken);
      if (payload == null) return null;

      // Already has a managed project
      final managedProject = payload['cloudaicompanionProject'] as String?;
      if (managedProject != null && managedProject.isNotEmpty) {
        return managedProject;
      }

      // Has an active tier — onboard to get a project
      final currentTier = (payload['currentTier'] as Map?)?['id'] as String?;
      if (currentTier != null) {
        return await _onboardUser(accessToken, currentTier);
      }

      // Pick from allowed tiers
      final allowedTiers = payload['allowedTiers'] as List? ?? [];
      if (allowedTiers.isEmpty) return null;

      final tier = _pickFreeTier(allowedTiers) ?? allowedTiers.first;
      final tierId = (tier as Map)['id'] as String? ?? 'free-tier';
      return await _onboardUser(accessToken, tierId);
    } catch (e) {
      _logger.warning('Failed to resolve project ID: $e');
      return null;
    }
  }

  static Map<String, String> _headers(String accessToken) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
        'User-Agent': geminiCliUserAgent,
        ..._codeAssistHeaders,
      };

  /// Fetches available Gemini model IDs visible to the current account/project.
  /// If the request fails or returns no models, returns an empty list so callers
  /// can fall back to a local default list.
  static Future<List<String>> fetchAvailableModels() async {
    try {
      final accessToken = await GeminiAuthService.getValidAccessToken();
      if (accessToken == null) {
        _logger.warning('fetchAvailableModels: no valid access token');
        return [];
      }
      final projectId = await ensureProjectId();
      final url = '$_codeAssistEndpoint/v1internal:retrieveUserQuota';
      final response = await http.post(
        Uri.parse(url),
        headers: _headers(accessToken),
        body: jsonEncode({'project': projectId}),
      );

      if (!response.ok) {
        _logger.warning(
            'retrieveUserQuota failed: ${response.statusCode} ${response.body}');
        return [];
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final buckets = data['quotaBuckets'] as List? ?? const [];
      final models = <String>{};

      for (final bucket in buckets) {
        if (bucket is! Map) continue;
        final bucketModels = bucket['models'];
        if (bucketModels is List) {
          for (final m in bucketModels) {
            if (m is String) {
              models.add(m);
            } else if (m is Map && m['model'] is String) {
              models.add(m['model'] as String);
            }
          }
        }
      }

      final result = models.toList()..sort();
      return result;
    } catch (e) {
      _logger.warning('Failed to fetch available Gemini models: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> _loadCodeAssist(
      String accessToken) async {
    final url = '$_codeAssistEndpoint/v1internal:loadCodeAssist';
    final response = await http.post(
      Uri.parse(url),
      headers: _headers(accessToken),
      body: jsonEncode({
        'metadata': {
          'ideType': 'IDE_UNSPECIFIED',
          'platform': 'PLATFORM_UNSPECIFIED',
          'pluginType': 'GEMINI',
        }
      }),
    );

    if (!response.ok) {
      _logger.warning(
          'loadCodeAssist failed: ${response.statusCode} ${response.body}');
      return null;
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<String?> _onboardUser(String accessToken, String tierId) async {
    final url = '$_codeAssistEndpoint/v1internal:onboardUser';
    final response = await http.post(
      Uri.parse(url),
      headers: _headers(accessToken),
      body: jsonEncode({
        'tierId': tierId,
        'metadata': {
          'ideType': 'IDE_UNSPECIFIED',
          'platform': 'PLATFORM_UNSPECIFIED',
          'pluginType': 'GEMINI',
        }
      }),
    );

    if (!response.ok) {
      _logger.warning(
          'onboardUser failed: ${response.statusCode} ${response.body}');
      return null;
    }

    Map<String, dynamic> payload =
        jsonDecode(response.body) as Map<String, dynamic>;

    // Poll for completion if operation is async
    if (payload['done'] != true && payload['name'] != null) {
      final opName = payload['name'] as String;
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(seconds: 5));
        final opResponse = await http.get(
          Uri.parse('$_codeAssistEndpoint/v1internal/$opName'),
          headers: _headers(accessToken),
        );
        if (opResponse.ok) {
          payload = jsonDecode(opResponse.body) as Map<String, dynamic>;
          if (payload['done'] == true) break;
        }
      }
    }

    if (payload['done'] == true) {
      final projectId = (payload['response']
          as Map?)?['cloudaicompanionProject']?['id'] as String?;
      return projectId;
    }

    return null;
  }

  static dynamic _pickFreeTier(List tiers) {
    for (final tier in tiers) {
      if (tier is Map && (tier['id'] as String?)?.contains('free') == true) {
        return tier;
      }
    }
    return null;
  }
}

extension on http.Response {
  bool get ok => statusCode >= 200 && statusCode < 300;
}
