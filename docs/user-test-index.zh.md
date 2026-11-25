# 用户功能测试逐项索引

与[功能地图](user-feature-map.zh.md)配套。按用户任务展开测试文件；每个用例链接到声明位置。业务链单独注明起点与终点。“组件/业务层”涵盖内部断言，以及只验证一段生产链路的用例；“宿主控件”在 Flutter 测试宿主执行。通过状态只针对列出的边界。结果为 2026-11-25 主干基线加本次测试改动的快照；同名参数化用例按实际运行逐条列出。

共 236 个测试源文件。通过 1151，跳过 5。

<a id="tasks"></a>
## 任务、后台与诊断

<details>
<summary>search_event_logs_tool_test.dart · 4 项</summary>

[测试源文件](../test/agent/built_in_tools/search_event_logs_tool_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [renderEventLogSearchResultsForAgent uses stored local time and unix seconds when available](../test/agent/built_in_tools/search_event_logs_tool_test.dart#L6) | 组件/业务层 | 通过 |
| [renderEventLogSearchResultsForAgent falls back to raw event_time for legacy events](../test/agent/built_in_tools/search_event_logs_tool_test.dart#L28) | 组件/业务层 | 通过 |
| [renderEventLogSearchResultsForAgent keeps rendering useful output when legacy time is malformed](../test/agent/built_in_tools/search_event_logs_tool_test.dart#L45) | 组件/业务层 | 通过 |
| [renderEventLogSearchResultsForAgent includes pagination hint only when the page is full](../test/agent/built_in_tools/search_event_logs_tool_test.dart#L63) | 组件/业务层 | 通过 |

</details>

<details>
<summary>agent_background_coordinator_test.dart · 11 项</summary>

[测试源文件](../test/data/services/agent_background_coordinator_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [publishes active status and schedules one drain for a run](../test/data/services/agent_background_coordinator_test.dart#L50) | 组件/业务层 | 通过 |
| [schedules drain from local tasks even when foreground tracker is empty](../test/data/services/agent_background_coordinator_test.dart#L81) | 组件/业务层 | 通过 |
| [defers WorkManager drain while app is foregrounded](../test/data/services/agent_background_coordinator_test.dart#L96) | 组件/业务层 | 通过 |
| [clears completed status and cancels drain when queue empties](../test/data/services/agent_background_coordinator_test.dart#L120) | 组件/业务层 | 通过 |
| [forwards notification tap requests to listeners](../test/data/services/agent_background_coordinator_test.dart#L152) | 组件/业务层 | 通过 |
| [buffers initial notification tap until a listener attaches](../test/data/services/agent_background_coordinator_test.dart#L164) | 组件/业务层 | 通过 |
| [keeps system surface active when error arrives with retryable tasks](../test/data/services/agent_background_coordinator_test.dart#L180) | 组件/业务层 | 通过 |
| [retries publishing after platform update failure](../test/data/services/agent_background_coordinator_test.dart#L209) | 组件/业务层 | 通过 |
| [serializes delayed active publish before terminal publish](../test/data/services/agent_background_coordinator_test.dart#L237) | 组件/业务层 | 通过 |
| [normal app launch keeps tracked task progress visible in foreground](../test/data/services/agent_background_coordinator_test.dart#L275) | 组件/业务层 | 通过 |
| [paused tracked work remains visible and keeps drain scheduled](../test/data/services/agent_background_coordinator_test.dart#L302) | 组件/业务层 | 通过 |

</details>

<details>
<summary>agent_background_platform_test.dart · 3 项</summary>

[测试源文件](../test/data/services/agent_background_platform_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [passes summary through updateAgentStatus platform payload](../test/data/services/agent_background_platform_test.dart#L19) | 组件/业务层 | 通过 |
| [passes summary through finishAgentStatus platform payload](../test/data/services/agent_background_platform_test.dart#L61) | 组件/业务层 | 通过 |
| [emits action event when Android asks Flutter to open agent activity](../test/data/services/agent_background_platform_test.dart#L97) | 组件/业务层 | 通过 |

</details>

<details>
<summary>agent_background_status_test.dart · 12 项</summary>

[测试源文件](../test/data/services/agent_background_status_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [AgentBackgroundStatus stays idle when there are no tasks or terminal messages](../test/data/services/agent_background_status_test.dart#L10) | 组件/业务层 | 通过 |
| [AgentBackgroundStatus uses task snapshot counts for active status](../test/data/services/agent_background_status_test.dart#L23) | 组件/业务层 | 通过 |
| [AgentBackgroundStatus keeps retryable error visible as active while tasks remain](../test/data/services/agent_background_status_test.dart#L62) | 组件/业务层 | 通过 |
| [AgentBackgroundStatus uses activity content as notification summary without title prefix](../test/data/services/agent_background_status_test.dart#L87) | 组件/业务层 | 通过 |
| [AgentBackgroundStatus falls back to activity title when content is blank](../test/data/services/agent_background_status_test.dart#L126) | 组件/业务层 | 通过 |
| [AgentBackgroundStatus treats an empty-queue activity error as stale without a run snapshot](../test/data/services/agent_background_status_test.dart#L150) | 组件/业务层 | 通过 |
| [AgentBackgroundStatus marks terminal stop as completed only after queue is empty](../test/data/services/agent_background_status_test.dart#L173) | 组件/业务层 | 通过 |
| [AgentBackgroundStatus trims multi-line content before sending to platform](../test/data/services/agent_background_status_test.dart#L205) | 组件/业务层 | 通过 |
| [AgentBackgroundStatus uses localized labels for platform-facing background copy](../test/data/services/agent_background_status_test.dart#L232) | 组件/业务层 | 通过 |
| [AgentBackgroundStatus uses foreground tracker task counts for platform status](../test/data/services/agent_background_status_test.dart#L255) | 组件/业务层 | 通过 |
| [AgentBackgroundStatus maps foreground tracker pause to a visible paused platform status](../test/data/services/agent_background_status_test.dart#L286) | 组件/业务层 | 通过 |
| [AgentBackgroundStatus maps foreground tracker attention to a visible needs-attention status](../test/data/services/agent_background_status_test.dart#L317) | 组件/业务层 | 通过 |

</details>

<details>
<summary>agent_foreground_task_tracker_test.dart · 4 项</summary>

[测试源文件](../test/data/services/agent_foreground_task_tracker_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [AgentForegroundTaskTracker tracks active task ids and counts current task statuses](../test/data/services/agent_foreground_task_tracker_test.dart#L22) | 组件/业务层 | 通过 |
| [AgentForegroundTaskTracker removes completed tasks from tracking](../test/data/services/agent_foreground_task_tracker_test.dart#L39) | 组件/业务层 | 通过 |
| [AgentForegroundTaskTracker moves failed tracked tasks to clearable attention state](../test/data/services/agent_foreground_task_tracker_test.dart#L53) | 组件/业务层 | 通过 |
| [AgentForegroundTaskTracker pauses only while tracked active tasks remain](../test/data/services/agent_foreground_task_tracker_test.dart#L75) | 组件/业务层 | 通过 |

</details>

<details>
<summary>agent_queue_background_worker_test.dart · 14 项</summary>

[测试源文件](../test/data/services/agent_queue_background_worker_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [AgentQueueBackgroundWorker recognizes both WorkManager task name and unique work name](../test/data/services/agent_queue_background_worker_test.dart#L45) | 组件/业务层 | 通过 |
| [AgentQueueBackgroundWorker uses KEEP for unique WorkManager drain scheduling](../test/data/services/agent_queue_background_worker_test.dart#L66) | 组件/业务层 | 通过 |
| [AgentQueueBackgroundWorker clamps immediate retry delay to at least thirty seconds](../test/data/services/agent_queue_background_worker_test.dart#L73) | 组件/业务层 | 通过 |
| [AgentQueueBackgroundWorker keeps future retry delay when it is longer than the clamp](../test/data/services/agent_queue_background_worker_test.dart#L86) | 组件/业务层 | 通过 |
| [AgentQueueBackgroundWorker does not initialize task queue when no user is active](../test/data/services/agent_queue_background_worker_test.dart#L95) | 组件/业务层 | 通过 |
| [AgentQueueBackgroundWorker retries a transient database lock before draining queue](../test/data/services/agent_queue_background_worker_test.dart#L115) | 组件/业务层 | 通过 |
| [AgentQueueBackgroundWorker reschedules soon when another executor owns the queue](../test/data/services/agent_queue_background_worker_test.dart#L138) | 组件/业务层 | 通过 |
| [AgentQueueBackgroundWorker does not retry non-database initialization failures](../test/data/services/agent_queue_background_worker_test.dart#L187) | 组件/业务层 | 通过 |
| [AgentQueueBackgroundWorker reschedules when only future retrying tasks remain](../test/data/services/agent_queue_background_worker_test.dart#L204) | 组件/业务层 | 通过 |
| [AgentQueueBackgroundWorker marks tracked foreground work paused when background slice ends with work left](../test/data/services/agent_queue_background_worker_test.dart#L239) | 组件/业务层 | 通过 |
| [AgentQueueBackgroundWorker drains handlers that publish agent activity after init](../test/data/services/agent_queue_background_worker_test.dart#L281) | 组件/业务层 | 通过 |
| [AgentQueueBackgroundWorker refreshes Android surface from live activity while task is processing](../test/data/services/agent_queue_background_worker_test.dart#L334) | 组件/业务层 | 通过 |
| [AgentQueueBackgroundWorker publishes each live activity update while task remains active](../test/data/services/agent_queue_background_worker_test.dart#L392) | 组件/业务层 | 通过 |
| [AgentQueueBackgroundWorker uses latest live activity in final status when retrying work remains](../test/data/services/agent_queue_background_worker_test.dart#L464) | 组件/业务层 | 通过 |

</details>

<details>
<summary>event_log_service_test.dart · 5 项</summary>

[测试源文件](../test/data/services/event_log_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [EventLogService stores agent-readable local time with explicit timezone](../test/data/services/event_log_service_test.dart#L9) | 组件/业务层 | 通过 |
| [EventLogService searches legacy log lines without local-time fields](../test/data/services/event_log_service_test.dart#L44) | 组件/业务层 | 通过 |
| [EventLogService reads the daylight-saving fallback day once](../test/data/services/event_log_service_test.dart#L81) | 组件/业务层 | 通过 |
| [EventLogService applies event type, time range, and pagination filters](../test/data/services/event_log_service_test.dart#L117) | 组件/业务层 | 通过 |
| [EventLogService ignores malformed json lines while keeping valid events](../test/data/services/event_log_service_test.dart#L174) | 组件/业务层 | 通过 |

</details>

<details>
<summary>local_task_executor_test.dart · 34 项</summary>

[测试源文件](../test/data/services/local_task_executor_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [LocalTaskExecutor scheduling getLastTaskByType uses insertion order when createdAt ties](../test/data/services/local_task_executor_test.dart#L26) | 组件/业务层 | 通过 |
| [LocalTaskExecutor scheduling scans past dependency-blocked queue head to run later tasks](../test/data/services/local_task_executor_test.dart#L51) | 组件/业务层 | 通过 |
| [LocalTaskExecutor scheduling fails malformed dependencies and still runs a later valid task](../test/data/services/local_task_executor_test.dart#L99) | 组件/业务层 | 通过 |
| [LocalTaskExecutor scheduling fails a dependent task when a prerequisite failed](../test/data/services/local_task_executor_test.dart#L136) | 组件/业务层 | 通过 |
| [LocalTaskExecutor scheduling runs a wait-for-completion task after its predecessor failed](../test/data/services/local_task_executor_test.dart#L175) | 组件/业务层 | 通过 |
| [LocalTaskExecutor scheduling preserves legacy wait semantics unless a task type opts into hard dependencies](../test/data/services/local_task_executor_test.dart#L217) | 组件/业务层 | 通过 |
| [LocalTaskExecutor scheduling uses only available concurrency slots while backlog remains queued](../test/data/services/local_task_executor_test.dart#L269) | 组件/业务层 | 通过 |
| [LocalTaskExecutor scheduling caps concurrent agent-family tasks while other work can start](../test/data/services/local_task_executor_test.dart#L311) | 组件/业务层 | 通过 |
| [LocalTaskExecutor scheduling scans past capped agent tasks to start other work](../test/data/services/local_task_executor_test.dart#L347) | 组件/业务层 | 通过 |
| [LocalTaskExecutor scheduling serializes tasks that share a concurrency policy key](../test/data/services/local_task_executor_test.dart#L391) | 组件/业务层 | 通过 |
| [LocalTaskExecutor scheduling reports active task activity snapshot](../test/data/services/local_task_executor_test.dart#L448) | 组件/业务层 | 通过 |
| [LocalTaskExecutor scheduling runnable activity excludes dormant future tasks](../test/data/services/local_task_executor_test.dart#L499) | 组件/业务层 | 通过 |
| [LocalTaskExecutor scheduling does not double-claim a task under repeated immediate polls](../test/data/services/local_task_executor_test.dart#L525) | 组件/业务层 | 通过 |
| [LocalTaskExecutor scheduling background drain runs available tasks and leaves future retries](../test/data/services/local_task_executor_test.dart#L559) | 组件/业务层 | 通过 |
| [LocalTaskExecutor scheduling background drain waits for claimed task handlers before returning](../test/data/services/local_task_executor_test.dart#L600) | 组件/业务层 | 通过 |
| [LocalTaskExecutor scheduling data replacement stop waits for active task handlers](../test/data/services/local_task_executor_test.dart#L642) | 组件/业务层 | 通过 |
| [LocalTaskExecutor scheduling data replacement stop resumes polling when the barrier times out](../test/data/services/local_task_executor_test.dart#L675) | 组件/业务层 | 通过 |
| [LocalTaskExecutor scheduling background drain does not reset already processing tasks](../test/data/services/local_task_executor_test.dart#L706) | 组件/业务层 | 通过 |
| [LocalTaskExecutor scheduling foreground start takes over an abandoned foreground lease](../test/data/services/local_task_executor_test.dart#L727) | 组件/业务层 | 通过 |
| [LocalTaskExecutor scheduling background drain does not take over a fresh foreground lease](../test/data/services/local_task_executor_test.dart#L741) | 组件/业务层 | 通过 |
| [LocalTaskExecutor scheduling foreground start does not take over a fresh background lease](../test/data/services/local_task_executor_test.dart#L771) | 组件/业务层 | 通过 |
| [LocalTaskExecutor scheduling background drain requeues orphan processing tasks](../test/data/services/local_task_executor_test.dart#L786) | 组件/业务层 | 通过 |
| [LocalTaskExecutor scheduling background drain can stop an already running executor](../test/data/services/local_task_executor_test.dart#L815) | 组件/业务层 | 通过 |
| [LocalTaskExecutor scheduling background drain respects user-level concurrency policy](../test/data/services/local_task_executor_test.dart#L852) | 组件/业务层 | 通过 |
| [LocalTaskExecutor scheduling background drain respects user-level concurrency across executors](../test/data/services/local_task_executor_test.dart#L906) | 组件/业务层 | 通过 |
| [LocalTaskExecutor crash loop guard clears execution marker after successful task completion](../test/data/services/local_task_executor_test.dart#L972) | 组件/业务层 | 通过 |
| [LocalTaskExecutor crash loop guard clears execution marker when Dart handler failure is retryable](../test/data/services/local_task_executor_test.dart#L992) | 组件/业务层 | 通过 |
| [LocalTaskExecutor crash loop guard first crash-like restart requeues stale processing task](../test/data/services/local_task_executor_test.dart#L1019) | 组件/业务层 | 通过 |
| [LocalTaskExecutor crash loop guard graceful app exit requeues stale task without crash count](../test/data/services/local_task_executor_test.dart#L1041) | 组件/业务层 | 通过 |
| [LocalTaskExecutor crash loop guard keeps separate crash markers for concurrent processing tasks](../test/data/services/local_task_executor_test.dart#L1063) | 组件/业务层 | 通过 |
| [LocalTaskExecutor crash loop guard simulates process death while a real task execution is in progress](../test/data/services/local_task_executor_test.dart#L1101) | 组件/业务层 | 通过 |
| [LocalTaskExecutor crash loop guard second crash-like restart fails task and clears marker](../test/data/services/local_task_executor_test.dart#L1161) | 组件/业务层 | 通过 |
| [LocalTaskExecutor crash loop guard bad dependency JSON fails task instead of leaving it pending forever](../test/data/services/local_task_executor_test.dart#L1182) | 组件/业务层 | 通过 |
| [LocalTaskExecutor crash loop guard reschedules one waiting task per business key](../test/data/services/local_task_executor_test.dart#L1203) | 组件/业务层 | 通过 |

</details>

<details>
<summary>sqlite_busy_retry_test.dart · 4 项</summary>

[测试源文件](../test/data/services/sqlite_busy_retry_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [SqliteBusyRetry recognizes common SQLite busy error variants](../test/data/services/sqlite_busy_retry_test.dart#L9) | 组件/业务层 | 通过 |
| [SqliteBusyRetry retries database locks with linear backoff and returns success](../test/data/services/sqlite_busy_retry_test.dart#L26) | 组件/业务层 | 通过 |
| [SqliteBusyRetry does not retry non-lock failures](../test/data/services/sqlite_busy_retry_test.dart#L49) | 组件/业务层 | 通过 |
| [SqliteBusyRetry rethrows the final database lock failure](../test/data/services/sqlite_busy_retry_test.dart#L67) | 组件/业务层 | 通过 |

</details>

<details>
<summary>super_agent_chat_turn_resume_test.dart · 4 项</summary>

[测试源文件](../test/data/services/super_agent_chat_turn_resume_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [Super Agent chat turn rescheduling normal processing persists one user message](../test/data/services/super_agent_chat_turn_resume_test.dart#L27) | 组件/业务层 | 通过 |
| [Super Agent chat turn rescheduling processing task reset to pending resumes without duplicating user](../test/data/services/super_agent_chat_turn_resume_test.dart#L51) | 组件/业务层 | 通过 |
| [Super Agent chat turn rescheduling retrying after partial commit resumes without duplicating user](../test/data/services/super_agent_chat_turn_resume_test.dart#L80) | 组件/业务层 | 通过 |
| [Super Agent chat turn rescheduling retrying after first LLM failure resumes without duplicating user](../test/data/services/super_agent_chat_turn_resume_test.dart#L124) | 组件/业务层 | 通过 |

</details>

<details>
<summary>agent_activity_widget_test.dart · 9 项</summary>

[测试源文件](../test/ui/agent_activity/agent_activity_widget_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [shows non-interactive processing affordance before task activity](../test/ui/agent_activity/agent_activity_widget_test.dart#L54) | 宿主控件 | 通过 |
| [uses fixed app logo instead of rotating processing frames](../test/ui/agent_activity/agent_activity_widget_test.dart#L74) | 宿主控件 | 通过 |
| [updates background task count while status is visible](../test/ui/agent_activity/agent_activity_widget_test.dart#L96) | 宿主控件 | 通过 |
| [shows background task count before agent tool messages](../test/ui/agent_activity/agent_activity_widget_test.dart#L140) | 宿主控件 | 通过 |
| [shows active task status as a static affordance](../test/ui/agent_activity/agent_activity_widget_test.dart#L166) | 宿主控件 | 通过 |
| [does not show stale non-terminal history without active work](../test/ui/agent_activity/agent_activity_widget_test.dart#L193) | 宿主控件 | 通过 |
| [shows and hides from active task snapshots only](../test/ui/agent_activity/agent_activity_widget_test.dart#L216) | 宿主控件 | 通过 |
| [ignores buffered notification activity action](../test/ui/agent_activity/agent_activity_widget_test.dart#L264) | 宿主控件 | 通过 |
| [notification action leaves the static background status unchanged](../test/ui/agent_activity/agent_activity_widget_test.dart#L286) | 宿主控件 | 通过 |

</details>

<details>
<summary>debug_settings_viewmodel_test.dart · 10 项</summary>

[测试源文件](../test/ui/settings/view_models/debug_settings_viewmodel_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [createReprocessCardsTask starts Super Agent reprocess](../test/ui/settings/view_models/debug_settings_viewmodel_test.dart#L17) | 组件/业务层 | 通过 |
| [createReprocessCardsTask requires a user and resets loading](../test/ui/settings/view_models/debug_settings_viewmodel_test.dart#L37) | 组件/业务层 | 通过 |
| [related follow-up prompt only names available agent capabilities](../test/ui/settings/view_models/debug_settings_viewmodel_test.dart#L51) | 组件/业务层 | 通过 |
| [date range task options format payload consistently](../test/ui/settings/view_models/debug_settings_viewmodel_test.dart#L62) | 组件/业务层 | 通过 |
| [clearToken clears user and resets router state](../test/ui/settings/view_models/debug_settings_viewmodel_test.dart#L78) | 组件/业务层 | 通过 |
| [clearData requires user and clears local data](../test/ui/settings/view_models/debug_settings_viewmodel_test.dart#L89) | 组件/业务层 | 通过 |
| [cloneToTestUser clones, switches user, and resets router state](../test/ui/settings/view_models/debug_settings_viewmodel_test.dart#L101) | 组件/业务层 | 通过 |
| [clearFailedAgentContexts returns cleared count](../test/ui/settings/view_models/debug_settings_viewmodel_test.dart#L131) | 组件/业务层 | 通过 |
| [creates comments reprocess task](../test/ui/settings/view_models/debug_settings_viewmodel_test.dart#L144) | 组件/业务层 | 通过 |
| [rebuildSearchIndex delegates to data controller](../test/ui/settings/view_models/debug_settings_viewmodel_test.dart#L170) | 组件/业务层 | 通过 |

</details>

<details>
<summary>agent_state_viewer_page_test.dart · 2 项</summary>

[测试源文件](../test/ui/settings/widgets/agent_state_viewer_page_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [renders parent state with linked child state ids](../test/ui/settings/widgets/agent_state_viewer_page_test.dart#L20) | 宿主控件 | 通过 |
| [scrolls state content to bottom and top](../test/ui/settings/widgets/agent_state_viewer_page_test.dart#L189) | 宿主控件 | 通过 |

</details>

<details>
<summary>async_task_load_error_test.dart · 1 项</summary>

[测试源文件](../test/ui/settings/widgets/async_task_load_error_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [uses localized operationFailed for load errors](../test/ui/settings/widgets/async_task_load_error_test.dart#L15) | 组件/业务层 | 通过 |

</details>

<details>
<summary>debug_settings_page_test.dart · 5 项</summary>

[测试源文件](../test/ui/settings/widgets/debug_settings_page_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [clears failed agent contexts from debugging page](../test/ui/settings/widgets/debug_settings_page_test.dart#L22) | 宿主控件 | 通过 |
| [disables clear failed contexts while loading](../test/ui/settings/widgets/debug_settings_page_test.dart#L48) | 宿主控件 | 通过 |
| [search result Debug reprocess cards opens dialog and creates task](../test/ui/settings/widgets/debug_settings_page_test.dart#L73) | 宿主控件 | 通过 |
| [reprocess cards dialog defaults to card-only mode](../test/ui/settings/widgets/debug_settings_page_test.dart#L125) | 宿主控件 | 通过 |
| [reprocess cards dialog submits related follow-up scope](../test/ui/settings/widgets/debug_settings_page_test.dart#L160) | 宿主控件 | 通过 |

</details>


<a id="navigation"></a>
## 启动、导航、设置与更新

<details>
<summary>app_startup_test.dart · 1 项</summary>

[测试源文件](../test/app_startup_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [localization finishes before all three independent services start](../test/app_startup_test.dart#L7) | 组件/业务层 | 通过 |

</details>

<details>
<summary>app_update_service_test.dart · 18 项</summary>

[测试源文件](../test/data/services/app_update_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [AppUpdateSettingsStore loads conservative defaults](../test/data/services/app_update_service_test.dart#L52) | 组件/业务层 | 通过 |
| [AppUpdateSettingsStore persists toggles and last check time](../test/data/services/app_update_service_test.dart#L62) | 设置控件→偏好读回 | 通过 |
| [release selection chooses the newest matching pre-release APK above current build](../test/data/services/app_update_service_test.dart#L82) | 组件/业务层 | 通过 |
| [release selection returns null when matching APK is not newer](../test/data/services/app_update_service_test.dart#L111) | 组件/业务层 | 通过 |
| [release selection uses release notes version for Flutter default APK asset names](../test/data/services/app_update_service_test.dart#L128) | 组件/业务层 | 通过 |
| [check/download/install flow still checks releases on mobile data when Wi-Fi-only is enabled](../test/data/services/app_update_service_test.dart#L151) | 组件/业务层 | 通过 |
| [check/download/install flow blocks APK download on mobile data when Wi-Fi-only is enabled](../test/data/services/app_update_service_test.dart#L177) | 组件/业务层 | 通过 |
| [check/download/install flow detects an available update from GitHub pre-releases](../test/data/services/app_update_service_test.dart#L202) | 组件/业务层 | 通过 |
| [check/download/install flow downloads APK and delegates install to Android platform channel](../test/data/services/app_update_service_test.dart#L226) | 组件/业务层 | 通过 |
| [check/download/install flow reuses a complete downloaded APK without fetching again](../test/data/services/app_update_service_test.dart#L264) | 组件/业务层 | 通过 |
| [check/download/install flow coalesces concurrent downloads of the same APK](../test/data/services/app_update_service_test.dart#L284) | 组件/业务层 | 通过 |
| [check/download/install flow does not clear update cache while a download is active](../test/data/services/app_update_service_test.dart#L328) | 组件/业务层 | 通过 |
| [check/download/install flow deletes corrupt partial APK when downloaded size mismatches](../test/data/services/app_update_service_test.dart#L355) | 组件/业务层 | 通过 |
| [check/download/install flow redownloads when cached APK size does not match asset size](../test/data/services/app_update_service_test.dart#L386) | 组件/业务层 | 通过 |
| [check/download/install flow reports and clears downloaded update cache files](../test/data/services/app_update_service_test.dart#L412) | 组件/业务层 | 通过 |
| [check/download/install flow opens unknown-app settings when install permission is missing](../test/data/services/app_update_service_test.dart#L433) | 组件/业务层 | 通过 |
| [check/download/install flow coalesces concurrent install requests for the same APK](../test/data/services/app_update_service_test.dart#L449) | 组件/业务层 | 通过 |
| [check/download/install flow fails install before platform call when APK file is missing](../test/data/services/app_update_service_test.dart#L467) | 组件/业务层 | 通过 |

</details>

<details>
<summary>user_stats_service_test.dart · 3 项</summary>

[测试源文件](../test/data/services/user_stats_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [aggregates user-facing stats from cards and event logs](../test/data/services/user_stats_service_test.dart#L33) | 组件/业务层 | 通过 |
| [falls back to local files when activity events are unavailable](../test/data/services/user_stats_service_test.dart#L198) | 组件/业务层 | 通过 |
| [keeps every civil day across the spring-forward](../test/data/services/user_stats_service_test.dart#L253) | 组件/业务层 | 通过 |

</details>

<details>
<summary>user_stats_model_test.dart · 5 项</summary>

[测试源文件](../test/domain/models/user_stats_model_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [lastDays stays on civil dates across the spring-forward](../test/domain/models/user_stats_model_test.dart#L6) | 组件/业务层 | 通过 |
| [inclusive civil end stays on the fall-back day](../test/domain/models/user_stats_model_test.dart#L21) | 组件/业务层 | 通过 |
| [UserStatsSnapshot trend buckets uses daily buckets for shorter ranges](../test/domain/models/user_stats_model_test.dart#L38) | 组件/业务层 | 通过 |
| [UserStatsSnapshot trend buckets groups ninety-day ranges into seven-day buckets](../test/domain/models/user_stats_model_test.dart#L51) | 组件/业务层 | 通过 |
| [UserStatsSnapshot trend buckets combines and deduplicates details for a bucket](../test/domain/models/user_stats_model_test.dart#L69) | 组件/业务层 | 通过 |

</details>

<details>
<summary>memex_router_init_test.dart · 8 项</summary>

[测试源文件](../test/integration/memex_router_init_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [MemexRouter._init ordering smoke test CardDetailNotifier.init() can be called without error (registers sync subscription on GlobalEventBus)](../test/integration/memex_router_init_test.dart#L8) | 组件/业务层 | 通过 |
| [MemexRouter._init ordering smoke test task handlers are registered before LocalTaskExecutor starts](../test/integration/memex_router_init_test.dart#L16) | 源码约束 | 通过 |
| [MemexRouter._init ordering smoke test primary companion wake loop is restored after task startup](../test/integration/memex_router_init_test.dart#L32) | 源码约束 | 通过 |
| [MemexRouter._init ordering smoke test history acquaintance is scheduled before the initiative wake](../test/integration/memex_router_init_test.dart#L46) | 源码约束 | 通过 |
| [MemexRouter._init ordering smoke test sendMessage waits for full router initialization before delegating](../test/integration/memex_router_init_test.dart#L61) | 源码约束 | 通过 |
| [MemexRouter._init ordering smoke test timeline init completes core before awaiting deferred work](../test/integration/memex_router_init_test.dart#L82) | 源码约束 | 通过 |
| [MemexRouter._init ordering smoke test user changes serialize and invalidate deferred initialization](../test/integration/memex_router_init_test.dart#L102) | 源码约束 | 通过 |
| [MemexRouter._init ordering smoke test fetchTimelineCards waits only for core initialization](../test/integration/memex_router_init_test.dart#L117) | 源码约束 | 通过 |

</details>

<details>
<summary>debug_tools_l10n_test.dart · 1 项</summary>

[测试源文件](../test/l10n/debug_tools_l10n_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [debug tools strings are localized](../test/l10n/debug_tools_l10n_test.dart#L14) | 组件/业务层 | 通过 |

</details>

<details>
<summary>demo_overlay_test.dart · 2 项</summary>

[测试源文件](../test/ui/core/widgets/demo_overlay_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [recovers the spotlight when the target appears later](../test/ui/core/widgets/demo_overlay_test.dart#L23) | 宿主控件 | 通过 |
| [a spotlight tap lands on the button inside the phone column](../test/ui/core/widgets/demo_overlay_test.dart#L70) | 宿主控件 | 通过 |

</details>

<details>
<summary>home_tab_rebuild_test.dart · 1 项</summary>

[测试源文件](../test/ui/main_screen/home_tab_rebuild_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [reading tab view models does not rebuild siblings on notify](../test/ui/main_screen/home_tab_rebuild_test.dart#L10) | 宿主控件 | 通过 |

</details>

<details>
<summary>main_bottom_bar_test.dart · 3 项</summary>

[测试源文件](../test/ui/main_screen/widgets/main_bottom_bar_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [tapping the Timeline label or icon area switches the tab](../test/ui/main_screen/widgets/main_bottom_bar_test.dart#L64) | 宿主控件 | 通过 |
| [tapping the Library tab area switches the tab](../test/ui/main_screen/widgets/main_bottom_bar_test.dart#L88) | 宿主控件 | 通过 |
| [home-indicator inset keeps tab labels above the gesture zone](../test/ui/main_screen/widgets/main_bottom_bar_test.dart#L103) | 宿主控件 | 通过 |

</details>

<details>
<summary>early_update_settings_card_test.dart · 5 项</summary>

[测试源文件](../test/ui/settings/widgets/early_update_settings_card_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [renders defaults and persists Wi-Fi-only toggle](../test/ui/settings/widgets/early_update_settings_card_test.dart#L35) | 宿主控件 | 通过 |
| [manual check reveals update and download opens installer](../test/ui/settings/widgets/early_update_settings_card_test.dart#L54) | 宿主控件 | 通过 |
| [shows active background download and disables manual actions](../test/ui/settings/widgets/early_update_settings_card_test.dart#L83) | 宿主控件 | 通过 |
| [background download becomes installable after polling](../test/ui/settings/widgets/early_update_settings_card_test.dart#L130) | 宿主控件 | 通过 |
| [can install cached update package and clear cache](../test/ui/settings/widgets/early_update_settings_card_test.dart#L173) | 宿主控件 | 通过 |

</details>

<details>
<summary>experimental_lab_page_test.dart · 1 项</summary>

[测试源文件](../test/ui/settings/widgets/experimental_lab_page_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [renders empty labs shell](../test/ui/settings/widgets/experimental_lab_page_test.dart#L16) | 宿主控件 | 通过 |

</details>

<details>
<summary>user_storage_prefs_cache_test.dart · 3 项</summary>

[测试源文件](../test/utils/user_storage_prefs_cache_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [getUserId rereads the mock store through sharedPrefs](../test/utils/user_storage_prefs_cache_test.dart#L15) | 组件/业务层 | 通过 |
| [getUserId treats blank values as logged out](../test/utils/user_storage_prefs_cache_test.dart#L24) | 组件/业务层 | 通过 |
| [sharedPrefs retries after a failed cached initialization](../test/utils/user_storage_prefs_cache_test.dart#L29) | 组件/业务层 | 通过 |

</details>


<a id="restore"></a>
## 备份、还原、迁移与工作区

<details>
<summary>filesystem_root_switch_test.dart · 1 项</summary>

[测试源文件](../test/data/repositories/filesystem_root_switch_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [FileSystemService root switching card writes resolve the active root at call time](../test/data/repositories/filesystem_root_switch_test.dart#L39) | 切换工作区→真实文件落点 | 通过 |

</details>

<details>
<summary>migrate_cards_fact_assets_test.dart · 3 项</summary>

[测试源文件](../test/data/repositories/migrate_cards_fact_assets_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [migrateCardsToFactAssets backfills legacy fact text, assets, and created_at](../test/data/repositories/migrate_cards_fact_assets_test.dart#L34) | 旧数据迁移→卡片文本与附件 | 通过 |
| [migrateCardsToFactAssets v2 backfills missing created_at without clobbering migrated content](../test/data/repositories/migrate_cards_fact_assets_test.dart#L70) | 组件/业务层 | 通过 |
| [migrateCardsToFactAssets reads entry after frontmatter without including later facts](../test/data/repositories/migrate_cards_fact_assets_test.dart#L109) | 组件/业务层 | 通过 |

</details>

<details>
<summary>backup_service_test.dart · 28 项</summary>

[测试源文件](../test/data/services/backup_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [restore brings a deleted journal entry back to Timeline and detail](../test/data/services/backup_service_test.dart#L66) | 备份入口→恢复→时间线与详情原文 | 通过 |
| [createBackup writes manifest and workspace content](../test/data/services/backup_service_test.dart#L98) | 备份入口→归档清单与正文 | 通过 |
| [createBackup excludes device-local notification prompt state](../test/data/services/backup_service_test.dart#L126) | 组件/业务层 | 通过 |
| [createBackup still compresses small text files](../test/data/services/backup_service_test.dart#L154) | 组件/业务层 | 通过 |
| [createBackup stores compressed media without recompressing](../test/data/services/backup_service_test.dart#L171) | 组件/业务层 | 通过 |
| [createBackup stores large files without recompressing](../test/data/services/backup_service_test.dart#L195) | 组件/业务层 | 通过 |
| [restore rejects a backup with a mismatched manifest checksum](../test/data/services/backup_service_test.dart#L235) | 恢复入口→无效归档被拒 | 通过 |
| [automatic backup skips a second run within twenty-four hours](../test/data/services/backup_service_test.dart#L271) | 组件/业务层 | 通过 |
| [automatic backup retention preference defaults and persists](../test/data/services/backup_service_test.dart#L288) | 组件/业务层 | 通过 |
| [automatic backup retention deletes only expired automatic snapshots](../test/data/services/backup_service_test.dart#L326) | 组件/业务层 | 通过 |
| [automatic backup pruning always keeps the newest snapshot](../test/data/services/backup_service_test.dart#L364) | 组件/业务层 | 通过 |
| [automatic backup retention still caps forever history by total size](../test/data/services/backup_service_test.dart#L387) | 组件/业务层 | 通过 |
| [automatic backup skip still prunes expired snapshots](../test/data/services/backup_service_test.dart#L414) | 组件/业务层 | 通过 |
| [deleteStoredBackup removes only the selected local snapshot](../test/data/services/backup_service_test.dart#L444) | 组件/业务层 | 通过 |
| [deleteStoredBackup delegates Android document deletion](../test/data/services/backup_service_test.dart#L485) | 组件/业务层 | 通过 |
| [restore leaves stored backup history files untouched](../test/data/services/backup_service_test.dart#L507) | 组件/业务层 | 通过 |
| [restore stages and applies workspace files from backup](../test/data/services/backup_service_test.dart#L539) | 组件/业务层 | 通过 |
| [restore ignores device-local state contained in an old backup](../test/data/services/backup_service_test.dart#L568) | 组件/业务层 | 通过 |
| [restore resumes a task executor that was running beforehand](../test/data/services/backup_service_test.dart#L599) | 组件/业务层 | 通过 |
| [restore removes workspace files that are not in the backup](../test/data/services/backup_service_test.dart#L620) | 组件/业务层 | 通过 |
| [restore removes stale workspace links without touching their target](../test/data/services/backup_service_test.dart#L654) | 组件/业务层 | 通过 |
| [restore keeps the main isolate responsive while extracting a larger backup](../test/data/services/backup_service_test.dart#L680) | 组件/业务层 | 通过 |
| [createBackup includes rows that were only in the WAL, and restore drops sidecars](../test/data/services/backup_service_test.dart#L738) | 备份→恢复→SQLite 读回 | 通过 |
| [inspectBackup reads backup manifest metadata](../test/data/services/backup_service_test.dart#L810) | 组件/业务层 | 通过 |
| [inspectBackup accepts legacy backup without manifest](../test/data/services/backup_service_test.dart#L833) | 组件/业务层 | 通过 |
| [inspectBackup rejects newer backup schema](../test/data/services/backup_service_test.dart#L842) | 组件/业务层 | 通过 |
| [inspectBackup rejects non-backup extension](../test/data/services/backup_service_test.dart#L859) | 组件/业务层 | 通过 |
| [inspectBackup rejects zip without backup markers](../test/data/services/backup_service_test.dart#L868) | 组件/业务层 | 通过 |

</details>

<details>
<summary>migration_state_service_test.dart · 2 项</summary>

[测试源文件](../test/data/services/migration_state_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [MigrationStateService marks successful migrations and skips later runs](../test/data/services/migration_state_service_test.dart#L28) | 组件/业务层 | 通过 |
| [MigrationStateService does not mark incomplete migrations](../test/data/services/migration_state_service_test.dart#L64) | 组件/业务层 | 通过 |

</details>

<details>
<summary>sandbox_user_clone_service_test.dart · 4 项</summary>

[测试源文件](../test/data/services/sandbox_user_clone_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [clones workspace content while skipping agent runtime state](../test/data/services/sandbox_user_clone_service_test.dart#L36) | 组件/业务层 | 通过 |
| [uses short default test username](../test/data/services/sandbox_user_clone_service_test.dart#L93) | 组件/业务层 | 通过 |
| [increments short default test username when it already exists](../test/data/services/sandbox_user_clone_service_test.dart#L106) | 组件/业务层 | 通过 |
| [overwrites named test workspace when requested](../test/data/services/sandbox_user_clone_service_test.dart#L123) | 组件/业务层 | 通过 |

</details>

<details>
<summary>app_database_connection_test.dart · 2 项</summary>

[测试源文件](../test/db/app_database_connection_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [AppDatabase connection options shares drift connections across isolates](../test/db/app_database_connection_test.dart#L9) | 组件/业务层 | 通过 |
| [AppDatabase connection options configures WAL and busy timeout on native SQLite connections](../test/db/app_database_connection_test.dart#L14) | 组件/业务层 | 通过 |

</details>

<details>
<summary>app_database_migration_test.dart · 2 项</summary>

[测试源文件](../test/db/app_database_migration_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [AppDatabase migrations upgrades schema 14 to 19 with a reply cursor baseline](../test/db/app_database_migration_test.dart#L11) | 组件/业务层 | 通过 |
| [AppDatabase migrations upgrades schema 18 without consuming its pending user message](../test/db/app_database_migration_test.dart#L57) | 组件/业务层 | 通过 |

</details>

<details>
<summary>user_notifications_migration_test.dart · 5 项</summary>

[测试源文件](../test/db/user_notifications_migration_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [UserNotifications migration table is queryable after creation](../test/db/user_notifications_migration_test.dart#L43) | 组件/业务层 | 通过 |
| [UserNotifications migration can insert and query a notification row](../test/db/user_notifications_migration_test.dart#L49) | 组件/业务层 | 通过 |
| [UserNotifications migration payload column is nullable](../test/db/user_notifications_migration_test.dart#L75) | 组件/业务层 | 通过 |
| [UserNotifications migration UNIQUE index rejects duplicate (userId, notificationType, subjectKey) triple](../test/db/user_notifications_migration_test.dart#L94) | 组件/业务层 | 通过 |
| [UserNotifications migration UNIQUE index allows different triples](../test/db/user_notifications_migration_test.dart#L129) | 组件/业务层 | 通过 |

</details>

<details>
<summary>backup_restore_confirm_dialog_test.dart · 4 项</summary>

[测试源文件](../test/ui/settings/widgets/backup_restore_confirm_dialog_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [renders manifest metadata and confirms restore](../test/ui/settings/widgets/backup_restore_confirm_dialog_test.dart#L17) | 确认控件→确认结果 | 通过 |
| [renders legacy backup details and cancels restore](../test/ui/settings/widgets/backup_restore_confirm_dialog_test.dart#L46) | 宿主控件 | 通过 |
| [keeps long metadata readable in a scrollable dialog](../test/ui/settings/widgets/backup_restore_confirm_dialog_test.dart#L73) | 宿主控件 | 通过 |
| [formats byte and gigabyte sizes](../test/ui/settings/widgets/backup_restore_confirm_dialog_test.dart#L100) | 宿主控件 | 通过 |

</details>

<details>
<summary>backup_restore_page_test.dart · 11 项</summary>

[测试源文件](../test/ui/settings/widgets/backup_restore_page_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [renders automatic backup settings and persists toggle](../test/ui/settings/widgets/backup_restore_page_test.dart#L21) | 设置控件→偏好读回 | 通过 |
| [shows estimated backup size and persists retention policy](../test/ui/settings/widgets/backup_restore_page_test.dart#L36) | 宿主控件 | 通过 |
| [shows stored automatic and safety snapshots with restore confirmation](../test/ui/settings/widgets/backup_restore_page_test.dart#L101) | 宿主控件 | 通过 |
| [deletes one backup from a mixed history after confirmation](../test/ui/settings/widgets/backup_restore_page_test.dart#L162) | 宿主控件 | 通过 |
| [manual snapshot button refreshes list and status](../test/ui/settings/widgets/backup_restore_page_test.dart#L246) | 宿主控件 | 通过 |
| [manual snapshot refresh does not rescan estimated source size](../test/ui/settings/widgets/backup_restore_page_test.dart#L288) | 宿主控件 | 通过 |
| [refreshes stored backup list when backup event is emitted](../test/ui/settings/widgets/backup_restore_page_test.dart#L326) | 宿主控件 | 通过 |
| [shows Android backup location picker menu](../test/ui/settings/widgets/backup_restore_page_test.dart#L359) | 宿主控件 | 通过 |
| [opens copyable full backup location details](../test/ui/settings/widgets/backup_restore_page_test.dart#L375) | 宿主控件 | 通过 |
| [shows iOS Files label with full sandbox path in details](../test/ui/settings/widgets/backup_restore_page_test.dart#L400) | 宿主控件 | 通过 |
| [shows Android SAF folder name and URI details](../test/ui/settings/widgets/backup_restore_page_test.dart#L426) | 宿主控件 | 通过 |

</details>


<a id="device"></a>
## 定位、健康、日历与系统动作

<details>
<summary>system_action_skill_test.dart · 5 项</summary>

[测试源文件](../test/agent/skills/manage_system_action/system_action_skill_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [prepares a pending calendar event instead of writing to the device](../test/agent/skills/manage_system_action/system_action_skill_test.dart#L29) | 组件/业务层 | 通过 |
| [prepares a reminder with an explicit due date](../test/agent/skills/manage_system_action/system_action_skill_test.dart#L73) | 组件/业务层 | 通过 |
| [rejects reminders without a due date](../test/agent/skills/manage_system_action/system_action_skill_test.dart#L98) | 组件/业务层 | 通过 |
| [rejects invalid event ranges without creating an action](../test/agent/skills/manage_system_action/system_action_skill_test.dart#L110) | 组件/业务层 | 通过 |
| [skill exposes only the two pending creation tools](../test/agent/skills/manage_system_action/system_action_skill_test.dart#L124) | 组件/业务层 | 通过 |

</details>

<details>
<summary>get_calendar_data_test.dart · 2 项</summary>

[测试源文件](../test/data/repositories/get_calendar_data_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [a card just after local midnight stays on that local day](../test/data/repositories/get_calendar_data_test.dart#L30) | 组件/业务层 | 通过 |
| [a month that contains the DST fallback still returns each day](../test/data/repositories/get_calendar_data_test.dart#L62) | 组件/业务层 | 通过 |

</details>

<details>
<summary>app_action_link_service_test.dart · 4 项</summary>

[测试源文件](../test/data/services/app_action_link_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [AppActionLinkService consumes and clears an initial quick note link once](../test/data/services/app_action_link_service_test.dart#L21) | 组件/业务层 | 通过 |
| [AppActionLinkService forwards event stream links and ignores empty non-string events](../test/data/services/app_action_link_service_test.dart#L48) | 组件/业务层 | 通过 |
| [AppActionLinkService tolerates MissingPluginException from initial link bridge](../test/data/services/app_action_link_service_test.dart#L73) | 组件/业务层 | 通过 |
| [AppActionLinkService dispose cancels event subscription and allows reinitialize](../test/data/services/app_action_link_service_test.dart#L91) | 组件/业务层 | 通过 |

</details>

<details>
<summary>app_action_service_test.dart · 12 项</summary>

[测试源文件](../test/data/services/app_action_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [AppActionService dispatches a supported quick_note action](../test/data/services/app_action_service_test.dart#L18) | 组件/业务层 | 通过 |
| [AppActionService consumePendingAction returns null when no action is queued](../test/data/services/app_action_service_test.dart#L30) | 组件/业务层 | 通过 |
| [AppActionService queues a cold-start action before a listener attaches](../test/data/services/app_action_service_test.dart#L43) | 组件/业务层 | 通过 |
| [AppActionService waits for a pending action that arrives after consumption starts](../test/data/services/app_action_service_test.dart#L56) | 组件/业务层 | 通过 |
| [AppActionService consumePendingAction is idempotent after one consume](../test/data/services/app_action_service_test.dart#L70) | 组件/业务层 | 通过 |
| [AppActionService deduplicates re-delivered action after consumption](../test/data/services/app_action_service_test.dart#L88) | 组件/业务层 | 通过 |
| [AppActionService allows the same action again after resetConsumed](../test/data/services/app_action_service_test.dart#L103) | 组件/业务层 | 通过 |
| [AppActionService allows the same action again after the dedup window](../test/data/services/app_action_service_test.dart#L119) | 组件/业务层 | 通过 |
| [AppActionService ignores unknown action types safely](../test/data/services/app_action_service_test.dart#L135) | 组件/业务层 | 通过 |
| [AppActionService maps memex://quick_note deep link to quick_note action](../test/data/services/app_action_service_test.dart#L144) | 组件/业务层 | 通过 |
| [AppActionService also accepts path-style memex:///quick_note deep link](../test/data/services/app_action_service_test.dart#L152) | 组件/业务层 | 通过 |
| [AppActionService ignores unknown deep link actions safely](../test/data/services/app_action_service_test.dart#L160) | 组件/业务层 | 通过 |

</details>

<details>
<summary>geocoding_service_test.dart · 1 项</summary>

[测试源文件](../test/data/services/geocoding_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [Amap reverse geocoding returns a structured address when key is set](../test/data/services/geocoding_service_test.dart#L13) | 真实地图服务（需密钥） | 跳过 |

</details>

<details>
<summary>health_service_test.dart · 1 项</summary>

[测试源文件](../test/data/services/health_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [iOS registers rich HealthKit metrics, not just steps](../test/data/services/health_service_test.dart#L10) | 平台注册声明 | 通过 |

</details>

<details>
<summary>native_action_service_test.dart · 3 项</summary>

[测试源文件](../test/data/services/native_action_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [forwards calendar events to the native system action channel](../test/data/services/native_action_service_test.dart#L15) | 组件/业务层 | 通过 |
| [forwards reminders to the native system action channel](../test/data/services/native_action_service_test.dart#L45) | 组件/业务层 | 通过 |
| [reports native channel failures without throwing](../test/data/services/native_action_service_test.dart#L69) | 组件/业务层 | 通过 |

</details>

<details>
<summary>system_action_service_test.dart · 4 项</summary>

[测试源文件](../test/data/services/system_action_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [SystemActionService action center dismiss hides pending actions without rejecting source visibility](../test/data/services/system_action_service_test.dart#L28) | 组件/业务层 | 通过 |
| [SystemActionService hard rejection removes actions from fact visibility](../test/data/services/system_action_service_test.dart#L54) | 组件/业务层 | 通过 |
| [SystemActionService applies a valid event through the native bridge and completes it](../test/data/services/system_action_service_test.dart#L77) | 组件/业务层 | 通过 |
| [SystemActionService rejects malformed action data before calling the native bridge](../test/data/services/system_action_service_test.dart#L109) | 组件/业务层 | 通过 |

</details>

<details>
<summary>location_context_config_test.dart · 4 项</summary>

[测试源文件](../test/domain/models/location_context_config_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [LocationContextConfig defaults to disabled until the user opts in](../test/domain/models/location_context_config_test.dart#L6) | 组件/业务层 | 通过 |
| [GeocodedAddress summary respects configured granularity](../test/domain/models/location_context_config_test.dart#L13) | 组件/业务层 | 通过 |
| [CurrentLocationContext fresh reminder tells the agent to prefer current location](../test/domain/models/location_context_config_test.dart#L39) | 组件/业务层 | 通过 |
| [CurrentLocationContext fresh GPS-only context is not injected into agent prompts](../test/domain/models/location_context_config_test.dart#L64) | 组件/业务层 | 通过 |

</details>

<details>
<summary>schedule_retirement_pipeline_test.dart · 1 项</summary>

[测试源文件](../test/integration/schedule_retirement_pipeline_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [retired schedule capability pipeline is unavailable to SuperAgent and blocked from every Timeline ingress](../test/integration/schedule_retirement_pipeline_test.dart#L23) | 组件/业务层 | 通过 |

</details>

<details>
<summary>system_action_card_test.dart · 4 项</summary>

[测试源文件](../test/ui/card_attachments/widgets/system_action_card_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [SystemActionCard renders dismissed actions as still actionable on source cards](../test/ui/card_attachments/widgets/system_action_card_test.dart#L30) | 宿主控件 | 通过 |
| [SystemActionCard keeps rejected actions hidden](../test/ui/card_attachments/widgets/system_action_card_test.dart#L47) | 宿主控件 | 通过 |
| [SystemActionCard does not offer a native write for an unsupported action type](../test/ui/card_attachments/widgets/system_action_card_test.dart#L62) | 宿主控件 | 通过 |
| [SystemActionCard loads a pending artifact with visible confirmation controls](../test/ui/card_attachments/widgets/system_action_card_test.dart#L79) | 宿主控件 | 通过 |

</details>

<details>
<summary>location_context_settings_page_test.dart · 12 项</summary>

[测试源文件](../test/ui/settings/location_context_settings_page_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [updates location context settings from the page](../test/ui/settings/location_context_settings_page_test.dart#L99) | 宿主控件 | 通过 |
| [complex edits stay draft until explicit save](../test/ui/settings/location_context_settings_page_test.dart#L198) | 宿主控件 | 通过 |
| [unsaved changes can be canceled or discarded on back](../test/ui/settings/location_context_settings_page_test.dart#L260) | 宿主控件 | 通过 |
| [renders localized Chinese labels](../test/ui/settings/location_context_settings_page_test.dart#L296) | 宿主控件 | 通过 |
| [enabling location context does not request permission](../test/ui/settings/location_context_settings_page_test.dart#L306) | 宿主控件 | 通过 |
| [test button displays a fresh reverse-geocoded location](../test/ui/settings/location_context_settings_page_test.dart#L324) | 宿主控件 | 通过 |
| [test button displays unavailable status without crashing](../test/ui/settings/location_context_settings_page_test.dart#L379) | 宿主控件 | 通过 |
| [permission guidance can request permission and retest](../test/ui/settings/location_context_settings_page_test.dart#L409) | 宿主控件 | 通过 |
| [service disabled guidance opens location settings](../test/ui/settings/location_context_settings_page_test.dart#L468) | 宿主控件 | 通过 |
| [blocked and approximate states point to app settings](../test/ui/settings/location_context_settings_page_test.dart#L506) | 宿主控件 | 通过 |
| [test button explains GPS-only reverse geocode failure](../test/ui/settings/location_context_settings_page_test.dart#L575) | 宿主控件 | 通过 |
| [test button displays a localized failure message](../test/ui/settings/location_context_settings_page_test.dart#L617) | 宿主控件 | 通过 |

</details>


<a id="assistant"></a>
## 对话、工具与智能整理

<details>
<summary>agent_system_prompt_helper_test.dart · 5 项</summary>

[测试源文件](../test/agent/agent_system_prompt_helper_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [applyPromptConfig keeps messages and tools unchanged when config is empty](../test/agent/agent_system_prompt_helper_test.dart#L7) | 组件/业务层 | 通过 |
| [applyPromptConfig system override takes precedence over replacements](../test/agent/agent_system_prompt_helper_test.dart#L29) | 组件/业务层 | 通过 |
| [applyPromptConfig applies multiple system prompt replacements in order](../test/agent/agent_system_prompt_helper_test.dart#L44) | 组件/业务层 | 通过 |
| [applyPromptConfig returns AgentPromptHookResult and preserves tool parameter mode](../test/agent/agent_system_prompt_helper_test.dart#L59) | 组件/业务层 | 通过 |
| [applyPromptConfig only overrides matching tools](../test/agent/agent_system_prompt_helper_test.dart#L100) | 组件/业务层 | 通过 |

</details>

<details>
<summary>agent_tool_error_result_test.dart · 16 项</summary>

[测试源文件](../test/agent/agent_tool_error_result_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [agent tool error results save_timeline_card with a non-existent fact_id is a tool error](../test/agent/agent_tool_error_result_test.dart#L47) | 组件/业务层 | 通过 |
| [agent tool error results save_timeline_card address schema excludes future destinations](../test/agent/agent_tool_error_result_test.dart#L78) | 组件/业务层 | 通过 |
| [agent tool error results save_timeline_card accepts JSON-encoded list arguments](../test/agent/agent_tool_error_result_test.dart#L96) | 组件/业务层 | 通过 |
| [agent tool error results save_timeline_card still accepts native list arguments](../test/agent/agent_tool_error_result_test.dart#L138) | 组件/业务层 | 通过 |
| [agent tool error results save_timeline_card rejects non-canonical local media refs](../test/agent/agent_tool_error_result_test.dart#L175) | 组件/业务层 | 通过 |
| [agent tool error results save_timeline_card rejects missing local media refs](../test/agent/agent_tool_error_result_test.dart#L209) | 组件/业务层 | 通过 |
| [agent tool error results save_timeline_card does not infer media type from url field names](../test/agent/agent_tool_error_result_test.dart#L240) | 组件/业务层 | 通过 |
| [agent tool error results save_timeline_card rejects non-bare asset refs](../test/agent/agent_tool_error_result_test.dart#L275) | 组件/业务层 | 通过 |
| [agent tool error results save_timeline_card validates custom template url fields](../test/agent/agent_tool_error_result_test.dart#L305) | 组件/业务层 | 通过 |
| [agent tool error results save_timeline_card accepts saved custom HTML templates](../test/agent/agent_tool_error_result_test.dart#L362) | 组件/业务层 | 通过 |
| [agent tool error results get_card_metadata lists native and custom templates together](../test/agent/agent_tool_error_result_test.dart#L424) | 组件/业务层 | 通过 |
| [agent tool error results save_timeline_card rejects malformed JSON list strings](../test/agent/agent_tool_error_result_test.dart#L465) | 组件/业务层 | 通过 |
| [agent tool error results save_timeline_card rejects JSON strings that are not arrays](../test/agent/agent_tool_error_result_test.dart#L487) | 组件/业务层 | 通过 |
| [agent tool error results SaveComment invalid input is marked as a tool error](../test/agent/agent_tool_error_result_test.dart#L513) | 组件/业务层 | 通过 |
| [agent tool error results MemoryRead without a default character is marked as a tool error](../test/agent/agent_tool_error_result_test.dart#L533) | 组件/业务层 | 通过 |
| [agent tool error results search_workspace_event_logs failures are marked as tool errors](../test/agent/agent_tool_error_result_test.dart#L548) | 组件/业务层 | 通过 |

</details>

<details>
<summary>claude_prompt_caching_test.dart · 6 项</summary>

[测试源文件](../test/agent/claude_prompt_caching_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [Claude caching and Memex accounting: https://api.anthropic.com stream=false](../test/agent/claude_prompt_caching_test.dart#L15) | 组件/业务层 | 通过 |
| [Claude caching and Memex accounting: https://api.anthropic.com stream=true](../test/agent/claude_prompt_caching_test.dart#L15) | 组件/业务层 | 通过 |
| [Claude caching and Memex accounting: https://api.minimaxi.com/anthropic stream=false](../test/agent/claude_prompt_caching_test.dart#L15) | 组件/业务层 | 通过 |
| [Claude caching and Memex accounting: https://api.minimaxi.com/anthropic stream=true](../test/agent/claude_prompt_caching_test.dart#L15) | 组件/业务层 | 通过 |
| [Claude caching and Memex accounting: https://api.xiaomimimo.com/anthropic stream=false](../test/agent/claude_prompt_caching_test.dart#L15) | 组件/业务层 | 通过 |
| [Claude caching and Memex accounting: https://api.xiaomimimo.com/anthropic stream=true](../test/agent/claude_prompt_caching_test.dart#L15) | 组件/业务层 | 通过 |

</details>

<details>
<summary>super_agent_context_compressor_test.dart · 2 项</summary>

[测试源文件](../test/agent/memory/super_agent_context_compressor_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [SuperAgentContextCompressor.stripArchivedImageBytes replaces archived image parts with fs path placeholders](../test/agent/memory/super_agent_context_compressor_test.dart#L7) | 组件/业务层 | 通过 |
| [SuperAgentContextCompressor.stripArchivedImageBytes handles missing path metadata and is idempotent](../test/agent/memory/super_agent_context_compressor_test.dart#L42) | 组件/业务层 | 通过 |

</details>

<details>
<summary>mint_and_save_fact_id_test.dart · 10 项</summary>

[测试源文件](../test/agent/mint_and_save_fact_id_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [mint_record_fact_id + status-driven new-card detection mint tool does not accept a content creation date](../test/agent/mint_and_save_fact_id_test.dart#L51) | 组件/业务层 | 通过 |
| [mint_record_fact_id + status-driven new-card detection mint reserves a processing placeholder card](../test/agent/mint_and_save_fact_id_test.dart#L58) | 组件/业务层 | 通过 |
| [mint_record_fact_id + status-driven new-card detection mint can reserve multiple processing placeholder cards](../test/agent/mint_and_save_fact_id_test.dart#L80) | 组件/业务层 | 通过 |
| [mint_record_fact_id + status-driven new-card detection mint then save completes the card and enqueues memory once](../test/agent/mint_and_save_fact_id_test.dart#L102) | 组件/业务层 | 通过 |
| [mint_record_fact_id + status-driven new-card detection re-saving a completed card is an edit and does not re-enqueue](../test/agent/mint_and_save_fact_id_test.dart#L145) | 组件/业务层 | 通过 |
| [mint_record_fact_id + status-driven new-card detection save without minting first is a tool error](../test/agent/mint_and_save_fact_id_test.dart#L189) | 组件/业务层 | 通过 |
| [mint_record_fact_id + status-driven new-card detection editing with only fact preserves the existing assets and title](../test/agent/mint_and_save_fact_id_test.dart#L209) | 组件/业务层 | 通过 |
| [mint_record_fact_id + status-driven new-card detection save accepts bare fs asset refs and stores renderable markdown refs](../test/agent/mint_and_save_fact_id_test.dart#L265) | 组件/业务层 | 通过 |
| [mint_record_fact_id + status-driven new-card detection card cache timeline ordering uses record creation time for new cards](../test/agent/mint_and_save_fact_id_test.dart#L303) | 组件/业务层 | 通过 |
| [mint_record_fact_id + status-driven new-card detection a fact containing an fs:// reference is rejected](../test/agent/mint_and_save_fact_id_test.dart#L343) | 组件/业务层 | 通过 |

</details>

<details>
<summary>state_util_test.dart · 4 项</summary>

[测试源文件](../test/agent/state_util_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [loadOrCreateAgentState repairs legacy assistant thinking into content blocks](../test/agent/state_util_test.dart#L24) | 组件/业务层 | 通过 |
| [loadOrCreateAgentState preserves provider-native content blocks](../test/agent/state_util_test.dart#L64) | 组件/业务层 | 通过 |
| [loadOrCreateAgentState repairs legacy DeepSeek V4 tool-call turns](../test/agent/state_util_test.dart#L90) | 组件/业务层 | 通过 |
| [loadOrCreateAgentState deletes only agent states matching metadata predicate](../test/agent/state_util_test.dart#L120) | 组件/业务层 | 通过 |

</details>

<details>
<summary>super_agent_child_test.dart · 29 项</summary>

[测试源文件](../test/agent/super_agent_child_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [SuperAgent child runtime default child timeout allows long specialist work](../test/agent/super_agent_child_test.dart#L60) | 组件/业务层 | 通过 |
| [SuperAgent child runtime profile none exposes no base tools](../test/agent/super_agent_child_test.dart#L64) | 组件/业务层 | 通过 |
| [SuperAgent child runtime profile read exposes read-only base tools but no write tools](../test/agent/super_agent_child_test.dart#L74) | 组件/业务层 | 通过 |
| [SuperAgent child runtime profile full adds write tools on top of read tools](../test/agent/super_agent_child_test.dart#L87) | 组件/业务层 | 通过 |
| [SuperAgent child runtime restricted read roots keep PKM workers out of Cards](../test/agent/super_agent_child_test.dart#L98) | 组件/业务层 | 通过 |
| [SuperAgent child runtime dynamic_timeline_ui gets scoped file tools injected; base stays bare](../test/agent/super_agent_child_test.dart#L220) | 组件/业务层 | 通过 |
| [SuperAgent child runtime reports child tool progress through delegate progress sink](../test/agent/super_agent_child_test.dart#L251) | 组件/业务层 | 通过 |
| [SuperAgent child runtime pkm overview formats a model-oriented structure tree](../test/agent/super_agent_child_test.dart#L287) | 组件/业务层 | 通过 |
| [SuperAgent child runtime pkm overview reports an empty PKM when the root is missing](../test/agent/super_agent_child_test.dart#L308) | 组件/业务层 | 通过 |
| [SuperAgent child runtime pkm overview marks incomplete trees when truncated](../test/agent/super_agent_child_test.dart#L320) | 组件/业务层 | 通过 |
| [SuperAgent child runtime delegate injects PKM overview reminder into pkm child](../test/agent/super_agent_child_test.dart#L337) | 组件/业务层 | 通过 |
| [SuperAgent child runtime delegate injects latest card metadata reminder into card child](../test/agent/super_agent_child_test.dart#L381) | 组件/业务层 | 通过 |
| [SuperAgent child runtime delegate passes referenced image attachments to child as image parts](../test/agent/super_agent_child_test.dart#L426) | 组件/业务层 | 通过 |
| [SuperAgent child runtime delegate inserts a reminder when an image attachment cannot load](../test/agent/super_agent_child_test.dart#L487) | 组件/业务层 | 通过 |
| [SuperAgent child runtime structured task_content text refs are plain text without asset blocks](../test/agent/super_agent_child_test.dart#L556) | 组件/业务层 | 通过 |
| [SuperAgent child runtime run infers no_op from the final plain-text message](../test/agent/super_agent_child_test.dart#L603) | 组件/业务层 | 通过 |
| [SuperAgent child runtime empty child response retries without spending the last turn](../test/agent/super_agent_child_test.dart#L616) | 组件/业务层 | 通过 |
| [SuperAgent child runtime terminal tool finish_summary completes child without final LLM call](../test/agent/super_agent_child_test.dart#L647) | 组件/业务层 | 通过 |
| [SuperAgent child runtime update insight success output does not expose card paths](../test/agent/super_agent_child_test.dart#L704) | 组件/业务层 | 通过 |
| [SuperAgent child runtime run reports failed when the child errors out](../test/agent/super_agent_child_test.dart#L760) | 组件/业务层 | 通过 |
| [SuperAgent child runtime timed out child cancels the model request and saves state](../test/agent/super_agent_child_test.dart#L780) | 组件/业务层 | 通过 |
| [SuperAgent child runtime delegate rejects nonexistent structured asset refs](../test/agent/super_agent_child_test.dart#L838) | 组件/业务层 | 通过 |
| [SuperAgent child runtime delegate accepts existing structured asset refs](../test/agent/super_agent_child_test.dart#L876) | 组件/业务层 | 通过 |
| [SuperAgent child runtime delegate rejects unknown agent types](../test/agent/super_agent_child_test.dart#L919) | 组件/业务层 | 通过 |
| [SuperAgent child runtime delegate rejects the retired schedule agent type](../test/agent/super_agent_child_test.dart#L954) | 组件/业务层 | 通过 |
| [SuperAgent child runtime delegate allows the fixed research agent type](../test/agent/super_agent_child_test.dart#L992) | 组件/业务层 | 通过 |
| [SuperAgent child runtime delegate schema exposes agent_type instead of profile and skills](../test/agent/super_agent_child_test.dart#L1037) | 组件/业务层 | 通过 |
| [SuperAgent child runtime finish_summary is only exposed by child-specialized skills](../test/agent/super_agent_child_test.dart#L1064) | 组件/业务层 | 通过 |
| [SuperAgent child runtime delegate accepts a fixed agent_type call without profile or skills](../test/agent/super_agent_child_test.dart#L1095) | 组件/业务层 | 通过 |

</details>

<details>
<summary>super_agent_harness_test.dart · 2 项</summary>

[测试源文件](../test/agent/super_agent_harness_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [SuperAgentHarness idle skill tracking persists idle counters in agent metadata across agent recreation](../test/agent/super_agent_harness_test.dart#L8) | 组件/业务层 | 通过 |
| [SuperAgentHarness idle skill tracking resets persisted counter when the optional skill is used](../test/agent/super_agent_harness_test.dart#L38) | 组件/业务层 | 通过 |

</details>

<details>
<summary>super_agent_loop_detector_test.dart · 3 项</summary>

[测试源文件](../test/agent/super_agent_loop_detector_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [SuperAgentLoopDetector does not diagnose non-tool turns based on accumulated loop count](../test/agent/super_agent_loop_detector_test.dart#L7) | 组件/业务层 | 通过 |
| [SuperAgentLoopDetector detects repeated identical tool calls](../test/agent/super_agent_loop_detector_test.dart#L22) | 组件/业务层 | 通过 |
| [SuperAgentLoopDetector canonicalizes argument key order before comparing tool calls](../test/agent/super_agent_loop_detector_test.dart#L34) | 组件/业务层 | 通过 |

</details>

<details>
<summary>chat_artifact_test.dart · 8 项</summary>

[测试源文件](../test/data/model/chat_artifact_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [ChatArtifact schema v2 parses a timeline card artifact with target uri metadata](../test/data/model/chat_artifact_test.dart#L6) | 组件/业务层 | 通过 |
| [ChatArtifact schema v2 parses multiple artifacts and round-trips json](../test/data/model/chat_artifact_test.dart#L29) | 组件/业务层 | 通过 |
| [ChatArtifact schema v2 normalizes knowledge file path for knowledge tab navigation](../test/data/model/chat_artifact_test.dart#L53) | 组件/业务层 | 通过 |
| [ChatArtifact schema v2 keeps each pending system action as a distinct artifact](../test/data/model/chat_artifact_test.dart#L76) | 组件/业务层 | 通过 |
| [ChatArtifact schema v2 rejects missing, malformed, legacy, or unknown artifacts](../test/data/model/chat_artifact_test.dart#L106) | 组件/业务层 | 通过 |
| [ChatTurnArtifactCollector deduplicates by stable UI destination and adds source fields](../test/data/model/chat_artifact_test.dart#L131) | 组件/业务层 | 通过 |
| [ChatTurnArtifactCollector seeds recovered turns and suppresses an identical replay](../test/data/model/chat_artifact_test.dart#L175) | 组件/业务层 | 通过 |
| [ChatArtifactSessionMigration rewrites legacy session artifacts to schema v2 once](../test/data/model/chat_artifact_test.dart#L205) | 组件/业务层 | 通过 |

</details>

<details>
<summary>chat_session_time_context_test.dart · 6 项</summary>

[测试源文件](../test/data/repositories/chat_session_time_context_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [chat session time context hydrates local time fields for legacy session detail](../test/data/repositories/chat_session_time_context_test.dart#L37) | 组件/业务层 | 通过 |
| [chat session time context preserves existing local time fields in session messages](../test/data/repositories/chat_session_time_context_test.dart#L80) | 组件/业务层 | 通过 |
| [chat session time context migrates legacy artifacts in session detail and persists v2](../test/data/repositories/chat_session_time_context_test.dart#L120) | 组件/业务层 | 通过 |
| [chat session time context paginates session detail messages from newest backwards](../test/data/repositories/chat_session_time_context_test.dart#L194) | 组件/业务层 | 通过 |
| [chat session time context adds local time fallback to chat session list rows](../test/data/repositories/chat_session_time_context_test.dart#L251) | 组件/业务层 | 通过 |
| [chat session time context checks one session path without loading session content](../test/data/repositories/chat_session_time_context_test.dart#L284) | 组件/业务层 | 通过 |

</details>

<details>
<summary>chat_error_event_l10n_test.dart · 4 项</summary>

[测试源文件](../test/data/services/chat_error_event_l10n_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [chat send errors use existing l10n strings](../test/data/services/chat_error_event_l10n_test.dart#L21) | 组件/业务层 | 通过 |
| [an empty saved API key is not reported as AI turned off](../test/data/services/chat_error_event_l10n_test.dart#L56) | 组件/业务层 | 通过 |
| [a saved config with no model still says AI is off](../test/data/services/chat_error_event_l10n_test.dart#L119) | 组件/业务层 | 通过 |
| [chat network errors show the network message](../test/data/services/chat_error_event_l10n_test.dart#L148) | 组件/业务层 | 通过 |

</details>

<details>
<summary>chat_run_registry_test.dart · 6 项</summary>

[测试源文件](../test/data/services/chat_run_registry_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [ActiveChatRun.attach replays missed events then continues live, no duplicates](../test/data/services/chat_run_registry_test.dart#L7) | 组件/业务层 | 通过 |
| [ActiveChatRun.attach attach after close replays buffer and completes](../test/data/services/chat_run_registry_test.dart#L26) | 组件/业务层 | 通过 |
| [ActiveChatRun.attach registry tracks and removes runs on close](../test/data/services/chat_run_registry_test.dart#L37) | 组件/业务层 | 通过 |
| [ActiveChatRun.attach getOrStart reuses active run and creates missing run](../test/data/services/chat_run_registry_test.dart#L49) | 组件/业务层 | 通过 |
| [ActiveChatRun.attach multiple attachments receive the same events](../test/data/services/chat_run_registry_test.dart#L63) | 组件/业务层 | 通过 |
| [ActiveChatRun.attach non-replay events are live-only for persisted history events](../test/data/services/chat_run_registry_test.dart#L77) | 组件/业务层 | 通过 |

</details>

<details>
<summary>chat_service_test.dart · 11 项</summary>

[测试源文件](../test/data/services/chat_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [request preparation events announces text preparation before doing any user/session I/O](../test/data/services/chat_service_test.dart#L29) | 组件/业务层 | 通过 |
| [request preparation events announces image preparation before trying to read the file](../test/data/services/chat_service_test.dart#L41) | 组件/业务层 | 通过 |
| [request preparation events rejects empty and whitespace-only requests without preparation](../test/data/services/chat_service_test.dart#L50) | 组件/业务层 | 通过 |
| [isActiveChatTurnTaskForSession matches only active chat turn tasks for the requested session](../test/data/services/chat_service_test.dart#L61) | 组件/业务层 | 通过 |
| [Super Agent chat turn resume guard keeps the running turn id while the agent can still resume](../test/data/services/chat_service_test.dart#L122) | 组件/业务层 | 通过 |
| [Super Agent state refresh creates a new agent state while preserving chat history and old state](../test/data/services/chat_service_test.dart#L162) | 组件/业务层 | 通过 |
| [Super Agent state refresh refuses to refresh while the session has an active queued turn](../test/data/services/chat_service_test.dart#L226) | 组件/业务层 | 通过 |
| [Super Agent state refresh migrates legacy artifacts when loading a session](../test/data/services/chat_service_test.dart#L252) | 组件/业务层 | 通过 |
| [Super Agent state refresh freezes the active agent state id into queued chat turn payload](../test/data/services/chat_service_test.dart#L297) | 组件/业务层 | 通过 |
| [Super Agent state refresh queues a later Super Agent turn behind the previous terminal state](../test/data/services/chat_service_test.dart#L365) | 组件/业务层 | 通过 |
| [Super Agent state refresh replaces a missing session id and persists the new turn](../test/data/services/chat_service_test.dart#L409) | 组件/业务层 | 通过 |

</details>

<details>
<summary>chat_session_storage_test.dart · 10 项</summary>

[测试源文件](../test/data/services/chat_session_storage_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [ChatSessionStorage migrates legacy YAML to metadata JSON and message JSONL](../test/data/services/chat_session_storage_test.dart#L40) | 组件/业务层 | 通过 |
| [ChatSessionStorage recovers a legacy session after the migration marker was completed](../test/data/services/chat_session_storage_test.dart#L104) | 组件/业务层 | 通过 |
| [ChatSessionStorage session listing rescans legacy YAML after migration completion](../test/data/services/chat_session_storage_test.dart#L153) | 组件/业务层 | 通过 |
| [ChatSessionStorage legacy message_count cleanup does not rewrite metadata again](../test/data/services/chat_session_storage_test.dart#L185) | 组件/业务层 | 通过 |
| [ChatSessionStorage appends messages to JSONL and updates metadata only](../test/data/services/chat_session_storage_test.dart#L221) | 组件/业务层 | 通过 |
| [ChatSessionStorage recovers valid messages from an incomplete UTF-8 tail](../test/data/services/chat_session_storage_test.dart#L262) | 组件/业务层 | 通过 |
| [ChatSessionStorage does not repair a tail while the same session is still appending](../test/data/services/chat_session_storage_test.dart#L296) | 组件/业务层 | 通过 |
| [ChatSessionStorage loads paged messages from newest backwards](../test/data/services/chat_session_storage_test.dart#L343) | 组件/业务层 | 通过 |
| [ChatSessionStorage loads paged messages by complete turn groups](../test/data/services/chat_session_storage_test.dart#L393) | 组件/业务层 | 通过 |
| [ChatSessionStorage loads only the latest artifact revision for a recovered turn](../test/data/services/chat_session_storage_test.dart#L480) | 组件/业务层 | 通过 |

</details>

<details>
<summary>file_operation_service_grep_test.dart · 7 项</summary>

[测试源文件](../test/data/services/file_operation_service_grep_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [FileOperationService.grepFiles inline regex flags files_with_matches accepts leading (?i)](../test/data/services/file_operation_service_grep_test.dart#L45) | 组件/业务层 | 通过 |
| [FileOperationService.grepFiles inline regex flags content mode accepts leading (?i) with context and line numbers](../test/data/services/file_operation_service_grep_test.dart#L56) | 组件/业务层 | 通过 |
| [FileOperationService.grepFiles inline regex flags count mode accepts combined leading flags and large head_limit](../test/data/services/file_operation_service_grep_test.dart#L75) | 组件/业务层 | 通过 |
| [FileOperationService.grepFiles inline regex flags leading (?-i) overrides the default case-insensitive search](../test/data/services/file_operation_service_grep_test.dart#L90) | 组件/业务层 | 通过 |
| [FileOperationService.grepFiles ripgrep engine uses real ripgrep syntax when rg is available](../test/data/services/file_operation_service_grep_test.dart#L134) | 组件/业务层 | 通过 |
| [FileOperationService.grepFiles ripgrep engine uses access scope exclusions before invoking directory ripgrep](../test/data/services/file_operation_service_grep_test.dart#L149) | 组件/业务层 | 通过 |
| [FileOperationService.grepFiles ripgrep engine builds directory ripgrep args from access scope](../test/data/services/file_operation_service_grep_test.dart#L169) | 组件/业务层 | 通过 |

</details>

<details>
<summary>live_agent_eval_test.dart · 1 项</summary>

[测试源文件](../test/live_agent_eval_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [Live Agent Evaluation companion + comment agent live run with env config](../test/live_agent_eval_test.dart#L27) | 真实模型条件用例 | 跳过 |

</details>

<details>
<summary>chat_event_batch_test.dart · 2 项</summary>

[测试源文件](../test/ui/chat/chat_event_batch_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [batches token chunks into one flush](../test/ui/chat/chat_event_batch_test.dart#L6) | 组件/业务层 | 通过 |
| [flushes immediately on error so the user sees it now](../test/ui/chat/chat_event_batch_test.dart#L28) | 组件/业务层 | 通过 |

</details>

<details>
<summary>chat_submission_coordinator_test.dart · 3 项</summary>

[测试源文件](../test/ui/chat/chat_submission_coordinator_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [rapid first sends share a session without waiting for the first reply](../test/ui/chat/chat_submission_coordinator_test.dart#L8) | 组件/业务层 | 通过 |
| [failed session creation releases the next send](../test/ui/chat/chat_submission_coordinator_test.dart#L43) | 组件/业务层 | 通过 |
| [disposing does not start a waiting send](../test/ui/chat/chat_submission_coordinator_test.dart#L64) | 组件/业务层 | 通过 |

</details>

<details>
<summary>chat_turn_viewmodel_test.dart · 5 项</summary>

[测试源文件](../test/ui/chat/view_models/chat_turn_viewmodel_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [preparation, queue and execution are distinct request states](../test/ui/chat/view_models/chat_turn_viewmodel_test.dart#L6) | 组件/业务层 | 通过 |
| [closing an old run preserves independent preparation and queued work](../test/ui/chat/view_models/chat_turn_viewmodel_test.dart#L18) | 组件/业务层 | 通过 |
| [finishing submission does not finish the queued turn](../test/ui/chat/view_models/chat_turn_viewmodel_test.dart#L31) | 组件/业务层 | 通过 |
| [late enqueue acknowledgement cannot regress a running or ended turn](../test/ui/chat/view_models/chat_turn_viewmodel_test.dart#L42) | 组件/业务层 | 通过 |
| [preparation errors and stream errors are scoped to their request](../test/ui/chat/view_models/chat_turn_viewmodel_test.dart#L53) | 组件/业务层 | 通过 |

</details>

<details>
<summary>agent_chat_dialog_test.dart · 41 项</summary>

[测试源文件](../test/ui/chat/widgets/agent_chat_dialog_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [preparing and queued requests survive the previous run ending](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L47) | 宿主控件 | 通过 |
| [duplicate attachment leaves queued work on the existing listener](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L84) | 宿主控件 | 通过 |
| [attachment failure does not stop another running request](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L121) | 宿主控件 | 通过 |
| [iOS gallery uses system picker and previews a limited-access selection before export](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L147) | 宿主控件 | 通过 |
| [recommended photo selected through native picker can be deselected by asset ID](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L220) | 宿主控件 | 通过 |
| [gallery preview appears before original export and cannot submit an incomplete attachment](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L283) | 宿主控件 | 通过 |
| [failed gallery originals offer retry and removal without losing the draft](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L341) | 宿主控件 | 通过 |
| [AgentChatDialog layout metrics resolves default sheet and full-screen heights](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L400) | 组件/业务层 | 通过 |
| [AgentChatDialog layout metrics uses rounded sheet corners only outside full screen](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L432) | 组件/业务层 | 通过 |
| [AgentChatDialog layout metrics uses keyboard inset whenever the keyboard is visible and editable](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L443) | 组件/业务层 | 通过 |
| [AgentChatDialog layout metrics does not create an empty assistant bubble for final done chunks](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L471) | 组件/业务层 | 通过 |
| [AgentChatDialog layout metrics requests older history near the top or when content is too short](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L486) | 组件/业务层 | 通过 |
| [AgentChatDialog layout metrics snaps down when the keyboard inset shrinks](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L526) | 组件/业务层 | 通过 |
| [AgentChatDialog layout metrics maps reversed chat list indexes around live status rows](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L543) | 组件/业务层 | 通过 |
| [AgentChatDialog layout metrics formats chat time dividers like persona chat](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L570) | 组件/业务层 | 通过 |
| [AgentChatDialog layout metrics formats token usage without estimated cost](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L583) | 组件/业务层 | 通过 |
| [AgentChatDialog layout metrics shows standalone thinking only before process or reply appears](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L602) | 组件/业务层 | 通过 |
| [AgentChatDialog layout metrics uses final process state instead of historical tool errors](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L636) | 组件/业务层 | 通过 |
| [AgentChatDialog layout metrics shows the photo suggestion status until suggestions resolve](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L662) | 组件/业务层 | 通过 |
| [AgentChatDialog layout metrics explains notification permission only for first eligible Android send](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L689) | 组件/业务层 | 通过 |
| [AgentChatDialog layout metrics keeps original filenames only for selected initial images](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L748) | 组件/业务层 | 通过 |
| [AgentChatDialog layout metrics uses demo send key only while spotlighting super agent publish](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L764) | 组件/业务层 | 通过 |
| [AgentChatDialog layout metrics keeps artifacts attached to the assistant reply item](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L773) | 组件/业务层 | 通过 |
| [AgentChatDialog layout metrics coalesces artifact revisions without changing card order](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L784) | 组件/业务层 | 通过 |
| [AgentChatDialog layout metrics attaches pending artifacts only to the same assistant turn](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L813) | 组件/业务层 | 通过 |
| [AgentChatDialog layout metrics toggles demo overlay suspension for routed detail pages](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L837) | 组件/业务层 | 通过 |
| [AgentChatDialog full-screen affordance starts as a bottom sheet with a full-screen action](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L852) | 宿主控件 | 通过 |
| [AgentChatDialog full-screen affordance keeps the keyboard sheet below the top safe area](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L888) | 宿主控件 | 通过 |
| [AgentChatDialog full-screen affordance expands to full screen and restores the sheet](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L911) | 宿主控件 | 通过 |
| [AgentChatDialog full-screen affordance does not show a loading logo while opening a session](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L967) | 宿主控件 | 通过 |
| [AgentChatDialog full-screen affordance reserves the photo suggestion slot on the first frame](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L978) | 宿主控件 | 通过 |
| [AgentChatDialog full-screen affordance renders selected images through the cached image widget](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L996) | 宿主控件 | 通过 |
| [AgentChatDialog full-screen affordance keeps process thinking and token usage inside details](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L1009) | 宿主控件 | 通过 |
| [AgentChatDialog full-screen affordance shows completed process despite intermediate tool errors](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L1051) | 宿主控件 | 通过 |
| [AgentChatDialog full-screen affordance resolves persisted user image paths as local files](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L1078) | 组件/业务层 | 通过 |
| [AgentChatDialog full-screen affordance keeps header actions inside the compact header on narrow screens](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L1104) | 宿主控件 | 通过 |
| [AgentChatDialog full-screen affordance super agent entry hides chat controls and uses send input](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L1121) | 宿主控件 | 通过 |
| [AgentChatDialog full-screen affordance renders a legacy schedule artifact without a dead link](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L1143) | 宿主控件 | 通过 |
| [AgentChatDialog full-screen affordance renders a system action with inline confirmation controls](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L1175) | 宿主控件 | 通过 |
| [AgentChatDialog full-screen affordance opens knowledge file artifacts with normalized PKM path](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L1229) | 宿主控件 | 通过 |
| [AgentChatDialog full-screen affordance keeps super agent header actions tight to the right edge](../test/ui/chat/widgets/agent_chat_dialog_test.dart#L1274) | 宿主控件 | 通过 |

</details>

<details>
<summary>chat_history_date_test.dart · 3 项</summary>

[测试源文件](../test/ui/chat/widgets/chat_history_date_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [formats UTC session times in local hours](../test/ui/chat/widgets/chat_history_date_test.dart#L16) | 组件/业务层 | 通过 |
| [uses calendar days not 24-hour buckets](../test/ui/chat/widgets/chat_history_date_test.dart#L24) | 组件/业务层 | 通过 |
| [returns empty for null and original for invalid values](../test/ui/chat/widgets/chat_history_date_test.dart#L38) | 组件/业务层 | 通过 |

</details>

<details>
<summary>chat_scroll_throttle_test.dart · 1 项</summary>

[测试源文件](../test/ui/chat/widgets/chat_scroll_throttle_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [throttles chat scroll unless forced](../test/ui/chat/widgets/chat_scroll_throttle_test.dart#L5) | 组件/业务层 | 通过 |

</details>

<details>
<summary>chat_scroll_throttle_widget_test.dart · 7 项</summary>

[测试源文件](../test/ui/chat/widgets/chat_scroll_throttle_widget_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [streamed tokens update the reply without restarting scroll until the 250ms boundary](../test/ui/chat/widgets/chat_scroll_throttle_widget_test.dart#L22) | 宿主控件 | 通过 |
| [completed reply scrolls immediately inside the throttle window](../test/ui/chat/widgets/chat_scroll_throttle_widget_test.dart#L60) | 宿主控件 | 通过 |
| [agent stop scrolls immediately inside the throttle window](../test/ui/chat/widgets/chat_scroll_throttle_widget_test.dart#L60) | 宿主控件 | 通过 |
| [error scrolls immediately inside the throttle window](../test/ui/chat/widgets/chat_scroll_throttle_widget_test.dart#L60) | 宿主控件 | 通过 |
| [approval requests remain visible inside the throttle window](../test/ui/chat/widgets/chat_scroll_throttle_widget_test.dart#L84) | 宿主控件 | 通过 |
| [full-screen action still scrolls inside the throttle window](../test/ui/chat/widgets/chat_scroll_throttle_widget_test.dart#L107) | 宿主控件 | 通过 |
| [disposing with a buffered token cancels pending UI work](../test/ui/chat/widgets/chat_scroll_throttle_widget_test.dart#L126) | 宿主控件 | 通过 |

</details>

<details>
<summary>open_super_agent_dialog_test.dart · 6 项</summary>

[测试源文件](../test/ui/chat/widgets/open_super_agent_dialog_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [returns cached latest Super Agent home session id](../test/ui/chat/widgets/open_super_agent_dialog_test.dart#L23) | 组件/业务层 | 通过 |
| [replaces a stale cached id with the latest home session](../test/ui/chat/widgets/open_super_agent_dialog_test.dart#L41) | 组件/业务层 | 通过 |
| [does not open an unverified cached id when validation fails](../test/ui/chat/widgets/open_super_agent_dialog_test.dart#L65) | 组件/业务层 | 通过 |
| [keeps a missing cached id available for a later iCloud retry](../test/ui/chat/widgets/open_super_agent_dialog_test.dart#L85) | 组件/业务层 | 通过 |
| [restores a legacy assistant session after app preferences are lost](../test/ui/chat/widgets/open_super_agent_dialog_test.dart#L101) | 组件/业务层 | 通过 |
| [waits for session lookup before building chat dialog](../test/ui/chat/widgets/open_super_agent_dialog_test.dart#L119) | 宿主控件 | 通过 |

</details>

<details>
<summary>memory_list_date_test.dart · 2 项</summary>

[测试源文件](../test/ui/memory/widgets/memory_list_date_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [formats UTC instants in local time](../test/ui/memory/widgets/memory_list_date_test.dart#L5) | 组件/业务层 | 通过 |
| [returns empty for missing or invalid values](../test/ui/memory/widgets/memory_list_date_test.dart#L14) | 组件/业务层 | 通过 |

</details>

<details>
<summary>memory_screen_l10n_test.dart · 1 项</summary>

[测试源文件](../test/ui/memory/widgets/memory_screen_l10n_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [MemoryScreen shows localized title and empty states](../test/ui/memory/widgets/memory_screen_l10n_test.dart#L31) | 宿主控件 | 通过 |

</details>

<details>
<summary>mention_parser_test.dart · 7 项</summary>

[测试源文件](../test/utils/mention_parser_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [indexOfStandaloneMention matches a mention surrounded by whitespace](../test/utils/mention_parser_test.dart#L6) | 组件/业务层 | 通过 |
| [indexOfStandaloneMention matches a mention at the start or end of the string](../test/utils/mention_parser_test.dart#L10) | 组件/业务层 | 通过 |
| [indexOfStandaloneMention matches when the mention is followed by punctuation](../test/utils/mention_parser_test.dart#L15) | 组件/业务层 | 通过 |
| [indexOfStandaloneMention does not match a longer token that shares a prefix](../test/utils/mention_parser_test.dart#L21) | 组件/业务层 | 通过 |
| [indexOfStandaloneMention matches non-ASCII mentions with explicit boundaries](../test/utils/mention_parser_test.dart#L28) | 组件/业务层 | 通过 |
| [indexOfStandaloneMention does not match an email-style prefix](../test/utils/mention_parser_test.dart#L33) | 组件/业务层 | 通过 |
| [indexOfStandaloneMention returns the first standalone mention when a prefix also appears](../test/utils/mention_parser_test.dart#L37) | 组件/业务层 | 通过 |

</details>

<details>
<summary>time_context_test.dart · 11 项</summary>

[测试源文件](../test/utils/time_context_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [time context helpers parses Unix seconds without losing precision](../test/utils/time_context_test.dart#L6) | 组件/业务层 | 通过 |
| [time context helpers rounds fractional Unix seconds to milliseconds](../test/utils/time_context_test.dart#L13) | 组件/业务层 | 通过 |
| [time context helpers rejects non numeric Unix seconds](../test/utils/time_context_test.dart#L20) | 组件/业务层 | 通过 |
| [time context helpers parses ISO date strings for local context decoration](../test/utils/time_context_test.dart#L25) | 组件/业务层 | 通过 |
| [time context helpers rejects blank and malformed ISO date strings](../test/utils/time_context_test.dart#L34) | 组件/业务层 | 通过 |
| [time context helpers converts date time to truncated Unix seconds](../test/utils/time_context_test.dart#L40) | 组件/业务层 | 通过 |
| [time context helpers converts parseable date time values to Unix seconds](../test/utils/time_context_test.dart#L48) | 组件/业务层 | 通过 |
| [time context helpers formats timezone offsets with sign and minutes](../test/utils/time_context_test.dart#L56) | 组件/业务层 | 通过 |
| [time context helpers formats local date time with explicit timezone context](../test/utils/time_context_test.dart#L65) | 组件/业务层 | 通过 |
| [time context helpers builds message time prefix with explicit timezone context](../test/utils/time_context_test.dart#L74) | 组件/业务层 | 通过 |
| [time context helpers builds current time reminder with local-time label](../test/utils/time_context_test.dart#L82) | 组件/业务层 | 通过 |

</details>


<a id="media"></a>
## 导入、分享、照片与媒体

<details>
<summary>RunnerTests.swift · 2 项</summary>

[测试源文件](../ios/RunnerTests/RunnerTests.swift)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [testPickerScrollCannotDismissASheet](../ios/RunnerTests/RunnerTests.swift#L10) | iOS 18.6 模拟器 · 原生回调/配置 | 通过 |
| [testGestureDismissalCompletesOnceAndNextPickerCanFinish](../ios/RunnerTests/RunnerTests.swift#L19) | iOS 18.6 模拟器 · 原生回调/配置 | 通过 |

</details>

<details>
<summary>file_tool_view_image_test.dart · 5 项</summary>

[测试源文件](../test/agent/file_tool_view_image_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [view_image tool inlines image and queues it for model-visible messages](../test/agent/file_tool_view_image_test.dart#L29) | 组件/业务层 | 通过 |
| [view_image tool does not require file permission manager read access](../test/agent/file_tool_view_image_test.dart#L84) | 组件/业务层 | 通过 |
| [view_image tool after-tool hook persists viewed image into agent history](../test/agent/file_tool_view_image_test.dart#L122) | 组件/业务层 | 通过 |
| [BatchRead tool uses workspace paths in file headers for direct reads](../test/agent/file_tool_view_image_test.dart#L208) | 组件/业务层 | 通过 |
| [BatchRead tool uses workspace paths in file headers for glob reads](../test/agent/file_tool_view_image_test.dart#L225) | 组件/业务层 | 通过 |

</details>

<details>
<summary>openai_client_image_history_test.dart · 2 项</summary>

[测试源文件](../test/agent/openai_client_image_history_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [StatefulAgent keeps previous-turn ImagePart in the second request](../test/agent/openai_client_image_history_test.dart#L8) | 组件/业务层 | 通过 |
| [OpenAIClient sends historical ImagePart as image_url](../test/agent/openai_client_image_history_test.dart#L43) | 组件/业务层 | 通过 |

</details>

<details>
<summary>asset_reference_service_test.dart · 2 项</summary>

[测试源文件](../test/data/services/asset_reference_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [AssetReferenceService.extractReferences extracts bare fs refs wrapped in markdown-style prose](../test/data/services/asset_reference_service_test.dart#L6) | 组件/业务层 | 通过 |
| [AssetReferenceService.extractReferences cleans file names from inline-code refs](../test/data/services/asset_reference_service_test.dart#L19) | 组件/业务层 | 通过 |

</details>

<details>
<summary>asset_safety_service_test.dart · 16 项</summary>

[测试源文件](../test/data/services/asset_safety_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [asynchronous inspection never performs synchronous file I/O](../test/data/services/asset_safety_service_test.dart#L32) | 组件/业务层 | 通过 |
| [reads safe image dimensions from headers without full decode](../test/data/services/asset_safety_service_test.dart#L46) | 组件/业务层 | 通过 |
| [marks long image unsafe while preserving metadata](../test/data/services/asset_safety_service_test.dart#L63) | 组件/业务层 | 通过 |
| [marks oversized audio unsafe for cloud transcription](../test/data/services/asset_safety_service_test.dart#L78) | 组件/业务层 | 通过 |
| [keeps narrow safe image analyzable while skipping OCR only](../test/data/services/asset_safety_service_test.dart#L94) | 组件/业务层 | 通过 |
| [blocks unknown large image from preview and analysis](../test/data/services/asset_safety_service_test.dart#L107) | 组件/业务层 | 通过 |
| [marks small audio safe for analysis and inline agent use](../test/data/services/asset_safety_service_test.dart#L124) | 组件/业务层 | 通过 |
| [blocks audio with unknown duration from automatic analysis](../test/data/services/asset_safety_service_test.dart#L138) | 组件/业务层 | 通过 |
| [cloud transcription skips unsafe audio before LLM lookup](../test/data/services/asset_safety_service_test.dart#L152) | 组件/业务层 | 通过 |
| [local transcription also skips unsafe audio before model lookup](../test/data/services/asset_safety_service_test.dart#L168) | 组件/业务层 | 通过 |
| [saveAssetFromFile keeps long image and records dimensions safely](../test/data/services/asset_safety_service_test.dart#L185) | 组件/业务层 | 通过 |
| [MediaService imports image using safe header dimensions](../test/data/services/asset_safety_service_test.dart#L208) | 组件/业务层 | 通过 |
| [custom agent skips unsafe inline audio parts](../test/data/services/asset_safety_service_test.dart#L226) | 组件/业务层 | 通过 |
| [custom agent skips unsafe inline image parts](../test/data/services/asset_safety_service_test.dart#L243) | 组件/业务层 | 通过 |
| [custom agent keeps safe inline image parts available](../test/data/services/asset_safety_service_test.dart#L261) | 组件/业务层 | 通过 |
| [photo suggestion skips unsafe image before MLKit processing](../test/data/services/asset_safety_service_test.dart#L279) | 组件/业务层 | 通过 |

</details>

<details>
<summary>clipboard_preview_service_test.dart · 16 项</summary>

[测试源文件](../test/data/services/clipboard_preview_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [ClipboardPreviewService returns text clipboard candidate when it has not been handled](../test/data/services/clipboard_preview_service_test.dart#L61) | 组件/业务层 | 通过 |
| [ClipboardPreviewService trims clipboard text and collapses preview whitespace](../test/data/services/clipboard_preview_service_test.dart#L73) | 组件/业务层 | 通过 |
| [ClipboardPreviewService keeps full plain text while bounding the preview text](../test/data/services/clipboard_preview_service_test.dart#L84) | 组件/业务层 | 通过 |
| [ClipboardPreviewService returns text candidate from native clipboard summary](../test/data/services/clipboard_preview_service_test.dart#L97) | 组件/业务层 | 通过 |
| [ClipboardPreviewService treats image data URI as an image candidate](../test/data/services/clipboard_preview_service_test.dart#L115) | 组件/业务层 | 通过 |
| [ClipboardPreviewService materializes image data URI into a temporary image file](../test/data/services/clipboard_preview_service_test.dart#L129) | 组件/业务层 | 通过 |
| [ClipboardPreviewService treats image file URI as an image candidate](../test/data/services/clipboard_preview_service_test.dart#L144) | 组件/业务层 | 通过 |
| [ClipboardPreviewService ignores blank clipboard text](../test/data/services/clipboard_preview_service_test.dart#L156) | 组件/业务层 | 通过 |
| [ClipboardPreviewService skips fallback when native clipboard summary is empty](../test/data/services/clipboard_preview_service_test.dart#L162) | 组件/业务层 | 通过 |
| [ClipboardPreviewService uses plain text fallback only when native channel is missing](../test/data/services/clipboard_preview_service_test.dart#L172) | 组件/业务层 | 通过 |
| [ClipboardPreviewService ignores binary-looking clipboard text from image bytes](../test/data/services/clipboard_preview_service_test.dart#L180) | 组件/业务层 | 通过 |
| [ClipboardPreviewService ignores replacement-heavy decoded binary clipboard text](../test/data/services/clipboard_preview_service_test.dart#L188) | 组件/业务层 | 通过 |
| [ClipboardPreviewService does not return the same candidate after it is marked handled](../test/data/services/clipboard_preview_service_test.dart#L194) | 组件/业务层 | 通过 |
| [ClipboardPreviewService handled clipboard hashes are scoped per user](../test/data/services/clipboard_preview_service_test.dart#L206) | 组件/业务层 | 通过 |
| [ClipboardPreviewService only suppresses the last handled clipboard token](../test/data/services/clipboard_preview_service_test.dart#L221) | 组件/业务层 | 通过 |
| [ClipboardPreviewService marks clipboard handled when current input already contains it](../test/data/services/clipboard_preview_service_test.dart#L234) | 组件/业务层 | 通过 |

</details>

<details>
<summary>document_text_extraction_service_test.dart · 7 项</summary>

[测试源文件](../test/data/services/document_text_extraction_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [extracts readable text from docx document xml](../test/data/services/document_text_extraction_service_test.dart#L20) | 组件/业务层 | 通过 |
| [extracts Chinese text from docx without garbling](../test/data/services/document_text_extraction_service_test.dart#L46) | 组件/业务层 | 通过 |
| [extracts workbook sheets from xlsx files as markdown tables](../test/data/services/document_text_extraction_service_test.dart#L70) | 组件/业务层 | 通过 |
| [creates an unsupported note for pdf files](../test/data/services/document_text_extraction_service_test.dart#L141) | 组件/业务层 | 通过 |
| [does not generate helper content for directly readable text files](../test/data/services/document_text_extraction_service_test.dart#L175) | 组件/业务层 | 通过 |
| [creates a clear note for legacy doc files](../test/data/services/document_text_extraction_service_test.dart#L188) | 组件/业务层 | 通过 |
| [creates a clear note for legacy xls files](../test/data/services/document_text_extraction_service_test.dart#L201) | 组件/业务层 | 通过 |

</details>

<details>
<summary>file_import_service_test.dart · 7 项</summary>

[测试源文件](../test/data/services/file_import_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [copies arbitrary files into _UserSettings/Imported and renames conflicts](../test/data/services/file_import_service_test.dart#L35) | 文件导入→持久化及冲突重命名 | 通过 |
| [creates agent-readable extracted text files next to documents](../test/data/services/file_import_service_test.dart#L99) | 文档导入→提取的文本文件 | 通过 |
| [creates unsupported extracted text helpers for pdf files](../test/data/services/file_import_service_test.dart#L146) | 组件/业务层 | 通过 |
| [creates persistent fs asset reference helpers next to imported images](../test/data/services/file_import_service_test.dart#L168) | 组件/业务层 | 通过 |
| [does not create asset reference helpers for imported audio files](../test/data/services/file_import_service_test.dart#L225) | 组件/业务层 | 通过 |
| [extracts zip files safely and skips unsafe entries](../test/data/services/file_import_service_test.dart#L258) | 导入归档→实际解压文件 | 通过 |
| [super agent import message scopes processing to selected options](../test/data/services/file_import_service_test.dart#L301) | 组件/业务层 | 通过 |

</details>

<details>
<summary>file_system_service_image_source_test.dart · 1 项</summary>

[测试源文件](../test/data/services/file_system_service_image_source_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [converts fs asset references to local HTTP asset URLs](../test/data/services/file_system_service_image_source_test.dart#L24) | 组件/业务层 | 通过 |

</details>

<details>
<summary>image_preview_cache_service_test.dart · 10 项</summary>

[测试源文件](../test/data/services/image_preview_cache_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [copies small images into the shared max768 cache path](../test/data/services/image_preview_cache_service_test.dart#L23) | 组件/业务层 | 通过 |
| [cached previews never re-inspect the cloud original](../test/data/services/image_preview_cache_service_test.dart#L59) | 组件/业务层 | 通过 |
| [compresses large images into the shared max768 cache path](../test/data/services/image_preview_cache_service_test.dart#L82) | 组件/业务层 | 通过 |
| [a slow download does not block a local preview and duplicate work is shared](../test/data/services/image_preview_cache_service_test.dart#L123) | 组件/业务层 | 通过 |
| [clear waits for active work and new readers regenerate after clearing](../test/data/services/image_preview_cache_service_test.dart#L152) | 组件/业务层 | 通过 |
| [cached previews bypass busy workers and new generation stays bounded](../test/data/services/image_preview_cache_service_test.dart#L189) | 组件/业务层 | 通过 |
| [a failed clear does not poison later preview requests](../test/data/services/image_preview_cache_service_test.dart#L242) | 组件/业务层 | 通过 |
| [clear removes every generated preview](../test/data/services/image_preview_cache_service_test.dart#L261) | 组件/业务层 | 通过 |
| [uses response content type for extensionless network images](../test/data/services/image_preview_cache_service_test.dart#L290) | 组件/业务层 | 通过 |
| [rejects extensionless network responses without an image MIME type](../test/data/services/image_preview_cache_service_test.dart#L326) | 组件/业务层 | 通过 |

</details>

<details>
<summary>llm_image_codec_test.dart · 2 项</summary>

[测试源文件](../test/data/services/llm_image_codec_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [isLlmSafeImageBytes accepts jpeg, png, gif, webp](../test/data/services/llm_image_codec_test.dart#L13) | 组件/业务层 | 通过 |
| [isLlmSafeImageBytes rejects heic ftyp container](../test/data/services/llm_image_codec_test.dart#L31) | 组件/业务层 | 通过 |

</details>

<details>
<summary>local_asset_server_image_preview_test.dart · 1 项</summary>

[测试源文件](../test/data/services/local_asset_server_image_preview_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [serves shared max768 image cache for asset HTTP requests](../test/data/services/local_asset_server_image_preview_test.dart#L42) | 组件/业务层 | 通过 |

</details>

<details>
<summary>local_asset_server_path_test.dart · 1 项</summary>

[测试源文件](../test/data/services/local_asset_server_path_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [rejects encoded parent segments instead of reading outside assets](../test/data/services/local_asset_server_path_test.dart#L22) | 组件/业务层 | 通过 |

</details>

<details>
<summary>native_photo_picker_service_test.dart · 4 项</summary>

[测试源文件](../test/data/services/native_photo_picker_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [returns ordered selections including photos outside library permission](../test/data/services/native_photo_picker_service_test.dart#L16) | 组件/业务层 | 通过 |
| [cancelling leaves selection empty](../test/data/services/native_photo_picker_service_test.dart#L32) | 组件/业务层 | 通过 |
| [preview is available while export waits; failed export can retry](../test/data/services/native_photo_picker_service_test.dart#L38) | 组件/业务层 | 通过 |
| [deduplicates by library id and ignores removed late exports](../test/data/services/native_photo_picker_service_test.dart#L82) | 组件/业务层 | 通过 |

</details>

<details>
<summary>photo_attachment_service_test.dart · 3 项</summary>

[测试源文件](../test/data/services/photo_attachment_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [shares a pending original export and retains its original filename](../test/data/services/photo_attachment_service_test.dart#L10) | 组件/业务层 | 通过 |
| [preserves fallback file behavior and handles missing filename metadata](../test/data/services/photo_attachment_service_test.dart#L33) | 组件/业务层 | 通过 |
| [a removed system photo returns an error instead of a thumbnail attachment](../test/data/services/photo_attachment_service_test.dart#L51) | 组件/业务层 | 通过 |

</details>

<details>
<summary>photo_suggestion_cancellation_test.dart · 3 项</summary>

[测试源文件](../test/data/services/photo_suggestion_cancellation_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [cancels every registered native request exactly once](../test/data/services/photo_suggestion_cancellation_test.dart#L6) | 组件/业务层 | 通过 |
| [does not cancel a native request after it is unregistered](../test/data/services/photo_suggestion_cancellation_test.dart#L24) | 组件/业务层 | 通过 |
| [immediately rejects and cancels requests registered after cancellation](../test/data/services/photo_suggestion_cancellation_test.dart#L39) | 组件/业务层 | 通过 |

</details>

<details>
<summary>photo_thumbnail_service_test.dart · 6 项</summary>

[测试源文件](../test/data/services/photo_thumbnail_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [uses a cancellable single-result iOS delivery mode](../test/data/services/photo_thumbnail_service_test.dart#L16) | 组件/业务层 | 通过 |
| [preheats only newly published Apple picker assets](../test/data/services/photo_thumbnail_service_test.dart#L33) | 组件/业务层 | 通过 |
| [bounds concurrent native thumbnail requests](../test/data/services/photo_thumbnail_service_test.dart#L55) | 组件/业务层 | 通过 |
| [shares requests and cancels native work after the last release](../test/data/services/photo_thumbnail_service_test.dart#L90) | 组件/业务层 | 通过 |
| [removes cancelled queued work before it reaches the loader](../test/data/services/photo_thumbnail_service_test.dart#L119) | 组件/业务层 | 通过 |
| [serves successful thumbnail bytes from the LRU cache](../test/data/services/photo_thumbnail_service_test.dart#L144) | 组件/业务层 | 通过 |

</details>

<details>
<summary>photo_attachments_viewmodel_test.dart · 4 项</summary>

[测试源文件](../test/ui/chat/view_models/photo_attachments_viewmodel_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [publishes immediately, bounds exports, and preserves selection order](../test/ui/chat/view_models/photo_attachments_viewmodel_test.dart#L14) | 组件/业务层 | 通过 |
| [removed and cleared selections never return on late completion](../test/ui/chat/view_models/photo_attachments_viewmodel_test.dart#L40) | 组件/业务层 | 通过 |
| [failed originals block submission and can be retried](../test/ui/chat/view_models/photo_attachments_viewmodel_test.dart#L63) | 组件/业务层 | 通过 |
| [disposing suppresses notifications and skips queued exports](../test/ui/chat/view_models/photo_attachments_viewmodel_test.dart#L81) | 组件/业务层 | 通过 |

</details>

<details>
<summary>reference_asset_formatter_test.dart · 2 项</summary>

[测试源文件](../test/ui/chat/widgets/reference_asset_formatter_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [formats local asset preview urls as fs refs for agent context](../test/ui/chat/widgets/reference_asset_formatter_test.dart#L6) | 组件/业务层 | 通过 |
| [keeps existing fs and remote urls unchanged](../test/ui/chat/widgets/reference_asset_formatter_test.dart#L15) | 组件/业务层 | 通过 |

</details>

<details>
<summary>language_picker_test.dart · 2 项</summary>

[测试源文件](../test/ui/core/widgets/language_picker_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [compact language value stays inline without code or subtitle](../test/ui/core/widgets/language_picker_test.dart#L6) | 宿主控件 | 通过 |
| [shows scalable language list and returns selected tag](../test/ui/core/widgets/language_picker_test.dart#L31) | 宿主控件 | 通过 |

</details>

<details>
<summary>local_image_decode_test.dart · 3 项</summary>

[测试源文件](../test/ui/core/widgets/local_image_decode_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [localImageDecodePixels scales by device pixel ratio](../test/ui/core/widgets/local_image_decode_test.dart#L5) | 组件/业务层 | 通过 |
| [localImageDecodePixels ignores empty or infinite sizes](../test/ui/core/widgets/local_image_decode_test.dart#L10) | 组件/业务层 | 通过 |
| [localImageDecodePixels clamps huge bitmaps](../test/ui/core/widgets/local_image_decode_test.dart#L16) | 组件/业务层 | 通过 |

</details>

<details>
<summary>local_image_provider_test.dart · 3 项</summary>

[测试源文件](../test/ui/core/widgets/local_image_provider_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [provider does not use NetworkImage for remote URLs](../test/ui/core/widgets/local_image_provider_test.dart#L11) | 组件/业务层 | 通过 |
| [provider reports an error instead of hanging on a stalled download](../test/ui/core/widgets/local_image_provider_test.dart#L17) | 组件/业务层 | 通过 |
| [provider applies one timeout across response stages](../test/ui/core/widgets/local_image_provider_test.dart#L47) | 组件/业务层 | 通过 |

</details>

<details>
<summary>local_image_safety_test.dart · 8 项</summary>

[测试源文件](../test/ui/core/widgets/local_image_safety_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [shows a safe placeholder instead of rendering unsafe long image](../test/ui/core/widgets/local_image_safety_test.dart#L40) | 宿主控件 | 通过 |
| [preview source config allows high-pixel phone photos only](../test/ui/core/widgets/local_image_safety_test.dart#L72) | 组件/业务层 | 通过 |
| [shows a safe placeholder for unsafe downloaded network images](../test/ui/core/widgets/local_image_safety_test.dart#L98) | 宿主控件 | 通过 |
| [provider resolves unsafe local images to a transparent placeholder](../test/ui/core/widgets/local_image_safety_test.dart#L126) | 组件/业务层 | 通过 |
| [provider still decodes safe local image pixels](../test/ui/core/widgets/local_image_safety_test.dart#L138) | 组件/业务层 | 通过 |
| [late failure from a recycled image cannot replace the new image](../test/ui/core/widgets/local_image_safety_test.dart#L149) | 宿主控件 | 通过 |
| [slow source inspection leaves the page interactive](../test/ui/core/widgets/local_image_safety_test.dart#L195) | 宿主控件 | 通过 |
| [swiping the detail gallery shows the pixels of the selected attachment](../test/ui/core/widgets/local_image_safety_test.dart#L238) | 详情图集控件→可见页的解码像素 | 通过 |

</details>

<details>
<summary>reliable_asset_picker_test.dart · 4 项</summary>

[测试源文件](../test/ui/core/widgets/reliable_asset_picker_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [keeps Android on the platform default thumbnail backend](../test/ui/core/widgets/reliable_asset_picker_test.dart#L12) | 组件/业务层 | 通过 |
| [Android picker config preserves the original image-only behavior](../test/ui/core/widgets/reliable_asset_picker_test.dart#L23) | 组件/业务层 | 通过 |
| [shows loading, retries once, and offers a manual retry](../test/ui/core/widgets/reliable_asset_picker_test.dart#L32) | 宿主控件 | 通过 |
| [cancels native work when a recycled grid cell is disposed](../test/ui/core/widgets/reliable_asset_picker_test.dart#L75) | 宿主控件 | 通过 |

</details>

<details>
<summary>clipboard_preview_card_test.dart · 2 项</summary>

[测试源文件](../test/ui/main_screen/widgets/clipboard_preview_card_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [renders compact preview and exposes paste and dismiss actions](../test/ui/main_screen/widgets/clipboard_preview_card_test.dart#L17) | 宿主控件 | 通过 |
| [renders image clipboard candidate with add image action](../test/ui/main_screen/widgets/clipboard_preview_card_test.dart#L59) | 宿主控件 | 通过 |

</details>

<details>
<summary>share_intent_handler_test.dart · 9 项</summary>

[测试源文件](../test/ui/main_screen/widgets/share_intent_handler_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [shared document files are routed to import without model config](../test/ui/main_screen/widgets/share_intent_handler_test.dart#L18) | 组件/业务层 | 通过 |
| [memex backup shares still route to restore](../test/ui/main_screen/widgets/share_intent_handler_test.dart#L51) | 组件/业务层 | 通过 |
| [image-only shares still open a draft without model config](../test/ui/main_screen/widgets/share_intent_handler_test.dart#L74) | 组件/业务层 | 通过 |
| [file attachments with image extensions still open a draft](../test/ui/main_screen/widgets/share_intent_handler_test.dart#L100) | 组件/业务层 | 通过 |
| [generic non-image file shares route to import](../test/ui/main_screen/widgets/share_intent_handler_test.dart#L124) | 组件/业务层 | 通过 |
| [mixed file shares import all attachments](../test/ui/main_screen/widgets/share_intent_handler_test.dart#L149) | 组件/业务层 | 通过 |
| [external opened image files open a draft without model config](../test/ui/main_screen/widgets/share_intent_handler_test.dart#L178) | 组件/业务层 | 通过 |
| [external opened non-image files route to import](../test/ui/main_screen/widgets/share_intent_handler_test.dart#L196) | 组件/业务层 | 通过 |
| [external opened mixed files route all files to import](../test/ui/main_screen/widgets/share_intent_handler_test.dart#L214) | 组件/业务层 | 通过 |

</details>

<details>
<summary>data_import_page_test.dart · 1 项</summary>

[测试源文件](../test/ui/settings/widgets/data_import_page_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [processing dialog updates impact text as options change](../test/ui/settings/widgets/data_import_page_test.dart#L17) | 宿主控件 | 通过 |

</details>


<a id="privacy"></a>
## 应用锁与隐私

<details>
<summary>app_entry_pin_test.dart · 1 项</summary>

[测试源文件](../test/ui/app_lock/app_entry_pin_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [a protected route is reachable only after the saved PIN](../test/ui/app_lock/app_entry_pin_test.dart#L10) | 应用锁键盘→受保护路由可操作（宿主） | 通过 |

</details>

<details>
<summary>app_lock_session_test.dart · 6 项</summary>

[测试源文件](../test/ui/app_lock/app_lock_session_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [backgrounding before the PIN does not unlock on resume](../test/ui/app_lock/app_lock_session_test.dart#L7) | 内部状态机 | 通过 |
| [an unlocked session returns without a PIN inside the grace period](../test/ui/app_lock/app_lock_session_test.dart#L19) | 内部状态机 | 通过 |
| [grace expiry asks for the PIN again](../test/ui/app_lock/app_lock_session_test.dart#L34) | 内部状态机 | 通过 |
| [a second pause after grace expiry still requires the PIN](../test/ui/app_lock/app_lock_session_test.dart#L47) | 内部状态机 | 通过 |
| [foreground and background transitions never authenticate a locked reader](../test/ui/app_lock/app_lock_session_test.dart#L64) | 内部状态机 | 通过 |
| [lock disabled leaves the session open across pause](../test/ui/app_lock/app_lock_session_test.dart#L90) | 内部状态机 | 通过 |

</details>


<a id="voice"></a>
## 录音、转写和语气

<details>
<summary>vocal_tone_test.dart · 7 项</summary>

[测试源文件](../test/domain/models/vocal_tone_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [SenseVoice angry tag becomes a tone and unknown tags do not](../test/domain/models/vocal_tone_test.dart#L7) | 组件/业务层 | 通过 |
| [laughter and crying events count when emotion is missing](../test/domain/models/vocal_tone_test.dart#L20) | 组件/业务层 | 通过 |
| [a disabled setting never asks the cloud model](../test/domain/models/vocal_tone_test.dart#L31) | 组件/业务层 | 通过 |
| [an on device tone is kept and the cloud is not called](../test/domain/models/vocal_tone_test.dart#L46) | 组件/业务层 | 通过 |
| [a failed cloud description leaves the transcript alone](../test/domain/models/vocal_tone_test.dart#L62) | 组件/业务层 | 通过 |
| [a cloud tone block is parsed and appended](../test/domain/models/vocal_tone_test.dart#L74) | 组件/业务层 | 通过 |
| [a cloud reply without a tone block is ignored](../test/domain/models/vocal_tone_test.dart#L98) | 组件/业务层 | 通过 |

</details>

<details>
<summary>local_speech_settings_copy_test.dart · 2 项</summary>

[测试源文件](../test/l10n/local_speech_settings_copy_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [en local-STT description describes cloud transcription, not raw attach](../test/l10n/local_speech_settings_copy_test.dart#L6) | 组件/业务层 | 通过 |
| [zh local-STT description describes cloud transcription, not raw attach](../test/l10n/local_speech_settings_copy_test.dart#L13) | 组件/业务层 | 通过 |

</details>

<details>
<summary>quick_recording_transcript_test.dart · 5 项</summary>

[测试源文件](../test/ui/main_screen/quick_recording_transcript_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [finalizeQuickRecordingTranscript empty PCM does not transcribe and keeps existing text](../test/ui/main_screen/quick_recording_transcript_test.dart#L8) | 转写函数与注入回调 | 通过 |
| [finalizeQuickRecordingTranscript non-empty PCM always calls transcribe and returns its text](../test/ui/main_screen/quick_recording_transcript_test.dart#L24) | 转写函数与注入回调 | 通过 |
| [finalizeQuickRecordingTranscript empty transcript keeps existing text for the caller toast path](../test/ui/main_screen/quick_recording_transcript_test.dart#L42) | 转写函数与注入回调 | 通过 |
| [finalizeQuickRecordingTranscript failed or empty final passes preserve every existing draft](../test/ui/main_screen/quick_recording_transcript_test.dart#L60) | 转写函数与注入回调 | 通过 |
| [finalizeQuickRecordingTranscript transcribe failure preserves text and surfaces error](../test/ui/main_screen/quick_recording_transcript_test.dart#L78) | 转写函数与注入回调 | 通过 |

</details>

<details>
<summary>vocal_tone_settings_card_test.dart · 1 项</summary>

[测试源文件](../test/ui/settings/widgets/vocal_tone_settings_card_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [vocal tone starts off and the switch reports the new value](../test/ui/settings/widgets/vocal_tone_settings_card_test.dart#L17) | 宿主控件 | 通过 |

</details>


<a id="permissions"></a>
## 授权与工具边界

<details>
<summary>agent_action_approval_service_test.dart · 6 项</summary>

[测试源文件](../test/agent/run_mode/agent_action_approval_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [AgentRunMode fromWire parses wire names and falls back to auto](../test/agent/run_mode/agent_action_approval_service_test.dart#L9) | 组件/业务层 | 通过 |
| [AgentActionApprovalService auto-denies when no UI is attached to the session](../test/agent/run_mode/agent_action_approval_service_test.dart#L19) | 组件/业务层 | 通过 |
| [AgentActionApprovalService resolves approval when UI approves](../test/agent/run_mode/agent_action_approval_service_test.dart#L28) | 组件/业务层 | 通过 |
| [AgentActionApprovalService resolves denial when UI denies](../test/agent/run_mode/agent_action_approval_service_test.dart#L51) | 组件/业务层 | 通过 |
| [AgentActionApprovalService detachSession denies everything still pending](../test/agent/run_mode/agent_action_approval_service_test.dart#L70) | 组件/业务层 | 通过 |
| [AgentActionApprovalService resolve is idempotent for unknown ids](../test/agent/run_mode/agent_action_approval_service_test.dart#L86) | 组件/业务层 | 通过 |

</details>

<details>
<summary>file_permission_manager_test.dart · 3 项</summary>

[测试源文件](../test/agent/security/file_permission_manager_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [FilePermissionManager.buildSearchAccessScope exports denied subtrees as directory-search exclusions](../test/agent/security/file_permission_manager_test.dart#L22) | 组件/业务层 | 通过 |
| [FilePermissionManager.buildSearchAccessScope disables directory search when denied subtree has readable override](../test/agent/security/file_permission_manager_test.dart#L47) | 组件/业务层 | 通过 |
| [FilePermissionManager.buildSearchAccessScope ignores denied rules outside the requested search root](../test/agent/security/file_permission_manager_test.dart#L77) | 组件/业务层 | 通过 |

</details>

<details>
<summary>super_agent_permissions_test.dart · 20 项</summary>

[测试源文件](../test/agent/super_agent_permissions_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [SuperAgent file permissions (normal mode) non-asset files under Facts are read-only](../test/agent/super_agent_permissions_test.dart#L29) | 组件/业务层 | 通过 |
| [SuperAgent file permissions (normal mode) moving or removing a Facts directory is denied (write on source)](../test/agent/super_agent_permissions_test.dart#L39) | 组件/业务层 | 通过 |
| [SuperAgent file permissions (normal mode) permission denial message does not expose absolute paths](../test/agent/super_agent_permissions_test.dart#L47) | 组件/业务层 | 通过 |
| [SuperAgent file permissions (normal mode) media files under assets stay writable](../test/agent/super_agent_permissions_test.dart#L63) | 组件/业务层 | 通过 |
| [SuperAgent file permissions (normal mode) the rest of the workspace stays writable](../test/agent/super_agent_permissions_test.dart#L68) | 组件/业务层 | 通过 |
| [SuperAgent file permissions (quick query) everything is read-only including assets](../test/agent/super_agent_permissions_test.dart#L78) | 组件/业务层 | 通过 |
| [SuperAgent quick query tools does not expose event log search or current time tools](../test/agent/super_agent_permissions_test.dart#L94) | 组件/业务层 | 通过 |
| [SuperAgent quick query tools allows image viewing as a read-only tool](../test/agent/super_agent_permissions_test.dart#L105) | 组件/业务层 | 通过 |
| [SuperAgent quick query tools allows generic LS for read-only filesystem access](../test/agent/super_agent_permissions_test.dart#L109) | 组件/业务层 | 通过 |
| [SuperAgent quick query tools excludes the mutating calendar and reminder skill](../test/agent/super_agent_permissions_test.dart#L113) | 组件/业务层 | 通过 |
| [SuperAgent quick query tools excludes the memory write skill](../test/agent/super_agent_permissions_test.dart#L122) | 组件/业务层 | 通过 |
| [SuperAgent quick query tools excludes the mutating PKM skill](../test/agent/super_agent_permissions_test.dart#L126) | 组件/业务层 | 通过 |
| [SuperAgent run limits root agent allows long import and organization runs](../test/agent/super_agent_permissions_test.dart#L132) | 组件/业务层 | 通过 |
| [SuperAgent legacy active skills drops stale active skill names before agent tools are composed](../test/agent/super_agent_permissions_test.dart#L139) | 组件/业务层 | 通过 |
| [SuperAgent transient pre-minted record reminder matches only the empty processing placeholder](../test/agent/super_agent_permissions_test.dart#L160) | 组件/业务层 | 通过 |
| [SuperAgent transient pre-minted record reminder annotates the matching user message only in model requests](../test/agent/super_agent_permissions_test.dart#L213) | 组件/业务层 | 通过 |
| [SuperAgent transient pre-minted record reminder does not append when no pre-minted fact_id exists](../test/agent/super_agent_permissions_test.dart#L241) | 组件/业务层 | 通过 |
| [SuperAgent transient pre-minted record reminder reuses persisted same-turn fact_id after task restart](../test/agent/super_agent_permissions_test.dart#L255) | 组件/业务层 | 通过 |
| [SuperAgent transient pre-minted record reminder keeps same-turn fact_id when a running agent will retry](../test/agent/super_agent_permissions_test.dart#L277) | 组件/业务层 | 通过 |
| [SuperAgent transient pre-minted record reminder annotates the matching history user message after the id is used](../test/agent/super_agent_permissions_test.dart#L322) | 组件/业务层 | 通过 |

</details>


<a id="notifications"></a>
## 提醒与卡片评论

<details>
<summary>timeline_comment_journey_test.dart · 1 项</summary>

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [open a listed entry, post and reply, then reopen the correct thread](../test/data/repositories/timeline_comment_journey_test.dart#L17) | 写卡→列表→发表评论与回复→详情读回及卡片隔离 | 通过 |

</details>

<details>
<summary>comment_agent_policy_live_test.dart · 3 项</summary>

[测试源文件](../test/agent/comment_agent_policy_live_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [CommentAgent live comment policy evaluation normal mode skips a trivial purchase record](../test/agent/comment_agent_policy_live_test.dart#L69) | 真实模型条件用例 | 跳过 |
| [CommentAgent live comment policy evaluation normal mode replies to an emotionally loaded record](../test/agent/comment_agent_policy_live_test.dart#L99) | 真实模型条件用例 | 跳过 |
| [CommentAgent live comment policy evaluation force reply mode replies even when the record is otherwise skippable](../test/agent/comment_agent_policy_live_test.dart#L130) | 真实模型条件用例 | 跳过 |

</details>

<details>
<summary>comment_agent_policy_test.dart · 4 项</summary>

[测试源文件](../test/agent/comment_agent_policy_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [CommentAgent policy routing normal mode exposes SaveComment and SkipComment](../test/agent/comment_agent_policy_test.dart#L31) | 组件/业务层 | 通过 |
| [CommentAgent policy routing force reply mode removes SkipComment and requires SaveComment](../test/agent/comment_agent_policy_test.dart#L41) | 组件/业务层 | 通过 |
| [CommentAgent policy routing counselor default persona includes a comment policy](../test/agent/comment_agent_policy_test.dart#L52) | 组件/业务层 | 通过 |
| [CommentAgent policy routing comment prompt supports policy based skipping in normal mode](../test/agent/comment_agent_policy_test.dart#L64) | 组件/业务层 | 通过 |

</details>

<details>
<summary>comment_tool_factory_test.dart · 6 项</summary>

[测试源文件](../test/agent/comment_tool_factory_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [CommentToolFactory SaveComment reply routing forcedReplyToId pins AI reply to the user comment even when the model supplies the original character comment id](../test/agent/comment_tool_factory_test.dart#L72) | 组件/业务层 | 通过 |
| [CommentToolFactory SaveComment reply routing forcedReplyToId still attaches to the user comment when the model leaves reply_to_id empty](../test/agent/comment_tool_factory_test.dart#L93) | 组件/业务层 | 通过 |
| [CommentToolFactory SaveComment reply routing without forcedReplyToId, SaveComment treats a self-reply as top-level](../test/agent/comment_tool_factory_test.dart#L112) | 组件/业务层 | 通过 |
| [CommentToolFactory SaveComment reply routing without forcedReplyToId, SaveComment preserves a valid model-supplied reply target for character-to-character interactions](../test/agent/comment_tool_factory_test.dart#L131) | 组件/业务层 | 通过 |
| [CommentToolFactory SaveComment reply routing empty reply_to_id is normalized to a top-level comment](../test/agent/comment_tool_factory_test.dart#L151) | 组件/业务层 | 通过 |
| [CommentToolFactory SaveComment reply routing SkipComment completes without writing a visible comment](../test/agent/comment_tool_factory_test.dart#L167) | 组件/业务层 | 通过 |

</details>

<details>
<summary>card_reply_name_test.dart · 3 项</summary>

[测试源文件](../test/data/repositories/card_reply_name_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [withResolvedReplyNames resolves an AI reply to a user comment as the display name](../test/data/repositories/card_reply_name_test.dart#L7) | 组件/业务层 | 通过 |
| [withResolvedReplyNames resolves an AI reply to another character by character name](../test/data/repositories/card_reply_name_test.dart#L42) | 组件/业务层 | 通过 |
| [withResolvedReplyNames does not use a raw userId as the user display name](../test/data/repositories/card_reply_name_test.dart#L77) | 组件/业务层 | 通过 |

</details>

<details>
<summary>card_detail_notifier_test.dart · 18 项</summary>

[测试源文件](../test/data/services/card_detail_notifier_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [CardDetailNotifier.computeSignals comments list length +1 triggers &quot;comments&quot; signal](../test/data/services/card_detail_notifier_test.dart#L74) | 组件/业务层 | 通过 |
| [CardDetailNotifier.computeSignals comments list length -1 triggers &quot;comments&quot; signal](../test/data/services/card_detail_notifier_test.dart#L91) | 组件/业务层 | 通过 |
| [CardDetailNotifier.computeSignals comment content change triggers &quot;comments&quot; signal](../test/data/services/card_detail_notifier_test.dart#L108) | 组件/业务层 | 通过 |
| [CardDetailNotifier.computeSignals null before (insert) with comments triggers &quot;comments&quot; signal](../test/data/services/card_detail_notifier_test.dart#L129) | 组件/业务层 | 通过 |
| [CardDetailNotifier.computeSignals null after (delete) with comments in before triggers &quot;comments&quot;](../test/data/services/card_detail_notifier_test.dart#L140) | 组件/业务层 | 通过 |
| [CardDetailNotifier.computeSignals identical comments produce no &quot;comments&quot; signal](../test/data/services/card_detail_notifier_test.dart#L151) | 组件/业务层 | 通过 |
| [CardDetailNotifier.computeSignals insight text change triggers &quot;insight&quot; signal](../test/data/services/card_detail_notifier_test.dart#L162) | 组件/业务层 | 通过 |
| [CardDetailNotifier.computeSignals insight summary change triggers &quot;insight&quot; signal](../test/data/services/card_detail_notifier_test.dart#L184) | 组件/业务层 | 通过 |
| [CardDetailNotifier.computeSignals insight related_facts reorder does NOT trigger (sorted comparison)](../test/data/services/card_detail_notifier_test.dart#L204) | 组件/业务层 | 通过 |
| [CardDetailNotifier.computeSignals insight character_id change does NOT trigger &quot;insight&quot; signal](../test/data/services/card_detail_notifier_test.dart#L231) | 组件/业务层 | 通过 |
| [CardDetailNotifier.computeSignals unrelated field-only mutations (title, tags, address, user_fixed_*) return empty set](../test/data/services/card_detail_notifier_test.dart#L253) | 组件/业务层 | 通过 |
| [CardDetailNotifier.computeSignals both null before and after returns empty set](../test/data/services/card_detail_notifier_test.dart#L289) | 组件/业务层 | 通过 |
| [CardDetailNotifier._handle branches delete op → exactly one dismissBy, zero upsert](../test/data/services/card_detail_notifier_test.dart#L329) | 组件/业务层 | 通过 |
| [CardDetailNotifier._handle branches empty-diff update → zero writes](../test/data/services/card_detail_notifier_test.dart#L347) | 组件/业务层 | 通过 |
| [CardDetailNotifier._handle branches foreground factId + non-empty diff → dismissBy only](../test/data/services/card_detail_notifier_test.dart#L375) | 组件/业务层 | 通过 |
| [CardDetailNotifier._handle branches non-foreground + non-empty diff with no existing row → upsert with the computed signals](../test/data/services/card_detail_notifier_test.dart#L396) | 组件/业务层 | 通过 |
| [CardDetailNotifier._handle branches non-foreground + non-empty diff with an existing row → upsert with set-union of stored and new signals](../test/data/services/card_detail_notifier_test.dart#L421) | 组件/业务层 | 通过 |
| [CardDetailNotifier._handle branches non-card namespace event is ignored](../test/data/services/card_detail_notifier_test.dart#L457) | 组件/业务层 | 通过 |

</details>

<details>
<summary>notifications_before_login_test.dart · 1 项</summary>

[测试源文件](../test/data/services/notifications_before_login_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [service methods return sentinels when DB is not initialized](../test/data/services/notifications_before_login_test.dart#L6) | 组件/业务层 | 通过 |

</details>

<details>
<summary>comment_reply_target_test.dart · 3 项</summary>

[测试源文件](../test/data/services/task_handlers/comment_reply_target_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [resolveReplyTargetCharacterId direct reply to an AI comment uses that character](../test/data/services/task_handlers/comment_reply_target_test.dart#L38) | 组件/业务层 | 通过 |
| [resolveReplyTargetCharacterId reply to a user comment walks the chain to the thread owner](../test/data/services/task_handlers/comment_reply_target_test.dart#L43) | 组件/业务层 | 通过 |
| [resolveReplyTargetCharacterId unknown or cyclic reply ids return null](../test/data/services/task_handlers/comment_reply_target_test.dart#L48) | 组件/业务层 | 通过 |

</details>

<details>
<summary>user_notification_service_test.dart · 6 项</summary>

[测试源文件](../test/data/services/user_notification_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [UserNotificationService upsert first upsert inserts a new row](../test/data/services/user_notification_service_test.dart#L21) | 通知业务入口→真实 SQLite 读回 | 通过 |
| [UserNotificationService upsert second upsert with same triple updates in place, bumps updatedAt, does NOT add a row](../test/data/services/user_notification_service_test.dart#L44) | 通知业务入口→真实 SQLite 读回 | 通过 |
| [UserNotificationService dismiss dismiss(id) deletes exactly one row](../test/data/services/user_notification_service_test.dart#L91) | 通知业务入口→真实 SQLite 读回 | 通过 |
| [UserNotificationService dismiss dismissBy(triple) deletes exactly one row](../test/data/services/user_notification_service_test.dart#L116) | 通知业务入口→真实 SQLite 读回 | 通过 |
| [UserNotificationService list list(userA) never returns userB rows](../test/data/services/user_notification_service_test.dart#L147) | 通知业务入口→真实 SQLite 读回 | 通过 |
| [UserNotificationService list list with notificationType filter works](../test/data/services/user_notification_service_test.dart#L180) | 通知业务入口→真实 SQLite 读回 | 通过 |

</details>

<details>
<summary>card_detail_notification_e2e_test.dart · 7 项</summary>

[测试源文件](../test/integration/card_detail_notification_e2e_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [End-to-end event-to-notification smoke test card change with comments diff → one row lands in notifications with expected payload](../test/integration/card_detail_notification_e2e_test.dart#L157) | 事件→内存替身 | 通过 |
| [End-to-end event-to-notification smoke test register factId as foreground → simulate another event → verify dismissBy was called (no upsert)](../test/integration/card_detail_notification_e2e_test.dart#L206) | 事件→内存替身 | 通过 |
| [End-to-end event-to-notification smoke test delete event → verify dismissBy was called](../test/integration/card_detail_notification_e2e_test.dart#L284) | 事件→内存替身 | 通过 |
| [End-to-end event-to-notification smoke test full lifecycle: create → foreground suppress → delete cleanup](../test/integration/card_detail_notification_e2e_test.dart#L342) | 事件→内存替身 | 通过 |
| [End-to-end event-to-notification smoke test non-card namespace events are ignored](../test/integration/card_detail_notification_e2e_test.dart#L463) | 事件→内存替身 | 通过 |
| [End-to-end event-to-notification smoke test update with no relevant diff (only title change) → no notification](../test/integration/card_detail_notification_e2e_test.dart#L482) | 事件→内存替身 | 通过 |
| [End-to-end event-to-notification smoke test signal merge: comments then insight → merged payload](../test/integration/card_detail_notification_e2e_test.dart#L528) | 事件→内存替身 | 通过 |

</details>


<a id="timeline"></a>
## 查找、筛选、时间线和详情

<details>
<summary>dynamic_timeline_ui_skill_test.dart · 12 项</summary>

[测试源文件](../test/agent/skills/dynamic_timeline_ui_skill_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [DynamicTimelineUiSkill registers expected tool names](../test/agent/skills/dynamic_timeline_ui_skill_test.dart#L33) | 组件/业务层 | 通过 |
| [DynamicTimelineUiSkill strips markdown html code fences](../test/agent/skills/dynamic_timeline_ui_skill_test.dart#L64) | 组件/业务层 | 通过 |
| [DynamicTimelineUiSkill rejects executable html](../test/agent/skills/dynamic_timeline_ui_skill_test.dart#L74) | 组件/业务层 | 通过 |
| [DynamicTimelineUiSkill recommends visual memory pattern for image-heavy intent](../test/agent/skills/dynamic_timeline_ui_skill_test.dart#L89) | 组件/业务层 | 通过 |
| [DynamicTimelineUiSkill pattern examples are accepted by timeline html sanitizer](../test/agent/skills/dynamic_timeline_ui_skill_test.dart#L99) | 组件/业务层 | 通过 |
| [DynamicTimelineUiSkill save_timeline_template requires view.html to exist](../test/agent/skills/dynamic_timeline_ui_skill_test.dart#L108) | 组件/业务层 | 通过 |
| [DynamicTimelineUiSkill preview can target a saved template id](../test/agent/skills/dynamic_timeline_ui_skill_test.dart#L138) | 组件/业务层 | 通过 |
| [DynamicTimelineUiSkill preview can target an existing template id](../test/agent/skills/dynamic_timeline_ui_skill_test.dart#L154) | 组件/业务层 | 通过 |
| [DynamicTimelineUiSkill preview fills HTML placeholders with data before rendering](../test/agent/skills/dynamic_timeline_ui_skill_test.dart#L170) | 组件/业务层 | 通过 |
| [DynamicTimelineUiSkill saves timeline template metadata for existing HTML](../test/agent/skills/dynamic_timeline_ui_skill_test.dart#L190) | 组件/业务层 | 通过 |
| [DynamicTimelineUiSkill adds current state reminder when overwriting template field schema](../test/agent/skills/dynamic_timeline_ui_skill_test.dart#L261) | 组件/业务层 | 通过 |
| [DynamicTimelineUiSkill adds current state reminder when replacing existing template data](../test/agent/skills/dynamic_timeline_ui_skill_test.dart#L348) | 组件/业务层 | 通过 |

</details>

<details>
<summary>timeline_diagnostics_skill_test.dart · 4 项</summary>

[测试源文件](../test/agent/skills/timeline_diagnostics_skill_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [TimelineDiagnosticsSkill registers focused diagnostic tools](../test/agent/skills/timeline_diagnostics_skill_test.dart#L33) | 组件/业务层 | 通过 |
| [TimelineDiagnosticsSkill search without query returns recent cards with local time](../test/agent/skills/timeline_diagnostics_skill_test.dart#L46) | 组件/业务层 | 通过 |
| [TimelineDiagnosticsSkill inspect returns original input context and current card data without comments](../test/agent/skills/timeline_diagnostics_skill_test.dart#L68) | 组件/业务层 | 通过 |
| [TimelineDiagnosticsSkill returns structured not found result for missing card](../test/agent/skills/timeline_diagnostics_skill_test.dart#L115) | 组件/业务层 | 通过 |

</details>

<details>
<summary>get_aggregated_timeline_week_test.dart · 1 项</summary>

[测试源文件](../test/data/repositories/get_aggregated_timeline_week_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [week labels use German week label](../test/data/repositories/get_aggregated_timeline_week_test.dart#L16) | 组件/业务层 | 通过 |

</details>

<details>
<summary>hydrate_card_cache_test.dart · 4 项</summary>

[测试源文件](../test/data/repositories/hydrate_card_cache_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [reuses the same hydrated card when YAML has not changed](../test/data/repositories/hydrate_card_cache_test.dart#L30) | 组件/业务层 | 通过 |
| [misses the cache after the card YAML changes](../test/data/repositories/hydrate_card_cache_test.dart#L55) | 组件/业务层 | 通过 |
| [does not reuse hydrated cards across users with matching YAML](../test/data/repositories/hydrate_card_cache_test.dart#L95) | 组件/业务层 | 通过 |
| [clearUser invalidates only the selected workspace](../test/data/repositories/hydrate_card_cache_test.dart#L131) | 组件/业务层 | 通过 |

</details>

<details>
<summary>timeline_pagination_property_test.dart · 3 项</summary>

[测试源文件](../test/data/repositories/timeline_pagination_property_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [Timeline pages match surviving entries after rebuild (seed 7)](../test/data/repositories/timeline_pagination_property_test.dart#L18) | 文件写改删→真实筛选分页与原文 | 通过 |
| [Timeline pages match surviving entries after rebuild (seed 31)](../test/data/repositories/timeline_pagination_property_test.dart#L18) | 文件写改删→真实筛选分页与原文 | 通过 |
| [Timeline pages match surviving entries after rebuild (seed 71)](../test/data/repositories/timeline_pagination_property_test.dart#L18) | 文件写改删→真实筛选分页与原文 | 通过 |

</details>

<details>
<summary>timeline_period_label_locale_test.dart · 2 项</summary>

[测试源文件](../test/data/repositories/timeline_period_label_locale_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [day labels use the active locale weekday name](../test/data/repositories/timeline_period_label_locale_test.dart#L17) | 组件/业务层 | 通过 |
| [month labels use the active locale month name](../test/data/repositories/timeline_period_label_locale_test.dart#L26) | 组件/业务层 | 通过 |

</details>

<details>
<summary>update_card_location_test.dart · 1 项</summary>

[测试源文件](../test/data/repositories/update_card_location_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [updateCardLocation stores card override and reusable location mark](../test/data/repositories/update_card_location_test.dart#L47) | 修改入口→地点、事件与复用 | 通过 |

</details>

<details>
<summary>update_card_ui_config_test.dart · 1 项</summary>

[测试源文件](../test/data/repositories/update_card_ui_config_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [publishes card UI config update event after writing task data](../test/data/repositories/update_card_ui_config_test.dart#L45) | 组件/业务层 | 通过 |

</details>

<details>
<summary>card_attachment_batch_test.dart · 3 项</summary>

[测试源文件](../test/data/services/card_attachment_batch_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [mergeAttachmentsForFacts groups two queries by fact id](../test/data/services/card_attachment_batch_test.dart#L6) | 组件/业务层 | 通过 |
| [mergeAttachmentsForFacts is stable for the same sort key](../test/data/services/card_attachment_batch_test.dart#L50) | 组件/业务层 | 通过 |
| [mergeAttachmentsForFacts returns an empty map for no facts](../test/data/services/card_attachment_batch_test.dart#L82) | 组件/业务层 | 通过 |

</details>

<details>
<summary>card_files_in_date_range_test.dart · 2 项</summary>

[测试源文件](../test/data/services/card_files_in_date_range_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [returns yaml cards for the requested days from one month folder](../test/data/services/card_files_in_date_range_test.dart#L24) | 组件/业务层 | 通过 |
| [includes the civil day after a daylight-saving fallback](../test/data/services/card_files_in_date_range_test.dart#L52) | 组件/业务层 | 通过 |

</details>

<details>
<summary>card_renderer_test.dart · 3 项</summary>

[测试源文件](../test/data/services/card_renderer_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [renderCard replaces fs:// urls inside legacy_html html field](../test/data/services/card_renderer_test.dart#L25) | 组件/业务层 | 通过 |
| [replaceFsInData only converts canonical fs refs](../test/data/services/card_renderer_test.dart#L69) | 组件/业务层 | 通过 |
| [renderCard prefers saved HTML template over built-in template id](../test/data/services/card_renderer_test.dart#L109) | 组件/业务层 | 通过 |

</details>

<details>
<summary>file_system_service_publish_test.dart · 6 项</summary>

[测试源文件](../test/data/services/file_system_service_publish_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [FileSystemService publish contract — DataChangeRecord construction safeWriteCardFile on non-existent file → event op == insert, before == null, after == new map](../test/data/services/file_system_service_publish_test.dart#L51) | 组件/业务层 | 通过 |
| [FileSystemService publish contract — DataChangeRecord construction safeWriteCardFile over existing file → event op == update, before == old, after == new](../test/data/services/file_system_service_publish_test.dart#L91) | 组件/业务层 | 通过 |
| [FileSystemService publish contract — DataChangeRecord construction deleteCard on existing file → op == delete, before == old, after == null](../test/data/services/file_system_service_publish_test.dart#L136) | 组件/业务层 | 通过 |
| [FileSystemService publish contract — DataChangeRecord construction deleteCard on already-missing file → NO event published](../test/data/services/file_system_service_publish_test.dart#L174) | 组件/业务层 | 通过 |
| [FileSystemService publish contract — DataChangeRecord construction op is determined from caller intent, not from snapshot presence (update with before == null for corrupt YAML)](../test/data/services/file_system_service_publish_test.dart#L193) | 组件/业务层 | 通过 |
| [FileSystemService publish contract — DataChangeRecord construction published event has correct source and namespace](../test/data/services/file_system_service_publish_test.dart#L230) | 组件/业务层 | 通过 |

</details>

<details>
<summary>search_service_test.dart · 3 项</summary>

[测试源文件](../test/data/services/search_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [SearchService FTS enqueue filtering skips card updates when only comments change](../test/data/services/search_service_test.dart#L7) | 组件/业务层 | 通过 |
| [SearchService FTS enqueue filtering enqueues card updates when fact changes](../test/data/services/search_service_test.dart#L36) | 组件/业务层 | 通过 |
| [SearchService FTS enqueue filtering enqueues card updates when indexed fields change](../test/data/services/search_service_test.dart#L59) | 组件/业务层 | 通过 |

</details>

<details>
<summary>timeline_card_event_publisher_test.dart · 4 项</summary>

[测试源文件](../test/data/services/timeline_card_event_publisher_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [emits a processing placeholder without rendering templates](../test/data/services/timeline_card_event_publisher_test.dart#L30) | 组件/业务层 | 通过 |
| [emits removal for an unused processing placeholder](../test/data/services/timeline_card_event_publisher_test.dart#L62) | 组件/业务层 | 通过 |
| [emits card added with rendered card fields](../test/data/services/timeline_card_event_publisher_test.dart#L76) | 组件/业务层 | 通过 |
| [emits card updated with failure reason](../test/data/services/timeline_card_event_publisher_test.dart#L114) | 组件/业务层 | 通过 |

</details>

<details>
<summary>timeline_card_visibility_test.dart · 3 项</summary>

[测试源文件](../test/domain/models/timeline_card_visibility_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [isRetiredTimelineCard recognizes the legacy schedule briefing id](../test/domain/models/timeline_card_visibility_test.dart#L7) | 组件/业务层 | 通过 |
| [isRetiredTimelineCard recognizes legacy schedule briefing template copies](../test/domain/models/timeline_card_visibility_test.dart#L19) | 组件/业务层 | 通过 |
| [isRetiredTimelineCard keeps normal timeline cards visible](../test/domain/models/timeline_card_visibility_test.dart#L31) | 组件/业务层 | 通过 |

</details>

<details>
<summary>classic_card_status_test.dart · 1 项</summary>

[测试源文件](../test/ui/core/cards/classic_card_status_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [failed classic card exposes the failure reason sheet](../test/ui/core/cards/classic_card_status_test.dart#L15) | 宿主控件 | 通过 |

</details>

<details>
<summary>gallery_card_l10n_test.dart · 8 项</summary>

[测试源文件](../test/ui/core/cards/templates/gallery_card_l10n_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [GalleryCard with empty image_urls shows noImages](../test/ui/core/cards/templates/gallery_card_l10n_test.dart#L37) | 宿主控件 | 通过 |
| [ConversationCard with empty messages shows noMessages](../test/ui/core/cards/templates/gallery_card_l10n_test.dart#L48) | 宿主控件 | 通过 |
| [CanvasCard with no image_url shows sketchContent](../test/ui/core/cards/templates/gallery_card_l10n_test.dart#L59) | 宿主控件 | 通过 |
| [Spanish template gallery uses localized labels](../test/ui/core/cards/templates/gallery_card_l10n_test.dart#L70) | 组件/业务层 | 通过 |
| [Arabic template gallery uses localized section titles](../test/ui/core/cards/templates/gallery_card_l10n_test.dart#L77) | 组件/业务层 | 通过 |
| [Japanese template gallery uses localized insight titles](../test/ui/core/cards/templates/gallery_card_l10n_test.dart#L84) | 组件/业务层 | 通过 |
| [Italian template gallery is localized](../test/ui/core/cards/templates/gallery_card_l10n_test.dart#L90) | 组件/业务层 | 通过 |
| [localized multiline gallery content contains real newlines](../test/ui/core/cards/templates/gallery_card_l10n_test.dart#L98) | 组件/业务层 | 通过 |

</details>

<details>
<summary>task_card_test.dart · 2 项</summary>

[测试源文件](../test/ui/core/cards/templates/temporal/task_card_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [parent completion updates every grouped subtask](../test/ui/core/cards/templates/temporal/task_card_test.dart#L6) | 宿主控件 | 通过 |
| [last completed subtask completes the parent task](../test/ui/core/cards/templates/temporal/task_card_test.dart#L43) | 宿主控件 | 通过 |

</details>

<details>
<summary>timeline_viewmodel_test.dart · 11 项</summary>

[测试源文件](../test/ui/timeline/view_models/timeline_viewmodel_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [timeline card idempotency helpers upsert inserts a new local card at the top](../test/ui/timeline/view_models/timeline_viewmodel_test.dart#L10) | 组件/业务层 | 通过 |
| [timeline card idempotency helpers upsert replaces a duplicate local submission instead of appending](../test/ui/timeline/view_models/timeline_viewmodel_test.dart#L28) | 组件/业务层 | 通过 |
| [timeline card idempotency helpers update collapses duplicate processing copies in their first position](../test/ui/timeline/view_models/timeline_viewmodel_test.dart#L59) | 组件/业务层 | 通过 |
| [timeline card idempotency helpers update leaves unloaded cards out of the current filtered list](../test/ui/timeline/view_models/timeline_viewmodel_test.dart#L98) | 组件/业务层 | 通过 |
| [timeline card idempotency helpers dedupe keeps the already loaded page copy across pagination overlap](../test/ui/timeline/view_models/timeline_viewmodel_test.dart#L110) | 组件/业务层 | 通过 |
| [timeline card idempotency helpers preparation drops legacy schedule briefing cards](../test/ui/timeline/view_models/timeline_viewmodel_test.dart#L132) | 组件/业务层 | 通过 |
| [timeline card idempotency helpers add ignores a retired schedule briefing event card](../test/ui/timeline/view_models/timeline_viewmodel_test.dart#L158) | 组件/业务层 | 通过 |
| [timeline card idempotency helpers update removes a card that becomes a retired schedule briefing](../test/ui/timeline/view_models/timeline_viewmodel_test.dart#L176) | 组件/业务层 | 通过 |
| [timeline card idempotency helpers card removed event clears an emitted processing placeholder](../test/ui/timeline/view_models/timeline_viewmodel_test.dart#L199) | 组件/业务层 | 通过 |
| [timeline tag refresh sameTimelineTags compares name icon and type](../test/ui/timeline/view_models/timeline_viewmodel_test.dart#L223) | 组件/业务层 | 通过 |
| [timeline tag refresh fetchTags does not notify when the tag list is unchanged](../test/ui/timeline/view_models/timeline_viewmodel_test.dart#L237) | 组件/业务层 | 通过 |

</details>

<details>
<summary>card_address_visibility_test.dart · 1 项</summary>

[测试源文件](../test/ui/timeline/widgets/card_address_visibility_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [hides empty and Unknown placeholder addresses](../test/ui/timeline/widgets/card_address_visibility_test.dart#L5) | 组件/业务层 | 通过 |

</details>

<details>
<summary>timeline_aux_query_isolation_test.dart · 4 项</summary>

[测试源文件](../test/ui/timeline/widgets/timeline_aux_query_isolation_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [timeline refresh renders cards and settles while auxiliary queries hang or fail](../test/ui/timeline/widgets/timeline_aux_query_isolation_test.dart#L58) | 宿主控件 | 通过 |
| [stale refresh return after tab switch does not leave loading on](../test/ui/timeline/widgets/timeline_aux_query_isolation_test.dart#L105) | 宿主控件 | 通过 |
| [refresh keeps timeline usable when unawaited fetchTags throws](../test/ui/timeline/widgets/timeline_aux_query_isolation_test.dart#L151) | 宿主控件 | 通过 |
| [timeline navigation no longer exposes a schedule tab](../test/ui/timeline/widgets/timeline_aux_query_isolation_test.dart#L181) | 宿主控件 | 通过 |

</details>

<details>
<summary>timeline_card_detail_body_section_test.dart · 4 项</summary>

[测试源文件](../test/ui/timeline/widgets/timeline_card_detail_body_section_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [ignores structured card content and preserves raw fact text](../test/ui/timeline/widgets/timeline_card_detail_body_section_test.dart#L8) | 宿主控件 | 通过 |
| [preserves raw fact markdown markers as plain text](../test/ui/timeline/widgets/timeline_card_detail_body_section_test.dart#L43) | 宿主控件 | 通过 |
| [ignores legacy html config and renders raw fact](../test/ui/timeline/widgets/timeline_card_detail_body_section_test.dart#L66) | 宿主控件 | 通过 |
| [keeps tag taps working when content is selectable](../test/ui/timeline/widgets/timeline_card_detail_body_section_test.dart#L86) | 宿主控件 | 通过 |

</details>

<details>
<summary>timeline_chrome_header_test.dart · 1 项</summary>

[测试源文件](../test/ui/timeline/widgets/timeline_chrome_header_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [chrome header stays mounted when the timeline list notifies](../test/ui/timeline/widgets/timeline_chrome_header_test.dart#L24) | 宿主控件 | 通过 |

</details>

<details>
<summary>timeline_entry_dedupe_test.dart · 4 项</summary>

[测试源文件](../test/ui/timeline/widgets/timeline_entry_dedupe_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [renders one processing entry after duplicate submission upsert](../test/ui/timeline/widgets/timeline_entry_dedupe_test.dart#L18) | 宿主控件 | 通过 |
| [renders one completed entry after duplicate processing update](../test/ui/timeline/widgets/timeline_entry_dedupe_test.dart#L48) | 宿主控件 | 通过 |
| [classic processing placeholder does not show model setup hint](../test/ui/timeline/widgets/timeline_entry_dedupe_test.dart#L81) | 宿主控件 | 通过 |
| [non-classic processing card keeps model setup hint](../test/ui/timeline/widgets/timeline_entry_dedupe_test.dart#L105) | 宿主控件 | 通过 |

</details>

<details>
<summary>timeline_loading_spinner_test.dart · 1 项</summary>

[测试源文件](../test/ui/timeline/widgets/timeline_loading_spinner_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [empty timeline loading uses a larger spinner](../test/ui/timeline/widgets/timeline_loading_spinner_test.dart#L26) | 宿主控件 | 通过 |

</details>

<details>
<summary>timeline_model_config_banner_test.dart · 3 项</summary>

[测试源文件](../test/ui/timeline/widgets/timeline_model_config_banner_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [banner hides and shows when LLM config events are emitted](../test/ui/timeline/widgets/timeline_model_config_banner_test.dart#L24) | 宿主控件 | 通过 |
| [banner rechecks persisted LLM config state on app resume](../test/ui/timeline/widgets/timeline_model_config_banner_test.dart#L48) | 宿主控件 | 通过 |
| [banner rechecks after configure flow returns](../test/ui/timeline/widgets/timeline_model_config_banner_test.dart#L68) | 宿主控件 | 通过 |

</details>


<a id="models"></a>
## 模型、账号与服务商设置

<details>
<summary>app_config_test.dart · 3 项</summary>

[测试源文件](../test/config/app_config_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [AppConfig.availableProviders includes DeepSeek in global flavor](../test/config/app_config_test.dart#L8) | 组件/业务层 | 通过 |
| [AppConfig.availableProviders excludes Memex proxy service from manual providers](../test/config/app_config_test.dart#L14) | 组件/业务层 | 通过 |
| [AppConfig.availableProviders includes DeepSeek in CN flavor](../test/config/app_config_test.dart#L22) | 组件/业务层 | 通过 |

</details>

<details>
<summary>memex_router_llm_config_event_test.dart · 3 项</summary>

[测试源文件](../test/data/repositories/memex_router_llm_config_event_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [saveLLMConfigs emits typed config change event](../test/data/repositories/memex_router_llm_config_event_test.dart#L43) | 组件/业务层 | 通过 |
| [resetLLMConfigs emits invalid config change event](../test/data/repositories/memex_router_llm_config_event_test.dart#L61) | 组件/业务层 | 通过 |
| [setDefaultLLMConfigKey emits default changed event](../test/data/repositories/memex_router_llm_config_event_test.dart#L80) | 组件/业务层 | 通过 |

</details>

<details>
<summary>memex_cloud_service_l10n_test.dart · 1 项</summary>

[测试源文件](../test/data/services/memex_cloud_service_l10n_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [auth and payment fallbacks resolve from l10n after init](../test/data/services/memex_cloud_service_l10n_test.dart#L15) | 组件/业务层 | 通过 |

</details>

<details>
<summary>model_role_config_service_test.dart · 2 项</summary>

[测试源文件](../test/data/services/model_role_config_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [ModelRoleConfigService findConfig handles empty inputs and normalizes keys](../test/data/services/model_role_config_service_test.dart#L31) | 组件/业务层 | 通过 |
| [ModelRoleConfigService loadSelection and setters normalize primary model keys](../test/data/services/model_role_config_service_test.dart#L59) | 组件/业务层 | 通过 |

</details>

<details>
<summary>oauth_missing_code_page_test.dart · 1 项</summary>

[测试源文件](../test/data/services/oauth_missing_code_page_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [OAuth missing-code page uses unknownError](../test/data/services/oauth_missing_code_page_test.dart#L15) | 组件/业务层 | 通过 |

</details>

<details>
<summary>llm_config_test.dart · 12 项</summary>

[测试源文件](../test/domain/models/llm_config_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [LLMConfig.duplicate creates copy with &quot;_copy&quot; suffix when no conflict](../test/domain/models/llm_config_test.dart#L21) | 组件/业务层 | 通过 |
| [LLMConfig.duplicate appends _copy_2 when &quot;_copy&quot; already exists](../test/domain/models/llm_config_test.dart#L36) | 组件/业务层 | 通过 |
| [LLMConfig.duplicate increments counter until unique key is found](../test/domain/models/llm_config_test.dart#L43) | 组件/业务层 | 通过 |
| [LLMConfig.duplicate does not modify the original config](../test/domain/models/llm_config_test.dart#L54) | 组件/业务层 | 通过 |
| [LLMConfig.duplicate handles keys with special characters gracefully](../test/domain/models/llm_config_test.dart#L60) | 组件/业务层 | 通过 |
| [DeepSeek provider uses official OpenAI-compatible API defaults](../test/domain/models/llm_config_test.dart#L74) | 组件/业务层 | 通过 |
| [DeepSeek provider recommends current official model IDs](../test/domain/models/llm_config_test.dart#L96) | 组件/业务层 | 通过 |
| [DeepSeek provider requires an API key and base URL](../test/domain/models/llm_config_test.dart#L107) | 组件/业务层 | 通过 |
| [current model recommendations uses the canonical GPT-5.6 Sol ID for new global configurations](../test/domain/models/llm_config_test.dart#L132) | 组件/业务层 | 通过 |
| [current model recommendations keeps OpenAI recommendations current and endpoint-specific](../test/domain/models/llm_config_test.dart#L146) | 组件/业务层 | 通过 |
| [current model recommendations includes the latest frontier models for hosted providers](../test/domain/models/llm_config_test.dart#L168) | 组件/业务层 | 通过 |
| [current model recommendations recognizes multimodal models added to the recommendations](../test/domain/models/llm_config_test.dart#L198) | 组件/业务层 | 通过 |

</details>

<details>
<summary>model_agent_config_pages_test.dart · 4 项</summary>

[测试源文件](../test/ui/settings/model_agent_config_pages_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [model config page can set a custom config as default](../test/ui/settings/model_agent_config_pages_test.dart#L69) | 设置控件→默认模型偏好 | 通过 |
| [model config page exposes a prominent add action](../test/ui/settings/model_agent_config_pages_test.dart#L90) | 宿主控件 | 通过 |
| [agent model assignments stay collapsed but remain reachable](../test/ui/settings/model_agent_config_pages_test.dart#L110) | 宿主控件 | 通过 |
| [agent config page discovers registered agents and shows default choice](../test/ui/settings/model_agent_config_pages_test.dart#L156) | 宿主控件 | 通过 |

</details>

<details>
<summary>oauth_authorize_l10n_test.dart · 1 项</summary>

[测试源文件](../test/ui/settings/oauth_authorize_l10n_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [OAuth authorize UI strings are localized](../test/ui/settings/oauth_authorize_l10n_test.dart#L14) | 组件/业务层 | 通过 |

</details>

<details>
<summary>ai_service_setup_viewmodel_test.dart · 6 项</summary>

[测试源文件](../test/ui/settings/view_models/ai_service_setup_viewmodel_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [loadModelRoles hydrates role and speech settings](../test/ui/settings/view_models/ai_service_setup_viewmodel_test.dart#L65) | 组件/业务层 | 通过 |
| [connectionMode separates unconfigured official and custom states](../test/ui/settings/view_models/ai_service_setup_viewmodel_test.dart#L82) | 组件/业务层 | 通过 |
| [saveMemexService persists official provider and refreshes roles](../test/ui/settings/view_models/ai_service_setup_viewmodel_test.dart#L111) | 组件/业务层 | 通过 |
| [clearMemexService resets official provider and falls back](../test/ui/settings/view_models/ai_service_setup_viewmodel_test.dart#L138) | 组件/业务层 | 通过 |
| [showMemexServiceSetup opens setup even when config fetch fails](../test/ui/settings/view_models/ai_service_setup_viewmodel_test.dart#L173) | 组件/业务层 | 通过 |
| [primary model updates persist and refresh ViewModel state](../test/ui/settings/view_models/ai_service_setup_viewmodel_test.dart#L190) | 组件/业务层 | 通过 |

</details>

<details>
<summary>ai_service_setup_page_test.dart · 12 项</summary>

[测试源文件](../test/ui/settings/widgets/ai_service_setup_page_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [hub renders connection choices without custom model controls](../test/ui/settings/widgets/ai_service_setup_page_test.dart#L25) | 宿主控件 | 通过 |
| [current setup shows only the active config name](../test/ui/settings/widgets/ai_service_setup_page_test.dart#L64) | 宿主控件 | 通过 |
| [current setup names the Memex official connection](../test/ui/settings/widgets/ai_service_setup_page_test.dart#L94) | 宿主控件 | 通过 |
| [settings registry model config entry opens AI model hub](../test/ui/settings/widgets/ai_service_setup_page_test.dart#L121) | 宿主控件 | 通过 |
| [app lock settings entry opens the lock controls](../test/ui/settings/widgets/ai_service_setup_page_test.dart#L145) | 宿主控件 | 通过 |
| [official route opens the existing Memex auth flow](../test/ui/settings/widgets/ai_service_setup_page_test.dart#L163) | 宿主控件 | 通过 |
| [official service page still saves Memex credentials](../test/ui/settings/widgets/ai_service_setup_page_test.dart#L187) | 宿主控件 | 通过 |
| [first custom setup opens the compact model editor directly](../test/ui/settings/widgets/ai_service_setup_page_test.dart#L225) | 宿主控件 | 通过 |
| [one valid custom model opens that model directly](../test/ui/settings/widgets/ai_service_setup_page_test.dart#L253) | 宿主控件 | 通过 |
| [multiple valid custom models open the model list](../test/ui/settings/widgets/ai_service_setup_page_test.dart#L277) | 宿主控件 | 通过 |
| [onboarding skip completes without saving credentials](../test/ui/settings/widgets/ai_service_setup_page_test.dart#L309) | 宿主控件 | 通过 |
| [onboarding custom model save completes setup flow](../test/ui/settings/widgets/ai_service_setup_page_test.dart#L328) | 宿主控件 | 通过 |

</details>

<details>
<summary>invalid_model_config_dialog_test.dart · 2 项</summary>

[测试源文件](../test/ui/settings/widgets/invalid_model_config_dialog_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [explains missing AI without agent or config key](../test/ui/settings/widgets/invalid_model_config_dialog_test.dart#L17) | 宿主控件 | 通过 |
| [an empty API key matches the chat error](../test/ui/settings/widgets/invalid_model_config_dialog_test.dart#L45) | 宿主控件 | 通过 |

</details>

<details>
<summary>model_config_edit_page_test.dart · 7 项</summary>

[测试源文件](../test/ui/settings/widgets/model_config_edit_page_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [ModelConfigEditPage duplicate mode shows &quot;Duplicate Configuration&quot; title when duplicateSource is provided](../test/ui/settings/widgets/model_config_edit_page_test.dart#L39) | 宿主控件 | 通过 |
| [ModelConfigEditPage duplicate mode pre-fills fields from duplicateSource](../test/ui/settings/widgets/model_config_edit_page_test.dart#L52) | 宿主控件 | 通过 |
| [ModelConfigEditPage duplicate mode save button is present when duplicateSource is provided](../test/ui/settings/widgets/model_config_edit_page_test.dart#L69) | 宿主控件 | 通过 |
| [ModelConfigEditPage duplicate mode saves duplicate config with unique key](../test/ui/settings/widgets/model_config_edit_page_test.dart#L93) | 宿主控件 | 通过 |
| [ModelConfigEditPage duplicate mode increments counter when duplicate key already exists](../test/ui/settings/widgets/model_config_edit_page_test.dart#L142) | 宿主控件 | 通过 |
| [ModelConfigEditPage provider selection renders DeepSeek configuration with official defaults](../test/ui/settings/widgets/model_config_edit_page_test.dart#L189) | 宿主控件 | 通过 |
| [ModelConfigEditPage simple setup mode hides the internal key and generates one when saved](../test/ui/settings/widgets/model_config_edit_page_test.dart#L214) | 宿主控件 | 通过 |

</details>

<details>
<summary>token_usage_utils_test.dart · 12 项</summary>

[测试源文件](../test/utils/token_usage_utils_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [TokenUsageUtils uses prompt tokens as denominator when cached tokens are included](../test/utils/token_usage_utils_test.dart#L8) | 组件/业务层 | 通过 |
| [TokenUsageUtils adds cached tokens to denominator when provider returns them separately](../test/utils/token_usage_utils_test.dart#L38) | 组件/业务层 | 通过 |
| [TokenUsageUtils does not infer provider semantics from token magnitude](../test/utils/token_usage_utils_test.dart#L68) | 组件/业务层 | 通过 |
| [TokenUsageUtils detects known provider cache token semantics from usage shape](../test/utils/token_usage_utils_test.dart#L95) | 组件/业务层 | 通过 |
| [TokenUsageUtils returns null when cache token semantics cannot be proven](../test/utils/token_usage_utils_test.dart#L132) | 组件/业务层 | 通过 |
| [TokenUsageUtils detects cache token semantics from concrete client adapters](../test/utils/token_usage_utils_test.dart#L139) | 组件/业务层 | 通过 |
| [TokenUsageUtils formats cache rate without exceeding 100 percent](../test/utils/token_usage_utils_test.dart#L170) | 组件/业务层 | 通过 |
| [TokenUsageUtils returns unavailable cache rate when cache semantics are unknown](../test/utils/token_usage_utils_test.dart#L189) | 组件/业务层 | 通过 |
| [TokenUsageUtils resolveFromUsageRecord reads persisted semantics](../test/utils/token_usage_utils_test.dart#L216) | 组件/业务层 | 通过 |
| [TokenUsageUtils formatCacheRateFromAggregated computes from pre-normalized values](../test/utils/token_usage_utils_test.dart#L244) | 组件/业务层 | 通过 |
| [TokenUsageUtils calculateCost estimates token cost with known pricing](../test/utils/token_usage_utils_test.dart#L272) | 组件/业务层 | 通过 |
| [TokenUsageUtils calculateCost falls back to gpt-4o for unknown models](../test/utils/token_usage_utils_test.dart#L292) | 组件/业务层 | 通过 |

</details>

<details>
<summary>user_storage_llm_config_test.dart · 6 项</summary>

[测试源文件](../test/utils/user_storage_llm_config_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [UserStorage LLM defaults agents without explicit config use selected global default](../test/utils/user_storage_llm_config_test.dart#L18) | 组件/业务层 | 通过 |
| [UserStorage LLM defaults removed selected default falls back to legacy default config](../test/utils/user_storage_llm_config_test.dart#L46) | 组件/业务层 | 通过 |
| [UserStorage LLM defaults AgentConfig.copyWith can clear explicit model selection](../test/utils/user_storage_llm_config_test.dart#L63) | 组件/业务层 | 通过 |
| [UserStorage LLM defaults DeepSeek builds an OpenAI-compatible chat client](../test/utils/user_storage_llm_config_test.dart#L69) | 组件/业务层 | 通过 |
| [UserStorage LLM defaults Claude uses the official endpoint and SDK caching default](../test/utils/user_storage_llm_config_test.dart#L84) | 组件/业务层 | 通过 |
| [UserStorage LLM defaults model role service maps text role to selected global default](../test/utils/user_storage_llm_config_test.dart#L100) | 组件/业务层 | 通过 |

</details>


<a id="knowledge"></a>
## 知识库、记忆与洞察

<details>
<summary>knowledge_insight_prompt_test.dart · 1 项</summary>

[测试源文件](../test/agent/knowledge_insight_prompt_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [Knowledge insight language prompts skill prompt interpolates the configured language instruction](../test/agent/knowledge_insight_prompt_test.dart#L9) | 组件/业务层 | 通过 |

</details>

<details>
<summary>knowledge_insight_skill_test.dart · 1 项</summary>

[测试源文件](../test/agent/knowledge_insight_skill_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [KnowledgeInsightSkill saving insight cards creates and publishes timeline summary card](../test/agent/knowledge_insight_skill_test.dart#L46) | 组件/业务层 | 通过 |

</details>

<details>
<summary>pkm_recent_listing_test.dart · 3 项</summary>

[测试源文件](../test/data/services/pkm_recent_listing_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [reuses a fresh listing for the same user](../test/data/services/pkm_recent_listing_test.dart#L5) | 组件/业务层 | 通过 |
| [a listing started earlier does not overwrite a newer generation](../test/data/services/pkm_recent_listing_test.dart#L58) | 组件/业务层 | 通过 |
| [detects PKM workspace files for cache invalidation](../test/data/services/pkm_recent_listing_test.dart#L69) | 组件/业务层 | 通过 |

</details>

<details>
<summary>insight_detail_page_test.dart · 1 项</summary>

[测试源文件](../test/ui/insight/insight_detail_page_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [shows friendly message for missing insight links](../test/ui/insight/insight_detail_page_test.dart#L15) | 宿主控件 | 通过 |

</details>

<details>
<summary>insight_viewmodel_html_test.dart · 3 项</summary>

[测试源文件](../test/ui/insight/view_models/insight_viewmodel_html_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [ensureHtmlRendered fills html once and is idempotent](../test/ui/insight/view_models/insight_viewmodel_html_test.dart#L12) | 组件/业务层 | 通过 |
| [ensureHtmlRendered skips native cards](../test/ui/insight/view_models/insight_viewmodel_html_test.dart#L33) | 组件/业务层 | 通过 |
| [failed HTML render waits for an explicit retry](../test/ui/insight/view_models/insight_viewmodel_html_test.dart#L50) | 组件/业务层 | 通过 |

</details>

<details>
<summary>insight_list_builder_test.dart · 2 项</summary>

[测试源文件](../test/ui/insight/widgets/insight_list_builder_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [uses a lazy ListView.builder for the insight feed](../test/ui/insight/widgets/insight_list_builder_test.dart#L24) | 宿主控件 | 通过 |
| [failed HTML render stops until the user retries](../test/ui/insight/widgets/insight_list_builder_test.dart#L58) | 宿主控件 | 通过 |

</details>

<details>
<summary>insight_screen_test.dart · 4 项</summary>

[测试源文件](../test/ui/insight/widgets/insight_screen_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [shows all insights without activity statistics navigation](../test/ui/insight/widgets/insight_screen_test.dart#L25) | 宿主控件 | 通过 |
| [a failed pin does not say the insight was pinned](../test/ui/insight/widgets/insight_screen_test.dart#L59) | 宿主控件 | 通过 |
| [a failed delete keeps the insight on screen](../test/ui/insight/widgets/insight_screen_test.dart#L77) | 宿主控件 | 通过 |
| [a pin that is already running does not toast a failure](../test/ui/insight/widgets/insight_screen_test.dart#L95) | 宿主控件 | 通过 |

</details>

<details>
<summary>insight_template_build_error_test.dart · 1 项</summary>

[测试源文件](../test/ui/insight/widgets/insight_template_build_error_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [uses localized operationFailed when a template fails to build](../test/ui/insight/widgets/insight_template_build_error_test.dart#L15) | 组件/业务层 | 通过 |

</details>

<details>
<summary>knowledge_base_screen_test.dart · 2 项</summary>

[测试源文件](../test/ui/knowledge/knowledge_base_screen_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [root listing helpers keep non-PARA folders and root files](../test/ui/knowledge/knowledge_base_screen_test.dart#L13) | 组件/业务层 | 通过 |
| [renders additional root folders and files below fixed PARA cards](../test/ui/knowledge/knowledge_base_screen_test.dart#L65) | 宿主控件 | 通过 |

</details>

<details>
<summary>knowledge_directory_body_test.dart · 1 项</summary>

[测试源文件](../test/ui/knowledge/widgets/knowledge_directory_body_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [directory rows are built through ListView.builder](../test/ui/knowledge/widgets/knowledge_directory_body_test.dart#L6) | 宿主控件 | 通过 |

</details>

<details>
<summary>lazy_secondary_loads_test.dart · 2 项</summary>

[测试源文件](../test/ui/lazy_secondary_loads_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [InsightViewModel does not start in a loading state](../test/ui/lazy_secondary_loads_test.dart#L14) | 组件/业务层 | 通过 |
| [KnowledgeBaseViewModel does not start in a loading state](../test/ui/lazy_secondary_loads_test.dart#L21) | 组件/业务层 | 通过 |

</details>


<a id="offline"></a>
## 离线记录与重试

<details>
<summary>offline_capture_queue_test.dart · 8 项</summary>

[测试源文件](../test/data/services/offline_capture_queue_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [sendMessage parks the turn and shows the network message](../test/data/services/offline_capture_queue_test.dart#L53) | 消息入口→提示、队列与文件 | 通过 |
| [a local endpoint is not parked when public DNS fails](../test/data/services/offline_capture_queue_test.dart#L91) | 组件/业务层 | 通过 |
| [connection refused ends failed instead of waiting for network](../test/data/services/offline_capture_queue_test.dart#L128) | 组件/业务层 | 通过 |
| [a host lookup failure waits, then runs when the network returns](../test/data/services/offline_capture_queue_test.dart#L156) | 队列恢复→任务完成 | 通过 |
| [private endpoints and offline errors are classified apart](../test/data/services/offline_capture_queue_test.dart#L191) | 组件/业务层 | 通过 |
| [deleting a waiting card cancels its turn and lets the next one run](../test/data/services/offline_capture_queue_test.dart#L230) | 发送→删除→恢复队列→时间线 | 通过 |
| [a resumed turn does not mint a card after the original was deleted](../test/data/services/offline_capture_queue_test.dart#L280) | 恢复会话入口→磁盘卡片集合 | 通过 |
| [a text-only reply removes the empty offline placeholder](../test/data/services/offline_capture_queue_test.dart#L311) | 回复处理→占位卡清理 | 通过 |

</details>


<a id="maintenance"></a>
## 维护者检查和发布辅助

<details>
<summary>test_generate_star_history.py · 3 项</summary>

[测试源文件](../.github/scripts/test_generate_star_history.py)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [test_fetches_anonymous_star_timestamps_with_graphql_pagination](../.github/scripts/test_generate_star_history.py#L17) | 维护工具 | 通过 |
| [test_cumulative_points_groups_stars_by_date](../.github/scripts/test_generate_star_history.py#L45) | 维护工具 | 通过 |
| [test_svg_is_deterministic_and_contains_summary](../.github/scripts/test_generate_star_history.py#L57) | 维护工具 | 通过 |

</details>

<details>
<summary>compare_flutter_analyze_test.py · 3 项</summary>

[测试源文件](../scripts/compare_flutter_analyze_test.py)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [test_parses_flutter_stdout_format](../scripts/compare_flutter_analyze_test.py#L9) | 维护工具 | 通过 |
| [test_parses_flutter_write_format_and_normalizes_paths](../scripts/compare_flutter_analyze_test.py#L21) | 维护工具 | 通过 |
| [test_baseline_comparison_ignores_line_drift](../scripts/compare_flutter_analyze_test.py#L34) | 维护工具 | 通过 |

</details>

<details>
<summary>test_compare_flutter_analyze.py · 3 项</summary>

[测试源文件](../tests/tools/test_compare_flutter_analyze.py)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [test_parse_report_extracts_analyzer_issues](../tests/tools/test_compare_flutter_analyze.py#L16) | 维护工具 | 通过 |
| [test_moved_existing_issue_is_not_new](../tests/tools/test_compare_flutter_analyze.py#L25) | 维护工具 | 通过 |
| [test_additional_copy_of_existing_issue_is_new](../tests/tools/test_compare_flutter_analyze.py#L38) | 维护工具 | 通过 |

</details>

<details>
<summary>test_compare_flutter_test_failures.py · 4 项</summary>

[测试源文件](../tests/tools/test_compare_flutter_test_failures.py)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [test_parse_failures_extracts_failed_test_label](../tests/tools/test_compare_flutter_test_failures.py#L18) | 维护工具 | 通过 |
| [test_same_failure_under_different_workspace_path_is_not_new](../tests/tools/test_compare_flutter_test_failures.py#L27) | 维护工具 | 通过 |
| [test_additional_failure_is_new](../tests/tools/test_compare_flutter_test_failures.py#L37) | 维护工具 | 通过 |
| [test_structured_terminal_and_exit_agree](../tests/tools/test_compare_flutter_test_failures.py#L70) | 维护工具 | 通过 |

</details>

<details>
<summary>test_local_pr_review.py · 7 项</summary>

[测试源文件](../tests/tools/test_local_pr_review.py)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [test_only_completed_required_workflows_are_ready](../tests/tools/test_local_pr_review.py#L12) | 维护工具 | 通过 |
| [test_same_head_separate_pr_or_base_needs_fresh_verdict](../tests/tools/test_local_pr_review.py#L21) | 维护工具 | 通过 |
| [test_record_withholds_status_when_concurrent_push_lands](../tests/tools/test_local_pr_review.py#L28) | 维护工具 | 通过 |
| [test_routing_covers_multiple_scenarios](../tests/tools/test_local_pr_review.py#L45) | 维护工具 | 通过 |
| [test_intent_edits_invalidate_status_context](../tests/tools/test_local_pr_review.py#L58) | 维护工具 | 通过 |
| [test_artifact_version_and_policy_are_authoritative](../tests/tools/test_local_pr_review.py#L63) | 维护工具 | 通过 |
| [test_independent_approval_needs_current_head_and_role](../tests/tools/test_local_pr_review.py#L85) | 维护工具 | 通过 |

</details>

<details>
<summary>test_pr_policy_check.py · 13 项</summary>

[测试源文件](../tests/tools/test_pr_policy_check.py)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [test_default_diff_budget_is_near_one_megabyte](../tests/tools/test_pr_policy_check.py#L29) | 维护工具 | 通过 |
| [test_secret_file_rejects](../tests/tools/test_pr_policy_check.py#L34) | 维护工具 | 通过 |
| [test_generated_file_without_source_rejects](../tests/tools/test_pr_policy_check.py#L41) | 维护工具 | 通过 |
| [test_generated_file_with_source_is_low_risk](../tests/tools/test_pr_policy_check.py#L46) | 维护工具 | 通过 |
| [test_docs_only_is_low_risk](../tests/tools/test_pr_policy_check.py#L58) | 维护工具 | 通过 |
| [test_workflow_change_is_high_risk](../tests/tools/test_pr_policy_check.py#L63) | 维护工具 | 通过 |
| [test_diff_truncation_remains_high_risk](../tests/tools/test_pr_policy_check.py#L68) | 维护工具 | 通过 |
| [test_unsafe_workflow_pattern_rejects](../tests/tools/test_pr_policy_check.py#L83) | 维护工具 | 通过 |
| [test_single_l10n_file_is_left_to_ai_review](../tests/tools/test_pr_policy_check.py#L94) | 维护工具 | 通过 |
| [test_app_code_path_is_not_high_risk_by_directory](../tests/tools/test_pr_policy_check.py#L100) | 维护工具 | 通过 |
| [test_production_change_without_test_signal_is_left_to_ai_review](../tests/tools/test_pr_policy_check.py#L106) | 维护工具 | 通过 |
| [test_sensitive_keyword_is_left_to_ai_review](../tests/tools/test_pr_policy_check.py#L112) | 维护工具 | 通过 |
| [test_outputs_include_bilingual_labels](../tests/tools/test_pr_policy_check.py#L123) | 维护工具 | 通过 |

</details>

<details>
<summary>test_pr_preflight_summary_comment.py · 4 项</summary>

[测试源文件](../tests/tools/test_pr_preflight_summary_comment.py)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [test_request_json_preserves_github_error_body](../tests/tools/test_pr_preflight_summary_comment.py#L17) | 维护工具 | 通过 |
| [test_build_comment_includes_one_sentence_details](../tests/tools/test_pr_preflight_summary_comment.py#L36) | 维护工具 | 通过 |
| [test_trigger_context_skips_transient_artifact_download_error](../tests/tools/test_pr_preflight_summary_comment.py#L80) | 维护工具 | 通过 |
| [test_trigger_context_continues_after_one_artifact_download_error](../tests/tools/test_pr_preflight_summary_comment.py#L96) | 维护工具 | 通过 |

</details>


<a id="companions"></a>
## 角色、头像、主动消息与私聊

<details>
<summary>character_agent_test.dart · 2 项</summary>

[测试源文件](../test/agent/character_agent_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [CharacterAgent transforms and finishes one observation](../test/agent/character_agent_test.dart#L19) | 组件/业务层 | 通过 |
| [CharacterAgent selects one proactive action from its own memory](../test/agent/character_agent_test.dart#L102) | 组件/业务层 | 通过 |

</details>

<details>
<summary>character_conversation_skill_test.dart · 1 项</summary>

[测试源文件](../test/agent/character_conversation_skill_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [conversation skill treats several bubbles as one agent decision](../test/agent/character_conversation_skill_test.dart#L17) | 组件/业务层 | 通过 |

</details>

<details>
<summary>character_history_acquaintance_skill_test.dart · 1 项</summary>

[测试源文件](../test/agent/character_history_acquaintance_skill_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [requires a real history visit before completing acquaintance](../test/agent/character_history_acquaintance_skill_test.dart#L17) | 组件/业务层 | 通过 |

</details>

<details>
<summary>character_initiative_skill_test.dart · 7 项</summary>

[测试源文件](../test/agent/character_initiative_skill_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [offers memory retrieval and two continuous initiative choices](../test/agent/character_initiative_skill_test.dart#L36) | 组件/业务层 | 通过 |
| [keeps future reflection available without a fixed retry count](../test/agent/character_initiative_skill_test.dart#L63) | 组件/业务层 | 通过 |
| [Speak includes the character-selected next wake](../test/agent/character_initiative_skill_test.dart#L83) | 组件/业务层 | 通过 |
| [Speak downgrades a legacy textual emoji placeholder to text](../test/agent/character_initiative_skill_test.dart#L127) | 组件/业务层 | 通过 |
| [Speak can send a Fluent emoji without a text bubble](../test/agent/character_initiative_skill_test.dart#L159) | 组件/业务层 | 通过 |
| [SleepUntil stays quiet now without ending future initiative](../test/agent/character_initiative_skill_test.dart#L187) | 组件/业务层 | 通过 |
| [can deliberately resolve an obsolete pending thought](../test/agent/character_initiative_skill_test.dart#L212) | 组件/业务层 | 通过 |

</details>

<details>
<summary>character_perception_skill_test.dart · 2 项</summary>

[测试源文件](../test/agent/character_perception_skill_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [CharacterPerceptionSkill exposes private memory tools but no messaging surface](../test/agent/character_perception_skill_test.dart#L50) | 组件/业务层 | 通过 |
| [CharacterPerceptionSkill generic Read cannot access the raw inbox](../test/agent/character_perception_skill_test.dart#L71) | 组件/业务层 | 通过 |

</details>

<details>
<summary>character_scene_memory_test.dart · 1 项</summary>

[测试源文件](../test/agent/character_scene_memory_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [comments use the same character workspace and scene action tools](../test/agent/character_scene_memory_test.dart#L37) | 组件/业务层 | 通过 |

</details>

<details>
<summary>avatar_media_service_test.dart · 5 项</summary>

[测试源文件](../test/data/services/avatar_media_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [recognizes all imported image extensions as avatar image paths](../test/data/services/avatar_media_service_test.dart#L29) | 组件/业务层 | 通过 |
| [resolves relative avatar media paths against current data root](../test/data/services/avatar_media_service_test.dart#L53) | 组件/业务层 | 通过 |
| [keeps DiceBear seeds and remote images out of relative path resolution](../test/data/services/avatar_media_service_test.dart#L64) | 组件/业务层 | 通过 |
| [caches DiceBear SVGs to application support directory](../test/data/services/avatar_media_service_test.dart#L77) | 组件/业务层 | 通过 |
| [returns null without creating a cache file on download failure](../test/data/services/avatar_media_service_test.dart#L94) | 组件/业务层 | 通过 |

</details>

<details>
<summary>character_conversation_handler_test.dart · 1 项</summary>

[测试源文件](../test/data/services/character_conversation_handler_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [one conversation decision writes several character bubbles](../test/data/services/character_conversation_handler_test.dart#L22) | 组件/业务层 | 通过 |

</details>

<details>
<summary>character_conversation_service_test.dart · 2 项</summary>

[测试源文件](../test/data/services/character_conversation_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [consecutive user bubbles share one rescheduled reply task](../test/data/services/character_conversation_service_test.dart#L11) | 组件/业务层 | 通过 |
| [startup reconciliation rebuilds only missing workspace replies](../test/data/services/character_conversation_service_test.dart#L68) | 组件/业务层 | 通过 |

</details>

<details>
<summary>character_execution_coordinator_test.dart · 2 项</summary>

[测试源文件](../test/data/services/character_execution_coordinator_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [serializes different scenes for the same character](../test/data/services/character_execution_coordinator_test.dart#L7) | 组件/业务层 | 通过 |
| [does not block a different character](../test/data/services/character_execution_coordinator_test.dart#L38) | 组件/业务层 | 通过 |

</details>

<details>
<summary>character_history_acquaintance_handler_test.dart · 1 项</summary>

[测试源文件](../test/data/services/character_history_acquaintance_handler_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [completed acquaintance retries do not run the agent again](../test/data/services/character_history_acquaintance_handler_test.dart#L12) | 组件/业务层 | 通过 |

</details>

<details>
<summary>character_history_acquaintance_service_test.dart · 1 项</summary>

[测试源文件](../test/data/services/character_history_acquaintance_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [browses existing moments and schedules acquaintance only once](../test/data/services/character_history_acquaintance_service_test.dart#L16) | 组件/业务层 | 通过 |

</details>

<details>
<summary>character_initiative_flow_test.dart · 1 项</summary>

[测试源文件](../test/data/services/character_initiative_flow_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [initiative reaches chat persistence, unread state, and the UI event](../test/data/services/character_initiative_flow_test.dart#L20) | 组件/业务层 | 通过 |

</details>

<details>
<summary>character_initiative_handler_test.dart · 7 项</summary>

[测试源文件](../test/data/services/character_initiative_handler_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [persists one unread message turn selected by the character](../test/data/services/character_initiative_handler_test.dart#L37) | 组件/业务层 | 通过 |
| [lets the agent decide while the character owns the last chat turn](../test/data/services/character_initiative_handler_test.dart#L122) | 组件/业务层 | 通过 |
| [defers initiative while direct user messages await a reply](../test/data/services/character_initiative_handler_test.dart#L189) | 组件/业务层 | 通过 |
| [turns SleepUntil into an agent-chosen persistent wake](../test/data/services/character_initiative_handler_test.dart#L295) | 组件/业务层 | 通过 |
| [ignores stale schedules and resolves a revisited thought](../test/data/services/character_initiative_handler_test.dart#L365) | 组件/业务层 | 通过 |
| [discards a proactive decision when direct chat changes mid-thought](../test/data/services/character_initiative_handler_test.dart#L454) | 组件/业务层 | 通过 |
| [keeps a resumed thought when direct chat arrives mid-decision](../test/data/services/character_initiative_handler_test.dart#L518) | 组件/业务层 | 通过 |

</details>

<details>
<summary>character_initiative_service_test.dart · 2 项</summary>

[测试源文件](../test/data/services/character_initiative_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [restores one wake loop and preserves an existing chosen time](../test/data/services/character_initiative_service_test.dart#L12) | 组件/业务层 | 通过 |
| [conversation deferral preserves the initiative task identity](../test/data/services/character_initiative_service_test.dart#L67) | 组件/业务层 | 通过 |

</details>

<details>
<summary>character_perception_handler_test.dart · 2 项</summary>

[测试源文件](../test/data/services/character_perception_handler_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [CharacterPerceptionTaskHandler routes once to the primary character and drains the inbox](../test/data/services/character_perception_handler_test.dart#L39) | 组件/业务层 | 通过 |
| [CharacterPerceptionTaskHandler does nothing when no enabled primary companion exists](../test/data/services/character_perception_handler_test.dart#L81) | 组件/业务层 | 通过 |

</details>

<details>
<summary>character_service_default_seed_test.dart · 5 项</summary>

[测试源文件](../test/data/services/character_service_default_seed_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [default characters store examples and interest filters separately](../test/data/services/character_service_default_seed_test.dart#L33) | 组件/业务层 | 通过 |
| [seed migration refreshes legacy default auntie persona](../test/data/services/character_service_default_seed_test.dart#L50) | 组件/业务层 | 通过 |
| [resolves imported HEIC avatar paths when loading characters](../test/data/services/character_service_default_seed_test.dart#L78) | 组件/业务层 | 通过 |
| [deleting a character emits a character update event](../test/data/services/character_service_default_seed_test.dart#L100) | 组件/业务层 | 通过 |
| [multi-character routing nudges multiple voices without forcing fill](../test/data/services/character_service_default_seed_test.dart#L130) | 组件/业务层 | 通过 |

</details>

<details>
<summary>character_workspace_service_test.dart · 5 项</summary>

[测试源文件](../test/data/services/character_workspace_service_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [CharacterWorkspaceService initializes a private workspace without modeled emotional state](../test/data/services/character_workspace_service_test.dart#L37) | 组件/业务层 | 通过 |
| [CharacterWorkspaceService deduplicates delivery and removes raw content after digestion](../test/data/services/character_workspace_service_test.dart#L63) | 组件/业务层 | 通过 |
| [CharacterWorkspaceService character-authored PKM and journal writes are scoped and idempotent](../test/data/services/character_workspace_service_test.dart#L126) | 组件/业务层 | 通过 |
| [CharacterWorkspaceService imports legacy configured memory without deleting the source](../test/data/services/character_workspace_service_test.dart#L185) | 组件/业务层 | 通过 |
| [CharacterWorkspaceService pending thoughts coalesce and can be resolved](../test/data/services/character_workspace_service_test.dart#L237) | 组件/业务层 | 通过 |

</details>

<details>
<summary>persona_chat_conversation_storage_test.dart · 16 项</summary>

[测试源文件](../test/data/services/persona_chat_conversation_storage_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [PersonaChatConversationStorage stores only messages and commits a multi-bubble turn once](../test/data/services/persona_chat_conversation_storage_test.dart#L31) | 组件/业务层 | 通过 |
| [PersonaChatConversationStorage finds an older committed turn without a receipt or duplicate](../test/data/services/persona_chat_conversation_storage_test.dart#L106) | 组件/业务层 | 通过 |
| [PersonaChatConversationStorage recovers an interrupted turn after pendingWritten](../test/data/services/persona_chat_conversation_storage_test.dart#L178) | 组件/业务层 | 通过 |
| [PersonaChatConversationStorage recovers an interrupted turn after messagesAppended](../test/data/services/persona_chat_conversation_storage_test.dart#L178) | 组件/业务层 | 通过 |
| [PersonaChatConversationStorage recovers an interrupted turn after metadataWritten](../test/data/services/persona_chat_conversation_storage_test.dart#L178) | 组件/业务层 | 通过 |
| [PersonaChatConversationStorage replays a partially appended batch from its write-ahead file](../test/data/services/persona_chat_conversation_storage_test.dart#L244) | 组件/业务层 | 通过 |
| [PersonaChatConversationStorage serializes writers and allocates one ordered message id](../test/data/services/persona_chat_conversation_storage_test.dart#L295) | 组件/业务层 | 通过 |
| [PersonaChatConversationStorage repairs derived metadata after an unindexed single append](../test/data/services/persona_chat_conversation_storage_test.dart#L331) | 组件/业务层 | 通过 |
| [PersonaChatConversationStorage truncates an incomplete UTF-8 tail without losing valid history](../test/data/services/persona_chat_conversation_storage_test.dart#L366) | 组件/业务层 | 通过 |
| [PersonaChatConversationStorage keeps read and agent-processing boundaries outside messages](../test/data/services/persona_chat_conversation_storage_test.dart#L387) | 组件/业务层 | 通过 |
| [PersonaChatConversationStorage clear changes generation and never reuses a message id](../test/data/services/persona_chat_conversation_storage_test.dart#L434) | 组件/业务层 | 通过 |
| [PersonaChatConversationStorage recovers an interrupted clear after pendingWritten](../test/data/services/persona_chat_conversation_storage_test.dart#L497) | 组件/业务层 | 通过 |
| [PersonaChatConversationStorage recovers an interrupted clear after messagesAppended](../test/data/services/persona_chat_conversation_storage_test.dart#L497) | 组件/业务层 | 通过 |
| [PersonaChatConversationStorage recovers an interrupted clear after metadataWritten](../test/data/services/persona_chat_conversation_storage_test.dart#L497) | 组件/业务层 | 通过 |
| [PersonaChatConversationStorage recovers an interrupted legacy snapshot import](../test/data/services/persona_chat_conversation_storage_test.dart#L542) | 组件/业务层 | 通过 |
| [PersonaChatConversationStorage rejects character ids that escape the workspace](../test/data/services/persona_chat_conversation_storage_test.dart#L597) | 组件/业务层 | 通过 |

</details>

<details>
<summary>persona_chat_workspace_recovery_test.dart · 3 项</summary>

[测试源文件](../test/data/services/persona_chat_workspace_recovery_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [persona chat workspace recovery imports legacy SQLite once, including its reply cursor](../test/data/services/persona_chat_workspace_recovery_test.dart#L44) | 组件/业务层 | 通过 |
| [persona chat workspace recovery runtime conversation remains available after SQLite is wiped](../test/data/services/persona_chat_workspace_recovery_test.dart#L105) | 清除 SQLite→会话恢复 | 通过 |
| [persona chat workspace recovery retried multi-bubble turns are idempotent](../test/data/services/persona_chat_workspace_recovery_test.dart#L129) | 重放同一轮次→持久化消息 | 通过 |

</details>

<details>
<summary>character_editor_test.dart · 1 项</summary>

[测试源文件](../test/domain/models/character_editor_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [character draft snapshots mutable editor collections](../test/domain/models/character_editor_test.dart#L5) | 组件/业务层 | 通过 |

</details>

<details>
<summary>character_message_test.dart · 5 项</summary>

[测试源文件](../test/domain/models/character_message_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [recognizes emoji-only bubbles without treating mixed text as emoji](../test/domain/models/character_message_test.dart#L6) | 组件/业务层 | 通过 |
| [maps stable agent emoji ids to Unicode and Fluent assets](../test/domain/models/character_message_test.dart#L19) | 组件/业务层 | 通过 |
| [classifies text and appends the selected Fluent emoji gesture](../test/domain/models/character_message_test.dart#L30) | 组件/业务层 | 通过 |
| [supports an emoji-only reply and rejects an unknown emoji id](../test/domain/models/character_message_test.dart#L56) | 组件/业务层 | 通过 |
| [fails when Speak contains neither text nor an emoji gesture](../test/domain/models/character_message_test.dart#L67) | 组件/业务层 | 通过 |

</details>

<details>
<summary>character_workspace_test.dart · 2 项</summary>

[测试源文件](../test/domain/models/character_workspace_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [character observation round-trips its one-time source material](../test/domain/models/character_workspace_test.dart#L5) | 组件/业务层 | 通过 |
| [runtime contains only operational cursors](../test/domain/models/character_workspace_test.dart#L27) | 组件/业务层 | 通过 |

</details>

<details>
<summary>character_companion_pipeline_test.dart · 1 项</summary>

[测试源文件](../test/integration/character_companion_pipeline_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [record becomes character memory, initiative, and reply context](../test/integration/character_companion_pipeline_test.dart#L21) | 业务入口→角色记忆和回复上下文 | 通过 |

</details>

<details>
<summary>character_conversation_pipeline_test.dart · 3 项</summary>

[测试源文件](../test/integration/character_conversation_pipeline_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [consecutive sends become one durable multi-bubble conversation turn](../test/integration/character_conversation_pipeline_test.dart#L25) | 业务入口→持久化角色消息 | 通过 |
| [initiative yields one pending user turn to the direct reply task](../test/integration/character_conversation_pipeline_test.dart#L136) | 组件/业务层 | 通过 |
| [initiative commit cannot overtake a pending direct message](../test/integration/character_conversation_pipeline_test.dart#L363) | 组件/业务层 | 通过 |

</details>

<details>
<summary>character_edit_viewmodel_test.dart · 3 项</summary>

[测试源文件](../test/ui/character/view_models/character_edit_viewmodel_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [loads and edits character-owned world and memory entries](../test/ui/character/view_models/character_edit_viewmodel_test.dart#L17) | 组件/业务层 | 通过 |
| [saves one draft through the router and exposes persistence errors](../test/ui/character/view_models/character_edit_viewmodel_test.dart#L34) | 组件/业务层 | 通过 |
| [reports workspace load failures](../test/ui/character/view_models/character_edit_viewmodel_test.dart#L52) | 组件/业务层 | 通过 |

</details>

<details>
<summary>character_viewmodel_test.dart · 4 项</summary>

[测试源文件](../test/ui/character/view_models/character_viewmodel_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [loads characters and reports failures explicitly](../test/ui/character/view_models/character_viewmodel_test.dart#L25) | 组件/业务层 | 通过 |
| [does not update enabled state when persistence fails](../test/ui/character/view_models/character_viewmodel_test.dart#L38) | 组件/业务层 | 通过 |
| [does not update enabled state when persist returns false](../test/ui/character/view_models/character_viewmodel_test.dart#L49) | 组件/业务层 | 通过 |
| [removes a character only after a successful delete](../test/ui/character/view_models/character_viewmodel_test.dart#L60) | 组件/业务层 | 通过 |

</details>

<details>
<summary>persona_avatar_viewmodel_test.dart · 4 项</summary>

[测试源文件](../test/ui/character/view_models/persona_avatar_viewmodel_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [ensureLoaded is a no-op until first call and stays idempotent](../test/ui/character/view_models/persona_avatar_viewmodel_test.dart#L16) | 组件/业务层 | 通过 |
| [loads avatar summary and refreshes when chat unread state changes](../test/ui/character/view_models/persona_avatar_viewmodel_test.dart#L42) | 组件/业务层 | 通过 |
| [exposes load failures without discarding the current summary](../test/ui/character/view_models/persona_avatar_viewmodel_test.dart#L74) | 组件/业务层 | 通过 |
| [ignores a stale refresh that completes after a newer refresh](../test/ui/character/view_models/persona_avatar_viewmodel_test.dart#L98) | 组件/业务层 | 通过 |

</details>

<details>
<summary>persona_chat_viewmodel_test.dart · 4 项</summary>

[测试源文件](../test/ui/character/view_models/persona_chat_viewmodel_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [typing indicator appears after a short delay](../test/ui/character/view_models/persona_chat_viewmodel_test.dart#L15) | 宿主控件 | 通过 |
| [quick completion cancels the pending typing indicator](../test/ui/character/view_models/persona_chat_viewmodel_test.dart#L34) | 宿主控件 | 通过 |
| [consecutive sends do not restart the display delay](../test/ui/character/view_models/persona_chat_viewmodel_test.dart#L57) | 宿主控件 | 通过 |
| [history and live updates use cursors without reloading visible rows](../test/ui/character/view_models/persona_chat_viewmodel_test.dart#L75) | 组件/业务层 | 通过 |

</details>

<details>
<summary>character_config_error_test.dart · 2 项</summary>

[测试源文件](../test/ui/character/widgets/character_config_error_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [image import fallback has no StateError prefix](../test/ui/character/widgets/character_config_error_test.dart#L15) | 组件/业务层 | 通过 |
| [image import keeps a specific error message](../test/ui/character/widgets/character_config_error_test.dart#L25) | 组件/业务层 | 通过 |

</details>

<details>
<summary>persona_avatar_button_test.dart · 3 项</summary>

[测试源文件](../test/ui/character/widgets/persona_avatar_button_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [loads the companion after the first frame](../test/ui/character/widgets/persona_avatar_button_test.dart#L14) | 宿主控件 | 通过 |
| [renders an empty slot when no companion is available](../test/ui/character/widgets/persona_avatar_button_test.dart#L49) | 宿主控件 | 通过 |
| [renders unread count and delegates taps](../test/ui/character/widgets/persona_avatar_button_test.dart#L72) | 宿主控件 | 通过 |

</details>

<details>
<summary>persona_chat_screen_test.dart · 11 项</summary>

[测试源文件](../test/ui/character/widgets/persona_chat_screen_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [loading older chat does not request an automatic bottom scroll](../test/ui/character/widgets/persona_chat_screen_test.dart#L8) | 组件/业务层 | 通过 |
| [send button is disabled until the user enters text](../test/ui/character/widgets/persona_chat_screen_test.dart#L46) | 宿主控件 | 通过 |
| [input remains enabled for consecutive sends](../test/ui/character/widgets/persona_chat_screen_test.dart#L72) | 宿主控件 | 通过 |
| [sending keeps the input focused for the next message](../test/ui/character/widgets/persona_chat_screen_test.dart#L98) | 宿主控件 | 通过 |
| [tapping the message area dismisses the input focus](../test/ui/character/widgets/persona_chat_screen_test.dart#L128) | 宿主控件 | 通过 |
| [supported emoji uses the Fluent 3D asset](../test/ui/character/widgets/persona_chat_screen_test.dart#L165) | 宿主控件 | 通过 |
| [unsupported emoji falls back to a smaller system glyph](../test/ui/character/widgets/persona_chat_screen_test.dart#L197) | 宿主控件 | 通过 |
| [every protocol emoji has a bundled Fluent asset](../test/ui/character/widgets/persona_chat_screen_test.dart#L212) | 宿主控件 | 通过 |
| [reversed chat list reserves index zero for the typing indicator](../test/ui/character/widgets/persona_chat_screen_test.dart#L222) | 组件/业务层 | 通过 |
| [marks chat read after open even without a scroll client](../test/ui/character/widgets/persona_chat_screen_test.dart#L239) | 组件/业务层 | 通过 |
| [scrolls to latest then marks chat read when a client is attached](../test/ui/character/widgets/persona_chat_screen_test.dart#L251) | 组件/业务层 | 通过 |

</details>

<details>
<summary>avatar_widgets_test.dart · 2 项</summary>

[测试源文件](../test/ui/core/widgets/avatar_widgets_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [CharacterAvatar routes HEIC media paths through LocalImage](../test/ui/core/widgets/avatar_widgets_test.dart#L10) | 宿主控件 | 通过 |
| [DiceBearAvatar shows a stable placeholder for empty seeds](../test/ui/core/widgets/avatar_widgets_test.dart#L26) | 宿主控件 | 通过 |

</details>

<details>
<summary>tavern_macro_test.dart · 7 项</summary>

[测试源文件](../test/utils/tavern_macro_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [TavernMacro.resolve replaces {{user}} case-insensitively](../test/utils/tavern_macro_test.dart#L6) | 组件/业务层 | 通过 |
| [TavernMacro.resolve replaces {{char}} case-insensitively](../test/utils/tavern_macro_test.dart#L17) | 组件/业务层 | 通过 |
| [TavernMacro.resolve replaces {{time}} with HH:mm and timezone offset](../test/utils/tavern_macro_test.dart#L28) | 组件/业务层 | 通过 |
| [TavernMacro.resolve replaces {{date}} with yyyy-MM-dd format](../test/utils/tavern_macro_test.dart#L39) | 组件/业务层 | 通过 |
| [TavernMacro.resolve leaves unknown macros untouched](../test/utils/tavern_macro_test.dart#L48) | 组件/业务层 | 通过 |
| [TavernMacro.resolve returns text unchanged when no macros present](../test/utils/tavern_macro_test.dart#L59) | 组件/业务层 | 通过 |
| [TavernMacro.resolve handles multiple macros in one string](../test/utils/tavern_macro_test.dart#L67) | 组件/业务层 | 通过 |

</details>


<a id="appearance"></a>
## 语言、外观和共用控件

<details>
<summary>arb_key_parity_test.dart · 1 项</summary>

[测试源文件](../test/l10n/arb_key_parity_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [locale ARB files stay in key parity with app_en.arb](../test/l10n/arb_key_parity_test.dart#L6) | 组件/业务层 | 通过 |

</details>

<details>
<summary>hardcoded_ui_strings_test.dart · 2 项</summary>

[测试源文件](../test/l10n/hardcoded_ui_strings_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [comment author labels resolve from l10n](../test/l10n/hardcoded_ui_strings_test.dart#L15) | 组件/业务层 | 通过 |
| [replyDisplayNameFor falls back to localized AI label](../test/l10n/hardcoded_ui_strings_test.dart#L24) | 组件/业务层 | 通过 |

</details>

<details>
<summary>italian_locale_smoke_test.dart · 2 项</summary>

[测试源文件](../test/l10n/italian_locale_smoke_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [Italian locale resolves and loads l10n](../test/l10n/italian_locale_smoke_test.dart#L8) | 组件/业务层 | 通过 |
| [Italian locale exposes the simplified AI setup copy](../test/l10n/italian_locale_smoke_test.dart#L24) | 组件/业务层 | 通过 |

</details>

<details>
<summary>locale_lookup_test.dart · 4 项</summary>

[测试源文件](../test/l10n/locale_lookup_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [every supported language tag resolves and loads l10n](../test/l10n/locale_lookup_test.dart#L8) | 组件/业务层 | 通过 |
| [Vietnamese locale exposes translated common actions](../test/l10n/locale_lookup_test.dart#L19) | 组件/业务层 | 通过 |
| [Farsi locale exposes translated common actions](../test/l10n/locale_lookup_test.dart#L32) | 组件/业务层 | 通过 |
| [new locales expose the simplified AI setup copy](../test/l10n/locale_lookup_test.dart#L45) | 组件/业务层 | 通过 |

</details>

<details>
<summary>bundled_google_fonts_test.dart · 2 项</summary>

[测试源文件](../test/ui/core/themes/bundled_google_fonts_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [disables runtime font fetching](../test/ui/core/themes/bundled_google_fonts_test.dart#L18) | 组件/业务层 | 通过 |
| [AppTheme and brand title resolve bundled fonts offline](../test/ui/core/themes/bundled_google_fonts_test.dart#L22) | 宿主控件 | 通过 |

</details>

<details>
<summary>memex_brand_title_test.dart · 3 项</summary>

[测试源文件](../test/ui/core/widgets/memex_brand_title_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [hides channel badge for stable builds](../test/ui/core/widgets/memex_brand_title_test.dart#L18) | 宿主控件 | 通过 |
| [shows Early channel badge for early builds](../test/ui/core/widgets/memex_brand_title_test.dart#L27) | 宿主控件 | 通过 |
| [shows Dev channel badge for development builds](../test/ui/core/widgets/memex_brand_title_test.dart#L36) | 宿主控件 | 通过 |

</details>

<details>
<summary>phone_width_frame_test.dart · 5 项</summary>

[测试源文件](../test/ui/core/widgets/phone_width_frame_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [a phone portrait keeps the current full-width layout](../test/ui/core/widgets/phone_width_frame_test.dart#L43) | 宿主控件 | 通过 |
| [a phone turned sideways stays full width](../test/ui/core/widgets/phone_width_frame_test.dart#L54) | 宿主控件 | 通过 |
| [a large flat screen centers a phone-width column](../test/ui/core/widgets/phone_width_frame_test.dart#L63) | 宿主控件 | 通过 |
| [a half-open hinge keeps the full window](../test/ui/core/widgets/phone_width_frame_test.dart#L93) | 宿主控件 | 通过 |
| [a flat hinge is shifted into the centered column](../test/ui/core/widgets/phone_width_frame_test.dart#L112) | 宿主控件 | 通过 |

</details>

<details>
<summary>searchable_dropdown_test.dart · 1 项</summary>

[测试源文件](../test/ui/core/widgets/searchable_dropdown_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [dropdown arrow clears focus from another active text field](../test/ui/core/widgets/searchable_dropdown_test.dart#L6) | 宿主控件 | 通过 |

</details>

<details>
<summary>viewport_gated_test.dart · 2 项</summary>

[测试源文件](../test/ui/core/widgets/viewport_gated_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [builds the child only after it intersects the viewport](../test/ui/core/widgets/viewport_gated_test.dart#L6) | 宿主控件 | 通过 |
| [builds immediately when not inside a scroll view](../test/ui/core/widgets/viewport_gated_test.dart#L52) | 宿主控件 | 通过 |

</details>

<details>
<summary>arabic_layout_smoke_test.dart · 3 项</summary>

[测试源文件](../test/ui/rtl/arabic_layout_smoke_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [MainBottomBar lays out without overflow in Arabic RTL](../test/ui/rtl/arabic_layout_smoke_test.dart#L53) | 宿主控件 | 通过 |
| [TimelineFilterBar lays out without overflow in Arabic RTL](../test/ui/rtl/arabic_layout_smoke_test.dart#L77) | 宿主控件 | 通过 |
| [SummaryCard metrics lay out without overflow in Arabic RTL](../test/ui/rtl/arabic_layout_smoke_test.dart#L102) | 宿主控件 | 通过 |

</details>

<details>
<summary>date_util_test.dart · 4 项</summary>

[测试源文件](../test/utils/date_util_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [parseLocalDateTime keeps offset timestamps as the same local instant](../test/utils/date_util_test.dart#L6) | 组件/业务层 | 通过 |
| [parseLocalDateTime keeps timezone-less timestamps in local time](../test/utils/date_util_test.dart#L13) | 组件/业务层 | 通过 |
| [parseLocalDateTime parses unix seconds and milliseconds as UTC instants](../test/utils/date_util_test.dart#L19) | 组件/业务层 | 通过 |
| [parseLocalDateTime returns null for blank or invalid values](../test/utils/date_util_test.dart#L32) | 组件/业务层 | 通过 |

</details>

<details>
<summary>toast_helper_test.dart · 2 项</summary>

[测试源文件](../test/utils/toast_helper_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [uses unknownError when the error text is empty](../test/utils/toast_helper_test.dart#L16) | 组件/业务层 | 通过 |
| [keeps ApiException messages](../test/utils/toast_helper_test.dart#L23) | 组件/业务层 | 通过 |

</details>

<details>
<summary>user_storage_locale_test.dart · 18 项</summary>

[测试源文件](../test/utils/user_storage_locale_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [UserStorage locale resolution keeps supported German locale](../test/utils/user_storage_locale_test.dart#L8) | 组件/业务层 | 通过 |
| [UserStorage locale resolution keeps supported Japanese locale](../test/utils/user_storage_locale_test.dart#L14) | 组件/业务层 | 通过 |
| [UserStorage locale resolution keeps supported Spanish locale](../test/utils/user_storage_locale_test.dart#L20) | 组件/业务层 | 通过 |
| [UserStorage locale resolution keeps supported Portuguese locale](../test/utils/user_storage_locale_test.dart#L26) | 组件/业务层 | 通过 |
| [UserStorage locale resolution keeps supported French locale](../test/utils/user_storage_locale_test.dart#L32) | 组件/业务层 | 通过 |
| [UserStorage locale resolution keeps supported Korean locale](../test/utils/user_storage_locale_test.dart#L38) | 组件/业务层 | 通过 |
| [UserStorage locale resolution keeps supported Hindi locale](../test/utils/user_storage_locale_test.dart#L44) | 组件/业务层 | 通过 |
| [UserStorage locale resolution keeps supported Indonesian locale](../test/utils/user_storage_locale_test.dart#L50) | 组件/业务层 | 通过 |
| [UserStorage locale resolution keeps supported Arabic locale](../test/utils/user_storage_locale_test.dart#L56) | 组件/业务层 | 通过 |
| [UserStorage locale resolution keeps supported Russian locale](../test/utils/user_storage_locale_test.dart#L62) | 组件/业务层 | 通过 |
| [UserStorage locale resolution keeps supported Italian locale](../test/utils/user_storage_locale_test.dart#L68) | 组件/业务层 | 通过 |
| [UserStorage locale resolution keeps supported Traditional Chinese locale](../test/utils/user_storage_locale_test.dart#L74) | 组件/业务层 | 通过 |
| [UserStorage locale resolution resolves Traditional Chinese regions to zh_Hant](../test/utils/user_storage_locale_test.dart#L82) | 组件/业务层 | 通过 |
| [UserStorage locale resolution parses locale tags with script codes](../test/utils/user_storage_locale_test.dart#L90) | 组件/业务层 | 通过 |
| [UserStorage locale resolution falls back unsupported locales to English](../test/utils/user_storage_locale_test.dart#L98) | 组件/业务层 | 通过 |
| [UserStorage Memex Agent notification permission marker is scoped to the active user](../test/utils/user_storage_locale_test.dart#L110) | 组件/业务层 | 通过 |
| [UserStorage Memex Agent notification permission marker does not set a marker without a user](../test/utils/user_storage_locale_test.dart#L137) | 组件/业务层 | 通过 |
| [UserStorage Memex Agent notification permission marker classifies the permission prompt marker as device-local](../test/utils/user_storage_locale_test.dart#L146) | 组件/业务层 | 通过 |

</details>


<a id="cross-feature"></a>
## 跨功能业务场景

<details>
<summary>agent_refactor_functional_test.dart · 7 项</summary>

[测试源文件](../test/agent_refactor_functional_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [Agent Refactor Functional Coverage memory entries: add/replace/remove and context retrieval](../test/agent_refactor_functional_test.dart#L121) | 组件/业务层 | 通过 |
| [Agent Refactor Functional Coverage timeline append branches: empty content skipped, non-empty persisted](../test/agent_refactor_functional_test.dart#L168) | 组件/业务层 | 通过 |
| [Agent Refactor Functional Coverage context compressor branches: compress + cooldown skip](../test/agent_refactor_functional_test.dart#L203) | 组件/业务层 | 通过 |
| [Agent Refactor Functional Coverage context assembler: builds unified snapshot with clipped sections](../test/agent_refactor_functional_test.dart#L274) | 组件/业务层 | 通过 |
| [Agent Refactor Functional Coverage comment thread timeline stores post once with multiple comments](../test/agent_refactor_functional_test.dart#L315) | 组件/业务层 | 通过 |
| [Agent Refactor Functional Coverage knowledge context snippets expand around matched terms](../test/agent_refactor_functional_test.dart#L397) | 组件/业务层 | 通过 |
| [Agent Refactor Functional Coverage tavern import: json+png preview/import/conflict and invalid format](../test/agent_refactor_functional_test.dart#L427) | 导入 JSON/PNG→预览、冲突与结果 | 通过 |

</details>


<a id="shared"></a>
## 跨功能基础设施

<details>
<summary>global_event_bus_dependency_test.dart · 2 项</summary>

[测试源文件](../test/data/services/global_event_bus_dependency_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [maps legacy EventBus dependencies to wait-for-completion barriers](../test/data/services/global_event_bus_dependency_test.dart#L27) | 组件/业务层 | 通过 |
| [honors scheduleDelaySeconds when enqueueing async subscribers](../test/data/services/global_event_bus_dependency_test.dart#L98) | 组件/业务层 | 通过 |

</details>

<details>
<summary>event_bus_message_test.dart · 5 项</summary>

[测试源文件](../test/domain/models/event_bus_message_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [parses profile update messages from event payloads](../test/domain/models/event_bus_message_test.dart#L5) | 组件/业务层 | 通过 |
| [parses character update messages from event payloads](../test/domain/models/event_bus_message_test.dart#L21) | 组件/业务层 | 通过 |
| [parses persona chat unread change messages](../test/domain/models/event_bus_message_test.dart#L37) | 组件/业务层 | 通过 |
| [parses backup snapshot change messages from event payloads](../test/domain/models/event_bus_message_test.dart#L49) | 组件/业务层 | 通过 |
| [parses backup restored messages from event payloads](../test/domain/models/event_bus_message_test.dart#L65) | 组件/业务层 | 通过 |

</details>

<details>
<summary>system_event_test.dart · 4 项</summary>

[测试源文件](../test/domain/models/system_event_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [DataChangeRecord insert op: before is null, after is populated](../test/domain/models/system_event_test.dart#L6) | 组件/业务层 | 通过 |
| [DataChangeRecord update op: both before and after are populated](../test/domain/models/system_event_test.dart#L24) | 组件/业务层 | 通过 |
| [DataChangeRecord delete op: before is populated, after is null](../test/domain/models/system_event_test.dart#L55) | 组件/业务层 | 通过 |
| [DataChangeRecord legacy delete shape: both before and after are null](../test/domain/models/system_event_test.dart#L75) | 组件/业务层 | 通过 |

</details>

<details>
<summary>async_pool_test.dart · 3 项</summary>

[测试源文件](../test/utils/async_pool_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [keeps input order while overlapping work](../test/utils/async_pool_test.dart#L5) | 组件/业务层 | 通过 |
| [returns an empty list for empty input](../test/utils/async_pool_test.dart#L28) | 组件/业务层 | 通过 |
| [rejects a non-positive limit](../test/utils/async_pool_test.dart#L36) | 组件/业务层 | 通过 |

</details>

<details>
<summary>async_work_queue_test.dart · 1 项</summary>

[测试源文件](../test/utils/async_work_queue_test.dart)

| 用例 | 证据边界 | 本次 |
|---|---|---|
| [failed work releases its slot and queued work stays in order](../test/utils/async_work_queue_test.dart#L6) | 组件/业务层 | 通过 |

</details>
