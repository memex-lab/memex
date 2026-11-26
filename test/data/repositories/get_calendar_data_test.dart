import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/get_calendar_data.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const userId = 'calendar-local-day-user';
  const utcPlus4 = Duration(hours: 4);

  late Directory tempDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.saveUser(userId);
    tempDir = await Directory.systemTemp.createTemp('memex_calendar_day_');
    await FileSystemService.init(tempDir.path);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('a card just after local midnight stays on that local day', () async {
    // 2026-10-01 02:00 at UTC+4 is 2026-09-30 22:00 UTC. Bucketing by the UTC
    // date files this card under 30 Sep, which the October grid never shows.
    final cardInstant = DateTime.utc(2026, 9, 30, 22);
    final timestamp = cardInstant.millisecondsSinceEpoch ~/ 1000;
    const factId = '2026/10/01.md#ts_1';
    final cardPath = FileSystemService.instance.getCardPath(userId, factId);
    await File(cardPath).create(recursive: true);
    await File(cardPath).writeAsString('''
timestamp: $timestamp
status: completed
title: Night note
tags: []
''');

    final from = DateTime.utc(2026, 9, 30, 20).millisecondsSinceEpoch ~/ 1000;
    final to =
        DateTime.utc(2026, 10, 31, 19, 59, 59).millisecondsSinceEpoch ~/ 1000;

    final days = await getCalendarData(from, to, utcOffset: utcPlus4);
    final occupied = days.where((day) => day.cards.isNotEmpty).toList();

    final expectedDay =
        DateTime.utc(2026, 10, 1).subtract(utcPlus4).millisecondsSinceEpoch ~/
            1000;

    expect(occupied, hasLength(1));
    expect(occupied.single.timestamp, expectedDay);
    expect(occupied.single.cards.single.title, 'Night note');
    expect(occupied.single.cards.single.id, factId);
  });

  test('a month that contains the DST fallback still returns each day',
      () async {
    final from = DateTime(2026, 10, 24).millisecondsSinceEpoch ~/ 1000;
    final to = DateTime(2026, 10, 26, 12).millisecondsSinceEpoch ~/ 1000;

    final days = await getCalendarData(from, to);

    expect(days, hasLength(3));
  });
  test('midnight partitions cards exactly once across leap day and new year',
      () async {
    for (final offset in [
      const Duration(hours: -8),
      const Duration(hours: 5, minutes: 45)
    ]) {
      for (final first in [
        DateTime.utc(2024, 2, 28),
        DateTime.utc(2026, 12, 31)
      ]) {
        final expected = <List<String>>[];
        for (var delta = -1; delta <= 2; delta++) {
          final date = first.add(Duration(days: delta));
          final day =
              date.toIso8601String().substring(0, 10).replaceAll('-', '/');
          final ids = <String>[];
          for (final second in [0, 86399]) {
            final id = '$day.md#ts_$second';
            final instant =
                date.subtract(offset).add(Duration(seconds: second));
            final file =
                File(FileSystemService.instance.getCardPath(userId, id));
            await file.create(recursive: true);
            await file.writeAsString(
                'timestamp: ${instant.millisecondsSinceEpoch ~/ 1000}\nstatus: completed\ntitle: Note\ntags: []\n');
            ids.add(id);
          }
          if (delta == 0 || delta == 1) expected.add(ids);
        }
        final from = first.subtract(offset).millisecondsSinceEpoch ~/ 1000;
        final days = await getCalendarData(from, from + 2 * 86400 - 1,
            utcOffset: offset);
        expect(days.map((d) => d.timestamp), [from, from + 86400]);
        expect(days.map((d) => d.cards.map((c) => c.id).toList()), expected);
      }
    }
  });
}
