import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/security/file_permission_manager.dart';
import 'package:memex/agent/super_agent/super_agent.dart';

void main() {
  const workspace = '/ws/_u';
  const facts = '/ws/_u/Facts';
  const assets = '/ws/_u/Facts/assets';

  FilePermissionManager managerFor({required bool quickQuery}) {
    return FilePermissionManager(
      'test_user',
      SuperAgent.buildPermissionRules(
        workspacePath: workspace,
        factsPath: facts,
        factsAssetsPath: assets,
        quickQuery: quickQuery,
      ),
      withDefaultRules: false,
    );
  }

  group('SuperAgent file permissions (normal mode)', () {
    final manager = managerFor(quickQuery: false);

    test('non-asset files under Facts are read-only', () {
      expect(
        () => manager.checkPermission(
            '$facts/2026/06/10.md', FileAccessType.write),
        throwsA(isA<PermissionDeniedException>()),
      );
      // Reading stays allowed.
      manager.checkPermission('$facts/2026/06/10.md', FileAccessType.read);
    });

    test('moving or removing a Facts directory is denied (write on source)',
        () {
      expect(
        () => manager.checkPermission('$facts/2026/06', FileAccessType.write),
        throwsA(isA<PermissionDeniedException>()),
      );
    });

    test('media files under assets stay writable', () {
      manager.checkPermission('$assets/photo.jpg', FileAccessType.write);
      manager.checkPermission('$assets/voice.m4a', FileAccessType.write);
    });

    test('the rest of the workspace stays writable', () {
      manager.checkPermission(
          '$workspace/Cards/2026_06_10.yaml', FileAccessType.write);
      manager.checkPermission('$workspace/PKM/note.md', FileAccessType.write);
    });
  });

  group('SuperAgent file permissions (quick query)', () {
    final manager = managerFor(quickQuery: true);

    test('everything is read-only including assets', () {
      manager.checkPermission('$facts/2026/06/10.md', FileAccessType.read);
      expect(
        () =>
            manager.checkPermission('$assets/photo.jpg', FileAccessType.write),
        throwsA(isA<PermissionDeniedException>()),
      );
      expect(
        () => manager.checkPermission(
            '$workspace/Cards/c.yaml', FileAccessType.write),
        throwsA(isA<PermissionDeniedException>()),
      );
    });
  });

  group('SuperAgent quick query tools', () {
    test('does not expose event log search or current time tools', () {
      expect(
        SuperAgent.isQuickQueryToolAllowed('search_workspace_event_logs'),
        isFalse,
      );
      expect(
        SuperAgent.isQuickQueryToolAllowed('getCurrentTime'),
        isFalse,
      );
    });

    test('allows image viewing as a read-only tool', () {
      expect(SuperAgent.isQuickQueryToolAllowed('view_image'), isTrue);
    });

    test('allows generic LS for read-only filesystem access', () {
      expect(SuperAgent.isQuickQueryToolAllowed('LS'), isTrue);
    });
  });

  group('SuperAgent run limits', () {
    test('root agent allows long import and organization runs', () {
      expect(SuperAgent.rootMaxTurns, greaterThan(20));
      expect(SuperAgent.rootMaxTurns, 80);
    });
  });

  group('SuperAgent legacy active skills', () {
    test('drops stale active skill names before agent tools are composed', () {
      final state = AgentState(
        sessionId: 'legacy_active_skill_session',
        metadata: {'userId': 'legacy_skill_user'},
        activeSkills: [
          'create_dynamic_timeline_card',
          'manage_timeline_card',
        ],
      );

      final pruned = SuperAgent.pruneUnavailableActiveSkills(
        state,
        {'manage_timeline_card', 'dynamic_timeline_ui'},
      );

      expect(pruned, isTrue);
      expect(state.activeSkills, ['manage_timeline_card']);
    });
  });
}
