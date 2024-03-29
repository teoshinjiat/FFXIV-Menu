﻿#SingleInstance, Force
#Persistent
SetWorkingDir %A_ScriptDir%
#include lib\json\json.ahk
#include lib\utility\utility.ahk
#include lib\utility\CLogTailer.ahk
#include lib\gdip\Gdip_All.ahk
#include lib\gdip\imageSearch\Gdip_ImageSearch.ahk
#include lib\constants\chat.ahk
#include lib\Class_LV_Colors\Class_LV_Colors.ahk
DebugWindow("Started FFXIV Main Menu",1,1,200,0)

global DND:=false ;this is a flag to prevent the log from disturbing me when im developing other script, used in logging function
global selectedTabIndex:=1
global selectedLogTabIndex:=1
global logFilePath:="C:\ahk\FFXIV\ffxiv.log"
global currentLineNumber:=""
global previousFileSize:=0
global lineArray:=[]
global verbose:="(Verbose)"
global error:="(Error)"
global debug:="(Debug)"
global menuData := [] ; can be refactor to object with key for better verbose reading
global log := {verbose:[], error:[], debug:[]}
menuData[ 1 ] := {function:"gAutoSynthesis", value:"vMainScript1", label:"Auto Synthesis", subOptionGuiType:"Checkbox", subOptionGuiStyle:"x60", subOptions:[{value:"vMainScript1_SubItem1", label:"Auto refresh food"}, {value:"vMainScript1_SubItem2", label:"Auto refresh medicine"}]}
menuData[ 2 ] := {function:"gAutoGather", value:"vMainScript2", label:"Auto Gather"}
menuData[ 3 ] := {function:"gAutoFish", value:"vMainScript3", label:"Auto Fish"}
menuData[ 4 ] := {function:"gEulmore", value:"vMainScript4", label:"Auto Eulmore Turnin", subOptionGuiType:"ListBox", subOptionGuiStyle:"w350", subOptions:[]}
menuData[ 5 ] := {function:"gProfitHelper", value:"vMainScript5", label:"Profit Helper"}


assignDataIntoEulmoreSubOptions() ; should be loaded only when sub tab is active to remove redundant load time
getPriceList() ; should be loaded only when sub tab is active to remove redundant load time
Goto, ^F3


^F3::
selectedTabIndex:=1
Gui, Menu:Destroy
;Gui, Menu:+AlwaysOnTop
;Gui, Menu:Add,Picture, x0 y0 w720 h188,gui.png
Gui, Menu:Color, 0x808080
guiH1Font("Menu")
guiItalic("Menu")
Gui, Menu:Add, Tab2, AltSubmit vTabNum gLoadTabIndex x15 y15 h500 w2500, Auto Synthesis  |Auto Gather |Auto Fishing  |Eulmore  | Tools



;https://www.autohotkey.com/boards/viewtopic.php?p=273253#p273253
; cant use function to draw gui because when function exits, variables are cleared, therefore, this is one big chunk of code to draw the GUI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; drawAutoSynthesis
guiH4Font("Menu")
guiBold("Menu")

guiUnderline("Menu")
Gui, Menu:Add, Text, x50 y70, Options
guiNormal("Menu") ; remove underline

guiH5Font("Menu")
guiBold("Menu")
Gui, Menu:Tab, 1 ;switching tab for Gui Add
function:=menuData[1].function
value:=menuData[1].value
label:=menuData[1].label

;populating GUI menu
initialX:=50
initialY:=70

for key, field in menuData[1].subOptions{ ;subBox options(parameters)
	index:=A_Index
	; reuse the same initial x,y for sub options
	subInitialY:=initialY
	
	value:=menuData[1].subOptions[key].value
	label:=menuData[1].subOptions[key].label
	subOptionGuiType:=menuData[1].subOptionGuiType
	subOptionGuiStyle:=menuData[1].subOptionGuiStyle
	subInitialY:=subInitialY+(index*20)
	Gui, Menu:Add, %subOptionGuiType%, x%initialX% y%subInitialY% %subOptionGuiStyle% %value%, %label%			
	
	/*
		legacy!
		if(subOptionGuiType="Checkbox"){
			Gui, Menu:Tab, 1
			Gui, Menu:Add, %subOptionGuiType%, x%initialX% y+%subInitialY% %subOptionGuiStyle% %value%, %label%			
		} else { ; for ListBox, add outside of subLoop
			listBoxOptions[key]:=label
		}
	*/
}

