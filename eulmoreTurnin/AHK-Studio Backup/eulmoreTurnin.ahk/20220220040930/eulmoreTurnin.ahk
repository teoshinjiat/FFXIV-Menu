WinGet, GameID, ID, ahk_class FFXIVGAME
#MaxThreadsPerHotkey, 2
#NoTrayIcon
#Persistent
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, Force
SetMouseDelay, 5
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
;("done crafting",Clear:=1,LineBreak:=1,Sleep:=500,0)
DebugWindow("Started Eulmore Turnin, no keys required to activate...",1,1,200,0)

global selectedItem:=%1%
DebugWindow("selectedItem: "%selectedItemselectedItem%,0,1,200,0)

Loop {
	DebugWindow("Start hand in",0,1,200,0)
	handleCollectableAppraiser()
	sleep, 1000
}

handleExchange(){
	ControlSend, , {q}, ahk_class FFXIVGAME
	sleep, 500
	ControlSend, , ``, ahk_class FFXIVGAME
	sleep, 1000
	exchange()
}


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
