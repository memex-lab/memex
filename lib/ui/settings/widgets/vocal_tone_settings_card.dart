import 'package:flutter/material.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/utils/user_storage.dart';

class VocalToneSettingsCard extends StatelessWidget {
  const VocalToneSettingsCard({
    super.key,
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = UserStorage.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Material(
        color: Colors.white,
        elevation: 1,
        shadowColor: AppColors.textSecondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(
              Icons.graphic_eq,
              color: AppColors.primary,
              size: 22,
            ),
            title: Text(
              l10n.analyzeVocalToneTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                l10n.analyzeVocalToneDesc,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ),
            value: enabled,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
