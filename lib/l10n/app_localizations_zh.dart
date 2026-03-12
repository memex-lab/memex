// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get timesLabel => '次数';

  @override
  String get recordSubmittedAiProcessing => '记录已提交，AI 正在处理中...';

  @override
  String modelSetAsDefault(Object modelId) {
    return '已将 $modelId 设为默认模型';
  }

  @override
  String loadModelListFailed(Object error) {
    return '加载模型列表失败: \n$error';
  }

  @override
  String get retry => '重试';

  @override
  String get noModelsFound => '没有找到可用的模型';

  @override
  String get unknownModel => '未知模型';

  @override
  String get openAiModelConfig => 'OpenAI 模型配置';

  @override
  String get notSet => '未设置';

  @override
  String get confirmClear => '确认清除';

  @override
  String get confirmClearTokenMessage => '清除当前用户？需要重新输入用户ID。';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get tokenCleared => '已清除用户';

  @override
  String clearTokenFailed(Object error) {
    return '清除用户失败: $error';
  }

  @override
  String get reprocessKnowledgeBase => '重新处理知识库';

  @override
  String get selectDateRangeOptional => '选择日期范围（可选）：';

  @override
  String get startDate => '开始日期';

  @override
  String get endDate => '结束日期';

  @override
  String get select => '选择';

  @override
  String get processLimitOptional => '处理数量限制（可选）';

  @override
  String get leaveEmptyForAll => '留空表示处理所有';

  @override
  String get startProcessing => '开始处理';

  @override
  String get userIdNotFound => '未找到用户ID';

  @override
  String get reprocessTaskCreated => '重新处理任务已创建，正在后台处理中';

  @override
  String createTaskFailed(Object error) {
    return '创建任务失败: $error';
  }

  @override
  String get reprocessCards => '重新处理卡片';

  @override
  String get reprocessCardsTaskCreated => '重新处理卡片任务已创建，正在后台处理中';

  @override
  String get regenerateComments => '重新生成评论';

  @override
  String get regenerateCommentsTaskCreated => '重新生成评论任务已创建，正在后台处理中';

  @override
  String get clearData => '清除数据';

  @override
  String get confirmClearDataMessage => '确定要清除数据吗？\n';

  @override
  String get confirmClearDataKeepFactsMessage =>
      '将仅保留 Facts 目录（原始记录），删除工作区内其他所有目录（Cards、Discoveries、KnowledgeInsights、PKM、_System 等）。\n\n此操作不可恢复！';

  @override
  String get dataClearedSuccess => '数据清除成功';

  @override
  String clearDataFailed(Object error) {
    return '清除数据失败: $error';
  }

  @override
  String get personalCenter => '个人中心';

  @override
  String get viewLogs => '查看日志';

  @override
  String get systemAuthorization => '系统授权';

  @override
  String get modelAuthorization => '模型授权';

  @override
  String get pkmKnowledgeBase => 'PKM知识库';

  @override
  String get aiCharacterConfig => 'AI 角色配置';

  @override
  String get appLockConfig => '应用锁配置';

  @override
  String get modelConfig => '模型配置';

  @override
  String get agentConfig => 'Agent配置';

  @override
  String get modelUsageStats => '模型使用统计';

  @override
  String get asyncTaskList => '异步任务列表';

  @override
  String get clearLocalToken => '清除用户';

  @override
  String get insightCardTemplates => '洞察卡片模板展示';

  @override
  String get timelineCardTemplates => 'Timeline 卡片模板展示';

  @override
  String get logViewer => '日志查看';

  @override
  String get autoRefresh => '自动刷新';

  @override
  String get lineCount => '行数: ';

  @override
  String get all => '全部';

  @override
  String loadStatsFailed(Object error) {
    return '加载统计数据失败: $error';
  }

  @override
  String get overview => '概览';

  @override
  String get daily => '每日';

  @override
  String get detail => '详情';

  @override
  String get date => '日期';

  @override
  String get noData => '暂无数据';

  @override
  String get totalCalls => '总调用次数';

  @override
  String saveLlmConfigFailed(Object error) {
    return '保存LLM配置失败: $error';
  }

  @override
  String get webHtmlPreviewUnavailable => 'Web 端暂未接入 HTML 预览，请在移动端查看。';

  @override
  String saveUserInfoFailed(Object error) {
    return '保存用户信息失败: $error';
  }

  @override
  String get totalEstimatedCost => '总预估费用';

  @override
  String get detailSubtitle => '详情';

  @override
  String get close => '关闭';

  @override
  String get noFragments => '暂无碎片';

  @override
  String get totalTokenConsumption => '总 Token 消耗';

  @override
  String get dataLoadFailedRetry => '数据加载失败，请稍后重试';

  @override
  String get timelineLoadFailedRetry => '时间轴加载失败，请稍后重试';

  @override
  String get aggregatedLoadFailedRetry => '加载聚合数据失败，请稍后重试';

  @override
  String get newPerspective => '新的视角';

  @override
  String get startPoint => '起点';

  @override
  String get endPoint => '终点';

  @override
  String get originalInput => '原始输入';

  @override
  String get referenceContent => '引用内容';

  @override
  String referenceWithTitle(Object title) {
    return '引用: $title';
  }

  @override
  String get discoveredTodoActions => '发现的待办动作';

  @override
  String get noPendingActions => '目前没有待处理的动作';

  @override
  String get askSomethingHint => '问点什么...';

  @override
  String get aiAssistant => 'AI助手';

  @override
  String get footprintMap => '足迹地图';

  @override
  String get waypointPlaces => '途径地点';

  @override
  String get unknownPlace => '未知地点';

  @override
  String get loadFailedRetry => '加载失败, 请重试';

  @override
  String get noRecordsInPeriod => '该周期内无记录';

  @override
  String get releaseToSend => '松开 发送';

  @override
  String get selectFromAlbum => '从相册选择';

  @override
  String get takePhoto => '拍照';

  @override
  String get enterContentOrMediaHint => '请输入内容、选择图片或录制音频';

  @override
  String get tellAiWhatHappened => '告诉AI发生了什么...';

  @override
  String recordingWithDuration(Object duration) {
    return '录音中: $duration';
  }

  @override
  String get playing => '播放中...';

  @override
  String get recordedAudio => '已录制音频';

  @override
  String get recordLabel => '记录';

  @override
  String get smartSuggesting => '智能建议中...';

  @override
  String get noTaskData => '暂无任务数据';

  @override
  String createdAtDate(Object date) {
    return '创建: $date';
  }

  @override
  String updatedAtDate(Object date) {
    return '更新: $date';
  }

  @override
  String durationLabel(Object duration) {
    return '耗时: $duration';
  }

  @override
  String retryCount(Object count) {
    return '重试: $count';
  }

  @override
  String get aiMaterialProcessFailed => 'AI 素材处理失败';

  @override
  String get aiMaterialProcessDone => 'AI 素材处理完成';

  @override
  String get aiOrganizingMaterial => 'AI 正在整理素材';

  @override
  String get taskCompletedAddedToTimeline => '任务已圆满完成，卡片已加入 Timeline';

  @override
  String get processErrorRetryLater => '处理过程中发生了一些错误，请稍后重试';

  @override
  String get loadDetailFailedRetry => '加载详情失败，请稍后重试';

  @override
  String get loadFailed => '加载失败';

  @override
  String get reload => '重新加载';

  @override
  String get aiInsightDetail => 'AI 洞察详情';

  @override
  String relatedRecordsCount(Object count) {
    return '关联记录 ($count)';
  }

  @override
  String get noRelatedRecords => '暂无具体关联记录';

  @override
  String get useFingerprintToUnlock => '请使用指纹解锁';

  @override
  String get locked => '已锁定';

  @override
  String get wrongPassword => '密码错误';

  @override
  String get enterPassword => '请输入密码';

  @override
  String get memexLocked => 'Memex 已锁定';

  @override
  String get calendarShortSun => '日';

  @override
  String get calendarShortMon => '一';

  @override
  String get calendarShortTue => '二';

  @override
  String get calendarShortWed => '三';

  @override
  String get calendarShortThu => '四';

  @override
  String get calendarShortFri => '五';

  @override
  String get calendarShortSat => '六';

  @override
  String noRecordsOnDate(Object date) {
    return '$date 无记录';
  }

  @override
  String get footprintPath => '足迹路径';

  @override
  String get lifeCompositionTable => '生活成分表';

  @override
  String get emotionReframe => '情绪重构';

  @override
  String get chronicleOfThings => '物的编年史';

  @override
  String get goalProgress => '目标进度';

  @override
  String get trendChart => '趋势图';

  @override
  String get comparisonChart => '对比图';

  @override
  String get todayTimeFlow => '今日时间流';

  @override
  String get insightAssistant => '洞察助手';

  @override
  String get insightInputHint => '关于知识洞察，你想了解什么...';

  @override
  String get aiInputHint => '无论是回忆还是当下，我都准备好了...';

  @override
  String get noContentInPeriod => '该时间段无内容';

  @override
  String get nothingHere => '这里什么都没有';

  @override
  String get noPendingActionsToast => '当前没有待处理动作';

  @override
  String get knowledgeNewDiscovery => '知识库新发现';

  @override
  String discoveredNewInsightsCount(Object count) {
    return '发现了 $count 个新洞察';
  }

  @override
  String updatedExistingInsightsCount(Object count) {
    return '更新了 $count 个现有洞察';
  }

  @override
  String get sectionNewInsights => '发现新洞察';

  @override
  String get sectionUpdatedInsights => '更新现有洞察';

  @override
  String get unnamedInsight => '未命名洞察';

  @override
  String loadDirectoryFailed(Object error) {
    return '加载目录失败: $error';
  }

  @override
  String readFileFailed(Object error) {
    return '读取文件失败: $error';
  }

  @override
  String get backToParent => '返回上级';

  @override
  String get directoryEmpty => '目录为空';

  @override
  String get copiedToClipboard => '已复制到剪贴板';

  @override
  String get copy => '复制';

  @override
  String get binaryFile => '二进制文件';

  @override
  String fileSizeLabel(Object size) {
    return '文件大小: $size';
  }

  @override
  String get selectedLocation => '已选位置';

  @override
  String get confirmLocationName => '确认位置名称';

  @override
  String get confirmLocationNameHint => '你可以修改位置名称（经纬度保持不变）';

  @override
  String get nameLabel => '名称';

  @override
  String get inputPlaceNameHint => '输入地点名称...';

  @override
  String currentCoordinates(Object lat, Object lng) {
    return '当前坐标: $lat, $lng';
  }

  @override
  String get confirmLocation => '确认位置';

  @override
  String get userCreatedSuccess => '用户创建成功！';

  @override
  String get welcomeToMemex => '欢迎来到 Memex';

  @override
  String get createUserIdToStart => '请创建一个你的专属昵称';

  @override
  String get userIdLabel => '你的名字 / 昵称';

  @override
  String get userIdHint => '请输入你的名字';

  @override
  String get pleaseEnterUserId => '名字不能为空哦';

  @override
  String get userIdMinLength => '名字太短啦，至少需要1个字符';

  @override
  String get userIdMaxLength => '名字太长啦，不能超过50个字符';

  @override
  String get userIdFormat => '名字格式有误';

  @override
  String get startUsing => '下一步';

  @override
  String get userIdTip => '开启你的专属记忆。';

  @override
  String get openAiAuthInfo => 'OpenAI 授权信息';

  @override
  String get setupModelConfigTitle => '连接你的 AI 大脑';

  @override
  String get setupModelConfigSubtitle =>
      'Memex 需要 AI 模型的支持才能为你整理记忆和提炼洞察。请配置你想使用的大模型服务。';

  @override
  String get setupModelConfigComplete => '配置完成，开启旅程';

  @override
  String get skipForNow => '暂不配置，先逛逛';

  @override
  String get modelAuth => '模型授权';

  @override
  String get clearAuth => '清除授权';

  @override
  String get openAiAuthCleared => '已清除 OpenAI 授权';

  @override
  String get authorizing => '正在授权中...';

  @override
  String openAiAuthSuccess(Object accountId) {
    return 'OpenAI 授权成功！AccountId: $accountId';
  }

  @override
  String authFailed(Object error) {
    return '授权失败: $error';
  }

  @override
  String get authorized => '已授权';

  @override
  String get viewAuthInfo => '查看授权信息';

  @override
  String get config => '配置';

  @override
  String get calendar => '日历';

  @override
  String get reminders => '提醒事项';

  @override
  String get writeToSystemFailed => '写入系统失败';

  @override
  String permissionRequired(Object name) {
    return '需要$name权限';
  }

  @override
  String permissionRationale(Object name) {
    return '请在设置中允许 App 访问你的$name，以便我们在后台帮你创建。';
  }

  @override
  String get goToSettings => '去设置';

  @override
  String get unknownAction => '未知操作';

  @override
  String get discoveredCalendarEvent => '发现日历日程';

  @override
  String get discoveredReminder => '发现提醒事项';

  @override
  String get addToCalendar => '加到日历';

  @override
  String get addToReminders => '加到提醒事项';

  @override
  String addedToSuccess(Object target) {
    return '已成功添加至$target';
  }

  @override
  String get ignore => '忽略';

  @override
  String get appLockOn => '应用锁已开启';

  @override
  String get appLockOff => '应用锁已关闭';

  @override
  String get enableAppLockFirst => '请先启用应用锁';

  @override
  String get enterFourDigitPassword => '请输入4位数字密码';

  @override
  String get passwordSetAndLockOn => '密码已设置并开启应用锁';

  @override
  String get appLockSettings => '应用锁配置';

  @override
  String get enableAppLock => '启用应用锁';

  @override
  String get enableAppLockSubtitle => '启用后，启动应用需要验证密码';

  @override
  String get enableBiometrics => '启用生物识别';

  @override
  String get biometricsSubtitle => '解锁时可以使用面容ID或触控ID';

  @override
  String get changePassword => '修改密码';

  @override
  String get setFourDigitPassword => '设置4位密码';

  @override
  String get reenterPasswordToConfirm => '请再次输入密码以确认';

  @override
  String get passwordMismatch => '两次输入的密码不一致，请重新输入';

  @override
  String get confirmDelete => '确认删除';

  @override
  String get confirmDeleteSessionMessage => '确定要删除这个会话吗？此操作不可恢复。';

  @override
  String get delete => '删除';

  @override
  String get deleteSuccess => '删除成功';

  @override
  String deleteFailed(Object error) {
    return '删除失败: $error';
  }

  @override
  String get continueChat => '继续对话...';

  @override
  String daysAgo(Object count) {
    return '$count天前';
  }

  @override
  String get chatHistory => '会话历史';

  @override
  String get noConversations => '暂无会话';

  @override
  String loadSessionListFailed(Object error) {
    return '加载会话列表失败: $error';
  }

  @override
  String yesterdayAt(Object time) {
    return '昨天 $time';
  }

  @override
  String get newChat => '新对话';

  @override
  String messageCount(Object count) {
    return '$count 条消息';
  }

  @override
  String get organize => '整理';

  @override
  String get pkmCategoryProject => '项目';

  @override
  String get pkmCategoryProjectSubtitle => '短期 · 目标 · 截止日';

  @override
  String get pkmCategoryArea => '领域';

  @override
  String get pkmCategoryAreaSubtitle => '长期 · 责任 · 标准';

  @override
  String get pkmCategoryResource => '资源';

  @override
  String get pkmCategoryResourceSubtitle => '兴趣 · 灵感 · 储备';

  @override
  String get pkmCategoryArchive => '归档';

  @override
  String get pkmCategoryArchiveSubtitle => '完成 · 沉寂 · 备查';

  @override
  String get recentChanges => '最近变动';

  @override
  String get noRecentChangesInThreeDays => '暂无最近3天的变动';

  @override
  String get unpinned => '已取消固定';

  @override
  String get pinnedStyle => '已固定该整理样式';

  @override
  String operationFailed(Object error) {
    return '操作失败: $error';
  }

  @override
  String get refreshingInsightData => '正在刷新洞察数据，这可能需要一点时间...';

  @override
  String refreshFailed(Object error) {
    return '刷新失败: $error';
  }

  @override
  String get sortUpdated => '排序已更新';

  @override
  String sortSaveFailed(Object error) {
    return '排序保存失败: $error';
  }

  @override
  String get insightCardDeleted => '已删除洞察卡片';

  @override
  String deleteFailedShort(Object error) {
    return '删除失败: $error';
  }

  @override
  String get aboutThisInsightHint => '关于这个洞察，你想了解什么...';

  @override
  String get knowledgeInsight => '知识洞察';

  @override
  String get completeSort => '完成排序';

  @override
  String get noKnowledgeInsight => '暂无知识洞察';

  @override
  String get updating => '更新中...';

  @override
  String get update => '更新';

  @override
  String get enabled => '已启用';

  @override
  String get disabled => '已禁用';

  @override
  String confirmDeleteCharacter(Object name) {
    return '确定要删除角色\"$name\"吗？此操作不可恢复。';
  }

  @override
  String get configureAiCharacter => '配置AI 角色';

  @override
  String get addCharacter => '添加角色';

  @override
  String get addCharacterSubtitle => '选择你喜欢的AI角色加入洞察团队。他们将从不同角度分析你的生活数据。';

  @override
  String get noCharacters => '暂无角色';

  @override
  String loadCharacterFailed(Object error) {
    return '加载角色失败: $error';
  }

  @override
  String get characterDesignerHint => '描述你想要创建或更新的角色...';

  @override
  String get characterDesigner => '角色设计师';

  @override
  String get noTags => '无标签';

  @override
  String get createSuccess => '创建成功';

  @override
  String get updateSuccess => '更新成功';

  @override
  String saveFailed(Object error) {
    return '保存失败: $error';
  }

  @override
  String get newCharacter => '新增角色';

  @override
  String get editCharacter => '编辑角色';

  @override
  String get save => '保存';

  @override
  String get characterName => '角色名称';

  @override
  String get characterNameHint => '给角色起个好听的名字';

  @override
  String get pleaseEnterCharacterName => '请输入角色名称';

  @override
  String get tagsLabel => '标签';

  @override
  String get tagsHint => '例如：智慧, 认可, 宏观\n用逗号分隔多个标签';

  @override
  String get characterPersonaLabel => '角色完整设定';

  @override
  String get characterPersonaHint =>
      '包含角色人设、风格指南、示例对话、知识过滤器等所有信息。\n可以使用 ## 标题 来分段组织内容。';

  @override
  String get pleaseEnterCharacterPersona => '请输入角色完整设定';

  @override
  String get systemFeaturesAndExtensions => '系统功能与扩展';

  @override
  String get shareExtensionTitle => '分享扩展 (Share Extension)';

  @override
  String get shareExtensionSubtitle => '允许通过系统分享菜单将内容分享至应用';

  @override
  String get screenTimeTitle => '屏幕使用时间 (Screen Time API)';

  @override
  String get screenTimeSubtitle => '授权访问应用使用时长与注意力数据';

  @override
  String permissionRequestError(Object error) {
    return '权限请求异常: $error';
  }

  @override
  String get permissionRequiredTitle => '需要权限';

  @override
  String get permissionPermanentlyDeniedMessage =>
      '由于您已永久拒绝该权限或系统需要，请前往系统设置中手动开启。';

  @override
  String get getting => '获取中...';

  @override
  String get unauthorized => '未授权';

  @override
  String get authorizedGoToSettings => '已授权，如需修改请前往系统设置';

  @override
  String get goToSettingsShort => '前往设置';

  @override
  String get basicPermissions => '基础权限';

  @override
  String get location => '定位';

  @override
  String get locationPermissionReason => '用于记录足迹和地理位置相关功能';

  @override
  String get photos => '相册';

  @override
  String get photosPermissionReason => '用于选取照片、保存生成的图片等';

  @override
  String get camera => '相机';

  @override
  String get cameraPermissionReason => '用于拍摄照片和视频相关功能';

  @override
  String get microphone => '麦克风';

  @override
  String get microphonePermissionReason => '用于语音识别、录音等功能';

  @override
  String get calendarPermissionReason => '用于记录日程、读取日历事件等';

  @override
  String get remindersPermissionReason => '用于记录和读取您的待办提醒';

  @override
  String get fitnessAndMotion => '健身与运动';

  @override
  String get fitnessPermissionReason => '用于记录健康与运动数据';

  @override
  String get notification => '通知';

  @override
  String get notificationPermissionReason => '用于发送日程提醒等重要通知';

  @override
  String get loadDetailFailedRetryShort => '加载详情失败，请稍后重试';

  @override
  String get llmCallStats => 'LLM 调用统计';

  @override
  String get noLlmCallRecords => '暂无 LLM 调用记录';

  @override
  String get total => '总计';

  @override
  String get callCount => '调用次数';

  @override
  String get estimatedCost => '预估费用';

  @override
  String get byAgent => '按 Agent 统计';

  @override
  String get cardGenerationAgent => '卡片生成 Agent';

  @override
  String get knowledgeOrgAgent => '知识库整理 Agent';

  @override
  String get commentGenerationAgent => '评论生成 Agent';

  @override
  String get timeUpdated => '时间已更新';

  @override
  String updateFailed(Object error) {
    return '更新失败: $error';
  }

  @override
  String get locationUpdated => '地点已更新';

  @override
  String get confirmDeleteCardMessage => '确定要删除这张卡片吗？此操作不可恢复。';

  @override
  String get profileAgent => '用户画像 Agent';

  @override
  String get assetAnalysis => '媒资分析';

  @override
  String get cardDetailNotFound => '未找到卡片详情';

  @override
  String get saySomething => '说点什么...';

  @override
  String get relatedMemories => '相关回忆';

  @override
  String get viewMore => '查看更多';

  @override
  String get relatedRecords => '相关记录';

  @override
  String get replySent => '回复已发送';

  @override
  String get insightTemplateGalleryTitle => '洞察卡片模板展示';

  @override
  String get timelineTemplateGalleryTitle => 'Timeline 卡片模板展示';

  @override
  String get categoryGeneral => '通用 (General)';

  @override
  String get categoryTextual => '文字 (Textual)';

  @override
  String get k411 =>
      '## 什么是心流？\n\n心流（Flow）是由心理学家米哈里·契克森米哈提出的一种心理状态。当你完全沉浸在一项具有挑战性但可完成的任务中，时间感消失，注意力高度集中，这就是心流。\n\n> 人在做感兴趣的事情时，常常浑然忘我。\n\n研究发现，心流状态下的人往往生产力最高，幸福感也最强。';

  @override
  String get timelineFilterAll => '全部';

  @override
  String get timelineDays => '日';

  @override
  String get timelineWeeks => '周';

  @override
  String get timelineMonths => '月';

  @override
  String get timelineYears => '年';

  @override
  String get insights => '洞察';

  @override
  String get memoryTitle => '记忆';

  @override
  String get longTermProfile => '长期记忆';

  @override
  String get recentBuffer => '近期记忆';

  @override
  String errorLoadingMemory(Object error) {
    return '加载记忆失败: $error';
  }

  @override
  String get agentConfiguration => 'Agent 配置';

  @override
  String get resetToDefaults => '恢复默认';

  @override
  String get resetAllAgentConfigurationsTitle => '重置所有 Agent 配置';

  @override
  String get resetAllAgentConfigurationsMessage =>
      '确定要将所有 Agent 配置恢复为默认值吗？此操作不可恢复。';

  @override
  String get resetButton => '重置';

  @override
  String loadDataFailed(Object error) {
    return '加载失败: $error';
  }

  @override
  String saveConfigFailed(Object error) {
    return '保存配置失败: $error';
  }

  @override
  String get selectLlmClient => '选择 LLM 客户端:';

  @override
  String get agentConfigurationsReset => 'Agent 配置已重置';

  @override
  String resetFailed(Object error) {
    return '重置失败: $error';
  }

  @override
  String get modelConfiguration => '模型配置';

  @override
  String get resetAllConfigurationsTitle => '重置所有配置';

  @override
  String get resetAllModelConfigurationsMessage => '确定要将所有模型配置恢复为默认值吗？此操作不可恢复。';

  @override
  String get modelConfigurationsReset => '模型配置已重置';

  @override
  String get cannotDeleteDefaultConfiguration => '无法删除默认配置';

  @override
  String get cannotDeleteConfigurationTitle => '无法删除配置';

  @override
  String configUsedByAgentsMessage(Object agentList) {
    return '以下 Agent 正在使用此配置:\n\n$agentList\n\n请先为这些 Agent 重新分配配置后再删除。';
  }

  @override
  String get ok => '确定';

  @override
  String get deleteConfigurationTitle => '删除配置';

  @override
  String confirmDeleteConfigMessage(Object key) {
    return '确定要删除「$key」吗？';
  }

  @override
  String get defaultLabel => '默认';

  @override
  String get missingApiKey => '缺少 API Key';

  @override
  String get invalidJsonInExtraField => '扩展字段 JSON 格式无效';

  @override
  String get keyAlreadyExists => '该 Key 已存在';

  @override
  String get resetConfigurationTitle => '重置配置';

  @override
  String get resetConfigurationMessage => '将此配置恢复为初始默认值？当前修改将丢失。';

  @override
  String get configurationResetPressSave => '配置已重置，请点击保存以应用。';

  @override
  String get addConfiguration => '添加配置';

  @override
  String get editConfiguration => '编辑配置';

  @override
  String get keyIdLabel => 'Key (ID)';

  @override
  String get keyIdHelper => '此配置的唯一标识符';

  @override
  String get required => '必填';

  @override
  String get clientLabel => '提供商';

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
  String get modelIdHelper => '例如 gemini-3.1-pro-preview、gpt-4o';

  @override
  String get apiKeyLabel => 'API Key';

  @override
  String get baseUrlLabel => 'Base URL';

  @override
  String get advancedSettings => '高级设置';

  @override
  String get proxyUrlOptional => '代理 URL (可选)';

  @override
  String get proxyUrlHelper => '若设置则覆盖全局代理';

  @override
  String get temperatureLabel => 'Temperature';

  @override
  String get topPLabel => 'Top P';

  @override
  String get maxTokensLabel => 'Max Tokens';

  @override
  String get extraParamsJson => '扩展参数 (JSON)';

  @override
  String get invalidJson => 'JSON 格式无效';

  @override
  String get warning => '警告';

  @override
  String get invalidConfigurationWarning =>
      '当前配置不完整（例如：缺少 API Key、Model ID，或 Base URL），可能无法正常工作。确定要保存吗？';

  @override
  String invalidModelConfigDetailed(Object agentId, Object configKey) {
    return '智能体“$agentId”需要有效的模型配置 (Key: “$configKey”) 才能运行。请在设置中更新并补全对应的参数。';
  }

  @override
  String get discardChangesTitle => '放弃未保存的修改？';

  @override
  String get discardChangesMessage => '您有未保存的修改。确定要放弃修改并离开吗？';

  @override
  String get discardButton => '放弃';

  @override
  String get chooseLanguage => '选择语言';

  @override
  String get chooseAvatar => '选择头像';

  @override
  String get coachMarkFirstPost => '点击这里，记录你的第一个想法 ✨';

  @override
  String get coachMarkInsightRefresh => '点击生成你的专属洞察 🔮';

  @override
  String get coachMarkConfigureModel => '先配置 AI 模型，解锁全部功能 🔑';

  @override
  String get configureNow => '立即配置';

  @override
  String get modelNotConfiguredBanner => 'AI 模型尚未配置，请先设置以解锁全部功能。';

  @override
  String get modelNotConfiguredSubmitHint => '请先配置 AI 模型再发布内容';

  @override
  String get processingStatus => '处理中';

  @override
  String get failedStatus => '处理失败';

  @override
  String get viewDetails => '查看详情';

  @override
  String get failureReason => '失败原因';

  @override
  String get unknownError => '发生未知错误';

  @override
  String get enableFitness => '开启健身权限';

  @override
  String get fitnessBannerMessage => '允许访问健身数据以记录你的健康和运动信息。';

  @override
  String get fitnessDismissTitle => '跳过健身权限？';

  @override
  String get fitnessDismissMessage => '如果跳过，应用将无法自动收集你的健康数据进行洞察分析和自动记录。';

  @override
  String get skipAnyway => '仍然跳过';
}
