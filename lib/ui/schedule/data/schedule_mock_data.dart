import 'package:flutter/material.dart';

import '../models/schedule_item.dart';

// =============================================================================
// Mock Data Sets (Three different interaction designs)
// =============================================================================

class ScheduleMockData {
  /// Interaction 1: Daily Focus - Today's schedule + todos with priority
  static List<ScheduleItem> get dailyFocusData {
    final now = DateTime.now();
    return [
      ScheduleItem(
        id: 'df-1',
        title: '晨间站会',
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.completed,
        startTime: DateTime(now.year, now.month, now.day, 9, 30),
        endTime: DateTime(now.year, now.month, now.day, 10, 0),
        location: '会议室 A',
        description: '团队每日站会，同步昨日进展与今日计划',
        tags: ['工作', '会议'],
        completedAt: DateTime(now.year, now.month, now.day, 10, 5),
        relatedEvents: [
          RelatedEvent(
            id: 're-1',
            title: '创建了会议记录卡片',
            type: 'card',
            timestamp: DateTime(now.year, now.month, now.day, 10, 10),
          ),
        ],
      ),
      ScheduleItem(
        id: 'df-2',
        title: '完成 Q3 产品需求文档',
        type: ScheduleItemType.todo,
        status: ScheduleItemStatus.inProgress,
        priority: 3,
        startTime: DateTime(now.year, now.month, now.day, 10, 30),
        description: '整理并输出 Q3 产品规划文档，包含用户故事和优先级排序',
        tags: ['工作', '文档'],
        relatedEvents: [
          RelatedEvent(
            id: 're-2',
            title: '在聊天中提到此任务',
            type: 'chat',
            timestamp: DateTime(now.year, now.month, now.day, 9, 0),
          ),
        ],
      ),
      ScheduleItem(
        id: 'df-3',
        title: '午餐 - 与设计师讨论 UI 方案',
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.pending,
        startTime: DateTime(now.year, now.month, now.day, 12, 0),
        endTime: DateTime(now.year, now.month, now.day, 13, 30),
        location: '公司食堂',
        description: '边吃边聊，讨论新版首页的视觉设计方案',
        tags: ['午餐', '设计'],
      ),
      ScheduleItem(
        id: 'df-4',
        title: '代码审查：PR #284',
        type: ScheduleItemType.todo,
        status: ScheduleItemStatus.pending,
        priority: 2,
        startTime: DateTime(now.year, now.month, now.day, 14, 0),
        description: '审查后端 API 优化相关的 Pull Request',
        tags: ['工作', '代码'],
      ),
      ScheduleItem(
        id: 'df-5',
        title: '购买周末露营装备',
        type: ScheduleItemType.todo,
        status: ScheduleItemStatus.pending,
        priority: 1,
        description: '帐篷、睡袋、便携炉具',
        tags: ['生活', '购物'],
      ),
      ScheduleItem(
        id: 'df-6',
        title: '健身 - 胸肌训练',
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.pending,
        startTime: DateTime(now.year, now.month, now.day, 18, 30),
        endTime: DateTime(now.year, now.month, now.day, 19, 30),
        location: '乐刻健身',
        description: '卧推 4 组 + 飞鸟 3 组 + 俯卧撑',
        tags: ['健康', '运动'],
      ),
    ];
  }

