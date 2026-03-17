import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/utils/logger.dart';

final _log = getLogger('ModelListService');

/// Fetches available model IDs from an OpenAI-compatible /v1/models endpoint.
class ModelListService {
  /// Fetch model IDs from the provider's models endpoint.
  /// Returns an empty list on failure (caller should fallback to recommended).
  static Future<List<String>> fetchModels({
    required String type,
    required String baseUrl,
    required String apiKey,
  }) async {
    final endpoint = LLMConfig.modelsEndpoint(type, baseUrl);
    if (endpoint == null) return [];

    _log.info('Fetching models from $endpoint (type=$type)');

    try {
      final headers = <String, String>{
        'Accept': 'application/json',
      };

      // Gemini uses ?key= query parameter for auth, not Bearer token
      Uri requestUri;
      if (type == LLMConfig.typeGemini) {
        if (apiKey.isNotEmpty) {
          // Use simple concatenation — Uri.replace can percent-encode the key incorrectly
          final separator = endpoint.contains('?') ? '&' : '?';
          requestUri = Uri.parse('$endpoint${separator}key=$apiKey');
        } else {
          requestUri = Uri.parse(endpoint);
        }
      } else {
        requestUri = Uri.parse(endpoint);
        if (apiKey.isNotEmpty) {
          headers['Authorization'] = 'Bearer $apiKey';
        }
      }

      final response = await http
          .get(requestUri, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        _log.warning(
            'Failed to fetch models: HTTP ${response.statusCode} from $endpoint\n${response.body}');
        return [];
      }

      final json = jsonDecode(response.body);
      final models = _parseModels(type, json);
      _log.info('Fetched ${models.length} models from $endpoint');
      return models;
    } catch (e) {
      _log.warning('Error fetching models from $endpoint: $e');
      return [];
    }
  }

  static List<String> _parseModels(String type, dynamic json) {
    if (type == LLMConfig.typeGemini) {
      return _parseGeminiModels(json);
    }
    if (type == LLMConfig.typeSeed) {
      return _parseVolcengineModels(json);
    }
    return _parseOpenAiModels(json);
  }

  /// Parse OpenAI-compatible response: { "data": [{ "id": "model-id" }, ...] }
  static List<String> _parseOpenAiModels(dynamic json) {
    if (json is! Map<String, dynamic>) return [];
    final data = json['data'];
    if (data is! List) return [];
    final ids = <String>[];
    for (final item in data) {
      if (item is Map<String, dynamic> && item['id'] is String) {
        ids.add(item['id'] as String);
      }
    }
    ids.sort();
    return ids;
  }

  /// Parse Gemini response: { "models": [{ "name": "models/gemini-..." }, ...] }
  /// Only includes models that support generateContent.
  static List<String> _parseGeminiModels(dynamic json) {
    if (json is! Map<String, dynamic>) return [];
    final models = json['models'];
    if (models is! List) return [];
    final ids = <String>[];
    for (final item in models) {
      if (item is Map<String, dynamic> && item['name'] is String) {
        // Filter: only keep models that support generateContent
        final methods = item['supportedGenerationMethods'];
        if (methods is List && methods.contains('generateContent')) {
          final name = (item['name'] as String).replaceFirst('models/', '');
          ids.add(name);
        }
      }
    }
    ids.sort();
    return ids;
  }

  /// Parse Volcengine response: OpenAI-compatible but with modalities field.
  /// Only includes models with image in input_modalities and text in output_modalities.
  static List<String> _parseVolcengineModels(dynamic json) {
    if (json is! Map<String, dynamic>) return [];
    final data = json['data'];
    if (data is! List) return [];
    final ids = <String>[];
    for (final item in data) {
      if (item is Map<String, dynamic> && item['id'] is String) {
        final modalities = item['modalities'];
        if (modalities is Map<String, dynamic>) {
          final input = modalities['input_modalities'];
          final output = modalities['output_modalities'];
          if (input is List &&
              output is List &&
              input.contains('image') &&
              output.contains('text')) {
            ids.add(item['id'] as String);
          }
        }
      }
    }
    ids.sort();
    return ids;
  }
}
