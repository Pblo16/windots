# env-vars.ps1
# Define aquí tus variables de entorno personalizadas

$customEnvVars = @{
  "Path" = $env:Path + ";$env:USERPROFILE\AppData\Local\Programs\Warp"
}

# Exportar variables
foreach ($key in $customEnvVars.Keys) {
  [Environment]::SetEnvironmentVariable($key, $customEnvVars[$key], "User")
  Write-Host "[+] Variable de entorno configurada: $key" -ForegroundColor Cyan
}
