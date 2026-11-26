# Memex 用户功能地图

从下表选择用户操作，查看自动化测试实际到达的终点和待验收的条件。功能行链接到代表性测试文件；原生权限、跨进程和真实服务的操作见[设备验收清单](user-device-acceptance.zh.md)。

**读法**：部件测试可证明真实 Flutter 控件的点击与反馈。业务入口测试可证明经服务、文件和数据库得到的结果。设备测试才能证明系统权限、原生入口和应用生命周期。独立的页面测试和服务测试各自通过，并不能合并算作一次从页面到磁盘的执行。P0 涉及隐私、数据留存或无法记录；P1 涉及常用工作流；P2 是呈现和辅助操作的验收顺序。

## 先看每天都会用的四件事

| 我在 App 里做什么 | 当前用例实际走到的结果 | 完整屏幕验收还缺什么 |
|---|---|---|
| 写一条记录，稍后找回 | 在真实记录编辑器输入文字并发送已选照片，离线任务保留原文和原图。恢复队列后，本地模型替身调用生产工具保存，时间线与详情按原 ID 读回这条图文。另一用例在磁盘数据库重开后从搜索命中找回带图记录及评论 | 系统选图、发送后杀进程，再从首页找到同一条记录 |
| 打开列表，翻页，点一条看详情 | 校验新旧顺序、相同时间戳、按标签翻页、编辑和删除后的结果；在真实列表点开带图记录、返回、再次点开后可读回留言 | 带多页数据滚动后返回，仍保持原列表位置 |
| 在一条记录下评论，再回复 | 经生产评论入口发言，再回复第一条；重新查询详情，原文、评论顺序和回复指向均正确，另一条记录没有串评论。关闭自动评论后，仍可从详情输入框发送，退回列表再打开能看到留言 | 实际设备断网或发送失败后的提示与重试 |
| 浏览带图记录，快速滑到下一张 | 在图集控件左右滑动，逐页检查可见图片的像素为红、蓝、红；复用图片控件后，上一张图的延迟失败不会覆盖新图 | 从系统相册选图发布，在实际列表看到对应缩略图，点开原图并返回同一卡片 |

[真实页面链路](../test/integration/local_workspace_screens_test.dart) · [记录、列表与评论回读](../test/data/repositories/timeline_comment_journey_test.dart) · [分页](../test/data/repositories/timeline_pagination_property_test.dart) · [详情正文控件](../test/ui/timeline/widgets/timeline_card_detail_body_section_test.dart) · [图片解码与滚动复用](../test/ui/core/widgets/local_image_safety_test.dart)

## 全部功能和验收边界

