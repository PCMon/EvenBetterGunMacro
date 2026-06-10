; Howdy ^-^

#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent
Loadouts := ["pistol flint sniper nerfrevolver", "rpg shotgun plasmapistol c4"]
LoadoutNames := ["Default", "Main"]
global ConfigLine := ["", "", "", "false"]
WeaponSlots := Map("nerfpistol", 1, "nerfrevolver", 2, "pistol", 3, "shotgun", 4, "rifle", 5, "revolver", 6, "flint", 7, "ak", 8, "sword", 9, "uzi", 10, "forcefield", 11, "plasmapistol", 12, "plasmashotgun", 13, "sniper", 14, "c4", 15, "c4buy", 16, "smoke", 17, "smokebuy", 18, "grenade", 19, "grenadebuy", 20, "rpgbuy", 21, "rpg", 22)

UsesLightTheme := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "SystemUsesLightTheme") ; get system light/darkmode preference
Font := "Segoe UI"
if UsesLightTheme = 1 {
    UsesLightTheme := true
    GUIBackColor := "0xf3f3f3"
    ButtonBackColor := "0xdadada"
    GUITextColor := "cBlack"
} else {
    UsesLightTheme := false
    GUIBackColor := "0x202020"
    ButtonBackColor := "0x2c2c2c"
    GUITextColor := "CWhite"
}
Height := SizeTestGUI("Height")

A_TrayMenu.Delete() ; delete default tray objects
if UsesLightTheme = false { ; enable darkmode tray if system preference matches
    TrayDarkMode()
}

SubMenuSettings := Menu()
SubMenuSettings.Add("Hotkey", HotkeyGUI.Bind(false))
SubMenuSettings.Add("Loadout", LoadoutGUI.Bind(false))
SubMenuSettings.Add("Sub 60 Compat", ToggleSub60Compat)
LoadoutMenu := Menu()

A_TrayMenu.Add("EBGM Settings", SubMenuSettings)
A_TrayMenu.Add()
A_TrayMenu.Add("Fix (Clears Config)", EndApp.Bind(true))
A_TrayMenu.Add("Exit", EndApp)

Prevkey := ConfigLine[1]
if CheckForConfig() { ; Check for config and unpack if it exists, else run setup process
    ConfigLine := UnpackConfig()
    Hotkey(ConfigLine[1], Main)
    if !CheckForUINav() {
        UIWarnGUI(false)
    }
    try { ; fallback for pre-v2.0 config files
        if ConfigLine[4] != "true" and ConfigLine[4] != "false" {
            ConfigLine[4] := "false"
            WriteToConfig()
        }
    } if IndexError {
        ConfigLine.Push("false")
        WriteToConfig()
    }
    if ConfigLine[4] = "true" {
        SubMenuSettings.Check("Sub 60 Compat")
    }
} else {
    WelcomeGUI(true)
}

Main(*) { ; main macro logic
    WeaponSelection := ConfigLine[2]
    WeaponSelectionArray := StrSplit(WeaponSelection, A_Space)
    if ConfigLine[4] = "true" {
        SleepTime := 60
    } else {
        SleepTime := 30
    }
    Send "\"
    Send "{LEFT}"
    Send "{LEFT}"
    Send "{RIGHT}"
    Send "{RIGHT}"
    Send "{RIGHT}"
    global CurrentSlot := 1
    global CurrentPage := 1
    for Weapon in WeaponSelectionArray {
        if WeaponSlots.Has(Weapon) {
            global SlotDest := WeaponSlots[Weapon]
        } else {
            MsgBox("Invalid weapon name, '" Weapon "'. Please ensure your weapon's name is spelled and formatted correctly as described in the loadout settings.")
        }
        if SlotDest < 15 {
            if CurrentPage != 1 {
                Loop CurrentSlot - 14 {
                    Send "{LEFT}"
                }
                Send "{UP}"
                Send ("{Enter}")
                Sleep SleepTime
                Send "{RIGHT}"
                CurrentSlot := 1
                CurrentPage := 1
            }
            if ConfigLine[3] = "false" {
                SlotDest := SlotDest - 2
            }
            SlotsToMove := SlotDest - CurrentSlot
            if SlotsToMove >0 {
                global DirectionToMove := "{RIGHT}"
            }
            if SlotsToMove <0 {
                global DirectionToMove := "{LEFT}"
                global SlotsToMove := Abs(SlotsToMove)
            }
            if SlotsToMove != 0 {
                Loop SlotsToMove {
                    Send DirectionToMove
                }
            }
            Send ("{Enter}")
            CurrentSlot := SlotDest
        }
        if SlotDest > 14 {
            if CurrentPage != 2 {
                Loop CurrentSlot {
                    Send "{LEFT}"
                }
                Send ("{Enter}")
                Sleep SleepTime
                Send "{RIGHT}"
                CurrentPage := 2
                CurrentSlot := 15
            }
            SlotsToMove := SlotDest - CurrentSlot
            if SlotsToMove >0 {
                global DirectionToMove := "{RIGHT}"
            }
            if SlotsToMove <0 {
                global DirectionToMove := "{LEFT}"
                global SlotsToMove := Abs(SlotsToMove)
            }
            if SlotsToMove != 0 {
                Loop SlotsToMove {
                    Send DirectionToMove
                }
            }
            if (Weapon = "c4buy" or Weapon = "rpgbuy" or Weapon = "grenadebuy") {
                loop 10 {
                    Send ("{Enter}")
                }
            } else if Weapon = "smokebuy" {
                loop 3 {
                    Send ("{Enter}")
                }
            } else {
                Send ("{Enter}")
            }
            CurrentSlot := SlotDest
        }
    }
    if CurrentPage = 2 {
        CurrentSlot := CurrentSlot - 14
    }
    loop CurrentSlot + 1 {
        Send "{LEFT}"
    }
    Send ("{Enter}")
    Send "\"
}

