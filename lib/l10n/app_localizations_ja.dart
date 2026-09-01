// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get timesLabel => '回数';

  @override
  String modelSetAsDefault(Object modelId) {
    return '$modelId をデフォルトモデルに設定';
  }

  @override
  String get retry => '再試行';

  @override
  String get unknownModel => '不明なモデル';

  @override
  String get notSet => '未設定';

  @override
  String get confirmClear => 'クリアの確認';

  @override
  String get confirmClearTokenMessage =>
      '現在のユーザーをクリアしますか？ユーザー ID を再入力する必要があります。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get confirm => '確認';

  @override
  String get tokenCleared => 'ユーザーをクリアしました';

  @override
  String clearTokenFailed(Object error) {
    return 'ユーザーのクリアに失敗しました: $error';
  }

  @override
  String get selectDateRangeOptional => '日付範囲を選択（任意）:';

  @override
  String get startDate => '開始日';

  @override
  String get endDate => '終了日';

  @override
  String get select => '選択';

  @override
  String get processLimitOptional => '処理件数の上限（任意）';

  @override
  String get leaveEmptyForAll => 'すべて処理する場合は空欄のままにしてください';

  @override
  String get startProcessing => '処理を開始';

  @override
  String get userIdNotFound => 'ユーザー ID が見つかりません';

  @override
  String createTaskFailed(Object error) {
    return 'タスクの作成に失敗しました: $error';
  }

  @override
  String get reprocessCards => 'カードを再処理';

  @override
  String get reprocessCardsTaskCreated => '再処理リクエストを スーパーエージェントのキューに追加しました';

  @override
  String get reprocessCardsDownstreamMode => '範囲';

  @override
  String get reprocessCardsCardOnly => 'カードのみ';

  @override
  String get reprocessCardsCardOnlyDesc =>
      '選択したタイムラインカードの確認と再生成を スーパーエージェントに依頼します。';

  @override
  String get reprocessCardsRerunDownstream => 'カードと関連する後続処理';

  @override
  String get reprocessCardsRerunDownstreamDesc =>
      '必要に応じて、関連する PKM とインサイト更新も スーパーエージェントに考慮させます。';

  @override
  String get reanalyzeMediaAssets => 'メディア添付を再読み取り';

  @override
  String get reanalyzeMediaAssetsDesc =>
      'カード再生成時に、添付メディアをもう一度確認するよう スーパーエージェントに依頼します。';

  @override
  String get regenerateComments => 'コメントを再生成';

  @override
  String get regenerateCommentsTaskCreated =>
      'コメント再生成タスクを作成しました。バックグラウンドで実行しています';

  @override
  String get rebuildSearchIndex => '検索インデックスを再構築';

  @override
  String get rebuildSearchIndexSuccess => '検索インデックスを正常に再構築しました';

  @override
  String get rebuildSearchIndexFailed => '検索インデックスの再構築に失敗しました';

  @override
  String get clearData => 'データをクリア';

  @override
  String get confirmClearDataMessage => 'データをクリアしますか？';

  @override
  String get confirmClearDataDeletesWorkspaceMessage =>
      '現在のユーザーのすべてのローカルワークスペースデータが削除されます。カード、メディア、ナレッジファイル、インサイト、メモリ、チャット履歴、システム状態が含まれます。\n\nこの操作は元に戻せません！';

  @override
  String get clearFailedAgentContexts => '失敗した会話コンテキストをクリア';

  @override
  String get confirmClearFailedAgentContextsMessage =>
      'インサイトエージェント と スケジュールエージェントの保存済み会話コンテキストをクリアしますか？以前の エージェントメッセージがモデル変更後に互換性を失った場合に役立ちます。ファクト、カード、ナレッジ、メモリ、モデル設定は削除されません。';

  @override
  String failedAgentContextsCleared(Object count) {
    return '保存済み会話コンテキストを $count 件クリアしました';
  }

  @override
  String clearFailedAgentContextsFailed(Object error) {
    return '会話コンテキストのクリアに失敗しました: $error';
  }

  @override
  String get cloneToTestUser => 'テストユーザーへ複製';

  @override
  String get confirmCloneToTestUserMessage =>
      '現在のワークスペースを新しいローカルテストユーザーにコピーし、そのユーザーへ切り替えます。エージェントの実行状態はコピーされません。現在のユーザーデータは変更されません。';

  @override
  String get testUserIdLabel => 'テストユーザー ID';

  @override
  String get testUserIdHelper => '英字、数字、ハイフン、アンダースコアを使用してください。';

  @override
  String get testUserIdInvalid => '英字、数字、ハイフン、アンダースコアのみ使用できます。';

  @override
  String get overwriteExistingTestUser => '同じ ID の既存テストユーザーを置き換える';

  @override
  String testUserCloneSuccess(Object userId) {
    return 'テストユーザー $userId に切り替えました';
  }

  @override
  String testUserCloneFailed(Object error) {
    return 'テストユーザーの複製に失敗しました: $error';
  }

  @override
  String get dataClearedSuccess => 'データを正常にクリアしました';

  @override
  String clearDataFailed(Object error) {
    return 'データのクリアに失敗しました: $error';
  }

  @override
  String get personalCenter => 'パーソナルセンター';

  @override
  String get viewLogs => 'ログを表示';

  @override
  String get systemAuthorization => 'システム認可';

  @override
  String get aiCharacterConfig => 'AI キャラクター設定';

  @override
  String get modelConfig => 'モデル設定';

  @override
  String get agentConfig => 'エージェント設定';

  @override
  String get experimentalLab => 'ラボ';

  @override
  String get experimentalLabDescription => '今後変更または移動される可能性がある実験的機能です。';

  @override
  String get modelUsageStats => 'モデル使用統計';

  @override
  String get asyncTaskList => '非同期タスクリスト';

  @override
  String get clearLocalToken => 'ユーザーをクリア';

  @override
  String get insightCardTemplates => 'インサイトカードテンプレート';

  @override
  String get timelineCardTemplates => 'タイムラインカードテンプレート';

  @override
  String get logViewer => 'ログビューア';

  @override
  String get autoRefresh => '自動更新';

  @override
  String get lineCount => '行数: ';

  @override
  String get all => 'すべて';

  @override
  String get schedule => '予定';

  @override
  String get appLockConfig => 'アプリロック設定';

  @override
  String loadStatsFailed(Object error) {
    return '統計の読み込みに失敗しました: $error';
  }

  @override
  String get overview => '概要';

  @override
  String get daily => '日別';

  @override
  String get modelStatsByAgent => 'エージェント別';

  @override
  String get detail => '詳細';

  @override
  String get date => '日付';

  @override
  String get agent => 'エージェント';

  @override
  String get noData => 'データなし';

  @override
  String get totalCalls => '合計呼び出し';

  @override
  String get calls => '呼び出し';

  @override
  String callsCount(Object count) {
    return '$count 回の呼び出し';
  }

  @override
  String get selectDateRange => '日付範囲を選択';

  @override
  String get totalTokens => '合計トークン';

  @override
  String get cacheRate => 'キャッシュ率';

  @override
  String get promptTokens => 'プロンプトトークン';

  @override
  String get completionTokens => '補完トークン';

  @override
  String get cachedTokens => 'キャッシュ済みトークン';

  @override
  String get thoughtTokens => '思考トークン';

  @override
  String get prompt => 'プロンプト';

  @override
  String get completion => '補完';

  @override
  String get cached => 'キャッシュ済み';

  @override
  String get thought => '思考';

  @override
  String get model => 'モデル';

  @override
  String get scene => 'シーン';

  @override
  String get sceneId => 'シーン ID';

  @override
  String get tokenUsage => 'トークン使用量';

  @override
  String get handler => 'ハンドラー';

  @override
  String get modelBreakdown => 'モデル内訳';

  @override
  String get callDetails => '呼び出し詳細';

  @override
  String recordDetailsTitle(Object scene) {
    return '記録の詳細: $scene';
  }

  @override
  String saveLlmConfigFailed(Object error) {
    return 'LLM 設定の保存に失敗しました: $error';
  }

  @override
  String get webHtmlPreviewUnavailable =>
      'Web では HTML プレビューを利用できません。モバイルで表示してください。';

  @override
  String saveUserInfoFailed(Object error) {
    return 'ユーザー情報の保存に失敗しました: $error';
  }

  @override
  String get totalEstimatedCost => '推定総コスト';

  @override
  String get close => '閉じる';

  @override
  String get totalTokenConsumption => '総トークン消費量';

  @override
  String get dataLoadFailedRetry => 'データの読み込みに失敗しました。後でもう一度お試しください。';

  @override
  String get timelineLoadFailedRetry => 'タイムラインの読み込みに失敗しました。後でもう一度お試しください。';

  @override
  String get newPerspective => '新しい視点';

  @override
  String get startPoint => '開始';

  @override
  String get endPoint => '終了';

  @override
  String get originalInput => '元の入力';

  @override
  String get referenceContent => '参照内容';

  @override
  String referenceWithTitle(Object title) {
    return '参照: $title';
  }

  @override
  String get actionCenterTitle => '保留中のアクション';

  @override
  String get noPendingActions => '保留中のアクションはありません';

  @override
  String get clarificationNeeded => 'Memex が確認したがっています';

  @override
  String get clarificationTextHint => '短い回答を入力';

  @override
  String get clarificationTextRequired => 'まず短い回答を追加してください';

  @override
  String get clarificationAnswered => '回答済み';

  @override
  String clarificationAnswerPrefix(Object answer) {
    return '回答: $answer';
  }

  @override
  String get answerSaved => '回答を保存しました';

  @override
  String get clarificationOtherAnswer => '手入力';

  @override
  String get clarificationNotSure => 'わからない / 回答したくない';

  @override
  String get yes => 'はい';

  @override
  String get no => 'いいえ';

  @override
  String get footprintMap => '足跡マップ';

  @override
  String get waypointPlaces => '経由地点';

  @override
  String get unknownPlace => '不明な場所';

  @override
  String get releaseToSend => '離すと送信';

  @override
  String get selectFromAlbum => 'アルバムから選択';

  @override
  String get clipboardPreviewTitle => '新しいクリップボード';

  @override
  String get clipboardPreviewImageTitle => 'クリップボード画像';

  @override
  String get clipboardPreviewImageDescription => '追加できる画像があります';

  @override
  String get clipboardPreviewUnprocessed => 'まだ貼り付けていません';

  @override
  String get clipboardPreviewPasteToInput => '入力欄に貼り付け';

  @override
  String get clipboardPreviewAddImageToInput => '画像を追加';

  @override
  String get clipboardPreviewImageFailed => 'クリップボード画像を読み取れませんでした';

  @override
  String get tellAiWhatHappened => '何があったか AI に伝えてください...';

  @override
  String recordingWithDuration(Object duration) {
    return '録音中: $duration';
  }

  @override
  String get playing => '再生中...';

  @override
  String get sendLabel => '送信';

  @override
  String attachedImagesMessage(Object count) {
    return '$count 枚の画像を送信しました';
  }

  @override
  String get noTaskData => 'タスクデータがありません';

  @override
  String createdAtDate(Object date) {
    return '作成: $date';
  }

  @override
  String updatedAtDate(Object date) {
    return '更新: $date';
  }

  @override
  String durationLabel(Object duration) {
    return '所要時間: $duration';
  }

  @override
  String retryCount(Object count) {
    return '再試行: $count';
  }

  @override
  String get loadDetailFailedRetry => '詳細の読み込みに失敗しました。後でもう一度お試しください。';

  @override
  String get loadFailed => '読み込みに失敗しました';

  @override
  String loadHistoryFailed(Object error) {
    return '履歴の読み込みに失敗しました: $error';
  }

  @override
  String get reload => '再読み込み';

  @override
  String get aiInsightDetail => 'インサイト詳細';

  @override
  String relatedRecordsCount(Object count) {
    return '関連記録（$count）';
  }

  @override
  String get noRelatedRecords => '関連記録はありません';

  @override
  String get useFingerprintToUnlock => '指紋でロック解除';

  @override
  String get locked => 'ロック中';

  @override
  String get wrongPassword => 'パスワードが違います';

  @override
  String get enterPassword => 'パスワードを入力';

  @override
  String get memexLocked => 'Memex はロックされています';

  @override
  String get calendarShortSun => '日';

  @override
  String get calendarShortMon => '月';

  @override
  String get calendarShortTue => '火';

  @override
  String get calendarShortWed => '水';

  @override
  String get calendarShortThu => '木';

  @override
  String get calendarShortFri => '金';

  @override
  String get calendarShortSat => '土';

  @override
  String noRecordsOnDate(Object date) {
    return '$date の記録はありません';
  }

  @override
  String get footprintPath => '足跡の経路';

  @override
  String get lifeCompositionTable => '生活構成';

  @override
  String get emotionReframe => '感情の捉え直し';

  @override
  String get chronicleOfThings => 'ものごとの記録';

  @override
  String get goalProgress => '目標の進捗';

  @override
  String get trendChart => 'トレンドチャート';

  @override
  String get comparisonChart => '比較チャート';

  @override
  String get todayTimeFlow => '今日の時間の流れ';

  @override
  String get aiInputHint => '思い出でも今のことでも、ここにいます...';

  @override
  String get refreshSuperAgentStateTooltip => 'Memex エージェントのコンテキストをクリア';

  @override
  String get refreshSuperAgentStateTitle => 'Memex エージェントの履歴コンテキストをクリアしますか？';

  @override
  String get refreshSuperAgentStateMessage =>
      '表示されているチャット履歴は残りますが、Memex エージェントの過去の実行コンテキストはクリアされ、今後の返信は新しいコンテキストから始まります。永続メモリ、ナレッジベースファイル、カード、その他の保存済みデータには影響しません。Memex エージェントの動作が異常なままのときに使用してください。続行しますか？';

  @override
  String get refreshSuperAgentStateActiveRunMessage =>
      '現在の Memex エージェントメッセージが完了してからコンテキストをクリアしてください。';

  @override
  String get refreshSuperAgentStateSuccess => 'Memex エージェントのコンテキストをクリアしました';

  @override
  String refreshSuperAgentStateFailed(Object error) {
    return 'Memex エージェントのコンテキストのクリアに失敗しました: $error';
  }

  @override
  String get nothingHere => 'まだ何もありません';

  @override
  String get nothingHereHint => '下のボタンをタップして最初のカードを作成';

  @override
  String get agentProcessing => 'AI が処理中です...';

  @override
  String get keepAppOpen => 'アプリを閉じないでください';

  @override
  String get activityDetail => 'アクティビティ詳細';

  @override
  String get noAgentActivityYet => 'エージェントアクティビティはまだありません';

  @override
  String get processingEllipsis => '処理中...';

  @override
  String get agentBackgroundTitle => 'Memex エージェント';

  @override
  String get agentBackgroundPausedTitle => 'Memex エージェント は一時停止中';

  @override
  String get agentBackgroundNeedsAttentionTitle => 'Memex エージェントに対応が必要です';

  @override
  String get agentBackgroundStageIdle => '待機中';

  @override
  String get agentBackgroundStageProcessing => '処理中';

  @override
  String get agentBackgroundStageQueued => 'キュー待ち';

  @override
  String get agentBackgroundStageRetrying => '再試行待ち';

  @override
  String get agentBackgroundStagePaused => '一時停止中';

  @override
  String get agentBackgroundStageCompleted => '完了';

  @override
  String get agentBackgroundStageNeedsAttention => '対応が必要';

  @override
  String get agentBackgroundStageAnalyzingMedia => 'メディアを分析中';

  @override
  String get agentBackgroundStageGeneratingCard => 'カードを生成中';

  @override
  String get agentBackgroundStageUpdatingKnowledge => 'ナレッジを更新中';

  @override
  String get agentBackgroundStagePreparingComment => 'コメントを準備中';

  @override
  String get agentBackgroundStageRoutingFollowUps => '後続処理を振り分け中';

  @override
  String agentBackgroundTaskSummary(
    Object running,
    Object pending,
    Object retrying,
  ) {
    return '実行中 $running、保留中 $pending、再試行 $retrying';
  }

  @override
  String agentBackgroundTaskDetail(Object count) {
    return '$count 件のキュー済みタスクを処理しています。';
  }

  @override
  String get agentBackgroundNoTasks => 'バックグラウンドタスクはありません。';

  @override
  String get agentBackgroundStarting => '処理を開始しています。';

  @override
  String get agentBackgroundCompletedDetail => 'すべてのバックグラウンドタスクが完了しました。';

  @override
  String get agentBackgroundFailedDetail => 'エラーにより処理が停止しました。';

  @override
  String get agentBackgroundPausedDetail => '処理は一時停止中で、後で続行されます。';

  @override
  String get agentBackgroundQueuedDetail => '次の処理ステップを待っています。';

  @override
  String get agentBackgroundRetryingDetail => '現在のステップは自動的に再試行されます。';

  @override
  String get agentBackgroundAnalyzeMediaDetail => '添付ファイルとローカルコンテキストを読み取っています。';

  @override
  String get agentBackgroundGeneratingCardDetail => '記録をタイムラインカードに変換しています。';

  @override
  String get agentBackgroundUpdatingKnowledgeDetail => 'ローカルナレッジとメモリを更新しています。';

  @override
  String get agentBackgroundPreparingCommentDetail => 'アシスタントのフォローアップを準備しています。';

  @override
  String get agentBackgroundRoutingFollowUpsDetail => 'このカードの後続アクションを確認しています。';

  @override
  String agentBackgroundPausedStatus(Object summary) {
    return '一時停止中 - $summary';
  }

  @override
  String agentBackgroundNeedsAttentionStatus(Object summary) {
    return '対応が必要 - $summary';
  }

  @override
  String get settings => '設定';

  @override
  String get languageSettings => '言語';

  @override
  String get languageSettingsDesc => 'アプリの表示言語を変更';

  @override
  String get noPendingActionsToast => '保留中のアクションはありません';

  @override
  String get knowledgeNewDiscovery => 'ナレッジの新しい発見';

  @override
  String discoveredNewInsightsCount(Object count) {
    return '$count 件の新しいインサイトを発見しました';
  }

  @override
  String updatedExistingInsightsCount(Object count) {
    return '$count 件の既存インサイトを更新しました';
  }

  @override
  String get sectionNewInsights => '新しいインサイト';

  @override
  String get sectionUpdatedInsights => '更新されたインサイト';

  @override
  String get unnamedInsight => '名前のないインサイト';

  @override
  String get copiedToClipboard => 'クリップボードにコピーしました';

  @override
  String get copy => 'コピー';

  @override
  String get selectedLocation => '選択した場所';

  @override
  String get confirmLocationName => '場所名を確認';

  @override
  String get confirmLocationNameHint => '名前を編集できます（座標は変わりません）';

  @override
  String get nameLabel => '名前';

  @override
  String get inputPlaceNameHint => '場所名を入力...';

  @override
  String currentCoordinates(Object lat, Object lng) {
    return '座標: $lat, $lng';
  }

  @override
  String get confirmLocation => '場所を確認';

  @override
  String get welcomeToMemex => 'Memex へようこそ';

  @override
  String get createUserIdToStart => 'プロフィールを作成';

  @override
  String get userIdLabel => 'あなたの名前 / ニックネーム';

  @override
  String get userIdHint => '名前またはニックネームを入力';

  @override
  String get pleaseEnterUserId => '名前を入力してください';

  @override
  String get userIdMaxLength => '名前は 50 文字以内にしてください';

  @override
  String get startUsing => '続行';

  @override
  String get userIdTip => '体験をパーソナライズするために使用されます。';

  @override
  String get setupModelConfigTitle => 'AI モデルを設定';

  @override
  String get setupModelConfigSubtitle =>
      'Memex が記録を整理し、画像を分析し、インサイトを生成するには最先端の AI モデルが必要です。接続方法を選択してください。';

  @override
  String get setupModelConfigComplete => '完了して進む';

  @override
  String get aiService => 'Memex モデルサービス';

  @override
  String get aiModelHubTitle => 'AI モデルとサービス';

  @override
  String get aiModelHubSubtitle =>
      'Memex 公式サービスを選ぶか、自分のプロバイダーを接続します。必要なときは高度なモデルルーティングも利用できます。';

  @override
  String get aiSetupCurrentStatusTitle => '現在の設定';

  @override
  String get aiSetupStatusNotConfiguredTitle => 'AI サービスが設定されていません';

  @override
  String get aiSetupStatusNotConfiguredDescription =>
      '記録、メディア、インサイトの AI 整理を有効にするには、接続方法を選択してください。';

  @override
  String get aiSetupStatusMemexTitle => 'MemeX 公式サービスを使用中';

  @override
  String get aiSetupStatusMemexDescription =>
      'Memex は、MemeX アカウントで管理される公式接続と API 認証情報を使用します。';

  @override
  String get aiSetupStatusCustomTitle => 'カスタムプロバイダー設定を使用中';

  @override
  String get aiSetupStatusCustomDescription =>
      'Memex は、設定済みのプロバイダー認証情報とモデルロール選択を使用します。';

  @override
  String get aiSetupChooseConnectionTitle => '接続方法を選択';

  @override
  String get aiSetupChooseConnectionDescription =>
      'Memex に AI モデルへアクセスさせる方法に合った経路から始めてください。';

  @override
  String get aiSetupOfficialRouteDescription =>
      'MemeX にサインインし、プロバイダー、キー、エージェント単位のモデルを選ばずに公式サービスを使用します。';

  @override
  String get aiSetupCustomRouteDescription =>
      '自分のプロバイダー認証情報を追加し、スーパーエージェントが使用するモデルを選び、必要に応じて エージェントごとのモデルを上書きします。';

  @override
  String get aiSetupCustomPageTitle => 'カスタム AI サービス';

  @override
  String get aiSetupCustomPageSubtitle =>
      'まずプロバイダー認証情報を設定し、その後 Memex が使用するモデルを選択します。';

  @override
  String get aiSetupProviderCredentialsTitle => 'プロバイダーと API キー';

  @override
  String get aiSetupProviderCredentialsDescription =>
      'OpenAI、Anthropic、DeepSeek、Gemini、OpenRouter、Ollama、または他の互換プロバイダーを追加・編集します。';

  @override
  String get modelRolesTitle => '主要モデルを選択';

  @override
  String get modelRolesDescription =>
      'スーパーエージェント はテキストと画像入力に 1 つのモデルを使用します。高度な エージェント 上書きは下で引き続き利用できます。';

  @override
  String get textModelRoleTitle => '主要モデル';

  @override
  String get textModelRoleDescription =>
      'スーパーエージェントがテキスト、画像、カード、ナレッジ、インサイト、チャット、コメント、メモリに使用します。';

  @override
  String get modelConnectionsTitle => 'モデルプロバイダーと API キー';

  @override
  String get modelConnectionsDescription =>
      'Memex 公式サービスを接続するか、自分のプロバイダー認証情報を追加します。';

  @override
  String get relatedAiCapabilitiesTitle => '高度な関連機能';

  @override
  String get relatedAiCapabilitiesDescription =>
      'エージェントの割り当て、位置情報プロバイダー、音声文字起こしの動作を細かく調整します。';

  @override
  String get aiSetupServiceCapabilitiesTitle => 'サービス機能';

  @override
  String get aiSetupServiceCapabilitiesDescription =>
      '音声や逆ジオコーディングなど、隣接する AI 搭載機能に Memex が使用するプロバイダーを選択します。';

  @override
  String get aiSetupAdvancedCustomizationTitle => '高度なモデルルーティング';

  @override
  String get aiSetupAdvancedCustomizationDescription =>
      '個別のエージェントに別のプロバイダーやモデル設定を使わせたい上級ユーザー向けです。';

  @override
  String get locationProviderSettings => '位置情報プロバイダー';

  @override
  String get speechProviderSettings => '音声文字起こし';

  @override
  String get advancedAgentModelAssignments => 'エージェントモデル割り当て';

  @override
  String get openAdvancedAgentModelAssignments => '個別エージェントを上書き';

  @override
  String get noConfiguredModelOptions =>
      'モデルロールを選択する前に、プロバイダーまたは API キーを追加してください。';

  @override
  String get modelSlotUpdated => 'モデルロールを更新しました';

  @override
  String get aiServiceMemexRouteTitle => 'Memex 経由で接続';

  @override
  String get aiServiceLongDescription =>
      'Memex はマルチエージェントシステムを使って生活記録、ナレッジノート、社会的コンテキストを整理し、より深いインサイトを発見し、永続メモリを備えた AI 伴走を提供します。あなたのデータはプレーンテキストの Markdown として保存され、データの自由と可搬性を保ちます。';

  @override
  String get aiServiceCustomApiRouteTitle => 'API キーを持っています';

  @override
  String get aiServiceCustomModelDescription =>
      'OpenAI、Anthropic、DeepSeek、Gemini、または他のプロバイダーの API キーをすでに持っている場合は、まずこちらを選択してください。';

  @override
  String get enableAiService => 'Memex と接続';

  @override
  String get aiServiceReadyToast => 'AI 整理が有効になりました';

  @override
  String get aiServiceSettingsDescription =>
      'API キーを持っていない場合は、Memex アカウントを使って主要なモデルサービスへ接続してください。';

  @override
  String get advancedModelConfiguration => 'API キーを設定';

  @override
  String get skipForNow => '今はスキップ';

  @override
  String get clearAuth => '認証をクリア';

  @override
  String get authorizing => '認証中...';

  @override
  String authFailed(Object error) {
    return '認証に失敗しました: $error';
  }

  @override
  String get authorized => '認証済み';

  @override
  String authorizedAs(Object email) {
    return '$email として認証しました';
  }

  @override
  String get authorizedSuccessfully => '認証に成功しました';

  @override
  String get reAuthorize => '再認証';

  @override
  String get authorizeWithOpenAi => 'OpenAI で認証';

  @override
  String get authorizeWithGoogle => 'Google で認証';

  @override
  String get config => '設定';

  @override
  String get calendar => 'カレンダー';

  @override
  String get reminders => 'リマインダー';

  @override
  String get writeToSystemFailed => 'システムへの書き込みに失敗しました';

  @override
  String permissionRequired(Object name) {
    return '$name の権限が必要です';
  }

  @override
  String permissionRationale(Object name) {
    return '作成できるように、設定でアプリに $name へのアクセスを許可してください。';
  }

  @override
  String get goToSettings => '設定へ移動';

  @override
  String get unknownAction => '不明なアクション';

  @override
  String get discoveredCalendarEvent => 'カレンダーイベントが見つかりました';

  @override
  String get discoveredReminder => 'リマインダーが見つかりました';

  @override
  String get addToCalendar => 'カレンダーに追加';

  @override
  String get addToReminders => 'リマインダーに追加';

  @override
  String get systemActionPendingExplanation =>
      'まだ追加されていません。下のボタンをタップすると、権限をリクエストしてデバイスに追加します。';

  @override
  String addedToSuccess(Object target) {
    return '$target に正常に追加しました';
  }

  @override
  String get ignore => '無視';

  @override
  String get confirmDelete => '削除の確認';

  @override
  String get confirmDeleteSessionMessage => 'この会話を削除しますか？この操作は元に戻せません。';

  @override
  String get delete => '削除';

  @override
  String get deleteSuccess => '正常に削除しました';

  @override
  String deleteFailed(Object error) {
    return '削除に失敗しました: $error';
  }

  @override
  String daysAgo(Object count) {
    return '$count 日前';
  }

  @override
  String get chatHistory => 'チャット履歴';

  @override
  String get enterFullScreenTooltip => '全画面表示にする';

  @override
  String get exitFullScreenTooltip => '全画面表示を終了';

  @override
  String get noConversations => '会話はありません';

  @override
  String loadSessionListFailed(Object error) {
    return '会話リストの読み込みに失敗しました: $error';
  }

  @override
  String yesterdayAt(Object time) {
    return '昨日 $time';
  }

  @override
  String get newChat => '新しいチャット';

  @override
  String messageCount(Object count) {
    return '$count 件のメッセージ';
  }

  @override
  String get organize => '整理';

  @override
  String get pkmCategoryProject => 'プロジェクト';

  @override
  String get pkmCategoryProjectSubtitle => '短期・目標・締切';

  @override
  String get pkmCategoryArea => 'エリア';

  @override
  String get pkmCategoryAreaSubtitle => '長期・責任・基準';

  @override
  String get pkmCategoryResource => 'リソース';

  @override
  String get pkmCategoryResourceSubtitle => '関心・着想・蓄積';

  @override
  String get pkmCategoryArchive => 'アーカイブ';

  @override
  String get pkmCategoryArchiveSubtitle => '完了・休止・参照';

  @override
  String get recentChanges => '最近の変更';

  @override
  String get noRecentChangesInThreeDays => '直近 3 日間に変更はありません';

  @override
  String get unpinned => '固定解除済み';

  @override
  String get pinnedStyle => 'スタイル固定済み';

  @override
  String operationFailed(Object error) {
    return '操作に失敗しました: $error';
  }

  @override
  String get refreshingInsightData => 'インサイトデータを更新しています。少し時間がかかる場合があります...';

  @override
  String refreshFailed(Object error) {
    return '更新に失敗しました: $error';
  }

  @override
  String get sortUpdated => '並び順を更新しました';

  @override
  String sortSaveFailed(Object error) {
    return '並び順の保存に失敗しました: $error';
  }

  @override
  String get insightCardDeleted => 'インサイトカードを削除しました';

  @override
  String deleteFailedShort(Object error) {
    return '削除に失敗しました: $error';
  }

  @override
  String get knowledgeInsight => 'ナレッジインサイト';

  @override
  String get completeSort => '並び替えを完了';

  @override
  String get noKnowledgeInsight => 'ナレッジインサイトはありません';

  @override
  String insightProcessingBacklogMessage(Object count) {
    return '$count 件のバックグラウンドタスクがまだ処理中です。';
  }

  @override
  String get insightUnavailableMessage =>
      'このインサイトはまだ生成中、または更新されたばかりです。インサイトを更新してから後でもう一度お試しください。';

  @override
  String get artifactOpen => '開く';

  @override
  String get updating => '更新中...';

  @override
  String get update => '更新';

  @override
  String get enabled => '有効';

  @override
  String get disabled => '無効';

  @override
  String get appLockOn => 'アプリロックが有効です';

  @override
  String get appLockOff => 'アプリロックが無効です';

  @override
  String get enableAppLockFirst => '先にアプリロックを有効にしてください';

  @override
  String get enterFourDigitPassword => '4 桁のパスワードを入力';

  @override
  String get passwordSetAndLockOn => 'パスワードを設定し、アプリロックを有効にしました';

  @override
  String get appLockSettings => 'アプリロック設定';

  @override
  String get enableAppLock => 'アプリロックを有効にする';

  @override
  String get enableAppLockSubtitle => 'アプリ起動時にパスワードを要求';

  @override
  String get enableBiometrics => '生体認証を有効にする';

  @override
  String get biometricsSubtitle => 'Face ID または Touch ID でロック解除';

  @override
  String get changePassword => 'パスワードを変更';

  @override
  String get setFourDigitPassword => '4 桁のパスワードを設定';

  @override
  String get reenterPasswordToConfirm => '確認のためパスワードを再入力';

  @override
  String get passwordMismatch => 'パスワードが一致しません。もう一度お試しください。';

  @override
  String confirmDeleteCharacter(Object name) {
    return 'キャラクター「$name」を削除しますか？この操作は元に戻せません。';
  }

  @override
  String get configureAiCharacter => 'AI キャラクターを設定';

  @override
  String get addCharacter => 'キャラクターを追加';

  @override
  String get addCharacterSubtitle =>
      'インサイトチームに参加する AI キャラクターを選択します。彼らは異なる角度からあなたの生活データを分析します。';

  @override
  String get noCharacters => 'キャラクターはいません';

  @override
  String loadCharacterFailed(Object error) {
    return 'キャラクターの読み込みに失敗しました: $error';
  }

  @override
  String get noTags => 'タグなし';

  @override
  String get createSuccess => '正常に作成しました';

  @override
  String get updateSuccess => '正常に更新しました';

  @override
  String saveFailed(Object error) {
    return '保存に失敗しました: $error';
  }

  @override
  String get newCharacter => '新しいキャラクター';

  @override
  String get editCharacter => 'キャラクターを編集';

  @override
  String get save => '保存';

  @override
  String get characterName => 'キャラクター名';

  @override
  String get characterNameHint => 'キャラクターに名前を付けてください';

  @override
  String get pleaseEnterCharacterName => 'キャラクター名を入力してください';

  @override
  String get tagsLabel => 'タグ';

  @override
  String get tagsHint => '例: 知恵, 承認, マクロ\n複数のタグはカンマで区切ってください';

  @override
  String get characterPersonaLabel => 'キャラクターペルソナ';

  @override
  String get characterPersonaHint =>
      'ペルソナ、スタイルガイド、会話例、ナレッジフィルターなどを含めてください。\nセクション見出しには ## を使用してください。';

  @override
  String get pleaseEnterCharacterPersona => 'キャラクターペルソナを入力してください';

  @override
  String permissionRequestError(Object error) {
    return '権限リクエストエラー: $error';
  }

  @override
  String get permissionRequiredTitle => '権限が必要です';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'この権限を恒久的に拒否したか、システム側で要求されています。システム設定で有効にしてください。';

  @override
  String get getting => '取得中...';

  @override
  String get unauthorized => '未認証';

  @override
  String get authorizedGoToSettings => '認証済みです。変更するにはシステム設定へ移動してください。';

  @override
  String get location => '位置情報';

  @override
  String get locationPermissionReason => '場所の記録と位置関連機能のため';

  @override
  String get photos => '写真';

  @override
  String get photosPermissionReason => '写真の選択、生成画像の保存などのため';

  @override
  String get camera => 'カメラ';

  @override
  String get cameraPermissionReason => '写真や動画の撮影のため';

  @override
  String get microphone => 'マイク';

  @override
  String get microphonePermissionReason => '音声認識、録音などのため';

  @override
  String get calendarPermissionReason => '予定の記録とカレンダーイベントの読み取りのため';

  @override
  String get remindersPermissionReason => 'リマインダーの記録と読み取りのため';

  @override
  String get fitnessAndMotion => 'フィットネスとモーション';

  @override
  String get fitnessPermissionReason => '健康データとモーションデータの記録のため';

  @override
  String get notification => '通知';

  @override
  String get notificationPermissionReason => '予定や重要なリマインダーを送信するため';

  @override
  String get memexAgentNotificationPermissionTitle =>
      'Memex Agent をバックグラウンドで実行する';

  @override
  String get memexAgentNotificationPermissionMessage =>
      'Memex Agent はデバイス上でローカルに動作します。通知を許可すると、Memex は進行状況を表示し、アプリを離れたり画面をオフにした後も処理を続けられます。通知を許可しない場合は、タスクが完了するまで Memex を前面に表示してください。';

  @override
  String get loadDetailFailedRetryShort => '詳細の読み込みに失敗しました。後でもう一度お試しください。';

  @override
  String get total => '合計';

  @override
  String get estimatedCost => '推定コスト';

  @override
  String get byAgent => 'エージェント別';

  @override
  String get timeUpdated => '更新時刻';

  @override
  String updateFailed(Object error) {
    return '更新に失敗しました: $error';
  }

  @override
  String get locationUpdated => '位置情報を更新しました';

  @override
  String get confirmDeleteCardMessage => 'このカードを削除しますか？この操作は元に戻せません。';

  @override
  String get cardDetailNotFound => 'カード詳細が見つかりません';

  @override
  String get saySomething => '何か入力してください...';

  @override
  String get relatedMemories => '関連メモリ';

  @override
  String get viewMore => 'さらに表示';

  @override
  String get relatedRecords => '関連記録';

  @override
  String get reply => '返信';

  @override
  String get replySent => '返信を送信しました';

  @override
  String get insightTemplateGalleryTitle => 'インサイトカードテンプレート';

  @override
  String get timelineTemplateGalleryTitle => 'タイムラインカードテンプレート';

  @override
  String get categoryTextual => 'テキスト';

  @override
  String get timelineFilterAll => 'すべて';

  @override
  String get insights => 'インサイト';

  @override
  String get memoryTitle => 'メモリ';

  @override
  String get longTermProfile => '長期プロフィール';

  @override
  String get recentBuffer => '最近のバッファ';

  @override
  String errorLoadingMemory(Object error) {
    return 'メモリの読み込みエラー: $error';
  }

  @override
  String get agentConfiguration => 'エージェント設定';

  @override
  String get resetToDefaults => 'デフォルトにリセット';

  @override
  String get resetAllAgentConfigurationsTitle => 'すべてのエージェント設定をリセット';

  @override
  String get resetAllAgentConfigurationsMessage =>
      'すべてのエージェント設定をデフォルト値にリセットしますか？この操作は元に戻せません。';

  @override
  String get resetButton => 'リセット';

  @override
  String loadDataFailed(Object error) {
    return 'データの読み込みに失敗しました: $error';
  }

  @override
  String saveConfigFailed(Object error) {
    return '設定の保存に失敗しました: $error';
  }

  @override
  String get selectLlmClient => 'LLM クライアントを選択:';

  @override
  String get agentConfigurationsReset => 'エージェント設定をリセットしました';

  @override
  String resetFailed(Object error) {
    return 'リセットに失敗しました: $error';
  }

  @override
  String get modelConfiguration => 'モデル設定';

  @override
  String get resetAllConfigurationsTitle => 'すべての設定をリセット';

  @override
  String get resetAllModelConfigurationsMessage =>
      'すべてのモデル設定をデフォルト値にリセットしますか？この操作は元に戻せません。';

  @override
  String get modelConfigurationsReset => 'モデル設定をリセットしました';

  @override
  String get cannotDeleteDefaultConfiguration => 'デフォルト設定は削除できません';

  @override
  String get cannotDeleteConfigurationTitle => '設定を削除できません';

  @override
  String configUsedByAgentsMessage(Object agentList) {
    return 'この設定は現在、次の エージェントに使用されています:\n\n$agentList\n\n削除する前に、これらの エージェントを再割り当てしてください。';
  }

  @override
  String get ok => 'OK';

  @override
  String get deleteConfigurationTitle => '設定を削除';

  @override
  String confirmDeleteConfigMessage(Object key) {
    return '「$key」を削除してもよろしいですか？';
  }

  @override
  String get defaultLabel => 'デフォルト';

  @override
  String get setAsDefault => 'デフォルトに設定';

  @override
  String get invalidJsonInExtraField => 'Extra フィールドの JSON が無効です';

  @override
  String get keyAlreadyExists => 'キーはすでに存在します';

  @override
  String get resetConfigurationTitle => '設定をリセット';

  @override
  String get resetConfigurationMessage => 'この設定を初期デフォルト値にリセットしますか？現在の変更は失われます。';

  @override
  String get configurationResetPressSave => '設定をリセットしました。適用するには保存を押してください。';

  @override
  String get addConfiguration => '設定を追加';

  @override
  String get editConfiguration => '設定を編集';

  @override
  String get duplicateConfiguration => '設定を複製';

  @override
  String get duplicate => '複製';

  @override
  String get keyIdLabel => '設定 ID';

  @override
  String get keyIdHelper => 'deepseek や work-gpt など、この設定に名前を付けてください。';

  @override
  String get required => '必須';

  @override
  String get clientLabel => 'モデルプロバイダー';

  @override
  String get providerGroupOpenAi => 'OpenAI';

  @override
  String get providerGroupAnthropic => 'Anthropic';

  @override
  String get providerGroupGoogle => 'Google';

  @override
  String get providerGroupOthers => '人気';

  @override
  String get providerOpenAiApiKey => 'API キー';

  @override
  String get providerOpenAiResponses => 'API キー（Responses）';

  @override
  String get providerChatGptOauth => 'ChatGPT Pro/Plus';

  @override
  String get providerClaudeApiKey => 'API キー';

  @override
  String get providerBedrockSecret => 'Bedrock Secret';

  @override
  String get providerGemini => 'Gemini';

  @override
  String get providerGeminiOauth => 'Gemini（Google OAuth）';

  @override
  String get providerKimi => 'Kimi（Moonshot）';

  @override
  String get providerQwen => 'Aliyun';

  @override
  String get providerSeed => 'Volcengine';

  @override
  String get providerZhipu => 'Zhipu GLM';

  @override
  String get providerDeepSeek => 'DeepSeek';

  @override
  String get providerMinimax => 'MiniMax';

  @override
  String get providerOpenRouter => 'OpenRouter';

  @override
  String get providerOllama => 'Ollama（ローカル）';

  @override
  String get providerMimo => 'Xiaomi MIMO';

  @override
  String get providerMemex => 'Memex プロキシサービス';

  @override
  String get memexSignIn => 'サインイン';

  @override
  String get memexCreateAccount => 'アカウント作成';

  @override
  String get memexUsername => 'ユーザー名';

  @override
  String get memexPassword => 'パスワード';

  @override
  String get memexCreateAccountLink => 'アカウントを作成';

  @override
  String get memexSignInLink => '代わりにサインイン';

  @override
  String get memexTopUp => 'Memex AI を使い始めるためにチャージ';

  @override
  String get memexTopUpSuccess => 'チャージが完了しました！';

  @override
  String get memexFillAllFields => 'すべての項目を入力してください';

  @override
  String get memexUsernameTooShort => 'ユーザー名は 6 文字以上にしてください';

  @override
  String get memexAuthFailed => '認証に失敗しました';

  @override
  String get memexPaymentFailed => '支払いの作成に失敗しました';

  @override
  String get memexLogout => 'ログアウト';

  @override
  String get memexTopUpButton => 'チャージ';

  @override
  String get memexTopUpChooseAmount => '金額を選択';

  @override
  String memexTopUpEstimatedRecords(Object range) {
    return '約 $range 件の記録';
  }

  @override
  String get memexTopUpPlanStarter => 'スターター';

  @override
  String get memexTopUpPlanEveryday => '日常利用';

  @override
  String get memexTopUpPlanHighVolume => '大容量';

  @override
  String get memexTopUpPlanCustom => 'カスタムクレジット';

  @override
  String get memexTopUpPlanStarterSubtitle => 'Memex AI を試すのに適しています';

  @override
  String get memexTopUpPlanEverydaySubtitle => '普段の整理に適しています';

  @override
  String get memexTopUpPlanHighVolumeSubtitle => '大量処理に適しています';

  @override
  String get memexTopUpPlanCustomSubtitle => 'USD 1-10,000 を入力';

  @override
  String get memexTopUpCustomEstimate => '見積もりは入力した金額に基づきます';

  @override
  String get memexCustomAmount => 'カスタム金額';

  @override
  String get memexViewHistory => '使用履歴';

  @override
  String memexBalanceLabel(Object amount) {
    return '残高: $amount';
  }

  @override
  String get memexConfirmPassword => 'パスワードを確認';

  @override
  String get memexPasswordMismatch => 'パスワードが一致しません';

  @override
  String memexPayAmount(Object amount) {
    return '$amount をチャージ';
  }

  @override
  String get modelIdLabel => 'モデル';

  @override
  String get modelIdHelper => '例: gemini-3.1-pro-preview、gpt-4o';

  @override
  String get fetchingModels => 'モデルを取得中...';

  @override
  String get fetchModelsButton => 'モデルを取得';

  @override
  String get enterApiKeyFirst => 'モデルを取得するには、まず API キーを入力してください';

  @override
  String get apiKeyLabel => 'API キー';

  @override
  String get baseUrlLabel => 'API エンドポイント';

  @override
  String get advancedSettings => '詳細設定';

  @override
  String get testConnectionSuccess => '接続に成功しました';

  @override
  String get testConnectionFailed => '接続に失敗しました';

  @override
  String get testTypeText => 'テキスト';

  @override
  String get testTypeVision => 'ビジョン';

  @override
  String get testButton => 'テスト';

  @override
  String get testing => 'テスト中...';

  @override
  String get proxyUrlOptional => 'プロキシ URL（任意）';

  @override
  String get proxyUrlHelper => '例: http://127.0.0.1:7890';

  @override
  String get temperatureLabel => 'Temperature';

  @override
  String get topPLabel => 'Top P';

  @override
  String get maxTokensLabel => 'Max Tokens';

  @override
  String get extraParamsJson => '追加パラメータ（JSON）';

  @override
  String get invalidJson => '無効な JSON';

  @override
  String get warning => '設定が未完了です';

  @override
  String get invalidConfigurationWarning =>
      'この設定はまだ完全ではありません（例: API キーまたはモデル ID が未入力）。保存して後から設定することもできます。続行しますか？';

  @override
  String invalidModelConfigDetailed(Object agentId, Object configKey) {
    return 'AI エージェント「$agentId」を動作させるには、有効なモデル設定（キー:「$configKey」）が必要です。モデル設定を確認してください。';
  }

  @override
  String get discardChangesTitle => 'このページを離れますか？';

  @override
  String get discardChangesMessage => '変更を加えた場合は、離れる前に保存してください。';

  @override
  String get discardButton => '破棄';

  @override
  String get chooseLanguage => '言語を選択';

  @override
  String get chooseAvatar => 'アバターを選択';

  @override
  String get configureNow => '今すぐ設定';

  @override
  String get modelNotConfiguredBanner =>
      'AI モデルがまだ設定されていません。設定するとすべての機能を利用できます。';

  @override
  String get modelNotConfiguredSubmitHint => '公開する前に AI モデルを設定してください';

  @override
  String get processingStatus => '処理中';

  @override
  String get failedStatus => '失敗';

  @override
  String get failureReason => '失敗理由';

  @override
  String get unknownError => '不明なエラーが発生しました';

  @override
  String get enableFitness => 'フィットネスを有効にする';

  @override
  String get fitnessBannerMessage =>
      '健康とアクティビティデータを追跡するため、フィットネスアクセスを許可してください。';

  @override
  String get fitnessDismissTitle => 'フィットネスアクセスをスキップしますか？';

  @override
  String get fitnessDismissMessage =>
      'フィットネス権限がないと、インサイトや自動記録のために健康データを自動収集できません。';

  @override
  String get skipAnyway => 'それでもスキップ';

  @override
  String get proModelHint => 'このモデルを使用するには ChatGPT Pro/Plus サブスクリプションが必要です。';

  @override
  String get searchKnowledgeBase => 'ナレッジベースを検索...';

  @override
  String get searchKnowledgeHint => 'ファイル名または内容を検索するキーワードを入力';

  @override
  String noSearchResults(Object query) {
    return '「$query」の結果は見つかりませんでした';
  }

  @override
  String get onlyMarkdownPreview => 'Markdown プレビューのみ対応しています';

  @override
  String get backupAndRestore => 'バックアップと復元';

  @override
  String get createBackup => 'バックアップを作成';

  @override
  String get restoreBackup => 'バックアップを復元';

  @override
  String get backupDescription =>
      'すべてのデータ（カード、ナレッジベース、インサイト、設定）を .memex ファイルにまとめます。共有シートから iCloud Drive、Google Drive、または任意の場所に保存できます。';

  @override
  String get restoreDescription =>
      '.memex バックアップファイルを選択してすべてのデータを復元します。現在のデータは上書きされます。';

  @override
  String get selectBackupFile => 'バックアップファイルを選択';

  @override
  String get estimatedSize => '推定サイズ';

  @override
  String get backupComplete => 'バックアップを作成しました';

  @override
  String backupFailed(Object error) {
    return 'バックアップに失敗しました: $error';
  }

  @override
  String get confirmRestore => '復元の確認';

  @override
  String get confirmRestoreMessage =>
      '復元すると、カード、ナレッジベース、インサイト、設定を含む現在のすべてのデータが上書きされます。この操作は元に戻せません。続行しますか？';

  @override
  String get restoreComplete => '復元が完了しました';

  @override
  String get restoreRestartHint => 'データを復元しました。すべての変更を反映するにはアプリを再起動してください。';

  @override
  String restoreFailed(Object error) {
    return '復元に失敗しました: $error';
  }

  @override
  String get invalidBackupFile => '無効なバックアップファイルです。.memex ファイルを選択してください。';

  @override
  String get automaticBackup => '自動バックアップ';

  @override
  String get autoBackupDescription =>
      '有効にすると、Memex は起動後またはフォアグラウンドに戻ったときに、1 日最大 1 回ローカルスナップショットを作成します。';

  @override
  String get backupSensitiveSettingsHint =>
      'バックアップには設定とモデルプロバイダーのキーが含まれます。信頼できる場所に保管してください。';

  @override
  String get backupLocation => '場所';

  @override
  String get backupLocationDetails => '場所の詳細';

  @override
  String get backupLocationSummary => 'アプリ内に表示';

  @override
  String get backupLocationFullPath => '完全パス';

  @override
  String get backupLocationUri => 'フォルダーアクセス URI';

  @override
  String get copyBackupLocationPath => 'パスをコピー';

  @override
  String get backupLocationCopied => 'バックアップ場所をコピーしました';

  @override
  String androidBackupLocationSelected(Object folderName) {
    return '選択したフォルダー: $folderName';
  }

  @override
  String get iosICloudBackupLocation => 'iCloud Drive > Memex > Backups';

  @override
  String get iosAppDocumentsBackupLocation =>
      'ファイル > この iPhone 内 > Memex > Backups';

  @override
  String get autoBackupStatus => '状態';

  @override
  String get noAutoBackupYet => '自動バックアップはまだありません';

  @override
  String lastBackupAt(Object time) {
    return '前回のバックアップ: $time';
  }

  @override
  String get autoBackupRetention => '保持期間';

  @override
  String autoBackupRetentionDays(Object days) {
    return '$days 日';
  }

  @override
  String get autoBackupRetentionForever => '無期限に保持';

  @override
  String get autoBackupMaxSize => '保存容量上限';

  @override
  String autoBackupRetentionLimitHint(Object size) {
    return '自動クリーンアップにより、自動スナップショットは $size 未満に保たれます。安全スナップショットと手動エクスポートは別途保持されます。';
  }

  @override
  String get createSnapshotNow => '今すぐバックアップ';

  @override
  String get backupLocationMenu => '場所を変更';

  @override
  String get defaultBackupLocation => 'デフォルトのバックアップフォルダー';

  @override
  String get defaultBackupLocationAndroidDesc =>
      'Memex のアプリ専用外部ファイルフォルダーを使用します。ストレージ権限は不要です。';

  @override
  String get chooseBackupLocation => 'バックアップフォルダーを選択';

  @override
  String get chooseBackupLocationAndroidDesc =>
      'Android のシステムピッカーでフォルダーを選び、Memex に永続アクセスを許可します。';

  @override
  String get storedBackups => '保存済みバックアップ';

  @override
  String get noStoredBackups => '最初のスナップショット後に自動バックアップがここに表示されます。';

  @override
  String get backupTypeAutoSnapshot => '自動スナップショット';

  @override
  String get backupTypeSafetySnapshot => '安全スナップショット';

  @override
  String get backupTypeManualBackup => '手動バックアップ';

  @override
  String get refresh => '更新';

  @override
  String get restoreThisBackup => 'このバックアップを復元';

  @override
  String get deleteThisBackup => 'このバックアップを削除';

  @override
  String get confirmDeleteBackup => 'バックアップを削除しますか？';

  @override
  String confirmDeleteBackupMessage(Object fileName) {
    return '$fileName を削除しますか？保存済みバックアップファイルが削除され、元に戻せません。';
  }

  @override
  String backupDeleted(Object fileName) {
    return 'バックアップを削除しました: $fileName';
  }

  @override
  String backupDeleteFailed(Object error) {
    return 'バックアップを削除できませんでした: $error';
  }

  @override
  String get creatingSafetySnapshot => '安全スナップショットを作成中...';

  @override
  String autoBackupCreated(Object fileName) {
    return 'スナップショットを作成しました: $fileName';
  }

  @override
  String backupLocationFailed(Object error) {
    return 'バックアップ場所を更新できませんでした: $error';
  }

  @override
  String get backupImportCreatedAt => '作成日時';

  @override
  String get backupImportSourceVersion => 'ソースバージョン';

  @override
  String get backupImportFlavor => 'ビルド';

  @override
  String get backupLegacyFormat => 'レガシーバックアップ（manifest なし）';

  @override
  String get restoreInProgress => 'バックアップを復元中...';

  @override
  String get dataStorage => 'データ保存先';

  @override
  String get dataStorageDescriptionAndroid =>
      'ワークスペースを保存するカスタムフォルダーを選択します。アプリを再インストールしてもデータは保持されます。';

  @override
  String get dataStorageDescriptionIOS =>
      'iCloud をオンにすると、ワークスペースをデバイス間で同期し、アプリ再インストール後もデータを保持できます。';

  @override
  String get storageLocationApp => 'アプリ内ストレージ';

  @override
  String get storageLocationAppDesc => 'データはアプリ内に保存され、アンインストール時に削除されます。';

  @override
  String get storageLocationCustom => 'デバイスストレージ（カスタムフォルダー）';

  @override
  String get storageLocationCustomDesc =>
      '選択したフォルダーにデータを保存します。フォルダーが残っていれば再インストール後もデータは保持されます。';

  @override
  String get storageLocationICloud => 'iCloud に保存';

  @override
  String get storageLocationICloudDesc =>
      'Apple デバイス間でワークスペースを同期します。再インストール後もデータは残ります。';

  @override
  String storageLocationCurrent(Object location) {
    return '現在: $location';
  }

  @override
  String get icloudRequiresCapability =>
      'iCloud ストレージを使用するには、iCloud にサインインして iCloud Drive をオンにしてください。';

  @override
  String get loadingFromICloud => 'iCloud からデータを復元中…';

  @override
  String get switchingToICloud => 'iCloud ストレージに切り替え中…';

  @override
  String get switchingStorage => 'ストレージを切り替え中…';

  @override
  String get customFolderAccessDenied =>
      'このフォルダーを読み書きできません。ストレージ権限を許可するか、別の場所を選択してください。';

  @override
  String get configured => '設定済み';

  @override
  String get apiKeyNotSet => 'API キーが未設定です — タップして設定';

  @override
  String get bottomNavTimeline => 'タイムライン';

  @override
  String get bottomNavLibrary => 'ライブラリ';

  @override
  String get aiGeneratedLabel => 'AI 生成';

  @override
  String sourceTraceWithCount(Object count) {
    return 'ソース追跡（$count）';
  }

  @override
  String get deleteAccount => 'アカウントを削除';

  @override
  String get deleteAccountDesc => 'すべてのローカルデータを完全に削除し、アプリをリセットします。';

  @override
  String get deleteAccountConfirmTitle => 'アカウントを削除しますか？';

  @override
  String get deleteAccountConfirmMessage =>
      'タイムラインカード、ナレッジベース、録音、設定を含むすべてのデータが完全に削除されます。この操作は元に戻せません。';

  @override
  String deleteAccountTypeName(Object name) {
    return '確認するには「$name」と入力してください';
  }

  @override
  String get deleteAccountTypeHint => '確認のためユーザー名を入力';

  @override
  String get llmConsentTitle => 'データ共有への同意';

  @override
  String llmConsentMessage(Object provider) {
    return 'AI 機能を有効にするため、Memex は処理のためにあなたのデータを $provider へ送信する必要があります。これには次が含まれます:\n\n• 入力したテキスト（メモ、音声文字起こし）\n• 写真のメタデータと抽出されたテキスト（OCR）\n• 健康とフィットネスの要約\n• タイムラインカードの内容\n\nデータはあなたのデバイスから $provider へ直接送信されます。Memex が他のサーバーでデータを保存または中継することはありません。\n\n$provider がデータをどのように扱うかについては、同社のプライバシーポリシーを確認してください。\n\nAI 処理のためにデータを $provider へ送信することに同意しますか？';
  }

  @override
  String get llmConsentAgree => '同意する';

  @override
  String get llmConsentDecline => '拒否';

  @override
  String get customAgents => 'カスタムエージェント';

  @override
  String get noCustomAgents => 'カスタムエージェント は設定されていません。';

  @override
  String get deleteAgent => 'エージェントを削除';

  @override
  String deleteAgentConfirm(Object name) {
    return 'カスタムエージェント「$name」を削除しますか？';
  }

  @override
  String get deleted => '削除しました';

  @override
  String get saved => '保存しました';

  @override
  String get newAgent => '新しいエージェント';

  @override
  String get editAgent => 'エージェントを編集';

  @override
  String get agentName => 'エージェント名';

  @override
  String get agentNameHint => 'my-custom-agent';

  @override
  String get agentNameRequired => '必須';

  @override
  String get agentNameInvalid => '英字、数字、ハイフンのみ使用できます';

  @override
  String get agentNameExists => '名前はすでに存在します';

  @override
  String get hostAgentType => 'ホストエージェントタイプ';

  @override
  String get skillDirectory => 'スキル ディレクトリ';

  @override
  String get skillDirInvalid => '相対パスである必要があります（先頭の / や .. は不可）';

  @override
  String get workingDirectory => '作業ディレクトリ（任意）';

  @override
  String get workingDirectoryHint => '空欄の場合はワークスペースのデフォルトを使用';

  @override
  String get llmConfig => 'LLM 設定';

  @override
  String get eventType => 'イベントタイプ';

  @override
  String get executionMode => '実行モード';

  @override
  String get executionModeAsync => '非同期';

  @override
  String get executionModeSync => '同期';

  @override
  String get dependsOn => '依存先';

  @override
  String get dependsOnHint => '依存項目を選択';

  @override
  String get priority => '優先度';

  @override
  String get maxRetries => '最大再試行回数';

  @override
  String get systemPromptLabel => 'システムプロンプト（任意）';

  @override
  String get systemPromptHint => 'ホストエージェントのプロンプトに追加される指示';

  @override
  String get eventSerializer => 'イベントシリアライザー';

  @override
  String get eventSerializerDefault => 'デフォルト（XML）';

  @override
  String get enabledLabel => '有効';

  @override
  String get skillsManagement => 'スキル 管理';

  @override
  String get skillsManagementEmpty => 'スキル はまだありません';

  @override
  String get downloadSkill => 'スキル をダウンロード';

  @override
  String get downloadFile => 'ファイルをダウンロード';

  @override
  String get downloading => 'ダウンロード中...';

  @override
  String get downloadSuccess => 'スキル を正常にダウンロードしました';

  @override
  String downloadFailed(Object error) {
    return 'ダウンロードに失敗しました: $error';
  }

  @override
  String get deleteConfirm => '削除の確認';

  @override
  String deleteConfirmMessage(String name) {
    return '「$name」を削除してもよろしいですか？';
  }

  @override
  String get invalidUrl => '有効な URL を入力してください';

  @override
  String get urlHint => 'https://example.com/skill.zip';

  @override
  String get newFolder => '新しいフォルダー';

  @override
  String get newFile => '新しいファイル';

  @override
  String get folderName => 'フォルダー名';

  @override
  String get fileName => 'ファイル名';

  @override
  String get nameRequired => '名前は必須です';

  @override
  String get nameInvalid => '名前に / または .. を含めることはできません';

  @override
  String createFailed(Object error) {
    return '作成に失敗しました: $error';
  }

  @override
  String get fileContent => 'ファイル内容';

  @override
  String get saveSuccess => '正常に保存しました';

  @override
  String downloadToCurrentDir(String dir) {
    return 'zip は現在のディレクトリに展開されます: $dir';
  }

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get privacyPolicyDesc => 'Memex がデータをどのように扱うか';

  @override
  String get llmAuthError => 'API 認証に失敗しました。設定で LLM 設定を確認してください。';

  @override
  String get llmBadRequestError =>
      'リクエストは LLM プロバイダーに拒否されました。入力形式が現在のモデルでサポートされていない可能性があります。';

  @override
  String get llmRateLimitError => 'API レート制限を超えました。後でもう一度お試しください。';

  @override
  String get llmServerError => 'LLM サービスは一時的に利用できません。後でもう一度お試しください。';

  @override
  String get llmNetworkError => 'ネットワーク接続に失敗しました。インターネット接続を確認してください。';

  @override
  String get llmUnknownError => 'コンテンツの処理中に予期しないエラーが発生しました。';

  @override
  String get llmErrorDialogTitle => '処理に失敗しました';

  @override
  String get goToModelConfig => '設定へ移動';

  @override
  String get speechModelDownloadTitle => '音声モデルをダウンロード';

  @override
  String speechModelDownloadDesc(Object sizeMB) {
    return '一度だけモデルのダウンロード（約 ${sizeMB}MB）が必要です。\n\nダウンロード後、文字起こしは完全にデバイス上で実行されます。';
  }

  @override
  String get speechModelStartDownload => 'ダウンロード開始';

  @override
  String get speechModelChooseSource => 'ダウンロード元を選択:';

  @override
  String get speechModelChinaMirror => '🇨🇳 中国ミラー（中国国内で高速）';

  @override
  String get speechModelGithub => '🌐 GitHub（グローバル）';

  @override
  String get speechModelDownloading => 'モデルをダウンロード中...';

  @override
  String get speechModelConnecting => '接続中...';

  @override
  String get deleteSpeechModel => '音声モデルを削除';

  @override
  String get confirmDeleteSpeechModelMessage =>
      'ダウンロード済みのローカル音声認識モデルファイルを削除しますか？次にローカル音声文字起こしを使うときに再度ダウンロードされます。';

  @override
  String get speechModelDeletedSuccess => '音声モデルファイルを削除しました';

  @override
  String get speechModelNotDownloaded => 'ダウンロード済み音声モデルファイルが見つかりません';

  @override
  String speechModelDeleteFailed(Object error) {
    return '音声モデルファイルの削除に失敗しました: $error';
  }

  @override
  String get speechTranscribing => '認識中...';

  @override
  String get speechNoResult => '音声が検出されませんでした';

  @override
  String get useLocalSpeechToTextTitle => 'ローカル音声文字起こしを使用';

  @override
  String get useLocalSpeechToTextDesc =>
      '有効にすると、音声は送信前にデバイス上で文字起こしされます。音声入力に対応していないモデルに便利です。無効にすると、元の音声が直接モデルへ送信されます。';

  @override
  String get pendingAiProcessingHint => '処理する AI モデルを設定';

  @override
  String get demoWelcome => 'Memex へようこそ！\nAI があなたの記録に何ができるか、簡単に見てみましょう。';

  @override
  String get demoTapAdd => 'ここをタップして最初の記録を作成';

  @override
  String get demoTapSend => 'タップして最初の記録を送信';

  @override
  String get demoTapCard => 'AI が記録をどう整理したかを見るにはタップ';

  @override
  String get demoDetailHint => 'これは AI が整理した記録の詳細です。自由に確認してから戻り、ツアーを続けてください。';

  @override
  String get demoTapInsight => 'AI 生成インサイトを見るにはタップ';

  @override
  String get demoTapInsightUpdate => '記録からインサイトを生成するにはタップ';

  @override
  String get demoTapKnowledge => '自動整理されたナレッジファイルを確認';

  @override
  String get demoDone => '生活の記録を始めましょう。';

  @override
  String get demoStartTour => 'ツアーを開始';

  @override
  String get demoGetStarted => '始める';

  @override
  String get demoSkip => 'スキップ';

  @override
  String get demoPrefillText => 'こんにちは Memex！これは私の最初の記録です 🎉';

  @override
  String get visionBadge => 'ビジョン';

  @override
  String get notMultimodalHint =>
      'Memex はメディア分析にマルチモーダルモデルの能力を利用します。記録に画像が含まれる場合は、設定したモデルが画像入力に対応していることを確認してください。';

  @override
  String get defaultModelPrefix => 'デフォルト';

  @override
  String get recommendedBadge => 'おすすめ';

  @override
  String get readOnlyBadge => 'CHAT';

  @override
  String get switchCompanion => 'コンパニオンを切り替え';

  @override
  String get personaChatInputHint => 'メッセージを入力...';

  @override
  String get today => '今日';

  @override
  String get tomorrow => '明日';

  @override
  String get yesterday => '昨日';

  @override
  String get showInsightTextTitle => 'Memex インサイトコメントを表示';

  @override
  String get showInsightTextDesc =>
      'カード詳細のコメント欄で、Memex インサイトを固定コメントとして表示するかどうか。';

  @override
  String get enableCharacterCommentTitle => 'キャラクター自動コメント';

  @override
  String get enableCharacterCommentDesc => 'キャラクターが新しい記録に自動でコメントします。';

  @override
  String get maxCommentCharactersTitle => 'コメントする最大キャラクター数';

  @override
  String get maxCommentCharactersDesc => '各記録にコメントできるキャラクター数。';

  @override
  String replyTo(String name) {
    return '$name に返信';
  }

  @override
  String get cdnSignalsComments => '新しい返信を受信しました';

  @override
  String get cdnSignalsInsight => '新しいインサイトが生成されました';

  @override
  String get cdnSignalsBoth => '新しい返信とインサイトがあります';

  @override
  String get untitledCard => '無題のカード';

  @override
  String get locationContextTitle => '位置コンテキスト';

  @override
  String get locationContextDescription => 'エージェントチャット用の現在の都市と近隣コンテキスト';

  @override
  String get locationContextAttachTitle => '現在地をチャットに添付';

  @override
  String get locationContextAttachDesc =>
      'デバイス GPS と逆ジオコーディングを使って、都市、地区、近隣のコンテキストを エージェントに提供します。';

  @override
  String get reverseGeocodingProvider => '逆ジオコーディングプロバイダー';

  @override
  String get amapProviderName => 'Amap';

  @override
  String get amapApiKey => 'Amap API キー';

  @override
  String get amapGcj02Note =>
      'Amap は GCJ-02 座標を使用します。デバイス GPS は逆ジオコーディング前に変換されます。';

  @override
  String get contextGranularity => 'コンテキストの粒度';

  @override
  String get granularityCity => '都市';

  @override
  String get granularityDistrict => '地区';

  @override
  String get granularityNeighborhood => '近隣';

  @override
  String get granularityStreet => '通り';

  @override
  String get granularityFullAddress => '完全住所候補';

  @override
  String get locationFreshness => '位置情報の鮮度';

  @override
  String minutesShort(int minutes) {
    return '$minutes 分';
  }

  @override
  String get oneHour => '1 時間';

  @override
  String get testCurrentLocation => '現在地をテスト';

  @override
  String locationTestFailed(String error) {
    return '失敗: $error';
  }

  @override
  String get locationDebugGps => 'GPS';

  @override
  String get locationDebugReverseGeocode => '逆ジオコーディング';

  @override
  String get locationDebugProvider => 'プロバイダー';

  @override
  String get locationDebugAgentContext => 'エージェントコンテキスト';

  @override
  String get locationDebugSource => 'ソース';

  @override
  String get locationDebugAddressSummary => '住所サマリー';

  @override
  String get locationDebugFullAddress => '完全住所';

  @override
  String get locationDebugCoordinates => '座標';

  @override
  String get locationDebugAccuracy => '精度';

  @override
  String get locationDebugReason => '理由';

  @override
  String get locationDebugOk => 'OK';

  @override
  String get locationDebugUnavailable => '利用不可';

  @override
  String get locationDebugInjected => '注入済み';

  @override
  String get locationDebugNotInjected => '未注入';

  @override
  String get locationStatusUpdatedAt => '更新済み';

  @override
  String get locationStatusSuccessTitle => '現在地の準備ができました';

  @override
  String get locationStatusSuccessBody =>
      '位置コンテキストが関連する場合、Memex はこの位置サマリーを添付できます。';

  @override
  String get locationStatusApproximateTitle => 'おおよその位置のみ';

  @override
  String get locationStatusApproximateBody =>
      '精度は都市またはエリア程度に見えます。このまま使用するか、より細かいコンテキストのためにシステム設定で正確な位置情報を有効にしてください。';

  @override
  String get locationStatusServiceDisabledTitle => 'システムの位置情報がオフです';

  @override
  String get locationStatusServiceDisabledBody =>
      'Memex はデバイス GPS のみを使用し、ネットワークや IP から位置を推測しません。Android では位置情報設定を開き、iOS では「設定 > プライバシーとセキュリティ > 位置情報サービス」を有効にしてください。';

  @override
  String get locationStatusPermissionDeniedTitle => '位置情報の権限が必要です';

  @override
  String get locationStatusPermissionDeniedBody =>
      'テスト時または位置コンテキストが必要なときに、Memex に位置情報の使用を許可してください。常時アクセスは要求されません。';

  @override
  String get locationStatusPermissionForeverTitle => '位置情報の権限がブロックされています';

  @override
  String get locationStatusPermissionForeverBody =>
      'アプリ設定を開き、Memex の位置情報を許可してください。iOS では「アプリの使用中」で十分です。';

  @override
  String get locationStatusDisabledTitle => '位置コンテキストはオフです';

  @override
  String get locationStatusDisabledBody =>
      'Memex にデバイス位置を エージェントコンテキストへ添付させたい場合は、上のスイッチをオンにして保存してください。';

  @override
  String get locationStatusGeocodeUnavailableTitle =>
      'GPS は動作していますが、住所検索に失敗しました';

  @override
  String get locationStatusGeocodeUnavailableBody =>
      'Memex は座標を取得していますが、GPS のみのコンテキストは エージェントに注入しません。逆ジオコーディングプロバイダーを確認して再試行してください。';

  @override
  String get locationStatusUnavailableTitle => '位置情報を利用できません';

  @override
  String get locationStatusUnavailableBody =>
      'システムの位置情報サービスとアプリ権限を確認してから、もう一度テストしてください。';

  @override
  String get allowLocationPermissionButton => '位置情報の権限を許可';

  @override
  String get openAppSettingsButton => 'アプリ設定を開く';

  @override
  String get openLocationSettingsButton => '位置情報設定を開く';

  @override
  String get locationSettingsOpenFailed => 'システム設定を開けませんでした。';

  @override
  String locationActionFailed(String error) {
    return '位置情報操作に失敗しました: $error';
  }

  @override
  String get settingsSearchPlaceholder => '設定を検索...';

  @override
  String get settingsSearchEmpty => '一致する設定は見つかりませんでした';

  @override
  String get importCharacterCard => 'キャラクターカードをインポート';

  @override
  String get firstMessageLabel => '最初のメッセージ';

  @override
  String get firstMessageHint => '初回会話で送信される挨拶（任意）';

  @override
  String get systemPromptOverrideLabel => 'システムプロンプトの上書き';

  @override
  String get systemPromptOverrideHint => 'デフォルトのシステムプロンプトを上書き（上級、任意）';

  @override
  String get postHistoryInstructionsLabel => '履歴後の指示';

  @override
  String get postHistoryInstructionsHint => 'チャット履歴の後、返信前に注入される指示（任意）';

  @override
  String get mesExampleLabel => 'メッセージ例';

  @override
  String get mesExampleHint => 'キャラクターの話し方を示す会話例（任意）';

  @override
  String get worldBookTitle => 'ワールドブック';

  @override
  String get worldBookSubtitle => 'キーワードがトリガーされたときに注入される背景知識';

  @override
  String get characterMemoryTitle => 'キャラクターメモリ';

  @override
  String get characterMemorySubtitle => 'キャラクターとユーザーの関係性ややり取りの記憶';

  @override
  String get addTooltip => '追加';

  @override
  String get constantBadge => '常時';

  @override
  String worldEntryFallbackName(Object index) {
    return 'エントリ $index';
  }

  @override
  String keywordsPrefix(Object keys) {
    return 'キーワード: $keys';
  }

  @override
  String memoryFallbackName(Object index) {
    return 'メモリ $index';
  }

  @override
  String get addWorldEntry => 'ワールドブックエントリを追加';

  @override
  String get editWorldEntry => 'ワールドブックエントリを編集';

  @override
  String get commentTitleLabel => 'コメント / タイトル';

  @override
  String get entryDescriptionHint => 'エントリの説明（任意）';

  @override
  String get triggerKeywordsLabel => 'トリガーキーワード';

  @override
  String get triggerKeywordsHint => 'カンマ区切り、例: magic, spell';

  @override
  String get contentLabel => '内容';

  @override
  String get worldEntryContentHint => 'キーワードがトリガーされたときに注入される背景知識';

  @override
  String get enabledCheckbox => '有効';

  @override
  String get addMemory => 'メモリを追加';

  @override
  String get editMemory => 'メモリを編集';

  @override
  String get memoryLabelField => 'ラベル';

  @override
  String get memoryLabelHint => '一意の識別子、例: 呼び名の好み';

  @override
  String get memoryContentHint => 'メモリ内容';

  @override
  String get salienceLabel => '重要度: ';

  @override
  String get labelCannotBeEmpty => 'ラベルは空にできません';

  @override
  String importSuccess(Object name) {
    return '$name を正常にインポートしました';
  }

  @override
  String importFailed(Object error) {
    return 'インポートに失敗しました: $error';
  }

  @override
  String get supportedFormats => '対応形式';

  @override
  String get tavernImportDescription =>
      '• SillyTavern V2 キャラクターカード（.json）\n• 埋め込みカード付き PNG 画像（.png）\n\nペルソナ、ワールドブックなどのフィールドは Memex のキャラクター形式に自動的にマッピングされます。';

  @override
  String get pickCharacterFile => 'キャラクターファイルを選択';

  @override
  String get repickFile => '別のファイルを選択';

  @override
  String get personaSettingSection => 'ペルソナ';

  @override
  String get systemPromptSection => 'システムプロンプト';

  @override
  String worldEntriesCount(Object count) {
    return 'ワールドブック: $count 件のエントリ';
  }

  @override
  String fileLabel(Object filename) {
    return 'ファイル: $filename';
  }

  @override
  String conflictWarning(Object names) {
    return '同じ名前のキャラクターがすでに存在します: $names。インポートすると既存キャラクターを上書きせず、新しいキャラクターを作成します。';
  }

  @override
  String get setPrimaryCompanionTitle => 'メインコンパニオンに設定';

  @override
  String get setPrimaryCompanionSubtitle => 'インポート後、自動的にメインコンパニオンに設定します';

  @override
  String get confirmImport => 'インポートを確認';

  @override
  String get chatBackground => 'チャット背景';

  @override
  String get chooseChatBackgroundImage => '背景画像を選択';

  @override
  String get earlyUpdateSettingsTitle => 'Early アクセス更新';

  @override
  String get earlyUpdateSettingsDesc =>
      '一致する Early APK の GitHub プレリリースを確認し、ダウンロードして Android のインストーラーへ渡します。';

  @override
  String get earlyUpdateUnsupported => 'Early 更新は Android Early ビルドでのみ利用できます。';

  @override
  String get earlyUpdateAutoCheckTitle => '更新を自動確認';

  @override
  String get earlyUpdateAutoCheckDesc => '起動時に最大 12 時間に 1 回確認します。';

  @override
  String get earlyUpdateWifiOnlyTitle => 'Wi-Fi のみでダウンロード';

  @override
  String get earlyUpdateWifiOnlyDesc => 'モバイルデータ使用中は更新ダウンロードをスキップします。';

  @override
  String get earlyUpdateAutoInstallTitle => '自動でダウンロードしてインストール';

  @override
  String get earlyUpdateAutoInstallDesc =>
      '新しいビルドが見つかったら、ダウンロードして Android インストーラーを自動的に開きます。';

  @override
  String get earlyUpdateCheckNow => '今すぐ確認';

  @override
  String get earlyUpdateChecking => 'GitHub プレリリースを確認中...';

  @override
  String get earlyUpdateSkippedMobile => 'Wi-Fi のみのダウンロードが有効なためスキップしました。';

  @override
  String get earlyUpdateNoUpdate => 'すでに最新の Early ビルドです。';

  @override
  String earlyUpdateFound(Object version, Object build) {
    return 'Early ビルド $version+$build が利用可能です。';
  }

  @override
  String get earlyUpdateDownloadAndInstall => 'ダウンロードしてインストール';

  @override
  String get earlyUpdateDownloadInProgress => '更新をダウンロード中...';

  @override
  String earlyUpdateDownloadingPercent(Object percent) {
    return '更新をダウンロード中: $percent%';
  }

  @override
  String get earlyUpdateDownloadReadyToInstall =>
      '更新パッケージをダウンロードしました。インストールできます。';

  @override
  String get earlyUpdateInstallDownloadedPackage => 'ダウンロード済みパッケージをインストール';

  @override
  String get earlyUpdateClearDownloadedPackage => 'ダウンロード済みパッケージをクリア';

  @override
  String get earlyUpdateClearDownloadedPackageSuccess =>
      'ダウンロード済み更新パッケージをクリアしました。';

  @override
  String get earlyUpdateInstallStarted => 'Android インストーラーを開きました。';

  @override
  String get earlyUpdateInstallPermissionRequired =>
      'Memex に不明なアプリのインストールを許可し、もう一度ダウンロードしてインストールをタップしてください。';

  @override
  String earlyUpdateLastChecked(Object time) {
    return '前回確認: $time';
  }

  @override
  String earlyUpdateCheckFailed(Object error) {
    return '更新確認に失敗しました: $error';
  }

  @override
  String get earlyUpdateDialogTitle => 'Early 更新があります';

  @override
  String get earlyUpdateReleaseNotes => 'リリースノート';

  @override
  String get dismissAllNotifications => 'すべてクリア';

  @override
  String get dismissByType => '種類別にクリア';

  @override
  String get dismissTypeSystemAction => 'リマインダーとイベント';

  @override
  String get dismissTypeClarification => '確認事項';

  @override
  String get dismissTypeCardUpdate => 'カード更新';

  @override
  String dismissedCount(Object count) {
    return '$count 件をクリアしました';
  }

  @override
  String get dataImportTitle => 'ファイルをインポート';

  @override
  String get dataImportSettingsDescription =>
      '古いファイルを Memex に取り込み、整理するかどうかを後で選べます。';

  @override
  String get dataImportDescription =>
      '古いメモ、エクスポートした記録、ドキュメント、ZIP アーカイブを選択できます。Memex はまずコピーを保存し、元のファイルは変更しません。取り込み後に、整理を Memex に任せるかどうかを選べます。';

  @override
  String get dataImportSelectFiles => 'インポートするファイルを選択';

  @override
  String get dataImportImporting => 'ファイルを保存中...';

  @override
  String get dataImportSuccess => 'ファイルを Memex に保存しました';

  @override
  String get dataImportOnlyStored => 'ファイルを保存しました。整理は開始していません。';

  @override
  String get dataImportQueued => 'Memex がこのインポートをバックグラウンドで整理します。';

  @override
  String get dataImportResultTitle => 'インポート完了';

  @override
  String dataImportResultSummary(Object count) {
    return '$count 個のファイルを保存しました。今すぐ整理することも、元資料としてそのまま残すこともできます。';
  }

  @override
  String dataImportRenamedConflicts(Object count) {
    return '同じ名前の項目 $count 件は、上書きを避けるため名前を変更しました。';
  }

  @override
  String dataImportSkippedUnsafeEntries(Object count) {
    return 'アーカイブ内の通常と異なる項目 $count 件をスキップしました。その他は通常どおりインポートされました。';
  }

  @override
  String get dataImportChooseProcessing => 'これらのファイルを整理';

  @override
  String get dataImportProcessTitle => 'このインポートを整理しますか？';

  @override
  String dataImportProcessPrompt(Object count) {
    return '$count 個のファイルをインポートしました。Memex に今すぐ整理させるか、元の資料として保存するだけにするかを選択してください。';
  }

  @override
  String get dataImportProcessKnowledgeBase => 'ナレッジベースに整理';

  @override
  String get dataImportProcessKnowledgeBaseDesc =>
      'ドキュメント、メモ、プロジェクト資料、参考資料に向いています。Memex が有用な情報を抽出し、あとで使いやすいように分類します。';

  @override
  String get dataImportProcessTimelineCards => 'タイムライン記録を作成';

  @override
  String get dataImportProcessTimelineCardsDesc =>
      '日記、チャット履歴、活動履歴、古いエクスポートに向いています。Memex が時間に関係する内容を記録に変換します。';

  @override
  String get dataImportImpactNone =>
      'Memex はこれらの元ファイルだけを保存します。AI による整理は開始されません。';

  @override
  String get dataImportImpactKnowledgeBase =>
      'Memex がこれらのファイルを読み、長く残したい情報をナレッジベースに整理します。タイムライン記録は自動では作成しません。';

  @override
  String get dataImportImpactTimelineCards =>
      'Memex がこれらのファイルを読み、生活上の出来事や日付のある履歴をタイムライン記録にします。ナレッジベースは自動では整理しません。';

  @override
  String get dataImportImpactBoth =>
      'Memex がタイムライン記録の作成と、再利用できる情報のナレッジベース整理を両方試みます。まとまった個人アーカイブの取り込みに適しています。';

  @override
  String get dataImportFinish => '保存だけする';

  @override
  String get noImages => '画像がありません';

  @override
  String get noMessages => 'メッセージがありません';

  @override
  String get sketchContent => 'スケッチ';

  @override
  String get emptyFolder => '空のフォルダ';

  @override
  String get usernameAlreadyTaken => 'このユーザー名は既に使われています';

  @override
  String get registrationFailed => '登録に失敗しました';

  @override
  String get loginFailed => 'ログインに失敗しました';

  @override
  String get paymentCreationFailed => '支払いを開始できませんでした';

  @override
  String get completePayment => '支払いを完了';

  @override
  String get commentReplyToYou => 'あなた';

  @override
  String get commentAuthorUser => 'ユーザー';

  @override
  String get commentAuthorAi => 'AI';

  @override
  String get authorizationCancelled => '認可がキャンセルされました';

  @override
  String timelineWeekNumberLabel(Object week) {
    return '第$week週';
  }

  @override
  String get timelineWeekLabel => '週';

  @override
  String get eventCardDefaultTitle => 'イベント';

  @override
  String get memoryNoLongTermYet => '長期記憶はまだありません。';

  @override
  String get memoryNoRecentBuffer => 'バッファに最近の記憶はありません。';

  @override
  String get memoryGeneralSubject => '一般';
}
