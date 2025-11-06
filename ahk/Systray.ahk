; Script: window_hider_plus.ahk
#Requires AutoHotkey v2.0
#SingleInstance Force

hiddenWindows := Map()
lastHidden := 0

TraySetIcon("shell32.dll", 44)
A_IconTip := "Gestor de ventanas ocultas"

A_TrayMenu.Delete()
A_TrayMenu.Add("No hay ventanas ocultas", (*) => 0)
A_TrayMenu.Disable("No hay ventanas ocultas")
A_TrayMenu.Add()
A_TrayMenu.Add("Salir", (*) => ExitApp())

; Ctrl + Shift + H → Ocultar ventana activa
^+h::
{
    hwnd := WinGetID("A")
    title := WinGetTitle("ahk_id " hwnd)
    if !title
        return
    if hiddenWindows.Has(hwnd)
        return
    WinHide("ahk_id " hwnd)
    hiddenWindows[hwnd] := title
    lastHidden := hwnd
    ; MsgBox de depuración eliminado
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
    global lastHidden
    if lastHidden && WinExist("ahk_id " lastHidden) {
        WinShow("ahk_id " lastHidden)
        WinActivate("ahk_id " lastHidden)
        hiddenWindows.Delete(lastHidden)
        lastHidden := 0
        UpdateTrayMenu()
    }
}

UpdateTrayMenu() {
    global hiddenWindows
    A_TrayMenu.Delete()
    if hiddenWindows.Count = 0 {
        A_TrayMenu.Add("No hay ventanas ocultas", (*) => 0)
        A_TrayMenu.Disable("No hay ventanas ocultas")
    } else {
        DetectHiddenWindows(true)
        for hwnd, title in hiddenWindows {
            if !WinExist("ahk_id " hwnd) {
                hiddenWindows.Delete(hwnd)
                continue
            }
            itemName := "Ventana [" hwnd "]: " title
            A_TrayMenu.Add(itemName, RestoreWindow.Bind(hwnd))
        }
        DetectHiddenWindows(false)
        A_TrayMenu.Add() ; Separador solo si hay ventanas ocultas
    }
    A_TrayMenu.Add("Salir", (*) => ExitApp())
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
