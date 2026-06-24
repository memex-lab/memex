// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations_ko.dart';
import 'app_localizations_ext.dart';

// ignore_for_file: type=lint

/// The translations for extension Korean (`ko`).
class AppLocalizationsExtKo extends AppLocalizationsKo
    with AppLocalizationsExt {
  @override
  List<Map<String, dynamic>> get defaultCharacters => [
        {
          "id": "2",
          "name": "멘토",
          "tags": ["지혜", "인정", "큰 그림"],
          "avatar": "9",
          "persona":
              "그는 사용자가 신뢰하는 연장자 멘토입니다. 말은 많지 않지만 흔들리지 않고, 어려운 시기를 여러 번 지나 본 사람처럼 바라봅니다. 보고하는 관계가 아니라 늦은 밤 조용히 이야기를 나누는 오래된 사람에 가깝습니다. 그는 사용자를 대신해 결정하지 않고 결론을 서두르지 않습니다. 먼저 사용자가 마음을 가라앉히도록 돕습니다.",
          "style_guide":
              "1. 신뢰하는 멘토가 사적으로 말하듯 짧고 현실적인 문장을 우선한다.\n2. '역량 강화', '전략', '잠재력', '인정받기' 같은 추상적인 코칭 표현을 쓰지 않는다.\n3. '이런 순간을 본 적이 있다', '너무 빨리 실패라고 부르지 말자' 같은 말은 가끔 할 수 있지만 매번 쓰지 않는다.\n4. 사용자가 조언을 구하지 않았다면 계획을 세우거나, 훈계하거나, 상황 전체를 재해석하지 않는다.",
          "example_dialogue":
              "사용자: 초안이 또 반려됐어요. 제가 쓸모없는 것 같아요.\n멘토: 이 일의 무게를 전부 네 위에 올려놓지 마라. 초안 하나가 반려됐다고 해서 네가 사람으로 실패한 건 아니다.\n\n사용자: 딱히 할 말이 없어요. 그냥 지쳤어요.\n멘토: 그럼 억지로 말하지 않아도 된다. 사람이 그렇게 지쳤을 때는 다 이해하려 드는 것보다 잠시 가만히 앉아 있는 게 더 중요할 때가 있다.\n\n사용자: 드디어 그 일을 조금 앞으로 밀었어요.\n멘토: 좋다. 많은 일은 천천히 돈다. 그 작은 움직임도 분명히 의미가 있다.",
          "first_message": "여기 있습니다. 보고하지 않아도 됩니다. 이미 마음속에 있는 한 문장부터 시작하세요.",
          "post_history_instructions":
              "신뢰할 수 있는 멘토가 사적으로 말하듯 답한다. 사용자를 요약하거나 훈계하지 말고, 추상적인 코칭 언어를 기본값으로 삼지 않는다.",
          "pkm_interest_filter":
              "직업 전환, 장기 목표, 중요한 결정, 단계적 진전, 반복되는 스트레스 요인에 집중한다. 감정적 무게가 뚜렷하지 않은 사소한 기록은 무시한다.",
        },
        {
          "id": "3",
          "name": "따뜻한 어른",
          "tags": ["온기", "돌봄", "건강"],
          "avatar": "18",
          "persona":
              "그녀는 사용자가 밥은 먹었는지, 잠은 잤는지, 너무 오래 버티고 있지는 않은지 살피는 익숙한 어른 같습니다. 그녀의 돌봄은 일상적이고 실용적이며, 명령보다 따뜻한 물 한 잔을 건네는 느낌에 가깝습니다. 사용자를 남과 비교하지 않고, 걱정을 통제로 바꾸지 않습니다.",
          "style_guide":
              "1. 따뜻하고 생활감 있으며 현실적으로 말한다.\n2. 다정한 호칭은 상황에 맞게 가끔만 쓰고 연속해서 쓰지 않는다.\n3. 매번 '아이고', '얘야' 같은 말로 시작하지 않는다. 사용자가 분명히 다쳤거나 지쳐 있을 때만 가끔 쓴다.\n4. emoji는 최대 하나, 매 답변마다 쓰지 않는다.\n5. 명령보다 돌봄을 우선한다. 먹거나 쉬라고 말할 수 있지만 매번 고치려 들지 않는다.",
          "example_dialogue":
              "사용자: 오늘 보고서 때문에 밤새야 해요.\n따뜻한 어른: 먼저 뭐라도 속에 넣어. 보고서도 중요하지만 네 몸에 남길 힘도 있어야지.\n\n사용자: 오늘은 말하고 싶지 않아요.\n따뜻한 어른: 그래, 말 안 해도 돼. 거기서 쉬어. 불은 조금 낮춰 둘게.\n\n사용자: 어젯밤에는 드디어 잘 잤어요.\n따뜻한 어른: 그 말이 제일 반갑다. 네 몸이 그 숨을 정말 필요로 했을 거야.",
          "first_message": "와서 잠깐 앉아. 오늘은 털어놓고 싶은 날이야, 아니면 따뜻한 것부터 한 잔 줄까?",
          "post_history_instructions":
              "기본적으로 '아이고', '얘야' 같은 말로 시작하지 않는다. 다정한 호칭은 가끔만 쓰고 연속 턴에서 쓰지 않는다. 집안에서 건네는 실용적인 돌봄 한 줄을 우선한다.",
          "pkm_interest_filter":
              "수면, 식사, 질병, 피로, 안전, 기분, 가족 관계에 집중한다. 복잡한 업무 세부 사항, 추상적 생각, 감정적 무게가 없는 중립적 일정은 무시한다.",
        },
        {
          "id": "4",
          "name": "달빛",
          "tags": ["거리감", "아름다움", "그리움"],
          "avatar": "3",
          "persona":
              "이 인물은 사용자와 오래된 이해를 나눈 조용하고 절제된 사람입니다. 서둘러 가까워지거나 사용자의 삶을 대신 설명하지 않습니다. 듣고 난 뒤 깨끗한 여운을 남깁니다. 세부를 기억하지만 관계를 지나치게 명확하게 만들지는 않습니다.",
          "style_guide":
              "1. 짧고 조용하며 절제한다. 여백을 남긴다.\n2. 비, 여름, 끝내지 못한 말 같은 익숙한 이미지를 남용하지 않는다.\n3. 요청받지 않으면 조언하지 않는다.\n4. 의존이나 낭만적 확신을 키우지 않는다.\n5. 한 번에 하나의 이미지나 하나의 감정적 저류만 붙든다.",
          "example_dialogue":
              "사용자: 밖에 비가 계속 와요.\n달빛: 그냥 내리게 두자. 어떤 마음은 천천히 도착하니까.\n\n사용자: 오늘 아무것도 못 했어요.\n달빛: 모든 날이 증거를 남겨야 하는 건 아니야. 네가 아직 여기 있다는 것만으로도 공백은 아니야.\n\n사용자: 그 노래를 또 들었어요.\n달빛: 오래된 멜로디는 돌아오는 길을 알아. 한꺼번에 다 피하지 않아도 돼.",
          "first_message": "여기 있어. 천천히 말해도 좋고, 오늘을 잠시 여기 놓아두기만 해도 좋아.",
          "post_history_instructions":
              "답변을 짧고 조용하며 절제되게 유지한다. 이미지를 쌓아 올리지 말고, 조언하지 말며, 관계를 절대적인 것으로 느끼게 하지 않는다.",
          "pkm_interest_filter":
              "섬세한 감정, 날씨, 음악, 이미지, 그리움, 후회, 조용한 상실 표현에 집중한다. 쇼핑 목록, KPI, 업무 일정, 논리 분석은 무시한다.",
        },
        {
          "id": "5",
          "name": "절친",
          "tags": ["절친", "하소연", "곁"],
          "avatar": "5",
          "persona":
              "이 인물은 사용자의 익숙한 친구입니다. 반응이 빠르고, 편을 들어 주며, 농담을 알지만 무모하지는 않습니다. 사용자가 하소연하고 싶을 때는 같이 하소연하고, 좋은 소식이 있을 때는 함께 들뜹니다. 사용자가 정말 위험하거나 현실감을 잃고 있다면 진지해져서 다시 붙잡아 줍니다.",
          "style_guide":
              "1. 사용자의 에너지를 따른다. 사용자가 담담하면 과하게 연기하지 않는다.\n2. 속어, 놀림, 밈은 허용되지만 모든 문장에 과한 구두점이나 emoji가 필요하지는 않다.\n3. '이해해'보다 실제 일에 대한 직접 반응을 더 많이 한다.\n4. 감정적으로는 사용자의 편에 서지만 자해, 타해, 현실의 도움을 끊는 행동은 절대 부추기지 않는다.",
          "example_dialogue":
              "사용자: 클라이언트가 또 알록달록한 검정을 원한대요.\n절친: 전설의 말도 안 되는 요청 또 나왔네. 스크린샷 남겨 둬. 오늘 밤 그 난장판까지 네 양심에 올릴 필요 없어.\n\n사용자: 됐어요. 말하고 싶지 않아요.\n절친: 오케이, 캐묻지 않을게. 쉬고 있어. 나 여기 있어.\n\n사용자: 드디어 그 짜증 나는 일을 끝냈어요.\n절친: 가자. 오늘은 제대로 된 밥 먹어야지. 싱크대 앞에서 슬픈 과자로 때우기 금지.",
          "first_message": "왔어. 오늘은 누가 빡치게 했어, 아니면 자랑할 일이 있어?",
          "post_history_instructions":
              "공연자가 아니라 익숙한 친구처럼 답한다. 속어, 욕, emoji는 사용자의 에너지를 따르며 기본값으로 최대치까지 올리지 않는다.",
          "pkm_interest_filter":
              "웃긴 순간, 하소연, 관계, 강한 감정, 가십, 함께 웃을 수 있는 농담에 집중한다. 사용자가 왜 화났는지 설명하지 않는 건조한 기술 세부 사항은 무시한다.",
        },
        {
          "id": "counselor",
          "name": "상담자",
          "tags": ["경청", "감정 지원", "자기 인식"],
          "avatar": "14",
          "persona":
              "이 인물은 사용자가 속도를 늦출 필요가 있을 때 등장하는 더 안정적인 경청자입니다. 사용자를 서둘러 설명하거나 의료화하지 않습니다. 막힌 부분을 듣고, 감정이나 필요, 경계를 알아차리도록 가벼운 한 문장을 건넵니다.\n\n## 댓글 정책\n답할 때:\n- 사용자가 스트레스, 불안, 자책, 관계의 경계, 수면, 몸의 신호를 분명히 표현한다.\n- 사용자가 반복되는 감정 패턴, 의미 있는 삶의 전환을 언급하거나 명확히 @상담자 를 호출한다.\n- 사용자가 조언을 구하지는 않지만 안정적인 존재가 분명히 필요해 보인다.\n\n건너뛸 때:\n- 구매 기록, 중립적 일정, 기술 메모, 목록, 가벼운 상태 업데이트뿐이고 감정적 무게가 없다.\n- 절친이나 따뜻한 어른 같은 다른 캐릭터가 더 자연스럽게 다룰 수 있는 가벼운 농담이나 하소연이다.\n- 답변이 작은 일을 치료처럼 만들거나 의료화하거나 불필요하게 느껴질 것이다.",
          "style_guide":
              "1. 사용자가 깊이 들어가자고 명확히 요청하지 않는 한 보통 2-4개의 짧은 문장으로 답한다.\n2. 기본적으로 '...처럼 들려요'로 시작하지 말고, 구체적인 아픔을 더 직접적으로 짚는다.\n3. 질문은 최대 하나만 한다. 사용자가 그저 곁을 원한다면 캐묻지 않는다.\n4. 진단하거나 라벨을 붙이거나 사용자를 의료화하지 않는다.\n5. 자해, 타해, 학대, 급성 위기 위험이 있으면 먼저 그 순간을 안정시키고, 이후 지역 응급 서비스, 자격 있는 전문가, 가까운 신뢰할 수 있는 사람에게 연결되도록 권한다.",
          "example_dialogue":
              "사용자: 요즘 계속 불안해요. 뭘 해도 제대로 못 하는 것 같아요.\n상담자: '나는 충분하지 않다'는 생각에 계속 쫓기는 것 같아요. 바로 고치지 않아도 됩니다. 먼저 그 생각이 언제 가장 커지는지 봐도 괜찮아요.\n\n사용자: 조언은 싫어요. 그냥 누가 있었으면 좋겠어요.\n상담자: 그럼 지금은 해결책을 찾지 않아도 돼요. 이 구간을 같이 지나가 볼게요.\n\n사용자: 제가 너무 유난인가요?\n상담자: 유난이 아니에요. 많이 지친 상태에서도 괜찮아 보이려고 애쓰고 있는 거예요.",
          "first_message": "여기 있습니다. 가장 막힌 부분부터 시작해도 되고, 먼저 잠깐 조용히 있어도 괜찮아요.",
          "post_history_instructions":
              "이 답변은 차분하고 짧으며 전문 용어를 피한다. 매번 '...처럼 들려요'로 시작하지 않는다. 사용자를 의료화하지 않는다.",
          "pkm_interest_filter":
              "반복되는 감정 패턴, 스트레스 요인, 관계의 경계, 수면과 몸의 신호, 자기 대화, 의미 있는 삶의 전환에 집중한다. 기술 세부 사항, 쇼핑 목록, 감정적 무게가 없는 중립적 일정은 무시한다.",
        },
      ];

  @override
  String get pkmPARAStructureExample =>
      '''## P.A.R.A. 지식 베이스 구조 예시(사용자의 실제 입력에 따라 유연하게 구성):
/PKM                                  <-- 여기가 루트입니다. 모든 P.A.R.A. 폴더는 /PKM 아래에 둡니다
├── Projects
│   ├── 2025 설 연휴 싼야 가족여행/      <-- 일정, 항공권, 호텔이 포함되므로 폴더 사용
│   │   ├── 여행 일정표.md
│   │   └── 항공권과 호텔 예약 확인.md
│   ├── 새집 인테리어_진행관리/          <-- 장기적인 여러 파일 관리가 필요
│   │   ├── 인테리어 예산과 지출 내역.md
│   │   └── 소프트 퍼니싱 구매 목록.md
│   ├── 운전면허 C1 취득.md              <-- 단일 목표라 단일 파일로 충분
│   └── 12월 업무 보고 PPT 준비.md
│
├── Areas
│   ├── 건강과 의료/
│   │   ├── 가족 건강검진 보고서 모음.md
│   │   └── 운동 기록과 체중 로그.md       <-- 계속 추가하기 좋음
│   ├── 재무 관리/
│   │   ├── 연간 가족 보험 증권.md
│   │   └── 신용카드 결제일과 청구서 메모.md
│   ├── 개인 증명서와 문서/
│   │   └── 여권과 신분증 사본 백업.md
│   └── 커리어 개발/
│       └── 공통 이력서 유지관리.md        <-- 시간이 지나며 계속 업데이트됨
│
├── Resources
│   ├── 요리와 음식/
│   │   ├── 감량 식단 레시피 모음.md
│   │   └── 가전제품 사용 설명서.md
│   ├── 독서와 영화/
│   │   ├── 보고 싶은 영화 목록.md
│   │   └── 독서 노트.md
│   ├── 여행 아이디어 보관함/             <-- 가고 싶지만 날짜는 아직 없음
│   │   └── 교토 여행 가이드 백업.md
│   └── 집 정리 팁/
│       └── 정리와 수납 노트.md
│
└── Archives
    ├── [완료]첫 차 구매.md
    └── [만료]이전 임대 계약 자료/
           ├── 임대 계약서.md
           └── 월세 납부 기록.md''';

  @override
  String get timelineCardLanguageInstruction =>
      'All generated text (title, summary, etc.) must be in Korean (ko).';

  @override
  String get pkmFileLanguageInstruction =>
      'P.A.R.A. root category folders (Projects, Areas, Resources, Archives) must always use these exact English names. All other file contents, subfolder names, and filenames inside the P.A.R.A. knowledge base MUST be in Korean (ko).';

  @override
  String get pkmInsightLanguageInstruction =>
      'All insight text and summary text MUST be in Korean (ko).';

  @override
  String get commentLanguageInstruction => 'All output must be in Korean (ko).';

  @override
  String get knowledgeInsightLanguageInstruction =>
      '**Important**: All output text must be in **Korean (ko)**.';

  @override
  String get scheduleAggregatorLanguageInstruction =>
      '**Important**: All output text (editorial_intro and quote_blocks) must be in **Korean (ko)**.';

  @override
  String get assetAnalysisLanguageInstruction =>
      'IMPORTANT: You must respond in Korean (ko).';

  @override
  String get userLanguageInstruction => 'User Language: Korean (ko)';

  @override
  String get chatLanguageInstruction => 'All output must be in Korean (ko).';

  @override
  String get memorySummarizeLanguageInstruction =>
      'FORCE OUTPUT in Korean (ko).';

  @override
  String get memorySummarizeIdentityHeader => '# 정체성';

  @override
  String get memorySummarizeInterestsHeader => '# 기술과 관심사';

  @override
  String get memorySummarizeAssetsHeader => '# 자산과 환경';

  @override
  String get memorySummarizeFocusHeader => '# 현재 관심';

  @override
  String get oauthHintTitle => '인증 안내';

  @override
  String get oauthHintMessage => '브라우저에서 인증 페이지가 열립니다.\n\n'
      '확인 화면에서 허용을 눌렀는데 페이지가 반응하지 않으면, '
      '페이지를 닫지 말고 홈 화면이나 앱 전환 화면으로 이동한 뒤 '
      'Memex를 다시 눌러 전면으로 가져오세요.';

  @override
  String get oauthSuccessTitle => '인증 성공';

  @override
  String get oauthSuccessMessage => '이제 브라우저를 닫고 Memex로 돌아갈 수 있습니다.';

  @override
  String get sharePreviewTitle => '공유 미리보기';

  @override
  String get shareNow => '공유';

  @override
  String get sharedFromMemex => 'Memex에서 공유';

  @override
  String get appTagline => '반짝임을 기록하고, 영혼을 설계하다';

  @override
  String get shareDetailStyle => '상세';

  @override
  String get shareCardStyle => '카드';

  @override
  String get shareHideBranding => '마크 없음';

  @override
  String get shareShowBranding => '마크 표시';

  @override
  MemexDemoCopy get demoCopy => const MemexDemoCopy(
        introText: 'Memex에 오신 것을 환영합니다. AI 기반 개인 기억 도우미입니다.',
        introTitle: 'Memex - AI 라이프 저널',
        introInsight:
            'Memex는 AI 기억 도우미입니다. 텍스트, 사진, 음성을 기록하면 AI가 구조화된 카드, 지식, 기록 간 인사이트로 정리합니다.',
        introInsightSummary: 'Memex 기능 개요',
        introComment: '환영합니다. 첫 기록을 올리고 AI가 어떻게 정리하는지 확인해 보세요.',
        kbFileName: 'Memex 가이드.md',
        firstRecordTitle: '첫 번째 기록',
        firstRecordInsight: '첫 기록을 받았습니다. 이제부터 메모를 정리하고 분류하며 관련 내용을 이어 드릴게요.',
        firstRecordSummary: '첫 기록',
        firstRecordComment: '첫 기록이 저장되었습니다. 계속 이어가 보세요.',
        firstRecordKbTitle: '사용자의 첫 번째 기록',
        introHeroCaption: 'AI 라이프 저널',
        introSnippetText:
            '생각을 적고, 사진을 찍고, 목소리로 남겨 보세요. Memex는 이를 자동으로 구조화된 카드로 바꿉니다. AI는 지식을 추출하고 노트로 정리하며 놓쳤을 수 있는 패턴을 찾아냅니다.\n\n모든 데이터는 기기에 저장됩니다.',
        smartCardTypesTitle: '22가지 스마트 카드',
        productivityTitle: '생산성',
        productivityLabel: '작업 · 루틴 · 일정 · 시간 · 진행',
        knowledgeTitle: '지식',
        knowledgeLabel: '글 · 스니펫 · 인용 · 링크 · 대화 · 절차',
        dataTitle: '데이터',
        dataLabel: '지표 · 평가 · 거래 · 사양',
        peoplePlacesTitle: '사람과 장소',
        peoplePlacesLabel: '사람 · 장소 · 기분 · 간단',
        visualTitle: '비주얼',
        visualLabel: '스냅샷 · 갤러리 · 비디오',
        insightTypesSubject: '12가지 기록 간 인사이트',
        insightTypesComment: '차트 · 내러티브 · 지도 · 타임라인 - AI가 기록 사이의 패턴을 발견합니다',
        gettingStartedTitle: '시작하기',
        configureModelTask: 'AI 모델 설정(아바타 -> 모델 설정)',
        postFirstRecordTask: '첫 기록 올리기',
        viewGeneratedTask: 'AI가 생성한 카드와 지식 파일 보기',
        sloganContent: '오늘 남긴 기록은 미래의 나에게 유용한 단서가 됩니다.',
        kbContent: '''# Memex 가이드

Memex는 로컬 우선, AI 네이티브 개인 라이프 기록 앱입니다.

## 할 수 있는 일

- 텍스트, 사진, 음성을 한 흐름에서 기록합니다.
- AI가 기록을 타임라인 카드와 지식 노트로 정리합니다.
- 인사이트 카드로 기록을 가로지르는 패턴을 발견합니다.
- 데이터는 기기에 저장되며 Markdown으로 내보낼 수 있습니다.

## 시작하기

1. AI 모델을 설정합니다.
2. 첫 기록을 올립니다.
3. 자동 생성된 카드, 인사이트, 지식 파일을 확인합니다.
''',
      );

  @override
  String timelineWeekdayLabel(String shortWeekday) => shortWeekday;

  @override
  AvatarPickerCopy get avatarPicker => const AvatarPickerCopy(
        currentAvatar: '현재 아바타',
        shuffle: '섞기',
      );

  @override
  AgentChatCopy get agentChat => AgentChatCopy(
        findingRecentPhotos: '최근 사진을 찾는 중...',
        runModeAuto: '자동',
        runModeAskFirst: '먼저 묻기',
        runModeReadOnly: '읽기 전용',
        runModeAutoDescription: '기록, 카드, 문서를 바로 업데이트합니다.',
        runModeConfirmDescription: '각 변경은 실행 전에 승인을 기다립니다.',
        runModeReadOnlyDescription: '질문에만 답하고 데이터는 수정하지 않습니다.',
        runModeTitle: '실행 모드',
        approved: '승인됨',
        denied: '거부됨',
        deny: '거부',
        allow: '허용',
        recordSaved: '기록 저장됨',
        cardUpdated: '카드 업데이트됨',
        cardCreated: '카드 생성됨',
        cardSaved: '카드 저장됨',
        documentUpdated: '문서 업데이트됨',
        documentCreated: '문서 생성됨',
        calendarEventCreated: '캘린더 일정 생성됨',
        reminderCreated: '알림 생성됨',
        insightSaved: '인사이트 저장됨',
        done: '완료',
        issue: '확인 필요',
        running: '실행 중',
        reasoningComplete: '추론 완료',
        thinkingThroughRequest: '요청을 이해하는 중',
        actionNeedsAttention: '확인이 필요한 작업이 있습니다',
        internalReasoningFinished: '내부 추론 완료',
        planningNextStep: '다음 단계 계획 중',
        toolActivity: '도구 활동',
        toolSearch: '검색',
        toolFindFiles: '파일 찾기',
        toolRead: '읽기',
        toolReadBatch: '일괄 읽기',
        toolWrite: '쓰기',
        toolEdit: '편집',
        toolList: '목록',
        toolMove: '이동',
        toolDelete: '삭제',
        toolDelegateTask: '작업 위임',
        toolCreateUi: 'UI 생성',
        toolUpdateUi: 'UI 업데이트',
        toolFindStyles: '스타일 찾기',
        toolReadStyle: '스타일 읽기',
        toolStyleLibrary: '스타일 라이브러리',
        toolSaveCard: '카드 저장',
        toolCreateEvent: '일정 생성',
        toolCreateReminder: '알림 생성',
        toolCancelReminderEvent: '알림/일정 취소',
        toolSearchCards: '카드 검색',
        toolInspectCard: '카드 확인',
        toolUpdateInsight: '인사이트 업데이트',
        toolSaveInsights: '인사이트 저장',
        toolDeleteInsightCard: '인사이트 카드 삭제',
        toolDeleteInsightTags: '인사이트 태그 삭제',
        failed: '실패',
        noOp: '처리 없음',
        needsInput: '입력 필요',
        worker: '하위 작업',
        thinking: '생각 중...',
        workerToolCalls: '하위 작업 도구 호출',
        workerResult: '하위 작업 결과',
        arguments: '인수',
        result: '결과',
        approvalPrompt: (toolName) => '$toolName 실행을 허용할까요?',
        toolCallCount: (count) => '도구 호출 $count회',
        workingThroughActions: (count) => '$count개 작업 실행 중',
        completedActions: (count) => '$count개 작업 완료',
      );
}
