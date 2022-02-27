#SingleInstance, Force
#Persistent
SetWorkingDir %A_ScriptDir%
#include lib\json\json.ahk
#include lib\utility\utility.ahk
#include lib\gdip\Gdip_All.ahk
#include lib\gdip\imageSearch\Gdip_ImageSearch.ahk
DebugWindow("Started FFXIV Main Menu",1,1,200,0)

global selectedTabIndex:="1"
global menuData := [] ; can be refactor to object with key for better verbose reading
menuData[ 1 ] := {function:"gAutoSynthesis", value:"vMainScript1", label:"Auto Synthesis", subOptionGuiType:"Checkbox", subOptionGuiStyle:"x60", subOptions:[{value:"Disabled vMainScript1_SubItem1", label:"Auto refresh food"}, {value:"Disabled vMainScript1_SubItem2", label:"Auto refresh medicine"}]}
menuData[ 2 ] := {function:"gAutoGather", value:"vMainScript2", label:"Auto Gather"}
menuData[ 3 ] := {function:"gAutoFish", value:"vMainScript3", label:"Auto Fish"}
menuData[ 4 ] := {function:"gEulmore", value:"vMainScript4", label:"Auto Eulmore Turnin", subOptionGuiType:"ListBox", subOptionGuiStyle:"w350", subOptions:[]}
menuData[ 5 ] := {function:"gProfitHelper", value:"vMainScript5", label:"Profit Helper"}

assignDataIntoEulmoreSubOptions(){
	FileRead, var, items.json
	obj := JSON.load(var)
	;log(obj)
	
	for i, items in obj.items{ ;mainBox mainscript boxes
		DebugWindow("----------------------------------------------------------------------------------------------------------------------------------------------------",0,1,0,0)		
		i:=A_Index
		DebugWindow("itemID:" obj.items[i].itemID " | name:" obj.items[i].name " | description:" obj.items[i].description " | category:" obj.items[i].paths.category " | subcategory:" obj.items[i].paths.subcategory " | filename:" obj.items[i].paths.filename,0,1,0,0)
		nameWithSpace:=obj.items[i].name:=StrReplace(obj.items[i].name, "_", " ")
		log("nameWithSpace : " + nameWithSpace)
		menuData[4].subOptions[i]:= {itemID: obj.items[i].itemID, label: nameWithSpace, description: obj.items[i].description, price: "N/A", numberOfSalesPast1Day: "N/A", numberOfSalesPast2Day: "N/A", numberOfSalesPast3Day: "N/A", value: "Disabled vMainScript5_SubItem1"}
		log("subOptions[i].label : " + menuData[4].subOptions[i].label)
	}
}


assignDataIntoEulmoreSubOptions()
;getPriceList()
Goto, ^F3

^F3::
Gui, Menu:Destroy
;Gui, Menu:+AlwaysOnTop
;Gui, Menu:Add,Picture, x0 y0 w720 h188,gui.png
Gui, Menu:Color, 0x808080
Gui, Menu:Font, s18, Verdana
Gui, Menu:Add, Tab2, AltSubmit vTabNum gLoadTabIndex x15 y15 h1000 w2560, Auto Synthesis  |Auto Gather |Auto Fishing  |Eulmore  |Profit Helper  
Gui, Menu:Font, s10, Verdana
Gui, Menu:Font, bold

;populating GUI menu
initialX:=40
initialY:=65

;https://www.autohotkey.com/boards/viewtopic.php?p=273253#p273253
; cant use function to draw gui because when function exits, variables are cleared, therefore, this is one big chunk of code to draw the GUI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; drawAutoSynthesis
Gui, Menu:Tab, 1 ;switching tab for Gui Add
function:=menuData[1].function
value:=menuData[1].value
label:=menuData[1].label

Gui, Menu:Add, Checkbox, x%initialX% y%initialY% %function% %value%, %label%

