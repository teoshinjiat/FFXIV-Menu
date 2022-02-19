DebugWindow("GUI input",0,1,200,0)

Gui, Add, Checkbox, vAutoSynthesis, Auto refresh food (numpad9) when it's less than 10 minutes
if(vAutoSynthesis){
	Gui, Add, Checkbox, vAutoSynthesis, Auto refresh food (numpad9) when it's less than 10 minutes
	
}
	Gui, Add, Checkbox, vMedicineFlag, Auto refresh medicine (numpad8) when it's less than 60 seconds
Gui, Add, Checkbox, vCollectableFlag, Collectable ;if true then send numpad0

;Gui, Add, Checkbox, hwndHCB Checked, Check
Gui, Add, DropDownList, hwndHDDL, A|B||C
Gui, Add, Button, default, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.
Gui, Show,, Simple Input Example
return  ; End of auto-execute section. The script is idle until the user does something.

GuiClose:
ButtonOK:
Gui, Submit  ; Save the input from the user to each control's associated variable.