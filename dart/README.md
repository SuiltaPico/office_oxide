# office_oxide for Dart / Flutter — Office Documents via FFI

Unofficial Dart/Flutter FFI bindings for the [office_oxide](https://github.com/yfedoseev/office_oxide) Rust core. Not affiliated with Office Oxide or Oxide (oxide.fyi). MIT / Apache-2.0.

[![License: MIT OR Apache-2.0](https://img.shields.io/badge/License-MIT%20OR%20Apache--2.0-blue.svg)](https://opensource.org/licenses)

> **Part of the office_oxide toolkit.** Same C FFI as [Rust](https://docs.rs/office_oxide), [Python](../python/README.md), [Go](../go/README.md), [JavaScript](../js/README.md), [C#](../csharp/OfficeOxide/README.md), and [WASM](../wasm-pkg/README.md).

## Fork vs upstream

| Role | Repository | Notes |
|------|------------|-------|
| **Fork (Dart binding maintained here)** | [**github.com/SuiltaPico/office_oxide**](https://github.com/SuiltaPico/office_oxide) | Contains `dart/`; Issues, Releases, and `dart run tool/install.dart` default here |
| **Upstream** | [github.com/yfedoseev/office_oxide](https://github.com/yfedoseev/office_oxide) | Rust core and other language bindings; Dart changes are intended for upstream PRs |

If this fork has not published `native-*` release assets yet, install from upstream:

```bash
dart run tool/install.dart --repo yfedoseev/office_oxide
```

## Quick start

### From the fork (Flutter / Dart apps)

```yaml
dependencies:
  office_oxide_ffi:
    git:
      url: https://github.com/SuiltaPico/office_oxide.git
      path: dart
      ref: main   # or a tag, e.g. v0.1.2
```

### Monorepo path

```yaml
dependencies:
  office_oxide_ffi:
    path: ../dart
```

```dart
import 'package:office_oxide_ffi/office_oxide_ffi.dart';

final doc = OfficeDocument.fromBytes(bytes, OfficeFormat.docx);
try {
  print(doc.toMarkdown());
} finally {
  doc.dispose();
}
```

### Native runtime

| Platform | How |
|----------|-----|
| Windows / Linux / macOS | GitHub Release **`native-*`** → `dart/native/` |
| Android (Flutter) | Release **`native-android`** (all ABIs) → `android/src/main/jniLibs/` |
| CI / local dev | `OFFICE_OXIDE_LIB=/path/to/liboffice_oxide.so` |

```bash
cd dart
dart run tool/install.dart
# default: SuiltaPico/office_oxide releases
dart run tool/install.dart --repo yfedoseev/office_oxide   # upstream releases
dart run tool/install.dart --platform android              # all ABIs for Flutter
dart run tool/install.dart --platform android --abi arm64-v8a   # single ABI
```

Optional environment variable:

```bash
export OFFICE_OXIDE_RELEASE_REPO=SuiltaPico/office_oxide
```

Do **not** use `office_oxide-windows-*.zip` (CLI-only). Use **`native-windows-x86_64.zip`** etc.

### Android

```bash
cd dart
dart run tool/install.dart --platform android
```

Downloads **`native-android.tar.gz`** (all ABIs: `arm64-v8a`, `armeabi-v7a`,
`x86_64`, `x86`) into `android/src/main/jniLibs/`. Pass `--abi <name>` for a
single ABI tarball. `ffiPlugin: true` bundles `jniLibs` in Flutter apps.

## API

| API | Description |
|-----|-------------|
| `OfficeDocument.fromBytes(bytes, format)` | Open from memory |
| `OfficeDocument.open(path)` | Open from path |
| `.plainText()` / `.toMarkdown()` / `.toHtml()` | Export |
| `.dispose()` | Free native handle |
| `OfficeDocument.libraryVersion()` | Underlying `office_oxide` version |

Formats: `docx`, `xlsx`, `pptx`, `doc`, `xls`, `ppt` via `OfficeFormat`.

## Examples

```bash
cd dart
dart pub get
dart run tool/install.dart
dart test
dart run examples/01_extract.dart
dart run examples/extract.dart path/to/report.docx
```

## Contributing upstream

- Keep the **unofficial / not affiliated** disclaimer in this README and in `pubspec.yaml` `description`.
- While developing in the fork, `homepage` / `repository` in `pubspec.yaml` may point at **SuiltaPico**; they may move back to **yfedoseev** after merge.
- See [docs/getting-started-dart.md](../docs/getting-started-dart.md).

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `native library not found` | `dart run tool/install.dart` or set `OFFICE_OXIDE_LIB` |
| Fork has no Release | `dart run tool/install.dart --repo yfedoseev/office_oxide` |
| Android `dlopen` failed | `dart run tool/install.dart --platform android`, rebuild the Flutter app |
| Wrong zip | Use **`native-*`**, not CLI bundles |

## License

MIT OR Apache-2.0 — see [LICENSE](LICENSE) and the repository root licenses.
