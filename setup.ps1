# ===============================
# Windows Setup Script by Pablo
# Autoactualizable + Interactivo
# ===============================

# --- Configuración de URLs ---
$repoSetupUrl = "https://raw.githubusercontent.com/Pblo16/windots/main/setup.ps1"
$repoScriptsBase = "https://raw.githubusercontent.com/Pblo16/windots/main/scripts/"
$tempDir = "$env:TEMP\windots"

# --- Autoactualización ---
function AutoUpdate {
    Write-Host "[~] Verificando actualización del instalador..." -ForegroundColor Cyan
    try {
        $tempSetup = "$tempDir\setup-latest.ps1"
        New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
        Invoke-WebRequest -Uri $repoSetupUrl -OutFile $tempSetup -UseBasicParsing
        if (Test-Path $PSCommandPath) {
            $localHash = Get-FileHash $PSCommandPath
            $remoteHash = Get-FileHash $tempSetup
            if ($localHash.Hash -ne $remoteHash.Hash) {
                Write-Host "[↑] Nueva versión detectada. Ejecutando actualizada..." -ForegroundColor Yellow
                Copy-Item $tempSetup $PSCommandPath -Force
                Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
                exit
            }
            else {
                Write-Host "[✓] Ya tienes la última versión." -ForegroundColor Green
            }
        }
    }
    catch {
        Write-Host "[!] No se pudo verificar actualización, usando versión local." -ForegroundColor Yellow
    }
}

AutoUpdate

