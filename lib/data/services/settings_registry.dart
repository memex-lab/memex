import 'dart:io';

import 'package:memex/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memex/config/app_flavor.dart';
import 'package:memex/domain/models/settings_item.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/ui/settings/widgets/ai_service_setup_page.dart';
import 'package:memex/ui/settings/widgets/system_authorization_page.dart';
import 'package:memex/ui/settings/widgets/model_config_list_page.dart';
import 'package:memex/ui/settings/widgets/agent_config_list_page.dart';
import 'package:memex/ui/settings/widgets/settings_page.dart';
import 'package:memex/ui/settings/widgets/debug_settings_page.dart';
import 'package:memex/ui/settings/widgets/data_storage_page.dart';
import 'package:memex/ui/settings/widgets/backup_restore_page.dart';
import 'package:memex/ui/settings/widgets/location_context_settings_page.dart';
import 'package:memex/ui/memory/view_models/memory_viewmodel.dart';
import 'package:memex/ui/memory/widgets/memory_screen.dart';
import 'package:memex/ui/character/view_models/character_viewmodel.dart';
import 'package:memex/ui/character/widgets/character_config_screen.dart';
import 'package:memex/utils/user_storage.dart';

/// Settings registry. Maintains a static list of all searchable settings items.
/// Organized by feature module, extensible for new entries.
class SettingsRegistry {
  SettingsRegistry._();

  /// All registered settings items.
  /// Uses getters so l10n strings resolve to the current locale at access time.
  static List<SettingsItem> get allItems => [
        ..._personalCenterItems,
        ..._settingsPageItems,
      ];

  // ---------------------------------------------------------------------------
  // PersonalCenterScreen level items
  // ---------------------------------------------------------------------------

