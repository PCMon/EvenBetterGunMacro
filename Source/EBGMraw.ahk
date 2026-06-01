; Howdy ^-^

#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

global ConfigLine := ["", "", "", "false"]
WeaponSlots := Map("nerfpistol", 1, "nerfrevolver", 2, "pistol", 3, "shotgun", 4, "rifle", 5, "revolver", 6, "flint", 7, "ak", 8, "sword", 9, "uzi", 10, "forcefield", 11, "plasmapistol", 12, "plasmashotgun", 13, "sniper", 14, "c4", 15, "c4buy", 16, "smoke", 17, "smokebuy", 18, "grenade", 19, "grenadebuy", 20, "rpgbuy", 21, "rpg", 22)

Theme := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "SystemUsesLightTheme") ; get system light/darkmode preference
if Theme = 1 {
    Theme := "Light"
} else if Theme = 0
    Theme := "Dark"

A_TrayMenu.Delete() ; delete default tray objects
if Theme = "Dark" { ; enable darkmode tray if system preference matches
    TrayDarkMode()
}

SubMenuSettings := Menu()
SubMenuSettings.Add("Hotkey", HotkeyGUI.Bind(false))
SubMenuSettings.Add("Loadout", LoadoutGUI.Bind(false))
SubMenuSettings.Add("Nerf", NerfGUI.Bind(false))
SubMenuSettings.Add("Sub 60 Compat", ToggleSub60Compat)
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
        MsgBox(SleepTime)
    } else {
        SleepTime := 30
        MsgBox(SleepTime)
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

; Config
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

; GUIS
WelcomeGUI(OOBE, *) {
    global Theme
    global Window := Gui("+LastFound", "EvenBetterGunMacro")
    if Theme = "Dark" {
        Window.BackColor := "0x202020"
        Window.SetFont("bold s13 q5 cWhite", "Segoe UI")
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", Window.Hwnd, "int", 20, "int*", 1, "int", 4)
        Window.Add("Text",, "Welcome to EBGM!")
        Window.SetFont("norm s10 q5 cWhite", "Segoe UI")
        Window.Add("Text",, "Everything submitted here can be edited after `nthe setup by right clicking EBGM in the system tray!")
        Button := Window.Add("Text", "x15 y89 w300 h35 Center +Border +0x0200 Background202020 cWhite", "Continue")
    } else if Theme = "Light" {
        Window.BackColor := "0xf3f3f3"
        Window.SetFont("bold s13 q5 c000000", "Segoe UI")
        Window.Add("Text",, "Welcome to EBGM!")
        Window.SetFont("norm s10 q5 c000000", "Segoe UI")
        Window.Add("Text",, "Everything submitted here can be edited after `nthe setup by right clicking EBGM in the system tray!")
        Button := Window.Add("Text", "x15 y89 w300 h35 Center +Border +0x0200 Backgroundf3f3f3 cBlack", "Continue")
    }
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
    global Window := Gui("+LastFound", "EvenBetterGunMacro")
    if Theme = "Dark" {
        Window.BackColor := "0x202020"
        Window.SetFont("bold s13 q5 cWhite", "Segoe UI")
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", Window.Hwnd, "int", 20, "int*", 1, "int", 4)
        Window.Add("Text",, "Please enter a hotkey:")
        Window.SetFont("norm s10 q5 cWhite", "Segoe UI")
        Window.Add("Text",, "You can make modifiers with characters such as:`n#(Win),  !(Alt),  ^(Ctrl),  +(Shift).")
        Window.Add("Link", "x225 y13", '<a href="https://www.autohotkey.com/docs/v2/KeyList.htm">Valid Hotkeys.</a>')
        EditBox := Window.Add("Edit", "x20 y100 w70 h21 Center -E0x0200 +Border +0x0200 Background202020 cWhite", ConfigLine[1])
        EditBox.Focus()
        Send("{End}")
        Button := Window.Add("Text", "x95 y100 w80 h21 Center +Border +0x0200 Background202020 cWhite", "Continue")
    } else if Theme = "Light" {
        Window.BackColor := "0xf3f3f3"
        Window.SetFont("bold s13 q5 c000000", "Segoe UI")
        Window.Add("Text",, "Please enter a hotkey:")
        Window.SetFont("norm s10 q5 c000000", "Segoe UI")
        Window.Add("Text",, "You can make modifiers with characters such as:`n#(Win),  !(Alt),  ^(Ctrl),  +(Shift).")
        Window.Add("Link", "x225 y13", '<a href="https://www.autohotkey.com/docs/v2/KeyList.htm">Valid Hotkeys.</a>')
        EditBox := Window.Add("Edit", "x20 y100 w70 h21 Center -E0x0200 +Border +0x0200 Backgroundf3f3f3 cBlack", ConfigLine[1])
        EditBox.Focus()
        Send("{End}")
        Button := Window.Add("Text", "x95 y100 w65 h21 Center +Border +0x0200 Backgroundf3f3f3 cBlack", "Continue")
    }
    if OOBE = true {
        Button.OnEvent("Click", HotkeyCheckAndPassOOBE)
        HotkeyCheckAndPassOOBE(*) {
            try {
                Hotkey(EditBox.Value, (*) => "")
                ConfigLine[1] := EditBox.Value
                Window.Destroy()
                LoadoutGUI(true)
                Hotkey(ConfigLine[1], Main)
            } catch Error {
                MsgBox("Please enter a valid hotkey.")
                Window.Destroy()
                HotkeyGUI(true)
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
                MsgBox("Please enter a valid hotkey.")
                Window.Destroy()
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

LoadoutGUI(OOBE, *) {
    global Window := Gui("+LastFound", "EvenBetterGunMacro")
    if Theme = "Dark" {
        Window.BackColor := "0x202020"
        Window.SetFont("bold s15 q5 cWhite", "Segoe UI")
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", Window.Hwnd, "int", 20, "int*", 1, "int", 4)
        Window.Add("Text",, "Please enter your loadout:")
        Window.SetFont("norm s10 q5 cWhite", "Segoe UI")
        Window.Add("Text",, "Selections: nerfpistol nerfrevolver pistol shotgun rifle revolver flint ak sword uzi forcefield plasmapistol `nplasmashotgun sniper c4 c4buy smoke smokebuy grenade grenadebuy rpgbuy rpg`n(c4buy and rpgbuy automatically grab ten.)`n`nExample: pistol revolver shotgun c4 c4buy forcefield.")
        EditBox := Window.Add("Edit", "x20 y154 w515 h21 -E0x0200 +Border +0x0200 Background202020 cWhite", ConfigLine[2])
        EditBox.Focus()
        Send("{End}")
        Button := Window.Add("Text", "x540 y154 w80 h21 Center +Border +0x0200 Background202020 cWhite", "Continue")
    } else if Theme = "Light" {
        Window.BackColor := "0xf3f3f3"
        Window.SetFont("bold s15 q5 c000000", "Segoe UI")
        Window.Add("Text",, "Please enter your loadout:")
        Window.SetFont("norm s10 q5 c000000", "Segoe UI")
        Window.Add("Text",, "Selections: nerfpistol nerfrevolver pistol shotgun rifle revolver flint ak sword uzi forcefield plasmapistol `nplasmashotgun sniper c4 c4buy smoke smokebuy grenade grenadebuy rpgbuy rpg`n(c4buy and rpgbuy automatically grab ten.)`n`nExample: pistol revolver shotgun c4 c4buy forcefield.")
        EditBox := Window.Add("Edit", "x20 y154 w515 h21 -E0x0200 +Border +0x0200 Backgroundf3f3f3 cBlack", ConfigLine[2])
        EditBox.Focus()
        Send("{End}")
        Button := Window.Add("Text", "x540 y154 w80 h21 Center +Border +0x0200 Backgroundf3f3f3 cBlack", "Continue")
    }
    if OOBE = true {
        Button.OnEvent("Click", LoadoutCheckAndPassOOBE)
        LoadoutCheckAndPassOOBE(*) {
            invalidWeapon := false
            if EditBox.Value = "" {
                invalidWeapon := true
            }
            WeaponSelection := EditBox.Value
            WeaponSelectionArray := StrSplit(WeaponSelection, A_Space)
            for Weapon in WeaponSelectionArray {
                if !WeaponSlots.Has(Weapon) {
                    MsgBox("Invalid weapon name, '" Weapon "'. Please ensure your weapon's name is spelled and formatted correctly as shown on this menu.")
                    invalidWeapon := true
                }
            }
            if invalidWeapon = true {
                ConfigLine[2] := EditBox.Value
                Window.Destroy()
                LoadoutGUI(true)
            } else {
                ConfigLine[2] := EditBox.Value
                Window.Destroy()
                NerfGUI(true)
            }
        }
    } else if OOBE = false {
        Button.OnEvent("Click", LoadoutCheckAndPass)
        LoadoutCheckAndPass(*) {
            invalidWeapon := false
            if EditBox.Value = "" {
                invalidWeapon := true
            }
            WeaponSelection := EditBox.Value
            WeaponSelectionArray := StrSplit(WeaponSelection, A_Space)
            for Weapon in WeaponSelectionArray {
                if !WeaponSlots.Has(Weapon) {
                    MsgBox("Invalid weapon name, '" Weapon "'. Please ensure your weapon's name is spelled and formatted correctly as shown on this menu.")
                    invalidWeapon := true
                }
            }
            if invalidWeapon = true {
                ConfigLine[2] := EditBox.Value
                Window.Destroy()
                LoadoutGUI(false)
            } else {
                ConfigLine[2] := EditBox.Value
                Window.Destroy()
                WriteToConfig()
            }
        }
    }
    Window.Show()
}

NerfGUI(OOBE, *) {
    global Window := Gui("+LastFound", "EvenBetterGunMacro")
    if Theme = "Dark" {
        Window.BackColor := "0x202020"
        Window.SetFont("bold s13 q5 cWhite", "Segoe UI")
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", Window.Hwnd, "int", 20, "int*", 1, "int", 4)
        Window.Add("Text",, "One last thing...")
        Window.SetFont("norm s10 q5 cWhite", "Segoe UI")
        Window.Add("Text",, "Are you a nerf owner?")
        ButtonYes := Window.Add("Text", "x17 y86 w80 h35 Center +Border +0x0200 Background202020 cWhite", "Yes")
        ButtonNo := Window.Add("Text", "x105 y86 w80 h35 Center +Border +0x0200 Background202020 cWhite", "No")
    } else if Theme = "Light" {
        Window.BackColor := "0xf3f3f3"
        Window.SetFont("bold s13 q5 c000000", "Segoe UI")
        Window.Add("Text",, "One last thing...")
        Window.SetFont("norm s10 q5 c000000", "Segoe UI")
        Window.Add("Text",, "Are you a nerf owner?")
        ButtonYes := Window.Add("Text", "w80 h35 Center +Border +0x0200 Backgroundf3f3f3 cBlack", "Yes")
        ButtonNo := Window.Add("Text", "x105 y86 w80 h35 Center +Border +0x0200 Backgroundf3f3f3 cBlack", "No")
    }
    if OOBE = true {
        ButtonYes.OnEvent("Click", (*) => (ConfigLine[3] := "true", Window.Destroy(), CompleteGUI()))
        ButtonNo.OnEvent("Click", (*) => (ConfigLine[3] := "false", Window.Destroy(), CompleteGUI()))
    } else if OOBE = false {
        ButtonYes.OnEvent("Click", (*) => (ConfigLine[3] := "true", Window.Destroy(), WriteToConfig()))
        ButtonNo.OnEvent("Click", (*) => (ConfigLine[3] := "false", Window.Destroy(), WriteToConfig()))
    }
    Window.Show()
}

CompleteGUI() {
    global Window := Gui("+LastFound", "EvenBetterGunMacro")
    if Theme = "Dark" {
        Window.BackColor := "0x202020"
        Window.SetFont("bold s11 q5 cWhite", "Segoe UI")
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", Window.Hwnd, "int", 20, "int*", 1, "int", 4)
        Window.Add("Text",, "All done!")
        Window.SetFont("norm s10 q5 cWhite", "Segoe UI")
        Window.Add("Text",, "All your settings have been saved`nand will take effect on each startup.`nThank you for using EBGM!")
        Button := Window.Add("Text", "x15 y100 w205 h35 Center +Border +0x0200 Background202020 cWhite", "Finish!")
    } else if Theme = "Light" {
        Window.BackColor := "0xf3f3f3"
        Window.SetFont("bold s11 q5 cBlack", "Segoe UI")
        Window.Add("Text",, "All done!")
        Window.SetFont("norm s10 q5 cBlack", "Segoe UI")
        Window.Add("Text",, "All your settings have been saved`nand will take effect on each startup.`nThank you for using EBGM!")
        Button := Window.Add("Text", "x15 y100 w205 h35 Center +Border +0x0200 Backgroundf3f3f3 cBlack", "Finish!")
    }
    Button.OnEvent("Click", (*) => (Window.Destroy(), WriteToConfig()))
    Window.Show()
}

UIWarnGUI(OOBE, *) {
    global Window := Gui("+LastFound", "EvenBetterGunMacro")
    if Theme = "Dark" {
        Window.Backcolor := "0x202020"
        Window.SetFont("bold s11 q5 cWhite", "Segoe UI")
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", Window.Hwnd, "int", 20, "int*", 1, "int", 4)
        Window.Add("Text",, "Warning!")
        Window.SetFont("norm s10 q5 cWhite", "Segoe UI")
        Window.Add("Text",, "EBGM Requires UI Navigation to be enabled, choose approach...")
        ChangeAndRestart := Window.Add("Text", "x15 y70 w400 h35 Center +Border +0x0200 Background202020 cWhite", "Change Setting and Restart Roblox")
        Change := Window.Add("Text", "x15 y110 w197 h35 Center +Border +0x0200 Background202020 cWhite", "Change Setting")
        LeaveAlone := Window.Add("Text", "x218 y110 w197 h35 Center +Border +0x0200 Background202020 cWhite", "Do Nothing")
    }
    if Theme = "Light" {
        Window.Backcolor := "0xf3f3f3"
        Window.SetFont("bold s11 q5 cBlack", "Segoe UI")
        Window.Add("Text",, "Warning!")
        Window.SetFont("norm s10 q5 cBlack", "Segoe UI")
        Window.Add("Text",, "EBGM Requires UI Navigation to be enabled, choose approach...")
        ChangeAndRestart := Window.Add("Text", "x15 y70 w400 h35 Center +Border +0x0200 Backgroundf3f3f3 cBlack", "Change Setting and Restart Roblox")
        Change := Window.Add("Text", "x15 y110 w197 h35 Center +Border +0x0200 Backgroundf3f3f3 cBlack", "Change Setting")
        LeaveAlone := Window.Add("Text", "x218 y110 w197 h35 Center +Border +0x0200 Backgroundf3f3f3 cBlack", "Do Nothing")
    }
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
    } else {
        ConfigLine[4] := "false"
    }
    if ConfigLine[4] = "true" {
        Menu.Check(Name)
        WriteToConfig()
    } else {
        menu.Uncheck(Name)
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
