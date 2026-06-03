// Manual fallback: download GitHub Release `native-*` into this package tree.
//
// Normal consumers should rely on the build hook (`dart pub get` / `flutter pub get`).
//
//   dart run tool/install.dart
//   dart run tool/install.dart --repo yfedoseev/office_oxide --version 0.1.2
//   dart run tool/install.dart --platform android
//   dart run tool/install.dart --platform android --abi arm64-v8a

import 'dart:io';

import 'package:office_oxide_ffi/src/native_release.dart';
import 'package:office_oxide_ffi/src/native_release_fetch.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> args) async {
  var repo = Platform.environment['OFFICE_OXIDE_RELEASE_REPO'] ??
      defaultReleaseRepo;
  var version = Platform.environment['OFFICE_OXIDE_RELEASE_TAG'] ??
      defaultReleaseTag;
  String? platformOverride;
  String? archOverride;

  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--repo' && i + 1 < args.length) {
      repo = args[++i];
    } else if (arg == '--version' && i + 1 < args.length) {
      version = args[++i];
    } else if (arg == '--platform' && i + 1 < args.length) {
      platformOverride = args[++i];
    } else if (arg == '--abi' && i + 1 < args.length) {
      archOverride = args[++i];
    } else if (arg == '--help' || arg == '-h') {
      stderr.writeln(
        'Manual native install (fallback). Prefer: dart pub get (build hook).\n'
        'usage: dart run tool/install.dart '
        '[--repo owner/repo] [--version TAG] '
        '[--platform linux|macos|windows|android] '
        '[--abi x64|arm64|all|arm64-v8a|armeabi-v7a|x86_64|x86]',
      );
      exit(0);
    } else if (arg.startsWith('--')) {
      throw ArgumentError('unknown argument: $arg');
    }
  }

  final dartRoot = Directory(p.dirname(p.dirname(Platform.script.toFilePath())));
  final platform = platformOverride ?? _hostPlatform();
  final arch = archOverride ?? _defaultArch(platform);

  await installNativeToPackage(
    packageRoot: dartRoot,
    platform: platform,
    arch: arch,
    repo: repo,
    tag: version,
  );
}

String _hostPlatform() {
  if (Platform.isWindows) return 'windows';
  if (Platform.isMacOS) return 'macos';
  if (Platform.isLinux) return 'linux';
  throw UnsupportedError(
    'auto-detect platform unsupported on ${Platform.operatingSystem}; '
    'pass --platform android for Flutter Android builds',
  );
}

String _defaultArch(String platform) {
  if (platform == 'android') return 'all';
  if (Platform.version.contains('arm64') ||
      Platform.version.contains('aarch64')) {
    return 'arm64';
  }
  return 'x64';
}
