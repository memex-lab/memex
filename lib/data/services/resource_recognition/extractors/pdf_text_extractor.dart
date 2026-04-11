import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:memex/utils/logger.dart';
import '../resource_type.dart';

/// Extracts text and metadata from local PDF files.
///
/// Strategy for C-end robustness:
/// - Only reads the first/last chunks of the file for metadata (not the whole file)
/// - Text extraction is best-effort; the real heavy lifting is delegated to
///   the LLM (CardAgent) which receives the extracted text + file reference
/// - Handles encrypted, compressed, and malformed PDFs gracefully
/// - Strict memory limits to avoid OOM on large scanned PDFs
class PdfTextExtractor {
  static final Logger _logger = getLogger('PdfTextExtractor');

  /// Max bytes to read for metadata extraction (first 64KB + last 16KB).
  static const int _headReadSize = 64 * 1024;
  static const int _tailReadSize = 16 * 1024;

  /// Max characters of extracted text to keep.
  static const int _maxTextLength = 30000;

  /// Max file size we'll attempt full text extraction on (20MB).
  /// Larger files get metadata only.
  static const int _maxFullReadSize = 20 * 1024 * 1024;

  /// Extract metadata and text content from a PDF file.
  /// Never throws — returns basic metadata on any failure.
  static Future<ResourceMetadata> extract(String filePath) async {
    final fileName = filePath.split('/').last;
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        _logger.warning('PDF file not found: $filePath');
        return _basicMetadata(filePath, fileName);
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        return _basicMetadata(filePath, fileName, extra: {'file_size': 0});
      }

