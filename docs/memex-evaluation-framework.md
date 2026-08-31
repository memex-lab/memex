# Memex Agent 全链路评估体系

中文 | [English](memex-evaluation-framework.en.md)

本文档只覆盖 Agent 评测：从标准化输入进入 Memex Agent 链路开始，到 Card、Memory、PKM、检索问答、Comment、Schedule、Insight、工具轨迹、成本与稳定性产物结束。

不覆盖产品 UI、备份/恢复、语音转写、原始图片 OCR、分享导入、权限、设置页等非 Agent 能力。如果输入包含位置、健康、图片分析文本或 OCR 文本，本文只评估 Agent 是否正确使用这些已给定上下文，不评估这些上下文本身的采集质量。

## 1. 场景

### 1.1 内容场景

| 场景 | 定义 | 必须覆盖 | 主要风险 |
| --- | --- | --- | --- |
| 生活流记录 | 用户记录睡眠、精力、运动、饮食、出行、天气、位置、日常状态 | 短句、长段、跨日连续记录、临时状态、长期模式 | 临时状态被长期化，健康/位置事实被过度推断 |
| 产品自测记录 | 用户记录 app bug、功能建议、Agent 行为、评估失败、交互不顺 | bug 现象、环境线索、期望行为、跨日进展、后续查询 | bug 记录被误当个人偏好，复现线索丢失 |
| 执行力外脑 | 用户记录 todo、提醒、日程、约定、模糊行动 | 明确行动、模糊行动、相对时间、拒绝/确认动作 | 反思性表达被误建 action，未确认就行动 |
| 情绪与关系复盘 | 用户记录情绪、拖延、焦虑、沟通、人物关系、关系变化 | 情绪标签、人物识别、关系召回、短期情绪、长期关系 | 评论过度心理分析，人物关系召回错误导致理解错误 |
| 知识与决策池 | 用户记录 AI 工具、文章/书、产品 idea、投资/购物/订阅判断 | 资料沉淀、观点来源、后续查询、PKM 路由 | 资料观点与用户事实混淆，财务/专业建议越界 |
| 高敏场景 | 家庭、求职、健康用药、财务/税务、身份/联系信息 | 隐私边界、引用精度、拒答/免责声明、行动确认 | 医疗/财务确定性建议，隐私泄漏，错误行动 |
| 已解析多模态上下文 | 输入中已包含图片说明、截图文字、OCR/视觉分析摘要 | Agent 使用分析文本、source 绑定、Card/PKM/检索引用 | 把分析文本和用户原话混淆，附件上下文脱离 source |
| 长上下文事实 | 很久以前、跨多天、跨会话、跨文件的事实需要被召回 | 长期项目、人物关系、旧偏好、旧承诺、旧 bug | 只看最近事实，忽略长程事实，旧新事实冲突未处理 |
| 长对话追问 | 用户在多轮对话中连续追问同一主题 | 前文指代、追问范围、source 保持、上下文更新 | 多轮后丢失实体、人物关系、时间范围或事实来源 |
| 失败降级 | LLM 失败、quota/network 错误、YAML/JSON 解析失败、loop/maxTurns | 原始 fact 保留、任务失败可定位、后续 Agent 继续 | 输入丢失，任务卡死，失败被 completed 掩盖 |

### 1.2 Agent 链路场景

| 场景 | 必测 case | Corner case |
| --- | --- | --- |
| 输入理解与路由 | 多意图拆分、主题识别、敏感等级、是否行动、是否长期化 | 问句式记录、反思式行动、短期情绪、同一输入多产物 |
| Card Agent | 模板选择、标题、字段、标签、source fact、完成状态 | 多模板都合理、字段幻觉、completed 但有 failure reason |
| Memory | must-write、must-not-write、冲突更新、人物关系、长期偏好、source 追溯 | 一次性状态误写长期记忆，关系别名/指代错误 |
| PKM | PARA 路由、读后写、append/no-op、混合信号拆分、source grounding | 未读覆盖、大文件膨胀、重复创建近似文件、loop |
| 检索与问答 | Card/Memory/PKM/Insight 多源检索、时间过滤、排序、引用、证据不足 | 命中但排名过低，使用旧事实，把评论当事实 |
| Super Agent / Chat / Comment | 只读问答、个性化建议、多轮追问、自动评论、@mention、澄清 | 写工具越权、评论过度解读、人物关系理解错误 |
| Schedule / System Action | skip/dirty/refresh、提醒/日历 action、pending/rejected/completed | 相对时间错误、拒绝后重复打扰、模糊行动被直接执行 |
| Knowledge Insight | 首次洞察、增量洞察、跨日趋势、结构化输出、source grounding | 空泛重复洞察、坏 YAML/JSON、旧事实覆盖新事实 |
| Agent 稳定性与效率 | 输入完成耗时、LLM 轮次、工具调用、上下文读取、缓存命中、队列收敛 | 轮次膨胀、重复工具调用、工具失败但 task completed |
| Agent 成本 | 单次输入 token、每个 Agent token、cache hit、成本/成功任务 | 某个 Agent 成本异常、cache 失效、质量不升但成本上升 |

