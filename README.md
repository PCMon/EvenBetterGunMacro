# EvenBetterGunMacro! (AutoHotkey v2)
<a href="https://github.com/PCMon/EvenBetterGunMacro/releases/latest" target="_blank">Install</a> / [Compile](#compiling) and [Verify](#verifying)

<img width="1020" height="399" alt="Screenshot 2026-05-25 084350" src="https://github.com/user-attachments/assets/98ff2d05-89f7-48a8-af7a-83a5e1fc8f0d" />


---

A customizable macro based tool intended to be used for Jailbreak.  


Tired of a slow, unoptimized and static hardcoded gunstore macro? Be in and out of the gunstore before the door even closes!

Featuring a customizable hotkey, loadout, and nerf status setting,
optimized to work as fast as possible! (Times as low as **70ms** for 10 weapon loadouts + explosive refills!)

Settings save, so you only need to input them once, boots without any GUI afterwards, to change your settings, simply right click it in the system tray!

<img src=https://github.com/PCMon/EvenBetterGunMacro/blob/main/gif.gif/>

Works on regular servers AND crew battles, and is stable on 60fps! 

---

## Installing

Download the <a href="https://github.com/PCMon/EvenBetterGunMacro/releases/latest" target="_blank">latest version's executable</a> or manually compile source.

## Compiling

1. Download the <a href="https://github.com/PCMon/EvenBetterGunMacro/blob/main/Source/EBGMraw.ahk" target="_blank">source code</a> as well as <a href="https://autohotkey.com" target="_blank">AutoHotkey v2</a>. <sub>(Ctrl + Click to open in new tab.)</sub>
   - At this point you can use the raw .ahk file by launching it with AutoHotkey or continue to compile to an executable. <br><br>
2. Right click the raw .ahk source and select `Compile Script (GUI)`. <br><br>
3. Ensure the `Source (script file)` box has the correct location to your raw .ahk source code.
   - (Optional) Set a destination for your compiled exe to go.
   - (Optional) Set a custom icon for the program, the default for EBGM is included in the main directory. <br><br>
4. Under `Base File (.bin, .exe)`, select v2.0.xx.
   - Choose either U32 (AutoHotkey32.exe) or U64 (AutoHotkey64.exe).
     - Compiling with U64 may yield improved performance, but compiling with U32 will improve compatibility with older versions of windows. <br><br>
5. Finally, press **Convert**.

---

## Verifying

You can verify that the newly compiled executable from the source is the same executable under releases with these steps.

1. Navigate to <a href="https://github.com/PCMon/EvenBetterGunMacro/releases/latest" target="_blank">latest release</a> and view the SHA256 hash github automatically provides for that executable. <br>
<img width="1216" height="235" alt="example" src="https://github.com/user-attachments/assets/0ef8a20a-8b04-4baf-92cd-a1924a051c3d" /> <br><br>

2. Open the Windows Command Prompt or a Powershell terminal. <sub>(Administrator privilages are not required.) <br><br>
3. Run the Windows tool `certutil` by doing `certutil -hashfile C:\Path\To\Your\Program\program.exe SHA256`. <br><br>
4. Verify that the output SHA256 hash is identical to that which is listed beside the executable on the releases tab.