# --- Requiere Admin ---
function Test-AdminPrivileges {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        if ($MyInvocation.MyCommand.Path) {
            Write-Host "[!] Reiniciando como administrador..." -ForegroundColor Yellow
            Start-Process powershell "-ExecutionPolicy Bypass -File `"$MyInvocation.MyCommand.Path`"" -Verb RunAs
        }
        else {
            Write-Host "[!] No se puede relanzar desde iwr | iex. Ejecuta PowerShell como administrador manualmente." -ForegroundColor Red
        }
        exit
    }
}


Test-AdminPrivileges

# --- Winget ---
function Install-Winget {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "[+] Instalando Winget..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile "$env:TEMP\Microsoft.DesktopAppInstaller.msixbundle"
        Add-AppxPackage "$env:TEMP\Microsoft.DesktopAppInstaller.msixbundle"
    }
    else {
        Write-Host "[✓] Winget ya está instalado." -ForegroundColor Green
    }
}

Install-Winget

# --- Instalador universal ---
function Install-App {
    param (
        [string]$id = "",
        [string]$name,
        [string]$type = "winget", # winget | exe
        [string]$url = ""
    )

    Write-Host "`n[+] Instalando $name..." -ForegroundColor Cyan

    switch ($type) {
        "winget" {
            try {
                winget install --id=$id -e --accept-source-agreements --accept-package-agreements -h | Out-Null
                Write-Host "[✓] $name instalado." -ForegroundColor Green
            }
            catch {
                Write-Host "[!] Error instalando $name via winget." -ForegroundColor Red
            }
        }
        "exe" {
            try {
                $installerPath = "$tempDir\$name.exe"
                Invoke-WebRequest -Uri $url -OutFile $installerPath -UseBasicParsing
                Start-Process -FilePath $installerPath -ArgumentList "/silent", "/verysilent", "/norestart" -Wait
                Write-Host "[✓] $name instalado." -ForegroundColor Green
            }
            catch {
                Write-Host "[!] Error instalando $name desde $url" -ForegroundColor Red
            }
        }
    }
}

# --- Listado de apps ---
$apps = @{
    winget = @(
        @{ id = "Flow-Launcher.Flow-Launcher"; name = "Flow Launcher" },
        @{ id = "Zen-Team.Zen-Browser"; name = "Zen Browser" },
        @{ id = "Warp.Warp"; name = "Warp Terminal" },
        @{ id = "Git.Git"; name = "Git" },
        @{ id = "Docker.DockerDesktop"; name = "Docker Desktop"; optional = $true },
        @{ id = "Microsoft.VisualStudioCode"; name = "VSCode"; optional = $true }
    )
    exe    = @(
        @{ name = "FilePilot"; url = "http://filepilot.tech/download/latest" }
    )
}

# --- Tipo de usuario ---
$tipoUsuario = Read-Host "[?] ¿Este equipo es para DESARROLLADOR o CASUAL? (dev/casual)"

# --- Instalación interactiva ---
foreach ($app in $apps.winget) {
    if ($app.PSContainsKey("optional") -and $tipoUsuario -eq "casual") { continue }
    if ($app.optional) {
        $resp = Read-Host "[?] ¿Deseas instalar $($app.name)? (y/n)"
        if ($resp -ne "y") { continue }
    }
    Install-App -id $app.id -name $app.name -type "winget"
}

foreach ($app in $apps.exe) {
    Install-App -name $app.name -type "exe" -url $app.url
}

# --- GlazeWM ---
$usarGlaze = Read-Host "[?] ¿Quieres usar GlazeWM (tiling manager)? (y/n)"
if ($usarGlaze -eq "y") {
    Install-App -id "glzr-io.glazewm" -name "GlazeWM" -type "winget"
    Write-Host "[+] Configurando inicio automático GlazeWM..." -ForegroundColor Cyan
    $taskName = "GlazeWM AutoStart"
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
    $glazePath = "$env:ProgramFiles\glzr.io\GlazeWM\glazewm.exe"
    $action = New-ScheduledTaskAction -Execute $glazePath
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Description "Auto-start GlazeWM at login" | Out-Null
}

# --- Scripts del repo ---
function Invoke-RepoScripts {
    Write-Host "[+] Ejecutando scripts desde repo..." -ForegroundColor Cyan
    try {
        $scriptList = @(
            "env-vars.ps1"  # puedes añadir más scripts aquí o detectarlos dinámicamente desde GitHub
        )
        foreach ($s in $scriptList | Sort-Object) {
            $url = "$repoScriptsBase$s"
            Write-Host "[~] Ejecutando $s..." -ForegroundColor Cyan
            Invoke-Expression (Invoke-WebRequest -UseBasicParsing $url).Content
        }
    }
    catch {
        Write-Host "[!] Error ejecutando scripts del repo." -ForegroundColor Red
    }
}

Invoke-RepoScripts

function Get-GitHubFolder {
    param(
        [string]$user = "Pblo16",
        [string]$repo = "windots",
        [string]$branch = "main",
        [string]$folder = "",           # ej: "yasb" o "glazewm"
        [string]$dest = ""
    )

    $apiUrl = "https://api.github.com/repos/$user/$repo/contents/$folder?ref=$branch"
    Write-Host "[~] Descargando archivos de $folder..." -ForegroundColor Cyan

    try {
        $files = Invoke-RestMethod -Uri $apiUrl -Headers @{ "User-Agent" = "PowerShell" }
        foreach ($file in $files) {
            if ($file.type -eq "file") {
                $rawUrl = $file.download_url
                $destPath = Join-Path $dest $file.name
                Invoke-WebRequest -Uri $rawUrl -OutFile $destPath -UseBasicParsing
                Write-Host "    [+] $($file.name) descargado." -ForegroundColor Green
            }
        }
    }
    catch {
        $errorMsg = $PSItem.ToString()
        Write-Host "[!] Error descargando $folder`: $errorMsg" -ForegroundColor Red
    }
}

# --- Uso ---
$yasbConfig = "$env:USERPROFILE\.config\yasb"
$glazeConfig = "$env:USERPROFILE\.glzr\glazewm"
New-Item -ItemType Directory -Force -Path $yasbConfig | Out-Null
New-Item -ItemType Directory -Force -Path $glazeConfig | Out-Null

Get-GitHubFolder -folder "yasb" -dest $yasbConfig
Get-GitHubFolder -folder "glazewm" -dest $glazeConfig


# Aquí puedes añadir lógica para descargar todos los archivos de esas carpetas (iwr + SaveAs) si quieres automatizarlo

# --- GlazeWM ---
$usarWSL = Read-Host "[?] ¿Quieres usar WSL? (y/n)"
if ($usarWSL -eq "y") {
    # --- WSL2 + Ubuntu ---
    Write-Host "[+] Revisando WSL..." -ForegroundColor Cyan
    wsl --status 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[+] Instalando WSL2 con Ubuntu..." -ForegroundColor Cyan
        wsl --install -d Ubuntu
    }
    else {
        Write-Host "[✓] WSL ya instalado." -ForegroundColor Green
    }

    Write-Host "[+] Ejecutando install.sh dentro de Ubuntu..." -ForegroundColor Cyan
    wsl -d Ubuntu -e bash -c "curl -O https://raw.githubusercontent.com/Pblo16/pablo.dots/refs/heads/main/install.sh; chmod +x install.sh; bash install.sh"
}
Write-Host ""
Write-Host "✅ Instalación completa. Reinicia el sistema para aplicar los cambios." -ForegroundColor Green
