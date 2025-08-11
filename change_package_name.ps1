# ================================
# Flutter(FVM) packageName / AppName / pubspec name / import path update
# ================================
$ErrorActionPreference = "Stop"

# ---- SETTINGS ----
$NEW_PACKAGE = "com.midashnt.homepage"     # new package name
$NEW_NAME    = "MiadsHnT"                  # new app display name
$NEW_IMPORT  = "midashnt_homepage"         # new pubspec.yaml name
$OLD_IMPORT  = "boilerplate"               # old pubspec.yaml name
# ------------------

# 실행 함수 (Windows/Mac/Linux 모두에서 동작)
function Run-FvmFlutter {
    param (
        [Parameter(Mandatory=$true)]
        [string[]] $ArgsList
    )
    & "fvm" "flutter" @ArgsList
}

Write-Host "PackageName: $NEW_PACKAGE"
Write-Host "AppName: $NEW_NAME"
Write-Host "pubspec.yaml name change: $OLD_IMPORT => $NEW_IMPORT"
Write-Host ""

# 1. pubspec.yaml 확인
$pubspecPath = Join-Path (Get-Location) "pubspec.yaml"
if (-not (Test-Path $pubspecPath)) {
    throw "pubspec.yaml not found in current folder."
}

# 2. Backup & name 변경
$timestamp = (Get-Date -Format 'yyyyMMdd_HHmmss')
$backup = Join-Path (Split-Path $pubspecPath -Parent) ("pubspec.yaml.bak_$timestamp")
Copy-Item $pubspecPath $backup -Force
$content = Get-Content -Raw -Encoding UTF8 $pubspecPath
if ($content -match "(?m)^\s*name:\s*.+$") {
    $newContent = $content -replace "(?m)^\s*name:\s*.+$", "name: $NEW_IMPORT"
    $newContent | Set-Content -Encoding UTF8 $pubspecPath
    Write-Host "pubspec.yaml name updated. Backup: $backup"
} else {
    throw "Could not find 'name:' line in pubspec.yaml"
}

# 4. rename / change_app_package_name 설치
Run-FvmFlutter @("pub", "add", "rename") | Out-Null
Run-FvmFlutter @("pub", "add", "change_app_package_name") | Out-Null

# 5. rename / change_app_package_name 실행
Run-FvmFlutter @("pub", "run", "change_app_package_name:main", $NEW_PACKAGE)
Run-FvmFlutter @("pub", "run", "rename", "setBundleId", "--targets", "ios,android", "--value", $NEW_PACKAGE)

# 6. Dart import 경로 변경
$targets = @()
foreach ($p in "lib","test","example") {
    if (Test-Path $p) { $targets += $p }
}
if ($targets.Count -gt 0) {
    $changed = 0
    Get-ChildItem -Recurse -Path $targets -Include *.dart -ErrorAction SilentlyContinue | ForEach-Object {
        $path = $_.FullName
        $text = Get-Content -Raw -Encoding UTF8 $path
        $replaced = $text -replace "package:$OLD_IMPORT\b", "package:$NEW_IMPORT"
        if ($replaced -ne $text) {
            $replaced | Set-Content -Encoding UTF8 $path
            $changed++
        }
    }
    Write-Host "Updated import paths in $changed dart files."
} else {
    Write-Host "No lib/test/example folder found, skipping import path update."
}

# 7. clean & pub get
Run-FvmFlutter @("clean") | Out-Null
Run-FvmFlutter @("pub", "get") | Out-Null

Write-Host "`nAll changes completed."


#$env:Path += ";C:\Users\MiDAS HnT\fvm\versions\3.32.7\bin" flutter 명령어 없을시 세팅
#flutter --version
# .\change_package_name.ps1 명령어로 ps1 파일 실행