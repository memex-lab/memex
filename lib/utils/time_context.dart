import 'package:intl/intl.dart';

DateTime? tryParseUnixSeconds(dynamic value) {
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch((value * 1000).round());
  }
  return null;
}

DateTime dateTimeFromUnixSeconds(dynamic value, {DateTime? fallback}) {
  return tryParseUnixSeconds(value) ?? fallback ?? DateTime.now();
}

String formatTimeZoneOffset(Duration offset) {
  final sign = offset.isNegative ? '-' : '+';
  final absolute = offset.abs();
  final hours = absolute.inHours.toString().padLeft(2, '0');
  final minutes = (absolute.inMinutes % 60).toString().padLeft(2, '0');
  return '$sign$hours:$minutes';
}

String formatLocalDateTimeWithZone(DateTime dateTime) {
  final local = dateTime.toLocal();
  final formatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(local);
  return '$formatted ${formatTimeZoneOffset(local.timeZoneOffset)} '
      '(${local.timeZoneName})';
}

String buildCurrentTimeReminder(DateTime dateTime) {
  return '<system-reminder>\n'
      'Current Local Time: ${formatLocalDateTimeWithZone(dateTime)}\n'
      '</system-reminder>\n\n';
}

String buildMessageTimePrefix(DateTime dateTime) {
  return '<message_time>${formatLocalDateTimeWithZone(dateTime)}</message_time>\n';
}
