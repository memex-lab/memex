typedef FilePathAccessPredicate = bool Function(String path);

/// Describes the file access boundary for a search operation.
///
/// FileOperationService consumes this as an execution hint only; the permission
/// system owns the policy and decides which subtrees must be excluded before a
/// directory-level search can be delegated to an external search engine.
class FileSearchAccessScope {
  final FilePathAccessPredicate allowsRead;
  final List<String> excludedPaths;
  final bool canUseDirectorySearch;

  const FileSearchAccessScope({
    required this.allowsRead,
    this.excludedPaths = const [],
    this.canUseDirectorySearch = true,
  });
}
