// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get timesLabel => 'Số lần';

  @override
  String modelSetAsDefault(Object modelId) {
    return 'Đặt $modelId làm mô hình mặc định';
  }

  @override
  String get retry => 'Thử lại';

  @override
  String get unknownModel => 'Mô hình không xác định';

  @override
  String get notSet => 'Chưa đặt';

  @override
  String get confirmClear => 'Xác nhận xóa';

  @override
  String get confirmClearTokenMessage =>
      'Xóa người dùng hiện tại? Bạn sẽ cần nhập lại ID người dùng.';

  @override
  String get cancel => 'Hủy';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get tokenCleared => 'Đã xóa người dùng';

  @override
  String clearTokenFailed(Object error) {
    return 'Không thể xóa người dùng: $error';
  }

  @override
  String get selectDateRangeOptional => 'Chọn khoảng ngày (tùy chọn):';

  @override
  String get startDate => 'Ngày bắt đầu';

  @override
  String get endDate => 'Ngày kết thúc';

  @override
  String get select => 'Chọn';

  @override
  String get processLimitOptional => 'Giới hạn xử lý (tùy chọn)';

  @override
  String get leaveEmptyForAll => 'Để trống để xử lý tất cả';

  @override
  String get startProcessing => 'Bắt đầu xử lý';

  @override
  String get userIdNotFound => 'Không tìm thấy ID người dùng';

  @override
  String createTaskFailed(Object error) {
    return 'Không thể tạo tác vụ: $error';
  }

  @override
  String get reprocessCards => 'Xử lý lại thẻ';

  @override
  String get reprocessCardsTaskCreated =>
      'Yêu cầu xử lý lại đã được đưa vào hàng đợi Super Agent';

  @override
  String get reprocessCardsDownstreamMode => 'Phạm vi';

  @override
  String get reprocessCardsCardOnly => 'Chỉ thẻ';

  @override
  String get reprocessCardsCardOnlyDesc =>
      'Yêu cầu Super Agent xem xét và tạo lại các thẻ dòng thời gian đã chọn.';

  @override
  String get reprocessCardsRerunDownstream =>
      'Thẻ và các bước theo dõi liên quan';

  @override
  String get reprocessCardsRerunDownstreamDesc =>
      'Yêu cầu Super Agent cũng xem xét các cập nhật PKM và insight liên quan khi cần.';

  @override
  String get reanalyzeMediaAssets => 'Đọc lại tệp đính kèm phương tiện';

  @override
  String get reanalyzeMediaAssetsDesc =>
      'Yêu cầu Super Agent kiểm tra lại phương tiện đính kèm khi tạo lại thẻ.';

  @override
  String get regenerateComments => 'Tạo lại bình luận';

  @override
  String get regenerateCommentsTaskCreated =>
      'Tác vụ tạo lại bình luận đã được tạo, đang chạy nền';

  @override
  String get rebuildSearchIndex => 'Xây dựng lại chỉ mục tìm kiếm';

  @override
  String get rebuildSearchIndexSuccess =>
      'Đã xây dựng lại chỉ mục tìm kiếm thành công';

  @override
  String get rebuildSearchIndexFailed =>
      'Không thể xây dựng lại chỉ mục tìm kiếm';

  @override
  String get clearData => 'Xóa dữ liệu';

  @override
  String get confirmClearDataMessage => 'Xóa dữ liệu?';

  @override
  String get confirmClearDataDeletesWorkspaceMessage =>
      'Tất cả dữ liệu workspace cục bộ của người dùng hiện tại sẽ bị xóa, bao gồm thẻ, phương tiện, tệp kiến thức, insight, bộ nhớ, lịch sử trò chuyện và trạng thái hệ thống.\n\nHành động này không thể hoàn tác!';

  @override
  String get clearFailedAgentContexts => 'Xóa ngữ cảnh hội thoại lỗi';

  @override
  String get confirmClearFailedAgentContextsMessage =>
      'Xóa ngữ cảnh hội thoại đã lưu cho agent Insight và Schedule? Hữu ích sau khi đổi mô hình khi tin nhắn agent trước đó không còn tương thích. Sự kiện, thẻ, kiến thức, bộ nhớ và cài đặt mô hình sẽ không bị xóa.';

  @override
  String failedAgentContextsCleared(Object count) {
    return 'Đã xóa $count ngữ cảnh hội thoại đã lưu';
  }

  @override
  String clearFailedAgentContextsFailed(Object error) {
    return 'Không thể xóa ngữ cảnh hội thoại: $error';
  }

  @override
  String get cloneToTestUser => 'Sao chép sang người dùng thử nghiệm';

  @override
  String get confirmCloneToTestUserMessage =>
      'Sao chép workspace hiện tại sang người dùng thử nghiệm cục bộ mới và chuyển sang đó. Trạng thái runtime của agent không được sao chép. Dữ liệu người dùng hiện tại sẽ không bị thay đổi.';

  @override
  String get testUserIdLabel => 'ID người dùng thử nghiệm';

  @override
  String get testUserIdHelper => 'Dùng chữ cái, số, gạch ngang hoặc gạch dưới.';

  @override
  String get testUserIdInvalid =>
      'Chỉ dùng chữ cái, số, gạch ngang hoặc gạch dưới.';

  @override
  String get overwriteExistingTestUser =>
      'Thay thế người dùng thử nghiệm hiện có cùng ID';

  @override
  String testUserCloneSuccess(Object userId) {
    return 'Đã chuyển sang người dùng thử nghiệm $userId';
  }

  @override
  String testUserCloneFailed(Object error) {
    return 'Không thể sao chép người dùng thử nghiệm: $error';
  }

  @override
  String get dataClearedSuccess => 'Đã xóa dữ liệu thành công';

  @override
  String clearDataFailed(Object error) {
    return 'Không thể xóa dữ liệu: $error';
  }

  @override
  String get personalCenter => 'Trung tâm cá nhân';

  @override
  String get viewLogs => 'Xem nhật ký';

  @override
  String get systemAuthorization => 'Ủy quyền hệ thống';

  @override
  String get aiCharacterConfig => 'Cấu hình nhân vật AI';

  @override
  String get modelConfig => 'Cấu hình mô hình';

  @override
  String get agentConfig => 'Cấu hình agent';

  @override
  String get experimentalLab => 'Phòng thí nghiệm';

  @override
  String get experimentalLabDescription =>
      'Tính năng thử nghiệm có thể thay đổi hoặc di chuyển sau này.';

  @override
  String get modelUsageStats => 'Thống kê sử dụng mô hình';

  @override
  String get asyncTaskList => 'Danh sách tác vụ bất đồng bộ';

  @override
  String get clearLocalToken => 'Xóa người dùng';

  @override
  String get insightCardTemplates => 'Mẫu thẻ insight';

  @override
  String get timelineCardTemplates => 'Mẫu thẻ dòng thời gian';

  @override
  String get logViewer => 'Trình xem nhật ký';

  @override
  String get autoRefresh => 'Tự động làm mới';

  @override
  String get lineCount => 'Số dòng: ';

  @override
  String get all => 'Tất cả';

  @override
  String get schedule => 'Lịch trình';

  @override
  String get appLockConfig => 'Cấu hình khóa ứng dụng';

  @override
  String loadStatsFailed(Object error) {
    return 'Không thể tải thống kê: $error';
  }

  @override
  String get overview => 'Tổng quan';

  @override
  String get daily => 'Hàng ngày';

  @override
  String get modelStatsByAgent => 'Theo agent';

  @override
  String get detail => 'Chi tiết';

  @override
  String get date => 'Ngày';

  @override
  String get agent => 'Agent';

  @override
  String get noData => 'Không có dữ liệu';

  @override
  String get totalCalls => 'Tổng số lần gọi';

  @override
  String get calls => 'Cuộc gọi';

  @override
  String callsCount(Object count) {
    return '$count cuộc gọi';
  }

  @override
  String get selectDateRange => 'Chọn khoảng ngày';

  @override
  String get totalTokens => 'Tổng token';

  @override
  String get cacheRate => 'Tỷ lệ cache';

  @override
  String get promptTokens => 'Token prompt';

  @override
  String get completionTokens => 'Token hoàn thành';

  @override
  String get cachedTokens => 'Token đã cache';

  @override
  String get thoughtTokens => 'Token suy nghĩ';

  @override
  String get prompt => 'Prompt';

  @override
  String get completion => 'Hoàn thành';

  @override
  String get cached => 'Đã cache';

  @override
  String get thought => 'Suy nghĩ';

  @override
  String get model => 'Mô hình';

  @override
  String get scene => 'Cảnh';

  @override
  String get sceneId => 'ID cảnh';

  @override
  String get tokenUsage => 'Sử dụng token';

  @override
  String get handler => 'Trình xử lý';

  @override
  String get modelBreakdown => 'Phân tích theo mô hình';

  @override
  String get callDetails => 'Chi tiết cuộc gọi';

  @override
  String recordDetailsTitle(Object scene) {
    return 'Chi tiết bản ghi: $scene';
  }

  @override
  String saveLlmConfigFailed(Object error) {
    return 'Không thể lưu cấu hình LLM: $error';
  }

  @override
  String get webHtmlPreviewUnavailable =>
      'Xem trước HTML không khả dụng trên web. Vui lòng xem trên thiết bị di động.';

  @override
  String saveUserInfoFailed(Object error) {
    return 'Không thể lưu thông tin người dùng: $error';
  }

  @override
  String get totalEstimatedCost => 'Tổng chi phí ước tính';

  @override
  String get close => 'Đóng';

  @override
  String get totalTokenConsumption => 'Tổng tiêu thụ token';

  @override
  String get dataLoadFailedRetry =>
      'Tải dữ liệu thất bại, vui lòng thử lại sau.';

  @override
  String get timelineLoadFailedRetry =>
      'Tải dòng thời gian thất bại, vui lòng thử lại sau.';

  @override
  String get newPerspective => 'Góc nhìn mới';

  @override
  String get startPoint => 'Bắt đầu';

  @override
  String get endPoint => 'Kết thúc';

  @override
  String get originalInput => 'Đầu vào gốc';

  @override
  String get referenceContent => 'Nội dung tham chiếu';

  @override
  String referenceWithTitle(Object title) {
    return 'Tham chiếu: $title';
  }

  @override
  String get actionCenterTitle => 'Hành động đang chờ';

  @override
  String get noPendingActions => 'Không có hành động đang chờ';

  @override
  String get clarificationNeeded => 'Memex muốn xác nhận';

  @override
  String get clarificationTextHint => 'Nhập câu trả lời ngắn';

  @override
  String get clarificationTextRequired => 'Hãy thêm câu trả lời ngắn trước';

  @override
  String get clarificationAnswered => 'Đã trả lời';

  @override
  String clarificationAnswerPrefix(Object answer) {
    return 'Trả lời: $answer';
  }

  @override
  String get answerSaved => 'Đã lưu câu trả lời';

  @override
  String get clarificationOtherAnswer => 'Nhập thủ công';

  @override
  String get clarificationNotSure => 'Không chắc / không muốn nói';

  @override
  String get yes => 'Có';

  @override
  String get no => 'Không';

  @override
  String get footprintMap => 'Bản đồ dấu chân';

  @override
  String get waypointPlaces => 'Địa điểm dừng chân';

  @override
  String get unknownPlace => 'Địa điểm không xác định';

  @override
  String get releaseToSend => 'Thả để gửi';

  @override
  String get selectFromAlbum => 'Chọn từ album';

  @override
  String get clipboardPreviewTitle => 'Clipboard mới';

  @override
  String get clipboardPreviewImageTitle => 'Ảnh clipboard';

  @override
  String get clipboardPreviewImageDescription => 'Ảnh sẵn sàng để thêm';

  @override
  String get clipboardPreviewUnprocessed => 'Chưa dán';

  @override
  String get clipboardPreviewPasteToInput => 'Dán vào ô nhập';

  @override
  String get clipboardPreviewAddImageToInput => 'Thêm ảnh';

  @override
  String get clipboardPreviewImageFailed => 'Không thể đọc ảnh clipboard';

  @override
  String get tellAiWhatHappened => 'Kể cho AI biết chuyện gì đã xảy ra...';

  @override
  String recordingWithDuration(Object duration) {
    return 'Đang ghi: $duration';
  }

  @override
  String get playing => 'Đang phát...';

  @override
  String get sendLabel => 'Gửi';

  @override
  String attachedImagesMessage(Object count) {
    return 'Đã gửi $count ảnh';
  }

  @override
  String get noTaskData => 'Không có dữ liệu tác vụ';

  @override
  String createdAtDate(Object date) {
    return 'Tạo: $date';
  }

  @override
  String updatedAtDate(Object date) {
    return 'Cập nhật: $date';
  }

  @override
  String durationLabel(Object duration) {
    return 'Thời lượng: $duration';
  }

  @override
  String retryCount(Object count) {
    return 'Thử lại: $count';
  }

  @override
  String get loadDetailFailedRetry =>
      'Tải chi tiết thất bại, vui lòng thử lại sau.';

  @override
  String get loadFailed => 'Tải thất bại';

  @override
  String loadHistoryFailed(Object error) {
    return 'Không thể tải lịch sử: $error';
  }

  @override
  String get reload => 'Tải lại';

  @override
  String get aiInsightDetail => 'Chi tiết insight';

  @override
  String relatedRecordsCount(Object count) {
    return 'Bản ghi liên quan ($count)';
  }

  @override
  String get noRelatedRecords => 'Không có bản ghi liên quan';

  @override
  String get useFingerprintToUnlock => 'Dùng vân tay để mở khóa';

  @override
  String get locked => 'Đã khóa';

  @override
  String get wrongPassword => 'Mật khẩu sai';

  @override
  String get enterPassword => 'Nhập mật khẩu';

  @override
  String get memexLocked => 'Memex đã khóa';

  @override
  String get calendarShortSun => 'CN';

  @override
  String get calendarShortMon => 'T2';

  @override
  String get calendarShortTue => 'T3';

  @override
  String get calendarShortWed => 'T4';

  @override
  String get calendarShortThu => 'T5';

  @override
  String get calendarShortFri => 'T6';

  @override
  String get calendarShortSat => 'T7';

  @override
  String noRecordsOnDate(Object date) {
    return 'Không có bản ghi vào $date';
  }

  @override
  String get footprintPath => 'Lộ trình dấu chân';

  @override
  String get lifeCompositionTable => 'Thành phần cuộc sống';

  @override
  String get emotionReframe => 'Tái khung cảm xúc';

  @override
  String get chronicleOfThings => 'Biên niên sự kiện';

  @override
  String get goalProgress => 'Tiến độ mục tiêu';

  @override
  String get trendChart => 'Biểu đồ xu hướng';

  @override
  String get comparisonChart => 'Biểu đồ so sánh';

  @override
  String get todayTimeFlow => 'Dòng thời gian hôm nay';

  @override
  String get aiInputHint => 'Dù là ký ức hay hiện tại, tôi luôn ở đây...';

  @override
  String get refreshSuperAgentStateTooltip => 'Xóa ngữ cảnh Memex Agent';

  @override
  String get refreshSuperAgentStateTitle => 'Xóa ngữ cảnh lịch sử Memex Agent?';

  @override
  String get refreshSuperAgentStateMessage =>
      'Lịch sử trò chuyện hiển thị sẽ giữ nguyên, nhưng ngữ cảnh runtime lịch sử của Memex Agent sẽ bị xóa và các phản hồi sau sẽ bắt đầu từ ngữ cảnh mới. Bộ nhớ lâu dài, tệp cơ sở kiến thức, thẻ và dữ liệu đã lưu khác không bị ảnh hưởng. Dùng khi Memex Agent hoạt động bất thường. Tiếp tục?';

  @override
  String get refreshSuperAgentStateActiveRunMessage =>
      'Đợi tin nhắn Memex Agent hiện tại hoàn tất trước khi xóa ngữ cảnh.';

  @override
  String get refreshSuperAgentStateSuccess => 'Đã xóa ngữ cảnh Memex Agent';

  @override
  String refreshSuperAgentStateFailed(Object error) {
    return 'Không thể xóa ngữ cảnh Memex Agent: $error';
  }

  @override
  String get nothingHere => 'Chưa có gì ở đây';

  @override
  String get nothingHereHint => 'Nhấn nút bên dưới để tạo thẻ đầu tiên';

  @override
  String get agentProcessing => 'AI đang xử lý...';

  @override
  String get keepAppOpen => 'Đừng đóng ứng dụng';

  @override
  String get activityDetail => 'Chi tiết hoạt động';

  @override
  String get noAgentActivityYet => 'Chưa có hoạt động agent';

  @override
  String get processingEllipsis => 'Đang xử lý...';

  @override
  String get agentBackgroundTitle => 'Memex Agent';

  @override
  String get agentBackgroundPausedTitle => 'Memex Agent đã tạm dừng';

  @override
  String get agentBackgroundNeedsAttentionTitle => 'Memex Agent cần chú ý';

  @override
  String get agentBackgroundStageIdle => 'Nhàn rỗi';

  @override
  String get agentBackgroundStageProcessing => 'Đang xử lý';

  @override
  String get agentBackgroundStageQueued => 'Đang chờ';

  @override
  String get agentBackgroundStageRetrying => 'Đang chờ thử lại';

  @override
  String get agentBackgroundStagePaused => 'Đã tạm dừng';

  @override
  String get agentBackgroundStageCompleted => 'Hoàn tất';

  @override
  String get agentBackgroundStageNeedsAttention => 'Cần chú ý';

  @override
  String get agentBackgroundStageAnalyzingMedia => 'Đang phân tích phương tiện';

  @override
  String get agentBackgroundStageGeneratingCard => 'Đang tạo thẻ';

  @override
  String get agentBackgroundStageUpdatingKnowledge => 'Đang cập nhật kiến thức';

  @override
  String get agentBackgroundStagePreparingComment => 'Đang chuẩn bị bình luận';

  @override
  String get agentBackgroundStageRoutingFollowUps => 'Đang định tuyến theo dõi';

  @override
  String agentBackgroundTaskSummary(
    Object running,
    Object pending,
    Object retrying,
  ) {
    return 'Đang chạy $running, Chờ $pending, Thử lại $retrying';
  }

  @override
  String agentBackgroundTaskDetail(Object count) {
    return 'Đang xử lý $count tác vụ trong hàng đợi.';
  }

  @override
  String get agentBackgroundNoTasks => 'Không có tác vụ nền.';

  @override
  String get agentBackgroundStarting => 'Đang bắt đầu xử lý.';

  @override
  String get agentBackgroundCompletedDetail => 'Tất cả tác vụ nền đã hoàn tất.';

  @override
  String get agentBackgroundFailedDetail => 'Xử lý dừng do lỗi.';

  @override
  String get agentBackgroundPausedDetail =>
      'Xử lý đã tạm dừng và sẽ tiếp tục sau.';

  @override
  String get agentBackgroundQueuedDetail => 'Đang chờ bước xử lý tiếp theo.';

  @override
  String get agentBackgroundRetryingDetail =>
      'Bước hiện tại sẽ tự động thử lại.';

  @override
  String get agentBackgroundAnalyzeMediaDetail =>
      'Đang đọc tệp đính kèm và ngữ cảnh cục bộ.';

  @override
  String get agentBackgroundGeneratingCardDetail =>
      'Đang biến bản ghi thành thẻ dòng thời gian.';

  @override
  String get agentBackgroundUpdatingKnowledgeDetail =>
      'Đang cập nhật kiến thức và bộ nhớ cục bộ.';

  @override
  String get agentBackgroundPreparingCommentDetail =>
      'Đang chuẩn bị phản hồi trợ lý.';

  @override
  String get agentBackgroundRoutingFollowUpsDetail =>
      'Đang kiểm tra hành động theo dõi cho thẻ này.';

  @override
  String agentBackgroundPausedStatus(Object summary) {
    return 'Tạm dừng - $summary';
  }

  @override
  String agentBackgroundNeedsAttentionStatus(Object summary) {
    return 'Cần chú ý - $summary';
  }

  @override
  String get settings => 'Cài đặt';

  @override
  String get languageSettings => 'Ngôn ngữ';

  @override
  String get languageSettingsDesc => 'Thay đổi ngôn ngữ hiển thị ứng dụng';

  @override
  String get noPendingActionsToast => 'Không có hành động đang chờ';

  @override
  String get knowledgeNewDiscovery => 'Phát hiện kiến thức mới';

  @override
  String discoveredNewInsightsCount(Object count) {
    return 'Đã phát hiện $count insight mới';
  }

  @override
  String updatedExistingInsightsCount(Object count) {
    return 'Đã cập nhật $count insight hiện có';
  }

  @override
  String get sectionNewInsights => 'Insight mới';

  @override
  String get sectionUpdatedInsights => 'Insight đã cập nhật';

  @override
  String get unnamedInsight => 'Insight chưa đặt tên';

  @override
  String get copiedToClipboard => 'Đã sao chép vào clipboard';

  @override
  String get copy => 'Sao chép';

  @override
  String get selectedLocation => 'Vị trí đã chọn';

  @override
  String get confirmLocationName => 'Xác nhận tên vị trí';

  @override
  String get confirmLocationNameHint =>
      'Bạn có thể chỉnh tên (tọa độ giữ nguyên)';

  @override
  String get nameLabel => 'Tên';

  @override
  String get inputPlaceNameHint => 'Nhập tên địa điểm...';

  @override
  String currentCoordinates(Object lat, Object lng) {
    return 'Tọa độ: $lat, $lng';
  }

  @override
  String get confirmLocation => 'Xác nhận vị trí';

  @override
  String get welcomeToMemex => 'Chào mừng đến Memex';

  @override
  String get createUserIdToStart => 'Tạo hồ sơ của bạn';

  @override
  String get userIdLabel => 'Tên / Biệt danh của bạn';

  @override
  String get userIdHint => 'Nhập tên hoặc biệt danh';

  @override
  String get pleaseEnterUserId => 'Vui lòng nhập tên';

  @override
  String get userIdMaxLength => 'Tên không được vượt quá 50 ký tự';

  @override
  String get startUsing => 'Tiếp tục';

  @override
  String get userIdTip => 'Sẽ được dùng để cá nhân hóa trải nghiệm của bạn.';

  @override
  String get setupModelConfigTitle => 'Thiết lập mô hình AI';

  @override
  String get setupModelConfigSubtitle =>
      'Memex cần mô hình AI tiên tiến để sắp xếp bản ghi, phân tích ảnh và tạo insight. Chọn một phương thức kết nối.';

  @override
  String get setupModelConfigComplete => 'Hoàn tất & Bắt đầu';

  @override
  String get aiService => 'Dịch vụ mô hình Memex';

  @override
  String get aiModelHubTitle => 'Mô hình AI và dịch vụ';

  @override
  String get aiModelHubSubtitle =>
      'Chọn dịch vụ chính thức của Memex hoặc mang nhà cung cấp của bạn. Định tuyến mô hình nâng cao vẫn khả dụng khi cần.';

  @override
  String get aiSetupCurrentStatusTitle => 'Thiết lập hiện tại';

  @override
  String get aiSetupStatusNotConfiguredTitle => 'Dịch vụ AI chưa được cấu hình';

  @override
  String get aiSetupStatusNotConfiguredDescription =>
      'Chọn một phương thức kết nối để bật tổ chức AI cho bản ghi, phương tiện và insight.';

  @override
  String get aiSetupStatusMemexTitle => 'Đang dùng dịch vụ chính thức MemeX';

  @override
  String get aiSetupStatusMemexDescription =>
      'Memex sẽ dùng kết nối chính thức và thông tin API Key do tài khoản MemeX quản lý.';

  @override
  String get aiSetupStatusCustomTitle =>
      'Đang dùng cài đặt nhà cung cấp tùy chỉnh';

  @override
  String get aiSetupStatusCustomDescription =>
      'Memex sẽ dùng thông tin nhà cung cấp và lựa chọn vai trò mô hình đã cấu hình.';

  @override
  String get aiSetupChooseConnectionTitle => 'Chọn phương thức kết nối';

  @override
  String get aiSetupChooseConnectionDescription =>
      'Bắt đầu với đường dẫn phù hợp cách bạn muốn Memex truy cập mô hình AI.';

  @override
  String get aiSetupOfficialRouteDescription =>
      'Đăng nhập MemeX và dùng dịch vụ chính thức mà không cần chọn nhà cung cấp, API Key hoặc mô hình theo agent.';

  @override
  String get aiSetupCustomRouteDescription =>
      'Thêm thông tin nhà cung cấp, chọn mô hình Super Agent nên dùng và tùy chọn ghi đè mô hình theo agent.';

  @override
  String get aiSetupCustomPageTitle => 'Dịch vụ AI tùy chỉnh';

  @override
  String get aiSetupCustomPageSubtitle =>
      'Cấu hình thông tin nhà cung cấp trước, sau đó chọn mô hình Memex nên dùng.';

  @override
  String get aiSetupProviderCredentialsTitle => 'Nhà cung cấp và API Key';

  @override
  String get aiSetupProviderCredentialsDescription =>
      'Thêm hoặc chỉnh OpenAI, Anthropic, DeepSeek, Gemini, OpenRouter, Ollama hoặc nhà cung cấp tương thích khác.';

  @override
  String get modelRolesTitle => 'Chọn mô hình chính';

  @override
  String get modelRolesDescription =>
      'Super Agent dùng một mô hình cho đầu vào văn bản và hình ảnh. Ghi đè agent nâng cao vẫn khả dụng bên dưới.';

  @override
  String get textModelRoleTitle => 'Mô hình chính';

  @override
  String get textModelRoleDescription =>
      'Super Agent dùng cho văn bản, hình ảnh, thẻ, kiến thức, insight, trò chuyện, bình luận và bộ nhớ.';

  @override
  String get modelConnectionsTitle => 'Nhà cung cấp mô hình và API Key';

  @override
  String get modelConnectionsDescription =>
      'Kết nối dịch vụ chính thức Memex hoặc thêm thông tin nhà cung cấp của bạn.';

  @override
  String get relatedAiCapabilitiesTitle => 'Khả năng nâng cao và liên quan';

  @override
  String get relatedAiCapabilitiesDescription =>
      'Tinh chỉnh phân công agent, nhà cung cấp vị trí và hành vi chuyển giọng nói thành văn bản.';

  @override
  String get aiSetupServiceCapabilitiesTitle => 'Khả năng dịch vụ';

  @override
  String get aiSetupServiceCapabilitiesDescription =>
      'Chọn nhà cung cấp Memex dùng cho khả năng AI liền kề như giọng nói và mã hóa ngược địa lý.';

  @override
  String get aiSetupAdvancedCustomizationTitle => 'Định tuyến mô hình nâng cao';

  @override
  String get aiSetupAdvancedCustomizationDescription =>
      'Dành cho người dùng nâng cao muốn từng agent dùng nhà cung cấp hoặc cấu hình mô hình khác nhau.';

  @override
  String get locationProviderSettings => 'Nhà cung cấp vị trí';

  @override
  String get speechProviderSettings => 'Chuyển giọng nói thành văn bản';

  @override
  String get advancedAgentModelAssignments => 'Phân công mô hình agent';

  @override
  String get openAdvancedAgentModelAssignments => 'Ghi đè từng agent';

  @override
  String get noConfiguredModelOptions =>
      'Thêm nhà cung cấp hoặc API Key trước khi chọn vai trò mô hình.';

  @override
  String get modelSlotUpdated => 'Đã cập nhật vai trò mô hình';

  @override
  String get aiServiceMemexRouteTitle => 'Kết nối qua Memex';

  @override
  String get aiServiceLongDescription =>
      'Memex dùng hệ thống đa agent để sắp xếp bản ghi cuộc sống, ghi chú kiến thức và ngữ cảnh xã hội, khám phá insight sâu hơn và cung cấp đồng hành AI với bộ nhớ lâu dài. Dữ liệu được lưu dạng Markdown văn bản thuần, bảo toàn tự do và khả năng di chuyển dữ liệu.';

  @override
  String get aiServiceCustomApiRouteTitle => 'Tôi có API Key';

  @override
  String get aiServiceCustomModelDescription =>
      'Chọn mục này trước nếu bạn đã có API Key từ OpenAI, Anthropic, DeepSeek, Gemini hoặc nhà cung cấp khác.';

  @override
  String get enableAiService => 'Kết nối với Memex';

  @override
  String get aiServiceReadyToast => 'Tổ chức AI đã bật';

  @override
  String get aiServiceSettingsDescription =>
      'Nếu bạn chưa có API Key, dùng tài khoản Memex để kết nối dịch vụ mô hình phổ biến.';

  @override
  String get advancedModelConfiguration => 'Cấu hình API Key';

  @override
  String get skipForNow => 'Bỏ qua tạm thời';

  @override
  String get clearAuth => 'Xóa ủy quyền';

  @override
  String get authorizing => 'Đang ủy quyền...';

  @override
  String authFailed(Object error) {
    return 'Ủy quyền thất bại: $error';
  }

  @override
  String get authorized => 'Đã ủy quyền';

  @override
  String authorizedAs(Object email) {
    return 'Đã ủy quyền dưới tên $email';
  }

  @override
  String get authorizedSuccessfully => 'Ủy quyền thành công';

  @override
  String get reAuthorize => 'Ủy quyền lại';

  @override
  String get authorizeWithOpenAi => 'Ủy quyền với OpenAI';

  @override
  String get authorizeWithGoogle => 'Ủy quyền với Google';

  @override
  String get config => 'Cấu hình';

  @override
  String get calendar => 'Lịch';

  @override
  String get reminders => 'Nhắc nhở';

  @override
  String get writeToSystemFailed => 'Không thể ghi vào hệ thống';

  @override
  String permissionRequired(Object name) {
    return 'Cần quyền $name';
  }

  @override
  String permissionRationale(Object name) {
    return 'Vui lòng cho phép ứng dụng truy cập $name trong Cài đặt để chúng tôi có thể tạo cho bạn.';
  }

  @override
  String get goToSettings => 'Đi tới Cài đặt';

  @override
  String get unknownAction => 'Hành động không xác định';

  @override
  String get discoveredCalendarEvent => 'Sự kiện lịch đang chờ xác nhận';

  @override
  String get discoveredReminder => 'Nhắc nhở đang chờ xác nhận';

  @override
  String get addToCalendar => 'Thêm vào lịch';

  @override
  String get addToReminders => 'Thêm vào nhắc nhở';

  @override
  String get systemActionPendingExplanation =>
      'Chưa thêm. Nhấn bên dưới để yêu cầu quyền và thêm vào thiết bị.';

  @override
  String addedToSuccess(Object target) {
    return 'Đã thêm thành công vào $target';
  }

  @override
  String get ignore => 'Bỏ qua';

  @override
  String get confirmDelete => 'Xác nhận xóa';

  @override
  String get confirmDeleteSessionMessage =>
      'Xóa cuộc trò chuyện này? Không thể hoàn tác.';

  @override
  String get delete => 'Xóa';

  @override
  String get deleteSuccess => 'Đã xóa thành công';

  @override
  String deleteFailed(Object error) {
    return 'Xóa thất bại: $error';
  }

  @override
  String daysAgo(Object count) {
    return '$count ngày trước';
  }

  @override
  String get chatHistory => 'Lịch sử trò chuyện';

  @override
  String get enterFullScreenTooltip => 'Vào toàn màn hình';

  @override
  String get exitFullScreenTooltip => 'Thoát toàn màn hình';

  @override
  String get noConversations => 'Không có cuộc trò chuyện';

  @override
  String loadSessionListFailed(Object error) {
    return 'Không thể tải danh sách phiên: $error';
  }

  @override
  String yesterdayAt(Object time) {
    return 'Hôm qua $time';
  }

  @override
  String get newChat => 'Trò chuyện mới';

  @override
  String messageCount(Object count) {
    return '$count tin nhắn';
  }

  @override
  String get organize => 'Sắp xếp';

  @override
  String get pkmCategoryProject => 'Dự án';

  @override
  String get pkmCategoryProjectSubtitle => 'Ngắn hạn · Mục tiêu · Hạn chót';

  @override
  String get pkmCategoryArea => 'Lĩnh vực';

  @override
  String get pkmCategoryAreaSubtitle => 'Dài hạn · Trách nhiệm · Tiêu chuẩn';

  @override
  String get pkmCategoryResource => 'Tài nguyên';

  @override
  String get pkmCategoryResourceSubtitle => 'Sở thích · Cảm hứng · Dự trữ';

  @override
  String get pkmCategoryArchive => 'Lưu trữ';

  @override
  String get pkmCategoryArchiveSubtitle => 'Hoàn tất · Ngủ · Tham khảo';

  @override
  String get recentChanges => 'Thay đổi gần đây';

  @override
  String get noRecentChangesInThreeDays => 'Không có thay đổi trong 3 ngày qua';

  @override
  String get unpinned => 'Đã bỏ ghim';

  @override
  String get pinnedStyle => 'Đã ghim phong cách';

  @override
  String operationFailed(Object error) {
    return 'Thao tác thất bại: $error';
  }

  @override
  String get refreshingInsightData =>
      'Đang làm mới dữ liệu insight, có thể mất một lúc...';

  @override
  String refreshFailed(Object error) {
    return 'Làm mới thất bại: $error';
  }

  @override
  String get sortUpdated => 'Đã cập nhật thứ tự sắp xếp';

  @override
  String sortSaveFailed(Object error) {
    return 'Không thể lưu thứ tự sắp xếp: $error';
  }

  @override
  String get insightCardDeleted => 'Đã xóa thẻ insight';

  @override
  String deleteFailedShort(Object error) {
    return 'Xóa thất bại: $error';
  }

  @override
  String get knowledgeInsight => 'Insight kiến thức';

  @override
  String get completeSort => 'Hoàn tất sắp xếp';

  @override
  String get noKnowledgeInsight => 'Không có insight kiến thức';

  @override
  String insightProcessingBacklogMessage(Object count) {
    return '$count tác vụ nền vẫn đang xử lý.';
  }

  @override
  String get insightUnavailableMessage =>
      'Insight này vẫn đang được tạo hoặc đã được cập nhật. Làm mới insight và thử lại sau.';

  @override
  String get artifactOpen => 'Mở';

  @override
  String get updating => 'Đang cập nhật...';

  @override
  String get update => 'Cập nhật';

  @override
  String get enabled => 'Đã bật';

  @override
  String get disabled => 'Đã tắt';

  @override
  String get appLockOn => 'Đã bật khóa ứng dụng';

  @override
  String get appLockOff => 'Đã tắt khóa ứng dụng';

  @override
  String get enableAppLockFirst => 'Vui lòng bật khóa ứng dụng trước';

  @override
  String get enterFourDigitPassword => 'Nhập mật khẩu 4 chữ số';

  @override
  String get passwordSetAndLockOn => 'Đã đặt mật khẩu và bật khóa ứng dụng';

  @override
  String get appLockSettings => 'Cài đặt khóa ứng dụng';

  @override
  String get enableAppLock => 'Bật khóa ứng dụng';

  @override
  String get enableAppLockSubtitle => 'Yêu cầu mật khẩu khi mở ứng dụng';

  @override
  String get enableBiometrics => 'Bật sinh trắc học';

  @override
  String get biometricsSubtitle => 'Dùng Face ID hoặc Touch ID để mở khóa';

  @override
  String get changePassword => 'Đổi mật khẩu';

  @override
  String get setFourDigitPassword => 'Đặt mật khẩu 4 chữ số';

  @override
  String get reenterPasswordToConfirm => 'Nhập lại mật khẩu để xác nhận';

  @override
  String get passwordMismatch => 'Mật khẩu không khớp. Vui lòng thử lại.';

  @override
  String confirmDeleteCharacter(Object name) {
    return 'Xóa nhân vật \"$name\"? Không thể hoàn tác.';
  }

  @override
  String get configureAiCharacter => 'Cấu hình nhân vật AI';

  @override
  String get addCharacter => 'Thêm nhân vật';

  @override
  String get addCharacterSubtitle =>
      'Chọn nhân vật AI tham gia đội insight của bạn. Họ sẽ phân tích dữ liệu cuộc sống từ nhiều góc độ.';

  @override
  String get noCharacters => 'Không có nhân vật';

  @override
  String loadCharacterFailed(Object error) {
    return 'Không thể tải nhân vật: $error';
  }

  @override
  String get noTags => 'Không có thẻ';

  @override
  String get createSuccess => 'Tạo thành công';

  @override
  String get updateSuccess => 'Cập nhật thành công';

  @override
  String saveFailed(Object error) {
    return 'Lưu thất bại: $error';
  }

  @override
  String get newCharacter => 'Nhân vật mới';

  @override
  String get editCharacter => 'Chỉnh sửa nhân vật';

  @override
  String get save => 'Lưu';

  @override
  String get characterName => 'Tên nhân vật';

  @override
  String get characterNameHint => 'Đặt tên cho nhân vật';

  @override
  String get pleaseEnterCharacterName => 'Vui lòng nhập tên nhân vật';

  @override
  String get tagsLabel => 'Thẻ';

  @override
  String get tagsHint =>
      'vd. trí tuệ, nhận thức, vĩ mô\nPhân tách nhiều thẻ bằng dấu phẩy';

  @override
  String get characterPersonaLabel => 'Nhân cách nhân vật';

  @override
  String get characterPersonaHint =>
      'Bao gồm nhân cách, hướng dẫn phong cách, hội thoại mẫu, bộ lọc kiến thức, v.v.\nDùng ## cho tiêu đề mục.';

  @override
  String get pleaseEnterCharacterPersona => 'Vui lòng nhập nhân cách nhân vật';

  @override
  String permissionRequestError(Object error) {
    return 'Lỗi yêu cầu quyền: $error';
  }

  @override
  String get permissionRequiredTitle => 'Cần quyền';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'Bạn đã từ chối vĩnh viễn quyền này hoặc hệ thống yêu cầu. Vui lòng bật trong cài đặt hệ thống.';

  @override
  String get getting => 'Đang lấy...';

  @override
  String get unauthorized => 'Chưa ủy quyền';

  @override
  String get authorizedGoToSettings =>
      'Đã ủy quyền. Vào cài đặt hệ thống để thay đổi.';

  @override
  String get location => 'Vị trí';

  @override
  String get locationPermissionReason =>
      'Để ghi lại địa điểm và tính năng liên quan vị trí';

  @override
  String get photos => 'Ảnh';

  @override
  String get photosPermissionReason => 'Để chọn ảnh, lưu ảnh đã tạo, v.v.';

  @override
  String get camera => 'Camera';

  @override
  String get cameraPermissionReason => 'Để chụp ảnh và quay video';

  @override
  String get microphone => 'Micro';

  @override
  String get microphonePermissionReason =>
      'Để nhận dạng giọng nói, ghi âm, v.v.';

  @override
  String get calendarPermissionReason =>
      'Để ghi lịch trình và đọc sự kiện lịch';

  @override
  String get remindersPermissionReason => 'Để ghi và đọc nhắc nhở';

  @override
  String get fitnessAndMotion => 'Sức khỏe & vận động';

  @override
  String get fitnessPermissionReason => 'Để ghi dữ liệu sức khỏe và vận động';

  @override
  String get notification => 'Thông báo';

  @override
  String get notificationPermissionReason =>
      'Để gửi lịch trình và nhắc nhở quan trọng';

  @override
  String get memexAgentNotificationPermissionTitle =>
      'Giữ Memex Agent chạy nền';

  @override
  String get memexAgentNotificationPermissionMessage =>
      'Memex Agent chạy cục bộ trên thiết bị. Thông báo giúp Memex hiển thị tiến độ và tiếp tục xử lý sau khi bạn rời ứng dụng hoặc tắt màn hình. Nếu tắt thông báo, hãy giữ Memex mở ở nền trước cho đến khi tác vụ hoàn tất.';

  @override
  String get loadDetailFailedRetryShort =>
      'Tải chi tiết thất bại, vui lòng thử lại sau.';

  @override
  String get total => 'Tổng';

  @override
  String get estimatedCost => 'Chi phí ước tính';

  @override
  String get byAgent => 'Theo agent';

  @override
  String get timeUpdated => 'Thời gian cập nhật';

  @override
  String updateFailed(Object error) {
    return 'Cập nhật thất bại: $error';
  }

  @override
  String get locationUpdated => 'Đã cập nhật vị trí';

  @override
  String get confirmDeleteCardMessage => 'Xóa thẻ này? Không thể hoàn tác.';

  @override
  String get cardDetailNotFound => 'Không tìm thấy chi tiết thẻ';

  @override
  String get saySomething => 'Nói gì đó...';

  @override
  String get relatedMemories => 'Bộ nhớ liên quan';

  @override
  String get viewMore => 'Xem thêm';

  @override
  String get relatedRecords => 'Bản ghi liên quan';

  @override
  String get reply => 'Trả lời';

  @override
  String get replySent => 'Đã gửi trả lời';

  @override
  String get insightTemplateGalleryTitle => 'Mẫu thẻ insight';

  @override
  String get timelineTemplateGalleryTitle => 'Mẫu thẻ dòng thời gian';

  @override
  String get categoryTextual => 'Văn bản';

  @override
  String get timelineFilterAll => 'TẤT CẢ';

  @override
  String get insights => 'Insight';

  @override
  String get memoryTitle => 'Bộ nhớ';

  @override
  String get longTermProfile => 'Hồ sơ dài hạn';

  @override
  String get recentBuffer => 'Bộ đệm gần đây';

  @override
  String errorLoadingMemory(Object error) {
    return 'Lỗi tải bộ nhớ: $error';
  }

  @override
  String get agentConfiguration => 'Cấu hình agent';

  @override
  String get resetToDefaults => 'Đặt lại mặc định';

  @override
  String get resetAllAgentConfigurationsTitle =>
      'Đặt lại tất cả cấu hình agent';

  @override
  String get resetAllAgentConfigurationsMessage =>
      'Bạn có chắc muốn đặt lại tất cả cấu hình agent về giá trị mặc định? Không thể hoàn tác.';

  @override
  String get resetButton => 'Đặt lại';

  @override
  String loadDataFailed(Object error) {
    return 'Không thể tải dữ liệu: $error';
  }

  @override
  String saveConfigFailed(Object error) {
    return 'Không thể lưu cấu hình: $error';
  }

  @override
  String get selectLlmClient => 'Chọn LLM Client:';

  @override
  String get agentConfigurationsReset => 'Đã đặt lại cấu hình agent';

  @override
  String resetFailed(Object error) {
    return 'Không thể đặt lại: $error';
  }

  @override
  String get modelConfiguration => 'Cấu hình mô hình';

  @override
  String get resetAllConfigurationsTitle => 'Đặt lại tất cả cấu hình';

  @override
  String get resetAllModelConfigurationsMessage =>
      'Bạn có chắc muốn đặt lại tất cả cấu hình mô hình về giá trị mặc định? Không thể hoàn tác.';

  @override
  String get modelConfigurationsReset => 'Đã đặt lại cấu hình mô hình';

  @override
  String get cannotDeleteDefaultConfiguration =>
      'Không thể xóa cấu hình mặc định';

  @override
  String get cannotDeleteConfigurationTitle => 'Không thể xóa cấu hình';

  @override
  String configUsedByAgentsMessage(Object agentList) {
    return 'Cấu hình này hiện được các agent sau sử dụng:\n\n$agentList\n\nVui lòng gán lại các agent này trước khi xóa.';
  }

  @override
  String get ok => 'OK';

  @override
  String get deleteConfigurationTitle => 'Xóa cấu hình';

  @override
  String confirmDeleteConfigMessage(Object key) {
    return 'Bạn có chắc muốn xóa \"$key\"?';
  }

  @override
  String get defaultLabel => 'Mặc định';

  @override
  String get setAsDefault => 'Đặt làm mặc định';

  @override
  String get invalidJsonInExtraField => 'JSON không hợp lệ trong trường Extra';

  @override
  String get keyAlreadyExists => 'Khóa đã tồn tại';

  @override
  String get resetConfigurationTitle => 'Đặt lại cấu hình';

  @override
  String get resetConfigurationMessage =>
      'Đặt lại cấu hình này về giá trị mặc định ban đầu? Thay đổi hiện tại sẽ mất.';

  @override
  String get configurationResetPressSave =>
      'Đã đặt lại cấu hình. Nhấn Lưu để áp dụng.';

  @override
  String get addConfiguration => 'Thêm cấu hình';

  @override
  String get editConfiguration => 'Chỉnh sửa cấu hình';

  @override
  String get duplicateConfiguration => 'Nhân bản cấu hình';

  @override
  String get duplicate => 'Nhân bản';

  @override
  String get keyIdLabel => 'ID cấu hình';

  @override
  String get keyIdHelper => 'Đặt tên cấu hình này, vd. deepseek hoặc work-gpt.';

  @override
  String get required => 'Bắt buộc';

  @override
  String get clientLabel => 'Nhà cung cấp mô hình';

  @override
  String get providerGroupOpenAi => 'OpenAI';

  @override
  String get providerGroupAnthropic => 'Anthropic';

  @override
  String get providerGroupGoogle => 'Google';

  @override
  String get providerGroupOthers => 'Phổ biến';

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
  String get providerMemex => 'Dịch vụ proxy Memex';

  @override
  String get memexSignIn => 'Đăng nhập';

  @override
  String get memexCreateAccount => 'Tạo tài khoản';

  @override
  String get memexUsername => 'Tên người dùng';

  @override
  String get memexPassword => 'Mật khẩu';

  @override
  String get memexCreateAccountLink => 'Tạo tài khoản';

  @override
  String get memexSignInLink => 'Đăng nhập thay thế';

  @override
  String get memexTopUp => 'Nạp tiền để bắt đầu dùng Memex AI';

  @override
  String get memexTopUpSuccess => 'Nạp tiền thành công!';

  @override
  String get memexFillAllFields => 'Vui lòng điền tất cả các trường';

  @override
  String get memexUsernameTooShort => 'Tên người dùng phải có ít nhất 6 ký tự';

  @override
  String get memexAuthFailed => 'Xác thực thất bại';

  @override
  String get memexPaymentFailed => 'Không thể tạo thanh toán';

  @override
  String get memexLogout => 'Đăng xuất';

  @override
  String get memexTopUpButton => 'Nạp tiền';

  @override
  String get memexTopUpChooseAmount => 'Chọn số tiền';

  @override
  String memexTopUpEstimatedRecords(Object range) {
    return 'Khoảng $range bản ghi';
  }

  @override
  String get memexTopUpPlanStarter => 'Khởi đầu';

  @override
  String get memexTopUpPlanEveryday => 'Hàng ngày';

  @override
  String get memexTopUpPlanHighVolume => 'Khối lượng lớn';

  @override
  String get memexTopUpPlanCustom => 'Tín dụng tùy chỉnh';

  @override
  String get memexTopUpPlanStarterSubtitle => 'Phù hợp để thử Memex AI';

  @override
  String get memexTopUpPlanEverydaySubtitle =>
      'Phù hợp để sắp xếp thường xuyên';

  @override
  String get memexTopUpPlanHighVolumeSubtitle => 'Phù hợp cho lô lớn';

  @override
  String get memexTopUpPlanCustomSubtitle => 'Nhập USD 1-10.000';

  @override
  String get memexTopUpCustomEstimate => 'Ước tính dựa trên số tiền đã nhập';

  @override
  String get memexCustomAmount => 'Số tiền tùy chỉnh';

  @override
  String get memexViewHistory => 'Lịch sử sử dụng';

  @override
  String memexBalanceLabel(Object amount) {
    return 'Số dư: $amount';
  }

  @override
  String get memexConfirmPassword => 'Xác nhận mật khẩu';

  @override
  String get memexPasswordMismatch => 'Mật khẩu không khớp';

  @override
  String memexPayAmount(Object amount) {
    return 'Nạp $amount';
  }

  @override
  String get modelIdLabel => 'Mô hình';

  @override
  String get modelIdHelper => 'vd. gemini-3.1-pro-preview, gpt-4o';

  @override
  String get fetchingModels => 'Đang lấy mô hình...';

  @override
  String get fetchModelsButton => 'Lấy mô hình';

  @override
  String get enterApiKeyFirst => 'Nhập API Key trước để lấy mô hình';

  @override
  String get apiKeyLabel => 'API Key';

  @override
  String get baseUrlLabel => 'Điểm cuối API';

  @override
  String get advancedSettings => 'Cài đặt nâng cao';

  @override
  String get testConnectionSuccess => 'Kết nối thành công';

  @override
  String get testConnectionFailed => 'Kết nối thất bại';

  @override
  String get testTypeText => 'Văn bản';

  @override
  String get testTypeVision => 'Hình ảnh';

  @override
  String get testButton => 'Kiểm tra';

  @override
  String get testing => 'Đang kiểm tra...';

  @override
  String get proxyUrlOptional => 'URL proxy (Tùy chọn)';

  @override
  String get proxyUrlHelper => 'vd. http://127.0.0.1:7890';

  @override
  String get temperatureLabel => 'Temperature';

  @override
  String get topPLabel => 'Top P';

  @override
  String get maxTokensLabel => 'Max Tokens';

  @override
  String get extraParamsJson => 'Tham số bổ sung (JSON)';

  @override
  String get invalidJson => 'JSON không hợp lệ';

  @override
  String get warning => 'Thiết lập chưa hoàn tất';

  @override
  String get invalidConfigurationWarning =>
      'Cấu hình chưa hoàn tất (vd. thiếu API Key hoặc Model ID). Bạn vẫn có thể lưu và cấu hình sau. Tiếp tục?';

  @override
  String invalidModelConfigDetailed(Object agentId, Object configKey) {
    return 'AI Agent \"$agentId\" cần cấu hình mô hình hợp lệ (key: \"$configKey\") để hoạt động. Vui lòng kiểm tra cài đặt mô hình.';
  }

  @override
  String get discardChangesTitle => 'Rời trang này?';

  @override
  String get discardChangesMessage =>
      'Nếu bạn đã thay đổi, hãy lưu trước khi rời đi.';

  @override
  String get discardButton => 'Bỏ qua';

  @override
  String get chooseLanguage => 'Chọn ngôn ngữ';

  @override
  String get chooseAvatar => 'Chọn avatar';

  @override
  String get configureNow => 'Cấu hình ngay';

  @override
  String get modelNotConfiguredBanner =>
      'Mô hình AI chưa được cấu hình. Thiết lập để mở khóa tất cả tính năng.';

  @override
  String get modelNotConfiguredSubmitHint =>
      'Vui lòng cấu hình mô hình AI trước khi xuất bản';

  @override
  String get processingStatus => 'Đang xử lý';

  @override
  String get failedStatus => 'Thất bại';

  @override
  String get failureReason => 'Lý do thất bại';

  @override
  String get unknownError => 'Đã xảy ra lỗi không xác định';

  @override
  String get enableFitness => 'Bật Fitness';

  @override
  String get fitnessBannerMessage =>
      'Cho phép truy cập fitness để theo dõi dữ liệu sức khỏe và hoạt động.';

  @override
  String get fitnessDismissTitle => 'Bỏ qua quyền Fitness?';

  @override
  String get fitnessDismissMessage =>
      'Không có quyền fitness, ứng dụng sẽ không thể tự động thu thập dữ liệu sức khỏe cho insight và ghi tự động.';

  @override
  String get skipAnyway => 'Vẫn bỏ qua';

  @override
  String get proModelHint => 'Mô hình này yêu cầu đăng ký ChatGPT Pro/Plus.';

  @override
  String get searchKnowledgeBase => 'Tìm kiếm cơ sở kiến thức...';

  @override
  String get searchKnowledgeHint => 'Nhập từ khóa để tìm tên tệp hoặc nội dung';

  @override
  String noSearchResults(Object query) {
    return 'Không tìm thấy kết quả cho \"$query\"';
  }

  @override
  String get onlyMarkdownPreview => 'Chỉ hỗ trợ xem trước Markdown';

  @override
  String get backupAndRestore => 'Sao lưu & Khôi phục';

  @override
  String get createBackup => 'Tạo bản sao lưu';

  @override
  String get restoreBackup => 'Khôi phục bản sao lưu';

  @override
  String get backupDescription =>
      'Đóng gói tất cả dữ liệu (thẻ, cơ sở kiến thức, insight, cài đặt) vào tệp .memex. Lưu vào iCloud Drive, Google Drive hoặc bất kỳ vị trí nào qua bảng chia sẻ.';

  @override
  String get restoreDescription =>
      'Chọn tệp sao lưu .memex để khôi phục tất cả dữ liệu. Sẽ ghi đè dữ liệu hiện tại.';

  @override
  String get selectBackupFile => 'Chọn tệp sao lưu';

  @override
  String get estimatedSize => 'Kích thước ước tính';

  @override
  String get backupComplete => 'Đã tạo bản sao lưu';

  @override
  String backupFailed(Object error) {
    return 'Sao lưu thất bại: $error';
  }

  @override
  String get confirmRestore => 'Xác nhận khôi phục';

  @override
  String get confirmRestoreMessage =>
      'Khôi phục sẽ ghi đè tất cả dữ liệu hiện tại bao gồm thẻ, cơ sở kiến thức, insight và cài đặt. Không thể hoàn tác. Tiếp tục?';

  @override
  String get restoreComplete => 'Khôi phục hoàn tất';

  @override
  String get restoreRestartHint =>
      'Dữ liệu đã được khôi phục. Vui lòng khởi động lại ứng dụng để mọi thay đổi có hiệu lực.';

  @override
  String restoreFailed(Object error) {
    return 'Khôi phục thất bại: $error';
  }

  @override
  String get invalidBackupFile =>
      'Tệp sao lưu không hợp lệ. Vui lòng chọn tệp .memex.';

  @override
  String get automaticBackup => 'Sao lưu tự động';

  @override
  String get autoBackupDescription =>
      'Khi bật, Memex tạo tối đa một ảnh chụp cục bộ mỗi ngày sau khi khởi động hoặc khi quay lại nền trước.';

  @override
  String get backupSensitiveSettingsHint =>
      'Bản sao lưu bao gồm cài đặt và API Key nhà cung cấp mô hình. Giữ tệp sao lưu ở nơi bạn tin tưởng.';

  @override
  String get backupLocation => 'Vị trí';

  @override
  String get backupLocationDetails => 'Chi tiết vị trí';

  @override
  String get backupLocationSummary => 'Hiển thị trong ứng dụng';

  @override
  String get backupLocationFullPath => 'Đường dẫn đầy đủ';

  @override
  String get backupLocationUri => 'URI quyền truy cập thư mục';

  @override
  String get copyBackupLocationPath => 'Sao chép đường dẫn';

  @override
  String get backupLocationCopied => 'Đã sao chép vị trí sao lưu';

  @override
  String androidBackupLocationSelected(Object folderName) {
    return 'Thư mục đã chọn: $folderName';
  }

  @override
  String get iosICloudBackupLocation => 'iCloud Drive > Memex > Backups';

  @override
  String get iosAppDocumentsBackupLocation =>
      'Files > Trên iPhone của tôi > Memex > Backups';

  @override
  String get autoBackupStatus => 'Trạng thái';

  @override
  String get noAutoBackupYet => 'Chưa có sao lưu tự động';

  @override
  String lastBackupAt(Object time) {
    return 'Sao lưu lần cuối: $time';
  }

  @override
  String get autoBackupRetention => 'Lưu giữ';

  @override
  String autoBackupRetentionDays(Object days) {
    return '$days ngày';
  }

  @override
  String get autoBackupRetentionForever => 'Giữ mãi mãi';

  @override
  String get autoBackupMaxSize => 'Giới hạn dung lượng';

  @override
  String autoBackupRetentionLimitHint(Object size) {
    return 'Dọn dẹp tự động giữ ảnh chụp tự động dưới $size. Ảnh chụp an toàn và xuất thủ công được giữ riêng.';
  }

  @override
  String get createSnapshotNow => 'Sao lưu ngay';

  @override
  String get backupLocationMenu => 'Đổi vị trí';

  @override
  String get defaultBackupLocation => 'Thư mục sao lưu mặc định';

  @override
  String get defaultBackupLocationAndroidDesc =>
      'Dùng thư mục tệp ngoài riêng của Memex. Không cần quyền lưu trữ.';

  @override
  String get chooseBackupLocation => 'Chọn thư mục sao lưu';

  @override
  String get chooseBackupLocationAndroidDesc =>
      'Chọn thư mục bằng bộ chọn hệ thống Android và cấp Memex quyền truy cập lâu dài.';

  @override
  String get storedBackups => 'Bản sao lưu đã lưu';

  @override
  String get noStoredBackups =>
      'Sao lưu tự động sẽ xuất hiện ở đây sau ảnh chụp đầu tiên.';

  @override
  String get backupTypeAutoSnapshot => 'Ảnh chụp tự động';

  @override
  String get backupTypeSafetySnapshot => 'Ảnh chụp an toàn';

  @override
  String get backupTypeManualBackup => 'Sao lưu thủ công';

  @override
  String get refresh => 'Làm mới';

  @override
  String get restoreThisBackup => 'Khôi phục bản sao lưu này';

  @override
  String get deleteThisBackup => 'Xóa bản sao lưu này';

  @override
  String get confirmDeleteBackup => 'Xóa bản sao lưu?';

  @override
  String confirmDeleteBackupMessage(Object fileName) {
    return 'Xóa $fileName? Sẽ xóa tệp sao lưu đã lưu và không thể hoàn tác.';
  }

  @override
  String backupDeleted(Object fileName) {
    return 'Đã xóa bản sao lưu: $fileName';
  }

  @override
  String backupDeleteFailed(Object error) {
    return 'Không thể xóa bản sao lưu: $error';
  }

  @override
  String get creatingSafetySnapshot => 'Đang tạo ảnh chụp an toàn...';

  @override
  String autoBackupCreated(Object fileName) {
    return 'Đã tạo ảnh chụp: $fileName';
  }

  @override
  String backupLocationFailed(Object error) {
    return 'Không thể cập nhật vị trí sao lưu: $error';
  }

  @override
  String get backupImportCreatedAt => 'Đã tạo';

  @override
  String get backupImportSourceVersion => 'Phiên bản nguồn';

  @override
  String get backupImportFlavor => 'Bản dựng';

  @override
  String get backupLegacyFormat => 'Sao lưu cũ (không có manifest)';

  @override
  String get restoreInProgress => 'Đang khôi phục bản sao lưu...';

  @override
  String get dataStorage => 'Lưu trữ dữ liệu';

  @override
  String get dataStorageDescriptionAndroid =>
      'Chọn thư mục tùy chỉnh để lưu workspace. Dữ liệu được giữ khi cài lại ứng dụng.';

  @override
  String get dataStorageDescriptionIOS =>
      'Bật iCloud để đồng bộ workspace trên các thiết bị và giữ dữ liệu khi cài lại ứng dụng.';

  @override
  String get storageLocationApp => 'Lưu trữ ứng dụng';

  @override
  String get storageLocationAppDesc =>
      'Dữ liệu lưu trong ứng dụng và sẽ bị xóa khi gỡ cài đặt.';

  @override
  String get storageLocationCustom => 'Lưu trữ thiết bị (thư mục tùy chỉnh)';

  @override
  String get storageLocationCustomDesc =>
      'Lưu dữ liệu trong thư mục bạn chọn. Dữ liệu tồn tại qua cài lại nếu thư mục còn.';

  @override
  String get storageLocationICloud => 'Lưu trên iCloud';

  @override
  String get storageLocationICloudDesc =>
      'Đồng bộ workspace trên thiết bị Apple. Dữ liệu giữ sau khi cài lại.';

  @override
  String storageLocationCurrent(Object location) {
    return 'Hiện tại: $location';
  }

  @override
  String get icloudRequiresCapability =>
      'Đăng nhập iCloud và bật iCloud Drive để dùng lưu trữ iCloud.';

  @override
  String get loadingFromICloud => 'Đang khôi phục dữ liệu từ iCloud…';

  @override
  String get switchingToICloud => 'Đang chuyển sang lưu trữ iCloud…';

  @override
  String get switchingStorage => 'Đang chuyển lưu trữ…';

  @override
  String get customFolderAccessDenied =>
      'Không thể đọc hoặc ghi thư mục này. Vui lòng cấp quyền lưu trữ hoặc chọn thư mục khác.';

  @override
  String get configured => 'Đã cấu hình';

  @override
  String get apiKeyNotSet => 'Chưa đặt API Key — nhấn để cấu hình';

  @override
  String get bottomNavTimeline => 'Dòng thời gian';

  @override
  String get bottomNavLibrary => 'Thư viện';

  @override
  String get aiGeneratedLabel => 'Do AI tạo';

  @override
  String sourceTraceWithCount(Object count) {
    return 'NGUỒN GỐC ($count)';
  }

  @override
  String get deleteAccount => 'Xóa tài khoản';

  @override
  String get deleteAccountDesc =>
      'Xóa vĩnh viễn tất cả dữ liệu cục bộ và đặt lại ứng dụng.';

  @override
  String get deleteAccountConfirmTitle => 'Xóa tài khoản?';

  @override
  String get deleteAccountConfirmMessage =>
      'Sẽ xóa vĩnh viễn tất cả dữ liệu bao gồm thẻ dòng thời gian, cơ sở kiến thức, bản ghi và cài đặt. Không thể hoàn tác.';

  @override
  String deleteAccountTypeName(Object name) {
    return 'Nhập \"$name\" để xác nhận';
  }

  @override
  String get deleteAccountTypeHint => 'Nhập tên người dùng để xác nhận';

  @override
  String get llmConsentTitle => 'Đồng ý chia sẻ dữ liệu';

  @override
  String llmConsentMessage(Object provider) {
    return 'Để bật tính năng AI, Memex cần gửi dữ liệu của bạn tới $provider để xử lý. Bao gồm:\n\n• Văn bản bạn nhập (ghi chú, chuyển giọng nói)\n• Siêu dữ liệu ảnh và văn bản trích xuất (OCR)\n• Tóm tắt sức khỏe và fitness\n• Nội dung thẻ dòng thời gian\n\nDữ liệu được gửi trực tiếp từ thiết bị tới $provider. Memex không lưu trữ hoặc chuyển tiếp dữ liệu qua máy chủ khác.\n\nVui lòng xem chính sách quyền riêng tư của $provider về cách họ xử lý dữ liệu.\n\nBạn có đồng ý gửi dữ liệu tới $provider để xử lý AI không?';
  }

  @override
  String get llmConsentAgree => 'Tôi đồng ý';

  @override
  String get llmConsentDecline => 'Từ chối';

  @override
  String get customAgents => 'Agent tùy chỉnh';

  @override
  String get noCustomAgents => 'Chưa cấu hình agent tùy chỉnh.';

  @override
  String get deleteAgent => 'Xóa agent';

  @override
  String deleteAgentConfirm(Object name) {
    return 'Xóa agent tùy chỉnh \"$name\"?';
  }

  @override
  String get deleted => 'Đã xóa';

  @override
  String get saved => 'Đã lưu';

  @override
  String get newAgent => 'Agent mới';

  @override
  String get editAgent => 'Chỉnh sửa agent';

  @override
  String get agentName => 'Tên agent';

  @override
  String get agentNameHint => 'my-custom-agent';

  @override
  String get agentNameRequired => 'Bắt buộc';

  @override
  String get agentNameInvalid => 'Chỉ chữ cái, chữ số và gạch ngang';

  @override
  String get agentNameExists => 'Tên đã tồn tại';

  @override
  String get hostAgentType => 'Loại host agent';

  @override
  String get skillDirectory => 'Thư mục skill';

  @override
  String get skillDirInvalid =>
      'Phải là đường dẫn tương đối (không có / hoặc .. ở đầu)';

  @override
  String get workingDirectory => 'Thư mục làm việc (Tùy chọn)';

  @override
  String get workingDirectoryHint => 'Để trống cho mặc định workspace';

  @override
  String get llmConfig => 'Cấu hình LLM';

  @override
  String get eventType => 'Loại sự kiện';

  @override
  String get executionMode => 'Chế độ thực thi';

  @override
  String get executionModeAsync => 'Bất đồng bộ';

  @override
  String get executionModeSync => 'Đồng bộ';

  @override
  String get dependsOn => 'Phụ thuộc';

  @override
  String get dependsOnHint => 'Chọn phụ thuộc';

  @override
  String get priority => 'Ưu tiên';

  @override
  String get maxRetries => 'Số lần thử lại tối đa';

  @override
  String get systemPromptLabel => 'System Prompt (Tùy chọn)';

  @override
  String get systemPromptHint => 'Hướng dẫn bổ sung thêm vào prompt host agent';

  @override
  String get eventSerializer => 'Event Serializer';

  @override
  String get eventSerializerDefault => 'Mặc định (XML)';

  @override
  String get enabledLabel => 'Đã bật';

  @override
  String get skillsManagement => 'Quản lý skill';

  @override
  String get skillsManagementEmpty => 'Chưa có skill';

  @override
  String get downloadSkill => 'Tải skill';

  @override
  String get downloadFile => 'Tải tệp';

  @override
  String get downloading => 'Đang tải...';

  @override
  String get downloadSuccess => 'Đã tải skill thành công';

  @override
  String downloadFailed(Object error) {
    return 'Tải thất bại: $error';
  }

  @override
  String get deleteConfirm => 'Xác nhận xóa';

  @override
  String deleteConfirmMessage(String name) {
    return 'Bạn có chắc muốn xóa \"$name\"?';
  }

  @override
  String get invalidUrl => 'Vui lòng nhập URL hợp lệ';

  @override
  String get urlHint => 'https://example.com/skill.zip';

  @override
  String get newFolder => 'Thư mục mới';

  @override
  String get newFile => 'Tệp mới';

  @override
  String get folderName => 'Tên thư mục';

  @override
  String get fileName => 'Tên tệp';

  @override
  String get nameRequired => 'Tên là bắt buộc';

  @override
  String get nameInvalid => 'Tên không được chứa / hoặc ..';

  @override
  String createFailed(Object error) {
    return 'Tạo thất bại: $error';
  }

  @override
  String get fileContent => 'Nội dung tệp';

  @override
  String get saveSuccess => 'Đã lưu thành công';

  @override
  String downloadToCurrentDir(String dir) {
    return 'Tệp zip sẽ được giải nén vào thư mục hiện tại: $dir';
  }

  @override
  String get privacyPolicy => 'Chính sách quyền riêng tư';

  @override
  String get privacyPolicyDesc => 'Cách Memex xử lý dữ liệu của bạn';

  @override
  String get llmAuthError =>
      'Xác thực API thất bại. Vui lòng kiểm tra cấu hình LLM trong Cài đặt.';

  @override
  String get llmBadRequestError =>
      'Yêu cầu bị nhà cung cấp LLM từ chối. Định dạng đầu vào có thể không được mô hình hiện tại hỗ trợ.';

  @override
  String get llmRateLimitError =>
      'Vượt giới hạn tốc độ API. Vui lòng thử lại sau.';

  @override
  String get llmServerError =>
      'Dịch vụ LLM tạm thời không khả dụng. Vui lòng thử lại sau.';

  @override
  String get llmNetworkError =>
      'Kết nối mạng thất bại. Vui lòng kiểm tra kết nối internet.';

  @override
  String get llmUnknownError =>
      'Đã xảy ra lỗi không mong đợi khi xử lý nội dung.';

  @override
  String get llmErrorDialogTitle => 'Xử lý thất bại';

  @override
  String get goToModelConfig => 'Đi tới Cài đặt';

  @override
  String get speechModelDownloadTitle => 'Tải mô hình giọng nói';

  @override
  String speechModelDownloadDesc(Object sizeMB) {
    return 'Cần tải mô hình một lần (~${sizeMB}MB).\n\nSau khi tải, chuyển giọng nói chạy hoàn toàn trên thiết bị.';
  }

  @override
  String get speechModelStartDownload => 'Bắt đầu tải';

  @override
  String get speechModelChooseSource => 'Chọn nguồn tải:';

  @override
  String get speechModelChinaMirror => '🇨🇳 Gương Trung Quốc (Nhanh hơn ở CN)';

  @override
  String get speechModelGithub => '🌐 GitHub (Toàn cầu)';

  @override
  String get speechModelDownloading => 'Đang tải mô hình...';

  @override
  String get speechModelConnecting => 'Đang kết nối...';

  @override
  String get deleteSpeechModel => 'Xóa mô hình giọng nói';

  @override
  String get confirmDeleteSpeechModelMessage =>
      'Xóa tệp mô hình nhận dạng giọng nói cục bộ đã tải? Sẽ được tải lại lần sau khi dùng chuyển giọng nói cục bộ.';

  @override
  String get speechModelDeletedSuccess => 'Đã xóa tệp mô hình giọng nói';

  @override
  String get speechModelNotDownloaded =>
      'Không tìm thấy tệp mô hình giọng nói đã tải';

  @override
  String speechModelDeleteFailed(Object error) {
    return 'Không thể xóa tệp mô hình giọng nói: $error';
  }

  @override
  String get speechTranscribing => 'Đang nhận dạng...';

  @override
  String get speechNoResult => 'Không phát hiện giọng nói';

  @override
  String get useLocalSpeechToTextTitle => 'Dùng chuyển giọng nói cục bộ';

  @override
  String get useLocalSpeechToTextDesc =>
      'Khi bật, âm thanh được chuyển thành văn bản trên thiết bị trước khi gửi — hữu ích cho mô hình không hỗ trợ đầu vào âm thanh. Khi tắt, âm thanh gốc được gửi trực tiếp tới mô hình.';

  @override
  String get pendingAiProcessingHint => 'Thiết lập mô hình AI để xử lý';

  @override
  String get demoWelcome =>
      'Chào mừng đến Memex!\nHãy xem nhanh AI có thể làm gì cho bản ghi của bạn.';

  @override
  String get demoTapAdd => 'Nhấn đây để tạo bản ghi đầu tiên';

  @override
  String get demoTapSend => 'Nhấn để gửi bản ghi đầu tiên';

  @override
  String get demoTapCard => 'Nhấn để xem AI đã sắp xếp bản ghi như thế nào';

  @override
  String get demoDetailHint =>
      'Đây là chi tiết bản ghi do AI sắp xếp. Cuộn xem, rồi quay lại để tiếp tục tour.';

  @override
  String get demoTapInsight => 'Nhấn để xem insight do AI tạo';

  @override
  String get demoTapInsightUpdate => 'Nhấn để tạo insight từ bản ghi';

  @override
  String get demoTapKnowledge => 'Xem tệp kiến thức được sắp xếp tự động';

  @override
  String get demoDone => 'Bắt đầu ghi lại cuộc sống.';

  @override
  String get demoStartTour => 'Bắt đầu tour';

  @override
  String get demoGetStarted => 'Bắt đầu';

  @override
  String get demoSkip => 'Bỏ qua';

  @override
  String get demoPrefillText =>
      'Xin chào Memex! Đây là bản ghi đầu tiên của tôi 🎉';

  @override
  String get visionBadge => 'Vision';

  @override
  String get notMultimodalHint =>
      'Memex dựa vào khả năng mô hình đa phương thức để phân tích phương tiện. Nếu bản ghi có ảnh, hãy đảm bảo mô hình đã cấu hình hỗ trợ đầu vào hình ảnh.';

  @override
  String get defaultModelPrefix => 'Mặc định';

  @override
  String get recommendedBadge => 'Đề xuất';

  @override
  String get readOnlyBadge => 'CHAT';

  @override
  String get switchCompanion => 'Đổi đồng hành';

  @override
  String get personaChatInputHint => 'Nhập tin nhắn...';

  @override
  String get today => 'Hôm nay';

  @override
  String get tomorrow => 'Ngày mai';

  @override
  String get yesterday => 'Hôm qua';

  @override
  String get showInsightTextTitle => 'Hiển thị bình luận insight Memex';

  @override
  String get showInsightTextDesc =>
      'Có hiển thị insight Memex dưới dạng bình luận ghim trong phần bình luận chi tiết thẻ.';

  @override
  String get enableCharacterCommentTitle => 'Tự động bình luận nhân vật';

  @override
  String get enableCharacterCommentDesc =>
      'Nhân vật tự động bình luận trên bản ghi mới.';

  @override
  String get maxCommentCharactersTitle => 'Số ký tự bình luận tối đa';

  @override
  String get maxCommentCharactersDesc =>
      'Số ký tự có thể bình luận trên mỗi bản ghi.';

  @override
  String replyTo(String name) {
    return 'Trả lời $name';
  }

  @override
  String get cdnSignalsComments => 'Đã nhận trả lời mới';

  @override
  String get cdnSignalsInsight => 'Đã tạo insight mới';

  @override
  String get cdnSignalsBoth => 'Trả lời mới và insight';

  @override
  String get untitledCard => 'Thẻ chưa đặt tên';

  @override
  String get locationContextTitle => 'Ngữ cảnh vị trí';

  @override
  String get locationContextDescription =>
      'Ngữ cảnh thành phố và khu vực hiện tại cho trò chuyện agent';

  @override
  String get locationContextAttachTitle =>
      'Đính kèm vị trí hiện tại vào trò chuyện';

  @override
  String get locationContextAttachDesc =>
      'Dùng GPS thiết bị và mã hóa ngược địa lý để cung cấp ngữ cảnh thành phố, quận và khu vực cho agent.';

  @override
  String get reverseGeocodingProvider => 'Nhà cung cấp mã hóa ngược địa lý';

  @override
  String get amapProviderName => 'Amap';

  @override
  String get amapApiKey => 'Amap API Key';

  @override
  String get amapGcj02Note =>
      'Amap dùng tọa độ GCJ-02. GPS thiết bị được chuyển đổi trước khi mã hóa ngược địa lý.';

  @override
  String get contextGranularity => 'Độ chi tiết ngữ cảnh';

  @override
  String get granularityCity => 'Thành phố';

  @override
  String get granularityDistrict => 'Quận';

  @override
  String get granularityNeighborhood => 'Khu vực';

  @override
  String get granularityStreet => 'Đường';

  @override
  String get granularityFullAddress => 'Ứng viên địa chỉ đầy đủ';

  @override
  String get locationFreshness => 'Độ mới vị trí';

  @override
  String minutesShort(int minutes) {
    return '$minutes phút';
  }

  @override
  String get oneHour => '1 giờ';

  @override
  String get testCurrentLocation => 'Kiểm tra vị trí hiện tại';

  @override
  String locationTestFailed(String error) {
    return 'Thất bại: $error';
  }

  @override
  String get locationDebugGps => 'GPS';

  @override
  String get locationDebugReverseGeocode => 'Mã hóa ngược địa lý';

  @override
  String get locationDebugProvider => 'Nhà cung cấp';

  @override
  String get locationDebugAgentContext => 'Ngữ cảnh agent';

  @override
  String get locationDebugSource => 'Nguồn';

  @override
  String get locationDebugAddressSummary => 'Tóm tắt địa chỉ';

  @override
  String get locationDebugFullAddress => 'Địa chỉ đầy đủ';

  @override
  String get locationDebugCoordinates => 'Tọa độ';

  @override
  String get locationDebugAccuracy => 'Độ chính xác';

  @override
  String get locationDebugReason => 'Lý do';

  @override
  String get locationDebugOk => 'OK';

  @override
  String get locationDebugUnavailable => 'không khả dụng';

  @override
  String get locationDebugInjected => 'đã chèn';

  @override
  String get locationDebugNotInjected => 'chưa chèn';

  @override
  String get locationStatusUpdatedAt => 'Đã cập nhật';

  @override
  String get locationStatusSuccessTitle => 'Vị trí hiện tại đã sẵn sàng';

  @override
  String get locationStatusSuccessBody =>
      'Memex có thể đính kèm tóm tắt vị trí này khi ngữ cảnh vị trí liên quan.';

  @override
  String get locationStatusApproximateTitle => 'Chỉ vị trí gần đúng';

  @override
  String get locationStatusApproximateBody =>
      'Độ chính xác ở mức thành phố hoặc khu vực. Bạn có thể tiếp tục dùng, hoặc bật Vị trí chính xác trong cài đặt hệ thống để ngữ cảnh chặt hơn.';

  @override
  String get locationStatusServiceDisabledTitle => 'Vị trí hệ thống đã tắt';

  @override
  String get locationStatusServiceDisabledBody =>
      'Memex chỉ dùng GPS thiết bị và không suy luận vị trí từ mạng hoặc IP. Trên Android, mở Cài đặt Vị trí; trên iOS, bật Cài đặt > Quyền riêng tư & Bảo mật > Dịch vụ vị trí.';

  @override
  String get locationStatusPermissionDeniedTitle => 'Cần quyền vị trí';

  @override
  String get locationStatusPermissionDeniedBody =>
      'Cho phép Memex dùng vị trí khi kiểm tra hoặc khi cần ngữ cảnh vị trí. Không yêu cầu quyền Luôn luôn.';

  @override
  String get locationStatusPermissionForeverTitle => 'Quyền vị trí bị chặn';

  @override
  String get locationStatusPermissionForeverBody =>
      'Mở cài đặt ứng dụng và cho phép vị trí cho Memex. Trên iOS, Khi dùng ứng dụng là đủ.';

  @override
  String get locationStatusDisabledTitle => 'Ngữ cảnh vị trí đã tắt';

  @override
  String get locationStatusDisabledBody =>
      'Bật công tắc phía trên và lưu khi bạn muốn Memex đính kèm vị trí thiết bị vào ngữ cảnh agent.';

  @override
  String get locationStatusGeocodeUnavailableTitle =>
      'GPS hoạt động, tra cứu địa chỉ thất bại';

  @override
  String get locationStatusGeocodeUnavailableBody =>
      'Memex có tọa độ nhưng sẽ không chèn ngữ cảnh chỉ GPS vào agent. Kiểm tra nhà cung cấp mã hóa ngược địa lý và thử lại.';

  @override
  String get locationStatusUnavailableTitle => 'Vị trí không khả dụng';

  @override
  String get locationStatusUnavailableBody =>
      'Kiểm tra dịch vụ vị trí hệ thống và quyền ứng dụng, rồi thử lại.';

  @override
  String get allowLocationPermissionButton => 'Cho phép quyền vị trí';

  @override
  String get openAppSettingsButton => 'Mở cài đặt ứng dụng';

  @override
  String get openLocationSettingsButton => 'Mở cài đặt vị trí';

  @override
  String get locationSettingsOpenFailed => 'Không thể mở cài đặt hệ thống.';

  @override
  String locationActionFailed(String error) {
    return 'Hành động vị trí thất bại: $error';
  }

  @override
  String get settingsSearchPlaceholder => 'Tìm kiếm cài đặt...';

  @override
  String get settingsSearchEmpty => 'Không tìm thấy cài đặt phù hợp';

  @override
  String get importCharacterCard => 'Nhập thẻ nhân vật';

  @override
  String get firstMessageLabel => 'Tin nhắn đầu tiên';

  @override
  String get firstMessageHint =>
      'Lời chào gửi ở cuộc trò chuyện đầu (tùy chọn)';

  @override
  String get systemPromptOverrideLabel => 'Ghi đè System Prompt';

  @override
  String get systemPromptOverrideHint =>
      'Ghi đè system prompt mặc định (nâng cao, tùy chọn)';

  @override
  String get postHistoryInstructionsLabel => 'Hướng dẫn sau lịch sử';

  @override
  String get postHistoryInstructionsHint =>
      'Hướng dẫn chèn sau lịch sử trò chuyện, trước phản hồi (tùy chọn)';

  @override
  String get mesExampleLabel => 'Ví dụ tin nhắn';

  @override
  String get mesExampleHint =>
      'Hội thoại mẫu thể hiện phong cách nhân vật (tùy chọn)';

  @override
  String get worldBookTitle => 'World Book';

  @override
  String get worldBookSubtitle =>
      'Kiến thức nền được chèn khi từ khóa được kích hoạt';

  @override
  String get characterMemoryTitle => 'Bộ nhớ nhân vật';

  @override
  String get characterMemorySubtitle =>
      'Động lực quan hệ và ký ức tương tác giữa nhân vật và người dùng';

  @override
  String get addTooltip => 'Thêm';

  @override
  String get constantBadge => 'Hằng số';

  @override
  String worldEntryFallbackName(Object index) {
    return 'Mục $index';
  }

  @override
  String keywordsPrefix(Object keys) {
    return 'Từ khóa: $keys';
  }

  @override
  String memoryFallbackName(Object index) {
    return 'Bộ nhớ $index';
  }

  @override
  String get addWorldEntry => 'Thêm mục World Book';

  @override
  String get editWorldEntry => 'Chỉnh sửa mục World Book';

  @override
  String get commentTitleLabel => 'Bình luận / Tiêu đề';

  @override
  String get entryDescriptionHint => 'Mô tả mục (tùy chọn)';

  @override
  String get triggerKeywordsLabel => 'Từ khóa kích hoạt';

  @override
  String get triggerKeywordsHint =>
      'Phân tách bằng dấu phẩy, vd.: magic, spell';

  @override
  String get contentLabel => 'Nội dung';

  @override
  String get worldEntryContentHint =>
      'Kiến thức nền được chèn khi từ khóa kích hoạt';

  @override
  String get enabledCheckbox => 'Đã bật';

  @override
  String get addMemory => 'Thêm bộ nhớ';

  @override
  String get editMemory => 'Chỉnh sửa bộ nhớ';

  @override
  String get memoryLabelField => 'Nhãn';

  @override
  String get memoryLabelHint => 'Định danh duy nhất, vd.: name preference';

  @override
  String get memoryContentHint => 'Nội dung bộ nhớ';

  @override
  String get salienceLabel => 'Mức độ nổi bật: ';

  @override
  String get labelCannotBeEmpty => 'Nhãn không được để trống';

  @override
  String importSuccess(Object name) {
    return 'Đã nhập $name thành công';
  }

  @override
  String importFailed(Object error) {
    return 'Nhập thất bại: $error';
  }

  @override
  String get supportedFormats => 'Định dạng hỗ trợ';

  @override
  String get tavernImportDescription =>
      '• Thẻ nhân vật SillyTavern V2 (.json)\n• Ảnh PNG có thẻ nhúng (.png)\n\nCác trường như persona, world book, v.v. sẽ tự động ánh xạ sang định dạng nhân vật Memex.';

  @override
  String get pickCharacterFile => 'Chọn tệp nhân vật';

  @override
  String get repickFile => 'Chọn tệp khác';

  @override
  String get personaSettingSection => 'Persona';

  @override
  String get systemPromptSection => 'System Prompt';

  @override
  String worldEntriesCount(Object count) {
    return 'World Book: $count mục';
  }

  @override
  String fileLabel(Object filename) {
    return 'Tệp: $filename';
  }

  @override
  String conflictWarning(Object names) {
    return 'Nhân vật cùng tên đã tồn tại: $names. Nhập sẽ tạo nhân vật mới mà không ghi đè nhân vật hiện có.';
  }

  @override
  String get setPrimaryCompanionTitle => 'Đặt làm đồng hành chính';

  @override
  String get setPrimaryCompanionSubtitle =>
      'Tự động đặt làm đồng hành chính sau khi nhập';

  @override
  String get confirmImport => 'Xác nhận nhập';

  @override
  String get chatBackground => 'Nền trò chuyện';

  @override
  String get chooseChatBackgroundImage => 'Chọn ảnh nền';

  @override
  String get earlyUpdateSettingsTitle => 'Cập nhật Early access';

  @override
  String get earlyUpdateSettingsDesc =>
      'Kiểm tra pre-release GitHub cho APK Early tương ứng, tải và chuyển cho trình cài Android.';

  @override
  String get earlyUpdateUnsupported =>
      'Cập nhật Early chỉ khả dụng trên bản dựng Android Early.';

  @override
  String get earlyUpdateAutoCheckTitle => 'Tự động kiểm tra cập nhật';

  @override
  String get earlyUpdateAutoCheckDesc =>
      'Kiểm tra khi khởi động tối đa mỗi 12 giờ một lần.';

  @override
  String get earlyUpdateWifiOnlyTitle => 'Chỉ tải trên Wi-Fi';

  @override
  String get earlyUpdateWifiOnlyDesc =>
      'Bỏ qua tải cập nhật khi dùng dữ liệu di động.';

  @override
  String get earlyUpdateAutoInstallTitle => 'Tự động tải và cài đặt';

  @override
  String get earlyUpdateAutoInstallDesc =>
      'Khi tìm thấy bản dựng mới, tải và mở trình cài Android tự động.';

  @override
  String get earlyUpdateCheckNow => 'Kiểm tra ngay';

  @override
  String get earlyUpdateChecking => 'Đang kiểm tra pre-release GitHub...';

  @override
  String get earlyUpdateSkippedMobile =>
      'Đã bỏ qua vì chỉ tải trên Wi-Fi đang bật.';

  @override
  String get earlyUpdateNoUpdate => 'Bạn đã ở bản Early mới nhất.';

  @override
  String earlyUpdateFound(Object version, Object build) {
    return 'Bản Early $version+$build đã có.';
  }

  @override
  String get earlyUpdateDownloadAndInstall => 'Tải và cài đặt';

  @override
  String get earlyUpdateDownloadInProgress => 'Đang tải cập nhật...';

  @override
  String earlyUpdateDownloadingPercent(Object percent) {
    return 'Đang tải cập nhật: $percent%';
  }

  @override
  String get earlyUpdateDownloadReadyToInstall =>
      'Đã tải gói cập nhật. Sẵn sàng cài đặt.';

  @override
  String get earlyUpdateInstallDownloadedPackage => 'Cài gói đã tải';

  @override
  String get earlyUpdateClearDownloadedPackage => 'Xóa gói đã tải';

  @override
  String get earlyUpdateClearDownloadedPackageSuccess =>
      'Đã xóa gói cập nhật đã tải.';

  @override
  String get earlyUpdateInstallStarted => 'Đã mở trình cài Android.';

  @override
  String get earlyUpdateInstallPermissionRequired =>
      'Cho phép Memex cài ứng dụng không xác định, rồi nhấn tải và cài lại.';

  @override
  String earlyUpdateLastChecked(Object time) {
    return 'Kiểm tra lần cuối: $time';
  }

  @override
  String earlyUpdateCheckFailed(Object error) {
    return 'Kiểm tra cập nhật thất bại: $error';
  }

  @override
  String get earlyUpdateDialogTitle => 'Có bản cập nhật Early';

  @override
  String get earlyUpdateReleaseNotes => 'Ghi chú phát hành';

  @override
  String get dismissAllNotifications => 'Xóa tất cả';

  @override
  String get dismissByType => 'Xóa theo loại';

  @override
  String get dismissTypeSystemAction => 'Nhắc nhở & sự kiện';

  @override
  String get dismissTypeClarification => 'Làm rõ';

  @override
  String get dismissTypeCardUpdate => 'Cập nhật thẻ';

  @override
  String dismissedCount(Object count) {
    return 'Đã xóa $count';
  }

  @override
  String get dataImportTitle => 'Nhập tệp';

  @override
  String get dataImportSettingsDescription =>
      'Đưa tệp cũ vào Memex, rồi quyết định có sắp xếp hay không.';

  @override
  String get dataImportDescription =>
      'Chọn ghi chú cũ, bản ghi xuất, tài liệu hoặc kho lưu trữ ZIP. Memex lưu bản sao trước và không đụng tệp gốc. Sau khi nhập, bạn có thể quyết định Memex có giúp sắp xếp không.';

  @override
  String get dataImportSelectFiles => 'Chọn tệp để nhập';

  @override
  String get dataImportImporting => 'Đang lưu tệp...';

  @override
  String get dataImportSuccess => 'Đã lưu tệp trong Memex';

  @override
  String get dataImportOnlyStored => 'Đã lưu tệp. Chưa bắt đầu sắp xếp.';

  @override
  String get dataImportQueued => 'Memex sẽ sắp xếp lần nhập này ở nền.';

  @override
  String get dataImportResultTitle => 'Nhập hoàn tất';

  @override
  String dataImportResultSummary(Object count) {
    return 'Đã lưu $count tệp. Bạn có thể sắp xếp ngay hoặc giữ làm nguyên liệu nguồn.';
  }

  @override
  String dataImportRenamedConflicts(Object count) {
    return '$count mục trùng tên đã được đổi tên để tránh ghi đè.';
  }

  @override
  String dataImportSkippedUnsafeEntries(Object count) {
    return '$count mục kho lưu trữ bất thường đã bỏ qua; phần còn lại nhập bình thường.';
  }

  @override
  String get dataImportChooseProcessing => 'Sắp xếp các tệp này';

  @override
  String get dataImportProcessTitle => 'Sắp xếp lần nhập này?';

  @override
  String dataImportProcessPrompt(Object count) {
    return 'Bạn đã nhập $count tệp. Chọn Memex có sắp xếp ngay hay chỉ giữ bản gốc.';
  }

  @override
  String get dataImportProcessKnowledgeBase => 'Sắp xếp vào cơ sở kiến thức';

  @override
  String get dataImportProcessKnowledgeBaseDesc =>
      'Tốt cho tài liệu, ghi chú, tài liệu dự án và tham chiếu. Memex trích xuất thông tin hữu ích và nhóm để dùng sau.';

  @override
  String get dataImportProcessTimelineCards => 'Tạo bản ghi dòng thời gian';

  @override
  String get dataImportProcessTimelineCardsDesc =>
      'Tốt cho nhật ký, nhật ký trò chuyện, lịch sử hoạt động và bản xuất cũ. Memex biến nội dung theo thời gian thành bản ghi khi phù hợp.';

  @override
  String get dataImportImpactNone =>
      'Memex chỉ giữ các tệp gốc. Không bắt đầu tổ chức AI.';

  @override
  String get dataImportImpactKnowledgeBase =>
      'Memex đọc các tệp và sắp xếp thông tin dài hạn hữu ích vào cơ sở kiến thức. Không chủ động tạo bản ghi dòng thời gian.';

  @override
  String get dataImportImpactTimelineCards =>
      'Memex đọc các tệp và tạo bản ghi dòng thời gian cho sự kiện cuộc sống hoặc lịch sử có ngày khi phù hợp. Không chủ động sắp xếp cơ sở kiến thức.';

  @override
  String get dataImportImpactBoth =>
      'Memex sẽ cố tạo bản ghi dòng thời gian và sắp xếp thông tin tái sử dụng vào cơ sở kiến thức. Tốt nhất cho kho lưu trữ cá nhân đầy đủ.';

  @override
  String get dataImportFinish => 'Chỉ lưu';

  @override
  String get noImages => 'Không có ảnh';

  @override
  String get noMessages => 'Không có tin nhắn';

  @override
  String get sketchContent => 'Nội dung phác thảo';

  @override
  String get emptyFolder => 'Thư mục trống';

  @override
  String get usernameAlreadyTaken => 'Tên người dùng đã được dùng';

  @override
  String get registrationFailed => 'Đăng ký thất bại';

  @override
  String get loginFailed => 'Đăng nhập thất bại';

  @override
  String get paymentCreationFailed => 'Không thể bắt đầu thanh toán';

  @override
  String get completePayment => 'Hoàn tất thanh toán';

  @override
  String get commentReplyToYou => 'Bạn';

  @override
  String get commentAuthorUser => 'Người dùng';

  @override
  String get commentAuthorAi => 'AI';

  @override
  String get authorizationCancelled => 'Đã hủy ủy quyền';

  @override
  String timelineWeekNumberLabel(Object week) {
    return 'Tuần $week';
  }

  @override
  String get timelineWeekLabel => 'Tuần';

  @override
  String get eventCardDefaultTitle => 'Sự kiện';

  @override
  String get memoryNoLongTermYet => 'Chưa có ký ức dài hạn.';

  @override
  String get memoryNoRecentBuffer => 'Không có ký ức gần đây trong bộ đệm.';

  @override
  String get memoryGeneralSubject => 'Chung';
}
