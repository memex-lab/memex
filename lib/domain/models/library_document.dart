import 'package:path/path.dart' as p;

/// A read-only preview derived from the user's Markdown.
class LibraryDocument {
  const LibraryDocument(
      {required this.path,
      required this.title,
      required this.excerpt,
      required this.topics,
      required this.sources,
      required this.openTasks,
      required this.totalTasks,
      required this.items,
      required this.modified});

  final String path, title, excerpt;
  final Set<String> topics, sources;
  final int openTasks, totalTasks, items, modified;

  static final _fact = RegExp(r'<!--\s*fact_id:\s*([^\s>]+)\s*-->');
  static final _task = RegExp(r'^\s*[-*+]\s+\[([ xX])\]\s+(.+)');
  static final _list = RegExp(r'^\s*(?:[-*+] |\d+[.)] )');
  static final _tag =
      RegExp(r'(?:^|\s)#([\p{L}][\p{L}\p{N}_-]*)', unicode: true);
  static const _roots = {
    'Projects',
    'Areas',
    'Resources',
    'Archives',
    '项目',
    '领域',
    '资源',
    '归档'
  };

  factory LibraryDocument.fromMarkdown(
      String path, String content, int modified) {
    final sources = _fact.allMatches(content).map((m) => m[1]!).toSet();
    final topics = p.posix.split(path).toList()..removeLast();
    if (topics.isNotEmpty && _roots.contains(topics.first)) topics.removeAt(0);
    final labels = topics.toSet();
    var title = p.posix.basenameWithoutExtension(path);
    var excerpt = '';
    var statusLine = '';
    var tableHeader = <String>[];
    var open = 0, tasks = 0, items = 0;
    var code = false, frontMatter = false, headingFound = false;
    final lines =
        content.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '').split('\n');
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line == '---' && (i == 0 || frontMatter)) {
        frontMatter = !frontMatter;
        continue;
      }
      if (frontMatter) continue;
      if (line.startsWith('```') || line.startsWith('~~~')) {
        code = !code;
        continue;
      }
      if (code || line.isEmpty) continue;
      if (line.startsWith('# ')) {
        if (!headingFound) {
          title = line.substring(2).trim();
          headingFound = true;
        }
        continue;
      }
      if (line.startsWith('|')) {
        final cells = line
            .split('|')
            .map((c) => c.trim())
            .where((c) => c.isNotEmpty)
            .toList();
        if (cells.isEmpty ||
            cells.every((c) => RegExp(r'^:?-{2,}:?$').hasMatch(c))) {
          continue;
        }
        if (tableHeader.isEmpty) {
          tableHeader = cells;
          continue;
        }
        items++;
        if (excerpt.isEmpty) excerpt = cells.take(3).join(' · ');
        continue;
      }
      tableHeader = [];
      labels.addAll(_tag.allMatches(line).map((m) => m[1]!));
      final task = _task.firstMatch(line);
      if (task != null) {
        tasks++;
        if (task[1] == ' ') open++;
      }
      if (_list.hasMatch(line)) items++;
      if ((excerpt.isEmpty || statusLine.isEmpty) &&
          !line.startsWith('#') &&
          !line.startsWith('|') &&
          !line.contains('fs://')) {
        final clean = (task?[2] ?? line)
            .replaceFirst(_list, '')
            .replaceAll(RegExp(r'[*_`]'), '')
            .replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^)]+\)'), (m) => m[1]!)
            .trim();
        if (clean.contains(RegExp(r'[\p{L}\p{N}]', unicode: true))) {
          final preview = String.fromCharCodes(clean.runes.take(160));
          if (excerpt.isEmpty) excerpt = preview;
          if (statusLine.isEmpty &&
              RegExp(r'^(?:进度|進度|待确认|待確認|当前状态|下一步|status|next step|progress)\s*[:：]',
                      caseSensitive: false)
                  .hasMatch(clean)) {
            statusLine = preview;
          }
        }
      }
    }
    return LibraryDocument(
        path: path,
        title: title,
        excerpt: statusLine.isEmpty ? excerpt : statusLine,
        topics: labels,
        sources: sources,
        openTasks: open,
        totalTasks: tasks,
        items: items,
        modified: modified);
  }

  LibraryDocument withSourceTopics(
          Set<String> verified, Iterable<String> tags, int newest) =>
      LibraryDocument(
          path: path,
          title: title,
          excerpt: excerpt,
          topics: {...topics, ...tags},
          sources: verified,
          openTasks: openTasks,
          totalTasks: totalTasks,
          items: items,
          modified: newest > modified ? newest : modified);

  int get usefulness =>
      (totalTasks > 0 || items >= 2 ? 3 : 0) +
      (sources.length >= 2 ? 2 : 0) +
      (excerpt.isNotEmpty ? 1 : 0);

  static List<LibraryDocument> highlights(
      List<LibraryDocument> documents, List<String> pinned, List<String> hidden,
      {List<String> visits = const []}) {
    final oftenOpened = <String>{};
    final seen = <String>{};
    for (final path in visits) {
      if (!seen.add(path)) oftenOpened.add(path);
    }
    int scoreOf(LibraryDocument d) =>
        d.usefulness + (oftenOpened.contains(d.path) ? 3 : 0);
    final candidates = documents
        .where((d) =>
            !hidden.contains(d.path) &&
            (pinned.contains(d.path) ||
                (d.usefulness > 0 && !d.path.startsWith('Archives/'))))
        .toList();
    candidates.sort((a, b) {
      final ai = pinned.indexOf(a.path), bi = pinned.indexOf(b.path);
      if (ai != bi) {
        return (ai < 0 ? pinned.length : ai)
            .compareTo(bi < 0 ? pinned.length : bi);
      }
      final score = scoreOf(b).compareTo(scoreOf(a));
      if (score != 0) return score;
      final recent = b.modified.compareTo(a.modified);
      return recent != 0 ? recent : a.path.compareTo(b.path);
    });
    final selected = <LibraryDocument>[];
    for (final d in candidates) {
      if (!pinned.contains(d.path) &&
          selected.any((s) =>
              s.title == d.title ||
              (d.sources.isNotEmpty &&
                  d.sources.length == s.sources.length &&
                  s.sources.containsAll(d.sources)))) {
        continue;
      }
      selected.add(d);
      if (selected.length == 3) break;
    }
    return selected;
  }
}

