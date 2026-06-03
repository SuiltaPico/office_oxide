// Downloads matching GitHub Release `native-*` assets into dart/native/ or
// dart/android/src/main/jniLibs/ for Flutter Android.
//
//   dart run tool/install.dart
//   dart run tool/install.dart --repo YOUR_GITHUB_USER/office_oxide
//   dart run tool/install.dart --version 0.1.2
//   dart run tool/install.dart --platform android
//   dart run tool/install.dart --platform android --abi arm64-v8a

import 'dart:io';

import 'package:path/path.dart' as p;

Future<void> main(List<String> args) async {
  var repo = Platform.environment['OFFICE_OXIDE_RELEASE_REPO'] ??
      'SuiltaPico/office_oxide';
  var version = '0.1.2';
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
        'usage: dart run tool/install.dart '
        '[--repo owner/repo] [--version x.y.z] '
        '[--platform linux|macos|windows|android] '
        '[--abi x64|arm64|all|arm64-v8a|armeabi-v7a|x86_64|x86]',
      );
      exit(0);
    } else if (arg.startsWith('--')) {
      throw ArgumentError('unknown argument: $arg');
    }
  }

  final scriptDir = p.dirname(Platform.script.toFilePath());
  final dartRoot = p.dirname(scriptDir);
  final platform = platformOverride ?? _hostPlatform();
  final arch = archOverride ?? _defaultArch(platform);

  if (Platform.isWindows) {
    final result = await Process.run(
      'powershell',
      [
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        p.join(scriptDir, 'download_native.ps1'),
        '-Platform',
        platform,
        '-Arch',
        arch,
        '-Version',
        version,
        '-Repo',
        repo,
      ],
      runInShell: true,
      workingDirectory: dartRoot,
    );
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    exit(result.exitCode);
  }

  final result = await Process.run(
    'bash',
    [
      p.join(scriptDir, 'download_native.sh'),
      platform,
      arch,
      version,
      repo,
    ],
    workingDirectory: dartRoot,
  );
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  exit(result.exitCode);
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
