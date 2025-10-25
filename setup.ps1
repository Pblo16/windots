# Windows Setup Script by Pablo
# Ejecutar con PowerShell (Admin si es posible)

function Require-Admin {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "[!] Este script necesita permisos de administrador." -ForegroundColor Red
        Write-Host "[!] Cierra esta ventana y ejecuta PowerShell como administrador para continuar." -ForegroundColor Yellow
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

function Install-App {
    param ($id, $name)
    Write-Host "[+] Instalando $name..." -ForegroundColor Cyan
    winget install --id=$id -e --accept-source-agreements --accept-package-agreements | Out-Null
}

function Install-Downloadable {
    param ($url, $name, $dest = "$env:TEMP\$name.exe")
    Write-Host "[+] Descargando e instalando $name..." -ForegroundColor Cyan
    try {
        $response = Invoke-WebRequest -Uri $url -MaximumRedirection 5 -OutFile $dest
        Start-Process $dest -Wait
    }
    catch {
        Write-Host "[!] Error descargando $name" -ForegroundColor Red
    }
}

# Configuración de apps
$commonApps = @(
    @{Id = "Flow-Launcher.Flow-Launcher"; Name = "Flow Launcher" },
    @{Id = "Zen-Team.Zen-Browser"; Name = "Zen Browser" },
    @{Id = "Warp.Warp"; Name = "Warp Terminal" },
    @{Id = "MacroDeck.MacroDeck"; Name = "Macro Deck" },
    @{Id = "AmN.yasb"; Name = "YASB (Yet Another Status Bar)" }
)

$devApps = @(
    @{Id = "Git.Git"; Name = "Git" },
    @{Id = "Schniz.fnm"; Name = "Fast Node Manager" }
)

$editors = @{
    "VisualStudioCode" = @{Id = "Microsoft.VisualStudioCode"; Name = "VisualStudioCode" }
    "zed"              = @{Id = "ZedIndustries.Zed"; Name = "Zed" }
}

$downloadables = @(
    @{Url = "http://filepilot.tech/download/latest"; Name = "FilePilot" }
)

$tipoUsuario = Read-Host "[?] ¿Vas a usar este equipo como DESARROLLADOR o CASUAL? (dev/casual)"

foreach ($app in $commonApps) { Install-App $app.Id $app.Name }

if ($tipoUsuario -eq "dev") {
    $editor = Read-Host "[?] ¿Prefieres usar VisualStudioCode o Zed? (VisualStudioCode/zed)"
    Install-App $editors[$editor].Id $editors[$editor].Name

    foreach ($app in $devApps) { Install-App $app.Id $app.Name }

    $usarDocker = Read-Host "[?] ¿Vas a usar Docker? (y/n)"
    if ($usarDocker -eq "y") { Install-App "Docker.DockerDesktop" "Docker Desktop" }
}

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

$esAsus = Read-Host "[?] ¿Tu equipo es ASUS? (y/n)"
if ($esAsus -eq "y") { Install-App "seerge.g-helper" "G-Helper para ASUS" }

foreach ($dl in $downloadables) { Install-Downloadable $dl.Url $dl.Name }

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
$usarWSL = Read-Host "[?] ¿Quieres usar WSL? (y/n)"
if ($usarWSL -eq "y") {   
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

# Ejecutar variables de entorno personalizadas
try {
    $enVarsScript = if ($PSScriptRoot) { Join-Path $PSScriptRoot "scripts\en-vars.ps1" } else { "" }

    if ($enVarsScript -and (Test-Path $enVarsScript)) {
        Write-Host "[+] Configurando variables de entorno personalizadas..." -ForegroundColor Cyan
        powershell -ExecutionPolicy Bypass -File $enVarsScript
    }
    else {
        Write-Host "[!] No se encontró scripts/en-vars.ps1 o el script no se ejecuta desde un archivo .ps1" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "[!] Error ejecutando en-vars.ps1: $($PSItem.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "✅ Instalación completa. Reinicia el sistema para aplicar los cambios." -ForegroundColor Green