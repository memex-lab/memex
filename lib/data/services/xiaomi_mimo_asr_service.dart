import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:memex/domain/models/speech_recognition_config.dart';
import 'package:memex/utils/audio_converter.dart';
import 'package:path/path.dart' as path;

typedef XiaomiMimoAudioConverter = Future<String?> Function(String inputPath);

class XiaomiMimoAsrService {
  XiaomiMimoAsrService({
    http.Client? httpClient,
    XiaomiMimoAudioConverter? audioConverter,
  })  : _httpClient = httpClient ?? http.Client(),
        _audioConverter = audioConverter ?? AudioConverter.toWav16kMono;

  static final XiaomiMimoAsrService instance = XiaomiMimoAsrService();

  static const int maxBase64AudioLength = 10 * 1024 * 1024;
  static const int maxBase64AudioBytes = maxBase64AudioLength;
  static final Uri _defaultChatCompletionsUri = Uri.parse(
    '${XiaomiMimoAsrConfig.defaultBaseUrl}/chat/completions',
  );

  final http.Client _httpClient;
  final XiaomiMimoAudioConverter _audioConverter;

  Future<String?> transcribeFile(
    String audioPath, {
    required XiaomiMimoAsrConfig config,
  }) async {
    final preparedPath = await _prepareSupportedAudio(audioPath);
    final bytes = await File(preparedPath).readAsBytes();
    return transcribeBytes(
      bytes,
      config: config,
      mimeType: mimeTypeForPath(preparedPath),
    );
  }

