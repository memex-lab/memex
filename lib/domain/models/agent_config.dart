class AgentConfig {
  static const Object _unset = Object();

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
    Object? llmConfigKey = _unset,
  }) {
    return AgentConfig(
      llmConfigKey:
          identical(llmConfigKey, _unset) ? this.llmConfigKey : llmConfigKey as String?,
    );
  }
}
