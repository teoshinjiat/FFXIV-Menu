WinGet, GameID, ID, ahk_class FFXIVGAME
#MaxThreadsPerHotkey, 2
#Persistent
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, Force
SetMouseDelay, 5
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
SetTimer, ForceExitApp,  3600000 ; 60 minutes

DebugWindow("GUI input",1,1,200,0)

Gui, Add, ListBox, r5 vScript, AutoSynthesis|Green|Blue|Black|White
Gui, Add, Button, default, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.
Gui, Show,, Simple Input Example
return  ; End of auto-execute section. The script is idle until the user does something.


ButtonCancel:
GuiClose:
GuiEscape:
Gui, Hide
Return   

ButtonOK:
Gui, Submit

if(Script="AutoSynthesis") {
	Run "C:\Users\teosh\Desktop\ahk\autoSynthesis\autoSynthesis.ahk"
}
