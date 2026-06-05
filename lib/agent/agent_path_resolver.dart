import 'package:path/path.dart' as path;

/// Resolves agent-visible absolute paths against a configured working directory.
class AgentPathResolver {
  const AgentPathResolver._();

  static String resolve(
    String pathStr, {
    required String workingDirectory,
  }) {
    final normalizedWorkingDirectory = path.normalize(workingDirectory);
    final normalizedPath = path.normalize(pathStr.trim().replaceAll('\\', '/'));

    if (normalizedPath.startsWith(normalizedWorkingDirectory)) {
      return normalizedPath;
    }
    if (normalizedPath.startsWith('/')) {
      if (normalizedPath == '/') return normalizedWorkingDirectory;
      return path.normalize(
        path.join(normalizedWorkingDirectory, normalizedPath.substring(1)),
      );
    }
    return path
        .normalize(path.join(normalizedWorkingDirectory, normalizedPath));
  }

  static String toRelative(
    String pathStr, {
    required String workingDirectory,
    bool allowRoot = false,
    String argumentName = 'path',
  }) {
    final normalizedWorkingDirectory = path.normalize(workingDirectory);
    final resolved = resolve(
      pathStr,
      workingDirectory: normalizedWorkingDirectory,
    );
    if (resolved != normalizedWorkingDirectory &&
        !path.isWithin(normalizedWorkingDirectory, resolved)) {
      throw ArgumentError('$argumentName must stay inside /.');
    }

    final relative = path.relative(resolved, from: normalizedWorkingDirectory);
    if (relative == '.') {
      if (allowRoot) return '';
      throw ArgumentError('$argumentName must not be /.');
    }
    if (relative == '..' || relative.startsWith('../')) {
      throw ArgumentError('$argumentName must stay inside /.');
    }
    return relative;
  }
}
