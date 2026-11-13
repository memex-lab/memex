/// A short description of how a voice note was spoken.
///
/// [moodCode] and [energyCode] are stable keys. The visible sentence is built
/// from localized labels. [summaryOverride] is a sentence already written by
/// the configured model, in the language of the speech.
class VocalTone {
  const VocalTone({
    required this.moodCode,
    required this.energyCode,
    required this.source,
    required this.confidence,
    this.summaryOverride,
  });

  final String moodCode;
  final String energyCode;

  /// `on_device` or `configured_model`.
  final String source;

  /// `model` for an on device tag, or `low` / `medium` / `high` / `unspecified`.
  final String confidence;
  final String? summaryOverride;

  String format({
    required String moodLabel,
    required String energyLabel,
    required String Function(String mood, String energy) line,
  }) {
    final override = summaryOverride?.trim();
    if (override != null && override.isNotEmpty) return override;
    return line(moodLabel, energyLabel);
  }
}

/// Result fields sherpa returns beside the transcript.
class LocalRecognition {
  const LocalRecognition({
    this.text,
    this.emotion = '',
    this.event = '',
    this.lang = '',
  });

  final String? text;
  final String emotion;
  final String event;
  final String lang;
}

String normalizeSenseVoiceLabel(String raw) {
  var value = raw.trim();
  if (value.startsWith('<|') && value.endsWith('|>') && value.length > 4) {
    value = value.substring(2, value.length - 2);
  }
  return value.toUpperCase().replaceAll(RegExp(r'[^A-Z_]'), '');
}

/// SenseVoice emotion tags the sherpa result exposes.
/// Unknown and empty tags produce no tone, so the draft stays unchanged.
VocalTone? vocalToneFromSenseVoice({
  required String emotion,
  required String event,
}) {
  final label = normalizeSenseVoiceLabel(emotion);
  final eventLabel = normalizeSenseVoiceLabel(event);
  final mapped = switch (label) {
    'HAPPY' => ('happy', 'high'),
    'SAD' => ('sad', 'low'),
    'ANGRY' => ('angry', 'high'),
    'NEUTRAL' => ('calm', 'steady'),
    'FEARFUL' => ('tense', 'high'),
    'DISGUSTED' => ('displeased', 'steady'),
    'SURPRISED' => ('surprised', 'high'),
    _ => null,
  };
  if (mapped == null) {
    if (eventLabel == 'LAUGHTER') {
      return const VocalTone(
        moodCode: 'laughter',
        energyCode: 'high',
        source: 'on_device',
        confidence: 'model',
      );
    }
    if (eventLabel == 'CRY') {
      return const VocalTone(
        moodCode: 'crying',
        energyCode: 'low',
        source: 'on_device',
        confidence: 'model',
      );
    }
    return null;
  }
  return VocalTone(
    moodCode: mapped.$1,
    energyCode: mapped.$2,
    source: 'on_device',
    confidence: 'model',
  );
}

const vocalToneCloudPrompt = '''Describe only the vocal delivery in this audio.
Return one block:
<voice_tone>
<mood>one word</mood>
<energy>low, steady, or high</energy>
<confidence>low, medium, or high</confidence>
<summary>one short neutral sentence in the language of the speech</summary>
</voice_tone>
Rules:
- Describe pace, energy, and apparent mood. Do not repeat the words that were said.
- If the delivery is unclear, set confidence to low and keep the summary cautious.
- Do not add text outside the voice_tone block.''';

VocalTone? parseCloudVocalTone(String? raw) {
  final text = raw?.trim();
  if (text == null || text.isEmpty) return null;
  final block = RegExp(
    r'<voice_tone>([\s\S]*?)</voice_tone>',
    caseSensitive: false,
  ).firstMatch(text);
  if (block == null) return null;
  final body = block.group(1) ?? '';
  String? tag(String name) {
    final match = RegExp(
      '<$name>([\\s\\S]*?)</$name>',
      caseSensitive: false,
    ).firstMatch(body);
    final value = match?.group(1)?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  final mood = tag('mood');
  if (mood == null || mood.length > 40) return null;
  final energy = _energyCode(tag('energy'));
  final confidence = _confidenceCode(tag('confidence'));
  final summary = tag('summary');
  final override = summary == null
      ? null
      : (summary.length > 240 ? summary.substring(0, 240).trim() : summary);
  return VocalTone(
    moodCode: mood.toLowerCase(),
    energyCode: energy,
    source: 'configured_model',
    confidence: confidence,
    summaryOverride: override,
  );
}

String _energyCode(String? raw) {
  switch (raw?.trim().toLowerCase()) {
    case 'low':
    case 'steady':
    case 'high':
      return raw!.trim().toLowerCase();
    default:
      return 'steady';
  }
}

String _confidenceCode(String? raw) {
  switch (raw?.trim().toLowerCase()) {
    case 'low':
    case 'medium':
    case 'high':
      return raw!.trim().toLowerCase();
    default:
      return 'unspecified';
  }
}

/// Adds a tone line only when [enabled] is true.
///
/// An on device tag wins, and the cloud callback is not used. A cloud failure
/// keeps the transcript and does not invent a mood.
Future<String?> applyVocalTone({
  required bool enabled,
  required String? transcript,
  VocalTone? localTone,
  required Future<VocalTone?> Function() describeWithCloud,
  required String Function(VocalTone tone) format,
}) async {
  final trimmed = transcript?.trim();
  if (!enabled || trimmed == null || trimmed.isEmpty) return transcript;
  VocalTone? tone = localTone;
  if (tone == null) {
    try {
      tone = await describeWithCloud();
    } catch (_) {
      return trimmed;
    }
  }
  if (tone == null) return trimmed;
  final override = tone.summaryOverride?.trim();
  final line = (override != null && override.isNotEmpty)
      ? override
      : format(tone).trim();
  if (line.isEmpty) return trimmed;
  return '$trimmed\n\n$line';
}
