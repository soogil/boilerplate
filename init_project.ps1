# 사용법:
# ./init_project.ps1 "My App Name" com.company.myapp my_app
# "앱이름" 번들ID pubspec_name 순서

param(
    [Parameter(Mandatory = $true)][string]$AppName,
    [Parameter(Mandatory = $true)][string]$BundleId,
    [Parameter(Mandatory = $true)][string]$ProjectName
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Flutter project initialization started..."

# --------------------------------------------------
# 1) Install rename as dev dependency
# --------------------------------------------------
Write-Host "🔧 Installing rename (dev dependency)"
flutter pub add rename --dev

# --------------------------------------------------
# 2) Set app name / bundle id (rename 3.x syntax)
# --------------------------------------------------
Write-Host "✏️ Setting app name"
dart run rename setAppName --value "$AppName"

Write-Host "✏️ Setting bundle id"
dart run rename setBundleId --value "$BundleId"

# --------------------------------------------------
# 3) Update pubspec.yaml (name / description)
# --------------------------------------------------
Write-Host "✏️ Updating pubspec.yaml"

$pubspec = "pubspec.yaml"
if (!(Test-Path $pubspec)) {
    throw "pubspec.yaml not found. Run this script from project root."
}

$content = Get-Content -Path $pubspec -Raw
$opt = [System.Text.RegularExpressions.RegexOptions]::Multiline

# Replace name
$content = [System.Text.RegularExpressions.Regex]::Replace(
    $content,
    '^\s*name\s*:\s*.*$',
    "name: $ProjectName",
    $opt
)

# Replace description
$content = [System.Text.RegularExpressions.Regex]::Replace(
    $content,
    '^\s*description\s*:\s*.*$',
    "description: `"$AppName`"",
    $opt
)

Set-Content -Path $pubspec -Value $content -Encoding UTF8

# --------------------------------------------------
# 4) Update Dart package imports (lib / test / integration_test)
# --------------------------------------------------
Write-Host "🔁 Updating Dart import paths"

$oldPackage = "boilerplate"   # 템플릿 기본 패키지명
$newPackage = $ProjectName

$targets = @("lib", "test", "integration_test", "example") | Where-Object { Test-Path $_ }

foreach ($dir in $targets) {
    $dartFiles = Get-ChildItem -Path $dir -Recurse -Filter *.dart -File
    foreach ($file in $dartFiles) {
        $src = Get-Content -Path $file.FullName -Raw
        $dst = $src.Replace("package:$oldPackage/", "package:$newPackage/")
        if ($src -ne $dst) {
            Set-Content -Path $file.FullName -Value $dst -Encoding UTF8
        }
    }
}

# --------------------------------------------------
# 5) Detect Android source root (kotlin / java)
# --------------------------------------------------
Write-Host "🔍 Detecting Android source root"

$kotlinRoot = "android/app/src/main/kotlin"
$javaRoot   = "android/app/src/main/java"

if (Test-Path $kotlinRoot) {
    $androidRoot = $kotlinRoot
    $useKotlin = $true
} elseif (Test-Path $javaRoot) {
    $androidRoot = $javaRoot
    $useKotlin = $false
} else {
    throw "Android source root not found (kotlin/java)."
}

Write-Host "➡ Android source root: $androidRoot"

# --------------------------------------------------
# 6) Create target package directory
# --------------------------------------------------
$packagePath = $BundleId -replace "\.", "/"
$targetPath = Join-Path $androidRoot $packagePath
New-Item -ItemType Directory -Force -Path $targetPath | Out-Null

# --------------------------------------------------
# 7) Move existing MainActivity if exists
# --------------------------------------------------
Write-Host "🔎 Searching MainActivity"

if ($useKotlin) {
    $oldMain = Get-ChildItem -Path $androidRoot -Recurse -Filter "MainActivity.kt" -ErrorAction SilentlyContinue | Select-Object -First 1
    $destFile = "MainActivity.kt"
} else {
    $oldMain = Get-ChildItem -Path $androidRoot -Recurse -Filter "MainActivity.java" -ErrorAction SilentlyContinue | Select-Object -First 1
    $destFile = "MainActivity.java"
}

if ($oldMain) {
    Write-Host "🔄 Moving MainActivity to new package"
    Move-Item -Path $oldMain.FullName -Destination (Join-Path $targetPath $destFile) -Force
} else {
    Write-Host "⚠️ MainActivity not found. It will be created."
}

# --------------------------------------------------
# 8) Create / overwrite MainActivity
# --------------------------------------------------
Write-Host "🖋 Creating MainActivity"

if ($useKotlin) {
    $mainContent = @"
package $BundleId

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
}
"@
    $mainPath = Join-Path $targetPath "MainActivity.kt"
} else {
    $mainContent = @"
package $BundleId;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
}
"@
    $mainPath = Join-Path $targetPath "MainActivity.java"
}

Set-Content -Path $mainPath -Value $mainContent -Encoding UTF8

# --------------------------------------------------
# 9) Fix AndroidManifest.xml MainActivity reference
# --------------------------------------------------
Write-Host "🛠 Patching AndroidManifest.xml"

$manifest = "android/app/src/main/AndroidManifest.xml"
if (Test-Path $manifest) {
    $m = Get-Content -Path $manifest -Raw
    $m = [System.Text.RegularExpressions.Regex]::Replace(
        $m,
        'android:name="[^"]*MainActivity"',
        'android:name=".MainActivity"',
        $opt
    )
    Set-Content -Path $manifest -Value $m -Encoding UTF8
}

# --------------------------------------------------
# 10) Fix applicationId in build.gradle
# --------------------------------------------------
Write-Host "🛠 Patching build.gradle applicationId"

$gradle = "android/app/build.gradle"
if (Test-Path $gradle) {
    $g = Get-Content -Path $gradle -Raw
    $g = [System.Text.RegularExpressions.Regex]::Replace(
        $g,
        'applicationId\s+"[^"]+"',
        "applicationId `"$BundleId`"",
        $opt
    )
    Set-Content -Path $gradle -Value $g -Encoding UTF8
}

# --------------------------------------------------
# 11) Clean & get packages
# --------------------------------------------------
Write-Host "🧹 flutter clean"
flutter clean

Write-Host "📦 flutter pub get"
flutter pub get

Write-Host ""
Write-Host "🎉 Initialization completed successfully!"
Write-Host "App Name      : $AppName"
Write-Host "Bundle ID     : $BundleId"
Write-Host "Package Name  : $ProjectName"
Write-Host "MainActivity  : $mainPath"
