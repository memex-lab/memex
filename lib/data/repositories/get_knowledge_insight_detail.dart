import 'package:memex/domain/models/card_detail_model.dart';
import 'package:memex/domain/models/insight_detail_model.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/card_renderer.dart';
import 'package:memex/data/services/html_templates.dart';
import 'package:memex/agent/skills/knowledge_insight/native_widgets.dart';

final _logger = getLogger('GetKnowledgeInsightDetailEndpoint');
final _fileSystemService = FileSystemService.instance;

/// Get knowledge insight card detail
///
/// Args:
///   insightId: insight card ID (e.g. card id field: "finance_2025_summary")
///
/// Returns:
///   InsightDetailModel: insight detail
Future<InsightDetailModel> getKnowledgeInsightDetail(String insightId) async {
  _logger.info(
      'GetKnowledgeInsightDetailEndpoint: getKnowledgeInsightDetail called: insightId=$insightId');

  try {
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      throw Exception('User not logged in, cannot get insight detail');
    }

    // Read knowledge insight card file (id.yaml)
    final cardFileName = '$insightId.yaml';
    final cardData =
        await _fileSystemService.readKnowledgeInsightCard(userId, cardFileName);

    if (cardData == null) {
      throw Exception('Knowledge insight card not found: $insightId');
    }

    // Build InsightMetadataModel
    final cardTitle = cardData['title'] as String? ?? '';
    final cardTemplateId = cardData['template_id'] as String? ?? '';

    // Infer icon from title or template_id
    String icon = 'bar_chart'; // default icon
    if (cardTitle.contains('expense') ||
        cardTitle.contains('finance') ||
        cardTemplateId.toLowerCase().contains('expense') ||
        cardTemplateId.toLowerCase().contains('finance')) {
      icon = 'account_balance_wallet';
    } else if (cardTitle.contains('mood') ||
        cardTemplateId.toLowerCase().contains('mood')) {
      icon = 'mood';
    } else if (cardTitle.contains('energy') ||
        cardTemplateId.toLowerCase().contains('energy')) {
      icon = 'battery_charging_full';
    } else if (cardTitle.contains('word') ||
        cardTemplateId.toLowerCase().contains('word')) {
      icon = 'text_fields';
    } else if (cardTitle.contains('map') ||
        cardTitle.contains('location') ||
        cardTemplateId.toLowerCase().contains('map')) {
      icon = 'map';
    }

    final insightInfo = InsightMetadataModel(
      id: insightId,
      title: cardTitle,
      icon: icon,
      type: 'chart',
    );

    // content: use card insight field
    final content = cardData['insight'] as String? ?? '';

    // analysis: render chart HTML (if not native type)
    String analysisHtml = '';
    final isNative = nativeWidgets.any((w) => w.id == cardTemplateId);

    if (!isNative) {
      analysisHtml = await _renderCardHtmlForDetail(userId, cardData);
    }

    // related_cards: from related_facts to timeline cards
    final relatedCards = <RelatedCardModel>[];
    final relatedFacts = cardData['related_facts'] as List<dynamic>? ?? [];

    for (final factId in relatedFacts) {
      try {
        if (factId is! String) {
          continue;
        }

        // Read card data
        final timelineCardData =
            await _fileSystemService.readCardFile(userId, factId);
        if (timelineCardData == null) {
          _logger.warning('Card not found for fact_id: $factId');
          continue;
        }

        // Read fact content for extracting assets and raw text
        final factInfo =
            await _fileSystemService.extractFactContentFromFile(userId, factId);
        final factContent = factInfo?.content;

        // Use unified renderCard method to process card
        final renderResult = await renderCard(
          userId: userId,
          cardData: timelineCardData,
          factContent: factContent,
        );

        // Extract assets and rawText (needed for UI toggle)
        final assetsAndText =
            await extractAssetsAndRawText(userId, factContent);
        final assets = assetsAndText['assets'] as List<AssetData>;
        final rawText = assetsAndText['rawText'] as String?;

        // Build RelatedCardModel
        final timestamp = timelineCardData.timestamp;

        relatedCards.add(RelatedCardModel(
          id: factId,
          html: renderResult.html,
          createdAt: timestamp,
          uiConfigs: renderResult.uiConfigs,
          title: timelineCardData.title,
          tags: List<String>.from(timelineCardData.tags),
          status: renderResult.status,
          assets: assets.isNotEmpty ? assets : null,
          rawText: rawText,
        ));
      } catch (e) {
        _logger.warning('Failed to load related card for fact_id $factId: $e');
        continue;
      }
    }

    // Determine widget type/template/data from card YAML
    // (widget_type is NOT stored in YAML — it's computed from template_id)
    String? widgetType;
    String? widgetTemplate;
    Map<String, dynamic>? mergedWidgetData;

    if (isNative) {
      widgetType = 'native';
      widgetTemplate = cardTemplateId;
      // Build widgetData the same way the list endpoint does:
      // flatten card + card['data'], then replace fs:// URLs
      final flatData = Map<String, dynamic>.from(cardData);
      if (cardData['data'] is Map) {
        flatData.addAll((cardData['data'] as Map).cast<String, dynamic>());
      }
      flatData.remove('data');
      mergedWidgetData = await replaceFsInData(flatData, userId);
    }

    // Build InsightDetailModel
    return InsightDetailModel(
      insight: insightInfo,
      content: content,
      analysis: analysisHtml,
      relatedCards: relatedCards,
      widgetType: widgetType,
      widgetTemplate: widgetTemplate,
      widgetData: mergedWidgetData,
    );
  } catch (e) {
    _logger.severe('Failed to get knowledge insight detail $insightId: $e');
    rethrow;
  }
}

/// Render knowledge insight card HTML (for detail page)
///
/// Args:
///   userId: user ID
///   cardData: card data map
///
/// Returns:
///   HTML string
Future<String> _renderCardHtmlForDetail(
    String userId, Map<String, dynamic> cardData) async {
  final templateId = cardData['template_id'] as String? ?? '';
  final title = cardData['title'] as String? ?? '';
  final insight = cardData['insight'] as String? ?? '';
  final data = cardData['data'] as Map<String, dynamic>? ?? {};

  // Try load knowledge insight card HTML template
  final htmlTemplate = await _fileSystemService
      .readKnowledgeInsightCardTemplateHtml(userId, templateId);

  if (htmlTemplate != null && htmlTemplate.isNotEmpty) {
    // Render with template
    try {
      // Prepare template data (title, insight, all fields in data)
      final templateData = <String, dynamic>{
        'title': title,
        'insight': insight,
      };

      templateData.addAll(data);

      // Render HTML template
      final renderedHtml =
          _fileSystemService.renderHtmlTemplate(htmlTemplate, templateData);
      final replacedHtml =
          await _fileSystemService.replaceFsInHtml(renderedHtml, userId);
      return replacedHtml;
    } catch (e) {
      _logger.warning('Failed to render template $templateId: $e');
      // On render failure, use fallback
      return getChartHtmlFallback(cardData);
    }
  } else {
    // Template not found, use fallback
    _logger.warning('Template $templateId not found, using fallback HTML');
    return getChartHtmlFallback(cardData);
  }
}
