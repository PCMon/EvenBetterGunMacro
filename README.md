<h1 align="center">EvenBetterGunMacro</h1>   

<p align="center">
  <a href="https://github.com/PCMon/EvenBetterGunMacro/releases/download/v2.6.5/EBGMcomp.exe">
    <img src="https://img.shields.io/badge/Install-blue?style=flat-square" alt="Install" width="130" height="55"/>
  </a>
</p>

<img width="2559" height="1439" alt="Image" src="https://github.com/user-attachments/assets/d5116d3b-adec-49c4-bc01-5dba65960c8d" />

---

### EvenBetterGunMacro (EBGM) is a lightweight customizable AutoHotkey based program for Jailbreak. <br><br>

> [!TIP]
> EBGM features three main modules currently:
>
> 1. The main Gun Store Macro, for getting your loadouts in a snap.
>
> 2. The Vehicle Spawning Macro, for summoning any vehicle you so choose optionally with any save slot.
>
> 3. The Missile Auto-Buy Macro, so you're never hit with that annoying pop-up when you go to take a shot.

#  

#### EBGM works on all server types and supports 60 fps by default, with an option to allow even lower framerates (like 20fps)!

#### EBGM uses very little system resources, at around 3-5MB of memory! <br>

> [!IMPORTANT]
> #### This is a standalone program, it does not create another file for you to use, it saves all your choices and automatically applies them each launch.

<div align="center">
  <a href="https://discord.gg/sx2VzzxDan">
    <img src="https://img.shields.io/badge/%20-%20-262626?logo=discord" width="75">
  </a>
  &nbsp;&nbsp;
  <a href="https://www.roblox.com/users/189272816/profile">
    <img src="https://img.shields.io/badge/%20-%20-335fff?logo=roblox" width="75">
  </a>
  &nbsp;&nbsp;
  <a href="https://x.com/pcmon0">
    <img src="https://img.shields.io/badge/%20-%20-2d2d2d?logo=x" width="75">
  </a>
</div>

# Installing

Download the <a href="https://github.com/PCMon/EvenBetterGunMacro/releases/latest" target="_blank">**latest version's executable or source code**</a>. <br>
<sub>EBGM has zero dependencies, so nothing other than <a href="https://autohotkey.com" target="_blank">AutoHotkey v2</a> is required to run the source!</sub>

---
# Compiling

#### 1. Download the <a href="https://github.com/PCMon/EvenBetterGunMacro/releases/latest" target="_blank">source code</a> as well as <a href="https://autohotkey.com" target="_blank">AutoHotkey v2</a>. <sub>(Ctrl + Click to open in new tab.)</sub> <br><br>
#### 2. Right click the raw .ahk source and select `Compile Script (GUI)`. <br><br>
#### 3. Ensure the `Source (script file)` box has the correct location to your raw .ahk source code.
   - Set a custom icon for the program, the default for EBGM is included in the main directory and is required for the verification step to work.
   - (Optional) Set a destination for your compiled exe to go. <br><br>
#### 5. Under `Base File (.bin, .exe)`, select v2.0.xx.
   - Choose either U32 (AutoHotkey32.exe) or U64 (AutoHotkey64.exe).
     - Compiling with U64 may yield improved performance, but compiling with U32 will improve compatibility with older versions of windows. <br>
     <sub>EvenBetterGunMacro uses U64 by default, and choosing U32 may affect results in the verification stage.</sub><br><br>
#### 6. Finally, press **Convert**.

## Verifying

### You can verify that the newly compiled executable from the source is the same executable under releases with these steps.

#### 1. Navigate to <a href="https://github.com/PCMon/EvenBetterGunMacro/releases/latest" target="_blank">latest release</a> and view the SHA256 hash github automatically provides for that executable. <br>
<img width="1216" height="235" alt="example" src="https://github.com/user-attachments/assets/0ef8a20a-8b04-4baf-92cd-a1924a051c3d" /> <br><br>

#### 2. Open the Windows Command Prompt or a Powershell terminal. <sub>(Administrator privilages are not required.) <br><br>
#### 3. Run the Windows tool `certutil` by doing `certutil -hashfile C:\Path\To\EBGM.exe SHA256`. <br><br>
#### 4. Verify that the output SHA256 hash is identical to that which is listed beside the executable on the releases tab.
- It is completely possible this will fail and result in a different hash, this can happen for a couple reasons, but I am going to work on compiling future releases with github actions for better trust.

---

## License

> [!IMPORTANT]
> This project is licensed under the GNU General Public License v3.0.
> 
> See the LICENSE file for details.

## Trademarks

> [!IMPORTANT]
> "EvenBetterGunMacro", "EBGM", and associated logos and artwork are not
> licensed under the GPL.
> 
> See TRADEMARKS.md for the project's trademark policy.
