# Renames release APKs for GitHub Releases upload.
#
# Flutter's default output names (app-arm64-v8a-release.apk, etc.) are not
# user-friendly. This script copies the output of
# `flutter build apk --release --split-per-abi` into build/release-uploads/
# under short, friendly names:
#
#   barcode-boss-arm64.apk      (recommended; ~95% of modern phones)
#   barcode-boss-arm32.apk      (pre-2018 32-bit phones)
#   barcode-boss-universal.apk  (all ABIs in one APK)
#
# Filenames do NOT include version -- the Pages /latest/download/<name>
# URL stays the same across every release, so links shared with testers
# never break.

$ErrorActionPreference = "Stop"

$SrcDir  = "build/app/outputs/flutter-apk"
$DestDir = "build/release-uploads"

$expected = @{
    "app-arm64-v8a-release.apk"   = "barcode-boss-arm64.apk"
    "app-armeabi-v7a-release.apk" = "barcode-boss-arm32.apk"
    "app-release.apk"             = "barcode-boss-universal.apk"
}

# Verify all source APKs exist first.
$missing = @()
foreach ($src in $expected.Keys) {
    if (-not (Test-Path (Join-Path $SrcDir $src))) { $missing += $src }
}
if ($missing.Count -gt 0) {
    Write-Host "ERROR: Source APKs not found:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "  - $SrcDir/$_" -ForegroundColor Red }
    Write-Host ""
    Write-Host "Run these first:" -ForegroundColor Yellow
    Write-Host "  flutter build apk --release --split-per-abi" -ForegroundColor Yellow
    Write-Host "  flutter build apk --release" -ForegroundColor Yellow
    exit 1
}

# Clean and recreate destination directory.
if (Test-Path $DestDir) { Remove-Item -Recurse -Force $DestDir }
New-Item -ItemType Directory -Path $DestDir | Out-Null

foreach ($pair in $expected.GetEnumerator()) {
    $src  = Join-Path $SrcDir  $pair.Key
    $dest = Join-Path $DestDir $pair.Value
    Copy-Item $src $dest
}

# Read version from pubspec.yaml for info output.
$version = (Get-Content pubspec.yaml | Where-Object { $_ -match '^version:' }) -replace 'version:\s*', ''

Write-Host ""
Write-Host "OK -- release upload files ready (v$version):" -ForegroundColor Green
Write-Host "  Folder: $DestDir" -ForegroundColor Green
Write-Host ""
Get-ChildItem $DestDir | ForEach-Object {
    $sizeMB = [math]::Round($_.Length / 1MB, 1)
    Write-Host ("  {0,-32} {1,6} MB" -f $_.Name, $sizeMB)
}
Write-Host ""
Write-Host "Next step: drag these into a new (or edited) GitHub Release at" -ForegroundColor Cyan
Write-Host "  https://github.com/mfbilgin/barcode-boss/releases" -ForegroundColor Cyan
