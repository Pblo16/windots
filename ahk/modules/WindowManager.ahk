; ============================================================================
; Window Manager Module - Gestor de ventanas y espacios de trabajo
; ============================================================================
; Este módulo permite:
; - Ocultar y restaurar ventanas mediante atajos de teclado
; - Guardar y cargar espacios de trabajo (snapshots de ventanas abiertas)
; ============================================================================

#Requires AutoHotkey v2.0

; ============================================================================
; CONFIGURACIÓN Y VARIABLES GLOBALES
; ============================================================================

hiddenWindows := Map()
lastHidden := 0
workspaces := Map()
workspaceFile := A_ScriptDir "\workspaces.json"

; ============================================================================
; CONFIGURACIÓN DE EXCLUSIONES
; ============================================================================
; Añade aquí los procesos que NO quieres guardar en espacios de trabajo

excludedProcesses := [
    ; Ventanas del sistema
    "ShellExperienceHost.exe",
    "TextInputHost.exe",
    "ApplicationFrameHost.exe",
    "StartMenuExperienceHost.exe",
    "SearchHost.exe",
    ; AutoHotkey (este script)
    "AutoHotkey64.exe",
    "AutoHotkey32.exe",
    ; Barras de sistema y overlays
    "yasb.exe",                    ; YASB bar
    "mondrian.exe",                ; Mondrian window manager
    ; Utilidades que no necesitas restaurar
    "Twinkle Tray.exe",            ; Twinkle Tray
    "explorer.exe",                ; Program Manager
    ; Añade más procesos aquí según necesites
    ; "nombre_proceso.exe",
]

; Títulos de ventanas a excluir (usa expresiones regulares)
excludedTitles := [
    "YasbBar",
    "Program Manager",
    "Twinkle Tray Panel",
    ; Añade más títulos aquí
    ; "Ventana temporal",
]

; ============================================================================

; Configuración de la bandeja del sistema
TraySetIcon("shell32.dll", 44)
A_IconTip := "Gestor de ventanas y espacios de trabajo"

; Inicializar menú
A_TrayMenu.Delete()
A_TrayMenu.Add("No hay ventanas ocultas", (*) => 0)
A_TrayMenu.Disable("No hay ventanas ocultas")
A_TrayMenu.Add()
A_TrayMenu.Add("Salir", (*) => ExitApp())

; ============================================================================
; ATAJOS DE TECLADO
; ============================================================================

; Ctrl + Shift + H → Ocultar ventana activa
^+h::
{
    global hiddenWindows, lastHidden

    hwnd := WinGetID("A")
    title := WinGetTitle("ahk_id " hwnd)

    if !title
        return

    if hiddenWindows.Has(hwnd)
        return

    WinHide("ahk_id " hwnd)
    hiddenWindows[hwnd] := title
    lastHidden := hwnd
    UpdateTrayMenu()
}

; Ctrl + Shift + M → Mostrar menú con todas las ventanas ocultas
^+m::
{
    UpdateTrayMenu()
    CoordMode("Menu", "Screen")
    MouseGetPos(&x, &y)
    A_TrayMenu.Show(x, y)
}

; Ctrl + Shift + L → Restaurar la última ventana oculta
^+l::
{
    global lastHidden, hiddenWindows

    if !lastHidden
        return

    DetectHiddenWindows(true)

    ; Verificar si la ventana sigue existiendo
    exists := WinExist("ahk_id " lastHidden)

    if !exists {
        ; Buscar otra ventana oculta para restaurar
        for hwnd, title in hiddenWindows {
            if WinExist("ahk_id " hwnd) {
                WinShow("ahk_id " hwnd)
                WinActivate("ahk_id " hwnd)
                hiddenWindows.Delete(hwnd)
                lastHidden := 0
                DetectHiddenWindows(false)
                UpdateTrayMenu()
                return
            }
        }
        ; No hay ventanas para restaurar
        hiddenWindows.Delete(lastHidden)
        lastHidden := 0
        DetectHiddenWindows(false)
        UpdateTrayMenu()
        return
    }

    WinShow("ahk_id " lastHidden)
    WinActivate("ahk_id " lastHidden)
    DetectHiddenWindows(false)

    hiddenWindows.Delete(lastHidden)
    lastHidden := 0
    UpdateTrayMenu()
}

