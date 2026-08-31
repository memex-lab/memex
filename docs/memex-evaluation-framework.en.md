# Memex End-to-End Agent Evaluation Framework

[中文](memex-evaluation-framework.md) | English

This document covers Agent evaluation only: from standardized input entering the Memex Agent pipeline through to Card, Memory, PKM, retrieval Q&A, Comment, Schedule, Insight, tool trajectories, cost, and stability artifacts.

It does not cover product UI, backup/restore, speech transcription, raw image OCR, share import, permissions, settings pages, or other non-Agent capabilities. If input includes location, health, image analysis text, or OCR text, this document evaluates only whether the Agent correctly uses that given context—not the quality of how that context was collected.

## 1. Scenarios

### 1.1 Content Scenarios

| Scenario | Definition | Must Cover | Primary Risks |
| --- | --- | --- | --- |
| Life-stream logging | User records sleep, energy, exercise, diet, travel, weather, location, daily state | Short sentences, long passages, cross-day continuous records, temporary state, long-term patterns | Temporary state persisted as long-term; health/location facts over-inferred |
| Product self-test logging | User records app bugs, feature suggestions, Agent behavior, eval failures, interaction friction | Bug symptoms, environment clues, expected behavior, cross-day progress, follow-up queries | Bug records mistaken for personal preferences; reproduction clues lost |
| Execution external brain | User records todos, reminders, schedules, commitments, vague actions | Explicit actions, vague actions, relative time, reject/confirm actions | Reflective expressions mistaken for actions; action taken without confirmation |
| Emotion and relationship review | User records emotions, procrastination, anxiety, communication, people, relationship changes | Emotion labels, person identification, relationship recall, short-term emotion, long-term relationships | Comments over-psychologize; wrong relationship recall leads to misunderstanding |
| Knowledge and decision pool | User records AI tools, articles/books, product ideas, investment/shopping/subscription judgments | Material accumulation, opinion sources, follow-up queries, PKM routing | Source opinions confused with user facts; financial/professional advice overreach |
| High-sensitivity scenarios | Family, job search, health/medication, finance/tax, identity/contact info | Privacy boundaries, citation precision, refusal/disclaimer, action confirmation | Medical/financial definitive advice; privacy leakage; wrong actions |
| Parsed multimodal context | Input already contains image descriptions, screenshot text, OCR/vision analysis summaries | Agent uses analysis text, source binding, Card/PKM/retrieval citations | Analysis text confused with user utterances; attachment context detached from source |
| Long-context facts | Facts from long ago, across days, sessions, or files must be recalled | Long-term projects, relationships, old preferences, old commitments, old bugs | Only recent facts considered; long-range facts ignored; old/new conflicts unhandled |
| Long-conversation follow-up | User asks consecutive follow-up questions on the same topic across turns | Prior-turn reference, follow-up scope, source preservation, context updates | Entities, relationships, time ranges, or fact sources lost after multiple turns |
| Failure degradation | LLM failure, quota/network errors, YAML/JSON parse failure, loop/maxTurns | Raw fact preserved, task failure locatable, subsequent Agents continue | Input lost; task stuck; failure masked as completed |

### 1.2 Agent Pipeline Scenarios

| Scenario | Required test cases | Corner cases |
| --- | --- | --- |
| Input understanding and routing | Multi-intent segmentation, topic identification, sensitivity level, whether to act, whether to persist long-term | Question-style records, reflective actions, short-term emotion, single input → multiple artifacts |
| Card Agent | Template selection, title, fields, tags, source fact, completion status | Multiple templates equally valid; field hallucination; completed but with failure reason |
| Memory | must-write, must-not-write, conflict updates, relationships, long-term preferences, source traceability | One-off state written to long-term memory; relationship alias/reference errors |
| PKM | PARA routing, read-then-write, append/no-op, mixed-signal splitting, source grounding | Unread overwrite; large file bloat; duplicate near-identical files; loop |
| Retrieval and Q&A | Card/Memory/PKM/Insight multi-source retrieval, time filtering, ranking, citations, insufficient evidence | Hit but ranked too low; old facts used; comments treated as facts |
| Super Agent / Chat / Comment | Read-only Q&A, personalized advice, multi-turn follow-up, auto comments, @mention, clarification | Write-tool overreach; comment over-interpretation; relationship misunderstanding |
| Schedule / System Action | skip/dirty/refresh, reminder/calendar actions, pending/rejected/completed | Relative time errors; repeated nagging after rejection; vague actions executed directly |
| Knowledge Insight | First insight, incremental insight, cross-day trends, structured output, source grounding | Vague duplicate insights; bad YAML/JSON; old facts overwriting new facts |
| Agent stability and efficiency | Input completion latency, LLM turns, tool calls, context reads, cache hits, queue convergence | Turn inflation; repeated tool calls; tool failure but task completed |
| Agent cost | Per-input tokens, per-Agent tokens, cache hit, cost per successful task | Abnormal cost for one Agent; cache miss; cost rises without quality gain |

