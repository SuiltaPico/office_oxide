import 'dart:io';

import 'package:office_oxide_ffi/office_oxide_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final fixture = p.join('test', 'fixtures', 'smoke.docx');

  test('native library loads', () {
    final override = Platform.environment[officeOxideLibEnv];
    final libPath = resolveNativeLibraryPath();
    if (!Platform.isAndroid &&
        (override == null || override.isEmpty)) {
      // With build hooks the library may be bundled without a file on disk.
      final onDisk = File(libPath).existsSync();
      if (!onDisk) {
        expect(
          OfficeDocument.libraryVersion(),
          startsWith('0.1.'),
          reason: 'bundled native asset (no file at $libPath)',
        );
        return;
      }
      expect(onDisk, isTrue, reason: 'missing: $libPath');
    }
    expect(OfficeDocument.libraryVersion(), startsWith('0.1.'));
  });

  test('native library path is anchored to package root', () {
    if (Platform.isAndroid) return;

    final libPath = resolveNativeLibraryPath();
    final packageRoot = p.normalize(
      p.join(p.dirname(libPath), '..', '..', '..', '..'),
    );
    final pubspec = File(p.join(packageRoot, 'pubspec.yaml'));
    expect(pubspec.existsSync(), isTrue, reason: 'package root: $packageRoot');
    expect(
      pubspec.readAsStringSync(),
      contains('name: office_oxide_ffi'),
    );
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
