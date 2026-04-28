import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/model/chat_events.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';
import 'package:go_router/go_router.dart';
import 'package:memex/routing/routes.dart';
import 'package:memex/ui/core/themes/app_colors.dart';

// --- Display Models ---

abstract class ChatDisplayItem {}

class UserMessageItem extends ChatDisplayItem {
  final String text;
  final List<Map<String, String>>? refs;
  UserMessageItem(this.text, {this.refs});
}

class AIMessageItem extends ChatDisplayItem {
  String text;
  bool isStreaming;
  AIMessageItem(this.text, {this.isStreaming = false});
}

class ThinkingItem extends ChatDisplayItem {
  String text;
  bool isExpanded;
  bool isFinished;
  ThinkingItem(this.text, {this.isExpanded = true, this.isFinished = false});
}

class ToolCallItem extends ChatDisplayItem {
  final String toolName;
  final String args;
  String? result;
  bool isError;
  bool isExpanded;

  ToolCallItem(this.toolName, this.args,
      {this.result, this.isError = false, this.isExpanded = false});
}

class ErrorItem extends ChatDisplayItem {
  final String error;
  ErrorItem(this.error);
}

class ProcessItem extends ChatDisplayItem {
  final List<ChatDisplayItem> children = [];
  bool isExpanded;
  bool isFinished;
  ProcessItem({this.isExpanded = true, this.isFinished = false});
}

/// Agent Chat Dialog with Real-time Event Streaming
class AgentChatDialog extends StatefulWidget {
  final String? agentName;
  final String title;
  final String? initialSessionId;
  final String inputHint;
  final String scene;
  final String? sceneId;
  final List<Map<String, String>>? initialRefs;

  const AgentChatDialog({
    super.key,
    this.agentName,
    this.title = 'AI Assistant',
    this.initialSessionId,
    this.inputHint = 'Ask something...',
    this.scene = 'assistant',
    this.sceneId,
    this.initialRefs,
  });

  @override
  State<AgentChatDialog> createState() => _AgentChatDialogState();
}

