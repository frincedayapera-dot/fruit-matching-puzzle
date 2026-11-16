# Fruit Matching Puzzle - lahat ng command

## A. Ilagay ang code + palitan ang package name + app icon
    $proj = "C:\Users\User\OneDrive\Desktop\fruit_matching_puzzle"
    Expand-Archive "$env:USERPROFILE\Downloads\fruit_matching_puzzle.zip" "$env:USERPROFILE\Downloads\fm_new" -Force
    Copy-Item "$env:USERPROFILE\Downloads\fm_new\fruit_matching_puzzle\*" $proj -Recurse -Force
    Set-Location $proj
    powershell -ExecutionPolicy Bypass -File .\setup.ps1

Package name = com.frinova.fruitmatchingpuzzle. Kung kinuha na ito sa Play Console:
    powershell -ExecutionPolicy Bypass -File .\setup.ps1 -PackageName com.frinova.fruitmatchpuzzle

## B. Subukan sa phone
    & "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" uninstall com.example.fruit_matching_puzzle
    flutter devices
    flutter run -d <device id>

## C. Signed AAB + APK para sa Play Store
    powershell -ExecutionPolicy Bypass -File .\release.ps1
- AAB: build\app\outputs\bundle\release\app-release.aab  (i-upload sa Play Console)
- APK: build\app\outputs\flutter-apk\app-release.apk

Sa bawat bagong upload, dagdagan ang numero pagkatapos ng + sa `version:` ng pubspec.yaml (hal. 1.2.0+4).
ITABI ang upload-keystore.jks (sa user folder mo) at ang password nito.
