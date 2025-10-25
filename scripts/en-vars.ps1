# env-vars.ps1
# Define aquí tus variables de entorno personalizadas



$warpPath = Join-Path $env:USERPROFILE "AppData\Local\Programs\Warp"
# Fallback: obtener Path del registro si $env:Path está vacío
$userPath = $env:Path
if (-not $userPath) {
  try {
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
  }
  catch { $userPath = "" }
}
$customEnvVars = @{
  "Path" = if ($userPath) { $userPath + ";" + $warpPath } else { $warpPath }
}

# Exportar variables
foreach ($key in $customEnvVars.Keys) {
  [Environment]::SetEnvironmentVariable($key, $customEnvVars[$key], "User")
  Write-Host "[+] Variable de entorno configurada: $key" -ForegroundColor Cyan
}
