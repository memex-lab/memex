import 'dart:async';
import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import '../data/services/gemini_auth_service.dart';
import 'gemini_oauth_project.dart';
import 'package:memex/llm_client/codex_responses_client.dart'
    show configureProxy;

const _codeAssistEndpoint = 'https://cloudcode-pa.googleapis.com';
const _codeAssistHeaders = {
  'X-Goog-Api-Client': 'gl-node/22.17.0',
  'Client-Metadata':
      'ideType=IDE_UNSPECIFIED,platform=PLATFORM_UNSPECIFIED,pluginType=GEMINI',
};

/// LLM client that uses Google OAuth + Cloud Code Assist API (free Gemini CLI tier).
/// Mirrors the opencode-gemini-auth plugin flow.
class GeminiOAuthClient extends LLMClient {
  final Logger _logger = Logger('GeminiOAuthClient');
  final Dio _client;
  final Duration timeout;
  final Duration connectTimeout;
  final String? proxyUrl;
  final int maxRetries;
  final int initialRetryDelayMs;
  final int maxRetryDelayMs;

  GeminiOAuthClient({
    this.timeout = const Duration(seconds: 300),
    this.connectTimeout = const Duration(seconds: 60),
    this.proxyUrl,
    this.maxRetries = 3,
    this.initialRetryDelayMs = 5000,
    this.maxRetryDelayMs = 30000,
    Dio? client,
  }) : _client = client ?? Dio() {
    configureProxy(_client, proxyUrl);
    _client.options.connectTimeout = connectTimeout;
  }

