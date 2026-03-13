import 'package:flutter/material.dart';
import 'package:memex/ui/chat/widgets/agent_chat_dialog.dart';
import 'package:memex/utils/user_storage.dart';

/// Chat input bar (fixed at bottom)
///
/// Shows a chat input at bottom; tap opens AgentChatDialog
class ChatInputBar extends StatefulWidget {
  /// Hint text (empty = use l10n default)
  final String? hintText;

  /// Agent name (optional)
  final String? agentName;

  /// Dialog title (empty = use l10n default)
  final String? dialogTitle;

  /// Callback when input is tapped (optional; default opens dialog)
  final VoidCallback? onTap;

  ChatInputBar({
    super.key,
    this.hintText,
    this.agentName,
    this.dialogTitle,
    this.onTap,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      // default: open AgentChatDialog
      _openChatDialog();
    }
  }

  void _openChatDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AgentChatDialog(
          agentName: widget.agentName,
          title: widget.dialogTitle ?? UserStorage.l10n.aiAssistant,
          inputHint: widget.hintText ?? UserStorage.l10n.askSomethingHint,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          border: Border.all(color: const Color(0xFFC7D2FE)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.15),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 16,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.hintText ?? UserStorage.l10n.askSomethingHint,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.arrow_upward,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

