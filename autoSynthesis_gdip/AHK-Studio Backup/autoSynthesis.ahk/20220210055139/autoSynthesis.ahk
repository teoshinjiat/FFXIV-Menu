WinGet, GameID, ID, ahk_class FFXIVGAME
#MaxThreadsPerHotkey, 2
#Persistent
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, Force
SetMouseDelay, 5
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
SetTimer, ForceExitApp,  36000000 ; 60 minutes

F1::
Loop{
	
	durability:=detectDurability()
	runMacro(durability)
	healthCheck()
	autoSynthesis()
	autoSynthesisFallback()
}

healthCheck(){
	durabilityCheck()
	spiritbondCheck()
}

durabilityCheck(){
	ErrorLevel:=""
	imageSearch, x, y, 0, 0, 569, 133, *30, *TransBlack, durability_yellow.png
	if(ErrorLevel=0){
		ControlSend, , {Esc}, ahk_class FFXIVGAME
		sleep, 200
		ControlSend, , !+4, ahk_class FFXIVGAME
		
		ErrorLevel:=""
		While (ErrorLevel != 0)
		{
			imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, repair_button.png
		}
		if(ErrorLevel=0){
			ControlSend, , {Down}, ahk_class FFXIVGAME
		}
	}
}

spiritbondCheck(){
	ErrorLevel:=""
	imageSearch, x, y, 0, 0, 569, 133, *30, *TransBlack, spritbond_full.png
}

autoSynthesis() {
	ErrorLevel:=""
	While (ErrorLevel != 0)
	{
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, synthesis_button.png
	}
	
	if(ErrorLevel=0){
		;MouseMove, %x%, %y%
		;Mouseclick, left, %x%, %y%
		ControlSend, , ``, ahk_class FFXIVGAME
		ControlSend, , ``, ahk_class FFXIVGAME
		ControlSend, , ``, ahk_class FFXIVGAME
	}
}

autoSynthesisFallback() {
	ErrorLevel:=""
	imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, synthesis_button.png
	
	if(ErrorLevel=0){
		;MouseMove, %x%, %y%
		;Mouseclick, left, %x%, %y%
		ControlSend, , ``, ahk_class FFXIVGAME
		ControlSend, , ``, ahk_class FFXIVGAME
		ControlSend, , ``, ahk_class FFXIVGAME
	}
}

detectDurability(){
	durability := ""
	while(durability=""){
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
	}
	return durability
}

runMacro(durability){
	ifequal durability,"35", ControlSend, , {Numpad6}, ahk_class FFXIVGAME
	ifequal durability,"40", ControlSend, , {Numpad3}, ahk_class FFXIVGAME
	ifequal durability,"70", ControlSend, , {Numpad4}, ahk_class FFXIVGAME
	ifequal durability,"80", ControlSend, , {Numpad7}, ahk_class FFXIVGAME
}

/*
	else if(durability=="40"){
		Send Numpad3
	} else if(durability=="70"){
		Send Numpad4
	} else if(durability=="80"){
		Send Numpad7
	}
*/

searchDurability(filename){
	imageSearch, x, y, 19, 353, 246, 451, *30, *TransBlack, %filename%.png
	return ErrorLevel
}

ForceExitApp:
SetTimer,  ForceExitApp, Off
ExitApp