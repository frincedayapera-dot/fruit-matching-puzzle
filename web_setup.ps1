param([switch]$SkipBuild)
# =====================================================================
#  Fruit Matching Puzzle - web_setup.ps1
#  Inihahanda ang project para sa WEBSITE (GitHub Pages)
#     powershell -ExecutionPolicy Bypass -File .\web_setup.ps1
# =====================================================================
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Step($t) { Write-Host ""; Write-Host "==> $t" -ForegroundColor Cyan }
function Read-Text($p) { return [System.IO.File]::ReadAllText((Resolve-Path $p).Path) }
function Write-Text($p, $text) {
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText((Resolve-Path $p).Path, $text, $enc)
}

Step "1/5  Web support"
if (-not (Test-Path "web")) {
    flutter create . --platforms=web --project-name fruit_matching_puzzle
    if ($LASTEXITCODE -ne 0) { throw "flutter create ay nag-fail" }
} else { Write-Host "May web folder na. Laktawan." }
if (-not (Test-Path "test")) { New-Item -ItemType Directory -Path "test" | Out-Null }
Set-Content -Path "test\widget_test.dart" -Value "void main() {}"

Step "2/5  Icon at pangalan ng website"
if (Test-Path "web_res") { Copy-Item "web_res\*" -Destination "web" -Recurse -Force }

$idxPath = "web\index.html"
$h = Read-Text $idxPath
$h = [regex]::Replace($h, '<title>[^<]*</title>', '<title>Fruit Matching Puzzle</title>', 1)
$h = [regex]::Replace($h, '(apple-mobile-web-app-title"\s+content=")[^"]*(")', '${1}Fruit Match${2}', 1)
$h = [regex]::Replace($h, '(<meta name="description" content=")[^"]*(")', '${1}A fun fruit memory matching game. Match the fruits, beat the clock and collect stars!${2}', 1)
Write-Text $idxPath $h

$manPath = "web\manifest.json"
$j = Read-Text $manPath
$j = [regex]::Replace($j, '"name":\s*"[^"]*"', '"name": "Fruit Matching Puzzle"', 1)
$j = [regex]::Replace($j, '"short_name":\s*"[^"]*"', '"short_name": "Fruit Match"', 1)
$j = [regex]::Replace($j, '"background_color":\s*"[^"]*"', '"background_color": "#2A1810"', 1)
$j = [regex]::Replace($j, '"theme_color":\s*"[^"]*"', '"theme_color": "#D98E4F"', 1)
$j = [regex]::Replace($j, '"description":\s*"[^"]*"', '"description": "A fun fruit memory matching game."', 1)
Write-Text $manPath $j
Write-Host "OK: web\index.html at web\manifest.json"

Step "3/5  GitHub Actions workflow"
New-Item -ItemType Directory -Force -Path ".github\workflows" | Out-Null
Copy-Item "tools\deploy.yml" -Destination ".github\workflows\deploy.yml" -Force
Write-Host "OK: .github\workflows\deploy.yml"

Step "4/5  flutter pub get"
flutter pub get
if ($LASTEXITCODE -ne 0) { throw "flutter pub get ay nag-fail" }

Step "5/5  Test build ng website"
if (-not $SkipBuild) {
    flutter build web --release
    if ($LASTEXITCODE -ne 0) { throw "Nag-fail ang web build" }
    Write-Host "OK: build\web"
}

Write-Host ""
Write-Host "TAPOS NA!" -ForegroundColor Green
Write-Host "Subukan sa browser:  flutter run -d chrome"
Write-Host "Susunod: i-push sa GitHub (tingnan ang WEB_DEPLOY.md)"
