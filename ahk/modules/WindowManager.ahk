; ============================================================================
; Window Manager Module - Gestor de ventanas ocultas
; ============================================================================
; Este módulo permite ocultar y restaurar ventanas mediante atajos de teclado
; Funciona como un gestor de ventanas con bandeja del sistema
; ============================================================================

#Requires AutoHotkey v2.0

; ============================================================================
; CONFIGURACIÓN Y VARIABLES GLOBALES
; ============================================================================

global hiddenWindows := Map()
global lastHidden := 0

; Configuración de la bandeja del sistema
TraySetIcon("shell32.dll", 44)
A_IconTip := "Gestor de ventanas ocultas"

; Inicializar menú
InitializeTrayMenu()

; ============================================================================
; ATAJOS DE TECLADO
; ============================================================================

; Ctrl + Shift + H → Ocultar ventana activa
^+h:: {
    HideActiveWindow()
}

; Ctrl + Shift + M → Mostrar menú con todas las ventanas ocultas
^+m:: {
    ShowWindowMenu()
}

; Ctrl + Shift + L → Restaurar la última ventana oculta
^+l:: {
    RestoreLastWindow()
}

; ============================================================================
; FUNCIONES PRINCIPALES
; ============================================================================

/**
 * Oculta la ventana activa actualmente
 */
HideActiveWindow() {
    global hiddenWindows, lastHidden

    try {
        hwnd := WinGetID("A")
        title := WinGetTitle("ahk_id " hwnd)

        ; Validaciones
        if (!title) {
            TrayTip "No hay ventana activa para ocultar", "Window Manager", 2
            return
        }

        if (hiddenWindows.Has(hwnd)) {
            TrayTip "Esta ventana ya está oculta", "Window Manager", 2
            return
        }

        ; Ocultar ventana
        WinHide("ahk_id " hwnd)
        hiddenWindows[hwnd] := title
        lastHidden := hwnd

        ; Notificación
        TrayTip "Ventana oculta: " SubStr(title, 1, 50), "Window Manager", 1
        UpdateTrayMenu()

    } catch as err {
        TrayTip "Error al ocultar ventana: " err.Message, "Window Manager", 3
    }
}

/**
 * Muestra el menú contextual con todas las ventanas ocultas
 */
ShowWindowMenu() {
    UpdateTrayMenu()
    CoordMode("Menu", "Screen")
    MouseGetPos(&x, &y)
    A_TrayMenu.Show(x, y)
}

/**
 * Restaura la última ventana que fue ocultada
 */
RestoreLastWindow() {
    global lastHidden, hiddenWindows

    if (!lastHidden) {
        TrayTip "No hay ventanas ocultas para restaurar", "Window Manager", 2
        return
    }

    if (!WinExist("ahk_id " lastHidden)) {
        TrayTip "La ventana ya no existe", "Window Manager", 2
        hiddenWindows.Delete(lastHidden)
        lastHidden := 0
        UpdateTrayMenu()
        return
    }

    try {
        title := hiddenWindows[lastHidden]
        WinShow("ahk_id " lastHidden)
        WinActivate("ahk_id " lastHidden)
        hiddenWindows.Delete(lastHidden)
        lastHidden := 0

        TrayTip "Ventana restaurada: " SubStr(title, 1, 50), "Window Manager", 1
        UpdateTrayMenu()

    } catch as err {
        TrayTip "Error al restaurar ventana: " err.Message, "Window Manager", 3
    }
}

/**
 * Restaura una ventana específica por su handle
 * @param hwnd Handle de la ventana a restaurar
 */
RestoreWindow(hwnd, *) {
    global hiddenWindows, lastHidden

    try {
        DetectHiddenWindows(true)

        if (!WinExist("ahk_id " hwnd)) {
            TrayTip "La ventana ya no existe", "Window Manager", 2
            hiddenWindows.Delete(hwnd)
            UpdateTrayMenu()
            return
        }

        title := hiddenWindows[hwnd]
        WinShow("ahk_id " hwnd)
        WinActivate("ahk_id " hwnd)

        DetectHiddenWindows(false)
        hiddenWindows.Delete(hwnd)

        if (lastHidden = hwnd) {
            lastHidden := 0
        }

        TrayTip "Ventana restaurada: " SubStr(title, 1, 50), "Window Manager", 1
        UpdateTrayMenu()

    } catch as err {
        TrayTip "Error al restaurar ventana: " err.Message, "Window Manager", 3
        DetectHiddenWindows(false)
    }
}

; ============================================================================
; FUNCIONES DE MENÚ
; ============================================================================

/**
 * Inicializa el menú de la bandeja del sistema
 */
InitializeTrayMenu() {
    A_TrayMenu.Delete()
    A_TrayMenu.Add("No hay ventanas ocultas", (*) => 0)
    A_TrayMenu.Disable("No hay ventanas ocultas")
    A_TrayMenu.Add()
    A_TrayMenu.Add("Salir", (*) => ExitApp())
}

/**
 * Actualiza el menú de la bandeja del sistema con las ventanas ocultas
 */
UpdateTrayMenu() {
    global hiddenWindows

    A_TrayMenu.Delete()

    if (hiddenWindows.Count = 0) {
        A_TrayMenu.Add("📋 No hay ventanas ocultas", (*) => 0)
        A_TrayMenu.Disable("📋 No hay ventanas ocultas")
    } else {
        A_TrayMenu.Add("🪟 Ventanas ocultas (" hiddenWindows.Count "):", (*) => 0)
        A_TrayMenu.Disable("🪟 Ventanas ocultas (" hiddenWindows.Count "):")
        A_TrayMenu.Add()

        DetectHiddenWindows(true)

        ; Listar todas las ventanas ocultas
        for hwnd, title in hiddenWindows {
            if (!WinExist("ahk_id " hwnd)) {
                hiddenWindows.Delete(hwnd)
                continue
            }

            ; Truncar título si es muy largo
            displayTitle := SubStr(title, 1, 50)
            if (StrLen(title) > 50) {
                displayTitle .= "..."
            }

            itemName := "   🔹 " displayTitle
            A_TrayMenu.Add(itemName, RestoreWindow.Bind(hwnd))
        }

        DetectHiddenWindows(false)
        A_TrayMenu.Add()
    }

    ; Opciones adicionales
    A_TrayMenu.Add("🔄 Actualizar", (*) => UpdateTrayMenu())
    A_TrayMenu.Add()
    A_TrayMenu.Add("❌ Salir", (*) => ExitApp())
}
