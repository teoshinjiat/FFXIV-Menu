SetWorkingDir %A_ScriptDir%
#include ..\..\lib\json\json.ahk
#include ..\utility\utility.ahk

WinGet, GameID, ID, ahk_class FFXIVGAME
#NoTrayIcon
#Persistent
#NoEnv
#SingleInstance, Force
SetMouseDelay, 5
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
;("done crafting",Clear:=1,LineBreak:=1,Sleep:=500,0)
log("Eulmore Turnin", clear:=1)

for n, param in A_Args  ; For each parameter:
{
	DebugWindow("Parameter number " %n%  " is " %param% ,0,1,0,0)
}

;global selectedItem:=%param%
global selectedItem:="Craftsmans_Command_Materia_X"
global matchedItemIndex:=""
global paths_category:=""
global paths_subcategory:=""
global paths_filename:=""

/*
	DebugWindow("selectedItem: "selectedItem,0,1,200,0)
	MsgBox The value in the variable named Var is %1%. 
	DebugWindow("%1%: "%1%,0,1,0,0)
	DebugWindow("selectedItem: "selectedItem,0,1,0,0)
*/

readItems()
;Loop {
	;handleCollectableAppraiser() ;turn in items
handleExchangeNPC() ;buy items
sleep, 1000
;}


handleCollectableAppraiser(){
	sleep, 1000
	ControlSend, , {e}, ahk_class FFXIVGAME
	sleep, 1000
	ControlSend, , ``, ahk_class FFXIVGAME
	sleep, 1000
	handInItems()
}

handleExchangeNPC(){
	DebugWindow("handleExchangeNPC()",0,1,0,0)	
	ControlSend, , {q}, ahk_class FFXIVGAME
	sleep, 500
	ControlSend, , ``, ahk_class FFXIVGAME
	sleep, 1000
	exchange()
}

exchange(){
	DebugWindow("exchange()",0,1,0,0)	
	;global paths_category:=""
	;global paths_subcategory:=""
	;global paths_filename:=""
	SetKeyDelay, 300
	windowCheck()
	handleCategory()
	handleSubCategory()
	buyItem()
}

windowCheck(){ ;looping to ensure window is indeed opened
	item_exchange_window:=""
	While (item_exchange_window!=0){
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, images\window\item_exchange_window.png
		item_exchange_window:=ErrorLevel
	}
}

handleCategory(){
	log("handleCategory()")
	log("paths_category : " paths_category)
	if(paths_category="crafters_scrip_materia"){
		ControlSend, , {Up}, ahk_class FFXIVGAME
		ControlSend, , {Up}, ahk_class FFXIVGAME
		ControlSend, , ``, ahk_class FFXIVGAME ;category is opened
		processCategory()
	}
}

processCategory(){
	categoryHighlighted:=""
	while(categoryHighlighted!=0){
		ControlSend, , {Down}, ahk_class FFXIVGAME		
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, images\category\%paths_category%.png
		categoryHighlighted:=ErrorLevel
		if(categoryHighlighted=0){
			ControlSend, , ``, ahk_class FFXIVGAME ;category is opened
			break ;selected category, handleSubCategory next
		}
	}
}

handleSubCategory(){
	ControlSend, , {Down}, ahk_class FFXIVGAME
	ControlSend, , ``, ahk_class FFXIVGAME ;subCategory is opened
	processSubCategory()
}

processSubCategory(){
	subCategoryHighlighted:=""
	while(subCategoryHighlighted!=0){
		ControlSend, , {Down}, ahk_class FFXIVGAME		
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, images\subcategory\%paths_subcategory%.png
		subCategoryHighlighted:=ErrorLevel
		if(subCategoryHighlighted=0){
			ControlSend, , ``, ahk_class FFXIVGAME ;category is opened
			break ;selected category, handleSubCategory next
		}
	}
}