  Future<Map<String, String>> _buildHeaders() async {
    final accessToken = await GeminiAuthService.getValidAccessToken();
    if (accessToken == null) throw Exception('Gemini OAuth not authorized.');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
      'User-Agent': GeminiOAuthProject.geminiCliUserAgent,
      ..._codeAssistHeaders,
    };
  }

  /// Wraps a standard Gemini request body into the Code Assist envelope.
  Future<Map<String, dynamic>> _wrapRequest(
    Map<String, dynamic> geminiBody,
    String model,
  ) async {
    final projectId = await GeminiOAuthProject.ensureProjectId();
    // Strip 'model' from inner request (Code Assist sets it at top level)
    final inner = Map<String, dynamic>.from(geminiBody)..remove('model');
    // Normalize system_instruction -> systemInstruction
    if (inner.containsKey('system_instruction')) {
      inner['systemInstruction'] = inner.remove('system_instruction');
    }
    // Strip thought parts from history (they cause errors on re-send)
    _stripThoughtParts(inner);
    return {
      'project': projectId,
      'model': model,
      'request': inner,
    };
  }

  void _stripThoughtParts(Map<String, dynamic> body) {
    final contents = body['contents'];
    if (contents is! List) return;
    final sanitized = <dynamic>[];
    for (final content in contents) {
      if (content is! Map<String, dynamic>) {
        sanitized.add(content);
        continue;
      }
      final record = Map<String, dynamic>.from(content);
      final parts = record['parts'];
      if (parts is! List) {
        sanitized.add(record);
        continue;
      }
      final filtered = parts
          .where((p) =>
              p is! Map<String, dynamic> || p['thought'] != true)
          .toList();
      if (filtered.isEmpty && record['role'] == 'model') continue;
      sanitized.add({...record, 'parts': filtered});
    }
    body['contents'] = sanitized;
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
    final model = modelConfig.model;
    final geminiBody = _createGeminiBody(messages,
        tools: tools,
        toolChoice: toolChoice,
        modelConfig: modelConfig,
        jsonOutput: jsonOutput);
    final wrappedBody = await _wrapRequest(geminiBody, model);
    final url = '$_codeAssistEndpoint/v1internal:generateContent';

    int retryCount = 0;
    int currentDelayMs = initialRetryDelayMs;

    while (true) {
      try {
        final headers = await _buildHeaders();
        final response = await _client.post(
          url,
          data: wrappedBody,
          options: Options(
            sendTimeout: timeout,
            receiveTimeout: timeout,
            headers: headers,
            validateStatus: (_) => true,
          ),
          cancelToken: cancelToken,
        );

        if (response.statusCode == 200) {
          final data = _unwrapResponse(response.data);
          final msg = _parseResponse(data, modelConfig);
          if (msg == null) {
            if (retryCount < maxRetries) {
              await _waitRetry('No candidates', retryCount, currentDelayMs);
              retryCount++;
              currentDelayMs = (currentDelayMs * 2).clamp(0, maxRetryDelayMs);
              continue;
            }
            throw Exception('Gemini OAuth returned no candidates');
          }
          return msg;
        }

        if (response.statusCode == 429 ||
            (response.statusCode != null && response.statusCode! >= 500)) {
          if (retryCount < maxRetries) {
            await _waitRetry(
                'status ${response.statusCode}', retryCount, currentDelayMs);
            retryCount++;
            currentDelayMs = (currentDelayMs * 2).clamp(0, maxRetryDelayMs);
            continue;
          }
        }
        throw Exception(
            'Gemini OAuth error: ${response.statusCode} ${response.data}');
      } on DioException catch (e) {
        if (retryCount < maxRetries) {
          await _waitRetry(
              'DioException: ${e.message}', retryCount, currentDelayMs);
          retryCount++;
          currentDelayMs = (currentDelayMs * 2).clamp(0, maxRetryDelayMs);
          continue;
        }
        rethrow;
      }
    }
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
    final model = modelConfig.model;
    final geminiBody = _createGeminiBody(messages,
        tools: tools,
        toolChoice: toolChoice,
        modelConfig: modelConfig,
        jsonOutput: jsonOutput);
    final wrappedBody = await _wrapRequest(geminiBody, model);
    final url = '$_codeAssistEndpoint/v1internal:streamGenerateContent?alt=sse';

    final controller = StreamController<StreamingMessage>();
    int retryCount = 0;
    int currentDelayMs = initialRetryDelayMs;

    void pump() async {
      while (true) {
        try {
          final headers = await _buildHeaders();
          final response = await _client.post(
            url,
            data: wrappedBody,
            options: Options(
              responseType: ResponseType.stream,
              sendTimeout: timeout,
              receiveTimeout: timeout,
              headers: {...headers, 'Accept': 'text/event-stream'},
              validateStatus: (_) => true,
            ),
            cancelToken: cancelToken,
          );

          if (response.statusCode != 200) {
            if (response.statusCode == 429 ||
                (response.statusCode != null && response.statusCode! >= 500)) {
              if (retryCount < maxRetries) {
                await _waitRetry('status ${response.statusCode}', retryCount,
                    currentDelayMs);
                retryCount++;
                currentDelayMs = (currentDelayMs * 2).clamp(0, maxRetryDelayMs);
                controller.add(StreamingMessage(
                    controlMessage: StreamingControlMessage(
                        controlFlag: StreamingControlFlag.retry,
                        data: {
                      'retryReason': 'status ${response.statusCode}'
                    })));
                continue;
              }
            }
            final body = await utf8.decodeStream(
                (response.data.stream as Stream).cast<List<int>>());
            throw Exception(
                'Gemini OAuth stream error: ${response.statusCode} $body');
          }

          final rawStream = (response.data.stream as Stream).cast<List<int>>();
          final transformedStream = rawStream
              .transform(utf8.decoder)
              .transform(const LineSplitter())
              .transform(_SseDecoder())
              .map((data) => _parseResponse(data, modelConfig))
              .where((msg) => msg != null)
              .map((msg) => StreamingMessage(modelMessage: msg!));

          bool retryNeeded = false;
          String? stopReason;
          await for (final msg in transformedStream) {
            stopReason = msg.modelMessage?.stopReason;
            if (stopReason == 'MALFORMED_FUNCTION_CALL' ||
                stopReason == 'OTHER') {
              retryNeeded = true;
              break;
            }
            controller.add(msg);
          }

          if (retryNeeded && retryCount < maxRetries) {
            await _waitRetry(
                'stopReason: $stopReason', retryCount, currentDelayMs);
            retryCount++;
            currentDelayMs = (currentDelayMs * 2).clamp(0, maxRetryDelayMs);
            controller.add(StreamingMessage(
                controlMessage: StreamingControlMessage(
                    controlFlag: StreamingControlFlag.retry,
                    data: {'retryReason': 'stopReason: $stopReason'})));
            continue;
          }

          controller.close();
          break;
        } on DioException catch (e) {
          if (retryCount < maxRetries) {
            await _waitRetry(
                'DioException: ${e.message}', retryCount, currentDelayMs);
            retryCount++;
            currentDelayMs = (currentDelayMs * 2).clamp(0, maxRetryDelayMs);
            controller.add(StreamingMessage(
                controlMessage: StreamingControlMessage(
                    controlFlag: StreamingControlFlag.retry,
                    data: {'retryReason': 'DioException: ${e.message}'})));
            continue;
          }
          controller.addError(e);
          controller.close();
          break;
        } catch (e) {
          controller.addError(e);
          controller.close();
          break;
        }
      }
    }

    pump();
    return controller.stream;
  }

  Future<void> _waitRetry(String reason, int retryCount, int delayMs) async {
    _logger.warning(
        'GeminiOAuth: $reason. Retrying in ${delayMs}ms... (attempt ${retryCount + 1}/$maxRetries)');
    await Future.delayed(Duration(milliseconds: delayMs));
  }

  /// Unwrap Code Assist envelope: `{response: <gemini_response>}` -> inner response.
  Map<String, dynamic> _unwrapResponse(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('response')) {
      return data['response'] as Map<String, dynamic>;
    }
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      try {
        final parsed = jsonDecode(data) as Map<String, dynamic>;
        if (parsed.containsKey('response')) {
          return parsed['response'] as Map<String, dynamic>;
        }
        return parsed;
      } catch (_) {}
    }
    return {};
  }
}

