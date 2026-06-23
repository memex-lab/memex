import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/api_exception.dart';

final _logger = getLogger('HealthEndpoint');
FileSystemService get _fileSystemService => FileSystemService.instance;

Future<bool> reportDailyHealthSummaryEndpoint(
    Map<String, Map<String, dynamic>> dailySummary) async {
  _logger.info('reportDailyHealthSummary called: ${dailySummary.length} days');

  try {
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      throw ApiException('User not logged in, cannot report health metrics');
    }

    final updatedDates = <String>[];

    for (final entry in dailySummary.entries) {
      final dateStr = entry.key;
      final healthData = entry.value;

      try {
        // Parse date
        final dateParts = dateStr.split('-');
        if (dateParts.length != 3) {
          _logger.warning('Invalid date format: $dateStr');
          continue;
        }

        final year = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final day = int.parse(dateParts[2]);
        final parsedDate = DateTime(year, month, day);
        if (parsedDate.year != year ||
            parsedDate.month != month ||
            parsedDate.day != day) {
          _logger.warning('Invalid date value: $dateStr');
          continue;
        }

        final yamlData = {
          'health': healthData,
          'health_updated_at': DateTime.now().toIso8601String(),
        };

        await _fileSystemService.updateDailyFactYamlData(
          userId,
          parsedDate,
          yamlData,
        );

        // Log event
        try {
          final monthStr = month.toString().padLeft(2, '0');
          final dayStr = day.toString().padLeft(2, '0');
          final factPath = 'Facts/$year/$monthStr/$dayStr.md';

          await _fileSystemService.eventLogService.logEvent(
            userId: userId,
            eventType: 'health_data_update',
            description: 'Updated comprehensive health summary',
            filePath: factPath,
            metadata: {
              'date': dateStr,
              'keys_updated': healthData.keys.toList(),
            },
          );
        } catch (e) {
          _logger.warning('Failed to log health update event: $e');
        }

        updatedDates.add(dateStr);
        _logger.info('Reported health for user $userId on $dateStr');
      } catch (e) {
        _logger.warning('Failed to report health for date $dateStr: $e');
        // Continue with other dates
      }
    }

    _logger.info('Reported health for ${updatedDates.length} days');
    if (dailySummary.isNotEmpty && updatedDates.isEmpty) {
      return false;
    }
    return true;
  } catch (e) {
    _logger.severe('Failed to report daily health summary locally: $e');
    return false;
  }
}
