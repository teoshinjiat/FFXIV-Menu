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
	do{
		errorLevel:=searchDurability(35)
		if(errorLevel=0){
			durability="35"
		} else{
			errorLevel:=searchDurability(40)
			if(errorLevel=0){
				durability="40"
			} else{
				errorLevel:=searchDurability(70)
				if(errorLevel=0){
					durability="70"
				} else {
					errorLevel:=searchDurability(80)
					if(errorLevel=0){
						durability="80"
					}
				}
			}
		}
	}while(durability!="")
	
	return durability
}

searchDurability(filename){
	imageSearch, x, y, 19, 353, 246, 451, *30, *TransBlack, %filename%.png
	return ErrorLevel
}