## 2. 指标详情

### 2.1 统计方式含义

| 统计方式 | 含义 |
| --- | --- |
| `micro` | 把所有样本的命中数和总数合并后计算，适合总体成功率、失败率、token 总量 |
| `macro per input` | 每条输入先算一个分数，再对所有输入取平均，避免长输入或多产物输入权重过大 |
| `macro per query` | 每个检索/问答 query 先算一个分数，再平均，适合 Recall@K、Citation Recall |
| `macro per task` | 每个 Agent task 先算一个分数，再平均，适合 Card/PKM/Schedule 等任务级指标 |
| `by agent` | 按 Agent 拆分统计。稳定性、工具、成本类指标必须同时输出全局值和 by-agent 值 |
| `by tool` | 按工具名拆分统计，适合工具失败率、工具延迟、重复工具调用 |
| `p50/p95/p99` | 延迟、轮次、工具调用数、token 数的分位数；p95/p99 用于观察长尾 |
| `pass@1` | 单次完整运行成功率，适合确定性或默认配置评估 |
| `pass^k` | 同一任务连续 k 次运行全部成功的比例，衡量 Agent 稳定性和非确定性可靠性 |
| `full-run` | 全量 case 都参与统计，不使用抽检。LLM judge 如被使用，也对全量相关 case 执行 |

### 2.2 输入理解与路由指标

| 指标 | 定义 | 口径 | 统计方式 | 获取方法 |
| --- | --- | --- | --- | --- |
| `compound_segment_coverage` | 复合输入中的 gold segment 是否被覆盖 | 被 Card/PKM/Memory/Action/Comment 正确覆盖的 segment 数 / 事前标注的 segment 总数 | macro per input + micro | gold segmentation、Agent outputs |
| `compound_segment_overmerge_rate` | 多意图被错误合并导致语义丢失 | 被合并后丢失独立主题/行动/时间的 segment 数 / 多意图 segment 总数 | micro | gold segmentation、Card fields、actions |
| `record_question_preservation_rate` | 问句式记录是否被保留为事实，而不是只当 QA | 原始问题语义在 Agent 产物中可见的记录数 / question-like record 总数 | micro | Facts、Cards、LLM equivalence |
| `reflection_action_false_positive_absence` | 反思性/假设性表达不误建 action | 未创建 action 的反思样本数 / actionability=禁止行动或需确认前不行动的样本数 | micro | action labels、system_actions、router trace |
| `temporary_state_personalization_absence` | 临时状态不被写成长期画像 | 未写入长期 Memory/PKM 人格化结论的临时状态数 / temporal_scope=瞬时或当天的样本数 | micro | Memory/PKM diff、gold temporal labels |
| `long_term_preference_write_recall` | 稳定偏好/约束被长期化 | 命中的长期偏好 gold atoms 数 / 事前标注的长期偏好或约束 gold atoms 数 | macro per input + micro | Memory/PKM diff、source fact ids |
| `project_self_test_traceability` | 产品自测记录能跨产物追溯 | 有 bug 现象、期望、环境线索、source fact 的记录数 / product-self-test records 总数 | micro | Card fields、PKM project file、retrieval source |
| `sensitive_domain_boundary_compliance` | 高敏领域遵守记录/总结边界 | 无越界建议、无隐私泄漏、无未授权行动的 outputs 数 / 高敏样本 outputs 总数 | micro | rule scanner、LLM judge、tool trace |
| `agent_route_accuracy` | 输入被路由到正确的下游 Agent | observed downstream agent set 与 expected agent set 匹配的输入数 / 有 expected routes 的输入数 | macro per input | router output、task list、expected routes |
| `agent_route_overtrigger_rate` | 不该触发的 Agent 被触发 | 多触发的 downstream agent 数 / observed downstream agent 总数 | micro, by agent | router trace、task list |
| `agent_route_miss_rate` | 应触发的 Agent 没有触发 | 漏触发的 downstream agent 数 / expected downstream agent 总数 | micro, by agent | expected routes、task list |

### 2.3 Card Agent 指标

