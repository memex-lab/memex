import 'package:flutter/foundation.dart';

import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/utils/result.dart';

const List<String> pkmParaRootPaths = [
  'Projects',
  'Areas',
  'Resources',
  'Archives',
];

const Set<String> _pkmParaRootPathSet = {
  'Projects',
  'Areas',
  'Resources',
  'Archives',
};

List<Map<String, dynamic>> additionalRootFoldersFromListing(
  Map<String, dynamic> rootListing,
) {
  final items = rootListing['items'] as List<dynamic>? ?? const [];
  final folders = <Map<String, dynamic>>[];

  for (final item in items) {
    if (item is! Map<String, dynamic>) continue;
    if (item['is_directory'] != true) continue;

    final path = (item['path'] ?? item['name'])?.toString().trim() ?? '';
    if (path.isEmpty || _pkmParaRootPathSet.contains(path)) continue;

    folders.add(Map<String, dynamic>.from(item)..['path'] = path);
  }

  folders.sort((a, b) {
    final aName = (a['name'] ?? a['path'] ?? '').toString().toLowerCase();
    final bName = (b['name'] ?? b['path'] ?? '').toString().toLowerCase();
    return aName.compareTo(bName);
  });
  return folders;
}

List<Map<String, dynamic>> rootFilesFromListing(
  Map<String, dynamic> rootListing,
) {
  final items = rootListing['items'] as List<dynamic>? ?? const [];
  final files = <Map<String, dynamic>>[];

  for (final item in items) {
    if (item is! Map<String, dynamic>) continue;
    if (item['is_directory'] == true) continue;

    final path = (item['path'] ?? item['name'])?.toString().trim() ?? '';
    if (path.isEmpty) continue;

    files.add(Map<String, dynamic>.from(item)..['path'] = path);
  }

  files.sort((a, b) {
    final aName = (a['name'] ?? a['path'] ?? '').toString().toLowerCase();
    final bName = (b['name'] ?? b['path'] ?? '').toString().toLowerCase();
    return aName.compareTo(bName);
  });
  return files;
}

/// ViewModel for the Knowledge base page. Holds recent files, category counts.
class KnowledgeBaseViewModel extends ChangeNotifier {
  KnowledgeBaseViewModel({required MemexRouter router}) : _router = router;

  final MemexRouter _router;

  bool isLoading = false;
  List<Map<String, dynamic>> recentFiles = [];
  List<Map<String, dynamic>> additionalRootFolders = [];
  List<Map<String, dynamic>> rootLevelFiles = [];
  Map<String, int> categoryCounts = {};

  int countItems(String category) => categoryCounts[category] ?? 0;

  Future<void> fetchData() async {
    isLoading = true;
    notifyListeners();
    final listResult = await _router.listPkmDirectory();
    final rootListing = listResult.when(
      onOk: (data) => data,
      onError: (_, __) => <String, dynamic>{},
    );
    additionalRootFolders = additionalRootFoldersFromListing(rootListing);
    rootLevelFiles = rootFilesFromListing(rootListing);

    final countPaths = [
      ...pkmParaRootPaths,
      ...additionalRootFolders.map((folder) => folder['path'] as String),
    ];
    final countResult = await _router.countPkmItems(countPaths);
    categoryCounts =
        countResult.when(onOk: (c) => c, onError: (_, __) => <String, int>{});
    for (final folder in additionalRootFolders) {
      final path = folder['path'] as String;
      folder['item_count'] = categoryCounts[path] ?? 0;
    }
    final recentResult = await _router.getRecentPkmFiles();
    recentFiles = recentResult.when(
        onOk: (r) => r, onError: (_, __) => <Map<String, dynamic>>[]);
    isLoading = false;
    notifyListeners();
  }
}