      // Read head and tail for metadata
      final raf = await file.open(mode: FileMode.read);
      try {
        final headSize = fileSize < _headReadSize ? fileSize : _headReadSize;
        final headBytes = await raf.read(headSize);

        Uint8List? tailBytes;
        if (fileSize > _headReadSize + _tailReadSize) {
          await raf.setPosition(fileSize - _tailReadSize);
          tailBytes = await raf.read(_tailReadSize);
        }

        // Extract metadata from head
        final headStr = _safeDecodeBytes(headBytes);
        final title = _extractPdfTitle(headStr) ?? _cleanFileName(fileName);
        final isEncrypted = headStr.contains('/Encrypt');

        // Extract page count from tail (linearized PDFs) or head
        final pageCount = _extractPageCount(headStr, tailBytes);

        // Attempt text extraction only for reasonable-sized, non-encrypted PDFs
        String? textContent;
        if (!isEncrypted && fileSize <= _maxFullReadSize) {
          textContent = await _extractText(file, fileSize);
        }

        return ResourceMetadata(
          type: ResourceType.pdf,
          source: filePath,
          title: title,
          description: _buildDescription(pageCount, fileSize),
          textContent: textContent,
          status: textContent != null && textContent.isNotEmpty
              ? RecognitionStatus.enriched
              : RecognitionStatus.detected,
          extra: {
            'file_name': fileName,
            'file_size': fileSize,
            if (pageCount > 0) 'page_count': pageCount,
            if (isEncrypted) 'encrypted': true,
          },
        );
      } finally {
        await raf.close();
      }
    } catch (e) {
      _logger.warning('Error extracting PDF from $filePath: $e');
      return _basicMetadata(filePath, fileName);
    }
  }

  /// Extract title from PDF Info dictionary in the header region.
  static String? _extractPdfTitle(String headerContent) {
    // Try /Title (literal string)
    final literalMatch =
        RegExp(r'/Title\s*\(([^)]{1,200})\)').firstMatch(headerContent);
    if (literalMatch != null) {
      final raw = literalMatch.group(1)?.trim();
      if (raw != null && raw.isNotEmpty && !_isGarbage(raw)) return raw;
    }

    // Try /Title <hex string>
    final hexMatch =
        RegExp(r'/Title\s*<([0-9A-Fa-f]+)>').firstMatch(headerContent);
    if (hexMatch != null) {
      final decoded = _decodeHexString(hexMatch.group(1)!);
      if (decoded != null && decoded.isNotEmpty && !_isGarbage(decoded)) {
        return decoded;
      }
    }

    return null;
  }

  /// Extract page count. Tries /Count in the Pages dictionary.
  static int _extractPageCount(String headStr, Uint8List? tailBytes) {
    // Look for /Type /Pages ... /Count N
    final countMatch =
        RegExp(r'/Type\s*/Pages[^>]*?/Count\s+(\d+)').firstMatch(headStr);
    if (countMatch != null) {
      return int.tryParse(countMatch.group(1)!) ?? 0;
    }

    // Try reversed order: /Count before /Type
    final countMatch2 =
        RegExp(r'/Count\s+(\d+)[^>]*?/Type\s*/Pages').firstMatch(headStr);
    if (countMatch2 != null) {
      return int.tryParse(countMatch2.group(1)!) ?? 0;
    }

    // Try in tail
    if (tailBytes != null) {
      final tailStr = _safeDecodeBytes(tailBytes);
      final tailMatch =
          RegExp(r'/Type\s*/Pages[^>]*?/Count\s+(\d+)').firstMatch(tailStr);
      if (tailMatch != null) {
        return int.tryParse(tailMatch.group(1)!) ?? 0;
      }
    }

    return 0;
  }

  /// Best-effort text extraction from PDF streams.
  /// Reads the file in chunks to avoid loading everything into memory at once.
  static Future<String?> _extractText(File file, int fileSize) async {
    try {
      // For files under 5MB, read all at once for simplicity
      if (fileSize <= 5 * 1024 * 1024) {
        final bytes = await file.readAsBytes();
        final content = _safeDecodeBytes(bytes);
        return _extractTextFromContent(content);
      }

      // For larger files, read in 2MB chunks and extract from each
      final buffer = StringBuffer();
      final raf = await file.open(mode: FileMode.read);
      try {
        const chunkSize = 2 * 1024 * 1024;
        var offset = 0;
        while (offset < fileSize && buffer.length < _maxTextLength) {
          final readSize =
              (offset + chunkSize > fileSize) ? fileSize - offset : chunkSize;
          await raf.setPosition(offset);
          final chunk = await raf.read(readSize);
          final chunkStr = _safeDecodeBytes(chunk);
          final extracted = _extractTextFromContent(chunkStr);
          if (extracted != null && extracted.isNotEmpty) {
            buffer.write(extracted);
            buffer.write(' ');
          }
          offset += chunkSize;
        }
      } finally {
        await raf.close();
      }

      final result = buffer.toString().trim();
      if (result.isEmpty) return null;
      return result.length > _maxTextLength
          ? result.substring(0, _maxTextLength)
          : result;
    } catch (e) {
      _logger.fine('Text extraction failed for ${file.path}: $e');
      return null;
    }
  }

  /// Extract readable text from a PDF content string.
  static String? _extractTextFromContent(String content) {
    final buffer = StringBuffer();

    // Strategy 1: BT...ET blocks with Tj/TJ operators
    final btEtPattern = RegExp(r'BT\b(.*?)\bET\b', dotAll: true);
    for (final match in btEtPattern.allMatches(content)) {
      final block = match.group(1) ?? '';

      // Tj: show string
      for (final tj
          in RegExp(r'\(([^)]*)\)\s*Tj').allMatches(block)) {
        final text = _decodePdfString(tj.group(1) ?? '');
        if (text.isNotEmpty) {
          buffer.write(text);
          buffer.write(' ');
        }
      }

      // TJ: show array of strings
      for (final tjArray
          in RegExp(r'\[(.*?)\]\s*TJ', dotAll: true).allMatches(block)) {
        final arrayContent = tjArray.group(1) ?? '';
        for (final part
            in RegExp(r'\(([^)]*)\)').allMatches(arrayContent)) {
          final text = _decodePdfString(part.group(1) ?? '');
          if (text.isNotEmpty) buffer.write(text);
        }
        buffer.write(' ');
      }
    }

    final result = buffer
        .toString()
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return result.isEmpty ? null : result;
  }

  /// Decode PDF string escape sequences.
  static String _decodePdfString(String raw) {
    return raw
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\r', '\r')
        .replaceAll(r'\t', '\t')
        .replaceAll(r'\\', '\\')
        .replaceAll(r'\(', '(')
        .replaceAll(r'\)', ')');
  }

  /// Decode a hex-encoded PDF string.
  static String? _decodeHexString(String hex) {
    try {
      if (hex.length % 2 != 0) hex = '${hex}0';
      final bytes = <int>[];
      for (var i = 0; i < hex.length; i += 2) {
        bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
      }
      // Try UTF-16BE first (common in PDF), fall back to Latin-1
      if (bytes.length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF) {
        return _decodeUtf16Be(bytes.sublist(2));
      }
      return latin1.decode(bytes);
    } catch (_) {
      return null;
    }
  }

  static String _decodeUtf16Be(List<int> bytes) {
    final buffer = StringBuffer();
    for (var i = 0; i + 1 < bytes.length; i += 2) {
      buffer.writeCharCode((bytes[i] << 8) | bytes[i + 1]);
    }
    return buffer.toString();
  }

  /// Safely decode bytes to string, handling non-UTF8 content.
  static String _safeDecodeBytes(Uint8List bytes) {
    try {
      return utf8.decode(bytes, allowMalformed: true);
    } catch (_) {
      return latin1.decode(bytes);
    }
  }

  /// Check if extracted text looks like garbage (binary data, etc.)
  static bool _isGarbage(String text) {
    if (text.isEmpty) return true;
    // If more than 30% non-printable characters, it's garbage
    var nonPrintable = 0;
    for (final c in text.codeUnits) {
      if (c < 32 && c != 10 && c != 13 && c != 9) nonPrintable++;
    }
    return nonPrintable / text.length > 0.3;
  }

  static String _cleanFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'\.[^.]+$'), '')
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .trim();
  }

  static String _buildDescription(int pageCount, int fileSize) {
    final parts = <String>[];
    if (pageCount > 0) parts.add('$pageCount pages');
    if (fileSize > 0) {
      if (fileSize >= 1024 * 1024) {
        parts.add('${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB');
      } else {
        parts.add('${(fileSize / 1024).toStringAsFixed(0)} KB');
      }
    }
    return parts.join(' · ');
  }

  static ResourceMetadata _basicMetadata(String filePath, String fileName,
      {Map<String, dynamic>? extra}) {
    return ResourceMetadata(
      type: ResourceType.pdf,
      source: filePath,
      title: _cleanFileName(fileName),
      status: RecognitionStatus.failed,
      extra: extra ?? {},
    );
  }
}
