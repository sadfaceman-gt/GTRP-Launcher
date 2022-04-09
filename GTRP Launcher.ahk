; -------------------- Initialization -------------------- ;

#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#Include %A_ScriptDir%\.GTRP\RunAsTask.ahk
#SingleInstance Force
DetectHiddenWindows, On

;              +-------------------------------------------------+                   ;       
;              |    ______    _________   _______      _______   |                   ;
;              |  .' ___  |  |  _   _  | |_   __ \    |_   __ \  |                   ;
;              | / .'   \_|  |_/ | | \_|   | |__) |     | |__) | |                   ;
;              | | |   ____      | |       |  __ /      |  ___/  |                   ;
;              | \ `.___]  |    _| |_     _| |  \ \_   _| |_     |                   ;
;              |  `._____.'    |_____|   |____| |___| |_____|    |                   ;
;              |           _                 _                   |                   ;
;              |          | |   ___  __ _ __| |___ _ _           |                   ;
;              |          | |__/ _ \/ _` / _` / -_) '_|          |                   ;
;              |          |____\___/\__,_\__,_\___|_|            |	                 ;
;              |                                                 |                   ;
;              +-------------------------------------------------+                   ;
; -------------------- Growtopia Resprite Project Launcher ------------------------- ;
;                               Made by SadFaceMan                                   ;
                                 Version := "3.0"
;                     Powered by Growtopia Resprite Project                          ;

Global textDelay := 50

; -------------------- You shouldn't edit anything beyond this point -------------------- ;

global rpname := []
global rpload := []
global rpcreator := []
global rpver := []
global rploadver := []
global rpdesc := []

global rploadname := []
global settings := []
sloadgame := false

; -------------------- Gui initialization and installation check -------------------- ;
if not WinExist("GTRP Client ahk_class AutoHotkeyGUI")
	sloadgame := true

Gui, Font, c00FF00 s12, Consolas
Gui, Color, 000000
WinSet, TransColor, 000000
Gui, Add, Picture, w600 h300 vGImage gGImage, %A_WorkingDir%\.GTRP\GTRPLogo.png
Gui, Add, Edit, x+10 w680 h250 Center -Tabstop ReadOnly -VScroll -HScroll -Wrap vGTitle
Gui, Add, Button, y+10 w220 h40 Center vGLaunch gGLaunch, Launch GTRP
Gui, Add, Button, x+10 w220 h40 Center vGInstall gGInstall, Install Package
Gui, Add, Button, x+10 w220 h40 Center vGClose gGClose, Close Launcher
Gui, Add, Text, x0 w0 h0
Gui, Add, ListBox, x+10 w200 h450 -Wrap vGRPList gGRPList AltSubmit,
Gui, Add, Edit, x+10 w450 h390 ReadOnly -VScroll -HScroll Wrap vGRPInfo
Gui, Add, Button, y+10 w220 h40 Center vGRPToggle gGRPToggle, Toggle
Gui, Add, Button, x+10 w220 h40 Center vGRPDelete gGRPDelete, Delete Resprite
Gui, Add, Edit, x680 y319 w625 h390 ReadOnly -HScroll Wrap vGLog
Gui, Add, CheckBox, y+8 w280 h20 -Wrap vGSet1 gGSet1, Launch as administrator
Gui, Add, CheckBox, y+2 w280 h20 -Wrap vGSet2 gGSet2, List resprites upon launch
Gui, Add, CheckBox, x970 y717 w330 h20 -Wrap vGSet3 gGSet3, Launch GTRP upon startup
Gui, Add, CheckBox, y+2 w330 h20 -Wrap vGSet4 gGSet4, Close launcher after closing GTRP
Gui, Font, c000000 s12, Consolas
GuiControl, Font, GRPList
Gui, Font, c00FF00 s12, Consolas
Gui, Show, Center, GTRP Client
Gosub, gdisable

