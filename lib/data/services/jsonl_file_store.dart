import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:logging/logging.dart';
import 'package:memex/utils/logger.dart';

/// Low-level primitives for append-only JSONL stores.
///
/// Writers always append complete UTF-8 lines. Readers tolerate a process
/// dying during the final append by truncating only the unterminated tail.
/// Higher-level stores remain responsible for schema validation and locking.
class JsonlFileStore {
  JsonlFileStore({String loggerName = 'JsonlFileStore'})
      : _logger = getLogger(loggerName);

  final Logger _logger;

  Future<JsonlAppendResult> append(
    File file,
    List<Map<String, dynamic>> objects,
  ) async {
    if (objects.isEmpty) {
      final length = await file.exists() ? await file.length() : 0;
      return JsonlAppendResult(startOffset: length, endOffset: length);
    }
    await file.parent.create(recursive: true);
    final startOffset = await file.exists() ? await file.length() : 0;
    final bytes = utf8.encode('${objects.map(jsonEncode).join('\n')}\n');
    await file.writeAsBytes(bytes, mode: FileMode.append, flush: true);
    return JsonlAppendResult(
      startOffset: startOffset,
      endOffset: startOffset + bytes.length,
    );
  }

  Future<List<Map<String, dynamic>>> readAllRecoveringTail(File file) async {
    if (!await file.exists()) return const [];
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return const [];

    final result = <Map<String, dynamic>>[];
    var lineStart = 0;
    var lastValidOffset = 0;

    Future<void> decodeLine(int lineEnd, {required bool terminated}) async {
      final endOffset = terminated ? lineEnd + 1 : lineEnd;
      try {
        final text = utf8.decode(bytes.sublist(lineStart, lineEnd));
        if (text.trim().isEmpty) {
          lastValidOffset = endOffset;
          return;
        }
        final decoded = jsonDecode(text);
        if (decoded is! Map) {
          throw const FormatException('JSONL row is not an object');
        }
        result.add(Map<String, dynamic>.from(decoded));
        lastValidOffset = endOffset;
      } catch (error) {
        if (!terminated) {
          _logger.warning('Truncating incomplete JSONL tail in ${file.path}');
          await file.writeAsBytes(
            bytes.sublist(0, lastValidOffset),
            flush: true,
          );
          return;
        }
        _logger.warning('Skipping malformed JSONL row in ${file.path}: $error');
        lastValidOffset = endOffset;
      }
    }

    for (var index = 0; index < bytes.length; index++) {
      if (bytes[index] != 0x0A) continue;
      await decodeLine(index, terminated: true);
      lineStart = index + 1;
    }
    if (lineStart < bytes.length) {
      await decodeLine(bytes.length, terminated: false);
    }
    return result;
  }

  /// Reads the committed JSON object beginning at [startOffset].
  ///
  /// This is intended for small derived indexes that point into the JSONL
  /// file. The row remains authoritative: a stale or invalid pointer returns
  /// `null` instead of supplying a second copy of the object.
  Future<Map<String, dynamic>?> readObjectAt(
    File file,
    int startOffset,
  ) async {
    if (startOffset < 0 || !await file.exists()) return null;
    final length = await file.length();
    if (startOffset >= length) return null;

    final handle = await file.open();
    final bytes = <int>[];
    var terminated = false;
    try {
      await handle.setPosition(startOffset);
      while (startOffset + bytes.length < length) {
        final chunk = await handle.read(
          math.min(8192, length - startOffset - bytes.length),
        );
        if (chunk.isEmpty) break;
        final newline = chunk.indexOf(0x0A);
        if (newline >= 0) {
          bytes.addAll(chunk.sublist(0, newline));
          terminated = true;
          break;
        }
        bytes.addAll(chunk);
      }
    } finally {
      await handle.close();
    }
    return terminated ? _decodeObject(bytes) : null;
  }

  /// Finds the last committed row matching [predicate].
  ///
  /// This scans the file and is reserved for recovery after a process dies
  /// between appending a row and updating its derived index.
  Future<JsonlLocatedObject?> findLastObject(
    File file,
    bool Function(Map<String, dynamic> object) predicate,
  ) async {
    if (!await file.exists()) return null;
    final bytes = await file.readAsBytes();
    JsonlLocatedObject? match;
    var lineStart = 0;
    for (var index = 0; index < bytes.length; index++) {
      if (bytes[index] != 0x0A) continue;
      final object = _decodeObject(bytes.sublist(lineStart, index));
      if (object != null && predicate(object)) {
        match = JsonlLocatedObject(
          startOffset: lineStart,
          value: object,
        );
      }
      lineStart = index + 1;
    }
    return match;
  }

