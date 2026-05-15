import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:share_plus/share_plus.dart';
import 'package:memex/data/services/backup_service.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/ui/settings/widgets/backup_restore_confirm_dialog.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/user_storage.dart';

typedef AutoBackupCreator = Future<BackupSnapshot?> Function({
  String trigger,
  bool force,
  void Function(String status)? onProgress,
});

class BackupRestorePage extends StatefulWidget {
  final bool? isAndroidOverride;
  final Future<int> Function()? estimateBackupSize;
  final Future<String> Function()? currentBackupLocationLabel;
  final Future<List<BackupSnapshot>> Function()? listStoredBackups;
  final AutoBackupCreator? createAutoBackup;
  final Future<void> Function()? useDefaultBackupDirectory;
  final Future<AndroidBackupDirectory?> Function()? pickAndroidBackupDirectory;

  const BackupRestorePage({
    super.key,
    this.isAndroidOverride,
    this.estimateBackupSize,
    this.currentBackupLocationLabel,
    this.listStoredBackups,
    this.createAutoBackup,
    this.useDefaultBackupDirectory,
    this.pickAndroidBackupDirectory,
  });

  bool get isAndroid => isAndroidOverride ?? Platform.isAndroid;

  @override
  State<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  final Logger _logger = getLogger('BackupRestorePage');
  bool _isBackingUp = false;
  bool _isRestoring = false;
  bool _isCreatingSnapshot = false;
  bool _isPickingLocation = false;
  bool _autoBackupEnabled = false;
  String _statusText = '';
  String _estimatedSize = '';
  String _backupLocation = '';
  DateTime? _lastAutoBackupAt;
  List<BackupSnapshot> _storedBackups = const [];

  @override
  void initState() {
    super.initState();
    _loadPageData();
  }

  Future<void> _loadPageData() async {
    final userId = await UserStorage.getUserId();
    final size =
        await (widget.estimateBackupSize ?? BackupService.estimateBackupSize)();
    final location = await (widget.currentBackupLocationLabel ??
        BackupService.currentBackupLocationLabel)();
    final snapshots =
        await (widget.listStoredBackups ?? BackupService.listStoredBackups)();
    final autoEnabled = userId != null && userId.isNotEmpty
        ? await UserStorage.isAutoBackupEnabled(userId)
        : false;
    final lastAutoBackupAt = userId != null && userId.isNotEmpty
        ? await UserStorage.getLastAutoBackupAt(userId)
        : null;

    if (mounted) {
      setState(() {
        _estimatedSize = _formatBytes(size);
        _backupLocation = location;
        _storedBackups = snapshots;
        _autoBackupEnabled = autoEnabled;
        _lastAutoBackupAt = lastAutoBackupAt;
      });
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat.yMd(
      UserStorage.l10n.localeName,
    ).add_Hm().format(dateTime);
  }

  Future<void> _createBackup() async {
    if (_isBackingUp) return;
    setState(() {
      _isBackingUp = true;
      _statusText = '';
    });

    try {
      final backupPath = await BackupService.createBackup(
        onProgress: (status) {
          if (mounted) setState(() => _statusText = status);
        },
      );

      if (!mounted) return;
      setState(() {
        _isBackingUp = false;
        _statusText = UserStorage.l10n.backupComplete;
      });

      // Share the file so user can save it anywhere
      final xFile = XFile(backupPath, mimeType: BackupService.backupMimeType);
      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [xFile],
        sharePositionOrigin: box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : const Rect.fromLTWH(0, 0, 100, 100),
      );
    } catch (e, stack) {
      _logger.severe('Backup failed: $e', e, stack);
      if (mounted) {
        setState(() {
          _isBackingUp = false;
          _statusText = '';
        });
        ToastHelper.showError(
          context,
          UserStorage.l10n.backupFailed(e.toString()),
        );
      }
    }
  }

  Future<void> _createSnapshotNow() async {
    if (_isCreatingSnapshot) return;
    setState(() {
      _isCreatingSnapshot = true;
      _statusText = '';
    });

    try {
      final createAutoBackup =
          widget.createAutoBackup ?? BackupService.maybeCreateAutoBackup;
      final snapshot = await createAutoBackup(
        trigger: 'manual',
        force: true,
        onProgress: (status) {
          if (mounted) setState(() => _statusText = status);
        },
      );
      await _loadPageData();

      if (!mounted) return;
      setState(() {
        _isCreatingSnapshot = false;
        _statusText = snapshot == null
            ? ''
            : UserStorage.l10n.autoBackupCreated(snapshot.name);
      });
    } catch (e, stack) {
      _logger.severe('Auto backup failed: $e', e, stack);
      if (mounted) {
        setState(() {
          _isCreatingSnapshot = false;
          _statusText = '';
        });
        ToastHelper.showError(
          context,
          UserStorage.l10n.backupFailed(e.toString()),
        );
      }
    }
  }

