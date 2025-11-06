# Script de prueba para verificar la instalación de AutoHotkey
# Ejecuta este script para verificar que los módulos de AHK están correctamente configurados

Write-Host "=== Windots AHK - Verificación de instalación ===" -ForegroundColor Green
Write-Host ""

$ahkConfig = "$env:USERPROFILE\.config\ahk"
$mainScript = Join-Path $ahkConfig "Main.ahk"
$shortcutsModule = Join-Path $ahkConfig "modules\Shortcuts.ahk"
$windowManagerModule = Join-Path $ahkConfig "modules\WindowManager.ahk"
$startupFolder = [Environment]::GetFolderPath('Startup')
$shortcutPath = Join-Path $startupFolder "Windots-AHK.lnk"

$allOk = $true

# Verificar carpeta de configuración
Write-Host "Verificando carpeta de configuración..." -ForegroundColor Cyan
if (Test-Path $ahkConfig) {
  Write-Host "  ✓ Carpeta de configuración existe: $ahkConfig" -ForegroundColor Green
}
else {
  Write-Host "  ✗ Carpeta de configuración NO existe: $ahkConfig" -ForegroundColor Red
  $allOk = $false
}

# Verificar script principal
Write-Host "Verificando script principal..." -ForegroundColor Cyan
if (Test-Path $mainScript) {
  Write-Host "  ✓ Main.ahk encontrado" -ForegroundColor Green
}
else {
  Write-Host "  ✗ Main.ahk NO encontrado" -ForegroundColor Red
  $allOk = $false
}

# Verificar módulos
Write-Host "Verificando módulos..." -ForegroundColor Cyan
if (Test-Path $shortcutsModule) {
  Write-Host "  ✓ Shortcuts.ahk encontrado" -ForegroundColor Green
}
else {
  Write-Host "  ✗ Shortcuts.ahk NO encontrado" -ForegroundColor Red
  $allOk = $false
}

if (Test-Path $windowManagerModule) {
  Write-Host "  ✓ WindowManager.ahk encontrado" -ForegroundColor Green
}
else {
  Write-Host "  ✗ WindowManager.ahk NO encontrado" -ForegroundColor Red
  $allOk = $false
}

# Verificar acceso directo en inicio
Write-Host "Verificando acceso directo en inicio..." -ForegroundColor Cyan
if (Test-Path $shortcutPath) {
  Write-Host "  ✓ Acceso directo creado en: $shortcutPath" -ForegroundColor Green
}
else {
  Write-Host "  ✗ Acceso directo NO encontrado en: $shortcutPath" -ForegroundColor Yellow
  Write-Host "    Los scripts no se ejecutarán automáticamente al inicio" -ForegroundColor Yellow
}

# Verificar si AutoHotkey está instalado
Write-Host "Verificando instalación de AutoHotkey..." -ForegroundColor Cyan
$ahkInstalled = $false
$ahkPaths = @(
  "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey.exe",
  "$env:ProgramFiles\AutoHotkey\AutoHotkey64.exe",
  "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey.exe"
)

foreach ($path in $ahkPaths) {
  if (Test-Path $path) {
    Write-Host "  ✓ AutoHotkey encontrado en: $path" -ForegroundColor Green
    $ahkInstalled = $true
    break
  }
}

if (-not $ahkInstalled) {
  Write-Host "  ✗ AutoHotkey v2.0 NO está instalado" -ForegroundColor Red
  Write-Host "    Descárgalo desde: https://www.autohotkey.com/" -ForegroundColor Yellow
  $allOk = $false
}

# Verificar si los scripts están en ejecución
Write-Host "Verificando si los scripts están en ejecución..." -ForegroundColor Cyan
$ahkProcess = Get-Process -Name "AutoHotkey*" -ErrorAction SilentlyContinue
if ($ahkProcess) {
  Write-Host "  ✓ AutoHotkey está en ejecución" -ForegroundColor Green
  Write-Host "    Procesos activos: $($ahkProcess.Count)" -ForegroundColor Gray
}
else {
  Write-Host "  ⚠ AutoHotkey NO está en ejecución" -ForegroundColor Yellow
  Write-Host "    Los atajos no estarán disponibles hasta que ejecutes Main.ahk" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Resumen ===" -ForegroundColor Yellow
if ($allOk -and $ahkInstalled) {
  Write-Host "✓ Instalación completa y correcta" -ForegroundColor Green
  Write-Host ""
  if (-not $ahkProcess) {
    Write-Host "Para activar los atajos ahora, ejecuta:" -ForegroundColor Cyan
    Write-Host "  Start-Process '$mainScript'" -ForegroundColor White
  }
}
else {
  Write-Host "✗ Se encontraron problemas en la instalación" -ForegroundColor Red
  Write-Host "  Ejecuta setup.ps1 para corregir los problemas" -ForegroundColor Yellow
}

Write-Host ""
