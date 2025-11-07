# Windots - AutoHotkey Configuration

Scripts de AutoHotkey v2.0 para mejorar la productividad en Windows.

## 📁 Estructura

```
ahk/
├── Main.ahk              # Script principal (ejecuta este)
├── modules/              # Módulos organizados por funcionalidad
│   ├── Shortcuts.ahk     # Atajos de teclado globales
│   └── WindowManager.ahk # Gestor de ventanas ocultas
├── overwrite.ahk         # Script legacy (obsoleto)
├── Systray.ahk           # Script legacy (obsoleto)
└── README.md             # Esta documentación
```

## 🚀 Uso

### Instalación automática

El script `setup.ps1` en la raíz del repositorio se encarga de:
1. Copiar estos scripts a `~\.config\ahk`
2. Crear un acceso directo en `shell:startup` para ejecutar `Main.ahk` al inicio

### Instalación manual

1. Copia la carpeta `ahk` a `%USERPROFILE%\.config\ahk`
2. Crea un acceso directo de `Main.ahk` en la carpeta de inicio:
   - Presiona `Win + R`
   - Escribe `shell:startup` y presiona Enter
   - Crea un acceso directo a `Main.ahk` en esta carpeta

### Ejecutar manualmente

Simplemente ejecuta `Main.ahk` haciendo doble clic en él.

## ⌨️ Atajos de teclado

### Lanzadores de aplicaciones

| Atajo | Acción |
|-------|--------|
| `Alt + E` | Abrir FilePilot (gestor de archivos) |
| `Alt + Shift + E` | Abrir Windows Explorer |
| `Alt + Enter` | Abrir Warp Terminal (minimizado) |
| `Alt + Shift + Enter` | Abrir Windows Terminal |

### Gestión de ventanas

| Atajo | Acción |
|-------|--------|
| `Ctrl + Shift + H` | Ocultar ventana activa |
| `Ctrl + Shift + M` | Mostrar menú de ventanas ocultas |
| `Ctrl + Shift + L` | Restaurar última ventana oculta |
| `Alt + Shift + Q` | Cerrar ventana activa (Alt+F4) |

### Espacios de trabajo

| Atajo | Acción |
|-------|--------|
| `Ctrl + Alt + S` | Guardar espacio de trabajo actual |
| `Ctrl + Alt + O` | Abrir menú de espacios de trabajo guardados |

### Atajos de Warp Terminal

| Atajo | Acción |
|-------|--------|
| `Ctrl + Alt + N` | Nueva pestaña de PowerShell |
| `Ctrl + Alt + Shift + N` | Nueva ventana de PowerShell |

### Utilidades del sistema

| Atajo | Acción |
|-------|--------|
| `Ctrl + Alt + R` | Recargar todos los scripts AHK |

## 🛠️ Personalización

### Añadir nuevos atajos

Edita `modules\Shortcuts.ahk` y añade tu atajo siguiendo este patrón:

```ahk
; Alt + T → Tu nuevo atajo
!t:: {
    ; Tu código aquí
    Run "notepad.exe"
}
```

### Modificar rutas de aplicaciones

Edita la sección de configuración en `modules\Shortcuts.ahk`:

```ahk
global APP_FILEPILOT := "C:\Ruta\A\Tu\Aplicacion.exe"
```

### Crear nuevos módulos

1. Crea un nuevo archivo `.ahk` en la carpeta `modules`
2. Añade `#Requires AutoHotkey v2.0` al inicio
3. Incluye el módulo en `Main.ahk`:

```ahk
Try {
    #Include modules\TuNuevoModulo.ahk
    TrayTip "Tu módulo cargado", "Windots AHK", 1
} Catch as err {
    TrayTip "Error cargando módulo: " err.Message, "Windots AHK", 3
}
```

## 📝 Notas

- Requiere AutoHotkey v2.0 o superior
- Los scripts legacy (`overwrite.ahk` y `Systray.ahk`) se mantienen por compatibilidad pero están obsoletos
- El script principal (`Main.ahk`) carga todos los módulos automáticamente
- El icono en la bandeja del sistema permite recargar scripts sin reiniciar

## 🔧 Solución de problemas

### Los atajos no funcionan

1. Verifica que AutoHotkey v2.0 esté instalado
2. Comprueba que `Main.ahk` esté en ejecución (icono en la bandeja del sistema)
3. Recarga los scripts con `Ctrl + Alt + R`

### Error al cargar módulos

- Verifica que la carpeta `modules` exista en el mismo directorio que `Main.ahk`
- Comprueba que los archivos `.ahk` en `modules` no tengan errores de sintaxis

## 📄 Licencia

Parte del proyecto Windots por Pablo.
