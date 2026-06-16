import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/speech_recognition_config.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('UserStorage speech recognition config', () {
    test('defaults to local provider', () async {
      final config = await UserStorage.getSpeechRecognitionConfig();

      expect(config.provider, SpeechRecognitionProvider.local);
      expect(config.tencentCloudEngineType, '16k_zh_en');
      expect(await UserStorage.getUseLocalSpeechToText(), isTrue);
    });

    test('migrates legacy false use_local_speech_to_text to Tencent Cloud',
        () async {
      SharedPreferences.setMockInitialValues({
        'use_local_speech_to_text': false,
      });

      final config = await UserStorage.getSpeechRecognitionConfig();

      expect(config.provider, SpeechRecognitionProvider.tencentCloud);
      expect(await UserStorage.getUseLocalSpeechToText(), isFalse);
    });

    test('saving config also preserves legacy bool semantics', () async {
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

      final config = await UserStorage.getSpeechRecognitionConfig();
      final prefs = await SharedPreferences.getInstance();

      expect(config.provider, SpeechRecognitionProvider.tencentCloud);
      expect(config.tencentCloudAppId, '1250000000');
      expect(await UserStorage.getUseLocalSpeechToText(), isFalse);
      expect(prefs.getBool('use_local_speech_to_text'), isFalse);
    });

    test('saving Xiaomi MiMo config preserves ASR settings', () async {
      await UserStorage.saveSpeechRecognitionConfig(
        const SpeechRecognitionConfig(
          provider: SpeechRecognitionProvider.xiaomiMimo,
          xiaomiMimo: XiaomiMimoAsrConfig(
            llmConfigKey: 'mimo-main',
            apiKey: 'manual-key',
            baseUrl: 'https://mimo.example/v1',
            model: 'mimo-v2.5-asr',
            language: 'zh',
          ),
        ),
      );

      final config = await UserStorage.getSpeechRecognitionConfig();
      final prefs = await SharedPreferences.getInstance();

      expect(config.provider, SpeechRecognitionProvider.xiaomiMimo);
      expect(config.xiaomiMimo.llmConfigKey, 'mimo-main');
      expect(config.xiaomiMimo.apiKey, 'manual-key');
      expect(config.xiaomiMimo.baseUrl, 'https://mimo.example/v1');
      expect(config.xiaomiMimo.language, 'zh');
      expect(await UserStorage.getUseLocalSpeechToText(), isFalse);
      expect(prefs.getBool('use_local_speech_to_text'), isFalse);
    });

    test('loads Xiaomi MiMo snake case provider and normalizes options',
        () async {
      SharedPreferences.setMockInitialValues({
        'speech_recognition_config':
            '{"provider":"xiaomi_mimo","xiaomiMimo":{"apiKey":"mimo-key","baseUrl":"https://token-plan-sgp.xiaomimimo.com/anthropic/","model":"unknown","language":"ja"}}',
      });

      final config = await UserStorage.getSpeechRecognitionConfig();

      expect(config.provider, SpeechRecognitionProvider.xiaomiMimo);
      expect(config.xiaomiMimo.apiKey, 'mimo-key');
      expect(
        config.xiaomiMimo.baseUrl,
        'https://token-plan-sgp.xiaomimimo.com/anthropic',
      );
      expect(config.xiaomiMimo.model, XiaomiMimoAsrConfig.defaultModel);
      expect(config.xiaomiMimo.language, XiaomiMimoAsrConfig.defaultLanguage);
      expect(config.hasXiaomiMimoCredentials, isTrue);
    });

    test('legacy setter switches provider while keeping Tencent settings',
        () async {
      await UserStorage.saveSpeechRecognitionConfig(
        const SpeechRecognitionConfig(
          provider: SpeechRecognitionProvider.tencentCloud,
          tencentCloud: TencentCloudAsrConfig(
            appId: '1250000000',
            secretId: 'sid',
            secretKey: 'skey',
          ),
          xiaomiMimo: XiaomiMimoAsrConfig(
            llmConfigKey: 'mimo-main',
            language: 'en',
          ),
        ),
      );

      await UserStorage.setUseLocalSpeechToText(true);
      var config = await UserStorage.getSpeechRecognitionConfig();
      expect(config.provider, SpeechRecognitionProvider.local);
      expect(config.tencentCloudAppId, '1250000000');

      await UserStorage.setUseLocalSpeechToText(false);
      config = await UserStorage.getSpeechRecognitionConfig();
      expect(config.provider, SpeechRecognitionProvider.tencentCloud);
      expect(config.tencentCloudSecretId, 'sid');
      expect(config.xiaomiMimo.llmConfigKey, 'mimo-main');
      expect(config.xiaomiMimo.language, 'en');
    });
  });
}
