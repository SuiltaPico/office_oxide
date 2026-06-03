import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:office_oxide_ffi/src/native_release.dart';
import 'package:office_oxide_ffi/src/native_release_fetch.dart';

/// Asset id used by [@DefaultAsset] / bundled FFI in [native_library.dart].
const String nativeAssetName = 'src/native_library.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets) {
      return;
    }

    final code = input.config.code;
    final targetOS = code.targetOS;
    final targetArchitecture = code.targetArchitecture;

    if (input.userDefines['skip_download'] == true) {
      return;
    }

    final repo = input.userDefines['release_repo'] as String? ?? defaultReleaseRepo;
    final tag = input.userDefines['release_tag'] as String? ?? defaultReleaseTag;
    final localLibUri = input.userDefines.path('local_lib');

    try {
      final libFile = await resolveNativeLibraryFile(
        outputDirectory: Directory.fromUri(input.outputDirectoryShared),
        packageRoot: input.packageRoot,
        targetOS: targetOS,
        targetArchitecture: targetArchitecture,
        repo: repo,
        tag: tag,
        localLib: localLibUri?.toFilePath(),
      );

      output.assets.code.add(
        CodeAsset(
          package: input.packageName,
          name: nativeAssetName,
          linkMode: DynamicLoadingBundled(),
          file: libFile.uri,
        ),
      );

      if (Platform.isLinux || Platform.isMacOS) {
        output.dependencies.add(libFile.uri);
      }
    } on UnsupportedError catch (e) {
      throw UnsupportedError(
        'office_oxide_ffi: ${e.message ?? e}\n'
        'Supported: Linux/macOS/Windows (x64, arm64) and Android (arm, arm64, '
        'x86, x64). Use hooks user_defines local_lib or OFFICE_OXIDE_LIB at '
        'runtime, or dart run tool/install.dart.',
      );
    } on HttpException catch (e) {
      throw StateError(
        'office_oxide_ffi: failed to download native library (${e.uri}): ${e.message}\n'
        'Fork releases: https://github.com/$repo/releases (tag v$tag)\n'
        'Until published, use:\n'
        '  dart run tool/install.dart --repo yfedoseev/office_oxide --version 0.1.2\n'
        'or hooks user_defines: release_repo / release_tag / local_lib',
      );
    }
  });
}
