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
    // Initial render with branding
    var showBranding = true;
    var isDetailStyle = false;

    // Cache rendered images keyed by (isDetail, showBranding)
    final cache = <String, Uint8List>{};

    String cacheKey(bool detail, bool branding) =>
        '${detail ? 'd' : 'c'}_${branding ? 'b' : 'n'}';

    Future<Uint8List> renderCurrent(BuildContext ctx) async {
      final key = cacheKey(isDetailStyle, showBranding);
      if (cache.containsKey(key)) return cache[key]!;

      final widget = isDetailStyle ? detailContent! : content;
      final bytes = isDetailStyle
          ? await _captureLongWidget(ctx, widget, showBranding: showBranding)
          : await _captureWidget(ctx, widget, showBranding: showBranding);
      cache[key] = bytes;
      return bytes;
    }

    final initialBytes =
        await _captureWidget(context, content, showBranding: showBranding);
    cache[cacheKey(false, true)] = initialBytes;
    if (!context.mounted) return;

    Uint8List currentBytes = initialBytes;

    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => SharePreviewDialog(
          imageBytes: currentBytes,
          isDetailStyle: isDetailStyle,
          showBranding: showBranding,
          onCancel: () => Navigator.of(ctx).pop(),
          onToggleStyle: detailContent != null
              ? () async {
                  isDetailStyle = !isDetailStyle;
                  final bytes = await renderCurrent(ctx);
                  setDialogState(() {
                    currentBytes = bytes;
                  });
                }
              : null,
          onToggleBranding: () async {
            showBranding = !showBranding;
            final bytes = await renderCurrent(ctx);
            setDialogState(() {
              currentBytes = bytes;
            });
          },
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
    Widget content, {
    bool showBranding = true,
  }) async {
    final poster = _wrapForCapture(
      context,
      SharePosterDecorator(content: content, showBranding: showBranding),
    );
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
    Widget content, {
    bool showBranding = true,
  }) async {
    final poster = _wrapForCapture(
      context,
      SharePosterDecorator(content: content, showBranding: showBranding),
    );
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

  /// Shares plain text content as a temporary file so the user can save it.
  static Future<void> shareTextAsFile(
    BuildContext context, {
    required String fileName,
    required String content,
    String mimeType = 'text/plain',
    String? text,
  }) async {
    final box = context.findRenderObject() as RenderBox?;
    final sharePositionOrigin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : const Rect.fromLTWH(0, 0, 100, 100);
    final tempDir = await getTemporaryDirectory();
    final safeFileName = _safeFileName(fileName);
    final file = File('${tempDir.path}/$safeFileName');
    await file.writeAsString(content);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: mimeType, name: safeFileName)],
      text: text,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  static String _safeFileName(String fileName) {
    final sanitized = fileName
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ');
    return sanitized.isEmpty ? 'memex.md' : sanitized;
  }
}
