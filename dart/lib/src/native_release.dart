import 'package:code_assets/code_assets.dart';

/// Default GitHub repo for `native-*` release assets (fork).
const String defaultReleaseRepo = 'SuiltaPico/office_oxide';

/// Default release tag for Dart/Flutter prebuilds (`v` prefix added in URLs).
///
/// Must match [Cargo.toml] / Git tag `v0.1.2` (see `.github/workflows/release.yml`).
const String defaultReleaseTag = '0.1.2';

/// GitHub archive base name (without extension), e.g. `native-linux-x86_64`.
String nativeAssetBaseName({
  required OS targetOS,
  required Architecture targetArchitecture,
}) {
  if (targetOS == OS.android) {
    final abi = androidJniAbi(targetArchitecture);
    return 'native-android-$abi';
  }
  final platform = switch (targetOS) {
    OS.linux => 'linux',
    OS.macOS => 'macos',
    OS.windows => 'windows',
    _ => throw UnsupportedError('unsupported target OS: ${targetOS.name}'),
  };
  final arch = switch (targetArchitecture) {
    Architecture.x64 => 'x86_64',
    Architecture.arm64 => 'aarch64',
    _ => throw UnsupportedError(
      'unsupported desktop architecture: ${targetArchitecture.name}',
    ),
  };
  return 'native-$platform-$arch';
}

/// Android JNI folder name for a [Architecture].
String androidJniAbi(Architecture architecture) => switch (architecture) {
  Architecture.arm64 => 'arm64-v8a',
  Architecture.arm => 'armeabi-v7a',
  Architecture.ia32 => 'x86',
  Architecture.x64 => 'x86_64',
  _ => throw UnsupportedError(
    'unsupported Android architecture: ${architecture.name}',
  ),
};

/// File name of the dynamic library inside extracted `lib/` or `jniLibs/<abi>/`.
String bundledLibraryBaseName(OS targetOS) => 'office_oxide';

/// Relative path to the shared library inside a desktop `native-*` archive.
String desktopLibraryRelativePath({
  required OS targetOS,
  required Architecture targetArchitecture,
}) {
  final platform = switch (targetOS) {
    OS.linux => 'linux',
    OS.macOS => 'macos',
    OS.windows => 'windows',
    _ => throw UnsupportedError('unsupported target OS: ${targetOS.name}'),
  };
  final archFolder = switch (targetArchitecture) {
    Architecture.x64 => 'x64',
    Architecture.arm64 => 'arm64',
    _ => throw UnsupportedError(
      'unsupported desktop architecture: ${targetArchitecture.name}',
    ),
  };
  final fileName = targetOS.dylibFileName(bundledLibraryBaseName(targetOS));
  return 'native/$platform/$archFolder/lib/$fileName';
}

/// Relative path inside an Android `native-android-<abi>` archive.
String androidLibraryRelativePath(Architecture targetArchitecture) {
  final abi = androidJniAbi(targetArchitecture);
  return 'jniLibs/$abi/liboffice_oxide.so';
}

/// Android Release archive base (`arch`: `all` or a JNI ABI folder name).
String nativeAndroidAssetBaseName(String arch) => switch (arch) {
  'all' => 'native-android',
  'arm64-v8a' || 'armeabi-v7a' || 'x86_64' || 'x86' => 'native-android-$arch',
  _ => throw ArgumentError(
    'unsupported Android ABI: $arch (use all, arm64-v8a, armeabi-v7a, x86_64, x86)',
  ),
};

/// Desktop install target: OS/arch for the hook plus `native/<platform>/<arch>/`.
( OS os, Architecture architecture) parseDesktopInstallTarget(
  String platform,
  String arch,
) {
  return switch ('$platform-$arch') {
    'linux-x64' => (OS.linux, Architecture.x64),
    'linux-arm64' => (OS.linux, Architecture.arm64),
    'macos-x64' => (OS.macOS, Architecture.x64),
    'macos-arm64' => (OS.macOS, Architecture.arm64),
    'windows-x64' => (OS.windows, Architecture.x64),
    'windows-arm64' => (OS.windows, Architecture.arm64),
    _ => throw ArgumentError('unsupported desktop platform/arch: $platform $arch'),
  };
}

/// HTTPS URL for a release archive.
Uri releaseArchiveUrl({
  required String repo,
  required String tag,
  required String assetBaseName,
  required OS targetOS,
}) {
  final vTag = tag.startsWith('v') ? tag : 'v$tag';
  final ext = targetOS == OS.windows ? 'zip' : 'tar.gz';
  return Uri.https(
    'github.com',
    '/$repo/releases/download/$vTag/$assetBaseName.$ext',
  );
}

/// Maps hook [BuildInput] code config to a preinstalled path under [packageRoot]
/// (from `dart run tool/install.dart`).
String? preinstalledLibraryRelativePath({
  required OS targetOS,
  required Architecture targetArchitecture,
}) {
  try {
    if (targetOS == OS.android) {
      return androidLibraryRelativePath(targetArchitecture);
    }
    return desktopLibraryRelativePath(
      targetOS: targetOS,
      targetArchitecture: targetArchitecture,
    );
  } on UnsupportedError {
    return null;
  }
}
