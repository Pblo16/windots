# Windows Setup Script by Pablo
# Ejecutar con PowerShell (Admin si es posible)

function Require-Admin {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "[!] Reiniciando como administrador..." -ForegroundColor Yellow
        Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
}

Require-Admin

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

$tipoUsuario = Read-Host "[?] ¿Vas a usar este equipo como DESARROLLADOR o CASUAL? (dev/casual)"

function Install-App {
    param ($id, $name)
    Write-Host "[+] Instalando $name..." -ForegroundColor Cyan
    winget install --id=$id -e --accept-source-agreements --accept-package-agreements | Out-Null
}

Install-App "Flow-Launcher.Flow-Launcher" "Flow Launcher"
Install-App "Zen-Team.Zen-Browser" "Zen Browser"
Install-App "Warp.Warp" "Warp Terminal"

$usarGlaze = Read-Host "[?] ¿Quieres usar el Tiling Manager GlazeWM? (y/n)"
if ($usarGlaze -eq "y") {
    Install-App "glzr-io.glazewm" "GlazeWM"
    Write-Host "[+] Configurando inicio automático de GlazeWM..." -ForegroundColor Cyan
    $taskName = "GlazeWM AutoStart"
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
    $glazePath = "$env:ProgramFiles\glzr.io\GlazeWM\glazewm.exe"
    $action = New-ScheduledTaskAction -Execute $glazePath
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Description "Auto-start GlazeWM at login" | Out-Null
}

Install-App "AmN.yasb" "YASB (Yet Another Status Bar)"

if ($tipoUsuario -eq "dev") {
    $editor = Read-Host "[?] ¿Prefieres usar VSCodium o Zed? (vscodium/zed)"
    if ($editor -eq "vscodium") {
        Install-App "VSCodium.VSCodium" "VSCodium"
    }
    else {
        Install-App "ZedIndustries.Zed" "Zed"
    }

    Install-App "MacroDeck.MacroDeck" "Macro Deck"
    Install-App "Git.Git" "Git"
    Install-App "Schniz.fnm" "Fast Node Manager"

    $usarDocker = Read-Host "[?] ¿Vas a usar Docker? (y/n)"
    if ($usarDocker -eq "y") {
        Install-App "Docker.DockerDesktop" "Docker Desktop"
    }
}

$esAsus = Read-Host "[?] ¿Tu equipo es ASUS? (y/n)"
if ($esAsus -eq "y") {
    Install-App "seerge.g-helper" "G-Helper para ASUS"
}

Write-Host "[+] Descargando e instalando FilePilot..." -ForegroundColor Cyan
$filePilot = "$env:TEMP\FilePilotInstaller.exe"
Invoke-WebRequest -Uri "http://filepilot.tech/download/latest" -OutFile $filePilot
Start-Process $filePilot -Wait

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

Write-Host "[+] Revisando WSL..." -ForegroundColor Cyan
$wslStatus = wsl --status 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[+] Instalando WSL2 con Ubuntu..." -ForegroundColor Cyan
    wsl --install -d Ubuntu
}
else {
    Write-Host "[✓] WSL ya está instalado." -ForegroundColor Green
}

Write-Host "[+] Ejecutando setup dentro de Ubuntu..." -ForegroundColor Cyan
wsl -d Ubuntu -e bash -c "curl -O https://raw.githubusercontent.com/Pblo16/pablo.dots/refs/heads/main/install.sh && chmod +x install.sh && bash install.sh"

Write-Host ""
Write-Host "✅ Instalación completa. Reinicia el sistema para aplicar los cambios." -ForegroundColor Green
