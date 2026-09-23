import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memex/utils/user_storage.dart';

class AICoreButton extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Function(LongPressMoveUpdateDetails)? onLongPressMoveUpdate;
  final Function(LongPressEndDetails)? onLongPressEnd;

  const AICoreButton({
    super.key,
    required this.onTap,
    required this.onLongPress,
    this.onLongPressMoveUpdate,
    this.onLongPressEnd,
  });

  @override
  State<AICoreButton> createState() => _AICoreButtonState();
}

class _AICoreButtonState extends State<AICoreButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _scaleController.animateTo(0.9).then((_) {
      if (mounted) {
        _scaleController.animateTo(1.0);
        widget.onTap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: UserStorage.l10n.addTooltip,
      onLongPressHint: UserStorage.l10n.speechProviderSettings,
      onTap: _handleTap,
      onLongPress: widget.onLongPress,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: _handleTap,
          onLongPressStart: (details) => widget.onLongPress(),
          onLongPressMoveUpdate: widget.onLongPressMoveUpdate,
          onLongPressEnd: widget.onLongPressEnd,
          behavior: HitTestBehavior.opaque,
          child: ScaleTransition(
            scale: _scaleController,
            child: Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x265B6CFF),
                    blurRadius: 6,
                    spreadRadius: -2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              // SVG is 88×88 (68px circle + 10px shadow padding each side)
              child: SvgPicture.asset(
                'assets/icons/nav_add_button.svg',
                width: 88,
                height: 88,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
