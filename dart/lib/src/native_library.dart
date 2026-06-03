import 'dart:ffi';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Environment variable for an explicit native library path (CI / local dev).
const String officeOxideLibEnv = 'OFFICE_OXIDE_LIB';

/// Opens the office_oxide dynamic library for the current platform.
///
/// Override with environment variable [officeOxideLibEnv] (absolute path to
/// `.so` / `.dylib` / `.dll`), same as the Node.js `OFFICE_OXIDE_LIB` convention.
DynamicLibrary openOfficeOxideLibrary() {
  final override = Platform.environment[officeOxideLibEnv];
  if (override != null && override.isNotEmpty) {
    return DynamicLibrary.open(override);
  }

  if (Platform.isAndroid) {
    return DynamicLibrary.open('liboffice_oxide.so');
  }

  final path = resolveNativeLibraryPath();
  if (!File(path).existsSync()) {
    throw StateError(
      'office_oxide native library not found at:\n  $path\n'
      'dart run tool/install.dart (desktop) or '
      'dart run tool/install.dart --platform android — see dart/README.md.',
    );
  }
  return DynamicLibrary.open(path);
}

/// Absolute path to the bundled native library (desktop / VM only).
///
/// On Android returns the load name `liboffice_oxide.so` (loaded from APK jniLibs).
String resolveNativeLibraryPath() {
  if (Platform.isAndroid) {
    return 'liboffice_oxide.so';
  }

  final packageRoot = _packageRoot();
  if (Platform.isWindows) {
    return p.join(
      packageRoot,
      'native',
      'windows',
      _windowsArch(),
      'lib',
      'office_oxide.dll',
    );
  }
  if (Platform.isLinux) {
    return p.join(
      packageRoot,
      'native',
      'linux',
      _linuxArch(),
      'lib',
      'liboffice_oxide.so',
    );
  }
  if (Platform.isMacOS) {
    return p.join(
      packageRoot,
      'native',
      'macos',
      _macosArch(),
      'lib',
      'liboffice_oxide.dylib',
    );
  }
  throw UnsupportedError(
    'office_oxide_ffi: unsupported platform ${Platform.operatingSystem}',
  );
}

String _packageRoot() {
  var dir = Directory.current;
  while (true) {
    final pubspec = File(p.join(dir.path, 'pubspec.yaml'));
    if (pubspec.existsSync()) {
      final text = pubspec.readAsStringSync();
      if (text.contains('name: office_oxide_ffi')) {
        return dir.path;
      }
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  throw StateError(
    'office_oxide_ffi: cannot locate package root (pubspec.yaml)',
  );
}

String _windowsArch() =>
    Platform.version.contains('arm64') ? 'arm64' : 'x64';

String _linuxArch() {
  if (Platform.version.contains('arm64') ||
      Platform.version.contains('aarch64')) {
    return 'arm64';
  }
  return 'x64';
}

String _macosArch() =>
    Platform.version.contains('arm64') ? 'arm64' : 'x64';
