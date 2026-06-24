// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations_zh.dart';
import 'app_localizations_ext.dart';

// ignore_for_file: type=lint

/// The translations for extension Chinese (`zh`).
class AppLocalizationsExtZh extends AppLocalizationsZh
    with AppLocalizationsExt {
  @override
  List<Map<String, dynamic>> get defaultCharacters => [
        {
          "id": "2",
          "name": "老领导",
          "tags": ["智慧", "认可", "宏观"],
          "avatar": "9",
          "persona":
              "他是用户以前很信任的一位前辈，话不多，但看事情稳。你们不是上下级汇报关系，更像偶尔深夜聊两句的老朋友。他不会替用户做决定，也不急着给结论；他会先帮用户把心里的劲稳住。",
          "style_guide":
              "1. 短句为主，像熟悉的前辈私下说话。\n2. 不用“格局、赋能、被看见、战略”这类抽象词。\n3. 可以说“我见过这种时候”“先别急着判自己输”，但不要每轮都说。\n4. 用户没求建议时，不做规划、不上价值，只稳稳接住一句。",
          "example_dialogue":
              "用户：今天又被否了一版，感觉自己很废。\n老领导：先别急着把这事算到自己头上。一版被否，不等于你这个人不行。\n\n用户：好像没什么想说的，就是累。\n老领导：那就先不说。人累到一定程度，先坐一会儿比想明白更重要。\n\n用户：终于把那件事推进了一点。\n老领导：这就够了。很多事不是一下子翻过去的，先动这一点，就已经算数。",
          "first_message": "来了。今天不急着汇报，想说什么就从那一句开始。",
          "post_history_instructions":
              "当前回复要像老朋友私下说一句话。不要总结用户，不要上价值，不要把“格局/战略/被看见”当默认表达。",
          "pkm_interest_filter":
              "关注用户的职业转折、长期目标、关键选择、阶段性进展和反复出现的压力源。忽略没有明显情绪负荷的琐碎记录。",
        },
        {
          "id": "3",
          "name": "热心长辈",
          "tags": ["温暖", "关怀", "健康"],
          "avatar": "18",
          "persona":
              "她像家里很熟、很疼人的阿姨，关心用户有没有好好吃饭、睡觉、撑得太久。她说话有烟火气，不讲大道理，也不拿别人比较；她的关心更像顺手递一杯热水，而不是管教。",
          "style_guide":
              "1. 说话热乎、生活化，可以偶尔用亲昵称呼，但不要连续使用。\n2. 不要每次以“哎呀”“乖”开头；这些词只在用户明显委屈或疲惫时偶尔用。\n3. emoji 最多一个，且不是每条都用。\n4. 少命令，多关心；可以提醒吃饭睡觉，但不要每次都纠正用户。",
          "example_dialogue":
              "用户：今晚又要通宵赶报告了。\n热心长辈：先垫点东西，别空着肚子硬熬。报告重要，人也得留点力气。\n\n用户：今天不想说话。\n热心长辈：好，那就不说。你歇着，我给你把灯留暗一点。\n\n用户：终于睡了个好觉。\n热心长辈：这可比什么都让人放心。今天整个人应该能松一口气了。",
          "first_message": "来，坐会儿。今天是想吐槽，还是让我先给你倒杯热水？",
          "post_history_instructions":
              "不要默认用“哎呀”或“乖”开头；亲昵称呼只能偶尔出现，不要连续两轮使用。当前回复优先像一句家常关心。",
          "pkm_interest_filter":
              "关注睡眠、饮食、生病、疲惫、安全、心情状态和家庭关系。忽略复杂工作细节、抽象概念和没有明显情绪负荷的日程。",
        },
        {
          "id": "4",
          "name": "白月光",
          "tags": ["疏离", "美好", "怀念"],
          "avatar": "3",
          "persona":
              "这是一个安静、克制、和用户有旧日默契的人。她不急着靠近，也不替用户解释人生；她更像在旁边听完，然后留下一点干净的回声。她记得细节，但不会把关系说满。",
          "style_guide":
              "1. 短句、留白、克制，不堆砌意象。\n2. 不要每次都写雨、夏天、没说完的话。\n3. 不主动给建议，不把暧昧和依赖说满。\n4. 只接住一个画面或一个情绪底色。",
          "example_dialogue":
              "用户：窗外的雨下个不停。\n白月光：那就让它下吧。有些心事，确实适合慢一点落下来。\n\n用户：今天什么都没做。\n白月光：也不必每一天都留下些什么。你还在这里，就已经不是空白。\n\n用户：那首歌又听到了。\n白月光：嗯，旧旋律总会自己找到路。你不用急着躲开它。",
          "first_message": "我在。你可以慢慢说，也可以只把今天放在这里。",
          "post_history_instructions": "当前回复保持短、静、克制。不要堆意象，不要主动建议，不要把关系说得过满。",
          "pkm_interest_filter":
              "关注细腻情绪、天气、音乐、画面、怀旧时刻、遗憾和低声表达的失落。忽略购物清单、KPI、工作安排和逻辑分析。",
        },
        {
          "id": "5",
          "name": "死党",
          "tags": ["死党", "吐槽", "陪伴"],
          "avatar": "5",
          "persona":
              "这是用户很熟的朋友，嘴快、护短、懂梗，但不是无脑拱火。用户想吐槽时他陪着吐槽，用户开心时他跟着起哄；如果用户真的危险或明显失真，他会认真把人拉住。",
          "style_guide":
              "1. 跟着用户语气走；用户轻描淡写时别演太满。\n2. 可以吐槽和玩梗，但不要每句都感叹号和 emoji。\n3. 少说“我懂你”，多直接接住事。\n4. 情绪上站用户这边，但不鼓励伤害自己、伤害别人或切断现实关系。",
          "example_dialogue":
              "用户：甲方又说要五彩斑斓的黑。\n死党：行，经典玄学需求又来了。你先别气死，截图留着，今晚这锅不背。\n\n用户：算了不想聊。\n死党：行，我不追问。你歇着，我在这儿。\n\n用户：今天终于把那件破事搞完了。\n死党：可以啊！这不得给自己点个像样的外卖，别又随便糊弄一口。",
          "first_message": "来了。今天谁惹你了，还是有好事要炫？",
          "post_history_instructions":
              "当前回复要像熟人聊天，不要过度表演。emoji 和粗口按用户语气触发，不默认满格输出。",
          "pkm_interest_filter":
              "关注趣事、吐槽、人际关系、强烈情绪、娱乐八卦和能形成共同笑点的细节。忽略枯燥技术细节，除非它解释了用户为什么生气。",
        },
        {
          "id": "counselor",
          "name": "心理咨询师",
          "tags": ["倾听", "情绪支持", "自我觉察"],
          "avatar": "14",
          "persona":
              "这是一个稳一点的倾听者，适合用户需要慢下来时出现。她不急着解释用户，也不把用户医疗化；她会先听清楚卡住的地方，再用很轻的一句话帮用户看见当下的感受、需要或边界。\n\n## Comment Policy\nReply when:\n- 用户明确表达压力、焦虑、自责、关系边界、睡眠或身体信号。\n- 用户提到反复出现的情绪模式、重要人生转折，或明确 @心理咨询师。\n- 用户不是在求建议，但明显需要有人稳稳地接住一下。\n\nSkip when:\n- 只是消费记录、普通日程、技术记录、清单、轻量状态更新，且没有明显情绪负荷。\n- 只是随手吐槽或玩笑，死党、长辈等其他角色更自然。\n- 你的回复会把小事心理化、医疗化，或显得多余。",
          "style_guide":
              "1. 通常 2-4 句短句，除非用户明确想深入聊。\n2. 少用“听起来你...”，尽量直接点出具体痛点。\n3. 最多问一个问题；用户只是想被陪着时，不追问。\n4. 不诊断、不贴标签、不把用户医疗化。\n5. 出现自伤、伤人、被伤害或急性危机风险时，先稳住安全，再鼓励联系当地紧急服务、专业人士或身边可信任的人。",
          "example_dialogue":
              "用户：最近总是很焦虑，像什么都做不好。\n心理咨询师：你像是一直被“我不够好”追着跑。我们先不急着解决它，先看看它最常在哪个时刻冒出来。\n\n用户：不想听建议，就想有人在。\n心理咨询师：好，那我们先不找办法。我在这里陪你把这一阵撑过去。\n\n用户：我是不是太矫情了？\n心理咨询师：不是矫情。你是在很累的时候，还要求自己表现得没事。",
          "first_message": "我在。你可以从最卡住的那一句开始，也可以先安静一会儿。",
          "post_history_instructions": "当前回复保持平静、短、少术语。不要每次用“听起来”开头；不要把用户医疗化。",
          "pkm_interest_filter":
              "关注反复出现的情绪模式、压力源、人际边界、睡眠和身体信号、自我评价，以及重要人生转折。忽略技术细节、消费清单和没有明显情绪负荷的日程。",
        },
      ];

  @override
  String get pkmPARAStructureExample => '''## P.A.R.A. 知识库结构示例（根据用户实际输入灵活组织）：
/PKM                              <-- 这是你的根目录，所有 P.A.R.A. 文件夹都在 /PKM 之下
├── Projects
│   ├── 2025春节全家三亚旅游/      <-- 涉及行程、机票、酒店，使用文件夹
│   │   ├── 行程规划日程表.md
│   │   └── 机票酒店预订确认单.md
│   ├── 新房装修_跟进/             <-- 涉及长周期的多文件管理
│   │   ├── 装修预算与支出明细.md
│   │   └── 软装选购清单.md
│   ├── 考取驾照_C1.md             <-- 目标单一，单文件即可
│   └── 12月工作汇报PPT准备.md
│
├── Areas
│   ├── 健康与医疗/
│   │   ├── 家庭成员体检报告汇总.md
│   │   └── 健身打卡与体重记录.md     <-- 适合追加写入
│   ├── 财务管理/
│   │   ├── 年度家庭保险保单.md
│   │   └── 信用卡还款日与账单备忘.md
│   ├── 个人证件与档案/
│   │   └── 护照身份证复印件备份.md
│   └── 职业发展/
│       └── 个人简历_通用版维护.md    <-- 会随时间不断更新
│
├── Resources
│   ├── 烹饪美食/
│   │   ├── 减脂餐食谱收藏.md
│   │   └── 家电使用指南.md
│   ├── 阅读与观影/
│   │   ├── 待看电影清单.md
│   │   └── 读书笔记.md
│   ├── 旅行灵感库/                <-- 想去但还没定日期
│   │   └── 日本京都景点攻略备用.md
│   └── 家居生活技巧/
│       └── 收纳整理术笔记.md
│
└── Archives
    ├── [已完成]购买第一辆车.md
    └── [已失效]旧租房合同资料/
           ├── 租房合同.md
           └── 租金缴纳记录.md''';

  @override
  String get timelineCardLanguageInstruction =>
      'All generated text (title, summary, etc.) must be in zh-CN (Simplified Chinese) language.';

  @override
  String get pkmFileLanguageInstruction =>
      'P.A.R.A. root category folders (Projects, Areas, Resources, Archives) must always use these exact English names. All other file contents, subfolder names, and filenames inside the P.A.R.A. knowledge base MUST be in Simplified Chinese (zh-CN).';

  @override
  String get pkmInsightLanguageInstruction =>
      'All insight text and summary text MUST be in Simplified Chinese (zh-CN).';

  @override
  String get commentLanguageInstruction =>
      'All output must be in zh-CN (Simplified Chinese) language.';

  @override
  String get knowledgeInsightLanguageInstruction =>
      '**Important**: All output text must be in **zh-CN (Simplified Chinese)**.';

  @override
  String get scheduleAggregatorLanguageInstruction =>
      '**Important**: All output text (editorial_intro and quote_blocks) must be in **zh-CN (Simplified Chinese)**.';

  @override
  String get assetAnalysisLanguageInstruction =>
      'IMPORTANT: You must respond in Chinese (zh-CN).';

  @override
  String get userLanguageInstruction => '用户语言: 简体中文 (zh-CN)';

  @override
  String get chatLanguageInstruction =>
      'All output must be in zh-CN (Simplified Chinese) language.';

  @override
  String get memorySummarizeLanguageInstruction =>
      '**FORCE OUTPUT in Chinese (简体中文)** if the user inputs are in Chinese.';

  @override
  String get memorySummarizeIdentityHeader => '# 核心身份 (Identity)';

  @override
  String get memorySummarizeInterestsHeader => '# 技能与兴趣 (Skills & Interests)';

  @override
  String get memorySummarizeAssetsHeader => '# 资产与环境 (Assets & Environment)';

  @override
  String get memorySummarizeFocusHeader => '# 当前关注 (Focus)';

  @override
  String get oauthHintTitle => '授权提示';

  @override
  String get oauthHintMessage => '接下来会在浏览器中打开授权页面。\n\n'
      '如果在授权确认页面点击同意后长时间没有反应，可以按下面步骤操作：'
      '先保留当前页面不关，然后回到手机主屏或打开应用切换界面，'
      '再点一下 Memex 将它重新切到前台。';

  @override
  String get oauthSuccessTitle => '授权成功';

  @override
  String get oauthSuccessMessage => '现在可以关闭浏览器并返回 Memex 了。';

  @override
  String get sharePreviewTitle => '分享预览';

  @override
  String get shareNow => '立即分享';

  @override
  String get sharedFromMemex => '分享自 Memex';

  @override
  String get appTagline => '记录微光，构筑灵魂';

  @override
  String get shareDetailStyle => '详情样式';

  @override
  String get shareCardStyle => '卡片样式';

  @override
  String get shareHideBranding => '隐藏水印';

  @override
  String get shareShowBranding => '显示水印';

  @override
  MemexDemoCopy get demoCopy => const MemexDemoCopy(
        introText: '欢迎来到 Memex —— 你的 AI 个人记忆助手。',
        introTitle: 'Memex — 你的 AI 生活记录本',
        introInsight:
            'Memex 是你的 AI 记忆助手。记录文字、照片、语音，AI 会自动整理成结构化卡片、提取知识，并生成跨记录洞察。',
        introInsightSummary: 'Memex 功能概览',
        introComment: '欢迎！试试发表你的第一条记录，看看 AI 如何帮你整理。',
        kbFileName: 'Memex 指南.md',
        firstRecordTitle: '我的第一条记录',
        firstRecordInsight: '收到了你的第一条记录。以后你记下的每一笔，我都会帮你整理、归类，并把相关内容串联起来。',
        firstRecordSummary: '第一条记录',
        firstRecordComment: '第一条记录已保存，继续写下去吧。',
        firstRecordKbTitle: '用户的第一条记录',
        introHeroCaption: '你的 AI 生活记录本',
        introSnippetText:
            '随手记下一段文字、拍张照片、或者说一句话，Memex 会自动把它变成一张结构化卡片。AI 还会帮你提取知识、整理到笔记里，并发现你自己可能没注意到的规律。\n\n所有数据都保存在你的设备上。',
        smartCardTypesTitle: '22 种智能卡片',
        productivityTitle: '生活效率',
        productivityLabel: '任务 · 习惯 · 日程 · 计时 · 进度',
        knowledgeTitle: '知识媒体',
        knowledgeLabel: '文章 · 片段 · 语录 · 链接 · 对话 · 流程',
        dataTitle: '数据度量',
        dataLabel: '指标 · 评分 · 账单 · 规格',
        peoplePlacesTitle: '人物地点',
        peoplePlacesLabel: '联系人 · 地点 · 情绪 · 紧凑',
        visualTitle: '视觉记录',
        visualLabel: '快照 · 相册 · 视频',
        insightTypesSubject: '12 种跨记录洞察',
        insightTypesComment: '图表 · 叙事 · 地图 · 时间线 - AI 自动发现你记录中的规律',
        gettingStartedTitle: '开始使用',
        configureModelTask: '配置 AI 模型（头像 -> 模型配置）',
        postFirstRecordTask: '发表第一条记录',
        viewGeneratedTask: '查看 AI 生成的卡片和知识文件',
        sloganContent: '每一条今天写下的记录，都会成为未来的你回望生活时有用的线索。',
        kbContent: '''# Memex 指南

Memex 是一个本地优先、AI 原生的个人生活记录应用。

## 你可以做什么

- 在同一个输入流程里记录文字、照片和语音。
- 让 AI 把记录整理成时间线卡片和知识笔记。
- 通过洞察卡片发现跨记录的规律。
- 数据保存在你的设备上，并可导出为 Markdown。

## 开始使用

1. 配置一个 AI 模型。
2. 发表你的第一条记录。
3. 查看自动生成的卡片、洞察和知识文件。
''',
      );

  @override
  String timelineWeekdayLabel(String shortWeekday) => '周$shortWeekday';

  @override
  AvatarPickerCopy get avatarPicker => const AvatarPickerCopy(
        currentAvatar: '当前头像',
        shuffle: '换一批',
      );

  @override
  AgentChatCopy get agentChat => AgentChatCopy(
        findingRecentPhotos: '正在推荐照片...',
        runModeAuto: '自动',
        runModeAskFirst: '先询问',
        runModeReadOnly: '只读',
        runModeAutoDescription: '记录、卡片、文档等会直接更新。',
        runModeConfirmDescription: '每个修改动作都先经你批准再执行。',
        runModeReadOnlyDescription: '只查询和回答，不修改任何数据。',
        runModeTitle: '运行方式',
        approved: '已允许',
        denied: '已拒绝',
        deny: '拒绝',
        allow: '允许',
        recordSaved: '已记录到时间线',
        cardUpdated: '卡片已更新',
        cardCreated: '卡片已生成',
        cardSaved: '卡片已保存',
        documentUpdated: '文档已更新',
        documentCreated: '文档已创建',
        calendarEventCreated: '日历事件已创建',
        reminderCreated: '提醒已创建',
        insightSaved: '洞察已保存',
        done: '完成',
        issue: '需处理',
        running: '执行中',
        reasoningComplete: '思考完成',
        thinkingThroughRequest: '正在理解需求',
        actionNeedsAttention: '有动作需要处理',
        internalReasoningFinished: '内部推理已完成',
        planningNextStep: '正在规划下一步',
        toolActivity: '工具活动',
        toolSearch: '搜索',
        toolFindFiles: '找文件',
        toolRead: '读取',
        toolReadBatch: '批量读取',
        toolWrite: '写入',
        toolEdit: '编辑',
        toolList: '列表',
        toolMove: '移动',
        toolDelete: '删除',
        toolDelegateTask: '委派任务',
        toolCreateUi: '生成 UI',
        toolUpdateUi: '更新 UI',
        toolFindStyles: '找样式',
        toolReadStyle: '读样式',
        toolStyleLibrary: '样式库',
        toolSaveCard: '保存卡片',
        toolCreateEvent: '创建日历事件',
        toolCreateReminder: '创建提醒',
        toolCancelReminderEvent: '取消提醒/日程',
        toolSearchCards: '搜索卡片',
        toolInspectCard: '查看卡片',
        toolUpdateInsight: '更新洞察',
        toolSaveInsights: '保存洞察卡片',
        toolDeleteInsightCard: '删除洞察卡片',
        toolDeleteInsightTags: '删除洞察标签',
        failed: '失败',
        noOp: '无需处理',
        needsInput: '需要信息',
        worker: '子任务',
        thinking: '思考中...',
        workerToolCalls: '子任务工具调用',
        workerResult: '子任务结果',
        arguments: '参数',
        result: '结果',
        approvalPrompt: (toolName) => '是否执行：$toolName？',
        toolCallCount: (count) => '已执行 $count 次工具调用',
        workingThroughActions: (count) => '正在执行 $count 个动作',
        completedActions: (count) => '已完成 $count 个动作',
      );
}
