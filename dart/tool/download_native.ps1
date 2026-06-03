param(
    [ValidateSet('windows', 'linux', 'macos', 'android')]
    [string] $Platform = 'windows',
    [string] $Arch = 'x64',
    [string] $Version = '0.1.2',
    [string] $Repo = 'SuiltaPico/office_oxide'
)

$ErrorActionPreference = 'Stop'
$dartRoot = Split-Path -Parent $PSScriptRoot

$androidAbis = @('arm64-v8a', 'armeabi-v7a', 'x86_64', 'x86')

if ($Platform -eq 'android') {
    if ($Arch -eq 'all') {
        $asset = 'native-android'
    } elseif ($Arch -in $androidAbis) {
        $asset = "native-android-$Arch"
    } else {
        throw "unsupported Android ABI: $Arch (supported: all, $($androidAbis -join ', '))"
    }
    $dest = Join-Path $dartRoot 'android\src\main'
} else {
    $asset = switch ("$Platform-$Arch") {
        'windows-x64'   { 'native-windows-x86_64' }
        'windows-arm64' { 'native-windows-aarch64' }
        'linux-x64'     { 'native-linux-x86_64' }
        'linux-arm64'   { 'native-linux-aarch64' }
        'macos-x64'     { 'native-macos-x86_64' }
        'macos-arm64'   { 'native-macos-aarch64' }
        default { throw "unsupported: $Platform $Arch" }
    }
    $dest = Join-Path $dartRoot "native\$Platform\$Arch"
}

New-Item -ItemType Directory -Force -Path $dest | Out-Null

$ext = if ($Platform -eq 'windows') { '.zip' } else { '.tar.gz' }
$url = "https://github.com/$Repo/releases/download/v$Version/${asset}.zip"
if ($ext -eq '.tar.gz') {
    $url = "https://github.com/$Repo/releases/download/v$Version/${asset}.tar.gz"
}

$tmp = Join-Path $env:TEMP "$asset$ext"
Write-Host "Downloading $url"
Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing

if ($ext -eq '.zip') {
    Expand-Archive -Path $tmp -DestinationPath $dest -Force
} else {
    tar -xzf $tmp -C $dest
}

Write-Host "Extracted to $dest"
if ($Platform -eq 'android') {
    Get-ChildItem -Recurse (Join-Path $dest 'jniLibs') -ErrorAction SilentlyContinue
} else {
    Get-ChildItem -Recurse (Join-Path $dest 'lib') -ErrorAction SilentlyContinue
}
