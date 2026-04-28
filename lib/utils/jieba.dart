import 'dart:async';
import 'dart:math' show log;
import 'package:flutter/services.dart' show rootBundle;
import 'package:logging/logging.dart';
import 'package:memex/utils/logger.dart';

// ---------------------------------------------------------------------------
// Trie node for the prefix dictionary
// ---------------------------------------------------------------------------

class _TrieNode {
  final Map<int, _TrieNode> children = {};
  int freq = 0; // >0 means this node is a complete word
}

/// Pure-Dart port of jieba Chinese word segmentation (no-HMM mode).
///
/// Ported from https://github.com/fxsjy/jieba (MIT license).
///
/// Memory management: the Trie dictionary (~15-25 MB) is loaded lazily on
/// first use and automatically released after [_idleTimeout] of inactivity.
/// Subsequent calls re-load it transparently.
///
/// Callers must `await ensureLoaded()` before calling [cut] or [cutForSearch].
class JiebaSegmenter {
  JiebaSegmenter._();
  static final JiebaSegmenter instance = JiebaSegmenter._();

  final Logger _logger = getLogger('JiebaSegmenter');

  static const _idleTimeout = Duration(minutes: 5);

  _TrieNode? _root;
  int _total = 0;
  double _logTotal = 0;
  Timer? _releaseTimer;

  /// Whether the dictionary is currently loaded in memory.
  bool get isLoaded => _root != null;

  static final RegExp _reHan = RegExp(r'([\u4E00-\u9FD5a-zA-Z0-9+#&._%-]+)');
  static final RegExp _reSkip = RegExp(r'(\r\n|\s)');
  static final RegExp _reEng = RegExp(r'[a-zA-Z0-9]');

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Load the dictionary if not already loaded. Resets the idle-release timer.
  Future<bool> ensureLoaded() async {
    _touchTimer();
    if (_root != null) return true;
    try {
      final raw = await rootBundle.loadString('assets/jieba_dict.txt');
      _buildTrie(raw);
      _logger.info('Jieba dictionary loaded: total freq=$_total');
      return true;
    } catch (e) {
      _logger.severe('Failed to load jieba dictionary: $e');
      return false;
    }
  }

  void _touchTimer() {
    _releaseTimer?.cancel();
    _releaseTimer = Timer(_idleTimeout, _release);
  }

  void _release() {
    if (_root == null) return;
    _root = null;
    _total = 0;
    _logTotal = 0;
    _releaseTimer?.cancel();
    _releaseTimer = null;
    _logger.info('Jieba dictionary released (idle timeout)');
  }

  /// Force release (e.g. on logout).
  void dispose() => _release();

  // ---------------------------------------------------------------------------
  // Trie construction
  // ---------------------------------------------------------------------------

  void _buildTrie(String raw) {
    final root = _TrieNode();
    int total = 0;
    for (final line in raw.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final parts = trimmed.split(' ');
      if (parts.length < 2) continue;
      final word = parts[0];
      final freq = int.tryParse(parts[1]) ?? 0;
      var node = root;
      for (int i = 0; i < word.length; i++) {
        node = node.children.putIfAbsent(word.codeUnitAt(i), () => _TrieNode());
      }
      node.freq = freq;
      total += freq;
    }
    _root = root;
    _total = total;
    _logTotal = log(total);
  }

  int _getFreq(String word) {
    var node = _root;
    if (node == null) return 0;
    for (int i = 0; i < word.length; i++) {
      final child = node!.children[word.codeUnitAt(i)];
      if (child == null) return 0;
      node = child;
    }
    return node!.freq;
  }

  // ---------------------------------------------------------------------------
  // DAG + DP
  // ---------------------------------------------------------------------------

  Map<int, List<int>> _getDAG(String sentence) {
    final root = _root!;
    final dag = <int, List<int>>{};
    final n = sentence.length;
    for (int k = 0; k < n; k++) {
      final tmpList = <int>[];
      var node = root;
      for (int i = k; i < n; i++) {
        final child = node.children[sentence.codeUnitAt(i)];
        if (child == null) break;
        if (child.freq > 0) tmpList.add(i);
        node = child;
      }
      if (tmpList.isEmpty) tmpList.add(k);
      dag[k] = tmpList;
    }
    return dag;
  }

