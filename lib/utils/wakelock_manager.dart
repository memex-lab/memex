import 'package:memex/utils/logger.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

final _log = getLogger('WakelockManager');

class WakelockManager {
  WakelockManager._();

  static final Set<String> _reasons = <String>{};

  static Future<void> acquire(String reason) async {
    final normalized = reason.trim();
    if (normalized.isEmpty) return;
    final wasEmpty = _reasons.isEmpty;
    _reasons.add(normalized);
    if (!wasEmpty) return;

    try {
      await WakelockPlus.enable();
      _log.fine('Wakelock enabled: $normalized');
    } catch (e) {
      _log.fine('Failed to enable wakelock: $e');
    }
  }

  static Future<void> release(String reason) async {
    final normalized = reason.trim();
    if (normalized.isEmpty) return;
    if (!_reasons.remove(normalized) || _reasons.isNotEmpty) return;

    try {
      await WakelockPlus.disable();
      _log.fine('Wakelock disabled');
    } catch (e) {
      _log.fine('Failed to disable wakelock: $e');
    }
  }
}
