import 'dart:math';
import 'package:logging/logging.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/utils/logger.dart';

/// Selects the most appropriate character to comment on a given input,
/// based on content-persona affinity rather than random selection.
///
/// Uses a lightweight keyword-matching approach (no LLM call) so it's
/// fast enough to run in the task handler hot path.
class CharacterSelectionService {
  static final Logger _logger = getLogger('CharacterSelectionService');

  /// Select the best character for the given input content.
  /// Falls back to weighted-random if no clear winner.
  static Future<CharacterModel?> selectCharacter({
    required String userId,
    required String inputContent,
    required String factId,
  }) async {
    final characters =
        await CharacterService.instance.getAllCharacters(userId);
    final enabled = characters.where((c) => c.enabled).toList();

    if (enabled.isEmpty) return null;
    if (enabled.length == 1) return enabled.first;

    // Score each character against the input
    final scores = <String, double>{};
    for (final char in enabled) {
      scores[char.id] = _scoreAffinity(char, inputContent);
    }

    // Find the max score
    final maxScore = scores.values.reduce(max);

    // If there's a clear winner (score > 0 and at least 2x the average),
    // pick that character. Otherwise, do weighted-random.
    final avgScore =
        scores.values.reduce((a, b) => a + b) / scores.values.length;

    if (maxScore > 0 && maxScore >= avgScore * 1.5) {
      // Clear affinity match
      final winnerId =
          scores.entries.firstWhere((e) => e.value == maxScore).key;
      final winner = enabled.firstWhere((c) => c.id == winnerId);
      _logger.info(
          'Selected ${winner.name} (score: $maxScore) for fact $factId');
      return winner;
    }

    // Weighted random: higher scores = higher probability, but everyone
    // has a chance. This prevents the same character from always winning.
    return _weightedRandom(enabled, scores, factId);
  }

  /// Score how well a character matches the input content.
  /// Higher = better match. Uses tags + persona keywords.
  static double _scoreAffinity(CharacterModel char, String content) {
    final lower = content.toLowerCase();
    var score = 0.0;

    // 1. Tag matching (tags are the primary signal)
    for (final tag in char.tags) {
      if (lower.contains(tag.toLowerCase())) {
        score += 3.0;
      }
    }

    // 2. Extract interest keywords from persona's pkm_interest_filter section
    final interestKeywords = _extractInterestKeywords(char.persona);
    for (final keyword in interestKeywords) {
      if (lower.contains(keyword.toLowerCase())) {
        score += 2.0;
      }
    }

    // 3. Emotional tone matching
    score += _emotionalAffinity(char, lower);

    return score;
  }

  /// Extract keywords from the PKM Interest Filter section of persona text.
  static List<String> _extractInterestKeywords(String persona) {
    final keywords = <String>[];

    // Look for "PKM Interest Filter" or "Focus on" sections
    final filterMatch = RegExp(
      r'(?:PKM Interest Filter|Focus on)[:\s]*(.*?)(?:\n#|\n\n|$)',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(persona);

    if (filterMatch != null) {
      final filterText = filterMatch.group(1) ?? '';
      // Extract meaningful nouns/phrases
      final words = filterText
          .replaceAll(RegExp(r'[,;.!?()]'), ' ')
          .split(RegExp(r'\s+'))
          .where((w) => w.length > 3) // Skip short words
          .where((w) => !_stopWords.contains(w.toLowerCase()))
          .toList();
      keywords.addAll(words);
    }

    return keywords;
  }

  /// Score emotional affinity between character and content tone.
  static double _emotionalAffinity(CharacterModel char, String lowerContent) {
    final charLower = '${char.name} ${char.tags.join(' ')}'.toLowerCase();
    var score = 0.0;

    // Health/fatigue signals → caring characters
    if (_matchesAny(lowerContent, _healthSignals)) {
      if (_matchesAny(charLower, ['care', 'health', 'warmth', '关心', '健康'])) {
        score += 4.0;
      }
    }

    // Venting/frustration signals → bestie characters
    if (_matchesAny(lowerContent, _ventingSignals)) {
      if (_matchesAny(charLower, ['bestie', 'venting', 'company', '闺蜜', '吐槽'])) {
        score += 4.0;
      }
    }

    // Reflective/philosophical signals → mentor characters
    if (_matchesAny(lowerContent, _reflectiveSignals)) {
      if (_matchesAny(charLower, ['wisdom', 'mentor', 'validation', '导师', '智慧'])) {
        score += 4.0;
      }
    }

    // Emotional/nostalgic signals → poetic characters
    if (_matchesAny(lowerContent, _emotionalSignals)) {
      if (_matchesAny(charLower, ['beauty', 'nostalgia', 'distant', '诗意', '月光'])) {
        score += 4.0;
      }
    }

    return score;
  }

  static bool _matchesAny(String text, List<String> patterns) {
    return patterns.any((p) => text.contains(p));
  }

  /// Weighted random selection. Characters with higher scores are more
  /// likely to be picked, but all enabled characters have a base chance.
  static CharacterModel _weightedRandom(
    List<CharacterModel> characters,
    Map<String, double> scores,
    String factId,
  ) {
    // Give everyone a base weight of 1.0 so no one is excluded
    final weights = characters.map((c) {
      return 1.0 + (scores[c.id] ?? 0.0);
    }).toList();

    final totalWeight = weights.reduce((a, b) => a + b);
    final rng = Random(factId.hashCode);
    var roll = rng.nextDouble() * totalWeight;

    for (var i = 0; i < characters.length; i++) {
      roll -= weights[i];
      if (roll <= 0) {
        _logger.info(
            'Weighted-random selected ${characters[i].name} for fact $factId');
        return characters[i];
      }
    }

    return characters.last;
  }

  // --- Signal word lists ---

  static const _healthSignals = [
    'tired', 'exhausted', 'sick', 'headache', 'sleep', 'insomnia',
    'hospital', 'doctor', 'medicine', 'pain', 'fever', 'cold',
    '累', '困', '生病', '头疼', '失眠', '医院', '吃药', '发烧', '感冒',
    '加班', '熬夜', '疲惫', '身体',
  ];

  static const _ventingSignals = [
    'angry', 'annoyed', 'frustrated', 'hate', 'ugh', 'wtf', 'unfair',
    'stupid', 'ridiculous', 'done with', 'fed up', 'pissed',
    '烦', '气死', '无语', '崩溃', '受不了', '讨厌', '垃圾', '傻逼',
    '操', '吐了', '服了', '离谱',
  ];

  static const _reflectiveSignals = [
    'thinking about', 'wondering', 'realize', 'perspective', 'growth',
    'decision', 'career', 'future', 'meaning', 'purpose', 'goal',
    '思考', '反思', '成长', '方向', '意义', '目标', '选择', '人生',
    '职业', '未来',
  ];

  static const _emotionalSignals = [
    'miss', 'remember', 'nostalgia', 'rain', 'sunset', 'music',
    'lonely', 'quiet', 'dream', 'memory', 'beautiful', 'melancholy',
    '想念', '回忆', '孤独', '安静', '梦', '月亮', '雨', '夕阳',
    '音乐', '美', '忧伤', '感慨',
  ];

  static const _stopWords = {
    'the', 'and', 'for', 'that', 'this', 'with', 'from', 'about',
    'into', 'like', 'just', 'only', 'also', 'more', 'than', 'when',
    'will', 'what', 'which', 'their', 'them', 'they', 'have', 'been',
    'focus', 'ignore', 'unless', 'based', 'user',
  };
}
