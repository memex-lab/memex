import 'package:flutter/material.dart';
import 'package:memex/data/services/whisper_service.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/settings/widgets/model_stats_page.dart';
import 'package:memex/ui/insight/widgets/insight_template_gallery_page.dart';
import 'package:memex/ui/timeline/widgets/timeline_template_gallery_page.dart';
import 'package:memex/ui/settings/widgets/log_viewer_page.dart';
import 'package:memex/ui/settings/widgets/async_task_list_page.dart';
import 'package:memex/ui/settings/widgets/custom_agent_config_page.dart';
import 'package:memex/ui/settings/widgets/skills_management_page.dart';
import 'package:memex/utils/toast_helper.dart';

class DebugSettingsPage extends StatelessWidget {
  final Future<void> Function() onClearToken;
  final Future<void> Function() onClearData;
  final Future<void> Function() onReprocessCards;
  final Future<void> Function() onReprocessComments;
  final Future<void> Function() onReprocessKnowledgeBase;
  final Future<void> Function() onRebuildSearchIndex;
  final bool isClearingData;
  final bool isReprocessingCards;
  final bool isReprocessingComments;
  final bool isReprocessingKnowledgeBase;
  final bool isRebuildingSearchIndex;

  const DebugSettingsPage({
    super.key,
    required this.onClearToken,
    required this.onClearData,
    required this.onReprocessCards,
    required this.onReprocessComments,
    required this.onReprocessKnowledgeBase,
    required this.onRebuildSearchIndex,
    required this.isClearingData,
    required this.isReprocessingCards,
    required this.isReprocessingComments,
    required this.isReprocessingKnowledgeBase,
    required this.isRebuildingSearchIndex,
  });

  Future<void> _deleteSpeechModel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(UserStorage.l10n.deleteSpeechModel),
        content: Text(UserStorage.l10n.confirmDeleteSpeechModelMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(UserStorage.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(UserStorage.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final deleted = await WhisperService.instance.deleteDownloadedModel();
      if (!context.mounted) return;

      if (deleted) {
        ToastHelper.showSuccess(
          context,
          UserStorage.l10n.speechModelDeletedSuccess,
        );
      } else {
        ToastHelper.showInfo(
          context,
          UserStorage.l10n.speechModelNotDownloaded,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ToastHelper.showError(
        context,
        UserStorage.l10n.speechModelDeleteFailed(e),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debugging'),
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _buildFunctionTab(
            context: context,
            icon: Icons.bar_chart_outlined,
            title: UserStorage.l10n.modelUsageStats,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ModelStatsPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildFunctionTab(
            context: context,
            icon: Icons.list_alt,
            title: UserStorage.l10n.asyncTaskList,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AsyncTaskListPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildFunctionTab(
            context: context,
            icon: Icons.extension_outlined,
            title: UserStorage.l10n.customAgents,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomAgentConfigPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildFunctionTab(
            context: context,
            icon: Icons.folder_special_outlined,
            title: UserStorage.l10n.skillsManagement,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SkillsManagementPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildFunctionTab(
            context: context,
            icon: Icons.dashboard_customize_outlined,
            title: UserStorage.l10n.insightCardTemplates,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InsightTemplateGalleryPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildFunctionTab(
            context: context,
            icon: Icons.view_timeline_outlined,
            title: UserStorage.l10n.timelineCardTemplates,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TimelineTemplateGalleryPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildFunctionTab(
            context: context,
            icon: Icons.delete_outline,
            title: UserStorage.l10n.clearLocalToken,
            onTap: onClearToken,
          ),
          const SizedBox(height: 12),
          _buildFunctionTab(
            context: context,
            icon: Icons.delete_sweep_outlined,
            title: UserStorage.l10n.deleteSpeechModel,
            onTap: () => _deleteSpeechModel(context),
          ),
          const SizedBox(height: 12),
          _buildFunctionTab(
            context: context,
            icon: Icons.cleaning_services_outlined,
            title: UserStorage.l10n.clearData,
            onTap: onClearData,
            isLoading: isClearingData,
          ),
          const SizedBox(height: 12),
          _buildFunctionTab(
            context: context,
            icon: Icons.credit_card_outlined,
            title: UserStorage.l10n.reprocessCards,
            onTap: onReprocessCards,
            isLoading: isReprocessingCards,
          ),
          const SizedBox(height: 12),
          _buildFunctionTab(
            context: context,
            icon: Icons.menu_book_outlined,
            title: UserStorage.l10n.reprocessKnowledgeBase,
            onTap: onReprocessKnowledgeBase,
            isLoading: isReprocessingKnowledgeBase,
          ),
          const SizedBox(height: 12),
          _buildFunctionTab(
            context: context,
            icon: Icons.chat_bubble_outline,
            title: UserStorage.l10n.regenerateComments,
            onTap: onReprocessComments,
            isLoading: isReprocessingComments,
          ),
          const SizedBox(height: 12),
          _buildFunctionTab(
            context: context,
            icon: Icons.article_outlined,
            title: UserStorage.l10n.viewLogs,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LogViewerPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildFunctionTab(
            context: context,
            icon: Icons.search_outlined,
            title: UserStorage.l10n.rebuildSearchIndex,
            onTap: onRebuildSearchIndex,
            isLoading: isRebuildingSearchIndex,
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionTab({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white),
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
                icon,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: isLoading ? Colors.grey[400] : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              else
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
