; Howdy ^-^
version := "EBGM v2.6.2.0"

#Requires AutoHotkey v2.0
;@Ahk2Exe-SetVersion 2.6.2.0
#SingleInstance Force
Persistent

global ConfigLine := ["false", "false"]
global LoadoutNames := ["Default"]
global LoadoutHotkeys := [""]
global LoadoutWeapons := [""]
global LoadoutNerf := [""]
global LoadoutActive := ["true"]
global HotkeyStorage := [""]
global VehicleIDs := [""]
global VehicleHotkeys := [""]
global VehicleActive := [""]
global VehicleCustom := [""]
global AutoBuy := "false"
WeaponSlots := Map("nerfpistol", 1, "nerfrevolver", 2, "pistol", 3, "shotgun", 4, "rifle", 5, "revolver", 6, "flint", 7, "ak", 8, "sword", 9, "uzi", 10, "forcefield", 11, "plasmapistol", 12, "plasmashotgun", 13, "sniper", 14, "c4", 15, "c4buy", 16, "smoke", 17, "smokebuy", 18, "grenade", 19, "grenadebuy", 20, "rpgbuy", 21, "rpg", 22, "flashlight", 23, "binoculars", 24)

UsesLightTheme := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "SystemUsesLightTheme") ; get system light/darkmode preference
Font := "Segoe UI"
TextAntiAliasing := "q5" ; q3 = disabled, q4 = standard, q5 = cleartype
if UsesLightTheme = 1 { ; set color values for GUI elements based on system preference
    UsesLightTheme := true
    GUIBackColor := "0xf3f3f3"
    ButtonBackColor := "0xdadada"
    ButtonBackColorAlt := "0xd3d3d3"
    GUITextColor := "cBlack"
} else {
    UsesLightTheme := false
    GUIBackColor := "0x202020"
    ButtonBackColor := "0x2c2c2c"
    ButtonBackColorAlt := "0x3b3b3b"
    GUITextColor := "CWhite"
}
Height := SizeTestGUI("Height") ; gets height of set font for window formatting

A_TrayMenu.Delete() ; delete default tray objects
if UsesLightTheme = false { ; enable darkmode tray if system preference matches
    TrayDarkMode()
}

SubMenuSettings := Menu() ; assemble tray menu
SubMenuSettings.Add("Run on Startup", ToggleStartup)
SubMenuSettings.Add("Sub 60 Compat", ToggleSub60Compat)

ContactMenu := Menu()
ContactMenu.Add("Discord (Fast)", ContactDiscord)
ContactMenu.Add("X (Moderate)", ContactX)
ContactMenu.Add("Email (Slow)", ContactEmail)

A_TrayMenu.Add("Loadouts", LoadoutsGUI)
A_TrayMenu.Add("Vehicle Spawning", VehiclesGUI)
A_TrayMenu.Add("Heli AutoBuy", ToggleAutoBuy)
A_TrayMenu.Add()
A_TrayMenu.Add("EBGM Settings", SubMenuSettings)
A_TrayMenu.Add("Latest Version", BringToLatestPage)
A_TrayMenu.Add("Contact Me", ContactMenu)
A_TrayMenu.Add()
A_TrayMenu.Add("Fix (Deletes Data)", EndApp.Bind(true))
A_TrayMenu.Add("Exit", EndApp)
A_TrayMenu.Add(version, DummyFunction)
A_TrayMenu.Disable(version)

if !CheckForVehicles() {
    VehicleIDs[1] := "1"
    VehicleHotkeys[1] := "f4"
    VehicleActive[1] := "false"
    VehicleCustom[1] := "0"
    HotkeyStorage.Push("f4")
    WriteToVehicles()
}
if (!CheckForConfig() || !CheckForLoadouts()) { ; check if config/loadout files exist do not exist, or if pre-v2 files exist, deletes and runs OOBE if so
    try FileDelete A_AppData . "\..\LocalLow" "\EBGM\Config.txt"
    try FileDelete A_AppData . "\..\LocalLow" "\EBGM\ConfigV2.txt"
    try FileDelete A_AppData . "\..\LocalLow" "\EBGM\Loadouts.txt"
    try FileDelete A_AppData . "\..\LocalLow" "\EBGM\Vehicles.txt"
    A_TrayMenu.Disable("Loadouts")
    A_TrayMenu.Disable("Vehicle Spawning")
    ToggleStartup("Run on Startup", "", SubMenuSettings)
    WelcomeGUI(true)
} else { ; if passes, unpack config and loadout files
    ConfigLine := UnpackConfig()
    if !ConfigLine.Has(2) {
        ConfigLine.Push("true")
    }
    LoadoutNames := UnpackLoadouts("Names")
    LoadoutHotkeys := UnpackLoadouts("Hotkeys")
    LoadoutWeapons := UnpackLoadouts("Weapons")
    LoadoutNerf := UnpackLoadouts("Nerf")
    LoadoutActive := UnpackLoadouts("Active")
    VehicleIDs := UnpackVehicles("IDs")
    VehicleHotkeys := UnpackVehicles("Hotkeys")
    VehicleActive := UnpackVehicles("Active")
    VehicleCustom := UnpackVehicles("Custom")
    AutoBuy := UnpackVehicles("AutoBuy")
    for index, item in LoadoutNames {
        HotkeyStorage.Push(LoadoutHotkeys[index])
    }
    for index, item in VehicleHotkeys {
        HotkeyStorage.Push(VehicleHotkeys[index])
    }
    RefreshHotkeys(true)
    if !CheckForUINav() {
        UIWarnGUI(false)
    }
    if ConfigLine[1] = "true" {
        SubMenuSettings.Check("Sub 60 Compat")
    }
    if ConfigLine[2] = "true" {
        SubMenuSettings.Check("Run on Startup")
        try {
            FileDelete A_Startup "\EBGM.lnk"
        }
        FileCreateShortcut(A_ScriptFullPath, A_Startup "\EBGM.lnk")
    }
    if AutoBuy = "true" {
        A_TrayMenu.Check("Heli AutoBuy")
    }
    WriteToConfig()
    WriteToLoadout()
    WriteToVehicles()
    Hotkey("~F", HeliAutoBuy)
    Hotkey("~B", HeliAutoBuy)
}

