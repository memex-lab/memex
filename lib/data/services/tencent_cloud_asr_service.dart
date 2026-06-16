import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:memex/data/services/realtime_speech_transcriber.dart';
import 'package:memex/domain/models/speech_recognition_config.dart';
import 'package:memex/utils/logger.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef TencentRealtimeChannelConnector = WebSocketChannel Function(Uri uri);

class TencentCloudAsrService {
  TencentCloudAsrService({
    http.Client? httpClient,
    DateTime Function()? now,
  })  : _httpClient = httpClient ?? http.Client(),
        _now = now ?? DateTime.now;

  static final TencentCloudAsrService instance = TencentCloudAsrService();

  static const _host = 'asr.cloud.tencent.com';

  final http.Client _httpClient;
  final DateTime Function() _now;

  Future<String?> transcribeFile(
    String audioPath, {
    required TencentCloudAsrConfig config,
  }) async {
    final bytes = await File(audioPath).readAsBytes();
    if (bytes.isEmpty) return null;
    return transcribeBytes(
      bytes,
      config: config,
      voiceFormat: voiceFormatForPath(audioPath),
    );
  }

  Future<String?> transcribeBytes(
    List<int> bytes, {
    required TencentCloudAsrConfig config,
    required String voiceFormat,
  }) async {
    if (!config.isConfigured) {
      throw const TencentCloudAsrException(
        'Tencent Cloud ASR credentials are not configured.',
      );
    }
    if (bytes.isEmpty) return null;

    final timestamp = _now().millisecondsSinceEpoch ~/ 1000;
    final params = flashParams(
      config: config,
      voiceFormat: voiceFormat,
      timestamp: timestamp,
    );
    final signature = flashSignature(
      appId: config.appId.trim(),
      secretKey: config.secretKey.trim(),
      params: params,
    );
    final uri = flashUri(appId: config.appId.trim(), params: params);

    final response = await _httpClient.post(
      uri,
      headers: {
        'Host': _host,
        'Authorization': signature,
        'Content-Type': 'application/octet-stream',
        'Content-Length': bytes.length.toString(),
      },
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw TencentCloudAsrException(
        'Tencent Cloud ASR request failed (${response.statusCode}).',
      );
    }

    return parseFlashTranscript(utf8.decode(response.bodyBytes));
  }

  static Map<String, String> flashParams({
    required TencentCloudAsrConfig config,
    required String voiceFormat,
    required int timestamp,
  }) {
    final params = <String, String>{
      'convert_num_mode': '1',
      'engine_type': config.engineType.trim().isEmpty
          ? TencentCloudAsrConfig.defaultEngineType
          : config.engineType.trim(),
      'filter_dirty': '0',
      'filter_modal': '0',
      'filter_punc': '0',
      'first_channel_only': '1',
      'secretid': config.secretId.trim(),
      'speaker_diarization': '0',
      'timestamp': timestamp.toString(),
      'voice_format': voiceFormat,
      'word_info': '0',
    };
    final hotwordList = config.hotwordList.trim();
    if (hotwordList.isNotEmpty) {
      params['hotword_list'] = hotwordList;
    }
    return params;
  }

  static Uri flashUri({
    required String appId,
    required Map<String, String> params,
  }) {
    return Uri.https(
      _host,
      '/asr/flash/v1/$appId',
      _sortedParams(params),
    );
  }

  static String flashSignature({
    required String appId,
    required String secretKey,
    required Map<String, String> params,
  }) {
    final source = 'POST$_host/asr/flash/v1/$appId?${_canonicalQuery(params)}';
    return _hmacSha1Base64(source, secretKey);
  }

  static String? parseFlashTranscript(String responseBody) {
    final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
    final code = decoded['code'];
    if (code != 0) {
      throw TencentCloudAsrException(
        decoded['message'] as String? ?? 'Tencent Cloud ASR failed.',
        code: code is int ? code : null,
        requestId: decoded['request_id'] as String?,
      );
    }
    final results = decoded['flash_result'];
    if (results is! List) return null;
    final parts = <String>[];
    for (final item in results) {
      if (item is! Map<String, dynamic>) continue;
      final text = item['text'] as String?;
      if (text != null && text.trim().isNotEmpty) {
        parts.add(text.trim());
        continue;
      }
      final sentenceList = item['sentence_list'];
      if (sentenceList is List) {
        for (final sentence in sentenceList) {
          if (sentence is! Map<String, dynamic>) continue;
          final sentenceText = sentence['text'] as String?;
          if (sentenceText != null && sentenceText.trim().isNotEmpty) {
            parts.add(sentenceText.trim());
          }
        }
      }
    }
    final transcript = parts.join('\n').trim();
    return transcript.isEmpty ? null : transcript;
  }

