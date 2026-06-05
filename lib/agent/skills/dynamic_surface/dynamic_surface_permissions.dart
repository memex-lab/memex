import 'package:memex/agent/security/file_permission_manager.dart';
import 'package:memex/data/services/dynamic_surface_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:path/path.dart' as path;

bool isWorkspacePathUnderFacts({
  required String userId,
  required String workspaceRelativePath,
  FileSystemService? fileSystemService,
}) {
  final fileSystem = fileSystemService ?? FileSystemService.instance;
  final resolved = _resolveWorkspaceRelativePath(
    userId: userId,
    workspaceRelativePath: workspaceRelativePath,
    fileSystemService: fileSystem,
  );
  final facts = path.normalize(fileSystem.getFactsPath(userId));
  return _isSameOrUnder(resolved, facts);
}

bool isWorkspacePathUnderNativeSource({
  required String userId,
  required String workspaceRelativePath,
  FileSystemService? fileSystemService,
}) {
  final fileSystem = fileSystemService ?? FileSystemService.instance;
  final resolved = _resolveWorkspaceRelativePath(
    userId: userId,
    workspaceRelativePath: workspaceRelativePath,
    fileSystemService: fileSystem,
  );
  return _nativeSourceRoots(userId, fileSystem).any(
    (root) => _isSameOrUnder(resolved, root),
  );
}

void rejectWorkspacePathUnderFacts({
  required String userId,
  required String workspaceRelativePath,
  required String argumentName,
  FileSystemService? fileSystemService,
}) {
  if (!isWorkspacePathUnderFacts(
    userId: userId,
    workspaceRelativePath: workspaceRelativePath,
    fileSystemService: fileSystemService,
  )) {
    return;
  }
  throw ArgumentError(
    '$argumentName must not be /Facts or any path under /Facts. '
    'Facts contains raw user records and is read-only. Use '
    '/_UserSettings/DynamicSurfaceData/<surface_id>/ for page-owned '
    'maintained data derived from Facts.',
  );
}

void rejectWorkspacePathUnderNativeSource({
  required String userId,
  required String workspaceRelativePath,
  required String argumentName,
  FileSystemService? fileSystemService,
}) {
  if (!isWorkspacePathUnderNativeSource(
    userId: userId,
    workspaceRelativePath: workspaceRelativePath,
    fileSystemService: fileSystemService,
  )) {
    return;
  }
  throw ArgumentError(
    '$argumentName must not be /Facts, /PKM, /Cards, /KnowledgeInsights, '
    'or any path under those native Memex directories. Dynamic Surface page '
    'agents maintain page-owned Markdown under '
    '/_UserSettings/DynamicSurfaceData/<surface_id>/ and read native '
    'directories only as evidence or trigger origins.',
  );
}

Future<List<PermissionRule>?> buildManagedDynamicSurfaceWriteRules({
  required String userId,
  required String? surfaceId,
  required FileSystemService fileSystemService,
  DynamicSurfaceService? dynamicSurfaceService,
}) async {
  if (surfaceId == null || surfaceId.isEmpty) return null;

  final service = dynamicSurfaceService ??
      DynamicSurfaceService(fileSystemService: fileSystemService);
  final surface = await service.getSurface(userId, surfaceId);
  if (surface == null) return const [];

  final workspace = path.normalize(fileSystemService.getWorkspacePath(userId));
  final sourcePath = path.normalize(path.join(workspace, surface.source.path));
  final writeRoot = sourcePath;

  if (_nativeSourceRoots(userId, fileSystemService).any(
    (root) => _isSameOrUnder(writeRoot, root),
  )) {
    rejectWorkspacePathUnderNativeSource(
      userId: userId,
      workspaceRelativePath: surface.source.path,
      argumentName: 'Dynamic Surface source.path',
      fileSystemService: fileSystemService,
    );
  }

  return [
    PermissionRule(rootPath: writeRoot, access: FileAccessType.write),
  ];
}

bool _isSameOrUnder(String childPath, String parentPath) {
  final child = path.normalize(childPath);
  final parent = path.normalize(parentPath);
  if (child == parent) return true;
  return path.isWithin(parent, child);
}

String _resolveWorkspaceRelativePath({
  required String userId,
  required String workspaceRelativePath,
  required FileSystemService fileSystemService,
}) {
  final workspace = path.normalize(fileSystemService.getWorkspacePath(userId));
  return path.normalize(path.join(workspace, workspaceRelativePath));
}

List<String> _nativeSourceRoots(
  String userId,
  FileSystemService fileSystemService,
) {
  return [
    fileSystemService.getFactsPath(userId),
    fileSystemService.getPkmPath(userId),
    fileSystemService.getCardsPath(userId),
    fileSystemService.getKnowledgeInsightsPath(userId),
  ].map(path.normalize).toList();
}