; logic
Main(Weapons, Nerf, *) { ; gunstore logic
    if WinActive("ahk_exe RobloxPlayerBeta.exe") {
        WeaponSelectionArray := StrSplit(Weapons, A_Space)
        if ConfigLine[1] = "true" {
            SleepTime := 60
        } else {
            SleepTime := 30
        }
        TogglePlayerInputs("Disable")
        Send "\{DOWN}{LEFT}{LEFT}{RIGHT}{UP}{RIGHT}{RIGHT}"
        CurrentSlot := 1
        CurrentPage := 1
        for Weapon in WeaponSelectionArray {
            if WeaponSlots.Has(Weapon) {
                SlotDest := WeaponSlots[Weapon]
            } else {
                MsgBox("Invalid weapon name, '" Weapon "'. Please ensure your weapon's name is spelled and formatted correctly as described in the loadout settings.") ; LEGACY WARNING (you wont experience this unless you're editing the config file manually)
            }
            if SlotDest < 15 {
                if CurrentPage != 1 {
                    if CurrentPage = 2 {
                        SlotsToSubtract := 14
                    } else if CurrentPage = 3 {
                        SlotsToSubtract := 22
                    }
                    Loop CurrentSlot - SlotsToSubtract {
                        Send "{LEFT}"
                    }
                    Send "{UP}{Enter}"
                    Sleep SleepTime
                    Send "{RIGHT}"
                    CurrentSlot := 1
                    CurrentPage := 1
                }
                if Nerf = "false" {
                    SlotDest := SlotDest - 2
                }
                SlotsToMove := SlotDest - CurrentSlot
                if SlotsToMove > 0 {
                    DirectionToMove := "{RIGHT}"
                }
                if SlotsToMove < 0 {
                    DirectionToMove := "{LEFT}"
                    SlotsToMove := Abs(SlotsToMove)
                }
                if SlotsToMove != 0 {
                    Loop SlotsToMove {
                        Send DirectionToMove
                    }
                }
                Send "{Enter}"
                CurrentSlot := SlotDest
            }
            if SlotDest > 14 and SlotDest < 23 {
                if CurrentPage != 2 {
                    if CurrentPage = 1 {
                        SlotsToSubtract := 0
                    } else if CurrentPage = 3 {
                        SlotsToSubtract := 22
                    }
                    Loop CurrentSlot - SlotsToSubtract {
                        Send "{LEFT}"
                    }
                    Send "{Enter}"
                    Sleep SleepTime
                    Send "{RIGHT}"
                    CurrentPage := 2
                    CurrentSlot := 15
                }
                SlotsToMove := SlotDest - CurrentSlot
                if SlotsToMove > 0 {
                    DirectionToMove := "{RIGHT}"
                }
                if SlotsToMove < 0 {
                    DirectionToMove := "{LEFT}"
                    SlotsToMove := Abs(SlotsToMove)
                }
                if SlotsToMove != 0 {
                    Loop SlotsToMove {
                        Send DirectionToMove
                    }
                }
                if (Weapon = "c4buy" or Weapon = "rpgbuy" or Weapon = "grenadebuy") {
                    loop 10 {
                        Send "{Enter}"
                    }
                } else if Weapon = "smokebuy" {
                    loop 3 {
                        Send "{Enter}"
                    }
                } else {
                    Send "{Enter}"
                }
                CurrentSlot := SlotDest
            }
            if SlotDest > 22 {
                if CurrentPage != 3 {
                    if CurrentPage = 1 {
                        SlotsToSubtract := 0
                    } else if CurrentPage = 2 {
                        SlotsToSubtract := 14
                    }
                    Loop (CurrentSlot - SlotsToSubtract) - 1 {
                        Send "{LEFT}"
                    }
                    Send "{DOWN}{LEFT}{Enter}"
                    Sleep SleepTime
                    Send "{RIGHT}"
                    CurrentPage := 3
                    CurrentSlot := 23
                }
                SlotsToMove := SlotDest - CurrentSlot
                if SlotsToMove > 0  {
                    DirectionToMove := "{RIGHT}"
                }
                if SlotsToMove < 0 {
                    DirectionToMove := "{LEFT}"
                    SlotsToMove := Abs(SlotsToMove)
                }
                if SlotsToMove != 0 {
                    Loop SlotsToMove {
                        Send DirectionToMove
                    }
                }
                Send "{Enter}"
                CurrentSlot := SlotDest
            }
        }
        if CurrentPage = 2 {
            CurrentSlot := CurrentSlot - 14
        }
        if CurrentPage = 3 {
            CurrentSlot := CurrentSlot - 22
        }
        loop CurrentSlot + 1 {
            Send "{LEFT}"
        }
        Send "{Enter}\"
        TogglePlayerInputs("Enable")
    }
}

VehicleMain(CarID, CustomID, *) { ; vehicle spawning logic
    if WinActive("ahk_exe RobloxPlayerBeta.exe") {
        CarID := Integer(CarID)
        CustomID := Integer(CustomID)
        TogglePlayerInputs("Disable")
        Send "\{DOWN}{DOWN}{DOWN}"
        Loop 25 {
            Send "{LEFT}"
        }
        Send "{RIGHT}{Enter}{UP}{UP}{UP}{UP}{UP}{RIGHT}{RIGHT}{RIGHT}{RIGHT}{RIGHT}{LEFT}{UP}{LEFT}{LEFT}{Enter}{RIGHT}{RIGHT}{DOWN}"
        Row := Floor(CarID / 6)
        Column := Abs((Mod(CarID, 6)) - 6)
        Loop Column {
            Send "{LEFT}"
        }
        Loop Row * 2 {
            Send "{DOWN}"
        }
        Send "{Enter}\"
        TogglePlayerInputs("Enable")
        if CustomID != 0 { ; custom apply logic
            Attempts := 0
            Success := false
            while (Attempts < 20 && Success = false) {
                if WinActive("ahk_exe RobloxPlayerBeta.exe") {
                    Attempts := Attempts + 1
                    Sleep 50
                    WinGetPos &X, &Y, &W, &H, "ahk_exe RobloxPlayerBeta.exe"
                    LeftCornerX := (39 / 100) * W
                    LeftCornerY := (70 / 100) * H
                    RightCornerX := (61 / 100) * W
                    RightCornerY := H - 40
                    if PixelSearch(&Found1, &Found2, LeftCornerX, LeftCornerY, RightCornerX, RightCornerY, 0xD2425E, 0) {
                        Success := true
                        TogglePlayerInputs("Disable")
                        Send "\{DOWN}{DOWN}{DOWN}"
                        Loop 25 {
                            Send "{LEFT}"
                        }
                        Send "{RIGHT}{Enter}{UP}{UP}{DOWN}{Enter}"
                        Sleep 75
                        Send "{RIGHT}"
                        Row := Floor((CustomID - 1) / 5)
                        Column := Mod(CustomID - 1, 5)
                        Loop Column * 2 {
                            Send "{RIGHT}"
                        }
                        Loop Row * 2 {
                            Send "{DOWN}"
                        }
                        Send "{Enter}"
                        Sleep 75
                        Loop 4 {
                            Send "{UP}"
                        }
                        Send "{RIGHT}{RIGHT}{DOWN}{DOWN}{Enter}{DOWN}{Enter}\"
                        TogglePlayerInputs("Enable")
                    }
                }
            }
        }
    }
}

HeliAutoBuy(*) { ; logic for the heli autobuy
    if AutoBuy = "true" {
        Sleep 500
        if WinActive("ahk_exe RobloxPlayerBeta.exe") {

            WinGetPos &X, &Y, &W, &H, "ahk_exe RobloxPlayerBeta.exe"
            LeftCornerX := (39 / 100) * W
            LeftCornerY := (70 / 100) * H
            RightCornerX := (61 / 100) * W
            RightCornerY := H - 40
            
            if PixelSearch(&Found1, &Found2, LeftCornerX, LeftCornerY, RightCornerX, RightCornerY, 0xD2425E, 0) { ; check for speedometer
                if !PixelSearch(&Found3, &Found4, LeftCornerX, LeftCornerY, RightCornerX, RightCornerY, 0xB653B9, 0) { ; check for rocket fuel
                    if !PixelSearch(&Found3, &Found4, LeftCornerX, LeftCornerY, RightCornerX, RightCornerY, 0x832F36, 0) { ; check for missile bar
                        TogglePlayerInputs("Disable")
                        Send "\F{DOWN}{DOWN}{DOWN}{DOWN}{LEFT}{UP}{RIGHT}{UP}{ENTER}\"
                        TogglePlayerInputs("Enable")
                    }
                }
            }
        }
    }
}

; GUIS
WelcomeGUI(*) { ; welcome GUI for OOBE 
    A_TrayMenu.Disable("Loadouts")
    A_TrayMenu.Disable("Vehicle Spawning")
    global Window := Gui("+LastFound -MinimizeBox -MaximizeBox", "EvenBetterGunMacro")
    DllCalls()
    Window.BackColor := GUIBackColor
    Window.SetFont("bold s13 " TextAntiAliasing " " GUITextColor, Font)
    Window.Add("Text",, "Welcome to EBGM!")
    Window.SetFont("norm s10 " TextAntiAliasing " " GUITextColor, Font)
    TextElement := Window.Add("Text",, "Everything submitted here can be edited after `nthe setup by right clicking EBGM in the system tray!")
    TextElement.GetPos(, &TextY, &TextWidth, &TextHeight)
    InteractableHeight := TextY + TextHeight + 10
    Button := Window.Add("Text", "x15 y" interactableHeight " w" TextWidth " h35 Center +0x0200 Background" ButtonBackColor " " GUITextColor, "Continue")
    if CheckForUINav() {
        Button.OnEvent("Click", (*) => (Window.Destroy(), HotkeyGUI(true, 1, false)))
    } else {
        try
            Button.OnEvent("Click", WelcomeCheckAndPass)
        WelcomeCheckAndPass(*) {
            Window.Destroy()
            UIWarnGUI(true)
        }
    }
    Window.Show()
}

HotkeyGUI(OOBE, Index, Vehicle, *) { ; hotkey GUI for setting a profile's hotkey
    RefreshHotkeys(false)
    global Window := Gui("+LastFound -MinimizeBox -MaximizeBox", "EvenBetterGunMacro")
    DllCalls()
    Window.BackColor := GUIBackColor
    Window.SetFont("bold s13 " TextAntiAliasing " " GUITextColor, Font)
    Window.Add("Text",, "Please enter a hotkey:")
    Window.SetFont("norm s10 " TextAntiAliasing " " GUITextColor, Font)
    Text := Window.Add("Text",, "You can make modifiers with characters such as:`n#(Win),  !(Alt),  ^(Ctrl),  +(Shift).")
    Text.GetPos(, &TextY, , &TextHeight)
    InteractableHeight := TextY + TextHeight + 15
    Window.GetPos(, , &WindowWidth)
    Window.Add("Link", "x" WindowWidth + 215 " y13", '<a href="https://www.autohotkey.com/docs/v2/KeyList.htm">Valid Hotkeys.</a>')
    if Vehicle {
        EditBox := Window.Add("Edit", "x20 y" InteractableHeight " w70 h" Height + 4 " Center -E0x0200 +0x0200 Background" ButtonBackColor " " GUITextColor, VehicleHotkeys[Index])
    } else {
        EditBox := Window.Add("Edit", "x20 y" InteractableHeight " w70 h" Height + 4 " Center -E0x0200 +0x0200 Background" ButtonBackColor " " GUITextColor, LoadoutHotkeys[Index])
    }
    EditBox.Focus()
    Send "{End}"
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
                CustomGUI("Please enter a valid hotkey.", true, "Ok", HotkeyGUI, OOBE, Index, Vehicle)
            }
            if invalidHotkey = false {
                LoadoutHotkeys[1] := EditBox.Value
                Window.Destroy()
                LoadoutGUI(true, 1)
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
                CustomGUI("Please enter a valid hotkey.", true, "Ok", HotkeyGUI, OOBE, Index, Vehicle)
            }
            if invalidHotkey = false {
                if Vehicle {
                    VehicleHotkeys[Index] := EditBox.Value
                    HotkeyStorage.Push(EditBox.Value)
                    Window.Destroy()
                    RefreshHotkeys(true)
                    WriteToVehicles()
                    VehiclesGUI()
                } else {
                    LoadoutHotkeys[Index] := EditBox.Value
                    HotkeyStorage.Push(EditBox.Value)
                    Window.Destroy()
                    RefreshHotkeys(true)
                    WriteToLoadout()
                    LoadoutsGUI()                    
                }
            }
        }
    }
    Window.Show()
}

