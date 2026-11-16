param([switch]$ApkOnly)
# =====================================================================
#  Fruit Matching Puzzle - release.ps1
#  Gumagawa ng signing key, nagse-set ng signing sa Gradle, at nagbi-build
#  ng SIGNED app bundle (.aab) at APK.
#     powershell -ExecutionPolicy Bypass -File .\release.ps1
# =====================================================================
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Step($t) { Write-Host ""; Write-Host "==> $t" -ForegroundColor Cyan }
function Read-Text($p) { return [System.IO.File]::ReadAllText((Resolve-Path $p).Path) }
function Write-Text($p, $text) {
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText((Resolve-Path $p).Path, $text, $enc)
}
function Plain($secure) {
    $b = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try { return [Runtime.InteropServices.Marshal]::PtrToStringAuto($b) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b) }
}

$gradlePath = "android\app\build.gradle.kts"
$propsPath  = "android\key.properties"
$ksPath     = Join-Path $env:USERPROFILE "upload-keystore.jks"
if (-not (Test-Path $gradlePath)) { throw "Hindi makita ang $gradlePath. Patakbuhin muna ang setup.ps1" }

# ---------- 1. keytool ----------
Step "1/4  Hanapin ang keytool"
$keytool = $null
$cmd = Get-Command keytool -ErrorAction SilentlyContinue
if ($cmd) { $keytool = $cmd.Source }
if (-not $keytool) {
    foreach ($c in @("C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe",
                     "C:\Program Files\Android\Android Studio Preview\jbr\bin\keytool.exe")) {
        if (Test-Path $c) { $keytool = $c; break }
    }
}
if (-not $keytool) {
    $hit = Get-ChildItem "C:\Program Files\Android" -Recurse -Filter keytool.exe -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($hit) { $keytool = $hit.FullName }
}
if (-not $keytool) { throw "Walang keytool. I-install ang Android Studio (kasama ang JDK) o ang JDK." }
Write-Host "keytool: $keytool"

# ---------- 2. signing key + key.properties ----------
Step "2/4  Signing key (upload-keystore.jks)"
if (-not (Test-Path $ksPath)) {
    Write-Host "Gagawa ng bagong signing key sa: $ksPath"
    Write-Host "ITABI ang file na ito at ang password. Kapag nawala, hindi ka na makakapag-update ng app." -ForegroundColor Yellow
    $s1 = Read-Host "Maglagay ng password (hindi bababa sa 6 na character)" -AsSecureString
    $s2 = Read-Host "Ulitin ang password" -AsSecureString
    $pw = Plain $s1
    if ($pw -ne (Plain $s2) -or $pw.Length -lt 6) { throw "Hindi pareho o masyadong maikli ang password" }
    & $keytool -genkeypair -v -keystore $ksPath -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload -storepass $pw -keypass $pw -dname "CN=Frinova, OU=Games, O=Frinova"
    if ($LASTEXITCODE -ne 0) { throw "Nag-fail ang paggawa ng key" }
} else {
    Write-Host "May key na: $ksPath"
    if (-not (Test-Path $propsPath)) {
        $pw = Plain (Read-Host "Ilagay ang password ng key" -AsSecureString)
    }
}
if (-not (Test-Path $propsPath)) {
    $storeFwd = $ksPath -replace '\\', '/'
    $lines = @("storePassword=$pw", "keyPassword=$pw", "keyAlias=upload", "storeFile=$storeFwd")
    [System.IO.File]::WriteAllText((Join-Path (Resolve-Path "android").Path "key.properties"), ($lines -join "`r`n") + "`r`n", (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "OK: android\key.properties"
}
# huwag i-commit ang secrets
$gi = "android\.gitignore"
if (Test-Path $gi) {
    $gt = Read-Text $gi
    if ($gt -notmatch 'key\.properties') { Write-Text $gi ($gt.TrimEnd() + "`r`nkey.properties`r`n*.jks`r`n") }
}

# ---------- 3. i-set ang signing sa build.gradle.kts ----------
Step "3/4  Signing config sa build.gradle.kts"
$g = Read-Text $gradlePath
if ($g -notmatch 'keystoreProperties') {
    if ($g -notmatch '(?m)^import java\.util\.Properties') {
        $g = "import java.util.Properties`r`nimport java.io.FileInputStream`r`n`r`n" + $g
    }
    $load = @'
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}


'@
    $am = [regex]::Match($g, '(?m)^android\s*\{')
    if (-not $am.Success) { throw "Walang android { block sa $gradlePath" }
    $g = $g.Insert($am.Index, $load)

    $sign = @'
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

'@
    $bm = [regex]::Match($g, '(?m)^[ \t]*buildTypes\s*\{')
    if (-not $bm.Success) { throw "Walang buildTypes block sa $gradlePath" }
    $g = $g.Insert($bm.Index, $sign)
    $g = $g.Replace('signingConfig = signingConfigs.getByName("debug")', 'signingConfig = signingConfigs.getByName("release")')
    Write-Text $gradlePath $g
    Write-Host "OK: na-set ang release signing"
} else {
    Write-Host "May signing config na. Laktawan."
}
if ((Read-Text $gradlePath) -notmatch 'getByName\("release"\)') {
    Write-Host "BABALA: tingnan ang buildTypes > release at ilagay: signingConfig = signingConfigs.getByName(`"release`")" -ForegroundColor Yellow
}

# ---------- 4. build ----------
Step "4/4  Build (signed)"
flutter clean
flutter pub get
if ($LASTEXITCODE -ne 0) { throw "flutter pub get ay nag-fail" }
if (-not $ApkOnly) {
    flutter build appbundle --release
    if ($LASTEXITCODE -ne 0) { throw "Nag-fail ang appbundle build" }
}
flutter build apk --release
if ($LASTEXITCODE -ne 0) { throw "Nag-fail ang apk build" }

Write-Host ""
Write-Host "TAPOS NA!" -ForegroundColor Green
$aab = "build\app\outputs\bundle\release\app-release.aab"
$apk = "build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $aab) { Write-Host "AAB (i-upload sa Play Console): $((Resolve-Path $aab).Path)" }
if (Test-Path $apk) { Write-Host "APK (pang-install sa phone):     $((Resolve-Path $apk).Path)" }
Write-Host "Tandaan: dagdagan ang numero pagkatapos ng + sa version ng pubspec.yaml (hal. 1.2.0+4) sa bawat bagong upload."