  /// Interaction 2: Weekly Overview - Week view with time blocks
  static List<ScheduleItem> get weeklyOverviewData {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return [
      // Monday
      ScheduleItem(
        id: 'wo-1',
        title: '周一：项目启动会',
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.completed,
        startTime: DateTime(monday.year, monday.month, monday.day, 10, 0),
        endTime: DateTime(monday.year, monday.month, monday.day, 11, 30),
        location: '线上 - Zoom',
        description: '新项目 kickoff，确定里程碑和分工',
        tags: ['工作', '会议'],
        completedAt: DateTime(monday.year, monday.month, monday.day, 11, 35),
      ),
      ScheduleItem(
        id: 'wo-2',
        title: '整理项目文档',
        type: ScheduleItemType.todo,
        status: ScheduleItemStatus.completed,
        priority: 2,
        startTime: DateTime(monday.year, monday.month, monday.day, 14, 0),
        completedAt: DateTime(monday.year, monday.month, monday.day, 16, 0),
        tags: ['工作', '文档'],
      ),
      // Tuesday
      ScheduleItem(
        id: 'wo-3',
        title: '周二：用户访谈',
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.completed,
        startTime: monday.add(const Duration(days: 1, hours: 9)),
        endTime: monday.add(const Duration(days: 1, hours: 11)),
        location: '用户公司',
        description: '访谈 3 位核心用户，收集反馈',
        tags: ['工作', '用户'],
        completedAt: monday.add(const Duration(days: 1, hours: 11, minutes: 30)),
      ),
      // Wednesday (today-ish)
      ScheduleItem(
        id: 'wo-4',
        title: '周三：设计评审',
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.pending,
        startTime: monday.add(const Duration(days: 2, hours: 14)),
        endTime: monday.add(const Duration(days: 2, hours: 15, minutes: 30)),
        location: '设计室',
        description: '评审新版 UI 设计稿',
        tags: ['工作', '设计'],
      ),
      ScheduleItem(
        id: 'wo-5',
        title: '完成周报',
        type: ScheduleItemType.todo,
        status: ScheduleItemStatus.pending,
        priority: 2,
        startTime: monday.add(const Duration(days: 2, hours: 16)),
        tags: ['工作', '报告'],
      ),
      // Thursday
      ScheduleItem(
        id: 'wo-6',
        title: '周四：技术分享会',
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.pending,
        startTime: monday.add(const Duration(days: 3, hours: 15)),
        endTime: monday.add(const Duration(days: 3, hours: 16)),
        location: '大会议室',
        description: 'Flutter 性能优化实践分享',
        tags: ['工作', '分享'],
      ),
      // Friday
      ScheduleItem(
        id: 'wo-7',
        title: '周五：团队聚餐',
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.pending,
        startTime: monday.add(const Duration(days: 4, hours: 18)),
        endTime: monday.add(const Duration(days: 4, hours: 20)),
        location: '海底捞',
        description: '季度团队建设活动',
        tags: ['团建', '聚餐'],
      ),
    ];
  }

  /// Interaction 4: Adaptive Cards - AI chooses card style per item
  static List<ScheduleItem> get adaptiveCardData {
    final now = DateTime.now();
    return [
      // Hero item: highest priority
      ScheduleItem(
        id: 'ac-1',
        title: 'Q3 产品架构评审',
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.pending,
        priority: 3,
        startTime: DateTime(now.year, now.month, now.day, 14, 0),
        endTime: DateTime(now.year, now.month, now.day, 16, 0),
        location: '大会议室',
        description: '这是本季度最重要的技术决策会议，需要所有核心成员参与。评审新模块的架构设计方案，确定技术选型。',
        tags: ['重要', '会议', '架构'],
        relatedEvents: [
          RelatedEvent(
            id: 'ac-re-1',
            title: '架构草案已分享到团队',
            type: 'doc',
            timestamp: DateTime(now.year, now.month, now.day, 9, 0),
          ),
        ],
      ),
      // Article-style item
      ScheduleItem(
        id: 'ac-2',
        title: '上周用户访谈总结',
        type: ScheduleItemType.todo,
        status: ScheduleItemStatus.pending,
        priority: 2,
        description: '## 关键发现\n\n- 3/5 用户提到搜索功能难用\n- 新手引导流程过于冗长\n- 收藏功能使用率超出预期\n\n## 下一步行动\n\n1. 优化搜索交互\n2. 简化 onboarding\n3. 增强收藏管理',
        tags: ['用户研究', '文档'],
      ),
      // Quote-style item
      ScheduleItem(
        id: 'ac-3',
        title: '记住：今天下午的演示不要迟到',
        type: ScheduleItemType.todo,
        status: ScheduleItemStatus.pending,
        priority: 3,
        description: '投资人演示，CEO 会出席',
        tags: ['重要', '提醒'],
      ),
      // Task with subtasks
      ScheduleItem(
        id: 'ac-4',
        title: '发布 v2.1 版本',
        type: ScheduleItemType.todo,
        status: ScheduleItemStatus.inProgress,
        priority: 2,
        description: '本周五前完成发布',
        tags: ['工作', '发布'],
      ),
      // Simple event
      ScheduleItem(
        id: 'ac-5',
        title: '团队午餐',
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.pending,
        startTime: DateTime(now.year, now.month, now.day, 12, 0),
        endTime: DateTime(now.year, now.month, now.day, 13, 0),
        location: '公司食堂',
        tags: ['午餐'],
      ),
      // Completed item (faded)
      ScheduleItem(
        id: 'ac-6',
        title: '晨间站会',
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.completed,
        startTime: DateTime(now.year, now.month, now.day, 9, 30),
        endTime: DateTime(now.year, now.month, now.day, 10, 0),
        completedAt: DateTime(now.year, now.month, now.day, 10, 5),
        tags: ['工作', '会议'],
      ),
      // Low priority compact item
      ScheduleItem(
        id: 'ac-7',
        title: '整理桌面文件',
        type: ScheduleItemType.todo,
        status: ScheduleItemStatus.pending,
        priority: 1,
        tags: ['整理'],
      ),
    ];
  }

