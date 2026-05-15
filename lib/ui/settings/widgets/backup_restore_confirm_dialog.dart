import 'package:flutter/material.dart';
import 'package:memex/data/services/backup_service.dart';
import 'package:memex/utils/user_storage.dart';

class BackupRestoreConfirmDialog extends StatelessWidget {
  const BackupRestoreConfirmDialog({super.key, required this.backupInfo});

  final BackupFileInfo backupInfo;

  @override
  Widget build(BuildContext context) {
    final manifest = backupInfo.manifest;
    final createdAt = manifest?.createdAt.toLocal();

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(UserStorage.l10n.confirmRestore),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(UserStorage.l10n.confirmRestoreMessage),
            const SizedBox(height: 16),
            if (manifest == null)
              _BackupInfoRow(
                label: UserStorage.l10n.backupImportSourceVersion,
                value: UserStorage.l10n.backupLegacyFormat,
              )
            else ...[
              if (createdAt != null)
                _BackupInfoRow(
                  label: UserStorage.l10n.backupImportCreatedAt,
                  value: _formatBackupDate(context, createdAt),
                ),
              _BackupInfoRow(
                label: UserStorage.l10n.backupImportSourceVersion,
                value: '${manifest.appVersion}+${manifest.buildNumber}',
              ),
              _BackupInfoRow(
                label: UserStorage.l10n.backupImportFlavor,
                value: manifest.flavor,
              ),
            ],
            _BackupInfoRow(
              label: UserStorage.l10n.estimatedSize,
              value: _formatBytes(backupInfo.sizeBytes),
            ),
          ],
        ),
      ),
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
    );
  }

  String _formatBackupDate(BuildContext context, DateTime dateTime) {
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatMediumDate(dateTime);
    final time = TimeOfDay.fromDateTime(dateTime).format(context);
    return '$date $time';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class _BackupInfoRow extends StatelessWidget {
  const _BackupInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
