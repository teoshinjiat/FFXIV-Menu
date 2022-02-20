SetWorkingDir %A_ScriptDir%
#include ..\lib\json\json.ahk
#include utility\utility.ahk
#include lib\gdip\Gdip_All.ahk
#include ..\lib\Functions\Gdip_ImageSearch\Gdip_ImageSearch.ahk
OnExit("KillGDIP")
WinGet, GameID, ID, ahk_class FFXIVGAME
#Persistent
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, Force
SetMouseDelay, 5
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
DebugWindow("Started GDIP playground",1,1,200,0)
DebugWindow("GameID:"GameID,0,1,200,0)


global gameId:=GameID
global haystack:=""
global needle:=""
global eatFoodFlag:=%1%
global eatMedicineFlag:=%2%
global collectableFlag:=%3%


if !pToken := Gdip_Startup()
{
	log("Gdip_Startup fail")
	ExitApp
}

DebugWindow("Started script",0,1,200,0)
Loop{	
	sleep, 500 ;after spamming `, give it some time to rest
	buttonToPress:=""
	durability:=detectDurability()
	repairMe:=""
	runMacro(durability)
	buttonToPress:=preHealthCheck()
	ErrorLevel:= 0
	sleep, 2000
	DebugWindow("it's still crafting",0,1,500,0)
	While (ErrorLevel=0)
	{
		imageSearch, x, y, 0, 852, 351, 994, *30, *TransBlack, %A_ScriptDir%\still-crafting.png
	}
	DebugWindow("done crafting",0,1,200,0)r
	if(ErrorLevel = 1){
		if(buttonToPress!=""){
			sleep, 1000
			healthCheck(buttonToPress)
			sleep, 4000
		}
		sleep, 1000
		autoSynthesis()
		autoSynthesis()
		;sleep, 2000
		;autoSynthesisFallback()
	}
}

runMacro(durability){
	ifequal durability,"35", ControlSend, , {Numpad1}, ahk_class FFXIVGAME
	ifequal durability,"40", ControlSend, , {Numpad3}, ahk_class FFXIVGAME
	ifequal durability,"70", ControlSend, , {Numpad4}, ahk_class FFXIVGAME
	ifequal durability,"80", ControlSend, , {Numpad7}, ahk_class FFXIVGAME
}

preHealthCheck(){
	ErrorLevel:=""
	buttonToPress:=""
	imageSearch, x, y, 0, 0, 569, 133, *30, *TransBlack, %A_ScriptDir%\spritbond_full.png
	if(ErrorLevel=0){
		DebugWindow("will extract materia next",0,1,2000,0)		
		buttonToPress:=3
	}
	
	imageSearch, x, y, 0, 0, 569, 133, *30, *TransBlack, %A_ScriptDir%\durability_yellow.png
	if(ErrorLevel=0){
		DebugWindow("will repair next",0,1,2000,0)
		buttonToPress:=4
	}
	
	if(eatFoodFlag=1){
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, %A_ScriptDir%\food_refresh.png
		if(ErrorLevel=0){
			DebugWindow("will eat food next",0,1,2000,0)
			buttonToPress:=5
		}
	}
	
	if(eatMedicineFlag=1){
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, %A_ScriptDir%\medicine_refresh.png
		if(ErrorLevel=0){
			DebugWindow("will eat medicine next",0,1,2000,0)
			buttonToPress:=6
		}
	}
	
	DebugWindow("preHealthCheck() buttonToPress:" + buttonToPress,0,1,2000,0)
	return buttonToPress
}

healthCheck(buttonToPress){
	DebugWindow("healthCheck() buttonToPress:" buttonToPress,0,1,200,0)
	if(buttonToPress=3){
		spiritbondCheck()
	} else if(buttonToPress=4){
		durabilityCheck()
	} else if(buttonToPress=5){
		eatFood()
	} else {
		eatMedicine()
	}
}

eatFood(){
	DebugWindow("eatFood",0,1,200,0)
	ErrorLevel:=""
	ControlSend, , {Esc}, ahk_class FFXIVGAME
	sleep, 5000
	ControlSend, , =, ahk_class FFXIVGAME
	sleep, 5000
	DebugWindow("opening craft item",0,1,200,0)
	ControlSend, , 2, ahk_class FFXIVGAME
}

eatMedicine(){
	DebugWindow("eatMedicine",0,1,200,0)
	ErrorLevel:=""
	ControlSend, , {Esc}, ahk_class FFXIVGAME
	sleep, 5000
	ControlSend, , -, ahk_class FFXIVGAME
	sleep, 5000
	DebugWindow("opening craft item",0,1,200,0)
	ControlSend, , 2, ahk_class FFXIVGAME
}

durabilityCheck(){
	DebugWindow("durabilityCheck",0,1,200,0)
	ErrorLevel:=""
	ControlSend, , {Esc}, ahk_class FFXIVGAME
	sleep, 2000
	DebugWindow("opening repair window",0,1,200,0)
	ControlSend, , 4, ahk_class FFXIVGAME
	
	ErrorLevel:=""
	While (ErrorLevel!=0)
	{
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, %A_ScriptDir%\repair_button.png
	}
	if(ErrorLevel=0){
		DebugWindow("repairing all",0,1,200,0)
		sleep, 500
		ControlSend, , {Right}, ahk_class FFXIVGAME
		sleep, 500
		ControlSend, , ``, ahk_class FFXIVGAME
		sleep, 500
		ControlSend, , 4, ahk_class FFXIVGAME
		sleep, 3000
		DebugWindow("opening craft item",0,1,200,0)
		ControlSend, , 2, ahk_class FFXIVGAME
	}
}

spiritbondCheck(){
	DebugWindow("spiritbondCheck()",0,1,200,0)
	
	ErrorLevel:=""
	ControlSend, , {Esc}, ahk_class FFXIVGAME
	sleep, 1000
	ControlSend, , 3, ahk_class FFXIVGAME
	
	ErrorLevel:="0"
	While (ErrorLevel = 0)
	{
		sleep, 1000
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, %A_ScriptDir%\spiritbond_100percent.png
		if(ErrorLevel=0){
			ControlSend, , {Right}, ahk_class FFXIVGAME
			sleep, 1000
			ControlSend, , ``, ahk_class FFXIVGAME
			sleep, 1000
			DebugWindow("EXTRACTING SPIRITBOND",0,1,1,0)
		} 
	}
	DebugWindow("FINISHED EXTRACTING SPIRITBOND",0,1,1,0)
	sleep, 2000
	ControlSend, , 3, ahk_class FFXIVGAME
	sleep, 3000
	DebugWindow("opening craft item",0,1,1,0)
	ControlSend, , 2, ahk_class FFXIVGAME
	DebugWindow("exiting spiritbond",0,1,1,0)
}

autoSynthesis() {
	DebugWindow("autoSynthesis()",0,1,1,0)
	ErrorLevel:=0
	While (ErrorLevel=0)
	{
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, %A_ScriptDir%\synthesis_button.png
		if(ErrorLevel=1){
			DebugWindow("breaking while loop",0,1,1,0)
			break
		}
		if(ErrorLevel=0){
			DebugWindow("looping to send ``",0,1,1,0)
			ControlSend, , ``, ahk_class FFXIVGAME
		}
		
	}
}

autoSynthesisFallback() {
	DebugWindow("autoSynthesisFallback()",0,1,1,0)
	
	ErrorLevel:=""
	imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, %A_ScriptDir%\synthesis_button.png
	
	if(ErrorLevel=0){
		;MouseMove, %x%, %y%
		;Mouseclick, left, %x%, %y%`
		sleep, 500
		ControlSend, , ``, ahk_class FFXIVGAME
	}
	
	ErrorLevel:=""
	imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, %A_ScriptDir%\synthesis_button.png
	
	if(ErrorLevel=0){
		;MouseMove, %x%, %y%
		;Mouseclick, left, %x%, %y%`
		sleep, 500
		ControlSend, , ``, ahk_class FFXIVGAME
	}
	
	ErrorLevel:=""
	imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, %A_ScriptDir%\synthesis_button.png
	
	if(ErrorLevel=0){
		;MouseMove, %x%, %y%
		;Mouseclick, left, %x%, %y%`
		sleep, 500
		ControlSend, , ``, ahk_class FFXIVGAME
	}
}