  Map<String, dynamic>? _decodeObject(List<int> bytes) {
    if (bytes.isEmpty) return null;
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  /// Reads at most [limit] JSONL rows backwards from [beforeOffset].
  ///
  /// The cursor is a UTF-8 byte offset and therefore remains independent of
  /// Dart string length and multi-byte characters.
  Future<JsonlPage> readPageBefore(
    File file, {
    required int limit,
    int? beforeOffset,
  }) async {
    if (limit <= 0 || !await file.exists()) return JsonlPage.empty;
    final length = await file.length();
    var endExclusive = beforeOffset == null
        ? length
        : math.max(0, math.min(length, beforeOffset));
    if (endExclusive == 0) return JsonlPage.empty;

    const chunkSize = 8192;
    final chunks = <List<int>>[];
    var position = endExclusive;
    var bufferStart = endExclusive;
    final handle = await file.open();
    try {
      while (position > 0) {
        final readSize = math.min(chunkSize, position);
        position -= readSize;
        bufferStart = position;
        await handle.setPosition(position);
        chunks.insert(0, await handle.read(readSize));

        final bytes = chunks.expand((chunk) => chunk).toList(growable: false);
        var localStart = 0;
        if (bufferStart > 0) {
          final newline = bytes.indexOf(0x0A);
          if (newline < 0) continue;
          localStart = newline + 1;
        }
        final lines = _decodeCompleteLines(
          bytes.sublist(localStart),
          absoluteStart: bufferStart + localStart,
          reachesFileEnd: endExclusive == length,
        );
        if (lines.length <= limit && bufferStart > 0) continue;

        final selected =
            lines.length <= limit ? lines : lines.sublist(lines.length - limit);
        return JsonlPage(
          rows: selected.map((line) => line.value).toList(growable: false),
          olderOffset: selected.isEmpty || selected.first.startOffset == 0
              ? null
              : selected.first.startOffset,
        );
      }
    } finally {
      await handle.close();
    }
    return JsonlPage.empty;
  }

  List<_DecodedLine> _decodeCompleteLines(
    List<int> bytes, {
    required int absoluteStart,
    required bool reachesFileEnd,
  }) {
    final result = <_DecodedLine>[];
    var start = 0;
    for (var index = 0; index < bytes.length; index++) {
      if (bytes[index] != 0x0A) continue;
      _decodePageLine(result, bytes, start, index, absoluteStart);
      start = index + 1;
    }
    // Writers terminate every committed row with a newline. Ignore an
    // incomplete final row here; readAllRecoveringTail owns physical repair.
    if (!reachesFileEnd && start < bytes.length) {
      _decodePageLine(result, bytes, start, bytes.length, absoluteStart);
    }
    return result;
  }

  void _decodePageLine(
    List<_DecodedLine> output,
    List<int> bytes,
    int start,
    int end,
    int absoluteStart,
  ) {
    if (end <= start) return;
    try {
      final decoded = jsonDecode(utf8.decode(bytes.sublist(start, end)));
      if (decoded is Map) {
        output.add(
          _DecodedLine(
            startOffset: absoluteStart + start,
            value: Map<String, dynamic>.from(decoded),
          ),
        );
      }
    } catch (error) {
      _logger.warning('Skipping malformed JSONL page row: $error');
    }
  }
}

class JsonlAppendResult {
  const JsonlAppendResult({
    required this.startOffset,
    required this.endOffset,
  });

  final int startOffset;
  final int endOffset;
}

class JsonlPage {
  const JsonlPage({required this.rows, required this.olderOffset});

  static const empty = JsonlPage(rows: [], olderOffset: null);

  final List<Map<String, dynamic>> rows;
  final int? olderOffset;
}

class JsonlLocatedObject {
  const JsonlLocatedObject({required this.startOffset, required this.value});

  final int startOffset;
  final Map<String, dynamic> value;
}

class _DecodedLine {
  const _DecodedLine({required this.startOffset, required this.value});

  final int startOffset;
  final Map<String, dynamic> value;
}
