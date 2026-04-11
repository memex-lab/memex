import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:memex/utils/logger.dart';
import '../resource_type.dart';

/// Extracts metadata from web URLs by fetching HTML and parsing
/// Open Graph / meta tags.
///
/// Designed for robustness in C-end scenarios:
/// - Strict timeout and size limits
/// - Handles redirects, non-HTML responses, JS-rendered pages gracefully
/// - Never throws — always returns at least basic metadata
class UrlMetadataExtractor {
  static final Logger _logger = getLogger('UrlMetadataExtractor');

  /// Max response body size to read (256KB). Prevents OOM on large files.
  static const int _maxResponseBytes = 256 * 1024;

  /// Per-URL timeout.
  static const Duration _timeout = Duration(seconds: 8);

  static Dio? _dioInstance;

  static Dio get _dio {
    _dioInstance ??= Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 6),
      receiveTimeout: const Duration(seconds: 6),
      sendTimeout: const Duration(seconds: 4),
      headers: {
        // Use a real browser UA — many sites block bot UAs
        'User-Agent':
            'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
            'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 '
            'Mobile/15E148 Safari/604.1',
        'Accept': 'text/html,application/xhtml+xml,*/*;q=0.8',
        'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
      },
      followRedirects: true,
      maxRedirects: 5,
      receiveDataWhenStatusError: false,
      // Validate status: accept 2xx and 3xx
      validateStatus: (status) => status != null && status < 400,
    ));
    return _dioInstance!;
  }

  /// Fetch and extract metadata from a URL.
  /// Never throws. Returns basic metadata on any failure.
  static Future<ResourceMetadata> extract(String url) async {
    try {
      return await _extractWithTimeout(url)
          .timeout(_timeout, onTimeout: () {
        _logger.info('Timeout fetching $url');
        return _fallbackMetadata(url);
      });
    } catch (e) {
      _logger.warning('Unexpected error extracting $url: $e');
      return _fallbackMetadata(url);
    }
  }

  static Future<ResourceMetadata> _extractWithTimeout(String url) async {
    try {
      // Use streaming to enforce size limit
      final response = await _dio.get<ResponseBody>(
        url,
        options: Options(responseType: ResponseType.stream),
      );

      if (response.data == null) return _fallbackMetadata(url);

      // Check content-type: only parse HTML
      final contentType =
          response.headers.value(HttpHeaders.contentTypeHeader) ?? '';
      if (!contentType.contains('text/html') &&
          !contentType.contains('application/xhtml')) {
        _logger.info('Non-HTML content-type for $url: $contentType');
        return ResourceMetadata(
          type: ResourceType.url,
          source: url,
          title: _titleFromUrl(url),
          status: RecognitionStatus.enriched,
          extra: {'content_type': contentType},
        );
      }

      // Read up to _maxResponseBytes
      final bodyBytes = <int>[];
      await for (final chunk in response.data!.stream) {
        bodyBytes.addAll(chunk);
        if (bodyBytes.length >= _maxResponseBytes) break;
      }

      final html = String.fromCharCodes(bodyBytes);
      final title = _extractTitle(html);
      final description = _extractMetaContent(html, 'description') ??
          _extractMetaProperty(html, 'og:description');
      final ogTitle = _extractMetaProperty(html, 'og:title');
      final ogImage = _extractMetaProperty(html, 'og:image');
      final ogSiteName = _extractMetaProperty(html, 'og:site_name');
      final ogType = _extractMetaProperty(html, 'og:type');

      // Resolve relative og:image to absolute
      String? resolvedImage = ogImage;
      if (ogImage != null && !ogImage.startsWith('http')) {
        try {
          resolvedImage = Uri.parse(url).resolve(ogImage).toString();
        } catch (_) {}
      }

      final finalUrl = response.realUri.toString();

      return ResourceMetadata(
        type: ResourceType.url,
        source: url,
        title: ogTitle ?? title ?? _titleFromUrl(url),
        description: _truncate(description, 500),
        thumbnailUrl: resolvedImage,
        status: RecognitionStatus.enriched,
        extra: {
          if (ogSiteName != null) 'site_name': ogSiteName,
          if (ogType != null) 'og_type': ogType,
          if (finalUrl != url) 'final_url': finalUrl,
        },
      );
    } on DioException catch (e) {
      _logger.info('DioException fetching $url: ${e.type} ${e.message}');
      return _fallbackMetadata(url);
    }
  }

  static ResourceMetadata _fallbackMetadata(String url) {
    return ResourceMetadata(
      type: ResourceType.url,
      source: url,
      title: _titleFromUrl(url),
      status: RecognitionStatus.failed,
    );
  }

  // --- Simple HTML parsing (no dependency on html package) ---

  static String? _extractTitle(String html) {
    final match = RegExp(
      r'<title[^>]*>(.*?)</title>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(html);
    return _cleanText(match?.group(1));
  }

  static String? _extractMetaContent(String html, String name) {
    // Try both attribute orders: name...content and content...name
    for (final pattern in [
      '<meta[^>]+name=["\']$name["\'][^>]+content=["\'](.*?)["\']',
      '<meta[^>]+content=["\'](.*?)["\'][^>]+name=["\']$name["\']',
    ]) {
      final match =
          RegExp(pattern, caseSensitive: false, dotAll: true).firstMatch(html);
      if (match != null) return _cleanText(match.group(1));
    }
    return null;
  }

  static String? _extractMetaProperty(String html, String property) {
    for (final pattern in [
      '<meta[^>]+property=["\']$property["\'][^>]+content=["\'](.*?)["\']',
      '<meta[^>]+content=["\'](.*?)["\'][^>]+property=["\']$property["\']',
    ]) {
      final match =
          RegExp(pattern, caseSensitive: false, dotAll: true).firstMatch(html);
      if (match != null) return _cleanText(match.group(1));
    }
    return null;
  }

  static String _titleFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (_) {
      return url;
    }
  }

  static String? _cleanText(String? text) {
    if (text == null) return null;
    final cleaned = text
        .trim()
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&#x27;', "'")
        .replaceAll('&#x2F;', '/')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned.isEmpty ? null : cleaned;
  }

  static String? _truncate(String? text, int maxLen) {
    if (text == null) return null;
    return text.length <= maxLen ? text : '${text.substring(0, maxLen)}...';
  }
}
