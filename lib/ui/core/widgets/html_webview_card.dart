import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:logging/logging.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';

/// Global height cache to avoid recalculating heights for the same HTML content
/// Key is the hash of the HTML content, value is the calculated height
class _HtmlHeightCache {
  static final Map<int, double> _cache = {};
  static const int _maxCacheSize = 200;

  static double? get(String html) {
    return _cache[html.hashCode];
  }

  static void set(String html, double height) {
    // Evict oldest entries if cache is too large
    if (_cache.length >= _maxCacheSize) {
      final keysToRemove =
          _cache.keys.take(_cache.length - _maxCacheSize + 50).toList();
      for (final key in keysToRemove) {
        _cache.remove(key);
      }
    }
    _cache[html.hashCode] = height;
  }
}

/// Configuration for HTML WebView card
class HtmlWebViewConfig {
  /// Initial height before content loads
  final double initialHeight;

  /// Minimum height threshold (content below this will trigger retry)
  final double minHeightThreshold;

  /// Maximum height limit
  final double maxHeight;

  /// Padding added to calculated height
  final double heightPadding;

  /// Base URL for resolving relative paths
  final String baseUrl;

  /// Whether to show container decoration (border, shadow, etc.)
  final bool showContainerDecoration;

  /// Border radius for the container
  final double borderRadius;

  /// Background color of the container
  final Color? backgroundColor;

  /// Border color of the container
  final Color? borderColor;

  const HtmlWebViewConfig({
    this.initialHeight = 160,
    this.minHeightThreshold = 100,
    this.maxHeight = 1000,
    this.heightPadding = 10,
    this.baseUrl = 'http://127.0.0.1:8080/api/v1',
    this.showContainerDecoration = false,
    this.borderRadius = 24,
    this.backgroundColor,
    this.borderColor,
  });

  /// Default config for timeline cards
  const factory HtmlWebViewConfig.timeline() = _TimelineConfig;

  /// Default config for insight cards
  const factory HtmlWebViewConfig.insight() = _InsightConfig;

  /// Default config for analysis content (larger)
  const factory HtmlWebViewConfig.analysis() = _AnalysisConfig;

  /// Default config for related cards (smaller)
  const factory HtmlWebViewConfig.relatedCard() = _RelatedCardConfig;

  /// Default config for snippets (header/footer in native widgets)
  const factory HtmlWebViewConfig.snippet() = _SnippetConfig;
}

/// Private implementation for timeline config
class _TimelineConfig extends HtmlWebViewConfig {
  const _TimelineConfig()
      : super(
          initialHeight: 160,
          minHeightThreshold: 100,
          maxHeight: 3000,
          heightPadding:
              0, // No extra padding, height should match content exactly
          showContainerDecoration: true,
          borderRadius: 24,
          backgroundColor: null, // Transparent to allow HTML background to show
          borderColor: const Color(0xFFF7F8FA),
        );
}

/// Private implementation for insight config
class _InsightConfig extends HtmlWebViewConfig {
  const _InsightConfig()
      : super(
          initialHeight: 160,
          minHeightThreshold: 100,
          maxHeight: 1000,
          heightPadding:
              0, // No extra padding, height should match content exactly
          showContainerDecoration: true,
          borderRadius: 24,
          backgroundColor: Colors.white,
          borderColor: const Color(0xFFF7F8FA),
        );
}

/// Private implementation for analysis config
class _AnalysisConfig extends HtmlWebViewConfig {
  const _AnalysisConfig()
      : super(
          initialHeight: 200,
          minHeightThreshold: 100,
          maxHeight: 2000,
          heightPadding:
              0, // No extra padding, height should match content exactly
          showContainerDecoration: false,
          borderRadius: 12,
        );
}

/// Private implementation for related card config
class _RelatedCardConfig extends HtmlWebViewConfig {
  const _RelatedCardConfig()
      : super(
          initialHeight: 120,
          minHeightThreshold: 60,
          maxHeight: 1000,
          heightPadding:
              0, // No extra padding, height should match content exactly
          showContainerDecoration: true,
          borderRadius: 16,
          backgroundColor: Colors.white,
          borderColor: const Color(0xFFE2E8F0),
        );
}

