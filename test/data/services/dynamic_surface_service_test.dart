import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/dynamic_surface_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/dynamic_surface_model.dart';
import 'package:path/path.dart' as path;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late FileSystemService fileSystemService;
  const userId = 'dynamic_surface_user';

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('memex_dynamic_surface_');
    fileSystemService = FileSystemService.detached(dataRoot: tempDir.path);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('parses Markdown directory through parser.js', () async {
    final workspacePath = fileSystemService.getWorkspacePath(userId);
    final projectDir = Directory(path.join(
      workspacePath,
      '_UserSettings',
      'DynamicSurfaceData',
      'project_board',
    ));
    await projectDir.create(recursive: true);
    await File(path.join(projectDir.path, 'Launch.md')).writeAsString('''
# Launch

## Landing page
Status: active
Due: 2026-06-10

Ship the first public landing page.

## Onboarding
Status: blocked
Due: 2026-06-20

Needs copy review.
''');

    await _writeSurfacePackage(
      fileSystemService,
      userId,
      'project_board',
      source: {
        'type': 'directory',
        'path': '_UserSettings/DynamicSurfaceData/project_board',
      },
      parser: '''
function parse(input) {
  const items = [];
  for (const file of input.files) {
    const sections = file.content.split(/\\n(?=##\\s+)/g);
    for (const section of sections) {
      const title = (section.match(/^##\\s+(.+)\$/m) || [])[1];
      if (!title) continue;
      const status = (section.match(/^Status:\\s*(.+)\$/m) || [])[1] || "";
      const due = (section.match(/^Due:\\s*(.+)\$/m) || [])[1] || "";
      items.push({ title, status, due, file_path: file.path });
    }
  }
  if (!items.length && input.files.length) {
    throw new Error("No project sections found");
  }
  return { kind: "project_board", items };
}
''',
    );

    final service = DynamicSurfaceService(fileSystemService: fileSystemService);
    final surface = await service.getSurface(userId, 'project_board');
    final data =
        await service.readSurfaceData(userId, surface!) as Map<String, dynamic>;

    expect(data['kind'], 'project_board');

    final items = data['items'] as List<dynamic>;
    expect(items, hasLength(2));
    expect(items.first['title'], 'Landing page');
    expect(items.first['status'], 'active');
    expect(items.first['due'], '2026-06-10');
    expect(items.last['title'], 'Onboarding');
    expect(items.last['status'], 'blocked');
  });

  test('renders free-form HTML with injected parser JSON', () async {
    final workspacePath = fileSystemService.getWorkspacePath(userId);
    final notesDir = Directory(path.join(
      workspacePath,
      '_UserSettings',
      'DynamicSurfaceData',
      'health_grid',
    ));
    await notesDir.create(recursive: true);
    await File(path.join(notesDir.path, 'Health.md')).writeAsString('''
# Health

- name: Sleep | score: 8 | trend: up
- name: Mobility | score: 5 | trend: flat
''');

    await _writeSurfacePackage(
      fileSystemService,
      userId,
      'health_grid',
      source: {
        'type': 'file',
        'path': '_UserSettings/DynamicSurfaceData/health_grid/Health.md',
      },
      parser: '''
function parse(input) {
  const items = [];
  for (const line of input.files[0].content.split("\\n")) {
    const match = line.match(/^[-*]\\s+(.+)\$/);
    if (!match) continue;
    const item = {};
    for (const part of match[1].split("|")) {
      const index = part.indexOf(":");
      if (index < 0) continue;
      item[part.slice(0, index).trim()] = part.slice(index + 1).trim();
    }
    items.push(item);
  }
  return { items };
}
''',
      html: '''
<section>
  <h1>{{surface.title}}</h1>
  <script type="application/json" id="memex-data">{{memex_data_json}}</script>
</section>
''',
    );

    final service = DynamicSurfaceService(fileSystemService: fileSystemService);
    final result = await service.renderSurface(userId, 'health_grid');

    expect(result.contentType, 'html');
    expect(result.content, contains('<h1>health_grid</h1>'));
    expect(result.content, contains('"items"'));

    final dataJson = RegExp(
      r'<script type="application/json" id="memex-data">(.+)</script>',
      dotAll: true,
    ).firstMatch(result.content)!.group(1)!;
    final decoded = jsonDecode(dataJson) as Map<String, dynamic>;
    final items = decoded['items'] as List<dynamic>;
    expect(items.first['name'], 'Sleep');
    expect(items.first['score'], '8');
    expect(items.last['trend'], 'flat');
  });

  test('passes through top-level array parser output', () async {
    final workspacePath = fileSystemService.getWorkspacePath(userId);
    final notesDir = Directory(path.join(
      workspacePath,
      '_UserSettings',
      'DynamicSurfaceData',
      'reading_list',
    ));
    await notesDir.create(recursive: true);
    await File(path.join(notesDir.path, 'Reading.md')).writeAsString('''
# Reading

- Deep Work
- Shape Up
''');

    await _writeSurfacePackage(
      fileSystemService,
      userId,
      'reading_list',
      source: {
        'type': 'file',
        'path': '_UserSettings/DynamicSurfaceData/reading_list/Reading.md',
      },
      parser: '''
function parse(input) {
  return input.files[0].content
    .split("\\n")
    .map((line) => line.match(/^[-*]\\s+(.+)\$/))
    .filter(Boolean)
    .map((match) => ({ title: match[1] }));
}
''',
      html: '''
<script type="application/json" id="memex-data">{{memex_data_json}}</script>
''',
    );

    final service = DynamicSurfaceService(fileSystemService: fileSystemService);
    final result = await service.renderSurface(userId, 'reading_list');

    expect(result.data, isA<List<dynamic>>());
    expect(result.data as List<dynamic>, hasLength(2));

    final dataJson = RegExp(
      r'<script type="application/json" id="memex-data">(.+)</script>',
      dotAll: true,
    ).firstMatch(result.content)!.group(1)!;
    final decoded = jsonDecode(dataJson) as List<dynamic>;
    expect(decoded.first['title'], 'Deep Work');
    expect(decoded.last['title'], 'Shape Up');
  });

  test('installs authored surface with parser.js and optional Markdown content',
      () async {
    final service = DynamicSurfaceService(fileSystemService: fileSystemService);

    final result = await service.installAuthoredSurface(
      userId: userId,
      surfaceId: 'authored_board',
      title: 'Authored Board',
      source: const DynamicSurfaceSource(
        type: 'file',
        path: '_UserSettings/DynamicSurfaceData/authored_board/Authored.md',
      ),
      parser: const DynamicSurfaceParserSpec(
        scriptPath: 'parser.js',
      ),
      parserContent: '''
function parse(input) {
  const file = input.files[0];
  const title = (file.content.match(/^##\\s+(.+)\$/m) || [])[1];
  const status = (file.content.match(/^Status:\\s*(.+)\$/m) || [])[1];
  if (!title || !status) throw new Error("Invalid authored board markdown");
  return { items: [{ title, status, file_path: file.path }] };
}
''',
      markdownContent: '''
# Authored

## First item
Status: active

This item came from agent-authored Markdown.
''',
      htmlContent: '''
<h1>{{surface.title}}</h1>
<script type="application/json">{{memex_data_json}}</script>
''',
    );

    expect(result.surface.id, 'authored_board');
    expect(result.content, contains('<h1>Authored Board</h1>'));

    final data = result.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;
    expect(items, hasLength(1));
    expect(items.single['title'], 'First item');
    expect(items.single['status'], 'active');
  });

  test('does not install authored surface with native source', () async {
    final service = DynamicSurfaceService(fileSystemService: fileSystemService);

    expect(
      () => service.installAuthoredSurface(
        userId: userId,
        surfaceId: 'bad_facts_source',
        title: 'Bad Facts Source',
        source: const DynamicSurfaceSource(
          type: 'file',
          path: 'Facts/2026/06/03.md',
        ),
        parser: const DynamicSurfaceParserSpec(
          scriptPath: 'parser.js',
        ),
        parserContent: 'function parse(input) { return { items: [] }; }',
        htmlContent: '<script>const data = {{memex_data_json}};</script>',
      ),
      throwsArgumentError,
    );
  });

  test('fails when parser.js rejects invalid Markdown data', () async {
    final workspacePath = fileSystemService.getWorkspacePath(userId);
    final dataDir = Directory(path.join(
      workspacePath,
      '_UserSettings',
      'DynamicSurfaceData',
      'daily_report',
    ));
    await dataDir.create(recursive: true);
    await File(path.join(dataDir.path, 'broken.md')).writeAsString('No date');

    await _writeSurfacePackage(
      fileSystemService,
      userId,
      'daily_report',
      source: {
        'type': 'directory',
        'path': '_UserSettings/DynamicSurfaceData/daily_report',
      },
      parser: '''
function parse(input) {
  const items = input.files.map((file) => {
    const date = (file.content.match(/^date:\\s*(.+)\$/m) || [])[1];
    if (!date) throw new Error("Missing date in " + file.path);
    return { date };
  });
  return { items };
}
''',
    );

    final service = DynamicSurfaceService(fileSystemService: fileSystemService);
    expect(
      () => service.renderSurface(userId, 'daily_report'),
      throwsA(anything),
    );

    final validation = await service.validateSurface(userId, 'daily_report');
    expect(validation.isValid, isFalse);
    expect(validation.surfaceId, 'daily_report');
    expect(validation.errorMessage, contains('Missing date'));
  });

  test('uninstalls package, page-owned source data, and draft', () async {
    final workspacePath = fileSystemService.getWorkspacePath(userId);
    final dataDir = Directory(path.join(
      workspacePath,
      '_UserSettings',
      'DynamicSurfaceData',
      'daily_report',
    ));
    await dataDir.create(recursive: true);
    await File(path.join(dataDir.path, 'data.md')).writeAsString('# Report');

    await _writeSurfacePackage(
      fileSystemService,
      userId,
      'daily_report',
      source: {
        'type': 'file',
        'path': '_UserSettings/DynamicSurfaceData/daily_report/data.md',
      },
      parser: 'function parse(input) { return input.files.length; }',
    );

    final draftDir = Directory(path.join(
      fileSystemService.getDynamicSurfaceDraftRootPath(userId),
      'daily_report',
    ));
    await draftDir.create(recursive: true);
    await File(path.join(draftDir.path, 'view.html')).writeAsString('<html>');

    final service = DynamicSurfaceService(fileSystemService: fileSystemService);
    final result = await service.uninstallSurface(
      userId: userId,
      surfaceId: 'daily_report',
    );

    expect(result.surfaceId, 'daily_report');
    expect(result.deletedPackage, isTrue);
    expect(
      result.deletedSourcePath,
      '_UserSettings/DynamicSurfaceData/daily_report',
    );
    expect(result.deletedDraft, isTrue);
    expect(
      await Directory(
        fileSystemService.getDynamicSurfacePath(userId, 'daily_report'),
      ).exists(),
      isFalse,
    );
    expect(await dataDir.exists(), isFalse);
    expect(await draftDir.exists(), isFalse);
    expect(await service.getSurface(userId, 'daily_report'), isNull);
  });
}

Future<void> _writeSurfacePackage(
  FileSystemService fileSystemService,
  String userId,
  String surfaceId, {
  required Map<String, dynamic> source,
  required String parser,
  String html = '<script>const data = {{memex_data_json}};</script>',
}) async {
  await fileSystemService.writeDynamicSurfaceManifest(userId, surfaceId, {
    'id': surfaceId,
    'title': surfaceId,
    'source': source,
    'parser': {
      'type': 'javascript',
      'script_path': 'parser.js',
      'entry': 'parse',
    },
    'render': {
      'type': 'html',
      'template_path': 'view.html',
    },
  });
  final surfaceDir = Directory(
    fileSystemService.getDynamicSurfacePath(userId, surfaceId),
  );
  await surfaceDir.create(recursive: true);
  await File(path.join(surfaceDir.path, 'view.html')).writeAsString(html);
  await File(path.join(surfaceDir.path, 'parser.js')).writeAsString(parser);
}
