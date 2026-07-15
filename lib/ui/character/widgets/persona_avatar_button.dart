import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/persona_chat_service.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/ui/character/view_models/persona_chat_viewmodel.dart';
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
  Timer? _retryTimer;
  int _unreadCount = 0;

  final Logger _logger = Logger('PersonaAvatarButton');

  @override
  void initState() {
    super.initState();
    EventBusService.instance.addHandler(
      EventBusMessageType.characterUpdated,
      _onCharacterUpdated,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final userId = await UserStorage.getUserId();
      _logger.info('PersonaAvatarButton _load: userId=$userId');
      if (userId == null) return;
      final router = MemexRouter();
      await router.ensureInitialized();
      if (!FileSystemService.isInitialized) {
        _scheduleRetry();
        return;
      }

      final primary = await CharacterService.instance.getPrimaryCompanion(
        userId,
      );
      _logger.info('PersonaAvatarButton _load: primary=${primary?.name}');
      if (!mounted || primary == null) return;

      setState(() => _character = primary);

      if (AppDatabase.isInitialized) {
        _unreadSub?.cancel();
        _unreadSub = PersonaChatService.instance.watchTotalUnreadCount().listen(
          (count) {
            if (mounted) setState(() => _unreadCount = count);
          },
        );
      }
    } catch (e, stack) {
      _logger.warning('PersonaAvatarButton _load failed: $e', e, stack);
    }
  }

  void _scheduleRetry() {
    if (_retryTimer?.isActive ?? false) return;
    _retryTimer = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        _load();
      }
    });
  }

  @override
  void dispose() {
    EventBusService.instance.removeHandler(
      EventBusMessageType.characterUpdated,
      _onCharacterUpdated,
    );
    _unreadSub?.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }

  void _onCharacterUpdated(EventBusMessage message) {
    if (mounted) {
      _load();
    }
  }

  void _openChat() {
    if (_character == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PersonaChatScreen(
          viewModel: PersonaChatViewModel(
            router: MemexRouter(),
            initialCharacterId: _character!.id,
          ),
        ),
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
          clipBehavior: Clip.none,
          children: [
            Center(
              child: _CompanionAvatarFrame(
                character: _character!,
              ),
            ),
            if (_unreadCount > 0) _UnreadBadge(count: _unreadCount),
          ],
        ),
      ),
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
