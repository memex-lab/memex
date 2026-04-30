import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:memex/ui/core/widgets/share_poster_decorator.dart';
import 'package:memex/ui/core/widgets/share_preview_dialog.dart';
import 'package:memex/utils/user_storage.dart';

class ShareService {
  /// Captures a widget as a poster image and shows a preview dialog before sharing.
  ///
  /// If [detailContent] is provided, the user can toggle between card style
  /// and detail (long image) style in the preview dialog.
  static Future<void> shareWidgetAsPoster(
    BuildContext context,
    Widget content, {
    Widget? detailContent,
  }) async {
    final cardBytes = await _captureWidget(context, content);
    if (!context.mounted) return;

    Uint8List? detailBytes;
    bool isDetailStyle = false;
    Uint8List currentBytes = cardBytes;

    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => SharePreviewDialog(
          imageBytes: currentBytes,
          isDetailStyle: isDetailStyle,
          onCancel: () => Navigator.of(ctx).pop(),
          onToggleStyle: detailContent != null
              ? () async {
                  if (!isDetailStyle) {
                    // Switch to detail style — capture on first toggle
                    if (detailBytes == null) {
                      // Show a brief loading indicator
                      setDialogState(() {});
                      detailBytes = await _captureLongWidget(
                        ctx,
                        detailContent,
                      );
                    }
                    if (detailBytes != null) {
                      setDialogState(() {
                        isDetailStyle = true;
                        currentBytes = detailBytes!;
                      });
                    }
                  } else {
                    // Switch back to card style
                    setDialogState(() {
                      isDetailStyle = false;
                      currentBytes = cardBytes;
                    });
                  }
                }
              : null,
          onShare: () async {
            Navigator.of(ctx).pop();
            await _performShare(currentBytes);
          },
        ),
      ),
    );
  }

  /// Capture a normal-sized widget (fits in viewport).
  static Future<Uint8List> _captureWidget(
    BuildContext context,
    Widget content,
  ) async {
    final poster =
        _wrapForCapture(context, SharePosterDecorator(content: content));
    final screenshotController = ScreenshotController();
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    return screenshotController.captureFromWidget(
      poster,
      context: context,
      delay: const Duration(milliseconds: 100),
      pixelRatio: pixelRatio,
    );
  }

  /// Capture a long widget that may exceed viewport height.
  /// Uses [captureFromLongWidget] for off-screen rendering.
  static Future<Uint8List> _captureLongWidget(
    BuildContext context,
    Widget content,
  ) async {
    final poster =
        _wrapForCapture(context, SharePosterDecorator(content: content));
    final screenshotController = ScreenshotController();
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    return screenshotController.captureFromLongWidget(
      poster,
      context: context,
      delay: const Duration(milliseconds: 200),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
      ),
      pixelRatio: pixelRatio,
    );
  }

  /// Wraps a widget with the necessary context providers for off-screen capture.
  static Widget _wrapForCapture(BuildContext context, Widget child) {
    return Theme(
      data: Theme.of(context),
      child: Directionality(
        textDirection: Directionality.of(context),
        child: MediaQuery(
          data: MediaQuery.of(context),
          child: Material(
            color: Colors.transparent,
            child: child,
          ),
        ),
      ),
    );
  }

  /// Internal method to perform the actual sharing.
  static Future<void> _performShare(Uint8List imageBytes) async {
    final tempDir = await getTemporaryDirectory();
    final file = File(
        '${tempDir.path}/memex_share_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(imageBytes);

    await Share.shareXFiles([XFile(file.path)],
        text: UserStorage.l10n.sharedFromMemex);
  }
}