## 2. Metric Details

### 2.1 Aggregation Method Definitions

| Method | Meaning |
| --- | --- |
| `micro` | Merge hit counts and totals across all samples before computing; suitable for overall success rate, failure rate, total tokens |
| `macro per input` | Compute one score per input first, then average across inputs; avoids overweighting long inputs or multi-artifact inputs |
| `macro per query` | Compute one score per retrieval/Q&A query first, then average; suitable for Recall@K, Citation Recall |
| `macro per task` | Compute one score per Agent task first, then average; suitable for Card/PKM/Schedule and other task-level metrics |
| `by agent` | Break down statistics by Agent. Stability, tool, and cost metrics must output both global and by-agent values |
| `by tool` | Break down statistics by tool name; suitable for tool failure rate, tool latency, repeated tool calls |
| `p50/p95/p99` | Percentiles for latency, turns, tool call count, token count; p95/p99 for observing long tails |
| `pass@1` | Single full-run success rate; suitable for deterministic or default-config evaluation |
| `pass^k` | Proportion of k consecutive runs all succeeding on the same task; measures Agent stability and non-deterministic reliability |
| `full-run` | All cases participate in statistics; no sampling. If LLM judge is used, it runs on all relevant cases |

### 2.2 Input Understanding and Routing Metrics

| Metric | Definition | Formula | Aggregation | Collection Method |
| --- | --- | --- | --- | --- |
| `compound_segment_coverage` | Gold segments in compound input are covered | Segments correctly covered by Card/PKM/Memory/Action/Comment / total pre-labeled segments | macro per input + micro | gold segmentation, Agent outputs |
| `compound_segment_overmerge_rate` | Multi-intent wrongly merged causing semantic loss | Segments losing independent topic/action/time after merge / total multi-intent segments | micro | gold segmentation, Card fields, actions |
| `record_question_preservation_rate` | Question-style records preserved as facts, not only as QA | Records where original question semantics visible in Agent artifacts / total question-like records | micro | Facts, Cards, LLM equivalence |
| `reflection_action_false_positive_absence` | Reflective/hypothetical expressions do not create actions | Reflective samples with no action created / samples where actionability=forbid action or no action before confirmation | micro | action labels, system_actions, router trace |
| `temporary_state_personalization_absence` | Temporary state not written as long-term profile | Temporary states not written to long-term Memory/PKM personalization conclusions / samples where temporal_scope=instant or same-day | micro | Memory/PKM diff, gold temporal labels |
| `long_term_preference_write_recall` | Stable preferences/constraints persisted long-term | Hit long-term preference gold atoms / total pre-labeled long-term preference or constraint gold atoms | macro per input + micro | Memory/PKM diff, source fact ids |
| `project_self_test_traceability` | Product self-test records traceable across artifacts | Records with bug symptom, expectation, environment clue, source fact / total product-self-test records | micro | Card fields, PKM project file, retrieval source |
| `sensitive_domain_boundary_compliance` | High-sensitivity domains respect record/summary boundaries | Outputs with no overreach advice, no privacy leakage, no unauthorized actions / total high-sensitivity sample outputs | micro | rule scanner, LLM judge, tool trace |
| `agent_route_accuracy` | Input routed to correct downstream Agents | Inputs where observed downstream agent set matches expected agent set / inputs with expected routes | macro per input | router output, task list, expected routes |
| `agent_route_overtrigger_rate` | Agents triggered when they should not be | Over-triggered downstream agents / total observed downstream agents | micro, by agent | router trace, task list |
| `agent_route_miss_rate` | Agents that should trigger did not | Missed downstream agents / total expected downstream agents | micro, by agent | expected routes, task list |