LoadoutGUI(OOBE, Index, *) { ; loadout GUI for setting a profile's loadout
    RefreshHotkeys(false)
    try {
        if LoadoutNerf[Index] = "true" {
            NerfState := true
        } else {
            NerfState := false
        }
    } catch Error {
        NerfState := false
    }
    global Window := Gui("+LastFound -MinimizeBox -MaximizeBox", "EvenBetterGunMacro")
    DllCalls()
    Window.BackColor := GUIBackColor
    Window.SetFont("bold s15 " TextAntiAliasing " " GUITextColor, Font)
    Window.Add("Text",, "Please enter a loadout:")
    Window.SetFont("norm s10 " TextAntiAliasing " " GUITextColor, Font)
    Window.Add("Text",, "Selections: nerfpistol nerfrevolver pistol shotgun rifle revolver flint ak sword uzi forcefield plasmapistol `nplasmashotgun sniper c4 c4buy smoke smokebuy grenade grenadebuy rpgbuy rpg flashlight binoculars`n(c4buy and rpgbuy automatically grab ten.)`n`nExample: pistol revolver shotgun c4 c4buy forcefield.")
    EditBox := Window.Add("Edit", "x20 y154 w512 h" Height + 4 " -E0x0200 +0x0200 Background" ButtonBackColor " " GUITextColor, LoadoutWeapons[Index])
    EditBox.Focus()
    Send "{End}"
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
            LoadoutNerf[Index] := "true"
        } else {
            LoadoutNerf[Index] := "false"
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
                CustomGUI("Invalid weapon name(s) '" invalidWeaponList "'. `nPlease ensure your weapon's name is`nspelled and formatted correctly as shown on this menu.", true, "Ok", LoadoutGUI, OOBE, Index, false)
            } else {
                LoadoutWeapons[Index] := WeaponSelection
                Window.Destroy()
                if OOBE {
                    CompleteGUI()
                } else {
                    WriteToLoadout()
                    RefreshHotkeys(true)
                    LoadoutsGUI()
                }
            }
        } else {
            Window.Destroy()
            CustomGUI("Please enter a loadout.", true, "Ok", LoadoutGUI, OOBE, Index, false)
        }
    }
    Window.Show()
}

