import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:memex/data/services/speech_transcription_service.dart';
import 'package:memex/data/services/tencent_cloud_asr_service.dart';
import 'package:memex/data/services/xiaomi_mimo_asr_service.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/domain/models/speech_recognition_config.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('memex_speech_asr_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('Tencent Cloud provider supports streaming when configured', () async {
    await UserStorage.saveSpeechRecognitionConfig(
      const SpeechRecognitionConfig(
        provider: SpeechRecognitionProvider.tencentCloud,
        tencentCloud: TencentCloudAsrConfig(
          appId: '1250000000',
          secretId: 'sid',
          secretKey: 'skey',
        ),
      ),
    );

    expect(
      await SpeechTranscriptionService.instance
          .supportsStreamingTranscription(),
      isTrue,
    );
    expect(
      await SpeechTranscriptionService.instance.createRealtimeTranscriber(
        onTextChanged: (_) {},
      ),
      isNotNull,
    );
  });

  test('Xiaomi MiMo provider does not advertise live streaming', () async {
    await UserStorage.saveSpeechRecognitionConfig(
      const SpeechRecognitionConfig(
        provider: SpeechRecognitionProvider.xiaomiMimo,
        xiaomiMimo: XiaomiMimoAsrConfig(apiKey: 'mimo-key'),
      ),
    );

    final speechService = SpeechTranscriptionService(
      xiaomiMimoAsrService: XiaomiMimoAsrService(
        httpClient: MockClient((_) async => http.Response('{}', 200)),
      ),
    );

    expect(await speechService.supportsStreamingTranscription(), isFalse);
    expect(
      await speechService.createRealtimeTranscriber(onTextChanged: (_) {}),
      isNull,
    );
  });

  test('routes safe files to Tencent Cloud ASR when provider is external',
      () async {
    await UserStorage.saveSpeechRecognitionConfig(
      const SpeechRecognitionConfig(
        provider: SpeechRecognitionProvider.tencentCloud,
        tencentCloud: TencentCloudAsrConfig(
          appId: '1250000000',
          secretId: 'AKIDEXAMPLE',
          secretKey: 'SECRETEXAMPLE',
        ),
      ),
    );
    final audio = File('${tempDir.path}/recording_60.wav');
    await audio.writeAsBytes([0, 1, 2, 3]);

    late http.Request captured;
    final speechService = SpeechTranscriptionService(
      tencentCloudAsrService: TencentCloudAsrService(
        now: () => DateTime.fromMillisecondsSinceEpoch(1700000000000),
        httpClient: MockClient((request) async {
          captured = request;
          return http.Response.bytes(
            utf8.encode(jsonEncode({
              'request_id': 'req-1',
              'code': 0,
              'message': '',
              'audio_duration': 60000,
              'flash_result': [
                {'text': '录音结束后的文字。', 'channel_id': 0},
              ],
            })),
            200,
          );
        }),
      ),
    );

    final result = await speechService.transcribeFileWithMetadata(audio.path);

    expect(result.text, '录音结束后的文字。');
    expect(result.usage, isNull);
    expect(result.model, 'tencent-cloud-asr/16k_zh_en');
    expect(captured.url.path, '/asr/flash/v1/1250000000');
    expect(captured.url.queryParameters['voice_format'], 'wav');
  });

  test('routes safe files to Xiaomi MiMo ASR using linked model config',
      () async {
    await UserStorage.saveLLMConfigs(const [
      LLMConfig(
        key: 'mimo-main',
        type: LLMConfig.typeMimo,
        modelId: 'mimo-v2.5',
        apiKey: 'linked-mimo-key',
        baseUrl: 'https://api.xiaomimimo.com/anthropic',
      ),
    ]);
    await UserStorage.saveSpeechRecognitionConfig(
      const SpeechRecognitionConfig(
        provider: SpeechRecognitionProvider.xiaomiMimo,
        xiaomiMimo: XiaomiMimoAsrConfig(
          llmConfigKey: 'mimo-main',
          language: 'zh',
        ),
      ),
    );
    final audio = File('${tempDir.path}/mimo_recording_60.wav');
    await audio.writeAsBytes([0, 1, 2, 3]);

    late http.Request captured;
    final speechService = SpeechTranscriptionService(
      xiaomiMimoAsrService: XiaomiMimoAsrService(
        httpClient: MockClient((request) async {
          captured = request;
          return http.Response.bytes(
            utf8.encode(jsonEncode({
              'choices': [
                {
                  'message': {'content': '小米识别完成。'},
                },
              ],
            })),
            200,
          );
        }),
      ),
    );

    final result = await speechService.transcribeFileWithMetadata(audio.path);

    expect(result.text, '小米识别完成。');
    expect(result.usage, isNull);
    expect(result.model, 'xiaomi-mimo-asr/mimo-v2.5-asr');
    expect(captured.url.toString(),
        'https://api.xiaomimimo.com/v1/chat/completions');
    expect(captured.headers['api-key'], 'linked-mimo-key');
    final body = jsonDecode(captured.body) as Map<String, dynamic>;
    expect(body['asr_options'], {'language': 'zh'});
  });

  test('linked Xiaomi MiMo token-plan anthropic URL maps to ASR v1 endpoint',
      () async {
    await UserStorage.saveLLMConfigs(const [
      LLMConfig(
        key: 'mimo-token-plan',
        type: LLMConfig.typeMimo,
        modelId: 'mimo-v2.5',
        apiKey: 'linked-token-plan-key',
        baseUrl: 'https://token-plan-sgp.xiaomimimo.com/anthropic',
      ),
    ]);
    await UserStorage.saveSpeechRecognitionConfig(
      const SpeechRecognitionConfig(
        provider: SpeechRecognitionProvider.xiaomiMimo,
        xiaomiMimo: XiaomiMimoAsrConfig(llmConfigKey: 'mimo-token-plan'),
      ),
    );
    final audio = File('${tempDir.path}/token_plan_recording_30.wav');
    await audio.writeAsBytes([0, 1, 2, 3]);

    late http.Request captured;
    final speechService = SpeechTranscriptionService(
      xiaomiMimoAsrService: XiaomiMimoAsrService(
        httpClient: MockClient((request) async {
          captured = request;
          return http.Response.bytes(
            utf8.encode(jsonEncode({
              'choices': [
                {
                  'message': {'content': 'token plan ok'},
                },
              ],
            })),
            200,
          );
        }),
      ),
    );

    final result = await speechService.transcribeFileWithMetadata(audio.path);

    expect(result.text, 'token plan ok');
    expect(captured.url.toString(),
        'https://token-plan-sgp.xiaomimimo.com/v1/chat/completions');
    expect(captured.headers['api-key'], 'linked-token-plan-key');
  });

  test('routes Xiaomi MiMo samples with manual credentials', () async {
    await UserStorage.saveSpeechRecognitionConfig(
      const SpeechRecognitionConfig(
        provider: SpeechRecognitionProvider.xiaomiMimo,
        xiaomiMimo: XiaomiMimoAsrConfig(
          apiKey: 'manual-mimo-key',
          baseUrl: 'https://mimo.example/v1',
          language: 'en',
        ),
      ),
    );

    late http.Request captured;
    final speechService = SpeechTranscriptionService(
      xiaomiMimoAsrService: XiaomiMimoAsrService(
        httpClient: MockClient((request) async {
          captured = request;
          return http.Response.bytes(
            utf8.encode(jsonEncode({
              'choices': [
                {
                  'message': {'content': 'sample text'},
                },
              ],
            })),
            200,
          );
        }),
      ),
    );

    final result = await speechService.transcribeSamplesWithMetadata(
      Float32List.fromList([0, 0.5, -0.5]),
    );

    expect(result.text, 'sample text');
    expect(result.model, 'xiaomi-mimo-asr/mimo-v2.5-asr');
    expect(captured.url.toString(), 'https://mimo.example/v1/chat/completions');
    expect(captured.headers['api-key'], 'manual-mimo-key');
    final body = jsonDecode(captured.body) as Map<String, dynamic>;
    expect(body['asr_options'], {'language': 'en'});
    final messages = body['messages'] as List<dynamic>;
    final content =
        (messages.single as Map<String, dynamic>)['content'] as List<dynamic>;
    final audio = content.single as Map<String, dynamic>;
    expect(
      (audio['input_audio'] as Map<String, dynamic>)['data'],
      startsWith('data:audio/wav;base64,'),
    );
  });

  test('ignores linked Xiaomi MiMo config when provider type is wrong',
      () async {
    await UserStorage.saveLLMConfigs(const [
      LLMConfig(
        key: 'not-mimo',
        type: LLMConfig.typeChatCompletion,
        modelId: 'gpt-5.4-mini',
        apiKey: 'wrong-key',
        baseUrl: 'https://api.example/v1',
      ),
    ]);
    await UserStorage.saveSpeechRecognitionConfig(
      const SpeechRecognitionConfig(
        provider: SpeechRecognitionProvider.xiaomiMimo,
        xiaomiMimo: XiaomiMimoAsrConfig(llmConfigKey: 'not-mimo'),
      ),
    );

    final result = await SpeechTranscriptionService(
      xiaomiMimoAsrService: XiaomiMimoAsrService(
        httpClient: MockClient((_) async {
          fail('Non-MiMo linked config should not be used for ASR');
        }),
      ),
    ).transcribeSamplesWithMetadata(Float32List.fromList([0.1]));

    expect(result.text, isNull);
    expect(result.model, 'xiaomi-mimo-asr-unconfigured');
  });

  test('returns unconfigured result when Xiaomi MiMo credentials are missing',
      () async {
    await UserStorage.saveSpeechRecognitionConfig(
      const SpeechRecognitionConfig(
        provider: SpeechRecognitionProvider.xiaomiMimo,
      ),
    );

    final result = await SpeechTranscriptionService(
      xiaomiMimoAsrService: XiaomiMimoAsrService(
        httpClient: MockClient((_) async {
          fail('MiMo ASR should not be called without credentials');
        }),
      ),
    ).transcribeSamplesWithMetadata(Float32List.fromList([0.1, 0.2]));

    expect(result.text, isNull);
    expect(result.model, 'xiaomi-mimo-asr-unconfigured');
  });

  test('Tencent Cloud flash transcript parser joins channel text', () {
    final transcript = TencentCloudAsrService.parseFlashTranscript(
      jsonEncode({
        'code': 0,
        'message': '',
        'flash_result': [
          {'text': '第一段。', 'channel_id': 0},
          {'text': '第二段。', 'channel_id': 1},
        ],
      }),
    );

    expect(transcript, '第一段。\n第二段。');
  });

  test('Tencent Cloud flash request signs sorted params', () {
    const config = TencentCloudAsrConfig(
      appId: '1250000000',
      secretId: 'AKIDEXAMPLE',
      secretKey: 'SECRETEXAMPLE',
      engineType: '16k_zh',
    );
    final params = TencentCloudAsrService.flashParams(
      config: config,
      voiceFormat: 'wav',
      timestamp: 1700000000,
    );
    final uri = TencentCloudAsrService.flashUri(
      appId: config.appId,
      params: params,
    );
    final signature = TencentCloudAsrService.flashSignature(
      appId: config.appId,
      secretKey: config.secretKey,
      params: params,
    );

    expect(uri.path, '/asr/flash/v1/1250000000');
    expect(uri.query, contains('engine_type=16k_zh'));
    expect(uri.query.indexOf('convert_num_mode=1'),
        lessThan(uri.query.indexOf('engine_type=16k_zh')));
    expect(signature, isNotEmpty);
    expect(signature, isNot(contains(config.secretKey)));
  });

  test('Tencent Cloud realtime result parser marks final slices stable', () {
    final event = TencentCloudRealtimeTranscriber.parseRealtimeResult({
      'code': 0,
      'result': {
        'slice_type': 2,
        'index': 3,
        'voice_text_str': '实时预览',
      },
    });

    expect(event?.index, 3);
    expect(event?.text, '实时预览');
    expect(event?.isStable, isTrue);
  });
}
