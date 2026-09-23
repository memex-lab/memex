import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/l10n/app_localizations.dart';

void main() {
  test('en local-STT description describes cloud transcription, not raw attach',
      () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(l10n.useLocalSpeechToTextDesc, contains('transcribed by your configured cloud model'));
    expect(l10n.useLocalSpeechToTextDesc, isNot(contains('original audio is sent directly')));
  });

  test('zh local-STT description describes cloud transcription, not raw attach',
      () {
    final l10n = lookupAppLocalizations(const Locale('zh'));
    expect(l10n.useLocalSpeechToTextDesc, contains('云端模型进行转录'));
    expect(l10n.useLocalSpeechToTextDesc, isNot(contains('原始音频发送给模型')));
  });
}
