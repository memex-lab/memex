import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const userId = 'card-range-user';
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('memex_card_range_');
    await FileSystemService.init(tempDir.path);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('returns yaml cards for the requested days from one month folder',
      () async {
    final month = Directory(
      p.join(
        FileSystemService.instance.getCardsPath(userId),
        '2026',
        '10',
      ),
    );
    await month.create(recursive: true);
    await File(p.join(month.path, '01_ts_1.yaml')).writeAsString('title: one');
    await File(p.join(month.path, '15_ts_2.yaml')).writeAsString('title: mid');
    await File(p.join(month.path, '31_ts_3.yaml')).writeAsString('title: late');
    await File(p.join(month.path, 'notes.txt')).writeAsString('skip');
    await Directory(p.join(month.path, '02_ts_9.yaml')).create();

    final files = await FileSystemService.instance.getCardFilesInDateRange(
      userId,
      DateTime(2026, 10, 1),
      DateTime(2026, 10, 15),
    );

    expect(
      files.map(p.basename).toList(),
      ['01_ts_1.yaml', '15_ts_2.yaml'],
    );
  });

  test('includes the civil day after a daylight-saving fallback', () async {
    // 2026-10-25 is the EU fallback. In Europe/Helsinki, midnight plus 24
    // hours is still 25 Oct, so a Duration stepper never reaches the 26th.
    final month = Directory(
      p.join(
        FileSystemService.instance.getCardsPath(userId),
        '2026',
        '10',
      ),
    );
    await month.create(recursive: true);
    await File(p.join(month.path, '25_ts_1.yaml')).writeAsString('title: fall');
    await File(p.join(month.path, '26_ts_1.yaml')).writeAsString('title: next');

    final files = await FileSystemService.instance.getCardFilesInDateRange(
      userId,
      DateTime(2026, 10, 24),
      DateTime(2026, 10, 26),
    );

    expect(
      files.map(p.basename).toList(),
      ['25_ts_1.yaml', '26_ts_1.yaml'],
    );
  });
}
