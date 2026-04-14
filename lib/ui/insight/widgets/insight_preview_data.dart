import 'package:memex/l10n/app_localizations_ext_zh.dart';
import 'package:memex/utils/user_storage.dart';

/// Hardcoded sample insight cards shown as preview when the user has no real insights.
/// These are never persisted — purely for display.
class InsightPreviewData {
  InsightPreviewData._();

  static bool get _isZh => UserStorage.l10n is AppLocalizationsExtZh;

  /// Returns a curated list of (templateId, widgetData) pairs for preview.
  /// We pick a representative subset (not all 12) to keep it digestible.
  static List<({String template, Map<String, dynamic> data})> get samples => [
        // 1. Summary
        (
          template: 'summary_card_v1',
          data: _isZh
              ? {
                  "tag": "WEEKLY REVIEW",
                  "title": "第 4 周：效率拉满的一周",
                  "date": "Jan 22 - Jan 28, 2026",
                  "badge": {"icon": "🚀", "text": "状态极佳"},
                  "insight_title": "本周回顾",
                  "insight_content":
                      "这周项目进展很快，代码提交量创了新高。周五晚上还和家人吃了顿饭，工作生活都没落下，节奏很好。",
                  "metrics": [
                    {"label": "专注", "value": "32h"},
                    {"label": "心情", "value": "8.2", "color": "#10B981"},
                    {"label": "记录", "value": "15条", "color": "#6366F1"},
                  ],
                  "highlights_title": "本周精选",
                  "highlights": [
                    {
                      "url": "https://picsum.photos/300/300?random=10",
                      "label": "项目上线",
                    },
                    {
                      "url": "https://picsum.photos/300/300?random=11",
                      "label": "家庭聚餐",
                    },
                    {"url": "https://picsum.photos/300/300?random=12"},
                  ],
                }
              : {
                  "tag": "WEEKLY REVIEW",
                  "title": "Week 4: A productive week",
                  "date": "Jan 22 - Jan 28, 2026",
                  "badge": {"icon": "🚀", "text": "On fire"},
                  "insight_title": "Weekly review",
                  "insight_content":
                      "Great momentum on the project this week — code commits hit a new high. Friday dinner with the family was a nice way to wrap things up. Good balance overall.",
                  "metrics": [
                    {"label": "Focus", "value": "32h"},
                    {"label": "Mood", "value": "8.2", "color": "#10B981"},
                    {"label": "Notes", "value": "15", "color": "#6366F1"},
                  ],
                  "highlights_title": "Highlights of the week",
                  "highlights": [
                    {
                      "url": "https://picsum.photos/300/300?random=10",
                      "label": "Launch",
                    },
                    {
                      "url": "https://picsum.photos/300/300?random=11",
                      "label": "Family dinner",
                    },
                    {"url": "https://picsum.photos/300/300?random=12"},
                  ],
                },
        ),

        // 2. Trend chart
        (
          template: 'trend_chart_card_v1',
          data: _isZh
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
                    {"label": "周一", "value": 7.5},
                  ],
                  "highlight_info": {"title": "8.5分", "subtitle": "周五最佳"},
                  "color": "#6366F1",
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
                    {"label": "Mon", "value": 7.5},
                  ],
                  "highlight_info": {
                    "title": "8.5 points",
                    "subtitle": "Friday highlight",
                  },
                  "color": "#6366F1",
                },
        ),

        // 3. Bar chart
        (
          template: 'bar_chart_card_v1',
          data: _isZh
              ? {
                  "title": "专注时长分布",
                  "subtitle": "你在代码上投入了最多精力",
                  "unit": "h",
                  "items": [
                    {"label": "设计", "value": 2.5, "icon": "🎨"},
                    {
                      "label": "代码",
                      "value": 8.2,
                      "icon": "💻",
                      "color": "#6366F1",
                      "is_highlight": true,
                    },
                    {"label": "阅读", "value": 1.5, "icon": "📚"},
                    {"label": "会议", "value": 3.0, "icon": "🗣️"},
                  ],
                }
              : {
                  "title": "Focus time distribution",
                  "subtitle": "You spent the most effort on Coding this week.",
                  "unit": "h",
                  "items": [
                    {"label": "Design", "value": 2.5, "icon": "🎨"},
                    {
                      "label": "Coding",
                      "value": 8.2,
                      "icon": "💻",
                      "color": "#6366F1",
                      "is_highlight": true,
                    },
                    {"label": "Reading", "value": 1.5, "icon": "📚"},
                    {"label": "Meetings", "value": 3.0, "icon": "🗣️"},
                  ],
                },
        ),

        // 4. Radar chart
        (
          template: 'radar_chart_card_v1',
          data: _isZh
              ? {
                  "title": "个人能力画像",
                  "badge": "本月",
                  "center_value": "78",
                  "center_label": "综合得分",
                  "dimensions": [
                    {"label": "执行力", "value": 80},
                    {"label": "思考力", "value": 60},
                    {"label": "创造力", "value": 70},
                    {"label": "影响力", "value": 85},
                    {"label": "学习力", "value": 50},
                  ],
                  "color": "#8B5CF6",
                }
              : {
                  "title": "Personal strengths",
                  "badge": "This month",
                  "center_value": "78",
                  "center_label": "Overall score",
                  "dimensions": [
                    {"label": "Execution", "value": 80},
                    {"label": "Thinking", "value": 60},
                    {"label": "Creativity", "value": 70},
                    {"label": "Influence", "value": 85},
                    {"label": "Learning", "value": 50},
                  ],
                  "color": "#8B5CF6",
                },
        ),

        // 5. Highlight
        (
          template: 'highlight_card_v1',
          data: _isZh
              ? {
                  "title": "今日灵感",
                  "quote_content": "预测未来的最好方式，就是去创造它。",
                  "quote_highlight": "创造它",
                  "footer": "- 彼得·德鲁克",
                  "theme": "dark",
                  "date": "2023.10.27",
                }
              : {
                  "title": "DAILY INSIGHT",
                  "quote_content":
                      "The best way to predict the future is to create it.",
                  "quote_highlight": "create it",
                  "footer": "- Peter Drucker",
                  "theme": "dark",
                  "date": "2023.10.27",
                },
        ),

        // 6. Composition
        (
          template: 'composition_card_v1',
          data: _isZh
              ? {
                  "title": "今日精力成分",
                  "badge": "高效",
                  "headline_items": [
                    {"label": "总时长", "value": "8.5h"},
                    {"label": "深度", "value": "4.2h"},
                  ],
                  "items": [
                    {"label": "Coding", "percentage": 50, "color": "#6366F1"},
                    {"label": "Meeting", "percentage": 30, "color": "#F43F5E"},
                    {"label": "Reading", "percentage": 20, "color": "#10B981"},
                  ],
                  "footer": "精力充沛的一天",
                }
              : {
                  "title": "Energy composition today",
                  "badge": "Efficient",
                  "headline_items": [
                    {"label": "Total time", "value": "8.5h"},
                    {"label": "Deep work", "value": "4.2h"},
                  ],
                  "items": [
                    {"label": "Coding", "percentage": 50, "color": "#6366F1"},
                    {"label": "Meetings", "percentage": 30, "color": "#F43F5E"},
                    {"label": "Reading", "percentage": 20, "color": "#10B981"},
                  ],
                  "footer": "A very productive day",
                },
        ),

        // 7. Contrast
        (
          template: 'contrast_card_v1',
          data: _isZh
              ? {
                  "title": "换个角度看",
                  "emotion": "neutral",
                  "context_section": {
                    "title": "原想法",
                    "content": "我太忙了，没有时间学习新东西。",
                    "icon": "😫",
                  },
                  "highlight_section": {
                    "title": "新视角",
                    "content": "忙碌说明通过实践学习的机会很多。我可以从做中学。",
                    "icon": "💡",
                    "color": "#10B981",
                  },
                }
              : {
                  "title": "A different angle",
                  "emotion": "neutral",
                  "context_section": {
                    "title": "Original thought",
                    "content":
                        "I am too busy and don't have time to learn new things.",
                    "icon": "😫",
                  },
                  "highlight_section": {
                    "title": "New perspective",
                    "content":
                        "Being busy means there are many opportunities to learn through practice. I can learn by doing.",
                    "icon": "💡",
                    "color": "#10B981",
                  },
                },
        ),

        // 8. Progress ring
        (
          template: 'progress_chart_card_v1',
          data: _isZh
              ? {
                  "title": "年度阅读目标",
                  "subtitle": "还差 12 本书",
                  "current": 65,
                  "target": 100,
                  "center_text": "65%",
                  "items": [
                    {"label": "已完成", "value": 65, "color": "#6366F1"},
                    {"label": "剩余", "value": 35, "color": "#E2E8F0"},
                  ],
                }
              : {
                  "title": "Annual reading goal",
                  "subtitle": "12 books to go",
                  "current": 65,
                  "target": 100,
                  "center_text": "65%",
                  "items": [
                    {"label": "Completed", "value": 65, "color": "#6366F1"},
                    {"label": "Remaining", "value": 35, "color": "#E2E8F0"},
                  ],
                },
        ),

        // 9. Bubble chart
        (
          template: 'bubble_chart_card_v1',
          data: _isZh
              ? {
                  "title": "本周关键词",
                  "bubbles": [
                    {
                      "label": "Flutter",
                      "value": 100,
                      "color": "#6366F1",
                      "is_highlight": true,
                    },
                    {"label": "Dart", "value": 80, "color": "#8B5CF6"},
                    {"label": "AI", "value": 60, "color": "#EC4899"},
                    {"label": "设计", "value": 40, "color": "#10B981"},
                    {"label": "Memex", "value": 90, "color": "#F59E0B"},
                  ],
                  "footer": "基于 42 条笔记分析",
                }
              : {
                  "title": "Keywords of the week",
                  "bubbles": [
                    {
                      "label": "Flutter",
                      "value": 100,
                      "color": "#6366F1",
                      "is_highlight": true,
                    },
                    {"label": "Dart", "value": 80, "color": "#8B5CF6"},
                    {"label": "AI", "value": 60, "color": "#EC4899"},
                    {"label": "Design", "value": 40, "color": "#10B981"},
                    {"label": "Memex", "value": 90, "color": "#F59E0B"},
                  ],
                  "footer": "Analysis based on 42 notes",
                },
        ),

        // 10. Timeline
        (
          template: 'timeline_card_v1',
          data: _isZh
              ? {
                  "title": "今日时间流",
                  "items": [
                    {
                      "time": "09:00",
                      "title": "深度工作",
                      "content": "完成了架构设计图 V2.0，修复了三个关键 Bug。",
                      "icon": "💻",
                      "color": "#6366F1",
                      "is_filled_dot": false,
                    },
                    {
                      "time": "12:30",
                      "title": "午餐 & 休息",
                      "content": "轻食沙拉，之后散步 20 分钟。",
                      "icon": "🥗",
                      "color": "#10B981",
                      "is_filled_dot": false,
                    },
                    {
                      "time": "14:00",
                      "content": "待记录...",
                      "is_filled_dot": true,
                      "color": "#CBD5E1",
                    },
                  ],
                }
              : {
                  "title": "Today's timeline",
                  "items": [
                    {
                      "time": "09:00",
                      "title": "Deep work",
                      "content":
                          "Finished architecture diagram v2.0 and fixed three critical bugs.",
                      "icon": "💻",
                      "color": "#6366F1",
                      "is_filled_dot": false,
                    },
                    {
                      "time": "12:30",
                      "title": "Lunch & break",
                      "content": "Light salad, followed by a 20-minute walk.",
                      "icon": "🥗",
                      "color": "#10B981",
                      "is_filled_dot": false,
                    },
                    {
                      "time": "14:00",
                      "content": "To be filled...",
                      "is_filled_dot": true,
                      "color": "#CBD5E1",
                    },
                  ],
                },
        ),
      ];
}
