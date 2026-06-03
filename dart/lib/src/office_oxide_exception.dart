/// office_oxide C FFI error codes (`office_oxide.h`).
enum OfficeOxideErrorCode {
  ok(0),
  invalidArg(1),
  io(2),
  parse(3),
  extraction(4),
  internal(5),
  unsupported(6);

  const OfficeOxideErrorCode(this.code);

  final int code;

  static OfficeOxideErrorCode? fromCode(int code) {
    for (final value in OfficeOxideErrorCode.values) {
      if (value.code == code) return value;
    }
    return null;
  }

  String get message => switch (this) {
        OfficeOxideErrorCode.ok => 'ok',
        OfficeOxideErrorCode.invalidArg => 'invalid argument',
        OfficeOxideErrorCode.io => 'I/O error',
        OfficeOxideErrorCode.parse => 'parse error',
        OfficeOxideErrorCode.extraction => 'extraction failed',
        OfficeOxideErrorCode.internal => 'internal error',
        OfficeOxideErrorCode.unsupported => 'unsupported format',
      };
}

/// Thrown when an FFI call returns a non-zero error code.
final class OfficeOxideException implements Exception {
  OfficeOxideException(this.operation, this.errorCode)
      : code = OfficeOxideErrorCode.fromCode(errorCode);

  final String operation;
  final int errorCode;
  final OfficeOxideErrorCode? code;

  @override
  String toString() {
    final kind = code?.message ?? 'code=$errorCode';
    return 'OfficeOxideException($operation: $kind)';
  }
}