  Future<String?> transcribeBytes(
    List<int> bytes, {
    required XiaomiMimoAsrConfig config,
    String mimeType = 'audio/wav',
  }) async {
    if (!config.hasDirectCredentials) {
      throw const XiaomiMimoAsrException('MiMo ASR API key is not configured.');
    }
    if (bytes.isEmpty) return null;

    final normalizedMimeType = normalizeSupportedMimeType(mimeType);
    final base64Audio = base64Encode(bytes);
    if (base64Audio.length > maxBase64AudioLength) {
      throw const XiaomiMimoAsrException(
        'MiMo ASR audio exceeds the 10MB Base64 limit.',
      );
    }

    final response = await _httpClient.post(
      chatCompletionsUri(config.baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'api-key': config.apiKey.trim(),
      },
      body: jsonEncode(
        chatCompletionBody(
          base64Audio: base64Audio,
          mimeType: normalizedMimeType,
          config: config,
        ),
      ),
    );

    final body = utf8.decode(response.bodyBytes);
    if (response.statusCode != 200) {
      throw XiaomiMimoAsrException(
        errorMessage(body) ??
            'MiMo ASR request failed (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    return parseTranscript(body);
  }

  static Uri chatCompletionsUri(String baseUrl) {
    final trimmed = baseUrl.trim();
    if (trimmed.isEmpty) return _defaultChatCompletionsUri;

    final source = trimmed.contains('://')
        ? trimmed
        : '${_defaultChatCompletionsUri.origin}'
            '${trimmed.startsWith('/') ? trimmed : '/$trimmed'}';
    final Uri uri;
    try {
      uri = Uri.parse(source);
    } on FormatException {
      throw XiaomiMimoAsrException('Invalid MiMo ASR base URL: $baseUrl');
    }
    if (!uri.hasScheme || uri.host.isEmpty) {
      throw XiaomiMimoAsrException('Invalid MiMo ASR base URL: $baseUrl');
    }

    final normalizedPath = uri.path.replaceFirst(RegExp(r'/+$'), '');
    if (normalizedPath.toLowerCase() == '/anthropic') {
      return _uriWithPath(uri, '/v1/chat/completions');
    }
    if (normalizedPath.toLowerCase().endsWith('/chat/completions')) {
      return _uriWithPath(uri, normalizedPath);
    }

    final basePath = normalizedPath.isEmpty ? '/v1' : normalizedPath;
    return _uriWithPath(uri, '$basePath/chat/completions');
  }

  static Uri _uriWithPath(Uri uri, String path) {
    return Uri.parse('${uri.origin}$path');
  }

  static Map<String, dynamic> chatCompletionBody({
    required String base64Audio,
    required String mimeType,
    required XiaomiMimoAsrConfig config,
  }) {
    return {
      'model': _normalizeModel(config.model),
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'input_audio',
              'input_audio': {
                'data': 'data:$mimeType;base64,$base64Audio',
              },
            },
          ],
        },
      ],
      'asr_options': {'language': _normalizeLanguage(config.language)},
    };
  }

  static String? parseTranscript(String responseBody) {
    final decoded = jsonDecode(responseBody);
    if (decoded is! Map<String, dynamic>) {
      throw const XiaomiMimoAsrException(
        'MiMo ASR returned an invalid response.',
      );
    }
    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) return null;
    final first = choices.first;
    if (first is! Map<String, dynamic>) return null;
    final message = first['message'];
    if (message is! Map<String, dynamic>) return null;
    return _extractText(message['content']) ?? _extractText(message['text']);
  }

  static String? errorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is! Map<String, dynamic>) return null;
      final error = decoded['error'];
      if (error is Map<String, dynamic>) {
        final message = error['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
      final message = decoded['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  static String mimeTypeForPath(String audioPath) {
    return switch (path.extension(audioPath).toLowerCase()) {
      '.wav' => 'audio/wav',
      '.mp3' => 'audio/mpeg',
      _ => throw XiaomiMimoAsrException(
          'Unsupported MiMo ASR audio format: ${path.extension(audioPath).toLowerCase()}',
        ),
    };
  }

  static String normalizeSupportedMimeType(String mimeType) {
    return switch (mimeType.trim().toLowerCase()) {
      'audio/wav' || 'audio/wave' || 'audio/x-wav' => 'audio/wav',
      'audio/mpeg' || 'audio/mp3' => 'audio/mpeg',
      _ => throw XiaomiMimoAsrException(
          'Unsupported MiMo ASR audio MIME type: $mimeType',
        ),
    };
  }

  static bool isSupportedInputPath(String audioPath) {
    final extension = path.extension(audioPath).toLowerCase();
    return extension == '.wav' || extension == '.mp3';
  }

  Future<String> _prepareSupportedAudio(String audioPath) async {
    if (isSupportedInputPath(audioPath)) return audioPath;
    final convertedPath = await _audioConverter(audioPath);
    if (convertedPath == null || !File(convertedPath).existsSync()) {
      throw const XiaomiMimoAsrException(
        'Failed to convert audio to WAV for MiMo ASR.',
      );
    }
    return convertedPath;
  }

  static String _normalizeModel(String value) {
    final trimmed = value.trim();
    return XiaomiMimoAsrConfig.supportedModels.contains(trimmed)
        ? trimmed
        : XiaomiMimoAsrConfig.defaultModel;
  }

  static String _normalizeLanguage(String value) {
    final trimmed = value.trim();
    return XiaomiMimoAsrConfig.supportedLanguages.contains(trimmed)
        ? trimmed
        : XiaomiMimoAsrConfig.defaultLanguage;
  }

  static String? _extractText(Object? content) {
    if (content is String) {
      final text = content.trim();
      return text.isEmpty ? null : text;
    }
    if (content is List) {
      final parts = <String>[];
      for (final item in content) {
        final text = _extractText(item);
        if (text != null && text.trim().isNotEmpty) {
          parts.add(text.trim());
        }
      }
      final joined = parts.join('\n').trim();
      return joined.isEmpty ? null : joined;
    }
    if (content is Map<String, dynamic>) {
      final text = _extractText(content['text']);
      if (text != null) return text;
      return _extractText(content['content']);
    }
    return null;
  }
}

class XiaomiMimoAsrException implements Exception {
  const XiaomiMimoAsrException(
    this.message, {
    this.statusCode,
  });

  final String message;
  final int? statusCode;

  @override
  String toString() {
    final status = statusCode == null ? '' : ' (statusCode: $statusCode)';
    return 'XiaomiMimoAsrException$status: $message';
  }
}