  static String voiceFormatForPath(String audioPath) {
    switch (path.extension(audioPath).toLowerCase()) {
      case '.wav':
        return 'wav';
      case '.pcm':
        return 'pcm';
      case '.mp3':
        return 'mp3';
      case '.m4a':
        return 'm4a';
      case '.aac':
        return 'aac';
      case '.amr':
        return 'amr';
      case '.ogg':
      case '.opus':
        return 'ogg-opus';
      default:
        throw TencentCloudAsrException(
          'Unsupported Tencent Cloud ASR audio format: ${path.extension(audioPath).toLowerCase()}',
        );
    }
  }

  static Map<String, String> realtimeParams({
    required TencentCloudAsrConfig config,
    required String voiceId,
    required int timestamp,
    required int nonce,
    int? expired,
  }) {
    final params = <String, String>{
      'convert_num_mode': '1',
      'engine_model_type': config.engineType.trim().isEmpty
          ? TencentCloudAsrConfig.defaultEngineType
          : config.engineType.trim(),
      'expired': (expired ?? timestamp + 86400).toString(),
      'filter_dirty': '0',
      'filter_empty_result': '1',
      'filter_modal': '0',
      'filter_punc': '0',
      'needvad': '1',
      'nonce': nonce.toString(),
      'secretid': config.secretId.trim(),
      'timestamp': timestamp.toString(),
      'voice_format': '1',
      'voice_id': voiceId,
      'word_info': '0',
    };
    final hotwordList = config.hotwordList.trim();
    if (hotwordList.isNotEmpty) {
      params['hotword_list'] = hotwordList;
    }
    return params;
  }

  static Uri realtimeUri({
    required String appId,
    required String secretKey,
    required Map<String, String> params,
  }) {
    final signature = realtimeSignature(
      appId: appId,
      secretKey: secretKey,
      params: params,
    );
    final allParams = {
      ..._sortedParams(params),
      'signature': signature,
    };
    return Uri.https(_host, '/asr/v2/$appId', allParams);
  }

  static String realtimeSignature({
    required String appId,
    required String secretKey,
    required Map<String, String> params,
  }) {
    final source = '$_host/asr/v2/$appId?${_canonicalQuery(params)}';
    return _hmacSha1Base64(source, secretKey);
  }

  RealtimeSpeechTranscriber createRealtimeTranscriber({
    required TencentCloudAsrConfig config,
    required void Function(String fullText) onTextChanged,
    TencentRealtimeChannelConnector? connector,
  }) {
    return TencentCloudRealtimeTranscriber(
      config: config,
      onTextChanged: onTextChanged,
      connector: connector,
      now: _now,
    );
  }

  static Map<String, String> _sortedParams(Map<String, String> params) {
    return Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  static String _canonicalQuery(Map<String, String> params) {
    return _sortedParams(params).entries.map((entry) {
      return '${entry.key}=${entry.value}';
    }).join('&');
  }

  static String _hmacSha1Base64(String source, String secretKey) {
    final hmac = Hmac(sha1, utf8.encode(secretKey));
    return base64Encode(hmac.convert(utf8.encode(source)).bytes);
  }
}

class TencentCloudRealtimeTranscriber implements RealtimeSpeechTranscriber {
  TencentCloudRealtimeTranscriber({
    required TencentCloudAsrConfig config,
    required void Function(String fullText) onTextChanged,
    TencentRealtimeChannelConnector? connector,
    DateTime Function()? now,
    int Function()? nonce,
    String Function()? voiceIdFactory,
  })  : _config = config,
        _onTextChanged = onTextChanged,
        _connector = connector ?? IOWebSocketChannel.connect,
        _now = now ?? DateTime.now,
        _nonce = nonce ??
            (() => DateTime.now().millisecondsSinceEpoch.remainder(1 << 31)),
        _voiceIdFactory = voiceIdFactory ?? const Uuid().v4;

  final TencentCloudAsrConfig _config;
  final void Function(String fullText) _onTextChanged;
  final TencentRealtimeChannelConnector _connector;
  final DateTime Function() _now;
  final int Function() _nonce;
  final String Function() _voiceIdFactory;
  final Logger _logger = getLogger('TencentCloudRealtimeTranscriber');

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Completer<void>? _handshakeCompleter;
  Completer<String?>? _finishCompleter;
  final Map<int, String> _stableSegments = {};
  final Map<int, String> _pendingSegments = {};
  bool _disposed = false;

