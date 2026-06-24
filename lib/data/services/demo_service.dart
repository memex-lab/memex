import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:memex/data/services/onboarding_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/card_renderer.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/domain/models/card_detail_model.dart';
import 'package:memex/l10n/app_localizations_ext.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';

final _logger = getLogger('DemoService');
const _uuid = Uuid();

enum DemoStep {
  welcome,
  tapAddButton,
  tapSend,
  tapCard,
  tapInsightTab,
  tapKnowledgeTab,
  done,
}

/// Singleton state machine + data writer for the onboarding demo.
class DemoService extends ChangeNotifier {
  DemoService._();
  static final DemoService instance = DemoService._();

  DemoStep? _currentStep;
  DemoStep? get currentStep => _currentStep;
  bool get isActive => _currentStep != null && _currentStep != DemoStep.done;

  bool _isOverlaySuspended = false;
  bool get isOverlaySuspended => _isOverlaySuspended;

  /// Whether the demo card has finished updating and is ready for spotlight.
  bool _cardReady = false;
  bool get cardReady => _cardReady;

  /// The card created from the user's first demo input.
  String? _demoCardId;
  bool isDemoTargetCardId(String cardId) => _demoCardId == cardId;

  // GlobalKeys for spotlight targets
  final GlobalKey addButtonKey = GlobalKey(debugLabel: 'demo_add_button');
  final GlobalKey sendButtonKey = GlobalKey(debugLabel: 'demo_send_button');
  final GlobalKey firstCardKey = GlobalKey(debugLabel: 'demo_first_card');
  final GlobalKey insightTabKey = GlobalKey(debugLabel: 'demo_insight_tab');
  final GlobalKey knowledgeTabKey = GlobalKey(debugLabel: 'demo_kb_tab');

  // Track IDs for cross-referencing
  String? _introFactId;

  /// Start the demo: write intro card, then show welcome overlay.
  /// Skips automatically for existing users who upgrade (they have legacy
  /// onboarding flags but not the new demo-seen flag).
  Future<void> start(String userId) async {
    final seen = await OnboardingService.hasDemoBeenSeen();
    if (seen) return;

    // If the user already has cards, they're not new — skip the demo.
    try {
      final existingCards =
          await FileSystemService.instance.listAllCardFiles(userId);
      if (existingCards.isNotEmpty) {
        await OnboardingService.markDemoAsSeen();
        return;
      }
    } catch (_) {
      // If we can't check, proceed with the demo — safe default for new users.
    }
    _logger.info('Starting onboarding demo');

    // Write the intro card before showing welcome
    await _writeIntroCard(userId);

    _demoCardId = null;
    _cardReady = false;
    _currentStep = DemoStep.welcome;
    _isOverlaySuspended = false;
    notifyListeners();
  }

  void advance() {
    if (_currentStep == null) return;
    const steps = DemoStep.values;
    final idx = steps.indexOf(_currentStep!);
    if (idx < steps.length - 1) {
      _currentStep = steps[idx + 1];
      _logger.info('Demo advanced to: $_currentStep');
      notifyListeners();
    } else {
      _finish();
    }
  }

  bool tryAdvance(DemoStep expected) {
    if (_currentStep == expected) {
      advance();
      return true;
    }
    return false;
  }

  void skip() {
    _logger.info('Demo skipped');
    _finish();
  }

  void suspendOverlay() {
    if (_isOverlaySuspended) return;
    _isOverlaySuspended = true;
    notifyListeners();
  }

  void resumeOverlay() {
    if (!_isOverlaySuspended) return;
    _isOverlaySuspended = false;
    notifyListeners();
  }

  void _finish() {
    _currentStep = null;
    _isOverlaySuspended = false;
    _demoCardId = null;
    _cardReady = false;
    OnboardingService.markDemoAsSeen();
    notifyListeners();
  }

