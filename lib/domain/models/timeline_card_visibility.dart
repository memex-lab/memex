import 'package:memex/domain/models/timeline_card_model.dart';

/// Stable identifiers used by the retired synthetic schedule briefing card.
///
/// These remain in the domain layer only for backward compatibility with
/// existing workspaces and delayed UI events. New code must not create cards
/// with either identifier.
const retiredScheduleBriefingCardId = '_system/schedule_briefing';
const retiredScheduleBriefingTemplateId = 'schedule_briefing';

/// Whether [card] belongs to a retired synthetic Timeline feature.
///
/// Keep this policy shared by every Timeline ingress path so legacy cards
/// cannot reappear through pagination, restore, or delayed event delivery.
bool isRetiredTimelineCard(TimelineCardModel card) {
  return card.id == retiredScheduleBriefingCardId ||
      card.uiConfigs.any(
        (config) => config.templateId == retiredScheduleBriefingTemplateId,
      );
}
