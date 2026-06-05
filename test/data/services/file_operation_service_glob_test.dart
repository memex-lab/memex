import 'dart:io';

import 'package:memex/data/services/file_operation_service.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('FileOperationService.globFiles', () {
    late Directory tempDir;
    late FileOperationService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('memex_glob_test_');
      service = FileOperationService.forTesting();

      final dailyReportDir = Directory(
        p.join(
          tempDir.path,
          '_UserSettings',
          'DynamicSurfaceData',
          'daily_report',
        ),
      );
      await dailyReportDir.create(recursive: true);
      await File(
        p.join(dailyReportDir.path, '2026-06-03.md'),
      ).writeAsString('# 2026-06-03 日报\n');
      await File(
        p.join(dailyReportDir.path, '2026-06-04.md'),
      ).writeAsString('# 2026-06-04 日报\n');
      await File(
        p.join(dailyReportDir.path, '2026-06-10.md'),
      ).writeAsString('# 2026-06-10 日报\n');

      final notesDir = Directory(p.join(tempDir.path, 'Notes'));
      await notesDir.create(recursive: true);
      await File(p.join(notesDir.path, 'a.md')).writeAsString('# A\n');
      await File(p.join(notesDir.path, 'b.txt')).writeAsString('B\n');
      await File(p.join(notesDir.path, 'launch-plan.md'))
          .writeAsString('# Launch plan\n');
      await File(p.join(notesDir.path, 'website-brief.txt'))
          .writeAsString('Website brief\n');
      await File(p.join(notesDir.path, '项目记录.md')).writeAsString('# 项目\n');
      await File(p.join(notesDir.path, '2026-06-03.md'))
          .writeAsString('# Note report\n');

      final nestedDir = Directory(p.join(notesDir.path, 'Nested'));
      await nestedDir.create(recursive: true);
      await File(p.join(nestedDir.path, 'deep.md')).writeAsString('# Deep\n');
      await File(p.join(nestedDir.path, 'deeper.txt')).writeAsString('Deep\n');
      await File(p.join(nestedDir.path, 'project-roadmap.md'))
          .writeAsString('# Project roadmap\n');

      final hiddenDir = Directory(p.join(notesDir.path, '.hidden_dir'));
      await hiddenDir.create(recursive: true);
      await File(p.join(hiddenDir.path, 'secret.md')).writeAsString('secret\n');
      await File(p.join(notesDir.path, '.hidden.md')).writeAsString('hidden\n');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('returns physical paths when no working directory root is mapped',
        () async {
      final result = await service.globFiles(
        pattern: '*.md',
        searchPath: p.join(tempDir.path, 'Notes'),
      );

      expect(_lines(result), contains(p.join(tempDir.path, 'Notes', 'a.md')));
      expect(
        _lines(result),
        contains(p.join(tempDir.path, 'Notes', '2026-06-03.md')),
      );
      expect(_lines(result), isNot(contains('/Notes/a.md')));
    });

    test('matches a physical absolute glob when no root is mapped', () async {
      final result = await service.globFiles(
        pattern: p.join(tempDir.path, 'Notes', '*.md'),
        searchPath: tempDir.path,
      );

      expect(_lines(result), contains(p.join(tempDir.path, 'Notes', 'a.md')));
      expect(
        _lines(result),
        contains(p.join(tempDir.path, 'Notes', '2026-06-03.md')),
      );
      expect(
        _lines(result),
        isNot(contains(p.join(tempDir.path, 'Notes', 'Nested', 'deep.md'))),
      );
    });

    test('matches a relative directory glob when no root is mapped', () async {
      final result = await service.globFiles(
        pattern: 'Notes/*.md',
        searchPath: tempDir.path,
      );

      expect(_lines(result), contains(p.join(tempDir.path, 'Notes', 'a.md')));
      expect(
        _lines(result),
        contains(p.join(tempDir.path, 'Notes', '2026-06-03.md')),
      );
      expect(
        _lines(result),
        isNot(contains(p.join(tempDir.path, 'Notes', 'Nested', 'deep.md'))),
      );
    });

    test('returns virtual paths when a working directory root is mapped',
        () async {
      final result = await service.globFiles(
        pattern: '*.md',
        searchPath: '/Notes',
        workingDirectory: tempDir.path,
      );

      expect(_lines(result), contains('/Notes/a.md'));
      expect(_lines(result), contains('/Notes/2026-06-03.md'));
      expect(
        _lines(result),
        isNot(contains(p.join(tempDir.path, 'Notes', 'a.md'))),
      );
    });

    test('matches a relative directory glob from mapped workspace root',
        () async {
      final result = await service.globFiles(
        pattern: 'Notes/*.md',
        workingDirectory: tempDir.path,
      );

      expect(_lines(result), contains('/Notes/a.md'));
      expect(_lines(result), contains('/Notes/2026-06-03.md'));
      expect(_lines(result), isNot(contains('/Notes/Nested/deep.md')));
    });

    test('matches a virtual absolute exact file pattern', () async {
      final result = await service.globFiles(
        pattern: '/_UserSettings/DynamicSurfaceData/daily_report/2026-06-03.md',
        workingDirectory: tempDir.path,
      );

      expect(
        result,
        '/_UserSettings/DynamicSurfaceData/daily_report/2026-06-03.md',
      );
    });

    test('matches a virtual absolute glob pattern from workspace root',
        () async {
      final result = await service.globFiles(
        pattern: '/_UserSettings/DynamicSurfaceData/daily_report/*.md',
        workingDirectory: tempDir.path,
      );

      expect(
        _lines(result),
        containsAll([
          '/_UserSettings/DynamicSurfaceData/daily_report/2026-06-03.md',
          '/_UserSettings/DynamicSurfaceData/daily_report/2026-06-04.md',
          '/_UserSettings/DynamicSurfaceData/daily_report/2026-06-10.md',
        ]),
      );
    });

    test('matches a virtual absolute pattern under an explicit search path',
        () async {
      final result = await service.globFiles(
        pattern: '/_UserSettings/DynamicSurfaceData/daily_report/2026-06-03.md',
        searchPath: '/_UserSettings/DynamicSurfaceData/daily_report',
        workingDirectory: tempDir.path,
      );

      expect(
        result,
        '/_UserSettings/DynamicSurfaceData/daily_report/2026-06-03.md',
      );
    });

    test('single star does not cross directory boundaries', () async {
      final result = await service.globFiles(
        pattern: '*.md',
        searchPath: '/Notes',
        workingDirectory: tempDir.path,
      );

      expect(_lines(result), contains('/Notes/a.md'));
      expect(_lines(result), contains('/Notes/2026-06-03.md'));
      expect(_lines(result), isNot(contains('/Notes/Nested/deep.md')));
    });

    test('double star crosses directories and includes current directory files',
        () async {
      final result = await service.globFiles(
        pattern: '**/*.md',
        searchPath: '/Notes',
        workingDirectory: tempDir.path,
      );

      expect(_lines(result), contains('/Notes/a.md'));
      expect(_lines(result), contains('/Notes/2026-06-03.md'));
      expect(_lines(result), contains('/Notes/Nested/deep.md'));
    });

    test('question mark matches exactly one non-slash character', () async {
      final result = await service.globFiles(
        pattern: '2026-06-0?.md',
        searchPath: '/_UserSettings/DynamicSurfaceData/daily_report',
        workingDirectory: tempDir.path,
      );

      expect(
        _lines(result),
        containsAll([
          '/_UserSettings/DynamicSurfaceData/daily_report/2026-06-03.md',
          '/_UserSettings/DynamicSurfaceData/daily_report/2026-06-04.md',
        ]),
      );
      expect(
        _lines(result),
        isNot(
          contains(
            '/_UserSettings/DynamicSurfaceData/daily_report/2026-06-10.md',
          ),
        ),
      );
    });

    test(
        'brace alternatives match common extension groups without root mapping',
        () async {
      final result = await service.globFiles(
        pattern: '*.{md,txt}',
        searchPath: p.join(tempDir.path, 'Notes'),
      );

      expect(_lines(result), contains(p.join(tempDir.path, 'Notes', 'a.md')));
      expect(_lines(result), contains(p.join(tempDir.path, 'Notes', 'b.txt')));
      expect(
        _lines(result),
        contains(p.join(tempDir.path, 'Notes', 'launch-plan.md')),
      );
      expect(
        _lines(result),
        contains(p.join(tempDir.path, 'Notes', 'website-brief.txt')),
      );
      expect(
        _lines(result),
        isNot(contains(p.join(tempDir.path, 'Notes', 'Nested', 'deep.md'))),
      );
    });

    test('brace alternatives work with recursive mapped workspace globs',
        () async {
      final result = await service.globFiles(
        pattern: '**/*{launch,website,project,项目}*',
        searchPath: '/Notes',
        workingDirectory: tempDir.path,
      );

      expect(
        _lines(result),
        containsAll([
          '/Notes/launch-plan.md',
          '/Notes/website-brief.txt',
          '/Notes/项目记录.md',
          '/Notes/Nested/project-roadmap.md',
        ]),
      );
      expect(_lines(result), isNot(contains('/Notes/a.md')));
      expect(_lines(result), isNot(contains('/Notes/Nested/deep.md')));
    });

    test('hidden files and hidden directories are skipped', () async {
      final result = await service.globFiles(
        pattern: '**/*.md',
        searchPath: '/Notes',
        workingDirectory: tempDir.path,
      );

      expect(_lines(result), isNot(contains('/Notes/.hidden.md')));
      expect(_lines(result), isNot(contains('/Notes/.hidden_dir/secret.md')));
    });

    test('returns No files found when no pattern matches', () async {
      final result = await service.globFiles(
        pattern: '*.pdf',
        searchPath: '/Notes',
        workingDirectory: tempDir.path,
      );

      expect(result, 'No files found');
    });
  });
}

List<String> _lines(String result) => result.split('\n');
