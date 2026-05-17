import 'dart:async';
import 'dart:convert';
import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:logging/logging.dart';
import 'package:memex/utils/user_storage.dart';

/// Helper class for managing agent responseId and hashCode caching
class AgentCacheHelper {
  static final Logger _logger = Logger('AgentCacheHelper');
  static bool responseCacheEnabled = false;

  /// Per-agentType "creation in progress" Future; ensures only one cache creation per agentType at a time
  static final Map<String, Future<void>> _creationLocks = {};

  /// Validates and ensures a valid cached responseId with matching hashCode
  ///
  /// [agentType] Agent type identifier (e.g., 'card', 'pkm')
  /// [client] LLM client instance
  /// [model] Model name
  /// [baseExtra] Base extra configuration for model config (e.g., reasoning settings)
  /// [agentFactory] Factory function to create an agent instance (should capture business parameters via closure)
  ///
  /// Returns the cached responseId if valid, or null if a new one needs to be fetched
  static Future<String?> ensureValidCachedResponseId({
    required String agentType,
    required LLMClient client,
    required ModelConfig modelConfig,
    required Future<StatefulAgent> Function({
      required LLMClient client,
      required ModelConfig modelConfig,
    }) agentFactory,
  }) async {
    if (client is! ResponsesClient) {
      return null;
    }
    if (!client.baseUrl.startsWith("https://ark.cn-beijing.volces.com")) {
      return null;
    }
    if (!responseCacheEnabled) {
      return null;
    }
    // Create a temporary agent to calculate current systemPrompt and tools hashCode
    // We need this to compare with cached values
    final tempAgentForHash = await agentFactory(
      client: client,
      modelConfig: modelConfig,
    );

    // Calculate current systemPrompt and tools hashCode
    final systemMessage = tempAgentForHash.composeSystemMessage();
    final currentSystemPromptHash = systemMessage?.content.hashCode ?? 0;
    final toolsCopy = tempAgentForHash.composeTools();
    // Create a string representation for each tool including name, description, and parameters
    final toolSignatures = toolsCopy.map((t) {
      // Serialize parameters to JSON string for consistent hashing
      final parametersJson = jsonEncode(t.parameters);
      return '${t.name}|${t.description}|$parametersJson';
    }).toList()
      ..sort();
    final currentToolsHash = toolSignatures.join('||').hashCode;

    // Get cached agent data (responseId and hashCode)
    final cachedData = await UserStorage.getCachedAgentData(agentType);
    String? cachedResponseId = cachedData?.responseId;

    // Check if responseId exists and is valid
    bool responseIdValid = false;
    if (cachedResponseId != null) {
      responseIdValid = await client.checkResponseId(cachedResponseId);
    }

    // Check if hashCode matches
    bool hashCodeMatches = false;
    if (cachedData != null) {
      hashCodeMatches =
          cachedData.systemPromptHash == currentSystemPromptHash &&
              cachedData.toolsHash == currentToolsHash;
    }

    // If responseId doesn't exist, is invalid, or hashCode doesn't match,
    // run with null input to get a new one (only one request per agentType may run creation; others wait and retry)
    if (cachedResponseId == null || !responseIdValid || !hashCodeMatches) {
      final existingLock = _creationLocks[agentType];
      if (existingLock != null) {
        await existingLock;
        return ensureValidCachedResponseId(
          agentType: agentType,
          client: client,
          modelConfig: modelConfig,
          agentFactory: agentFactory,
        );
      }

      final completer = Completer<void>();
      _creationLocks[agentType] = completer.future;
      try {
        final reason = cachedResponseId == null
            ? 'missing'
            : !responseIdValid
                ? 'invalid'
                : 'hashCode mismatch';
        _logger.info(
          '[$agentType] ResponseId cache is $reason (responseId: ${cachedResponseId ?? "null"}, valid: $responseIdValid, hashCode matches: $hashCodeMatches), running with null input to get new responseId',
        );

        // Create modelConfig for initialization (with caching enabled)
        // Based on baseExtra, but add caching and expire_at
        // Set expire_at to 1 hour from now (in seconds)
        final expireAt = (DateTime.now()
                .add(const Duration(hours: 1))
                .millisecondsSinceEpoch ~/
            1000);
        final initExtra = Map<String, dynamic>.from(modelConfig.extra ?? {});
        // local_todo: check if extra is configured in storage
        initExtra["caching"] = {"type": "enabled", "prefix": true};
        initExtra["expire_at"] = expireAt;
        final initModelConfig = ModelConfig(
          model: modelConfig.model,
          extra: initExtra,
          temperature: modelConfig.temperature,
          maxTokens:
              null, // Volcengine does not support caching.prefix with max_output_tokens
          topP: modelConfig.topP,
          topK: modelConfig.topK,
          generationConfig: modelConfig.generationConfig,
        );

        // Create a temporary agent to run with null input
        final tempAgent = await agentFactory(
          client: client,
          modelConfig: initModelConfig,
        );

        // Run with null input to get responseId
        final emptyInput = <LLMMessage>[];
        final messages = await tempAgent.run(emptyInput, useStream: false);

        // Extract responseId from the returned messages
        String? newResponseId;
        for (final msg in messages) {
          if (msg is ModelMessage && msg.responseId != null) {
            newResponseId = msg.responseId;
            break;
          }
        }

        if (newResponseId != null) {
          // Save responseId and hashCode together
          await UserStorage.saveCachedAgentData(
            agentType,
            AgentCacheData(
              responseId: newResponseId,
              systemPromptHash: currentSystemPromptHash,
              toolsHash: currentToolsHash,
            ),
          );
          _logger.info(
            '[$agentType] Cached new responseId: $newResponseId with hashCode (systemPrompt: $currentSystemPromptHash, tools: $currentToolsHash)',
          );
          return newResponseId;
        } else {
          _logger.warning(
              '[$agentType] Failed to get responseId from null input run');
          return null;
        }
      } finally {
        completer.complete();
        _creationLocks.remove(agentType);
      }
    }

    // Cache is valid, return the cached responseId
    return cachedResponseId;
  }
}
