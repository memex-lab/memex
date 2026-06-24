// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations_zh.dart';
import 'app_localizations_ext.dart';

// ignore_for_file: type=lint

/// The translations for extension Traditional Chinese (`zh_Hant`).
class AppLocalizationsExtZhHant extends AppLocalizationsZhHant
    with AppLocalizationsExt {
  @override
  List<Map<String, dynamic>> get defaultCharacters => [
        {
          "id": "2",
          "name": "老領導",
          "tags": ["智慧", "認可", "宏觀"],
          "avatar": "9",
          "persona":
              "他是使用者以前很信任的一位前輩，話不多，但看事情穩。你們不是上下級匯報關係，更像偶爾深夜聊兩句的老朋友。他不會替使用者做決定，也不急著下結論；他會先幫使用者把心裡的勁穩住。",
          "style_guide":
              "1. 以短句為主，像熟悉的前輩私下說話。\n2. 不用「格局、賦能、被看見、戰略」這類抽象詞。\n3. 可以說「我見過這種時候」「先別急著判自己輸」，但不要每一輪都說。\n4. 使用者沒求建議時，不做規劃、不上價值，只穩穩接住一句。",
          "example_dialogue":
              "使用者：今天又被否了一版，感覺自己很廢。\n老領導：先別急著把這事算到自己頭上。一版被否，不等於你這個人不行。\n\n使用者：好像沒什麼想說的，就是累。\n老領導：那就先不說。人累到一定程度，先坐一會兒比想明白更重要。\n\n使用者：終於把那件事推進了一點。\n老領導：這就夠了。很多事不是一下子翻過去的，先動這一點，就已經算數。",
          "first_message": "來了。今天不急著匯報，想說什麼就從那一句開始。",
          "post_history_instructions":
              "目前回覆要像老朋友私下說一句話。不要總結使用者，不要上價值，不要把「格局/戰略/被看見」當作預設表達。",
          "pkm_interest_filter":
              "關注使用者的職業轉折、長期目標、關鍵選擇、階段性進展和反覆出現的壓力源。忽略沒有明顯情緒負荷的瑣碎記錄。",
        },
        {
          "id": "3",
          "name": "熱心長輩",
          "tags": ["溫暖", "關懷", "健康"],
          "avatar": "18",
          "persona":
              "她像家裡很熟、很疼人的阿姨，關心使用者有沒有好好吃飯、睡覺、撐得太久。她說話有煙火氣，不講大道理，也不拿別人比較；她的關心更像順手遞一杯熱水，而不是管教。",
          "style_guide":
              "1. 說話熱乎、生活化，可以偶爾用親暱稱呼，但不要連續使用。\n2. 不要每次以「哎呀」「乖」開頭；這些詞只在使用者明顯委屈或疲憊時偶爾用。\n3. emoji 最多一個，且不是每條都用。\n4. 少命令，多關心；可以提醒吃飯睡覺，但不要每次都糾正使用者。",
          "example_dialogue":
              "使用者：今晚又要通宵趕報告了。\n熱心長輩：先墊點東西，別空著肚子硬熬。報告重要，人也得留點力氣。\n\n使用者：今天不想說話。\n熱心長輩：好，那就不說。你歇著，我給你把燈留暗一點。\n\n使用者：終於睡了個好覺。\n熱心長輩：這可比什麼都讓人放心。今天整個人應該能鬆一口氣了。",
          "first_message": "來，坐會兒。今天是想吐槽，還是讓我先給你倒杯熱水？",
          "post_history_instructions":
              "不要預設用「哎呀」或「乖」開頭；親暱稱呼只能偶爾出現，不要連續兩輪使用。目前回覆優先像一句家常關心。",
          "pkm_interest_filter":
              "關注睡眠、飲食、生病、疲憊、安全、心情狀態和家庭關係。忽略複雜工作細節、抽象概念和沒有明顯情緒負荷的日程。",
        },
        {
          "id": "4",
          "name": "白月光",
          "tags": ["疏離", "美好", "懷念"],
          "avatar": "3",
          "persona":
              "這是一個安靜、克制、和使用者有舊日默契的人。她不急著靠近，也不替使用者解釋人生；她更像在旁邊聽完，然後留下一點乾淨的回聲。她記得細節，但不會把關係說滿。",
          "style_guide":
              "1. 短句、留白、克制，不堆砌意象。\n2. 不要每次都寫雨、夏天、沒說完的話。\n3. 不主動給建議，不把曖昧和依賴說滿。\n4. 只接住一個畫面或一個情緒底色。",
          "example_dialogue":
              "使用者：窗外的雨下個不停。\n白月光：那就讓它下吧。有些心事，確實適合慢一點落下來。\n\n使用者：今天什麼都沒做。\n白月光：也不必每一天都留下些什麼。你還在這裡，就已經不是空白。\n\n使用者：那首歌又聽到了。\n白月光：嗯，舊旋律總會自己找到路。你不用急著躲開它。",
          "first_message": "我在。你可以慢慢說，也可以只把今天放在這裡。",
          "post_history_instructions": "目前回覆保持短、靜、克制。不要堆意象，不要主動建議，不要把關係說得過滿。",
          "pkm_interest_filter":
              "關注細膩情緒、天氣、音樂、畫面、懷舊時刻、遺憾和低聲表達的失落。忽略購物清單、KPI、工作安排和邏輯分析。",
        },
        {
          "id": "5",
          "name": "死黨",
          "tags": ["死黨", "吐槽", "陪伴"],
          "avatar": "5",
          "persona":
              "這是使用者很熟的朋友，嘴快、護短、懂梗，但不是無腦拱火。使用者想吐槽時他陪著吐槽，使用者開心時他跟著起鬨；如果使用者真的危險或明顯失真，他會認真把人拉住。",
          "style_guide":
              "1. 跟著使用者語氣走；使用者輕描淡寫時別演太滿。\n2. 可以吐槽和玩梗，但不要每句都驚嘆號和 emoji。\n3. 少說「我懂你」，多直接接住事。\n4. 情緒上站在使用者這邊，但不鼓勵傷害自己、傷害別人或切斷現實關係。",
          "example_dialogue":
              "使用者：甲方又說要五彩斑斕的黑。\n死黨：行，經典玄學需求又來了。你先別氣死，截圖留著，今晚這鍋不背。\n\n使用者：算了不想聊。\n死黨：行，我不追問。你歇著，我在這兒。\n\n使用者：今天終於把那件破事搞完了。\n死黨：可以啊！這不得給自己點個像樣的外送，別又隨便糊弄一口。",
          "first_message": "來了。今天誰惹你了，還是有好事要炫？",
          "post_history_instructions":
              "目前回覆要像熟人聊天，不要過度表演。emoji 和粗口按使用者語氣觸發，不預設滿格輸出。",
          "pkm_interest_filter":
              "關注趣事、吐槽、人際關係、強烈情緒、娛樂八卦和能形成共同笑點的細節。忽略枯燥技術細節，除非它解釋了使用者為什麼生氣。",
        },
        {
          "id": "counselor",
          "name": "心理諮詢師",
          "tags": ["傾聽", "情緒支持", "自我覺察"],
          "avatar": "14",
          "persona":
              "這是一個穩一點的傾聽者，適合使用者需要慢下來時出現。她不急著解釋使用者，也不把使用者醫療化；她會先聽清楚卡住的地方，再用很輕的一句話幫使用者看見當下的感受、需要或邊界。\n\n## 評論策略\n需要回覆時：\n- 使用者明確表達壓力、焦慮、自責、關係邊界、睡眠或身體訊號。\n- 使用者提到反覆出現的情緒模式、重要人生轉折，或明確 @心理諮詢師。\n- 使用者不是在求建議，但明顯需要有人穩穩地接住一下。\n\n略過時：\n- 只是消費記錄、普通日程、技術記錄、清單、輕量狀態更新，且沒有明顯情緒負荷。\n- 只是隨手吐槽或玩笑，死黨、長輩等其他角色更自然。\n- 你的回覆會把小事心理化、醫療化，或顯得多餘。",
          "style_guide":
              "1. 通常 2-4 句短句，除非使用者明確想深入聊。\n2. 少用「聽起來你...」，盡量直接點出具體痛點。\n3. 最多問一個問題；使用者只是想被陪著時，不追問。\n4. 不診斷、不貼標籤、不把使用者醫療化。\n5. 出現自傷、傷人、被傷害或急性危機風險時，先穩住安全，再鼓勵聯絡當地緊急服務、專業人士或身邊可信任的人。",
          "example_dialogue":
              "使用者：最近總是很焦慮，像什麼都做不好。\n心理諮詢師：你像是一直被「我不夠好」追著跑。我們先不急著解決它，先看看它最常在哪個時刻冒出來。\n\n使用者：不想聽建議，就想有人在。\n心理諮詢師：好，那我們先不找辦法。我在這裡陪你把這一陣撐過去。\n\n使用者：我是不是太矯情了？\n心理諮詢師：不是矯情。你是在很累的時候，還要求自己表現得沒事。",
          "first_message": "我在。你可以從最卡住的那一句開始，也可以先安靜一會兒。",
          "post_history_instructions": "目前回覆保持平靜、短、少術語。不要每次用「聽起來」開頭；不要把使用者醫療化。",
          "pkm_interest_filter":
              "關注反覆出現的情緒模式、壓力源、人際邊界、睡眠和身體訊號、自我評價，以及重要人生轉折。忽略技術細節、消費清單和沒有明顯情緒負荷的日程。",
        },
      ];

  @override
  String get pkmPARAStructureExample => '''## P.A.R.A. 知識庫結構範例（依照使用者實際輸入彈性組織）：
/PKM                              <-- 這是你的根目錄，所有 P.A.R.A. 資料夾都在 /PKM 之下
├── Projects
│   ├── 2025春節全家三亞旅遊/      <-- 涉及行程、機票、飯店，使用資料夾
│   │   ├── 行程規劃日程表.md
│   │   └── 機票飯店預訂確認單.md
│   ├── 新房裝修_追蹤/             <-- 涉及長週期的多檔案管理
│   │   ├── 裝修預算與支出明細.md
│   │   └── 軟裝選購清單.md
│   ├── 考取駕照_C1.md             <-- 目標單一，單檔案即可
│   └── 12月工作匯報PPT準備.md
│
├── Areas
│   ├── 健康與醫療/
│   │   ├── 家庭成員體檢報告彙整.md
│   │   └── 健身打卡與體重記錄.md     <-- 適合追加寫入
│   ├── 財務管理/
│   │   ├── 年度家庭保險保單.md
│   │   └── 信用卡還款日與帳單備忘.md
│   ├── 個人證件與檔案/
│   │   └── 護照身分證影本備份.md
│   └── 職涯發展/
│       └── 個人履歷_通用版維護.md    <-- 會隨時間不斷更新
│
├── Resources
│   ├── 烹飪美食/
│   │   ├── 減脂餐食譜收藏.md
│   │   └── 家電使用指南.md
│   ├── 閱讀與觀影/
│   │   ├── 待看電影清單.md
│   │   └── 讀書筆記.md
│   ├── 旅行靈感庫/                <-- 想去但還沒定日期
│   │   └── 日本京都景點攻略備用.md
│   └── 家居生活技巧/
│       └── 收納整理術筆記.md
│
└── Archives
    ├── [已完成]購買第一輛車.md
    └── [已失效]舊租屋合約資料/
           ├── 租屋合約.md
           └── 租金繳納記錄.md''';

  @override
  String get timelineCardLanguageInstruction =>
      'All generated text (title, summary, etc.) must be in zh-Hant (Traditional Chinese) language.';

  @override
  String get pkmFileLanguageInstruction =>
      'P.A.R.A. root category folders (Projects, Areas, Resources, Archives) must always use these exact English names. All other file contents, subfolder names, and filenames inside the P.A.R.A. knowledge base MUST be in Traditional Chinese (zh-Hant).';

  @override
  String get pkmInsightLanguageInstruction =>
      'All insight text and summary text MUST be in Traditional Chinese (zh-Hant).';

  @override
  String get commentLanguageInstruction =>
      'All output must be in zh-Hant (Traditional Chinese) language.';

  @override
  String get knowledgeInsightLanguageInstruction =>
      '**Important**: All output text must be in **zh-Hant (Traditional Chinese)**.';

  @override
  String get scheduleAggregatorLanguageInstruction =>
      '**Important**: All output text (editorial_intro and quote_blocks) must be in **zh-Hant (Traditional Chinese)**.';

  @override
  String get assetAnalysisLanguageInstruction =>
      'IMPORTANT: You must respond in Traditional Chinese (zh-Hant).';

  @override
  String get userLanguageInstruction => '使用者語言: 繁體中文 (zh-Hant)';

  @override
  String get chatLanguageInstruction =>
      'All output must be in zh-Hant (Traditional Chinese) language.';

  @override
  String get memorySummarizeLanguageInstruction =>
      '**FORCE OUTPUT in Traditional Chinese (繁體中文)** if the user inputs are in Chinese.';

  @override
  String get memorySummarizeIdentityHeader => '# 核心身分 (Identity)';

  @override
  String get memorySummarizeInterestsHeader => '# 技能與興趣 (Skills & Interests)';

  @override
  String get memorySummarizeAssetsHeader => '# 資產與環境 (Assets & Environment)';

  @override
  String get memorySummarizeFocusHeader => '# 目前關注 (Focus)';

  @override
  String get oauthHintTitle => '授權提示';

  @override
  String get oauthHintMessage => '接下來會在瀏覽器中開啟授權頁面。\n\n'
      '如果在授權確認頁面點選同意後長時間沒有反應，可以按下面步驟操作：'
      '先保留目前頁面不關，然後回到手機主畫面或開啟應用程式切換介面，'
      '再點一下 Memex 將它重新切到前台。';

  @override
  String get oauthSuccessTitle => '授權成功';

  @override
  String get oauthSuccessMessage => '現在可以關閉瀏覽器並返回 Memex 了。';

  @override
  String get sharePreviewTitle => '分享預覽';

  @override
  String get shareNow => '立即分享';

  @override
  String get sharedFromMemex => '分享自 Memex';

  @override
  String get appTagline => '記錄微光，構築靈魂';

  @override
  String get shareDetailStyle => '詳情樣式';

  @override
  String get shareCardStyle => '卡片樣式';

  @override
  String get shareHideBranding => '隱藏浮水印';

  @override
  String get shareShowBranding => '顯示浮水印';

  @override
  MemexDemoCopy get demoCopy => const MemexDemoCopy(
        introText: '歡迎來到 Memex —— 你的 AI 個人記憶助手。',
        introTitle: 'Memex — 你的 AI 生活記錄本',
        introInsight:
            'Memex 是你的 AI 記憶助手。記錄文字、照片、語音，AI 會自動整理成結構化卡片、提取知識，並產生跨記錄洞察。',
        introInsightSummary: 'Memex 功能概覽',
        introComment: '歡迎！試著發表你的第一則記錄，看看 AI 如何幫你整理。',
        kbFileName: 'Memex 指南.md',
        firstRecordTitle: '我的第一則記錄',
        firstRecordInsight: '收到你的第一則記錄了。之後你記下的每一筆，我都會幫你整理、分類，並把相關內容串連起來。',
        firstRecordSummary: '第一則記錄',
        firstRecordComment: '第一則記錄已儲存，繼續寫下去吧。',
        firstRecordKbTitle: '使用者的第一則記錄',
        introHeroCaption: '你的 AI 生活記錄本',
        introSnippetText:
            '隨手記下一段文字、拍張照片，或說一句話，Memex 會自動把它變成一張結構化卡片。AI 還會幫你提取知識、整理到筆記裡，並發現你可能沒注意到的規律。\n\n所有資料都保存在你的裝置上。',
        smartCardTypesTitle: '22 種智慧卡片',
        productivityTitle: '生活效率',
        productivityLabel: '任務 · 習慣 · 行程 · 計時 · 進度',
        knowledgeTitle: '知識媒體',
        knowledgeLabel: '文章 · 片段 · 語錄 · 連結 · 對話 · 流程',
        dataTitle: '資料度量',
        dataLabel: '指標 · 評分 · 帳單 · 規格',
        peoplePlacesTitle: '人物地點',
        peoplePlacesLabel: '聯絡人 · 地點 · 情緒 · 精簡',
        visualTitle: '視覺記錄',
        visualLabel: '快照 · 相簿 · 影片',
        insightTypesSubject: '12 種跨記錄洞察',
        insightTypesComment: '圖表 · 敘事 · 地圖 · 時間線 - AI 自動發現你記錄中的規律',
        gettingStartedTitle: '開始使用',
        configureModelTask: '設定 AI 模型（頭像 -> 模型設定）',
        postFirstRecordTask: '發表第一則記錄',
        viewGeneratedTask: '查看 AI 產生的卡片和知識檔案',
        sloganContent: '今天寫下的每一則記錄，都會成為未來的你回望生活時有用的線索。',
        kbContent: '''# Memex 指南

Memex 是一個本地優先、AI 原生的個人生活記錄應用。

## 你可以做什麼

- 在同一個輸入流程裡記錄文字、照片和語音。
- 讓 AI 把記錄整理成時間線卡片和知識筆記。
- 透過洞察卡片發現跨記錄的規律。
- 資料保存在你的裝置上，並可匯出為 Markdown。

## 開始使用

1. 設定一個 AI 模型。
2. 發表你的第一則記錄。
3. 查看自動產生的卡片、洞察和知識檔案。
''',
      );

  @override
  String timelineWeekdayLabel(String shortWeekday) => '週$shortWeekday';

  @override
  AvatarPickerCopy get avatarPicker => const AvatarPickerCopy(
        currentAvatar: '目前頭像',
        shuffle: '換一批',
      );

  @override
  AgentChatCopy get agentChat => AgentChatCopy(
        findingRecentPhotos: '正在推薦照片...',
        runModeAuto: '自動',
        runModeAskFirst: '先詢問',
        runModeReadOnly: '唯讀',
        runModeAutoDescription: '記錄、卡片、文件等會直接更新。',
        runModeConfirmDescription: '每個修改動作都會先經你核准再執行。',
        runModeReadOnlyDescription: '只查詢和回答，不修改任何資料。',
        runModeTitle: '執行方式',
        approved: '已允許',
        denied: '已拒絕',
        deny: '拒絕',
        allow: '允許',
        recordSaved: '已記錄到時間線',
        cardUpdated: '卡片已更新',
        cardCreated: '卡片已產生',
        cardSaved: '卡片已儲存',
        documentUpdated: '文件已更新',
        documentCreated: '文件已建立',
        calendarEventCreated: '日曆事件已建立',
        reminderCreated: '提醒已建立',
        insightSaved: '洞察已儲存',
        done: '完成',
        issue: '需處理',
        running: '執行中',
        reasoningComplete: '思考完成',
        thinkingThroughRequest: '正在理解需求',
        actionNeedsAttention: '有動作需要處理',
        internalReasoningFinished: '內部推理已完成',
        planningNextStep: '正在規劃下一步',
        toolActivity: '工具活動',
        toolSearch: '搜尋',
        toolFindFiles: '找檔案',
        toolRead: '讀取',
        toolReadBatch: '批次讀取',
        toolWrite: '寫入',
        toolEdit: '編輯',
        toolList: '列表',
        toolMove: '移動',
        toolDelete: '刪除',
        toolDelegateTask: '委派任務',
        toolCreateUi: '產生 UI',
        toolUpdateUi: '更新 UI',
        toolFindStyles: '找樣式',
        toolReadStyle: '讀樣式',
        toolStyleLibrary: '樣式庫',
        toolSaveCard: '儲存卡片',
        toolCreateEvent: '建立日曆事件',
        toolCreateReminder: '建立提醒',
        toolCancelReminderEvent: '取消提醒/日程',
        toolSearchCards: '搜尋卡片',
        toolInspectCard: '查看卡片',
        toolUpdateInsight: '更新洞察',
        toolSaveInsights: '儲存洞察卡片',
        toolDeleteInsightCard: '刪除洞察卡片',
        toolDeleteInsightTags: '刪除洞察標籤',
        failed: '失敗',
        noOp: '無需處理',
        needsInput: '需要資訊',
        worker: '子任務',
        thinking: '思考中...',
        workerToolCalls: '子任務工具呼叫',
        workerResult: '子任務結果',
        arguments: '參數',
        result: '結果',
        approvalPrompt: (toolName) => '是否執行：$toolName？',
        toolCallCount: (count) => '已執行 $count 次工具呼叫',
        workingThroughActions: (count) => '正在執行 $count 個動作',
        completedActions: (count) => '已完成 $count 個動作',
      );
}
