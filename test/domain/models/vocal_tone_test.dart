import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/vocal_tone.dart';

void main() {
  String format(VocalTone tone) => '${tone.moodCode}/${tone.energyCode}';

  test('SenseVoice angry tag becomes a tone and unknown tags do not', () {
    final angry = vocalToneFromSenseVoice(emotion: '<|ANGRY|>', event: '');
    expect(angry?.moodCode, 'angry');
    expect(angry?.energyCode, 'high');
    expect(angry?.source, 'on_device');

    expect(
      vocalToneFromSenseVoice(emotion: 'EMO_UNKNOWN', event: 'Speech'),
      isNull,
    );
    expect(vocalToneFromSenseVoice(emotion: '', event: ''), isNull);
  });

  test('laughter and crying events count when emotion is missing', () {
    expect(
      vocalToneFromSenseVoice(emotion: '', event: 'Laughter')?.moodCode,
      'laughter',
    );
    expect(
      vocalToneFromSenseVoice(emotion: '', event: '<|Cry|>')?.moodCode,
      'crying',
    );
  });

  test('a disabled setting never asks the cloud model', () async {
    var calls = 0;
    final text = await applyVocalTone(
      enabled: false,
      transcript: 'I went to the garage.',
      describeWithCloud: () async {
        calls += 1;
        return null;
      },
      format: format,
    );
    expect(calls, 0);
    expect(text, 'I went to the garage.');
  });

  test('an on device tone is kept and the cloud is not called', () async {
    var calls = 0;
    final text = await applyVocalTone(
      enabled: true,
      transcript: 'I went to the garage.',
      localTone: vocalToneFromSenseVoice(emotion: 'ANGRY', event: ''),
      describeWithCloud: () async {
        calls += 1;
        return null;
      },
      format: format,
    );
    expect(calls, 0);
    expect(text, 'I went to the garage.\n\nangry/high');
  });

  test('a failed cloud description leaves the transcript alone', () async {
    final text = await applyVocalTone(
      enabled: true,
      transcript: 'I went to the garage.',
      describeWithCloud: () async {
        throw Exception('offline');
      },
      format: format,
    );
    expect(text, 'I went to the garage.');
  });

  test('a cloud tone block is parsed and appended', () async {
    final parsed = parseCloudVocalTone('''
Note
<voice_tone>
<mood>tired</mood>
<energy>low</energy>
<confidence>medium</confidence>
<summary>Spoken slowly, with low energy.</summary>
</voice_tone>
''');
    expect(parsed?.moodCode, 'tired');
    expect(parsed?.energyCode, 'low');
    expect(parsed?.confidence, 'medium');
    expect(parsed?.source, 'configured_model');

    final text = await applyVocalTone(
      enabled: true,
      transcript: 'I went to the garage.',
      describeWithCloud: () async => parsed,
      format: format,
    );
    expect(text, 'I went to the garage.\n\nSpoken slowly, with low energy.');
  });

  test('a cloud reply without a tone block is ignored', () {
    expect(parseCloudVocalTone('the speaker sounds fine'), isNull);
  });
}
