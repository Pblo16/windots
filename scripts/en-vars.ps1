# env-vars.ps1
# Define aquí tus variables de entorno personalizadas


$warpPath = Join-Path $env:USERPROFILE "AppData\Local\Programs\Warp"
$customEnvVars = @{
  "Path" = if ($env:Path) { $env:Path + ";" + $warpPath } else { $warpPath }
}

# Exportar variables
foreach ($key in $customEnvVars.Keys) {
  [Environment]::SetEnvironmentVariable($key, $customEnvVars[$key], "User")
  Write-Host "[+] Variable de entorno configurada: $key" -ForegroundColor Cyan
}
