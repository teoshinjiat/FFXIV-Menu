SetWorkingDir %A_ScriptDir%
#SingleInstance, Force
#include ..\lib\json\json.ahk
#include ..\lib\utility\utility.ahk
#include ..\lib\gdip\Gdip_All.ahk
#include ..\lib\gdip\imageSearch\Gdip_ImageSearch.ahk

WinGet, GameID, ID, ahk_class FFXIVGAME
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, Force
SetMouseDelay, 5
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
log("Started Retainer Helper", 1)
global GameID:=GameID

retainerIndex=[1,2,3,4,5,6];

loop{
	if(isRetainerWindowCurrentlyOnFocus()){
		log("it's on focus now")
	}
}
	
isRetainerWindowCurrentlyOnFocus(){
	isRetainerWindowCurrentlyOnFocus:=false
	while(!isRetainerWindowCurrentlyOnFocus){
		isRetainerWindowCurrentlyOnFocus:=searchImage("images/indicator/retainer_window_focus_indicator",,,,,1, GameID) ; pop, check for window	
		if(!isRetainerWindowCurrentlyOnFocus){
			attemptToRegainFocus()
		}
	}
	return isRetainerWindowCurrentlyOnFocus
}

; fallback
attemptToRegainFocus(){ ; this will force mousemovement to the game because controlclick does not work for the game, worth the downside
	isFocused:=1
	while(isFocused=1){
		log("attemptToRegainFocus()")
		;imageSearch, x, y, 0, 164, 490, 641, *30, *TransBlack, elderNutmeg.png
		
		;Run % "images/window/retainer_window_click_position.png"
		log("before()")
		
		ImageSearch, foundX, foundY,0,0,2560,1440, *1 images\window\retainer_window_click_position.png
		log("after()")
		
		isFocused:=ErrorLevel
		if(isFocused=0){
			log("ErrorLevel:" ErrorLevel)
			log("foundX : " + foundX)
			log("foundY : " + foundY)
			MouseClick, left, %foundX%, %foundY%
			sleep, 1000
			break
		}
	}
}



^F4::
log("Terminated Retainer Helper",0,1)
archieveLogFile()
ExitApp 
