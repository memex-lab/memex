import 'chat_artifact.dart';

abstract class ChatEvent {}

class ChatResponseChunkEvent extends ChatEvent {
  final String text;
  final bool isDone;
  ChatResponseChunkEvent(this.text, {this.isDone = false});
}

class ChatThoughtChunkEvent extends ChatEvent {
  final String text;
  ChatThoughtChunkEvent(this.text);
}

enum ChatTraceKind { tool, delegate }

class ChatTraceStartedEvent extends ChatEvent {
  final String id;
  final String? parentId;
  final ChatTraceKind kind;
  final String name;
  final String args;
  final String? label;

  ChatTraceStartedEvent({
    required this.id,
    this.parentId,
    required this.kind,
    required this.name,
    required this.args,
    this.label,
  });
}

class ChatTraceCompletedEvent extends ChatEvent {
  final String id;
  final String result;
  final bool isError;
  final String? status;

  /// Structured metadata returned by the tool (e.g. an `artifact` entry
  /// describing a created record/card/document for UI previews).
  final Map<String, dynamic>? metadata;

  ChatTraceCompletedEvent({
    required this.id,
    required this.result,
    this.isError = false,
    this.status,
    this.metadata,
  });
}

class ChatErrorEvent extends ChatEvent {
  final String error;
  ChatErrorEvent(this.error);
}

class ChatArtifactsEvent extends ChatEvent {
  final List<ChatArtifact> artifacts;
  ChatArtifactsEvent(this.artifacts);
}

class ChatAgentStartedEvent extends ChatEvent {}

class ChatAgentStoppedEvent extends ChatEvent {}

class ChatTokenUsageEvent extends ChatEvent {
  final int promptTokens;
  final int completionTokens;
  final int cachedTokens;
  final int totalTokens;
  final double estimatedCost;

  /// Normalized denominator for cache rate, computed per-call then summed.
  final int effectivePromptTokens;

  /// Numerator for cache rate (excludes unknown-semantics calls).
  final int cachedTokensForRate;

  ChatTokenUsageEvent({
    required this.promptTokens,
    required this.completionTokens,
    required this.cachedTokens,
    required this.totalTokens,
    required this.estimatedCost,
    this.effectivePromptTokens = 0,
    this.cachedTokensForRate = 0,
  });
}

class ChatSessionCreatedEvent extends ChatEvent {
  final String sessionId;
  ChatSessionCreatedEvent(this.sessionId);
}
