# windots

Configuración automatizada para entornos Windows.

## Instalación rápida
Ejecuta el siguiente comando en PowerShell para instalar y configurar automáticamente:

```powershell
iwr -useb https://raw.githubusercontent.com/Pblo16/windots/main/setup.ps1 | iex
```

## Estructura del proyecto

- `setup.ps1`: Script principal de instalación y configuración.
- `glazewm/config.yaml`: Configuración para el gestor de ventanas GlazeWM.
- `yasb/config.yaml`: Configuración para YASB (barra de estado).
- `yasb/styles.css`: Estilos personalizados para YASB.
- `scripts/en-vars.ps1`: Script para definir variables de entorno.


## Personalización
Edita los archivos de configuración en las carpetas `glazewm` y `yasb` para adaptar el entorno a tus preferencias.

## Requisitos
- PowerShell
- Acceso a internet para descargar dependencias

## Créditos
Autor: [Pablo](https://github.com/Pblo16)
