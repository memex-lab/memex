import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memex/config/app_flavor.dart';
import 'package:memex/data/services/speech_transcription_service.dart';
import 'package:memex/data/services/whisper_service.dart';
import 'package:memex/domain/models/local_speech_model.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:logging/logging.dart';

typedef _SpeechModelDownloadRequest = ({
  LocalSpeechModelId model,
  bool useChineseMirror,
});

/// Shared download flow for local speech models (SenseVoice / Whisper).
class SpeechModelDownloadFlow {
  SpeechModelDownloadFlow._();

  static final Logger _logger = getLogger('SpeechModelDownloadFlow');
  static bool _downloadInProgress = false;

  static Future<bool> ensureLocalModelReady(BuildContext context) async {
    final speechService = SpeechTranscriptionService.instance;
    if (!await speechService.requiresLocalModelDownload()) return true;
    if (!context.mounted) return false;

    final downloaded = await showDownloadDialog(context);
    if (!context.mounted) return false;
    if (!downloaded) return false;

    return !await speechService.requiresLocalModelDownload();
  }

  /// Shows model/source selection, runs the download to completion, and returns
  /// whether the selected model is ready afterward.
  static Future<bool> showDownloadDialog(BuildContext context) async {
    final request = await showDialog<_SpeechModelDownloadRequest>(
      context: context,
      builder: (ctx) => _SpeechModelDownloadDialog(
        onStartDownload: (model, useChineseMirror) {
          Navigator.pop(
            ctx,
            (model: model, useChineseMirror: useChineseMirror),
          );
        },
      ),
    );
    if (request == null || !context.mounted) return false;

    return _downloadModel(
      context: context,
      model: request.model,
      useChineseMirror: request.useChineseMirror,
    );
  }

  static Future<bool> _downloadModel({
    required BuildContext context,
    required LocalSpeechModelId model,
    required bool useChineseMirror,
  }) async {
    if (_downloadInProgress) {
      _logger.warning('Speech model download already in progress');
      return false;
    }

    final l10n = UserStorage.l10n;
    var progress = 0.0;
    StateSetter? setDialogState;
    _downloadInProgress = true;

    if (!context.mounted) {
      _downloadInProgress = false;
      return false;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          setDialogState = setState;
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(l10n.speechModelDownloading),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: progress > 0 ? progress : null,
                  backgroundColor: AppColors.background,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  progress > 0
                      ? '${(progress * 100).toInt()}%'
                      : l10n.speechModelConnecting,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    var success = false;
    try {
      await WhisperService.instance.downloadModel(
        model: model,
        useChineseMirror: useChineseMirror,
        onProgress: (p) {
          progress = p;
          setDialogState?.call(() {});
        },
      );
      success = await WhisperService.instance.isModelDownloaded(model);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.speechModelDownloadSuccess)),
        );
      } else if (!success) {
        throw StateError('Download finished but model files are missing');
      }
    } catch (e, st) {
      _logger.severe('Speech model download failed', e, st);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.speechModelDownloadFailed(e.toString()))),
        );
      }
    } finally {
      _downloadInProgress = false;
      if (context.mounted) Navigator.of(context).pop();
    }

    return success;
  }
}

class _SpeechModelDownloadDialog extends StatefulWidget {
  const _SpeechModelDownloadDialog({required this.onStartDownload});

  final void Function(LocalSpeechModelId model, bool useChineseMirror)
      onStartDownload;

  @override
  State<_SpeechModelDownloadDialog> createState() =>
      _SpeechModelDownloadDialogState();
}

class _SpeechModelDownloadDialogState extends State<_SpeechModelDownloadDialog> {
  late LocalSpeechModelId _selectedModel;
  final _profiles = LocalSpeechModelProfile.selectableProfiles();

  @override
  void initState() {
    super.initState();
    _selectedModel = LocalSpeechModelProfile.defaultForFlavor();
    UserStorage.getLocalSpeechModel().then((model) {
      if (mounted) setState(() => _selectedModel = model);
    });
  }

  LocalSpeechModelProfile get _selectedProfile =>
      LocalSpeechModelProfile.fromId(_selectedModel);

  String _titleFor(LocalSpeechModelId id, dynamic l10n) => switch (id) {
        LocalSpeechModelId.senseVoice => l10n.speechModelSenseVoiceTitle,
        LocalSpeechModelId.whisperSmall => l10n.speechModelWhisperSmallTitle,
      };

  String _descFor(LocalSpeechModelId id, dynamic l10n) => switch (id) {
        LocalSpeechModelId.senseVoice => l10n.speechModelSenseVoiceDesc,
        LocalSpeechModelId.whisperSmall => l10n.speechModelWhisperSmallDesc,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = UserStorage.l10n;
    final sizeMB = _selectedProfile.approxSizeMB.toInt();

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(l10n.speechModelDownloadTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.speechModelDownloadDesc(sizeMB)),
            const SizedBox(height: 16),
            Text(
              l10n.speechModelChooseModel,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ..._profiles.map((profile) {
              final selected = _selectedModel == profile.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => setState(() => _selectedModel = profile.id),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary.withValues(alpha: 0.2),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _titleFor(profile.id, l10n),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _descFor(profile.id, l10n),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.speechModelApproxSize(
                                  profile.approxSizeMB.toInt(),
                                ),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            if (AppFlavor.isCN && _selectedProfile.supportsChinaMirror) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      widget.onStartDownload(_selectedModel, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(l10n.speechModelStartDownload),
                ),
              ),
            ] else if (!AppFlavor.isCN) ...[
              Text(
                l10n.speechModelChooseSource,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.speechModelSourceHint,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      widget.onStartDownload(_selectedModel, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(l10n.speechModelGithub),
                ),
              ),
              if (_selectedProfile.supportsChinaMirror) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () =>
                        widget.onStartDownload(_selectedModel, true),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(l10n.speechModelChinaMirror),
                  ),
                ),
              ],
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      widget.onStartDownload(_selectedModel, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(l10n.speechModelStartDownload),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
