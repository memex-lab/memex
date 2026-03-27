import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter/material.dart';
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
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:memex/ui/core/cards/style/timeline_theme.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';
import 'package:memex/utils/share_service.dart';
import 'package:memex/ui/core/cards/native_card_factory.dart';

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
  Timer? _pollingTimer;
  static const Duration _pollingInterval =
      Duration(seconds: 5); // poll every 5s

  @override
  void initState() {
    super.initState();
    _memexRouter = MemexRouter();
    _fetchDetail();
    _startPollingIfNeeded();
  }

  @override
  void dispose() {
    _stopPolling();
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
    // check polling status after setState
    _startPollingIfNeeded();
  }

  /// Check if there is a pending comment (last comment is user, no follow-up AI reply yet)
  bool get _hasPendingComment {
    if (_detail == null) return false;
    final comments = _detail!.insight.comments;
    if (comments.isEmpty) return false;

    // check if last comment is from user
    final lastComment = comments.last;
    return !lastComment.isAi;
  }

  void _startPollingIfNeeded() {
    if (_hasPendingComment && _pollingTimer == null) {
      _startPolling();
    } else if (!_hasPendingComment && _pollingTimer != null) {
      _stopPolling();
    }
  }

  void _startPolling() {
    if (_pollingTimer != null) {
      return;
    }

    _pollingTimer = Timer.periodic(_pollingInterval, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _fetchDetail();
    });
  }

  void _stopPolling() {
    if (_pollingTimer != null) {
      _pollingTimer?.cancel();
      _pollingTimer = null;
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
      {double? cost}) {
    // Extract values for calculation
    final prompt = stats['Prompt Tokens'] ?? 0;
    final cached = stats['Cached Tokens'] ?? 0;

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
            if (prompt == 0) {
              valueStr = '0.0%';
            } else {
              final rate = (cached / prompt) * 100;
              valueStr = '${rate.toStringAsFixed(1)}%';
            }
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

    await ShareService.shareWidgetAsPoster(context, shareWidget);
  }

  void _showInputModal(String cardId) {
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
            onCommentPosted: () {
              Navigator.pop(context);
              _fetchDetail();
            },
            autofocus: true,
          ),
        ),
      ),
    );
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
                    _RoundIconButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                    Row(
                      children: [
                        _RoundIconButton(
                          icon: Icons.ios_share,
                          onTap: _shareCard,
                        ),
                        const SizedBox(width: 8),
                        _RoundIconButton(
                          icon: Icons.chat_bubble_outline,
                          onTap: _showChatDialog,
                        ),
                        const SizedBox(width: 8),
                        _RoundIconButton(
                          icon: Icons.delete_outline,
                          onTap: _deleteCard,
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
      // Asset Gallery
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
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
                            fit: BoxFit.cover,
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

    // Add Insight as the first "Pinned" comment/description
    if (detail.insight.character != null) {
      commentWidgets.add(
        _buildSingleComment(
          avatar: detail.insight.character!.avatar,
          name: detail.insight.character!.name,
          content: detail.insight.text,
          isAuthor: true,
          time: DateFormat('MM-dd').format(detail.timestamp),
        ),
      );
    }

    // Add other comments
    for (var comment in detail.insight.comments) {
      commentWidgets.add(
        _buildSingleComment(
          avatar: comment.character?.avatar,
          name: comment.isAi ? (comment.character?.name ?? 'AI') : 'User',
          content: comment.content,
          time: DateFormat('MM-dd').format(
              DateTime.fromMillisecondsSinceEpoch(comment.timestamp * 1000)),
          isAi: comment.isAi,
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
    String? avatar,
    required String name,
    required String content,
    required String time,
    bool isAuthor = false,
    bool isAi = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: avatar != null && avatar.isNotEmpty
              ? LocalImage.provider(avatar)
              : null,
          backgroundColor:
              isAuthor ? const Color(0xFF8B5CF6) : Colors.grey[200],
          child: avatar == null || avatar.isEmpty
              ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: isAuthor ? Colors.white : Colors.grey[600],
                    fontSize: 14,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0A0A0A),
                      letterSpacing: -0.15,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF334155),
                  height: 1.43,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF94A3B8),
                      height: 1.43,
                      letterSpacing: -0.15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Like button removed
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
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
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
                    color: const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined,
                          size: 16, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 8),
                      Text(
                        UserStorage.l10n.saySomething,
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF94A3B8)),
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

    return Container(
      width: double.infinity,
      color:
          TimelineTheme.colors.backgroundSecondary, // Using semantic background
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
                  UserStorage.l10n.relatedMemories, // Semantic and soft
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A5565),
                    letterSpacing: -0.15,
                  ),
                ),
                const Spacer(),
                if (cards.length > 3)
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
            height: 270, // Reduced height to minimize whitespace
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
    return Container(
      width: 170, // Slightly narrower
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Media / Visual Area (Dominant)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: TimelineTheme.colors.backgroundSecondary,
                    image: card.assets.isNotEmpty && card.assets.first.isImage
                        ? DecorationImage(
                            image: LocalImage.provider(card.assets.first.url),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: card.assets.isEmpty || !card.assets.first.isImage
                      ? Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 28,
                            color: TimelineTheme.colors.textTertiary
                                .withOpacity(0.3),
                          ),
                        )
                      : null,
                ),
              ),

              // Content Area (Compact)
              Container(
                height: 85, // Fixed compact height for text area
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      card.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TimelineTheme.typography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13, // Slightly smaller for density
                        height: 1.3,
                      ),
                    ),

                    // Footer: Content Preview or Date
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
                        if (card.rawContent.isNotEmpty)
                          const SizedBox(width: 4),

                        // Date always shown but compact
                        Text(
                          card.date.substring(5), // MM-DD
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
          ),
        ),
      ),
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

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(
          icon,
          size: 20,
          color: const Color(0xFF4A5565),
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

  const _CommentInputWidget({
    required this.cardId,
    required this.onCommentPosted,
    this.autofocus = false,
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
      await memexRouter.postComment(widget.cardId, content);

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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: widget.autofocus,
              decoration: InputDecoration(
                hintText: UserStorage.l10n.saySomething,
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintStyle: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                ),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1E293B),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _postComment(),
            ),
          ),
          IconButton(
            icon: _isPosting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                    ),
                  )
                : const Icon(
                    Icons.send,
                    color: Color(0xFF6366F1),
                    size: 20,
                  ),
            onPressed: _isPosting ? null : _postComment,
          ),
        ],
      ),
    );
  }
}
