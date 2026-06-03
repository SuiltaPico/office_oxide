# Getting Started with office_oxide (Dart / Flutter)

Dart and Flutter apps can call the same [C FFI](../include/office_oxide_c/office_oxide.h) surface as Go, C#, and Node.js (koffi). The binding lives in [`dart/`](../dart/) as package **`office_oxide_ffi`**.

> Unofficial Dart/Flutter binding; not affiliated with Office Oxide or Oxide (oxide.fyi).

## Repositories

| Role | GitHub |
|------|--------|
| **Fork (Dart binding maintained here)** | https://github.com/SuiltaPico/office_oxide |
| **Upstream (Rust core)** | https://github.com/yfedoseev/office_oxide |

Report Dart-specific issues on the fork; core parsing bugs may belong upstream.

## Installation

### From the fork (recommended for consumers)

```yaml
dependencies:
  office_oxide_ffi:
    git:
      url: https://github.com/SuiltaPico/office_oxide.git
      path: dart
      ref: main
```

### Monorepo / local path

```yaml
dependencies:
  office_oxide_ffi:
    path: ../dart
```

### Native runtime

1. **Desktop / `dart test`** — install script (Release **`native-*`**, not CLI zips):

   ```bash
   cd dart && dart run tool/install.dart
   ```

   Default Release source is the fork:

   ```bash
   dart run tool/install.dart
   # → github.com/SuiltaPico/office_oxide/releases
   ```

   If the fork has no `native-*` assets yet, use upstream:

   ```bash
   dart run tool/install.dart --repo yfedoseev/office_oxide
   ```

   Or set **`OFFICE_OXIDE_LIB`** to a built `liboffice_oxide.so` / `.dylib` / `.dll`
   (same convention as the Node.js binding).

2. **Android** — from GitHub Release **`native-android`** (or per-ABI `native-android-*`):

   ```bash
   cd dart && dart run tool/install.dart --platform android
   ```

   Installs `liboffice_oxide.so` for `arm64-v8a`, `armeabi-v7a`, `x86_64`, and
   `x86` under `dart/android/src/main/jniLibs/`.

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

## Flutter

Add the dependency; Android uses the plugin’s `jniLibs`. Desktop Flutter runners still need the matching `dart/native/...` library on disk (same as CLI `dart test`).

## Supported formats

`docx`, `xlsx`, `pptx`, `doc`, `xls`, `ppt` — pass the matching `OfficeFormat` when opening from bytes.

## Examples

| Example | Purpose |
|---------|---------|
| [`dart/examples/01_extract.dart`](../dart/examples/01_extract.dart) | Self-contained smoke (CI) |
| [`dart/examples/extract.dart`](../dart/examples/extract.dart) | Classic file-path extract |

## Troubleshooting

| Error | Fix |
|-------|-----|
| `native library not found` | Run `dart/tool/download_native.*` for your OS/arch |
| `liboffice_oxide.so` not found (Android) | `dart run tool/install.dart --platform android` |
| Wrong zip downloaded | Use **`native-windows-x86_64`**, not `office_oxide-windows-x86_64` (CLI only) |

## See also

- [C FFI](getting-started-c.md)
- [dart/README.md](../dart/README.md)
