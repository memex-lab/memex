import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:memex/config/app_flavor.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/settings/widgets/backup_restore_page.dart';
import 'package:memex/ui/settings/widgets/data_storage_page.dart';
import 'package:memex/ui/settings/widgets/location_context_settings_page.dart';
import 'package:memex/ui/settings/widgets/early_update_settings_card.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/comment_settings_service.dart'
    show CommentSettings;
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/main.dart' show rootShellKey;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _currentLang = 'en';
  bool _useLocalSpeechToText = true;
  CommentSettings _commentSettings = const CommentSettings();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final locale = await UserStorage.getLocale();
    final useLocalSpeechToText = await UserStorage.getUseLocalSpeechToText();
    final commentSettings = await MemexRouter().getCommentSettings();
    if (mounted) {
      setState(() {
        _currentLang = locale.languageCode == 'zh' ? 'zh' : 'en';
        _useLocalSpeechToText = useLocalSpeechToText;
        _commentSettings = commentSettings;
      });
    }
  }

  Future<void> _changeLanguage(String langCode) async {
    if (_currentLang == langCode) return;
    final locale = Locale(langCode);
    await UserStorage.setLocale(locale);
    await UserStorage.initL10n();
    if (mounted) {
      setState(() => _currentLang = langCode);
    }
  }

  Future<void> _updateUseLocalSpeechToText(bool value) async {
    await UserStorage.setUseLocalSpeechToText(value);
    if (mounted) {
      setState(() => _useLocalSpeechToText = value);
    }
  }

  Future<void> _updateShowInsightText(bool value) async {
    final updated = _commentSettings.copyWith(showInsightText: value);
    await MemexRouter().saveCommentSettings(updated);
    if (mounted) {
      setState(() => _commentSettings = updated);
    }
  }

  Future<void> _updateEnableCharacterComment(bool value) async {
    final updated = _commentSettings.copyWith(enableCharacterComment: value);
    await MemexRouter().saveCommentSettings(updated);
    if (mounted) {
      setState(() => _commentSettings = updated);
    }
  }

  Future<void> _updateMaxCommentCharacters(int value) async {
    final updated = _commentSettings.copyWith(maxCommentCharacters: value);
    await MemexRouter().saveCommentSettings(updated);
    if (mounted) {
      setState(() => _commentSettings = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UserStorage.l10n.settings),
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textSecondary.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.language, color: AppColors.primary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            UserStorage.l10n.languageSettings,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            UserStorage.l10n.languageSettingsDesc,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildLangChip('English', 'en'),
                    const SizedBox(width: 10),
                    _buildLangChip('中文', 'zh'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textSecondary.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(
                Icons.graphic_eq,
                color: AppColors.primary,
                size: 22,
              ),
              title: Text(
                UserStorage.l10n.useLocalSpeechToTextTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  UserStorage.l10n.useLocalSpeechToTextDesc,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ),
              value: _useLocalSpeechToText,
              onChanged: _updateUseLocalSpeechToText,
            ),
          ),
          const SizedBox(height: 16),
          if (Platform.isAndroid && AppFlavor.isEarly) ...[
            EarlyUpdateSettingsCard(),
            const SizedBox(height: 16),
          ],
          // Show Insight Text toggle
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textSecondary.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(
                Icons.lightbulb_outline,
                color: AppColors.primary,
                size: 22,
              ),
              title: Text(
                UserStorage.l10n.showInsightTextTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  UserStorage.l10n.showInsightTextDesc,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ),
              value: _commentSettings.showInsightText,
              onChanged: _updateShowInsightText,
            ),
          ),
          const SizedBox(height: 16),
          // Enable Character Comment toggle
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textSecondary.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(
                Icons.chat_bubble_outline,
                color: AppColors.primary,
                size: 22,
              ),
              title: Text(
                UserStorage.l10n.enableCharacterCommentTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  UserStorage.l10n.enableCharacterCommentDesc,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ),
              value: _commentSettings.enableCharacterComment,
              onChanged: _updateEnableCharacterComment,
            ),
          ),
          // Max comment characters slider (only visible when comments are enabled)
          if (_commentSettings.enableCharacterComment) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textSecondary.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.groups_outlined,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              UserStorage.l10n.maxCommentCharactersTitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              UserStorage.l10n.maxCommentCharactersDesc,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_commentSettings.maxCommentCharacters}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _commentSettings.maxCommentCharacters.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    activeColor: AppColors.primary,
                    onChanged: (v) => _updateMaxCommentCharacters(v.round()),
                  ),
                ],
              ),
            ),
          ],
          // Data Storage (iOS only — Android has no storage options to choose)
          if (Platform.isIOS) ...[
            const SizedBox(height: 16),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DataStoragePage(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textSecondary.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.folder_outlined,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              UserStorage.l10n.dataStorage,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              UserStorage.l10n.dataStorageDescriptionIOS,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LocationContextSettingsPage(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textSecondary.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.my_location_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            UserStorage.l10n.location,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            UserStorage.l10n.locationContextDescription,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Backup & Restore
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BackupRestorePage(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textSecondary.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.backup_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            UserStorage.l10n.backupAndRestore,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            UserStorage.l10n.backupDescription,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Privacy Policy
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                launchUrl(
                  Uri.parse(
                    'https://github.com/memex-lab/memex/blob/main/PRIVACY_POLICY.md',
                  ),
                  mode: LaunchMode.externalApplication,
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textSecondary.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.privacy_tip_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            UserStorage.l10n.privacyPolicy,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            UserStorage.l10n.privacyPolicyDesc,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.open_in_new,
                      color: Color(0xFFCBD5E1),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Delete Account
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showDeleteAccountDialog,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textSecondary.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_forever_outlined,
                      color: Colors.red,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            UserStorage.l10n.deleteAccount,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            UserStorage.l10n.deleteAccountDesc,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    final l10n = UserStorage.l10n;
    final userId = await UserStorage.getUserId() ?? '';
    final controller = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isMatch = controller.text == userId;
            final showError = controller.text.isNotEmpty && !isMatch;
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(l10n.deleteAccountConfirmTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.deleteAccountConfirmMessage),
                  const SizedBox(height: 16),
                  Text(
                    l10n.deleteAccountTypeName(userId),
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: l10n.deleteAccountTypeHint,
                      border: const OutlineInputBorder(),
                      isDense: true,
                      errorText:
                          showError ? l10n.deleteAccountTypeName(userId) : null,
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(UserStorage.l10n.cancel),
                ),
                TextButton(
                  onPressed:
                      isMatch ? () => Navigator.pop(context, true) : null,
                  child: Text(
                    l10n.deleteAccount,
                    style: TextStyle(color: isMatch ? Colors.red : Colors.grey),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || !mounted) return;

    // Perform deletion
    try {
      // 1. Stop background services that use the database
      LocalTaskExecutor.instance.stop();
      await EventBusService.instance.disconnect();

      // 2. Close and delete database
      if (AppDatabase.isInitialized) {
        await AppDatabase.instance.close();
      }

      // 3. Delete workspace files
      try {
        final dataRoot = FileSystemService.instance.dataRoot;
        final dir = Directory(dataRoot);
        if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
      } catch (_) {
        // workspace may not exist
      }

      // 4. Clear all SharedPreferences
      await UserStorage.clearAllData();

      // 5. Navigate back to home and let RootShell re-check user state
      if (mounted) {
        // Pop settings page first so we're back at the main screen
        Navigator.of(context).popUntil((route) => route.isFirst);
        // Then tell RootShell to re-check — it will find no user and show setup
        rootShellKey.currentState?.resetAndRecheck();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(UserStorage.l10n.operationFailed('$e'))),
        );
      }
    }
  }

  Widget _buildLangChip(String label, String langCode) {
    final isSelected = _currentLang == langCode;
    return GestureDetector(
      onTap: () => _changeLanguage(langCode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