  /// Interaction 5: Conversational Briefing - AI chat-style schedule
  static List<ScheduleItem> get conversationalData {
    final now = DateTime.now();
    return [
      ScheduleItem(
        id: 'cb-1',
        title: '晨间站会',
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.completed,
        startTime: DateTime(now.year, now.month, now.day, 9, 30),
        endTime: DateTime(now.year, now.month, now.day, 10, 0),
        completedAt: DateTime(now.year, now.month, now.day, 10, 5),
        location: '会议室 A',
        tags: ['工作', '会议'],
      ),
      ScheduleItem(
        id: 'cb-2',
        title: '完成 Q3 产品需求文档',
        type: ScheduleItemType.todo,
        status: ScheduleItemStatus.inProgress,
        priority: 3,
        startTime: DateTime(now.year, now.month, now.day, 10, 30),
        description: '整理并输出 Q3 产品规划文档',
        tags: ['工作', '文档'],
      ),
      ScheduleItem(
        id: 'cb-3',
        title: '午餐 - 与设计师讨论 UI 方案',
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.pending,
        startTime: DateTime(now.year, now.month, now.day, 12, 0),
        endTime: DateTime(now.year, now.month, now.day, 13, 30),
        location: '公司食堂',
        tags: ['午餐', '设计'],
      ),
      ScheduleItem(
        id: 'cb-4',
        title: '代码审查：PR #284',
        type: ScheduleItemType.todo,
        status: ScheduleItemStatus.pending,
        priority: 2,
        startTime: DateTime(now.year, now.month, now.day, 14, 0),
        tags: ['工作', '代码'],
      ),
      ScheduleItem(
        id: 'cb-5',
        title: '购买周末露营装备',
        type: ScheduleItemType.todo,
        status: ScheduleItemStatus.pending,
        priority: 1,
        description: '帐篷、睡袋、便携炉具',
        tags: ['生活', '购物'],
      ),
      ScheduleItem(
        id: 'cb-6',
        title: '健身 - 胸肌训练',
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.pending,
        startTime: DateTime(now.year, now.month, now.day, 18, 30),
        endTime: DateTime(now.year, now.month, now.day, 19, 30),
        location: '乐刻健身',
        tags: ['健康', '运动'],
      ),
    ];
  }

  /// Interaction 6: Magazine Narrative - editorial layout
  static List<ScheduleItem> get magazineData {
    final now = DateTime.now();
    return [
      // Hero: the most important event of the week
      ScheduleItem(
        id: 'mg-1',
        title: 'Q3 产品发布会',
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.pending,
        priority: 3,
        startTime: DateTime(now.year, now.month, now.day + 2, 14, 0),
        endTime: DateTime(now.year, now.month, now.day + 2, 16, 0),
        location: '总部大礼堂',
        description: '本季度最重要的产品发布会，将向全体用户展示全新功能。准备工作已经进入最后阶段，请确保所有演示材料就绪。',
        tags: ['重要', '发布', '全员'],
      ),
      // Day 1
      ScheduleItem(
        id: 'mg-2',
        title: '架构评审会议',
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.completed,
        startTime: DateTime(now.year, now.month, now.day - 1, 10, 0),
        endTime: DateTime(now.year, now.month, now.day - 1, 12, 0),
        completedAt: DateTime(now.year, now.month, now.day - 1, 12, 10),
        location: '会议室 B',
        description: '通过了微服务拆分方案',
        tags: ['工作', '技术'],
      ),
      ScheduleItem(
        id: 'mg-3',
        title: '用户反馈整理',
        type: ScheduleItemType.todo,
        status: ScheduleItemStatus.pending,
        priority: 2,
        startTime: DateTime(now.year, now.month, now.day, 9, 0),
        description: '整理过去一周收到的用户反馈，分类并提取 actionable items',
        tags: ['用户', '整理'],
      ),
      // Day 2
      ScheduleItem(
        id: 'mg-4',
        title: '设计评审',
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.pending,
        startTime: DateTime(now.year, now.month, now.day, 14, 0),
        endTime: DateTime(now.year, now.month, now.day, 15, 30),
        location: '设计室',
        description: '新版首页视觉设计稿评审',
        tags: ['工作', '设计'],
      ),
      ScheduleItem(
        id: 'mg-5',
        title: '技术分享：Flutter 性能优化',
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.pending,
        startTime: DateTime(now.year, now.month, now.day + 1, 15, 0),
        endTime: DateTime(now.year, now.month, now.day + 1, 16, 0),
        location: '大会议室',
        description: '分享 Flutter 渲染原理和性能调优实践',
        tags: ['分享', '技术'],
      ),
      // Quote-worthy reminder
      ScheduleItem(
        id: 'mg-6',
        title: '截止提醒：Q3 OKR 提交',
        type: ScheduleItemType.todo,
        status: ScheduleItemStatus.pending,
        priority: 3,
        startTime: DateTime(now.year, now.month, now.day + 3, 17, 0),
        description: '本周五下午 5 点前必须提交',
        tags: ['重要', '截止'],
      ),
      // Relaxation
      ScheduleItem(
        id: 'mg-7',
        title: '周末露营',
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.pending,
        startTime: DateTime(now.year, now.month, now.day + 5, 8, 0),
        endTime: DateTime(now.year, now.month, now.day + 5, 20, 0),
        location: '莫干山',
        description: '和朋友们一起的露营之旅',
        tags: ['生活', '户外'],
      ),
    ];
  }

