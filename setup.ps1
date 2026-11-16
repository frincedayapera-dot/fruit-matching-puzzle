param(
    [string]$PackageName = "com.frinova.fruitmatchingpuzzle",
    [switch]$Run
)
# =====================================================================
#  Fruit Matching Puzzle - setup.ps1
#  Ginagawa: android folder, manifest, PACKAGE NAME (palit com.example),
#            paglipat ng MainActivity, app icon (puno ang tile), pub get
#
#  Patakbuhin sa loob ng project folder:
#     powershell -ExecutionPolicy Bypass -File .\setup.ps1
#  Kung kinuha na ang package name sa Play Console, ibang pangalan:
#     powershell -ExecutionPolicy Bypass -File .\setup.ps1 -PackageName com.frinova.fruitmatchpuzzle
# =====================================================================
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Step($t) { Write-Host ""; Write-Host "==> $t" -ForegroundColor Cyan }
function Read-Text($p) { return [System.IO.File]::ReadAllText((Resolve-Path $p).Path) }
function Write-Text($p, $text) {
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText((Resolve-Path $p).Path, $text, $enc)
}
function Write-Abs($full, $text) {
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($full, $text, $enc)
}

# ---------- 0. i-check ang package name ----------
if ($PackageName -notmatch '^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$') {
    throw "Hindi tamang package name: $PackageName  (hal. com.frinova.fruitmatchingpuzzle - lowercase, may tuldok)"
}
if ($PackageName -like "com.example*") {
    throw "Hindi pwede ang com.example sa Play Store. Gumamit ng ibang package name."
}
Write-Host "Package name: $PackageName" -ForegroundColor Yellow

# ---------- 1. android folder ----------
Step "1/6  Android folder"
if (-not (Test-Path "android")) {
    flutter create . --platforms=android --org com.frinova --project-name fruit_matching_puzzle
    if ($LASTEXITCODE -ne 0) { throw "flutter create ay nag-fail" }
} else {
    Write-Host "May android folder na. Laktawan."
}

# ---------- 2. test file ----------
Step "2/6  Ayusin ang test file"
if (-not (Test-Path "test")) { New-Item -ItemType Directory -Path "test" | Out-Null }
Set-Content -Path "test\widget_test.dart" -Value "void main() {}"

# ---------- 3. AndroidManifest.xml (main) ----------
Step "3/6  AndroidManifest.xml (internet, email, pangalan ng app)"
$manifestPath = "android\app\src\main\AndroidManifest.xml"
if (-not (Test-Path $manifestPath)) { throw "Hindi makita ang $manifestPath" }
$m = Read-Text $manifestPath
$idx = $m.IndexOf("<application")
if ($idx -lt 0) { throw "Walang <application sa manifest" }
$extra = ""
if ($m -notmatch 'android\.permission\.INTERNET') {
    $extra += '<uses-permission android:name="android.permission.INTERNET" />' + "`r`n    "
}
if ($m -notmatch 'android\.intent\.action\.SENDTO') {
    $extra += '<queries>' + "`r`n"
    $extra += '        <intent>' + "`r`n"
    $extra += '            <action android:name="android.intent.action.SENDTO" />' + "`r`n"
    $extra += '            <data android:scheme="mailto" />' + "`r`n"
    $extra += '        </intent>' + "`r`n"
    $extra += '    </queries>' + "`r`n    "
}
if ($extra -ne "") { $m = $m.Insert($idx, $extra) }
$labelRx = New-Object System.Text.RegularExpressions.Regex 'android:label="[^"]*"'
$m = $labelRx.Replace($m, 'android:label="Fruit Matching Puzzle"', 1)
Write-Text $manifestPath $m
Write-Host "OK: $manifestPath"

# ---------- 4. PACKAGE NAME (namespace + applicationId + MainActivity) ----------
Step "4/6  Package name -> $PackageName"
$gradle = $null
foreach ($f in @("android\app\build.gradle.kts", "android\app\build.gradle")) {
    if (Test-Path $f) { $gradle = $f; break }
}
if (-not $gradle) { throw "Walang build.gradle sa android\app" }
$isKts = $gradle.EndsWith(".kts")
$g = Read-Text $gradle