for key, field in menuData[1].subOptions{ ;subBox options(parameters)
	
	value:=menuData[1].subOptions[key].value
	label:=menuData[1].subOptions[key].label
	subOptionGuiType:=menuData[1].subOptionGuiType
	subOptionGuiStyle:=menuData[1].subOptionGuiStyle
	if(subOptionGuiType="Checkbox"){
		subInitialX=initialX+25
		subInitialY=initialY+25
		Gui, Menu:Tab, 1
		Gui, Menu:Add, %subOptionGuiType%, x+subInitialX y+subInitialY %subOptionGuiStyle% %value%, %label%			
	} else { ; for ListBox, add outside of subLoop
		listBoxOptions[key]:=label
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; drawAutoGather
Gui, Menu:Tab, 2 ;switching tab for Gui Add
function:=menuData[2].function
value:=menuData[2].value
label:=menuData[2].label

Gui, Menu:Add, Checkbox, x%initialX% y%initialY% %function% %value%, %label%


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; drawAutoFish
Gui, Menu:Tab, 3 ;switching tab for Gui Add
function:=menuData[3].function
value:=menuData[3].value
label:=menuData[3].label

Gui, Menu:Add, Checkbox, x%initialX% y%initialY% %function% %value%, %label%


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; drawEulmore
Gui, Menu:Tab, 4 ;switching tab for Gui Add
function:=menuData[4].function
value:=menuData[4].value
label:=menuData[4].label

Gui, Menu:Add, Checkbox, x%initialX% y%initialY% %function% %value%, %label%
Gui, Menu:Add, Button, yp x+initialX+25 Disabled gPriceListWindow vPriceListWindow, Check Price List  ; todo: disabled attribute	


listBoxOptions:=[]
log("menuData[4].subOptions[key].label : " menuData[4].subOptions[1].label)

for key, field in menuData[4].subOptions{ ;subBox options(parameters)
	value:=menuData[4].subOptions[key].value
	label:=menuData[4].subOptions[key].label
	subOptionGuiType:=menuData[4].subOptionGuiType
	subOptionGuiStyle:=menuData[4].subOptionGuiStyle
	listBoxOptions[key]:=label
}

options:=""
for i, obj in listBoxOptions {
	options:=options . listBoxOptions[i]
	if(listBoxOptions.length()!=i){
		options:=options . "|"
	}
}
Gui, Menu:Add, %subOptionGuiType%, h80 %subOptionGuiStyle% %value%, %options%	; auto resize is not supported for listbox, therefore hardcoded height	



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


Gui, Menu:Tab ; exiting tab edit
Gui, Menu:Add, Button, x15 y1020 w500 gButtonOK, Execute  ; The label ButtonOK (if it exists) will be run when the button is pressed.

Gui, Menu:Add, Text, vStatusTitle Hidden, Status
Gui, Menu:Add, Text, vStatusText Hidden w800, 0

Gui, Menu:Add, Progress, w450 h20 cGreen vMyProgress Hidden, 75

Gui, Menu:Show, w2560 h1440, FFXIV Menu
Gui, Menu:+Resize
Gui, Menu:Show, Maximize
return


LoadTabIndex:
Gui, Menu:Submit, NoHide
selectedTabIndex:=TabNum
return

MenuButtonCancel:
MenuGuiClose:
MenuGuiEscape:
Gui, Menu:Destroy
ExitApp

ButtonOK:
Gui, Submit, NoHide ;retrieve control values

GuiControl, Show, StatusTitle
GuiControl, Show, StatusText
GuiControl, Show, MyProgress

if(selectedTabIndex="1") {
	updateStatusText("autoSynthesis")
	foodRefresh:=MainScript1_SubItem1
	medicineRefresh:=MainScript1_SubItem2
	collectableFlag:=MainScript1_SubItem3
	log("foodRefresh : " + foodRefresh)
	log("medicineRefresh : " + medicineRefresh)
	Run autoSynthesis\autoSynthesis.ahk %foodRefresh% %medicineRefresh%
} else if(selectedTabIndex="2") {
	updateStatusText("gather")
	Run "C:\Users\teosh\Desktop\ahk\gather\gather.ahk"
} else if(selectedTabIndex="3") {
	updateStatusText("fish")
	Run "C:\Users\teosh\Desktop\ahk\fish\fish.ahk"
} else if(selectedTabIndex="4") {
	updateStatusText("eulmoreTurnin")
	selectedItem:=MainScript5_SubItem1
	selectedItem:=StrReplace(selectedItem, " ", "_") ;replace space in string for easier matching in the subscript
	Run eulmoreTurnin\eulmoreTurnin.ahk %selectedItem%
	log("selectedItem : " + selectedItem)
} else if(selectedTabIndex="5") {
	updateStatusText("profitHelper")
	Run "C:\Users\teosh\Desktop\ahk\profitHelper\profitHelper.ahk"
}
return

updateStatusText(scriptName) {
	log("scriptName : " + scriptName)
	GuiControl,,StatusText, Currently running %scriptname%.ahk
}
getCheckedBox(){
	/*
		for i in menuData{ ;mainBox mainscript boxes
			GuiControlGet, CheckBoxState,, MainScript%A_Index%
			if(CheckBoxState=1){
				return %A_Index%
			}
		}
	*/
	Gui, Menu:submit, nohide
	log("TabNum : " + TabNum)
	log("%TabNum% : " + %TabNum%)
	Msgbox %TabNum%
	
	return %TabNum%
}

;hardcoded because g-label doesnt support parameter passing
AutoSynthesis(){ ;1
	uncheckMainScriptBoxes(1)
}

AutoGather(){ ;2
	uncheckMainScriptBoxes(2)
}

AutoFish(){ ;3
	uncheckMainScriptBoxes(3)
}

Eulmore(){ ;4
	uncheckMainScriptBoxes(4)
}

ProfitHelper(){ ;5
	uncheckMainScriptBoxes(5)
	GuiControlGet, CheckBoxState,, MainScript6
	if(CheckBoxState=1){
		log("ProfitHelper checked")
	}
}

; UIUX enhancement
uncheckMainScriptBoxes(selectedIndex){
	log("uncheckMainScriptBoxes())")
	for i, obj in menuData {
		mainScriptLoopIndex := i
		GuiControlGet, CheckBoxState,, MainScript%mainScriptLoopIndex%
		If (mainScriptLoopIndex = selectedIndex) ;to enable the disabled fields for the matched mainBox(ScriptBoxes)
		{ 
			for key, field in menuData[i].subOptions{ ;looping sub boxes
				
				If (CheckBoxState = 1)
				{ 
					if(mainScriptLoopIndex=4){ ;dirty fix for eulmore check price window
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
		
		If (mainScriptLoopIndex != selectedIndex) ;to uncheck other mainBoxes
		{ 
			GuiControl,, MainScript%A_Index%, 0
			for key, field in menuData[i].subOptions{ ;to uncheck and disable other subBoxes
				GuiControl, Disabled, MainScript%mainScriptLoopIndex%_SubItem%A_Index%
				if(menuData[i].subOptionGuiType="Checkbox"){
					GuiControl,, MainScript%mainScriptLoopIndex%_SubItem%A_Index%, 0 ;to uncheck other subBoxes when clicking other mainBox away from current selected mainBox				
				} else { ; deselect item from selected items in List
					GuiControl, Choose, MainScript%mainScriptLoopIndex%_SubItem%A_Index%, 0
				}
			}
			if(mainScriptLoopIndex=4){ ;dirty fix for eulmore check price window
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

