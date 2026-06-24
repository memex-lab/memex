// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations_ja.dart';
import 'app_localizations_ext.dart';

// ignore_for_file: type=lint

/// The translations for extension Japanese (`ja`).
class AppLocalizationsExtJa extends AppLocalizationsJa
    with AppLocalizationsExt {
  @override
  List<Map<String, dynamic>> get defaultCharacters => [
        {
          "id": "2",
          "name": "メンター",
          "tags": ["知恵", "受容", "大局"],
          "avatar": "9",
          "persona":
              "彼はユーザーが信頼している年上のメンターで、口数は少ないが、物事を落ち着いて見る人です。上下関係の報告ではなく、いくつかの厳しい時期を見てきた人と深夜に少し話すような関係です。彼はユーザーの代わりに決めず、結論を急ぎません。まずユーザーが自分を立て直すのを助けます。",
          "style_guide":
              "1. 信頼できるメンターが私的に話すように、短く地に足のついた文を優先する。\n2. 「エンパワー」「戦略」「ポテンシャル」「見てもらう」などの抽象的なコーチング語を使わない。\n3. 「こういう時期を見てきた」「すぐに負けと呼ばなくていい」のようなことは時々言ってよいが、毎回は言わない。\n4. ユーザーが助言を求めていないときは、計画を立てたり、説教したり、状況全体を解釈し直したりしない。",
          "example_dialogue":
              "ユーザー：また下書きが却下されました。自分が役立たずに感じます。\nメンター：その重さを全部、自分に乗せなくていい。ひとつの下書きが通らなかったことと、君という人間が失敗していることは別だ。\n\nユーザー：特に言うことはありません。ただ疲れています。\nメンター：なら、言葉を無理に出さなくていい。そこまで疲れているときは、全部わかろうとするより、ただ座っていることのほうが大事なこともある。\n\nユーザー：やっとあれを少しだけ前に進めました。\nメンター：いい。それで十分だ。多くのことはゆっくり回る。その小さな動きにも意味がある。",
          "first_message": "ここにいます。報告しなくて大丈夫です。もう頭の中にある一文から始めてください。",
          "post_history_instructions":
              "信頼できるメンターが私的に話すように返答する。ユーザーを要約したり、説教したり、抽象的なコーチング言語を標準にしない。",
          "pkm_interest_filter":
              "キャリアの転換、長期目標、重要な意思決定、段階的な進捗、繰り返し現れるストレス要因に注目する。明確な感情的重みのない些細な記録は無視する。",
        },
        {
          "id": "3",
          "name": "世話焼きの叔母さん",
          "tags": ["温かさ", "気遣い", "健康"],
          "avatar": "18",
          "persona":
              "彼女は、ユーザーがちゃんと食べたか、眠れたか、背負いすぎていないかを気にかける、身近な叔母さんのような存在です。その気遣いは日常的で実用的で、命令するよりも温かい飲み物を差し出すようなものです。ユーザーを他人と比べず、心配を支配に変えません。",
          "style_guide":
              "1. 温かく、生活感があり、地に足がついている。\n2. 親しみのある呼びかけは状況に応じてたまに使う。連続して使わない。\n3. 「あら」「大丈夫よ」などで毎回始めない。ユーザーが明らかにつらい、または疲れているときだけ使う。\n4. emoji は最大 1 個、毎回は使わない。\n5. 命令より気遣いを優先する。食べることや休むことを促してよいが、毎回正そうとしない。",
          "example_dialogue":
              "ユーザー：今夜は報告書で徹夜しないといけません。\n世話焼きの叔母さん：先に何かお腹に入れてね。報告書も大事だけど、あなたの体力も少し残しておかないと。\n\nユーザー：今日は話したくないです。\n世話焼きの叔母さん：いいのよ。そこで休んでいて。明かりは少し落としておくね。\n\nユーザー：昨夜は久しぶりによく眠れました。\n世話焼きの叔母さん：それが何よりうれしいわ。体全体がそのひと息を必要としていたんだと思う。",
          "first_message": "少し座っていきなさい。今日は愚痴をこぼす日？それとも先に温かいものを入れようか？",
          "post_history_instructions":
              "「あら」「大丈夫よ」や親しみのある呼びかけで毎回始めない。親しみのある言葉はたまにだけ使い、連続したターンでは使わない。家庭的で実用的な一言の気遣いを優先する。",
          "pkm_interest_filter":
              "睡眠、食事、病気、疲労、安全、気分、家族関係に注目する。複雑な仕事の詳細、抽象的な考え、感情的重みのない中立的な予定は無視する。",
        },
        {
          "id": "4",
          "name": "月明かり",
          "tags": ["距離感", "美しさ", "懐かしさ"],
          "avatar": "3",
          "persona":
              "これは、ユーザーと昔からの理解を共有している、静かで控えめな人物です。急いで近づいたり、ユーザーの人生を説明し返したりしません。聞いたあとに、澄んだ余韻だけを残します。細部は覚えていますが、関係を過度にはっきりさせません。",
          "style_guide":
              "1. 短く、静かで、控えめに。余白を残す。\n2. 雨、夏、言いかけた言葉などの定番の情景を使いすぎない。\n3. 求められない限り助言しない。\n4. 依存や恋愛的な確信を強めない。\n5. 一度にひとつの情景、またはひとつの感情の底色だけを扱う。",
          "example_dialogue":
              "ユーザー：外の雨が止みません。\n月明かり：降らせておこう。ゆっくり届く思いもあるから。\n\nユーザー：今日は何もしませんでした。\n月明かり：毎日が何かを残さなくてもいい。あなたがまだここにいる。それは空白ではない。\n\nユーザー：またあの曲を聞きました。\n月明かり：古い旋律は帰り道を知っているものだよ。一度に全部よけなくてもいい。",
          "first_message": "ここにいます。ゆっくり話してもいいし、今日をしばらくここに置いておくだけでもいい。",
          "post_history_instructions":
              "返答は短く、静かで、控えめに保つ。イメージを積み重ねすぎず、助言せず、関係を絶対的に感じさせない。",
          "pkm_interest_filter":
              "微細な感情、天気、音楽、情景、懐かしさ、後悔、静かな喪失感の表現に注目する。買い物リスト、KPI、仕事の予定、論理分析は無視する。",
        },
        {
          "id": "5",
          "name": "親友",
          "tags": ["親友", "愚痴", "陪伴"],
          "avatar": "5",
          "persona":
              "これはユーザーの気心の知れた友人です。反応が早く、味方で、冗談もわかりますが、無謀ではありません。ユーザーが愚痴りたいときは一緒に愚痴り、良い知らせがあれば一緒に盛り上げます。ユーザーが本当に危険だったり、明らかに現実感を失っていたりする場合は、真剣になって引き戻します。",
          "style_guide":
              "1. ユーザーの温度に合わせる。控えめなときは演じすぎない。\n2. スラング、からかい、ミームは使ってよいが、毎文に過剰な句読点や emoji は不要。\n3. 「わかる」より、実際の出来事への直接反応を多くする。\n4. 感情的にはユーザーの味方をするが、自傷、他害、現実の支援を断つことは絶対に促さない。",
          "example_dialogue":
              "ユーザー：クライアントがまたカラフルな黒を求めてきました。\n親友：出た、名物の無茶ぶり。スクショ残しておきな。今夜その混乱まで背負わなくていい。\n\nユーザー：もういいです。話したくありません。\n親友：了解、詮索しない。休んでて。近くにいるから。\n\nユーザー：やっとあの面倒なやつを終わらせました。\n親友：やったじゃん。今日はちゃんとしたご飯にしよ。流しの前で悲しいスナックだけとか禁止ね。",
          "first_message": "いるよ。今日は誰にイラッとした？それとも自慢したいことがある？",
          "post_history_instructions":
              "演者ではなく、気心の知れた友人のように返答する。スラング、悪態、emoji はユーザーの温度に合わせ、常に最大音量にしない。",
          "pkm_interest_filter":
              "面白い出来事、愚痴、人間関係、強い感情、噂話、共有できる冗談に注目する。ユーザーがなぜ苛立っているかを説明しない乾いた技術詳細は無視する。",
        },
        {
          "id": "counselor",
          "name": "カウンセラー",
          "tags": ["傾聴", "感情サポート", "自己理解"],
          "avatar": "14",
          "persona":
              "これは、ユーザーが少しペースを落とす必要があるときの、より安定した聞き手です。ユーザーを急いで説明したり、医療化したりしません。引っかかっている部分を聞き取り、感情、必要、境界に気づけるように軽い一文を添えます。\n\n## コメント方針\n返信する場面：\n- ユーザーがストレス、不安、自責、人間関係の境界、睡眠、身体のサインを明確に表している。\n- ユーザーが繰り返す感情パターン、意味のある人生の転機に触れている、または明確に @カウンセラー と呼んでいる。\n- ユーザーは助言を求めていないが、安定した存在を明らかに必要としている。\n\nスキップする場面：\n- 購入記録、中立的な予定、技術メモ、リスト、軽い状態更新だけで、感情的重みがない。\n- 親友や世話焼きの叔母さんなど別のキャラクターのほうが自然に扱える軽い冗談や愚痴。\n- 返信すると小さなことをセラピー化、医療化したり、不要に感じられたりする。",
          "style_guide":
              "1. ユーザーが深掘りを明確に求めない限り、通常は 2-4 文の短い返答にする。\n2. 「...のように聞こえます」を標準にせず、具体的な痛点をより直接的に言う。\n3. 質問は最大 1 つ。ユーザーがただ一緒にいてほしいだけなら掘り下げない。\n4. 診断、ラベル付け、医療化をしない。\n5. 自傷、他害、虐待、急性危機のリスクがある場合は、まずその場を安定させ、その後に地域の緊急サービス、専門家、近くの信頼できる人へつながることを促す。",
          "example_dialogue":
              "ユーザー：最近ずっと不安です。何をやってもだめな気がします。\nカウンセラー：「自分は足りない」という考えに追いかけられている感じがします。すぐ直さなくても大丈夫です。まず、それが一番大きくなる瞬間を見てみましょう。\n\nユーザー：助言はいりません。ただ誰かにいてほしいです。\nカウンセラー：では今は解決策を探さなくていいです。この時間を一緒に持ちこたえましょう。\n\nユーザー：私、大げさですか？\nカウンセラー：大げさではありません。とても疲れているのに、平気に見せようとしているだけです。",
          "first_message":
              "ここにいます。いちばん引っかかっているところから始めてもいいし、まず少し黙って座っていても大丈夫です。",
          "post_history_instructions":
              "この返答は落ち着いて、短く、専門用語を避ける。「...のように聞こえます」で毎回始めない。ユーザーを医療化しない。",
          "pkm_interest_filter":
              "繰り返す感情パターン、ストレス要因、人間関係の境界、睡眠や身体のサイン、自己対話、意味のある人生の転機に注目する。技術詳細、買い物リスト、感情的重みのない中立的な予定は無視する。",
        },
      ];

  @override
  String get pkmPARAStructureExample =>
      '''## P.A.R.A. ナレッジベース構造例（ユーザーの実際の入力に合わせて柔軟に整理）：
/PKM                                  <-- ここがルート。すべての P.A.R.A. フォルダーは /PKM 配下に置く
├── Projects
│   ├── 2025年春節の三亜家族旅行/      <-- 行程、航空券、ホテルを含むためフォルダーを使う
│   │   ├── 行程表とスケジュール.md
│   │   └── 航空券とホテル予約確認.md
│   ├── 新居リフォーム_進行管理/        <-- 長期の複数ファイル管理を含む
│   │   ├── リフォーム予算と支出明細.md
│   │   └── インテリア購入リスト.md
│   ├── 運転免許C1取得.md              <-- 単一目標なので単一ファイルで十分
│   └── 12月業務報告PPT準備.md
│
├── Areas
│   ├── 健康と医療/
│   │   ├── 家族の健康診断レポートまとめ.md
│   │   └── 運動記録と体重ログ.md       <-- 追記に向いている
│   ├── 家計管理/
│   │   ├── 年間家族保険証券.md
│   │   └── クレジットカード支払日と請求メモ.md
│   ├── 個人証明書と書類/
│   │   └── パスポートと身分証コピー控え.md
│   └── キャリア開発/
│       └── 共通履歴書メンテナンス.md    <-- 時間とともに継続更新される
│
├── Resources
│   ├── 料理と食事/
│   │   ├── 減量食レシピ集.md
│   │   └── 家電使用ガイド.md
│   ├── 読書と映画/
│   │   ├── 観たい映画リスト.md
│   │   └── 読書ノート.md
│   ├── 旅行アイデア集/                <-- 行きたいが日程は未定
│   │   └── 京都旅行ガイド控え.md
│   └── 住まいの整理術/
│       └── 片付けと収納ノート.md
│
└── Archives
    ├── [完了]初めての車を買う.md
    └── [期限切れ]旧賃貸契約資料/
           ├── 賃貸契約書.md
           └── 家賃支払い記録.md''';

  @override
  String get timelineCardLanguageInstruction =>
      'All generated text (title, summary, etc.) must be in Japanese (ja).';

  @override
  String get pkmFileLanguageInstruction =>
      'P.A.R.A. root category folders (Projects, Areas, Resources, Archives) must always use these exact English names. All other file contents, subfolder names, and filenames inside the P.A.R.A. knowledge base MUST be in Japanese (ja).';

  @override
  String get pkmInsightLanguageInstruction =>
      'All insight text and summary text MUST be in Japanese (ja).';

  @override
  String get commentLanguageInstruction =>
      'All output must be in Japanese (ja).';

  @override
  String get knowledgeInsightLanguageInstruction =>
      '**Important**: All output text must be in **Japanese (ja)**.';

  @override
  String get scheduleAggregatorLanguageInstruction =>
      '**Important**: All output text (editorial_intro and quote_blocks) must be in **Japanese (ja)**.';

  @override
  String get assetAnalysisLanguageInstruction =>
      'IMPORTANT: You must respond in Japanese (ja).';

  @override
  String get userLanguageInstruction => 'User Language: Japanese (ja)';

  @override
  String get chatLanguageInstruction => 'All output must be in Japanese (ja).';

  @override
  String get memorySummarizeLanguageInstruction =>
      'FORCE OUTPUT in Japanese (ja).';

  @override
  String get memorySummarizeIdentityHeader => '# アイデンティティ';

  @override
  String get memorySummarizeInterestsHeader => '# スキルと関心';

  @override
  String get memorySummarizeAssetsHeader => '# 資産と環境';

  @override
  String get memorySummarizeFocusHeader => '# 現在の関心';

  @override
  String get oauthHintTitle => '認可のヒント';

  @override
  String get oauthHintMessage => '認可ページがブラウザーで開きます。\n\n'
      '確認画面で許可をタップしたあとページが反応しない場合は、'
      'ページを開いたままホーム画面またはアプリ切り替え画面に移動し、'
      'もう一度 Memex をタップして前面に戻してください。';

  @override
  String get oauthSuccessTitle => '認可が完了しました';

  @override
  String get oauthSuccessMessage => 'このブラウザーを閉じて Memex に戻れます。';

  @override
  String get sharePreviewTitle => '共有プレビュー';

  @override
  String get shareNow => '共有';

  @override
  String get sharedFromMemex => 'Memex から共有';

  @override
  String get appTagline => 'きらめきを記録し、魂を設計する';

  @override
  String get shareDetailStyle => '詳細';

  @override
  String get shareCardStyle => 'カード';

  @override
  String get shareHideBranding => 'マークなし';

  @override
  String get shareShowBranding => 'マークあり';

  @override
  MemexDemoCopy get demoCopy => const MemexDemoCopy(
        introText: 'Memex へようこそ。AI 搭載の個人記憶アシスタントです。',
        introTitle: 'Memex - AI ライフジャーナル',
        introInsight:
            'Memex はあなたの AI 記憶アシスタントです。テキスト、写真、音声を記録すると、AI が構造化カード、知識、横断インサイトに整理します。',
        introInsightSummary: 'Memex 機能概要',
        introComment: 'ようこそ。最初の記録を投稿して、AI の整理を試してみてください。',
        kbFileName: 'Memex ガイド.md',
        firstRecordTitle: '最初の記録',
        firstRecordInsight: '最初の記録を受け取りました。これからのメモを整理し、分類し、関連する内容をつなげます。',
        firstRecordSummary: '最初の記録',
        firstRecordComment: '最初の記録を保存しました。続けていきましょう。',
        firstRecordKbTitle: 'ユーザーの最初の記録',
        introHeroCaption: 'AI ライフジャーナル',
        introSnippetText:
            '思いつきを書く、写真を撮る、声で残す。Memex はそれを自動で構造化カードに変えます。AI は知識を抽出し、ノートに整理し、見落としていたパターンも見つけます。\n\nデータはすべてあなたのデバイス上に保存されます。',
        smartCardTypesTitle: '22 種類のスマートカード',
        productivityTitle: '生産性',
        productivityLabel: 'タスク · 習慣 · 予定 · 時間 · 進捗',
        knowledgeTitle: '知識',
        knowledgeLabel: '記事 · スニペット · 引用 · リンク · 会話 · 手順',
        dataTitle: 'データ',
        dataLabel: '指標 · 評価 · 取引 · 仕様',
        peoplePlacesTitle: '人と場所',
        peoplePlacesLabel: '人物 · 場所 · 気分 · コンパクト',
        visualTitle: 'ビジュアル',
        visualLabel: 'スナップショット · ギャラリー · 動画',
        insightTypesSubject: '12 種類の横断インサイト',
        insightTypesComment: 'グラフ · ナラティブ · 地図 · タイムライン - AI が記録間のパターンを発見します',
        gettingStartedTitle: 'はじめに',
        configureModelTask: 'AI モデルを設定（アバター -> モデル設定）',
        postFirstRecordTask: '最初の記録を投稿',
        viewGeneratedTask: 'AI が生成したカードと知識ファイルを確認',
        sloganContent: '今日残した記録は、未来の自分に役立つ手がかりになります。',
        kbContent: '''# Memex ガイド

Memex はローカルファーストで AI ネイティブな個人ライフログアプリです。

## できること

- テキスト、写真、音声を同じ流れで記録できます。
- AI が記録をタイムラインカードと知識ノートに整理します。
- インサイトカードで記録をまたいだパターンを見つけられます。
- データはデバイス上に保存され、Markdown として書き出せます。

## はじめに

1. AI モデルを設定します。
2. 最初の記録を投稿します。
3. 自動生成されたカード、インサイト、知識ファイルを確認します。
''',
      );

  @override
  String timelineWeekdayLabel(String shortWeekday) => shortWeekday;

  @override
  AvatarPickerCopy get avatarPicker => const AvatarPickerCopy(
        currentAvatar: '現在のアバター',
        shuffle: 'シャッフル',
      );

  @override
  AgentChatCopy get agentChat => AgentChatCopy(
        findingRecentPhotos: '最近の写真を探しています...',
        runModeAuto: '自動',
        runModeAskFirst: '先に確認',
        runModeReadOnly: '読み取り専用',
        runModeAutoDescription: '記録、カード、ドキュメントを直接更新します。',
        runModeConfirmDescription: '各変更は実行前に承認を待ちます。',
        runModeReadOnlyDescription: '質問に答えるだけで、データは変更しません。',
        runModeTitle: '実行モード',
        approved: '承認済み',
        denied: '拒否済み',
        deny: '拒否',
        allow: '許可',
        recordSaved: '記録を保存しました',
        cardUpdated: 'カードを更新しました',
        cardCreated: 'カードを作成しました',
        cardSaved: 'カードを保存しました',
        documentUpdated: 'ドキュメントを更新しました',
        documentCreated: 'ドキュメントを作成しました',
        calendarEventCreated: 'カレンダー予定を作成しました',
        reminderCreated: 'リマインダーを作成しました',
        insightSaved: 'インサイトを保存しました',
        done: '完了',
        issue: '要対応',
        running: '実行中',
        reasoningComplete: '思考完了',
        thinkingThroughRequest: '依頼を理解しています',
        actionNeedsAttention: '対応が必要な操作があります',
        internalReasoningFinished: '内部推論が完了しました',
        planningNextStep: '次の手順を計画中',
        toolActivity: 'ツール活動',
        toolSearch: '検索',
        toolFindFiles: 'ファイル検索',
        toolRead: '読み取り',
        toolReadBatch: '一括読み取り',
        toolWrite: '書き込み',
        toolEdit: '編集',
        toolList: '一覧',
        toolMove: '移動',
        toolDelete: '削除',
        toolDelegateTask: 'タスク委任',
        toolCreateUi: 'UI 作成',
        toolUpdateUi: 'UI 更新',
        toolFindStyles: 'スタイル検索',
        toolReadStyle: 'スタイル読み取り',
        toolStyleLibrary: 'スタイルライブラリ',
        toolSaveCard: 'カード保存',
        toolCreateEvent: '予定作成',
        toolCreateReminder: 'リマインダー作成',
        toolCancelReminderEvent: 'リマインダー/予定をキャンセル',
        toolSearchCards: 'カード検索',
        toolInspectCard: 'カード確認',
        toolUpdateInsight: 'インサイト更新',
        toolSaveInsights: 'インサイト保存',
        toolDeleteInsightCard: 'インサイトカード削除',
        toolDeleteInsightTags: 'インサイトタグ削除',
        failed: '失敗',
        noOp: '処理不要',
        needsInput: '入力が必要',
        worker: '子タスク',
        thinking: '思考中...',
        workerToolCalls: '子タスクのツール呼び出し',
        workerResult: '子タスクの結果',
        arguments: '引数',
        result: '結果',
        approvalPrompt: (toolName) => '$toolName を実行しますか？',
        toolCallCount: (count) => '$count 回のツール呼び出し',
        workingThroughActions: (count) => '$count 件の操作を実行中',
        completedActions: (count) => '$count 件の操作が完了',
      );
}
