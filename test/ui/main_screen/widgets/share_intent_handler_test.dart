import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/ui/main_screen/widgets/share_intent_handler.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:share_handler/share_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await UserStorage.initL10n();
    await UserStorage.resetLLMConfigs();
  });

  test('shared document files are routed to import without model config',
      () async {
    final importedPaths = <List<String>>[];
    final drafts = <SharedDraft>[];
    final backupPaths = <String>[];
    final handler = _handler(
      onSharedDraft: drafts.add,
      onBackupFileShared: (path) async => backupPaths.add(path),
      onImportFilesShared: (paths) async => importedPaths.add(paths),
    );

    await handler.handleSharedMediaForTesting(
      SharedMedia(
        attachments: [
          SharedAttachment(
            path: '/tmp/report.pdf',
            type: SharedAttachmentType.file,
          ),
          SharedAttachment(
            path: 'file:///tmp/archive.zip',
            type: SharedAttachmentType.file,
          ),
        ],
      ),
    );

    expect(importedPaths, [
      ['/tmp/report.pdf', '/tmp/archive.zip'],
    ]);
    expect(drafts, isEmpty);
    expect(backupPaths, isEmpty);
  });

  test('memex backup shares still route to restore', () async {
    final importedPaths = <List<String>>[];
    final backupPaths = <String>[];
    final handler = _handler(
      onBackupFileShared: (path) async => backupPaths.add(path),
      onImportFilesShared: (paths) async => importedPaths.add(paths),
    );

    await handler.handleSharedMediaForTesting(
      SharedMedia(
        attachments: [
          SharedAttachment(
            path: 'file:///tmp/backup.memex',
            type: SharedAttachmentType.file,
          ),
        ],
      ),
    );

    expect(backupPaths, ['/tmp/backup.memex']);
    expect(importedPaths, isEmpty);
  });

  test('image-only shares still open a draft', () async {
    await UserStorage.saveLLMConfigs(const [_validLocalModelConfig]);
    final importedPaths = <List<String>>[];
    final drafts = <SharedDraft>[];
    final handler = _handler(
      onSharedDraft: drafts.add,
      onImportFilesShared: (paths) async => importedPaths.add(paths),
    );

    await handler.handleSharedMediaForTesting(
      SharedMedia(
        content: 'photo note',
        attachments: [
          SharedAttachment(
            path: '/tmp/photo.png',
            type: SharedAttachmentType.image,
          ),
        ],
      ),
    );

    expect(importedPaths, isEmpty);
    expect(drafts, hasLength(1));
    expect(drafts.single.text, 'photo note');
    expect(drafts.single.images.single.path, '/tmp/photo.png');
  });
}

ShareIntentHandler _handler({
  void Function(SharedDraft)? onSharedDraft,
  Future<void> Function(String backupFilePath)? onBackupFileShared,
  Future<void> Function(List<String> filePaths)? onImportFilesShared,
}) {
  return ShareIntentHandler(
    logger: Logger('ShareIntentHandlerTest'),
    scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
    onSharedDraft: onSharedDraft ?? (_) {},
    onBackupFileShared: onBackupFileShared ?? (_) async {},
    onImportFilesShared: onImportFilesShared ?? (_) async {},
  );
}

const _validLocalModelConfig = LLMConfig(
  key: 'local-ollama',
  type: LLMConfig.typeOllama,
  modelId: 'llama3',
  apiKey: '',
  baseUrl: 'http://127.0.0.1:11434',
);
