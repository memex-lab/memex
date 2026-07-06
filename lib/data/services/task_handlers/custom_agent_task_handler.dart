import 'dart:convert';
import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import 'package:memex/agent/memex_skill_host_agent/memex_skill_host_agent.dart';
import 'package:memex/agent/pure_skill_host_agent/pure_skill_host_agent.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/data/services/asset_reference_service.dart';
import 'package:memex/data/services/asset_safety_service.dart';
import 'package:memex/data/services/custom_agent_config_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/chat_session_storage.dart';
import 'package:memex/data/services/llm_image_codec.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/custom_agent_config.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/time_context.dart';
import 'package:memex/utils/user_storage.dart';

final Logger _logger = getLogger('CustomAgentTaskHandler');

/// Call once at app init to wire the real runner into the service.
void initCustomAgentHandler() {
  setCustomAgentRunner(_handleCustomAgentTask);
}

/// MIME type lookup for common image/audio extensions.
const _mimeTypes = <String, String>{
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.png': 'image/png',
  '.gif': 'image/gif',
  '.webp': 'image/webp',
  '.heic': 'image/heic',
  '.heif': 'image/heif',
  '.bmp': 'image/bmp',
  '.tiff': 'image/tiff',
  '.tif': 'image/tiff',
  '.mp3': 'audio/mpeg',
  '.wav': 'audio/wav',
  '.flac': 'audio/flac',
  '.aac': 'audio/aac',
  '.ogg': 'audio/ogg',
  '.m4a': 'audio/mp4',
  '.aiff': 'audio/aiff',
  '.aif': 'audio/aiff',
  '.wma': 'audio/x-ms-wma',
};

/// Extract media references from the event XML string and build multimodal
/// [UserContentPart] list. This is generic — works for any event type whose
/// serialized content contains `fs://file` references.
Future<List<UserContentPart>> _buildAssetPartsFromXml(
  String userId,
  String eventXml,
) async {
  final references = AssetReferenceService.extractReferences(eventXml);
  if (references.isEmpty) return const [];

  final parts = <UserContentPart>[];

  for (final reference in references) {
    try {
      final asset = await AssetReferenceService.resolveExisting(
        userId: userId,
        reference: reference,
      );
      if (asset == null) {
        _logger.warning(
          'Asset file not found or unsupported, skipping: $reference',
        );
        continue;
      }

      final file = File(asset.absolutePath);
      final ext = p.extension(asset.fileName).toLowerCase();
      final mime = _mimeTypes[ext];
      if (mime == null) {
        _logger.fine('Unsupported asset extension, skipping: $ext');
        continue;
      }

      final safety =
          await AssetSafetyService.instance.inspectFile(asset.absolutePath);
      if (!safety.safeForInlineBase64) {
        _logger.warning(
          'Skipping unsafe custom-agent inline asset ${asset.absolutePath}: ${safety.reason}',
        );
        continue;
      }

      if (asset.type == AssetReferenceType.image) {
        // Transcode to JPEG so HEIC originals survive OpenAI-compatible
        // endpoints (Kimi rejects HEIC); falls back to raw bytes.
        final transcoded =
            await LlmImageCodec.transcodeForLlm(asset.absolutePath);
        final b64 = base64Encode(transcoded ?? await file.readAsBytes());
        parts.add(ImagePart(
          b64,
          transcoded != null ? LlmImageCodec.jpegMimeType : mime,
        ));
      } else {
        parts.add(AudioPart(base64Encode(await file.readAsBytes()), mime));
      }
    } catch (e) {
      _logger.warning('Failed to read asset $reference: $e');
    }
  }
  return parts;
}

Future<List<UserContentPart>> buildAssetPartsFromXmlForTesting(
  String userId,
  String eventXml,
) {
  return _buildAssetPartsFromXml(userId, eventXml);
}

