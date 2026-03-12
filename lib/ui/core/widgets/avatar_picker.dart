import 'package:flutter/material.dart';
import 'package:memex/utils/user_storage.dart';

/// Shows a bottom sheet grid of avatar emoji options.
/// Returns the selected emoji, or null if dismissed.
Future<String?> showAvatarPicker(BuildContext context, String currentAvatar) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              UserStorage.l10n.chooseAvatar,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: UserStorage.avatarOptions.length,
              itemBuilder: (context, index) {
                final emoji = UserStorage.avatarOptions[index];
                final isSelected = emoji == currentAvatar;
                return GestureDetector(
                  onTap: () => Navigator.pop(context, emoji),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFEEF2FF)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected
                          ? Border.all(color: const Color(0xFF6366F1), width: 2)
                          : Border.all(color: Colors.grey[200]!),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
