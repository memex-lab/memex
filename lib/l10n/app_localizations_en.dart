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
  String modelSetAsDefault(Object modelId) {
    return 'Set $modelId as default model';
  }

  @override
  String get retry => 'Retry';

  @override
  String get unknownModel => 'Unknown model';

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
  String createTaskFailed(Object error) {
    return 'Failed to create task: $error';
  }

  @override
  String get reprocessCards => 'Reprocess cards';

  @override
  String get reprocessCardsTaskCreated =>
      'Reprocess request queued in Super Agent';

  @override
  String get reprocessCardsDownstreamMode => 'Scope';

  @override
  String get reprocessCardsCardOnly => 'Cards only';

  @override
  String get reprocessCardsCardOnlyDesc =>
      'Ask Super Agent to review and regenerate the selected timeline cards.';

  @override
  String get reprocessCardsRerunDownstream => 'Cards and related follow-ups';

  @override
  String get reprocessCardsRerunDownstreamDesc =>
      'Ask Super Agent to also consider related PKM and insight updates when needed.';

  @override
  String get reanalyzeMediaAssets => 'Re-read media attachments';

  @override
  String get reanalyzeMediaAssetsDesc =>
      'Ask Super Agent to inspect attached media again when regenerating cards.';

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
  String get confirmClearDataDeletesWorkspaceMessage =>
      'All local workspace data for the current user will be deleted, including cards, media, knowledge files, insights, memory, chat history, and system state.\n\nThis action cannot be undone!';

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
  String get cloneToTestUser => 'Clone to test user';

  @override
  String get confirmCloneToTestUserMessage =>
      'Copy the current workspace into a new local test user and switch to it. Agent runtime state is not copied. Your current user data will not be modified.';

  @override
  String get testUserIdLabel => 'Test user ID';

  @override
  String get testUserIdHelper => 'Use letters, numbers, hyphen, or underscore.';

  @override
  String get testUserIdInvalid =>
      'Use only letters, numbers, hyphen, or underscore.';

  @override
  String get overwriteExistingTestUser =>
      'Replace existing test user with the same ID';

  @override
  String testUserCloneSuccess(Object userId) {
    return 'Switched to test user $userId';
  }

  @override
  String testUserCloneFailed(Object error) {
    return 'Failed to clone test user: $error';
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
  String get aiCharacterConfig => 'AI character config';

  @override
  String get modelConfig => 'Model config';

  @override
  String get agentConfig => 'Agent config';

  @override
  String get experimentalLab => 'Labs';

  @override
  String get experimentalLabDescription =>
      'Experimental features that may change or move later.';

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
  String get appLockConfig => 'App lock config';

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
  String get close => 'Close';

  @override
  String get totalTokenConsumption => 'Total token consumption';

  @override
  String get dataLoadFailedRetry => 'Data load failed, please retry later.';

  @override
  String get timelineLoadFailedRetry =>
      'Timeline load failed, please retry later.';

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
  String get footprintMap => 'Footprint map';

  @override
  String get waypointPlaces => 'Waypoint places';

  @override
  String get unknownPlace => 'Unknown place';

  @override
  String get releaseToSend => 'Release to send';

  @override
  String get selectFromAlbum => 'Select from album';

  @override
  String get clipboardPreviewTitle => 'New clipboard';

  @override
  String get clipboardPreviewImageTitle => 'Clipboard image';

  @override
  String get clipboardPreviewImageDescription => 'Image ready to add';

  @override
  String get clipboardPreviewUnprocessed => 'Not pasted yet';

  @override
  String get clipboardPreviewPasteToInput => 'Paste to input';

  @override
  String get clipboardPreviewAddImageToInput => 'Add image';

  @override
  String get clipboardPreviewImageFailed => 'Couldn\'t read clipboard image';

  @override
  String get tellAiWhatHappened => 'Tell AI what happened...';

  @override
  String recordingWithDuration(Object duration) {
    return 'Recording: $duration';
  }

  @override
  String get playing => 'Playing...';

  @override
  String get sendLabel => 'Send';

  @override
  String attachedImagesMessage(Object count) {
    return 'Sent $count image(s)';
  }

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
  String get loadDetailFailedRetry => 'Load detail failed, please retry later.';

  @override
  String get loadFailed => 'Load failed';

  @override
  String loadHistoryFailed(Object error) {
    return 'Failed to load history: $error';
  }

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
  String get aiInputHint =>
      'Whether it\'s memories or the present, I\'m here...';

  @override
  String get refreshSuperAgentStateTooltip => 'Clear Memex Agent context';

  @override
  String get refreshSuperAgentStateTitle =>
      'Clear Memex Agent history context?';

  @override
  String get refreshSuperAgentStateMessage =>
      'The visible chat history will stay, but Memex Agent\'s historical runtime context will be cleared and future replies will start from a fresh context. Persistent memory, knowledge base files, cards, and other saved data are not affected. Use this when Memex Agent keeps behaving abnormally. Continue?';

  @override
  String get refreshSuperAgentStateActiveRunMessage =>
      'Wait until the current Memex Agent message finishes before clearing context.';

  @override
  String get refreshSuperAgentStateSuccess => 'Memex Agent context cleared';

  @override
  String refreshSuperAgentStateFailed(Object error) {
    return 'Failed to clear Memex Agent context: $error';
  }

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
  String get agentBackgroundTitle => 'Memex Agent';

  @override
  String get agentBackgroundPausedTitle => 'Memex Agent paused';

  @override
  String get agentBackgroundNeedsAttentionTitle =>
      'Memex Agent needs attention';

  @override
  String get agentBackgroundStageIdle => 'Idle';

  @override
  String get agentBackgroundStageProcessing => 'Processing';

  @override
  String get agentBackgroundStageQueued => 'Queued';

  @override
  String get agentBackgroundStageRetrying => 'Waiting to retry';

  @override
  String get agentBackgroundStagePaused => 'Paused';

  @override
  String get agentBackgroundStageCompleted => 'Completed';

  @override
  String get agentBackgroundStageNeedsAttention => 'Needs attention';

  @override
  String get agentBackgroundStageAnalyzingMedia => 'Analyzing media';

  @override
  String get agentBackgroundStageGeneratingCard => 'Generating card';

  @override
  String get agentBackgroundStageUpdatingKnowledge => 'Updating knowledge';

  @override
  String get agentBackgroundStagePreparingComment => 'Preparing comment';

  @override
  String get agentBackgroundStageRoutingFollowUps => 'Routing follow-ups';

  @override
  String agentBackgroundTaskSummary(
      Object running, Object pending, Object retrying) {
    return 'Running $running, Pending $pending, Retry $retrying';
  }

  @override
  String agentBackgroundTaskDetail(Object count) {
    return 'Processing $count queued task(s).';
  }

  @override
  String get agentBackgroundNoTasks => 'No background tasks.';

  @override
  String get agentBackgroundStarting => 'Processing is starting.';

  @override
  String get agentBackgroundCompletedDetail => 'All background tasks finished.';

  @override
  String get agentBackgroundFailedDetail => 'Processing stopped with an error.';

  @override
  String get agentBackgroundPausedDetail =>
      'Processing is paused and will continue later.';

  @override
  String get agentBackgroundQueuedDetail =>
      'Waiting for the next processing step.';

  @override
  String get agentBackgroundRetryingDetail =>
      'The current step will retry automatically.';

  @override
  String get agentBackgroundAnalyzeMediaDetail =>
      'Reading attachments and local context.';

  @override
  String get agentBackgroundGeneratingCardDetail =>
      'Turning the record into a timeline card.';

  @override
  String get agentBackgroundUpdatingKnowledgeDetail =>
      'Updating local knowledge and memory.';

  @override
  String get agentBackgroundPreparingCommentDetail =>
      'Preparing an assistant follow-up.';

  @override
  String get agentBackgroundRoutingFollowUpsDetail =>
      'Checking follow-up actions for this card.';

  @override
  String agentBackgroundPausedStatus(Object summary) {
    return 'Paused - $summary';
  }

  @override
  String agentBackgroundNeedsAttentionStatus(Object summary) {
    return 'Needs attention - $summary';
  }

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
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get copy => 'Copy';

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
  String get userIdMaxLength => 'Name must not exceed 50 characters';

  @override
  String get startUsing => 'Continue';

  @override
  String get userIdTip => 'This will be used to personalize your experience.';

  @override
  String get setupModelConfigTitle => 'Set up an AI model';

  @override
  String get setupModelConfigSubtitle =>
      'Memex needs a frontier AI model to organize records, analyze images, and generate insights. Choose one connection method.';

  @override
  String get setupModelConfigComplete => 'Complete & Go';

  @override
  String get aiService => 'Memex Model Service';

  @override
  String get aiModelHubTitle => 'AI models and services';

  @override
  String get aiModelHubSubtitle =>
      'Choose Memex\'s official service or bring your own provider. Advanced model routing stays available when you need it.';

  @override
  String get aiSetupCurrentStatusTitle => 'Current setup';

  @override
  String get aiSetupStatusNotConfiguredTitle => 'AI service is not configured';

  @override
  String get aiSetupStatusNotConfiguredDescription =>
      'Choose one connection method to enable AI organization for records, media, and insights.';

  @override
  String get aiSetupStatusMemexTitle => 'Using Memex official service';

  @override
  String get aiSetupStatusMemexDescription =>
      'Memex will use the official connection and API credentials managed by your Memex account.';

  @override
  String get aiSetupStatusCustomTitle => 'Using custom provider settings';

  @override
  String get aiSetupStatusCustomDescription =>
      'Memex will use your configured provider credentials and model role selections.';

  @override
  String get aiSetupChooseConnectionTitle => 'Choose a connection method';

  @override
  String get aiSetupChooseConnectionDescription =>
      'Start with the path that matches how you want Memex to access AI models.';

  @override
  String get aiSetupOfficialRouteDescription =>
      'Sign in to Memex to use the official AI service.';

  @override
  String get aiSetupCustomRouteDescription =>
      'Add your own provider and API key.';

  @override
  String get aiSetupCustomPageTitle => 'Custom AI service';

  @override
  String get aiSetupCustomPageSubtitle =>
      'Configure provider credentials first, then choose the model Memex should use.';

  @override
  String get aiSetupProviderCredentialsTitle => 'Provider and API keys';

  @override
  String get aiSetupProviderCredentialsDescription =>
      'Add or edit OpenAI, Anthropic, DeepSeek, Gemini, OpenRouter, Ollama, or another compatible provider.';

  @override
  String get modelRolesTitle => 'Choose primary model';

  @override
  String get modelRolesDescription =>
      'Super Agent uses one model for text and image inputs. Advanced agent overrides stay available below.';

  @override
  String get textModelRoleTitle => 'Primary model';

  @override
  String get textModelRoleDescription =>
      'Used by Super Agent for text, images, cards, knowledge, insights, chat, comments, and memory.';

  @override
  String get modelConnectionsTitle => 'Model providers and API keys';

  @override
  String get modelConnectionsDescription =>
      'Connect Memex\'s official service or add your own provider credentials.';

  @override
  String get relatedAiCapabilitiesTitle => 'Advanced and related capabilities';

  @override
  String get relatedAiCapabilitiesDescription =>
      'Fine-tune agent assignments, location provider, and speech transcription behavior.';

  @override
  String get aiSetupServiceCapabilitiesTitle => 'Service capabilities';

  @override
  String get aiSetupServiceCapabilitiesDescription =>
      'Choose the providers Memex uses for adjacent AI-powered capabilities such as speech and reverse geocoding.';

  @override
  String get aiSetupAdvancedCustomizationTitle => 'Advanced model routing';

  @override
  String get aiSetupAdvancedCustomizationDescription =>
      'For power users who want individual agents to use different providers or model configs.';

  @override
  String get locationProviderSettings => 'Location provider';

  @override
  String get speechProviderSettings => 'Speech transcription';

  @override
  String get advancedAgentModelAssignments => 'Agent model assignments';

  @override
  String get openAdvancedAgentModelAssignments => 'Override individual agents';

  @override
  String get noConfiguredModelOptions =>
      'Add a provider or API key before choosing model roles.';

  @override
  String get modelSlotUpdated => 'Model role updated';

  @override
  String get aiServiceMemexRouteTitle => 'Connect through Memex';

  @override
  String get aiServiceLongDescription =>
      'Memex uses a multi-agent system to organize life records, knowledge notes, and social context, discover deeper insights, and provide AI companionship with persistent memory. Your data is stored as plain-text Markdown, preserving data freedom and portability.';

  @override
  String get aiServiceCustomApiRouteTitle => 'I have an API key';

  @override
  String get aiServiceCustomModelDescription =>
      'Choose this first if you already have an API key from OpenAI, Anthropic, DeepSeek, Gemini, or another provider.';

  @override
  String get enableAiService => 'Connect with Memex';

  @override
  String get aiServiceReadyToast => 'AI organization is on';

  @override
  String get aiServiceSettingsDescription =>
      'If you do not have an API key, use a Memex account to connect to mainstream model services.';

  @override
  String get advancedModelConfiguration => 'Configure API key';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get clearAuth => 'Clear auth';

  @override
  String get authorizing => 'Authorizing...';

  @override
  String authFailed(Object error) {
    return 'Auth failed: $error';
  }

  @override
  String get authorized => 'Authorized';

  @override
  String authorizedAs(Object email) {
    return 'Authorized as $email';
  }

  @override
  String get authorizedSuccessfully => 'Authorized successfully';

  @override
  String get reAuthorize => 'Re-authorize';

  @override
  String get authorizeWithOpenAi => 'Authorize with OpenAI';

  @override
  String get authorizeWithGoogle => 'Authorize with Google';

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
  String get discoveredCalendarEvent => 'Calendar event awaiting confirmation';

  @override
  String get discoveredReminder => 'Reminder awaiting confirmation';

  @override
  String get addToCalendar => 'Add to calendar';

  @override
  String get addToReminders => 'Add to reminders';

  @override
  String get systemActionPendingExplanation =>
      'Not added yet. Tap below to request permission and add it to your device.';

  @override
  String addedToSuccess(Object target) {
    return 'Successfully added to $target';
  }

  @override
  String get ignore => 'Ignore';

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
  String get artifactOpen => 'Open';

  @override
  String get updating => 'Updating...';

  @override
  String get update => 'Update';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

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
  String get memexAgentNotificationPermissionTitle =>
      'Keep Memex Agent running in the background';

  @override
  String get memexAgentNotificationPermissionMessage =>
      'Memex Agent runs locally on your device. Notifications let Memex show progress and keep processing after you leave the app or turn off the screen. If notifications are off, keep Memex open in the foreground until the task finishes.';

  @override
  String get loadDetailFailedRetryShort =>
      'Load detail failed, please retry later.';

  @override
  String get total => 'Total';

  @override
  String get estimatedCost => 'Estimated cost';

  @override
  String get byAgent => 'By Agent';

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
  String get categoryTextual => 'Textual';

  @override
  String get timelineFilterAll => 'ALL';

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
  String get keyIdLabel => 'Config ID';

  @override
  String get keyIdHelper => 'Name this setup, such as deepseek or work-gpt.';

  @override
  String get required => 'Required';

  @override
  String get clientLabel => 'Model provider';

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
  String get providerMemex => 'Memex proxy service';

  @override
  String get memexSignIn => 'Sign In';

  @override
  String get memexCreateAccount => 'Create Account';

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
  String get memexTopUpButton => 'Top up';

  @override
  String get memexTopUpChooseAmount => 'Choose an amount';

  @override
  String memexTopUpEstimatedRecords(Object range) {
    return 'About $range records';
  }

  @override
  String get memexTopUpPlanStarter => 'Starter';

  @override
  String get memexTopUpPlanEveryday => 'Everyday';

  @override
  String get memexTopUpPlanHighVolume => 'High volume';

  @override
  String get memexTopUpPlanCustom => 'Custom credits';

  @override
  String get memexTopUpPlanStarterSubtitle => 'Good for trying Memex AI';

  @override
  String get memexTopUpPlanEverydaySubtitle => 'Good for regular organizing';

  @override
  String get memexTopUpPlanHighVolumeSubtitle => 'Good for larger batches';

  @override
  String get memexTopUpPlanCustomSubtitle => 'Enter USD 1-10,000';

  @override
  String get memexTopUpCustomEstimate =>
      'Estimate is based on the amount entered';

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
  String get modelIdLabel => 'Model';

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
  String get baseUrlLabel => 'API endpoint';

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
  String get failureReason => 'Failure Reason';

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
  String get autoBackupRetention => 'Retention';

  @override
  String autoBackupRetentionDays(Object days) {
    return '$days days';
  }

  @override
  String get autoBackupRetentionForever => 'Keep forever';

  @override
  String get autoBackupMaxSize => 'Storage cap';

  @override
  String autoBackupRetentionLimitHint(Object size) {
    return 'Automatic cleanup keeps automatic snapshots under $size. Safety snapshots and manual exports are kept separately.';
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
  String get backupTypeAutoSnapshot => 'Automatic snapshot';

  @override
  String get backupTypeSafetySnapshot => 'Safety snapshot';

  @override
  String get backupTypeManualBackup => 'Manual backup';

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
  String storageLocationCurrent(Object location) {
    return 'Current: $location';
  }

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
  String get downloadFile => 'Download file';

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
  String get demoDetailHint =>
      'This is your AI-organized record detail. Scroll around, then go back to continue the tour.';

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
  String get readOnlyBadge => 'CHAT';

  @override
  String get switchCompanion => 'Switch companion';

  @override
  String get personaChatInputHint => 'Type a message...';

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
  String dismissedCount(Object count) {
    return '$count cleared';
  }

  @override
  String get dataImportTitle => 'Import files';

  @override
  String get dataImportSettingsDescription =>
      'Bring old files into Memex, then decide whether to organize them.';

  @override
  String get dataImportDescription =>
      'Choose old notes, exported records, documents, or ZIP archives. Memex saves a copy first and leaves the original files untouched. After import, you can decide whether Memex should help organize them.';

  @override
  String get dataImportSelectFiles => 'Choose files to import';

  @override
  String get dataImportImporting => 'Saving files...';

  @override
  String get dataImportSuccess => 'Files saved in Memex';

  @override
  String get dataImportOnlyStored => 'Files saved. No organization started.';

  @override
  String get dataImportQueued =>
      'Memex will organize this import in the background.';

  @override
  String get dataImportResultTitle => 'Import complete';

  @override
  String dataImportResultSummary(Object count) {
    return '$count files have been saved. You can organize them now or leave them as original source material.';
  }

  @override
  String dataImportRenamedConflicts(Object count) {
    return '$count item(s) had the same name and were renamed to avoid overwriting anything.';
  }

  @override
  String dataImportSkippedUnsafeEntries(Object count) {
    return '$count unusual archive item(s) were skipped; the rest was imported normally.';
  }

  @override
  String get dataImportChooseProcessing => 'Organize these files';

  @override
  String get dataImportProcessTitle => 'Organize this import?';

  @override
  String dataImportProcessPrompt(Object count) {
    return 'You imported $count files. Choose whether Memex should organize them now, or just keep the originals.';
  }

  @override
  String get dataImportProcessKnowledgeBase => 'Organize into knowledge base';

  @override
  String get dataImportProcessKnowledgeBaseDesc =>
      'Best for documents, notes, project material, and references. Memex will extract useful information and group it for later use.';

  @override
  String get dataImportProcessTimelineCards => 'Create timeline records';

  @override
  String get dataImportProcessTimelineCardsDesc =>
      'Best for diaries, chat logs, activity history, and old exports. Memex will turn time-based content into records when it makes sense.';

  @override
  String get dataImportImpactNone =>
      'Memex will only keep these original files. No AI organization will start.';

  @override
  String get dataImportImpactKnowledgeBase =>
      'Memex will read these files and organize useful long-term information into the knowledge base. It will not proactively create timeline records.';

  @override
  String get dataImportImpactTimelineCards =>
      'Memex will read these files and create timeline records for life events or dated history when appropriate. It will not proactively organize the knowledge base.';

  @override
  String get dataImportImpactBoth =>
      'Memex will try to create timeline records and organize reusable information into the knowledge base. This is best for a complete personal archive.';

  @override
  String get dataImportFinish => 'Just save them';

  @override
  String get noImages => 'No images';

  @override
  String get noMessages => 'No messages';

  @override
  String get sketchContent => 'Sketch content';

  @override
  String get emptyFolder => 'Empty folder';

  @override
  String get usernameAlreadyTaken => 'Username already taken';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get paymentCreationFailed => 'Could not start payment';

  @override
  String get completePayment => 'Complete payment';

  @override
  String get commentReplyToYou => 'You';

  @override
  String get commentAuthorUser => 'User';

  @override
  String get commentAuthorAi => 'AI';

  @override
  String get authorizationCancelled => 'Authorization cancelled';

  @override
  String timelineWeekNumberLabel(Object week) {
    return 'Week $week';
  }

  @override
  String get timelineWeekLabel => 'Week';

  @override
  String get eventCardDefaultTitle => 'Event';

  @override
  String get memoryNoLongTermYet => 'No long-term memories yet.';

  @override
  String get memoryNoRecentBuffer => 'No recent memories in buffer.';

  @override
  String get memoryGeneralSubject => 'General';
}
