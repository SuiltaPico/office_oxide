# Native libraries for `office_oxide_ffi`

Desktop / VM tests load binaries from here. Flutter on Android loads
`android/src/main/jniLibs/<abi>/liboffice_oxide.so` instead.

## Download prebuilt (matches GitHub Release `native-*` assets)

```powershell
dart/tool/download_native.ps1 -Platform windows -Arch x64
dart/tool/download_native.ps1 -Platform android -Arch all
dart/tool/download_native.ps1 -Platform android -Arch arm64-v8a
```

```bash
dart/tool/download_native.sh linux x64
dart/tool/download_native.sh android all
dart/tool/download_native.sh android arm64-v8a
```

Or use the cross-platform installer:

```bash
cd dart
dart run tool/install.dart
dart run tool/install.dart --platform android
dart run tool/install.dart --platform android --abi x86_64
```

## Android Release assets

| Asset | ABIs |
|-------|------|
| **`native-android.tar.gz`** | all: `arm64-v8a`, `armeabi-v7a`, `x86_64`, `x86` |
| `native-android-arm64-v8a.tar.gz` | 64-bit ARM (phones, most devices) |
| `native-android-armeabi-v7a.tar.gz` | 32-bit ARM (legacy devices) |
| `native-android-x86_64.tar.gz` | 64-bit x86 (emulators) |
| `native-android-x86.tar.gz` | 32-bit x86 (legacy emulators) |

Each tarball extracts to `android/src/main/jniLibs/<abi>/liboffice_oxide.so`.
