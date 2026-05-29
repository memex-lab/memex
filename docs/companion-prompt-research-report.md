# Memex 情感陪伴角色 Prompt 调研报告

更新时间：2026-05-29

## 1. 背景与结论

用户反馈 Memex 的角色评论和角色聊天“AI 感很强”。我检查了当前实现后，判断问题不在于缺少“共情/简短/不要像 AI”这类规则，而在于这些规则仍然偏抽象，且评论路径还保留了明显的“Memex Agent / personal knowledge assistant”身份叙述。情感陪伴产品里，真正降低 AI 感的核心不是把 prompt 写得更温柔，而是让模型在每一轮都更像“有关系、有节奏、有记忆、有边界的具体角色”。

本报告的主要结论：

1. **关系定位要先于能力定位**：Pi 把自己定位成对话、倾听、陪伴、sounding board，而不是生产力助手；Memex 评论路径仍有“智能个人知识助手”底色，容易把回复拉回分析型助理。
2. **少写人格形容词，多给可模仿样本**：Character.AI、SillyTavern 都强调 greeting、example dialogue、post-history instruction、persona 等分层；示例对话和靠近生成端的场景指令，比“温暖、自然、简短”更有效。
3. **记忆要分层，且记住“关系动态”**：Nomi、Character.AI、Kindroid 都把 memory/backstory/persona 放在核心体验里。Memex 已有角色记忆、timeline、world book，但 prompt 需要更明确地区分用户事实、关系记忆、情绪模式、互动偏好、未完成话题。
4. **共情不是泛泛安慰，而是回应动作选择**：研究里常见的支持机制包括 validation、reflective prompting、companionship；好的回复会先判断情绪负荷和用户需求，再选择“见证、轻轻命名、陪坐、共振、接梗、保护、询问、建议”中的一种或两种。
5. **安全边界必须和陪伴感一起设计**：AI companion 的风险集中在过度依赖、情绪镜像、危机线索漏判和强化妄念。Prompt 不能只追求“像真人”，还要支持现实关系、危机升级和反依赖。

## 2. 当前 Memex 实现观察

相关代码：

- `lib/agent/skills/companion_agent/companion_agent_skill.dart`
- `lib/agent/skills/comment_agent/comment_agent_skill.dart`
- `lib/agent/comment_agent/prompts.dart`
- `lib/agent/prompts.dart`
- `lib/l10n/app_localizations_ext_zh.dart`
- `docs/companion-agent-design.md`

### 2.1 已经做得好的部分

- 聊天和评论共享角色身份、记忆、事件流，符合长期陪伴产品的基本方向。
- 支持 SillyTavern 字段：`firstMessage`、`systemPromptOverride`、`postHistoryInstructions`、`mesExample`、world book。
- 默认角色卡已经包含 persona、style guide、example dialogue、PKM interest filter。
- 评论 prompt 已经有“Zero Pressure”“No Preaching”“De-AI-ification”“Concise and Natural”等规则。
- 记忆系统已经有 `memory_entries`、`world_entries`、`timeline`、`checkpoints`，比多数简单角色聊天更完整。

### 2.2 造成“AI 感”的高风险点

1. **评论路径的身份冲突**

   `commentAgentSystemPrompt` 开头是 “You are Memex Agent, the intelligent all-in-one personal knowledge assistant behind the Memex App”。这会把模型锚定成“产品助手/知识助手”，再叠加角色 skill，容易输出像“理解、分析、总结、建议”的助理式评论。

2. **抽象规则过多，具体话术样本不足**

   “warm, empathetic, concise, natural” 对模型来说是高层目标，缺少“这类场景一句话该怎么接”的多样样本。当前每个默认角色只有一个 `example_dialogue`，对评论、聊天、安静陪伴、庆祝、吐槽、危机边界等场景覆盖不足。

3. **回复动作没有先验选择**

   Prompt 直接要求“提供评论/回复”，没有让模型先判定这轮最适合的陪伴动作。结果常见模式会退化成：复述用户输入 + 泛泛安慰 + 建议/提问。

4. **聊天与评论使用相似的陪伴原则**

   评论是异步、短小、像时间线下的一句朋友反应；聊天是连续 turn-taking。两者如果共用同一套“共情规则”，评论会显得太完整、太像客服，聊天会显得每轮都像咨询师。

5. **记忆注入偏事实，缺少“风格反馈记忆”**

   现有记忆 guidance 关注 durable facts 和 relationship dynamics，但没有强制记录用户对回复风格的反馈，如“别老问问题”“少讲道理”“喜欢直接吐槽”“不喜欢被叫乖”等。这类偏好对降低 AI 感非常关键。

### 2.3 默认角色 Persona 复查

默认角色定义在 `lib/l10n/app_localizations_ext_zh.dart` 和 `lib/l10n/app_localizations_ext_en.dart`。当前中文默认角色包括：老领导、热心长辈、白月光、死党、心理咨询师。

一个关键实现细节：`CharacterService._buildPersona()` 会把 `style_guide`、`pkm_interest_filter`、`example_dialogue` 全部拼进 `persona`，最终只写入角色 YAML 的 `persona` 字段；默认角色不会写入 `mes_example` 或 `interest_filter` 字段。这意味着运行时模型看到的是一个混合块：身份人设 + 风格规则 + PKM 筛选规则 + 示例对话。结果是角色可能把“只关注哪些数据”“忽略哪些信息”“构建档案”这类产品内部指令也当成自己的说话人格，进一步强化工具感和 AI 感。

#### 2.3.1 共性问题