| 指标 | 定义 | 口径 | 统计方式 | 获取方法 |
| --- | --- | --- | --- | --- |
| `card_materialization_rate` | 标准输入后生成对应 Card | 可按 factId 取回 Card 的输入数 / record 输入总数 | micro | Cards 文件、router fetch |
| `input_to_valid_card_success_rate` | 输入最终有合法主卡且无 `failure_reason` | 主卡存在、可解析、结构合法、无 failure reason 的 fact 数 / 输入 fact 总数 | micro | Facts、Cards parser |
| `card_completed_rate` | Card task 最终 completed | status=completed 的 Card 数 / materialized Card 数 | micro | Card YAML、task status |
| `completed_with_failure_reason_rate` | completed 但带 failure reason 的状态矛盾比例 | status=completed 且 `failure_reason` 非空的 Card 数 / completed Card 数 | micro | Card YAML |
| `card_schema_valid_rate` | Card 最小结构合法 | title、timestamp、status、ui_configs 等字段合法的 Card 数 / materialized Card 数 | micro | Card parser |
| `card_template_primary_accuracy` | 首个模板命中 gold | primary template 在 expected set 内的任务数 / card eval task 总数 | macro per task | task expected、Card uiConfigs |
| `card_template_any_accuracy` | 任意模板命中 gold | 任一 template 在 expected set 内的任务数 / card eval task 总数 | macro per task | task expected、Card uiConfigs |
| `card_field_precision` | 抽取字段中正确字段比例 | 正确 observed 字段数 / observed 字段总数 | micro, by field | field gold、规则/LLM equivalence |
| `card_field_recall` | 应抽字段被保留比例 | 命中的 gold 字段数 / gold 字段总数 | micro, by field | field gold、规则/LLM equivalence |
| `card_entity_recall` | 人物、地点、项目、金额等实体覆盖 | 命中的 gold entity 数 / gold entity 总数 | micro, by entity type | expected entities、Card data/search blob |
| `card_time_parse_accuracy` | 时间解析落在容差内 | observed time 与 gold time 差值 <= tolerance 的任务数 / 有 gold time 的任务数 | macro per task | Card data、expected time |
| `card_title_relevance_score` | 标题表达核心事实 | 标题 judge 达标的 Card 数 / Card 总数 | full-run macro | title、input、Card data、LLM judge |
| `card_hallucinated_field_absence` | 不出现禁止字段或编造细节 | 未出现 must_not_fields 的任务数 / 配置 must_not 的任务数 | micro | Card YAML、expected must_not |
| `card_source_fact_grounding_rate` | Card 指向正确 fact id/source | factId 与输入 factId 一致的 Card 数 / materialized Card 数 | micro | Card YAML path/factId |
| `card_cache_fts_freshness` | Card 文件、cache、FTS 同步 | 三者均可检索/取回的 Card 数 / completed Card 数 | micro | Cards、`card_cache`、`card_fts` |

### 2.4 Memory、人物关系与长上下文指标

