param([string]$FlutterSdk = '')
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
    & $taskFlutter pub get
    if ($LASTEXITCODE -ne 0) { throw 'pub get that bai.' }
    & $taskFlutter analyze
    if ($LASTEXITCODE -ne 0) { throw 'Phan tich ma chua dat.' }
    & $taskFlutter test --coverage
    if ($LASTEXITCODE -ne 0) { throw 'Kiem thu chua dat.' }
    Write-Host 'Hoan tat. Coverage: coverage/lcov.info'
} finally { Pop-Location }