LoadoutsGUI(*) { ; loadouts GUI for managing profiles
    A_TrayMenu.Disable("Loadouts")
    A_TrayMenu.Disable("Vehicle Spawning")
    global Window := Gui("+LastFound -MinimizeBox -MaximizeBox", "EvenBetterGunMacro")
    DllCalls()
    Window.BackColor := GUIBackColor
    Window.SetFont("bold s11 " TextAntiAliasing " " GUITextColor, Font)
    BigText := Window.Add("Text",, "Manage Loadouts:")
    BigText.GetPos(&BigTextX,,,&BigTextHeight)
    Window.SetFont("norm s10 " TextAntiAliasing " " GUITextColor, Font)
    NameCategory := Window.Add("Text", "x" BigTextX " y" BigTextHeight + 20 " w75 h" Height + 4 " Center +0x0200 Background" ButtonBackColorAlt " " GUITextColor, "Name")
    NameCategory.GetPos(&CategoryX, &CategoryY, &CategoryWidth, &CategoryHeight)
    LoadoutCategory := Window.Add("Text", "x" BigTextX + 75 " y" BigTextHeight + 20 " w400 h" Height + 4 " Center +0x0200 Background" ButtonBackColor " " GUITextColor, "Loadout")
    HotkeyCategory := Window.Add("Text", "x" BigTextX + 475 " y" BigTextHeight + 20 " w75 h" Height + 4 " Center +0x0200 Background" ButtonBackColorAlt " " GUITextColor, "Hotkey")
    NerfCategory := Window.Add("Text", "x" BigTextX + 550 " y" BigTextHeight + 20 " w75 h" Height + 4 " Center +0x0200 Background" ButtonBackColor " " GUITextColor, "Nerf")
    ActiveCategory := Window.Add("Text", "x" BigTextX + 625 " y" BigTextHeight + 20 " w" Height + 4 " h" Height + 4 " Center +0x0200 Background" ButtonBackColorAlt " " GUITextColor, "*")
    CreateLoadout := Window.Add("Text", "x" BigTextX + 550 " y" BigTextHeight - 5 " w" 79 + Height " h" Height + 4 " Center +0x0200 Background" ButtonBackColor " " GUITextColor, "+").OnEvent("Click", CreateNewLoadout)
    CreateNewLoadout(*) {
        LoadoutNames.Push("Default")
        LoadoutHotkeys.Push("f1")
        LoadoutWeapons.Push("pistol")
        LoadoutNerf.Push("false")
        LoadoutActive.Push("false")
        Window.Destroy()
        WriteToLoadout()
        RefreshHotkeys(true)
        LoadoutsGUI()
    }
    for index, item in LoadoutNames {
        CurrentIndex := index
        Window.Add("Text", "x" BigTextX " y" (CategoryY + (index * 22)) + 2  " w75 h" Height + 4 " Center +0x0200 Background" ButtonBackColorAlt " " GUITextColor, LoadoutNames[index]).OnEvent("Click", Name.Bind(Window, CurrentIndex))
        Name(Window, CurrentIndex, *) {
            Window.Destroy()
            NameGUI(CurrentIndex)
        }
        Window.Add("Text", "x" BigTextX + 75 " y" (CategoryY + (index * 22)) + 2  " w400 h" Height + 4 " Center +0x0200 Background" ButtonBackColor " " GUITextColor, "")
        Window.Add("Text", "x" BigTextX + 79 " y" (CategoryY + (index * 22)) + 2  " w392 h" Height + 4 " Center +0x0200 Background" ButtonBackColor " " GUITextColor, LoadoutWeapons[index]).OnEvent("Click", Loadout.Bind(Window, CurrentIndex))
        Loadout(Window, CurrentIndex, *) {
            Window.Destroy()
            LoadoutGUI(false, CurrentIndex)
        }
        Window.Add("Text", "x" BigTextX + 475 " y" (CategoryY + (index * 22)) + 2  " w75 h" Height + 4 " Center +0x0200 Background" ButtonBackColorAlt " " GUITextColor, LoadoutHotkeys[index]).OnEvent("Click", Hotkeys.Bind(Window, CurrentIndex))
        Hotkeys(Window, CurrentIndex, *) {
            Window.Destroy()
            HotkeyGUI(false, CurrentIndex, false)
        }
        Window.Add("Text", "x" BigTextX + 550 " y" (CategoryY + (index * 22)) + 2 " w75 h" Height + 4 " Center +0x0200 Background" ButtonBackColor " " GUITextColor, LoadoutNerf[index])
        if LoadoutActive[CurrentIndex] = "true" {
            marker := "✓"
        } else {
            marker := "X"
        }
        ActiveLoadout := Window.Add("Text", "x" BigTextX + 625 " y" (CategoryY + (index * 22)) + 2 " w" Height + 4 " h" Height + 4 " Center +0x0200 Background" ButtonBackColorAlt " " GUITextColor, marker).OnEvent("Click", ToggleActive.Bind(Window, CurrentIndex))
        ToggleActive(Window, CurrentIndex, *) {
            Window.Destroy()
            if LoadoutActive[CurrentIndex] = "true" {
                LoadoutActive[CurrentIndex] := "false"
            } else if LoadoutActive[CurrentIndex] = "false" {
                LoadoutActive[CurrentIndex] := "true"
            }
            WriteToLoadout()
            RefreshHotkeys(true)
            LoadoutsGUI()
        }
        Delete := Window.Add("Text", "x" BigTextX + 650 " y" (CategoryY + (index * 22)) + 2 " w50" " h" Height + 4 " Center +0x0200 Background" ButtonBackColor " " GUITextColor, "Delete").OnEvent("Click", RemoveEntry.Bind(Window, CurrentIndex))
    }
    Window.Add("Text", "x" BigTextX + 550 " w150 h25 Center +0x0200 Background" ButtonBackColor " " GUITextColor, "Close").OnEvent("Click", (*) => ExitWindow())
    RemoveEntry(Window, CurrentIndex, *) {
        if LoadoutNames.Has(2) {
            LoadoutNames.RemoveAt(CurrentIndex)
            LoadoutHotkeys.RemoveAt(CurrentIndex)
            LoadoutWeapons.RemoveAt(CurrentIndex)
            LoadoutNerf.RemoveAt(CurrentIndex)
            LoadoutActive.RemoveAt(CurrentIndex)
        } else {
            HotkeyStorage.Push("f1")
            LoadoutNames[1] := "Default"
            LoadoutHotkeys[1] := "f1"
            LoadoutWeapons[1] := "pistol"
            LoadoutNerf[1] := "false"
            LoadoutActive[1] := "false"
        }
        WriteToLoadout()
        Window.Destroy()
        RefreshHotkeys(true)
        LoadoutsGUI()
    }
    Window.OnEvent("Close", ExitWindow)
    ExitWindow(*) {
        A_TrayMenu.Enable("Loadouts")
        A_TrayMenu.Enable("Vehicle Spawning")
        Window.Destroy()
    }
    Window.Show()
}

