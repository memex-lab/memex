import 'dart:io';

import 'package:memex/data/services/file_search_access_scope.dart';
import 'package:memex/data/services/file_operation_service.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final ripgrepExecutable = _findRipgrepExecutable();

  group('FileOperationService.grepFiles inline regex flags', () {
    late Directory tempDir;
    late Directory factsDir;
    late FileOperationService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('memex_grep_test_');
      factsDir = Directory(p.join(tempDir.path, 'Facts'));
      await factsDir.create(recursive: true);
      service = FileOperationService.forTesting(
        ripgrepExecutable: '__memex_missing_rg_for_fallback_test__',
      );

      await File(p.join(factsDir.path, 'note.md')).writeAsString('''
Before
Memex is local-first
After
lower memex mention
MemeX stylized
''');
      await File(
        p.join(factsDir.path, 'case.md'),
      ).writeAsString('Memex only mixed case\n');
      await File(
        p.join(factsDir.path, 'other.md'),
      ).writeAsString('No product keyword here\n');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('files_with_matches accepts leading (?i)', () async {
      final result = await service.grepFiles(
        pattern: r'(?i)memex',
        searchPath: '/Facts/case.md',
        workingDirectory: tempDir.path,
      );

      expect(result, contains('Found 1 file'));
      expect(result, contains('/Facts/case.md'));
    });

    test(
      'content mode accepts leading (?i) with context and line numbers',
      () async {
        final result = await service.grepFiles(
          pattern: r'(?i)meme[xX]|MemeX',
          searchPath: '/Facts/note.md',
          workingDirectory: tempDir.path,
          outputMode: 'content',
          C: 1,
          n: true,
          headLimit: 50,
        );

        expect(result, contains('/Facts/note.md:2:Memex is local-first'));
        expect(result, contains('/Facts/note.md:4:lower memex mention'));
        expect(result, contains('/Facts/note.md:5:MemeX stylized'));
      },
    );

    test(
      'count mode accepts combined leading flags and large head_limit',
      () async {
        final result = await service.grepFiles(
          pattern: r'(?is)meme[xX]',
          searchPath: '/Facts/note.md',
          workingDirectory: tempDir.path,
          outputMode: 'count',
          headLimit: 50,
        );

        expect(result, '/Facts/note.md:3');
      },
    );

    test(
      'leading (?-i) overrides the default case-insensitive search',
      () async {
        final defaultResult = await service.grepFiles(
          pattern: r'memex',
          searchPath: '/Facts/case.md',
          workingDirectory: tempDir.path,
        );
        final strictResult = await service.grepFiles(
          pattern: r'(?-i)memex',
          searchPath: '/Facts/case.md',
          workingDirectory: tempDir.path,
        );

        expect(defaultResult, contains('/Facts/case.md'));
        expect(strictResult, 'No files found');
      },
    );
  });

  group('FileOperationService.grepFiles ripgrep engine', () {
    late Directory tempDir;
    late FileOperationService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('memex_rg_test_');
      service = FileOperationService.forTesting(
        ripgrepExecutable: ripgrepExecutable,
      );

      await File(
        p.join(tempDir.path, 'allowed.md'),
      ).writeAsString('Memex mixed case\n');
      await File(
        p.join(tempDir.path, 'blocked.md'),
      ).writeAsString('secret should stay unread\n');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'uses real ripgrep syntax when rg is available',
      () async {
        final result = await service.grepFiles(
          pattern: r'(?i:memex)',
          searchPath: tempDir.path,
          outputMode: 'content',
          n: true,
        );

        expect(result, contains('/allowed.md:1:Memex mixed case'));
      },
      skip: ripgrepExecutable == null ? 'ripgrep is not available' : false,
    );

    test(
      'uses access scope exclusions before invoking directory ripgrep',
      () async {
        final blockedPath = p.join(tempDir.path, 'blocked.md');
        final result = await service.grepFiles(
          pattern: r'(?i:memex)|secret',
          searchPath: tempDir.path,
          accessScope: FileSearchAccessScope(
            allowsRead: (filePath) => filePath != blockedPath,
            excludedPaths: [blockedPath],
          ),
        );

        expect(result, contains('/allowed.md'));
        expect(result, isNot(contains('/blocked.md')));
        expect(result, isNot(contains('secret')));
      },
      skip: ripgrepExecutable == null ? 'ripgrep is not available' : false,
    );

    test('builds directory ripgrep args from access scope', () async {
      final blockedPath = p.join(tempDir.path, 'blocked.md');
      final args = await service.buildRipgrepDirectoryArgsForTesting(
        searchPath: tempDir.path,
        includeGlob: '*.md',
        typeExtensions: {'md', 'markdown'},
        accessScope: FileSearchAccessScope(
          allowsRead: (filePath) => filePath != blockedPath,
          excludedPaths: [blockedPath],
        ),
      );

      expect(args, isNotNull);
      expect(args, contains('--no-ignore'));
      expect(args, contains('*.md'));
      expect(args, contains('*.{md,markdown}'));
      expect(args, contains('!blocked.md'));
      expect(args, contains('!blocked.md/**'));
    });
  });
}

String? _findRipgrepExecutable() {
  try {
    final result = Process.runSync('rg', ['--version']);
    return result.exitCode == 0 ? 'rg' : null;
  } catch (_) {
    return null;
  }
}