| 指标 | 定义 | 口径 | 统计方式 | 获取方法 |
| --- | --- | --- | --- | --- |
| `memory_recall_at_10` | query 的 top10 memory 候选覆盖 gold memory atoms | top10 中命中的唯一 gold memory atoms 数 / 该 query 事前标注的 gold memory atoms 数。gold 必须事前标注，LLM 只判断语义等价，不事后决定 gold | macro per query + micro | ranked memory ids、source fact ids |
| `memory_must_write_recall` | 应写长期记忆是否写入 | 命中的 must-write gold facts 数 / must-write gold facts 总数 | macro per input + micro | Memory files/tool result |
| `memory_write_precision` | 写入记忆中正确长期事实比例 | 属于 gold 或可接受长期事实的 memory 数 / observed memory 总数 | micro | Memory entries、gold set、LLM judge |
| `memory_must_not_write_precision` | 临时/噪声没有被长期化 | 未被写入的 must-not facts 数 / must-not facts 总数 | micro | Memory entries、must_not labels |
| `memory_source_grounding` | memory 可追溯来源 | 带正确 source fact id/snippet 的 memory 数 / observed memory 数 | micro | memory metadata、source snippets |
| `memory_temporal_validity` | 有效期/时态正确 | valid_from/until/status 正确的 memory 数 / 需要时态判断的 memory 数 | micro | memory metadata、gold temporal constraints |
| `memory_conflict_handling` | 新事实覆盖或限定旧事实 | 正确更新、停用或限定旧记忆的 conflict case 数 / conflict case 总数 | macro per case | before/after memory diff |
| `memory_duplicate_rate` | 重复或近重复记忆比例 | duplicate memory entries 数 / observed memory 总数 | micro | embedding/LLM duplicate judge |
| `relationship_entity_resolution_accuracy` | 人物实体、别名、指代被正确归一 | 正确归一到 gold person id 的 mention 数 / person mention 总数 | micro, by relation type | person labels、Card/Memory/PKM outputs |
| `relationship_recall_at_10` | 人物关系相关 query 能召回正确关系事实 | top10 中命中的唯一 gold relationship facts 数 / 该 query 需要召回的 gold relationship facts 数 | macro per query + micro | retrieval trace、Memory/Card/PKM sources |
| `relationship_precision_at_10` | 召回的人物关系事实不混入错误关系 | top10 中相关 relationship facts 数 / top10 relationship candidates 数 | macro per query | retrieval trace、gold relations |
| `relationship_temporal_accuracy` | 人物关系变化的时间和有效性正确 | 使用正确关系版本的回答/产物数 / 有关系变化的任务数 | macro per task | source timestamps、answer citations |
| `relationship_reasoning_error_rate` | 因人物关系召回或识别错误导致最终理解错误 | 出现关系误用的任务数 / 涉及人物关系的任务数 | micro | final output、citations、gold relation graph |
| `long_context_fact_recall_at_10` | 长程事实 query 能召回远期事实 | top10 中命中的唯一 long-context gold facts 数 / query 需要的 long-context gold facts 数 | macro per query + micro | retrieval trace、source timestamps |
| `long_context_conversation_recall_at_10` | 长对话追问能召回前文关键事实 | top10 或 assembled context 中命中的 gold prior-turn facts 数 / 该 turn 需要的 prior-turn facts 数 | macro per turn | ChatSessions、context assembler trace |
| `long_context_staleness_error_rate` | 长上下文中错误使用过期事实 | 使用过期事实的任务数 / 有新旧冲突的长上下文任务数 | micro | source timestamps、answer citations |
| `coreference_resolution_accuracy` | “他/她/这个/上次/那件事”等指代解析正确 | 正确解析的 coreference mention 数 / coreference mention 总数 | micro | gold coreference labels、answer/tool args |

### 2.5 PKM 指标

| 指标 | 定义 | 口径 | 统计方式 | 获取方法 |
| --- | --- | --- | --- | --- |
| `pkm_completion_rate` | PKM task 到达 persist 或 clean skip | complete evidence 为 true 的任务数 / PKM 任务总数 | micro | `PkmRunCompletionEvidence`、task status |
| `pkm_path_accuracy` | 写入路径命中 gold bucket/file | path score 总和 / PKM persist task 总数；preferred file=1，acceptable bucket=partial，错误路径=0 | macro per task | workspace diff、expected path |
| `pkm_read_before_write_rate` | append/edit 前读取目标文件 | 写前读过 required path 的任务数 / 需要 append/edit 的任务数 | micro | tool transcript order |
| `pkm_no_overwrite_rate` | 旧内容未丢失 | seed marker 仍存在的任务数 / 有 seed marker 的任务数 | micro | before/after PKM snapshot |
| `pkm_content_preservation` | 关键事实被保留 | 命中的 must_include facts 数 / gold facts 总数 | micro | PKM content、LLM semantic match |
| `pkm_source_grounding` | PKM 条目包含 source fact id | 正确 source id 存在的条目数 / observed 或 gold PKM 条目数 | micro | PKM markdown marker |
| `pkm_append_coherence` | 追加内容符合原文件风格 | append coherence judge 达标的 append 数 / append task 总数 | macro per append | original file、new chunk、LLM judge |
| `pkm_merge_split_quality` | 合并/拆分数量符合预期 | entry count 在 min/max 或 split targets 命中的任务数 / PKM organization task 总数 | macro per task | workspace diff、expected min/max |
| `pkm_noop_accuracy` | 低信号输入 clean skip | 无 PKM mutation 且 task completed 的 no-op 数 / no-op task 总数 | micro | workspace diff、completion evidence |
| `pkm_clarification_completion_rate` | 含糊重要信息创建澄清后完成 | clarification created 且 task completed 的 case 数 / clarification-needed cases 总数 | micro | clarification_requests、task status |
| `pkm_redundant_tool_call_rate` | 同 query/path 重复工具调用比例 | 重复 Read/Grep/BatchRead 次数 / 全部 read/search 工具调用数 | micro | tool transcript |
| `pkm_loop_detection_absence` | 未触发 loop guard | 无 loopDetection 的 PKM task 数 / PKM task 总数 | micro | task error、AgentException code |

### 2.6 检索与问答指标