; GUIS
WelcomeGUI(OOBE, *) {
    global Window := Gui("+LastFound -MinimizeBox -MaximizeBox", "EvenBetterGunMacro")
    DllCalls()
    Window.BackColor := GUIBackColor
    Window.SetFont("bold s13 q5 " GUITextColor, Font)
    Window.Add("Text",, "Welcome to EBGM!")
    Window.SetFont("norm s10 q5 " GUITextColor, Font)
    TextElement := Window.Add("Text",, "Everything submitted here can be edited after `nthe setup by right clicking EBGM in the system tray!")
    TextElement.GetPos(, &TextY, &TextWidth, &TextHeight)
    InteractableHeight := TextY + TextHeight + 10
    Button := Window.Add("Text", "x15 y" interactableHeight " w" TextWidth " h35 Center +0x0200 Background" ButtonBackColor " " GUITextColor, "Continue")
    if CheckForUINav() {
        Button.OnEvent("Click", (*) => (Window.Destroy(), HotkeyGUI(true)))
    } else if !CheckForUINav() {
        Button.OnEvent("Click", WelcomeCheckAndPass)
        WelcomeCheckAndPass(*) {
            Window.Destroy()
            UIWarnGUI(true)
        }
    }
    Window.Show()
}

HotkeyGUI(OOBE, *) {
    Prevkey := ConfigLine[1]
    try Hotkey(Prevkey, "Off")
    global Window := Gui("+LastFound -MinimizeBox -MaximizeBox", "EvenBetterGunMacro")
    DllCalls()
    Window.BackColor := GUIBackColor
    Window.SetFont("bold s13 q5 " GUITextColor, Font)
    Window.Add("Text",, "Please enter a hotkey:")
    Window.SetFont("norm s10 q5 " GUITextColor, Font)
    Text := Window.Add("Text",, "You can make modifiers with characters such as:`n#(Win),  !(Alt),  ^(Ctrl),  +(Shift).")
    Text.GetPos(, &TextY, , &TextHeight)
    InteractableHeight := TextY + TextHeight + 15
    Window.GetPos(, , &WindowWidth)
    Window.Add("Link", "x" WindowWidth + 215 " y13", '<a href="https://www.autohotkey.com/docs/v2/KeyList.htm">Valid Hotkeys.</a>')
    EditBox := Window.Add("Edit", "x20 y" InteractableHeight " w70 h" Height + 4 " Center -E0x0200 +0x0200 Background" ButtonBackColor " " GUITextColor, ConfigLine[1])
    EditBox.Focus()
    Send("{End}")
    Button := Window.Add("Text", "x100 y" InteractableHeight " w80 h" Height + 4 " Center +0x0200 Background" ButtonBackColor " " GUITextColor, "Continue")
    if OOBE = true {
        Button.OnEvent("Click", HotkeyCheckAndPassOOBE)
        invalidHotkey := false
        HotkeyCheckAndPassOOBE(*) {
            try {
                Hotkey(EditBox.Value, (*) => "")
            } catch Error {
                invalidHotkey := true
                Window.Destroy()
                CustomGUI("Please enter a valid hotkey.", true, "Ok")
                HotkeyGUI(true)
            }
            if invalidHotkey = false {
                ConfigLine[1] := EditBox.Value
                Window.Destroy()
                LoadoutGUI(true)
                Hotkey(ConfigLine[1], Main)
            }
        }
    } else if OOBE = false {
        Button.OnEvent("Click", HotkeyCheckAndPass)
        invalidHotkey := false
        HotkeyCheckAndPass(*) {
            try {
                Hotkey(EditBox.Value, (*) => "")
            } catch Error {
                invalidHotkey := true
                Window.Destroy()
                CustomGUI("Please enter a valid hotkey.", true, "Ok")
                HotkeyGUI(false)
            }
            if invalidHotkey = false {
                ConfigLine[1] := EditBox.Value
                Window.Destroy()
                WriteToConfig()
                Hotkey(ConfigLine[1], Main)
            }
        }
    }
    Window.Show()
}