Gui, Menu:Add, text, xp+20 yp+20, Craft Count (0 as infinite) ; 0 or empty field by accident or anything that is not positive integer will indicate as infinite craft
Gui, Menu:Add, Edit, xp+20 yp+20 w200 Number
Gui, Menu:Add, UpDown, xp+50 yp+20 vCraftCount Range0-6, 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; drawAutoGather
Gui, Menu:Tab, 2 ;switching tab for Gui Add
function:=menuData[2].function
value:=menuData[2].value
label:=menuData[2].label
guiH4Font("Menu")
guiBold("Menu")
guiNormal("Menu")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; drawAutoFish
Gui, Menu:Tab, 3 ;switching tab for Gui Add
function:=menuData[3].function
value:=menuData[3].value
label:=menuData[3].label

guiH4Font("Menu")
guiBold("Menu")
guiNormal("Menu")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; drawEulmore
Gui, Menu:Tab, 4 ;switching tab for Gui Add
function:=menuData[4].function
value:=menuData[4].value
label:=menuData[4].label

subInitialX:=initialX
subInitialY:=initialY

guiH5Font("Menu")
guiBold("Menu")
;Gui, Menu:Add, Checkbox, x%initialX% y%initialY% %function% %value%, %label%
Gui, Menu:Add, Button, x%initialX% y%initialY% gPriceListWindow vPriceListWindow, Check Price List  ; todo: disabled attribute	


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
Gui, Menu:Add, %subOptionGuiType%, h100 %subOptionGuiStyle% %value%, %options%	; auto resize is not supported for listbox, therefore hardcoded height. h20 is per row	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; drawTools
Gui, Menu:Tab, 5 ;switching tab for Gui Add

Gui, Menu:Add, Button, x40 y65 w400 gDrawDatabaseManagement, Database Management  ; todo: disabled attribute	
Gui, Menu:Add, Button, xp yp+40 w400 gDrawProfitHelper, Profit Helper  ; todo: disabled attribute	



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Gui, Menu:Tab ; exiting tab edit
Gui, Menu:Add, Button, x18 y462 w300 h50 gButtonOK, Execute  ; The label ButtonOK (if it exists) will be run when the button is pressed.
Gui, Menu:Add, Checkbox, x320 y480 w300 vLoggingTogglingFlag gToggleLogging, Toggle Logging  ; The label ButtonOK (if it exists) will be run when the button is pressed.
;Gui, Menu:Add, Text, x18 y470 vStatusTitle Hidden, Status
Gui, Menu:Add, Text, x18 y520 vStatusTitle, Status :
Gui, Menu:Add, Text, xp+60 y520 vStatusText w800, Idling
;Gui, Menu:Add, Progress, x150 y500 w450 h20 cGreen vMyProgress Hidden, 75
;Gui, Menu:Add, Progress, x150 y500 w450 h20 cGreen vMyProgress Hidden, 75


Gui, Menu:Add, Tab2, AltSubmit vLogNum gLoadLogTabIndex x15 y550 h800 w2500, Verbose  |Debug |Error  

Gui, Menu:Tab, Verbose
Gui, Menu:Add, ListView, y580 xp h750 w2500 vLogVerbose gDisableListViewFocus LVS_REPORT, Timestamp        | Type         | Log |
Gui, Menu:Tab, Debug
Gui, Menu:Add, ListView, yp xp w2500 h750 vLogDebug gDisableListViewFocus, Timestamp           | Type         | Log
Gui, Menu:Tab, Error
Gui, Menu:Add, ListView, yp xp w2500 h750 vLogError gDisableListViewFocus, Timestamp           | Type         | Log

Gui, Menu:Show, w2560 h1440, FFXIV Menu
Gui, Menu:+Resize
Gui, Menu:Show, Maximize

return


DisableListViewFocus:
LV_Modify(A_EventInfo, "-Focus -Select") ;index of the selected row
Return

ToggleLogging:
GuiControlGet, LogState,, LoggingTogglingFlag
log("LogState LogStateLogStateLogStateLogState : " + LogState)
if(LogState=1){
	loadInitialLog()
	previousFileSize:=getCurrentLogFileSize() ; initialize the log file size
	log("LogState is checked")
	SetTimer, LoggingTask, 500 ; loop to get new logs, this is a workaround because multithreading does not support AHK_L
} else {
	; clear log
}

