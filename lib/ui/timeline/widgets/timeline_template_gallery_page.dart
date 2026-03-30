import 'package:flutter/material.dart';
import 'package:memex/l10n/app_localizations_ext_zh.dart';
import 'package:memex/ui/core/cards/native_card_factory.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/widgets/back_button.dart';

/// Timeline 卡片模板展示页面
/// 展示所有支持的 Timeline 卡片模板及示例数据
class TimelineTemplateGalleryPage extends StatelessWidget {
  const TimelineTemplateGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isZh = UserStorage.l10n is AppLocalizationsExtZh;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          UserStorage.l10n.timelineTemplateGalleryTitle,
          style: const TextStyle(
            fontFamily: 'PingFang SC',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0A0A0A),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F8FA),
        surfaceTintColor: const Color(0xFFF7F8FA),
        elevation: 0,
        leading: const AppBackButton(),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ─── 通用 ───
          _buildCategoryHeader(isZh ? '通用 (General)' : 'General'),
          _buildSection(
            context,
            isZh ? '1. Classic Card (文字笔记)' : '1. Classic Card (Text note)',
            'classic_card',
            isZh
                ? {
                    'content':
                        '今天在咖啡馆读完了《思考，快与慢》第三章，对“锚定效应”的案例印象深刻。人们总会不自觉地被最初接触到的信息所影响，这值得我们在做决策时格外警惕。',
                    'tags': ['读书', '心理学'],
                  }
                : {
                    'content':
                        'Finished chapter 3 of "Thinking, Fast and Slow" at a café today. The examples about the anchoring effect were impressive and reminded me how our first piece of information can quietly bias every later decision.',
                    'tags': ['Reading', 'Psychology'],
                  },
            title: isZh ? '读书笔记' : 'Reading notes',
          ),
          // ─── 文字 ───
          _buildCategoryHeader(UserStorage.l10n.categoryTextual),
          _buildSection(
            context,
            isZh ? '2. Snippet Card (文字片段)' : '2. Snippet Card (Text snippet)',
            'snippet',
            isZh
                ? {
                    'text': '**“任何足够先进的技术，都与魔法无异。”**\n\n— Arthur C. Clarke',
                    'style': 'default',
                    'tags': ['名言', '科技', '未来'],
                  }
                : {
                    'text':
                        '**“Any sufficiently advanced technology is indistinguishable from magic.”**\n\n— Arthur C. Clarke',
                    'style': 'default',
                    'tags': ['Quote', 'Technology', 'Future'],
                  },
            title: isZh ? '科技名言' : 'Tech quote',
          ),
          _buildSection(
            context,
            isZh ? '3. Article Card (长文章)' : '3. Article Card (Long article)',
            'article',
            isZh
                ? {
                    'body':
                        '## 什么是心流？\n\n心流（Flow）是由心理学家米哈里·契克森米哈提出的一种心理状态。当你完全沉浸在一项具有挑战性但可完成的任务中，时间感消失，注意力高度集中，这就是心流。\n\n> 人在做感兴趣的事情时，常常浑然忘我。\n\n研究发现，心流状态下的人往往生产力最高，幸福感也最强。',
                  }
                : {
                    'body':
                        '## What is flow?\n\nFlow is a psychological state proposed by Mihaly Csikszentmihalyi. When you are fully immersed in a challenging yet achievable task, you lose track of time and your attention is completely focused — this is flow.\n\n> When people do what they truly enjoy, they often forget themselves.\n\nResearch shows that people in a flow state are usually the most productive and also feel the happiest.',
                  },
            title: isZh ? '什么是心流体验' : 'What is flow experience',
          ),
          _buildSection(
            context,
            isZh
                ? '4. Conversation Card (对话)'
                : '4. Conversation Card (Conversation)',
            'conversation',
            isZh
                ? {
                    'messages': [
                      {
                        'sender': 'AI 助理',
                        'text': '你今天的工作效率看起来很高！完成了哪些任务？',
                        'isMe': false
                      },
                      {
                        'sender': 'me',
                        'text': '完成了架构设计和代码 review，感觉很充实。',
                        'isMe': true
                      },
                      {
                        'sender': 'AI 助理',
                        'text': '太棒了！记得今晚早点休息，明天还有重要会议。',
                        'isMe': false
                      },
                    ],
                  }
                : {
                    'messages': [
                      {
                        'sender': 'AI Assistant',
                        'text':
                            'You were pretty productive today! What did you get done?',
                        'isMe': false
                      },
                      {
                        'sender': 'me',
                        'text':
                            'Finished the architecture design and code review. Feels great.',
                        'isMe': true
                      },
                      {
                        'sender': 'AI Assistant',
                        'text':
                            'Awesome! Remember to rest early tonight, you have an important meeting tomorrow.',
                        'isMe': false
                      },
                    ],
                  },
            title: isZh ? '与 AI 的对话' : 'Conversation with AI',
          ),
          _buildSection(
            context,
            isZh ? '5. Quote Card (引言)' : '5. Quote Card (Quote)',
            'quote',
            isZh
                ? {
                    'content': '不要等待完美的时机，你应该行动，并让时机在行动中变得完美。',
                    'author': '拿破仑·希尔',
                    'source': '《思考致富》',
                  }
                : {
                    'content':
                        'Do not wait for the perfect moment. Act, and let the moment become perfect through your action.',
                    'author': 'Napoleon Hill',
                    'source': 'Think and Grow Rich',
                  },
            title: isZh ? '每日金句' : 'Quote of the day',
          ),
          _buildWrappedSection(
            context,
            isZh ? '6. Compact Card (紧凑行)' : '6. Compact Card (Compact row)',
            'compact_card',
            isZh
                ? {
                    'details': ['500ml', '第 4 杯', '今日目标 2000ml'],
                    'color': '#3B82F6',
                  }
                : {
                    'details': ['500ml', 'Cup 4', 'Today’s goal 2000ml'],
                    'color': '#3B82F6',
                  },
            title: isZh ? '💧 喝水打卡' : '💧 Water intake',
          ),

          // ─── 视觉 ───
          _buildCategoryHeader(isZh ? '视觉 (Visual)' : 'Visual'),
          _buildSection(
            context,
            isZh ? '7. Snapshot Card (照片)' : '7. Snapshot Card (Photo)',
            'snapshot',
            isZh
                ? {
                    'image_url': 'https://picsum.photos/600/400?random=30',
                    'location': '上海·外滩',
                  }
                : {
                    'image_url': 'https://picsum.photos/600/400?random=30',
                    'location': 'The Bund · Shanghai',
                  },
            title: isZh ? '黄昏时刻' : 'Dusk moment',
          ),
          _buildSection(
            context,
            isZh ? '8. Gallery Card (相册)' : '8. Gallery Card (Album)',
            'gallery',
            {
              'image_urls': [
                'https://picsum.photos/400/400?random=31',
                'https://picsum.photos/400/400?random=32',
                'https://picsum.photos/400/400?random=33',
              ],
            },
            title: isZh ? '周末露营' : 'Weekend camping',
          ),
          _buildSection(
            context,
            isZh ? '9. Video Card (视频)' : '9. Video Card (Video)',
            'video',
            {
              'video_url':
                  'https://ai-video.weshop.ai/video/91f4255d-6c43-4608-b5e6-d39ed7890ccb_20260210.mp4',
              'duration': '00:30',
            },
            title: isZh ? '视频记录' : 'Video log',
          ),
          _buildSection(
            context,
            isZh ? '10. Canvas Card (画布)' : '10. Canvas Card (Canvas)',
            'canvas',
            {},
            title: isZh ? '思维导图草稿' : 'Mindmap draft',
          ),

          // ─── 数值 ───
          _buildCategoryHeader(isZh ? '数值 (Quantifiable)' : 'Quantifiable'),
          _buildSection(
            context,
            isZh ? '11. Metric Card (多指标)' : '11. Metric Card (Metrics)',
            'metric',
            isZh
                ? {
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
                  }
                : {
                    'items': [
                      {
                        'title': 'Deep sleep',
                        'value': 2.5,
                        'unit': 'h',
                        'label': 'Last night',
                        'trend': 'up',
                        'color': 'indigo'
                      },
                      {
                        'title': 'Steps',
                        'value': 8342,
                        'unit': 'steps',
                        'label': 'Today',
                        'trend': 'up',
                        'color': 'emerald'
                      },
                      {
                        'title': 'Heart rate',
                        'value': 72,
                        'unit': 'bpm',
                        'label': 'Resting',
                        'trend': 'neutral',
                        'color': 'orange'
                      },
                    ],
                  },
            title: isZh ? '健康指标' : 'Health metrics',
          ),
          _buildSection(
            context,
            isZh ? '12. Rating Card (评分)' : '12. Rating Card (Rating)',
            'rating',
            isZh
                ? {
                    'subject': '《星际穿越》',
                    'score': 4.5,
                    'max_score': 5.0,
                    'comment': '震撼的视觉效果，对时间与爱的哲学思考让人久久回味。',
                  }
                : {
                    'subject': 'Interstellar',
                    'score': 4.5,
                    'max_score': 5.0,
                    'comment':
                        'Breathtaking visuals and a philosophical take on time and love that lingers long after watching.',
                  },
            title: isZh ? '电影评分' : 'Movie rating',
          ),
          _buildSection(
            context,
            isZh ? '13. Mood Card (心情)' : '13. Mood Card (Mood)',
            'mood',
            isZh
                ? {
                    'mood_name': 'Excited',
                    'intensity': 8,
                    'trigger': '新项目立项，团队士气高涨',
                  }
                : {
                    'mood_name': 'Excited',
                    'intensity': 8,
                    'trigger':
                        'New project kicked off and the team is highly motivated.',
                  },
            title: isZh ? '今日心情' : 'Today’s mood',
          ),
          _buildSection(
            context,
            isZh ? '14. Progress Card (进度条)' : '14. Progress Card (Progress)',
            'progress',
            isZh
                ? {
                    'label': '年度读书计划',
                    'current': 18.0,
                    'total': 52.0,
                    'unit': '本',
                  }
                : {
                    'label': 'Annual reading plan',
                    'current': 18.0,
                    'total': 52.0,
                    'unit': 'books',
                  },
            title: isZh ? '年度目标进度' : 'Annual goal progress',
          ),

          // ─── 时间 ───
          _buildCategoryHeader(isZh ? '时间 (Temporal)' : 'Temporal'),
          _buildSection(
            context,
            isZh ? '15. Event Card (日程事件)' : '15. Event Card (Event)',
            'event',
            isZh
                ? {
                    'start_time': '2026-03-10T14:00:00',
                    'end_time': '2026-03-10T16:00:00',
                    'location': '上海·浦东新区科技园 A 座会议室',
                  }
                : {
                    'start_time': '2026-03-10T14:00:00',
                    'end_time': '2026-03-10T16:00:00',
                    'location':
                        'Building A, Tech Park, Pudong New Area, Shanghai',
                  },
            title: isZh ? 'AI 产品评审会议' : 'AI product review meeting',
          ),
          _buildSection(
            context,
            isZh ? '16. Duration Card (计时器)' : '16. Duration Card (Timer)',
            'duration',
            {
              'elapsed': 1500,
              'remaining': 1500,
              'is_running': false,
            },
            title: isZh ? '番茄钟' : 'Pomodoro timer',
          ),
          _buildSection(
            context,
            isZh ? '17. Task Card (任务)' : '17. Task Card (Task)',
            'task',
            isZh
                ? {
                    'is_completed': false,
                    'priority': 'high',
                    'subtasks': [
                      {'title': '竞品分析报告', 'completed': true},
                      {'title': '用户访谈整理', 'completed': true},
                      {'title': '需求文档初稿', 'completed': false},
                      {'title': 'PRD 评审会议', 'completed': false},
                    ],
                  }
                : {
                    'is_completed': false,
                    'priority': 'high',
                    'subtasks': [
                      {
                        'title': 'Competitive analysis report',
                        'completed': true
                      },
                      {'title': 'User interview synthesis', 'completed': true},
                      {
                        'title': 'First draft of requirements doc',
                        'completed': false
                      },
                      {'title': 'PRD review meeting', 'completed': false},
                    ],
                  },
            title: isZh ? '完成产品需求分析' : 'Complete product requirements analysis',
          ),
          _buildSection(
            context,
            isZh
                ? '18. Routine Card (习惯打卡)'
                : '18. Routine Card (Habit tracker)',
            'routine',
            isZh
                ? {
                    'habit_name': '每日冥想 10 分钟',
                    'streak': 14,
                    'history': [true, true, false, true, true, true, true],
                  }
                : {
                    'habit_name': 'Daily 10-minute meditation',
                    'streak': 14,
                    'history': [true, true, false, true, true, true, true],
                  },
            title: isZh ? '每日冥想' : 'Daily meditation',
          ),
          _buildSection(
            context,
            isZh ? '19. Procedure Card (操作步骤)' : '19. Procedure Card (Steps)',
            'procedure',
            isZh
                ? {
                    'steps': [
                      '准备食材：低筋面粉 200g、鸡蛋 3 个、黄油 100g',
                      '预热烤箱至 175°C',
                      '将黄油和糖混合打发至颜色变浅',
                      '逐个加入鸡蛋，充分搅拌',
                      '筛入面粉，翻拌均匀',
                      '送入烤箱烘烤 25 分钟',
                    ],
                  }
                : {
                    'steps': [
                      'Prepare ingredients: 200g cake flour, 3 eggs, 100g butter',
                      'Preheat the oven to 175°C',
                      'Cream butter and sugar until the mixture becomes pale',
                      'Add eggs one by one and mix thoroughly',
                      'Sift in the flour and fold until just combined',
                      'Bake in the oven for 25 minutes',
                    ],
                  },
            title: isZh ? '黄油曲奇食谱' : 'Butter cookie recipe',
          ),

          // ─── 实体 ───
          _buildCategoryHeader(isZh ? '实体 (Entities)' : 'Entities'),
          _buildSection(
            context,
            isZh ? '20. Person Card (人物)' : '20. Person Card (Person)',
            'person',
            isZh
                ? {
                    'name': '张晓明',
                    'relation': '产品经理',
                    'status': 'online',
                  }
                : {
                    'name': 'Alex Zhang',
                    'relation': 'Product Manager',
                    'status': 'online',
                  },
            title: isZh ? '联系人' : 'Contact',
          ),
          _buildSection(
            context,
            isZh ? '21. Place Card (地点)' : '21. Place Card (Place)',
            'place',
            isZh
                ? {
                    'name': '蔦屋书店·上海静安寺',
                    'address': '上海市静安区泰兴路 400 号',
                    'lat': 31.2304,
                    'lng': 121.4537,
                  }
                : {
                    'name': 'Tsutaya Bookstore · Jing’an Temple',
                    'address': '400 Taixing Rd, Jing’an District, Shanghai',
                    'lat': 31.2304,
                    'lng': 121.4537,
                  },
            title: isZh ? '常去书店' : 'Favorite bookstore',
          ),
          _buildSection(
            context,
            isZh ? '22. Spec Sheet (产品规格)' : '22. Spec Sheet (Product specs)',
            'spec_sheet',
            isZh
                ? {
                    'subtitle': '智能手表',
                    'specs': {
                      '屏幕': '1.9 英寸 AMOLED',
                      '电池': '5 天续航',
                      '防水': 'IP68',
                      '重量': '32g',
                      '芯片': 'Apple S9',
                      '尺寸': '45mm',
                    },
                  }
                : {
                    'subtitle': 'Smartwatch',
                    'specs': {
                      'Display': '1.9" AMOLED',
                      'Battery': '5-day battery life',
                      'Water resistance': 'IP68',
                      'Weight': '32g',
                      'Chip': 'Apple S9',
                      'Size': '45mm',
                    },
                  },
            title: 'Apple Watch Series 9',
          ),
          _buildSection(
            context,
            isZh
                ? '23. Transaction Card (消费)'
                : '23. Transaction Card (Spending)',
            'transaction',
            isZh
                ? {
                    'merchant': '胡同里面馆',
                    'amount': '¥ 68.00',
                    'location': '北京·鼓楼大街',
                    'items': [
                      {'name': '招牌炸酱面（大）', 'amount': '¥ 38'},
                      {'name': '卤蛋', 'amount': '¥ 8'},
                      {'name': '冰镇老北京酸奶', 'amount': '¥ 22'},
                    ],
                  }
                : {
                    'merchant': 'Hutong Noodle House',
                    'amount': '¥ 68.00',
                    'location': 'Gulou Street, Beijing',
                    'items': [
                      {
                        'name': 'Signature Zhajiangmian (large)',
                        'amount': '¥ 38'
                      },
                      {'name': 'Marinated egg', 'amount': '¥ 8'},
                      {'name': 'Chilled Beijing yogurt', 'amount': '¥ 22'},
                    ],
                  },
            title: isZh ? '午餐消费' : 'Lunch spending',
          ),
          _buildSection(
            context,
            isZh ? '24. Link Card (链接)' : '24. Link Card (Link)',
            'link',
            {
              'url': 'https://flutter.dev/docs',
              'domain': 'flutter.dev',
            },
            title: 'Flutter 官方文档',
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// 分类标题
  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  /// 普通卡片区块
  Widget _buildSection(
    BuildContext context,
    String label,
    String templateId,
    Map<String, dynamic> data, {
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A5565),
            ),
          ),
        ),
        NativeCardFactory.build(
          templateId: templateId,
          data: data,
          title: title,
          status: 'completed',
          onTap: () => _openPreview(context, templateId, data, title),
        ),
      ],
    );
  }

  /// 带背景包装的卡片区块（用于自身没有背景的 compact_card 等）
  Widget _buildWrappedSection(
    BuildContext context,
    String label,
    String templateId,
    Map<String, dynamic> data, {
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A5565),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _openPreview(context, templateId, data, title),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: NativeCardFactory.build(
              templateId: templateId,
              data: data,
              title: title,
              status: 'completed',
            ),
          ),
        ),
      ],
    );
  }

  void _openPreview(BuildContext context, String templateId,
      Map<String, dynamic> data, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _TemplatePreviewPage(
          templateId: templateId,
          data: data,
          title: title,
        ),
      ),
    );
  }
}

/// 卡片模板预览详情页 — 模拟详情页布局
class _TemplatePreviewPage extends StatelessWidget {
  final String templateId;
  final Map<String, dynamic> data;
  final String title;

  const _TemplatePreviewPage({
    required this.templateId,
    required this.data,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final tags = (data['tags'] as List<dynamic>?)?.cast<String>() ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppBackButton(),
                  Text(
                    templateId,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF99A1AF),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    if (title.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'PingFang SC',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0A0A0A),
                            height: 1.375,
                            letterSpacing: -0.45,
                          ),
                        ),
                      ),
                    // Tags
                    if (tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Wrap(
                          spacing: 8,
                          children: tags
                              .map((t) => Text(
                                    '#$t',
                                    style: const TextStyle(
                                      fontFamily: 'PingFang SC',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF5B6CFF),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    // Card
                    NativeCardFactory.build(
                      templateId: templateId,
                      data: data,
                      title: title,
                      status: 'completed',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
