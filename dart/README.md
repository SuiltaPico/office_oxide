# office_oxide_ffi — Office documents in Dart & Flutter

**Read Word, Excel, and PowerPoint in your app** — modern Open XML **and** legacy binary formats — via a fast Rust core and Dart FFI. Export **plain text**, **Markdown**, or **HTML** from bytes or a file path.

Unofficial Dart/Flutter binding for [office_oxide](https://github.com/yfedoseev/office_oxide). Not affiliated with Office Oxide or Oxide (oxide.fyi). **MIT OR Apache-2.0.**

[![License: MIT OR Apache-2.0](https://img.shields.io/badge/License-MIT%20OR%20Apache--2.0-blue.svg)](https://opensource.org/licenses)

## What it opens

| Format | Extensions | Notes |
|--------|------------|--------|
| **Word** | `.docx`, `.doc` | Office Open XML + Word 97–2003 binary |
| **Excel** | `.xlsx`, `.xls` | Spreadsheets; competitive speed vs calamine on XLSX |
| **PowerPoint** | `.pptx`, `.ppt` | Slides + legacy PPT |

Use `OfficeFormat.docx`, `.xlsx`, `.pptx`, `.doc`, `.xls`, or `.ppt`, or `OfficeDocument.open(path)` (extension inferred).

**Outputs (read-only today):**

| Method | Use case |
|--------|----------|
| `plainText()` | Search, RAG chunks, logging |
| `toMarkdown()` | LLM prompts, chat apps, note tools |
| `toHtml()` | Rich preview or downstream HTML pipelines |

Same [C FFI](https://github.com/yfedoseev/office_oxide/blob/main/include/office_oxide_c/office_oxide.h) as the [Python](https://pypi.org/project/office-oxide/), [Go](https://pkg.go.dev/github.com/yfedoseev/office_oxide/go), [C#](https://www.nuget.org/packages/OfficeOxide), and [Node](https://www.npmjs.com/package/office-oxide) packages — one engine, six formats.

## Why not “docx-only” converters?

The underlying [office_oxide](https://github.com/yfedoseev/office_oxide) library is built for **batch extraction at native speed** (median ~0.8 ms/docx, ~5 ms/xlsx on large public corpora — see upstream [BENCHMARKS.md](https://github.com/yfedoseev/office_oxide/blob/main/BENCHMARKS.md)). If you only need `.docx` → Markdown, this package still fits; if you later need **`.xlsx` / `.ppt` / legacy `.doc`**, you do not swap libraries.

- **Fast** — Rust core, no JVM, no external `antiword`/`catdoc` binaries at runtime  
- **Reliable** — tuned for real-world Office files (upstream reports near-100% success on *valid* inputs in benchmark corpora)  
- **Flutter-ready** — Android `ffiPlugin`; desktop via prebuilt `native-*` Release assets  

## Install

**pub.dev** (after publish):

```yaml
dependencies:
  office_oxide_ffi: ^0.1.2
```

**Git** (fork with Dart binding + Releases):

```yaml
dependencies:
  office_oxide_ffi:
    git:
      url: https://github.com/SuiltaPico/office_oxide.git
      path: dart
      ref: v0.1.2
```

Requires **Dart SDK ≥ 3.10** and **Flutter ≥ 3.16** (build hooks + Android plugin).

## Quick start

```dart
import 'package:office_oxide_ffi/office_oxide_ffi.dart';

// From file (format from extension)
final report = OfficeDocument.open('report.docx');
try {
  print(report.plainText());
  print(report.toMarkdown());
} finally {
  report.dispose();
}

// From bytes (e.g. file_picker, network)
final sheet = OfficeDocument.fromBytes(xlsxBytes, OfficeFormat.xlsx);
try {
  final md = sheet.toMarkdown();
} finally {
  sheet.dispose();
}

print(OfficeDocument.libraryVersion()); // linked native library version
```

```bash
cd dart
dart pub get   # downloads native lib via build hook (see below)
dart test
dart run examples/01_extract.dart
```

## Native library (automatic)

Prebuilt binaries are **not** shipped inside the pub tarball. On `dart pub get` / `flutter pub get`, the [build hook](https://dart.dev/tools/hooks) (`hook/build.dart`) downloads the matching **`native-*`** asset from GitHub Releases (default: [SuiltaPico/office_oxide](https://github.com/SuiltaPico/office_oxide) tag **`v0.1.2`**).

| Situation | What to do |
|-----------|------------|
| Normal app / CI | `dart pub get` or `flutter pub get` |
| Offline / custom tag | `dart run tool/install.dart` — see [tool/README.md](tool/README.md) |
| Local Rust build | Set `OFFICE_OXIDE_LIB` to `liboffice_oxide.so` / `.dylib` / `.dll` |
| Fork has no Release yet | `dart run tool/install.dart --repo yfedoseev/office_oxide --version 0.1.2` |

Override hook defaults in your app `pubspec.yaml`:

```yaml
hooks:
  user_defines:
    office_oxide_ffi:
      release_repo: SuiltaPico/office_oxide
      release_tag: 0.1.2
      # local_lib: /path/to/liboffice_oxide.so
      # skip_download: true
```

Use Release assets named **`native-*`**, not CLI-only `office_oxide-windows-*.zip` bundles.

### Supported platforms

| Target | Architectures |
|--------|----------------|
| Linux | x64, arm64 |
| macOS | x64, arm64 |
| Windows | x64, arm64 |
| Android (Flutter) | arm64-v8a, armeabi-v7a, x86_64, x86 |

**Not supported here:** iOS, Web (use [WASM](https://www.npmjs.com/package/office-oxide-wasm) in a WebView or backend instead).

## API

| API | Description |
|-----|-------------|
| `OfficeDocument.fromBytes(bytes, OfficeFormat.*)` | Open from memory |
| `OfficeDocument.open(path)` | Open from path; format from extension |
| `.plainText()` / `.toMarkdown()` / `.toHtml()` | Export |
| `.formatName` | e.g. `docx`, `xlsx` |
| `.dispose()` | Free native handle |
| `OfficeDocument.libraryVersion()` | Native `office_oxide` version string |

## Repositories

| Role | URL |
|------|-----|
| **Maintained fork (Dart + Releases)** | https://github.com/SuiltaPico/office_oxide |
| **Upstream (Rust core)** | https://github.com/yfedoseev/office_oxide |

Longer guide: [docs/getting-started-dart.md](https://github.com/SuiltaPico/office_oxide/blob/main/docs/getting-started-dart.md).

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `native library not found` | Run `dart pub get` (hook), `dart run tool/install.dart`, or set `OFFICE_OXIDE_LIB` |
| Hook download failed | Ensure `release_tag` matches a GitHub Release with `native-linux-x86_64.tar.gz`, etc. |
| Android `dlopen` failed | `dart run tool/install.dart --platform android`, then rebuild the app |
| Using `pdfrx` + this package | You may need `dependency_overrides: hooks: ^2.0.2` until pdfium adopts hooks 2.x |

## Package layout (contributors)

| Path | Purpose |
|------|---------|
| `lib/` | Public API + FFI |
| `hook/build.dart` | Release download + native asset bundling |
| `tool/install.dart` | Manual / offline native install |
| `android/` | Flutter `ffiPlugin` scaffold |
| `examples/` | Small runnable demos |

## License

MIT OR Apache-2.0 — see [LICENSE](LICENSE) and the repository root licenses.
