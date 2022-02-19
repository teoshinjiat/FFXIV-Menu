WinGet, GameID, ID, ahk_class FFXIVGAME
#MaxThreadsPerHotkey, 2
#Persistent
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, Force
SetMouseDelay, 5
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
;("done crafting",Clear:=1,LineBreak:=1,Sleep:=500,0)


F1::
Loop{
	DebugWindow("Start hand in",1,1,200,0)
	handleCollectableAppraiser()
	turnIn()
	sleep, 1000
}

F2::
DebugWindow("Start exchange",1,1,200,0)
handleExchange()
Return


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
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, scripExchange_materia.png
	}
	if(ErrorLevel=0){
		MouseMove, %x%, %y%
		MouseClick, left, %x%, %y%
	}
	imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, scripExchange_materia.png
	if(ErrorLevel=0){
		MouseMove, %x%, %y%
		MouseClick, left, %x%, %y%
	}
	
	ErrorLevel:=""
	While (ErrorLevel!=0)
	{
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, scrip_materia_dropdown.png
	}
	if(ErrorLevel=0){
		MouseMove, %x%, %y%
		MouseClick, left, %x%, %y%
	}
	
	;callback
	imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, scrip_materia_dropdown.png
	if(ErrorLevel=0){
		MouseMove, %x%, %y%
		MouseClick, left, %x%, %y%
	}
	
	ErrorLevel:=""
	While (ErrorLevel!=0)
	{
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, selectSubCategory.png
	}
	if(ErrorLevel=0){
		MouseMove, %x%, %y%
		MouseClick, left, %x%, %y%
	}
	
	ErrorLevel:=""
	While (ErrorLevel!=0)
	{
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, selectSubCategory_whitescrip.png
	}
	if(ErrorLevel=0){
		MouseMove, %x%, %y%
		MouseClick, left, %x%, %y%
	}
	imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, selectSubCategory_whitescrip.png
	if(ErrorLevel=0){
		MouseMove, %x%, %y%
		MouseClick, left, %x%, %y%
	}
	
	MouseMove, 0, 0
	
	ErrorLevel:=""
	While (ErrorLevel!=0)
	{
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, buyItem.png
	}
	
	if(ErrorLevel=0){
		MouseMove, %x%, %y%
		sleep, 500
		MouseClick, left, %x%, %y%
		sleep, 500
		ControlSend, , {Esc}, ahk_class FFXIVGAME
		sleep, 500
		ControlSend, , {Down}, ahk_class FFXIVGAME
		sleep, 500
		ControlSend, , {Left}, ahk_class FFXIVGAME
		sleep, 1000
		MouseMove, %x%, %y%
		MouseClick, left, %x%, %y%
		MouseClick, left, %x%, %y%
		sleep, 1000
		ControlSend, , {Down}, ahk_class FFXIVGAME
		sleep, 1000
		ControlSend, , {Down}, ahk_class FFXIVGAME
		sleep, 1000
		ControlSend, , ``, ahk_class FFXIVGAME
		sleep, 1000
		ControlSend, , {Esc}, ahk_class FFXIVGAME
	}
}

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
	
	ErrorLevel:=""
	
	sleep, 200
	ControlSend, , ``, ahk_class FFXIVGAME
	sleep, 200
	ControlSend, , ``, ahk_class FFXIVGAME
	Loop 8{
		sleep, 500
		ControlSend, , ``, ahk_class FFXIVGAME
	}
	sleep, 200
	
	ErrorLevel:=""
	imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, scrip_full.png
	if(ErrorLevel=0){
		sleep, 888
		ControlSend, , {Esc}, ahk_class FFXIVGAME
	}
	sleep, 888
	ControlSend, , {Esc}, ahk_class FFXIVGAME
	sleep, 1500
	handleExchange()
}
