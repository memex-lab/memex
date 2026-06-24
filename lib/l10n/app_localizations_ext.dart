// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';
import 'app_localizations_ext_ar.dart';
import 'app_localizations_ext_de.dart';
import 'app_localizations_ext_en.dart';
import 'app_localizations_ext_es.dart';
import 'app_localizations_ext_fr.dart';
import 'app_localizations_ext_hi.dart';
import 'app_localizations_ext_id.dart';
import 'app_localizations_ext_ja.dart';
import 'app_localizations_ext_ko.dart';
import 'app_localizations_ext_pt.dart';
import 'app_localizations_ext_ru.dart';
import 'app_localizations_ext_zh.dart';
import 'app_localizations_ext_zh_hant.dart';
import 'template_gallery_l10n.dart' as gallery;
import 'package:flutter/material.dart';

// ignore_for_file: type=lint

/// The extension for AppLocalizations.
mixin AppLocalizationsExt on AppLocalizations {
  String get pkmPARAStructureExample;
  String get timelineCardLanguageInstruction;
  String get pkmFileLanguageInstruction;
  String get pkmInsightLanguageInstruction;
  String get commentLanguageInstruction;
  String get knowledgeInsightLanguageInstruction;
  String get scheduleAggregatorLanguageInstruction;
  String get assetAnalysisLanguageInstruction;

  String get userLanguageInstruction;

  String get chatLanguageInstruction;

  String get memorySummarizeLanguageInstruction;

  String get memorySummarizeIdentityHeader;

  String get memorySummarizeInterestsHeader;

  String get memorySummarizeAssetsHeader;

  String get memorySummarizeFocusHeader;

  /// Android OAuth hint dialog (before opening browser).
  String get oauthHintTitle;
  String get oauthHintMessage;

  /// OAuth success page (HTML) after redirect.
  String get oauthSuccessTitle;
  String get oauthSuccessMessage;

  /// Share poster localization.
  String get sharePreviewTitle;
  String get shareNow;
  String get sharedFromMemex;
  String get appTagline;
  String get shareDetailStyle;
  String get shareCardStyle;
  String get shareHideBranding;
  String get shareShowBranding;

  /// Default built-in characters (used to seed `Characters/*.yaml`).
  List<Map<String, dynamic>> get defaultCharacters;

  AvatarPickerCopy get avatarPicker;
  AgentChatCopy get agentChat;
  MemexDemoCopy get demoCopy;
  String timelineWeekdayLabel(String shortWeekday);

  List<gallery.TemplateGallerySection> get timelineTemplateGallerySections {
    switch (localeName) {
      case 'zh':
      case 'zh_Hant':
        return gallery.timelineTemplateGallerySectionsZh;
      default:
        return gallery.timelineTemplateGallerySectionsEn;
    }
  }

  List<gallery.TemplateGalleryItem> get insightTemplateGalleryItems {
    switch (localeName) {
      case 'zh':
      case 'zh_Hant':
        return gallery.insightTemplateGalleryItemsZh;
      default:
        return gallery.insightTemplateGalleryItemsEn;
    }
  }

  List<gallery.InsightPreviewSample> get insightPreviewSamples {
    const order = [
      'summary_card_v1',
      'trend_chart_card_v1',
      'bar_chart_card_v1',
      'radar_chart_card_v1',
      'highlight_card_v1',
      'composition_card_v1',
      'contrast_card_v1',
      'progress_chart_card_v1',
      'bubble_chart_card_v1',
      'timeline_card_v1',
    ];
    final byTemplate = {
      for (final item in insightTemplateGalleryItems)
        item.templateId: item.data,
    };
    return [
      for (final template in order)
        if (byTemplate[template] != null)
          (template: template, data: byTemplate[template]!),
    ];
  }
}

class AvatarPickerCopy {
  const AvatarPickerCopy({
    required this.currentAvatar,
    required this.shuffle,
  });

  final String currentAvatar;
  final String shuffle;
}

class MemexDemoCopy {
  const MemexDemoCopy({
    required this.introText,
    required this.introTitle,
    required this.introInsight,
    required this.introInsightSummary,
    required this.introComment,
    required this.kbFileName,
    required this.kbContent,
    required this.firstRecordTitle,
    required this.firstRecordInsight,
    required this.firstRecordSummary,
    required this.firstRecordComment,
    required this.firstRecordKbTitle,
    required this.introHeroCaption,
    required this.introSnippetText,
    required this.smartCardTypesTitle,
    required this.productivityTitle,
    required this.productivityLabel,
    required this.knowledgeTitle,
    required this.knowledgeLabel,
    required this.dataTitle,
    required this.dataLabel,
    required this.peoplePlacesTitle,
    required this.peoplePlacesLabel,
    required this.visualTitle,
    required this.visualLabel,
    required this.insightTypesSubject,
    required this.insightTypesComment,
    required this.gettingStartedTitle,
    required this.configureModelTask,
    required this.postFirstRecordTask,
    required this.viewGeneratedTask,
    required this.sloganContent,
  });

  final String introText;
  final String introTitle;
  final String introInsight;
  final String introInsightSummary;
  final String introComment;
  final String kbFileName;
  final String kbContent;
  final String firstRecordTitle;
  final String firstRecordInsight;
  final String firstRecordSummary;
  final String firstRecordComment;
  final String firstRecordKbTitle;
  final String introHeroCaption;
  final String introSnippetText;
  final String smartCardTypesTitle;
  final String productivityTitle;
  final String productivityLabel;
  final String knowledgeTitle;
  final String knowledgeLabel;
  final String dataTitle;
  final String dataLabel;
  final String peoplePlacesTitle;
  final String peoplePlacesLabel;
  final String visualTitle;
  final String visualLabel;
  final String insightTypesSubject;
  final String insightTypesComment;
  final String gettingStartedTitle;
  final String configureModelTask;
  final String postFirstRecordTask;
  final String viewGeneratedTask;
  final String sloganContent;