# 4a. kunin ang LUMANG pangalan
$oldNs = ""; $oldId = ""
$nsRx = New-Object System.Text.RegularExpressions.Regex 'namespace\s*=?\s*"([^"]*)"'
$idRx = New-Object System.Text.RegularExpressions.Regex 'applicationId\s*=?\s*"([^"]*)"'
$mm = $nsRx.Match($g); if ($mm.Success) { $oldNs = $mm.Groups[1].Value }
$mm = $idRx.Match($g); if ($mm.Success) { $oldId = $mm.Groups[1].Value }
if (-not $idRx.IsMatch($g)) { throw "Walang applicationId sa $gradle" }
Write-Host "Luma: namespace=[$oldNs]  applicationId=[$oldId]"

# 4b. gradle: namespace at applicationId
if ($isKts) { $nsRep = 'namespace = "' + $PackageName + '"'; $idRep = 'applicationId = "' + $PackageName + '"' }
else        { $nsRep = 'namespace "' + $PackageName + '"';   $idRep = 'applicationId "' + $PackageName + '"' }
if ($nsRx.IsMatch($g)) { $g = $nsRx.Replace($g, $nsRep, 1) }
$g = $idRx.Replace($g, $idRep, 1)
Write-Text $gradle $g

# 4c. palitan ang lumang pangalan sa ibang files (manifest, kt, java, xml)
$olds = @($oldNs, $oldId) | Where-Object { $_ -and ($_ -ne $PackageName) } | Select-Object -Unique
if ($olds.Count -gt 0) {
    Get-ChildItem -Path "android\app\src" -Recurse -File -Include *.xml, *.kt, *.java | ForEach-Object {
        $t = [System.IO.File]::ReadAllText($_.FullName)
        $n = $t
        foreach ($o in $olds) { $n = $n.Replace($o, $PackageName) }
        if ($n -ne $t) { Write-Abs $_.FullName $n; Write-Host "  na-update: $($_.Name)" }
    }
}

# 4d. ilipat ang MainActivity sa bagong folder at ayusin ang "package" line
$movedAny = $false
foreach ($rootRel in @("android\app\src\main\kotlin", "android\app\src\main\java")) {
    if (-not (Test-Path $rootRel)) { continue }
    $root = (Resolve-Path $rootRel).Path
    $found = Get-ChildItem -Path $root -Recurse -File -Include MainActivity.kt, MainActivity.java
    foreach ($f in $found) {
        $text = [System.IO.File]::ReadAllText($f.FullName)
        $text = [regex]::Replace($text, '(?m)^\s*package\s+[\w\.]+', "package $PackageName", 1)
        $newDir = Join-Path $root ($PackageName -replace '\.', '\')
        $newFile = Join-Path $newDir $f.Name
        if ($f.FullName -ne $newFile) {
            New-Item -ItemType Directory -Force -Path $newDir | Out-Null
            Write-Abs $newFile $text
            $oldDir = $f.DirectoryName
            Remove-Item $f.FullName -Force
            # burahin ang mga walang lamang lumang folder
            while ($oldDir -ne $root -and (Test-Path $oldDir) -and -not (Get-ChildItem -Path $oldDir -Force)) {
                Remove-Item $oldDir -Force
                $oldDir = Split-Path $oldDir -Parent
            }
            Write-Host "  nailipat: $($f.Name) -> $newDir"
        } else {
            Write-Abs $newFile $text
        }
        $movedAny = $true
    }
}
if (-not $movedAny) { Write-Host "BABALA: walang MainActivity na nakita (tingnan ang android\app\src\main\kotlin)" -ForegroundColor Yellow }

# ---------- 5. packages ----------
Step "5/6  flutter clean + pub get"
flutter clean
flutter pub get
if ($LASTEXITCODE -ne 0) { throw "flutter pub get ay nag-fail" }

# ---------- 6. app icon (puno ang tile, tulad ng Purcafe) ----------
Step "6/6  App icon (puno ang tile)"
if (-not (Test-Path "android_res")) { throw "Walang android_res folder" }
Copy-Item "android_res\*" -Destination "android\app\src\main\res" -Recurse -Force
Write-Host "OK: nakopya ang icon sa android\app\src\main\res"

Write-Host ""
Write-Host "TAPOS NA ANG SETUP!  Package name: $PackageName" -ForegroundColor Green
Write-Host "Mga device na nakikita ng Flutter:"
flutter devices
Write-Host ""
Write-Host "1) Burahin ang LUMANG app sa phone (com.example...) para lumabas ang bagong icon."
Write-Host "2) I-run:  flutter run -d <device id>"
Write-Host "3) Para sa Play Store:  powershell -ExecutionPolicy Bypass -File .\release.ps1"

if ($Run) { flutter run }
