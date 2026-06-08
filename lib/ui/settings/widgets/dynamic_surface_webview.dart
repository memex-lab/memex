import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show Factory, kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Full-page WebView renderer for Dynamic Surfaces.
///
/// This is intentionally separate from HtmlWebViewCard. Dynamic Surfaces are
/// page-level UI, so the WebView owns vertical scrolling and fills its parent
/// instead of being measured into a Timeline card height.
class DynamicSurfaceWebView extends StatefulWidget {
  const DynamicSurfaceWebView({
    super.key,
    required this.html,
    this.baseUrl = 'http://127.0.0.1:8080/api/v1',
    this.bottomContentInset = 0,
  });

  final String html;
  final String baseUrl;
  final double bottomContentInset;

  @override
  State<DynamicSurfaceWebView> createState() => _DynamicSurfaceWebViewState();
}

class _DynamicSurfaceWebViewState extends State<DynamicSurfaceWebView> {
  static final Set<Factory<OneSequenceGestureRecognizer>>
      _webViewGestureRecognizers = {
    Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
  };

  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    if (kIsWeb) return;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (_) => NavigationDecision.navigate,
        ),
      );

    if (Platform.isIOS) {
      _controller!.setUserAgent(
        'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) '
        'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 '
        'Mobile/15E148 Safari/604.1',
      );
    } else if (Platform.isAndroid) {
      _controller!.setUserAgent(
        'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      );
    }

    _controller!.loadHtmlString(
      _wrapHtml(widget.html),
      baseUrl: widget.baseUrl,
    );
  }

  @override
  void didUpdateWidget(covariant DynamicSurfaceWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.html != widget.html ||
        oldWidget.baseUrl != widget.baseUrl ||
        oldWidget.bottomContentInset != widget.bottomContentInset) {
      _controller?.loadHtmlString(
        _wrapHtml(widget.html),
        baseUrl: widget.baseUrl,
      );
    }
  }

  String _wrapHtml(String html) {
    final bottomInset = widget.bottomContentInset.clamp(0, 320).toDouble();
    final style = '''
      <style>
        html, body {
          margin: 0;
          padding: 0;
          min-height: 100%;
          overflow-x: hidden;
          overflow-y: auto;
          -webkit-overflow-scrolling: touch;
          -webkit-text-size-adjust: 100%;
          text-size-adjust: 100%;
          background: transparent;
        }
        * {
          box-sizing: border-box;
          -webkit-tap-highlight-color: transparent;
        }
        img, video, canvas, svg {
          max-width: 100%;
        }
        body::after {
          content: "";
          display: block;
          height: ${bottomInset}px;
          min-height: ${bottomInset}px;
          flex: 0 0 ${bottomInset}px;
          pointer-events: none;
        }
      </style>
    ''';

    if (html.contains('</head>')) {
      return html.replaceAll('</head>', '$style</head>');
    }
    if (html.contains('<head>')) {
      return html.replaceAll('<head>', '<head>$style');
    }

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
  $style
</head>
<body>
  $html
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            UserStorage.l10n.webHtmlPreviewUnavailable,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF92400E),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }

    return ColoredBox(
      color: AppColors.background,
      child: WebViewWidget(
        controller: controller,
        gestureRecognizers: _webViewGestureRecognizers,
      ),
    );
  }
}
