// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get timesLabel => 'Times';

  @override
  String get recordSubmittedAiProcessing =>
      'Record submitted, AI is processing...';

  @override
  String modelSetAsDefault(Object modelId) {
    return 'Set $modelId as default model';
  }

  @override
  String loadModelListFailed(Object error) {
    return 'Failed to load model list: \n$error';
  }

  @override
  String get retry => 'Retry';

  @override
  String get noModelsFound => 'No models found';

  @override
  String get unknownModel => 'Unknown model';

  @override
  String get openAiModelConfig => 'OpenAI Model Config';

  @override
  String get notSet => 'Not set';

  @override
  String get confirmClear => 'Confirm clear';

  @override
  String get confirmClearTokenMessage =>
      'Clear current user? You will need to enter user ID again.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get tokenCleared => 'User cleared';

  @override
  String clearTokenFailed(Object error) {
    return 'Failed to clear user: $error';
  }

  @override
  String get reprocessKnowledgeBase => 'Reprocess knowledge base';

  @override
  String get selectDateRangeOptional => 'Select date range (optional):';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get select => 'Select';

  @override
  String get processLimitOptional => 'Process limit (optional)';

  @override
  String get leaveEmptyForAll => 'Leave empty to process all';

  @override
  String get startProcessing => 'Start processing';

  @override
  String get userIdNotFound => 'User ID not found';

  @override
  String get reprocessTaskCreated =>
      'Reprocess task created, running in background';

  @override
  String createTaskFailed(Object error) {
    return 'Failed to create task: $error';
  }

  @override
  String get reprocessCards => 'Reprocess cards';

  @override
  String get reprocessCardsTaskCreated =>
      'Reprocess cards task created, running in background';

  @override
  String get regenerateComments => 'Regenerate comments';

  @override
  String get regenerateCommentsTaskCreated =>
      'Regenerate comments task created, running in background';

  @override
  String get rebuildSearchIndex => 'Rebuild search index';

  @override
  String get rebuildSearchIndexSuccess => 'Search index rebuilt successfully';

  @override
  String get rebuildSearchIndexFailed => 'Failed to rebuild search index';

  @override
  String get clearData => 'Clear data';

  @override
  String get confirmClearDataMessage => 'Clear data?';

  @override
  String get confirmClearDataKeepFactsMessage =>
      'Only the Facts directory (raw input) will be kept. All other workspace directories (Cards, Discoveries, KnowledgeInsights, PKM, _System, etc.) will be deleted.\n\nThis action cannot be undone!';

  @override
  String get clearFailedAgentContexts => 'Clear failed conversation context';

  @override
  String get confirmClearFailedAgentContextsMessage =>
      'Clear the saved conversation context for Insight and Schedule agents? This is useful after changing models when previous agent messages are no longer compatible. Facts, cards, knowledge, memories, and model settings will not be deleted.';

  @override
  String failedAgentContextsCleared(Object count) {
    return 'Cleared $count saved conversation context(s)';
  }

  @override
  String clearFailedAgentContextsFailed(Object error) {
    return 'Failed to clear conversation context: $error';
  }

  @override
  String get dataClearedSuccess => 'Data cleared successfully';

  @override
  String clearDataFailed(Object error) {
    return 'Failed to clear data: $error';
  }

  @override
  String get personalCenter => 'Personal center';

  @override
  String get viewLogs => 'View logs';

  @override
  String get systemAuthorization => 'System authorization';

  @override
  String get modelAuthorization => 'Model authorization';

  @override
  String get pkmKnowledgeBase => 'PKM knowledge base';

  @override
  String get aiCharacterConfig => 'AI character config';

  @override
  String get appLockConfig => 'App lock config';

  @override
  String get modelConfig => 'Model config';

  @override
  String get agentConfig => 'Agent config';

  @override
  String get modelUsageStats => 'Model usage stats';

  @override
  String get asyncTaskList => 'Async task list';

  @override
  String get clearLocalToken => 'Clear user';

  @override
  String get insightCardTemplates => 'Insight card templates';

  @override
  String get timelineCardTemplates => 'Timeline card templates';

  @override
  String get logViewer => 'Log viewer';

  @override
  String get autoRefresh => 'Auto refresh';

  @override
  String get lineCount => 'Line count: ';

  @override
  String get all => 'All';

  @override
  String get schedule => 'Schedule';

  @override
  String get statistics => 'Stats';

  @override
  String get activityStats => 'Activity stats';

  @override
  String activityStatsSummary(Object inputs, Object cards, Object todos) {
    return 'In this period you recorded $inputs time(s), generated $cards card(s), and completed $todos todo(s).';
  }

  @override
  String get last7Days => '7 days';

  @override
  String get last30Days => '30 days';

  @override
  String get last90Days => '90 days';

  @override
  String get records => 'Records';

  @override
  String get words => 'Words';

  @override
  String get cards => 'Cards';

  @override
  String get knowledgeUnits => 'Knowledge units';

  @override
  String get completedTodos => 'Completed todos';

  @override
  String get activeDays => 'Active days';

  @override
  String get streakDays => 'Streak';

  @override
  String get dailyRhythm => 'Daily rhythm';

  @override
  String get recordToOutput => 'Record to output';

  @override
  String get sourceBreakdown => 'Source breakdown';

  @override
  String get topThemes => 'Top themes';

  @override
  String get textInput => 'Text';

  @override
  String get imageInput => 'Images';

  @override
  String get audioInput => 'Audio';

  @override
  String get noStatsYet => 'No activity stats yet';

  @override
  String get tapDayForDetails => 'Tap a day to view details';

  @override
  String get dayDetails => 'Day details';

  @override
  String loadStatsFailed(Object error) {
    return 'Failed to load stats: $error';
  }

  @override
  String get overview => 'Overview';

  @override
  String get daily => 'Daily';

  @override
  String get modelStatsByAgent => 'By agent';

  @override
  String get detail => 'Detail';

  @override
  String get date => 'Date';

  @override
  String get agent => 'Agent';

  @override
  String get noData => 'No data';

  @override
  String get totalCalls => 'Total calls';

  @override
  String get calls => 'Calls';

  @override
  String callsCount(Object count) {
    return '$count calls';
  }

  @override
  String get selectDateRange => 'Select date range';

  @override
  String get totalTokens => 'Total tokens';

  @override
  String get cacheRate => 'Cache rate';

  @override
  String get promptTokens => 'Prompt tokens';

  @override
  String get completionTokens => 'Completion tokens';

  @override
  String get cachedTokens => 'Cached tokens';

  @override
  String get thoughtTokens => 'Thought tokens';

  @override
  String get prompt => 'Prompt';

  @override
  String get completion => 'Completion';

  @override
  String get cached => 'Cached';

  @override
  String get thought => 'Thought';

  @override
  String get model => 'Model';

  @override
  String get scene => 'Scene';

  @override
  String get sceneId => 'Scene ID';

  @override
  String get tokenUsage => 'Token usage';

  @override
  String get handler => 'Handler';

  @override
  String get modelBreakdown => 'Model breakdown';

  @override
  String get callDetails => 'Call details';

  @override
  String recordDetailsTitle(Object scene) {
    return 'Record details: $scene';
  }

  @override
  String saveLlmConfigFailed(Object error) {
    return 'Failed to save LLM config: $error';
  }

  @override
  String get webHtmlPreviewUnavailable =>
      'HTML preview is not available on web. Please view on mobile.';

  @override
  String saveUserInfoFailed(Object error) {
    return 'Failed to save user info: $error';
  }

  @override
  String get totalEstimatedCost => 'Total estimated cost';

  @override
  String get detailSubtitle => 'Detail';

  @override
  String get close => 'Close';

  @override
  String get noFragments => 'No fragments';

  @override
  String get totalTokenConsumption => 'Total token consumption';

  @override
  String get dataLoadFailedRetry => 'Data load failed, please retry later.';

  @override
  String get timelineLoadFailedRetry =>
      'Timeline load failed, please retry later.';

  @override
  String get aggregatedLoadFailedRetry =>
      'Failed to load aggregated data, please retry later.';

  @override
  String get newPerspective => 'New perspective';

  @override
  String get startPoint => 'Start';

  @override
  String get endPoint => 'End';

  @override
  String get originalInput => 'Original input';

  @override
  String get referenceContent => 'Reference content';

  @override
  String referenceWithTitle(Object title) {
    return 'Reference: $title';
  }

  @override
  String get discoveredTodoActions => 'Discovered todo actions';

  @override
  String get actionCenterTitle => 'Pending actions';

  @override
  String get noPendingActions => 'No pending actions';

  @override
  String get clarificationNeeded => 'Memex wants to confirm';

  @override
  String get clarificationTextHint => 'Type a short answer';

  @override
  String get clarificationTextRequired => 'Add a short answer first';

  @override
  String get clarificationAnswered => 'Answered';

  @override
  String clarificationAnswerPrefix(Object answer) {
    return 'Answer: $answer';
  }

  @override
  String get answerSaved => 'Answer saved';

  @override
  String get clarificationOtherAnswer => 'Manual input';

  @override
  String get clarificationNotSure => 'Not sure / prefer not to say';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get askSomethingHint => 'Ask something...';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get footprintMap => 'Footprint map';

  @override
  String get waypointPlaces => 'Waypoint places';

  @override
  String get unknownPlace => 'Unknown place';

  @override
  String get loadFailedRetry => 'Load failed, please retry.';

  @override
  String get noRecordsInPeriod => 'No records in this period.';

  @override
  String get releaseToSend => 'Release to send';

  @override
  String get selectFromAlbum => 'Select from album';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get enterContentOrMediaHint =>
      'Enter content, select image or record audio.';

  @override
  String inputDraftLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Draft · $count chars',
      one: 'Draft · 1 char',
    );
    return '$_temp0';
  }

  @override
  String get discardDraftTitle => 'Discard this draft?';

  @override
  String get discardDraftMessage => 'The draft content will be cleared.';

  @override
  String get discardDraftTooltip => 'Discard draft';

  @override
  String get tellAiWhatHappened => 'Tell AI what happened...';

  @override
  String recordingWithDuration(Object duration) {
    return 'Recording: $duration';
  }

  @override
  String get playing => 'Playing...';

  @override
  String get recordedAudio => 'Recorded audio';

  @override
  String get recordLabel => 'Record';

  @override
  String get smartSuggesting => 'Smart suggesting...';

  @override
  String get noTaskData => 'No task data';

  @override
  String createdAtDate(Object date) {
    return 'Created: $date';
  }

  @override
  String updatedAtDate(Object date) {
    return 'Updated: $date';
  }

  @override
  String durationLabel(Object duration) {
    return 'Duration: $duration';
  }

  @override
  String retryCount(Object count) {
    return 'Retry: $count';
  }

  @override
  String get aiMaterialProcessFailed => 'AI material process failed';

  @override
  String get aiMaterialProcessDone => 'AI material process done';

  @override
  String get aiOrganizingMaterial => 'AI is organizing material';

  @override
  String get taskCompletedAddedToTimeline =>
      'Task completed, card added to Timeline';

  @override
  String get processErrorRetryLater =>
      'Some errors occurred, please retry later.';

  @override
  String get loadDetailFailedRetry => 'Load detail failed, please retry later.';

  @override
  String get loadFailed => 'Load failed';

  @override
  String get reload => 'Reload';

  @override
  String get aiInsightDetail => 'Insight Detail';

  @override
  String relatedRecordsCount(Object count) {
    return 'Related records ($count)';
  }

  @override
  String get noRelatedRecords => 'No related records';

  @override
  String get useFingerprintToUnlock => 'Use fingerprint to unlock';

  @override
  String get locked => 'Locked';

  @override
  String get wrongPassword => 'Wrong password';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get memexLocked => 'Memex is locked';

  @override
  String get calendarShortSun => 'Sun';

  @override
  String get calendarShortMon => 'Mon';

  @override
  String get calendarShortTue => 'Tue';

  @override
  String get calendarShortWed => 'Wed';

  @override
  String get calendarShortThu => 'Thu';

  @override
  String get calendarShortFri => 'Fri';

  @override
  String get calendarShortSat => 'Sat';

  @override
  String noRecordsOnDate(Object date) {
    return 'No records on $date';
  }

  @override
  String get footprintPath => 'Footprint path';

  @override
  String get lifeCompositionTable => 'Life composition';

  @override
  String get emotionReframe => 'Emotion reframe';

  @override
  String get chronicleOfThings => 'Chronicle of things';

  @override
  String get goalProgress => 'Goal progress';

  @override
  String get trendChart => 'Trend chart';

  @override
  String get comparisonChart => 'Comparison chart';

  @override
  String get todayTimeFlow => 'Today\'s time flow';

  @override
  String get insightAssistant => 'Insight assistant';

  @override
  String get insightInputHint =>
      'What would you like to know about your knowledge...';

  @override
  String get aiInputHint =>
      'Whether it\'s memories or the present, I\'m here...';

  @override
  String get noContentInPeriod => 'No content in this period';

  @override
  String get nothingHere => 'Nothing here yet';

  @override
  String get nothingHereHint =>
      'Tap the button below to create your first card';

  @override
  String get agentProcessing => 'AI is processing...';

  @override
  String get keepAppOpen => 'Don\'t close the app';

  @override
  String get activityDetail => 'Activity Detail';

  @override
  String get noAgentActivityYet => 'No agent activity yet';

  @override
  String get processingEllipsis => 'Processing...';

  @override
  String get settings => 'Settings';

  @override
  String get languageSettings => 'Language';

  @override
  String get languageSettingsDesc => 'Change the app display language';

  @override
  String get noPendingActionsToast => 'No pending actions';

  @override
  String get knowledgeNewDiscovery => 'Knowledge new discovery';

  @override
  String discoveredNewInsightsCount(Object count) {
    return 'Discovered $count new insight(s)';
  }

  @override
  String updatedExistingInsightsCount(Object count) {
    return 'Updated $count existing insight(s)';
  }

  @override
  String get sectionNewInsights => 'New insights';

  @override
  String get sectionUpdatedInsights => 'Updated insights';

  @override
  String get unnamedInsight => 'Unnamed insight';

  @override
  String loadDirectoryFailed(Object error) {
    return 'Failed to load directory: $error';
  }

  @override
  String readFileFailed(Object error) {
    return 'Failed to read file: $error';
  }

  @override
  String get backToParent => 'Back';

  @override
  String get directoryEmpty => 'Directory is empty';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get copy => 'Copy';

  @override
  String get binaryFile => 'Binary file';

  @override
  String fileSizeLabel(Object size) {
    return 'File size: $size';
  }

  @override
  String get selectedLocation => 'Selected location';

  @override
  String get confirmLocationName => 'Confirm location name';

  @override
  String get confirmLocationNameHint =>
      'You can edit the name (coordinates stay the same)';

  @override
  String get nameLabel => 'Name';

  @override
  String get inputPlaceNameHint => 'Enter place name...';

  @override
  String currentCoordinates(Object lat, Object lng) {
    return 'Coordinates: $lat, $lng';
  }

  @override
  String get confirmLocation => 'Confirm location';

  @override
  String get userCreatedSuccess => 'User created successfully!';

  @override
  String get welcomeToMemex => 'Welcome to Memex';

  @override
  String get createUserIdToStart => 'Create your profile';

  @override
  String get userIdLabel => 'Your Name / Nickname';

  @override
  String get userIdHint => 'Enter your name or nickname';

  @override
  String get pleaseEnterUserId => 'Please enter your name';

  @override
  String get userIdMinLength => 'Name must be at least 1 character';

  @override
  String get userIdMaxLength => 'Name must not exceed 50 characters';

  @override
  String get userIdFormat => 'Name format is incorrect';

  @override
  String get startUsing => 'Continue';

  @override
  String get userIdTip => 'This will be used to personalize your experience.';

  @override
  String get openAiAuthInfo => 'OpenAI auth info';

  @override
  String get setupModelConfigTitle => 'Connect Your AI Brain';

  @override
  String get setupModelConfigSubtitle =>
      'Memex needs an AI model to process your memories and insights. Please configure your preferred provider.';

  @override
  String get setupModelConfigComplete => 'Complete & Go';

  @override
  String get aiService => 'Memex Model Service';

  @override
  String get aiServiceTitle => 'The AI journal for your real life';

  @override
  String get aiServiceSubtitle =>
      'Turn scattered notes, photos, and voice records into a structured second brain.';

  @override
  String get aiServiceLongDescription =>
      'Memex uses a multi-agent system to organize life records, knowledge notes, and social context, discover deeper insights, and provide AI companionship with persistent memory. Your data is stored as plain-text Markdown, preserving data freedom and portability.';

  @override
  String get aiServiceCustomModelTitle => 'Connect your own AI model';

  @override
  String get aiServiceCustomModelDescription =>
      'If you are familiar with model APIs and can configure them yourself, we recommend using your own key. If not, you can top up our pay-as-you-go credit.';

  @override
  String get aiServiceStepAccount =>
      'One account manages credit, billing, and usage history.';

  @override
  String get aiServiceStepBalance =>
      'Pay as you go. Top up when balance runs low; no fixed monthly fee.';

  @override
  String get aiServiceStepEnable =>
      'Once enabled, text, photo, and voice records enter the AI organization queue.';

  @override
  String get enableAiService => 'Start using';

  @override
  String get aiServiceWaitingForPayment =>
      'Sign in and choose credit to turn on';

  @override
  String get aiServiceReadyToast => 'AI organization is on';

  @override
  String get aiServiceSettingsDescription =>
      'Manage AI organization, credit, and usage history.';

  @override
  String get advancedModelConfiguration => 'I want to connect my own AI model';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get modelAuth => 'Model auth';

  @override
  String get clearAuth => 'Clear auth';

  @override
  String get openAiAuthCleared => 'OpenAI auth cleared';

  @override
  String get authorizing => 'Authorizing...';

  @override
  String openAiAuthSuccess(Object accountId) {
    return 'OpenAI auth success! AccountId: $accountId';
  }

  @override
  String authFailed(Object error) {
    return 'Auth failed: $error';
  }

  @override
  String get authorized => 'Authorized';

  @override
  String get viewAuthInfo => 'View auth info';

  @override
  String get config => 'Config';

  @override
  String get calendar => 'Calendar';

  @override
  String get reminders => 'Reminders';

  @override
  String get writeToSystemFailed => 'Failed to write to system';

  @override
  String permissionRequired(Object name) {
    return '$name permission required';
  }

  @override
  String permissionRationale(Object name) {
    return 'Please allow the app to access your $name in Settings so we can create it for you.';
  }

  @override
  String get goToSettings => 'Go to Settings';

  @override
  String get unknownAction => 'Unknown action';

  @override
  String get discoveredCalendarEvent => 'Calendar event found';

  @override
  String get discoveredReminder => 'Reminder found';

  @override
  String get addToCalendar => 'Add to calendar';

  @override
  String get addToReminders => 'Add to reminders';

  @override
  String addedToSuccess(Object target) {
    return 'Successfully added to $target';
  }

  @override
  String get ignore => 'Ignore';

  @override
  String get appLockOn => 'App lock enabled';

  @override
  String get appLockOff => 'App lock disabled';

  @override
  String get enableAppLockFirst => 'Please enable app lock first';

  @override
  String get enterFourDigitPassword => 'Enter 4-digit password';

  @override
  String get passwordSetAndLockOn => 'Password set and app lock enabled';

  @override
  String get appLockSettings => 'App lock settings';

  @override
  String get enableAppLock => 'Enable app lock';

  @override
  String get enableAppLockSubtitle =>
      'Password required when launching the app';

  @override
  String get enableBiometrics => 'Enable biometrics';

  @override
  String get biometricsSubtitle => 'Use Face ID or Touch ID to unlock';

  @override
  String get changePassword => 'Change password';

  @override
  String get setFourDigitPassword => 'Set 4-digit password';

  @override
  String get reenterPasswordToConfirm => 'Re-enter password to confirm';

  @override
  String get passwordMismatch => 'Passwords do not match. Please try again.';

  @override
  String get confirmDelete => 'Confirm delete';

  @override
  String get confirmDeleteSessionMessage =>
      'Delete this conversation? This cannot be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get deleteSuccess => 'Deleted successfully';

  @override
  String deleteFailed(Object error) {
    return 'Delete failed: $error';
  }

  @override
  String get continueChat => 'Continue conversation...';

  @override
  String daysAgo(Object count) {
    return '$count days ago';
  }

  @override
  String get chatHistory => 'Chat history';

  @override
  String get enterFullScreenTooltip => 'Enter full screen';

  @override
  String get exitFullScreenTooltip => 'Exit full screen';

  @override
  String get noConversations => 'No conversations';

  @override
  String loadSessionListFailed(Object error) {
    return 'Failed to load session list: $error';
  }

  @override
  String yesterdayAt(Object time) {
    return 'Yesterday $time';
  }

  @override
  String get newChat => 'New chat';

  @override
  String messageCount(Object count) {
    return '$count messages';
  }

  @override
  String get organize => 'Organize';

  @override
  String get pkmCategoryProject => 'Project';

  @override
  String get pkmCategoryProjectSubtitle => 'Short-term · Goals · Deadlines';

  @override
  String get pkmCategoryArea => 'Area';

  @override
  String get pkmCategoryAreaSubtitle =>
      'Long-term · Responsibility · Standards';

  @override
  String get pkmCategoryResource => 'Resource';

  @override
  String get pkmCategoryResourceSubtitle => 'Interests · Inspiration · Reserve';

  @override
  String get pkmCategoryArchive => 'Archive';

  @override
  String get pkmCategoryArchiveSubtitle => 'Done · Dormant · Reference';

  @override
  String get recentChanges => 'Recent changes';

  @override
  String get noRecentChangesInThreeDays => 'No changes in the last 3 days';

  @override
  String get unpinned => 'Unpinned';

  @override
  String get pinnedStyle => 'Style pinned';

  @override
  String operationFailed(Object error) {
    return 'Operation failed: $error';
  }

  @override
  String get refreshingInsightData =>
      'Refreshing insight data, this may take a moment...';

  @override
  String refreshFailed(Object error) {
    return 'Refresh failed: $error';
  }

  @override
  String get sortUpdated => 'Sort order updated';

  @override
  String sortSaveFailed(Object error) {
    return 'Failed to save sort: $error';
  }

  @override
  String get insightCardDeleted => 'Insight card deleted';

  @override
  String deleteFailedShort(Object error) {
    return 'Delete failed: $error';
  }

  @override
  String get aboutThisInsightHint =>
      'What would you like to know about this insight...';

  @override
  String get knowledgeInsight => 'Knowledge insight';

  @override
  String get completeSort => 'Complete sort';

  @override
  String get noKnowledgeInsight => 'No knowledge insight';

  @override
  String insightProcessingBacklogMessage(Object count) {
    return '$count background tasks are still processing.';
  }

  @override
  String get insightUnavailableMessage =>
      'This insight is still being generated or was updated. Refresh insights and try again later.';

  @override
  String get scheduleAggregation => 'Schedule aggregation';

  @override
  String get noScheduleAggregation => 'No schedule aggregation';

  @override
  String get scheduleAggregationEmptyHint =>
      'Tap Update to organize schedules and todos from real temporal cards.';

  @override
  String get scheduleAggregationLoadFailed => 'Failed to load schedule data';

  @override
  String get scheduleAggregationRefreshFailed =>
      'Failed to refresh schedule data';

  @override
  String get scheduleTaskUpdateFailed => 'Failed to update task';

  @override
  String get scheduleFeatured => 'Featured';

  @override
  String get scheduleThisWeek => 'This week';

  @override
  String get scheduleDone => 'Done';

  @override
  String get scheduleTbd => 'TBD';

  @override
  String get scheduleWeekOverview => 'This week';

  @override
  String get scheduleImportant => 'Important';

  @override
  String get scheduleBriefingTitle => 'Schedule briefing';

  @override
  String get scheduleBriefingNeedsUpdate => 'Needs update';

  @override
  String get scheduleBriefingOpen => 'Open';

  @override
  String get scheduleBriefingNoData => 'No schedule briefing yet';

  @override
  String scheduleBriefingUpdated(Object time) {
    return 'Updated $time';
  }

  @override
  String scheduleBriefingDoneCount(Object count) {
    return '$count done';
  }

  @override
  String scheduleBriefingConflictCount(Object count) {
    return '$count conflicts';
  }

  @override
  String get updating => 'Updating...';

  @override
  String get update => 'Update';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String confirmDeleteCharacter(Object name) {
    return 'Delete character \"$name\"? This cannot be undone.';
  }

  @override
  String get configureAiCharacter => 'Configure AI character';

  @override
  String get addCharacter => 'Add character';

  @override
  String get addCharacterSubtitle =>
      'Choose AI characters to join your insight team. They will analyze your life data from different angles.';

  @override
  String get noCharacters => 'No characters';

  @override
  String loadCharacterFailed(Object error) {
    return 'Failed to load characters: $error';
  }

  @override
  String get characterDesignerHint =>
      'Describe the character you want to create or update...';

  @override
  String get characterDesigner => 'Character designer';

  @override
  String get noTags => 'No tags';

  @override
  String get createSuccess => 'Created successfully';

  @override
  String get updateSuccess => 'Updated successfully';

  @override
  String saveFailed(Object error) {
    return 'Save failed: $error';
  }

  @override
  String get newCharacter => 'New character';

  @override
  String get editCharacter => 'Edit character';

  @override
  String get save => 'Save';

  @override
  String get characterName => 'Character name';

  @override
  String get characterNameHint => 'Give your character a name';

  @override
  String get pleaseEnterCharacterName => 'Please enter character name';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get tagsHint =>
      'e.g. wisdom, recognition, macro\nSeparate multiple tags with commas';

  @override
  String get characterPersonaLabel => 'Character persona';

  @override
  String get characterPersonaHint =>
      'Include persona, style guide, example dialogue, knowledge filters, etc.\nUse ## for section headers.';

  @override
  String get pleaseEnterCharacterPersona => 'Please enter character persona';

  @override
  String get systemFeaturesAndExtensions => 'System features & extensions';

  @override
  String get shareExtensionTitle => 'Share extension';

  @override
  String get shareExtensionSubtitle =>
      'Share content to the app from system share sheet';

  @override
  String get screenTimeTitle => 'Screen Time (Screen Time API)';

  @override
  String get screenTimeSubtitle => 'Access app usage and attention data';

  @override
  String permissionRequestError(Object error) {
    return 'Permission request error: $error';
  }

  @override
  String get permissionRequiredTitle => 'Permission required';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'You have permanently denied this permission or the system requires it. Please enable it in system settings.';

  @override
  String get getting => 'Getting...';

  @override
  String get unauthorized => 'Unauthorized';

  @override
  String get authorizedGoToSettings =>
      'Authorized. Go to system settings to change.';

  @override
  String get goToSettingsShort => 'Open Settings';

  @override
  String get basicPermissions => 'Basic permissions';

  @override
  String get location => 'Location';

  @override
  String get locationPermissionReason =>
      'For recording places and location-related features';

  @override
  String get photos => 'Photos';

  @override
  String get photosPermissionReason =>
      'For selecting photos, saving generated images, etc.';

  @override
  String get camera => 'Camera';

  @override
  String get cameraPermissionReason => 'For taking photos and videos';

  @override
  String get microphone => 'Microphone';

  @override
  String get microphonePermissionReason =>
      'For voice recognition, recording, etc.';

  @override
  String get calendarPermissionReason =>
      'For recording schedule and reading calendar events';

  @override
  String get remindersPermissionReason =>
      'For recording and reading your reminders';

  @override
  String get fitnessAndMotion => 'Fitness & motion';

  @override
  String get fitnessPermissionReason => 'For recording health and motion data';

  @override
  String get notification => 'Notification';

  @override
  String get notificationPermissionReason =>
      'For sending schedule and important reminders';

  @override
  String get loadDetailFailedRetryShort =>
      'Load detail failed, please retry later.';

  @override
  String get llmCallStats => 'LLM call stats';

  @override
  String get noLlmCallRecords => 'No LLM call records';

  @override
  String get total => 'Total';

  @override
  String get callCount => 'Call count';

  @override
  String get estimatedCost => 'Estimated cost';

  @override
  String get byAgent => 'By Agent';

  @override
  String get cardGenerationAgent => 'Card generation Agent';

  @override
  String get knowledgeOrgAgent => 'Knowledge org Agent';

  @override
  String get commentGenerationAgent => 'Comment generation Agent';

  @override
  String get timeUpdated => 'Time updated';

  @override
  String updateFailed(Object error) {
    return 'Update failed: $error';
  }

  @override
  String get locationUpdated => 'Location updated';

  @override
  String get confirmDeleteCardMessage =>
      'Delete this card? This cannot be undone.';

  @override
  String get profileAgent => 'Profile Agent';

  @override
  String get assetAnalysis => 'Asset analysis';

  @override
  String get cardDetailNotFound => 'Card detail not found';

  @override
  String get saySomething => 'Say something...';

  @override
  String get relatedMemories => 'Related memories';

  @override
  String get viewMore => 'View more';

  @override
  String get relatedRecords => 'Related records';

  @override
  String get reply => 'Reply';

  @override
  String get replySent => 'Reply sent';

  @override
  String get insightTemplateGalleryTitle => 'Insight card templates';

  @override
  String get timelineTemplateGalleryTitle => 'Timeline card templates';

  @override
  String get categoryGeneral => 'General';

  @override
  String get categoryTextual => 'Textual';

  @override
  String get k411 =>
      '## 什么是心流？  心流（Flow）是由心理学家米哈里·契克森米哈提出的一种心理状态。当你完全沉浸在一项具有挑战性但可完成的任务中，时间感消失，注意力高度集中，这就是心流。  > 人在做感兴趣的事情时，常常浑然忘我。  研究发现，心流状态下的人往往生产力最高，幸福感也最强。';

  @override
  String get timelineFilterAll => 'ALL';

  @override
  String get timelineDays => 'Days';

  @override
  String get timelineWeeks => 'Weeks';

  @override
  String get timelineMonths => 'Months';

  @override
  String get timelineYears => 'Years';

  @override
  String get insights => 'Insights';

  @override
  String get memoryTitle => 'Memory';

  @override
  String get longTermProfile => 'Long-term Profile';

  @override
  String get recentBuffer => 'Recent Buffer';

  @override
  String errorLoadingMemory(Object error) {
    return 'Error loading memory: $error';
  }

  @override
  String get agentConfiguration => 'Agent Configuration';

  @override
  String get resetToDefaults => 'Reset to Defaults';

  @override
  String get resetAllAgentConfigurationsTitle =>
      'Reset All Agent Configurations';

  @override
  String get resetAllAgentConfigurationsMessage =>
      'Are you sure you want to reset all agent configurations to their default values? This action cannot be undone.';

  @override
  String get resetButton => 'Reset';

  @override
  String loadDataFailed(Object error) {
    return 'Failed to load data: $error';
  }

  @override
  String saveConfigFailed(Object error) {
    return 'Failed to save config: $error';
  }

  @override
  String get selectLlmClient => 'Select LLM Client:';

  @override
  String get agentConfigurationsReset => 'Agent configurations reset';

  @override
  String resetFailed(Object error) {
    return 'Failed to reset: $error';
  }

  @override
  String get modelConfiguration => 'Model Configuration';

  @override
  String get resetAllConfigurationsTitle => 'Reset All Configurations';

  @override
  String get resetAllModelConfigurationsMessage =>
      'Are you sure you want to reset all model configurations to their default values? This action cannot be undone.';

  @override
  String get modelConfigurationsReset => 'Model configurations reset';

  @override
  String get cannotDeleteDefaultConfiguration =>
      'Cannot delete default configuration';

  @override
  String get cannotDeleteConfigurationTitle => 'Cannot Delete Configuration';

  @override
  String configUsedByAgentsMessage(Object agentList) {
    return 'This configuration is currently used by the following agents:\n\n$agentList\n\nPlease reassign these agents before deleting.';
  }

  @override
  String get ok => 'OK';

  @override
  String get deleteConfigurationTitle => 'Delete Configuration';

  @override
  String confirmDeleteConfigMessage(Object key) {
    return 'Are you sure you want to delete \"$key\"?';
  }

  @override
  String get defaultLabel => 'Default';

  @override
  String get setAsDefault => 'Set as default';

  @override
  String get missingApiKey => 'Missing API Key';

  @override
  String get invalidJsonInExtraField => 'Invalid JSON in Extra field';

  @override
  String get keyAlreadyExists => 'Key already exists';

  @override
  String get resetConfigurationTitle => 'Reset Configuration';

  @override
  String get resetConfigurationMessage =>
      'Reset this configuration to its initial default values? Current changes will be lost.';

  @override
  String get configurationResetPressSave =>
      'Configuration reset. Press Save to apply.';

  @override
  String get addConfiguration => 'Add Configuration';

  @override
  String get editConfiguration => 'Edit Configuration';

  @override
  String get duplicateConfiguration => 'Duplicate Configuration';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get keyIdLabel => 'Key (ID)';

  @override
  String get keyIdHelper => 'Unique identifier for this configuration';

  @override
  String get required => 'Required';

  @override
  String get clientLabel => 'Provider';

  @override
  String get geminiClient => 'Gemini';

  @override
  String get chatCompletionClient => 'OpenAI (ChatCompletion)';

  @override
  String get responsesClient => 'OpenAI (Responses)';

  @override
  String get bedrockClient => 'Bedrock';

  @override
  String get providerGroupOpenAi => 'OpenAI';

  @override
  String get providerGroupAnthropic => 'Anthropic';

  @override
  String get providerGroupGoogle => 'Google';

  @override
  String get providerGroupOthers => 'Popular';

  @override
  String get providerOpenAiApiKey => 'API Key';

  @override
  String get providerOpenAiResponses => 'API Key (Responses)';

  @override
  String get providerChatGptOauth => 'ChatGPT Pro/Plus';

  @override
  String get providerClaudeApiKey => 'API Key';

  @override
  String get providerBedrockSecret => 'Bedrock Secret';

  @override
  String get providerGemini => 'Gemini';

  @override
  String get providerGeminiOauth => 'Gemini (Google OAuth)';

  @override
  String get providerKimi => 'Kimi (Moonshot)';

  @override
  String get providerQwen => 'Aliyun';

  @override
  String get providerSeed => 'Volcengine';

  @override
  String get providerZhipu => 'Zhipu GLM';

  @override
  String get providerDeepSeek => 'DeepSeek';

  @override
  String get providerMinimax => 'MiniMax';

  @override
  String get providerOpenRouter => 'OpenRouter';

  @override
  String get providerOllama => 'Ollama (Local)';

  @override
  String get providerMimo => 'Xiaomi MIMO';

  @override
  String get providerMemex => 'Memex AI';

  @override
  String get memexSignIn => 'Sign In';

  @override
  String get memexCreateAccount => 'Create Account';

  @override
  String get memexSignInToMemex => 'Sign in to Memex AI';

  @override
  String get memexCreateMemexAccount => 'Create Memex AI account';

  @override
  String get memexUsername => 'Username';

  @override
  String get memexPassword => 'Password';

  @override
  String get memexCreateAccountLink => 'Create account';

  @override
  String get memexSignInLink => 'Sign in instead';

  @override
  String get memexTopUp => 'Top up to start using Memex AI';

  @override
  String get memexApplyCredentials => 'Apply Credentials';

  @override
  String get memexCredentialsApplied => 'Credentials applied';

  @override
  String get memexTopUpSuccess => 'Top up successful!';

  @override
  String get memexFillAllFields => 'Please fill in all fields';

  @override
  String get memexUsernameTooShort => 'Username must be at least 6 characters';

  @override
  String get memexAuthFailed => 'Authentication failed';

  @override
  String get memexPaymentFailed => 'Failed to create payment';

  @override
  String get memexLogout => 'Logout';

  @override
  String memexPricingInfo(Object ratio) {
    return 'Pay-as-you-go · Official API pricing × $ratio';
  }

  @override
  String get memexCustomAmount => 'Custom Amount';

  @override
  String get memexViewHistory => 'Usage History';

  @override
  String memexBalanceLabel(Object amount) {
    return 'Balance: $amount';
  }

  @override
  String get memexConfirmPassword => 'Confirm Password';

  @override
  String get memexPasswordMismatch => 'Passwords do not match';

  @override
  String memexPayAmount(Object amount) {
    return 'Top up $amount';
  }

  @override
  String get modelIdLabel => 'Model ID';

  @override
  String get modelIdHelper => 'e.g. gemini-3.1-pro-preview, gpt-4o';

  @override
  String get fetchingModels => 'Fetching models...';

  @override
  String get fetchModelsButton => 'Fetch Models';

  @override
  String get enterApiKeyFirst => 'Enter API Key first to fetch models';

  @override
  String get apiKeyLabel => 'API Key';

  @override
  String get baseUrlLabel => 'Base URL';

  @override
  String get advancedSettings => 'Advanced Settings';

  @override
  String get testConnectionSuccess => 'Connection Successful';

  @override
  String get testConnectionFailed => 'Connection Failed';

  @override
  String get testTypeText => 'Text';

  @override
  String get testTypeVision => 'Vision';

  @override
  String get testButton => 'Test';

  @override
  String get testing => 'Testing...';

  @override
  String get proxyUrlOptional => 'Proxy URL (Optional)';

  @override
  String get proxyUrlHelper => 'e.g. http://127.0.0.1:7890';

  @override
  String get temperatureLabel => 'Temperature';

  @override
  String get topPLabel => 'Top P';

  @override
  String get maxTokensLabel => 'Max Tokens';

  @override
  String get extraParamsJson => 'Extra Params (JSON)';

  @override
  String get invalidJson => 'Invalid JSON';

  @override
  String get warning => 'Incomplete Setup';

  @override
  String get invalidConfigurationWarning =>
      'The configuration is not complete yet (e.g., API Key or Model ID is missing). You can still save and configure it later. Continue?';

  @override
  String invalidModelConfigDetailed(Object agentId, Object configKey) {
    return 'AI Agent \"$agentId\" needs a valid model configuration (key: \"$configKey\") to operate. Please check the model settings.';
  }

  @override
  String get discardChangesTitle => 'Leave this page?';

  @override
  String get discardChangesMessage =>
      'If you made any changes, please save them before leaving.';

  @override
  String get discardButton => 'Discard';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get chooseAvatar => 'Choose Avatar';

  @override
  String get coachMarkConfigureModel =>
      'Set up your AI model first to unlock all features 🔑';

  @override
  String get configureNow => 'Configure Now';

  @override
  String get modelNotConfiguredBanner =>
      'AI model not configured yet. Set it up to unlock all features.';

  @override
  String get modelNotConfiguredSubmitHint =>
      'Please configure an AI model before publishing';

  @override
  String get processingStatus => 'Processing';

  @override
  String get failedStatus => 'Failed';

  @override
  String get viewDetails => 'View Details';

  @override
  String get failureReason => 'Failure Reason';

  @override
  String get cardGenerationFailedTitle => 'Card generation failed';

  @override
  String get cardGenerationFailedDescription =>
      'Your original record is saved. You can regenerate the card without creating a duplicate record.';

  @override
  String get regenerateCard => 'Regenerate Card';

  @override
  String get cardRegenerationStarted => 'Card regeneration started';

  @override
  String get cardRegenerationFailed => 'Failed to start card regeneration';

  @override
  String get cardRegeneratingTitle => 'Regenerating card';

  @override
  String get cardRegeneratingDescription =>
      'Memex is rebuilding this card from the saved original record.';

  @override
  String failedCardsRetryTitle(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards failed to generate',
      one: '1 card failed to generate',
    );
    return '$_temp0';
  }

  @override
  String get failedCardsRetryDescription =>
      'Original records are saved. Retry all failed card generations from the saved records.';

  @override
  String get retryAllFailedCards => 'Retry All';

  @override
  String failedCardsRetryStarted(Object count) {
    return 'Started regenerating $count failed cards';
  }

  @override
  String failedCardsRetryPartial(Object retried, Object failed) {
    return 'Started $retried retries. $failed cards need attention.';
  }

  @override
  String get unknownError => 'Unknown error occurred';

  @override
  String get enableFitness => 'Enable Fitness';

  @override
  String get fitnessBannerMessage =>
      'Allow fitness access to track your health and activity data.';

  @override
  String get fitnessDismissTitle => 'Skip Fitness Access?';

  @override
  String get fitnessDismissMessage =>
      'Without fitness permission, the app won\'t be able to automatically collect your health data for insights and auto-recording.';

  @override
  String get skipAnyway => 'Skip Anyway';

  @override
  String get proModelHint =>
      'This model requires a ChatGPT Pro/Plus subscription.';

  @override
  String get searchKnowledgeBase => 'Search knowledge base...';

  @override
  String get searchKnowledgeHint =>
      'Enter keyword to search file names or content';

  @override
  String noSearchResults(Object query) {
    return 'No results found for \"$query\"';
  }

  @override
  String get onlyMarkdownPreview => 'Only Markdown preview supported';

  @override
  String get backupAndRestore => 'Backup & Restore';

  @override
  String get createBackup => 'Create Backup';

  @override
  String get restoreBackup => 'Restore Backup';

  @override
  String get backupDescription =>
      'Pack all your data (cards, knowledge base, insights, settings) into a .memex file. Save it to iCloud Drive, Google Drive, or any location via the share sheet.';

  @override
  String get restoreDescription =>
      'Select a .memex backup file to restore all data. This will overwrite current data.';

  @override
  String get selectBackupFile => 'Select Backup File';

  @override
  String get estimatedSize => 'Estimated size';

  @override
  String get backupComplete => 'Backup created';

  @override
  String backupFailed(Object error) {
    return 'Backup failed: $error';
  }

  @override
  String get confirmRestore => 'Confirm Restore';

  @override
  String get confirmRestoreMessage =>
      'Restoring will overwrite all current data including cards, knowledge base, insights, and settings. This cannot be undone. Continue?';

  @override
  String get restoreComplete => 'Restore complete';

  @override
  String get restoreRestartHint =>
      'Data has been restored. Please restart the app for all changes to take effect.';

  @override
  String restoreFailed(Object error) {
    return 'Restore failed: $error';
  }

  @override
  String get invalidBackupFile =>
      'Invalid backup file. Please select a .memex file.';

  @override
  String get automaticBackup => 'Automatic Backup';

  @override
  String get autoBackupDescription =>
      'When enabled, Memex creates at most one local snapshot per day after startup or when returning to the foreground.';

  @override
  String get backupSensitiveSettingsHint =>
      'Backups include settings and model provider keys. Keep backup files somewhere you trust.';

  @override
  String get backupLocation => 'Location';

  @override
  String get backupLocationDetails => 'Location details';

  @override
  String get backupLocationSummary => 'Shown in app';

  @override
  String get backupLocationFullPath => 'Full path';

  @override
  String get backupLocationUri => 'Folder access URI';

  @override
  String get copyBackupLocationPath => 'Copy path';

  @override
  String get backupLocationCopied => 'Backup location copied';

  @override
  String androidBackupLocationSelected(Object folderName) {
    return 'Selected folder: $folderName';
  }

  @override
  String get iosICloudBackupLocation => 'iCloud Drive > Memex > Backups';

  @override
  String get iosAppDocumentsBackupLocation =>
      'Files > On My iPhone > Memex > Backups';

  @override
  String get autoBackupStatus => 'Status';

  @override
  String get noAutoBackupYet => 'No automatic backup yet';

  @override
  String lastBackupAt(Object time) {
    return 'Last backup: $time';
  }

  @override
  String get createSnapshotNow => 'Back up now';

  @override
  String get backupLocationMenu => 'Change location';

  @override
  String get defaultBackupLocation => 'Default backup folder';

  @override
  String get defaultBackupLocationAndroidDesc =>
      'Use Memex\'s app-specific external files folder. No storage permission needed.';

  @override
  String get chooseBackupLocation => 'Choose backup folder';

  @override
  String get chooseBackupLocationAndroidDesc =>
      'Pick a folder with Android\'s system picker and grant Memex persistent access.';

  @override
  String get storedBackups => 'Stored Backups';

  @override
  String get noStoredBackups =>
      'Automatic backups will appear here after the first snapshot.';

  @override
  String get refresh => 'Refresh';

  @override
  String get restoreThisBackup => 'Restore this backup';

  @override
  String get deleteThisBackup => 'Delete this backup';

  @override
  String get confirmDeleteBackup => 'Delete backup?';

  @override
  String confirmDeleteBackupMessage(Object fileName) {
    return 'Delete $fileName? This removes the stored backup file and cannot be undone.';
  }

  @override
  String backupDeleted(Object fileName) {
    return 'Backup deleted: $fileName';
  }

  @override
  String backupDeleteFailed(Object error) {
    return 'Could not delete backup: $error';
  }

  @override
  String get creatingSafetySnapshot => 'Creating safety snapshot...';

  @override
  String autoBackupCreated(Object fileName) {
    return 'Snapshot created: $fileName';
  }

  @override
  String backupLocationFailed(Object error) {
    return 'Could not update backup location: $error';
  }

  @override
  String get backupImportCreatedAt => 'Created';

  @override
  String get backupImportSourceVersion => 'Source version';

  @override
  String get backupImportFlavor => 'Build';

  @override
  String get backupLegacyFormat => 'Legacy backup (no manifest)';

  @override
  String get restoreInProgress => 'Restoring backup...';

  @override
  String get dataStorage => 'Data Storage';

  @override
  String get dataStorageDescription =>
      'Choose where Memex stores your data. Custom folder or iCloud keeps data when you reinstall the app.';

  @override
  String get dataStorageDescriptionAndroid =>
      'Choose a custom folder to store your workspace. Data is kept when you reinstall the app.';

  @override
  String get dataStorageDescriptionIOS =>
      'Turn on iCloud to sync your workspace across devices and keep data when you reinstall the app.';

  @override
  String get storageLocationApp => 'App storage';

  @override
  String get storageLocationAppDesc =>
      'Data is stored inside the app and will be removed when you uninstall.';

  @override
  String get storageLocationCustom => 'Device storage (custom folder)';

  @override
  String get storageLocationCustomDesc =>
      'Store data in a folder you choose. Data persists across reinstall if the folder remains.';

  @override
  String get storageLocationICloud => 'Store in iCloud';

  @override
  String get storageLocationICloudDesc =>
      'Sync your workspace across Apple devices. Data stays after reinstall.';

  @override
  String get chooseFolder => 'Choose folder';

  @override
  String storageLocationCurrent(Object location) {
    return 'Current: $location';
  }

  @override
  String get icloudNotAvailable => 'iCloud not available';

  @override
  String get icloudRequiresCapability =>
      'Sign in to iCloud and turn on iCloud Drive to use iCloud storage.';

  @override
  String get loadingFromICloud => 'Restoring data from iCloud…';

  @override
  String get switchingToICloud => 'Switching to iCloud storage…';

  @override
  String get switchingStorage => 'Switching storage…';

  @override
  String get customPathInvalid =>
      'Selected folder is no longer accessible. Using app storage.';

  @override
  String get storagePermissionRequired =>
      'Storage permission is needed to use a custom folder. Please allow it.';

  @override
  String get customFolderAccessDenied =>
      'Cannot read or write this folder. Please grant storage permission or choose another location.';

  @override
  String get configured => 'Configured';

  @override
  String get apiKeyNotSet => 'API Key not set — tap to configure';

  @override
  String get bottomNavTimeline => 'Timeline';

  @override
  String get bottomNavLibrary => 'Library';

  @override
  String get aiGeneratedLabel => 'AI Generated';

  @override
  String sourceTraceWithCount(Object count) {
    return 'SOURCE TRACE ($count)';
  }

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountDesc =>
      'Permanently delete all local data and reset the app.';

  @override
  String get deleteAccountConfirmTitle => 'Delete Account?';

  @override
  String get deleteAccountConfirmMessage =>
      'This will permanently delete all your data including timeline cards, knowledge base, recordings, and settings. This action cannot be undone.';

  @override
  String get deleteAccountSuccess => 'All data has been deleted.';

  @override
  String deleteAccountTypeName(Object name) {
    return 'Type \"$name\" to confirm';
  }

  @override
  String get deleteAccountTypeHint => 'Enter your username to confirm';

  @override
  String get llmConsentTitle => 'Data Sharing Consent';

  @override
  String llmConsentMessage(Object provider) {
    return 'To enable AI features, Memex needs to send your data to $provider for processing. This includes:\n\n• Text you enter (notes, voice transcriptions)\n• Photo metadata and extracted text (OCR)\n• Health and fitness summaries\n• Timeline card content\n\nYour data is sent directly from your device to $provider. Memex does not store or relay your data through any other server.\n\nPlease review $provider\'s privacy policy for how they handle your data.\n\nDo you agree to send your data to $provider for AI processing?';
  }

  @override
  String get llmConsentAgree => 'I Agree';

  @override
  String get llmConsentDecline => 'Decline';

  @override
  String get customAgents => 'Custom Agents';

  @override
  String get noCustomAgents => 'No custom agents configured.';

  @override
  String get deleteAgent => 'Delete Agent';

  @override
  String deleteAgentConfirm(Object name) {
    return 'Delete custom agent \"$name\"?';
  }

  @override
  String get deleted => 'Deleted';

  @override
  String get saved => 'Saved';

  @override
  String get newAgent => 'New Agent';

  @override
  String get editAgent => 'Edit Agent';

  @override
  String get agentName => 'Agent Name';

  @override
  String get agentNameHint => 'my-custom-agent';

  @override
  String get agentNameRequired => 'Required';

  @override
  String get agentNameInvalid => 'Only letters, digits, and hyphens';

  @override
  String get agentNameExists => 'Name already exists';

  @override
  String get hostAgentType => 'Host Agent Type';

  @override
  String get skillDirectory => 'Skill Directory';

  @override
  String get skillDirInvalid => 'Must be a relative path (no leading / or ..)';

  @override
  String get workingDirectory => 'Working Directory (optional)';

  @override
  String get workingDirectoryHint => 'Leave empty for workspace default';

  @override
  String get llmConfig => 'LLM Config';

  @override
  String get eventType => 'Event Type';

  @override
  String get executionMode => 'Execution Mode';

  @override
  String get executionModeAsync => 'Async';

  @override
  String get executionModeSync => 'Sync';

  @override
  String get dependsOn => 'Depends On';

  @override
  String get dependsOnHint => 'Select dependencies';

  @override
  String get priority => 'Priority';

  @override
  String get maxRetries => 'Max Retries';

  @override
  String get systemPromptLabel => 'System Prompt (optional)';

  @override
  String get systemPromptHint =>
      'Additional instructions appended to host agent prompt';

  @override
  String get eventSerializer => 'Event Serializer';

  @override
  String get eventSerializerDefault => 'Default (XML)';

  @override
  String get enabledLabel => 'Enabled';

  @override
  String get skillsManagement => 'Skills Management';

  @override
  String get skillsManagementEmpty => 'No skills yet';

  @override
  String get downloadSkill => 'Download Skill';

  @override
  String get downloadSkillHint => 'Enter skill zip URL';

  @override
  String get downloading => 'Downloading...';

  @override
  String get downloadSuccess => 'Skill downloaded successfully';

  @override
  String downloadFailed(Object error) {
    return 'Download failed: $error';
  }

  @override
  String get deleteConfirm => 'Confirm Delete';

  @override
  String deleteConfirmMessage(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get emptyDirectory => 'Empty directory';

  @override
  String get invalidUrl => 'Please enter a valid URL';

  @override
  String get urlHint => 'https://example.com/skill.zip';

  @override
  String get newFolder => 'New Folder';

  @override
  String get newFile => 'New File';

  @override
  String get folderName => 'Folder Name';

  @override
  String get fileName => 'File Name';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get nameInvalid => 'Name cannot contain / or ..';

  @override
  String createFailed(Object error) {
    return 'Create failed: $error';
  }

  @override
  String get fileContent => 'File Content';

  @override
  String get saveSuccess => 'Saved successfully';

  @override
  String downloadToCurrentDir(String dir) {
    return 'The zip will be extracted to current directory: $dir';
  }

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyDesc => 'How Memex handles your data';

  @override
  String get dataShareBanner =>
      'When AI features are enabled, your data is sent to the configured provider for processing. Tap to learn more.';

  @override
  String llmConsentDataShareNote(Object provider) {
    return 'Data sharing: Your data will be sent to $provider for AI processing.';
  }

  @override
  String get llmAuthError =>
      'API authentication failed. Please check your LLM configuration in Settings.';

  @override
  String get llmBadRequestError =>
      'The request was rejected by the LLM provider. The input format may not be supported by the current model.';

  @override
  String get llmRateLimitError =>
      'API rate limit exceeded. Please try again later.';

  @override
  String get llmServerError =>
      'LLM service is temporarily unavailable. Please try again later.';

  @override
  String get llmNetworkError =>
      'Network connection failed. Please check your internet connection.';

  @override
  String get llmUnknownError =>
      'An unexpected error occurred while processing your content.';

  @override
  String get llmErrorDialogTitle => 'Processing Failed';

  @override
  String get goToModelConfig => 'Go to Settings';

  @override
  String get speechModelDownloadTitle => 'Download Speech Model';

  @override
  String speechModelDownloadDesc(Object sizeMB) {
    return 'A one-time model download (~${sizeMB}MB) is required.\n\nOnce downloaded, transcription runs entirely on-device.';
  }

  @override
  String get speechModelStartDownload => 'Start Download';

  @override
  String get speechModelChooseSource => 'Choose download source:';

  @override
  String get speechModelChinaMirror => '🇨🇳 China Mirror (Faster in CN)';

  @override
  String get speechModelGithub => '🌐 GitHub (Global)';

  @override
  String get speechModelDownloading => 'Downloading model...';

  @override
  String get speechModelConnecting => 'Connecting...';

  @override
  String speechModelDownloadFailed(Object error) {
    return 'Download failed: $error';
  }

  @override
  String get deleteSpeechModel => 'Delete speech model';

  @override
  String get confirmDeleteSpeechModelMessage =>
      'Delete the downloaded local speech recognition model files? They will be downloaded again the next time local speech-to-text is used.';

  @override
  String get speechModelDeletedSuccess => 'Speech model files deleted';

  @override
  String get speechModelNotDownloaded =>
      'No downloaded speech model files found';

  @override
  String speechModelDeleteFailed(Object error) {
    return 'Failed to delete speech model files: $error';
  }

  @override
  String get speechTranscribing => 'Recognizing...';

  @override
  String get speechTranscriptionTitle => 'Transcription';

  @override
  String get speechNoResult => 'No speech detected';

  @override
  String get useLocalSpeechToTextTitle => 'Use local speech to text';

  @override
  String get useLocalSpeechToTextDesc =>
      'When enabled, audio is transcribed on-device before sending — useful for models that do not support audio input. When disabled, the original audio is sent directly to the model.';

  @override
  String get pendingAiProcessingHint => 'Set up AI model to process';

  @override
  String get demoWelcome =>
      'Welcome to Memex!\nLet\'s take a quick tour of what AI can do for your records.';

  @override
  String get demoTapAdd => 'Tap here to create your first record';

  @override
  String get demoTapSend => 'Tap to send your first record';

  @override
  String get demoTapCard => 'Tap to see how AI organized your record';

  @override
  String get demoTapInsight => 'Tap to see AI-generated insights';

  @override
  String get demoTapInsightUpdate =>
      'Tap to generate insights from your records';

  @override
  String get demoTapKnowledge => 'Check your auto-organized knowledge files';

  @override
  String get demoDone => 'Start recording your life.';

  @override
  String get demoStartTour => 'Start Tour';

  @override
  String get demoGetStarted => 'Get Started';

  @override
  String get demoSkip => 'Skip';

  @override
  String get demoPrefillText => 'Hello Memex! This is my first record 🎉';

  @override
  String get visionBadge => 'Vision';

  @override
  String get notMultimodalHint =>
      'Memex relies on multimodal model capabilities for media analysis. If your records contain images, please make sure the model you configured supports image input.';

  @override
  String get defaultModelPrefix => 'Default';

  @override
  String get recommendedBadge => 'Recommended';

  @override
  String get reanalyzeMediaAssets => 'Re-analyze media assets';

  @override
  String get reanalyzeMediaAssetsDesc =>
      'Refreshes media analysis files before regenerating cards.';

  @override
  String get readOnlyMode => 'Chat';

  @override
  String get readOnlyBadge => 'CHAT';

  @override
  String get chatModeLabel => 'Agent';

  @override
  String get switchCompanion => 'Switch companion';

  @override
  String get personaChatInputHint => 'Type a message...';

  @override
  String get personaChatEmptyHint =>
      'Send the first message to begin this companion chat';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get showInsightTextTitle => 'Show Memex insight comment';

  @override
  String get showInsightTextDesc =>
      'Whether to show the Memex insight as a pinned comment in the card detail comment section.';

  @override
  String get enableCharacterCommentTitle => 'Character auto-comment';

  @override
  String get enableCharacterCommentDesc =>
      'Characters automatically comment on new records.';

  @override
  String get maxCommentCharactersTitle => 'Max commenting characters';

  @override
  String get maxCommentCharactersDesc =>
      'How many characters can comment on each record.';

  @override
  String replyTo(String name) {
    return 'Reply to $name';
  }

  @override
  String get cdnSignalsComments => 'New reply received';

  @override
  String get cdnSignalsInsight => 'New insight generated';

  @override
  String get cdnSignalsBoth => 'New reply and insight';

  @override
  String get untitledCard => 'Untitled card';

  @override
  String get locationContextTitle => 'Location Context';

  @override
  String get locationContextDescription =>
      'Current city and neighborhood context for agent chat';

  @override
  String get locationContextAttachTitle => 'Attach current location to chat';

  @override
  String get locationContextAttachDesc =>
      'Uses device GPS and reverse geocoding to provide city, district, and neighborhood context to the agent.';

  @override
  String get reverseGeocodingProvider => 'Reverse geocoding provider';

  @override
  String get amapProviderName => 'Amap';

  @override
  String get amapApiKey => 'Amap API Key';

  @override
  String get amapGcj02Note =>
      'Amap uses GCJ-02 coordinates. Device GPS is converted before reverse geocoding.';

  @override
  String get contextGranularity => 'Context granularity';

  @override
  String get granularityCity => 'City';

  @override
  String get granularityDistrict => 'District';

  @override
  String get granularityNeighborhood => 'Neighborhood';

  @override
  String get granularityStreet => 'Street';

  @override
  String get granularityFullAddress => 'Full address candidate';

  @override
  String get locationFreshness => 'Location freshness';

  @override
  String minutesShort(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get oneHour => '1 hour';

  @override
  String get testCurrentLocation => 'Test current location';

  @override
  String get locationUnavailable => 'location unavailable';

  @override
  String locationTestFailed(String error) {
    return 'Failed: $error';
  }

  @override
  String get locationDebugGps => 'GPS';

  @override
  String get locationDebugReverseGeocode => 'Reverse geocode';

  @override
  String get locationDebugProvider => 'Provider';

  @override
  String get locationDebugAgentContext => 'Agent context';

  @override
  String get locationDebugSource => 'Source';

  @override
  String get locationDebugAddressSummary => 'Address summary';

  @override
  String get locationDebugFullAddress => 'Full address';

  @override
  String get locationDebugCoordinates => 'Coordinates';

  @override
  String get locationDebugAccuracy => 'Accuracy';

  @override
  String get locationDebugReason => 'Reason';

  @override
  String get locationDebugOk => 'OK';

  @override
  String get locationDebugUnavailable => 'unavailable';

  @override
  String get locationDebugInjected => 'injected';

  @override
  String get locationDebugNotInjected => 'not injected';

  @override
  String get locationStatusUpdatedAt => 'Updated';

  @override
  String get locationStatusSuccessTitle => 'Current location is ready';

  @override
  String get locationStatusSuccessBody =>
      'Memex can attach this location summary when location context is relevant.';

  @override
  String get locationStatusApproximateTitle => 'Approximate location only';

  @override
  String get locationStatusApproximateBody =>
      'Accuracy looks city or area level. You can keep using it, or enable Precise Location in system settings for a tighter context.';

  @override
  String get locationStatusServiceDisabledTitle => 'System location is off';

  @override
  String get locationStatusServiceDisabledBody =>
      'Memex only uses device GPS and will not infer location from network or IP. On Android, open Location settings; on iOS, enable Settings > Privacy & Security > Location Services.';

  @override
  String get locationStatusPermissionDeniedTitle =>
      'Location permission is needed';

  @override
  String get locationStatusPermissionDeniedBody =>
      'Allow Memex to use location while testing or when location context is needed. Always access is not requested.';

  @override
  String get locationStatusPermissionForeverTitle =>
      'Location permission is blocked';

  @override
  String get locationStatusPermissionForeverBody =>
      'Open app settings and allow location for Memex. On iOS, While Using the App is enough.';

  @override
  String get locationStatusDisabledTitle => 'Location Context is off';

  @override
  String get locationStatusDisabledBody =>
      'Turn on the switch above and save when you want Memex to attach device location to agent context.';

  @override
  String get locationStatusGeocodeUnavailableTitle =>
      'GPS works, address lookup failed';

  @override
  String get locationStatusGeocodeUnavailableBody =>
      'Memex has coordinates but will not inject GPS-only context into the agent. Check the reverse geocoding provider and try again.';

  @override
  String get locationStatusUnavailableTitle => 'Location unavailable';

  @override
  String get locationStatusUnavailableBody =>
      'Check system location services and app permission, then test again.';

  @override
  String get allowLocationPermissionButton => 'Allow location permission';

  @override
  String get openAppSettingsButton => 'Open app settings';

  @override
  String get openLocationSettingsButton => 'Open location settings';

  @override
  String get locationSettingsOpenFailed => 'Could not open system settings.';

  @override
  String locationActionFailed(String error) {
    return 'Location action failed: $error';
  }

  @override
  String get settingsSearchPlaceholder => 'Search settings...';

  @override
  String get settingsSearchEmpty => 'No matching settings found';

  @override
  String get importCharacterCard => 'Import Character Card';

  @override
  String get firstMessageLabel => 'First Message';

  @override
  String get firstMessageHint =>
      'Greeting sent on first conversation (optional)';

  @override
  String get systemPromptOverrideLabel => 'System Prompt Override';

  @override
  String get systemPromptOverrideHint =>
      'Override default system prompt (advanced, optional)';

  @override
  String get postHistoryInstructionsLabel => 'Post-History Instructions';

  @override
  String get postHistoryInstructionsHint =>
      'Instructions injected after chat history, before reply (optional)';

  @override
  String get mesExampleLabel => 'Message Examples';

  @override
  String get mesExampleHint =>
      'Example dialogues showing character style (optional)';

  @override
  String get worldBookTitle => 'World Book';

  @override
  String get worldBookSubtitle =>
      'Background knowledge injected when keywords are triggered';

  @override
  String get characterMemoryTitle => 'Character Memory';

  @override
  String get characterMemorySubtitle =>
      'Relationship dynamics and interaction memories between character and user';

  @override
  String get addTooltip => 'Add';

  @override
  String get constantBadge => 'Constant';

  @override
  String worldEntryFallbackName(Object index) {
    return 'Entry $index';
  }

  @override
  String keywordsPrefix(Object keys) {
    return 'Keywords: $keys';
  }

  @override
  String memoryFallbackName(Object index) {
    return 'Memory $index';
  }

  @override
  String get addWorldEntry => 'Add World Book Entry';

  @override
  String get editWorldEntry => 'Edit World Book Entry';

  @override
  String get commentTitleLabel => 'Comment / Title';

  @override
  String get entryDescriptionHint => 'Entry description (optional)';

  @override
  String get triggerKeywordsLabel => 'Trigger Keywords';

  @override
  String get triggerKeywordsHint => 'Comma-separated, e.g.: magic, spell';

  @override
  String get contentLabel => 'Content';

  @override
  String get worldEntryContentHint =>
      'Background knowledge injected when keywords trigger';

  @override
  String get enabledCheckbox => 'Enabled';

  @override
  String get addMemory => 'Add Memory';

  @override
  String get editMemory => 'Edit Memory';

  @override
  String get memoryLabelField => 'Label';

  @override
  String get memoryLabelHint => 'Unique identifier, e.g.: name preference';

  @override
  String get memoryContentHint => 'Memory content';

  @override
  String get salienceLabel => 'Salience: ';

  @override
  String get labelCannotBeEmpty => 'Label cannot be empty';

  @override
  String importSuccess(Object name) {
    return '$name imported successfully';
  }

  @override
  String importFailed(Object error) {
    return 'Import failed: $error';
  }

  @override
  String get supportedFormats => 'Supported Formats';

  @override
  String get tavernImportDescription =>
      '• SillyTavern V2 character cards (.json)\n• PNG images with embedded cards (.png)\n\nFields like persona, world book, etc. will be automatically mapped to Memex character format.';

  @override
  String get pickCharacterFile => 'Pick Character File';

  @override
  String get repickFile => 'Pick Another File';

  @override
  String get personaSettingSection => 'Persona';

  @override
  String get systemPromptSection => 'System Prompt';

  @override
  String worldEntriesCount(Object count) {
    return 'World Book: $count entries';
  }

  @override
  String fileLabel(Object filename) {
    return 'File: $filename';
  }

  @override
  String conflictWarning(Object names) {
    return 'Character with same name already exists: $names. Importing will create a new character without overwriting existing ones.';
  }

  @override
  String get setPrimaryCompanionTitle => 'Set as Primary Companion';

  @override
  String get setPrimaryCompanionSubtitle =>
      'Automatically set as your primary companion after import';

  @override
  String get confirmImport => 'Confirm Import';

  @override
  String get chatBackground => 'Chat Background';

  @override
  String get chooseChatBackgroundImage => 'Choose background image';

  @override
  String get earlyUpdateSettingsTitle => 'Early access updates';

  @override
  String get earlyUpdateSettingsDesc =>
      'Check GitHub pre-releases for the matching Early APK, download it, and hand it to Android\'s installer.';

  @override
  String get earlyUpdateUnsupported =>
      'Early updates are only available in the Android Early build.';

  @override
  String get earlyUpdateAutoCheckTitle => 'Auto check for updates';

  @override
  String get earlyUpdateAutoCheckDesc =>
      'Check at startup at most once every 12 hours.';

  @override
  String get earlyUpdateWifiOnlyTitle => 'Download on Wi-Fi only';

  @override
  String get earlyUpdateWifiOnlyDesc =>
      'Skip update downloads while using mobile data.';

  @override
  String get earlyUpdateAutoInstallTitle => 'Auto download and install';

  @override
  String get earlyUpdateAutoInstallDesc =>
      'When a new build is found, download it and open the Android installer automatically.';

  @override
  String get earlyUpdateCheckNow => 'Check now';

  @override
  String get earlyUpdateChecking => 'Checking GitHub pre-releases...';

  @override
  String get earlyUpdateSkippedMobile =>
      'Skipped because Wi-Fi-only downloads are enabled.';

  @override
  String get earlyUpdateNoUpdate =>
      'You are already on the latest Early build.';

  @override
  String earlyUpdateFound(Object version, Object build) {
    return 'Early build $version+$build is available.';
  }

  @override
  String get earlyUpdateDownloadAndInstall => 'Download and install';

  @override
  String get earlyUpdateDownloadInProgress => 'Downloading update...';

  @override
  String earlyUpdateDownloadingPercent(Object percent) {
    return 'Downloading update: $percent%';
  }

  @override
  String get earlyUpdateDownloadReadyToInstall =>
      'Update package downloaded. Ready to install.';

  @override
  String get earlyUpdateInstallDownloadedPackage =>
      'Install downloaded package';

  @override
  String get earlyUpdateClearDownloadedPackage => 'Clear downloaded package';

  @override
  String get earlyUpdateClearDownloadedPackageSuccess =>
      'Downloaded update package cleared.';

  @override
  String get earlyUpdateInstallStarted => 'Android installer opened.';

  @override
  String get earlyUpdateInstallPermissionRequired =>
      'Allow Memex to install unknown apps, then tap download and install again.';

  @override
  String earlyUpdateLastChecked(Object time) {
    return 'Last checked: $time';
  }

  @override
  String earlyUpdateCheckFailed(Object error) {
    return 'Update check failed: $error';
  }

  @override
  String get earlyUpdateDialogTitle => 'Early update available';

  @override
  String get earlyUpdateReleaseNotes => 'Release notes';

  @override
  String get dismissAllNotifications => 'Clear all';

  @override
  String get dismissByType => 'Clear by type';

  @override
  String get dismissTypeSystemAction => 'Reminders & events';

  @override
  String get dismissTypeClarification => 'Clarifications';

  @override
  String get dismissTypeCardUpdate => 'Card updates';

  @override
  String get dismissAllConfirm => 'Clear all notifications?';

  @override
  String dismissTypeConfirm(Object type) {
    return 'Clear all $type notifications?';
  }

  @override
  String dismissedCount(Object count) {
    return '$count cleared';
  }
}
