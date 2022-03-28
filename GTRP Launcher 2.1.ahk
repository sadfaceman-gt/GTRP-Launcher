; Top Sneaky

; -------------------- Initialization -------------------- ;

#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#Include %A_ScriptDir%\.GTRP\RunAsTask.ahk
#SingleInstance Off
DetectHiddenWindows, On

; -------------------------- Growtopia Resprite Project Launcher ------------------------- ;
;                                    Made by SadFaceMan                                    ;
                                      Version := "2.1"
;                           Powered by Growtopia Resprite Project                          ;
; ---------------------------------------------------------------------------------------- ;

Global textDelay := 50

; -------------------- You shouldn't edit anything beyond this point -------------------- ;

global rploadname := [] ; List of loaded resprites
global rpname := [] ; List of ALL resprites
global rpload := [] ; If resprite is whitelisted (True/False)
global settings := []
; SETTINGS
; 1. Always run as administrator (Default : Enabled)
; 2. List loaded resprites upon launching GTRP (Default : Enabled)
; 3. Launch GTRP immediately upon startup (Default : Disabled)
; 4. Close GTRP Launcher after closing GTRP (Default : Disabled)
global mode := 1 ; Menu, Game, Load, Resprite, Settings 
sloadgame := false

; -------------------- Gui initialization and installation check -------------------- ;

if not WinExist("GTRP Client ahk_class AutoHotkeyGUI")
	sloadgame := true