class _AgentChatDialogState extends State<AgentChatDialog>
    with SingleTickerProviderStateMixin {
  final Logger _logger = getLogger('AgentChatDialog');

  // Services
  final MemexRouter _memexRouter = MemexRouter();

  // State
  List<ChatDisplayItem> _items = [];
  String? _currentSessionId;
  bool _isLoading = false;
  bool _isStreaming = false;
  bool _isLoadingAgent = false;
  ChatTokenUsageEvent? _lastTokenUsage;
  bool _isReadOnly = false;
  // Whether the user has sent at least one message in normal mode — prevents switching to read-only.
  bool _hasSentInNormalMode = false;

  // Controllers
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  StreamSubscription<ChatEvent>? _chatSubscription;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _contextSent = false;

  @override
  void initState() {
    super.initState();
    _currentSessionId = widget.initialSessionId;

    // Animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();

    if (_currentSessionId != null) {
      _loadSessionHistory();
    }
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    _controller.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  // --- Logic ---

  Future<void> _loadSessionHistory() async {
    if (_currentSessionId == null) return;
    setState(() => _isLoading = true);

    try {
      // Note: We still use MemexRouter (or directly file service via a helper) to fetch history.
      // Since ChatService doesn't expose fetchHistory yet, reusing existing endpoint logic is fine.
      final sessionData =
          await _memexRouter.fetchChatSessionDetail(_currentSessionId!);
      final messagesData = sessionData['messages'] as List<dynamic>? ?? [];

      final historyItems = <ChatDisplayItem>[];
      for (var msg in messagesData) {
        final role = msg['role'] as String? ?? 'user';
        final contentList = msg['content'] as List<dynamic>? ?? [];
        final textParts = contentList
            .where((item) => item['type'] == 'text')
            .map((item) => item['text'] as String? ?? '')
            .where((text) => text.isNotEmpty);
        final text = textParts.join(' ');

        if (text.isNotEmpty) {
          if (role == 'user') {
            List<Map<String, String>>? refs;
            if (msg['refs'] != null) {
              refs = (msg['refs'] as List)
                  .map((e) => Map<String, String>.from(e as Map))
                  .toList();
            }
            historyItems.add(UserMessageItem(text, refs: refs));
          } else {
            historyItems.add(AIMessageItem(text));
          }
        }
      }

      ChatTokenUsageEvent? restoredUsage;
      if (sessionData['total_usage'] != null) {
        final usage = sessionData['total_usage'] as Map<String, dynamic>;
        restoredUsage = ChatTokenUsageEvent(
          promptTokens: usage['prompt_tokens'] as int? ?? 0,
          completionTokens: usage['completion_tokens'] as int? ?? 0,
          cachedTokens: usage['cached_tokens'] as int? ?? 0,
          totalTokens: usage['total_tokens'] as int? ?? 0,
          estimatedCost: usage['total_cost'] as double? ?? 0.0,
        );
      }

      setState(() {
        _items = historyItems;
        _lastTokenUsage = restoredUsage;
        _isLoading = false;
        // Restore read-only mode from persisted session
        final wasQuickQuery = sessionData['is_quick_query'] == true;
        _isReadOnly = wasQuickQuery;
        // If session was in normal mode (or field missing for old sessions), lock toggle
        _hasSentInNormalMode = !wasQuickQuery;
      });
      _scrollToBottom();
    } catch (e) {
      _logger.severe('Error loading history', e);
      setState(() => _isLoading = false);
      if (mounted) ToastHelper.showError(context, 'Failed to load history: $e');
    }
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty || _isStreaming) return;

    _messageFocusNode.unfocus();
    String finalMessage = message.trim();
    List<Map<String, String>>? refs;
    if (widget.initialRefs != null && !_contextSent) {
      refs = widget.initialRefs;
      _contextSent = true;
    }

    // Lock read-only toggle once user sends in normal mode
    if (!_isReadOnly) {
      _hasSentInNormalMode = true;
    }

    setState(() {
      _items.add(UserMessageItem(finalMessage, refs: refs));
      _isStreaming = true;
      _messageController.clear();
    });
    _scrollToBottom();

    _chatSubscription?.cancel();

    _chatSubscription = _memexRouter
        .sendMessage(
      finalMessage,
      sessionId: _currentSessionId,
      agentName: widget.agentName,
      scene: widget.scene,
      sceneId: widget.sceneId,
      refs: refs,
      isQuickQuery: _isReadOnly,
    )
        .listen(
      (event) {
        _handleChatEvent(event);
      },
      onError: (e) {
        setState(() {
          _items.add(ErrorItem(e.toString()));
          _isStreaming = false;
        });
        _scrollToBottom();
      },
      onDone: () {
        setState(() {
          _isStreaming = false;
          // Ensure the last AI message is marked as done
          if (_items.isNotEmpty && _items.last is AIMessageItem) {
            (_items.last as AIMessageItem).isStreaming = false;
          }
        });
      },
    );
  }

  void _handleChatEvent(ChatEvent event) {
    setState(() {
      if (event is ChatAgentStartedEvent) {
        _isLoadingAgent = true;
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
        return;
      }

      // Handle Thoughts and Tools (Grouping)
      if (event is ChatThoughtChunkEvent ||
          event is ChatToolCallEvent ||
          event is ChatToolResultEvent) {
        ProcessItem processItem;
        if (_items.isNotEmpty && _items.last is ProcessItem) {
          processItem = _items.last as ProcessItem;
        } else {
          processItem = ProcessItem();
          _items.add(processItem);
        }

        if (event is ChatThoughtChunkEvent) {
          if (processItem.children.isNotEmpty &&
              processItem.children.last is ThinkingItem) {
            (processItem.children.last as ThinkingItem).text += event.text;
          } else {
            processItem.children.add(ThinkingItem(event.text));
          }
        } else if (event is ChatToolCallEvent) {
          processItem.children.add(ToolCallItem(event.toolName, event.args));
        } else if (event is ChatToolResultEvent) {
          // Find matching tool in current process item
          for (int i = processItem.children.length - 1; i >= 0; i--) {
            final item = processItem.children[i];
            if (item is ToolCallItem &&
                item.toolName == event.toolName &&
                item.result == null) {
              item.result = event.result;
              item.isError = event.isError;
              break;
            }
          }
        }
        return; // Handled
      }

      // Handle Response (Finish Progress)
      if (event is ChatResponseChunkEvent) {
        if (_items.isNotEmpty && _items.last is ProcessItem) {
          final process = _items.last as ProcessItem;
          process.isFinished = true;
          process.isExpanded = false; // Collapse when answer starts
        }

        if (_items.isNotEmpty && _items.last is AIMessageItem) {
          final aiMsg = _items.last as AIMessageItem;
          aiMsg.text += event.text;
        } else {
          _items.add(AIMessageItem(event.text, isStreaming: !event.isDone));
        }
      } else if (event is ChatErrorEvent) {
        _items.add(ErrorItem(event.error));
      }
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // --- UI Building ---

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop
          FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),
          // Dialog
          SlideTransition(
            position: _slideAnimation,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height *
                    0.75, // Taller for better view
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 40,
                        offset: Offset(0, -10)),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        child: _isLoading
                            ? Center(child: AgentLogoLoading())
                            : _items.isEmpty
                                ? Center(
                                    child: Text(
                                      'Start a conversation with ${widget.title}',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.all(24),
                                    itemCount: _items.length +
                                        (_isLoadingAgent ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index == _items.length) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 24),
                                          child: Row(
                                            children: const [
                                              CircleAvatar(
                                                radius: 12,
                                                backgroundColor:
                                                    AppColors.iconBgLight,
                                                child: SizedBox(
                                                  width: 12,
                                                  height: 12,
                                                  child:
                                                      CircularProgressIndicator(
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
                                                    color:
                                                        AppColors.textTertiary),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      return _buildItem(_items[index]);
                                    },
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: const Border(bottom: BorderSide(color: Color(0xFFF7F8FA))),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            widget.title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          const SizedBox(width: 8),
          _buildModeChip(),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.history,
                size: 18, color: AppColors.textTertiary),
            onPressed: () {
              context.push(
                AppRoutes.chatHistory,
                extra: {
                  'agentName': widget.agentName,
                  'title': widget.title,
                },
              ).then((_) {
                if (mounted) {
                  setState(() {});
                  _loadSessionHistory();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.close,
                size: 20, color: AppColors.textTertiary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip() {
    final locked = !_isReadOnly && _hasSentInNormalMode;
    final canToggle = !locked && !_isStreaming;

    final label = _isReadOnly
        ? UserStorage.l10n.readOnlyMode
        : UserStorage.l10n.chatModeLabel;

    return GestureDetector(
      onTap: canToggle
          ? () {
              setState(() {
                _isReadOnly = !_isReadOnly;
              });
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _isReadOnly
              ? AppColors.primary.withValues(alpha: 0.08)
              : locked
                  ? const Color(0xFFF0F0F0)
                  : const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _isReadOnly
                    ? AppColors.primary
                    : locked
                        ? AppColors.textTertiary
                        : AppColors.textSecondary,
              ),
            ),
            if (canToggle) ...[
              const SizedBox(width: 2),
              Icon(
                Icons.unfold_more,
                size: 12,
                color:
                    _isReadOnly ? AppColors.primary : AppColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF7F8FA))),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                decoration: InputDecoration(
                  hintText: widget.inputHint,
                  hintStyle: const TextStyle(
                      color: AppColors.textTertiary, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (text) => _sendMessage(text),
              ),
            ),
            GestureDetector(
              onTap: () => _sendMessage(_messageController.text),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isStreaming ? Colors.grey : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isStreaming ? Icons.stop : Icons.arrow_upward,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
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
                  maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16)
                    .copyWith(bottomRight: const Radius.circular(4)),
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
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.link,
                                    size: 12, color: Colors.white70),
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
                  SelectableText(
                    item.text,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.white, height: 1.5),
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
            const CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.iconBgLight,
              child:
                  Icon(Icons.auto_awesome, size: 12, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16)
                    .copyWith(topLeft: const Radius.circular(4)),
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
                      left: BorderSide(color: AppColors.primary, width: 3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (item is ProcessItem) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            const SizedBox(width: 32), // Indent
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          item.isExpanded = !item.isExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                                item.isFinished
                                    ? Icons.check_circle_outline
                                    : Icons.sync,
                                size: 14,
                                color: AppColors.textTertiary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.isFinished
                                    ? 'Process Completed'
                                    : 'Processing...',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textTertiary,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            Icon(
                              item.isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 16,
                              color: AppColors.textTertiary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (item.isExpanded)
                      Column(
                        children: item.children.map((child) {
                          if (child is ThinkingItem) {
                            return _buildThinkingItem(child);
                          } else if (child is ToolCallItem) {
                            return _buildToolCallItem(child);
                          }
                          return const SizedBox.shrink();
                        }).toList(),
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
          child: Text(item.error,
              style: const TextStyle(color: Colors.red, fontSize: 12)),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTokenUsageDisplay() {
    if (_lastTokenUsage == null) return const SizedBox.shrink();
    final item = _lastTokenUsage!;

    String cacheRate = '0.0%';
    if (item.promptTokens > 0) {
      final rate = (item.cachedTokens / item.promptTokens) * 100;
      cacheRate = '${rate.toStringAsFixed(1)}%';
    }

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
            'Tokens: ${item.totalTokens} (P:${item.promptTokens} C:${item.completionTokens} Cache:$cacheRate) • Est: \$${item.estimatedCost.toStringAsFixed(5)}',
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

  Widget _buildThinkingItem(ThinkingItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.psychology, size: 12, color: Color(0xFFCBD5E1)),
              SizedBox(width: 6),
              Text('Thinking...',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500)),
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
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                item.isExpanded = !item.isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    item.isError
                        ? Icons.error_outline
                        : Icons.build_circle_outlined,
                    size: 14,
                    color: item.isError ? Colors.red : AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Used tool: ${item.toolName}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF334155)),
                    ),
                  ),
                  if (item.result == null)
                    const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 1.5))
                  else
                    Icon(
                      item.isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                ],
              ),
            ),
          ),
          if (item.isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF7F8FA))),
                color: Color(0xFFF7F8FA),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Arguments:',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(item.args,
                      style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  if (item.result != null) ...[
                    const Text('Result:',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(item.result!,
                        style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: Color(0xFF334155))),
                  ]
                ],
              ),
            ),
        ],
      ),
    );
  }
} // End of _AgentChatDialogState
