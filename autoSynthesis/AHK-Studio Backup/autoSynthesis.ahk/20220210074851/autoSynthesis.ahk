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
Loop{
	OutputDebug % "AHK| " text
	durability:=detectDurability()
	runMacro(durability)
	repairMe:=""
	buttonToPress:=""
	buttonToPress:=preHealthCheck()
	ErrorLevel:=0
	While (ErrorLevel = 0)
	{
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, still-crafting.png
	}
	DebugWindow("done crafting",0,1,200,0)
	if(ErrorLevel = 1){
		if(buttonToPress!=0){
			healthCheck(buttonToPress)
		}
		autoSynthesis()
		autoSynthesisFallback()
	}
	
}

preHealthCheck(){
	ErrorLevel:=""
	buttonToPress:=""
	imageSearch, x, y, 0, 0, 569, 133, *30, *TransBlack, spritbond_full.png
	if(ErrorLevel=0){
		buttonToPress:=3
	}
	
	imageSearch, x, y, 0, 0, 569, 133, *30, *TransBlack, durability_yellow.png
	if(ErrorLevel=0){
		buttonToPress:=4
	}
	DebugWindow("totalErrorLevel:" + totalErrorLevel,0,1,2000,0)
	return buttonToPress
}

healthCheck(buttonToPress){
	DebugWindow("buttonToPress:" buttonToPress,0,1,200,0)
	if(buttonToPress=3){
		spiritbondCheck()
	} else {
		durabilityCheck()
	}
}

durabilityCheck(){
	DebugWindow("durabilityCheck",0,1,200,0)
	ErrorLevel:=""
	DebugWindow("before Esc",0,1,200,0)
	;imageSearch, x, y, 0, 0, 569, 133, *30, *TransBlack, durability_yellow.png
	;if(ErrorLevel=0){
	ControlSend, , {Esc}, ahk_class FFXIVGAME
	sleep, 2000
	DebugWindow("opening repair window",0,1,200,0)
	ControlSend, , 4, ahk_class FFXIVGAME
	
	ErrorLevel:=""r
	While (ErrorLevel!=0)
	{
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, repair_button.png
	}
	if(ErrorLevel=0){
		sleep, 200
		ControlSend, , {Down}, ahk_class FFXIVGAME
		sleep, 200
		ControlSend, , ``, ahk_class FFXIVGAME
		sleep, 200
		ControlSend, , 4, ahk_class FFXIVGAME
		
		sleep, 3000
		DebugWindow("opening craft item",0,1,200,0)
		ControlSend, , 2, ahk_class FFXIVGAME
	}
	;}
}

spiritbondCheck(){
	DebugWindow("spiritbondCheck",0,1,200,0)
	
	ErrorLevel:=""
	;imageSearch, x, y, 0, 0, 569, 133, *30, *TransBlack, spritbond_full.png
	;if(ErrorLevel=0){
	DebugWindow("spritbond DETECTED",0,1,200,0)
	ControlSend, , {Esc}, ahk_class FFXIVGAME
	sleep, 1000
	ControlSend, , 3, ahk_class FFXIVGAME
	
	ErrorLevel:="0"
	DebugWindow("outside while",0,1,1000,0)
	While (ErrorLevel = 0)
	{
		DebugWindow("inside while",0,1,1000,0)
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, spiritbond_100percent.png
		if(ErrorLevel=0){
			ControlSend, , {Right}, ahk_class FFXIVGAME
			sleep, 500
			ControlSend, , ``, ahk_class FFXIVGAME
			DebugWindow("EXTRACTING SPIRITBOND",0,1,1000,0)
		}
	}
	
	DebugWindow("FINISHED EXTRACTING SPIRITBOND",0,1,200,0)
	sleep, 200
	ControlSend, , 3, ahk_class FFXIVGAME
	sleep, 200
	ControlSend, , 2, ahk_class FFXIVGAME
	sleep, 2000
	DebugWindow("exiting spiritbond",0,1,200,0)
	;}
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