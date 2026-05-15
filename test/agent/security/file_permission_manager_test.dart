import 'dart:io';

import 'package:memex/agent/security/file_permission_manager.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('FilePermissionManager.buildSearchAccessScope', () {
    late Directory tempDir;

    setUp(() async {
      tempDir =
          await Directory.systemTemp.createTemp('memex_permission_scope_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('exports denied subtrees as directory-search exclusions', () {
      final deniedPath = p.join(tempDir.path, '_System');
      final manager = FilePermissionManager(
        'user-1',
        [
          PermissionRule(
            rootPath: tempDir.path,
            access: FileAccessType.read,
          ),
          PermissionRule(
            rootPath: deniedPath,
            access: FileAccessType.none,
          ),
        ],
        withDefaultRules: false,
      );

      final scope = manager.buildSearchAccessScope(tempDir.path);

      expect(scope.canUseDirectorySearch, isTrue);
      expect(scope.excludedPaths, [deniedPath]);
      expect(scope.allowsRead(tempDir.path), isTrue);
      expect(scope.allowsRead(deniedPath), isFalse);
    });

    test('disables directory search when denied subtree has readable override',
        () {
      final deniedPath = p.join(tempDir.path, '_System');
      final readableOverride = p.join(deniedPath, 'Public');
      final manager = FilePermissionManager(
        'user-1',
        [
          PermissionRule(
            rootPath: tempDir.path,
            access: FileAccessType.read,
          ),
          PermissionRule(
            rootPath: deniedPath,
            access: FileAccessType.none,
          ),
          PermissionRule(
            rootPath: readableOverride,
            access: FileAccessType.read,
          ),
        ],
        withDefaultRules: false,
      );

      final scope = manager.buildSearchAccessScope(tempDir.path);

      expect(scope.canUseDirectorySearch, isFalse);
      expect(scope.allowsRead(deniedPath), isFalse);
      expect(scope.allowsRead(readableOverride), isTrue);
    });

    test('ignores denied rules outside the requested search root', () {
      final outsidePath = p.join(tempDir.parent.path, 'outside-denied');
      final manager = FilePermissionManager(
        'user-1',
        [
          PermissionRule(
            rootPath: tempDir.path,
            access: FileAccessType.read,
          ),
          PermissionRule(
            rootPath: outsidePath,
            access: FileAccessType.none,
          ),
        ],
        withDefaultRules: false,
      );

      final scope = manager.buildSearchAccessScope(tempDir.path);

      expect(scope.canUseDirectorySearch, isTrue);
      expect(scope.excludedPaths, isEmpty);
    });
  });
}
