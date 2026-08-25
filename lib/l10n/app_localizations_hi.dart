// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get timesLabel => 'बार';

  @override
  String modelSetAsDefault(Object modelId) {
    return '$modelId को डिफ़ॉल्ट मॉडल बनाएं';
  }

  @override
  String get retry => 'फिर कोशिश करें';

  @override
  String get unknownModel => 'अज्ञात मॉडल';

  @override
  String get notSet => 'सेट नहीं है';

  @override
  String get confirmClear => 'साफ़ करने की पुष्टि करें';

  @override
  String get confirmClearTokenMessage =>
      'मौजूदा यूज़र साफ़ करें? आपको यूज़र ID फिर से दर्ज करनी होगी।';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get tokenCleared => 'यूज़र साफ़ किया गया';

  @override
  String clearTokenFailed(Object error) {
    return 'यूज़र साफ़ नहीं हो सका: $error';
  }

  @override
  String get selectDateRangeOptional => 'तारीख़ सीमा चुनें (वैकल्पिक):';

  @override
  String get startDate => 'शुरू तारीख़';

  @override
  String get endDate => 'समाप्ति तारीख़';

  @override
  String get select => 'चुनें';

  @override
  String get processLimitOptional => 'प्रोसेसिंग सीमा (वैकल्पिक)';

  @override
  String get leaveEmptyForAll => 'सब प्रोसेस करने के लिए खाली छोड़ें';

  @override
  String get startProcessing => 'प्रोसेसिंग शुरू करें';

  @override
  String get userIdNotFound => 'यूज़र ID नहीं मिली';

  @override
  String createTaskFailed(Object error) {
    return 'टास्क नहीं बन सका: $error';
  }

  @override
  String get reprocessCards => 'कार्ड फिर से प्रोसेस करें';

  @override
  String get reprocessCardsTaskCreated =>
      'रीप्रोसेस अनुरोध सुपर एजेंट में कतारबद्ध हुआ';

  @override
  String get reprocessCardsDownstreamMode => 'दायरा';

  @override
  String get reprocessCardsCardOnly => 'सिर्फ़ कार्ड';

  @override
  String get reprocessCardsCardOnlyDesc =>
      'सुपर एजेंट से चुने हुए टाइमलाइन कार्ड की समीक्षा और पुनर्जनन करवाएं।';

  @override
  String get reprocessCardsRerunDownstream => 'कार्ड और संबंधित फ़ॉलो-अप';

  @override
  String get reprocessCardsRerunDownstreamDesc =>
      'ज़रूरत होने पर सुपर एजेंट से संबंधित PKM और अंतर्दृष्टि अपडेट भी विचार करने को कहें।';

  @override
  String get reanalyzeMediaAssets => 'मीडिया संलग्नक फिर से पढ़ें';

  @override
  String get reanalyzeMediaAssetsDesc =>
      'कार्ड फिर से बनाते समय सुपर एजेंट से संलग्न मीडिया फिर से जँचवाएं।';

  @override
  String get regenerateComments => 'कमेंट फिर से बनाएं';

  @override
  String get regenerateCommentsTaskCreated =>
      'टिप्पणी फिर से बनाएँ करने का कार्य बना, पृष्ठभूमि में चल रहा है';

  @override
  String get rebuildSearchIndex => 'खोज सूचकांक फिर से बनाएं';

  @override
  String get rebuildSearchIndexSuccess => 'खोज सूचकांक सफलतापूर्वक फिर से बना';

  @override
  String get rebuildSearchIndexFailed => 'खोज सूचकांक फिर से नहीं बन सका';

  @override
  String get clearData => 'डेटा साफ़ करें';

  @override
  String get confirmClearDataMessage => 'डेटा साफ़ करें?';

  @override
  String get confirmClearDataDeletesWorkspaceMessage =>
      'मौजूदा यूज़र का पूरा स्थानीय वर्कस्पेस डेटा हट जाएगा, जिसमें कार्ड, मीडिया, ज्ञान फ़ाइलें, अंतर्दृष्टियाँ, स्मृति, चैट इतिहास और सिस्टम स्थिति शामिल हैं।\n\nयह कार्रवाई वापस नहीं की जा सकती!';

  @override
  String get clearFailedAgentContexts => 'असफल बातचीत संदर्भ साफ़ करें';

  @override
  String get confirmClearFailedAgentContextsMessage =>
      'अंतर्दृष्टि और अनुसूची एजेंटों के सहेजे गए बातचीत संदर्भ साफ़ करें? मॉडल बदलने के बाद पुराने एजेंट संदेश असंगत हो जाएँ तो यह उपयोगी है। तथ्य, कार्ड, ज्ञान, स्मृतियाँ और मॉडल सेटिंग्स नहीं हटेंगी।';

  @override
  String failedAgentContextsCleared(Object count) {
    return '$count सहेजा गया बातचीत संदर्भ साफ़ किए गए';
  }

  @override
  String clearFailedAgentContextsFailed(Object error) {
    return 'बातचीत संदर्भ साफ़ नहीं हो सका: $error';
  }

  @override
  String get cloneToTestUser => 'परीक्षण उपयोगकर्ता में प्रतिलिपि बनाएं';

  @override
  String get confirmCloneToTestUserMessage =>
      'मौजूदा वर्कस्पेस को नए स्थानीय परीक्षण उपयोगकर्ता में कॉपी करके उसी पर स्विच करें। एजेंट रनटाइम स्थिति कॉपी नहीं होगी। आपका मौजूदा उपयोगकर्ता डेटा बदला नहीं जाएगा।';

  @override
  String get testUserIdLabel => 'परीक्षण उपयोगकर्ता की ID';

  @override
  String get testUserIdHelper => 'अक्षर, अंक, हाइफ़न या अंडरस्कोर उपयोग करें।';

  @override
  String get testUserIdInvalid =>
      'सिर्फ़ अक्षर, अंक, हाइफ़न या अंडरस्कोर उपयोग करें।';

  @override
  String get overwriteExistingTestUser =>
      'उसी ID वाले मौजूदा परीक्षण उपयोगकर्ता को बदलें';

  @override
  String testUserCloneSuccess(Object userId) {
    return 'परीक्षण उपयोगकर्ता $userId पर स्विच किया गया';
  }

  @override
  String testUserCloneFailed(Object error) {
    return 'परीक्षण उपयोगकर्ता की प्रतिलिपि नहीं बन सकी: $error';
  }

  @override
  String get dataClearedSuccess => 'डेटा सफलतापूर्वक साफ़ किया गया';

  @override
  String clearDataFailed(Object error) {
    return 'डेटा साफ़ नहीं हो सका: $error';
  }

  @override
  String get personalCenter => 'व्यक्तिगत केंद्र';

  @override
  String get viewLogs => 'लॉग देखें';

  @override
  String get systemAuthorization => 'सिस्टम अनुमति सेटिंग';

  @override
  String get aiCharacterConfig => 'एआई चरित्र कॉन्फ़िगरेशन';

  @override
  String get modelConfig => 'मॉडल कॉन्फ़िगरेशन';

  @override
  String get agentConfig => 'एजेंट कॉन्फ़िगरेशन';

  @override
  String get experimentalLab => 'प्रयोगशाला';

  @override
  String get experimentalLabDescription =>
      'प्रयोगात्मक सुविधाएँ जो बाद में बदल या हट सकती हैं।';

  @override
  String get modelUsageStats => 'मॉडल उपयोग आँकड़े';

  @override
  String get asyncTaskList => 'असिंक्रोनस कार्य सूची';

  @override
  String get clearLocalToken => 'यूज़र साफ़ करें';

  @override
  String get insightCardTemplates => 'अंतर्दृष्टि कार्ड टेम्पलेट्स';

  @override
  String get timelineCardTemplates => 'टाइमलाइन कार्ड टेम्पलेट्स';

  @override
  String get logViewer => 'लॉग देखें';

  @override
  String get autoRefresh => 'स्वतः रीफ़्रेश';

  @override
  String get lineCount => 'लाइन संख्या: ';

  @override
  String get all => 'सभी';

  @override
  String get schedule => 'शेड्यूल';

  @override
  String get appLockConfig => 'ऐप लॉक कॉन्फ़िगरेशन';

  @override
  String loadStatsFailed(Object error) {
    return 'आँकड़े लोड नहीं हो सके: $error';
  }

  @override
  String get overview => 'सारांश';

  @override
  String get daily => 'दैनिक';

  @override
  String get modelStatsByAgent => 'एजेंट के अनुसार';

  @override
  String get detail => 'विवरण';

  @override
  String get date => 'तारीख़';

  @override
  String get agent => 'एजेंट';

  @override
  String get noData => 'कोई डेटा नहीं';

  @override
  String get totalCalls => 'कुल कॉल';

  @override
  String get calls => 'कॉल';

  @override
  String callsCount(Object count) {
    return '$count कॉल';
  }

  @override
  String get selectDateRange => 'तारीख़ सीमा चुनें';

  @override
  String get totalTokens => 'कुल टोकन';

  @override
  String get cacheRate => 'कैश दर';

  @override
  String get promptTokens => 'प्रॉम्प्ट टोकन';

  @override
  String get completionTokens => 'उत्तर टोकन';

  @override
  String get cachedTokens => 'कैश टोकन';

  @override
  String get thoughtTokens => 'सोच टोकन';

  @override
  String get prompt => 'प्रॉम्प्ट';

  @override
  String get completion => 'उत्तर';

  @override
  String get cached => 'कैश';

  @override
  String get thought => 'विचार';

  @override
  String get model => 'मॉडल';

  @override
  String get scene => 'दृश्य';

  @override
  String get sceneId => 'दृश्य ID';

  @override
  String get tokenUsage => 'टोकन उपयोग';

  @override
  String get handler => 'हैंडलर';

  @override
  String get modelBreakdown => 'मॉडल विभाजन';

  @override
  String get callDetails => 'कॉल विवरण';

  @override
  String recordDetailsTitle(Object scene) {
    return 'रिकॉर्ड विवरण: $scene';
  }

  @override
  String saveLlmConfigFailed(Object error) {
    return 'एलएलएम कॉन्फ़िगरेशन सहेजें नहीं हो सका: $error';
  }

  @override
  String get webHtmlPreviewUnavailable =>
      'Web पर एचटीएमएल पूर्वावलोकन उपलब्ध नहीं है। कृपया मोबाइल पर देखें।';

  @override
  String saveUserInfoFailed(Object error) {
    return 'उपयोगकर्ता जानकारी सहेजें नहीं हो सकी: $error';
  }

  @override
  String get totalEstimatedCost => 'कुल अनुमानित लागत';

  @override
  String get close => 'बंद करें';

  @override
  String get totalTokenConsumption => 'कुल टोकन खपत';

  @override
  String get dataLoadFailedRetry =>
      'डेटा लोड नहीं हो सका, कृपया बाद में फिर कोशिश करें।';

  @override
  String get timelineLoadFailedRetry =>
      'टाइमलाइन लोड नहीं हो सकी, कृपया बाद में फिर कोशिश करें।';

  @override
  String get newPerspective => 'नया दृष्टिकोण';

  @override
  String get startPoint => 'शुरुआत';

  @override
  String get endPoint => 'अंत';

  @override
  String get originalInput => 'मूल इनपुट';

  @override
  String get referenceContent => 'संदर्भ सामग्री';

  @override
  String referenceWithTitle(Object title) {
    return 'संदर्भ: $title';
  }

  @override
  String get actionCenterTitle => 'लंबित कार्रवाइयाँ';

  @override
  String get noPendingActions => 'कोई लंबित कार्रवाई नहीं';

  @override
  String get clarificationNeeded => 'Memex पुष्टि करना चाहता है';

  @override
  String get clarificationTextHint => 'छोटा जवाब लिखें';

  @override
  String get clarificationTextRequired => 'पहले छोटा जवाब जोड़ें';

  @override
  String get clarificationAnswered => 'जवाब दिया गया';

  @override
  String clarificationAnswerPrefix(Object answer) {
    return 'जवाब: $answer';
  }

  @override
  String get answerSaved => 'जवाब सहेजें हुआ';

  @override
  String get clarificationOtherAnswer => 'मैनुअल इनपुट';

  @override
  String get clarificationNotSure => 'पक्का नहीं / कहना नहीं चाहते';

  @override
  String get yes => 'हाँ';

  @override
  String get no => 'नहीं';

  @override
  String get footprintMap => 'पदचिह्न मैप';

  @override
  String get waypointPlaces => 'मार्ग-बिंदु स्थान';

  @override
  String get unknownPlace => 'अज्ञात स्थान';

  @override
  String get releaseToSend => 'भेजने के लिए छोड़ें';

  @override
  String get selectFromAlbum => 'एल्बम से चुनें';

  @override
  String get clipboardPreviewTitle => 'नया क्लिपबोर्ड';

  @override
  String get clipboardPreviewImageTitle => 'क्लिपबोर्ड छवि';

  @override
  String get clipboardPreviewImageDescription => 'छवि जोड़ने के लिए तैयार';

  @override
  String get clipboardPreviewUnprocessed => 'अभी पेस्ट नहीं हुआ';

  @override
  String get clipboardPreviewPasteToInput => 'इनपुट में पेस्ट करें';

  @override
  String get clipboardPreviewAddImageToInput => 'छवि जोड़ें';

  @override
  String get clipboardPreviewImageFailed => 'क्लिपबोर्ड छवि पढ़ी नहीं जा सकी';

  @override
  String get tellAiWhatHappened => 'एआई को बताएं क्या हुआ...';

  @override
  String recordingWithDuration(Object duration) {
    return 'रिकॉर्डिंग: $duration';
  }

  @override
  String get playing => 'चल रहा है...';

  @override
  String get sendLabel => 'भेजें';

  @override
  String attachedImagesMessage(Object count) {
    return '$count छवि भेजी गईं';
  }

  @override
  String get noTaskData => 'कोई कार्य डेटा नहीं';

  @override
  String createdAtDate(Object date) {
    return 'बनाया गया: $date';
  }

  @override
  String updatedAtDate(Object date) {
    return 'अपडेट: $date';
  }

  @override
  String durationLabel(Object duration) {
    return 'अवधि: $duration';
  }

  @override
  String retryCount(Object count) {
    return 'पुनः प्रयास संख्या: $count';
  }

  @override
  String get loadDetailFailedRetry =>
      'विवरण लोड नहीं हो सका, कृपया बाद में फिर कोशिश करें।';

  @override
  String get loadFailed => 'लोड विफल';

  @override
  String get reload => 'फिर लोड करें';

  @override
  String get aiInsightDetail => 'अंतर्दृष्टि विवरण';

  @override
  String relatedRecordsCount(Object count) {
    return 'संबंधित रिकॉर्ड ($count)';
  }

  @override
  String get noRelatedRecords => 'कोई संबंधित रिकॉर्ड नहीं';

  @override
  String get useFingerprintToUnlock =>
      'अनलॉक करने के लिए फ़िंगरप्रिंट उपयोग करें';

  @override
  String get locked => 'लॉक है';

  @override
  String get wrongPassword => 'गलत पासवर्ड';

  @override
  String get enterPassword => 'पासवर्ड दर्ज करें';

  @override
  String get memexLocked => 'Memex लॉक है';

  @override
  String get calendarShortSun => 'रवि';

  @override
  String get calendarShortMon => 'सोम';

  @override
  String get calendarShortTue => 'मंगल';

  @override
  String get calendarShortWed => 'बुध';

  @override
  String get calendarShortThu => 'गुरु';

  @override
  String get calendarShortFri => 'शुक्र';

  @override
  String get calendarShortSat => 'शनि';

  @override
  String noRecordsOnDate(Object date) {
    return '$date पर कोई रिकॉर्ड नहीं';
  }

  @override
  String get footprintPath => 'पदचिह्न पथ';

  @override
  String get lifeCompositionTable => 'जीवन संरचना';

  @override
  String get emotionReframe => 'भावना पुनर्परिभाषा';

  @override
  String get chronicleOfThings => 'चीज़ों का वृत्तांत';

  @override
  String get goalProgress => 'लक्ष्य प्रगति';

  @override
  String get trendChart => 'रुझान चार्ट';

  @override
  String get comparisonChart => 'तुलना चार्ट';

  @override
  String get todayTimeFlow => 'आज का समय प्रवाह';

  @override
  String get aiInputHint => 'यादें हों या वर्तमान, मैं यहाँ हूँ...';

  @override
  String get refreshSuperAgentStateTooltip => 'Memex एजेंट संदर्भ साफ़ करें';

  @override
  String get refreshSuperAgentStateTitle =>
      'Memex एजेंट इतिहास संदर्भ साफ़ करें?';

  @override
  String get refreshSuperAgentStateMessage =>
      'दिखने वाली चैट इतिहास रहेगी, लेकिन Memex एजेंट का ऐतिहासिक रनटाइम संदर्भ साफ़ हो जाएगा और आगे के जवाब नए संदर्भ से शुरू होंगे। स्थायी स्मृति, ज्ञान आधार फ़ाइलें, कार्ड और अन्य सहेजा गया डेटा प्रभावित नहीं होंगे। जब Memex एजेंट असामान्य व्यवहार करता रहे तब इसका उपयोग करें। जारी रखें?';

  @override
  String get refreshSuperAgentStateActiveRunMessage =>
      'संदर्भ साफ़ करने से पहले मौजूदा Memex एजेंट संदेश पूरा होने दें।';

  @override
  String get refreshSuperAgentStateSuccess =>
      'Memex एजेंट संदर्भ साफ़ किया गया';

  @override
  String refreshSuperAgentStateFailed(Object error) {
    return 'Memex एजेंट संदर्भ साफ़ नहीं हो सका: $error';
  }

  @override
  String get nothingHere => 'अभी यहाँ कुछ नहीं';

  @override
  String get nothingHereHint =>
      'अपना पहला कार्ड बनाने के लिए नीचे बटन टैप करें';

  @override
  String get agentProcessing => 'एआई प्रोसेस कर रहा है...';

  @override
  String get keepAppOpen => 'ऐप बंद न करें';

  @override
  String get activityDetail => 'गतिविधि विवरण';

  @override
  String get noAgentActivityYet => 'अभी कोई एजेंट गतिविधि नहीं';

  @override
  String get processingEllipsis => 'प्रोसेसिंग हो रहा है...';

  @override
  String get agentBackgroundTitle => 'Memex एजेंट';

  @override
  String get agentBackgroundPausedTitle => 'Memex एजेंट रुका हुआ है';

  @override
  String get agentBackgroundNeedsAttentionTitle => 'Memex एजेंट को ध्यान चाहिए';

  @override
  String get agentBackgroundStageIdle => 'निष्क्रिय';

  @override
  String get agentBackgroundStageProcessing => 'प्रोसेसिंग में';

  @override
  String get agentBackgroundStageQueued => 'कतार में';

  @override
  String get agentBackgroundStageRetrying => 'पुनः प्रयास का इंतज़ार';

  @override
  String get agentBackgroundStagePaused => 'रुका हुआ';

  @override
  String get agentBackgroundStageCompleted => 'पूरा';

  @override
  String get agentBackgroundStageNeedsAttention => 'ध्यान चाहिए';

  @override
  String get agentBackgroundStageAnalyzingMedia => 'मीडिया विश्लेषण हो रहा है';

  @override
  String get agentBackgroundStageGeneratingCard => 'कार्ड बनाएँ हो रहा है';

  @override
  String get agentBackgroundStageUpdatingKnowledge => 'ज्ञान अपडेट हो रहा है';

  @override
  String get agentBackgroundStagePreparingComment => 'टिप्पणी तैयार हो रहा है';

  @override
  String get agentBackgroundStageRoutingFollowUps => 'फ़ॉलो-अप रूट हो रहे हैं';

  @override
  String agentBackgroundTaskSummary(
      Object running, Object pending, Object retrying) {
    return 'चल रहे $running, लंबित $pending, पुनः प्रयास $retrying';
  }

  @override
  String agentBackgroundTaskDetail(Object count) {
    return '$count कतारबद्ध कार्य प्रोसेस हो रहे हैं।';
  }

  @override
  String get agentBackgroundNoTasks => 'कोई पृष्ठभूमि कार्य नहीं।';

  @override
  String get agentBackgroundStarting => 'प्रोसेसिंग शुरू हो रही है।';

  @override
  String get agentBackgroundCompletedDetail => 'सभी पृष्ठभूमि कार्य पूरे हुए।';

  @override
  String get agentBackgroundFailedDetail => 'प्रोसेसिंग त्रुटि के साथ रुक गई।';

  @override
  String get agentBackgroundPausedDetail =>
      'प्रोसेसिंग रुका हुआ है और बाद में जारी रहेगी।';

  @override
  String get agentBackgroundQueuedDetail =>
      'अगले प्रोसेसिंग चरण का इंतज़ार है।';

  @override
  String get agentBackgroundRetryingDetail =>
      'मौजूदा चरण अपने आप पुनः प्रयास होगा।';

  @override
  String get agentBackgroundAnalyzeMediaDetail =>
      'संलग्नक और स्थानीय संदर्भ पढ़े जा रहे हैं।';

  @override
  String get agentBackgroundGeneratingCardDetail =>
      'रिकॉर्ड को टाइमलाइन कार्ड में बदला जा रहा है।';

  @override
  String get agentBackgroundUpdatingKnowledgeDetail =>
      'स्थानीय ज्ञान और स्मृति अपडेट हो रही है।';

  @override
  String get agentBackgroundPreparingCommentDetail =>
      'सहायक फ़ॉलो-अप तैयार हो रहा है।';

  @override
  String get agentBackgroundRoutingFollowUpsDetail =>
      'इस कार्ड के फ़ॉलो-अप कार्रवाइयाँ जाँचे जा रहे हैं।';

  @override
  String agentBackgroundPausedStatus(Object summary) {
    return 'रुका हुआ - $summary';
  }

  @override
  String agentBackgroundNeedsAttentionStatus(Object summary) {
    return 'ध्यान चाहिए - $summary';
  }

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get languageSettings => 'भाषा';

  @override
  String get languageSettingsDesc => 'ऐप प्रदर्शन भाषा बदलें';

  @override
  String get noPendingActionsToast => 'कोई लंबित कार्रवाई नहीं';

  @override
  String get knowledgeNewDiscovery => 'ज्ञान खोज';

  @override
  String discoveredNewInsightsCount(Object count) {
    return '$count नए अंतर्दृष्टि मिले';
  }

  @override
  String updatedExistingInsightsCount(Object count) {
    return '$count मौजूदा अंतर्दृष्टियाँ अपडेट हुईं';
  }

  @override
  String get sectionNewInsights => 'नए अंतर्दृष्टियाँ';

  @override
  String get sectionUpdatedInsights => 'अपडेट हुए अंतर्दृष्टियाँ';

  @override
  String get unnamedInsight => 'बेनाम अंतर्दृष्टि';

  @override
  String get copiedToClipboard => 'क्लिपबोर्ड में कॉपी किया गया';

  @override
  String get copy => 'कॉपी करें';

  @override
  String get selectedLocation => 'चुना गया स्थान';

  @override
  String get confirmLocationName => 'स्थान नाम पुष्टि करें';

  @override
  String get confirmLocationNameHint =>
      'आप नाम संपादित कर सकते हैं (निर्देशांक वही रहेंगे)';

  @override
  String get nameLabel => 'नाम';

  @override
  String get inputPlaceNameHint => 'स्थान नाम दर्ज करें...';

  @override
  String currentCoordinates(Object lat, Object lng) {
    return 'निर्देशांक: $lat, $lng';
  }

  @override
  String get confirmLocation => 'स्थान पुष्टि करें';

  @override
  String get welcomeToMemex => 'Memex में आपका स्वागत है';

  @override
  String get createUserIdToStart => 'अपनी प्रोफ़ाइल बनाएं';

  @override
  String get userIdLabel => 'आपका नाम / उपनाम';

  @override
  String get userIdHint => 'अपना नाम या उपनाम दर्ज करें';

  @override
  String get pleaseEnterUserId => 'कृपया अपना नाम दर्ज करें';

  @override
  String get userIdMaxLength => 'नाम 50 चरित्र से अधिक नहीं होना चाहिए';

  @override
  String get startUsing => 'जारी रखें';

  @override
  String get userIdTip => 'यह आपके अनुभव को वैयक्तिकृत करने के लिए उपयोग होगा।';

  @override
  String get setupModelConfigTitle => 'एआई मॉडल सेटअप करें';

  @override
  String get setupModelConfigSubtitle =>
      'रिकॉर्ड व्यवस्थित करने, छवियाँ विश्लेषण करने और अंतर्दृष्टियाँ बनाएँ करने के लिए Memex को अग्रणी एआई मॉडल चाहिए। एक कनेक्शन विधि चुनें।';

  @override
  String get setupModelConfigComplete => 'पूरा करें और आगे बढ़ें';

  @override
  String get aiService => 'Memex मॉडल सेवा';

  @override
  String get aiModelHubTitle => 'एआई मॉडल और सेवाएँ';

  @override
  String get aiModelHubSubtitle =>
      'Memex की आधिकारिक सेवा चुनें या अपना प्रदाता लाएं। ज़रूरत होने पर उन्नत मॉडल रूटिंग उपलब्ध रहता है।';

  @override
  String get aiSetupCurrentStatusTitle => 'मौजूदा सेटअप';

  @override
  String get aiSetupStatusNotConfiguredTitle => 'एआई सेवा कॉन्फ़िगर नहीं है';

  @override
  String get aiSetupStatusNotConfiguredDescription =>
      'रिकॉर्ड, मीडिया और अंतर्दृष्टियाँ के लिए एआई संगठन चालू करने हेतु एक कनेक्शन विधि चुनें।';

  @override
  String get aiSetupStatusMemexTitle => 'MemeX आधिकारिक सेवा उपयोग में';

  @override
  String get aiSetupStatusMemexDescription =>
      'Memex आपके MemeX खाता द्वारा प्रबंधित आधिकारिक कनेक्शन और एपीआई क्रेडेंशियल उपयोग करेगा।';

  @override
  String get aiSetupStatusCustomTitle => 'कस्टम प्रदाता सेटिंग्स उपयोग में';

  @override
  String get aiSetupStatusCustomDescription =>
      'Memex आपके कॉन्फ़िगर प्रदाता क्रेडेंशियल और मॉडल भूमिका चयन उपयोग करेगा।';

  @override
  String get aiSetupChooseConnectionTitle => 'कनेक्शन विधि चुनें';

  @override
  String get aiSetupChooseConnectionDescription =>
      'जिस तरह आप Memex को एआई मॉडल पहुँच कराना चाहते हैं, उससे मेल खाता पथ चुनें।';

  @override
  String get aiSetupOfficialRouteDescription =>
      'MemeX में साइन इन करें और प्रदाता, कुंजियाँ या एजेंट-स्तर मॉडल चुने बिना आधिकारिक सेवा उपयोग करें।';

  @override
  String get aiSetupCustomRouteDescription =>
      'अपने प्रदाता क्रेडेंशियल जोड़ें, सुपर एजेंट के लिए मॉडल चुनें, और चाहें तो प्रति-एजेंट मॉडल ओवरराइड करें।';

  @override
  String get aiSetupCustomPageTitle => 'कस्टम एआई सेवा';

  @override
  String get aiSetupCustomPageSubtitle =>
      'पहले प्रदाता क्रेडेंशियल कॉन्फ़िगर करें, फिर Memex को उपयोग करने वाला मॉडल चुनें।';

  @override
  String get aiSetupProviderCredentialsTitle => 'प्रदाता और एपीआई कुंजीs';

  @override
  String get aiSetupProviderCredentialsDescription =>
      'OpenAI, Anthropic, DeepSeek, Gemini, OpenRouter, Ollama या किसी संगत प्रदाता को जोड़ें/संपादित करें।';

  @override
  String get modelRolesTitle => 'मुख्य मॉडल चुनें';

  @override
  String get modelRolesDescription =>
      'सुपर एजेंट पाठ और छवि इनपुट के लिए एक मॉडल उपयोग करता है। उन्नत एजेंट ओवरराइड नीचे उपलब्ध रहते हैं।';

  @override
  String get textModelRoleTitle => 'मुख्य मॉडल';

  @override
  String get textModelRoleDescription =>
      'सुपर एजेंट इसे पाठ, छवियाँ, कार्ड, ज्ञान, अंतर्दृष्टियाँ, चैट, टिप्पणियाँ और स्मृति के लिए उपयोग करता है।';

  @override
  String get modelConnectionsTitle => 'मॉडल प्रदाता और एपीआई कुंजीs';

  @override
  String get modelConnectionsDescription =>
      'Memex की आधिकारिक सेवा कनेक्ट करें या अपने प्रदाता क्रेडेंशियल जोड़ें।';

  @override
  String get relatedAiCapabilitiesTitle => 'उन्नत और संबंधित क्षमताएँ';

  @override
  String get relatedAiCapabilitiesDescription =>
      'एजेंट असाइनमेंट, स्थान प्रदाता और वाणी लिप्यंतरण व्यवहार को बारीकी से समायोजित करें।';

  @override
  String get aiSetupServiceCapabilitiesTitle => 'सेवा क्षमताएँ';

  @override
  String get aiSetupServiceCapabilitiesDescription =>
      'वाणी और रिवर्स जियोकोडिंग जैसी निकटवर्ती एआई-संचालित क्षमताओं के लिए Memex कौन से प्रदाता उपयोग करे, चुनें।';

  @override
  String get aiSetupAdvancedCustomizationTitle => 'उन्नत मॉडल रूटिंग';

  @override
  String get aiSetupAdvancedCustomizationDescription =>
      'उन्नत उपयोगकर्ता के लिए, जो अलग-अलग एजेंट को अलग प्रदाता या मॉडल कॉन्फ़िगरेशन देना चाहते हैं।';

  @override
  String get locationProviderSettings => 'स्थान प्रदाता सेटिंग';

  @override
  String get speechProviderSettings => 'वाणी लिप्यंतरण सेटिंग';

  @override
  String get advancedAgentModelAssignments => 'एजेंट मॉडल असाइनमेंट सेटिंग';

  @override
  String get openAdvancedAgentModelAssignments =>
      'व्यक्तिगत एजेंट ओवरराइड करें';

  @override
  String get noConfiguredModelOptions =>
      'मॉडल भूमिकाएँ चुनने से पहले प्रदाता या एपीआई कुंजी जोड़ें।';

  @override
  String get modelSlotUpdated => 'मॉडल भूमिका अपडेट हुआ';

  @override
  String get aiServiceMemexRouteTitle => 'Memex के ज़रिए कनेक्ट करें';

  @override
  String get aiServiceLongDescription =>
      'Memex जीवन रिकॉर्ड, ज्ञान नोट्स और सामाजिक संदर्भ को व्यवस्थित करने, गहरी अंतर्दृष्टियाँ खोजने, और स्थायी स्मृति के साथ एआई साथ देने के लिए मल्टी-एजेंट सिस्टम उपयोग करता है। आपका डेटा सादे पाठ Markdown के रूप में संग्रहीत रहता है, जिससे डेटा स्वतंत्रता और पोर्टेबिलिटी बनी रहती है।';

  @override
  String get aiServiceCustomApiRouteTitle => 'मेरे पास एपीआई कुंजी है';

  @override
  String get aiServiceCustomModelDescription =>
      'अगर आपके पास OpenAI, Anthropic, DeepSeek, Gemini या किसी दूसरे प्रदाता की एपीआई कुंजी पहले से है तो पहले इसे चुनें।';

  @override
  String get enableAiService => 'Memex से कनेक्ट करें';

  @override
  String get aiServiceReadyToast => 'एआई संगठन चालू है';

  @override
  String get aiServiceSettingsDescription =>
      'अगर आपके पास एपीआई कुंजी नहीं है, तो मुख्यधारा मॉडल सेवाओं से कनेक्ट करने के लिए Memex खाता उपयोग करें।';

  @override
  String get advancedModelConfiguration => 'एपीआई कुंजी कॉन्फ़िगर करें';

  @override
  String get skipForNow => 'अभी छोड़ें';

  @override
  String get clearAuth => 'प्रमाणीकरण साफ़ करें';

  @override
  String get authorizing => 'प्राधिकरण हो रहा है...';

  @override
  String authFailed(Object error) {
    return 'प्राधिकरण विफल: $error';
  }

  @override
  String get authorized => 'अधिकृत';

  @override
  String get config => 'कॉन्फ़िग';

  @override
  String get calendar => 'कैलेंडर';

  @override
  String get reminders => 'रिमाइंडर';

  @override
  String get writeToSystemFailed => 'सिस्टम में लिखना विफल';

  @override
  String permissionRequired(Object name) {
    return '$name अनुमति आवश्यक';
  }

  @override
  String permissionRationale(Object name) {
    return 'कृपया सेटिंग्स में ऐप को आपके $name तक पहुँच दें ताकि हम इसे आपके लिए बना सकें।';
  }

  @override
  String get goToSettings => 'सेटिंग्स पर जाएँ';

  @override
  String get unknownAction => 'अज्ञात कार्रवाई';

  @override
  String get discoveredCalendarEvent => 'कैलेंडर ईवेंट मिला';

  @override
  String get discoveredReminder => 'रिमाइंडर मिला';

  @override
  String get addToCalendar => 'कैलेंडर में जोड़ें';

  @override
  String get addToReminders => 'रिमाइंडर में जोड़ें';

  @override
  String get systemActionPendingExplanation =>
      'अभी जोड़ा नहीं गया है। अनुमति माँगने और इसे अपने डिवाइस में जोड़ने के लिए नीचे टैप करें।';

  @override
  String addedToSuccess(Object target) {
    return '$target में सफलतापूर्वक जोड़ा गया';
  }

  @override
  String get ignore => 'नज़रअंदाज़ करें';

  @override
  String get confirmDelete => 'हटाएँ पुष्टि करें';

  @override
  String get confirmDeleteSessionMessage =>
      'यह बातचीत हटाएँ? यह वापस नहीं किया जा सकता।';

  @override
  String get delete => 'हटाएँ';

  @override
  String get deleteSuccess => 'सफलतापूर्वक हटाया गया';

  @override
  String deleteFailed(Object error) {
    return 'हटाएँ विफल: $error';
  }

  @override
  String daysAgo(Object count) {
    return '$count दिन पहले';
  }

  @override
  String get chatHistory => 'चैट इतिहास';

  @override
  String get enterFullScreenTooltip => 'पूर्ण स्क्रीन में जाएँ';

  @override
  String get exitFullScreenTooltip => 'पूर्ण स्क्रीन से बाहर निकलें';

  @override
  String get noConversations => 'कोई बातचीत नहीं';

  @override
  String loadSessionListFailed(Object error) {
    return 'सत्र सूची लोड नहीं हो सकी: $error';
  }

  @override
  String yesterdayAt(Object time) {
    return 'कल $time';
  }

  @override
  String get newChat => 'नया चैट';

  @override
  String messageCount(Object count) {
    return '$count संदेश';
  }

  @override
  String get organize => 'व्यवस्थित करें';

  @override
  String get pkmCategoryProject => 'परियोजना';

  @override
  String get pkmCategoryProjectSubtitle => 'अल्पकालिक · लक्ष्य · समयसीमाएँ';

  @override
  String get pkmCategoryArea => 'क्षेत्र';

  @override
  String get pkmCategoryAreaSubtitle => 'दीर्घकालिक · ज़िम्मेदारी · मानक';

  @override
  String get pkmCategoryResource => 'संसाधन';

  @override
  String get pkmCategoryResourceSubtitle => 'रुचियाँ · प्रेरणा · संग्रह';

  @override
  String get pkmCategoryArchive => 'संग्रह';

  @override
  String get pkmCategoryArchiveSubtitle => 'पूर्ण · निष्क्रिय · संदर्भ';

  @override
  String get recentChanges => 'हाल के बदलाव';

  @override
  String get noRecentChangesInThreeDays => 'पिछले 3 दिनों में कोई बदलाव नहीं';

  @override
  String get unpinned => 'पिन नहीं किया गया';

  @override
  String get pinnedStyle => 'शैली पिन किया गया';

  @override
  String operationFailed(Object error) {
    return 'कार्रवाई विफल: $error';
  }

  @override
  String get refreshingInsightData =>
      'अंतर्दृष्टि डेटा रीफ़्रेश हो रहा है, इसमें थोड़ा समय लग सकता है...';

  @override
  String refreshFailed(Object error) {
    return 'रीफ़्रेश विफल: $error';
  }

  @override
  String get sortUpdated => 'क्रम अपडेट हुआ';

  @override
  String sortSaveFailed(Object error) {
    return 'क्रम सहेजा नहीं जा सका: $error';
  }

  @override
  String get insightCardDeleted => 'अंतर्दृष्टि कार्ड हटाया गया';

  @override
  String deleteFailedShort(Object error) {
    return 'हटाएँ विफल: $error';
  }

  @override
  String get knowledgeInsight => 'ज्ञान अंतर्दृष्टि';

  @override
  String get completeSort => 'क्रम पूरा करें';

  @override
  String get noKnowledgeInsight => 'कोई ज्ञान अंतर्दृष्टि नहीं';

  @override
  String insightProcessingBacklogMessage(Object count) {
    return '$count पृष्ठभूमि कार्य अभी भी प्रोसेस हो रहे हैं।';
  }

  @override
  String get insightUnavailableMessage =>
      'यह अंतर्दृष्टि अभी बनाएँ हो रहा है या अपडेट हुआ है। अंतर्दृष्टियाँ रीफ़्रेश करें और बाद में फिर कोशिश करें।';

  @override
  String get artifactOpen => 'खोलें';

  @override
  String get updating => 'अपडेट हो रहा है...';

  @override
  String get update => 'अपडेट करें';

  @override
  String get enabled => 'चालू';

  @override
  String get disabled => 'बंद';

  @override
  String get appLockOn => 'ऐप लॉक चालू है';

  @override
  String get appLockOff => 'ऐप लॉक बंद है';

  @override
  String get enableAppLockFirst => 'कृपया पहले ऐप लॉक चालू करें';

  @override
  String get enterFourDigitPassword => '4 अंकों का पासवर्ड दर्ज करें';

  @override
  String get passwordSetAndLockOn => 'पासवर्ड सेट और ऐप लॉक चालू';

  @override
  String get appLockSettings => 'ऐप लॉक सेटिंग्स';

  @override
  String get enableAppLock => 'ऐप लॉक चालू करें करें';

  @override
  String get enableAppLockSubtitle => 'ऐप शुरू करते समय पासवर्ड आवश्यक';

  @override
  String get enableBiometrics => 'बायोमेट्रिक्स चालू करें';

  @override
  String get biometricsSubtitle =>
      'अनलॉक करने के लिए Face ID या Touch ID उपयोग करें';

  @override
  String get changePassword => 'पासवर्ड बदलें';

  @override
  String get setFourDigitPassword => '4 अंकों का पासवर्ड सेट करें';

  @override
  String get reenterPasswordToConfirm =>
      'पुष्टि करें करने के लिए पासवर्ड फिर दर्ज करें';

  @override
  String get passwordMismatch => 'पासवर्ड मेल नहीं खाते। कृपया फिर कोशिश करें।';

  @override
  String confirmDeleteCharacter(Object name) {
    return 'चरित्र \"$name\" हटाएँ? यह वापस नहीं किया जा सकता।';
  }

  @override
  String get configureAiCharacter => 'एआई चरित्र कॉन्फ़िगर करें';

  @override
  String get addCharacter => 'चरित्र जोड़ें';

  @override
  String get addCharacterSubtitle =>
      'अपनी अंतर्दृष्टि टीम में एआई चरित्र जोड़ें। वे आपके जीवन डेटा को अलग-अलग कोणों से विश्लेषित करेंगे।';

  @override
  String get noCharacters => 'कोई चरित्र नहीं';

  @override
  String loadCharacterFailed(Object error) {
    return 'चरित्र लोड नहीं हो सके: $error';
  }

  @override
  String get noTags => 'कोई टैग नहीं';

  @override
  String get createSuccess => 'सफलतापूर्वक बनाया गया';

  @override
  String get updateSuccess => 'सफलतापूर्वक अपडेट हुआ';

  @override
  String saveFailed(Object error) {
    return 'सहेजें विफल: $error';
  }

  @override
  String get newCharacter => 'नया चरित्र';

  @override
  String get editCharacter => 'चरित्र संपादित करें';

  @override
  String get save => 'सहेजें करें';

  @override
  String get characterName => 'चरित्र नाम';

  @override
  String get characterNameHint => 'अपने चरित्र को नाम दें';

  @override
  String get pleaseEnterCharacterName => 'कृपया चरित्र नाम दर्ज करें';

  @override
  String get tagsLabel => 'टैग सूची';

  @override
  String get tagsHint =>
      'जैसे: बुद्धि, पहचान, व्यापकता\nकई टैग को अल्पविराम से अलग करें';

  @override
  String get characterPersonaLabel => 'चरित्र व्यक्तित्व विवरण';

  @override
  String get characterPersonaHint =>
      'व्यक्तित्व, शैली मार्गदर्शिका, उदाहरण संवाद, ज्ञान फ़िल्टर आदि शामिल करें।\nसेक्शन शीर्षकों के लिए ## उपयोग करें।';

  @override
  String get pleaseEnterCharacterPersona => 'कृपया चरित्र व्यक्तित्व दर्ज करें';

  @override
  String permissionRequestError(Object error) {
    return 'अनुमति अनुरोध त्रुटि: $error';
  }

  @override
  String get permissionRequiredTitle => 'अनुमति आवश्यक';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'आपने इस अनुमति को स्थायी रूप से अस्वीकार किया है या सिस्टम इसे मांगता है। कृपया सिस्टम सेटिंग्स में चालू करें करें।';

  @override
  String get getting => 'लिया जा रहा है...';

  @override
  String get unauthorized => 'अनधिकृत';

  @override
  String get authorizedGoToSettings =>
      'अनुमति मिल गई। बदलने के लिए सिस्टम सेटिंग्स पर जाएँ।';

  @override
  String get location => 'स्थान';

  @override
  String get locationPermissionReason =>
      'Places और स्थान-संबंधित सुविधाएँ रिकॉर्ड करने के लिए';

  @override
  String get photos => 'फ़ोटो';

  @override
  String get photosPermissionReason =>
      'फ़ोटो चुनने, बनाया गया छवियाँ सहेजें करने आदि के लिए';

  @override
  String get camera => 'कैमरा';

  @override
  String get cameraPermissionReason => 'फ़ोटो और वीडियो लेने के लिए';

  @override
  String get microphone => 'माइक्रोफ़ोन';

  @override
  String get microphonePermissionReason => 'वाणी पहचान, रिकॉर्डिंग आदि के लिए';

  @override
  String get calendarPermissionReason =>
      'अनुसूची रिकॉर्ड करने और कैलेंडर ईवेंट पढ़ने के लिए';

  @override
  String get remindersPermissionReason =>
      'आपके रिमाइंडर रिकॉर्ड और पढ़ने करने के लिए';

  @override
  String get fitnessAndMotion => 'फ़िटनेस और गतिविधि';

  @override
  String get fitnessPermissionReason =>
      'स्वास्थ्य और गतिविधि डेटा रिकॉर्ड करने के लिए';

  @override
  String get notification => 'सूचना';

  @override
  String get notificationPermissionReason =>
      'अनुसूची और महत्वपूर्ण रिमाइंडर भेजने के लिए';

  @override
  String get memexAgentNotificationPermissionTitle =>
      'Memex Agent को बैकग्राउंड में चलने दें';

  @override
  String get memexAgentNotificationPermissionMessage =>
      'Memex Agent आपके डिवाइस पर लोकल रूप से चलता है। नोटिफिकेशन अनुमति देने पर Memex प्रगति दिखा सकता है और ऐप छोड़ने या स्क्रीन बंद करने के बाद भी प्रोसेसिंग जारी रख सकता है। नोटिफिकेशन बंद हों तो काम पूरा होने तक Memex को सामने खुला रखें।';

  @override
  String get loadDetailFailedRetryShort =>
      'विवरण लोड नहीं हो सका, कृपया बाद में फिर कोशिश करें।';

  @override
  String get total => 'कुल';

  @override
  String get estimatedCost => 'अनुमानित लागत';

  @override
  String get byAgent => 'एजेंट के अनुसार';

  @override
  String get timeUpdated => 'समय अपडेट हुआ';

  @override
  String updateFailed(Object error) {
    return 'अपडेट विफल: $error';
  }

  @override
  String get locationUpdated => 'स्थान अपडेट हुई';

  @override
  String get confirmDeleteCardMessage =>
      'यह कार्ड हटाएँ? यह वापस नहीं किया जा सकता।';

  @override
  String get cardDetailNotFound => 'कार्ड विवरण नहीं मिला';

  @override
  String get saySomething => 'कुछ कहें...';

  @override
  String get relatedMemories => 'संबंधित स्मृतियाँ';

  @override
  String get viewMore => 'और देखें';

  @override
  String get relatedRecords => 'संबंधित रिकॉर्ड';

  @override
  String get reply => 'जवाब करें';

  @override
  String get replySent => 'जवाब भेजा गया';

  @override
  String get insightTemplateGalleryTitle => 'अंतर्दृष्टि कार्ड टेम्पलेट्स';

  @override
  String get timelineTemplateGalleryTitle => 'टाइमलाइन कार्ड टेम्पलेट्स';

  @override
  String get categoryTextual => 'पाठ्य श्रेणी';

  @override
  String get timelineFilterAll => 'सभी रिकॉर्ड';

  @override
  String get insights => 'अंतर्दृष्टियाँ सूची';

  @override
  String get memoryTitle => 'स्मृति खंड';

  @override
  String get longTermProfile => 'दीर्घकालिक प्रोफ़ाइल';

  @override
  String get recentBuffer => 'हालिया बफ़र';

  @override
  String errorLoadingMemory(Object error) {
    return 'स्मृति लोड करते समय त्रुटि: $error';
  }

  @override
  String get agentConfiguration => 'एजेंट कॉन्फ़िगरेशन';

  @override
  String get resetToDefaults => 'डिफ़ॉल्ट पर रीसेट करें';

  @override
  String get resetAllAgentConfigurationsTitle =>
      'सभी एजेंट कॉन्फ़िगरेशन रीसेट करें';

  @override
  String get resetAllAgentConfigurationsMessage =>
      'क्या आप सभी एजेंट कॉन्फ़िगरेशन को उनके डिफ़ॉल्ट मान पर रीसेट करना चाहते हैं? यह कार्रवाई वापस नहीं की जा सकती।';

  @override
  String get resetButton => 'रीसेट करें';

  @override
  String loadDataFailed(Object error) {
    return 'डेटा लोड नहीं हो सका: $error';
  }

  @override
  String saveConfigFailed(Object error) {
    return 'कॉन्फ़िगरेशन सहेजा नहीं जा सका: $error';
  }

  @override
  String get selectLlmClient => 'एलएलएम क्लाइंट चुनें:';

  @override
  String get agentConfigurationsReset => 'एजेंट कॉन्फ़िगरेशन रीसेट हुए';

  @override
  String resetFailed(Object error) {
    return 'रीसेट विफल: $error';
  }

  @override
  String get modelConfiguration => 'मॉडल कॉन्फ़िगरेशन';

  @override
  String get resetAllConfigurationsTitle => 'सभी कॉन्फ़िगरेशन रीसेट करें';

  @override
  String get resetAllModelConfigurationsMessage =>
      'क्या आप सभी मॉडल कॉन्फ़िगरेशन को उनके डिफ़ॉल्ट मान पर रीसेट करना चाहते हैं? यह कार्रवाई वापस नहीं की जा सकती।';

  @override
  String get modelConfigurationsReset => 'मॉडल कॉन्फ़िगरेशन रीसेट हुए';

  @override
  String get cannotDeleteDefaultConfiguration =>
      'डिफ़ॉल्ट कॉन्फ़िगरेशन हटाएँ नहीं कर सकते';

  @override
  String get cannotDeleteConfigurationTitle =>
      'कॉन्फ़िगरेशन हटाएँ नहीं कर सकते';

  @override
  String configUsedByAgentsMessage(Object agentList) {
    return 'यह कॉन्फ़िगरेशन अभी इन एजेंटों द्वारा उपयोग हो रही है:\n\n$agentList\n\nहटाने से पहले इन एजेंटों को फिर से असाइन करें।';
  }

  @override
  String get ok => 'OK';

  @override
  String get deleteConfigurationTitle => 'कॉन्फ़िगरेशन हटाएँ करें';

  @override
  String confirmDeleteConfigMessage(Object key) {
    return 'क्या आप \"$key\" हटाना चाहते हैं?';
  }

  @override
  String get defaultLabel => 'डिफ़ॉल्ट';

  @override
  String get setAsDefault => 'डिफ़ॉल्ट के रूप में सेट करें';

  @override
  String get invalidJsonInExtraField => 'अतिरिक्त फ़ील्ड में अमान्य JSON';

  @override
  String get keyAlreadyExists => 'कुंजी पहले से मौजूद है';

  @override
  String get resetConfigurationTitle => 'कॉन्फ़िगरेशन रीसेट करें';

  @override
  String get resetConfigurationMessage =>
      'इस कॉन्फ़िगरेशन को शुरुआती डिफ़ॉल्ट मान पर रीसेट करें? मौजूदा बदलाव खो जाएँगे।';

  @override
  String get configurationResetPressSave =>
      'कॉन्फ़िगरेशन रीसेट हो गई। लागू करें करने के लिए सहेजें दबाएँ।';

  @override
  String get addConfiguration => 'कॉन्फ़िगरेशन जोड़ें';

  @override
  String get editConfiguration => 'कॉन्फ़िगरेशन संपादित करें';

  @override
  String get duplicateConfiguration => 'कॉन्फ़िगरेशन डुप्लिकेट करें';

  @override
  String get duplicate => 'डुप्लिकेट करें';

  @override
  String get keyIdLabel => 'कॉन्फ़िगरेशन आईडी';

  @override
  String get keyIdHelper => 'इस सेटअप को नाम दें, जैसे deepseek या work-gpt।';

  @override
  String get required => 'आवश्यक';

  @override
  String get clientLabel => 'मॉडल प्रदाता चुनें';

  @override
  String get providerGroupOpenAi => 'OpenAI';

  @override
  String get providerGroupAnthropic => 'Anthropic';

  @override
  String get providerGroupGoogle => 'Google';

  @override
  String get providerGroupOthers => 'लोकप्रिय प्रदाता';

  @override
  String get providerOpenAiApiKey => 'एपीआई कुंजी';

  @override
  String get providerOpenAiResponses => 'एपीआई कुंजी (Responses मोड)';

  @override
  String get providerChatGptOauth => 'ChatGPT Pro/Plus खाता';

  @override
  String get providerClaudeApiKey => 'एपीआई कुंजी';

  @override
  String get providerBedrockSecret => 'Bedrock गुप्त कुंजी';

  @override
  String get providerGemini => 'Gemini';

  @override
  String get providerGeminiOauth => 'Google OAuth से Gemini लॉगिन';

  @override
  String get providerKimi => 'Kimi (Moonshot प्रदाता)';

  @override
  String get providerQwen => 'Aliyun प्रदाता';

  @override
  String get providerSeed => 'Volcengine प्रदाता';

  @override
  String get providerZhipu => 'Zhipu GLM प्रदाता';

  @override
  String get providerDeepSeek => 'DeepSeek';

  @override
  String get providerMinimax => 'MiniMax';

  @override
  String get providerOpenRouter => 'OpenRouter';

  @override
  String get providerOllama => 'Ollama (स्थानीय प्रदाता)';

  @override
  String get providerMimo => 'Xiaomi MIMO प्रदाता';

  @override
  String get providerMemex => 'Memex प्रॉक्सी सेवा';

  @override
  String get memexSignIn => 'साइन इन करें';

  @override
  String get memexCreateAccount => 'खाता बनाएं';

  @override
  String get memexUsername => 'उपयोगकर्ता नाम दर्ज करें';

  @override
  String get memexPassword => 'पासवर्ड दर्ज करें';

  @override
  String get memexCreateAccountLink => 'खाता बनाएं';

  @override
  String get memexSignInLink => 'इसके बजाय साइन इन करें';

  @override
  String get memexTopUp => 'Memex एआई उपयोग शुरू करने के लिए रिचार्ज करें';

  @override
  String get memexTopUpSuccess => 'शीर्ष up सफल!';

  @override
  String get memexFillAllFields => 'कृपया सभी फ़ील्ड भरें';

  @override
  String get memexUsernameTooShort =>
      'उपयोगकर्ता नाम कम से कम 6 चरित्र का होना चाहिए';

  @override
  String get memexAuthFailed => 'प्रमाणीकरण विफल';

  @override
  String get memexPaymentFailed => 'भुगतान नहीं बन सका';

  @override
  String get memexLogout => 'लॉग आउट करें';

  @override
  String get memexTopUpButton => 'शीर्ष up करें';

  @override
  String get memexTopUpChooseAmount => 'राशि चुनें';

  @override
  String memexTopUpEstimatedRecords(Object range) {
    return 'लगभग $range रिकॉर्ड';
  }

  @override
  String get memexTopUpPlanStarter => 'शुरुआती प्लान';

  @override
  String get memexTopUpPlanEveryday => 'रोज़मर्रा प्लान';

  @override
  String get memexTopUpPlanHighVolume => 'उच्च उपयोग प्लान';

  @override
  String get memexTopUpPlanCustom => 'कस्टम क्रेडिट प्लान';

  @override
  String get memexTopUpPlanStarterSubtitle => 'Memex एआई आज़माने के लिए अच्छा';

  @override
  String get memexTopUpPlanEverydaySubtitle => 'नियमित आयोजन के लिए अच्छा';

  @override
  String get memexTopUpPlanHighVolumeSubtitle => 'बड़े बैच के लिए अच्छा';

  @override
  String get memexTopUpPlanCustomSubtitle => 'USD 1-10,000 दर्ज करें';

  @override
  String get memexTopUpCustomEstimate => 'अनुमान दर्ज राशि पर आधारित है';

  @override
  String get memexCustomAmount => 'कस्टम राशि';

  @override
  String get memexViewHistory => 'उपयोग इतिहास देखें';

  @override
  String memexBalanceLabel(Object amount) {
    return 'शेष राशि: $amount';
  }

  @override
  String get memexConfirmPassword => 'पासवर्ड पुष्टि करें';

  @override
  String get memexPasswordMismatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String memexPayAmount(Object amount) {
    return '$amount रिचार्ज करें';
  }

  @override
  String get modelIdLabel => 'मॉडल';

  @override
  String get modelIdHelper => 'जैसे gemini-3.1-pro-preview, gpt-4o';

  @override
  String get fetchingModels => 'मॉडल लाएँ हो रहे हैं...';

  @override
  String get fetchModelsButton => 'मॉडल लाएँ करें';

  @override
  String get enterApiKeyFirst =>
      'मॉडल लाएँ करने के लिए पहले एपीआई कुंजी दर्ज करें';

  @override
  String get apiKeyLabel => 'एपीआई कुंजी';

  @override
  String get baseUrlLabel => 'एपीआई एंडपॉइंट यूआरएल';

  @override
  String get advancedSettings => 'उन्नत सेटिंग्स';

  @override
  String get testConnectionSuccess => 'कनेक्शन सफल';

  @override
  String get testConnectionFailed => 'कनेक्शन विफल';

  @override
  String get testTypeText => 'पाठ';

  @override
  String get testTypeVision => 'विज़न';

  @override
  String get testButton => 'परीक्षण करें';

  @override
  String get testing => 'परीक्षण हो रहा है...';

  @override
  String get proxyUrlOptional => 'प्रॉक्सी यूआरएल (वैकल्पिक)';

  @override
  String get proxyUrlHelper => 'जैसे http://127.0.0.1:7890';

  @override
  String get temperatureLabel => 'तापमान मान';

  @override
  String get topPLabel => 'शीर्ष P मान';

  @override
  String get maxTokensLabel => 'अधिकतम टोकन';

  @override
  String get extraParamsJson => 'अतिरिक्त पैरामीटर (JSON)';

  @override
  String get invalidJson => 'अमान्य JSON फ़ॉर्मैट';

  @override
  String get warning => 'अधूरा सेटअप';

  @override
  String get invalidConfigurationWarning =>
      'कॉन्फ़िगरेशन अभी पूरी नहीं है (जैसे एपीआई कुंजी या मॉडल आईडी मौजूद नहीं है)। आप फिर भी इसे सहेजें कर सकते हैं और बाद में कॉन्फ़िगर कर सकते हैं। जारी रखें?';

  @override
  String invalidModelConfigDetailed(Object agentId, Object configKey) {
    return 'एआई एजेंट \"$agentId\" को चलने के लिए वैध मॉडल कॉन्फ़िगरेशन (कुंजी: \"$configKey\") चाहिए। कृपया मॉडल सेटिंग्स जाँचें।';
  }

  @override
  String get discardChangesTitle => 'यह पेज छोड़ें?';

  @override
  String get discardChangesMessage =>
      'अगर आपने बदलाव किए हैं, तो जाने से पहले उन्हें सहेजें करें।';

  @override
  String get discardButton => 'छोड़ें';

  @override
  String get chooseLanguage => 'भाषा चुनें';

  @override
  String get chooseAvatar => 'अवतार चुनें';

  @override
  String get configureNow => 'अभी कॉन्फ़िगर करें';

  @override
  String get modelNotConfiguredBanner =>
      'एआई मॉडल अभी कॉन्फ़िगर नहीं है। सभी सुविधाएँ अनलॉक करने के लिए सेटअप करें।';

  @override
  String get modelNotConfiguredSubmitHint =>
      'प्रकाशित करने से पहले कृपया एआई मॉडल कॉन्फ़िगर करें';

  @override
  String get processingStatus => 'प्रोसेसिंग में';

  @override
  String get failedStatus => 'विफल स्थिति';

  @override
  String get failureReason => 'विफलता कारण';

  @override
  String get unknownError => 'अज्ञात त्रुटि हुई';

  @override
  String get enableFitness => 'फ़िटनेस चालू करें करें';

  @override
  String get fitnessBannerMessage =>
      'स्वास्थ्य और गतिविधि डेटा ट्रैक करने के लिए फ़िटनेस पहुँच दें।';

  @override
  String get fitnessDismissTitle => 'फ़िटनेस पहुँच छोड़ें?';

  @override
  String get fitnessDismissMessage =>
      'फ़िटनेस अनुमति के बिना ऐप अंतर्दृष्टियों और स्वचालित रिकॉर्डिंग के लिए आपका स्वास्थ्य डेटा अपने आप एकत्र नहीं कर पाएगा।';

  @override
  String get skipAnyway => 'फिर भी छोड़ें';

  @override
  String get proModelHint => 'इस मॉडल के लिए ChatGPT Pro/Plus सदस्यता चाहिए।';

  @override
  String get searchKnowledgeBase => 'ज्ञान आधार में खोजें...';

  @override
  String get searchKnowledgeHint =>
      'फ़ाइल नाम या सामग्री खोजने के लिए कीवर्ड दर्ज करें';

  @override
  String noSearchResults(Object query) {
    return '\"$query\" के लिए कोई नतीजा नहीं मिला';
  }

  @override
  String get onlyMarkdownPreview => 'सिर्फ़ Markdown पूर्वावलोकन समर्थित है';

  @override
  String get backupAndRestore => 'बैकअप और बहाल';

  @override
  String get createBackup => 'बैकअप बनाएं';

  @override
  String get restoreBackup => 'बैकअप बहाल करें';

  @override
  String get backupDescription =>
      'अपना पूरा डेटा (कार्ड, ज्ञान आधार, अंतर्दृष्टियाँ, सेटिंग्स) .memex फ़ाइल में पैक करें। इसे शेयर शीट से iCloud ड्राइव, Google ड्राइव या किसी भी जगह सहेजें।';

  @override
  String get restoreDescription =>
      'पूरा डेटा बहाल करने के लिए .memex बैकअप फ़ाइल चुनें। इससे मौजूदा डेटा ओवरराइट होगा।';

  @override
  String get selectBackupFile => 'बैकअप फ़ाइल चुनें';

  @override
  String get estimatedSize => 'अनुमानित आकार';

  @override
  String get backupComplete => 'बैकअप बनाया गया';

  @override
  String backupFailed(Object error) {
    return 'बैकअप विफल: $error';
  }

  @override
  String get confirmRestore => 'बहाल पुष्टि करें';

  @override
  String get confirmRestoreMessage =>
      'बहाल करने से कार्ड, ज्ञान आधार, अंतर्दृष्टियाँ और सेटिंग्स सहित सारा मौजूदा डेटा ओवरराइट होगा। यह वापस नहीं किया जा सकता। जारी रखें?';

  @override
  String get restoreComplete => 'बहाल पूरा';

  @override
  String get restoreRestartHint =>
      'डेटा बहाल हो गया है। सभी बदलाव लागू करने के लिए ऐप रीस्टार्ट करें।';

  @override
  String restoreFailed(Object error) {
    return 'बहाल विफल: $error';
  }

  @override
  String get invalidBackupFile =>
      'अमान्य बैकअप फ़ाइल। कृपया .memex फ़ाइल चुनें।';

  @override
  String get automaticBackup => 'स्वचालित बैकअप';

  @override
  String get autoBackupDescription =>
      'चालू होने पर Memex स्टार्टअप के बाद या अग्रभूमि में लौटते समय हर दिन अधिकतम एक स्थानीय स्नैपशॉट बनाता है।';

  @override
  String get backupSensitiveSettingsHint =>
      'बैकअप में सेटिंग्स और मॉडल प्रदाता कुंजियाँ शामिल होती हैं। बैकअप फ़ाइलें भरोसेमंद जगह रखें।';

  @override
  String get backupLocation => 'बैकअप स्थान';

  @override
  String get backupLocationDetails => 'स्थान विवरण देखें';

  @override
  String get backupLocationSummary => 'ऐप में दिखाया गया';

  @override
  String get backupLocationFullPath => 'पूरा पथ';

  @override
  String get backupLocationUri => 'फ़ोल्डर पहुँच URI मान';

  @override
  String get copyBackupLocationPath => 'पथ कॉपी करें';

  @override
  String get backupLocationCopied => 'बैकअप स्थान कॉपी की गई';

  @override
  String androidBackupLocationSelected(Object folderName) {
    return 'चुना गया फ़ोल्डर: $folderName';
  }

  @override
  String get iosICloudBackupLocation => 'iCloud ड्राइव > Memex > बैकअप';

  @override
  String get iosAppDocumentsBackupLocation =>
      'फ़ाइलें > मेरे iPhone पर > Memex > बैकअप फ़ोल्डर';

  @override
  String get autoBackupStatus => 'स्थिति';

  @override
  String get noAutoBackupYet => 'अभी कोई स्वचालित बैकअप नहीं';

  @override
  String lastBackupAt(Object time) {
    return 'पिछला बैकअप समय: $time';
  }

  @override
  String get autoBackupRetention => 'रिटेंशन अवधि';

  @override
  String autoBackupRetentionDays(Object days) {
    return '$days दिन';
  }

  @override
  String get autoBackupRetentionForever => 'हमेशा रखें';

  @override
  String get autoBackupMaxSize => 'स्टोरेज सीमा';

  @override
  String autoBackupRetentionLimitHint(Object size) {
    return 'स्वचालित सफ़ाई स्वचालित स्नैपशॉट को $size से नीचे रखती है। सुरक्षा स्नैपशॉट और मैनुअल निर्यात अलग रखे जाते हैं।';
  }

  @override
  String get createSnapshotNow => 'अभी बैकअप करें';

  @override
  String get backupLocationMenu => 'स्थान बदलें';

  @override
  String get defaultBackupLocation => 'डिफ़ॉल्ट बैकअप फ़ोल्डर पथ';

  @override
  String get defaultBackupLocationAndroidDesc =>
      'Memex का ऐप-विशिष्ट बाहरी फ़ाइल फ़ोल्डर उपयोग करें। स्टोरेज अनुमति की ज़रूरत नहीं।';

  @override
  String get chooseBackupLocation => 'बैकअप फ़ोल्डर चुनें';

  @override
  String get chooseBackupLocationAndroidDesc =>
      'Android सिस्टम चयनकर्ता से फ़ोल्डर चुनें और Memex को स्थायी पहुँच दें।';

  @override
  String get storedBackups => 'संग्रहीत बैकअप';

  @override
  String get noStoredBackups =>
      'पहले स्नैपशॉट के बाद स्वचालित बैकअप यहाँ दिखेंगे।';

  @override
  String get backupTypeAutoSnapshot => 'स्वचालित स्नैपशॉट प्रकार';

  @override
  String get backupTypeSafetySnapshot => 'सुरक्षा स्नैपशॉट प्रकार';

  @override
  String get backupTypeManualBackup => 'मैनुअल बैकअप प्रकार';

  @override
  String get refresh => 'रीफ़्रेश करें';

  @override
  String get restoreThisBackup => 'यह बैकअप बहाल करें';

  @override
  String get deleteThisBackup => 'यह बैकअप हटाएँ करें';

  @override
  String get confirmDeleteBackup => 'बैकअप हटाएँ करें?';

  @override
  String confirmDeleteBackupMessage(Object fileName) {
    return '$fileName हटाएँ? इससे संग्रहीत बैकअप फ़ाइल हट जाएगी और वापस नहीं आ सकेगी।';
  }

  @override
  String backupDeleted(Object fileName) {
    return 'बैकअप हटाएँ हुआ: $fileName';
  }

  @override
  String backupDeleteFailed(Object error) {
    return 'बैकअप हटाएँ नहीं हो सका: $error';
  }

  @override
  String get creatingSafetySnapshot => 'सुरक्षा स्नैपशॉट बन रहा है...';

  @override
  String autoBackupCreated(Object fileName) {
    return 'स्नैपशॉट बना: $fileName';
  }

  @override
  String backupLocationFailed(Object error) {
    return 'बैकअप स्थान अपडेट नहीं हो सकी: $error';
  }

  @override
  String get backupImportCreatedAt => 'बनने का समय';

  @override
  String get backupImportSourceVersion => 'स्रोत संस्करण जानकारी';

  @override
  String get backupImportFlavor => 'बिल्ड';

  @override
  String get backupLegacyFormat => 'पुराना बैकअप (मैनिफ़ेस्ट नहीं)';

  @override
  String get restoreInProgress => 'बैकअप बहाल हो रहा है...';

  @override
  String get dataStorage => 'डेटा स्टोरेज';

  @override
  String get dataStorageDescriptionAndroid =>
      'वर्कस्पेस सहेजें करने के लिए कस्टम फ़ोल्डर चुनें। ऐप दोबारा इंस्टॉल करने पर डेटा बना रहता है।';

  @override
  String get dataStorageDescriptionIOS =>
      'डिवाइसों के बीच वर्कस्पेस सिंक करने और दोबारा इंस्टॉल करने के बाद डेटा रखने के लिए iCloud चालू करें।';

  @override
  String get storageLocationApp => 'ऐप स्टोरेज स्थान';

  @override
  String get storageLocationAppDesc =>
      'डेटा ऐप के भीतर संग्रहीत रहता है और अनइंस्टॉल करने पर हट जाएगा।';

  @override
  String get storageLocationCustom => 'डिवाइस स्टोरेज (कस्टम फ़ोल्डर चुनें)';

  @override
  String get storageLocationCustomDesc =>
      'डेटा आपके चुने फ़ोल्डर में सहेजें करें। फ़ोल्डर रहने पर दोबारा इंस्टॉल करने के बाद डेटा बना रहता है।';

  @override
  String get storageLocationICloud => 'iCloud में सहेजें करें';

  @override
  String get storageLocationICloudDesc =>
      'Apple डिवाइस के बीच वर्कस्पेस सिंक करें। दोबारा इंस्टॉल करने के बाद डेटा रहता है।';

  @override
  String storageLocationCurrent(Object location) {
    return 'मौजूदा: $location';
  }

  @override
  String get icloudRequiresCapability =>
      'iCloud स्टोरेज उपयोग करने के लिए iCloud में साइन इन करें और iCloud ड्राइव चालू करें।';

  @override
  String get loadingFromICloud => 'iCloud से डेटा बहाल हो रहा है…';

  @override
  String get switchingToICloud => 'iCloud स्टोरेज पर स्विच हो रहा है…';

  @override
  String get switchingStorage => 'स्टोरेज स्विच हो रहा है…';

  @override
  String get customFolderAccessDenied =>
      'इस फ़ोल्डर को पढ़ या लिख नहीं कर सकते। कृपया स्टोरेज अनुमति दें या दूसरा स्थान चुनें।';

  @override
  String get configured => 'कॉन्फ़िगर है';

  @override
  String get apiKeyNotSet =>
      'एपीआई कुंजी सेट नहीं है — कॉन्फ़िगर करने के लिए टैप करें';

  @override
  String get bottomNavTimeline => 'टाइमलाइन टैब';

  @override
  String get bottomNavLibrary => 'लाइब्रेरी टैब';

  @override
  String get aiGeneratedLabel => 'एआई बनाया गया';

  @override
  String sourceTraceWithCount(Object count) {
    return 'स्रोत ट्रेस ($count)';
  }

  @override
  String get deleteAccount => 'खाता हटाएँ करें';

  @override
  String get deleteAccountDesc =>
      'सारा स्थानीय डेटा स्थायी रूप से हटाएँ करें और ऐप रीसेट करें।';

  @override
  String get deleteAccountConfirmTitle => 'खाता हटाएँ करें?';

  @override
  String get deleteAccountConfirmMessage =>
      'इससे टाइमलाइन कार्ड, ज्ञान आधार, रिकॉर्डिंग और सेटिंग्स सहित आपका सारा डेटा स्थायी रूप से हटाएँ हो जाएगा। यह कार्रवाई वापस नहीं की जा सकती।';

  @override
  String deleteAccountTypeName(Object name) {
    return 'पुष्टि करने के लिए \"$name\" दर्ज करें';
  }

  @override
  String get deleteAccountTypeHint =>
      'पुष्टि करें करने के लिए अपना उपयोगकर्ता नाम दर्ज करें';

  @override
  String get llmConsentTitle => 'डेटा साझाकरण सहमति';

  @override
  String llmConsentMessage(Object provider) {
    return 'एआई सुविधाएँ चालू करने के लिए Memex को आपका डेटा प्रोसेसिंग के लिए $provider को भेजना होगा। इसमें शामिल है:\n\n• आपके द्वारा दर्ज पाठ (नोट्स, वाणी लिप्यंतरण)\n• फोटो मेटाडेटा और निकाला गया पाठ (ओसीआर)\n• स्वास्थ्य और फ़िटनेस सारांश\n• टाइमलाइन कार्ड सामग्री\n\nआपका डेटा आपके डिवाइस से सीधे $provider को भेजा जाता है। Memex आपका डेटा किसी दूसरे सर्वर पर संग्रहीत या रिले नहीं करता।\n\nकृपया देखें कि $provider आपकी डेटा गोपनीयता कैसे संभालता है।\n\nक्या आप एआई प्रोसेसिंग के लिए अपना डेटा $provider को भेजने से सहमत हैं?';
  }

  @override
  String get llmConsentAgree => 'मैं सहमत हूँ';

  @override
  String get llmConsentDecline => 'अस्वीकार करें';

  @override
  String get customAgents => 'कस्टम एजेंट';

  @override
  String get noCustomAgents => 'कोई कस्टम एजेंट कॉन्फ़िगर नहीं है।';

  @override
  String get deleteAgent => 'एजेंट हटाएँ करें';

  @override
  String deleteAgentConfirm(Object name) {
    return 'कस्टम एजेंट \"$name\" हटाएँ?';
  }

  @override
  String get deleted => 'हटाया गया';

  @override
  String get saved => 'सहेजा गया';

  @override
  String get newAgent => 'नया एजेंट';

  @override
  String get editAgent => 'संपादित एजेंट';

  @override
  String get agentName => 'एजेंट नाम';

  @override
  String get agentNameHint => 'my-custom-agent';

  @override
  String get agentNameRequired => 'आवश्यक';

  @override
  String get agentNameInvalid => 'सिर्फ़ अक्षर, अंक और हाइफ़न';

  @override
  String get agentNameExists => 'नाम पहले से मौजूद है';

  @override
  String get hostAgentType => 'होस्ट एजेंट प्रकार';

  @override
  String get skillDirectory => 'कौशल निर्देशिका';

  @override
  String get skillDirInvalid => 'सापेक्ष पथ होना चाहिए (शुरुआती / या .. नहीं)';

  @override
  String get workingDirectory => 'कार्य निर्देशिका (वैकल्पिक)';

  @override
  String get workingDirectoryHint => 'वर्कस्पेस डिफ़ॉल्ट के लिए खाली छोड़ें';

  @override
  String get llmConfig => 'एलएलएम कॉन्फ़िगरेशन';

  @override
  String get eventType => 'ईवेंट प्रकार';

  @override
  String get executionMode => 'निष्पादन मोड';

  @override
  String get executionModeAsync => 'असिंक्रोनस मोड';

  @override
  String get executionModeSync => 'सिंक्रोनस मोड';

  @override
  String get dependsOn => 'निर्भर करता है';

  @override
  String get dependsOnHint => 'निर्भरताएँ चुनें';

  @override
  String get priority => 'प्राथमिकता स्तर';

  @override
  String get maxRetries => 'अधिकतम पुनः प्रयास';

  @override
  String get systemPromptLabel => 'सिस्टम प्रॉम्प्ट (वैकल्पिक)';

  @override
  String get systemPromptHint =>
      'होस्ट एजेंट प्रॉम्प्ट में जोड़े जाने वाले अतिरिक्त निर्देश';

  @override
  String get eventSerializer => 'ईवेंट सीरियलाइज़र';

  @override
  String get eventSerializerDefault => 'डिफ़ॉल्ट सीरियलाइज़र (XML)';

  @override
  String get enabledLabel => 'चालू';

  @override
  String get skillsManagement => 'कौशल प्रबंधन';

  @override
  String get skillsManagementEmpty => 'अभी कोई कौशल नहीं';

  @override
  String get downloadSkill => 'कौशल डाउनलोड करें';

  @override
  String get downloadFile => 'फ़ाइल डाउनलोड करें';

  @override
  String get downloading => 'डाउनलोड हो रहा है...';

  @override
  String get downloadSuccess => 'कौशल सफलतापूर्वक डाउनलोड हुई';

  @override
  String downloadFailed(Object error) {
    return 'डाउनलोड विफल: $error';
  }

  @override
  String get deleteConfirm => 'हटाएँ पुष्टि करें';

  @override
  String deleteConfirmMessage(String name) {
    return 'क्या आप \"$name\" हटाना चाहते हैं?';
  }

  @override
  String get invalidUrl => 'कृपया मान्य यूआरएल दर्ज करें';

  @override
  String get urlHint => 'https://example.com/skill.zip';

  @override
  String get newFolder => 'नया फ़ोल्डर';

  @override
  String get newFile => 'नई फ़ाइल';

  @override
  String get folderName => 'फ़ोल्डर नाम';

  @override
  String get fileName => 'फ़ाइल नाम';

  @override
  String get nameRequired => 'नाम आवश्यक है';

  @override
  String get nameInvalid => 'नाम में / या .. नहीं हो सकता';

  @override
  String createFailed(Object error) {
    return 'बनाना विफल: $error';
  }

  @override
  String get fileContent => 'फ़ाइल सामग्री';

  @override
  String get saveSuccess => 'सफलतापूर्वक सहेजें हुआ';

  @override
  String downloadToCurrentDir(String dir) {
    return 'ज़िप मौजूदा निर्देशिका में निकलेगा: $dir';
  }

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get privacyPolicyDesc => 'Memex आपका डेटा कैसे संभालता है';

  @override
  String get llmAuthError =>
      'एपीआई प्रमाणीकरण विफल। कृपया सेटिंग्स में अपना एलएलएम कॉन्फ़िगरेशन जाँचें।';

  @override
  String get llmBadRequestError =>
      'अनुरोध एलएलएम प्रदाता ने अस्वीकार कर दिया। इनपुट फ़ॉर्मैट मौजूदा मॉडल से समर्थित नहीं हो सकता।';

  @override
  String get llmRateLimitError =>
      'एपीआई दर सीमा पार हो गई। कृपया बाद में फिर कोशिश करें।';

  @override
  String get llmServerError =>
      'एलएलएम सेवा अस्थायी रूप से अनुपलब्ध है। कृपया बाद में फिर कोशिश करें।';

  @override
  String get llmNetworkError =>
      'नेटवर्क कनेक्शन विफल। कृपया अपना इंटरनेट कनेक्शन जाँचें।';

  @override
  String get llmUnknownError =>
      'आपकी सामग्री प्रोसेस करते समय अप्रत्याशित त्रुटि हुई।';

  @override
  String get llmErrorDialogTitle => 'प्रोसेसिंग विफल';

  @override
  String get goToModelConfig => 'सेटिंग्स पर जाएँ';

  @override
  String get speechModelDownloadTitle => 'वाणी मॉडल डाउनलोड करें';

  @override
  String speechModelDownloadDesc(Object sizeMB) {
    return 'एक बार मॉडल डाउनलोड (~${sizeMB}MB) करना आवश्यक है।\n\nडाउनलोड के बाद लिप्यंतरण पूरी तरह डिवाइस पर चलेगा।';
  }

  @override
  String get speechModelStartDownload => 'डाउनलोड शुरू करें';

  @override
  String get speechModelChooseSource => 'डाउनलोड स्रोत चुनें:';

  @override
  String get speechModelChinaMirror => '🇨🇳 चीन मिरर (CN में तेज़)';

  @override
  String get speechModelGithub => '🌐 GitHub (वैश्विक स्रोत)';

  @override
  String get speechModelDownloading => 'मॉडल डाउनलोड हो रहा है...';

  @override
  String get speechModelConnecting => 'कनेक्ट हो रहा है...';

  @override
  String get deleteSpeechModel => 'वाणी मॉडल हटाएँ करें';

  @override
  String get confirmDeleteSpeechModelMessage =>
      'डाउनलोड की गई स्थानीय वाणी पहचान मॉडल फ़ाइलें हटाएँ? अगली बार स्थानीय वाणी-से-पाठ उपयोग होने पर ये फिर डाउनलोड होंगी।';

  @override
  String get speechModelDeletedSuccess => 'वाणी मॉडल फ़ाइलें हटाएँ हुईं';

  @override
  String get speechModelNotDownloaded =>
      'कोई डाउनलोड की गई वाणी मॉडल फ़ाइलें नहीं मिलीं';

  @override
  String speechModelDeleteFailed(Object error) {
    return 'वाणी मॉडल फ़ाइलें हटाएँ नहीं हो सकीं: $error';
  }

  @override
  String get speechTranscribing => 'वाणी पहचानी जा रही है...';

  @override
  String get speechNoResult => 'कोई वाणी पहचानी नहीं हुई';

  @override
  String get useLocalSpeechToTextTitle => 'स्थानीय वाणी to पाठ उपयोग करें';

  @override
  String get useLocalSpeechToTextDesc =>
      'चालू होने पर ऑडियो भेजने से पहले डिवाइस पर लिप्यंतरण होता है — उन मॉडल के लिए उपयोगी जो ऑडियो इनपुट का समर्थन नहीं करते। बंद होने पर मूल ऑडियो सीधे मॉडल को भेजा जाता है।';

  @override
  String get pendingAiProcessingHint =>
      'प्रोसेस करने के लिए एआई मॉडल सेटअप करें';

  @override
  String get demoWelcome =>
      'Memex में आपका स्वागत है!\nआइए जल्दी से देखें कि एआई आपके रिकॉर्ड के लिए क्या कर सकता है।';

  @override
  String get demoTapAdd => 'अपना पहला रिकॉर्ड बनाने के लिए यहाँ टैप करें';

  @override
  String get demoTapSend => 'अपना पहला रिकॉर्ड भेजने के लिए टैप करें';

  @override
  String get demoTapCard =>
      'एआई ने आपके रिकॉर्ड को कैसे व्यवस्थित किया, देखने के लिए टैप करें';

  @override
  String get demoDetailHint =>
      'यह आपका एआई द्वारा व्यवस्थित रिकॉर्ड विवरण है। इसे देखें, फिर टूर जारी रखने के लिए वापस जाएँ।';

  @override
  String get demoTapInsight => 'एआई-जनित अंतर्दृष्टियाँ देखने के लिए टैप करें';

  @override
  String get demoTapInsightUpdate =>
      'अपने रिकॉर्ड से अंतर्दृष्टियाँ बनाएँ करने के लिए टैप करें';

  @override
  String get demoTapKnowledge =>
      'स्वचालित रूप से व्यवस्थित ज्ञान फ़ाइलें देखें';

  @override
  String get demoDone => 'अपना जीवन रिकॉर्ड करना शुरू करें।';

  @override
  String get demoStartTour => 'टूर शुरू करें';

  @override
  String get demoGetStarted => 'शुरू करें';

  @override
  String get demoSkip => 'छोड़ें';

  @override
  String get demoPrefillText => 'नमस्ते Memex! यह मेरा पहला रिकॉर्ड है 🎉';

  @override
  String get visionBadge => 'विज़न';

  @override
  String get notMultimodalHint =>
      'मीडिया विश्लेषण के लिए Memex मल्टीमॉडल मॉडल क्षमताएँ पर निर्भर करता है। अगर आपके रिकॉर्ड में छवियाँ हैं, तो सुनिश्चित करें कि कॉन्फ़िगर मॉडल छवि इनपुट समर्थन करता है।';

  @override
  String get defaultModelPrefix => 'डिफ़ॉल्ट';

  @override
  String get recommendedBadge => 'अनुशंसित विकल्प';

  @override
  String get readOnlyBadge => 'CHAT';

  @override
  String get switchCompanion => 'साथी बदलें';

  @override
  String get personaChatInputHint => 'संदेश प्रकार करें...';

  @override
  String get today => 'आज';

  @override
  String get tomorrow => 'कल';

  @override
  String get yesterday => 'कल';

  @override
  String get showInsightTextTitle => 'Memex अंतर्दृष्टि टिप्पणी दिखाएँ';

  @override
  String get showInsightTextDesc =>
      'कार्ड विवरण टिप्पणी सेक्शन में Memex अंतर्दृष्टि को पिन की गई टिप्पणी के रूप में दिखाना है या नहीं।';

  @override
  String get enableCharacterCommentTitle => 'चरित्र स्वचालित टिप्पणी चालू करें';

  @override
  String get enableCharacterCommentDesc =>
      'चरित्र नए रिकॉर्ड पर अपने आप टिप्पणी करते हैं।';

  @override
  String get maxCommentCharactersTitle =>
      'अधिकतम टिप्पणी करने वाले चरित्र सीमा';

  @override
  String get maxCommentCharactersDesc =>
      'हर रिकॉर्ड पर कितने चरित्र टिप्पणी कर सकते हैं।';

  @override
  String replyTo(String name) {
    return '$name को जवाब करें';
  }

  @override
  String get cdnSignalsComments => 'नया जवाब मिला';

  @override
  String get cdnSignalsInsight => 'नया अंतर्दृष्टि बनाएँ हुआ';

  @override
  String get cdnSignalsBoth => 'नया जवाब और अंतर्दृष्टि';

  @override
  String get untitledCard => 'शीर्षक रहित कार्ड शीर्षक';

  @override
  String get locationContextTitle => 'स्थान संदर्भ';

  @override
  String get locationContextDescription =>
      'एजेंट चैट के लिए मौजूदा शहर और इलाका संदर्भ';

  @override
  String get locationContextAttachTitle => 'मौजूदा स्थान चैट में जोड़ें करें';

  @override
  String get locationContextAttachDesc =>
      'एजेंट को शहर, ज़िला और इलाका संदर्भ देने के लिए डिवाइस जीपीएस और रिवर्स जियोकोडिंग उपयोग करता है।';

  @override
  String get reverseGeocodingProvider => 'रिवर्स जियोकोडिंग प्रदाता सेटिंग';

  @override
  String get amapProviderName => 'Amap';

  @override
  String get amapApiKey => 'Amap एपीआई कुंजी';

  @override
  String get amapGcj02Note =>
      'Amap GCJ-02 निर्देशांक उपयोग करता है। रिवर्स जियोकोडिंग से पहले डिवाइस जीपीएस बदला जाता है।';

  @override
  String get contextGranularity => 'संदर्भ सूक्ष्मता स्तर';

  @override
  String get granularityCity => 'शहर स्तर';

  @override
  String get granularityDistrict => 'ज़िला स्तर';

  @override
  String get granularityNeighborhood => 'इलाका स्तर';

  @override
  String get granularityStreet => 'सड़क स्तर';

  @override
  String get granularityFullAddress => 'पूर्ण पता उम्मीदवार स्तर';

  @override
  String get locationFreshness => 'स्थान ताज़गी सीमा';

  @override
  String minutesShort(int minutes) {
    return '$minutes मिनट';
  }

  @override
  String get oneHour => '1 घंटा';

  @override
  String get testCurrentLocation => 'मौजूदा स्थान परीक्षण करें';

  @override
  String locationTestFailed(String error) {
    return 'विफल हुआ: $error';
  }

  @override
  String get locationDebugGps => 'जीपीएस';

  @override
  String get locationDebugReverseGeocode => 'रिवर्स जियोकोड चरण';

  @override
  String get locationDebugProvider => 'प्रदाता नाम';

  @override
  String get locationDebugAgentContext => 'एजेंट संदर्भ डेटा';

  @override
  String get locationDebugSource => 'स्रोत नाम';

  @override
  String get locationDebugAddressSummary => 'पता सारांश विवरण';

  @override
  String get locationDebugFullAddress => 'पूर्ण पता विवरण';

  @override
  String get locationDebugCoordinates => 'निर्देशांक मान';

  @override
  String get locationDebugAccuracy => 'सटीकता मान';

  @override
  String get locationDebugReason => 'कारण विवरण';

  @override
  String get locationDebugOk => 'OK';

  @override
  String get locationDebugUnavailable => 'उपलब्ध नहीं';

  @override
  String get locationDebugInjected => 'जोड़ें किया गया';

  @override
  String get locationDebugNotInjected => 'जोड़ें नहीं किया गया';

  @override
  String get locationStatusUpdatedAt => 'अपडेट समय';

  @override
  String get locationStatusSuccessTitle => 'मौजूदा स्थान तैयार है';

  @override
  String get locationStatusSuccessBody =>
      'स्थान संदर्भ प्रासंगिक होने पर Memex यह स्थान सारांश जोड़ें कर सकता है।';

  @override
  String get locationStatusApproximateTitle => 'सिर्फ़ अनुमानित स्थान';

  @override
  String get locationStatusApproximateBody =>
      'सटीकता शहर या क्षेत्र स्तर की लगती है। आप इसे उपयोग कर सकते हैं, या सख़्त संदर्भ के लिए सिस्टम सेटिंग्स में सटीक स्थान चालू करें।';

  @override
  String get locationStatusServiceDisabledTitle => 'सिस्टम स्थान बंद है';

  @override
  String get locationStatusServiceDisabledBody =>
      'Memex सिर्फ़ डिवाइस जीपीएस उपयोग करता है और नेटवर्क या IP से स्थान अनुमान नहीं करेगा। Android पर स्थान सेटिंग्स खोलें; iOS पर सेटिंग्स > गोपनीयता और सुरक्षा > स्थान सेवाएँ चालू करें।';

  @override
  String get locationStatusPermissionDeniedTitle => 'स्थान अनुमति चाहिए';

  @override
  String get locationStatusPermissionDeniedBody =>
      'परीक्षण करते समय या स्थान संदर्भ ज़रूरी होने पर Memex को स्थान उपयोग करने दें। हमेशा पहुँच अनुरोध नहीं किया जाता।';

  @override
  String get locationStatusPermissionForeverTitle => 'स्थान अनुमति bलॉक है';

  @override
  String get locationStatusPermissionForeverBody =>
      'ऐप सेटिंग्स खोलकर Memex के लिए स्थान अनुमति दें। iOS पर ऐप उपयोग के दौरान पर्याप्त है।';

  @override
  String get locationStatusDisabledTitle => 'स्थान संदर्भ बंद है';

  @override
  String get locationStatusDisabledBody =>
      'जब आप चाहें कि Memex डिवाइस स्थान को एजेंट संदर्भ में जोड़े, ऊपर स्विच चालू करके सहेजें।';

  @override
  String get locationStatusGeocodeUnavailableTitle =>
      'जीपीएस काम कर रहा है, पता खोज विफल';

  @override
  String get locationStatusGeocodeUnavailableBody =>
      'Memex के पास निर्देशांक हैं लेकिन वह सिर्फ़ जीपीएस संदर्भ एजेंट में नहीं जोड़ेगा। रिवर्स जियोकोडिंग प्रदाता जाँचें और फिर कोशिश करें।';

  @override
  String get locationStatusUnavailableTitle => 'स्थान उपलब्ध नहीं है';

  @override
  String get locationStatusUnavailableBody =>
      'सिस्टम स्थान सेवाएँ और ऐप अनुमति जाँचें, फिर परीक्षण करें।';

  @override
  String get allowLocationPermissionButton => 'स्थान अनुमति दें';

  @override
  String get openAppSettingsButton => 'ऐप सेटिंग्स खोलें';

  @override
  String get openLocationSettingsButton => 'स्थान सेटिंग्स खोलें';

  @override
  String get locationSettingsOpenFailed => 'सिस्टम सेटिंग्स खुल नहीं सकीं।';

  @override
  String locationActionFailed(String error) {
    return 'स्थान कार्रवाई विफल: $error';
  }

  @override
  String get settingsSearchPlaceholder => 'सेटिंग्स खोजें...';

  @override
  String get settingsSearchEmpty => 'कोई मिलती-जुलती सेटिंग नहीं मिली';

  @override
  String get importCharacterCard => 'चरित्र कार्ड आयात करें';

  @override
  String get firstMessageLabel => 'पहला संदेश';

  @override
  String get firstMessageHint =>
      'पहली बातचीत पर भेजा जाने वाला अभिवादन (वैकल्पिक)';

  @override
  String get systemPromptOverrideLabel => 'सिस्टम प्रॉम्प्ट ओवरराइड';

  @override
  String get systemPromptOverrideHint =>
      'डिफ़ॉल्ट सिस्टम प्रॉम्प्ट ओवरराइड करें (उन्नत, वैकल्पिक)';

  @override
  String get postHistoryInstructionsLabel => 'इतिहास के बाद निर्देश';

  @override
  String get postHistoryInstructionsHint =>
      'चैट इतिहास के बाद, जवाब से पहले जोड़े जाने वाले निर्देश (वैकल्पिक)';

  @override
  String get mesExampleLabel => 'संदेश उदाहरण';

  @override
  String get mesExampleHint =>
      'चरित्र शैली दिखाने वाले उदाहरण संवाद (वैकल्पिक)';

  @override
  String get worldBookTitle => 'विश्व पुस्तक';

  @override
  String get worldBookSubtitle =>
      'कीवर्ड ट्रिगर होने पर जोड़ा जाने वाला पृष्ठभूमि ज्ञान';

  @override
  String get characterMemoryTitle => 'चरित्र स्मृति';

  @override
  String get characterMemorySubtitle =>
      'चरित्र और उपयोगकर्ता के बीच रिश्ता गतिशीलता और इंटरैक्शन स्मृतियाँ';

  @override
  String get addTooltip => 'जोड़ें';

  @override
  String get constantBadge => 'स्थिर बैज';

  @override
  String worldEntryFallbackName(Object index) {
    return 'प्रविष्टि $index नाम';
  }

  @override
  String keywordsPrefix(Object keys) {
    return 'कीवर्ड सूची: $keys';
  }

  @override
  String memoryFallbackName(Object index) {
    return 'स्मृति $index नाम';
  }

  @override
  String get addWorldEntry => 'विश्व पुस्तक प्रविष्टि जोड़ें';

  @override
  String get editWorldEntry => 'विश्व पुस्तक प्रविष्टि संपादित करें';

  @override
  String get commentTitleLabel => 'टिप्पणी / शीर्षक';

  @override
  String get entryDescriptionHint => 'प्रविष्टि विवरण (वैकल्पिक पाठ)';

  @override
  String get triggerKeywordsLabel => 'ट्रिगर कीवर्ड';

  @override
  String get triggerKeywordsHint => 'अल्पविराम से अलग, जैसे: जादू, मंत्र';

  @override
  String get contentLabel => 'सामग्री पाठ';

  @override
  String get worldEntryContentHint =>
      'कीवर्ड ट्रिगर होने पर जोड़ा जाने वाला पृष्ठभूमि ज्ञान';

  @override
  String get enabledCheckbox => 'चालू';

  @override
  String get addMemory => 'स्मृति जोड़ें';

  @override
  String get editMemory => 'स्मृति संपादित करें';

  @override
  String get memoryLabelField => 'लेबल नाम';

  @override
  String get memoryLabelHint => 'विशिष्ट पहचानकर्ता, जैसे: नाम पसंद';

  @override
  String get memoryContentHint => 'स्मृति सामग्री पाठ';

  @override
  String get salienceLabel => 'महत्त्व मान: ';

  @override
  String get labelCannotBeEmpty => 'लेबल खाली नहीं हो सकता';

  @override
  String importSuccess(Object name) {
    return '$name सफलतापूर्वक आयात हुआ';
  }

  @override
  String importFailed(Object error) {
    return 'आयात विफल: $error';
  }

  @override
  String get supportedFormats => 'समर्थित फ़ॉर्मैट';

  @override
  String get tavernImportDescription =>
      '• SillyTavern V2 चरित्र कार्ड (.json)\n• एम्बेडेड कार्ड वाली PNG छवियाँ (.png)\n\nव्यक्तित्व, विश्व पुस्तक आदि फ़ील्ड अपने आप Memex चरित्र फ़ॉर्मैट में मैप हो जाएँगे।';

  @override
  String get pickCharacterFile => 'चरित्र फ़ाइल चुनें';

  @override
  String get repickFile => 'दूसरी फ़ाइल चुनें';

  @override
  String get personaSettingSection => 'व्यक्तित्व';

  @override
  String get systemPromptSection => 'सिस्टम प्रॉम्प्ट';

  @override
  String worldEntriesCount(Object count) {
    return 'विश्व पुस्तक: $count प्रविष्टियाँ कुल';
  }

  @override
  String fileLabel(Object filename) {
    return 'फ़ाइल नाम: $filename';
  }

  @override
  String conflictWarning(Object names) {
    return 'इसी नाम वाला चरित्र पहले से मौजूद है: $names। आयात करने पर मौजूदा चरित्रों को ओवरराइट किए बिना नया चरित्र बनेगा।';
  }

  @override
  String get setPrimaryCompanionTitle => 'मुख्य साथी के रूप में सेट करें';

  @override
  String get setPrimaryCompanionSubtitle =>
      'आयात के बाद अपने आप आपका मुख्य साथी सेट करें';

  @override
  String get confirmImport => 'आयात पुष्टि करें';

  @override
  String get chatBackground => 'चैट पृष्ठभूमि';

  @override
  String get chooseChatBackgroundImage => 'पृष्ठभूमि छवि चुनें';

  @override
  String get earlyUpdateSettingsTitle => 'अर्ली एक्सेस अपडेट सेटिंग';

  @override
  String get earlyUpdateSettingsDesc =>
      'मिलती अर्ली APK के लिए GitHub प्री-रिलीज़ जाँच करें, डाउनलोड करें, और Android इंस्टॉलर को दें।';

  @override
  String get earlyUpdateUnsupported =>
      'अर्ली अपडेट सिर्फ़ Android अर्ली बिल्ड में उपलब्ध हैं।';

  @override
  String get earlyUpdateAutoCheckTitle => 'अपडेट के लिए स्वचालित जाँच';

  @override
  String get earlyUpdateAutoCheckDesc =>
      'स्टार्टअप पर हर 12 घंटे में अधिकतम एक बार जाँच करें।';

  @override
  String get earlyUpdateWifiOnlyTitle => 'सिर्फ़ Wi-Fi पर डाउनलोड';

  @override
  String get earlyUpdateWifiOnlyDesc =>
      'मोबाइल डेटा उपयोग करते समय अपडेट डाउनलोड छोड़ें।';

  @override
  String get earlyUpdateAutoInstallTitle => 'स्वचालित डाउनलोड और इंस्टॉल';

  @override
  String get earlyUpdateAutoInstallDesc =>
      'नई बिल्ड मिलने पर उसे डाउनलोड करके Android इंस्टॉलर अपने आप खोलें।';

  @override
  String get earlyUpdateCheckNow => 'अभी जाँच करें';

  @override
  String get earlyUpdateChecking => 'GitHub प्री-रिलीज़ जाँच हो रहे हैं...';

  @override
  String get earlyUpdateSkippedMobile =>
      'सिर्फ़ Wi-Fi डाउनलोड चालू हैं, इसलिए छोड़ा गया।';

  @override
  String get earlyUpdateNoUpdate => 'आप नवीनतम अर्ली बिल्ड पर हैं।';

  @override
  String earlyUpdateFound(Object version, Object build) {
    return 'अर्ली बिल्ड $version+$build उपलब्ध है।';
  }

  @override
  String get earlyUpdateDownloadAndInstall => 'डाउनलोड और इंस्टॉल';

  @override
  String get earlyUpdateDownloadInProgress => 'अपडेट डाउनलोड हो रहा है...';

  @override
  String earlyUpdateDownloadingPercent(Object percent) {
    return 'अपडेट डाउनलोड हो रहा है: $percent%';
  }

  @override
  String get earlyUpdateDownloadReadyToInstall =>
      'अपडेट पैकेज डाउनलोड हो गया। इंस्टॉल के लिए तैयार।';

  @override
  String get earlyUpdateInstallDownloadedPackage =>
      'डाउनलोड किया गया पैकेज इंस्टॉल करें';

  @override
  String get earlyUpdateClearDownloadedPackage =>
      'डाउनलोड किया गया पैकेज साफ़ करें';

  @override
  String get earlyUpdateClearDownloadedPackageSuccess =>
      'डाउनलोड किया गया अपडेट पैकेज साफ़ किया गया।';

  @override
  String get earlyUpdateInstallStarted => 'Android इंस्टॉलर खुला।';

  @override
  String get earlyUpdateInstallPermissionRequired =>
      'Memex को अज्ञात ऐप इंस्टॉल करने दें, फिर डाउनलोड और इंस्टॉल दोबारा टैप करें।';

  @override
  String earlyUpdateLastChecked(Object time) {
    return 'पिछली जाँच: $time';
  }

  @override
  String earlyUpdateCheckFailed(Object error) {
    return 'अपडेट जाँच विफल: $error';
  }

  @override
  String get earlyUpdateDialogTitle => 'अर्ली अपडेट उपलब्ध है';

  @override
  String get earlyUpdateReleaseNotes => 'रिलीज़ नोट्स देखें';

  @override
  String get dismissAllNotifications => 'सभी साफ़ करें';

  @override
  String get dismissByType => 'प्रकार के अनुसार साफ़ करें';

  @override
  String get dismissTypeSystemAction => 'रिमाइंडर और ईवेंट';

  @override
  String get dismissTypeClarification => 'स्पष्टीकरण साफ़ करें';

  @override
  String get dismissTypeCardUpdate => 'कार्ड अपडेट साफ़ करें';

  @override
  String dismissedCount(Object count) {
    return '$count साफ़ किए गए';
  }

  @override
  String get dataImportTitle => 'फ़ाइलें आयात करें';

  @override
  String get dataImportSettingsDescription =>
      'पुरानी फ़ाइलें Memex में लाएँ, फिर तय करें कि उन्हें व्यवस्थित करना है या नहीं।';

  @override
  String get dataImportDescription =>
      'पुराने नोट्स, निर्यात किए गए रिकॉर्ड, दस्तावेज़ या ZIP आर्काइव चुनें। Memex पहले एक कॉपी सुरक्षित रखता है और मूल फ़ाइलों को नहीं बदलता। आयात के बाद आप तय कर सकते हैं कि Memex उन्हें व्यवस्थित करे या नहीं।';

  @override
  String get dataImportSelectFiles => 'आयात करने के लिए फ़ाइलें चुनें';

  @override
  String get dataImportImporting => 'फ़ाइलें सहेजी जा रही हैं...';

  @override
  String get dataImportSuccess => 'फ़ाइलें Memex में सहेजी गईं';

  @override
  String get dataImportOnlyStored =>
      'फ़ाइलें सहेजी गईं। कोई व्यवस्था शुरू नहीं हुई।';

  @override
  String get dataImportQueued =>
      'Memex इस आयात को पृष्ठभूमि में व्यवस्थित करेगा।';

  @override
  String get dataImportResultTitle => 'आयात पूरा हुआ';

  @override
  String dataImportResultSummary(Object count) {
    return '$count फ़ाइलें सहेजी गईं। आप उन्हें अभी व्यवस्थित कर सकते हैं या मूल स्रोत सामग्री के रूप में रख सकते हैं।';
  }

  @override
  String dataImportRenamedConflicts(Object count) {
    return 'एक ही नाम वाले $count आइटमों का नाम बदला गया ताकि कुछ भी ओवरराइट न हो।';
  }

  @override
  String dataImportSkippedUnsafeEntries(Object count) {
    return 'आर्काइव के $count असामान्य आइटम छोड़े गए; बाकी सामग्री सामान्य रूप से आयात हुई।';
  }

  @override
  String get dataImportChooseProcessing => 'इन फ़ाइलों को व्यवस्थित करें';

  @override
  String get dataImportProcessTitle => 'इस आयात को व्यवस्थित करना है?';

  @override
  String dataImportProcessPrompt(Object count) {
    return 'आपने $count फ़ाइलें आयात की हैं। चुनें कि Memex उन्हें अभी व्यवस्थित करे या केवल मूल फ़ाइलें रखे।';
  }

  @override
  String get dataImportProcessKnowledgeBase => 'ज्ञान आधार में व्यवस्थित करें';

  @override
  String get dataImportProcessKnowledgeBaseDesc =>
      'दस्तावेज़, नोट्स, प्रोजेक्ट सामग्री और संदर्भों के लिए अच्छा है। Memex उपयोगी जानकारी निकालेगा और बाद में उपयोग के लिए समूहित करेगा।';

  @override
  String get dataImportProcessTimelineCards => 'टाइमलाइन रिकॉर्ड बनाएँ';

  @override
  String get dataImportProcessTimelineCardsDesc =>
      'डायरी, चैट लॉग, गतिविधि इतिहास और पुराने निर्यातों के लिए अच्छा है। Memex समय-आधारित सामग्री को उचित होने पर रिकॉर्ड में बदलेगा।';

  @override
  String get dataImportImpactNone =>
      'Memex केवल इन मूल फ़ाइलों को रखेगा। कोई AI व्यवस्था शुरू नहीं होगी।';

  @override
  String get dataImportImpactKnowledgeBase =>
      'Memex इन फ़ाइलों को पढ़ेगा और लंबे समय तक काम आने वाली जानकारी को ज्ञान आधार में व्यवस्थित करेगा। यह अपने आप टाइमलाइन रिकॉर्ड नहीं बनाएगा।';

  @override
  String get dataImportImpactTimelineCards =>
      'Memex इन फ़ाइलों को पढ़ेगा और जीवन की घटनाओं या तारीख वाले इतिहास के लिए टाइमलाइन रिकॉर्ड बनाएगा। यह अपने आप ज्ञान आधार व्यवस्थित नहीं करेगा।';

  @override
  String get dataImportImpactBoth =>
      'Memex टाइमलाइन रिकॉर्ड बनाने और दोबारा उपयोग होने वाली जानकारी को ज्ञान आधार में व्यवस्थित करने की कोशिश करेगा। यह पूर्ण निजी आर्काइव के लिए सबसे उपयुक्त है।';

  @override
  String get dataImportFinish => 'केवल सहेजें';

  @override
  String get noImages => 'कोई चित्र नहीं';

  @override
  String get noMessages => 'कोई संदेश नहीं';

  @override
  String get sketchContent => 'स्केच';

  @override
  String get emptyFolder => 'खाली फ़ोल्डर';

  @override
  String get usernameAlreadyTaken => 'यह उपयोगकर्ता नाम पहले से लिया गया है';

  @override
  String get registrationFailed => 'पंजीकरण असफल';

  @override
  String get loginFailed => 'लॉगिन असफल';

  @override
  String get paymentCreationFailed => 'भुगतान शुरू नहीं हो सका';

  @override
  String get completePayment => 'भुगतान पूरा करें';

  @override
  String get commentReplyToYou => 'आप';
}
