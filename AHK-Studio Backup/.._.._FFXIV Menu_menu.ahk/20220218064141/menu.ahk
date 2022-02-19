WinGet, GameID, ID, ahk_class FFXIVGAME
#SingleInstance, Force

DebugWindow("GUI input",1,1,200,0)

Gui, Add, ListBox, r5 vScript, AutoSynthesis| |AutoGather| |AutoFish
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
} else if(Script="AutoGather") {
	Run "C:\Users\teosh\Desktop\ahk\autoSynthesis\autoSynthesis.ahk"
} else if(Script="AutoFish") {
	Run "C:\Users\teosh\Desktop\ahk\fish\fish.ahk"
}

^r::ExitApp
DebugWindow("All scripts terminated...",1,1,200,0)
