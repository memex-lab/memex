import 'package:memex/domain/models/card_model.dart';
import 'package:logging/logging.dart';

final _logger = Logger('RuleBasedCardMatcher');

/// Rule-based card template matcher used when LLM is unavailable.
///
/// Priority order:
///   1. 1 image  → snapshot
///   2. 2+ images → gallery
///   3. URL-only text → link
///   4. Everything else → snippet
CardData applyRuleBasedTemplate({
  required CardData card,
  required String combinedText,
  required List<String> imageUrls,
  required String? audioUrl,
}) {
  final pureText = _extractPureText(combinedText);

  final templateId = _matchTemplate(pureText: pureText, imageUrls: imageUrls);

  _logger.info(
      'Rule-based match: templateId=$templateId, images=${imageUrls.length}, textLen=${pureText.length}');

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

String _matchTemplate(
    {required String pureText, required List<String> imageUrls}) {
  if (imageUrls.isNotEmpty) {
    return imageUrls.length == 1 ? 'snapshot' : 'gallery';
  }
  if (_isUrlOnly(pureText)) return 'link';
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
      return {
        'url': url,
        if (rest.isNotEmpty) 'title': rest,
      };
    case 'snippet':
    default:
      return {'text': pureText.isNotEmpty ? pureText : '…', 'style': 'default'};
  }
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
