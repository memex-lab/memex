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
  String get clearData => 'Clear data';

  @override
  String get confirmClearDataMessage => 'Clear data?';

  @override
  String get confirmClearDataKeepFactsMessage =>
      'Only the Facts directory (raw input) will be kept. All other workspace directories (Cards, Discoveries, KnowledgeInsights, PKM, _System, etc.) will be deleted.\n\nThis action cannot be undone!';

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
  String loadStatsFailed(Object error) {
    return 'Failed to load stats: $error';
  }

  @override
  String get overview => 'Overview';

  @override
  String get daily => 'Daily';

  @override
  String get detail => 'Detail';

  @override
  String get date => 'Date';

  @override
  String get noData => 'No data';

  @override
  String get totalCalls => 'Total calls';

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
  String get noPendingActions => 'No pending actions';

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
  String get aiInsightDetail => 'AI Insight Detail';

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
  String get nothingHere => 'Nothing here';

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
  String get modelIdLabel => 'Model ID';

  @override
  String get modelIdHelper => 'e.g. gemini-3.1-pro-preview, gpt-4o';

  @override
  String get apiKeyLabel => 'API Key';

  @override
  String get baseUrlLabel => 'Base URL';

  @override
  String get advancedSettings => 'Advanced Settings';

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
  String get warning => 'Warning';

  @override
  String get invalidConfigurationWarning =>
      'The current configuration is invalid (e.g., missing API Key, Model ID, or Base URL). It may not work properly. Do you want to save anyway?';

  @override
  String invalidModelConfigDetailed(Object agentId, Object configKey) {
    return 'AI Agent \"$agentId\" needs a valid model configuration (key: \"$configKey\") to operate. Please check the model settings.';
  }

  @override
  String get discardChangesTitle => 'Discard unsaved changes?';

  @override
  String get discardChangesMessage =>
      'You have unsaved changes. Are you sure you want to leave without saving?';

  @override
  String get discardButton => 'Discard';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get coachMarkFirstPost => 'Tap here to capture your first thought ✨';

  @override
  String get coachMarkInsightRefresh =>
      'Tap to generate insights from your records 🔮';

  @override
  String get coachMarkConfigureModel =>
      'Set up your AI model first to unlock all features 🔑';

  @override
  String get configureNow => 'Configure Now';
}
