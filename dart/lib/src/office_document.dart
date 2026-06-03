import 'dart:ffi';
import 'dart:io' show File;
import 'dart:typed_data';

import 'package:office_oxide_ffi/src/bindings.dart';
import 'package:office_oxide_ffi/src/office_format.dart';

/// Read-only Office document (C `OfficeDocumentHandle`).
final class OfficeDocument {
  OfficeDocument._(this._handle);

  final Pointer<Void> _handle;
  var _disposed = false;

  factory OfficeDocument.fromBytes(List<int> bytes, OfficeFormat format) {
    final handle = OfficeOxideBindings.instance.openFromBytes(
      Uint8List.fromList(bytes),
      format,
    );
    return OfficeDocument._(handle);
  }

  factory OfficeDocument.open(String path) {
    final format = OfficeFormat.fromPath(path);
    if (format == null) {
      throw ArgumentError.value(path, 'path', 'unsupported extension');
    }
    return OfficeDocument.fromBytes(File(path).readAsBytesSync(), format);
  }

  static String libraryVersion() => OfficeOxideBindings.instance.version;

  String get formatName {
    _checkNotDisposed();
    return OfficeOxideBindings.instance.documentFormat(_handle);
  }

  String plainText() {
    _checkNotDisposed();
    return OfficeOxideBindings.instance.documentPlainText(_handle);
  }

  String toMarkdown() {
    _checkNotDisposed();
    return OfficeOxideBindings.instance.documentToMarkdown(_handle);
  }

  String toHtml() {
    _checkNotDisposed();
    return OfficeOxideBindings.instance.documentToHtml(_handle);
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    OfficeOxideBindings.instance.documentFree(_handle);
  }

  void _checkNotDisposed() {
    if (_disposed) {
      throw StateError('OfficeDocument has been disposed');
    }
  }
}