LoadoutsGUI(*) {
    Window := Gui("+LastFound -MinimizeBox -MaximizeBox", "EvenBetterGunMacro")
    DllCalls()
    Window.BackColor := GUIBackColor
}

LoadoutGUI(OOBE, *) {
    try {
        if ConfigLine[3] = "true" {
            NerfState := true
        } else {
            NerfState := false
        }
    } catch Error {
        NerfState := false
    }
    WeaponSelection := ConfigLine[2]
    global Window := Gui("+LastFound -MinimizeBox -MaximizeBox", "EvenBetterGunMacro")
    DllCalls()
    Window.BackColor := GUIBackColor
    Window.SetFont("bold s15 q5 " GUITextColor, Font)
    Window.Add("Text",, "Please enter a loadout:")
    Window.SetFont("norm s10 q5 " GUITextColor, Font)
    Window.Add("Text",, "Selections: nerfpistol nerfrevolver pistol shotgun rifle revolver flint ak sword uzi forcefield plasmapistol `nplasmashotgun sniper c4 c4buy smoke smokebuy grenade grenadebuy rpgbuy rpg`n(c4buy and rpgbuy automatically grab ten.)`n`nExample: pistol revolver shotgun c4 c4buy forcefield.")
    EditBox := Window.Add("Edit", "x20 y154 w512 h" Height + 4 " -E0x0200 +0x0200 Background" ButtonBackColor " " GUITextColor, WeaponSelection)
    EditBox.Focus()
    Send("{End}")
    Button := Window.Add("Text", "x540 y154 w80 h" Height + 4 " h" Height + 4 " Center +0x0200 Background" ButtonBackColor " " GUITextColor, "Continue")
    Button.GetPos(&ButtonX,&ButtonY,&ButtonWidth,&ButtonHeight)
    Window.Add("Text", "x" (ButtonX + ButtonWidth) - 55 " y" (ButtonY - ButtonHeight) - 8 " Center +0x0200 " GUITextColor, "Nerf? ")
    if NerfState {
        NerfButton := Window.Add("Text", "x" (ButtonX + ButtonWidth) - 17 " y" (ButtonY - ButtonHeight) - 8 " w17 h17 Center +0x0200 Background" ButtonBackColor " " GUITextColor, "✓")
    } else if !NerfState {
        NerfButton := Window.Add("Text", "x" (ButtonX + ButtonWidth) - 17 " y" (ButtonY - ButtonHeight) - 8 " w17 h17 Center +0x0200 Background" ButtonBackColor " " GUITextColor, "")
    }
    Button.OnEvent("Click", LoadoutCheckAndPassOOBE)
    NerfButton.OnEvent("Click", ToggleNerf)
    ToggleNerf(*) {
        NerfState := !NerfState
        if NerfState {
            NerfButton.Text := "✓"
        } else {
            NerfButton.Text := ""
        }
    }
    LoadoutCheckAndPassOOBE(*) {
        invalidWeapon := false
        invalidWeaponList := "" 
        if NerfState {
            ConfigLine[3] := "true"
        } else {
            ConfigLine[3] := "false"
        }
        if EditBox.Value = "" {
            invalidWeapon := true
        }
        WeaponSelection := EditBox.Value
        WeaponSelection := RegExReplace(WeaponSelection, " +", " ")
        WeaponSelection := Trim(WeaponSelection, " ")
        WeaponSelectionArray := StrSplit(WeaponSelection, A_Space)
        if WeaponSelection != "" {
            for Weapon in WeaponSelectionArray {
                if !WeaponSlots.Has(Weapon) {
                    invalidWeaponList := invalidWeaponList ", " Weapon
                    invalidWeapon := true
                }
            }
            if invalidWeapon = true {
                Window.Destroy()
                invalidWeaponList := SubStr(invalidWeaponList, 3)
                CustomGUI("Invalid weapon name(s) '" invalidWeaponList "'. `nPlease ensure your weapon's name is`nspelled and formatted correctly as shown on this menu.", true, "Ok")
                LoadoutGUI(OOBE)
            } else {
                ConfigLine[2] := WeaponSelection
                Window.Destroy()
                if OOBE {
                    CompleteGUI()
                } else {
                    WriteToConfig()
                }
            }
        } else {
            Window.Destroy()
            CustomGUI("Please enter a loadout.", true, "Ok")
            LoadoutGUI(OOBE)
        }
    }
    Window.Show()
}