| 优先级 | 从用户入口到可观察结果 | 已验证到哪里 | 尚需怎样的验收 |
|---|---|---|---|
| P0 | [安装 → 初次设置用户、语言、模型 → 重开进入首页](../test/app_startup_test.dart) | 启动服务编排、模型配置页和存储偏好分别有用例 | 全新安装和旧用户升级，经引导保存后杀进程重开 |
| P0 | [输入文字或打开快捷记录 → 保存 → 时间线和详情读到原文](../test/integration/local_workspace_screens_test.dart) | 从编辑器离线发送，恢复后由实际执行器处理同一任务，核对时间线中的卡片 ID、详情原文与附件；快捷动作和草稿另测 | 系统强制退出后，重新启动并从首页找回同一条图文 |
| P0 | [无网记录 → 删除等待中的记录 → 恢复网络 → 不再出现，下一条继续](../test/data/services/offline_capture_queue_test.dart) | 在真实发送、删除、队列恢复和时间线读取之间跑通；网络探针与任务执行器可控 | 飞行模式和系统终止进程后重启 |
| P0 | [长按录音 → 停止或取消 → 校对转写 → 发送](../test/ui/main_screen/quick_recording_transcript_test.dart) | 合成 PCM 的转写、已有草稿保存、空结果和异常有覆盖；语音提示与设置单测 | 麦克风权限、真实模型、编辑后保存和回看 |
| P1 | [系统分享、剪贴板、相册、相机、文件选择 → 草稿或导入 → 回看附件](../test/ui/main_screen/widgets/share_intent_handler_test.dart) | 分享分流、剪贴板预览、文件导入、缩略图、附件失败恢复及 iOS 选择器回调均有分层用例 | 从系统分享面板进入，含权限拒绝、取消、混合附件，保存后重新打开 |
| P0 | [滚动时间线、筛标签、翻页 → 找到正确卡片，打开详情、修改和删除](../test/data/repositories/timeline_pagination_property_test.dart) | 从真实文件写入、编辑、删除和重建索引，经分页入口读回；卡片详情、时间、地点、模板及视图更新有局部覆盖 | 从屏幕操作并跨进程恢复滚动、过滤及详情状态 |
| P1 | [按周或日期回顾、打开日历和聚合视图 → 对应日期的记录](../test/data/repositories/get_calendar_data_test.dart) | 跨年和闰日按负时差与非整点正时差分组，两天的首尾记录恰好出现一次；删记录后日历同步消失 | 从首页切换视图、跨月和夏令时打开正确记录 |
| P1 | [知识库搜索文件；时间线全文索引按关键词定位原记录](../test/integration/local_workspace_screens_test.dart) | 知识库搜索页从无结果到找到 Markdown 并打开正文；卡片业务查询验证修改和删除后重建索引，按结果 ID 找到原文及附件 | 自动增量索引和跨账号重开后没有旧命中 |
| P1 | [AI 整理记录 → 卡片类型、标签、关系与内容可查看](../test/integration/local_workspace_screens_test.dart) | 确定性模型通过实际工具保存带图卡片，核对详情的原文和附件；模板和事件更新另测 | 真实模型生成关联卡，打开附件及失败重试 |
| P1 | [打开卡片、评论或回复 → 正确对象收到更新，已查看提醒消失](../test/integration/card_detail_notification_e2e_test.dart) | 评论目标、前台抑制、从实际事件总线写入 SQLite 收件箱，验证合并、列表、删除和用户隔离 | 由卡片详情操作到活动中心读取，再重启确认已读状态 |
| P1 | [和助手对话、引用附件、澄清、继续或取消 → 正确会话保留消息和结果](../test/data/services/super_agent_chat_turn_resume_test.dart) | 对话提交、历史、流更新、持久化、恢复和工具策略分别测试；联网评测有独立条件 | 从对话框连续发送及中断，真实供应商出错后恢复，旧轮次不重复执行 |
| P0 | [授权或拒绝工具、原生动作 → 用户选择被遵守](../test/agent/security/file_permission_manager_test.dart) | 文件权限、只读运行、审批服务、系统操作卡等已分层覆盖 | 在设备上拒绝或撤销授权后触发同一动作，核对实际系统副作用 |
| P1 | [查看任务、后台运行和失败日志 → 找到状态并继续处理](../test/data/services/local_task_executor_test.dart) | 队列、重试、任务跟踪、后台协调及活动面板分别测试 | 退后台、系统回收、再启动，看到相同任务和唯一结果 |
| P1 | [浏览知识库、导入文档、打开目录和文件 → 内容可读](../test/ui/knowledge/knowledge_base_screen_test.dart) | PKM 列表、文档提取、目录/文件界面和导入控件分别覆盖 | 从系统文件选择到入库，再从知识库打开正文和媒体 |
| P1 | [浏览洞察、模板和关联记录 → 打开详情或固定后再找到](../test/ui/insight/insight_detail_page_test.dart) | 洞察生成辅助逻辑、列表、详情、模板失败态有测试 | 在同一工作区由原始记录生成洞察，固定并重启回看 |
| P1 | [查看、编辑或删除记忆 → 下次对话使用更新后的上下文](../test/agent/character_scene_memory_test.dart) | 记忆增删改、上下文拼装、列表时间和本地化有覆盖 | 从角色编辑页修改角色记忆后开始新会话，验证删除内容不再被引用 |
| P1 | [创建、编辑、导入角色和头像 → 角色配置可用](../test/agent_refactor_functional_test.dart) | 角色卡 JSON/PNG 导入、冲突、存储和头像编辑有覆盖 | 从系统选择器导入，保存后切角色并重启 |
| P1 | [角色评论、主动消息、私聊和历史 → 同一角色记得前文](../test/integration/character_conversation_pipeline_test.dart) | 记录→角色记忆→回复上下文、连续发送→持久化消息有业务链测试 | 在真实对话页切换角色、重新进入，验证模型输出和通知 |
| P0 | [备份 → 删记录 → 恢复 → 再次筛到原记录并读回正文](../test/data/services/backup_service_test.dart) | 经备份/恢复业务入口、真实文件和数据库读回；另有 WAL 最新写入、快照保留与确认对话框用例 | 在 iOS Files / Android 文档选择器上导入旧版备份并冷启动 |
| P0 | [更换用户或工作目录、迁移或克隆 → 正确用户的数据和附件可读](../test/integration/memex_router_init_test.dart) | 根目录切换、数据库迁移、附件引用、沙盒克隆有局部覆盖 | 使用两个工作区经设置切换，重启检查文件、搜索与通知均隔离 |
| P0 | [打开已上锁的 App → 错 PIN 仍不可进入 → 正确 PIN 后可操作](../test/ui/app_lock/app_entry_pin_test.dart) | 使用真实 MemexApp 和数字键盘、合成受保护路由，在 Flutter 宿主验证点击结果；另有宽限期状态序列 | 生物识别取消、系统任务切换缩略图、后台超时和冷启动的真机画面 |
| P1 | [配置提供商、模型角色、OAuth 或托管账号 → 测试连接并使用所选角色](../test/ui/settings/model_agent_config_pages_test.dart) | 配置页、角色选择、持久化、OAuth 错误文案、凭据配置有覆盖 | 浏览器返回、取消、过期、离线、本地服务商请求，以及退出或删除账号 |
| P1 | [设置地理上下文、健康及系统授权 → 记录反映选择](../test/ui/settings/location_context_settings_page_test.dart) | 位置覆盖、位置设置页、健康服务、原生动作分别验证 | 在真实权限对话框选择允许/拒绝并回看记录 |
| P1 | [导出文件、选择本机/iCloud/Android 目录 → 在外部读回](../test/ui/settings/widgets/backup_restore_page_test.dart) | 工作区文件与归档内容、备份位置界面有覆盖 | 用系统文件 App 打开导出的 Markdown 和关联媒体；存储撤权后重新选择 |
| P2 | [切语言、字体、RTL、外观与布局 → 当前页面可读可操作](../test/ui/rtl/arabic_layout_smoke_test.dart) | ARB 完整性、控件、不同语言/方向的页面分别有测试 | 重启后从首页走同一任务；缩放、长文本和辅助功能导航 |
| P2 | [个人中心、统计、用量、实验功能、模型/技能管理、诊断和更新 → 能查找和修改设置](../test/ui/settings/widgets/debug_settings_page_test.dart) | 用户统计、模型用量、调试视图、实验室、更新信息与部分设置有用例 | 从设置搜索进入子页，保存后重新打开；设备上完成更新/失败恢复 |
| P1 | 刷新时间线、等待处理完成、再次收到同一事件 | [列表控件](../test/ui/timeline/widgets/timeline_entry_dedupe_test.dart)实际断言同一卡片只有一个可见条目，旧状态被新正文替换；[切换筛选的加载用例](../test/ui/timeline/widgets/timeline_aux_query_isolation_test.dart)验证等待时可见加载提示，完成后仅显示新筛选结果 | 慢加载、空库与失败时刷新，再滚动到下一页，保留位置和已显示内容 |
| P1 | 在详情左右滑动图片、放大查看，播放音频附件 | [详情图集](../lib/ui/timeline/widgets/timeline/asset_header_gallery.dart)包含图片分页、缩放与音频播放入口；解码、图集分页与错误占位分别验收 | 双指缩放与翻页的手势冲突、离开页面停止播放、系统音频中断恢复 |
| P1 | 设置是否显示洞察、是否自动评论、最多几个角色参与 | [设置持久化](../lib/data/services/comment_settings_service.dart)和[评论处理入口](../lib/data/services/task_handlers/comment_agent_handler.dart)可定位；关闭自动评论时，显式指定角色有独立处理路径 | 设置重开和手动留言已实测；普通记录、显式提及角色的模型响应及人数上限待验 |
| P1 | 选择日期范围重新处理卡片，决定是否重跑后续任务 | [设置页用例](../test/ui/settings/widgets/debug_settings_page_test.dart)验到选择项和任务创建提示 | 对有范围内外记录的工作区执行，观察范围外内容保持原样，重复提交不重复生成下游结果 |
| P0 | 设置中取消或确认删除本地账号，重开后回到初次设置 | [真实设置页](../test/integration/local_workspace_screens_test.dart)验证错名、取消和确认；重建应用根页面进入引导。当前账号工作区及数据库已清除，另一个账号、普通文件和外部备份可读；[文件范围回归](../test/data/services/local_account_data_test.dart)覆盖 SQLite 辅助文件、链接及重复清理 | 真实设备的系统终止与重开，以及 iCloud 或文档树授权中断 |


