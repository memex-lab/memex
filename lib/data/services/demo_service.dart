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
import 'package:memex/domain/models/event_bus_message.dart';
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
  tapInsightUpdate,
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

  /// Whether the demo card has finished updating and is ready for spotlight.
  bool _cardReady = false;
  bool get cardReady => _cardReady;

  // GlobalKeys for spotlight targets
  final GlobalKey addButtonKey = GlobalKey(debugLabel: 'demo_add_button');
  final GlobalKey sendButtonKey = GlobalKey(debugLabel: 'demo_send_button');
  final GlobalKey firstCardKey = GlobalKey(debugLabel: 'demo_first_card');
  final GlobalKey insightTabKey = GlobalKey(debugLabel: 'demo_insight_tab');
  final GlobalKey insightUpdateKey =
      GlobalKey(debugLabel: 'demo_insight_update');
  final GlobalKey knowledgeTabKey = GlobalKey(debugLabel: 'demo_kb_tab');

  // Track IDs for cross-referencing
  String? _introFactId;
  String? _userRecordFactId;

  /// Start the demo: write intro card, then show welcome overlay.
  /// Skips automatically for existing users who upgrade (they have legacy
  /// onboarding flags but not the new demo-seen flag).
  Future<void> start(String userId) async {
    final seen = await OnboardingService.hasDemoBeenSeen();
    if (seen) return;

    // If the user already has fact files, they're not new — skip the demo.
    try {
      final factsDir =
          Directory(FileSystemService.instance.getFactsPath(userId));
      if (await factsDir.exists()) {
        final hasFacts = await factsDir
            .list(recursive: true)
            .any((e) => e.path.endsWith('.md'));
        if (hasFacts) {
          await OnboardingService.markDemoAsSeen();
          return;
        }
      }
    } catch (_) {
      // If we can't check, proceed with the demo — safe default for new users.
    }
    _logger.info('Starting onboarding demo');

    // Write the intro card before showing welcome
    await _writeIntroCard(userId);

    _currentStep = DemoStep.welcome;
    notifyListeners();
  }

  void advance() {
    if (_currentStep == null) return;
    final steps = DemoStep.values;
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

  void _finish() {
    _currentStep = null;
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
      case DemoStep.tapInsightUpdate:
        return insightUpdateKey;
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
      case DemoStep.tapInsightUpdate:
        return l10n.demoTapInsightUpdate;
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

  bool get _isZh => UserStorage.l10n.localeName.startsWith('zh');

  /// Write the Memex intro card that's visible when user first enters timeline.
  Future<void> _writeIntroCard(String userId) async {
    try {
      final fs = FileSystemService.instance;
      final now = DateTime.now().subtract(const Duration(minutes: 1));
      final factId = await fs.generateFactId(userId, now);
      _introFactId = factId;
      final simpleFactId = fs.extractSimpleFactId(factId);
      final timeStr = fs.formatTime(now);

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
          index: 1,
          factId: factId,
        );
        iconFsUrl = 'fs://$filename';
        try {
          tempFile.deleteSync();
        } catch (_) {}
      } catch (e) {
        _logger.warning('Failed to copy demo icon: $e');
      }

      final rawText = _isZh ? _introTextZh : _introTextEn;
      final combinedText =
          iconFsUrl != null ? '$rawText\n\n![image]($iconFsUrl)' : rawText;
      final markdownEntry =
          '## <id:$simpleFactId> $timeStr "{}"\n\n$combinedText\n';
      await fs.appendToDailyFactFile(userId, now, markdownEntry);

      final introCard = CardData(
        factId: factId,
        timestamp: now.millisecondsSinceEpoch ~/ 1000,
        status: 'completed',
        title: _isZh ? 'Memex — 你的 AI 生活记录本' : 'Memex — Your AI Life Journal',
        tags: const ['Knowledge'],
        uiConfigs: _buildIntroUiConfigs(iconFsUrl),
        insight: CardInsight(
          text: _isZh
              ? 'Memex 是你的 AI 记忆助手。记录文字、照片、语音，AI 自动整理成结构化卡片、提取知识、生成跨记录洞察。'
              : 'Memex is your AI memory assistant. Record text, photos, voice — AI auto-organizes into structured cards, extracts knowledge, and generates cross-record insights.',
          summary: _isZh ? 'Memex 功能概览' : 'Memex feature overview',
          characterId: '0',
        ),
        comments: [
          CardComment(
            id: _uuid.v4(),
            content: _isZh
                ? '欢迎！试试发表你的第一条记录，看看 AI 如何帮你整理 ✨'
                : 'Welcome! Try posting your first record and see how AI organizes it ✨',
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
        factContent: combinedText,
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
      final kbFile =
          File(path.join(kbDir, _isZh ? 'Memex 指南.md' : 'Memex Guide.md'));
      final kbContent =
          (_isZh ? _kbContentZh : _kbContentEn) + '\n<!-- fact_id: $factId -->';
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
      _userRecordFactId = factId;
      final fs = FileSystemService.instance;
      final eventBus = EventBusService.instance;

      // Ensure default characters are created before writing comment
      await CharacterService.instance.getAllCharacters(userId);

      // Pick a default character for the comment (死党/Buddy)
      final defaultChars = UserStorage.l10n.defaultCharacters;
      final commentCharId = defaultChars.isNotEmpty
          ? defaultChars.last['id'] as String // "5" (死党/Buddy)
          : '5';

      // Wait a moment to simulate processing
      await Future.delayed(const Duration(milliseconds: 1500));

      // Build completed card
      final relatedFacts = _introFactId != null
          ? [RelatedFact(id: _introFactId!)]
          : <RelatedFact>[];

      final completedCard = CardData(
        factId: factId,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        status: 'completed',
        title: _isZh ? '我的第一条记录' : 'My First Record',
        tags: const ['Knowledge'],
        uiConfigs: [
          UiConfig(templateId: 'snippet', data: {
            'text': combinedText,
            'style': 'default',
          }),
        ],
        insight: CardInsight(
          text: _isZh
              ? '收到了你的第一条记录 🎉 。以后你记下的每一笔，我都会帮你整理、归类，还会把相关的内容串联起来。'
              : 'Your first record is here 🎉 Filed under "Knowledge." Every note you jot down from now on, I\'ll organize, categorize, and connect the dots for you.',
          summary: _isZh ? '第一条记录' : 'First record',
          relatedFacts: relatedFacts,
          characterId: '0',
        ),
        comments: [
          CardComment(
            id: _uuid.v4(),
            content: _isZh
                ? '哟，开张大吉！🎉 期待你接下来的记录～'
                : 'And so it begins! 🎉 Looking forward to what comes next~',
            isAi: true,
            characterId: commentCharId,
            timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          ),
        ],
      );

      await fs.safeWriteCardFile(userId, factId, completedCard);

      // Render and push update to timeline
      final renderResult = await renderCard(
        userId: userId,
        cardData: completedCard,
        factContent: combinedText,
      );
      final assetsAndText = await extractAssetsAndRawText(userId, combinedText);
      final assets = (assetsAndText['assets'] as List<AssetData>)
          .map((a) => a.toJson())
          .toList();
      final rawText = assetsAndText['rawText'] as String?;

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

      // Card is now stable — signal the overlay to measure.
      _cardReady = true;
      notifyListeners();

      _logger.info('Demo: wrote completed card for $factId');

      // Append user's first record to the KB file with fact_id reference
      try {
        final pkmRoot = fs.getPkmPath(userId);
        final kbDir = path.join(pkmRoot, 'Resources');
        final kbFileName = _isZh ? 'Memex 指南.md' : 'Memex Guide.md';
        final kbFile = File(path.join(kbDir, kbFileName));
        if (await kbFile.exists()) {
          final existing = await kbFile.readAsString();
          final appendSection = _isZh
              ? '\n\n## 用户的第一条记录\n\n$combinedText\n\n<!-- fact_id: $factId -->'
              : '\n\n## User\'s First Record\n\n$combinedText\n\n<!-- fact_id: $factId -->';
          await kbFile.writeAsString('$existing$appendSection');
        }
      } catch (e) {
        _logger.warning('Failed to append to KB file: $e');
      }
    } catch (e) {
      _logger.severe('Failed to handle demo submit: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Preset content
  // ---------------------------------------------------------------------------

  static const _introTextEn =
      'Welcome to Memex — your AI-powered personal memory assistant.';
  static const _introTextZh = '欢迎来到 Memex —— 你的 AI 个人记忆助手。';

  /// Build intro card uiConfigs with multiple templates to showcase Memex.
  List<UiConfig> _buildIntroUiConfigs(String? iconFsUrl) => [
        // 1. Snapshot — app icon hero
        if (iconFsUrl != null)
          UiConfig(templateId: 'snapshot', data: {
            'image_url': iconFsUrl,
            'caption': _isZh ? '你的 AI 生活记录本' : 'Your AI life journal',
          }),

        // 2. Snippet — natural intro paragraph
        UiConfig(templateId: 'snippet', data: {
          'text': _isZh
              ? '随手记下一段文字、拍张照片、或者说一句话 — Memex 会自动把它变成一张结构化的卡片。'
                  '不只是记录，AI 还会帮你提取知识、整理到笔记里，甚至发现你自己都没注意到的规律。\n\n'
                  '所有数据都存在你的手机上，不经过任何云端。'
              : 'Jot down a thought, snap a photo, or say something out loud — Memex turns it into a structured card automatically. '
                  'Beyond recording, AI extracts knowledge into organized notes and surfaces patterns you might have missed.\n\n'
                  'Everything stays on your device. No cloud, no compromise.',
          'style': 'default',
        }),

        // 3. Metric — 5 categories, 22 templates
        UiConfig(templateId: 'metric', data: {
          'title': _isZh ? '22 种智能卡片' : '22 Smart Card Types',
          'items': [
            {
              'title': _isZh ? '生活效率' : 'Productivity',
              'value': 5,
              'unit': '',
              'label': _isZh
                  ? '任务 · 习惯 · 日程 · 计时 · 进度'
                  : 'task · routine · event · duration · progress',
              'color': 'indigo',
            },
            {
              'title': _isZh ? '知识媒体' : 'Knowledge',
              'value': 6,
              'unit': '',
              'label': _isZh
                  ? '文章 · 片段 · 语录 · 链接 · 对话 · 流程'
                  : 'article · snippet · quote · link · conversation · procedure',
              'color': 'emerald',
            },
            {
              'title': _isZh ? '数据度量' : 'Data',
              'value': 4,
              'unit': '',
              'label': _isZh
                  ? '指标 · 评分 · 账单 · 规格'
                  : 'metric · rating · transaction · spec',
              'color': 'orange',
            },
            {
              'title': _isZh ? '人物地点' : 'People & Places',
              'value': 4,
              'unit': '',
              'label': _isZh
                  ? '联系人 · 地点 · 情绪 · 紧凑'
                  : 'person · place · mood · compact',
              'color': 'indigo',
            },
            {
              'title': _isZh ? '视觉记录' : 'Visual',
              'value': 3,
              'unit': '',
              'label': _isZh ? '快照 · 相册 · 视频' : 'snapshot · gallery · video',
              'color': 'emerald',
            },
          ],
        }),

        // 4. Rating — insight capability (right after card types)
        UiConfig(templateId: 'rating', data: {
          'subject': _isZh ? '12 种跨记录洞察' : '12 Cross-Record Insight Types',
          'score': 4,
          'max_score': 4,
          'comment': _isZh
              ? '图表 · 叙事 · 地图 · 时间线 — AI 自动发现你记录中的规律'
              : 'Charts · Narratives · Maps · Timelines — AI discovers patterns across your records',
        }),

        // 5. Task — getting started
        UiConfig(templateId: 'task', data: {
          'title': _isZh ? '开始使用' : 'Getting Started',
          'subtasks': [
            {
              'title': _isZh
                  ? '配置 AI 模型（头像 → 模型配置）'
                  : 'Configure AI model (Avatar → Model Config)',
              'completed': false,
            },
            {
              'title': _isZh ? '发表第一条记录' : 'Post your first record',
              'completed': false,
            },
            {
              'title': _isZh
                  ? '查看 AI 生成的卡片和知识文件'
                  : 'View AI-generated cards and knowledge files',
              'completed': false,
            },
          ],
        }),

        // 6. Quote — slogan
        UiConfig(templateId: 'quote', data: {
          'content': _isZh
              ? '生活值得被认真对待。每一条记录，都是未来的你回望今天时，最珍贵的线索。'
              : 'Your life deserves to be remembered well. Every record you make today becomes a thread your future self will be grateful to find.',
          'author': 'Memex',
        }),
      ];

  static const _kbContentEn = '''# Memex Guide

## What is Memex?

Memex is a local-first, AI-native personal life recording app. Capture text, photos, and voice — a multi-agent system automatically organizes your records into structured timeline cards, extracts knowledge, and generates insights across your entries.

Everything stays on your device. You bring your own LLM provider. No cloud, no compromise.

## Multi-Modal Recording

- Capture text, images, and voice in a single input flow
- Long-press to record audio, release to send
- Automatic EXIF extraction (timestamp, GPS location) from photos
- On-device OCR text recognition and image labeling via Google ML Kit

## AI-Powered Organization

A multi-agent architecture works behind the scenes: each agent handles a specific domain — recording organization, card generation, insights, comments, memory summarization, and media analysis.

Memex auto-generates the most fitting card for each record:

- **Productivity** (5): task, routine, event, duration, progress — record todos, habits, schedules and goals
- **Knowledge** (6): article, snippet, quote, link, conversation, procedure — capture notes, references and dialogues
- **People & Places** (4): person, place, mood, compact — record contacts and locations with map preview
- **Data** (4): metric, rating, transaction, spec sheet — record measurements, reviews and expenses
- **Visual** (3): snapshot, gallery, video — preserve moments through photos

AI also handles auto-tagging, entity extraction, and cross-reference linking between records.

## AI Conversation Assistant

You can chat with the AI assistant about any card or topic. Ask questions, get summaries, or explore connections across your records through natural conversation.

## Insights

AI discovers patterns across your records and presents them as insight cards:

- **Charts**: trend, bar, radar, bubble, composition, progress ring — visualize patterns, distributions and goal progress
- **Narrative**: highlight, contrast, summary — surface key conclusions, before/after comparisons, and periodic reviews
- **Spatial & Temporal**: map, route, timeline — reconstruct where and when things happened
- **Gallery**: visual memory from your photos

## Knowledge Organization

Uses P.A.R.A methodology — Projects, Areas, Resources, Archives. Every record is automatically filed into the right place.

## Pure Text & Data Freedom

- After AI organization, all records naturally settle into interconnected Markdown files, making diary and document archiving effortless
- As AI capabilities advance, pure text records bridge the gap of time and keep pace with its evolution — future models will unlock new experiences from your existing records
- Zero vendor lock-in: export all records as standard Markdown files and migrate to any note-taking app at zero cost

## Storage & Backup

- Supports iCloud Drive and app storage
- One-tap full backup and restore

## Multi-LLM Provider Support

Memex supports a wide range of LLM providers: Google Gemini, OpenAI, Anthropic Claude, AWS Bedrock, Kimi (Moonshot), Aliyun (Qwen), Volcengine (Doubao), Zhipu GLM, MiniMax, Xiaomi MIMO, OpenRouter, and Ollama for local models. Each agent can be configured with a different model independently.

Google Gemini and OpenAI also support OAuth sign-in without an API key.

## Privacy & Security

- All data stored locally on your device
- App lock with biometric authentication (Face ID / fingerprint)
- No cloud dependency — your data never leaves your device
''';

  static const _kbContentZh = '''# Memex 指南

## 什么是 Memex？

Memex 是一个本地优先、AI 原生的个人生活记录应用。支持文字、图片、语音多模态输入，通过多 Agent 协作自动将你的记录整理为结构化的时间线卡片，提取知识，并生成跨记录的洞察。

所有数据存储在你的设备上，你只需要选择你偏好的模型提供商。

## 多模态记录

- 文字、图片、语音一站式记录
- 长按录音，松手即发送
- 自动提取照片 EXIF 信息（时间、GPS 位置）
- 端侧 OCR 文字识别与图像标签分析（Google ML Kit）

## AI 自动整理

多 Agent 架构在后台协同工作：记录整理、卡片生成、洞察分析、评论、记忆摘要、媒体分析等各司其职。

Memex 为每条记录自动生成最合适的卡片：

- **生活效率**（5 种）：任务、习惯、日程、计时、进度 — 记录待办、习惯打卡、日程与目标
- **知识媒体**（6 种）：文章、片段、语录、链接、对话、流程 — 记录笔记、参考资料与对话内容
- **人物地点**（4 种）：联系人、地点、情绪、紧凑 — 记录人际关系与位置信息，支持地图预览
- **数据度量**（4 种）：指标、评分、账单、规格 — 记录测量数据、评价与消费
- **视觉记录**（3 种）：快照、相册、视频 — 用图片留存珍贵时刻

AI 还会自动打标签、提取实体、建立记录之间的关联关系。

## AI 对话助手

你可以和 AI 助手聊任何卡片或话题。提问、获取摘要、或通过自然对话探索记录之间的关联。

## 洞察

AI 从你的记录中发现规律，以洞察卡片的形式呈现：

- **图表**：趋势、柱状、雷达、气泡、构成比例、进度环 — 可视化数据规律、分布与目标进展
- **叙事**：亮点、对比、总结 — 提炼关键结论、呈现前后变化、生成周期性回顾
- **时空**：地图、路线、时间线 — 还原事件发生的地点与时间脉络
- **图集** — 以照片形式唤起视觉记忆

## 知识整理

采用 P.A.R.A 方法论 — Projects（项目）、Areas（领域）、Resources（资源）、Archives（归档）。每条记录自动归档到合适的位置。

## 纯文本与数据自由

- AI 整理后，所有记录自然形成一系列相互关联的 Markdown 文件，一键完成日记与文档入库
- AI 能力在不断飞跃，纯文本记录能跨越时空跟上进化的脚步 — 未来更强的模型会从你现有的记录中挖掘出全新的体验与洞察
- 零平台锁定：随时一键导出所有记录为 Markdown 文件，零成本迁移到任何笔记产品

## 存储与备份

- 支持 iCloud Drive
- 一键完整备份与恢复

## 多 LLM 提供商支持

Memex 支持多种 LLM 提供商：Google Gemini、OpenAI、Anthropic Claude、AWS Bedrock、Kimi（月之暗面）、阿里云（通义千问）、火山引擎（豆包）、智谱 GLM、MiniMax、小米 MIMO、OpenRouter，以及 Ollama 本地模型。每个 Agent 可以独立配置不同的模型。

Google Gemini 和 OpenAI 还支持 OAuth 登录，无需 API Key。

## 隐私与安全

- 所有数据存储在你的设备本地
- 应用锁，支持生物识别认证（Face ID / 指纹）
- 无云端依赖，数据不会离开你的设备
''';
}