CompleteGUI() {
    global Window := Gui("+LastFound -MinimizeBox -MaximizeBox", "EvenBetterGunMacro")
    DllCalls()
    Window.BackColor := GUIBackColor
    Window.SetFont("bold s11 q5 " GUITextColor, Font)
    BigText := Window.Add("Text",, "All done!")
    BigText.GetPos(&BigTextX,,,&BigTextHeight)
    Window.SetFont("norm s10 q5 " GUITextColor, Font)
    Text := Window.Add("Text", "x" BigTextX " y" BigTextHeight + 20, "Your settings will be saved and`nwill take effect on each startup.`nThank you for using EBGM!")
    Text.GetPos(, &TextY, &TextWidth, &TextHeight)
    InteractableHeight := TextY + TextHeight + 5
    Button := Window.Add("Text", "x15 y" InteractableHeight " w" TextWidth " h35 Center +0x0200 Background" ButtonBackColor " " GUITextColor, "Finish!")
    Button.OnEvent("Click", (*) => (Window.Destroy(), WriteToConfig()))
    Window.Show()
}

UIWarnGUI(OOBE, *) {
    global Window := Gui("+LastFound -MinimizeBox -MaximizeBox", "EvenBetterGunMacro")
    DllCalls()
    Window.Backcolor := GUIBackColor
    Window.SetFont("bold s11 q5 " GUITextColor, Font)
    Window.Add("Text",, "Warning!")
    Window.SetFont("norm s10 q5 " GUITextColor, Font)
    Window.Add("Text",, "EBGM Requires UI Navigation to be enabled, choose approach...")
    ChangeAndRestart := Window.Add("Text", "x15 y70 w400 h35 Center +0x0200 Background" ButtonBackColor " " GUITextColor, "Change Setting and Restart Roblox")
    Change := Window.Add("Text", "x15 y110 w197 h35 Center +0x0200 Background" ButtonBackColor " " GUITextColor, "Change Setting")
    LeaveAlone := Window.Add("Text", "x218 y110 w197 h35 Center +0x0200 Background" ButtonBackColor " " GUITextColor, "Do Nothing")
    if OOBE = true {
        ChangeAndRestart.OnEvent("Click", (*) => (Window.Destroy(), EnableUINav(), RestartRoblox(), HotkeyGUI(true)))
        Change.OnEvent("Click", (*) => (Window.Destroy(), EnableUINav(), HotkeyGUI(true)))
        LeaveAlone.OnEvent("Click", (*) => (Window.Destroy(), HotkeyGUI(true)))
    } else if OOBE = false {
        ChangeAndRestart.OnEvent("Click", (*) => (Window.Destroy(), EnableUINav(), RestartRoblox()))
        Change.OnEvent("Click", (*) => (Window.Destroy(), EnableUINav()))
        LeaveAlone.OnEvent("Click", (*) => (Window.Destroy()))
    }
    Window.Show()
}

CustomGUI(Text, Button, ButtonText) {
    Global Window := Gui("+LastFound -MinimizeBox -MaximizeBox", "EvenBetterGunMacro")
    DllCalls()
    Window.BackColor := GUIBackColor
    Window.SetFont("norm s10 q5 " GUITextColor, Font)
    TextElement := Window.Add("Text",, Text)
    if Button {
        TextElement.GetPos(, , &TextWidth)
        ButtonHeight := TextWidth
        ButtonHeight := ButtonHeight / 30 + 30
        Button := Window.Add("Text", "w" TextWidth " h" ButtonHeight " Center +0x0200 Background" ButtonBackColor " " GUITextColor, ButtonText)
        Button.OnEvent("Click", Process)
        Process(*) {
            Window.Destroy()
        }
    }
    Window.Show()
    WinWaitClose("ahk_id " Window.Hwnd)
}

SizeTestGUI(Request) {
    Window := Gui("+LastFound -MinimizeBox -MaximizeBox", "EvenBetterGunMacro")
    Window.SetFont("norm s10 q5 " GUITextColor, Font)
    TextHeight := Window.Add("Text", "Hidden", "Wq")
    TextWidth := Window.Add("Text", "Hidden", "MW")
    TextHeight.GetPos(, , , &Height)
    TextWidth.GetPos(, , &Width)
    if Request = "Width" {
        Return Width
    } else if Request = "Height" {
        return Height
    } else {
        return "Unknown Request."
    }
}

