import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:memex/ui/chat/widgets/chat_history_screen.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
  });

  test('formats UTC session times in local hours', () {
    final utc = DateTime.utc(2026, 8, 27, 15, 30);
    final iso = utc.toIso8601String();
    final local = utc.toLocal();
    final formatted = formatChatHistoryDateTime(iso, now: local);
    expect(formatted, DateFormat('HH:mm').format(local));
  });

  test('uses calendar days not 24-hour buckets', () {
    final yesterdayEvening = DateTime(2026, 8, 27, 23, 0);
    final todayMorning = DateTime(2026, 8, 28, 1, 0);
    final formatted = formatChatHistoryDateTime(
      yesterdayEvening.toIso8601String(),
      now: todayMorning,
    );
    expect(
      formatted,
      UserStorage.l10n
          .yesterdayAt(DateFormat('HH:mm').format(yesterdayEvening)),
    );
  });

  test('returns empty for null and original for invalid values', () {
    expect(formatChatHistoryDateTime(null), '');
    expect(formatChatHistoryDateTime('not-a-date'), 'not-a-date');
  });
}
