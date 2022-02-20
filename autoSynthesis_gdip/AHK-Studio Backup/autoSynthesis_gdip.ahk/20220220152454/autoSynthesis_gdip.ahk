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
	gdip:= 1
	sleep, 2000
	DebugWindow("it's still crafting",0,1,500,0)
	While (gdip>0) ; when the crafting window is opened, means it's currently in busy mode
	{
		processWindowImage()
		gdip:=searchImage("still-crafting")
	}
	DebugWindow("done crafting",0,1,200,0)
	if(gdip<1){ ; if less than 1, means not found, which means not busy anymore, proceed next
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
	processWindowImage() ;save current window image
	buttonToPress:=""
	gdip:=searchImage("spritbond_full")
	if(gdip>0){
		DebugWindow("will extract materia next",0,1,2000,0)		
		buttonToPress:=3
	}
	
	gdip:=searchImage("durability_yellow")
	if(gdip>0){
		DebugWindow("will repair next",0,1,2000,0)
		buttonToPress:=4
	}
	
	if(eatFoodFlag=1){
		gdip:=searchImage("food_refresh")
		if(gdip>0){
			DebugWindow("will eat food next",0,1,2000,0)
			buttonToPress:=5
		}
	}
	
	if(eatMedicineFlag=1){
		gdip:=searchImage("medicine_refresh")
		if(gdip>0){
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
	gdip:=""
	ControlSend, , {Esc}, ahk_class FFXIVGAME
	sleep, 5000
	ControlSend, , =, ahk_class FFXIVGAME
	sleep, 5000
	DebugWindow("opening craft item",0,1,200,0)
	ControlSend, , 2, ahk_class FFXIVGAME
}

eatMedicine(){
	DebugWindow("eatMedicine",0,1,200,0)
	gdip:=""
	ControlSend, , {Esc}, ahk_class FFXIVGAME
	sleep, 5000
	ControlSend, , -, ahk_class FFXIVGAME
	sleep, 5000
	DebugWindow("opening craft item",0,1,200,0)
	ControlSend, , 2, ahk_class FFXIVGAME
}

durabilityCheck(){
	DebugWindow("durabilityCheck",0,1,200,0)
	ControlSend, , {Esc}, ahk_class FFXIVGAME
	sleep, 2000
	DebugWindow("opening repair window",0,1,200,0)
	ControlSend, , 4, ahk_class FFXIVGAME
	
	gdip:=""
	While (gdip<1) ; ensure repair button is located
	{
		processWindowImage() ;save current window image
		gdip:=searchImage("repair_button")
	}
	if(gdip>0){ ;positive value means located, then repair
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
	
	ControlSend, , {Esc}, ahk_class FFXIVGAME
	sleep, 1000
	ControlSend, , 3, ahk_class FFXIVGAME
	
	gdip:=0
	While (gdip = 0)
	{
		processWindowImage() ;save current window image
		sleep, 1000
		gdip:=searchImage("spiritbond_100percent")
		if(gdip>0){
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
	gdip:=1
	While (gdip>0)
	{
		processWindowImage() ;save current window image
		gdip:=searchImage("synthesis_button")
		if(gdip<1){ ; synthesis_button not exist
			DebugWindow("breaking while loop",0,1,1,0)
			break
		}
		if(gdip>0){ ; synthesis_button exist
			DebugWindow("looping to send ``",0,1,1,0)
			ControlSend, , ``, ahk_class FFXIVGAME
		}
		
	}
}

autoSynthesisFallback() {
	DebugWindow("autoSynthesisFallback()",0,1,1,0)
	processWindowImage() ;save current window image
	gdip:=searchImage("synthesis_button")
	
	if(gdip>0){
		;MouseMove, %x%, %y%
		;Mouseclick, left, %x%, %y%`
		sleep, 500
		ControlSend, , ``, ahk_class FFXIVGAME
	}
	
	gdip:=searchImage("synthesis_button")
	
	if(gdip>0){
		;MouseMove, %x%, %y%
		;Mouseclick, left, %x%, %y%`
		sleep, 500
		ControlSend, , ``, ahk_class FFXIVGAME
	}
	
	gdip:=searchImage("synthesis_button")
	if(gdip>0){
		;MouseMove, %x%, %y%
		;Mouseclick, left, %x%, %y%`
		sleep, 500
		ControlSend, , ``, ahk_class FFXIVGAME
	}
}

detectDurability(){
	DebugWindow("detectDurability()",0,1,1,0)
	durability := ""
	while(durability=""){
		processWindowImage()		
		gdip:=searchImage(35)
		if(gdip>0){
			durability="35"
		} else{
			gdip:=searchImage(40)
			if(gdip>0){
				durability="40"
			} else{
				gdip:=searchImage(70)
				if(gdip>0){
					durability="70"
				} else {
					gdip:=searchImage(80)
					if(gdip>0){
						durability="80"
					}
				}
			}
		}
	}
	return durability
}

searchImage(filename){
	token := Gdip_Startup()
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
	
	sleep, 1000
	needleFilename:=filename ".png"
	needlePath:=A_ScriptDir "\" needleFilename
	needle:=Gdip_CreateBitmapFromFile(needlePath)
	result:=Gdip_ImageSearch(haystack,needle,LIST,,,,,80,0,1,0)
	Gdip_DisposeImage(haystack)
	Gdip_DisposeImage(needle)
	log("result for filename, " filename ".png : " result)
	return result
}

eatFoodFunc(){
	eatFoodFlag:="1"
}

processWindowImage(){

	Gdip_DisposeImage(pBitmap) ; clearing for reassignation
}

KillGDIP() {
	if pBitmap
		Gdip_DisposeImage(pBitmap)	
	
	Gdip_Shutdown(pToken)
}

^F4::ExitApp DebugWindow("All scripts terminated...",0,1,200,0)
