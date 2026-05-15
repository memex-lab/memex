import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/utils/time_context.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:path/path.dart' as p;

import 'package:logging/logging.dart';

final _logger = Logger('MemoryManagement');

class MemoryManagement {
  final String userId;
  final String sourceAgent;
  final FileSystemService fileSystem;
  final LLMClient client;
  final ModelConfig modelConfig;
  final int recentBufferThreshold;

  MemoryManagement({
    required this.userId,
    required this.sourceAgent,
    required this.client,
    required this.modelConfig,
    this.recentBufferThreshold = 10,
    FileSystemService? fileSystem,
  }) : fileSystem = fileSystem ?? FileSystemService.instance;

  static Future<MemoryManagement> createDefault({
    required String userId,
    required String sourceAgent,
    FileSystemService? fileSystem,
  }) async {
    final resources = await UserStorage.getAgentLLMResources(
      AgentDefinitions.profileAgent,
      defaultClientKey: LLMConfig.defaultClientKey,
    );

    return MemoryManagement(
      userId: userId,
      sourceAgent: sourceAgent,
      client: resources.client,
      modelConfig: resources.modelConfig,
      fileSystem: fileSystem,
    );
  }

  // Static lock map to handle concurrency across different MemoryManagement instances
  static final Map<String, Future<void>> _locks = {};

  Future<T> _withLock<T>(String key, Future<T> Function() operation) async {
    while (_locks.containsKey(key)) {
      await _locks[key]!;
    }

    final completer = Completer<void>();
    _locks[key] = completer.future;

    try {
      return await operation();
    } finally {
      completer.complete();
      _locks.remove(key);
    }
  }

  Future<T> _runWithMemoryLock<T>(Future<T> Function() operation) async {
    final path = _getMemoryPath();
    return _withLock(path, operation);
  }

  String _getMemoryPath() {
    return p.join(fileSystem.getSystemPath(userId), 'memory', 'memory.json');
  }

  Future<Map<String, dynamic>> _loadMemory() async {
    final path = _getMemoryPath();
    final file = File(path);
    if (!await file.exists()) {
      return {
        "user_id": userId,
        "last_updated": DateTime.now().toIso8601String(),
        "next_mem_id": 101,
        "archived_memory": "",
        "recent_buffer": [],
      };
    }

    try {
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      // In case of error/corruption, return default structure but maybe log warning?
      // For now, robust fallback.
      return {
        "user_id": userId,
        "last_updated": DateTime.now().toIso8601String(),
        "next_mem_id": 101,
        "archived_memory": "",
        "recent_buffer": [],
      };
    }
  }

  Future<void> _writeMemory(Map<String, dynamic> memory) async {
    final path = _getMemoryPath();
    final file = File(path);
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }

    // Update timestamp
    memory['last_updated'] = DateTime.now().toIso8601String();

    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(memory));
  }

  Future<String> appendMemories(List<String> memories) async {
    return _runWithMemoryLock(() async {
      var mem = await _loadMemory();
      final buffer = (mem['recent_buffer'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [];

      int nextId = (mem['next_mem_id'] as int?) ?? 101;
      final addedIds = <String>[];

      for (final memory in memories) {
        final m = memory.trim();
        if (m.isEmpty) continue;

        final memoryId = "mem_$nextId";
        nextId++;

        final newEntry = {
          "memory_id": memoryId,
          "content": m,
          "source_agent": sourceAgent,
          "created_at": DateTime.now().toIso8601String(),
        };

        buffer.add(newEntry);
        addedIds.add(memoryId);
      }

      mem['next_mem_id'] = nextId;
      mem['recent_buffer'] = buffer;

      String resultMsg =
          "Memories appended successfully. IDs: ${addedIds.join(', ')}";

      if (buffer.length > recentBufferThreshold) {
        try {
          mem = await _summarizeMemory(mem);
          resultMsg += "\n(Memory buffer consolidated to archive)";
        } catch (e) {
          resultMsg += "\n(Memory consolidation failed: $e)";
        }
      }

      await _writeMemory(mem);
      return resultMsg;
    });
  }

  List<Tool> buildMemoryManagementTools() {
    return [
      Tool(
        name: 'append_memories',
        description:
            'Records permanent facts, preferences, or plans into the user\'s long-term profile. DO NOT record transient context (e.g., "User is asking about X") or chat logs. ONLY record enduring information that will be useful for future sessions. Support batch addition.',
        parameters: {
          'type': 'object',
          'properties': {
            'memories': {
              'type': 'array',
              'description':
                  'List of memory strings to add. Each string should be an atomic fact using 3rd person perspective. AVOID "User said". BAD: "User said he likes Python". GOOD: "Preferred programming language is Python".',
              'items': {
                'type': 'string',
              },
            },
          },
          'required': ['memories'],
        },
        executable: (List<dynamic> memories) async {
          return appendMemories(memories.whereType<String>().toList());
        },
      ),
    ];
  }

  Future<Map<String, dynamic>> _summarizeMemory(
      Map<String, dynamic> memory) async {
    final archived = memory['archived_memory'] as String? ?? '';
    final buffer = (memory['recent_buffer'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        [];

    if (buffer.isEmpty) return memory;

    final itemsToConsolidate = buffer;
    final itemsToKeep = <Map<String, dynamic>>[];

    if (itemsToConsolidate.isEmpty) return memory;

    final currentTime = DateTime.now();

    final itemsBuffer = StringBuffer();
    for (final item in itemsToConsolidate) {
      itemsBuffer.writeln('- [${item['created_at']}] ${item['content']}');
    }

    final prompt = '''Role: You are an expert **User Profile Builder**.
Task: Synthesize "Short-term Memories" into a cohesive "User Profile".
Goal: **Summarize and compress** information to build a high-fidelity persona. Do NOT create a daily log.

## Context Data:
Current Local Time: ${formatLocalDateTimeWithZone(currentTime)}

## Current Profile (Markdown):
${archived.isEmpty ? '(Empty - Initialize new)' : archived}

## New Information Buffer:
${itemsBuffer.toString()}

## Processing Rules (STRICT):

1.  **Profiling over Logging (CRITICAL)**:
    -   **Convert Events to Attributes**: Do not record *what happened*. Record *what it means*.
    -   *Bad*: "User asked about OpenWrt settings on Monday." -> This is a Log.
    -   *Good*: "Tech Stack: Familiar with OpenWrt & Network configuration." -> This is a Profile.
    -   **Transformation**: Extract the User's Identity, Skills, Preferences, and Constraints from the raw events.

2.  **Aggressive Merging (Summary)**:
    -   **Combine Related Items**: If the buffer has 5 entries about "Router setup", summarize them into **ONE** bullet point defining the user's network setup.
    -   **Update Status**: If new info contradicts old info (e.g., location changed), **overwrite** the old info. Keep only the latest state.
    -   **Discard Noise**: Remove specific timestamps, one-off transaction IDs, and transient emotions.

3.  **Language Consistency**:
    -   ${UserStorage.l10n.memorySummarizeLanguageInstruction}
    -   Keep technical terms (like "Python", "OpenWrt") in English where appropriate.

4.  **Output Structure**:
    -   Organize the summary using these logical headers (or similar):
        -   `${UserStorage.l10n.memorySummarizeIdentityHeader}`: Basic info, roles, family status.
        -   `${UserStorage.l10n.memorySummarizeInterestsHeader}`: Tech stack, hobbies, professional skills.
        -   `${UserStorage.l10n.memorySummarizeAssetsHeader}`: Devices, hardware, location, home setup.
        -   `${UserStorage.l10n.memorySummarizeFocusHeader}`: Active goals or immediate plans (summarized).
    -   Use concise bullet points.

5.  **Output**:
    -   Return ONLY the updated Markdown text. Do not wrap in markdown code blocks.
    -   **CRITICAL**: You must output the **FULL, MERGED Profile**. Do not output just the changes. The output should be a valid, standalone Markdown document that replaces the old profile entirely.
    -   **CONSTRAINT**: Keep the entire profile concise, ideally under 1000 words. Prune less important details if necessary to fit.
''';

    try {
      final response = await client.generate(
        [
          UserMessage([TextPart(prompt)])
        ],
        modelConfig: modelConfig,
      );

      var rawOutput = response.textOutput?.trim() ?? '';
      if (rawOutput.startsWith('```')) {
        rawOutput =
            rawOutput.replaceAll(RegExp(r'^```(markdown)?|```$'), '').trim();
      }

      // Auto-condense if output is too long (approx 1000 words -> 3000~4000 chars mixed context)
      if (rawOutput.length > 4000) {
        _logger.info(
            'Profile too long (${rawOutput.length} chars). Requesting condensation.');

        final condensePrompt = '''
You are an expert editor.
The following user profile is too long (${rawOutput.length} characters).
Please condense it to under 2000 characters while strictly preserving the key attributes (Identity, Skills, Preferences).
Discard verbose timestamps or minor details.

Profile to condense:
"""
$rawOutput
"""

Output ONLY the condensed Markdown.
''';

        try {
          final condenseResponse = await client.generate(
            [
              UserMessage([TextPart(condensePrompt)])
            ],
            modelConfig: modelConfig,
          );

          final condensedOutput = condenseResponse.textOutput?.trim() ?? '';
          if (condensedOutput.isNotEmpty) {
            var finalOutput = condensedOutput;
            if (finalOutput.startsWith('```')) {
              finalOutput = finalOutput
                  .replaceAll(RegExp(r'^```(markdown)?|```$'), '')
                  .trim();
            }
            rawOutput = finalOutput;
            _logger.info('Profile condensed to ${rawOutput.length} chars.');
          }
        } catch (e) {
          _logger.warning('Failed to condense profile: $e');
        }
      }

      final newArchived = rawOutput;

      if (newArchived.isNotEmpty) {
        memory['archived_memory'] = newArchived;
        memory['recent_buffer'] = itemsToKeep;
      }
    } catch (e) {
      _logger.severe('Memory consolidation failed: $e');
    }

    return memory;
  }

  Future<String> buildMemoryManagementPrompt() async {
    return '''## Memory System Capabilities (Background Process)
You possess a long-term memory system as a **secondary, background capability**.
**Primary Directive**: Your main priority is ALWAYS to fulfill the user's immediate request (answering questions, coding, chatting, etc.) accurately and helpfully.
**Secondary Directive (The "Silent Observer")**: 
While executing your primary directive, **silently observe** the conversation for high-value information to update the User Profile.
- **Do NOT** let this background task interfere with the quality or tone of your main response.
- **Do NOT** ask the user follow-up questions solely to populate the memory.

---
### 🧠 Core Memory Logic
1. **Recall**: Use the context provided in the `<user_memory_context>` block to tailor your responses.
2. **Record (Analytic & Selective)**: 
   - **Trigger Condition**: Use the `append_memories` tool **IF AND ONLY IF** you detect new information with clear **Long-term Strategic Value**.
   - **Analyst Mindset**: Do not act as a passive scribe. Look for patterns and attributes (e.g., "User buys expensive gear" -> "High spending power"), rather than just logging events.
   - **AI Interaction Preferences**: Treat durable preferences about how the AI should interact as memory candidates, such as asking fewer clarification questions, confirming more proactively, or avoiding small interruptions.
   - **The "Silence is Okay" Rule**: If the conversation is casual, transactional, or contains no new profile data, **DO NOT call the tool**. It is better to record *nothing* than to fill the memory with noise.

   #### Recording Rules (Strict Filters)
   
   **Rule 1: The "7-Day Validity" Test** (Time Filter)
   Before calling the tool, ask: *"Will this fact still be useful guidance for me 7 days from now?"*
   - YES -> It's a candidate for memory.
   - NO -> Discard it. (e.g., "I'm hungry", "Traffic is bad", "I'm testing this code").
   - **EXCEPTION**: Record **Upcoming Events** (flights, deadlines) regardless of the 7-day rule as they impact the immediate future.

   **Rule 2: The "Profile vs. Diary" Test** (Abstraction Filter)
   - **Diary (DON'T RECORD)**: Specific timestamps, transaction logs, invoice numbers, daily OOTD, fluctuating prices (e.g., stock price today).
   - **Profile (DO RECORD)**: The *attributes* implied by those events.
     - *Raw Event*: "Bought a \$2000 coffee machine."
     - *Memory*: "User is a coffee enthusiast and values high-end appliances." (Extract the **Trait**, not just the Receipt).

   **Rule 3: The "Implicit Insight" Rule** (Inference)
   - Capture what the user *implies* but doesn't say.
   - *User says*: "Can you make the font bigger? My eyes hurt."
   - *Memory*: "User has visual accessibility needs/prefers large text."

   **Rule 4: The "Dual-Write" Requirement**
   - Even if you produced a file/artifact for the user, if the *context* of that task defines the user (e.g., "Working on Project X"), record the *context* to memory.

   #### ❌ Explicit Exclusion List (Do NOT Record)
   - **Transactional Noise**: Invoice IDs, receipt numbers, courier tracking codes.
   - **Transient Data**: Current weather, specific stock prices (unless analyzing trends), random daily thoughts.
   - **Completed Chores**: "I took out the trash" (Zero long-term value).

   #### Case Studies: How to Think Like a Profiler
    
    **Case 1: The "Financial Noise" Trap**
    - **User Input**: "Bought 6 knife items on Dec 12 2025, total 598.3, 5 pending shipment."
    - **❌ WRONG Way (Accountant)**: "Dec 12 2025 knife purchase 598.3." (Reason: Records transient price and date.)
    - **✅ RIGHT Way (Profiler)**: 
      1. *Analyze*: Price and Date are noise. Status (Shipping) is transient.
      2. *Extract*: User buys *multiple* knives -> User collects knives.
      3. *Memory*: "Interest: **knife collection**."

    **Case 2: The "Stock Snapshot" Trap**
    - **User Input**: "Moor thread closed at 814.88, down 13.41%, think A-shares have a bubble."
    - **❌ WRONG Way (Logger)**: "Record Moor thread 814.88, market cap 383B..." (Reason: Prices change every second. Junk data tomorrow.)
    - **✅ RIGHT Way (Profiler)**:
      1. *Analyze*: Specific numbers are snapshots. Delete them.
      2. *Extract*: User pays attention to this stock + negative view on market.
      3. *Memory*: "Investment view: follows **Moor thread**, sees A-shares bubble."

    **Case 3: The "Language Match" Trap**
    - **User Input**: "I don't like cilantro."
    - **❌ WRONG Way (Translator)**: "User dislikes coriander." (Reason: Language mismatch.)
    - **✅ RIGHT Way (Native Speaker)**: "Food preference: dislikes **cilantro**."

    **Case 4: The "Implicit Trait" Extraction**
    - **User Input**: "My portfolio has NVDA and Tencent."
    - **✅ RIGHT Way**: "Investment Interest: Holds **US Tech (NVDA)** and **HK Tech (Tencent)**." (Focus on the *Sector* and *Asset Class*, not the account balance).
''';
  }

  Future<String> buildSuperAgentMemoryManagementPrompt() async {
    final basePrompt = await buildMemoryManagementPrompt();
    return '''$basePrompt

## SuperAgent Memory Boundary (Conservative Mode)
SuperAgent often searches and summarizes existing workspace history. Apply these extra rules when deciding whether to call `append_memories`:
- Treat retrieved Facts, PKM files, chat history, existing memory, and event logs as read-only evidence. Do not convert them into new memories by themselves.
- Only write memory when the current conversation introduces or explicitly confirms durable user profile information, or when the user explicitly asks you to remember/update memory.
- Deduplicate against `<user_memory_context>`; do not rewrite or paraphrase information that is already known.
''';
  }

  Future<String> buildMemoryReadOnlyPrompt() async {
    return '''## Memory System Capabilities (Read-Only Context)
You have access to the user's long-term memory context as **reference material only**.
**Primary Directive**: Use the `<user_memory_context>` block to tailor your response to the user's preferences, active projects, and constraints.

---
### 🧠 Core Memory Logic
1. **Recall Only**: Use the context provided in the `<user_memory_context>` block to answer the user's immediate request accurately and helpfully.
2. **No Memory Updates**: You cannot and must not create, update, delete, or propose changes to memory in this mode.
3. **Read-Only Task Boundary**: When searching, summarizing, listing, or comparing existing Facts/PKM/history/chat records, treat all retrieved information as read-only evidence for the answer, not as new memory candidates.
''';
  }

  Future<String> buildMemoryPrompt() async {
    return _runWithMemoryLock(() async {
      final mem = await _loadMemory();
      final archived = mem['archived_memory'] as String? ?? '';

      final buffer = (mem['recent_buffer'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [];

      if (archived.isEmpty && buffer.isEmpty) {
        return "";
      }

      final sb = StringBuffer();

      sb.writeln('<user_memory_context>');
      sb.writeln(
          'The following is the user\'s long-term profile and recent context.');
      sb.writeln('');

      if (archived.isNotEmpty) {
        sb.writeln('### 🧠 Long-term Profile (Established Facts)');
        sb.writeln(archived);
        sb.writeln('');
      }

      if (buffer.isNotEmpty) {
        sb.writeln('### 📝 Recent Working Memory (New & Unprocessed)');

        for (final item in buffer) {
          final timeStr = item['created_at'] ?? '';
          final shortTime =
              timeStr.length > 16 ? timeStr.substring(0, 16) : timeStr;

          sb.writeln('- [$shortTime] ${item['content']}');
        }
        sb.writeln('');
      }

      sb.writeln('</user_memory_context>');

      if (archived.isNotEmpty || buffer.isNotEmpty) {
        sb.writeln(
            '**Context Instruction**: The above information defines the user\'s preferences, active projects, and constraints. You must adapt your response to align with this profile.');
      }

      return sb.toString();
    });
  }
}
