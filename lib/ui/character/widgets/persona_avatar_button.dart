import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:memex/data/services/persona_chat_service.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/ui/character/widgets/persona_chat_screen.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/ui/core/widgets/dicebear_avatar.dart';
import 'package:memex/utils/user_storage.dart';

/// Small avatar button in the timeline header.
/// Shows the user's primary companion character with an unread badge.
/// Tap to open chat, long-press to switch characters.
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

  Future<void> _showCharacterSwitcher() async {
    final userId = await UserStorage.getUserId();
    if (userId == null) return;

    final characters = await CharacterService.instance.getAllCharacters(userId);
    final enabled = characters.where((c) => c.enabled).toList();
    if (enabled.isEmpty || !mounted) return;

    final selected = await showModalBottomSheet<CharacterModel>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CharacterSwitcherSheet(
        characters: enabled,
        currentId: _character?.id,
      ),
    );

    if (selected != null && mounted) {
      // Set as primary and reload
      await CharacterService.instance.setPrimaryCompanion(userId, selected.id);
      setState(() => _character = selected.copyWith(isPrimaryCompanion: true));
      // Open chat with the newly selected character
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PersonaChatScreen(characterId: selected.id),
          ),
        );
      }
    }
  }

  String _avatarSeed(CharacterModel char) {
    if (char.avatar != null && char.avatar!.isNotEmpty) return char.avatar!;
    return 'companion_${char.name}';
  }

  @override
  Widget build(BuildContext context) {
    if (_character == null) return const SizedBox(width: 36, height: 36);

    return GestureDetector(
      onTap: _openChat,
      onLongPress: _showCharacterSwitcher,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          children: [
            Center(
              child: DiceBearAvatar(
                seed: _avatarSeed(_character!),
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

/// Bottom sheet for switching companion characters.
class _CharacterSwitcherSheet extends StatelessWidget {
  final List<CharacterModel> characters;
  final String? currentId;

  const _CharacterSwitcherSheet({
    required this.characters,
    this.currentId,
  });

  String _avatarSeed(CharacterModel char) {
    if (char.avatar != null && char.avatar!.isNotEmpty) return char.avatar!;
    return 'companion_${char.name}';
  }

  @override
  Widget build(BuildContext context) {
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
            const Text(
              'Switch companion',
              style: TextStyle(
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