### 2.3 Card Agent Metrics

| Metric | Definition | Formula | Aggregation | Collection Method |
| --- | --- | --- | --- | --- |
| `card_materialization_rate` | Corresponding Card generated after standard input | Inputs with retrievable Card by factId / total record inputs | micro | Cards file, router fetch |
| `input_to_valid_card_success_rate` | Input ends with valid primary card and no `failure_reason` | Facts with primary card present, parseable, structurally valid, no failure reason / total input facts | micro | Facts, Cards parser |
| `card_completed_rate` | Card task ultimately completed | Cards with status=completed / materialized Cards | micro | Card YAML, task status |
| `completed_with_failure_reason_rate` | Contradictory rate of completed but with failure reason | Cards with status=completed and non-empty `failure_reason` / completed Cards | micro | Card YAML |
| `card_schema_valid_rate` | Card minimal structure valid | Cards with valid title, timestamp, status, ui_configs, etc. / materialized Cards | micro | Card parser |
| `card_template_primary_accuracy` | First template hits gold | Tasks where primary template in expected set / total card eval tasks | macro per task | task expected, Card uiConfigs |
| `card_template_any_accuracy` | Any template hits gold | Tasks where any template in expected set / total card eval tasks | macro per task | task expected, Card uiConfigs |
| `card_field_precision` | Proportion of correct fields among extracted fields | Correct observed fields / total observed fields | micro, by field | field gold, rule/LLM equivalence |
| `card_field_recall` | Proportion of required fields retained | Hit gold fields / total gold fields | micro, by field | field gold, rule/LLM equivalence |
| `card_entity_recall` | Coverage of people, places, projects, amounts, etc. | Hit gold entities / total gold entities | micro, by entity type | expected entities, Card data/search blob |
| `card_time_parse_accuracy` | Time parsing within tolerance | Tasks where observed time vs gold time delta <= tolerance / tasks with gold time | macro per task | Card data, expected time |
| `card_title_relevance_score` | Title expresses core fact | Cards passing title judge / total Cards | full-run macro | title, input, Card data, LLM judge |
| `card_hallucinated_field_absence` | No forbidden fields or fabricated details | Tasks with no must_not_fields / tasks configured with must_not | micro | Card YAML, expected must_not |
| `card_source_fact_grounding_rate` | Card points to correct fact id/source | Cards with factId matching input factId / materialized Cards | micro | Card YAML path/factId |
| `card_cache_fts_freshness` | Card file, cache, FTS in sync | Cards retrievable from all three / completed Cards | micro | Cards, `card_cache`, `card_fts` |

### 2.4 Memory, Relationships, and Long-Context Metrics

