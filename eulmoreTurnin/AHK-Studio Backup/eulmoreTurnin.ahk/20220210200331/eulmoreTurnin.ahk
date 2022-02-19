WinGet, GameID, ID, ahk_class FFXIVGAME
#MaxThreadsPerHotkey, 2
#Persistent
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, Force
SetMouseDelay, 5
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
SetTimer, ForceExitApp,  36000000 ; 60 minutes
;("done crafting",Clear:=1,LineBreak:=1,Sleep:=500,0)


F1::
DebugWindow("Started script",1,1,200,0)
;Loop{
	;handleCollectableAppraiser()
turnIn()

;}

handleCollectableAppraiser(){
	ControlSend, , {e}, ahk_class FFXIVGAME
	sleep, 500
	ControlSend, , ``, ahk_class FFXIVGAME
	sleep, 1000
	turnIn()
	
	
}

turnIn(){
	DebugWindow("turnIn()",0,1,200,0)
	
	ErrorLevel:=""
	While (ErrorLevel!=0)
	{
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, popoto.png
	}
	MouseMove, %x%, %y%
	MouseClick, left, %x%, %y%
	
	collectableItem:=0
	scripFull:=1
	DebugWindow("while()",0,1,200,0)
	While (collectableItem!=1&&scripFull!=0)
	{
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, popoto.png
		collectableItem:=ErrorLevel
		
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, scrip_full.png
		scripFull:=ErrorLevel
		
		DebugWindow("collectableItem:"collectableItem,0,1,200,0)
		DebugWindow("scripFull:"scripFull,0,1,200,0)
		
		if(collectableItem=0){
			ControlSend, , ``, ahk_class FFXIVGAME
			sleep, 500
			ControlSend, , ``, ahk_class FFXIVGAME
			sleep, 500
			ControlSend, , ``, ahk_class FFXIVGAME
		}
	}
	
	
	
}


ForceExitApp:
SetTimer,  ForceExitApp, Off
ExitApp

/*
	
	While (collectableItem!=1)
	{
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, popoto.png
		collectableItem:=ErrorLevel
		
		;imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, scrip_full.png
		;scriptFull:=ErrorLevel
		if(collectableItem=0){
			ControlSend, , ``, ahk_class FFXIVGAME
		}
		
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, scrip_full.png
		if(ErrorLevel=0){
			collectableItem:=1
		}
	}
	
*/