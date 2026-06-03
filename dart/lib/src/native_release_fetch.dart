import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:office_oxide_ffi/src/native_release.dart';
import 'package:path/path.dart' as p;

/// Downloads and extracts the office_oxide shared library for [targetOS] /
/// [targetArchitecture] into [outputDirectory].
Future<File> fetchNativeLibrary({
  required Directory outputDirectory,
  required OS targetOS,
  required Architecture targetArchitecture,
  required String repo,
  required String tag,
}) async {
  final assetBase = nativeAssetBaseName(
    targetOS: targetOS,
    targetArchitecture: targetArchitecture,
  );
  final url = releaseArchiveUrl(
    repo: repo,
    tag: tag,
    assetBaseName: assetBase,
    targetOS: targetOS,
  );
  final ext = targetOS == OS.windows ? '.zip' : '.tar.gz';
  final archiveFile = File(
    p.join(outputDirectory.path, '$assetBase$ext'),
  );
  final extractRoot = Directory(
    p.join(outputDirectory.path, assetBase),
  );

  if (!await extractRoot.exists()) {
    await extractRoot.create(recursive: true);
  }

  if (!await archiveFile.exists()) {
    await _download(url, archiveFile);
    await _extractArchive(
      archiveFile: archiveFile,
      dest: extractRoot,
      isZip: targetOS == OS.windows,
    );
  }

  final libRelative = targetOS == OS.android
      ? androidLibraryRelativePath(targetArchitecture)
      : p.join(
          'lib',
          targetOS.dylibFileName(bundledLibraryBaseName(targetOS)),
        );

  final libFile = File(p.join(extractRoot.path, libRelative));
  if (!await libFile.exists()) {
    throw StateError(
      'expected library at ${libFile.path} after extracting $url',
    );
  }
  return libFile;
}

Future<void> _download(Uri url, File dest) async {
  final client = HttpClient()..findProxy = HttpClient.findProxyFromEnvironment;
  try {
    final request = await client.getUrl(url);
    final response = await request.close();
    if (response.statusCode != 200) {
      throw HttpException(
        'GET $url failed with status ${response.statusCode}',
        uri: url,
      );
    }
    await dest.parent.create(recursive: true);
    await response.pipe(dest.openWrite());
  } finally {
    client.close(force: true);
  }
}

Future<void> _extractArchive({
  required File archiveFile,
  required Directory dest,
  required bool isZip,
}) async {
  if (isZip) {
    final result = await Process.run(
      'powershell',
      [
        '-NoProfile',
        '-Command',
        'Expand-Archive -LiteralPath "${archiveFile.path}" -DestinationPath "${dest.path}" -Force',
      ],
      runInShell: true,
    );
    if (result.exitCode != 0) {
      throw StateError(
        'Expand-Archive failed: ${result.stderr}',
      );
    }
    return;
  }

  final result = await Process.run('tar', [
    '-xzf',
    archiveFile.path,
    '-C',
    dest.path,
  ]);
  if (result.exitCode != 0) {
    throw StateError('tar failed: ${result.stderr}');
  }
}

/// Resolves an on-disk library file: [localLib] override, preinstalled under
/// [packageRoot], or download into [outputDirectory].
Future<File> resolveNativeLibraryFile({
  required Directory outputDirectory,
  required Uri packageRoot,
  required OS targetOS,
  required Architecture targetArchitecture,
  required String repo,
  required String tag,
  String? localLib,
}) async {
  if (localLib != null && localLib.isNotEmpty) {
    final file = File(localLib);
    if (!file.existsSync()) {
      throw StateError('local_lib does not exist: $localLib');
    }
    return file;
  }

  final relative = preinstalledLibraryRelativePath(
    targetOS: targetOS,
    targetArchitecture: targetArchitecture,
  );
  if (relative != null) {
    final preinstalled = File.fromUri(packageRoot.resolve(relative));
    if (preinstalled.existsSync()) {
      return preinstalled;
    }
  }

  return fetchNativeLibrary(
    outputDirectory: outputDirectory,
    targetOS: targetOS,
    targetArchitecture: targetArchitecture,
    repo: repo,
    tag: tag,
  );
}

/// Manual install: download a Release archive into the package tree.
///
/// * Desktop → `native/<platform>/<arch>/{lib,include}/`
/// * Android → `android/src/main/jniLibs/...`
///
/// Prefer [`dart pub get`](https://dart.dev/tools/hooks) (build hook) for normal use.
Future<Directory> installNativeToPackage({
  required Directory packageRoot,
  required String platform,
  required String arch,
  required String repo,
  required String tag,
}) async {
  if (platform == 'android') {
    final assetBase = nativeAndroidAssetBaseName(arch);
    final dest = Directory(
      p.join(packageRoot.path, 'android', 'src', 'main'),
    );
    final url = releaseArchiveUrl(
      repo: repo,
      tag: tag,
      assetBaseName: assetBase,
      targetOS: OS.android,
    );
    stdout.writeln('Fetching $url');
    await dest.create(recursive: true);
    await _downloadAndExtractInto(url: url, dest: dest, isZip: false);
    stdout.writeln('Extracted to ${dest.path}');
    return dest;
  }

  final (os, architecture) = parseDesktopInstallTarget(platform, arch);
  final assetBase = nativeAssetBaseName(
    targetOS: os,
    targetArchitecture: architecture,
  );
  final dest = Directory(p.join(packageRoot.path, 'native', platform, arch));
  final url = releaseArchiveUrl(
    repo: repo,
    tag: tag,
    assetBaseName: assetBase,
    targetOS: os,
  );
  stdout.writeln('Fetching $url');
  await dest.create(recursive: true);
  await _downloadAndExtractInto(
    url: url,
    dest: dest,
    isZip: os == OS.windows,
  );
  stdout.writeln('Extracted to ${dest.path}');
  return dest;
}

Future<void> _downloadAndExtractInto({
  required Uri url,
  required Directory dest,
  required bool isZip,
}) async {
  final ext = isZip ? '.zip' : '.tar.gz';
  final tmp = File(
    p.join(
      Directory.systemTemp.path,
      'office_oxide_install_${DateTime.now().microsecondsSinceEpoch}$ext',
    ),
  );
  try {
    await _download(url, tmp);
    await _extractArchive(archiveFile: tmp, dest: dest, isZip: isZip);
  } finally {
    if (tmp.existsSync()) {
      tmp.deleteSync();
    }
  }
}
