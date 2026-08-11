import 'package:flutter/foundation.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/domain/models/character_history.dart';
import 'package:memex/domain/models/character_model.dart';

class CharacterHistoryAcquaintanceService {
  CharacterHistoryAcquaintanceService._({
    FileSystemService? fileSystem,
    required CharacterWorkspaceService workspaceService,
    required LocalTaskExecutor taskExecutor,
  })  : _injectedFileSystem = fileSystem,
        _workspaceService = workspaceService,
        _taskExecutor = taskExecutor;

  static final CharacterHistoryAcquaintanceService instance =
      CharacterHistoryAcquaintanceService._(
    workspaceService: CharacterWorkspaceService.instance,
    taskExecutor: LocalTaskExecutor.instance,
  );

  @visibleForTesting
  factory CharacterHistoryAcquaintanceService.forTesting({
    required FileSystemService fileSystem,
    required CharacterWorkspaceService workspaceService,
    required LocalTaskExecutor taskExecutor,
  }) {
    return CharacterHistoryAcquaintanceService._(
      fileSystem: fileSystem,
      workspaceService: workspaceService,
      taskExecutor: taskExecutor,
    );
  }

  static const taskType = 'character_history_acquaintance_task';

  static String taskBizId(String characterId) =>
      'character_history_acquaintance:$characterId';

  final FileSystemService? _injectedFileSystem;
  final CharacterWorkspaceService _workspaceService;
  final LocalTaskExecutor _taskExecutor;

  FileSystemService get _fileSystem =>
      _injectedFileSystem ?? FileSystemService.instance;

  Future<bool> ensureScheduled({
    required String userId,
    required CharacterModel character,
  }) async {
    await _workspaceService.ensureInitialized(userId, character);
    if (await _workspaceService.isHistoryAcquaintanceComplete(
      userId,
      character.id,
    )) {
      return false;
    }

    final bizId = taskBizId(character.id);
    if (await _taskExecutor.hasActiveTask(taskType: taskType, bizId: bizId)) {
      return false;
    }
    await _taskExecutor.enqueueTask(
      userId: userId,
      taskType: taskType,
      payload: {'character_id': character.id},
      bizId: bizId,
      priority: 10,
      maxRetries: 3,
    );
    return true;
  }

  Future<CharacterHistoryPage> browseMoments({
    required String userId,
    required int page,
    required int pageSize,
  }) async {
    if (page < 1) throw ArgumentError.value(page, 'page');
    if (pageSize < 1 || pageSize > 30) {
      throw ArgumentError.value(pageSize, 'pageSize');
    }
    final files = await _fileSystem.listAllCardFiles(userId);
    final start = (page - 1) * pageSize;
    if (start >= files.length) {
      return CharacterHistoryPage(
        page: page,
        pageSize: pageSize,
        total: files.length,
        moments: const [],
      );
    }

    final moments = <CharacterHistoryMoment>[];
    for (final file in files.skip(start).take(pageSize)) {
      final factId = _fileSystem.factIdFromCardPath(file);
      if (factId == null) continue;
      final card = await _fileSystem.readCardFile(userId, factId);
      if (card == null || card.deleted == true || _contentOf(card).isEmpty) {
        continue;
      }
      moments.add(_toMoment(card));
    }
    return CharacterHistoryPage(
      page: page,
      pageSize: pageSize,
      total: files.length,
      moments: moments,
    );
  }

  Future<List<CharacterHistoryMoment>> searchMoments({
    required String userId,
    required String query,
    int limit = 12,
  }) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return const [];
    if (limit < 1 || limit > 30) throw ArgumentError.value(limit, 'limit');

    final results = <CharacterHistoryMoment>[];
    for (final file in await _fileSystem.listAllCardFiles(userId)) {
      final factId = _fileSystem.factIdFromCardPath(file);
      if (factId == null) continue;
      final card = await _fileSystem.readCardFile(userId, factId);
      if (card == null || card.deleted == true) continue;
      final searchable = [
        card.title ?? '',
        _contentOf(card),
        card.address ?? '',
        ...card.tags,
      ].join('\n').toLowerCase();
      if (searchable.contains(normalized)) {
        results.add(_toMoment(card));
        if (results.length >= limit) break;
      }
    }
    return results;
  }

  Future<CharacterHistoryMoment?> readMoment({
    required String userId,
    required String factId,
  }) async {
    final card = await _fileSystem.readCardFile(userId, factId);
    if (card == null || card.deleted == true || _contentOf(card).isEmpty) {
      return null;
    }
    return _toMoment(card);
  }

  CharacterHistoryMoment _toMoment(CardData card) {
    return CharacterHistoryMoment(
      factId: card.factId,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        card.timestamp * 1000,
        isUtc: true,
      ).toLocal(),
      title: card.title,
      content: _contentOf(card),
      tags: card.tags,
      address: card.address,
    );
  }

  String _contentOf(CardData card) {
    final fact = card.fact?.trim() ?? '';
    if (fact.isNotEmpty) return fact;
    return card.insight?.summary?.trim() ?? '';
  }
}
