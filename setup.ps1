# Windows Setup Script by Pablo
# Ejecutar con PowerShell (Admin si es posible)

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
        # PowerShell 5 no soporta -MaximumRedirection en Invoke-WebRequest
        if ($PSVersionTable.PSVersion.Major -ge 6) {
            $response = Invoke-WebRequest -Uri $url -MaximumRedirection 5 -OutFile $dest
        }
        else {
            $response = Invoke-WebRequest -Uri $url -OutFile $dest
        }
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
    @{Id = "MacroDeck.MacroDeck"; Name = "Macro Deck" },
    @{Id = "AmN.yasb"; Name = "YASB (Yet Another Status Bar)" }
)

$devApps = @(
    @{Id = "Git.Git"; Name = "Git" },
    @{Id = "Schniz.fnm"; Name = "Fast Node Manager" },
    @{Id = "Warp.Warp"; Name = "Warp Terminal" }
)

$editors = @{
    "VisualStudioCode" = @{Id = "Microsoft.VisualStudioCode"; Name = "VisualStudioCode" }
    "zed"              = @{Id = "ZedIndustries.Zed"; Name = "Zed" }
}

$downloadables = @(
    @{Url = "http://filepilot.tech/download/latest"; Name = "FilePilot" }
)


$tipoUsuario = Show-Menu "¿Vas a usar este equipo como DESARROLLADOR o CASUAL?" @("Desarrollador", "Casual")
$tipoUsuario = if ($tipoUsuario -eq "Desarrollador") { "dev" } else { "casual" }

foreach ($app in $commonApps) { Install-App $app.Id $app.Name }

if ($tipoUsuario -eq "dev") {
    $editor = Show-Menu "¿Prefieres usar VisualStudioCode o Zed?" @("VisualStudioCode", "zed")
    Install-App $editors[$editor].Id $editors[$editor].Name

    foreach ($app in $devApps) { Install-App $app.Id $app.Name }

    $usarDocker = Show-Menu "¿Vas a usar Docker?" @("Sí", "No")
    if ($usarDocker -eq "Sí") { Install-App "Docker.DockerDesktop" "Docker Desktop" }
}


$usarGlaze = Show-Menu "¿Quieres usar el Tiling Manager GlazeWM?" @("Sí", "No")
if ($usarGlaze -eq "Sí") {
    Install-App "glzr-io.glazewm" "GlazeWM"
    Write-Host "[+] Configurando inicio automático de GlazeWM..." -ForegroundColor Cyan
    $taskName = "GlazeWM AutoStart"
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
    $glazePath = "$env:ProgramFiles\glzr.io\GlazeWM\glazewm.exe"
    $action = New-ScheduledTaskAction -Execute $glazePath
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Description "Auto-start GlazeWM at login" | Out-Null
}


$esAsus = Show-Menu "¿Tu equipo es ASUS?" @("Sí", "No")
if ($esAsus -eq "Sí") { Install-App "seerge.g-helper" "G-Helper para ASUS" }

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