DebugWindow("GUI input",1,1,200,0)

Gui, Add, ListBox, r5 vScript, AutoSynthesis|Green|Blue|Black|White
Gui, Add, Button, default, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.
Gui, Show,, Simple Input Example
return  ; End of auto-execute section. The script is idle until the user does something.

GuiClose:
ButtonOK:
Gui, Submit  ; Save the input from the user to each control's associated variable.

DebugWindow("vScript:" Script,0,1,200,0)

if(Script="AutoSynthesis") {
	Run "C:\Users\teosh\Desktop\ahk\autoSynthesis\autoSynthesis.ahk"
}