| 指标 | 定义 | 口径 | 统计方式 | 获取方法 |
| --- | --- | --- | --- | --- |
| `retrieval_hit_at_1/3/5/10` | top k 至少命中一个 gold source | hit 的 query 数 / 有 expected_sources 的 query 数 | macro per query | ranked sources、expected_sources |
| `retrieval_precision_at_1/3/5/10` | top k 相关比例 | top k 中 relevant source 数 / top k returned source 数 | macro per query + micro | ranked sources、gold set |
| `retrieval_recall_at_5/10` | top k 覆盖 gold source 比例 | top k 中唯一 gold source 数 / gold source 总数 | macro per query + micro | ranked sources、gold set |
| `retrieval_mrr` | 第一个正确来源排名倒数 | 所有 query 的 `1 / first_relevant_rank` 之和 / query 总数 | macro | ranked sources |
| `retrieval_ndcg_at_10` | 排序质量，支持分级相关 | DCG@10 / IDCG@10 | macro | graded relevance |
| `retrieval_filter_accuracy` | user/time/type/project/person filters 正确 | filters 完全或部分命中的 query 数 / 有 expected_filters 的 query 数 | macro | tool args、applied_filters |
| `citation_precision` | 引用来源都相关 | cited 中 relevant source 数 / cited source 总数 | micro | answer citations、expected_sources |
| `citation_recall` | 应引用来源被引用 | cited 中 gold source 数 / gold source 总数 | macro per query + micro | answer citations、expected_sources |
| `answer_must_include` | 答案包含必答信息 | 命中的 must_include 数 / must_include 总数 | macro per answer | answer text、rules/LLM equivalence |
| `unsupported_claim_absence` | 无无证据断言 | 无 unsupported claims 的回答数 / QA task 总数 | micro | source snippets、LLM judge |
| `grounded_answer_rate` | 答案完整且有来源支撑 | groundedness/completeness 达标回答数 / QA task 总数 | macro per answer | LLM judge with snippets |
| `abstention_accuracy` | 证据不足时拒答，证据足时不乱拒答 | abstain/answer 决策正确的任务数 / abstention-labeled task 总数 | micro | expected should_abstain、answer |
| `freshness_accuracy` | 使用最新有效事实 | answer 使用最新 source 的任务数 / 有旧新冲突 query 数 | micro | source timestamps、answer citations |
| `chat_recall_source_coverage` | 真实 chat 追问引用足够来源 | 回答引用覆盖 gold source 的 chat turns 数 / 有 expected_sources 的 chat turns 数 | macro per turn | ChatSessions、retrieval trace、citations |

### 2.7 Super Agent、Chat、Comment 指标

| 指标 | 定义 | 口径 | 统计方式 | 获取方法 |
| --- | --- | --- | --- | --- |
| `super_agent_read_only_compliance` | 只读场景无写入工具/side effect | 无 prohibited write call 的只读任务数 / read_only task 总数 | micro | tool transcript、system_actions |
| `tool_selection_accuracy` | 选择期望工具 | expected tool 被调用的任务数 / tool task 总数 | macro per task | trace tool_calls |
| `tool_args_accuracy` | 工具参数正确 | 参数字段和值匹配的调用数 / expected tool calls 总数 | micro | tool args |
| `tool_call_minimality` | 工具调用不超过预算 | call count <= max 的任务数 / 配置 max 的任务数 | micro | trace |
| `uncertainty_calibration` | 信息不足澄清/拒答，足够时回答 | 决策正确任务数 / uncertainty-labeled task 总数 | micro | answer、clarification/system action |
| `personalization_accuracy` | 利用用户偏好/上下文 | 命中 personalization_must_include 的回答数 / personalized task 总数 | macro per answer | answer、memory sources |
| `chat_session_persistence_rate` | 对话写入 ChatSessions | 可读取 session 的 chat 数 / chat 操作数 | micro | ChatSessions YAML、router chat |
| `multi_turn_context_retention` | 多轮追问保留上下文 | 后续回答引用前文/来源正确的 turns 数 / multi-turn eval turns 总数 | macro per turn | chat messages、LLM judge |
| `comment_relevance_score` | 评论与卡片内容相关 | 评论 relevance judge 达标数 / AI comment 总数 | full-run macro | card、comment、LLM judge |
| `comment_boundary_safety` | 评论不过度解读敏感内容 | 无越界、无诊断、无财务建议的评论数 / 敏感场景评论数 | micro | LLM safety judge |
| `comment_not_fact_leakage_absence` | 检索/回答不把 AI 评论当用户事实 | 未引用评论为事实的回答数 / 含评论干扰的 QA task 总数 | micro | source type、answer citations |
| `character_routing_accuracy` | @mention/角色选择正确 | 目标 character 命中的评论/回复数 / character-routed case 总数 | micro | comment character_id |

### 2.8 Schedule 与 System Action 指标

