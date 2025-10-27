# Windows Setup Script by Pablo
# Ejecutar con PowerShell (Admin si es posible)

Write-Host "=== Windows Setup Script by Pablo v 1.0 ===" -ForegroundColor Green
function Show-Menu {
    param (
        [string]$Title,
        [string[]]$Options
    )
    Write-Host "`n$Title" -ForegroundColor Yellow
    for ($i = 0; $i -lt $Options.Length; $i++) {
        Write-Host "  $($i+1)) $($Options[$i])"
    }
    do {
        $choice = Read-Host "Selecciona una opción (1-$($Options.Length))"
    } while ($choice -notmatch '^[1-9]\d*$' -or $choice -lt 1 -or $choice -gt $Options.Length)
    return $Options[$choice - 1]
}

function Require-Admin {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "[!] Este script necesita permisos de administrador." -ForegroundColor Red
        Write-Host "[!] Cierra esta ventana y ejecuta PowerShell como administrador para continuar." -ForegroundColor Yellow
        exit
    }
}

Require-Admin
# Configs
Write-Host "[+] Clonando configuraciones de Windows..." -ForegroundColor Cyan
$repoPath = "$env:TEMP\windots"
if (Test-Path $repoPath) { Remove-Item -Recurse -Force $repoPath }
git clone https://github.com/Pblo16/windots.git $repoPath

$yasbConfig = "$env:USERPROFILE\.config\yasb"
$glazeConfig = "$env:USERPROFILE\.glzr\glazewm"

New-Item -ItemType Directory -Force -Path $yasbConfig | Out-Null
New-Item -ItemType Directory -Force -Path $glazeConfig | Out-Null

Copy-Item "$repoPath\yasb\*" $yasbConfig -Recurse -Force
Copy-Item "$repoPath\glazewm\*" $glazeConfig -Recurse -Force

Write-Host "[✓] Configuraciones copiadas correctamente." -ForegroundColor Green

# WSL
$usarWSL = Show-Menu "¿Quieres usar WSL?" @("Sí", "No")
if ($usarWSL -eq "Sí") {
    Write-Host "[+] Revisando WSL..." -ForegroundColor Cyan
    $wslStatus = wsl --status 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[+] Instalando WSL2 con Ubuntu..." -ForegroundColor Cyan
        wsl --install -d Ubuntu
    }
    else { Write-Host "[✓] WSL ya está instalado." -ForegroundColor Green }

    Write-Host "[+] Ejecutando setup dentro de Ubuntu..." -ForegroundColor Cyan
    wsl -d Ubuntu -e bash -c "curl -O https://raw.githubusercontent.com/Pblo16/pablo.dots/refs/heads/main/install.sh && chmod +x install.sh && bash install.sh"
}

# Ejecutar variables de entorno personalizadas desde el repo clonado
try {
    $warpPath = Join-Path $env:USERPROFILE "AppData\Local\Programs\Warp"
    $customEnvVars = @{
        "Path" = if ($env:Path) { $env:Path + ";" + $warpPath } else { $warpPath }
    }
    # Exportar variables
    foreach ($key in $customEnvVars.Keys) {
        [Environment]::SetEnvironmentVariable($key, $customEnvVars[$key], "User")
        Write-Host "[+] Variable de entorno configurada: $key" -ForegroundColor Cyan
    }

}
catch {
    Write-Host "[!] Error ejecutando en-vars" -ForegroundColor Red
}

Write-Host ""

Write-Host "✅ Instalación completa. Reinicia el sistema para aplicar los cambios." -ForegroundColor Green
