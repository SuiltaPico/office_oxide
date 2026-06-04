## 0.1.2+1

- Register Flutter `ffiPlugin` on Linux, macOS, and Windows (pub.dev platform labels).
- Add desktop plugin CMake / macOS pod stubs; native load unchanged via build hook.
- Native library still **office_oxide v0.1.2** (`release_tag: 0.1.2`).

## 0.1.2

- Initial pub release: Dart/Flutter FFI for office_oxide (DOCX/XLSX/PPTX and legacy formats).
- Build hook downloads `native-*` / `native-android-*` from GitHub Releases.
- Android `ffiPlugin` only (desktop via hook, not yet listed on pub.dev).
- Manual fallback: `dart run tool/install.dart`.