; Ctrl + Alt + S → Guardar espacio de trabajo
^!s::
{
    SaveWorkspace()
}

; Ctrl + Alt + O → Cargar espacio de trabajo
^!o::
{
    LoadWorkspaceMenu()
}

; ============================================================================
; FUNCIONES
; ============================================================================

UpdateTrayMenu() {
    global hiddenWindows
    A_TrayMenu.Delete()

    if hiddenWindows.Count = 0 {
        A_TrayMenu.Add("📋 No hay ventanas ocultas", (*) => 0)
        A_TrayMenu.Disable("📋 No hay ventanas ocultas")
    } else {
        A_TrayMenu.Add("🪟 Ventanas ocultas: " hiddenWindows.Count, (*) => 0)
        A_TrayMenu.Disable("🪟 Ventanas ocultas: " hiddenWindows.Count)
        A_TrayMenu.Add()

        DetectHiddenWindows(true)
        for hwnd, title in hiddenWindows {
            if !WinExist("ahk_id " hwnd) {
                hiddenWindows.Delete(hwnd)
                continue
            }
            ; Truncar título si es muy largo
            displayTitle := StrLen(title) > 50 ? SubStr(title, 1, 50) "..." : title
            itemName := "   • " displayTitle
            A_TrayMenu.Add(itemName, RestoreWindow.Bind(hwnd))
        }
        DetectHiddenWindows(false)
        A_TrayMenu.Add()
        A_TrayMenu.Add("🔄 Restaurar todas", RestoreAll)
    }

    A_TrayMenu.Add()
    A_TrayMenu.Add("❌ Salir", (*) => ExitApp())
}

RestoreWindow(hwnd, *) {
    global hiddenWindows, lastHidden

    DetectHiddenWindows(true)
    if WinExist("ahk_id " hwnd) {
        WinShow("ahk_id " hwnd)
        WinActivate("ahk_id " hwnd)
    }
    DetectHiddenWindows(false)

    hiddenWindows.Delete(hwnd)
    if lastHidden = hwnd
        lastHidden := 0
    UpdateTrayMenu()
}

RestoreAll(*) {
    global hiddenWindows, lastHidden

    if hiddenWindows.Count = 0
        return

    DetectHiddenWindows(true)
    for hwnd, title in hiddenWindows.Clone() {
        if WinExist("ahk_id " hwnd)
            WinShow("ahk_id " hwnd)
        hiddenWindows.Delete(hwnd)
    }
    DetectHiddenWindows(false)

    lastHidden := 0
    UpdateTrayMenu()
}

; ============================================================================
; FUNCIONES DE ESPACIOS DE TRABAJO
; ============================================================================

SaveWorkspace(*) {
    global workspaces, workspaceFile, excludedProcesses, excludedTitles

    ; Pedir nombre del espacio de trabajo
    IB := InputBox("Nombre del espacio de trabajo:", "Guardar Espacio de Trabajo", "w300 h100")
    if IB.Result = "Cancel" || IB.Value = ""
        return

    wsName := IB.Value
    windows := []

    ; Obtener todas las ventanas visibles
    winList := WinGetList()
    for hwnd in winList {
        try {
            ; Solo ventanas visibles
            if !WinGetStyle("ahk_id " hwnd)
                continue

            title := WinGetTitle("ahk_id " hwnd)
            processName := WinGetProcessName("ahk_id " hwnd)

            ; Filtrar ventanas sin título, sin proceso o del sistema
            if !title || title = "" || !processName
                continue

            ; Filtrar procesos excluidos (de la configuración)
            skip := false
            for excludeProc in excludedProcesses {
                if processName = excludeProc {
                    skip := true
                    break
                }
            }
            if skip
                continue

            ; Filtrar títulos excluidos (de la configuración)
            for excludeTitle in excludedTitles {
                if InStr(title, excludeTitle) {
                    skip := true
                    break
                }
            }
            if skip
                continue

            processPath := WinGetProcessPath("ahk_id " hwnd)
            if !processPath || processPath = ""
                continue            ; Obtener posición y tamaño
            WinGetPos(&x, &y, &w, &h, "ahk_id " hwnd)

            windows.Push({
                title: title,
                process: processName,
                path: processPath,
                x: x,
                y: y,
                width: w,
                height: h
            })
        } catch {
            continue
        }
    }

    if windows.Length = 0 {
        MsgBox "No se encontraron ventanas para guardar", "Error", 48
        return
    }

    workspaces[wsName] := windows

    ; Intentar guardar y mostrar resultado
    result := SaveWorkspacesToFile()
    if result
        MsgBox "Espacio '" wsName "' guardado con " windows.Length " ventanas", "Éxito", 64
    else
        MsgBox "Error al guardar el espacio de trabajo", "Error", 16
}

