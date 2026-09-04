import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memex/ui/main_screen/widgets/ai_core_button.dart';
import 'package:memex/utils/user_storage.dart';

/// Home bottom bar: Timeline / capture / Library, scaled from the 393-wide
/// Figma canvas. Tab hit targets are enlarged and lifted above the system
/// gesture inset so taps still switch pages on phones with a home indicator.
class MainBottomBar extends StatelessWidget {
  const MainBottomBar({
    super.key,
    required this.currentTab,
    required this.onTimelineTap,
    required this.onLibraryTap,
    required this.onCenterTap,
    required this.onCenterLongPress,
    this.onCenterLongPressMoveUpdate,
    this.onCenterLongPressEnd,
    this.centerButtonKey,
    this.timelineTabKey,
    this.libraryTabKey,
  });

  final int currentTab;
  final VoidCallback onTimelineTap;
  final VoidCallback onLibraryTap;
  final VoidCallback onCenterTap;
  final VoidCallback onCenterLongPress;
  final GestureLongPressMoveUpdateCallback? onCenterLongPressMoveUpdate;
  final GestureLongPressEndCallback? onCenterLongPressEnd;
  final Key? centerButtonKey;
  final Key? timelineTabKey;
  final Key? libraryTabKey;

  static const double designWidth = 393;
  static const double designHeight = 120.5;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    const selectedColor = Color(0xFF1F1F1F);
    const idleColor = Color(0xFF99A1AF);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FittedBox(
          fit: BoxFit.fitWidth,
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: designWidth,
            height: designHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: _NavBarPainter()),
                ),
                const Positioned(
                  top: 100.0,
                  bottom: -100.0,
                  left: 0,
                  right: 0,
                  child: ColoredBox(color: Colors.white),
                ),
                PositionedDirectional(
                  top: -16.0,
                  start: 0,
                  end: 0,
                  child: Center(
                    child: AICoreButton(
                      key: centerButtonKey,
                      onTap: onCenterTap,
                      onLongPress: onCenterLongPress,
                      onLongPressMoveUpdate: onCenterLongPressMoveUpdate,
                      onLongPressEnd: onCenterLongPressEnd,
                    ),
                  ),
                ),
                _NavTab(
                  key: timelineTabKey,
                  top: 40,
                  start: 16,
                  width: 118,
                  height: 56,
                  selected: currentTab == 0,
                  label: UserStorage.l10n.bottomNavTimeline,
                  onTap: onTimelineTap,
                  icon: SvgPicture.asset(
                    'assets/icons/tab_timeline_active.svg',
                    width: 22,
                    height: 23,
                    colorFilter: ColorFilter.mode(
                      currentTab == 0 ? selectedColor : idleColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                _NavTab(
                  key: libraryTabKey,
                  top: 40,
                  end: 16,
                  width: 118,
                  height: 56,
                  selected: currentTab == 1,
                  label: UserStorage.l10n.bottomNavLibrary,
                  onTap: onLibraryTap,
                  icon: SvgPicture.asset(
                    'assets/icons/tab_library_inactive.svg',
                    width: 25.06,
                    height: 21.15,
                    colorFilter: ColorFilter.mode(
                      currentTab == 1 ? selectedColor : idleColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (bottomInset > 0)
          ColoredBox(
            color: Colors.white,
            child: SizedBox(height: bottomInset),
          ),
      ],
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    super.key,
    required this.top,
    this.start,
    this.end,
    required this.width,
    required this.height,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  }) : assert(start != null || end != null);

  final double top;
  final double? start;
  final double? end;
  final double width;
  final double height;
  final Widget icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: top,
      start: start,
      end: end,
      width: width,
      height: height,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              icon,
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: selected
                      ? const Color(0xFF1F1F1F)
                      : const Color(0xFF99A1AF),
                  letterSpacing: 0.14,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarPainter extends CustomPainter {
  const _NavBarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, 20);
    path.lineTo(142.528, 20);
    path.cubicTo(148.501, 20, 153.977, 23.3275, 156.729, 28.6293);
    path.lineTo(164.497, 43.5965);
    path.cubicTo(179.426, 72.3609, 220.574, 72.3609, 235.503, 43.5966);
    path.lineTo(243.271, 28.6293);
    path.cubicTo(246.023, 23.3275, 251.499, 20, 257.472, 20);
    path.lineTo(size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 20);
    path.close();

    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(-50, -50, size.width + 100, size.height + 50),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0),
    );
    canvas.restore();

    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
