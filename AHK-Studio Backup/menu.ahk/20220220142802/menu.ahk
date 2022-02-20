#SingleInstance, Force
SetWorkingDir %A_ScriptDir%
DebugWindow("Started script.",1,1,200,0)
MainScriptArray := ["Auto Synthesis", "Auto Gather", "Auto Fish"]

global menuData := []
menuData[ 1 ] := {function:"gAutoSynthesis", value:"vMainScript1", label:"Auto Synthesis", subOptionGuiType:"Checkbox", subOptionGuiStyle:"x60", subOptions:[{value:"Disabled vMainScript1_SubItem1", label:"Auto refresh food"}, {value:"Disabled vMainScript1_SubItem2", label:"Auto refresh medicine"}, {value:"Disabled vMainScript1_SubItem3", label:"Collectable"}]}
menuData[ 2 ] := {function:"gAutoQuickSynthesis", value:"vMainScript2", label:"Auto Quick Synthesis"}
menuData[ 3 ] := {function:"gAutoGather", value:"vMainScript3", label:"Auto Gather"}
menuData[ 4 ] := {function:"gAutoFish", value:"vMainScript4", label:"Auto Fish"}
menuData[ 5 ] := {function:"gEulmore", value:"vMainScript5", label:"Auto Eulmore Turnin", subOptionGuiType:"ListBox", subOptionGuiStyle:"w350", subOptions:[{value:"Disabled vMainScript5_SubItem1", label:"Craftsmans Command Materia X"}]}
menuData[ 6 ] := {function:"gProfitCalculator", value:"vMainScript6", label:"Profit Calculator"}

Gui,Add,Picture, x0 y0 w720 h188,gui.png
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
		value:=menuData[i].subOptions[key].value
		label:=menuData[i].subOptions[key].label
		subOptionGuiType:=menuData[i].subOptionGuiType
		subOptionGuiStyle:=menuData[i].subOptionGuiStyle		
		Gui, Add, %subOptionGuiType%, %subOptionGuiStyle% %value%, %label%
		;DebugWindow("Array: " i "`nKey: " key "`nAnimal: " animal,0,1,200,0)
		;Gui, Add, Checkbox, x25 menuData[]i.function menuData[i].value, menuData[i].label
	}
}


Gui, Add, Button, default, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.
Gui, Show, w720 h500, FFXIV Menu
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
	foodRefresh:=MainScript1_SubItem1
	medicineRefresh:=MainScript1_SubItem2
	collectableFlag:=MainScript1_SubItem3
	Run autoSynthesis\autoSynthesis.ahk %foodRefresh% %medicineRefresh% %collectableFlag%
	;Run autoSynthesis_gdip\autoSynthesis_gdip.ahk %foodRefresh% %medicineRefresh% %collectableFlag%
} else if(checkedBoxIndex="2") {
	Run "C:\Users\teosh\Desktop\ahk\autoQuickSynthesis\autoQuickSynthesis.ahk"
} else if(checkedBoxIndex="3") {
	Run "C:\Users\teosh\Desktop\ahk\gather\gather.ahk"
} else if(checkedBoxIndex="4") {
	Run "C:\Users\teosh\Desktop\ahk\fish\fish.ahk"
} else if(checkedBoxIndex="5") {
	selectedItem:=MainScript5_SubItem1
	selectedItem:=StrReplace(selectedItem, " ", "_") ;replace space in string for easier matching
	Run eulmoreTurnin\eulmoreTurnin.ahk %selectedItem%
} else if(checkedBoxIndex="6") {
	Run "C:\Users\teosh\Desktop\ahk\profitCalculator\profitCalculator.ahk"
}

getCheckedBox(){
	Loop, 7{
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

; UIUX enhancement
uncheckMainScriptBoxes(selectedIndex){
	for i, obj in menuData{
		mainScriptLoopIndex := i
		GuiControlGet, CheckBoxState,, MainScript%mainScriptLoopIndex%
		If (mainScriptLoopIndex = selectedIndex) ;to enable the disabled fields for the matched mainBox(ScriptBoxes)
		{ 
			for key, field in menuData[i].subOptions{ ;looping sub boxes
				
				If (CheckBoxState = 1)
				{ 
					GuiControl, Enable, MainScript%mainScriptLoopIndex%_SubItem%A_Index%
				} 
				Else 
				{
					GuiControl, Disabled, MainScript%mainScriptLoopIndex%_SubItem%A_Index%
					
					if(menuData[i].subOptionGuiType="Checkbox"){
						GuiControl,, MainScript%mainScriptLoopIndex%_SubItem%A_Index%, 0 ;to uncheck subBoxes when mainBox is uncheck						
					}
				}
			}
		}
		
		If (mainScriptLoopIndex != selectedIndex)
		{ 
			GuiControl,, MainScript%A_Index%, 0 ;to uncheck other mainBoxes
			for key, field in menuData[i].subOptions{ ;to uncheck and disable other subBoxes
				GuiControl, Disabled, MainScript%mainScriptLoopIndex%_SubItem%A_Index%
				if(menuData[i].subOptionGuiType="Checkbox"){
					GuiControl,, MainScript%mainScriptLoopIndex%_SubItem%A_Index%, 0 ;to uncheck other subBoxes when clicking other mainBox away from current selected mainBox				
				} else { ; deselect item from selected items in List
					GuiControl, Choose, MainScript%mainScriptLoopIndex%_SubItem%A_Index%, 0
				}
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