  GlobalKey? get currentTargetKey {
    switch (_currentStep) {
      case DemoStep.tapAddButton:
        return addButtonKey;
      case DemoStep.tapSend:
        return sendButtonKey;
      case DemoStep.tapCard:
        return firstCardKey;
      case DemoStep.tapInsightTab:
        return insightTabKey;
      case DemoStep.tapKnowledgeTab:
        return knowledgeTabKey;
      default:
        return null;
    }
  }

  String get tooltipText {
    final l10n = UserStorage.l10n;
    switch (_currentStep) {
      case DemoStep.welcome:
        return l10n.demoWelcome;
      case DemoStep.tapAddButton:
        return l10n.demoTapAdd;
      case DemoStep.tapSend:
        return l10n.demoTapSend;
      case DemoStep.tapCard:
        return l10n.demoTapCard;
      case DemoStep.tapInsightTab:
        return l10n.demoTapInsight;
      case DemoStep.tapKnowledgeTab:
        return l10n.demoTapKnowledge;
      case DemoStep.done:
        return l10n.demoDone;
      default:
        return '';
    }
  }

  String get actionButtonText {
    final l10n = UserStorage.l10n;
    switch (_currentStep) {
      case DemoStep.welcome:
        return l10n.demoStartTour;
      case DemoStep.done:
        return l10n.demoGetStarted;
      default:
        return '';
    }
  }

  String get skipText => UserStorage.l10n.demoSkip;
  String get prefillText => UserStorage.l10n.demoPrefillText;

  // ---------------------------------------------------------------------------
  // Data writing
  // ---------------------------------------------------------------------------

  MemexDemoCopy get _copy => UserStorage.l10n.demoCopy;

  /// Write the Memex intro card that's visible when user first enters timeline.
  Future<void> _writeIntroCard(String userId) async {
    try {
      final fs = FileSystemService.instance;
      final now = DateTime.now().subtract(const Duration(minutes: 1));
      final factId = await fs.allocateCardFactId(userId);
      _introFactId = factId;

      // Copy icon.png from assets to user's asset directory
      String? iconFsUrl;
      try {
        final byteData = await rootBundle.load('assets/icon.png');
        final tempDir = await getTemporaryDirectory();
        final tempFile =
            File('${tempDir.path}/demo_icon_${now.millisecondsSinceEpoch}.png');
        await tempFile.writeAsBytes(
          byteData.buffer
              .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        );
        final (filename, _) = await fs.saveAssetFromFile(
          userId: userId,
          sourcePath: tempFile.path,
          assetType: 'img',
        );
        iconFsUrl = 'fs://$filename';
        try {
          tempFile.deleteSync();
        } catch (_) {}
      } catch (e) {
        _logger.warning('Failed to copy demo icon: $e');
      }

      final copy = _copy;
      final rawText = copy.introText;
      final assets = iconFsUrl != null ? ['![image]($iconFsUrl)'] : <String>[];

      final introCard = CardData(
        factId: factId,
        createdAt: now.millisecondsSinceEpoch ~/ 1000,
        timestamp: now.millisecondsSinceEpoch ~/ 1000,
        status: 'completed',
        title: copy.introTitle,
        tags: const ['Knowledge'],
        fact: rawText,
        assets: assets,
        uiConfigs: _buildIntroUiConfigs(iconFsUrl),
        insight: CardInsight(
          text: copy.introInsight,
          summary: copy.introInsightSummary,
          characterId: '0',
        ),
        comments: [
          CardComment(
            id: _uuid.v4(),
            content: copy.introComment,
            isAi: true,
            characterId: '5',
            timestamp: now.millisecondsSinceEpoch ~/ 1000,
          ),
        ],
      );
      await fs.safeWriteCardFile(userId, factId, introCard);

      // Emit event so timeline picks up the new card
      final renderResult = await renderCard(
        userId: userId,
        cardData: introCard,
        factContent: rawText,
      );
      EventBusService.instance.emitEvent(CardAddedMessage(
        id: factId,
        html: renderResult.html ?? '',
        timestamp: introCard.timestamp,
        tags: introCard.tags,
        status: renderResult.status,
        title: introCard.title,
        uiConfigs: renderResult.uiConfigs,
        rawText: rawText,
      ));

      // Write knowledge file
      final pkmRoot = fs.getPkmPath(userId);
      final kbDir = path.join(pkmRoot, 'Resources');
      await Directory(kbDir).create(recursive: true);
      final kbFile = File(path.join(kbDir, copy.kbFileName));
      final kbContent = '${copy.kbContent}\n<!-- fact_id: $factId -->';
      await kbFile.writeAsString(kbContent);

      // Ensure tags exist
      await fs.ensureTagsFileInitialized(userId);
      await fs.appendNewTags(userId, [
        {
          'name': 'Knowledge',
          'icon': '💡',
          'icon_type': 'emoji',
        },
      ]);

      _logger.info('Wrote intro card: $factId');
    } catch (e) {
      _logger.severe('Failed to write intro card: $e');
    }
  }

