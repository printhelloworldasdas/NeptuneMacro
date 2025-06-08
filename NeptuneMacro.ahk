#Persistent
#SingleInstance Force
SetTitleMatchMode, 2
SetBatchLines, -1

; --- Configuración Inicial ---
configFile := A_ScriptDir . "\config.ini"
global macroActivo := false
global autoClickerActivo := false
global webhookURL := ""
global modoCaminata := "Cuadrado"  ; Valor por defecto
global version := "v3.5"
global tiempoActivo := 0
global ciclosCompletados := 0
global ultimaEjecucion := "Nunca"
global pasoCuadrado := 0
global pasoZigZag := 0
global pasoTriangulo := 0
global pasoEstrella := 0
global pasoEspiral := 0
global pasoXSnake := 0
global autoClickDelay := 50 ; Valor por defecto autoclicker en ms
global size := 100 ; Tamaño base para patrones de movimiento
global TCLRKey := "A" ; Tecla para movimiento izquierda/derecha
global TCFBKey := "W" ; Tecla para movimiento adelante/atrás
global AFCLRKey := "D" ; Tecla alternativa izquierda/derecha
global AFCFBKey := "S" ; Tecla alternativa adelante/atrás

; --- Colores actualizados ---
colorFondo := "0x660000"           ; Rojo oscuro pero menos intenso que 0x330000 (fondo)
colorPrincipal := "0xF08080"       ; Rojo claro suave (botones principales)
colorSecundario := "0xCD5C5C"      ; Rojo medio claro (botones secundarios)
colorExito := "0x27AE60"           ; Verde éxito
colorTexto := "0xECF0F1"           ; Blanco suave
colorTextoOscuro := "0x95A5A6"     ; Gris claro
colorAdvertencia := "0xE67E22"     ; Naranja

; --- Leer Configuración ---
IniRead, webhookURL, %configFile%, Settings, Webhook, 
IniRead, modoCaminata, %configFile%, Settings, ModoCaminata, ZigZag
IniRead, autoClickDelay, %configFile%, Settings, AutoClickDelay, 50

; --- Crear Interfaz Gráfica ---
Gui, Color, %colorFondo%
Gui, Font, s11 c%colorTexto% Bold, Segoe UI

; Icono y título
Gui, Add, Picture, x10 y10 w40 h40, images\bee_icon.png
Gui, Add, Text, x60 y15 w300 h30 c%colorTexto%, NeptuneMacro %version%
Gui, Add, Text, x370 y15 w110 h20 c%colorTextoOscuro% Right, by Im_Troller

; Tabs con tema limpio
Gui, Font, s10 c%colorTexto%
Gui, Add, Tab2, x10 y55 w490 h255 vMainTab -Border, Macro|Settings|Stats|Info

; --- Pestaña Macro ---
Gui, Tab, Macro
Gui, Add, Picture, x20 y80 w48 h48, images\macro_icon.png
Gui, Add, Button, gIniciarMacro x80 y85 w160 h40 Background%colorPrincipal% c%colorTexto% +HwndhBtnStart, 🚀 Start Macron(F1)
Gui, Add, Button, gDetenerMacro x260 y85 w160 h40 Background%colorSecundario% c%colorTexto% +HwndhBtnStop, ⏹ Stop Macron(F2)

Gui, Add, GroupBox, x20 y140 w400 h90, Movement Mode
Gui, Add, DropDownList, vModoCaminataSel x40 y165 w360 Choose1 BackgroundFFF c000000, Standing|Cuadrado|ZigZag|XSnake
GuiControl, ChooseString, ModoCaminataSel, %modoCaminata%

; AutoClick Delay input
Gui, Add, Text, x20 y240 w180 h20 c%colorTexto%, AutoClick Delay (ms):
Gui, Add, Edit, vAutoClickDelayInput x200 y238 w80 h26 c000000 BackgroundFFF8DC -E0x200 Border, %autoClickDelay%

Gui, Add, StatusBar,, Status: Waiting...

; --- Pestaña Settings ---
Gui, Tab, Settings
Gui, Add, Picture, x20 y80 w48 h48, images\settings_icon.png
Gui, Add, Text, x80 y80 w140 h24 c%colorTextoOscuro%, Discord Webhook:
Gui, Add, Edit, vWebhookInput x80 y110 w340 h28 c000000 BackgroundFFF8DC -E0x200 Border, %webhookURL%
Gui, Add, Button, gGuardarConfiguracion x80 y150 w140 h36 Background%colorExito% c%colorTexto%, 💾 Save
Gui, Add, Button, gProbarWebhook x240 y150 w140 h36 Background%colorPrincipal% c%colorTexto%, 🔍 Test Webhook

