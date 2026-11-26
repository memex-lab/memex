import 'dart:io';

import 'package:memex/data/services/file_system_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Remove only this account's workspace and its Drift database files.
/// The selected storage root can be shared with other apps and accounts.
Future<void> deleteLocalAccountFiles(
    FileSystemService fs, String userId) async {
  if (userId.trim().isEmpty ||
      userId.contains('/') ||
      userId.contains(r'\') ||
      userId.contains('\x00')) {
    throw ArgumentError('Invalid local account name');
  }
  final workspace = Directory(fs.getWorkspacePath(userId));
  if (await FileSystemEntity.isLink(workspace.parent.path)) {
    throw FileSystemException(
        'Workspace container is a link', workspace.parent.path);
  }

  final documents = await getApplicationDocumentsDirectory();
  final support = await getApplicationSupportDirectory();
  final dbName = 'memex_local_$userId.sqlite';
  final files = <File>[];
  for (final directory in {documents.path, support.path}) {
    for (final suffix in ['', '-wal', '-shm', '-journal']) {
      final file = File(p.join(directory, '$dbName$suffix'));
      final type = await FileSystemEntity.type(file.path, followLinks: false);
      if (type == FileSystemEntityType.notFound) continue;
      if (type != FileSystemEntityType.file &&
          type != FileSystemEntityType.link) {
        throw FileSystemException('Unexpected database file type', file.path);
      }
      files.add(file);
    }
  }
  final type = await FileSystemEntity.type(workspace.path, followLinks: false);
  if (type == FileSystemEntityType.link) {
    await Link(workspace.path).delete();
  } else if (type == FileSystemEntityType.directory) {
    await workspace.delete(recursive: true);
  } else if (type != FileSystemEntityType.notFound) {
    throw FileSystemException('Unexpected workspace type', workspace.path);
  }
  for (final file in files) {
    await file.delete();
  }
}
