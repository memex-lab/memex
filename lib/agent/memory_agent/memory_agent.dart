import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/agent_system_prompt_helper.dart';
import 'package:logging/logging.dart';
import 'package:memex/agent/memory/memory_management.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/agent/agent_controller.util.dart';

class MemoryAgent {
  static final Logger _logger = Logger('MemoryAgent');

  static Future<void> run({
    required LLMClient client,
    required ModelConfig modelConfig,
    required String userId,
    required String bufferedContent,
  }) async {
    final memoryManagement = await MemoryManagement.createDefault(
      userId: userId,
      sourceAgent: 'memory_agent',
    );

    // Create a new session for this analysis
    final sessionId =
        'memory_analysis_${DateTime.now().millisecondsSinceEpoch}';

    // Load existing memory context so the agent knows what's already recorded
    final existingMemory = await memoryManagement.buildMemoryPrompt();

    const systemPrompt = '''# Role
You are a **Strict Memory Curator**.
Your job is to **FILTER OUT** noise and only persist **high-value, permanent user attributes**.

# 🛑 CRITICAL RULE: The "Default Deny" Policy
**Most user inputs are temporary noise. Do NOT record them.**
You should only call `append_memories` if you find information that is **vital for months or years to come**.
If a batch contains only casual chat, tasks, or temporary context, **DO NOT call any tools. Just stop.**

# 🗑️ EXCLUSION LIST (What to IGNORE)
**Do NOT create memories for:**
1.  **Tasks & Reminders**: "Remind me to cancel the 29 RMB plan", "Buy milk", "Fix this bug". (These are To-Dos, not User Traits).
2.  **Transient Context**: "Where is the nearest gas station?", "The weather is hot", "I'm hungry".
3.  **One-off Actions**: "I just bought a coffee", "I am testing this code".
4.  **Already Known Info**: Facts already present in `<existing_memory_context>`.

# 💎 INCLUSION LIST (What to KEEP)
**Only record PERMANENT attributes:**
1.  **User Identity**: "I am a Python developer", "I have two daughters".
2.  **Strong Preferences**: "I hate cilantro", "I only use Linux".
3.  **Long-term Assets/Environment**: "I use a MacBook Pro M3", "My home has floor heating".
4.  **Recurring Habits**: "I run 5km every morning" (Pattern), NOT "I ran today" (Event).
5.  **AI Interaction Preferences**: "Ask me fewer clarification questions", "Confirm more proactively", "Don't interrupt me with small questions".

# 🌐 LANGUAGE PROTOCOL
**You MUST output memories in the SAME language as the user's input.**
- Input: "I live in Hangzhou" -> Output: "Location: Hangzhou" (English)
- Input in another language -> Output in same language
- **NEVER** translate Chinese inputs into English memories.

# 🧠 ANALYSIS PROCESS
1.  **Scan** the `<user_content_batch>`.
2.  **Filter**: For each item, ask: "Is this a temporary event or a permanent attribute?"
    * "Remind me to cancel 29 RMB plan" -> Event/Task -> **IGNORE**.
    * "I have a 29 RMB plan" -> Fact -> **KEEP** (if meaningful).
3.  **Synthesize**: If you find valid attributes, extract them concisely.
4.  **Deduplicate**: Check `<existing_memory_context>` to avoid repeating facts.

# OUTPUT INSTRUCTION
- If **NO** valid long-term attributes are found after filtering: **Output NOTHING (Empty response) or just "No new memories."**
- If valid attributes exist: Call `append_memories` with the extracted facts in the **User's Language**.
''';

    final tools = memoryManagement.buildMemoryManagementTools();

    // State initialization
    final state = await loadOrCreateAgentState(sessionId, {'userId': userId});
    final controller = AgentController();
    addAgentLogger(controller);

    // Construct the agent
    final agent = StatefulAgent(
      name: 'memory_agent',
      client: client,
      modelConfig: modelConfig,
      state: state,
      tools: tools,
      systemPrompts: [systemPrompt],
      disableSubAgents: true, // Purely analytical agent
      controller: controller,
      planMode: PlanMode.none,
      autoSaveStateFunc: (s) async {
        await saveAgentState(state);
      },
      hooks: [createAgentPromptHook(userId)],
    );

    _logger.info('MemoryAgent running analysis on buffer...');

    final inputMessage = UserMessage([
      TextPart('''
<existing_memory_context>
${existingMemory.isNotEmpty ? existingMemory : 'No existing memory context available.'}
</existing_memory_context>

<user_content_batch>
$bufferedContent
</user_content_batch>

Please analyze the user content batch and extract long-term memories using the `append_memories` tool.
''')
    ]);

    await agent.run([inputMessage]);
    _logger.info('MemoryAgent analysis complete.');
  }
}