VehiclesGUI(*) { ; manager GUI for vehicle spawning
    A_TrayMenu.Disable("Loadouts")
    A_TrayMenu.Disable("Vehicle Spawning")
    global Window := Gui("+LastFound -MinimizeBox -MaximizeBox", "EvenBetterGunMacro")
    DllCalls()
    Window.BackColor := GUIBackColor
    Window.SetFont("bold s11 " TextAntiAliasing " " GUITextColor, Font)
    BigText := Window.Add("Text",, "Manage Vehicles:")
    BigText.GetPos(&BigTextX,,,&BigTextHeight)
    Window.SetFont("norm s7 " TextAntiAliasing " " GUITextColor, Font)
    Window.Add("Text", "x160 y10", "IMPORTANT: You must have at least six vehicles `nin your favorites in order for this to work!")
    Window.SetFont("norm s10 " TextAntiAliasing " " GUITextColor, Font)
    IDCategory := Window.Add("Text", "x" BigTextX " y" BigTextHeight + 20 " w100 h" Height + 4 " Center +0x0200 Background" ButtonBackColorAlt " " GUITextColor, "Vehicle ID")
    CustomCategory := Window.Add("Text", "x" BigTextX + 100 " y" BigTextHeight + 20 " w100 h" Height + 4 " Center +0x0200 Background" ButtonBackColor " " GUITextColor, "Custom ID")
    IDCategory.GetPos(&CategoryX, &CategoryY, &CategoryWidth, &CategoryHeight)
    HotkeyCategory := Window.Add("Text", "x" BigTextX + 200 " y" BigTextHeight + 20 " w100 h" Height + 4 " Center +0x0200 Background" ButtonBackColorAlt " " GUITextColor, "Hotkey")
    ActiveCategory := Window.Add("Text", "x" BigTextX + 300 " y" BigTextHeight + 20 " w" Height + 4 " h" Height + 4 " Center +0x0200 Background" ButtonBackColor " " GUITextColor, "*")
    CreateVehicle := Window.Add("Text", "x" BigTextX + 325 " y" CategoryHeight + 19 " w" 79 + Height " h" Height + 4 " Center +0x0200 Background" ButtonBackColorAlt " " GUITextColor, "+").OnEvent("Click", CreateNewVehicle)
    CreateNewVehicle(*) {
        VehicleIDs.Push("1")
        VehicleHotkeys.Push("f4")
        VehicleActive.Push("false")
        VehicleCustom.Push("0")
        Window.Destroy()
        WriteToVehicles()
        RefreshHotkeys(true)
        VehiclesGUI()
    }
    for index, item in VehicleIDs {
        CurrentIndex := index
        Window.Add("Text", "x" BigTextX " y" (CategoryY + (index * 22)) + 2  " w100 h" Height + 4 " Center +0x0200 Background" ButtonBackColorAlt " " GUITextColor, VehicleIDs[index]).OnEvent("Click", IDs.Bind(Window, CurrentIndex))
        IDs(Window, CurrentIndex, *) {
            Window.Destroy()
            IDsGUI(CurrentIndex, VehicleIDs)
        }
        Window.Add("Text", "x" BigTextX + 100 " y" (CategoryY + (index * 22)) + 2  " w100 h" Height + 4 " Center +0x0200 Background" ButtonBackColor " " GUITextColor, VehicleCustom[index]).OnEvent("Click", CustomID.Bind(Window, CurrentIndex))
        CustomID(Window, CurrentIndex, *) {
            Window.Destroy()
            IDsGUI(CurrentIndex, VehicleCustom)
        }
        Window.Add("Text", "x" BigTextX + 200 " y" (CategoryY + (index * 22)) + 2  " w100 h" Height + 4 " Center +0x0200 Background" ButtonBackColorAlt " " GUITextColor, VehicleHotkeys[index]).OnEvent("Click", Hotkeys.Bind(Window, CurrentIndex))
        Hotkeys(Window, CurrentIndex, *) {
            Window.Destroy()
            HotkeyGUI(false, CurrentIndex, true)
        }
        if VehicleActive[CurrentIndex] = "true" {
            marker := "✓"
        } else {
            marker := "X"
        }
        Window.Add("Text", "x" BigTextX + 300 " y" (CategoryY + (index * 22)) + 2 " w" Height + 4 " h" Height + 4 " Center +0x0200 Background" ButtonBackColor " " GUITextColor, marker).OnEvent("Click", ToggleVehicle.Bind(Window, CurrentIndex))
        ToggleVehicle(Window, CurrentIndex, *) {
            Window.Destroy()
            if VehicleActive[CurrentIndex] = "true" {
                VehicleActive[CurrentIndex] := "false"
            } else if VehicleActive[CurrentIndex] = "false" {
                VehicleActive[CurrentIndex] := "true"
            }
            WriteToVehicles()
            RefreshHotkeys(true)
            VehiclesGUI()
        }
        Delete := Window.Add("Text", "x" BigTextX + 325 " y" (CategoryY + (index * 22)) + 2 " w50" " h" Height + 4 " Center +0x0200 Background" ButtonBackColorAlt " " GUITextColor, "Delete").OnEvent("Click", RemoveEntry.Bind(Window, CurrentIndex))
        RemoveEntry(Window, CurrentIndex, *) {
            if VehicleIDs.Has(2) {
                VehicleIDs.RemoveAt(CurrentIndex)
                VehicleHotkeys.RemoveAt(CurrentIndex)
                VehicleActive.RemoveAt(CurrentIndex)
                VehicleCustom.RemoveAt(CurrentIndex)
            } else {
                HotkeyStorage.Push("f4")
                VehicleIDs[1] := "1"
                VehicleHotkeys[1] := "f4"
                VehicleActive[1] := "false"
                VehicleCustom[1] := "0"
            }
            WriteToVehicles()
            Window.Destroy()
            RefreshHotkeys(true)
            VehiclesGUI()
        }
    }
    Link := Window.Add("Link", "x15", '<a href="https://imgur.com/a/tI0Qalf">Vehicle ID Example.</a>')
    Link.GetPos(,&Y,,)
    Window.Add("Text", "x" BigTextX + 225 " y" Y " w" 79 + Height " h" Height + 4 " Center +0x0200 Background" ButtonBackColorAlt " " GUITextColor, "Close").OnEvent("Click", ExitWindow)
    Window.OnEvent("Close", ExitWindow)
    ExitWindow(*) {
        A_TrayMenu.Enable("Loadouts")
        A_TrayMenu.Enable("Vehicle Spawning")
        Window.Destroy()
    }
    Window.Show()
}