gttext := "
(
+-------------------------------------------------+
|    ______    _________   _______      _______   |
|  .' ___  |  |  _   _  | |_   __ \    |_   __ \  |
| / .'   \_|  |_/ | | \_|   | |__) |     | |__) | |
| | |   ____      | |       |  __ /      |  ___/  |
| \ '.___]  |    _| |_     _| |  \ \_   _| |_     |
|  '._____.'    |_____|   |____| |___| |_____|    |
|                                                 |
+-------------------------------------------------+
Growtopia Resprite Project Launcher
Made by SadFaceMan
Version " . Version . "
)"
GuiControl, , GTitle, %gttext%
gtext("Verifying installation...")
if ConnectedToInternet()
{
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", "https://raw.githubusercontent.com/sadfaceman-gt/GTRP-Launcher/main/ver", true)
	whr.Send()
	whr.WaitForResponse()
	NVer := Format("{:.1f}", whr.ResponseText)
	if(Version < NVer)
	{
		gtext("A new version of GTRP Launcher is available! (" . NVer . ")")
		Sleep, 1500
	}
	else
		gtext("Latest version : " . NVer)
}
else
	gtext("Cannot check for updates as GTRP Launcher is not connected to the internet")
initcheck := []
initcheck.Push("Growtopia.exe")
initcheck.Push(".GTRP")
initcheck.Push(".GTRP\Blacklist")
initcheck.Push(".GTRP\GameCache")
initcheck.Push(".GTRP\Resprites")
initcheck.Push(".GTRP\Part1")
initcheck.Push(".GTRP\Part2")
initcheck.Push(".GTRP\pssuspend.exe")
initcheck.Push(".GTRP\pssuspend64.exe")
initcheck.Push(".GTRP\UnRAR.exe")
initerror := 0
Loop
{
	if(initcheck[A_Index])
	{
		if not FileExist(A_WorkingDir . "\" . initcheck[A_Index])
		{
			gtext("Could not find " . initcheck[A_Index])
			initerror++
			Sleep, 400
		}
	}
	else
		Break
}
gtext("")
if (initerror >= 1)
{
	Gosub, errorlog
	gtext("Several items are missing, GTRP Launcher cannot run. Please check the error log to re-verify installation")
	Sleep, 2000
	Gosub, closegtrp
}
gtext("Installation verified")
gtext("")
Gosub, loadsettings
Gosub, loadresprites
if(settings[3] and sloadgame) or FileExist(A_WorkingDir . "\.GTRP\autostart")
{
	FileDelete, %A_WorkingDir%\.GTRP\autostart
	Gosub, GLaunch_main
	Return
}
Gosub, genable
Return

; -------------------- Button actions -------------------- ;

GImage: ; ---------- Image ---------- ;
Run, https://github.com/sadfaceman-gt/GTRP-Launcher
Return

GLaunch: ; ---------- Launch GTRP ---------- ;
Gosub, gdisable
gtext("Preparing to launch GTRP...")
gtext("")
Gosub, loadsettings
Gosub, loadresprites
Gosub, GLaunch_main
Return

GLaunch_main:
if(settings[1]) and not(A_IsAdmin)
{
	FileAppend, , %A_WorkingDir%\.GTRP\autostart
	Loop
	{
		RunAsTask()
		if(A_IsAdmin)
			Break
	}
}
if not(A_IsAdmin)
{
	gtext(" <!> WARNING <!>")
	gtext("GTRP Client is not being run as administrator. vCache may not function properly!")
	gtext("")
	Sleep, 1000
}
if not FileExist(A_WorkingDir . "\save.dat")
{
	gtext(" <!> WARNING <!>")
	gtext("Couldn't find save.dat, make sure you've run Growtopia at least once before starting GTRP!")
	gtext("")
	Sleep, 1000
	Gosub, GLaunch_end
	Return
}
if WinExist("Growtopia ahk_class AppClass")
{
	if FileExist(A_WorkingDir . "\.GTRP\switch\*")
	{
		gtext("GTRP Client is already running! Reloading resprites...")
		Sleep, 1000
		gtext("")
		Gosub, cleanvcache
		Gosub, cleancache
		Gosub, listresprites
		Gosub, loadcache
		Gosub, extractresprites
		Gosub, loadvcache
		gtext("Resprites reloaded!")
		gtext("")
		Gosub, GLaunch_end
		Return
	}
	else
	{
		gtext("Growtopia is already running! Closing Growtopia...")
		WinClose, Growtopia ahk_class AppClass
		Sleep, 1000
		gtext("")
	}
}
if FileExist(A_WorkingDir . "\.GTRP\switch\*")
{
	gtext("GTRP Client did not shut down correctly! Cleaning leftover files...")
	Sleep, 1000
	gtext("")
	Gosub, cleanvcache
	Gosub, cleancache
}
gtext("Launching GTRP...")
Gosub, listresprites
Gosub, loadcache
Gosub, extractresprites
Gosub, loadvcache
FileDelete, %A_WorkingDir%\.GTRP\update
gtext("Loading Growtopia...")
Run, Growtopia.exe, %A_WorkingDir%
WinWait, Growtopia ahk_class AppClass
gtext("Growtopia loaded")
gtext("")
Loop
{
	Sleep, 200
	If not WinExist("Growtopia ahk_class AppClass")
		Break
	If FileExist(A_WorkingDir . "\.GTRP\update")
	{
		FileReadLine, VName, %A_WorkingDir%\.GTRP\update, 1
		FileReadLine, FName, %A_WorkingDir%\.GTRP\update, 2
		FileDelete, %A_WorkingDir%\.GTRP\update
		gtext(VName . " has updated a file! (" . FName . ")")
	}
}
FileDelete, %A_WorkingDir%\.GTRP\update
gtext("")
Gosub, cleanvcache
Gosub, cleancache
Gosub, GLaunch_end
Return

GLaunch_end:
if(settings[4])
{
	Gosub, closegtrp
	ExitApp
}
Gosub, genable
Return

GInstall: ; ---------- Install Package ---------- ;
Gosub, gdisable
FileRemoveDir, %A_WorkingDir%\.GTRP\temp\, 1
gtext(" - GTRP Resprite Package Installation - ")
gtext("Select a resprite package to install (*.gpak; *.gtrp)")
FileSelectFile, FPath, , , Select a resprite package, Growtopia Resprite Package (*.gpak; *.gtrp)
if(!FPath)
{
	gtext("Installation cancelled")
	Gosub, GInstall_end
	Return
}
SplitPath, FPath, FName, FDir, FExt, FTName, FDrive
gtext("Extracting " . FName . "...")
FileCreateDir, %A_WorkingDir%\.GTRP\temp\

if(FExt = "gpak")
{
	FileCopy, %FPath%, %A_WorkingDir%\.GTRP\temp\%FTName%.zip, 1
	RunWait PowerShell.exe -Command Expand-Archive -LiteralPath '%A_WorkingDir%\.GTRP\temp\%FTName%.zip' -DestinationPath '%A_WorkingDir%\.GTRP\temp\',, Hide
	if not FileExist(A_WorkingDir . "\.GTRP\temp\data.g")
	{
		FileCopy, %FPath%, %A_WorkingDir%\.GTRP\temp\%FTName%.rar, 1
		RunWait %ComSpec% /c unrar x -r temp\%FTName%.rar temp, %A_WorkingDir%\.GTRP\, Hide
		if not FileExist(A_WorkingDir . "\.GTRP\temp\data.g")
		{
			gtext("Invalid GTRP resprite package! Installation cancelled")
			Gosub, GInstall_end
			Return
		}
	}
	gtext("File Type : GTRP Universal Package (.gpak)")
}
else if(FExt = "gtrp")
{
	FileCopy, %FPath%, %A_WorkingDir%\.GTRP\temp\%FTName%.zip, 1
	RunWait PowerShell.exe -Command Expand-Archive -LiteralPath '%A_WorkingDir%\.GTRP\temp\%FTName%.zip' -DestinationPath '%A_WorkingDir%\.GTRP\temp\',, Hide
	if not FileExist(A_WorkingDir . "\.GTRP\temp\data.g")
	{
		gtext("Invalid GTRP resprite package! Installation cancelled")
		Gosub, GInstall_end
		Return
	}
	gtext("File Type : Growtopia Resprite Zipped Package (.gtrp) (Legacy)")
}
else
{
	gtext("Unknown file extension! Installation cancelled")
	Gosub, GInstall_end
	Return
}



FileReadLine, RPPackageName, %A_WorkingDir%\.GTRP\temp\data.g, 1
if(!RPPackageName)
	RPPackageName := FName
FileReadLine, RPCreatorName, %A_WorkingDir%\.GTRP\temp\data.g, 2
if(!RPCreatorName)
	RPCreatorName := "Unknown"
FileReadLine, RPPackageVer, %A_WorkingDir%\.GTRP\temp\data.g, 3
if(!RPPackageVer)
	RPPackageVer := "1.0"
RPPackageVer := Format("{:s}", RPPackageVer)
FileReadLine, RPLoaderVer, %A_WorkingDir%\.GTRP\temp\data.g, 4
if(!RPLoaderVer)
	RPLoaderVer := Version
RPLoaderVer := Format("{:.1f}", RPLoaderVer)
FileReadLine, RPPackageDesc, %A_WorkingDir%\.GTRP\temp\data.g, 5
Loop, 15
{
	NNum := A_Index + 5
	FileReadLine, NDesc, %A_WorkingDir%\.GTRP\temp\data.g, NNum
	if(ErrorLevel)
		break
	RPPackageDesc := RPPackageDesc . "`n"  . NDesc
}
if(!RPPackageDesc)
	RPPackageDesc := "No description"
GuiControl, , GRPInfo, 
ginfo("Package Name     : " . RPPackageName)
ginfo("Package Creator  : " . RPCreatorName)
ginfo("Package Version  : " . RPPackageVer)
ginfo("Launcher Version : " . RPLoaderVer)
ginfo("Description      : " . RPPackageDesc)
if FileExist(A_WorkingDir . "\.GTRP\Resprites\" . RPPackageName)
{
	gtext(" <!> WARNING <!>")
	gtext(RPPackageName . " already exists. Installing this resprite will replace the existing one")
	Sleep, 1000
	gtext("")
}
if(RPLoaderVer < Version)
{
	gtext(" <!> WARNING <!>")
	gtext("This resprite package was made for an older version of GTRP Loader (" . RPLoaderVer . "), this may cause instabilities! Please refer to the wiki to see if this resprite is compatible with the current loader")
	Sleep, 1000
	gtext("")
}
gtext("Installing " . RPPackageName . "...")
MsgBox, 260, GTRP Resprite Package Installation, Install %RPPackageName%?, 15
IfMsgBox Yes
{
	FileRemoveDir, %A_WorkingDir%\.GTRP\Resprites\%RPPackageName%, 1
	FileCreateDir, %A_WorkingDir%\.GTRP\Resprites\%RPPackageName%
	FileCopy, %A_WorkingDir%\.GTRP\temp\data.g, %A_WorkingDir%\.GTRP\Resprites\%RPPackageName%\data.g, 1
	FileCopyDir, %A_WorkingDir%\.GTRP\temp\resprite\, %A_WorkingDir%\.GTRP\Resprites\%RPPackageName%\resprite\, 1
	FileDelete, %A_WorkingDir%\.GTRP\Blacklist\%RPPackageName%
	initcheck := []
	initcheck.Push("data.g")
	initcheck.Push("resprite")
	initerror := 0
	Loop
	{
		if(initcheck[A_Index])
		{
			if not FileExist(A_WorkingDir . "\.GTRP\Resprites\" . RPPackageName . "\" . initcheck[A_Index])
				initerror++
		}
		else
			Break
	}
	if(initerror >= 1) 
	{
		gtext("Failed to install " . RPPackageName . ", the package may contain missing files, or the internal packaged resprite name may contain illegal characters")
		FileRemoveDir, %A_WorkingDir%\.GTRP\Resprites\%RPPackageName%, 1
		Sleep, 1000
	}
	else
		gtext("Successfully installed " . RPPackageName)
}
else
	gtext("Installation cancelled")
Gosub, GInstall_end
Return

GInstall_end:
FileRemoveDir, %A_WorkingDir%\.GTRP\temp\, 1
Sleep, 1000
gtext("")
Gosub, loadresprites
Gosub, genable
Return

GClose: ; ---------- Close Launcher ---------- ;
Gosub, gdisable
Gosub, closegtrp
Return

GRPList: ; ---------- Selecting a resprite ---------- ;
Gosub, gdisable
Gui, Submit, NoHide
GRPIndex := Floor((GRPList / 2) + 0.5)
GuiControl, , GRPInfo, 
if(!rpname[GRPIndex])
{
	gtext("Invalid index number. Try reopening GTRP Launcher")
	gtext("")
	Gosub, genable
	Return
}
ginfo("Package Name     : " . rpname[GRPIndex])
ginfo("Package Creator  : " . rpcreator[GRPIndex])
ginfo("Package Version  : " . rpver[GRPIndex])
ginfo("Launcher Version : " . rploadver[GRPIndex])
ginfo("Description      : " . rpdesc[GRPIndex])
if(rploadver[GRPIndex] < Version)
{
	gtext(" <!> WARNING <!>")
	gtext("This resprite package was made for an older version of GTRP Loader (" . RPLoaderVer . "), this may cause instabilities! Please refer to the wiki to see if this resprite is compatible with the current loader")
	gtext("")
}
Gosub, genable
Return

GRPToggle: ; ---------- Toggle ---------- ;
Gosub, gdisable
Gui, Submit, NoHide
GRPIndex := Floor((GRPList / 2) + 0.5)
if(!rpname[GRPIndex])
{
	gtext("Select a resprite to toggle")
	gtext("")
	Gosub, genable
	Return
}
FName := rpname[GRPIndex]
if(rpload[GRPIndex])
{
	gtext("Unloading " . FName . "...")
	FileAppend, , %A_WorkingDir%\.GTRP\Blacklist\%FName%
	if not FileExist(A_WorkingDir . "\.GTRP\Blacklist\" . FName)
		gtext("Failed to unload " . FName)
	else
		gtext(FName . " unloaded")
}
else
{
	gtext("Loading " . FName . "...")
	FileDelete, %A_WorkingDir%\.GTRP\Blacklist\%FName%
	if FileExist(A_WorkingDir . "\.GTRP\Blacklist\" . FName)
		gtext("Failed to load " . FName)
	else
		gtext(FName . " loaded")
}
Sleep, 1000
gtext("")
Gosub, loadresprites
Gosub, genable
Return

GRPDelete: ; ---------- Delete Resprite ---------- ;
Gosub, gdisable
Gui, Submit, NoHide
GRPIndex := Floor((GRPList / 2) + 0.5)
if(!rpname[GRPIndex])
{
	gtext("Select a resprite to delete")
	gtext("")
	Gosub, genable
	Return
}
FDel := rpname[GRPIndex]
gtext("Deleting " . FDel . "...")
MsgBox, 260, GTRP Resprite, Are you sure you want to delete %FDel%?`nThis action cannot be undone!, 15
IfMsgBox Yes
{
	FileRemoveDir, %A_WorkingDir%\.GTRP\Resprites\%FDel%, 1
	if FileExist(A_WorkingDir . "\.GTRP\Resprites\" . FDel)
		gtext("Failed to delete " . FDel . ", the target folder and the internal packaged resprite name may be inconsistent, or the resprite may still be in use")
	else
		gtext("Successfully deleted " . FDel)
}
else
	gtext("Deletion cancelled")
Sleep, 1000
gtext("")
Gosub, loadresprites
Gosub, genable
Return

GSet1: ; ---------- Settings 1 ---------- ;
Gosub, gdisable
Gui, Submit, NoHide
settings[1] := GSet1
Gosub, setsettings
Gosub, genable
Return

GSet2: ; ---------- Settings 2 ---------- ;
Gosub, gdisable
Gui, Submit, NoHide
settings[2] := GSet2
Gosub, setsettings
Gosub, genable
Return

GSet3: ; ---------- Settings 2 ---------- ;
Gosub, gdisable
Gui, Submit, NoHide
settings[3] := GSet3
Gosub, setsettings
Gosub, genable
Return

GSet4: ; ---------- Settings 2 ---------- ;
Gosub, gdisable
Gui, Submit, NoHide
settings[4] := GSet4
Gosub, setsettings
Gosub, genable
Return

; -------------------- Subs and functions -------------------- ;

loadresprites: ; ---------- loadresprites ---------- ;
gtext("Reloading resprites...")
rpname := []
rploadname := []
rpload := []
rpcreator := []
rpver := []
rploadver := []
rpdesc := []
GRPIndex := 0
GuiControl, , GRPInfo
GuiControl, , GRPList, |
Loop, Files, %A_WorkingDir%\.GTRP\Resprites\*.g, R
{
	SplitPath, A_LoopFilePath, FName, FDir, FExt, FTName, FDrive
	FFolder := StrReplace(FDir, A_WorkingDir . "\.GTRP\Resprites\")
	FileReadLine, RPPackageName, %A_LoopFilePath%, 1
	if(!RPPackageName)
		RPPackageName := FFolder
	FileReadLine, RPCreatorName, %A_LoopFilePath%, 2
	if(!RPCreatorName)
		RPCreatorName := "Unknown"
	FileReadLine, RPPackageVer, %A_LoopFilePath%, 3
	if(!RPPackageVer)
		RPPackageVer := "1.0"
	RPPackageVer := Format("{:s}", RPPackageVer)
	FileReadLine, RPLoaderVer, %A_LoopFilePath%, 4
	if(!RPLoaderVer)
		RPLoaderVer := Version
	RPLoaderVer := Format("{:.1f}", RPLoaderVer)
	FileReadLine, RPPackageDesc, %A_LoopFilePath%, 5
	Loop, 15
	{
		NNum := A_Index + 5
		FileReadLine, NDesc, %A_LoopFilePath%, NNum
		if(ErrorLevel)
			break
		RPPackageDesc := RPPackageDesc . "`n"  . NDesc
	}
	if(!RPPackageDesc)
		RPPackageDesc := "No description"
		
	rpname.Push(RPPackageName)
	if FileExist(A_WorkingDir . "\.GTRP\Blacklist\" . RPPackageName)
		rpload.Push(false)
	else
	{
		rpload.Push(true)
		rploadname.Push(RPPackageName)
	}
	rpcreator.Push(RPCreatorName)
	rpver.Push(RPPackageVer)
	rploadver.Push(RPLoaderVer)
	rpdesc.Push(RPPackageDesc)
	if(rpload[A_Index])
		GText := " [ Loaded ]"
	else
		GText := " [Unloaded]"
	GuiControl, , GRPList, %RPPackageName%
	GuiControl, , GRPList, %GText%
	gtext(RPPackageName . " reloaded")
}
gtext("")
Return

setsettings:
FileDelete, %A_WorkingDir%\.GTRP\Settings
if FileExist(A_WorkingDir . "\.GTRP\Settings")
{
	gtext("Failed to modify settings, the settings file may still be in use")
	gtext("")
	Sleep, 1000
	Gosub, loadsettings
	Return
}
Loop, 4
{
	nset := settings[A_Index]
	FileAppend, %nset%`n, %A_WorkingDir%\.GTRP\Settings
}
Gosub, loadsettings
Return

loadsettings: ; ---------- loadsettings ---------- ;
gtext("Reloading settings...")
settings := []
if not FileExist(A_WorkingDir . "\.GTRP\Settings")
	FileAppend, 1`n1`n0`n0, %A_WorkingDir%\.GTRP\Settings
Loop, 4
{
	FileReadLine, spush, %A_WorkingDir%\.GTRP\Settings, %A_Index%
	settings.Push(spush)
}
if(settings[1])
	GuiControl, , GSet1, 1
else
	GuiControl, , GSet1, 0
if(settings[2])
	GuiControl, , GSet2, 1
else
	GuiControl, , GSet2, 0
if(settings[3])
	GuiControl, , GSet3, 1
else
	GuiControl, , GSet3, 0
if(settings[4])
	GuiControl, , GSet4, 1
else
	GuiControl, , GSet4, 0
gtext("Settings reloaded")
gtext("")
Return

listresprites: ; ---------- listresprites ---------- ;
if(settings[2])
{
	gtext("")
	gtext(" - Loaded resprites - ")
	Loop
	{
		if(!rploadname[A_Index])
			Break
		gtext("[" . A_Index . "] " . rploadname[A_Index])
		Sleep, 800
	}
	Sleep, 400
}
Return

loadcache: ;---------- loadcache ----------;
gtext("Loading cache...")
FileCreateDir, %A_WorkingDir%\.GTRP\cache\
FileCreateDir, %A_WorkingDir%\.GTRP\switch\
FileCopyDir, %A_WorkingDir%\cache\, %A_WorkingDir%\.GTRP\cache\, 1
gtext("Cache copied")
gtext("")
Return

extractresprites: ; ---------- extractresprites ---------- ;
Loop
{
	if(!rploadname[A_Index])
		Break
	FName := rploadname[A_Index]
	gtext("Loading " . FName . "...")
	Loop, Files, %A_WorkingDir%\.GTRP\Resprites\%FName%\resprite\*, R
	{
		SPath := StrReplace(A_LoopFilePath, A_WorkingDir . "\.GTRP\Resprites\" . FName . "\resprite\", "")
		SDir := StrReplace(SPath, "\" . A_LoopFileName, "")
		SSwitch := StrReplace(SDir, "\", "-")
		FileAppend, , %A_WorkingDir%\.GTRP\switch\%SSwitch%
		FileCreateDir, %A_WorkingDir%\.GTRP\GameCache\%SDir%
		FileCopy, %A_WorkingDir%\%SPath%, %A_WorkingDir%\.GTRP\GameCache\%SPath%, 1
	}
	FileCopyDir, %A_WorkingDir%\.GTRP\Resprites\%FName%\resprite\, %A_WorkingDir%\, 1
	FileCopyDir, %A_WorkingDir%\.GTRP\Resprites\%FName%\resprite\, %A_WorkingDir%\cache\, 1
	FileCopyDir, %A_WorkingDir%\.GTRP\Resprites\%FName%\resprite\, %A_WorkingDir%\.GTRP\cache, 1
	gtext(FName . " loaded")
}
gtext("")
Return

loadvcache: ; ---------- loadvcache ---------- ;
gtext("Loading vCache...")
Loop, Files, %A_WorkingDir%\.GTRP\switch\*, R
{
	FName := StrReplace(A_LoopFileName, "-", "\")
	FileRead, Part1, %A_WorkingDir%\.GTRP\Part1
	FileRead, Part2, %A_WorkingDir%\.GTRP\Part2
	FullPart := Part1 . "cache\" . FName . Part2
	FRun := "vCache_" . A_LoopFileName . ".ahk"
	FileAppend, %FullPart%, %A_WorkingDir%\%FRun%
	Run, %FRun%, %A_WorkingDir%
}
gtext("vCache loaded")
gtext("")
Return

cleanvcache: ; ---------- cleanvcache ---------- ;
gtext("Claning vCache...")
Loop, Files, %A_WorkingDir%\.GTRP\switch\*, R
{
	FDel := "vCache_" . A_LoopFileName . ".ahk"
	WinClose, %A_WorkingDir%\%FDel% ahk_class AutoHotkey
	FileDelete, %A_WorkingDir%\%FDel%
}
gtext("vCache cleaned")
gtext("")
Return

cleancache: ;---------- cleancache ----------;
gtext("Cleaning cache...")
FileRemoveDir, %A_WorkingDir%\.GTRP\cache\, 1
FileRemoveDir, %A_WorkingDir%\.GTRP\switch\, 1
FileCopyDir, %A_WorkingDir%\.GTRP\GameCache\, %A_WorkingDir%\, 1
FileCopyDir, %A_WorkingDir%\.GTRP\GameCache\, %A_WorkingDir%\cache\, 1
FileRemoveDir, %A_WorkingDir%\.GTRP\GameCache\, 1
FileCreateDir, %A_WorkingDir%\.GTRP\GameCache\
gtext("Cache cleaned")
gtext("")
Return

closegtrp: ; ---------- closegtrp ---------- ;
gtext("Closing GTRP Launcher...")
Sleep, 800
ExitApp
Return

errorlog: ; ---------- errorlog ---------- ;
GuiControlGet, GELog, , GLog
FormatTime, TimeString, ,
FileAppend, `n`n`n---------- Error Log ----------`n%TimeString%`n (Start Log)`n%GELog%`n (End Log), %A_WorkingDir%\.GTRP\error-log.txt
gtext("An error log has been created at .GTRP\error-log.txt")
gtext("")
Sleep, 1000
Return

gdisable: ; ---------- gdisable ---------- ;
GuiControl, Disable, GLaunch
GuiControl, Disable, GInstall
GuiControl, Disable, GRPList
GuiControl, Disable, GRPToggle
GuiControl, Disable, GRPDelete
GuiControl, Disable, GSet1
GuiControl, Disable, GSet2
GuiControl, Disable, GSet3
GuiControl, Disable, GSet4
Return

genable: ; ---------- genable ---------- ;
GuiControl, Enable, GLaunch
GuiControl, Enable, GInstall
GuiControl, Enable, GRPList
GuiControl, Enable, GRPToggle
GuiControl, Enable, GRPDelete
GuiControl, Enable, GSet1
GuiControl, Enable, GSet2
GuiControl, Enable, GSet3
GuiControl, Enable, GSet4
GRPIndex := 0
Return

gtext(ntext) ; ---------- gtext ---------- ;
{
	if(!ntext)
		ntext := " "
	GuiControlGet, GOLog, , GLog
	FormatTime, TimeString, , hh:mm:ss
	if(GOLog)
		GuiControl, , GLog, %GOLog%`n[%TimeString%] %ntext%
	else
		GuiControl, , GLog, [%TimeString%] %ntext%
	ControlSend, Edit3, ^{End}, GTRP Client ahk_class AutoHotkeyGUI
	Sleep, textDelay
	Return
}

ginfo(ntext) ; ---------- ginfo  ---------- ;
{
	if(!ntext)
		ntext := " "
	GuiControlGet, GOLog, , GRPInfo
	if(GOLog)
		GuiControl, , GRPInfo, %GOLog%`n%ntext%
	else
		GuiControl, , GRPInfo, %ntext%
	Return
}

ConnectedToInternet(flag=0x40) { 
Return DllCall("Wininet.dll\InternetGetConnectedState", "Str", flag,"Int",0) 
}