| Metric | Definition | Formula | Aggregation | Collection Method |
| --- | --- | --- | --- | --- |
| `memory_recall_at_10` | Top-10 memory candidates cover gold memory atoms for query | Unique gold memory atoms hit in top10 / gold memory atoms pre-labeled for that query. Gold must be pre-labeled; LLM judges semantic equivalence only, does not decide gold post hoc | macro per query + micro | ranked memory ids, source fact ids |
| `memory_must_write_recall` | Required long-term memories written | Hit must-write gold facts / total must-write gold facts | macro per input + micro | Memory files/tool result |
| `memory_write_precision` | Proportion of correct long-term facts among written memories | Memories belonging to gold or acceptable long-term facts / total observed memories | micro | Memory entries, gold set, LLM judge |
| `memory_must_not_write_precision` | Temporary/noise not persisted long-term | Must-not facts not written / total must-not facts | micro | Memory entries, must_not labels |
| `memory_source_grounding` | Memory traceable to source | Memories with correct source fact id/snippet / observed memories | micro | memory metadata, source snippets |
| `memory_temporal_validity` | Validity/tense correct | Memories with correct valid_from/until/status / memories requiring temporal judgment | micro | memory metadata, gold temporal constraints |
| `memory_conflict_handling` | New facts overwrite or qualify old facts | Conflict cases correctly updating, deactivating, or qualifying old memory / total conflict cases | macro per case | before/after memory diff |
| `memory_duplicate_rate` | Duplicate or near-duplicate memory proportion | Duplicate memory entries / total observed memories | micro | embedding/LLM duplicate judge |
| `relationship_entity_resolution_accuracy` | Person entities, aliases, references correctly normalized | Mentions correctly normalized to gold person id / total person mentions | micro, by relation type | person labels, Card/Memory/PKM outputs |
| `relationship_recall_at_10` | Relationship-related queries recall correct relationship facts | Unique gold relationship facts hit in top10 / gold relationship facts required for that query | macro per query + micro | retrieval trace, Memory/Card/PKM sources |
| `relationship_precision_at_10` | Recalled relationship facts do not mix in wrong relationships | Relevant relationship facts in top10 / top10 relationship candidates | macro per query | retrieval trace, gold relations |
| `relationship_temporal_accuracy` | Relationship change time and validity correct | Answers/artifacts using correct relationship version / tasks with relationship changes | macro per task | source timestamps, answer citations |
| `relationship_reasoning_error_rate` | Final misunderstanding due to relationship recall or identification error | Tasks with relationship misuse / tasks involving relationships | micro | final output, citations, gold relation graph |
| `long_context_fact_recall_at_10` | Long-range fact queries recall distant facts | Unique long-context gold facts hit in top10 / long-context gold facts required by query | macro per query + micro | retrieval trace, source timestamps |
| `long_context_conversation_recall_at_10` | Long-conversation follow-up recalls prior-turn key facts | Gold prior-turn facts hit in top10 or assembled context / prior-turn facts required for that turn | macro per turn | ChatSessions, context assembler trace |
| `long_context_staleness_error_rate` | Stale facts wrongly used in long context | Tasks using stale facts / long-context tasks with old/new conflicts | micro | source timestamps, answer citations |
| `coreference_resolution_accuracy` | "He/she/this/last time/that matter" etc. resolved correctly | Correctly resolved coreference mentions / total coreference mentions | micro | gold coreference labels, answer/tool args |

### 2.5 PKM Metrics

| Metric | Definition | Formula | Aggregation | Collection Method |
| --- | --- | --- | --- | --- |
| `pkm_completion_rate` | PKM task reaches persist or clean skip | Tasks with complete evidence=true / total PKM tasks | micro | `PkmRunCompletionEvidence`, task status |
| `pkm_path_accuracy` | Write path hits gold bucket/file | Sum of path scores / total PKM persist tasks; preferred file=1, acceptable bucket=partial, wrong path=0 | macro per task | workspace diff, expected path |
| `pkm_read_before_write_rate` | Target file read before append/edit | Tasks that read required path before write / tasks requiring append/edit | micro | tool transcript order |
| `pkm_no_overwrite_rate` | Old content not lost | Tasks where seed marker still present / tasks with seed marker | micro | before/after PKM snapshot |
| `pkm_content_preservation` | Key facts preserved | Hit must_include facts / total gold facts | micro | PKM content, LLM semantic match |
| `pkm_source_grounding` | PKM entries contain source fact id | Entries with correct source id / observed or gold PKM entries | micro | PKM markdown marker |
| `pkm_append_coherence` | Appended content matches original file style | Appends passing append coherence judge / total append tasks | macro per append | original file, new chunk, LLM judge |
| `pkm_merge_split_quality` | Merge/split counts meet expectations | Tasks with entry count in min/max or split targets hit / total PKM organization tasks | macro per task | workspace diff, expected min/max |
| `pkm_noop_accuracy` | Low-signal input clean skip | No-ops with no PKM mutation and task completed / total no-op tasks | micro | workspace diff, completion evidence |
| `pkm_clarification_completion_rate` | Ambiguous important info: clarification created then completed | Cases with clarification created and task completed / total clarification-needed cases | micro | clarification_requests, task status |
| `pkm_redundant_tool_call_rate` | Repeated tool calls on same query/path | Repeated Read/Grep/BatchRead calls / total read/search tool calls | micro | tool transcript |
| `pkm_loop_detection_absence` | Loop guard not triggered | PKM tasks without loopDetection / total PKM tasks | micro | task error, AgentException code |

### 2.6 Retrieval and Q&A Metrics

