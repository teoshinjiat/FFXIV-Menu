SetWorkingDir %A_ScriptDir%
#include lib\json\json.ahk
#include lib\utility\utility.ahk
#include lib\gdip\Gdip_All.ahk
#include lib\gdip\imageSearch\Gdip_ImageSearch.ahk

OnExit("KillGDIP")
WinGet, GameID, ID, ahk_class FFXIVGAME
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, Force
SetMouseDelay, 5
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
log("Started Auto Synthesis")


global GameID:=GameID
global haystack:=""
global needle:=""

global expectedCraftCount:=A_Args[1]
global eatFoodFlag:=A_Args[2]
global eatMedicineFlag:=A_Args[3]
global currentCraftCount:=0
log("Param, expectedCraftCount : " + expectedCraftCount)
log("Param, eatFoodFlag : " + eatFoodFlag)
log("Param, eatMedicineFlag : " + eatMedicineFlag)

expectedCraftCount:=(expectedCraftCount > 0) ? expectedCraftCount : 2147483647 ; if is positive value means is not an infinite craft loop
Loop % expectedCraftCount {
	sleep, 500 ; mini rest time
	buttonToPress:=""
	durability:=detectDurability()
	repairMe:=""
	runMacro(durability)
	startTime := A_TickCount
	buttonToPress:=preHealthCheck() ; check for any maintenance while crafting, will perform after item is crafted if there's any maintenance needed
	sleep, 2000
	craftingWindow:=true
	log("it's still crafting")
	While (craftingWindow) ; when the crafting window is opened, means it's currently in busy mode, so keep looping until window is missing from game client
	{
		craftingWindow:=searchImage("still-crafting",,,,,1, GameID, false) ; pop, check for window
	}
	logTag("Debug", "Finished crafted one item, current craft count is " expectedCraftCount)
	EndTime := A_TickCount
	tooltip("Current craft count : " expectedCraftCount)
	logTag("Debug", "Time taken for the craft is " Ceil((EndTime - StartTime)/1000.0) " seconds")
	if(!craftingWindow){ ; if less than 1, means not found, which means not busy anymore, proceed next
		if(buttonToPress!=""){
			sleep, 1000
			healthCheck(buttonToPress)
			sleep, 4000 ; animation locked delay
		}
		sleep, 1000
		autoSynthesis()
	}
	expectedCraftCount++
}
log("Auto Synthesis finished.")
tooltip("Auto Synthesis finished.")
EXITAPP

runMacro(durability){
	ifequal durability,"35", ControlSend, , {Numpad1}, ahk_class FFXIVGAME
	ifequal durability,"40", ControlSend, , {Numpad3}, ahk_class FFXIVGAME
	ifequal durability,"70", ControlSend, , {Numpad4}, ahk_class FFXIVGAME
	ifequal durability,"80", ControlSend, , {Numpad7}, ahk_class FFXIVGAME
}

preHealthCheck(){
	buttonToPress:=""
	
	spritbond_full:=searchImage("spritbond_full",,,,,1, GameID)
	if(spritbond_full){
		log("will extract materia next")		
		buttonToPress:=3
	}
	
	
	durability_yellow:=searchImage("durability_yellow",,,,,1, GameID)
	if(durability_yellow){
		log("will repair next")
		buttonToPress:=4
	}
	
	if(eatFoodFlag=1){
		food_refresh:=searchImage("food_refresh",,,,,50, GameID)
		if(food_refresh){
			log("will eat food next")
			buttonToPress:=5
		}
	}
	
	if(eatMedicineFlag=1){
		medicine_refresh:=searchImage("medicine_refresh",,,,,50, GameID)
		if(medicine_refresh){
			log("will eat medicine next")
			buttonToPress:=6
		}
	}
	
	log("preHealthCheck() buttonToPress:" + buttonToPress)
	return buttonToPress
}

healthCheck(buttonToPress){
	log("healthCheck() buttonToPress:" buttonToPress)
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
	log("eatFood()")
	ControlSend, , {Esc}, ahk_class FFXIVGAME
	sleep, 5000
	ControlSend, , =, ahk_class FFXIVGAME
	sleep, 5000
	log("opening craft item")
	ControlSend, , 2, ahk_class FFXIVGAME
}

eatMedicine(){
	log("eatMedicine()")
	ControlSend, , {Esc}, ahk_class FFXIVGAME
	sleep, 5000
	ControlSend, , -, ahk_class FFXIVGAME
	sleep, 5000
	log("opening craft item")
	ControlSend, , 2, ahk_class FFXIVGAME
}

