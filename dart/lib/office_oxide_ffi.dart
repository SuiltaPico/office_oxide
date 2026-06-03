/// Dart/Flutter FFI bindings for [office_oxide](https://github.com/yfedoseev/office_oxide).
///
/// Unofficial binding; not affiliated with Office Oxide or Oxide (oxide.fyi).
library;

export 'src/office_document.dart';
export 'src/office_format.dart';
export 'src/office_oxide_exception.dart';
export 'src/native_library.dart'
    show officeOxideLibEnv, resolveNativeLibraryPath;
