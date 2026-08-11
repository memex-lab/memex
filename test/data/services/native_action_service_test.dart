import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/native_action_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.memexlab.memex/system_actions');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('forwards calendar events to the native system action channel',
      () async {
    MethodCall? received;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      received = call;
      return true;
    });
    final start = DateTime(2026, 8, 1, 15, 30);
    final end = DateTime(2026, 8, 1, 16, 30);

    final success = await NativeActionService.addCalendarEvent(
      title: 'Team review',
      startTime: start,
      endTime: end,
      location: 'Meeting room A',
      notes: 'Bring the launch plan',
    );

    expect(success, isTrue);
    expect(received!.method, 'addCalendarEvent');
    expect(received!.arguments, {
      'title': 'Team review',
      'startTime': start.millisecondsSinceEpoch,
      'endTime': end.millisecondsSinceEpoch,
      'location': 'Meeting room A',
      'notes': 'Bring the launch plan',
    });
  });

  test('forwards reminders to the native system action channel', () async {
    MethodCall? received;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      received = call;
      return true;
    });
    final due = DateTime(2026, 8, 2, 9);

    final success = await NativeActionService.addReminder(
      title: 'Call the dentist',
      dueDate: due,
      notes: 'Ask about the next checkup',
    );

    expect(success, isTrue);
    expect(received!.method, 'addReminder');
    expect(received!.arguments, {
      'title': 'Call the dentist',
      'dueDate': due.millisecondsSinceEpoch,
      'notes': 'Ask about the next checkup',
    });
  });

  test('reports native channel failures without throwing', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: 'PERMISSION_DENIED');
    });

    final success = await NativeActionService.addReminder(
      title: 'Call the dentist',
      dueDate: DateTime(2026, 8, 2, 9),
    );

    expect(success, isFalse);
  });
}