/// A real directory surfaced on the home grid. Documents in nested folders
/// roll up to the first personal directory beneath a PARA root.
class LibraryFolder {
  LibraryFolder._(this.path, this.latest);

  final String path;
  String get name => p.posix.basename(path);
  LibraryDocument latest;
  int documentCount = 0;
  int _visits = 0;
  final _sources = <String>{};

  static String? _personalFolder(String directory) {
    final parts = p.posix.split(directory);
    if (parts.isEmpty) return null;
    final depth = LibraryDocument._roots.contains(parts.first) ? 2 : 1;
    if (directory == '.' || parts.length < depth) return null;
    return parts.take(depth).join('/');
  }

  static List<LibraryFolder> frequent(
      List<LibraryDocument> documents, List<String> visits) {
    final folders = <String, LibraryFolder>{};
    final documentFolders = <String, LibraryFolder>{};
    for (final doc in documents) {
      final path = _personalFolder(p.posix.dirname(doc.path));
      if (path == null) continue;
      final folder =
          folders.putIfAbsent(path, () => LibraryFolder._(path, doc));
      documentFolders[doc.path] = folder;
      folder.documentCount++;
      folder._sources.addAll(doc.sources);
      if (doc.modified > folder.latest.modified ||
          (doc.modified == folder.latest.modified &&
              doc.path.compareTo(folder.latest.path) < 0)) {
        folder.latest = doc;
      }
    }
    for (final visit in visits) {
      final folder = visit.endsWith('/')
          ? folders[_personalFolder(visit)]
          : documentFolders[visit];
      if (folder != null) folder._visits++;
    }
    final ranked = folders.values.toList()
      ..sort((a, b) {
        final comparisons = [
          b._visits.compareTo(a._visits),
          b._sources.length.compareTo(a._sources.length),
          b.documentCount.compareTo(a.documentCount),
          b.latest.modified.compareTo(a.latest.modified),
          a.path.compareTo(b.path),
        ];
        return comparisons.firstWhere((value) => value != 0, orElse: () => 0);
      });
    return ranked.take(4).toList();
  }
}
