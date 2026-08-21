import 'dart:convert';
import 'dart:io';

import 'package:memex/data/services/jsonl_file_store.dart';

enum JsonlConversationCommitPhase {
  pendingWritten,
  messagesAppended,
  metadataWritten,
}

typedef JsonlConversationCommitObserver = Future<void> Function(
  JsonlConversationCommitPhase phase,
);

/// Crash-recoverable commits spanning an append-only JSONL file and metadata.
///
/// The journal is deliberately schema-agnostic. Feature stores own message and
/// metadata validation while this service owns the physical write protocol.
/// Only one pending commit may exist because callers serialize access to a
/// conversation before invoking this service.
class JsonlConversationJournal {
  JsonlConversationJournal({
    JsonlFileStore? jsonl,
    JsonlConversationCommitObserver? observer,
  })  : _jsonl = jsonl ?? JsonlFileStore(),
        _observer = observer;

  static const int pendingSchemaVersion = 1;

  final JsonlFileStore _jsonl;
  final JsonlConversationCommitObserver? _observer;

  Future<void> commit({
    required File messagesFile,
    required File metadataFile,
    required File pendingFile,
    required int baseOffset,
    required List<Map<String, dynamic>> messages,
    required Map<String, dynamic> targetMetadata,
    bool truncateBeforeAppend = false,
  }) async {
    await writeJsonFile(pendingFile, {
      'journal_schema_version': pendingSchemaVersion,
      'base_offset': baseOffset,
      'messages': messages,
      'target_metadata': targetMetadata,
    });
    await _observer?.call(JsonlConversationCommitPhase.pendingWritten);

    if (truncateBeforeAppend) {
      await _truncate(messagesFile, baseOffset);
    } else {
      final currentLength =
          await messagesFile.exists() ? await messagesFile.length() : 0;
      if (currentLength != baseOffset) {
        await pendingFile.delete();
        throw StateError(
          'JSONL log changed while preparing a conversation commit.',
        );
      }
    }
    await _jsonl.append(messagesFile, messages);
    await _observer?.call(JsonlConversationCommitPhase.messagesAppended);

    await writeJsonFile(metadataFile, targetMetadata);
    await _observer?.call(JsonlConversationCommitPhase.metadataWritten);
    if (await pendingFile.exists()) await pendingFile.delete();
  }

  /// Completes a pending commit by replaying it from its original byte offset.
  ///
  /// Callers must validate [targetMetadata] before it replaces feature state.
  /// Replaying from [baseOffset] makes recovery correct whether no message,
  /// part of a batch, or the complete batch reached disk before interruption.
  Future<bool> recover({
    required File messagesFile,
    required File metadataFile,
    required File pendingFile,
    required bool Function(Map<String, dynamic> targetMetadata)
        validateMetadata,
  }) async {
    if (!await pendingFile.exists()) return false;
    final decoded = jsonDecode(await pendingFile.readAsString());
    if (decoded is! Map ||
        decoded['journal_schema_version'] != pendingSchemaVersion) {
      throw const FormatException('Invalid JSONL conversation commit.');
    }
    final baseOffset = decoded['base_offset'];
    final rawMessages = decoded['messages'];
    final rawMetadata = decoded['target_metadata'];
    if (baseOffset is! num ||
        baseOffset.toInt() < 0 ||
        rawMessages is! List ||
        rawMetadata is! Map) {
      throw const FormatException('Incomplete JSONL conversation commit.');
    }
    if (rawMessages.any((row) => row is! Map)) {
      throw const FormatException('Invalid JSONL conversation rows.');
    }
    final messages = rawMessages
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
    final targetMetadata = Map<String, dynamic>.from(rawMetadata);
    if (!validateMetadata(targetMetadata)) {
      throw const FormatException('Invalid pending conversation metadata.');
    }

    await messagesFile.parent.create(recursive: true);
    if (!await messagesFile.exists()) {
      await messagesFile.writeAsString('', flush: true);
    }
    final currentLength = await messagesFile.length();
    if (currentLength < baseOffset.toInt()) {
      throw StateError('JSONL log is shorter than its pending commit.');
    }
    await _truncate(messagesFile, baseOffset.toInt());
    await _jsonl.append(messagesFile, messages);
    await writeJsonFile(metadataFile, targetMetadata);
    await pendingFile.delete();
    return true;
  }

  Future<void> _truncate(File file, int length) async {
    await file.parent.create(recursive: true);
    if (!await file.exists()) await file.writeAsString('', flush: true);
    final handle = await file.open(mode: FileMode.append);
    try {
      await handle.truncate(length);
      await handle.flush();
    } finally {
      await handle.close();
    }
  }

  Future<void> writeJsonFile(
    File file,
    Map<String, dynamic> value,
  ) {
    const encoder = JsonEncoder.withIndent('  ');
    return replaceFile(file, '${encoder.convert(value)}\n');
  }

  Future<void> replaceFile(File file, String content) async {
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(content, encoding: utf8, flush: true);
    try {
      await temporary.rename(file.path);
    } on FileSystemException {
      if (await file.exists()) await file.delete();
      await temporary.rename(file.path);
    }
  }
}
