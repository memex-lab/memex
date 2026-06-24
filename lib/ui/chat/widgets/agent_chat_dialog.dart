import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:logging/logging.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:memex/l10n/app_localizations_ext.dart';
import 'package:memex/agent/run_mode/agent_action_approval_service.dart';
import 'package:memex/agent/run_mode/agent_run_mode.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/model/chat_artifact.dart';
import 'package:memex/data/model/chat_events.dart';
import 'package:memex/data/services/demo_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/input_draft_service.dart';
import 'package:memex/ui/core/widgets/html_webview_card.dart';
import 'package:memex/ui/timeline/widgets/timeline_card_detail_screen.dart';
import 'package:memex/data/services/photo_suggestion_service.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/result.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/utils/token_usage_utils.dart';
import 'package:memex/utils/time_context.dart';

// --- Display Models ---

abstract class ChatDisplayItem {
  DateTime? get timestamp => null;
}

class UserMessageItem extends ChatDisplayItem {
  final String text;
  final List<Map<String, String>>? refs;
  final List<String> imagePaths;
  @override
  final DateTime? timestamp;
  UserMessageItem(
    this.text, {
    this.refs,
    this.imagePaths = const [],
    this.timestamp,
  });
}

class AIMessageItem extends ChatDisplayItem {
  String text;
  bool isStreaming;
  @override
  DateTime? timestamp;
  AIMessageItem(
    this.text, {
    this.isStreaming = false,
    this.timestamp,
  });
}

class ThinkingItem extends ChatDisplayItem {
  String text;
  bool isExpanded;
  bool isFinished;
  ThinkingItem(this.text, {this.isExpanded = true, this.isFinished = false});
}

class ToolCallItem extends ChatDisplayItem {
  final String id;
  ChatTraceKind kind;
  final String toolName;
  String args;
  final DateTime startedAt;
  final List<ToolCallItem> childToolCalls = [];
  String? result;
  bool isError;
  bool isExpanded;
  DateTime? completedAt;
  Map<String, dynamic>? metadata;
  String? label;
  String? status;

  ToolCallItem(
    this.id,
    this.toolName,
    this.args, {
    this.kind = ChatTraceKind.tool,
    this.label,
    this.result,
    this.isError = false,
    this.isExpanded = false,
  }) : startedAt = DateTime.now();

  bool get isRunning => result == null;

  bool get isDelegate => kind == ChatTraceKind.delegate;

  Iterable<ToolCallItem> get selfAndDescendants sync* {
    yield this;
    for (final child in childToolCalls) {
      yield* child.selfAndDescendants;
    }
  }

  bool get hasRunningTrace =>
      isRunning || childToolCalls.any((child) => child.hasRunningTrace);

  bool get hasTraceError =>
      isError || childToolCalls.any((child) => child.hasTraceError);

  int get childTraceCount => childToolCalls.fold<int>(
        childToolCalls.length,
        (total, child) => total + child.childTraceCount,
      );

  Duration? get duration {
    final finishedAt = completedAt;
    if (finishedAt == null) return null;
    return finishedAt.difference(startedAt);
  }
}

