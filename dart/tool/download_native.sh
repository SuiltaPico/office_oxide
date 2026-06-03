#!/usr/bin/env bash
# Usage:
#   dart/tool/download_native.sh [linux|macos|windows|android] [arch|abi] [version] [repo]
#   Android arch: all (default bundle), arm64-v8a, armeabi-v7a, x86_64, x86
#   repo defaults to SuiltaPico/office_oxide (use yfedoseev/office_oxide for upstream releases).
set -euo pipefail

platform="${1:-linux}"
arch="${2:-x64}"
version="${3:-0.1.2}"
repo="${4:-SuiltaPico/office_oxide}"

dart_root="$(cd "$(dirname "$0")/.." && pwd)"

if [[ "${platform}" == "android" ]]; then
  case "${arch}" in
    all)         asset=native-android ;;
    arm64-v8a)   asset=native-android-arm64-v8a ;;
    armeabi-v7a) asset=native-android-armeabi-v7a ;;
    x86_64)      asset=native-android-x86_64 ;;
    x86)         asset=native-android-x86 ;;
    *)
      echo "unsupported Android ABI: ${arch}" >&2
      echo "supported: all, arm64-v8a, armeabi-v7a, x86_64, x86" >&2
      exit 1
      ;;
  esac
  dest="${dart_root}/android/src/main"
else
  case "${platform}-${arch}" in
    linux-x64)     asset=native-linux-x86_64 ;;
    linux-arm64)   asset=native-linux-aarch64 ;;
    macos-x64)     asset=native-macos-x86_64 ;;
    macos-arm64)   asset=native-macos-aarch64 ;;
    windows-x64)   asset=native-windows-x86_64 ;;
    windows-arm64) asset=native-windows-aarch64 ;;
    *) echo "unsupported: ${platform} ${arch}" >&2; exit 1 ;;
  esac
  dest="${dart_root}/native/${platform}/${arch}"
fi

mkdir -p "${dest}"

url="https://github.com/${repo}/releases/download/v${version}/${asset}.tar.gz"
if [[ "${platform}" == "windows" ]]; then
  url="https://github.com/${repo}/releases/download/v${version}/${asset}.zip"
fi

tmp="$(mktemp)"
echo "Fetching ${url}"
curl -fsSL -o "${tmp}" "${url}"

if [[ "${platform}" == "windows" ]]; then
  unzip -qo "${tmp}" -d "${dest}"
else
  tar -xzf "${tmp}" -C "${dest}"
fi
rm -f "${tmp}"

echo "Extracted to ${dest}"
if [[ "${platform}" == "android" ]]; then
  ls -la "${dest}/jniLibs" 2>/dev/null || true
else
  ls -la "${dest}/lib" 2>/dev/null || true
fi
