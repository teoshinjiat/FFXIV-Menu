#SingleInstance, Force
#Persistent
SetWorkingDir %A_ScriptDir%
#include lib\json\json.ahk
#include lib\utility\utility.ahk
#include lib\gdip\Gdip_All.ahk
#include lib\gdip\imageSearch\Gdip_ImageSearch.ahk
DebugWindow("Started FFXIV Main Menu",1,1,200,0)

global menuData := [] ; can be refactor to object with key for better verbose reading
menuData[ 1 ] := {function:"gAutoSynthesis", value:"vMainScript1", label:"Auto Synthesis", subOptionGuiType:"Checkbox", subOptionGuiStyle:"x60", subOptions:[{value:"Disabled vMainScript1_SubItem1", label:"Auto refresh food"}, {value:"Disabled vMainScript1_SubItem2", label:"Auto refresh medicine"}]}
menuData[ 2 ] := {function:"gAutoQuickSynthesis", value:"vMainScript2", label:"Auto Quick Synthesis"}
menuData[ 3 ] := {function:"gAutoGather", value:"vMainScript3", label:"Auto Gather"}
menuData[ 4 ] := {function:"gAutoFish", value:"vMainScript4", label:"Auto Fish"}
menuData[ 5 ] := {function:"gEulmore", value:"vMainScript5", label:"Auto Eulmore Turnin", subOptionGuiType:"ListBox", subOptionGuiStyle:"w350", subOptions:[]}
menuData[ 6 ] := {function:"gProfitHelper", value:"vMainScript6", label:"Profits Helper"}

assignDataIntoEulmoreSubOptions(){
	FileRead, var, items.json
	obj := JSON.load(var)
	;log(obj)
	
	for i, items in obj.items{ ;mainBox mainscript boxes
		DebugWindow("----------------------------------------------------------------------------------------------------------------------------------------------------",0,1,0,0)		
		i:=A_Index
		DebugWindow("itemID:" obj.items[i].itemID " | name:" obj.items[i].name " | description:" obj.items[i].description " | category:" obj.items[i].paths.category " | subcategory:" obj.items[i].paths.subcategory " | filename:" obj.items[i].paths.filename,0,1,0,0)
		nameWithSpace:=obj.items[i].name:=StrReplace(obj.items[i].name, "_", " ")
		;log("nameWithSpace : " + nameWithSpace)
		menuData[5].subOptions[i]:= {itemID: obj.items[i].itemID, label: nameWithSpace, description: obj.items[i].description, price: "N/A", numberOfSalesPast1Day: "N/A", numberOfSalesPast2Day: "N/A", numberOfSalesPast3Day: "N/A", value: "Disabled vMainScript5_SubItem1"}
		;log("subOptions[i].name : " + menuData[5].subOptions[i].name)
		;log("menuData[5].subOptions[i] : " +menuData[5].subOptions[i])
		
	}
}


assignDataIntoEulmoreSubOptions()
getPriceList()
Goto, ^F3
;callAPI()
^F3::
Gui, Menu:Destroy
Gui, Menu:+AlwaysOnTop
Gui, Menu:Add,Picture, x0 y0 w720 h188,gui.png
Gui, Menu:Color, 0x808080
Gui, Menu:Font, s10, Verdana
Gui, Menu:Font, bold

