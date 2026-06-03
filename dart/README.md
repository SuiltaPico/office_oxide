# office_oxide for Dart / Flutter — Office Documents via FFI

Unofficial Dart/Flutter FFI bindings for the [office_oxide](https://github.com/yfedoseev/office_oxide) Rust core. Not affiliated with Office Oxide or Oxide (oxide.fyi). MIT / Apache-2.0.

[![License: MIT OR Apache-2.0](https://img.shields.io/badge/License-MIT%20OR%20Apache--2.0-blue.svg)](https://opensource.org/licenses)

> **Part of the office_oxide toolkit.** Same C FFI as [Rust](https://docs.rs/office_oxide), [Python](../python/README.md), [Go](../go/README.md), [JavaScript](../js/README.md), [C#](../csharp/OfficeOxide/README.md), and [WASM](../wasm-pkg/README.md).

## Fork vs upstream

| Role | Repository | Notes |
|------|------------|-------|
| **Fork (Dart binding maintained here)** | [**github.com/SuiltaPico/office_oxide**](https://github.com/SuiltaPico/office_oxide) | Contains `dart/`; Issues, Releases, and `dart run tool/install.dart` default here |
| **Upstream** | [github.com/yfedoseev/office_oxide](https://github.com/yfedoseev/office_oxide) | Rust core and other language bindings; Dart changes are intended for upstream PRs |

If this fork has not published `native-*` release assets yet, point the hook or
`install.dart` at upstream: `--repo yfedoseev/office_oxide --version 0.1.2`.

## Package layout

| Path | In git | Purpose |
|------|--------|---------|
| `lib/` | yes | Dart API + shared release/download logic |
| `hook/build.dart` | yes | Build hook — **primary** native download |
| `tool/install.dart` | yes | Manual install fallback only |
| `native/` | empty (see `native/README.md`) | Optional on-disk desktop prebuilds |
| `android/` | yes (no `.so`) | Flutter `ffiPlugin` + `jniLibs/` target |
| `test/fixtures/` | yes | Smoke `.docx` |
| `examples/` | yes | Two small demos (see `examples/README.md`) |
| `.dart_tool/` | no | Hook output, analyzer cache |

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

### Native runtime (one primary path)

1. **`dart pub get`** / **`flutter pub get`** — runs [`hook/build.dart`](hook/build.dart) and downloads the matching GitHub Release **`native-*`** asset ([Dart hooks](https://dart.dev/tools/hooks)).
2. **`dart run tool/install.dart`** — only if you need offline install, all Android ABIs at once, or a different `--repo` / `--version`.
3. **`OFFICE_OXIDE_LIB`** — CI or local Rust `cargo build --release --lib`.

Configure the hook in `pubspec.yaml` → `hooks.user_defines.office_oxide_ffi` (`release_repo`, `release_tag`, optional `local_lib`, `skip_download`). Default tag: **`v0.1.2`** (same as `Cargo.toml` / Release workflow).

```bash
cd dart
dart pub get
dart test
```

Manual fallback (see [`tool/README.md`](tool/README.md)):

```bash
dart run tool/install.dart
dart run tool/install.dart --repo yfedoseev/office_oxide --version 0.1.2
dart run tool/install.dart --platform android              # all ABIs → jniLibs/
dart run tool/install.dart --platform android --abi arm64-v8a
```

Use Release assets named **`native-*`**, not `office_oxide-windows-*.zip` (CLI-only).

### Supported platforms (after Release)

| Target | Architectures |
|--------|----------------|
| Linux | x64, arm64 |
| macOS | x64, arm64 |
| Windows | x64, arm64 |
| Android (Flutter) | arm64-v8a, armeabi-v7a, x86_64, x86 |

Not supported: iOS, Web (use WASM bindings elsewhere).

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
dart pub get   # hook downloads native lib (or use install.dart / OFFICE_OXIDE_LIB)
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
| `native library not found` | `dart pub get` (hook), `dart run tool/install.dart`, or `OFFICE_OXIDE_LIB` |
| Fork has no Release yet | `dart run tool/install.dart --repo yfedoseev/office_oxide` or push tag **`v0.1.2`** on `main` |
| Hook download failed | Check `release_tag` in `pubspec.yaml` `hooks.user_defines` matches a GitHub Release |
| Android `dlopen` failed | `dart run tool/install.dart --platform android`, rebuild the Flutter app |
| Wrong zip | Use **`native-*`**, not CLI bundles |

## License

MIT OR Apache-2.0 — see [LICENSE](LICENSE) and the repository root licenses.
