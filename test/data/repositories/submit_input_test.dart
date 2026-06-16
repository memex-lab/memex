import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/submit_input.dart';
import 'package:memex/data/services/agent_run_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_asset_server.dart';
import 'package:memex/data/services/location_context_service.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('submitInput', () {
    late Directory root;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await UserStorage.initL10n();
      root = await Directory.systemTemp.createTemp('memex_submit_input_');
      await FileSystemService.init(root.path);
      setSubmitInputAgentRunServiceForTesting(null);
      setSubmitInputLocationContextServiceForTesting(null);
    });

    tearDown(() async {
      setSubmitInputAgentRunServiceForTesting(null);
      setSubmitInputLocationContextServiceForTesting(null);
      await LocalAssetServer.stopServer();
      if (await root.exists()) {
        await root.delete(recursive: true);
      }
    });

    test('continues when durable agent run persistence fails', () async {
      final agentRunService = _ThrowingAgentRunService();
      setSubmitInputAgentRunServiceForTesting(agentRunService);

      final result = await submitInput('submit-input-user', [
        {'type': 'text', 'text': 'note survives run persistence failure'},
      ]);

      final factId = result['fact_id'] as String;
      final factPath = factId.split('#').first;
      final factFile = File(
        p.join(
          FileSystemService.instance.getFactsPath('submit-input-user'),
          factPath,
        ),
      );
      final cardFile = File(
        FileSystemService.instance.getCardPath('submit-input-user', factId),
      );

      expect(result['card'], isA<Map<String, dynamic>>());
      expect(await factFile.readAsString(), contains('note survives'));
      expect(cardFile.existsSync(), isTrue);
      expect(agentRunService.createCalls, 1);
      expect(agentRunService.refreshCalls, 1);
    });

    test('writes device GPS input_location to Fact header metadata', () async {
      final capturedAt = DateTime.utc(2026, 6, 16, 6, 22, 10);
      setSubmitInputLocationContextServiceForTesting(
        LocationContextService.forTesting(
          isLocationServiceEnabled: () async => true,
          checkPermission: () async => LocationPermission.whileInUse,
          getCurrentPosition: (_) async => _position(
            lat: 31.212345,
            lng: 121.456789,
            accuracy: 12.3,
            timestamp: capturedAt,
          ),
        ),
      );

      final result = await submitInput('submit-input-user', [
        {'type': 'text', 'text': 'finished the location metadata plan'},
      ]);

      final factId = result['fact_id'] as String;
      final factFile = _factFileFor('submit-input-user', factId);
      final factContent = await factFile.readAsString();
      final headerLine = factContent.split('\n').first;
      final headerMetadata =
          jsonDecode(headerLine.substring(headerLine.indexOf('{')))
              as Map<String, dynamic>;
      final inputLocation =
          headerMetadata['input_location'] as Map<String, dynamic>;

      expect(inputLocation['lat'], 31.212345);
      expect(inputLocation['lng'], 121.456789);
      expect(inputLocation['accuracy_meters'], 12.3);
      expect(inputLocation['source'], 'device_gps');
      expect(inputLocation['coordinate_system'], 'WGS84');
      expect(
        DateTime.parse(inputLocation['captured_at'] as String).toUtc(),
        capturedAt,
      );

      final extracted = await FileSystemService.instance
          .extractFactContentFromFile('submit-input-user', factId);
      final extractedLocation =
          extracted!.metadata['input_location'] as Map<String, dynamic>;
      expect(extractedLocation['source'], 'device_gps');
      expect(extractedLocation['lat'], 31.212345);
    });

    test('does not infer input_location from location-looking text', () async {
      setSubmitInputLocationContextServiceForTesting(
        LocationContextService.forTesting(
          isLocationServiceEnabled: () async => false,
        ),
      );

      final result = await submitInput('submit-input-user', [
        {'type': 'text', 'text': 'Lunch in Paris near 48.8566, 2.3522.'},
      ]);

      final factId = result['fact_id'] as String;
      final extracted = await FileSystemService.instance
          .extractFactContentFromFile('submit-input-user', factId);
      final factContent = await _factFileFor(
        'submit-input-user',
        factId,
      ).readAsString();
      final headerLine = factContent.split('\n').first;

      expect(extracted!.metadata, isNot(contains('input_location')));
      expect(extracted.content, contains('48.8566'));
      expect(headerLine, isNot(contains('input_location')));
    });

    test('parses old empty and missing Fact header metadata', () async {
      final fs = FileSystemService.instance;
      const userId = 'submit-input-user';
      final date = DateTime(2026, 6, 16);
      await fs.appendToDailyFactFile(
        userId,
        date,
        '## <id:ts_1> 09:00:00 "{}"\n\nold quoted empty\n'
        '## <id:ts_2> 10:00:00 {}\n\nold raw empty\n'
        '## <id:ts_3> 11:00:00\n\nold missing metadata\n'
        '## <id:ts_4> 12:00:00 {"input_location":{"lat":1.0,"lng":2.0,"accuracy_meters":3.0,"source":"device_gps","coordinate_system":"WGS84","captured_at":"2026-06-16T12:00:00+08:00"}}\n\nnew metadata\n',
      );

      final quoted = await fs.extractFactContentFromFile(
        userId,
        '2026/06/16.md#ts_1',
      );
      final raw = await fs.extractFactContentFromFile(
        userId,
        '2026/06/16.md#ts_2',
      );
      final missing = await fs.extractFactContentFromFile(
        userId,
        '2026/06/16.md#ts_3',
      );
      final withLocation = await fs.extractFactContentFromFile(
        userId,
        '2026/06/16.md#ts_4',
      );

      expect(quoted!.metadata, isEmpty);
      expect(raw!.metadata, isEmpty);
      expect(missing!.metadata, isEmpty);
      expect(quoted.content, 'old quoted empty');
      expect(raw.content, 'old raw empty');
      expect(missing.content, 'old missing metadata');
      expect(
        withLocation!.metadata['input_location'],
        containsPair('source', 'device_gps'),
      );
    });
  });
}

File _factFileFor(String userId, String factId) {
  final factPath = factId.split('#').first;
  return File(
    p.join(FileSystemService.instance.getFactsPath(userId), factPath),
  );
}

Position _position({
  required double lat,
  required double lng,
  required double accuracy,
  required DateTime timestamp,
}) {
  return Position(
    latitude: lat,
    longitude: lng,
    timestamp: timestamp,
    accuracy: accuracy,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
}

class _ThrowingAgentRunService extends AgentRunService {
  _ThrowingAgentRunService() : super.forTesting();

  int createCalls = 0;
  int refreshCalls = 0;

  @override
  bool get isAvailable => true;

  @override
  Future<void> createForSubmittedInput({
    required String userId,
    required String factId,
  }) async {
    createCalls++;
    throw StateError('create failed');
  }

  @override
  Future<void> refreshRunFromTasks(String runId) async {
    refreshCalls++;
    throw StateError('refresh failed');
  }
}
