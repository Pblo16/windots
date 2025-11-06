; ============================================================================
; Shortcuts Module - Atajos de teclado globales
; ============================================================================
; Este módulo contiene todos los atajos de teclado personalizados
; Para añadir nuevos atajos, simplemente añade una nueva sección aquí
; ============================================================================

#Requires AutoHotkey v2.0

; ============================================================================
; CONFIGURACIÓN
; ============================================================================

; Rutas de aplicaciones (modifica aquí para personalizar)
global APP_FILEPILOT := EnvGet("USERPROFILE") "\AppData\Local\Voidstar\FilePilot\FPilot.exe"
global APP_EXPLORER := "explorer.exe"
global APP_WARP := "warp"
global APP_TERMINAL := "wt"

; ============================================================================
; LANZADORES DE APLICACIONES
; ============================================================================

; Alt + E → Abrir FilePilot (File Manager)
!e:: {
    LaunchApp(APP_FILEPILOT, "FilePilot")
}

; Alt + Shift + E → Abrir Windows Explorer
!+e:: {
    LaunchApp(APP_EXPLORER, "Explorer")
}

; Alt + Enter → Abrir Warp Terminal (minimizado)
!Enter:: {
    LaunchApp(APP_WARP, "Warp Terminal", "min")
}

; Alt + Shift + Enter → Abrir Windows Terminal
!+Enter:: {
    LaunchApp(APP_TERMINAL, "Windows Terminal")
}

; ============================================================================
; ATAJOS ESPECÍFICOS DE WARP
; ============================================================================

; Ctrl + Alt + N → Nueva pestaña de PowerShell en Warp
^!n:: {
    if WinActive("ahk_exe Warp.exe") {
        SendWarpCommand("create new tab: powershell")
    }
}

; Ctrl + Alt + Shift + N → Nueva ventana de PowerShell en Warp
^!+n:: {
    if WinActive("ahk_exe Warp.exe") {
        SendWarpCommand("create new window: powershell")
    }
}

; ============================================================================
; GESTIÓN DE VENTANAS
; ============================================================================

; Alt + Shift + Q → Cerrar ventana activa (Alt+F4)
!+q:: {
    Send "!{F4}"
}

; ============================================================================
; UTILIDADES DEL SISTEMA
; ============================================================================

; Ctrl + Alt + R → Recargar todos los scripts AHK
^!r:: {
    Reload()
    Sleep 1000
    TrayTip "Scripts recargados", "Windots AHK", 1
}

; ============================================================================
; FUNCIONES AUXILIARES
; ============================================================================

/**
 * Lanza una aplicación con manejo de errores
 * @param appPath Ruta de la aplicación o comando
 * @param appName Nombre de la aplicación para mensajes
 * @param windowMode Modo de ventana: "min", "max", "" (opcional)
 */
LaunchApp(appPath, appName, windowMode := "") {
    try {
        if (windowMode = "") {
            Run appPath
        } else {
            Run appPath, , windowMode
        }
    } catch as err {
        TrayTip "Error al abrir " appName ": " err.Message, "Windots AHK", 3
    }
}

/**
 * Envía un comando a Warp Terminal usando la paleta de comandos
 * @param command Comando a enviar
 */
SendWarpCommand(command) {
    Send "^+p"        ; Abrir paleta de comandos
    Sleep 120
    Send command      ; Escribir comando
    Sleep 100
    Send "{Enter}"    ; Ejecutar comando
}
