import 'dart:async';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:memex/utils/logger.dart';
import 'resource_type.dart';
import 'extractors/url_metadata_extractor.dart';
import 'extractors/pdf_text_extractor.dart';

/// Recognizes and extracts metadata from various resource types
/// found in user input (URLs, PDFs, documents, etc.).
///
/// Design principles for C-end robustness:
/// - Detection (regex) is synchronous and instant — never blocks input
/// - Enrichment (network fetch, file parsing) is async with strict timeouts
/// - Every method is null-safe and never throws
/// - Results are cached to avoid redundant work
/// - Parallel processing with concurrency limits
class ResourceRecognizer {
  static final Logger _logger = getLogger('ResourceRecognizer');

  // --- URL patterns ---

  /// Matches http/https URLs in text.
  /// Handles: standard URLs, URLs with Chinese characters, encoded URLs,
  /// URLs in parentheses/brackets, short links, etc.
  static final RegExp _urlPattern = RegExp(
    r'https?://'
    r'[^\s<>\[\]{}"'
    r'\uFF01-\uFF5E'  // Fullwidth ASCII variants
    r'\uFF0C\u3002\uFF01\uFF1F\u3001\uFF1B\uFF1A'  // Chinese punctuation
    r'\u201C\u201D\u2018\u2019\uFF08\uFF09\u3010\u3011\u300A\u300B'
    r']+',
    unicode: true,
  );

  /// Characters that are unlikely to be the last char of a URL.
  static final RegExp _trailingJunk = RegExp(r'[.,;:!?\)\]}>，。！？、；：）】》]+$');

  // --- File extension patterns ---

  static const _pdfExtensions = ['.pdf'];
  static const _docExtensions = ['.doc', '.docx'];

  /// Max number of URLs to process in parallel.
  static const int _maxParallelUrls = 3;

  /// Overall timeout for recognizeText (prevents blocking submit).
  static const Duration _overallTimeout = Duration(seconds: 12);

  // --- Simple in-memory cache ---
  static final Map<String, ResourceMetadata> _cache = {};
  static const int _maxCacheSize = 100;

  /// Synchronous detection: extract resource references from text.
  /// Returns immediately with basic metadata (no network calls).
  static List<ResourceMetadata> detectResources(String text) {
    final results = <ResourceMetadata>[];
    final urls = extractUrls(text);
    for (final url in urls) {
      // Check cache first
      if (_cache.containsKey(url)) {
        results.add(_cache[url]!);
        continue;
      }
      results.add(_classifyUrl(url));
    }
    return results;
  }

  /// Async enrichment: detect + fetch metadata for all resources.
  /// Has an overall timeout to avoid blocking the input pipeline.
  /// Returns whatever it managed to fetch within the time limit.
  static Future<List<ResourceMetadata>> recognizeText(String text) async {
    try {
      return await _recognizeTextInternal(text)
          .timeout(_overallTimeout, onTimeout: () {
        _logger.info('Resource recognition timed out, returning detected-only');
        return detectResources(text);
      });
    } catch (e) {
      _logger.warning('Resource recognition failed: $e');
      return detectResources(text);
    }
  }

  static Future<List<ResourceMetadata>> _recognizeTextInternal(
      String text) async {
    final urls = extractUrls(text);
    if (urls.isEmpty) return [];

    // Process URLs in parallel with concurrency limit
    final results = <ResourceMetadata>[];
    for (var i = 0; i < urls.length; i += _maxParallelUrls) {
      final batch = urls.skip(i).take(_maxParallelUrls);
      final futures = batch.map((url) => _processUrl(url));
      final batchResults = await Future.wait(futures);
      results.addAll(batchResults);
    }

    return results;
  }

  /// Recognize resources from file paths (e.g., shared files, picked files).
  static Future<List<ResourceMetadata>> recognizeFiles(
      List<String> filePaths) async {
    final results = <ResourceMetadata>[];
    for (final path in filePaths) {
      try {
        final meta = await _processFile(path);
        if (meta != null) results.add(meta);
      } catch (e) {
        _logger.warning('Failed to process file $path: $e');
      }
    }
    return results;
  }

  /// Extract all URLs from text.
  static List<String> extractUrls(String text) {
    final matches = _urlPattern.allMatches(text);
    final seen = <String>{};
    final urls = <String>[];

    for (final match in matches) {
      var url = match.group(0)!;
      // Clean trailing punctuation
      url = url.replaceAll(_trailingJunk, '');
      // Balance parentheses: if URL has unmatched ), trim it
      url = _balanceParentheses(url);
      if (url.isNotEmpty && seen.add(url)) {
        urls.add(url);
      }
    }
    return urls;
  }

