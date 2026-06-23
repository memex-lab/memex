import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/document_text_extraction_service.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('memex_doc_extract_');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test('extracts readable text from docx document xml', () async {
    final archive = Archive()
      ..addFile(_archiveFile(
        'word/document.xml',
        '<w:document><w:body>'
            '<w:p><w:r><w:t>Hello &amp; welcome</w:t></w:r></w:p>'
            '<w:p><w:r><w:t>Second paragraph</w:t></w:r></w:p>'
            '</w:body></w:document>',
      ));
    final docxPath = p.join(tempDir.path, 'notes.docx');
    await File(docxPath).writeAsBytes(ZipEncoder().encode(archive));

    final extracted =
        await DocumentTextExtractionService.instance.extractForAgent(
      File(docxPath),
    );

    expect(
        extracted, contains('Text extracted from original file: notes.docx'));
    expect(extracted, contains('Hello & welcome'));
    expect(extracted, contains('Second paragraph'));
  });

  test('extracts workbook sheets from xlsx files as markdown tables', () async {
    final archive = Archive()
      ..addFile(_archiveFile(
        'xl/workbook.xml',
        '''
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <sheets>
    <sheet name="Budget" sheetId="1" r:id="rId1"/>
  </sheets>
</workbook>
''',
      ))
      ..addFile(_archiveFile(
        'xl/_rels/workbook.xml.rels',
        '''
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1"
      Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet"
      Target="worksheets/sheet1.xml"/>
</Relationships>
''',
      ))
      ..addFile(_archiveFile(
        'xl/sharedStrings.xml',
        '''
<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <si><t>Name</t></si>
  <si><t>Coffee</t></si>
  <si><r><t>Rich</t></r><r><t> text</t></r></si>
</sst>
''',
      ))
      ..addFile(_archiveFile(
        'xl/worksheets/sheet1.xml',
        '''
<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <sheetData>
    <row r="1">
      <c r="A1" t="s"><v>0</v></c>
      <c r="B1"><v>12.5</v></c>
      <c r="C1" t="inlineStr"><is><t>Inline value</t></is></c>
    </row>
    <row r="3">
      <c r="A3" t="s"><v>1</v></c>
      <c r="B3" t="s"><v>2</v></c>
      <c r="C3" t="b"><v>1</v></c>
    </row>
  </sheetData>
</worksheet>
''',
      ));

    final xlsxPath = p.join(tempDir.path, 'budget.xlsx');
    await File(xlsxPath).writeAsBytes(ZipEncoder().encode(archive));

    final extracted =
        await DocumentTextExtractionService.instance.extractForAgent(
      File(xlsxPath),
    );

    expect(
      extracted,
      contains('Text extracted from original file: budget.xlsx'),
    );
    expect(extracted, contains('## Sheet: Budget'));
    expect(extracted, contains('| A | B | C |'));
    expect(extracted, contains('| Name | 12.5 | Inline value |'));
    expect(extracted, contains('| Coffee | Rich text | TRUE |'));
  });

  test('extracts simple embedded text from text-based pdf streams', () async {
    const pdf = '''
%PDF-1.4
1 0 obj
<< /Length 44 >>
stream
BT
/F1 12 Tf
72 720 Td
(Hello from PDF) Tj
ET
endstream
endobj
%%EOF
''';
    final pdfPath = p.join(tempDir.path, 'report.pdf');
    await File(pdfPath).writeAsBytes(latin1.encode(pdf));

    final extracted =
        await DocumentTextExtractionService.instance.extractForAgent(
      File(pdfPath),
    );

    expect(
        extracted, contains('Text extracted from original file: report.pdf'));
    expect(extracted, contains('Hello from PDF'));
  });

  test('creates a clear note for legacy doc files', () async {
    final docPath = p.join(tempDir.path, 'legacy.doc');
    await File(docPath).writeAsString('not really a doc');

    final extracted =
        await DocumentTextExtractionService.instance.extractForAgent(
      File(docPath),
    );

    expect(extracted, contains('legacy .doc Word file'));
    expect(extracted, contains('legacy.doc'));
  });

  test('creates a clear note for legacy xls files', () async {
    final xlsPath = p.join(tempDir.path, 'legacy.xls');
    await File(xlsPath).writeAsString('not really an xls');

    final extracted =
        await DocumentTextExtractionService.instance.extractForAgent(
      File(xlsPath),
    );

    expect(extracted, contains('legacy .xls Excel file'));
    expect(extracted, contains('legacy.xls'));
  });
}

ArchiveFile _archiveFile(String name, String content) {
  final bytes = utf8.encode(content);
  return ArchiveFile(name, bytes.length, bytes);
}