;populating GUI menu
for i, obj in menuData{ ;mainBox mainscript boxes
	function:=menuData[i].function
	value:=menuData[i].value
	label:=menuData[i].label
	Gui, Menu:Add, Checkbox, x25 %function% %value%, %label%
	if(function="gEulmore"){
		Gui, Menu:Add, Button, yp x+25 Disabled gPriceListWindow vPriceListWindow, Check Price List  ; todo: disabled attribute	
	}
	
	listBoxOptions:=[]
	value:=""
	label:=""
	subOptionGuiType:=""
	subOptionGuiStyle:=""
	
	for key, field in menuData[i].subOptions{ ;subBox options(parameters)
		value:=menuData[i].subOptions[key].value
		label:=menuData[i].subOptions[key].label
		subOptionGuiType:=menuData[i].subOptionGuiType
		subOptionGuiStyle:=menuData[i].subOptionGuiStyle
		if(subOptionGuiType="Checkbox"){
			Gui, Menu:Add, %subOptionGuiType%, %subOptionGuiStyle% %value%, %label%			
		} else { ; for ListBox, add outside of subLoop
			listBoxOptions[key]:=label
		}
		;DebugWindow("Array: " i "`nKey: " key "`nAnimal: " animal,0,1,200,0)
		;Gui, Add, Checkbox, x25 menuData[]i.function menuData[i].value, menuData[i].label
	}
	if(subOptionGuiType="ListBox"){
		options:=""
		for i, obj in listBoxOptions {
			;log("listBoxOptions[i] : " + listBoxOptions[i])
			options:=options . listBoxOptions[i]
			if(listBoxOptions.length()!=i){
				options:=options . "|"
			}
		}
		Gui, Menu:Add, %subOptionGuiType%, h80 %subOptionGuiStyle% %value%, %options%	; auto resize is not supported for listbox, therefore hardcoded height	
	}
}
Gui, Menu:Add, Button, gButtonOK Default, Execute  ; The label ButtonOK (if it exists) will be run when the button is pressed.
Gui, Menu:Show, w720 h600, FFXIV Menu
return

ButtonOK:
Gui, Submit
checkedBoxIndex:=getCheckedBox()
if(checkedBoxIndex="1") {
	foodRefresh:=MainScript1_SubItem1
	medicineRefresh:=MainScript1_SubItem2
	collectableFlag:=MainScript1_SubItem3
	log("foodRefresh : " + foodRefresh)
	log("medicineRefresh : " + medicineRefresh)
	
	Run autoSynthesis\autoSynthesis.ahk %foodRefresh% %medicineRefresh%
} else if(checkedBoxIndex="2") {
	Run "C:\Users\teosh\Desktop\ahk\autoQuickSynthesis\autoQuickSynthesis.ahk"
} else if(checkedBoxIndex="3") {
	Run "C:\Users\teosh\Desktop\ahk\gather\gather.ahk"
} else if(checkedBoxIndex="4") {
	Run "C:\Users\teosh\Desktop\ahk\fish\fish.ahk"
} else if(checkedBoxIndex="5") {
	selectedItem:=MainScript5_SubItem1
	selectedItem:=StrReplace(selectedItem, " ", "_") ;replace space in string for easier matching in the subscript
	Run eulmoreTurnin\eulmoreTurnin.ahk %selectedItem%
	log("selectedItem : " + selectedItem)
} else if(checkedBoxIndex="6") {
	Run "C:\Users\teosh\Desktop\ahk\profitCalculator\profitCalculator.ahk"
}
return

getCheckedBox(){
	for i in menuData{ ;mainBox mainscript boxes
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

ProfitHelper(){ ;6
	uncheckMainScriptBoxes(6)
	GuiControlGet, CheckBoxState,, MainScript6
	if(CheckBoxState=1){
		log("ProfitHelper checked")
	}
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
					if(mainScriptLoopIndex=5){ ;dirty fix for eulmore check price window
						GuiControl, Enable, PriceListWindow
					}
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
			if(mainScriptLoopIndex=5){ ;dirty fix for eulmore check price window
				GuiControl, Disabled, PriceListWindow
			}
		} 
	}
}

global response:=""
getPriceList(){
	log("getPriceList()")
	for i, subOptions in menuData[5].subOptions{
		response:=getPriceForItemApi(menuData[5].subOptions[i].itemID)
		obj := JSON.load(response)	
		getLastKnownPrice(obj)
	}
}

getLastKnownPrice(obj){
	log("getLastKnownPrice()")
	lastPrice:=""
	itemId:=""
	numberOfSales:=""
	for i, entries in obj.entries{ ;mainBox mainscript boxes
		if(i=1){
			itemID:= obj.itemID
			lastPrice:=obj.entries[i].pricePerUnit
			numberOfSales:=obj.entries.length()
		}
	}
	log("itemID " obj.itemID "'s last known price : " lastPrice " gils")
	assignKnownPriceIntoEulmoreSubOptions(itemID, lastPrice, numberOfSales)
}