  /// Called after user submits their first record during demo.
  /// Writes a completed card with preset data, insight, comment, and relation to intro card.
  Future<void> handleDemoSubmit(
      String userId, String factId, String combinedText) async {
    try {
      await _writeCompletedDemoCard(
        userId: userId,
        factId: factId,
        combinedText: combinedText,
        publishAsAdded: false,
      );
    } catch (e) {
      _logger.severe('Failed to handle demo submit: $e');
    }
  }

  /// Called when the onboarding demo is submitted from Super Agent chat.
  ///
  /// The Super Agent chat stream does not synchronously return the legacy
  /// submitInput fact_id, so the demo creates and publishes its own card.
  Future<void> handleSuperAgentDemoSubmit(
      String userId, String combinedText) async {
    try {
      final factId =
          await FileSystemService.instance.allocateCardFactId(userId);
      await _writeCompletedDemoCard(
        userId: userId,
        factId: factId,
        combinedText: combinedText,
        publishAsAdded: true,
      );
    } catch (e) {
      _logger.severe('Failed to handle super agent demo submit: $e');
    }
  }

  Future<void> _writeCompletedDemoCard({
    required String userId,
    required String factId,
    required String combinedText,
    required bool publishAsAdded,
  }) async {
    final fs = FileSystemService.instance;
    final eventBus = EventBusService.instance;

    _demoCardId = factId;
    _cardReady = false;
    notifyListeners();

    // Ensure default characters are created before writing comment
    await CharacterService.instance.getAllCharacters(userId);

    // Pick a default character for the comment (死党/Buddy)
    final defaultChars = UserStorage.l10n.defaultCharacters;
    var commentCharId = '5';
    for (final charData in defaultChars) {
      if (charData['id'] == '5') {
        commentCharId = charData['id'] as String;
        break;
      }
    }

    // Wait a moment to simulate processing
    await Future.delayed(const Duration(milliseconds: 1500));

    // Build completed card
    final relatedFacts = _introFactId != null
        ? [RelatedFact(id: _introFactId!)]
        : <RelatedFact>[];
    final createdAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final copy = _copy;

    final completedCard = CardData(
      factId: factId,
      createdAt: createdAt,
      timestamp: createdAt,
      status: 'completed',
      title: copy.firstRecordTitle,
      tags: const ['Knowledge'],
      uiConfigs: [
        UiConfig(templateId: 'snippet', data: {
          'text': combinedText,
          'style': 'default',
        }),
      ],
      insight: CardInsight(
        text: copy.firstRecordInsight,
        summary: copy.firstRecordSummary,
        relatedFacts: relatedFacts,
        characterId: '0',
      ),
      comments: [
        CardComment(
          id: _uuid.v4(),
          content: copy.firstRecordComment,
          isAi: true,
          characterId: commentCharId,
          timestamp: createdAt,
        ),
      ],
    );

    await fs.safeWriteCardFile(userId, factId, completedCard);

    final renderResult = await renderCard(
      userId: userId,
      cardData: completedCard,
      factContent: combinedText,
    );
    final assetsAndText = await extractAssetsAndRawText(userId, completedCard);
    final assets = (assetsAndText['assets'] as List<AssetData>)
        .map((a) => a.toJson())
        .toList();
    final rawText = assetsAndText['rawText'] as String?;

    if (publishAsAdded) {
      eventBus.emitEvent(CardAddedMessage(
        id: factId,
        html: renderResult.html ?? '',
        timestamp: completedCard.timestamp,
        tags: completedCard.tags,
        status: renderResult.status,
        title: completedCard.title,
        uiConfigs: renderResult.uiConfigs,
        assets: assets.isNotEmpty ? assets : null,
        rawText: rawText,
      ));
    } else {
      eventBus.emitEvent(CardUpdatedMessage(
        id: factId,
        html: renderResult.html ?? '',
        timestamp: completedCard.timestamp,
        tags: completedCard.tags,
        status: renderResult.status,
        title: completedCard.title,
        uiConfigs: renderResult.uiConfigs,
        assets: assets.isNotEmpty ? assets : null,
        rawText: rawText,
      ));
    }

    // Card is now stable — signal the overlay to measure.
    _cardReady = true;
    notifyListeners();

    _logger.info('Demo: wrote completed card for $factId');

    // Append user's first record to the KB file with fact_id reference
    try {
      final pkmRoot = fs.getPkmPath(userId);
      final kbDir = path.join(pkmRoot, 'Resources');
      final kbFileName = copy.kbFileName;
      final kbFile = File(path.join(kbDir, kbFileName));
      if (await kbFile.exists()) {
        final existing = await kbFile.readAsString();
        final appendSection = copy.firstRecordKbAppend(combinedText, factId);
        await kbFile.writeAsString('$existing$appendSection');
      }
    } catch (e) {
      _logger.warning('Failed to append to KB file: $e');
    }
  }

