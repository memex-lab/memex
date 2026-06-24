import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:memex/utils/logger.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

class DocumentTextExtractionService {
  DocumentTextExtractionService._();

  static final DocumentTextExtractionService instance =
      DocumentTextExtractionService._();

  final _logger = getLogger('DocumentTextExtractionService');

  Future<String?> extractForAgent(File file) async {
    final extension = p.extension(file.path).toLowerCase();
    try {
      final body = switch (extension) {
        '.docx' => await _extractDocxText(file),
        '.xlsx' => await _extractXlsxText(file),
        '.pdf' => _unsupportedExtractionMessage(),
        '.doc' => _legacyDocMessage(),
        '.xls' => _legacyXlsMessage(),
        _ => null,
      };
      if (body == null) return null;
      return _wrapExtractedText(
        originalFileName: p.basename(file.path),
        body: body,
      );
    } catch (e, st) {
      _logger.warning('Failed to extract text from ${file.path}', e, st);
      return _wrapExtractedText(
        originalFileName: p.basename(file.path),
        body: _failedExtractionMessage(),
      );
    }
  }

  Future<String> _extractDocxText(File file) async {
    final archive = ZipDecoder().decodeBytes(await file.readAsBytes());
    final sections = <String>[];
    for (final entry in archive.files) {
      final name = entry.name;
      final isDocument = name == 'word/document.xml';
      final isHeaderOrFooter =
          RegExp(r'^word/(header|footer)\d+\.xml$').hasMatch(name);
      if (!entry.isFile || (!isDocument && !isHeaderOrFooter)) continue;

      final bytes = entry.readBytes();
      if (bytes == null || bytes.isEmpty) continue;
      final text = _wordXmlToText(utf8.decode(bytes, allowMalformed: true));
      if (text.trim().isNotEmpty) sections.add(text.trim());
    }

    if (sections.isEmpty) {
      return 'No readable DOCX text was found. The document may be empty, '
          'encrypted, or contain only embedded images.';
    }
    return sections.join('\n\n');
  }

  Future<String> _extractXlsxText(File file) async {
    final archive = ZipDecoder().decodeBytes(await file.readAsBytes());
    final entries = {
      for (final entry in archive.files)
        if (entry.isFile) entry.name: entry,
    };
    final sharedStrings = _readXlsxSharedStrings(entries);
    final sheets = _readXlsxSheetReferences(entries);
    final sections = <String>[];

    for (final sheet in sheets) {
      final xml = _archiveEntryText(entries[sheet.path]);
      if (xml == null || xml.trim().isEmpty) continue;

      final markdown = _xlsxWorksheetToMarkdown(xml, sharedStrings);
      if (markdown.trim().isEmpty) continue;
      sections.add('## Sheet: ${sheet.name}\n\n$markdown');
    }

    if (sections.isEmpty) {
      return 'No readable XLSX cell text was found. The workbook may be '
          'empty, encrypted, or contain only charts, images, or unsupported '
          'embedded objects.';
    }
    return sections.join('\n\n');
  }

  List<String> _readXlsxSharedStrings(Map<String, ArchiveFile> entries) {
    final xml = _archiveEntryText(entries['xl/sharedStrings.xml']);
    if (xml == null || xml.trim().isEmpty) return const [];

    final document = XmlDocument.parse(xml);
    return document
        .findAllElements('si', namespace: '*')
        .map(_xlsxTextRuns)
        .toList();
  }

  List<_XlsxSheetReference> _readXlsxSheetReferences(
    Map<String, ArchiveFile> entries,
  ) {
    final workbookXml = _archiveEntryText(entries['xl/workbook.xml']);
    if (workbookXml == null || workbookXml.trim().isEmpty) {
      return _fallbackXlsxSheetReferences(entries);
    }

    final rels = _readXlsxWorkbookRelationships(entries);
    final workbook = XmlDocument.parse(workbookXml);
    final sheets = <_XlsxSheetReference>[];
    var fallbackIndex = 1;

    for (final sheet in workbook.findAllElements('sheet', namespace: '*')) {
      final name = sheet.getAttribute('name', namespace: '*')?.trim();
      final relationshipId = sheet.getAttribute('id', namespace: '*');
      final path = relationshipId == null ? null : rels[relationshipId];
      if (path == null || !entries.containsKey(path)) continue;

      sheets.add(
        _XlsxSheetReference(
          name: name == null || name.isEmpty ? 'Sheet $fallbackIndex' : name,
          path: path,
        ),
      );
      fallbackIndex += 1;
    }

    return sheets.isEmpty ? _fallbackXlsxSheetReferences(entries) : sheets;
  }