assignKnownPriceIntoEulmoreSubOptions(itemID, lastPrice, numberOfSales){
	log("assignKnownPriceIntoEulmoreSubOptions()")
	for i, subOptions in menuData[5].subOptions{
		if(menuData[5].subOptions[i].itemID=itemID){
			menuData[5].subOptions[i].price:=lastPrice
			menuData[5].subOptions[i].numberOfSalesPast1Day:=numberOfSales
			break
		}
	}
}

ButtonCancel:
GuiClose:
GuiEscape:
Gui, Destroy
Return



PriceListWindow:
Gui, PriceListWindow:Default
Gui, PriceListWindow:+AlwaysOnTop
Gui, PriceListWindow:+resize
Gui, PriceListWindow:Add,Picture, x0 y0 w800 h188,gui.png
Gui, PriceListWindow:Color, 0x808080
Gui, PriceListWindow:Font, s10, Verdana
Gui, PriceListWindow:Font, bold
Gui, PriceListWindow:Add, ListView, r20 w800 gOnDoubleClick, Item ID | Item Name| Last Known Price | #Sales Past 3 Day
Gui, PriceListWindow:Add, Button, gGetMoreData, Show number of sales in the past 3 days ; will make 2 more api calls	

for i, subOptions in menuData[5].subOptions{
	log("priceListWindow menuData[5].subOptions[i].itemID : " + menuData[5].subOptions[i].itemID)
	LV_Add("", menuData[5].subOptions[i].itemID, menuData[5].subOptions[i].label, menuData[5].subOptions[i].price, menuData[5].subOptions[i].numberOfSalesPast1Day)
}

; https://www.autohotkey.com/docs/commands/ListView.htm#LV_ModifyCol for future reference
LV_ModifyCol(1,"AutoHdr")
LV_ModifyCol(2,"AutoHdr")
LV_ModifyCol(3,"AutoHdr")
LV_ModifyCol(3,"Integer")
LV_ModifyCol(3,"SortDesc") ; sort by price
LV_ModifyCol(4,"AutoHdr")

Gui, PriceListWindow:Show
return

GetMoreData:
return

; to select the listbox in the first gui window
OnDoubleClick:
if (A_GuiEvent = "DoubleClick")
{
	LV_GetText(ItemID, A_EventInfo)
	selectedItemID:=ItemID
	log("double clicked row number " %A_EventInfo% ", ItemID: " %ItemID%)
	getSelectedRow(selectedItemID)
	Gui, Destroy
}
return

getSelectedRow(selectedItemID){
	log("getSelectedRow()")
	guiIndex:=eulmoreArrayFindById(selectedItemID)
	log("guiIndex : " + guiIndex)
	highlightSelectedRow(guiIndex)
}

eulmoreArrayFindById(selectedItemID){ ; find by itemID, return the matched index in the array
	log("eulmoreArrayFind()")
	for i, subOptions in menuData[5].subOptions{
		log("selectedItemID : " + selectedItemID)
		log("menuData[5].subOptions[i].itemID : " + menuData[5].subOptions[i].itemID)
		if(menuData[5].subOptions[i].itemID=selectedItemID){
			log("found matched item i : " i)
			return i
		}
	}
}

highlightSelectedRow(guiIndex) {
	GuiControl, Menu:Choose, MainScript5_SubItem1, %guiIndex%
}
;^F4::ExitApp DebugWindow("Terminated Menu",1,1,200,0)

Pause::Pause
PostMessage, 0x111, 65306,,, autoSynthesis.ahk  ;sending pause to other running scripts, press hotkey again to resume
PostMessage, 0x111, 65306,,, autoQuickSynthesis.ahk  ;sending pause to other running scripts, press hotkey again to resume
PostMessage, 0x111, 65306,,, gather.ahk  ;sending pause to other running scripts, press hotkey again to resume
PostMessage, 0x111, 65306,,, fish.ahk  ;sending pause to other running scripts, press hotkey again to resume
PostMessage, 0x111, 65306,,, eulmoreTurnin.ahk  ;sending pause to other running scripts, press hotkey again to resume
PostMessage, 0x111, 65306,,, profitCalculator.ahk  ;sending pause to other running scripts, press hotkey again to resume

