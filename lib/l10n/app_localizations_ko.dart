// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get timesLabel => '횟수';

  @override
  String modelSetAsDefault(Object modelId) {
    return '$modelId을(를) 기본 모델로 설정';
  }

  @override
  String get retry => '재시도';

  @override
  String get unknownModel => '알 수 없는 모델';

  @override
  String get notSet => '설정되지 않음';

  @override
  String get confirmClear => '지우기 확인';

  @override
  String get confirmClearTokenMessage =>
      '현재 사용자를 지우시겠습니까? 사용자 ID를 다시 입력해야 합니다.';

  @override
  String get cancel => '취소';

  @override
  String get confirm => '확인';

  @override
  String get tokenCleared => '사용자를 지웠습니다';

  @override
  String clearTokenFailed(Object error) {
    return '사용자를 지우지 못했습니다: $error';
  }

  @override
  String get selectDateRangeOptional => '날짜 범위 선택(선택 사항):';

  @override
  String get startDate => '시작일';

  @override
  String get endDate => '종료일';

  @override
  String get select => '선택';

  @override
  String get processLimitOptional => '처리 제한(선택 사항)';

  @override
  String get leaveEmptyForAll => '전체를 처리하려면 비워 두세요';

  @override
  String get startProcessing => '처리 시작';

  @override
  String get userIdNotFound => '사용자 ID를 찾을 수 없습니다';

  @override
  String createTaskFailed(Object error) {
    return '작업을 만들지 못했습니다: $error';
  }

  @override
  String get reprocessCards => '카드 다시 처리';

  @override
  String get reprocessCardsTaskCreated => '다시 처리 요청을 슈퍼 에이전트 대기열에 추가했습니다';

  @override
  String get reprocessCardsDownstreamMode => '범위';

  @override
  String get reprocessCardsCardOnly => '카드만';

  @override
  String get reprocessCardsCardOnlyDesc =>
      '선택한 타임라인 카드를 검토하고 다시 생성하도록 슈퍼 에이전트에 요청합니다.';

  @override
  String get reprocessCardsRerunDownstream => '카드 및 관련 후속 작업';

  @override
  String get reprocessCardsRerunDownstreamDesc =>
      '필요할 때 관련 PKM과 인사이트 업데이트도 고려하도록 슈퍼 에이전트에 요청합니다.';

  @override
  String get reanalyzeMediaAssets => '미디어 첨부 다시 읽기';

  @override
  String get reanalyzeMediaAssetsDesc =>
      '카드를 다시 생성할 때 첨부 미디어를 다시 검사하도록 슈퍼 에이전트에 요청합니다.';

  @override
  String get regenerateComments => '댓글 다시 생성';

  @override
  String get regenerateCommentsTaskCreated =>
      '댓글 다시 생성 작업이 생성되어 백그라운드에서 실행 중입니다';

  @override
  String get rebuildSearchIndex => '검색 인덱스 다시 만들기';

  @override
  String get rebuildSearchIndexSuccess => '검색 인덱스를 성공적으로 다시 만들었습니다';

  @override
  String get rebuildSearchIndexFailed => '검색 인덱스를 다시 만들지 못했습니다';

  @override
  String get clearData => '데이터 지우기';

  @override
  String get confirmClearDataMessage => '데이터를 지우시겠습니까?';

  @override
  String get confirmClearDataDeletesWorkspaceMessage =>
      '현재 사용자의 모든 로컬 워크스페이스 데이터가 삭제됩니다. 카드, 미디어, 지식 파일, 인사이트, 메모리, 채팅 기록, 시스템 상태가 포함됩니다.\n\n이 작업은 되돌릴 수 없습니다!';

  @override
  String get clearFailedAgentContexts => '실패한 대화 컨텍스트 지우기';

  @override
  String get confirmClearFailedAgentContextsMessage =>
      '인사이트 에이전트와 일정 에이전트의 저장된 대화 컨텍스트를 지우시겠습니까? 모델을 변경한 뒤 이전 에이전트 메시지가 더 이상 호환되지 않을 때 유용합니다. 사실, 카드, 지식, 메모리, 모델 설정은 삭제되지 않습니다.';

  @override
  String failedAgentContextsCleared(Object count) {
    return '저장된 대화 컨텍스트 $count개를 지웠습니다';
  }

  @override
  String clearFailedAgentContextsFailed(Object error) {
    return '대화 컨텍스트를 지우지 못했습니다: $error';
  }

  @override
  String get cloneToTestUser => '테스트 사용자로 복제';

  @override
  String get confirmCloneToTestUserMessage =>
      '현재 워크스페이스를 새 로컬 테스트 사용자로 복사하고 그 사용자로 전환합니다. 에이전트 실행 상태는 복사되지 않습니다. 현재 사용자 데이터는 변경되지 않습니다.';

  @override
  String get testUserIdLabel => '테스트 사용자 ID';

  @override
  String get testUserIdHelper => '영문자, 숫자, 하이픈 또는 밑줄을 사용하세요.';

  @override
  String get testUserIdInvalid => '영문자, 숫자, 하이픈 또는 밑줄만 사용할 수 있습니다.';

  @override
  String get overwriteExistingTestUser => '같은 ID의 기존 테스트 사용자 바꾸기';

  @override
  String testUserCloneSuccess(Object userId) {
    return '테스트 사용자 $userId(으)로 전환했습니다';
  }

  @override
  String testUserCloneFailed(Object error) {
    return '테스트 사용자 복제에 실패했습니다: $error';
  }

  @override
  String get dataClearedSuccess => '데이터를 성공적으로 지웠습니다';

  @override
  String clearDataFailed(Object error) {
    return '데이터를 지우지 못했습니다: $error';
  }

  @override
  String get personalCenter => '개인 센터';

  @override
  String get viewLogs => '로그 보기';

  @override
  String get systemAuthorization => '시스템 권한';

  @override
  String get aiCharacterConfig => 'AI 캐릭터 설정';

  @override
  String get modelConfig => '모델 설정';

  @override
  String get agentConfig => '에이전트 설정';

  @override
  String get experimentalLab => '실험실';

  @override
  String get experimentalLabDescription => '나중에 변경되거나 이동될 수 있는 실험적 기능입니다.';

  @override
  String get modelUsageStats => '모델 사용 통계';

  @override
  String get asyncTaskList => '비동기 작업 목록';

  @override
  String get clearLocalToken => '사용자 지우기';

  @override
  String get insightCardTemplates => '인사이트 카드 템플릿';

  @override
  String get timelineCardTemplates => '타임라인 카드 템플릿';

  @override
  String get logViewer => '로그 뷰어';

  @override
  String get autoRefresh => '자동 새로고침';

  @override
  String get lineCount => '줄 수: ';

  @override
  String get all => '전체';

  @override
  String get schedule => '일정';

  @override
  String get appLockConfig => '앱 잠금 설정';

  @override
  String loadStatsFailed(Object error) {
    return '통계를 불러오지 못했습니다: $error';
  }

  @override
  String get overview => '개요';

  @override
  String get daily => '일별';

  @override
  String get modelStatsByAgent => '에이전트별';

  @override
  String get detail => '세부 정보';

  @override
  String get date => '날짜';

  @override
  String get agent => '에이전트';

  @override
  String get noData => '데이터 없음';

  @override
  String get totalCalls => '총 호출';

  @override
  String get calls => '호출';

  @override
  String callsCount(Object count) {
    return '$count회 호출';
  }

  @override
  String get selectDateRange => '날짜 범위 선택';

  @override
  String get totalTokens => '총 토큰';

  @override
  String get cacheRate => '캐시 비율';

  @override
  String get promptTokens => '프롬프트 토큰';

  @override
  String get completionTokens => '완성 토큰';

  @override
  String get cachedTokens => '캐시된 토큰';

  @override
  String get thoughtTokens => '사고 토큰';

  @override
  String get prompt => '프롬프트';

  @override
  String get completion => '완성';

  @override
  String get cached => '캐시됨';

  @override
  String get thought => '사고';

  @override
  String get model => '모델';

  @override
  String get scene => '장면';

  @override
  String get sceneId => '장면 ID';

  @override
  String get tokenUsage => '토큰 사용량';

  @override
  String get handler => '핸들러';

  @override
  String get modelBreakdown => '모델 분석';

  @override
  String get callDetails => '호출 세부 정보';

  @override
  String recordDetailsTitle(Object scene) {
    return '기록 세부 정보: $scene';
  }

  @override
  String saveLlmConfigFailed(Object error) {
    return 'LLM 설정을 저장하지 못했습니다: $error';
  }

  @override
  String get webHtmlPreviewUnavailable =>
      '웹에서는 HTML 미리보기를 사용할 수 없습니다. 모바일에서 확인해 주세요.';

  @override
  String saveUserInfoFailed(Object error) {
    return '사용자 정보를 저장하지 못했습니다: $error';
  }

  @override
  String get totalEstimatedCost => '총 예상 비용';

  @override
  String get close => '닫기';

  @override
  String get totalTokenConsumption => '총 토큰 소비량';

  @override
  String get dataLoadFailedRetry => '데이터를 불러오지 못했습니다. 나중에 다시 시도해 주세요.';

  @override
  String get timelineLoadFailedRetry => '타임라인을 불러오지 못했습니다. 나중에 다시 시도해 주세요.';

  @override
  String get newPerspective => '새로운 관점';

  @override
  String get startPoint => '시작';

  @override
  String get endPoint => '끝';

  @override
  String get originalInput => '원본 입력';

  @override
  String get referenceContent => '참조 내용';

  @override
  String referenceWithTitle(Object title) {
    return '참조: $title';
  }

  @override
  String get actionCenterTitle => '대기 중인 작업';

  @override
  String get noPendingActions => '대기 중인 작업이 없습니다';

  @override
  String get clarificationNeeded => 'Memex가 확인하고 싶어 합니다';

  @override
  String get clarificationTextHint => '짧은 답변을 입력하세요';

  @override
  String get clarificationTextRequired => '먼저 짧은 답변을 추가하세요';

  @override
  String get clarificationAnswered => '답변됨';

  @override
  String clarificationAnswerPrefix(Object answer) {
    return '답변: $answer';
  }

  @override
  String get answerSaved => '답변을 저장했습니다';

  @override
  String get clarificationOtherAnswer => '직접 입력';

  @override
  String get clarificationNotSure => '잘 모르겠음 / 답변하고 싶지 않음';

  @override
  String get yes => '예';

  @override
  String get no => '아니요';

  @override
  String get footprintMap => '발자국 지도';

  @override
  String get waypointPlaces => '경유 장소';

  @override
  String get unknownPlace => '알 수 없는 장소';

  @override
  String get releaseToSend => '놓으면 전송';

  @override
  String get selectFromAlbum => '앨범에서 선택';

  @override
  String get clipboardPreviewTitle => '새 클립보드';

  @override
  String get clipboardPreviewImageTitle => '클립보드 이미지';

  @override
  String get clipboardPreviewImageDescription => '추가할 이미지가 준비되었습니다';

  @override
  String get clipboardPreviewUnprocessed => '아직 붙여넣지 않았습니다';

  @override
  String get clipboardPreviewPasteToInput => '입력창에 붙여넣기';

  @override
  String get clipboardPreviewAddImageToInput => '이미지 추가';

  @override
  String get clipboardPreviewImageFailed => '클립보드 이미지를 읽을 수 없습니다';

  @override
  String get tellAiWhatHappened => '무슨 일이 있었는지 AI에게 알려 주세요...';

  @override
  String recordingWithDuration(Object duration) {
    return '녹음 중: $duration';
  }

  @override
  String get playing => '재생 중...';

  @override
  String get sendLabel => '보내기';

  @override
  String attachedImagesMessage(Object count) {
    return '이미지 $count장을 보냈습니다';
  }

  @override
  String get noTaskData => '작업 데이터가 없습니다';

  @override
  String createdAtDate(Object date) {
    return '생성: $date';
  }

  @override
  String updatedAtDate(Object date) {
    return '업데이트: $date';
  }

  @override
  String durationLabel(Object duration) {
    return '소요 시간: $duration';
  }

  @override
  String retryCount(Object count) {
    return '재시도: $count';
  }

  @override
  String get loadDetailFailedRetry => '세부 정보를 불러오지 못했습니다. 나중에 다시 시도해 주세요.';

  @override
  String get loadFailed => '불러오기 실패';

  @override
  String loadHistoryFailed(Object error) {
    return '기록을 불러오지 못했습니다: $error';
  }

  @override
  String get reload => '다시 불러오기';

  @override
  String get aiInsightDetail => '인사이트 세부 정보';

  @override
  String relatedRecordsCount(Object count) {
    return '관련 기록($count)';
  }

  @override
  String get noRelatedRecords => '관련 기록이 없습니다';

  @override
  String get useFingerprintToUnlock => '지문으로 잠금 해제';

  @override
  String get locked => '잠김';

  @override
  String get wrongPassword => '비밀번호가 올바르지 않습니다';

  @override
  String get enterPassword => '비밀번호 입력';

  @override
  String get memexLocked => 'Memex가 잠겨 있습니다';

  @override
  String get calendarShortSun => '일';

  @override
  String get calendarShortMon => '월';

  @override
  String get calendarShortTue => '화';

  @override
  String get calendarShortWed => '수';

  @override
  String get calendarShortThu => '목';

  @override
  String get calendarShortFri => '금';

  @override
  String get calendarShortSat => '토';

  @override
  String noRecordsOnDate(Object date) {
    return '$date에는 기록이 없습니다';
  }

  @override
  String get footprintPath => '발자국 경로';

  @override
  String get lifeCompositionTable => '생활 구성';

  @override
  String get emotionReframe => '감정 재구성';

  @override
  String get chronicleOfThings => '사물의 기록';

  @override
  String get goalProgress => '목표 진행';

  @override
  String get trendChart => '추세 차트';

  @override
  String get comparisonChart => '비교 차트';

  @override
  String get todayTimeFlow => '오늘의 시간 흐름';

  @override
  String get aiInputHint => '기억이든 지금의 일이든, 제가 여기 있어요...';

  @override
  String get refreshSuperAgentStateTooltip => 'Memex 에이전트 컨텍스트 지우기';

  @override
  String get refreshSuperAgentStateTitle => 'Memex 에이전트 기록 컨텍스트를 지우시겠습니까?';

  @override
  String get refreshSuperAgentStateMessage =>
      '표시되는 채팅 기록은 유지되지만, Memex 에이전트의 과거 실행 컨텍스트는 지워지고 이후 답변은 새로운 컨텍스트에서 시작됩니다. 영구 메모리, 지식 베이스 파일, 카드 및 기타 저장된 데이터에는 영향을 주지 않습니다. Memex 에이전트가 계속 비정상적으로 동작할 때 사용하세요. 계속하시겠습니까?';

  @override
  String get refreshSuperAgentStateActiveRunMessage =>
      '현재 Memex 에이전트 메시지가 끝난 뒤 컨텍스트를 지워 주세요.';

  @override
  String get refreshSuperAgentStateSuccess => 'Memex 에이전트 컨텍스트를 지웠습니다';

  @override
  String refreshSuperAgentStateFailed(Object error) {
    return 'Memex 에이전트 컨텍스트를 지우지 못했습니다: $error';
  }

  @override
  String get nothingHere => '아직 아무것도 없습니다';

  @override
  String get nothingHereHint => '아래 버튼을 눌러 첫 카드를 만드세요';

  @override
  String get agentProcessing => 'AI가 처리 중입니다...';

  @override
  String get keepAppOpen => '앱을 닫지 마세요';

  @override
  String get activityDetail => '활동 세부 정보';

  @override
  String get noAgentActivityYet => '아직 에이전트 활동이 없습니다';

  @override
  String get processingEllipsis => '처리 중...';

  @override
  String get agentBackgroundTitle => 'Memex 에이전트';

  @override
  String get agentBackgroundPausedTitle => 'Memex 에이전트 일시 중지됨';

  @override
  String get agentBackgroundNeedsAttentionTitle => 'Memex 에이전트에 확인이 필요합니다';

  @override
  String get agentBackgroundStageIdle => '대기 중';

  @override
  String get agentBackgroundStageProcessing => '처리 중';

  @override
  String get agentBackgroundStageQueued => '대기열에 있음';

  @override
  String get agentBackgroundStageRetrying => '재시도 대기 중';

  @override
  String get agentBackgroundStagePaused => '일시 중지됨';

  @override
  String get agentBackgroundStageCompleted => '완료됨';

  @override
  String get agentBackgroundStageNeedsAttention => '확인 필요';

  @override
  String get agentBackgroundStageAnalyzingMedia => '미디어 분석 중';

  @override
  String get agentBackgroundStageGeneratingCard => '카드 생성 중';

  @override
  String get agentBackgroundStageUpdatingKnowledge => '지식 업데이트 중';

  @override
  String get agentBackgroundStagePreparingComment => '댓글 준비 중';

  @override
  String get agentBackgroundStageRoutingFollowUps => '후속 작업 라우팅 중';

  @override
  String agentBackgroundTaskSummary(
    Object running,
    Object pending,
    Object retrying,
  ) {
    return '실행 중 $running, 대기 중 $pending, 재시도 $retrying';
  }

  @override
  String agentBackgroundTaskDetail(Object count) {
    return '대기열 작업 $count개를 처리 중입니다.';
  }

  @override
  String get agentBackgroundNoTasks => '백그라운드 작업이 없습니다.';

  @override
  String get agentBackgroundStarting => '처리를 시작하고 있습니다.';

  @override
  String get agentBackgroundCompletedDetail => '모든 백그라운드 작업이 완료되었습니다.';

  @override
  String get agentBackgroundFailedDetail => '오류로 인해 처리가 중단되었습니다.';

  @override
  String get agentBackgroundPausedDetail => '처리가 일시 중지되었으며 나중에 계속됩니다.';

  @override
  String get agentBackgroundQueuedDetail => '다음 처리 단계를 기다리는 중입니다.';

  @override
  String get agentBackgroundRetryingDetail => '현재 단계가 자동으로 다시 시도됩니다.';

  @override
  String get agentBackgroundAnalyzeMediaDetail => '첨부 파일과 로컬 컨텍스트를 읽는 중입니다.';

  @override
  String get agentBackgroundGeneratingCardDetail => '기록을 타임라인 카드로 변환 중입니다.';

  @override
  String get agentBackgroundUpdatingKnowledgeDetail => '로컬 지식과 메모리를 업데이트 중입니다.';

  @override
  String get agentBackgroundPreparingCommentDetail => '어시스턴트 후속 답변을 준비 중입니다.';

  @override
  String get agentBackgroundRoutingFollowUpsDetail => '이 카드의 후속 작업을 확인 중입니다.';

  @override
  String agentBackgroundPausedStatus(Object summary) {
    return '일시 중지됨 - $summary';
  }

  @override
  String agentBackgroundNeedsAttentionStatus(Object summary) {
    return '확인 필요 - $summary';
  }

  @override
  String get settings => '설정';

  @override
  String get languageSettings => '언어';

  @override
  String get languageSettingsDesc => '앱 표시 언어 변경';

  @override
  String get noPendingActionsToast => '대기 중인 작업이 없습니다';

  @override
  String get knowledgeNewDiscovery => '새로운 지식 발견';

  @override
  String discoveredNewInsightsCount(Object count) {
    return '새 인사이트 $count개를 발견했습니다';
  }

  @override
  String updatedExistingInsightsCount(Object count) {
    return '기존 인사이트 $count개를 업데이트했습니다';
  }

  @override
  String get sectionNewInsights => '새 인사이트';

  @override
  String get sectionUpdatedInsights => '업데이트된 인사이트';

  @override
  String get unnamedInsight => '이름 없는 인사이트';

  @override
  String get copiedToClipboard => '클립보드에 복사했습니다';

  @override
  String get copy => '복사';

  @override
  String get selectedLocation => '선택한 위치';

  @override
  String get confirmLocationName => '위치 이름 확인';

  @override
  String get confirmLocationNameHint => '이름을 수정할 수 있습니다(좌표는 그대로 유지)';

  @override
  String get nameLabel => '이름';

  @override
  String get inputPlaceNameHint => '장소 이름 입력...';

  @override
  String currentCoordinates(Object lat, Object lng) {
    return '좌표: $lat, $lng';
  }

  @override
  String get confirmLocation => '위치 확인';

  @override
  String get welcomeToMemex => 'Memex에 오신 것을 환영합니다';

  @override
  String get createUserIdToStart => '프로필 만들기';

  @override
  String get userIdLabel => '이름 / 닉네임';

  @override
  String get userIdHint => '이름 또는 닉네임 입력';

  @override
  String get pleaseEnterUserId => '이름을 입력해 주세요';

  @override
  String get userIdMaxLength => '이름은 50자를 넘을 수 없습니다';

  @override
  String get startUsing => '계속';

  @override
  String get userIdTip => '개인화된 경험을 제공하는 데 사용됩니다.';

  @override
  String get setupModelConfigTitle => 'AI 모델 설정';

  @override
  String get setupModelConfigSubtitle =>
      'Memex가 기록을 정리하고 이미지를 분석하며 인사이트를 생성하려면 최첨단 AI 모델이 필요합니다. 연결 방법을 선택하세요.';

  @override
  String get setupModelConfigComplete => '완료하고 이동';

  @override
  String get aiService => 'Memex 모델 서비스';

  @override
  String get aiModelHubTitle => 'AI 모델 및 서비스';

  @override
  String get aiModelHubSubtitle =>
      'Memex 공식 서비스를 선택하거나 직접 보유한 제공업체를 연결하세요. 필요할 때 고급 모델 라우팅도 사용할 수 있습니다.';

  @override
  String get aiSetupCurrentStatusTitle => '현재 설정';

  @override
  String get aiSetupStatusNotConfiguredTitle => 'AI 서비스가 설정되지 않았습니다';

  @override
  String get aiSetupStatusNotConfiguredDescription =>
      '기록, 미디어, 인사이트의 AI 정리를 활성화하려면 연결 방법을 선택하세요.';

  @override
  String get aiSetupStatusMemexTitle => 'Memex 공식 서비스 사용 중';

  @override
  String get aiSetupStatusMemexDescription =>
      'Memex는 Memex 계정에서 관리하는 공식 연결과 API 인증 정보를 사용합니다.';

  @override
  String get aiSetupStatusCustomTitle => '사용자 지정 제공업체 설정 사용 중';

  @override
  String get aiSetupStatusCustomDescription =>
      'Memex는 설정된 제공업체 인증 정보와 모델 역할 선택을 사용합니다.';

  @override
  String get aiSetupChooseConnectionTitle => '연결 방법 선택';

  @override
  String get aiSetupChooseConnectionDescription =>
      'Memex가 AI 모델에 접근하는 방식에 맞는 경로부터 시작하세요.';

  @override
  String get aiSetupOfficialRouteDescription =>
      'Memex에 로그인하여 공식 AI 서비스를 이용하세요.';

  @override
  String get aiSetupCustomRouteDescription => '자체 제공업체와 API 키를 추가합니다.';

  @override
  String get aiSetupCustomPageTitle => '사용자 지정 AI 서비스';

  @override
  String get aiSetupCustomPageSubtitle =>
      '먼저 제공업체 인증 정보를 설정한 다음 Memex가 사용할 모델을 선택하세요.';

  @override
  String get aiSetupProviderCredentialsTitle => '제공업체 및 API 키';

  @override
  String get aiSetupProviderCredentialsDescription =>
      'OpenAI, Anthropic, DeepSeek, Gemini, OpenRouter, Ollama 또는 다른 호환 제공업체를 추가하거나 편집합니다.';

  @override
  String get modelRolesTitle => '기본 모델 선택';

  @override
  String get modelRolesDescription =>
      '슈퍼 에이전트는 텍스트와 이미지 입력에 하나의 모델을 사용합니다. 고급 에이전트 재정의는 아래에서 계속 사용할 수 있습니다.';

  @override
  String get textModelRoleTitle => '기본 모델';

  @override
  String get textModelRoleDescription =>
      '슈퍼 에이전트가 텍스트, 이미지, 카드, 지식, 인사이트, 채팅, 댓글, 메모리에 사용합니다.';

  @override
  String get modelConnectionsTitle => '모델 제공업체 및 API 키';

  @override
  String get modelConnectionsDescription =>
      'Memex 공식 서비스를 연결하거나 직접 보유한 제공업체 인증 정보를 추가하세요.';

  @override
  String get relatedAiCapabilitiesTitle => '고급 및 관련 기능';

  @override
  String get relatedAiCapabilitiesDescription =>
      '에이전트 할당, 위치 제공업체, 음성 전사 동작을 세부 조정합니다.';

  @override
  String get aiSetupServiceCapabilitiesTitle => '서비스 기능';

  @override
  String get aiSetupServiceCapabilitiesDescription =>
      '음성 및 역지오코딩처럼 AI 기반 주변 기능에 Memex가 사용할 제공업체를 선택하세요.';

  @override
  String get aiSetupAdvancedCustomizationTitle => '고급 모델 라우팅';

  @override
  String get aiSetupAdvancedCustomizationDescription =>
      '개별 에이전트가 서로 다른 제공업체나 모델 설정을 사용하기 원하는 고급 사용자를 위한 옵션입니다.';

  @override
  String get locationProviderSettings => '위치 제공업체';

  @override
  String get speechProviderSettings => '음성 전사';

  @override
  String get advancedAgentModelAssignments => '에이전트 모델 할당';

  @override
  String get openAdvancedAgentModelAssignments => '개별 에이전트 재정의';

  @override
  String get noConfiguredModelOptions => '모델 역할을 선택하기 전에 제공업체 또는 API 키를 추가하세요.';

  @override
  String get modelSlotUpdated => '모델 역할을 업데이트했습니다';

  @override
  String get aiServiceMemexRouteTitle => 'Memex를 통해 연결';

  @override
  String get aiServiceLongDescription =>
      'Memex는 멀티 에이전트 시스템을 사용하여 생활 기록, 지식 노트, 사회적 맥락을 정리하고, 더 깊은 인사이트를 발견하며, 지속 메모리를 갖춘 AI 동반을 제공합니다. 데이터는 일반 텍스트 Markdown으로 저장되어 데이터의 자유와 이동성을 보존합니다.';

  @override
  String get aiServiceCustomApiRouteTitle => 'API 키가 있습니다';

  @override
  String get aiServiceCustomModelDescription =>
      'OpenAI, Anthropic, DeepSeek, Gemini 또는 다른 제공업체의 API 키를 이미 가지고 있다면 먼저 이 옵션을 선택하세요.';

  @override
  String get enableAiService => 'Memex와 연결';

  @override
  String get aiServiceReadyToast => 'AI 정리가 켜졌습니다';

  @override
  String get aiServiceSettingsDescription =>
      'API 키가 없다면 Memex 계정으로 주요 모델 서비스에 연결하세요.';

  @override
  String get advancedModelConfiguration => 'API 키 설정';

  @override
  String get skipForNow => '지금은 건너뛰기';

  @override
  String get clearAuth => '인증 지우기';

  @override
  String get authorizing => '인증 중...';

  @override
  String authFailed(Object error) {
    return '인증 실패: $error';
  }

  @override
  String get authorized => '인증됨';

  @override
  String authorizedAs(Object email) {
    return '$email(으)로 인증됨';
  }

  @override
  String get authorizedSuccessfully => '인증되었습니다';

  @override
  String get reAuthorize => '다시 인증';

  @override
  String get authorizeWithOpenAi => 'OpenAI로 인증';

  @override
  String get authorizeWithGoogle => 'Google로 인증';

  @override
  String get config => '설정';

  @override
  String get calendar => '캘린더';

  @override
  String get reminders => '미리 알림';

  @override
  String get writeToSystemFailed => '시스템에 쓰지 못했습니다';

  @override
  String permissionRequired(Object name) {
    return '$name 권한이 필요합니다';
  }

  @override
  String permissionRationale(Object name) {
    return '앱이 $name에 접근할 수 있도록 설정에서 허용해 주세요. 그래야 대신 생성할 수 있습니다.';
  }

  @override
  String get goToSettings => '설정으로 이동';

  @override
  String get unknownAction => '알 수 없는 작업';

  @override
  String get discoveredCalendarEvent => '캘린더 이벤트를 찾았습니다';

  @override
  String get discoveredReminder => '미리 알림을 찾았습니다';

  @override
  String get addToCalendar => '캘린더에 추가';

  @override
  String get addToReminders => '미리 알림에 추가';

  @override
  String get systemActionPendingExplanation =>
      '아직 추가되지 않았습니다. 아래 버튼을 눌러 권한을 요청하고 기기에 추가하세요.';

  @override
  String addedToSuccess(Object target) {
    return '$target에 성공적으로 추가했습니다';
  }

  @override
  String get ignore => '무시';

  @override
  String get confirmDelete => '삭제 확인';

  @override
  String get confirmDeleteSessionMessage => '이 대화를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';

  @override
  String get delete => '삭제';

  @override
  String get deleteSuccess => '성공적으로 삭제했습니다';

  @override
  String deleteFailed(Object error) {
    return '삭제 실패: $error';
  }

  @override
  String daysAgo(Object count) {
    return '$count일 전';
  }

  @override
  String get chatHistory => '채팅 기록';

  @override
  String get enterFullScreenTooltip => '전체 화면으로 전환';

  @override
  String get exitFullScreenTooltip => '전체 화면 종료';

  @override
  String get noConversations => '대화가 없습니다';

  @override
  String loadSessionListFailed(Object error) {
    return '대화 목록을 불러오지 못했습니다: $error';
  }

  @override
  String yesterdayAt(Object time) {
    return '어제 $time';
  }

  @override
  String get newChat => '새 채팅';

  @override
  String messageCount(Object count) {
    return '메시지 $count개';
  }

  @override
  String get organize => '정리';

  @override
  String get pkmCategoryProject => '프로젝트';

  @override
  String get pkmCategoryProjectSubtitle => '단기 · 목표 · 마감';

  @override
  String get pkmCategoryArea => '영역';

  @override
  String get pkmCategoryAreaSubtitle => '장기 · 책임 · 기준';

  @override
  String get pkmCategoryResource => '리소스';

  @override
  String get pkmCategoryResourceSubtitle => '관심사 · 영감 · 저장';

  @override
  String get pkmCategoryArchive => '아카이브';

  @override
  String get pkmCategoryArchiveSubtitle => '완료 · 휴면 · 참조';

  @override
  String get recentChanges => '최근 변경 사항';

  @override
  String get noRecentChangesInThreeDays => '지난 3일 동안 변경 사항이 없습니다';

  @override
  String get unpinned => '고정 해제됨';

  @override
  String get pinnedStyle => '스타일 고정됨';

  @override
  String operationFailed(Object error) {
    return '작업 실패: $error';
  }

  @override
  String get refreshingInsightData => '인사이트 데이터를 새로고침 중입니다. 잠시 걸릴 수 있습니다...';

  @override
  String refreshFailed(Object error) {
    return '새로고침 실패: $error';
  }

  @override
  String get sortUpdated => '정렬 순서를 업데이트했습니다';

  @override
  String sortSaveFailed(Object error) {
    return '정렬을 저장하지 못했습니다: $error';
  }

  @override
  String get insightCardDeleted => '인사이트 카드를 삭제했습니다';

  @override
  String deleteFailedShort(Object error) {
    return '삭제 실패: $error';
  }

  @override
  String get knowledgeInsight => '지식 인사이트';

  @override
  String get completeSort => '정렬 완료';

  @override
  String get noKnowledgeInsight => '지식 인사이트가 없습니다';

  @override
  String insightProcessingBacklogMessage(Object count) {
    return '백그라운드 작업 $count개가 아직 처리 중입니다.';
  }

  @override
  String get insightUnavailableMessage =>
      '이 인사이트는 아직 생성 중이거나 업데이트되었습니다. 인사이트를 새로고침한 뒤 나중에 다시 시도해 주세요.';

  @override
  String get artifactOpen => '열기';

  @override
  String get updating => '업데이트 중...';

  @override
  String get update => '업데이트';

  @override
  String get enabled => '활성화됨';

  @override
  String get disabled => '비활성화됨';

  @override
  String get appLockOn => '앱 잠금이 켜졌습니다';

  @override
  String get appLockOff => '앱 잠금이 꺼졌습니다';

  @override
  String get enableAppLockFirst => '먼저 앱 잠금을 켜 주세요';

  @override
  String get enterFourDigitPassword => '4자리 비밀번호 입력';

  @override
  String get passwordSetAndLockOn => '비밀번호를 설정하고 앱 잠금을 켰습니다';

  @override
  String get appLockSettings => '앱 잠금 설정';

  @override
  String get enableAppLock => '앱 잠금 켜기';

  @override
  String get enableAppLockSubtitle => '앱을 실행할 때 비밀번호 필요';

  @override
  String get enableBiometrics => '생체 인증 켜기';

  @override
  String get biometricsSubtitle => 'Face ID 또는 Touch ID로 잠금 해제';

  @override
  String get changePassword => '비밀번호 변경';

  @override
  String get setFourDigitPassword => '4자리 비밀번호 설정';

  @override
  String get reenterPasswordToConfirm => '확인을 위해 비밀번호 다시 입력';

  @override
  String get passwordMismatch => '비밀번호가 일치하지 않습니다. 다시 시도해 주세요.';

  @override
  String confirmDeleteCharacter(Object name) {
    return '캐릭터 \"$name\"을(를) 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';
  }

  @override
  String get configureAiCharacter => 'AI 캐릭터 설정';

  @override
  String get addCharacter => '캐릭터 추가';

  @override
  String get addCharacterSubtitle =>
      '인사이트 팀에 참여할 AI 캐릭터를 선택하세요. 각 캐릭터가 서로 다른 관점에서 생활 데이터를 분석합니다.';

  @override
  String get noCharacters => '캐릭터가 없습니다';

  @override
  String loadCharacterFailed(Object error) {
    return '캐릭터를 불러오지 못했습니다: $error';
  }

  @override
  String get noTags => '태그 없음';

  @override
  String get createSuccess => '성공적으로 생성했습니다';

  @override
  String get updateSuccess => '성공적으로 업데이트했습니다';

  @override
  String saveFailed(Object error) {
    return '저장 실패: $error';
  }

  @override
  String get newCharacter => '새 캐릭터';

  @override
  String get editCharacter => '캐릭터 편집';

  @override
  String get save => '저장';

  @override
  String get characterName => '캐릭터 이름';

  @override
  String get characterNameHint => '캐릭터 이름을 입력하세요';

  @override
  String get pleaseEnterCharacterName => '캐릭터 이름을 입력해 주세요';

  @override
  String get tagsLabel => '태그';

  @override
  String get tagsHint => '예: 지혜, 인정, 거시적\n여러 태그는 쉼표로 구분하세요';

  @override
  String get characterPersonaLabel => '캐릭터 페르소나';

  @override
  String get characterPersonaHint =>
      '페르소나, 스타일 가이드, 대화 예시, 지식 필터 등을 포함하세요.\n섹션 제목에는 ##을 사용하세요.';

  @override
  String get pleaseEnterCharacterPersona => '캐릭터 페르소나를 입력해 주세요';

  @override
  String permissionRequestError(Object error) {
    return '권한 요청 오류: $error';
  }

  @override
  String get permissionRequiredTitle => '권한 필요';

  @override
  String get permissionPermanentlyDeniedMessage =>
      '이 권한을 영구적으로 거부했거나 시스템에서 요구합니다. 시스템 설정에서 활성화해 주세요.';

  @override
  String get getting => '가져오는 중...';

  @override
  String get unauthorized => '인증되지 않음';

  @override
  String get authorizedGoToSettings => '인증됨. 변경하려면 시스템 설정으로 이동하세요.';

  @override
  String get location => '위치';

  @override
  String get locationPermissionReason => '장소 기록 및 위치 관련 기능을 위해';

  @override
  String get photos => '사진';

  @override
  String get photosPermissionReason => '사진 선택, 생성 이미지 저장 등을 위해';

  @override
  String get camera => '카메라';

  @override
  String get cameraPermissionReason => '사진과 동영상 촬영을 위해';

  @override
  String get microphone => '마이크';

  @override
  String get microphonePermissionReason => '음성 인식, 녹음 등을 위해';

  @override
  String get calendarPermissionReason => '일정 기록 및 캘린더 이벤트 읽기를 위해';

  @override
  String get remindersPermissionReason => '미리 알림 기록 및 읽기를 위해';

  @override
  String get fitnessAndMotion => '피트니스 및 동작';

  @override
  String get fitnessPermissionReason => '건강 및 동작 데이터 기록을 위해';

  @override
  String get notification => '알림';

  @override
  String get notificationPermissionReason => '일정 및 중요한 미리 알림을 보내기 위해';

  @override
  String get memexAgentNotificationPermissionTitle =>
      'Memex Agent를 백그라운드에서 계속 실행';

  @override
  String get memexAgentNotificationPermissionMessage =>
      'Memex Agent는 기기에서 로컬로 실행됩니다. 알림을 허용하면 Memex가 진행 상황을 표시하고 앱을 벗어나거나 화면을 꺼도 작업을 계속 처리할 수 있습니다. 알림을 허용하지 않으면 작업이 끝날 때까지 Memex를 전면에 유지해 주세요.';

  @override
  String get loadDetailFailedRetryShort => '세부 정보를 불러오지 못했습니다. 나중에 다시 시도해 주세요.';

  @override
  String get total => '합계';

  @override
  String get estimatedCost => '예상 비용';

  @override
  String get byAgent => '에이전트별';

  @override
  String get timeUpdated => '업데이트 시간';

  @override
  String updateFailed(Object error) {
    return '업데이트 실패: $error';
  }

  @override
  String get locationUpdated => '위치를 업데이트했습니다';

  @override
  String get confirmDeleteCardMessage => '이 카드를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';

  @override
  String get cardDetailNotFound => '카드 세부 정보를 찾을 수 없습니다';

  @override
  String get saySomething => '무언가 입력하세요...';

  @override
  String get relatedMemories => '관련 메모리';

  @override
  String get viewMore => '더 보기';

  @override
  String get relatedRecords => '관련 기록';

  @override
  String get reply => '답장';

  @override
  String get replySent => '답장을 보냈습니다';

  @override
  String get insightTemplateGalleryTitle => '인사이트 카드 템플릿';

  @override
  String get timelineTemplateGalleryTitle => '타임라인 카드 템플릿';

  @override
  String get categoryTextual => '텍스트';

  @override
  String get timelineFilterAll => '전체';

  @override
  String get insights => '인사이트';

  @override
  String get memoryTitle => '메모리';

  @override
  String get longTermProfile => '장기 프로필';

  @override
  String get recentBuffer => '최근 버퍼';

  @override
  String errorLoadingMemory(Object error) {
    return '메모리를 불러오는 중 오류: $error';
  }

  @override
  String get agentConfiguration => '에이전트 설정';

  @override
  String get resetToDefaults => '기본값으로 재설정';

  @override
  String get resetAllAgentConfigurationsTitle => '모든 에이전트 설정 재설정';

  @override
  String get resetAllAgentConfigurationsMessage =>
      '모든 에이전트 설정을 기본값으로 재설정하시겠습니까? 이 작업은 되돌릴 수 없습니다.';

  @override
  String get resetButton => '재설정';

  @override
  String loadDataFailed(Object error) {
    return '데이터를 불러오지 못했습니다: $error';
  }

  @override
  String saveConfigFailed(Object error) {
    return '설정을 저장하지 못했습니다: $error';
  }

  @override
  String get selectLlmClient => 'LLM 클라이언트 선택:';

  @override
  String get agentConfigurationsReset => '에이전트 설정을 재설정했습니다';

  @override
  String resetFailed(Object error) {
    return '재설정 실패: $error';
  }

  @override
  String get modelConfiguration => '모델 설정';

  @override
  String get resetAllConfigurationsTitle => '모든 설정 재설정';

  @override
  String get resetAllModelConfigurationsMessage =>
      '모든 모델 설정을 기본값으로 재설정하시겠습니까? 이 작업은 되돌릴 수 없습니다.';

  @override
  String get modelConfigurationsReset => '모델 설정을 재설정했습니다';

  @override
  String get cannotDeleteDefaultConfiguration => '기본 설정은 삭제할 수 없습니다';

  @override
  String get cannotDeleteConfigurationTitle => '설정을 삭제할 수 없음';

  @override
  String configUsedByAgentsMessage(Object agentList) {
    return '이 설정은 현재 다음 에이전트에서 사용 중입니다:\n\n$agentList\n\n삭제하기 전에 이 에이전트들을 다시 할당해 주세요.';
  }

  @override
  String get ok => '확인';

  @override
  String get deleteConfigurationTitle => '설정 삭제';

  @override
  String confirmDeleteConfigMessage(Object key) {
    return '\"$key\"을(를) 삭제하시겠습니까?';
  }

  @override
  String get defaultLabel => '기본값';

  @override
  String get setAsDefault => '기본값으로 설정';

  @override
  String get invalidJsonInExtraField => 'Extra 필드의 JSON이 올바르지 않습니다';

  @override
  String get keyAlreadyExists => '키가 이미 존재합니다';

  @override
  String get resetConfigurationTitle => '설정 재설정';

  @override
  String get resetConfigurationMessage =>
      '이 설정을 초기 기본값으로 재설정하시겠습니까? 현재 변경 사항은 사라집니다.';

  @override
  String get configurationResetPressSave => '설정을 재설정했습니다. 적용하려면 저장을 누르세요.';

  @override
  String get addConfiguration => '설정 추가';

  @override
  String get editConfiguration => '설정 편집';

  @override
  String get duplicateConfiguration => '설정 복제';

  @override
  String get duplicate => '복제';

  @override
  String get keyIdLabel => '설정 ID';

  @override
  String get keyIdHelper => 'deepseek 또는 work-gpt처럼 이 설정의 이름을 지정하세요.';

  @override
  String get required => '필수';

  @override
  String get clientLabel => '모델 제공업체';

  @override
  String get providerGroupOpenAi => 'OpenAI';

  @override
  String get providerGroupAnthropic => 'Anthropic';

  @override
  String get providerGroupGoogle => 'Google';

  @override
  String get providerGroupOthers => '인기';

  @override
  String get providerOpenAiApiKey => 'API 키';

  @override
  String get providerOpenAiResponses => 'API 키(Responses)';

  @override
  String get providerChatGptOauth => 'ChatGPT Pro/Plus';

  @override
  String get providerClaudeApiKey => 'API 키';

  @override
  String get providerBedrockSecret => 'Bedrock Secret';

  @override
  String get providerGemini => 'Gemini';

  @override
  String get providerGeminiOauth => 'Gemini(Google OAuth)';

  @override
  String get providerKimi => 'Kimi(Moonshot)';

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
  String get providerOllama => 'Ollama(로컬)';

  @override
  String get providerMimo => 'Xiaomi MIMO';

  @override
  String get providerMemex => 'Memex 프록시 서비스';

  @override
  String get memexSignIn => '로그인';

  @override
  String get memexCreateAccount => '계정 만들기';

  @override
  String get memexUsername => '사용자 이름';

  @override
  String get memexPassword => '비밀번호';

  @override
  String get memexCreateAccountLink => '계정 만들기';

  @override
  String get memexSignInLink => '대신 로그인';

  @override
  String get memexTopUp => 'Memex AI 사용을 시작하려면 충전하세요';

  @override
  String get memexTopUpSuccess => '충전 성공!';

  @override
  String get memexFillAllFields => '모든 필드를 입력해 주세요';

  @override
  String get memexUsernameTooShort => '사용자 이름은 최소 6자여야 합니다';

  @override
  String get memexAuthFailed => '인증 실패';

  @override
  String get memexPaymentFailed => '결제를 만들지 못했습니다';

  @override
  String get memexLogout => '로그아웃';

  @override
  String get memexTopUpButton => '충전';

  @override
  String get memexTopUpChooseAmount => '금액 선택';

  @override
  String memexTopUpEstimatedRecords(Object range) {
    return '약 $range개의 기록';
  }

  @override
  String get memexTopUpPlanStarter => '스타터';

  @override
  String get memexTopUpPlanEveryday => '일상';

  @override
  String get memexTopUpPlanHighVolume => '대용량';

  @override
  String get memexTopUpPlanCustom => '사용자 지정 크레딧';

  @override
  String get memexTopUpPlanStarterSubtitle => 'Memex AI를 시험해 보기 좋습니다';

  @override
  String get memexTopUpPlanEverydaySubtitle => '정기적인 정리에 좋습니다';

  @override
  String get memexTopUpPlanHighVolumeSubtitle => '더 큰 배치에 좋습니다';

  @override
  String get memexTopUpPlanCustomSubtitle => 'USD 1-10,000 입력';

  @override
  String get memexTopUpCustomEstimate => '예상치는 입력한 금액을 기준으로 합니다';

  @override
  String get memexCustomAmount => '사용자 지정 금액';

  @override
  String get memexViewHistory => '사용 기록';

  @override
  String memexBalanceLabel(Object amount) {
    return '잔액: $amount';
  }

  @override
  String get memexConfirmPassword => '비밀번호 확인';

  @override
  String get memexPasswordMismatch => '비밀번호가 일치하지 않습니다';

  @override
  String memexPayAmount(Object amount) {
    return '$amount 충전';
  }

  @override
  String get modelIdLabel => '모델';

  @override
  String get modelIdHelper => '예: gemini-3.1-pro-preview, gpt-4o';

  @override
  String get fetchingModels => '모델을 가져오는 중...';

  @override
  String get fetchModelsButton => '모델 가져오기';

  @override
  String get enterApiKeyFirst => '모델을 가져오려면 먼저 API 키를 입력하세요';

  @override
  String get apiKeyLabel => 'API 키';

  @override
  String get baseUrlLabel => 'API 엔드포인트';

  @override
  String get advancedSettings => '고급 설정';

  @override
  String get testConnectionSuccess => '연결 성공';

  @override
  String get testConnectionFailed => '연결 실패';

  @override
  String get testTypeText => '텍스트';

  @override
  String get testTypeVision => '비전';

  @override
  String get testButton => '테스트';

  @override
  String get testing => '테스트 중...';

  @override
  String get proxyUrlOptional => '프록시 URL(선택 사항)';

  @override
  String get proxyUrlHelper => '예: http://127.0.0.1:7890';

  @override
  String get temperatureLabel => 'Temperature';

  @override
  String get topPLabel => 'Top P';

  @override
  String get maxTokensLabel => 'Max Tokens';

  @override
  String get extraParamsJson => '추가 매개변수(JSON)';

  @override
  String get invalidJson => '올바르지 않은 JSON';

  @override
  String get warning => '설정이 완료되지 않았습니다';

  @override
  String get invalidConfigurationWarning =>
      '설정이 아직 완전하지 않습니다(예: API 키 또는 모델 ID 누락). 그래도 저장하고 나중에 설정할 수 있습니다. 계속하시겠습니까?';

  @override
  String invalidModelConfigDetailed(Object agentId, Object configKey) {
    return 'AI 에이전트 \"$agentId\"가 작동하려면 유효한 모델 설정(키: \"$configKey\")이 필요합니다. 모델 설정을 확인해 주세요.';
  }

  @override
  String get discardChangesTitle => '이 페이지를 떠나시겠습니까?';

  @override
  String get discardChangesMessage => '변경 사항이 있다면 떠나기 전에 저장해 주세요.';

  @override
  String get discardButton => '버리기';

  @override
  String get chooseLanguage => '언어 선택';

  @override
  String get chooseAvatar => '아바타 선택';

  @override
  String get configureNow => '지금 설정';

  @override
  String get modelNotConfiguredBanner =>
      'AI 모델이 아직 설정되지 않았습니다. 설정하면 모든 기능을 사용할 수 있습니다.';

  @override
  String get modelNotConfiguredSubmitHint => '게시하기 전에 AI 모델을 설정해 주세요';

  @override
  String get processingStatus => '처리 중';

  @override
  String get failedStatus => '실패';

  @override
  String get failureReason => '실패 원인';

  @override
  String get unknownError => '알 수 없는 오류가 발생했습니다';

  @override
  String get enableFitness => '피트니스 활성화';

  @override
  String get fitnessBannerMessage => '건강 및 활동 데이터를 추적할 수 있도록 피트니스 접근을 허용해 주세요.';

  @override
  String get fitnessDismissTitle => '피트니스 접근을 건너뛰시겠습니까?';

  @override
  String get fitnessDismissMessage =>
      '피트니스 권한이 없으면 앱이 인사이트와 자동 기록을 위해 건강 데이터를 자동 수집할 수 없습니다.';

  @override
  String get skipAnyway => '그래도 건너뛰기';

  @override
  String get proModelHint => '이 모델을 사용하려면 ChatGPT Pro/Plus 구독이 필요합니다.';

  @override
  String get searchKnowledgeBase => '지식 베이스 검색...';

  @override
  String get searchKnowledgeHint => '파일 이름 또는 내용을 검색할 키워드를 입력하세요';

  @override
  String noSearchResults(Object query) {
    return '\"$query\"에 대한 결과를 찾을 수 없습니다';
  }

  @override
  String get onlyMarkdownPreview => 'Markdown 미리보기만 지원됩니다';

  @override
  String get backupAndRestore => '백업 및 복원';

  @override
  String get createBackup => '백업 만들기';

  @override
  String get restoreBackup => '백업 복원';

  @override
  String get backupDescription =>
      '모든 데이터(카드, 지식 베이스, 인사이트, 설정)를 .memex 파일로 묶습니다. 공유 시트를 통해 iCloud Drive, Google Drive 또는 원하는 위치에 저장하세요.';

  @override
  String get restoreDescription =>
      '.memex 백업 파일을 선택해 모든 데이터를 복원합니다. 현재 데이터는 덮어써집니다.';

  @override
  String get selectBackupFile => '백업 파일 선택';

  @override
  String get estimatedSize => '예상 크기';

  @override
  String get backupComplete => '백업이 생성되었습니다';

  @override
  String backupFailed(Object error) {
    return '백업 실패: $error';
  }

  @override
  String get confirmRestore => '복원 확인';

  @override
  String get confirmRestoreMessage =>
      '복원하면 카드, 지식 베이스, 인사이트, 설정을 포함한 현재 모든 데이터가 덮어써집니다. 이 작업은 되돌릴 수 없습니다. 계속하시겠습니까?';

  @override
  String get restoreComplete => '복원 완료';

  @override
  String get restoreRestartHint =>
      '데이터가 복원되었습니다. 모든 변경 사항을 적용하려면 앱을 다시 시작해 주세요.';

  @override
  String restoreFailed(Object error) {
    return '복원 실패: $error';
  }

  @override
  String get invalidBackupFile => '올바르지 않은 백업 파일입니다. .memex 파일을 선택해 주세요.';

  @override
  String get automaticBackup => '자동 백업';

  @override
  String get autoBackupDescription =>
      '활성화하면 Memex가 시작 후 또는 포그라운드로 돌아올 때 하루 최대 한 번 로컬 스냅샷을 만듭니다.';

  @override
  String get backupSensitiveSettingsHint =>
      '백업에는 설정과 모델 제공업체 키가 포함됩니다. 신뢰할 수 있는 위치에 보관하세요.';

  @override
  String get backupLocation => '위치';

  @override
  String get backupLocationDetails => '위치 세부 정보';

  @override
  String get backupLocationSummary => '앱에 표시됨';

  @override
  String get backupLocationFullPath => '전체 경로';

  @override
  String get backupLocationUri => '폴더 접근 URI';

  @override
  String get copyBackupLocationPath => '경로 복사';

  @override
  String get backupLocationCopied => '백업 위치를 복사했습니다';

  @override
  String androidBackupLocationSelected(Object folderName) {
    return '선택한 폴더: $folderName';
  }

  @override
  String get iosICloudBackupLocation => 'iCloud Drive > Memex > Backups';

  @override
  String get iosAppDocumentsBackupLocation =>
      '파일 > 나의 iPhone > Memex > Backups';

  @override
  String get autoBackupStatus => '상태';

  @override
  String get noAutoBackupYet => '아직 자동 백업이 없습니다';

  @override
  String lastBackupAt(Object time) {
    return '마지막 백업: $time';
  }

  @override
  String get autoBackupRetention => '보존';

  @override
  String autoBackupRetentionDays(Object days) {
    return '$days일';
  }

  @override
  String get autoBackupRetentionForever => '영구 보존';

  @override
  String get autoBackupMaxSize => '저장 용량 한도';

  @override
  String autoBackupRetentionLimitHint(Object size) {
    return '자동 정리는 자동 스냅샷을 $size 이하로 유지합니다. 안전 스냅샷과 수동 내보내기 백업은 별도로 보관됩니다.';
  }

  @override
  String get createSnapshotNow => '지금 백업';

  @override
  String get backupLocationMenu => '위치 변경';

  @override
  String get defaultBackupLocation => '기본 백업 폴더';

  @override
  String get defaultBackupLocationAndroidDesc =>
      'Memex의 앱 전용 외부 파일 폴더를 사용합니다. 저장소 권한이 필요하지 않습니다.';

  @override
  String get chooseBackupLocation => '백업 폴더 선택';

  @override
  String get chooseBackupLocationAndroidDesc =>
      'Android 시스템 선택기로 폴더를 고르고 Memex에 지속 접근 권한을 부여합니다.';

  @override
  String get storedBackups => '저장된 백업';

  @override
  String get noStoredBackups => '첫 스냅샷 후 자동 백업이 여기에 표시됩니다.';

  @override
  String get backupTypeAutoSnapshot => '자동 스냅샷';

  @override
  String get backupTypeSafetySnapshot => '안전 스냅샷';

  @override
  String get backupTypeManualBackup => '수동 백업';

  @override
  String get refresh => '새로고침';

  @override
  String get restoreThisBackup => '이 백업 복원';

  @override
  String get deleteThisBackup => '이 백업 삭제';

  @override
  String get confirmDeleteBackup => '백업을 삭제하시겠습니까?';

  @override
  String confirmDeleteBackupMessage(Object fileName) {
    return '$fileName을(를) 삭제하시겠습니까? 저장된 백업 파일이 제거되며 되돌릴 수 없습니다.';
  }

  @override
  String backupDeleted(Object fileName) {
    return '백업을 삭제했습니다: $fileName';
  }

  @override
  String backupDeleteFailed(Object error) {
    return '백업을 삭제할 수 없습니다: $error';
  }

  @override
  String get creatingSafetySnapshot => '안전 스냅샷 생성 중...';

  @override
  String autoBackupCreated(Object fileName) {
    return '스냅샷 생성됨: $fileName';
  }

  @override
  String backupLocationFailed(Object error) {
    return '백업 위치를 업데이트할 수 없습니다: $error';
  }

  @override
  String get backupImportCreatedAt => '생성됨';

  @override
  String get backupImportSourceVersion => '소스 버전';

  @override
  String get backupImportFlavor => '빌드';

  @override
  String get backupLegacyFormat => '레거시 백업(manifest 없음)';

  @override
  String get restoreInProgress => '백업 복원 중...';

  @override
  String get dataStorage => '데이터 저장소';

  @override
  String get dataStorageDescriptionAndroid =>
      '워크스페이스를 저장할 사용자 지정 폴더를 선택하세요. 앱을 다시 설치해도 데이터가 유지됩니다.';

  @override
  String get dataStorageDescriptionIOS =>
      'iCloud를 켜면 워크스페이스를 기기 간에 동기화하고 앱 재설치 후에도 데이터를 유지할 수 있습니다.';

  @override
  String get storageLocationApp => '앱 저장소';

  @override
  String get storageLocationAppDesc => '데이터가 앱 내부에 저장되며 제거하면 함께 삭제됩니다.';

  @override
  String get storageLocationCustom => '기기 저장소(사용자 지정 폴더)';

  @override
  String get storageLocationCustomDesc =>
      '선택한 폴더에 데이터를 저장합니다. 폴더가 남아 있으면 재설치 후에도 데이터가 유지됩니다.';

  @override
  String get storageLocationICloud => 'iCloud에 저장';

  @override
  String get storageLocationICloudDesc =>
      'Apple 기기 간에 워크스페이스를 동기화합니다. 재설치 후에도 데이터가 유지됩니다.';

  @override
  String storageLocationCurrent(Object location) {
    return '현재: $location';
  }

  @override
  String get icloudRequiresCapability =>
      'iCloud 저장소를 사용하려면 iCloud에 로그인하고 iCloud Drive를 켜세요.';

  @override
  String get loadingFromICloud => 'iCloud에서 데이터 복원 중…';

  @override
  String get switchingToICloud => 'iCloud 저장소로 전환 중…';

  @override
  String get switchingStorage => '저장소 전환 중…';

  @override
  String get customFolderAccessDenied =>
      '이 폴더를 읽거나 쓸 수 없습니다. 저장소 권한을 허용하거나 다른 위치를 선택하세요.';

  @override
  String get configured => '설정됨';

  @override
  String get apiKeyNotSet => 'API 키가 설정되지 않음 — 탭하여 설정';

  @override
  String get bottomNavTimeline => '타임라인';

  @override
  String get bottomNavLibrary => '라이브러리';

  @override
  String get aiGeneratedLabel => 'AI 생성';

  @override
  String sourceTraceWithCount(Object count) {
    return '소스 추적($count)';
  }

  @override
  String get deleteAccount => '계정 삭제';

  @override
  String get deleteAccountDesc => '모든 로컬 데이터를 영구 삭제하고 앱을 재설정합니다.';

  @override
  String get deleteAccountConfirmTitle => '계정을 삭제하시겠습니까?';

  @override
  String get deleteAccountConfirmMessage =>
      '타임라인 카드, 지식 베이스, 녹음, 설정을 포함한 모든 데이터가 영구 삭제됩니다. 이 작업은 되돌릴 수 없습니다.';

  @override
  String deleteAccountTypeName(Object name) {
    return '확인하려면 \"$name\"을(를) 입력하세요';
  }

  @override
  String get deleteAccountTypeHint => '확인을 위해 사용자 이름 입력';

  @override
  String get llmConsentTitle => '데이터 공유 동의';

  @override
  String llmConsentMessage(Object provider) {
    return 'AI 기능을 활성화하려면 Memex가 처리를 위해 사용자의 데이터를 $provider에 보내야 합니다. 여기에는 다음이 포함됩니다:\n\n• 사용자가 입력한 텍스트(메모, 음성 전사)\n• 사진 메타데이터 및 추출된 텍스트(OCR)\n• 건강 및 피트니스 요약\n• 타임라인 카드 내용\n\n데이터는 사용자의 기기에서 $provider로 직접 전송됩니다. Memex는 다른 서버를 통해 데이터를 저장하거나 중계하지 않습니다.\n\n$provider가 데이터를 어떻게 처리하는지 개인정보 처리방침을 확인해 주세요.\n\nAI 처리를 위해 데이터를 $provider에 보내는 데 동의하시겠습니까?';
  }

  @override
  String get llmConsentAgree => '동의합니다';

  @override
  String get llmConsentDecline => '거부';

  @override
  String get customAgents => '사용자 지정 에이전트';

  @override
  String get noCustomAgents => '설정된 사용자 지정 에이전트가 없습니다.';

  @override
  String get deleteAgent => '에이전트 삭제';

  @override
  String deleteAgentConfirm(Object name) {
    return '사용자 지정 에이전트 \"$name\"을(를) 삭제하시겠습니까?';
  }

  @override
  String get deleted => '삭제됨';

  @override
  String get saved => '저장됨';

  @override
  String get newAgent => '새 에이전트';

  @override
  String get editAgent => '에이전트 편집';

  @override
  String get agentName => '에이전트 이름';

  @override
  String get agentNameHint => 'my-custom-agent';

  @override
  String get agentNameRequired => '필수';

  @override
  String get agentNameInvalid => '문자, 숫자, 하이픈만 허용됩니다';

  @override
  String get agentNameExists => '이름이 이미 존재합니다';

  @override
  String get hostAgentType => '호스트 에이전트 유형';

  @override
  String get skillDirectory => '스킬 디렉터리';

  @override
  String get skillDirInvalid => '상대 경로여야 합니다(앞의 / 또는 .. 불가)';

  @override
  String get workingDirectory => '작업 디렉터리(선택 사항)';

  @override
  String get workingDirectoryHint => '비워 두면 워크스페이스 기본값 사용';

  @override
  String get llmConfig => 'LLM 설정';

  @override
  String get eventType => '이벤트 유형';

  @override
  String get executionMode => '실행 모드';

  @override
  String get executionModeAsync => '비동기';

  @override
  String get executionModeSync => '동기';

  @override
  String get dependsOn => '의존 대상';

  @override
  String get dependsOnHint => '의존 항목 선택';

  @override
  String get priority => '우선순위';

  @override
  String get maxRetries => '최대 재시도';

  @override
  String get systemPromptLabel => '시스템 프롬프트(선택 사항)';

  @override
  String get systemPromptHint => '호스트 에이전트 프롬프트에 추가되는 지시';

  @override
  String get eventSerializer => '이벤트 직렬화기';

  @override
  String get eventSerializerDefault => '기본값(XML)';

  @override
  String get enabledLabel => '활성화';

  @override
  String get skillsManagement => '스킬 관리';

  @override
  String get skillsManagementEmpty => '아직 스킬이 없습니다';

  @override
  String get downloadSkill => '스킬 다운로드';

  @override
  String get downloadFile => '파일 다운로드';

  @override
  String get downloading => '다운로드 중...';

  @override
  String get downloadSuccess => '스킬을 성공적으로 다운로드했습니다';

  @override
  String downloadFailed(Object error) {
    return '다운로드 실패: $error';
  }

  @override
  String get deleteConfirm => '삭제 확인';

  @override
  String deleteConfirmMessage(String name) {
    return '\"$name\"을(를) 삭제하시겠습니까?';
  }

  @override
  String get invalidUrl => '유효한 URL을 입력해 주세요';

  @override
  String get urlHint => 'https://example.com/skill.zip';

  @override
  String get newFolder => '새 폴더';

  @override
  String get newFile => '새 파일';

  @override
  String get folderName => '폴더 이름';

  @override
  String get fileName => '파일 이름';

  @override
  String get nameRequired => '이름은 필수입니다';

  @override
  String get nameInvalid => '이름에는 / 또는 .. 을 포함할 수 없습니다';

  @override
  String createFailed(Object error) {
    return '생성 실패: $error';
  }

  @override
  String get fileContent => '파일 내용';

  @override
  String get saveSuccess => '성공적으로 저장했습니다';

  @override
  String downloadToCurrentDir(String dir) {
    return 'zip이 현재 디렉터리에 압축 해제됩니다: $dir';
  }

  @override
  String get privacyPolicy => '개인정보 처리방침';

  @override
  String get privacyPolicyDesc => 'Memex가 데이터를 처리하는 방식';

  @override
  String get llmAuthError => 'API 인증에 실패했습니다. 설정에서 LLM 설정을 확인해 주세요.';

  @override
  String get llmBadRequestError =>
      'LLM 제공업체가 요청을 거부했습니다. 현재 모델이 입력 형식을 지원하지 않을 수 있습니다.';

  @override
  String get llmRateLimitError => 'API 요청 한도를 초과했습니다. 나중에 다시 시도해 주세요.';

  @override
  String get llmServerError => 'LLM 서비스를 일시적으로 사용할 수 없습니다. 나중에 다시 시도해 주세요.';

  @override
  String get llmNetworkError => '네트워크 연결에 실패했습니다. 인터넷 연결을 확인해 주세요.';

  @override
  String get llmUnknownError => '콘텐츠 처리 중 예상치 못한 오류가 발생했습니다.';

  @override
  String get llmErrorDialogTitle => '처리 실패';

  @override
  String get goToModelConfig => '설정으로 이동';

  @override
  String get speechModelDownloadTitle => '음성 모델 다운로드';

  @override
  String speechModelDownloadDesc(Object sizeMB) {
    return '일회성 모델 다운로드(약 ${sizeMB}MB)가 필요합니다.\n\n다운로드 후 전사는 완전히 기기에서 실행됩니다.';
  }

  @override
  String get speechModelStartDownload => '다운로드 시작';

  @override
  String get speechModelChooseSource => '다운로드 소스 선택:';

  @override
  String get speechModelChinaMirror => '🇨🇳 중국 미러(중국 내 더 빠름)';

  @override
  String get speechModelGithub => '🌐 GitHub(글로벌)';

  @override
  String get speechModelDownloading => '모델 다운로드 중...';

  @override
  String get speechModelConnecting => '연결 중...';

  @override
  String get deleteSpeechModel => '음성 모델 삭제';

  @override
  String get confirmDeleteSpeechModelMessage =>
      '다운로드한 로컬 음성 인식 모델 파일을 삭제하시겠습니까? 다음에 로컬 음성-텍스트를 사용할 때 다시 다운로드됩니다.';

  @override
  String get speechModelDeletedSuccess => '음성 모델 파일을 삭제했습니다';

  @override
  String get speechModelNotDownloaded => '다운로드된 음성 모델 파일을 찾을 수 없습니다';

  @override
  String speechModelDeleteFailed(Object error) {
    return '음성 모델 파일 삭제 실패: $error';
  }

  @override
  String get speechTranscribing => '인식 중...';

  @override
  String get speechNoResult => '음성이 감지되지 않았습니다';

  @override
  String get useLocalSpeechToTextTitle => '로컬 음성-텍스트 사용';

  @override
  String get useLocalSpeechToTextDesc =>
      '활성화하면 오디오가 전송 전에 기기에서 텍스트로 변환됩니다. 오디오 입력을 지원하지 않는 모델에 유용합니다. 비활성화하면 원본 오디오가 모델로 직접 전송됩니다.';

  @override
  String get pendingAiProcessingHint => '처리할 AI 모델 설정';

  @override
  String get demoWelcome =>
      'Memex에 오신 것을 환영합니다!\nAI가 기록으로 무엇을 할 수 있는지 간단히 둘러보세요.';

  @override
  String get demoTapAdd => '여기를 눌러 첫 기록을 만드세요';

  @override
  String get demoTapSend => '첫 기록을 보내려면 탭하세요';

  @override
  String get demoTapCard => 'AI가 기록을 어떻게 정리했는지 보려면 탭하세요';

  @override
  String get demoDetailHint => 'AI가 정리한 기록 상세 화면입니다. 자유롭게 살펴본 뒤 돌아가 투어를 계속하세요.';

  @override
  String get demoTapInsight => 'AI 생성 인사이트를 보려면 탭하세요';

  @override
  String get demoTapInsightUpdate => '기록에서 인사이트를 생성하려면 탭하세요';

  @override
  String get demoTapKnowledge => '자동 정리된 지식 파일 확인';

  @override
  String get demoDone => '삶을 기록하기 시작하세요.';

  @override
  String get demoStartTour => '투어 시작';

  @override
  String get demoGetStarted => '시작하기';

  @override
  String get demoSkip => '건너뛰기';

  @override
  String get demoPrefillText => '안녕하세요 Memex! 이것은 제 첫 기록입니다 🎉';

  @override
  String get visionBadge => '비전';

  @override
  String get notMultimodalHint =>
      'Memex는 미디어 분석에 멀티모달 모델 기능을 사용합니다. 기록에 이미지가 포함되어 있다면 설정한 모델이 이미지 입력을 지원하는지 확인해 주세요.';

  @override
  String get defaultModelPrefix => '기본값';

  @override
  String get recommendedBadge => '추천';

  @override
  String get readOnlyBadge => 'CHAT';

  @override
  String get switchCompanion => '동반자 전환';

  @override
  String get personaChatInputHint => '메시지 입력...';

  @override
  String get today => '오늘';

  @override
  String get tomorrow => '내일';

  @override
  String get yesterday => '어제';

  @override
  String get showInsightTextTitle => 'Memex 인사이트 댓글 표시';

  @override
  String get showInsightTextDesc =>
      '카드 세부 댓글 섹션에서 Memex 인사이트를 고정 댓글로 표시할지 여부입니다.';

  @override
  String get enableCharacterCommentTitle => '캐릭터 자동 댓글';

  @override
  String get enableCharacterCommentDesc => '캐릭터가 새 기록에 자동으로 댓글을 남깁니다.';

  @override
  String get maxCommentCharactersTitle => '댓글 캐릭터 최대 수';

  @override
  String get maxCommentCharactersDesc => '각 기록에 댓글을 남길 수 있는 캐릭터 수입니다.';

  @override
  String replyTo(String name) {
    return '$name에게 답장';
  }

  @override
  String get cdnSignalsComments => '새 답장을 받았습니다';

  @override
  String get cdnSignalsInsight => '새 인사이트가 생성되었습니다';

  @override
  String get cdnSignalsBoth => '새 답장과 인사이트가 있습니다';

  @override
  String get untitledCard => '제목 없는 카드';

  @override
  String get locationContextTitle => '위치 컨텍스트';

  @override
  String get locationContextDescription => '에이전트 채팅을 위한 현재 도시 및 동네 컨텍스트';

  @override
  String get locationContextAttachTitle => '현재 위치를 채팅에 첨부';

  @override
  String get locationContextAttachDesc =>
      '기기 GPS와 역지오코딩을 사용해 에이전트에 도시, 구역, 동네 컨텍스트를 제공합니다.';

  @override
  String get reverseGeocodingProvider => '역지오코딩 제공업체';

  @override
  String get amapProviderName => 'Amap';

  @override
  String get amapApiKey => 'Amap API 키';

  @override
  String get amapGcj02Note => 'Amap은 GCJ-02 좌표를 사용합니다. 기기 GPS는 역지오코딩 전에 변환됩니다.';

  @override
  String get contextGranularity => '컨텍스트 세분화';

  @override
  String get granularityCity => '도시';

  @override
  String get granularityDistrict => '구역';

  @override
  String get granularityNeighborhood => '동네';

  @override
  String get granularityStreet => '거리';

  @override
  String get granularityFullAddress => '전체 주소 후보';

  @override
  String get locationFreshness => '위치 최신도';

  @override
  String minutesShort(int minutes) {
    return '$minutes분';
  }

  @override
  String get oneHour => '1시간';

  @override
  String get testCurrentLocation => '현재 위치 테스트';

  @override
  String locationTestFailed(String error) {
    return '실패: $error';
  }

  @override
  String get locationDebugGps => 'GPS';

  @override
  String get locationDebugReverseGeocode => '역지오코딩';

  @override
  String get locationDebugProvider => '제공업체';

  @override
  String get locationDebugAgentContext => '에이전트 컨텍스트';

  @override
  String get locationDebugSource => '소스';

  @override
  String get locationDebugAddressSummary => '주소 요약';

  @override
  String get locationDebugFullAddress => '전체 주소';

  @override
  String get locationDebugCoordinates => '좌표';

  @override
  String get locationDebugAccuracy => '정확도';

  @override
  String get locationDebugReason => '이유';

  @override
  String get locationDebugOk => 'OK';

  @override
  String get locationDebugUnavailable => '사용 불가';

  @override
  String get locationDebugInjected => '주입됨';

  @override
  String get locationDebugNotInjected => '주입되지 않음';

  @override
  String get locationStatusUpdatedAt => '업데이트됨';

  @override
  String get locationStatusSuccessTitle => '현재 위치가 준비되었습니다';

  @override
  String get locationStatusSuccessBody =>
      '위치 컨텍스트가 관련 있을 때 Memex가 이 위치 요약을 첨부할 수 있습니다.';

  @override
  String get locationStatusApproximateTitle => '대략적인 위치만 있음';

  @override
  String get locationStatusApproximateBody =>
      '정확도가 도시 또는 지역 수준으로 보입니다. 그대로 사용하거나 더 정확한 컨텍스트를 위해 시스템 설정에서 정확한 위치를 켤 수 있습니다.';

  @override
  String get locationStatusServiceDisabledTitle => '시스템 위치가 꺼져 있습니다';

  @override
  String get locationStatusServiceDisabledBody =>
      'Memex는 기기 GPS만 사용하며 네트워크나 IP로 위치를 추정하지 않습니다. Android에서는 위치 설정을 열고, iOS에서는 설정 > 개인정보 보호 및 보안 > 위치 서비스를 켜세요.';

  @override
  String get locationStatusPermissionDeniedTitle => '위치 권한이 필요합니다';

  @override
  String get locationStatusPermissionDeniedBody =>
      '테스트 중이거나 위치 컨텍스트가 필요할 때 Memex가 위치를 사용하도록 허용하세요. 항상 접근 권한은 요청하지 않습니다.';

  @override
  String get locationStatusPermissionForeverTitle => '위치 권한이 차단되었습니다';

  @override
  String get locationStatusPermissionForeverBody =>
      '앱 설정을 열고 Memex의 위치 사용을 허용하세요. iOS에서는 앱 사용 중 허용이면 충분합니다.';

  @override
  String get locationStatusDisabledTitle => '위치 컨텍스트가 꺼져 있습니다';

  @override
  String get locationStatusDisabledBody =>
      'Memex가 기기 위치를 에이전트 컨텍스트에 첨부하기를 원하면 위 스위치를 켜고 저장하세요.';

  @override
  String get locationStatusGeocodeUnavailableTitle =>
      'GPS는 작동하지만 주소 조회에 실패했습니다';

  @override
  String get locationStatusGeocodeUnavailableBody =>
      'Memex가 좌표는 가지고 있지만 GPS만 있는 컨텍스트는 에이전트에 주입하지 않습니다. 역지오코딩 제공업체를 확인하고 다시 시도하세요.';

  @override
  String get locationStatusUnavailableTitle => '위치를 사용할 수 없습니다';

  @override
  String get locationStatusUnavailableBody =>
      '시스템 위치 서비스와 앱 권한을 확인한 뒤 다시 테스트하세요.';

  @override
  String get allowLocationPermissionButton => '위치 권한 허용';

  @override
  String get openAppSettingsButton => '앱 설정 열기';

  @override
  String get openLocationSettingsButton => '위치 설정 열기';

  @override
  String get locationSettingsOpenFailed => '시스템 설정을 열 수 없습니다.';

  @override
  String locationActionFailed(String error) {
    return '위치 작업 실패: $error';
  }

  @override
  String get settingsSearchPlaceholder => '설정 검색...';

  @override
  String get settingsSearchEmpty => '일치하는 설정을 찾을 수 없습니다';

  @override
  String get importCharacterCard => '캐릭터 카드 가져오기';

  @override
  String get firstMessageLabel => '첫 메시지';

  @override
  String get firstMessageHint => '첫 대화에서 보내는 인사말(선택 사항)';

  @override
  String get systemPromptOverrideLabel => '시스템 프롬프트 재정의';

  @override
  String get systemPromptOverrideHint => '기본 시스템 프롬프트 재정의(고급, 선택 사항)';

  @override
  String get postHistoryInstructionsLabel => '기록 이후 지시';

  @override
  String get postHistoryInstructionsHint => '채팅 기록 뒤, 답변 전에 주입되는 지시(선택 사항)';

  @override
  String get mesExampleLabel => '메시지 예시';

  @override
  String get mesExampleHint => '캐릭터 스타일을 보여 주는 예시 대화(선택 사항)';

  @override
  String get worldBookTitle => '월드북';

  @override
  String get worldBookSubtitle => '키워드가 트리거될 때 주입되는 배경 지식';

  @override
  String get characterMemoryTitle => '캐릭터 메모리';

  @override
  String get characterMemorySubtitle => '캐릭터와 사용자 사이의 관계 역학 및 상호작용 메모리';

  @override
  String get addTooltip => '추가';

  @override
  String get constantBadge => '상시';

  @override
  String worldEntryFallbackName(Object index) {
    return '항목 $index';
  }

  @override
  String keywordsPrefix(Object keys) {
    return '키워드: $keys';
  }

  @override
  String memoryFallbackName(Object index) {
    return '메모리 $index';
  }

  @override
  String get addWorldEntry => '월드북 항목 추가';

  @override
  String get editWorldEntry => '월드북 항목 편집';

  @override
  String get commentTitleLabel => '댓글 / 제목';

  @override
  String get entryDescriptionHint => '항목 설명(선택 사항)';

  @override
  String get triggerKeywordsLabel => '트리거 키워드';

  @override
  String get triggerKeywordsHint => '쉼표로 구분, 예: magic, spell';

  @override
  String get contentLabel => '내용';

  @override
  String get worldEntryContentHint => '키워드가 트리거될 때 주입되는 배경 지식';

  @override
  String get enabledCheckbox => '활성화';

  @override
  String get addMemory => '메모리 추가';

  @override
  String get editMemory => '메모리 편집';

  @override
  String get memoryLabelField => '라벨';

  @override
  String get memoryLabelHint => '고유 식별자, 예: 호칭 선호';

  @override
  String get memoryContentHint => '메모리 내용';

  @override
  String get salienceLabel => '중요도: ';

  @override
  String get labelCannotBeEmpty => '라벨은 비워 둘 수 없습니다';

  @override
  String importSuccess(Object name) {
    return '$name을(를) 성공적으로 가져왔습니다';
  }

  @override
  String importFailed(Object error) {
    return '가져오기 실패: $error';
  }

  @override
  String get supportedFormats => '지원 형식';

  @override
  String get tavernImportDescription =>
      '• SillyTavern V2 캐릭터 카드(.json)\n• 카드가 내장된 PNG 이미지(.png)\n\n페르소나, 월드북 등의 필드는 Memex 캐릭터 형식으로 자동 매핑됩니다.';

  @override
  String get pickCharacterFile => '캐릭터 파일 선택';

  @override
  String get repickFile => '다른 파일 선택';

  @override
  String get personaSettingSection => '페르소나';

  @override
  String get systemPromptSection => '시스템 프롬프트';

  @override
  String worldEntriesCount(Object count) {
    return '월드북: 항목 $count개';
  }

  @override
  String fileLabel(Object filename) {
    return '파일: $filename';
  }

  @override
  String conflictWarning(Object names) {
    return '같은 이름의 캐릭터가 이미 존재합니다: $names. 가져오면 기존 캐릭터를 덮어쓰지 않고 새 캐릭터를 만듭니다.';
  }

  @override
  String get setPrimaryCompanionTitle => '기본 동반자로 설정';

  @override
  String get setPrimaryCompanionSubtitle => '가져온 뒤 자동으로 기본 동반자로 설정합니다';

  @override
  String get confirmImport => '가져오기 확인';

  @override
  String get chatBackground => '채팅 배경';

  @override
  String get chooseChatBackgroundImage => '배경 이미지 선택';

  @override
  String get earlyUpdateSettingsTitle => 'Early 액세스 업데이트';

  @override
  String get earlyUpdateSettingsDesc =>
      '현재 Early APK와 일치하는 GitHub 프리릴리스를 확인하고 다운로드한 뒤 Android 설치 프로그램에 전달합니다.';

  @override
  String get earlyUpdateUnsupported =>
      'Early 업데이트는 Android Early 빌드에서만 사용할 수 있습니다.';

  @override
  String get earlyUpdateAutoCheckTitle => '업데이트 자동 확인';

  @override
  String get earlyUpdateAutoCheckDesc => '시작 시 최대 12시간에 한 번 확인합니다.';

  @override
  String get earlyUpdateWifiOnlyTitle => 'Wi-Fi에서만 다운로드';

  @override
  String get earlyUpdateWifiOnlyDesc => '모바일 데이터를 사용할 때 업데이트 다운로드를 건너뜁니다.';

  @override
  String get earlyUpdateAutoInstallTitle => '자동 다운로드 및 설치';

  @override
  String get earlyUpdateAutoInstallDesc =>
      '새 빌드를 찾으면 다운로드하고 Android 설치 프로그램을 자동으로 엽니다.';

  @override
  String get earlyUpdateCheckNow => '지금 확인';

  @override
  String get earlyUpdateChecking => 'GitHub 프리릴리스 확인 중...';

  @override
  String get earlyUpdateSkippedMobile => 'Wi-Fi 전용 다운로드가 켜져 있어 건너뛰었습니다.';

  @override
  String get earlyUpdateNoUpdate => '이미 최신 Early 빌드입니다.';

  @override
  String earlyUpdateFound(Object version, Object build) {
    return 'Early 빌드 $version+$build을(를) 사용할 수 있습니다.';
  }

  @override
  String get earlyUpdateDownloadAndInstall => '다운로드 및 설치';

  @override
  String get earlyUpdateDownloadInProgress => '업데이트 다운로드 중...';

  @override
  String earlyUpdateDownloadingPercent(Object percent) {
    return '업데이트 다운로드 중: $percent%';
  }

  @override
  String get earlyUpdateDownloadReadyToInstall =>
      '업데이트 패키지가 다운로드되었습니다. 설치할 준비가 되었습니다.';

  @override
  String get earlyUpdateInstallDownloadedPackage => '다운로드한 패키지 설치';

  @override
  String get earlyUpdateClearDownloadedPackage => '다운로드한 패키지 지우기';

  @override
  String get earlyUpdateClearDownloadedPackageSuccess =>
      '다운로드한 업데이트 패키지를 지웠습니다.';

  @override
  String get earlyUpdateInstallStarted => 'Android 설치 프로그램을 열었습니다.';

  @override
  String get earlyUpdateInstallPermissionRequired =>
      'Memex가 알 수 없는 앱을 설치하도록 허용한 다음, 다운로드 및 설치를 다시 탭하세요.';

  @override
  String earlyUpdateLastChecked(Object time) {
    return '마지막 확인: $time';
  }

  @override
  String earlyUpdateCheckFailed(Object error) {
    return '업데이트 확인 실패: $error';
  }

  @override
  String get earlyUpdateDialogTitle => 'Early 업데이트 사용 가능';

  @override
  String get earlyUpdateReleaseNotes => '릴리스 노트';

  @override
  String get dismissAllNotifications => '모두 지우기';

  @override
  String get dismissByType => '유형별 지우기';

  @override
  String get dismissTypeSystemAction => '미리 알림 및 이벤트';

  @override
  String get dismissTypeClarification => '확인 요청';

  @override
  String get dismissTypeCardUpdate => '카드 업데이트';

  @override
  String dismissedCount(Object count) {
    return '$count개를 지웠습니다';
  }

  @override
  String get dataImportTitle => '파일 가져오기';

  @override
  String get dataImportSettingsDescription => '예전 파일을 Memex로 가져온 뒤 정리할지 선택하세요.';

  @override
  String get dataImportDescription =>
      '예전 노트, 내보낸 기록, 문서, ZIP 압축 파일을 선택할 수 있습니다. Memex는 먼저 복사본을 저장하고 원본 파일은 변경하지 않습니다. 가져온 뒤 Memex가 정리하도록 할지 선택할 수 있습니다.';

  @override
  String get dataImportSelectFiles => '가져올 파일 선택';

  @override
  String get dataImportImporting => '파일 저장 중...';

  @override
  String get dataImportSuccess => '파일이 Memex에 저장되었습니다';

  @override
  String get dataImportOnlyStored => '파일이 저장되었습니다. 정리는 시작하지 않았습니다.';

  @override
  String get dataImportQueued => 'Memex가 이 가져오기를 백그라운드에서 정리합니다.';

  @override
  String get dataImportResultTitle => '가져오기 완료';

  @override
  String dataImportResultSummary(Object count) {
    return '$count개 파일이 저장되었습니다. 지금 정리하거나 원본 자료로 그대로 둘 수 있습니다.';
  }

  @override
  String dataImportRenamedConflicts(Object count) {
    return '같은 이름의 항목 $count개는 덮어쓰기를 피하도록 이름을 바꿨습니다.';
  }

  @override
  String dataImportSkippedUnsafeEntries(Object count) {
    return '압축 파일 안의 특이한 항목 $count개는 건너뛰었고, 나머지는 정상적으로 가져왔습니다.';
  }

  @override
  String get dataImportChooseProcessing => '이 파일 정리하기';

  @override
  String get dataImportProcessTitle => '이번 가져오기를 정리할까요?';

  @override
  String dataImportProcessPrompt(Object count) {
    return '$count개 파일을 가져왔습니다. Memex가 지금 정리하게 할지, 원본만 보관할지 선택하세요.';
  }

  @override
  String get dataImportProcessKnowledgeBase => '지식 베이스에 정리';

  @override
  String get dataImportProcessKnowledgeBaseDesc =>
      '문서, 노트, 프로젝트 자료, 참고 자료에 적합합니다. Memex가 유용한 정보를 뽑아 나중에 쓰기 좋게 묶어 둡니다.';

  @override
  String get dataImportProcessTimelineCards => '타임라인 기록 만들기';

  @override
  String get dataImportProcessTimelineCardsDesc =>
      '일기, 채팅 기록, 활동 내역, 예전 내보내기에 적합합니다. Memex가 시간 의미가 있는 내용을 기록으로 정리합니다.';

  @override
  String get dataImportImpactNone => 'Memex는 이 원본 파일만 보관합니다. AI 정리는 시작되지 않습니다.';

  @override
  String get dataImportImpactKnowledgeBase =>
      'Memex가 이 파일을 읽고 오래 보관할 만한 정보를 지식 베이스에 정리합니다. 타임라인 기록은 먼저 만들지 않습니다.';

  @override
  String get dataImportImpactTimelineCards =>
      'Memex가 이 파일을 읽고 생활 이벤트나 날짜가 있는 기록을 타임라인 기록으로 만듭니다. 지식 베이스는 먼저 정리하지 않습니다.';

  @override
  String get dataImportImpactBoth =>
      'Memex가 타임라인 기록을 만들고 재사용할 수 있는 정보를 지식 베이스에 정리합니다. 완전한 개인 아카이브를 가져올 때 적합합니다.';

  @override
  String get dataImportFinish => '저장만 하기';

  @override
  String get noImages => '이미지 없음';

  @override
  String get noMessages => '메시지 없음';

  @override
  String get sketchContent => '스케치';

  @override
  String get emptyFolder => '빈 폴더';

  @override
  String get usernameAlreadyTaken => '이미 사용 중인 사용자 이름입니다';

  @override
  String get registrationFailed => '가입에 실패했습니다';

  @override
  String get loginFailed => '로그인에 실패했습니다';

  @override
  String get paymentCreationFailed => '결제를 시작할 수 없습니다';

  @override
  String get completePayment => '결제 완료';

  @override
  String get commentReplyToYou => '나';

  @override
  String get commentAuthorUser => '사용자';

  @override
  String get commentAuthorAi => 'AI';

  @override
  String get authorizationCancelled => '인증이 취소되었습니다';

  @override
  String timelineWeekNumberLabel(Object week) {
    return '$week주차';
  }

  @override
  String get timelineWeekLabel => '주';

  @override
  String get eventCardDefaultTitle => '이벤트';

  @override
  String get memoryNoLongTermYet => '아직 장기 기억이 없습니다.';

  @override
  String get memoryNoRecentBuffer => '버퍼에 최근 기억이 없습니다.';

  @override
  String get memoryGeneralSubject => '일반';
}
