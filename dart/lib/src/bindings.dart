import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:office_oxide_ffi/src/native_library.dart';
import 'package:office_oxide_ffi/src/office_format.dart';
import 'package:office_oxide_ffi/src/office_oxide_exception.dart';

final class OfficeOxideBindings {
  OfficeOxideBindings._(this._lib) {
    _version = _lib
        .lookupFunction<_VersionNative, _Version>('office_oxide_version');
    _freeString = _lib.lookupFunction<_FreeStringNative, _FreeString>(
      'office_oxide_free_string',
    );
    _documentOpenFromBytes = _lib.lookupFunction<
        _DocumentOpenFromBytesNative, _DocumentOpenFromBytes>(
      'office_document_open_from_bytes',
    );
    _documentFree =
        _lib.lookupFunction<_DocumentFreeNative, _DocumentFree>(
      'office_document_free',
    );
    _documentFormat = _lib.lookupFunction<_DocumentFormatNative, _DocumentFormat>(
      'office_document_format',
    );
    _documentPlainText = _lib.lookupFunction<
        _DocumentPlainTextNative, _DocumentPlainText>(
      'office_document_plain_text',
    );
    _documentToMarkdown = _lib.lookupFunction<
        _DocumentToMarkdownNative, _DocumentToMarkdown>(
      'office_document_to_markdown',
    );
    _documentToHtml = _lib.lookupFunction<_DocumentToHtmlNative, _DocumentToHtml>(
      'office_document_to_html',
    );
  }

  static final OfficeOxideBindings instance =
      OfficeOxideBindings._(openOfficeOxideLibrary());

  final DynamicLibrary _lib;

  late final _Version _version;
  late final _FreeString _freeString;
  late final _DocumentOpenFromBytes _documentOpenFromBytes;
  late final _DocumentFree _documentFree;
  late final _DocumentFormat _documentFormat;
  late final _DocumentPlainText _documentPlainText;
  late final _DocumentToMarkdown _documentToMarkdown;
  late final _DocumentToHtml _documentToHtml;

  String get version => _version().cast<Utf8>().toDartString();

  Pointer<Void> openFromBytes(Uint8List bytes, OfficeFormat format) {
    final data = calloc<Uint8>(bytes.length);
    final err = calloc<Int32>();
    final formatPtr = format.extension.toNativeUtf8();
    try {
      data.asTypedList(bytes.length).setAll(0, bytes);
      final handle = _documentOpenFromBytes(
        data,
        bytes.length,
        formatPtr,
        err,
      );
      final code = err.value;
      if (handle == nullptr || code != 0) {
        throw OfficeOxideException('openFromBytes', code);
      }
      return handle;
    } finally {
      calloc.free(data);
      calloc.free(err);
      malloc.free(formatPtr);
    }
  }

  void documentFree(Pointer<Void> handle) => _documentFree(handle);

  String documentFormat(Pointer<Void> handle) =>
      _documentFormat(handle).cast<Utf8>().toDartString();

  String documentPlainText(Pointer<Void> handle) =>
      _extractString(handle, _documentPlainText, 'plainText');

  String documentToMarkdown(Pointer<Void> handle) =>
      _extractString(handle, _documentToMarkdown, 'toMarkdown');

  String documentToHtml(Pointer<Void> handle) =>
      _extractString(handle, _documentToHtml, 'toHtml');

  String _extractString(
    Pointer<Void> handle,
    Pointer<Utf8> Function(Pointer<Void>, Pointer<Int32>) native,
    String operation,
  ) {
    final err = calloc<Int32>();
    try {
      final ptr = native(handle, err);
      if (ptr == nullptr) {
        throw OfficeOxideException(operation, err.value);
      }
      try {
        return ptr.toDartString();
      } finally {
        _freeString(ptr.cast<Char>());
      }
    } finally {
      calloc.free(err);
    }
  }
}

typedef _VersionNative = Pointer<Utf8> Function();
typedef _Version = Pointer<Utf8> Function();

typedef _FreeStringNative = Void Function(Pointer<Char>);
typedef _FreeString = void Function(Pointer<Char>);

typedef _DocumentOpenFromBytesNative = Pointer<Void> Function(
  Pointer<Uint8> data,
  IntPtr len,
  Pointer<Utf8> format,
  Pointer<Int32> errorCode,
);
typedef _DocumentOpenFromBytes = Pointer<Void> Function(
  Pointer<Uint8> data,
  int len,
  Pointer<Utf8> format,
  Pointer<Int32> errorCode,
);

typedef _DocumentFreeNative = Void Function(Pointer<Void> handle);
typedef _DocumentFree = void Function(Pointer<Void> handle);

typedef _DocumentFormatNative = Pointer<Utf8> Function(Pointer<Void> handle);
typedef _DocumentFormat = Pointer<Utf8> Function(Pointer<Void> handle);

typedef _DocumentPlainTextNative = Pointer<Utf8> Function(
  Pointer<Void> handle,
  Pointer<Int32> errorCode,
);
typedef _DocumentPlainText = Pointer<Utf8> Function(
  Pointer<Void> handle,
  Pointer<Int32> errorCode,
);

typedef _DocumentToMarkdownNative = Pointer<Utf8> Function(
  Pointer<Void> handle,
  Pointer<Int32> errorCode,
);
typedef _DocumentToMarkdown = Pointer<Utf8> Function(
  Pointer<Void> handle,
  Pointer<Int32> errorCode,
);

typedef _DocumentToHtmlNative = Pointer<Utf8> Function(
  Pointer<Void> handle,
  Pointer<Int32> errorCode,
);
typedef _DocumentToHtml = Pointer<Utf8> Function(
  Pointer<Void> handle,
  Pointer<Int32> errorCode,
);
