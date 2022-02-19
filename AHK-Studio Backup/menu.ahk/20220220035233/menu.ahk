#SingleInstance, Force
DebugWindow("Started script.",1,1,200,0)
MainScriptArray := ["Auto Synthesis", "Auto Gather", "Auto Fish"]

global menuData := []
menuData[ 1 ] := {function:"gAutoSynthesis", value:"vMainScript1", label:"Auto Synthesis", subOptionGuiType:"Checkbox", subOptions:[{value:"Disabled vMainScript1_SubCheckBox1", label:"Auto refresh food"}, {value:"Disabled vMainScript1_SubCheckBox2", label:"Auto refresh medicine"}, {value:"Disabled vMainScript1_SubCheckBox3", label:"Collectable"}]}
menuData[ 2 ] := {function:"gAutoQuickSynthesis", value:"vMainScript2", label:"Auto Quick Synthesis"}
menuData[ 3 ] := {function:"gAutoGather", value:"vMainScript3", label:"Auto Gather"}
menuData[ 4 ] := {function:"gAutoFish", value:"vMainScript4", label:"Auto Fish"}

menuData[ 5 ] := {function:"gEulmore", value:"vMainScript5", label:"Auto Eulmore Turnin", subOptionGuiType:"ListBox", subOptions:[{value:"Disabled vMainScript5_SubCheckBox1", label:"Craftsman's Command Materia X"}]}


menuData[ 6 ] := {function:"gProfitCalculator", value:"vMainScript6", label:"Profit Calculator"}

Gui, Color, 0x808080
Gui, Font, s10, Verdana
Gui, Font, bold

;populating GUI menu
for i, obj in menuData{ ;mainBox mainscript boxes
	function:=menuData[i].function
	value:=menuData[i].value
	label:=menuData[i].label
	Gui, Add, Checkbox, x25 %function% %value%, %label%
	for key, field in menuData[i].subOptions{ ;subBox options(parameters)
		
		subOptionGuiType:=menuData[i].subOptionGuiType
		value:=menuData[i].subOptions[key].value
		label:=menuData[i].subOptions[key].label
		;Gui, Add, %subOptionGuiType%, x60 %value%, %label%
		Gui, Add, %subOptionGuiType%, (subOptionGuiType = "Checkbox") ? x60 ! x200 %value%, %label%
		
		
		;DebugWindow("Array: " i "`nKey: " key "`nAnimal: " animal,0,1,200,0)
		;Gui, Add, Checkbox, x25 menuData[]i.function menuData[i].value, menuData[i].label
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
	Run "C:\Users\teosh\Desktop\ahk\autoQuickSynthesis\autoQuickSynthesis.ahk"
} else if(checkedBoxIndex="3") {
	Run "C:\Users\teosh\Desktop\ahk\gather\gather.ahk"
} else if(checkedBoxIndex="4") {
	Run "C:\Users\teosh\Desktop\ahk\fish\fish.ahk"
} else if(checkedBoxIndex="5") {
	item1:=MainScript5_SubCheckBox1
	Run "C:\Users\teosh\Desktop\ahk\eulmoreTurnin\eulmoreTurnin.ahk" %item1%
} else if(checkedBoxIndex="6") {
	Run "C:\Users\teosh\Desktop\ahk\profitCalculator\profitCalculator.ahk"
}

getCheckedBox(){
	Loop, 5{
		GuiControlGet, CheckBoxState,, MainScript%A_Index%
		if(CheckBoxState=1){
			return %A_Index%
		}
	}
	
}

;hardcoded because g-label doesnt support parameter passing
AutoSynthesis(){ ;1
	uncheckMainScriptBoxes(1)
}

AutoQuickSynthesis(){ ;2
	uncheckMainScriptBoxes(2)
}

AutoGather(){ ;3
	uncheckMainScriptBoxes(3)
}

AutoFish(){ ;4
	uncheckMainScriptBoxes(4)
}

Eulmore(){ ;5
	uncheckMainScriptBoxes(5)
}

ProfitCalculator(){ ;6
	uncheckMainScriptBoxes(6)
}

uncheckMainScriptBoxes(selectedIndex){
	for i, obj in menuData{
		mainScriptLoopIndex := i
		GuiControlGet, CheckBoxState,, MainScript%mainScriptLoopIndex%
		If (mainScriptLoopIndex = selectedIndex) ;to enable the disabled fields for the matched mainBox(ScriptBoxes)
		{ 
			for key, field in menuData[i].subOptions{ ;looping sub boxes
				If (CheckBoxState = 1)
				{ 
					GuiControl, Enable, MainScript%mainScriptLoopIndex%_SubCheckBox%A_Index%
				} 
				Else 
				{
					GuiControl, Disabled, MainScript%mainScriptLoopIndex%_SubCheckBox%A_Index%
					GuiControl,, MainScript%mainScriptLoopIndex%_SubCheckBox%A_Index%, 0 ;to uncheck subBoxes when mainBox is uncheck
				}
			}
		}
		
		If (mainScriptLoopIndex != selectedIndex)
		{ 
			GuiControl,, MainScript%A_Index%, 0 ;to uncheck other mainBoxes
			Loop, 3 { ;to uncheck and disable other subBoxes
				GuiControl, Disabled, MainScript%mainScriptLoopIndex%_SubCheckBox%A_Index%
				GuiControl,, MainScript%mainScriptLoopIndex%_SubCheckBox%A_Index%, 0 ;to uncheck other mainBoxes				
			}
		} 
	}
}

^F4::ExitApp DebugWindow("All scripts terminated...",1,1,200,0)

Pause::Pause
PostMessage, 0x111, 65306,,, autoSynthesis.ahk  ;sending pause to other running scripts, press hotkey again to resume
PostMessage, 0x111, 65306,,, autoQuickSynthesis.ahk  ;sending pause to other running scripts, press hotkey again to resume
PostMessage, 0x111, 65306,,, gather.ahk  ;sending pause to other running scripts, press hotkey again to resume
PostMessage, 0x111, 65306,,, fish.ahk  ;sending pause to other running scripts, press hotkey again to resume
PostMessage, 0x111, 65306,,, eulmoreTurnin.ahk  ;sending pause to other running scripts, press hotkey again to resume
PostMessage, 0x111, 65306,,, profitCalculator.ahk  ;sending pause to other running scripts, press hotkey again to resume