  /// Check if a file path looks like a supported resource.
  static ResourceType? detectFileType(String path) {
    final lower = path.toLowerCase();
    if (_pdfExtensions.any(lower.endsWith)) return ResourceType.pdf;
    if (_docExtensions.any(lower.endsWith)) return ResourceType.doc;
    return null;
  }

  /// Check if text contains any recognizable resources.
  static bool containsResources(String text) {
    return _urlPattern.hasMatch(text);
  }

  /// Clear the metadata cache.
  static void clearCache() => _cache.clear();

  // --- Internal processing ---

  /// Classify a URL by its extension without fetching.
  static ResourceMetadata _classifyUrl(String url) {
    final lower = url.toLowerCase();
    final uri = Uri.tryParse(url);
    final path = uri?.path.toLowerCase() ?? lower;

    if (_pdfExtensions.any((ext) => path.endsWith(ext) || lower.contains('$ext?'))) {
      return ResourceMetadata(
        type: ResourceType.pdf,
        source: url,
        title: _titleFromUrl(url),
        status: RecognitionStatus.detected,
        extra: const {'is_remote': true},
      );
    }

    if (_docExtensions.any((ext) => path.endsWith(ext))) {
      return ResourceMetadata(
        type: ResourceType.doc,
        source: url,
        title: _titleFromUrl(url),
        status: RecognitionStatus.detected,
        extra: const {'is_remote': true},
      );
    }

    return ResourceMetadata(
      type: ResourceType.url,
      source: url,
      title: _titleFromUrl(url),
      status: RecognitionStatus.detected,
    );
  }

  static Future<ResourceMetadata> _processUrl(String url) async {
    // Check cache
    if (_cache.containsKey(url)) return _cache[url]!;

    _logger.fine('Processing URL: $url');

    final classified = _classifyUrl(url);

    // For non-HTML resources, don't try to fetch HTML metadata
    if (classified.type != ResourceType.url) {
      _cacheResult(url, classified);
      return classified;
    }

    // Fetch HTML metadata
    final enriched = await UrlMetadataExtractor.extract(url);
    _cacheResult(url, enriched);
    return enriched;
  }

  static Future<ResourceMetadata?> _processFile(String filePath) async {
    final type = detectFileType(filePath);

    switch (type) {
      case ResourceType.pdf:
        return PdfTextExtractor.extract(filePath);
      case ResourceType.doc:
        final file = File(filePath);
        if (!await file.exists()) return null;
        return ResourceMetadata(
          type: ResourceType.doc,
          source: filePath,
          title: filePath.split('/').last.replaceAll(RegExp(r'\.[^.]+$'), ''),
          status: RecognitionStatus.detected,
          extra: {'file_size': await file.length()},
        );
      case null:
        // Generic file
        final file = File(filePath);
        if (!await file.exists()) return null;
        return ResourceMetadata(
          type: ResourceType.file,
          source: filePath,
          title: filePath.split('/').last,
          status: RecognitionStatus.detected,
          extra: {'file_size': await file.length()},
        );
      default:
        return null;
    }
  }

  static void _cacheResult(String key, ResourceMetadata meta) {
    if (_cache.length >= _maxCacheSize) {
      // Evict oldest entries
      final keysToRemove = _cache.keys.take(_maxCacheSize ~/ 4).toList();
      for (final k in keysToRemove) {
        _cache.remove(k);
      }
    }
    _cache[key] = meta;
  }

  /// Balance parentheses in URL — handles Wikipedia-style URLs like
  /// https://en.wikipedia.org/wiki/Dart_(programming_language)
  static String _balanceParentheses(String url) {
    var openCount = 0;
    var lastValidIndex = url.length;

    for (var i = 0; i < url.length; i++) {
      if (url[i] == '(') {
        openCount++;
      } else if (url[i] == ')') {
        if (openCount > 0) {
          openCount--;
        } else {
          // Unmatched closing paren — URL likely ends before this
          lastValidIndex = i;
          break;
        }
      }
    }

    return url.substring(0, lastValidIndex);
  }

  static String _titleFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isNotEmpty) {
        final last = Uri.decodeComponent(segments.last);
        final cleaned = last.replaceAll(RegExp(r'\.[^.]+$'), '');
        if (cleaned.isNotEmpty) return cleaned;
      }
      return uri.host;
    } catch (_) {
      return url;
    }
  }
}
