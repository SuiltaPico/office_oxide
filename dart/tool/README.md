# `tool/`

| Script | When to use |
|--------|-------------|
| [`install.dart`](install.dart) | Manual / offline install of Release `native-*` assets into `native/` or `jniLibs/` |

**Default path:** `dart pub get` runs [`hook/build.dart`](../hook/build.dart) and downloads the matching prebuilt library automatically. Use `install.dart` only when the hook cannot run (no network, wrong Release tag, or you need all Android ABIs in one shot).
