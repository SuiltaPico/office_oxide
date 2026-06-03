/// Office file format passed to the C FFI (`docx`, `xlsx`, …).
enum OfficeFormat {
  docx('docx'),
  xlsx('xlsx'),
  pptx('pptx'),
  doc('doc'),
  xls('xls'),
  ppt('ppt');

  const OfficeFormat(this.extension);

  final String extension;

  /// Infers format from a file path extension; returns null if unknown.
  static OfficeFormat? fromPath(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) return null;
    final ext = path.substring(dot + 1).toLowerCase();
    for (final format in OfficeFormat.values) {
      if (format.extension == ext) return format;
    }
    return null;
  }
}