  static List<SettingsItem> get _personalCenterItems => [
        SettingsItem(
          id: 'system_authorization',
          titleGetter: () => UserStorage.l10n.systemAuthorization,
          descriptionGetter: () => UserStorage.l10n.systemAuthorization,
          keywords: const [
            '权限',
            '授权',
            '通知',
            '相册',
            '麦克风',
            '定位',
            '健康',
            '运动',
            '步数',
            'permission',
            'authorization',
            'notification',
            'photos',
            'microphone',
            'location',
            'health',
            'fitness',
          ],
          icon: Icons.security_outlined,
          navigationTarget: NavigationTarget(
            pageBuilder: (_) => const SystemAuthorizationPage(),
          ),
          parentPathGetter: () => [UserStorage.l10n.personalCenter],
        ),
        if (AppConfig.enableMemexModelService)
          SettingsItem(
            id: 'ai_service',
            titleGetter: () => UserStorage.l10n.aiService,
            descriptionGetter: () =>
                UserStorage.l10n.aiServiceSettingsDescription,
            keywords: const [
              'AI服务',
              '付费',
              '充值',
              '余额',
              '普通配置',
              '开通',
              'memex模型服务',
              'ai service',
              'memex model service',
              'paid',
              'payment',
              'top up',
              'balance',
              'subscription',
            ],
            icon: Icons.auto_awesome_rounded,
            navigationTarget: NavigationTarget(
              pageBuilder: (_) => const AiServiceSetupPage(),
            ),
            parentPathGetter: () => [UserStorage.l10n.personalCenter],
          ),
        SettingsItem(
          id: 'model_config',
          titleGetter: () => UserStorage.l10n.modelConfig,
          descriptionGetter: () => UserStorage.l10n.modelConfiguration,
          keywords: const [
            '模型',
            'API',
            '密钥',
            'LLM',
            '大模型',
            '配置',
            '接口',
            '服务商',
            'token',
            'model',
            'api key',
            'endpoint',
            'llm',
            'openai',
            'claude',
            'gemini',
            'deepseek',
            'provider',
          ],
          icon: Icons.settings_input_component_outlined,
          navigationTarget: NavigationTarget(
            pageBuilder: (_) => const ModelConfigListPage(),
          ),
          parentPathGetter: () => [UserStorage.l10n.personalCenter],
        ),
        SettingsItem(
          id: 'agent_config',
          titleGetter: () => UserStorage.l10n.agentConfig,
          descriptionGetter: () => UserStorage.l10n.agentConfiguration,
          keywords: const [
            'agent',
            '智能体',
            '代理',
            '分配模型',
            '卡片处理',
            '知识提取',
            '评论生成',
            '聊天',
            '图片分析',
            'agent config',
            'agent model',
            'card agent',
            'knowledge',
            'comment',
            'chat',
          ],
          icon: Icons.people_outline,
          navigationTarget: NavigationTarget(
            pageBuilder: (_) => const AgentConfigListPage(),
          ),
          parentPathGetter: () => [UserStorage.l10n.personalCenter],
        ),
        SettingsItem(
          id: 'memory',
          titleGetter: () => UserStorage.l10n.memoryTitle,
          descriptionGetter: () => UserStorage.l10n.memoryTitle,
          keywords: const [
            '记忆',
            '了解',
            '个人信息',
            '偏好',
            '用户画像',
            '习惯',
            '兴趣',
            'memory',
            'remember',
            'personal info',
            'preferences',
            'profile',
            'habit',
            'interest',
          ],
          icon: Icons.memory,
          navigationTarget: NavigationTarget(
            pageBuilder: (context) {
              final vm = MemoryViewModel(router: context.read<MemexRouter>());
              vm.loadMemory();
              return MemoryScreen(viewModel: vm);
            },
          ),
          parentPathGetter: () => [UserStorage.l10n.personalCenter],
        ),
        SettingsItem(
          id: 'character_config',
          titleGetter: () => UserStorage.l10n.aiCharacterConfig,
          descriptionGetter: () => UserStorage.l10n.configureAiCharacter,
          keywords: const [
            '角色',
            '性格',
            '人设',
            '头像',
            'AI角色',
            '评论风格',
            '语气',
            '虚拟人物',
            'character',
            'persona',
            'personality',
            'avatar',
            'ai character',
            'tone',
            'style',
          ],
          icon: Icons.psychology,
          navigationTarget: NavigationTarget(
            pageBuilder: (context) {
              final vm =
                  CharacterViewModel(router: context.read<MemexRouter>());
              vm.loadCharacters();
              return CharacterConfigScreen(viewModel: vm);
            },
          ),
          parentPathGetter: () => [UserStorage.l10n.personalCenter],
        ),
        SettingsItem(
          id: 'settings',
          titleGetter: () => UserStorage.l10n.settings,
          descriptionGetter: () => UserStorage.l10n.settings,
          keywords: const [
            '设置',
            '通用',
            '偏好',
            '选项',
            '配置',
            'settings',
            'general',
            'preferences',
            'options',
            'config',
          ],
          icon: Icons.settings_outlined,
          navigationTarget: NavigationTarget(
            pageBuilder: (_) => const SettingsPage(),
          ),
          parentPathGetter: () => [UserStorage.l10n.personalCenter],
        ),
        SettingsItem(
          id: 'debug',
          titleGetter: () => 'Debug',
          descriptionGetter: () => 'Debug',
          keywords: const [
            '调试',
            '开发',
            '日志',
            '重建索引',
            '清除数据',
            '重新处理',
            '搜索索引',
            '退出登录',
            'debug',
            'developer',
            'logs',
            'rebuild index',
            'clear data',
            'reprocess',
            'logout',
          ],
          icon: Icons.bug_report_outlined,
          navigationTarget: NavigationTarget(
            pageBuilder: (_) => DebugSettingsPage(
              onClearToken: () async {},
              onClearData: () async {},
              onClearFailedAgentContexts: () async {},
              onReprocessCards: () async {},
              onReprocessComments: () async {},
              onReprocessKnowledgeBase: () async {},
              onRebuildSearchIndex: () async {},
              isClearingData: false,
              isClearingFailedAgentContexts: false,
              isReprocessingCards: false,
              isReprocessingComments: false,
              isReprocessingKnowledgeBase: false,
              isRebuildingSearchIndex: false,
            ),
          ),
          parentPathGetter: () => [UserStorage.l10n.personalCenter],
        ),
      ];