DllCalls() {
    if !UsesLightTheme {
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", Window.Hwnd, "int", 20, "int*", 1, "int", 4)
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", Window.Hwnd, "UInt", 34, "Ptr*", GUIBackColor, "UInt", 4)
    }
    Margins := Buffer(16)
    NumPut("int", 0, Margins, 0)
    NumPut("int", 0, Margins, 4)
    NumPut("int", 0, Margins, 8)
    NumPut("int", 0, Margins, 12)
    DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", Window.Hwnd, "UInt", 33, "Ptr*", 1, "UInt", 4)
    DllCall("dwmapi\DwmExtendFrameIntoClientArea", "Ptr", Window.Hwnd, "Ptr", Margins)
}

; Config
WriteToConfig() {
    DirCreate A_AppData . "\..\LocalLow" "\EBGM\"
    ConfigFile := FileOpen(A_AppData . "\..\LocalLow" "\EBGM\Config.txt", "w")
    ConfigInformation := ConfigLine[1] "`n"
                        . ConfigLine[2] "`n"
                        . ConfigLine[3] "`n"
                        . ConfigLine[4]
    ConfigFile.Write(ConfigInformation)
    ConfigFile.Close()
}

CheckForConfig() { ; Check LocalLow for Config File
    if FileExist(A_AppData . "\..\LocalLow" "\EBGM\Config.txt") {
        return true
    }
    else {
        return false
    }
}

UnpackConfig() { ; Extract and Array Config Data
    Line := StrSplit(FileRead(A_AppData . "\..\LocalLow" "\EBGM\Config.txt"), "`n", "`r")
    return Line
}

TrayDarkMode() {
    if (VerCompare(A_OSVersion, "10.0.17763") >= 0) {
        DWMWA_USE_IMMERSIVE_DARK_MODE := (VerCompare(A_OSVersion, "10.0.18985") >= 0) ? 20 : 19
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", A_ScriptHwnd, "Int", DWMWA_USE_IMMERSIVE_DARK_MODE, "Int*", True, "Int", 4)
        uxtheme := DllCall("kernel32\GetModuleHandle", "Str", "uxtheme", "Ptr")
        SetPreferredAppMode := DllCall("kernel32\GetProcAddress", "Ptr", uxtheme, "Ptr", 135, "Ptr")
        FlushMenuThemes := DllCall("kernel32\GetProcAddress", "Ptr", uxtheme, "Ptr", 136, "Ptr")
        DllCall(SetPreferredAppMode, "Int", 2) 
        DllCall(FlushMenuThemes)
    }
}

CheckForUINav() {
    Config := StrSplit(FileRead(A_AppData . "\..\Local" "\Roblox\GlobalBasicSettings_13.xml"), "`n", "`r")
    for Line in Config {
        if InStr(Line, "UiNavigationKeyBindEnabled") {
            if InStr(Line, "false") {
                return false
            } else {
                return true
            }
        }
    }
}

EnableUINav() {
    Config := FileRead(A_AppData . "\..\Local" "\Roblox\GlobalBasicSettings_13.xml")
    NewConfig := StrReplace(Config, '<bool name="UiNavigationKeyBindEnabled">false</bool>', '<bool name="UiNavigationKeyBindEnabled">true</bool>')
    ConfigFile := FileOpen(A_AppData . "\..\Local" "\Roblox\GlobalBasicSettings_13.xml", "w")
    ConfigFile.Write(NewConfig)
    ConfigFile.Close
}

ToggleSub60Compat(Name, Pos, Menu) {
    global ConfigLine
    if ConfigLine[4] = "false" {
        ConfigLine[4] := "true"
        Menu.Check(Name)
    } else {
        ConfigLine[4] := "false"
        menu.Uncheck(Name)
    }
    if FileExist(A_AppData . "\..\LocalLow" "\EBGM\Config.txt") {
        WriteToConfig()
    }
}

RestartRoblox() {
    if ProcessExist("RobloxPlayerBeta.exe") {
        ProcessClose("RobloxPlayerBeta.exe")
        ProcessWaitClose("RobloxPlayerBeta.exe", 5)
    }
    Run("roblox://")
}

EndApp(DeleteConfig, *) {
    if DeleteConfig = true {
        try FileDelete A_AppData . "\..\LocalLow" "\EBGM\Config.txt"
        Reload()
    } else {
        ExitApp
    }
}
