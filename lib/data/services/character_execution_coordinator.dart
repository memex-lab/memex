import 'package:synchronized/synchronized.dart';

/// Serializes every scene that can read or mutate one character's continuity.
///
/// The task queue orders persistent work by type. This coordinator gives
/// perception, comments, initiative, and chat a shared per-character execution
/// boundary across task types inside the app process.
class CharacterExecutionCoordinator {
  CharacterExecutionCoordinator();

  static final CharacterExecutionCoordinator instance =
      CharacterExecutionCoordinator();

  final Map<String, Lock> _locks = <String, Lock>{};

  Future<T> run<T>({
    required String userId,
    required String characterId,
    required Future<T> Function() action,
  }) {
    final key = '$userId:$characterId';
    final lock = _locks.putIfAbsent(key, Lock.new);
    return lock.synchronized(action);
  }
}
