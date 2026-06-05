import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/custom_agent_config.dart';

void main() {
  test('serializes optional managed surface id for page agents', () {
    const config = CustomAgentConfig(
      agentName: 'project-page',
      skillDirectoryPath: '_UserSettings/skills/project-page',
      workingDirectory: '',
      eventType: 'dynamic_surface_refresh_requested',
      managedSurfaceId: 'project_board',
    );

    final decoded = CustomAgentConfig.fromJsonString(config.toJsonString());

    expect(decoded.agentName, 'project-page');
    expect(decoded.eventType, 'dynamic_surface_refresh_requested');
    expect(decoded.managedSurfaceId, 'project_board');
    expect(decoded.toJson()['managedSurfaceId'], 'project_board');
  });
}
