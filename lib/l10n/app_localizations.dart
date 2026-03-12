import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @timesLabel.
  ///
  /// In en, this message translates to:
  /// **'Times'**
  String get timesLabel;

  /// No description provided for @recordSubmittedAiProcessing.
  ///
  /// In en, this message translates to:
  /// **'Record submitted, AI is processing...'**
  String get recordSubmittedAiProcessing;

  /// No description provided for @modelSetAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set {modelId} as default model'**
  String modelSetAsDefault(Object modelId);

  /// No description provided for @loadModelListFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load model list: \n{error}'**
  String loadModelListFailed(Object error);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noModelsFound.
  ///
  /// In en, this message translates to:
  /// **'No models found'**
  String get noModelsFound;

  /// No description provided for @unknownModel.
  ///
  /// In en, this message translates to:
  /// **'Unknown model'**
  String get unknownModel;

  /// No description provided for @openAiModelConfig.
  ///
  /// In en, this message translates to:
  /// **'OpenAI Model Config'**
  String get openAiModelConfig;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @confirmClear.
  ///
  /// In en, this message translates to:
  /// **'Confirm clear'**
  String get confirmClear;

  /// No description provided for @confirmClearTokenMessage.
  ///
  /// In en, this message translates to:
  /// **'Clear current user? You will need to enter user ID again.'**
  String get confirmClearTokenMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @tokenCleared.
  ///
  /// In en, this message translates to:
  /// **'User cleared'**
  String get tokenCleared;

  /// No description provided for @clearTokenFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear user: {error}'**
  String clearTokenFailed(Object error);

  /// No description provided for @reprocessKnowledgeBase.
  ///
  /// In en, this message translates to:
  /// **'Reprocess knowledge base'**
  String get reprocessKnowledgeBase;

  /// No description provided for @selectDateRangeOptional.
  ///
  /// In en, this message translates to:
  /// **'Select date range (optional):'**
  String get selectDateRangeOptional;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @processLimitOptional.
  ///
  /// In en, this message translates to:
  /// **'Process limit (optional)'**
  String get processLimitOptional;

  /// No description provided for @leaveEmptyForAll.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to process all'**
  String get leaveEmptyForAll;

  /// No description provided for @startProcessing.
  ///
  /// In en, this message translates to:
  /// **'Start processing'**
  String get startProcessing;

  /// No description provided for @userIdNotFound.
  ///
  /// In en, this message translates to:
  /// **'User ID not found'**
  String get userIdNotFound;

  /// No description provided for @reprocessTaskCreated.
  ///
  /// In en, this message translates to:
  /// **'Reprocess task created, running in background'**
  String get reprocessTaskCreated;

  /// No description provided for @createTaskFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create task: {error}'**
  String createTaskFailed(Object error);

  /// No description provided for @reprocessCards.
  ///
  /// In en, this message translates to:
  /// **'Reprocess cards'**
  String get reprocessCards;

  /// No description provided for @reprocessCardsTaskCreated.
  ///
  /// In en, this message translates to:
  /// **'Reprocess cards task created, running in background'**
  String get reprocessCardsTaskCreated;

  /// No description provided for @regenerateComments.
  ///
  /// In en, this message translates to:
  /// **'Regenerate comments'**
  String get regenerateComments;

  /// No description provided for @regenerateCommentsTaskCreated.
  ///
  /// In en, this message translates to:
  /// **'Regenerate comments task created, running in background'**
  String get regenerateCommentsTaskCreated;

  /// No description provided for @clearData.
  ///
  /// In en, this message translates to:
  /// **'Clear data'**
  String get clearData;

  /// No description provided for @confirmClearDataMessage.
  ///
  /// In en, this message translates to:
  /// **'Clear data?'**
  String get confirmClearDataMessage;

  /// No description provided for @confirmClearDataKeepFactsMessage.
  ///
  /// In en, this message translates to:
  /// **'Only the Facts directory (raw input) will be kept. All other workspace directories (Cards, Discoveries, KnowledgeInsights, PKM, _System, etc.) will be deleted.\n\nThis action cannot be undone!'**
  String get confirmClearDataKeepFactsMessage;

  /// No description provided for @dataClearedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data cleared successfully'**
  String get dataClearedSuccess;

  /// No description provided for @clearDataFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear data: {error}'**
  String clearDataFailed(Object error);

  /// No description provided for @personalCenter.
  ///
  /// In en, this message translates to:
  /// **'Personal center'**
  String get personalCenter;

  /// No description provided for @viewLogs.
  ///
  /// In en, this message translates to:
  /// **'View logs'**
  String get viewLogs;

  /// No description provided for @systemAuthorization.
  ///
  /// In en, this message translates to:
  /// **'System authorization'**
  String get systemAuthorization;

  /// No description provided for @modelAuthorization.
  ///
  /// In en, this message translates to:
  /// **'Model authorization'**
  String get modelAuthorization;

  /// No description provided for @pkmKnowledgeBase.
  ///
  /// In en, this message translates to:
  /// **'PKM knowledge base'**
  String get pkmKnowledgeBase;

  /// No description provided for @aiCharacterConfig.
  ///
  /// In en, this message translates to:
  /// **'AI character config'**
  String get aiCharacterConfig;

  /// No description provided for @appLockConfig.
  ///
  /// In en, this message translates to:
  /// **'App lock config'**
  String get appLockConfig;

  /// No description provided for @modelConfig.
  ///
  /// In en, this message translates to:
  /// **'Model config'**
  String get modelConfig;

  /// No description provided for @agentConfig.
  ///
  /// In en, this message translates to:
  /// **'Agent config'**
  String get agentConfig;

  /// No description provided for @modelUsageStats.
  ///
  /// In en, this message translates to:
  /// **'Model usage stats'**
  String get modelUsageStats;

  /// No description provided for @asyncTaskList.
  ///
  /// In en, this message translates to:
  /// **'Async task list'**
  String get asyncTaskList;

  /// No description provided for @clearLocalToken.
  ///
  /// In en, this message translates to:
  /// **'Clear user'**
  String get clearLocalToken;

  /// No description provided for @insightCardTemplates.
  ///
  /// In en, this message translates to:
  /// **'Insight card templates'**
  String get insightCardTemplates;

  /// No description provided for @timelineCardTemplates.
  ///
  /// In en, this message translates to:
  /// **'Timeline card templates'**
  String get timelineCardTemplates;

  /// No description provided for @logViewer.
  ///
  /// In en, this message translates to:
  /// **'Log viewer'**
  String get logViewer;

  /// No description provided for @autoRefresh.
  ///
  /// In en, this message translates to:
  /// **'Auto refresh'**
  String get autoRefresh;

  /// No description provided for @lineCount.
  ///
  /// In en, this message translates to:
  /// **'Line count: '**
  String get lineCount;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @loadStatsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load stats: {error}'**
  String loadStatsFailed(Object error);

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @detail.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get detail;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @totalCalls.
  ///
  /// In en, this message translates to:
  /// **'Total calls'**
  String get totalCalls;

  /// No description provided for @saveLlmConfigFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save LLM config: {error}'**
  String saveLlmConfigFailed(Object error);

  /// No description provided for @webHtmlPreviewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'HTML preview is not available on web. Please view on mobile.'**
  String get webHtmlPreviewUnavailable;

  /// No description provided for @saveUserInfoFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save user info: {error}'**
  String saveUserInfoFailed(Object error);

  /// No description provided for @totalEstimatedCost.
  ///
  /// In en, this message translates to:
  /// **'Total estimated cost'**
  String get totalEstimatedCost;

  /// No description provided for @detailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get detailSubtitle;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @noFragments.
  ///
  /// In en, this message translates to:
  /// **'No fragments'**
  String get noFragments;

  /// No description provided for @totalTokenConsumption.
  ///
  /// In en, this message translates to:
  /// **'Total token consumption'**
  String get totalTokenConsumption;

  /// No description provided for @dataLoadFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'Data load failed, please retry later.'**
  String get dataLoadFailedRetry;

  /// No description provided for @timelineLoadFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'Timeline load failed, please retry later.'**
  String get timelineLoadFailedRetry;

  /// No description provided for @aggregatedLoadFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'Failed to load aggregated data, please retry later.'**
  String get aggregatedLoadFailedRetry;

  /// No description provided for @newPerspective.
  ///
  /// In en, this message translates to:
  /// **'New perspective'**
  String get newPerspective;

  /// No description provided for @startPoint.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startPoint;

  /// No description provided for @endPoint.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endPoint;

  /// No description provided for @originalInput.
  ///
  /// In en, this message translates to:
  /// **'Original input'**
  String get originalInput;

  /// No description provided for @referenceContent.
  ///
  /// In en, this message translates to:
  /// **'Reference content'**
  String get referenceContent;

  /// No description provided for @referenceWithTitle.
  ///
  /// In en, this message translates to:
  /// **'Reference: {title}'**
  String referenceWithTitle(Object title);

  /// No description provided for @discoveredTodoActions.
  ///
  /// In en, this message translates to:
  /// **'Discovered todo actions'**
  String get discoveredTodoActions;

  /// No description provided for @noPendingActions.
  ///
  /// In en, this message translates to:
  /// **'No pending actions'**
  String get noPendingActions;

  /// No description provided for @askSomethingHint.
  ///
  /// In en, this message translates to:
  /// **'Ask something...'**
  String get askSomethingHint;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @footprintMap.
  ///
  /// In en, this message translates to:
  /// **'Footprint map'**
  String get footprintMap;

  /// No description provided for @waypointPlaces.
  ///
  /// In en, this message translates to:
  /// **'Waypoint places'**
  String get waypointPlaces;

  /// No description provided for @unknownPlace.
  ///
  /// In en, this message translates to:
  /// **'Unknown place'**
  String get unknownPlace;

  /// No description provided for @loadFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'Load failed, please retry.'**
  String get loadFailedRetry;

  /// No description provided for @noRecordsInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No records in this period.'**
  String get noRecordsInPeriod;

  /// No description provided for @releaseToSend.
  ///
  /// In en, this message translates to:
  /// **'Release to send'**
  String get releaseToSend;

  /// No description provided for @selectFromAlbum.
  ///
  /// In en, this message translates to:
  /// **'Select from album'**
  String get selectFromAlbum;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @enterContentOrMediaHint.
  ///
  /// In en, this message translates to:
  /// **'Enter content, select image or record audio.'**
  String get enterContentOrMediaHint;

  /// No description provided for @tellAiWhatHappened.
  ///
  /// In en, this message translates to:
  /// **'Tell AI what happened...'**
  String get tellAiWhatHappened;

  /// No description provided for @recordingWithDuration.
  ///
  /// In en, this message translates to:
  /// **'Recording: {duration}'**
  String recordingWithDuration(Object duration);

  /// No description provided for @playing.
  ///
  /// In en, this message translates to:
  /// **'Playing...'**
  String get playing;

  /// No description provided for @recordedAudio.
  ///
  /// In en, this message translates to:
  /// **'Recorded audio'**
  String get recordedAudio;

  /// No description provided for @recordLabel.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get recordLabel;

  /// No description provided for @smartSuggesting.
  ///
  /// In en, this message translates to:
  /// **'Smart suggesting...'**
  String get smartSuggesting;

  /// No description provided for @noTaskData.
  ///
  /// In en, this message translates to:
  /// **'No task data'**
  String get noTaskData;

  /// No description provided for @createdAtDate.
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String createdAtDate(Object date);

  /// No description provided for @updatedAtDate.
  ///
  /// In en, this message translates to:
  /// **'Updated: {date}'**
  String updatedAtDate(Object date);

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration: {duration}'**
  String durationLabel(Object duration);

  /// No description provided for @retryCount.
  ///
  /// In en, this message translates to:
  /// **'Retry: {count}'**
  String retryCount(Object count);

  /// No description provided for @aiMaterialProcessFailed.
  ///
  /// In en, this message translates to:
  /// **'AI material process failed'**
  String get aiMaterialProcessFailed;

  /// No description provided for @aiMaterialProcessDone.
  ///
  /// In en, this message translates to:
  /// **'AI material process done'**
  String get aiMaterialProcessDone;

  /// No description provided for @aiOrganizingMaterial.
  ///
  /// In en, this message translates to:
  /// **'AI is organizing material'**
  String get aiOrganizingMaterial;

  /// No description provided for @taskCompletedAddedToTimeline.
  ///
  /// In en, this message translates to:
  /// **'Task completed, card added to Timeline'**
  String get taskCompletedAddedToTimeline;

  /// No description provided for @processErrorRetryLater.
  ///
  /// In en, this message translates to:
  /// **'Some errors occurred, please retry later.'**
  String get processErrorRetryLater;

  /// No description provided for @loadDetailFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'Load detail failed, please retry later.'**
  String get loadDetailFailedRetry;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Load failed'**
  String get loadFailed;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @aiInsightDetail.
  ///
  /// In en, this message translates to:
  /// **'AI Insight Detail'**
  String get aiInsightDetail;

  /// No description provided for @relatedRecordsCount.
  ///
  /// In en, this message translates to:
  /// **'Related records ({count})'**
  String relatedRecordsCount(Object count);

  /// No description provided for @noRelatedRecords.
  ///
  /// In en, this message translates to:
  /// **'No related records'**
  String get noRelatedRecords;

  /// No description provided for @useFingerprintToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint to unlock'**
  String get useFingerprintToUnlock;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get wrongPassword;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @memexLocked.
  ///
  /// In en, this message translates to:
  /// **'Memex is locked'**
  String get memexLocked;

  /// No description provided for @calendarShortSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get calendarShortSun;

  /// No description provided for @calendarShortMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get calendarShortMon;

  /// No description provided for @calendarShortTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get calendarShortTue;

  /// No description provided for @calendarShortWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get calendarShortWed;

  /// No description provided for @calendarShortThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get calendarShortThu;

  /// No description provided for @calendarShortFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get calendarShortFri;

  /// No description provided for @calendarShortSat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get calendarShortSat;

  /// No description provided for @noRecordsOnDate.
  ///
  /// In en, this message translates to:
  /// **'No records on {date}'**
  String noRecordsOnDate(Object date);

  /// No description provided for @footprintPath.
  ///
  /// In en, this message translates to:
  /// **'Footprint path'**
  String get footprintPath;

  /// No description provided for @lifeCompositionTable.
  ///
  /// In en, this message translates to:
  /// **'Life composition'**
  String get lifeCompositionTable;

  /// No description provided for @emotionReframe.
  ///
  /// In en, this message translates to:
  /// **'Emotion reframe'**
  String get emotionReframe;

  /// No description provided for @chronicleOfThings.
  ///
  /// In en, this message translates to:
  /// **'Chronicle of things'**
  String get chronicleOfThings;

  /// No description provided for @goalProgress.
  ///
  /// In en, this message translates to:
  /// **'Goal progress'**
  String get goalProgress;

  /// No description provided for @trendChart.
  ///
  /// In en, this message translates to:
  /// **'Trend chart'**
  String get trendChart;

  /// No description provided for @comparisonChart.
  ///
  /// In en, this message translates to:
  /// **'Comparison chart'**
  String get comparisonChart;

  /// No description provided for @todayTimeFlow.
  ///
  /// In en, this message translates to:
  /// **'Today\'s time flow'**
  String get todayTimeFlow;

  /// No description provided for @insightAssistant.
  ///
  /// In en, this message translates to:
  /// **'Insight assistant'**
  String get insightAssistant;

  /// No description provided for @insightInputHint.
  ///
  /// In en, this message translates to:
  /// **'What would you like to know about your knowledge...'**
  String get insightInputHint;

  /// No description provided for @aiInputHint.
  ///
  /// In en, this message translates to:
  /// **'Whether it\'s memories or the present, I\'m here...'**
  String get aiInputHint;

  /// No description provided for @noContentInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No content in this period'**
  String get noContentInPeriod;

  /// No description provided for @nothingHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get nothingHere;

  /// No description provided for @nothingHereHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to create your first card'**
  String get nothingHereHint;

  /// No description provided for @noPendingActionsToast.
  ///
  /// In en, this message translates to:
  /// **'No pending actions'**
  String get noPendingActionsToast;

  /// No description provided for @knowledgeNewDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Knowledge new discovery'**
  String get knowledgeNewDiscovery;

  /// No description provided for @discoveredNewInsightsCount.
  ///
  /// In en, this message translates to:
  /// **'Discovered {count} new insight(s)'**
  String discoveredNewInsightsCount(Object count);

  /// No description provided for @updatedExistingInsightsCount.
  ///
  /// In en, this message translates to:
  /// **'Updated {count} existing insight(s)'**
  String updatedExistingInsightsCount(Object count);

  /// No description provided for @sectionNewInsights.
  ///
  /// In en, this message translates to:
  /// **'New insights'**
  String get sectionNewInsights;

  /// No description provided for @sectionUpdatedInsights.
  ///
  /// In en, this message translates to:
  /// **'Updated insights'**
  String get sectionUpdatedInsights;

  /// No description provided for @unnamedInsight.
  ///
  /// In en, this message translates to:
  /// **'Unnamed insight'**
  String get unnamedInsight;

  /// No description provided for @loadDirectoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load directory: {error}'**
  String loadDirectoryFailed(Object error);

  /// No description provided for @readFileFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to read file: {error}'**
  String readFileFailed(Object error);

  /// No description provided for @backToParent.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backToParent;

  /// No description provided for @directoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Directory is empty'**
  String get directoryEmpty;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @binaryFile.
  ///
  /// In en, this message translates to:
  /// **'Binary file'**
  String get binaryFile;

  /// No description provided for @fileSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'File size: {size}'**
  String fileSizeLabel(Object size);

  /// No description provided for @selectedLocation.
  ///
  /// In en, this message translates to:
  /// **'Selected location'**
  String get selectedLocation;

  /// No description provided for @confirmLocationName.
  ///
  /// In en, this message translates to:
  /// **'Confirm location name'**
  String get confirmLocationName;

  /// No description provided for @confirmLocationNameHint.
  ///
  /// In en, this message translates to:
  /// **'You can edit the name (coordinates stay the same)'**
  String get confirmLocationNameHint;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @inputPlaceNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter place name...'**
  String get inputPlaceNameHint;

  /// No description provided for @currentCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates: {lat}, {lng}'**
  String currentCoordinates(Object lat, Object lng);

  /// No description provided for @confirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm location'**
  String get confirmLocation;

  /// No description provided for @userCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'User created successfully!'**
  String get userCreatedSuccess;

  /// No description provided for @welcomeToMemex.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Memex'**
  String get welcomeToMemex;

  /// No description provided for @createUserIdToStart.
  ///
  /// In en, this message translates to:
  /// **'Create your profile'**
  String get createUserIdToStart;

  /// No description provided for @userIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Name / Nickname'**
  String get userIdLabel;

  /// No description provided for @userIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name or nickname'**
  String get userIdHint;

  /// No description provided for @pleaseEnterUserId.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterUserId;

  /// No description provided for @userIdMinLength.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 1 character'**
  String get userIdMinLength;

  /// No description provided for @userIdMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Name must not exceed 50 characters'**
  String get userIdMaxLength;

  /// No description provided for @userIdFormat.
  ///
  /// In en, this message translates to:
  /// **'Name format is incorrect'**
  String get userIdFormat;

  /// No description provided for @startUsing.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get startUsing;

  /// No description provided for @userIdTip.
  ///
  /// In en, this message translates to:
  /// **'This will be used to personalize your experience.'**
  String get userIdTip;

  /// No description provided for @openAiAuthInfo.
  ///
  /// In en, this message translates to:
  /// **'OpenAI auth info'**
  String get openAiAuthInfo;

  /// No description provided for @setupModelConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect Your AI Brain'**
  String get setupModelConfigTitle;

  /// No description provided for @setupModelConfigSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Memex needs an AI model to process your memories and insights. Please configure your preferred provider.'**
  String get setupModelConfigSubtitle;

  /// No description provided for @setupModelConfigComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete & Go'**
  String get setupModelConfigComplete;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @modelAuth.
  ///
  /// In en, this message translates to:
  /// **'Model auth'**
  String get modelAuth;

  /// No description provided for @clearAuth.
  ///
  /// In en, this message translates to:
  /// **'Clear auth'**
  String get clearAuth;

  /// No description provided for @openAiAuthCleared.
  ///
  /// In en, this message translates to:
  /// **'OpenAI auth cleared'**
  String get openAiAuthCleared;

  /// No description provided for @authorizing.
  ///
  /// In en, this message translates to:
  /// **'Authorizing...'**
  String get authorizing;

  /// No description provided for @openAiAuthSuccess.
  ///
  /// In en, this message translates to:
  /// **'OpenAI auth success! AccountId: {accountId}'**
  String openAiAuthSuccess(Object accountId);

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Auth failed: {error}'**
  String authFailed(Object error);

  /// No description provided for @authorized.
  ///
  /// In en, this message translates to:
  /// **'Authorized'**
  String get authorized;

  /// No description provided for @viewAuthInfo.
  ///
  /// In en, this message translates to:
  /// **'View auth info'**
  String get viewAuthInfo;

  /// No description provided for @config.
  ///
  /// In en, this message translates to:
  /// **'Config'**
  String get config;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @writeToSystemFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to write to system'**
  String get writeToSystemFailed;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'{name} permission required'**
  String permissionRequired(Object name);

  /// No description provided for @permissionRationale.
  ///
  /// In en, this message translates to:
  /// **'Please allow the app to access your {name} in Settings so we can create it for you.'**
  String permissionRationale(Object name);

  /// No description provided for @goToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get goToSettings;

  /// No description provided for @unknownAction.
  ///
  /// In en, this message translates to:
  /// **'Unknown action'**
  String get unknownAction;

  /// No description provided for @discoveredCalendarEvent.
  ///
  /// In en, this message translates to:
  /// **'Calendar event found'**
  String get discoveredCalendarEvent;

  /// No description provided for @discoveredReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder found'**
  String get discoveredReminder;

  /// No description provided for @addToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to calendar'**
  String get addToCalendar;

  /// No description provided for @addToReminders.
  ///
  /// In en, this message translates to:
  /// **'Add to reminders'**
  String get addToReminders;

  /// No description provided for @addedToSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully added to {target}'**
  String addedToSuccess(Object target);

  /// No description provided for @ignore.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get ignore;

  /// No description provided for @appLockOn.
  ///
  /// In en, this message translates to:
  /// **'App lock enabled'**
  String get appLockOn;

  /// No description provided for @appLockOff.
  ///
  /// In en, this message translates to:
  /// **'App lock disabled'**
  String get appLockOff;

  /// No description provided for @enableAppLockFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enable app lock first'**
  String get enableAppLockFirst;

  /// No description provided for @enterFourDigitPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter 4-digit password'**
  String get enterFourDigitPassword;

  /// No description provided for @passwordSetAndLockOn.
  ///
  /// In en, this message translates to:
  /// **'Password set and app lock enabled'**
  String get passwordSetAndLockOn;

  /// No description provided for @appLockSettings.
  ///
  /// In en, this message translates to:
  /// **'App lock settings'**
  String get appLockSettings;

  /// No description provided for @enableAppLock.
  ///
  /// In en, this message translates to:
  /// **'Enable app lock'**
  String get enableAppLock;

  /// No description provided for @enableAppLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Password required when launching the app'**
  String get enableAppLockSubtitle;

  /// No description provided for @enableBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Enable biometrics'**
  String get enableBiometrics;

  /// No description provided for @biometricsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use Face ID or Touch ID to unlock'**
  String get biometricsSubtitle;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @setFourDigitPassword.
  ///
  /// In en, this message translates to:
  /// **'Set 4-digit password'**
  String get setFourDigitPassword;

  /// No description provided for @reenterPasswordToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password to confirm'**
  String get reenterPasswordToConfirm;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match. Please try again.'**
  String get passwordMismatch;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm delete'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteSessionMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this conversation? This cannot be undone.'**
  String get confirmDeleteSessionMessage;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get deleteSuccess;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed: {error}'**
  String deleteFailed(Object error);

  /// No description provided for @continueChat.
  ///
  /// In en, this message translates to:
  /// **'Continue conversation...'**
  String get continueChat;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(Object count);

  /// No description provided for @chatHistory.
  ///
  /// In en, this message translates to:
  /// **'Chat history'**
  String get chatHistory;

  /// No description provided for @noConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations'**
  String get noConversations;

  /// No description provided for @loadSessionListFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load session list: {error}'**
  String loadSessionListFailed(Object error);

  /// No description provided for @yesterdayAt.
  ///
  /// In en, this message translates to:
  /// **'Yesterday {time}'**
  String yesterdayAt(Object time);

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get newChat;

  /// No description provided for @messageCount.
  ///
  /// In en, this message translates to:
  /// **'{count} messages'**
  String messageCount(Object count);

  /// No description provided for @organize.
  ///
  /// In en, this message translates to:
  /// **'Organize'**
  String get organize;

  /// No description provided for @pkmCategoryProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get pkmCategoryProject;

  /// No description provided for @pkmCategoryProjectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Short-term · Goals · Deadlines'**
  String get pkmCategoryProjectSubtitle;

  /// No description provided for @pkmCategoryArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get pkmCategoryArea;

  /// No description provided for @pkmCategoryAreaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Long-term · Responsibility · Standards'**
  String get pkmCategoryAreaSubtitle;

  /// No description provided for @pkmCategoryResource.
  ///
  /// In en, this message translates to:
  /// **'Resource'**
  String get pkmCategoryResource;

  /// No description provided for @pkmCategoryResourceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Interests · Inspiration · Reserve'**
  String get pkmCategoryResourceSubtitle;

  /// No description provided for @pkmCategoryArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get pkmCategoryArchive;

  /// No description provided for @pkmCategoryArchiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Done · Dormant · Reference'**
  String get pkmCategoryArchiveSubtitle;

  /// No description provided for @recentChanges.
  ///
  /// In en, this message translates to:
  /// **'Recent changes'**
  String get recentChanges;

  /// No description provided for @noRecentChangesInThreeDays.
  ///
  /// In en, this message translates to:
  /// **'No changes in the last 3 days'**
  String get noRecentChangesInThreeDays;

  /// No description provided for @unpinned.
  ///
  /// In en, this message translates to:
  /// **'Unpinned'**
  String get unpinned;

  /// No description provided for @pinnedStyle.
  ///
  /// In en, this message translates to:
  /// **'Style pinned'**
  String get pinnedStyle;

  /// No description provided for @operationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed: {error}'**
  String operationFailed(Object error);

  /// No description provided for @refreshingInsightData.
  ///
  /// In en, this message translates to:
  /// **'Refreshing insight data, this may take a moment...'**
  String get refreshingInsightData;

  /// No description provided for @refreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Refresh failed: {error}'**
  String refreshFailed(Object error);

  /// No description provided for @sortUpdated.
  ///
  /// In en, this message translates to:
  /// **'Sort order updated'**
  String get sortUpdated;

  /// No description provided for @sortSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save sort: {error}'**
  String sortSaveFailed(Object error);

  /// No description provided for @insightCardDeleted.
  ///
  /// In en, this message translates to:
  /// **'Insight card deleted'**
  String get insightCardDeleted;

  /// No description provided for @deleteFailedShort.
  ///
  /// In en, this message translates to:
  /// **'Delete failed: {error}'**
  String deleteFailedShort(Object error);

  /// No description provided for @aboutThisInsightHint.
  ///
  /// In en, this message translates to:
  /// **'What would you like to know about this insight...'**
  String get aboutThisInsightHint;

  /// No description provided for @knowledgeInsight.
  ///
  /// In en, this message translates to:
  /// **'Knowledge insight'**
  String get knowledgeInsight;

  /// No description provided for @completeSort.
  ///
  /// In en, this message translates to:
  /// **'Complete sort'**
  String get completeSort;

  /// No description provided for @noKnowledgeInsight.
  ///
  /// In en, this message translates to:
  /// **'No knowledge insight'**
  String get noKnowledgeInsight;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updating;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @confirmDeleteCharacter.
  ///
  /// In en, this message translates to:
  /// **'Delete character \"{name}\"? This cannot be undone.'**
  String confirmDeleteCharacter(Object name);

  /// No description provided for @configureAiCharacter.
  ///
  /// In en, this message translates to:
  /// **'Configure AI character'**
  String get configureAiCharacter;

  /// No description provided for @addCharacter.
  ///
  /// In en, this message translates to:
  /// **'Add character'**
  String get addCharacter;

  /// No description provided for @addCharacterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose AI characters to join your insight team. They will analyze your life data from different angles.'**
  String get addCharacterSubtitle;

  /// No description provided for @noCharacters.
  ///
  /// In en, this message translates to:
  /// **'No characters'**
  String get noCharacters;

  /// No description provided for @loadCharacterFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load characters: {error}'**
  String loadCharacterFailed(Object error);

  /// No description provided for @characterDesignerHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the character you want to create or update...'**
  String get characterDesignerHint;

  /// No description provided for @characterDesigner.
  ///
  /// In en, this message translates to:
  /// **'Character designer'**
  String get characterDesigner;

  /// No description provided for @noTags.
  ///
  /// In en, this message translates to:
  /// **'No tags'**
  String get noTags;

  /// No description provided for @createSuccess.
  ///
  /// In en, this message translates to:
  /// **'Created successfully'**
  String get createSuccess;

  /// No description provided for @updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully'**
  String get updateSuccess;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String saveFailed(Object error);

  /// No description provided for @newCharacter.
  ///
  /// In en, this message translates to:
  /// **'New character'**
  String get newCharacter;

  /// No description provided for @editCharacter.
  ///
  /// In en, this message translates to:
  /// **'Edit character'**
  String get editCharacter;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @characterName.
  ///
  /// In en, this message translates to:
  /// **'Character name'**
  String get characterName;

  /// No description provided for @characterNameHint.
  ///
  /// In en, this message translates to:
  /// **'Give your character a name'**
  String get characterNameHint;

  /// No description provided for @pleaseEnterCharacterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter character name'**
  String get pleaseEnterCharacterName;

  /// No description provided for @tagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsLabel;

  /// No description provided for @tagsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. wisdom, recognition, macro\nSeparate multiple tags with commas'**
  String get tagsHint;

  /// No description provided for @characterPersonaLabel.
  ///
  /// In en, this message translates to:
  /// **'Character persona'**
  String get characterPersonaLabel;

  /// No description provided for @characterPersonaHint.
  ///
  /// In en, this message translates to:
  /// **'Include persona, style guide, example dialogue, knowledge filters, etc.\nUse ## for section headers.'**
  String get characterPersonaHint;

  /// No description provided for @pleaseEnterCharacterPersona.
  ///
  /// In en, this message translates to:
  /// **'Please enter character persona'**
  String get pleaseEnterCharacterPersona;

  /// No description provided for @systemFeaturesAndExtensions.
  ///
  /// In en, this message translates to:
  /// **'System features & extensions'**
  String get systemFeaturesAndExtensions;

  /// No description provided for @shareExtensionTitle.
  ///
  /// In en, this message translates to:
  /// **'Share extension'**
  String get shareExtensionTitle;

  /// No description provided for @shareExtensionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share content to the app from system share sheet'**
  String get shareExtensionSubtitle;

  /// No description provided for @screenTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Screen Time (Screen Time API)'**
  String get screenTimeTitle;

  /// No description provided for @screenTimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access app usage and attention data'**
  String get screenTimeSubtitle;

  /// No description provided for @permissionRequestError.
  ///
  /// In en, this message translates to:
  /// **'Permission request error: {error}'**
  String permissionRequestError(Object error);

  /// No description provided for @permissionRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Permission required'**
  String get permissionRequiredTitle;

  /// No description provided for @permissionPermanentlyDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have permanently denied this permission or the system requires it. Please enable it in system settings.'**
  String get permissionPermanentlyDeniedMessage;

  /// No description provided for @getting.
  ///
  /// In en, this message translates to:
  /// **'Getting...'**
  String get getting;

  /// No description provided for @unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized'**
  String get unauthorized;

  /// No description provided for @authorizedGoToSettings.
  ///
  /// In en, this message translates to:
  /// **'Authorized. Go to system settings to change.'**
  String get authorizedGoToSettings;

  /// No description provided for @goToSettingsShort.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get goToSettingsShort;

  /// No description provided for @basicPermissions.
  ///
  /// In en, this message translates to:
  /// **'Basic permissions'**
  String get basicPermissions;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @locationPermissionReason.
  ///
  /// In en, this message translates to:
  /// **'For recording places and location-related features'**
  String get locationPermissionReason;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @photosPermissionReason.
  ///
  /// In en, this message translates to:
  /// **'For selecting photos, saving generated images, etc.'**
  String get photosPermissionReason;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @cameraPermissionReason.
  ///
  /// In en, this message translates to:
  /// **'For taking photos and videos'**
  String get cameraPermissionReason;

  /// No description provided for @microphone.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get microphone;

  /// No description provided for @microphonePermissionReason.
  ///
  /// In en, this message translates to:
  /// **'For voice recognition, recording, etc.'**
  String get microphonePermissionReason;

  /// No description provided for @calendarPermissionReason.
  ///
  /// In en, this message translates to:
  /// **'For recording schedule and reading calendar events'**
  String get calendarPermissionReason;

  /// No description provided for @remindersPermissionReason.
  ///
  /// In en, this message translates to:
  /// **'For recording and reading your reminders'**
  String get remindersPermissionReason;

  /// No description provided for @fitnessAndMotion.
  ///
  /// In en, this message translates to:
  /// **'Fitness & motion'**
  String get fitnessAndMotion;

  /// No description provided for @fitnessPermissionReason.
  ///
  /// In en, this message translates to:
  /// **'For recording health and motion data'**
  String get fitnessPermissionReason;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @notificationPermissionReason.
  ///
  /// In en, this message translates to:
  /// **'For sending schedule and important reminders'**
  String get notificationPermissionReason;

  /// No description provided for @loadDetailFailedRetryShort.
  ///
  /// In en, this message translates to:
  /// **'Load detail failed, please retry later.'**
  String get loadDetailFailedRetryShort;

  /// No description provided for @llmCallStats.
  ///
  /// In en, this message translates to:
  /// **'LLM call stats'**
  String get llmCallStats;

  /// No description provided for @noLlmCallRecords.
  ///
  /// In en, this message translates to:
  /// **'No LLM call records'**
  String get noLlmCallRecords;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @callCount.
  ///
  /// In en, this message translates to:
  /// **'Call count'**
  String get callCount;

  /// No description provided for @estimatedCost.
  ///
  /// In en, this message translates to:
  /// **'Estimated cost'**
  String get estimatedCost;

  /// No description provided for @byAgent.
  ///
  /// In en, this message translates to:
  /// **'By Agent'**
  String get byAgent;

  /// No description provided for @cardGenerationAgent.
  ///
  /// In en, this message translates to:
  /// **'Card generation Agent'**
  String get cardGenerationAgent;

  /// No description provided for @knowledgeOrgAgent.
  ///
  /// In en, this message translates to:
  /// **'Knowledge org Agent'**
  String get knowledgeOrgAgent;

  /// No description provided for @commentGenerationAgent.
  ///
  /// In en, this message translates to:
  /// **'Comment generation Agent'**
  String get commentGenerationAgent;

  /// No description provided for @timeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Time updated'**
  String get timeUpdated;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {error}'**
  String updateFailed(Object error);

  /// No description provided for @locationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Location updated'**
  String get locationUpdated;

  /// No description provided for @confirmDeleteCardMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this card? This cannot be undone.'**
  String get confirmDeleteCardMessage;

  /// No description provided for @profileAgent.
  ///
  /// In en, this message translates to:
  /// **'Profile Agent'**
  String get profileAgent;

  /// No description provided for @assetAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Asset analysis'**
  String get assetAnalysis;

  /// No description provided for @cardDetailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Card detail not found'**
  String get cardDetailNotFound;

  /// No description provided for @saySomething.
  ///
  /// In en, this message translates to:
  /// **'Say something...'**
  String get saySomething;

  /// No description provided for @relatedMemories.
  ///
  /// In en, this message translates to:
  /// **'Related memories'**
  String get relatedMemories;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View more'**
  String get viewMore;

  /// No description provided for @relatedRecords.
  ///
  /// In en, this message translates to:
  /// **'Related records'**
  String get relatedRecords;

  /// No description provided for @replySent.
  ///
  /// In en, this message translates to:
  /// **'Reply sent'**
  String get replySent;

  /// No description provided for @insightTemplateGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Insight card templates'**
  String get insightTemplateGalleryTitle;

  /// No description provided for @timelineTemplateGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Timeline card templates'**
  String get timelineTemplateGalleryTitle;

  /// No description provided for @categoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get categoryGeneral;

  /// No description provided for @categoryTextual.
  ///
  /// In en, this message translates to:
  /// **'Textual'**
  String get categoryTextual;

  /// No description provided for @k411.
  ///
  /// In en, this message translates to:
  /// **'## 什么是心流？  心流（Flow）是由心理学家米哈里·契克森米哈提出的一种心理状态。当你完全沉浸在一项具有挑战性但可完成的任务中，时间感消失，注意力高度集中，这就是心流。  > 人在做感兴趣的事情时，常常浑然忘我。  研究发现，心流状态下的人往往生产力最高，幸福感也最强。'**
  String get k411;

  /// No description provided for @timelineFilterAll.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get timelineFilterAll;

  /// No description provided for @timelineDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get timelineDays;

  /// No description provided for @timelineWeeks.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get timelineWeeks;

  /// No description provided for @timelineMonths.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get timelineMonths;

  /// No description provided for @timelineYears.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get timelineYears;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @memoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get memoryTitle;

  /// No description provided for @longTermProfile.
  ///
  /// In en, this message translates to:
  /// **'Long-term Profile'**
  String get longTermProfile;

  /// No description provided for @recentBuffer.
  ///
  /// In en, this message translates to:
  /// **'Recent Buffer'**
  String get recentBuffer;

  /// No description provided for @errorLoadingMemory.
  ///
  /// In en, this message translates to:
  /// **'Error loading memory: {error}'**
  String errorLoadingMemory(Object error);

  /// No description provided for @agentConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Agent Configuration'**
  String get agentConfiguration;

  /// No description provided for @resetToDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get resetToDefaults;

  /// No description provided for @resetAllAgentConfigurationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset All Agent Configurations'**
  String get resetAllAgentConfigurationsTitle;

  /// No description provided for @resetAllAgentConfigurationsMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all agent configurations to their default values? This action cannot be undone.'**
  String get resetAllAgentConfigurationsMessage;

  /// No description provided for @resetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetButton;

  /// No description provided for @loadDataFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data: {error}'**
  String loadDataFailed(Object error);

  /// No description provided for @saveConfigFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save config: {error}'**
  String saveConfigFailed(Object error);

  /// No description provided for @selectLlmClient.
  ///
  /// In en, this message translates to:
  /// **'Select LLM Client:'**
  String get selectLlmClient;

  /// No description provided for @agentConfigurationsReset.
  ///
  /// In en, this message translates to:
  /// **'Agent configurations reset'**
  String get agentConfigurationsReset;

  /// No description provided for @resetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset: {error}'**
  String resetFailed(Object error);

  /// No description provided for @modelConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Model Configuration'**
  String get modelConfiguration;

  /// No description provided for @resetAllConfigurationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset All Configurations'**
  String get resetAllConfigurationsTitle;

  /// No description provided for @resetAllModelConfigurationsMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all model configurations to their default values? This action cannot be undone.'**
  String get resetAllModelConfigurationsMessage;

  /// No description provided for @modelConfigurationsReset.
  ///
  /// In en, this message translates to:
  /// **'Model configurations reset'**
  String get modelConfigurationsReset;

  /// No description provided for @cannotDeleteDefaultConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete default configuration'**
  String get cannotDeleteDefaultConfiguration;

  /// No description provided for @cannotDeleteConfigurationTitle.
  ///
  /// In en, this message translates to:
  /// **'Cannot Delete Configuration'**
  String get cannotDeleteConfigurationTitle;

  /// No description provided for @configUsedByAgentsMessage.
  ///
  /// In en, this message translates to:
  /// **'This configuration is currently used by the following agents:\n\n{agentList}\n\nPlease reassign these agents before deleting.'**
  String configUsedByAgentsMessage(Object agentList);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @deleteConfigurationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Configuration'**
  String get deleteConfigurationTitle;

  /// No description provided for @confirmDeleteConfigMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{key}\"?'**
  String confirmDeleteConfigMessage(Object key);

  /// No description provided for @defaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @missingApiKey.
  ///
  /// In en, this message translates to:
  /// **'Missing API Key'**
  String get missingApiKey;

  /// No description provided for @invalidJsonInExtraField.
  ///
  /// In en, this message translates to:
  /// **'Invalid JSON in Extra field'**
  String get invalidJsonInExtraField;

  /// No description provided for @keyAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Key already exists'**
  String get keyAlreadyExists;

  /// No description provided for @resetConfigurationTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Configuration'**
  String get resetConfigurationTitle;

  /// No description provided for @resetConfigurationMessage.
  ///
  /// In en, this message translates to:
  /// **'Reset this configuration to its initial default values? Current changes will be lost.'**
  String get resetConfigurationMessage;

  /// No description provided for @configurationResetPressSave.
  ///
  /// In en, this message translates to:
  /// **'Configuration reset. Press Save to apply.'**
  String get configurationResetPressSave;

  /// No description provided for @addConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Add Configuration'**
  String get addConfiguration;

  /// No description provided for @editConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Edit Configuration'**
  String get editConfiguration;

  /// No description provided for @keyIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Key (ID)'**
  String get keyIdLabel;

  /// No description provided for @keyIdHelper.
  ///
  /// In en, this message translates to:
  /// **'Unique identifier for this configuration'**
  String get keyIdHelper;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @clientLabel.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get clientLabel;

  /// No description provided for @geminiClient.
  ///
  /// In en, this message translates to:
  /// **'Gemini'**
  String get geminiClient;

  /// No description provided for @chatCompletionClient.
  ///
  /// In en, this message translates to:
  /// **'OpenAI (ChatCompletion)'**
  String get chatCompletionClient;

  /// No description provided for @responsesClient.
  ///
  /// In en, this message translates to:
  /// **'OpenAI (Responses)'**
  String get responsesClient;

  /// No description provided for @bedrockClient.
  ///
  /// In en, this message translates to:
  /// **'Bedrock'**
  String get bedrockClient;

  /// No description provided for @modelIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Model ID'**
  String get modelIdLabel;

  /// No description provided for @modelIdHelper.
  ///
  /// In en, this message translates to:
  /// **'e.g. gemini-3.1-pro-preview, gpt-4o'**
  String get modelIdHelper;

  /// No description provided for @apiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKeyLabel;

  /// No description provided for @baseUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get baseUrlLabel;

  /// No description provided for @advancedSettings.
  ///
  /// In en, this message translates to:
  /// **'Advanced Settings'**
  String get advancedSettings;

  /// No description provided for @proxyUrlOptional.
  ///
  /// In en, this message translates to:
  /// **'Proxy URL (Optional)'**
  String get proxyUrlOptional;

  /// No description provided for @proxyUrlHelper.
  ///
  /// In en, this message translates to:
  /// **'e.g. http://127.0.0.1:7890'**
  String get proxyUrlHelper;

  /// No description provided for @temperatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperatureLabel;

  /// No description provided for @topPLabel.
  ///
  /// In en, this message translates to:
  /// **'Top P'**
  String get topPLabel;

  /// No description provided for @maxTokensLabel.
  ///
  /// In en, this message translates to:
  /// **'Max Tokens'**
  String get maxTokensLabel;

  /// No description provided for @extraParamsJson.
  ///
  /// In en, this message translates to:
  /// **'Extra Params (JSON)'**
  String get extraParamsJson;

  /// No description provided for @invalidJson.
  ///
  /// In en, this message translates to:
  /// **'Invalid JSON'**
  String get invalidJson;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @invalidConfigurationWarning.
  ///
  /// In en, this message translates to:
  /// **'The current configuration is invalid (e.g., missing API Key, Model ID, or Base URL). It may not work properly. Do you want to save anyway?'**
  String get invalidConfigurationWarning;

  /// No description provided for @invalidModelConfigDetailed.
  ///
  /// In en, this message translates to:
  /// **'AI Agent \"{agentId}\" needs a valid model configuration (key: \"{configKey}\") to operate. Please check the model settings.'**
  String invalidModelConfigDetailed(Object agentId, Object configKey);

  /// No description provided for @discardChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard unsaved changes?'**
  String get discardChangesTitle;

  /// No description provided for @discardChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Are you sure you want to leave without saving?'**
  String get discardChangesMessage;

  /// No description provided for @discardButton.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardButton;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @chooseAvatar.
  ///
  /// In en, this message translates to:
  /// **'Choose Avatar'**
  String get chooseAvatar;

  /// No description provided for @coachMarkFirstPost.
  ///
  /// In en, this message translates to:
  /// **'Tap here to capture your first thought ✨'**
  String get coachMarkFirstPost;

  /// No description provided for @coachMarkInsightRefresh.
  ///
  /// In en, this message translates to:
  /// **'Tap to generate insights from your records 🔮'**
  String get coachMarkInsightRefresh;

  /// No description provided for @coachMarkConfigureModel.
  ///
  /// In en, this message translates to:
  /// **'Set up your AI model first to unlock all features 🔑'**
  String get coachMarkConfigureModel;

  /// No description provided for @configureNow.
  ///
  /// In en, this message translates to:
  /// **'Configure Now'**
  String get configureNow;

  /// No description provided for @modelNotConfiguredBanner.
  ///
  /// In en, this message translates to:
  /// **'AI model not configured yet. Set it up to unlock all features.'**
  String get modelNotConfiguredBanner;

  /// No description provided for @modelNotConfiguredSubmitHint.
  ///
  /// In en, this message translates to:
  /// **'Please configure an AI model before publishing'**
  String get modelNotConfiguredSubmitHint;

  /// No description provided for @processingStatus.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processingStatus;

  /// No description provided for @failedStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failedStatus;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @failureReason.
  ///
  /// In en, this message translates to:
  /// **'Failure Reason'**
  String get failureReason;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred'**
  String get unknownError;

  /// No description provided for @enableFitness.
  ///
  /// In en, this message translates to:
  /// **'Enable Fitness'**
  String get enableFitness;

  /// No description provided for @fitnessBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'Allow fitness access to track your health and activity data.'**
  String get fitnessBannerMessage;

  /// No description provided for @fitnessDismissTitle.
  ///
  /// In en, this message translates to:
  /// **'Skip Fitness Access?'**
  String get fitnessDismissTitle;

  /// No description provided for @fitnessDismissMessage.
  ///
  /// In en, this message translates to:
  /// **'Without fitness permission, the app won\'t be able to automatically collect your health data for insights and auto-recording.'**
  String get fitnessDismissMessage;

  /// No description provided for @skipAnyway.
  ///
  /// In en, this message translates to:
  /// **'Skip Anyway'**
  String get skipAnyway;

  /// No description provided for @proModelHint.
  ///
  /// In en, this message translates to:
  /// **'This model requires a ChatGPT Pro/Plus subscription.'**
  String get proModelHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
