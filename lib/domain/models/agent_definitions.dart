class AgentDefinitions {
  static const String analyzeAssets = 'analyze_assets';
  static const String cardAgent = 'card_agent';
  static const String pkmAgent = 'pkm_agent';
  static const String knowledgeInsightAgent = 'knowledge_insight_agent';
  static const String commentAgent = 'comment_agent';
  static const String chatAgent = 'chat_agent';
  static const String companionAgent = 'companion_agent';
  static const String profileAgent = 'profile_agent';
  static const String postCardRouterAgent = 'post_card_router_agent';
  static const String scheduleAggregatorAgent = 'schedule_aggregator_agent';
  static const String askClarificationAgent = 'ask_clarification_agent';
  static const String clarificationResolutionAgent =
      'clarification_resolution_agent';

  /// Order here drives the display order in the agent configuration screen.
  static const Map<String, String> displayNames = {
    analyzeAssets: 'Media analysis',
    cardAgent: 'Cards',
    pkmAgent: 'PKM',
    knowledgeInsightAgent: 'Insights',
    commentAgent: 'Comments',
    chatAgent: 'Chat',
    companionAgent: 'Companion',
    profileAgent: 'Memory summary',
    postCardRouterAgent: 'Post-Card Router',
    scheduleAggregatorAgent: 'Schedule',
    askClarificationAgent: 'Ask Clarification',
    clarificationResolutionAgent: 'Ask resolution',
  };

  /// Agent IDs exposed in the model configuration screen.
  ///
  /// Keeping this derived from the display-name registry makes the settings UI
  /// pick up newly registered built-in agents automatically.
  static List<String> get configurableAgentIds =>
      List.unmodifiable(displayNames.keys);
}