/// Private implementation for snippet config
class _SnippetConfig extends HtmlWebViewConfig {
  const _SnippetConfig()
      : super(
          initialHeight: 100,
          minHeightThreshold: 40,
          maxHeight: 2000,
          heightPadding: 20,
          showContainerDecoration: false,
          borderRadius: 0,
          backgroundColor: null,
          borderColor: null,
        );
}

/// Unified HTML WebView card widget
///
/// This widget provides a consistent way to render HTML content in WebView
/// across the app. It handles:
/// - Automatic height calculation
/// - Pointer events disabling
/// - HTML structure normalization
/// - Retry logic for height calculation
///
/// HTML Source Specification:
/// - The HTML should be a complete HTML document or a fragment
/// - If it's a fragment, it will be wrapped in a proper HTML structure
/// - The HTML should have a single root element for best height calculation
/// - External resources should use absolute URLs or relative to baseUrl
/// - CSS should be self-contained or use absolute URLs
class HtmlWebViewCard extends StatefulWidget {
  /// HTML content to render
  final String html;

  /// Configuration for the WebView
  final HtmlWebViewConfig config;

  const HtmlWebViewCard({
    super.key,
    required this.html,
    this.config = const HtmlWebViewConfig.timeline(),
    this.onContentTap,
  });

  /// Callback for content taps (when not clicking interactive elements)
  final VoidCallback? onContentTap;

  @override
  State<HtmlWebViewCard> createState() => _HtmlWebViewCardState();
}

class _HtmlWebViewCardState extends State<HtmlWebViewCard> {
  final Logger _logger = getLogger('HtmlWebViewCard');
  WebViewController? _controller;
  double _height = 160;
  // Layer 2: Flutter MethodChannel
  static const MethodChannel _channel =
      MethodChannel('com.memexlab.memex/webview');

