import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/run_mode/agent_action_approval_service.dart';
import 'package:memex/utils/date_util.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/time_context.dart';

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

/// Mint a fresh `fact_id` for a brand-new record, reserving the id by writing a
/// `processing` placeholder card. This is a SuperAgent base tool (not buried in
/// a skill) so the agent can mint without first activating
/// `manage_timeline_card` — capture then becomes a clean "mint, then delegate"
/// flow. It writes data, so it is intentionally excluded from Quick Query
/// (read-only) mode.
final mintRecordFactIdTool = Tool(
  name: 'mint_record_fact_id',
  description:
      "Mint a fresh fact_id for a brand-new record BEFORE creating its card. "
      "The system reserves the id (it never collides and is never guessed by "
      "you). Pass the returned fact_id into the task_brief of every worker for "
      "this record (card / PKM / schedule) so they all link to one identity. "
      "Use this only for a NEW record — to edit an existing card, reuse that "
      "card's id instead.",
  parameters: {
    'type': 'object',
    'properties': {},
  },
  executable: () async {
    final context = AgentCallToolContext.current;
    if (context == null) {
      throw StateError(
          "mint_record_fact_id must be called within an agent execution context.");
    }

    final denied = await gateMutatingToolCall(
      toolName: 'mint_record_fact_id',
      summary: 'Reserve a new card id (processing placeholder)',
    );
    if (denied != null) return denied;

    final userId = context.state.metadata['userId'] as String;
    final factId = await FileSystemService.instance.allocateCardFactId(userId);
    getLogger('CommonTools').info('Minted fact_id: $factId');
    return AgentToolResult(
      content: TextPart(
          "Minted fact_id: $factId. Use this exact id when saving the card "
          "(save_timeline_card), organizing it into PKM "
          "(`<!-- fact_id: $factId -->`), and updating the schedule, so every "
          "part of this record shares one identity."),
      metadata: {
        'artifact': {
          'type': 'fact_id',
          'id': factId,
        },
      },
    );
  },
);
