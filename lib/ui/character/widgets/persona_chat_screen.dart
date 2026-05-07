import 'dart:async';
import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:memex/agent/companion_agent/companion_agent.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/data/services/persona_chat_service.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/ui/core/widgets/back_button.dart';
import 'package:memex/ui/core/widgets/dicebear_avatar.dart';
import 'package:memex/utils/time_context.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:intl/intl.dart';

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
  List<PersonaChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isStreaming = false;
  String _streamingText = '';

  // Keep LLM history for context window
  final List<LLMMessage> _llmHistory = [];
  static const int _maxHistoryMessages = 30;

  String _withMessageTime(DateTime timestamp, String content) {
    return '${buildMessageTimePrefix(timestamp)}$content';
  }

  LLMMessage _historyMessageFor(PersonaChatMessage msg) {
    final content = _withMessageTime(msg.timestamp, msg.content);
    if (msg.isFromCharacter) {
      return ModelMessage(model: 'history', textOutput: content);
    }
    return UserMessage([TextPart(content)]);
  }

  String get _avatarSeed {
    if (_character?.avatar != null && _character!.avatar!.isNotEmpty) {
      return _character!.avatar!;
    }
    return 'companion_${_character?.name ?? ''}';
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final userId = await UserStorage.getUserId();
    if (userId == null) return;

    final character = await CharacterService.instance
        .getCharacter(userId, _currentCharacterId);

    final messages = await _chatService.getMessages(_currentCharacterId);
    await _chatService.markAllRead(_currentCharacterId);

    // Build LLM history from persisted messages
    _llmHistory.clear();
    final reversed = messages.reversed.toList();
    for (final msg in reversed) {
      _llmHistory.add(_historyMessageFor(msg));
    }
    // Trim to max
    if (_llmHistory.length > _maxHistoryMessages) {
      _llmHistory.removeRange(0, _llmHistory.length - _maxHistoryMessages);
    }

    if (mounted) {
      setState(() {
        _character = character;
        _messages = reversed;
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    // Trigger memory update in background when leaving chat
    _updateMemoryInBackground();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateMemoryInBackground() async {
    if (_llmHistory.isEmpty) return;
    final userId = await UserStorage.getUserId();
    if (userId == null) return;

    try {
      final resources = await UserStorage.getAgentLLMResources(
        AgentDefinitions.chatAgent,
        defaultClientKey: LLMConfig.defaultClientKey,
      );
      // Fire and forget — don't block dispose
      CompanionAgent.onConversationEnd(
        client: resources.client,
        modelConfig: resources.modelConfig,
        userId: userId,
        characterId: _currentCharacterId,
        conversation: _llmHistory,
      );
    } catch (_) {}
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isStreaming) return;

    _textController.clear();

    final userMessageTime = DateTime.now();

    // Persist user message
    await _chatService.addUserMessage(_currentCharacterId, text,
        timestamp: userMessageTime);

    // Add to LLM history
    _llmHistory.add(
        UserMessage([TextPart(_withMessageTime(userMessageTime, text))]));

    // Reload messages to show user's message
    final messages = await _chatService.getMessages(_currentCharacterId);
    setState(() {
      _messages = messages.reversed.toList();
      _isStreaming = true;
      _streamingText = '';
    });
    _scrollToBottom();

    // Get LLM resources
    final userId = await UserStorage.getUserId();
    if (userId == null) return;

    try {
      final resources = await UserStorage.getAgentLLMResources(
        AgentDefinitions.chatAgent,
        defaultClientKey: LLMConfig.defaultClientKey,
      );

      // Trim history before sending
      final historyToSend = _llmHistory.length > _maxHistoryMessages
          ? _llmHistory.sublist(_llmHistory.length - _maxHistoryMessages)
          : List<LLMMessage>.from(_llmHistory);
      // Remove the last user message since CompanionAgent.chat adds it
      if (historyToSend.isNotEmpty) historyToSend.removeLast();

      final buffer = StringBuffer();
      await for (final chunk in CompanionAgent.chat(
        client: resources.client,
        modelConfig: resources.modelConfig,
        userId: userId,
        characterId: _currentCharacterId,
        userMessage: text,
        userMessageTime: userMessageTime,
        history: historyToSend,
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
        final responseTime = DateTime.now();
        await _chatService.addCharacterMessage(
          _currentCharacterId,
          fullResponse,
          isRead: true, // User is looking at it
          timestamp: responseTime,
        );
        _llmHistory.add(ModelMessage(
            model: 'companion',
            textOutput: _withMessageTime(responseTime, fullResponse)));
      }

      // Reload messages
      final updated = await _chatService.getMessages(_currentCharacterId);
      if (mounted) {
        setState(() {
          _messages = updated.reversed.toList();
          _isStreaming = false;
          _streamingText = '';
        });
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
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
      // Save memory for current conversation before switching
      _updateMemoryInBackground();

      // Set as primary companion
      await CharacterService.instance.setPrimaryCompanion(userId, selected.id);

      // Switch to new character
      setState(() {
        _currentCharacterId = selected.id;
        _isLoading = true;
      });
      await _init();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const AppBackButton(),
        title: _character == null
            ? null
            : GestureDetector(
                onTap: _isStreaming ? null : _switchCharacter,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DiceBearAvatar(
                      seed: _avatarSeed,
                      size: 28,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _character!.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.unfold_more,
                      size: 18,
                      color: _isStreaming
                          ? AppColors.textTertiary
                          : AppColors.primary,
                    ),
                  ],
                ),
              ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(child: _buildMessageList()),
                _buildInputBar(),
              ],
            ),
    );
  }

  Widget _buildMessageList() {
    // Show typing indicator or streaming bubble at the end
    final showStreamingBubble = _isStreaming && _streamingText.isNotEmpty;
    final showTypingIndicator = _isStreaming && _streamingText.isEmpty;
    final extraItems = (showStreamingBubble || showTypingIndicator) ? 1 : 0;
    final itemCount = _messages.length + extraItems;

    if (itemCount == 0) return _buildEmptyState();

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Typing indicator or streaming message at the end
        if (index == _messages.length) {
          if (showTypingIndicator) {
            return _buildTypingIndicator();
          }
          return _buildBubble(
            text: _streamingText,
            isCharacter: true,
            isStreaming: true,
          );
        }

        final msg = _messages[index];
        final showDate = index == 0 ||
            !_isSameDay(msg.timestamp, _messages[index - 1].timestamp);

        return Column(
          children: [
            if (showDate) _buildDateDivider(msg.timestamp),
            _buildBubble(
              text: msg.content,
              isCharacter: msg.isFromCharacter,
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: DiceBearAvatar(
                seed: _avatarSeed,
                size: 64,
                backgroundColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _character?.name ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (_character != null && _character!.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _character!.tags.join(' · '),
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textTertiary),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Say hi 👋',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateDivider(DateTime date) {
    final now = DateTime.now();
    String label;
    if (_isSameDay(date, now)) {
      label = 'Today';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      label = 'Yesterday';
    } else {
      label = DateFormat('MMM d').format(date);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
      ),
    );
  }

  Widget _buildBubble({
    required String text,
    required bool isCharacter,
    bool isStreaming = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isCharacter ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCharacter) ...[
            DiceBearAvatar(
              seed: _avatarSeed,
              size: 32,
              backgroundColor: AppColors.primary.withValues(alpha: 0.08),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isCharacter ? Colors.white : AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isCharacter ? 4 : 16),
                  bottomRight: Radius.circular(isCharacter ? 16 : 4),
                ),
                boxShadow: isCharacter
                    ? [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: isCharacter
                        ? MarkdownBody(
                            data: text,
                            softLineBreak: true,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: AppColors.textPrimary,
                              ),
                              strong: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              em: const TextStyle(fontStyle: FontStyle.italic),
                              listBullet:
                                  const TextStyle(color: AppColors.primary),
                              code: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                backgroundColor: Color(0xFFF7F8FA),
                                fontFamily: 'monospace',
                              ),
                              codeblockDecoration: BoxDecoration(
                                color: const Color(0xFFF7F8FA),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          )
                        : Text(
                            text,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  if (isStreaming) ...[
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 8,
                      height: 8,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (!isCharacter) const SizedBox(width: 8),
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
          DiceBearAvatar(
            seed: _avatarSeed,
            size: 32,
            backgroundColor: AppColors.primary.withValues(alpha: 0.08),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
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
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 8, 16, MediaQuery.of(context).padding.bottom + 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Message...',
                hintStyle: const TextStyle(
                    color: AppColors.textTertiary, fontSize: 15),
                filled: true,
                fillColor: AppColors.background,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontSize: 15),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              enabled: !_isStreaming,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isStreaming ? null : _sendMessage,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color:
                    _isStreaming ? AppColors.textTertiary : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
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
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
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

  String _avatarSeed(CharacterModel char) {
    if (char.avatar != null && char.avatar!.isNotEmpty) return char.avatar!;
    return 'companion_${char.name}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UserStorage.l10n;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.switchCompanion,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
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
                    leading: DiceBearAvatar(
                      seed: _avatarSeed(char),
                      size: 40,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.08),
                    ),
                    title: Text(
                      char.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isCurrent ? FontWeight.w600 : FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: char.tags.isNotEmpty
                        ? Text(
                            char.tags.join(' · '),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    trailing: isCurrent
                        ? const Icon(Icons.check_circle,
                            color: AppColors.primary, size: 20)
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