CompleteGUI() { ; complete GUI for OOBE
    global Window := Gui("+LastFound -MinimizeBox -MaximizeBox", "EvenBetterGunMacro")
    DllCalls()
    Window.BackColor := GUIBackColor
    Window.SetFont("bold s11 " TextAntiAliasing " " GUITextColor, Font)
    BigText := Window.Add("Text",, "All done!")
    BigText.GetPos(&BigTextX,,,&BigTextHeight)
    Window.SetFont("norm s10 " TextAntiAliasing " " GUITextColor, Font)
    Text := Window.Add("Text", "x" BigTextX " y" BigTextHeight + 20, "Your settings will be saved and`nwill take effect on each startup.`nThank you for using EBGM!")
    Text.GetPos(, &TextY, &TextWidth, &TextHeight)
    InteractableHeight := TextY + TextHeight + 5
    Button := Window.Add("Text", "x15 y" InteractableHeight " w" TextWidth " h35 Center +0x0200 Background" ButtonBackColor " " GUITextColor, "Finish!")
    Button.OnEvent("Click", Complete)
    Complete(*) {
        Window.Destroy()
        A_TrayMenu.Enable("Loadouts")
        A_TrayMenu.Enable("Vehicle Spawning")
        WriteToLoadout()
        WriteToConfig()
        VehicleIDs[1] := "1"
        VehicleHotkeys[1] := "f4"
        VehicleActive[1] := "false"
        WriteToVehicles()
        Hotkey(
            LoadoutHotkeys[1],
            Main.Bind(
                LoadoutWeapons[1],
                LoadoutNerf[1]
            )
        )
    }
    Window.Show()
}

NameGUI(Index, *) { ; name GUI for setting a profile's name
    global Window := Gui("+LastFound -MinimizeBox -MaximizeBox", "EvenBetterGunMacro")
    DllCalls()
    Window.BackColor := GUIBackColor
    Window.SetFont("bold s11 " TextAntiAliasing " " GUITextColor, Font)
    BigText := Window.Add("Text", "x27", "Enter a name:")
    BigText.GetPos(&BigTextX,,,&BigTextHeight)
    Window.SetFont("norm s10 " TextAntiAliasing " " GUITextColor, Font)
    BigText.GetPos(, &BigTextY, , &BigTextHeight)
    InteractableHeight := BigTextY + BigTextHeight + 15
    EditBox := Window.Add("Edit", "x13 y" InteractableHeight " w75 h" Height + 4 " Center -E0x0200 +0x0200 Background" ButtonBackColor " " GUITextColor, LoadoutNames[Index])
    EditBox.Focus()
    Send "{End}"
    Button := Window.Add("Text", "x93 y" InteractableHeight " w50 h" Height + 4 " Center +0x0200 Background" ButtonBackColor " " GUITextColor, "Done").OnEvent("Click", SubmitName)
    SubmitName(*) {
        LoadoutNames[Index] := EditBox.Value
        Window.Destroy()
        WriteToLoadout()
        LoadoutsGUI()
    }
    Window.Show()
}

IDsGUI(Index, IDType, *) { ; GUI for setting a vehicle spawn ID
    global Window := Gui("+LastFound -MinimizeBox -MaximizeBox", "EvenBetterGunMacro")
    DllCalls()
    Window.BackColor := GUIBackColor
    Window.SetFont("bold s11 " TextAntiAliasing " " GUITextColor, Font)
    BigText := Window.Add("Text", "x27", "Enter an ID:")
    BigText.GetPos(&BigTextX,,,&BigTextHeight)
    Window.SetFont("norm s10 " TextAntiAliasing " " GUITextColor, Font)
    BigText.GetPos(, &BigTextY, , &BigTextHeight)
    InteractableHeight := BigTextY + BigTextHeight + 15
    EditBox := Window.Add("Edit", "x13 y" InteractableHeight " w75 h" Height + 4 " Center -E0x0200 +0x0200 Background" ButtonBackColor " " GUITextColor, IDType[Index])
    EditBox.Focus()
    Send "{End}"
    Button := Window.Add("Text", "x93 y" InteractableHeight " w50 h" Height + 4 " Center +0x0200 Background" ButtonBackColor " " GUITextColor, "Done").OnEvent("Click", SubmitID)
    SubmitID(*) {
        if IsDigit(EditBox.Value) {
            IDType[Index] := EditBox.Value
            Window.Destroy()
            WriteToVehicles()
            RefreshHotkeys(true)
            VehiclesGUI()
        } else {
            Window.Destroy()
            CustomGUI("Please enter a valid ID.", true, "Continue", IDsGUI, Index, false, false)
        }
    }
    Window.Show()
}

UIWarnGUI(OOBE, *) { ; ui warn GUI for if EBGM detects roblox UI navigation is disabled
    global Window := Gui("+LastFound -MinimizeBox -MaximizeBox", "EvenBetterGunMacro")
    DllCalls()
    Window.Backcolor := GUIBackColor
    Window.SetFont("bold s11 " TextAntiAliasing " " GUITextColor, Font)
    Window.Add("Text",, "Warning!")
    Window.SetFont("norm s10 " TextAntiAliasing " " GUITextColor, Font)
    Window.Add("Text",, "EBGM Requires UI Navigation to be enabled, choose approach...")
    ChangeAndRestart := Window.Add("Text", "x15 y70 w400 h35 Center +0x0200 Background" ButtonBackColor " " GUITextColor, "Change Setting and Restart Roblox")
    Change := Window.Add("Text", "x15 y110 w197 h35 Center +0x0200 Background" ButtonBackColor " " GUITextColor, "Change Setting")
    LeaveAlone := Window.Add("Text", "x218 y110 w197 h35 Center +0x0200 Background" ButtonBackColor " " GUITextColor, "Do Nothing")
    if OOBE = true {
        ChangeAndRestart.OnEvent("Click", (*) => (Window.Destroy(), EnableUINav(), RestartRoblox(), HotkeyGUI(true, 1, false)))
        Change.OnEvent("Click", (*) => (Window.Destroy(), EnableUINav(), HotkeyGUI(true, 1, false)))
        LeaveAlone.OnEvent("Click", (*) => (Window.Destroy(), HotkeyGUI(true, 1, false)))
    } else if OOBE = false {
        ChangeAndRestart.OnEvent("Click", (*) => (Window.Destroy(), EnableUINav(), RestartRoblox()))
        Change.OnEvent("Click", (*) => (Window.Destroy(), EnableUINav()))
        LeaveAlone.OnEvent("Click", (*) => (Window.Destroy()))
    }
    Window.Show()
}
    