  // ---------------------------------------------------------------------------
  // SettingsPage level items
  // ---------------------------------------------------------------------------

  static List<SettingsItem> get _settingsPageItems => [
        SettingsItem(
          id: 'settings.language',
          titleGetter: () => UserStorage.l10n.languageSettings,
          descriptionGetter: () => UserStorage.l10n.languageSettingsDesc,
          keywords: const [
            '语言',
            '中文',
            '英文',
            '切换语言',
            '界面语言',
            '翻译',
            'language',
            'english',
            'chinese',
            'locale',
            'switch language',
            'i18n',
          ],
          icon: Icons.language,
          navigationTarget: NavigationTarget(
            pageBuilder: (_) => const SettingsPage(),
          ),
          parentPathGetter: () =>
              [UserStorage.l10n.personalCenter, UserStorage.l10n.settings],
        ),
        SettingsItem(
          id: 'settings.local_speech',
          titleGetter: () => UserStorage.l10n.useLocalSpeechToTextTitle,
          descriptionGetter: () => UserStorage.l10n.useLocalSpeechToTextDesc,
          keywords: const [
            '语音',
            '识别',
            '转文字',
            '本地语音',
            '录音',
            '输入',
            '麦克风',
            'speech',
            'recognition',
            'voice',
            'speech to text',
            'stt',
            'whisper',
            'recording',
            'dictation',
          ],
          icon: Icons.graphic_eq,
          navigationTarget: NavigationTarget(
            pageBuilder: (_) => const SettingsPage(),
          ),
          parentPathGetter: () =>
              [UserStorage.l10n.personalCenter, UserStorage.l10n.settings],
        ),
        if (Platform.isAndroid && AppFlavor.isEarly)
          SettingsItem(
            id: 'settings.early_updates',
            titleGetter: () => UserStorage.l10n.earlyUpdateSettingsTitle,
            descriptionGetter: () => UserStorage.l10n.earlyUpdateSettingsDesc,
            keywords: const [
              '更新',
              '自动更新',
              'Early',
              '预发布',
              '内测',
              'APK',
              'GitHub',
              'Wi-Fi',
              'update',
              'auto update',
              'pre-release',
              'prerelease',
              'download',
              'install',
              'wifi',
            ],
            icon: Icons.system_update_alt,
            navigationTarget: NavigationTarget(
              pageBuilder: (_) => const SettingsPage(),
            ),
            parentPathGetter: () =>
                [UserStorage.l10n.personalCenter, UserStorage.l10n.settings],
          ),
        SettingsItem(
          id: 'settings.show_insight',
          titleGetter: () => UserStorage.l10n.showInsightTextTitle,
          descriptionGetter: () => UserStorage.l10n.showInsightTextDesc,
          keywords: const [
            '洞察',
            '文本',
            '显示',
            '隐藏',
            '卡片详情',
            '卡片详情页',
            '时间线',
            'insight',
            'text',
            'show',
            'hide',
            'card text',
            'card detail',
            'timeline',
          ],
          icon: Icons.lightbulb_outline,
          navigationTarget: NavigationTarget(
            pageBuilder: (_) => const SettingsPage(),
          ),
          parentPathGetter: () =>
              [UserStorage.l10n.personalCenter, UserStorage.l10n.settings],
        ),
        SettingsItem(
          id: 'settings.character_comment',
          titleGetter: () => UserStorage.l10n.enableCharacterCommentTitle,
          descriptionGetter: () => UserStorage.l10n.enableCharacterCommentDesc,
          keywords: const [
            '评论',
            '角色评论',
            '评价',
            '反馈',
            '卡片评论',
            '卡片详情',
            '卡片详情页',
            '开关',
            'comment',
            'character comment',
            'feedback',
            'reaction',
            'card detail',
            'card comment',
            'toggle',
          ],
          icon: Icons.chat_bubble_outline,
          navigationTarget: NavigationTarget(
            pageBuilder: (_) => const SettingsPage(),
          ),
          parentPathGetter: () =>
              [UserStorage.l10n.personalCenter, UserStorage.l10n.settings],
        ),
        SettingsItem(
          id: 'settings.max_comment_characters',
          titleGetter: () => UserStorage.l10n.maxCommentCharactersTitle,
          descriptionGetter: () => UserStorage.l10n.maxCommentCharactersDesc,
          keywords: const [
            '评论数量',
            '角色数量',
            '最大数量',
            '几个角色',
            '多少角色',
            '评论人数',
            '卡片详情',
            '卡片详情页',
            'max characters',
            'comment count',
            'number of characters',
            'how many',
            'card detail',
          ],
          icon: Icons.groups_outlined,
          navigationTarget: NavigationTarget(
            pageBuilder: (_) => const SettingsPage(),
          ),
          parentPathGetter: () =>
              [UserStorage.l10n.personalCenter, UserStorage.l10n.settings],
        ),
        SettingsItem(
          id: 'settings.data_storage',
          titleGetter: () => UserStorage.l10n.dataStorage,
          descriptionGetter: () => UserStorage.l10n.dataStorageDescriptionIOS,
          keywords: const [
            '存储',
            '数据',
            '路径',
            'iCloud',
            '存储位置',
            '文件',
            '空间',
            '迁移',
            'storage',
            'data',
            'path',
            'icloud',
            'location',
            'file',
            'space',
            'migrate',
          ],
          icon: Icons.folder_outlined,
          navigationTarget: NavigationTarget(
            pageBuilder: (_) => const DataStoragePage(),
          ),
          parentPathGetter: () =>
              [UserStorage.l10n.personalCenter, UserStorage.l10n.settings],
        ),
        SettingsItem(
          id: 'settings.location_context',
          titleGetter: () => UserStorage.l10n.location,
          descriptionGetter: () => UserStorage.l10n.locationContextDescription,
          keywords: const [
            '定位',
            '位置',
            '地理位置',
            '当前位置',
            '逆地理编码',
            '高德',
            'OpenStreetMap',
            'GPS',
            '城市',
            '街区',
            'location',
            'current location',
            'geocoding',
            'reverse geocoding',
            'amap',
            'osm',
            'city',
            'neighborhood',
          ],
          icon: Icons.my_location_outlined,
          navigationTarget: NavigationTarget(
            pageBuilder: (_) => const LocationContextSettingsPage(),
          ),
          parentPathGetter: () =>
              [UserStorage.l10n.personalCenter, UserStorage.l10n.settings],
        ),
        SettingsItem(
          id: 'settings.backup_restore',
          titleGetter: () => UserStorage.l10n.backupAndRestore,
          descriptionGetter: () => UserStorage.l10n.backupDescription,
          keywords: const [
            '备份',
            '恢复',
            '自动备份',
            '快照',
            '时间点',
            '导出',
            '导入',
            '数据迁移',
            '换手机',
            '同步',
            'backup',
            'restore',
            'automatic backup',
            'snapshot',
            'restore point',
            'export',
            'import',
            'migrate',
            'sync',
            'transfer',
          ],
          icon: Icons.backup_outlined,
          navigationTarget: NavigationTarget(
            pageBuilder: (_) => const BackupRestorePage(),
          ),
          parentPathGetter: () =>
              [UserStorage.l10n.personalCenter, UserStorage.l10n.settings],
        ),
        SettingsItem(
          id: 'settings.privacy_policy',
          titleGetter: () => UserStorage.l10n.privacyPolicy,
          descriptionGetter: () => UserStorage.l10n.privacyPolicyDesc,
          keywords: const [
            '隐私',
            '政策',
            '条款',
            '协议',
            '数据安全',
            '用户协议',
            'privacy',
            'policy',
            'terms',
            'agreement',
            'data safety',
          ],
          icon: Icons.privacy_tip_outlined,
          navigationTarget: NavigationTarget(
            pageBuilder: (_) => const SettingsPage(),
          ),
          parentPathGetter: () =>
              [UserStorage.l10n.personalCenter, UserStorage.l10n.settings],
        ),
      ];
}
