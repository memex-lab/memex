import 'package:memex/domain/models/card_model.dart';
import 'package:logging/logging.dart';

final _logger = Logger('RuleBasedCardMatcher');

/// Rule-based card template matcher used when LLM is unavailable.
///
/// Priority order:
///   1. 1 image  → snapshot
///   2. 2+ images → gallery
///   3. URL-only text → link
///   4. Long mixed text → digest
///   5. Everything else → snippet
CardData applyRuleBasedTemplate({
  required CardData card,
  required String combinedText,
  required List<String> imageUrls,
  required String? audioUrl,
}) {
  final pureText = _extractPureText(combinedText);

  final templateId = _matchTemplate(pureText: pureText, imageUrls: imageUrls);

  _logger.info(
    'Rule-based match: templateId=$templateId, images=${imageUrls.length}, textLen=${pureText.length}',
  );

  final data = _buildData(
    templateId: templateId,
    pureText: pureText,
    imageUrls: imageUrls,
  );

  final title = _deriveTitle(pureText);

  return card.copyWith(
    status: 'processing',
    title: title.isEmpty ? null : title,
    uiConfigs: [UiConfig(templateId: templateId, data: data)],
  );
}

String _matchTemplate({
  required String pureText,
  required List<String> imageUrls,
}) {
  if (imageUrls.isNotEmpty) {
    return imageUrls.length == 1 ? 'snapshot' : 'gallery';
  }
  if (_isUrlOnly(pureText)) return 'link';
  if (_looksLikeMixedLongText(pureText)) return 'digest';
  return 'snippet';
}

final _urlRe = RegExp(r'https?://\S+', caseSensitive: false);

bool _isUrlOnly(String t) {
  if (!_urlRe.hasMatch(t)) return false;
  // Allow short surrounding text (e.g. a title alongside the URL)
  return t.replaceAll(_urlRe, '').trim().length < 60;
}

Map<String, dynamic> _buildData({
  required String templateId,
  required String pureText,
  required List<String> imageUrls,
}) {
  switch (templateId) {
    case 'snapshot':
      return {
        'image_url': imageUrls.first,
        if (pureText.isNotEmpty) 'caption': pureText,
      };
    case 'gallery':
      return {
        'image_urls': imageUrls,
        if (pureText.isNotEmpty) 'title': _deriveTitle(pureText),
      };
    case 'link':
      final url = _urlRe.firstMatch(pureText)?.group(0) ?? pureText;
      final rest = pureText.replaceAll(_urlRe, '').trim();
      return {'url': url, if (rest.isNotEmpty) 'title': rest};
    case 'digest':
      return _buildDigestData(pureText);
    case 'snippet':
    default:
      return {'text': pureText.isNotEmpty ? pureText : '…', 'style': 'default'};
  }
}

Map<String, dynamic> _buildDigestData(String pureText) {
  final parts = _splitThoughts(pureText);
  final groups = <String, List<String>>{};

  for (final part in parts) {
    final type = _classifyDigestPart(part);
    groups.putIfAbsent(type, () => []).add(part);
  }

  final sections = <Map<String, dynamic>>[];
  for (final entry in groups.entries) {
    final items = entry.value.take(4).toList();
    if (items.isEmpty) continue;
    sections.add({
      'type': entry.key,
      'title': _digestSectionTitle(entry.key),
      'items': items,
    });
  }

  if (sections.isEmpty && pureText.trim().isNotEmpty) {
    sections.add({
      'type': 'note',
      'title': 'Notes',
      'items': parts.take(4).toList(),
    });
  }

  return {
    'summary': _shorten(pureText.replaceAll(RegExp(r'\s+'), ' '), 140),
    'sections': sections,
  };
}

List<String> _splitThoughts(String text) {
  final byLine = text
      .split(RegExp(r'\n+'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
  if (byLine.length > 1) return byLine.take(12).toList();

  return text
      .split(RegExp(r'[。！？.!?；;]\s*'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .take(12)
      .toList();
}

String _classifyDigestPart(String text) {
  final lower = text.toLowerCase();
  if (RegExp(r'(todo|to do|待办|要做|需要|得|must|need|finish|完成)').hasMatch(lower)) {
    return 'todo';
  }
  if (RegExp(
    r'(meeting|schedule|calendar|会议|日程|约|明天|后天|下周|周[一二三四五六日天]|星期|[0-2]?\d[:：][0-5]\d)',
  ).hasMatch(lower)) {
    return 'schedule';
  }
  if (RegExp(
    r'(mood|feel|feeling|stress|anxious|happy|sad|tired|心情|感觉|焦虑|开心|难受|累|压力)',
  ).hasMatch(lower)) {
    return 'mood';
  }
  if (RegExp(
    r'(project|prd|roadmap|milestone|deadline|review|项目|需求|版本|迭代|评审)',
  ).hasMatch(lower)) {
    return 'project';
  }
  if (RegExp(r'(idea|thought|maybe|灵感|想法|想到|也许|或许)').hasMatch(lower)) {
    return 'idea';
  }
  return 'note';
}

String _digestSectionTitle(String type) {
  switch (type) {
    case 'todo':
      return 'Todos';
    case 'schedule':
      return 'Schedule';
    case 'mood':
      return 'Mood';
    case 'project':
      return 'Project';
    case 'idea':
      return 'Ideas';
    default:
      return 'Notes';
  }
}

String _shorten(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength - 3)}...';
}

bool _looksLikeMixedLongText(String pureText) {
  if (pureText.length < 280 && _splitThoughts(pureText).length < 4) {
    return false;
  }

  final types = _splitThoughts(
    pureText,
  ).map(_classifyDigestPart).where((type) => type != 'note').toSet();
  return types.length >= 2;
}

String _extractPureText(String combinedText) {
  return combinedText
      .split('\n')
      .where((l) => !l.startsWith('![') && !l.startsWith('[audio]'))
      .join('\n')
      .trim();
}

String _deriveTitle(String pureText) {
  if (pureText.isEmpty) return '';
  final firstLine = pureText.split('\n').first.trim();
  if (firstLine.length <= 60) return firstLine;
  return '${firstLine.substring(0, 57)}...';
}