CustomGUI(Text, Button, ButtonText, ForwardDest, ForwardPar, Index, Vehicle) { ; dynamic GUI that accepts custom inputs for info, button text, or forward destination
    Global Window := Gui("+LastFound -MinimizeBox -MaximizeBox", "EvenBetterGunMacro")
    DllCalls()
    Window.BackColor := GUIBackColor
    Window.SetFont("norm s10 " TextAntiAliasing " " GUITextColor, Font)
    TextElement := Window.Add("Text",, Text)
    if Button {
        TextElement.GetPos(, , &TextWidth)
        ButtonHeight := TextWidth
        ButtonHeight := ButtonHeight / 30 + 30
        Button := Window.Add("Text", "w" TextWidth " h" ButtonHeight " Center +0x0200 Background" ButtonBackColor " " GUITextColor, ButtonText)
        Button.OnEvent("Click", Process)
        Process(*) {
            Window.Destroy()
            ForwardDest(ForwardPar, Index, Vehicle)
        }
    }
    Window.Show()
}

SizeTestGUI(Request) { ; invisible size test GUI to find height of the set font for GUI formatting
    Window := Gui("+LastFound -MinimizeBox -MaximizeBox", "EvenBetterGunMacro")
    Window.SetFont("norm s10 " TextAntiAliasing " " GUITextColor, Font)
    TextHeight := Window.Add("Text", "Hidden", "Wq")
    TextWidth := Window.Add("Text", "Hidden", "MW")
    TextHeight.GetPos(, , , &Height)
    TextWidth.GetPos(, , &Width)
    if Request = "Width" {
        Return Width
    } else if Request = "Height" {
        return Height
    }
}

DllCalls() { ; reusable dll calls for GUIs
    if !UsesLightTheme { ; sets window titlebar to darkmode if system preference matches
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", Window.Hwnd, "int", 20, "int*", 1, "int", 4)
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", Window.Hwnd, "UInt", 34, "Ptr*", GUIBackColor, "UInt", 4)
    }
    Margins := Buffer(16) ; removes corners from windows for a square GUI style
    NumPut("int", 0, Margins, 0)
    NumPut("int", 0, Margins, 4)
    NumPut("int", 0, Margins, 8)
    NumPut("int", 0, Margins, 12)
    DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", Window.Hwnd, "UInt", 33, "Ptr*", 1, "UInt", 4)
    DllCall("dwmapi\DwmExtendFrameIntoClientArea", "Ptr", Window.Hwnd, "Ptr", Margins)
}

; Configs
WriteToConfig() { ; writes general config data to file
    DirCreate A_AppData . "\..\LocalLow" "\EBGM\"
    ConfigFile := FileOpen(A_AppData . "\..\LocalLow" "\EBGM\ConfigV2.txt", "w")
    ConfigInformation := ConfigLine[1] "`n"
                            . ConfigLine[2] "`n"
    ConfigFile.Write(ConfigInformation)
    ConfigFile.Close()
}

WriteToLoadout() { ; writes loadout data to file (forgive the horridly ugly formatting)
    DirCreate A_AppData . "\..\LocalLow" "\EBGM\"
    LoadoutFile := FileOpen(A_AppData . "\..\LocalLow" "\EBGM\Loadouts.txt", "w")
    for index, item in LoadoutNames {
        if index > 1 {
            NamesString .= ","
        }
        NamesString .= item
    }
    for index, item in LoadoutHotkeys {
        if index > 1 {
            HotkeyString .= ","
        }
        HotkeyString .= item
    }
    for index, item in LoadoutWeapons {
        if index > 1 {
            WeaponString .= ","
        }
        WeaponString .= item
    }
    for index, item in LoadoutNerf {
        if index > 1 {
            NerfString .= ","
        }
        NerfString .= item
    }
    for index, item in LoadoutActive {
        if index > 1 {
            ActiveString .= ","
        }
        ActiveString .= item
    }
    LoadoutInformation := NamesString "`n"
                            . HotkeyString "`n"
                            . WeaponString "`n"
                            . NerfString "`n"
                            . ActiveString "`n"
    LoadoutFile.Write(LoadoutInformation)
    LoadoutFile.Close()
}

WriteToVehicles() { ; writes vehicle spawning data to file
    DirCreate A_AppData . "\..\LocalLow" "\EBGM\"
    VehiclesFile := FileOpen(A_AppData . "\..\LocalLow" "\EBGM\Vehicles.txt", "w")
    for index, item in VehicleIDs {
        if index > 1 {
            IDsString .= ","
        }
        IDsString .= item
    }
    for index, item in VehicleHotkeys {
        if index > 1 {
            HotkeysString .= ","
        }
        HotkeysString .= item
    }
    for index, item in VehicleActive {
        if index > 1 {
            ActiveString .= ","
        }
        ActiveString .= item
    }
    for index, item in VehicleCustom {
        if index > 1 {
            CustomString .= ","
        }
        CustomString .= item
    }
    VehiclesInformation := IDsString "`n"
                            . HotkeysString "`n"
                            . ActiveString "`n"
                            . CustomString "`n"
                            . AutoBuy "`n"
    VehiclesFile.Write(VehiclesInformation)
    VehiclesFile.Close()
}

CheckForConfig() { ; Check LocalLow for Config File
    if FileExist(A_AppData . "\..\LocalLow" "\EBGM\ConfigV2.txt") {
        return true
    }
    else {
        return false
    }
}

CheckForLoadouts() { ; Check LocalLow for Loadouts File
    if FileExist(A_AppData . "\..\LocalLow" "\EBGM\Loadouts.txt") {
        return true
    }
    else {
        return false
    }
}

CheckForVehicles() { ; Check LocalLow for Vehicles File
    if FileExist(A_AppData . "\..\LocalLow" "\EBGM\Vehicles.txt") {
        return true
    }
    else {
        return false
    }
}

UnpackConfig() { ; Extract and Array Config Data
    Line := StrSplit(FileRead(A_AppData . "\..\LocalLow" "\EBGM\ConfigV2.txt"), "`n", "`r")
    return Line
}