  Future<void> _toggleAutoBackup(bool enabled) async {
    final userId = await UserStorage.getUserId();
    if (userId == null || userId.isEmpty) return;
    await UserStorage.setAutoBackupEnabled(userId, enabled);
    if (mounted) {
      setState(() => _autoBackupEnabled = enabled);
    }
  }

  Future<void> _showBackupLocationMenu() async {
    if (!widget.isAndroid) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.folder_special_outlined),
              title: Text(UserStorage.l10n.defaultBackupLocation),
              subtitle: Text(UserStorage.l10n.defaultBackupLocationAndroidDesc),
              onTap: () async {
                Navigator.pop(context);
                await (widget.useDefaultBackupDirectory ??
                    BackupService.useDefaultBackupDirectory)();
                await _loadPageData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined),
              title: Text(UserStorage.l10n.chooseBackupLocation),
              subtitle: Text(UserStorage.l10n.chooseBackupLocationAndroidDesc),
              onTap: () async {
                Navigator.pop(context);
                await _pickAndroidBackupLocation();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndroidBackupLocation() async {
    if (_isPickingLocation) return;
    setState(() => _isPickingLocation = true);

    try {
      await (widget.pickAndroidBackupDirectory ??
          BackupService.pickAndroidBackupDirectory)();
      await _loadPageData();
    } catch (e, stack) {
      _logger.warning('Failed to pick backup location: $e', e, stack);
      if (mounted) {
        ToastHelper.showError(
          context,
          UserStorage.l10n.backupLocationFailed(e.toString()),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingLocation = false);
      }
    }
  }

  Future<void> _restoreBackup() async {
    if (_isRestoring) return;

    // Pick file
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.isEmpty) return;

    final filePath = result.files.single.path;
    if (filePath == null) return;

    // Validate extension
    if (!BackupService.isSelectableBackupFile(filePath)) {
      if (mounted) {
        ToastHelper.showError(context, UserStorage.l10n.invalidBackupFile);
      }
      return;
    }

    BackupFileInfo backupInfo;
    try {
      backupInfo = await BackupService.inspectBackup(filePath);
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, UserStorage.l10n.restoreFailed(e));
      }
      return;
    }
    if (!mounted) return;

    final confirmed = await _confirmRestore(backupInfo: backupInfo);
    if (confirmed != true) return;

    await _performRestore(
      (onProgress) =>
          BackupService.restoreBackup(filePath, onProgress: onProgress),
    );
  }

  Future<void> _restoreStoredBackup(BackupSnapshot snapshot) async {
    if (_isRestoring) return;

    final confirmed = await _confirmRestore();
    if (confirmed != true) return;

    await _performRestore(
      (onProgress) =>
          BackupService.restoreStoredBackup(snapshot, onProgress: onProgress),
    );
  }

  Future<bool?> _confirmRestore({BackupFileInfo? backupInfo}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => backupInfo == null
          ? AlertDialog(
              backgroundColor: Colors.white,
              title: Text(UserStorage.l10n.confirmRestore),
              content: Text(UserStorage.l10n.confirmRestoreMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(UserStorage.l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: Text(UserStorage.l10n.confirm),
                ),
              ],
            )
          : BackupRestoreConfirmDialog(backupInfo: backupInfo),
    );
  }

  Future<void> _performRestore(
    Future<bool> Function(void Function(String status) onProgress) restore,
  ) async {
    setState(() {
      _isRestoring = true;
      _statusText = UserStorage.l10n.creatingSafetySnapshot;
    });

    try {
      await BackupService.createSafetySnapshot(
        reason: 'before_restore',
        onProgress: (status) {
          if (mounted) setState(() => _statusText = status);
        },
      );
      await restore((status) {
        if (mounted) setState(() => _statusText = status);
      });

      if (!mounted) return;
      setState(() {
        _isRestoring = false;
        _statusText = UserStorage.l10n.restoreComplete;
      });

      // Show restart hint
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(UserStorage.l10n.restoreComplete),
            content: Text(UserStorage.l10n.restoreRestartHint),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Pop back to root
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(UserStorage.l10n.ok),
              ),
            ],
          ),
        );
      }
    } catch (e, stack) {
      _logger.severe('Restore failed: $e', e, stack);
      if (mounted) {
        setState(() {
          _isRestoring = false;
          _statusText = '';
        });
        ToastHelper.showError(
          context,
          UserStorage.l10n.restoreFailed(e.toString()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isBackingUp ||
        _isRestoring ||
        _isCreatingSnapshot ||
        _isPickingLocation;

    return Scaffold(
      appBar: AppBar(
        title: Text(UserStorage.l10n.backupAndRestore),
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildAutoBackupCard(isBusy),

          const SizedBox(height: 16),

          // Backup section
          _buildCard(
            icon: Icons.backup_outlined,
            title: UserStorage.l10n.createBackup,
            subtitle: _estimatedSize.isNotEmpty
                ? '${UserStorage.l10n.estimatedSize}: $_estimatedSize'
                : null,
            description: UserStorage.l10n.backupDescription,
            buttonText: UserStorage.l10n.createBackup,
            isLoading: _isBackingUp,
            onPressed: isBusy ? null : _createBackup,
          ),

          const SizedBox(height: 16),

          // Restore section
          _buildCard(
            icon: Icons.restore_outlined,
            title: UserStorage.l10n.restoreBackup,
            description: UserStorage.l10n.restoreDescription,
            buttonText: UserStorage.l10n.selectBackupFile,
            isLoading: _isRestoring,
            onPressed: isBusy ? null : _restoreBackup,
          ),

          const SizedBox(height: 16),
          _buildStoredBackupsCard(isBusy),

          // Status
          if (_statusText.isNotEmpty) ...[
            const SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isBusy)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  Flexible(
                    child: Text(
                      _statusText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isBusy
                            ? AppColors.textSecondary
                            : const Color(0xFF16A34A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAutoBackupCard(bool isBusy) {
    final lastBackupText = _lastAutoBackupAt == null
        ? UserStorage.l10n.noAutoBackupYet
        : UserStorage.l10n.lastBackupAt(_formatDateTime(_lastAutoBackupAt!));

    return _settingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  UserStorage.l10n.automaticBackup,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Switch(
                value: _autoBackupEnabled,
                activeThumbColor: AppColors.primary,
                onChanged: isBusy ? null : _toggleAutoBackup,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            UserStorage.l10n.autoBackupDescription,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textTertiary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            UserStorage.l10n.backupSensitiveSettingsHint,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          _infoRow(UserStorage.l10n.backupLocation, _backupLocation),
          const SizedBox(height: 8),
          _infoRow(UserStorage.l10n.autoBackupStatus, lastBackupText),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isBusy ? null : _createSnapshotNow,
                  icon: _isCreatingSnapshot
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.camera_outlined, size: 18),
                  label: Text(UserStorage.l10n.createSnapshotNow),
                ),
              ),
              if (widget.isAndroid) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isBusy ? null : _showBackupLocationMenu,
                    icon: _isPickingLocation
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.folder_open_outlined, size: 18),
                    label: Text(UserStorage.l10n.backupLocationMenu),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoredBackupsCard(bool isBusy) {
    return _settingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.history_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  UserStorage.l10n.storedBackups,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                tooltip: UserStorage.l10n.refresh,
                onPressed: isBusy ? null : _loadPageData,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_storedBackups.isEmpty)
            Text(
              UserStorage.l10n.noStoredBackups,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textTertiary,
                height: 1.5,
              ),
            )
          else
            ..._storedBackups.map(
              (snapshot) => _StoredBackupTile(
                snapshot: snapshot,
                dateText: _formatDateTime(snapshot.createdAt),
                sizeText: _formatBytes(snapshot.sizeBytes),
                onRestore: isBusy ? null : () => _restoreStoredBackup(snapshot),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required String description,
    required String buttonText,
    required bool isLoading,
    VoidCallback? onPressed,
  }) {
    return _settingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textTertiary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsCard({required Widget child}) {
    return Container(
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
      child: child,
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _StoredBackupTile extends StatelessWidget {
  final BackupSnapshot snapshot;
  final String dateText;
  final String sizeText;
  final VoidCallback? onRestore;

  const _StoredBackupTile({
    required this.snapshot,
    required this.dateText,
    required this.sizeText,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = UserStorage.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          leading: Icon(
            snapshot.isSafetySnapshot
                ? Icons.health_and_safety_outlined
                : Icons.inventory_2_outlined,
            color: AppColors.primary,
          ),
          title: Text(
            snapshot.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '$dateText - $sizeText',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
          trailing: IconButton(
            tooltip: l10n.restoreThisBackup,
            onPressed: onRestore,
            icon: const Icon(Icons.restore_outlined),
          ),
        ),
      ),
    );
  }
}
