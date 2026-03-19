import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memex/ui/chat/view_models/chat_viewmodel.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';
import 'package:memex/ui/chat/widgets/agent_chat_dialog.dart';

/// Chat history list screen. Receives [viewModel] from parent (Compass-style).
class ChatHistoryScreen extends StatefulWidget {
  final ChatViewModel viewModel;
  final String? agentName;
  final String? title;

  const ChatHistoryScreen({
    super.key,
    required this.viewModel,
    this.agentName,
    this.title,
  });

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.viewModel.loadSessions().catchError((e) {
        if (mounted)
          ToastHelper.showError(
              context, UserStorage.l10n.loadSessionListFailed(e.toString()));
      });
    });
  }

  Future<void> _deleteSession(
      ChatViewModel vm, String sessionId, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(UserStorage.l10n.confirmDelete),
        content: Text(UserStorage.l10n.confirmDeleteSessionMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(UserStorage.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(UserStorage.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await vm.deleteSession(sessionId, index);
        if (mounted)
          ToastHelper.showSuccess(context, UserStorage.l10n.deleteSuccess);
      } catch (e) {
        if (mounted)
          ToastHelper.showError(
              context, UserStorage.l10n.deleteFailed(e.toString()));
      }
    }
  }

  void _openSession(ChatViewModel vm, String sessionId) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AgentChatDialog(
          agentName: widget.agentName,
          title: widget.title ?? UserStorage.l10n.aiAssistant,
          initialSessionId: sessionId,
          inputHint: UserStorage.l10n.continueChat,
        );
      },
    ).then((_) {
      if (mounted) vm.loadSessions();
    });
  }

  String _formatDateTime(String? isoString) {
    if (isoString == null) return '';
    try {
      final dateTime = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return DateFormat('HH:mm').format(dateTime);
      } else if (difference.inDays == 1) {
        return UserStorage.l10n
            .yesterdayAt(DateFormat('HH:mm').format(dateTime));
      } else if (difference.inDays < 7) {
        return UserStorage.l10n.daysAgo(difference.inDays);
      } else {
        return DateFormat('MM-dd HH:mm').format(dateTime);
      }
    } catch (e) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: Text(
              widget.title ?? UserStorage.l10n.chatHistory,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            backgroundColor: const Color(0xFFF8FAFC),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.of(context).pop(),
              color: const Color(0xFF64748B),
            ),
          ),
          body: vm.isLoading
              ? Center(child: AgentLogoLoading())
              : vm.sessions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_bubble_outline,
                              size: 48, color: Color(0xFFCBD5E1)),
                          const SizedBox(height: 16),
                          Text(
                            UserStorage.l10n.noConversations,
                            style: const TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => vm.loadSessions(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: vm.sessions.length,
                        itemBuilder: (context, index) {
                          final session = vm.sessions[index];
                          final sessionId =
                              session['session_id'] as String? ?? '';
                          final title = session['title'] as String? ??
                              UserStorage.l10n.newChat;
                          final lastMessagePreview =
                              session['last_message_preview'] as String? ?? '';
                          final updatedAt = session['updated_at'] as String?;
                          final messageCount =
                              session['message_count'] as int? ?? 0;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: const Color(0xFFF1F5F9)),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF64748B).withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _openSession(vm, sessionId),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF0F172A),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            if (lastMessagePreview.isNotEmpty)
                                              Text(
                                                lastMessagePreview,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      const Color(0xFF94A3B8),
                                                  height: 1.4,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Text(
                                                  _formatDateTime(updatedAt),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        const Color(0xFF94A3B8),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '•',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        const Color(0xFF94A3B8),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  UserStorage.l10n.messageCount(
                                                      messageCount),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        const Color(0xFF94A3B8),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: Colors.red[300],
                                        ),
                                        onPressed: () => _deleteSession(
                                            vm, sessionId, index),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showGeneralDialog(
                context: context,
                barrierDismissible: true,
                barrierLabel: '',
                barrierColor: Colors.transparent,
                transitionDuration: const Duration(milliseconds: 500),
                pageBuilder: (context, animation, secondaryAnimation) {
                  return AgentChatDialog(
                    agentName: widget.agentName,
                    title: widget.title ?? UserStorage.l10n.aiAssistant,
                    inputHint: UserStorage.l10n.askSomethingHint,
                  );
                },
              ).then((_) {
                if (mounted) widget.viewModel.loadSessions();
              });
            },
            backgroundColor: const Color(0xFF6366F1),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}
