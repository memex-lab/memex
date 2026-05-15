import 'package:intl/intl.dart';
import 'package:memex/utils/time_context.dart';

/// Replaces SillyTavern-style macros in character card text fields.
///
/// Supported macros (case-insensitive):
/// - `{{user}}` → the current user's name
/// - `{{char}}` → the character's name
/// - `{{time}}` → current local time (HH:mm with timezone)
/// - `{{date}}` → current local date (yyyy-MM-dd)
///
/// Unknown macros are left as-is.
class TavernMacro {
  TavernMacro._();

  static final _macroPattern = RegExp(r'\{\{(\w+)\}\}', caseSensitive: false);

  /// Replace all supported macros in [text].
  ///
  /// [userName] — the user's display name (from UserStorage.getUserId).
  /// [charName] — the character's name.
  static String resolve(
    String text, {
    required String userName,
    required String charName,
  }) {
    if (!text.contains('{{')) return text;

    final now = DateTime.now().toLocal();
    return text.replaceAllMapped(_macroPattern, (match) {
      final macro = match.group(1)!.toLowerCase();
      switch (macro) {
        case 'user':
          return userName;
        case 'char':
          return charName;
        case 'time':
          // HH:mm with timezone offset, e.g. "14:30 +08:00 (CST)"
          final time = DateFormat('HH:mm').format(now);
          return '$time ${formatTimeZoneOffset(now.timeZoneOffset)}';
        case 'date':
          return DateFormat('yyyy-MM-dd').format(now);
        default:
          return match.group(0)!; // leave unknown macros untouched
      }
    });
  }
}
