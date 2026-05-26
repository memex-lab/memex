import 'dart:async';

import 'package:flutter/material.dart';

import 'package:memex/data/services/app_update_service.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/user_storage.dart';

class EarlyUpdateSettingsCard extends StatefulWidget {
  EarlyUpdateSettingsCard({
    super.key,
    AppUpdateService? service,
    this.forceVisible = false,
  }) : service = service ?? AppUpdateService.instance;

  final AppUpdateService service;
  final bool forceVisible;

  @override
  State<EarlyUpdateSettingsCard> createState() =>
      _EarlyUpdateSettingsCardState();
}

class _EarlyUpdateSettingsCardState extends State<EarlyUpdateSettingsCard> {
  AppUpdateSettings? _settings;
  AppUpdateInfo? _availableUpdate;
  AppUpdateCacheInfo _cacheInfo = AppUpdateCacheInfo.empty;
  bool _availableUpdateDownloaded = false;
  bool _availableUpdateDownloading = false;
  bool _checking = false;
  bool _downloading = false;
  bool _clearingCache = false;
  int _downloadPercent = 0;
  String? _statusText;
  Timer? _downloadPollTimer;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _downloadPollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    if (!widget.forceVisible && !widget.service.isSupported) return;
    final settings = await widget.service.loadSettings();
    final cacheInfo = await widget.service.getDownloadedUpdateCacheInfo();
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _cacheInfo = cacheInfo;
      _statusText = _lastCheckedText(settings);
    });
  }

  Future<void> _saveSettings(AppUpdateSettings settings) async {
    await widget.service.saveSettings(settings);
    if (!mounted) return;
    setState(() => _settings = settings);
  }

  Future<void> _checkNow() async {
    if (_checking || _downloading || _clearingCache) return;
    setState(() {
      _checking = true;
      _statusText = UserStorage.l10n.earlyUpdateChecking;
    });

    try {
      final result = await widget.service.checkForUpdate(manual: true);
      final latestSettings = await widget.service.loadSettings();
      final latestCacheInfo =
          await widget.service.getDownloadedUpdateCacheInfo();
      var availableUpdateDownloaded = false;
      AppUpdateDownloadProgress? activeDownloadProgress;
      if (result.status == AppUpdateCheckStatus.updateAvailable) {
        final update = result.update!;
        activeDownloadProgress = widget.service.getActiveDownloadProgress(
          update,
        );
        availableUpdateDownloaded = await widget.service.hasDownloadedUpdate(
          update,
        );
      }
      if (!mounted) return;
      setState(() {
        _checking = false;
        _settings = latestSettings;
        _cacheInfo = latestCacheInfo;
        _availableUpdateDownloaded = availableUpdateDownloaded;
        switch (result.status) {
          case AppUpdateCheckStatus.unsupported:
            _availableUpdate = null;
            _availableUpdateDownloaded = false;
            _availableUpdateDownloading = false;
            _statusText = UserStorage.l10n.earlyUpdateUnsupported;
          case AppUpdateCheckStatus.skippedNotWifi:
            _availableUpdate = null;
            _availableUpdateDownloaded = false;
            _availableUpdateDownloading = false;
            _statusText = UserStorage.l10n.earlyUpdateSkippedMobile;
          case AppUpdateCheckStatus.noUpdate:
            _availableUpdate = null;
            _availableUpdateDownloaded = false;
            _availableUpdateDownloading = false;
            _statusText = UserStorage.l10n.earlyUpdateNoUpdate;
          case AppUpdateCheckStatus.updateAvailable:
            _availableUpdate = result.update;
            final update = result.update!;
            _availableUpdateDownloading = activeDownloadProgress != null;
            _downloadPercent = activeDownloadProgress?.percent ?? 0;
            _statusText = _availableUpdateDownloading
                ? _downloadStatusText(activeDownloadProgress)
                : UserStorage.l10n.earlyUpdateFound(
                    update.versionName,
                    update.buildNumber,
                  );
        }
      });
      _syncDownloadPolling();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _availableUpdateDownloaded = false;
        _availableUpdateDownloading = false;
        _statusText = UserStorage.l10n.earlyUpdateCheckFailed(e);
      });
      _syncDownloadPolling();
    }
  }

  Future<void> _downloadAndInstall() async {
    final update = _availableUpdate;
    if (update == null ||
        _downloading ||
        _clearingCache ||
        _availableUpdateDownloading) {
      return;
    }

    setState(() {
      _downloading = true;
      _availableUpdateDownloading = false;
      _downloadPercent = 0;
      _statusText = UserStorage.l10n.earlyUpdateDownloadingPercent(0);
    });

    try {
      final download = await widget.service.downloadUpdate(
        update,
        onProgress: (receivedBytes, totalBytes) {
          if (!mounted || totalBytes <= 0) return;
          final percent =
              ((receivedBytes / totalBytes) * 100).clamp(0, 100).round();
          setState(() {
            _downloadPercent = percent;
            _statusText = UserStorage.l10n.earlyUpdateDownloadingPercent(
              percent,
            );
          });
        },
      );

      final latestCacheInfo =
          await widget.service.getDownloadedUpdateCacheInfo();
      final install = await widget.service.installUpdate(download.apkPath);
      if (!mounted) return;
      setState(() {
        _downloading = false;
        _availableUpdateDownloading = false;
        _downloadPercent = 100;
        _cacheInfo = latestCacheInfo;
        _availableUpdateDownloaded = true;
        _statusText = switch (install.status) {
          AppUpdateInstallStatus.started =>
            UserStorage.l10n.earlyUpdateInstallStarted,
          AppUpdateInstallStatus.permissionRequired =>
            UserStorage.l10n.earlyUpdateInstallPermissionRequired,
          AppUpdateInstallStatus.unsupported =>
            UserStorage.l10n.earlyUpdateUnsupported,
        };
      });
    } catch (e) {
      if (!mounted) return;
      final statusText = switch (e) {
        AppUpdateWifiRequiredException() =>
          UserStorage.l10n.earlyUpdateSkippedMobile,
        AppUpdateDownloadInProgressException() =>
          UserStorage.l10n.earlyUpdateDownloadInProgress,
        _ => UserStorage.l10n.earlyUpdateCheckFailed(e),
      };
      setState(() {
        _downloading = false;
        _availableUpdateDownloading = e is AppUpdateDownloadInProgressException;
        _statusText = statusText;
      });
      if (e is AppUpdateWifiRequiredException) {
        ToastHelper.showInfo(
          context,
          UserStorage.l10n.earlyUpdateSkippedMobile,
        );
      } else if (e is AppUpdateDownloadInProgressException) {
        ToastHelper.showInfo(
          context,
          UserStorage.l10n.earlyUpdateDownloadInProgress,
        );
      } else {
        ToastHelper.showError(context, e);
      }
      _syncDownloadPolling();
    }
  }

  Future<void> _clearDownloadedPackage() async {
    if (_checking || _downloading || _clearingCache) return;
    if (widget.service.hasActiveDownload) {
      setState(() {
        _availableUpdateDownloading = _availableUpdate != null;
        _statusText = UserStorage.l10n.earlyUpdateDownloadInProgress;
      });
      _syncDownloadPolling();
      return;
    }

    setState(() => _clearingCache = true);
    try {
      await widget.service.clearDownloadedUpdates();
      final latestCacheInfo =
          await widget.service.getDownloadedUpdateCacheInfo();
      if (!mounted) return;
      setState(() {
        _clearingCache = false;
        _cacheInfo = latestCacheInfo;
        _availableUpdateDownloaded = false;
        _availableUpdateDownloading = false;
        _statusText = UserStorage.l10n.earlyUpdateClearDownloadedPackageSuccess;
      });
      ToastHelper.showSuccess(
        context,
        UserStorage.l10n.earlyUpdateClearDownloadedPackageSuccess,
      );
    } catch (e) {
      if (!mounted) return;
      final statusText = e is AppUpdateDownloadInProgressException
          ? UserStorage.l10n.earlyUpdateDownloadInProgress
          : UserStorage.l10n.earlyUpdateCheckFailed(e);
      setState(() {
        _clearingCache = false;
        _availableUpdateDownloading = e is AppUpdateDownloadInProgressException;
        _statusText = statusText;
      });
      if (e is AppUpdateDownloadInProgressException) {
        ToastHelper.showInfo(
          context,
          UserStorage.l10n.earlyUpdateDownloadInProgress,
        );
      } else {
        ToastHelper.showError(context, e);
      }
      _syncDownloadPolling();
    }
  }

  void _syncDownloadPolling() {
    final update = _availableUpdate;
    final shouldPoll = update != null &&
        (_availableUpdateDownloading ||
            widget.service.isDownloadingUpdate(update));
    if (!shouldPoll) {
      _downloadPollTimer?.cancel();
      _downloadPollTimer = null;
      return;
    }

    _downloadPollTimer ??= Timer.periodic(const Duration(milliseconds: 500), (
      _,
    ) {
      unawaited(_refreshActiveDownloadState());
    });
  }

  Future<void> _refreshActiveDownloadState() async {
    final update = _availableUpdate;
    if (update == null || !mounted) return;

    final progress = widget.service.getActiveDownloadProgress(update);
    if (progress != null) {
      setState(() {
        _availableUpdateDownloading = true;
        _downloadPercent = progress.percent;
        _statusText = _downloadStatusText(progress);
      });
      return;
    }

    final latestCacheInfo = await widget.service.getDownloadedUpdateCacheInfo();
    final downloaded = await widget.service.hasDownloadedUpdate(update);
    if (!mounted) return;
    setState(() {
      _availableUpdateDownloading = false;
      _availableUpdateDownloaded = downloaded;
      _cacheInfo = latestCacheInfo;
      if (downloaded) {
        _downloadPercent = 100;
        _statusText = UserStorage.l10n.earlyUpdateDownloadReadyToInstall;
      } else {
        _downloadPercent = 0;
        _statusText = UserStorage.l10n.earlyUpdateFound(
          update.versionName,
          update.buildNumber,
        );
      }
    });
    _syncDownloadPolling();
  }

  String _downloadStatusText(AppUpdateDownloadProgress? progress) {
    final percent = progress?.percent ?? 0;
    if (percent > 0) {
      return UserStorage.l10n.earlyUpdateDownloadingPercent(percent);
    }
    return UserStorage.l10n.earlyUpdateDownloadInProgress;
  }

  String? _lastCheckedText(AppUpdateSettings settings) {
    final checkedAt = settings.lastCheckAt;
    if (checkedAt == null) return null;
    final local = checkedAt.toLocal();
    final formatted =
        '${local.year}-${_two(local.month)}-${_two(local.day)} ${_two(local.hour)}:${_two(local.minute)}';
    return UserStorage.l10n.earlyUpdateLastChecked(formatted);
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    if (!widget.forceVisible && !widget.service.isSupported) {
      return const SizedBox.shrink();
    }

    final settings = _settings;
    if (settings == null) {
      return _buildShell(
        child: const SizedBox(
          height: 72,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    final operationBusy = _checking ||
        _downloading ||
        _clearingCache ||
        _availableUpdateDownloading;

    return _buildShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.system_update_alt,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      UserStorage.l10n.earlyUpdateSettingsTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      UserStorage.l10n.earlyUpdateSettingsDesc,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildSwitch(
            title: UserStorage.l10n.earlyUpdateAutoCheckTitle,
            subtitle: UserStorage.l10n.earlyUpdateAutoCheckDesc,
            value: settings.autoCheckEnabled,
            onChanged: (value) =>
                _saveSettings(settings.copyWith(autoCheckEnabled: value)),
          ),
          _buildSwitch(
            title: UserStorage.l10n.earlyUpdateWifiOnlyTitle,
            subtitle: UserStorage.l10n.earlyUpdateWifiOnlyDesc,
            value: settings.wifiOnlyDownloads,
            onChanged: (value) =>
                _saveSettings(settings.copyWith(wifiOnlyDownloads: value)),
          ),
          _buildSwitch(
            title: UserStorage.l10n.earlyUpdateAutoInstallTitle,
            subtitle: UserStorage.l10n.earlyUpdateAutoInstallDesc,
            value: settings.autoDownloadAndInstall,
            onChanged: (value) =>
                _saveSettings(settings.copyWith(autoDownloadAndInstall: value)),
          ),
          if (_statusText != null) ...[
            const SizedBox(height: 12),
            Text(
              _statusText!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ],
          if (_downloading || _availableUpdateDownloading) ...[
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: _downloadPercent <= 0 ? null : _downloadPercent / 100,
              color: AppColors.primary,
              minHeight: 4,
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: operationBusy ? null : _checkNow,
                icon: _checking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: Text(UserStorage.l10n.earlyUpdateCheckNow),
              ),
              if (_availableUpdate != null)
                FilledButton.icon(
                  onPressed: operationBusy ? null : _downloadAndInstall,
                  icon: Icon(
                    _availableUpdateDownloading
                        ? Icons.downloading
                        : _availableUpdateDownloaded
                            ? Icons.install_mobile
                            : Icons.download,
                    size: 18,
                  ),
                  label: Text(
                    _availableUpdateDownloading
                        ? UserStorage.l10n.earlyUpdateDownloadInProgress
                        : _availableUpdateDownloaded
                            ? UserStorage
                                .l10n.earlyUpdateInstallDownloadedPackage
                            : UserStorage.l10n.earlyUpdateDownloadAndInstall,
                  ),
                ),
              if (_cacheInfo.hasFiles)
                OutlinedButton.icon(
                  onPressed: operationBusy || widget.service.hasActiveDownload
                      ? null
                      : _clearDownloadedPackage,
                  icon: _clearingCache
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline, size: 18),
                  label: Text(
                    UserStorage.l10n.earlyUpdateClearDownloadedPackage,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShell({required Widget child}) {
    final borderRadius = BorderRadius.circular(16);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
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
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.35),
        ),
      ),
      value: value,
      onChanged: _checking || _downloading || _clearingCache ? null : onChanged,
    );
  }
}