  String firstRecordKbAppend(String combinedText, String factId) =>
      '\n\n## $firstRecordKbTitle\n\n$combinedText\n\n<!-- fact_id: $factId -->';
}

class AgentChatCopy {
  const AgentChatCopy({
    required this.findingRecentPhotos,
    required this.runModeAuto,
    required this.runModeAskFirst,
    required this.runModeReadOnly,
    required this.runModeAutoDescription,
    required this.runModeConfirmDescription,
    required this.runModeReadOnlyDescription,
    required this.runModeTitle,
    required this.approved,
    required this.denied,
    required this.deny,
    required this.allow,
    required this.recordSaved,
    required this.cardUpdated,
    required this.cardCreated,
    required this.cardSaved,
    required this.documentUpdated,
    required this.documentCreated,
    required this.calendarEventCreated,
    required this.reminderCreated,
    required this.insightSaved,
    required this.done,
    required this.issue,
    required this.running,
    required this.reasoningComplete,
    required this.thinkingThroughRequest,
    required this.actionNeedsAttention,
    required this.internalReasoningFinished,
    required this.planningNextStep,
    required this.toolActivity,
    required this.toolSearch,
    required this.toolFindFiles,
    required this.toolRead,
    required this.toolReadBatch,
    required this.toolWrite,
    required this.toolEdit,
    required this.toolList,
    required this.toolMove,
    required this.toolDelete,
    required this.toolDelegateTask,
    required this.toolCreateUi,
    required this.toolUpdateUi,
    required this.toolFindStyles,
    required this.toolReadStyle,
    required this.toolStyleLibrary,
    required this.toolSaveCard,
    required this.toolCreateEvent,
    required this.toolCreateReminder,
    required this.toolCancelReminderEvent,
    required this.toolSearchCards,
    required this.toolInspectCard,
    required this.toolUpdateInsight,
    required this.toolSaveInsights,
    required this.toolDeleteInsightCard,
    required this.toolDeleteInsightTags,
    required this.failed,
    required this.noOp,
    required this.needsInput,
    required this.worker,
    required this.thinking,
    required this.workerToolCalls,
    required this.workerResult,
    required this.arguments,
    required this.result,
    required this.approvalPrompt,
    required this.toolCallCount,
    required this.workingThroughActions,
    required this.completedActions,
  });

  final String findingRecentPhotos;
  final String runModeAuto;
  final String runModeAskFirst;
  final String runModeReadOnly;
  final String runModeAutoDescription;
  final String runModeConfirmDescription;
  final String runModeReadOnlyDescription;
  final String runModeTitle;
  final String approved;
  final String denied;
  final String deny;
  final String allow;
  final String recordSaved;
  final String cardUpdated;
  final String cardCreated;
  final String cardSaved;
  final String documentUpdated;
  final String documentCreated;
  final String calendarEventCreated;
  final String reminderCreated;
  final String insightSaved;
  final String done;
  final String issue;
  final String running;
  final String reasoningComplete;
  final String thinkingThroughRequest;
  final String actionNeedsAttention;
  final String internalReasoningFinished;
  final String planningNextStep;
  final String toolActivity;
  final String toolSearch;
  final String toolFindFiles;
  final String toolRead;
  final String toolReadBatch;
  final String toolWrite;
  final String toolEdit;
  final String toolList;
  final String toolMove;
  final String toolDelete;
  final String toolDelegateTask;
  final String toolCreateUi;
  final String toolUpdateUi;
  final String toolFindStyles;
  final String toolReadStyle;
  final String toolStyleLibrary;
  final String toolSaveCard;
  final String toolCreateEvent;
  final String toolCreateReminder;
  final String toolCancelReminderEvent;
  final String toolSearchCards;
  final String toolInspectCard;
  final String toolUpdateInsight;
  final String toolSaveInsights;
  final String toolDeleteInsightCard;
  final String toolDeleteInsightTags;
  final String failed;
  final String noOp;
  final String needsInput;
  final String worker;
  final String thinking;
  final String workerToolCalls;
  final String workerResult;
  final String arguments;
  final String result;
  final String Function(String toolName) approvalPrompt;
  final String Function(int count) toolCallCount;
  final String Function(int count) workingThroughActions;
  final String Function(int count) completedActions;
}

/// Standalone function to lookup AppLocalizationsExt instances by locale.
AppLocalizationsExt lookupAppLocalizationsExt(Locale locale) {
  // Lookup logic when language+script codes are specified.
  if (locale.languageCode == 'zh' &&
      (locale.scriptCode == 'Hant' ||
          locale.countryCode == 'Hant' ||
          locale.countryCode == 'TW' ||
          locale.countryCode == 'HK' ||
          locale.countryCode == 'MO')) {
    return AppLocalizationsExtZhHant();
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsExtAr();
    case 'de':
      return AppLocalizationsExtDe();
    case 'en':
      return AppLocalizationsExtEn();
    case 'es':
      return AppLocalizationsExtEs();
    case 'fr':
      return AppLocalizationsExtFr();
    case 'hi':
      return AppLocalizationsExtHi();
    case 'id':
      return AppLocalizationsExtId();
    case 'ja':
      return AppLocalizationsExtJa();
    case 'ko':
      return AppLocalizationsExtKo();
    case 'pt':
      return AppLocalizationsExtPt();
    case 'ru':
      return AppLocalizationsExtRu();
    case 'zh':
      return AppLocalizationsExtZh();
  }

  throw FlutterError(
      'AppLocalizationsExt.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
