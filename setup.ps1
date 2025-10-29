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
# Variables para control de sobrescritura entre llamadas
$script:OverwriteAll = $false
$script:SkipAll = $false

# Función de copia que pregunta si debe sobrescribir archivos existentes
function Copy-WithPrompt {
    param (
        [Parameter(Mandatory=$true)][string]$Source,
        [Parameter(Mandatory=$true)][string]$Destination
    )

    if (-not (Test-Path $Destination)) {
        New-Item -ItemType Directory -Force -Path $Destination | Out-Null
    }

    # Normalizar base del origen (quitar posible "\\*" o "*")
    $baseSource = $Source -replace '\\\*$','' -replace '\*$',''

    # Mostrar info de qué base de origen y destino se van a procesar
    $rootName = Split-Path $baseSource -Leaf
    Write-Host "Copiando carpeta: $rootName -> $Destination" -ForegroundColor Cyan

    # Crear subdirectorios primero
    $dirs = Get-ChildItem -Path $baseSource -Recurse -Force -Directory -ErrorAction SilentlyContinue
    foreach ($d in $dirs) {
        $rel = $d.FullName.Substring($baseSource.Length).TrimStart('\','/')
        $destDir = Join-Path $Destination $rel
        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Force -Path $destDir | Out-Null }
    }

    # Copiar ficheros preguntando cuando existe el destino
    # Ordenar y hacer únicos por FullName para evitar prompts dobles
    $files = Get-ChildItem -Path $baseSource -Recurse -Force -File -ErrorAction SilentlyContinue | Sort-Object -Property FullName -Unique
    $total = $files.Count
    for ($i = 0; $i -lt $files.Count; $i++) {
        $f = $files[$i]
        $rel = $f.FullName.Substring($baseSource.Length).TrimStart('\','/')
        $destFile = Join-Path $Destination $rel
        $index = $i + 1

        if (Test-Path $destFile) {
            if ($script:OverwriteAll) { Copy-Item -Path $f.FullName -Destination $destFile -Force; continue }
            if ($script:SkipAll) { continue }

            while ($true) {
                # Mostrar rutas completas y progreso para que el usuario sepa exactamente qué archivo se está pidiendo
                Write-Host "[$index/$total] Origen: $($f.FullName)" -ForegroundColor Yellow
                Write-Host "[$index/$total] Destino: $destFile" -ForegroundColor Yellow
                $ans = Read-Host "Sobrescribir? [S/N/A/I/C]"
                switch ($ans.ToUpper()) {
                    'S' { Copy-Item -Path $f.FullName -Destination $destFile -Force; break }
                    'N' { break }
                    'A' { $script:OverwriteAll = $true; Copy-Item -Path $f.FullName -Destination $destFile -Force; break }
                    'I' { $script:SkipAll = $true; break }
                    'C' { throw "Operacion cancelada por el usuario." }
                    Default { Write-Host "Respuesta no valida. Usa S, N, A, I o C." -ForegroundColor Yellow }
                }
            }
        }
        else {
            Copy-Item -Path $f.FullName -Destination $destFile -Force
        }
    }
}
# Configs
Write-Host "[+] Clonando configuraciones de Windows..." -ForegroundColor Cyan
$repoPath = "$env:TEMP\windots"
if (Test-Path $repoPath) { Remove-Item -Recurse -Force $repoPath }
git clone https://github.com/Pblo16/windots.git $repoPath

$yasbConfig = "$env:USERPROFILE\.config\yasb"
$mondrianConfig = "$env:USERPROFILE\.config\mondrian"
$ohmyposhConfig = "$env:USERPROFILE\.oh-my-posh"
$weztermConfig = "$env:USERPROFILE\.config\wezterm"

New-Item -ItemType Directory -Force -Path $yasbConfig | Out-Null
New-Item -ItemType Directory -Force -Path $mondrianConfig | Out-Null
New-Item -ItemType Directory -Force -Path $ohmyposhConfig | Out-Null
New-Item -ItemType Directory -Force -Path $weztermConfig | Out-Null

# Copiar configuraciones con prompt si el archivo ya existe
Copy-WithPrompt "$repoPath\yasb\*" $yasbConfig
Copy-WithPrompt "$repoPath\mondrian\*" $mondrianConfig
Copy-WithPrompt "$repoPath\oh-my-posh\*" $ohmyposhConfig
Copy-WithPrompt "$repoPath\wezterm\*" $weztermConfig

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
