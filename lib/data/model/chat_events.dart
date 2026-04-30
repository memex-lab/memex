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

class ChatToolCallEvent extends ChatEvent {
  final String toolName;
  final String args;
  ChatToolCallEvent(this.toolName, this.args);
}

class ChatToolResultEvent extends ChatEvent {
  final String toolName;
  final String result;
  final bool isError;
  ChatToolResultEvent(this.toolName, this.result, {this.isError = false});
}

class ChatErrorEvent extends ChatEvent {
  final String error;
  ChatErrorEvent(this.error);
}

class ChatAgentStartedEvent extends ChatEvent {}

class ChatAgentStoppedEvent extends ChatEvent {}

class ChatTokenUsageEvent extends ChatEvent {
  final int promptTokens;
  final int completionTokens;
  final int cachedTokens;
  final int cacheBaseTokens;
  final int totalTokens;
  final double estimatedCost;

  ChatTokenUsageEvent({
    required this.promptTokens,
    required this.completionTokens,
    required this.cachedTokens,
    required this.cacheBaseTokens,
    required this.totalTokens,
    required this.estimatedCost,
  });
}

class ChatSessionCreatedEvent extends ChatEvent {
  final String sessionId;
  ChatSessionCreatedEvent(this.sessionId);
}
