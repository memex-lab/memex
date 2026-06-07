import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:memex/agent/companion_agent/companion_agent.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/persona_chat_service.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/ui/core/widgets/character_avatar.dart';
import 'package:memex/ui/core/widgets/local_image.dart';
import 'package:memex/utils/tavern_macro.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:intl/intl.dart';

const _personaStageInk = Color(0xFF080B12);
const _personaPanel = Color(0xFF101217);
const _personaPanelSoft = Color(0xFF1B1D24);
const _personaText = Color(0xFFF2ECE0);
const _personaTextMuted = Color(0xFF9E9A94);
const _personaAccent = Color(0xFFE4D6BD);
const _personaAccentCool = Color(0xFF6F7E91);
const _personaLine = Color(0xFF343A45);
const _personaCharacterBubble = Color(0xD9101115);
const _personaUserBubble = Color(0xFFE8DEC8);
const _personaUserBorder = Color(0xFFEFE4CD);

/// 1-on-1 chat screen with an AI companion character.
class PersonaChatScreen extends StatefulWidget {
  final String characterId;
  const PersonaChatScreen({super.key, required this.characterId});

  @override
  State<PersonaChatScreen> createState() => _PersonaChatScreenState();
}

class _PersonaChatScreenState extends State<PersonaChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _chatService = PersonaChatService.instance;

  late String _currentCharacterId = widget.characterId;
  CharacterModel? _character;
  String? _userId;
  String? _userAvatar;
  List<PersonaChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isStreaming = false;
  String _streamingText = '';

  // Pagination state — WeChat/WhatsApp style: load older messages on scroll-up
  static const int _pageSize = 30;
  bool _hasMoreHistory = true;
  bool _isLoadingMore = false;

  // Cached MarkdownStyleSheet — avoid recreating on every build
  static final _cachedMarkdownStyle = MarkdownStyleSheet(
    p: const TextStyle(
      fontSize: 15,
      height: 1.68,
      color: _personaText,
    ),
    strong: const TextStyle(
      fontWeight: FontWeight.w700,
      color: _personaText,
    ),
    em: const TextStyle(fontStyle: FontStyle.italic),
    listBullet: const TextStyle(color: _personaAccent),
    code: const TextStyle(
      fontSize: 13,
      color: _personaText,
      backgroundColor: Color(0xFF241615),
      fontFamily: 'monospace',
    ),
    codeblockDecoration: BoxDecoration(
      color: const Color(0xFF241615),
      borderRadius: BorderRadius.circular(8),
    ),
  );

  @override
  void initState() {
    super.initState();
    _init();
    _scrollController.addListener(_onScroll);
    EventBusService.instance.addHandler(
      EventBusMessageType.personaChatMessageAdded,
      _onPersonaChatMessageAdded,
    );
  }

  Future<void> _init() async {
    final userId = await UserStorage.getUserId();
    if (userId == null) return;
    final userAvatar = await MemexRouter().getUserAvatar();

    final character = await CharacterService.instance
        .getCharacter(userId, _currentCharacterId);

    final messages = await _chatService.getMessages(
      _currentCharacterId,
      limit: _pageSize,
    );
    await _chatService.markAllRead(_currentCharacterId);

    // If this is the first chat and the character has a greeting, deliver it.
    if (messages.isEmpty &&
        character != null &&
        character.firstMessage != null &&
        character.firstMessage!.trim().isNotEmpty) {
      final greeting = TavernMacro.resolve(
        character.firstMessage!,
        userName: userId,
        charName: character.name,
      );
      await _chatService.addCharacterMessage(
        _currentCharacterId,
        greeting,
        isRead: true,
      );
      // Reload after inserting greeting.
      final updatedMessages = await _chatService.getMessages(
        _currentCharacterId,
        limit: _pageSize,
      );
      if (mounted) {
        setState(() {
          _character = character;
          _userId = userId;
          _userAvatar = userAvatar;
          _messages = updatedMessages;
          _hasMoreHistory = updatedMessages.length >= _pageSize;
          _isLoading = false;
        });
        _scrollToBottom();
      }
      return;
    }

    if (mounted) {
      setState(() {
        _character = character;
        _userId = userId;
        _userAvatar = userAvatar;
        _messages = messages;
        _hasMoreHistory = messages.length >= _pageSize;
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    EventBusService.instance.removeHandler(
      EventBusMessageType.personaChatMessageAdded,
      _onPersonaChatMessageAdded,
    );
    _scrollController.removeListener(_onScroll);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Triggered when user scrolls toward the top (older messages).
  /// Since the list is reversed, maxScrollExtent = oldest direction.
  void _onScroll() {
    if (!_hasMoreHistory || _isLoadingMore) return;
    final pos = _scrollController.position;
    // Trigger load when within 20% of the top (maxScrollExtent in reversed list)
    if (pos.pixels >= pos.maxScrollExtent * 0.8) {
      _loadMoreHistory();
    }
  }

  /// Loads the next page of older messages and prepends them to the list.
  Future<void> _loadMoreHistory() async {
    if (_isLoadingMore || !_hasMoreHistory) return;
    setState(() => _isLoadingMore = true);

    final olderMessages = await _chatService.getMessages(
      _currentCharacterId,
      limit: _pageSize,
      offset: _messages.length,
    );

    if (!mounted) return;
    setState(() {
      _messages = [..._messages, ...olderMessages];
      _hasMoreHistory = olderMessages.length >= _pageSize;
      _isLoadingMore = false;
    });
  }

  void _onPersonaChatMessageAdded(EventBusMessage message) {
    if (message is! PersonaChatMessageAddedMessage) return;
    if (message.characterId != _currentCharacterId) return;
    if (!mounted) return;
    // New message arrived — reload the latest page and keep any older
    // messages that were already loaded via pagination.
    _chatService
        .getMessages(_currentCharacterId, limit: _messages.length + 5)
        .then((updated) {
      if (!mounted) return;
      setState(() => _messages = updated);
      _scrollToBottom();
    });
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isStreaming) return;

    _textController.clear();

    final userMessageTime = DateTime.now();

    // Persist user message
    await _chatService.addUserMessage(_currentCharacterId, text,
        timestamp: userMessageTime);

    // Reload messages to show user's message (preserve loaded history depth)
    final messages = await _chatService.getMessages(
      _currentCharacterId,
      limit: _messages.length + 1,
    );
    setState(() {
      _messages = messages;
      _isStreaming = true;
      _streamingText = '';
    });
    _scrollToBottom();

    // Get LLM resources
    final userId = await UserStorage.getUserId();
    if (userId == null) return;

    try {
      final resources = await UserStorage.getAgentLLMResources(
        AgentDefinitions.companionAgent,
        defaultClientKey: LLMConfig.defaultClientKey,
      );

      final buffer = StringBuffer();
      await for (final chunk in CompanionAgent.chat(
        client: resources.client,
        modelConfig: resources.modelConfig,
        userId: userId,
        characterId: _currentCharacterId,
        userMessage: text,
        userMessageTime: userMessageTime,
      )) {
        buffer.write(chunk);
        if (mounted) {
          setState(() => _streamingText = buffer.toString());
          _scrollToBottom();
        }
      }

      // Persist character response
      final fullResponse = buffer.toString().trim();
      if (fullResponse.isNotEmpty) {
        await _chatService.addCharacterMessage(
          _currentCharacterId,
          fullResponse,
          isRead: true, // User is looking at it
          timestamp: DateTime.now(),
        );
      }

      // Reload messages
      final updated = await _chatService.getMessages(
        _currentCharacterId,
        limit: _messages.length + 1,
      );
      if (mounted) {
        setState(() {
          _messages = updated;
          _isStreaming = false;
          _streamingText = '';
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isStreaming = false;
          _streamingText = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get response: $e')),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 16));
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _switchCharacter() async {
    if (_isStreaming) return;

    final userId = await UserStorage.getUserId();
    if (userId == null) return;

    final characters = await CharacterService.instance.getAllCharacters(userId);
    final enabled = characters.where((c) => c.enabled).toList();
    if (enabled.length <= 1 || !mounted) return;

    final selected = await _CharacterSwitcherSheet.show(
      context,
      characters: enabled,
      currentId: _currentCharacterId,
    );

    if (selected != null && selected.id != _currentCharacterId && mounted) {
      // Set as primary companion
      await CharacterService.instance.setPrimaryCompanion(userId, selected.id);

      // Switch to new character
      setState(() {
        _currentCharacterId = selected.id;
        _isLoading = true;
        _hasMoreHistory = true;
        _isLoadingMore = false;
      });
      await _init();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _personaStageInk,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: _ChatAtmosphereBackground(character: _character),
                  ),
                ),
                Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top),
                    _buildHeader(),
                    Expanded(child: _buildMessageList()),
                    _buildInputBar(),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    final character = _character;

    final content = Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const _FrostedCircleButton(
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _personaText,
                size: 17,
              ),
            ),
          ),
          if (character != null) ...[
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: _isStreaming ? null : _switchCharacter,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      padding: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _personaAccent.withValues(alpha: 0.72),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.42),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: CharacterAvatar(
                        avatar: character.avatar,
                        name: character.name,
                        size: 41,
                        backgroundColor: _personaPanelSoft,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        character.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          height: 1.1,
                          fontWeight: FontWeight.w600,
                          color: _personaText,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 19,
                      color: _isStreaming ? _personaTextMuted : _personaAccent,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return content;
  }

  Widget _buildMessageList() {
    // Show typing indicator or streaming bubble at the end
    final showStreamingBubble = _isStreaming && _streamingText.isNotEmpty;
    final showTypingIndicator = _isStreaming && _streamingText.isEmpty;
    final extraItems = (showStreamingBubble || showTypingIndicator) ? 1 : 0;
    // Extra item at the tail (top of reversed list) for load-more indicator
    final loadMoreItem = (_hasMoreHistory || _isLoadingMore) ? 1 : 0;
    final itemCount = _messages.length + extraItems + loadMoreItem;

    if (_messages.isEmpty && extraItems == 0) return _buildEmptyState();

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.fromLTRB(10, 8, 12, 10),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Typing indicator or streaming message at the bottom (index 0 in reversed list)
        if (extraItems == 1 && index == 0) {
          if (showTypingIndicator) {
            return _buildTypingIndicator();
          }
          return _buildBubble(
            text: _streamingText,
            isCharacter: true,
            isStreaming: true,
          );
        }

        // Load-more indicator at the top (last index in reversed list)
        if (loadMoreItem == 1 && index == itemCount - 1) {
          return _buildLoadMoreIndicator();
        }

        final messageIndex = _messageIndexForListIndex(
          listIndex: index,
          extraItems: extraItems,
        );
        final msg = _messages[messageIndex];
        final showDate = _shouldShowDateDivider(
          messageIndex,
          _messages,
        );

        return Column(
          children: [
            if (showDate) _buildDateDivider(msg.timestamp),
            if (msg.messageType == 'action')
              _buildActionMessage(text: msg.content)
            else
              _buildBubble(
                text: msg.content,
                isCharacter: msg.isFromCharacter,
              ),
          ],
        );
      },
    );
  }

  int _messageIndexForListIndex({
    required int listIndex,
    required int extraItems,
  }) {
    return personaChatMessageIndexForReversedList(
      listIndex: listIndex,
      extraItems: extraItems,
    );
  }

  bool _shouldShowDateDivider(
    int messageIndex,
    List<PersonaChatMessage> messages,
  ) {
    // Always show timestamp for the oldest loaded message
    if (messageIndex == messages.length - 1) return true;
    // Show timestamp when gap between adjacent messages exceeds 10 minutes
    // (WeChat/WhatsApp convention)
    final current = messages[messageIndex].timestamp;
    final previous = messages[messageIndex + 1].timestamp;
    return current.difference(previous).inMinutes.abs() >= 10;
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 52, 32, 24),
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _personaPanelSoft.withValues(alpha: 0.94),
                      _personaAccent.withValues(alpha: 0.2),
                    ],
                  ),
                  border: Border.all(
                    color: _personaAccent.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _personaAccent.withValues(alpha: 0.18),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: CharacterAvatar(
                  avatar: _character?.avatar,
                  name: _character?.name ?? '',
                  size: 96,
                  backgroundColor: Colors.transparent,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _character?.name ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _personaText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateDivider(DateTime date) {
    final label = _formatTimeDivider(date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _personaPanel.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: _personaTextMuted),
          ),
        ),
      ),
    );
  }

  /// Formats a timestamp for the chat time divider, following WeChat conventions:
  /// - Today: "HH:mm"
  /// - Yesterday: "昨天 HH:mm" / "Yesterday HH:mm"
  /// - This week (within 7 days): "周三 HH:mm" / "Wed HH:mm"
  /// - This year: "3月15日 HH:mm" / "Mar 15 HH:mm"
  /// - Older: "2024年3月15日 HH:mm" / "Mar 15, 2024 HH:mm"
  String _formatTimeDivider(DateTime date) {
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

  Widget _buildLoadMoreIndicator() {
    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: _personaAccentCool,
            ),
          ),
        ),
      );
    }
    // Invisible sentinel — the scroll listener handles triggering the load.
    return const SizedBox(height: 1);
  }

  /// Renders a narrative / action description message.
  /// No speech bubble — italic text centred with a subtle divider style,
  /// matching the roleplay convention for stage directions.
  Widget _buildActionMessage({required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 0.5,
              color: _personaLine.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 0,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.68,
              ),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                  color: _personaTextMuted,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 0.5,
              color: _personaLine.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble({
    required String text,
    required bool isCharacter,
    bool isStreaming = false,
  }) {
    if (isCharacter) {
      return _buildCharacterBubble(text: text, isStreaming: isStreaming);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 54),
          Flexible(
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.68,
                ),
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                decoration: BoxDecoration(
                  color: _personaUserBubble.withValues(alpha: 0.9),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(6),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                  border: Border.all(
                    color: _personaUserBorder.withValues(alpha: 0.82),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _personaUserBorder.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.55,
                    color: Color(0xFF2D2923),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 46,
            child: Align(
              alignment: Alignment.topRight,
              child: _UserAvatar(
                avatar: _userAvatar,
                name: _userId ?? '',
                size: 34,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterBubble({
    required String text,
    required bool isStreaming,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 46,
            child: Align(
              alignment: Alignment.topLeft,
              child: _FramedCharacterAvatar(
                avatar: _character?.avatar,
                name: _character?.name ?? '',
                size: 40,
              ),
            ),
          ),
          Flexible(
            child: Align(
              alignment: Alignment.topLeft,
              child: _CharacterMessageFrame(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: MarkdownBody(
                        data: text,
                        softLineBreak: true,
                        styleSheet: _cachedMarkdownStyle,
                      ),
                    ),
                    if (isStreaming) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 8,
                        height: 8,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: _personaAccent,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 54),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 46,
            child: Align(
              alignment: Alignment.topLeft,
              child: _FramedCharacterAvatar(
                avatar: _character?.avatar,
                name: _character?.name ?? '',
                size: 40,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            decoration: BoxDecoration(
              color: _personaCharacterBubble,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border.all(
                color: _personaLine.withValues(alpha: 0.7),
              ),
              boxShadow: [
                BoxShadow(
                  color: _personaLine.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return PersonaChatInputBar(
      controller: _textController,
      isStreaming: _isStreaming,
      onSend: _sendMessage,
      hintText: UserStorage.l10n.personaChatInputHint,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

@visibleForTesting
int personaChatMessageIndexForReversedList({
  required int listIndex,
  required int extraItems,
}) {
  return listIndex - extraItems;
}

class _ChatAtmosphereBackground extends StatelessWidget {
  const _ChatAtmosphereBackground({required this.character});

  final CharacterModel? character;

  @override
  Widget build(BuildContext context) {
    final bgPath = character?.chatBackground;
    final hasCustomBg =
        bgPath != null && bgPath.isNotEmpty && File(bgPath).existsSync();

    return Stack(
      children: [
        if (hasCustomBg)
          Positioned.fill(
            child: LocalImage(
              url: bgPath,
              fit: BoxFit.cover,
            ),
          )
        else
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF070A11),
                  Color(0xFF131923),
                  Color(0xFF060607),
                ],
                stops: [0, 0.54, 1],
              ),
            ),
          ),
        if (!hasCustomBg && character != null)
          Positioned.fill(
            child: Opacity(
              opacity: 0.22,
              child: Transform.scale(
                scale: 1.5,
                alignment: Alignment.centerRight,
                child: Align(
                  alignment: const Alignment(0.92, -0.16),
                  child: CharacterAvatar(
                    avatar: character!.avatar,
                    name: character!.name,
                    size: MediaQuery.sizeOf(context).shortestSide * 0.95,
                    backgroundColor: _personaPanelSoft,
                  ),
                ),
              ),
            ),
          ),
        if (!hasCustomBg)
          Positioned.fill(
            child: CustomPaint(
              painter: _ChatTexturePainter(),
            ),
          ),
        if (!hasCustomBg) ...[
          Positioned(
            top: -88,
            left: -72,
            child: _AtmosphereGlow(
              size: 240,
              color: const Color(0xFF40516A).withValues(alpha: 0.2),
            ),
          ),
          Positioned(
            top: 84,
            right: -96,
            child: _AtmosphereGlow(
              size: 280,
              color: _personaAccent.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            bottom: 76,
            left: -120,
            child: _AtmosphereGlow(
              size: 320,
              color: const Color(0xFF334154).withValues(alpha: 0.15),
            ),
          ),
        ],
        if (hasCustomBg)
          // Bottom-up dark gradient: solid dark at bottom (input bar area),
          // fades to transparent around the first message zone so the
          // background image emerges naturally upward. No top overlay.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0xFF080B12),
                    const Color(0xFF080B12).withValues(alpha: 0.92),
                    const Color(0xFF080B12).withValues(alpha: 0.55),
                    Colors.transparent,
                    Colors.transparent,
                  ],
                  stops: const [0, 0.10, 0.30, 0.50, 1],
                ),
              ),
            ),
          )
        else
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.16),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.34),
                  ],
                  stops: const [0, 0.2, 0.7, 1],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ChatTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1;
    for (var y = 48.0; y < size.height; y += 72) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + 18),
        linePaint,
      );
    }

    final dotPaint = Paint()
      ..color = _personaAccent.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;
    for (var y = 36.0; y < size.height; y += 56) {
      for (var x = 24.0; x < size.width; x += 64) {
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AtmosphereGlow extends StatelessWidget {
  const _AtmosphereGlow({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 46, sigmaY: 46),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _CharacterMessageFrame extends StatelessWidget {
  const _CharacterMessageFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.72,
      ),
      padding: const EdgeInsets.fromLTRB(18, 13, 18, 13),
      decoration: BoxDecoration(
        color: _personaCharacterBubble,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(7),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.34),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FramedCharacterAvatar extends StatelessWidget {
  const _FramedCharacterAvatar({
    required this.avatar,
    required this.name,
    required this.size,
  });

  final String? avatar;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.38),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: CharacterAvatar(
        avatar: avatar,
        name: name,
        size: size - 3,
        backgroundColor: _personaPanelSoft,
      ),
    );
  }
}

class _FrostedCircleButton extends StatelessWidget {
  const _FrostedCircleButton({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _personaPanel.withValues(alpha: 0.62),
        border: Border.all(color: _personaAccent.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.34),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: IconTheme(
        data: const IconThemeData(color: _personaText),
        child: child,
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({
    required this.avatar,
    required this.name,
    required this.size,
  });

  final String? avatar;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CharacterAvatar(
      avatar:
          avatar ?? (name.isNotEmpty ? name : UserStorage.defaultAvatarSeed),
      name: name,
      size: size,
      backgroundColor: _personaAccentCool.withValues(alpha: 0.22),
    );
  }
}

@visibleForTesting
class PersonaChatInputBar extends StatelessWidget {
  const PersonaChatInputBar({
    super.key,
    required this.controller,
    required this.isStreaming,
    required this.onSend,
    required this.hintText,
  });

  final TextEditingController controller;
  final bool isStreaming;
  final VoidCallback onSend;
  final String hintText;

  bool _canSend(String value) => !isStreaming && value.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 10, 14, bottomPadding + 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 34,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: _personaAccent.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final canSend = _canSend(value.text);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: const TextStyle(
                        color: _personaTextMuted,
                        fontSize: 15,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 10,
                      ),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.35,
                      color: _personaText,
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) {
                      if (canSend) onSend();
                    },
                    enabled: !isStreaming,
                  ),
                ),
                const SizedBox(width: 8),
                _SendButton(
                  enabled: canSend,
                  onTap: onSend,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Send message',
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: enabled
                ? _personaAccent.withValues(alpha: 0.78)
                : Colors.white.withValues(alpha: 0.08),
            border: Border.all(
              color: enabled
                  ? _personaAccent.withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.08),
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: _personaAccent.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            Icons.send_rounded,
            color: enabled ? const Color(0xFF5B5346) : _personaTextMuted,
            size: 22,
          ),
        ),
      ),
    );
  }
}

