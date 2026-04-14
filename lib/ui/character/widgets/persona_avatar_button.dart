import 'dart:async';
import 'package:flutter/material.dart';
import 'package:memex/data/services/persona_chat_service.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/ui/character/widgets/persona_chat_screen.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/utils/user_storage.dart';

/// Small avatar button in the timeline header.
/// Shows the user's primary companion character with an unread badge.
class PersonaAvatarButton extends StatefulWidget {
  const PersonaAvatarButton({super.key});

  @override
  State<PersonaAvatarButton> createState() => _PersonaAvatarButtonState();
}

class _PersonaAvatarButtonState extends State<PersonaAvatarButton> {
  CharacterModel? _character;
  StreamSubscription? _unreadSub;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = UserStorage.userId;
    if (userId == null) return;

    final primary =
        await CharacterService.instance.getPrimaryCompanion(userId);
    if (!mounted || primary == null) return;

    setState(() => _character = primary);

    if (AppDatabase.isInitialized) {
      _unreadSub = PersonaChatService.instance
          .watchTotalUnreadCount()
          .listen((count) {
        if (mounted) setState(() => _unreadCount = count);
      });
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
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.primary.withValues(alpha: 0.25),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    _character!.name.characters.first,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
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
