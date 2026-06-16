import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:memex/data/services/tencent_cloud_asr_service.dart';
import 'package:memex/domain/models/speech_recognition_config.dart';

void main() {
  group('TencentCloudAsrService signing', () {
    test('builds canonical string in sorted query order and signs it', () {
      final params = TencentCloudAsrService.flashParams(
        config: const TencentCloudAsrConfig(
          appId: '1250000000',
          secretId: 'AKIDEXAMPLE',
          secretKey: 'SECRETEXAMPLE',
        ),
        voiceFormat: 'wav',
        timestamp: 1700000000,
      );

      expect(
        TencentCloudAsrService.flashSignature(
          appId: '1250000000',
          secretKey: 'SECRETEXAMPLE',
          params: params,
        ),
        'AONW85EntyVikqWEZwnx4HevzW0=',
      );
    });
  });

  group('TencentCloudAsrService', () {
    test('parses and joins flash_result channel text', () {
      final text = TencentCloudAsrService.parseFlashTranscript(jsonEncode({
        'code': 0,
        'flash_result': [
          {'channel_id': 0, 'text': '第一段。'},
          {'channel_id': 1, 'text': 'Second part.'},
        ],
      }));

      expect(text, '第一段。\nSecond part.');
    });

    test('falls back to sentence text when channel text is missing', () {
      final text = TencentCloudAsrService.parseFlashTranscript(jsonEncode({
        'code': 0,
        'flash_result': [
          {
            'channel_id': 0,
            'sentence_list': [
              {'text': '你好。'},
              {'text': 'Memex。'},
            ],
          },
        ],
      }));

      expect(text, '你好。\nMemex。');
    });

    test('posts bytes with signed flash recognition request', () async {
      late http.Request captured;
      final service = TencentCloudAsrService(
        now: () => DateTime.fromMillisecondsSinceEpoch(1700000000000),
        httpClient: MockClient((request) async {
          captured = request;
          return http.Response.bytes(
            utf8.encode(jsonEncode({
              'request_id': 'req-1',
              'code': 0,
              'message': '',
              'audio_duration': 520,
              'flash_result': [
                {'text': '腾讯云智能语音欢迎您。', 'channel_id': 0},
              ],
            })),
            200,
          );
        }),
      );

      final result = await service.transcribeBytes(
        [1, 2, 3],
        config: const TencentCloudAsrConfig(
          appId: '1250000000',
          secretId: 'AKIDEXAMPLE',
          secretKey: 'SECRETEXAMPLE',
        ),
        voiceFormat: 'wav',
      );

      expect(result, '腾讯云智能语音欢迎您。');
      expect(captured.method, 'POST');
      expect(captured.url.host, 'asr.cloud.tencent.com');
      expect(captured.url.path, '/asr/flash/v1/1250000000');
      expect(captured.url.queryParameters['engine_type'], '16k_zh_en');
      expect(captured.url.queryParameters['voice_format'], 'wav');
      expect(captured.url.queryParameters['secretid'], 'AKIDEXAMPLE');
      expect(
        captured.headers['Authorization'] ?? captured.headers['authorization'],
        'AONW85EntyVikqWEZwnx4HevzW0=',
      );
      expect(
        captured.headers['Content-Type'] ?? captured.headers['content-type'],
        'application/octet-stream',
      );
      expect(captured.bodyBytes, [1, 2, 3]);
    });

    test('throws TencentCloudAsrException for non-zero API code', () {
      expect(
        () => TencentCloudAsrService.parseFlashTranscript(jsonEncode({
          'request_id': 'req-failed',
          'code': 4002,
          'message': '鉴权失败。',
        })),
        throwsA(
          isA<TencentCloudAsrException>()
              .having((e) => e.code, 'code', 4002)
              .having((e) => e.requestId, 'requestId', 'req-failed'),
        ),
      );
    });

    test('maps supported file extensions to Tencent voice_format', () {
      expect(TencentCloudAsrService.voiceFormatForPath('/tmp/a.wav'), 'wav');
      expect(TencentCloudAsrService.voiceFormatForPath('/tmp/a.m4a'), 'm4a');
      expect(
          TencentCloudAsrService.voiceFormatForPath('/tmp/a.ogg'), 'ogg-opus');
    });
  });
}
