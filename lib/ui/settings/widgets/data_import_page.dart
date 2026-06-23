import 'package:flutter/material.dart';
import 'package:memex/data/services/file_import_service.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/ui/settings/view_models/data_import_viewmodel.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/user_storage.dart';

class DataImportPage extends StatefulWidget {
  const DataImportPage({
    super.key,
    required this.viewModel,
  });

  final DataImportViewModel viewModel;

  @override
  State<DataImportPage> createState() => _DataImportPageState();
}

class _DataImportPageState extends State<DataImportPage> {
  Future<void> _pickAndImport() async {
    final result = await widget.viewModel.pickAndImport();
    if (!mounted) return;

    if (result == null) {
      final error = widget.viewModel.errorMessage;
      if (error != null) {
        ToastHelper.showError(context, UserStorage.l10n.operationFailed(error));
      }
      return;
    }

    ToastHelper.showSuccess(context, UserStorage.l10n.dataImportSuccess);
    final options = await showDialog<ImportProcessingOptions>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ImportProcessingOptionsDialog(result: result),
    );
    if (!mounted || options == null) return;

    if (!options.hasProcessing) {
      ToastHelper.showSuccess(context, UserStorage.l10n.dataImportOnlyStored);
      return;
    }

    final queued =
        await widget.viewModel.startSuperAgentProcessing(result, options);
    if (!mounted) return;
    if (queued) {
      ToastHelper.showSuccess(context, UserStorage.l10n.dataImportQueued);
    } else {
      ToastHelper.showError(
        context,
        UserStorage.l10n.operationFailed(
          widget.viewModel.errorMessage ?? 'Failed to queue processing',
        ),
      );
    }
  }

  Future<void> _showProcessingDialog(FileImportResult result) async {
    final options = await showDialog<ImportProcessingOptions>(
      context: context,
      builder: (context) => ImportProcessingOptionsDialog(result: result),
    );
    if (!mounted || options == null) return;
    if (!options.hasProcessing) return;

    final queued =
        await widget.viewModel.startSuperAgentProcessing(result, options);
    if (!mounted) return;
    if (queued) {
      ToastHelper.showSuccess(context, UserStorage.l10n.dataImportQueued);
    } else {
      ToastHelper.showError(
        context,
        UserStorage.l10n.operationFailed(
          widget.viewModel.errorMessage ?? 'Failed to queue processing',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UserStorage.l10n.dataImportTitle),
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final result = widget.viewModel.lastImportResult;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
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
                        const Icon(
                          Icons.upload_file_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                UserStorage.l10n.dataImportTitle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                UserStorage.l10n.dataImportDescription,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: widget.viewModel.isImporting
                            ? null
                            : _pickAndImport,
                        icon: widget.viewModel.isImporting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.add),
                        label: Text(
                          widget.viewModel.isImporting
                              ? (widget.viewModel.statusText.isEmpty
                                  ? UserStorage.l10n.dataImportImporting
                                  : widget.viewModel.statusText)
                              : UserStorage.l10n.dataImportSelectFiles,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (result != null) ...[
                const SizedBox(height: 16),
                _ImportResultPanel(
                  result: result,
                  onProcess: widget.viewModel.isQueueingProcessing
                      ? null
                      : () => _showProcessingDialog(result),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ImportResultPanel extends StatelessWidget {
  const _ImportResultPanel({
    required this.result,
    required this.onProcess,
  });

  final FileImportResult result;
  final VoidCallback? onProcess;

  @override
  Widget build(BuildContext context) {
    final l10n = UserStorage.l10n;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dataImportResultTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.dataImportResultSummary(result.importedFileCount),
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          if (result.renamedConflictCount > 0) ...[
            const SizedBox(height: 6),
            Text(
              l10n.dataImportRenamedConflicts(result.renamedConflictCount),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
          if (result.skippedUnsafeArchiveEntries > 0) ...[
            const SizedBox(height: 6),
            Text(
              l10n.dataImportSkippedUnsafeEntries(
                result.skippedUnsafeArchiveEntries,
              ),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onProcess,
              icon: const Icon(Icons.auto_awesome_outlined),
              label: Text(l10n.dataImportChooseProcessing),
            ),
          ),
        ],
      ),
    );
  }
}

class ImportProcessingOptionsDialog extends StatefulWidget {
  const ImportProcessingOptionsDialog({
    super.key,
    required this.result,
  });

  final FileImportResult result;

  @override
  State<ImportProcessingOptionsDialog> createState() =>
      _ImportProcessingOptionsDialogState();
}

class _ImportProcessingOptionsDialogState
    extends State<ImportProcessingOptionsDialog> {
  ImportProcessingOptions _options = const ImportProcessingOptions();

  @override
  Widget build(BuildContext context) {
    final l10n = UserStorage.l10n;
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(l10n.dataImportProcessTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dataImportProcessPrompt(widget.result.importedFileCount),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _options.processKnowledgeBase,
              onChanged: (value) {
                setState(() {
                  _options = _options.copyWith(
                    processKnowledgeBase: value ?? false,
                  );
                });
              },
              title: Text(l10n.dataImportProcessKnowledgeBase),
              subtitle: Text(l10n.dataImportProcessKnowledgeBaseDesc),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _options.processTimelineCards,
              onChanged: (value) {
                setState(() {
                  _options = _options.copyWith(
                    processTimelineCards: value ?? false,
                  );
                });
              },
              title: Text(l10n.dataImportProcessTimelineCards),
              subtitle: Text(l10n.dataImportProcessTimelineCardsDesc),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                dataImportImpactText(_options),
                key: const ValueKey('data-import-impact-text'),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _options),
          child: Text(
            _options.hasProcessing
                ? l10n.startProcessing
                : l10n.dataImportFinish,
          ),
        ),
      ],
    );
  }
}

String dataImportImpactText(ImportProcessingOptions options) {
  final l10n = UserStorage.l10n;
  if (options.processKnowledgeBase && options.processTimelineCards) {
    return l10n.dataImportImpactBoth;
  }
  if (options.processKnowledgeBase) {
    return l10n.dataImportImpactKnowledgeBase;
  }
  if (options.processTimelineCards) {
    return l10n.dataImportImpactTimelineCards;
  }
  return l10n.dataImportImpactNone;
}