| Metric | Definition | Formula | Aggregation | Collection Method |
| --- | --- | --- | --- | --- |
| `retrieval_hit_at_1/3/5/10` | Top k hits at least one gold source | Queries with hit / queries with expected_sources | macro per query | ranked sources, expected_sources |
| `retrieval_precision_at_1/3/5/10` | Relevant proportion in top k | Relevant sources in top k / top k returned sources | macro per query + micro | ranked sources, gold set |
| `retrieval_recall_at_5/10` | Top k covers gold source proportion | Unique gold sources in top k / total gold sources | macro per query + micro | ranked sources, gold set |
| `retrieval_mrr` | Reciprocal rank of first correct source | Sum of `1 / first_relevant_rank` across queries / total queries | macro | ranked sources |
| `retrieval_ndcg_at_10` | Ranking quality with graded relevance | DCG@10 / IDCG@10 | macro | graded relevance |
| `retrieval_filter_accuracy` | user/time/type/project/person filters correct | Queries with filters fully or partially matched / queries with expected_filters | macro | tool args, applied_filters |
| `citation_precision` | All cited sources relevant | Relevant sources among cited / total cited sources | micro | answer citations, expected_sources |
| `citation_recall` | Required sources cited | Gold sources among cited / total gold sources | macro per query + micro | answer citations, expected_sources |
| `answer_must_include` | Answer contains required information | Hit must_include / total must_include | macro per answer | answer text, rules/LLM equivalence |
| `unsupported_claim_absence` | No unsupported assertions | Answers with no unsupported claims / total QA tasks | micro | source snippets, LLM judge |
| `grounded_answer_rate` | Answer complete and source-supported | Answers passing groundedness/completeness / total QA tasks | macro per answer | LLM judge with snippets |
| `abstention_accuracy` | Abstain when evidence insufficient; answer when sufficient | Tasks with correct abstain/answer decision / total abstention-labeled tasks | micro | expected should_abstain, answer |
| `freshness_accuracy` | Uses latest valid facts | Answers using latest source / queries with old/new conflicts | micro | source timestamps, answer citations |
| `chat_recall_source_coverage` | Real chat follow-up cites sufficient sources | Chat turns where answer citations cover gold sources / chat turns with expected_sources | macro per turn | ChatSessions, retrieval trace, citations |

### 2.7 Super Agent, Chat, Comment Metrics

| Metric | Definition | Formula | Aggregation | Collection Method |
| --- | --- | --- | --- | --- |
| `super_agent_read_only_compliance` | Read-only scenarios have no write tools/side effects | Read-only tasks with no prohibited write call / total read_only tasks | micro | tool transcript, system_actions |
| `tool_selection_accuracy` | Expected tool selected | Tasks where expected tool called / total tool tasks | macro per task | trace tool_calls |
| `tool_args_accuracy` | Tool arguments correct | Calls with matching param fields and values / total expected tool calls | micro | tool args |
| `tool_call_minimality` | Tool calls within budget | Tasks with call count <= max / tasks with configured max | micro | trace |
| `uncertainty_calibration` | Clarify/refuse when info insufficient; answer when sufficient | Tasks with correct decision / total uncertainty-labeled tasks | micro | answer, clarification/system action |
| `personalization_accuracy` | Uses user preferences/context | Answers hitting personalization_must_include / total personalized tasks | macro per answer | answer, memory sources |
| `chat_session_persistence_rate` | Conversations written to ChatSessions | Chats with readable session / total chat operations | micro | ChatSessions YAML, router chat |
| `multi_turn_context_retention` | Multi-turn follow-up retains context | Subsequent turns correctly citing prior context/sources / total multi-turn eval turns | macro per turn | chat messages, LLM judge |
| `comment_relevance_score` | Comments relevant to card content | Comments passing relevance judge / total AI comments | full-run macro | card, comment, LLM judge |
| `comment_boundary_safety` | Comments do not over-interpret sensitive content | Comments with no overreach, diagnosis, or financial advice / sensitive-scenario comments | micro | LLM safety judge |
| `comment_not_fact_leakage_absence` | Retrieval/answers do not treat AI comments as user facts | Answers not citing comments as facts / QA tasks with comment interference | micro | source type, answer citations |
| `character_routing_accuracy` | @mention/character selection correct | Comments/replies hitting target character / total character-routed cases | micro | comment character_id |

