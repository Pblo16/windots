; AHK v2
#SingleInstance Force

; Atajo global: Win + E para abrir FilePilot
!e:: {
    Run EnvGet("USERPROFILE") "\AppData\Local\Voidstar\FilePilot\FPilot.exe"
}

!+e:: Run "explorer.exe"
!Enter:: Run "warp", , "min"

!+Enter:: Run "wt"

; Atajo global: Ctrl + Alt + N
^!n:: {
    if WinActive("ahk_exe Warp.exe") {
        ; Enviar Ctrl+Shift+P y comando para crear nueva pestaña PowerShell
        Send "^+p"
        Sleep 120
        Send "create new tab: powershell"
        Sleep 100
        Send "{Enter}"
    }
}

; Atajo global: Ctrl + Alt + Shift + N
^!+n:: {
    if WinActive("ahk_exe Warp.exe") {
        ; Enviar Ctrl+Shift+P y comando para crear nueva ventana PowerShell
        Send "^+p"
        Sleep 120
        Send "create new window: powershell"
        Sleep 100
        Send "{Enter}"
    }
}

/* Close active window shortcuts */
!+q:: Send "!{F4}"  ; Alt + Shift + Q

; --- Hot Reload manual ---
^!r::  ; Ctrl + Alt + R
{
    Reload()
}