class ErrorItem extends ChatDisplayItem {
  final String error;
  @override
  final DateTime timestamp;
  ErrorItem(this.error, {DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
}

/// Inline preview of something the agent produced (record, card, document).
class ArtifactItem extends ChatDisplayItem {
  final ChatArtifact artifact;

  /// Raw HTML captured from the producing tool call args, for mini previews
  /// of dynamic HTML cards.
  final String? html;

  ArtifactItem(this.artifact, {this.html});
}

/// Inline ask-first approval card for one pending mutating tool call.
class ApprovalRequestItem extends ChatDisplayItem {
  final AgentActionApprovalRequest request;
  String status; // 'pending' | 'approved' | 'denied'
  ApprovalRequestItem(this.request) : status = 'pending';
}

class ProcessItem extends ChatDisplayItem {
  final List<ChatDisplayItem> children = [];
  @override
  final DateTime timestamp;
  bool isExpanded;
  bool isFinished;
  ProcessItem({
    this.isExpanded = false,
    this.isFinished = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  List<ToolCallItem> get toolCalls =>
      children.whereType<ToolCallItem>().toList();

  List<ToolCallItem> get allTraceCalls =>
      toolCalls.expand((tool) => tool.selfAndDescendants).toList();

  List<ThinkingItem> get thinkingItems =>
      children.whereType<ThinkingItem>().toList();

  bool get hasRunningTool => toolCalls.any((tool) => tool.hasRunningTrace);

  bool get hasToolError => toolCalls.any((tool) => tool.hasTraceError);
}

const double _agentChatSheetHeightFactor = 0.75;
const int _agentChatHistoryPageSize = 10;
const Duration _agentChatKeyboardShowAnimationDuration =
    Duration(milliseconds: 220);
const Duration _agentChatKeyboardHideAnimationDuration = Duration.zero;
const BorderRadius _agentChatSheetBorderRadius = BorderRadius.vertical(
  top: Radius.circular(32),
);

@visibleForTesting
double resolveAgentChatDialogHeight(
  Size viewportSize, {
  required bool isFullScreen,
  double keyboardInset = 0,
}) {
  final baseHeight = isFullScreen
      ? viewportSize.height
      : viewportSize.height * _agentChatSheetHeightFactor;
  if (keyboardInset <= 0) return baseHeight;

  final availableHeight = math.max(0.0, viewportSize.height - keyboardInset);
  if (availableHeight <= 0) return baseHeight;
  return math.min(baseHeight, availableHeight);
}

@visibleForTesting
BorderRadius resolveAgentChatDialogBorderRadius({required bool isFullScreen}) {
  return isFullScreen ? BorderRadius.zero : _agentChatSheetBorderRadius;
}

@visibleForTesting
double resolveSuperAgentInputBottomInset({
  required double keyboardInset,
  required bool inputFocused,
  required bool isStreaming,
}) {
  return keyboardInset;
}

@visibleForTesting
bool shouldCreateAIMessageForResponseChunk({
  required String text,
  required bool isDone,
}) {
  return !(isDone && text.isEmpty);
}

@visibleForTesting
int superAgentItemIndexForReversedList({
  required int listIndex,
  required int itemCount,
  required int extraItems,
}) {
  return itemCount - 1 - (listIndex - extraItems);
}

@visibleForTesting
String formatSuperAgentTimeDivider(DateTime date) {
  final now = DateTime.now();
  final locale = UserStorage.l10n.localeName;
  final time = DateFormat('HH:mm', locale).format(date);

  if (_isSameDay(date, now)) {
    return time;
  }

  if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
    return '${UserStorage.l10n.yesterday} $time';
  }

  final daysAgo = DateTime(now.year, now.month, now.day)
      .difference(DateTime(date.year, date.month, date.day))
      .inDays;

  if (daysAgo < 7) {
    final weekday = DateFormat.E(locale).format(date);
    return '$weekday $time';
  }

  if (date.year == now.year) {
    return '${DateFormat.MMMd(locale).format(date)} $time';
  }

  return '${DateFormat.yMMMd(locale).format(date)} $time';
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

@visibleForTesting
String formatSuperAgentTokenUsage(ChatTokenUsageEvent item) {
  final cacheRate = TokenUsageUtils.formatCacheRateFromAggregated(
    effectivePromptTokens: item.effectivePromptTokens,
    cachedTokens: item.cachedTokensForRate,
  );
  return 'Tokens: ${item.totalTokens} '
      '(P:${item.promptTokens} C:${item.completionTokens} Cache:$cacheRate)';
}

@visibleForTesting
Duration resolveSuperAgentKeyboardInsetAnimationDuration({
  required double previousInset,
  required double nextInset,
}) {
  return nextInset < previousInset
      ? _agentChatKeyboardHideAnimationDuration
      : _agentChatKeyboardShowAnimationDuration;
}

@visibleForTesting
bool shouldShowSuperAgentPhotoSuggestions({
  required bool isLoading,
  required bool hasSuggestions,
}) {
  return isLoading || hasSuggestions;
}

@visibleForTesting
bool shouldQueueSuperAgentSend({
  required bool isStreaming,
  required bool hasSessionId,
  required bool hasChatSubscription,
}) {
  return isStreaming && hasSessionId && hasChatSubscription;
}

@visibleForTesting
Map<String, String> initialOriginalFilenamesForSelectedImages(
  List<XFile> images,
  Map<String, String> provided,
) {
  if (images.isEmpty || provided.isEmpty) return const <String, String>{};

  final selectedPaths = images.map((image) => image.path).toSet();
  return {
    for (final entry in provided.entries)
      if (selectedPaths.contains(entry.key) && entry.value.trim().isNotEmpty)
        entry.key: entry.value,
  };
}

@visibleForTesting
Key? superAgentDemoPublishTargetKey(DemoStep? currentStep) {
  return currentStep == DemoStep.tapSend
      ? DemoService.instance.sendButtonKey
      : null;
}

/// Agent Chat Dialog with Real-time Event Streaming
class AgentChatDialog extends StatefulWidget {
  final String? initialSessionId;
  final String? sceneId;
  final List<Map<String, String>>? initialRefs;
  final String? initialDraftText;
  final List<XFile> initialImages;
  final Map<String, String> initialImageOriginalFilenames;

  const AgentChatDialog({
    super.key,
    this.initialSessionId,
    this.sceneId,
    this.initialRefs,
    this.initialDraftText,
    this.initialImages = const [],
    this.initialImageOriginalFilenames = const {},
  });

  @override
  State<AgentChatDialog> createState() => _AgentChatDialogState();
}

class _AgentChatDialogState extends State<AgentChatDialog>
    with SingleTickerProviderStateMixin {
  final Logger _logger = getLogger('AgentChatDialog');

  // Services
  MemexRouter? _memexRouter;
  MemexRouter get _router => _memexRouter ??= MemexRouter();
  final InputDraftService _draftService = InputDraftService.instance;

  // State
  List<ChatDisplayItem> _items = [];
  String? _currentSessionId;
  bool _isLoading = false;
  bool _isLoadingMoreHistory = false;
  bool _hasMoreHistory = false;
  int _loadedHistoryMessageCount = 0;
  bool _isStreaming = false;
  bool _isLoadingAgent = false;
  bool _isRefreshingAgentState = false;
  bool _nextResponseStartsNewMessage = true;
  ChatTokenUsageEvent? _lastTokenUsage;
  bool _isFullScreen = false;
  AgentRunMode _runMode = AgentRunMode.auto;
  StreamSubscription<AgentActionApprovalRequest>? _approvalSubscription;

  // Controllers
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _selectedImages = [];
  final Map<String, String> _originalFilenames = {};
  StreamSubscription<ChatEvent>? _chatSubscription;
  final List<StreamSubscription<ChatEvent>> _queuedSendSubscriptions = [];
  Timer? _draftSaveDebounce;
  bool _isApplyingDraft = false;
  bool _isLoadingPhotoSuggestions = false;
  List<List<EnhancedPhoto>> _photoSuggestionClusters = [];
  double _lastKeyboardBottomOffset = 0;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _contextSent = false;

  @override
  void initState() {
    super.initState();
    _currentSessionId = widget.initialSessionId;
    final initialDraftText = widget.initialDraftText;
    if (initialDraftText != null && initialDraftText.isNotEmpty) {
      _messageController.text = initialDraftText;
      _messageController.selection = TextSelection.collapsed(
        offset: initialDraftText.length,
      );
    }
    _messageController.addListener(_handleDraftTextChanged);
    _scrollController.addListener(_handleHistoryScroll);
    _selectedImages.addAll(widget.initialImages);
    _originalFilenames.addAll(
      initialOriginalFilenamesForSelectedImages(
        widget.initialImages,
        widget.initialImageOriginalFilenames,
      ),
    );
    unawaited(_loadActiveDraftIfNeeded());
    unawaited(_loadPhotoSuggestions());

    // Animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();

    UserStorage.getSuperAgentRunMode().then((value) {
      if (mounted) {
        setState(() => _runMode = AgentRunMode.fromWire(value));
      }
    });

    final sessionId = _currentSessionId;
    if (sessionId != null) {
      AgentActionApprovalService.instance.attachSession(sessionId);
    }
    _approvalSubscription = AgentActionApprovalService.instance.requests
        .listen(_handleApprovalRequest);

    if (_currentSessionId != null) {
      _loadSessionHistory();
    }
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    for (final subscription in _queuedSendSubscriptions) {
      subscription.cancel();
    }
    _queuedSendSubscriptions.clear();
    _approvalSubscription?.cancel();
    final sessionId = _currentSessionId;
    if (sessionId != null) {
      // Denies anything still pending so a gated tool call never hangs.
      AgentActionApprovalService.instance.detachSession(sessionId);
    }
    _flushDraftOnDispose();
    _messageController.removeListener(_handleDraftTextChanged);
    _scrollController.removeListener(_handleHistoryScroll);
    _controller.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _handleApprovalRequest(AgentActionApprovalRequest request) {
    if (!mounted || request.sessionId != _currentSessionId) return;
    setState(() => _items.add(ApprovalRequestItem(request)));
    _scrollToBottom();
  }

  // --- Logic ---

  void _handleHistoryScroll() {
    if (!_hasMoreHistory || _isLoadingMoreHistory || _isLoading) return;
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0) return;
    if (position.pixels >= position.maxScrollExtent * 0.8) {
      unawaited(_loadMoreSessionHistory());
    }
  }

  Future<void> _loadSessionHistory() async {
    if (_currentSessionId == null) return;
    setState(() => _isLoading = true);

    try {
      // Note: We still use MemexRouter (or directly file service via a helper) to fetch history.
      // Since ChatService doesn't expose fetchHistory yet, reusing existing endpoint logic is fine.
      final sessionData = await _router.fetchChatSessionDetail(
        _currentSessionId!,
        messageLimit: _agentChatHistoryPageSize,
      );
      final messagesData = sessionData['messages'] as List<dynamic>? ?? [];
      final historyItems = _chatItemsFromSessionMessages(messagesData);

      ChatTokenUsageEvent? restoredUsage;
      if (sessionData['total_usage'] != null) {
        final usage = sessionData['total_usage'] as Map<String, dynamic>;
        final prompt = usage['prompt_tokens'] as int? ?? 0;
        final cached = usage['cached_tokens'] as int? ?? 0;
        restoredUsage = ChatTokenUsageEvent(
          promptTokens: prompt,
          completionTokens: usage['completion_tokens'] as int? ?? 0,
          cachedTokens: cached,
          effectivePromptTokens:
              usage['effective_prompt_tokens'] as int? ?? prompt,
          cachedTokensForRate:
              usage['cached_tokens_for_rate'] as int? ?? cached,
          totalTokens: usage['total_tokens'] as int? ?? 0,
          estimatedCost: usage['total_cost'] as double? ?? 0.0,
        );
      }

      setState(() {
        _items = historyItems;
        _lastTokenUsage = restoredUsage;
        _loadedHistoryMessageCount = messagesData.length;
        _hasMoreHistory =
            sessionData['has_more_messages'] == true && messagesData.isNotEmpty;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      _logger.severe('Error loading history', e);
      setState(() => _isLoading = false);
      if (mounted) ToastHelper.showError(context, 'Failed to load history: $e');
    }
    // After history is on screen, resume following an in-flight run if the
    // dialog was closed mid-reply.
    unawaited(_maybeReattachToActiveRun());
  }

  Future<void> _loadMoreSessionHistory() async {
    final sessionId = _currentSessionId;
    if (sessionId == null ||
        _isLoadingMoreHistory ||
        _isLoading ||
        !_hasMoreHistory) {
      return;
    }

    setState(() => _isLoadingMoreHistory = true);
    try {
      final sessionData = await _router.fetchChatSessionDetail(
        sessionId,
        messageLimit: _agentChatHistoryPageSize,
        messageOffset: _loadedHistoryMessageCount,
      );
      final messagesData = sessionData['messages'] as List<dynamic>? ?? [];
      final olderItems = _chatItemsFromSessionMessages(messagesData);
      if (!mounted || sessionId != _currentSessionId) return;

      setState(() {
        _items = [...olderItems, ..._items];
        _loadedHistoryMessageCount += messagesData.length;
        _hasMoreHistory =
            sessionData['has_more_messages'] == true && messagesData.isNotEmpty;
        _isLoadingMoreHistory = false;
      });
    } catch (e, st) {
      _logger.warning('Failed to load older chat history: $e', e, st);
      if (!mounted) return;
      setState(() => _isLoadingMoreHistory = false);
    }
  }

  List<ChatDisplayItem> _chatItemsFromSessionMessages(List<dynamic> messages) {
    final historyItems = <ChatDisplayItem>[];
    for (final msg in messages) {
      if (msg is! Map) continue;
      final message = Map<String, dynamic>.from(msg);
      final role = message['role'] as String? ?? 'user';
      final contentList = message['content'] as List<dynamic>? ?? [];
      final imagePaths = <String>[];
      final textParts = contentList
          .where((item) {
            if (item is Map && item['type'] == 'image_url') {
              final imageUrl = item['image_url'];
              if (imageUrl is Map) {
                final filePath = imageUrl['filePath']?.toString();
                if (filePath != null && filePath.isNotEmpty) {
                  imagePaths.add(_resolveDisplayImagePath(filePath));
                }
              }
            }
            return item is Map && item['type'] == 'text';
          })
          .map((item) => item['text'] as String? ?? '')
          .where((text) => text.isNotEmpty);
      final text = textParts.join(' ');

      if (text.isEmpty && imagePaths.isEmpty) continue;
      final timestamp = tryParseDateTime(message['timestamp']);
      if (role == 'user') {
        List<Map<String, String>>? refs;
        if (message['refs'] != null) {
          refs = (message['refs'] as List)
              .map((e) => Map<String, String>.from(e as Map))
              .toList();
        }
        historyItems.add(
          UserMessageItem(
            text.isNotEmpty
                ? text
                : UserStorage.l10n.attachedImagesMessage(imagePaths.length),
            refs: refs,
            imagePaths: imagePaths,
            timestamp: timestamp,
          ),
        );
      } else {
        historyItems.add(AIMessageItem(text, timestamp: timestamp));
      }
    }
    return historyItems;
  }

  String _resolveDisplayImagePath(String filePath) {
    if (filePath.startsWith('/')) {
      return filePath;
    }
    return FileSystemService.instance.toAbsolutePath(filePath);
  }

  bool get _hasInitialReferenceContext =>
      widget.initialRefs != null && widget.initialRefs!.isNotEmpty;

  bool get _shouldPersistDraft => !_hasInitialReferenceContext;

  bool get _shouldLoadStoredDraft =>
      _shouldPersistDraft &&
      widget.initialImages.isEmpty &&
      (widget.initialDraftText == null || widget.initialDraftText!.isEmpty);

  Future<void> _loadActiveDraftIfNeeded() async {
    if (!_shouldLoadStoredDraft || _messageController.text.isNotEmpty) return;

    final draft = await _draftService.loadActiveDraft();
    if (!mounted ||
        draft == null ||
        !_shouldLoadStoredDraft ||
        _messageController.text.isNotEmpty) {
      return;
    }

    _isApplyingDraft = true;
    _messageController.text = draft.text;
    _messageController.selection = TextSelection.collapsed(
      offset: _messageController.text.length,
    );
    _isApplyingDraft = false;
    setState(() {});
  }

  void _handleDraftTextChanged() {
    if (_isApplyingDraft || !_shouldPersistDraft) return;
    _scheduleDraftSave();
  }

  void _scheduleDraftSave() {
    _draftSaveDebounce?.cancel();
    _draftSaveDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!_shouldPersistDraft) return;
      unawaited(_draftService.saveTextDraft(_messageController.text));
    });
  }

  void _clearDraftAfterAcceptedSend() {
    if (!_shouldPersistDraft) return;
    _draftSaveDebounce?.cancel();
    unawaited(_draftService.clearActiveDraft());
  }

  void _flushDraftOnDispose() {
    _draftSaveDebounce?.cancel();
    if (!_shouldPersistDraft) return;
    unawaited(_draftService.saveTextDraft(_messageController.text));
  }

  Future<void> _loadPhotoSuggestions() async {
    if (_isLoadingPhotoSuggestions || _photoSuggestionClusters.isNotEmpty) {
      return;
    }

    setState(() => _isLoadingPhotoSuggestions = true);
    try {
      final clusters = await PhotoSuggestionService.fetchAndClusterRecentPhotos(
        maxCount: 10,
      );
      if (!mounted) return;
      setState(() {
        _photoSuggestionClusters =
            clusters.where((cluster) => cluster.isNotEmpty).take(8).toList();
        _isLoadingPhotoSuggestions = false;
      });
    } catch (e, st) {
      _logger.warning('Failed to load photo suggestions: $e', e, st);
      if (!mounted) return;
      setState(() => _isLoadingPhotoSuggestions = false);
    }
  }

  bool _isSuggestionClusterSelected(List<EnhancedPhoto> cluster) {
    return cluster.isNotEmpty &&
        cluster.every(
          (photo) => _selectedImages.any(
            (image) => image.path == photo.xFile.path,
          ),
        );
  }

  void _togglePhotoSuggestionCluster(List<EnhancedPhoto> cluster) {
    if (cluster.isEmpty) return;

    if (_isSuggestionClusterSelected(cluster)) {
      setState(() {
        for (final photo in cluster) {
          _selectedImages
              .removeWhere((image) => image.path == photo.xFile.path);
          _originalFilenames.remove(photo.xFile.path);
        }
      });
      return;
    }

    setState(() {
      for (final photo in cluster) {
        final alreadySelected =
            _selectedImages.any((image) => image.path == photo.xFile.path);
        if (alreadySelected) continue;

        // Keep the original EXIF/GPS-carrying file from assetToXFile().
        _selectedImages.add(photo.xFile);
        _originalFilenames[photo.xFile.path] = photo.xFile.name;
      }
    });
  }

  void _recordSentImageHashes(
    List<XFile> images,
    Map<String, String>? originalFilenames,
  ) {
    if (images.isEmpty) return;

    unawaited(() async {
      final hashes = <String>[];
      for (final image in images) {
        try {
          final length = await image.length();
          final effectiveName = originalFilenames?[image.path] ?? image.name;
          final rawHashStr = 'photo_${effectiveName}_$length';
          hashes.add(crypto.md5.convert(utf8.encode(rawHashStr)).toString());
        } catch (e, st) {
          _logger.warning('Failed to hash sent image ${image.path}: $e', e, st);
        }
      }

      if (hashes.isEmpty) return;
      try {
        await _router.recordProcessedHashes(hashes);
      } catch (e, st) {
        _logger.warning('Failed to record sent image hashes: $e', e, st);
      }
    }());
  }

  void _sendMessage(
    String message, {
    List<XFile> images = const [],
    Map<String, String>? imageOriginalFilenames,
  }) {
    if (message.trim().isEmpty && images.isEmpty) return;

    final queueBehindActiveRun = shouldQueueSuperAgentSend(
      isStreaming: _isStreaming,
      hasSessionId: _currentSessionId != null,
      hasChatSubscription: _chatSubscription != null,
    );
    _messageFocusNode.unfocus();
    String finalMessage = message.trim();
    final displayText = finalMessage.isNotEmpty
        ? finalMessage
        : UserStorage.l10n.attachedImagesMessage(images.length);
    final sentAt = DateTime.now();
    List<Map<String, String>>? refs;
    if (widget.initialRefs != null && !_contextSent) {
      refs = widget.initialRefs;
      _contextSent = true;
    }

    setState(() {
      _items.add(
        UserMessageItem(
          displayText,
          refs: refs,
          imagePaths: images.map((image) => image.path).toList(),
          timestamp: sentAt,
        ),
      );
      _loadedHistoryMessageCount += 1;
      _isStreaming = true;
      _messageController.clear();
      if (images.isNotEmpty) {
        _selectedImages.clear();
        _originalFilenames.clear();
      }
    });
    _clearDraftAfterAcceptedSend();
    _scrollToBottom();

    final stream = _router.sendMessage(
      finalMessage,
      sessionId: _currentSessionId,
      agentName: 'memex_agent',
      scene: 'super_agent_home',
      sceneId: widget.sceneId,
      refs: refs,
      images: images,
      imageOriginalFilenames: imageOriginalFilenames,
      isQuickQuery: _runMode == AgentRunMode.readOnly,
      runMode: _runMode.wireName,
    );
    _recordSentImageHashes(images, imageOriginalFilenames);
    if (queueBehindActiveRun) {
      _listenToQueuedSend(stream);
    } else {
      _listenToChatStream(stream);
    }
  }

  /// Subscribes the dialog to a chat event stream — either a freshly started
  /// send or a re-attached in-flight run.
  void _listenToChatStream(Stream<ChatEvent> stream) {
    _chatSubscription?.cancel();
    late final StreamSubscription<ChatEvent> subscription;
    subscription = stream.listen(
      (event) {
        _handleChatEvent(event);
      },
      onError: (e) {
        if (_chatSubscription == subscription) {
          _chatSubscription = null;
        }
        _handleChatStreamError(e);
      },
      onDone: () {
        if (_chatSubscription == subscription) {
          _chatSubscription = null;
        }
        _handleChatStreamDone();
      },
    );
    _chatSubscription = subscription;
  }

  /// Consumes the enqueue/session events from a send made while this dialog is
  /// already attached to the active run. The existing live subscription remains
  /// responsible for agent progress and responses.
  void _listenToQueuedSend(Stream<ChatEvent> stream) {
    late final StreamSubscription<ChatEvent> subscription;
    var promotedToChatStream = false;

    void promoteToChatStream(ChatEvent firstEvent) {
      promotedToChatStream = true;
      _queuedSendSubscriptions.remove(subscription);
      final previousSubscription = _chatSubscription;
      if (previousSubscription != null &&
          previousSubscription != subscription) {
        unawaited(previousSubscription.cancel());
      }
      _chatSubscription = subscription;
      _handleChatEvent(firstEvent);
    }

    subscription = stream.listen(
      (event) {
        if (!mounted) return;
        if (!promotedToChatStream &&
            (event is ChatSessionCreatedEvent || event is ChatErrorEvent)) {
          _handleChatEvent(event);
          return;
        }
        if (!promotedToChatStream) {
          promoteToChatStream(event);
          return;
        }
        _handleChatEvent(event);
      },
      onError: (e) {
        if (!mounted) return;
        if (promotedToChatStream) {
          if (_chatSubscription == subscription) {
            _chatSubscription = null;
          }
          _handleChatStreamError(e);
        } else {
          setState(() => _items.add(ErrorItem(e.toString())));
          _scrollToBottom();
        }
      },
      onDone: () {
        if (promotedToChatStream) {
          if (_chatSubscription == subscription) {
            _chatSubscription = null;
          }
          _handleChatStreamDone();
        } else {
          _queuedSendSubscriptions.remove(subscription);
        }
      },
    );
    _queuedSendSubscriptions.add(subscription);
  }

  void _handleChatStreamError(Object error) {
    if (!mounted) return;
    setState(() {
      _items.add(ErrorItem(error.toString()));
      _isStreaming = false;
      _isLoadingAgent = false;
    });
    _scrollToBottom();
  }

  void _handleChatStreamDone() {
    if (!mounted) return;
    setState(() {
      _isStreaming = false;
      _isLoadingAgent = false;
      // Ensure the last AI message is marked as done
      if (_items.isNotEmpty && _items.last is AIMessageItem) {
        (_items.last as AIMessageItem).isStreaming = false;
      }
      final primary = _lastPrimaryItem();
      if (primary is ProcessItem) {
        primary.isFinished = true;
        primary.isExpanded = false;
      }
    });
  }

  /// If this session has a run still executing (the dialog was closed while
  /// the agent worked), restore the streaming UI and replay missed events.
  Future<void> _maybeReattachToActiveRun() async {
    final sessionId = _currentSessionId;
    if (!mounted || sessionId == null) return;
    if (!await _router.hasActiveChatRun(sessionId)) return;
    if (!mounted || sessionId != _currentSessionId) return;

    AgentActionApprovalService.instance.attachSession(sessionId);
    _messageFocusNode.unfocus();
    setState(() {
      _isStreaming = true;
      _isLoadingAgent = true;
      _nextResponseStartsNewMessage = true;
    });
    _listenToChatStream(_router.attachToChatRun(sessionId));
    _scrollToBottom();
  }

  Future<void> _handleRefreshAgentState() async {
    final sessionId = _currentSessionId;
    if (sessionId == null || sessionId.isEmpty || _isRefreshingAgentState) {
      return;
    }

    if (await _router.hasActiveChatRun(sessionId)) {
      if (!mounted || sessionId != _currentSessionId) return;
      await _showRefreshAgentStateDialog(
        message: UserStorage.l10n.refreshSuperAgentStateActiveRunMessage,
        canRefresh: false,
      );
      return;
    }
    if (!mounted || sessionId != _currentSessionId) return;

    final confirmed = await _showRefreshAgentStateDialog(
      message: UserStorage.l10n.refreshSuperAgentStateMessage,
      canRefresh: true,
    );
    if (confirmed != true) return;
    if (!mounted || sessionId != _currentSessionId) return;

    setState(() => _isRefreshingAgentState = true);
    final result = await _router.refreshSuperAgentChatState(sessionId);
    if (!mounted || sessionId != _currentSessionId) return;
    setState(() => _isRefreshingAgentState = false);

    result.when(
      onOk: (_) {
        setState(() => _lastTokenUsage = null);
        ToastHelper.showSuccess(
          context,
          UserStorage.l10n.refreshSuperAgentStateSuccess,
        );
      },
      onError: (error, _) {
        ToastHelper.showError(
          context,
          UserStorage.l10n.refreshSuperAgentStateFailed(error),
        );
      },
    );
  }

  Future<bool?> _showRefreshAgentStateDialog({
    required String message,
    required bool canRefresh,
  }) {
    final dismissLabel =
        canRefresh ? UserStorage.l10n.cancel : UserStorage.l10n.close;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(UserStorage.l10n.refreshSuperAgentStateTitle),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(dismissLabel),
          ),
          if (canRefresh)
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(UserStorage.l10n.refresh),
            ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final image = await _imagePicker.pickImage(
          source: source,
          imageQuality: 85,
        );
        if (image != null && mounted) {
          setState(() => _selectedImages.add(image));
        }
        return;
      }

      if (!mounted) return;
      final result = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: 9,
          requestType: RequestType.image,
          filterOptions: FilterOptionGroup(
            containsPathModified: true,
            createTimeCond: DateTimeCond.def().copyWith(ignore: true),
            updateTimeCond: DateTimeCond.def().copyWith(ignore: true),
            videoOption: const FilterOption(
              durationConstraint: DurationConstraint(
                min: Duration.zero,
                max: Duration.zero,
              ),
            ),
          ),
        ),
      );
      if (result == null) return;