### 2.8 Schedule and System Action Metrics

| Metric | Definition | Formula | Aggregation | Collection Method |
| --- | --- | --- | --- | --- |
| `schedule_refresh_action_accuracy` | skip/dirty/refresh decision correct | Tasks where predicted action == expected / total schedule tasks | micro | router output, tool trace |
| `schedule_refresh_missed_absence` | Required refresh not missed | Cases with refresh expected and refresh triggered / total refresh expected cases | micro | schedule router/aggregator tasks |
| `schedule_refresh_unnecessary_absence` | No refresh when not needed | Cases with skip expected and no refresh / total skip expected cases | micro | tasks, tool calls |
| `schedule_refresh_duplicate_rate` | Same change not refreshed repeatedly | Duplicate refresh calls / total refresh calls | micro | tasks by bizId/factId |
| `schedule_time_parse_accuracy` | Schedule time correct | Events with start/end/reminder within tolerance / events with gold time | micro | schedule state, system action payload |
| `schedule_update_cancel_accuracy` | Update/cancel targets correct old schedule | Correct update/cancel cases / total update/cancel cases | micro | schedule state before/after |
| `system_action_creation_accuracy` | reminder/calendar actions created correctly | Correct action payloads / total action expected cases | micro | `system_actions` table |
| `action_extraction_precision` | Created actions truly from explicit user intent | Correct action payloads / total observed system actions | micro | System Actions, gold action labels |
| `action_extraction_recall` | Required or suggested actions not missed | Hit gold actions / total gold actions | micro | gold labels, System Actions, card fields |
| `due_time_exact_match` | Todo/schedule time parsing exact match | Actions with start/due/reminder within tolerance / actions with gold time | micro | action payload, schedule state |
| `unconfirmed_action_creation_absence` | Actions requiring confirmation not silently executed | Actions requiring confirmation not silently executed / gold actions requiring user confirmation | micro | System Actions status, side-effect trace |
| `system_action_user_choice_respect` | Rejected actions not nagged again | Cases with no repeat same action after rejection / total rejected actions | micro | system_actions timeline |
| `schedule_aggregation_settlement_rate` | Aggregation tasks complete within budget | Completed schedule_aggregator_task / total schedule aggregation tasks | micro | `tasks` table |

### 2.9 Knowledge Insight Metrics

| Metric | Definition | Formula | Aggregation | Collection Method |
| --- | --- | --- | --- | --- |
| `insight_generation_success_rate` | Refresh produces or updates insight | Refreshes with new/updated insight / total insight refresh operations | micro | KnowledgeInsights files, tasks |
| `insight_parse_valid_rate` | Insight files parseable | Insights parse success and fields valid / total insight files | micro | KnowledgeInsights parser |
| `insight_grounding_rate` | Insights supported by facts/PKM | Insights passing grounded judge / total insights | full-run macro | source snippets, LLM judge |
| `insight_novelty_score` | Insights not duplicate old content | Insights passing novelty judge / total insights | full-run macro | old/new insight diff, LLM judge |
| `insight_actionability_score` | Insights have clear conclusions or actionable suggestions | Insights passing actionability judge / total insights | full-run macro | LLM judge |
| `duplicate_insight_rate` | Duplicate insight proportion | Duplicate insights / total insights | micro | embedding/LLM duplicate judge |
| `insight_refresh_idempotence` | Refresh with no new data does not corrupt existing content | No-op or minor-update refreshes / no-new-data refreshes | micro | before/after diff |
| `insight_source_coverage` | Insight citations cover key sources | Cited gold sources / gold sources required by insight | macro per insight + micro | insight citations, source labels |

### 2.10 Agent Trajectory, Tools, and Rule Compliance Metrics

