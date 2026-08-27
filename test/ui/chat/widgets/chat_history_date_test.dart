import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:memex/ui/chat/widgets/chat_history_screen.dart';

void main() {
  test('formats UTC session times in local hours', () {
    final utc = DateTime.utc(2026, 8, 27, 15, 30);
    final iso = utc.toIso8601String();
    final local = utc.toLocal();
    final formatted = formatChatHistoryDateTime(iso, now: local);
    expect(formatted, DateFormat('HH:mm').format(local));
  });

  test('returns empty for null and original for invalid values', () {
    expect(formatChatHistoryDateTime(null), '');
    expect(formatChatHistoryDateTime('not-a-date'), 'not-a-date');
  });
}
