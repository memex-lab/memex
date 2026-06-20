import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/local_speech_model.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists selected local speech model', () async {
    await UserStorage.setLocalSpeechModel(LocalSpeechModelId.whisperSmall);
    expect(
      await UserStorage.getLocalSpeechModel(),
      LocalSpeechModelId.whisperSmall,
    );
  });

  test('resetLocalSpeechModel clears preference', () async {
    await UserStorage.setLocalSpeechModel(LocalSpeechModelId.senseVoice);
    await UserStorage.resetLocalSpeechModel();
    expect(
      await UserStorage.getLocalSpeechModel(),
      LocalSpeechModelProfile.defaultForFlavor(),
    );
  });
}
