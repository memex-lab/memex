import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:memex/ui/core/cards/style/timeline_theme.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/utils/user_storage.dart';

class SharePreviewDialog extends StatelessWidget {
  final Uint8List imageBytes;
  final VoidCallback onShare;
  final VoidCallback onCancel;

  /// Callback to toggle between card style and detail style.
  /// If null, the toggle button is hidden.
  final VoidCallback? onToggleStyle;

  /// Whether the current preview is in detail (long image) style.
  final bool isDetailStyle;

  const SharePreviewDialog({
    super.key,
    required this.imageBytes,
    required this.onShare,
    required this.onCancel,
    this.onToggleStyle,
    this.isDetailStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = UserStorage.l10n;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Preview Title
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  l10n.sharePreviewTitle,
                  style: TimelineTheme.typography.title.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                    shadows: [
                      const Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),

              // Image Preview
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.memory(
                      imageBytes,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildButton(
                    onTap: onCancel,
                    icon: Icons.close_rounded,
                    label: l10n.cancel,
                    isPrimary: false,
                  ),
                  if (onToggleStyle != null) ...[
                    const SizedBox(width: 24),
                    _buildButton(
                      onTap: onToggleStyle!,
                      icon: isDetailStyle
                          ? Icons.crop_square_rounded
                          : Icons.article_outlined,
                      label: isDetailStyle
                          ? l10n.shareCardStyle
                          : l10n.shareDetailStyle,
                      isPrimary: false,
                      isAccent: true,
                    ),
                  ],
                  const SizedBox(width: 24),
                  _buildButton(
                    onTap: onShare,
                    icon: Icons.share_rounded,
                    label: l10n.shareNow,
                    isPrimary: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required bool isPrimary,
    bool isAccent = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPrimary
                  ? Colors.white
                  : isAccent
                      ? AppColors.primary.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.15),
              border: isPrimary || isAccent
                  ? null
                  : Border.all(
                      color: Colors.white.withValues(alpha: 0.3), width: 1.5),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: isPrimary
                  ? AppColors.primary
                  : isAccent
                      ? Colors.white
                      : Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
