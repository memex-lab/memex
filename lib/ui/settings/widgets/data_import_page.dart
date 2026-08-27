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
          widget.viewModel.errorMessage ?? UserStorage.l10n.unknownError,
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
            ],
          );
        },
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
