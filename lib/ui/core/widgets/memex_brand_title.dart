import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memex/config/app_flavor.dart';
import 'package:memex/ui/core/themes/app_colors.dart';

class MemexBrandTitle extends StatelessWidget {
  const MemexBrandTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final badgeLabel = AppFlavor.homeBadgeLabel;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Meme',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                  height: 1,
                  color: AppColors.textPrimary,
                ),
              ),
              TextSpan(
                text: 'x',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                  height: 1,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        if (badgeLabel != null) ...[
          const SizedBox(width: 7),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: _ChannelBadge(label: badgeLabel),
          ),
        ],
      ],
    );
  }
}

class _ChannelBadge extends StatelessWidget {
  const _ChannelBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.1,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
