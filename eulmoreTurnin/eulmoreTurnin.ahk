SetWorkingDir %A_ScriptDir%
#include lib\json\json.ahk
#include lib\utility\utility.ahk
#include lib\gdip\Gdip_All.ahk
#include lib\gdip\imageSearch\Gdip_ImageSearch.ahk

WinGet, GameID, ID, ahk_class FFXIVGAME
#NoEnv
#SingleInstance, Force
SetMouseDelay, 5
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
log("Eulmore Turnin", clear:=1)

global GameID:=GameID
global selectedItem:=A_Args[1]
global matchedItemIndex:=""
global paths_category:=""
global paths_subcategory:=""
global paths_filename:=""

log("selectedItem: " selectedItem)


readItems()
Loop {
	SetKeyDelay, 8
	handleCollectableAppraiser() ;turn in items
	SetKeyDelay, 300
	handleExchangeNPC() ;buy items
	sleep, 1000
	ControlSend, , {Esc}, ahk_class FFXIVGAME
	sleep, 1000
}

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
	windowCheck()
	handleCategory()
	handleSubCategory()
	buyItem()
}

windowCheck(){ ;looping to ensure window is indeed opened
	item_exchange_window:=""
	log("windowChecwindowCheck()")
	
	While (item_exchange_window!=0){
		imageSearch, x, y, 0, 0, 2560, 1440, *1, *TransBlack, images\window\item_exchange_window.png
		item_exchange_window:=ErrorLevel
		log("searching for window")
	}
	log("window found..")
}

handleCategory(){
	log("handleCategory()")
	log("paths_category : " paths_category)
	if(paths_category="crafters_scrip_materia"){
		sleep, 2000
		ControlSend, , {Up}, ahk_class FFXIVGAME
		ControlSend, , {Up}, ahk_class FFXIVGAME
		
		ControlSend, , {Up}, ahk_class FFXIVGAME
		ControlSend, , ``, ahk_class FFXIVGAME ;category is opened
		processCategory()
	}
}

processCategory(){
	log("processCategory()")
	
	categoryHighlighted:=""
	while(categoryHighlighted!=0){
		ControlSend, , {Down}, ahk_class FFXIVGAME		
		imageSearch, x, y, 0, 0, 2560, 1440, *1, *TransBlack, images\category\%paths_category%.png
		categoryHighlighted:=ErrorLevel
		log("subCategoryHighlighted ErrorLevel :" subCategoryHighlighted)
		
		if(categoryHighlighted=0){
			log("categoryHighlighted : found")
			ControlSend, , ``, ahk_class FFXIVGAME ;category is opened
			break ;selected category, handleSubCategory next
		}
	}
}

handleSubCategory(){
	log("handleSubCategory()")
	
	ControlSend, , {Down}, ahk_class FFXIVGAME
	ControlSend, , ``, ahk_class FFXIVGAME ;subCategory is opened
	processSubCategory()
}

processSubCategory(){
	log("processSubCategory()")
	
	subCategoryHighlighted:=""
	while(subCategoryHighlighted!=0){
		ControlSend, , {Down}, ahk_class FFXIVGAME		
		imageSearch, x, y, 0, 0, 2560, 1440, *1, *TransBlack, images\subcategory\%paths_subcategory%.png
		
		subCategoryHighlighted:=ErrorLevel
		log("subCategoryHighlighted filename: " paths_subcategory ".png")		
		log("subCategoryHighlighted ErrorLevel: " subCategoryHighlighted)
		
		if(subCategoryHighlighted=0){
			log("subCategoryHighlighted: found")
			ControlSend, , ``, ahk_class FFXIVGAME ;category is opened
			break ;selected category, handleSubCategory next
		}
	}
}

buyItem(){
	log("buyItem()")
	
	itemHighlighted:=""
	while(itemHighlighted!=0){
		ControlSend, , {Down}, ahk_class FFXIVGAME	
		imageSearch, x, y, 0, 0, 2560, 1440, *1 images\item\%paths_filename%.png
		itemHighlighted:=ErrorLevel
		if(itemHighlighted=0){
			setMaxQuantity()
			confirm()
			break ;selected category, handleSubCategory next
		}
	}
}

setMaxQuantity(){
	log("setQuantity()")
	ControlSend, , {Right}, ahk_class FFXIVGAME	
	ControlSend, , {Insert}, ahk_class FFXIVGAME	
	ControlSend, , {Left}, ahk_class FFXIVGAME		
}

confirm(){
	log("confirm()")	
	ControlSend, , ``, ahk_class FFXIVGAME	
	ControlSend, , {Left}, ahk_class FFXIVGAME	
	ControlSend, , ``, ahk_class FFXIVGAME		
}

handInItems(){
	DebugWindow("handInItems()",0,1,200,0)
	ErrorLevel:=""
	While (tradeButtonErrorLevel!=0)
	{
		imageSearch, x, y, 0, 0, 2560, 1440, *1, *TransBlack, images\window\run_out_of_items.png
		itemMissing:=ErrorLevel
		if(itemMissing=0){
			log("Ran out of items to trade. Terminating script.")
			ExitApp
		}
		
		imageSearch, x, y, 0, 0, 2560, 1440, *1, *TransBlack, images\button\trade.png
		tradeButtonErrorLevel:=ErrorLevel
		if(tradeButtonErrorLevel=0){
			ControlSend, , {Right}, ahk_class FFXIVGAME
			ControlSend, , {Right}, ahk_class FFXIVGAME			
			ControlSend, , ``, ahk_class FFXIVGAME
			ControlSend, , ``, ahk_class FFXIVGAME			
			Loop {
				ControlSend, , ``, ahk_class FFXIVGAME
				sleep, 200													
				
				imageSearch, x, y, 0, 0, 2560, 1440, *1, *TransBlack, images\dialogue\scrips_full.png
				if(ErrorLevel=0){
					DebugWindow("scrips full",0,1,200,0)
					
					ControlSend, , {Esc}, ahk_class FFXIVGAME
					sleep, 100					
					ControlSend, , {Esc}, ahk_class FFXIVGAME
					Goto, ContinueHere
					return
				}
				
				imageSearch, x, y, 0, 0, 2560, 1440, *1, *TransBlack, images\button\trade_disabled.png
				if(ErrorLevel=0){	
					DebugWindow("no more item to trade", 0,1,200,0)
					
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
		
		log("matching")		
		if(selectedItem=obj.items[i].name){
			log("matched...")
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

^F4::ExitApp DebugWindow("Terminated EulmoreTurnin",0,1,200,0)