| 指标 | 定义 | 口径 | 统计方式 | 获取方法 |
| --- | --- | --- | --- | --- |
| `schedule_refresh_action_accuracy` | skip/dirty/refresh 决策正确 | predicted action == expected 的任务数 / schedule task 总数 | micro | router output、tool trace |
| `schedule_refresh_missed_absence` | 必刷不漏刷 | refresh expected 且触发 refresh 的 case 数 / refresh expected case 总数 | micro | schedule router/aggregator tasks |
| `schedule_refresh_unnecessary_absence` | 无需刷新时不刷 | skip expected 且未刷新的 case 数 / skip expected case 总数 | micro | tasks、tool calls |
| `schedule_refresh_duplicate_rate` | 同一变化不重复刷新 | duplicate refresh calls 数 / refresh calls 总数 | micro | tasks by bizId/factId |
| `schedule_time_parse_accuracy` | 日程时间正确 | start/end/reminder 在容差内的 events 数 / 有 gold time 的 events 数 | micro | schedule state、system action payload |
| `schedule_update_cancel_accuracy` | 修改/取消指向正确旧日程 | 正确 update/cancel 的 case 数 / update/cancel case 总数 | micro | schedule state before/after |
| `system_action_creation_accuracy` | reminder/calendar action 正确创建 | 正确 action payload 数 / action expected case 总数 | micro | `system_actions` table |
| `action_extraction_precision` | 创建的行动确实来自用户明确意图 | 正确 action payload 数 / observed system action 总数 | micro | System Actions、gold action labels |
| `action_extraction_recall` | 应创建或建议的行动没有漏掉 | 命中的 gold action 数 / gold action 总数 | micro | gold labels、System Actions、card fields |
| `due_time_exact_match` | 待办/日程时间解析完全匹配 | start/due/reminder 在容差内的 action 数 / 有 gold time 的 action 数 | micro | action payload、schedule state |
| `unconfirmed_action_creation_absence` | 需确认动作未被静默执行 | 未静默执行的需确认 actions 数 / 需用户确认的 gold actions 数 | micro | System Actions status、side-effect trace |
| `system_action_user_choice_respect` | rejected action 不重复打扰 | rejected 后无重复同 action 的 case 数 / rejected actions 总数 | micro | system_actions timeline |
| `schedule_aggregation_settlement_rate` | 聚合任务在预算内完成 | completed schedule_aggregator_task 数 / schedule aggregation task 总数 | micro | `tasks` table |

### 2.9 Knowledge Insight 指标

| 指标 | 定义 | 口径 | 统计方式 | 获取方法 |
| --- | --- | --- | --- | --- |
| `insight_generation_success_rate` | refresh 产生或更新 insight | 有新/更新 insight 的 refresh 数 / insight refresh 操作数 | micro | KnowledgeInsights files、tasks |
| `insight_parse_valid_rate` | insight 文件可解析 | parse 成功且字段合法的 insight 数 / insight 文件总数 | micro | KnowledgeInsights parser |
| `insight_grounding_rate` | 洞察有事实/PKM 支撑 | grounded judge 达标的 insight 数 / insight 总数 | full-run macro | source snippets、LLM judge |
| `insight_novelty_score` | 洞察不是重复旧内容 | novelty judge 达标的 insight 数 / insight 总数 | full-run macro | old/new insight diff、LLM judge |
| `insight_actionability_score` | 洞察有明确结论或可行动建议 | actionability judge 达标的 insight 数 / insight 总数 | full-run macro | LLM judge |
| `duplicate_insight_rate` | 重复洞察比例 | duplicate insight 数 / insight 总数 | micro | embedding/LLM duplicate judge |
| `insight_refresh_idempotence` | 无新数据时刷新不乱改 | no-op 或仅轻微更新的 refresh 数 / no-new-data refresh 数 | micro | before/after diff |
| `insight_source_coverage` | 洞察引用覆盖关键来源 | cited gold sources 数 / insight 所需 gold sources 数 | macro per insight + micro | insight citations、source labels |

### 2.10 Agent 轨迹、工具与规则遵守指标

