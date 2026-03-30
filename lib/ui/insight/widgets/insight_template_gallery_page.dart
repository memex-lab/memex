import 'package:flutter/material.dart';
import 'package:memex/l10n/app_localizations_ext_zh.dart';
import 'package:memex/ui/core/cards/native_widget_factory.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/widgets/back_button.dart';

class InsightTemplateGalleryPage extends StatelessWidget {
  const InsightTemplateGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isZh = UserStorage.l10n is AppLocalizationsExtZh;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          UserStorage.l10n.insightTemplateGalleryTitle,
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
          _buildSection(
            isZh
                ? '1. Timeline Card (今日时间流)'
                : '1. Timeline Card (Today’s timeline)',
            'timeline_card_v1',
            isZh
                ? {
                    "title": "今日时间流",
                    "items": [
                      {
                        "time": "09:00",
                        "title": "深度工作",
                        "content": "完成了架构设计图 V2.0，修复了三个关键 Bug。",
                        "icon": "💻",
                        "color": "#6366F1",
                        "is_filled_dot": false
                      },
                      {
                        "time": "12:30",
                        "title": "午餐 & 休息",
                        "content": "轻食沙拉，之后散步 20 分钟。",
                        "icon": "🥗",
                        "color": "#10B981",
                        "is_filled_dot": false
                      },
                      {
                        "time": "14:00",
                        "content": "待记录...",
                        "is_filled_dot": true,
                        "color": "#CBD5E1"
                      }
                    ]
                  }
                : {
                    "title": "Today’s timeline",
                    "items": [
                      {
                        "time": "09:00",
                        "title": "Deep work",
                        "content":
                            "Finished architecture diagram v2.0 and fixed three critical bugs.",
                        "icon": "💻",
                        "color": "#6366F1",
                        "is_filled_dot": false
                      },
                      {
                        "time": "12:30",
                        "title": "Lunch & break",
                        "content": "Light salad, followed by a 20-minute walk.",
                        "icon": "🥗",
                        "color": "#10B981",
                        "is_filled_dot": false
                      },
                      {
                        "time": "14:00",
                        "content": "To be filled...",
                        "is_filled_dot": true,
                        "color": "#CBD5E1"
                      }
                    ]
                  },
          ),
          _buildSection(
            isZh
                ? '2. Bubble Chart (关键词气泡)'
                : '2. Bubble Chart (Keyword bubbles)',
            'bubble_chart_card_v1',
            isZh
                ? {
                    "title": "本周关键词",
                    "bubbles": [
                      {
                        "label": "Flutter",
                        "value": 100,
                        "color": "#6366F1",
                        "is_highlight": true
                      },
                      {"label": "Dart", "value": 80, "color": "#8B5CF6"},
                      {"label": "AI", "value": 60, "color": "#EC4899"},
                      {"label": "设计", "value": 40, "color": "#10B981"},
                      {"label": "Memex", "value": 90, "color": "#F59E0B"},
                    ],
                    "footer": "基于 42 条笔记分析"
                  }
                : {
                    "title": "Keywords of the week",
                    "bubbles": [
                      {
                        "label": "Flutter",
                        "value": 100,
                        "color": "#6366F1",
                        "is_highlight": true
                      },
                      {"label": "Dart", "value": 80, "color": "#8B5CF6"},
                      {"label": "AI", "value": 60, "color": "#EC4899"},
                      {"label": "Design", "value": 40, "color": "#10B981"},
                      {"label": "Memex", "value": 90, "color": "#F59E0B"},
                    ],
                    "footer": "Analysis based on 42 notes",
                  },
          ),
          _buildSection(
            isZh ? '3. Trend Line (趋势图)' : '3. Trend Line (Trend chart)',
            'trend_chart_card_v1',
            isZh
                ? {
                    "title": "近7日情绪指数",
                    "top_right_text": "平均值: 7.2",
                    "points": [
                      {"label": "周二", "value": 3.5},
                      {"label": "周三", "value": 4.0},
                      {"label": "周四", "value": 5.5},
                      {"label": "周五", "value": 8.5, "is_highlight": true},
                      {"label": "周六", "value": 7.0},
                      {"label": "周日", "value": 6.5},
                      {"label": "周一", "value": 7.5}
                    ],
                    "highlight_info": {"title": "8.5分", "subtitle": "周五高光"},
                    "color": "#6366F1"
                  }
                : {
                    "title": "Mood index (last 7 days)",
                    "top_right_text": "Average: 7.2",
                    "points": [
                      {"label": "Tue", "value": 3.5},
                      {"label": "Wed", "value": 4.0},
                      {"label": "Thu", "value": 5.5},
                      {"label": "Fri", "value": 8.5, "is_highlight": true},
                      {"label": "Sat", "value": 7.0},
                      {"label": "Sun", "value": 6.5},
                      {"label": "Mon", "value": 7.5}
                    ],
                    "highlight_info": {
                      "title": "8.5 points",
                      "subtitle": "Friday highlight"
                    },
                    "color": "#6366F1"
                  },
          ),
          _buildSection(
            isZh ? '4. Bar Chart (柱状对比)' : '4. Bar Chart (Bar comparison)',
            'bar_chart_card_v1',
            isZh
                ? {
                    "title": "专注时长分布",
                    "subtitle": "Agent 洞察: 你在 代码 上投入了最多精力。",
                    "unit": "h",
                    "items": [
                      {"label": "设计", "value": 2.5, "icon": "🎨"},
                      {
                        "label": "代码",
                        "value": 8.2,
                        "icon": "💻",
                        "color": "#6366F1",
                        "is_highlight": true
                      },
                      {"label": "阅读", "value": 1.5, "icon": "📚"},
                      {"label": "会议", "value": 3.0, "icon": "🗣️"}
                    ]
                  }
                : {
                    "title": "Focus time distribution",
                    "subtitle":
                        "Agent insight: You spent the most effort on Coding.",
                    "unit": "h",
                    "items": [
                      {"label": "Design", "value": 2.5, "icon": "🎨"},
                      {
                        "label": "Coding",
                        "value": 8.2,
                        "icon": "💻",
                        "color": "#6366F1",
                        "is_highlight": true
                      },
                      {"label": "Reading", "value": 1.5, "icon": "📚"},
                      {"label": "Meetings", "value": 3.0, "icon": "🗣️"}
                    ]
                  },
          ),
          _buildSection(
            isZh
                ? '5. Progress Ring (目标进度)'
                : '5. Progress Ring (Goal progress)',
            'progress_chart_card_v1',
            isZh
                ? {
                    "title": "年度阅读目标",
                    "subtitle": "还差 12 本书",
                    "current": 65,
                    "target": 100,
                    "center_text": "65%",
                    "items": [
                      {"label": "已完成", "value": 65, "color": "#6366F1"},
                      {"label": "剩余", "value": 35, "color": "#E2E8F0"}
                    ]
                  }
                : {
                    "title": "Annual reading goal",
                    "subtitle": "12 books to go",
                    "current": 65,
                    "target": 100,
                    "center_text": "65%",
                    "items": [
                      {"label": "Completed", "value": 65, "color": "#6366F1"},
                      {"label": "Remaining", "value": 35, "color": "#E2E8F0"}
                    ]
                  },
          ),
          _buildSection(
            isZh ? '6. Radar Chart (雷达图)' : '6. Radar Chart (Radar)',
            'radar_chart_card_v1',
            isZh
                ? {
                    "title": "能力模型",
                    "badge": "本月重心",
                    "center_value": "78",
                    "center_label": "综合得分",
                    "dimensions": [
                      {"label": "执行力", "value": 80},
                      {"label": "思考力", "value": 60},
                      {"label": "创造力", "value": 70},
                      {"label": "影响力", "value": 85},
                      {"label": "学习力", "value": 50}
                    ],
                    "color": "#8B5CF6"
                  }
                : {
                    "title": "Capability model",
                    "badge": "Monthly focus",
                    "center_value": "78",
                    "center_label": "Overall score",
                    "dimensions": [
                      {"label": "Execution", "value": 80},
                      {"label": "Thinking", "value": 60},
                      {"label": "Creativity", "value": 70},
                      {"label": "Influence", "value": 85},
                      {"label": "Learning", "value": 50}
                    ],
                    "color": "#8B5CF6"
                  },
          ),
          _buildSection(
            isZh ? '7. Highlight/Quote (金句)' : '7. Highlight/Quote (Quote)',
            'highlight_card_v1',
            {
              "title": "DAILY INSIGHT",
              "quote_content":
                  "The best way to predict the future is to create it.",
              "quote_highlight": "create it",
              "footer": "- Peter Drucker",
              "theme": "dark",
              "date": "2023.10.27"
            },
          ),
          _buildSection(
            isZh ? '8. Composition (成分表)' : '8. Composition (Breakdown)',
            'composition_card_v1',
            isZh
                ? {
                    "title": "今日精力成分",
                    "badge": "高效",
                    "headline_items": [
                      {"label": "总时长", "value": "8.5h"},
                      {"label": "深度", "value": "4.2h"}
                    ],
                    "items": [
                      {"label": "Coding", "percentage": 50, "color": "#6366F1"},
                      {
                        "label": "Meeting",
                        "percentage": 30,
                        "color": "#F43F5E"
                      },
                      {"label": "Reading", "percentage": 20, "color": "#10B981"}
                    ],
                    "footer": "精力充沛的一天"
                  }
                : {
                    "title": "Energy composition today",
                    "badge": "Efficient",
                    "headline_items": [
                      {"label": "Total time", "value": "8.5h"},
                      {"label": "Deep work", "value": "4.2h"}
                    ],
                    "items": [
                      {"label": "Coding", "percentage": 50, "color": "#6366F1"},
                      {
                        "label": "Meetings",
                        "percentage": 30,
                        "color": "#F43F5E"
                      },
                      {"label": "Reading", "percentage": 20, "color": "#10B981"}
                    ],
                    "footer": "A very productive day",
                  },
          ),
          _buildSection(
            isZh
                ? '9. Contrast/Reframing (对比/重构)'
                : '9. Contrast/Reframing (Reframing)',
            'contrast_card_v1',
            isZh
                ? {
                    "title": "观点重构",
                    "emotion": "neutral",
                    "context_section": {
                      "title": "原想法",
                      "content": "我太忙了，没有时间学习新东西。",
                      "icon": "😫"
                    },
                    "highlight_section": {
                      "title": "新视角",
                      "content": "忙碌说明通过实践学习的机会很多。我可以从做中学。",
                      "icon": "💡",
                      "color": "#10B981"
                    }
                  }
                : {
                    "title": "Reframing a belief",
                    "emotion": "neutral",
                    "context_section": {
                      "title": "Original thought",
                      "content":
                          "I am too busy and don’t have time to learn new things.",
                      "icon": "😫"
                    },
                    "highlight_section": {
                      "title": "New perspective",
                      "content":
                          "Being busy means there are many opportunities to learn through practice. I can learn by doing.",
                      "icon": "💡",
                      "color": "#10B981"
                    }
                  },
          ),
          _buildSection(
            isZh
                ? '10. Gallery/Chronicle (多图列表)'
                : '10. Gallery/Chronicle (Gallery)',
            'gallery_card_v1',
            isZh
                ? {
                    "title": "灵感碎片",
                    "headline": "3 Photos",
                    "content": "今天捕捉到的一些设计灵感。",
                    "images": [
                      {
                        "url": "https://picsum.photos/200/200?random=1",
                        "caption": "Texture"
                      },
                      {
                        "url": "https://picsum.photos/200/200?random=2",
                        "caption": "Color"
                      },
                      {
                        "url": "https://picsum.photos/200/200?random=3",
                        "caption": "Light"
                      }
                    ]
                  }
                : {
                    "title": "Inspiration snippets",
                    "headline": "3 Photos",
                    "content": "Some design inspirations captured today.",
                    "images": [
                      {
                        "url": "https://picsum.photos/200/200?random=1",
                        "caption": "Texture"
                      },
                      {
                        "url": "https://picsum.photos/200/200?random=2",
                        "caption": "Color"
                      },
                      {
                        "url": "https://picsum.photos/200/200?random=3",
                        "caption": "Light"
                      }
                    ]
                  },
          ),
          _buildSection(
            isZh ? '11. Map Card (地图)' : '11. Map Card (Map)',
            'map_card_v1',
            isZh
                ? {
                    "title": "足迹",
                    "locations": [
                      {"lat": 39.9042, "lng": 116.4074, "name": "Beijing"},
                      {"lat": 31.2304, "lng": 121.4737, "name": "Shanghai"}
                    ],
                    "info_title": "双城记",
                    "info_detail": "本周往返于京沪之间"
                  }
                : {
                    "title": "Footprints",
                    "locations": [
                      {"lat": 39.9042, "lng": 116.4074, "name": "Beijing"},
                      {"lat": 31.2304, "lng": 121.4737, "name": "Shanghai"}
                    ],
                    "info_title": "A tale of two cities",
                    "info_detail":
                        "Commuting between Beijing and Shanghai this week",
                  },
          ),
          _buildSection(
            isZh ? '12. Summary Card (总结卡片)' : '12. Summary Card (Summary)',
            'summary_card_v1',
            isZh
                ? {
                    "tag": "WEEKLY REVIEW",
                    "title": "第 4 周：突破与连接",
                    "date": "Jan 22 - Jan 28, 2026",
                    "badge": {"icon": "🚀", "text": "S级状态"},
                    "insight_title": "Agent 洞察",
                    "insight_content":
                        "这周你的主要精力都投入在了 #AI Agent 的开发上，代码提交量创下新高。同时，我注意到你周五晚上记录了与家人的聚餐，这种“极致工作，极致生活”的模式非常健康。",
                    "metrics": [
                      {"label": "专注", "value": "32h"},
                      {"label": "心情", "value": "8.2", "color": "#10B981"},
                      {"label": "记录", "value": "15条", "color": "#6366F1"}
                    ],
                    "highlights_title": "本周高光 (已选 3 张)",
                    "highlights": [
                      {
                        "url": "https://picsum.photos/300/300?random=10",
                        "label": "项目上线"
                      },
                      {
                        "url": "https://picsum.photos/300/300?random=11",
                        "label": "家庭聚餐"
                      },
                      {"url": "https://picsum.photos/300/300?random=12"}
                    ]
                  }
                : {
                    "tag": "WEEKLY REVIEW",
                    "title": "Week 4: Breakthrough & connection",
                    "date": "Jan 22 - Jan 28, 2026",
                    "badge": {"icon": "🚀", "text": "S-level state"},
                    "insight_title": "Agent insight",
                    "insight_content":
                        "This week you focused mainly on #AI Agent development and hit a new record for code commits. I also noticed you logged a family dinner on Friday night — this “work hard, live fully” pattern is very healthy.",
                    "metrics": [
                      {"label": "Focus", "value": "32h"},
                      {"label": "Mood", "value": "8.2", "color": "#10B981"},
                      {"label": "Notes", "value": "15", "color": "#6366F1"}
                    ],
                    "highlights_title": "Highlights of the week (3 selected)",
                    "highlights": [
                      {
                        "url": "https://picsum.photos/300/300?random=10",
                        "label": "Launch"
                      },
                      {
                        "url": "https://picsum.photos/300/300?random=11",
                        "label": "Family dinner"
                      },
                      {"url": "https://picsum.photos/300/300?random=12"}
                    ]
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      String label, String templateId, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A5565),
            ),
          ),
        ),
        NativeWidgetFactory.build(templateId, data) ??
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.red.shade50,
              child: Text('Failed to build $templateId'),
            ),
      ],
    );
  }
}