  /// Interaction 3: Smart Agenda - AI-suggested priorities with time blocking
  static List<ScheduleItem> get smartAgendaData {
    final now = DateTime.now();
    return [
      ScheduleItem(
        id: 'sa-1',
        title: '回复客户邮件（紧急）',
        type: ScheduleItemType.todo,
        status: ScheduleItemStatus.completed,
        priority: 3,
        startTime: DateTime(now.year, now.month, now.day, 8, 0),
        completedAt: DateTime(now.year, now.month, now.day, 8, 20),
        description: '回复 ABC 公司关于合同条款的询问',
        tags: ['工作', '邮件'],
        relatedEvents: [
          RelatedEvent(
            id: 'sa-re-1',
            title: '收到客户邮件',
            type: 'email',
            timestamp: DateTime(now.year, now.month, now.day, 7, 30),
          ),
        ],
      ),
      ScheduleItem(
        id: 'sa-2',
        title: '深度工作：架构设计',
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.inProgress,
        startTime: DateTime(now.year, now.month, now.day, 9, 0),
        endTime: DateTime(now.year, now.month, now.day, 11, 0),
        location: '安静区',
        description: '专注时间段，设计新模块的架构方案',
        tags: ['工作', '深度'],
      ),
      ScheduleItem(
        id: 'sa-3',
        title: '跟进 Bug 修复进度',
        type: ScheduleItemType.todo,
        status: ScheduleItemStatus.pending,
        priority: 2,
        startTime: DateTime(now.year, now.month, now.day, 11, 30),
        description: '检查 #1421、#1423 的修复状态',
        tags: ['工作', 'Bug'],
      ),
      ScheduleItem(
        id: 'sa-4',
        title: '午休 + 冥想',
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.pending,
        startTime: DateTime(now.year, now.month, now.day, 12, 0),
        endTime: DateTime(now.year, now.month, now.day, 13, 0),
        description: '建议休息 20 分钟后进行 10 分钟冥想',
        tags: ['健康', '休息'],
      ),
      ScheduleItem(
        id: 'sa-5',
        title: '1-on-1 与直属领导',
        type: ScheduleItemType.event,
        status: ScheduleItemStatus.pending,
        startTime: DateTime(now.year, now.month, now.day, 14, 0),
        endTime: DateTime(now.year, now.month, now.day, 14, 30),
        location: '领导办公室',
        description: '月度一对一沟通，讨论职业发展',
        tags: ['工作', '1-on-1'],
      ),
      ScheduleItem(
        id: 'sa-6',
        title: '学习：Flutter 3.24 新特性',
        type: ScheduleItemType.todo,
        status: ScheduleItemStatus.pending,
        priority: 1,
        startTime: DateTime(now.year, now.month, now.day, 15, 0),
        description: '阅读官方文档，尝试新 Widget',
        tags: ['学习', '技术'],
      ),
      ScheduleItem(
        id: 'sa-7',
        title: '阅读《深度工作》30 分钟',
        type: ScheduleItemType.todo,
        status: ScheduleItemStatus.pending,
        priority: 1,
        description: '每天保持阅读习惯',
        tags: ['阅读', '自我提升'],
      ),
    ];
  }
}
