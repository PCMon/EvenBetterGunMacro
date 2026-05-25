#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

global ConfigLine := ["XButton1", "pistol sniper forcefield plasmapistol", "false"]
WeaponSlots := Map("nerfpistol", 1, "nerfrevolver", 2, "pistol", 3, "shotgun", 4, "rifle", 5, "revolver", 6, "flint", 7, "ak", 8, "sword", 9, "uzi", 10, "forcefield", 11, "plasmapistol", 12, "plasmashotgun", 13, "sniper", 14, "c4", 15, "c4buy", 16, "smoke", 17, "smokebuy", 18, "grenade", 19, "grenadebuy", 20, "rpgbuy", 21, "rpg", 22)
Theme := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "SystemUsesLightTheme")
if Theme = 1 {
    Theme := "Light"
} else if Theme = 0
    Theme := "Dark"
SleepTime := 30 ; 30ms enables consistent macro use on 60fps without sacrificing speed

A_TrayMenu.Delete()
SubMenuSettings := Menu()
SubMenuSettings.Add("Hotkey", HotkeyGUI.Bind(false))
SubMenuSettings.Add("Loadout", LoadoutGUI.Bind(false))
SubMenuSettings.Add("Nerf", NerfGUI.Bind(false))
A_TrayMenu.Add("EBGM Settings", SubMenuSettings)
A_TrayMenu.Add()
A_TrayMenu.Add("Fix (Clears Config)", EndApp.Bind(true))
A_TrayMenu.Add("Exit", EndApp)

Prevkey := ConfigLine[1]
if CheckForConfig() { ; Check for config and unpack if it exists, else run setup process
    ConfigLine := UnpackConfig()
    Hotkey(ConfigLine[1], Main)
}
else {
    WelcomeGUI(true)
}

Main(*) {
    WeaponSelection := ConfigLine[2]
    WeaponSelectionArray := StrSplit(WeaponSelection, A_Space)
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
        Window.SetFont("s11 cWhite", "Franklin Gothic")
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", Window.Hwnd, "int", 20, "int*", 1, "int", 4)
        Window.Add("Text",, "Welcome to EBGM! `n`nEverything submitted here can be edited after `nthe setup by right clicking EBGM in the system tray!")
        Button := Window.Add("Text", "x15 y85 w300 h35 Center +Border +0x0200 Background202020 cWhite", "Continue")
    } else if Theme = "Light" {
        Window.BackColor := "0xf3f3f3"
        Window.SetFont("s11 c000000", "Franklin Gothic")
        Window.Add("Text",, "Welcome to EBGM! `n`nEverything submitted here can be edited after `nthe setup by right clicking EBGM in the system tray!")
        Button := Window.Add("Text", "x15 y85 w300 h35 Center +Border +0x0200 Backgroundf3f3f3 cBlack", "Continue")
    }
    if OOBE = true {
        Button.OnEvent("Click", (*) => (Window.Destroy(), HotkeyGUI(true)))
    } else if OOBE = false {
        Button.OnEvent("Click", (*) => (Window.Destroy(), WriteToConfig()))
    }
    Window.Show()
}

HotkeyGUI(OOBE, *) {
    Prevkey := ConfigLine[1]
    try Hotkey(Prevkey, "Off")
    global Window := Gui("+LastFound", "EvenBetterGunMacro")
    if Theme = "Dark" {
        Window.BackColor := "0x202020"
        Window.SetFont("s11 cWhite", "Franklin Gothic")
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", Window.Hwnd, "int", 20, "int*", 1, "int", 4)
        Window.Add("Text",, "Please Enter a Hotkey:`n`nYou can make modifiers with characters such as:`n#(Win),  !(Alt),  ^(Ctrl),  +(Shift).")
        Window.Add("Link",, '<a href="https://www.autohotkey.com/docs/v2/KeyList.htm">Valid Hotkeys.</a>')
        EditBox := Window.Add("Edit", "w70 h20 Center -E0x0200 +Border +0x0200 Background202020 cWhite", ConfigLine[1])
        EditBox.Focus()
        Send("{End}")
        Button := Window.Add("Text", "x95 y112 w80 h20 Center +Border +0x0200 Background202020 cWhite", "Continue")
    } else if Theme = "Light" {
        Window.BackColor := "0xf3f3f3"
        Window.SetFont("s11 c000000", "Franklin Gothic")
        Window.Add("Text",, "Please Enter a Hotkey:`n`nYou can make modifiers with characters such as:`n#(Win),  !(Alt),  ^(Ctrl),  +(Shift).")
        Window.Add("Link",, '<a href="https://www.autohotkey.com/docs/v2/KeyList.htm">Valid Hotkeys.</a>')
        EditBox := Window.Add("Edit", "w70 h20 Center -E0x0200 +Border +0x0200 Backgroundf3f3f3 cBlack", ConfigLine[1])
        EditBox.Focus()
        Send("{End}")
        Button := Window.Add("Text", "x95 y112 w80 h20 Center +Border +0x0200 Backgroundf3f3f3 cBlack", "Continue")
    }
    if OOBE = true {
        Button.OnEvent("Click", (*) => (ConfigLine[1] := EditBox.Value, Window.Destroy(), LoadoutGUI(true), Hotkey(ConfigLine[1], Main)))
    } else if OOBE = false {
        Button.OnEvent("Click", (*) => (ConfigLine[1] := EditBox.Value, Window.Destroy(), WriteToConfig(), Hotkey(ConfigLine[1], Main)))
    }
    Window.Show()
}

