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
  String modelSetAsDefault(Object modelId) {
    return '已将 $modelId 设为默认模型';
  }

  @override
  String get retry => '重试';

  @override
  String get unknownModel => '未知模型';

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
  String createTaskFailed(Object error) {
    return '创建任务失败: $error';
  }

  @override
  String get reprocessCards => '重新处理卡片';

  @override
  String get reprocessCardsTaskCreated => '已交给 Super Agent 重新处理';

  @override
  String get reprocessCardsDownstreamMode => '处理范围';

  @override
  String get reprocessCardsCardOnly => '只处理卡片';

  @override
  String get reprocessCardsCardOnlyDesc => '让 Super Agent 检查并重新生成选中的时间线卡片。';

  @override
  String get reprocessCardsRerunDownstream => '卡片和相关后续';

  @override
  String get reprocessCardsRerunDownstreamDesc =>
      '让 Super Agent 在需要时一并考虑 PKM 和洞察更新。';

  @override
  String get reanalyzeMediaAssets => '重新读取媒体附件';

  @override
  String get reanalyzeMediaAssetsDesc => '重新生成卡片时，让 Super Agent 在需要时再次查看附件内容。';

  @override
  String get regenerateComments => '重新生成评论';

  @override
  String get regenerateCommentsTaskCreated => '重新生成评论任务已创建，正在后台处理中';

  @override
  String get rebuildSearchIndex => '重建搜索索引';

  @override
  String get rebuildSearchIndexSuccess => '搜索索引重建完成';

  @override
  String get rebuildSearchIndexFailed => '搜索索引重建失败';

  @override
  String get clearData => '清除数据';

  @override
  String get confirmClearDataMessage => '确定要清除数据吗？\n';

  @override
  String get confirmClearDataDeletesWorkspaceMessage =>
      '当前用户的本地工作区数据都会被删除，包括卡片、媒体、知识文件、洞察、记忆、聊天历史和系统状态。\n\n此操作不可恢复！';

  @override
  String get clearFailedAgentContexts => '清除失败的对话上下文';

  @override
  String get confirmClearFailedAgentContextsMessage =>
      '清除 Insight 和 Schedule Agent 已保存的对话上下文？这适用于切换模型后，旧的 agent 消息与新模型 API 不兼容的情况。Facts、卡片、知识库、记忆和模型配置不会被删除。';

  @override
  String failedAgentContextsCleared(Object count) {
    return '已清除 $count 个已保存的对话上下文';
  }

  @override
  String clearFailedAgentContextsFailed(Object error) {
    return '清除对话上下文失败: $error';
  }

  @override
  String get cloneToTestUser => '克隆为测试用户';

  @override
  String get confirmCloneToTestUserMessage =>
      '将当前工作区复制到一个新的本地测试用户并切换过去。不会复制 Agent 运行态，当前用户数据不会被修改。';

  @override
  String get testUserIdLabel => '测试用户名';

  @override
  String get testUserIdHelper => '只能使用英文、数字、中划线或下划线。';

  @override
  String get testUserIdInvalid => '只能使用英文、数字、中划线或下划线。';

  @override
  String get overwriteExistingTestUser => '覆盖同名测试用户';

  @override
  String testUserCloneSuccess(Object userId) {
    return '已切换到测试用户 $userId';
  }

  @override
  String testUserCloneFailed(Object error) {
    return '克隆测试用户失败: $error';
  }

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
  String get aiCharacterConfig => 'AI 角色配置';

  @override
  String get modelConfig => '模型配置';

  @override
  String get agentConfig => 'Agent配置';

  @override
  String get experimentalLab => '实验室';

  @override
  String get experimentalLabDescription => '仍在实验中的能力，后续可能调整或移动。';

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
  String get schedule => '日程';

  @override
  String get appLockConfig => '应用锁配置';

  @override
  String loadStatsFailed(Object error) {
    return '加载统计数据失败: $error';
  }

  @override
  String get overview => '概览';

  @override
  String get daily => '每日';

  @override
  String get modelStatsByAgent => '分模型统计';

  @override
  String get detail => '详情';

  @override
  String get date => '日期';

  @override
  String get agent => 'Agent';

  @override
  String get noData => '暂无数据';

  @override
  String get totalCalls => '总调用次数';

  @override
  String get calls => '调用';

  @override
  String callsCount(Object count) {
    return '$count 次调用';
  }

  @override
  String get selectDateRange => '选择日期范围';

  @override
  String get totalTokens => '总 Token';

  @override
  String get cacheRate => '缓存命中率';

  @override
  String get promptTokens => 'Prompt Token';

  @override
  String get completionTokens => 'Completion Token';

  @override
  String get cachedTokens => 'Cached Token';

  @override
  String get thoughtTokens => 'Thought Token';

  @override
  String get prompt => 'Prompt';

  @override
  String get completion => 'Completion';

  @override
  String get cached => 'Cached';

  @override
  String get thought => 'Thought';

  @override
  String get model => '模型';

  @override
  String get scene => '场景';

  @override
  String get sceneId => '场景 ID';

  @override
  String get tokenUsage => 'Token 用量';

  @override
  String get handler => '处理器';

  @override
  String get modelBreakdown => '模型拆分';

  @override
  String get callDetails => '调用详情';

  @override
  String recordDetailsTitle(Object scene) {
    return '记录详情: $scene';
  }

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
  String get close => '关闭';

  @override
  String get totalTokenConsumption => '总 Token 消耗';

  @override
  String get dataLoadFailedRetry => '数据加载失败，请稍后重试';

  @override
  String get timelineLoadFailedRetry => '时间轴加载失败，请稍后重试';

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
  String get actionCenterTitle => '待处理事项';

  @override
  String get noPendingActions => '目前没有待处理的动作';

  @override
  String get clarificationNeeded => 'Memex 想确认一下';

  @override
  String get clarificationTextHint => '输入一个简短回答';

  @override
  String get clarificationTextRequired => '请先补充一个简短回答';

  @override
  String get clarificationAnswered => '已回答';

  @override
  String clarificationAnswerPrefix(Object answer) {
    return '已回答：$answer';
  }

  @override
  String get answerSaved => '回答已保存';

  @override
  String get clarificationOtherAnswer => '手动输入';

  @override
  String get clarificationNotSure => '不知道/不方便说';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get footprintMap => '足迹地图';

  @override
  String get waypointPlaces => '途径地点';

  @override
  String get unknownPlace => '未知地点';

  @override
  String get releaseToSend => '松开 发送';

  @override
  String get selectFromAlbum => '从相册选择';

  @override
  String get clipboardPreviewTitle => '新剪贴板';

  @override
  String get clipboardPreviewImageTitle => '剪贴板图片';

  @override
  String get clipboardPreviewImageDescription => '可添加到输入框';

  @override
  String get clipboardPreviewUnprocessed => '未处理';

  @override
  String get clipboardPreviewPasteToInput => '粘贴到输入框';

  @override
  String get clipboardPreviewAddImageToInput => '添加图片';

  @override
  String get clipboardPreviewImageFailed => '无法读取剪贴板图片';

  @override
  String get tellAiWhatHappened => '告诉AI发生了什么...';

  @override
  String recordingWithDuration(Object duration) {
    return '录音中: $duration';
  }

  @override
  String get playing => '播放中...';

  @override
  String get sendLabel => '发送';

  @override
  String attachedImagesMessage(Object count) {
    return '发送了 $count 张图片';
  }

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
  String get loadDetailFailedRetry => '加载详情失败，请稍后重试';

  @override
  String get loadFailed => '加载失败';

  @override
  String loadHistoryFailed(Object error) {
    return '加载历史记录失败：$error';
  }

  @override
  String get reload => '重新加载';

  @override
  String get aiInsightDetail => '洞察详情';

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
  String get aiInputHint => '无论是回忆还是当下，我都准备好了...';

  @override
  String get refreshSuperAgentStateTooltip => '清空 Memex Agent Context';

  @override
  String get refreshSuperAgentStateTitle => '清空 Memex Agent 历史 Context？';

  @override
  String get refreshSuperAgentStateMessage =>
      '可见聊天历史会继续保留，但 Memex Agent 的历史运行 Context 会被清空，之后会从新的 Context 开始回复。持久化记忆、知识库文件、卡片等已保存数据不受影响。适用于 Memex Agent 持续运行异常等情况。确定继续？';

  @override
  String get refreshSuperAgentStateActiveRunMessage =>
      '当前 Memex Agent 消息处理完后才能清空 Context。';

  @override
  String get refreshSuperAgentStateSuccess => 'Memex Agent Context 已清空';

  @override
  String refreshSuperAgentStateFailed(Object error) {
    return '清空 Memex Agent Context 失败: $error';
  }

  @override
  String get nothingHere => '还没有任何内容';

  @override
  String get nothingHereHint => '点击下方按钮创建你的第一张卡片';

  @override
  String get agentProcessing => 'AI 处理中...';

  @override
  String get keepAppOpen => '请不要关闭应用';

  @override
  String get activityDetail => '活动详情';

  @override
  String get noAgentActivityYet => '暂无 Agent 活动';

  @override
  String get processingEllipsis => '处理中...';

  @override
  String get agentBackgroundTitle => 'Memex Agent';

  @override
  String get agentBackgroundPausedTitle => 'Memex Agent 已暂停';

  @override
  String get agentBackgroundNeedsAttentionTitle => 'Memex Agent 需要处理';

  @override
  String get agentBackgroundStageIdle => '空闲';

  @override
  String get agentBackgroundStageProcessing => '处理中';

  @override
  String get agentBackgroundStageQueued => '排队中';

  @override
  String get agentBackgroundStageRetrying => '等待重试';

  @override
  String get agentBackgroundStagePaused => '已暂停';

  @override
  String get agentBackgroundStageCompleted => '已完成';

  @override
  String get agentBackgroundStageNeedsAttention => '需要处理';

  @override
  String get agentBackgroundStageAnalyzingMedia => '分析素材中';

  @override
  String get agentBackgroundStageGeneratingCard => '生成卡片中';

  @override
  String get agentBackgroundStageUpdatingKnowledge => '更新知识中';

  @override
  String get agentBackgroundStagePreparingComment => '准备评论中';

  @override
  String get agentBackgroundStageRoutingFollowUps => '分发后续任务中';

  @override
  String agentBackgroundTaskSummary(
      Object running, Object pending, Object retrying) {
    return '执行中 $running，排队中 $pending，重试中 $retrying';
  }

  @override
  String agentBackgroundTaskDetail(Object count) {
    return '正在处理 $count 个后台任务。';
  }

  @override
  String get agentBackgroundNoTasks => '暂无后台任务。';

  @override
  String get agentBackgroundStarting => '后台处理正在启动。';

  @override
  String get agentBackgroundCompletedDetail => '所有后台任务已完成。';

  @override
  String get agentBackgroundFailedDetail => '后台处理遇到错误。';

  @override
  String get agentBackgroundPausedDetail => '后台处理已暂停，稍后会继续。';

  @override
  String get agentBackgroundQueuedDetail => '正在等待下一个处理步骤。';

  @override
  String get agentBackgroundRetryingDetail => '当前步骤将自动重试。';

  @override
  String get agentBackgroundAnalyzeMediaDetail => '正在读取附件和本地上下文。';

  @override
  String get agentBackgroundGeneratingCardDetail => '正在把记录生成时间线卡片。';

  @override
  String get agentBackgroundUpdatingKnowledgeDetail => '正在更新本地知识和记忆。';

  @override
  String get agentBackgroundPreparingCommentDetail => '正在准备助手跟进评论。';

  @override
  String get agentBackgroundRoutingFollowUpsDetail => '正在检查这张卡片的后续动作。';

  @override
  String agentBackgroundPausedStatus(Object summary) {
    return '已暂停 - $summary';
  }

  @override
  String agentBackgroundNeedsAttentionStatus(Object summary) {
    return '需要处理 - $summary';
  }

  @override
  String get settings => '设置';

  @override
  String get languageSettings => '语言';

  @override
  String get languageSettingsDesc => '更改应用显示语言';

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
  String get copiedToClipboard => '已复制到剪贴板';

  @override
  String get copy => '复制';

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
  String get userIdMaxLength => '名字太长啦，不能超过50个字符';

  @override
  String get startUsing => '下一步';

  @override
  String get userIdTip => '开启你的专属记忆。';

  @override
  String get setupModelConfigTitle => '配置 AI 模型';

  @override
  String get setupModelConfigSubtitle =>
      'Memex 需要一个前沿 AI 模型来整理记录、分析图片并生成洞察。选择一种连接方式即可。';

  @override
  String get setupModelConfigComplete => '配置完成，开启旅程';

  @override
  String get aiService => 'Memex 模型服务';

  @override
  String get aiModelHubTitle => 'AI 模型与服务';

  @override
  String get aiModelHubSubtitle => '先选择使用 Memex 官方服务，或接入自己的服务商；需要时再进入高级模型分配。';

  @override
  String get aiSetupCurrentStatusTitle => '当前配置';

  @override
  String get aiSetupStatusNotConfiguredTitle => '尚未配置 AI 服务';

  @override
  String get aiSetupStatusNotConfiguredDescription =>
      '选择一种连接方式后，Memex 才能开始整理记录、分析媒体并生成洞察。';

  @override
  String get aiSetupStatusMemexTitle => '正在使用 Memex 官方服务';

  @override
  String get aiSetupStatusMemexDescription =>
      'Memex 会使用 Memex 账号管理的官方连接和 API 凭证。';

  @override
  String get aiSetupStatusCustomTitle => '正在使用自定义服务商';

  @override
  String get aiSetupStatusCustomDescription =>
      'Memex 会使用你配置的服务商凭证，以及文本/视觉模型用途选择。';

  @override
  String get aiSetupChooseConnectionTitle => '选择连接方式';

  @override
  String get aiSetupChooseConnectionDescription =>
      '先选择你希望 Memex 通过哪条路径访问 AI 模型。';

  @override
  String get aiSetupOfficialRouteDescription => '登录 Memex 后即可使用官方 AI 服务。';

  @override
  String get aiSetupCustomRouteDescription => '添加自己的服务商和 API Key。';

  @override
  String get aiSetupCustomPageTitle => '自定义 AI 服务';

  @override
  String get aiSetupCustomPageSubtitle => '先配置服务商和 API Key，再选择 Memex 使用的模型。';

  @override
  String get aiSetupProviderCredentialsTitle => '服务商与 API Key';

  @override
  String get aiSetupProviderCredentialsDescription =>
      '添加或编辑 OpenAI、Anthropic、DeepSeek、Gemini、OpenRouter、Ollama 等兼容服务商。';

  @override
  String get modelRolesTitle => '选择主模型';

  @override
  String get modelRolesDescription =>
      'Super Agent 使用同一个模型处理文本和图片输入。需要时仍可在下方为单个 Agent 高级覆盖。';

  @override
  String get textModelRoleTitle => '主模型';

  @override
  String get textModelRoleDescription =>
      '供 Super Agent 处理文本、图片、卡片、知识库、洞察、聊天、评论和记忆总结。';

  @override
  String get modelConnectionsTitle => '模型服务商与 API Key';

  @override
  String get modelConnectionsDescription => '可以连接 Memex 官方服务，也可以添加你自己的服务商凭证。';

  @override
  String get relatedAiCapabilitiesTitle => '高级与相关能力';

  @override
  String get relatedAiCapabilitiesDescription =>
      '调整单个 Agent 的模型分配、位置服务商和语音识别方式。';

  @override
  String get aiSetupServiceCapabilitiesTitle => '服务能力';

  @override
  String get aiSetupServiceCapabilitiesDescription =>
      '配置语音识别、逆地理编码等相邻 AI 能力使用的服务方式。';

  @override
  String get aiSetupAdvancedCustomizationTitle => '高级模型路由';

  @override
  String get aiSetupAdvancedCustomizationDescription =>
      '适合希望不同 Agent 使用不同服务商或模型配置的高级用户。';

  @override
  String get locationProviderSettings => '位置服务商';

  @override
  String get speechProviderSettings => '语音识别';

  @override
  String get advancedAgentModelAssignments => 'Agent 模型分配';

  @override
  String get openAdvancedAgentModelAssignments => '为单个 Agent 覆盖模型';

  @override
  String get noConfiguredModelOptions => '请先添加模型服务商或 API Key，再选择模型用途。';

  @override
  String get modelSlotUpdated => '模型用途已更新';

  @override
  String get aiServiceMemexRouteTitle => '通过 Memex 连接';

  @override
  String get aiServiceLongDescription =>
      'Memex 利用多 Agent 架构自动整理你的生活记录、知识笔记与社交关系，深度挖掘洞察，并提供具有持久记忆的 AI 陪伴。所有数据均以纯文本 Markdown 存储，赋予你绝对的数据自由与跨平台迁移能力。';

  @override
  String get aiServiceCustomApiRouteTitle => '我有 API Key';

  @override
  String get aiServiceCustomModelDescription =>
      '已有 OpenAI、Anthropic、DeepSeek、Gemini 等服务的 API Key 时，优先选择这项。';

  @override
  String get enableAiService => '使用 Memex 连接';

  @override
  String get aiServiceReadyToast => 'AI 整理已开启';

  @override
  String get aiServiceSettingsDescription =>
      '没有 API Key 时，可用 Memex 账号代理连接主流模型服务。';

  @override
  String get advancedModelConfiguration => '配置 API Key';

  @override
  String get skipForNow => '暂不配置，先逛逛';

  @override
  String get clearAuth => '清除授权';

  @override
  String get authorizing => '正在授权中...';

  @override
  String authFailed(Object error) {
    return '授权失败: $error';
  }

  @override
  String get authorized => '已授权';

  @override
  String authorizedAs(Object email) {
    return '已授权为 $email';
  }

  @override
  String get authorizedSuccessfully => '授权成功';

  @override
  String get reAuthorize => '重新授权';

  @override
  String get authorizeWithOpenAi => '使用 OpenAI 授权';

  @override
  String get authorizeWithGoogle => '使用 Google 授权';

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
  String get discoveredCalendarEvent => '待确认的日历事件';

  @override
  String get discoveredReminder => '待确认的提醒事项';

  @override
  String get addToCalendar => '加到日历';

  @override
  String get addToReminders => '加到提醒事项';

  @override
  String get systemActionPendingExplanation => '尚未添加。点击下方按钮后，系统会请求权限并写入你的设备。';

  @override
  String addedToSuccess(Object target) {
    return '已成功添加至$target';
  }

  @override
  String get ignore => '忽略';

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
  String daysAgo(Object count) {
    return '$count天前';
  }

  @override
  String get chatHistory => '会话历史';

  @override
  String get enterFullScreenTooltip => '全屏查看';

  @override
  String get exitFullScreenTooltip => '退出全屏';

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
  String get knowledgeInsight => '知识洞察';

  @override
  String get completeSort => '完成排序';

  @override
  String get noKnowledgeInsight => '暂无知识洞察';

  @override
  String insightProcessingBacklogMessage(Object count) {
    return '还有 $count 个后台任务正在处理。';
  }

  @override
  String get insightUnavailableMessage => '这个洞察仍在生成中，或已被更新。请刷新洞察后稍后再试。';

  @override
  String get artifactOpen => '查看';

  @override
  String get updating => '更新中...';

  @override
  String get update => '更新';

  @override
  String get enabled => '已启用';

  @override
  String get disabled => '已禁用';

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
  String get memexAgentNotificationPermissionTitle => '让 Memex Agent 在后台继续运行';

  @override
  String get memexAgentNotificationPermissionMessage =>
      'Memex Agent 在你的设备本地运行。开启通知权限后，Memex 可以显示后台执行进度，让任务在你退到后台或关闭屏幕时继续处理。不开启时，请保持 Memex 在前台，直到任务完成。';

  @override
  String get loadDetailFailedRetryShort => '加载详情失败，请稍后重试';

  @override
  String get total => '总计';

  @override
  String get estimatedCost => '预估费用';

  @override
  String get byAgent => '按 Agent 统计';

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
  String get reply => '回复';

  @override
  String get replySent => '回复已发送';

  @override
  String get insightTemplateGalleryTitle => '洞察卡片模板展示';

  @override
  String get timelineTemplateGalleryTitle => 'Timeline 卡片模板展示';

  @override
  String get categoryTextual => '文字 (Textual)';

  @override
  String get timelineFilterAll => '全部';

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
  String get setAsDefault => '设为默认';

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
  String get duplicateConfiguration => '复制配置';

  @override
  String get duplicate => '复制';

  @override
  String get keyIdLabel => '配置 ID';

  @override
  String get keyIdHelper => '给这套配置起个名字，例如 deepseek 或 work-gpt。';

  @override
  String get required => '必填';

  @override
  String get clientLabel => '模型服务商';

  @override
  String get providerGroupOpenAi => 'OpenAI';

  @override
  String get providerGroupAnthropic => 'Anthropic';

  @override
  String get providerGroupGoogle => 'Google';

  @override
  String get providerGroupOthers => '热门';

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
  String get providerKimi => 'Kimi (月之暗面)';

  @override
  String get providerQwen => 'Aliyun (阿里云)';

  @override
  String get providerSeed => 'Volcengine (火山引擎)';

  @override
  String get providerZhipu => 'Zhipu GLM (智谱)';

  @override
  String get providerDeepSeek => 'DeepSeek (官方 API)';

  @override
  String get providerMinimax => 'MiniMax';

  @override
  String get providerOpenRouter => 'OpenRouter';

  @override
  String get providerOllama => 'Ollama (本地)';

  @override
  String get providerMimo => 'Xiaomi MIMO (小米)';

  @override
  String get providerMemex => 'Memex 代理服务';

  @override
  String get memexSignIn => '登录';

  @override
  String get memexCreateAccount => '注册';

  @override
  String get memexUsername => '用户名';

  @override
  String get memexPassword => '密码';

  @override
  String get memexCreateAccountLink => '注册账号';

  @override
  String get memexSignInLink => '已有账号，去登录';

  @override
  String get memexTopUp => '充值后即可使用 Memex AI';

  @override
  String get memexTopUpSuccess => '充值成功！';

  @override
  String get memexFillAllFields => '请填写所有字段';

  @override
  String get memexUsernameTooShort => '用户名至少 6 个字符';

  @override
  String get memexAuthFailed => '认证失败';

  @override
  String get memexPaymentFailed => '创建支付失败';

  @override
  String get memexLogout => '退出';

  @override
  String get memexTopUpButton => '充值';

  @override
  String get memexTopUpChooseAmount => '选择充值额度';

  @override
  String memexTopUpEstimatedRecords(Object range) {
    return '预计 $range 条记录';
  }

  @override
  String get memexTopUpPlanStarter => '轻量尝试';

  @override
  String get memexTopUpPlanEveryday => '日常整理';

  @override
  String get memexTopUpPlanHighVolume => '高频使用';

  @override
  String get memexTopUpPlanCustom => '自定义额度';

  @override
  String get memexTopUpPlanStarterSubtitle => '适合先体验 Memex AI';

  @override
  String get memexTopUpPlanEverydaySubtitle => '适合持续整理和分析';

  @override
  String get memexTopUpPlanHighVolumeSubtitle => '适合批量处理较多记录';

  @override
  String get memexTopUpPlanCustomSubtitle => '输入 1-10000 美元';

  @override
  String get memexTopUpCustomEstimate => '按输入金额计算预计处理量';

  @override
  String get memexCustomAmount => '自定义金额';

  @override
  String get memexViewHistory => '使用记录';

  @override
  String memexBalanceLabel(Object amount) {
    return '余额: $amount';
  }

  @override
  String get memexConfirmPassword => '确认密码';

  @override
  String get memexPasswordMismatch => '两次密码不一致';

  @override
  String memexPayAmount(Object amount) {
    return '充值 $amount';
  }

  @override
  String get modelIdLabel => '模型';

  @override
  String get modelIdHelper => '例如 gemini-3.1-pro-preview、gpt-4o';

  @override
  String get fetchingModels => '正在获取模型列表...';

  @override
  String get fetchModelsButton => '获取模型列表';

  @override
  String get enterApiKeyFirst => '请先填写 API Key 以获取模型列表';

  @override
  String get apiKeyLabel => 'API Key';

  @override
  String get baseUrlLabel => 'API 地址';

  @override
  String get advancedSettings => '高级设置';

  @override
  String get testConnectionSuccess => '连接成功';

  @override
  String get testConnectionFailed => '连接失败';

  @override
  String get testTypeText => '文本';

  @override
  String get testTypeVision => '视觉';

  @override
  String get testButton => '测试';

  @override
  String get testing => '测试中...';

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
  String get warning => '配置未完成';

  @override
  String get invalidConfigurationWarning =>
      '当前配置尚未完成（例如：缺少 API Key 或 Model ID）。你可以先保存，稍后再补全配置。是否继续？';

  @override
  String invalidModelConfigDetailed(Object agentId, Object configKey) {
    return '智能体“$agentId”需要有效的模型配置 (Key: “$configKey”) 才能运行。请在设置中更新并补全对应的参数。';
  }

  @override
  String get discardChangesTitle => '离开此页面？';

  @override
  String get discardChangesMessage => '如果您做了更改，请先保存后再离开。';

  @override
  String get discardButton => '放弃';

  @override
  String get chooseLanguage => '选择语言';

  @override
  String get chooseAvatar => '选择头像';

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

  @override
  String get proModelHint => '此模型需要 ChatGPT Pro/Plus 订阅才能使用。';

  @override
  String get searchKnowledgeBase => '搜索知识库...';

  @override
  String get searchKnowledgeHint => '输入关键词搜索文件名或内容';

  @override
  String noSearchResults(Object query) {
    return '未找到 \"$query\" 相关结果';
  }

  @override
  String get onlyMarkdownPreview => '仅支持 Markdown 文件预览';

  @override
  String get backupAndRestore => '备份与恢复';

  @override
  String get createBackup => '创建备份';

  @override
  String get restoreBackup => '恢复备份';

  @override
  String get backupDescription =>
      '将所有数据（卡片、知识库、洞察、设置）打包为 .memex 文件。可通过分享保存到 iCloud Drive、Google Drive 或任意位置。';

  @override
  String get restoreDescription => '选择 .memex 备份文件恢复所有数据。这将覆盖当前数据。';

  @override
  String get selectBackupFile => '选择备份文件';

  @override
  String get estimatedSize => '预估大小';

  @override
  String get backupComplete => '备份已创建';

  @override
  String backupFailed(Object error) {
    return '备份失败: $error';
  }

  @override
  String get confirmRestore => '确认恢复';

  @override
  String get confirmRestoreMessage =>
      '恢复将覆盖当前所有数据，包括卡片、知识库、洞察和设置。此操作不可撤销，确定继续？';

  @override
  String get restoreComplete => '恢复完成';

  @override
  String get restoreRestartHint => '数据已恢复，请重启应用以使所有更改生效。';

  @override
  String restoreFailed(Object error) {
    return '恢复失败: $error';
  }

  @override
  String get invalidBackupFile => '无效的备份文件，请选择 .memex 文件。';

  @override
  String get automaticBackup => '自动备份';

  @override
  String get autoBackupDescription => '开启后，Memex 会在启动或回到前台时检查，每天最多创建一次本地时间点快照。';

  @override
  String get backupSensitiveSettingsHint => '备份包含设置和模型服务商密钥，请只保存到你信任的位置。';

  @override
  String get backupLocation => '位置';

  @override
  String get backupLocationDetails => '位置详情';

  @override
  String get backupLocationSummary => '应用中显示';

  @override
  String get backupLocationFullPath => '完整路径';

  @override
  String get backupLocationUri => '文件夹授权 URI';

  @override
  String get copyBackupLocationPath => '复制路径';

  @override
  String get backupLocationCopied => '备份位置已复制';

  @override
  String androidBackupLocationSelected(Object folderName) {
    return '已选文件夹：$folderName';
  }

  @override
  String get iosICloudBackupLocation => 'iCloud 云盘 > Memex > Backups';

  @override
  String get iosAppDocumentsBackupLocation =>
      '文件 > 我的 iPhone > Memex > Backups';

  @override
  String get autoBackupStatus => '状态';

  @override
  String get noAutoBackupYet => '还没有自动备份';

  @override
  String lastBackupAt(Object time) {
    return '上次备份：$time';
  }

  @override
  String get autoBackupRetention => '保留';

  @override
  String autoBackupRetentionDays(Object days) {
    return '$days 天';
  }

  @override
  String get autoBackupRetentionForever => '永久保留';

  @override
  String get autoBackupMaxSize => '空间上限';

  @override
  String autoBackupRetentionLimitHint(Object size) {
    return '自动清理会让自动快照总大小不超过 $size。安全快照和手动导出备份会单独保留。';
  }

  @override
  String get createSnapshotNow => '立即备份';

  @override
  String get backupLocationMenu => '更改位置';

  @override
  String get defaultBackupLocation => '默认备份文件夹';

  @override
  String get defaultBackupLocationAndroidDesc => '使用 Memex 的应用专属外部目录，不需要存储权限。';

  @override
  String get chooseBackupLocation => '选择备份文件夹';

  @override
  String get chooseBackupLocationAndroidDesc =>
      '使用 Android 系统选择器选择文件夹，并授予 Memex 持久访问权限。';

  @override
  String get storedBackups => '已保存备份';

  @override
  String get noStoredBackups => '创建第一个自动快照后会显示在这里。';

  @override
  String get backupTypeAutoSnapshot => '自动快照';

  @override
  String get backupTypeSafetySnapshot => '安全快照';

  @override
  String get backupTypeManualBackup => '手动备份';

  @override
  String get refresh => '刷新';

  @override
  String get restoreThisBackup => '恢复此备份';

  @override
  String get deleteThisBackup => '删除此备份';

  @override
  String get confirmDeleteBackup => '删除备份？';

  @override
  String confirmDeleteBackupMessage(Object fileName) {
    return '删除 $fileName？这会移除已保存的备份文件，且无法撤销。';
  }

  @override
  String backupDeleted(Object fileName) {
    return '备份已删除：$fileName';
  }

  @override
  String backupDeleteFailed(Object error) {
    return '无法删除备份：$error';
  }

  @override
  String get creatingSafetySnapshot => '正在创建安全快照...';

  @override
  String autoBackupCreated(Object fileName) {
    return '快照已创建：$fileName';
  }

  @override
  String backupLocationFailed(Object error) {
    return '无法更新备份位置：$error';
  }

  @override
  String get backupImportCreatedAt => '创建时间';

  @override
  String get backupImportSourceVersion => '来源版本';

  @override
  String get backupImportFlavor => '构建渠道';

  @override
  String get backupLegacyFormat => '旧版备份（无 manifest）';

  @override
  String get restoreInProgress => '正在恢复备份...';

  @override
  String get dataStorage => '数据存储';

  @override
  String get dataStorageDescriptionAndroid => '选择自定义文件夹存放工作区数据，卸载重装后仍可保留。';

  @override
  String get dataStorageDescriptionIOS => '开启 iCloud 可在设备间同步工作区，并在卸载重装后保留数据。';

  @override
  String get storageLocationApp => '应用存储';

  @override
  String get storageLocationAppDesc => '数据存储在应用内部，卸载时会被清除。';

  @override
  String get storageLocationCustom => '设备存储（自定义文件夹）';

  @override
  String get storageLocationCustomDesc => '将数据存储在你选择的文件夹中，卸载重装后若该文件夹仍在则可保留数据。';

  @override
  String get storageLocationICloud => '存储到 iCloud';

  @override
  String get storageLocationICloudDesc => '在 Apple 设备间同步工作区，卸载重装后数据可保留。';

  @override
  String storageLocationCurrent(Object location) {
    return '当前：$location';
  }

  @override
  String get icloudRequiresCapability => '请先登录 iCloud 账号并开启 iCloud Drive 同步功能。';

  @override
  String get loadingFromICloud => '正在从 iCloud 恢复数据…';

  @override
  String get switchingToICloud => '正在切换到 iCloud 存储…';

  @override
  String get switchingStorage => '正在切换存储…';

  @override
  String get customFolderAccessDenied => '无法读写该文件夹，请授予存储权限或选择其他位置。';

  @override
  String get configured => '已配置';

  @override
  String get apiKeyNotSet => 'API Key 未设置 — 点击配置';

  @override
  String get bottomNavTimeline => '记录';

  @override
  String get bottomNavLibrary => '知识库';

  @override
  String get aiGeneratedLabel => 'AI 生成';

  @override
  String sourceTraceWithCount(Object count) {
    return '追溯（$count）';
  }

  @override
  String get deleteAccount => '删除账户';

  @override
  String get deleteAccountDesc => '永久删除所有本地数据并重置应用。';

  @override
  String get deleteAccountConfirmTitle => '确认删除账户？';

  @override
  String get deleteAccountConfirmMessage =>
      '此操作将永久删除您的所有数据，包括时间线卡片、知识库、录音和设置。此操作不可撤销。';

  @override
  String deleteAccountTypeName(Object name) {
    return '输入 \"$name\" 以确认';
  }

  @override
  String get deleteAccountTypeHint => '输入用户名以确认';

  @override
  String get llmConsentTitle => '数据共享同意';

  @override
  String llmConsentMessage(Object provider) {
    return '为了启用 AI 功能，Memex 需要将您的数据发送至 $provider 进行处理，包括：\n\n• 您输入的文字（笔记、语音转录）\n• 照片元数据和提取的文字（OCR）\n• 健康与健身摘要\n• 时间线卡片内容\n\n数据将直接从您的设备发送至 $provider，Memex 不会通过任何其他服务器存储或中转您的数据。\n\n请查阅 $provider 的隐私政策了解其数据处理方式。\n\n您是否同意将数据发送至 $provider 进行 AI 处理？';
  }

  @override
  String get llmConsentAgree => '我同意';

  @override
  String get llmConsentDecline => '拒绝';

  @override
  String get customAgents => '自定义 Agent';

  @override
  String get noCustomAgents => '暂无自定义 Agent 配置。';

  @override
  String get deleteAgent => '删除 Agent';

  @override
  String deleteAgentConfirm(Object name) {
    return '确定删除自定义 Agent「$name」？';
  }

  @override
  String get deleted => '已删除';

  @override
  String get saved => '已保存';

  @override
  String get newAgent => '新建 Agent';

  @override
  String get editAgent => '编辑 Agent';

  @override
  String get agentName => 'Agent 名称';

  @override
  String get agentNameHint => 'my-custom-agent';

  @override
  String get agentNameRequired => '必填';

  @override
  String get agentNameInvalid => '仅支持字母、数字和横线';

  @override
  String get agentNameExists => '名称已存在';

  @override
  String get hostAgentType => '宿主 Agent 类型';

  @override
  String get skillDirectory => 'Skill 目录';

  @override
  String get skillDirInvalid => '必须是相对路径（不能以 / 开头或包含 ..）';

  @override
  String get workingDirectory => '工作目录';

  @override
  String get workingDirectoryHint => '留空使用工作区默认路径';

  @override
  String get llmConfig => 'LLM 配置';

  @override
  String get eventType => '事件类型';

  @override
  String get executionMode => '执行模式';

  @override
  String get executionModeAsync => '异步';

  @override
  String get executionModeSync => '同步';

  @override
  String get dependsOn => '执行依赖';

  @override
  String get dependsOnHint => '选择依赖项';

  @override
  String get priority => '优先级';

  @override
  String get maxRetries => '最大重试次数';

  @override
  String get systemPromptLabel => '系统提示词（可选）';

  @override
  String get systemPromptHint => '追加到宿主 Agent 系统提示词之后';

  @override
  String get eventSerializer => '事件序列化器';

  @override
  String get eventSerializerDefault => '默认（XML）';

  @override
  String get enabledLabel => '启用';

  @override
  String get skillsManagement => 'Skills 管理';

  @override
  String get skillsManagementEmpty => '暂无 Skill';

  @override
  String get downloadSkill => '下载 Skill';

  @override
  String get downloadFile => '下载文件';

  @override
  String get downloading => '下载中...';

  @override
  String get downloadSuccess => 'Skill 下载成功';

  @override
  String downloadFailed(Object error) {
    return '下载失败：$error';
  }

  @override
  String get deleteConfirm => '确认删除';

  @override
  String deleteConfirmMessage(String name) {
    return '确定要删除「$name」吗？';
  }

  @override
  String get invalidUrl => '请输入有效的 URL';

  @override
  String get urlHint => 'https://example.com/skill.zip';

  @override
  String get newFolder => '新建文件夹';

  @override
  String get newFile => '新建文件';

  @override
  String get folderName => '文件夹名称';

  @override
  String get fileName => '文件名';

  @override
  String get nameRequired => '名称不能为空';

  @override
  String get nameInvalid => '名称不能包含 / 或 ..';

  @override
  String createFailed(Object error) {
    return '创建失败：$error';
  }

  @override
  String get fileContent => '文件内容';

  @override
  String get saveSuccess => '保存成功';

  @override
  String downloadToCurrentDir(String dir) {
    return 'zip 将解压到当前目录：$dir';
  }

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get privacyPolicyDesc => '了解 Memex 如何处理您的数据';

  @override
  String get llmAuthError => 'API 认证失败，请在设置中检查 LLM 配置。';

  @override
  String get llmBadRequestError => '请求被 LLM 服务商拒绝，当前模型可能不支持该输入格式。';

  @override
  String get llmRateLimitError => 'API 调用频率超限，请稍后再试。';

  @override
  String get llmServerError => 'LLM 服务暂时不可用，请稍后再试。';

  @override
  String get llmNetworkError => '网络连接失败，请检查网络设置。';

  @override
  String get llmUnknownError => '处理内容时发生未知错误。';

  @override
  String get llmErrorDialogTitle => '处理失败';

  @override
  String get goToModelConfig => '前往设置';

  @override
  String get speechModelDownloadTitle => '下载语音识别模型';

  @override
  String speechModelDownloadDesc(Object sizeMB) {
    return '首次使用语音转文字需要下载离线模型（约${sizeMB}MB）。\n\n下载后语音识别将完全在本地运行，无需联网。';
  }

  @override
  String get speechModelStartDownload => '开始下载';

  @override
  String get speechModelChooseSource => '选择下载线路：';

  @override
  String get speechModelChinaMirror => '🇨🇳 国内线路（推荐）';

  @override
  String get speechModelGithub => '🌐 GitHub（海外线路）';

  @override
  String get speechModelDownloading => '正在下载模型...';

  @override
  String get speechModelConnecting => '连接中...';

  @override
  String get deleteSpeechModel => '删除语音识别模型';

  @override
  String get confirmDeleteSpeechModelMessage =>
      '确定要删除已下载的本地语音识别模型文件吗？下次使用本地语音转文字时会重新下载。';

  @override
  String get speechModelDeletedSuccess => '语音识别模型文件已删除';

  @override
  String get speechModelNotDownloaded => '未找到已下载的语音识别模型文件';

  @override
  String speechModelDeleteFailed(Object error) {
    return '删除语音识别模型文件失败: $error';
  }

  @override
  String get speechTranscribing => '正在识别...';

  @override
  String get speechNoResult => '未识别到语音内容';

  @override
  String get useLocalSpeechToTextTitle => '使用本地语音转文字';

  @override
  String get useLocalSpeechToTextDesc =>
      '开启时，会先在设备上把音频转成文字再发送，这适合不支持音频输入的模型。关闭后，会直接把原始音频发送给模型处理。';

  @override
  String get pendingAiProcessingHint => '配置 AI 模型以自动整理此记录';

  @override
  String get demoWelcome => '欢迎来到 Memex！\n快速了解 AI 如何帮你整理记录。';

  @override
  String get demoTapAdd => '点击这里创建你的第一条记录';

  @override
  String get demoTapSend => '点击发送你的第一条记录';

  @override
  String get demoTapCard => '点击查看 AI 如何整理你的记录';

  @override
  String get demoDetailHint => '这里是 AI 整理后的记录详情。可以自由浏览，看完后返回继续导览。';

  @override
  String get demoTapInsight => '点击查看 AI 生成的洞察';

  @override
  String get demoTapInsightUpdate => '点击生成你的专属洞察';

  @override
  String get demoTapKnowledge => '查看自动整理的知识文件';

  @override
  String get demoDone => '开始记录你的生活吧。';

  @override
  String get demoStartTour => '开始体验';

  @override
  String get demoGetStarted => '开始使用';

  @override
  String get demoSkip => '跳过';

  @override
  String get demoPrefillText => '你好 Memex！这是我的第一条记录 🎉';

  @override
  String get visionBadge => '视觉';

  @override
  String get notMultimodalHint =>
      'Memex依赖模型多模态能力用于媒体分析，如果您的记录内容包含图片，请确保您配置的模型支持图片输入。';

  @override
  String get defaultModelPrefix => '默认使用';

  @override
  String get recommendedBadge => '推荐';

  @override
  String get readOnlyBadge => '对话';

  @override
  String get switchCompanion => '切换角色';

  @override
  String get personaChatInputHint => '输入消息...';

  @override
  String get today => '今天';

  @override
  String get tomorrow => '明天';

  @override
  String get yesterday => '昨天';

  @override
  String get showInsightTextTitle => '显示 Memex 洞察评论';

  @override
  String get showInsightTextDesc => '是否在卡片详情的评论区显示 Memex 洞察评论。';

  @override
  String get enableCharacterCommentTitle => '角色自动评论';

  @override
  String get enableCharacterCommentDesc => '角色自动对新记录发表评论。';

  @override
  String get maxCommentCharactersTitle => '最大评论角色数';

  @override
  String get maxCommentCharactersDesc => '每条记录最多几个角色参与评论。';

  @override
  String replyTo(String name) {
    return '回复 $name';
  }

  @override
  String get cdnSignalsComments => '收到新回复';

  @override
  String get cdnSignalsInsight => '生成了新洞察';

  @override
  String get cdnSignalsBoth => '有新回复和洞察';

  @override
  String get untitledCard => '未命名卡片';

  @override
  String get locationContextTitle => '位置上下文';

  @override
  String get locationContextDescription => '为 Agent 对话提供当前城市与街区上下文';

  @override
  String get locationContextAttachTitle => '为对话附加当前位置';

  @override
  String get locationContextAttachDesc =>
      '使用设备 GPS 和逆地理编码，为 Agent 提供城市、区县和街区上下文。';

  @override
  String get reverseGeocodingProvider => '逆地理编码服务商';

  @override
  String get amapProviderName => '高德地图';

  @override
  String get amapApiKey => '高德地图 API Key';

  @override
  String get amapGcj02Note => '高德地图使用 GCJ-02 坐标；设备 GPS 会先转换后再逆地理编码。';

  @override
  String get contextGranularity => '上下文粒度';

  @override
  String get granularityCity => '城市';

  @override
  String get granularityDistrict => '区县';

  @override
  String get granularityNeighborhood => '街区';

  @override
  String get granularityStreet => '街道';

  @override
  String get granularityFullAddress => '完整地址候选';

  @override
  String get locationFreshness => '位置新鲜度';

  @override
  String minutesShort(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String get oneHour => '1 小时';

  @override
  String get testCurrentLocation => '测试当前位置';

  @override
  String locationTestFailed(String error) {
    return '失败：$error';
  }

  @override
  String get locationDebugGps => 'GPS';

  @override
  String get locationDebugReverseGeocode => '逆地理编码';

  @override
  String get locationDebugProvider => '服务商';

  @override
  String get locationDebugAgentContext => 'Agent 上下文';

  @override
  String get locationDebugSource => '来源';

  @override
  String get locationDebugAddressSummary => '地址摘要';

  @override
  String get locationDebugFullAddress => '完整地址';

  @override
  String get locationDebugCoordinates => '坐标';

  @override
  String get locationDebugAccuracy => '精度';

  @override
  String get locationDebugReason => '原因';

  @override
  String get locationDebugOk => '成功';

  @override
  String get locationDebugUnavailable => '不可用';

  @override
  String get locationDebugInjected => '已注入';

  @override
  String get locationDebugNotInjected => '未注入';

  @override
  String get locationStatusUpdatedAt => '更新时间';

  @override
  String get locationStatusSuccessTitle => '当前位置已可用';

  @override
  String get locationStatusSuccessBody => '当位置上下文与对话相关时，Memex 可以附加这段位置摘要。';

  @override
  String get locationStatusApproximateTitle => '仅获得大致位置';

  @override
  String get locationStatusApproximateBody =>
      '当前精度看起来只到城市或区域级别。你可以继续使用，也可以在系统设置中开启精确位置以获得更细的上下文。';

  @override
  String get locationStatusServiceDisabledTitle => '系统定位已关闭';

  @override
  String get locationStatusServiceDisabledBody =>
      'Memex 只使用设备 GPS，不会通过网络或 IP 推测位置。Android 可打开定位设置；iOS 请前往 设置 > 隐私与安全性 > 定位服务 开启。';

  @override
  String get locationStatusPermissionDeniedTitle => '需要允许位置权限';

  @override
  String get locationStatusPermissionDeniedBody =>
      '仅在测试或实际需要位置上下文时允许 Memex 使用位置即可；不会请求始终访问。';

  @override
  String get locationStatusPermissionForeverTitle => '位置权限已被系统阻止';

  @override
  String get locationStatusPermissionForeverBody =>
      '请打开应用设置，重新允许 Memex 使用位置。iOS 选择“使用 App 期间”即可。';

  @override
  String get locationStatusDisabledTitle => '位置上下文未开启';

  @override
  String get locationStatusDisabledBody =>
      '如果希望 Memex 为 Agent 上下文附加设备位置，请打开上方开关并保存。';

  @override
  String get locationStatusGeocodeUnavailableTitle => 'GPS 可用，但地址解析失败';

  @override
  String get locationStatusGeocodeUnavailableBody =>
      'Memex 已拿到坐标，但不会把纯 GPS 坐标注入给 Agent。请检查逆地理编码服务商后再试。';

  @override
  String get locationStatusUnavailableTitle => '位置不可用';

  @override
  String get locationStatusUnavailableBody => '请检查系统定位服务和应用权限，然后再次测试。';

  @override
  String get allowLocationPermissionButton => '允许位置权限';

  @override
  String get openAppSettingsButton => '打开应用设置';

  @override
  String get openLocationSettingsButton => '开启系统定位';

  @override
  String get locationSettingsOpenFailed => '无法打开系统设置。';

  @override
  String locationActionFailed(String error) {
    return '位置操作失败：$error';
  }

  @override
  String get settingsSearchPlaceholder => '搜索设置项...';

  @override
  String get settingsSearchEmpty => '未找到匹配的设置项';

  @override
  String get importCharacterCard => '导入角色卡';

  @override
  String get firstMessageLabel => '首条消息';

  @override
  String get firstMessageHint => '角色首次对话时发送的问候语（可选）';

  @override
  String get systemPromptOverrideLabel => '系统提示词覆盖';

  @override
  String get systemPromptOverrideHint => '覆盖默认系统提示词（高级，可选）';

  @override
  String get postHistoryInstructionsLabel => '历史后指令';

  @override
  String get postHistoryInstructionsHint => '在对话历史之后、回复之前注入的指令（可选）';

  @override
  String get mesExampleLabel => '对话示例';

  @override
  String get mesExampleHint => '角色对话风格示例（可选）';

  @override
  String get worldBookTitle => '世界书';

  @override
  String get worldBookSubtitle => '触发关键词时注入的背景知识';

  @override
  String get characterMemoryTitle => '角色记忆';

  @override
  String get characterMemorySubtitle => '角色与用户之间的关系动态和互动记忆';

  @override
  String get addTooltip => '添加';

  @override
  String get constantBadge => '常驻';

  @override
  String worldEntryFallbackName(Object index) {
    return '条目 $index';
  }

  @override
  String keywordsPrefix(Object keys) {
    return '关键词: $keys';
  }

  @override
  String memoryFallbackName(Object index) {
    return '记忆 $index';
  }

  @override
  String get addWorldEntry => '添加世界书条目';

  @override
  String get editWorldEntry => '编辑世界书条目';

  @override
  String get commentTitleLabel => '备注/标题';

  @override
  String get entryDescriptionHint => '条目说明（可选）';

  @override
  String get triggerKeywordsLabel => '触发关键词';

  @override
  String get triggerKeywordsHint => '逗号分隔，如: 魔法, 咒语';

  @override
  String get contentLabel => '内容';

  @override
  String get worldEntryContentHint => '当关键词触发时注入的背景知识';

  @override
  String get enabledCheckbox => '启用';

  @override
  String get addMemory => '添加记忆';

  @override
  String get editMemory => '编辑记忆';

  @override
  String get memoryLabelField => '标签';

  @override
  String get memoryLabelHint => '记忆的唯一标识，如: 称呼偏好';

  @override
  String get memoryContentHint => '记忆内容';

  @override
  String get salienceLabel => '重要性: ';

  @override
  String get labelCannotBeEmpty => '标签不能为空';

  @override
  String importSuccess(Object name) {
    return '$name 导入成功';
  }

  @override
  String importFailed(Object error) {
    return '导入失败: $error';
  }

  @override
  String get supportedFormats => '支持的格式';

  @override
  String get tavernImportDescription =>
      '• SillyTavern V2 角色卡 (.json)\n• 内嵌角色卡的 PNG 图片 (.png)\n\n导入后会自动映射角色设定、世界书等字段到 Memex 角色格式。';

  @override
  String get pickCharacterFile => '选择角色卡文件';

  @override
  String get repickFile => '重新选择文件';

  @override
  String get personaSettingSection => '角色设定';

  @override
  String get systemPromptSection => '系统提示词';

  @override
  String worldEntriesCount(Object count) {
    return '世界书: $count 条';
  }

  @override
  String fileLabel(Object filename) {
    return '文件: $filename';
  }

  @override
  String conflictWarning(Object names) {
    return '已存在同名角色: $names。继续导入将创建新角色，不会覆盖已有角色。';
  }

  @override
  String get setPrimaryCompanionTitle => '设为主要陪伴角色';

  @override
  String get setPrimaryCompanionSubtitle => '导入后自动设为你的主要陪伴角色';

  @override
  String get confirmImport => '确认导入';

  @override
  String get chatBackground => '聊天背景';

  @override
  String get chooseChatBackgroundImage => '选择聊天背景图';

  @override
  String get earlyUpdateSettingsTitle => 'Early 体验版更新';

  @override
  String get earlyUpdateSettingsDesc =>
      '从 GitHub 预发布版本中检测匹配当前 Early 渠道的 APK，下载后交给 Android 系统安装器安装。';

  @override
  String get earlyUpdateUnsupported => 'Early 更新仅支持 Android Early 包。';

  @override
  String get earlyUpdateAutoCheckTitle => '自动检测更新';

  @override
  String get earlyUpdateAutoCheckDesc => '启动时检测，每 12 小时最多一次。';

  @override
  String get earlyUpdateWifiOnlyTitle => '仅在 Wi-Fi 下载';

  @override
  String get earlyUpdateWifiOnlyDesc => '使用移动数据时跳过更新下载。';

  @override
  String get earlyUpdateAutoInstallTitle => '自动下载并安装';

  @override
  String get earlyUpdateAutoInstallDesc => '发现新版本后自动下载，并打开 Android 系统安装器。';

  @override
  String get earlyUpdateCheckNow => '立即检查';

  @override
  String get earlyUpdateChecking => '正在检查 GitHub 预发布版本...';

  @override
  String get earlyUpdateSkippedMobile => '已跳过：当前开启了仅 Wi-Fi 下载。';

  @override
  String get earlyUpdateNoUpdate => '当前已经是最新 Early 版本。';

  @override
  String earlyUpdateFound(Object version, Object build) {
    return '发现 Early 版本 $version+$build。';
  }

  @override
  String get earlyUpdateDownloadAndInstall => '下载并安装';

  @override
  String get earlyUpdateDownloadInProgress => '正在下载更新...';

  @override
  String earlyUpdateDownloadingPercent(Object percent) {
    return '正在下载更新：$percent%';
  }

  @override
  String get earlyUpdateDownloadReadyToInstall => '更新包已下载，可直接安装。';

  @override
  String get earlyUpdateInstallDownloadedPackage => '安装已下载包';

  @override
  String get earlyUpdateClearDownloadedPackage => '清除下载包';

  @override
  String get earlyUpdateClearDownloadedPackageSuccess => '已清除下载包。';

  @override
  String get earlyUpdateInstallStarted => '已打开 Android 系统安装器。';

  @override
  String get earlyUpdateInstallPermissionRequired =>
      '请允许 Memex 安装未知来源应用，然后再次点击下载并安装。';

  @override
  String earlyUpdateLastChecked(Object time) {
    return '上次检查：$time';
  }

  @override
  String earlyUpdateCheckFailed(Object error) {
    return '检查更新失败：$error';
  }

  @override
  String get earlyUpdateDialogTitle => '发现 Early 更新';

  @override
  String get earlyUpdateReleaseNotes => '更新说明';

  @override
  String get dismissAllNotifications => '清除全部';

  @override
  String get dismissByType => '按类型清除';

  @override
  String get dismissTypeSystemAction => '日程提醒';

  @override
  String get dismissTypeClarification => '澄清确认';

  @override
  String get dismissTypeCardUpdate => '卡片更新';

  @override
  String dismissedCount(Object count) {
    return '已清除 $count 条';
  }

  @override
  String get dataImportTitle => '导入文件';

  @override
  String get dataImportSettingsDescription => '把旧文件带进 Memex，再决定要不要整理。';

  @override
  String get dataImportDescription =>
      '可以选择以前的笔记、导出的记录、文档或 ZIP 压缩包。Memex 会先保存一份副本，不会修改原文件；导入后你再决定是否让 Memex 帮你整理。';

  @override
  String get dataImportSelectFiles => '选择要导入的文件';

  @override
  String get dataImportImporting => '正在保存文件...';

  @override
  String get dataImportSuccess => '文件已保存到 Memex';

  @override
  String get dataImportOnlyStored => '文件已保存，暂不进行整理。';

  @override
  String get dataImportQueued => 'Memex 会在后台整理这次导入。';

  @override
  String get dataImportResultTitle => '导入完成';

  @override
  String dataImportResultSummary(Object count) {
    return '已保存 $count 个文件。你可以现在开始整理，也可以先把它们作为原始资料保留。';
  }

  @override
  String dataImportRenamedConflicts(Object count) {
    return '有 $count 个同名项目已自动改名，避免覆盖已有内容。';
  }

  @override
  String dataImportSkippedUnsafeEntries(Object count) {
    return '压缩包中有 $count 个异常项目已跳过，其余内容已正常导入。';
  }

  @override
  String get dataImportChooseProcessing => '整理这些内容';

  @override
  String get dataImportProcessTitle => '要整理这次导入吗？';

  @override
  String dataImportProcessPrompt(Object count) {
    return '这次导入了 $count 个文件。你可以让 Memex 现在帮你整理，也可以只保存原始资料。';
  }

  @override
  String get dataImportProcessKnowledgeBase => '整理到知识库';

  @override
  String get dataImportProcessKnowledgeBaseDesc =>
      '适合文档、资料、笔记、项目素材。Memex 会提取有用信息并归类，方便以后查找和复用。';

  @override
  String get dataImportProcessTimelineCards => '生成时间线记录';

  @override
  String get dataImportProcessTimelineCardsDesc =>
      '适合日记、聊天记录、活动记录、历史导出。Memex 会把有时间意义的内容整理成记录。';

  @override
  String get dataImportImpactNone => 'Memex 只会保存这批原始文件，不会启动 AI 整理。';

  @override
  String get dataImportImpactKnowledgeBase =>
      'Memex 会阅读这批文件，把值得长期保存的信息整理进知识库；不会主动生成时间线记录。';

  @override
  String get dataImportImpactTimelineCards =>
      'Memex 会阅读这批文件，把适合记录生活或事件的内容生成时间线记录；不会主动整理知识库。';

  @override
  String get dataImportImpactBoth =>
      'Memex 会同时尝试生成时间线记录，并把可复用的信息整理进知识库。适合导入比较完整的历史资料。';

  @override
  String get dataImportFinish => '先保存即可';

  @override
  String get noImages => '暂无图片';

  @override
  String get noMessages => '暂无消息';

  @override
  String get sketchContent => '草图内容';

  @override
  String get emptyFolder => '空文件夹';

  @override
  String get usernameAlreadyTaken => '用户名已被占用';

  @override
  String get registrationFailed => '注册失败';

  @override
  String get loginFailed => '登录失败';

  @override
  String get paymentCreationFailed => '无法发起支付';

  @override
  String get completePayment => '完成支付';

  @override
  String get commentReplyToYou => '你';

  @override
  String get commentAuthorUser => '用户';

  @override
  String get commentAuthorAi => 'AI';

  @override
  String get authorizationCancelled => '授权已取消';

  @override
  String timelineWeekNumberLabel(Object week) {
    return '第 $week 周';
  }

  @override
  String get timelineWeekLabel => '周';

  @override
  String get eventCardDefaultTitle => '事件';

  @override
  String get memoryNoLongTermYet => '还没有长期记忆。';

  @override
  String get memoryNoRecentBuffer => '缓冲区中还没有近期记忆。';

  @override
  String get memoryGeneralSubject => '通用';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get timesLabel => '次數';

  @override
  String modelSetAsDefault(Object modelId) {
    return '已將 $modelId 設為預設模型';
  }

  @override
  String get retry => '重試';

  @override
  String get unknownModel => '未知模型';

  @override
  String get notSet => '未設定';

  @override
  String get confirmClear => '確認清除';

  @override
  String get confirmClearTokenMessage => '清除目前使用者？之後需要重新輸入使用者 ID。';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '確認';

  @override
  String get tokenCleared => '已清除使用者';

  @override
  String clearTokenFailed(Object error) {
    return '清除使用者失敗：$error';
  }

  @override
  String get selectDateRangeOptional => '選擇日期範圍（選填）：';

  @override
  String get startDate => '開始日期';

  @override
  String get endDate => '結束日期';

  @override
  String get select => '選擇';

  @override
  String get processLimitOptional => '處理數量限制（選填）';

  @override
  String get leaveEmptyForAll => '留空表示處理全部';

  @override
  String get startProcessing => '開始處理';

  @override
  String get userIdNotFound => '找不到使用者 ID';

  @override
  String createTaskFailed(Object error) {
    return '建立任務失敗：$error';
  }

  @override
  String get reprocessCards => '重新處理卡片';

  @override
  String get reprocessCardsTaskCreated => '已交給 超級智慧體 重新處理';

  @override
  String get reprocessCardsDownstreamMode => '處理範圍';

  @override
  String get reprocessCardsCardOnly => '只處理卡片';

  @override
  String get reprocessCardsCardOnlyDesc => '請 超級智慧體 檢查並重新產生選取的時間線卡片。';

  @override
  String get reprocessCardsRerunDownstream => '卡片與相關後續';

  @override
  String get reprocessCardsRerunDownstreamDesc =>
      '請 超級智慧體 在需要時一併考慮相關的 PKM 與洞察更新。';

  @override
  String get reanalyzeMediaAssets => '重新讀取媒體附件';

  @override
  String get reanalyzeMediaAssetsDesc => '重新產生卡片時，請 超級智慧體 在需要時再次查看附件內容。';

  @override
  String get regenerateComments => '重新產生評論';

  @override
  String get regenerateCommentsTaskCreated => '重新產生評論任務已建立，正在背景處理';

  @override
  String get rebuildSearchIndex => '重建搜尋索引';

  @override
  String get rebuildSearchIndexSuccess => '搜尋索引已重建完成';

  @override
  String get rebuildSearchIndexFailed => '搜尋索引重建失敗';

  @override
  String get clearData => '清除資料';

  @override
  String get confirmClearDataMessage => '確定要清除資料嗎？';

  @override
  String get confirmClearDataDeletesWorkspaceMessage =>
      '目前使用者的所有本機工作區資料都會被刪除，包括卡片、媒體、知識檔案、洞察、記憶、聊天記錄與系統狀態。\n\n此操作無法復原！';

  @override
  String get clearFailedAgentContexts => '清除失敗的對話上下文';

  @override
  String get confirmClearFailedAgentContextsMessage =>
      '清除 Insight 與 日程智慧體 已儲存的對話上下文？這適用於切換模型後，先前的 智慧體 訊息不再相容的情況。Facts、卡片、知識庫、記憶與模型設定不會被刪除。';

  @override
  String failedAgentContextsCleared(Object count) {
    return '已清除 $count 個已儲存的對話上下文';
  }

  @override
  String clearFailedAgentContextsFailed(Object error) {
    return '清除對話上下文失敗：$error';
  }

  @override
  String get cloneToTestUser => '複製為測試使用者';

  @override
  String get confirmCloneToTestUserMessage =>
      '將目前工作區複製到新的本機測試使用者並切換過去。不會複製 智慧體 執行狀態，目前使用者資料不會被修改。';

  @override
  String get testUserIdLabel => '測試使用者 ID';

  @override
  String get testUserIdHelper => '請使用英文字母、數字、連字號或底線。';

  @override
  String get testUserIdInvalid => '只能使用英文字母、數字、連字號或底線。';

  @override
  String get overwriteExistingTestUser => '覆蓋同名測試使用者';

  @override
  String testUserCloneSuccess(Object userId) {
    return '已切換到測試使用者 $userId';
  }

  @override
  String testUserCloneFailed(Object error) {
    return '複製測試使用者失敗：$error';
  }

  @override
  String get dataClearedSuccess => '資料已成功清除';

  @override
  String clearDataFailed(Object error) {
    return '清除資料失敗：$error';
  }

  @override
  String get personalCenter => '個人中心';

  @override
  String get viewLogs => '查看日誌';

  @override
  String get systemAuthorization => '系統授權';

  @override
  String get aiCharacterConfig => 'AI 角色設定';

  @override
  String get modelConfig => '模型設定';

  @override
  String get agentConfig => '智慧體 設定';

  @override
  String get experimentalLab => '實驗室';

  @override
  String get experimentalLabDescription => '仍在實驗中的功能，之後可能調整或移動。';

  @override
  String get modelUsageStats => '模型使用統計';

  @override
  String get asyncTaskList => '非同步任務列表';

  @override
  String get clearLocalToken => '清除使用者';

  @override
  String get insightCardTemplates => '洞察卡片範本';

  @override
  String get timelineCardTemplates => '時間線 卡片範本';

  @override
  String get logViewer => '日誌檢視器';

  @override
  String get autoRefresh => '自動重新整理';

  @override
  String get lineCount => '行數：';

  @override
  String get all => '全部';

  @override
  String get schedule => '日程';

  @override
  String get appLockConfig => '應用程式鎖定設定';

  @override
  String loadStatsFailed(Object error) {
    return '載入統計資料失敗：$error';
  }

  @override
  String get overview => '概覽';

  @override
  String get daily => '每日';

  @override
  String get modelStatsByAgent => '按 智慧體 統計';

  @override
  String get detail => '詳情';

  @override
  String get date => '日期';

  @override
  String get agent => '智慧體';

  @override
  String get noData => '暫無資料';

  @override
  String get totalCalls => '總呼叫次數';

  @override
  String get calls => '呼叫';

  @override
  String callsCount(Object count) {
    return '$count 次呼叫';
  }

  @override
  String get selectDateRange => '選擇日期範圍';

  @override
  String get totalTokens => '總 權杖';

  @override
  String get cacheRate => '快取命中率';

  @override
  String get promptTokens => '提示詞 權杖';

  @override
  String get completionTokens => '補全 權杖';

  @override
  String get cachedTokens => '快取 權杖';

  @override
  String get thoughtTokens => '思考 權杖';

  @override
  String get prompt => '提示詞';

  @override
  String get completion => '補全';

  @override
  String get cached => '快取';

  @override
  String get thought => '思考';

  @override
  String get model => '模型';

  @override
  String get scene => '場景';

  @override
  String get sceneId => '場景 ID';

  @override
  String get tokenUsage => '權杖 用量';

  @override
  String get handler => '處理器';

  @override
  String get modelBreakdown => '模型拆分';

  @override
  String get callDetails => '呼叫詳情';

  @override
  String recordDetailsTitle(Object scene) {
    return '記錄詳情：$scene';
  }

  @override
  String saveLlmConfigFailed(Object error) {
    return '儲存 LLM 設定失敗：$error';
  }

  @override
  String get webHtmlPreviewUnavailable => 'Web 端暫未支援 HTML 預覽，請在行動裝置查看。';

  @override
  String saveUserInfoFailed(Object error) {
    return '儲存使用者資訊失敗：$error';
  }

  @override
  String get totalEstimatedCost => '總預估費用';

  @override
  String get close => '關閉';

  @override
  String get totalTokenConsumption => '總 權杖 消耗';

  @override
  String get dataLoadFailedRetry => '資料載入失敗，請稍後重試。';

  @override
  String get timelineLoadFailedRetry => '時間線載入失敗，請稍後重試。';

  @override
  String get newPerspective => '新的視角';

  @override
  String get startPoint => '起點';

  @override
  String get endPoint => '終點';

  @override
  String get originalInput => '原始輸入';

  @override
  String get referenceContent => '引用內容';

  @override
  String referenceWithTitle(Object title) {
    return '引用：$title';
  }

  @override
  String get actionCenterTitle => '待處理事項';

  @override
  String get noPendingActions => '目前沒有待處理的動作';

  @override
  String get clarificationNeeded => 'Memex 想確認一下';

  @override
  String get clarificationTextHint => '輸入一個簡短回答';

  @override
  String get clarificationTextRequired => '請先補充一個簡短回答';

  @override
  String get clarificationAnswered => '已回答';

  @override
  String clarificationAnswerPrefix(Object answer) {
    return '已回答：$answer';
  }

  @override
  String get answerSaved => '回答已儲存';

  @override
  String get clarificationOtherAnswer => '手動輸入';

  @override
  String get clarificationNotSure => '不知道／不方便說';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get footprintMap => '足跡地圖';

  @override
  String get waypointPlaces => '途經地點';

  @override
  String get unknownPlace => '未知地點';

  @override
  String get releaseToSend => '放開即可傳送';

  @override
  String get selectFromAlbum => '從相簿選擇';

  @override
  String get clipboardPreviewTitle => '新剪貼簿內容';

  @override
  String get clipboardPreviewImageTitle => '剪貼簿圖片';

  @override
  String get clipboardPreviewImageDescription => '可加入輸入框';

  @override
  String get clipboardPreviewUnprocessed => '尚未貼上';

  @override
  String get clipboardPreviewPasteToInput => '貼到輸入框';

  @override
  String get clipboardPreviewAddImageToInput => '加入圖片';

  @override
  String get clipboardPreviewImageFailed => '無法讀取剪貼簿圖片';

  @override
  String get tellAiWhatHappened => '告訴 AI 發生了什麼...';

  @override
  String recordingWithDuration(Object duration) {
    return '錄音中：$duration';
  }

  @override
  String get playing => '播放中...';

  @override
  String get sendLabel => '傳送';

  @override
  String attachedImagesMessage(Object count) {
    return '已傳送 $count 張圖片';
  }

  @override
  String get noTaskData => '暫無任務資料';

  @override
  String createdAtDate(Object date) {
    return '建立：$date';
  }

  @override
  String updatedAtDate(Object date) {
    return '更新：$date';
  }

  @override
  String durationLabel(Object duration) {
    return '耗時：$duration';
  }

  @override
  String retryCount(Object count) {
    return '重試：$count';
  }

  @override
  String get loadDetailFailedRetry => '載入詳情失敗，請稍後重試';

  @override
  String get loadFailed => '載入失敗';

  @override
  String loadHistoryFailed(Object error) {
    return '載入歷史記錄失敗：$error';
  }

  @override
  String get reload => '重新載入';

  @override
  String get aiInsightDetail => '洞察詳情';

  @override
  String relatedRecordsCount(Object count) {
    return '關聯記錄（$count）';
  }

  @override
  String get noRelatedRecords => '暫無具體關聯記錄';

  @override
  String get useFingerprintToUnlock => '請使用指紋解鎖';

  @override
  String get locked => '已鎖定';

  @override
  String get wrongPassword => '密碼錯誤';

  @override
  String get enterPassword => '請輸入密碼';

  @override
  String get memexLocked => 'Memex 已鎖定';

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
    return '$date 無記錄';
  }

  @override
  String get footprintPath => '足跡路徑';

  @override
  String get lifeCompositionTable => '生活成分表';

  @override
  String get emotionReframe => '情緒重構';

  @override
  String get chronicleOfThings => '物的編年史';

  @override
  String get goalProgress => '目標進度';

  @override
  String get trendChart => '趨勢圖';

  @override
  String get comparisonChart => '對比圖';

  @override
  String get todayTimeFlow => '今日時間流';

  @override
  String get aiInputHint => '無論是回憶還是當下，我都準備好了...';

  @override
  String get refreshSuperAgentStateTooltip => '清空 Memex 智慧體 上下文';

  @override
  String get refreshSuperAgentStateTitle => '清空 Memex 智慧體 歷史 上下文？';

  @override
  String get refreshSuperAgentStateMessage =>
      '可見聊天記錄會繼續保留，但 Memex 智慧體 的歷史執行 上下文 會被清空，之後會從新的 上下文 開始回覆。持久化記憶、知識庫檔案、卡片等已儲存資料不受影響。適用於 Memex 智慧體 持續運作異常等情況。確定繼續？';

  @override
  String get refreshSuperAgentStateActiveRunMessage =>
      '目前 Memex 智慧體 訊息處理完後才能清空 上下文。';

  @override
  String get refreshSuperAgentStateSuccess => 'Memex 智慧體 上下文 已清空';

  @override
  String refreshSuperAgentStateFailed(Object error) {
    return '清空 Memex 智慧體 上下文 失敗：$error';
  }

  @override
  String get nothingHere => '還沒有任何內容';

  @override
  String get nothingHereHint => '點選下方按鈕建立你的第一張卡片';

  @override
  String get agentProcessing => 'AI 處理中...';

  @override
  String get keepAppOpen => '請不要關閉應用程式';

  @override
  String get activityDetail => '活動詳情';

  @override
  String get noAgentActivityYet => '暫無 智慧體 活動';

  @override
  String get processingEllipsis => '處理中...';

  @override
  String get agentBackgroundTitle => 'Memex 智慧體';

  @override
  String get agentBackgroundPausedTitle => 'Memex 智慧體 已暫停';

  @override
  String get agentBackgroundNeedsAttentionTitle => 'Memex 智慧體 需要處理';

  @override
  String get agentBackgroundStageIdle => '閒置';

  @override
  String get agentBackgroundStageProcessing => '處理中';

  @override
  String get agentBackgroundStageQueued => '排隊中';

  @override
  String get agentBackgroundStageRetrying => '等待重試';

  @override
  String get agentBackgroundStagePaused => '已暫停';

  @override
  String get agentBackgroundStageCompleted => '已完成';

  @override
  String get agentBackgroundStageNeedsAttention => '需要處理';

  @override
  String get agentBackgroundStageAnalyzingMedia => '分析素材中';

  @override
  String get agentBackgroundStageGeneratingCard => '產生卡片中';

  @override
  String get agentBackgroundStageUpdatingKnowledge => '更新知識中';

  @override
  String get agentBackgroundStagePreparingComment => '準備評論中';

  @override
  String get agentBackgroundStageRoutingFollowUps => '分派後續任務中';

  @override
  String agentBackgroundTaskSummary(
      Object running, Object pending, Object retrying) {
    return '執行中 $running，排隊中 $pending，重試中 $retrying';
  }

  @override
  String agentBackgroundTaskDetail(Object count) {
    return '正在處理 $count 個背景任務。';
  }

  @override
  String get agentBackgroundNoTasks => '暫無背景任務。';

  @override
  String get agentBackgroundStarting => '背景處理正在啟動。';

  @override
  String get agentBackgroundCompletedDetail => '所有背景任務已完成。';

  @override
  String get agentBackgroundFailedDetail => '背景處理遇到錯誤。';

  @override
  String get agentBackgroundPausedDetail => '背景處理已暫停，稍後會繼續。';

  @override
  String get agentBackgroundQueuedDetail => '正在等待下一個處理步驟。';

  @override
  String get agentBackgroundRetryingDetail => '目前步驟將自動重試。';

  @override
  String get agentBackgroundAnalyzeMediaDetail => '正在讀取附件和本機上下文。';

  @override
  String get agentBackgroundGeneratingCardDetail => '正在把記錄產生為時間線卡片。';

  @override
  String get agentBackgroundUpdatingKnowledgeDetail => '正在更新本機知識和記憶。';

  @override
  String get agentBackgroundPreparingCommentDetail => '正在準備助手跟進評論。';

  @override
  String get agentBackgroundRoutingFollowUpsDetail => '正在檢查這張卡片的後續動作。';

  @override
  String agentBackgroundPausedStatus(Object summary) {
    return '已暫停 - $summary';
  }

  @override
  String agentBackgroundNeedsAttentionStatus(Object summary) {
    return '需要處理 - $summary';
  }

  @override
  String get settings => '設定';

  @override
  String get languageSettings => '語言';

  @override
  String get languageSettingsDesc => '更改應用程式顯示語言';

  @override
  String get noPendingActionsToast => '目前沒有待處理動作';

  @override
  String get knowledgeNewDiscovery => '知識庫新發現';

  @override
  String discoveredNewInsightsCount(Object count) {
    return '發現了 $count 個新洞察';
  }

  @override
  String updatedExistingInsightsCount(Object count) {
    return '更新了 $count 個現有洞察';
  }

  @override
  String get sectionNewInsights => '發現新洞察';

  @override
  String get sectionUpdatedInsights => '更新現有洞察';

  @override
  String get unnamedInsight => '未命名洞察';

  @override
  String get copiedToClipboard => '已複製到剪貼簿';

  @override
  String get copy => '複製';

  @override
  String get selectedLocation => '已選位置';

  @override
  String get confirmLocationName => '確認位置名稱';

  @override
  String get confirmLocationNameHint => '你可以修改位置名稱（經緯度保持不變）';

  @override
  String get nameLabel => '名稱';

  @override
  String get inputPlaceNameHint => '輸入地點名稱...';

  @override
  String currentCoordinates(Object lat, Object lng) {
    return '目前座標：$lat, $lng';
  }

  @override
  String get confirmLocation => '確認位置';

  @override
  String get welcomeToMemex => '歡迎來到 Memex';

  @override
  String get createUserIdToStart => '請建立你的專屬暱稱';

  @override
  String get userIdLabel => '你的名字／暱稱';

  @override
  String get userIdHint => '請輸入你的名字';

  @override
  String get pleaseEnterUserId => '名字不能為空';

  @override
  String get userIdMaxLength => '名字太長，不能超過 50 個字元';

  @override
  String get startUsing => '下一步';

  @override
  String get userIdTip => '開啟你的專屬記憶。';

  @override
  String get setupModelConfigTitle => '設定 AI 模型';

  @override
  String get setupModelConfigSubtitle =>
      'Memex 需要一個前沿 AI 模型來整理記錄、分析圖片並產生洞察。選擇一種連線方式即可。';

  @override
  String get setupModelConfigComplete => '設定完成，開始旅程';

  @override
  String get aiService => 'Memex 模型服務';

  @override
  String get aiModelHubTitle => 'AI 模型與服務';

  @override
  String get aiModelHubSubtitle => '先選擇使用 Memex 官方服務，或接入自己的服務商；需要時再進入進階模型分配。';

  @override
  String get aiSetupCurrentStatusTitle => '目前設定';

  @override
  String get aiSetupStatusNotConfiguredTitle => '尚未設定 AI 服務';

  @override
  String get aiSetupStatusNotConfiguredDescription =>
      '選擇一種連線方式後，Memex 才能開始整理記錄、分析媒體並產生洞察。';

  @override
  String get aiSetupStatusMemexTitle => '正在使用 Memex 官方服務';

  @override
  String get aiSetupStatusMemexDescription =>
      'Memex 會使用 Memex 帳號管理的官方連線和 API 憑證。';

  @override
  String get aiSetupStatusCustomTitle => '正在使用自訂服務商';

  @override
  String get aiSetupStatusCustomDescription =>
      'Memex 會使用你設定的服務商憑證，以及文字／視覺模型用途選擇。';

  @override
  String get aiSetupChooseConnectionTitle => '選擇連線方式';

  @override
  String get aiSetupChooseConnectionDescription =>
      '先選擇你希望 Memex 透過哪條路徑存取 AI 模型。';

  @override
  String get aiSetupOfficialRouteDescription => '登入 Memex 後即可使用官方 AI 服務。';

  @override
  String get aiSetupCustomRouteDescription => '新增自己的服務商和 API Key。';

  @override
  String get aiSetupCustomPageTitle => '自訂 AI 服務';

  @override
  String get aiSetupCustomPageSubtitle => '先設定服務商和 API 金鑰，再選擇 Memex 使用的模型。';

  @override
  String get aiSetupProviderCredentialsTitle => '服務商與 API 金鑰';

  @override
  String get aiSetupProviderCredentialsDescription =>
      '新增或編輯 OpenAI、Anthropic、DeepSeek、Gemini、OpenRouter、Ollama 等相容服務商。';

  @override
  String get modelRolesTitle => '選擇主模型';

  @override
  String get modelRolesDescription =>
      '超級智慧體 使用同一個模型處理文字和圖片輸入。需要時仍可在下方為單一 智慧體 進階覆蓋。';

  @override
  String get textModelRoleTitle => '主模型';

  @override
  String get textModelRoleDescription =>
      '供 超級智慧體 處理文字、圖片、卡片、知識庫、洞察、聊天、評論和記憶總結。';

  @override
  String get modelConnectionsTitle => '模型服務商與 API 金鑰';

  @override
  String get modelConnectionsDescription => '可以連接 Memex 官方服務，也可以新增你自己的服務商憑證。';

  @override
  String get relatedAiCapabilitiesTitle => '進階與相關能力';

  @override
  String get relatedAiCapabilitiesDescription => '調整單一 智慧體 的模型分配、位置服務商和語音辨識方式。';

  @override
  String get aiSetupServiceCapabilitiesTitle => '服務能力';

  @override
  String get aiSetupServiceCapabilitiesDescription =>
      '設定語音辨識、逆地理編碼等相鄰 AI 能力使用的服務方式。';

  @override
  String get aiSetupAdvancedCustomizationTitle => '進階模型路由';

  @override
  String get aiSetupAdvancedCustomizationDescription =>
      '適合希望不同 智慧體 使用不同服務商或模型設定的進階使用者。';

  @override
  String get locationProviderSettings => '位置服務商';

  @override
  String get speechProviderSettings => '語音辨識';

  @override
  String get advancedAgentModelAssignments => '智慧體 模型分配';

  @override
  String get openAdvancedAgentModelAssignments => '為單一 智慧體 覆蓋模型';

  @override
  String get noConfiguredModelOptions => '請先新增模型服務商或 API 金鑰，再選擇模型用途。';

  @override
  String get modelSlotUpdated => '模型用途已更新';

  @override
  String get aiServiceMemexRouteTitle => '透過 Memex 連線';

  @override
  String get aiServiceLongDescription =>
      'Memex 利用多 智慧體 架構自動整理你的生活記錄、知識筆記與社交關係，深入挖掘洞察，並提供具有持久記憶的 AI 陪伴。所有資料均以純文字 Markdown 儲存，賦予你完整的資料自由與跨平台遷移能力。';

  @override
  String get aiServiceCustomApiRouteTitle => '我有 API 金鑰';

  @override
  String get aiServiceCustomModelDescription =>
      '已有 OpenAI、Anthropic、DeepSeek、Gemini 等服務的 API 金鑰 時，優先選擇這項。';

  @override
  String get enableAiService => '使用 Memex 連線';

  @override
  String get aiServiceReadyToast => 'AI 整理已開啟';

  @override
  String get aiServiceSettingsDescription =>
      '沒有 API 金鑰 時，可使用 Memex 帳號代理連接主流模型服務。';

  @override
  String get advancedModelConfiguration => '設定 API 金鑰';

  @override
  String get skipForNow => '暫不設定，先逛逛';

  @override
  String get clearAuth => '清除授權';

  @override
  String get authorizing => '正在授權中...';

  @override
  String authFailed(Object error) {
    return '授權失敗：$error';
  }

  @override
  String get authorized => '已授權';

  @override
  String authorizedAs(Object email) {
    return '已授權為 $email';
  }

  @override
  String get authorizedSuccessfully => '授權成功';

  @override
  String get reAuthorize => '重新授權';

  @override
  String get authorizeWithOpenAi => '使用 OpenAI 授權';

  @override
  String get authorizeWithGoogle => '使用 Google 授權';

  @override
  String get config => '設定';

  @override
  String get calendar => '行事曆';

  @override
  String get reminders => '提醒事項';

  @override
  String get writeToSystemFailed => '寫入系統失敗';

  @override
  String permissionRequired(Object name) {
    return '需要$name權限';
  }

  @override
  String permissionRationale(Object name) {
    return '請在設定中允許 App 存取你的$name，以便我們替你建立。';
  }

  @override
  String get goToSettings => '前往設定';

  @override
  String get unknownAction => '未知操作';

  @override
  String get discoveredCalendarEvent => '發現行事曆日程';

  @override
  String get discoveredReminder => '發現提醒事項';

  @override
  String get addToCalendar => '加入行事曆';

  @override
  String get addToReminders => '加入提醒事項';

  @override
  String get systemActionPendingExplanation => '尚未加入。點擊下方按鈕後，系統會要求權限並寫入你的裝置。';

  @override
  String addedToSuccess(Object target) {
    return '已成功加入至$target';
  }

  @override
  String get ignore => '忽略';

  @override
  String get confirmDelete => '確認刪除';

  @override
  String get confirmDeleteSessionMessage => '確定要刪除這段對話嗎？此操作無法復原。';

  @override
  String get delete => '刪除';

  @override
  String get deleteSuccess => '刪除成功';

  @override
  String deleteFailed(Object error) {
    return '刪除失敗：$error';
  }

  @override
  String daysAgo(Object count) {
    return '$count 天前';
  }

  @override
  String get chatHistory => '對話記錄';

  @override
  String get enterFullScreenTooltip => '全螢幕查看';

  @override
  String get exitFullScreenTooltip => '退出全螢幕';

  @override
  String get noConversations => '暫無對話';

  @override
  String loadSessionListFailed(Object error) {
    return '載入對話列表失敗：$error';
  }

  @override
  String yesterdayAt(Object time) {
    return '昨天 $time';
  }

  @override
  String get newChat => '新對話';

  @override
  String messageCount(Object count) {
    return '$count 則訊息';
  }

  @override
  String get organize => '整理';

  @override
  String get pkmCategoryProject => '專案';

  @override
  String get pkmCategoryProjectSubtitle => '短期 · 目標 · 截止日';

  @override
  String get pkmCategoryArea => '領域';

  @override
  String get pkmCategoryAreaSubtitle => '長期 · 責任 · 標準';

  @override
  String get pkmCategoryResource => '資源';

  @override
  String get pkmCategoryResourceSubtitle => '興趣 · 靈感 · 儲備';

  @override
  String get pkmCategoryArchive => '封存';

  @override
  String get pkmCategoryArchiveSubtitle => '完成 · 沉寂 · 備查';

  @override
  String get recentChanges => '最近變動';

  @override
  String get noRecentChangesInThreeDays => '最近 3 天暫無變動';

  @override
  String get unpinned => '已取消固定';

  @override
  String get pinnedStyle => '已固定此整理樣式';

  @override
  String operationFailed(Object error) {
    return '操作失敗：$error';
  }

  @override
  String get refreshingInsightData => '正在重新整理洞察資料，可能需要一點時間...';

  @override
  String refreshFailed(Object error) {
    return '重新整理失敗：$error';
  }

  @override
  String get sortUpdated => '排序已更新';

  @override
  String sortSaveFailed(Object error) {
    return '排序儲存失敗：$error';
  }

  @override
  String get insightCardDeleted => '已刪除洞察卡片';

  @override
  String deleteFailedShort(Object error) {
    return '刪除失敗：$error';
  }

  @override
  String get knowledgeInsight => '知識洞察';

  @override
  String get completeSort => '完成排序';

  @override
  String get noKnowledgeInsight => '暫無知識洞察';

  @override
  String insightProcessingBacklogMessage(Object count) {
    return '還有 $count 個背景任務正在處理。';
  }

  @override
  String get insightUnavailableMessage => '這個洞察仍在產生中，或已被更新。請重新整理洞察後稍後再試。';

  @override
  String get artifactOpen => '查看';

  @override
  String get updating => '更新中...';

  @override
  String get update => '更新';

  @override
  String get enabled => '已啟用';

  @override
  String get disabled => '已停用';

  @override
  String get appLockOn => '應用程式鎖定已開啟';

  @override
  String get appLockOff => '應用程式鎖定已關閉';

  @override
  String get enableAppLockFirst => '請先啟用應用程式鎖定';

  @override
  String get enterFourDigitPassword => '請輸入 4 位數密碼';

  @override
  String get passwordSetAndLockOn => '密碼已設定並開啟應用程式鎖定';

  @override
  String get appLockSettings => '應用程式鎖定設定';

  @override
  String get enableAppLock => '啟用應用程式鎖定';

  @override
  String get enableAppLockSubtitle => '啟用後，啟動應用程式需要驗證密碼';

  @override
  String get enableBiometrics => '啟用生物辨識';

  @override
  String get biometricsSubtitle => '解鎖時可使用 Face ID 或 Touch ID';

  @override
  String get changePassword => '修改密碼';

  @override
  String get setFourDigitPassword => '設定 4 位數密碼';

  @override
  String get reenterPasswordToConfirm => '請再次輸入密碼以確認';

  @override
  String get passwordMismatch => '兩次輸入的密碼不一致，請重新輸入';

  @override
  String confirmDeleteCharacter(Object name) {
    return '確定要刪除角色「$name」嗎？此操作無法復原。';
  }

  @override
  String get configureAiCharacter => '設定 AI 角色';

  @override
  String get addCharacter => '新增角色';

  @override
  String get addCharacterSubtitle => '選擇你喜歡的 AI 角色加入洞察團隊。他們會從不同角度分析你的生活資料。';

  @override
  String get noCharacters => '暫無角色';

  @override
  String loadCharacterFailed(Object error) {
    return '載入角色失敗：$error';
  }

  @override
  String get noTags => '無標籤';

  @override
  String get createSuccess => '建立成功';

  @override
  String get updateSuccess => '更新成功';

  @override
  String saveFailed(Object error) {
    return '儲存失敗：$error';
  }

  @override
  String get newCharacter => '新增角色';

  @override
  String get editCharacter => '編輯角色';

  @override
  String get save => '儲存';

  @override
  String get characterName => '角色名稱';

  @override
  String get characterNameHint => '給角色取個好聽的名字';

  @override
  String get pleaseEnterCharacterName => '請輸入角色名稱';

  @override
  String get tagsLabel => '標籤';

  @override
  String get tagsHint => '例如：智慧, 認可, 宏觀\n用逗號分隔多個標籤';

  @override
  String get characterPersonaLabel => '角色完整設定';

  @override
  String get characterPersonaHint =>
      '包含角色人設、風格指南、範例對話、知識篩選器等所有資訊。\n可以使用 ## 標題來分段組織內容。';

  @override
  String get pleaseEnterCharacterPersona => '請輸入角色完整設定';

  @override
  String permissionRequestError(Object error) {
    return '權限請求異常：$error';
  }

  @override
  String get permissionRequiredTitle => '需要權限';

  @override
  String get permissionPermanentlyDeniedMessage =>
      '由於你已永久拒絕該權限，或系統需要手動開啟，請前往系統設定中啟用。';

  @override
  String get getting => '取得中...';

  @override
  String get unauthorized => '未授權';

  @override
  String get authorizedGoToSettings => '已授權，如需修改請前往系統設定';

  @override
  String get location => '定位';

  @override
  String get locationPermissionReason => '用於記錄足跡和地理位置相關功能';

  @override
  String get photos => '相簿';

  @override
  String get photosPermissionReason => '用於選取照片、儲存產生的圖片等';

  @override
  String get camera => '相機';

  @override
  String get cameraPermissionReason => '用於拍攝照片與影片相關功能';

  @override
  String get microphone => '麥克風';

  @override
  String get microphonePermissionReason => '用於語音辨識、錄音等功能';

  @override
  String get calendarPermissionReason => '用於記錄日程、讀取行事曆事件等';

  @override
  String get remindersPermissionReason => '用於記錄和讀取你的待辦提醒';

  @override
  String get fitnessAndMotion => '健身與運動';

  @override
  String get fitnessPermissionReason => '用於記錄健康與運動資料';

  @override
  String get notification => '通知';

  @override
  String get notificationPermissionReason => '用於傳送日程提醒等重要通知';

  @override
  String get memexAgentNotificationPermissionTitle => '讓 Memex Agent 在背景繼續執行';

  @override
  String get memexAgentNotificationPermissionMessage =>
      'Memex Agent 在你的裝置本地執行。開啟通知權限後，Memex 可以顯示背景執行進度，讓任務在你退到背景或關閉螢幕時繼續處理。未開啟時，請保持 Memex 在前景，直到任務完成。';

  @override
  String get loadDetailFailedRetryShort => '載入詳情失敗，請稍後重試';

  @override
  String get total => '總計';

  @override
  String get estimatedCost => '預估費用';

  @override
  String get byAgent => '按 智慧體 統計';

  @override
  String get timeUpdated => '時間已更新';

  @override
  String updateFailed(Object error) {
    return '更新失敗：$error';
  }

  @override
  String get locationUpdated => '地點已更新';

  @override
  String get confirmDeleteCardMessage => '確定要刪除這張卡片嗎？此操作無法復原。';

  @override
  String get cardDetailNotFound => '找不到卡片詳情';

  @override
  String get saySomething => '說點什麼...';

  @override
  String get relatedMemories => '相關回憶';

  @override
  String get viewMore => '查看更多';

  @override
  String get relatedRecords => '相關記錄';

  @override
  String get reply => '回覆';

  @override
  String get replySent => '回覆已傳送';

  @override
  String get insightTemplateGalleryTitle => '洞察卡片範本';

  @override
  String get timelineTemplateGalleryTitle => '時間線 卡片範本';

  @override
  String get categoryTextual => '文字（文字）';

  @override
  String get timelineFilterAll => '全部';

  @override
  String get insights => '洞察';

  @override
  String get memoryTitle => '記憶';

  @override
  String get longTermProfile => '長期記憶';

  @override
  String get recentBuffer => '近期記憶';

  @override
  String errorLoadingMemory(Object error) {
    return '載入記憶失敗：$error';
  }

  @override
  String get agentConfiguration => '智慧體 設定';

  @override
  String get resetToDefaults => '恢復預設';

  @override
  String get resetAllAgentConfigurationsTitle => '重設所有 智慧體 設定';

  @override
  String get resetAllAgentConfigurationsMessage =>
      '確定要將所有 智慧體 設定恢復為預設值嗎？此操作無法復原。';

  @override
  String get resetButton => '重設';

  @override
  String loadDataFailed(Object error) {
    return '載入失敗：$error';
  }

  @override
  String saveConfigFailed(Object error) {
    return '儲存設定失敗：$error';
  }

  @override
  String get selectLlmClient => '選擇 LLM 用戶端：';

  @override
  String get agentConfigurationsReset => '智慧體 設定已重設';

  @override
  String resetFailed(Object error) {
    return '重設失敗：$error';
  }

  @override
  String get modelConfiguration => '模型設定';

  @override
  String get resetAllConfigurationsTitle => '重設所有設定';

  @override
  String get resetAllModelConfigurationsMessage => '確定要將所有模型設定恢復為預設值嗎？此操作無法復原。';

  @override
  String get modelConfigurationsReset => '模型設定已重設';

  @override
  String get cannotDeleteDefaultConfiguration => '無法刪除預設設定';

  @override
  String get cannotDeleteConfigurationTitle => '無法刪除設定';

  @override
  String configUsedByAgentsMessage(Object agentList) {
    return '以下 智慧體 正在使用此設定：\n\n$agentList\n\n請先為這些 智慧體 重新分配設定後再刪除。';
  }

  @override
  String get ok => '確定';

  @override
  String get deleteConfigurationTitle => '刪除設定';

  @override
  String confirmDeleteConfigMessage(Object key) {
    return '確定要刪除「$key」嗎？';
  }

  @override
  String get defaultLabel => '預設';

  @override
  String get setAsDefault => '設為預設';

  @override
  String get invalidJsonInExtraField => '擴充欄位 JSON 格式無效';

  @override
  String get keyAlreadyExists => '此 Key 已存在';

  @override
  String get resetConfigurationTitle => '重設設定';

  @override
  String get resetConfigurationMessage => '將此設定恢復為初始預設值？目前修改將會遺失。';

  @override
  String get configurationResetPressSave => '設定已重設，請點選儲存以套用。';

  @override
  String get addConfiguration => '新增設定';

  @override
  String get editConfiguration => '編輯設定';

  @override
  String get duplicateConfiguration => '複製設定';

  @override
  String get duplicate => '複製';

  @override
  String get keyIdLabel => '設定 ID';

  @override
  String get keyIdHelper => '替這套設定命名，例如 deepseek 或 work-gpt。';

  @override
  String get required => '必填';

  @override
  String get clientLabel => '模型服務商';

  @override
  String get providerGroupOpenAi => 'OpenAI';

  @override
  String get providerGroupAnthropic => 'Anthropic';

  @override
  String get providerGroupGoogle => 'Google';

  @override
  String get providerGroupOthers => '熱門';

  @override
  String get providerOpenAiApiKey => 'API 金鑰';

  @override
  String get providerOpenAiResponses => 'API 金鑰（Responses）';

  @override
  String get providerChatGptOauth => 'ChatGPT Pro/Plus';

  @override
  String get providerClaudeApiKey => 'API 金鑰';

  @override
  String get providerBedrockSecret => 'Bedrock Secret';

  @override
  String get providerGemini => 'Gemini';

  @override
  String get providerGeminiOauth => 'Gemini（Google OAuth）';

  @override
  String get providerKimi => 'Kimi（月之暗面）';

  @override
  String get providerQwen => 'Aliyun（阿里雲）';

  @override
  String get providerSeed => 'Volcengine（火山引擎）';

  @override
  String get providerZhipu => 'Zhipu GLM（智譜）';

  @override
  String get providerDeepSeek => 'DeepSeek（官方 API）';

  @override
  String get providerMinimax => 'MiniMax';

  @override
  String get providerOpenRouter => 'OpenRouter';

  @override
  String get providerOllama => 'Ollama（本機）';

  @override
  String get providerMimo => 'Xiaomi MIMO（小米）';

  @override
  String get providerMemex => 'Memex 代理服務';

  @override
  String get memexSignIn => '登入';

  @override
  String get memexCreateAccount => '註冊';

  @override
  String get memexUsername => '使用者名稱';

  @override
  String get memexPassword => '密碼';

  @override
  String get memexCreateAccountLink => '註冊帳號';

  @override
  String get memexSignInLink => '已有帳號，前往登入';

  @override
  String get memexTopUp => '儲值後即可使用 Memex AI';

  @override
  String get memexTopUpSuccess => '儲值成功！';

  @override
  String get memexFillAllFields => '請填寫所有欄位';

  @override
  String get memexUsernameTooShort => '使用者名稱至少 6 個字元';

  @override
  String get memexAuthFailed => '驗證失敗';

  @override
  String get memexPaymentFailed => '建立付款失敗';

  @override
  String get memexLogout => '登出';

  @override
  String get memexTopUpButton => '儲值';

  @override
  String get memexTopUpChooseAmount => '選擇儲值額度';

  @override
  String memexTopUpEstimatedRecords(Object range) {
    return '預計 $range 筆記錄';
  }

  @override
  String get memexTopUpPlanStarter => '輕量嘗試';

  @override
  String get memexTopUpPlanEveryday => '日常整理';

  @override
  String get memexTopUpPlanHighVolume => '高頻使用';

  @override
  String get memexTopUpPlanCustom => '自訂額度';

  @override
  String get memexTopUpPlanStarterSubtitle => '適合先體驗 Memex AI';

  @override
  String get memexTopUpPlanEverydaySubtitle => '適合持續整理與分析';

  @override
  String get memexTopUpPlanHighVolumeSubtitle => '適合批次處理較多記錄';

  @override
  String get memexTopUpPlanCustomSubtitle => '輸入 1-10000 美元';

  @override
  String get memexTopUpCustomEstimate => '依輸入金額估算可處理量';

  @override
  String get memexCustomAmount => '自訂金額';

  @override
  String get memexViewHistory => '使用記錄';

  @override
  String memexBalanceLabel(Object amount) {
    return '餘額：$amount';
  }

  @override
  String get memexConfirmPassword => '確認密碼';

  @override
  String get memexPasswordMismatch => '兩次密碼不一致';

  @override
  String memexPayAmount(Object amount) {
    return '儲值 $amount';
  }

  @override
  String get modelIdLabel => '模型';

  @override
  String get modelIdHelper => '例如 gemini-3.1-pro-preview、gpt-4o';

  @override
  String get fetchingModels => '正在取得模型列表...';

  @override
  String get fetchModelsButton => '取得模型列表';

  @override
  String get enterApiKeyFirst => '請先填寫 API 金鑰 以取得模型列表';

  @override
  String get apiKeyLabel => 'API 金鑰';

  @override
  String get baseUrlLabel => 'API 位址';

  @override
  String get advancedSettings => '進階設定';

  @override
  String get testConnectionSuccess => '連線成功';

  @override
  String get testConnectionFailed => '連線失敗';

  @override
  String get testTypeText => '文字';

  @override
  String get testTypeVision => '視覺';

  @override
  String get testButton => '測試';

  @override
  String get testing => '測試中...';

  @override
  String get proxyUrlOptional => '代理 URL（選填）';

  @override
  String get proxyUrlHelper => '例如 http://127.0.0.1:7890';

  @override
  String get temperatureLabel => 'Temperature';

  @override
  String get topPLabel => 'Top P';

  @override
  String get maxTokensLabel => 'Max 權杖';

  @override
  String get extraParamsJson => '擴充參數（JSON）';

  @override
  String get invalidJson => 'JSON 格式無效';

  @override
  String get warning => '設定未完成';

  @override
  String get invalidConfigurationWarning =>
      '目前設定尚未完成（例如缺少 API 金鑰 或 Model ID）。你可以先儲存，稍後再補全設定。是否繼續？';

  @override
  String invalidModelConfigDetailed(Object agentId, Object configKey) {
    return '智慧體「$agentId」需要有效的模型設定（Key：「$configKey」）才能執行。請在設定中更新並補全對應參數。';
  }

  @override
  String get discardChangesTitle => '離開此頁面？';

  @override
  String get discardChangesMessage => '如果你做了變更，請先儲存後再離開。';

  @override
  String get discardButton => '放棄';

  @override
  String get chooseLanguage => '選擇語言';

  @override
  String get chooseAvatar => '選擇頭像';

  @override
  String get configureNow => '立即設定';

  @override
  String get modelNotConfiguredBanner => 'AI 模型尚未設定，請先設定以解鎖全部功能。';

  @override
  String get modelNotConfiguredSubmitHint => '請先設定 AI 模型再發布內容';

  @override
  String get processingStatus => '處理中';

  @override
  String get failedStatus => '處理失敗';

  @override
  String get failureReason => '失敗原因';

  @override
  String get unknownError => '發生未知錯誤';

  @override
  String get enableFitness => '開啟健身權限';

  @override
  String get fitnessBannerMessage => '允許存取健身資料，以記錄你的健康和運動資訊。';

  @override
  String get fitnessDismissTitle => '跳過健身權限？';

  @override
  String get fitnessDismissMessage => '如果跳過，應用程式將無法自動收集你的健康資料，用於洞察分析和自動記錄。';

  @override
  String get skipAnyway => '仍然跳過';

  @override
  String get proModelHint => '此模型需要 ChatGPT Pro/Plus 訂閱才能使用。';

  @override
  String get searchKnowledgeBase => '搜尋知識庫...';

  @override
  String get searchKnowledgeHint => '輸入關鍵字搜尋檔名或內容';

  @override
  String noSearchResults(Object query) {
    return '找不到「$query」相關結果';
  }

  @override
  String get onlyMarkdownPreview => '僅支援 Markdown 檔案預覽';

  @override
  String get backupAndRestore => '備份與還原';

  @override
  String get createBackup => '建立備份';

  @override
  String get restoreBackup => '還原備份';

  @override
  String get backupDescription =>
      '將所有資料（卡片、知識庫、洞察、設定）打包為 .memex 檔案。可透過分享儲存到 iCloud Drive、Google Drive 或任意位置。';

  @override
  String get restoreDescription => '選擇 .memex 備份檔還原所有資料。這會覆蓋目前資料。';

  @override
  String get selectBackupFile => '選擇備份檔';

  @override
  String get estimatedSize => '預估大小';

  @override
  String get backupComplete => '備份已建立';

  @override
  String backupFailed(Object error) {
    return '備份失敗：$error';
  }

  @override
  String get confirmRestore => '確認還原';

  @override
  String get confirmRestoreMessage =>
      '還原會覆蓋目前所有資料，包括卡片、知識庫、洞察和設定。此操作無法復原，確定繼續？';

  @override
  String get restoreComplete => '還原完成';

  @override
  String get restoreRestartHint => '資料已還原，請重新啟動應用程式以套用所有變更。';

  @override
  String restoreFailed(Object error) {
    return '還原失敗：$error';
  }

  @override
  String get invalidBackupFile => '無效的備份檔，請選擇 .memex 檔案。';

  @override
  String get automaticBackup => '自動備份';

  @override
  String get autoBackupDescription => '開啟後，Memex 會在啟動或回到前景時檢查，每天最多建立一次本機時間點快照。';

  @override
  String get backupSensitiveSettingsHint => '備份包含設定和模型服務商金鑰，請只儲存到你信任的位置。';

  @override
  String get backupLocation => '位置';

  @override
  String get backupLocationDetails => '位置詳情';

  @override
  String get backupLocationSummary => '應用程式中顯示';

  @override
  String get backupLocationFullPath => '完整路徑';

  @override
  String get backupLocationUri => '資料夾授權 URI';

  @override
  String get copyBackupLocationPath => '複製路徑';

  @override
  String get backupLocationCopied => '備份位置已複製';

  @override
  String androidBackupLocationSelected(Object folderName) {
    return '已選資料夾：$folderName';
  }

  @override
  String get iosICloudBackupLocation => 'iCloud 雲碟 > Memex > Backups';

  @override
  String get iosAppDocumentsBackupLocation =>
      '檔案 > 我的 iPhone > Memex > Backups';

  @override
  String get autoBackupStatus => '狀態';

  @override
  String get noAutoBackupYet => '還沒有自動備份';

  @override
  String lastBackupAt(Object time) {
    return '上次備份：$time';
  }

  @override
  String get autoBackupRetention => '保留';

  @override
  String autoBackupRetentionDays(Object days) {
    return '$days 天';
  }

  @override
  String get autoBackupRetentionForever => '永久保留';

  @override
  String get autoBackupMaxSize => '空間上限';

  @override
  String autoBackupRetentionLimitHint(Object size) {
    return '自動清理會讓自動快照總大小不超過 $size。安全快照和手動匯出備份會另外保留。';
  }

  @override
  String get createSnapshotNow => '立即備份';

  @override
  String get backupLocationMenu => '變更位置';

  @override
  String get defaultBackupLocation => '預設備份資料夾';

  @override
  String get defaultBackupLocationAndroidDesc =>
      '使用 Memex 的應用程式專屬外部目錄，不需要儲存權限。';

  @override
  String get chooseBackupLocation => '選擇備份資料夾';

  @override
  String get chooseBackupLocationAndroidDesc =>
      '使用 Android 系統選擇器選擇資料夾，並授予 Memex 持久存取權限。';

  @override
  String get storedBackups => '已儲存備份';

  @override
  String get noStoredBackups => '建立第一個自動快照後會顯示在這裡。';

  @override
  String get backupTypeAutoSnapshot => '自動快照';

  @override
  String get backupTypeSafetySnapshot => '安全快照';

  @override
  String get backupTypeManualBackup => '手動備份';

  @override
  String get refresh => '重新整理';

  @override
  String get restoreThisBackup => '還原此備份';

  @override
  String get deleteThisBackup => '刪除此備份';

  @override
  String get confirmDeleteBackup => '刪除備份？';

  @override
  String confirmDeleteBackupMessage(Object fileName) {
    return '刪除 $fileName？這會移除已儲存的備份檔，且無法復原。';
  }

  @override
  String backupDeleted(Object fileName) {
    return '備份已刪除：$fileName';
  }

  @override
  String backupDeleteFailed(Object error) {
    return '無法刪除備份：$error';
  }

  @override
  String get creatingSafetySnapshot => '正在建立安全快照...';

  @override
  String autoBackupCreated(Object fileName) {
    return '快照已建立：$fileName';
  }

  @override
  String backupLocationFailed(Object error) {
    return '無法更新備份位置：$error';
  }

  @override
  String get backupImportCreatedAt => '建立時間';

  @override
  String get backupImportSourceVersion => '來源版本';

  @override
  String get backupImportFlavor => '建置版本';

  @override
  String get backupLegacyFormat => '舊版備份（沒有 manifest）';

  @override
  String get restoreInProgress => '正在還原備份...';

  @override
  String get dataStorage => '資料儲存';

  @override
  String get dataStorageDescriptionAndroid =>
      '選擇自訂資料夾來儲存你的工作區。重新安裝應用程式後，資料仍會保留。';

  @override
  String get dataStorageDescriptionIOS =>
      '開啟 iCloud，在裝置之間同步工作區，並在重新安裝應用程式後保留資料。';

  @override
  String get storageLocationApp => '應用程式儲存空間';

  @override
  String get storageLocationAppDesc => '資料會儲存在應用程式內，解除安裝時會一併移除。';

  @override
  String get storageLocationCustom => '裝置儲存空間（自訂資料夾）';

  @override
  String get storageLocationCustomDesc =>
      '將資料儲存在你選擇的資料夾中。只要資料夾仍存在，重新安裝後資料也會保留。';

  @override
  String get storageLocationICloud => '儲存到 iCloud';

  @override
  String get storageLocationICloudDesc => '在 Apple 裝置之間同步你的工作區。重新安裝後資料仍會保留。';

  @override
  String storageLocationCurrent(Object location) {
    return '目前：$location';
  }

  @override
  String get icloudRequiresCapability =>
      '請登入 iCloud 並開啟 iCloud Drive，才能使用 iCloud 儲存空間。';

  @override
  String get loadingFromICloud => '正在從 iCloud 還原資料…';

  @override
  String get switchingToICloud => '正在切換到 iCloud 儲存空間…';

  @override
  String get switchingStorage => '正在切換儲存空間…';

  @override
  String get customFolderAccessDenied => '無法讀取或寫入此資料夾。請授予儲存權限，或選擇其他位置。';

  @override
  String get configured => '已設定';

  @override
  String get apiKeyNotSet => '尚未設定 API 金鑰 — 點選以設定';

  @override
  String get bottomNavTimeline => '時間軸';

  @override
  String get bottomNavLibrary => '知識庫';

  @override
  String get aiGeneratedLabel => 'AI 生成';

  @override
  String sourceTraceWithCount(Object count) {
    return '來源追蹤（$count）';
  }

  @override
  String get deleteAccount => '刪除帳戶';

  @override
  String get deleteAccountDesc => '永久刪除所有本機資料並重設應用程式。';

  @override
  String get deleteAccountConfirmTitle => '要刪除帳戶嗎？';

  @override
  String get deleteAccountConfirmMessage =>
      '這會永久刪除你的所有資料，包括時間軸卡片、知識庫、錄音和設定。此動作無法復原。';

  @override
  String deleteAccountTypeName(Object name) {
    return '輸入「$name」以確認';
  }

  @override
  String get deleteAccountTypeHint => '輸入你的使用者名稱以確認';

  @override
  String get llmConsentTitle => '資料分享同意';

  @override
  String llmConsentMessage(Object provider) {
    return '為了啟用 AI 功能，Memex 需要將你的資料傳送給 $provider 進行處理。這包括：\n\n• 你輸入的文字（筆記、語音轉錄）\n• 照片中繼資料與擷取文字（OCR）\n• 健康與健身摘要\n• 時間軸卡片內容\n\n你的資料會直接從裝置傳送給 $provider。Memex 不會透過任何其他伺服器儲存或轉送你的資料。\n\n請查看 $provider 的隱私權政策，了解其資料處理方式。\n\n你是否同意將資料傳送給 $provider 進行 AI 處理？';
  }

  @override
  String get llmConsentAgree => '我同意';

  @override
  String get llmConsentDecline => '拒絕';

  @override
  String get customAgents => '自訂 智慧體';

  @override
  String get noCustomAgents => '尚未設定自訂 智慧體。';

  @override
  String get deleteAgent => '刪除 智慧體';

  @override
  String deleteAgentConfirm(Object name) {
    return '要刪除自訂 智慧體「$name」嗎？';
  }

  @override
  String get deleted => '已刪除';

  @override
  String get saved => '已儲存';

  @override
  String get newAgent => '新增 智慧體';

  @override
  String get editAgent => '編輯 智慧體';

  @override
  String get agentName => '智慧體 名稱';

  @override
  String get agentNameHint => 'my-custom-agent';

  @override
  String get agentNameRequired => '必填';

  @override
  String get agentNameInvalid => '僅可使用字母、數字和連字號';

  @override
  String get agentNameExists => '名稱已存在';

  @override
  String get hostAgentType => '宿主 智慧體 類型';

  @override
  String get skillDirectory => '技能 目錄';

  @override
  String get skillDirInvalid => '必須是相對路徑（不能以 / 開頭或包含 ..）';

  @override
  String get workingDirectory => '工作目錄（選填）';

  @override
  String get workingDirectoryHint => '留空則使用工作區預設值';

  @override
  String get llmConfig => 'LLM 設定';

  @override
  String get eventType => '事件類型';

  @override
  String get executionMode => '執行模式';

  @override
  String get executionModeAsync => '非同步';

  @override
  String get executionModeSync => '同步';

  @override
  String get dependsOn => '依賴項目';

  @override
  String get dependsOnHint => '選擇依賴項目';

  @override
  String get priority => '優先順序';

  @override
  String get maxRetries => '最大重試次數';

  @override
  String get systemPromptLabel => '系統提示詞（選填）';

  @override
  String get systemPromptHint => '附加到宿主 智慧體 提示詞後方的額外指示';

  @override
  String get eventSerializer => '事件序列化器';

  @override
  String get eventSerializerDefault => '預設（XML）';

  @override
  String get enabledLabel => '啟用';

  @override
  String get skillsManagement => '技能 管理';

  @override
  String get skillsManagementEmpty => '尚無 技能';

  @override
  String get downloadSkill => '下載 技能';

  @override
  String get downloadFile => '下載檔案';

  @override
  String get downloading => '下載中...';

  @override
  String get downloadSuccess => '技能 已成功下載';

  @override
  String downloadFailed(Object error) {
    return '下載失敗：$error';
  }

  @override
  String get deleteConfirm => '確認刪除';

  @override
  String deleteConfirmMessage(String name) {
    return '確定要刪除「$name」嗎？';
  }

  @override
  String get invalidUrl => '請輸入有效的 URL';

  @override
  String get urlHint => 'https://example.com/skill.zip';

  @override
  String get newFolder => '新增資料夾';

  @override
  String get newFile => '新增檔案';

  @override
  String get folderName => '資料夾名稱';

  @override
  String get fileName => '檔案名稱';

  @override
  String get nameRequired => '名稱為必填';

  @override
  String get nameInvalid => '名稱不能包含 / 或 ..';

  @override
  String createFailed(Object error) {
    return '建立失敗：$error';
  }

  @override
  String get fileContent => '檔案內容';

  @override
  String get saveSuccess => '儲存成功';

  @override
  String downloadToCurrentDir(String dir) {
    return 'zip 會解壓縮到目前目錄：$dir';
  }

  @override
  String get privacyPolicy => '隱私權政策';

  @override
  String get privacyPolicyDesc => 'Memex 如何處理你的資料';

  @override
  String get llmAuthError => 'API 驗證失敗。請在設定中檢查你的 LLM 設定。';

  @override
  String get llmBadRequestError => 'LLM 服務商拒絕了請求。目前模型可能不支援此輸入格式。';

  @override
  String get llmRateLimitError => 'API 呼叫頻率已超過限制。請稍後再試。';

  @override
  String get llmServerError => 'LLM 服務暫時無法使用。請稍後再試。';

  @override
  String get llmNetworkError => '網路連線失敗。請檢查你的網際網路連線。';

  @override
  String get llmUnknownError => '處理你的內容時發生未預期的錯誤。';

  @override
  String get llmErrorDialogTitle => '處理失敗';

  @override
  String get goToModelConfig => '前往設定';

  @override
  String get speechModelDownloadTitle => '下載語音模型';

  @override
  String speechModelDownloadDesc(Object sizeMB) {
    return '需要一次性下載模型（約 ${sizeMB}MB）。\n\n下載完成後，轉錄會完全在裝置上執行。';
  }

  @override
  String get speechModelStartDownload => '開始下載';

  @override
  String get speechModelChooseSource => '選擇下載來源：';

  @override
  String get speechModelChinaMirror => '🇨🇳 中國鏡像（中國大陸較快）';

  @override
  String get speechModelGithub => '🌐 GitHub（全球）';

  @override
  String get speechModelDownloading => '正在下載模型...';

  @override
  String get speechModelConnecting => '正在連線...';

  @override
  String get deleteSpeechModel => '刪除語音模型';

  @override
  String get confirmDeleteSpeechModelMessage =>
      '要刪除已下載的本機語音辨識模型檔案嗎？下次使用本機語音轉文字時會重新下載。';

  @override
  String get speechModelDeletedSuccess => '語音模型檔案已刪除';

  @override
  String get speechModelNotDownloaded => '找不到已下載的語音模型檔案';

  @override
  String speechModelDeleteFailed(Object error) {
    return '刪除語音模型檔案失敗：$error';
  }

  @override
  String get speechTranscribing => '正在辨識...';

  @override
  String get speechNoResult => '未偵測到語音';

  @override
  String get useLocalSpeechToTextTitle => '使用本機語音轉文字';

  @override
  String get useLocalSpeechToTextDesc =>
      '開啟時，音訊會先在裝置上轉錄成文字再傳送，適合不支援音訊輸入的模型。關閉時，原始音訊會直接傳送給模型。';

  @override
  String get pendingAiProcessingHint => '設定 AI 模型以處理';

  @override
  String get demoWelcome => '歡迎來到 Memex！\n讓我們快速看看 AI 能為你的記錄做些什麼。';

  @override
  String get demoTapAdd => '點這裡建立你的第一筆記錄';

  @override
  String get demoTapSend => '點選送出你的第一筆記錄';

  @override
  String get demoTapCard => '點選查看 AI 如何整理你的記錄';

  @override
  String get demoDetailHint => '這裡是 AI 整理後的記錄詳情。可以自由瀏覽，看完後返回繼續導覽。';

  @override
  String get demoTapInsight => '點選查看 AI 生成的洞察';

  @override
  String get demoTapInsightUpdate => '點選從你的記錄生成洞察';

  @override
  String get demoTapKnowledge => '查看自動整理的知識檔案';

  @override
  String get demoDone => '開始記錄你的生活。';

  @override
  String get demoStartTour => '開始導覽';

  @override
  String get demoGetStarted => '開始使用';

  @override
  String get demoSkip => '略過';

  @override
  String get demoPrefillText => '你好 Memex！這是我的第一筆記錄 🎉';

  @override
  String get visionBadge => '視覺';

  @override
  String get notMultimodalHint =>
      'Memex 依賴多模態模型能力進行媒體分析。如果你的記錄包含圖片，請確認你設定的模型支援圖片輸入。';

  @override
  String get defaultModelPrefix => '預設';

  @override
  String get recommendedBadge => '推薦';

  @override
  String get readOnlyBadge => 'CHAT';

  @override
  String get switchCompanion => '切換陪伴角色';

  @override
  String get personaChatInputHint => '輸入訊息...';

  @override
  String get today => '今天';

  @override
  String get tomorrow => '明天';

  @override
  String get yesterday => '昨天';

  @override
  String get showInsightTextTitle => '顯示 Memex 洞察評論';

  @override
  String get showInsightTextDesc => '是否在卡片詳情的評論區中，將 Memex 洞察顯示為置頂評論。';

  @override
  String get enableCharacterCommentTitle => '角色自動評論';

  @override
  String get enableCharacterCommentDesc => '角色會自動對新記錄發表評論。';

  @override
  String get maxCommentCharactersTitle => '最多評論角色數';

  @override
  String get maxCommentCharactersDesc => '每筆記錄可由幾個角色參與評論。';

  @override
  String replyTo(String name) {
    return '回覆 $name';
  }

  @override
  String get cdnSignalsComments => '收到新回覆';

  @override
  String get cdnSignalsInsight => '已生成新洞察';

  @override
  String get cdnSignalsBoth => '收到新回覆與新洞察';

  @override
  String get untitledCard => '未命名卡片';

  @override
  String get locationContextTitle => '位置上下文';

  @override
  String get locationContextDescription => '智慧體 對話目前所在城市與街區上下文';

  @override
  String get locationContextAttachTitle => '將目前位置附加到對話';

  @override
  String get locationContextAttachDesc =>
      '使用裝置 GPS 與反向地理編碼，向 智慧體 提供城市、行政區和街區上下文。';

  @override
  String get reverseGeocodingProvider => '反向地理編碼服務商';

  @override
  String get amapProviderName => '高德地圖';

  @override
  String get amapApiKey => '高德地圖 API 金鑰';

  @override
  String get amapGcj02Note => '高德地圖使用 GCJ-02 座標。裝置 GPS 會先轉換，再進行反向地理編碼。';

  @override
  String get contextGranularity => '上下文精細度';

  @override
  String get granularityCity => '城市';

  @override
  String get granularityDistrict => '行政區';

  @override
  String get granularityNeighborhood => '街區';

  @override
  String get granularityStreet => '街道';

  @override
  String get granularityFullAddress => '完整地址候選';

  @override
  String get locationFreshness => '位置新鮮度';

  @override
  String minutesShort(int minutes) {
    return '$minutes 分鐘';
  }

  @override
  String get oneHour => '1 小時';

  @override
  String get testCurrentLocation => '測試目前位置';

  @override
  String locationTestFailed(String error) {
    return '失敗：$error';
  }

  @override
  String get locationDebugGps => 'GPS';

  @override
  String get locationDebugReverseGeocode => '反向地理編碼';

  @override
  String get locationDebugProvider => '服務商';

  @override
  String get locationDebugAgentContext => '智慧體 上下文';

  @override
  String get locationDebugSource => '來源';

  @override
  String get locationDebugAddressSummary => '地址摘要';

  @override
  String get locationDebugFullAddress => '完整地址';

  @override
  String get locationDebugCoordinates => '座標';

  @override
  String get locationDebugAccuracy => '精確度';

  @override
  String get locationDebugReason => '原因';

  @override
  String get locationDebugOk => '正常';

  @override
  String get locationDebugUnavailable => '無法使用';

  @override
  String get locationDebugInjected => '已注入';

  @override
  String get locationDebugNotInjected => '未注入';

  @override
  String get locationStatusUpdatedAt => '已更新';

  @override
  String get locationStatusSuccessTitle => '目前位置已就緒';

  @override
  String get locationStatusSuccessBody => '當位置上下文與對話相關時，Memex 可以附加這段位置摘要。';

  @override
  String get locationStatusApproximateTitle => '僅有大致位置';

  @override
  String get locationStatusApproximateBody =>
      '精確度看起來只到城市或區域層級。你可以繼續使用，或在系統設定中開啟精確位置，以取得更精準的上下文。';

  @override
  String get locationStatusServiceDisabledTitle => '系統定位已關閉';

  @override
  String get locationStatusServiceDisabledBody =>
      'Memex 只使用裝置 GPS，不會從網路或 IP 推斷位置。Android 請開啟位置設定；iOS 請啟用「設定 > 隱私權與安全性 > 定位服務」。';

  @override
  String get locationStatusPermissionDeniedTitle => '需要位置權限';

  @override
  String get locationStatusPermissionDeniedBody =>
      '請允許 Memex 在測試或需要位置上下文時使用位置。不會要求永遠存取。';

  @override
  String get locationStatusPermissionForeverTitle => '位置權限已被封鎖';

  @override
  String get locationStatusPermissionForeverBody =>
      '請開啟應用程式設定並允許 Memex 使用位置。在 iOS 上，「使用 App 期間」就足夠。';

  @override
  String get locationStatusDisabledTitle => '位置上下文已關閉';

  @override
  String get locationStatusDisabledBody =>
      '當你希望 Memex 將裝置位置附加到 智慧體 上下文時，請開啟上方開關並儲存。';

  @override
  String get locationStatusGeocodeUnavailableTitle => 'GPS 可用，但地址查詢失敗';

  @override
  String get locationStatusGeocodeUnavailableBody =>
      'Memex 有座標，但不會將只有 GPS 的上下文注入 智慧體。請檢查反向地理編碼服務商後再試。';

  @override
  String get locationStatusUnavailableTitle => '位置無法使用';

  @override
  String get locationStatusUnavailableBody => '請檢查系統定位服務與應用程式權限，然後再測試一次。';

  @override
  String get allowLocationPermissionButton => '允許位置權限';

  @override
  String get openAppSettingsButton => '開啟應用程式設定';

  @override
  String get openLocationSettingsButton => '開啟位置設定';

  @override
  String get locationSettingsOpenFailed => '無法開啟系統設定。';

  @override
  String locationActionFailed(String error) {
    return '位置操作失敗：$error';
  }

  @override
  String get settingsSearchPlaceholder => '搜尋設定...';

  @override
  String get settingsSearchEmpty => '找不到相符的設定項目';

  @override
  String get importCharacterCard => '匯入角色卡';

  @override
  String get firstMessageLabel => '第一則訊息';

  @override
  String get firstMessageHint => '首次對話時送出的問候語（選填）';

  @override
  String get systemPromptOverrideLabel => '覆寫系統提示詞';

  @override
  String get systemPromptOverrideHint => '覆寫預設系統提示詞（進階，選填）';

  @override
  String get postHistoryInstructionsLabel => '歷史後指示';

  @override
  String get postHistoryInstructionsHint => '插入在聊天歷史之後、回覆之前的指示（選填）';

  @override
  String get mesExampleLabel => '訊息範例';

  @override
  String get mesExampleHint => '展示角色風格的範例對話（選填）';

  @override
  String get worldBookTitle => '世界書';

  @override
  String get worldBookSubtitle => '觸發關鍵字時注入的背景知識';

  @override
  String get characterMemoryTitle => '角色記憶';

  @override
  String get characterMemorySubtitle => '角色與使用者之間的關係動態和互動記憶';

  @override
  String get addTooltip => '新增';

  @override
  String get constantBadge => '常駐';

  @override
  String worldEntryFallbackName(Object index) {
    return '項目 $index';
  }

  @override
  String keywordsPrefix(Object keys) {
    return '關鍵字：$keys';
  }

  @override
  String memoryFallbackName(Object index) {
    return '記憶 $index';
  }

  @override
  String get addWorldEntry => '新增世界書項目';

  @override
  String get editWorldEntry => '編輯世界書項目';

  @override
  String get commentTitleLabel => '評論 / 標題';

  @override
  String get entryDescriptionHint => '項目描述（選填）';

  @override
  String get triggerKeywordsLabel => '觸發關鍵字';

  @override
  String get triggerKeywordsHint => '以逗號分隔，例如：魔法, 咒語';

  @override
  String get contentLabel => '內容';

  @override
  String get worldEntryContentHint => '關鍵字觸發時注入的背景知識';

  @override
  String get enabledCheckbox => '啟用';

  @override
  String get addMemory => '新增記憶';

  @override
  String get editMemory => '編輯記憶';

  @override
  String get memoryLabelField => '標籤';

  @override
  String get memoryLabelHint => '唯一識別碼，例如：稱呼偏好';

  @override
  String get memoryContentHint => '記憶內容';

  @override
  String get salienceLabel => '重要性：';

  @override
  String get labelCannotBeEmpty => '標籤不能為空';

  @override
  String importSuccess(Object name) {
    return '$name 匯入成功';
  }

  @override
  String importFailed(Object error) {
    return '匯入失敗：$error';
  }

  @override
  String get supportedFormats => '支援格式';

  @override
  String get tavernImportDescription =>
      '• SillyTavern V2 角色卡（.json）\n• 內嵌角色卡的 PNG 圖片（.png）\n\n角色設定、世界書等欄位會自動對應到 Memex 角色格式。';

  @override
  String get pickCharacterFile => '選擇角色檔案';

  @override
  String get repickFile => '選擇其他檔案';

  @override
  String get personaSettingSection => '角色設定';

  @override
  String get systemPromptSection => '系統提示詞';

  @override
  String worldEntriesCount(Object count) {
    return '世界書：$count 個項目';
  }

  @override
  String fileLabel(Object filename) {
    return '檔案：$filename';
  }

  @override
  String conflictWarning(Object names) {
    return '已存在同名角色：$names。匯入會建立新角色，不會覆寫既有角色。';
  }

  @override
  String get setPrimaryCompanionTitle => '設為主要陪伴角色';

  @override
  String get setPrimaryCompanionSubtitle => '匯入後自動設為你的主要陪伴角色';

  @override
  String get confirmImport => '確認匯入';

  @override
  String get chatBackground => '聊天背景';

  @override
  String get chooseChatBackgroundImage => '選擇背景圖片';

  @override
  String get earlyUpdateSettingsTitle => 'Early 版更新';

  @override
  String get earlyUpdateSettingsDesc =>
      '檢查 GitHub 預先發行版本中符合目前 Early APK 的版本，下載後交給 Android 安裝程式。';

  @override
  String get earlyUpdateUnsupported => 'Early 更新僅適用於 Android Early 建置版本。';

  @override
  String get earlyUpdateAutoCheckTitle => '自動檢查更新';

  @override
  String get earlyUpdateAutoCheckDesc => '啟動時檢查，最多每 12 小時一次。';

  @override
  String get earlyUpdateWifiOnlyTitle => '僅透過 Wi-Fi 下載';

  @override
  String get earlyUpdateWifiOnlyDesc => '使用行動數據時略過更新下載。';

  @override
  String get earlyUpdateAutoInstallTitle => '自動下載並安裝';

  @override
  String get earlyUpdateAutoInstallDesc => '找到新建置版本時，自動下載並開啟 Android 安裝程式。';

  @override
  String get earlyUpdateCheckNow => '立即檢查';

  @override
  String get earlyUpdateChecking => '正在檢查 GitHub 預先發行版本...';

  @override
  String get earlyUpdateSkippedMobile => '已略過，因為已啟用僅限 Wi-Fi 下載。';

  @override
  String get earlyUpdateNoUpdate => '你已使用最新版 Early 建置版本。';

  @override
  String earlyUpdateFound(Object version, Object build) {
    return 'Early 建置版本 $version+$build 已可用。';
  }

  @override
  String get earlyUpdateDownloadAndInstall => '下載並安裝';

  @override
  String get earlyUpdateDownloadInProgress => '正在下載更新...';

  @override
  String earlyUpdateDownloadingPercent(Object percent) {
    return '正在下載更新：$percent%';
  }

  @override
  String get earlyUpdateDownloadReadyToInstall => '更新套件已下載。可準備安裝。';

  @override
  String get earlyUpdateInstallDownloadedPackage => '安裝已下載套件';

  @override
  String get earlyUpdateClearDownloadedPackage => '清除已下載套件';

  @override
  String get earlyUpdateClearDownloadedPackageSuccess => '已清除下載的更新套件。';

  @override
  String get earlyUpdateInstallStarted => '已開啟 Android 安裝程式。';

  @override
  String get earlyUpdateInstallPermissionRequired =>
      '請允許 Memex 安裝未知應用程式，然後再次點選下載並安裝。';

  @override
  String earlyUpdateLastChecked(Object time) {
    return '上次檢查：$time';
  }

  @override
  String earlyUpdateCheckFailed(Object error) {
    return '更新檢查失敗：$error';
  }

  @override
  String get earlyUpdateDialogTitle => '有 Early 更新可用';

  @override
  String get earlyUpdateReleaseNotes => '版本說明';

  @override
  String get dismissAllNotifications => '全部清除';

  @override
  String get dismissByType => '依類型清除';

  @override
  String get dismissTypeSystemAction => '提醒與事件';

  @override
  String get dismissTypeClarification => '釐清事項';

  @override
  String get dismissTypeCardUpdate => '卡片更新';

  @override
  String dismissedCount(Object count) {
    return '已清除 $count 項';
  }

  @override
  String get dataImportTitle => '匯入檔案';

  @override
  String get dataImportSettingsDescription => '把舊檔案帶進 Memex，再決定要不要整理。';

  @override
  String get dataImportDescription =>
      '可以選擇以前的筆記、匯出的記錄、文件或 ZIP 壓縮包。Memex 會先保存一份副本，不會修改原檔；匯入後你再決定是否讓 Memex 幫你整理。';

  @override
  String get dataImportSelectFiles => '選擇要匯入的檔案';

  @override
  String get dataImportImporting => '正在保存檔案...';

  @override
  String get dataImportSuccess => '檔案已保存到 Memex';

  @override
  String get dataImportOnlyStored => '檔案已保存，暫不進行整理。';

  @override
  String get dataImportQueued => 'Memex 會在背景整理這次匯入。';

  @override
  String get dataImportResultTitle => '匯入完成';

  @override
  String dataImportResultSummary(Object count) {
    return '已保存 $count 個檔案。你可以現在開始整理，也可以先把它們作為原始資料保留。';
  }

  @override
  String dataImportRenamedConflicts(Object count) {
    return '有 $count 個同名項目已自動改名，避免覆蓋已有內容。';
  }

  @override
  String dataImportSkippedUnsafeEntries(Object count) {
    return '壓縮包中有 $count 個異常項目已略過，其餘內容已正常匯入。';
  }

  @override
  String get dataImportChooseProcessing => '整理這些內容';

  @override
  String get dataImportProcessTitle => '要整理這次匯入嗎？';

  @override
  String dataImportProcessPrompt(Object count) {
    return '這次匯入了 $count 個檔案。你可以讓 Memex 現在幫你整理，也可以只保存原始資料。';
  }

  @override
  String get dataImportProcessKnowledgeBase => '整理到知識庫';

  @override
  String get dataImportProcessKnowledgeBaseDesc =>
      '適合文件、資料、筆記、專案素材。Memex 會提取有用資訊並分類，方便以後查找和複用。';

  @override
  String get dataImportProcessTimelineCards => '生成時間線記錄';

  @override
  String get dataImportProcessTimelineCardsDesc =>
      '適合日記、聊天記錄、活動記錄、歷史匯出。Memex 會把有時間意義的內容整理成記錄。';

  @override
  String get dataImportImpactNone => 'Memex 只會保存這批原始檔案，不會啟動 AI 整理。';

  @override
  String get dataImportImpactKnowledgeBase =>
      'Memex 會閱讀這批檔案，把值得長期保存的資訊整理進知識庫；不會主動生成時間線記錄。';

  @override
  String get dataImportImpactTimelineCards =>
      'Memex 會閱讀這批檔案，把適合記錄生活或事件的內容生成時間線記錄；不會主動整理知識庫。';

  @override
  String get dataImportImpactBoth =>
      'Memex 會同時嘗試生成時間線記錄，並把可複用的資訊整理進知識庫。適合匯入比較完整的歷史資料。';

  @override
  String get dataImportFinish => '先保存即可';

  @override
  String get noImages => '暫無圖片';

  @override
  String get noMessages => '暫無訊息';

  @override
  String get sketchContent => '草圖內容';

  @override
  String get emptyFolder => '空資料夾';

  @override
  String get usernameAlreadyTaken => '使用者名稱已被占用';

  @override
  String get registrationFailed => '註冊失敗';

  @override
  String get loginFailed => '登入失敗';

  @override
  String get paymentCreationFailed => '無法發起付款';

  @override
  String get completePayment => '完成付款';

  @override
  String get commentReplyToYou => '你';

  @override
  String get commentAuthorUser => '用戶';

  @override
  String get commentAuthorAi => 'AI';

  @override
  String get authorizationCancelled => '授權已取消';

  @override
  String timelineWeekNumberLabel(Object week) {
    return '第 $week 週';
  }

  @override
  String get timelineWeekLabel => '週';

  @override
  String get eventCardDefaultTitle => '事件';

  @override
  String get memoryNoLongTermYet => '還沒有長期記憶。';

  @override
  String get memoryNoRecentBuffer => '緩衝區中還沒有近期記憶。';

  @override
  String get memoryGeneralSubject => '通用';
}
