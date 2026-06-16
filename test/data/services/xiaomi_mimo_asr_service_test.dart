import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:memex/data/services/xiaomi_mimo_asr_service.dart';
import 'package:memex/domain/models/speech_recognition_config.dart';

void main() {
  group('XiaomiMimoAsrService', () {
    const config = XiaomiMimoAsrConfig(apiKey: 'mimo-key');

    test('posts MiMo input_audio request with api-key header', () async {
      late http.Request captured;
      final service = XiaomiMimoAsrService(
        httpClient: MockClient((request) async {
          captured = request;
          return http.Response.bytes(
            utf8.encode(jsonEncode({
              'choices': [
                {
                  'message': {'content': '会议转写完成。'},
                },
              ],
            })),
            200,
          );
        }),
      );

      final text = await service.transcribeBytes(
        [0, 1, 2, 3],
        config: config,
        mimeType: 'audio/wav',
      );

      expect(text, '会议转写完成。');
      expect(captured.url.toString(),
          'https://api.xiaomimimo.com/v1/chat/completions');
      expect(captured.headers['api-key'], 'mimo-key');
      expect(captured.headers['Content-Type'], 'application/json');

      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['model'], XiaomiMimoAsrConfig.defaultModel);
      expect(body['asr_options'], {'language': 'auto'});
      final messages = body['messages'] as List<dynamic>;
      final firstMessage = messages.single as Map<String, dynamic>;
      final content = firstMessage['content'] as List<dynamic>;
      final audio = content.single as Map<String, dynamic>;
      expect(audio['type'], 'input_audio');
      expect(
        (audio['input_audio'] as Map<String, dynamic>)['data'],
        'data:audio/wav;base64,AAECAw==',
      );
    });

    test('normalizes anthropic and full chat completions base URLs', () {
      expect(
        XiaomiMimoAsrService.chatCompletionsUri(
          'https://api.xiaomimimo.com/anthropic',
        ).toString(),
        'https://api.xiaomimimo.com/v1/chat/completions',
      );
      expect(
        XiaomiMimoAsrService.chatCompletionsUri(
          'https://token-plan-sgp.xiaomimimo.com/anthropic',
        ).toString(),
        'https://token-plan-sgp.xiaomimimo.com/v1/chat/completions',
      );
      expect(
        XiaomiMimoAsrService.chatCompletionsUri(
          'https://mimo.example/v1/chat/completions',
        ).toString(),
        'https://mimo.example/v1/chat/completions',
      );
      expect(
        XiaomiMimoAsrService.chatCompletionsUri('https://mimo.example/v1')
            .toString(),
        'https://mimo.example/v1/chat/completions',
      );
      expect(
        XiaomiMimoAsrService.chatCompletionsUri('/v1').toString(),
        'https://api.xiaomimimo.com/v1/chat/completions',
      );
      expect(
        XiaomiMimoAsrService.chatCompletionsUri(
          'https://mimo.example/v1?ignored=true#frag',
        ).toString(),
        'https://mimo.example/v1/chat/completions',
      );
    });

    test('rejects invalid base URLs before posting', () {
      expect(
        () => XiaomiMimoAsrService.chatCompletionsUri('://bad-url'),
        throwsA(isA<XiaomiMimoAsrException>()),
      );
    });

    test('normalizes request model, language, and MIME values', () {
      final body = XiaomiMimoAsrService.chatCompletionBody(
        base64Audio: 'AAAA',
        mimeType: XiaomiMimoAsrService.normalizeSupportedMimeType(
          'audio/x-wav',
        ),
        config: const XiaomiMimoAsrConfig(
          apiKey: 'mimo-key',
          model: 'unknown-model',
          language: 'ja',
        ),
      );

      expect(body['model'], XiaomiMimoAsrConfig.defaultModel);
      expect(body['asr_options'], {'language': 'auto'});
      final messages = body['messages'] as List<dynamic>;
      final content =
          (messages.single as Map<String, dynamic>)['content'] as List<dynamic>;
      final audio = content.single as Map<String, dynamic>;
      expect(
        (audio['input_audio'] as Map<String, dynamic>)['data'],
        'data:audio/wav;base64,AAAA',
      );
      expect(
        XiaomiMimoAsrService.normalizeSupportedMimeType('audio/mp3'),
        'audio/mpeg',
      );
      expect(
        () => XiaomiMimoAsrService.normalizeSupportedMimeType('audio/aac'),
        throwsA(isA<XiaomiMimoAsrException>()),
      );
    });

    test('parses content arrays with text fields', () {
      final transcript = XiaomiMimoAsrService.parseTranscript(
        jsonEncode({
          'choices': [
            {
              'message': {
                'content': [
                  {'type': 'text', 'text': '第一段'},
                  {'type': 'text', 'text': '第二段'},
                ],
              },
            },
          ],
        }),
      );

      expect(transcript, '第一段\n第二段');
    });

    test('parses message text fallback and nested content maps', () {
      expect(
        XiaomiMimoAsrService.parseTranscript(
          jsonEncode({
            'choices': [
              {
                'message': {'text': '备用文本'},
              },
            ],
          }),
        ),
        '备用文本',
      );
      expect(
        XiaomiMimoAsrService.parseTranscript(
          jsonEncode({
            'choices': [
              {
                'message': {
                  'content': {
                    'content': {'text': '嵌套文本'},
                  },
                },
              },
            ],
          }),
        ),
        '嵌套文本',
      );
      expect(
        XiaomiMimoAsrService.parseTranscript(jsonEncode({'choices': []})),
        isNull,
      );
    });

    test('returns null for empty audio without posting', () async {
      final service = XiaomiMimoAsrService(
        httpClient: MockClient((request) async {
          fail('Empty audio should not be posted');
        }),
      );

      expect(await service.transcribeBytes([], config: config), isNull);
    });

    test('throws before posting when API key is missing', () async {
      final service = XiaomiMimoAsrService(
        httpClient: MockClient((request) async {
          fail('Unconfigured MiMo ASR should not post');
        }),
      );

      expect(
        () => service.transcribeBytes(
          [1],
          config: const XiaomiMimoAsrConfig(),
        ),
        throwsA(isA<XiaomiMimoAsrException>()),
      );
    });

    test('throws XiaomiMimoAsrException for API errors', () async {
      final service = XiaomiMimoAsrService(
        httpClient: MockClient((request) async {
          return http.Response(
            jsonEncode({
              'error': {'message': 'invalid api key'},
            }),
            401,
          );
        }),
      );

      expect(
        () => service.transcribeBytes([1], config: config),
        throwsA(
          isA<XiaomiMimoAsrException>()
              .having((e) => e.message, 'message', 'invalid api key')
              .having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('rejects audio when encoded payload exceeds MiMo limit', () async {
      final service = XiaomiMimoAsrService(
        httpClient: MockClient((_) async => http.Response('{}', 200)),
      );
      final bytes = List<int>.filled(
        (XiaomiMimoAsrService.maxBase64AudioLength * 3 ~/ 4) + 4,
        1,
      );

      expect(
        () => service.transcribeBytes(bytes, config: config),
        throwsA(isA<XiaomiMimoAsrException>()),
      );
    });

    test('uses MP3 MIME type for mp3 files', () async {
      final tempDir = await Directory.systemTemp.createTemp('mimo_asr_');
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });
      final audio = File('${tempDir.path}/voice.mp3');
      await audio.writeAsBytes([1, 2, 3]);

      late String dataUrl;
      final service = XiaomiMimoAsrService(
        httpClient: MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          final messages = body['messages'] as List<dynamic>;
          final content =
              (messages.single as Map<String, dynamic>)['content'] as List;
          dataUrl = ((content.single as Map<String, dynamic>)['input_audio']
              as Map<String, dynamic>)['data'] as String;
          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {'content': 'mp3 ok'},
                },
              ],
            }),
            200,
          );
        }),
      );

      final text = await service.transcribeFile(audio.path, config: config);

      expect(text, 'mp3 ok');
      expect(dataUrl, startsWith('data:audio/mpeg;base64,'));
    });

    test('converts unsupported file types to wav before posting', () async {
      final tempDir = await Directory.systemTemp.createTemp('mimo_asr_');
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });
      final source = File('${tempDir.path}/voice.m4a');
      await source.writeAsBytes([1, 2, 3]);
      final converted = File('${tempDir.path}/voice.wav');
      await converted.writeAsBytes([9, 8]);

      String? converterInput;
      late String dataUrl;
      final service = XiaomiMimoAsrService(
        audioConverter: (inputPath) async {
          converterInput = inputPath;
          return converted.path;
        },
        httpClient: MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          final messages = body['messages'] as List<dynamic>;
          final content =
              (messages.single as Map<String, dynamic>)['content'] as List;
          dataUrl = ((content.single as Map<String, dynamic>)['input_audio']
              as Map<String, dynamic>)['data'] as String;
          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {'content': 'converted ok'},
                },
              ],
            }),
            200,
          );
        }),
      );

      final text = await service.transcribeFile(source.path, config: config);

      expect(text, 'converted ok');
      expect(converterInput, source.path);
      expect(dataUrl, 'data:audio/wav;base64,CQg=');
    });

    test('throws when unsupported file conversion fails', () async {
      final tempDir = await Directory.systemTemp.createTemp('mimo_asr_');
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });
      final source = File('${tempDir.path}/voice.m4a');
      await source.writeAsBytes([1, 2, 3]);
      final service = XiaomiMimoAsrService(
        audioConverter: (_) async => null,
        httpClient: MockClient((request) async {
          fail('Failed conversion should not be posted');
        }),
      );

      expect(
        () => service.transcribeFile(source.path, config: config),
        throwsA(isA<XiaomiMimoAsrException>()),
      );
    });
  });
}