DrawProfitHelper:
log("drawProfitHelper()")

DrawDatabaseManagement:
log("drawDatabaseManagement()")

LoadTabIndex:
log("LoadTabIndex:")
Gui, Menu:Submit, NoHide
selectedTabIndex:=TabNum
log("selectedTabIndex : " + selectedTabIndex)
return

LoadLogTabIndex:
log("LoadLogTabIndex:")
Gui, Menu:Submit, NoHide
selectedLogTabIndex:=LogNum
log("selectedLogTabIndex : " + selectedLogTabIndex)
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

if(selectedTabIndex=1) { 
	updateStatusText("autoSynthesis")
	craftCount:=CraftCount
	foodRefresh:=MainScript1_SubItem1
	medicineRefresh:=MainScript1_SubItem2
	
	log("craftCount : " + craftCount)
	log("foodRefresh : " + foodRefresh)
	log("medicineRefresh : " + medicineRefresh)
	
	Run autoSynthesis\autoSynthesis.ahk %craftCount% %foodRefresh% %medicineRefresh% 
} else if(selectedTabIndex=2) {
	updateStatusText("gather")
	Run "C:\Users\teosh\Desktop\ahk\gather\gather.ahk"
} else if(selectedTabIndex=3) {
	updateStatusText("fish")
	Run "C:\Users\teosh\Desktop\ahk\fish\fish.ahk"
} else if(selectedTabIndex=4) {
	updateStatusText("eulmoreTurnin")
	selectedItem:=MainScript5_SubItem1
	selectedItem:=StrReplace(selectedItem, " ", "_") ;replace space in string for easier matching in the subscript
	Run eulmoreTurnin\eulmoreTurnin.ahk %selectedItem%
	log("selectedItem : " + selectedItem)
} else if(selectedTabIndex=5) {
	updateStatusText("profitHelper")
	Run "C:\Users\teosh\Desktop\ahk\profitHelper\profitHelper.ahk"
}
return

assignDataIntoEulmoreSubOptions(){
	FileRead, var, items.json
	obj := JSON.load(var)
	;log(obj)
	
	for i, items in obj.items{ ;mainBox mainscript boxes
		DebugWindow("----------------------------------------------------------------------------------------------------------------------------------------------------",0,1,0,0)		
		i:=A_Index
		DebugWindow("itemID:" obj.itLoggingTaskems[i].itemID " | name:" obj.items[i].name " | description:" obj.items[i].description " | category:" obj.items[i].paths.category " | subcategory:" obj.items[i].paths.subcategory " | filename:" obj.items[i].paths.filename,0,1,0,0)
		nameWithSpace:=obj.items[i].name:=StrReplace(obj.items[i].name, "_", " ")
		log("nameWithSpace : " + nameWithSpace)
		menuData[4].subOptions[i]:= {itemID: obj.items[i].itemID, label: nameWithSpace, description: obj.items[i].description, price: "N/A", numberOfSalesPast1Day: "N/A", numberOfSalesPast2Day: "N/A", numberOfSalesPast3Day: "N/A", value: "vMainScript5_SubItem1"}
		log("subOptions[i].label : " + menuData[4].subOptions[i].label)
	}
}

updateStatusText(scriptName) {
	GuiControl,,StatusText, Currently running %scriptname%.ahk
}

;hardcoded because g-label doesnt support parameter passing
; g-label functions start with capital letters
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

; UX enhancement, to deselect other tab's checkboxes when navigating away from current tab
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
	for i, subOptions in menuData[4].subOptions{
		lastKnownPrice:=getFirstListingPriceForHQItemFromRavana(menuData[4].subOptions[i].itemID, false)
		numberOfSales:=getNumberOfSalesForItemFromRavana(menuData[4].subOptions[i].itemID) ; TODO, get number of sales
		log("lastKnownPrice : " + lastKnownPrice)
		
		log("numberOfSales : " + numberOfSales)
		assignKnownPriceIntoEulmoreSubOptions(menuData[4].subOptions[i].itemID, lastKnownPrice, numberOfSales)
	}
}

getLastKnownPrice(obj){
	log("getLastKnownPrice()")
	log("itemID " obj.itemID "'s last known price : " lastPrice " gils")
}

