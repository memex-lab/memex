import 'dart:async';
import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:dio/dio.dart' show CancelToken;
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import 'package:memex/llm_client/gemma_model_manager.dart';

/// LLM client that runs Gemma models on-device via the official LiteRT-LM
/// Kotlin API, communicated through Flutter Platform Channels.
///
/// Supports multiple concurrent callers (e.g. card_agent + pkm_agent):
///   - Each call gets a unique requestId
///   - Kotlin side queues requests and processes them one at a time
///   - Tokens are pushed back via reverse MethodChannel "onInferenceEvent"
///   - Each Dart caller only receives events for its own requestId
class GemmaLocalClient extends LLMClient {
  final Logger _logger = Logger('GemmaLocalClient');
  final String modelId;

  static const _channel = MethodChannel('com.memexlab.memex/litert_lm');
  static const _uuid = Uuid();
  // Global lock: ensures only one inference runs at a time.
  // Simple mutex using a future chain.
  static Future<void> _lockChain = Future.value();

  /// Enqueue this caller. Returns a [Completer] — call [complete()] to release the lock.
  static Future<Completer<void>> _acquireLock() async {
    final completer = Completer<void>();
    final prev = _lockChain;
    _lockChain = completer.future;
    await prev; // wait for all previous holders to finish
    return completer;
  }

  // Active inference streams keyed by requestId
  static final Map<String, StreamController<Map<String, dynamic>>>
      _activeStreams = {};
  static bool _callbackRegistered = false;

  GemmaLocalClient({required this.modelId}) {
    _ensureCallbackRegistered();
  }