  Map<String, String> _readXlsxWorkbookRelationships(
    Map<String, ArchiveFile> entries,
  ) {
    final relsXml = _archiveEntryText(entries['xl/_rels/workbook.xml.rels']);
    if (relsXml == null || relsXml.trim().isEmpty) return const {};

    final document = XmlDocument.parse(relsXml);
    final relationships = <String, String>{};
    for (final relationship
        in document.findAllElements('Relationship', namespace: '*')) {
      final id = relationship.getAttribute('Id', namespace: '*');
      final target = relationship.getAttribute('Target', namespace: '*');
      if (id == null || target == null || target.trim().isEmpty) continue;
      relationships[id] = _xlsxWorkbookTargetToEntryPath(target);
    }
    return relationships;
  }

  String _xlsxWorkbookTargetToEntryPath(String target) {
    final normalized = target.startsWith('/')
        ? p.posix.normalize(target.substring(1))
        : p.posix.normalize(p.posix.join('xl', target));
    return normalized;
  }

  List<_XlsxSheetReference> _fallbackXlsxSheetReferences(
    Map<String, ArchiveFile> entries,
  ) {
    final paths = entries.keys
        .where((path) => RegExp(r'^xl/worksheets/[^/]+\.xml$').hasMatch(path))
        .toList()
      ..sort();

    return [
      for (var i = 0; i < paths.length; i += 1)
        _XlsxSheetReference(
          name: 'Sheet ${i + 1}',
          path: paths[i],
        ),
    ];
  }