assignKnownPriceIntoEulmoreSubOptions(itemID, lastPrice, numberOfSales){
	log("assignKnownPriceIntoEulmoreSubOptions()")
	for i, subOptions in menuData[4].subOptions{
		if(menuData[4].subOptions[i].itemID=itemID){
			menuData[4].subOptions[i].price:=lastPrice
			menuData[4].subOptions[i].numberOfSalesPast1Day:=numberOfSales
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

for i, subOptions in menuData[4].subOptions{
	log("priceListWindow menuData[5].subOptions[i].itemID : " + menuData[4].subOptions[i].itemID)
	LV_Add("", menuData[4].subOptions[i].itemID, menuData[4].subOptions[i].label, menuData[4].subOptions[i].price, menuData[4].subOptions[i].numberOfSalesPast1Day)
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
	guiIndex:=eulmoreArrayFindById(selectedItemID)
	highlightSelectedRow(guiIndex)
}

eulmoreArrayFindById(selectedItemID){ ; find by itemID, return the matched index in the array
	for i, subOptions in menuData[4].subOptions{
		log("selectedItemID : " + selectedItemID)
		log("menuData[4].subOptions[i].itemID : " + menuData[4].subOptions[i].itemID)
		if(menuData[4].subOptions[i].itemID=selectedItemID){
			log("found matched item i : " i)
			return i
		}
	}
}

highlightSelectedRow(guiIndex) {
	GuiControl, Menu:Choose, MainScript5_SubItem1, %guiIndex%
}

LoggingTask:
detectNewLogs()
return

detectNewLogs() {
	currentFileSize:=getCurrentLogFileSize()
	if(previousFileSize < currentFileSize){
		lineArray:=[]
		previousFileSize:=currentFileSize
		loadNewLogs()
	}
}

getCurrentLogFileSize(){
	FileGetSize, currentFileSize, %logFilePath%	
	return currentFileSize
}

loadInitialLog(){
	FileRead, fileContent, %logFilePath%
	lines := StrSplit(fileContent, "`r`n")
	processLines(lines)
}

loadNewLogs(){
	Loop
	{  
		FileReadLine, fileContent, %logFilePath%, %currentLineNumber%
		if(ErrorLevel){
			break
		} else { 
			;MsgBox, % fileContent
			line:=fileContent
			lineArray.push(line)
		}
		currentLineNumber++
	}
	processLines(lineArray)
}

processLines(lines){
	for i in lines{
		haystack:=lines[i]
		obj:=splitLogByColumn(lines[i])
		updateGuiLog(obj)
		log.verbose.push(obj)
	}
	currentLineNumber:= log.verbose.length() + log.error.length() + log.error.length() ; will be used in index file read for res	uming at new changes
	;log("currentLineNumber : " +currentLineNumber)
}

splitLogByColumn(log){
	logArray:=StrSplit(log, "|",,3) ;only split by 3 times, because log message might contain a delimiter
	return {logTimestamp:logArray[1], logType:logArray[2], logMessage:logArray[3]}
}

updateGuiLog(obj){
	Gui, Menu:Default
	if(obj.logType=verbose){
		Gui, Menu:ListView, LogVerbose
		LV_Add("", obj.logTimestamp, obj.logType, obj.logMessage) 
		LV_Modify(LV_GetCount(), "Vis") ; https://www.autohotkey.com/docs/commands/ListView.htm#LV_Modify auto scroll to bottom
	}
}



;^F4::ExitApp DebugWindow("Terminated Menu",1,1,200,0)

Pause::Pause
PostMessage, 0x111, 65306,,, autoSynthesis.ahk  ;sending pause to other running scripts, press hotkey again to resume
PostMessage, 0x111, 65306,,, autoQuickSynthesis.ahk  ;sending pause to other running scripts, press hotkey again to resume
PostMessage, 0x111, 65306,,, gather.ahk  ;sending pause to other running scripts, press hotkey again to resume
PostMessage, 0x111, 65306,,, fish.ahk  ;sending pause to other running scripts, press hotkey again to resume
PostMessage, 0x111, 65306,,, eulmoreTurnin.ahk  ;sending pause to other running scripts, press hotkey again to resume
PostMessage, 0x111, 65306,,, profitCalculator.ahk  ;sending pause to other running scripts, press hotkey again to resume

