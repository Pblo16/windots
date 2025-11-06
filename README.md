# windots

Configuración automatizada para entornos Windows.

## Instalación rápida
Ejecuta el siguiente comando en PowerShell para instalar y configurar automáticamente:

```powershell
iwr -useb https://raw.githubusercontent.com/Pblo16/windots/main/setup.ps1 | iex
```

## Estructura del proyecto

- `setup.ps1`: Script principal de instalación y configuración.
- `ahk/`: Scripts de AutoHotkey v2.0 para atajos de teclado personalizados.
  - `Main.ahk`: Script principal que carga todos los módulos.
  - `modules/`: Módulos organizados por funcionalidad.
    - `Shortcuts.ahk`: Atajos de teclado globales.
    - `WindowManager.ahk`: Gestor de ventanas ocultas.
  - `Config.ahk`: Archivo de configuración personalizada.
  - `README.md`: Documentación detallada de AHK.
- `yasb/`: Configuración para YASB (barra de estado).
  - `config.yaml`: Configuración principal.
  - `styles.css`: Estilos personalizados.
- `mondrian/`: Configuración para el gestor de ventanas Mondrian.
- `oh-my-posh/`: Temas personalizados para Oh My Posh.
- `wezterm/`: Configuración para WezTerm terminal.

## Características

### 🎨 Interfaz personalizada
- **YASB**: Barra de estado moderna y configurable
- **Mondrian**: Gestor de ventanas en mosaico
- **Wallpapers**: Colección curada de fondos de pantalla

### ⌨️ Atajos de teclado (AutoHotkey)
- Lanzadores rápidos de aplicaciones (FilePilot, Warp, Terminal)
- Gestor de ventanas ocultas con bandeja del sistema
- Atajos específicos para Warp Terminal
- Fácilmente expandible con nuevos módulos

### 🖥️ Terminal mejorado
- **Oh My Posh**: Prompts personalizados
- **WezTerm**: Terminal moderna y configurable
- Integración con WSL2 (opcional)

## Instalación

### Instalación automática (recomendada)

Ejecuta el siguiente comando en PowerShell con privilegios de administrador:

```powershell
iwr -useb https://raw.githubusercontent.com/Pblo16/windots/main/setup.ps1 | iex
```

El script se encargará de:
1. ✅ Clonar configuraciones en `~\.config\`
2. ✅ Copiar scripts de AutoHotkey
3. ✅ Crear acceso directo en el inicio de Windows
4. ✅ Configurar variables de entorno
5. ✅ (Opcional) Instalar y configurar WSL2 con Ubuntu

### Instalación manual

1. Clona el repositorio:
```powershell
git clone https://github.com/Pblo16/windots.git
cd windots
```

2. Ejecuta el script de instalación como administrador:
```powershell
.\setup.ps1
```

## Configuración de AutoHotkey

Los scripts de AutoHotkey se instalan automáticamente en `~\.config\ahk` y se ejecutan al inicio de Windows.

### Atajos disponibles

| Atajo | Acción |
|-------|--------|
| `Alt + E` | Abrir FilePilot |
| `Alt + Shift + E` | Abrir Explorer |
| `Alt + Enter` | Abrir Warp Terminal |
| `Ctrl + Shift + H` | Ocultar ventana activa |
| `Ctrl + Shift + L` | Restaurar última ventana |
| `Ctrl + Alt + R` | Recargar scripts AHK |

Para más información, consulta [ahk/README.md](ahk/README.md).


## Personalización

### Atajos de teclado

Edita `~\.config\ahk\Config.ahk` para añadir tus propios atajos sin modificar los scripts principales.

### Estilos y colores

- **YASB**: Edita `~\.config\yasb\styles.css`
- **Oh My Posh**: Edita `~\.oh-my-posh\php.omp.json`
- **WezTerm**: Edita `~\.config\wezterm\wezterm.lua`

### Gestor de ventanas

Edita `~\.config\mondrian\mondrian.toml` para cambiar el comportamiento del gestor de ventanas.

## Requisitos

- Windows 10/11
- PowerShell 5.1 o superior
- Git
- [AutoHotkey v2.0](https://www.autohotkey.com/) (para atajos de teclado)
- Acceso a internet para descargar dependencias

## Créditos
Autor: [Pablo](https://github.com/Pblo16)