// ---------------------------------------------------------------------------
// SSE decoder: parses `data: {...}` lines from the Code Assist SSE stream.
// The inner JSON may be wrapped as `{response: <gemini_chunk>}`.
// ---------------------------------------------------------------------------
class _SseDecoder extends StreamTransformerBase<String, Map<String, dynamic>> {
  @override
  Stream<Map<String, dynamic>> bind(Stream<String> stream) async* {
    await for (final line in stream) {
      if (!line.startsWith('data:')) continue;
      final json = line.substring(5).trim();
      if (json.isEmpty || json == '[DONE]') continue;
      try {
        final parsed = jsonDecode(json) as Map<String, dynamic>;
        // Unwrap Code Assist envelope
        if (parsed.containsKey('response')) {
          yield parsed['response'] as Map<String, dynamic>;
        } else {
          yield parsed;
        }
      } catch (_) {}
    }
  }
}

// ---------------------------------------------------------------------------
// Request body builder (reuses dart_agent_core Gemini format)
// ---------------------------------------------------------------------------
Map<String, dynamic> _createGeminiBody(
  List<LLMMessage> messages, {
  List<Tool>? tools,
  ToolChoice? toolChoice,
  required ModelConfig modelConfig,
  bool? jsonOutput,
}) {
  final contents = messages.where((m) => m is! SystemMessage).map((m) {
    String role = 'user';
    if (m is ModelMessage) role = 'model';
    if (m is FunctionExecutionResultMessage) role = 'function';

    final parts = <Map<String, dynamic>>[];

    if (m is UserMessage) {
      for (final part in m.contents) {
        if (part is TextPart) {
          parts.add({'text': part.text});
        } else if (part is ImagePart) {
          parts.add({
            'inlineData': {'mimeType': part.mimeType, 'data': part.base64Data}
          });
        }
      }
    } else if (m is ModelMessage) {
      if (m.textOutput != null) parts.add({'text': m.textOutput});
      for (final fc in m.functionCalls) {
        final fcPart = <String, dynamic>{
          'functionCall': {
            'name': fc.name,
            'args': fc.arguments is Map
                ? fc.arguments
                : jsonDecode(fc.arguments),
          }
        };
        if (m.thoughtSignature != null) {
          fcPart['thoughtSignature'] = m.thoughtSignature;
        }
        parts.add(fcPart);
      }
    } else if (m is FunctionExecutionResultMessage) {
      for (final res in m.results) {
        final text =
            res.content.whereType<TextPart>().map((t) => t.text).join('\n');
        parts.add({
          'functionResponse': {
            'name': res.id,
            'response': {'content': text},
          }
        });
      }
    }

    return {'role': role, 'parts': parts};
  }).toList();

  final systemMessages = messages.whereType<SystemMessage>().toList();
  final generationConfig = <String, dynamic>{
    if (modelConfig.temperature != null) 'temperature': modelConfig.temperature,
    if (modelConfig.maxTokens != null) 'maxOutputTokens': modelConfig.maxTokens,
    if (modelConfig.topP != null) 'topP': modelConfig.topP,
    if (jsonOutput == true) 'responseMimeType': 'application/json',
  };

  if (modelConfig.extra?['thinkingConfig'] != null) {
    generationConfig['thinkingConfig'] = modelConfig.extra!['thinkingConfig'];
  }

  final body = <String, dynamic>{
    'contents': contents,
    if (generationConfig.isNotEmpty) 'generationConfig': generationConfig,
  };

  if (systemMessages.isNotEmpty) {
    body['systemInstruction'] = {
      'parts': [
        {'text': systemMessages.map((m) => m.content).join('\n')}
      ]
    };
  }

  if (tools != null && tools.isNotEmpty) {
    body['tools'] = [
      {
        'functionDeclarations': tools
            .map((t) => {
                  'name': t.name,
                  'description': t.description,
                  'parameters': t.parameters,
                })
            .toList()
      }
    ];

    switch (toolChoice?.mode) {
      case ToolChoiceMode.none:
        body['toolConfig'] = {
          'functionCallingConfig': {'mode': 'NONE'}
        };
        break;
      case ToolChoiceMode.auto:
        body['toolConfig'] = {
          'functionCallingConfig': {'mode': 'AUTO'}
        };
        break;
      case ToolChoiceMode.required:
        final cfg = <String, dynamic>{'mode': 'ANY'};
        if (toolChoice?.allowedFunctionNames != null) {
          cfg['allowedFunctionNames'] = toolChoice!.allowedFunctionNames;
        }
        body['toolConfig'] = {'functionCallingConfig': cfg};
        break;
      case null:
        break;
    }
  }

  return body;
}