Gui, Add, GroupBox, x20 y200 w440 h80, Advanced Settings
Gui, Add, CheckBox, vCheckNotificaciones x40 y225 w160 h26 Checked c%colorTexto%, Notifications
Gui, Add, CheckBox, vCheckSonido x240 y225 w160 h26 Checked c%colorTexto%, Sounds

; --- Pestaña Stats ---
Gui, Tab, Stats
Gui, Add, Picture, x20 y80 w48 h48, images\stats_icon.png
Gui, Add, Text, vTxtTiempoActivo x80 y85 w220 h26 c%colorTexto%, Active Time: 00:00:00
Gui, Add, Text, vTxtCiclos x80 y120 w220 h26 c%colorTexto%, Cycles Completed: 0
Gui, Add, Text, vTxtUltimaEjecucion x80 y155 w220 h26 c%colorTexto%, Last Run: Never
Gui, Add, Text, vTxtModoUsado x80 y190 w220 h26 c%colorTexto%, Mode Used: %modoCaminata%
Gui, Add, Button, gResetStats x80 y230 w140 h36 Background%colorAdvertencia% c%colorTexto%, 🔄 Reset Stats

; --- Pestaña Info ---
Gui, Tab, Info
Gui, Font, s12 c%colorTexto% Bold
Gui, Add, Text, x20 y90 w460 h40 Center, Created by Im_Troller
Gui, Font, s10 c%colorTextoOscuro%
Gui, Add, Text, x20 y140 w460 h80 Center, © 2023 Bee Macro Premium - All Rights Reserved.`nAll rights reserved.

; --- Botón salir en la esquina ---
Gui, Add, Button, gSalir x430 y315 w70 h28 Background666666 c%colorTexto%, ✖ Exit

; Set window icon and title
Menu, Tray, Icon, images\bee_icon.ico
Gui, Show, w510 h350 Center, NeptuneMacro
SB_SetText("Status: Ready | Mode: " . modoCaminata)

SetTimer, ActualizarTiempo, 1000
return

; --- Funciones Principales ---

GuardarConfiguracion:
    Gui, Submit, NoHide
    webhookURL := WebhookInput
    modoCaminata := ModoCaminataSel
    autoClickDelay := AutoClickDelayInput
    if (autoClickDelay < 1)
        autoClickDelay := 50  ; mínimo 1ms
    IniWrite, %webhookURL%, %configFile%, Settings, Webhook
    IniWrite, %modoCaminata%, %configFile%, Settings, ModoCaminata
    IniWrite, %autoClickDelay%, %configFile%, Settings, AutoClickDelay
    SB_SetText("Status: Settings saved | Mode: " . modoCaminata . " | Click Delay: " . autoClickDelay . "ms")
    MostrarNotificacion("✅ Settings saved", "Changes saved successfully.")
return

ProbarWebhook:
    EnviarWebhookEmbed("Webhook Test", "✅ Discord connection working!", 3066993)
    SB_SetText("Status: Webhook tested - check Discord")
    MostrarNotificacion("🔍 Webhook Tested", "Check your Discord channel.")
return

IniciarMacro:
    if (!macroActivo) {
        Gui, Submit, NoHide
        modoCaminata := ModoCaminataSel
        autoClickDelay := AutoClickDelayInput
        if (autoClickDelay < 1)
            autoClickDelay := 50
        ultimaEjecucion := A_Now
        macroActivo := true
        pasoCuadrado := 0
        pasoZigZag := 0
        pasoXSnake := 0
        tiempoActivo := 0
        ciclosCompletados := 0
        SB_SetText("Status: Starting macro in 2 seconds...")
        Sleep, 2000
        SetTimer, Movimiento, 100
        SB_SetText("Status: Macro ACTIVE (" . modoCaminata . ") | F2 to stop")
        MostrarNotificacion("🐝 Macro Active", "Mode: " . modoCaminata)
        EnviarWebhookEmbed("Macro Activated", "✅ Macro ACTIVE in mode: " . modoCaminata, 3066993)
        GuiControl,, TxtUltimaEjecucion, Last Run: %A_Hour%:%A_Min%:%A_Sec%
        GuiControl,, TxtModoUsado, Mode Used: %modoCaminata%
        GuiControl,, TxtTiempoActivo, Active Time: 00:00:00
        GuiControl,, TxtCiclos, Cycles Completed: 0
        Gosub, IniciarAutoClicker
    }
return

DetenerMacro:
    if (macroActivo) {
        macroActivo := false
        SetTimer, Movimiento, Off
        Gosub, DetenerAutoClicker
        SB_SetText("Status: Macro STOPPED | Mode: " . modoCaminata)
        MostrarNotificacion("⏹ Macro Stopped", "Collection stopped.")
        EnviarWebhookEmbed("Macro Stopped", "⛔ Macro STOPPED (Mode: " . modoCaminata . ")", 15158332)
    }
return

Walk(duration) {
    Sleep, duration
    Click
}

Movimiento:
if (!macroActivo)
    return

Send, {W up}{A up}{S up}{D up}

if (modoCaminata = "Standing") {
    ; No movement, just click
    Click
    Sleep, 1000
    ciclosCompletados++
    GuiControl,, TxtCiclos, Cycles Completed: %ciclosCompletados%
}
else if (modoCaminata = "Cuadrado") {
    if (pasoCuadrado = 0) {
        Send, {W down}
        Sleep, 1200
        Send, {W up}
        Click
        pasoCuadrado := 1
    }
    else if (pasoCuadrado = 1) {
        Send, {D down}
        Sleep, 1200
        Send, {D up}
        Click
        pasoCuadrado := 2
    }
    else if (pasoCuadrado = 2) {
        Send, {S down}
        Sleep, 1200
        Send, {S up}
        Click
        pasoCuadrado := 3
    }
    else if (pasoCuadrado = 3) {
        Send, {A down}
        Sleep, 1200
        Send, {A up}
        Click
        pasoCuadrado := 0
    }
    ciclosCompletados++
    GuiControl,, TxtCiclos, Cycles Completed: %ciclosCompletados%
}
else if (modoCaminata = "ZigZag") {
    if (pasoZigZag = 0) {
        ; Move forward 3 times
        Send, {W down}
        Sleep, 500
        Send, {W up}
        Click
        Sleep, 300
        Send, {W down}
        Sleep, 500
        Send, {W up}
        Click
        Sleep, 300
        Send, {W down}
        Sleep, 500
        Send, {W up}
        Click
        pasoZigZag := 1
    }
    else if (pasoZigZag = 1) {
        ; Move right
        Send, {D down}
        Sleep, 500
        Send, {D up}
        pasoZigZag := 2
    }
    else if (pasoZigZag = 2) {
        ; Move backward 3 times
        Send, {S down}
        Sleep, 500
        Send, {S up}
        Click
        Sleep, 300
        Send, {S down}
        Sleep, 500
        Send, {S up}
        Click
        Sleep, 300
        Send, {S down}
        Sleep, 500
        Send, {S up}
        Click
        pasoZigZag := 3
    }
    else if (pasoZigZag = 3) {
        ; Move right to return to starting position
        Send, {D down}
        Sleep, 500
        Send, {D up}
        pasoZigZag := 0
    }
    ciclosCompletados++
    GuiControl,, TxtCiclos, Cycles Completed: %ciclosCompletados%
}
else if (modoCaminata = "XSnake") {
    reps := 1 ; Puedes ajustar para más repeticiones

    loop, %reps% {
        Send, {%TCLRKey% down}
        Walk(4 * size)
        Send, {%TCLRKey% up}{%TCFBKey% down}
        Walk(2 * size)
        Send, {%TCFBKey% up}{%AFCLRKey% down}
        Walk(8 * size)
        Send, {%AFCLRKey% up}{%TCFBKey% down}
        Walk(2 * size)
        Send, {%TCFBKey% up}{%TCLRKey% down}
        Walk(8 * size)
        Send, {%TCLRKey% up}{%AFCLRKey% down}{%AFCFBKey% down}
        Walk(Sqrt((8 * size) ** 2 + (8 * size) ** 2))
        Send, {%AFCLRKey% up}{%AFCFBKey% up}{%TCLRKey% down}
        Walk(8 * size)
        Send, {%TCLRKey% up}{%TCFBKey% down}
        Walk(2 * size)
        Send, {%TCFBKey% up}{%AFCLRKey% down}
        Walk(8 * size)
        Send, {%AFCLRKey% up}{%TCFBKey% down}
        Walk(6.7 * size)
        Send, {%TCFBKey% up}{%TCLRKey% down}
        Walk(8 * size)
        Send, {%TCLRKey% up}{%AFCFBKey% down}
        Walk(2 * size)
        Send, {%AFCFBKey% up}{%AFCLRKey% down}
        Walk(8 * size)
        Send, {%AFCLRKey% up}{%AFCFBKey% down}
        Walk(2 * size)
        Send, {%AFCFBKey% up}{%TCLRKey% down}
        Walk(8 * size)
        Send, {%TCLRKey% up}{%AFCFBKey% down}
        Walk(2 * size)
        Send, {%AFCFBKey% up}{%AFCLRKey% down}
        Walk(8 * size)
        Send, {%AFCLRKey% up}{%AFCFBKey% down}
        Walk(3 * size)
        Send, {%AFCFBKey% up}{%TCLRKey% down}
        Walk(8 * size)
        Send, {%TCLRKey% up}{%TCFBKey% down}{%AFCLRKey% down}
        Walk(Sqrt((4 * size) ** 2 + (4 * size) ** 2))
        Send, {%TCFBKey% up}{%AFCLRKey% up}
    }

    ciclosCompletados++
    GuiControl,, TxtCiclos, Cycles Completed: %ciclosCompletados%
}
return

; --- Auto Clicker ---

IniciarAutoClicker:
    if (!autoClickerActivo) {
        autoClickerActivo := true
        SetTimer, AutoClickerTimer, %autoClickDelay%
        SB_SetText("Status: AutoClicker ACTIVE (" . autoClickDelay . "ms) | F2 to stop")
        MostrarNotificacion("🖱️ AutoClicker Active", "AutoClicker started with delay " . autoClickDelay . "ms.")
    }
return

DetenerAutoClicker:
    if (autoClickerActivo) {
        autoClickerActivo := false
        SetTimer, AutoClickerTimer, Off
        SB_SetText("Status: AutoClicker STOPPED")
        MostrarNotificacion("🛑 AutoClicker Stopped", "AutoClicker stopped.")
    }
return

AutoClickerTimer:
if (autoClickerActivo and macroActivo) {
    Click
}
return

; --- Hotkeys ---

F1::
    Gosub, IniciarMacro
return

F2::
    Gosub, DetenerMacro
return

; --- Temporizador para actualizar tiempo activo ---

ActualizarTiempo:
if (macroActivo) {
    tiempoActivo++
    horas := Floor(tiempoActivo / 3600)
    minutos := Floor(Mod(tiempoActivo, 3600) / 60)
    segundos := Mod(tiempoActivo, 60)
    tiempoFormateado := Format("{:02}:{:02}:{:02}", horas, minutos, segundos)
    GuiControl,, TxtTiempoActivo, Active Time: %tiempoFormateado%
}
return

ResetStats:
    tiempoActivo := 0
    ciclosCompletados := 0
    GuiControl,, TxtTiempoActivo, Active Time: 00:00:00
    GuiControl,, TxtCiclos, Cycles Completed: 0
    SB_SetText("Status: Stats reset")
    MostrarNotificacion("🔄 Stats Reset", "Statistics have been reset.")
return

MostrarNotificacion(titulo, mensaje) {
    Gui, Submit, NoHide
    if (CheckNotificaciones)
        TrayTip, %titulo%, %mensaje%, 1, 1
    if (CheckSonido)
        SoundPlay, *-1
}

EnviarWebhookEmbed(titulo, descripcion, color := 3447003) {
    global webhookURL
    if (webhookURL = "")
        return
    embedJson := "{""title"": """ titulo """, ""description"": """ descripcion """, ""color"": " color "}"
    json := "{""embeds"": [" embedJson "]}"
    try {
        http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        http.Open("POST", webhookURL, false)
        http.SetRequestHeader("Content-Type", "application/json")
        http.Send(json)
    } catch e {
        SB_SetText("Status: Webhook error")
    }
}

GuiEscape:
GuiClose:
Salir:
    if (macroActivo) {
        SetTimer, Movimiento, Off
        SetTimer, AutoClickerTimer, Off
        EnviarWebhookEmbed("Macro Closed", "📴 Macro was closed while active.", 10038562)
    }
    ExitApp
return