## 应长期保持的属性

| 属性 | 判据与可复现输入 | 现有证据或待补层级 |
|---|---|---|
| 正文和记录 ID 一致 | 列表打开哪条记录，详情就读到那条原文；评论和回复不改变正文，也不串到邻卡 | [真实列表、评论与详情读回](../test/data/repositories/timeline_comment_journey_test.dart)；键盘发送和杀进程读回仍需设备验证 |
| 同一条记录只展示一次 | 重复收到处理中或完成更新后，列表保留一个相同 ID 的可见条目；完成正文取代过期占位 | [列表条目控件](../test/ui/timeline/widgets/timeline_entry_dedupe_test.dart)；刷新与分页响应乱序仍待补 |
| 评论线程归属 | 重新打开详情时，评论顺序、内容、回复目标 ID 与提交一致；另一条记录的评论集合不变 | [业务入口用例](../test/data/repositories/timeline_comment_journey_test.dart)，尚未验证重复点击发送时的语义 |
| 图片与当前附件一致 | 第一张、下一张、回到第一张时，实际显示的像素匹配各自文件；已滑走图片的迟到失败不能盖住当前图 | [本地图片与图集控件](../test/ui/core/widgets/local_image_safety_test.dart)；系统选图到发布、打开原图仍待设备验收 |
| 设置开关及清理范围 | 关闭自动评论应抑制非显式的角色参与；取消重处理或删除不应修改数据，确认后的范围与界面提示一致 | 关闭自动评论重开设置仍关闭，手动留言可用；删号错名、取消、确认后的文件范围均有页面和文件用例。重处理范围及显式提及角色的实际执行待验 |
| 重建前后结果等价 | 生成同时间戳、重复 ID 编辑、删除、不同标签；把实际各页拼起来，与独立维护的存活记录集合按时间、ID 排序比较，并检查每条原文 | [固定种子的分页属性测试](../test/data/repositories/timeline_pagination_property_test.dart)，包含最后一张空页 |
| 取消与恢复幂等 | 删除等待中的记录后，恢复网络仍不生成旧卡，后续依赖任务只运行一次 | [离线记录与队列](../test/data/services/offline_capture_queue_test.dart)；进程中断时序尚需设备验证 |
| 恢复往返 | 备份前的可见正文和标签，在删除后恢复回到原值；最新 WAL 数据也要可读 | [备份服务](../test/data/services/backup_service_test.dart)；旧版本、原生文件授权待补 |
| 身份和通知隔离 | 同用户、同类别、同对象重复更新只保留一条；另一用户相同操作独立；删除只作用于目标 | [真实通知服务与内存 SQLite](../test/data/services/user_notification_service_test.dart) |
| 鉴权单调性 | 未认证时，任意连续的后台/前台切换不能取得认证；已认证会话只能在宽限内续用 | [32 组边界组合](../test/ui/app_lock/app_lock_session_test.dart)、[真实 PIN 控件与受保护路由](../test/ui/app_lock/app_entry_pin_test.dart) |
| 转写失败不丢草稿 | 空、缺失或异常的最终结果都保留原文本，包括空格、换行与 Unicode；异常标志仍可见 | [转写输入组合](../test/ui/main_screen/quick_recording_transcript_test.dart)；设备手势到保存仍待验 |
| 迁移兼容、附件完整 | 恢复或迁移前后，同一记录引用的媒体可打开且内容一致 | [附件迁移测试](../test/data/repositories/migrate_cards_fact_assets_test.dart)和备份测试有局部证据；跨版本设备样本待补 |
| 副作用唯一、权限有效 | 重试、取消或切换会话不能执行两次系统操作；拒绝后不产生副作用 | 现有权限与审批测试见索引；系统实际执行次数、拒绝和撤权仍待设备验收 |
| 导入重名与媒体安全 | 不同文件使用相同名称时，两份内容都应保留，后导入者取得不冲突的名称；归档里的越界路径永远不能成为工作区外文件；混合附件不能丢失正文 | [导入服务](../test/data/services/file_import_service_test.dart)、[分享分流](../test/ui/main_screen/widgets/share_intent_handler_test.dart)有示例；从外部 App 发起的组合待补 |
| 搜索与文件一致 | 对同一批内容新增、改名、重标或删除后，搜索结果 ID 应与当前工作区匹配；切换用户后无前一用户的结果 | [搜索更新判定](../test/data/services/search_service_test.dart)覆盖触发逻辑；另有[重建索引后按关键词读详情、修改和删除](../test/data/repositories/timeline_comment_journey_test.dart)。自动增量和多账号切换待补 |
| 日历边界 | 记录属于本地日期的唯一一天；月末、跨年与夏令时不会遗漏或重复 | [日历查询](../test/data/repositories/get_calendar_data_test.dart)和[日期工具](../test/utils/date_util_test.dart)；设备时区切换后的页面读回待补 |
| 对话因果顺序 | 连续发送、打断和恢复后，回复仍归属原角色、原会话和原轮次，重复处理不新增一组消息 | [角色会话业务链](../test/integration/character_conversation_pipeline_test.dart)、[会话恢复](../test/data/services/persona_chat_workspace_recovery_test.dart) |
| 关联对象一致 | 角色、卡片、洞察和 PKM 关联在重开后指向同一对象；缺失引用不应展示另一对象 | [卡片加载](../test/data/repositories/hydrate_card_cache_test.dart)、[洞察详情](../test/ui/insight/insight_detail_page_test.dart)有局部证据；跨页面关联闭环待补 |
| 模型选择与故障隔离 | 改一个角色的模型不影响其他角色；切换默认模型再重开后保留选择；连接失败时草稿保留 | [角色配置](../test/data/services/model_role_config_service_test.dart)、[模型设置控件](../test/ui/settings/model_agent_config_pages_test.dart)；真实提供商出错后的用户结果待补 |
| 后台任务可恢复 | 网络恢复、重复唤醒、前后台切换后，已完成任务的结果唯一，下一项仍可继续 | [本地执行器](../test/data/services/local_task_executor_test.dart)和离线记录；操作系统杀进程后的行为待补 |
| 语言切换不改业务数据 | 切换语言应保留同一记录 ID、原文、用户时区与操作能力；翻译目录键集合一致 | [语言偏好](../test/utils/user_storage_locale_test.dart)、[RTL 页面](../test/ui/rtl/arabic_layout_smoke_test.dart)、[ARB 键](../test/l10n/arb_key_parity_test.dart)；跨语言全旅程待补 |
| 更新与账号边界 | 取消或失败的更新保留现有资料；退出账号后，下一账号不能看见前一账号的通知、历史或凭据 | [版本判断](../test/data/services/app_update_service_test.dart)、通知隔离和[退出期间前台执行器的任务写回原账号](../test/integration/memex_router_init_test.dart)有自动化验证；Android 后台执行器在切换或删除账号期间的写入、安装升级和设备重新登录仍待验收 |

在项目根目录运行 `flutter test <测试文件路径>` 可复跑单个文件。运行 `python3 scripts/verify_pr.py --base origin/main --list` 可查看当前改动命中的场景，去掉 `--list` 即可执行。