  @override
  Future<void> init() async {
    if (!_config.isConfigured) {
      throw const TencentCloudAsrException(
        'Tencent Cloud ASR credentials are not configured.',
      );
    }
    final timestamp = _now().millisecondsSinceEpoch ~/ 1000;
    final params = TencentCloudAsrService.realtimeParams(
      config: _config,
      voiceId: _voiceIdFactory(),
      timestamp: timestamp,
      nonce: _nonce(),
    );
    final uri = TencentCloudAsrService.realtimeUri(
      appId: _config.appId.trim(),
      secretKey: _config.secretKey.trim(),
      params: params,
    );

    _handshakeCompleter = Completer<void>();
    _channel = _connector(uri);
    _subscription = _channel!.stream.listen(
      _handleMessage,
      onError: (Object error, StackTrace stackTrace) {
        _logger.warning('Tencent Cloud realtime ASR stream error: $error');
        _completeHandshakeError(error, stackTrace);
        _completeFinishError(error, stackTrace);
      },
      onDone: () {
        if (_finishCompleter != null && !_finishCompleter!.isCompleted) {
          _finishCompleter!.complete(_displayTextOrNull());
        }
      },
    );

    await _handshakeCompleter!.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException(
          'Tencent Cloud realtime ASR handshake timed out.',
        );
      },
    );
  }

  @override
  void addAudioChunk(Uint8List pcmBytes) {
    if (_disposed || pcmBytes.isEmpty) return;
    _channel?.sink.add(pcmBytes);
  }

  @override
  Future<String?> finish() async {
    if (_disposed) return _displayTextOrNull();
    _finishCompleter ??= Completer<String?>();
    _channel?.sink.add(jsonEncode({'type': 'end'}));
    try {
      return await _finishCompleter!.future.timeout(
        const Duration(seconds: 20),
        onTimeout: _displayTextOrNull,
      );
    } finally {
      dispose();
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    unawaited(_subscription?.cancel());
    _subscription = null;
    unawaited(_channel?.sink.close());
    _channel = null;
  }

  void _handleMessage(dynamic message) {
    if (message is! String) return;
    final decoded = jsonDecode(message) as Map<String, dynamic>;
    final code = decoded['code'];
    if (code is int && code != 0) {
      final error = TencentCloudAsrException(
        decoded['message'] as String? ?? 'Tencent Cloud realtime ASR failed.',
      );
      _completeHandshakeError(error);
      _completeFinishError(error);
      return;
    }

    if (_handshakeCompleter != null && !_handshakeCompleter!.isCompleted) {
      _handshakeCompleter!.complete();
    }

    if (decoded['final'] == 1) {
      if (_finishCompleter != null && !_finishCompleter!.isCompleted) {
        _finishCompleter!.complete(_displayTextOrNull());
      }
      return;
    }

    final event = parseRealtimeResult(decoded);
    if (event == null || event.text.trim().isEmpty) return;
    if (event.isStable) {
      _stableSegments[event.index] = event.text.trim();
      _pendingSegments.remove(event.index);
    } else {
      _pendingSegments[event.index] = event.text.trim();
    }
    final displayText = _displayTextOrNull();
    if (displayText != null) {
      _onTextChanged(displayText);
    }
  }

  static TencentRealtimeTextEvent? parseRealtimeResult(
    Map<String, dynamic> message,
  ) {
    final result = message['result'];
    if (result is! Map<String, dynamic>) return null;
    final text = result['voice_text_str'] as String?;
    if (text == null) return null;
    final index = result['index'] as int? ?? 0;
    final sliceType = result['slice_type'] as int? ?? 1;
    return TencentRealtimeTextEvent(
      index: index,
      text: text,
      isStable: sliceType == 2,
    );
  }

  String? _displayTextOrNull() {
    final indexes = {
      ..._stableSegments.keys,
      ..._pendingSegments.keys,
    }.toList()
      ..sort();
    final parts = <String>[];
    for (final index in indexes) {
      final text = _stableSegments[index] ?? _pendingSegments[index];
      if (text != null && text.trim().isNotEmpty) parts.add(text.trim());
    }
    final text = parts.join(' ').trim();
    return text.isEmpty ? null : text;
  }

  void _completeHandshakeError(Object error, [StackTrace? stackTrace]) {
    final completer = _handshakeCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.completeError(error, stackTrace);
    }
  }

  void _completeFinishError(Object error, [StackTrace? stackTrace]) {
    final completer = _finishCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.completeError(error, stackTrace);
    }
  }
}

class TencentRealtimeTextEvent {
  final int index;
  final String text;
  final bool isStable;

  const TencentRealtimeTextEvent({
    required this.index,
    required this.text,
    required this.isStable,
  });
}

class TencentCloudAsrException implements Exception {
  final String message;
  final int? code;
  final String? requestId;

  const TencentCloudAsrException(
    this.message, {
    this.code,
    this.requestId,
  });

  @override
  String toString() {
    final parts = <String>[
      'TencentCloudAsrException',
      if (code != null) 'code=$code',
      if (requestId != null && requestId!.isNotEmpty) 'requestId=$requestId',
      message,
    ];
    return parts.join(': ');
  }
}