LoadoutGUI(OOBE, *) {
    global Window := Gui("+LastFound", "EvenBetterGunMacro")
    if Theme = "Dark" {
        Window.BackColor := "0x202020"
        Window.SetFont("s11 cWhite", "Franklin Gothic")
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", Window.Hwnd, "int", 20, "int*", 1, "int", 4)
        Window.Add("Text",, "Please enter your loadout:`n`nSelections: nerfpistol nerfrevolver pistol shotgun rifle revolver flint ak sword uzi forcefield plasmapistol `nplasmashotgun sniper c4 c4buy smoke smokebuy grenade grenadebuy rpgbuy rpg`n`nExample: pistol revolver shotgun c4 c4buy forcefield.")
        EditBox := Window.Add("Edit", "w500 h20 -E0x0200 +Border +0x0200 Background202020 cWhite", ConfigLine[2])
        EditBox.Focus()
        Send("{End}")
        Button := Window.Add("Text", "x525 y112 w80 h20 Center +Border +0x0200 Background202020 cWhite", "Continue")
    } else if Theme = "Light" {
        Window.BackColor := "0xf3f3f3"
        Window.SetFont("s11 c000000", "Franklin Gothic")
        Window.Add("Text",, "Please enter your loadout:`n`nSelections: nerfpistol nerfrevolver pistol shotgun rifle revolver flint ak sword uzi forcefield plasmapistol `nplasmashotgun sniper c4 c4buy smoke smokebuy grenade grenadebuy rpgbuy rpg`n`nExample: pistol revolver shotgun c4 c4buy forcefield.")
        EditBox := Window.Add("Edit", "w500 h20 -E0x0200 +Border +0x0200 Backgroundf3f3f3 cBlack", ConfigLine[2])
        EditBox.Focus()
        Send("{End}")
        Button := Window.Add("Text", "x525 y112 w80 h20 Center +Border +0x0200 Backgroundf3f3f3 cBlack", "Continue")
    }
    if OOBE = true {
        Button.OnEvent("Click", (*) => (ConfigLine[2] := EditBox.Value, Window.Destroy(), NerfGUI(true)))
    } else if OOBE = false {
        Button.OnEvent("Click", (*) => (ConfigLine[2] := EditBox.Value, Window.Destroy(), WriteToConfig()))
    }
    Window.Show()
}

NerfGUI(OOBE, *) {
    global Window := Gui("+LastFound", "EvenBetterGunMacro")
    if Theme = "Dark" {
        Window.BackColor := "0x202020"
        Window.SetFont("s11 cWhite", "Franklin Gothic")
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", Window.Hwnd, "int", 20, "int*", 1, "int", 4)
        Window.Add("Text",, "One last thing...`n`nAre you a nerf owner?")
        ButtonYes := Window.Add("Text", "w80 h35 Center +Border +0x0200 Background202020 cWhite", "Yes")
        ButtonNo := Window.Add("Text", "x105 y72 w80 h35 Center +Border +0x0200 Background202020 cWhite", "No")
    } else if Theme = "Light" {
        Window.BackColor := "0xf3f3f3"
        Window.SetFont("s11 c000000", "Franklin Gothic")
        Window.Add("Text",, "One last thing...`n`nAre you a nerf owner?")
        ButtonYes := Window.Add("Text", "w80 h35 Center +Border +0x0200 Backgroundf3f3f3 cBlack", "Yes")
        ButtonNo := Window.Add("Text", "x105 y72 w80 h35 Center +Border +0x0200 Backgroundf3f3f3 cBlack", "No")
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
        Window.SetFont("s11 cWhite", "Franklin Gothic")
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", Window.Hwnd, "int", 20, "int*", 1, "int", 4)
        Window.Add("Text",, "All done! `nThank you for using EBGM!")
        Button := Window.Add("Text", "x15 y50 w200 h35 Center +Border +0x0200 Background202020 cWhite", "Done!")
    } else if Theme = "Light" {
        Window.BackColor := "0xf3f3f3"
        Window.SetFont("s11 c000000", "Franklin Gothic")
        Window.Add("Text",, "All done! `nThank you for using EBGM!")
        Button := Window.Add("Text", "x15 y50 w200 h35 Center +Border +0x0200 Backgroundf3f3f3 cBlack", "Done!")
    }
    Button.OnEvent("Click", (*) => (Window.Destroy(), WriteToConfig()))
    Window.Show()
}

WriteToConfig() {
    DirCreate A_AppData . "\..\LocalLow" "\EBGM\"
    ConfigFile := FileOpen(A_AppData . "\..\LocalLow" "\EBGM\Config.txt", "w")
    ConfigInformation := ConfigLine[1] "`n"
                        . ConfigLine[2] "`n"
                        . ConfigLine[3]
    ConfigFile.Write(ConfigInformation)
    ConfigFile.Close()
}

EndApp(DeleteConfig, *) {
    if DeleteConfig = true {
        try FileDelete A_AppData . "\..\LocalLow" "\EBGM\Config.txt"
        Reload()
    } else {
        ExitApp
    }
}