LoadWorkspaceMenu(*) {
    global workspaces

    LoadWorkspacesFromFile()

    if workspaces.Count = 0 {
        MsgBox "No hay espacios de trabajo guardados", "Info", 64
        return
    }

    ; Crear menú de espacios de trabajo
    wsMenu := Menu()
    for wsName, windows in workspaces {
        wsMenu.Add(wsName " (" windows.Length " ventanas)", LoadWorkspace.Bind(wsName))
    }
    wsMenu.Add()
    wsMenu.Add("🗑️ Eliminar espacio...", DeleteWorkspaceMenu)

    CoordMode("Menu", "Screen")
    MouseGetPos(&x, &y)
    wsMenu.Show(x, y)
}

LoadWorkspace(wsName, *) {
    global workspaces

    if !workspaces.Has(wsName)
        return

    windows := workspaces[wsName]
    opened := 0
    failed := 0

    for winInfo in windows {
        try {
            ; Verificar si la aplicación existe
            if !FileExist(winInfo.path) {
                failed++
                continue
            }

            ; Abrir la aplicación
            Run winInfo.path
            opened++

            ; Esperar un poco entre ventanas
            Sleep 800

        } catch {
            failed++
            continue
        }
    }
}

DeleteWorkspaceMenu(*) {
    global workspaces, workspaceFile

    if workspaces.Count = 0
        return

    ; Crear lista de espacios de trabajo
    wsList := ""
    for wsName, windows in workspaces
        wsList .= wsName "`n"

    IB := InputBox("Nombre del espacio a eliminar:`n`n" wsList, "Eliminar Espacio de Trabajo", "w400 h250")
    if IB.Result = "Cancel" || IB.Value = ""
        return

    wsName := IB.Value
    if workspaces.Has(wsName) {
        workspaces.Delete(wsName)
        SaveWorkspacesToFile()
    }
}

