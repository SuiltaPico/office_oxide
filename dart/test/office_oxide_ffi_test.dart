import 'dart:io';

import 'package:office_oxide_ffi/office_oxide_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final fixture = p.join('test', 'fixtures', 'smoke.docx');

  test('native library loads', () {
    final libPath = resolveNativeLibraryPath();
    if (!Platform.isAndroid) {
      expect(File(libPath).existsSync(), isTrue, reason: 'missing: $libPath');
    }
    expect(OfficeDocument.libraryVersion(), startsWith('0.1.'));
  });

  test('fromBytes extracts text and markdown', () {
    final bytes = File(fixture).readAsBytesSync();
    final doc = OfficeDocument.fromBytes(bytes, OfficeFormat.docx);
    addTearDown(doc.dispose);

    expect(doc.formatName, 'docx');
    expect(doc.plainText(), contains('Hello FFI'));
    expect(doc.toMarkdown(), contains('Hello FFI'));
  });

  test('open from path', () {
    final doc = OfficeDocument.open(fixture);
    addTearDown(doc.dispose);
    expect(doc.plainText(), isNotEmpty);
  });
}
