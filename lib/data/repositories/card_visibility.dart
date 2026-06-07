import 'package:memex/domain/models/card_model.dart';

/// Cards that are useful as internal task logs but should not appear in the
/// user's memory timeline.
bool shouldHideFromTimeline(CardData card) {
  return isDynamicSurfaceMaintenanceResultCard(card);
}

bool isDynamicSurfaceMaintenanceResultCard(CardData card) {
  for (final config in card.uiConfigs) {
    if (config.templateId != 'system_task') continue;
    final agentName =
        (config.data['agentName'] ?? config.data['title'] ?? card.title)
            ?.toString()
            .trim();
    if (agentName != null && agentName.startsWith('surface-')) {
      return true;
    }
  }
  return false;
}