| 指标 | 定义 | 口径 | 统计方式 | 获取方法 |
| --- | --- | --- | --- | --- |
| `end_to_end_task_success_rate` | Agent 全链路最终状态达成任务目标 | 最终产物和状态都满足 expected outcome 的 case 数 / case 总数 | pass@1, full-run | final artifacts、DB state、expected outcome |
| `final_state_match_rate` | 最终状态与事前标注目标状态一致 | state diff 完全或按规则等价的 case 数 / 有 target state 的 case 数 | micro | Cards、Memory、PKM、System Actions、expected state |
| `trajectory_rule_compliance` | 中间轨迹遵守任务规则和工具权限 | 无 prohibited action、无越权写入、无规则违背的 task 数 / task 总数 | micro, by agent | tool transcript、policy labels |
| `trajectory_efficiency_score` | 在达成目标时轨迹不过度冗长 | 达成目标且 turns/tools/peek 均在预算内的 task 数 / successful task 数 | macro per task, by agent | trace、budget config |
| `tool_selection_accuracy` | 选择期望工具 | expected tool 被调用的任务数 / tool task 总数 | macro per task, by agent | trace tool_calls |
| `tool_args_accuracy` | 工具参数正确 | 参数字段和值匹配的调用数 / expected tool calls 总数 | micro, by tool | tool args |
| `tool_call_failure_rate` | 工具调用失败比例 | isError 或 result failed 的 tool calls 数 / tool calls 总数 | micro, by tool and agent | tool transcript、agent activity response |
| `tool_call_retry_rate` | 同工具同参数失败后重试比例 | retry tool calls 数 / failed tool calls 数 | micro, by tool | tool transcript |
| `repeated_tool_call_rate` | 无新信息的重复工具调用比例 | same tool+args repeated calls 数 / tool calls 总数 | micro, by agent | normalized tool args |
| `read_tool_error_rate` | 只读工具失败率 | failed read-only tool calls 数 / read-only tool calls 总数 | micro, by tool | tool transcript |
| `write_tool_error_rate` | 写工具失败率 | failed write tool calls 数 / write tool calls 总数 | micro, by tool | tool transcript |
| `context_peek_count_per_task` | Agent 只读上下文读取次数 | Read/Grep/Glob/LS/BatchRead/search/retrieval 调用数 / agent task 数 | mean/p50/p95, by agent | tool transcript、agent activity |
| `context_peek_redundancy_rate` | “偷看”后未被使用或重复读取 | 重复 path/query 或未进入最终引用/写入依据的 peek 数 / context peek 调用总数 | micro, by agent | tool transcript、citations/source ids |
| `first_write_after_read_rate` | 写入前至少读取必要上下文 | 写工具前有相关 read/peek 的 write tasks 数 / write task 总数 | micro, by agent | tool transcript order |
| `agent_finalization_rate` | Agent 以预期完成工具或完成信号结束 | 有 completion evidence 的 agent tasks 数 / agent tasks 总数 | micro, by agent | completion evidence、task result |
| `agent_empty_response_rate` | Agent 返回空内容/空工具导致重试或失败 | empty/invalid response turns 数 / LLM turns 总数 | micro, by agent | trace、task error、provider response |
| `agent_turn_budget_violation_rate` | 对话轮次超过预算 | turns > max_turns_budget 的 tasks 数 / agent tasks 总数 | micro, by agent | LLM call record、trace |

### 2.11 Agent 稳定性、延迟与成本指标

所有本节指标必须输出全局值和 by-agent 值；对输入级指标，还要输出 by downstream chain。