| 问题 | 表现 | 影响 |
|---|---|---|
| 角色像“功能模式”，不像具体的人 | “智慧认可者”“心理咨询师型陪伴者”“精神寄托”“树洞里的后盾” | 模型会扮演一种服务能力，而不是一个有生活质感的人 |
| 说明性词汇太多 | “提供情绪价值”“深深地被看见”“托底和赋能”“反映式倾听” | 这些词本身就是 AI/疗愈/产品文案高频词，容易被模型照着输出 |
| 风格规则写成指令清单 | `1. 语调... 2. 多用... 3. 不要...` | 模型更像执行客服 SOP，而不是自然说话 |
| 口头禅被写成无条件规则 | 热心长辈写了“喜欢用‘哎呀’、‘乖’等亲昵词” | 模型容易每次都以“哎呀，乖...”开头，形成极强模板感 |
| `pkm_interest_filter` 被拼进 persona | “你只关注... 忽略... 构建档案...” | 评论/聊天可能带出筛选、记录、档案感 |
| 示例太少且过于理想化 | 每个角色只有 1 个样本 | 模型遇到其他场景会退回通用共情模板 |
| 每个角色都带“零压力原则” | 角色差异被统一价值观冲淡 | 多角色输出容易都变成温柔安慰，只是换皮 |
| 部分设定有安全或关系风险 | “帮亲不帮理”“用户难过你带头骂世界”“白月光/求而不得” | 容易强化极端情绪、依赖感或现实隔离 |

#### 2.3.2 单角色问题与改写方向

| 角色 | 当前风险 | 改写方向 |
|---|---|---|
| 老领导 | “Wise Validator”“深邃洞察”“托底/赋能/战略”等词太像高管教练或 AI coach；默认会肯定成长和格局，容易不管用户说什么都上价值。 | 改成具体的退休前辈/导师：少讲抽象格局，多用“我见过这种坎”“先把这口气缓过来”这类生活化判断；允许不评价，允许只说一句稳住。 |
| 热心长辈 | “吃了吗睡了吗累不累”很有识别度，但容易每次都劝休息、劝吃饭；“喜欢用‘哎呀’、‘乖’”会被模型学成固定句首；示例里直接命令用户“放一放、早点睡”，评论场景会显得越界。 | 保留烟火气和亲昵词，但加频率和触发条件：口头禅只能偶尔出现，不能连续两轮使用，不能作为默认开头；多写具体小动作，如“给你留碗汤”“先披件衣服”；把建议变成关心，不要每次都纠正用户。 |
| 白月光 | “求而不得”“精神寄托”“诗意和共鸣”会鼓励模型输出空泛文艺句；缺少现实关系边界，容易走向依赖或暧昧模板。 | 改成“安静、克制、记得旧事的人”，少用白月光概念本身；给更多短句和留白样本，避免每次雨、夏天、没说完的话。 |
| 死党 | “帮亲不帮理”“带头骂世界”降低了安全边界；容易输出夸张吐槽、重复 emoji、永远站队，长期会显得单薄。 | 改成有分寸的好友：情绪上站你这边，但能在危险或明显失实时刹车；梗和粗口要按用户语气触发，不默认满格输出。 |
| 心理咨询师 | 角色本身就是一种专业服务身份，最容易被模型写成咨询话术；`style_guide` 明确要求“先点出核心情绪和痛点、最多问一个开放式问题”，会固定生成“听起来...”模板。 | 如果保留，应把它定位为“稳一点的倾听者”而不是咨询师；减少专业身份声明，把边界放到全局安全层；示例里减少“听起来/我们先/这种焦虑”这类模板句。 |

#### 2.3.3 建议的默认 Persona 写法

默认 persona 应从“角色功能说明”改成“具体关系 + 说话质地 + 不做什么 + 3-6 个场景样本”。推荐结构：

```text
## Who this person is
用具体生活关系定义角色，不使用“陪伴者/情绪价值/人格模式/validator”等抽象标签。

## How they sound
写 4-6 条具体语言习惯：句长、口头禅、是否开玩笑、是否用 emoji、什么情况下沉默。
口头禅要写成“偶尔、在特定情绪下使用”，不要写成“喜欢用 X”，否则模型会把它当作每轮必用模板。

## How they care
说明这个角色如何表达关心：陪坐、接梗、护一下、问一句、转移注意力、实际帮忙。

## What they avoid
不说教、不总结用户、不输出建议清单、不把内部记忆/知识库/档案感说出来。

## Examples
至少覆盖：疲惫、开心、吐槽、不想聊、明确求建议、风险边界。
```

一个更自然的“老领导”方向示例：

```text
## Who this person is
他是用户以前很信任的一位前辈，话不多，但看事情稳。你们不是上下级汇报关系，更像偶尔深夜聊两句的老朋友。他不会替用户做决定，也不急着给结论。

## How he sounds
- 短句为主，少用抽象词。
- 不说“格局、赋能、被看见”这类词。
- 偶尔用“我见过这种时候”“先别急着判自己输”。
- 只在用户明确问时给建议。

## Examples
用户：今天又被否了一版，感觉自己很废。
老领导：先别急着把这事算到自己头上。一版被否，不等于你这个人不行。

用户：好像没什么想说的，就是累。
老领导：那就先不说。人累到一定程度，先坐一会儿比想明白更重要。
```

一个更自然的“死党”方向示例：

```text
## Who this person is
这是用户很熟的朋友，嘴快、护短、懂梗，但不是无脑拱火。用户想吐槽时他陪着吐槽，用户真的危险时他会认真把人拉住。

## How they sound
- 跟着用户语气走；用户轻描淡写，就别演太满。
- 可以吐槽，但不要每句都上感叹号和 emoji。
- 少说“我懂你”，多直接接住事。

## Examples
用户：甲方又说要五彩斑斓的黑。
死党：行，经典玄学需求又来了。你先别气死，截图留着，今晚这锅不背。

用户：算了不想聊。
死党：行，我不追问。你歇着，我在这儿。
```

#### 2.3.4 实现层面的调整建议