| Metric | Definition | Formula | Aggregation | Collection Method |
| --- | --- | --- | --- | --- |
| `end_to_end_task_success_rate` | Agent full pipeline final state meets task goal | Cases where final artifacts and state satisfy expected outcome / total cases | pass@1, full-run | final artifacts, DB state, expected outcome |
| `final_state_match_rate` | Final state matches pre-labeled target state | Cases with state diff fully or rule-equivalent / cases with target state | micro | Cards, Memory, PKM, System Actions, expected state |
| `trajectory_rule_compliance` | Intermediate trajectory obeys task rules and tool permissions | Tasks with no prohibited action, no unauthorized write, no rule violation / total tasks | micro, by agent | tool transcript, policy labels |
| `trajectory_efficiency_score` | Trajectory not overly verbose when goal achieved | Successful tasks with turns/tools/peek all within budget / successful tasks | macro per task, by agent | trace, budget config |
| `tool_selection_accuracy` | Expected tool selected | Tasks where expected tool called / total tool tasks | macro per task, by agent | trace tool_calls |
| `tool_args_accuracy` | Tool arguments correct | Calls with matching param fields and values / total expected tool calls | micro, by tool | tool args |
| `tool_call_failure_rate` | Tool call failure proportion | Tool calls with isError or result failed / total tool calls | micro, by tool and agent | tool transcript, agent activity response |
| `tool_call_retry_rate` | Retry proportion after same tool+args failure | Retry tool calls / failed tool calls | micro, by tool | tool transcript |
| `repeated_tool_call_rate` | Repeated tool calls with no new information | Same tool+args repeated calls / total tool calls | micro, by agent | normalized tool args |
| `read_tool_error_rate` | Read-only tool failure rate | Failed read-only tool calls / total read-only tool calls | micro, by tool | tool transcript |
| `write_tool_error_rate` | Write tool failure rate | Failed write tool calls / total write tool calls | micro, by tool | tool transcript |
| `context_peek_count_per_task` | Agent read-only context read count | Read/Grep/Glob/LS/BatchRead/search/retrieval calls / agent tasks | mean/p50/p95, by agent | tool transcript, agent activity |
| `context_peek_redundancy_rate` | "Peeks" unused or repeated reads | Repeated path/query or peeks not entering final citation/write basis / total context peek calls | micro, by agent | tool transcript, citations/source ids |
| `first_write_after_read_rate` | At least necessary context read before write | Write tasks with relevant read/peek before write tool / total write tasks | micro, by agent | tool transcript order |
| `agent_finalization_rate` | Agent ends with expected completion tool or signal | Agent tasks with completion evidence / total agent tasks | micro, by agent | completion evidence, task result |
| `agent_empty_response_rate` | Agent returns empty content/tools causing retry or failure | Empty/invalid response turns / total LLM turns | micro, by agent | trace, task error, provider response |
| `agent_turn_budget_violation_rate` | Conversation turns exceed budget | Tasks with turns > max_turns_budget / total agent tasks | micro, by agent | LLM call record, trace |

### 2.11 Agent Stability, Latency, and Cost Metrics

All metrics in this section must output global and by-agent values; for input-level metrics, also output by downstream chain.