  /// Build intro card uiConfigs with multiple templates to showcase Memex.
  List<UiConfig> _buildIntroUiConfigs(String? iconFsUrl) {
    final copy = _copy;
    return [
      // 1. Snapshot — app icon hero
      if (iconFsUrl != null)
        UiConfig(templateId: 'snapshot', data: {
          'image_url': iconFsUrl,
          'caption': copy.introHeroCaption,
        }),

      // 2. Snippet — natural intro paragraph
      UiConfig(templateId: 'snippet', data: {
        'text': copy.introSnippetText,
        'style': 'default',
      }),

      // 3. Metric — 5 categories, 22 templates
      UiConfig(templateId: 'metric', data: {
        'title': copy.smartCardTypesTitle,
        'items': [
          {
            'title': copy.productivityTitle,
            'value': 5,
            'unit': '',
            'label': copy.productivityLabel,
            'color': 'indigo',
          },
          {
            'title': copy.knowledgeTitle,
            'value': 6,
            'unit': '',
            'label': copy.knowledgeLabel,
            'color': 'emerald',
          },
          {
            'title': copy.dataTitle,
            'value': 4,
            'unit': '',
            'label': copy.dataLabel,
            'color': 'orange',
          },
          {
            'title': copy.peoplePlacesTitle,
            'value': 4,
            'unit': '',
            'label': copy.peoplePlacesLabel,
            'color': 'indigo',
          },
          {
            'title': copy.visualTitle,
            'value': 3,
            'unit': '',
            'label': copy.visualLabel,
            'color': 'emerald',
          },
        ],
      }),

      // 4. Rating — insight capability (right after card types)
      UiConfig(templateId: 'rating', data: {
        'subject': copy.insightTypesSubject,
        'score': 4,
        'max_score': 4,
        'comment': copy.insightTypesComment,
      }),

      // 5. Task — getting started
      UiConfig(templateId: 'task', data: {
        'title': copy.gettingStartedTitle,
        'subtasks': [
          {
            'title': copy.configureModelTask,
            'completed': false,
          },
          {
            'title': copy.postFirstRecordTask,
            'completed': false,
          },
          {
            'title': copy.viewGeneratedTask,
            'completed': false,
          },
        ],
      }),

      // 6. Quote — slogan
      UiConfig(templateId: 'quote', data: {
        'content': copy.sloganContent,
        'author': 'Memex',
      }),
    ];
  }
}
