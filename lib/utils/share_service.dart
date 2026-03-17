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
  static Future<void> shareWidgetAsPoster(BuildContext context, Widget content) async {
    // 1. Assemble share poster with decorator
    final poster = Theme(
      data: Theme.of(context),
      child: Directionality(
        textDirection: Directionality.of(context),
        child: MediaQuery(
          data: MediaQuery.of(context),
          child: Material(
            color: Colors.transparent,
            child: SharePosterDecorator(content: content),
          ),
        ),
      ),
    );
    
    // 2. Render to image
    final screenshotController = ScreenshotController();
    final Uint8List imageBytes = await screenshotController.captureFromWidget(
      poster,
      context: context,
      delay: const Duration(milliseconds: 100),
    );

    if (!context.mounted) return;

    // 3. Show preview confirmation dialog
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      builder: (ctx) => SharePreviewDialog(
        imageBytes: imageBytes,
        onCancel: () => Navigator.of(ctx).pop(),
        onShare: () async {
          Navigator.of(ctx).pop();
          await _performShare(imageBytes);
        },
      ),
    );
  }

  /// Internal method to perform the actual sharing.
  static Future<void> _performShare(Uint8List imageBytes) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/memex_share_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(imageBytes);

    await Share.shareXFiles([XFile(file.path)], text: UserStorage.l10n.sharedFromMemex);
  }
}