  /// Register the reverse MethodChannel handler once
  static void _ensureCallbackRegistered() {
    if (_callbackRegistered) return;
    _callbackRegistered = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onInferenceEvent') {
        final args = Map<String, dynamic>.from(call.arguments as Map);
        final requestId = args['requestId'] as String?;
        if (requestId != null && _activeStreams.containsKey(requestId)) {
          _activeStreams[requestId]!.add(args);
        }
      }
    });
  }

  @override
  Future<ModelMessage> generate(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    final inferenceStream = await stream(
      messages,
      tools: tools,
      toolChoice: toolChoice,
      modelConfig: modelConfig,
      jsonOutput: jsonOutput,
      cancelToken: cancelToken,
    );

    final buffer = StringBuffer();
    final functionCalls = <FunctionCall>[];
    String? thought;

    await for (final msg in inferenceStream) {
      final m = msg.modelMessage;
      if (m == null) continue;
      if (m.textOutput != null && m.textOutput!.isNotEmpty) {
        buffer.write(m.textOutput);
      }
      if (m.functionCalls.isNotEmpty) {
        functionCalls.addAll(m.functionCalls);
      }
      if (m.thought != null) thought = (thought ?? '') + (m.thought ?? '');
    }

    return ModelMessage(
      textOutput: buffer.isEmpty ? null : buffer.toString(),
      functionCalls: functionCalls,
      thought: thought,
      model: modelConfig.model,
      stopReason: 'end_turn',
    );
  }

  @override
  Future<Stream<StreamingMessage>> stream(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    final isInstalled = await GemmaModelManager.isModelInstalled(modelId);
    if (!isInstalled) {
      throw Exception(
        'Gemma model "$modelId" is not downloaded. '
        'Please download it from the model configuration page first.',
      );
    }

    final requestId = _uuid.v4();
    final args = _buildChannelArgs(messages, tools, modelConfig);
    final controller = StreamController<StreamingMessage>();

    // Acquire global lock first — ensures no other inference is running before
    // we potentially rebuild the engine for a different backend configuration.
    final lockCompleter = await _acquireLock();

    // Engine init/rebuild happens inside the lock so we never tear down the
    // engine while another inference is still in progress.
    await GemmaModelManager.ensureEngineReady(
      modelId,
      maxTokens: modelConfig.maxTokens,
      enableVision: _hasImageContent(messages),
      enableAudio: _hasAudioContent(messages),
    );

    void releaseLock() {
      if (!lockCompleter.isCompleted) lockCompleter.complete();
    }

    void releaseLockAndCleanup() {
      _cleanup(requestId);
      releaseLock();
    }

    // Register stream for this requestId
    final eventController = StreamController<Map<String, dynamic>>();
    _activeStreams[requestId] = eventController;

    // Listen to events from Kotlin for this requestId
    final sub = eventController.stream.listen(
      (event) {
        final type = event['type'] as String?;
        switch (type) {
          case 'text':
            final token = event['token'] as String? ?? '';
            if (token.isNotEmpty) {
              controller.add(StreamingMessage(
                modelMessage: ModelMessage(
                  textOutput: token,
                  model: modelConfig.model,
                ),
              ));
            }
          case 'tool_call':
            final name = event['name'] as String? ?? '';
            final arguments = event['arguments'] as String? ?? '{}';
            controller.add(StreamingMessage(
              modelMessage: ModelMessage(
                functionCalls: [
                  FunctionCall(id: name, name: name, arguments: arguments),
                ],
                model: modelConfig.model,
              ),
            ));
          case 'thought':
            final content = event['content'] as String? ?? '';
            if (content.isNotEmpty) {
              controller.add(StreamingMessage(
                modelMessage: ModelMessage(
                  thought: content,
                  model: modelConfig.model,
                ),
              ));
            }
          case 'done':
            controller.add(StreamingMessage(
              modelMessage: ModelMessage(
                stopReason: 'end_turn',
                model: modelConfig.model,
              ),
            ));
            releaseLockAndCleanup();
            if (!controller.isClosed) controller.close();
          case 'error':
            final message = event['message'] as String? ?? 'Unknown error';
            _logger.severe('LiteRT-LM inference error [$requestId]: $message');
            releaseLockAndCleanup();
            if (!controller.isClosed) {
              controller
                  .addError(Exception('Gemma local inference error: $message'));
              controller.close();
            }
        }
      },
      onError: (Object e) {
        _logger.severe('LiteRT-LM stream error', e);
        releaseLockAndCleanup();
        if (!controller.isClosed) {
          controller.addError(Exception('Gemma local inference error: $e'));
          controller.close();
        }
      },
      onDone: () {
        releaseLockAndCleanup();
        if (!controller.isClosed) controller.close();
      },
      cancelOnError: true,
    );

    // Start inference on native side (returns immediately, queued)
    await _channel.invokeMethod('startInference', {
      'requestId': requestId,
      'args': args,
    });

    // Handle external cancellation
    cancelToken?.whenCancel.then((_) {
      _channel.invokeMethod('cancelInference', {'requestId': requestId});
      releaseLockAndCleanup();
      sub.cancel();
      if (!controller.isClosed) controller.close();
    });

    return controller.stream;
  }

  static void _cleanup(String requestId) {
    final sc = _activeStreams.remove(requestId);
    if (sc != null && !sc.isClosed) sc.close();
  }

  static bool _hasImageContent(List<LLMMessage> messages) {
    for (final m in messages) {
      if (m is UserMessage) {
        if (m.contents.any((p) => p is ImagePart)) return true;
      }
    }
    return false;
  }

  static bool _hasAudioContent(List<LLMMessage> messages) {
    for (final m in messages) {
      if (m is UserMessage) {
        if (m.contents.any((p) => p is AudioPart)) return true;
      }
    }
    return false;
  }

  Map<String, dynamic> _buildChannelArgs(
    List<LLMMessage> messages,
    List<Tool>? tools,
    ModelConfig modelConfig,
  ) {
    final systemParts = <String>[];
    final nativeMessages = <Map<String, dynamic>>[];

    for (final m in messages) {
      if (m is SystemMessage) {
        systemParts.add(m.content);
      } else if (m is UserMessage) {
        final textParts = <String>[];
        String? imageBase64;
        String? audioBase64;

        for (final part in m.contents) {
          if (part is TextPart) {
            textParts.add(part.text);
          } else if (part is ImagePart) {
            imageBase64 = part.base64Data;
          } else if (part is AudioPart) {
            audioBase64 = part.base64Data;
          }
        }
        final msg = <String, dynamic>{
          'role': 'user',
          'text': textParts.join('\n'),
        };
        if (imageBase64 != null) msg['imageBase64'] = imageBase64;
        if (audioBase64 != null) msg['audioBase64'] = audioBase64;
        nativeMessages.add(msg);
      } else if (m is ModelMessage) {
        if (m.textOutput != null && m.textOutput!.isNotEmpty) {
          nativeMessages.add({'role': 'model', 'text': m.textOutput!});
        }
      } else if (m is FunctionExecutionResultMessage) {
        for (final res in m.results) {
          final text =
              res.content.whereType<TextPart>().map((t) => t.text).join('\n');
          nativeMessages.add({
            'role': 'tool',
            'toolName': res.id,
            'text': text,
          });
        }
      }
    }

    final nativeTools = tools
            ?.map((t) => {
                  'name': t.name,
                  'description': t.description,
                  'parametersJson': jsonEncode(t.parameters),
                })
            .toList() ??
        [];

    return {
      'systemInstruction': systemParts.isEmpty ? null : systemParts.join('\n'),
      'messages': nativeMessages,
      'tools': nativeTools,
      'temperature': modelConfig.temperature,
      'topK': modelConfig.topK,
      'topP': modelConfig.topP,
    };
  }
}
