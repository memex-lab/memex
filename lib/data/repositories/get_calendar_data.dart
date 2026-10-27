import 'package:path/path.dart' as path;
import 'package:memex/domain/models/calendar_model.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/services/file_system_service.dart';

final _logger = getLogger('GetCalendarDataEndpoint');

/// Get calendar data
/// Maps to backend GET /cards/calendar
Future<List<CalendarDay>> getCalendarData(
  int fromTimestamp,
  int toTimestamp, {
  Duration? utcOffset,
}) async {
  _logger.info(
    'getCalendarData called: fromTimestamp=$fromTimestamp, toTimestamp=$toTimestamp',
  );

  try {
    final userId = await UserStorage.getUserId();
    if (userId == null) {
      _logger.warning('No user ID found, returning empty calendar data');
      return [];
    }

    final fileSystemService = FileSystemService.instance;

    // Convert timestamps to the device's local calendar days. Card files and
    // the calendar UI both use local dates; UTC year/month/day drops cards
    // that fall on the previous UTC day (for example 02:00 in UTC+4).
    final startWall = _calendarWallClock(fromTimestamp, utcOffset: utcOffset);
    final endWall = _calendarWallClock(toTimestamp, utcOffset: utcOffset);
    final startDate = DateTime(startWall.year, startWall.month, startWall.day);
    final endDate = DateTime(endWall.year, endWall.month, endWall.day);

    // Use FileSystemService to find files in range
    final cardFiles = await fileSystemService.getCardFilesInDateRange(
      userId,
      startDate,
      endDate,
    );

    // Group data by date
    final dailyData = <int, List<CalendarCard>>{};

    // Init container per day (ensure empty list even when no cards)
    var currentDate = startDate;
    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      final ts = _calendarDayStartUnix(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        utcOffset: utcOffset,
      );
      dailyData[ts] = [];
      currentDate = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      ).add(const Duration(days: 1));
    }

    // Process card files
    for (final cardFile in cardFiles) {
      try {
        // Parse fact_id from path
        // Path format: Cards/YYYY/MM/DD_ts_X.yaml
        final parts = path.split(cardFile);
        if (parts.length < 3) {
          continue;
        }
        final year = parts[parts.length - 3];
        final month = parts[parts.length - 2];
        final dayTsFile = parts[parts.length - 1];
        final dayTs = dayTsFile.replaceAll('.yaml', '');
        final dayTsParts = dayTs.split('_');
        if (dayTsParts.length < 2) {
          continue;
        }
        final day = dayTsParts[0];
        final tsPart = dayTsParts.sublist(1).join('_');
        final factId = '$year/$month/$day.md#$tsPart';

        // Read card data
        final cardData = await fileSystemService.readCardFile(userId, factId);
        if (cardData == null) {
          continue;
        }

        if (cardData.deleted == true) {
          continue;
        }

        var ts = cardData.userFixedTimestamp ?? cardData.timestamp;

        // Assign to the local calendar day, matching CalendarViewModel.
        final cardWall = _calendarWallClock(ts, utcOffset: utcOffset);
        final dayStartTs = _calendarDayStartUnix(
          cardWall.year,
          cardWall.month,
          cardWall.day,
          utcOffset: utcOffset,
        );

        if (dailyData.containsKey(dayStartTs)) {
          final location =
              cardData.userFixedAddress ??
              cardData.userFixedLocation?.name ??
              cardData.address ??
              '';

          final calCard = CalendarCard(
            id: factId,
            timestamp: ts,
            title: cardData.title ?? 'Untitled',
            tags: List<String>.from(cardData.tags),
            location: location,
          );
          dailyData[dayStartTs]!.add(calCard);
        }
      } catch (e) {
        _logger.warning('Error processing card file $cardFile: $e');
        continue;
      }
    }

    // Build result list
    final result = <CalendarDay>[];

    // Sort by time
    final sortedDays = dailyData.keys.toList()..sort();

    for (final dayTs in sortedDays) {
      final cards = dailyData[dayTs]!;
      // Sort day's cards by time
      cards.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      result.add(
        CalendarDay(timestamp: dayTs, cards: cards, total: cards.length),
      );
    }

    return result;
  } catch (e) {
    _logger.severe('Failed to get calendar data: $e');
    return [];
  }
}

/// Wall-clock time for a unix timestamp. [utcOffset] is for tests; production
/// uses the device zone, including the offset that applied at that instant.
DateTime _calendarWallClock(int unixSeconds, {Duration? utcOffset}) {
  final utc = DateTime.fromMillisecondsSinceEpoch(
    unixSeconds * 1000,
    isUtc: true,
  );
  if (utcOffset == null) return utc.toLocal();
  return utc.add(utcOffset);
}

/// Unix seconds for local midnight of a civil date.
int _calendarDayStartUnix(int year, int month, int day, {Duration? utcOffset}) {
  if (utcOffset == null) {
    return DateTime(year, month, day).millisecondsSinceEpoch ~/ 1000;
  }
  return DateTime.utc(
        year,
        month,
        day,
      ).subtract(utcOffset).millisecondsSinceEpoch ~/
      1000;
}
