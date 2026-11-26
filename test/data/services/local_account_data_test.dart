import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_account_data.dart';
import 'package:memex/data/services/local_asset_server.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _AppDirs extends PathProviderPlatform {
  _AppDirs(this.root);
  final String root;

  @override
  Future<String?> getApplicationDocumentsPath() async => '$root/docs';
  @override
  Future<String?> getApplicationSupportPath() async => '$root/support';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  late Directory selected;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('memex-account-files');
    final previous = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _AppDirs(root.path);
    addTearDown(() => PathProviderPlatform.instance = previous);
    selected = await Directory('${root.path}/chosen').create();
    await FileSystemService.init(selected.path);
    addTearDown(() async {
      await LocalAssetServer.stopServer();
      await root.delete(recursive: true);
    });
  });

  test(
      'delete only the account workspace and exact database files, even on retry',
      () async {
    const user = 'reader';
    final other = File('${selected.path}/workspace/_reader-2/keep.md');
    final backup = File('${selected.path}/backup.memex');
    final own = File('${selected.path}/workspace/_reader/Facts/record.md');
    final removed = [own];
    final kept = [other, backup];
    for (final dir in ['docs', 'support']) {
      final prefix = '${root.path}/$dir/memex_local_reader';
      removed.addAll(['', '-wal', '-shm', '-journal']
          .map((suffix) => File('$prefix.sqlite$suffix')));
      kept.addAll([File('$prefix.sqlite.bak'), File('$prefix-2.sqlite')]);
    }
    for (final file in [...kept, ...removed]) {
      await file.create(recursive: true);
      await file.writeAsString(file.path);
    }
    await Link('${own.parent.path}/external').create(other.parent.path);
    await deleteLocalAccountFiles(FileSystemService.instance, user);
    await deleteLocalAccountFiles(FileSystemService.instance, user);
    for (final file in removed) {
      expect(await file.exists(), isFalse, reason: file.path);
    }
    for (final file in kept) {
      expect(await file.readAsString(), file.path);
    }
  });

  test(
      'a linked workspace container or malformed identity cannot reach outside the account',
      () async {
    final external = File('${root.path}/elsewhere/_reader/record.md');
    await external.create(recursive: true);
    await external.writeAsString('outside');
    await Link('${selected.path}/workspace')
        .create(external.parent.parent.path);
    await expectLater(
        deleteLocalAccountFiles(FileSystemService.instance, 'reader'),
        throwsA(isA<FileSystemException>()));
    for (final id in ['', ' ', 'x/../_reader', r'x\reader']) {
      await expectLater(deleteLocalAccountFiles(FileSystemService.instance, id),
          throwsArgumentError);
    }
    // A link at the account path itself can be unlinked without descending.
    await Link('${selected.path}/workspace').delete();
    await Directory('${selected.path}/workspace').create();
    final accountLink = Link('${selected.path}/workspace/_reader');
    await accountLink.create(external.parent.path);
    await deleteLocalAccountFiles(FileSystemService.instance, 'reader');
    expect(await accountLink.exists(), isFalse);
    expect(await external.readAsString(), 'outside');
  });
}
