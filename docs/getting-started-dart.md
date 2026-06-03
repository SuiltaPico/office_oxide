# Getting Started with office_oxide (Dart / Flutter)

Dart and Flutter apps call the same [C FFI](../include/office_oxide_c/office_oxide.h) as Go, C#, and Node.js (koffi). The binding lives in [`dart/`](../dart/) as package **`office_oxide_ffi`**.

> Unofficial Dart/Flutter binding; not affiliated with Office Oxide or Oxide (oxide.fyi).

## Repositories

| Role | GitHub |
|------|--------|
| **Fork (Dart binding maintained here)** | https://github.com/SuiltaPico/office_oxide |
| **Upstream (Rust core)** | https://github.com/yfedoseev/office_oxide |

## Installation

```yaml
dependencies:
  office_oxide_ffi:
    git:
      url: https://github.com/SuiltaPico/office_oxide.git
      path: dart
      ref: main
```

Requires **Dart SDK ≥ 3.10** (build hooks).

### Native library

```bash
cd dart && dart pub get
```

That runs the package build hook and downloads the correct **`native-*`** prebuilt for your host (or Flutter build target). No separate shell scripts.

**Fallback:** `dart run tool/install.dart` (offline, all Android ABIs, or another Release repo/tag).

**CI / Rust dev:** `OFFICE_OXIDE_LIB=/absolute/path/to/liboffice_oxide.{so,dylib,dll}`.

If the fork has no Release yet:

```bash
dart run tool/install.dart --repo yfedoseev/office_oxide --version 0.1.2
```

### Android (Flutter)

`ffiPlugin: true` — hook downloads per-ABI assets during `flutter pub get` / build. To populate all `jniLibs/` locally:

```bash
cd dart && dart run tool/install.dart --platform android
```

## Quickstart

```dart
import 'package:office_oxide_ffi/office_oxide_ffi.dart';

void main() {
  final doc = OfficeDocument.open('report.docx');
  try {
    print(doc.plainText());
    print(doc.toMarkdown());
  } finally {
    doc.dispose();
  }
}
```

From bytes:

```dart
final doc = OfficeDocument.fromBytes(bytes, OfficeFormat.docx);
```

## Supported platforms

| Target | Architectures |
|--------|----------------|
| Linux | x64, arm64 |
| macOS | x64, arm64 |
| Windows | x64, arm64 |
| Android | arm64-v8a, armeabi-v7a, x86_64, x86 |

Not supported: iOS, Web.

## Examples

See [`dart/examples/README.md`](../dart/examples/README.md).

## Troubleshooting

| Error | Fix |
|-------|-----|
| `native library not found` | `dart pub get` (hook), then `dart run tool/install.dart`, or `OFFICE_OXIDE_LIB` |
| Hook download 404 | Push tag **`v0.1.2`** (runs Release workflow) or use upstream `install.dart --repo yfedoseev/office_oxide` |
| Android `dlopen` failed | `dart run tool/install.dart --platform android`, rebuild the app |
| Wrong zip | Use **`native-*`**, not CLI `office_oxide-windows-*` bundles |

## See also

- [dart/README.md](../dart/README.md)
- [C FFI](getting-started-c.md)