detectDurability(){
	DebugWindow("detectDurability()",0,1,1,0)
	processWindowImage()
	durability := ""
	while(durability=""){
		errorLevel:=searchDurability(35)
		if(errorLevel=0){
			durability="35"
		} else{
			errorLevel:=searchDurability(40)
			if(errorLevel=0){ ;*[autoSynthesis]
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

searchDurability(filename){
	DebugWindow("durability filename : " filename,0,1,1,0)
	;log("dir: " a_scriptdir)
	needlePath:=A_ScriptDir "\"filename".png"
	Run % needlePath
	needle:=Gdip_CreateBitmapFromFile(needlePath)
	
	result:= Gdip_ImageSearch(haystack,needle,LIST,,,,,80,0,1,0)
	DebugWindow("result : " result,0,1,1,0)
	
	;imageSearch, x, y, 19, 353, 246, 451, *30, *TransBlack, %A_ScriptDir%\%filename%.png
	;return ErrorLevel
}

eatFoodFunc(){
	eatFoodFlag:="1"
}


processWindowImage(){
	log("GameID: "GameID)
	if !pBitmap := Gdip_BitmapFromHWND(gameId)
	{
		log("Gdip_BitmapFromHWND fail")
		ExitApp
	}
	
	if Gdip_SaveBitmapToFile(pBitmap, img := A_ScriptDir "\screen.png")
	{
		log("Gdip_SaveBitmapToFile fail11")
		ExitApp
	}
	haystack:=Gdip_CreateBitmapFromFile("screen.png")
}



KillGDIP() {
	global
	
	if pBitmap
		Gdip_DisposeImage(pBitmap)	
	
	Gdip_Shutdown(pToken)
}

^F4::ExitApp DebugWindow("All scripts terminated...",0,1,200,0)
