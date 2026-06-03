// Extract plain text and Markdown from a file path.
//
//   dart pub get
//   dart run examples/extract.dart path/to/file.docx

import 'dart:io';

import 'package:office_oxide_ffi/office_oxide_ffi.dart';

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('usage: dart run examples/extract.dart <file>');
    exit(1);
  }

  print('office_oxide ${OfficeDocument.libraryVersion()}');

  final doc = OfficeDocument.open(args[0]);
  try {
    print('format: ${doc.formatName}');
    print('--- plain text ---');
    print(doc.plainText());
    print('--- markdown ---');
    print(doc.toMarkdown());
  } finally {
    doc.dispose();
  }
}
