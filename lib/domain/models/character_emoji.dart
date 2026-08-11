enum CharacterEmoji {
  slightSmile(
    agentId: 'slight_smile',
    glyph: '🙂',
    assetFileName: 'slightly_smiling_face_3d.png',
  ),
  warmSmile(
    agentId: 'warm_smile',
    glyph: '😊',
    assetFileName: 'smiling_face_with_smiling_eyes_3d.png',
  ),
  affection(
    agentId: 'affection',
    glyph: '🥰',
    assetFileName: 'smiling_face_with_hearts_3d.png',
  ),
  laugh(
    agentId: 'laugh',
    glyph: '😂',
    assetFileName: 'face_with_tears_of_joy_3d.png',
  ),
  kiss(
    agentId: 'kiss',
    glyph: '😘',
    assetFileName: 'face_blowing_a_kiss_3d.png',
  ),
  wink(
    agentId: 'wink',
    glyph: '😉',
    assetFileName: 'winking_face_3d.png',
  ),
  hug(
    agentId: 'hug',
    glyph: '🤗',
    assetFileName: 'hugging_face_3d.png',
  ),
  pleading(
    agentId: 'pleading',
    glyph: '🥺',
    assetFileName: 'pleading_face_3d.png',
  ),
  thinking(
    agentId: 'thinking',
    glyph: '🤔',
    assetFileName: 'thinking_face_3d.png',
  ),
  pensive(
    agentId: 'pensive',
    glyph: '😔',
    assetFileName: 'pensive_face_3d.png',
  ),
  relieved(
    agentId: 'relieved',
    glyph: '😌',
    assetFileName: 'relieved_face_3d.png',
  ),
  sleeping(
    agentId: 'sleeping',
    glyph: '😴',
    assetFileName: 'sleeping_face_3d.png',
  ),
  holdingBackTears(
    agentId: 'holding_back_tears',
    glyph: '🥹',
    assetFileName: 'face_holding_back_tears_3d.png',
  ),
  melting(
    agentId: 'melting',
    glyph: '🫠',
    assetFileName: 'melting_face_3d.png',
  ),
  crying(
    agentId: 'crying',
    glyph: '😢',
    assetFileName: 'crying_face_3d.png',
  ),
  sobbing(
    agentId: 'sobbing',
    glyph: '😭',
    assetFileName: 'loudly_crying_face_3d.png',
  ),
  flushed(
    agentId: 'flushed',
    glyph: '😳',
    assetFileName: 'flushed_face_3d.png',
  ),
  unamused(
    agentId: 'unamused',
    glyph: '😒',
    assetFileName: 'unamused_face_3d.png',
  ),
  quiet(
    agentId: 'quiet',
    glyph: '🤫',
    assetFileName: 'shushing_face_3d.png',
  ),
  yawning(
    agentId: 'yawning',
    glyph: '🥱',
    assetFileName: 'yawning_face_3d.png',
  ),
  beaming(
    agentId: 'beaming',
    glyph: '😁',
    assetFileName: 'beaming_face_with_smiling_eyes_3d.png',
  ),
  happy(
    agentId: 'happy',
    glyph: '😄',
    assetFileName: 'grinning_face_with_smiling_eyes_3d.png',
  ),
  giggle(
    agentId: 'giggle',
    glyph: '🤭',
    assetFileName: 'face_with_hand_over_mouth_3d.png',
  ),
  shy(
    agentId: 'shy',
    glyph: '🙈',
    assetFileName: 'see-no-evil_monkey_3d.png',
  ),
  heart(
    agentId: 'heart',
    glyph: '❤️',
    assetFileName: 'red_heart_3d.png',
  ),
  twoHearts(
    agentId: 'two_hearts',
    glyph: '💕',
    assetFileName: 'two_hearts_3d.png',
  ),
  sparklingHeart(
    agentId: 'sparkling_heart',
    glyph: '💖',
    assetFileName: 'sparkling_heart_3d.png',
  ),
  sparkles(
    agentId: 'sparkles',
    glyph: '✨',
    assetFileName: 'sparkles_3d.png',
  ),
  moon(
    agentId: 'moon',
    glyph: '🌙',
    assetFileName: 'crescent_moon_3d.png',
  ),
  sun(
    agentId: 'sun',
    glyph: '🌞',
    assetFileName: 'sun_with_face_3d.png',
  ),
  celebrate(
    agentId: 'celebrate',
    glyph: '🎉',
    assetFileName: 'party_popper_3d.png',
  ),
  thumbsUp(
    agentId: 'thumbs_up',
    glyph: '👍',
    assetFileName: 'thumbs_up_3d_default.png',
  ),
  applause(
    agentId: 'applause',
    glyph: '👏',
    assetFileName: 'clapping_hands_3d_default.png',
  ),
  eyes(
    agentId: 'eyes',
    glyph: '👀',
    assetFileName: 'eyes_3d.png',
  ),
  fire(
    agentId: 'fire',
    glyph: '🔥',
    assetFileName: 'fire_3d.png',
  ),
  sunflower(
    agentId: 'sunflower',
    glyph: '🌻',
    assetFileName: 'sunflower_3d.png',
  ),
  wave(
    agentId: 'wave',
    glyph: '👋',
    assetFileName: 'waving_hand_3d_default.png',
  );

  const CharacterEmoji({
    required this.agentId,
    required this.glyph,
    required this.assetFileName,
  });

  final String agentId;
  final String glyph;
  final String assetFileName;

  static final List<String> agentIds =
      values.map((emoji) => emoji.agentId).toList(growable: false);

  static final Map<String, CharacterEmoji> _byAgentId = {
    for (final emoji in values) emoji.agentId: emoji,
  };

  static CharacterEmoji? fromAgentId(String value) {
    return _byAgentId[value.trim()];
  }

  static CharacterEmoji? fromGlyph(String value) {
    final normalized = _withoutPresentationSelectors(value.trim());
    for (final emoji in values) {
      if (_withoutPresentationSelectors(emoji.glyph) == normalized) {
        return emoji;
      }
    }
    return null;
  }

  static String _withoutPresentationSelectors(String value) {
    return value.replaceAll('\uFE0E', '').replaceAll('\uFE0F', '');
  }
}
