import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:share_plus/share_plus.dart';
import 'package:memex/data/services/backup_service.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:file_picker/file_picker.dart';

class BackupRestorePage extends StatefulWidget {
  const BackupRestorePage({super.key});

  @override
  State<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  final Logger _logger = getLogger('BackupRestorePage');
  bool _isBackingUp = false;
  bool _isRestoring = false;
  String _statusText = '';
  String _estimatedSize = '';

  @override
  void initState() {
    super.initState();
    _loadEstimatedSize();
  }

  Future<void> _loadEstimatedSize() async {
    final size = await BackupService.estimateBackupSize();
    if (mounted) {
      setState(() {
        _estimatedSize = _formatBytes(size);
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
      final xFile = XFile(backupPath);
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
            context, UserStorage.l10n.backupFailed(e.toString()));
      }
    }
  }

  Future<void> _restoreBackup() async {
    if (_isRestoring) return;

    // Pick file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result == null || result.files.isEmpty) return;

    final filePath = result.files.single.path;
    if (filePath == null) return;

    // Validate extension
    if (!filePath.endsWith('.memex') && !filePath.endsWith('.zip')) {
      if (mounted) {
        ToastHelper.showError(context, UserStorage.l10n.invalidBackupFile);
      }
      return;
    }

    // Confirm
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _isRestoring = true;
      _statusText = '';
    });

    try {
      await BackupService.restoreBackup(
        filePath,
        onProgress: (status) {
          if (mounted) setState(() => _statusText = status);
        },
      );

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
            context, UserStorage.l10n.restoreFailed(e.toString()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isBackingUp || _isRestoring;

    return Scaffold(
      appBar: AppBar(
        title: Text(UserStorage.l10n.backupAndRestore),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
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
                  Text(
                    _statusText,
                    style: TextStyle(
                      fontSize: 14,
                      color: isBusy
                          ? const Color(0xFF64748B)
                          : const Color(0xFF16A34A),
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

  Widget _buildCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required String description,
    required String buttonText,
    required bool isLoading,
    VoidCallback? onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.08),
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
              Icon(icon, color: const Color(0xFF6366F1), size: 24),
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
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
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
              color: Color(0xFF94A3B8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
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
}