/// Animated three-dot typing indicator.
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Stagger each dot by 0.2
            final delay = i * 0.2;
            final t = (_controller.value - delay) % 1.0;
            // Bounce: peak at 0.3, back to 0 at 0.6
            final offset = t < 0.3
                ? -4.0 * (t / 0.3)
                : t < 0.6
                    ? -4.0 * (1 - (t - 0.3) / 0.3)
                    : 0.0;
            return Padding(
              padding: EdgeInsets.only(right: i < 2 ? 4 : 0),
              child: Transform.translate(
                offset: Offset(0, offset),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: _personaAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Bottom sheet for switching companion characters.
class _CharacterSwitcherSheet extends StatelessWidget {
  final List<CharacterModel> characters;
  final String? currentId;

  const _CharacterSwitcherSheet({
    required this.characters,
    this.currentId,
  });

  static Future<CharacterModel?> show(
    BuildContext context, {
    required List<CharacterModel> characters,
    String? currentId,
  }) {
    return showModalBottomSheet<CharacterModel>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CharacterSwitcherSheet(
        characters: characters,
        currentId: currentId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UserStorage.l10n;
    return Container(
      decoration: BoxDecoration(
        color: _personaPanel.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.switchCompanion,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _personaText,
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: characters.length,
                itemBuilder: (context, index) {
                  final char = characters[index];
                  final isCurrent = char.id == currentId;
                  return ListTile(
                    leading: CharacterAvatar(
                      avatar: char.avatar,
                      name: char.name,
                      size: 40,
                      backgroundColor: _personaAccent.withValues(alpha: 0.18),
                    ),
                    title: Text(
                      char.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isCurrent ? FontWeight.w600 : FontWeight.w400,
                        color: _personaText,
                      ),
                    ),
                    subtitle: char.tags.isNotEmpty
                        ? Text(
                            char.tags.join(' · '),
                            style: const TextStyle(
                              fontSize: 12,
                              color: _personaTextMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    trailing: isCurrent
                        ? const Icon(Icons.check_circle,
                            color: _personaAccent, size: 20)
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: isCurrent
                        ? () => Navigator.pop(context)
                        : () => Navigator.pop(context, char),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
