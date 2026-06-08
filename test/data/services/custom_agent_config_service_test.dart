import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/custom_agent_config_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/data/services/local_asset_server.dart';
import 'package:memex/domain/models/custom_agent_config.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:memex/utils/time_context.dart';

void main() {
  late Directory tempDir;
  const userId = 'custom_agent_user';

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('memex_surface_agent_');
    await FileSystemService.init(tempDir.path);
  });

  tearDown(() async {
    await LocalAssetServer.stopServer();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('ordinary custom agent with empty event type has no subscription',
      () async {
    const config = CustomAgentConfig(
      agentName: 'ordinary-agent',
      skillDirectoryPath: '_UserSettings/skills/ordinary-agent',
      eventType: '',
    );

    await CustomAgentConfigService.instance.saveAndReload(userId, config);

    final subscriptionIds = GlobalEventBus.instance.getAsyncSubscriptionIds();
    expect(
      subscriptionIds.any((id) => id.startsWith('custom_agent:ordinary-agent')),
      isFalse,
    );
  });

  test('serializes data_changed records into event XML', () {
    final createdAt = DateTime.parse('2026-06-03T20:10:00+08:00');
    final xml = defaultEventToXml(
      SystemEvent<DataChangeRecord>(
        type: SystemEventTypes.dataChanged,
        source: 'test',
        eventId: 'evt1',
        createdAt: createdAt,
        payload: DataChangeRecord(
          op: DataChangeOp.update,
          ns: DataChangeNs.pkmFile,
          documentKey: 'Projects/Launch.md',
          after: const {
            'file_name': 'Launch.md',
            'content': 'Launch Plan blocked by legal review.',
          },
        ),
      ),
    );

    expect(
      xml,
      contains(
        '<created_at>${formatLocalDateTimeWithZone(createdAt)}</created_at>',
      ),
    );
    expect(xml, contains('<op>update</op>'));
    expect(xml, contains('<ns>pkm_file</ns>'));
    expect(xml, contains('<document_key>Projects/Launch.md</document_key>'));
    expect(xml, contains('legal review'));
  });
}
