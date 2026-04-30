import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/routing/routes.dart';
import 'package:intl/intl.dart';
import 'package:memex/ui/timeline/widgets/location_picker_page.dart';
import 'package:memex/ui/calendar/view_models/calendar_viewmodel.dart';
import 'package:provider/provider.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:memex/domain/models/card_detail_model.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:latlong2/latlong.dart';
import 'package:memex/ui/timeline/widgets/timeline/asset_header_gallery.dart';
import 'package:memex/ui/core/widgets/local_image.dart';

import 'package:memex/ui/chat/widgets/agent_chat_dialog.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:memex/ui/core/widgets/dicebear_avatar.dart';
import 'package:memex/ui/core/cards/style/timeline_theme.dart';
import 'package:memex/ui/core/themes/design_system.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';
import 'package:memex/ui/character/widgets/persona_chat_screen.dart';
import 'package:memex/utils/share_service.dart';
import 'package:memex/ui/core/cards/native_card_factory.dart';
import 'package:memex/utils/token_usage_utils.dart';

/// Timeline card detail screen - plays full card detail
class TimelineCardDetailScreen extends StatefulWidget {
  final String cardId;

  const TimelineCardDetailScreen({
    super.key,
    required this.cardId,
  });

  @override
  State<TimelineCardDetailScreen> createState() =>
      _TimelineCardDetailScreenState();
}

class _TimelineCardDetailScreenState extends State<TimelineCardDetailScreen> {
  CardDetailModel? _detail;
  bool _isLoading = true;
  String? _errorMessage;
  late final MemexRouter _memexRouter;
  String _userName = 'User';
  String? _userAvatar;
  double? _firstImageAspectRatio;
  bool _showInsightText = true;
  String? _replyToCommentId;
  String? _replyToCommentName;

  @override
  void initState() {
    super.initState();
    _memexRouter = MemexRouter();
    _fetchDetail();
    _loadUserInfo();
    _setupEventBus();
  }

  void _setupEventBus() {
    EventBusService.instance.addHandler(
      EventBusMessageType.cardDetailUpdated,
      _handleCardDetailUpdated,
    );
  }

  void _handleCardDetailUpdated(EventBusMessage message) {
    if (message is CardDetailUpdatedMessage &&
        message.cardId == widget.cardId &&
        mounted) {
      _fetchDetail();
    }
  }

  Future<void> _loadUserInfo() async {
    final name = await UserStorage.getUserId();
    final avatar = await UserStorage.getUserAvatar();
    final settings = await _memexRouter.getCommentSettings();
    if (mounted) {
      setState(() {
        _userName = name ?? 'User';
        _userAvatar = avatar;
        _showInsightText = settings.showInsightText;
      });
    }
  }

  void _resolveFirstImageAspectRatio(CardDetailModel detail) {
    if (_firstImageAspectRatio != null) return;
    final imageAssets = detail.assets.where((a) => a.isImage).toList();
    if (imageAssets.isEmpty) return;

    final dims = LocalImage.extractDimensionsFromUrl(imageAssets.first.url);
    if (dims != null && dims.width > 0 && dims.height > 0) {
      setState(() {
        _firstImageAspectRatio = dims.width / dims.height;
      });
    }
  }

  @override
  void dispose() {
    EventBusService.instance.removeHandler(
      EventBusMessageType.cardDetailUpdated,
      _handleCardDetailUpdated,
    );
    super.dispose();
  }

