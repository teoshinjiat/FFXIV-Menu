SetWorkingDir %A_ScriptDir%
#include ..\..\lib\json\json.ahk

WinGet, GameID, ID, ahk_class FFXIVGAME
#NoTrayIcon
#Persistent
#NoEnv
#SingleInstance, Force
SetMouseDelay, 5
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
;("done crafting",Clear:=1,LineBreak:=1,Sleep:=500,0)
DebugWindow("Started Eulmore Turnin, no keys required to activate...",0,1,200,0)

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
Loop {
	DebugWindow("Start hand in",0,1,200,0)
	handleCollectableAppraiser() ;turn in items
	handleExchange() ;buy items
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

handleExchange(){
	ControlSend, , {q}, ahk_class FFXIVGAME
	sleep, 500
	ControlSend, , ``, ahk_class FFXIVGAME
	sleep, 1000
	exchange()
}

handInItems(){
	DebugWindow("handInItems()",0,1,200,0)
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
}


readItems(){
	FileRead, var, ..\items.json
	obj := JSON.load(var)
	
	for i, items in obj.items{ ;mainBox mainscript boxes
		DebugWindow("----------------------------------------------------------------------------------------------------------------------------------------------------",0,1,0,0)		
		i:=A_Index
		DebugWindow("id:" obj.items[i].id " | name:" obj.items[i].name " | description:" obj.items[i].description " | category:" obj.items[i].paths.category " | subcategory:" obj.items[i].paths.subcategory " | filename:" obj.items[i].paths.filename,0,1,0,0)
		
		if(selectedItem=obj.items[i].name){
			setPaths(i)
			break ;if found item, skip the rest of the search
		}
	}
}

setPaths(i){
	paths_category:=obj.items[i].paths.category
	paths_subcategory:=obj.items[i].paths.subcategory
	paths_filename:=obj.items[i].paths.filename
}

/*

	
	
	exchange(){
		ErrorLevel:=""
		While (ErrorLevel!=0)
		{
			imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, %A_ScriptDir%\scripExchange_materia.png
		}
		if(ErrorLevel=0){
			MouseMove, %x%, %y%
			MouseClick, left, %x%, %y%
		}
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, %A_ScriptDir%\scripExchange_materia.png
		if(ErrorLevel=0){
			MouseMove, %x%, %y%
			MouseClick, left, %x%, %y%
		}
		
		ErrorLevel:=""
		While (ErrorLevel!=0)
		{
			imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, %A_ScriptDir%\scrip_materia_dropdown.png
			if(ErrorLevel=0){
				MouseMove, %x%, %y%
				MouseClick, left, %x%, %y%
			}
		}
		
		sleep, 500
	;callback
		ErrorLevel:=""	
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, %A_ScriptDir%\scrip_materia_dropdown_fallback.png
		if(ErrorLevel=0){
			MouseMove, %x%, %y%
			MouseClick, left, %x%, %y%
		}
		
		sleep, 500
		ErrorLevel:=""
		While (ErrorLevel!=0)
		{
			imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, %A_ScriptDir%\selectSubCategory.png
		}
		if(ErrorLevel=0){
			MouseMove, %x%, %y%
			MouseClick, left, %x%, %y%
			MouseMove, %x%, %y%
			MouseClick, left, %x%, %y%
		}
		
		ErrorLevel:=""
		While (ErrorLevel!=0)
		{
			imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, %A_ScriptDir%\selectSubCategory_whitescrip.png
		}
		if(ErrorLevel=0){
			MouseMove, %x%, %y%
			MouseClick, left, %x%, %y%
			MouseMove, %x%, %y%
			MouseClick, left, %x%, %y%
		}
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, %A_ScriptDir%\selectSubCategory_whitescrip.png
		if(ErrorLevel=0){
			MouseMove, %x%, %y%
			MouseClick, left, %x%, %y%
		}
		
		MouseMove, 0, 0
		
		ErrorLevel:=""
		While (ErrorLevel!=0)
		{
			imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, %A_ScriptDir%\buyItem.png
		}
		
		if(ErrorLevel=0){
			MouseMove, %x%, %y%
			sleep, 500
			MouseClick, left, %x%, %y%
			sleep, 500
			ControlSend, , {Esc}, ahk_class FFXIVGAME
			sleep, 500
			ControlSend, , {Right}, ahk_class FFXIVGAME
			sleep, 500
			ControlSend, , ``, ahk_class FFXIVGAME
			sleep, 500
			ControlSend, , {Left}, ahk_class FFXIVGAME
			sleep, 500
			ControlSend, , ``, ahk_class FFXIVGAME
			sleep, 500
			ControlSend, , {Left}, ahk_class FFXIVGAME
			sleep, 500
			ControlSend, , ``, ahk_class FFXIVGAME
			sleep, 500
			ControlSend, , {Left}, ahk_class FFXIVGAME
			sleep, 500
			ControlSend, , ``, ahk_class FFXIVGAME
			sleep, 1000
			ControlSend, , {Esc}, ahk_class FFXIVGAME
			sleep, 2000
			handleCollectableAppraiser()
		}
	}
	
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
	
	^F4::ExitApp DebugWindow("All scripts terminated...",1,1,200,0)
	