param([string]$Device = '', [switch]$Sample, [string]$FlutterSdk = '')
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
    if ($LASTEXITCODE -ne 0) { throw 'Khong tai duoc dependency.' }
    $taskArgs = @('run')
    if ($Device) { $taskArgs += @('-d', $Device) }
    if ($Sample) { $taskArgs += '--dart-define=USE_FIXTURE=true' }
    & $taskFlutter @taskArgs
    if ($LASTEXITCODE -ne 0) { throw 'Chay demo that bai. Kiem tra flutter doctor -v.' }
} finally { Pop-Location }