durabilityCheck(){
	log("durabilityCheck()")
	ControlSend, , {Esc}, ahk_class FFXIVGAME
	sleep, 2000
	log("opening repair window")
	ControlSend, , 4, ahk_class FFXIVGAME
	
	repair_button:=false
	While (repair_button = false) ; ensure repair button is located
	{
		repair_button:=searchImage("repair_button",,,,,1, GameID)
	}
	if(repair_button){
		log("repairing all")
		sleep, 500
		ControlSend, , {Right}, ahk_class FFXIVGAME
		sleep, 500
		ControlSend, , ``, ahk_class FFXIVGAME
		sleep, 500
		ControlSend, , 4, ahk_class FFXIVGAME
		sleep, 3000
		log("opening craft item")
		ControlSend, , 2, ahk_class FFXIVGAME
	}
}

spiritbondCheck(){
	log("spiritbondCheck()")
	sleep, 1000
	ControlSend, , {Esc}, ahk_class FFXIVGAME
	sleep, 1000
	ControlSend, , 3, ahk_class FFXIVGAME
	sleep, 1000
	
	
	spiritbond_100percent:=true
	While (spiritbond_100percent)
	{
		sleep, 1000
		ControlSend, , {Up}, ahk_class FFXIVGAME
		sleep, 1000		
		log("below while()")
		
		spiritbond_100percent:=searchImage("spiritbond_100percent",,,,,1, GameID)
		if(spiritbond_100percent){
			ControlSend, , {Down}, ahk_class FFXIVGAME
			sleep, 1000
			ControlSend, , ``, ahk_class FFXIVGAME
			sleep, 1000
			log("extracted one spiritbond")
		} 
		sleep, 2000 ;animation locked and window redisplay delay
	}
	
	log("FINISHED EXTRACTING SPIRITBOND")
	sleep, 2000
	ControlSend, , 3, ahk_class FFXIVGAME
	sleep, 3000
	log("opening craft item")
	ControlSend, , 2, ahk_class FFXIVGAME
	log("exiting spiritbond")
}

autoSynthesis() {
	log("autoSynthesis()")
	
	synthesis_button:=true
	index:=0
	While (synthesis_button)
	{
		synthesis_button:=searchImage("synthesis_button",,,,,80, GameID)
		if(!synthesis_button){ ; synthesis_button not exist
			log("breaking while loop")
			autoSynthesisFallback()
			break
		}
		if(synthesis_button){ ; synthesis_button exist
			log("looping to send ``")
			ControlSend, , ``, ahk_class FFXIVGAME
			index++
			if(index>5) {
				checkForFullInventory()
			}
		}
	}
}

checkForFullInventory(){
	log("checkForFullInventory()")
	inventory_full:=searchImage("inventory_full",,,,,1, GameID)
	if(inventory_full){
		ControlSend, , 2, ahk_class FFXIVGAME ; close window
		log("inventory full, script is terminated")
		ExitApp
	}
}

autoSynthesisFallback() { ; only run this when synthesis button is found
	log("autoSynthesisFallback()")
	
	synthesis_button:=searchImage("synthesis_button",,,,,80, GameID)
	
	if(synthesis_button){
		log("synthesis button variance of 80 is found")
		sleep, 300	
		ControlSend, , 2, ahk_class FFXIVGAME ; close window
		sleep, 2000 ; animation locked when closing craft window
		ControlSend, , 2, ahk_class FFXIVGAME ; reopen window
		sleep, 300	
		ControlSend, , ``, ahk_class FFXIVGAME
		sleep, 300
		ControlSend, , ``, ahk_class FFXIVGAME
		sleep, 300
		ControlSend, , ``, ahk_class FFXIVGAME
	}
}

detectDurability(){
	log("detectDurability()")
	durability := ""
	durabilityFlag:=false
	while(durability=""){	
		durabilityFlag:=searchImage("35",,,,,1, GameID)
		if(durabilityFlag){
			durability="35"
		} else{			
			durabilityFlag:=searchImage("40",,,,,1, GameID)
			if(durabilityFlag){
				durability="40"
			} else{
				durabilityFlag:=searchImage("70",,,,,1, GameID)
				if(durabilityFlag){
					durability="70"
				} else {					
					durabilityFlag:=searchImage("80",,,,,1, GameID)
					if(durabilityFlag){
						durability="80"
					}
				}
			}
		}
	}
	return durability
}

eatFoodFunc(){
	eatFoodFlag:="1"
}

KillGDIP() {
	if pBitmap
		Gdip_DisposeImage(pBitmap)	
	
	Gdip_Shutdown(pToken)
}

^F4::
log("Terminated Auto Synthesis",0,1)
sleep, 1000
archieveLogFile()
ExitApp 