SaveWorkspacesToFile() {
    global workspaces, workspaceFile

    try {
        ; Si no hay espacios, crear archivo vacío
        if workspaces.Count = 0 {
            FileDelete workspaceFile
            FileAppend "{}", workspaceFile, "UTF-8"
            return true
        }

        json := "{"
        first := true
        for wsName, windows in workspaces {
            if !first
                json .= ","
            first := false

            json .= '`n  "' wsName '": ['
            for i, winInfo in windows {
                if i > 1
                    json .= ","
                json .= '`n    {'
                json .= '`n      "title": "' StrReplace(winInfo.title, '"', '\"') '",'
                json .= '`n      "process": "' winInfo.process '",'
                json .= '`n      "path": "' StrReplace(winInfo.path, '\', '\\') '",'
                json .= '`n      "x": ' winInfo.x ','
                json .= '`n      "y": ' winInfo.y ','
                json .= '`n      "width": ' winInfo.width ','
                json .= '`n      "height": ' winInfo.height
                json .= '`n    }'
            }
            json .= '`n  ]'
        }
        json .= "`n}"

        ; Eliminar archivo anterior si existe
        if FileExist(workspaceFile)
            FileDelete workspaceFile

        ; Escribir nuevo archivo
        FileAppend json, workspaceFile, "UTF-8"

        ; Verificar que se creó
        return FileExist(workspaceFile) ? true : false

    } catch as err {
        MsgBox "Error guardando: " err.Message "`nArchivo: " workspaceFile, "Error", 16
        return false
    }
}

LoadWorkspacesFromFile() {
    global workspaces, workspaceFile

    workspaces := Map()

    if !FileExist(workspaceFile)
        return

    try {
        jsonText := FileRead(workspaceFile, "UTF-8")
        workspaces := ParseWorkspacesJSON(jsonText)
    } catch as err {
        MsgBox "Error al cargar espacios de trabajo: " err.Message, "Error", 16
    }
}

ParseWorkspacesJSON(jsonText) {
    wsMap := Map()

    ; Eliminar llaves externas y espacios
    jsonText := Trim(jsonText)
    jsonText := SubStr(jsonText, 2, StrLen(jsonText) - 2) ; Quitar { }

    ; Dividir por espacios de trabajo
    currentPos := 1
    while (currentPos < StrLen(jsonText)) {
        ; Buscar nombre del espacio de trabajo
        nameStart := InStr(jsonText, '"', false, currentPos)
        if !nameStart
            break
        nameEnd := InStr(jsonText, '"', false, nameStart + 1)
        wsName := SubStr(jsonText, nameStart + 1, nameEnd - nameStart - 1)

        ; Buscar el array de ventanas
        arrayStart := InStr(jsonText, "[", false, nameEnd)
        arrayEnd := FindMatchingBracket(jsonText, arrayStart)

        if !arrayEnd
            break

        arrayContent := SubStr(jsonText, arrayStart + 1, arrayEnd - arrayStart - 1)
        windows := ParseWindowsArray(arrayContent)

        wsMap[wsName] := windows
        currentPos := arrayEnd + 1
    }

    return wsMap
}

FindMatchingBracket(text, startPos) {
    level := 0
    loop parse, SubStr(text, startPos) {
        if A_LoopField = "["
            level++
        else if A_LoopField = "]" {
            level--
            if level = 0
                return startPos + A_Index - 1
        }
    }
    return 0
}

ParseWindowsArray(arrayText) {
    windows := []

    ; Dividir por objetos
    currentPos := 1
    while (currentPos < StrLen(arrayText)) {
        objStart := InStr(arrayText, "{", false, currentPos)
        if !objStart
            break

        objEnd := InStr(arrayText, "}", false, objStart)
        if !objEnd
            break

        objText := SubStr(arrayText, objStart + 1, objEnd - objStart - 1)
        winInfo := ParseWindowObject(objText)

        if winInfo
            windows.Push(winInfo)

        currentPos := objEnd + 1
    }

    return windows
}

ParseWindowObject(objText) {
    winInfo := {}

    try {
        ; Extraer cada campo
        winInfo.title := ExtractJSONValue(objText, "title")
        winInfo.process := ExtractJSONValue(objText, "process")
        winInfo.path := ExtractJSONValue(objText, "path")

        ; Extraer números con validación
        xVal := ExtractJSONValue(objText, "x")
        yVal := ExtractJSONValue(objText, "y")
        wVal := ExtractJSONValue(objText, "width")
        hVal := ExtractJSONValue(objText, "height")

        winInfo.x := (xVal != "") ? Integer(xVal) : 0
        winInfo.y := (yVal != "") ? Integer(yVal) : 0
        winInfo.width := (wVal != "") ? Integer(wVal) : 800
        winInfo.height := (hVal != "") ? Integer(hVal) : 600

        return winInfo
    } catch {
        return false
    }
}

ExtractJSONValue(text, key) {
    try {
        ; Buscar "key":
        searchStr := '"' key '":'
        pos := InStr(text, searchStr)
        if !pos
            return ""

        ; Avanzar después de los dos puntos
        pos := pos + StrLen(searchStr)

        ; Saltar espacios y saltos de línea
        while (pos <= StrLen(text)) {
            char := SubStr(text, pos, 1)
            if char = " " || char = "`n" || char = "`r" || char = "`t"
                pos++
            else
                break
        }

        if pos > StrLen(text)
            return ""

        ; Si es un string (empieza con ")
        if SubStr(text, pos, 1) = '"' {
            pos++
            endPos := InStr(text, '"', false, pos)
            if !endPos
                return ""
            value := SubStr(text, pos, endPos - pos)
            ; Reemplazar escapes
            value := StrReplace(value, "\\", "\")
            value := StrReplace(value, '\"', '"')
            return value
        }

        ; Si es un número
        endPos := pos
        while (endPos <= StrLen(text)) {
            char := SubStr(text, endPos, 1)
            if IsDigit(char) || char = "-" || char = "."
                endPos++
            else
                break
        }

        numStr := Trim(SubStr(text, pos, endPos - pos))
        return numStr

    } catch {
        return ""
    }
}

IsDigit(char) {
    return (char >= "0" && char <= "9")
}
