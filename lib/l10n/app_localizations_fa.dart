// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get timesLabel => 'بار';

  @override
  String modelSetAsDefault(Object modelId) {
    return 'تنظیم $modelId به‌عنوان مدل پیش‌فرض';
  }

  @override
  String get retry => 'تلاش مجدد';

  @override
  String get unknownModel => 'مدل ناشناخته';

  @override
  String get notSet => 'تنظیم نشده';

  @override
  String get confirmClear => 'تأیید پاک‌سازی';

  @override
  String get confirmClearTokenMessage =>
      'کاربر فعلی پاک شود؟ باید دوباره شناسه کاربر را وارد کنید.';

  @override
  String get cancel => 'لغو';

  @override
  String get confirm => 'تأیید';

  @override
  String get tokenCleared => 'کاربر پاک شد';

  @override
  String clearTokenFailed(Object error) {
    return 'پاک‌سازی کاربر ناموفق بود: $error';
  }

  @override
  String get selectDateRangeOptional => 'انتخاب بازه زمانی (اختیاری):';

  @override
  String get startDate => 'تاریخ شروع';

  @override
  String get endDate => 'تاریخ پایان';

  @override
  String get select => 'انتخاب';

  @override
  String get processLimitOptional => 'محدودیت پردازش (اختیاری)';

  @override
  String get leaveEmptyForAll => 'برای پردازش همه خالی بگذارید';

  @override
  String get startProcessing => 'شروع پردازش';

  @override
  String get userIdNotFound => 'شناسه کاربر یافت نشد';

  @override
  String createTaskFailed(Object error) {
    return 'ایجاد وظیفه ناموفق بود: $error';
  }

  @override
  String get reprocessCards => 'پردازش مجدد کارت‌ها';

  @override
  String get reprocessCardsTaskCreated =>
      'درخواست پردازش مجدد در صف Super Agent قرار گرفت';

  @override
  String get reprocessCardsDownstreamMode => 'دامنه';

  @override
  String get reprocessCardsCardOnly => 'فقط کارت‌ها';

  @override
  String get reprocessCardsCardOnlyDesc =>
      'از Super Agent بخواهید کارت‌های انتخاب‌شده خط زمانی را بازبینی و دوباره بسازد.';

  @override
  String get reprocessCardsRerunDownstream => 'کارت‌ها و پیگیری‌های مرتبط';

  @override
  String get reprocessCardsRerunDownstreamDesc =>
      'در صورت نیاز، از Super Agent بخواهید به‌روزرسانی‌های PKM و بینش مرتبط را نیز در نظر بگیرد.';

  @override
  String get reanalyzeMediaAssets => 'خواندن مجدد پیوست‌های رسانه‌ای';

  @override
  String get reanalyzeMediaAssetsDesc =>
      'هنگام بازسازی کارت‌ها، از Super Agent بخواهید رسانه‌های پیوست‌شده را دوباره بررسی کند.';

  @override
  String get regenerateComments => 'بازسازی نظرات';

  @override
  String get regenerateCommentsTaskCreated =>
      'وظیفه بازسازی نظرات ایجاد شد و در پس‌زمینه در حال اجراست';

  @override
  String get rebuildSearchIndex => 'بازسازی نمایه جستجو';

  @override
  String get rebuildSearchIndexSuccess => 'نمایه جستجو با موفقیت بازسازی شد';

  @override
  String get rebuildSearchIndexFailed => 'بازسازی نمایه جستجو ناموفق بود';

  @override
  String get clearData => 'پاک‌سازی داده‌ها';

  @override
  String get confirmClearDataMessage => 'داده‌ها پاک شوند؟';

  @override
  String get confirmClearDataDeletesWorkspaceMessage =>
      'تمام داده‌های محلی فضای کاری کاربر فعلی حذف می‌شود، از جمله کارت‌ها، رسانه‌ها، فایل‌های دانش، بینش‌ها، حافظه، تاریخچه گفتگو و وضعیت سیستم.\n\nاین عمل قابل بازگشت نیست!';

  @override
  String get clearFailedAgentContexts => 'پاک‌سازی زمینه گفتگوی ناموفق';

  @override
  String get confirmClearFailedAgentContextsMessage =>
      'زمینه گفتگوی ذخیره‌شده عوامل Insight و Schedule پاک شود؟ پس از تغییر مدل، وقتی پیام‌های قبلی عامل دیگر سازگار نیستند مفید است. حقایق، کارت‌ها، دانش، خاطرات و تنظیمات مدل حذف نمی‌شوند.';

  @override
  String failedAgentContextsCleared(Object count) {
    return '$count زمینه گفتگوی ذخیره‌شده پاک شد';
  }

  @override
  String clearFailedAgentContextsFailed(Object error) {
    return 'پاک‌سازی زمینه گفتگو ناموفق بود: $error';
  }

  @override
  String get cloneToTestUser => 'کپی به کاربر آزمایشی';

  @override
  String get confirmCloneToTestUserMessage =>
      'فضای کاری فعلی در یک کاربر آزمایشی محلی جدید کپی و به آن منتقل شود. وضعیت زمان اجرای عامل کپی نمی‌شود. داده‌های کاربر فعلی شما تغییر نمی‌کند.';

  @override
  String get testUserIdLabel => 'شناسه کاربر آزمایشی';

  @override
  String get testUserIdHelper =>
      'از حروف، اعداد، خط تیره یا زیرخط استفاده کنید.';

  @override
  String get testUserIdInvalid =>
      'فقط از حروف، اعداد، خط تیره یا زیرخط استفاده کنید.';

  @override
  String get overwriteExistingTestUser =>
      'جایگزینی کاربر آزمایشی موجود با همین شناسه';

  @override
  String testUserCloneSuccess(Object userId) {
    return 'به کاربر آزمایشی $userId تغییر کرد';
  }

  @override
  String testUserCloneFailed(Object error) {
    return 'کپی کاربر آزمایشی ناموفق بود: $error';
  }

  @override
  String get dataClearedSuccess => 'داده‌ها با موفقیت پاک شدند';

  @override
  String clearDataFailed(Object error) {
    return 'پاک‌سازی داده‌ها ناموفق بود: $error';
  }

  @override
  String get personalCenter => 'مرکز شخصی';

  @override
  String get viewLogs => 'مشاهده گزارش‌ها';

  @override
  String get systemAuthorization => 'مجوز سیستم';

  @override
  String get aiCharacterConfig => 'تنظیمات شخصیت هوش مصنوعی';

  @override
  String get modelConfig => 'تنظیمات مدل';

  @override
  String get agentConfig => 'تنظیمات عامل';

  @override
  String get experimentalLab => 'آزمایشگاه';

  @override
  String get experimentalLabDescription =>
      'قابلیت‌های آزمایشی که ممکن است بعداً تغییر کنند یا جابه‌جا شوند.';

  @override
  String get modelUsageStats => 'آمار استفاده از مدل';

  @override
  String get asyncTaskList => 'فهرست وظایف ناهمگام';

  @override
  String get clearLocalToken => 'پاک‌سازی کاربر';

  @override
  String get insightCardTemplates => 'قالب‌های کارت بینش';

  @override
  String get timelineCardTemplates => 'قالب‌های کارت خط زمانی';

  @override
  String get logViewer => 'نمایشگر گزارش';

  @override
  String get autoRefresh => 'به‌روزرسانی خودکار';

  @override
  String get lineCount => 'تعداد خط: ';

  @override
  String get all => 'همه';

  @override
  String get schedule => 'برنامه زمان‌بندی';

  @override
  String get appLockConfig => 'تنظیمات قفل برنامه';

  @override
  String loadStatsFailed(Object error) {
    return 'بارگذاری آمار ناموفق بود: $error';
  }

  @override
  String get overview => 'نمای کلی';

  @override
  String get daily => 'روزانه';

  @override
  String get modelStatsByAgent => 'بر اساس عامل';

  @override
  String get detail => 'جزئیات';

  @override
  String get date => 'تاریخ';

  @override
  String get agent => 'عامل';

  @override
  String get noData => 'داده‌ای وجود ندارد';

  @override
  String get totalCalls => 'کل تماس‌ها';

  @override
  String get calls => 'تماس‌ها';

  @override
  String callsCount(Object count) {
    return '$count تماس';
  }

  @override
  String get selectDateRange => 'انتخاب بازه زمانی';

  @override
  String get totalTokens => 'کل توکن‌ها';

  @override
  String get cacheRate => 'نرخ کش';

  @override
  String get promptTokens => 'توکن‌های درخواست';

  @override
  String get completionTokens => 'توکن‌های پاسخ';

  @override
  String get cachedTokens => 'توکن‌های کش‌شده';

  @override
  String get thoughtTokens => 'توکن‌های تفکر';

  @override
  String get prompt => 'درخواست';

  @override
  String get completion => 'پاسخ';

  @override
  String get cached => 'کش‌شده';

  @override
  String get thought => 'تفکر';

  @override
  String get model => 'مدل';

  @override
  String get scene => 'سناریو';

  @override
  String get sceneId => 'شناسه سناریو';

  @override
  String get tokenUsage => 'مصرف توکن';

  @override
  String get handler => 'پردازشگر';

  @override
  String get modelBreakdown => 'تفکیک مدل';

  @override
  String get callDetails => 'جزئیات تماس';

  @override
  String recordDetailsTitle(Object scene) {
    return 'جزئیات رکورد: $scene';
  }

  @override
  String saveLlmConfigFailed(Object error) {
    return 'ذخیره تنظیمات LLM ناموفق بود: $error';
  }

  @override
  String get webHtmlPreviewUnavailable =>
      'پیش‌نمایش HTML در وب در دسترس نیست. لطفاً روی موبایل مشاهده کنید.';

  @override
  String saveUserInfoFailed(Object error) {
    return 'ذخیره اطلاعات کاربر ناموفق بود: $error';
  }

  @override
  String get totalEstimatedCost => 'هزینه تخمینی کل';

  @override
  String get close => 'بستن';

  @override
  String get totalTokenConsumption => 'مصرف کل توکن';

  @override
  String get dataLoadFailedRetry =>
      'بارگذاری داده ناموفق بود، لطفاً بعداً دوباره تلاش کنید.';

  @override
  String get timelineLoadFailedRetry =>
      'بارگذاری خط زمانی ناموفق بود، لطفاً بعداً دوباره تلاش کنید.';

  @override
  String get newPerspective => 'دیدگاه جدید';

  @override
  String get startPoint => 'شروع';

  @override
  String get endPoint => 'پایان';

  @override
  String get originalInput => 'ورودی اصلی';

  @override
  String get referenceContent => 'محتوای مرجع';

  @override
  String referenceWithTitle(Object title) {
    return 'مرجع: $title';
  }

  @override
  String get actionCenterTitle => 'اقدامات در انتظار';

  @override
  String get noPendingActions => 'اقدام در انتظاری وجود ندارد';

  @override
  String get clarificationNeeded => 'Memex می‌خواهد تأیید کند';

  @override
  String get clarificationTextHint => 'یک پاسخ کوتاه بنویسید';

  @override
  String get clarificationTextRequired => 'ابتدا یک پاسخ کوتاه وارد کنید';

  @override
  String get clarificationAnswered => 'پاسخ داده شد';

  @override
  String clarificationAnswerPrefix(Object answer) {
    return 'پاسخ: $answer';
  }

  @override
  String get answerSaved => 'پاسخ ذخیره شد';

  @override
  String get clarificationOtherAnswer => 'ورود دستی';

  @override
  String get clarificationNotSure => 'مطمئن نیستم / ترجیح می‌دهم نگویم';

  @override
  String get yes => 'بله';

  @override
  String get no => 'خیر';

  @override
  String get footprintMap => 'نقشه ردپا';

  @override
  String get waypointPlaces => 'مکان‌های میانی';

  @override
  String get unknownPlace => 'مکان ناشناخته';

  @override
  String get releaseToSend => 'رها کنید تا ارسال شود';

  @override
  String get selectFromAlbum => 'انتخاب از آلبوم';

  @override
  String get clipboardPreviewTitle => 'بریده‌دان جدید';

  @override
  String get clipboardPreviewImageTitle => 'تصویر بریده‌دان';

  @override
  String get clipboardPreviewImageDescription => 'تصویر آماده افزودن است';

  @override
  String get clipboardPreviewUnprocessed => 'هنوز جایگذاری نشده';

  @override
  String get clipboardPreviewPasteToInput => 'جایگذاری در ورودی';

  @override
  String get clipboardPreviewAddImageToInput => 'افزودن تصویر';

  @override
  String get clipboardPreviewImageFailed => 'خواندن تصویر بریده‌دان ممکن نبود';

  @override
  String get tellAiWhatHappened => 'به هوش مصنوعی بگویید چه اتفاقی افتاد...';

  @override
  String recordingWithDuration(Object duration) {
    return 'در حال ضبط: $duration';
  }

  @override
  String get playing => 'در حال پخش...';

  @override
  String get sendLabel => 'ارسال';

  @override
  String attachedImagesMessage(Object count) {
    return '$count تصویر ارسال شد';
  }

  @override
  String get noTaskData => 'داده وظیفه‌ای وجود ندارد';

  @override
  String createdAtDate(Object date) {
    return 'ایجاد شده: $date';
  }

  @override
  String updatedAtDate(Object date) {
    return 'به‌روز شده: $date';
  }

  @override
  String durationLabel(Object duration) {
    return 'مدت: $duration';
  }

  @override
  String retryCount(Object count) {
    return 'تلاش مجدد: $count';
  }

  @override
  String get loadDetailFailedRetry =>
      'بارگذاری جزئیات ناموفق بود، لطفاً بعداً دوباره تلاش کنید.';

  @override
  String get loadFailed => 'بارگذاری ناموفق بود';

  @override
  String loadHistoryFailed(Object error) {
    return 'بارگذاری تاریخچه ناموفق بود: $error';
  }

  @override
  String get reload => 'بارگذاری مجدد';

  @override
  String get aiInsightDetail => 'جزئیات بینش';

  @override
  String relatedRecordsCount(Object count) {
    return 'رکوردهای مرتبط ($count)';
  }

  @override
  String get noRelatedRecords => 'رکورد مرتبطی وجود ندارد';

  @override
  String get useFingerprintToUnlock =>
      'برای باز کردن از اثر انگشت استفاده کنید';

  @override
  String get locked => 'قفل شده';

  @override
  String get wrongPassword => 'رمز عبور اشتباه است';

  @override
  String get enterPassword => 'رمز عبور را وارد کنید';

  @override
  String get memexLocked => 'Memex قفل است';

  @override
  String get calendarShortSun => 'ی';

  @override
  String get calendarShortMon => 'د';

  @override
  String get calendarShortTue => 'س';

  @override
  String get calendarShortWed => 'چ';

  @override
  String get calendarShortThu => 'پ';

  @override
  String get calendarShortFri => 'ج';

  @override
  String get calendarShortSat => 'ش';

  @override
  String noRecordsOnDate(Object date) {
    return 'در $date رکوردی وجود ندارد';
  }

  @override
  String get footprintPath => 'مسیر ردپا';

  @override
  String get lifeCompositionTable => 'ترکیب زندگی';

  @override
  String get emotionReframe => 'بازنگری هیجان';

  @override
  String get chronicleOfThings => 'وقایع‌نگاری امور';

  @override
  String get goalProgress => 'پیشرفت هدف';

  @override
  String get trendChart => 'نمودار روند';

  @override
  String get comparisonChart => 'نمودار مقایسه';

  @override
  String get todayTimeFlow => 'جریان زمان امروز';

  @override
  String get aiInputHint => 'چه خاطره باشد چه حال، اینجا هستم...';

  @override
  String get refreshSuperAgentStateTooltip => 'پاک‌سازی زمینه Memex Agent';

  @override
  String get refreshSuperAgentStateTitle => 'زمینه تاریخی Memex Agent پاک شود؟';

  @override
  String get refreshSuperAgentStateMessage =>
      'تاریخچه گفتگوی قابل‌مشاهده باقی می‌ماند، اما زمینه زمان اجرای تاریخی Memex Agent پاک می‌شود و پاسخ‌های بعدی از زمینه‌ای تازه شروع می‌شوند. حافظه پایدار، فایل‌های پایگاه دانش، کارت‌ها و سایر داده‌های ذخیره‌شده تحت تأثیر قرار نمی‌گیرند. وقتی Memex Agent رفتار غیرعادی دارد از این استفاده کنید. ادامه می‌دهید؟';

  @override
  String get refreshSuperAgentStateActiveRunMessage =>
      'تا پایان پیام فعلی Memex Agent صبر کنید، سپس زمینه را پاک کنید.';

  @override
  String get refreshSuperAgentStateSuccess => 'زمینه Memex Agent پاک شد';

  @override
  String refreshSuperAgentStateFailed(Object error) {
    return 'پاک‌سازی زمینه Memex Agent ناموفق بود: $error';
  }

  @override
  String get nothingHere => 'هنوز چیزی اینجا نیست';

  @override
  String get nothingHereHint => 'برای ساخت اولین کارت، دکمه زیر را لمس کنید';

  @override
  String get agentProcessing => 'هوش مصنوعی در حال پردازش است...';

  @override
  String get keepAppOpen => 'برنامه را نبندید';

  @override
  String get activityDetail => 'جزئیات فعالیت';

  @override
  String get noAgentActivityYet => 'هنوز فعالیت عاملی وجود ندارد';

  @override
  String get processingEllipsis => 'در حال پردازش...';

  @override
  String get agentBackgroundTitle => 'Memex Agent';

  @override
  String get agentBackgroundPausedTitle => 'Memex Agent متوقف شد';

  @override
  String get agentBackgroundNeedsAttentionTitle =>
      'Memex Agent نیاز به توجه دارد';

  @override
  String get agentBackgroundStageIdle => 'بیکار';

  @override
  String get agentBackgroundStageProcessing => 'در حال پردازش';

  @override
  String get agentBackgroundStageQueued => 'در صف';

  @override
  String get agentBackgroundStageRetrying => 'در انتظار تلاش مجدد';

  @override
  String get agentBackgroundStagePaused => 'متوقف';

  @override
  String get agentBackgroundStageCompleted => 'تکمیل شد';

  @override
  String get agentBackgroundStageNeedsAttention => 'نیاز به توجه';

  @override
  String get agentBackgroundStageAnalyzingMedia => 'تحلیل رسانه';

  @override
  String get agentBackgroundStageGeneratingCard => 'ساخت کارت';

  @override
  String get agentBackgroundStageUpdatingKnowledge => 'به‌روزرسانی دانش';

  @override
  String get agentBackgroundStagePreparingComment => 'آماده‌سازی نظر';

  @override
  String get agentBackgroundStageRoutingFollowUps => 'مسیریابی پیگیری‌ها';

  @override
  String agentBackgroundTaskSummary(
    Object running,
    Object pending,
    Object retrying,
  ) {
    return 'در حال اجرا $running، در انتظار $pending، تلاش مجدد $retrying';
  }

  @override
  String agentBackgroundTaskDetail(Object count) {
    return 'در حال پردازش $count وظیفه در صف.';
  }

  @override
  String get agentBackgroundNoTasks => 'وظیفه پس‌زمینه‌ای وجود ندارد.';

  @override
  String get agentBackgroundStarting => 'پردازش در حال شروع است.';

  @override
  String get agentBackgroundCompletedDetail =>
      'همه وظایف پس‌زمینه به پایان رسید.';

  @override
  String get agentBackgroundFailedDetail => 'پردازش با خطا متوقف شد.';

  @override
  String get agentBackgroundPausedDetail =>
      'پردازش متوقف شده و بعداً ادامه می‌یابد.';

  @override
  String get agentBackgroundQueuedDetail => 'در انتظار مرحله پردازش بعدی.';

  @override
  String get agentBackgroundRetryingDetail =>
      'مرحله فعلی به‌طور خودکار دوباره تلاش می‌شود.';

  @override
  String get agentBackgroundAnalyzeMediaDetail =>
      'خواندن پیوست‌ها و زمینه محلی.';

  @override
  String get agentBackgroundGeneratingCardDetail =>
      'تبدیل رکورد به کارت خط زمانی.';

  @override
  String get agentBackgroundUpdatingKnowledgeDetail =>
      'به‌روزرسانی دانش و حافظه محلی.';

  @override
  String get agentBackgroundPreparingCommentDetail =>
      'آماده‌سازی پیگیری دستیار.';

  @override
  String get agentBackgroundRoutingFollowUpsDetail =>
      'بررسی اقدامات پیگیری برای این کارت.';

  @override
  String agentBackgroundPausedStatus(Object summary) {
    return 'متوقف - $summary';
  }

  @override
  String agentBackgroundNeedsAttentionStatus(Object summary) {
    return 'نیاز به توجه - $summary';
  }

  @override
  String get settings => 'تنظیمات';

  @override
  String get languageSettings => 'زبان';

  @override
  String get languageSettingsDesc => 'تغییر زبان نمایش برنامه';

  @override
  String get noPendingActionsToast => 'اقدام در انتظاری وجود ندارد';

  @override
  String get knowledgeNewDiscovery => 'کشف جدید دانش';

  @override
  String discoveredNewInsightsCount(Object count) {
    return '$count بینش جدید کشف شد';
  }

  @override
  String updatedExistingInsightsCount(Object count) {
    return '$count بینش موجود به‌روز شد';
  }

  @override
  String get sectionNewInsights => 'بینش‌های جدید';

  @override
  String get sectionUpdatedInsights => 'بینش‌های به‌روز شده';

  @override
  String get unnamedInsight => 'بینش بدون نام';

  @override
  String get copiedToClipboard => 'در بریده‌دان کپی شد';

  @override
  String get copy => 'کپی';

  @override
  String get selectedLocation => 'مکان انتخاب‌شده';

  @override
  String get confirmLocationName => 'تأیید نام مکان';

  @override
  String get confirmLocationNameHint =>
      'می‌توانید نام را ویرایش کنید (مختصات ثابت می‌ماند)';

  @override
  String get nameLabel => 'نام';

  @override
  String get inputPlaceNameHint => 'نام مکان را وارد کنید...';

  @override
  String currentCoordinates(Object lat, Object lng) {
    return 'مختصات: $lat, $lng';
  }

  @override
  String get confirmLocation => 'تأیید مکان';

  @override
  String get welcomeToMemex => 'به Memex خوش آمدید';

  @override
  String get createUserIdToStart => 'پروفایل خود را بسازید';

  @override
  String get userIdLabel => 'نام / نام‌مستعار شما';

  @override
  String get userIdHint => 'نام یا نام‌مستعار خود را وارد کنید';

  @override
  String get pleaseEnterUserId => 'لطفاً نام خود را وارد کنید';

  @override
  String get userIdMaxLength => 'نام نباید بیش از ۵۰ نویسه باشد';

  @override
  String get startUsing => 'ادامه';

  @override
  String get userIdTip => 'برای شخصی‌سازی تجربه شما استفاده می‌شود.';

  @override
  String get setupModelConfigTitle => 'راه‌اندازی مدل هوش مصنوعی';

  @override
  String get setupModelConfigSubtitle =>
      'Memex برای سازمان‌دهی سوابق، تحلیل تصاویر و تولید بینش به یک مدل پیشرفته هوش مصنوعی نیاز دارد. یک روش اتصال را انتخاب کنید.';

  @override
  String get setupModelConfigComplete => 'تکمیل و شروع';

  @override
  String get aiService => 'سرویس مدل Memex';

  @override
  String get aiModelHubTitle => 'مدل‌ها و سرویس‌های هوش مصنوعی';

  @override
  String get aiModelHubSubtitle =>
      'سرویس رسمی Memex را انتخاب کنید یا ارائه‌دهنده خود را بیاورید. مسیریابی پیشرفته مدل در صورت نیاز در دسترس است.';

  @override
  String get aiSetupCurrentStatusTitle => 'پیکربندی فعلی';

  @override
  String get aiSetupStatusNotConfiguredTitle =>
      'سرویس هوش مصنوعی پیکربندی نشده است';

  @override
  String get aiSetupStatusNotConfiguredDescription =>
      'برای فعال‌سازی سازمان‌دهی هوش مصنوعی سوابق، رسانه و بینش، یک روش اتصال انتخاب کنید.';

  @override
  String get aiSetupStatusMemexTitle => 'استفاده از سرویس رسمی MemeX';

  @override
  String get aiSetupStatusMemexDescription =>
      'Memex از اتصال رسمی و اعتبارنامه‌های API مدیریت‌شده توسط حساب MemeX شما استفاده می‌کند.';

  @override
  String get aiSetupStatusCustomTitle =>
      'استفاده از تنظیمات ارائه‌دهنده سفارشی';

  @override
  String get aiSetupStatusCustomDescription =>
      'Memex از اعتبارنامه‌های ارائه‌دهنده و انتخاب‌های نقش مدل شما استفاده می‌کند.';

  @override
  String get aiSetupChooseConnectionTitle => 'انتخاب روش اتصال';

  @override
  String get aiSetupChooseConnectionDescription =>
      'با مسیری شروع کنید که با نحوه دسترسی Memex به مدل‌های هوش مصنوعی هم‌خوان باشد.';

  @override
  String get aiSetupOfficialRouteDescription =>
      'به MemeX وارد شوید و بدون انتخاب ارائه‌دهنده، کلید یا مدل‌های سطح عامل، از سرویس رسمی استفاده کنید.';

  @override
  String get aiSetupCustomRouteDescription =>
      'اعتبارنامه ارائه‌دهنده خود را اضافه کنید، مدلی را که Super Agent باید استفاده کند انتخاب کنید و در صورت تمایل مدل‌ها را برای هر عامل تغییر دهید.';

  @override
  String get aiSetupCustomPageTitle => 'سرویس هوش مصنوعی سفارشی';

  @override
  String get aiSetupCustomPageSubtitle =>
      'ابتدا اعتبارنامه ارائه‌دهنده را پیکربندی کنید، سپس مدلی را که Memex باید استفاده کند انتخاب کنید.';

  @override
  String get aiSetupProviderCredentialsTitle => 'ارائه‌دهنده و کلیدهای API';

  @override
  String get aiSetupProviderCredentialsDescription =>
      'OpenAI، Anthropic، DeepSeek، Gemini، OpenRouter، Ollama یا ارائه‌دهنده سازگار دیگری را اضافه یا ویرایش کنید.';

  @override
  String get modelRolesTitle => 'انتخاب مدل اصلی';

  @override
  String get modelRolesDescription =>
      'Super Agent از یک مدل برای ورودی متنی و تصویری استفاده می‌کند. تغییرات پیشرفته عامل در پایین در دسترس است.';

  @override
  String get textModelRoleTitle => 'مدل اصلی';

  @override
  String get textModelRoleDescription =>
      'توسط Super Agent برای متن، تصاویر، کارت‌ها، دانش، بینش‌ها، گفت‌وگو، نظرات و حافظه استفاده می‌شود.';

  @override
  String get modelConnectionsTitle => 'ارائه‌دهندگان مدل و کلیدهای API';

  @override
  String get modelConnectionsDescription =>
      'سرویس رسمی Memex را متصل کنید یا اعتبارنامه ارائه‌دهنده خود را اضافه کنید.';

  @override
  String get relatedAiCapabilitiesTitle => 'قابلیت‌های پیشرفته و مرتبط';

  @override
  String get relatedAiCapabilitiesDescription =>
      'تخصیص عامل‌ها، ارائه‌دهنده مکان و رفتار رونویسی گفتار را تنظیم کنید.';

  @override
  String get aiSetupServiceCapabilitiesTitle => 'قابلیت‌های سرویس';

  @override
  String get aiSetupServiceCapabilitiesDescription =>
      'ارائه‌دهندگانی را که Memex برای قابلیت‌های مکمل مبتنی بر هوش مصنوعی مانند گفتار و تبدیل مختصات به آدرس استفاده می‌کند انتخاب کنید.';

  @override
  String get aiSetupAdvancedCustomizationTitle => 'مسیریابی پیشرفته مدل';

  @override
  String get aiSetupAdvancedCustomizationDescription =>
      'برای کاربران حرفه‌ای که می‌خواهند عامل‌های جداگانه از ارائه‌دهندگان یا پیکربندی‌های مدل متفاوت استفاده کنند.';

  @override
  String get locationProviderSettings => 'ارائه‌دهنده مکان';

  @override
  String get speechProviderSettings => 'رونویسی گفتار';

  @override
  String get advancedAgentModelAssignments => 'تخصیص مدل به عامل‌ها';

  @override
  String get openAdvancedAgentModelAssignments => 'تغییر عامل‌های جداگانه';

  @override
  String get noConfiguredModelOptions =>
      'قبل از انتخاب نقش‌های مدل، یک ارائه‌دهنده یا کلید API اضافه کنید.';

  @override
  String get modelSlotUpdated => 'نقش مدل به‌روزرسانی شد';

  @override
  String get aiServiceMemexRouteTitle => 'اتصال از طریق Memex';

  @override
  String get aiServiceLongDescription =>
      'Memex از یک سامانه چندعامله برای سازمان‌دهی سوابق زندگی، یادداشت‌های دانشی و زمینه اجتماعی، کشف بینش‌های عمیق‌تر و ارائه همراهی هوش مصنوعی با حافظه پایدار استفاده می‌کند. داده‌های شما به‌صورت Markdown متنی ساده ذخیره می‌شوند و آزادی و قابلیت انتقال داده حفظ می‌شود.';

  @override
  String get aiServiceCustomApiRouteTitle => 'کلید API دارم';

  @override
  String get aiServiceCustomModelDescription =>
      'اگر از قبل کلید API از OpenAI، Anthropic، DeepSeek، Gemini یا ارائه‌دهنده دیگری دارید، ابتدا این را انتخاب کنید.';

  @override
  String get enableAiService => 'اتصال با Memex';

  @override
  String get aiServiceReadyToast => 'سازمان‌دهی هوش مصنوعی فعال است';

  @override
  String get aiServiceSettingsDescription =>
      'اگر کلید API ندارید، با حساب Memex به سرویس‌های مدل اصلی متصل شوید.';

  @override
  String get advancedModelConfiguration => 'پیکربندی کلید API';

  @override
  String get skipForNow => 'فعلاً رد شو';

  @override
  String get clearAuth => 'پاک کردن احراز هویت';

  @override
  String get authorizing => 'در حال احراز هویت...';

  @override
  String authFailed(Object error) {
    return 'احراز هویت ناموفق بود: $error';
  }

  @override
  String get authorized => 'احراز هویت شده';

  @override
  String authorizedAs(Object email) {
    return 'احراز هویت شده به عنوان $email';
  }

  @override
  String get authorizedSuccessfully => 'احراز هویت با موفقیت انجام شد';

  @override
  String get reAuthorize => 'احراز هویت مجدد';

  @override
  String get authorizeWithOpenAi => 'احراز هویت با OpenAI';

  @override
  String get authorizeWithGoogle => 'احراز هویت با Google';

  @override
  String get config => 'پیکربندی';

  @override
  String get calendar => 'تقویم';

  @override
  String get reminders => 'یادآورها';

  @override
  String get writeToSystemFailed => 'نوشتن در سیستم ناموفق بود';

  @override
  String permissionRequired(Object name) {
    return 'مجوز $name لازم است';
  }

  @override
  String permissionRationale(Object name) {
    return 'لطفاً در تنظیمات به برنامه اجازه دسترسی به $name خود را بدهید تا بتوانیم آن را برایتان ایجاد کنیم.';
  }

  @override
  String get goToSettings => 'رفتن به تنظیمات';

  @override
  String get unknownAction => 'اقدام ناشناخته';

  @override
  String get discoveredCalendarEvent => 'رویداد تقویم در انتظار تأیید';

  @override
  String get discoveredReminder => 'یادآور در انتظار تأیید';

  @override
  String get addToCalendar => 'افزودن به تقویم';

  @override
  String get addToReminders => 'افزودن به یادآورها';

  @override
  String get systemActionPendingExplanation =>
      'هنوز افزوده نشده است. برای درخواست مجوز و افزودن به دستگاه، پایین را لمس کنید.';

  @override
  String addedToSuccess(Object target) {
    return 'با موفقیت به $target افزوده شد';
  }

  @override
  String get ignore => 'نادیده گرفتن';

  @override
  String get confirmDelete => 'تأیید حذف';

  @override
  String get confirmDeleteSessionMessage =>
      'این گفت‌وگو حذف شود؟ این کار قابل بازگشت نیست.';

  @override
  String get delete => 'حذف';

  @override
  String get deleteSuccess => 'با موفقیت حذف شد';

  @override
  String deleteFailed(Object error) {
    return 'حذف ناموفق بود: $error';
  }

  @override
  String daysAgo(Object count) {
    return '$count روز پیش';
  }

  @override
  String get chatHistory => 'تاریخچه گفت‌وگو';

  @override
  String get enterFullScreenTooltip => 'ورود به حالت تمام‌صفحه';

  @override
  String get exitFullScreenTooltip => 'خروج از حالت تمام‌صفحه';

  @override
  String get noConversations => 'گفت‌وگویی وجود ندارد';

  @override
  String loadSessionListFailed(Object error) {
    return 'بارگذاری فهرست نشست ناموفق بود: $error';
  }

  @override
  String yesterdayAt(Object time) {
    return 'دیروز $time';
  }

  @override
  String get newChat => 'گفت‌وگوی جدید';

  @override
  String messageCount(Object count) {
    return '$count پیام';
  }

  @override
  String get organize => 'سازمان‌دهی';

  @override
  String get pkmCategoryProject => 'پروژه';

  @override
  String get pkmCategoryProjectSubtitle => 'کوتاه‌مدت · اهداف · مهلت‌ها';

  @override
  String get pkmCategoryArea => 'حوزه';

  @override
  String get pkmCategoryAreaSubtitle => 'بلندمدت · مسئولیت · استانداردها';

  @override
  String get pkmCategoryResource => 'منابع';

  @override
  String get pkmCategoryResourceSubtitle => 'علاقه‌مندی‌ها · الهام · ذخیره';

  @override
  String get pkmCategoryArchive => 'بایگانی';

  @override
  String get pkmCategoryArchiveSubtitle => 'انجام‌شده · غیرفعال · مرجع';

  @override
  String get recentChanges => 'تغییرات اخیر';

  @override
  String get noRecentChangesInThreeDays => 'در ۳ روز گذشته تغییری نبوده است';

  @override
  String get unpinned => 'سنجاق برداشته شد';

  @override
  String get pinnedStyle => 'سبک سنجاق شد';

  @override
  String operationFailed(Object error) {
    return 'عملیات ناموفق بود: $error';
  }

  @override
  String get refreshingInsightData =>
      'در حال به‌روزرسانی داده‌های بینش، ممکن است کمی طول بکشد...';

  @override
  String refreshFailed(Object error) {
    return 'به‌روزرسانی ناموفق بود: $error';
  }

  @override
  String get sortUpdated => 'ترتیب مرتب‌سازی به‌روزرسانی شد';

  @override
  String sortSaveFailed(Object error) {
    return 'ذخیره مرتب‌سازی ناموفق بود: $error';
  }

  @override
  String get insightCardDeleted => 'کارت بینش حذف شد';

  @override
  String deleteFailedShort(Object error) {
    return 'حذف ناموفق بود: $error';
  }

  @override
  String get knowledgeInsight => 'بینش دانشی';

  @override
  String get completeSort => 'تکمیل مرتب‌سازی';

  @override
  String get noKnowledgeInsight => 'بینشی وجود ندارد';

  @override
  String insightProcessingBacklogMessage(Object count) {
    return '$count وظیفه پس‌زمینه هنوز در حال پردازش است.';
  }

  @override
  String get insightUnavailableMessage =>
      'این بینش هنوز در حال تولید است یا به‌روزرسانی شده. بینش‌ها را تازه‌سازی کنید و بعداً دوباره امتحان کنید.';

  @override
  String get artifactOpen => 'باز کردن';

  @override
  String get updating => 'در حال به‌روزرسانی...';

  @override
  String get update => 'به‌روزرسانی';

  @override
  String get enabled => 'فعال';

  @override
  String get disabled => 'غیرفعال';

  @override
  String get appLockOn => 'قفل برنامه فعال شد';

  @override
  String get appLockOff => 'قفل برنامه غیرفعال شد';

  @override
  String get enableAppLockFirst => 'لطفاً ابتدا قفل برنامه را فعال کنید';

  @override
  String get enterFourDigitPassword => 'رمز ۴ رقمی را وارد کنید';

  @override
  String get passwordSetAndLockOn => 'رمز تنظیم شد و قفل برنامه فعال شد';

  @override
  String get appLockSettings => 'تنظیمات قفل برنامه';

  @override
  String get enableAppLock => 'فعال‌سازی قفل برنامه';

  @override
  String get enableAppLockSubtitle => 'هنگام باز کردن برنامه رمز لازم است';

  @override
  String get enableBiometrics => 'فعال‌سازی بیومتریک';

  @override
  String get biometricsSubtitle =>
      'برای باز کردن از Face ID یا Touch ID استفاده کنید';

  @override
  String get changePassword => 'تغییر رمز';

  @override
  String get setFourDigitPassword => 'تنظیم رمز ۴ رقمی';

  @override
  String get reenterPasswordToConfirm => 'رمز را دوباره برای تأیید وارد کنید';

  @override
  String get passwordMismatch =>
      'رمزها مطابقت ندارند. لطفاً دوباره امتحان کنید.';

  @override
  String confirmDeleteCharacter(Object name) {
    return 'شخصیت «$name» حذف شود؟ این کار قابل بازگشت نیست.';
  }

  @override
  String get configureAiCharacter => 'پیکربندی شخصیت هوش مصنوعی';

  @override
  String get addCharacter => 'افزودن شخصیت';

  @override
  String get addCharacterSubtitle =>
      'شخصیت‌های هوش مصنوعی را برای پیوستن به تیم بینش خود انتخاب کنید. آن‌ها داده‌های زندگی شما را از زوایای مختلف تحلیل می‌کنند.';

  @override
  String get noCharacters => 'شخصیتی وجود ندارد';

  @override
  String loadCharacterFailed(Object error) {
    return 'بارگذاری شخصیت‌ها ناموفق بود: $error';
  }

  @override
  String get noTags => 'برچسبی وجود ندارد';

  @override
  String get createSuccess => 'با موفقیت ایجاد شد';

  @override
  String get updateSuccess => 'با موفقیت به‌روزرسانی شد';

  @override
  String saveFailed(Object error) {
    return 'ذخیره ناموفق بود: $error';
  }

  @override
  String get newCharacter => 'شخصیت جدید';

  @override
  String get editCharacter => 'ویرایش شخصیت';

  @override
  String get save => 'ذخیره';

  @override
  String get characterName => 'نام شخصیت';

  @override
  String get characterNameHint => 'برای شخصیت خود نامی انتخاب کنید';

  @override
  String get pleaseEnterCharacterName => 'لطفاً نام شخصیت را وارد کنید';

  @override
  String get tagsLabel => 'برچسب‌ها';

  @override
  String get tagsHint =>
      'مثلاً wisdom، recognition، macro\nبرچسب‌های متعدد را با ویرگول جدا کنید';

  @override
  String get characterPersonaLabel => 'شخصیت‌پردازی';

  @override
  String get characterPersonaHint =>
      'شخصیت‌پردازی، راهنمای سبک، نمونه گفت‌وگو، فیلترهای دانش و غیره را وارد کنید.\nبرای سرتیتر بخش‌ها از ## استفاده کنید.';

  @override
  String get pleaseEnterCharacterPersona => 'لطفاً شخصیت‌پردازی را وارد کنید';

  @override
  String permissionRequestError(Object error) {
    return 'خطای درخواست مجوز: $error';
  }

  @override
  String get permissionRequiredTitle => 'مجوز لازم است';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'این مجوز را برای همیشه رد کرده‌اید یا سیستم آن را الزامی کرده است. لطفاً در تنظیمات سیستم آن را فعال کنید.';

  @override
  String get getting => 'در حال دریافت...';

  @override
  String get unauthorized => 'غیرمجاز';

  @override
  String get authorizedGoToSettings =>
      'مجاز. برای تغییر به تنظیمات سیستم بروید.';

  @override
  String get location => 'مکان';

  @override
  String get locationPermissionReason =>
      'برای ثبت مکان‌ها و قابلیت‌های مرتبط با موقعیت';

  @override
  String get photos => 'عکس‌ها';

  @override
  String get photosPermissionReason =>
      'برای انتخاب عکس، ذخیره تصاویر تولیدشده و غیره';

  @override
  String get camera => 'دوربین';

  @override
  String get cameraPermissionReason => 'برای گرفتن عکس و ویدیو';

  @override
  String get microphone => 'میکروفون';

  @override
  String get microphonePermissionReason => 'برای تشخیص گفتار، ضبط و غیره';

  @override
  String get calendarPermissionReason =>
      'برای ثبت برنامه و خواندن رویدادهای تقویم';

  @override
  String get remindersPermissionReason => 'برای ثبت و خواندن یادآورهای شما';

  @override
  String get fitnessAndMotion => 'تناسب اندام و حرکت';

  @override
  String get fitnessPermissionReason => 'برای ثبت داده‌های سلامت و حرکت';

  @override
  String get notification => 'اعلان';

  @override
  String get notificationPermissionReason =>
      'برای ارسال برنامه و یادآورهای مهم';

  @override
  String get memexAgentNotificationPermissionTitle =>
      'اجرای Memex Agent در پس‌زمینه';

  @override
  String get memexAgentNotificationPermissionMessage =>
      'Memex Agent به‌صورت محلی روی دستگاه شما اجرا می‌شود. اعلان‌ها به Memex اجازه می‌دهند پیشرفت را نشان دهد و پس از خروج از برنامه یا خاموش کردن صفحه، پردازش را ادامه دهد. اگر اعلان‌ها خاموش باشند، تا پایان وظیفه Memex را در پیش‌زمینه باز نگه دارید.';

  @override
  String get loadDetailFailedRetryShort =>
      'بارگذاری جزئیات ناموفق بود، لطفاً بعداً دوباره امتحان کنید.';

  @override
  String get total => 'جمع';

  @override
  String get estimatedCost => 'هزینه تخمینی';

  @override
  String get byAgent => 'بر اساس عامل';

  @override
  String get timeUpdated => 'زمان به‌روزرسانی شد';

  @override
  String updateFailed(Object error) {
    return 'به‌روزرسانی ناموفق بود: $error';
  }

  @override
  String get locationUpdated => 'مکان به‌روزرسانی شد';

  @override
  String get confirmDeleteCardMessage =>
      'این کارت حذف شود؟ این کار قابل بازگشت نیست.';

  @override
  String get cardDetailNotFound => 'جزئیات کارت یافت نشد';

  @override
  String get saySomething => 'چیزی بنویسید...';

  @override
  String get relatedMemories => 'خاطرات مرتبط';

  @override
  String get viewMore => 'مشاهده بیشتر';

  @override
  String get relatedRecords => 'سوابق مرتبط';

  @override
  String get reply => 'پاسخ';

  @override
  String get replySent => 'پاسخ ارسال شد';

  @override
  String get insightTemplateGalleryTitle => 'قالب‌های کارت بینش';

  @override
  String get timelineTemplateGalleryTitle => 'قالب‌های کارت خط زمانی';

  @override
  String get categoryTextual => 'متنی';

  @override
  String get timelineFilterAll => 'همه';

  @override
  String get insights => 'بینش‌ها';

  @override
  String get memoryTitle => 'حافظه';

  @override
  String get longTermProfile => 'پروفایل بلندمدت';

  @override
  String get recentBuffer => 'بافر اخیر';

  @override
  String errorLoadingMemory(Object error) {
    return 'خطا در بارگذاری حافظه: $error';
  }

  @override
  String get agentConfiguration => 'پیکربندی عامل';

  @override
  String get resetToDefaults => 'بازنشانی به پیش‌فرض';

  @override
  String get resetAllAgentConfigurationsTitle =>
      'بازنشانی همه پیکربندی‌های عامل';

  @override
  String get resetAllAgentConfigurationsMessage =>
      'آیا مطمئن هستید می‌خواهید همه پیکربندی‌های عامل را به مقادیر پیش‌فرض بازنشانی کنید؟ این کار قابل بازگشت نیست.';

  @override
  String get resetButton => 'بازنشانی';

  @override
  String loadDataFailed(Object error) {
    return 'بارگذاری داده ناموفق بود: $error';
  }

  @override
  String saveConfigFailed(Object error) {
    return 'ذخیره پیکربندی ناموفق بود: $error';
  }

  @override
  String get selectLlmClient => 'انتخاب کلاینت LLM:';

  @override
  String get agentConfigurationsReset => 'پیکربندی‌های عامل بازنشانی شد';

  @override
  String resetFailed(Object error) {
    return 'بازنشانی ناموفق بود: $error';
  }

  @override
  String get modelConfiguration => 'پیکربندی مدل';

  @override
  String get resetAllConfigurationsTitle => 'بازنشانی همه پیکربندی‌ها';

  @override
  String get resetAllModelConfigurationsMessage =>
      'آیا مطمئن هستید می‌خواهید همه پیکربندی‌های مدل را به مقادیر پیش‌فرض بازنشانی کنید؟ این کار قابل بازگشت نیست.';

  @override
  String get modelConfigurationsReset => 'پیکربندی‌های مدل بازنشانی شد';

  @override
  String get cannotDeleteDefaultConfiguration =>
      'پیکربندی پیش‌فرض قابل حذف نیست';

  @override
  String get cannotDeleteConfigurationTitle => 'حذف پیکربندی ممکن نیست';

  @override
  String configUsedByAgentsMessage(Object agentList) {
    return 'این پیکربندی در حال حاضر توسط عامل‌های زیر استفاده می‌شود:\n\n$agentList\n\nلطفاً قبل از حذف، این عامل‌ها را تخصیص مجدد دهید.';
  }

  @override
  String get ok => 'باشه';

  @override
  String get deleteConfigurationTitle => 'حذف پیکربندی';

  @override
  String confirmDeleteConfigMessage(Object key) {
    return 'آیا مطمئن هستید می‌خواهید «$key» را حذف کنید؟';
  }

  @override
  String get defaultLabel => 'پیش‌فرض';

  @override
  String get setAsDefault => 'تنظیم به‌عنوان پیش‌فرض';

  @override
  String get invalidJsonInExtraField => 'JSON نامعتبر در فیلد Extra';

  @override
  String get keyAlreadyExists => 'کلید از قبل وجود دارد';

  @override
  String get resetConfigurationTitle => 'بازنشانی پیکربندی';

  @override
  String get resetConfigurationMessage =>
      'این پیکربندی به مقادیر پیش‌فرض اولیه بازنشانی شود؟ تغییرات فعلی از بین می‌روند.';

  @override
  String get configurationResetPressSave =>
      'پیکربندی بازنشانی شد. برای اعمال دکمه ذخیره را بزنید.';

  @override
  String get addConfiguration => 'افزودن پیکربندی';

  @override
  String get editConfiguration => 'ویرایش پیکربندی';

  @override
  String get duplicateConfiguration => 'تکثیر پیکربندی';

  @override
  String get duplicate => 'تکثیر';

  @override
  String get keyIdLabel => 'شناسه پیکربندی';

  @override
  String get keyIdHelper =>
      'نامی برای این پیکربندی انتخاب کنید، مثل deepseek یا work-gpt.';

  @override
  String get required => 'الزامی';

  @override
  String get clientLabel => 'ارائه‌دهنده مدل';

  @override
  String get providerGroupOpenAi => 'OpenAI';

  @override
  String get providerGroupAnthropic => 'Anthropic';

  @override
  String get providerGroupGoogle => 'Google';

  @override
  String get providerGroupOthers => 'محبوب';

  @override
  String get providerOpenAiApiKey => 'کلید API';

  @override
  String get providerOpenAiResponses => 'کلید API (Responses)';

  @override
  String get providerChatGptOauth => 'ChatGPT Pro/Plus';

  @override
  String get providerClaudeApiKey => 'کلید API';

  @override
  String get providerBedrockSecret => 'رمز Bedrock';

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
  String get providerOllama => 'Ollama (محلی)';

  @override
  String get providerMimo => 'Xiaomi MIMO';

  @override
  String get providerMemex => 'سرویس پراکسی Memex';

  @override
  String get memexSignIn => 'ورود';

  @override
  String get memexCreateAccount => 'ایجاد حساب';

  @override
  String get memexUsername => 'نام کاربری';

  @override
  String get memexPassword => 'رمز عبور';

  @override
  String get memexCreateAccountLink => 'ایجاد حساب';

  @override
  String get memexSignInLink => 'ورود به‌جای آن';

  @override
  String get memexTopUp => 'برای شروع استفاده از Memex AI، حساب را شارژ کنید';

  @override
  String get memexTopUpSuccess => 'شارژ حساب با موفقیت انجام شد!';

  @override
  String get memexFillAllFields => 'لطفاً همه فیلدها را پر کنید';

  @override
  String get memexUsernameTooShort => 'نام کاربری باید حداقل ۶ کاراکتر باشد';

  @override
  String get memexAuthFailed => 'احراز هویت ناموفق بود';

  @override
  String get memexPaymentFailed => 'ایجاد پرداخت ناموفق بود';

  @override
  String get memexLogout => 'خروج';

  @override
  String get memexTopUpButton => 'شارژ';

  @override
  String get memexTopUpChooseAmount => 'مبلغ را انتخاب کنید';

  @override
  String memexTopUpEstimatedRecords(Object range) {
    return 'حدود $range رکورد';
  }

  @override
  String get memexTopUpPlanStarter => 'شروع';

  @override
  String get memexTopUpPlanEveryday => 'روزانه';

  @override
  String get memexTopUpPlanHighVolume => 'حجم بالا';

  @override
  String get memexTopUpPlanCustom => 'اعتبار سفارشی';

  @override
  String get memexTopUpPlanStarterSubtitle => 'مناسب برای آزمایش Memex AI';

  @override
  String get memexTopUpPlanEverydaySubtitle => 'مناسب برای سازماندهی روزانه';

  @override
  String get memexTopUpPlanHighVolumeSubtitle =>
      'مناسب برای پردازش‌های بزرگ‌تر';

  @override
  String get memexTopUpPlanCustomSubtitle =>
      'مبلغ بین ۱ تا ۱۰٬۰۰۰ دلار وارد کنید';

  @override
  String get memexTopUpCustomEstimate =>
      'برآورد بر اساس مبلغ واردشده محاسبه می‌شود';

  @override
  String get memexCustomAmount => 'مبلغ سفارشی';

  @override
  String get memexViewHistory => 'تاریخچه استفاده';

  @override
  String memexBalanceLabel(Object amount) {
    return 'موجودی: $amount';
  }

  @override
  String get memexConfirmPassword => 'تأیید رمز عبور';

  @override
  String get memexPasswordMismatch => 'رمزهای عبور یکسان نیستند';

  @override
  String memexPayAmount(Object amount) {
    return 'شارژ $amount';
  }

  @override
  String get modelIdLabel => 'مدل';

  @override
  String get modelIdHelper => 'مثال: gemini-3.1-pro-preview، gpt-4o';

  @override
  String get fetchingModels => 'در حال دریافت مدل‌ها...';

  @override
  String get fetchModelsButton => 'دریافت مدل‌ها';

  @override
  String get enterApiKeyFirst =>
      'ابتدا کلید API را وارد کنید تا مدل‌ها دریافت شوند';

  @override
  String get apiKeyLabel => 'کلید API';

  @override
  String get baseUrlLabel => 'نقطه پایانی API';

  @override
  String get advancedSettings => 'تنظیمات پیشرفته';

  @override
  String get testConnectionSuccess => 'اتصال موفق';

  @override
  String get testConnectionFailed => 'اتصال ناموفق';

  @override
  String get testTypeText => 'متن';

  @override
  String get testTypeVision => 'بینایی';

  @override
  String get testButton => 'آزمون';

  @override
  String get testing => 'در حال آزمون...';

  @override
  String get proxyUrlOptional => 'آدرس پروکسی (اختیاری)';

  @override
  String get proxyUrlHelper => 'مثال: http://127.0.0.1:7890';

  @override
  String get temperatureLabel => 'دما';

  @override
  String get topPLabel => 'Top P';

  @override
  String get maxTokensLabel => 'حداکثر توکن';

  @override
  String get extraParamsJson => 'پارامترهای اضافی (JSON)';

  @override
  String get invalidJson => 'JSON نامعتبر';

  @override
  String get warning => 'تنظیمات ناقص';

  @override
  String get invalidConfigurationWarning =>
      'پیکربندی هنوز کامل نیست (مثلاً کلید API یا شناسه مدل وارد نشده). می‌توانید ذخیره کنید و بعداً تکمیلش کنید. ادامه می‌دهید؟';

  @override
  String invalidModelConfigDetailed(Object agentId, Object configKey) {
    return 'عامل هوش مصنوعی «$agentId» برای کارکرد به پیکربندی معتبر مدل (کلید: «$configKey») نیاز دارد. لطفاً تنظیمات مدل را بررسی کنید.';
  }

  @override
  String get discardChangesTitle => 'این صفحه را ترک می‌کنید؟';

  @override
  String get discardChangesMessage =>
      'اگر تغییری داده‌اید، قبل از خروج آن را ذخیره کنید.';

  @override
  String get discardButton => 'صرف‌نظر';

  @override
  String get chooseLanguage => 'انتخاب زبان';

  @override
  String get chooseAvatar => 'انتخاب آواتار';

  @override
  String get configureNow => 'اکنون پیکربندی کنید';

  @override
  String get modelNotConfiguredBanner =>
      'مدل هوش مصنوعی هنوز پیکربندی نشده. برای فعال‌سازی همه قابلیت‌ها آن را تنظیم کنید.';

  @override
  String get modelNotConfiguredSubmitHint =>
      'لطفاً قبل از انتشار، یک مدل هوش مصنوعی پیکربندی کنید';

  @override
  String get processingStatus => 'در حال پردازش';

  @override
  String get failedStatus => 'ناموفق';

  @override
  String get failureReason => 'دلیل خطا';

  @override
  String get unknownError => 'خطای ناشناخته رخ داد';

  @override
  String get enableFitness => 'فعال‌سازی تناسب اندام';

  @override
  String get fitnessBannerMessage =>
      'برای ردیابی داده‌های سلامت و فعالیت، دسترسی به تناسب اندام را مجاز کنید.';

  @override
  String get fitnessDismissTitle => 'رد کردن دسترسی به تناسب اندام؟';

  @override
  String get fitnessDismissMessage =>
      'بدون مجوز تناسب اندام، برنامه نمی‌تواند به‌طور خودکار داده‌های سلامت شما را برای بینش‌ها و ثبت خودکار جمع‌آوری کند.';

  @override
  String get skipAnyway => 'با این حال رد شو';

  @override
  String get proModelHint => 'این مدل به اشتراک ChatGPT Pro/Plus نیاز دارد.';

  @override
  String get searchKnowledgeBase => 'جستجو در پایگاه دانش...';

  @override
  String get searchKnowledgeHint =>
      'کلیدواژه‌ای برای جستجو در نام یا محتوای فایل‌ها وارد کنید';

  @override
  String noSearchResults(Object query) {
    return 'نتیجه‌ای برای «$query» یافت نشد';
  }

  @override
  String get onlyMarkdownPreview => 'فقط پیش‌نمایش Markdown پشتیبانی می‌شود';

  @override
  String get backupAndRestore => 'پشتیبان‌گیری و بازیابی';

  @override
  String get createBackup => 'ایجاد پشتیبان';

  @override
  String get restoreBackup => 'بازیابی پشتیبان';

  @override
  String get backupDescription =>
      'همه داده‌های شما (کارت‌ها، پایگاه دانش، بینش‌ها، تنظیمات) را در یک فایل .memex بسته‌بندی کنید. از طریق برگه اشتراک‌گذاری آن را در iCloud Drive، Google Drive یا هر مکان دیگری ذخیره کنید.';

  @override
  String get restoreDescription =>
      'یک فایل پشتیبان .memex انتخاب کنید تا همه داده‌ها بازیابی شوند. این کار داده‌های فعلی را بازنویسی می‌کند.';

  @override
  String get selectBackupFile => 'انتخاب فایل پشتیبان';

  @override
  String get estimatedSize => 'حجم تقریبی';

  @override
  String get backupComplete => 'پشتیبان ایجاد شد';

  @override
  String backupFailed(Object error) {
    return 'پشتیبان‌گیری ناموفق بود: $error';
  }

  @override
  String get confirmRestore => 'تأیید بازیابی';

  @override
  String get confirmRestoreMessage =>
      'بازیابی همه داده‌های فعلی از جمله کارت‌ها، پایگاه دانش، بینش‌ها و تنظیمات را بازنویسی می‌کند. این کار قابل بازگشت نیست. ادامه می‌دهید؟';

  @override
  String get restoreComplete => 'بازیابی کامل شد';

  @override
  String get restoreRestartHint =>
      'داده‌ها بازیابی شدند. برای اعمال همه تغییرات، برنامه را مجدداً راه‌اندازی کنید.';

  @override
  String restoreFailed(Object error) {
    return 'بازیابی ناموفق بود: $error';
  }

  @override
  String get invalidBackupFile =>
      'فایل پشتیبان نامعتبر است. لطفاً یک فایل .memex انتخاب کنید.';

  @override
  String get automaticBackup => 'پشتیبان‌گیری خودکار';

  @override
  String get autoBackupDescription =>
      'در صورت فعال بودن، Memex حداکثر یک نسخه محلی در روز پس از راه‌اندازی یا بازگشت به پیش‌زمینه ایجاد می‌کند.';

  @override
  String get backupSensitiveSettingsHint =>
      'پشتیبان‌ها شامل تنظیمات و کلیدهای ارائه‌دهنده مدل هستند. فایل‌های پشتیبان را در مکانی امن نگه دارید.';

  @override
  String get backupLocation => 'مکان';

  @override
  String get backupLocationDetails => 'جزئیات مکان';

  @override
  String get backupLocationSummary => 'نمایش در برنامه';

  @override
  String get backupLocationFullPath => 'مسیر کامل';

  @override
  String get backupLocationUri => 'URI دسترسی به پوشه';

  @override
  String get copyBackupLocationPath => 'کپی مسیر';

  @override
  String get backupLocationCopied => 'مکان پشتیبان کپی شد';

  @override
  String androidBackupLocationSelected(Object folderName) {
    return 'پوشه انتخاب‌شده: $folderName';
  }

  @override
  String get iosICloudBackupLocation => 'iCloud Drive > Memex > Backups';

  @override
  String get iosAppDocumentsBackupLocation =>
      'Files > On My iPhone > Memex > Backups';

  @override
  String get autoBackupStatus => 'وضعیت';

  @override
  String get noAutoBackupYet => 'هنوز پشتیبان خودکاری وجود ندارد';

  @override
  String lastBackupAt(Object time) {
    return 'آخرین پشتیبان: $time';
  }

  @override
  String get autoBackupRetention => 'نگهداری';

  @override
  String autoBackupRetentionDays(Object days) {
    return '$days روز';
  }

  @override
  String get autoBackupRetentionForever => 'نگهداری دائمی';

  @override
  String get autoBackupMaxSize => 'سقف فضای ذخیره‌سازی';

  @override
  String autoBackupRetentionLimitHint(Object size) {
    return 'پاک‌سازی خودکار نسخه‌های خودکار را زیر $size نگه می‌دارد. نسخه‌های ایمنی و خروجی‌های دستی جداگانه نگه داشته می‌شوند.';
  }

  @override
  String get createSnapshotNow => 'اکنون پشتیبان بگیر';

  @override
  String get backupLocationMenu => 'تغییر مکان';

  @override
  String get defaultBackupLocation => 'پوشه پیش‌فرض پشتیبان';

  @override
  String get defaultBackupLocationAndroidDesc =>
      'از پوشه فایل‌های خارجی اختصاصی Memex استفاده کنید. نیازی به مجوز ذخیره‌سازی نیست.';

  @override
  String get chooseBackupLocation => 'انتخاب پوشه پشتیبان';

  @override
  String get chooseBackupLocationAndroidDesc =>
      'با انتخابگر سیستم Android یک پوشه انتخاب کنید و به Memex دسترسی دائمی بدهید.';

  @override
  String get storedBackups => 'پشتیبان‌های ذخیره‌شده';

  @override
  String get noStoredBackups =>
      'پس از اولین نسخه، پشتیبان‌های خودکار اینجا نمایش داده می‌شوند.';

  @override
  String get backupTypeAutoSnapshot => 'نسخه خودکار';

  @override
  String get backupTypeSafetySnapshot => 'نسخه ایمنی';

  @override
  String get backupTypeManualBackup => 'پشتیبان دستی';

  @override
  String get refresh => 'بازخوانی';

  @override
  String get restoreThisBackup => 'بازیابی این پشتیبان';

  @override
  String get deleteThisBackup => 'حذف این پشتیبان';

  @override
  String get confirmDeleteBackup => 'پشتیبان حذف شود؟';

  @override
  String confirmDeleteBackupMessage(Object fileName) {
    return '$fileName حذف شود؟ این کار فایل پشتیبان ذخیره‌شده را حذف می‌کند و قابل بازگشت نیست.';
  }

  @override
  String backupDeleted(Object fileName) {
    return 'پشتیبان حذف شد: $fileName';
  }

  @override
  String backupDeleteFailed(Object error) {
    return 'حذف پشتیبان ممکن نشد: $error';
  }

  @override
  String get creatingSafetySnapshot => 'در حال ایجاد نسخه ایمنی...';

  @override
  String autoBackupCreated(Object fileName) {
    return 'نسخه ایجاد شد: $fileName';
  }

  @override
  String backupLocationFailed(Object error) {
    return 'به‌روزرسانی مکان پشتیبان ممکن نشد: $error';
  }

  @override
  String get backupImportCreatedAt => 'ایجاد شده';

  @override
  String get backupImportSourceVersion => 'نسخه منبع';

  @override
  String get backupImportFlavor => 'ساخت';

  @override
  String get backupLegacyFormat => 'پشتیبان قدیمی (بدون مانیفست)';

  @override
  String get restoreInProgress => 'در حال بازیابی پشتیبان...';

  @override
  String get dataStorage => 'ذخیره‌سازی داده';

  @override
  String get dataStorageDescriptionAndroid =>
      'یک پوشه سفارشی برای ذخیره فضای کاری انتخاب کنید. داده‌ها پس از نصب مجدد برنامه حفظ می‌شوند.';

  @override
  String get dataStorageDescriptionIOS =>
      'iCloud را فعال کنید تا فضای کاری در دستگاه‌ها همگام‌سازی شود و پس از نصب مجدد حفظ بماند.';

  @override
  String get storageLocationApp => 'ذخیره‌سازی در برنامه';

  @override
  String get storageLocationAppDesc =>
      'داده‌ها داخل برنامه ذخیره می‌شوند و با حذف برنامه پاک می‌شوند.';

  @override
  String get storageLocationCustom => 'ذخیره‌سازی دستگاه (پوشه سفارشی)';

  @override
  String get storageLocationCustomDesc =>
      'داده‌ها در پوشه‌ای که انتخاب می‌کنید ذخیره می‌شوند. اگر پوشه باقی بماند، پس از نصب مجدد حفظ می‌شوند.';

  @override
  String get storageLocationICloud => 'ذخیره در iCloud';

  @override
  String get storageLocationICloudDesc =>
      'فضای کاری را در دستگاه‌های Apple همگام‌سازی کنید. داده‌ها پس از نصب مجدد باقی می‌مانند.';

  @override
  String storageLocationCurrent(Object location) {
    return 'فعلی: $location';
  }

  @override
  String get icloudRequiresCapability =>
      'برای استفاده از ذخیره‌سازی iCloud، به iCloud وارد شوید و iCloud Drive را فعال کنید.';

  @override
  String get loadingFromICloud => 'در حال بازیابی داده از iCloud…';

  @override
  String get switchingToICloud => 'در حال تغییر به ذخیره‌سازی iCloud…';

  @override
  String get switchingStorage => 'در حال تغییر محل ذخیره‌سازی…';

  @override
  String get customFolderAccessDenied =>
      'خواندن یا نوشتن در این پوشه ممکن نیست. لطفاً مجوز ذخیره‌سازی بدهید یا مکان دیگری انتخاب کنید.';

  @override
  String get configured => 'پیکربندی شده';

  @override
  String get apiKeyNotSet => 'کلید API تنظیم نشده — برای پیکربندی ضربه بزنید';

  @override
  String get bottomNavTimeline => 'خط زمانی';

  @override
  String get bottomNavLibrary => 'کتابخانه';

  @override
  String get aiGeneratedLabel => 'تولیدشده با هوش مصنوعی';

  @override
  String sourceTraceWithCount(Object count) {
    return 'ردیابی منبع ($count)';
  }

  @override
  String get deleteAccount => 'حذف حساب';

  @override
  String get deleteAccountDesc =>
      'همه داده‌های محلی را برای همیشه حذف و برنامه را بازنشانی کنید.';

  @override
  String get deleteAccountConfirmTitle => 'حساب حذف شود؟';

  @override
  String get deleteAccountConfirmMessage =>
      'این کار همه داده‌های شما از جمله کارت‌های خط زمانی، پایگاه دانش، ضبط‌ها و تنظیمات را برای همیشه حذف می‌کند. این عمل قابل بازگشت نیست.';

  @override
  String deleteAccountTypeName(Object name) {
    return 'برای تأیید «$name» را تایپ کنید';
  }

  @override
  String get deleteAccountTypeHint => 'نام کاربری خود را برای تأیید وارد کنید';

  @override
  String get llmConsentTitle => 'رضایت‌نامه اشتراک‌گذاری داده';

  @override
  String llmConsentMessage(Object provider) {
    return 'برای فعال‌سازی قابلیت‌های هوش مصنوعی، Memex باید داده‌های شما را برای پردازش به $provider ارسال کند. این شامل موارد زیر است:\n\n• متنی که وارد می‌کنید (یادداشت‌ها، رونوشت صدا)\n• فراداده عکس و متن استخراج‌شده (OCR)\n• خلاصه‌های سلامت و تناسب اندام\n• محتوای کارت‌های خط زمانی\n\nداده‌های شما مستقیماً از دستگاه شما به $provider ارسال می‌شوند. Memex داده‌های شما را در هیچ سرور دیگری ذخیره یا منتقل نمی‌کند.\n\nلطفاً سیاست حریم خصوصی $provider را درباره نحوه مدیریت داده‌هایتان مطالعه کنید.\n\nآیا با ارسال داده‌هایتان به $provider برای پردازش هوش مصنوعی موافقید؟';
  }

  @override
  String get llmConsentAgree => 'موافقم';

  @override
  String get llmConsentDecline => 'رد';

  @override
  String get customAgents => 'عامل‌های سفارشی';

  @override
  String get noCustomAgents => 'عامل سفارشی پیکربندی نشده است.';

  @override
  String get deleteAgent => 'حذف عامل';

  @override
  String deleteAgentConfirm(Object name) {
    return 'عامل سفارشی «$name» حذف شود؟';
  }

  @override
  String get deleted => 'حذف شد';

  @override
  String get saved => 'ذخیره شد';

  @override
  String get newAgent => 'عامل جدید';

  @override
  String get editAgent => 'ویرایش عامل';

  @override
  String get agentName => 'نام عامل';

  @override
  String get agentNameHint => 'my-custom-agent';

  @override
  String get agentNameRequired => 'الزامی';

  @override
  String get agentNameInvalid => 'فقط حروف، اعداد و خط تیره';

  @override
  String get agentNameExists => 'این نام از قبل وجود دارد';

  @override
  String get hostAgentType => 'نوع عامل میزبان';

  @override
  String get skillDirectory => 'پوشه مهارت';

  @override
  String get skillDirInvalid => 'باید مسیر نسبی باشد (بدون / یا .. در ابتدا)';

  @override
  String get workingDirectory => 'پوشه کاری (اختیاری)';

  @override
  String get workingDirectoryHint => 'برای پیش‌فرض فضای کاری خالی بگذارید';

  @override
  String get llmConfig => 'پیکربندی LLM';

  @override
  String get eventType => 'نوع رویداد';

  @override
  String get executionMode => 'حالت اجرا';

  @override
  String get executionModeAsync => 'ناهمزمان';

  @override
  String get executionModeSync => 'همزمان';

  @override
  String get dependsOn => 'وابسته به';

  @override
  String get dependsOnHint => 'وابستگی‌ها را انتخاب کنید';

  @override
  String get priority => 'اولویت';

  @override
  String get maxRetries => 'حداکثر تلاش مجدد';

  @override
  String get systemPromptLabel => 'دستور سیستم (اختیاری)';

  @override
  String get systemPromptHint =>
      'دستورالعمل‌های اضافی که به دستور عامل میزبان اضافه می‌شوند';

  @override
  String get eventSerializer => 'سریال‌ساز رویداد';

  @override
  String get eventSerializerDefault => 'پیش‌فرض (XML)';

  @override
  String get enabledLabel => 'فعال';

  @override
  String get skillsManagement => 'مدیریت مهارت‌ها';

  @override
  String get skillsManagementEmpty => 'هنوز مهارتی وجود ندارد';

  @override
  String get downloadSkill => 'دانلود مهارت';

  @override
  String get downloadFile => 'دانلود فایل';

  @override
  String get downloading => 'در حال دانلود...';

  @override
  String get downloadSuccess => 'مهارت با موفقیت دانلود شد';

  @override
  String downloadFailed(Object error) {
    return 'دانلود ناموفق بود: $error';
  }

  @override
  String get deleteConfirm => 'تأیید حذف';

  @override
  String deleteConfirmMessage(String name) {
    return 'آیا مطمئنید که می‌خواهید «$name» را حذف کنید؟';
  }

  @override
  String get invalidUrl => 'لطفاً یک URL معتبر وارد کنید';

  @override
  String get urlHint => 'https://example.com/skill.zip';

  @override
  String get newFolder => 'پوشه جدید';

  @override
  String get newFile => 'فایل جدید';

  @override
  String get folderName => 'نام پوشه';

  @override
  String get fileName => 'نام فایل';

  @override
  String get nameRequired => 'نام الزامی است';

  @override
  String get nameInvalid => 'نام نمی‌تواند شامل / یا .. باشد';

  @override
  String createFailed(Object error) {
    return 'ایجاد ناموفق بود: $error';
  }

  @override
  String get fileContent => 'محتوای فایل';

  @override
  String get saveSuccess => 'با موفقیت ذخیره شد';

  @override
  String downloadToCurrentDir(String dir) {
    return 'فایل zip در پوشهٔ فعلی استخراج خواهد شد: $dir';
  }

  @override
  String get privacyPolicy => 'سیاست حریم خصوصی';

  @override
  String get privacyPolicyDesc => 'نحوهٔ رسیدگی Memex به داده‌های شما';

  @override
  String get llmAuthError =>
      'احراز هویت API ناموفق بود. لطفاً پیکربندی LLM خود را در تنظیمات بررسی کنید.';

  @override
  String get llmBadRequestError =>
      'درخواست توسط ارائه‌دهندهٔ LLM رد شد. ممکن است قالب ورودی توسط مدل فعلی پشتیبانی نشود.';

  @override
  String get llmRateLimitError =>
      'محدودیت نرخ API فراتر رفت. لطفاً بعداً دوباره تلاش کنید.';

  @override
  String get llmServerError =>
      'سرویس LLM موقتاً در دسترس نیست. لطفاً بعداً دوباره تلاش کنید.';

  @override
  String get llmNetworkError =>
      'اتصال شبکه برقرار نشد. لطفاً اتصال اینترنت خود را بررسی کنید.';

  @override
  String get llmUnknownError =>
      'هنگام پردازش محتوای شما خطای غیرمنتظره‌ای رخ داد.';

  @override
  String get llmErrorDialogTitle => 'پردازش ناموفق بود';

  @override
  String get goToModelConfig => 'رفتن به تنظیمات';

  @override
  String get speechModelDownloadTitle => 'دانلود مدل گفتار';

  @override
  String speechModelDownloadDesc(Object sizeMB) {
    return 'یک دانلود یک‌بارهٔ مدل (~$sizeMB مگابایت) لازم است.\n\nپس از دانلود، رونویسی کاملاً روی دستگاه انجام می‌شود.';
  }

  @override
  String get speechModelStartDownload => 'شروع دانلود';

  @override
  String get speechModelChooseSource => 'منبع دانلود را انتخاب کنید:';

  @override
  String get speechModelChinaMirror => '🇨🇳 آینهٔ چین (سریع‌تر در چین)';

  @override
  String get speechModelGithub => '🌐 GitHub (جهانی)';

  @override
  String get speechModelDownloading => 'در حال دانلود مدل...';

  @override
  String get speechModelConnecting => 'در حال اتصال...';

  @override
  String get deleteSpeechModel => 'حذف مدل گفتار';

  @override
  String get confirmDeleteSpeechModelMessage =>
      'فایل‌های مدل تشخیص گفتار محلی دانلودشده حذف شوند؟ دفعهٔ بعدی که از گفتار به متن محلی استفاده کنید، دوباره دانلود خواهند شد.';

  @override
  String get speechModelDeletedSuccess => 'فایل‌های مدل گفتار حذف شدند';

  @override
  String get speechModelNotDownloaded => 'فایل مدل گفتار دانلودشده‌ای یافت نشد';

  @override
  String speechModelDeleteFailed(Object error) {
    return 'حذف فایل‌های مدل گفتار ناموفق بود: $error';
  }

  @override
  String get speechTranscribing => 'در حال شناسایی...';

  @override
  String get speechNoResult => 'گفتاری شناسایی نشد';

  @override
  String get useLocalSpeechToTextTitle => 'استفاده از گفتار به متن محلی';

  @override
  String get useLocalSpeechToTextDesc =>
      'در صورت فعال بودن، صدا قبل از ارسال روی دستگاه رونویسی می‌شود — برای مدل‌هایی که ورودی صوتی را پشتیبانی نمی‌کنند مفید است. در صورت غیرفعال بودن، صدای اصلی مستقیماً به مدل ارسال می‌شود.';

  @override
  String get pendingAiProcessingHint =>
      'برای پردازش، مدل هوش مصنوعی را تنظیم کنید';

  @override
  String get demoWelcome =>
      'به Memex خوش آمدید!\nبیایید سریعی ببینیم هوش مصنوعی چه کاری می‌تواند برای رکوردهای شما انجام دهد.';

  @override
  String get demoTapAdd => 'اینجا بزنید تا اولین رکورد خود را بسازید';

  @override
  String get demoTapSend => 'برای ارسال اولین رکورد بزنید';

  @override
  String get demoTapCard =>
      'بزنید تا ببینید هوش مصنوعی رکورد شما را چگونه سازماندهی کرده';

  @override
  String get demoDetailHint =>
      'این جزئیات رکورد سازماندهی‌شده توسط هوش مصنوعی است. پیمایش کنید، سپس برای ادامهٔ تور برگردید.';

  @override
  String get demoTapInsight =>
      'برای دیدن بینش‌های تولیدشده توسط هوش مصنوعی بزنید';

  @override
  String get demoTapInsightUpdate => 'برای تولید بینش از رکوردهای خود بزنید';

  @override
  String get demoTapKnowledge =>
      'فایل‌های دانش سازماندهی‌شدهٔ خودکار خود را ببینید';

  @override
  String get demoDone => 'زندگی خود را ثبت کنید.';

  @override
  String get demoStartTour => 'شروع تور';

  @override
  String get demoGetStarted => 'شروع کنید';

  @override
  String get demoSkip => 'رد کردن';

  @override
  String get demoPrefillText => 'سلام Memex! این اولین رکورد من است 🎉';

  @override
  String get visionBadge => 'بینایی';

  @override
  String get notMultimodalHint =>
      'Memex برای تحلیل رسانه به قابلیت‌های مدل چندوجهی متکی است. اگر رکوردهای شما تصویر دارند، مطمئن شوید مدل پیکربندی‌شده ورودی تصویر را پشتیبانی می‌کند.';

  @override
  String get defaultModelPrefix => 'پیش‌فرض';

  @override
  String get recommendedBadge => 'توصیه‌شده';

  @override
  String get readOnlyBadge => 'گفتگو';

  @override
  String get switchCompanion => 'تعویض همراه';

  @override
  String get personaChatInputHint => 'پیامی بنویسید...';

  @override
  String get today => 'امروز';

  @override
  String get tomorrow => 'فردا';

  @override
  String get yesterday => 'دیروز';

  @override
  String get showInsightTextTitle => 'نمایش نظر بینش Memex';

  @override
  String get showInsightTextDesc =>
      'نمایش بینش Memex به‌عنوان نظر سنجاق‌شده در بخش نظرات جزئیات کارت.';

  @override
  String get enableCharacterCommentTitle => 'نظر خودکار شخصیت';

  @override
  String get enableCharacterCommentDesc =>
      'شخصیت‌ها به‌طور خودکار روی رکوردهای جدید نظر می‌گذارند.';

  @override
  String get maxCommentCharactersTitle => 'حداکثر شخصیت‌های نظردهنده';

  @override
  String get maxCommentCharactersDesc =>
      'چند شخصیت می‌توانند روی هر رکورد نظر بگذارند.';

  @override
  String replyTo(String name) {
    return 'پاسخ به $name';
  }

  @override
  String get cdnSignalsComments => 'پاسخ جدید دریافت شد';

  @override
  String get cdnSignalsInsight => 'بینش جدید تولید شد';

  @override
  String get cdnSignalsBoth => 'پاسخ و بینش جدید';

  @override
  String get untitledCard => 'کارت بدون عنوان';

  @override
  String get locationContextTitle => 'زمینهٔ موقعیت مکانی';

  @override
  String get locationContextDescription =>
      'زمینهٔ شهر و محلهٔ فعلی برای گفتگوی عامل';

  @override
  String get locationContextAttachTitle => 'پیوست موقعیت فعلی به گفتگو';

  @override
  String get locationContextAttachDesc =>
      'از GPS دستگاه و تبدیل مختصات به آدرس برای ارائهٔ زمینهٔ شهر، منطقه و محله به عامل استفاده می‌کند.';

  @override
  String get reverseGeocodingProvider => 'ارائه‌دهندهٔ تبدیل مختصات به آدرس';

  @override
  String get amapProviderName => 'Amap';

  @override
  String get amapApiKey => 'کلید API Amap';

  @override
  String get amapGcj02Note =>
      'Amap از مختصات GCJ-02 استفاده می‌کند. GPS دستگاه قبل از تبدیل به آدرس تبدیل می‌شود.';

  @override
  String get contextGranularity => 'دقت زمینه';

  @override
  String get granularityCity => 'شهر';

  @override
  String get granularityDistrict => 'منطقه';

  @override
  String get granularityNeighborhood => 'محله';

  @override
  String get granularityStreet => 'خیابان';

  @override
  String get granularityFullAddress => 'آدرس کامل احتمالی';

  @override
  String get locationFreshness => 'تازگی موقعیت';

  @override
  String minutesShort(int minutes) {
    return '$minutes دقیقه';
  }

  @override
  String get oneHour => '۱ ساعت';

  @override
  String get testCurrentLocation => 'آزمون موقعیت فعلی';

  @override
  String locationTestFailed(String error) {
    return 'ناموفق: $error';
  }

  @override
  String get locationDebugGps => 'GPS';

  @override
  String get locationDebugReverseGeocode => 'تبدیل به آدرس';

  @override
  String get locationDebugProvider => 'ارائه‌دهنده';

  @override
  String get locationDebugAgentContext => 'زمینهٔ عامل';

  @override
  String get locationDebugSource => 'منبع';

  @override
  String get locationDebugAddressSummary => 'خلاصهٔ آدرس';

  @override
  String get locationDebugFullAddress => 'آدرس کامل';

  @override
  String get locationDebugCoordinates => 'مختصات';

  @override
  String get locationDebugAccuracy => 'دقت';

  @override
  String get locationDebugReason => 'دلیل';

  @override
  String get locationDebugOk => 'تأیید';

  @override
  String get locationDebugUnavailable => 'در دسترس نیست';

  @override
  String get locationDebugInjected => 'تزریق‌شده';

  @override
  String get locationDebugNotInjected => 'تزریق‌نشده';

  @override
  String get locationStatusUpdatedAt => 'به‌روزرسانی';

  @override
  String get locationStatusSuccessTitle => 'موقعیت فعلی آماده است';

  @override
  String get locationStatusSuccessBody =>
      'Memex می‌تواند این خلاصهٔ موقعیت را در صورت مرتبط بودن زمینهٔ مکانی پیوست کند.';

  @override
  String get locationStatusApproximateTitle => 'فقط موقعیت تقریبی';

  @override
  String get locationStatusApproximateBody =>
      'دقت در سطح شهر یا منطقه به نظر می‌رسد. می‌توانید از آن استفاده کنید، یا برای زمینهٔ دقیق‌تر موقعیت دقیق را در تنظیمات سیستم فعال کنید.';

  @override
  String get locationStatusServiceDisabledTitle =>
      'موقعیت‌یابی سیستم خاموش است';

  @override
  String get locationStatusServiceDisabledBody =>
      'Memex فقط از GPS دستگاه استفاده می‌کند و موقعیت را از شبکه یا IP حدس نمی‌زند. در Android تنظیمات موقعیت را باز کنید؛ در iOS تنظیمات > حریم خصوصی و امنیت > سرویس‌های موقعیت‌یابی را فعال کنید.';

  @override
  String get locationStatusPermissionDeniedTitle =>
      'مجوز موقعیت مکانی لازم است';

  @override
  String get locationStatusPermissionDeniedBody =>
      'به Memex اجازه دهید هنگام آزمون یا در صورت نیاز به زمینهٔ مکانی از موقعیت استفاده کند. دسترسی همیشگی درخواست نمی‌شود.';

  @override
  String get locationStatusPermissionForeverTitle =>
      'مجوز موقعیت مسدود شده است';

  @override
  String get locationStatusPermissionForeverBody =>
      'تنظیمات برنامه را باز کنید و موقعیت را برای Memex مجاز کنید. در iOS «هنگام استفاده از برنامه» کافی است.';

  @override
  String get locationStatusDisabledTitle => 'زمینهٔ موقعیت مکانی خاموش است';

  @override
  String get locationStatusDisabledBody =>
      'وقتی می‌خواهید Memex موقعیت دستگاه را به زمینهٔ عامل پیوست کند، کلید بالا را روشن کنید و ذخیره کنید.';

  @override
  String get locationStatusGeocodeUnavailableTitle =>
      'GPS کار می‌کند، جستجوی آدرس ناموفق بود';

  @override
  String get locationStatusGeocodeUnavailableBody =>
      'Memex مختصات را دارد اما زمینهٔ فقط GPS را به عامل تزریق نمی‌کند. ارائه‌دهندهٔ تبدیل مختصات به آدرس را بررسی کنید و دوباره تلاش کنید.';

  @override
  String get locationStatusUnavailableTitle => 'موقعیت در دسترس نیست';

  @override
  String get locationStatusUnavailableBody =>
      'سرویس‌های موقعیت‌یابی سیستم و مجوز برنامه را بررسی کنید، سپس دوباره آزمون کنید.';

  @override
  String get allowLocationPermissionButton => 'مجاز کردن دسترسی موقعیت';

  @override
  String get openAppSettingsButton => 'باز کردن تنظیمات برنامه';

  @override
  String get openLocationSettingsButton => 'باز کردن تنظیمات موقعیت';

  @override
  String get locationSettingsOpenFailed => 'باز کردن تنظیمات سیستم ممکن نشد.';

  @override
  String locationActionFailed(String error) {
    return 'عملیات موقعیت ناموفق بود: $error';
  }

  @override
  String get settingsSearchPlaceholder => 'جستجو در تنظیمات...';

  @override
  String get settingsSearchEmpty => 'تنظیمات مطابقتی یافت نشد';

  @override
  String get importCharacterCard => 'وارد کردن کارت شخصیت';

  @override
  String get firstMessageLabel => 'اولین پیام';

  @override
  String get firstMessageHint => 'سلام ارسالی در اولین گفتگو (اختیاری)';

  @override
  String get systemPromptOverrideLabel => 'جایگزینی دستور سیستم';

  @override
  String get systemPromptOverrideHint =>
      'جایگزینی دستور سیستم پیش‌فرض (پیشرفته، اختیاری)';

  @override
  String get postHistoryInstructionsLabel => 'دستورات پس از تاریخچه';

  @override
  String get postHistoryInstructionsHint =>
      'دستورات تزریق‌شده پس از تاریخچهٔ گفتگو، قبل از پاسخ (اختیاری)';

  @override
  String get mesExampleLabel => 'نمونه پیام‌ها';

  @override
  String get mesExampleHint => 'گفتگوهای نمونه برای نمایش سبک شخصیت (اختیاری)';

  @override
  String get worldBookTitle => 'کتاب جهان';

  @override
  String get worldBookSubtitle =>
      'دانش پس‌زمینه تزریق‌شده هنگام فعال شدن کلیدواژه‌ها';

  @override
  String get characterMemoryTitle => 'حافظهٔ شخصیت';

  @override
  String get characterMemorySubtitle =>
      'پویایی رابطه و خاطرات تعامل بین شخصیت و کاربر';

  @override
  String get addTooltip => 'افزودن';

  @override
  String get constantBadge => 'ثابت';

  @override
  String worldEntryFallbackName(Object index) {
    return 'ورودی $index';
  }

  @override
  String keywordsPrefix(Object keys) {
    return 'کلیدواژه‌ها: $keys';
  }

  @override
  String memoryFallbackName(Object index) {
    return 'خاطره $index';
  }

  @override
  String get addWorldEntry => 'افزودن ورودی کتاب جهان';

  @override
  String get editWorldEntry => 'ویرایش ورودی کتاب جهان';

  @override
  String get commentTitleLabel => 'نظر / عنوان';

  @override
  String get entryDescriptionHint => 'توضیح ورودی (اختیاری)';

  @override
  String get triggerKeywordsLabel => 'کلیدواژه‌های محرک';

  @override
  String get triggerKeywordsHint => 'با ویرگول جدا کنید، مثلاً: جادو، طلسم';

  @override
  String get contentLabel => 'محتوا';

  @override
  String get worldEntryContentHint =>
      'دانش پس‌زمینه تزریق‌شده هنگام فعال شدن کلیدواژه‌ها';

  @override
  String get enabledCheckbox => 'فعال';

  @override
  String get addMemory => 'افزودن خاطره';

  @override
  String get editMemory => 'ویرایش خاطره';

  @override
  String get memoryLabelField => 'برچسب';

  @override
  String get memoryLabelHint => 'شناسهٔ یکتا، مثلاً: ترجیح نام';

  @override
  String get memoryContentHint => 'محتوای خاطره';

  @override
  String get salienceLabel => 'اهمیت: ';

  @override
  String get labelCannotBeEmpty => 'برچسب نمی‌تواند خالی باشد';

  @override
  String importSuccess(Object name) {
    return '$name با موفقیت وارد شد';
  }

  @override
  String importFailed(Object error) {
    return 'وارد کردن ناموفق بود: $error';
  }

  @override
  String get supportedFormats => 'قالب‌های پشتیبانی‌شده';

  @override
  String get tavernImportDescription =>
      '• کارت‌های شخصیت SillyTavern V2 (.json)\n• تصاویر PNG با کارت جاسازی‌شده (.png)\n\nفیلدهایی مانند شخصیت، کتاب جهان و غیره به‌طور خودکار به قالب شخصیت Memex نگاشت می‌شوند.';

  @override
  String get pickCharacterFile => 'انتخاب فایل شخصیت';

  @override
  String get repickFile => 'انتخاب فایل دیگر';

  @override
  String get personaSettingSection => 'شخصیت';

  @override
  String get systemPromptSection => 'دستور سیستم';

  @override
  String worldEntriesCount(Object count) {
    return 'کتاب جهان: $count ورودی';
  }

  @override
  String fileLabel(Object filename) {
    return 'فایل: $filename';
  }

  @override
  String conflictWarning(Object names) {
    return 'شخصیتی با همین نام از قبل وجود دارد: $names. وارد کردن شخصیت جدیدی ایجاد می‌کند بدون بازنویسی موارد موجود.';
  }

  @override
  String get setPrimaryCompanionTitle => 'تنظیم به‌عنوان همراه اصلی';

  @override
  String get setPrimaryCompanionSubtitle =>
      'پس از وارد کردن به‌طور خودکار به‌عنوان همراه اصلی شما تنظیم شود';

  @override
  String get confirmImport => 'تأیید وارد کردن';

  @override
  String get chatBackground => 'پس‌زمینهٔ گفتگو';

  @override
  String get chooseChatBackgroundImage => 'انتخاب تصویر پس‌زمینه';

  @override
  String get earlyUpdateSettingsTitle => 'به‌روزرسانی دسترسی زودهنگام';

  @override
  String get earlyUpdateSettingsDesc =>
      'پیش‌انتشارهای GitHub را برای APK Early مربوطه بررسی کنید، آن را دانلود کنید و به نصب‌کنندهٔ Android بسپارید.';

  @override
  String get earlyUpdateUnsupported =>
      'به‌روزرسانی‌های زودهنگام فقط در نسخهٔ Early اندروید در دسترس است.';

  @override
  String get earlyUpdateAutoCheckTitle => 'بررسی خودکار به‌روزرسانی';

  @override
  String get earlyUpdateAutoCheckDesc =>
      'حداکثر هر ۱۲ ساعت یک‌بار هنگام راه‌اندازی بررسی شود.';

  @override
  String get earlyUpdateWifiOnlyTitle => 'دانلود فقط با Wi-Fi';

  @override
  String get earlyUpdateWifiOnlyDesc =>
      'هنگام استفاده از دادهٔ موبایل از دانلود به‌روزرسانی صرف‌نظر شود.';

  @override
  String get earlyUpdateAutoInstallTitle => 'دانلود و نصب خودکار';

  @override
  String get earlyUpdateAutoInstallDesc =>
      'وقتی نسخهٔ جدیدی یافت شد، آن را دانلود کنید و نصب‌کنندهٔ Android را به‌طور خودکار باز کنید.';

  @override
  String get earlyUpdateCheckNow => 'بررسی اکنون';

  @override
  String get earlyUpdateChecking => 'در حال بررسی پیش‌انتشارهای GitHub...';

  @override
  String get earlyUpdateSkippedMobile =>
      'به‌دلیل فعال بودن دانلود فقط با Wi-Fi رد شد.';

  @override
  String get earlyUpdateNoUpdate =>
      'شما از جدیدترین نسخهٔ Early استفاده می‌کنید.';

  @override
  String earlyUpdateFound(Object version, Object build) {
    return 'نسخهٔ Early $version+$build در دسترس است.';
  }

  @override
  String get earlyUpdateDownloadAndInstall => 'دانلود و نصب';

  @override
  String get earlyUpdateDownloadInProgress => 'در حال دانلود به‌روزرسانی...';

  @override
  String earlyUpdateDownloadingPercent(Object percent) {
    return 'در حال دانلود به‌روزرسانی: $percent٪';
  }

  @override
  String get earlyUpdateDownloadReadyToInstall =>
      'بستهٔ به‌روزرسانی دانلود شد. آمادهٔ نصب.';

  @override
  String get earlyUpdateInstallDownloadedPackage => 'نصب بستهٔ دانلودشده';

  @override
  String get earlyUpdateClearDownloadedPackage => 'پاک کردن بستهٔ دانلودشده';

  @override
  String get earlyUpdateClearDownloadedPackageSuccess =>
      'بستهٔ به‌روزرسانی دانلودشده پاک شد.';

  @override
  String get earlyUpdateInstallStarted => 'نصب‌کنندهٔ Android باز شد.';

  @override
  String get earlyUpdateInstallPermissionRequired =>
      'به Memex اجازهٔ نصب برنامه‌های ناشناس را بدهید، سپس دوباره دانلود و نصب را بزنید.';

  @override
  String earlyUpdateLastChecked(Object time) {
    return 'آخرین بررسی: $time';
  }

  @override
  String earlyUpdateCheckFailed(Object error) {
    return 'بررسی به‌روزرسانی ناموفق بود: $error';
  }

  @override
  String get earlyUpdateDialogTitle => 'به‌روزرسانی زودهنگام در دسترس است';

  @override
  String get earlyUpdateReleaseNotes => 'یادداشت‌های انتشار';

  @override
  String get dismissAllNotifications => 'پاک کردن همه';

  @override
  String get dismissByType => 'پاک کردن بر اساس نوع';

  @override
  String get dismissTypeSystemAction => 'یادآورها و رویدادها';

  @override
  String get dismissTypeClarification => 'توضیحات';

  @override
  String get dismissTypeCardUpdate => 'به‌روزرسانی کارت‌ها';

  @override
  String dismissedCount(Object count) {
    return '$count مورد پاک شد';
  }

  @override
  String get dataImportTitle => 'وارد کردن فایل‌ها';

  @override
  String get dataImportSettingsDescription =>
      'فایل‌های قدیمی را به Memex بیاورید، سپس تصمیم بگیرید آیا سازماندهی شوند.';

  @override
  String get dataImportDescription =>
      'یادداشت‌ها، رکوردهای صادرشده، اسناد یا آرشیوهای ZIP قدیمی را انتخاب کنید. Memex ابتدا یک کپی ذخیره می‌کند و فایل‌های اصلی دست‌نخورده می‌مانند. پس از وارد کردن می‌توانید تصمیم بگیرید Memex در سازماندهی آن‌ها کمک کند یا نه.';

  @override
  String get dataImportSelectFiles => 'انتخاب فایل‌ها برای وارد کردن';

  @override
  String get dataImportImporting => 'در حال ذخیرهٔ فایل‌ها...';

  @override
  String get dataImportSuccess => 'فایل‌ها در Memex ذخیره شدند';

  @override
  String get dataImportOnlyStored => 'فایل‌ها ذخیره شدند. سازماندهی آغاز نشد.';

  @override
  String get dataImportQueued =>
      'Memex این وارد کردن را در پس‌زمینه سازماندهی خواهد کرد.';

  @override
  String get dataImportResultTitle => 'وارد کردن کامل شد';

  @override
  String dataImportResultSummary(Object count) {
    return '$count فایل ذخیره شد. می‌توانید اکنون آن‌ها را سازماندهی کنید یا به‌عنوان منبع اصلی نگه دارید.';
  }

  @override
  String dataImportRenamedConflicts(Object count) {
    return '$count مورد نام یکسان داشتند و برای جلوگیری از بازنویسی تغییر نام یافتند.';
  }

  @override
  String dataImportSkippedUnsafeEntries(Object count) {
    return '$count مورد غیرمعمول در آرشیو رد شد؛ بقیه به‌طور عادی وارد شدند.';
  }

  @override
  String get dataImportChooseProcessing => 'سازماندهی این فایل‌ها';

  @override
  String get dataImportProcessTitle => 'این وارد کردن سازماندهی شود؟';

  @override
  String dataImportProcessPrompt(Object count) {
    return 'شما $count فایل وارد کردید. انتخاب کنید Memex اکنون آن‌ها را سازماندهی کند یا فقط نسخه‌های اصلی را نگه دارد.';
  }

  @override
  String get dataImportProcessKnowledgeBase => 'سازماندهی در پایگاه دانش';

  @override
  String get dataImportProcessKnowledgeBaseDesc =>
      'مناسب برای اسناد، یادداشت‌ها، مطالب پروژه و مراجع. Memex اطلاعات مفید را استخراج و برای استفادهٔ بعدی گروه‌بندی می‌کند.';

  @override
  String get dataImportProcessTimelineCards => 'ایجاد رکوردهای خط زمانی';

  @override
  String get dataImportProcessTimelineCardsDesc =>
      'مناسب برای خاطرات روزانه، گفتگوها، تاریخچهٔ فعالیت و صادرات قدیمی. Memex محتوای زمان‌محور را در صورت مناسب بودن به رکورد تبدیل می‌کند.';

  @override
  String get dataImportImpactNone =>
      'Memex فقط این فایل‌های اصلی را نگه می‌دارد. سازماندهی هوش مصنوعی آغاز نمی‌شود.';

  @override
  String get dataImportImpactKnowledgeBase =>
      'Memex این فایل‌ها را می‌خواند و اطلاعات بلندمدت مفید را در پایگاه دانش سازماندهی می‌کند. به‌طور فعال رکوردهای خط زمانی ایجاد نمی‌کند.';

  @override
  String get dataImportImpactTimelineCards =>
      'Memex این فایل‌ها را می‌خواند و در صورت مناسب بودن رکوردهای خط زمانی برای رویدادهای زندگی یا تاریخچهٔ تاریخ‌دار ایجاد می‌کند. به‌طور فعال پایگاه دانش را سازماندهی نمی‌کند.';

  @override
  String get dataImportImpactBoth =>
      'Memex تلاش می‌کند رکوردهای خط زمانی ایجاد کند و اطلاعات قابل استفادهٔ مجدد را در پایگاه دانش سازماندهی کند. این برای آرشیو شخصی کامل بهترین است.';

  @override
  String get dataImportFinish => 'فقط ذخیره شوند';

  @override
  String get noImages => 'تصویری نیست';

  @override
  String get noMessages => 'پیامی نیست';

  @override
  String get sketchContent => 'محتوای طرح';

  @override
  String get emptyFolder => 'پوشه خالی';

  @override
  String get usernameAlreadyTaken => 'نام کاربری قبلاً گرفته شده است';

  @override
  String get registrationFailed => 'ثبت‌نام ناموفق بود';

  @override
  String get loginFailed => 'ورود ناموفق بود';

  @override
  String get paymentCreationFailed => 'شروع پرداخت ممکن نشد';

  @override
  String get completePayment => 'تکمیل پرداخت';

  @override
  String get commentReplyToYou => 'شما';

  @override
  String get commentAuthorUser => 'کاربر';

  @override
  String get commentAuthorAi => 'هوش مصنوعی';

  @override
  String get authorizationCancelled => 'مجوز لغو شد';

  @override
  String timelineWeekNumberLabel(Object week) {
    return 'هفته $week';
  }

  @override
  String get timelineWeekLabel => 'هفته';

  @override
  String get eventCardDefaultTitle => 'رویداد';

  @override
  String get memoryNoLongTermYet => 'هنوز هیچ خاطره بلندمدتی وجود ندارد.';

  @override
  String get memoryNoRecentBuffer => 'هیچ خاطره جدیدی در بافر وجود ندارد.';

  @override
  String get memoryGeneralSubject => 'عمومی';
}
