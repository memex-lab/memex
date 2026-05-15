import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:memex/data/services/persona_chat_service.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/ui/character/widgets/persona_chat_screen.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/ui/core/widgets/character_avatar.dart';
import 'package:memex/utils/user_storage.dart';

/// Small avatar button in the timeline header.
/// Shows the user's primary companion character with an unread badge.
/// Tap to open chat.
class PersonaAvatarButton extends StatefulWidget {
  const PersonaAvatarButton({super.key});

  @override
  State<PersonaAvatarButton> createState() => _PersonaAvatarButtonState();
}

class _PersonaAvatarButtonState extends State<PersonaAvatarButton> {
  CharacterModel? _character;
  StreamSubscription? _unreadSub;
  int _unreadCount = 0;

  final Logger _logger = Logger('PersonaAvatarButton');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), _load);
    });
  }

  Future<void> _load() async {
    try {
      final userId = await UserStorage.getUserId();
      _logger.info('PersonaAvatarButton _load: userId=$userId');
      if (userId == null) return;

      final primary =
          await CharacterService.instance.getPrimaryCompanion(userId);
      _logger.info('PersonaAvatarButton _load: primary=${primary?.name}');
      if (!mounted || primary == null) return;

      setState(() => _character = primary);

      if (AppDatabase.isInitialized) {
        _unreadSub?.cancel();
        _unreadSub =
            PersonaChatService.instance.watchTotalUnreadCount().listen((count) {
          if (mounted) setState(() => _unreadCount = count);
        });
      }
    } catch (e, stack) {
      _logger.warning('PersonaAvatarButton _load failed: $e', e, stack);
    }
  }

  @override
  void dispose() {
    _unreadSub?.cancel();
    super.dispose();
  }

  void _openChat() {
    if (_character == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PersonaChatScreen(characterId: _character!.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_character == null) return const SizedBox(width: 36, height: 36);

    return GestureDetector(
      onTap: _openChat,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          children: [
            Center(
              child: CharacterAvatar(
                avatar: _character!.avatar,
                name: _character!.name,
                size: 30,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
            if (_unreadCount > 0)
              Positioned(
                top: 1,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _unreadCount > 99 ? '99+' : '$_unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
