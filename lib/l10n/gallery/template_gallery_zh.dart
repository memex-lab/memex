import 'template_gallery_models.dart';

const timelineTemplateGallerySectionsZh = [
  TemplateGallerySection(
    title: '通用 (General)',
    items: [
      TemplateGalleryItem(
        label: '1. Classic Card (文字笔记)',
        templateId: 'classic_card',
        title: '读书笔记',
        data: {
          'content':
              '今天在咖啡馆读完了《思考，快与慢》第三章，对“锚定效应”的案例印象深刻。人们总会不自觉地被最初接触到的信息所影响，这值得我们在做决策时格外警惕。',
          'tags': ['读书', '心理学'],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: '文字 (Textual)',
    items: [
      TemplateGalleryItem(
        label: '2. Snippet Card (文字片段)',
        templateId: 'snippet',
        title: '科技名言',
        data: {
          'text': '**“任何足够先进的技术，都与魔法无异。”**\n\n— Arthur C. Clarke',
          'style': 'default',
          'tags': ['名言', '科技', '未来'],
        },
      ),
      TemplateGalleryItem(
        label: '3. Article Card (长文章)',
        templateId: 'article',
        title: '什么是心流体验',
        data: {
          'body':
              '## 什么是心流？\n\n心流（Flow）是由心理学家米哈里·契克森米哈提出的一种心理状态。当你完全沉浸在一项具有挑战性但可完成的任务中，时间感消失，注意力高度集中，这就是心流。\n\n> 人在做感兴趣的事情时，常常浑然忘我。\n\n研究发现，心流状态下的人往往生产力最高，幸福感也最强。',
        },
      ),
      TemplateGalleryItem(
        label: '4. Conversation Card (对话)',
        templateId: 'conversation',
        title: '与 AI 的对话',
        data: {
          'messages': [
            {
              'sender': 'AI 助理',
              'text': '你今天的工作效率看起来很高！完成了哪些任务？',
              'isMe': false
            },
            {'sender': 'me', 'text': '完成了架构设计和代码 review，感觉很充实。', 'isMe': true},
            {
              'sender': 'AI 助理',
              'text': '太棒了！记得今晚早点休息，明天还有重要会议。',
              'isMe': false
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '5. Quote Card (引言)',
        templateId: 'quote',
        title: '每日金句',
        data: {
          'content': '不要等待完美的时机，你应该行动，并让时机在行动中变得完美。',
          'author': '拿破仑·希尔',
          'source': '《思考致富》',
        },
      ),
      TemplateGalleryItem(
        label: '6. Compact Card (紧凑行)',
        templateId: 'compact_card',
        title: '💧 喝水打卡',
        wrapped: true,
        data: {
          'details': ['500ml', '第 4 杯', '今日目标 2000ml'],
          'color': '#3B82F6',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: '视觉 (Visual)',
    items: [
      TemplateGalleryItem(
        label: '7. Snapshot Card (照片)',
        templateId: 'snapshot',
        title: '黄昏时刻',
        data: {
          'image_url': 'https://picsum.photos/600/400?random=30',
          'location': '上海·外滩',
        },
      ),
      TemplateGalleryItem(
        label: '8. Gallery Card (相册)',
        templateId: 'gallery',
        title: '周末露营',
        data: {
          'image_urls': [
            'https://picsum.photos/400/400?random=31',
            'https://picsum.photos/400/400?random=32',
            'https://picsum.photos/400/400?random=33',
          ],
        },
      ),
      TemplateGalleryItem(
        label: '9. Video Card (视频)',
        templateId: 'video',
        title: '视频记录',
        data: {
          'video_url':
              'https://ai-video.weshop.ai/video/91f4255d-6c43-4608-b5e6-d39ed7890ccb_20260210.mp4',
          'duration': '00:30',
        },
      ),
      TemplateGalleryItem(
        label: '10. Canvas Card (画布)',
        templateId: 'canvas',
        title: '思维导图草稿',
        data: {},
      ),
    ],
  ),
  TemplateGallerySection(
    title: '数值 (Quantifiable)',
    items: [
      TemplateGalleryItem(
        label: '11. Metric Card (多指标)',
        templateId: 'metric',
        title: '健康指标',
        data: {
          'items': [
            {
              'title': '深度睡眠',
              'value': 2.5,
              'unit': 'h',
              'label': '昨晚',
              'trend': 'up',
              'color': 'indigo'
            },
            {
              'title': '步数',
              'value': 8342,
              'unit': '步',
              'label': '今日',
              'trend': 'up',
              'color': 'emerald'
            },
            {
              'title': '心率',
              'value': 72,
              'unit': 'bpm',
              'label': '静息',
              'trend': 'neutral',
              'color': 'orange'
            },
          ],
        },
      ),
      TemplateGalleryItem(
        label: '12. Rating Card (评分)',
        templateId: 'rating',
        title: '电影评分',
        data: {
          'subject': '《星际穿越》',
          'score': 4.5,
          'max_score': 5.0,
          'comment': '震撼的视觉效果，对时间与爱的哲学思考让人久久回味。',
        },
      ),
      TemplateGalleryItem(
        label: '13. Mood Card (心情)',
        templateId: 'mood',
        title: '今日心情',
        data: {
          'mood_name': 'Excited',
          'intensity': 8,
          'trigger': '新项目立项，团队士气高涨',
        },
      ),
      TemplateGalleryItem(
        label: '14. Progress Card (进度条)',
        templateId: 'progress',
        title: '年度目标进度',
        data: {
          'label': '年度读书计划',
          'current': 18.0,
          'total': 52.0,
          'unit': '本',
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: '时间 (Temporal)',
    items: [
      TemplateGalleryItem(
        label: '15. Event Card (日程事件)',
        templateId: 'event',
        title: 'AI 产品评审会议',
        data: {
          'start_time': '2026-03-10T14:00:00',
          'end_time': '2026-03-10T16:00:00',
          'location': '上海·浦东新区科技园 A 座会议室',
        },
      ),
      TemplateGalleryItem(
        label: '16. Duration Card (计时器)',
        templateId: 'duration',
        title: '番茄钟',
        data: {
          'elapsed': 1500,
          'remaining': 1500,
          'is_running': false,
        },
      ),
      TemplateGalleryItem(
        label: '17. Task Card (任务)',
        templateId: 'task',
        title: '完成产品需求分析',
        data: {
          'is_completed': false,
          'priority': 'high',
          'subtasks': [
            {'title': '竞品分析报告', 'completed': true},
            {'title': '用户访谈整理', 'completed': true},
            {'title': '需求文档初稿', 'completed': false},
            {'title': 'PRD 评审会议', 'completed': false},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '18. Routine Card (习惯打卡)',
        templateId: 'routine',
        title: '每日冥想',
        data: {
          'habit_name': '每日冥想 10 分钟',
          'streak': 14,
          'history': [true, true, false, true, true, true, true],
        },
      ),
      TemplateGalleryItem(
        label: '19. Procedure Card (操作步骤)',
        templateId: 'procedure',
        title: '黄油曲奇食谱',
        data: {
          'steps': [
            '准备食材：低筋面粉 200g、鸡蛋 3 个、黄油 100g',
            '预热烤箱至 175°C',
            '将黄油和糖混合打发至颜色变浅',
            '逐个加入鸡蛋，充分搅拌',
            '筛入面粉，翻拌均匀',
            '送入烤箱烘烤 25 分钟',
          ],
        },
      ),
    ],
  ),
  TemplateGallerySection(
    title: '实体 (Entities)',
    items: [
      TemplateGalleryItem(
        label: '20. Person Card (人物)',
        templateId: 'person',
        title: '联系人',
        data: {
          'name': '张晓明',
          'relation': '产品经理',
          'status': 'online',
        },
      ),
      TemplateGalleryItem(
        label: '21. Place Card (地点)',
        templateId: 'place',
        title: '常去书店',
        data: {
          'name': '蔦屋书店·上海静安寺',
          'address': '上海市静安区泰兴路 400 号',
          'lat': 31.2304,
          'lng': 121.4537,
        },
      ),
      TemplateGalleryItem(
        label: '22. Spec Sheet (产品规格)',
        templateId: 'spec_sheet',
        title: 'Apple Watch Series 9',
        data: {
          'subtitle': '智能手表',
          'specs': {
            '屏幕': '1.9 英寸 AMOLED',
            '电池': '5 天续航',
            '防水': 'IP68',
            '重量': '32g',
            '芯片': 'Apple S9',
            '尺寸': '45mm',
          },
        },
      ),
      TemplateGalleryItem(
        label: '23. Transaction Card (消费)',
        templateId: 'transaction',
        title: '午餐消费',
        data: {
          'merchant': '胡同里面馆',
          'amount': '¥ 68.00',
          'location': '北京·鼓楼大街',
          'items': [
            {'name': '招牌炸酱面（大）', 'amount': '¥ 38'},
            {'name': '卤蛋', 'amount': '¥ 8'},
            {'name': '冰镇老北京酸奶', 'amount': '¥ 22'},
          ],
        },
      ),
      TemplateGalleryItem(
        label: '24. Link Card (链接)',
        templateId: 'link',
        title: 'Flutter 官方文档',
        data: {
          'url': 'https://flutter.dev/docs',
          'domain': 'flutter.dev',
        },
      ),
    ],
  ),
];

const insightTemplateGalleryItemsZh = [
  TemplateGalleryItem(
    label: '1. Timeline Card (今日时间流)',
    templateId: 'timeline_card_v1',
    data: {
      'title': '今日时间流',
      'items': [
        {
          'time': '09:00',
          'title': '深度工作',
          'content': '完成了架构设计图 V2.0，修复了三个关键 Bug。',
          'icon': '💻',
          'color': '#6366F1',
          'is_filled_dot': false
        },
        {
          'time': '12:30',
          'title': '午餐 & 休息',
          'content': '轻食沙拉，之后散步 20 分钟。',
          'icon': '🥗',
          'color': '#10B981',
          'is_filled_dot': false
        },
        {
          'time': '14:00',
          'content': '待记录...',
          'is_filled_dot': true,
          'color': '#CBD5E1'
        },
      ],
    },
  ),
  TemplateGalleryItem(
    label: '2. Bubble Chart (关键词气泡)',
    templateId: 'bubble_chart_card_v1',
    data: {
      'title': '本周关键词',
      'bubbles': [
        {
          'label': 'Flutter',
          'value': 100,
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': 'Dart', 'value': 80, 'color': '#8B5CF6'},
        {'label': 'AI', 'value': 60, 'color': '#EC4899'},
        {'label': '设计', 'value': 40, 'color': '#10B981'},
        {'label': 'Memex', 'value': 90, 'color': '#F59E0B'},
      ],
      'footer': '基于 42 条笔记分析',
    },
  ),
  TemplateGalleryItem(
    label: '3. Trend Line (趋势图)',
    templateId: 'trend_chart_card_v1',
    data: {
      'title': '近7日情绪指数',
      'top_right_text': '平均值: 7.2',
      'points': [
        {'label': '周二', 'value': 3.5},
        {'label': '周三', 'value': 4.0},
        {'label': '周四', 'value': 5.5},
        {'label': '周五', 'value': 8.5, 'is_highlight': true},
        {'label': '周六', 'value': 7.0},
        {'label': '周日', 'value': 6.5},
        {'label': '周一', 'value': 7.5},
      ],
      'highlight_info': {'title': '8.5分', 'subtitle': '周五高光'},
      'color': '#6366F1',
    },
  ),
  TemplateGalleryItem(
    label: '4. Bar Chart (柱状对比)',
    templateId: 'bar_chart_card_v1',
    data: {
      'title': '专注时长分布',
      'subtitle': 'Agent 洞察: 你在 代码 上投入了最多精力。',
      'unit': 'h',
      'items': [
        {'label': '设计', 'value': 2.5, 'icon': '🎨'},
        {
          'label': '代码',
          'value': 8.2,
          'icon': '💻',
          'color': '#6366F1',
          'is_highlight': true
        },
        {'label': '阅读', 'value': 1.5, 'icon': '📚'},
        {'label': '会议', 'value': 3.0, 'icon': '🗣️'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '5. Progress Ring (目标进度)',
    templateId: 'progress_chart_card_v1',
    data: {
      'title': '年度阅读目标',
      'subtitle': '还差 12 本书',
      'current': 65,
      'target': 100,
      'center_text': '65%',
      'items': [
        {'label': '已完成', 'value': 65, 'color': '#6366F1'},
        {'label': '剩余', 'value': 35, 'color': '#E2E8F0'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '6. Radar Chart (雷达图)',
    templateId: 'radar_chart_card_v1',
    data: {
      'title': '能力模型',
      'badge': '本月重心',
      'center_value': '78',
      'center_label': '综合得分',
      'dimensions': [
        {'label': '执行力', 'value': 80},
        {'label': '思考力', 'value': 60},
        {'label': '创造力', 'value': 70},
        {'label': '影响力', 'value': 85},
        {'label': '学习力', 'value': 50},
      ],
      'color': '#8B5CF6',
    },
  ),
  TemplateGalleryItem(
    label: '7. Highlight/Quote (金句)',
    templateId: 'highlight_card_v1',
    data: {
      'title': 'DAILY INSIGHT',
      'quote_content': 'The best way to predict the future is to create it.',
      'quote_highlight': 'create it',
      'footer': '- Peter Drucker',
      'theme': 'dark',
      'date': '2023.10.27',
    },
  ),
  TemplateGalleryItem(
    label: '8. Composition (成分表)',
    templateId: 'composition_card_v1',
    data: {
      'title': '今日精力成分',
      'badge': '高效',
      'headline_items': [
        {'label': '总时长', 'value': '8.5h'},
        {'label': '深度', 'value': '4.2h'},
      ],
      'items': [
        {'label': 'Coding', 'percentage': 50, 'color': '#6366F1'},
        {'label': 'Meeting', 'percentage': 30, 'color': '#F43F5E'},
        {'label': 'Reading', 'percentage': 20, 'color': '#10B981'},
      ],
      'footer': '精力充沛的一天',
    },
  ),
  TemplateGalleryItem(
    label: '9. Contrast/Reframing (对比/重构)',
    templateId: 'contrast_card_v1',
    data: {
      'title': '观点重构',
      'emotion': 'neutral',
      'context_section': {
        'title': '原想法',
        'content': '我太忙了，没有时间学习新东西。',
        'icon': '😫'
      },
      'highlight_section': {
        'title': '新视角',
        'content': '忙碌说明通过实践学习的机会很多。我可以从做中学。',
        'icon': '💡',
        'color': '#10B981'
      },
    },
  ),
  TemplateGalleryItem(
    label: '10. Gallery/Chronicle (多图列表)',
    templateId: 'gallery_card_v1',
    data: {
      'title': '灵感碎片',
      'headline': '3 Photos',
      'content': '今天捕捉到的一些设计灵感。',
      'images': [
        {'url': 'https://picsum.photos/200/200?random=1', 'caption': 'Texture'},
        {'url': 'https://picsum.photos/200/200?random=2', 'caption': 'Color'},
        {'url': 'https://picsum.photos/200/200?random=3', 'caption': 'Light'},
      ],
    },
  ),
  TemplateGalleryItem(
    label: '11. Map Card (地图)',
    templateId: 'map_card_v1',
    data: {
      'title': '足迹',
      'locations': [
        {'lat': 39.9042, 'lng': 116.4074, 'name': 'Beijing'},
        {'lat': 31.2304, 'lng': 121.4737, 'name': 'Shanghai'},
      ],
      'info_title': '双城记',
      'info_detail': '本周往返于京沪之间',
    },
  ),
  TemplateGalleryItem(
    label: '12. Summary Card (总结卡片)',
    templateId: 'summary_card_v1',
    data: {
      'tag': 'WEEKLY REVIEW',
      'title': '第 4 周：突破与连接',
      'date': 'Jan 22 - Jan 28, 2026',
      'badge': {'icon': '🚀', 'text': 'S级状态'},
      'insight_title': 'Agent 洞察',
      'insight_content':
          '这周你的主要精力都投入在了 #AI Agent 的开发上，代码提交量创下新高。同时，我注意到你周五晚上记录了与家人的聚餐，这种“极致工作，极致生活”的模式非常健康。',
      'metrics': [
        {'label': '专注', 'value': '32h'},
        {'label': '心情', 'value': '8.2', 'color': '#10B981'},
        {'label': '记录', 'value': '15条', 'color': '#6366F1'},
      ],
      'highlights_title': '本周高光 (已选 3 张)',
      'highlights': [
        {'url': 'https://picsum.photos/300/300?random=10', 'label': '项目上线'},
        {'url': 'https://picsum.photos/300/300?random=11', 'label': '家庭聚餐'},
        {'url': 'https://picsum.photos/300/300?random=12'},
      ],
    },
  ),
];
