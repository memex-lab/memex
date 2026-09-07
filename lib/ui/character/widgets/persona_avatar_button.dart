import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/ui/character/view_models/persona_avatar_viewmodel.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/ui/core/widgets/character_avatar.dart';

/// Small avatar button in the timeline header.
/// Shows the user's primary companion character with an unread badge.
/// Tap to open chat.
class PersonaAvatarButton extends StatefulWidget {
  const PersonaAvatarButton({
    super.key,
    required this.viewModel,
    required this.onTap,
  });

  final PersonaAvatarViewModel viewModel;
  final ValueChanged<CharacterModel> onTap;

  @override
  State<PersonaAvatarButton> createState() => _PersonaAvatarButtonState();
}

class _PersonaAvatarButtonState extends State<PersonaAvatarButton> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(widget.viewModel.ensureLoaded());
    });
  }

  @override
  void didUpdateWidget(PersonaAvatarButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel != widget.viewModel) {
      unawaited(widget.viewModel.ensureLoaded());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final character = widget.viewModel.character;
        if (character == null) {
          return const SizedBox(width: 36, height: 36);
        }

        return GestureDetector(
          onTap: () => widget.onTap(character),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: _CompanionAvatarFrame(character: character),
                ),
                if (widget.viewModel.unreadCount > 0)
                  _UnreadBadge(count: widget.viewModel.unreadCount),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CompanionAvatarFrame extends StatelessWidget {
  const _CompanionAvatarFrame({required this.character});

  final CharacterModel character;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Center(
            child: Icon(
              Icons.forum_rounded,
              size: 19,
              color: Colors.white,
            ),
          ),
          Positioned(
            left: -3,
            bottom: -3,
            child: Container(
              width: 18,
              height: 18,
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.18),
                ),
              ),
              child: CharacterAvatar(
                avatar: character.avatar,
                name: character.name,
                size: 15,
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.82),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -2,
      right: -3,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Center(
          child: Text(
            count > 99 ? '99+' : '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