  Map<int, List<double>> _calc(String sentence, Map<int, List<int>> dag) {
    final n = sentence.length;
    final route = <int, List<double>>{};
    route[n] = [0.0, 0.0];
    for (int idx = n - 1; idx >= 0; idx--) {
      double bestProb = -1e308;
      double bestX = idx.toDouble();
      for (final x in dag[idx]!) {
        final word = sentence.substring(idx, x + 1);
        final freq = _getFreq(word);
        final prob = log(freq > 0 ? freq : 1) - _logTotal + route[x + 1]![0];
        if (prob > bestProb) {
          bestProb = prob;
          bestX = x.toDouble();
        }
      }
      route[idx] = [bestProb, bestX];
    }
    return route;
  }

  // ---------------------------------------------------------------------------
  // Internal: segment a single Chinese+ASCII block
  // ---------------------------------------------------------------------------

  List<String> _cutBlock(String sentence) {
    final dag = _getDAG(sentence);
    final route = _calc(sentence, dag);
    final result = <String>[];
    int x = 0;
    final n = sentence.length;
    final buf = StringBuffer();
    while (x < n) {
      final y = route[x]![1].toInt() + 1;
      final word = sentence.substring(x, y);
      if (_reEng.hasMatch(word) && word.length == 1) {
        buf.write(word);
        x = y;
      } else {
        if (buf.isNotEmpty) {
          result.add(buf.toString());
          buf.clear();
        }
        result.add(word);
        x = y;
      }
    }
    if (buf.isNotEmpty) result.add(buf.toString());
    return result;
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Segment [sentence] into words.
  ///
  /// Requires [ensureLoaded] to have been called first. If the dictionary is
  /// not loaded, returns [sentence] as a single-element list.
  List<String> cut(String sentence) {
    if (sentence.isEmpty || _root == null) return [sentence];
    _touchTimer();
    final result = <String>[];
    for (final blk in _splitBlocks(sentence)) {
      if (blk.isEmpty) continue;
      if (_reHan.hasMatch(blk) && _reHan.firstMatch(blk)!.group(0) == blk) {
        result.addAll(_cutBlock(blk));
      } else {
        int last = 0;
        for (final m in _reSkip.allMatches(blk)) {
          if (m.start > last) {
            for (int i = last; i < m.start; i++) {
              result.add(blk[i]);
            }
          }
          result.add(m.group(0)!);
          last = m.end;
        }
        if (last < blk.length) {
          for (int i = last; i < blk.length; i++) {
            result.add(blk[i]);
          }
        }
      }
    }
    return result;
  }

  /// Finer segmentation for search engines.
  ///
  /// Emits sub-word bigrams/trigrams that exist in the dictionary before
  /// the full word, improving recall for sub-word queries.
  ///
  /// Requires [ensureLoaded] to have been called first.
  List<String> cutForSearch(String sentence) {
    if (sentence.isEmpty || _root == null) return [sentence];
    _touchTimer();
    final words = cut(sentence);
    final result = <String>[];
    for (final w in words) {
      if (w.length > 2) {
        for (int i = 0; i <= w.length - 2; i++) {
          final gram2 = w.substring(i, i + 2);
          if (_getFreq(gram2) > 0) result.add(gram2);
        }
      }
      if (w.length > 3) {
        for (int i = 0; i <= w.length - 3; i++) {
          final gram3 = w.substring(i, i + 3);
          if (_getFreq(gram3) > 0) result.add(gram3);
        }
      }
      result.add(w);
    }
    return result;
  }

  List<String> _splitBlocks(String text) {
    final blocks = <String>[];
    int last = 0;
    for (final m in _reHan.allMatches(text)) {
      if (m.start > last) blocks.add(text.substring(last, m.start));
      blocks.add(m.group(0)!);
      last = m.end;
    }
    if (last < text.length) blocks.add(text.substring(last));
    return blocks;
  }
}
