import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/custom_agent_config_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/data/services/local_asset_server.dart';
import 'package:memex/domain/models/custom_agent_config.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:memex/utils/time_context.dart';
import 'package:path/path.dart' as path;

void main() {
  late Directory tempDir;
  const userId = 'surface_agent_user';

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

  test('installs a custom page agent config for a dynamic surface', () async {
    final config =
        await CustomAgentConfigService.instance.installDynamicSurfacePageAgent(
      userId: userId,
      surfaceId: 'project_board',
      displayName: 'Project Board',
    );

    expect(config.agentName, 'surface-project-board');
    expect(config.hostAgentType, HostAgentType.memex);
    expect(config.eventType, SystemEventTypes.userInputSubmitted);
    expect(config.managedSurfaceId, 'project_board');
    expect(config.skillDirectoryPath, '');

    final loaded = await CustomAgentConfigService.instance.loadAll(userId);
    expect(loaded.map((item) => item.agentName), contains(config.agentName));

    final legacySkillPath = path.join(
      FileSystemService.instance.getWorkspacePath(userId),
      '_UserSettings',
      'skills',
      'dynamic-surfaces',
      'project_board',
    );
    expect(await Directory(legacySkillPath).exists(), isFalse);

    final subscriptionIds = GlobalEventBus.instance.getAsyncSubscriptionIds();
    expect(
      subscriptionIds,
      contains('custom_agent:surface-project-board:user_input_submitted'),
    );
    expect(
      subscriptionIds,
      contains(
        'custom_agent:surface-project-board:dynamic_surface_refresh_requested',
      ),
    );
  });

  test('reconfigures a bound page agent trigger and working mechanism',
      () async {
    final initial =
        await CustomAgentConfigService.instance.installDynamicSurfacePageAgent(
      userId: userId,
      surfaceId: 'project_board',
      triggerEventType: SystemEventTypes.userInputSubmitted,
      systemPrompt: 'Maintain only the project-board surface.',
    );
    expect(initial.systemPrompt, 'Maintain only the project-board surface.');

    final config =
        await CustomAgentConfigService.instance.installDynamicSurfacePageAgent(
      userId: userId,
      surfaceId: 'project_board',
      triggerEventType: SystemEventTypes.cardCommentPosted,
    );

    expect(config.eventType, SystemEventTypes.cardCommentPosted);
    expect(config.workingDirectory, '');
    expect(config.skillDirectoryPath, '');
    expect(config.systemPrompt, 'Maintain only the project-board surface.');
    expect(config.managedSurfaceId, 'project_board');

    final subscriptionIds = GlobalEventBus.instance.getAsyncSubscriptionIds();
    expect(
      subscriptionIds,
      isNot(
          contains('custom_agent:surface-project-board:user_input_submitted')),
    );
    expect(
      subscriptionIds,
      contains('custom_agent:surface-project-board:card_comment_posted'),
    );
    expect(
      subscriptionIds,
      contains(
        'custom_agent:surface-project-board:dynamic_surface_refresh_requested',
      ),
    );
  });

  test('upserts page agent config without resetting preserved fields',
      () async {
    const existing = CustomAgentConfig(
      agentName: 'surface-weekly-report',
      hostAgentType: HostAgentType.memex,
      skillDirectoryPath: '',
      workingDirectory: '',
      llmConfigKey: 'fast-model',
      eventType: SystemEventTypes.cardCommentPosted,
      executionMode: ExecutionMode.sync,
      dependsOn: ['upstream-agent'],
      enabled: false,
      priority: 7,
      maxRetries: 2,
      isCustom: false,
      systemPrompt: 'Keep the weekly report source current.',
      eventSerializerName: 'compact',
      managedSurfaceId: 'weekly_report',
    );
    await CustomAgentConfigService.instance.saveAndReload(userId, existing);

    final updated =
        await CustomAgentConfigService.instance.installDynamicSurfacePageAgent(
      userId: userId,
      surfaceId: 'weekly_report',
      triggerEventType: SystemEventTypes.userInputSubmitted,
    );

    expect(updated.agentName, existing.agentName);
    expect(updated.hostAgentType, HostAgentType.memex);
    expect(updated.skillDirectoryPath, '');
    expect(updated.workingDirectory, '');
    expect(updated.llmConfigKey, existing.llmConfigKey);
    expect(updated.eventType, SystemEventTypes.userInputSubmitted);
    expect(updated.executionMode, existing.executionMode);
    expect(updated.dependsOn, existing.dependsOn);
    expect(updated.enabled, existing.enabled);
    expect(updated.priority, existing.priority);
    expect(updated.maxRetries, existing.maxRetries);
    expect(updated.isCustom, existing.isCustom);
    expect(updated.systemPrompt, existing.systemPrompt);
    expect(updated.eventSerializerName, existing.eventSerializerName);
    expect(updated.managedSurfaceId, existing.managedSurfaceId);
  });

  test('manual-only page agent only subscribes to surface refresh', () async {
    final config =
        await CustomAgentConfigService.instance.installDynamicSurfacePageAgent(
      userId: userId,
      surfaceId: 'reading_list',
      triggerEventType: '',
      systemPrompt: 'Refresh the reading-list mapping from PKM when requested.',
    );

    expect(config.eventType, '');

    final subscriptionIds = GlobalEventBus.instance.getAsyncSubscriptionIds();
    expect(
      subscriptionIds,
      contains(
        'custom_agent:surface-reading-list:dynamic_surface_refresh_requested',
      ),
    );
    expect(
      subscriptionIds,
      isNot(contains('custom_agent:surface-reading-list:data_changed')),
    );
    expect(
      subscriptionIds,
      isNot(contains('custom_agent:surface-reading-list:user_input_submitted')),
    );
  });

  test('deletes dynamic surface page agent config and skill directory',
      () async {
    final config =
        await CustomAgentConfigService.instance.installDynamicSurfacePageAgent(
      userId: userId,
      surfaceId: 'reading_list',
      triggerEventType: SystemEventTypes.userInputSubmitted,
    );
    final legacySkillPath = path.join(
      FileSystemService.instance.getWorkspacePath(userId),
      '_UserSettings',
      'skills',
      'dynamic-surfaces',
      'reading_list',
    );
    await Directory(legacySkillPath).create(recursive: true);
    await File(path.join(legacySkillPath, 'SKILL.md')).writeAsString('legacy');
    expect(await Directory(legacySkillPath).exists(), isTrue);

    final deletedAgentName =
        await CustomAgentConfigService.instance.deleteDynamicSurfacePageAgent(
      userId: userId,
      surfaceId: 'reading_list',
    );

    expect(deletedAgentName, config.agentName);
    final loaded = await CustomAgentConfigService.instance.loadAll(userId);
    expect(loaded.map((item) => item.agentName),
        isNot(contains(config.agentName)));
    expect(await Directory(legacySkillPath).exists(), isFalse);

    final subscriptionIds = GlobalEventBus.instance.getAsyncSubscriptionIds();
    expect(
      subscriptionIds
          .any((id) => id.startsWith('custom_agent:${config.agentName}')),
      isFalse,
    );
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
