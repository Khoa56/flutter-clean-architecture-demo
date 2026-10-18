param([string]$FlutterSdk = '')
$ErrorActionPreference = 'Stop'
Push-Location -LiteralPath $PSScriptRoot
try {
    foreach ($taskName in @('JAVA_HOME', 'ANDROID_HOME', 'GRADLE_USER_HOME')) {
        $taskValue = [Environment]::GetEnvironmentVariable($taskName, 'User')
        if ($taskValue) { Set-Item -LiteralPath "Env:\$taskName" -Value $taskValue }
    }
    if (-not $FlutterSdk -and -not (Get-Command flutter -ErrorAction SilentlyContinue)) {
        $taskBundled = Join-Path $PSScriptRoot '..\..\work\flutter-sdk'
        if (Test-Path -LiteralPath (Join-Path $taskBundled 'bin\flutter.bat')) {
            $FlutterSdk = (Resolve-Path -LiteralPath $taskBundled).Path
        }
    }
    $taskFlutter = if ($FlutterSdk) { Join-Path $FlutterSdk 'bin\flutter.bat' } else { 'flutter' }
    & $taskFlutter pub get
    if ($LASTEXITCODE -ne 0) { throw 'Khong tai duoc dependency.' }
    & $taskFlutter build apk --release
    if ($LASTEXITCODE -ne 0) { throw 'Build APK that bai. Kiem tra flutter doctor -v.' }
    Write-Host 'APK: build/app/outputs/flutter-apk/app-release.apk'
} finally { Pop-Location }
