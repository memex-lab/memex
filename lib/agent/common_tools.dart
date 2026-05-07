import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/prompts.dart';
import 'package:memex/utils/date_util.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/file_operation_service.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/time_context.dart';
import 'dart:io';

final getCurrentTimeTool = Tool(
  name: 'getCurrentTime',
  description: 'Get current time and week id',
  parameters: {
    'type': 'object',
    'properties': {},
  },
  executable: () {
    final now = DateTime.now();

    // ISO week year can be different from calendar year (e.g. early Jan)
    // Adjust year if needed.
    // For simplicity, let's trust the Monday-based calc.
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final thursday = monday.add(const Duration(days: 3));
    final year = thursday.year;

    final weekId = '${year}_W${isoWeekNumber(now)}';
    return "Current Local Time: ${formatLocalDateTimeWithZone(now)}, Current WeekId: $weekId";
  },
);

final getPkmOverviewTool = Tool(
  name: 'get_pkm_overview',
  description:
      'Get current directory structure and file information of the PKM knowledge base.',
  parameters: {
    'type': 'object',
    'properties': {},
  },
  executable: () async {
    final context = AgentCallToolContext.current;
    if (context == null) {
      throw StateError(
          "get_pkm_overview must be called within an agent execution context.");
    }
    final userId = context.state.metadata['userId'] as String;
    final fileService = FileSystemService.instance;
    final fileOpService = FileOperationService.instance;

    final workingDirectory = fileService.getWorkspacePath(userId);
    final pkmPath = fileService.getPkmPath(userId);
    final pkmDir = Directory(pkmPath);

    String pkmStructure = '';
    try {
      if (pkmDir.existsSync()) {
        pkmStructure = await fileOpService.listDirectory(
          dirPath: pkmPath,
          workingDirectory: workingDirectory,
        );
      } else {
        pkmStructure = Prompts.pkmAgentDirectoryNotCreated;
      }
    } catch (e) {
      getLogger('PkmAgent').warning('Failed to get PKM structure: $e');
      pkmStructure = Prompts.pkmAgentDirectoryStructureError(e.toString());
    }
    final header = pkmStructure.contains('passing a specific path') ? Prompts.pkmAgentTruncatedOverviewHeader : Prompts.pkmAgentFullOverviewHeader;
    return '''<system-reminder>
$header
$pkmStructure
</system-reminder>''';
  },
);
