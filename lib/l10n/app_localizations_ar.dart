// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get timesLabel => 'مرات';

  @override
  String modelSetAsDefault(Object modelId) {
    return 'تعيين $modelId كنموذج افتراضي';
  }

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get unknownModel => 'نموذج غير معروف';

  @override
  String get notSet => 'غير محدد';

  @override
  String get confirmClear => 'تأكيد المسح';

  @override
  String get confirmClearTokenMessage =>
      'هل تريد مسح المستخدم الحالي؟ ستحتاج إلى إدخال معرف المستخدم مرة أخرى.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get tokenCleared => 'تم مسح المستخدم';

  @override
  String clearTokenFailed(Object error) {
    return 'فشل مسح المستخدم: $error';
  }

  @override
  String get selectDateRangeOptional => 'اختر نطاق التاريخ (اختياري):';

  @override
  String get startDate => 'تاريخ البدء';

  @override
  String get endDate => 'تاريخ الانتهاء';

  @override
  String get select => 'اختيار';

  @override
  String get processLimitOptional => 'حد المعالجة (اختياري)';

  @override
  String get leaveEmptyForAll => 'اتركه فارغا لمعالجة الكل';

  @override
  String get startProcessing => 'بدء المعالجة';

  @override
  String get userIdNotFound => 'لم يتم العثور على معرف المستخدم';

  @override
  String createTaskFailed(Object error) {
    return 'فشل إنشاء المهمة: $error';
  }

  @override
  String get reprocessCards => 'إعادة معالجة البطاقات';

  @override
  String get reprocessCardsTaskCreated =>
      'تم وضع طلب إعادة المعالجة في قائمة الوكيل الفائق';

  @override
  String get reprocessCardsDownstreamMode => 'النطاق';

  @override
  String get reprocessCardsCardOnly => 'البطاقات فقط';

  @override
  String get reprocessCardsCardOnlyDesc =>
      'اطلب من الوكيل الفائق مراجعة بطاقات الخط الزمني المحددة وإعادة إنشائها.';

  @override
  String get reprocessCardsRerunDownstream => 'البطاقات والمتابعات المرتبطة';

  @override
  String get reprocessCardsRerunDownstreamDesc =>
      'اطلب من الوكيل الفائق أن يأخذ تحديثات PKM والجدول والرؤى المرتبطة في الحسبان عند الحاجة.';

  @override
  String get reanalyzeMediaAssets => 'إعادة قراءة مرفقات الوسائط';

  @override
  String get reanalyzeMediaAssetsDesc =>
      'اطلب من الوكيل الفائق فحص الوسائط المرفقة مرة أخرى عند إعادة إنشاء البطاقات.';

  @override
  String get regenerateComments => 'إعادة إنشاء التعليقات';

  @override
  String get regenerateCommentsTaskCreated =>
      'تم إنشاء مهمة إعادة إنشاء التعليقات، وتعمل في الخلفية';

  @override
  String get rebuildSearchIndex => 'إعادة بناء فهرس البحث';

  @override
  String get rebuildSearchIndexSuccess => 'تمت إعادة بناء فهرس البحث بنجاح';

  @override
  String get rebuildSearchIndexFailed => 'فشل إعادة بناء فهرس البحث';

  @override
  String get clearData => 'مسح البيانات';

  @override
  String get confirmClearDataMessage => 'مسح البيانات؟';

  @override
  String get confirmClearDataDeletesWorkspaceMessage =>
      'سيتم حذف كل بيانات مساحة العمل المحلية للمستخدم الحالي، بما في ذلك البطاقات والوسائط وملفات المعرفة والرؤى والذاكرة وسجل الدردشة وحالة النظام.\n\nلا يمكن التراجع عن هذا الإجراء!';

  @override
  String get clearFailedAgentContexts => 'مسح سياق المحادثة الفاشل';

  @override
  String get confirmClearFailedAgentContextsMessage =>
      'هل تريد مسح سياق المحادثة المحفوظ لوكلاء الرؤى والجدولة؟ هذا مفيد بعد تغيير النماذج عندما لا تعود رسائل الوكيل السابقة متوافقة. لن يتم حذف الحقائق أو البطاقات أو المعرفة أو الذكريات أو إعدادات النموذج.';

  @override
  String failedAgentContextsCleared(Object count) {
    return 'تم مسح $count سياق محادثة محفوظ';
  }

  @override
  String clearFailedAgentContextsFailed(Object error) {
    return 'فشل مسح سياق المحادثة: $error';
  }

  @override
  String get cloneToTestUser => 'نسخ إلى مستخدم اختبار';

  @override
  String get confirmCloneToTestUserMessage =>
      'انسخ مساحة العمل الحالية إلى مستخدم اختبار محلي جديد ثم انتقل إليه. لن يتم نسخ حالة تشغيل الوكيل. لن يتم تعديل بيانات المستخدم الحالية.';

  @override
  String get testUserIdLabel => 'معرف مستخدم الاختبار';

  @override
  String get testUserIdHelper =>
      'استخدم أحرفا أو أرقاما أو شرطة أو شرطة سفلية.';

  @override
  String get testUserIdInvalid =>
      'استخدم فقط أحرفا أو أرقاما أو شرطة أو شرطة سفلية.';

  @override
  String get overwriteExistingTestUser =>
      'استبدال مستخدم الاختبار الموجود بنفس المعرف';

  @override
  String testUserCloneSuccess(Object userId) {
    return 'تم الانتقال إلى مستخدم الاختبار $userId';
  }

  @override
  String testUserCloneFailed(Object error) {
    return 'فشل نسخ مستخدم الاختبار: $error';
  }

  @override
  String get dataClearedSuccess => 'تم مسح البيانات بنجاح';

  @override
  String clearDataFailed(Object error) {
    return 'فشل مسح البيانات: $error';
  }

  @override
  String get personalCenter => 'المركز الشخصي';

  @override
  String get viewLogs => 'عرض السجلات';

  @override
  String get systemAuthorization => 'تفويض النظام';

  @override
  String get aiCharacterConfig => 'إعداد شخصية الذكاء الاصطناعي';

  @override
  String get modelConfig => 'إعداد النموذج';

  @override
  String get agentConfig => 'إعداد الوكيل';

  @override
  String get experimentalLab => 'المختبر';

  @override
  String get experimentalLabDescription =>
      'ميزات تجريبية قد تتغير أو تنتقل لاحقا.';

  @override
  String get modelUsageStats => 'إحصاءات استخدام النموذج';

  @override
  String get asyncTaskList => 'قائمة المهام غير المتزامنة';

  @override
  String get clearLocalToken => 'مسح المستخدم';

  @override
  String get insightCardTemplates => 'قوالب بطاقات الرؤى';

  @override
  String get timelineCardTemplates => 'قوالب بطاقات الخط الزمني';

  @override
  String get logViewer => 'عارض السجلات';

  @override
  String get autoRefresh => 'تحديث تلقائي';

  @override
  String get lineCount => 'عدد الأسطر: ';

  @override
  String get all => 'الكل';

  @override
  String get schedule => 'الجدول';

  @override
  String get statistics => 'الإحصاءات';

  @override
  String get appLockConfig => 'إعداد قفل التطبيق';

  @override
  String get activityStats => 'إحصاءات النشاط';

  @override
  String activityStatsSummary(Object inputs, Object cards, Object todos) {
    return 'في هذه الفترة سجلت $inputs مرة، وأنشأت $cards بطاقة، وأكملت $todos مهمة.';
  }

  @override
  String get last7Days => '7 أيام';

  @override
  String get last30Days => '30 يوما';

  @override
  String get last90Days => '90 يوما';

  @override
  String get records => 'السجلات';

  @override
  String get words => 'الكلمات';

  @override
  String get cards => 'البطاقات';

  @override
  String get knowledgeUnits => 'وحدات المعرفة';

  @override
  String get completedTodos => 'المهام المكتملة';

  @override
  String get activeDays => 'أيام نشطة';

  @override
  String get streakDays => 'السلسلة';

  @override
  String get dailyRhythm => 'الإيقاع اليومي';

  @override
  String get recordToOutput => 'من السجل إلى الناتج';

  @override
  String get sourceBreakdown => 'توزيع المصادر';

  @override
  String get topThemes => 'أبرز المواضيع';

  @override
  String get textInput => 'نص';

  @override
  String get imageInput => 'صور';

  @override
  String get audioInput => 'صوت';

  @override
  String get noStatsYet => 'لا توجد إحصاءات نشاط بعد';

  @override
  String get tapDayForDetails => 'اضغط على يوم لعرض التفاصيل';

  @override
  String get dayDetails => 'تفاصيل اليوم';

  @override
  String loadStatsFailed(Object error) {
    return 'فشل تحميل الإحصاءات: $error';
  }

  @override
  String get overview => 'نظرة عامة';

  @override
  String get daily => 'يومي';

  @override
  String get modelStatsByAgent => 'حسب الوكيل';

  @override
  String get detail => 'تفصيل';

  @override
  String get date => 'التاريخ';

  @override
  String get agent => 'الوكيل';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get totalCalls => 'إجمالي الاستدعاءات';

  @override
  String get calls => 'الاستدعاءات';

  @override
  String callsCount(Object count) {
    return '$count استدعاءات';
  }

  @override
  String get selectDateRange => 'اختر نطاق التاريخ';

  @override
  String get totalTokens => 'إجمالي الرموز';

  @override
  String get cacheRate => 'معدل التخزين المؤقت';

  @override
  String get promptTokens => 'الرموز الموجه';

  @override
  String get completionTokens => 'الرموز الإكمال';

  @override
  String get cachedTokens => 'الرموز من التخزين المؤقت';

  @override
  String get thoughtTokens => 'الرموز التفكير';

  @override
  String get prompt => 'الموجه';

  @override
  String get completion => 'الإكمال';

  @override
  String get cached => 'المخزن مؤقتا';

  @override
  String get thought => 'التفكير';

  @override
  String get model => 'النموذج';

  @override
  String get scene => 'المشهد';

  @override
  String get sceneId => 'معرف المشهد';

  @override
  String get tokenUsage => 'استخدام الرموز';

  @override
  String get handler => 'معالج';

  @override
  String get modelBreakdown => 'توزيع النموذج';

  @override
  String get callDetails => 'تفاصيل الاستدعاء';

  @override
  String recordDetailsTitle(Object scene) {
    return 'تفاصيل السجل: $scene';
  }

  @override
  String saveLlmConfigFailed(Object error) {
    return 'فشل حفظ إعداد نموذج اللغة الكبير: $error';
  }

  @override
  String get webHtmlPreviewUnavailable =>
      'معاينة HTML غير متاحة على الويب. يرجى العرض على الهاتف.';

  @override
  String saveUserInfoFailed(Object error) {
    return 'فشل حفظ معلومات المستخدم: $error';
  }

  @override
  String get totalEstimatedCost => 'إجمالي التكلفة المقدرة';

  @override
  String get close => 'إغلاق';

  @override
  String get totalTokenConsumption => 'إجمالي استهلاك الرموز';

  @override
  String get dataLoadFailedRetry => 'فشل تحميل البيانات، يرجى المحاولة لاحقا.';

  @override
  String get timelineLoadFailedRetry =>
      'فشل تحميل الخط الزمني، يرجى المحاولة لاحقا.';

  @override
  String get newPerspective => 'منظور جديد';

  @override
  String get startPoint => 'البداية';

  @override
  String get endPoint => 'النهاية';

  @override
  String get originalInput => 'الإدخال الأصلي';

  @override
  String get referenceContent => 'محتوى مرجعي';

  @override
  String referenceWithTitle(Object title) {
    return 'مرجع: $title';
  }

  @override
  String get actionCenterTitle => 'إجراءات معلقة';

  @override
  String get noPendingActions => 'لا توجد إجراءات معلقة';

  @override
  String get clarificationNeeded => 'يريد Memex التأكيد';

  @override
  String get clarificationTextHint => 'اكتب إجابة قصيرة';

  @override
  String get clarificationTextRequired => 'أضف إجابة قصيرة أولا';

  @override
  String get clarificationAnswered => 'تمت الإجابة';

  @override
  String clarificationAnswerPrefix(Object answer) {
    return 'الإجابة: $answer';
  }

  @override
  String get answerSaved => 'تم حفظ الإجابة';

  @override
  String get clarificationOtherAnswer => 'إدخال يدوي';

  @override
  String get clarificationNotSure => 'لست متأكدا / أفضل عدم القول';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get footprintMap => 'خريطة الأثر';

  @override
  String get waypointPlaces => 'أماكن نقاط الطريق';

  @override
  String get unknownPlace => 'مكان غير معروف';

  @override
  String get releaseToSend => 'أفلت للإرسال';

  @override
  String get selectFromAlbum => 'اختر من الألبوم';

  @override
  String get clipboardPreviewTitle => 'حافظة جديدة';

  @override
  String get clipboardPreviewImageTitle => 'صورة من الحافظة';

  @override
  String get clipboardPreviewImageDescription => 'الصورة جاهزة للإضافة';

  @override
  String get clipboardPreviewUnprocessed => 'لم يتم اللصق بعد';

  @override
  String get clipboardPreviewPasteToInput => 'لصق في الإدخال';

  @override
  String get clipboardPreviewAddImageToInput => 'إضافة صورة';

  @override
  String get clipboardPreviewImageFailed => 'تعذر قراءة صورة الحافظة';

  @override
  String get tellAiWhatHappened => 'أخبر الذكاء الاصطناعي بما حدث...';

  @override
  String recordingWithDuration(Object duration) {
    return 'التسجيل: $duration';
  }

  @override
  String get playing => 'يتم التشغيل...';

  @override
  String get sendLabel => 'إرسال';

  @override
  String attachedImagesMessage(Object count) {
    return 'تم إرسال $count صورة';
  }

  @override
  String get noTaskData => 'لا توجد بيانات مهمة';

  @override
  String createdAtDate(Object date) {
    return 'تم الإنشاء: $date';
  }

  @override
  String updatedAtDate(Object date) {
    return 'تم التحديث: $date';
  }

  @override
  String durationLabel(Object duration) {
    return 'المدة: $duration';
  }

  @override
  String retryCount(Object count) {
    return 'إعادة المحاولة: $count';
  }

  @override
  String get loadDetailFailedRetry =>
      'فشل تحميل التفاصيل، يرجى المحاولة لاحقا.';

  @override
  String get loadFailed => 'فشل التحميل';

  @override
  String get reload => 'إعادة التحميل';

  @override
  String get aiInsightDetail => 'تفاصيل الرؤية';

  @override
  String relatedRecordsCount(Object count) {
    return 'السجلات المرتبطة ($count)';
  }

  @override
  String get noRelatedRecords => 'لا توجد سجلات مرتبطة';

  @override
  String get useFingerprintToUnlock => 'استخدم البصمة لإلغاء القفل';

  @override
  String get locked => 'مقفل';

  @override
  String get wrongPassword => 'كلمة المرور غير صحيحة';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get memexLocked => 'Memex مقفل';

  @override
  String get calendarShortSun => 'الأحد';

  @override
  String get calendarShortMon => 'الاثنين';

  @override
  String get calendarShortTue => 'الثلاثاء';

  @override
  String get calendarShortWed => 'الأربعاء';

  @override
  String get calendarShortThu => 'الخميس';

  @override
  String get calendarShortFri => 'الجمعة';

  @override
  String get calendarShortSat => 'السبت';

  @override
  String noRecordsOnDate(Object date) {
    return 'لا توجد سجلات في $date';
  }

  @override
  String get footprintPath => 'مسار الأثر';

  @override
  String get lifeCompositionTable => 'تركيب الحياة';

  @override
  String get emotionReframe => 'إعادة صياغة الشعور';

  @override
  String get chronicleOfThings => 'سجل الأشياء';

  @override
  String get goalProgress => 'تقدم الهدف';

  @override
  String get trendChart => 'مخطط الاتجاه';

  @override
  String get comparisonChart => 'مخطط المقارنة';

  @override
  String get todayTimeFlow => 'تدفق وقت اليوم';

  @override
  String get aiInputHint => 'سواء كانت ذكريات أو الحاضر، أنا هنا...';

  @override
  String get refreshSuperAgentStateTooltip => 'مسح سياق وكيل Memex';

  @override
  String get refreshSuperAgentStateTitle => 'مسح سياق تاريخ وكيل Memex؟';

  @override
  String get refreshSuperAgentStateMessage =>
      'سيبقى سجل الدردشة الظاهر، لكن سيتم مسح سياق التشغيل التاريخي لـ وكيل Memex وستبدأ الردود القادمة من سياق جديد. لن تتأثر الذاكرة الدائمة أو ملفات قاعدة المعرفة أو البطاقات أو البيانات المحفوظة الأخرى. استخدم هذا عندما يستمر وكيل Memex في سلوك غير طبيعي. متابعة؟';

  @override
  String get refreshSuperAgentStateActiveRunMessage =>
      'انتظر حتى تنتهي رسالة وكيل Memex الحالية قبل مسح السياق.';

  @override
  String get refreshSuperAgentStateSuccess => 'تم مسح سياق وكيل Memex';

  @override
  String refreshSuperAgentStateFailed(Object error) {
    return 'فشل مسح سياق وكيل Memex: $error';
  }

  @override
  String get nothingHere => 'لا شيء هنا بعد';

  @override
  String get nothingHereHint => 'اضغط على الزر أدناه لإنشاء بطاقتك الأولى';

  @override
  String get agentProcessing => 'الذكاء الاصطناعي يعالج...';

  @override
  String get keepAppOpen => 'لا تغلق التطبيق';

  @override
  String get activityDetail => 'تفاصيل النشاط';

  @override
  String get noAgentActivityYet => 'لا يوجد نشاط وكيل بعد';

  @override
  String get processingEllipsis => 'تتم المعالجة...';

  @override
  String get agentBackgroundTitle => 'وكيل Memex';

  @override
  String get agentBackgroundPausedTitle => 'وكيل Memex متوقف مؤقتا';

  @override
  String get agentBackgroundNeedsAttentionTitle =>
      'وكيل Memex يحتاج إلى انتباه';

  @override
  String get agentBackgroundStageIdle => 'خامل';

  @override
  String get agentBackgroundStageProcessing => 'تتم المعالجة';

  @override
  String get agentBackgroundStageQueued => 'في القائمة';

  @override
  String get agentBackgroundStageRetrying => 'بانتظار إعادة المحاولة';

  @override
  String get agentBackgroundStagePaused => 'متوقف مؤقتا';

  @override
  String get agentBackgroundStageCompleted => 'مكتمل';

  @override
  String get agentBackgroundStageNeedsAttention => 'يحتاج إلى انتباه';

  @override
  String get agentBackgroundStageAnalyzingMedia => 'تحليل الوسائط';

  @override
  String get agentBackgroundStageGeneratingCard => 'إنشاء بطاقة';

  @override
  String get agentBackgroundStageUpdatingKnowledge => 'تحديث المعرفة';

  @override
  String get agentBackgroundStagePreparingComment => 'تحضير تعليق';

  @override
  String get agentBackgroundStageRoutingFollowUps => 'توجيه المتابعات';

  @override
  String agentBackgroundTaskSummary(
      Object running, Object pending, Object retrying) {
    return 'قيد التشغيل $running، معلق $pending، إعادة محاولة $retrying';
  }

  @override
  String agentBackgroundTaskDetail(Object count) {
    return 'تتم معالجة $count مهمة في القائمة.';
  }

  @override
  String get agentBackgroundNoTasks => 'لا توجد مهام في الخلفية.';

  @override
  String get agentBackgroundStarting => 'بدأت المعالجة.';

  @override
  String get agentBackgroundCompletedDetail => 'اكتملت كل مهام الخلفية.';

  @override
  String get agentBackgroundFailedDetail => 'توقفت المعالجة بسبب خطأ.';

  @override
  String get agentBackgroundPausedDetail =>
      'المعالجة متوقفة مؤقتا وستستمر لاحقا.';

  @override
  String get agentBackgroundQueuedDetail => 'بانتظار خطوة المعالجة التالية.';

  @override
  String get agentBackgroundRetryingDetail =>
      'ستتم إعادة محاولة الخطوة الحالية تلقائيا.';

  @override
  String get agentBackgroundAnalyzeMediaDetail =>
      'قراءة المرفقات والسياق المحلي.';

  @override
  String get agentBackgroundGeneratingCardDetail =>
      'تحويل السجل إلى بطاقة الخط الزمني.';

  @override
  String get agentBackgroundUpdatingKnowledgeDetail =>
      'تحديث المعرفة والذاكرة المحلية.';

  @override
  String get agentBackgroundPreparingCommentDetail =>
      'تحضير متابعة من المساعد.';

  @override
  String get agentBackgroundRoutingFollowUpsDetail =>
      'فحص إجراءات المتابعة لهذه البطاقة.';

  @override
  String agentBackgroundPausedStatus(Object summary) {
    return 'متوقف مؤقتا - $summary';
  }

  @override
  String agentBackgroundNeedsAttentionStatus(Object summary) {
    return 'يحتاج إلى انتباه - $summary';
  }

  @override
  String get settings => 'الإعدادات';

  @override
  String get languageSettings => 'اللغة';

  @override
  String get languageSettingsDesc => 'تغيير لغة عرض التطبيق';

  @override
  String get noPendingActionsToast => 'لا توجد إجراءات معلقة';

  @override
  String get knowledgeNewDiscovery => 'اكتشاف معرفة جديد';

  @override
  String discoveredNewInsightsCount(Object count) {
    return 'تم اكتشاف $count رؤى جديدة';
  }

  @override
  String updatedExistingInsightsCount(Object count) {
    return 'تم تحديث $count رؤى موجودة';
  }

  @override
  String get sectionNewInsights => 'رؤى جديدة';

  @override
  String get sectionUpdatedInsights => 'رؤى محدثة';

  @override
  String get unnamedInsight => 'رؤية بلا اسم';

  @override
  String get copiedToClipboard => 'تم النسخ إلى الحافظة';

  @override
  String get copy => 'نسخ';

  @override
  String get selectedLocation => 'الموقع المحدد';

  @override
  String get confirmLocationName => 'تأكيد اسم الموقع';

  @override
  String get confirmLocationNameHint =>
      'يمكنك تعديل الاسم (ستبقى الإحداثيات كما هي)';

  @override
  String get nameLabel => 'الاسم';

  @override
  String get inputPlaceNameHint => 'أدخل اسم المكان...';

  @override
  String currentCoordinates(Object lat, Object lng) {
    return 'الإحداثيات: $lat, $lng';
  }

  @override
  String get confirmLocation => 'تأكيد الموقع';

  @override
  String get welcomeToMemex => 'مرحبا بك في Memex';

  @override
  String get createUserIdToStart => 'أنشئ ملفك الشخصي';

  @override
  String get userIdLabel => 'اسمك / لقبك';

  @override
  String get userIdHint => 'أدخل اسمك أو لقبك';

  @override
  String get pleaseEnterUserId => 'يرجى إدخال اسمك';

  @override
  String get userIdMaxLength => 'يجب ألا يتجاوز الاسم 50 حرفا';

  @override
  String get startUsing => 'متابعة';

  @override
  String get userIdTip => 'سيستخدم هذا لتخصيص تجربتك.';

  @override
  String get setupModelConfigTitle => 'إعداد نموذج الذكاء الاصطناعي';

  @override
  String get setupModelConfigSubtitle =>
      'يحتاج Memex إلى نموذج الذكاء الاصطناعي متقدم لتنظيم السجلات وتحليل الصور وتوليد الرؤى. اختر طريقة اتصال واحدة.';

  @override
  String get setupModelConfigComplete => 'إكمال والانتقال';

  @override
  String get aiService => 'خدمة نماذج Memex';

  @override
  String get aiModelHubTitle => 'نماذج وخدمات الذكاء الاصطناعي';

  @override
  String get aiModelHubSubtitle =>
      'اختر الخدمة الرسمية من Memex أو استخدم مزودك الخاص. يظل توجيه النماذج المتقدم متاحا عند الحاجة.';

  @override
  String get aiSetupCurrentStatusTitle => 'الإعداد الحالي';

  @override
  String get aiSetupStatusNotConfiguredTitle =>
      'خدمة الذكاء الاصطناعي غير مهيأة';

  @override
  String get aiSetupStatusNotConfiguredDescription =>
      'اختر طريقة اتصال لتفعيل تنظيم الذكاء الاصطناعي للسجلات والوسائط والرؤى.';

  @override
  String get aiSetupStatusMemexTitle => 'استخدام خدمة MemeX الرسمية';

  @override
  String get aiSetupStatusMemexDescription =>
      'سيستخدم Memex الاتصال الرسمي وبيانات واجهة البرمجة التي يديرها حساب MemeX الخاص بك.';

  @override
  String get aiSetupStatusCustomTitle => 'استخدام إعدادات مزود مخصص';

  @override
  String get aiSetupStatusCustomDescription =>
      'سيستخدم Memex بيانات اعتماد المزود واختيارات أدوار النموذج التي قمت بتهيئتها.';

  @override
  String get aiSetupChooseConnectionTitle => 'اختر طريقة الاتصال';

  @override
  String get aiSetupChooseConnectionDescription =>
      'ابدأ بالطريق الذي يناسب الطريقة التي تريد أن يصل بها Memex إلى نماذج الذكاء الاصطناعي.';

  @override
  String get aiSetupOfficialRouteDescription =>
      'سجل الدخول إلى MemeX واستخدم الخدمة الرسمية دون اختيار مزودين أو مفاتيح أو نماذج على مستوى الوكيل.';

  @override
  String get aiSetupCustomRouteDescription =>
      'أضف بيانات مزودك، واختر النموذج الذي سيستخدمه الوكيل الفائق، ويمكنك اختياريا تجاوز النماذج لكل وكيل.';

  @override
  String get aiSetupCustomPageTitle => 'خدمة الذكاء الاصطناعي مخصصة';

  @override
  String get aiSetupCustomPageSubtitle =>
      'قم بتهيئة بيانات المزود أولا، ثم اختر النموذج الذي سيستخدمه Memex.';

  @override
  String get aiSetupProviderCredentialsTitle => 'المزود ومفاتيح واجهة البرمجة';

  @override
  String get aiSetupProviderCredentialsDescription =>
      'أضف أو عدل OpenAI أو Anthropic أو DeepSeek أو Gemini أو OpenRouter أو Ollama أو مزودا متوافقا آخر.';

  @override
  String get modelRolesTitle => 'اختر النموذج الأساسي';

  @override
  String get modelRolesDescription =>
      'يستخدم الوكيل الفائق نموذجا واحدا لإدخالات النص والصور. تبقى التجاوزات المتقدمة للوكلاء متاحة أدناه.';

  @override
  String get textModelRoleTitle => 'النموذج الأساسي';

  @override
  String get textModelRoleDescription =>
      'يستخدمه الوكيل الفائق للنصوص والصور والبطاقات والمعرفة والرؤى والدردشة والتعليقات والجدول والذاكرة.';

  @override
  String get modelConnectionsTitle => 'مزودو النماذج ومفاتيح واجهة البرمجة';

  @override
  String get modelConnectionsDescription =>
      'صل خدمة Memex الرسمية أو أضف بيانات مزودك الخاصة.';

  @override
  String get relatedAiCapabilitiesTitle => 'قدرات متقدمة ومرتبطة';

  @override
  String get relatedAiCapabilitiesDescription =>
      'اضبط تعيينات الوكلاء ومزود الموقع وسلوك تحويل الكلام إلى نص.';

  @override
  String get aiSetupServiceCapabilitiesTitle => 'قدرات الخدمة';

  @override
  String get aiSetupServiceCapabilitiesDescription =>
      'اختر المزودين الذين يستخدمهم Memex لقدرات الذكاء الاصطناعي المجاورة مثل الكلام والترميز الجغرافي العكسي.';

  @override
  String get aiSetupAdvancedCustomizationTitle => 'توجيه نماذج متقدم';

  @override
  String get aiSetupAdvancedCustomizationDescription =>
      'للمستخدمين المتقدمين الذين يريدون أن يستخدم وكلاء مختلفون مزودين أو إعدادات نماذج مختلفة.';

  @override
  String get locationProviderSettings => 'إعداد مزود الموقع';

  @override
  String get speechProviderSettings => 'إعداد الكلام التفريغ';

  @override
  String get advancedAgentModelAssignments => 'تعيينات نماذج الوكلاء';

  @override
  String get openAdvancedAgentModelAssignments => 'تجاوز وكلاء فرديين';

  @override
  String get noConfiguredModelOptions =>
      'أضف مزودا أو مفتاح واجهة البرمجة قبل اختيار أدوار النموذج.';

  @override
  String get modelSlotUpdated => 'تم تحديث دور النموذج';

  @override
  String get aiServiceMemexRouteTitle => 'الاتصال عبر Memex';

  @override
  String get aiServiceLongDescription =>
      'يستخدم Memex نظاما متعدد الوكلاء لتنظيم سجلات الحياة وملاحظات المعرفة والسياق الاجتماعي، واكتشاف رؤى أعمق، وتقديم رفقة الذكاء الاصطناعي بذاكرة مستمرة. يتم تخزين بياناتك كملفات Markdown نصية، مما يحافظ على حرية البيانات وقابليتها للنقل.';

  @override
  String get aiServiceCustomApiRouteTitle => 'لدي مفتاح واجهة البرمجة';

  @override
  String get aiServiceCustomModelDescription =>
      'اختر هذا أولا إذا كان لديك مفتاح واجهة البرمجة من OpenAI أو Anthropic أو DeepSeek أو Gemini أو مزود آخر.';

  @override
  String get enableAiService => 'الاتصال بـ Memex';

  @override
  String get aiServiceReadyToast => 'تنظيم الذكاء الاصطناعي مفعّل';

  @override
  String get aiServiceSettingsDescription =>
      'إذا لم يكن لديك مفتاح واجهة البرمجة، فاستخدم حساب Memex للاتصال بخدمات النماذج الشائعة.';

  @override
  String get advancedModelConfiguration => 'تهيئة مفتاح واجهة البرمجة';

  @override
  String get skipForNow => 'تخطي الآن';

  @override
  String get clearAuth => 'مسح التفويض';

  @override
  String get authorizing => 'جار التفويض...';

  @override
  String authFailed(Object error) {
    return 'فشل التفويض: $error';
  }

  @override
  String get authorized => 'مفوّض';

  @override
  String get config => 'الإعداد';

  @override
  String get calendar => 'التقويم';

  @override
  String get reminders => 'التذكيرات';

  @override
  String get writeToSystemFailed => 'فشل الكتابة إلى النظام';

  @override
  String permissionRequired(Object name) {
    return 'إذن $name مطلوب';
  }

  @override
  String permissionRationale(Object name) {
    return 'يرجى السماح للتطبيق بالوصول إلى $name من الإعدادات كي نتمكن من إنشائه لك.';
  }

  @override
  String get goToSettings => 'الانتقال إلى الإعدادات';

  @override
  String get unknownAction => 'إجراء غير معروف';

  @override
  String get discoveredCalendarEvent => 'تم العثور على حدث تقويم';

  @override
  String get discoveredReminder => 'تم العثور على تذكير';

  @override
  String get addToCalendar => 'إضافة إلى التقويم';

  @override
  String get addToReminders => 'إضافة إلى التذكيرات';

  @override
  String addedToSuccess(Object target) {
    return 'تمت الإضافة إلى $target بنجاح';
  }

  @override
  String get ignore => 'تجاهل';

  @override
  String get confirmDelete => 'تأكيد الحذف';

  @override
  String get confirmDeleteSessionMessage =>
      'حذف هذه المحادثة؟ لا يمكن التراجع عن ذلك.';

  @override
  String get delete => 'حذف';

  @override
  String get deleteSuccess => 'تم الحذف بنجاح';

  @override
  String deleteFailed(Object error) {
    return 'فشل الحذف: $error';
  }

  @override
  String daysAgo(Object count) {
    return 'منذ $count يوم';
  }

  @override
  String get chatHistory => 'سجل الدردشة';

  @override
  String get enterFullScreenTooltip => 'دخول ملء الشاشة';

  @override
  String get exitFullScreenTooltip => 'الخروج من ملء الشاشة';

  @override
  String get noConversations => 'لا توجد محادثات';

  @override
  String loadSessionListFailed(Object error) {
    return 'فشل تحميل قائمة الجلسات: $error';
  }

  @override
  String yesterdayAt(Object time) {
    return 'أمس $time';
  }

  @override
  String get newChat => 'دردشة جديدة';

  @override
  String messageCount(Object count) {
    return '$count رسائل';
  }

  @override
  String get organize => 'تنظيم';

  @override
  String get pkmCategoryProject => 'مشروع (مشروع)';

  @override
  String get pkmCategoryProjectSubtitle => 'قصير المدى · أهداف · مواعيد نهائية';

  @override
  String get pkmCategoryArea => 'مجال (مجال)';

  @override
  String get pkmCategoryAreaSubtitle => 'طويل المدى · مسؤولية · معايير';

  @override
  String get pkmCategoryResource => 'مورد (مورد)';

  @override
  String get pkmCategoryResourceSubtitle => 'اهتمامات · إلهام · مخزون';

  @override
  String get pkmCategoryArchive => 'أرشيف (أرشيف)';

  @override
  String get pkmCategoryArchiveSubtitle => 'منجز · خامد · مرجع';

  @override
  String get recentChanges => 'تغييرات حديثة';

  @override
  String get noRecentChangesInThreeDays => 'لا توجد تغييرات خلال آخر 3 أيام';

  @override
  String get unpinned => 'غير مثبت';

  @override
  String get pinnedStyle => 'تم تثبيت النمط';

  @override
  String operationFailed(Object error) {
    return 'فشلت العملية: $error';
  }

  @override
  String get refreshingInsightData =>
      'يتم تحديث بيانات الرؤى، قد يستغرق ذلك لحظة...';

  @override
  String refreshFailed(Object error) {
    return 'فشل التحديث: $error';
  }

  @override
  String get sortUpdated => 'تم تحديث ترتيب الفرز';

  @override
  String sortSaveFailed(Object error) {
    return 'فشل حفظ الفرز: $error';
  }

  @override
  String get insightCardDeleted => 'تم حذف بطاقة الرؤية';

  @override
  String deleteFailedShort(Object error) {
    return 'فشل الحذف: $error';
  }

  @override
  String get knowledgeInsight => 'رؤية معرفية';

  @override
  String get completeSort => 'إكمال الفرز';

  @override
  String get noKnowledgeInsight => 'لا توجد رؤية معرفية';

  @override
  String insightProcessingBacklogMessage(Object count) {
    return 'ما زالت $count مهام خلفية قيد المعالجة.';
  }

  @override
  String get insightUnavailableMessage =>
      'ما زالت هذه الرؤية قيد الإنشاء أو تم تحديثها. حدّث الرؤى وحاول لاحقا.';

  @override
  String get noScheduleAggregation => 'لا يوجد تجميع جدول';

  @override
  String get scheduleAggregationEmptyHint =>
      'اضغط تحديث لتنظيم الجداول والمهام من البطاقات الزمنية الحقيقية.';

  @override
  String get scheduleAggregationLoadFailed => 'فشل تحميل بيانات الجدول';

  @override
  String get scheduleAggregationRefreshFailed => 'فشل تحديث بيانات الجدول';

  @override
  String get scheduleTaskUpdateFailed => 'فشل تحديث المهمة';

  @override
  String get scheduleFeatured => 'مميز';

  @override
  String get scheduleThisWeek => 'هذا الأسبوع';

  @override
  String get scheduleDone => 'تم';

  @override
  String get scheduleTbd => 'لم يحدد بعد';

  @override
  String get scheduleWeekOverview => 'هذا الأسبوع';

  @override
  String get scheduleImportant => 'مهم';

  @override
  String get scheduleBriefingTitle => 'موجز الجدول';

  @override
  String get scheduleBriefingOpen => 'فتح';

  @override
  String get scheduleBriefingNoData => 'لا يوجد موجز جدول بعد';

  @override
  String scheduleBriefingUpdated(Object time) {
    return 'تم التحديث $time';
  }

  @override
  String scheduleBriefingDoneCount(Object count) {
    return '$count منجز';
  }

  @override
  String get updating => 'جار التحديث...';

  @override
  String get update => 'تحديث';

  @override
  String get enabled => 'مفعّل';

  @override
  String get disabled => 'معطّل';

  @override
  String get appLockOn => 'قفل التطبيق مفعّل';

  @override
  String get appLockOff => 'قفل التطبيق معطّل';

  @override
  String get enableAppLockFirst => 'يرجى تفعيل قفل التطبيق أولا';

  @override
  String get enterFourDigitPassword => 'أدخل كلمة مرور من 4 أرقام';

  @override
  String get passwordSetAndLockOn => 'تم تعيين كلمة المرور وتفعيل قفل التطبيق';

  @override
  String get appLockSettings => 'إعدادات قفل التطبيق';

  @override
  String get enableAppLock => 'تفعيل قفل التطبيق';

  @override
  String get enableAppLockSubtitle => 'كلمة المرور مطلوبة عند تشغيل التطبيق';

  @override
  String get enableBiometrics => 'تفعيل القياسات الحيوية';

  @override
  String get biometricsSubtitle => 'استخدم Face ID أو Touch ID لإلغاء القفل';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get setFourDigitPassword => 'تعيين كلمة مرور من 4 أرقام';

  @override
  String get reenterPasswordToConfirm => 'أعد إدخال كلمة المرور للتأكيد';

  @override
  String get passwordMismatch => 'كلمتا المرور غير متطابقتين. حاول مرة أخرى.';

  @override
  String confirmDeleteCharacter(Object name) {
    return 'حذف الشخصية \"$name\"؟ لا يمكن التراجع عن ذلك.';
  }

  @override
  String get configureAiCharacter => 'إعداد شخصية الذكاء الاصطناعي';

  @override
  String get addCharacter => 'إضافة شخصية';

  @override
  String get addCharacterSubtitle =>
      'اختر شخصيات الذكاء الاصطناعي للانضمام إلى فريق الرؤى. ستحلل بيانات حياتك من زوايا مختلفة.';

  @override
  String get noCharacters => 'لا توجد شخصيات';

  @override
  String loadCharacterFailed(Object error) {
    return 'فشل تحميل الشخصيات: $error';
  }

  @override
  String get noTags => 'لا توجد وسوم';

  @override
  String get createSuccess => 'تم الإنشاء بنجاح';

  @override
  String get updateSuccess => 'تم التحديث بنجاح';

  @override
  String saveFailed(Object error) {
    return 'فشل الحفظ: $error';
  }

  @override
  String get newCharacter => 'شخصية جديدة';

  @override
  String get editCharacter => 'تعديل الشخصية';

  @override
  String get save => 'حفظ';

  @override
  String get characterName => 'اسم الشخصية';

  @override
  String get characterNameHint => 'امنح شخصيتك اسما';

  @override
  String get pleaseEnterCharacterName => 'يرجى إدخال اسم الشخصية';

  @override
  String get tagsLabel => 'وسوم العلامات';

  @override
  String get tagsHint => 'مثال: حكمة، إدراك، سياق واسع\nافصل عدة وسوم بفواصل';

  @override
  String get characterPersonaLabel => 'الشخصية الشخصية';

  @override
  String get characterPersonaHint =>
      'ضمّن الشخصية ودليل الأسلوب وحوارا مثاليا وفلاتر معرفة وغير ذلك.\nاستخدم ## لعناوين الأقسام.';

  @override
  String get pleaseEnterCharacterPersona => 'يرجى إدخال الشخصية الشخصية';

  @override
  String permissionRequestError(Object error) {
    return 'خطأ طلب الإذن: $error';
  }

  @override
  String get permissionRequiredTitle => 'الإذن مطلوب';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'لقد رفضت هذا الإذن نهائيا أو يطلبه النظام. يرجى تفعيله من إعدادات النظام.';

  @override
  String get getting => 'جار الحصول...';

  @override
  String get unauthorized => 'غير مفوّض';

  @override
  String get authorizedGoToSettings =>
      'تم التفويض. انتقل إلى إعدادات النظام للتغيير.';

  @override
  String get location => 'الموقع';

  @override
  String get locationPermissionReason =>
      'لتسجيل الأماكن والميزات المرتبطة بالموقع';

  @override
  String get photos => 'الصور';

  @override
  String get photosPermissionReason =>
      'لاختيار الصور وحفظ الصور المولدة وغير ذلك';

  @override
  String get camera => 'الكاميرا';

  @override
  String get cameraPermissionReason => 'لالتقاط الصور والفيديوهات';

  @override
  String get microphone => 'الميكروفون';

  @override
  String get microphonePermissionReason => 'للتعرف على الصوت والتسجيل وغير ذلك';

  @override
  String get calendarPermissionReason => 'لتسجيل الجداول وقراءة أحداث التقويم';

  @override
  String get remindersPermissionReason => 'لتسجيل وقراءة تذكيراتك';

  @override
  String get fitnessAndMotion => 'اللياقة والحركة';

  @override
  String get fitnessPermissionReason => 'لتسجيل بيانات الصحة والحركة';

  @override
  String get notification => 'الإشعارات';

  @override
  String get notificationPermissionReason => 'لإرسال الجداول والتذكيرات المهمة';

  @override
  String get memexAgentNotificationPermissionTitle =>
      'إبقاء Memex Agent يعمل في الخلفية';

  @override
  String get memexAgentNotificationPermissionMessage =>
      'يعمل Memex Agent محليا على جهازك. عند السماح بالإشعارات، يستطيع Memex عرض التقدم ومتابعة المعالجة بعد مغادرة التطبيق أو إيقاف الشاشة. إذا كانت الإشعارات متوقفة، أبق Memex مفتوحا في الواجهة حتى تكتمل المهمة.';

  @override
  String get loadDetailFailedRetryShort =>
      'فشل تحميل التفاصيل، يرجى المحاولة لاحقا.';

  @override
  String get total => 'الإجمالي';

  @override
  String get estimatedCost => 'التكلفة المقدرة';

  @override
  String get byAgent => 'حسب الوكيل';

  @override
  String get timeUpdated => 'تم تحديث الوقت';

  @override
  String updateFailed(Object error) {
    return 'فشل التحديث: $error';
  }

  @override
  String get locationUpdated => 'تم تحديث الموقع';

  @override
  String get confirmDeleteCardMessage =>
      'حذف هذه البطاقة؟ لا يمكن التراجع عن ذلك.';

  @override
  String get cardDetailNotFound => 'لم يتم العثور على تفاصيل البطاقة';

  @override
  String get saySomething => 'قل شيئا...';

  @override
  String get relatedMemories => 'ذكريات مرتبطة';

  @override
  String get viewMore => 'عرض المزيد';

  @override
  String get relatedRecords => 'سجلات مرتبطة';

  @override
  String get reply => 'رد';

  @override
  String get replySent => 'تم إرسال الرد';

  @override
  String get insightTemplateGalleryTitle => 'قوالب بطاقات الرؤى';

  @override
  String get timelineTemplateGalleryTitle => 'قوالب بطاقات الخط الزمني';

  @override
  String get categoryTextual => 'نصي';

  @override
  String get timelineFilterAll => 'الكل';

  @override
  String get insights => 'الرؤى';

  @override
  String get memoryTitle => 'الذاكرة';

  @override
  String get longTermProfile => 'الملف طويل المدى';

  @override
  String get recentBuffer => 'المخزن الحديث';

  @override
  String errorLoadingMemory(Object error) {
    return 'خطأ في تحميل الذاكرة: $error';
  }

  @override
  String get agentConfiguration => 'إعداد الوكيل';

  @override
  String get resetToDefaults => 'إعادة إلى الافتراضيات';

  @override
  String get resetAllAgentConfigurationsTitle => 'إعادة كل إعدادات الوكلاء';

  @override
  String get resetAllAgentConfigurationsMessage =>
      'هل تريد إعادة كل إعدادات الوكلاء إلى قيمها الافتراضية؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get resetButton => 'إعادة';

  @override
  String loadDataFailed(Object error) {
    return 'فشل تحميل البيانات: $error';
  }

  @override
  String saveConfigFailed(Object error) {
    return 'فشل حفظ الإعداد: $error';
  }

  @override
  String get selectLlmClient => 'اختر نموذج اللغة الكبير عميل:';

  @override
  String get agentConfigurationsReset => 'تمت إعادة إعدادات الوكلاء';

  @override
  String resetFailed(Object error) {
    return 'فشلت الإعادة: $error';
  }

  @override
  String get modelConfiguration => 'إعداد النموذج';

  @override
  String get resetAllConfigurationsTitle => 'إعادة كل الإعدادات';

  @override
  String get resetAllModelConfigurationsMessage =>
      'هل تريد إعادة كل إعدادات النماذج إلى قيمها الافتراضية؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get modelConfigurationsReset => 'تمت إعادة إعدادات النماذج';

  @override
  String get cannotDeleteDefaultConfiguration =>
      'لا يمكن حذف الإعداد الافتراضي';

  @override
  String get cannotDeleteConfigurationTitle => 'لا يمكن حذف الإعداد';

  @override
  String configUsedByAgentsMessage(Object agentList) {
    return 'هذا الإعداد مستخدم حاليا بواسطة الوكلاء التاليين:\n\n$agentList\n\nيرجى إعادة تعيين هؤلاء الوكلاء قبل الحذف.';
  }

  @override
  String get ok => 'OK';

  @override
  String get deleteConfigurationTitle => 'حذف الإعداد';

  @override
  String confirmDeleteConfigMessage(Object key) {
    return 'هل تريد حذف \"$key\"؟';
  }

  @override
  String get defaultLabel => 'افتراضي';

  @override
  String get setAsDefault => 'تعيينه كافتراضي';

  @override
  String get invalidJsonInExtraField => 'JSON غير صالح في الحقل الإضافي';

  @override
  String get keyAlreadyExists => 'المفتاح موجود بالفعل';

  @override
  String get resetConfigurationTitle => 'إعادة الإعداد';

  @override
  String get resetConfigurationMessage =>
      'إعادة هذا الإعداد إلى قيمه الافتراضية الأولى؟ ستفقد التغييرات الحالية.';

  @override
  String get configurationResetPressSave =>
      'تمت إعادة الإعداد. اضغط حفظ للتطبيق.';

  @override
  String get addConfiguration => 'إضافة إعداد';

  @override
  String get editConfiguration => 'تعديل الإعداد';

  @override
  String get duplicateConfiguration => 'نسخ الإعداد';

  @override
  String get duplicate => 'نسخ';

  @override
  String get keyIdLabel => 'معرف الإعداد';

  @override
  String get keyIdHelper => 'سم هذا الإعداد، مثل deepseek أو work-gpt.';

  @override
  String get required => 'مطلوب';

  @override
  String get clientLabel => 'مزود النموذج';

  @override
  String get providerGroupOpenAi => 'OpenAI';

  @override
  String get providerGroupAnthropic => 'Anthropic';

  @override
  String get providerGroupGoogle => 'Google';

  @override
  String get providerGroupOthers => 'شائع';

  @override
  String get providerOpenAiApiKey => 'مفتاح واجهة البرمجة';

  @override
  String get providerOpenAiResponses => 'مفتاح واجهة البرمجة (وضع Responses)';

  @override
  String get providerChatGptOauth => 'حساب ChatGPT Pro/Plus';

  @override
  String get providerClaudeApiKey => 'مفتاح واجهة البرمجة';

  @override
  String get providerBedrockSecret => 'مفتاح Bedrock السري';

  @override
  String get providerGemini => 'Gemini';

  @override
  String get providerGeminiOauth => 'Gemini عبر Google OAuth';

  @override
  String get providerKimi => 'Kimi من Moonshot';

  @override
  String get providerQwen => 'مزود Aliyun';

  @override
  String get providerSeed => 'مزود Volcengine';

  @override
  String get providerZhipu => 'مزود Zhipu GLM';

  @override
  String get providerDeepSeek => 'DeepSeek';

  @override
  String get providerMinimax => 'MiniMax';

  @override
  String get providerOpenRouter => 'OpenRouter';

  @override
  String get providerOllama => 'Ollama المحلي';

  @override
  String get providerMimo => 'Xiaomi MIMO المزود';

  @override
  String get providerMemex => 'خدمة وكيل Memex';

  @override
  String get memexSignIn => 'تسجيل الدخول';

  @override
  String get memexCreateAccount => 'إنشاء حساب';

  @override
  String get memexUsername => 'اسم المستخدم';

  @override
  String get memexPassword => 'كلمة المرور';

  @override
  String get memexCreateAccountLink => 'إنشاء حساب';

  @override
  String get memexSignInLink => 'تسجيل الدخول بدلا من ذلك';

  @override
  String get memexTopUp => 'اشحن الرصيد لبدء استخدام Memex الذكاء الاصطناعي';

  @override
  String get memexTopUpSuccess => 'تم الشحن بنجاح!';

  @override
  String get memexFillAllFields => 'يرجى ملء كل الحقول';

  @override
  String get memexUsernameTooShort =>
      'يجب أن يكون اسم المستخدم 6 أحرف على الأقل';

  @override
  String get memexAuthFailed => 'فشل التحقق';

  @override
  String get memexPaymentFailed => 'فشل إنشاء الدفع';

  @override
  String get memexLogout => 'تسجيل الخروج';

  @override
  String get memexTopUpButton => 'شحن';

  @override
  String get memexTopUpChooseAmount => 'اختر مبلغا';

  @override
  String memexTopUpEstimatedRecords(Object range) {
    return 'حوالي $range سجلات';
  }

  @override
  String get memexTopUpPlanStarter => 'خطة بداية';

  @override
  String get memexTopUpPlanEveryday => 'خطة يومي';

  @override
  String get memexTopUpPlanHighVolume => 'خطة مرتفع volume';

  @override
  String get memexTopUpPlanCustom => 'رصيد مخصص';

  @override
  String get memexTopUpPlanStarterSubtitle =>
      'مناسب لتجربة Memex الذكاء الاصطناعي';

  @override
  String get memexTopUpPlanEverydaySubtitle => 'مناسب للتنظيم المنتظم';

  @override
  String get memexTopUpPlanHighVolumeSubtitle => 'مناسب للدفعات الكبيرة';

  @override
  String get memexTopUpPlanCustomSubtitle => 'أدخل USD 1-10,000';

  @override
  String get memexTopUpCustomEstimate => 'التقدير مبني على المبلغ المدخل';

  @override
  String get memexCustomAmount => 'مبلغ مخصص';

  @override
  String get memexViewHistory => 'عرض سجل الاستخدام';

  @override
  String memexBalanceLabel(Object amount) {
    return 'الرصيد: $amount';
  }

  @override
  String get memexConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get memexPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String memexPayAmount(Object amount) {
    return 'شحن $amount';
  }

  @override
  String get modelIdLabel => 'النموذج';

  @override
  String get modelIdHelper => 'مثال gemini-3.1-pro-preview, gpt-4o';

  @override
  String get fetchingModels => 'جار جلب النماذج...';

  @override
  String get fetchModelsButton => 'جلب النماذج';

  @override
  String get enterApiKeyFirst => 'أدخل مفتاح واجهة البرمجة أولا لجلب النماذج';

  @override
  String get apiKeyLabel => 'مفتاح واجهة البرمجة';

  @override
  String get baseUrlLabel => 'واجهة البرمجة نقطة النهاية الرابط';

  @override
  String get advancedSettings => 'إعدادات متقدمة';

  @override
  String get testConnectionSuccess => 'نجح الاتصال';

  @override
  String get testConnectionFailed => 'فشل الاتصال';

  @override
  String get testTypeText => 'نص';

  @override
  String get testTypeVision => 'رؤية';

  @override
  String get testButton => 'اختبار';

  @override
  String get testing => 'جار الاختبار...';

  @override
  String get proxyUrlOptional => 'رابط الوكيل (اختياري)';

  @override
  String get proxyUrlHelper => 'مثال http://127.0.0.1:7890';

  @override
  String get temperatureLabel => 'قيمة Temperature';

  @override
  String get topPLabel => 'قيمة Top P';

  @override
  String get maxTokensLabel => 'حد Max الرموز';

  @override
  String get extraParamsJson => 'إضافي معلمات بصيغة JSON';

  @override
  String get invalidJson => 'JSON غير صالح';

  @override
  String get warning => 'إعداد غير مكتمل';

  @override
  String get invalidConfigurationWarning =>
      'الإعداد غير مكتمل بعد (مثل غياب مفتاح واجهة البرمجة أو معرّف النموذج). يمكنك حفظه الآن وتهيئته لاحقا. متابعة؟';

  @override
  String invalidModelConfigDetailed(Object agentId, Object configKey) {
    return 'يحتاج وكيل الذكاء الاصطناعي \"$agentId\" إلى إعداد نموذج صالح (مفتاح: \"$configKey\") للعمل. يرجى فحص إعدادات النموذج.';
  }

  @override
  String get discardChangesTitle => 'مغادرة هذه الصفحة؟';

  @override
  String get discardChangesMessage =>
      'إذا أجريت أي تغييرات، يرجى حفظها قبل المغادرة.';

  @override
  String get discardButton => 'تجاهل';

  @override
  String get chooseLanguage => 'اختر اللغة';

  @override
  String get chooseAvatar => 'اختر الصورة الرمزية';

  @override
  String get configureNow => 'تهيئة الآن';

  @override
  String get modelNotConfiguredBanner =>
      'لم يتم إعداد نموذج الذكاء الاصطناعي بعد. قم بإعداده لفتح كل الميزات.';

  @override
  String get modelNotConfiguredSubmitHint =>
      'يرجى إعداد نموذج الذكاء الاصطناعي قبل النشر';

  @override
  String get processingStatus => 'قيد المعالجة';

  @override
  String get failedStatus => 'فشل';

  @override
  String get failureReason => 'سبب الفشل';

  @override
  String get unknownError => 'حدث خطأ غير معروف';

  @override
  String get enableFitness => 'تفعيل اللياقة';

  @override
  String get fitnessBannerMessage =>
      'اسمح بالوصول إلى اللياقة لتتبع بيانات صحتك ونشاطك.';

  @override
  String get fitnessDismissTitle => 'تخطي الوصول إلى اللياقة؟';

  @override
  String get fitnessDismissMessage =>
      'بدون إذن اللياقة، لن يتمكن التطبيق من جمع بيانات صحتك تلقائيا للرؤى والتسجيل التلقائي.';

  @override
  String get skipAnyway => 'تخطي رغم ذلك';

  @override
  String get proModelHint => 'يتطلب هذا النموذج اشتراك ChatGPT Pro/Plus.';

  @override
  String get searchKnowledgeBase => 'البحث في قاعدة المعرفة...';

  @override
  String get searchKnowledgeHint =>
      'أدخل كلمة مفتاحية للبحث في أسماء الملفات أو المحتوى';

  @override
  String noSearchResults(Object query) {
    return 'لا توجد نتائج لـ \"$query\"';
  }

  @override
  String get onlyMarkdownPreview => 'تدعم المعاينة Markdown فقط';

  @override
  String get backupAndRestore => 'النسخ الاحتياطي والاستعادة';

  @override
  String get createBackup => 'إنشاء نسخة احتياطية';

  @override
  String get restoreBackup => 'استعادة نسخة احتياطية';

  @override
  String get backupDescription =>
      'اجمع كل بياناتك (البطاقات، قاعدة المعرفة، الرؤى، الإعدادات) في ملف .memex. احفظه في iCloud Drive أو Google Drive أو أي مكان عبر قائمة المشاركة.';

  @override
  String get restoreDescription =>
      'اختر ملف .memex نسخة احتياطية لاستعادة كل البيانات. سيستبدل هذا البيانات الحالية.';

  @override
  String get selectBackupFile => 'اختر ملف النسخة الاحتياطية';

  @override
  String get estimatedSize => 'الحجم المقدر';

  @override
  String get backupComplete => 'تم إنشاء النسخة الاحتياطية';

  @override
  String backupFailed(Object error) {
    return 'فشل النسخ الاحتياطي: $error';
  }

  @override
  String get confirmRestore => 'تأكيد الاستعادة';

  @override
  String get confirmRestoreMessage =>
      'ستستبدل الاستعادة كل البيانات الحالية بما فيها البطاقات وقاعدة المعرفة والرؤى والإعدادات. لا يمكن التراجع عن ذلك. متابعة؟';

  @override
  String get restoreComplete => 'اكتملت الاستعادة';

  @override
  String get restoreRestartHint =>
      'تمت استعادة البيانات. يرجى إعادة تشغيل التطبيق لتطبيق كل التغييرات.';

  @override
  String restoreFailed(Object error) {
    return 'فشلت الاستعادة: $error';
  }

  @override
  String get invalidBackupFile =>
      'ملف النسخة الاحتياطية غير صالح. يرجى اختيار ملف .memex.';

  @override
  String get automaticBackup => 'نسخ احتياطي تلقائي';

  @override
  String get autoBackupDescription =>
      'عند التفعيل، ينشئ Memex لقطة محلية واحدة على الأكثر يوميا بعد بدء التشغيل أو عند العودة إلى المقدمة.';

  @override
  String get backupSensitiveSettingsHint =>
      'تتضمن النسخ الاحتياطية الإعدادات ومفاتيح مزودي النماذج. احتفظ بملفات النسخ في مكان تثق به.';

  @override
  String get backupLocation => 'الموقع';

  @override
  String get backupLocationDetails => 'تفاصيل الموقع';

  @override
  String get backupLocationSummary => 'يظهر داخل التطبيق';

  @override
  String get backupLocationFullPath => 'المسار الكامل';

  @override
  String get backupLocationUri => 'URI للوصول إلى المجلد';

  @override
  String get copyBackupLocationPath => 'نسخ المسار';

  @override
  String get backupLocationCopied => 'تم نسخ موقع النسخة الاحتياطية';

  @override
  String androidBackupLocationSelected(Object folderName) {
    return 'المجلد المحدد: $folderName';
  }

  @override
  String get iosICloudBackupLocation => 'iCloud Drive > Memex > Backups';

  @override
  String get iosAppDocumentsBackupLocation =>
      'ملفات > On My iPhone > Memex > Backups مجلد';

  @override
  String get autoBackupStatus => 'الحالة';

  @override
  String get noAutoBackupYet => 'لا توجد نسخة احتياطية تلقائية بعد';

  @override
  String lastBackupAt(Object time) {
    return 'آخر نسخة احتياطية: $time';
  }

  @override
  String get autoBackupRetention => 'الاحتفاظ';

  @override
  String autoBackupRetentionDays(Object days) {
    return '$days يوم';
  }

  @override
  String get autoBackupRetentionForever => 'احتفظ بها دائما';

  @override
  String get autoBackupMaxSize => 'حد التخزين';

  @override
  String autoBackupRetentionLimitHint(Object size) {
    return 'يحافظ التنظيف التلقائي على اللقطات التلقائية تحت $size. يتم الاحتفاظ بلقطات الأمان والتصدير اليدوي بشكل منفصل.';
  }

  @override
  String get createSnapshotNow => 'نسخ احتياطي الآن';

  @override
  String get backupLocationMenu => 'تغيير الموقع';

  @override
  String get defaultBackupLocation => 'مجلد النسخ الافتراضي';

  @override
  String get defaultBackupLocationAndroidDesc =>
      'استخدم مجلد الملفات الخارجية الخاص بتطبيق Memex. لا حاجة إلى إذن التخزين.';

  @override
  String get chooseBackupLocation => 'اختر مجلد النسخ الاحتياطي';

  @override
  String get chooseBackupLocationAndroidDesc =>
      'اختر مجلدا عبر منتقي Android وامنح Memex وصولا دائما.';

  @override
  String get storedBackups => 'النسخ المحفوظة';

  @override
  String get noStoredBackups => 'ستظهر النسخ التلقائية هنا بعد أول لقطة.';

  @override
  String get backupTypeAutoSnapshot => 'لقطة تلقائية';

  @override
  String get backupTypeSafetySnapshot => 'لقطة أمان';

  @override
  String get backupTypeManualBackup => 'نسخ يدوي';

  @override
  String get refresh => 'تحديث';

  @override
  String get restoreThisBackup => 'استعادة هذه النسخة';

  @override
  String get deleteThisBackup => 'حذف هذه النسخة';

  @override
  String get confirmDeleteBackup => 'حذف النسخة الاحتياطية؟';

  @override
  String confirmDeleteBackupMessage(Object fileName) {
    return 'حذف $fileName؟ سيؤدي ذلك إلى إزالة ملف النسخة المحفوظ ولا يمكن التراجع عنه.';
  }

  @override
  String backupDeleted(Object fileName) {
    return 'تم حذف النسخة: $fileName';
  }

  @override
  String backupDeleteFailed(Object error) {
    return 'تعذر حذف النسخة الاحتياطية: $error';
  }

  @override
  String get creatingSafetySnapshot => 'إنشاء لقطة أمان...';

  @override
  String autoBackupCreated(Object fileName) {
    return 'تم إنشاء اللقطة: $fileName';
  }

  @override
  String backupLocationFailed(Object error) {
    return 'تعذر تحديث موقع النسخة الاحتياطية: $error';
  }

  @override
  String get backupImportCreatedAt => 'تم الإنشاء';

  @override
  String get backupImportSourceVersion => 'إصدار المصدر';

  @override
  String get backupImportFlavor => 'البنية';

  @override
  String get backupLegacyFormat => 'نسخة قديمة (بدون manifest)';

  @override
  String get restoreInProgress => 'جار استعادة النسخة...';

  @override
  String get dataStorage => 'تخزين البيانات';

  @override
  String get dataStorageDescriptionAndroid =>
      'اختر مجلدا مخصصا لتخزين مساحة العمل. تبقى البيانات عند إعادة تثبيت التطبيق.';

  @override
  String get dataStorageDescriptionIOS =>
      'فعّل iCloud لمزامنة مساحة العمل بين الأجهزة والحفاظ على البيانات بعد إعادة التثبيت.';

  @override
  String get storageLocationApp => 'تخزين التطبيق';

  @override
  String get storageLocationAppDesc =>
      'يتم تخزين البيانات داخل التطبيق وستحذف عند إلغاء التثبيت.';

  @override
  String get storageLocationCustom => 'تخزين الجهاز (مجلد مخصص)';

  @override
  String get storageLocationCustomDesc =>
      'خزن البيانات في مجلد تختاره. تبقى البيانات بعد إعادة التثبيت إذا بقي المجلد.';

  @override
  String get storageLocationICloud => 'التخزين في iCloud';

  @override
  String get storageLocationICloudDesc =>
      'زامن مساحة العمل بين أجهزة Apple. تبقى البيانات بعد إعادة التثبيت.';

  @override
  String storageLocationCurrent(Object location) {
    return 'الحالي: $location';
  }

  @override
  String get icloudRequiresCapability =>
      'سجل الدخول إلى iCloud وفعّل iCloud Drive لاستخدام تخزين iCloud.';

  @override
  String get loadingFromICloud => 'استعادة البيانات من iCloud…';

  @override
  String get switchingToICloud => 'الانتقال إلى تخزين iCloud…';

  @override
  String get switchingStorage => 'تبديل التخزين…';

  @override
  String get customFolderAccessDenied =>
      'لا يمكن قراءة هذا المجلد أو الكتابة إليه. يرجى منح إذن التخزين أو اختيار موقع آخر.';

  @override
  String get configured => 'مهيأ';

  @override
  String get apiKeyNotSet => 'لم يتم تعيين مفتاح واجهة البرمجة — اضغط للتهيئة';

  @override
  String get bottomNavTimeline => 'تبويب الخط الزمني';

  @override
  String get bottomNavLibrary => 'تبويب المكتبة';

  @override
  String get aiGeneratedLabel => 'مولد بواسطة الذكاء الاصطناعي';

  @override
  String sourceTraceWithCount(Object count) {
    return 'تتبع المصدر ($count)';
  }

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountDesc =>
      'حذف كل البيانات المحلية نهائيا وإعادة ضبط التطبيق.';

  @override
  String get deleteAccountConfirmTitle => 'حذف الحساب؟';

  @override
  String get deleteAccountConfirmMessage =>
      'سيؤدي ذلك إلى حذف كل بياناتك نهائيا بما في ذلك بطاقات الخط الزمني وقاعدة المعرفة والتسجيلات والإعدادات. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String deleteAccountTypeName(Object name) {
    return 'اكتب \"$name\" للتأكيد';
  }

  @override
  String get deleteAccountTypeHint => 'أدخل اسم المستخدم للتأكيد';

  @override
  String get llmConsentTitle => 'الموافقة على مشاركة البيانات';

  @override
  String llmConsentMessage(Object provider) {
    return 'لتفعيل ميزات الذكاء الاصطناعي، يحتاج Memex إلى إرسال بياناتك إلى $provider للمعالجة. يشمل ذلك:\n\n• النص الذي تدخله (الملاحظات، تفريغ الصوت)\n• بيانات الصور والنص المستخرج (التعرف الضوئي على النصوص)\n• ملخصات الصحة واللياقة\n• محتوى بطاقات الخط الزمني\n\nيتم إرسال بياناتك مباشرة من جهازك إلى $provider. لا يخزن Memex بياناتك ولا يمررها عبر أي خادم آخر.\n\nيرجى مراجعة سياسة خصوصية $provider لمعرفة كيفية التعامل مع بياناتك.\n\nهل توافق على إرسال بياناتك إلى $provider لمعالجة الذكاء الاصطناعي؟';
  }

  @override
  String get llmConsentAgree => 'أوافق';

  @override
  String get llmConsentDecline => 'رفض';

  @override
  String get customAgents => 'وكلاء مخصصون';

  @override
  String get noCustomAgents => 'لا يوجد وكلاء مخصصون مهيؤون.';

  @override
  String get deleteAgent => 'حذف الوكيل';

  @override
  String deleteAgentConfirm(Object name) {
    return 'حذف الوكيل المخصص \"$name\"؟';
  }

  @override
  String get deleted => 'تم الحذف';

  @override
  String get saved => 'تم الحفظ';

  @override
  String get newAgent => 'وكيل جديد';

  @override
  String get editAgent => 'تعديل الوكيل';

  @override
  String get agentName => 'اسم الوكيل';

  @override
  String get agentNameHint => 'my-custom-agent';

  @override
  String get agentNameRequired => 'مطلوب';

  @override
  String get agentNameInvalid => 'أحرف وأرقام وشرطات فقط';

  @override
  String get agentNameExists => 'الاسم موجود بالفعل';

  @override
  String get hostAgentType => 'نوع الوكيل المضيف';

  @override
  String get skillDirectory => 'مجلد المهارة';

  @override
  String get skillDirInvalid =>
      'يجب أن يكون مسارا نسبيا (بدون / في البداية أو ..)';

  @override
  String get workingDirectory => 'مجلد العمل (اختياري)';

  @override
  String get workingDirectoryHint => 'اتركه فارغا لاستخدام workspace الافتراضي';

  @override
  String get llmConfig => 'إعداد نموذج اللغة الكبير';

  @override
  String get eventType => 'نوع الحدث';

  @override
  String get executionMode => 'وضع التنفيذ';

  @override
  String get executionModeAsync => 'غير متزامن';

  @override
  String get executionModeSync => 'متزامن';

  @override
  String get dependsOn => 'يعتمد على';

  @override
  String get dependsOnHint => 'اختر الاعتمادات';

  @override
  String get priority => 'الأولوية';

  @override
  String get maxRetries => 'أقصى محاولات';

  @override
  String get systemPromptLabel => 'الموجه النظامي (اختياري)';

  @override
  String get systemPromptHint => 'تعليمات إضافية تلحق بموجه الوكيل المضيف';

  @override
  String get eventSerializer => 'مسلسل الحدث';

  @override
  String get eventSerializerDefault => 'المسلسل الافتراضي (XML)';

  @override
  String get enabledLabel => 'مفعّل';

  @override
  String get skillsManagement => 'إدارة المهارات';

  @override
  String get skillsManagementEmpty => 'لا توجد مهارات بعد';

  @override
  String get downloadSkill => 'تحميل مهارة';

  @override
  String get downloadFile => 'تنزيل الملف';

  @override
  String get downloading => 'جار التحميل...';

  @override
  String get downloadSuccess => 'تم تحميل المهارة بنجاح';

  @override
  String downloadFailed(Object error) {
    return 'فشل التحميل: $error';
  }

  @override
  String get deleteConfirm => 'تأكيد الحذف';

  @override
  String deleteConfirmMessage(String name) {
    return 'هل تريد حذف \"$name\"؟';
  }

  @override
  String get invalidUrl => 'يرجى إدخال الرابط صالح';

  @override
  String get urlHint => 'https://example.com/skill.zip';

  @override
  String get newFolder => 'مجلد جديد';

  @override
  String get newFile => 'ملف جديد';

  @override
  String get folderName => 'اسم المجلد';

  @override
  String get fileName => 'اسم الملف';

  @override
  String get nameRequired => 'الاسم مطلوب';

  @override
  String get nameInvalid => 'لا يمكن أن يحتوي الاسم على / أو ..';

  @override
  String createFailed(Object error) {
    return 'فشل الإنشاء: $error';
  }

  @override
  String get fileContent => 'محتوى الملف';

  @override
  String get saveSuccess => 'تم الحفظ بنجاح';

  @override
  String downloadToCurrentDir(String dir) {
    return 'سيتم استخراج zip إلى المجلد الحالي: $dir';
  }

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get privacyPolicyDesc => 'كيف يتعامل Memex مع بياناتك';

  @override
  String get llmAuthError =>
      'فشل التحقق من واجهة البرمجة. يرجى فحص إعداد نموذج اللغة الكبير في الإعدادات.';

  @override
  String get llmBadRequestError =>
      'رفض مزود نموذج اللغة الكبير الطلب. قد لا يدعم النموذج الحالي صيغة الإدخال.';

  @override
  String get llmRateLimitError =>
      'تم تجاوز حد واجهة البرمجة. يرجى المحاولة لاحقا.';

  @override
  String get llmServerError =>
      'خدمة نموذج اللغة الكبير غير متاحة مؤقتا. يرجى المحاولة لاحقا.';

  @override
  String get llmNetworkError => 'فشل الاتصال بالشبكة. يرجى فحص اتصال الإنترنت.';

  @override
  String get llmUnknownError => 'حدث خطأ غير متوقع أثناء معالجة المحتوى.';

  @override
  String get llmErrorDialogTitle => 'فشلت المعالجة';

  @override
  String get goToModelConfig => 'الانتقال إلى الإعدادات';

  @override
  String get speechModelDownloadTitle => 'تحميل نموذج الكلام';

  @override
  String speechModelDownloadDesc(Object sizeMB) {
    return 'يلزم تحميل النموذج مرة واحدة (~${sizeMB}MB).\n\nبعد التحميل، يعمل التفريغ بالكامل على الجهاز.';
  }

  @override
  String get speechModelStartDownload => 'بدء التحميل';

  @override
  String get speechModelChooseSource => 'اختر مصدر التحميل:';

  @override
  String get speechModelChinaMirror => '🇨🇳 مرآة الصين (أسرع في CN)';

  @override
  String get speechModelGithub => '🌐 GitHub (المصدر العالمي)';

  @override
  String get speechModelDownloading => 'جار تحميل النموذج...';

  @override
  String get speechModelConnecting => 'جار الاتصال...';

  @override
  String get deleteSpeechModel => 'حذف نموذج الكلام';

  @override
  String get confirmDeleteSpeechModelMessage =>
      'حذف ملفات نموذج التعرف على الكلام المحلي المحملة؟ سيتم تحميلها مرة أخرى في المرة التالية التي تستخدم فيها محلي تحويل الكلام إلى نص.';

  @override
  String get speechModelDeletedSuccess => 'تم حذف ملفات نموذج الكلام';

  @override
  String get speechModelNotDownloaded =>
      'لم يتم العثور على ملفات نموذج الكلام محملة';

  @override
  String speechModelDeleteFailed(Object error) {
    return 'فشل حذف ملفات نموذج الكلام: $error';
  }

  @override
  String get speechTranscribing => 'جار التعرف...';

  @override
  String get speechNoResult => 'لم يتم اكتشاف كلام';

  @override
  String get useLocalSpeechToTextTitle => 'استخدام تحويل الكلام إلى نص محليا';

  @override
  String get useLocalSpeechToTextDesc =>
      'عند التفعيل، يتم تفريغ الصوت على الجهاز قبل الإرسال — مفيد للنماذج التي لا تدعم إدخال الصوت. عند التعطيل، يرسل الصوت الأصلي مباشرة إلى النموذج.';

  @override
  String get pendingAiProcessingHint =>
      'قم بإعداد نموذج الذكاء الاصطناعي للمعالجة';

  @override
  String get demoWelcome =>
      'مرحبا بك في Memex!\nلنأخذ جولة سريعة عما يستطيع الذكاء الاصطناعي فعله لسجلاتك.';

  @override
  String get demoTapAdd => 'اضغط هنا لإنشاء أول سجل';

  @override
  String get demoTapSend => 'اضغط لإرسال أول سجل';

  @override
  String get demoTapCard => 'اضغط لترى كيف نظم الذكاء الاصطناعي سجلك';

  @override
  String get demoDetailHint =>
      'هذه تفاصيل السجل التي نظمها الذكاء الاصطناعي. تصفحها، ثم عُد لمتابعة الجولة.';

  @override
  String get demoTapInsight =>
      'اضغط لرؤية الرؤى المولدة بواسطة الذكاء الاصطناعي';

  @override
  String get demoTapInsightUpdate => 'اضغط لتوليد رؤى من سجلاتك';

  @override
  String get demoTapKnowledge => 'راجع ملفات المعرفة المنظمة تلقائيا';

  @override
  String get demoDone => 'ابدأ تسجيل حياتك.';

  @override
  String get demoStartTour => 'بدء الجولة';

  @override
  String get demoGetStarted => 'ابدأ';

  @override
  String get demoSkip => 'تخطي';

  @override
  String get demoPrefillText => 'مرحبا Memex! هذا هو سجلي الأول 🎉';

  @override
  String get visionBadge => 'رؤية';

  @override
  String get notMultimodalHint =>
      'يعتمد Memex على قدرات النماذج متعددة الوسائط لتحليل الوسائط. إذا احتوت سجلاتك على صور، فتأكد من أن النموذج المهيأ يدعم إدخال الصور.';

  @override
  String get defaultModelPrefix => 'افتراضي';

  @override
  String get recommendedBadge => 'موصى به';

  @override
  String get readOnlyBadge => 'CHAT';

  @override
  String get switchCompanion => 'تبديل الرفيق';

  @override
  String get personaChatInputHint => 'اكتب رسالة...';

  @override
  String get today => 'اليوم';

  @override
  String get tomorrow => 'غدا';

  @override
  String get yesterday => 'أمس';

  @override
  String get showInsightTextTitle => 'عرض تعليق رؤية Memex';

  @override
  String get showInsightTextDesc =>
      'هل يتم عرض رؤية Memex كتعليق مثبت في قسم تعليقات تفاصيل البطاقة.';

  @override
  String get enableCharacterCommentTitle => 'تعليق الشخصيات تلقائيا';

  @override
  String get enableCharacterCommentDesc =>
      'تعلق الشخصيات تلقائيا على السجلات الجديدة.';

  @override
  String get maxCommentCharactersTitle => 'أقصى عدد شخصيات معلقة';

  @override
  String get maxCommentCharactersDesc => 'كم شخصية يمكنها التعليق على كل سجل.';

  @override
  String replyTo(String name) {
    return 'رد على $name';
  }

  @override
  String get cdnSignalsComments => 'تم تلقي رد جديد';

  @override
  String get cdnSignalsInsight => 'تم توليد رؤية جديدة';

  @override
  String get cdnSignalsBoth => 'رد جديد ورؤية جديدة';

  @override
  String get untitledCard => 'بطاقة بلا عنوان';

  @override
  String get locationContextTitle => 'سياق الموقع';

  @override
  String get locationContextDescription =>
      'سياق المدينة والحي الحالي لدردشة الوكيل';

  @override
  String get locationContextAttachTitle => 'إرفاق الموقع الحالي بالدردشة';

  @override
  String get locationContextAttachDesc =>
      'يستخدم نظام تحديد المواقع للجهاز والترميز الجغرافي العكسي لتوفير سياق المدينة والمنطقة والحي للوكيل.';

  @override
  String get reverseGeocodingProvider => 'مزود الترميز الجغرافي العكسي';

  @override
  String get amapProviderName => 'Amap';

  @override
  String get amapApiKey => 'Amap مفتاح واجهة البرمجة value';

  @override
  String get amapGcj02Note =>
      'يستخدم Amap إحداثيات GCJ-02. يتم تحويل نظام تحديد المواقع الجهاز قبل الترميز الجغرافي العكسي.';

  @override
  String get contextGranularity => 'دقة السياق';

  @override
  String get granularityCity => 'مدينة';

  @override
  String get granularityDistrict => 'منطقة';

  @override
  String get granularityNeighborhood => 'حي';

  @override
  String get granularityStreet => 'شارع';

  @override
  String get granularityFullAddress => 'مرشح العنوان الكامل';

  @override
  String get locationFreshness => 'حداثة الموقع';

  @override
  String minutesShort(int minutes) {
    return '$minutes دقائق';
  }

  @override
  String get oneHour => 'ساعة واحدة';

  @override
  String get testCurrentLocation => 'اختبار الموقع الحالي';

  @override
  String locationTestFailed(String error) {
    return 'فشل: $error';
  }

  @override
  String get locationDebugGps => 'نظام تحديد المواقع';

  @override
  String get locationDebugReverseGeocode => 'خطوة الترميز الجغرافي العكسي';

  @override
  String get locationDebugProvider => 'المزود';

  @override
  String get locationDebugAgentContext => 'سياق الوكيل';

  @override
  String get locationDebugSource => 'المصدر';

  @override
  String get locationDebugAddressSummary => 'ملخص العنوان';

  @override
  String get locationDebugFullAddress => 'العنوان الكامل';

  @override
  String get locationDebugCoordinates => 'الإحداثيات';

  @override
  String get locationDebugAccuracy => 'الدقة';

  @override
  String get locationDebugReason => 'السبب';

  @override
  String get locationDebugOk => 'OK';

  @override
  String get locationDebugUnavailable => 'غير متاح';

  @override
  String get locationDebugInjected => 'تم الحقن';

  @override
  String get locationDebugNotInjected => 'لم يتم الحقن';

  @override
  String get locationStatusUpdatedAt => 'تم التحديث';

  @override
  String get locationStatusSuccessTitle => 'الموقع الحالي جاهز';

  @override
  String get locationStatusSuccessBody =>
      'يمكن لـ Memex إرفاق ملخص الموقع هذا عندما يكون سياق الموقع مناسبا.';

  @override
  String get locationStatusApproximateTitle => 'الموقع تقريبي فقط';

  @override
  String get locationStatusApproximateBody =>
      'تبدو الدقة على مستوى المدينة أو المنطقة. يمكنك الاستمرار في استخدامه، أو تفعيل الموقع الدقيق في إعدادات النظام لسياق أدق.';

  @override
  String get locationStatusServiceDisabledTitle => 'موقع النظام متوقف';

  @override
  String get locationStatusServiceDisabledBody =>
      'يستخدم Memex نظام تحديد المواقع في الجهاز فقط، ولن يستنتج الموقع من الشبكة أو IP. على Android افتح إعدادات الموقع؛ وعلى iOS فعّل الإعدادات > الخصوصية والأمان > خدمات الموقع.';

  @override
  String get locationStatusPermissionDeniedTitle => 'إذن الموقع مطلوب';

  @override
  String get locationStatusPermissionDeniedBody =>
      'اسمح لـ Memex باستخدام الموقع أثناء الاختبار أو عندما يكون سياق الموقع مطلوبا. لا يتم طلب الوصول الدائم.';

  @override
  String get locationStatusPermissionForeverTitle => 'إذن الموقع محظور';

  @override
  String get locationStatusPermissionForeverBody =>
      'افتح إعدادات التطبيق واسمح بالموقع لـ Memex. على iOS يكفي أثناء استخدام التطبيق.';

  @override
  String get locationStatusDisabledTitle => 'سياق الموقع متوقف';

  @override
  String get locationStatusDisabledBody =>
      'فعّل المفتاح أعلاه واحفظ عندما تريد أن يرفق Memex موقع الجهاز بسياق الوكيل.';

  @override
  String get locationStatusGeocodeUnavailableTitle =>
      'نظام تحديد المواقع يعمل، لكن بحث العنوان فشل';

  @override
  String get locationStatusGeocodeUnavailableBody =>
      'لدى Memex إحداثيات لكنه لن يحقن سياق نظام تحديد المواقع-فقط في الوكيل. افحص مزود الترميز الجغرافي العكسي وحاول مرة أخرى.';

  @override
  String get locationStatusUnavailableTitle => 'الموقع غير متاح';

  @override
  String get locationStatusUnavailableBody =>
      'افحص خدمات موقع النظام وإذن التطبيق، ثم اختبر مرة أخرى.';

  @override
  String get allowLocationPermissionButton => 'السماح بإذن الموقع';

  @override
  String get openAppSettingsButton => 'فتح إعدادات التطبيق';

  @override
  String get openLocationSettingsButton => 'فتح إعدادات الموقع';

  @override
  String get locationSettingsOpenFailed => 'تعذر فتح إعدادات النظام.';

  @override
  String locationActionFailed(String error) {
    return 'فشل إجراء الموقع: $error';
  }

  @override
  String get settingsSearchPlaceholder => 'البحث في الإعدادات...';

  @override
  String get settingsSearchEmpty => 'لم يتم العثور على إعدادات مطابقة';

  @override
  String get importCharacterCard => 'استيراد بطاقة شخصية';

  @override
  String get firstMessageLabel => 'الرسالة الأولى';

  @override
  String get firstMessageHint => 'التحية المرسلة في أول محادثة (اختياري)';

  @override
  String get systemPromptOverrideLabel => 'تجاوز الموجه النظامي';

  @override
  String get systemPromptOverrideHint =>
      'تجاوز الموجه النظامي الافتراضي (متقدم، اختياري)';

  @override
  String get postHistoryInstructionsLabel => 'تعليمات بعد السجل';

  @override
  String get postHistoryInstructionsHint =>
      'تعليمات تحقن بعد سجل الدردشة وقبل الرد (اختياري)';

  @override
  String get mesExampleLabel => 'أمثلة الرسائل';

  @override
  String get mesExampleHint => 'حوارات مثال تعرض أسلوب الشخصية (اختياري)';

  @override
  String get worldBookTitle => 'كتاب العالم';

  @override
  String get worldBookSubtitle =>
      'معرفة خلفية تحقن عند تشغيل الكلمات المفتاحية';

  @override
  String get characterMemoryTitle => 'ذاكرة الشخصية';

  @override
  String get characterMemorySubtitle =>
      'ديناميكيات العلاقة وذكريات التفاعل بين الشخصية والمستخدم';

  @override
  String get addTooltip => 'إضافة';

  @override
  String get constantBadge => 'ثابت';

  @override
  String worldEntryFallbackName(Object index) {
    return 'إدخال $index اسم';
  }

  @override
  String keywordsPrefix(Object keys) {
    return 'الكلمات المفتاحية: $keys';
  }

  @override
  String memoryFallbackName(Object index) {
    return 'ذاكرة $index اسم';
  }

  @override
  String get addWorldEntry => 'إضافة كتاب العالم إدخال';

  @override
  String get editWorldEntry => 'تعديل كتاب العالم إدخال';

  @override
  String get commentTitleLabel => 'تعليق / عنوان';

  @override
  String get entryDescriptionHint => 'وصف إدخال (اختياري)';

  @override
  String get triggerKeywordsLabel => 'كلمات تشغيل';

  @override
  String get triggerKeywordsHint => 'مفصولة بفواصل، مثل: سحر، تعويذة';

  @override
  String get contentLabel => 'المحتوى';

  @override
  String get worldEntryContentHint =>
      'معرفة خلفية تحقن عندما تعمل الكلمات المفتاحية';

  @override
  String get enabledCheckbox => 'مفعّل';

  @override
  String get addMemory => 'إضافة ذاكرة';

  @override
  String get editMemory => 'تعديل الذاكرة';

  @override
  String get memoryLabelField => 'تسمية اسم';

  @override
  String get memoryLabelHint => 'معرّف فريد، مثال: تفضيل الاسم';

  @override
  String get memoryContentHint => 'محتوى الذاكرة';

  @override
  String get salienceLabel => 'الأهمية: ';

  @override
  String get labelCannotBeEmpty => 'لا يمكن أن يكون تسمية فارغا';

  @override
  String importSuccess(Object name) {
    return 'تم استيراد $name بنجاح';
  }

  @override
  String importFailed(Object error) {
    return 'فشل الاستيراد: $error';
  }

  @override
  String get supportedFormats => 'الصيغ المدعومة';

  @override
  String get tavernImportDescription =>
      '• بطاقات شخصيات SillyTavern V2 (.json)\n• صور PNG تتضمن بطاقات مدمجة (.png)\n\nسيتم تعيين حقول مثل الشخصية وworld كتاب وغيرها تلقائيا إلى صيغة شخصية Memex.';

  @override
  String get pickCharacterFile => 'اختر ملف الشخصية';

  @override
  String get repickFile => 'اختر ملفا آخر';

  @override
  String get personaSettingSection => 'الشخصية';

  @override
  String get systemPromptSection => 'الموجه النظامي';

  @override
  String worldEntriesCount(Object count) {
    return 'كتاب العالم: $count إدخالات إجمالا';
  }

  @override
  String fileLabel(Object filename) {
    return 'الملف: $filename';
  }

  @override
  String conflictWarning(Object names) {
    return 'توجد شخصية بنفس الاسم بالفعل: $names. سيؤدي الاستيراد إلى إنشاء شخصية جديدة دون الكتابة فوق الموجودة.';
  }

  @override
  String get setPrimaryCompanionTitle => 'تعيين كرفيق أساسي';

  @override
  String get setPrimaryCompanionSubtitle =>
      'تعيينه تلقائيا كرفيقك الأساسي بعد الاستيراد';

  @override
  String get confirmImport => 'تأكيد الاستيراد';

  @override
  String get chatBackground => 'خلفية الدردشة';

  @override
  String get chooseChatBackgroundImage => 'اختر صورة خلفية';

  @override
  String get earlyUpdateSettingsTitle => 'تحديثات الوصول المبكر';

  @override
  String get earlyUpdateSettingsDesc =>
      'تحقق من إصدارات GitHub التمهيدية لملف الوصول المبكر APK المطابق، ثم حمله ومرره إلى مثبت Android.';

  @override
  String get earlyUpdateUnsupported =>
      'تحديثات الوصول المبكر متاحة فقط في Android إصدار الوصول المبكر.';

  @override
  String get earlyUpdateAutoCheckTitle => 'فحص التحديثات تلقائيا';

  @override
  String get earlyUpdateAutoCheckDesc =>
      'افحص عند بدء التشغيل مرة واحدة على الأكثر كل 12 ساعة.';

  @override
  String get earlyUpdateWifiOnlyTitle => 'التحميل عبر Wi-Fi فقط';

  @override
  String get earlyUpdateWifiOnlyDesc =>
      'تخطي تحميل التحديثات أثناء استخدام بيانات الهاتف.';

  @override
  String get earlyUpdateAutoInstallTitle => 'تحميل وتثبيت تلقائي';

  @override
  String get earlyUpdateAutoInstallDesc =>
      'عند العثور على البنية جديد، حمله وافتح مثبت Android تلقائيا.';

  @override
  String get earlyUpdateCheckNow => 'فحص الآن';

  @override
  String get earlyUpdateChecking => 'جار فحص إصدارات GitHub التمهيدية...';

  @override
  String get earlyUpdateSkippedMobile =>
      'تم التخطي لأن تحميلات Wi-Fi-فقط مفعلة.';

  @override
  String get earlyUpdateNoUpdate => 'أنت على آخر إصدار الوصول المبكر بالفعل.';

  @override
  String earlyUpdateFound(Object version, Object build) {
    return 'إصدار الوصول المبكر $version+$build متاح.';
  }

  @override
  String get earlyUpdateDownloadAndInstall => 'تحميل وتثبيت';

  @override
  String get earlyUpdateDownloadInProgress => 'جار تحميل التحديث...';

  @override
  String earlyUpdateDownloadingPercent(Object percent) {
    return 'جار تحميل التحديث: $percent%';
  }

  @override
  String get earlyUpdateDownloadReadyToInstall =>
      'تم تحميل حزمة التحديث. جاهزة للتثبيت.';

  @override
  String get earlyUpdateInstallDownloadedPackage => 'تثبيت الحزمة المحملة';

  @override
  String get earlyUpdateClearDownloadedPackage => 'مسح الحزمة المحملة';

  @override
  String get earlyUpdateClearDownloadedPackageSuccess =>
      'تم مسح حزمة التحديث المحملة.';

  @override
  String get earlyUpdateInstallStarted => 'تم فتح مثبت Android.';

  @override
  String get earlyUpdateInstallPermissionRequired =>
      'اسمح لـ Memex بتثبيت تطبيقات غير معروفة، ثم اضغط تنزيل و تثبيت مرة أخرى.';

  @override
  String earlyUpdateLastChecked(Object time) {
    return 'آخر فحص: $time';
  }

  @override
  String earlyUpdateCheckFailed(Object error) {
    return 'فشل فحص التحديث: $error';
  }

  @override
  String get earlyUpdateDialogTitle => 'تحديث الوصول المبكر متاح';

  @override
  String get earlyUpdateReleaseNotes => 'ملاحظات الإصدار';

  @override
  String get dismissAllNotifications => 'مسح الكل';

  @override
  String get dismissByType => 'مسح حسب النوع';

  @override
  String get dismissTypeSystemAction => 'التذكيرات والأحداث';

  @override
  String get dismissTypeClarification => 'التوضيحات';

  @override
  String get dismissTypeCardUpdate => 'تحديثات البطاقات';

  @override
  String dismissedCount(Object count) {
    return 'تم مسح $count';
  }

  @override
  String get dataImportTitle => 'استيراد الملفات';

  @override
  String get dataImportSettingsDescription =>
      'أضف ملفاتك القديمة إلى Memex ثم قرر إن كنت تريد تنظيمها.';

  @override
  String get dataImportDescription =>
      'اختر ملاحظات قديمة أو سجلات مصدّرة أو مستندات أو أرشيفات ZIP. يحفظ Memex نسخة أولًا ولا يغيّر الملفات الأصلية. بعد الاستيراد يمكنك اختيار ما إذا كان Memex سيساعدك في تنظيمها.';

  @override
  String get dataImportSelectFiles => 'اختيار الملفات للاستيراد';

  @override
  String get dataImportImporting => 'جارٍ حفظ الملفات...';

  @override
  String get dataImportSuccess => 'تم حفظ الملفات في Memex';

  @override
  String get dataImportOnlyStored => 'تم حفظ الملفات. لم يبدأ أي تنظيم.';

  @override
  String get dataImportQueued => 'سينظم Memex هذا الاستيراد في الخلفية.';

  @override
  String get dataImportResultTitle => 'اكتمل الاستيراد';

  @override
  String dataImportResultSummary(Object count) {
    return 'تم حفظ $count ملفات. يمكنك تنظيمها الآن أو إبقاؤها كمواد أصلية.';
  }

  @override
  String dataImportRenamedConflicts(Object count) {
    return 'كانت هناك $count عناصر بالاسم نفسه، فتمت إعادة تسميتها حتى لا يتم استبدال أي شيء.';
  }

  @override
  String dataImportSkippedUnsafeEntries(Object count) {
    return 'تم تخطي $count عناصر غير معتادة داخل الأرشيف؛ وتم استيراد الباقي بشكل طبيعي.';
  }

  @override
  String get dataImportChooseProcessing => 'تنظيم هذه الملفات';

  @override
  String get dataImportProcessTitle => 'هل تريد تنظيم هذا الاستيراد؟';

  @override
  String dataImportProcessPrompt(Object count) {
    return 'لقد استوردت $count ملفات. اختر ما إذا كان Memex سينظمها الآن أو سيحتفظ بالملفات الأصلية فقط.';
  }

  @override
  String get dataImportProcessKnowledgeBase => 'تنظيمها في قاعدة المعرفة';

  @override
  String get dataImportProcessKnowledgeBaseDesc =>
      'مناسب للمستندات والملاحظات ومواد المشاريع والمراجع. سيستخرج Memex المعلومات المفيدة ويجمعها لاستخدامها لاحقًا.';

  @override
  String get dataImportProcessTimelineCards => 'إنشاء سجلات زمنية';

  @override
  String get dataImportProcessTimelineCardsDesc =>
      'مناسب للمذكرات وسجلات المحادثات وسجل النشاط والتصديرات القديمة. سيحوّل Memex المحتوى المرتبط بالوقت إلى سجلات عند الحاجة.';

  @override
  String get dataImportImpactNone =>
      'سيحتفظ Memex بهذه الملفات الأصلية فقط. لن يبدأ أي تنظيم بالذكاء الاصطناعي.';

  @override
  String get dataImportImpactKnowledgeBase =>
      'سيقرأ Memex هذه الملفات وينظم المعلومات المفيدة على المدى الطويل في قاعدة المعرفة. لن ينشئ سجلات زمنية تلقائيًا.';

  @override
  String get dataImportImpactTimelineCards =>
      'سيقرأ Memex هذه الملفات وينشئ سجلات زمنية لأحداث الحياة أو السجل المؤرخ عندما يكون ذلك مناسبًا. لن ينظم قاعدة المعرفة تلقائيًا.';

  @override
  String get dataImportImpactBoth =>
      'سيحاول Memex إنشاء سجلات زمنية وتنظيم المعلومات القابلة لإعادة الاستخدام في قاعدة المعرفة. هذا مناسب للأرشيف الشخصي الكامل.';

  @override
  String get dataImportFinish => 'الحفظ فقط';
}