Future<void> _handleCustomAgentTask(
  String userId,
  CustomAgentConfig config,
  Map<String, dynamic> payload,
) async {
  final agentName = config.agentName;
  _logger.info(
    'Running custom agent "$agentName" for event ${payload['event_type']}',
  );

  final agentIdForLLM = config.llmConfigKey ?? AgentDefinitions.chatAgent;
  final resources = await UserStorage.getAgentLLMResources(
    agentIdForLLM,
    defaultClientKey: config.llmConfigKey ?? LLMConfig.defaultClientKey,
  );

  final now = DateTime.now();
  final nowStr =
      '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}_${now.microsecond.toString().padLeft(6, '0')}';
  final sessionId = '${agentName}_custom_${userId}_$nowStr';
  final state = await loadOrCreateAgentState(sessionId, {
    'userId': userId,
    'agentName': agentName,
    'scene': 'custom_agent_$agentName',
    'sceneId': nowStr,
  });

  final skillAbsPath = FileSystemService.instance.resolveSkillPath(
    userId,
    config.skillDirectoryPath,
  );

  final workingDirAbsPath = await FileSystemService.instance
      .resolveWorkingDirectory(userId, config.workingDirectory);

  // Sync skill directory into workingDirectory if it's outside,
  // so file tools (Read, LS, etc.) can access skill files.
  final skillSync = await FileSystemService.instance.syncSkillsIfNeeded(
    skillAbsPath: skillAbsPath,
    workingDirAbsPath: workingDirAbsPath,
  );

  final eventXml = payload['event_xml'] as String? ?? '';
  final textContent =
      'A system event has occurred. Process it according to your skills.\n\n$eventXml';

  // Build multimodal message: text + any image/audio assets found in the XML.
  final contentParts = <UserContentPart>[TextPart(textContent)];
  final mediaParts = await _buildAssetPartsFromXml(userId, eventXml);
  contentParts.addAll(mediaParts);

  final userMessage = UserMessage(contentParts);

  StatefulAgent agent;
  switch (config.hostAgentType) {
    case HostAgentType.pure:
      agent = await PureSkillHostAgent.createAgent(
        client: resources.client,
        modelConfig: resources.modelConfig,
        userId: userId,
        name: agentName,
        state: state,
        skillDirectoryPath: skillSync.effectivePath,
        workingDirectory: workingDirAbsPath,
        additionalSystemPrompt: config.systemPrompt,
      );
      break;
    case HostAgentType.memex:
      agent = await MemexSkillHostAgent.createAgent(
        client: resources.client,
        modelConfig: resources.modelConfig,
        userId: userId,
        name: agentName,
        state: state,
        skillDirectoryPath: skillSync.effectivePath,
        workingDirectory: workingDirAbsPath,
        additionalSystemPrompt: config.systemPrompt,
      );
      break;
  }

  try {
    final responses = await agent.run([userMessage]);

    // Extract text result from agent output.
    String? resultText;
    final last = responses.isNotEmpty ? responses.last : null;
    if (last is ModelMessage && last.textOutput != null) {
      resultText = last.textOutput;
      _logger.info('Custom agent "$agentName" result: $resultText');
    } else {
      _logger.info('Custom agent "$agentName" completed, last: $last');
    }

    // Persist a chat session so AgentChatDialog can load history and
    // continue the conversation in the same session context.
    await _createChatSession(
      userId: userId,
      sessionId: sessionId,
      agentName: agentName,
      userText: textContent,
      aiResponse: resultText,
    );
  } finally {
    // Sync skill changes back to the original directory if we made a copy.
    await FileSystemService.instance.syncSkillsBack(skillSync);
  }
}

/// Create a chat session compatible with ChatService / chat.dart so
/// that AgentChatDialog can load the conversation history and continue chatting.
Future<void> _createChatSession({
  required String userId,
  required String sessionId,
  required String agentName,
  required String userText,
  String? aiResponse,
}) async {
  final storage = ChatSessionStorage.instance;

  // Don't overwrite if it already exists (e.g. retry scenario).
  if (await storage.sessionExists(userId, sessionId)) return;

  final now = DateTime.now();
  final nowIso = now.toIso8601String();
  final nowLocal = formatLocalDateTimeWithZone(now);
  final nowUnixSeconds = unixSecondsFromDateTime(now);
  final messages = <Map<String, dynamic>>[
    {
      'role': 'user',
      'content': [
        {'type': 'text', 'text': userText},
      ],
      'timestamp': nowIso,
      'local_time': nowLocal,
      'unix_seconds': nowUnixSeconds,
    },
    if (aiResponse != null)
      {
        'role': 'ai',
        'content': [
          {'type': 'text', 'text': aiResponse},
        ],
        'timestamp': nowIso,
        'local_time': nowLocal,
        'unix_seconds': nowUnixSeconds,
      },
  ];

  final metadata = <String, dynamic>{
    'session_id': sessionId,
    'agent_name': agentName,
    'title': agentName,
    'created_at': nowIso,
    'created_at_local': nowLocal,
    'created_at_unix_seconds': nowUnixSeconds,
    'updated_at': nowIso,
    'updated_at_local': nowLocal,
    'updated_at_unix_seconds': nowUnixSeconds,
    'messages': messages,
    'is_custom_agent': true,
  };

  try {
    await storage.createSession(
      userId: userId,
      sessionId: sessionId,
      metadata: metadata,
      messages: messages,
    );
    _logger.info(
      'Created chat session for custom agent "$agentName": $sessionId',
    );
  } catch (e) {
    _logger.warning('Failed to create chat session file: $e');
  }
}
