#SingleInstance, Force
DebugWindow("Started script.",1,1,200,0)
MainScriptArray := ["Auto Synthesis", "Auto Gather", "Auto Fish"]

menuData := []
menuData[ 1 ] := {function:"gAutoSynthesis", value:"vMainScript1", label:"Auto Synthesis", subOptions:[{value:"Disabled vMainScript1_SubCheckBox1", label:"Auto refresh food"}, {value:"Disabled vMainScript1_SubCheckBox2", label:"Auto refresh medicine"}, {value:"Disabled vMainScript1_SubCheckBox3", label:"Collectable"}]}
menuData[ 2 ] := {function:"gAutoGather", value:"vMainScript2", label:"Auto Gather"}
menuData[ 3 ] := {function:"gAutoFish", value:"vMainScript3", label:"Auto Fish"}

Gui, Color, 0x808080
Gui, Font, s10, Verdana
Gui, Font, bold

for i, obj in menuData{
	function:=menuData[i].function
	value:=menuData[i].value
	label:=menuData[i].label
	Gui, Add, Checkbox, x25 %function% %value%, %label%
	for key, field in menuData[i].subOptions{
		value:=menuData[i].subOptions[key].value
		label:=menuData[i].subOptions[key].label
		Gui, Add, Checkbox, x60 %value%, %label%
		
		;DebugWindow("Array: " i "`nKey: " key "`nAnimal: " animal,0,1,200,0)
		;Gui, Add, Checkbox, x25 menuData[i].function menuData[i].value, menuData[i].label
	}
}

Gui, Add, Button, default, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.
Gui, Show, w640 h480, FFXIV Menu
return  ; End of auto-execute section. The script is idle until the user does something.


ButtonCancel:
GuiClose:
GuiEscape:
Gui, Destroy
Return   


ButtonOK:
Gui, Submit
checkedBoxIndex:=getCheckedBox()
if(checkedBoxIndex="1") {
	foodRefresh:=MainScript1_SubCheckBox1
	medicineRefresh:=MainScript1_SubCheckBox2
	collectableFlag:=MainScript1_SubCheckBox3
	Run "C:\Users\teosh\Desktop\ahk\autoSynthesis\autoSynthesis.ahk" %foodRefresh% %medicineRefresh% %collectableFlag%
} else if(checkedBoxIndex="2") {
	Run "C:\Users\teosh\Desktop\ahk\gather\gather.ahk"
} else if(checkedBoxIndex="3") {
	Run "C:\Users\teosh\Desktop\ahk\fish\fish.ahk"
}

getCheckedBox(){
	Loop, 3{
		GuiControlGet, CheckBoxState,, MainScript%A_Index%
		if(CheckBoxState=1){
			return %A_Index%
		}
	}
	
}

AutoSynthesis(){ ;1
	uncheckMainScriptBoxes(1)
}

AutoGather(){ ;2
	uncheckMainScriptBoxes(2)
}

AutoFish(){ ;1
	uncheckMainScriptBoxes(3)
}

uncheckMainScriptBoxes(index){
	Loop, 7 {
		MainScriptLoopIndex := A_index
		GuiControlGet, CheckBoxState,, MainScript%A_Index%
		If (MainScriptLoopIndex = index)
		{ 
			Loop, 3{
				If (CheckBoxState = 1)
				{ 
					GuiControl, Enable, MainScript%MainScriptLoopIndex%_SubCheckBox%A_Index%
				} 
				Else 
				{
					GuiControl, Disabled, MainScript%MainScriptLoopIndex%_SubCheckBox%A_Index%
					GuiControl,, MainScript%MainScriptLoopIndex%_SubCheckBox%A_Index%, 0 ;to uncheck subBoxes when mainBox is uncheck
				}
			}
		}
		
		If (MainScriptLoopIndex != index)
		{ 
			GuiControl,, MainScript%A_Index%, 0 ;to uncheck other mainBoxes
			Loop, 3 { ;to uncheck and disable other subBoxes
				GuiControl, Disabled, MainScript%MainScriptLoopIndex%_SubCheckBox%A_Index%
				GuiControl,, MainScript%MainScriptLoopIndex%_SubCheckBox%A_Index%, 0 ;to uncheck other mainBoxes				
			}
		} 
	}
}

^r::ExitApp DebugWindow("All scripts terminated...",1,1,200,0)
Pause::Pause

DetectHiddenWindows, On
WM_COMMAND := 0x0111
ID_FILE_PAUSE := 65403
PostMessage, WM_COMMAND, ID_FILE_PAUSE,,, C:\YourScript.ahk ahk_class AutoHotkey