      for (final asset in result) {
        final xFile = await PhotoSuggestionService.assetToXFile(asset);
        if (xFile == null) continue;
        final originalName = await asset.titleAsync;
        _originalFilenames[xFile.path] = originalName;
        if (mounted) {
          setState(() => _selectedImages.add(xFile));
        }
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, e);
      }
    }
  }

  void _removeSelectedImage(int index) {
    if (index < 0 || index >= _selectedImages.length) return;
    setState(() {
      _originalFilenames.remove(_selectedImages[index].path);
      _selectedImages.removeAt(index);
    });
  }

  void _handleSuperAgentSubmit() {
    final message = _messageController.text;
    final images = List<XFile>.from(_selectedImages);
    final imageOriginalFilenames = Map<String, String>.from(_originalFilenames);

    if (_handleDemoSubmitIfNeeded(message, images: images)) return;

    _sendMessage(
      message,
      images: images,
      imageOriginalFilenames: imageOriginalFilenames,
    );
  }

  bool _handleDemoSubmitIfNeeded(
    String message, {
    required List<XFile> images,
  }) {
    final demo = DemoService.instance;
    if (demo.currentStep != DemoStep.tapSend) return false;
    if (message.trim().isEmpty && images.isEmpty) return false;

    final combinedText = message.trim().isNotEmpty
        ? message.trim()
        : UserStorage.l10n.attachedImagesMessage(images.length);

    demo.tryAdvance(DemoStep.tapSend);
    _messageFocusNode.unfocus();
    _messageController.clear();
    _selectedImages.clear();
    _originalFilenames.clear();
    _clearDraftAfterAcceptedSend();

    unawaited(Navigator.of(context).maybePop());
    unawaited(_writeSuperAgentDemoSubmit(combinedText));
    return true;
  }

  Future<void> _writeSuperAgentDemoSubmit(String combinedText) async {
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      _logger.warning(
        'Cannot submit onboarding demo from Super Agent; user not logged in',
      );
      return;
    }
    await DemoService.instance.handleSuperAgentDemoSubmit(userId, combinedText);
  }

  void _handleChatEvent(ChatEvent event) {
    setState(() {
      if (event is ChatAgentStartedEvent) {
        _messageFocusNode.unfocus();
        _isStreaming = true;
        _isLoadingAgent = true;
        _nextResponseStartsNewMessage = true;
        return;
      }
      if (event is ChatAgentStoppedEvent) {
        _isLoadingAgent = false;
        return;
      }
      if (event is ChatTokenUsageEvent) {
        _lastTokenUsage = event;
        return;
      }
      if (event is ChatSessionCreatedEvent) {
        _currentSessionId = event.sessionId;
        AgentActionApprovalService.instance.attachSession(event.sessionId);
        return;
      }

      // Handle Thoughts and Tools (Grouping)
      if (event is ChatThoughtChunkEvent ||
          event is ChatTraceStartedEvent ||
          event is ChatTraceCompletedEvent) {
        final processItem = _ensureProcessItem();

        if (event is ChatThoughtChunkEvent) {
          if (processItem.children.isNotEmpty &&
              processItem.children.last is ThinkingItem) {
            (processItem.children.last as ThinkingItem).text += event.text;
          } else {
            processItem.children.add(ThinkingItem(event.text));
          }
        } else if (event is ChatTraceStartedEvent) {
          _upsertTraceStart(processItem, event);
        } else if (event is ChatTraceCompletedEvent) {
          final matchedTool = _completeTrace(processItem, event);
          if (!event.isError) {
            final artifact = ChatArtifact.fromToolMetadata(event.metadata);
            if (artifact != null) {
              _items.add(
                ArtifactItem(
                  artifact,
                  html: artifact.type == ChatArtifact.typeHtmlCard
                      ? _htmlFromToolArgs(matchedTool)
                      : null,
                ),
              );
            }
          }
        }
        return; // Handled
      }

      // Handle Response (Finish Progress)
      if (event is ChatResponseChunkEvent) {
        final primary = _lastPrimaryItem();
        if (primary is ProcessItem) {
          primary.isFinished = true;
          primary.isExpanded = false; // Collapse when answer starts
        }

        if (primary is AIMessageItem && !_nextResponseStartsNewMessage) {
          primary.text += event.text;
          primary.isStreaming = !event.isDone;
        } else if (shouldCreateAIMessageForResponseChunk(
          text: event.text,
          isDone: event.isDone,
        )) {
          _items.add(
            AIMessageItem(
              event.text,
              isStreaming: !event.isDone,
              timestamp: DateTime.now(),
            ),
          );
          _loadedHistoryMessageCount += 1;
        }
        if (event.isDone) {
          _nextResponseStartsNewMessage = true;
        } else {
          _nextResponseStartsNewMessage = false;
        }
      } else if (event is ChatErrorEvent) {
        _items.add(ErrorItem(event.error));
      }
    });
    _scrollToBottom();
  }

  /// Auxiliary items (artifacts, approval cards) interleave with the process
  /// stream; grouping logic must look past them.
  bool _isAuxiliaryItem(ChatDisplayItem item) =>
      item is ArtifactItem || item is ApprovalRequestItem;

  ChatDisplayItem? _lastPrimaryItem() {
    for (var i = _items.length - 1; i >= 0; i--) {
      final item = _items[i];
      if (_isAuxiliaryItem(item)) continue;
      return item;
    }
    return null;
  }

  ProcessItem _ensureProcessItem() {
    final primary = _lastPrimaryItem();
    if (primary is ProcessItem) return primary;
    final processItem = ProcessItem();
    _items.add(processItem);
    return processItem;
  }

  String? _htmlFromToolArgs(ToolCallItem? tool) {
    if (tool == null) return null;
    try {
      final decoded = jsonDecode(tool.args);
      if (decoded is Map && decoded['html'] is String) {
        final html = (decoded['html'] as String).trim();
        return html.isEmpty ? null : html;
      }
    } catch (_) {
      // Args are not guaranteed to be valid JSON.
    }
    return null;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool get _showAgentThinkingRow {
    return _isLoadingAgent;
  }

  int _agentChatListItemCount() {
    return _items.length +
        (_showAgentThinkingRow ? 1 : 0) +
        ((_hasMoreHistory || _isLoadingMoreHistory) ? 1 : 0);
  }

  bool _shouldShowHistoryLoaderAt(int index) {
    if (!_hasMoreHistory && !_isLoadingMoreHistory) return false;
    return index == _agentChatListItemCount() - 1;
  }

  Widget _buildAgentThinkingItem() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.iconBgLight,
            child: SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Thinking...',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryLoadMoreIndicator() {
    if (_isLoadingMoreHistory) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }
    return const SizedBox(height: 1);
  }

  Widget _buildItemWithTimeDivider(int itemIndex) {
    final item = _items[itemIndex];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_shouldShowTimeDivider(itemIndex)) _buildTimeDivider(item),
        _buildItem(item),
      ],
    );
  }

  bool _shouldShowTimeDivider(int itemIndex) {
    final timestamp = _items[itemIndex].timestamp;
    if (timestamp == null) return false;

    for (var i = itemIndex - 1; i >= 0; i--) {
      final previous = _items[i].timestamp;
      if (previous == null) continue;
      return timestamp.difference(previous).inMinutes.abs() >= 10;
    }
    return true;
  }

  Widget _buildTimeDivider(ChatDisplayItem item) {
    final timestamp = item.timestamp;
    if (timestamp == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEFF2F6)),
          ),
          child: Text(
            formatSuperAgentTimeDivider(timestamp),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Building ---

  @override
  Widget build(BuildContext context) {
    final viewportSize = MediaQuery.of(context).size;
    final keyboardBottomOffset = resolveSuperAgentInputBottomInset(
      keyboardInset: MediaQuery.of(context).viewInsets.bottom,
      inputFocused: _messageFocusNode.hasFocus,
      isStreaming: _isStreaming,
    );
    final keyboardInsetAnimationDuration =
        resolveSuperAgentKeyboardInsetAnimationDuration(
      previousInset: _lastKeyboardBottomOffset,
      nextInset: keyboardBottomOffset,
    );
    _lastKeyboardBottomOffset = keyboardBottomOffset;
    final dialogHeight = resolveAgentChatDialogHeight(
      viewportSize,
      isFullScreen: _isFullScreen,
      keyboardInset: keyboardBottomOffset,
    );
    final borderRadius = resolveAgentChatDialogBorderRadius(
      isFullScreen: _isFullScreen,
    );

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop
          FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.black.withValues(alpha: 0.2)),
            ),
          ),
          // Dialog
          SlideTransition(
            position: _slideAnimation,
            child: AnimatedPadding(
              duration: keyboardInsetAnimationDuration,
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(bottom: keyboardBottomOffset),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  key: const ValueKey('agent_chat_dialog_container'),
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: double.infinity,
                  height: dialogHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: borderRadius,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 40,
                        offset: Offset(0, -10),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: SafeArea(
                    top: _isFullScreen,
                    bottom: false,
                    child: Column(
                      children: [
                        _buildHeader(),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: _messageFocusNode.unfocus,
                            child: Container(
                              color: Colors.white,
                              child: _isLoading
                                  ? const Center(child: AgentLogoLoading())
                                  : _items.isEmpty
                                      ? _buildEmptyState()
                                      : ListView.builder(
                                          controller: _scrollController,
                                          reverse: true,
                                          keyboardDismissBehavior:
                                              ScrollViewKeyboardDismissBehavior
                                                  .onDrag,
                                          padding: const EdgeInsets.all(24),
                                          itemCount: _agentChatListItemCount(),
                                          itemBuilder: (context, index) {
                                            final extraItems =
                                                _showAgentThinkingRow ? 1 : 0;
                                            if (extraItems == 1 && index == 0) {
                                              return _buildAgentThinkingItem();
                                            }
                                            if (_shouldShowHistoryLoaderAt(
                                                index)) {
                                              return _buildHistoryLoadMoreIndicator();
                                            }
                                            final itemIndex =
                                                superAgentItemIndexForReversedList(
                                              listIndex: index,
                                              itemCount: _items.length,
                                              extraItems: extraItems,
                                            );
                                            return _buildItemWithTimeDivider(
                                              itemIndex,
                                            );
                                          },
                                        ),
                            ),
                          ),
                        ),
                        _buildTokenUsageDisplay(),
                        _buildContextIndicator(),
                        _buildInput(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextIndicator() {
    if (widget.initialRefs == null ||
        widget.initialRefs!.isEmpty ||
        _contextSent) {
      return const SizedBox.shrink();
    }
    final title =
        widget.initialRefs!.first['title'] ?? UserStorage.l10n.referenceContent;

    return Container(
      width: double.infinity,
      color: const Color(0xFFF7F8FA),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.link, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              UserStorage.l10n.referenceWithTitle(title),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAgentMark(size: 32),
          const SizedBox(height: 6),
          Text(
            UserStorage.l10n.aiInputHint,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final actions = <Widget>[
      if (_currentSessionId != null)
        _buildHeaderIconButton(
          key: const ValueKey('agent_chat_refresh_state_button'),
          tooltip: UserStorage.l10n.refreshSuperAgentStateTooltip,
          icon: Icons.refresh_rounded,
          onPressed: _handleRefreshAgentState,
        ),
      _buildHeaderIconButton(
        key: const ValueKey('agent_chat_fullscreen_toggle'),
        tooltip: _isFullScreen
            ? UserStorage.l10n.exitFullScreenTooltip
            : UserStorage.l10n.enterFullScreenTooltip,
        icon: _isFullScreen ? Icons.close_fullscreen : Icons.open_in_full,
        onPressed: () {
          setState(() {
            _isFullScreen = !_isFullScreen;
          });
          _scrollToBottom();
        },
      ),
      _buildHeaderIconButton(
        key: const ValueKey('agent_chat_close_button'),
        tooltip: UserStorage.l10n.close,
        icon: Icons.close,
        iconSize: 20,
        onPressed: () => Navigator.of(context).pop(),
      ),
    ];
    final reservedActionWidth = actions.length * 36.0 + 8;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 24, right: 4, top: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: const Border(bottom: BorderSide(color: Color(0xFFF7F8FA))),
      ),
      child: SizedBox(
        height: 36,
        child: Stack(
          children: [
            Positioned.fill(
              right: reservedActionWidth,
              child: Row(
                children: [
                  _buildAgentMark(size: 22),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      'Memex',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              child: Row(mainAxisSize: MainAxisSize.min, children: actions),
            ),
          ],
        ),
      ),
    );
  }

  /// Compact header action button. Material's default [IconButton] reserves a
  /// 48x48 hit box, which leaves fullscreen/close icons floating too far from
  /// the sheet edge. A stable 36x36 box keeps the tap target predictable while
  /// visually aligning the close icon near the right edge.
  Widget _buildHeaderIconButton({
    Key? key,
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    double iconSize = 18,
  }) {
    return Tooltip(
      message: tooltip,
      child: SizedBox.square(
        key: key,
        dimension: 36,
        child: InkResponse(
          onTap: onPressed,
          radius: 20,
          child: Center(
            child: Icon(icon, size: iconSize, color: AppColors.textTertiary),
          ),
        ),
      ),
    );
  }

  Widget _buildAgentMark({double size = 24}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: Image.asset(
        'assets/icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildInput() {
    return _buildSuperAgentInput();
  }

  Widget _buildPhotoSuggestionRow() {
    if (_isLoadingPhotoSuggestions) {
      return SizedBox(
        height: 48,
        child: Row(
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 18,
              color: AppColors.primary.withValues(alpha: 0.55),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                _agentChat.findingRecentPhotos,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_photoSuggestionClusters.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 68,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _photoSuggestionClusters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return _buildPhotoSuggestionChip(_photoSuggestionClusters[index]);
        },
      ),
    );
  }

  Widget _buildPhotoSuggestionChip(List<EnhancedPhoto> cluster) {
    final isSelected = _isSuggestionClusterSelected(cluster);

    return GestureDetector(
      onTap: () => _togglePhotoSuggestionCluster(cluster),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.45)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...cluster.take(5).map(
                  (photo) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 46,
                        height: 46,
                        child: AssetEntityImage(
                          photo.entity,
                          fit: BoxFit.cover,
                          isOriginal: false,
                          thumbnailSize: const ThumbnailSize.square(120),
                          thumbnailFormat: ThumbnailFormat.jpeg,
                        ),
                      ),
                    ),
                  ),
                ),
            if (cluster.length > 5)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  '+${cluster.length - 5}',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 2),
            Icon(
              isSelected ? Icons.check_circle : Icons.add_circle_outline,
              size: 20,
              color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuperAgentInput() {
    final showPhotoSuggestions = shouldShowSuperAgentPhotoSuggestions(
      isLoading: _isLoadingPhotoSuggestions,
      hasSuggestions: _photoSuggestionClusters.isNotEmpty,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF7F8FA))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showPhotoSuggestions) ...[
            _buildPhotoSuggestionRow(),
            const SizedBox(height: 10),
          ],
          if (_selectedImages.isNotEmpty) ...[
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return _buildSelectedImageThumb(index);
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _messageController,
                  focusNode: _messageFocusNode,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: UserStorage.l10n.aiInputHint,
                    hintStyle: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildInputIconButton(
                      key: const ValueKey('super_agent_camera_button'),
                      icon: Icons.camera_alt,
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                    const SizedBox(width: 12),
                    _buildInputIconButton(
                      key: const ValueKey('super_agent_gallery_button'),
                      icon: Icons.photo_library,
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _buildRunModeChip(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      key: superAgentDemoPublishTargetKey(
                        DemoService.instance.currentStep,
                      ),
                      child: GestureDetector(
                        key: const ValueKey('super_agent_publish_button'),
                        onTap: _handleSuperAgentSubmit,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                UserStorage.l10n.sendLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_upward,
                                size: 17,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Run mode selector (super agent home) ---

  String _runModeLabel(AgentRunMode mode) {
    switch (mode) {
      case AgentRunMode.auto:
        return _agentChat.runModeAuto;
      case AgentRunMode.confirm:
        return _agentChat.runModeAskFirst;
      case AgentRunMode.readOnly:
        return _agentChat.runModeReadOnly;
    }
  }

  String _runModeDescription(AgentRunMode mode) {
    switch (mode) {
      case AgentRunMode.auto:
        return _agentChat.runModeAutoDescription;
      case AgentRunMode.confirm:
        return _agentChat.runModeConfirmDescription;
      case AgentRunMode.readOnly:
        return _agentChat.runModeReadOnlyDescription;
    }
  }

  IconData _runModeIcon(AgentRunMode mode) {
    switch (mode) {
      case AgentRunMode.auto:
        return Icons.bolt_rounded;
      case AgentRunMode.confirm:
        return Icons.verified_user_outlined;
      case AgentRunMode.readOnly:
        return Icons.visibility_outlined;
    }
  }

  void _selectRunMode(AgentRunMode mode) {
    setState(() => _runMode = mode);
    UserStorage.setSuperAgentRunMode(mode.wireName);
  }

  Widget _buildRunModeChip() {
    return GestureDetector(
      key: const ValueKey('super_agent_run_mode_chip'),
      onTap: _showRunModePicker,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(21),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _runModeIcon(_runMode),
              size: 15,
              color: _runMode == AgentRunMode.auto
                  ? AppColors.textSecondary
                  : AppColors.primary,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                _runModeLabel(_runMode),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _runMode == AgentRunMode.auto
                      ? AppColors.textSecondary
                      : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.unfold_more,
              size: 13,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  void _showRunModePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _agentChat.runModeTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                for (final mode in AgentRunMode.values)
                  InkWell(
                    key: ValueKey('run_mode_option_${mode.wireName}'),
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _selectRunMode(mode);
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: _runMode == mode
                            ? const Color(0xFFF0F4FF)
                            : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _runMode == mode
                              ? AppColors.primary
                              : const Color(0xFFEFF2F6),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _runModeIcon(mode),
                            size: 18,
                            color: _runMode == mode
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _runModeLabel(mode),
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _runModeDescription(mode),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_runMode == mode)
                            const Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputIconButton({
    required Key key,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(21),
        ),
        child: Icon(icon, size: 20, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildSelectedImageThumb(int index) {
    final image = _selectedImages[index];
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            File(image.path),
            width: 72,
            height: 72,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: () => _removeSelectedImage(index),
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageImageGrid(List<String> imagePaths) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: imagePaths.map((imagePath) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(imagePath),
            width: 88,
            height: 88,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 88,
              height: 88,
              color: Colors.white.withValues(alpha: 0.18),
              child: const Icon(
                Icons.broken_image_outlined,
                color: Colors.white70,
                size: 22,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildItem(ChatDisplayItem item) {
    if (item is UserMessageItem) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(
                  16,
                ).copyWith(bottomRight: const Radius.circular(4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.refs != null && item.refs!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: item.refs!.map((ref) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.link,
                                  size: 12,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    ref['title'] ?? 'Reference',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  if (item.imagePaths.isNotEmpty) ...[
                    _buildMessageImageGrid(item.imagePaths),
                    const SizedBox(height: 8),
                  ],
                  SelectableText(
                    item.text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (item is AIMessageItem) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.iconBgLight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  'assets/icon.png',
                  width: 16,
                  height: 16,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        16,
                      ).copyWith(topLeft: const Radius.circular(4)),
                      border: Border.all(color: const Color(0xFFF7F8FA)),
                    ),
                    child: MarkdownBody(
                      data: item.text,
                      selectable: true,
                      softLineBreak: true,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        strong: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        em: const TextStyle(fontStyle: FontStyle.italic),
                        listBullet: const TextStyle(color: AppColors.primary),
                        code: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          backgroundColor: Color(0xFFF7F8FA),
                          fontFamily: 'monospace',
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: const Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        blockquote: const TextStyle(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                        blockquoteDecoration: BoxDecoration(
                          color: const Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.circular(8),
                          border: const Border(
                            left: BorderSide(
                              color: AppColors.primary,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!item.isStreaming)
                    Padding(
                      padding: const EdgeInsets.only(left: 2, top: 6),
                      child: _CopyMessageButton(
                        text: item.text,
                        onCopied: () {
                          ToastHelper.showSuccess(
                            context,
                            UserStorage.l10n.copiedToClipboard,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (item is ProcessItem) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 32), // Indent
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE6EAF2)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A0F172A),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        setState(() {
                          item.isExpanded = !item.isExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildProcessStatusGlyph(item),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _processTitle(item),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF0F172A),
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _processSubtitle(item),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textTertiary,
                                          height: 1.25,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildProcessStatePill(item),
                                const SizedBox(width: 6),
                                Icon(
                                  item.isExpanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  size: 20,
                                  color: AppColors.textTertiary,
                                ),
                              ],
                            ),
                            if (item.toolCalls.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              _buildToolSummaryChips(item),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (item.isExpanded)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0xFFF1F5F9)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.thinkingItems.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              ...item.thinkingItems.map(_buildThinkingItem),
                            ],
                            if (item.toolCalls.isNotEmpty)
                              _buildToolTraceList(item.toolCalls),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else if (item is ErrorItem) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            item.error,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
      );
    } else if (item is ApprovalRequestItem) {
      return _buildApprovalRequestItem(item);
    } else if (item is ArtifactItem) {
      return _buildArtifactItem(item);
    }
    return const SizedBox.shrink();
  }

  // --- Ask-first approval card ---

  void _resolveApproval(ApprovalRequestItem item, {required bool approved}) {
    AgentActionApprovalService.instance.resolve(
      item.request.id,
      approved: approved,
    );
    setState(() => item.status = approved ? 'approved' : 'denied');
  }

  Widget _buildApprovalRequestItem(ApprovalRequestItem item) {
    final isPending = item.status == 'pending';
    final isApproved = item.status == 'approved';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 32),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: isPending ? const Color(0xFFFFFBEB) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPending
                      ? const Color(0xFFFDE68A)
                      : const Color(0xFFE6EAF2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: 16,
                        color: isPending
                            ? const Color(0xFFB45309)
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          isPending
                              ? _agentChat.approvalPrompt(
                                  _toolDisplayName(item.request.toolName),
                                )
                              : isApproved
                                  ? _agentChat.approved
                                  : _agentChat.denied,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isPending
                                ? const Color(0xFF92400E)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (!isPending)
                        Icon(
                          isApproved
                              ? Icons.check_circle_outline
                              : Icons.cancel_outlined,
                          size: 16,
                          color: isApproved
                              ? const Color(0xFF16A34A)
                              : AppColors.textTertiary,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.request.summary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  for (final entry in item.request.details.entries)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textTertiary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  if (isPending) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            key: ValueKey(
                              'approval_deny_${item.request.id}',
                            ),
                            onPressed: () =>
                                _resolveApproval(item, approved: false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _agentChat.deny,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            key: ValueKey(
                              'approval_allow_${item.request.id}',
                            ),
                            onPressed: () =>
                                _resolveApproval(item, approved: true),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _agentChat.allow,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Artifact previews ---

  String _artifactHeading(ChatArtifact artifact) {
    switch (artifact.type) {
      case ChatArtifact.typeRecord:
        return _agentChat.recordSaved;
      case ChatArtifact.typeHtmlCard:
        return artifact.updated
            ? _agentChat.cardUpdated
            : _agentChat.cardCreated;
      case ChatArtifact.typeCard:
        return _agentChat.cardSaved;
      case ChatArtifact.typeFile:
        return artifact.updated
            ? _agentChat.documentUpdated
            : _agentChat.documentCreated;
      case ChatArtifact.typeSystemAction:
        return artifact.kind == 'calendar'
            ? _agentChat.calendarEventCreated
            : _agentChat.reminderCreated;
      case ChatArtifact.typeInsight:
        return _agentChat.insightSaved;
      default:
        return _agentChat.done;
    }
  }

  IconData _artifactIcon(ChatArtifact artifact) {
    switch (artifact.type) {
      case ChatArtifact.typeRecord:
        return Icons.bookmark_added_outlined;
      case ChatArtifact.typeHtmlCard:
      case ChatArtifact.typeCard:
        return Icons.auto_awesome_mosaic_outlined;
      case ChatArtifact.typeFile:
        return Icons.description_outlined;
      case ChatArtifact.typeSystemAction:
        return Icons.notifications_active_outlined;
      case ChatArtifact.typeInsight:
        return Icons.insights_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  void _openArtifact(ChatArtifact artifact) {
    final cardId = artifact.id;
    if (cardId == null || cardId.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TimelineCardDetailScreen(cardId: cardId),
      ),
    );
  }

  bool _artifactIsTappable(ChatArtifact artifact) {
    switch (artifact.type) {
      case ChatArtifact.typeRecord:
      case ChatArtifact.typeHtmlCard:
      case ChatArtifact.typeCard:
        return artifact.id != null && artifact.id!.isNotEmpty;
      default:
        return false;
    }
  }

  /// Only the most recent HTML artifacts keep a live WebView preview; older
  /// ones degrade to a flat tile to bound WebView count in long sessions.
  static const int _maxLiveHtmlPreviews = 2;

  Set<ArtifactItem> _liveHtmlPreviewItems() {
    final allowed = <ArtifactItem>{};
    for (var i = _items.length - 1;
        i >= 0 && allowed.length < _maxLiveHtmlPreviews;
        i--) {
      final item = _items[i];
      if (item is ArtifactItem &&
          item.artifact.type == ChatArtifact.typeHtmlCard &&
          item.html != null) {
        allowed.add(item);
      }
    }
    return allowed;
  }

  Widget _buildArtifactItem(ArtifactItem item) {
    final artifact = item.artifact;
    final tappable = _artifactIsTappable(artifact);
    final showHtmlPreview =
        item.html != null && _liveHtmlPreviewItems().contains(item);

    final content = Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EAF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _artifactIcon(artifact),
                size: 15,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _artifactHeading(artifact),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (tappable)
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
            ],
          ),
          if (artifact.title != null) ...[
            const SizedBox(height: 8),
            Text(
              artifact.title!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
          ],
          if (artifact.path != null) ...[
            const SizedBox(height: 8),
            Text(
              artifact.path!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'monospace',
              ),
            ),
          ],
          if (artifact.snippet != null) ...[
            const SizedBox(height: 6),
            Text(
              artifact.snippet!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
          if (artifact.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: artifact.tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (artifact.imagePaths.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: artifact.imagePaths.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final path =
                      _resolveDisplayImagePath(artifact.imagePaths[index]);
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(path),
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 64,
                        height: 64,
                        color: const Color(0xFFF7F8FA),
                        child: const Icon(
                          Icons.broken_image_outlined,
                          size: 18,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          if (showHtmlPreview) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AbsorbPointer(
                child: HtmlWebViewCard(
                  html: item.html!,
                  config: const HtmlWebViewConfig(
                    initialHeight: 140,
                    minHeightThreshold: 40,
                    maxHeight: 240,
                    heightPadding: 0,
                    showContainerDecoration: true,
                    borderRadius: 14,
                    borderColor: Color(0xFFF1F5F9),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 32),
          Expanded(
            child: tappable
                ? GestureDetector(
                    onTap: () => _openArtifact(artifact),
                    child: content,
                  )
                : content,
          ),
        ],
      ),
    );
  }

  Widget _buildTokenUsageDisplay() {
    if (_lastTokenUsage == null) return const SizedBox.shrink();
    final item = _lastTokenUsage!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            formatSuperAgentTokenUsage(item),
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessStatusGlyph(ProcessItem item) {
    final color = item.hasToolError
        ? const Color(0xFFEF4444)
        : item.hasRunningTool || !item.isFinished
            ? AppColors.primary
            : const Color(0xFF10B981);
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: item.hasRunningTool || !item.isFinished
            ? const SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: AppColors.primary,
                ),
              )
            : Icon(
                item.hasToolError
                    ? Icons.error_outline_rounded
                    : Icons.check_rounded,
                size: 16,
                color: color,
              ),
      ),
    );
  }

  Widget _buildProcessStatePill(ProcessItem item) {
    final label = item.hasToolError
        ? _agentChat.issue
        : item.hasRunningTool || !item.isFinished
            ? _agentChat.running
            : _agentChat.done;
    final color = item.hasToolError
        ? const Color(0xFFEF4444)
        : item.hasRunningTool || !item.isFinished
            ? AppColors.primary
            : const Color(0xFF10B981);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }

  String _processTitle(ProcessItem item) {
    final toolCount = item.allTraceCalls.length;
    if (toolCount == 0) {
      return item.isFinished
          ? _agentChat.reasoningComplete
          : _agentChat.thinkingThroughRequest;
    }
    if (item.hasToolError) {
      return _agentChat.actionNeedsAttention;
    }
    if (item.hasRunningTool || !item.isFinished) {
      return _agentChat.workingThroughActions(toolCount);
    }
    return _agentChat.completedActions(toolCount);
  }

  String _processSubtitle(ProcessItem item) {
    final toolCounts = _toolCounts(item.allTraceCalls);
    if (toolCounts.isEmpty) {
      return item.isFinished
          ? _agentChat.internalReasoningFinished
          : _agentChat.planningNextStep;
    }
    return toolCounts.entries
        .take(4)
        .map((entry) => '${_toolDisplayName(entry.key)} x${entry.value}')
        .join(' · ');
  }

  Widget _buildToolSummaryChips(ProcessItem item) {
    final entries = _toolCounts(item.allTraceCalls).entries.toList();
    final visibleEntries = entries.take(4).toList();
    final hiddenCount =
        entries.skip(4).fold<int>(0, (sum, entry) => sum + entry.value);

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final entry in visibleEntries)
          _buildToolChip(
            icon: _toolIcon(entry.key),
            label: entry.value == 1
                ? _toolDisplayName(entry.key)
                : '${_toolDisplayName(entry.key)} ${entry.value}',
          ),
        if (hiddenCount > 0)
          _buildToolChip(
            icon: Icons.more_horiz_rounded,
            label: '+$hiddenCount',
          ),
      ],
    );
  }

  Widget _buildToolChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolTraceList(List<ToolCallItem> tools) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Text(
              _agentChat.toolActivity,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
          for (var index = 0; index < tools.length; index++) ...[
            if (index > 0)
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            _buildToolCallItem(tools[index]),
          ],
        ],
      ),
    );
  }

  Map<String, int> _toolCounts(List<ToolCallItem> tools) {
    final counts = <String, int>{};
    for (final tool in tools) {
      counts[tool.toolName] = (counts[tool.toolName] ?? 0) + 1;
    }
    return counts;
  }

  void _upsertTraceStart(ProcessItem process, ChatTraceStartedEvent event) {
    final existing = _findTraceItem(process, event.id);
    if (existing != null) {
      existing.kind = event.kind;
      existing.label = event.label ?? existing.label;
      existing.args = event.args;
      return;
    }

    final item = ToolCallItem(
      event.id,
      event.name,
      event.args,
      kind: event.kind,
      label: event.label,
    );
    final parentId = event.parentId;
    if (parentId == null) {
      process.children.add(item);
      return;
    }

    final parent = _findTraceItem(process, parentId);
    if (parent == null) {
      process.children.add(item);
    } else {
      parent.childToolCalls.add(item);
    }
  }

  ToolCallItem? _completeTrace(
    ProcessItem process,
    ChatTraceCompletedEvent event,
  ) {
    final item = _findTraceItem(process, event.id);
    if (item == null) return null;
    if (!(item.isDelegate && event.status == null && item.result != null)) {
      item.result = event.result;
    }
    item.isError = event.isError;
    item.status = event.status ?? item.status;
    item.completedAt = DateTime.now();
    item.metadata = event.metadata ?? item.metadata;
    return item;
  }

  ToolCallItem? _findTraceItem(ProcessItem process, String id) {
    for (final item in process.children.whereType<ToolCallItem>()) {
      final found = _findTraceItemIn(item, id);
      if (found != null) return found;
    }
    return null;
  }

  ToolCallItem? _findTraceItemIn(ToolCallItem root, String id) {
    if (root.id == id) return root;
    for (final child in root.childToolCalls) {
      final found = _findTraceItemIn(child, id);
      if (found != null) return found;
    }
    return null;
  }

  IconData _toolIcon(String toolName) {
    switch (toolName.toLowerCase()) {
      case 'grep':
        return Icons.search_rounded;
      case 'glob':
        return Icons.travel_explore_rounded;
      case 'read':
      case 'batchread':
        return Icons.article_outlined;
      case 'write':
        return Icons.note_add_outlined;
      case 'edit':
        return Icons.edit_note_rounded;
      case 'ls':
        return Icons.folder_open_outlined;
      case 'move':
        return Icons.drive_file_move_outline;
      case 'remove':
        return Icons.delete_outline_rounded;
      case 'delegate_to_subagent':
        return Icons.account_tree_outlined;
      case 'create_dynamic_timeline_card':
      case 'update_dynamic_timeline_card':
        return Icons.auto_awesome_mosaic_outlined;
      case 'recommend_dynamic_timeline_design_patterns':
      case 'get_dynamic_timeline_design_pattern':
      case 'list_dynamic_timeline_design_patterns':
        return Icons.palette_outlined;
      default:
        return Icons.extension_outlined;
    }
  }

  String _toolDisplayName(String toolName) {
    switch (toolName.toLowerCase()) {
      case 'grep':
        return _agentChat.toolSearch;
      case 'glob':
        return _agentChat.toolFindFiles;
      case 'read':
        return _agentChat.toolRead;
      case 'batchread':
        return _agentChat.toolReadBatch;
      case 'write':
        return _agentChat.toolWrite;
      case 'edit':
        return _agentChat.toolEdit;
      case 'ls':
        return _agentChat.toolList;
      case 'move':
        return _agentChat.toolMove;
      case 'remove':
        return _agentChat.toolDelete;
      case 'delegate_to_subagent':
        return _agentChat.toolDelegateTask;
      case 'create_dynamic_timeline_card':
        return _agentChat.toolCreateUi;
      case 'update_dynamic_timeline_card':
        return _agentChat.toolUpdateUi;
      case 'recommend_dynamic_timeline_design_patterns':
        return _agentChat.toolFindStyles;
      case 'get_dynamic_timeline_design_pattern':
        return _agentChat.toolReadStyle;
      case 'list_dynamic_timeline_design_patterns':
        return _agentChat.toolStyleLibrary;
      case 'save_timeline_card':
        return _agentChat.toolSaveCard;
      case 'create_calendar_event':
        return _agentChat.toolCreateEvent;
      case 'create_reminder':
        return _agentChat.toolCreateReminder;
      case 'cancel_action':
        return _agentChat.toolCancelReminderEvent;
      case 'search_timeline_cards':
        return _agentChat.toolSearchCards;
      case 'inspect_timeline_card':
        return _agentChat.toolInspectCard;
      case 'update_timeline_card_insight':
        return _agentChat.toolUpdateInsight;
      case 'save_knowledge_insight_cards':
        return _agentChat.toolSaveInsights;
      case 'delete_knowledge_insight_card':
        return _agentChat.toolDeleteInsightCard;
      case 'delete_knowledge_insight_tags':
        return _agentChat.toolDeleteInsightTags;
      default:
        return toolName;
    }
  }

  String _toolStatusLabel(ToolCallItem item) {
    if (item.isDelegate && item.status != null) {
      final status = item.status!;
      if (status == 'running') return _agentChat.running;
      if (status == 'completed') return _agentChat.done;
      if (status == 'failed') return _agentChat.failed;
      if (status == 'noOp') return _agentChat.noOp;
      if (status == 'needsParentInput') {
        return _agentChat.needsInput;
      }
    }
    if (item.isRunning) return _agentChat.running;
    if (item.isError) return _agentChat.failed;
    final duration = item.duration;
    if (duration == null) return _agentChat.done;
    final milliseconds = duration.inMilliseconds;
    if (milliseconds < 1000) return '${milliseconds}ms';
    return '${(milliseconds / 1000).toStringAsFixed(1)}s';
  }

  AgentChatCopy get _agentChat => UserStorage.l10n.agentChat;

  String _compactPreview(String value, {int maxLength = 96}) {
    final compact = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.length <= maxLength) return compact;
    return '${compact.substring(0, maxLength)}...';
  }

  String _delegatePreview(ToolCallItem item) {
    final childName = item.label ?? _agentChat.worker;
    final count = item.childTraceCount;
    final countLabel = _agentChat.toolCallCount(count);
    return '$childName · $countLabel';
  }

  Widget _buildThinkingItem(ThinkingItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, size: 12, color: Color(0xFFCBD5E1)),
              const SizedBox(width: 6),
              Text(
                _agentChat.thinking,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          MarkdownBody(
            data: item.text,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCallItem(ToolCallItem item) {
    final statusColor = item.isError
        ? const Color(0xFFEF4444)
        : item.isRunning
            ? AppColors.primary
            : const Color(0xFF10B981);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              item.isExpanded = !item.isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _toolIcon(item.toolName),
                    size: 15,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _toolDisplayName(item.toolName),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.isDelegate
                            ? _delegatePreview(item)
                            : _compactPreview(item.args),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _toolStatusLabel(item),
                  style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  item.isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
        if (item.isExpanded)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.childToolCalls.isNotEmpty) ...[
                  Text(
                    _agentChat.workerToolCalls,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        for (var index = 0;
                            index < item.childToolCalls.length;
                            index++) ...[
                          if (index > 0)
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFF1F5F9),
                            ),
                          _buildToolCallItem(item.childToolCalls[index]),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                if (item.isDelegate && item.result != null) ...[
                  Text(
                    _agentChat.workerResult,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    item.result!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF334155),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Text(
                  _agentChat.arguments,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  item.args,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: Color(0xFF334155),
                    height: 1.35,
                  ),
                ),
                if (item.result != null && !item.isDelegate) ...[
                  const SizedBox(height: 10),
                  Text(
                    _agentChat.result,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    item.result!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: Color(0xFF334155),
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
} // End of _AgentChatDialogState

/// A minimal copy icon shown below AI messages.
/// Only displays a small icon that transitions to a checkmark on success.
class _CopyMessageButton extends StatefulWidget {
  final String text;
  final VoidCallback? onCopied;

  const _CopyMessageButton({required this.text, this.onCopied});

  @override
  State<_CopyMessageButton> createState() => _CopyMessageButtonState();
}

class _CopyMessageButtonState extends State<_CopyMessageButton> {
  bool _copied = false;

  Future<void> _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (!mounted) return;
    setState(() => _copied = true);
    widget.onCopied?.call();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleCopy,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            _copied ? Icons.check_rounded : Icons.copy_outlined,
            key: ValueKey(_copied),
            size: 18,
            color: _copied ? AppColors.success : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