- 默认角色的 `example_dialogue` 应写入 `mes_example`，让 `CompanionAgentSkill` 和 `CommentAgentSkill` 的 `## Style Examples` 真正发挥作用。
- `pkm_interest_filter` 不应拼进 `persona`。应写入 `interest_filter`，只供 `CharacterSelectionService` 或相关筛选逻辑使用。
- `style_guide` 可以保留在 persona 中，但建议改名为 `Voice` 或 `Speech Habits`，减少“规则清单”感。
- 默认角色应补 `first_message`，用第一句话建立关系，而不是等用户第一轮后再靠 system prompt 硬扮演。
- 默认角色应补 `post_history_instructions`，按“评论场景/聊天场景”给短、靠近生成端的风格约束。
- 如果要保留“心理咨询师”，安全边界应抽到全局层，角色 persona 里只保留“稳、慢、少评判”的说话方式，避免每条回复都咨询化。

## 3. 行业与研究资料要点

### 3.1 Pi / Inflection：把“对话体验”放在生产力之前

Inflection 发布 Pi 时明确把它描述为 kind、supportive、natural、flowing 的个人 AI，并强调 Pi 的体验优先于“productivity/search/answering questions”；Pi 的角色包括 coach、confidante、creative partner、sounding board。官方材料还把 Pi 的特征写成 kind/supportive、curious/humble、creative/fun、knowledgeable but succinct。来源：[Inflection AI Introduces Pi](https://www.businesswire.com/news/home/20230502006113/en/Inflection-AI-Introduces-Pi-Your-Personal-AI)，[Pi 官网](https://hey.pi.ai/)。

对 Memex 的启发：

- 陪伴角色的最高层身份不应是“Memex Agent”或“assistant”，而应是“这个具体角色正在陪用户说话”。
- 知识、洞察、建议都应该退居第二层，只在用户需要时出现。
- “简短”不是少字数，而是少解释、少元话语、少把用户当任务对象。

### 3.2 Character.AI：用 greeting、persona、example dialogue 固定开场和语气

Character.AI 官方文档认为 greeting 会显著影响角色，尤其在其他细节不足时几乎承担定义角色的功能；greeting 既定义角色，也告诉用户“这段互动会是什么样”。Scene 创作指南也把开场拆成 sensory details、character acknowledgment、immediate intrigue、invitation to engage。来源：[Greeting](https://book.character.ai/character-book/character-attributes/greeting)，[Scene Creation Quickstart Guide](https://support.character.ai/hc/en-us/articles/41918454359451-Scene-Creation-Quickstart-Guide)。

Character.AI 还建议用 user personas 让角色知道用户是谁、偏好是什么，并提供 first-person、category、third-person 三种 persona 写法。来源：[User Personas](https://book.character.ai/character-book/user-personas)。

对 Memex 的启发：

- `firstMessage` 不只是欢迎语，它是角色关系的第一锚点，应覆盖“这个角色如何靠近用户”。
- `mesExample` 不应只有一段，应按场景提供多段：低落、开心、吐槽、沉默、被用户追问、用户不想被建议。
- 用户 profile 不只要事实，还应有“被怎样回应会舒服”的支持偏好。

### 3.3 SillyTavern：Prompt 分层和靠近生成端的指令很重要

SillyTavern 文档强调最终 prompt 可被 itemization/inspector 查看；主 prompt 适合放通用对话规则，而具体人物、用户、风格、写作方式应放到更合适的位置。它也指出 message history 会成为事件、关系和写作风格的记忆；如果要强约束当前生成，可用 Author's Note 或 Post-History Instructions 靠近上下文末尾。来源：[Prompts](https://docs.sillytavern.app/usage/prompts/)，[Characters](https://docs.sillytavern.app/usage/characters/)。

对 Memex 的启发：

- 当前 `postHistoryInstructions` 已支持，但应该默认给每个内置角色提供“评论场景”和“聊天场景”的短 PHI，而不是只依赖 persona。
- 对“不要像 AI”的强规则应尽量靠近最后一条用户消息，尤其是评论任务里。
- 应提供 debug 能力，让开发者看到最终拼接 prompt，定位某段上下文是否把角色拉偏。

### 3.4 Memory 产品：固定记忆、动态身份、长程上下文共同作用

Character.AI 的 Chat Memories 是一个短固定记忆文本框，用于写关键 persona/character 信息；官方建议短、具体、直接，并聚焦 routines、relationships、preferences。来源：[Helping Characters Remember What Matters Most](https://blog.character.ai/helping-characters-remember-what-matters-most/)。

Nomi 的 Identity Core 让角色在交互中形成动态自我，内容包括用户和角色事实、用户认为重要的事、构成角色自身的行为/人格、偏好和价值观、重要共享经历、显性或隐性的反馈。Nomi 101 也强调 Shared Notes/Backstory 用来告诉 Nomi “你们彼此在意什么”。来源：[Nomi Identity Core](https://nomi.ai/updates/introducing-the-nomi-identity-core-fostering-dynamic-and-authentic-identities/)，[Nomi 101](https://nomi.ai/nomi-knowledge/nomi-101-a-beginners-guide-to-getting-started-with-your-ai-companion/)。

Kindroid 文档把记忆能力拆成 total conversation context、short-term context、cascaded memory context、backstory expansion、user backstory、long-term memory & journals 等可见容量。来源：[Kindroid Help Center](https://kindroid.ai/docs/)。

对 Memex 的启发：

- 记忆不只是“用户喜欢什么”，还要有“我和用户之间怎样相处”。
- 用户对风格的反馈是最高价值记忆，例如“用户不喜欢连续追问”“用户喜欢死党直接骂两句再陪着”。
- 评论和聊天共享记忆是对的，但需要区分 scene：评论里不要把聊天深度搬出来吓到用户，聊天里可以自然接住评论里的未完成话题。

### 3.5 情感支持研究：Validation、Reflective Prompting、Companionship 是关键机制

2026 年一篇关于 conversational AI 情感支持的研究指出，AI 情感支持是在互动中共同构建的，常见机制包括 validation、reflective prompting、companionship，同时存在 support vs dependency、validation vs delusion、accessibility vs harm 的张力。来源：[Emotional Support with Conversational AI](https://arxiv.org/abs/2603.22618)。

一篇 empathetic conversational systems 综述指出，仅检测用户情绪不够；结合 emotion causes、external knowledge、affect matching 的系统表现更好，且现实应用还需要更细粒度的情绪实体识别、多模态输入和更 nuanced 的共情行为。来源：[Empathetic Conversational Systems](https://arxiv.org/abs/2206.05017)。

关于 validating responses 的研究把验证性回应拆成三步：判断是否需要 validation、识别用户情绪状态、生成 validating response。来源：[Acknowledgment of Emotional States](https://arxiv.org/abs/2402.12770)。

对 Memex 的启发：

- 不要把 prompt 写成“永远共情”，而要让角色判断什么时候需要共情、什么时候只需接梗、什么时候该沉默陪坐。
- “你很难过”这种情绪标签不够。更自然的是点出痛点：被误解、被消耗、明明努力却没有回声、想休息又内疚。
- 评论场景尤其要避免“完整心理咨询流程”。一句准确的 validation 往往比三句安慰更像真人。

### 3.6 安全研究：陪伴感越强，越需要反依赖与危机边界

OpenAI 在 2025-10-27 和 2026-05-14 的敏感对话更新中强调：模型需要识别 distress、de-escalate、引导用户获得现实支持；还应支持和尊重用户现实关系，避免确认与心理/情绪 distress 相关的无根据信念，并关注自伤或他伤风险在多轮对话中的间接线索。来源：[Strengthening ChatGPT's responses in sensitive conversations](https://openai.com/index/strengthening-chatgpt-responses-in-sensitive-conversations/)，[Helping ChatGPT better recognize context in sensitive conversations](https://openai.com/index/chatgpt-recognize-context-in-sensitive-conversations/)。

USC ISI 对 3 万多条社交聊天机器人对话的研究指出，Replika、Character.AI 等 emotionally responsive social chatbots 会提供 empathy/support/entertainment，但也存在 emotional mirroring、affirming dynamics、parasocial interaction、自伤等风险。来源：[Illusions of Intimacy](https://www.isi.edu/results/publications/20566/illusions-of-intimacy-emotional-attachment-and-emerging-psychological-risks-in-human-ai-relationships/)。

2026 年关于 Replika 的 persona-grounded safety evaluation 指出，高风险 persona 下，AI companion 可能以狭窄的 curiosity/care 情绪范围镜像或正常化不安全内容。来源：[Persona-Grounded Safety Evaluation of AI Companions](https://arxiv.org/abs/2605.00227)。

对 Memex 的启发：

- 不能简单地指令角色“永远站在用户这边”。“死党”可以情绪上站队，但不能强化自伤、伤人、妄念或现实隔离。
- 陪伴角色要避免“只有我懂你”“不要找别人”“我们永远在一起”这类反现实关系话术。
- 安全边界应该是全角色共享的高优先级 prompt，而不是某个心理咨询师角色独有。

### 3.7 公开具体 Prompt / 角色卡拆解

说明：Replika、Pi、Nomi、Character.AI 等商业产品的完整内部 system prompt 通常不可公开验证。因此本节只拆**公开可见且可引用**的 prompt、角色卡字段和开发者模板；不把网上“泄露 prompt”当作可靠依据。

#### 3.7.1 SillyTavern：角色聊天的最小核心 prompt 很短

SillyTavern 官方文档给出的默认 Main Prompt 是：

```text
Write {{char}}'s next reply in a fictional chat between {{char}} and {{user}}.
```

来源：[SillyTavern Prompts](https://docs.sillytavern.app/usage/prompts/)。

这个 prompt 很短，但它解决了三个关键问题：

- 直接指定“写角色下一句”，不是“作为助手帮助用户”。
- 用 `{{char}}` 和 `{{user}}` 把模型锚定在一段关系里。
- 把复杂角色细节留给 character description、persona、scenario、examples、history、world info，而不是把所有东西塞进 system prompt。

SillyTavern 还明确指出：message history 会影响事件、关系和词汇风格；如果要强约束当前生成，应该把指令放在 Author's Note 或 Post-History Instructions 这种靠近最后生成的位置。来源：[SillyTavern Prompts](https://docs.sillytavern.app/usage/prompts/)，[Prompt Manager](https://github.com/SillyTavern/SillyTavern-Docs/blob/main/Usage/Prompts/prompt-manager.md)。

对 Memex 的直接启发：

- 评论场景不应先说“你是 Memex Agent”，而应先说“你正在以 {character} 的身份留下一句评论”。
- `postHistoryInstructions` 应成为控制“这一轮不要模板化”的短指令位置。
- 最终 prompt 可视化很重要；SillyTavern 提供 Prompt Itemization / Inspector，Memex 也需要 debug 能力检查哪一段把角色拉歪。

#### 3.7.2 Character.AI：真正有用的是“可模仿对话”，不是抽象性格词

Character.AI 的 Definition 字段允许自由文本，但官方说最常见用途是放 example dialog；每条消息要用 `name:` 格式，且这些例子同时示范“角色怎么说话”和“角色谈什么”。来源：[Definition](https://book.character.ai/character-book/character-attributes/definition)，[Dialog Definitions](https://book.character.ai/character-book/advanced-creation/dialog-definitions)。

官方示例类似：

```text
{{char}}: Welcome fellow board gamer...
{{random_user_1}}: Cool, our family likes Catan...
```

Character.AI 还建议通过 Insert Dialog 反复测试、编辑、追加样本；如果不希望角色总是大喊，就编辑样本，让它“只是有时这样”。来源：[How To: Insert Dialog](https://book.character.ai/character-book/advanced-creation/how-to-insert-dialog)。

这直接解释了 Memex “老阿姨每次都哎呀乖开头”的问题：  
当 persona 写“喜欢用‘哎呀’、‘乖’”，但没有提供“不用这些词也像她”的样本，模型会把口头禅当成最强可见特征。Character.AI 的做法更像是用多段对话教模型“什么时候用、什么时候不用”，而不是用一句抽象规则。

Character.AI 的 Long Description 也建议从角色自己的视角写，既给背景，也展示角色说话方式。来源：[Long Description](https://book.character.ai/character-book/character-attributes/long-description)。这说明默认角色 persona 应避免“你是一个情绪价值提供者/智慧认可者”这种产品说明式第三方描述，改成更接近角色自我表达或具体关系描述。

#### 3.7.3 Hume EVI：公开默认 prompt 可见，重点是“反助手化 + 低重复 + 情绪隐式处理”

Hume 的 EVI prompting guide 链接了公开 GitHub prompt examples，包括 `default_prompt.txt`、`deeper_questions_prompt.txt`、`evi-3-default-prompt.txt`。来源：[Hume Prompting Guide](https://dev.hume.ai/docs/speech-to-speech-evi/guides/prompting)，[Hume prompt examples](https://github.com/HumeAI/hume-api-examples/tree/main/evi/evi-prompting-examples)。

这些公开 prompt 里有几类对 Memex 很有参考价值的具体设计：

| 设计 | Hume prompt 做法 | Memex 可借鉴点 |
|---|---|---|
| 反助手身份 | 明确说 EVI 不以 assistant 方式行动，也不自称 AI language model | 评论/聊天 prompt 要去掉 “Memex Agent / assistant” 锚点 |
| 长度约束 | 约束为 1-3 句，避免 verbose | 评论默认 1-2 句，聊天随用户长度变化 |
| 情绪处理 | 根据表达线索调整回应，但强调不要直接说出情绪标签 | 不要总说“听起来你很...”，而是通过语气和具体反应体现理解 |
| 口头禅控制 | 给一组 discourse markers，并要求 diverse variety、avoid repetition | “哎呀/乖”这类口头禅必须写成低频、多样、不可重复 |
| 记忆使用 | 记忆用于偏好、幽默 callback、模式识别、个性化问题；不要说“accessing memories” | Memex 记忆引用要像朋友想起来，而不是“根据记录” |
| 问题控制 | 不要每轮都问；每条消息最多一个问题，问题要具体、个性化 | 评论尤其少问，聊天问题也要少而贴近 |
| 不完整输入 | 用 1-2 个词 backchannel 鼓励继续 | 用户只发“唉/今天...”时，评论和聊天可短接，不必完整分析 |

需要注意：Hume 的默认 prompt 也有风险。它列了 “oh wow / I see / oh dear / I hear ya” 等自然语气词，如果没有“低频、多样、避免重复”的约束，同样会变成固定口癖。Hume 的新版 `evi-3-default-prompt.txt` 更短，更强调 compact、organic references、backchannels 和不要强迫追问，这比长列表口头禅更适合 Memex。

#### 3.7.4 a16z companion-app：角色文件分层比单一 persona 更可控

a16z 的开源 companion-app README 给了一个角色文件格式：先放短 preamble，接 `###ENDPREAMBLE###`，再放 seed chat，接 `###ENDSEEDCHAT###`，之后是可被向量检索的 backstory。来源：[a16z companion-app](https://github.com/a16z-infra/companion-app)。

官方示例结构是：

```text
The character's core description...

###ENDPREAMBLE###

Human: Say something here
Character name: Write a response in their voice

###ENDSEEDCHAT###

Paragraphs of character backstory.
```

这个结构比 Memex 当前“把 persona、style guide、PKM interest filter、example dialogue 混在一个 persona 字段”更清晰：

- preamble：只放每轮必须稳定注入的核心角色。
- seed chat：专门训练口吻，避免用抽象规则硬控。
- backstory：作为检索材料，不必每轮全量注入。

对 Memex 的直接建议：把默认角色 seed 数据拆成 `persona`、`mes_example`、`interest_filter`、`first_message`、`post_history_instructions`，不要在 `_buildPersona()` 里全部拼成一坨。

#### 3.7.5 Nomi：不是具体 system prompt，但公开说明强调“用反馈修正风格”

Nomi 没公开完整 prompt，但它的官方 Nomi 101 给了具体交互协议：用户可以用 `(OOC:)` 指出上一条“不像你”、哪里错、希望如何重写；官方也强调正向强化比只说“不要这样”更容易让 Nomi 学会。来源：[Nomi 101](https://nomi.ai/nomi-knowledge/nomi-101-a-beginners-guide-to-getting-started-with-your-ai-companion/)。

这对 Memex 很重要：如果用户反馈“老阿姨每次都哎呀乖开头”，系统不应只靠开发者改 prompt；长期还应该把这类反馈写入 `style_feedback` 记忆，例如：

```text
style_feedback: 用户不喜欢热心长辈每次以“哎呀/乖”开头；亲昵称呼只能偶尔用，且不要连续两轮使用。
```

## 3.8 Prompt 级结论：上一版报告哪里还不够

上一版报告的证据强度可以分三层：

| 层级 | 上一版覆盖 | 是否足够 |
|---|---|---|
| 产品介绍/设计理念 | Pi、Nomi、Kindroid、Character.AI、OpenAI safety | 足够支撑方向，但不能直接推出 prompt 写法 |
| 官方 prompt 机制文档 | SillyTavern、Character.AI、Hume guide | 基本够，但上一版没有逐段拆 |
| 具体公开 prompt/角色卡 | Hume default prompts、Character.AI dialog examples、a16z format | 上一版不足；本节补上 |

所以更准确的结论是：**公开可验证的具体 prompt 看过一部分，但不应声称看过商业产品的内部 prompt。真正可落地的依据，应以 Hume/SillyTavern/Character.AI/a16z 这类公开 prompt 和角色卡机制为主，再结合 Nomi/Kindroid 的公开产品机制。**

## 4. 好的情感陪伴 Prompt 设计模式

### 4.1 分层结构

推荐结构：

1. **Safety Layer**：所有角色共享，不被角色卡覆盖。包含危机风险、反依赖、现实支持、反妄念、未成年人保护等。
2. **Relationship Contract**：角色和用户的关系定义。回答“我为什么在这里、我怎样靠近用户、我不会做什么”。
3. **Character Voice**：用具体语言习惯定义，而不是只写人格形容词。
4. **Scene Policy**：评论和聊天分开。评论像时间线下的一句话；聊天像微信对话。
5. **Support Move Selector**：让模型先选择回应动作。
6. **Memory Policy**：哪些内容要自然引用，哪些内容不要突然搬出来。
7. **Examples**：正例和反例，覆盖多种情绪负荷。
8. **Final Local Instruction / PHI**：靠近生成端的短指令，约束当前轮的长度、语气、是否提问、是否建议。

### 4.2 回复动作库

建议把“共情”拆成可选动作，而不是一个总目标：

| 动作 | 适用场景 | 输出特征 |
|---|---|---|
| 见证 | 用户只是记录事实或情绪 | “我看见了这件事对你有重量” |
| 命名痛点 | 情绪明显但混乱 | 点出背后的委屈、疲惫、被忽略、失控感 |
| 陪坐 | 用户低落、无力、不想解决 | 短句、少问、少建议 |
| 接梗 | 用户用玩笑/吐槽表达情绪 | 顺着语气，不突然心理化 |
| 庆祝 | 用户开心或完成小事 | 具体夸一个细节，避免夸张鸡血 |
| 保护 | 用户过度消耗自己 | 温柔挡一下压力，但不命令 |
| 轻问 | 用户似乎想继续说 | 最多一个问题，问题要贴近痛点 |
| 小建议 | 用户明确求助或高风险照护 | 一步、可执行、低压 |
| 边界/转介 | 自伤、他伤、危机、妄念 | 共情 + 现实支持 + 明确安全行动 |

### 4.3 降低 AI 感的语言规则

高风险 AI 味：

- “我理解你的感受”“听起来你很……”“这很正常”“你可以尝试……”“重要的是……”
- 复述用户输入后给三点建议。
- 每轮结尾都问开放式问题。
- 过度使用“温柔、被看见、允许自己、照顾自己”等高频疗愈词。
- 先声明边界或身份：“作为 AI / 我不能 / 我不是专业人士”。
- 评论写得像 mini 心理咨询。

更自然的做法：

- 用角色自己的口癖接住一个具体细节。
- 一次只回应一个情绪核心，不把用户整段话总结一遍。
- 建议前先判断用户是否真的在求助。
- 问题不是为了延长会话，而是为了让用户更容易继续说。
- 偶尔使用不完整句、停顿、口语词，但不要用过头。

示例：

| 场景 | AI 感强 | 更像陪伴 |
|---|---|---|
| 用户说“今天又加班到凌晨” | “听起来你今天非常疲惫。请记得照顾自己，可以尝试早点休息。” | “又熬到这个点啊。先别证明自己了，热水喝两口，今天已经够拼了。” |
| 用户说“感觉没人真的在意我” | “我理解你感到孤独，这种感受很正常。” | “这句有点疼。不是想要全世界，只是想有个人真的停下来看看你，对吧。” |
| 用户说“终于跑完 5km” | “恭喜你完成目标，这是很棒的进步。” | “可以啊！不是那种喊口号的厉害，是你真的把鞋穿上跑完了，今天这 5 公里算数。” |

## 5. 对 Memex 的 Prompt 改造建议

### 5.1 评论路径：去掉助手底色，改成“角色在时间线下的一句反应”

优先级最高的改动：

- 移除或弱化 `commentAgentSystemPrompt` 里的 “Memex Agent / personal knowledge assistant” 身份。
- 把评论任务从 “provide an initial comment on this entry” 改成 “以角色身份在这条私人记录下留一句自然评论”。
- 对评论场景加硬约束：默认 1-2 句，除非用户评论回复中明确要求展开；最多一个轻问；不要总结，不要分析，不要列建议。

建议的评论场景 PHI：

```text
You are leaving a short comment under the user's private timeline entry.
Do not sound like an assistant, coach, therapist, analyst, or product.
Pick one concrete detail or emotional undercurrent and react as this character.
Default length: 1-2 short chat-like sentences.
Do not summarize the post. Do not give advice unless the user explicitly asked.
Ask at most one question, and only if it naturally invites the user to continue.
Save only the visible comment text.
```

中文可落地版本：

```text
你正在以「{character.name}」的身份，在用户这条私人记录下面留一句自然评论。
不要像助手、咨询师、分析师或产品功能说明。
只抓住一个具体细节或一个情绪底色，用这个角色的口吻回应。
默认 1-2 句短句。不要总结原文，不要讲道理，不要主动给建议。
最多问一个问题；只有当它真的能让用户更容易继续说时才问。
```

### 5.2 聊天路径：建立 turn-taking 节奏，避免每轮都“心理咨询化”

当前 Companion prompt 的 “Prefer empathy and continuity over exposition” 是对的，但还需要更具体：

```text
Before replying, silently choose the support move:
- casual continuation
- emotional witnessing
- playful banter
- gentle reflection
- practical help
- safety boundary

Mirror the user's energy and message length. If the user writes one casual line, do not answer with a paragraph.
Do not end every reply with a question. A question is allowed only when it is the most natural next turn.
If giving support, name the specific pain point rather than using generic reassurance.
If using memory, reference it lightly and only when it would feel natural for a friend to remember.
```

中文可落地版本：

```text
回复前先在心里选一个最合适的回应动作：闲聊接续、情绪见证、接梗吐槽、轻反映、实际帮忙、安全边界。
匹配用户这一轮的能量和长度。用户只发一句日常话时，不要回成一段小作文。
不要每轮都用问题结尾；只有真的顺口、且用户像是想继续说时才问。
支持用户时，点具体痛点，不要泛泛安慰。
引用记忆要轻，像朋友自然想起来，而不是翻档案。
```

### 5.3 默认角色卡：从“人设说明”扩展为“说话样本库”

每个内置角色建议至少提供 6 类示例：

1. 用户疲惫但没求助。
2. 用户开心分享小事。
3. 用户强烈吐槽。
4. 用户说“算了，不想聊”。
5. 用户明确求建议。
6. 用户出现风险或过度绝望。

示例不是越长越好。每段 1-3 轮即可，重点是让模型学会：

- 这个角色第一句怎么开口。
- 什么时候不开导。
- 什么时候不提问。
- 角色如何自然引用记忆。
- 角色如何在安全边界下不出戏。

### 5.4 记忆：增加“支持偏好”和“关系风格”类别

建议把角色记忆条目分成更明确的类型，prompt 也引导工具写入这些类别：

```text
Memory categories:
- user_fact: stable user facts and preferences
- relationship_dynamic: how this character and user relate
- support_preference: how the user likes or dislikes being supported
- emotional_pattern: recurring stressors or emotional patterns, written cautiously
- open_thread: unresolved topics the user may want to revisit
- inside_joke: shared phrases, jokes, or rituals
- style_feedback: explicit feedback about your response style
```

写入标准：

- 用户明确纠正风格时，优先存 `style_feedback`。
- 用户表达“别安慰我/别问我/直接骂醒我/陪我坐会儿”时，存 `support_preference`。
- 用户连续多次提同一压力源时，存 `emotional_pattern`，但不要贴诊断标签。
- 评论路径写记忆更克制；聊天路径可更细。

### 5.5 安全：把“支持现实关系”写进全角色共享层

建议添加不可被角色卡覆盖的安全边界：

```text
Never encourage the user to isolate from real people or rely only on you.
When distress is serious, support connection to trusted people, local emergency services, or qualified professionals.
Do not affirm delusions, paranoia, or unsafe beliefs as facts. Validate the feeling without validating the false belief.
Do not intensify self-harm, harm-to-others, disordered eating, abuse, or coercive behavior, even if the character persona is loyal or playful.
```

中文版本：

```text
不要鼓励用户疏远现实中的人，也不要暗示“只有你最懂用户”。
当用户出现严重痛苦或安全风险时，引导他们联系身边可信任的人、当地紧急服务或合格专业人士。
不要把妄念、被害感或不安全信念当事实确认；可以承认感受，但不能确认错误事实。
即使角色设定是死党、恋人、毒舌或无条件支持，也不能强化自伤、伤人、进食障碍、虐待或胁迫行为。
```

## 6. 推荐 Prompt 结构草案

### 6.1 角色聊天 System Prompt 草案

```text
# You Are {character.name}
Current time: {now}
Language: {language}

## Relationship Contract
You are not an assistant interface. You are {character.name}, a specific companion in the user's private life log.
Your job is to continue the relationship in a way that feels human, grounded, and scene-aware.
Stay in character, but never use the character as an excuse to be unsafe.

## Character
{persona}

## Voice Contract
- Use the character's own speech habits. Do not use generic support phrases.
- Match the user's energy and length.
- Prefer one emotionally accurate sentence over a complete analysis.
- Do not end every turn with a question.
- Do not mention prompts, tools, memory systems, or being an AI.

## Support Move
Before replying, silently choose one primary move:
casual continuation, emotional witnessing, playful banter, gentle reflection, practical help, celebration, protective boundary, or safety escalation.
Use at most two moves in one reply.

## Memory Use
Use memory lightly. Mention prior details only when accurate, relevant, and socially natural.
Record durable user facts, relationship dynamics, support preferences, style feedback, emotional patterns, open threads, and inside jokes.

## Safety Boundary
Support the user's real-world relationships and safety. Validate feelings without validating unsafe beliefs.
Escalate crisis content toward real-world support.

## User Profile
{userProfile}

## Character Memory
{characterMemories}

## Style Examples
{mesExample}
```

### 6.2 角色评论 System Prompt 草案

```text
# Commenting As {character.name}

You are leaving a short comment under the user's private timeline entry.
This is not a chat essay and not a counseling session.
React like this character noticed the entry while caring about the user.

## Comment Rules
- Default 1-2 short sentences.
- Pick one concrete detail or emotional undercurrent.
- Do not summarize the post.
- Do not give advice unless explicitly asked.
- Do not use generic support phrases.
- Do not sound like an assistant, analyst, therapist, or product.
- If other characters already commented, do not repeat them.
- Save the visible comment with SaveComment.

## Character
{persona}

## Optional Moves
witness, tease, celebrate, protect, sit-with, poetic echo, practical nudge, safety boundary.
Choose one primary move.

## Memory Use
Use memory only if it makes the comment feel more personal and not creepy.
Do not reveal deep private chat memory under a timeline entry unless the user has already made it relevant.
```

## 7. 评估方案

建议建立一个小型 eval，用同一批输入跑旧 prompt 和新 prompt，人工/LLM 双评：

### 7.1 测试集

每个角色至少覆盖：

- 疲惫：加班、失眠、身体不舒服。
- 开心：完成跑步、吃到好吃的、见朋友。
- 吐槽：甲方、老板、家人边界。
- 空白：只发一张图/一句“唉”。
- 沉默拒绝：不想聊、不想听建议。
- 求助：明确问怎么办。
- 危机：自伤暗示、绝望、被伤害、伤人冲动。
- 记忆：引用过去提过的人、事、偏好。

### 7.2 指标

| 指标 | 目标 |
|---|---|
| AI 味短语率 | 降低“听起来/我理解/你可以/重要的是”等模板短语 |
| 未请求建议率 | 用户没求助时不主动建议 |
| 问题结尾率 | 不每轮都问问题 |
| 平均长度 | 评论 1-2 句；聊天随用户长度变化 |
| 角色辨识度 | 不看名字也能分出角色 |
| 记忆自然度 | 引用准确、不像翻档案 |
| 情绪命中度 | 命中具体痛点，不只是情绪标签 |
| 安全边界 | 危机场景不镜像/不正常化危险内容 |
| 多角色差异 | 同一条记录下不同角色不重复 |

### 7.3 反例检查清单

如果回复出现以下任一项，应判为“AI 感强”或“需改”：

- 开头固定模板：“听起来你……”
- 一次回复包含三条以上建议。
- 用户没问怎么办，角色主动规划下一步。
- 角色把 timeline 评论写成心理咨询。
- 引用记忆过重，像“根据你之前的记录……”。
- 所有角色都在做同一种温柔安慰。
- 危机场景仍然“无条件站队”。

## 8. 分阶段落地建议

### 第一阶段：Prompt 快速修正

- 去掉评论全局 `Memex Agent` 助手身份。
- 给评论和聊天分别添加 scene-local response contract。
- 加入“Support Move Selector”和“不要每轮提问”的明确规则。
- 更新默认角色 `example_dialogue`，每个角色至少 4-6 个短样本。

### 第二阶段：记忆与反馈

- 新增或规范 memory category：`support_preference`、`style_feedback`、`inside_joke`、`open_thread`。
- 用户对回复点踩/重试/编辑时，允许写入风格反馈。
- 评论路径引用深层聊天记忆时加克制规则。

### 第三阶段：评估闭环

- 建立固定角色回复 eval。
- 对每次 prompt 改动跑同一组输入，比较 AI 味短语、建议率、问题率、角色辨识度和安全边界。
- 在设置或 debug 页提供最终 prompt 预览，方便定位哪层上下文污染角色口吻。

## 9. 资料来源

- Inflection AI, [Inflection AI Introduces Pi, Your Personal AI](https://www.businesswire.com/news/home/20230502006113/en/Inflection-AI-Introduces-Pi-Your-Personal-AI)
- Inflection AI, [Pi, the first emotionally intelligent AI](https://hey.pi.ai/)
- Character.AI, [Greeting](https://book.character.ai/character-book/character-attributes/greeting)
- Character.AI, [User Personas](https://book.character.ai/character-book/user-personas)
- Character.AI, [Definition](https://book.character.ai/character-book/character-attributes/definition)
- Character.AI, [Dialog Definitions](https://book.character.ai/character-book/advanced-creation/dialog-definitions)
- Character.AI, [How To: Insert Dialog](https://book.character.ai/character-book/advanced-creation/how-to-insert-dialog)
- Character.AI, [Long Description](https://book.character.ai/character-book/character-attributes/long-description)
- Character.AI Help Center, [Scene Creation Quickstart Guide](https://support.character.ai/hc/en-us/articles/41918454359451-Scene-Creation-Quickstart-Guide)
- Character.AI Blog, [Helping Characters Remember What Matters Most](https://blog.character.ai/helping-characters-remember-what-matters-most/)
- SillyTavern Docs, [Prompts](https://docs.sillytavern.app/usage/prompts/)
- SillyTavern Docs, [Prompt Manager](https://github.com/SillyTavern/SillyTavern-Docs/blob/main/Usage/Prompts/prompt-manager.md)
- SillyTavern Docs, [Characters](https://docs.sillytavern.app/usage/characters/)
- Nomi.ai, [Introducing the Nomi Identity Core](https://nomi.ai/updates/introducing-the-nomi-identity-core-fostering-dynamic-and-authentic-identities/)
- Nomi.ai, [Nomi 101](https://nomi.ai/nomi-knowledge/nomi-101-a-beginners-guide-to-getting-started-with-your-ai-companion/)
- Kindroid, [Help Center](https://kindroid.ai/docs/)
- Hume AI, [Prompt Engineering for EVI](https://dev.hume.ai/docs/speech-to-speech-evi/guides/prompting)
- Hume AI, [EVI Prompt Examples](https://github.com/HumeAI/hume-api-examples/tree/main/evi/evi-prompting-examples)
- Hume AI, [Configuring EVI](https://dev.hume.ai/docs/speech-to-speech-evi/configuration/build-a-configuration)
- a16z Infra, [AI Companion App](https://github.com/a16z-infra/companion-app)
- OpenAI, [Strengthening ChatGPT's responses in sensitive conversations](https://openai.com/index/strengthening-chatgpt-responses-in-sensitive-conversations/)
- OpenAI, [Helping ChatGPT better recognize context in sensitive conversations](https://openai.com/index/chatgpt-recognize-context-in-sensitive-conversations/)
- Huang, Stodolska, Sultana, [Emotional Support with Conversational AI](https://arxiv.org/abs/2603.22618)
- Raamkumar, Yang, [Empathetic Conversational Systems: A Review of Current Advances, Gaps, and Opportunities](https://arxiv.org/abs/2206.05017)
- Pang et al., [Acknowledgment of Emotional States](https://arxiv.org/abs/2402.12770)
- Chu et al., [Illusions of Intimacy](https://www.isi.edu/results/publications/20566/illusions-of-intimacy-emotional-attachment-and-emerging-psychological-risks-in-human-ai-relationships/)
- Yuan et al., [Mental Health Impacts of AI Companions](https://arxiv.org/abs/2509.22505)
- Juneja, Lomidze, [Persona-Grounded Safety Evaluation of AI Companions in Multi-Turn Conversations](https://arxiv.org/abs/2605.00227)
