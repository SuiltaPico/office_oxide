// Self-contained smoke test (uses test/fixtures/smoke.docx).
//
//   dart pub get
//   dart run example/01_extract.dart

import 'dart:io';

import 'package:office_oxide_ffi/office_oxide_ffi.dart';
import 'package:path/path.dart' as p;

void main() {
  final fixture = p.join('test', 'fixtures', 'smoke.docx');
  final bytes = File(fixture).readAsBytesSync();

  final doc = OfficeDocument.fromBytes(bytes, OfficeFormat.docx);
  try {
    assert(doc.formatName == 'docx');
    final text = doc.plainText();
    assert(text.contains('Hello FFI'), text);
    assert(doc.toMarkdown().contains('Hello FFI'));
    print('01_extract OK');
  } finally {
    doc.dispose();
  }
}
