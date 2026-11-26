# 1149 项原用例审查记录

用例按清理前工作树 `b245780d` 的文件和行号编号。生产文件链接固定在 main 的 `6953a8a8`。查看清理后的测试位置、链路层级与执行状态，请见[现行用例索引](user-test-index.zh.md)。

清理后剩 1125 项。27 个旧名称退出索引，新增 3 个名称，净减少 24 项。旧输入并入参数组合时，原编号下写明承接用例。账号清理和账号切换标注了工作分支修复。

| 如何查 | 原编号 |
|---|---|
| 六条源码检查怎样变成一次冷启动测试 | [#694–699](#case-694) |
| 通知表与唯一索引怎样覆盖生产库 | [#634–638](#case-634) |
| 记录、照片、评论、搜索与删除账号跑到了哪一层 | [#216–217](#case-216)、[#690–693](#case-690) |
| 为何去掉重复的卡片保存与代理委派 | [#78](#case-78)、[#147](#case-147) |
| 哪个首页性能用例只验证了夹具 | [#903](#case-903) |

每行给出原用例所保护的场景、对应生产文件、原断言中的可观察结果节选以及相关用例。断言过长处用省略号缩写。同一参数化声明的不同输入分别计数。相关项按作用对象、调用和断言筛选；原断言与候选匹配由静态分析提取。保留相关用例时区分输入、异常、时序和观测位置。未找到可替代项时保留原用例。工具链和原生桥接独立列出。

**反向验证。** 在独立副本中撤掉通知的唯一约束，重复插入成功，[#637](#case-637) 对应的新测试立即报错。将聊天改成只等核心初始化，延迟任务仍被阻塞时聊天已返回，[#697](#case-697) 对应的新测试报错。两项在正常实现下均通过。其余用例的回归价值根据执行入口、输入条件和断言判断。

<details>
<summary>.github/scripts/test_generate_star_history.py · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1'></a>1 · L17 | test_fetches_anonymous_star_timestamps_with_graphql_pagination | [generate_star_history][m1] | `self.assertEqual(dates, [dt.date(2025, 1, 1), dt.date(2025, 2, 1)])`；`self.assertNotIn('login', request_body)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-2'></a>2 · L45 | test_cumulative_points_groups_stars_by_date | [generate_star_history][m1] | `self.assertEqual(GENERATOR.cumulative_points(dates), [(dt.date(2025, 1, 1), 2), (dt.date(2025, 2, 1), 3)])` | 保留 · 未找到同一行为的替代项 |
| <a id='case-3'></a>3 · L57 | test_svg_is_deterministic_and_contains_summary | [generate_star_history][m1] | `self.assertEqual(first, second)`；`self.assertEqual(element_tree.fromstring(first).tag, '{http://www.w3.org/2000/svg}svg')` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>ios/RunnerTests/RunnerTests.swift · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-4'></a>4 · L10 | testPickerScrollCannotDismissASheet | [PhotoPickerChannelHandler][m2] | `XCTAssertEqual(picker.modalPresentationStyle, .fullScreen)`；`XCTAssertEqual(picker.configuration.preferredAssetRepresentationMode, .current)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-5'></a>5 · L19 | testGestureDismissalCompletesOnceAndNextPickerCanFinish | [PhotoPickerChannelHandler][m2] | `XCTAssertEqual((value as? [[String: Any]])?.count, 0)`；`XCTAssertEqual(secondResults, 1)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/agent/agent_system_prompt_helper_test.dart · 5 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-6'></a>6 · L7 | applyPromptConfig keeps messages and tools unchanged when config is empty | [agent_system_prompt_helper][m3] | `expect(result.tools.single, same(tool))`；`expect(result.requestMessages.single, same(requestMessages.single))` | 保留 · [#9](#case-9) returns AgentPromptHookResult and preserves tool parameter mode |
| <a id='case-7'></a>7 · L29 | applyPromptConfig system override takes precedence over replacements | [agent_system_prompt_helper][m3] | `expect(result.systemMessage?.content, 'override content')` | 保留 · [#8](#case-8) applies multiple system prompt replacements in order |
| <a id='case-8'></a>8 · L44 | applyPromptConfig applies multiple system prompt replacements in order | [agent_system_prompt_helper][m3] | `expect(result.systemMessage?.content, 'third prompt')` | 保留 · [#7](#case-7) system override takes precedence over replacements |
| <a id='case-9'></a>9 · L59 | applyPromptConfig returns AgentPromptHookResult and preserves tool parameter mode | [agent_system_prompt_helper][m3] | `expect(result, isA<AgentPromptHookResult>())`；`expect(result.tools.single.parameterMode, ToolParameterMode.object)` | 保留 · [#6](#case-6) keeps messages and tools unchanged when config is empty |
| <a id='case-10'></a>10 · L100 | applyPromptConfig only overrides matching tools | [agent_system_prompt_helper][m3] | `expect(result.tools.first.description, 'Target description')`；`expect(result.tools.last, same(other))` | 保留 · [#6](#case-6) keeps messages and tools unchanged when config is empty |

</details>

<details>
<summary>test/agent/agent_tool_error_result_test.dart · 16 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-11'></a>11 · L47 | agent tool error results save_timeline_card with a non-existent fact_id is a tool error | [timeline_card_skill][m4] | `expect(result.isError, isTrue)`；`expect(_text(result), contains('Error executing save_timeline_card'))` | 保留 · [#78](#case-78) mint_record_fact_id + status-driven new-card det…ng first is a tool error |
| <a id='case-12'></a>12 · L78 | agent tool error results save_timeline_card address schema excludes future destinations | [timeline_card_skill][m4] | `expect(description, contains('future destinations'))`；`expect(description, contains('omit address'))` | 保留 · [#22](#case-22) rejects malformed JSON list strings |
| <a id='case-13'></a>13 · L96 | agent tool error results save_timeline_card accepts JSON-encoded list arguments | [timeline_card_skill][m4] | `expect(card?.title, 'Memex project notes')`；`expect(card?.tags, ['Project', 'Emotion'])` | 保留 · [#14](#case-14) still accepts native list arguments |
| <a id='case-14'></a>14 · L138 | agent tool error results save_timeline_card still accepts native list arguments | [timeline_card_skill][m4] | `expect(card?.uiConfigs.single.templateId, 'article')`；`expect(card?.tags, ['Knowledge'])` | 保留 · [#13](#case-13) accepts JSON-encoded list arguments |
| <a id='case-15'></a>15 · L175 | agent tool error results save_timeline_card rejects non-canonical local media refs | [timeline_card_skill][m4] | `expect(result.isError, isTrue)`；`expect(_text(result), contains('bare ′fs://filename.ext′'))` | 保留 · [#18](#case-18) non-bare asset refs |
| <a id='case-16'></a>16 · L209 | agent tool error results save_timeline_card rejects missing local media refs | [timeline_card_skill][m4] | `expect(result.isError, isTrue)`；`expect(_text(result), contains('missing_photo.jpg'))` | 保留 · [#15](#case-15) non-canonical local media refs |
| <a id='case-17'></a>17 · L240 | agent tool error results save_timeline_card does not infer media type from url field names | [timeline_card_skill][m4] | `expect(result.isError, isFalse)` | 保留 · [#16](#case-16) rejects missing local media refs |
| <a id='case-18'></a>18 · L275 | agent tool error results save_timeline_card rejects non-bare asset refs | [timeline_card_skill][m4] | `expect(result.isError, isTrue)`；`expect(_text(result), contains('bare ′fs://filename.ext′'))` | 保留 · [#15](#case-15) non-canonical local media refs |
| <a id='case-19'></a>19 · L305 | agent tool error results save_timeline_card validates custom template url fields | [timeline_card_skill][m4] | `expect(result.isError, isTrue)`；`expect(_text(result), contains('cover_url'))` | 保留 · [#20](#case-20) accepts saved custom HTML templates |
| <a id='case-20'></a>20 · L362 | agent tool error results save_timeline_card accepts saved custom HTML templates | [timeline_card_skill][m4] | `expect(card?.uiConfigs.single.templateId, 'focus_dashboard')`；`expect(card?.uiConfigs.single.data['summary'], 'Deep work summary.')` | 保留 · [#19](#case-19) validates custom template url fields |
| <a id='case-21'></a>21 · L424 | agent tool error results get_card_metadata lists native and custom templates together | [timeline_card_skill][m4] | `expect(metadata, contains('# Available Templates'))`；`expect(metadata, isNot(contains('# Custom HTML Templates')))` | 保留 · [#20](#case-20) save_timeline_card accepts saved custom HTML templates |
| <a id='case-22'></a>22 · L465 | agent tool error results save_timeline_card rejects malformed JSON list strings | [timeline_card_skill][m4] | `expect(_text(result), contains('ui_configs must be valid JSON'))` | 保留 · [#23](#case-23) JSON strings that are not arrays |
| <a id='case-23'></a>23 · L487 | agent tool error results save_timeline_card rejects JSON strings that are not arrays | [timeline_card_skill][m4] | `expect(result.isError, isTrue)` | 保留 · [#22](#case-22) malformed JSON list strings |
| <a id='case-24'></a>24 · L513 | agent tool error results SaveComment invalid input is marked as a tool error | [comment_tools][m5] | `expect(_text(result), contains('Error executing SaveComment'))`；`expect(_text(result), contains('Comment content cannot be empty'))` | 保留 · [#26](#case-26) search_workspace_event_logs failures are marked as tool errors |
| <a id='case-25'></a>25 · L533 | agent tool error results MemoryRead without a default character is marked as a tool error | [memory_tools][m6] | `expect(_text(result), contains('Error executing MemoryRead'))`；`expect(_text(result), contains('No default character set'))` | 保留 · [#26](#case-26) search_workspace_event_logs failures are marked as tool errors |
| <a id='case-26'></a>26 · L548 | agent tool error results search_workspace_event_logs failures are marked as tool errors | [search_event_logs_tool][m7] | `expect(_text(result), contains('Error executing search_workspace_event_logs'))` | 保留 · [#24](#case-24) SaveComment invalid input is marked as a tool error |

</details>

<details>
<summary>test/agent/built_in_tools/search_event_logs_tool_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-27'></a>27 · L6 | renderEventLogSearchResultsForAgent uses stored local time and unix seconds when available | [search_event_logs_tool][m7] | `expect(output, contains('Local Time: 2026-04-28 20:00:46 +08:00 (CST)'))`；`expect(output, contains('Unix Seconds: 1777387246'))` | 保留 · [#28](#case-28) falls back to raw event_time for legacy events |
| <a id='case-28'></a>28 · L28 | renderEventLogSearchResultsForAgent falls back to raw event_time for legacy events | [search_event_logs_tool][m7] | `expect(output, contains('Raw Time: 2026-04-28T20:00:46.000'))` | 保留 · [#29](#case-29) keeps rendering useful output when legacy time is malformed |
| <a id='case-29'></a>29 · L45 | renderEventLogSearchResultsForAgent keeps rendering useful output when legacy time is malformed | [search_event_logs_tool][m7] | `expect(output, contains('Local Time: Unknown'))`；`expect(output, contains('Malformed timestamp event'))` | 保留 · [#28](#case-28) falls back to raw event_time for legacy events |
| <a id='case-30'></a>30 · L63 | renderEventLogSearchResultsForAgent includes pagination hint only when the page is full | [search_event_logs_tool][m7] | `expect(fullPageOutput, contains('offset=6'))`；`expect(partialPageOutput, isNot(contains('offset=')))` | 保留 · [#28](#case-28) falls back to raw event_time for legacy events |

</details>

<details>
<summary>test/agent/character_agent_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-31'></a>31 · L19 | CharacterAgent transforms and finishes one observation | [character_agent][m8] | `expect(await workspaceService.loadPendingObservations(userId, character.id), isEmpty)`；`expect(client.calledTools, ['AppendJournal', 'Remember', 'FinishObservation'])` | 保留 · 未找到同一行为的替代项 |
| <a id='case-32'></a>32 · L102 | CharacterAgent selects one proactive action from its own memory | [character_agent][m8] | `expect(decision.action, CharacterInitiativeAction.speak)`；`expect(client.lastPrompt, contains('origin'))` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/agent/character_conversation_skill_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-33'></a>33 · L17 | conversation skill treats several bubbles as one agent decision | [character_conversation_skill][m9] | `expect(skill.tools!.map((tool) => tool.name), containsAll(['Glob', 'Grep', 'Read', 'Remember']))`；`expect(skill.systemPrompt, contains('several bubbles'))` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/agent/character_history_acquaintance_skill_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-34'></a>34 · L17 | requires a real history visit before completing acquaintance | [character_history_acquaintance_skill][m10] | `expect(await workspace.isHistoryAcquaintanceComplete('user-1', 'yaoyao'), isTrue)`；`expect(skill.systemPrompt, contains('subjective and selective'))` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/agent/character_initiative_skill_test.dart · 7 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-35'></a>35 · L36 | offers memory retrieval and two continuous initiative choices | [character_initiative_skill][m11] | `expect(names, containsAll(['Glob', 'Grep', 'Read', 'Remember']))`；`expect(skill.systemPrompt, contains('There is no system push'))` | 保留 · 未找到同一行为的替代项 |
| <a id='case-36'></a>36 · L63 | keeps future reflection available without a fixed retry count | [character_initiative_skill][m11] | `expect(skill.tools!.map((tool) => tool.name), contains('SleepUntil'))`；`expect(skill.systemPrompt, contains('not a permanent shutdown'))` | 保留 · [#40](#case-40) SleepUntil stays quiet now without ending future initiative |
| <a id='case-37'></a>37 · L83 | Speak includes the character-selected next wake | [character_initiative_skill][m11] | `expect(tool.parameters['required'], ['next_wake_at', 'next_wake_reason'])`；`expect(decision?.action, CharacterInitiativeAction.speak)` | 保留 · [#39](#case-39) can send a Fluent emoji without a text bubble |
| <a id='case-38'></a>38 · L127 | Speak downgrades a legacy textual emoji placeholder to text | [character_initiative_skill][m11] | `expect(decision?.messages, [CharacterOutgoingMessage.text('[smile]')])` | 保留 · [#39](#case-39) can send a Fluent emoji without a text bubble |
| <a id='case-39'></a>39 · L159 | Speak can send a Fluent emoji without a text bubble | [character_initiative_skill][m11] | `expect(decision?.messages, [CharacterOutgoingMessage.emoji('👋')])` | 保留 · [#38](#case-38) downgrades a legacy textual emoji placeholder to text |
| <a id='case-40'></a>40 · L187 | SleepUntil stays quiet now without ending future initiative | [character_initiative_skill][m11] | `expect(decision?.action, CharacterInitiativeAction.sleepUntil)`；`expect(decision?.wakeAt, now.add(const Duration(days: 1)))` | 保留 · [#37](#case-37) Speak includes the character-selected next wake |
| <a id='case-41'></a>41 · L212 | can deliberately resolve an obsolete pending thought | [character_initiative_skill][m11] | `expect(skill.tools!.map((tool) => tool.name), contains('ResolvePendingThought'))` | 保留 · [#39](#case-39) Speak can send a Fluent emoji without a text bubble |

</details>

<details>
<summary>test/agent/character_perception_skill_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-42'></a>42 · L50 | CharacterPerceptionSkill exposes private memory tools but no messaging surface | [character_perception_skill][m12] | `expect(skill.systemPrompt, contains('progressively'))`；`expect(skill.systemPrompt, contains('not produce a message for the user'))` | 保留 · [#43](#case-43) generic Read cannot access the raw inbox |
| <a id='case-43'></a>43 · L71 | CharacterPerceptionSkill generic Read cannot access the raw inbox | [character_perception_skill][m12] | `expect(result.isError, isTrue)` | 保留 · [#42](#case-42) exposes private memory tools but no messaging surface |

</details>

<details>
<summary>test/agent/character_scene_memory_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-44'></a>44 · L37 | comments use the same character workspace and scene action tools | [comment_agent_skill][m13] | `expect(skill.systemPrompt, contains('Your workspace is your durable'))`；`expect(skill.systemPrompt, isNot(contains('## User Profile')))` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/agent/claude_prompt_caching_test.dart · 6 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-45'></a>45 · L15 | Claude caching and Memex accounting: https://api.anthropic.com stream=false | [token_usage_utils][m14] | `expect(requests.single, isNot(contains('cache_control')))`；`expect(TokenUsageUtils.resolveFromUsageRecord({'cache_tokens_included_in_prompt'…_usage' : usage.originalUsage}), isTrue)` | 保留参数轴。三个服务端点分别覆盖流式与非流式响应，并校验缓存用量。 · [#46](#case-46) stream=true |
| <a id='case-46'></a>46 · L15 | Claude caching and Memex accounting: https://api.anthropic.com stream=true | [token_usage_utils][m14] | `expect(semantics, isTrue)`；`expect(TokenUsageUtils.resolveFromUsageRecord({'cache_tokens_included_in_prompt'…_usage' : usage.originalUsage}), isTrue)` | 保留参数轴。三个服务端点分别覆盖流式与非流式响应，并校验缓存用量。 · [#45](#case-45) stream=false |
| <a id='case-47'></a>47 · L15 | Claude caching and Memex accounting: https://api.minimaxi.com/anthropic stream=false | [token_usage_utils][m14] | `expect(requests.single, isNot(contains('cache_control')))`；`expect(TokenUsageUtils.resolveFromUsageRecord({'cache_tokens_included_in_prompt'…_usage' : usage.originalUsage}), isTrue)` | 保留参数轴。三个服务端点分别覆盖流式与非流式响应，并校验缓存用量。 · [#48](#case-48) stream=true |
| <a id='case-48'></a>48 · L15 | Claude caching and Memex accounting: https://api.minimaxi.com/anthropic stream=true | [token_usage_utils][m14] | `expect(semantics, isTrue)`；`expect(TokenUsageUtils.resolveFromUsageRecord({'cache_tokens_included_in_prompt'…_usage' : usage.originalUsage}), isTrue)` | 保留参数轴。三个服务端点分别覆盖流式与非流式响应，并校验缓存用量。 · [#47](#case-47) stream=false |
| <a id='case-49'></a>49 · L15 | Claude caching and Memex accounting: https://api.xiaomimimo.com/anthropic stream=false | [token_usage_utils][m14] | `expect(requests.single, isNot(contains('cache_control')))`；`expect(TokenUsageUtils.resolveFromUsageRecord({'cache_tokens_included_in_prompt'…_usage' : usage.originalUsage}), isTrue)` | 保留参数轴。三个服务端点分别覆盖流式与非流式响应，并校验缓存用量。 · [#50](#case-50) stream=true |
| <a id='case-50'></a>50 · L15 | Claude caching and Memex accounting: https://api.xiaomimimo.com/anthropic stream=true | [token_usage_utils][m14] | `expect(semantics, isTrue)`；`expect(TokenUsageUtils.resolveFromUsageRecord({'cache_tokens_included_in_prompt'…_usage' : usage.originalUsage}), isTrue)` | 保留参数轴。三个服务端点分别覆盖流式与非流式响应，并校验缓存用量。 · [#49](#case-49) stream=false |

</details>

<details>
<summary>test/agent/comment_agent_policy_live_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-51'></a>51 · L69 | CommentAgent live comment policy evaluation normal mode skips a trivial purchase record | [comment_agent][m15] | `expect(comments, isEmpty)` | 保留在线验证。默认运行缺服务凭据时跳过。 · [#52](#case-52) replies to an emotionally loaded record |
| <a id='case-52'></a>52 · L99 | CommentAgent live comment policy evaluation normal mode replies to an emotionally loaded record | [comment_agent][m15] | `expect(comments, hasLength(1))` | 保留在线验证。默认运行缺服务凭据时跳过。 · [#53](#case-53) force reply mode replies even when the record is otherwise skippable |
| <a id='case-53'></a>53 · L130 | CommentAgent live comment policy evaluation force reply mode replies even when the record is otherwise skippable | [comment_agent][m15] | `expect(comments, hasLength(1))` | 保留在线验证。默认运行缺服务凭据时跳过。 · [#52](#case-52) normal mode replies to an emotionally loaded record |

</details>

<details>
<summary>test/agent/comment_agent_policy_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-54'></a>54 · L31 | CommentAgent policy routing normal mode exposes SaveComment and SkipComment | [comment_agent_skill][m13] | `expect(toolNames, containsAll(['SaveComment', 'SkipComment']))`；`expect(skill.systemPrompt, contains('Comment Policy'))` | 保留 · [#55](#case-55) force reply mode removes SkipComment and requires SaveComment |
| <a id='case-55'></a>55 · L41 | CommentAgent policy routing force reply mode removes SkipComment and requires SaveComment | [comment_agent_skill][m13] | `expect(toolNames, contains('SaveComment'))`；`expect(skill.systemPrompt, isNot(contains('call ′SkipComment′')))` | 保留 · [#54](#case-54) normal mode exposes SaveComment and SkipComment |
| <a id='case-56'></a>56 · L52 | CommentAgent policy routing counselor default persona includes a comment policy | [comment_agent_skill][m13] | `expect(persona, contains('## Comment Policy'))`；`expect(persona, contains('Skip when:'))` | 保留 · [#54](#case-54) normal mode exposes SaveComment and SkipComment |
| <a id='case-57'></a>57 · L64 | CommentAgent policy routing comment prompt supports policy based skipping in normal mode | [comment_agent_skill][m13] | `expect(prompt, contains('Comment Policy'))`；`expect(prompt, contains('Do not update memory when you call ′SkipComment′'))` | 保留 · [#54](#case-54) normal mode exposes SaveComment and SkipComment |

</details>

<details>
<summary>test/agent/comment_tool_factory_test.dart · 6 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-58'></a>58 · L72 | CommentToolFactory SaveComment reply routing forcedReplyToId pins AI reply to the user comment even when the model supplies the original character comment id | [comment_tools][m5] | `expect(latest.characterId, characterId)`；`expect(latest.replyToId, 'user-comment')` | 保留 · [#59](#case-59) still attaches to the user comment when the mode…leaves reply_to_id empty |
| <a id='case-59'></a>59 · L93 | CommentToolFactory SaveComment reply routing forcedReplyToId still attaches to the user comment when the model leaves reply_to_id empty | [comment_tools][m5] | `expect(latest.replyToId, 'user-comment')` | 保留 · [#62](#case-62) empty reply_to_id is normalized to a top-level comment |
| <a id='case-60'></a>60 · L112 | CommentToolFactory SaveComment reply routing without forcedReplyToId, SaveComment treats a self-reply as top-level | [comment_tools][m5] | `expect(latest.replyToId, isNull)` | 保留。自回复与空目标都是顶层评论，但输入的归一化规则不同。 · [#62](#case-62) empty reply_to_id is normalized to a top-level comment |
| <a id='case-61'></a>61 · L131 | CommentToolFactory SaveComment reply routing without forcedReplyToId, SaveComment preserves a valid model-supplied reply target for character-to-character interactions | [comment_tools][m5] | `expect(latest.replyToId, 'other-char-comment')` | 保留 · [#59](#case-59) forcedReplyToId still attaches to the user comme…leaves reply_to_id empty |
| <a id='case-62'></a>62 · L151 | CommentToolFactory SaveComment reply routing empty reply_to_id is normalized to a top-level comment | [comment_tools][m5] | `expect(latest.replyToId, isNull)` | 保留。自回复与空目标都是顶层评论，但输入的归一化规则不同。 · [#60](#case-60) without forcedReplyToId, SaveComment treats a self-reply as top-level |
| <a id='case-63'></a>63 · L167 | CommentToolFactory SaveComment reply routing SkipComment completes without writing a visible comment | [comment_tools][m5] | `expect(cardAfter!.comments.length, cardBefore!.comments.length)`；`expect(cardAfter.comments.map((c) => c.content), isNot(contains('Outside this character comment policy.')))` | 保留 · [#62](#case-62) empty reply_to_id is normalized to a top-level comment |

</details>

<details>
<summary>test/agent/file_tool_view_image_test.dart · 5 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-64'></a>64 · L29 | view_image tool inlines image and queues it for model-visible messages | [pending_tool_image_buffer][m16] | `expect(tool.description, isNot(contains('next model call only')))`；`expect(tool.description, startsWith('View a local image file.'))` | 保留 · [#65](#case-65) does not require file permission manager read access |
| <a id='case-65'></a>65 · L84 | view_image tool does not require file permission manager read access | [file_permission_manager][m17] | `expect(_text(result), contains('Image attached to the next message'))`；`expect(pending.single.image.base64Data, base64Encode(imageBytes))` | 保留 · [#64](#case-64) inlines image and queues it for model-visible messages |
| <a id='case-66'></a>66 · L122 | view_image tool after-tool hook persists viewed image into agent history | [pending_tool_image_buffer][m16] | `expect(imageMessages, hasLength(1))`；`expect(PendingToolImageBuffer.instance.drain(state.sessionId), isEmpty)` | 保留 · [#65](#case-65) does not require file permission manager read access |
| <a id='case-67'></a>67 · L208 | BatchRead tool uses workspace paths in file headers for direct reads | [file_tools][m18] | `expect(output, contains('File: /PKM/Resources/finance/summary.md'))`；`expect(output, contains('balance notes'))` | 保留 · [#68](#case-68) glob reads |
| <a id='case-68'></a>68 · L225 | BatchRead tool uses workspace paths in file headers for glob reads | [file_tools][m18] | `expect(output, contains('File: /PKM/Projects/aurora/plan.md'))`；`expect(output, contains('project plan'))` | 保留 · [#67](#case-67) direct reads |

</details>

<details>
<summary>test/agent/knowledge_insight_prompt_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-69'></a>69 · L9 | Knowledge insight language prompts skill prompt interpolates the configured language instruction | [prompts][m19] | `expect(prompt, isNot(contains(r'$instruction')))` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/agent/knowledge_insight_skill_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-70'></a>70 · L46 | KnowledgeInsightSkill saving insight cards creates and publishes timeline summary card | [knowledge_insight_skill][m20] | `expect(message.uiConfigs.single.templateId, 'insight_summary')`；`expect(summaryCard?.uiConfigs.single.templateId, 'insight_summary')` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/agent/memory/super_agent_context_compressor_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-71'></a>71 · L7 | SuperAgentContextCompressor.stripArchivedImageBytes replaces archived image parts with fs path placeholders | [super_agent_context_compressor][m21] | `expect(texts[1], contains('fs://a.png'))`；`expect(texts[2], contains('fs://b.jpg'))` | 保留 · [#72](#case-72) handles missing path metadata and is idempotent |
| <a id='case-72'></a>72 · L42 | SuperAgentContextCompressor.stripArchivedImageBytes handles missing path metadata and is idempotent | [super_agent_context_compressor][m21] | `expect((user.contents.single as TextPart).text, '[archived image attachment]')` | 保留 · [#71](#case-71) replaces archived image parts with fs path placeholders |

</details>

<details>
<summary>test/agent/mint_and_save_fact_id_test.dart · 10 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-73'></a>73 · L51 | mint_record_fact_id + status-driven new-card detection mint tool does not accept a content creation date | [common_tools][m22] | `expect(mintRecordFactIdTool.parameters['properties'], isNot(contains('content_creation_date')))` | 保留 · [#78](#case-78) save without minting first is a tool error |
| <a id='case-74'></a>74 · L58 | mint_record_fact_id + status-driven new-card detection mint reserves a processing placeholder card | [common_tools][m22] | `expect(_text(mintResult), factId)`；`expect(card!.status, 'processing')` | 保留 · [#75](#case-75) can reserve multiple processing placeholder cards |
| <a id='case-75'></a>75 · L80 | mint_record_fact_id + status-driven new-card detection mint can reserve multiple processing placeholder cards | [common_tools][m22] | `expect(_artifactIds(mintResult), factIds)`；`expect(card!.status, 'processing')` | 保留 · [#74](#case-74) reserves a processing placeholder card |
| <a id='case-76'></a>76 · L102 | mint_record_fact_id + status-driven new-card detection mint then save completes the card and enqueues memory once | [timeline_card_skill][m4] | `expect(_text(saveResult), isNot(contains('fact_id')))`；`expect(_text(saveResult), isNot(contains(factId)))` | 保留 · [#77](#case-77) re-saving a completed card is an edit and does not re-enqueue |
| <a id='case-77'></a>77 · L145 | mint_record_fact_id + status-driven new-card detection re-saving a completed card is an edit and does not re-enqueue | [timeline_card_skill][m4] | `expect(card!.title, 'Edited title')`；`expect(await _pendingMemoryFactIds(userId), [factId])` | 保留 · [#76](#case-76) mint then save completes the card and enqueues memory once |
| <a id='case-78'></a>78 · L189 | mint_record_fact_id + status-driven new-card detection save without minting first is a tool error | [timeline_card_skill][m4] | `expect(result.isError, isTrue)` | 删除。与 [#11](#case-11) 均保存未创建的 ID，[#11](#case-11) 还检查错误包含工具名和请求 ID。 · [#11](#case-11) agent tool error results save_timeline_card with… fact_id is a tool error |
| <a id='case-79'></a>79 · L209 | mint_record_fact_id + status-driven new-card detection editing with only fact preserves the existing assets and title | [timeline_card_skill][m4] | `expect(card!.fact, 'Spicy peppers, fried fish, and cucumber soup for dinner.')`；`expect(card.uiConfigs.single.templateId, 'snapshot')` | 保留 · [#80](#case-80) save accepts bare fs asset refs and stores renderable markdown refs |
| <a id='case-80'></a>80 · L265 | mint_record_fact_id + status-driven new-card detection save accepts bare fs asset refs and stores renderable markdown refs | [timeline_card_skill][m4] | `expect(card!.assets, ['![image](fs://bare_photo.jpg)'])` | 保留 · [#82](#case-82) a fact containing an fs:// reference is rejected |
| <a id='case-81'></a>81 · L303 | mint_record_fact_id + status-driven new-card detection card cache timeline ordering uses record creation time for new cards | [timeline_card_skill][m4] | `expect(card!.timestamp, DateTime.parse('2000-01-01T00:00:00').millisecondsSinceEpoch ~/ 1000)`；`expect(cachedCard.timestamp, createdAt)` | 保留 · [#73](#case-73) mint tool does not accept a content creation date |
| <a id='case-82'></a>82 · L343 | mint_record_fact_id + status-driven new-card detection a fact containing an fs:// reference is rejected | [timeline_card_skill][m4] | `expect(_text(result), contains('fs://'))`；`expect(await FileSystemService.instance.readCardFile(userId, factId), isNull)` | 保留 · [#78](#case-78) save without minting first is a tool error |

</details>

<details>
<summary>test/agent/openai_client_image_history_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-83'></a>83 · L8 | StatefulAgent keeps previous-turn ImagePart in the second request | [pubspec][m23] | `expect(previousUser.contents.whereType<ImagePart>(), hasLength(1))`；`expect(previousUser.contents.whereType<ImagePart>().single.base64Data, imageBase64)` | 保留。覆盖 main 锁定的 dart_agent_core SDK，分别检查历史消息和发往 HTTP 的载荷。 · [#84](#case-84) OpenAIClient sends historical ImagePart as image_url |
| <a id='case-84'></a>84 · L43 | OpenAIClient sends historical ImagePart as image_url | [pubspec][m23] | `expect(content, contains(predicate<Map>((part) {final imageUrl = part['image_url…data:image/png;base64,$imageBase64';})))` | 保留。覆盖 main 锁定的 dart_agent_core SDK，分别检查历史消息和发往 HTTP 的载荷。 · [#83](#case-83) StatefulAgent keeps previous-turn ImagePart in the second request |

</details>

<details>
<summary>test/agent/run_mode/agent_action_approval_service_test.dart · 6 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-85'></a>85 · L9 | AgentRunMode fromWire parses wire names and falls back to auto | [agent_action_approval_service][m24] | `expect(AgentRunMode.fromWire('auto'), AgentRunMode.auto)`；`expect(AgentRunMode.fromWire(null), AgentRunMode.auto)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-86'></a>86 · L19 | AgentActionApprovalService auto-denies when no UI is attached to the session | [agent_action_approval_service][m24] | `expect(approved, isFalse)` | 保留 · [#88](#case-88) resolves denial when UI denies |
| <a id='case-87'></a>87 · L28 | AgentActionApprovalService resolves approval when UI approves | [agent_action_approval_service][m24] | `expect(requests, hasLength(1))`；`expect(service.pendingForSession('session-a'), isEmpty)` | 保留 · [#88](#case-88) denial when UI denies |
| <a id='case-88'></a>88 · L51 | AgentActionApprovalService resolves denial when UI denies | [agent_action_approval_service][m24] | `expect(await future, isFalse)` | 保留 · [#87](#case-87) approval when UI approves |
| <a id='case-89'></a>89 · L70 | AgentActionApprovalService detachSession denies everything still pending | [agent_action_approval_service][m24] | `expect(service.pendingForSession('session-c'), hasLength(1))`；`expect(service.pendingForSession('session-c'), isEmpty)` | 保留 · [#88](#case-88) resolves denial when UI denies |
| <a id='case-90'></a>90 · L86 | AgentActionApprovalService resolve is idempotent for unknown ids | [agent_action_approval_service][m24] | `expect(() => service.resolve('does-not-exist', approved: true), returnsNormally)` | 保留 · [#88](#case-88) resolves denial when UI denies |

</details>

<details>
<summary>test/agent/security/file_permission_manager_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-91'></a>91 · L22 | FilePermissionManager.buildSearchAccessScope exports denied subtrees as directory-search exclusions | [file_permission_manager][m17] | `expect(scope.canUseDirectorySearch, isTrue)`；`expect(scope.allowsRead(deniedPath), isFalse)` | 保留 · [#92](#case-92) disables directory search when denied subtree has readable override |
| <a id='case-92'></a>92 · L47 | FilePermissionManager.buildSearchAccessScope disables directory search when denied subtree has readable override | [file_permission_manager][m17] | `expect(scope.canUseDirectorySearch, isFalse)`；`expect(scope.allowsRead(readableOverride), isTrue)` | 保留 · [#91](#case-91) exports denied subtrees as directory-search exclusions |
| <a id='case-93'></a>93 · L77 | FilePermissionManager.buildSearchAccessScope ignores denied rules outside the requested search root | [file_permission_manager][m17] | `expect(scope.canUseDirectorySearch, isTrue)` | 保留 · [#91](#case-91) exports denied subtrees as directory-search exclusions |

</details>

<details>
<summary>test/agent/skills/dynamic_timeline_ui_skill_test.dart · 12 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-94'></a>94 · L33 | DynamicTimelineUiSkill registers expected tool names | [dynamic_timeline_ui_skill][m25] | `expect(skill.tools?.map((tool) => tool.name), isNot(contains('create_dynamic_timeline_card')))`；`expect(skill.tools?.map((tool) => tool.name), isNot(contains('update_dynamic_timeline_card')))` | 保留 · [#100](#case-100) preview can target a saved template id |
| <a id='case-95'></a>95 · L64 | DynamicTimelineUiSkill strips markdown html code fences | [dynamic_timeline_ui_skill][m25] | `expect(html, '<section><h1>Focus Review</h1></section>')` | 保留 · [#96](#case-96) rejects executable html |
| <a id='case-96'></a>96 · L74 | DynamicTimelineUiSkill rejects executable html | [dynamic_timeline_ui_skill][m25] | `expect(() => DynamicTimelineUiSkill.sanitizeHtmlForTimeline('<script>alert(1)</script>'), throwsArgumentError)` | 保留 · [#95](#case-95) strips markdown html code fences |
| <a id='case-97'></a>97 · L89 | DynamicTimelineUiSkill recommends visual memory pattern for image-heavy intent | [dynamic_timeline_ui_skill][m25] | `expect(matches.first.pattern.id, 'visual_memory_editorial')` | 保留 · [#98](#case-98) pattern examples are accepted by timeline html sanitizer |
| <a id='case-98'></a>98 · L99 | DynamicTimelineUiSkill pattern examples are accepted by timeline html sanitizer | [dynamic_timeline_ui_skill][m25] | `expect(DynamicTimelineUiSkill.sanitizeHtmlForTimeline(pattern.htmlExample), contains('memex-card'))` | 保留 · [#96](#case-96) rejects executable html |
| <a id='case-99'></a>99 · L108 | DynamicTimelineUiSkill save_timeline_template requires view.html to exist | [dynamic_timeline_ui_skill][m25] | `expect(_text(result), contains('Template HTML is required before saving metadata.'))` | 保留 · [#100](#case-100) preview can target a saved template id |
| <a id='case-100'></a>100 · L138 | DynamicTimelineUiSkill preview can target a saved template id | [dynamic_timeline_ui_skill][m25] | `expect(_text(result), contains('Template "missing_template"'))` | 保留 · [#101](#case-101) an existing template id |
| <a id='case-101'></a>101 · L154 | DynamicTimelineUiSkill preview can target an existing template id | [dynamic_timeline_ui_skill][m25] | `expect(_text(result), contains('current Timeline card style'))` | 保留 · [#100](#case-100) a saved template id |
| <a id='case-102'></a>102 · L170 | DynamicTimelineUiSkill preview fills HTML placeholders with data before rendering | [dynamic_timeline_ui_skill][m25] | `expect(_text(result), contains('<script'))` | 保留 · [#100](#case-100) can target a saved template id |
| <a id='case-103'></a>103 · L190 | DynamicTimelineUiSkill saves timeline template metadata for existing HTML | [dynamic_timeline_ui_skill][m25] | `expect(_text(result), contains('Timeline HTML template'))`；`expect(html, contains('{{title}}'))` | 保留 · [#105](#case-105) adds current state reminder when replacing existing template data |
| <a id='case-104'></a>104 · L261 | DynamicTimelineUiSkill adds current state reminder when overwriting template field schema | [dynamic_timeline_ui_skill][m25] | `expect(_text(result), isNot(contains(factId)))`；`expect(currentState.systemReminders['timeline_template_schema_changed_focus_dashboard'], contains(factId))` | 保留 · [#105](#case-105) replacing existing template data |
| <a id='case-105'></a>105 · L348 | DynamicTimelineUiSkill adds current state reminder when replacing existing template data | [dynamic_timeline_ui_skill][m25] | `expect(reminder, contains(factId))`；`expect(reminder, contains('Existing cards using this template may need'))` | 保留 · [#104](#case-104) overwriting template field schema |

</details>

<details>
<summary>test/agent/skills/manage_system_action/system_action_skill_test.dart · 5 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-106'></a>106 · L29 | prepares a pending calendar event instead of writing to the device | [system_action_skill][m26] | `expect(action.actionType, 'calendar')`；`expect(action.status, 'pending')` | 保留 · [#107](#case-107) reminder with an explicit due date |
| <a id='case-107'></a>107 · L73 | prepares a reminder with an explicit due date | [system_action_skill][m26] | `expect(action.actionType, 'reminder')`；`expect(DateTime.parse(data['due_date']), DateTime(2026, 8, 2, 9))` | 保留 · [#106](#case-106) pending calendar event instead of writing to the device |
| <a id='case-108'></a>108 · L98 | rejects reminders without a due date | [system_action_skill][m26] | `expect(await SystemActionService.instance.getPending(), isEmpty)` | 保留 · [#109](#case-109) invalid event ranges without creating an action |
| <a id='case-109'></a>109 · L110 | rejects invalid event ranges without creating an action | [system_action_service][m27] | `expect(await SystemActionService.instance.getPending(), isEmpty)` | 保留 · [#108](#case-108) reminders without a due date |
| <a id='case-110'></a>110 · L124 | skill exposes only the two pending creation tools | [system_action_skill][m26] | `expect(skill.tools!.map((tool) => tool.name), ['create_calendar_event', 'create_reminder'])`；`expect(skill.tools!.every((tool) => tool.description.contains('user confirmation')), isTrue)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/agent/skills/timeline_diagnostics_skill_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-111'></a>111 · L33 | TimelineDiagnosticsSkill registers focused diagnostic tools | [timeline_diagnostics_skill][m28] | `expect(skill.tools?.map((tool) => tool.name), ['search_timeline_cards', 'inspect_timeline_card'])` | 保留 · [#114](#case-114) returns structured not found result for missing card |
| <a id='case-112'></a>112 · L46 | TimelineDiagnosticsSkill search without query returns recent cards with local time | [timeline_diagnostics_skill][m28] | `expect(result, contains('Recent timeline cards:'))`；`expect(result, contains(formatLocalDateTimeWithZone(dateTimeFromUnixSeconds(_recordTimestamp))))` | 保留 · [#111](#case-111) registers focused diagnostic tools |
| <a id='case-113'></a>113 · L68 | TimelineDiagnosticsSkill inspect returns original input context and current card data without comments | [timeline_diagnostics_skill][m28] | `expect(result, contains('Original input context:'))`；`expect(result, contains('Original user input (fact):'))` | 保留 · [#114](#case-114) returns structured not found result for missing card |
| <a id='case-114'></a>114 · L115 | TimelineDiagnosticsSkill returns structured not found result for missing card | [timeline_diagnostics_skill][m28] | `expect(result, 'Card not found.')` | 保留 · [#113](#case-113) inspect returns original input context and curre…rd data without comments |

</details>

<details>
<summary>test/agent/state_util_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-115'></a>115 · L24 | loadOrCreateAgentState repairs legacy assistant thinking into content blocks | [state_util][m29] | `expect(message.contentBlocks, [{'type' : 'thinking', 'thinking' : 'Need to inspe…: 'Read', 'input' : {'path' : 'a.md'}}])` | 保留 · [#116](#case-116) preserves provider-native content blocks |
| <a id='case-116'></a>116 · L64 | loadOrCreateAgentState preserves provider-native content blocks | [state_util][m29] | `expect(message.contentBlocks, blocks)` | 保留 · [#115](#case-115) repairs legacy assistant thinking into content blocks |
| <a id='case-117'></a>117 · L90 | loadOrCreateAgentState repairs legacy DeepSeek V4 tool-call turns | [state_util][m29] | `expect(message.thought, ' ')` | 保留 · [#115](#case-115) assistant thinking into content blocks |
| <a id='case-118'></a>118 · L120 | loadOrCreateAgentState deletes only agent states matching metadata predicate | [state_util][m29] | `expect(deleted, unorderedEquals(['knowledge_insight_state', 'schedule_aggregator_state']))`；`expect(await File('$stateDirPath/pkm_state.json').exists(), isTrue)` | 保留 · [#116](#case-116) preserves provider-native content blocks |

</details>

<details>
<summary>test/agent/super_agent_child_test.dart · 29 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-119'></a>119 · L60 | SuperAgent child runtime default child timeout allows long specialist work | [super_agent_child][m30] | `expect(cfg(ChildToolProfile.read).timeout, const Duration(minutes: 20))` | 保留。检查子任务的默认超时配置；取消正在运行的请求另由 [#139](#case-139) 覆盖。 · [#139](#case-139) timed out child cancels the model request and saves state |
| <a id='case-120'></a>120 · L64 | SuperAgent child runtime profile none exposes no base tools | [super_agent_child][m30] | `expect(agent.tools ?? const [], isEmpty)` | 保留 · [#121](#case-121) read exposes read-only base tools but no write tools |
| <a id='case-121'></a>121 · L74 | SuperAgent child runtime profile read exposes read-only base tools but no write tools | [super_agent_child][m30] | `expect(names, containsAll(<String>['LS', 'Glob', 'Grep', 'Read']))`；`expect(names, isNot(contains('Write')))` | 保留 · [#120](#case-120) none exposes no base tools |
| <a id='case-122'></a>122 · L87 | SuperAgent child runtime profile full adds write tools on top of read tools | [super_agent_child][m30] | `expect(names, containsAll(<String>['Read', 'Write', 'Edit']))` | 保留 · [#121](#case-121) read exposes read-only base tools but no write tools |
| <a id='case-123'></a>123 · L98 | SuperAgent child runtime restricted read roots keep PKM workers out of Cards | [super_agent_child][m30] | `expect(await File('$workspace/PKM/new.md').readAsString(), 'new pkm note')`；`expect(() => _callTool<String>(readTool, {'file_path' : '/Cards/card.yaml'}), th…ile /Cards/card.yaml does not exist'))))` | 保留 · [#122](#case-122) profile full adds write tools on top of read tools |
| <a id='case-124'></a>124 · L220 | SuperAgent child runtime dynamic_timeline_ui gets scoped file tools injected; base stays bare | [super_agent_child][m30] | `expect(agent.tools ?? const [], isEmpty)`；`expect(skillToolNames, contains('save_timeline_template'))` | 保留 · [#120](#case-120) profile none exposes no base tools |
| <a id='case-125'></a>125 · L251 | SuperAgent child runtime reports child tool progress through delegate progress sink | [super_agent_child][m30] | `expect(result.status, SuperAgentChildStatus.completed)`；`expect(sink.events, contains('finish:delegate_1:LS:false'))` | 保留 · [#138](#case-138) run reports failed when the child errors out |
| <a id='case-126'></a>126 · L287 | SuperAgent child runtime pkm overview formats a model-oriented structure tree | [super_agent_child][m30] | `expect(overview, contains('PKM structure tree'))`；`expect(overview, contains('complete PKM structure'))` | 保留 · [#128](#case-128) marks incomplete trees when truncated |
| <a id='case-127'></a>127 · L308 | SuperAgent child runtime pkm overview reports an empty PKM when the root is missing | [super_agent_child][m30] | `expect(overview, 'P.A.R.A. knowledge base has not been created yet, currently empty.')` | 保留 · [#128](#case-128) marks incomplete trees when truncated |
| <a id='case-128'></a>128 · L320 | SuperAgent child runtime pkm overview marks incomplete trees when truncated | [super_agent_child][m30] | `expect(overview, contains('PKM structure tree'))`；`expect(overview, isNot(contains('complete PKM structure')))` | 保留 · [#126](#case-126) formats a model-oriented structure tree |
| <a id='case-129'></a>129 · L337 | SuperAgent child runtime delegate injects PKM overview reminder into pkm child | [super_agent_child][m30] | `expect(childPrompt, contains('Current PKM structure tree'))`；`expect(childPrompt, isNot(contains('card.yaml')))` | 保留 · [#130](#case-130) latest card metadata reminder into card child |
| <a id='case-130'></a>130 · L381 | SuperAgent child runtime delegate injects latest card metadata reminder into card child | [super_agent_child][m30] | `expect(childPrompt, contains('Latest get_card_metadata result.'))`；`expect(childPrompt, contains('Use this metadata instead of calling get_card_metadata again'))` | 保留 · [#129](#case-129) PKM overview reminder into pkm child |
| <a id='case-131'></a>131 · L426 | SuperAgent child runtime delegate passes referenced image attachments to child as image parts | [super_agent_child][m30] | `expect(imageParts, hasLength(1))`；`expect(childPrompt, contains('The following image part is this attachment'))` | 保留 · [#132](#case-132) inserts a reminder when an image attachment cannot load |
| <a id='case-132'></a>132 · L487 | SuperAgent child runtime delegate inserts a reminder when an image attachment cannot load | [super_agent_child][m30] | `expect(childPrompt, contains('This image attachment could not be loaded into this message.'))`；`expect(childPrompt, isNot(contains('The following system reminder replaces this attachment')))` | 保留 · [#133](#case-133) structured task_content text refs are plain text without asset blocks |
| <a id='case-133'></a>133 · L556 | SuperAgent child runtime structured task_content text refs are plain text without asset blocks | [super_agent_child][m30] | `expect(childUserMessage.contents.whereType<ImagePart>(), isEmpty)`；`expect(_messagesText(client.generateInputs[1]), contains('fs://photo.jpg'))` | 保留 · [#141](#case-141) delegate accepts existing structured asset refs |
| <a id='case-134'></a>134 · L603 | SuperAgent child runtime run infers no_op from the final plain-text message | [super_agent_child][m30] | `expect(result.status, SuperAgentChildStatus.noOp)` | 保留 · [#138](#case-138) reports failed when the child errors out |
| <a id='case-135'></a>135 · L616 | SuperAgent child runtime empty child response retries without spending the last turn | [super_agent_child][m30] | `expect(savedState.lastError, isNull)`；`expect(savedState.history.messages.whereType<ModelMessage>().single.textOutput, 'Completed the task.')` | 保留 · [#120](#case-120) profile none exposes no base tools |
| <a id='case-136'></a>136 · L647 | SuperAgent child runtime terminal tool finish_summary completes child without final LLM call | [super_agent_child][m30] | `expect(result.status, SuperAgentChildStatus.completed)`；`expect(result.summary, 'Updated the card insight and found no related facts.')` | 保留 · [#134](#case-134) run infers no_op from the final plain-text message |
| <a id='case-137'></a>137 · L704 | SuperAgent child runtime update insight success output does not expose card paths | [super_agent_child][m30] | `expect(text, 'Card insight updated.')`；`expect(text, isNot(contains('Related facts count')))` | 保留 · [#141](#case-141) delegate accepts existing structured asset refs |
| <a id='case-138'></a>138 · L760 | SuperAgent child runtime run reports failed when the child errors out | [super_agent_child][m30] | `expect(result.status, SuperAgentChildStatus.failed)`；`expect(savedState.lastError, contains('boom'))` | 保留 · [#139](#case-139) timed out child cancels the model request and saves state |
| <a id='case-139'></a>139 · L780 | SuperAgent child runtime timed out child cancels the model request and saves state | [super_agent_child][m30] | `expect(result.status, SuperAgentChildStatus.failed)`；`expect(result.error, 'child timed out after 20ms')` | 保留 · [#138](#case-138) run reports failed when the child errors out |
| <a id='case-140'></a>140 · L838 | SuperAgent child runtime delegate rejects nonexistent structured asset refs | [super_agent_child][m30] | `expect(_text(result), contains('fs://missing.jpg'))` | 保留 · [#141](#case-141) accepts existing structured asset refs |
| <a id='case-141'></a>141 · L876 | SuperAgent child runtime delegate accepts existing structured asset refs | [super_agent_child][m30] | `expect(_text(result), contains('Asset reference accepted.'))` | 保留 · [#140](#case-140) rejects nonexistent structured asset refs |
| <a id='case-142'></a>142 · L919 | SuperAgent child runtime delegate rejects unknown agent types | [super_agent_child][m30] | `expect(_text(result), contains('Unknown agent_type'))` | 保留 · [#143](#case-143) the retired schedule agent type |
| <a id='case-143'></a>143 · L954 | SuperAgent child runtime delegate rejects the retired schedule agent type | [super_agent_child][m30] | `expect(_text(result), contains('Unknown agent_type "schedule"'))` | 保留 · [#142](#case-142) unknown agent types |
| <a id='case-144'></a>144 · L992 | SuperAgent child runtime delegate allows the fixed research agent type | [super_agent_child][m30] | `expect(_text(result), contains('agent_type="research"'))`；`expect(_text(result), isNot(contains('child=')))` | 保留 · [#147](#case-147) accepts a fixed agent_type call without profile or skills |
| <a id='case-145'></a>145 · L1037 | SuperAgent child runtime delegate schema exposes agent_type instead of profile and skills | [super_agent_child][m30] | `expect(properties.keys, contains('agent_type'))`；`expect(agentType['enum'], isNot(contains('schedule')))` | 保留 · [#147](#case-147) accepts a fixed agent_type call without profile or skills |
| <a id='case-146'></a>146 · L1064 | SuperAgent child runtime finish_summary is only exposed by child-specialized skills | [super_agent_child][m30] | `expect(childSaveProperties, contains('finish_summary'))`；`expect((childInsightProperties['finish_summary'] as Map)['description'], isNot(contains('child')))` | 保留 · [#147](#case-147) delegate accepts a fixed agent_type call without profile or skills |
| <a id='case-147'></a>147 · L1095 | SuperAgent child runtime delegate accepts a fixed agent_type call without profile or skills | [super_agent_child][m30] | `expect(_text(result), contains('agent_type="research"'))`；`expect(_text(result), isNot(contains('child=')))` | 删除。[#144](#case-144) 使用相同 research 输入、相同模型响应和四个相同断言。 · [#144](#case-144) allows the fixed research agent type |

</details>

<details>
<summary>test/agent/super_agent_harness_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-148'></a>148 · L8 | SuperAgentHarness idle skill tracking persists idle counters in agent metadata across agent recreation | [super_agent_harness][m31] | `expect(state.metadata['super_agent_idle_skill_turns_v1'], {'optional_skill' : 2})`；`expect(state.metadata['super_agent_idle_skill_turns_v1'], {'optional_skill' : 3})` | 保留 · [#149](#case-149) resets persisted counter when the optional skill is used |
| <a id='case-149'></a>149 · L38 | SuperAgentHarness idle skill tracking resets persisted counter when the optional skill is used | [super_agent_harness][m31] | `expect(state.metadata, isNot(contains('super_agent_idle_skill_turns_v1')))` | 保留 · [#148](#case-148) persists idle counters in agent metadata across agent recreation |

</details>

<details>
<summary>test/agent/super_agent_loop_detector_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-150'></a>150 · L7 | SuperAgentLoopDetector does not diagnose non-tool turns based on accumulated loop count | [super_agent_loop_detector][m32] | `expect(result.isLoop, isFalse)` | 保留 · [#151](#case-151) detects repeated identical tool calls |
| <a id='case-151'></a>151 · L22 | SuperAgentLoopDetector detects repeated identical tool calls | [super_agent_loop_detector][m32] | `expect(await detector.detect(_toolCall('1')), _isNotLoop)`；`expect(await detector.detect(_toolCall('2')), _isNotLoop)` | 保留 · [#152](#case-152) canonicalizes argument key order before comparing tool calls |
| <a id='case-152'></a>152 · L34 | SuperAgentLoopDetector canonicalizes argument key order before comparing tool calls | [super_agent_loop_detector][m32] | `expect(await detector.detect(_toolCall('1', arguments: '{"b":2,"a":1}')), _isNotLoop)` | 保留 · [#151](#case-151) detects repeated identical tool calls |

</details>

<details>
<summary>test/agent/super_agent_permissions_test.dart · 20 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-153'></a>153 · L29 | SuperAgent file permissions (normal mode) non-asset files under Facts are read-only | [super_agent][m33] | `expect(() => manager.checkPermission('$facts/2026/06/10.md', FileAccessType.writ…rowsA(isA<PermissionDeniedException>()))` | 保留 · [#156](#case-156) media files under assets stay writable |
| <a id='case-154'></a>154 · L39 | SuperAgent file permissions (normal mode) moving or removing a Facts directory is denied (write on source) | [super_agent][m33] | `expect(() => manager.checkPermission('$facts/2026/06', FileAccessType.write), throwsA(isA<PermissionDeniedException>()))` | 保留 · [#153](#case-153) non-asset files under Facts are read-only |
| <a id='case-155'></a>155 · L47 | SuperAgent file permissions (normal mode) permission denial message does not expose absolute paths | [super_agent][m33] | `expect(message, isNot(contains('/ws')))`；`expect(message, isNot(contains(facts)))` | 保留 · [#157](#case-157) the rest of the workspace stays writable |
| <a id='case-156'></a>156 · L63 | SuperAgent file permissions (normal mode) media files under assets stay writable | [super_agent][m33] | 两次写 assets 路径均须成功，否则权限检查会抛错 | 保留 · [#157](#case-157) the rest of the workspace stays writable |
| <a id='case-157'></a>157 · L68 | SuperAgent file permissions (normal mode) the rest of the workspace stays writable | [super_agent][m33] | 写 Cards 和 PKM 时权限检查均须成功 | 保留 · [#156](#case-156) media files under assets stay writable |
| <a id='case-158'></a>158 · L78 | SuperAgent file permissions (quick query) everything is read-only including assets | [super_agent][m33] | `expect(() => manager.checkPermission('$assets/photo.jpg', FileAccessType.write),…rowsA(isA<PermissionDeniedException>()))` | 保留 · [#153](#case-153) (normal mode) non-asset files under Facts are read-only |
| <a id='case-159'></a>159 · L94 | SuperAgent quick query tools does not expose event log search or current time tools | [super_agent][m33] | `expect(SuperAgent.isQuickQueryToolAllowed('getCurrentTime'), isFalse)` | 保留 · [#160](#case-160) allows image viewing as a read-only tool |
| <a id='case-160'></a>160 · L105 | SuperAgent quick query tools allows image viewing as a read-only tool | [super_agent][m33] | `expect(SuperAgent.isQuickQueryToolAllowed('view_image'), isTrue)` | 保留 · [#161](#case-161) generic LS for read-only filesystem access |
| <a id='case-161'></a>161 · L109 | SuperAgent quick query tools allows generic LS for read-only filesystem access | [super_agent][m33] | `expect(SuperAgent.isQuickQueryToolAllowed('LS'), isTrue)` | 保留 · [#160](#case-160) image viewing as a read-only tool |
| <a id='case-162'></a>162 · L113 | SuperAgent quick query tools excludes the mutating calendar and reminder skill | [super_agent][m33] | `expect(SuperAgent.isQuickQuerySkillAllowed('manage_calendar_and_reminders'), isFalse)` | 保留 · [#164](#case-164) PKM skill |
| <a id='case-163'></a>163 · L122 | SuperAgent quick query tools excludes the memory write skill | [super_agent][m33] | `expect(SuperAgent.isQuickQuerySkillAllowed('manage_memory'), isFalse)` | 保留 · [#164](#case-164) mutating PKM skill |
| <a id='case-164'></a>164 · L126 | SuperAgent quick query tools excludes the mutating PKM skill | [super_agent][m33] | `expect(SuperAgent.isQuickQuerySkillAllowed('manage_pkm'), isFalse)` | 保留 · [#162](#case-162) calendar and reminder skill |
| <a id='case-165'></a>165 · L132 | SuperAgent run limits root agent allows long import and organization runs | [super_agent][m33] | `expect(SuperAgent.rootMaxTurns, 80)` | 删除。只比较常量 80 与 20，未执行长任务。长任务可完成性尚无这条证据。 · [#139](#case-139) child runtime timed out child cancels the model request and saves state |
| <a id='case-166'></a>166 · L139 | SuperAgent legacy active skills drops stale active skill names before agent tools are composed | [super_agent][m33] | `expect(state.activeSkills, ['manage_timeline_card'])` | 保留 · [#163](#case-163) quick query tools excludes the memory write skill |
| <a id='case-167'></a>167 · L160 | SuperAgent transient pre-minted record reminder matches only the empty processing placeholder | [super_agent][m33] | `expect(isUnusedPreallocatedRecordPlaceholder(placeholder, factId), isTrue)`；`expect(isUnusedPreallocatedRecordPlaceholder(placeholder.copyWith(status: 'waiting_for_network'), factId), isTrue)` | 保留 · [#169](#case-169) does not append when no pre-minted fact_id exists |
| <a id='case-168'></a>168 · L213 | SuperAgent transient pre-minted record reminder annotates the matching user message only in model requests | [super_agent][m33] | `expect(text, contains('2026/06/26.md#ts_2'))`；`expect(text, contains('current user message'))` | 保留 · [#169](#case-169) does not append when no pre-minted fact_id exists |
| <a id='case-169'></a>169 · L241 | SuperAgent transient pre-minted record reminder does not append when no pre-minted fact_id exists | [super_agent][m33] | `expect(requestMessages, same(messages))` | 保留 · [#168](#case-168) annotates the matching user message only in model requests |
| <a id='case-170'></a>170 · L255 | SuperAgent transient pre-minted record reminder reuses persisted same-turn fact_id after task restart | [super_agent][m33] | `expect(state.metadata[SuperAgentPreMintedRecordHook.factIdMetadataKey], '2026/06/26.md#ts_1')` | 保留 · [#171](#case-171) keeps same-turn fact_id when a running agent will retry |
| <a id='case-171'></a>171 · L277 | SuperAgent transient pre-minted record reminder keeps same-turn fact_id when a running agent will retry | [super_agent][m33] | `expect(state.metadata[SuperAgentPreMintedRecordHook.factIdMetadataKey], '2026/06/26.md#ts_1')`；`expect(state.metadata[SuperAgentPreMintedRecordHook.turnIdMetadataKey], 'turn-1')` | 保留 · [#170](#case-170) reuses persisted same-turn fact_id after task restart |
| <a id='case-172'></a>172 · L322 | SuperAgent transient pre-minted record reminder annotates the matching history user message after the id is used | [super_agent][m33] | `expect(messages.singleWhere((m) => m is UserMessage), same(userMessage))`；`expect(reminder, contains('Newly minted record fact_id was used this turn: 2026/06/26.md#ts_1.'))` | 保留 · [#168](#case-168) user message only in model requests |

</details>

<details>
<summary>test/agent_refactor_functional_test.dart · 7 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-173'></a>173 · L121 | Agent Refactor Functional Coverage memory entries: add/replace/remove and context retrieval | [character_memory_service][m34] | `expect(text, contains('non-lecturing comfort'))`；`expect(entries, isEmpty)` | 保留 · [#176](#case-176) context assembler: builds unified snapshot with clipped sections |
| <a id='case-174'></a>174 · L168 | Agent Refactor Functional Coverage timeline append branches: empty content skipped, non-empty persisted | [character_memory_service][m34] | `expect(lines, isEmpty)`；`expect(lines.first, contains('"event_type":"userChatMessage"'))` | 保留 · [#175](#case-175) context compressor branches: compress + cooldown skip |
| <a id='case-175'></a>175 · L203 | Agent Refactor Functional Coverage context compressor branches: compress + cooldown skip | [character_context_compressor][m35] | `expect(archivedSearch, contains('turn-0'))`；`expect(afterSkip.length, beforeSkip.length)` | 保留 · [#174](#case-174) timeline append branches: empty content skipped, non-empty persisted |
| <a id='case-176'></a>176 · L274 | Agent Refactor Functional Coverage context assembler: builds unified snapshot with clipped sections | [character_context_assembler][m36] | `expect(snapshot.characterMemories, contains('short support'))`；`expect(snapshot.recentTimeline, contains('Post:'))` | 保留 · [#177](#case-177) comment thread timeline stores post once with multiple comments |
| <a id='case-177'></a>177 · L315 | Agent Refactor Functional Coverage comment thread timeline stores post once with multiple comments | [character_memory_service][m34] | `expect(snapshot.recentTimeline, contains('Original post body'))`；`expect(commentSnapshot.recentTimeline, isNot(contains('Original post body')))` | 保留 · [#176](#case-176) context assembler: builds unified snapshot with clipped sections |
| <a id='case-178'></a>178 · L397 | Agent Refactor Functional Coverage knowledge context snippets expand around matched terms | [user_knowledge_context_service][m37] | `expect(context, contains('burnout recovery'))`；`expect(context, isNot(contains(List.filled(120, 'A').join())))` | 保留 · 未找到同一行为的替代项 |
| <a id='case-179'></a>179 · L427 | Agent Refactor Functional Coverage tavern import: json+png preview/import/conflict and invalid format | [tavern_character_import_service][m38] | `expect(jsonWorldEntries.length + pngWorldEntries.length, greaterThan(0))`；`expect(() => svc.previewFromFile(filePath: txt.path), throwsA(isA<ArgumentError>()))` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/app_startup_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-180'></a>180 · L7 | localization finishes before all three independent services start | [app_startup][m39] | `expect(started, unorderedEquals(['workmanager', 'bridge', 'server']))` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/config/app_config_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-181'></a>181 · L8 | AppConfig.availableProviders includes DeepSeek in global flavor | [app_config][m40] | `expect(AppConfig.availableProviders, contains(LLMConfig.typeDeepSeek))` | 保留。国内和全球两个构建渠道可独立配置。 · [#183](#case-183) CN flavor |
| <a id='case-182'></a>182 · L14 | AppConfig.availableProviders excludes Memex proxy service from manual providers | [app_config][m40] | `expect(AppConfig.availableProviders, isNot(contains(LLMConfig.typeMemex)))` | 保留 · [#181](#case-181) includes DeepSeek in global flavor |
| <a id='case-183'></a>183 · L22 | AppConfig.availableProviders includes DeepSeek in CN flavor | [app_config][m40] | `expect(AppConfig.availableProviders, contains(LLMConfig.typeDeepSeek))` | 保留。国内和全球两个构建渠道可独立配置。 · [#181](#case-181) global flavor |

</details>

<details>
<summary>test/data/model/chat_artifact_test.dart · 8 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-184'></a>184 · L6 | ChatArtifact schema v2 parses a timeline card artifact with target uri metadata | [chat_artifact][m41] | `expect(artifact!.version, ChatArtifact.schemaVersion)`；`expect(artifact.kind, ChatArtifact.kindTimelineCard)` | 保留 · [#188](#case-188) rejects missing, malformed, legacy, or unknown artifacts |
| <a id='case-185'></a>185 · L29 | ChatArtifact schema v2 parses multiple artifacts and round-trips json | [chat_artifact][m41] | `expect(artifacts.first.kind, ChatArtifact.kindKnowledgeInsight)`；`expect(ChatArtifact.fromJson(artifacts.last.toJson())!.updated, isTrue)` | 保留 · [#191](#case-191) ChatArtifactSessionMigration rewrites legacy ses…ifacts to schema v2 once |
| <a id='case-186'></a>186 · L53 | ChatArtifact schema v2 normalizes knowledge file path for knowledge tab navigation | [chat_artifact][m41] | `expect(ChatArtifact.knowledgeFilePathFromWorkspacePath(r'\PKM\Areas\health.md'), 'Areas/health.md')`；`expect(ChatArtifact.knowledgeFilePathFromWorkspacePath('Projects/memex.md'), isNull)` | 保留 · [#191](#case-191) ChatArtifactSessionMigration rewrites legacy ses…ifacts to schema v2 once |
| <a id='case-187'></a>187 · L76 | ChatArtifact schema v2 keeps each pending system action as a distinct artifact | [chat_artifact][m41] | `expect(collector.artifacts.map((artifact) => artifact.systemActionId), ['action-1', 'action-2'])`；`expect(first.targetUri, isNot(second.targetUri))` | 保留 · [#190](#case-190) ChatTurnArtifactCollector seeds recovered turns …sses an identical replay |
| <a id='case-188'></a>188 · L106 | ChatArtifact schema v2 rejects missing, malformed, legacy, or unknown artifacts | [chat_artifact][m41] | `expect(ChatArtifact.fromToolMetadata({'artifact' : {'type' : 'card', 'id' : 'legacy'}}), isNull)`；`expect(ChatArtifact.fromToolMetadata({'artifact' : {'version' : ChatArtifact.sch…ChatArtifact.operationCreate}}), isNull)` | 保留 · [#184](#case-184) parses a timeline card artifact with target uri metadata |
| <a id='case-189'></a>189 · L131 | ChatTurnArtifactCollector deduplicates by stable UI destination and adds source fields | [chat_artifact][m41] | `expect(collector.artifacts.single.sourceRunId, 'turn-1')`；`expect(collector.artifacts.single.sourceToolCallId, 'tool-3')` | 保留 · [#190](#case-190) seeds recovered turns and suppresses an identical replay |
| <a id='case-190'></a>190 · L175 | ChatTurnArtifactCollector seeds recovered turns and suppresses an identical replay | [chat_artifact][m41] | `expect(collector.artifacts, hasLength(1))` | 保留 · [#189](#case-189) deduplicates by stable UI destination and adds source fields |
| <a id='case-191'></a>191 · L205 | ChatArtifactSessionMigration rewrites legacy session artifacts to schema v2 once | [chat_artifact][m41] | `expect(session[ChatArtifactSessionMigration.schemaVersionKey], ChatArtifact.schemaVersion)`；`expect(fileArtifact.kind, ChatArtifact.kindKnowledgeFile)` | 保留 · [#188](#case-188) ChatArtifact schema v2 rejects missing, malforme…cy, or unknown artifacts |

</details>

<details>
<summary>test/data/repositories/card_reply_name_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-192'></a>192 · L7 | withResolvedReplyNames resolves an AI reply to a user comment as the display name | [card][m42] | `expect(resolved[1].replyToName, userDisplayName)`；`expect(commentReplyNameMap(comments, userDisplayName: userDisplayName)['u1'], userDisplayName)` | 保留 · [#193](#case-193) another character by character name |
| <a id='case-193'></a>193 · L42 | withResolvedReplyNames resolves an AI reply to another character by character name | [card_detail_model][m43] | `expect(resolved[1].replyToName, 'YaoYao')` | 保留 · [#192](#case-192) a user comment as the display name |
| <a id='case-194'></a>194 · L77 | withResolvedReplyNames does not use a raw userId as the user display name | [card_detail_model][m43] | `expect(resolved[1].replyToName, isNot(rawUserId))`；`expect(replyDisplayNameFor(comments.first, userDisplayName), userDisplayName)` | 保留 · [#192](#case-192) resolves an AI reply to a user comment as the display name |

</details>

<details>
<summary>test/data/repositories/chat_session_time_context_test.dart · 6 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-195'></a>195 · L37 | chat session time context hydrates local time fields for legacy session detail | [chat][m44] | `expect(detail['created_at_local'], contains('2026-04-28 20:00:46'))`；`expect(detail['updated_at_local'], contains('2026-04-28 20:05:00'))` | 保留 · [#196](#case-196) preserves existing local time fields in session messages |
| <a id='case-196'></a>196 · L80 | chat session time context preserves existing local time fields in session messages | [chat][m44] | `expect(detail['created_at_local'], 'already-local-created')`；`expect(message['local_time'], 'already-local-message')` | 保留 · [#195](#case-195) hydrates local time fields for legacy session detail |
| <a id='case-197'></a>197 · L120 | chat session time context migrates legacy artifacts in session detail and persists v2 | [chat_session_storage][m45] | `expect(persisted[ChatArtifactSessionMigration.schemaVersionKey], ChatArtifact.schemaVersion)`；`expect(await File(storage.messagesPath(userId, 'legacy-artifact-session')).exists(), isTrue)` | 保留 · [#429](#case-429) ChatSessionStorage migrates legacy YAML to metad…a JSON and message JSONL |
| <a id='case-198'></a>198 · L194 | chat session time context paginates session detail messages from newest backwards | [chat][m44] | `expect(latest['has_more_messages'], isTrue)`；`expect(_messageText(oldestMessages.single), 'message 1')` | 保留 · [#196](#case-196) preserves existing local time fields in session messages |
| <a id='case-199'></a>199 · L251 | chat session time context adds local time fallback to chat session list rows | [chat][m44] | `expect(sessions.single['created_at_local'], contains('2026-04-28'))`；`expect(sessions.single['updated_at_local'], contains('2026-04-28'))` | 保留 · [#196](#case-196) preserves existing local time fields in session messages |
| <a id='case-200'></a>200 · L284 | chat session time context checks one session path without loading session content | [chat_session_storage][m45] | `expect(await chatSessionExistsEndpoint('missing-session'), isFalse)` | 保留 · [#432](#case-432) ChatSessionStorage legacy message_count cleanup …t rewrite metadata again |

</details>

<details>
<summary>test/data/repositories/filesystem_root_switch_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-201'></a>201 · L39 | FileSystemService root switching card writes resolve the active root at call time | [file_system_service][m46] | `expect(File(rootBCard).readAsStringSync(), contains('root B'))`；`expect(File(rootBCard).existsSync(), isTrue)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/data/repositories/get_aggregated_timeline_week_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-202'></a>202 · L16 | week labels use German week label | [get_aggregated_timeline][m47] | `expect(label, contains('Woche'))`；`expect(label, contains('10'))` | 保留 · [#222](#case-222) month labels use the active locale month name |

</details>

<details>
<summary>test/data/repositories/get_calendar_data_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-203'></a>203 · L30 | a card just after local midnight stays on that local day | [get_calendar_data][m48] | `expect(occupied.single.timestamp, expectedDay)`；`expect(occupied.single.cards.single.id, factId)` | 保留 · [#205](#case-205) midnight partitions cards exactly once across leap day and new year |
| <a id='case-204'></a>204 · L62 | a month that contains the DST fallback still returns each day | [get_calendar_data][m48] | `expect(days, hasLength(3))` | 保留 · [#203](#case-203) card just after local midnight stays on that local day |
| <a id='case-205'></a>205 · L71 | midnight partitions cards exactly once across leap day and new year | [get_calendar_data][m48] | `expect(days.map((d) => d.cards.map((c) => c.id).toList()), expected)` | 保留 · [#203](#case-203) a card just after local midnight stays on that local day |

</details>

<details>
<summary>test/data/repositories/hydrate_card_cache_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-206'></a>206 · L30 | reuses the same hydrated card when YAML has not changed | [hydrated_card_cache][m49] | `expect(identical(first, second), isTrue)`；`expect(HydratedCardCache.instance.length, 1)` | 保留 · [#208](#case-208) does not reuse hydrated cards across users with matching YAML |
| <a id='case-207'></a>207 · L55 | misses the cache after the card YAML changes | [hydrated_card_cache][m49] | `expect(second?.title, 'After')`；`expect(identical(first, second), isFalse)` | 保留 · [#208](#case-208) does not reuse hydrated cards across users with matching YAML |
| <a id='case-208'></a>208 · L95 | does not reuse hydrated cards across users with matching YAML | [hydrated_card_cache][m49] | `expect(identical(first, second), isFalse)`；`expect(HydratedCardCache.instance.length, 2)` | 保留 · [#206](#case-206) reuses the same hydrated card when YAML has not changed |
| <a id='case-209'></a>209 · L131 | clearUser invalidates only the selected workspace | [hydrated_card_cache][m49] | `expect(HydratedCardCache.instance.length, 1)`；`expect(HydratedCardCache.instance.get(secondUserId, factId, hydratedCardContentHash(_cardData)), same(second))` | 保留 · [#206](#case-206) reuses the same hydrated card when YAML has not changed |

</details>

<details>
<summary>test/data/repositories/memex_router_llm_config_event_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-210'></a>210 · L43 | saveLLMConfigs emits typed config change event | [memex_router][m50] | `expect(messages.single.hasValidConfig, isTrue)`；`expect(messages.single.reason, 'saved')` | 保留 · [#211](#case-211) resetLLMConfigs emits invalid config change event |
| <a id='case-211'></a>211 · L61 | resetLLMConfigs emits invalid config change event | [memex_router][m50] | `expect(messages.single.hasValidConfig, isFalse)`；`expect(messages.single.reason, 'reset')` | 保留 · [#210](#case-210) saveLLMConfigs emits typed config change event |
| <a id='case-212'></a>212 · L80 | setDefaultLLMConfigKey emits default changed event | [memex_router][m50] | `expect(messages, hasLength(1))`；`expect(messages.single.reason, 'default_changed')` | 保留 · [#210](#case-210) saveLLMConfigs emits typed config change event |

</details>

<details>
<summary>test/data/repositories/migrate_cards_fact_assets_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-213'></a>213 · L34 | migrateCardsToFactAssets backfills legacy fact text, assets, and created_at | [migrate_cards_fact_assets][m51] | `expect(card!.fact, '早餐吃了豆浆油条。')`；`expect(card.createdAt, DateTime(2026, 5, 18, 9, 8, 7).millisecondsSinceEpoch ~/ 1000)` | 保留 · [#214](#case-214) v2 backfills missing created_at without clobbering migrated content |
| <a id='case-214'></a>214 · L70 | migrateCardsToFactAssets v2 backfills missing created_at without clobbering migrated content | [migrate_cards_fact_assets][m51] | `expect(card!.fact, 'already migrated fact')`；`expect(card.createdAt, DateTime(2026, 5, 18, 10, 11, 12).millisecondsSinceEpoch ~/ 1000)` | 保留 · [#213](#case-213) backfills legacy fact text, assets, and created_at |
| <a id='case-215'></a>215 · L109 | migrateCardsToFactAssets reads entry after frontmatter without including later facts | [migrate_cards_fact_assets][m51] | `expect(card!.fact, '午饭吃了牛肉面。')`；`expect(card.assets, ['[audio](fs://lunch.m4a)'])` | 保留 · [#213](#case-213) backfills legacy fact text, assets, and created_at |

</details>

<details>
<summary>test/data/repositories/timeline_comment_journey_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-216'></a>216 · L26 | open a listed entry, post and reply, then reopen the correct thread | [post_comment][m52] | `expect(comments.map((c) => c.id), [firstId, reply['comment_id']])`；`expect(comments.last.replyToId, firstId)` | 保留。同一服务链提交评论和回复，再按两条记录分别读取线程，校验归属。 · [#690](#case-690) post a comment in detail and read it after reopening the screen |
| <a id='case-217'></a>217 · L75 | find a photo note and its thread after reopening the database | [search_service][m53] | `expect(Uri.parse(listed.assets!.single.url).pathSegments.last, photo)`；`expect(Uri.parse(image.url).pathSegments.last, photo)` | 保留。从重开的数据库和真实搜索命中重新读附件与评论。 · [#692](#case-692) send a photo offline, replay the queued turn and…and attachment in detail |

</details>

<details>
<summary>test/data/repositories/timeline_pagination_property_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-218'></a>218 · L18 | Timeline pages match surviving entries after rebuild (seed 31) | [get_timeline_cards][m54] | `expect(await files.safeWriteCardFile(user, id, card), isTrue)`；`expect(ids, records.map((c) => c.factId), reason: 'filter=$tag, seed=$seed')` | 保留固定种子。相同分页属性在不同数据、操作序列和排序冲突上成立。 · [#220](#case-220) 71) |
| <a id='case-219'></a>219 · L18 | Timeline pages match surviving entries after rebuild (seed 7) | [get_timeline_cards][m54] | `expect(await files.safeWriteCardFile(user, id, card), isTrue)`；`expect(ids, records.map((c) => c.factId), reason: 'filter=$tag, seed=$seed')` | 保留固定种子。相同分页属性在不同数据、操作序列和排序冲突上成立。 · [#220](#case-220) 71) |
| <a id='case-220'></a>220 · L18 | Timeline pages match surviving entries after rebuild (seed 71) | [get_timeline_cards][m54] | `expect(await files.safeWriteCardFile(user, id, card), isTrue)`；`expect(ids, records.map((c) => c.factId), reason: 'filter=$tag, seed=$seed')` | 保留固定种子。相同分页属性在不同数据、操作序列和排序冲突上成立。 · [#219](#case-219) 7) |

</details>

<details>
<summary>test/data/repositories/timeline_period_label_locale_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-221'></a>221 · L17 | day labels use the active locale weekday name | [get_aggregated_timeline][m47] | `expect(label, isNot(contains('Aug')))` | 保留 · [#222](#case-222) month labels use the active locale month name |
| <a id='case-222'></a>222 · L26 | month labels use the active locale month name | [get_aggregated_timeline][m47] | `expect(subLabel, '')` | 保留 · [#221](#case-221) day labels use the active locale weekday name |

</details>

<details>
<summary>test/data/repositories/update_card_location_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-223'></a>223 · L47 | updateCardLocation stores card override and reusable location mark | [card][m42] | `expect(card.userFixedLocation?.name, 'People Square')`；`expect(card.userFixedLocation?.lat, closeTo(31.2304, 0.000001))` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/data/repositories/update_card_ui_config_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-224'></a>224 · L45 | publishes card UI config update event after writing task data | [update_card_ui_config][m55] | `expect(observedTimelineUpdate!.id, cardId)`；`expect(card!.uiConfigs.single.data['is_completed'], isTrue)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/data/services/agent_background_coordinator_test.dart · 11 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-225'></a>225 · L50 | publishes active status and schedules one drain for a run | [agent_background_coordinator][m56] | `expect(platform.updates.single.state, AgentBackgroundRunState.active)`；`expect(platform.updates.last.summary, isNot(contains('Updating PKM')))` | 保留 · [#232](#case-232) retries publishing after platform update failure |
| <a id='case-226'></a>226 · L81 | schedules drain from local tasks even when foreground tracker is empty | [agent_background_coordinator][m56] | `expect(platform.updates, isEmpty)`；`expect(platform.finished, isEmpty)` | 保留 · [#228](#case-228) clears completed status and cancels drain when queue empties |
| <a id='case-227'></a>227 · L96 | defers WorkManager drain while app is foregrounded | [agent_background_coordinator][m56] | `expect(platform.updates.single.state, AgentBackgroundRunState.active)`；`expect(scheduler.events.last, 'schedule:true:0')` | 保留 · [#234](#case-234) normal app launch keeps tracked task progress visible in foreground |
| <a id='case-228'></a>228 · L120 | clears completed status and cancels drain when queue empties | [agent_background_coordinator][m56] | `expect(scheduler.cancelCount, greaterThanOrEqualTo(1))` | 保留 · [#233](#case-233) serializes delayed active publish before terminal publish |
| <a id='case-229'></a>229 · L152 | forwards notification tap requests to listeners | [agent_background_coordinator][m56] | 订阅后触发系统动作，一秒内收到通知 | 保留 · [#230](#case-230) buffers initial notification tap until a listener attaches |
| <a id='case-230'></a>230 · L164 | buffers initial notification tap until a listener attaches | [agent_background_coordinator][m56] | 先消费冷启动动作，再订阅，一秒内补发通知 | 保留 · [#229](#case-229) forwards notification tap requests to listeners |
| <a id='case-231'></a>231 · L180 | keeps system surface active when error arrives with retryable tasks | [agent_background_coordinator][m56] | `expect(platform.updates.last.state, AgentBackgroundRunState.active)`；`expect(scheduler.cancelCount, cancelCountBeforeError)` | 保留 · [#234](#case-234) normal app launch keeps tracked task progress visible in foreground |
| <a id='case-232'></a>232 · L209 | retries publishing after platform update failure | [agent_background_coordinator][m56] | `expect(platform.updates, isEmpty)`；`expect(platform.updateAttempts, 2)` | 保留 · [#225](#case-225) publishes active status and schedules one drain for a run |
| <a id='case-233'></a>233 · L237 | serializes delayed active publish before terminal publish | [agent_background_coordinator][m56] | `expect(platform.stopCount, stopCountBeforeTerminal)`；`expect(platform.events, ['update:active:bg=true', 'stop'])` | 保留 · [#228](#case-228) clears completed status and cancels drain when queue empties |
| <a id='case-234'></a>234 · L275 | normal app launch keeps tracked task progress visible in foreground | [agent_background_coordinator][m56] | `expect(platform.updates.last.state, AgentBackgroundRunState.active)`；`expect(scheduler.scheduleCount, 0)` | 保留 · [#227](#case-227) defers WorkManager drain while app is foregrounded |
| <a id='case-235'></a>235 · L302 | paused tracked work remains visible and keeps drain scheduled | [agent_background_coordinator][m56] | `expect(platform.updates.last.state, AgentBackgroundRunState.paused)`；`expect(platform.updates.last.detail, contains('continue later'))` | 保留 · [#234](#case-234) normal app launch keeps tracked task progress visible in foreground |

</details>

<details>
<summary>test/data/services/agent_background_platform_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-236'></a>236 · L19 | passes summary through updateAgentStatus platform payload | [agent_background_platform][m57] | `expect(calls.single.method, 'updateAgentStatus')`；`expect(payload['summary'], isNot(contains('Calling Tool')))` | 保留 · [#237](#case-237) finishAgentStatus platform payload |
| <a id='case-237'></a>237 · L61 | passes summary through finishAgentStatus platform payload | [agent_background_platform][m57] | `expect(calls.single.method, 'finishAgentStatus')`；`expect(payload['title'], 'Memex Agent needs attention')` | 保留 · [#236](#case-236) updateAgentStatus platform payload |
| <a id='case-238'></a>238 · L97 | emits action event when Android asks Flutter to open agent activity | [agent_background_platform][m57] | `expect(events, ['agent_activity'])` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/data/services/agent_background_status_test.dart · 12 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-239'></a>239 · L10 | AgentBackgroundStatus stays idle when there are no tasks or terminal messages | [agent_background_status][m58] | `expect(status.state, AgentBackgroundRunState.idle)`；`expect(status.summary, 'No background tasks.')` | 保留 · [#244](#case-244) treats an empty-queue activity error as stale without a run snapshot |
| <a id='case-240'></a>240 · L23 | AgentBackgroundStatus uses task snapshot counts for active status | [agent_background_status][m58] | `expect(status.state, AgentBackgroundRunState.active)`；`expect(status.toPlatformMap(isInBackground: true), containsPair('summary', 'Processing 4 queued task(s).'))` | 保留 · [#248](#case-248) foreground tracker task counts for platform status |
| <a id='case-241'></a>241 · L62 | AgentBackgroundStatus keeps retryable error visible as active while tasks remain | [agent_background_status][m58] | `expect(status.state, AgentBackgroundRunState.active)`；`expect(status.summary, 'Will retry automatically')` | 保留 · [#244](#case-244) treats an empty-queue activity error as stale without a run snapshot |
| <a id='case-242'></a>242 · L87 | AgentBackgroundStatus uses activity content as notification summary without title prefix | [agent_background_status][m58] | `expect(status.title, 'Memex Agent')`；`expect(status.summary, isNot(contains('Tool called')))` | 保留 · [#243](#case-243) falls back to activity title when content is blank |
| <a id='case-243'></a>243 · L126 | AgentBackgroundStatus falls back to activity title when content is blank | [agent_background_status][m58] | `expect(status.stage, 'Reading workspace')`；`expect(status.summary, 'Reading workspace')` | 保留 · [#242](#case-242) uses activity content as notification summary without title prefix |
| <a id='case-244'></a>244 · L150 | AgentBackgroundStatus treats an empty-queue activity error as stale without a run snapshot | [agent_background_status][m58] | `expect(status.state, AgentBackgroundRunState.idle)`；`expect(status.title, 'Memex Agent')` | 保留 · [#239](#case-239) stays idle when there are no tasks or terminal messages |
| <a id='case-245'></a>245 · L173 | AgentBackgroundStatus marks terminal stop as completed only after queue is empty | [agent_background_status][m58] | `expect(stillRunning.state, AgentBackgroundRunState.active)`；`expect(completed.state, AgentBackgroundRunState.completed)` | 保留 · [#244](#case-244) treats an empty-queue activity error as stale without a run snapshot |
| <a id='case-246'></a>246 · L205 | AgentBackgroundStatus trims multi-line content before sending to platform | [agent_background_status][m58] | `expect(status.detail.contains('\n'), isFalse)`；`expect(status.summary.contains('\n'), isFalse)` | 保留 · [#243](#case-243) falls back to activity title when content is blank |
| <a id='case-247'></a>247 · L232 | AgentBackgroundStatus uses localized labels for platform-facing background copy | [agent_background_status][m58] | `expect(status.title, 'Memex Agent')`；`expect(status.toPlatformMap(), containsPair('statusText', '执行中 1，排队中 2，重试中 1'))` | 保留 · [#240](#case-240) task snapshot counts for active status |
| <a id='case-248'></a>248 · L255 | AgentBackgroundStatus uses foreground tracker task counts for platform status | [agent_background_status][m58] | `expect(status.state, AgentBackgroundRunState.active)`；`expect(status.toPlatformMap(), containsPair('taskSummary', 'Running 1, Pending 3, Retry 0'))` | 保留 · [#240](#case-240) task snapshot counts for active status |
| <a id='case-249'></a>249 · L286 | AgentBackgroundStatus maps foreground tracker pause to a visible paused platform status | [agent_background_status][m58] | `expect(status.state, AgentBackgroundRunState.paused)`；`expect(status.toPlatformMap(), containsPair('state', 'paused'))` | 保留 · [#248](#case-248) uses foreground tracker task counts for platform status |
| <a id='case-250'></a>250 · L317 | AgentBackgroundStatus maps foreground tracker attention to a visible needs-attention status | [agent_background_status][m58] | `expect(status.title, 'Memex Agent needs attention')`；`expect(status.toPlatformMap(), containsPair('statusText', 'Needs attention'))` | 保留 · [#249](#case-249) pause to a visible paused platform status |

</details>

<details>
<summary>test/data/services/agent_foreground_task_tracker_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-251'></a>251 · L22 | AgentForegroundTaskTracker tracks active task ids and counts current task statuses | [agent_foreground_task_tracker][m59] | `expect(snapshot.activeTaskIds, {'pending-a', 'processing-a'})`；`expect(snapshot.taskSnapshot.total, 2)` | 保留 · [#252](#case-252) removes completed tasks from tracking |
| <a id='case-252'></a>252 · L39 | AgentForegroundTaskTracker removes completed tasks from tracking | [agent_foreground_task_tracker][m59] | `expect(snapshot.activeTaskIds, isEmpty)`；`expect(snapshot.hasActiveTasks, isFalse)` | 保留 · [#253](#case-253) moves failed tracked tasks to clearable attention state |
| <a id='case-253'></a>253 · L53 | AgentForegroundTaskTracker moves failed tracked tasks to clearable attention state | [agent_foreground_task_tracker][m59] | `expect(failed.activeTaskIds, isEmpty)`；`expect(failed.attentionTaskErrors, {'task-a' : 'API key is missing'})` | 保留 · [#252](#case-252) removes completed tasks from tracking |
| <a id='case-254'></a>254 · L75 | AgentForegroundTaskTracker pauses only while tracked active tasks remain | [agent_foreground_task_tracker][m59] | `expect(paused.paused, isTrue)`；`expect(completed.activeTaskIds, isEmpty)` | 保留 · [#252](#case-252) removes completed tasks from tracking |

</details>

<details>
<summary>test/data/services/agent_queue_background_worker_test.dart · 14 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-255'></a>255 · L45 | AgentQueueBackgroundWorker recognizes both WorkManager task name and unique work name | [agent_queue_background_worker][m60] | `expect(AgentQueueBackgroundWorker.isAgentQueueDrainTask(WorkmanagerAgentQueueDrainScheduler.taskName), isTrue)`；`expect(AgentQueueBackgroundWorker.isAgentQueueDrainTask(WorkmanagerAgentQueueDrainScheduler.uniqueName), isTrue)` | 保留 · [#256](#case-256) uses KEEP for unique WorkManager drain scheduling |
| <a id='case-256'></a>256 · L66 | AgentQueueBackgroundWorker uses KEEP for unique WorkManager drain scheduling | [agent_queue_background_worker][m60] | `expect(WorkmanagerAgentQueueDrainScheduler.existingWorkPolicy, ExistingWorkPolicy.keep)` | 保留。约束唯一排队策略的默认值；没有实际调用 Android WorkManager。 · [#255](#case-255) recognizes both WorkManager task name and unique work name |
| <a id='case-257'></a>257 · L73 | AgentQueueBackgroundWorker clamps immediate retry delay to at least thirty seconds | [agent_queue_background_worker][m60] | `expect(AgentQueueBackgroundWorker.clampNextDelay(now + 10), const Duration(seconds: 30))` | 保留 · [#258](#case-258) keeps future retry delay when it is longer than the clamp |
| <a id='case-258'></a>258 · L86 | AgentQueueBackgroundWorker keeps future retry delay when it is longer than the clamp | [agent_queue_background_worker][m60] | `expect(AgentQueueBackgroundWorker.clampNextDelay(now + 600), const Duration(seconds: 600))` | 保留 · [#257](#case-257) clamps immediate retry delay to at least thirty seconds |
| <a id='case-259'></a>259 · L95 | AgentQueueBackgroundWorker does not initialize task queue when no user is active | [agent_queue_background_worker][m60] | `expect(completed, isTrue)`；`expect(platform.stopCalls, 1)` | 保留 · [#260](#case-260) retries a transient database lock before draining queue |
| <a id='case-260'></a>260 · L115 | AgentQueueBackgroundWorker retries a transient database lock before draining queue | [agent_queue_background_worker][m60] | `expect(completed, isTrue)`；`expect(platform.stopCalls, 1)` | 保留 · [#259](#case-259) does not initialize task queue when no user is active |
| <a id='case-261'></a>261 · L138 | AgentQueueBackgroundWorker reschedules soon when another executor owns the queue | [agent_queue_background_worker][m60] | `expect(snapshot.pausedMessage, UserStorage.l10n.agentBackgroundPausedDetail)`；`expect(platform.updates.single.state, AgentBackgroundRunState.paused)` | 保留 · [#264](#case-264) marks tracked foreground work paused when backgr…lice ends with work left |
| <a id='case-262'></a>262 · L187 | AgentQueueBackgroundWorker does not retry non-database initialization failures | [agent_queue_background_worker][m60] | `expect(attempts, 1)` | 保留 · [#260](#case-260) retries a transient database lock before draining queue |
| <a id='case-263'></a>263 · L204 | AgentQueueBackgroundWorker reschedules when only future retrying tasks remain | [agent_queue_background_worker][m60] | `expect(platform.updates.single.state, AgentBackgroundRunState.active)`；`expect(platform.updateBackgroundFlags.single, isTrue)` | 保留 · [#261](#case-261) soon when another executor owns the queue |
| <a id='case-264'></a>264 · L239 | AgentQueueBackgroundWorker marks tracked foreground work paused when background slice ends with work left | [agent_queue_background_worker][m60] | `expect(snapshot.pausedMessage, UserStorage.l10n.agentBackgroundPausedDetail)`；`expect(platform.updates.single.state, AgentBackgroundRunState.paused)` | 保留 · [#261](#case-261) reschedules soon when another executor owns the queue |
| <a id='case-265'></a>265 · L281 | AgentQueueBackgroundWorker drains handlers that publish agent activity after init | [agent_queue_background_worker][m60] | `expect(messages.single.title, 'Background activity')`；`expect(platform.stopCalls, 1)` | 保留 · [#266](#case-266) refreshes Android surface from live activity while task is processing |
| <a id='case-266'></a>266 · L334 | AgentQueueBackgroundWorker refreshes Android surface from live activity while task is processing | [agent_queue_background_worker][m60] | `expect(platform.updates.single.state, AgentBackgroundRunState.active)`；`expect(platform.updates.single.summary, 'worker drain')` | 保留 · [#267](#case-267) publishes each live activity update while task remains active |
| <a id='case-267'></a>267 · L392 | AgentQueueBackgroundWorker publishes each live activity update while task remains active | [agent_queue_background_worker][m60] | `expect(platform.updates.map((status) => status.summary), containsAllInOrder(['reading context', 'writing results']))`；`expect(platform.updateBackgroundFlags, everyElement(isTrue))` | 保留 · [#266](#case-266) refreshes Android surface from live activity while task is processing |
| <a id='case-268'></a>268 · L464 | AgentQueueBackgroundWorker uses latest live activity in final status when retrying work remains | [agent_queue_background_worker][m60] | `expect(platform.updates.last.stage, 'Background activity')`；`expect(platform.updateBackgroundFlags.last, isTrue)` | 保留 · [#267](#case-267) publishes each live activity update while task remains active |

</details>

<details>
<summary>test/data/services/app_action_link_service_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-269'></a>269 · L21 | AppActionLinkService consumes and clears an initial quick note link once | [app_action_link_service][m61] | `expect(readCount, 1)`；`expect(actionService.consumeIfPending(), AppActionService.quickNoteAction)` | 保留 · [#270](#case-270) forwards event stream links and ignores empty non-string events |
| <a id='case-270'></a>270 · L48 | AppActionLinkService forwards event stream links and ignores empty non-string events | [app_action_link_service][m61] | `expect(actionService.consumeIfPending(), AppActionService.quickNoteAction)` | 保留 · [#272](#case-272) dispose cancels event subscription and allows reinitialize |
| <a id='case-271'></a>271 · L73 | AppActionLinkService tolerates MissingPluginException from initial link bridge | [app_action_link_service][m61] | `expect(actionService.consumeIfPending(), isNull)` | 保留 · [#272](#case-272) dispose cancels event subscription and allows reinitialize |
| <a id='case-272'></a>272 · L91 | AppActionLinkService dispose cancels event subscription and allows reinitialize | [app_action_link_service][m61] | `expect(actionService.consumeIfPending(), AppActionService.quickNoteAction)` | 保留 · [#270](#case-270) forwards event stream links and ignores empty non-string events |

</details>

<details>
<summary>test/data/services/app_action_service_test.dart · 12 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-273'></a>273 · L18 | AppActionService dispatches a supported quick_note action | [app_action_service][m62] | `expect(service.consumeIfPending(), AppActionService.quickNoteAction)` | 保留 · [#282](#case-282) maps memex://quick_note deep link to quick_note action |
| <a id='case-274'></a>274 · L30 | AppActionService consumePendingAction returns null when no action is queued | [app_action_service][m62] | `expect(action, isNull)` | 保留 · [#277](#case-277) is idempotent after one consume |
| <a id='case-275'></a>275 · L43 | AppActionService queues a cold-start action before a listener attaches | [app_action_service][m62] | `expect(await service.consumePendingAction(timeout: const Duration(milliseconds: 1)), AppActionService.quickNoteAction)` | 保留 · [#277](#case-277) consumePendingAction is idempotent after one consume |
| <a id='case-276'></a>276 · L56 | AppActionService waits for a pending action that arrives after consumption starts | [app_action_service][m62] | `expect(await pending, AppActionService.quickNoteAction)` | 保留 · [#278](#case-278) deduplicates re-delivered action after consumption |
| <a id='case-277'></a>277 · L70 | AppActionService consumePendingAction is idempotent after one consume | [app_action_service][m62] | `expect(await service.consumePendingAction(timeout: const Duration(milliseconds: 1)), AppActionService.quickNoteAction)` | 保留 · [#274](#case-274) returns null when no action is queued |
| <a id='case-278'></a>278 · L88 | AppActionService deduplicates re-delivered action after consumption | [app_action_service][m62] | `expect(await service.consumePendingAction(timeout: const Duration(milliseconds: 1)), AppActionService.quickNoteAction)` | 保留 · [#280](#case-280) allows the same action again after the dedup window |
| <a id='case-279'></a>279 · L103 | AppActionService allows the same action again after resetConsumed | [app_action_service][m62] | `expect(service.consumeIfPending(), AppActionService.quickNoteAction)` | 保留。显式解除去重和去重窗口自然到期分别有独立触发方式。 · [#280](#case-280) the dedup window |
| <a id='case-280'></a>280 · L119 | AppActionService allows the same action again after the dedup window | [app_action_service][m62] | `expect(service.consumeIfPending(), AppActionService.quickNoteAction)` | 保留。显式解除去重和去重窗口自然到期分别有独立触发方式。 · [#279](#case-279) resetConsumed |
| <a id='case-281'></a>281 · L135 | AppActionService ignores unknown action types safely | [app_action_service][m62] | `expect(service.hasPendingAction, isFalse)` | 保留 · [#284](#case-284) deep link actions safely |
| <a id='case-282'></a>282 · L144 | AppActionService maps memex://quick_note deep link to quick_note action | [app_action_service][m62] | `expect(service.handleDeepLink('memex://quick_note'), isTrue)` | 保留 · [#283](#case-283) also accepts path-style memex:///quick_note deep link |
| <a id='case-283'></a>283 · L152 | AppActionService also accepts path-style memex:///quick_note deep link | [app_action_service][m62] | `expect(service.handleDeepLink('memex:///quick_note'), isTrue)` | 保留 · [#282](#case-282) maps memex://quick_note deep link to quick_note action |
| <a id='case-284'></a>284 · L160 | AppActionService ignores unknown deep link actions safely | [app_action_service][m62] | `expect(service.handleDeepLink('memex://unknown_action'), isFalse)`；`expect(service.handleDeepLink('https://example.com/quick_note'), isFalse)` | 保留 · [#281](#case-281) action types safely |

</details>

<details>
<summary>test/data/services/app_update_service_test.dart · 18 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-285'></a>285 · L52 | AppUpdateSettingsStore loads conservative defaults | [app_update_service][m63] | `expect(settings.autoCheckEnabled, isTrue)`；`expect(settings.lastCheckAt, isNull)` | 保留 · [#286](#case-286) persists toggles and last check time |
| <a id='case-286'></a>286 · L62 | AppUpdateSettingsStore persists toggles and last check time | [app_update_service][m63] | `expect(loaded.autoCheckEnabled, isFalse)`；`expect(loaded.lastCheckAt, DateTime.utc(2026, 5, 15, 2, 30))` | 保留 · [#285](#case-285) loads conservative defaults |
| <a id='case-287'></a>287 · L82 | release selection chooses the newest matching pre-release APK above current build | [app_update_service][m63] | `expect(update.buildNumber, 113)`；`expect(update.downloadUrl, 'https://example.com/global.apk')` | 保留 · [#289](#case-289) uses release notes version for Flutter default APK asset names |
| <a id='case-288'></a>288 · L111 | release selection returns null when matching APK is not newer | [app_update_service][m63] | `expect(update, isNull)` | 保留 · [#287](#case-287) chooses the newest matching pre-release APK above current build |
| <a id='case-289'></a>289 · L128 | release selection uses release notes version for Flutter default APK asset names | [app_update_service][m63] | `expect(update!.versionName, '1.0.30-early.20260515.abcdef0')`；`expect(update.buildNumber, 113)` | 保留 · [#287](#case-287) chooses the newest matching pre-release APK above current build |
| <a id='case-290'></a>290 · L151 | check/download/install flow still checks releases on mobile data when Wi-Fi-only is enabled | [app_update_service][m63] | `expect(settings.lastCheckAt, DateTime(2026, 5, 15, 10))` | 保留 · [#292](#case-292) detects an available update from GitHub pre-releases |
| <a id='case-291'></a>291 · L177 | check/download/install flow blocks APK download on mobile data when Wi-Fi-only is enabled | [app_update_service][m63] | `expect(() => service.downloadUpdate(update), throwsA(isA<AppUpdateWifiRequiredException>()))` | 保留 · [#290](#case-290) still checks releases on mobile data when Wi-Fi-only is enabled |
| <a id='case-292'></a>292 · L202 | check/download/install flow detects an available update from GitHub pre-releases | [app_update_service][m63] | `expect(result.status, AppUpdateCheckStatus.updateAvailable)`；`expect(settings.lastCheckAt, DateTime(2026, 5, 15, 10))` | 保留 · [#290](#case-290) still checks releases on mobile data when Wi-Fi-only is enabled |
| <a id='case-293'></a>293 · L226 | check/download/install flow downloads APK and delegates install to Android platform channel | [app_update_service][m63] | `expect(await File(download.apkPath).readAsBytes(), [1, 2, 3, 4])`；`expect(platform.installedApkPath, download.apkPath)` | 保留 · [#294](#case-294) reuses a complete downloaded APK without fetching again |
| <a id='case-294'></a>294 · L264 | check/download/install flow reuses a complete downloaded APK without fetching again | [app_update_service][m63] | `expect(download.apkPath, apk.path)`；`expect(await File(download.apkPath).readAsBytes(), [1, 2, 3, 4])` | 保留 · [#298](#case-298) redownloads when cached APK size does not match asset size |
| <a id='case-295'></a>295 · L284 | check/download/install flow coalesces concurrent downloads of the same APK | [app_update_service][m63] | `expect(downloads[0].apkPath, downloads[1].apkPath)`；`expect(await File(downloads[0].apkPath).readAsBytes(), [1, 2, 3, 4])` | 保留 · [#298](#case-298) redownloads when cached APK size does not match asset size |
| <a id='case-296'></a>296 · L328 | check/download/install flow does not clear update cache while a download is active | [app_update_service][m63] | `expect(service.hasActiveDownload, isTrue)`；`expectLater(service.clearDownloadedUpdates(), throwsA(isA<AppUpdateDownloadInProgressException>()))` | 保留 · [#299](#case-299) reports and clears downloaded update cache files |
| <a id='case-297'></a>297 · L355 | check/download/install flow deletes corrupt partial APK when downloaded size mismatches | [app_update_service][m63] | `expectLater(service.downloadUpdate(_testUpdate), throwsA(isA<AppUpdateInvalidPackageException>()))`；`expect(await File('${p.join(tempDir.path, _testUpdate.assetName)}.part').exists(), isFalse)` | 保留 · [#294](#case-294) reuses a complete downloaded APK without fetching again |
| <a id='case-298'></a>298 · L386 | check/download/install flow redownloads when cached APK size does not match asset size | [app_update_service][m63] | `expect(download.reusedExistingFile, isFalse)`；`expect(await File(download.apkPath).readAsBytes(), [1, 2, 3, 4])` | 保留 · [#294](#case-294) reuses a complete downloaded APK without fetching again |
| <a id='case-299'></a>299 · L412 | check/download/install flow reports and clears downloaded update cache files | [app_update_service][m63] | `expect(after.hasFiles, isFalse)`；`expect(await File(p.join(tempDir.path, 'notes.txt')).exists(), isTrue)` | 保留 · [#296](#case-296) does not clear update cache while a download is active |
| <a id='case-300'></a>300 · L433 | check/download/install flow opens unknown-app settings when install permission is missing | [app_update_service][m63] | `expect(result.status, AppUpdateInstallStatus.permissionRequired)`；`expect(platform.openedInstallSettings, isTrue)` | 保留 · [#302](#case-302) fails install before platform call when APK file is missing |
| <a id='case-301'></a>301 · L449 | check/download/install flow coalesces concurrent install requests for the same APK | [app_update_service][m63] | `expect(platform.installCallCount, 1)`；`expect(platform.installedApkPath, apk.path)` | 保留 · [#300](#case-300) opens unknown-app settings when install permission is missing |
| <a id='case-302'></a>302 · L467 | check/download/install flow fails install before platform call when APK file is missing | [app_update_service][m63] | `expectLater(service.installUpdate(p.join(tempDir.path, 'missing.apk')), throwsA(…sA<AppUpdateInvalidPackageException>()))`；`expect(platform.canInstallCheckCount, 0)` | 保留 · [#300](#case-300) opens unknown-app settings when install permission is missing |

</details>

<details>
<summary>test/data/services/asset_reference_service_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-303'></a>303 · L6 | AssetReferenceService.extractReferences extracts bare fs refs wrapped in markdown-style prose | [asset_reference_service][m64] | `expect(AssetReferenceService.extractReferences(text), ['fs://img_20260618_ts_0_no_1_1080x2400.jpg', 'fs://photo.jpg'])` | 保留 · [#304](#case-304) cleans file names from inline-code refs |
| <a id='case-304'></a>304 · L19 | AssetReferenceService.extractReferences cleans file names from inline-code refs | [asset_reference_service][m64] | `expect(AssetReferenceService.extractFileNameFromReference('′fs://img_20260618_ts… 'img_20260618_ts_0_no_1_1080x2400.jpg')` | 保留 · [#303](#case-303) extracts bare fs refs wrapped in markdown-style prose |

</details>

<details>
<summary>test/data/services/asset_safety_service_test.dart · 16 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-305'></a>305 · L32 | asynchronous inspection never performs synchronous file I/O | [asset_safety_service][m65] | `expect(report.width, 800)`；`expect(handle.closed, isTrue)` | 保留 · [#306](#case-306) reads safe image dimensions from headers without full decode |
| <a id='case-306'></a>306 · L46 | reads safe image dimensions from headers without full decode | [asset_safety_service][m65] | `expect(report.type, AssetSafetyType.image)`；`expect(report.safeForOcr, isTrue)` | 保留 · [#310](#case-310) blocks unknown large image from preview and analysis |
| <a id='case-307'></a>307 · L63 | marks long image unsafe while preserving metadata | [asset_safety_service][m65] | `expect(report.width, 1000)`；`expect(report.reason, contains('long edge'))` | 保留 · [#310](#case-310) blocks unknown large image from preview and analysis |
| <a id='case-308'></a>308 · L78 | marks oversized audio unsafe for cloud transcription | [asset_safety_service][m65] | `expect(report.type, AssetSafetyType.audio)`；`expect(report.reason, contains('duration'))` | 保留 · [#312](#case-312) blocks audio with unknown duration from automatic analysis |
| <a id='case-309'></a>309 · L94 | keeps narrow safe image analyzable while skipping OCR only | [asset_safety_service][m65] | `expect(report.safeForPreview, isTrue)`；`expect(report.safeForOcr, isFalse)` | 保留 · [#307](#case-307) marks long image unsafe while preserving metadata |
| <a id='case-310'></a>310 · L107 | blocks unknown large image from preview and analysis | [asset_safety_service][m65] | `expect(report.type, AssetSafetyType.image)`；`expect(report.safeForPreview, isFalse)` | 保留 · [#307](#case-307) marks long image unsafe while preserving metadata |
| <a id='case-311'></a>311 · L124 | marks small audio safe for analysis and inline agent use | [asset_safety_service][m65] | `expect(report.safeForAnalysis, isTrue)`；`expect(report.safeForInlineBase64, isTrue)` | 保留 · [#312](#case-312) blocks audio with unknown duration from automatic analysis |
| <a id='case-312'></a>312 · L138 | blocks audio with unknown duration from automatic analysis | [asset_safety_service][m65] | `expect(report.type, AssetSafetyType.audio)`；`expect(report.reason, contains('duration is unavailable'))` | 保留 · [#308](#case-308) marks oversized audio unsafe for cloud transcription |
| <a id='case-313'></a>313 · L152 | cloud transcription skips unsafe audio before LLM lookup | [asset_safety_service][m65] | `expect(result.model, 'asset-safety')`；`expect(result.usage, isNull)` | 保留。分别调用本地和云端转写入口，任一入口均可能跳过素材检查。 · [#314](#case-314) local transcription also skips unsafe audio before model lookup |
| <a id='case-314'></a>314 · L168 | local transcription also skips unsafe audio before model lookup | [asset_safety_service][m65] | `expect(result.model, 'asset-safety')`；`expect(result.usage, isNull)` | 保留。分别调用本地和云端转写入口，任一入口均可能跳过素材检查。 · [#313](#case-313) cloud transcription skips unsafe audio before LLM lookup |
| <a id='case-315'></a>315 · L185 | saveAssetFromFile keeps long image and records dimensions safely | [asset_safety_service][m65] | `expect(filename, contains('1000x13000'))`；`expect(await copied.readAsBytes(), await source.readAsBytes())` | 保留 · [#316](#case-316) MediaService imports image using safe header dimensions |
| <a id='case-316'></a>316 · L208 | MediaService imports image using safe header dimensions | [asset_safety_service][m65] | `expect(imported.absolutePath, contains('1000x13000'))`；`expect(FileSystemService.instance.toAbsolutePath(imported.relativePath), imported.absolutePath)` | 保留 · [#315](#case-315) saveAssetFromFile keeps long image and records dimensions safely |
| <a id='case-317'></a>317 · L226 | custom agent skips unsafe inline audio parts | [asset_safety_service][m65] | `expect(parts.whereType<AudioPart>(), isEmpty)` | 保留 · [#318](#case-318) image parts |
| <a id='case-318'></a>318 · L243 | custom agent skips unsafe inline image parts | [asset_safety_service][m65] | `expect(parts.whereType<ImagePart>(), isEmpty)` | 保留 · [#317](#case-317) audio parts |
| <a id='case-319'></a>319 · L261 | custom agent keeps safe inline image parts available | [asset_safety_service][m65] | `expect(parts.whereType<ImagePart>(), hasLength(1))` | 保留 · [#318](#case-318) skips unsafe inline image parts |
| <a id='case-320'></a>320 · L279 | photo suggestion skips unsafe image before MLKit processing | [asset_safety_service][m65] | `expect(result.ocrBlocks, isEmpty)`；`expect(result.modifiedTime, (await image.stat()).modified)` | 保留 · [#318](#case-318) custom agent skips unsafe inline image parts |

</details>

<details>
<summary>test/data/services/avatar_media_service_test.dart · 5 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-321'></a>321 · L29 | recognizes all imported image extensions as avatar image paths | [avatar_media_service][m66] | `expect(AvatarMediaService.isRelativeImagePath(relative), isTrue, reason: ext)` | 保留 · [#323](#case-323) keeps DiceBear seeds and remote images out of relative path resolution |
| <a id='case-322'></a>322 · L53 | resolves relative avatar media paths against current data root | [avatar_media_service][m66] | `expect(resolved, p.join(tempDir.path, relative))` | 保留 · [#321](#case-321) recognizes all imported image extensions as avatar image paths |
| <a id='case-323'></a>323 · L64 | keeps DiceBear seeds and remote images out of relative path resolution | [avatar_media_service][m66] | `expect(AvatarMediaService.isDiceBearSeed('Felix'), isTrue)`；`expect(AvatarMediaService.isRelativeImagePath(remote), isFalse)` | 保留 · [#321](#case-321) recognizes all imported image extensions as avatar image paths |
| <a id='case-324'></a>324 · L77 | caches DiceBear SVGs to application support directory | [avatar_media_service][m66] | `expect(await cached.exists(), isTrue)`；`expect(await cached.readAsString(), _svgBody)` | 保留 · [#325](#case-325) returns null without creating a cache file on download failure |
| <a id='case-325'></a>325 · L94 | returns null without creating a cache file on download failure | [avatar_media_service][m66] | `expect(await cacheFile.exists(), isFalse)` | 保留 · [#324](#case-324) caches DiceBear SVGs to application support directory |

</details>

<details>
<summary>test/data/services/backup_service_test.dart · 28 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-326'></a>326 · L66 | restore brings a deleted journal entry back to Timeline and detail | [backup_service][m67] | `expect(await getTimelineCards(tags: ['notebook']), isEmpty)`；`expect((await getCardDetail(cards.single.id)).rawContent, text)` | 保留 · [#344](#case-344) resumes a task executor that was running beforehand |
| <a id='case-327'></a>327 · L98 | createBackup writes manifest and workspace content | [backup_service][m67] | `expect(archive.files.map((file) => file.name), containsAll(['manifest.json', 'se…ings.json', 'workspace/Cards/card.md']))`；`expect(manifestJson['formatVersion'], 1)` | 保留 · [#329](#case-329) still compresses small text files |
| <a id='case-328'></a>328 · L126 | createBackup excludes device-local notification prompt state | [backup_service][m67] | `expect(settings, isNot(contains('memex_agent_notification_permission_prompted_backup-service-user')))` | 保留 · [#329](#case-329) still compresses small text files |
| <a id='case-329'></a>329 · L154 | createBackup still compresses small text files | [backup_service][m67] | `expect(utf8.decode(archivedCard.content), 'hello backup')` | 保留 · [#327](#case-327) writes manifest and workspace content |
| <a id='case-330'></a>330 · L171 | createBackup stores compressed media without recompressing | [backup_service][m67] | `expect(archivedMedia.content, await mediaFile.readAsBytes())` | 保留 · [#331](#case-331) large files without recompressing |
| <a id='case-331'></a>331 · L195 | createBackup stores large files without recompressing | [backup_service][m67] | `expect(archivedLargeFile.compression, CompressionType.none)`；`expect(largeEntry['sha256'], await _sha256File(largeFile))` | 保留 · [#330](#case-330) compressed media without recompressing |
| <a id='case-332'></a>332 · L235 | restore rejects a backup with a mismatched manifest checksum | [backup_service][m67] | `expectLater(BackupService.restoreBackup(corruptedPath), throwsA(isA<Exception>()… contains('Backup checksum mismatch'))))` | 保留 · [#327](#case-327) createBackup writes manifest and workspace content |
| <a id='case-333'></a>333 · L271 | automatic backup skips a second run within twenty-four hours | [backup_service][m67] | `expect(second, isNull)` | 保留 · [#338](#case-338) skip still prunes expired snapshots |
| <a id='case-334'></a>334 · L288 | automatic backup retention preference defaults and persists | [backup_service][m67] | `expect(await UserStorage.getAutoBackupRetentionDays('backup-service-user'), UserStorage.defaultAutoBackupRetentionDays)`；`expect(await UserStorage.getAutoBackupRetentionDays('backup-service-user'), 14)` | 保留 · [#337](#case-337) still caps forever history by total size |
| <a id='case-335'></a>335 · L326 | automatic backup retention deletes only expired automatic snapshots | [backup_service][m67] | `expect(await expired.exists(), isFalse)`；`expect(await safety.exists(), isTrue)` | 保留 · [#336](#case-336) pruning always keeps the newest snapshot |
| <a id='case-336'></a>336 · L364 | automatic backup pruning always keeps the newest snapshot | [backup_service][m67] | `expect(await newest.exists(), isTrue)`；`expect(await oldest.exists(), isFalse)` | 保留 · [#335](#case-335) retention deletes only expired automatic snapshots |
| <a id='case-337'></a>337 · L387 | automatic backup retention still caps forever history by total size | [backup_service][m67] | `expect(remainingNames, contains('memex_auto_00.memex'))`；`expect(remainingNames, isNot(contains('memex_auto_04.memex')))` | 保留 · [#335](#case-335) deletes only expired automatic snapshots |
| <a id='case-338'></a>338 · L414 | automatic backup skip still prunes expired snapshots | [backup_service][m67] | `expect(snapshot, isNull)`；`expect(await expired.exists(), isFalse)` | 保留 · [#335](#case-335) retention deletes only expired automatic snapshots |
| <a id='case-339'></a>339 · L444 | deleteStoredBackup removes only the selected local snapshot | [backup_service][m67] | `expect(remainingNames, isNot(contains(p.basename(target.path))))`；`expect(remainingNames, contains(p.basename(keepSafety.path)))` | 保留 · [#340](#case-340) delegates Android document deletion |
| <a id='case-340'></a>340 · L485 | deleteStoredBackup delegates Android document deletion | [backup_service][m67] | `expect(deletedUris, ['content://backups/auto'])` | 保留 · [#339](#case-339) removes only the selected local snapshot |
| <a id='case-341'></a>341 · L507 | restore leaves stored backup history files untouched | [backup_service][m67] | `expect(await historyAuto.exists(), isTrue)`；`expect(await File(backupPath).exists(), isTrue)` | 保留 · [#345](#case-345) removes workspace files that are not in the backup |
| <a id='case-342'></a>342 · L539 | restore stages and applies workspace files from backup | [backup_service][m67] | `expect(await cardFile.readAsString(), 'hello backup')` | 保留 · [#345](#case-345) removes workspace files that are not in the backup |
| <a id='case-343'></a>343 · L568 | restore ignores device-local state contained in an old backup | [backup_service][m67] | `expect(await UserStorage.hasPromptedMemexAgentNotificationPermission(), isFalse)` | 保留 · [#345](#case-345) removes workspace files that are not in the backup |
| <a id='case-344'></a>344 · L599 | restore resumes a task executor that was running beforehand | [backup_service][m67] | `expect(executor.isRunning, isTrue)` | 保留 · [#345](#case-345) removes workspace files that are not in the backup |
| <a id='case-345'></a>345 · L620 | restore removes workspace files that are not in the backup | [backup_service][m67] | `expect(await localBackup.exists(), isTrue)`；`expect(await File(p.join(workspace.path, 'Cards', 'card.md')).readAsString(), 'hello backup')` | 保留 · [#342](#case-342) stages and applies workspace files from backup |
| <a id='case-346'></a>346 · L654 | restore removes stale workspace links without touching their target | [backup_service][m67] | `expect(await staleLink.exists(), isFalse)` | 保留 · [#345](#case-345) workspace files that are not in the backup |
| <a id='case-347'></a>347 · L680 | restore keeps the main isolate responsive while extracting a larger backup | [backup_service][m67] | `expect(mainIsolateTicks, greaterThan(5), reason: 'Restore should yield to the main isolate during extraction.')`；`expect(await mutatedFile.openRead(0, 64).expand((bytes) => bytes).toList(), _deterministicBytes(length: 64, seed: 1))` | 保留 · [#345](#case-345) removes workspace files that are not in the backup |
| <a id='case-348'></a>348 · L738 | createBackup includes rows that were only in the WAL, and restore drops sidecars | [backup_service][m67] | `expect(rows, hasLength(1))`；`expect(rows.single.data['value'], 'kept')` | 保留 · [#345](#case-345) restore removes workspace files that are not in the backup |
| <a id='case-349'></a>349 · L810 | inspectBackup reads backup manifest metadata | [backup_service][m67] | `expect(info.manifest?.appVersion, '1.0.30')`；`expect(info.manifest?.flavor, 'globalEarly')` | 保留 · [#350](#case-350) accepts legacy backup without manifest |
| <a id='case-350'></a>350 · L833 | inspectBackup accepts legacy backup without manifest | [backup_service][m67] | `expect(info.manifest, isNull)` | 保留 · [#349](#case-349) reads backup manifest metadata |
| <a id='case-351'></a>351 · L842 | inspectBackup rejects newer backup schema | [backup_service][m67] | `expect(() => BackupService.inspectBackup(file.path), throwsA(isA<UnsupportedBackupVersionException>()))` | 保留 · [#352](#case-352) non-backup extension |
| <a id='case-352'></a>352 · L859 | inspectBackup rejects non-backup extension | [backup_service][m67] | `expect(() => BackupService.inspectBackup(file.path), throwsA(isA<InvalidBackupFileException>()))` | 保留 · [#353](#case-353) zip without backup markers |
| <a id='case-353'></a>353 · L868 | inspectBackup rejects zip without backup markers | [backup_service][m67] | `expect(() => BackupService.inspectBackup(file.path), throwsA(isA<InvalidBackupFileException>()))` | 保留 · [#352](#case-352) non-backup extension |

</details>

<details>
<summary>test/data/services/card_attachment_batch_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-354'></a>354 · L6 | mergeAttachmentsForFacts groups two queries by fact id | [card_attachment_service][m68] | `expect(merged['fact-a']!.map((item) => item.id), ['clarification_c1', 'system_action_a1'])`；`expect(merged['fact-b']!.single.id, 'system_action_a2')` | 保留 · [#355](#case-355) is stable for the same sort key |
| <a id='case-355'></a>355 · L50 | mergeAttachmentsForFacts is stable for the same sort key | [card_attachment_service][m68] | `expect(merged['fact-a']!.map((item) => item.id), ['system_action_a1', 'system_action_a2'])` | 保留 · [#356](#case-356) returns an empty map for no facts |
| <a id='case-356'></a>356 · L82 | mergeAttachmentsForFacts returns an empty map for no facts | [card_attachment_service][m68] | `expect(mergeAttachmentsForFacts(factIds: const [], actions: const [], requests: const []), isEmpty)` | 保留 · [#355](#case-355) is stable for the same sort key |

</details>

<details>
<summary>test/data/services/card_detail_notifier_test.dart · 18 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-357'></a>357 · L74 | CardDetailNotifier.computeSignals comments list length +1 triggers "comments" signal | [card_detail_notifier][m69] | `expect(signals, contains('comments'))` | 保留。增、删、编辑及整条记录插入或删除具有不同的前后快照。 · [#358](#case-358) -1 triggers "comments" signal |
| <a id='case-358'></a>358 · L91 | CardDetailNotifier.computeSignals comments list length -1 triggers "comments" signal | [card_detail_notifier][m69] | `expect(signals, contains('comments'))` | 保留。增、删、编辑及整条记录插入或删除具有不同的前后快照。 · [#357](#case-357) +1 triggers "comments" signal |
| <a id='case-359'></a>359 · L108 | CardDetailNotifier.computeSignals comment content change triggers "comments" signal | [card_detail_notifier][m69] | `expect(signals, contains('comments'))` | 保留。增、删、编辑及整条记录插入或删除具有不同的前后快照。 · [#360](#case-360) null before (insert) with comments triggers "comments" signal |
| <a id='case-360'></a>360 · L129 | CardDetailNotifier.computeSignals null before (insert) with comments triggers "comments" signal | [card_detail_notifier][m69] | `expect(signals, contains('comments'))` | 保留。增、删、编辑及整条记录插入或删除具有不同的前后快照。 · [#361](#case-361) after (delete) with comments in before triggers "comments" |
| <a id='case-361'></a>361 · L140 | CardDetailNotifier.computeSignals null after (delete) with comments in before triggers "comments" | [card_detail_notifier][m69] | `expect(signals, contains('comments'))` | 保留。增、删、编辑及整条记录插入或删除具有不同的前后快照。 · [#360](#case-360) before (insert) with comments triggers "comments" signal |
| <a id='case-362'></a>362 · L151 | CardDetailNotifier.computeSignals identical comments produce no "comments" signal | [card_detail_notifier][m69] | `expect(signals, isNot(contains('comments')))` | 保留 · [#359](#case-359) comment content change triggers "comments" signal |
| <a id='case-363'></a>363 · L162 | CardDetailNotifier.computeSignals insight text change triggers "insight" signal | [card_detail_notifier][m69] | `expect(signals, contains('insight'))` | 保留。单独改动洞察正文或摘要，任一字段漏触发都会失败。 · [#364](#case-364) summary change triggers "insight" signal |
| <a id='case-364'></a>364 · L184 | CardDetailNotifier.computeSignals insight summary change triggers "insight" signal | [card_detail_notifier][m69] | `expect(signals, contains('insight'))` | 保留。单独改动洞察正文或摘要，任一字段漏触发都会失败。 · [#363](#case-363) text change triggers "insight" signal |
| <a id='case-365'></a>365 · L204 | CardDetailNotifier.computeSignals insight related_facts reorder does NOT trigger (sorted comparison) | [card_detail_notifier][m69] | `expect(signals, isNot(contains('insight')))` | 保留 · [#366](#case-366) character_id change does NOT trigger "insight" signal |
| <a id='case-366'></a>366 · L231 | CardDetailNotifier.computeSignals insight character_id change does NOT trigger "insight" signal | [card_detail_notifier][m69] | `expect(signals, isNot(contains('insight')))` | 保留 · [#363](#case-363) text change triggers "insight" signal |
| <a id='case-367'></a>367 · L253 | CardDetailNotifier.computeSignals unrelated field-only mutations (title, tags, address, user_fixed_*) return empty set | [card_detail_notifier][m69] | `expect(signals, isEmpty)` | 保留 · [#368](#case-368) both null before and after returns empty set |
| <a id='case-368'></a>368 · L289 | CardDetailNotifier.computeSignals both null before and after returns empty set | [card_detail_notifier][m69] | `expect(signals, isEmpty)` | 保留 · [#361](#case-361) null after (delete) with comments in before triggers "comments" |
| <a id='case-369'></a>369 · L329 | CardDetailNotifier._handle branches delete op → exactly one dismissBy, zero upsert | [card_detail_notifier][m69] | `expect(fakeService.dismissByCalls, hasLength(1))`；`expect(fakeService.dismissByCalls.first['subjectKey'], 'fact-123')` | 保留 · [#371](#case-371) foreground factId + non-empty diff → dismissBy only |
| <a id='case-370'></a>370 · L347 | CardDetailNotifier._handle branches empty-diff update → zero writes | [card_detail_notifier][m69] | `expect(fakeService.upsertCalls, isEmpty)` | 保留 · [#371](#case-371) foreground factId + non-empty diff → dismissBy only |
| <a id='case-371'></a>371 · L375 | CardDetailNotifier._handle branches foreground factId + non-empty diff → dismissBy only | [card_detail_notifier][m69] | `expect(fakeService.dismissByCalls, hasLength(1))` | 保留 · [#370](#case-370) empty-diff update → zero writes |
| <a id='case-372'></a>372 · L396 | CardDetailNotifier._handle branches non-foreground + non-empty diff with no existing row → upsert with the computed signals | [card_detail_notifier][m69] | `expect(call['notificationType'], 'card_detail_update')`；`expect(fakeService.dismissByCalls, isEmpty)` | 保留 · [#373](#case-373) an existing row → upsert with set-union of stored and new signals |
| <a id='case-373'></a>373 · L421 | CardDetailNotifier._handle branches non-foreground + non-empty diff with an existing row → upsert with set-union of stored and new signals | [card_detail_notifier][m69] | `expect((payload['signals'] as List).toSet(), {'comments', 'insight'})` | 保留 · [#372](#case-372) no existing row → upsert with the computed signals |
| <a id='case-374'></a>374 · L457 | CardDetailNotifier._handle branches non-card namespace event is ignored | [card_detail_notifier][m69] | `expect(fakeService.upsertCalls, isEmpty)` | 保留 · [#370](#case-370) empty-diff update → zero writes |

</details>

<details>
<summary>test/data/services/card_files_in_date_range_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-375'></a>375 · L24 | returns yaml cards for the requested days from one month folder | [file_system_service][m46] | `expect(files.map(p.basename).toList(), ['01_ts_1.yaml', '15_ts_2.yaml'])` | 保留 · [#376](#case-376) includes the civil day after a daylight-saving fallback |
| <a id='case-376'></a>376 · L52 | includes the civil day after a daylight-saving fallback | [file_system_service][m46] | `expect(files.map(p.basename).toList(), ['25_ts_1.yaml', '26_ts_1.yaml'])` | 保留 · [#375](#case-375) returns yaml cards for the requested days from one month folder |

</details>

<details>
<summary>test/data/services/card_renderer_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-377'></a>377 · L25 | renderCard replaces fs:// urls inside legacy_html html field | [card_renderer][m70] | `expect(htmlConfig.templateId, 'legacy_html')`；`expect((html as String), allOf(contains('http://127.0.0.1:'), contains('/assets/…s_1_no_1_800.png'), contains('token=')))` | 保留 · [#379](#case-379) prefers saved HTML template over built-in template id |
| <a id='case-378'></a>378 · L69 | replaceFsInData only converts canonical fs refs | [card_renderer][m70] | `expect(imageUrls[1], allOf(isA<String>(), contains('http://127.0.0.1:'), contain…1_ts_0_no_2.HEIC'), contains('token=')))`；`expect(processed['title'], 'Umbrella')` | 保留 · 未找到同一行为的替代项 |
| <a id='case-379'></a>379 · L109 | renderCard prefers saved HTML template over built-in template id | [card_renderer][m70] | `expect(config.templateId, 'legacy_html')`；`expect(config.data['html'], contains('Rendered by the user HTML template.'))` | 保留 · [#377](#case-377) replaces fs:// urls inside legacy_html html field |

</details>

<details>
<summary>test/data/services/character_conversation_handler_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-380'></a>380 · L22 | one conversation decision writes several character bubbles | [character_conversation_handler][m71] | `expect(characterRows.map((message) => message.content), ['醒啦。', '🙂🙂'])`；`expect(characterRows.map((message) => message.contactEpisodeId).toSet(), {'character_conversation:3-5'})` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/data/services/character_conversation_service_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-381'></a>381 · L11 | consecutive user bubbles share one rescheduled reply task | [character_conversation_service][m72] | `expect(messages.map((message) => message.content), ['我刚下楼', '外面有点热', '突然想喝冰的'])`；`expect(jsonDecode(tasks.single.payload!)['character_id'], 'yaoyao')` | 保留 · [#382](#case-382) startup reconciliation rebuilds only missing workspace replies |
| <a id='case-382'></a>382 · L68 | startup reconciliation rebuilds only missing workspace replies | [character_conversation_service][m72] | `expect(task.scheduledAt, now.millisecondsSinceEpoch ~/ 1000)` | 保留 · [#381](#case-381) consecutive user bubbles share one rescheduled reply task |

</details>

<details>
<summary>test/data/services/character_execution_coordinator_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-383'></a>383 · L7 | serializes different scenes for the same character | [character_execution_coordinator][m73] | `expect(secondStarted, isTrue)` | 保留 · [#384](#case-384) does not block a different character |
| <a id='case-384'></a>384 · L38 | does not block a different character | [character_execution_coordinator][m73] | `expect(otherRan, isTrue)` | 保留 · [#383](#case-383) serializes different scenes for the same character |

</details>

<details>
<summary>test/data/services/character_history_acquaintance_handler_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-385'></a>385 · L12 | completed acquaintance retries do not run the agent again | [character_history_acquaintance_handler][m74] | `expect(runs, 1)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/data/services/character_history_acquaintance_service_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-386'></a>386 · L16 | browses existing moments and schedules acquaintance only once | [character_history_acquaintance_service][m75] | `expect(page.moments.single.factId, '2026/07/13.md#ts_1')`；`expect(await db.select(db.tasks).get(), hasLength(1))` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/data/services/character_initiative_flow_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-387'></a>387 · L20 | initiative reaches chat persistence, unread state, and the UI event | [character_initiative_handler][m76] | `expect(messages.every((message) => message.origin == PersonaChatMessageOrigin.in…acter_initiative:event-flow-1'), isTrue)`；`expect(await chatService.getUnreadCount('yaoyao'), 2)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/data/services/character_initiative_handler_test.dart · 7 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-388'></a>388 · L37 | persists one unread message turn selected by the character | [character_initiative_handler][m76] | `expect(context.characterComment, '哈哈，是的，每天都玩不够。')`；`expect(characterId, 'yaoyao')` | 保留 · [#393](#case-393) discards a proactive decision when direct chat changes mid-thought |
| <a id='case-389'></a>389 · L122 | lets the agent decide while the character owns the last chat turn | [character_initiative_handler][m76] | `expect(sent, isFalse)` | 保留 · [#391](#case-391) turns SleepUntil into an agent-chosen persistent wake |
| <a id='case-390'></a>390 · L189 | defers initiative while direct user messages await a reply | [character_initiative_handler][m76] | `expect(userId, 'user-1')`；`expect(scheduledRetryReason, contains('direct conversation'))` | 保留 · [#393](#case-393) discards a proactive decision when direct chat changes mid-thought |
| <a id='case-391'></a>391 · L295 | turns SleepUntil into an agent-chosen persistent wake | [character_initiative_handler][m76] | `expect(capturedScheduledFor, now.add(const Duration(days: 3, hours: 2)))`；`expect(await workspaceService.loadPendingThoughts('user-1', 'yaoyao'), isEmpty)` | 保留 · [#392](#case-392) ignores stale schedules and resolves a revisited thought |
| <a id='case-392'></a>392 · L365 | ignores stale schedules and resolves a revisited thought | [character_initiative_handler][m76] | `expect(context.resumedThought?.id, thought.id)`；`expect(context.pendingThoughts.map((item) => item.id), contains(thought.id))` | 保留 · [#394](#case-394) keeps a resumed thought when direct chat arrives mid-decision |
| <a id='case-393'></a>393 · L454 | discards a proactive decision when direct chat changes mid-thought | [character_initiative_handler][m76] | `expect(scheduled, isTrue)` | 保留 · [#394](#case-394) keeps a resumed thought when direct chat arrives mid-decision |
| <a id='case-394'></a>394 · L518 | keeps a resumed thought when direct chat arrives mid-decision | [character_initiative_handler][m76] | `expect(context.resumedThought?.id, thought.id)`；`expect(pendingChecks, 2)` | 保留 · [#392](#case-392) ignores stale schedules and resolves a revisited thought |

</details>

<details>
<summary>test/data/services/character_initiative_service_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-395'></a>395 · L12 | restores one wake loop and preserves an existing chosen time | [character_initiative_service][m77] | `expect(tasks.single.scheduledAt, wakeAt.millisecondsSinceEpoch ~/ 1000)`；`expect(payload['wake_reason'], '晚上想起她时，再看看要不要说句话。')` | 保留 · [#396](#case-396) conversation deferral preserves the initiative task identity |
| <a id='case-396'></a>396 · L67 | conversation deferral preserves the initiative task identity | [character_initiative_service][m77] | `expect(task.type, CharacterInitiativeService.taskType)`；`expect(task.bizId, CharacterInitiativeService.taskBizId)` | 保留 · [#395](#case-395) restores one wake loop and preserves an existing chosen time |

</details>

<details>
<summary>test/data/services/character_perception_handler_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-397'></a>397 · L39 | CharacterPerceptionTaskHandler routes once to the primary character and drains the inbox | [character_perception_handler][m78] | `expect(digested, hasLength(1))`；`expect(await workspaceService.loadPendingObservations('wujia', 'primary'), isEmpty)` | 保留 · [#398](#case-398) does nothing when no enabled primary companion exists |
| <a id='case-398'></a>398 · L81 | CharacterPerceptionTaskHandler does nothing when no enabled primary companion exists | [character_perception_handler][m78] | `expect(digesterCalled, isFalse)` | 保留 · [#397](#case-397) routes once to the primary character and drains the inbox |

</details>

<details>
<summary>test/data/services/character_service_default_seed_test.dart · 5 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-399'></a>399 · L33 | default characters store examples and interest filters separately | [character_service][m79] | `expect(auntie.persona, contains('## Voice'))`；`expect(auntie.persona, isNot(contains('## PKM Interest Filter')))` | 保留 · [#400](#case-400) seed migration refreshes legacy default auntie persona |
| <a id='case-400'></a>400 · L50 | seed migration refreshes legacy default auntie persona | [character_service][m79] | `expect(character!.persona, isNot(contains("喜欢用'哎呀'")))`；`expect(character.persona, contains('## Voice'))` | 保留 · [#401](#case-401) resolves imported HEIC avatar paths when loading characters |
| <a id='case-401'></a>401 · L78 | resolves imported HEIC avatar paths when loading characters | [character_service][m79] | `expect(character!.avatar, p.join(tempRoot.path, relativeAvatar))` | 保留 · [#400](#case-400) seed migration refreshes legacy default auntie persona |
| <a id='case-402'></a>402 · L100 | deleting a character emits a character update event | [character_service][m79] | `expect(await CharacterService.instance.deleteCharacter(userId, '3'), isTrue)`；`expect(messages.single.characterId, '3')` | 保留 · 未找到同一行为的替代项 |
| <a id='case-403'></a>403 · L130 | multi-character routing nudges multiple voices without forcing fill | [character_service][m79] | `expect(client.lastPrompt, contains('prefer selecting 2-5'))`；`expect(client.lastPrompt, contains('Do not pick only the single best fit by default'))` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/data/services/character_workspace_service_test.dart · 5 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-404'></a>404 · L37 | CharacterWorkspaceService initializes a private workspace without modeled emotional state | [character_workspace_service][m80] | `expect(identity, contains(character.persona))`；`expect(runtime.keys, isNot(contains('intimacy')))` | 保留 · 未找到同一行为的替代项 |
| <a id='case-405'></a>405 · L63 | CharacterWorkspaceService deduplicates delivery and removes raw content after digestion | [character_workspace_service][m80] | `expect(index, isNot(contains('content')))`；`expect(redelivery, isNull)` | 保留 · [#406](#case-406) character-authored PKM and journal writes are scoped and idempotent |
| <a id='case-406'></a>406 · L126 | CharacterWorkspaceService character-authored PKM and journal writes are scoped and idempotent | [character_workspace_service][m80] | `expect(pkm, contains('姐姐会把成长讲得有点难'))`；`expect(service.writePkmNote(userId: 'wujia', characterId: 'yaoyao', relativePath…content: 'escape'), throwsArgumentError)` | 保留 · [#405](#case-405) deduplicates delivery and removes raw content after digestion |
| <a id='case-407'></a>407 · L185 | CharacterWorkspaceService imports legacy configured memory without deleting the source | [character_workspace_service][m80] | `expect(await legacyMemory.exists(), isTrue)`；`expect(await legacyWorld.exists(), isTrue)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-408'></a>408 · L237 | CharacterWorkspaceService pending thoughts coalesce and can be resolved | [character_workspace_service][m80] | `expect(await service.loadPendingThoughts('wujia', 'yaoyao'), hasLength(1))`；`expect(await service.loadPendingThoughts('wujia', 'yaoyao'), isEmpty)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/data/services/chat_error_event_l10n_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-409'></a>409 · L21 | chat send errors use existing l10n strings | [chat_service][m81] | `expect(chatErrorUserNotLoggedIn(), UserStorage.l10n.userIdNotFound)`；`expect(chatErrorEmptyMessage(), UserStorage.l10n.unknownError)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-410'></a>410 · L56 | an empty saved API key is not reported as AI turned off | [chat_service][m81] | `expect(resolved.apiKey, isEmpty)`；`expect(resolved.configurationProblem, InvalidModelConfigReason.emptyApiKey)` | 保留 · [#411](#case-411) a saved config with no model still says AI is off |
| <a id='case-411'></a>411 · L119 | a saved config with no model still says AI is off | [chat_service][m81] | `expect(chatErrorOperationFailed(error!), UserStorage.l10n.invalidModelConfigPlain)` | 保留 · [#410](#case-410) an empty saved API key is not reported as AI turned off |
| <a id='case-412'></a>412 · L148 | chat network errors show the network message | [chat_service][m81] | `expect(chatErrorOperationFailed("Exception: Failed host lookup: 'api.anthropic.com'"), UserStorage.l10n.llmNetworkError)`；`expect(agentError, UserStorage.l10n.llmNetworkError)` | 保留 · [#552](#case-552) sendMessage parks the turn and shows the network message |

</details>

<details>
<summary>test/data/services/chat_run_registry_test.dart · 6 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-413'></a>413 · L7 | ActiveChatRun.attach replays missed events then continues live, no duplicates | [chat_run_registry][m82] | `expect(received, ['a', 'b', 'c'])` | 保留 · [#414](#case-414) attach after close replays buffer and completes |
| <a id='case-414'></a>414 · L26 | ActiveChatRun.attach attach after close replays buffer and completes | [chat_run_registry][m82] | `expect((events.single as ChatResponseChunkEvent).text, 'x')` | 保留 · [#413](#case-413) replays missed events then continues live, no duplicates |
| <a id='case-415'></a>415 · L37 | ActiveChatRun.attach registry tracks and removes runs on close | [chat_run_registry][m82] | `expect(registry.isActive('s3'), isFalse)` | 保留 · [#414](#case-414) attach after close replays buffer and completes |
| <a id='case-416'></a>416 · L49 | ActiveChatRun.attach getOrStart reuses active run and creates missing run | [chat_run_registry][m82] | `expect(identical(first, second), isTrue)`；`expect(registry.isActive('s5'), isTrue)` | 保留 · [#415](#case-415) registry tracks and removes runs on close |
| <a id='case-417'></a>417 · L63 | ActiveChatRun.attach multiple attachments receive the same events | [chat_run_registry][m82] | `expect((await second).length, 2)` | 保留 · [#413](#case-413) replays missed events then continues live, no duplicates |
| <a id='case-418'></a>418 · L77 | ActiveChatRun.attach non-replay events are live-only for persisted history events | [chat_run_registry][m82] | `expect(liveReceived, [liveOnlyEvent])`；`expect(replayed.single, isA<ChatResponseChunkEvent>())` | 保留 · [#417](#case-417) multiple attachments receive the same events |

</details>

<details>
<summary>test/data/services/chat_service_test.dart · 10 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-419'></a>419 · L29 | request preparation events announces text preparation before doing any user/session I/O | [chat_service][m81] | `expect((event as ChatTurnPreparingEvent).turnId, 'request-text')` | 保留 · [#420](#case-420) image preparation before trying to read the file |
| <a id='case-420'></a>420 · L41 | request preparation events announces image preparation before trying to read the file | [chat_service][m81] | `expect(event, isA<ChatTurnPreparingEvent>())` | 保留 · [#419](#case-419) text preparation before doing any user/session I/O |
| <a id='case-421'></a>421 · L50 | request preparation events rejects empty and whitespace-only requests without preparation | [chat_service][m81] | `expect(events.single, isA<ChatErrorEvent>())` | 保留 · [#420](#case-420) announces image preparation before trying to read the file |
| <a id='case-422'></a>422 · L61 | isActiveChatTurnTaskForSession matches only active chat turn tasks for the requested session | [chat_service][m81] | `expect(isActiveChatTurnTaskForSession(sessionId: 'session-a', taskType: taskType…({'session_id' : 'session-a'})), isTrue)`；`expect(isActiveChatTurnTaskForSession(sessionId: 'session-a', taskType: 'other_t…{'session_id' : 'session-a'})), isFalse)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-423'></a>423 · L147 | Super Agent state refresh creates a new agent state while preserving chat history and old state | [chat_service][m81] | `expect(sessionData['active_agent_state_session_id'], newStateId)`；`expect(newState.history.messages, isEmpty)` | 保留 · [#424](#case-424) refuses to refresh while the session has an active queued turn |
| <a id='case-424'></a>424 · L211 | Super Agent state refresh refuses to refresh while the session has an active queued turn | [chat_service][m81] | `expect(sessionData.containsKey('active_agent_state_session_id'), isFalse)` | 保留 · [#425](#case-425) migrates legacy artifacts when loading a session |
| <a id='case-425'></a>425 · L237 | Super Agent state refresh migrates legacy artifacts when loading a session | [chat_service][m81] | `expect(sessionData[ChatArtifactSessionMigration.schemaVersionKey], ChatArtifact.schemaVersion)`；`expect(artifact.sourceRunId, 'turn-legacy')` | 保留 · [#424](#case-424) refuses to refresh while the session has an active queued turn |
| <a id='case-426'></a>426 · L282 | Super Agent state refresh freezes the active agent state id into queued chat turn payload | [chat_service][m81] | `expect(queued.turnId, 'request-with-frozen-state')`；`expect(payload['agent_state_session_id'], activeStateId)` | 保留 · [#427](#case-427) queues a later Super Agent turn behind the previous terminal state |
| <a id='case-427'></a>427 · L350 | Super Agent state refresh queues a later Super Agent turn behind the previous terminal state | [chat_service][m81] | `expect(dependencies, [{'task_id' : 'failed-super-agent-turn', 'condition' : 'wait_for_completion'}])` | 保留 · [#428](#case-428) replaces a missing session id and persists the new turn |
| <a id='case-428'></a>428 · L394 | Super Agent state refresh replaces a missing session id and persists the new turn | [chat_service][m81] | `expect(newSessionId, isNot(missingSessionId))`；`expect(messages.single['content'].single['text'], 'recover this turn')` | 保留 · [#427](#case-427) queues a later Super Agent turn behind the previous terminal state |

</details>

<details>
<summary>test/data/services/chat_session_storage_test.dart · 10 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-429'></a>429 · L40 | ChatSessionStorage migrates legacy YAML to metadata JSON and message JSONL | [chat_session_storage][m45] | `expect(await File(storage.legacyYamlPath(userId, sessionId)).exists(), isFalse)`；`expect(metadata[ChatSessionStorage.storageSchemaVersionKey], ChatSessionStorage.storageSchemaVersion)` | 保留 · [#430](#case-430) recovers a legacy session after the migration marker was completed |
| <a id='case-430'></a>430 · L104 | ChatSessionStorage recovers a legacy session after the migration marker was completed | [chat_session_storage][m45] | `expect(await File(storage.legacyYamlPath(userId, sessionId)).exists(), isFalse)`；`expect(_messageText((await storage.loadMessages(userId, sessionId)).single), 'still here')` | 保留 · [#431](#case-431) session listing rescans legacy YAML after migration completion |
| <a id='case-431'></a>431 · L153 | ChatSessionStorage session listing rescans legacy YAML after migration completion | [chat_session_storage][m45] | `expect(sessions.map((session) => session['session_id']), contains(sessionId))` | 保留 · [#430](#case-430) recovers a legacy session after the migration marker was completed |
| <a id='case-432'></a>432 · L185 | ChatSessionStorage legacy message_count cleanup does not rewrite metadata again | [chat_session_storage][m45] | `expect(cleaned.containsKey('message_count'), isFalse)` | 保留 · [#433](#case-433) appends messages to JSONL and updates metadata only |
| <a id='case-433'></a>433 · L221 | ChatSessionStorage appends messages to JSONL and updates metadata only | [chat_session_storage][m45] | `expect(metadata.containsKey('messages'), isFalse)`；`expect(metadata['last_message_preview'], 'hello jsonl')` | 保留 · [#434](#case-434) recovers valid messages from an incomplete UTF-8 tail |
| <a id='case-434'></a>434 · L262 | ChatSessionStorage recovers valid messages from an incomplete UTF-8 tail | [chat_session_storage][m45] | `expect(await storage.loadMessages(userId, sessionId), hasLength(1))` | 保留 · [#433](#case-433) appends messages to JSONL and updates metadata only |
| <a id='case-435'></a>435 · L296 | ChatSessionStorage does not repair a tail while the same session is still appending | [chat_session_storage][m45] | `expect(readCompleted, isFalse)`；`expect(_messageText(messages.single), '完整回复')` | 保留 · [#434](#case-434) recovers valid messages from an incomplete UTF-8 tail |
| <a id='case-436'></a>436 · L343 | ChatSessionStorage loads paged messages from newest backwards | [chat_session_storage][m45] | `expect(latest.hasMoreMessages, isTrue)`；`expect(_messageText(older.messages[2]), startsWith('message 47 '))` | 保留 · [#437](#case-437) by complete turn groups |
| <a id='case-437'></a>437 · L393 | ChatSessionStorage loads paged messages by complete turn groups | [chat_session_storage][m45] | `expect(latest.messages.map((m) => m['turn_id']), ['turn-2', 'turn-2', 'turn-2', 'turn-3', 'turn-3', 'turn-3'])`；`expect(older.messages.map((m) => m['turn_id']), ['turn-1', 'turn-1', 'turn-1'])` | 保留 · [#436](#case-436) from newest backwards |
| <a id='case-438'></a>438 · L480 | ChatSessionStorage loads only the latest artifact revision for a recovered turn | [chat_session_storage][m45] | `expect(artifacts, hasLength(1))`；`expect(artifacts.single.updated, isTrue)` | 保留 · [#437](#case-437) paged messages by complete turn groups |

</details>

<details>
<summary>test/data/services/clipboard_preview_service_test.dart · 16 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-439'></a>439 · L61 | ClipboardPreviewService returns text clipboard candidate when it has not been handled | [clipboard_preview_service][m83] | `expect(candidate!.text, clipboardText)`；`expect(candidate.isText, isTrue)` | 保留 · [#442](#case-442) candidate from native clipboard summary |
| <a id='case-440'></a>440 · L73 | ClipboardPreviewService trims clipboard text and collapses preview whitespace | [clipboard_preview_service][m83] | `expect(candidate.previewText, 'line one line two line three')`；`expect(candidate.characterCount, candidate.text!.runes.length)` | 保留 · [#441](#case-441) keeps full plain text while bounding the preview text |
| <a id='case-441'></a>441 · L84 | ClipboardPreviewService keeps full plain text while bounding the preview text | [clipboard_preview_service][m83] | `expect(candidate.text, clipboardText)`；`expect(candidate.previewText.endsWith('...'), isTrue)` | 保留 · [#448](#case-448) uses plain text fallback only when native channel is missing |
| <a id='case-442'></a>442 · L97 | ClipboardPreviewService returns text candidate from native clipboard summary | [clipboard_preview_service][m83] | `expect(candidate!.isText, isTrue)`；`expect(candidate.text, 'Native clipboard text')` | 保留 · [#448](#case-448) uses plain text fallback only when native channel is missing |
| <a id='case-443'></a>443 · L115 | ClipboardPreviewService treats image data URI as an image candidate | [clipboard_preview_service][m83] | `expect(candidate!.isImage, isTrue)`；`expect(candidate.dataUri, clipboardText)` | 保留 · [#445](#case-445) file URI as an image candidate |
| <a id='case-444'></a>444 · L129 | ClipboardPreviewService materializes image data URI into a temporary image file | [clipboard_preview_service][m83] | `expect(candidate!.isImage, isTrue)`；`expect(image.path.endsWith('.png'), isTrue)` | 保留 · [#445](#case-445) treats image file URI as an image candidate |
| <a id='case-445'></a>445 · L144 | ClipboardPreviewService treats image file URI as an image candidate | [clipboard_preview_service][m83] | `expect(candidate.imageUri, clipboardText)`；`expect(candidate.fileName, 'memex_clipboard_image.jpg')` | 保留 · [#443](#case-443) data URI as an image candidate |
| <a id='case-446'></a>446 · L156 | ClipboardPreviewService ignores blank clipboard text | [clipboard_preview_service][m83] | `expect(await service.fetchUnhandledText(), isNull)` | 保留 · [#449](#case-449) binary-looking clipboard text from image bytes |
| <a id='case-447'></a>447 · L162 | ClipboardPreviewService skips fallback when native clipboard summary is empty | [clipboard_preview_service][m83] | `expect(await service.fetchUnhandledText(), isNull)` | 保留 · [#446](#case-446) ignores blank clipboard text |
| <a id='case-448'></a>448 · L172 | ClipboardPreviewService uses plain text fallback only when native channel is missing | [clipboard_preview_service][m83] | `expect(candidate!.isText, isTrue)`；`expect(candidate.text, clipboardText)` | 保留 · [#442](#case-442) returns text candidate from native clipboard summary |
| <a id='case-449'></a>449 · L180 | ClipboardPreviewService ignores binary-looking clipboard text from image bytes | [clipboard_preview_service][m83] | `expect(await service.fetchUnhandledText(), isNull)` | 保留 · [#446](#case-446) blank clipboard text |
| <a id='case-450'></a>450 · L188 | ClipboardPreviewService ignores replacement-heavy decoded binary clipboard text | [clipboard_preview_service][m83] | `expect(await service.fetchUnhandledText(), isNull)` | 保留 · [#449](#case-449) binary-looking clipboard text from image bytes |
| <a id='case-451'></a>451 · L194 | ClipboardPreviewService does not return the same candidate after it is marked handled | [clipboard_preview_service][m83] | `expect(candidate, isNotNull)` | 保留 · [#452](#case-452) handled clipboard hashes are scoped per user |
| <a id='case-452'></a>452 · L206 | ClipboardPreviewService handled clipboard hashes are scoped per user | [clipboard_preview_service][m83] | `expect(candidate, isNotNull)`；`expect(await service.fetchUnhandledText(), isNull)` | 保留 · [#451](#case-451) does not return the same candidate after it is marked handled |
| <a id='case-453'></a>453 · L221 | ClipboardPreviewService only suppresses the last handled clipboard token | [clipboard_preview_service][m83] | `expect(await service.fetchUnhandledText(), isNull)`；`expect(previousCandidate!.text, 'handled text 0')` | 保留 · [#446](#case-446) ignores blank clipboard text |
| <a id='case-454'></a>454 · L234 | ClipboardPreviewService marks clipboard handled when current input already contains it | [clipboard_preview_service][m83] | `expect(await service.fetchUnhandledText(), isNull)` | 保留 · [#451](#case-451) does not return the same candidate after it is marked handled |

</details>

<details>
<summary>test/data/services/document_text_extraction_service_test.dart · 7 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-455'></a>455 · L20 | extracts readable text from docx document xml | [document_text_extraction_service][m84] | `expect(extracted, contains('Text extracted from original file: notes.docx'))`；`expect(extracted, isNot(contains('Original file: ′notes.docx′')))` | 保留 · [#456](#case-456) Chinese text from docx without garbling |
| <a id='case-456'></a>456 · L46 | extracts Chinese text from docx without garbling | [document_text_extraction_service][m84] | `expect(extracted, contains('Text extracted from original file: 中文文档.docx'))`；`expect(extracted, isNot(contains('<w:')))` | 保留 · [#455](#case-455) readable text from docx document xml |
| <a id='case-457'></a>457 · L70 | extracts workbook sheets from xlsx files as markdown tables | [document_text_extraction_service][m84] | `expect(extracted, contains('Text extracted from original file: budget.xlsx'))`；`expect(extracted, contains('\| Coffee \| Rich text \| TRUE \|'))` | 保留 · [#456](#case-456) Chinese text from docx without garbling |
| <a id='case-458'></a>458 · L141 | creates an unsupported note for pdf files | [document_text_extraction_service][m84] | `expect(extracted, contains('Text extracted from original file: report.pdf'))`；`expect(extracted, isNot(contains('Hello from PDF')))` | 保留 · [#461](#case-461) a clear note for legacy xls files |
| <a id='case-459'></a>459 · L175 | does not generate helper content for directly readable text files | [document_text_extraction_service][m84] | `expect(extracted, isNull)` | 保留 · [#461](#case-461) creates a clear note for legacy xls files |
| <a id='case-460'></a>460 · L188 | creates a clear note for legacy doc files | [document_text_extraction_service][m84] | `expect(extracted, contains('legacy.doc'))` | 保留 · [#461](#case-461) xls files |
| <a id='case-461'></a>461 · L201 | creates a clear note for legacy xls files | [document_text_extraction_service][m84] | `expect(extracted, contains('legacy.xls'))` | 保留 · [#460](#case-460) doc files |

</details>

<details>
<summary>test/data/services/event_log_service_test.dart · 5 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-462'></a>462 · L9 | EventLogService stores agent-readable local time with explicit timezone | [event_log_service][m85] | `expect(events.single['event_time_local'], matches(RegExp(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [+-]\d{2}:\d{2}')))`；`expect(events.single['event_time_unix_seconds'], isA<int>())` | 保留 · [#463](#case-463) searches legacy log lines without local-time fields |
| <a id='case-463'></a>463 · L44 | EventLogService searches legacy log lines without local-time fields | [event_log_service][m85] | `expect(events.single['description'], 'legacy chat event')`；`expect(events.single.containsKey('event_time_local'), isFalse)` | 保留 · [#466](#case-466) ignores malformed json lines while keeping valid events |
| <a id='case-464'></a>464 · L81 | EventLogService reads the daylight-saving fallback day once | [event_log_service][m85] | `expect(events.single['description'], 'fallback day')` | 保留 · [#463](#case-463) searches legacy log lines without local-time fields |
| <a id='case-465'></a>465 · L117 | EventLogService applies event type, time range, and pagination filters | [event_log_service][m85] | `expect(events.single['description'], 'older chat')` | 保留 · [#464](#case-464) reads the daylight-saving fallback day once |
| <a id='case-466'></a>466 · L174 | EventLogService ignores malformed json lines while keeping valid events | [event_log_service][m85] | `expect(events.single['description'], 'valid event')` | 保留 · [#463](#case-463) searches legacy log lines without local-time fields |

</details>

<details>
<summary>test/data/services/file_import_service_test.dart · 7 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-467'></a>467 · L35 | copies arbitrary files into _UserSettings/Imported and renames conflicts | [file_import_service][m86] | `expect(result.workspaceRelativeDirectoryPath, p.join('_UserSettings', 'Imported', result.sourceName))`；`expect(result.absoluteDirectoryPath, p.join(FileSystemService.instance.getImport…Path('import-user'), result.sourceName))` | 保留 · [#472](#case-472) extracts zip files safely and skips unsafe entries |
| <a id='case-468'></a>468 · L99 | creates agent-readable extracted text files next to documents | [file_import_service][m86] | `expect(generated.relativePath, p.join('_UserSettings', 'Imported', 'report', 'report.pdf.extracted-text-for-agent.md'))`；`expect(await File(p.join(result.absoluteDirectoryPath, 'report.pdf.extracted-tex…dAsString(), contains('extracted body'))` | 保留 · [#469](#case-469) unsupported extracted text helpers for pdf files |
| <a id='case-469'></a>469 · L146 | creates unsupported extracted text helpers for pdf files | [file_import_service][m86] | `expect(result.generatedTextFileCount, 1)`；`expect(await helperFile.readAsString(), contains('Memex could not parse readable text content'))` | 保留 · [#468](#case-468) agent-readable extracted text files next to documents |
| <a id='case-470'></a>470 · L168 | creates persistent fs asset reference helpers next to imported images | [file_import_service][m86] | `expect(generated.relativePath, p.join('_UserSettings', 'Imported', 'photo', 'photo.png.asset-reference-for-agent.md'))`；`expect(helperContent, contains('Corresponding ′fs://′ reference: ′fs://'))` | 保留 · [#471](#case-471) does not create asset reference helpers for imported audio files |
| <a id='case-471'></a>471 · L225 | does not create asset reference helpers for imported audio files | [file_import_service][m86] | `expect(result.files.map((file) => file.relativePath), contains(p.join('_UserSett…gs', 'Imported', 'voice', 'voice.m4a')))`；`expect(await File(p.join(result.absoluteDirectoryPath, 'voice.m4a.asset-reference-for-agent.md')).exists(), isFalse)` | 保留 · [#470](#case-470) creates persistent fs asset reference helpers next to imported images |
| <a id='case-472'></a>472 · L258 | extracts zip files safely and skips unsafe entries | [file_import_service][m86] | `expect(result.skippedUnsafeArchiveEntries, 2)`；`expect(result.files.map((file) => file.relativePath).toList(), containsAll([p.jo…rted', 'my-export', 'folder', 'b.md')]))` | 保留 · [#471](#case-471) does not create asset reference helpers for imported audio files |
| <a id='case-473'></a>473 · L301 | super agent import message scopes processing to selected options | [file_import_service][m86] | `expect(message, contains('.extracted-text-for-agent.md'))`；`expect(message, contains('.asset-reference-for-agent.md'))` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/data/services/file_operation_service_grep_test.dart · 7 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-474'></a>474 · L45 | FileOperationService.grepFiles inline regex flags files_with_matches accepts leading (?i) | [file_operation_service][m87] | `expect(result, contains('Found 1 file'))` | 保留 · [#477](#case-477) leading (?-i) overrides the default case-insensitive search |
| <a id='case-475'></a>475 · L56 | FileOperationService.grepFiles inline regex flags content mode accepts leading (?i) with context and line numbers | [file_operation_service][m87] | `expect(result, contains('/Facts/note.md:2:Memex is local-first'))`；`expect(result, contains('/Facts/note.md:5:MemeX stylized'))` | 保留 · [#476](#case-476) count mode accepts combined leading flags and large head_limit |
| <a id='case-476'></a>476 · L75 | FileOperationService.grepFiles inline regex flags count mode accepts combined leading flags and large head_limit | [file_operation_service][m87] | `expect(result, '/Facts/note.md:3')` | 保留 · [#474](#case-474) files_with_matches accepts leading (?i) |
| <a id='case-477'></a>477 · L90 | FileOperationService.grepFiles inline regex flags leading (?-i) overrides the default case-insensitive search | [file_operation_service][m87] | `expect(defaultResult, contains('/Facts/case.md'))` | 保留 · [#474](#case-474) files_with_matches accepts leading (?i) |
| <a id='case-478'></a>478 · L134 | FileOperationService.grepFiles ripgrep engine uses real ripgrep syntax when rg is available | [file_operation_service][m87] | `expect(result, contains('/allowed.md:1:Memex mixed case'))` | 保留 · [#479](#case-479) access scope exclusions before invoking directory ripgrep |
| <a id='case-479'></a>479 · L149 | FileOperationService.grepFiles ripgrep engine uses access scope exclusions before invoking directory ripgrep | [file_operation_service][m87] | `expect(result, contains('/allowed.md'))`；`expect(result, isNot(contains('secret')))` | 保留 · [#478](#case-478) real ripgrep syntax when rg is available |
| <a id='case-480'></a>480 · L169 | FileOperationService.grepFiles ripgrep engine builds directory ripgrep args from access scope | [file_operation_service][m87] | `expect(args, contains('--no-ignore'))`；`expect(args, contains('!blocked.md/**'))` | 保留 · [#479](#case-479) uses access scope exclusions before invoking directory ripgrep |

</details>

<details>
<summary>test/data/services/file_system_service_image_source_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-481'></a>481 · L24 | converts fs asset references to local HTTP asset URLs | [file_system_service][m46] | `expect(uri.scheme, 'http')`；`expect(uri.host, '127.0.0.1')` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/data/services/file_system_service_publish_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-482'></a>482 · L41 | writing, replacing and deleting a file publish matching snapshots once | [file_system_service][m46] | `expect(await fs.safeWriteCardFile(user, id, card), isTrue)`；`expect(await fs.safeWriteCardFile(user, id, updated), isTrue)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-483'></a>483 · L74 | an unreadable card stays untouched and emits no update | [file_system_service][m46] | `fail('unreadable card was passed to updater')`；`expect(events, isEmpty)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/data/services/geocoding_service_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-484'></a>484 · L13 | Amap reverse geocoding returns a structured address when key is set | [geocoding_service][m88] | `markTestSkipped('Set AMAP_GEOCODING_TEST_KEY to run this live test.')`；`expect(result.provider, GeocodingProvider.amap)` | 保留在线验证。默认运行缺服务凭据时跳过。 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/data/services/global_event_bus_dependency_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-485'></a>485 · L27 | maps legacy EventBus dependencies to wait-for-completion barriers | [global_event_bus][m89] | `expect(_dependencyConditions(legacyWaiter.dependencies), {sourceTask.id : 'wait_…', 'base-wait' : 'wait_for_completion'})`；`expect(_dependencyConditions(hardDependent.dependencies), {sourceTask.id : 'requ…', 'base-wait' : 'wait_for_completion'})` | 保留 · [#486](#case-486) honors scheduleDelaySeconds when enqueueing async subscribers |
| <a id='case-486'></a>486 · L98 | honors scheduleDelaySeconds when enqueueing async subscribers | [global_event_bus][m89] | `expect(task.scheduledAt! >= before + 20, isTrue)` | 保留 · [#485](#case-485) maps legacy EventBus dependencies to wait-for-completion barriers |

</details>

<details>
<summary>test/data/services/health_service_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-487'></a>487 · L10 | registers only steps on Android and the HealthKit metrics on the other platform branch | [health_service][m90] | `expect(types, [HealthDataType.STEPS])` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/data/services/image_preview_cache_service_test.dart · 10 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-488'></a>488 · L23 | copies small images into the shared max768 cache path | [image_preview_cache_service][m91] | `expect(preview.file.path, endsWith(ImagePreviewCacheService.cacheFileSuffix))`；`expect(cachedAgain.cacheHit, isTrue)` | 保留 · [#490](#case-490) compresses large images into the shared max768 cache path |
| <a id='case-489'></a>489 · L59 | cached previews never re-inspect the cloud original | [image_preview_cache_service][m91] | `expect(cached.cacheHit, isTrue)`；`expect(cached.file.path, first.file.path)` | 保留 · [#493](#case-493) bypass busy workers and new generation stays bounded |
| <a id='case-490'></a>490 · L82 | compresses large images into the shared max768 cache path | [image_preview_cache_service][m91] | `expect(preview.file.path, endsWith(ImagePreviewCacheService.cacheFileSuffix))`；`expect(cachedAgain.cacheHit, isTrue)` | 保留 · [#488](#case-488) copies small images into the shared max768 cache path |
| <a id='case-491'></a>491 · L123 | a slow download does not block a local preview and duplicate work is shared | [image_preview_cache_service][m91] | `expect(identical(remote, duplicate), isTrue)`；`expect(localPreview.file.existsSync(), isTrue)` | 保留 · [#494](#case-494) failed clear does not poison later preview requests |
| <a id='case-492'></a>492 · L152 | clear waits for active work and new readers regenerate after clearing | [image_preview_cache_service][m91] | `expect(compressions, 2)` | 保留 · [#495](#case-495) removes every generated preview |
| <a id='case-493'></a>493 · L189 | cached previews bypass busy workers and new generation stays bounded | [image_preview_cache_service][m91] | `expect(gates.length, 2)`；`expect(maxActive, 2)` | 保留 · [#489](#case-489) never re-inspect the cloud original |
| <a id='case-494'></a>494 · L242 | a failed clear does not poison later preview requests | [image_preview_cache_service][m91] | `expectLater(service.clear(), throwsA(isA<FileSystemException>()))` | 保留 · [#495](#case-495) clear removes every generated preview |
| <a id='case-495'></a>495 · L261 | clear removes every generated preview | [image_preview_cache_service][m91] | `expect(await preview.file.exists(), isFalse)`；`expect(await Directory('${tempDir.path}/${ImagePreviewCacheService.cacheDirectoryName}').exists(), isFalse)` | 保留 · [#494](#case-494) a failed clear does not poison later preview requests |
| <a id='case-496'></a>496 · L290 | uses response content type for extensionless network images | [image_preview_cache_service][m91] | `expect(preview.contentType, 'image/jpeg')`；`expect(File(downloadedPath!).existsSync(), isFalse)` | 保留 · [#497](#case-497) rejects extensionless network responses without an image MIME type |
| <a id='case-497'></a>497 · L326 | rejects extensionless network responses without an image MIME type | [image_preview_cache_service][m91] | `expect(() => service.getOrCreatePreview(source: 'https://example.test/image', is…on', 'unsupported network image type')))` | 保留 · [#496](#case-496) uses response content type for extensionless network images |

</details>

<details>
<summary>test/data/services/llm_image_codec_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-498'></a>498 · L13 | isLlmSafeImageBytes accepts jpeg, png, gif, webp | [llm_image_codec][m92] | `expect(LlmImageCodec.isLlmSafeImageBytes(_bytes([0xFF, 0xD8, 0xFF])), isTrue)`；`expect(LlmImageCodec.isLlmSafeImageBytes(Uint8List.fromList([0x52, 0x49, 0x46, 0…0, 0, 0x57, 0x45, 0x42, 0x50])), isTrue)` | 保留 · [#499](#case-499) rejects heic ftyp container |
| <a id='case-499'></a>499 · L31 | isLlmSafeImageBytes rejects heic ftyp container | [llm_image_codec][m92] | `expect(LlmImageCodec.isLlmSafeImageBytes(heicHead), isFalse)` | 保留 · [#498](#case-498) accepts jpeg, png, gif, webp |

</details>

<details>
<summary>test/data/services/local_account_data_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-500'></a>500 · L38 | delete only the account workspace and exact database files, even on retry | [settings_page][m93] | `expect(await file.readAsString(), file.path)` | 保留。main 的删除账号功能在设置页；账号数据范围修复在工作分支。 · [#501](#case-501) a linked workspace container or malformed identi…each outside the account |
| <a id='case-501'></a>501 · L68 | a linked workspace container or malformed identity cannot reach outside the account | [settings_page][m93] | `expectLater(deleteLocalAccountFiles(FileSystemService.instance, 'reader'), throwsA(isA<FileSystemException>()))`；`expect(await external.readAsString(), 'outside')` | 保留。main 的删除账号功能在设置页；账号数据范围修复在工作分支。 · [#500](#case-500) delete only the account workspace and exact data…ase files, even on retry |

</details>

<details>
<summary>test/data/services/local_asset_server_image_preview_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-502'></a>502 · L42 | serves shared max768 image cache for asset HTTP requests | [local_asset_server][m94] | `expect(response.headers.toLowerCase(), contains('http/1.1 200 ok'))`；`expect(response.headers.toLowerCase(), contains('content-type: image/jpeg'))` | 保留 · [#503](#case-503) rejects encoded parent segments instead of reading outside assets |

</details>

<details>
<summary>test/data/services/local_asset_server_path_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-503'></a>503 · L22 | rejects encoded parent segments instead of reading outside assets | [local_asset_server][m94] | `expect(safeAssetRelativePath(['assets', userId, '../../secret.txt']), isNull)`；`expect(utf8.decode(doubleEncoded.body), isNot(contains('do-not-leak')))` | 保留 · [#502](#case-502) serves shared max768 image cache for asset HTTP requests |

</details>

<details>
<summary>test/data/services/local_task_executor_test.dart · 34 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-504'></a>504 · L26 | LocalTaskExecutor scheduling getLastTaskByType uses insertion order when createdAt ties | [local_task_executor][m95] | `expect(await executor.getLastTaskByType('super_agent_chat_turn_task'), 'chat-2')` | 保留 · [#509](#case-509) preserves legacy wait semantics unless a task ty…s into hard dependencies |
| <a id='case-505'></a>505 · L51 | LocalTaskExecutor scheduling scans past dependency-blocked queue head to run later tasks | [local_task_executor][m95] | `expect(blocked.status, 'pending')` | 保留 · [#512](#case-512) capped agent tasks to start other work |
| <a id='case-506'></a>506 · L99 | LocalTaskExecutor scheduling fails malformed dependencies and still runs a later valid task | [local_task_executor][m95] | `expect(malformed.error, contains('Invalid task dependencies'))` | 保留 · [#505](#case-505) scans past dependency-blocked queue head to run later tasks |
| <a id='case-507'></a>507 · L136 | LocalTaskExecutor scheduling fails a dependent task when a prerequisite failed | [local_task_executor][m95] | `expect(dependent.error, contains('failed-prerequisite'))`；`expect(jsonDecode(dependent.dependencies!), [{'task_id' : 'failed-prerequisite', 'condition' : 'requires_success'}])` | 保留 · [#508](#case-508) runs a wait-for-completion task after its predecessor failed |
| <a id='case-508'></a>508 · L175 | LocalTaskExecutor scheduling runs a wait-for-completion task after its predecessor failed | [local_task_executor][m95] | `expect(predecessor.status, 'failed')`；`expect(jsonDecode(waitingTask.dependencies!), [{'task_id' : predecessorId, 'condition' : 'wait_for_completion'}])` | 保留 · [#529](#case-529) crash loop guard clears execution marker after s…ccessful task completion |
| <a id='case-509'></a>509 · L217 | LocalTaskExecutor scheduling preserves legacy wait semantics unless a task type opts into hard dependencies | [local_task_executor][m95] | `expect(legacyHardTaskRan, isFalse)`；`expect(legacyHard.error, contains('Dependency tasks failed'))` | 保留 · [#506](#case-506) fails malformed dependencies and still runs a later valid task |
| <a id='case-510'></a>510 · L269 | LocalTaskExecutor scheduling uses only available concurrency slots while backlog remains queued | [local_task_executor][m95] | `expect(startedCount, 1)` | 保留 · [#513](#case-513) serializes tasks that share a concurrency policy key |
| <a id='case-511'></a>511 · L311 | LocalTaskExecutor scheduling caps concurrent agent-family tasks while other work can start | [local_task_executor][m95] | `expect(otherStarted, 1)` | 保留。启动队列累积与已占满两个槽位后的新增积压是不同调度状态。 · [#512](#case-512) scans past capped agent tasks to start other work |
| <a id='case-512'></a>512 · L347 | LocalTaskExecutor scheduling scans past capped agent tasks to start other work | [local_task_executor][m95] | `expect(otherStarted, 1)` | 保留。启动队列累积与已占满两个槽位后的新增积压是不同调度状态。 · [#511](#case-511) caps concurrent agent-family tasks while other work can start |
| <a id='case-513'></a>513 · L391 | LocalTaskExecutor scheduling serializes tasks that share a concurrency policy key | [local_task_executor][m95] | `expect((await _getTask(db, 'serial-2')).status, 'pending')` | 保留 · [#527](#case-527) background drain respects user-level concurrency policy |
| <a id='case-514'></a>514 · L448 | LocalTaskExecutor scheduling reports active task activity snapshot | [local_task_executor][m95] | `expect(snapshot, const TaskActivitySnapshot(pending: 1, processing: 1, retrying:…', 'processing-task', 'retrying-task'}))`；`expect(snapshot.hasActiveTasks, isTrue)` | 保留 · [#515](#case-515) runnable activity excludes dormant future tasks |
| <a id='case-515'></a>515 · L499 | LocalTaskExecutor scheduling runnable activity excludes dormant future tasks | [local_task_executor][m95] | `expect(runnableSnapshot.pending, 1)`；`expect(runnableSnapshot.activeTaskIds, {'ready-now'})` | 保留 · [#514](#case-514) reports active task activity snapshot |
| <a id='case-516'></a>516 · L525 | LocalTaskExecutor scheduling does not double-claim a task under repeated immediate polls | [local_task_executor][m95] | `expect(runCount, 1)` | 保留 · [#526](#case-526) background drain can stop an already running executor |
| <a id='case-517'></a>517 · L559 | LocalTaskExecutor scheduling background drain runs available tasks and leaves future retries | [local_task_executor][m95] | `expect(completedTaskIds, ['available-drain'])`；`expect(available.status, 'completed')` | 保留 · [#526](#case-526) can stop an already running executor |
| <a id='case-518'></a>518 · L600 | LocalTaskExecutor scheduling background drain waits for claimed task handlers before returning | [local_task_executor][m95] | `expect((await _getTask(db, 'slow-drain')).status, 'processing')`；`expect((await _getTask(db, 'slow-drain')).status, 'completed')` | 保留 · [#526](#case-526) can stop an already running executor |
| <a id='case-519'></a>519 · L642 | LocalTaskExecutor scheduling data replacement stop waits for active task handlers | [local_task_executor][m95] | `expect(executor.isRunning, isFalse)`；`expect((await _getTask(db, 'slow-restore')).status, 'completed')` | 保留 · [#520](#case-520) resumes polling when the barrier times out |
| <a id='case-520'></a>520 · L675 | LocalTaskExecutor scheduling data replacement stop resumes polling when the barrier times out | [local_task_executor][m95] | `expectLater(executor.stopAndWaitForActiveTasks(timeout: const Duration(milliseconds: 20)), throwsA(isA<StateError>()))` | 保留 · [#519](#case-519) waits for active task handlers |
| <a id='case-521'></a>521 · L706 | LocalTaskExecutor scheduling background drain does not reset already processing tasks | [local_task_executor][m95] | `expect(task.status, 'processing')` | 保留 · [#526](#case-526) can stop an already running executor |
| <a id='case-522'></a>522 · L727 | LocalTaskExecutor scheduling foreground start takes over an abandoned foreground lease | [local_task_executor][m95] | `expect(lease?.value, executor.queueOwnerValueForTesting)` | 保留 · [#524](#case-524) does not take over a fresh background lease |
| <a id='case-523'></a>523 · L741 | LocalTaskExecutor scheduling background drain does not take over a fresh foreground lease | [local_task_executor][m95] | `expect(lease?.value, 'foreground-process:foreground')`；`expect(task.status, 'pending')` | 保留 · [#524](#case-524) foreground start does not take over a fresh background lease |
| <a id='case-524'></a>524 · L771 | LocalTaskExecutor scheduling foreground start does not take over a fresh background lease | [local_task_executor][m95] | `expect(lease?.value, 'background-process:background')` | 保留 · [#523](#case-523) background drain does not take over a fresh foreground lease |
| <a id='case-525'></a>525 · L786 | LocalTaskExecutor scheduling background drain requeues orphan processing tasks | [local_task_executor][m95] | `expect(completedTaskIds, ['orphan-processing'])`；`expect(await executor.getTaskExecutionMarkerForTesting(task.id), isNull)` | 保留 · [#526](#case-526) can stop an already running executor |
| <a id='case-526'></a>526 · L815 | LocalTaskExecutor scheduling background drain can stop an already running executor | [local_task_executor][m95] | `expect(completedTaskIds, ['available-drain'])`；`expect(afterDrain.status, 'pending')` | 保留 · [#527](#case-527) respects user-level concurrency policy |
| <a id='case-527'></a>527 · L852 | LocalTaskExecutor scheduling background drain respects user-level concurrency policy | [local_task_executor][m95] | `expect((await _getTask(db, 'serial-2')).status, 'pending')`；`expect(completedTaskIds, ['serial-1', 'serial-2'])` | 保留 · [#528](#case-528) across executors |
| <a id='case-528'></a>528 · L906 | LocalTaskExecutor scheduling background drain respects user-level concurrency across executors | [local_task_executor][m95] | `expect((await _getTask(db, 'serial-cross-2')).status, 'pending')`；`expect(backgroundStarted.isCompleted, isFalse)` | 保留 · [#527](#case-527) policy |
| <a id='case-529'></a>529 · L972 | LocalTaskExecutor crash loop guard clears execution marker after successful task completion | [local_task_executor][m95] | `expect(task.status, 'completed')`；`expect(await executor.getTaskExecutionMarkerForTesting(), isNull)` | 保留 · [#530](#case-530) when Dart handler failure is retryable |
| <a id='case-530'></a>530 · L992 | LocalTaskExecutor crash loop guard clears execution marker when Dart handler failure is retryable | [local_task_executor][m95] | `expect(task.error, contains('boom'))`；`expect(await executor.getTaskExecutionMarkerForTesting(), isNull)` | 保留 · [#529](#case-529) after successful task completion |
| <a id='case-531'></a>531 · L1019 | LocalTaskExecutor crash loop guard first crash-like restart requeues stale processing task | [local_task_executor][m95] | `expect(markerPayload['task_id'], task.id)`；`expect(markerPayload['crash_count'], 1)` | 保留 · [#535](#case-535) second crash-like restart fails task and clears marker |
| <a id='case-532'></a>532 · L1041 | LocalTaskExecutor crash loop guard graceful app exit requeues stale task without crash count | [local_task_executor][m95] | `expect(await executor.getTaskExecutionMarkerForTesting(task.id), isNull)`；`expect(await executor.getGracefulExitMarkerForTesting(), isNull)` | 保留 · [#531](#case-531) first crash-like restart requeues stale processing task |
| <a id='case-533'></a>533 · L1063 | LocalTaskExecutor crash loop guard keeps separate crash markers for concurrent processing tasks | [local_task_executor][m95] | `expect(crashCounts[taskA.id], 1)`；`expect(crashCounts[taskB.id], 1)` | 保留 · [#531](#case-531) first crash-like restart requeues stale processing task |
| <a id='case-534'></a>534 · L1101 | LocalTaskExecutor crash loop guard simulates process death while a real task execution is in progress | [local_task_executor][m95] | `expect(updated.error, contains('crash-like exits'))`；`expect(await executor.getTaskExecutionMarkerForTesting(taskId), isNull)` | 保留 · [#529](#case-529) clears execution marker after successful task completion |
| <a id='case-535'></a>535 · L1161 | LocalTaskExecutor crash loop guard second crash-like restart fails task and clears marker | [local_task_executor][m95] | `expect(updated.error, contains('crash-like exits'))`；`expect(await executor.getTaskExecutionMarkerForTesting(), isNull)` | 保留 · [#531](#case-531) first crash-like restart requeues stale processing task |
| <a id='case-536'></a>536 · L1182 | LocalTaskExecutor crash loop guard bad dependency JSON fails task instead of leaving it pending forever | [local_task_executor][m95] | `expect(await executor.getTaskExecutionMarkerForTesting(), isNull)` | 保留 · [#535](#case-535) second crash-like restart fails task and clears marker |
| <a id='case-537'></a>537 · L1203 | LocalTaskExecutor crash loop guard reschedules one waiting task per business key | [local_task_executor][m95] | `expect(secondId, firstId)`；`expect(jsonDecode(tasks.single.payload!)['revision'], 2)` | 保留 · [#531](#case-531) first crash-like restart requeues stale processing task |

</details>

<details>
<summary>test/data/services/memex_cloud_service_l10n_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-538'></a>538 · L15 | auth and payment fallbacks resolve from l10n after init | [memex_cloud_service][m96] | `expect(UserStorage.l10n.usernameAlreadyTaken, 'Username already taken')`；`expect(UserStorage.l10n.paymentCreationFailed, 'Could not start payment')` | 保留英文注册、登录与付款失败的语言资源断言。用例仅读取本地化文本，未请求云服务。 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/data/services/migration_state_service_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-539'></a>539 · L28 | MigrationStateService marks successful migrations and skips later runs | [migration_state_service][m97] | `expect(await MigrationStateService.instance.isCompleted(userId, 'test_success_v1'), isTrue)`；`expect(state['updated_at'], isA<String>())` | 保留 · [#540](#case-540) does not mark incomplete migrations |
| <a id='case-540'></a>540 · L64 | MigrationStateService does not mark incomplete migrations | [migration_state_service][m97] | `expect(incompleteResult, isFalse)`；`expect(await MigrationStateService.instance.isCompleted(userId, 'test_retry_v1'), isTrue)` | 保留 · [#539](#case-539) marks successful migrations and skips later runs |

</details>

<details>
<summary>test/data/services/model_role_config_service_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-541'></a>541 · L31 | ModelRoleConfigService findConfig handles empty inputs and normalizes keys | [model_role_config_service][m98] | `expect(ModelRoleConfigService.findConfig(const [], textConfig.key), isNull)`；`expect(ModelRoleConfigService.findConfig(const [textConfig], 'missing'), isNull)` | 保留 · [#542](#case-542) loadSelection and setters normalize primary model keys |
| <a id='case-542'></a>542 · L59 | ModelRoleConfigService loadSelection and setters normalize primary model keys | [model_role_config_service][m98] | `expect(resetSelection.textConfigKey, textConfig.key)` | 保留 · [#541](#case-541) findConfig handles empty inputs and normalizes keys |

</details>

<details>
<summary>test/data/services/native_action_service_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-543'></a>543 · L15 | forwards calendar events to the native system action channel | [native_action_service][m99] | `expect(success, isTrue)`；`expect(received!.method, 'addCalendarEvent')` | 保留 · [#544](#case-544) reminders to the native system action channel |
| <a id='case-544'></a>544 · L45 | forwards reminders to the native system action channel | [native_action_service][m99] | `expect(success, isTrue)`；`expect(received!.arguments, {'title' : 'Call the dentist', 'dueDate' : due.milli…'notes' : 'Ask about the next checkup'})` | 保留 · [#545](#case-545) reports native channel failures without throwing |
| <a id='case-545'></a>545 · L69 | reports native channel failures without throwing | [native_action_service][m99] | `expect(success, isFalse)` | 保留 · [#544](#case-544) forwards reminders to the native system action channel |

</details>

<details>
<summary>test/data/services/native_photo_picker_service_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-546'></a>546 · L16 | returns ordered selections including photos outside library permission | [native_photo_picker_service][m100] | `expect(photos.map((photo) => photo.id), ['first', 'limited'])`；`expect(photos.last.assetId, isNull)` | 保留 · [#547](#case-547) cancelling leaves selection empty |
| <a id='case-547'></a>547 · L32 | cancelling leaves selection empty | [native_photo_picker_service][m100] | `expect((await NativePhotoPickerService.pick()).valueOrThrow, isEmpty)` | 保留 · [#546](#case-546) returns ordered selections including photos outside library permission |
| <a id='case-548'></a>548 · L38 | preview is available while export waits; failed export can retry | [native_photo_picker_service][m100] | `expect(vm.items.single.preview, [1, 2, 3])`；`expect(vm.canSubmit, isFalse)` | 保留 · [#549](#case-549) deduplicates by library id and ignores removed late exports |
| <a id='case-549'></a>549 · L82 | deduplicates by library id and ignores removed late exports | [native_photo_picker_service][m100] | `expect(vm.items, hasLength(1))`；`expect(released, containsAll(['a', 'b']))` | 保留 · [#548](#case-548) preview is available while export waits; failed export can retry |

</details>

<details>
<summary>test/data/services/notifications_before_login_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-550'></a>550 · L6 | service methods return sentinels when DB is not initialized | [user_notification_service][m101] | `expect(AppDatabase.isInitialized, isFalse, reason: 'No AppDatabase.init() was called, so isInitialized should be false')`；`expect(rows, isEmpty)` | 保留 · [#624](#case-624) UserNotificationService dismiss dismissBy(triple… deletes exactly one row |

</details>

<details>
<summary>test/data/services/oauth_missing_code_page_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-551'></a>551 · L15 | OAuth missing-code page uses unknownError | [local_server_service][m102] | `expect(oauthMissingCodePage(), UserStorage.l10n.unknownError)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/data/services/offline_capture_queue_test.dart · 8 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-552'></a>552 · L53 | sendMessage parks the turn and shows the network message | [chat_service][m81] | `expect(events.whereType<ChatErrorEvent>().single.error, UserStorage.l10n.llmNetworkError)`；`expect(tasks.single.status, waitingNetworkTaskStatus)` | 保留 · [#558](#case-558) a resumed turn does not mint a card after the original was deleted |
| <a id='case-553'></a>553 · L91 | a local endpoint is not parked when public DNS fails | [chat_service][m81] | `expect(tasks.single.status, 'pending')`；`expect(cardFiles, isEmpty)` | 保留 · [#427](#case-427) Super Agent state refresh queues a later Super A… previous terminal state |
| <a id='case-554'></a>554 · L128 | connection refused ends failed instead of waiting for network | [chat_service][m81] | `expect(failed.retryCount, 0)` | 保留 · [#555](#case-555) a host lookup failure waits, then runs when the network returns |
| <a id='case-555'></a>555 · L156 | a host lookup failure waits, then runs when the network returns | [chat_service][m81] | `expect(runs, 1)`；`expect(runs, 2)` | 保留 · [#554](#case-554) connection refused ends failed instead of waiting for network |
| <a id='case-556'></a>556 · L191 | private endpoints and offline errors are classified apart | [network_reachability][m103] | `expect(isPrivateModelEndpoint('http://127.0.0.1:11434/v1'), isTrue)`；`expect(isPrivateModelEndpoint('http://localhost:11434/v1'), isTrue)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-557'></a>557 · L230 | deleting a waiting card cancels its turn and lets the next one run | [chat_service][m81] | `expect((await getTimelineCards()).map((card) => card.id), [factId])`；`expect(await _cardFiles(), isEmpty)` | 保留 · [#558](#case-558) a resumed turn does not mint a card after the original was deleted |
| <a id='case-558'></a>558 · L280 | a resumed turn does not mint a card after the original was deleted | [chat_service][m81] | `expect(await _cardFiles(), isEmpty)` | 保留 · [#557](#case-557) deleting a waiting card cancels its turn and lets the next one run |
| <a id='case-559'></a>559 · L311 | a text-only reply removes the empty offline placeholder | [chat_service][m81] | `expect(isUnusedPreallocatedRecordPlaceholder(waiting, factId), isTrue)`；`expect(await FileSystemService.instance.readCardFile('offline-capture-user', factId), isNull)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/data/services/persona_chat_conversation_storage_test.dart · 16 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-560'></a>560 · L31 | PersonaChatConversationStorage stores only messages and commits a multi-bubble turn once | [persona_chat_conversation_storage][m104] | `expect(metadata.lastTurnId, 'character_conversation:1-1')`；`expect(File(fileSystem.getCharacterConversationPendingCommitPath(_userId, _characterId)).existsSync(), isFalse)` | 保留 · [#562](#case-562) recovers an interrupted turn after messagesAppended |
| <a id='case-561'></a>561 · L106 | PersonaChatConversationStorage finds an older committed turn without a receipt or duplicate | [persona_chat_conversation_storage][m104] | `expect(await storage.tryAppendInitiativeTurn(userId: _userId, characterId: _char…r('retry must not regenerate')), isTrue)`；`expect(Directory(fileSystem.getCharacterConversationPath(_userId, _characterId))…ryElement(isNot(contains('_episodes'))))` | 保留 · [#570](#case-570) clear changes generation and never reuses a message id |
| <a id='case-562'></a>562 · L178 | PersonaChatConversationStorage recovers an interrupted turn after messagesAppended | [persona_chat_conversation_storage][m104] | `expect(() => interrupted.appendTurn(userId: _userId, characterId: _characterId, …ssageId + 1, '第三句')]), throwsStateError)`；`expect(messages.reversed.map((record) => record.content), ['第一句', '第二句', '第三句'])` | 保留。各自在不同持久化边界中断，分别验证提交和清空的恢复。 · [#564](#case-564) pendingWritten |
| <a id='case-563'></a>563 · L178 | PersonaChatConversationStorage recovers an interrupted turn after metadataWritten | [persona_chat_conversation_storage][m104] | `expect(() => interrupted.appendTurn(userId: _userId, characterId: _characterId, …ssageId + 1, '第三句')]), throwsStateError)`；`expect(File(fileSystem.getCharacterConversationPendingCommitPath(_userId, _characterId)).existsSync(), isFalse)` | 保留。各自在不同持久化边界中断，分别验证提交和清空的恢复。 · [#564](#case-564) pendingWritten |
| <a id='case-564'></a>564 · L178 | PersonaChatConversationStorage recovers an interrupted turn after pendingWritten | [persona_chat_conversation_storage][m104] | `expect(() => interrupted.appendTurn(userId: _userId, characterId: _characterId, …ssageId + 1, '第三句')]), throwsStateError)`；`expect(File(fileSystem.getCharacterConversationPendingCommitPath(_userId, _characterId)).existsSync(), isFalse)` | 保留。各自在不同持久化边界中断，分别验证提交和清空的恢复。 · [#563](#case-563) metadataWritten |
| <a id='case-565'></a>565 · L244 | PersonaChatConversationStorage replays a partially appended batch from its write-ahead file | [persona_chat_conversation_storage][m104] | `expect(messages.map((record) => record.id).toSet(), {1, 2, 3})`；`expect(await _messagesFile(fileSystem).readAsLines(), hasLength(3))` | 保留 · [#562](#case-562) recovers an interrupted turn after messagesAppended |
| <a id='case-566'></a>566 · L295 | PersonaChatConversationStorage serializes writers and allocates one ordered message id | [persona_chat_conversation_storage][m104] | `expect(messages.map((record) => record.id).toSet(), {for (var id = 1; id <= 12; id++) id})`；`expect((await storage.loadMetadata(userId: _userId, characterId: _characterId)).nextMessageId, 13)` | 保留 · [#569](#case-569) keeps read and agent-processing boundaries outside messages |
| <a id='case-567'></a>567 · L331 | PersonaChatConversationStorage repairs derived metadata after an unindexed single append | [persona_chat_conversation_storage][m104] | `expect(metadata.nextMessageId, 3)`；`expect(metadata.messagesByteLength, await file.length())` | 保留 · [#569](#case-569) keeps read and agent-processing boundaries outside messages |
| <a id='case-568'></a>568 · L366 | PersonaChatConversationStorage truncates an incomplete UTF-8 tail without losing valid history | [persona_chat_conversation_storage][m104] | `expect(second.single.content, '保留中文')` | 保留 · [#564](#case-564) recovers an interrupted turn after pendingWritten |
| <a id='case-569'></a>569 · L387 | PersonaChatConversationStorage keeps read and agent-processing boundaries outside messages | [persona_chat_conversation_storage][m104] | `expect(await storage.markAllRead(userId: _userId, characterId: _characterId), 1)`；`expect((await storage.loadMessages(userId: _userId, characterId: _characterId)).first.isRead, isTrue)` | 保留 · [#566](#case-566) serializes writers and allocates one ordered message id |
| <a id='case-570'></a>570 · L434 | PersonaChatConversationStorage clear changes generation and never reuses a message id | [persona_chat_conversation_storage][m104] | `expect(await storage.clearConversation(userId: _userId, characterId: _characterI….parse('2026-07-15T10:00:00+08:00')), 1)`；`expectLater(storage.appendTurn(userId: _userId, characterId: _characterId, turnI…sageId, '不应出现的旧回复')]), throwsStateError)` | 保留 · [#566](#case-566) serializes writers and allocates one ordered message id |
| <a id='case-571'></a>571 · L497 | PersonaChatConversationStorage recovers an interrupted clear after messagesAppended | [persona_chat_conversation_storage][m104] | `expectLater(interrupted.clearConversation(userId: _userId, characterId: _charact…-15T10:00:00+08:00')), throwsStateError)`；`expect(await recovered.loadMessages(userId: _userId, characterId: _characterId), isEmpty)` | 保留。各自在不同持久化边界中断，分别验证提交和清空的恢复。 · [#573](#case-573) pendingWritten |
| <a id='case-572'></a>572 · L497 | PersonaChatConversationStorage recovers an interrupted clear after metadataWritten | [persona_chat_conversation_storage][m104] | `expectLater(interrupted.clearConversation(userId: _userId, characterId: _charact…-15T10:00:00+08:00')), throwsStateError)`；`expect(metadata.nextMessageId, before.nextMessageId)` | 保留。各自在不同持久化边界中断，分别验证提交和清空的恢复。 · [#573](#case-573) pendingWritten |
| <a id='case-573'></a>573 · L497 | PersonaChatConversationStorage recovers an interrupted clear after pendingWritten | [persona_chat_conversation_storage][m104] | `expectLater(interrupted.clearConversation(userId: _userId, characterId: _charact…-15T10:00:00+08:00')), throwsStateError)`；`expect(metadata.nextMessageId, before.nextMessageId)` | 保留。各自在不同持久化边界中断，分别验证提交和清空的恢复。 · [#572](#case-572) metadataWritten |
| <a id='case-574'></a>574 · L542 | PersonaChatConversationStorage recovers an interrupted legacy snapshot import | [persona_chat_conversation_storage][m104] | `expectLater(interrupted.importLegacySnapshot(userId: _userId, characterId: _char…oughUserMessageId: 1), throwsStateError)`；`expect(await recovered.getReplyCursor(userId: _userId, characterId: _characterId), 1)` | 保留 · [#564](#case-564) turn after pendingWritten |
| <a id='case-575'></a>575 · L597 | PersonaChatConversationStorage rejects character ids that escape the workspace | [persona_chat_conversation_storage][m104] | `expect(() => fileSystem.getCharacterConversationPath(_userId, '../outside'), throwsArgumentError)` | 保留 · [#561](#case-561) finds an older committed turn without a receipt or duplicate |

</details>

<details>
<summary>test/data/services/persona_chat_workspace_recovery_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-576'></a>576 · L44 | persona chat workspace recovery imports legacy SQLite once, including its reply cursor | [persona_chat_service][m105] | `expect(await chat.getReplyCursor(characterId), 1)`；`expect(migrationState, isNot(contains('persona_chat_workspace_v2')))` | 保留 · [#577](#case-577) runtime conversation remains available after SQLite is wiped |
| <a id='case-577'></a>577 · L105 | persona chat workspace recovery runtime conversation remains available after SQLite is wiped | [persona_chat_service][m105] | `expect(await chat.getPendingUserMessages(characterId), isEmpty)` | 保留 · [#578](#case-578) retried multi-bubble turns are idempotent |
| <a id='case-578'></a>578 · L129 | persona chat workspace recovery retried multi-bubble turns are idempotent | [persona_chat_service][m105] | `expect(await speak(), [2, 3])`；`expect(await db.select(db.personaChatMessages).get(), isEmpty)` | 保留 · [#577](#case-577) runtime conversation remains available after SQLite is wiped |

</details>

<details>
<summary>test/data/services/photo_attachment_service_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-579'></a>579 · L10 | shares a pending original export and retains its original filename | [photo_attachment_service][m106] | `expect(isOrigin, isTrue)`；`expect(result.originalName, 'IMG_001.HEIC')` | 保留 · [#580](#case-580) preserves fallback file behavior and handles missing filename metadata |
| <a id='case-580'></a>580 · L33 | preserves fallback file behavior and handles missing filename metadata | [photo_attachment_service][m106] | `expect(result.path, '/tmp/fallback.jpg')`；`expect(result.originalName, 'fallback.jpg')` | 保留 · [#579](#case-579) shares a pending original export and retains its original filename |
| <a id='case-581'></a>581 · L51 | a removed system photo returns an error instead of a thumbnail attachment | [photo_attachment_service][m106] | `expect((await service.prepareAsset('missing')).isError, isTrue)` | 保留 · [#580](#case-580) preserves fallback file behavior and handles missing filename metadata |

</details>

<details>
<summary>test/data/services/photo_suggestion_cancellation_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-582'></a>582 · L6 | cancels every registered native request exactly once | [photo_suggestion_service][m107] | `expect(token.registerNativeRequest(first), isTrue)`；`expect(token.registerNativeRequest(second), isTrue)` | 保留 · [#584](#case-584) immediately rejects and cancels requests registered after cancellation |
| <a id='case-583'></a>583 · L24 | does not cancel a native request after it is unregistered | [photo_suggestion_service][m107] | `expect(token.registerNativeRequest(request), isTrue)` | 保留 · [#582](#case-582) cancels every registered native request exactly once |
| <a id='case-584'></a>584 · L39 | immediately rejects and cancels requests registered after cancellation | [photo_suggestion_service][m107] | `expect(cancelled, [request])` | 保留 · [#582](#case-582) cancels every registered native request exactly once |

</details>

<details>
<summary>test/data/services/photo_thumbnail_service_test.dart · 6 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-585'></a>585 · L16 | uses a cancellable single-result iOS delivery mode | [photo_thumbnail_service][m108] | `expect(option.toMap()['deliveryMode'], DeliveryMode.highQualityFormat.index)`；`expect(option.toMap()['resizeContentMode'], ResizeContentMode.fill.index)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-586'></a>586 · L33 | preheats only newly published Apple picker assets | [photo_thumbnail_service][m108] | `expect(calls.first.option.toMap()['deliveryMode'], DeliveryMode.opportunistic.index)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-587'></a>587 · L55 | bounds concurrent native thumbnail requests | [photo_thumbnail_service][m108] | `expect(completers.keys, containsAll(['first', 'second']))`；`expect(completers, isNot(contains('third')))` | 保留 · [#590](#case-590) serves successful thumbnail bytes from the LRU cache |
| <a id='case-588'></a>588 · L90 | shares requests and cancels native work after the last release | [photo_thumbnail_service][m108] | `expect(loadCount, 1)`；`expect(await second.future, isNull)` | 保留 · [#590](#case-590) serves successful thumbnail bytes from the LRU cache |
| <a id='case-589'></a>589 · L119 | removes cancelled queued work before it reaches the loader | [photo_thumbnail_service][m108] | `expect(await queued.future, isNull)` | 保留 · [#588](#case-588) shares requests and cancels native work after the last release |
| <a id='case-590'></a>590 · L144 | serves successful thumbnail bytes from the LRU cache | [photo_thumbnail_service][m108] | `expect(await service.request(asset('cached')).future, [7])`；`expect(loadCount, 1)` | 保留 · [#588](#case-588) shares requests and cancels native work after the last release |

</details>

<details>
<summary>test/data/services/pkm_recent_listing_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-591'></a>591 · L5 | reuses a fresh listing for the same user | [pkm_recent_listing][m109] | `expect(shouldReuseRecentPkmCache(cache: cache, userId: 'u1', now: cachedAt.add(const Duration(seconds: 5))), isTrue)`；`expect(shouldReuseRecentPkmCache(cache: cache, userId: 'u1', now: cachedAt.add(c…onds: 1)), forceRefresh: true), isFalse)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-592'></a>592 · L58 | a listing started earlier does not overwrite a newer generation | [pkm_recent_listing][m109] | `expect(shouldStoreRecentPkmResult(startedGeneration: 1, currentGeneration: 2), isFalse)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-593'></a>593 · L69 | detects PKM workspace files for cache invalidation | [pkm_recent_listing][m109] | `expect(isPkmWorkspaceFile('/workspace/_u1/Cards/2026/01/01.yaml'), isFalse)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/data/services/sandbox_user_clone_service_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-594'></a>594 · L36 | clones workspace content while skipping agent runtime state | [sandbox_user_clone_service][m110] | `expect(await File(p.join(targetWorkspace.path, '_System', 'state_dir', 'agent.json')).exists(), isFalse)`；`expect(result.skippedPaths, contains('_System/state_dir'))` | 保留 · [#597](#case-597) overwrites named test workspace when requested |
| <a id='case-595'></a>595 · L93 | uses short default test username | [sandbox_user_clone_service][m110] | `expect(await Directory(p.join(tempDir.path, 'workspace', '_test')).exists(), isTrue)` | 保留 · [#596](#case-596) increments short default test username when it already exists |
| <a id='case-596'></a>596 · L106 | increments short default test username when it already exists | [sandbox_user_clone_service][m110] | `expect(await Directory(p.join(tempDir.path, 'workspace', '_test2')).exists(), isTrue)` | 保留 · [#595](#case-595) uses short default test username |
| <a id='case-597'></a>597 · L123 | overwrites named test workspace when requested | [sandbox_user_clone_service][m110] | `expect(result.targetUserId, 'test')`；`expect(await File(p.join(existingTarget.path, 'Cards', 'card.yaml')).exists(), isTrue)` | 保留 · [#595](#case-595) uses short default test username |

</details>

<details>
<summary>test/data/services/search_service_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-598'></a>598 · L7 | SearchService FTS enqueue filtering skips card updates when only comments change | [search_service][m53] | `expect(SearchService.instance.shouldEnqueueFtsIndexUpdateForTesting(record), isFalse)` | 保留 · [#600](#case-600) enqueues card updates when indexed fields change |
| <a id='case-599'></a>599 · L36 | SearchService FTS enqueue filtering enqueues card updates when fact changes | [search_service][m53] | `expect(SearchService.instance.shouldEnqueueFtsIndexUpdateForTesting(record), isTrue)` | 保留。分别只改正文和标题，避免其中一个字段漏更新全文索引。 · [#600](#case-600) indexed fields change |
| <a id='case-600'></a>600 · L59 | SearchService FTS enqueue filtering enqueues card updates when indexed fields change | [search_service][m53] | `expect(SearchService.instance.shouldEnqueueFtsIndexUpdateForTesting(record), isTrue)` | 保留。分别只改正文和标题，避免其中一个字段漏更新全文索引。 · [#599](#case-599) fact changes |

</details>

<details>
<summary>test/data/services/sqlite_busy_retry_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-601'></a>601 · L9 | SqliteBusyRetry recognizes common SQLite busy error variants | [sqlite_busy_retry][m111] | `expect(SqliteBusyRetry.isDatabaseLocked(Exception('SqliteException(5): database is locked (code 5)')), isTrue)`；`expect(SqliteBusyRetry.isDatabaseLocked(Exception('SQLITE_ERROR: bad sql')), isFalse)` | 保留 · [#603](#case-603) does not retry non-lock failures |
| <a id='case-602'></a>602 · L26 | SqliteBusyRetry retries database locks with linear backoff and returns success | [sqlite_busy_retry][m111] | `expect(attempts, 3)` | 保留 · [#603](#case-603) does not retry non-lock failures |
| <a id='case-603'></a>603 · L49 | SqliteBusyRetry does not retry non-lock failures | [sqlite_busy_retry][m111] | `expectLater(SqliteBusyRetry.run<void>(operation: 'test non-lock', logger: logger… state');}), throwsA(isA<StateError>()))` | 保留 · [#604](#case-604) rethrows the final database lock failure |
| <a id='case-604'></a>604 · L67 | SqliteBusyRetry rethrows the final database lock failure | [sqlite_busy_retry][m111] | `expectLater(SqliteBusyRetry.run<void>(operation: 'test exhausted lock', logger: … locked');}), throwsA(isA<Exception>()))` | 保留 · [#603](#case-603) does not retry non-lock failures |

</details>

<details>
<summary>test/data/services/super_agent_chat_turn_resume_test.dart · 5 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-605'></a>605 · L39 | Super Agent chat turn rescheduling a late completion cannot clear the newer turn on disk | [chat_service][m81] | `expect(await chat.prepareChatTurn(state, sessionId: session, turnId: 'new'), isFalse)`；`expect((await loadOrCreateAgentState(session, null)).metadata.containsKey(_runningTurnIdKey), isFalse)` | 保留 · [#607](#case-607) processing task reset to pending resumes without duplicating user |
| <a id='case-606'></a>606 · L58 | Super Agent chat turn rescheduling normal processing persists one user message | [chat_service][m81] | `expect(_userMessageCount(state), 1)`；`expect(state.metadata.containsKey(_runningTurnIdKey), isFalse)` | 保留 · [#607](#case-607) processing task reset to pending resumes without duplicating user |
| <a id='case-607'></a>607 · L82 | Super Agent chat turn rescheduling processing task reset to pending resumes without duplicating user | [chat_service][m81] | `expect((await _getTask(db, 'processing-task')).status, 'completed')`；`expect(state.metadata.containsKey(_runningTurnIdKey), isFalse)` | 保留 · [#606](#case-606) normal processing persists one user message |
| <a id='case-608'></a>608 · L111 | Super Agent chat turn rescheduling retrying after partial commit resumes without duplicating user | [chat_service][m81] | `expect(state.metadata.containsKey(_runningTurnIdKey), isFalse)`；`expect(retryAttempt.requestUserCounts, [1])` | 保留 · [#609](#case-609) first LLM failure resumes without duplicating user |
| <a id='case-609'></a>609 · L155 | Super Agent chat turn rescheduling retrying after first LLM failure resumes without duplicating user | [chat_service][m81] | `expect(firstAttempt.requestUserCounts, [1])`；`expect(state.metadata.containsKey(_runningTurnIdKey), isFalse)` | 保留 · [#608](#case-608) partial commit resumes without duplicating user |

</details>

<details>
<summary>test/data/services/system_action_service_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-610'></a>610 · L28 | SystemActionService action center dismiss hides pending actions without rejecting source visibility | [system_action_service][m27] | `expect(await SystemActionService.instance.getPending(), isEmpty)`；`expect(visibleForFact.single.status, 'dismissed')` | 保留 · [#611](#case-611) hard rejection removes actions from fact visibility |
| <a id='case-611'></a>611 · L54 | SystemActionService hard rejection removes actions from fact visibility | [system_action_service][m27] | `expect(await SystemActionService.instance.getVisibleForFact('2026/05/25.md#ts_7'), isEmpty)` | 保留 · [#610](#case-610) action center dismiss hides pending actions with…ecting source visibility |
| <a id='case-612'></a>612 · L77 | SystemActionService applies a valid event through the native bridge and completes it | [system_action_service][m27] | `expect((await SystemActionService.instance.getAction(action.id))!.status, 'completed')`；`expect(await SystemActionService.instance.getPending(), isEmpty)` | 保留 · [#613](#case-613) rejects malformed action data before calling the native bridge |
| <a id='case-613'></a>613 · L109 | SystemActionService rejects malformed action data before calling the native bridge | [system_action_service][m27] | `expect(nativeCallCount, 0)`；`expect((await SystemActionService.instance.getAction(action.id))!.status, 'pending')` | 保留 · [#612](#case-612) applies a valid event through the native bridge and completes it |

</details>

<details>
<summary>test/data/services/task_handlers/comment_reply_target_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-614'></a>614 · L38 | resolveReplyTargetCharacterId direct reply to an AI comment uses that character | [comment_agent_handler][m112] | `expect(resolveReplyTargetCharacterId(comments, 'b1'), 'char-b')` | 保留 · [#615](#case-615) reply to a user comment walks the chain to the thread owner |
| <a id='case-615'></a>615 · L43 | resolveReplyTargetCharacterId reply to a user comment walks the chain to the thread owner | [comment_agent_handler][m112] | `expect(resolveReplyTargetCharacterId(comments, 'u2'), 'char-a')` | 保留 · [#614](#case-614) direct reply to an AI comment uses that character |
| <a id='case-616'></a>616 · L48 | resolveReplyTargetCharacterId unknown or cyclic reply ids return null | [comment_agent_handler][m112] | `expect(resolveReplyTargetCharacterId(comments, 'missing'), isNull)` | 保留 · [#614](#case-614) direct reply to an AI comment uses that character |

</details>

<details>
<summary>test/data/services/timeline_card_event_publisher_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-617'></a>617 · L30 | emits a processing placeholder without rendering templates | [timeline_card_event_publisher][m113] | `expect(message.status, 'processing')`；`expect(message.rawText, 'Just captured.')` | 保留 · [#619](#case-619) card added with rendered card fields |
| <a id='case-618'></a>618 · L62 | emits removal for an unused processing placeholder | [timeline_card_event_publisher][m113] | `expect((messages.single as CardRemovedMessage).id, cardId)` | 保留 · [#617](#case-617) a processing placeholder without rendering templates |
| <a id='case-619'></a>619 · L76 | emits card added with rendered card fields | [timeline_card_event_publisher][m113] | `expect(messages.single, isA<CardAddedMessage>())`；`expect(message.id, cardId)` | 保留 · [#617](#case-617) a processing placeholder without rendering templates |
| <a id='case-620'></a>620 · L114 | emits card updated with failure reason | [timeline_card_event_publisher][m113] | `expect(messages.single, isA<CardUpdatedMessage>())`；`expect(message.failureReason, 'tool failed')` | 保留 · [#619](#case-619) added with rendered card fields |

</details>

<details>
<summary>test/data/services/user_notification_service_test.dart · 6 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-621'></a>621 · L21 | UserNotificationService upsert first upsert inserts a new row | [user_notification_service][m101] | `expect(rows.first.userId, 'user-a')`；`expect(rows.first.notificationType, 'card_detail_update')` | 保留 · [#623](#case-623) dismiss dismiss(id) deletes exactly one row |
| <a id='case-622'></a>622 · L44 | UserNotificationService upsert second upsert with same triple updates in place, bumps updatedAt, does NOT add a row | [user_notification_service][m101] | `expect(rows.first.createdAt, 1)`；`expect(rows.first.updatedAt, greaterThan(rows.first.createdAt))` | 保留 · [#623](#case-623) dismiss dismiss(id) deletes exactly one row |
| <a id='case-623'></a>623 · L91 | UserNotificationService dismiss dismiss(id) deletes exactly one row | [user_notification_service][m101] | `expect(rows.first.subjectKey, 'fact-2')` | 保留。按通知 ID 与按三字段组合删除为两个公开入口。 · [#624](#case-624) dismissBy(triple) deletes exactly one row |
| <a id='case-624'></a>624 · L116 | UserNotificationService dismiss dismissBy(triple) deletes exactly one row | [user_notification_service][m101] | `expect(rows.first.subjectKey, 'fact-2')` | 保留。按通知 ID 与按三字段组合删除为两个公开入口。 · [#623](#case-623) dismiss(id) deletes exactly one row |
| <a id='case-625'></a>625 · L147 | UserNotificationService list list(userA) never returns userB rows | [user_notification_service][m101] | `expect(rowsB, hasLength(1))`；`expect((await service.list(userId: 'user-b')).single.id, rowsB.single.id)` | 保留 · [#623](#case-623) dismiss dismiss(id) deletes exactly one row |
| <a id='case-626'></a>626 · L180 | UserNotificationService list list with notificationType filter works | [user_notification_service][m101] | `expect(filtered.first.notificationType, 'card_detail_update')`；`expect(all, hasLength(2))` | 保留 · [#623](#case-623) dismiss dismiss(id) deletes exactly one row |

</details>

<details>
<summary>test/data/services/user_stats_service_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-627'></a>627 · L33 | aggregates user-facing stats from cards and event logs | [user_stats_service][m114] | `expect(snapshot.summary.totalCards, 2)`；`expect(may18.cards, 1)` | 保留 · [#628](#case-628) falls back to local files when activity events are unavailable |
| <a id='case-628'></a>628 · L198 | falls back to local files when activity events are unavailable | [user_stats_service][m114] | `expect(snapshot.dayDetails['2026-05-18']!.knowledgePaths, contains('PKM/Areas/health.md'))`；`expect(snapshot.dayDetails['2026-05-18']!.insightTitles, contains('Health week'))` | 保留 · [#627](#case-627) aggregates user-facing stats from cards and event logs |
| <a id='case-629'></a>629 · L253 | keeps every civil day across the spring-forward | [user_stats_service][m114] | `expect(snapshot.daily.map((point) => point.date).toList(), [DateTime(2026, 3, 27…Time(2026, 4, 1), DateTime(2026, 4, 2)])` | 保留 · [#628](#case-628) falls back to local files when activity events are unavailable |

</details>

<details>
<summary>test/db/app_database_connection_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-630'></a>630 · L9 | AppDatabase connection options requests shared connections for native isolates | [app_database][m115] | `expect(AppDatabase.nativeOptionsForTesting.shareAcrossIsolates, isTrue)` | 保留。检查原生连接的跨 isolate 配置；数据库日志模式和 busy timeout 由 [#631](#case-631) 在真实连接上读回。 · [#631](#case-631) configures WAL and busy timeout on native SQLite connections |
| <a id='case-631'></a>631 · L13 | AppDatabase connection options configures WAL and busy timeout on native SQLite connections | [app_database][m115] | `expect(busyTimeout, 5000)` | 保留 · [#630](#case-630) requests shared connections for native isolates |

</details>

<details>
<summary>test/db/app_database_migration_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-632'></a>632 · L11 | AppDatabase migrations upgrades schema 14 to 19 with a reply cursor baseline | [app_database][m115] | `expect(schemaVersion, 19)`；`expect(cursor.consumedThroughMessageId, 1)` | 保留 · [#633](#case-633) 18 without consuming its pending user message |
| <a id='case-633'></a>633 · L57 | AppDatabase migrations upgrades schema 18 without consuming its pending user message | [app_database][m115] | `expect(await _userVersion(db), 19)`；`expect(pending.map((message) => message.content), ['pending user message'])` | 保留 · [#632](#case-632) 14 to 19 with a reply cursor baseline |

</details>

<details>
<summary>test/db/user_notifications_migration_test.dart · 5 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-634'></a>634 · L43 | UserNotifications migration table is queryable after creation | [app_database][m115] | `expect(rows, isEmpty)` | 删除。[#635](#case-635) 在真实生产库写入并读回一行，覆盖表缺失。 · [#635](#case-635) can insert and query a notification row |
| <a id='case-635'></a>635 · L49 | UserNotifications migration can insert and query a notification row | [app_database][m115] | `expect(rows.first.userId, 'user-a')`；`expect(rows.first.notificationType, 'card_detail_update')` | 改用实际 AppDatabase 建表及索引，去掉测试自建索引。 · [#621](#case-621) UserNotificationService upsert first upsert inserts a new row |
| <a id='case-636'></a>636 · L75 | UserNotifications migration payload column is nullable | [app_database][m115] | `expect(rows.first.payload, isNull)` | 改用实际 AppDatabase 建表及索引，去掉测试自建索引。 · [#635](#case-635) can insert and query a notification row |
| <a id='case-637'></a>637 · L94 | UserNotifications migration UNIQUE index rejects duplicate (userId, notificationType, subjectKey) triple | [app_database][m115] | `expect(() => db.into(db.userNotifications).insert(UserNotificationsCompanion.ins… now)), throwsA(isA<SqliteException>()))` | 改用实际 AppDatabase 建表及索引，去掉测试自建索引。 · [#638](#case-638) allows different triples |
| <a id='case-638'></a>638 · L129 | UserNotifications migration UNIQUE index allows different triples | [app_database][m115] | `expect(rows, hasLength(3))` | 改用实际 AppDatabase 建表及索引，去掉测试自建索引。 · [#637](#case-637) rejects duplicate (userId, notificationType, subjectKey) triple |

</details>

<details>
<summary>test/domain/models/character_editor_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-639'></a>639 · L5 | character draft snapshots mutable editor collections | [character_editor][m116] | `expect(draft.tags, ['朋友'])`；`expect(draft.memoryEntries.single['content'], '喜欢被叫姐姐')` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/domain/models/character_message_test.dart · 5 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-640'></a>640 · L6 | recognizes emoji-only bubbles without treating mixed text as emoji | [character_message][m117] | `expect(isEmojiOnlyMessage('🙂'), isTrue)`；`expect(isEmojiOnlyMessage('1️⃣2'), isFalse)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-641'></a>641 · L19 | maps stable agent emoji ids to Unicode and Fluent assets | [character_message][m117] | `expect(CharacterEmoji.fromAgentId('warm_smile'), CharacterEmoji.warmSmile)`；`expect(CharacterEmoji.fromAgentId('unknown'), isNull)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-642'></a>642 · L30 | classifies text and appends the selected Fluent emoji gesture | [character_message][m117] | `expect(messages[0], CharacterOutgoingMessage.text('早点睡。'))`；`expect(messages.map((message) => message.storageType), [PersonaChatMessageTypes.…s.emoji, PersonaChatMessageTypes.emoji])` | 保留 · [#643](#case-643) supports an emoji-only reply and rejects an unknown emoji id |
| <a id='case-643'></a>643 · L56 | supports an emoji-only reply and rejects an unknown emoji id | [character_message][m117] | `expect(() => parseCharacterOutgoingMessages(null, emojiId: 'not_supported'), throwsArgumentError)` | 保留 · [#642](#case-642) classifies text and appends the selected Fluent emoji gesture |
| <a id='case-644'></a>644 · L67 | fails when Speak contains neither text nor an emoji gesture | [character_message][m117] | `expect(() => parseCharacterOutgoingMessages([{'type' : 'emoji'}, null, '']), throwsArgumentError)` | 保留 · [#642](#case-642) classifies text and appends the selected Fluent emoji gesture |

</details>

<details>
<summary>test/domain/models/character_workspace_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-645'></a>645 · L5 | character observation round-trips its one-time source material | [character_workspace][m118] | `expect(restored.id, observation.id)`；`expect(restored.sourceEventId, 'event-1')` | 保留 · 未找到同一行为的替代项 |
| <a id='case-646'></a>646 · L27 | runtime contains only operational cursors | [character_workspace][m118] | `expect(runtime.toJson().keys, isNot(contains('mood')))`；`expect(runtime.toJson().keys, isNot(contains('desire')))` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/domain/models/event_bus_message_test.dart · 5 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-647'></a>647 · L5 | parses profile update messages from event payloads | [event_bus_message][m119] | `expect(parsed, isA<ProfileUpdatedMessage>())`；`expect(message.type, EventBusMessageType.profileUpdated)` | 保留 · [#648](#case-648) character update messages from event payloads |
| <a id='case-648'></a>648 · L21 | parses character update messages from event payloads | [event_bus_message][m119] | `expect(message.type, EventBusMessageType.characterUpdated)`；`expect(message.characterId, 'mentor')` | 保留 · [#647](#case-647) profile update messages from event payloads |
| <a id='case-649'></a>649 · L37 | parses persona chat unread change messages | [event_bus_message][m119] | `expect(parsed, isA<PersonaChatUnreadChangedMessage>())`；`expect(message.type, EventBusMessageType.personaChatUnreadChanged)` | 保留 · [#648](#case-648) character update messages from event payloads |
| <a id='case-650'></a>650 · L49 | parses backup snapshot change messages from event payloads | [event_bus_message][m119] | `expect(message.type, EventBusMessageType.backupSnapshotsChanged)`；`expect(message.snapshotId, 'memex_auto_2026.memex')` | 保留 · [#651](#case-651) restored messages from event payloads |
| <a id='case-651'></a>651 · L65 | parses backup restored messages from event payloads | [event_bus_message][m119] | `expect(parsed, isA<BackupRestoredMessage>())`；`expect(message.type, EventBusMessageType.backupRestored)` | 保留 · [#648](#case-648) character update messages from event payloads |

</details>

<details>
<summary>test/domain/models/llm_config_test.dart · 12 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-652'></a>652 · L21 | LLMConfig.duplicate creates copy with "_copy" suffix when no conflict | [llm_config][m120] | `expect(duplicated.key, 'my-config_copy')`；`expect(duplicated.topP, baseConfig.topP)` | 保留 · [#653](#case-653) appends _copy_2 when "_copy" already exists |
| <a id='case-653'></a>653 · L36 | LLMConfig.duplicate appends _copy_2 when "_copy" already exists | [llm_config][m120] | `expect(duplicated.key, 'my-config_copy_2')` | 保留 · [#655](#case-655) does not modify the original config |
| <a id='case-654'></a>654 · L43 | LLMConfig.duplicate increments counter until unique key is found | [llm_config][m120] | `expect(duplicated.key, 'my-config_copy_4')` | 保留 · [#655](#case-655) does not modify the original config |
| <a id='case-655'></a>655 · L54 | LLMConfig.duplicate does not modify the original config | [llm_config][m120] | `expect(duplicated.key, isNot(baseConfig.key))` | 保留 · [#653](#case-653) appends _copy_2 when "_copy" already exists |
| <a id='case-656'></a>656 · L60 | LLMConfig.duplicate handles keys with special characters gracefully | [llm_config][m120] | `expect(duplicated.key, 'config-v1.2_test_copy')` | 保留 · [#655](#case-655) does not modify the original config |
| <a id='case-657'></a>657 · L74 | DeepSeek provider uses official OpenAI-compatible API defaults | [llm_config][m120] | `expect(LLMConfig.providerDisplayName(LLMConfig.typeDeepSeek), 'DeepSeek')`；`expect(LLMConfig.modelsEndpoint(LLMConfig.typeDeepSeek, 'https://api.deepseek.com'), 'https://api.deepseek.com/models')` | 保留 · [#658](#case-658) recommends current official model IDs |
| <a id='case-658'></a>658 · L96 | DeepSeek provider recommends current official model IDs | [llm_config][m120] | `expect(LLMConfig.featuredModels(LLMConfig.typeDeepSeek), {'deepseek-v4-flash', 'deepseek-v4-pro'})` | 保留 · [#662](#case-662) current model recommendations includes the lates…els for hosted providers |
| <a id='case-659'></a>659 · L107 | DeepSeek provider requires an API key and base URL | [llm_config][m120] | `expect(validConfig.copyWith(apiKey: '').isValid, isFalse)`；`expect(validConfig.copyWith(apiKey: '').configurationProblem, InvalidModelConfigReason.emptyApiKey)` | 保留 · [#658](#case-658) recommends current official model IDs |
| <a id='case-660'></a>660 · L132 | current model recommendations uses the canonical GPT-5.6 Sol ID for new global configurations | [llm_config][m120] | `expect(LLMConfig.createDefaultClientConfig().modelId, 'gpt-5.6-sol')`；`expect(LLMConfig.featuredModels(LLMConfig.typeResponses), containsAll(['gpt-5.6-sol', 'gpt-5.6-terra', 'gpt-5.6-luna']))` | 保留 · [#661](#case-661) keeps OpenAI recommendations current and endpoint-specific |
| <a id='case-661'></a>661 · L146 | current model recommendations keeps OpenAI recommendations current and endpoint-specific | [llm_config][m120] | `expect(chatModels, isNot(contains('gpt-5.5-pro')))`；`expect([...chatModels, ...responseModels], isNot(contains(startsWith('gpt-5.4'))))` | 保留 · [#660](#case-660) uses the canonical GPT-5.6 Sol ID for new global configurations |
| <a id='case-662'></a>662 · L168 | current model recommendations includes the latest frontier models for hosted providers | [llm_config][m120] | `expect(LLMConfig.featuredModels(entry.key), contains(entry.value), reason: '${en…hould badge its current recommendation')` | 保留 · [#663](#case-663) recognizes multimodal models added to the recommendations |
| <a id='case-663'></a>663 · L198 | current model recommendations recognizes multimodal models added to the recommendations | [llm_config][m120] | `expect(LLMConfig.isKnownMultimodal(LLMConfig.typeZhipu, 'glm-5.2'), isFalse)` | 保留 · [#662](#case-662) includes the latest frontier models for hosted providers |

</details>

<details>
<summary>test/domain/models/location_context_config_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-664'></a>664 · L6 | LocationContextConfig defaults to disabled until the user opts in | [location_context_config][m121] | `expect(LocationContextConfig.fromJson(const {}).enabled, isFalse)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-665'></a>665 · L13 | GeocodedAddress summary respects configured granularity | [location_context_config][m121] | `expect(address.summary(LocationContextGranularity.city), '上海市')`；`expect(address.summary(LocationContextGranularity.full), '上海市徐汇区武康路')` | 保留 · 未找到同一行为的替代项 |
| <a id='case-666'></a>666 · L39 | CurrentLocationContext fresh reminder tells the agent to prefer current location | [location_context_config][m121] | `expect(reminder, contains('current_location_context'))`；`expect(reminder, contains('Prefer current_location_context'))` | 保留 · [#667](#case-667) GPS-only context is not injected into agent prompts |
| <a id='case-667'></a>667 · L64 | CurrentLocationContext fresh GPS-only context is not injected into agent prompts | [location_context_config][m121] | `expect(context.toAgentSystemReminderContent(), isNull)` | 保留 · [#666](#case-666) reminder tells the agent to prefer current location |

</details>

<details>
<summary>test/domain/models/timeline_card_visibility_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-668'></a>668 · L7 | isRetiredTimelineCard recognizes the legacy schedule briefing id | [timeline_card_visibility][m122] | `expect(isRetiredTimelineCard(_card(id: retiredScheduleBriefingCardId, templateId: 'classic_card')), isTrue)` | 保留 · [#669](#case-669) legacy schedule briefing template copies |
| <a id='case-669'></a>669 · L19 | isRetiredTimelineCard recognizes legacy schedule briefing template copies | [timeline_card_visibility][m122] | `expect(isRetiredTimelineCard(_card(id: 'legacy-schedule-copy', templateId: retiredScheduleBriefingTemplateId)), isTrue)` | 保留 · [#668](#case-668) the legacy schedule briefing id |
| <a id='case-670'></a>670 · L31 | isRetiredTimelineCard keeps normal timeline cards visible | [timeline_card_visibility][m122] | `expect(isRetiredTimelineCard(_card(id: '2026/07/27.md#ts_1', templateId: 'classic_card')), isFalse)` | 保留 · [#668](#case-668) recognizes the legacy schedule briefing id |

</details>

<details>
<summary>test/domain/models/user_stats_model_test.dart · 5 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-671'></a>671 · L6 | lastDays stays on civil dates across the spring-forward | [user_stats_model][m123] | `expect(range.start, DateTime(2026, 3, 27))`；`expect(civilDaysInclusive(range.start, range.end).last, DateTime(2026, 4, 2))` | 保留 · 未找到同一行为的替代项 |
| <a id='case-672'></a>672 · L21 | inclusive civil end stays on the fall-back day | [user_stats_model][m123] | `expect(DateTime(bound.year, bound.month, bound.day), end)`；`expect(bound.isAfter(byDuration), isTrue)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-673'></a>673 · L38 | UserStatsSnapshot trend buckets uses daily buckets for shorter ranges | [user_stats_model][m123] | `expect(snapshot.preferredTrendBucketSizeDays, 1)`；`expect(snapshot.maxTrendValueFor(UserStatsMetric.inputs), 30)` | 保留 · [#674](#case-674) groups ninety-day ranges into seven-day buckets |
| <a id='case-674'></a>674 · L51 | UserStatsSnapshot trend buckets groups ninety-day ranges into seven-day buckets | [user_stats_model][m123] | `expect(snapshot.preferredTrendBucketSizeDays, 7)`；`expect(snapshot.maxTrendValueFor(UserStatsMetric.inputs), 567)` | 保留 · [#673](#case-673) uses daily buckets for shorter ranges |
| <a id='case-675'></a>675 · L69 | UserStatsSnapshot trend buckets combines and deduplicates details for a bucket | [user_stats_model][m123] | `expect(detail.date, DateTime(2026, 1, 1))`；`expect(detail.completedTodoTitles, ['Todo 0', 'Todo 1'])` | 保留 · [#673](#case-673) uses daily buckets for shorter ranges |

</details>

<details>
<summary>test/domain/models/vocal_tone_test.dart · 7 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-676'></a>676 · L7 | SenseVoice angry tag becomes a tone and unknown tags do not | [vocal_tone][m124] | `expect(vocalToneFromSenseVoice(emotion: 'EMO_UNKNOWN', event: 'Speech'), isNull)`；`expect(vocalToneFromSenseVoice(emotion: '', event: ''), isNull)` | 保留 · [#677](#case-677) laughter and crying events count when emotion is missing |
| <a id='case-677'></a>677 · L20 | laughter and crying events count when emotion is missing | [vocal_tone][m124] | `expect(vocalToneFromSenseVoice(emotion: '', event: '<\|Cry\|>')?.moodCode, 'crying')` | 保留 · [#676](#case-676) SenseVoice angry tag becomes a tone and unknown tags do not |
| <a id='case-678'></a>678 · L31 | a disabled setting never asks the cloud model | [vocal_tone][m124] | `expect(text, 'I went to the garage.')` | 保留 · [#680](#case-680) failed cloud description leaves the transcript alone |
| <a id='case-679'></a>679 · L46 | an on device tone is kept and the cloud is not called | [vocal_tone][m124] | `expect(text, 'I went to the garage.\n\nangry/high')` | 保留 · [#678](#case-678) a disabled setting never asks the cloud model |
| <a id='case-680'></a>680 · L62 | a failed cloud description leaves the transcript alone | [vocal_tone][m124] | `expect(text, 'I went to the garage.')` | 保留 · [#678](#case-678) disabled setting never asks the cloud model |
| <a id='case-681'></a>681 · L74 | a cloud tone block is parsed and appended | [vocal_tone][m124] | `expect(parsed?.moodCode, 'tired')`；`expect(parsed?.energyCode, 'low')` | 保留 · [#680](#case-680) failed cloud description leaves the transcript alone |
| <a id='case-682'></a>682 · L98 | a cloud reply without a tone block is ignored | [vocal_tone][m124] | `expect(parseCloudVocalTone('the speaker sounds fine'), isNull)` | 保留 · [#681](#case-681) tone block is parsed and appended |

</details>

<details>
<summary>test/integration/card_detail_notification_e2e_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-683'></a>683 · L63 | published comment and insight merge into the same inbox row | [card_detail_notifier][m69] | `expect(first.subjectKey, card)`；`expect(jsonDecode(updated.payload!)['signals'], ['comments', 'insight'])` | 保留 · [#685](#case-685) PKM changes and title-only changes leave the inbox empty |
| <a id='case-684'></a>684 · L74 | viewing and deleting a card clear only its notification | [card_detail_notifier][m69] | `expect((await inbox()).map((n) => n.subjectKey), contains(card))`；`expect((await inbox('other')).single.subjectKey, card)` | 保留 · [#371](#case-371) CardDetailNotifier._handle branches foreground f…ty diff → dismissBy only |
| <a id='case-685'></a>685 · L94 | PKM changes and title-only changes leave the inbox empty | [card_detail_notifier][m69] | `expect((await inbox()).single.subjectKey, card)`；`expect(await inbox(), isEmpty)` | 保留 · [#683](#case-683) published comment and insight merge into the same inbox row |

</details>

<details>
<summary>test/integration/character_companion_pipeline_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-686'></a>686 · L21 | record becomes character memory, initiative, and reply context | [character_workspace_service][m80] | `expect(memory, contains('常常聊到长大'))`；`expect(proactiveMessages.every((message) => message.origin == PersonaChatMessageOrigin.initiative), isTrue)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/integration/character_conversation_pipeline_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-687'></a>687 · L25 | consecutive sends become one durable multi-bubble conversation turn | [persona_chat_service][m105] | `expect(context.incomingMessages.map((message) => message.content), ['我刚下楼', '外面有点热', '突然想喝冰的'])`；`expect(tasks.single.status, 'completed')` | 保留 · [#688](#case-688) initiative yields one pending user turn to the direct reply task |
| <a id='case-688'></a>688 · L136 | initiative yields one pending user turn to the direct reply task | [persona_chat_service][m105] | `expect(await chatService.getReplyCursor(character.id), userMessageId)`；`expect(await chatService.getPendingUserMessages(character.id), isEmpty)` | 保留 · [#687](#case-687) consecutive sends become one durable multi-bubble conversation turn |
| <a id='case-689'></a>689 · L363 | initiative commit cannot overtake a pending direct message | [persona_chat_service][m105] | `expect(committedWhilePending, isFalse)`；`expect(characterMessage.origin, PersonaChatMessageOrigin.initiative)` | 保留 · [#688](#case-688) yields one pending user turn to the direct reply task |

</details>

<details>
<summary>test/integration/local_workspace_screens_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-690'></a>690 · L138 | post a comment in detail and read it after reopening the screen | [timeline_card_detail_screen][m125] | `expect(tester.widget<SwitchListTile>(tile).value, isFalse)`；`expect(posted, findsWidgets)` | 保留。从详情输入、提交、退出再打开验证留言可见，补足服务层覆盖不到的入口。 · [#216](#case-216) open a listed entry, post and reply, then reopen the correct thread |
| <a id='case-691'></a>691 · L238 | search the knowledge base and open the matching Markdown document | [knowledge_base_screen][m126] | 打开搜索命中的文件页后，等到正文中出现 Hawthorn blossoms beside the river. | 保留。从知识库搜索框输入关键词，点开实际 Markdown 页面并等到正文。 · [#898](#case-898) root listing helpers keep non-PARA folders and root files |
| <a id='case-692'></a>692 · L277 | send a photo offline, replay the queued turn and read the same note and attachment in detail | [agent_chat_dialog][m127] | `expect(detail.rawContent, note)`；`expect(closed, isTrue, reason: 'journal database closed after replay')` | 保留。编辑器离线发送照片，经队列恢复和生产工具写入，再核对详情。 · [#217](#case-217) find a photo note and its thread after reopening the database |
| <a id='case-693'></a>693 · L392 | confirm account deletion keeps siblings, backups, and the selected folder | [settings_page][m93] | `expect(await workspace.exists(), isTrue)`；`expect(await UserStorage.resolveDataRoot('other'), customRoot.path)` | 保留。main 的删除账号功能在设置页；账号数据范围修复在工作分支。 · [#690](#case-690) post a comment in detail and read it after reopening the screen |

</details>

<details>
<summary>test/integration/memex_router_init_test.dart · 7 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-694'></a>694 · L23 | MemexRouter initialization source ordering task handlers are registered before LocalTaskExecutor starts | [memex_router][m50] | 读取 Dart 源码，比较文本位置 | 并入冷启动集成用例。旧队列中的索引任务由真实处理器完成，全文检索能找到它。 · [#697](#case-697) sendMessage waits for full router initialization before delegating |
| <a id='case-695'></a>695 · L39 | MemexRouter initialization source ordering primary companion wake loop is restored after task startup | [memex_router][m50] | 读取 Dart 源码，比较文本位置 | 并入冷启动集成用例。启动后数据库中出现主动唤醒任务。 · [#696](#case-696) history acquaintance is scheduled before the initiative wake |
| <a id='case-696'></a>696 · L54 | MemexRouter initialization source ordering history acquaintance is scheduled before the initiative wake | [memex_router][m50] | 读取 Dart 源码，比较文本位置 | 并入冷启动集成用例。实际查询两类任务的插入顺序。 · [#697](#case-697) sendMessage waits for full router initialization before delegating |
| <a id='case-697'></a>697 · L69 | MemexRouter initialization source ordering sendMessage waits for full router initialization before delegating | [memex_router][m50] | 读取 Dart 源码，比较文本位置 | 并入冷启动集成用例。阻塞延迟初始化时聊天保持等待，放行后收到响应。 · [#699](#case-699) fetchTimelineCards waits only for core initialization |
| <a id='case-698'></a>698 · L90 | MemexRouter initialization source ordering timeline init completes core before awaiting deferred work | [memex_router][m50] | 读取 Dart 源码，比较文本位置 | 并入冷启动集成用例。延迟初始化仍挂起时已能读出迁移后的记录。 · [#699](#case-699) fetchTimelineCards waits only for core initialization |
| <a id='case-699'></a>699 · L110 | MemexRouter initialization source ordering fetchTimelineCards waits only for core initialization | [memex_router][m50] | 读取 Dart 源码，比较文本位置 | 并入冷启动集成用例。时间线读取在放行聊天前已返回正文。 · [#698](#case-698) timeline init completes core before awaiting deferred work |
| <a id='case-700'></a>700 · L136 | switching accounts reopens the selected timeline even for the same card ID | [memex_router][m50] | `expect(await UserStorage.getUserId(), user)`；`expect(await UserStorage.getUserId(), isNull)` | 保留。main 有账号切换入口；等待旧任务写回的修复在工作分支。 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/integration/schedule_retirement_pipeline_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-701'></a>701 · L23 | retired schedule capability pipeline is unavailable to SuperAgent and blocked from every Timeline ingress | [timeline_viewmodel][m128] | `expect(agentType['enum'], isNot(contains('schedule')))`；`expect(viewModel.cards, isEmpty)` | 保留 · [#1022](#case-1022) timeline card idempotency helpers card removed e…d processing placeholder |

</details>

<details>
<summary>test/l10n/arb_key_parity_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-702'></a>702 · L6 | locale ARB files stay in key parity with app_en.arb | [app_en][m129] | `expect(result.exitCode, 0, reason: '${result.stderr}${result.stdout}')` | 保留。实际运行 scripts/check_arb_key_parity.py；缺失翻译键时工具应退出失败。 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/l10n/debug_tools_l10n_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-703'></a>703 · L14 | debug tools strings are localized | [app_localizations][m130] | `expect(l10n.taskIdLabel('42'), contains('42'))`；`expect(l10n.taskBizIdLabel('biz-1'), contains('biz-1'))` | 保留调试文案插值契约。仅证明占位符渲染，未打开调试页。 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/l10n/hardcoded_ui_strings_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-704'></a>704 · L15 | comment author labels resolve from l10n | [app_localizations][m130] | `expect(UserStorage.l10n.commentAuthorUser, '用户')`；`expect(UserStorage.l10n.commentAuthorAi, 'AI')` | 保留 · [#705](#case-705) replyDisplayNameFor falls back to localized AI label |
| <a id='case-705'></a>705 · L24 | replyDisplayNameFor falls back to localized AI label | [card][m42] | `expect(replyDisplayNameFor(comment, UserStorage.l10n.commentAuthorUser), UserStorage.l10n.commentAuthorAi)` | 保留 · [#192](#case-192) withResolvedReplyNames resolves an AI reply to a…ment as the display name |

</details>

<details>
<summary>test/l10n/italian_locale_smoke_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-706'></a>706 · L8 | Italian locale resolves and loads l10n | [app_localizations_ext][m131] | `expect(l10n.localeName, 'it')`；`expect(l10n.retry, 'Riprova')` | 保留 · [#707](#case-707) exposes the simplified AI setup copy |
| <a id='case-707'></a>707 · L22 | Italian locale exposes the simplified AI setup copy | [supported_languages][m132] | `expect(l10n.aiSetupStatusMemexTitle, 'Utilizzando il servizio ufficiale Memex')`；`expect(l10n.aiSetupStatusMemexDescription, isNot(contains('MemeX')))` | 保留 · [#713](#case-713) new locales expose the simplified AI setup copy |

</details>

<details>
<summary>test/l10n/local_speech_settings_copy_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-708'></a>708 · L6 | en local-STT description describes cloud transcription, not raw attach | [app_localizations][m130] | `expect(l10n.useLocalSpeechToTextDesc, isNot(contains('original audio is sent directly')))` | 保留 · [#709](#case-709) zh local-STT description describes cloud transcription, not raw attach |
| <a id='case-709'></a>709 · L13 | zh local-STT description describes cloud transcription, not raw attach | [app_localizations][m130] | `expect(l10n.useLocalSpeechToTextDesc, isNot(contains('原始音频发送给模型')))` | 保留 · [#708](#case-708) en local-STT description describes cloud transcription, not raw attach |

</details>

<details>
<summary>test/l10n/locale_lookup_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-710'></a>710 · L8 | every supported language tag resolves and loads l10n | [supported_languages][m132] | `expect(l10n.localeName, isNotEmpty)`；`expect(ext.oauthHintTitle, isNotEmpty)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-711'></a>711 · L19 | Vietnamese locale exposes translated common actions | [supported_languages][m132] | `expect(supportedLanguageTags, contains('vi'))`；`expect(l10n.localeName, 'vi')` | 保留 · [#712](#case-712) Farsi locale exposes translated common actions |
| <a id='case-712'></a>712 · L30 | Farsi locale exposes translated common actions | [supported_languages][m132] | `expect(supportedLanguageTags, contains('fa'))`；`expect(l10n.localeName, 'fa')` | 保留 · [#711](#case-711) Vietnamese locale exposes translated common actions |
| <a id='case-713'></a>713 · L41 | new locales expose the simplified AI setup copy | [supported_languages][m132] | `expect(l10n.aiSetupStatusMemexTitle, entry.value[0])`；`expect(l10n.aiSetupStatusMemexDescription, isNot(contains('MemeX')))` | 保留 · [#707](#case-707) Italian locale exposes the simplified AI setup copy |

</details>

<details>
<summary>test/live_agent_eval_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-714'></a>714 · L27 | Live Agent Evaluation companion + comment agent live run with env config | [comment_agent][m15] | `expect(latestComment, isNot(contains('Connection interrupted')))`；`expect(timeline.any((line) => line.contains('"event_type":"characterComment"')), isTrue)` | 保留在线验证。默认运行缺服务凭据时跳过。 · [#52](#case-52) CommentAgent live comment policy evaluation norm…motionally loaded record |

</details>

<details>
<summary>test/ui/agent_activity/agent_activity_widget_test.dart · 9 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-715'></a>715 · L54 | shows non-interactive processing affordance before task activity | [agent_activity_widget][m133] | `expect(find.text('AI is processing...'), findsOneWidget)`；`expect(find.text('Processing...'), findsNothing)` | 保留。尚无任务时的强制可见状态与已有四项排队任务分别触发。 · [#719](#case-719) active task status as a static affordance |
| <a id='case-716'></a>716 · L74 | uses fixed app logo instead of rotating processing frames | [agent_activity_widget][m133] | `expect(_assetImage('assets/icons/processing_1.png'), findsNothing)`；`expect(_assetImage('assets/icons/processing_2.png'), findsNothing)` | 保留 · [#715](#case-715) shows non-interactive processing affordance before task activity |
| <a id='case-717'></a>717 · L96 | updates background task count while status is visible | [agent_activity_widget][m133] | `expect(find.text(oneTaskMessage), findsOneWidget)`；`expect(find.text(twoTaskMessage), findsOneWidget)` | 保留 · [#723](#case-723) notification action leaves the static background status unchanged |
| <a id='case-718'></a>718 · L140 | shows background task count before agent tool messages | [agent_activity_widget][m133] | `expect(find.text('AI is processing...'), findsOneWidget)`；`expect(find.text('Activity Detail'), findsNothing)` | 保留 · [#719](#case-719) active task status as a static affordance |
| <a id='case-719'></a>719 · L166 | shows active task status as a static affordance | [agent_activity_widget][m133] | `expect(find.text('AI is processing...'), findsOneWidget)`；`expect(find.text('Running 0, Pending 4, Retry 0'), findsOneWidget)` | 保留。尚无任务时的强制可见状态与已有四项排队任务分别触发。 · [#718](#case-718) background task count before agent tool messages |
| <a id='case-720'></a>720 · L193 | does not show stale non-terminal history without active work | [agent_activity_widget][m133] | `expect(find.text('AI is processing...'), findsNothing)` | 保留 · [#721](#case-721) shows and hides from active task snapshots only |
| <a id='case-721'></a>721 · L216 | shows and hides from active task snapshots only | [agent_activity_widget][m133] | `expect(find.text('AI is processing...'), findsOneWidget)`；`expect(find.text('AI is processing...'), findsNothing)` | 保留 · [#720](#case-720) does not show stale non-terminal history without active work |
| <a id='case-722'></a>722 · L264 | ignores buffered notification activity action | [agent_activity_widget][m133] | `expect(find.text('No agent activity yet'), findsNothing)` | 保留 · [#723](#case-723) notification action leaves the static background status unchanged |
| <a id='case-723'></a>723 · L286 | notification action leaves the static background status unchanged | [agent_activity_service][m134] | `expect(find.text('Live notification body'), findsNothing)`；`expect(find.text(taskSummary), findsOneWidget)` | 保留 · [#717](#case-717) updates background task count while status is visible |

</details>

<details>
<summary>test/ui/app_lock/app_entry_pin_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-724'></a>724 · L10 | a protected route is reachable only after the saved PIN | [main][m135] | `expect(entry, findsNothing)`；`expect(opened, isTrue)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/ui/app_lock/app_lock_session_test.dart · 6 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-725'></a>725 · L7 | backgrounding before the PIN does not unlock on resume | [app_lock_session][m136] | `expect(session.isLocked, isTrue)`；`expect(session.sessionUnlocked, isFalse)` | 保留 · [#727](#case-727) grace expiry asks for the PIN again |
| <a id='case-726'></a>726 · L19 | an unlocked session returns without a PIN inside the grace period | [app_lock_session][m136] | `expect(session.isLocked, isTrue)`；`expect(session.sessionUnlocked, isTrue)` | 保留 · [#727](#case-727) grace expiry asks for the PIN again |
| <a id='case-727'></a>727 · L34 | grace expiry asks for the PIN again | [app_lock_session][m136] | `expect(session.isLocked, isTrue)`；`expect(session.sessionUnlocked, isFalse)` | 保留。第二次进入后台可能错误地重置已经超时的认证窗口。 · [#728](#case-728) a second pause after grace expiry still requires the PIN |
| <a id='case-728'></a>728 · L47 | a second pause after grace expiry still requires the PIN | [app_lock_session][m136] | `expect(session.requiresAuth, isTrue)` | 保留。第二次进入后台可能错误地重置已经超时的认证窗口。 · [#727](#case-727) grace expiry asks for the PIN again |
| <a id='case-729'></a>729 · L64 | foreground and background transitions never authenticate a locked reader | [app_lock_session][m136] | `expect(session.isLocked, isTrue)`；`expect(session.isLocked, !allowed, reason: 'auth=$authenticated gaps=$firstGap,$secondGap')` | 保留 · [#728](#case-728) a second pause after grace expiry still requires the PIN |
| <a id='case-730'></a>730 · L90 | lock disabled leaves the session open across pause | [app_lock_session][m136] | `expect(session.isLocked, isFalse)` | 保留 · [#728](#case-728) a second pause after grace expiry still requires the PIN |

</details>

<details>
<summary>test/ui/card_attachments/widgets/system_action_card_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-731'></a>731 · L30 | SystemActionCard renders dismissed actions as still actionable on source cards | [system_action_card][m137] | `expect(find.text('天津小白院领证Party调研'), findsOneWidget)`；`expect(find.text(UserStorage.l10n.ignore), findsOneWidget)` | 保留 · [#732](#case-732) keeps rejected actions hidden |
| <a id='case-732'></a>732 · L47 | SystemActionCard keeps rejected actions hidden | [system_action_card][m137] | `expect(find.text(UserStorage.l10n.addToCalendar), findsNothing)` | 保留 · [#731](#case-731) renders dismissed actions as still actionable on source cards |
| <a id='case-733'></a>733 · L62 | SystemActionCard does not offer a native write for an unsupported action type | [system_action_card][m137] | `expect(find.text(UserStorage.l10n.unknownAction), findsWidgets)` | 保留 · [#732](#case-732) keeps rejected actions hidden |
| <a id='case-734'></a>734 · L79 | SystemActionCard loads a pending artifact with visible confirmation controls | [system_action_card][m137] | `expect(find.text(UserStorage.l10n.systemActionPendingExplanation), findsOneWidget)`；`expect(find.text(UserStorage.l10n.ignore), findsOneWidget)` | 保留 · [#731](#case-731) renders dismissed actions as still actionable on source cards |

</details>

<details>
<summary>test/ui/character/view_models/character_edit_viewmodel_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-735'></a>735 · L17 | loads and edits character-owned world and memory entries | [character_edit_viewmodel][m138] | `expect(viewModel.worldEntries.single['content'], '旧书店在街角')`；`expect(viewModel.memoryEntries, isEmpty)` | 保留 · [#737](#case-737) reports workspace load failures |
| <a id='case-736'></a>736 · L34 | saves one draft through the router and exposes persistence errors | [character_edit_viewmodel][m138] | `expect(await viewModel.save(draft), isTrue)`；`expect(router.savedDraft, same(draft))` | 保留 · [#737](#case-737) reports workspace load failures |
| <a id='case-737'></a>737 · L52 | reports workspace load failures | [character_edit_viewmodel][m138] | `expect(await viewModel.load(), isFalse)`；`expect(viewModel.errorMessage, contains('workspace unavailable'))` | 保留 · [#736](#case-736) saves one draft through the router and exposes persistence errors |

</details>

<details>
<summary>test/ui/character/view_models/character_viewmodel_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-738'></a>738 · L25 | loads characters and reports failures explicitly | [character_viewmodel][m139] | `expect(await viewModel.loadCharacters(), isTrue)`；`expect(viewModel.characters, [character])` | 保留 · [#741](#case-741) removes a character only after a successful delete |
| <a id='case-739'></a>739 · L38 | does not update enabled state when persistence fails | [character_viewmodel][m139] | `expect(await viewModel.setCharacterEnabled(character, false), isFalse)`；`expect(viewModel.characters.single.enabled, isTrue)` | 保留。持久化抛异常与返回 false 都须维持原有启用状态。 · [#740](#case-740) persist returns false |
| <a id='case-740'></a>740 · L49 | does not update enabled state when persist returns false | [character_viewmodel][m139] | `expect(await viewModel.setCharacterEnabled(character, false), isFalse)`；`expect(viewModel.characters.single.enabled, isTrue)` | 保留。持久化抛异常与返回 false 都须维持原有启用状态。 · [#739](#case-739) persistence fails |
| <a id='case-741'></a>741 · L60 | removes a character only after a successful delete | [character_viewmodel][m139] | `expect(await viewModel.deleteCharacter(character), isFalse)`；`expect(await viewModel.deleteCharacter(character), isTrue)` | 保留 · [#740](#case-740) does not update enabled state when persist returns false |

</details>

<details>
<summary>test/ui/character/view_models/persona_avatar_viewmodel_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-742'></a>742 · L16 | ensureLoaded is a no-op until first call and stays idempotent | [persona_avatar_viewmodel][m140] | `expect(viewModel.character, isNull)`；`expect(router.loadCount, 1)` | 保留 · [#743](#case-743) loads avatar summary and refreshes when chat unread state changes |
| <a id='case-743'></a>743 · L42 | loads avatar summary and refreshes when chat unread state changes | [persona_avatar_viewmodel][m140] | `expect(viewModel.unreadCount, 2)`；`expect(viewModel.unreadCount, 0)` | 保留 · [#742](#case-742) ensureLoaded is a no-op until first call and stays idempotent |
| <a id='case-744'></a>744 · L74 | exposes load failures without discarding the current summary | [persona_avatar_viewmodel][m140] | `expect(viewModel.character?.id, 'friend')`；`expect(viewModel.errorMessage, contains('unavailable'))` | 保留 · [#743](#case-743) loads avatar summary and refreshes when chat unread state changes |
| <a id='case-745'></a>745 · L98 | ignores a stale refresh that completes after a newer refresh | [persona_avatar_viewmodel][m140] | `expect(viewModel.unreadCount, 0)` | 保留 · [#744](#case-744) exposes load failures without discarding the current summary |

</details>

<details>
<summary>test/ui/character/view_models/persona_chat_viewmodel_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-746'></a>746 · L15 | typing indicator appears after a short delay | [persona_chat_viewmodel][m141] | `expect(await viewModel.sendMessage('hello'), isTrue)`；`expect(viewModel.isReplying, isTrue)` | 保留 · [#747](#case-747) quick completion cancels the pending typing indicator |
| <a id='case-747'></a>747 · L34 | quick completion cancels the pending typing indicator | [persona_chat_viewmodel][m141] | `expect(viewModel.isReplying, isFalse)` | 保留 · [#746](#case-746) typing indicator appears after a short delay |
| <a id='case-748'></a>748 · L57 | consecutive sends do not restart the display delay | [persona_chat_viewmodel][m141] | `expect(await viewModel.sendMessage('one'), isTrue)`；`expect(viewModel.isReplying, isTrue)` | 保留 · [#746](#case-746) typing indicator appears after a short delay |
| <a id='case-749'></a>749 · L75 | history and live updates use cursors without reloading visible rows | [persona_chat_viewmodel][m141] | `expect(router.historyCalls, 0)`；`expect(router.historyCalls, 1)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/ui/character/widgets/character_config_error_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-750'></a>750 · L15 | image import fallback has no StateError prefix | [character_config_screen][m142] | `expect(message, isNot(contains('Bad state:')))` | 保留 · [#751](#case-751) keeps a specific error message |
| <a id='case-751'></a>751 · L25 | image import keeps a specific error message | [character_config_screen][m142] | `expect(characterImageImportFailureMessage('disk full'), UserStorage.l10n.operationFailed('disk full'))` | 保留 · [#750](#case-750) fallback has no StateError prefix |

</details>

<details>
<summary>test/ui/character/widgets/persona_avatar_button_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-752'></a>752 · L14 | loads the companion after the first frame | [persona_avatar_button][m143] | `expect(router.loadCount, 0)`；`expect(find.text('1'), findsOneWidget)` | 保留 · [#754](#case-754) renders unread count and delegates taps |
| <a id='case-753'></a>753 · L49 | renders an empty slot when no companion is available | [persona_avatar_button][m143] | `expect(find.byType(CharacterAvatar), findsNothing)` | 保留 · [#754](#case-754) unread count and delegates taps |
| <a id='case-754'></a>754 · L72 | renders unread count and delegates taps | [persona_avatar_button][m143] | `expect(find.byType(CharacterAvatar), findsOneWidget)`；`expect(tapped?.id, 'friend')` | 保留 · [#753](#case-753) an empty slot when no companion is available |

</details>

<details>
<summary>test/ui/character/widgets/persona_chat_screen_test.dart · 11 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-755'></a>755 · L8 | loading older chat does not request an automatic bottom scroll | [persona_chat_screen][m144] | `expect(shouldAutoScrollPersonaChat(previousCharacterId: 'yaoyao', currentCharact… 9, currentNewestMessageId: 10), isTrue)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-756'></a>756 · L46 | send button is disabled until the user enters text | [persona_chat_screen][m144] | `expect(sends, 1)` | 保留 · [#757](#case-757) input remains enabled for consecutive sends |
| <a id='case-757'></a>757 · L72 | input remains enabled for consecutive sends | [persona_chat_screen][m144] | `expect(textField.enabled, isNot(false))`；`expect(sends, 2)` | 保留 · [#758](#case-758) sending keeps the input focused for the next message |
| <a id='case-758'></a>758 · L98 | sending keeps the input focused for the next message | [persona_chat_screen][m144] | `expect(sends, 1)`；`expect(focusNode.hasFocus, isTrue)` | 保留 · [#757](#case-757) input remains enabled for consecutive sends |
| <a id='case-759'></a>759 · L128 | tapping the message area dismisses the input focus | [persona_chat_screen][m144] | `expect(focusNode.hasFocus, isFalse)` | 保留 · [#758](#case-758) sending keeps the input focused for the next message |
| <a id='case-760'></a>760 · L165 | supported emoji uses the Fluent 3D asset | [persona_chat_screen][m144] | `expect((image.image as AssetImage).assetName, 'assets/fluent_emoji/smiling_face_with_smiling_eyes_3d.png')`；`expect(semantics.properties.label, 'Emoji message: 😊')` | 保留 · [#762](#case-762) every protocol emoji has a bundled Fluent asset |
| <a id='case-761'></a>761 · L197 | unsupported emoji falls back to a smaller system glyph | [persona_chat_screen][m144] | `expect(find.byType(Image), findsNothing)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-762'></a>762 · L212 | every protocol emoji has a bundled Fluent asset | [persona_chat_screen][m144] | `expect(data.lengthInBytes, greaterThan(0), reason: emoji.agentId)` | 保留 · [#760](#case-760) supported emoji uses the Fluent 3D asset |
| <a id='case-763'></a>763 · L222 | reversed chat list reserves index zero for the typing indicator | [persona_chat_screen][m144] | `expect(personaChatMessageIndexForReversedList(listIndex: 0, extraItems: 0), 0)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-764'></a>764 · L239 | marks chat read after open even without a scroll client | [persona_chat_screen][m144] | `expect(events, ['read'])` | 保留 · [#765](#case-765) scrolls to latest then marks chat read when a client is attached |
| <a id='case-765'></a>765 · L251 | scrolls to latest then marks chat read when a client is attached | [persona_chat_screen][m144] | `expect(events, ['scroll', 'read'])` | 保留 · [#764](#case-764) marks chat read after open even without a scroll client |

</details>

<details>
<summary>test/ui/chat/chat_event_batch_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-766'></a>766 · L6 | batches token chunks into one flush | [chat_event_batcher][m145] | `expect(applied, isEmpty)`；`expect(flushes, 1)` | 保留 · [#767](#case-767) flushes immediately on error so the user sees it now |
| <a id='case-767'></a>767 · L28 | flushes immediately on error so the user sees it now | [chat_event_batcher][m145] | `expect(flushes, 2)` | 保留 · [#766](#case-766) batches token chunks into one flush |

</details>

<details>
<summary>test/ui/chat/chat_submission_coordinator_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-768'></a>768 · L8 | rapid first sends share a session without waiting for the first reply | [chat_submission_coordinator][m146] | `expect(calls, [null, 'shared'])` | 保留 · [#769](#case-769) failed session creation releases the next send |
| <a id='case-769'></a>769 · L43 | failed session creation releases the next send | [chat_submission_coordinator][m146] | `expect(calls, [null])` | 保留 · [#768](#case-768) rapid first sends share a session without waiting for the first reply |
| <a id='case-770'></a>770 · L64 | disposing does not start a waiting send | [chat_submission_coordinator][m146] | `expect(secondStarted, isFalse)` | 保留 · [#768](#case-768) rapid first sends share a session without waiting for the first reply |

</details>

<details>
<summary>test/ui/chat/view_models/chat_turn_viewmodel_test.dart · 5 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-771'></a>771 · L6 | preparation, queue and execution are distinct request states | [chat_turn_viewmodel][m147] | `expect(vm.hasPreparing, isTrue)`；`expect(vm.hasPending, isFalse)` | 保留 · [#773](#case-773) finishing submission does not finish the queued turn |
| <a id='case-772'></a>772 · L18 | closing an old run preserves independent preparation and queued work | [chat_turn_viewmodel][m147] | `expect(vm.phaseOf('c'), ChatTurnPhase.queued)`；`expect(vm.hasPending, isTrue)` | 保留 · [#773](#case-773) finishing submission does not finish the queued turn |
| <a id='case-773'></a>773 · L31 | finishing submission does not finish the queued turn | [chat_turn_viewmodel][m147] | `expect(vm.phaseOf('a'), ChatTurnPhase.queued)` | 保留 · [#771](#case-771) preparation, queue and execution are distinct request states |
| <a id='case-774'></a>774 · L42 | late enqueue acknowledgement cannot regress a running or ended turn | [chat_turn_viewmodel][m147] | `expect(vm.phaseOf('a'), ChatTurnPhase.running)` | 保留 · [#775](#case-775) preparation errors and stream errors are scoped to their request |
| <a id='case-775'></a>775 · L53 | preparation errors and stream errors are scoped to their request | [chat_turn_viewmodel][m147] | `expect(vm.phaseOf('b'), ChatTurnPhase.failed)`；`expect(vm.hasPending, isTrue)` | 保留 · [#773](#case-773) finishing submission does not finish the queued turn |

</details>

<details>
<summary>test/ui/chat/view_models/photo_attachments_viewmodel_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-776'></a>776 · L14 | publishes immediately, bounds exports, and preserves selection order | [photo_attachments_viewmodel][m148] | `expect(vm.items.map((e) => e.asset!.id), ['a', 'b', 'c'])`；`expect(vm.items.map((e) => e.prepared!.path), ['/original/a.heic', '/original/b.heic', '/original/c.heic'])` | 保留 · [#778](#case-778) failed originals block submission and can be retried |
| <a id='case-777'></a>777 · L40 | removed and cleared selections never return on late completion | [photo_attachments_viewmodel][m148] | `expect(jobs.containsKey('queued'), isFalse)`；`expect(vm.canSubmit, isTrue)` | 保留 · [#776](#case-776) publishes immediately, bounds exports, and preserves selection order |
| <a id='case-778'></a>778 · L63 | failed originals block submission and can be retried | [photo_attachments_viewmodel][m148] | `expect(vm.items.single.failed, isTrue)`；`expect(vm.canSubmit, isTrue)` | 保留 · [#776](#case-776) publishes immediately, bounds exports, and preserves selection order |
| <a id='case-779'></a>779 · L81 | disposing suppresses notifications and skips queued exports | [photo_attachments_viewmodel][m148] | `expect(notifications, 1)` | 保留 · [#776](#case-776) publishes immediately, bounds exports, and preserves selection order |

</details>

<details>
<summary>test/ui/chat/widgets/agent_chat_dialog_test.dart · 41 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-780'></a>780 · L47 | preparing and queued requests survive the previous run ending | [agent_chat_dialog][m127] | `expect(find.text('First reply', findRichText: true), findsOneWidget)`；`expect(find.byType(CircularProgressIndicator), findsNothing)` | 保留 · [#781](#case-781) duplicate attachment leaves queued work on the existing listener |
| <a id='case-781'></a>781 · L84 | duplicate attachment leaves queued work on the existing listener | [agent_chat_dialog][m127] | `expect(duplicateCancelled, isTrue)`；`expect(find.text('Duplicate replay', findRichText: true), findsNothing)` | 保留 · [#780](#case-780) preparing and queued requests survive the previous run ending |
| <a id='case-782'></a>782 · L121 | attachment failure does not stop another running request | [agent_chat_dialog][m127] | `expect(find.text('Cannot read attachment'), findsOneWidget)`；`expect(find.text('Still listening', findRichText: true), findsOneWidget)` | 保留 · [#781](#case-781) duplicate attachment leaves queued work on the existing listener |
| <a id='case-783'></a>783 · L147 | iOS gallery uses system picker and previews a limited-access selection before export | [agent_chat_dialog][m127] | `expect(pickerCalls, 1)`；`expect(released, ['native-selected'])` | 保留 · [#785](#case-785) gallery preview appears before original export a…an incomplete attachment |
| <a id='case-784'></a>784 · L220 | recommended photo selected through native picker can be deselected by asset ID | [agent_chat_dialog][m127] | `expect(find.byIcon(Icons.check_circle), findsOneWidget)`；`expect(find.byIcon(Icons.add_circle_outline), findsOneWidget)` | 保留 · [#783](#case-783) iOS gallery uses system picker and previews a li… selection before export |
| <a id='case-785'></a>785 · L283 | gallery preview appears before original export and cannot submit an incomplete attachment | [agent_chat_dialog][m127] | `expect(find.byKey(const ValueKey('selected-photo-selection-original')), findsOneWidget)`；`expect(exportCalls, 1)` | 保留 · [#783](#case-783) iOS gallery uses system picker and previews a li… selection before export |
| <a id='case-786'></a>786 · L341 | failed gallery originals offer retry and removal without losing the draft | [agent_chat_dialog][m127] | `expect(find.text(UserStorage.l10n.selectedPhotosPreparationFailed), findsOneWidget)`；`expect(find.text('keep this draft'), findsOneWidget)` | 保留 · [#785](#case-785) gallery preview appears before original export a…an incomplete attachment |
| <a id='case-787'></a>787 · L400 | AgentChatDialog layout metrics resolves default sheet and full-screen heights | [agent_chat_dialog][m127] | `expect(resolveAgentChatDialogHeight(viewport, isFullScreen: false), 600)`；`expect(resolveAgentChatDialogHeight(viewport, isFullScreen: false, keyboardInset: 320, topSafeInset: 44), 436)` | 保留 · [#788](#case-788) uses rounded sheet corners only outside full screen |
| <a id='case-788'></a>788 · L432 | AgentChatDialog layout metrics uses rounded sheet corners only outside full screen | [agent_chat_dialog][m127] | `expect(resolveAgentChatDialogBorderRadius(isFullScreen: true), BorderRadius.zero)` | 保留 · [#787](#case-787) resolves default sheet and full-screen heights |
| <a id='case-789'></a>789 · L443 | AgentChatDialog layout metrics uses keyboard inset whenever the keyboard is visible and editable | [agent_chat_dialog][m127] | `expect(resolveSuperAgentInputBottomInset(keyboardInset: 320, inputFocused: true, isStreaming: false), 320)`；`expect(resolveSuperAgentInputBottomInset(keyboardInset: 320, inputFocused: false, isStreaming: false), 320)` | 保留 · [#792](#case-792) snaps down when the keyboard inset shrinks |
| <a id='case-790'></a>790 · L471 | AgentChatDialog layout metrics does not create an empty assistant bubble for final done chunks | [agent_chat_dialog][m127] | `expect(shouldCreateAIMessageForResponseChunk(text: '', isDone: true), isFalse)`；`expect(shouldCreateAIMessageForResponseChunk(text: 'Done', isDone: true), isTrue)` | 保留 · [#804](#case-804) attaches pending artifacts only to the same assistant turn |
| <a id='case-791'></a>791 · L486 | AgentChatDialog layout metrics requests older history near the top or when content is too short | [agent_chat_dialog][m127] | `expect(shouldRequestOlderSuperAgentHistory(hasMoreHistory: true, isLoading: fals… pixels: 0, maxScrollExtent: 0), isTrue)`；`expect(shouldRequestOlderSuperAgentHistory(hasMoreHistory: true, isLoading: true…ls: 100, maxScrollExtent: 100), isFalse)` | 保留 · [#800](#case-800) keeps original filenames only for selected initial images |
| <a id='case-792'></a>792 · L526 | AgentChatDialog layout metrics snaps down when the keyboard inset shrinks | [agent_chat_dialog][m127] | `expect(resolveSuperAgentKeyboardInsetAnimationDuration(previousInset: 320, nextInset: 0), Duration.zero)` | 保留 · [#789](#case-789) uses keyboard inset whenever the keyboard is visible and editable |
| <a id='case-793'></a>793 · L543 | AgentChatDialog layout metrics maps reversed chat list indexes around live status rows | [agent_chat_dialog][m127] | `expect(superAgentItemIndexForReversedList(listIndex: 0, itemCount: 10, extraItems: 0), 9)`；`expect(superAgentItemIndexForReversedList(listIndex: 10, itemCount: 10, extraItems: 1), 0)` | 保留 · [#800](#case-800) keeps original filenames only for selected initial images |
| <a id='case-794'></a>794 · L570 | AgentChatDialog layout metrics formats chat time dividers like persona chat | [agent_chat_dialog][m127] | `expect(formatSuperAgentTimeDivider(today.subtract(const Duration(days: 1))), contains(UserStorage.l10n.yesterday))` | 保留 · [#795](#case-795) token usage without estimated cost |
| <a id='case-795'></a>795 · L583 | AgentChatDialog layout metrics formats token usage without estimated cost | [agent_chat_dialog][m127] | `expect(text, isNot(contains('Est')))`；`expect(text, isNot(contains('0.12345')))` | 保留 · [#794](#case-794) chat time dividers like persona chat |
| <a id='case-796'></a>796 · L602 | AgentChatDialog layout metrics shows standalone thinking only before process or reply appears | [agent_chat_dialog][m127] | `expect(shouldShowSuperAgentThinkingRow(isLoadingAgent: true, primaryItem: ProcessItem()..isFinished = true), isTrue)`；`expect(shouldShowSuperAgentThinkingRow(isLoadingAgent: true, primaryItem: AIMess…m('reply', isStreaming: true)), isFalse)` | 保留 · [#797](#case-797) uses final process state instead of historical tool errors |
| <a id='case-797'></a>797 · L636 | AgentChatDialog layout metrics uses final process state instead of historical tool errors | [agent_chat_dialog][m127] | `expect(superAgentProcessVisualState(completedProcess), SuperAgentProcessVisualState.done)`；`expect(superAgentProcessVisualState(attentionProcess), SuperAgentProcessVisualState.needsAttention)` | 保留 · [#813](#case-813) full-screen affordance shows completed process d…intermediate tool errors |
| <a id='case-798'></a>798 · L662 | AgentChatDialog layout metrics shows the photo suggestion status until suggestions resolve | [agent_chat_dialog][m127] | `expect(shouldShowSuperAgentPhotoSuggestionStatus(isLoading: true, hasSuggestions…e, hasLoadedSuggestions: false), isTrue)`；`expect(shouldShowSuperAgentPhotoSuggestionStatus(isLoading: false, hasSuggestion…e, hasLoadedSuggestions: true), isFalse)` | 保留 · [#810](#case-810) full-screen affordance reserves the photo sugges… slot on the first frame |
| <a id='case-799'></a>799 · L689 | AgentChatDialog layout metrics explains notification permission only for first eligible Android send | [agent_chat_dialog][m127] | `expect(shouldExplainMemexAgentNotificationPermission(platform: TargetPlatform.an…tatus: PermissionStatus.denied), isTrue)`；`expect(shouldExplainMemexAgentNotificationPermission(platform: TargetPlatform.an…ssionStatus.permanentlyDenied), isFalse)` | 保留 · [#800](#case-800) keeps original filenames only for selected initial images |
| <a id='case-800'></a>800 · L748 | AgentChatDialog layout metrics keeps original filenames only for selected initial images | [agent_chat_dialog][m127] | `expect(initialOriginalFilenamesForSelectedImages(selected, {'/tmp/a.jpg' : 'came… {'/tmp/a.jpg' : 'camera-original.jpg'})` | 保留 · [#811](#case-811) full-screen affordance renders selected images t… the cached image widget |
| <a id='case-801'></a>801 · L764 | AgentChatDialog layout metrics uses demo send key only while spotlighting super agent publish | [agent_chat_dialog][m127] | `expect(superAgentDemoPublishTargetKey(null), isNull)`；`expect(superAgentDemoPublishTargetKey(DemoStep.tapSend), same(DemoService.instance.sendButtonKey))` | 保留 · [#805](#case-805) toggles demo overlay suspension for routed detail pages |
| <a id='case-802'></a>802 · L773 | AgentChatDialog layout metrics keeps artifacts attached to the assistant reply item | [agent_chat_dialog][m127] | `expect(reply.artifacts.single.artifact.title, 'Schedule presentation')` | 保留 · [#803](#case-803) coalesces artifact revisions without changing card order |
| <a id='case-803'></a>803 · L784 | AgentChatDialog layout metrics coalesces artifact revisions without changing card order | [agent_chat_dialog][m127] | `expect(current.first.artifact.title, 'Final')`；`expect(current.last.artifact.kind, ChatArtifact.kindSchedule)` | 保留 · [#802](#case-802) keeps artifacts attached to the assistant reply item |
| <a id='case-804'></a>804 · L813 | AgentChatDialog layout metrics attaches pending artifacts only to the same assistant turn | [agent_chat_dialog][m127] | `expect(shouldAttachArtifactsToAssistantReply(turnId: 'turn-1', primaryItem: AIMe…Item('Done', turnId: 'turn-1')), isTrue)`；`expect(shouldAttachArtifactsToAssistantReply(turnId: 'turn-1', primaryItem: UserMessageItem('next request')), isFalse)` | 保留 · [#802](#case-802) keeps artifacts attached to the assistant reply item |
| <a id='case-805'></a>805 · L837 | AgentChatDialog layout metrics toggles demo overlay suspension for routed detail pages | [agent_chat_dialog][m127] | `expect(demo.isOverlaySuspended, isTrue)`；`expect(demo.isOverlaySuspended, isFalse)` | 保留 · [#801](#case-801) uses demo send key only while spotlighting super agent publish |
| <a id='case-806'></a>806 · L852 | AgentChatDialog full-screen affordance starts as a bottom sheet with a full-screen action | [agent_chat_dialog][m127] | `expect(find.byTooltip(UserStorage.l10n.enterFullScreenTooltip), findsOneWidget)`；`expect(tester.getSize(find.byKey(const ValueKey('agent_chat_dialog_container'))).height, 600)` | 保留 · [#808](#case-808) expands to full screen and restores the sheet |
| <a id='case-807'></a>807 · L888 | AgentChatDialog full-screen affordance keeps the keyboard sheet below the top safe area | [agent_chat_dialog][m127] | `expect(dialogRect.top, topSafeInset)` | 保留 · [#815](#case-815) header actions inside the compact header on narrow screens |
| <a id='case-808'></a>808 · L911 | AgentChatDialog full-screen affordance expands to full screen and restores the sheet | [agent_chat_dialog][m127] | `expect(tester.getSize(find.byKey(const ValueKey('agent_chat_dialog_container'))).height, 800)`；`expect(tester.getSize(find.byKey(const ValueKey('agent_chat_dialog_container'))).height, 600)` | 保留 · [#806](#case-806) starts as a bottom sheet with a full-screen action |
| <a id='case-809'></a>809 · L967 | AgentChatDialog full-screen affordance does not show a loading logo while opening a session | [agent_chat_dialog][m127] | `expect(find.byType(AgentLogoLoading), findsNothing)` | 保留 · [#811](#case-811) renders selected images through the cached image widget |
| <a id='case-810'></a>810 · L978 | AgentChatDialog full-screen affordance reserves the photo suggestion slot on the first frame | [agent_chat_dialog][m127] | `expect(tester.getSize(slotFinder).height, superAgentPhotoSuggestionSlotHeight)`；`expect(find.text(UserStorage.l10n.agentChat.findingRecentPhotos), findsOneWidget)` | 保留 · [#811](#case-811) renders selected images through the cached image widget |
| <a id='case-811'></a>811 · L996 | AgentChatDialog full-screen affordance renders selected images through the cached image widget | [agent_chat_dialog][m127] | `expect(find.byType(LocalImage), findsOneWidget)` | 保留 · [#809](#case-809) does not show a loading logo while opening a session |
| <a id='case-812'></a>812 · L1009 | AgentChatDialog full-screen affordance keeps process thinking and token usage inside details | [agent_chat_dialog][m127] | `expect(find.text(UserStorage.l10n.agentChat.thinking), findsNothing)`；`expect(find.byKey(const ValueKey('agent_chat_token_usage_debug')), findsOneWidget)` | 保留 · [#813](#case-813) shows completed process despite intermediate tool errors |
| <a id='case-813'></a>813 · L1051 | AgentChatDialog full-screen affordance shows completed process despite intermediate tool errors | [agent_chat_dialog][m127] | `expect(find.text(UserStorage.l10n.agentChat.completedActions(1)), findsOneWidget)`；`expect(find.text(UserStorage.l10n.agentChat.issue), findsNothing)` | 保留 · [#812](#case-812) keeps process thinking and token usage inside details |
| <a id='case-814'></a>814 · L1078 | AgentChatDialog full-screen affordance resolves persisted user image paths as local files | [agent_chat_dialog][m127] | `expect(superAgentUserMessageImageSourceForLocalDisplay('https://example.com/phot….jpg'), 'https://example.com/photo.jpg')` | 保留 · [#811](#case-811) renders selected images through the cached image widget |
| <a id='case-815'></a>815 · L1104 | AgentChatDialog full-screen affordance keeps header actions inside the compact header on narrow screens | [agent_chat_dialog][m127] | `expect(find.byKey(const ValueKey('agent_chat_fullscreen_toggle')), findsOneWidget)`；`expect(find.byTooltip(UserStorage.l10n.close), findsOneWidget)` | 保留 · [#806](#case-806) starts as a bottom sheet with a full-screen action |
| <a id='case-816'></a>816 · L1121 | AgentChatDialog full-screen affordance super agent entry hides chat controls and uses send input | [agent_chat_dialog][m127] | `expect(find.byKey(const ValueKey('super_agent_camera_button')), findsOneWidget)`；`expect(find.byKey(const ValueKey('super_agent_gallery_button')), findsOneWidget)` | 保留 · [#806](#case-806) starts as a bottom sheet with a full-screen action |
| <a id='case-817'></a>817 · L1143 | AgentChatDialog full-screen affordance renders a legacy schedule artifact without a dead link | [agent_chat_dialog][m127] | `expect(find.text('${UserStorage.l10n.agentChat.result} · 1'), findsOneWidget)`；`expect(find.text(UserStorage.l10n.artifactOpen), findsNothing)` | 保留 · [#819](#case-819) opens knowledge file artifacts with normalized PKM path |
| <a id='case-818'></a>818 · L1175 | AgentChatDialog full-screen affordance renders a system action with inline confirmation controls | [agent_chat_dialog][m127] | `expect(find.text(UserStorage.l10n.agentChat.calendarEventCreated), findsNothing)`；`expect(find.text(UserStorage.l10n.systemActionPendingExplanation), findsOneWidget)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-819'></a>819 · L1229 | AgentChatDialog full-screen affordance opens knowledge file artifacts with normalized PKM path | [agent_chat_dialog][m127] | `expect(find.text('I updated the knowledge file.'), findsOneWidget)`；`expect(page.filePath, 'Projects/memex.md')` | 保留 · [#817](#case-817) renders a legacy schedule artifact without a dead link |
| <a id='case-820'></a>820 · L1274 | AgentChatDialog full-screen affordance keeps super agent header actions tight to the right edge | [agent_chat_dialog][m127] | `expect(dialogRect.right - closeButtonRect.right, moreOrLessEquals(4))`；`expect(closeIconRect.right, greaterThan(dialogRect.right - 13))` | 保留 · [#815](#case-815) header actions inside the compact header on narrow screens |

</details>

<details>
<summary>test/ui/chat/widgets/chat_history_date_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-821'></a>821 · L16 | formats UTC session times in local hours | [chat_history_screen][m149] | `expect(formatted, DateFormat('HH:mm').format(local))` | 保留 · [#822](#case-822) uses calendar days not 24-hour buckets |
| <a id='case-822'></a>822 · L24 | uses calendar days not 24-hour buckets | [chat_history_screen][m149] | `expect(formatted, UserStorage.l10n.yesterdayAt(DateFormat('HH:mm').format(yesterdayEvening)))` | 保留 · [#821](#case-821) formats UTC session times in local hours |
| <a id='case-823'></a>823 · L38 | returns empty for null and original for invalid values | [chat_history_screen][m149] | `expect(formatChatHistoryDateTime(null), '')` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/ui/chat/widgets/chat_scroll_throttle_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-824'></a>824 · L5 | throttles chat scroll unless forced | [agent_chat_dialog][m127] | `expect(shouldScrollChatToBottom(now: start, lastScrollAt: null, minInterval: gap, force: false), isTrue)`；`expect(shouldScrollChatToBottom(now: start.subtract(const Duration(seconds: 1)),…minInterval: gap, force: false), isTrue)` | 保留。除节流边界外，还独立覆盖系统时钟回拨后的滚动。 · [#825](#case-825) streamed tokens update the reply without restart…until the 250ms boundary |

</details>

<details>
<summary>test/ui/chat/widgets/chat_scroll_throttle_widget_test.dart · 7 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-825'></a>825 · L22 | streamed tokens update the reply without restarting scroll until the 250ms boundary | [agent_chat_dialog][m127] | `expect(chat.controller.position.isScrollingNotifier.value, isTrue)`；`expect(find.text('First second third', findRichText: true).hitTestable(), findsOneWidget)` | 保留 · [#827](#case-827) completed reply scrolls immediately inside the throttle window |
| <a id='case-826'></a>826 · L60 | agent stop scrolls immediately inside the throttle window | [agent_chat_dialog][m127] | `expect(chat.controller.position.isScrollingNotifier.value, isTrue)`；`expect(find.text(visibleText, findRichText: true).hitTestable(), findsOneWidget)` | 保留。停止、完成、报错三种独立事件均应绕过滚动节流。 · [#828](#case-828) error scrolls immediately inside the throttle window |
| <a id='case-827'></a>827 · L60 | completed reply scrolls immediately inside the throttle window | [agent_chat_dialog][m127] | `expect(chat.controller.position.isScrollingNotifier.value, isTrue)`；`expect(find.text(visibleText, findRichText: true).hitTestable(), findsOneWidget)` | 保留。停止、完成、报错三种独立事件均应绕过滚动节流。 · [#828](#case-828) error scrolls immediately inside the throttle window |
| <a id='case-828'></a>828 · L60 | error scrolls immediately inside the throttle window | [agent_chat_dialog][m127] | `expect(chat.controller.position.isScrollingNotifier.value, isTrue)`；`expect(find.text(visibleText, findRichText: true).hitTestable(), findsOneWidget)` | 保留。停止、完成、报错三种独立事件均应绕过滚动节流。 · [#826](#case-826) agent stop scrolls immediately inside the throttle window |
| <a id='case-829'></a>829 · L84 | approval requests remain visible inside the throttle window | [agent_chat_dialog][m127] | `expect(chat.controller.offset, closeTo(0, 0.01))`；`expect(await approval, isFalse)` | 保留 · [#828](#case-828) error scrolls immediately inside the throttle window |
| <a id='case-830'></a>830 · L107 | full-screen action still scrolls inside the throttle window | [agent_chat_dialog][m127] | `expect(find.text('Newest answer', findRichText: true).hitTestable(), findsOneWidget)` | 保留 · [#828](#case-828) error scrolls immediately inside the throttle window |
| <a id='case-831'></a>831 · L126 | disposing with a buffered token cancels pending UI work | [agent_chat_dialog][m127] | `expect(tester.takeException(), isNull)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/ui/chat/widgets/open_super_agent_dialog_test.dart · 6 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-832'></a>832 · L23 | returns cached latest Super Agent home session id | [open_super_agent_dialog][m150] | `expectLater(latestSuperAgentSessionId(sessionExists: (_) async => const Ok(true)…Ok([]);}), completion('cached-session'))` | 保留 · [#833](#case-833) replaces a stale cached id with the latest home session |
| <a id='case-833'></a>833 · L41 | replaces a stale cached id with the latest home session | [open_super_agent_dialog][m150] | `expect(await UserStorage.getLatestSuperAgentHomeSessionId(), 'restored-home')` | 保留 · [#832](#case-832) returns cached latest Super Agent home session id |
| <a id='case-834'></a>834 · L65 | does not open an unverified cached id when validation fails | [open_super_agent_dialog][m150] | `expect(sessionId, isNull)`；`expect(await UserStorage.getLatestSuperAgentHomeSessionId(), 'cached-session')` | 保留 · [#835](#case-835) keeps a missing cached id available for a later iCloud retry |
| <a id='case-835'></a>835 · L85 | keeps a missing cached id available for a later iCloud retry | [open_super_agent_dialog][m150] | `expect(await UserStorage.getLatestSuperAgentHomeSessionId(), 'late-session')` | 保留 · [#834](#case-834) does not open an unverified cached id when validation fails |
| <a id='case-836'></a>836 · L101 | restores a legacy assistant session after app preferences are lost | [open_super_agent_dialog][m150] | `expect(sessionId, 'legacy-home')` | 保留 · [#832](#case-832) returns cached latest Super Agent home session id |
| <a id='case-837'></a>837 · L119 | waits for session lookup before building chat dialog | [open_super_agent_dialog][m150] | `expect(find.byType(AgentChatDialog), findsNothing)`；`expect(find.byType(AgentChatDialog), findsOneWidget)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/ui/chat/widgets/reference_asset_formatter_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-838'></a>838 · L6 | formats local asset preview urls as fs refs for agent context | [reference_asset_formatter][m151] | `expect(formatAssetReferenceForAgent(asset), 'fs://photo_1.jpg')` | 保留 · [#839](#case-839) keeps existing fs and remote urls unchanged |
| <a id='case-839'></a>839 · L15 | keeps existing fs and remote urls unchanged | [reference_asset_formatter][m151] | `expect(formatAssetReferenceForAgent(AssetData(type: 'image', url: 'fs://photo.jpg')), 'fs://photo.jpg')` | 保留 · [#838](#case-838) formats local asset preview urls as fs refs for agent context |

</details>

<details>
<summary>test/ui/core/cards/classic_card_status_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-840'></a>840 · L15 | failed classic card exposes the failure reason sheet | [classic_card][m152] | `expect(find.text(failureReason), findsOneWidget)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/ui/core/cards/templates/gallery_card_l10n_test.dart · 8 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-841'></a>841 · L37 | GalleryCard with empty image_urls shows noImages | [gallery_card][m153] | `expect(find.text(UserStorage.l10n.noImages), findsOneWidget)` | 保留 · [#842](#case-842) ConversationCard with empty messages shows noMessages |
| <a id='case-842'></a>842 · L48 | ConversationCard with empty messages shows noMessages | [conversation_card][m154] | `expect(find.text(UserStorage.l10n.noMessages), findsOneWidget)` | 保留 · [#841](#case-841) GalleryCard with empty image_urls shows noImages |
| <a id='case-843'></a>843 · L59 | CanvasCard with no image_url shows sketchContent | [canvas_card][m155] | `expect(find.text(UserStorage.l10n.sketchContent), findsOneWidget)` | 保留 · [#841](#case-841) GalleryCard with empty image_urls shows noImages |
| <a id='case-844'></a>844 · L70 | Spanish template gallery uses localized labels | [template_gallery_models][m156] | `expect(sections.first.items.first.label, isNot(contains('Classic Card')))` | 保留 · [#847](#case-847) Italian template gallery is localized |
| <a id='case-845'></a>845 · L77 | Arabic template gallery uses localized section titles | [template_gallery_models][m156] | `expect(sections.first.items.first.label, contains('البطاقة'))` | 保留 · [#847](#case-847) Italian template gallery is localized |
| <a id='case-846'></a>846 · L84 | Japanese template gallery uses localized insight titles | [template_gallery_models][m156] | `expect(items.first.data['title'], '今日のタイムライン')` | 保留 · [#845](#case-845) Arabic template gallery uses localized section titles |
| <a id='case-847'></a>847 · L90 | Italian template gallery is localized | [template_gallery_models][m156] | `expect(sections.first.items.first.label, contains('Scheda classica'))`；`expect(sections.first.items.first.label, isNot(contains('Classic Card')))` | 保留 · [#844](#case-844) Spanish template gallery uses localized labels |
| <a id='case-848'></a>848 · L98 | localized multiline gallery content contains real newlines | [gallery_card][m153] | `expect(snippet, contains('\n\n'))`；`expect(article, isNot(contains(r'\n')))` | 保留 · [#844](#case-844) Spanish template gallery uses localized labels |

</details>

<details>
<summary>test/ui/core/cards/templates/temporal/task_card_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-849'></a>849 · L6 | parent completion updates every grouped subtask | [task_card][m157] | `expect((updates.last['subtasks'] as List).map((subtask) => (subtask as Map)['completed']), [true, true])` | 保留 · [#850](#case-850) last completed subtask completes the parent task |
| <a id='case-850'></a>850 · L43 | last completed subtask completes the parent task | [task_card][m157] | `expect((updates.last['subtasks'] as List).map((subtask) => (subtask as Map)['completed']), [true, true])` | 保留 · [#849](#case-849) parent completion updates every grouped subtask |

</details>

<details>
<summary>test/ui/core/themes/bundled_google_fonts_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-851'></a>851 · L18 | disables runtime font fetching | [bundled_google_fonts][m158] | `expect(GoogleFonts.config.allowRuntimeFetching, isFalse)` | 保留。前者验证是否启用在线字体请求，后者实际挂载离线字体及品牌标题。 · [#852](#case-852) AppTheme and brand title resolve bundled fonts offline |
| <a id='case-852'></a>852 · L22 | AppTheme and brand title resolve bundled fonts offline | [bundled_google_fonts][m158] | `expect(find.byType(MemexBrandTitle), findsOneWidget)`；`expect(find.text('offline quote'), findsOneWidget)` | 保留。前者验证是否启用在线字体请求，后者实际挂载离线字体及品牌标题。 · [#851](#case-851) disables runtime font fetching |

</details>

<details>
<summary>test/ui/core/widgets/avatar_widgets_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-853'></a>853 · L10 | CharacterAvatar routes HEIC media paths through LocalImage | [character_avatar][m159] | `expect(find.byType(LocalImage), findsOneWidget)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-854'></a>854 · L26 | DiceBearAvatar shows a stable placeholder for empty seeds | [dicebear_avatar][m160] | `expect(find.byIcon(Icons.person), findsOneWidget)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/ui/core/widgets/demo_overlay_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-855'></a>855 · L23 | recovers the spotlight when the target appears later | [demo_overlay][m161] | `expect(find.text(UserStorage.l10n.demoTapAdd), findsNothing)`；`expect(find.text(UserStorage.l10n.demoTapAdd), findsOneWidget)` | 保留 · [#856](#case-856) a spotlight tap lands on the button inside the phone column |
| <a id='case-856'></a>856 · L70 | a spotlight tap lands on the button inside the phone column | [demo_overlay][m161] | `expect(find.text(UserStorage.l10n.demoTapAdd), findsOneWidget)` | 保留 · [#855](#case-855) recovers the spotlight when the target appears later |

</details>

<details>
<summary>test/ui/core/widgets/language_picker_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-857'></a>857 · L6 | compact language value stays inline without code or subtitle | [language_picker][m162] | `expect(find.text('Русский'), findsOneWidget)`；`expect(find.byIcon(Icons.translate_outlined), findsNothing)` | 保留 · [#858](#case-858) shows scalable language list and returns selected tag |
| <a id='case-858'></a>858 · L31 | shows scalable language list and returns selected tag | [language_picker][m162] | `expect(find.byType(TextField), findsNothing)`；`expect(selectedTag, 'ru')` | 保留 · [#857](#case-857) compact language value stays inline without code or subtitle |

</details>

<details>
<summary>test/ui/core/widgets/local_image_decode_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-859'></a>859 · L5 | localImageDecodePixels scales by device pixel ratio | [local_image][m163] | `expect(localImageDecodePixels(120, 3), 360)` | 保留 · [#861](#case-861) clamps huge bitmaps |
| <a id='case-860'></a>860 · L10 | localImageDecodePixels ignores empty or infinite sizes | [local_image][m163] | `expect(localImageDecodePixels(null, 2), isNull)`；`expect(localImageDecodePixels(double.infinity, 2), isNull)` | 保留 · [#861](#case-861) clamps huge bitmaps |
| <a id='case-861'></a>861 · L16 | localImageDecodePixels clamps huge bitmaps | [local_image][m163] | `expect(localImageDecodePixels(8000, 3), 4096)` | 保留 · [#859](#case-859) scales by device pixel ratio |

</details>

<details>
<summary>test/ui/core/widgets/local_image_provider_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-862'></a>862 · L11 | provider reports an error instead of hanging on a stalled download | [local_image][m163] | `expect(error, isA<TimeoutException>())` | 保留 · [#863](#case-863) applies one timeout across response stages |
| <a id='case-863'></a>863 · L39 | provider applies one timeout across response stages | [local_image][m163] | `expect(error, isA<TimeoutException>())`；`expect((error as TimeoutException).duration, lessThanOrEqualTo(timeout - headerDelay))` | 保留 · [#862](#case-862) reports an error instead of hanging on a stalled download |

</details>

<details>
<summary>test/ui/core/widgets/local_image_safety_test.dart · 8 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-864'></a>864 · L40 | shows a safe placeholder instead of rendering unsafe long image | [local_image][m163] | `expect(find.byType(Image), findsNothing)` | 保留 · [#866](#case-866) for unsafe downloaded network images |
| <a id='case-865'></a>865 · L72 | preview source config allows high-pixel phone photos only | [local_image][m163] | `expect(defaultReport.reason, contains('pixel count'))`；`expect(previewSourceReport.safeForPreview, isTrue)` | 保留 · [#870](#case-870) slow source inspection leaves the page interactive |
| <a id='case-866'></a>866 · L98 | shows a safe placeholder for unsafe downloaded network images | [local_image][m163] | `expect(find.byType(Image), findsNothing)` | 保留 · [#864](#case-864) instead of rendering unsafe long image |
| <a id='case-867'></a>867 · L126 | provider resolves unsafe local images to a transparent placeholder | [local_image][m163] | `expect(info.image.width, 1)`；`expect(pixels!.getUint8(3), 0)` | 保留 · [#868](#case-868) still decodes safe local image pixels |
| <a id='case-868'></a>868 · L138 | provider still decodes safe local image pixels | [local_image][m163] | `expect(pixels!.getUint8(3), greaterThan(0))` | 保留 · [#867](#case-867) resolves unsafe local images to a transparent placeholder |
| <a id='case-869'></a>869 · L149 | late failure from a recycled image cannot replace the new image | [local_image][m163] | `expect(tester.widget<Image>(find.byType(Image)).image, displayed)` | 保留 · [#870](#case-870) slow source inspection leaves the page interactive |
| <a id='case-870'></a>870 · L195 | slow source inspection leaves the page interactive | [local_image][m163] | `expect(inspection.isCompleted, isFalse)`；`expect(find.text('taps 1'), findsOneWidget)` | 保留 · [#869](#case-869) late failure from a recycled image cannot replace the new image |
| <a id='case-871'></a>871 · L238 | swiping the detail gallery shows the pixels of the selected attachment | [local_image][m163] | `expect(pixels!.buffer.asUint8List().take(4), rgba)` | 保留。左右滑动后读取图集像素，检测复用或懒加载显示错图。 · [#868](#case-868) provider still decodes safe local image pixels |

</details>

<details>
<summary>test/ui/core/widgets/memex_brand_title_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-872'></a>872 · L18 | hides channel badge for stable builds | [memex_brand_title][m164] | `expect(find.text('DEV'), findsNothing)` | 保留 · [#873](#case-873) shows Early channel badge for early builds |
| <a id='case-873'></a>873 · L27 | shows Early channel badge for early builds | [memex_brand_title][m164] | `expect(find.text('EARLY'), findsOneWidget)` | 保留 · [#872](#case-872) hides channel badge for stable builds |
| <a id='case-874'></a>874 · L36 | shows Dev channel badge for development builds | [memex_brand_title][m164] | `expect(find.text('DEV'), findsOneWidget)` | 保留 · [#872](#case-872) hides channel badge for stable builds |

</details>

<details>
<summary>test/ui/core/widgets/phone_width_frame_test.dart · 5 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-875'></a>875 · L43 | a phone portrait keeps the current full-width layout | [phone_width_frame][m165] | `expect(tester.getSize(find.byKey(_WidthProbe.columnKey)).width, 390)`；`expect(tester.getSize(find.byKey(_WidthProbe.bubbleKey)).width, 390 * 0.72)` | 保留 · [#876](#case-876) turned sideways stays full width |
| <a id='case-876'></a>876 · L54 | a phone turned sideways stays full width | [phone_width_frame][m165] | `expect(tester.getSize(find.byKey(_WidthProbe.columnKey)).width, 844)`；`expect(tester.getSize(find.byKey(_WidthProbe.bubbleKey)).width, 844 * 0.72)` | 保留 · [#875](#case-875) portrait keeps the current full-width layout |
| <a id='case-877'></a>877 · L63 | a large flat screen centers a phone-width column | [phone_width_frame][m165] | `expect(tester.getSize(find.byKey(_WidthProbe.columnKey)).width, PhoneWidthFrame.maxWidth)`；`expect(tester.getTopLeft(find.byKey(_WidthProbe.columnKey)).dx, (size.width - PhoneWidthFrame.maxWidth) / 2)` | 保留 · [#879](#case-879) flat hinge is shifted into the centered column |
| <a id='case-878'></a>878 · L93 | a half-open hinge keeps the full window | [phone_width_frame][m165] | `expect(tester.getSize(find.byKey(_WidthProbe.columnKey)).width, 840)`；`expect(tester.getSize(find.byKey(_WidthProbe.bubbleKey)).width, 840 * 0.72)` | 保留 · [#875](#case-875) phone portrait keeps the current full-width layout |
| <a id='case-879'></a>879 · L112 | a flat hinge is shifted into the centered column | [phone_width_frame][m165] | `expect(find.text('area:230'), findsOneWidget)` | 保留 · [#877](#case-877) large flat screen centers a phone-width column |

</details>

<details>
<summary>test/ui/core/widgets/reliable_asset_picker_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-880'></a>880 · L12 | keeps Android on the platform default thumbnail backend | [reliable_asset_picker][m166] | `expect(photoPickerBackendFor(TargetPlatform.android), PhotoPickerBackend.platformDefault)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-881'></a>881 · L23 | Android picker config preserves the original image-only behavior | [reliable_asset_picker][m166] | `expect(config.requestType, RequestType.image)`；`expect(config.pageSize, const AssetPickerConfig().pageSize)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-882'></a>882 · L32 | shows loading, retries once, and offers a manual retry | [reliable_asset_picker][m166] | `expect(find.byKey(reliableThumbnailLoadingKey), findsOneWidget)`；`expect(find.byKey(reliableThumbnailImageKey), findsOneWidget)` | 保留 · [#883](#case-883) cancels native work when a recycled grid cell is disposed |
| <a id='case-883'></a>883 · L75 | cancels native work when a recycled grid cell is disposed | [reliable_asset_picker][m166] | `expect(cancelCount, 1)` | 保留 · [#882](#case-882) shows loading, retries once, and offers a manual retry |

</details>

<details>
<summary>test/ui/core/widgets/searchable_dropdown_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-884'></a>884 · L6 | dropdown arrow clears focus from another active text field | [searchable_dropdown][m167] | `expect(otherFocusNode.hasFocus, isTrue)`；`expect(find.text('kimi-k2.5'), findsOneWidget)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/ui/core/widgets/viewport_gated_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-885'></a>885 · L6 | builds the child only after it intersects the viewport | [viewport_gated][m168] | `expect(find.text('visible-child'), findsOneWidget)`；`expect(find.text('offscreen-child'), findsNothing)` | 保留 · [#886](#case-886) immediately when not inside a scroll view |
| <a id='case-886'></a>886 · L52 | builds immediately when not inside a scroll view | [viewport_gated][m168] | `expect(find.text('visible-child'), findsOneWidget)` | 保留 · [#885](#case-885) the child only after it intersects the viewport |

</details>

<details>
<summary>test/ui/insight/insight_detail_page_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-887'></a>887 · L15 | shows friendly message for missing insight links | [insight_detail_page][m169] | `expect(find.textContaining('Knowledge insight card not found'), findsNothing)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/ui/insight/view_models/insight_viewmodel_html_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-888'></a>888 · L12 | ensureHtmlRendered fills html once and is idempotent | [insight_viewmodel][m170] | `expect(viewModel.insights!.single.html, '<div>chart</div>')` | 保留 · [#889](#case-889) skips native cards |
| <a id='case-889'></a>889 · L33 | ensureHtmlRendered skips native cards | [insight_viewmodel][m170] | `expect(router.renderCount, 0)` | 保留 · [#888](#case-888) fills html once and is idempotent |
| <a id='case-890'></a>890 · L50 | failed HTML render waits for an explicit retry | [insight_viewmodel][m170] | `expect(viewModel.hasHtmlRenderFailed(item.id), isTrue)`；`expect(viewModel.hasHtmlRenderFailed(item.id), isFalse)` | 保留 · [#888](#case-888) ensureHtmlRendered fills html once and is idempotent |

</details>

<details>
<summary>test/ui/insight/widgets/insight_list_builder_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-891'></a>891 · L24 | uses a lazy ListView.builder for the insight feed | [insight_screen][m171] | `expect(find.byType(ListView), findsOneWidget)` | 改写。滚动前远端卡片未挂载，滚动后可见第 40 张。 · [#900](#case-900) directory rows are built through ListView.builder |
| <a id='case-892'></a>892 · L58 | failed HTML render stops until the user retries | [insight_screen][m171] | `expect(find.text(UserStorage.l10n.reload), findsOneWidget)`；`expect(router.renderCount, 2)` | 保留 · [#891](#case-891) uses a lazy ListView.builder for the insight feed |

</details>

<details>
<summary>test/ui/insight/widgets/insight_screen_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-893'></a>893 · L25 | shows all insights without activity statistics navigation | [insight_screen][m171] | `expect(find.text('First insight'), findsOneWidget)`；`expect(find.text('Activity stats'), findsNothing)` | 保留 · [#891](#case-891) uses a lazy ListView.builder for the insight feed |
| <a id='case-894'></a>894 · L59 | a failed pin does not say the insight was pinned | [insight_screen][m171] | `expect(find.text('Style pinned'), findsNothing)`；`expect(find.text('First insight'), findsOneWidget)` | 保留 · [#895](#case-895) delete keeps the insight on screen |
| <a id='case-895'></a>895 · L77 | a failed delete keeps the insight on screen | [insight_screen][m171] | `expect(find.textContaining('Delete failed'), findsOneWidget)`；`expect(find.text('First insight'), findsOneWidget)` | 保留 · [#894](#case-894) pin does not say the insight was pinned |
| <a id='case-896'></a>896 · L95 | a pin that is already running does not toast a failure | [insight_screen][m171] | `expect(find.text('Style pinned'), findsNothing)` | 保留 · [#894](#case-894) failed pin does not say the insight was pinned |

</details>

<details>
<summary>test/ui/insight/widgets/insight_template_build_error_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-897'></a>897 · L15 | uses localized operationFailed when a template fails to build | [insight_template_gallery_page][m172] | `expect(insightTemplateBuildError('classic'), UserStorage.l10n.operationFailed('classic'))` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/ui/knowledge/knowledge_base_screen_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-898'></a>898 · L13 | root listing helpers keep non-PARA folders and root files | [knowledge_base_screen][m126] | `expect(files.map((file) => file['path']), ['Loose note.md'])` | 保留 · [#899](#case-899) renders additional root folders and files below fixed PARA cards |
| <a id='case-899'></a>899 · L65 | renders additional root folders and files below fixed PARA cards | [knowledge_base_screen][m126] | `expect(find.text('PROJECTS'), findsOneWidget)`；`expect(find.text('Loose note.md'), findsOneWidget)` | 保留 · [#898](#case-898) root listing helpers keep non-PARA folders and root files |

</details>

<details>
<summary>test/ui/knowledge/widgets/knowledge_directory_body_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-900'></a>900 · L6 | directory rows are built through ListView.builder | [knowledge_directory_page][m173] | `expect(find.byType(ListView), findsOneWidget)`；`expect(find.text('Folder 19'), findsNothing)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/ui/lazy_secondary_loads_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-901'></a>901 · L14 | InsightViewModel does not start in a loading state | [insight_viewmodel][m170] | `expect(vm.isLoading, isFalse)` | 保留。分别检查两个独立页面模型启动时的加载标志与初始数据，未计入首页加载链路。 · [#902](#case-902) KnowledgeBaseViewModel does not start in a loading state |
| <a id='case-902'></a>902 · L21 | KnowledgeBaseViewModel does not start in a loading state | [knowledge_base_viewmodel][m174] | `expect(vm.isLoading, isFalse)` | 保留。分别检查两个独立页面模型启动时的加载标志与初始数据，未计入首页加载链路。 · [#901](#case-901) InsightViewModel does not start in a loading state |

</details>

<details>
<summary>test/ui/main_screen/home_tab_rebuild_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-903'></a>903 · L10 | reading tab view models does not rebuild siblings on notify | [main][m135] | `expect(knowledgeBuilds, 1)` | 删除。测试自行拼出 Provider 树；修改首页的订阅方式不会让它失败。首页标签之间的重建隔离仍缺页面级证据。 · [#1034](#case-1034) chrome header stays mounted when the timeline list notifies |

</details>

<details>
<summary>test/ui/main_screen/quick_recording_transcript_test.dart · 5 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-904'></a>904 · L8 | finalizeQuickRecordingTranscript empty PCM does not transcribe and keeps existing text | [quick_recording_transcript][m175] | `expect(result.text, 'streaming')`；`expect(result.error, isNull)` | 保留 · [#905](#case-905) non-empty PCM always calls transcribe and returns its text |
| <a id='case-905'></a>905 · L24 | finalizeQuickRecordingTranscript non-empty PCM always calls transcribe and returns its text | [quick_recording_transcript][m175] | `expect(result.text, 'cloud transcript')`；`expect(result.error, isNull)` | 保留并增加 PCM 样本数值与符号断言。 · [#904](#case-904) empty PCM does not transcribe and keeps existing text |
| <a id='case-906'></a>906 · L42 | finalizeQuickRecordingTranscript empty transcript keeps existing text for the caller toast path | [quick_recording_transcript][m175] | `expect(result.text, isEmpty)`；`expect(result.hasText, isFalse)` | 并入 [#907](#case-907)，逐一校验草稿、回调次数与原始错误。 · [#907](#case-907) failed or empty final passes preserve every existing draft |
| <a id='case-907'></a>907 · L60 | finalizeQuickRecordingTranscript failed or empty final passes preserve every existing draft | [quick_recording_transcript][m175] | `expect(result.hasError, outcome == 'failed')` | 保留并加强，包括回调次数、错误对象和草稿状态。 · [#906](#case-906) empty transcript keeps existing text for the caller toast path |
| <a id='case-908'></a>908 · L78 | finalizeQuickRecordingTranscript transcribe failure preserves text and surfaces error | [quick_recording_transcript][m175] | `expect(result.text, isEmpty)`；`expect(result.hasError, isTrue)` | 并入 [#907](#case-907)，逐一校验草稿、回调次数与原始错误。 · [#907](#case-907) failed or empty final passes preserve every existing draft |

</details>

<details>
<summary>test/ui/main_screen/widgets/clipboard_preview_card_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-909'></a>909 · L17 | renders compact preview and exposes paste and dismiss actions | [clipboard_preview_card][m176] | `expect(find.text(UserStorage.l10n.clipboardPreviewTitle), findsOneWidget)`；`expect(dismissCount, 1)` | 保留 · [#910](#case-910) image clipboard candidate with add image action |
| <a id='case-910'></a>910 · L59 | renders image clipboard candidate with add image action | [clipboard_preview_card][m176] | `expect(find.text(UserStorage.l10n.clipboardPreviewImageTitle), findsOneWidget)`；`expect(find.text(UserStorage.l10n.clipboardPreviewAddImageToInput), findsOneWidget)` | 保留 · [#909](#case-909) compact preview and exposes paste and dismiss actions |

</details>

<details>
<summary>test/ui/main_screen/widgets/main_bottom_bar_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-911'></a>911 · L64 | tapping the Timeline label or icon area switches the tab | [main_bottom_bar][m177] | `expect(timelineTaps, 1)`；`expect(timelineTaps, 2)` | 保留 · [#912](#case-912) Library tab area switches the tab |
| <a id='case-912'></a>912 · L88 | tapping the Library tab area switches the tab | [main_bottom_bar][m177] | `expect(libraryTaps, 1)` | 保留 · [#911](#case-911) Timeline label or icon area switches the tab |
| <a id='case-913'></a>913 · L103 | home-indicator inset keeps tab labels above the gesture zone | [main_bottom_bar][m177] | `expect(tester.getSize(find.byType(MainBottomBar)).height, 120.5 + inset)` | 保留 · [#911](#case-911) tapping the Timeline label or icon area switches the tab |

</details>

<details>
<summary>test/ui/main_screen/widgets/share_intent_handler_test.dart · 9 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-914'></a>914 · L18 | shared document files are routed to import without model config | [share_intent_handler][m178] | `expect(importedPaths, [['/tmp/report.pdf', '/tmp/archive.zip']])`；`expect(backupPaths, isEmpty)` | 保留 · [#919](#case-919) mixed file shares import all attachments |
| <a id='case-915'></a>915 · L51 | memex backup shares still route to restore | [share_intent_handler][m178] | `expect(backupPaths, ['/tmp/backup.memex'])` | 保留 · [#918](#case-918) generic non-image file shares route to import |
| <a id='case-916'></a>916 · L74 | image-only shares still open a draft without model config | [share_intent_handler][m178] | `expect(importedPaths, isEmpty)`；`expect(drafts.single.images.single.path, '/tmp/photo.png')` | 保留 · [#917](#case-917) file attachments with image extensions still open a draft |
| <a id='case-917'></a>917 · L100 | file attachments with image extensions still open a draft | [share_intent_handler][m178] | `expect(importedPaths, isEmpty)`；`expect(drafts.single.images.single.path, '/tmp/photo.heic')` | 保留 · [#916](#case-916) image-only shares still open a draft without model config |
| <a id='case-918'></a>918 · L124 | generic non-image file shares route to import | [share_intent_handler][m178] | `expect(drafts, isEmpty)` | 保留 · [#919](#case-919) mixed file shares import all attachments |
| <a id='case-919'></a>919 · L149 | mixed file shares import all attachments | [share_intent_handler][m178] | `expect(drafts, isEmpty)` | 保留 · [#918](#case-918) generic non-image file shares route to import |
| <a id='case-920'></a>920 · L178 | external opened image files open a draft without model config | [share_intent_handler][m178] | `expect(importedPaths, isEmpty)`；`expect(drafts.single.images.single.path, '/tmp/opened_photo.jpg')` | 保留 · [#916](#case-916) image-only shares still open a draft without model config |
| <a id='case-921'></a>921 · L196 | external opened non-image files route to import | [share_intent_handler][m178] | `expect(importedPaths, [['/tmp/opened_document.pdf']])` | 保留 · [#922](#case-922) mixed files route all files to import |
| <a id='case-922'></a>922 · L214 | external opened mixed files route all files to import | [share_intent_handler][m178] | `expect(importedPaths, [['/tmp/opened_photo.jpg', '/tmp/opened_document.pdf']])` | 保留 · [#921](#case-921) non-image files route to import |

</details>

<details>
<summary>test/ui/memory/widgets/memory_list_date_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-923'></a>923 · L5 | formats UTC instants in local time | [memory_screen][m179] | `expect(formatted, '${local.month}/${local.day} ${local.hour}:${local.minute.toString().padLeft(2, '0')}')` | 保留 · 未找到同一行为的替代项 |
| <a id='case-924'></a>924 · L14 | returns empty for missing or invalid values | [memory_screen][m179] | `expect(formatMemoryListDate('not-a-date'), '')` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/ui/memory/widgets/memory_screen_l10n_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-925'></a>925 · L31 | MemoryScreen shows localized title and empty states | [memory_screen][m179] | `expect(find.text(UserStorage.l10n.memoryTitle), findsOneWidget)`；`expect(find.text(UserStorage.l10n.memoryNoLongTermYet), findsOneWidget)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/ui/rtl/arabic_layout_smoke_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-926'></a>926 · L53 | MainBottomBar lays out without overflow in Arabic RTL | [main_bottom_bar][m177] | `expect(find.byType(MainBottomBar), findsOneWidget)`；`expect(find.text(UserStorage.l10n.bottomNavLibrary), findsOneWidget)` | 保留 · [#927](#case-927) TimelineFilterBar lays out without overflow in Arabic RTL |
| <a id='case-927'></a>927 · L77 | TimelineFilterBar lays out without overflow in Arabic RTL | [timeline_screen][m180] | `expect(find.byType(TimelineFilterBar), findsOneWidget)` | 保留 · [#926](#case-926) MainBottomBar lays out without overflow in Arabic RTL |
| <a id='case-928'></a>928 · L102 | SummaryCard metrics lay out without overflow in Arabic RTL | [summary_card][m181] | `expect(find.byType(SummaryCard), findsOneWidget)` | 保留 · [#927](#case-927) TimelineFilterBar lays out without overflow in Arabic RTL |

</details>

<details>
<summary>test/ui/settings/location_context_settings_page_test.dart · 12 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-929'></a>929 · L99 | updates location context settings from the page | [location_context_settings_page][m182] | `expect(find.text('Location Context'), findsOneWidget)`；`expect(config.granularity, LocationContextGranularity.neighborhood)` | 保留 · [#930](#case-930) complex edits stay draft until explicit save |
| <a id='case-930'></a>930 · L198 | complex edits stay draft until explicit save | [location_context_settings_page][m182] | `expect(find.text('Save'), findsOneWidget)`；`expect(config.amapApiKey, 'draft-key')` | 保留 · [#929](#case-929) updates location context settings from the page |
| <a id='case-931'></a>931 · L260 | unsaved changes can be canceled or discarded on back | [location_context_settings_page][m182] | `expect(find.text('Save'), findsOneWidget)`；`expect(config.enabled, isFalse)` | 保留 · [#929](#case-929) updates location context settings from the page |
| <a id='case-932'></a>932 · L296 | renders localized Chinese labels | [location_context_settings_page][m182] | `expect(find.text('位置上下文'), findsOneWidget)`；`expect(find.text('已保存'), findsOneWidget)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-933'></a>933 · L306 | enabling location context does not request permission | [location_context_settings_page][m182] | `expect(requestCount, 0)` | 保留 · [#936](#case-936) permission guidance can request permission and retest |
| <a id='case-934'></a>934 · L324 | test button displays a fresh reverse-geocoded location | [location_context_settings_page][m182] | `expect(find.text('Current location is ready'), findsOneWidget)`；`expect(find.textContaining('GPS: fresh'), findsOneWidget)` | 保留 · [#939](#case-939) explains GPS-only reverse geocode failure |
| <a id='case-935'></a>935 · L379 | test button displays unavailable status without crashing | [location_context_settings_page][m182] | `expect(find.textContaining('GPS: unavailable'), findsOneWidget)`；`expect(find.textContaining('Reverse geocode: unavailable'), findsOneWidget)` | 保留 · [#940](#case-940) a localized failure message |
| <a id='case-936'></a>936 · L409 | permission guidance can request permission and retest | [location_context_settings_page][m182] | `expect(requestCount, 1)`；`expect(find.text('Current location is ready'), findsOneWidget)` | 保留 · [#937](#case-937) service disabled guidance opens location settings |
| <a id='case-937'></a>937 · L468 | service disabled guidance opens location settings | [location_context_settings_page][m182] | `expect(find.text('System location is off'), findsOneWidget)` | 保留 · [#936](#case-936) permission guidance can request permission and retest |
| <a id='case-938'></a>938 · L506 | blocked and approximate states point to app settings | [location_context_settings_page][m182] | `expect(appSettingsOpenCount, 1)`；`expect(find.text('Open app settings'), findsOneWidget)` | 保留 · [#937](#case-937) service disabled guidance opens location settings |
| <a id='case-939'></a>939 · L575 | test button explains GPS-only reverse geocode failure | [location_context_settings_page][m182] | `expect(find.textContaining('Reverse geocode: unavailable'), findsOneWidget)`；`expect(find.textContaining('Reason: reverse geocode unavailable (amap)'), findsOneWidget)` | 保留 · [#934](#case-934) displays a fresh reverse-geocoded location |
| <a id='case-940'></a>940 · L617 | test button displays a localized failure message | [location_context_settings_page][m182] | `expect(find.textContaining('Failed: Bad state: mock location failure'), findsOneWidget)` | 保留 · [#935](#case-935) unavailable status without crashing |

</details>

<details>
<summary>test/ui/settings/model_agent_config_pages_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-941'></a>941 · L69 | model config page can set a custom config as default | [model_config_list_page][m183] | `expect(await UserStorage.getDefaultLLMConfigKey(), customDefault.key)`；`expect(find.text(UserStorage.l10n.modelSetAsDefault(customDefault.modelId)), findsOneWidget)` | 保留 · [#942](#case-942) exposes a prominent add action |
| <a id='case-942'></a>942 · L90 | model config page exposes a prominent add action | [model_config_list_page][m183] | `expect(addAction, findsOneWidget)`；`expect(find.byType(ModelConfigEditPage), findsOneWidget)` | 保留 · [#941](#case-941) can set a custom config as default |
| <a id='case-943'></a>943 · L110 | agent model assignments stay collapsed but remain reachable | [agent_config_list_page][m184] | `expect(find.byKey(const ValueKey('agent-model-assignments-action')), findsNothing)`；`expect(find.byType(AgentConfigListPage), findsOneWidget)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-944'></a>944 · L156 | agent config page discovers registered agents and shows default choice | [agent_definitions][m185] | `expect(find.text(AgentDefinitions.displayNames[AgentDefinitions.chatAgent]!), findsOneWidget)`；`expect(find.text('Default: custom / custom-model'), findsWidgets)` | 保留 · [#941](#case-941) model config page can set a custom config as default |

</details>

<details>
<summary>test/ui/settings/oauth_authorize_l10n_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-945'></a>945 · L14 | OAuth authorize UI strings are localized | [app_localizations][m130] | `expect(l10n.authorizedAs('user@example.com'), contains('user@example.com'))`；`expect(l10n.loadHistoryFailed('timeout'), contains('timeout'))` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/ui/settings/view_models/ai_service_setup_viewmodel_test.dart · 6 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-946'></a>946 · L65 | loadModelRoles hydrates role and speech settings | [ai_service_setup_viewmodel][m186] | `expect(viewModel.isRoleLoading, isFalse)`；`expect(viewModel.roleSelection?.textConfigKey, textConfig.key)` | 保留 · [#951](#case-951) primary model updates persist and refresh ViewModel state |
| <a id='case-947'></a>947 · L82 | connectionMode separates unconfigured official and custom states | [ai_service_setup_viewmodel][m186] | `expect(memexViewModel.connectionMode, AiServiceConnectionMode.memexOfficial)`；`expect(customViewModel.connectionMode, AiServiceConnectionMode.customProvider)` | 保留 · [#946](#case-946) loadModelRoles hydrates role and speech settings |
| <a id='case-948'></a>948 · L111 | saveMemexService persists official provider and refreshes roles | [ai_service_setup_viewmodel][m186] | `expect(memexConfig.type, LLMConfig.typeMemex)`；`expect(memexConfig.modelId, 'memex-fast')` | 保留 · [#949](#case-949) clearMemexService resets official provider and falls back |
| <a id='case-949'></a>949 · L138 | clearMemexService resets official provider and falls back | [ai_service_setup_viewmodel][m186] | `expect(defaultConfig.type, isNot(LLMConfig.typeMemex))`；`expect(viewModel.isMemexLoggedIn, isFalse)` | 保留 · [#948](#case-948) saveMemexService persists official provider and refreshes roles |
| <a id='case-950'></a>950 · L173 | showMemexServiceSetup opens setup even when config fetch fails | [ai_service_setup_viewmodel][m186] | `expect(viewModel.showMemexSetup, isTrue)`；`expect(viewModel.isMemexConfigLoading, isFalse)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-951'></a>951 · L190 | primary model updates persist and refresh ViewModel state | [ai_service_setup_viewmodel][m186] | `expect(viewModel.roleSelection?.textConfigKey, textConfig.key)` | 保留 · [#946](#case-946) loadModelRoles hydrates role and speech settings |

</details>

<details>
<summary>test/ui/settings/view_models/debug_settings_viewmodel_test.dart · 10 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-952'></a>952 · L17 | createReprocessCardsTask starts Super Agent reprocess | [debug_settings_viewmodel][m187] | `expect(dataController.superAgentReprocesses, hasLength(1))`；`expect(options.scope, ReprocessCardsScope.cardsOnly)` | 保留 · [#953](#case-953) requires a user and resets loading |
| <a id='case-953'></a>953 · L37 | createReprocessCardsTask requires a user and resets loading | [debug_settings_viewmodel][m187] | `expectLater(viewModel.createReprocessCardsTask(const ReprocessCardsDebugOptions(…<DebugSettingsUserNotFoundException>()))`；`expect(viewModel.isReprocessingCards, isFalse)` | 保留 · [#952](#case-952) starts Super Agent reprocess |
| <a id='case-954'></a>954 · L51 | related follow-up prompt only names available agent capabilities | [debug_settings_viewmodel][m187] | `expect(message, contains('related PKM or knowledge insight'))` | 保留 · 未找到同一行为的替代项 |
| <a id='case-955'></a>955 · L62 | date range task options format payload consistently | [debug_settings_viewmodel][m187] | `expect(payload['date_from'], '2026-06-01')`；`expect(DebugDateRangeTaskOptions.formatDate(DateTime(2026, 1, 9)), '2026-01-09')` | 保留 · 未找到同一行为的替代项 |
| <a id='case-956'></a>956 · L78 | clearToken clears user and resets router state | [debug_settings_viewmodel][m187] | `expect(dataController.accountChanges, [null])` | 保留 · [#957](#case-957) clearData requires user and clears local data |
| <a id='case-957'></a>957 · L88 | clearData requires user and clears local data | [debug_settings_viewmodel][m187] | `expect(cleared, isTrue)`；`expect(dataController.clearDataCount, 1)` | 保留 · [#956](#case-956) clearToken clears user and resets router state |
| <a id='case-958'></a>958 · L100 | cloneToTestUser clones, switches user, and resets router state | [debug_settings_viewmodel][m187] | `expect(result?.targetUserId, 'test_clone')`；`expect(dataController.cloneRequests.single.targetUserId, 'test_clone')` | 保留 · [#956](#case-956) clearToken clears user and resets router state |
| <a id='case-959'></a>959 · L129 | clearFailedAgentContexts returns cleared count | [debug_settings_viewmodel][m187] | `expect(viewModel.isClearingFailedAgentContexts, isFalse)`；`expect(dataController.clearFailedAgentContextsCount, 1)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-960'></a>960 · L142 | creates comments reprocess task | [debug_settings_viewmodel][m187] | `expect(await viewModel.createReprocessCommentsTask(options), isTrue)`；`expect(dataController.enqueuedTasks.single.taskType, 'reprocess_comments_task')` | 保留 · [#952](#case-952) createReprocessCardsTask starts Super Agent reprocess |
| <a id='case-961'></a>961 · L168 | rebuildSearchIndex delegates to data controller | [debug_settings_viewmodel][m187] | `expect(viewModel.isRebuildingSearchIndex, isFalse)`；`expect(dataController.rebuildAllFtsIndexesCount, 1)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/ui/settings/widgets/agent_state_viewer_page_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-962'></a>962 · L20 | renders parent state with linked child state ids | [agent_state_viewer_page][m188] | `expect(find.textContaining('Linked Child States'), findsOneWidget)`；`expect(find.textContaining('Linked child state: ′manage_card_child_1′'), findsOneWidget)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-963'></a>963 · L189 | scrolls state content to bottom and top | [agent_state_viewer_page][m188] | `expect(position.maxScrollExtent, greaterThan(0))`；`expect(position.pixels, 0)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/ui/settings/widgets/ai_service_setup_page_test.dart · 12 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-964'></a>964 · L25 | hub renders connection choices without custom model controls | [ai_service_setup_page][m189] | `expect(find.text(UserStorage.l10n.aiModelHubTitle), findsWidgets)`；`expect(find.text(UserStorage.l10n.aiSetupChooseConnectionTitle), findsOneWidget)` | 保留 · [#969](#case-969) official route opens the existing Memex auth flow |
| <a id='case-965'></a>965 · L64 | current setup shows only the active config name | [ai_service_setup_page][m189] | `expect(find.text(activeConfig.key), findsOneWidget)`；`expect(find.textContaining(activeConfig.modelId), findsNothing)` | 保留 · [#966](#case-966) names the Memex official connection |
| <a id='case-966'></a>966 · L94 | current setup names the Memex official connection | [ai_service_setup_page][m189] | `expect(find.text(UserStorage.l10n.aiSetupStatusMemexTitle), findsOneWidget)`；`expect(find.text(UserStorage.l10n.aiSetupStatusMemexDescription), findsNothing)` | 保留 · [#965](#case-965) shows only the active config name |
| <a id='case-967'></a>967 · L121 | settings registry model config entry opens AI model hub | [ai_service_setup_page][m189] | `expect(item.title, UserStorage.l10n.aiModelHubTitle)`；`expect(item.description, UserStorage.l10n.aiModelHubSubtitle)` | 保留 · [#968](#case-968) app lock settings entry opens the lock controls |
| <a id='case-968'></a>968 · L145 | app lock settings entry opens the lock controls | [ai_service_setup_page][m189] | `expect(find.byType(AppLockSettingsPage), findsOneWidget)`；`expect(find.text(UserStorage.l10n.enableAppLock), findsOneWidget)` | 保留 · [#967](#case-967) settings registry model config entry opens AI model hub |
| <a id='case-969'></a>969 · L163 | official route opens the existing Memex auth flow | [ai_service_setup_page][m189] | `expect(find.byType(MemexOfficialServicePage), findsOneWidget)`；`expect(find.text(UserStorage.l10n.aiServiceMemexRouteTitle), findsWidgets)` | 保留 · [#971](#case-971) first custom setup opens the compact model editor directly |
| <a id='case-970'></a>970 · L187 | official service page still saves Memex credentials | [ai_service_setup_page][m189] | `expect(memexConfig.type, LLMConfig.typeMemex)`；`expect(memexConfig.baseUrl, 'https://memex.example/v1')` | 保留 · [#966](#case-966) current setup names the Memex official connection |
| <a id='case-971'></a>971 · L225 | first custom setup opens the compact model editor directly | [ai_service_setup_page][m189] | `expect(find.byType(ModelConfigEditPage), findsOneWidget)`；`expect(find.text(UserStorage.l10n.advancedAgentModelAssignments), findsNothing)` | 保留 · [#972](#case-972) one valid custom model opens that model directly |
| <a id='case-972'></a>972 · L253 | one valid custom model opens that model directly | [ai_service_setup_page][m189] | `expect(find.byType(ModelConfigEditPage), findsOneWidget)`；`expect(find.text(customConfig.modelId), findsOneWidget)` | 保留 · [#975](#case-975) onboarding custom model save completes setup flow |
| <a id='case-973'></a>973 · L277 | multiple valid custom models open the model list | [ai_service_setup_page][m189] | `expect(find.byType(ModelConfigListPage), findsOneWidget)`；`expect(find.text(secondConfig.key), findsOneWidget)` | 保留 · [#972](#case-972) one valid custom model opens that model directly |
| <a id='case-974'></a>974 · L309 | onboarding skip completes without saving credentials | [ai_service_setup_page][m189] | `expect(completed, isTrue)` | 保留 · [#975](#case-975) custom model save completes setup flow |
| <a id='case-975'></a>975 · L328 | onboarding custom model save completes setup flow | [ai_service_setup_page][m189] | `expect(find.byType(ModelConfigEditPage), findsOneWidget)`；`expect(await UserStorage.getDefaultLLMConfigKey(), customConfig.key)` | 保留 · [#972](#case-972) one valid custom model opens that model directly |

</details>

<details>
<summary>test/ui/settings/widgets/async_task_load_error_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-976'></a>976 · L15 | uses localized operationFailed for load errors | [async_task_list_page][m190] | `expect(asyncTaskLoadErrorMessage('timeout'), UserStorage.l10n.operationFailed('timeout'))` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/ui/settings/widgets/backup_restore_confirm_dialog_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-977'></a>977 · L17 | renders manifest metadata and confirms restore | [backup_restore_confirm_dialog][m191] | `expect(find.text(UserStorage.l10n.confirmRestore), findsOneWidget)`；`expect(find.text(UserStorage.l10n.confirmRestoreMessage), findsOneWidget)` | 保留 · [#978](#case-978) legacy backup details and cancels restore |
| <a id='case-978'></a>978 · L46 | renders legacy backup details and cancels restore | [backup_restore_confirm_dialog][m191] | `expect(find.text(UserStorage.l10n.backupLegacyFormat), findsOneWidget)`；`expect(find.text(UserStorage.l10n.backupImportFlavor), findsNothing)` | 保留 · [#977](#case-977) manifest metadata and confirms restore |
| <a id='case-979'></a>979 · L73 | keeps long metadata readable in a scrollable dialog | [backup_restore_confirm_dialog][m191] | `expect(find.byType(SingleChildScrollView), findsOneWidget)`；`expect(find.text('globalEarly-channel-with-a-very-long-internal-build-label'), findsOneWidget)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-980'></a>980 · L100 | formats byte and gigabyte sizes | [backup_restore_confirm_dialog][m191] | `expect(find.text('2.0 GB'), findsOneWidget)` | 保留 · [#978](#case-978) renders legacy backup details and cancels restore |

</details>

<details>
<summary>test/ui/settings/widgets/backup_restore_page_test.dart · 11 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-981'></a>981 · L21 | renders automatic backup settings and persists toggle | [backup_restore_page][m192] | `expect(find.text(UserStorage.l10n.automaticBackup), findsOneWidget)`；`expect(await UserStorage.isAutoBackupEnabled('backup-test-user'), isTrue)` | 保留 · [#986](#case-986) manual snapshot refresh does not rescan estimated source size |
| <a id='case-982'></a>982 · L36 | shows estimated backup size and persists retention policy | [backup_restore_page][m192] | `expect(find.text(UserStorage.l10n.estimatedSize), findsOneWidget)`；`expect(find.text(UserStorage.l10n.autoBackupRetentionDays(30)), findsOneWidget)` | 保留 · [#986](#case-986) manual snapshot refresh does not rescan estimated source size |
| <a id='case-983'></a>983 · L101 | shows stored automatic and safety snapshots with restore confirmation | [backup_restore_page][m192] | `expect(find.text(safetyName), findsOneWidget)`；`expect(find.text(UserStorage.l10n.confirmRestoreMessage), findsOneWidget)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-984'></a>984 · L162 | deletes one backup from a mixed history after confirmation | [backup_restore_page][m192] | `expect(find.text(UserStorage.l10n.confirmDeleteBackup), findsOneWidget)`；`expect(find.text(UserStorage.l10n.backupDeleted(oldAutoName)), findsOneWidget)` | 保留 · [#987](#case-987) refreshes stored backup list when backup event is emitted |
| <a id='case-985'></a>985 · L246 | manual snapshot button refreshes list and status | [backup_restore_page][m192] | `expect(trigger, 'manual')`；`expect(find.text(UserStorage.l10n.autoBackupCreated(snapshot.name)), findsOneWidget)` | 保留 · [#986](#case-986) refresh does not rescan estimated source size |
| <a id='case-986'></a>986 · L288 | manual snapshot refresh does not rescan estimated source size | [backup_restore_page][m192] | `expect(estimateCalls, 1)` | 保留 · [#985](#case-985) button refreshes list and status |
| <a id='case-987'></a>987 · L326 | refreshes stored backup list when backup event is emitted | [backup_restore_page][m192] | `expect(find.text(snapshot.name), findsOneWidget)` | 保留 · [#985](#case-985) manual snapshot button refreshes list and status |
| <a id='case-988'></a>988 · L359 | shows Android backup location picker menu | [backup_restore_page][m192] | `expect(find.text(UserStorage.l10n.defaultBackupLocation), findsOneWidget)`；`expect(find.text(UserStorage.l10n.chooseBackupLocation), findsOneWidget)` | 保留 · [#991](#case-991) SAF folder name and URI details |
| <a id='case-989'></a>989 · L375 | opens copyable full backup location details | [backup_restore_page][m192] | `expect(find.text(UserStorage.l10n.backupLocationDetails), findsOneWidget)`；`expect(find.text(UserStorage.l10n.backupLocationFullPath), findsOneWidget)` | 保留 · [#990](#case-990) shows iOS Files label with full sandbox path in details |
| <a id='case-990'></a>990 · L400 | shows iOS Files label with full sandbox path in details | [backup_restore_page][m192] | `expect(detail.data, fullPath)` | 保留 · [#989](#case-989) opens copyable full backup location details |
| <a id='case-991'></a>991 · L426 | shows Android SAF folder name and URI details | [backup_restore_page][m192] | `expect(find.text(UserStorage.l10n.androidBackupLocationSelected('MemexBackups')), findsOneWidget)`；`expect(detail.data, treeUri)` | 保留 · [#988](#case-988) backup location picker menu |

</details>

<details>
<summary>test/ui/settings/widgets/data_import_page_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-992'></a>992 · L17 | processing dialog updates impact text as options change | [data_import_page][m193] | `expect(find.text(UserStorage.l10n.dataImportImpactNone), findsOneWidget)`；`expect(find.text(UserStorage.l10n.dataImportImpactTimelineCards), findsOneWidget)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/ui/settings/widgets/debug_settings_page_test.dart · 5 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-993'></a>993 · L22 | clears failed agent contexts from debugging page | [debug_settings_page][m194] | `expect(clearCount, 1)` | 保留 · [#994](#case-994) disables clear failed contexts while loading |
| <a id='case-994'></a>994 · L48 | disables clear failed contexts while loading | [debug_settings_page][m194] | `expect(clearCount, 0)` | 保留 · [#993](#case-993) clears failed agent contexts from debugging page |
| <a id='case-995'></a>995 · L73 | search result Debug reprocess cards opens dialog and creates task | [debug_settings_page][m194] | `expect(find.byType(ReprocessCardsDialog), findsOneWidget)`；`expect(find.text(UserStorage.l10n.reprocessCardsTaskCreated), findsOneWidget)` | 保留 · [#996](#case-996) reprocess cards dialog defaults to card-only mode |
| <a id='case-996'></a>996 · L125 | reprocess cards dialog defaults to card-only mode | [debug_settings_page][m194] | `expect(find.text(UserStorage.l10n.reprocessCardsCardOnly), findsOneWidget)`；`expect(submitted!.toTaskPayload(), containsPair(ReprocessCardsPayloadKeys.scope,…ocessCardsScope.cardsOnly.payloadValue))` | 保留 · [#997](#case-997) submits related follow-up scope |
| <a id='case-997'></a>997 · L160 | reprocess cards dialog submits related follow-up scope | [debug_settings_page][m194] | `expect(payload[ReprocessCardsPayloadKeys.scope], ReprocessCardsScope.cardsAndRelatedFollowUps.payloadValue)`；`expect(payload['reanalyze_assets'], isTrue)` | 保留 · [#996](#case-996) defaults to card-only mode |

</details>

<details>
<summary>test/ui/settings/widgets/early_update_settings_card_test.dart · 5 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-998'></a>998 · L35 | renders defaults and persists Wi-Fi-only toggle | [early_update_settings_card][m195] | `expect(find.text(UserStorage.l10n.earlyUpdateSettingsTitle), findsOneWidget)`；`expect(settings.wifiOnlyDownloads, isFalse)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-999'></a>999 · L54 | manual check reveals update and download opens installer | [early_update_settings_card][m195] | `expect(find.text(UserStorage.l10n.earlyUpdateDownloadAndInstall), findsOneWidget)`；`expect(find.text(UserStorage.l10n.earlyUpdateInstallStarted), findsOneWidget)` | 保留 · [#1000](#case-1000) shows active background download and disables manual actions |
| <a id='case-1000'></a>1000 · L83 | shows active background download and disables manual actions | [early_update_settings_card][m195] | `expect(find.text(UserStorage.l10n.earlyUpdateDownloadInProgress), findsOneWidget)`；`expect(service.downloadCallCount, 0)` | 保留 · [#1001](#case-1001) background download becomes installable after polling |
| <a id='case-1001'></a>1001 · L130 | background download becomes installable after polling | [early_update_settings_card][m195] | `expect(find.text(UserStorage.l10n.earlyUpdateDownloadReadyToInstall), findsOneWidget)`；`expect(find.text(UserStorage.l10n.earlyUpdateInstallDownloadedPackage), findsOneWidget)` | 保留 · [#1000](#case-1000) shows active background download and disables manual actions |
| <a id='case-1002'></a>1002 · L173 | can install cached update package and clear cache | [early_update_settings_card][m195] | `expect(find.text(UserStorage.l10n.earlyUpdateInstallDownloadedPackage), findsOneWidget)`；`expect(find.text(UserStorage.l10n.earlyUpdateClearDownloadedPackage), findsNothing)` | 保留 · [#1001](#case-1001) background download becomes installable after polling |

</details>

<details>
<summary>test/ui/settings/widgets/experimental_lab_page_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1003'></a>1003 · L16 | renders empty labs shell | [experimental_lab_page][m196] | `expect(find.text(UserStorage.l10n.experimentalLabDescription), findsOneWidget)` | 保留实验室空页的标题和描述。只覆盖页面打开后的可见结果。 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/ui/settings/widgets/invalid_model_config_dialog_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1004'></a>1004 · L17 | explains missing AI without agent or config key | [invalid_model_config_dialog][m197] | `expect(find.text(UserStorage.l10n.invalidModelConfigPlain), findsOneWidget)`；`expect(find.text(UserStorage.l10n.turnOnAi), findsOneWidget)` | 保留 · [#1005](#case-1005) an empty API key matches the chat error |
| <a id='case-1005'></a>1005 · L45 | an empty API key matches the chat error | [invalid_model_config_dialog][m197] | `expect(find.textContaining('chat_agent'), findsNothing)`；`expect(find.textContaining('default'), findsNothing)` | 保留 · [#1004](#case-1004) explains missing AI without agent or config key |

</details>

<details>
<summary>test/ui/settings/widgets/model_config_edit_page_test.dart · 7 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1006'></a>1006 · L39 | ModelConfigEditPage duplicate mode shows "Duplicate Configuration" title when duplicateSource is provided | [model_config_edit_page][m198] | `expect(find.text('Duplicate Configuration'), findsOneWidget)` | 保留 · [#1008](#case-1008) save button is present when duplicateSource is provided |
| <a id='case-1007'></a>1007 · L52 | ModelConfigEditPage duplicate mode pre-fills fields from duplicateSource | [model_config_edit_page][m198] | `expect(find.text('source-config'), findsOneWidget)`；`expect(find.text('https://api.openai.com/v1'), findsOneWidget)` | 保留 · [#1006](#case-1006) shows "Duplicate Configuration" title when duplicateSource is provided |
| <a id='case-1008'></a>1008 · L69 | ModelConfigEditPage duplicate mode save button is present when duplicateSource is provided | [model_config_edit_page][m198] | `expect(find.byKey(const ValueKey('model_config_bottom_save_button')), findsOneWidget)`；`expect(find.descendant(of: find.byKey(const ValueKey('model_config_bottom_save_b…ing: find.text('Save')), findsOneWidget)` | 并入 [#1009](#case-1009)，顶部保存实际写入，底部保存入口及文字也受校验。 · [#1009](#case-1009) saves duplicate config with unique key |
| <a id='case-1009'></a>1009 · L93 | ModelConfigEditPage duplicate mode saves duplicate config with unique key | [model_config_edit_page][m198] | `expect(duplicated.apiKey, customConfig.apiKey)`；`expect(duplicated.proxyUrl, customConfig.proxyUrl)` | 保留 · [#1008](#case-1008) save button is present when duplicateSource is provided |
| <a id='case-1010'></a>1010 · L142 | ModelConfigEditPage duplicate mode increments counter when duplicate key already exists | [model_config_edit_page][m198] | `expect(configs.any((c) => c.key == 'myconfig_copy_2'), isTrue)` | 保留 · [#1009](#case-1009) saves duplicate config with unique key |
| <a id='case-1011'></a>1011 · L189 | ModelConfigEditPage provider selection renders DeepSeek configuration with official defaults | [model_config_edit_page][m198] | `expect(find.textContaining('DeepSeek'), findsWidgets)`；`expect(find.text('deepseek-v4-flash'), findsOneWidget)` | 保留 · [#1006](#case-1006) duplicate mode shows "Duplicate Configuration" t…licateSource is provided |
| <a id='case-1012'></a>1012 · L214 | ModelConfigEditPage simple setup mode hides the internal key and generates one when saved | [model_config_edit_page][m198] | `expect(find.text(UserStorage.l10n.keyIdLabel), findsNothing)`；`expect(savedConfig.key, 'deepseek')` | 保留 · [#1010](#case-1010) duplicate mode increments counter when duplicate key already exists |

</details>

<details>
<summary>test/ui/settings/widgets/vocal_tone_settings_card_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1013'></a>1013 · L17 | vocal tone starts off and the switch reports the new value | [vocal_tone_settings_card][m199] | `expect(find.text(UserStorage.l10n.analyzeVocalToneTitle), findsOneWidget)`；`expect(find.text(UserStorage.l10n.analyzeVocalToneDesc), findsOneWidget)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/ui/timeline/view_models/timeline_viewmodel_test.dart · 11 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1014'></a>1014 · L10 | timeline card idempotency helpers upsert inserts a new local card at the top | [timeline_viewmodel][m128] | `expect(result.map((card) => card.id), ['2026/05/18.md#ts_3', '2026/05/18.md#ts_1', '2026/05/18.md#ts_2'])` | 保留 · [#1015](#case-1015) replaces a duplicate local submission instead of appending |
| <a id='case-1015'></a>1015 · L28 | timeline card idempotency helpers upsert replaces a duplicate local submission instead of appending | [timeline_viewmodel][m128] | `expect(result, hasLength(2))`；`expect(result.where((card) => card.id == '2026/05/18.md#ts_1'), hasLength(1))` | 保留 · [#1016](#case-1016) update collapses duplicate processing copies in their first position |
| <a id='case-1016'></a>1016 · L59 | timeline card idempotency helpers update collapses duplicate processing copies in their first position | [timeline_viewmodel][m128] | `expect(result.where((card) => card.id == '2026/05/18.md#ts_1'), hasLength(1))` | 保留 · [#1015](#case-1015) upsert replaces a duplicate local submission instead of appending |
| <a id='case-1017'></a>1017 · L98 | timeline card idempotency helpers update leaves unloaded cards out of the current filtered list | [timeline_viewmodel][m128] | `expect(result.map((card) => card.title), ['visible card'])` | 保留 · [#1016](#case-1016) collapses duplicate processing copies in their first position |
| <a id='case-1018'></a>1018 · L110 | timeline card idempotency helpers dedupe keeps the already loaded page copy across pagination overlap | [timeline_viewmodel][m128] | `expect(result.map((card) => card.title), ['top', 'page one boundary', 'older'])` | 保留 · [#1016](#case-1016) update collapses duplicate processing copies in their first position |
| <a id='case-1019'></a>1019 · L132 | timeline card idempotency helpers preparation drops legacy schedule briefing cards | [timeline_viewmodel][m128] | `expect(result.map((card) => card.id), ['2026/05/18.md#ts_1'])` | 保留 · [#1020](#case-1020) add ignores a retired schedule briefing event card |
| <a id='case-1020'></a>1020 · L158 | timeline card idempotency helpers add ignores a retired schedule briefing event card | [timeline_viewmodel][m128] | `expect(viewModel.cards, isEmpty)` | 保留 · [#1021](#case-1021) update removes a card that becomes a retired schedule briefing |
| <a id='case-1021'></a>1021 · L176 | timeline card idempotency helpers update removes a card that becomes a retired schedule briefing | [timeline_viewmodel][m128] | `expect(viewModel.cards, isEmpty)` | 保留 · [#1020](#case-1020) add ignores a retired schedule briefing event card |
| <a id='case-1022'></a>1022 · L199 | timeline card idempotency helpers card removed event clears an emitted processing placeholder | [timeline_viewmodel][m128] | `expect(viewModel.cards, isEmpty)` | 保留 · [#1020](#case-1020) add ignores a retired schedule briefing event card |
| <a id='case-1023'></a>1023 · L223 | timeline tag refresh sameTimelineTags compares name icon and type | [timeline_viewmodel][m128] | `expect(sameTimelineTags([TagModel(name: 'Work', icon: '💼', iconType: TagIconType… iconType: TagIconType.emoji)]), isTrue)` | 保留 · [#1024](#case-1024) fetchTags does not notify when the tag list is unchanged |
| <a id='case-1024'></a>1024 · L237 | timeline tag refresh fetchTags does not notify when the tag list is unchanged | [timeline_viewmodel][m128] | `expect(viewModel.tags.single.name, 'Work')`；`expect(notifications, 1)` | 保留 · [#1028](#case-1028) refresh keeps timeline usable when unawaited fetchTags throws |

</details>

<details>
<summary>test/ui/timeline/widgets/card_address_visibility_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1025'></a>1025 · L5 | hides empty and Unknown placeholder addresses | [timeline_card_detail_screen][m125] | `expect(shouldShowCardAddress('Unknown'), isFalse)`；`expect(shouldShowCardAddress('Tokyo'), isTrue)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/ui/timeline/widgets/timeline_aux_query_isolation_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1026'></a>1026 · L58 | timeline refresh renders cards and settles while auxiliary queries hang or fail | [timeline_viewmodel][m128] | `expectLater(refresh, completes)`；`expect(find.byKey(const ValueKey('timeline-loading')), findsNothing)` | 保留 · [#1028](#case-1028) refresh keeps timeline usable when unawaited fetchTags throws |
| <a id='case-1027'></a>1027 · L105 | stale refresh return after tab switch does not leave loading on | [timeline_viewmodel][m128] | `expect(find.byKey(const ValueKey('timeline-loading')), findsOneWidget)`；`expect(vm.isLoading, isFalse)` | 保留 · [#1028](#case-1028) refresh keeps timeline usable when unawaited fetchTags throws |
| <a id='case-1028'></a>1028 · L151 | refresh keeps timeline usable when unawaited fetchTags throws | [timeline_viewmodel][m128] | `expectLater(vm.refresh(), completes)`；`expect(vm.tags, isEmpty)` | 保留 · [#1026](#case-1026) timeline refresh renders cards and settles while…ary queries hang or fail |
| <a id='case-1029'></a>1029 · L181 | timeline navigation no longer exposes a schedule tab | [timeline_screen][m180] | `expect(find.text(UserStorage.l10n.timelineFilterAll), findsOneWidget)`；`expect(find.text(UserStorage.l10n.schedule), findsNothing)` | 保留 · [#927](#case-927) TimelineFilterBar lays out without overflow in Arabic RTL |

</details>

<details>
<summary>test/ui/timeline/widgets/timeline_card_detail_body_section_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1030'></a>1030 · L8 | ignores structured card content and preserves raw fact text | [timeline_card_detail_screen][m125] | `expect(find.textContaining('## 晚餐记录', findRichText: true), findsOneWidget)`；`expect(find.text('一家人吃了家常晚餐，还尝到了太顺杨梅。'), findsNothing)` | 保留。含结构化模板和无模板时均须显示原文；前者额外拦截模板正文替换原文。 · [#1031](#case-1031) preserves raw fact markdown markers as plain text |
| <a id='case-1031'></a>1031 · L43 | preserves raw fact markdown markers as plain text | [timeline_card_detail_screen][m125] | `expect(find.textContaining('## 晚餐记录', findRichText: true), findsOneWidget)`；`expect(find.text('晚餐记录'), findsNothing)` | 保留。含结构化模板和无模板时均须显示原文；前者额外拦截模板正文替换原文。 · [#1030](#case-1030) ignores structured card content and preserves raw fact text |
| <a id='case-1032'></a>1032 · L66 | ignores legacy html config and renders raw fact | [timeline_card_detail_screen][m125] | `expect(find.text('普通正文'), findsOneWidget)` | 保留 · [#1030](#case-1030) structured card content and preserves raw fact text |
| <a id='case-1033'></a>1033 · L86 | keeps tag taps working when content is selectable | [timeline_card_detail_screen][m125] | `expect(tappedTag, 'Visual')` | 保留 · [#1030](#case-1030) ignores structured card content and preserves raw fact text |

</details>

<details>
<summary>test/ui/timeline/widgets/timeline_chrome_header_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1034'></a>1034 · L24 | chrome header stays mounted when the timeline list notifies | [timeline_screen][m180] | `expect(find.byType(MemexBrandTitle), findsOneWidget)` | 加强。时间线通知前后检查同一个 Element，能发现标题被卸载后再挂载。 · [#903](#case-903) reading tab view models does not rebuild siblings on notify |

</details>

<details>
<summary>test/ui/timeline/widgets/timeline_entry_dedupe_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1035'></a>1035 · L18 | renders one processing entry after duplicate submission upsert | [timeline_viewmodel][m128] | `expect(find.text('fresh processing copy'), findsOneWidget)`；`expect(find.text('older neighbor'), findsOneWidget)` | 保留 · [#1036](#case-1036) completed entry after duplicate processing update |
| <a id='case-1036'></a>1036 · L48 | renders one completed entry after duplicate processing update | [timeline_viewmodel][m128] | `expect(find.byType(TimelineEntryItem), findsOneWidget)`；`expect(find.text('completed result'), findsOneWidget)` | 保留 · [#1035](#case-1035) processing entry after duplicate submission upsert |
| <a id='case-1037'></a>1037 · L81 | classic processing placeholder does not show model setup hint | [timeline_screen][m180] | `expect(find.text(UserStorage.l10n.pendingAiProcessingHint), findsNothing)` | 保留 · [#1038](#case-1038) non-classic processing card keeps model setup hint |
| <a id='case-1038'></a>1038 · L105 | non-classic processing card keeps model setup hint | [timeline_card_model][m200] | `expect(find.text(UserStorage.l10n.pendingAiProcessingHint), findsOneWidget)` | 保留 · [#1037](#case-1037) classic processing placeholder does not show model setup hint |

</details>

<details>
<summary>test/ui/timeline/widgets/timeline_loading_spinner_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1039'></a>1039 · L26 | empty timeline loading uses a larger spinner | [timeline_screen][m180] | `expect(loading.size, 72)` | 删除。原用例固定 72 像素。[#1027](#case-1027) 检查切换筛选前后加载标志出现、消失和新卡可见。 · [#1027](#case-1027) stale refresh return after tab switch does not leave loading on |

</details>

<details>
<summary>test/ui/timeline/widgets/timeline_model_config_banner_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1040'></a>1040 · L24 | banner hides and shows when LLM config events are emitted | [timeline_model_config_banner][m201] | `expect(_modelBannerFinder(), findsNothing)`；`expect(_modelBannerFinder(), findsOneWidget)` | 保留 · [#1041](#case-1041) rechecks persisted LLM config state on app resume |
| <a id='case-1041'></a>1041 · L48 | banner rechecks persisted LLM config state on app resume | [timeline_model_config_banner][m201] | `expect(_modelBannerFinder(), findsNothing)`；`expect(_modelBannerFinder(), findsOneWidget)` | 保留 · [#1040](#case-1040) hides and shows when LLM config events are emitted |
| <a id='case-1042'></a>1042 · L68 | banner rechecks after configure flow returns | [timeline_model_config_banner][m201] | `expect(_modelBannerFinder(), findsOneWidget)`；`expect(_modelBannerFinder(), findsNothing)` | 保留 · [#1041](#case-1041) persisted LLM config state on app resume |

</details>

<details>
<summary>test/utils/async_pool_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1043'></a>1043 · L5 | keeps input order while overlapping work | [async_pool][m202] | `expect(values, ['n1', 'n2', 'n3', 'n4', 'n5'])`；`expect(maxInFlight, 3)` | 保留 · [#1045](#case-1045) rejects a non-positive limit |
| <a id='case-1044'></a>1044 · L28 | returns an empty list for empty input | [async_pool][m202] | `expect(values, isEmpty)` | 保留 · [#1043](#case-1043) keeps input order while overlapping work |
| <a id='case-1045'></a>1045 · L36 | rejects a non-positive limit | [async_pool][m202] | `expect(() => mapWithLimit<int, int>([1], (item) async => item, limit: 0), throwsArgumentError)` | 保留 · [#1043](#case-1043) keeps input order while overlapping work |

</details>

<details>
<summary>test/utils/async_work_queue_test.dart · 1 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1046'></a>1046 · L6 | failed work releases its slot and queued work stays in order | [async_work_queue][m203] | `expectLater(a, throwsStateError)`；`expect(calls, [1, 2, 3])` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>test/utils/date_util_test.dart · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1047'></a>1047 · L6 | parseLocalDateTime keeps offset timestamps as the same local instant | [date_util][m204] | `expect(parsed, DateTime.parse('2026-05-15T15:00:00+08:00').toLocal())` | 保留 · [#1048](#case-1048) timezone-less timestamps in local time |
| <a id='case-1048'></a>1048 · L13 | parseLocalDateTime keeps timezone-less timestamps in local time | [date_util][m204] | `expect(parsed, DateTime(2026, 5, 15, 15))` | 保留 · [#1047](#case-1047) offset timestamps as the same local instant |
| <a id='case-1049'></a>1049 · L19 | parseLocalDateTime parses unix seconds and milliseconds as UTC instants | [date_util][m204] | `expect(parseLocalDateTime(instant.millisecondsSinceEpoch ~/ 1000)?.toUtc(), instant)` | 保留 · [#1047](#case-1047) keeps offset timestamps as the same local instant |
| <a id='case-1050'></a>1050 · L32 | parseLocalDateTime returns null for blank or invalid values | [date_util][m204] | `expect(parseLocalDateTime(' '), isNull)`；`expect(parseLocalDateTime(null), isNull)` | 保留 · [#1048](#case-1048) keeps timezone-less timestamps in local time |

</details>

<details>
<summary>test/utils/mention_parser_test.dart · 7 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1051'></a>1051 · L6 | indexOfStandaloneMention matches a mention surrounded by whitespace | [mention_parser][m205] | `expect(indexOfStandaloneMention('hello @Bob there', '@Bob'), 6)` | 保留 · [#1052](#case-1052) at the start or end of the string |
| <a id='case-1052'></a>1052 · L10 | indexOfStandaloneMention matches a mention at the start or end of the string | [mention_parser][m205] | `expect(indexOfStandaloneMention('ping @Bob', '@Bob'), 5)` | 保留 · [#1051](#case-1051) surrounded by whitespace |
| <a id='case-1053'></a>1053 · L15 | indexOfStandaloneMention matches when the mention is followed by punctuation | [mention_parser][m205] | `expect(indexOfStandaloneMention('see @Bob.', '@Bob'), 4)`；`expect(indexOfStandaloneMention('see @Bob-next', '@Bob'), 4)` | 保留 · [#1051](#case-1051) a mention surrounded by whitespace |
| <a id='case-1054'></a>1054 · L21 | indexOfStandaloneMention does not match a longer token that shares a prefix | [mention_parser][m205] | `expect(indexOfStandaloneMention('hello @Bobby', '@Bob'), -1)`；`expect(indexOfStandaloneMention('你好 @小明明', '@小明'), -1)` | 保留 · [#1056](#case-1056) an email-style prefix |
| <a id='case-1055'></a>1055 · L28 | indexOfStandaloneMention matches non-ASCII mentions with explicit boundaries | [mention_parser][m205] | `expect(indexOfStandaloneMention('你好 @小明。', '@小明'), 3)` | 保留 · [#1051](#case-1051) a mention surrounded by whitespace |
| <a id='case-1056'></a>1056 · L33 | indexOfStandaloneMention does not match an email-style prefix | [mention_parser][m205] | `expect(indexOfStandaloneMention('mail@Bob.com', '@Bob'), -1)` | 保留 · [#1057](#case-1057) returns the first standalone mention when a prefix also appears |
| <a id='case-1057'></a>1057 · L37 | indexOfStandaloneMention returns the first standalone mention when a prefix also appears | [mention_parser][m205] | `expect(indexOfStandaloneMention('@Bobby and @Bob later', '@Bob'), 11)` | 保留 · [#1056](#case-1056) does not match an email-style prefix |

</details>

<details>
<summary>test/utils/tavern_macro_test.dart · 7 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1058'></a>1058 · L6 | TavernMacro.resolve replaces {{user}} case-insensitively | [tavern_macro][m206] | `expect(TavernMacro.resolve('Hello {{user}}! And {{User}} again.', userName: 'Ali…'Bob'), 'Hello Alice! And Alice again.')` | 保留 · [#1059](#case-1059) {{char}} case-insensitively |
| <a id='case-1059'></a>1059 · L17 | TavernMacro.resolve replaces {{char}} case-insensitively | [tavern_macro][m206] | `expect(TavernMacro.resolve('{{char}} says hi. {{CHAR}} too.', userName: 'Alice',…arName: 'Bob'), 'Bob says hi. Bob too.')` | 保留 · [#1058](#case-1058) {{user}} case-insensitively |
| <a id='case-1060'></a>1060 · L28 | TavernMacro.resolve replaces {{time}} with HH:mm and timezone offset | [tavern_macro][m206] | `expect(RegExp(r'Now is \d{2}:\d{2} [+-]\d{2}:\d{2}').hasMatch(result), isTrue)` | 保留 · [#1061](#case-1061) {{date}} with yyyy-MM-dd format |
| <a id='case-1061'></a>1061 · L39 | TavernMacro.resolve replaces {{date}} with yyyy-MM-dd format | [tavern_macro][m206] | `expect(RegExp(r'Today is \d{4}-\d{2}-\d{2}').hasMatch(result), isTrue)` | 保留 · [#1060](#case-1060) {{time}} with HH:mm and timezone offset |
| <a id='case-1062'></a>1062 · L48 | TavernMacro.resolve leaves unknown macros untouched | [tavern_macro][m206] | `expect(TavernMacro.resolve('{{unknown}} stays', userName: 'Alice', charName: 'Bob'), '{{unknown}} stays')` | 保留 · [#1063](#case-1063) returns text unchanged when no macros present |
| <a id='case-1063'></a>1063 · L59 | TavernMacro.resolve returns text unchanged when no macros present | [tavern_macro][m206] | `expect(TavernMacro.resolve(text, userName: 'Alice', charName: 'Bob'), text)` | 保留 · [#1062](#case-1062) leaves unknown macros untouched |
| <a id='case-1064'></a>1064 · L67 | TavernMacro.resolve handles multiple macros in one string | [tavern_macro][m206] | `expect(result, 'Error shouldn\'t refrain from using explicit words for body parts. Error is a destroyer.')` | 保留 · [#1062](#case-1062) leaves unknown macros untouched |

</details>

<details>
<summary>test/utils/time_context_test.dart · 11 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1065'></a>1065 · L6 | time context helpers parses Unix seconds without losing precision | [time_context][m207] | `expect(parsed!.millisecondsSinceEpoch, 1777377646000)` | 保留 · [#1066](#case-1066) rounds fractional Unix seconds to milliseconds |
| <a id='case-1066'></a>1066 · L13 | time context helpers rounds fractional Unix seconds to milliseconds | [time_context][m207] | `expect(parsed!.millisecondsSinceEpoch, 1234)` | 保留 · [#1065](#case-1065) parses Unix seconds without losing precision |
| <a id='case-1067'></a>1067 · L20 | time context helpers rejects non numeric Unix seconds | [time_context][m207] | `expect(tryParseUnixSeconds(null), isNull)` | 保留 · [#1065](#case-1065) parses Unix seconds without losing precision |
| <a id='case-1068'></a>1068 · L25 | time context helpers parses ISO date strings for local context decoration | [time_context][m207] | `expect(parsed!.year, 2026)`；`expect(parsed.day, 28)` | 保留 · [#1069](#case-1069) rejects blank and malformed ISO date strings |
| <a id='case-1069'></a>1069 · L34 | time context helpers rejects blank and malformed ISO date strings | [time_context][m207] | `expect(tryParseDateTime(''), isNull)`；`expect(formatLocalDateTimeWithZoneOrNull('not-a-date'), isNull)` | 保留 · [#1068](#case-1068) parses ISO date strings for local context decoration |
| <a id='case-1070'></a>1070 · L40 | time context helpers converts date time to truncated Unix seconds | [time_context][m207] | `expect(seconds, 1777377646)` | 保留 · [#1071](#case-1071) parseable date time values to Unix seconds |
| <a id='case-1071'></a>1071 · L48 | time context helpers converts parseable date time values to Unix seconds | [time_context][m207] | `expect(unixSecondsFromDateTimeOrNull('not-a-date'), isNull)` | 保留 · [#1070](#case-1070) date time to truncated Unix seconds |
| <a id='case-1072'></a>1072 · L56 | time context helpers formats timezone offsets with sign and minutes | [time_context][m207] | `expect(formatTimeZoneOffset(const Duration(hours: -5, minutes: -30)), '-05:30')`；`expect(formatTimeZoneOffset(Duration.zero), '+00:00')` | 保留 · [#1073](#case-1073) local date time with explicit timezone context |
| <a id='case-1073'></a>1073 · L65 | time context helpers formats local date time with explicit timezone context | [time_context][m207] | `expect(formatted, contains('2026-04-28 20:00:46'))` | 保留 · [#1074](#case-1074) builds message time prefix with explicit timezone context |
| <a id='case-1074'></a>1074 · L74 | time context helpers builds message time prefix with explicit timezone context | [time_context][m207] | `expect(prefix, startsWith('<message_time>'))`；`expect(prefix, contains('2026-04-28 20:00:46'))` | 保留 · [#1073](#case-1073) formats local date time with explicit timezone context |
| <a id='case-1075'></a>1075 · L82 | time context helpers builds current time reminder with local-time label | [time_context][m207] | `expect(reminder, contains('Current Local Time:'))`；`expect(reminder, endsWith('</system-reminder>\n\n'))` | 保留 · [#1074](#case-1074) message time prefix with explicit timezone context |

</details>

<details>
<summary>test/utils/toast_helper_test.dart · 2 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1076'></a>1076 · L16 | uses unknownError when the error text is empty | [toast_helper][m208] | `expect(ToastHelper.formatErrorMessage(ApiException(' ')), UserStorage.l10n.unknownError)` | 保留 · [#1077](#case-1077) keeps ApiException messages |
| <a id='case-1077'></a>1077 · L23 | keeps ApiException messages | [toast_helper][m208] | `expect(ToastHelper.formatErrorMessage(ApiException('nope')), 'nope')` | 保留 · [#1076](#case-1076) uses unknownError when the error text is empty |

</details>

<details>
<summary>test/utils/token_usage_utils_test.dart · 12 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1078'></a>1078 · L8 | TokenUsageUtils uses prompt tokens as denominator when cached tokens are included | [token_usage_utils][m14] | `expect(TokenUsageUtils.effectivePromptTokens(promptTokens: 1000, cachedTokens: 2…chedTokensIncludedInPrompt: true), 1000)`；`expect(TokenUsageUtils.cacheRate(promptTokens: 1000, cachedTokens: 250, cachedTo…edInPrompt: true), closeTo(25.0, 0.001))` | 保留 · [#1079](#case-1079) adds cached tokens to denominator when provider returns them separately |
| <a id='case-1079'></a>1079 · L38 | TokenUsageUtils adds cached tokens to denominator when provider returns them separately | [token_usage_utils][m14] | `expect(TokenUsageUtils.effectivePromptTokens(promptTokens: 200, cachedTokens: 80…hedTokensIncludedInPrompt: false), 1000)`；`expect(TokenUsageUtils.cacheRate(promptTokens: 200, cachedTokens: 800, cachedTok…dInPrompt: false), closeTo(80.0, 0.001))` | 保留 · [#1078](#case-1078) uses prompt tokens as denominator when cached tokens are included |
| <a id='case-1080'></a>1080 · L68 | TokenUsageUtils does not infer provider semantics from token magnitude | [token_usage_utils][m14] | `expect(TokenUsageUtils.effectivePromptTokens(promptTokens: 1000, cachedTokens: 2…hedTokensIncludedInPrompt: false), 1250)`；`expect(TokenUsageUtils.cacheRate(promptTokens: 1000, cachedTokens: 250, cachedTo…dInPrompt: false), closeTo(20.0, 0.001))` | 保留 · [#1079](#case-1079) adds cached tokens to denominator when provider returns them separately |
| <a id='case-1081'></a>1081 · L95 | TokenUsageUtils detects known provider cache token semantics from usage shape | [token_usage_utils][m14] | `expect(TokenUsageUtils.cachedTokensIncludedInPrompt(originalUsage: {'cache_read_input_tokens' : 100}), isFalse)`；`expect(TokenUsageUtils.cachedTokensIncludedInPrompt(originalUsage: {'cache_creation_input_tokens' : 100}), isFalse)` | 保留 · [#1082](#case-1082) returns null when cache token semantics cannot be proven |
| <a id='case-1082'></a>1082 · L132 | TokenUsageUtils returns null when cache token semantics cannot be proven | [token_usage_utils][m14] | `expect(TokenUsageUtils.cachedTokensIncludedInPrompt(), isNull)` | 保留 · [#1081](#case-1081) detects known provider cache token semantics from usage shape |
| <a id='case-1083'></a>1083 · L139 | TokenUsageUtils detects cache token semantics from concrete client adapters | [token_usage_utils][m14] | `expect(TokenUsageUtils.cachedTokensIncludedInPrompt(client: ClaudeClient(apiKey: 'test-key')), isTrue)`；`expect(TokenUsageUtils.cachedTokensIncludedInPrompt(client: CodexResponsesClient(accessToken: 'test-token')), isTrue)` | 保留 · [#1082](#case-1082) returns null when cache token semantics cannot be proven |
| <a id='case-1084'></a>1084 · L170 | TokenUsageUtils formats cache rate without exceeding 100 percent | [token_usage_utils][m14] | `expect(TokenUsageUtils.formatCacheRate(promptTokens: 0, cachedTokens: 500, cache…okensIncludedInPrompt: false), '100.0%')` | 保留 · [#1087](#case-1087) formatCacheRateFromAggregated computes from pre-normalized values |
| <a id='case-1085'></a>1085 · L189 | TokenUsageUtils returns unavailable cache rate when cache semantics are unknown | [token_usage_utils][m14] | `expect(TokenUsageUtils.formatCacheRateOrUnavailable(promptTokens: 100, cachedTok…hedTokensIncludedInPrompt: null), 'N/A')`；`expect(TokenUsageUtils.formatCacheRateOrUnavailable(promptTokens: 100, cachedTok…edTokensIncludedInPrompt: null), '0.0%')` | 保留 · [#1082](#case-1082) null when cache token semantics cannot be proven |
| <a id='case-1086'></a>1086 · L216 | TokenUsageUtils resolveFromUsageRecord reads persisted semantics | [token_usage_utils][m14] | `expect(TokenUsageUtils.resolveFromUsageRecord({'cache_tokens_included_in_prompt' : true}), isTrue)`；`expect(TokenUsageUtils.resolveFromUsageRecord({}), isNull)` | 保留 · [#1082](#case-1082) returns null when cache token semantics cannot be proven |
| <a id='case-1087'></a>1087 · L244 | TokenUsageUtils formatCacheRateFromAggregated computes from pre-normalized values | [token_usage_utils][m14] | `expect(TokenUsageUtils.formatCacheRateFromAggregated(effectivePromptTokens: 1000, cachedTokens: 250), '25.0%')`；`expect(TokenUsageUtils.formatCacheRateFromAggregated(effectivePromptTokens: 0, cachedTokens: 0), '0.0%')` | 保留 · [#1084](#case-1084) formats cache rate without exceeding 100 percent |
| <a id='case-1088'></a>1088 · L272 | TokenUsageUtils calculateCost estimates token cost with known pricing | [token_usage_utils][m14] | `expect(costs['input'], closeTo(expectedInput, 1e-10))`；`expect(costs['total'], closeTo(expectedInput + expectedOutput, 1e-10))` | 保留 · [#1089](#case-1089) falls back to gpt-4o for unknown models |
| <a id='case-1089'></a>1089 · L292 | TokenUsageUtils calculateCost falls back to gpt-4o for unknown models | [token_usage_utils][m14] | `expect(costs['total'], closeTo(expectedInput + expectedOutput, 1e-10))` | 保留 · [#1088](#case-1088) estimates token cost with known pricing |

</details>

<details>
<summary>test/utils/user_storage_llm_config_test.dart · 6 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1090'></a>1090 · L18 | UserStorage LLM defaults agents without explicit config use selected global default | [llm_config][m120] | `expect(await UserStorage.getDefaultLLMConfigKey(), LLMConfig.defaultClientKey)`；`expect(await UserStorage.getDefaultLLMConfigKey(), customConfig.key)` | 保留 · [#1091](#case-1091) removed selected default falls back to legacy default config |
| <a id='case-1091'></a>1091 · L46 | UserStorage LLM defaults removed selected default falls back to legacy default config | [llm_config][m120] | `expect(await UserStorage.getDefaultLLMConfigKey(), LLMConfig.defaultClientKey)` | 保留 · [#1090](#case-1090) agents without explicit config use selected global default |
| <a id='case-1092'></a>1092 · L63 | UserStorage LLM defaults AgentConfig.copyWith can clear explicit model selection | [user_storage][m209] | `expect(config.copyWith(llmConfigKey: null).llmConfigKey, isNull)` | 保留 · [#1091](#case-1091) removed selected default falls back to legacy default config |
| <a id='case-1093'></a>1093 · L69 | UserStorage LLM defaults DeepSeek builds an OpenAI-compatible chat client | [user_storage][m209] | `expect(resources.client, isA<OpenAIClient>())` | 保留 · [#1094](#case-1094) Claude uses the official endpoint and SDK caching default |
| <a id='case-1094'></a>1094 · L84 | UserStorage LLM defaults Claude uses the official endpoint and SDK caching default | [user_storage][m209] | `expect(client.enablePromptCaching, isNull)` | 保留 · [#1093](#case-1093) DeepSeek builds an OpenAI-compatible chat client |
| <a id='case-1095'></a>1095 · L100 | UserStorage LLM defaults model role service maps text role to selected global default | [user_storage][m209] | `expect(await UserStorage.getDefaultLLMConfigKey(), textConfig.key)` | 保留 · [#1091](#case-1091) removed selected default falls back to legacy default config |

</details>

<details>
<summary>test/utils/user_storage_locale_test.dart · 18 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1096'></a>1096 · L8 | UserStorage locale resolution keeps supported German locale | [user_storage][m209] | `expect(locale.languageCode, 'de')` | 合并。固定 17 个已发布基础语言，逐一解析并核对 Locale，错误指明语言。 · [#1104](#case-1104) Arabic locale |
| <a id='case-1097'></a>1097 · L14 | UserStorage locale resolution keeps supported Japanese locale | [user_storage][m209] | `expect(locale.languageCode, 'ja')` | 合并。固定 17 个已发布基础语言，逐一解析并核对 Locale，错误指明语言。 · [#1104](#case-1104) Arabic locale |
| <a id='case-1098'></a>1098 · L20 | UserStorage locale resolution keeps supported Spanish locale | [user_storage][m209] | `expect(locale.languageCode, 'es')` | 合并。固定 17 个已发布基础语言，逐一解析并核对 Locale，错误指明语言。 · [#1104](#case-1104) Arabic locale |
| <a id='case-1099'></a>1099 · L26 | UserStorage locale resolution keeps supported Portuguese locale | [user_storage][m209] | `expect(locale.languageCode, 'pt')` | 合并。固定 17 个已发布基础语言，逐一解析并核对 Locale，错误指明语言。 · [#1104](#case-1104) Arabic locale |
| <a id='case-1100'></a>1100 · L32 | UserStorage locale resolution keeps supported French locale | [user_storage][m209] | `expect(locale.languageCode, 'fr')` | 合并。固定 17 个已发布基础语言，逐一解析并核对 Locale，错误指明语言。 · [#1104](#case-1104) Arabic locale |
| <a id='case-1101'></a>1101 · L38 | UserStorage locale resolution keeps supported Korean locale | [user_storage][m209] | `expect(locale.languageCode, 'ko')` | 合并。固定 17 个已发布基础语言，逐一解析并核对 Locale，错误指明语言。 · [#1104](#case-1104) Arabic locale |
| <a id='case-1102'></a>1102 · L44 | UserStorage locale resolution keeps supported Hindi locale | [user_storage][m209] | `expect(locale.languageCode, 'hi')` | 合并。固定 17 个已发布基础语言，逐一解析并核对 Locale，错误指明语言。 · [#1104](#case-1104) Arabic locale |
| <a id='case-1103'></a>1103 · L50 | UserStorage locale resolution keeps supported Indonesian locale | [user_storage][m209] | `expect(locale.languageCode, 'id')` | 合并。固定 17 个已发布基础语言，逐一解析并核对 Locale，错误指明语言。 · [#1104](#case-1104) Arabic locale |
| <a id='case-1104'></a>1104 · L56 | UserStorage locale resolution keeps supported Arabic locale | [user_storage][m209] | `expect(locale.languageCode, 'ar')` | 合并。固定 17 个已发布基础语言，逐一解析并核对 Locale，错误指明语言。 · [#1106](#case-1106) Italian locale |
| <a id='case-1105'></a>1105 · L62 | UserStorage locale resolution keeps supported Russian locale | [user_storage][m209] | `expect(locale.languageCode, 'ru')` | 合并。固定 17 个已发布基础语言，逐一解析并核对 Locale，错误指明语言。 · [#1104](#case-1104) Arabic locale |
| <a id='case-1106'></a>1106 · L68 | UserStorage locale resolution keeps supported Italian locale | [user_storage][m209] | `expect(locale.languageCode, 'it')` | 合并。固定 17 个已发布基础语言，逐一解析并核对 Locale，错误指明语言。 · [#1104](#case-1104) Arabic locale |
| <a id='case-1107'></a>1107 · L74 | UserStorage locale resolution keeps supported Traditional Chinese locale | [user_storage][m209] | `expect(UserStorage.localeTag(locale), 'zh_Hant')` | 保留 · [#1108](#case-1108) resolves Traditional Chinese regions to zh_Hant |
| <a id='case-1108'></a>1108 · L82 | UserStorage locale resolution resolves Traditional Chinese regions to zh_Hant | [user_storage][m209] | `expect(UserStorage.localeTag(locale), 'zh_Hant')` | 保留 · [#1107](#case-1107) keeps supported Traditional Chinese locale |
| <a id='case-1109'></a>1109 · L90 | UserStorage locale resolution parses locale tags with script codes | [user_storage][m209] | `expect(locale.scriptCode, 'Hant')`；`expect(UserStorage.localeTag(locale), 'zh_Hant')` | 保留 · [#1107](#case-1107) keeps supported Traditional Chinese locale |
| <a id='case-1110'></a>1110 · L98 | UserStorage locale resolution falls back unsupported locales to English | [user_storage][m209] | `expect(locale.languageCode, 'en')` | 保留 · [#1104](#case-1104) keeps supported Arabic locale |
| <a id='case-1111'></a>1111 · L110 | UserStorage Memex Agent notification permission marker is scoped to the active user | [user_storage][m209] | `expect(await UserStorage.hasPromptedMemexAgentNotificationPermission(), isFalse)`；`expect(await UserStorage.hasPromptedMemexAgentNotificationPermission(), isTrue)` | 保留 · [#1112](#case-1112) does not set a marker without a user |
| <a id='case-1112'></a>1112 · L137 | UserStorage Memex Agent notification permission marker does not set a marker without a user | [user_storage][m209] | `expect(await UserStorage.hasPromptedMemexAgentNotificationPermission(), isFalse)` | 保留 · [#1111](#case-1111) is scoped to the active user |
| <a id='case-1113'></a>1113 · L146 | UserStorage Memex Agent notification permission marker classifies the permission prompt marker as device-local | [user_storage][m209] | `expect(UserStorage.isDeviceLocalPreferenceKey('memex_agent_notification_permission_prompted_user-a'), isTrue)` | 保留 · [#1112](#case-1112) does not set a marker without a user |

</details>

<details>
<summary>test/utils/user_storage_prefs_cache_test.dart · 3 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1114'></a>1114 · L15 | getUserId rereads the mock store through sharedPrefs | [user_storage][m209] | `expect(await UserStorage.getUserId(), 'next-user')` | 保留 · [#1116](#case-1116) sharedPrefs retries after a failed cached initialization |
| <a id='case-1115'></a>1115 · L24 | getUserId treats blank values as logged out | [user_storage][m209] | `expect(await UserStorage.getUserId(), isNull)` | 保留 · [#1114](#case-1114) rereads the mock store through sharedPrefs |
| <a id='case-1116'></a>1116 · L29 | sharedPrefs retries after a failed cached initialization | [user_storage][m209] | `expectLater(UserStorage.sharedPrefs(), throwsStateError)`；`expect(await UserStorage.getUserId(), 'cached-user')` | 保留 · [#1114](#case-1114) getUserId rereads the mock store through sharedPrefs |

</details>

<details>
<summary>tests/tools/test_compare_flutter_analyze.py · 5 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1117'></a>1117 · L16 | test_parse_report_extracts_analyzer_issues | [compare_flutter_analyze][m210] | `self.assertEqual(len(issues), 2)`；`self.assertEqual(issues[1].code, 'unused_import')` | 保留 · [#1120](#case-1120) test_parses_flutter_write_format_and_normalizes_paths |
| <a id='case-1118'></a>1118 · L27 | test_moved_existing_issue_is_not_new | [compare_flutter_analyze][m210] | `self.assertEqual(new_issues, [])` | 保留。前者对移行诊断返回空差集；后者同时含真实新增错误与不同工作区路径。 · [#1119](#case-1119) test_additional_copy_of_existing_issue_is_new |
| <a id='case-1119'></a>1119 · L40 | test_additional_copy_of_existing_issue_is_new | [compare_flutter_analyze][m210] | `self.assertEqual(new_issues[0].line, 20)` | 保留 · [#1118](#case-1118) test_moved_existing_issue_is_not_new |
| <a id='case-1120'></a>1120 · L54 | test_parses_flutter_write_format_and_normalizes_paths | [compare_flutter_analyze][m210] | `self.assertEqual(len(issues), 2)`；`self.assertEqual(issues[1].path, 'test/foo_test.dart')` | 保留 · [#1117](#case-1117) test_parse_report_extracts_analyzer_issues |
| <a id='case-1121'></a>1121 · L67 | test_baseline_comparison_ignores_line_drift | [compare_flutter_analyze][m210] | `self.assertEqual(len(new_issues), 1)`；`self.assertEqual(new_issues[0].path, 'lib/data/new.dart')` | 保留。前者对移行诊断返回空差集；后者同时含真实新增错误与不同工作区路径。 · [#1119](#case-1119) test_additional_copy_of_existing_issue_is_new |

</details>

<details>
<summary>tests/tools/test_compare_flutter_test_failures.py · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1122'></a>1122 · L18 | test_parse_failures_extracts_failed_test_label | [compare_flutter_test_failures][m211] | `self.assertEqual(failures[0].normalized_label, 'test/live_agent_eval_test.dart: …comment agent live run with env config')` | 保留 · 未找到同一行为的替代项 |
| <a id='case-1123'></a>1123 · L27 | test_same_failure_under_different_workspace_path_is_not_new | [compare_flutter_test_failures][m211] | `self.assertEqual(new_failures, [])` | 保留 · [#1124](#case-1124) test_additional_failure_is_new |
| <a id='case-1124'></a>1124 · L37 | test_additional_failure_is_new | [compare_flutter_test_failures][m211] | `self.assertEqual(new_failures[0].normalized_label, 'test/new_test.dart: new failing test')` | 保留 · [#1123](#case-1123) test_same_failure_under_different_workspace_path_is_not_new |
| <a id='case-1125'></a>1125 · L70 | test_structured_terminal_and_exit_agree | [compare_flutter_test_failures][m211] | `self.assertEqual(machine_failures(self.stream('success', True), 0), [])`；`self.assertRaises(ValueError)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>tests/tools/test_local_pr_review.py · 7 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1126'></a>1126 · L12 | test_only_completed_required_workflows_are_ready | [local_pr_review][m212] | `self.assertEqual(review.preflight(checks), 'ready')`；`self.assertEqual(review.preflight(checks), 'preflight-failed')` | 保留 · 未找到同一行为的替代项 |
| <a id='case-1127'></a>1127 · L21 | test_same_head_separate_pr_or_base_needs_fresh_verdict | [local_pr_review][m212] | `self.assertNotEqual(review.review_context(pr), review.review_context(dict(pr, base={'sha': 'bbb'})))` | 保留 · [#1132](#case-1132) test_independent_approval_needs_current_head_and_role |
| <a id='case-1128'></a>1128 · L28 | test_record_withholds_status_when_concurrent_push_lands | [local_pr_review][m212] | `self.assertEqual(api.call_count, 2)`；`self.assertRaisesRegex(ValueError, 'withheld')` | 保留 · 未找到同一行为的替代项 |
| <a id='case-1129'></a>1129 · L45 | test_routing_covers_multiple_scenarios | [local_pr_review][m212] | `self.assertCountEqual(select(['ios/Runner/AppDelegate.swift', 'lib/data/services…service.dart']), ['restore', 'startup'])`；`self.assertEqual(select(['README.md']), [])` | 保留 · 未找到同一行为的替代项 |
| <a id='case-1130'></a>1130 · L58 | test_intent_edits_invalidate_status_context | [local_pr_review][m212] | `self.assertNotEqual(review.review_context(pr), review.review_context(dict(pr, body='uploads recordings')))` | 保留 · 未找到同一行为的替代项 |
| <a id='case-1131'></a>1131 · L63 | test_artifact_version_and_policy_are_authoritative | [local_pr_review][m212] | `self.assertEqual(classify('old', 'low_risk'), 'waiting-preflight')`；`self.assertEqual(classify('base', 'high_risk'), 'ready-owner')` | 保留 · 未找到同一行为的替代项 |
| <a id='case-1132'></a>1132 · L85 | test_independent_approval_needs_current_head_and_role | [local_pr_review][m212] | `self.assertTrue(review.independent_approval('repo', pr, [approval]))`；`self.assertFalse(review.independent_approval('repo', pr, [approval, dict(approval, state='DISMISSED')]))` | 保留 · [#1127](#case-1127) test_same_head_separate_pr_or_base_needs_fresh_verdict |

</details>

<details>
<summary>tests/tools/test_pr_policy_check.py · 13 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1133'></a>1133 · L29 | test_default_diff_budget_is_near_one_megabyte | [pr_policy_check][m213] | `self.assertEqual(args.max_diff_bytes, 1000000)` | 保留通过正式命令行解析器读取的默认 PR 差异大小预算。超限时的判定另见 [#1139](#case-1139)。 · 未找到同一行为的替代项 |
| <a id='case-1134'></a>1134 · L34 | test_secret_file_rejects | [pr_policy_check][m213] | `self.assertEqual(result.decision, DECISION_REJECT)`；`self.assertTrue(result.findings[0].message_zh)` | 保留 · [#1135](#case-1135) test_generated_file_without_source_rejects |
| <a id='case-1135'></a>1135 · L41 | test_generated_file_without_source_rejects | [pr_policy_check][m213] | `self.assertEqual(result.decision, DECISION_REJECT)` | 保留 · [#1140](#case-1140) test_unsafe_workflow_pattern_rejects |
| <a id='case-1136'></a>1136 · L46 | test_generated_file_with_source_is_low_risk | [pr_policy_check][m213] | `self.assertEqual(result.decision, DECISION_LOW_RISK)`；`self.assertEqual(result.findings, [])` | 保留 · [#1137](#case-1137) test_docs_only_is_low_risk |
| <a id='case-1137'></a>1137 · L58 | test_docs_only_is_low_risk | [pr_policy_check][m213] | `self.assertEqual(result.decision, DECISION_LOW_RISK)` | 保留 · [#1136](#case-1136) test_generated_file_with_source_is_low_risk |
| <a id='case-1138'></a>1138 · L63 | test_workflow_change_is_high_risk | [pr_policy_check][m213] | `self.assertEqual(result.decision, DECISION_HIGH_RISK)` | 保留 · [#1139](#case-1139) test_diff_truncation_remains_high_risk |
| <a id='case-1139'></a>1139 · L68 | test_diff_truncation_remains_high_risk | [pr_policy_check][m213] | `self.assertEqual(result.decision, DECISION_HIGH_RISK)` | 保留 · [#1138](#case-1138) test_workflow_change_is_high_risk |
| <a id='case-1140'></a>1140 · L83 | test_unsafe_workflow_pattern_rejects | [pr_policy_check][m213] | `self.assertEqual(result.decision, DECISION_REJECT)` | 保留 · [#1135](#case-1135) test_generated_file_without_source_rejects |
| <a id='case-1141'></a>1141 · L94 | test_single_l10n_file_is_left_to_ai_review | [pr_policy_check][m213] | `self.assertEqual(result.findings, [])` | 保留 · [#1144](#case-1144) test_sensitive_keyword_is_left_to_ai_review |
| <a id='case-1142'></a>1142 · L100 | test_app_code_path_is_not_high_risk_by_directory | [pr_policy_check][m213] | `self.assertEqual(result.decision, DECISION_LOW_RISK)` | 保留 · [#1136](#case-1136) test_generated_file_with_source_is_low_risk |
| <a id='case-1143'></a>1143 · L106 | test_production_change_without_test_signal_is_left_to_ai_review | [pr_policy_check][m213] | `self.assertEqual(result.findings, [])` | 保留 · [#1141](#case-1141) test_single_l10n_file_is_left_to_ai_review |
| <a id='case-1144'></a>1144 · L112 | test_sensitive_keyword_is_left_to_ai_review | [pr_policy_check][m213] | `self.assertEqual(result.findings, [])` | 保留 · [#1141](#case-1141) test_single_l10n_file_is_left_to_ai_review |
| <a id='case-1145'></a>1145 · L123 | test_outputs_include_bilingual_labels | [pr_policy_check][m213] | `self.assertEqual(data['decision_zh'], '高风险')`；`self.assertNotIn('风险分', markdown)` | 保留 · 未找到同一行为的替代项 |

</details>

<details>
<summary>tests/tools/test_pr_preflight_summary_comment.py · 4 项</summary>

| 编号 · 原行 | 场景 | main 对应实现 | 原观测点（节选） | 相关项及处理 |
|---|---|---|---|---|
| <a id='case-1146'></a>1146 · L17 | test_request_json_preserves_github_error_body | [pr_preflight_summary_comment][m214] | `self.assertEqual(context.exception.status, 403)`；`self.assertRaises(GitHubApiError)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-1147'></a>1147 · L36 | test_build_comment_includes_one_sentence_details | [pr_preflight_summary_comment][m214] | `self.assertIn('Policy preflight：′未命中治理规则′。未命中打回或高风险规则。', comment)`；`self.assertIn('Flutter quality: ′PASS′. Analyzer and test baselines found no newly introduced issue.', comment)` | 保留 · 未找到同一行为的替代项 |
| <a id='case-1148'></a>1148 · L80 | test_trigger_context_skips_transient_artifact_download_error | [pr_preflight_summary_comment][m214] | `self.assertIsNone(context)` | 保留 · [#1149](#case-1149) test_trigger_context_continues_after_one_artifact_download_error |
| <a id='case-1149'></a>1149 · L96 | test_trigger_context_continues_after_one_artifact_download_error | [pr_preflight_summary_comment][m214] | `self.assertEqual(context['head_sha'], 'abc123')` | 保留 · [#1148](#case-1148) test_trigger_context_skips_transient_artifact_download_error |

</details>

[m1]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/.github/scripts/generate_star_history.py
[m2]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/ios/Runner/PhotoPickerChannelHandler.swift
[m3]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/agent_system_prompt_helper.dart
[m4]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/skills/manage_timeline_card/timeline_card_skill.dart
[m5]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/skills/comment_agent/tools/comment_tools.dart
[m6]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/skills/comment_agent/tools/memory_tools.dart
[m7]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/built_in_tools/search_event_logs_tool.dart
[m8]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/character_agent/character_agent.dart
[m9]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/character_agent/character_conversation_skill.dart
[m10]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/character_agent/character_history_acquaintance_skill.dart
[m11]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/character_agent/character_initiative_skill.dart
[m12]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/character_agent/character_perception_skill.dart
[m13]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/skills/comment_agent/comment_agent_skill.dart
[m14]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/utils/token_usage_utils.dart
[m15]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/comment_agent/comment_agent.dart
[m16]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/super_agent/pending_tool_image_buffer.dart
[m17]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/security/file_permission_manager.dart
[m18]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/built_in_tools/file_tools.dart
[m19]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/prompts.dart
[m20]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/skills/knowledge_insight/knowledge_insight_skill.dart
[m21]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/memory/super_agent_context_compressor.dart
[m22]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/common_tools.dart
[m23]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/pubspec.lock
[m24]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/run_mode/agent_action_approval_service.dart
[m25]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/skills/dynamic_timeline_ui/dynamic_timeline_ui_skill.dart
[m26]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/skills/manage_system_action/system_action_skill.dart
[m27]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/system_action_service.dart
[m28]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/skills/timeline_diagnostics/timeline_diagnostics_skill.dart
[m29]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/state_util.dart
[m30]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/super_agent/subagent/super_agent_child.dart
[m31]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/super_agent/super_agent_harness.dart
[m32]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/super_agent/super_agent_loop_detector.dart
[m33]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/super_agent/super_agent.dart
[m34]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/memory/character_memory_service.dart
[m35]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/memory/character_context_compressor.dart
[m36]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/context/character_context_assembler.dart
[m37]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/agent/context/user_knowledge_context_service.dart
[m38]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/tavern_character_import_service.dart
[m39]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/app_startup.dart
[m40]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/config/app_config.dart
[m41]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/model/chat_artifact.dart
[m42]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/repositories/card.dart
[m43]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/domain/models/card_detail_model.dart
[m44]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/repositories/chat.dart
[m45]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/chat_session_storage.dart
[m46]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/file_system_service.dart
[m47]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/repositories/get_aggregated_timeline.dart
[m48]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/repositories/get_calendar_data.dart
[m49]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/hydrated_card_cache.dart
[m50]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/repositories/memex_router.dart
[m51]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/repositories/migrate_cards_fact_assets.dart
[m52]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/repositories/post_comment.dart
[m53]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/search_service.dart
[m54]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/repositories/get_timeline_cards.dart
[m55]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/repositories/update_card_ui_config.dart
[m56]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/agent_background_coordinator.dart
[m57]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/agent_background_platform.dart
[m58]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/agent_background_status.dart
[m59]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/agent_foreground_task_tracker.dart
[m60]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/agent_queue_background_worker.dart
[m61]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/app_action_link_service.dart
[m62]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/app_action_service.dart
[m63]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/app_update_service.dart
[m64]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/asset_reference_service.dart
[m65]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/asset_safety_service.dart
[m66]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/avatar_media_service.dart
[m67]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/backup_service.dart
[m68]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/card_attachment_service.dart
[m69]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/card_detail_notifier.dart
[m70]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/card_renderer.dart
[m71]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/task_handlers/character_conversation_handler.dart
[m72]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/character_conversation_service.dart
[m73]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/character_execution_coordinator.dart
[m74]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/task_handlers/character_history_acquaintance_handler.dart
[m75]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/character_history_acquaintance_service.dart
[m76]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/task_handlers/character_initiative_handler.dart
[m77]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/character_initiative_service.dart
[m78]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/task_handlers/character_perception_handler.dart
[m79]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/character_service.dart
[m80]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/character_workspace_service.dart
[m81]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/chat_service.dart
[m82]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/chat_run_registry.dart
[m83]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/clipboard_preview_service.dart
[m84]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/document_text_extraction_service.dart
[m85]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/event_log_service.dart
[m86]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/file_import_service.dart
[m87]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/file_operation_service.dart
[m88]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/geocoding_service.dart
[m89]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/global_event_bus.dart
[m90]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/health_service.dart
[m91]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/image_preview_cache_service.dart
[m92]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/llm_image_codec.dart
[m93]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/settings/widgets/settings_page.dart
[m94]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/local_asset_server.dart
[m95]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/local_task_executor.dart
[m96]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/memex_cloud_service.dart
[m97]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/migration_state_service.dart
[m98]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/model_role_config_service.dart
[m99]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/native_action_service.dart
[m100]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/native_photo_picker_service.dart
[m101]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/user_notification_service.dart
[m102]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/local_server_service.dart
[m103]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/utils/network_reachability.dart
[m104]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/persona_chat_conversation_storage.dart
[m105]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/persona_chat_service.dart
[m106]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/photo_attachment_service.dart
[m107]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/photo_suggestion_service.dart
[m108]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/photo_thumbnail_service.dart
[m109]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/pkm_recent_listing.dart
[m110]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/sandbox_user_clone_service.dart
[m111]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/sqlite_busy_retry.dart
[m112]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/task_handlers/comment_agent_handler.dart
[m113]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/timeline_card_event_publisher.dart
[m114]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/user_stats_service.dart
[m115]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/db/app_database.dart
[m116]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/domain/models/character_editor.dart
[m117]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/domain/models/character_message.dart
[m118]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/domain/models/character_workspace.dart
[m119]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/domain/models/event_bus_message.dart
[m120]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/domain/models/llm_config.dart
[m121]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/domain/models/location_context_config.dart
[m122]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/domain/models/timeline_card_visibility.dart
[m123]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/domain/models/user_stats_model.dart
[m124]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/domain/models/vocal_tone.dart
[m125]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/timeline/widgets/timeline_card_detail_screen.dart
[m126]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/knowledge/widgets/knowledge_base_screen.dart
[m127]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/chat/widgets/agent_chat_dialog.dart
[m128]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/timeline/view_models/timeline_viewmodel.dart
[m129]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/l10n/app_en.arb
[m130]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/l10n/app_localizations.dart
[m131]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/l10n/app_localizations_ext.dart
[m132]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/l10n/supported_languages.dart
[m133]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/agent_activity/widgets/agent_activity_widget.dart
[m134]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/data/services/agent_activity_service.dart
[m135]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/main.dart
[m136]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/app_lock/app_lock_session.dart
[m137]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/card_attachments/widgets/system_action_card.dart
[m138]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/character/view_models/character_edit_viewmodel.dart
[m139]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/character/view_models/character_viewmodel.dart
[m140]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/character/view_models/persona_avatar_viewmodel.dart
[m141]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/character/view_models/persona_chat_viewmodel.dart
[m142]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/character/widgets/character_config_screen.dart
[m143]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/character/widgets/persona_avatar_button.dart
[m144]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/character/widgets/persona_chat_screen.dart
[m145]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/chat/chat_event_batcher.dart
[m146]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/chat/chat_submission_coordinator.dart
[m147]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/chat/view_models/chat_turn_viewmodel.dart
[m148]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/chat/view_models/photo_attachments_viewmodel.dart
[m149]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/chat/widgets/chat_history_screen.dart
[m150]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/chat/widgets/open_super_agent_dialog.dart
[m151]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/chat/widgets/reference_asset_formatter.dart
[m152]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/core/cards/templates/classic_card.dart
[m153]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/core/cards/templates/visual/gallery_card.dart
[m154]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/core/cards/templates/textual/conversation_card.dart
[m155]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/core/cards/templates/visual/canvas_card.dart
[m156]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/l10n/gallery/template_gallery_models.dart
[m157]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/core/cards/templates/temporal/task_card.dart
[m158]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/core/themes/bundled_google_fonts.dart
[m159]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/core/widgets/character_avatar.dart
[m160]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/core/widgets/dicebear_avatar.dart
[m161]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/core/widgets/demo_overlay.dart
[m162]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/core/widgets/language_picker.dart
[m163]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/core/widgets/local_image.dart
[m164]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/core/widgets/memex_brand_title.dart
[m165]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/core/widgets/phone_width_frame.dart
[m166]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/core/widgets/reliable_asset_picker.dart
[m167]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/core/widgets/searchable_dropdown.dart
[m168]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/core/widgets/viewport_gated.dart
[m169]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/insight/widgets/insight_detail_page.dart
[m170]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/insight/view_models/insight_viewmodel.dart
[m171]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/insight/widgets/insight_screen.dart
[m172]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/insight/widgets/insight_template_gallery_page.dart
[m173]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/knowledge/widgets/knowledge_directory_page.dart
[m174]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/knowledge/view_models/knowledge_base_viewmodel.dart
[m175]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/main_screen/quick_recording_transcript.dart
[m176]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/main_screen/widgets/clipboard_preview_card.dart
[m177]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/main_screen/widgets/main_bottom_bar.dart
[m178]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/main_screen/widgets/share_intent_handler.dart
[m179]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/memory/widgets/memory_screen.dart
[m180]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/timeline/widgets/timeline_screen.dart
[m181]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/insight/widgets/insight_cards/summary_card.dart
[m182]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/settings/widgets/location_context_settings_page.dart
[m183]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/settings/widgets/model_config_list_page.dart
[m184]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/settings/widgets/agent_config_list_page.dart
[m185]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/domain/models/agent_definitions.dart
[m186]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/settings/view_models/ai_service_setup_viewmodel.dart
[m187]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/settings/view_models/debug_settings_viewmodel.dart
[m188]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/settings/widgets/agent_state_viewer_page.dart
[m189]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/settings/widgets/ai_service_setup_page.dart
[m190]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/settings/widgets/async_task_list_page.dart
[m191]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/settings/widgets/backup_restore_confirm_dialog.dart
[m192]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/settings/widgets/backup_restore_page.dart
[m193]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/settings/widgets/data_import_page.dart
[m194]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/settings/widgets/debug_settings_page.dart
[m195]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/settings/widgets/early_update_settings_card.dart
[m196]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/settings/widgets/experimental_lab_page.dart
[m197]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/settings/widgets/invalid_model_config_dialog.dart
[m198]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/settings/widgets/model_config_edit_page.dart
[m199]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/settings/widgets/vocal_tone_settings_card.dart
[m200]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/domain/models/timeline_card_model.dart
[m201]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/ui/timeline/widgets/timeline_model_config_banner.dart
[m202]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/utils/async_pool.dart
[m203]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/utils/async_work_queue.dart
[m204]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/utils/date_util.dart
[m205]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/utils/mention_parser.dart
[m206]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/utils/tavern_macro.dart
[m207]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/utils/time_context.dart
[m208]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/utils/toast_helper.dart
[m209]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/lib/utils/user_storage.dart
[m210]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/scripts/compare_flutter_analyze.py
[m211]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/scripts/compare_flutter_test_failures.py
[m212]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/scripts/local_pr_review.py
[m213]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/scripts/pr_policy_check.py
[m214]: https://github.com/memex-lab/memex/blob/6953a8a83222e6e52401dc93838a69bb37596ee7/scripts/pr_preflight_summary_comment.py
