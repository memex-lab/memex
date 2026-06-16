import 'package:flutter/material.dart';
import 'package:memex/data/services/app_update_service.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/ui/settings/view_models/about_memex_viewmodel.dart';
import 'package:memex/utils/user_storage.dart';

class AboutMemexPage extends StatefulWidget {
  const AboutMemexPage({super.key, required this.viewModel});

  final AboutMemexViewModelContract viewModel;

  @override
  State<AboutMemexPage> createState() => _AboutMemexPageState();
}

class _AboutMemexPageState extends State<AboutMemexPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UserStorage.l10n.aboutMemexTitle),
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final vm = widget.viewModel;
          if (vm.loading && vm.buildInfo == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(vm),
              const SizedBox(height: 16),
              _buildInfoSection(vm),
              const SizedBox(height: 16),
              _buildUpdateSection(vm),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(AboutMemexViewModelContract vm) {
    final info = vm.buildInfo;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.asset(
            'assets/icon.png',
            width: 72,
            height: 72,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          info?.appName ?? 'Memex',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          info?.displayVersion ?? UserStorage.l10n.appInfoUnknown,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildInfoSection(AboutMemexViewModelContract vm) {
    final info = vm.buildInfo;
    return _SectionCard(
      child: Column(
        children: [
          _InfoRow(
            label: UserStorage.l10n.appInfoVersion,
            value: info?.versionName ?? UserStorage.l10n.appInfoUnknown,
          ),
          _InfoRow(
            label: UserStorage.l10n.appInfoBuild,
            value: '${info?.buildNumber ?? '-'}',
          ),
          _InfoRow(
            label: UserStorage.l10n.appInfoFlavor,
            value: info?.flavorName ?? UserStorage.l10n.appInfoUnknown,
          ),
          _InfoRow(
            label: UserStorage.l10n.appInfoChannel,
            value: info?.channelName ?? UserStorage.l10n.appInfoUnknown,
          ),
          _InfoRow(
            label: UserStorage.l10n.appInfoInstallerSource,
            value:
                info?.installerDisplayName ?? UserStorage.l10n.appInfoUnknown,
          ),
          _InfoRow(
            label: UserStorage.l10n.appInfoPackage,
            value: info?.packageName ?? UserStorage.l10n.appInfoUnknown,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateSection(AboutMemexViewModelContract vm) {
    final settings = vm.settings ?? const AppUpdateSettings();
    final hasUpdate = vm.updateCheck?.hasUpdate ?? false;
    final canActOnUpdate =
        hasUpdate &&
        ((vm.updateCheck?.canDownloadApk ?? false) ||
            (vm.updateCheck?.canOpenExternalUpdate ?? false));
    final busy = vm.checking || vm.performingUpdate || vm.clearingCache;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.system_update_alt, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  UserStorage.l10n.appUpdateSectionTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(UserStorage.l10n.appUpdateAutoCheckTitle),
            subtitle: Text(UserStorage.l10n.appUpdateAutoCheckDesc),
            value: settings.autoCheckEnabled,
            onChanged: busy ? null : vm.updateAutoCheckEnabled,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(UserStorage.l10n.appUpdateWifiOnlyTitle),
            subtitle: Text(UserStorage.l10n.appUpdateWifiOnlyDesc),
            value: settings.wifiOnlyDownloads,
            onChanged: busy ? null : vm.updateWifiOnlyDownloads,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(UserStorage.l10n.appUpdateAutoInstallTitle),
            subtitle: Text(UserStorage.l10n.appUpdateAutoInstallDesc),
            value: settings.autoDownloadAndInstall,
            onChanged: busy ? null : vm.updateAutoDownloadAndInstall,
          ),
          if (vm.statusText != null) ...[
            const SizedBox(height: 8),
            Text(
              vm.statusText!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ],
          if (vm.performingUpdate &&
              (vm.updateCheck?.canDownloadApk ?? false)) ...[
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: vm.downloadPercent <= 0 ? null : vm.downloadPercent / 100,
              minHeight: 4,
              color: AppColors.primary,
            ),
          ],
          if (vm.cacheInfo.hasFiles) ...[
            const SizedBox(height: 10),
            Text(
              UserStorage.l10n.appUpdateCacheInfo(
                vm.cacheInfo.fileCount,
                vm.cacheInfo.totalBytes,
              ),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: busy ? null : vm.checkNow,
                icon: vm.checking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: Text(UserStorage.l10n.appUpdateCheckNow),
              ),
              if (canActOnUpdate)
                FilledButton.icon(
                  onPressed: busy ? null : vm.performUpdateAction,
                  icon: Icon(
                    vm.updateCheck?.canDownloadApk ?? false
                        ? Icons.download
                        : Icons.open_in_new,
                    size: 18,
                  ),
                  label: Text(
                    vm.updateCheck?.canDownloadApk ?? false
                        ? UserStorage.l10n.appUpdateDownloadAndInstall
                        : UserStorage.l10n.appUpdateOpenUpdatePage,
                  ),
                ),
              OutlinedButton.icon(
                onPressed: vm.buildInfo == null ? null : vm.copyDiagnostics,
                icon: const Icon(Icons.copy, size: 18),
                label: Text(UserStorage.l10n.appUpdateCopyDiagnostics),
              ),
              if (vm.cacheInfo.hasFiles)
                OutlinedButton.icon(
                  onPressed: busy ? null : vm.clearUpdateCache,
                  icon: vm.clearingCache
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline, size: 18),
                  label: Text(UserStorage.l10n.appUpdateClearCache),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: const EdgeInsets.all(20), child: child),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
