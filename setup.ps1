# ===============================
# Windows Setup Script by Pablo
# Compatible PS5.1 (Windows PowerShell)
# ===============================
$ErrorActionPreference = "Stop"

$repoScriptsBase = "https://raw.githubusercontent.com/Pblo16/windots/main/scripts/"
$tempDir = "$env:TEMP\windots"
if (-not (Test-Path $tempDir)) { New-Item -ItemType Directory -Force -Path $tempDir | Out-Null }

function Test-Admin {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        if ($MyInvocation.MyCommand.Path) {
            Write-Host "[!] Reiniciando como administrador..." -ForegroundColor Yellow
            Start-Process powershell "-ExecutionPolicy Bypass -File `"$MyInvocation.MyCommand.Path`"" -Verb RunAs
        }
        else {
            Write-Host "[!] Ejecuta PowerShell como administrador manualmente." -ForegroundColor Red
        }
        exit
    }
}
Test-Admin

# --- Winget ---
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "[+] Instalando Winget..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile "$env:TEMP\Microsoft.DesktopAppInstaller.msixbundle" -UseBasicParsing
    Add-AppxPackage "$env:TEMP\Microsoft.DesktopAppInstaller.msixbundle"
}
else { Write-Host "[✓] Winget ya está instalado." -ForegroundColor Green }

# --- Función universal ---
function Install-App {
    param([string]$id, [string]$name, [string]$type = "winget", [string]$url = "")
    Write-Host "`n[+] Instalando $name..." -ForegroundColor Cyan
    if ($type -eq "winget") {
        try { winget install --id=$id -e --accept-source-agreements --accept-package-agreements -h | Out-Null; Write-Host "[✓] $name instalado." -ForegroundColor Green }
        catch { Write-Host "[!] Error instalando $name: ${($_.Exception.Message)}" -ForegroundColor Red }
    }
    elseif ($type -eq "exe") {
        try {
            $installer = Join-Path $tempDir "$name.exe"
            Invoke-WebRequest -Uri $url -OutFile $installer -UseBasicParsing
            if (Test-Path $installer) {
                Start-Process -FilePath $installer -ArgumentList "/silent", "/verysilent", "/norestart" -Wait
                Write-Host "[✓] $name instalado." -ForegroundColor Green
            }
            else { Write-Host "[!] No se pudo descargar $name" -ForegroundColor Red }
        }
        catch { Write-Host "[!] Error descargando $name: ${($_.Exception.Message)}" -ForegroundColor Red }
    }
}

# --- Apps ---
$apps = @{
    winget = @(
        @{ id = "Flow-Launcher.Flow-Launcher"; name = "Flow Launcher" },
        @{ id = "Zen-Team.Zen-Browser"; name = "Zen Browser" },
        @{ id = "Warp.Warp"; name = "Warp Terminal" },
        @{ id = "Git.Git"; name = "Git" },
        @{ id = "Microsoft.VisualStudioCode"; name = "VSCode"; optional = $true },
        @{ id = "Docker.DockerDesktop"; name = "Docker Desktop"; optional = $true }
    )
    exe    = @(
        @{ name = "FilePilot"; url = "http://filepilot.tech/download/latest" }
    )
}

$tipoUsuario = Read-Host "[?] Este equipo es para DESARROLLADOR o CASUAL? (dev/casual)"

foreach ($app in $apps.winget) {
    if ($app.ContainsKey("optional") -and $tipoUsuario -eq "casual") { continue }
    if ($app.ContainsKey("optional") -and $app.optional) {
        $resp = Read-Host "[?] Deseas instalar $($app.name)? (y/n)"
        if ($resp -ne "y") { continue }
    }
    Install-App -id $app.id -name $app.name -type "winget"
}

foreach ($app in $apps.exe) {
    Install-App -name $app.name -type "exe" -url $app.url
}

# --- GlazeWM ---
$usarGlaze = Read-Host "[?] Quieres usar GlazeWM (tiling manager)? (y/n)"
if ($usarGlaze -eq "y") {
    Install-App -id "glzr-io.glazewm" -name "GlazeWM" -type "winget"
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
    $scripts = @("env-vars.ps1")
    foreach ($s in $scripts) {
        $url = "$repoScriptsBase$s"
        Write-Host "[~] Ejecutando $s..." -ForegroundColor Cyan
        try { Invoke-Expression (Invoke-WebRequest -Uri $url -UseBasicParsing).Content }
        catch { Write-Host "[!] Error ejecutando $s: ${($_.Exception.Message)}" -ForegroundColor Red }
    }
}
Invoke-RepoScripts

# --- Descarga carpetas sin git ---
function Get-GitHubFolder {
    param([string]$folder, [string]$dest)
    $api = "https://api.github.com/repos/Pblo16/windots/contents/$folder?ref=main"
    Write-Host "[~] Descargando $folder..." -ForegroundColor Cyan
    try {
        $files = Invoke-RestMethod -Uri $api -Headers @{ "User-Agent" = "PowerShell" }
        foreach ($f in $files) {
            if ($f.type -eq "file") {
                $destPath = Join-Path $dest $f.name
                Invoke-WebRequest -Uri $f.download_url -OutFile $destPath -UseBasicParsing
                Write-Host "    [+] $($f.name) descargado" -ForegroundColor Green
            }
        }
    }
    catch { Write-Host "[!] Error descargando $folder: ${($_.Exception.Message)}" -ForegroundColor Red }
}

$yasbDir = "$env:USERPROFILE\.config\yasb"
$glazeDir = "$env:USERPROFILE\.glzr\glazewm"
New-Item -ItemType Directory -Force -Path $yasbDir | Out-Null
New-Item -ItemType Directory -Force -Path $glazeDir | Out-Null

Get-GitHubFolder -folder "yasb" -dest $yasbDir
Get-GitHubFolder -folder "glazewm" -dest $glazeDir

# --- WSL ---
$usarWSL = Read-Host "[?] Quieres usar WSL? (y/n)"
if ($usarWSL -eq "y") {
    wsl --status 2>$null
    if ($LASTEXITCODE -ne 0) { wsl --install -d Ubuntu }
    Write-Host "[+] Ejecutando install.sh en Ubuntu..." -ForegroundColor Cyan
    wsl -d Ubuntu -e bash -c "curl -O https://raw.githubusercontent.com/Pblo16/pablo.dots/refs/heads/main/install.sh; chmod +x install.sh; bash install.sh"
}

Write-Host "`n✅ Instalación completa. Reinicia el sistema." -ForegroundColor Green
