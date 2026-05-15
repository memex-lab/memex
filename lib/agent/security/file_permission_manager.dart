import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/file_search_access_scope.dart';
import 'package:path/path.dart' as p;
import 'package:collection/collection.dart';

enum FileAccessType {
  read,
  write, // Implies read
  none
}

class PermissionDeniedException implements Exception {
  final String path;
  final FileAccessType requiredAccess;

  PermissionDeniedException(this.path, this.requiredAccess);

  @override
  String toString() =>
      'PermissionDeniedException: Access denied for "$path". Required: $requiredAccess';
}

class PermissionRule {
  final String path;
  final FileAccessType access;

  /// Creates a rule. [rootPath] will be normalized to an absolute path.
  /// If provided path is not absolute, it might be ambiguous, so absolute paths are recommended.
  PermissionRule({required String rootPath, required this.access})
      : path = _normalize(rootPath);

  @override
  String toString() => 'PermissionRule($path, $access)';
}

/// Normalizes path to be absolute and remove trailing separators for consistent matching
String _normalize(String path) {
  var normalized = p.normalize(p.absolute(path));
  // Remove trailing separator if present (except for root /)
  if (normalized.length > 1 && normalized.endsWith(p.separator)) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  return normalized;
}

class FilePermissionManager {
  final List<PermissionRule> _rules;

  /// Creates a manager with the given [rules].
  /// Rules will be automatically sorted by specificity (longest path first).
  FilePermissionManager(
    String userId,
    List<PermissionRule> rules, {
    bool withDefaultRules = true,
  }) : _rules = [] {
    final allRules = List<PermissionRule>.from(rules);
    if (withDefaultRules) {
      final fileService = FileSystemService.instance;
      allRules.addAll([
        PermissionRule(
            rootPath: fileService.getSystemPath(userId),
            access: FileAccessType.none),
        PermissionRule(
            rootPath: fileService.getChatSessionsPath(userId),
            access: FileAccessType.none),
        PermissionRule(
            // Legacy file, deprecated
            rootPath: fileService.getProfilePath(userId),
            access: FileAccessType.none),
        PermissionRule(
            rootPath: fileService.getWorkspacePath(userId),
            access: FileAccessType.read),
      ]);
    }
    _rules.addAll(_sortRulesBySpecificity(allRules));
  }

  static List<PermissionRule> _sortRulesBySpecificity(
      List<PermissionRule> rules) {
    final sorted = List<PermissionRule>.from(rules);
    // Sort by path length descending (Longest Prefix Match)
    // Use mergeSort from 'package:collection' for STABLE sorting.
    // This ensures that if two rules have the same path length (or same path),
    // their relative order is preserved.
    mergeSort(sorted,
        compare: (a, b) => b.path.length.compareTo(a.path.length));
    return sorted;
  }

  /// Checks if the operation is allowed for the target [path].
  /// Throws [PermissionDeniedException] if not allowed.
  void checkPermission(String path, FileAccessType requiredAccess) {
    final normalizedTarget = _normalize(path);

    // Find the 'Topmost' rule (Longest Prefix Match)
    final match = _rules.firstWhere(
      (rule) {
        if (normalizedTarget == rule.path) return true;
        if (normalizedTarget.startsWith(rule.path)) {
          // Ensure it's a directory match (e.g. /foo/bar matches /foo, but /foobar does not match /foo)
          final rest = normalizedTarget.substring(rule.path.length);
          if (rest.startsWith(p.separator)) return true;
          // Special case dealing with root
          if (rule.path == p.separator) return true;
        }
        return false;
      },
      orElse: () =>
          PermissionRule(rootPath: p.separator, access: FileAccessType.none),
    );

    if (!_hasAccess(match.access, requiredAccess)) {
      throw PermissionDeniedException(normalizedTarget, requiredAccess);
    }
  }

  /// Checks if the operation is allowed for the target [path] without throwing.
  bool allowsRead(String path) {
    try {
      checkPermission(path, FileAccessType.read);
      return true;
    } catch (_) {
      return false;
    }
  }

  FileSearchAccessScope buildSearchAccessScope(String searchRoot) {
    final normalizedRoot = _normalize(searchRoot);
    final excludedPaths = <String>[];
    var canUseDirectorySearch = true;

    for (final rule in _rules) {
      if (rule.access != FileAccessType.none) {
        continue;
      }
      if (!_isSameOrUnder(rule.path, normalizedRoot)) {
        continue;
      }
      if (allowsRead(rule.path)) {
        continue;
      }

      final hasReadableDescendant = _rules.any((other) =>
          other.path != rule.path &&
          _isSameOrUnder(other.path, rule.path) &&
          _hasAccess(other.access, FileAccessType.read));
      if (hasReadableDescendant) {
        canUseDirectorySearch = false;
        break;
      }

      final alreadyExcluded =
          excludedPaths.any((excluded) => _isSameOrUnder(rule.path, excluded));
      if (!alreadyExcluded) {
        excludedPaths.add(rule.path);
      }
    }

    return FileSearchAccessScope(
      allowsRead: allowsRead,
      excludedPaths: excludedPaths,
      canUseDirectorySearch: canUseDirectorySearch,
    );
  }

  bool _hasAccess(FileAccessType granted, FileAccessType required) {
    if (granted == FileAccessType.none) return false;
    if (granted == FileAccessType.write) return true; // Write implies Read
    if (granted == FileAccessType.read && required == FileAccessType.read) {
      return true;
    }
    return false;
  }

  bool _isSameOrUnder(String childPath, String parentPath) {
    final child = _normalize(childPath);
    final parent = _normalize(parentPath);
    if (child == parent) return true;
    if (child.startsWith(parent)) {
      final rest = child.substring(parent.length);
      return rest.startsWith(p.separator) || parent == p.separator;
    }
    return false;
  }
}