buyItem(){
	itemHighlighted:=""
	while(itemHighlighted!=0){
		ControlSend, , {Down}, ahk_class FFXIVGAME		
		Run images\item\%paths_filename%.png
		
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, images\item\%paths_filename%.png
		sleep, 1000
		itemHighlighted:=ErrorLevel
		if(itemHighlighted=0){
			log("Coordinates found at x:" %x% ", y:" %y%)
		} else if(itemHighlighted=1){
			log("Not found")
		} else {
			log("Could not conduct search")	
		}
		if(itemHighlighted=0){
			ControlSend, , ``, ahk_class FFXIVGAME ;category is opened
			break ;selected category, handleSubCategory next
		}
	}
}

handInItems(){
	DebugWindow("handInItems()",0,1,200,0)
	ErrorLevel:=""
	While (tradeButtonErrorLevel!=0)
	{
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, images\button\trade.png
		tradeButtonErrorLevel:=ErrorLevel
		if(tradeButtonErrorLevel=0){
			ControlSend, , {Right}, ahk_class FFXIVGAME
			ControlSend, , {Right}, ahk_class FFXIVGAME			
			ControlSend, , ``, ahk_class FFXIVGAME
			ControlSend, , ``, ahk_class FFXIVGAME			
			Loop {
				ControlSend, , ``, ahk_class FFXIVGAME
				sleep, 200													
				
				imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, images\dialogue\scrips_full.png
				if(ErrorLevel=0){
					ControlSend, , {Esc}, ahk_class FFXIVGAME
					sleep, 100					
					ControlSend, , {Esc}, ahk_class FFXIVGAME
					Goto, ContinueHere
					return
				}
				sleep, 500
			}
		}
	}
	ContinueHere:
	sleep, 200
	sleep, 1500
}


readItems(){
	FileRead, var, ..\items.json
	obj := JSON.load(var)
	
	for i, items in obj.items{ ;mainBox mainscript boxes
		DebugWindow("----------------------------------------------------------------------------------------------------------------------------------------------------",0,1,0,0)		
		i:=A_Index
		DebugWindow("id:" obj.items[i].id " | name:" obj.items[i].name " | description:" obj.items[i].description " | category:" obj.items[i].paths.category " | subcategory:" obj.items[i].paths.subcategory " | filename:" obj.items[i].paths.filename,0,1,0,0)
		
		if(selectedItem=obj.items[i].name){
			setPaths(obj.items[i])
			break ;if found item, skip the rest of the search
		}
	}
}

setPaths(obj){
	paths_category:=obj.paths.category
	paths_subcategory:=obj.paths.subcategory
	paths_filename:=obj.paths.filename
	log("paths_category : " + paths_category)
	log("paths_subcategory : " + paths_subcategory)
	log("paths_filename : " + paths_filename)
}
^F4::ExitApp DebugWindow("All scripts terminated...",0,1,200,0)

/*
	
	
	
	
	
	handleCollectableAppraiser(){
		sleep, 1000
		ControlSend, , {e}, ahk_class FFXIVGAME
		sleep, 1000
		ControlSend, , ``, ahk_class FFXIVGAME
		sleep, 1000
		turnIn()
	}
	
	turnIn(){
		DebugWindow("turnIn()",0,1,200,0)
		
		ErrorLevel:=""
		While (tradeButtonErrorLevel!=0)
		{
			imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, %A_ScriptDir%\trade.png
			tradeButtonErrorLevel:=ErrorLevel
			if(tradeButtonErrorLevel=0){
				ControlSend, , {Right}, ahk_class FFXIVGAME
				ControlSend, , {Right}, ahk_class FFXIVGAME			
				ControlSend, , ``, ahk_class FFXIVGAME
				ControlSend, , ``, ahk_class FFXIVGAME			
				Loop {
					ControlSend, , ``, ahk_class FFXIVGAME
					sleep, 200													
					
					imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, %A_ScriptDir%\purple_scrips_full.png
					if(ErrorLevel=0){
						ControlSend, , {Esc}, ahk_class FFXIVGAME
						sleep, 100					
						ControlSend, , {Esc}, ahk_class FFXIVGAME
						Goto, ContinueHere
						return
					}
					sleep, 500
				}
			}
		}
		
		ContinueHere:
		sleep, 200
		sleep, 1500
		handleExchange()
	}
	
	
	