  Future<void> _fetchDetail() async {
    if (_detail == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final detail = await _memexRouter.fetchCardDetail(widget.cardId);
      if (!mounted) return;
      setState(() {
        _detail = detail;
      });
      _resolveFirstImageAspectRatio(detail);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = UserStorage.l10n.loadDetailFailedRetryShort;
      });
      ToastHelper.showError(context, e);
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showChatDialog() {
    if (_detail == null) return;

    final contextString = StringBuffer();
    contextString.writeln('Card Fact ID: ${_detail!.id}');
    contextString
        .writeln('Card Timestamp: ${_detail!.timestamp.toIso8601String()}');
    contextString.writeln('Card Title: ${_detail!.title}');
    contextString.writeln('Card Content: ${_detail!.rawContent}');
    if (_detail!.insight.text.isNotEmpty) {
      contextString.writeln('Asset analysis results: ${_detail!.insight.text}');
    }

    if (_detail!.insight.comments.isNotEmpty) {
      contextString.writeln('Card Comments:');
      for (var comment in _detail!.insight.comments) {
        final authorName =
            comment.isAi ? 'AI' : (comment.character?.name ?? 'User');
        final authorId =
            comment.isAi ? 'ai_agent' : (comment.character?.id ?? 'user');
        final time =
            DateTime.fromMillisecondsSinceEpoch(comment.timestamp * 1000)
                .toIso8601String();
        contextString.writeln(
            '- [$time] $authorName (ID: $authorId): ${comment.content}');
      }
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AgentChatDialog(
          agentName: 'memex_agent',
          title: UserStorage.l10n.aiAssistant,
          inputHint: UserStorage.l10n.aiInputHint,
          scene: 'assistant_timeline_card_detail',
          sceneId: _detail!.id,
          initialRefs: [
            {
              'title': _detail!.title,
              'content': contextString.toString(),
              'type': 'timeline_card',
            }
          ],
        );
      },
    );
  }

  void _openCalendar() {
    if (_detail == null) return;
    final initialDate = _detail!.timestamp;
    final vm = CalendarViewModel(
      router: context.read<MemexRouter>(),
      initialDate: initialDate,
    );
    vm.fetchMonthData(DateTime(initialDate.year, initialDate.month));
    context.push(AppRoutes.calendar, extra: initialDate);
  }

  Future<void> _editTime() async {
    if (_detail == null) return;

    final initialDate = _detail!.timestamp;
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date == null) return;
    if (!mounted) return;

    // Use CupertinoDatePicker for cleaner time selection
    // Default to initial time or now if same day
    final initialTime = TimeOfDay.fromDateTime(initialDate);
    var selectedDateTime = DateTime(
        date.year, date.month, date.day, initialTime.hour, initialTime.minute);

    final timeResult = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text(UserStorage.l10n.cancel),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: Text(UserStorage.l10n.confirm),
                    onPressed: () => Navigator.pop(context, selectedDateTime),
                  ),
                ],
              ),
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: selectedDateTime,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newDateTime) {
                    selectedDateTime = newDateTime;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (timeResult == null) return;

    final newDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      timeResult.hour,
      timeResult.minute,
    );

    // Optimistic Update
    final oldDetail = _detail;
    setState(() {
      _detail = _detail!.copyWith(timestamp: newDateTime);
    });

    try {
      // API call
      // Server expects unix timestamp in seconds
      final timestamp = newDateTime.millisecondsSinceEpoch ~/ 1000;
      await _memexRouter.updateCardTime(widget.cardId, timestamp);
      ToastHelper.showSuccess(context, UserStorage.l10n.timeUpdated);
    } catch (e) {
      if (!mounted) return;
      // Revert
      setState(() {
        _detail = oldDetail;
      });
      ToastHelper.showError(
          context, UserStorage.l10n.updateFailed(e.toString()));
    }
  }

  Future<void> _editLocation() async {
    if (_detail == null) return;

    final result = await Navigator.push<LocationPickerResult>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerPage(
          initialName: _detail!.address,
          initialPoint: (_detail!.lat != null && _detail!.lng != null)
              ? LatLng(_detail!.lat!, _detail!.lng!)
              : null,
        ),
      ),
    );

    if (result != null) {
      // Optimistic Update
      final oldDetail = _detail;
      setState(() {
        _detail = _detail!.copyWith(
          address: result.name ?? result.address,
          lat: result.point.latitude,
          lng: result.point.longitude,
        );
      });

      try {
        await _memexRouter.updateCardLocation(
          widget.cardId,
          result.point.latitude,
          result.point.longitude,
          result.name ?? result.address ?? '',
        );
        ToastHelper.showSuccess(context, UserStorage.l10n.locationUpdated);
      } catch (e) {
        if (!mounted) return;
        // Revert
        setState(() {
          _detail = oldDetail;
        });
        ToastHelper.showError(
            context, UserStorage.l10n.updateFailed(e.toString()));
      }
    }
  }

  Future<void> _showLLMStats() async {
    if (_detail == null || _detail!.llmStats == null) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(UserStorage.l10n.llmCallStats),
            content: Text(UserStorage.l10n.noLlmCallRecords),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(UserStorage.l10n.confirm),
              ),
            ],
          ),
        );
      }
      return;
    }

    final stats = _detail!.llmStats!;

    // show stats dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(UserStorage.l10n.llmCallStats),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // total
              _buildStatSection(
                  UserStorage.l10n.total,
                  {
                    UserStorage.l10n.callCount: stats.totalCalls,
                    'Cache Rate': -1, // Special flag for calculation
                    'Prompt Tokens': stats.totalPromptTokens,
                    'Completion Tokens': stats.totalCompletionTokens,
                    'Cached Tokens': stats.totalCachedTokens,
                    'Thought Tokens': stats.totalThoughtTokens,
                    'Total Tokens': stats.totalTokens,
                    UserStorage.l10n.estimatedCost: -2, // Special flag for cost
                  },
                  cost: stats.totalCost),
              const SizedBox(height: 16),
              // by Agent
              if (stats.byAgent.isNotEmpty) ...[
                Text(
                  UserStorage.l10n.byAgent,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...stats.byAgent.entries.map((entry) {
                  final agentName = entry.key;
                  final agentStat = entry.value;
                  final cacheRate = agentStat.cacheUnknownTokens > 0
                      ? 'N/A'
                      : TokenUsageUtils.formatCacheRate(
                          promptTokens: agentStat.cacheBaseTokens,
                          cachedTokens: agentStat.cachedTokens,
                          cachedTokensIncludedInPrompt: true,
                        );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildStatSection(
                      _getAgentDisplayName(agentName),
                      {
                        UserStorage.l10n.callCount: agentStat.calls,
                        'Cache Rate': -1, // Special flag
                        'Prompt Tokens': agentStat.promptTokens,
                        'Completion Tokens': agentStat.completionTokens,
                        'Cached Tokens': agentStat.cachedTokens,
                        'Thought Tokens': agentStat.thoughtTokens,
                        'Total Tokens': agentStat.totalTokens,
                        UserStorage.l10n.estimatedCost:
                            -2, // Special flag for cost
                      },
                      cost: agentStat.totalCost,
                      cacheRate: cacheRate,
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(UserStorage.l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildStatSection(String title, Map<String, int> stats,
      {double? cost, String? cacheRate}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        ...stats.entries.map((entry) {
          String valueStr;
          if (entry.key == 'Cache Rate') {
            valueStr = cacheRate ?? 'N/A';
          } else if (entry.key == UserStorage.l10n.estimatedCost) {
            valueStr = _formatCost(cost ?? 0.0);
          } else {
            valueStr = entry.key == UserStorage.l10n.callCount
                ? entry.value.toString()
                : _formatTokenCount(entry.value);
          }

          return Padding(
            padding: const EdgeInsets.only(left: 8, top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                Text(
                  valueStr,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _formatCost(double cost) {
    if (cost < 0.001) {
      return '\$${cost.toStringAsFixed(6)}';
    } else {
      return '\$${cost.toStringAsFixed(4)}';
    }
  }

  String _formatTokenCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(2)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(2)}k';
    }
    return count.toString();
  }

  String _getAgentDisplayName(String agentName) {
    final displayNames = {
      'card_agent': UserStorage.l10n.cardGenerationAgent,
      'pkm_agent': UserStorage.l10n.knowledgeOrgAgent,
      'comment_agent': UserStorage.l10n.commentGenerationAgent,
      'profile_agent': UserStorage.l10n.profileAgent,
      'asset_analysis': UserStorage.l10n.assetAnalysis,
    };
    return displayNames[agentName] ?? agentName;
  }

  Future<void> _deleteCard() async {
    if (_detail == null) return;

    // show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(UserStorage.l10n.confirmDelete),
        content: Text(UserStorage.l10n.confirmDeleteCardMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(UserStorage.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(UserStorage.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // call delete API
      await _memexRouter.deleteCard(widget.cardId);

      if (mounted) {
        ToastHelper.showSuccess(context, UserStorage.l10n.deleteSuccess);
        // go back
        Navigator.of(context).pop(true); // true = deleted, refresh timeline
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(
            context, UserStorage.l10n.deleteFailed(e.toString()));
      }
    }
  }

  int _currentAssetIndex = 0;

  void _showFullScreenGallery() {
    if (_detail == null || _detail!.assets.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenGallery(
          assets: _detail!.assets,
          initialIndex: _currentAssetIndex,
        ),
      ),
    );
  }

  Future<void> _shareCard() async {
    if (_detail == null) return;
    ToastHelper.showInfo(context, UserStorage.l10n.processingEllipsis);

    List<UiConfig> displayConfigs;
    if (_detail!.uiConfigs.isNotEmpty) {
      displayConfigs = _detail!.uiConfigs;
    } else {
      final audioAssets = _detail!.assets.where((a) => a.isAudio).toList();
      displayConfigs = [
        UiConfig(
          templateId: 'classic_card',
          data: <String, dynamic>{
            'content': _detail!.rawContent,
            'images': _detail!.assets
                .where((a) => a.isImage)
                .map((a) => a.url)
                .toList(),
            'audioUrl': audioAssets.isNotEmpty ? audioAssets.first.url : null,
            'tags': _detail!.tags,
          },
        )
      ];
    }

    final shareWidget = Container(
      width: 400,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Timestamp Header mimicking list view
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Row(
              children: [
                Text(
                  DateFormat('MM/dd HH:mm').format(_detail!.timestamp),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFCBD5E1),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_detail!.address.isNotEmpty &&
                          _detail!.address != 'Unknown') ...[
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _detail!.address.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Card content scaled to fit
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: 390,
                child: Column(
                  children: displayConfigs.map((config) {
                    return NativeCardFactory.build(
                      templateId: config.templateId,
                      data: config.data,
                      title: _detail!.title,
                      status: 'completed',
                      tags: _detail!.tags,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // Build detail-style widget (long image with full content, images, comments)
    final detailWidget = _buildShareDetailWidget(_detail!);

    await ShareService.shareWidgetAsPoster(
      context,
      shareWidget,
      detailContent: detailWidget,
    );
  }

  /// Builds a long-form detail widget for the "detail style" share image.
  /// Mirrors the real detail page layout: images → title → content+tags →
  /// date/location → related memories → comments (insight as first comment).
  Widget _buildShareDetailWidget(CardDetailModel detail) {
    final imageAssets = detail.assets.where((a) => a.isImage).toList();

    return Container(
      width: 400,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Images (same as header media)
          if (imageAssets.isNotEmpty) ...[
            for (final asset in imageAssets) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LocalImage(
                  url: asset.url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],

          const SizedBox(height: 4),

          // 2. Title (same style as detail page)
          if (detail.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                detail.title,
                style: const TextStyle(
                  fontFamily: 'PingFang SC',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                  height: 1.375,
                  letterSpacing: -0.45,
                ),
              ),
            ),

          // 3. Content with inline tags (same as detail page)
          if (detail.rawContent.isNotEmpty || detail.tags.isNotEmpty)
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: detail.rawContent,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF334155),
                      height: 1.6,
                    ),
                  ),
                  if (detail.rawContent.isNotEmpty && detail.tags.isNotEmpty)
                    const TextSpan(text: ' '),
                  ...detail.tags.map((tag) {
                    return TextSpan(
                      text: '#$tag',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.w400,
                        height: 1.25,
                        letterSpacing: 0,
                      ),
                    );
                  }).expand((span) => [span, const TextSpan(text: ' ')]),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // 4. Date and Location (same as detail page)
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                DateFormat('MM-dd').format(detail.timestamp),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF94A3B8),
                ),
              ),
              if (detail.address.isNotEmpty && detail.address != 'Unknown') ...[
                const SizedBox(width: 6),
                Text(
                  detail.address,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),

          // 5. Related Memories (same as detail page)
          if (detail.insight.relatedCards.isNotEmpty) ...[
            _buildShareRelatedMemories(detail.insight.relatedCards),
            const SizedBox(height: 24),
          ],

          // 6. Comments — insight as first comment, then other comments
          //    (mirrors _buildCommentsList logic)
          _buildShareCommentsList(detail),
        ],
      ),
    );
  }

  /// Builds the related memories section for the share detail widget.
  /// Compact vertical list for the long image (horizontal carousel doesn't
  /// work well in a static off-screen capture).
  Widget _buildShareRelatedMemories(List<RelatedCard> cards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header (same as detail page)
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: TimelineTheme.colors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              UserStorage.l10n.relatedMemories,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A5565),
                letterSpacing: -0.15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Render related cards as compact list items
        ...cards.take(5).map((card) {
          final hasImage = card.assets.isNotEmpty && card.assets.first.isImage;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (hasImage) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: LocalImage(
                        url: card.assets.first.url,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        card.date,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// Builds the comments list for the share detail widget.
  /// Insight is rendered as the first "pinned" comment (same as detail page).
  Widget _buildShareCommentsList(CardDetailModel detail) {
    final List<Widget> commentWidgets = [];

    // Insight as first comment (same as _buildCommentsList)
    if (_showInsightText && detail.insight.character != null) {
      commentWidgets.add(
        _buildShareSingleComment(
          characterId: detail.insight.characterId,
          avatar: detail.insight.character!.avatar,
          name: detail.insight.character!.name,
          content: detail.insight.text,
          time: DateFormat('MM-dd').format(detail.timestamp),
          isAuthor: true,
        ),
      );
    }

    // Other comments
    for (var comment in detail.insight.comments) {
      final isUser = !comment.isAi;
      final commentName =
          isUser ? _userName : (comment.character?.name ?? 'AI');
      commentWidgets.add(
        _buildShareSingleComment(
          characterId: isUser ? 'user' : comment.character?.id,
          avatar: isUser ? _userAvatar : comment.character?.avatar,
          name: commentName,
          content: comment.content,
          time: DateFormat('MM-dd').format(
            DateTime.fromMillisecondsSinceEpoch(comment.timestamp * 1000),
          ),
          isAi: comment.isAi,
          replyToName: comment.replyToName,
        ),
      );
    }

    return Column(
      children: commentWidgets
          .map((w) =>
              Padding(padding: const EdgeInsets.only(bottom: 24), child: w))
          .toList(),
    );
  }

  /// Builds a single comment for the share detail widget.
  /// Static version of _buildSingleComment (no tap handlers, no navigation).
  Widget _buildShareSingleComment({
    String? characterId,
    String? avatar,
    required String name,
    required String content,
    required String time,
    bool isAuthor = false,
    bool isAi = false,
    String? replyToName,
  }) {
    // Avatar logic — same as _buildSingleComment
    Widget avatarWidget;
    final isMemexSystem = (characterId == null || characterId == '0') && !isAi;
    final isUserComment = characterId == 'user';

    if (isUserComment) {
      avatarWidget = DiceBearAvatar(
        seed: (avatar != null && avatar.isNotEmpty) ? avatar : name,
        size: 36,
        backgroundColor: const Color(0xFFEEF2FF),
      );
    } else if (isMemexSystem || (characterId == null || characterId == '0')) {
      avatarWidget = CircleAvatar(
        radius: 18,
        backgroundColor: Colors.white,
        child: ClipOval(
          child: Image.asset(
            'assets/icon.png',
            width: 36,
            height: 36,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      final seed =
          (avatar != null && avatar.isNotEmpty) ? avatar : 'companion_$name';
      avatarWidget = DiceBearAvatar(
        seed: seed,
        size: 36,
        backgroundColor: const Color(0xFFEEF2FF),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        avatarWidget,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name row with optional reply chain indicator
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 0,
                children: [
                  Text(name, style: AppTextStyles.commentName),
                  if (replyToName != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.subdirectory_arrow_right_rounded,
                          size: 14, color: AppColors.textTertiary),
                    ),
                    Text(
                      replyToName,
                      style: AppTextStyles.commentName.copyWith(
                        color: AppColors.primary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              // Use plain Text for share (MarkdownBody may not render well offscreen)
              Text(
                content,
                style: AppTextStyles.commentContent,
              ),
              const SizedBox(height: 6),
              Text(time, style: AppTextStyles.commentDate),
            ],
          ),
        ),
      ],
    );
  }

  void _showInputModal(String cardId) {
    final replyId = _replyToCommentId;
    final replyName = _replyToCommentName;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: _CommentInputWidget(
            cardId: cardId,
            replyToId: replyId,
            replyToName: replyName,
            onCommentPosted: () {
              Navigator.pop(context);
              _fetchDetail();
            },
            autofocus: true,
          ),
        ),
      ),
    ).whenComplete(() {
      // Clear reply state when modal is dismissed
      if (mounted) {
        setState(() {
          _replyToCommentId = null;
          _replyToCommentName = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: AgentLogoLoading()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text(UserStorage.l10n.detail)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchDetail,
                child: Text(UserStorage.l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_detail == null) {
      return Scaffold(
        body: Center(child: Text(UserStorage.l10n.cardDetailNotFound)),
      );
    }

    final detail = _detail!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Navigation Buttons
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 9,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.chevron_left,
                              size: 22, color: Color(0xFF99A1AF)),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _shareCard,
                          child: SvgPicture.asset(
                            'assets/icons/btn_share.svg',
                            width: 36,
                            height: 36,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: _showChatDialog,
                          child: SizedBox(
                            width: 36,
                            height: 36,
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/icons/chat_add.svg',
                                width: 22,
                                height: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: _deleteCard,
                          child: SvgPicture.asset(
                            'assets/icons/btn_delete.svg',
                            width: 36,
                            height: 36,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // 1. Media Area (Assets or Text-as-Image)
                          SliverToBoxAdapter(
                            child: _buildHeaderMedia(context, detail),
                          ),

                          // 2. Content Area
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  // Title
                                  if (detail.title.isNotEmpty)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: Text(
                                        detail.title,
                                        style: const TextStyle(
                                          fontFamily: 'PingFang SC',
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF334155),
                                          height: 1.375, // 33/24
                                          letterSpacing: -0.45,
                                        ),
                                      ),
                                    ),

                                  // Content with tags
                                  if (detail.rawContent.isNotEmpty ||
                                      detail.tags.isNotEmpty)
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: detail.rawContent,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF334155),
                                              height: 1.6,
                                            ),
                                          ),
                                          if (detail.rawContent.isNotEmpty &&
                                              detail.tags.isNotEmpty)
                                            const TextSpan(text: ' '),
                                          ...detail.tags.map((tag) {
                                            return TextSpan(
                                              text: '#$tag',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF6366F1),
                                                fontWeight: FontWeight.w400,
                                                height: 1.25,
                                                letterSpacing: 0,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  Navigator.pop(context, {
                                                    'action': 'filter_tag',
                                                    'tag': tag
                                                  });
                                                },
                                            );
                                          }).expand((span) => [
                                                span,
                                                const TextSpan(text: ' '),
                                              ]),
                                        ],
                                      ),
                                    )
                                  else if (detail.tags.isNotEmpty)
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: detail.tags.map((tag) {
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context, {
                                              'action': 'filter_tag',
                                              'tag': tag
                                            });
                                          },
                                          child: Text(
                                            '#$tag',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF6366F1),
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),

                                  const SizedBox(height: 16),

                                  // Date and Location
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: _openCalendar,
                                        onLongPress: _editTime,
                                        child: Text(
                                          DateFormat('MM-dd')
                                              .format(detail.timestamp),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ),
                                      if (detail.address.isNotEmpty) ...[
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onLongPress: _editLocation,
                                          child: Text(
                                            detail.address,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF94A3B8),
                                            ),
                                            maxLines: null,
                                            softWrap: true,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),

                                  const SizedBox(height: 24),
                                  const Divider(
                                      height: 1, color: Color(0xFFE2E8F0)),
                                  const SizedBox(height: 16),

                                  // Related Records
                                  // Related Records Bar Removed

                                  // Comments Area
                                  // Related Records Trigger (replacing comments count)
                                  // AI Related Memories Section
                                  if (detail
                                      .insight.relatedCards.isNotEmpty) ...[
                                    _buildRelatedMemoriesSection(
                                        context, detail.insight.relatedCards),
                                    const SizedBox(height: 24),
                                  ],
                                  const SizedBox(height: 16),

                                  // Display Comments
                                  _buildCommentsList(detail),

                                  const SizedBox(
                                      height:
                                          100), // Bottom padding for fixed bar
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                _buildBottomBar(detail),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderMedia(BuildContext context, CardDetailModel detail) {
    if (detail.assets.isNotEmpty) {
      final screenHeight = MediaQuery.of(context).size.height;
      final topPadding = MediaQuery.of(context).padding.top;
      final containerWidth = MediaQuery.of(context).size.width -
          32; // minus horizontal padding 16*2
      // Max: screen - status bar - nav bar(52) - bottom input bar(76) - title area(~60)
      final maxHeight = screenHeight - topPadding - 52 - 76 - 60;
      // Calculate height from first image aspect ratio
      final double imageHeight;
      if (_firstImageAspectRatio != null && _firstImageAspectRatio! > 0) {
        final naturalHeight = containerWidth / _firstImageAspectRatio!;
        imageHeight = naturalHeight.clamp(150.0, maxHeight);
      } else {
        imageHeight = (screenHeight * 0.55).clamp(150.0, maxHeight);
      }

      // Asset Gallery
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SizedBox(
              height: imageHeight,
              child: GestureDetector(
                onTap: _showFullScreenGallery,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: PageView.builder(
                    itemCount: detail.assets.length,
                    onPageChanged: (index) {
                      setState(() => _currentAssetIndex = index);
                    },
                    itemBuilder: (context, index) {
                      final asset = detail.assets[index];
                      if (asset.isImage) {
                        return Container(
                          color: const Color(0xFFF7F8FA),
                          child: LocalImage(
                            url: asset.url,
                            fit: BoxFit.contain,
                          ),
                        );
                      } else if (asset.isAudio) {
                        return Container(
                          color: const Color(0xFF0A0A0A),
                          child: Center(
                            child: AudioPlayerWidget(url: asset.url),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ),
            ),
            if (detail.assets.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(detail.assets.length, (index) {
                    final isSelected = _currentAssetIndex == index;
                    return Container(
                      width: isSelected ? 7 : 5,
                      height: isSelected ? 7 : 5,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? const Color(0xFF5B6CFF)
                            : const Color(0xFF99A1AF),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      );
    } else {
      // No assets — skip the large header, content area handles everything
      return const SizedBox.shrink();
    }
  }

  Widget _buildCommentsList(CardDetailModel detail) {
    final List<Widget> commentWidgets = [];

    // Add Insight as the first "Pinned" comment/description (if enabled)
    if (_showInsightText && detail.insight.character != null) {
      commentWidgets.add(
        _buildSingleComment(
          characterId: detail.insight.characterId,
          avatar: detail.insight.character!.avatar,
          name: detail.insight.character!.name,
          content: detail.insight.text,
          isAuthor: true,
          time: DateFormat('MM-dd').format(detail.timestamp),
        ),
      );
    }

    // Build a lookup map for comment names (for reply chain display)
    final commentNameMap = <String, String>{};
    // Add insight character as a possible reply target
    if (detail.insight.character != null) {
      commentNameMap['insight'] = detail.insight.character!.name;
    }
    for (var comment in detail.insight.comments) {
      final isUser = !comment.isAi;
      final name = isUser ? _userName : (comment.character?.name ?? 'AI');
      commentNameMap[comment.id] = name;
    }

    // Add other comments
    for (var comment in detail.insight.comments) {
      final isUser = !comment.isAi;
      final commentName =
          isUser ? _userName : (comment.character?.name ?? 'AI');
      commentWidgets.add(
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Tap a comment to reply to it
              setState(() {
                _replyToCommentId = comment.id;
                _replyToCommentName = commentName;
              });
              _showInputModal(detail.id);
            },
            borderRadius: BorderRadius.circular(8),
            splashColor: AppColors.primary.withValues(alpha: 0.06),
            highlightColor: AppColors.primary.withValues(alpha: 0.03),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: _buildSingleComment(
                characterId: isUser ? 'user' : comment.character?.id,
                avatar: isUser ? _userAvatar : comment.character?.avatar,
                name: commentName,
                content: comment.content,
                time: DateFormat('MM-dd').format(
                    DateTime.fromMillisecondsSinceEpoch(
                        comment.timestamp * 1000)),
                isAi: comment.isAi,
                replyToName: comment.replyToName,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: commentWidgets
          .map((w) =>
              Padding(padding: const EdgeInsets.only(bottom: 24), child: w))
          .toList(),
    );
  }

  Widget _buildSingleComment({
    String? characterId,
    String? avatar,
    required String name,
    required String content,
    required String time,
    bool isAuthor = false,
    bool isAi = false,
    String? replyToName,
  }) {
    // Determine avatar widget:
    // - characterId "0" or null = Memex system → use logo
    // - characterId "user" = user comment → use DiceBear with user avatar
    // - Other characters → use DiceBear with character avatar
    Widget avatarWidget;
    final isMemexSystem = (characterId == null || characterId == '0') && !isAi;
    final isUserComment = characterId == 'user';

    if (isUserComment) {
      // User's own DiceBear avatar
      avatarWidget = DiceBearAvatar(
        seed: (avatar != null && avatar.isNotEmpty) ? avatar : name,
        size: 36,
        backgroundColor: const Color(0xFFEEF2FF),
      );
    } else if (isMemexSystem || (characterId == null || characterId == '0')) {
      // Memex logo
      avatarWidget = CircleAvatar(
        radius: 18,
        backgroundColor: Colors.white,
        child: ClipOval(
          child: Image.asset(
            'assets/icon.png',
            width: 36,
            height: 36,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      // Character DiceBear avatar — use avatar field if set, fallback to name
      final seed =
          (avatar != null && avatar.isNotEmpty) ? avatar : 'companion_$name';
      avatarWidget = DiceBearAvatar(
        seed: seed,
        size: 36,
        backgroundColor: const Color(0xFFEEF2FF),
      );
    }

    // Wrap avatar with tap-to-chat for AI characters
    final bool isCharacterAvatar = !isUserComment &&
        !isMemexSystem &&
        characterId != null &&
        characterId != '0';
    final tappableAvatar = isCharacterAvatar
        ? GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PersonaChatScreen(characterId: characterId),
                ),
              );
            },
            child: avatarWidget,
          )
        : avatarWidget;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        tappableAvatar,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name row with optional reply chain indicator
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 0,
                children: [
                  Text(name, style: AppTextStyles.commentName),
                  if (replyToName != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.subdirectory_arrow_right_rounded,
                          size: 14, color: AppColors.textTertiary),
                    ),
                    Text(
                      replyToName,
                      style: AppTextStyles.commentName.copyWith(
                        color: AppColors.primary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              if (isAuthor || isAi)
                MarkdownBody(
                  data: content,
                  softLineBreak: true,
                  styleSheet: MarkdownStyleSheet(
                    p: AppTextStyles.commentContent,
                    strong: AppTextStyles.commentContent.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    em: const TextStyle(fontStyle: FontStyle.italic),
                    listBullet: const TextStyle(color: AppColors.primary),
                    code: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      backgroundColor: AppColors.background,
                      fontFamily: 'monospace',
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
              else
                Text(content, style: AppTextStyles.commentContent),
              const SizedBox(height: 6),
              Text(time, style: AppTextStyles.commentDate),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(CardDetailModel detail) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
            16, 8, 16, 32), // Safe area handled by bottom padding
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border(
              top: BorderSide(
                  color: AppColors.textTertiary.withValues(alpha: 0.2))),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _showInputModal(detail.id),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 16, color: AppColors.textTertiary),
                      const SizedBox(width: 8),
                      Text(
                        UserStorage.l10n.saySomething,
                        style: TextStyle(
                            fontSize: 14, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedMemoriesSection(
      BuildContext context, List<RelatedCard> cards) {
    if (cards.isEmpty) return const SizedBox.shrink();

    // Calculate how many cards fit on screen
    // card width 170 + separator 12, horizontal padding 20 each side
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - 40; // minus left+right padding
    final visibleCount = (availableWidth + 12) ~/
        (170 + 12); // +12 because last card has no separator
    final hasOverflow = cards.length > visibleCount;

    return Container(
      width: double.infinity,
      color: TimelineTheme.colors.backgroundSecondary,
      padding: const EdgeInsets.only(top: 24, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: TimelineTheme.colors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  UserStorage.l10n.relatedMemories,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A5565),
                    letterSpacing: -0.15,
                  ),
                ),
                const Spacer(),
                if (hasOverflow)
                  GestureDetector(
                    onTap: () => _showRelatedCards(context, cards),
                    child: Row(
                      children: [
                        Text(
                          UserStorage.l10n.viewMore,
                          style: TimelineTheme.typography.label.copyWith(
                            color: TimelineTheme.colors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: TimelineTheme.colors.textSecondary,
                        ),
                      ],
                    ),
                  )
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Horizontal Vertical-Poster Carousel
          SizedBox(
            height: 270,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: cards.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final card = cards[index];
                return _buildRichRelatedCardItem(context, card);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRichRelatedCardItem(BuildContext context, RelatedCard card) {
    final hasImage = card.assets.isNotEmpty && card.assets.first.isImage;

    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: TimelineTheme.colors.textTertiary.withOpacity(0.05),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TimelineCardDetailScreen(cardId: card.id),
              ),
            );
          },
          child: hasImage
              ? _buildImageRelatedCard(card)
              : _buildTextRelatedCard(card),
        ),
      ),
    );
  }

  /// Related card with image: image top + compact title/date bottom
  Widget _buildImageRelatedCard(RelatedCard card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: TimelineTheme.colors.backgroundSecondary,
              image: DecorationImage(
                image: LocalImage.provider(card.assets.first.url),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Container(
          height: 85,
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                card.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TimelineTheme.typography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
              Row(
                children: [
                  if (card.rawContent.isNotEmpty)
                    Expanded(
                      child: Text(
                        card.rawContent,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TimelineTheme.typography.small.copyWith(
                          color: TimelineTheme.colors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  if (card.rawContent.isNotEmpty) const SizedBox(width: 4),
                  Text(
                    card.date.substring(5),
                    style: TimelineTheme.typography.small.copyWith(
                      color: TimelineTheme.colors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Text-only related card: same layout as image card, top area shows text content instead of image
  Widget _buildTextRelatedCard(RelatedCard card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top area: text content replacing image, with quote decorations
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: const Color(0xFFF8FAFC),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Opening quote
                const Text(
                  '\u275D',
                  style: TextStyle(
                    fontSize: 36,
                    color: Color(0x0A334155),
                    height: 1,
                  ),
                ),
                // Text content, vertically centered in remaining space
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const style = TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF64748B),
                        height: 1.6,
                      );
                      final tp = TextPainter(
                        text: TextSpan(text: 'A', style: style),
                        textDirection: ui.TextDirection.ltr,
                      )..layout();
                      final maxLines = (constraints.maxHeight / tp.height)
                          .floor()
                          .clamp(1, 999);
                      return Center(
                        child: Text(
                          card.rawContent,
                          maxLines: maxLines,
                          overflow: TextOverflow.ellipsis,
                          style: style,
                        ),
                      );
                    },
                  ),
                ),
                // Closing quote
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '\u275E',
                    style: TextStyle(
                      fontSize: 36,
                      color: Color(0x0A334155),
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bottom area: same structure as image card, rawContent already shown above
        Container(
          height: 85,
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                card.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TimelineTheme.typography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
              Row(
                children: [
                  Text(
                    card.date.substring(5),
                    style: TimelineTheme.typography.small.copyWith(
                      color: TimelineTheme.colors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showRelatedCards(BuildContext context, List<RelatedCard> cards) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Center(
                child: Text(
                  UserStorage.l10n.relatedRecords,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TimelineCardDetailScreen(cardId: card.id),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  card.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  card.date,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              size: 14, color: Color(0xFFCBD5E1)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenGallery extends StatefulWidget {
  final List<AssetData> assets;
  final int initialIndex;

  const _FullScreenGallery({
    required this.assets,
    required this.initialIndex,
  });

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              final asset = widget.assets[index];
              if (asset.isImage) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: LocalImage.provider(asset.url),
                  initialScale: PhotoViewComputedScale.contained,
                  heroAttributes: PhotoViewHeroAttributes(tag: asset.url),
                );
              } else {
                return PhotoViewGalleryPageOptions.customChild(
                  child: Container(
                    color: Colors.black,
                    child: Center(
                      child: AudioPlayerWidget(url: asset.url),
                    ),
                  ),
                  initialScale: PhotoViewComputedScale.contained,
                  heroAttributes: PhotoViewHeroAttributes(tag: asset.url),
                );
              }
            },
            itemCount: widget.assets.length,
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          Positioned(
            top: 50,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),
          if (widget.assets.length > 1)
            Positioned(
              top: 50,
              right: 0,
              left: 0,
              child: Center(
                child: Text(
                  '${_currentIndex + 1}/${widget.assets.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CommentInputWidget extends StatefulWidget {
  final String cardId;
  final VoidCallback onCommentPosted;
  final bool autofocus;
  final String? replyToId;
  final String? replyToName;

  const _CommentInputWidget({
    required this.cardId,
    required this.onCommentPosted,
    this.autofocus = false,
    this.replyToId,
    this.replyToName,
  });

  @override
  State<_CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<_CommentInputWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _isPosting) return;

    setState(() {
      _isPosting = true;
    });

    try {
      final memexRouter = MemexRouter();
      await memexRouter.postComment(
        widget.cardId,
        content,
        replyToId: widget.replyToId,
      );

      _controller.clear();
      widget.onCommentPosted();

      if (mounted) {
        ToastHelper.showSuccess(context, UserStorage.l10n.replySent);
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Reply-to banner (WeChat-style)
        if (widget.replyToName != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.reply_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    UserStorage.l10n.replyTo(widget.replyToName!),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        // Input field
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius:
                BorderRadius.circular(widget.replyToName != null ? 0 : 20),
            border: widget.replyToName != null
                ? null
                : Border.all(
                    color: AppColors.primary.withValues(alpha: 0.0),
                    width: 1.5,
                  ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: widget.autofocus,
                  decoration: InputDecoration(
                    hintText: widget.replyToName != null
                        ? UserStorage.l10n.replyTo(widget.replyToName!)
                        : UserStorage.l10n.saySomething,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    hintStyle: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 14,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _postComment(),
                ),
              ),
              IconButton(
                icon: _isPosting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                onPressed: _isPosting ? null : _postComment,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
