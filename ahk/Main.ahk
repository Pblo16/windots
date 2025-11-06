; ============================================================================
; Main AHK Script - Windots Configuration
; ============================================================================
; Este es el script principal que carga todos los módulos de AutoHotkey
; Ejecuta este script al inicio de Windows para activar todos los atajos
; ============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

; Configuración global
SetWorkingDir A_ScriptDir
Persistent

; Icono de bandeja del sistema
TraySetIcon("shell32.dll", 165)
A_IconTip := "Windots AHK Manager"

; Configurar menú de bandeja
A_TrayMenu.Delete()
A_TrayMenu.Add("🔄 Recargar scripts", (*) => Reload())
A_TrayMenu.Add()
A_TrayMenu.Add("📂 Abrir carpeta de scripts", (*) => Run(A_ScriptDir))
A_TrayMenu.Add("📝 Editar Main.ahk", (*) => Run("notepad.exe " A_ScriptFullPath))
A_TrayMenu.Add()
A_TrayMenu.Add("❌ Salir", (*) => ExitApp())

; Cargar módulos
try {
    #Include modules\Shortcuts.ahk
    TrayTip "Módulo de atajos cargado", "Windots AHK", 1
} catch as err {
    TrayTip "Error cargando módulo de atajos: " err.Message, "Windots AHK", 3
}

try {
    #Include modules\WindowManager.ahk
    TrayTip "Módulo de gestión de ventanas cargado", "Windots AHK", 1
} catch as err {
    TrayTip "Error cargando módulo de ventanas: " err.Message, "Windots AHK", 3
}

; Notificación de inicio
Sleep 500
TrayTip "Todos los módulos cargados correctamente", "Windots AHK Manager", 1