Gui, Font, c00FF00 s12, Consolas
Gui, Color, 000000
tpad := ""
Loop, 8
{
	tpad := tpad . ".........."
}
Gui, add, text, R3 vgtitle, %tpad%`n%tpad%`n%tpad%
Gui, Add, Edit, R16 W800 Wrap ReadOnly vgedit, %tpad%
Gui, Add, Edit, R1 W630 -Wrap vginput, %tpad%
Gui, Add, Button, x+10 R1 W75 +Default gnextgui vgbutton, OK
Gui, Add, Button, x+10 R1 W75 gexitgui, Exit
GuiControl, , gtitle, 
GuiControl, , gedit, 
GuiControl, , ginput, 
GuiControl, Disable, gbutton
GuiControl, Disable, ginput
Gui, Font, c000000 s12, Consolas
GuiControl, Font , ginput, 
GuiControl, +Center, gtitle
Gui, Show, Center, GTRP Client
gtitle("Growtopia Resprite Project Launcher", "Made by SadFaceMan", "Version " . Version)
initcheck := []
initcheck.Push("Growtopia.exe")
initcheck.Push(".GTRP")
initerror := 0
i := 1
Loop
{
	if(initcheck[i])
	{
		if not FileExist(A_WorkingDir . "\" . initcheck[i])
		{
			gtext("Couldn't find " . initcheck[i] . ", are you sure you've installed GTRP Launcher correctly?")
			initerror++
			Sleep, 1200
		}
		i++
	}
	else
	{
		Break
	}
}
if(initerror >= 1) 
	Gosub, closegtrp
Gosub, getlistresprites
Gosub, getsettings
if(settings[3] and sloadgame) or FileExist(A_WorkingDir . "\.GTRP\autostart")
{
	FileDelete, %A_WorkingDir%\.GTRP\autostart
	Gosub, mode_game
	Return
}
Gosub, mode_menu
Gosub, genable
Return

; -------------------- GUI Modes -------------------- ;

mode_menu: ; ---------- menu/1 ---------- ;
mode := 1
gtext("")
gtext(" - Growtopia Resprite Project Launcher - ")
gtext("[1] Launch GTRP")
gtext("[2] Install a resprite")
gtext("[3] Delete a resprite")
gtext("[4] View loaded resprites")
gtext("[5] Settings")
gtext("")
gtext("Select a number")
Return

mode_install: ; ---------- install/3 ---------- ;
mode := 3
FileRemoveDir, %A_WorkingDir%\.GTRP\temp\, 1
RPName := ""
RPCreatorName := ""
RPPackageVer := ""
RPLoaderVer := ""
RPDesc := ""
gtext("")
gtext(" - GTRP Resprite Installation - ")
gtext("Select a resprite (.gtrp)")
FileSelectFile, FPath, , , Select a resprite, GTRP Resprites (*.gtrp)
if(!FPath)
{
	gtext("Installation cancelled")
	Sleep, 1000
	Gosub, mode_menu
	Return
}
SplitPath, FPath, FName, FDir, FExt, FTName, FDrive
if(FExt != "gtrp")
{
	gtext("Unknown file extension! Installation cancelled")
	Sleep, 1000
	Gosub, mode_menu
	Return
}

gtext("Extracting " . FName . "...")
FileCreateDir, %A_WorkingDir%\.GTRP\temp\
FileCopy, %FPath%, %A_WorkingDir%\.GTRP\temp\%FTName%.zip, 1
RunWait PowerShell.exe -Command Expand-Archive -LiteralPath '%A_WorkingDir%\.GTRP\temp\%FTName%.zip' -DestinationPath %A_WorkingDir%\.GTRP\temp\,, Hide

if not FileExist(A_WorkingDir . "\.GTRP\temp\data")
{
	gtext("Invalid GTRP resprite! Installation cancelled")
	Sleep, 1000
	Gosub, mode_menu
	Return
}

FileReadLine, RPName, %A_WorkingDir%\.GTRP\temp\data, 1
FileReadLine, RPCreatorName, %A_WorkingDir%\.GTRP\temp\data, 2
FileReadLine, RPPackageVer, %A_WorkingDir%\.GTRP\temp\data, 3
FileReadLine, RPLoaderVer, %A_WorkingDir%\.GTRP\temp\data, 4
FileReadLine, RPDesc, %A_WorkingDir%\.GTRP\temp\data, 5
gtext("")
if(!RPName)
	RPName := FTName
gtext("Resprite Name    : " . RPName)
if(RPCreatorName)
	gtext("Resprite Creator : " . RPCreatorName)
if(RPPackageVer)
	gtext("Resprite Version : " . RPPackageVer)
if(RPLoaderVer)
	gtext("Loader Version   : " . RPLoaderVer)
if(RPDesc)
	gtext("Description      : " . RPDesc)
if FileExist(A_WorkingDir . "\.GTRP\Resprites\" . RPName . ".gtrp")
{
	gtext("")
	gtext(" <!> WARNING <!>")
	gtext(RPName . " already exists. Installing this resprite will replace the existing one.")
}
gtext("")
gtext("[1] Install resprite")
gtext("[0] Return to menu")
gtext("")
gtext("Select an option")
Return

mode_del: ; ---------- delete/4 ---------- ;
mode := 4
dmode := 1
gtext("")
gtext(" - Delete Resprites - ")
Gosub, getlistresprites
Loop
{
	if(!rpname[A_Index])
		Break
	gtext("[" . A_Index . "] " . rpname[A_Index])
}
gtext("[0] Return to menu")
gtext("")
gtext("Select an option")
Return

mode_rp: ; ---------- loaded resprites/5 ---------- ;
mode := 5
gtext("")
gtext(" - Loaded Resprites - ")
Gosub, getlistresprites
Loop
{
	if(!rpname[A_Index])
		Break
	if(rpload[A_Index])
		gtext("[" . A_Index . "] [Enabled ] " . rpname[A_Index])
	Else
		gtext("[" . A_Index . "] [Disabled] " . rpname[A_Index])
}
gtext("[0] Return to menu")
gtext("")
gtext("Select an option")
Return

mode_set: ; ---------- settings/6 ---------- ;
mode := 6
gtext("")
gtext(" - Settings - ")
Gosub, getsettings
if(settings[1])
	gtext("[1] [Enabled ] Always launch GTRP as administrator (Default)")
else
	gtext("[1] [Disabled] Do not launch GTRP as administrator")
if(settings[2])
	gtext("[2] [Enabled ] List loaded resprites upon launching GTRP (Default)")
else
	gtext("[2] [Disabled] Do not list loaded resprites upon launching GTRP")
if(settings[3])
	gtext("[3] [Enabled ] Launch GTRP immediately upon startup")
else
	gtext("[3] [Disabled] Do not Launch GTRP immediately upon startup (Default)")
if(settings[4])
	gtext("[4] [Enabled ] Close GTRP Launcher after closing GTRP")
else
	gtext("[4] [Disabled] Keep GTRP Launcher open after closing GTRP (Default)")
gtext("[0] Return to menu")
gtext("")
gtext("Select an option")
Return

mode_game: ; ---------- GTRP/game/2 ---------- ;
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
	Sleep, 1000
}
if not FileExist(A_WorkingDir . "\save.dat")
{
	gtext(" <!> WARNING <!>")
	gtext("Couldn't find save.dat, make sure you've run Growtopia at least once before starting GTRP!")
	Sleep, 1000
	Gosub, btmenu
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
		Gosub, getlistresprites
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
		Gosub, loadcache
		Gosub, extractresprites
		Gosub, loadvcache
		gtext("Resprites reloaded!")
		gtext("")
		Gosub, btmenu
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
Gosub, getlistresprites
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
Gosub, loadcache
Gosub, extractresprites
Gosub, loadvcache
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
gtext("")
Gosub, cleanvcache
Gosub, cleancache
Gosub, btmenu
Return

btmenu:
if(settings[4])
{
	Gosub, closegtrp
	ExitApp
}
mode := 1
Gosub, mode_menu
Gosub, genable
Return

; -------------------- Button actions -------------------- ;

nextgui: ; ---------- OK Button ---------- ;
Gosub, gdisable
GuiControlGet, n, , ginput
gtext(n)

if(n = "help" or n = "h") ; ---------- OK Button : Special commands ---------- ;
{
	gtext("")
	gtext(" - Growtopia Resprite Project Launcher - ")
	gtext(" Made by SadFaceMan")
	gtext(" Version " . Version)
	gtext(" Powered by Growtopia Resprite Project")
	gtext("")
	gtext("Enter number (1, 2, 3, ...) to select your option, then hit 'OK'")
	gtext("")
	gtext(" Special commands")
	gtext("help  : Shows this screen")
	gtext("clear : Clears the console")
	Sleep, 5000
	Gosub, rtn
}
else if(n = "clear" or n = "clr" or n = "c")
{
	GuiControl, , gedit, 
	gtext("Console cleared")
	Sleep, 1000
	Gosub, rtn
}

else if(mode = 1) ; ---------- OK Button : Menu ---------- ;
{
	if (n > 0 and n < 6)
		mode := n+1
	Else
	{
		gtext("Invalid option")
		Sleep, 1000
	}
	Gosub, rtn
}

else if(mode = 3) ; ---------- OK Button : Install ---------- ;
{
	if(n = 1)
	{
		gtext("Installing " . RPName . "...")
		FileCopy, %A_WorkingDir%\.GTRP\temp\%FTName%.zip, %A_WorkingDir%\.GTRP\Resprites\%RPName%.gtrp, 1
		gtext(RPName . " successfully installed")
	}
	else
		gtext("Installation cancelled")
	Sleep, 1000
	FileRemoveDir, %A_WorkingDir%\.GTRP\temp\, 1
	mode := 1
	Gosub, rtn
}

else if(mode = 4) ; ---------- OK Button : Delete ---------- ;
{
	if(dmode = 1)
	{
		if(n = 0)
		{
			mode := 1
			Gosub, rtn
		}
		else if(!rpname[n])
		{
			gtext("Invalid option")
			Sleep, 1000
			Gosub, rtn
		}
		else
		{
			FDel := rpname[n]
			gtext("Are you sure you want to delete " . FDel . "?")
			gtext("[1] Delete resprite (This action cannot be undone!)")
			gtext("[0] Cancel")
			gtext("")
			gtext("Select an option")
			dmode := 2
		}
	}
	Else
	{
		if(n = 1)
		{
			FileDelete, %A_WorkingDir%\.GTRP\Resprites\%FDel%.gtrp
			gtext(FDel . " successfully deleted")
		}
		Else
			gtext("Deletion cancelled")
		dmode := 1
		Sleep, 1000
		Gosub, rtn
	}
}

else if(mode = 5) ; ---------- OK Button : Loaded ---------- ;
{
	if(n = 0)
		mode := 1
	else if(!rpname[n])
	{
		gtext("Invalid option")
		Sleep, 1000
	}
	else
	{
		FName := rpname[n]
		if(rpload[n])
		{
			FileAppend, , %A_WorkingDir%\.GTRP\Blacklist\%FName%
			gtext(FName . " blacklisted")
		}
		else
		{
			FileDelete, %A_WorkingDir%\.GTRP\Blacklist\%FName%
			gtext(FName . " whitelisted")
		}
		Sleep, 1000
	}
	Gosub, rtn
}

else if (mode = 6) ; ---------- OK Button : Settings ---------- ;
{
	if(n = 0)
		mode := 1
	else if (n > 0 or n < 5)
	{
		if (settings[n])
			settings[n] := 0
		else
			settings[n] := 1
		FileDelete, %A_WorkingDir%\.GTRP\Settings
		Loop, 4
		{
			nset := settings[A_Index]
			FileAppend, %nset%`n, %A_WorkingDir%\.GTRP\Settings
		}
	}
	else
	{
		gtext("Invalid option")
		Sleep, 1000
	}
	Gosub, rtn
}

Gosub, genable
Return
rtn:
if(mode = 1)
	Gosub, mode_menu
else if (mode = 2)
	Gosub, mode_game
else if (mode = 3)
	Gosub, mode_install
else if (mode = 4)
	Gosub, mode_del
else if (mode = 5)
	Gosub, mode_rp
else if (mode = 6)
	Gosub, mode_set
Return

exitgui: ; ---------- Exit Button ---------- ;
Gosub, gdisable
Gosub, closegtrp
ExitApp

; -------------------- Subs and functions -------------------- ;

getlistresprites: ; ---------- getlistresprites ---------- ;
rploadname := []
rpname := []
rpload := []
Loop, Files, %A_WorkingDir%\.GTRP\Resprites\*.gtrp, R
{
	SplitPath, A_LoopFilePath, FName, FDir, FExt, FTName, FDrive
	rpname.Push(FTName)
	if FileExist(A_WorkingDir . "\.GTRP\Blacklist\" . FTName)
		rpload.Push(false)
	else
	{
		rpload.Push(true)
		rploadname.Push(FTName)
	}
}
Return

getsettings: ; ---------- getsettings ---------- ;
settings := []
if not FileExist(A_WorkingDir . "\.GTRP\Settings")
	FileAppend, 1`n1`n0`n0, %A_WorkingDir%\.GTRP\Settings
Loop, 4
{
	FileReadLine, spush, %A_WorkingDir%\.GTRP\Settings, %A_Index%
	settings.Push(spush)
}
Return

loadcache: ;---------- loadcache ----------;
gtext("Loading cache...")
FileCreateDir, %A_WorkingDir%\.GTRP\cache\
FileCreateDir, %A_WorkingDir%\.GTRP\switch\
;FileCopyDir, %A_WorkingDir%\cache\, %A_WorkingDir%\.GTRP\cache\, 1
gtext("Cache copied")
gtext("")
Return

extractresprites: ; ---------- extractresprites ---------- ;
gtext("Extracting resprites...")
Loop
{
	if(!rploadname[A_Index])
		Break
	FName := rploadname[A_Index]
	gtext("Extracting " . FName . "...")
	FileCopy, %A_WorkingDir%\.GTRP\Resprites\%FName%.gtrp, %A_WorkingDir%\.GTRP\Resprites\%FName%.zip, 1
	FileCreateDir, %A_WorkingDir%\.GTRP\Resprites\%FName%\
	RunWait PowerShell.exe -Command Expand-Archive -LiteralPath '%A_WorkingDir%\.GTRP\Resprites\%FName%.zip' -DestinationPath '%A_WorkingDir%\.GTRP\Resprites\%FName%\',, Hide
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
	FileRemoveDir, %A_WorkingDir%\.GTRP\Resprites\%FName%\, 1
	FileDelete, %A_WorkingDir%\.GTRP\Resprites\%FName%.zip
}
gtext("Resprites extracted")
gtext("")
Return

loadvcache: ; ---------- loadvcache ---------- ;
gtext("Loading vCache...")
Loop, Files, %A_WorkingDir%\.GTRP\switch\*, R
{
	gtext("Loading " . A_LoopFileName . "...")
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

gdisable: ; ---------- gdisable ---------- ;
GuiControl, Disable, gbutton
GuiControl, Disable, ginput
Return

genable: ; ---------- genable ---------- ;
GuiControl, Enable, gbutton
GuiControl, Enable, ginput
GuiControl, , ginput, 
ControlSend, Edit1, {Tab}, GTRP Client ahk_class AutoHotkeyGUI
Return

gtitle(nt1, nt2, nt3) ; ---------- gtitle ---------- ;
{
	GuiControl, , gtitle, %nt1%`n%nt2%`n%nt3%
	Return
}

gtext(ntext) ; ---------- gtext ---------- ;
{
	if(!ntext)
		ntext := " "
	GuiControlGet, gotext, , gedit
	FormatTime, TimeString, , hh:mm:ss
	if(gotext)
		GuiControl, , gedit, %gotext%`n[%TimeString%] %ntext%
	else
	{
		GuiControl, , gedit, [%TimeString%] %ntext%
	}
	ControlSend, Edit1, ^{End}, GTRP Client ahk_class AutoHotkeyGUI
	Sleep, textDelay
	Return
}
