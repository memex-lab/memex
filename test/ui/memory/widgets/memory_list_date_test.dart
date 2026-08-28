import 'package:test/test.dart';
import 'package:memex/ui/memory/widgets/memory_screen.dart';

void main() {
  test('formats UTC instants in local time', () {
    final formatted = formatMemoryListDate('2026-01-02T15:04:00.000Z');
    final local = DateTime.parse('2026-01-02T15:04:00.000Z').toLocal();
    expect(
      formatted,
      '${local.month}/${local.day} ${local.hour}:${local.minute.toString().padLeft(2, '0')}',
    );
  });

  test('returns empty for missing or invalid values', () {
    expect(formatMemoryListDate(null), '');
    expect(formatMemoryListDate('not-a-date'), '');
  });
}
