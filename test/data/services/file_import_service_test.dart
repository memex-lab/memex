import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/file_import_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/ui/settings/view_models/data_import_viewmodel.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await UserStorage.initL10n();
    await UserStorage.saveUser('import-user');
    tempDir = await Directory.systemTemp.createTemp('memex_file_import_');
    await FileSystemService.init(tempDir.path);
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  FileImportService service() {
    return FileImportService.forTesting();
  }

  test(
      'copies arbitrary files into _UserSettings/Imported and renames conflicts',
      () async {
    final sourceFileA = File(
      p.join(tempDir.path, 'sources', 'a', 'notes.txt'),
    );
    final sourceFileB = File(
      p.join(tempDir.path, 'sources', 'b', 'notes.txt'),
    );
    await sourceFileA.create(recursive: true);
    await sourceFileB.create(recursive: true);
    await sourceFileA.writeAsString('legacy note a');
    await sourceFileB.writeAsString('legacy note b');

    final result = await service().importToUserSettingsImported([
      sourceFileA.path,
      sourceFileB.path,
    ]);

    expect(result.sourceName, startsWith('Selected Files '));
    expect(result.importedFileCount, 2);
    expect(result.generatedTextFileCount, 0);
    expect(result.renamedConflictCount, 1);
    expect(
      result.workspaceRelativeDirectoryPath,
      p.join('_UserSettings', 'Imported', result.sourceName),
    );
    expect(
      result.settingsRelativeDirectoryPath,
      p.join('Imported', result.sourceName),
    );
    expect(
      result.absoluteDirectoryPath,
      p.join(
        FileSystemService.instance.getImportedFilesPath('import-user'),
        result.sourceName,
      ),
    );
    expect(
      await Directory(p.join(
        FileSystemService.instance.getPkmPath('import-user'),
        'Resources',
        'Imported',
      )).exists(),
      isFalse,
    );

    final importedFileA = File(
      p.join(result.absoluteDirectoryPath, 'notes.txt'),
    );
    final importedFileB = File(
      p.join(result.absoluteDirectoryPath, 'notes 2.txt'),
    );
    expect(await importedFileA.readAsString(), 'legacy note a');
    expect(await importedFileB.readAsString(), 'legacy note b');
    expect(
      await File(p.join(
        result.absoluteDirectoryPath,
        'notes.txt.extracted-text-for-agent.md',
      )).exists(),
      isFalse,
    );
  });

  test('creates agent-readable extracted text files next to documents',
      () async {
    final sourcePdf = File(p.join(tempDir.path, 'sources', 'report.pdf'));
    await sourcePdf.create(recursive: true);
    await sourcePdf.writeAsString('fake pdf bytes');

    final importService = FileImportService.forTesting(
      extractDocumentText: (file) async =>
          '# Text extracted from original file: ${p.basename(file.path)}\n\n'
          'extracted body',
    );

    final result = await importService.importToUserSettingsImported([
      sourcePdf.path,
    ]);

    expect(result.importedFileCount, 1);
    expect(result.generatedTextFileCount, 1);

    final generated = result.files.singleWhere((file) => file.isGenerated);
    expect(
      generated.relativePath,
      p.join(
        '_UserSettings',
        'Imported',
        'report',
        'report.pdf.extracted-text-for-agent.md',
      ),
    );
    expect(
      generated.sourceRelativePath,
      p.join(
        '_UserSettings',
        'Imported',
        'report',
        'report.pdf',
      ),
    );
    expect(
      await File(p.join(
        result.absoluteDirectoryPath,
        'report.pdf.extracted-text-for-agent.md',
      )).readAsString(),
      contains('extracted body'),
    );
  });

  test('creates unsupported extracted text helpers for pdf files', () async {
    final sourcePdf = File(p.join(tempDir.path, 'sources', 'report.pdf'));
    await sourcePdf.create(recursive: true);
    await sourcePdf.writeAsBytes(latin1.encode('%PDF-1.4\n%%EOF'));

    final result = await service().importToUserSettingsImported([
      sourcePdf.path,
    ]);

    expect(result.importedFileCount, 1);
    expect(result.generatedTextFileCount, 1);
    final helperFile = File(p.join(
      result.absoluteDirectoryPath,
      'report.pdf.extracted-text-for-agent.md',
    ));
    expect(await helperFile.exists(), isTrue);
    expect(
      await helperFile.readAsString(),
      contains('Memex could not parse readable text content'),
    );
  });

  test('creates persistent fs asset reference helpers next to imported images',
      () async {
    final sourceImage = File(p.join(tempDir.path, 'sources', 'photo.png'));
    await sourceImage.create(recursive: true);
    await sourceImage.writeAsBytes(_pngHeader(width: 320, height: 240));

    final result = await service().importToUserSettingsImported([
      sourceImage.path,
    ]);

    expect(result.importedFileCount, 1);
    expect(result.generatedTextFileCount, 0);
    expect(result.generatedAssetReferenceFileCount, 1);

    final generated = result.files.singleWhere(
      (file) => file.generatedKind == ImportedGeneratedFileKind.assetReference,
    );
    expect(
      generated.relativePath,
      p.join(
        '_UserSettings',
        'Imported',
        'photo',
        'photo.png.asset-reference-for-agent.md',
      ),
    );
    expect(
      generated.sourceRelativePath,
      p.join('_UserSettings', 'Imported', 'photo', 'photo.png'),
    );

    final helperContent = await File(p.join(
      result.absoluteDirectoryPath,
      'photo.png.asset-reference-for-agent.md',
    )).readAsString();
    expect(
      helperContent,
      contains('Corresponding `fs://` reference: `fs://'),
    );
    expect(helperContent, isNot(contains('view_image')));
    expect(helperContent, isNot(contains('/PKM/Resources/Imported')));
    expect(helperContent, isNot(contains('/_UserSettings/Imported')));
    expect(helperContent, isNot(contains('/Facts/assets')));
    expect(helperContent, isNot(contains('Asset type')));

    final assetRef = RegExp(r'fs://([^`]+)').firstMatch(helperContent);
    expect(assetRef, isNotNull);
    final assetFileName = assetRef!.group(1)!;
    expect(
      await File(p.join(
        FileSystemService.instance.getAssetsPath('import-user'),
        assetFileName,
      )).exists(),
      isTrue,
    );
  });

  test('does not create asset reference helpers for imported audio files',
      () async {
    final sourceAudio = File(p.join(tempDir.path, 'sources', 'voice.m4a'));
    await sourceAudio.create(recursive: true);
    await sourceAudio.writeAsBytes(
      const [0x00, 0x00, 0x00, 0x18, 0x66, 0x74, 0x79, 0x70],
    );

    final result = await service().importToUserSettingsImported([
      sourceAudio.path,
    ]);

    expect(result.importedFileCount, 1);
    expect(result.generatedAssetReferenceFileCount, 0);
    expect(
      result.files.map((file) => file.relativePath),
      contains(p.join('_UserSettings', 'Imported', 'voice', 'voice.m4a')),
    );
    expect(
      await File(
        p.join(result.absoluteDirectoryPath, 'voice.m4a'),
      ).exists(),
      isTrue,
    );
    expect(
      await File(p.join(
        result.absoluteDirectoryPath,
        'voice.m4a.asset-reference-for-agent.md',
      )).exists(),
      isFalse,
    );
  });

  test('extracts zip files safely and skips unsafe entries', () async {
    final archive = Archive()
      ..addFile(_archiveFile('folder/a.md', 'first'))
      ..addFile(_archiveFile('folder/b.md', 'second'))
      ..addFile(_archiveFile('../escape.md', 'escape'))
      ..addFile(_archiveFile('/absolute.md', 'absolute'));

    final zipPath = p.join(tempDir.path, 'my-export.zip');
    await File(zipPath).writeAsBytes(ZipEncoder().encode(archive));

    final result = await service().importToUserSettingsImported([zipPath]);

    expect(result.sourceName, 'my-export');
    expect(result.importedFileCount, 2);
    expect(result.renamedConflictCount, 0);
    expect(result.skippedUnsafeArchiveEntries, 2);
    expect(
      result.files.map((file) => file.relativePath).toList(),
      containsAll([
        p.join('_UserSettings', 'Imported', 'my-export', 'folder', 'a.md'),
        p.join('_UserSettings', 'Imported', 'my-export', 'folder', 'b.md'),
      ]),
    );

    expect(
      await File(p.join(result.absoluteDirectoryPath, 'folder', 'a.md'))
          .readAsString(),
      'first',
    );
    expect(
      await File(p.join(result.absoluteDirectoryPath, 'folder', 'b.md'))
          .readAsString(),
      'second',
    );
    expect(
      await File(p.join(
        FileSystemService.instance.getUserSettingsPath('import-user'),
        'escape.md',
      )).exists(),
      isFalse,
    );
  });

  test('super agent import message scopes processing to selected options', () {
    const result = FileImportResult(
      sourceName: 'my-export',
      settingsRelativeDirectoryPath: 'Imported/my-export',
      workspaceRelativeDirectoryPath: '_UserSettings/Imported/my-export',
      absoluteDirectoryPath: '/tmp/workspace/_UserSettings/Imported/my-export',
      files: [
        ImportedFileRecord(
          relativePath: '_UserSettings/Imported/my-export/a.md',
          sizeBytes: 4,
        ),
      ],
      renamedConflictCount: 0,
      skippedUnsafeArchiveEntries: 0,
    );

    final message = buildSuperAgentImportMessage(
      result,
      const ImportProcessingOptions(
        processKnowledgeBase: true,
        processTimelineCards: true,
      ),
    );

    expect(message, contains('`/_UserSettings/Imported/my-export`'));
    expect(message, isNot(contains('Generated extracted-text helper files')));
    expect(message,
        isNot(contains('Generated image asset-reference helper files')));
    expect(message, isNot(contains('Renamed conflicts')));
    expect(message, isNot(contains('not as knowledge-base content')));
    expect(message,
        isNot(contains('Do not assume the app categorized the files')));
    expect(message, contains('Timeline Cards'));
    expect(message, contains('knowledge base'));
    expect(message, isNot(contains('delegate_to_subagent')));
    expect(message, isNot(contains('manage_timeline_card')));
    expect(message, isNot(contains('manage_pkm')));
    expect(
      message,
      isNot(contains('written next to the original imported file')),
    );
    expect(
      message,
      isNot(contains('Treat the imported folder as source material')),
    );
    expect(message, contains('.extracted-text-for-agent.md'));
    expect(
      message,
      isNot(contains('Memex could not parse readable text content')),
    );
    expect(message, isNot(contains('Plain-text formats')));
    expect(message, contains('.asset-reference-for-agent.md'));
    expect(message, isNot(contains('view_image')));
    expect(message, isNot(contains('Do not invent or rewrite')));
    expect(message, isNot(contains('Do not invent fact_ids')));
    expect(message, isNot(contains('imported-only material')));
    expect(message, isNot(contains('pretending it is known')));
    expect(message, contains('process it in chunks'));
    expect(message, contains('context window'));
  });
}

ArchiveFile _archiveFile(String name, String content) {
  final bytes = utf8.encode(content);
  return ArchiveFile(name, bytes.length, bytes);
}

List<int> _pngHeader({required int width, required int height}) {
  final bytes = Uint8List(33);
  bytes.setAll(0, const [
    0x89,
    0x50,
    0x4e,
    0x47,
    0x0d,
    0x0a,
    0x1a,
    0x0a,
    0x00,
    0x00,
    0x00,
    0x0d,
    0x49,
    0x48,
    0x44,
    0x52,
  ]);
  _writeUint32Be(bytes, 16, width);
  _writeUint32Be(bytes, 20, height);
  bytes.setAll(24, const [
    0x08,
    0x02,
    0x00,
    0x00,
    0x00,
    0x90,
    0x77,
    0x53,
    0xde,
  ]);
  return bytes;
}

void _writeUint32Be(Uint8List bytes, int offset, int value) {
  bytes[offset] = (value >> 24) & 0xff;
  bytes[offset + 1] = (value >> 16) & 0xff;
  bytes[offset + 2] = (value >> 8) & 0xff;
  bytes[offset + 3] = value & 0xff;
}
