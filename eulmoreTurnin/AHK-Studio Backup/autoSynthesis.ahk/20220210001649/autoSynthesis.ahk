WinGet, GameID, ID, ahk_class FFXIVGAME
#MaxThreadsPerHotkey, 2
#Persistent
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, Force
SetMouseDelay, 5

F3::
;autoSynthesis()
detectDurability()

autoSynthesis() {
	ErrorLevel:=""
	While (ErrorLevel != 0)
	{
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, synthesis_button.png
	}
	if(ErrorLevel=0){
		MouseMove, %x%, %y%
		Mouseclick, left, %x%, %y%
	}
}

detectDurability(){
	durability := ""
	errorLevel:=searchDurability(35)
	if(errorLevel=0){
		durability="35"
		msgbox dura is 35
	} else {
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, 35.png
		if(ErrorLevel=0){
			durability="35"
		}
	}
}

searchDurability(filename){
	imageSearch, x, y, 19, 353, 246, 451, *30, *TransBlack, %filename%+.png
}