  /// Layer 2: disable WebView scrolling via platform channel
  /// Called when: 1) page load complete (onPageFinished) 2) height updated (Future.microtask after setState)
  Future<void> _disableWebViewScrolling() async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod('disableScrolling');
    } catch (e) {
      // platform channel may be unavailable, ignore
      _logger.warning('Failed to disable WebView scrolling: $e', e);
    }
  }

  /// Removes border-radius from root container only to avoid duplicate rounding
  /// Flutter layer handles root container border radius uniformly
  /// Internal elements (icons, badges, etc.) keep their border-radius
  String _removeBorderRadius(String html) {
    // Remove border-radius from .card class (root container)
    // This preserves border-radius for internal elements like icons, badges, etc.
    // Note: Border removal is handled by CSS, not here
    html = html.replaceAllMapped(
      RegExp(r'\.card\s*\{[^}]*\}', caseSensitive: false),
      (match) {
        // Remove border-radius from .card rule, keep the rest
        String rule = match.group(0)!;
        rule = rule.replaceAllMapped(
          RegExp(r'border-radius[^;}]*:\s*[^;}]+[;\s]*', caseSensitive: false),
          (m) => '',
        );
        // Clean up multiple semicolons
        rule = rule.replaceAll(RegExp(r';;+'), ';');
        return rule;
      },
    );

    // Remove border-radius from root div with class="card" in inline styles
    // Handle both single and double quotes separately
    // Note: Border removal is handled by CSS, not here
    html = html.replaceAllMapped(
      RegExp('<div[^>]*class\\s*=\\s*"card"[^>]*style\\s*="[^"]*"',
          caseSensitive: false),
      (match) {
        String div = match.group(0)!;
        // Remove border-radius only
        div = div.replaceAllMapped(
          RegExp(r'border-radius[^;"]*:\s*[^;"]+;?', caseSensitive: false),
          (m) => '',
        );
        // Clean up multiple semicolons
        div = div.replaceAll(RegExp(r';;+'), ';');
        return div;
      },
    );
    html = html.replaceAllMapped(
      RegExp("<div[^>]*class\\s*=\\s*'card'[^>]*style\\s*='[^']*'",
          caseSensitive: false),
      (match) {
        String div = match.group(0)!;
        // Remove border-radius only
        div = div.replaceAllMapped(
          RegExp('border-radius[^;\']*:\\s*[^;\']+;?', caseSensitive: false),
          (m) => '',
        );
        // Clean up multiple semicolons
        div = div.replaceAll(RegExp(r';;+'), ';');
        return div;
      },
    );

    // Remove rounded-* classes from root container only (class="card rounded-*")
    html = html.replaceAllMapped(
      RegExp('class\\s*=\\s*"card\\s+rounded-\\[?[^\\s">)\\]\\]]+\\]?"',
          caseSensitive: false),
      (match) => match.group(0)!.replaceAllMapped(
            RegExp('\\s+rounded-\\[?[^\\s">)\\]\\]]+\\]?',
                caseSensitive: false),
            (m) => '',
          ),
    );
    html = html.replaceAllMapped(
      RegExp("class\\s*=\\s*'card\\s+rounded-\\[?[^\\s'>)\\]\\]]+\\]?'",
          caseSensitive: false),
      (match) => match.group(0)!.replaceAllMapped(
            RegExp('\\s+rounded-\\[?[^\\s\'>)\\]\\]]+\\]?',
                caseSensitive: false),
            (m) => '',
          ),
    );
    html = html.replaceAllMapped(
      RegExp('class\\s*=\\s*"rounded-\\[?[^\\s">)\\]\\]]+\\]?\\s+card"',
          caseSensitive: false),
      (match) => match.group(0)!.replaceAllMapped(
            RegExp('rounded-\\[?[^\\s">)\\]\\]]+\\]?\\s+',
                caseSensitive: false),
            (m) => '',
          ),
    );
    html = html.replaceAllMapped(
      RegExp("class\\s*=\\s*'rounded-\\[?[^\\s'>)\\]\\]]+\\]?\\s+card'",
          caseSensitive: false),
      (match) => match.group(0)!.replaceAllMapped(
            RegExp('rounded-\\[?[^\\s\'>)\\]\\]]+\\]?\\s+',
                caseSensitive: false),
            (m) => '',
          ),
    );

    return html;
  }

  /// Wraps HTML with necessary scripts and styles
  ///
  /// This method:
  /// 1. Removes border-radius from HTML (handled by Flutter layer)
  /// 2. Adds CSS to disable pointer events
  /// 3. Adds JavaScript to calculate and report height
  /// 4. Ensures proper HTML structure
  String _wrapHtmlWithScript(String html) {
    // Reduced number of retries to minimize setState calls
    String script = '''
      <script>
        (function() {
          let lastHeight = 0;
          let retryCount = 0;
          // Increased minimal polling duration
          const maxRetries = 20; 
          const minHeightThreshold = ${widget.config.minHeightThreshold};
          const maxHeight = ${widget.config.maxHeight};

          // Click handler for interaction
          document.addEventListener('click', function(e) {
            const interactive = e.target.closest('audio, video, a, button, input');
            if (interactive) return;
            if (window.ClickChannel) {
              ClickChannel.postMessage('click');
            }
          });

          function sendHeight(height) {
             if (Math.abs(height - lastHeight) > 2 && height > 0) {
                lastHeight = height;
                if (window.HeightChannel) {
                   HeightChannel.postMessage(height.toString());
                }
             }
          }

          function calculateHeight() {
            try {
              const body = document.body;
              if (!body) return 0;

              let height = 0;
              // Method 1: Scroll Height (most reliable for overflowing content)
              height = body.scrollHeight;

              // Method 2: Bounding Client Rect of Body (if scrollHeight is weird)
              const bodyRect = body.getBoundingClientRect();
              if (bodyRect.height > height) height = bodyRect.height;
              
              // Method 3: First child check (for single car usage)
              if (body.firstElementChild) {
                 const rect = body.firstElementChild.getBoundingClientRect();
                 const childHeight = rect.bottom - rect.top; // includes margins if mapped correctly
                 if (childHeight > height) height = childHeight;
              }

              // Clamp
              return Math.min(height, maxHeight);
            } catch (e) {
              return 0;
            }
          }

          function checkUpdate() {
             const h = calculateHeight();
             if (h > 0) sendHeight(h);
          }

          // 1. Initial Check
          checkUpdate();

          // 2. ResizeObserver for dynamic content changes
          if (window.ResizeObserver) {
            const resizeObserver = new ResizeObserver(() => checkUpdate());
            resizeObserver.observe(document.body);
            if (document.body.firstElementChild) {
               resizeObserver.observe(document.body.firstElementChild);
            }
          }

          // 3. Image Load Listeners
          const images = document.querySelectorAll('img');
          images.forEach(img => {
             img.addEventListener('load', checkUpdate);
          });

          // 4. Polling Fallback (Aggressive at start, then slower)
          // Run frequently at start to catch initial render
          let interval = setInterval(() => {
             checkUpdate();
             retryCount++;
             if (retryCount > maxRetries) {
                clearInterval(interval);
                // Keep a slow poll just in case
                setInterval(checkUpdate, 1000); 
             }
          }, 200);
          
          // Also listen to window load
          window.addEventListener('load', checkUpdate);
        })();
      </script>
    ''';

    // Remove border-radius from outermost container only
    // Flutter layer handles all border radius uniformly
    // Border removal is handled by CSS (body > *:first-child rule)
    html = _removeBorderRadius(html);

    // CSS to disable pointer events and ensure proper sizing
    // Add cross-platform normalization for iOS and Android WebView rendering
    String pointerEventsStyle = '''
      <style>
        html, body {
          margin: 0;
          padding: 0;
          border: 0;
          outline: 0;
          overflow: hidden;
          pointer-events: ${widget.onContentTap != null ? 'auto' : 'none !important'};
          height: auto !important;
          min-height: 0 !important;
          -webkit-text-size-adjust: 100%;
          -moz-text-size-adjust: 100%;
          -ms-text-size-adjust: 100%;
          text-size-adjust: 100%;
          -webkit-font-smoothing: antialiased;
          -moz-osx-font-smoothing: grayscale;
        }
        * {
          pointer-events: ${widget.onContentTap != null ? 'auto' : 'none !important'};
          -webkit-box-sizing: border-box;
          -moz-box-sizing: border-box;
          box-sizing: border-box;
          -webkit-tap-highlight-color: transparent;
        }
        /* Only remove borders from root html/body elements, not from internal elements */
        html, body {
          border: 0 !important;
          outline: 0 !important;
        }
        /* Remove border from body's first direct child element (the root card container) */
        /* This works for any card type (.bill-card, .moment-card, .card, etc.) */
        /* The key is to target the outermost container regardless of its class name */
        body > *:first-child {
          border: none !important;
          border-width: 0 !important;
          border-top: none !important;
          border-bottom: none !important;
          border-left: none !important;
          border-right: none !important;
          outline: none !important;
        }
        /* Ensure consistent rendering across platforms */
        body {
          font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
          -webkit-font-smoothing: antialiased;
          -moz-osx-font-smoothing: grayscale;
          border: none !important;
          outline: none !important;
        }
        /* Normalize image rendering - preserve image borders if they exist */
        img {
          max-width: 100%;
          height: auto;
          display: block;
        }
        /* Remove bottom margin/padding from all elements to avoid blank space */
        body > *:last-child {
          margin-bottom: 0 !important;
          padding-bottom: 0 !important;
        }
        /* Remove bottom margin from all direct children to prevent blank space */
        body > * {
          margin-bottom: 0;
        }
        /* Ensure body itself has no bottom padding/margin */
        body {
          margin-bottom: 0 !important;
          padding-bottom: 0 !important;
        }
        /* Remove any table borders if present */
        table, td, th {
          border: none !important;
          border-collapse: collapse;
        }
        /* Remove any hr or line elements */
        hr {
          display: none !important;
          border: none !important;
          height: 0 !important;
        }
      </style>
    ''';

    // Normalize HTML structure
    if (html.contains('</head>')) {
      // Insert style before </head> and script before </body>
      html = html.replaceAll('</head>', '$pointerEventsStyle</head>');
      if (html.contains('</body>')) {
        html = html.replaceAll('</body>', '$script</body>');
      } else {
        html = '$html$script';
      }
    } else if (html.contains('<head>')) {
      // Insert style after <head> and script before </body>
      html = html.replaceAll('<head>', '<head>$pointerEventsStyle');
      if (html.contains('</body>')) {
        html = html.replaceAll('</body>', '$script</body>');
      } else {
        html = '$html$script';
      }
    } else {
      // Wrap in full HTML structure with enhanced viewport for cross-platform consistency
      html = '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
        <meta name="apple-mobile-web-app-capable" content="yes">
        <meta name="apple-mobile-web-app-status-bar-style" content="default">
        $pointerEventsStyle
      </head>
      <body>
        $html
        $script
      </body>
      </html>
      ''';
    }

    return html;
  }

  @override
  void initState() {
    super.initState();
    // Try to use cached height first for instant display
    final cachedHeight = _HtmlHeightCache.get(widget.html);
    _height = cachedHeight ?? widget.config.initialHeight;

    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            // allow all navigation including HTTP resources
            onNavigationRequest: (NavigationRequest request) {
              // allow all requests including HTTP images
              return NavigationDecision.navigate;
            },
            // disable scrolling as soon as page loads
            onPageFinished: (String url) {
              _disableWebViewScrolling();
              // permanently disable scroll via JavaScript injection
              _controller?.runJavaScript('''
                (function() {
                  document.documentElement.style.overflow = 'hidden';
                  document.body.style.overflow = 'hidden';
                  document.body.style.overflowX = 'hidden';
                  document.body.style.overflowY = 'hidden';
                })();
              ''');
            },
          ),
        )
        ..addJavaScriptChannel(
          'ClickChannel',
          onMessageReceived: (JavaScriptMessage message) {
            if (message.message == 'click') {
              widget.onContentTap?.call();
            }
          },
        )
        ..addJavaScriptChannel(
          'HeightChannel',
          onMessageReceived: (JavaScriptMessage message) {
            final height = double.tryParse(message.message);

            if (height == null || height <= 0) return;

            final newHeight = height + widget.config.heightPadding;

            // Limit height to reasonable range
            if (!mounted) {
              return;
            }

            final heightToSet = newHeight > widget.config.maxHeight
                ? widget.config.maxHeight
                : newHeight;

            final cachedHeight = _HtmlHeightCache.get(widget.html);

            // Only update if changed significantly
            if (cachedHeight == null ||
                (heightToSet - cachedHeight).abs() > 2) {
              // Cache the height for future use
              _HtmlHeightCache.set(widget.html, heightToSet);
              setState(() {
                _height = heightToSet;
              });
              // disable scrolling right after height update (Future.microtask after setState)
              Future.microtask(() {
                _disableWebViewScrolling();
              });
            }
          },
        );

      // Set platform-specific user agent for consistent rendering
      if (Platform.isIOS) {
        _controller!.setUserAgent(
            'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1');
      } else if (Platform.isAndroid) {
        _controller!.setUserAgent(
            'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36');
      }

      _controller!.loadHtmlString(
        _wrapHtmlWithScript(widget.html),
        baseUrl: widget.config.baseUrl,
      );
    }
  }

  @override
  void didUpdateWidget(covariant HtmlWebViewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.html != widget.html) {
      final cachedHeight = _HtmlHeightCache.get(widget.html);
      // Reset height when HTML changes
      setState(() {
        _height = cachedHeight ?? widget.config.initialHeight;
      });
      _controller!.loadHtmlString(
        _wrapHtmlWithScript(widget.html),
        baseUrl: widget.config.baseUrl,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Web fallback
    if (kIsWeb) {
      return Container(
        height: widget.config.initialHeight,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(widget.config.borderRadius),
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

    if (_controller == null) {
      return const SizedBox.shrink();
    }

    // Create WebView widget
    // Use RepaintBoundary to prevent unnecessary repaints that might cause visual artifacts
    Widget webView = RepaintBoundary(
      child: SizedBox(
        height: _height,
        child: WebViewWidget(controller: _controller!),
      ),
    );

    // Always wrap in Container with border radius to ensure proper clipping
    // The border should be applied to the outer container, not clipped
    // Background color is optional - if null, HTML background will show through
    return Container(
      decoration: BoxDecoration(
        color: widget.config.backgroundColor,
        borderRadius: BorderRadius.circular(widget.config.borderRadius),
        border: widget.config.borderColor != null
            ? Border.all(
                color: widget.config.borderColor!,
                width: 1.0,
              )
            : null,
        boxShadow: widget.config.showContainerDecoration &&
                widget.config.backgroundColor == Colors.white
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.config.borderRadius),
        clipBehavior: Clip.antiAlias,
        child: webView,
      ),
    );
  }
}