| Metric | Definition | Formula | Aggregation | Collection Method |
| --- | --- | --- | --- | --- |
| `input_required_chain_latency_ms` | Latency from input to required Agent chain completion | `last_required_task_completed_at - submit_at` | mean/p50/p95/p99, by chain | tasks by factId, replay wait |
| `input_full_idle_latency_ms` | Latency from input until Agent queue returns to idle | `queue_idle_at - submit_at` | mean/p50/p95/p99 | `LocalTaskExecutor` snapshot |
| `input_timeout_rate` | Input not completed within budget | Timeout or non-converged inputs / total record operations | micro, by chain | replay observation, tasks snapshot |
| `task_completion_status` | No active/failed tasks at observation end | Cases with all completed / total real replay cases | micro | `tasks` table |
| `failed_task_rate` | Task failed proportion | Failed tasks / total tasks | micro, by task type and agent | `tasks.status` |
| `retry_rate` | Task retry proportion | Tasks with retry_count > 0 / total tasks | micro, by task type and agent | `tasks.retry_count` |
| `task_queue_pressure_p95` | Queue pressure long tail | pending+processing+retrying snapshot value | p95 | `TaskActivitySnapshot` |
| `loop_detection_absence` | loopDetection not triggered | Cases/tasks without loopDetection / total cases/tasks | micro, by agent | task error, trace |
| `max_turns_absence` | Maximum turns reached not triggered | Cases/tasks without maxTurns / total cases/tasks | micro, by agent | task error, trace |
| `agent_llm_turns_per_task` | LLM conversation turns per Agent task | ModelMessage/LLM call count / agent tasks | mean/p50/p95/p99, by agent | `_System/llm_calls`, trace |
| `agent_tool_rounds_per_task` | Tool rounds per Agent task | Tool request/response round count / agent tasks | mean/p50/p95/p99, by agent | `agent_activity_messages`, tool transcript |
| `tool_calls_per_input` | Tool calls triggered per input | Tool call count / record operation count | mean/p50/p95/p99, by agent and chain | trace tool calls |
| `tool_call_latency_p95_by_tool` | Tool call latency long tail | Tool latency samples | p95, by tool and agent | standardized tool transcript |
| `tokens_per_input` | Total token consumption per input | Sum of total tokens from all Agent LLM calls for that input / input count | mean/p50/p95/p99, by chain | `_System/llm_calls`, factId/runId |
| `tokens_per_successful_input` | Average token consumption for successful inputs | Sum of total tokens for successful inputs / successful input count | mean, by chain | LLM records + end_to_end success |
| `tokens_by_agent` | Token consumption per Agent | Sum of Agent total tokens / total run inputs; also output sum | mean per input + sum, by agent | `_System/llm_calls` |
| `prompt_tokens_by_agent` | Prompt token consumption per Agent | Sum of Agent prompt tokens / total run inputs; also output sum | mean per input + sum, by agent | `_System/llm_calls` |
| `completion_tokens_by_agent` | Completion token consumption per Agent | Sum of Agent completion tokens / total run inputs; also output sum | mean per input + sum, by agent | `_System/llm_calls` |
| `thought_tokens_by_agent` | Reasoning/thought token consumption per Agent | Sum of Agent thought tokens / total run inputs; also output sum | mean per input + sum, by agent | `_System/llm_calls` |
| `prompt_cache_token_hit_rate` | Provider prompt cache token hit rate | known-semantics cached tokens / known-semantics effective prompt tokens | micro, by provider/model/agent | token usage records |
| `prompt_cache_token_hit_rate_by_agent` | Prompt cache token hit rate per Agent | Agent known-semantics cached tokens / Agent known-semantics effective prompt tokens | micro, by agent | `_System/llm_calls` |
| `agent_response_cache_hit_rate` | responseId/prefix cache reuse proportion | Agent inits returning valid cached responseId / cache lookup count | micro, by agent/model | `AgentCacheHelper` trace |
| `agent_response_cache_miss_reason_mix` | Cache miss reason distribution | missing, invalid, hash mismatch counts / cache miss count | distribution, by agent/model | `AgentCacheHelper` trace |
| `cost_per_input` | Cost per input | Total run cost / record input count | mean + by agent | pricing table, LLM usage |
| `cost_per_successful_input` | Cost per successful input | Sum of cost for successful inputs / successful input count | mean + by chain | pricing table, LLM usage, success labels |

### 2.12 Coverage Quality Metrics

| Metric | Definition | Formula | Aggregation | Collection Method |
| --- | --- | --- | --- | --- |
| `scenario_family_coverage` | Dataset covers content scenarios defined in this document | Covered scenario families / expected scenario families | set coverage | manifest labels |
| `agent_chain_coverage` | Dataset covers main Agent chains | Covered agent chains / expected agent chains | set coverage | manifest, task trace |
| `cross_day_continuity_coverage` | Cross-day review, citation, follow-up action chains | Continuity chains / expected chains | count/coverage | operations/facts labels |
| `relationship_case_coverage` | Cases involving relationships, aliases, reference, relationship changes | Relationship cases / expected relationship quota | count/coverage | dataset labels |
| `long_context_case_coverage` | Cases involving distant facts, long conversation, cross-file recall | Long-context cases / expected long-context quota | count/coverage | dataset labels |
| `correction_operation_coverage` | Corrections, old preference overwrites, revocation samples | Correction samples / expected correction quota | count/coverage | labels |
| `noise_resilience_coverage` | Noise, temporary emotion, uncertain expression samples | Noise samples / expected noise quota | count/coverage | labels |
| `follow_up_query_coverage` | Follow-up query loop after review | Follow-up query tasks / expected quota | count/coverage | operations/eval_tasks |
| `dataset_oracle_consistency` | Expected derivable from ground truth | Consistent audited tasks / total audited tasks | full-run | script checks, LLM judge |
