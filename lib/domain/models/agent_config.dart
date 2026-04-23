class AgentConfig {
  /// The key of the LLMConfig to use for this agent.
  final String? llmConfigKey;

  const AgentConfig({
    this.llmConfigKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'llmConfigKey': llmConfigKey,
    };
  }

  factory AgentConfig.fromJson(Map<String, dynamic> json) {
    return AgentConfig(
      llmConfigKey: json['llmConfigKey'] as String?,
    );
  }

  AgentConfig copyWith({
    String? llmConfigKey,
  }) {
    return AgentConfig(
      llmConfigKey: llmConfigKey ?? this.llmConfigKey,
    );
  }
}