  String _xlsxWorksheetToMarkdown(
    String xml,
    List<String> sharedStrings,
  ) {
    final document = XmlDocument.parse(xml);
    final rows = <List<String>>[];
    var maxColumn = -1;

    for (final rowElement in document.findAllElements('row', namespace: '*')) {
      final rowValues = <int, String>{};
      for (final cell in rowElement.findElements('c', namespace: '*')) {
        final value = _xlsxCellValue(cell, sharedStrings).trim();
        if (value.isEmpty) continue;

        final columnIndex =
            _xlsxColumnIndex(cell.getAttribute('r', namespace: '*')) ??
                rowValues.length;
        rowValues[columnIndex] = _normalizeExtractedText(value);
        if (columnIndex > maxColumn) maxColumn = columnIndex;
      }

      if (rowValues.isEmpty) continue;
      final rowMaxColumn = rowValues.keys.reduce((a, b) => a > b ? a : b);
      final row = List<String>.filled(rowMaxColumn + 1, '');
      for (final entry in rowValues.entries) {
        row[entry.key] = entry.value;
      }
      rows.add(row);
    }

    if (rows.isEmpty || maxColumn < 0) return '';

    final columnCount = maxColumn + 1;
    final lines = <String>[];
    lines.add(
      '| ${List.generate(columnCount, _xlsxColumnLabel).join(' | ')} |',
    );
    lines.add('| ${List.filled(columnCount, '---').join(' | ')} |');
    for (final row in rows) {
      lines.add(
        '| ${List.generate(
          columnCount,
          (index) => _escapeMarkdownTableCell(
            index < row.length ? row[index] : '',
          ),
        ).join(' | ')} |',
      );
    }
    return lines.join('\n');
  }

  String _xlsxCellValue(XmlElement cell, List<String> sharedStrings) {
    final type = cell.getAttribute('t', namespace: '*');
    if (type == 'inlineStr') {
      final inlineString = _firstXmlElement(
        cell.findElements('is', namespace: '*'),
      );
      return inlineString == null ? '' : _xlsxTextRuns(inlineString);
    }

    final value =
        _firstXmlElement(cell.findElements('v', namespace: '*'))?.innerText;
    if (value == null) return '';

    return switch (type) {
      's' => _xlsxSharedStringValue(value, sharedStrings),
      'b' => value == '1' ? 'TRUE' : 'FALSE',
      _ => value,
    };
  }

  String _xlsxSharedStringValue(String value, List<String> sharedStrings) {
    final index = int.tryParse(value.trim());
    if (index == null || index < 0 || index >= sharedStrings.length) {
      return value;
    }
    return sharedStrings[index];
  }

  String _xlsxTextRuns(XmlElement element) {
    final textRuns = element.findAllElements('t', namespace: '*').toList();
    if (textRuns.isEmpty) return element.innerText;
    return textRuns.map((run) => run.innerText).join();
  }

  int? _xlsxColumnIndex(String? cellReference) {
    if (cellReference == null) return null;
    final match = RegExp(r'^[A-Za-z]+').firstMatch(cellReference);
    final letters = match?.group(0);
    if (letters == null || letters.isEmpty) return null;

    var index = 0;
    for (final codeUnit in letters.toUpperCase().codeUnits) {
      index = index * 26 + (codeUnit - 0x41 + 1);
    }
    return index - 1;
  }

  String _xlsxColumnLabel(int zeroBasedIndex) {
    var value = zeroBasedIndex + 1;
    final chars = <int>[];
    while (value > 0) {
      value -= 1;
      chars.insert(0, 0x41 + value % 26);
      value ~/= 26;
    }
    return String.fromCharCodes(chars);
  }

  String _escapeMarkdownTableCell(String value) {
    return value
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll('\n', '<br>')
        .replaceAll('|', r'\|');
  }

  String? _archiveEntryText(ArchiveFile? entry) {
    if (entry == null) return null;
    final bytes = entry.readBytes();
    if (bytes == null || bytes.isEmpty) return null;
    return utf8.decode(bytes, allowMalformed: true);
  }

  XmlElement? _firstXmlElement(Iterable<XmlElement> elements) {
    for (final element in elements) {
      return element;
    }
    return null;
  }

  String _wordXmlToText(String xml) {
    try {
      final document = XmlDocument.parse(xml);
      final paragraphs = <String>[];
      for (final paragraph in document.findAllElements('p', namespace: '*')) {
        final buffer = StringBuffer();
        for (final node in paragraph.descendants.whereType<XmlElement>()) {
          switch (node.localName) {
            case 't':
            case 'instrText':
              buffer.write(node.innerText);
            case 'tab':
              buffer.write('\t');
            case 'br':
            case 'cr':
              buffer.write('\n');
          }
        }
        final text = _normalizeExtractedText(buffer.toString());
        if (text.isNotEmpty) paragraphs.add(text);
      }
      return paragraphs.join('\n\n');
    } catch (_) {
      var text = xml
          .replaceAll(RegExp(r'<w:tab\s*/>'), '\t')
          .replaceAll(RegExp(r'<w:(br|cr)[^>]*/>'), '\n')
          .replaceAll(RegExp(r'</w:tc>'), '\t')
          .replaceAll(RegExp(r'</w:tr>'), '\n')
          .replaceAll(RegExp(r'</w:p>'), '\n\n');

      text = text.replaceAll(RegExp(r'<[^>]+>'), '');
      text = _decodeXmlEntities(text);
      return _normalizeExtractedText(text);
    }
  }

  String _legacyDocMessage() {
    return _unsupportedExtractionMessage();
  }

  String _legacyXlsMessage() {
    return _unsupportedExtractionMessage();
  }

  String _unsupportedExtractionMessage() {
    return 'Memex could not parse readable text content from this document.';
  }

  String _failedExtractionMessage() {
    return 'Memex tried to parse readable text content from this document, '
        'but parsing failed.';
  }

  String _wrapExtractedText({
    required String originalFileName,
    required String body,
  }) {
    return '''
# Text extracted from original file: $originalFileName

$body
''';
  }

  String _decodeXmlEntities(String value) {
    return value.replaceAllMapped(
      RegExp(r'&(#x[0-9A-Fa-f]+|#\d+|amp|lt|gt|quot|apos);'),
      (match) {
        final entity = match.group(1)!;
        if (entity == 'amp') return '&';
        if (entity == 'lt') return '<';
        if (entity == 'gt') return '>';
        if (entity == 'quot') return '"';
        if (entity == 'apos') return "'";
        if (entity.startsWith('#x')) {
          return String.fromCharCode(int.parse(entity.substring(2), radix: 16));
        }
        if (entity.startsWith('#')) {
          return String.fromCharCode(int.parse(entity.substring(1)));
        }
        return match.group(0)!;
      },
    );
  }

  static String _normalizeExtractedText(String value) {
    return value
        .replaceAll(RegExp(r'[ \t]+\n'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}

class _XlsxSheetReference {
  const _XlsxSheetReference({
    required this.name,
    required this.path,
  });

  final String name;
  final String path;
}