ModelMessage? _parseResponse(
    Map<String, dynamic> data, ModelConfig modelConfig) {
  try {
    final candidates = data['candidates'] as List? ?? [];
    if (candidates.isEmpty) return null;

    final candidate = candidates[0] as Map<String, dynamic>;
    final contentParts =
        (candidate['content'] as Map?)?['parts'] as List? ?? [];

    String? textOutput;
    String? thought;
    String? thoughtSignature;
    final functionCalls = <FunctionCall>[];

    for (final part in contentParts) {
      if (part is! Map) continue;
      if (part['thought'] == true) {
        thought = (thought ?? '') + (part['text'] as String? ?? '');
      } else if (part.containsKey('text')) {
        textOutput = (textOutput ?? '') + (part['text'] as String? ?? '');
      }
      if (part.containsKey('functionCall')) {
        final fc = part['functionCall'] as Map;
        functionCalls.add(FunctionCall(
          id: fc['name'] as String,
          name: fc['name'] as String,
          arguments: jsonEncode(fc['args'] ?? {}),
        ));
      }
      if (part.containsKey('thoughtSignature')) {
        thoughtSignature = part['thoughtSignature'] as String?;
      }
    }

    if (candidate.containsKey('thoughtSignature')) {
      thoughtSignature = candidate['thoughtSignature'] as String?;
    }

    ModelUsage? usage;
    if (data['usageMetadata'] != null) {
      final u = data['usageMetadata'] as Map;
      usage = ModelUsage(
        promptTokens: (u['promptTokenCount'] as num?)?.toInt() ?? 0,
        completionTokens: (u['candidatesTokenCount'] as num?)?.toInt() ?? 0,
        totalTokens: (u['totalTokenCount'] as num?)?.toInt() ?? 0,
        cachedToken: (u['cachedContentTokenCount'] as num?)?.toInt() ?? 0,
        thoughtToken: (u['thoughtsTokenCount'] as num?)?.toInt() ?? 0,
        model: modelConfig.model,
        originalUsage: u as Map<String, dynamic>,
      );
    }

    return ModelMessage(
      textOutput: textOutput,
      thought: thought,
      thoughtSignature: thoughtSignature,
      functionCalls: functionCalls,
      usage: usage,
      stopReason: candidate['finishReason'] as String?,
      model: modelConfig.model,
    );
  } catch (e) {
    return null;
  }
}