UnpackLoadouts(Request) { ; Extract and Array Loadouts Data
    Line := StrSplit(FileRead(A_AppData . "\..\LocalLow" "\EBGM\Loadouts.txt"), "`n", "`r")
    if Request = "Names" {
        return StrSplit(Line[1], ",")
    } else if Request = "Hotkeys" {
        return StrSplit(Line[2], ",")
    } else if Request = "Weapons" {
        return StrSplit(Line[3], ",")
    } else if Request = "Nerf" {
        return StrSplit(Line[4], ",")
    } else if Request = "Active" {
        return StrSplit(Line[5], ",")
    }
}

UnpackVehicles(Request) { ; Extract and Array Vehicles Data
    Line := StrSplit(FileRead(A_AppData . "\..\LocalLow" "\EBGM\Vehicles.txt"), "`n", "`r")
    try {
        if Request = "IDs" {
            return StrSplit(Line[1], ",")
        } else if Request = "Hotkeys" {
            return StrSplit(Line[2], ",")
        } else if Request = "Active" {
            return StrSplit(Line[3], ",")
        } else if Request = "Custom" {
            return StrSplit(Line[4], ",")
        } else if Request = "AutoBuy" {
            return Line[5]
        }
    } if Error {
        try {
            FileDelete A_AppData . "\..\LocalLow" "\EBGM\Vehicles.txt"
        }
    Reload()
    }
}

DummyFunction(*) {
    ; Does nothing and dies
}

BringToLatestPage(*)
{
    Run("https://github.com/PCMon/EvenBetterGunMacro/releases/latest")
}

ContactDiscord(*) {
    try {
        RegRead("HKEY_CLASSES_ROOT\Discord")
        Run("discord://-/users/951192864833036388")
    } catch TargetError {
        Run("https://discord.com/users/951192864833036388")
    }
}

ContactX(*) {
    Run("https://x.com/pcmon0")
}

ContactEmail(*) {
    A_Clipboard := "evenbettergunmacro@gmail.com"
    MouseGetPos(&X, &Y)
    SetTimer () => ToolTip(), -2000
    ToolTip("Copied!", X, Y)
}

TogglePlayerInputs(Toggle) { ; enables or disables WASD keys to prevent macro disruption
    if Toggle = "Disable" {
        if WinActive("ahk_exe RobloxPlayerBeta.exe") {
            Hotkey("W", DummyFunction)
            Hotkey("A", DummyFunction)
            Hotkey("S", DummyFunction)
            Hotkey("D", DummyFunction)
        }
    } else if Toggle = "Enable" {
        Hotkey("W", "Off")
        Hotkey("A", "Off")
        Hotkey("S", "Off")
        Hotkey("D", "Off")
    }
}

RefreshHotkeys(Apply) { ; disables all known hotkeys and optionally re-enables active ones
    for item in HotkeyStorage {
        if item != ""
            try {
                Hotkey(item, "Off")
            }
    }
    if Apply {
        for index, item in LoadoutActive {
            if LoadoutActive[index] = "true" {
                try {
                    Hotkey(
                        LoadoutHotkeys[index],
                        Main.Bind(
                            LoadoutWeapons[index],
                            LoadoutNerf[index]
                        ),
                        "On"
                    )
               }
            }
        }
        for index, item in VehicleActive {
            if VehicleActive[index] = "true" {
                try {
                    Hotkey(
                        VehicleHotkeys[index],
                    VehicleMain.Bind(
                        VehicleIDs[index],
                        VehicleCustom[index]
                    ),
                    "On"
                    )
                }
            }
        }
    }
}    

TrayDarkMode() { ; dll calls to set tray to darkmode 
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

CheckForUINav() { ; checks if roblox's UI navigation feature is enabled or not
    try {
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
    } if Error {
        try {
            FileDelete A_Startup "\EBGM.lnk"
        }
        CustomGUI("You don't have Roblox installed. `nWhy on Earth are you running this program?", true, "Good Question.", EndApp, false, false, false)
    }
}

EnableUINav() { ; rewrites roblox's GlobalBasicSettings_13 file to enable UI navigation
    Config := FileRead(A_AppData . "\..\Local" "\Roblox\GlobalBasicSettings_13.xml")
    NewConfig := StrReplace(Config, '<bool name="UiNavigationKeyBindEnabled">false</bool>', '<bool name="UiNavigationKeyBindEnabled">true</bool>')
    ConfigFile := FileOpen(A_AppData . "\..\Local" "\Roblox\GlobalBasicSettings_13.xml", "w")
    ConfigFile.Write(NewConfig)
    ConfigFile.Close
}

ToggleStartup(Name, Pos, Menu) { ; toggles run on startup
    global ConfigLine
    if ConfigLine[2] = "false" {
        ConfigLine[2] := "true"
        Menu.Check(Name)
        FileCreateShortcut(A_ScriptFullPath, A_Startup "\EBGM.lnk")
    } else {
        ConfigLine[2] := "false"
        Menu.Uncheck(Name)
        try {
            FileDelete A_Startup "\EBGM.lnk"
        }
    }
    if FileExist(A_AppData . "\..\LocalLow" "\EBGM\ConfigV2.txt") {
        WriteToConfig()
    }
}

ToggleSub60Compat(Name, Pos, Menu) { ; toggles sub-60fps compatibility 
    global ConfigLine
    if ConfigLine[1] = "false" {
        ConfigLine[1] := "true"
        Menu.Check(Name)
    } else {
        ConfigLine[1] := "false"
        Menu.Uncheck(Name)
    }
    if FileExist(A_AppData . "\..\LocalLow" "\EBGM\ConfigV2.txt") {
        WriteToConfig()
    }
}

ToggleAutoBuy(Name, Pos, Menu) { ; toggles helicopter autobuy
    global AutoBuy
    if AutoBuy = "false" {
        AutoBuy := "true"
        Menu.Check(Name)
    } else {
        AutoBuy := "false"
        Menu.Uncheck(Name)
    }
    if FileExist(A_AppData . "\..\LocalLow" "\EBGM\Vehicles.txt") {
        WriteToVehicles()
    }
    RefreshHotkeys(true)
}

RestartRoblox() { ; restarts roblox
    if ProcessExist("RobloxPlayerBeta.exe") {
        ProcessClose("RobloxPlayerBeta.exe")
        ProcessWaitClose("RobloxPlayerBeta.exe", 5)
    }
    Run("roblox://")
}

EndApp(DeleteConfig, *) { ; closes EBGM and optionally deletes config and loadout files
    if DeleteConfig = true {
        try {
            FileDelete A_AppData . "\..\LocalLow" "\EBGM\ConfigV2.txt"
            FileDelete A_AppData . "\..\LocalLow" "\EBGM\Loadouts.txt"
            FileDelete A_AppData . "\..\LocalLow" "\EBGM\Vehicles.txt"
        }
        Reload()
    } else {
        ExitApp
    }
}