# `native/` — optional on-disk prebuilds (desktop)

This directory is **empty in git**. After `dart pub get` (build hook) or
`dart run tool/install.dart`, desktop libraries land under:

```text
native/<platform>/<arch>/lib/…
native/<platform>/<arch>/include/office_oxide_c/…
```

Flutter on **Android** uses `android/src/main/jniLibs/` instead — see [README.md](../README.md).
