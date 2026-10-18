param([string]$FlutterSdk = '', [int]$Port = 8788)
$ErrorActionPreference = 'Stop'
Push-Location -LiteralPath $PSScriptRoot
try {
    if (-not $FlutterSdk -and -not (Get-Command flutter -ErrorAction SilentlyContinue)) {
        $taskBundled = Join-Path $PSScriptRoot '..\..\work\flutter-sdk'
        if (Test-Path -LiteralPath (Join-Path $taskBundled 'bin\flutter.bat')) {
            $FlutterSdk = (Resolve-Path -LiteralPath $taskBundled).Path
        }
    }
    $taskFlutter = if ($FlutterSdk) { Join-Path $FlutterSdk 'bin\flutter.bat' } else { 'flutter' }
    $taskDart = if ($FlutterSdk) { Join-Path $FlutterSdk 'bin\dart.bat' } else { 'dart' }
    & $taskFlutter pub get
    if ($LASTEXITCODE -ne 0) { throw 'Khong tai duoc dependency.' }
    & $taskFlutter build web --release --no-web-resources-cdn '--dart-define=API_BASE_URL=/api/'
    if ($LASTEXITCODE -ne 0) { throw 'Build Web that bai.' }
    & $taskDart run tool/demo_server.dart "--port=$Port"
    if ($LASTEXITCODE -ne 0) { throw 'Khong khoi dong duoc may chu. Kiem tra cong dang duoc dung.' }
} finally { Pop-Location }
