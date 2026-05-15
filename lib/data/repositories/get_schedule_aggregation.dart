import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/schedule_aggregation_model.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';

final _logger = getLogger('GetScheduleAggregation');

/// Get the latest schedule aggregation for the current user
Future<ScheduleAggregationModel?> getScheduleAggregation() async {
  try {
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      _logger.warning('No user ID found, cannot get schedule aggregation');
      return null;
    }

    final fileSystem = FileSystemService.instance;
    final latest = await fileSystem.getLatestScheduleAggregation(userId);
    if (latest == null) {
      _logger.info('No schedule aggregation found for user $userId');
      return null;
    }

    return ScheduleAggregationModel.fromYaml(latest);
  } catch (e) {
    _logger.severe('Failed to get schedule aggregation: $e');
    return null;
  }
}

/// Check if schedule aggregation needs refresh (older than given duration)
Future<bool> scheduleAggregationNeedsRefresh({Duration? maxAge}) async {
  try {
    final userId = await UserStorage.getUserId();
    if (userId == null) return true;

    final fileSystem = FileSystemService.instance;
    final latest = await fileSystem.getLatestScheduleAggregation(userId);
    if (latest == null) return true;

    final generatedAt = DateTime.tryParse(latest['generated_at'] ?? '');
    if (generatedAt == null) return true;

    final age = DateTime.now().difference(generatedAt);
    return age > (maxAge ?? const Duration(minutes: 30));
  } catch (e) {
    _logger.warning('Failed to check schedule aggregation freshness: $e');
    return true;
  }
}
