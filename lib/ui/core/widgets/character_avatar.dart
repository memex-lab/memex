import 'package:flutter/material.dart';
import 'package:memex/ui/core/widgets/dicebear_avatar.dart';
import 'package:memex/ui/core/widgets/local_image.dart';

/// Returns true if the avatar string represents a local image file path
/// (as opposed to a DiceBear seed string).
bool isImageAvatar(String? avatar) {
  if (avatar == null || avatar.isEmpty) return false;
  final lower = avatar.toLowerCase();
  return lower.endsWith('.png') ||
      lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.webp') ||
      lower.contains('/');
}

/// A unified character avatar widget that handles both DiceBear seed avatars
/// and custom image file avatars.
///
/// If [avatar] looks like a file path (contains '/' or ends with image extension),
/// it renders using [LocalImage] in a circle. Otherwise it uses [DiceBearAvatar].
class CharacterAvatar extends StatelessWidget {
  const CharacterAvatar({
    super.key,
    required this.avatar,
    required this.name,
    this.size = 48,
    this.backgroundColor,
  });

  /// The avatar value from CharacterModel. Can be a DiceBear seed or a file path.
  final String? avatar;

  /// Character name, used as fallback seed for DiceBear.
  final String name;

  /// Avatar diameter.
  final double size;

  /// Background color for DiceBear avatars.
  final Color? backgroundColor;

  String get _dicebearSeed {
    if (avatar != null && avatar!.isNotEmpty && !isImageAvatar(avatar)) {
      return avatar!;
    }
    return 'companion_$name';
  }

  @override
  Widget build(BuildContext context) {
    if (isImageAvatar(avatar)) {
      return ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: LocalImage(
            url: avatar!,
            fit: BoxFit.cover,
            width: size,
            height: size,
            errorBuilder: (_, __, ___) => _fallbackDiceBear(),
          ),
        ),
      );
    }

    return DiceBearAvatar(
      seed: _dicebearSeed,
      size: size,
      backgroundColor: backgroundColor,
    );
  }

  Widget _fallbackDiceBear() {
    return DiceBearAvatar(
      seed: _dicebearSeed,
      size: size,
      backgroundColor: backgroundColor,
    );
  }
}