| 指标 | 定义 | 口径 | 统计方式 | 获取方法 |
| --- | --- | --- | --- | --- |
| `input_required_chain_latency_ms` | 输入到必需 Agent 链路完成的耗时 | `last_required_task_completed_at - submit_at` | mean/p50/p95/p99, by chain | tasks by factId、replay wait |
| `input_full_idle_latency_ms` | 输入后 Agent 队列回到 idle 的耗时 | `queue_idle_at - submit_at` | mean/p50/p95/p99 | `LocalTaskExecutor` snapshot |
| `input_timeout_rate` | 输入未在预算内完成 | timeout 或 non-converged input 数 / record operations 总数 | micro, by chain | replay observation、tasks snapshot |
| `task_completion_status` | 观察结束时无 active/failed task | all completed 的 case 数 / real replay case 总数 | micro | `tasks` table |
| `failed_task_rate` | task failed 比例 | failed tasks 数 / task 总数 | micro, by task type and agent | `tasks.status` |
| `retry_rate` | task retry 比例 | retry_count > 0 task 数 / task 总数 | micro, by task type and agent | `tasks.retry_count` |
| `task_queue_pressure_p95` | 队列压力长尾 | pending+processing+retrying snapshot 值 | p95 | `TaskActivitySnapshot` |
| `loop_detection_absence` | 未触发 loopDetection | 无 loopDetection 的 case/task 数 / case/task 总数 | micro, by agent | task error、trace |
| `max_turns_absence` | 未触发 Maximum turns reached | 无 maxTurns 的 case/task 数 / case/task 总数 | micro, by agent | task error、trace |
| `agent_llm_turns_per_task` | 单个 Agent task 的 LLM 对话轮次 | ModelMessage/LLM call 数 / agent task 数 | mean/p50/p95/p99, by agent | `_System/llm_calls`、trace |
| `agent_tool_rounds_per_task` | 单个 Agent task 的工具轮次 | tool request/response round 数 / agent task 数 | mean/p50/p95/p99, by agent | `agent_activity_messages`、tool transcript |
| `tool_calls_per_input` | 每次输入触发的工具调用数量 | tool call 数 / record operation 数 | mean/p50/p95/p99, by agent and chain | trace tool calls |
| `tool_call_latency_p95_by_tool` | 工具调用耗时长尾 | tool latency samples | p95, by tool and agent | standardized tool transcript |
| `tokens_per_input` | 单次输入总 token 消耗 | 该输入关联所有 Agent LLM calls 的 total tokens 之和 / 输入数 | mean/p50/p95/p99, by chain | `_System/llm_calls`、factId/runId |
| `tokens_per_successful_input` | 成功输入的平均 token 消耗 | successful input 关联 total tokens 之和 / successful input 数 | mean, by chain | LLM records + end_to_end success |
| `tokens_by_agent` | 每个 Agent 消耗 token 数 | 某 Agent total tokens 之和 / run 总输入数；同时输出 sum | mean per input + sum, by agent | `_System/llm_calls` |
| `prompt_tokens_by_agent` | 每个 Agent prompt token 消耗 | 某 Agent prompt tokens 之和 / run 总输入数；同时输出 sum | mean per input + sum, by agent | `_System/llm_calls` |
| `completion_tokens_by_agent` | 每个 Agent completion token 消耗 | 某 Agent completion tokens 之和 / run 总输入数；同时输出 sum | mean per input + sum, by agent | `_System/llm_calls` |
| `thought_tokens_by_agent` | 每个 Agent reasoning/thought token 消耗 | 某 Agent thought tokens 之和 / run 总输入数；同时输出 sum | mean per input + sum, by agent | `_System/llm_calls` |
| `prompt_cache_token_hit_rate` | provider prompt cache token 命中率 | known-semantics cached tokens / known-semantics effective prompt tokens | micro, by provider/model/agent | token usage records |
| `prompt_cache_token_hit_rate_by_agent` | 每个 Agent 的 prompt cache token 命中率 | 某 Agent known-semantics cached tokens / 某 Agent known-semantics effective prompt tokens | micro, by agent | `_System/llm_calls` |
| `agent_response_cache_hit_rate` | responseId/prefix cache 被复用比例 | 返回有效 cached responseId 的 agent init 次数 / cache lookup 次数 | micro, by agent/model | `AgentCacheHelper` trace |
| `agent_response_cache_miss_reason_mix` | cache miss 原因分布 | missing、invalid、hash mismatch 次数 / cache miss 次数 | distribution, by agent/model | `AgentCacheHelper` trace |
| `cost_per_input` | 单次输入成本 | run 总成本 / record input 数 | mean + by agent | pricing table、LLM usage |
| `cost_per_successful_input` | 成功输入成本 | successful input 关联成本之和 / successful input 数 | mean + by chain | pricing table、LLM usage、success labels |

### 2.12 覆盖质量指标

| 指标 | 定义 | 口径 | 统计方式 | 获取方法 |
| --- | --- | --- | --- | --- |
| `scenario_family_coverage` | 数据集覆盖本文定义的内容场景 | covered scenario families 数 / expected scenario families 数 | set coverage | manifest labels |
| `agent_chain_coverage` | 数据集覆盖主要 Agent 链路 | covered agent chains 数 / expected agent chains 数 | set coverage | manifest、task trace |
| `cross_day_continuity_coverage` | 跨日有复盘、引用、后续行动链 | continuity chains 数 / expected chains 数 | count/coverage | operations/facts labels |
| `relationship_case_coverage` | 涉及人物关系、别名、指代、关系变化的 case 覆盖 | relationship case 数 / expected relationship quota | count/coverage | dataset labels |
| `long_context_case_coverage` | 涉及远期事实、长对话、跨文件召回的 case 覆盖 | long-context case 数 / expected long-context quota | count/coverage | dataset labels |
| `correction_operation_coverage` | 有纠错、覆盖旧偏好、撤销样本 | correction samples 数 / expected correction quota | count/coverage | labels |
| `noise_resilience_coverage` | 有噪声、临时情绪、不确定表达样本 | noise samples 数 / expected noise quota | count/coverage | labels |
| `follow_up_query_coverage` | 回看后继续追问闭环 | follow-up query tasks 数 / expected quota | count/coverage | operations/eval_tasks |
| `dataset_oracle_consistency` | expected 能从 ground truth 推出 | consistent audited tasks 数 / audited tasks 总数 | full-run | script checks、LLM judge |
