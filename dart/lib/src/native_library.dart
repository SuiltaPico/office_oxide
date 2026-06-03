import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'package:path/path.dart' as p;

/// Environment variable for an explicit native library path (CI / local dev).
const String officeOxideLibEnv = 'OFFICE_OXIDE_LIB';

/// Bundled native asset id (see `hook/build.dart`).
const String _nativeAssetId = 'package:office_oxide_ffi/src/native_library.dart';

/// Opens the office_oxide dynamic library for the current platform.
///
/// Resolution order:
/// 1. [officeOxideLibEnv] (absolute path to `.so` / `.dylib` / `.dll`)
/// 2. Flutter Android: `liboffice_oxide.so` from jniLibs / hook asset
/// 3. Hook [CodeAsset] bundled via [_officeOxideVersionSymbol] + [DynamicLibrary.process]
/// 4. Manual `dart run tool/install.dart` layout under `native/`
DynamicLibrary openOfficeOxideLibrary() {
  final override = Platform.environment[officeOxideLibEnv];
  if (override != null && override.isNotEmpty) {
    return DynamicLibrary.open(override);
  }

  if (Platform.isAndroid) {
    return DynamicLibrary.open('liboffice_oxide.so');
  }

  if (_tryOpenBundledLibrary() case final lib?) {
    return lib;
  }

  final path = resolveNativeLibraryPath();
  if (!File(path).existsSync()) {
    throw StateError(
      'office_oxide native library not found at:\n  $path\n'
      'Run `dart pub get` (build hook downloads Release assets), '
      '`dart run tool/install.dart`, or set $officeOxideLibEnv — see dart/README.md.',
    );
  }
  return DynamicLibrary.open(path);
}

DynamicLibrary? _tryOpenBundledLibrary() {
  try {
    _officeOxideVersionSymbol();
    final lib = DynamicLibrary.process();
    if (lib.providesSymbol('office_oxide_version')) {
      return lib;
    }
  } on Object {
    // No bundled asset for this target (e.g. hook skipped or unsupported OS).
  }
  return null;
}

/// Loads the hook-bundled library (no-op if not linked).
@Native<Pointer<Utf8> Function()>(
  assetId: _nativeAssetId,
  symbol: 'office_oxide_version',
  isLeaf: true,
)
external Pointer<Utf8> _officeOxideVersionSymbol();

/// Absolute path to the bundled native library (desktop / VM only).
///
/// On Android returns the load name `liboffice_oxide.so` (loaded from APK jniLibs).
/// When using build hooks, the library may exist only in the native asset bundle
/// (no file at this path).
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
  final fromConfig = _packageRootFromPackageConfig();
  if (fromConfig != null) {
    return fromConfig;
  }

  final fromCwd = _packageRootFromCwdPubspec();
  if (fromCwd != null) {
    return fromCwd;
  }

  throw StateError(
    'office_oxide_ffi: cannot locate package root; run from a project with '
    'office_oxide_ffi in pubspec, or set $officeOxideLibEnv',
  );
}

/// Resolves via `.dart_tool/package_config.json` (path/git/pub deps).
String? _packageRootFromPackageConfig() {
  final explicit = Platform.packageConfig;
  if (explicit != null) {
    final root = _officeOxideRootFromConfig(File(explicit));
    if (root != null) {
      return root;
    }
  }

  var dir = Directory.current;
  while (true) {
    final configFile = File(p.join(dir.path, '.dart_tool', 'package_config.json'));
    if (configFile.existsSync()) {
      final root = _officeOxideRootFromConfig(configFile);
      if (root != null) {
        return root;
      }
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      break;
    }
    dir = parent;
  }
  return null;
}

String? _officeOxideRootFromConfig(File configFile) {
  try {
    final json =
        jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;
    final packages = json['packages'] as List<dynamic>?;
    if (packages == null) {
      return null;
    }
    for (final pkg in packages) {
      final map = pkg as Map<String, dynamic>;
      if (map['name'] != 'office_oxide_ffi') {
        continue;
      }
      final rootUri = map['rootUri'] as String;
      final configDir = p.dirname(configFile.path);
      final root = rootUri.startsWith('file:')
          ? p.fromUri(Uri.parse(rootUri))
          : p.normalize(p.join(configDir, rootUri));
      if (_isPackageRoot(root)) {
        return root;
      }
    }
  } on Object {
    return null;
  }
  return null;
}

/// Fallback when cwd is the package directory (e.g. `dart test` from `dart/`).
String? _packageRootFromCwdPubspec() {
  var dir = Directory.current;
  while (true) {
    if (_isPackageRoot(dir.path)) {
      return dir.path;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      break;
    }
    dir = parent;
  }
  return null;
}

bool _isPackageRoot(String dir) {
  final pubspec = File(p.join(dir, 'pubspec.yaml'));
  if (!pubspec.existsSync()) {
    return false;
  }
  return pubspec.readAsStringSync().contains('name: office_oxide_ffi');
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
