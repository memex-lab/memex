import 'template_gallery_models.dart';

const timelineTemplateGallerySectionsKo = [
  TemplateGallerySection(
    title: '일반적인',
    items: [
      TemplateGalleryItem(
        label: '1. 클래식 카드 (텍스트 노트)',
        templateId: 'classic_card',
        title: '메모 읽기',
        data: {
          'content':
              '오늘 카페에서 "생각하기, 빠르고 느리게" 3장을 마쳤습니다. 앵커링 효과에 대한 예는 인상적이었으며 첫 번째 정보가 이후의 모든 결정에 어떻게 조용히 편향될 수 있는지 상기시켜주었습니다.',
          'tags': ['독서', '심리학'],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: '텍스트',
    items: [
      TemplateGalleryItem(
        label: '2. 스니펫 카드(텍스트 스니펫)',
        templateId: 'snippet',
        title: '기술 견적',
        data: {
          'text':
              '**“충분히 발전된 기술은 마법과 구별할 수 없습니다.”**\n\n— Arthur C. Clarke',
          'style': 'default',
          'tags': ['인용하다', '기술', '미래'],
        },
      ),
      TemplateGalleryItem(
        label: '3. 기사 카드(긴 기사)',
        templateId: 'article',
        title: '플로우 경험이란 무엇인가',
        data: {
          'body':
              '## 흐름이란 무엇인가요?\n\n흐름은 Mihaly Csikszentmihalyi가 제안한 심리적 상태입니다. 도전적이지만 달성 가능한 작업에 완전히 몰입하면 시간 가는 줄 모르고 주의가 완전히 집중됩니다. 이것이 바로 흐름입니다.\n\n> 사람들은 진정으로 즐기는 일을 할 때 자신을 잊어버리는 경우가 많습니다.\n\n연구에 따르면 흐름 상태에 있는 사람들은 일반적으로 가장 생산적이며 가장 행복하다고 느낍니다.',
        },
      ),
      TemplateGalleryItem(
        label: '4. 대화카드(대화)',
        templateId: 'conversation',
        title: 'AI와의 대화',
        data: {
          'messages': [
            {
              'sender': 'AI 어시스턴트',
              'text':
                  '오늘 꽤 생산적이셨어요! 당신은 무엇을 했나요?',
              'isMe': false,
            },
            {
              'sender': 'me',
              'text':
                  '아키텍처 설계 및 코드 검토를 완료했습니다. 기분이 좋아요.',
              'isMe': true,
            },
            {
              'sender': 'AI 어시스턴트',
              'text':
                  '엄청난! 내일 중요한 회의가 있으니 오늘 밤 일찍 쉬세요.',
              'isMe': false,
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '5. 견적카드(견적)',
        templateId: 'quote',
        title: '오늘의 명언',
        data: {
          'content':
              '완벽한 순간을 기다리지 마십시오. 행동하고, 행동을 통해 순간이 완벽해지도록 하세요.',
          'author': 'Napoleon Hill',
          'source': '생각하고 부자가 되자',
        },
      ),
      TemplateGalleryItem(
        label: '6. 컴팩트 카드(컴팩트 행)',
        templateId: 'compact_card',
        title: '💧 수분 섭취',
        wrapped: true,
        data: {
          'details': ['500ml', '컵 4', '오늘의 목표 2000ml'],
          'color': '#3B82F6',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: '시각적',
    items: [
      TemplateGalleryItem(
        label: '7. 스냅샷 카드(사진)',
        templateId: 'snapshot',
        title: '황혼의 순간',
        data: {
          'image_url': 'https://picsum.photos/600/400?random=30',
          'location': '와이탄 · 상하이',
        },
      ),
      TemplateGalleryItem(
        label: '8. 갤러리 카드(앨범)',
        templateId: 'gallery',
        title: '주말 캠핑',
        data: {
          'image_urls': [
            'https://picsum.photos/400/400?random=31',
            'https://picsum.photos/400/400?random=32',
            'https://picsum.photos/400/400?random=33',
          ],
        },
      ),
      TemplateGalleryItem(
        label: '9. 비디오 카드(비디오)',
        templateId: 'video',
        title: '영상기록',
        data: {
          'video_url':
              'https://ai-video.weshop.ai/video/91f4255d-6c43-4608-b5e6-d39ed7890ccb_20260210.mp4',
          'duration': '00:30',
        },
      ),
      TemplateGalleryItem(
        label: '10. 캔버스 카드 (캔버스)',
        templateId: 'canvas',
        title: '마인드맵 초안',
        data: {},
      ),
    ],
  ),
  TemplateGallerySection(
    title: '정량화 가능',
    items: [
      TemplateGalleryItem(
        label: '11. 메트릭 카드(메트릭)',
        templateId: 'metric',
        title: '건강 지표',
        data: {
          'items': [
            {
              'title': '혼수',
              'value': 2.5,
              'unit': 'h',
              'label': '어젯밤',
              'trend': 'up',
              'color': 'indigo',
            },
            {
              'title': '단계',
              'value': 8342,
              'unit': 'steps',
              'label': '오늘',
              'trend': 'up',
              'color': 'emerald',
            },
            {
              'title': '심박수',
              'value': 72,
              'unit': 'bpm',
              'label': '휴식',
              'trend': 'neutral',
              'color': 'orange',
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '12. 등급 카드(등급)',
        templateId: 'rating',
        title: '영화 등급',
        data: {
          'subject': 'Interstellar',
          'score': 4.5,
          'max_score': 5.0,
          'comment':
              '숨막히는 영상미와 시간과 사랑에 대한 철학적 해석은 시청 후에도 오랫동안 여운을 남깁니다.',
        },
      ),
      TemplateGalleryItem(
        label: '13. 기분카드(Mood)',
        templateId: 'mood',
        title: '오늘의 기분',
        data: {
          'mood_name': 'Excited',
          'intensity': 8,
          'trigger': '새로운 프로젝트가 시작되었고 팀은 의욕이 넘쳤습니다.',
        },
      ),
      TemplateGalleryItem(
        label: '14. 진행 카드(진행)',
        templateId: 'progress',
        title: '연간 목표 진행 상황',
        data: {
          'label': '연간 독서 계획',
          'current': 18.0,
          'total': 52.0,
          'unit': 'books',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: '일시적인',
    items: [
      TemplateGalleryItem(
        label: '15. 이벤트 카드(이벤트)',
        templateId: 'event',
        title: 'AI상품평론회',
        data: {
          'start_time': '2026-03-10T14:00:00',
          'end_time': '2026-03-10T16:00:00',
          'location': '빌딩 A, 기술 공원, 푸동 신구, 상하이',
        },
      ),
      TemplateGalleryItem(
        label: '16. 기간 카드(타이머)',
        templateId: 'duration',
        title: '뽀모도로 타이머',
        data: {
          'elapsed': 1500,
          'remaining': 1500,
          'is_running': false,
        },
      ),
      TemplateGalleryItem(
        label: '17. 태스크 카드(과제)',
        templateId: 'task',
        title: '완전한 제품 요구사항 분석',
        data: {
          'is_completed': false,
          'priority': 'high',
          'subtasks': [
            {'title': '경쟁 분석 보고서', 'completed': true},
            {'title': '사용자 인터뷰 종합', 'completed': true},
            {'title': '요구사항 문서의 첫 번째 초안', 'completed': false},
            {'title': 'PRD 검토 회의', 'completed': false},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '18. 루틴 카드(습관 추적기)',
        templateId: 'routine',
        title: '매일의 명상',
        data: {
          'habit_name': '매일 10분 명상',
          'streak': 14,
          'history': [true, true, false, true, true, true, true],
        },
      ),
      TemplateGalleryItem(
        label: '19. Procedure Card (Steps)',
        templateId: 'procedure',
        title: 'Butter cookie recipe',
        data: {
          'steps': [
            '준비물: 박력분 200g, 계란 3개, 버터 100g',
            '오븐을 175°C로 예열하세요',
            '혼합물이 창백해질 때까지 버터와 설탕을 크림화하세요',
            '계란을 하나씩 넣고 잘 섞어주세요',
            '밀가루를 체에 쳐서 넣고 섞일 때까지 접으세요',
            '오븐에 25분간 굽는다',
          ],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: '엔터티',
    items: [
      TemplateGalleryItem(
        label: '20. 개인카드(Person)',
        templateId: 'person',
        title: '연락하다',
        data: {
          'name': 'Alex Zhang',
          'relation': '제품 관리자',
          'status': 'online',
        },
      ),
      TemplateGalleryItem(
        label: '21. 장소 카드(장소)',
        templateId: 'place',
        title: '좋아하는 서점',
        data: {
          'name': '츠타야 서점 · 정안사',
          'address': '400 Taixing Rd, Jing\'an District, 상하이',
          'lat': 31.2304,
          'lng': 121.4537,
        },
      ),
      TemplateGalleryItem(
        label: '22. 사양서(제품 사양)',
        templateId: 'spec_sheet',
        title: '애플워치 시리즈 9',
        data: {
          'subtitle': '스마트워치',
          'specs': {
            '표시하다': '1.9" AMOLED',
            '배터리': '5일의 배터리 수명',
            '방수': 'IP68',
            '무게': '32g',
            '칩': 'Apple S9',
            '크기': '45mm',
          },
        },
      ),
      TemplateGalleryItem(
        label: '23. 거래카드(지출)',
        templateId: 'transaction',
        title: '점심 지출',
        data: {
          'merchant': '후통 누들 하우스',
          'amount': '¥ 68.00',
          'location': '베이징 구러우 거리',
          'items': [
            {'name': '시그니처 자강몐(대)', 'amount': '¥ 38'},
            {'name': '절인 계란', 'amount': '¥ 8'},
            {'name': '차가운 베이징 요거트', 'amount': '¥ 22'},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '24. 링크카드(링크)',
        templateId: 'link',
        title: 'Flutter 문서',
        data: {
          'url': 'https://flutter.dev/docs',
          'domain': 'flutter.dev',
        },
      ),
    ],
  ),
];

const insightTemplateGalleryItemsKo = [
  TemplateGalleryItem(
    label: '1. 타임라인 카드(오늘의 타임라인)',
    templateId: 'timeline_card_v1',
    data: {
      'title': '오늘의 타임라인',
      'items': [
        {
          'time': '09:00',
          'title': '심층 작업',
          'content':
              '아키텍처 다이어그램 v2.0을 완료하고 세 가지 중요한 버그를 수정했습니다.',
          'icon': '💻',
          'color': '#6366F1',
          'is_filled_dot': false,
        },
        {
          'time': '12:30',
          'title': '점심 및 휴식',
          'content': '가벼운 샐러드를 먹고 20분 정도 산책을 합니다.',
          'icon': '🥗',
          'color': '#10B981',
          'is_filled_dot': false,
        },
        {
          'time': '14:00',
          'content': '채워지려고...',
          'is_filled_dot': true,
          'color': '#CBD5E1'
        },
      ],
    },
  ),
  TemplateGalleryItem(
    label: '2. 버블차트(키워드 버블)',
    templateId: 'bubble_chart_card_v1',
    data: {
      'title': '이번주 키워드',
      'bubbles': [
        {
          'label': 'Flutter',
          'value': 100,
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Dart', 'value': 80, 'color': '#8B5CF6'},
        {'label': 'AI', 'value': 60, 'color': '#EC4899'},
        {'label': '설계', 'value': 40, 'color': '#10B981'},
        {'label': 'Memex', 'value': 90, 'color': '#F59E0B'},
      ],
      'footer': '42개의 노트를 기반으로 한 분석',
    },
  ),
  TemplateGalleryItem(
    label: '3. 추세선(추세 차트)',
    templateId: 'trend_chart_card_v1',
    data: {
      'title': '기분 지수(지난 7일)',
      'top_right_text': '평균: 7.2',
      'points': [
        {'label': '화', 'value': 3.5},
        {'label': '수요일', 'value': 4.0},
        {'label': '목', 'value': 5.5},
        {'label': '금', 'value': 8.5, 'is_highlight': true},
        {'label': '앉았다', 'value': 7.0},
        {'label': '해', 'value': 6.5},
        {'label': '월', 'value': 7.5},
      ],
      'highlight_info': {'title': '8.5점', 'subtitle': '금요일 하이라이트'},
      'color': '#6366F1',
    },
  ),
  TemplateGalleryItem(
    label: '4. 막대 차트(막대 비교)',
    templateId: 'bar_chart_card_v1',
    data: {
      'title': '집중 시간 분포',
      'subtitle': '상담원 인사이트: 코딩에 가장 많은 노력을 기울였습니다.',
      'unit': 'h',
      'items': [
        {'label': '설계', 'value': 2.5, 'icon': '🎨'},
        {
          'label': '코딩',
          'value': 8.2,
          'icon': '💻',
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': '독서', 'value': 1.5, 'icon': '📚'},
        {'label': '회의', 'value': 3.0, 'icon': '🗣️'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '5. 진행 링(목표 진행)',
    templateId: 'progress_chart_card_v1',
    data: {
      'title': '연간 독서 목표',
      'subtitle': '앞으로 12권의 책',
      'current': 65,
      'target': 100,
      'center_text': '65%',
      'items': [
        {'label': '완료', 'value': 65, 'color': '#6366F1'},
        {'label': '남음', 'value': 35, 'color': '#E2E8F0'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '6. 레이더 차트(레이더)',
    templateId: 'radar_chart_card_v1',
    data: {
      'title': '역량 모델',
      'badge': '월간 포커스',
      'center_value': '78',
      'center_label': '종합점수',
      'dimensions': [
        {'label': '실행', 'value': 80},
        {'label': '생각', 'value': 60},
        {'label': '창의성', 'value': 70},
        {'label': '영향', 'value': 85},
        {'label': '학습', 'value': 50},
      ],
      'color': '#8B5CF6',
    },
  ),
  TemplateGalleryItem(
    label: '7. 하이라이트/인용(인용)',
    templateId: 'highlight_card_v1',
    data: {
      'title': 'DAILY INSIGHT',
      'quote_content': '미래를 예측하는 가장 좋은 방법은 미래를 창조하는 것입니다.',
      'quote_highlight': 'create it',
      'footer': '- 피터 드러커',
      'theme': 'dark',
      'date': '2023.10.27',
    },
  ),
  TemplateGalleryItem(
    label: '8. 구성(내역)',
    templateId: 'composition_card_v1',
    data: {
      'title': '오늘의 에너지 구성',
      'badge': '효율적인',
      'headline_items': [
        {'label': '총 시간', 'value': '8.5h'},
        {'label': '심층 작업', 'value': '4.2h'},
      ],
      'items': [
        {'label': '코딩', 'percentage': 50, 'color': '#6366F1'},
        {'label': '회의', 'percentage': 30, 'color': '#F43F5E'},
        {'label': '독서', 'percentage': 20, 'color': '#10B981'},
      ],
      'footer': '매우 생산적인 하루',
    },
  ),
  TemplateGalleryItem(
    label: '9. 대비/리프레이밍(Reframing)',
    templateId: 'contrast_card_v1',
    data: {
      'title': '믿음의 재구성',
      'emotion': 'neutral',
      'context_section': {
        'title': '독창적인 생각',
        'content': '나는 너무 바빠서 새로운 것을 배울 시간이 없습니다.',
        'icon': '😫'
      },
      'highlight_section': {
        'title': '새로운 관점',
        'content':
            '바쁘다는 것은 연습을 통해 배울 수 있는 기회가 많다는 것을 의미합니다. 나는 실천함으로써 배울 수 있다.',
        'icon': '💡',
        'color': '#10B981'
      },
    },
  ),
  TemplateGalleryItem(
    label: '10. 갤러리/연대기(갤러리)',
    templateId: 'gallery_card_v1',
    data: {
      'title': '영감 스니펫',
      'headline': '3 Photos',
      'content': '오늘 포착한 일부 디자인 영감.',
      'images': [
        {'url': 'https://picsum.photos/200/200?random=1', 'caption': '조직'},
        {'url': 'https://picsum.photos/200/200?random=2', 'caption': '색상'},
        {'url': 'https://picsum.photos/200/200?random=3', 'caption': '빛'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '11. 맵카드(지도)',
    templateId: 'map_card_v1',
    data: {
      'title': '발자취',
      'locations': [
        {'lat': 39.9042, 'lng': 116.4074, 'name': 'Beijing'},
        {'lat': 31.2304, 'lng': 121.4737, 'name': 'Shanghai'},
      ],
      'info_title': '두 도시의 이야기',
      'info_detail': '이번주 베이징-상하이 출퇴근',
    },
  ),
  TemplateGalleryItem(
    label: '12. 요약 카드(요약)',
    templateId: 'summary_card_v1',
    data: {
      'tag': 'WEEKLY REVIEW',
      'title': '4주차: 돌파구와 연결',
      'date': 'Jan 22 - Jan 28, 2026',
      'badge': {'icon': '🚀', 'text': 'S레벨 상태'},
      'insight_title': '상담원 통찰력',
      'insight_content':
          '이번 주에는 주로 #AI Agent 개발에 집중하셨고 코드 커밋에서 새로운 기록을 달성하셨습니다. 또한 귀하가 금요일 밤에 가족 저녁 식사를 기록했다는 것을 알았습니다. 이 "열심히 일하고 충만하게 살아라" 패턴은 매우 건강합니다.',
      'metrics': [
        {'label': '집중', 'value': '32h'},
        {'label': '기분', 'value': '8.2', 'color': '#10B981'},
        {'label': '기록', 'value': '15', 'color': '#6366F1'},
      ],
      'highlights_title': '이번주 하이라이트(3개 선택)',
      'highlights': [
        {'url': 'https://picsum.photos/300/300?random=10', 'label': '시작하다'},
        {
          'url': 'https://picsum.photos/300/300?random=11',
          'label': '가족 저녁 식사'
        },
        {'url': 'https://picsum.photos/300/300?random=12'},
      ],
    },
  ),
];
