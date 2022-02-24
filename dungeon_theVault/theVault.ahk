SetWorkingDir %A_ScriptDir%
#include ..\lib\gdip\Gdip_All.ahk
#include ..\lib\gdip\Gdip_ImageSearch.ahk
#include ..\lib\utility\utility.ahk

;OnExit("KillGDIP")
WinGet, GameID, ID, ahk_class FFXIVGAME
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, Force
SetMouseDelay, 5
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
log("Started Dungeon - The Vault", clear:=1)
DebugWindow("GameID:"GameID,0,1,200,0)


global gameId:=GameID
global haystack:=""
global needle:=""

loop {
	processDutyQueue()
	dutyPop()
	bot()
	Sleep 1000 + Rnd(0,1000)
	checkDurability()
}

checkDurability(){	
	durability:=searchImage("images\indicator\durability_yellow",,,,,1, GameID) ; pop, check for window
	if(durability){
		repair()
		log("need to repair")		
	} else {
		log("no need to repair")
	}
}

repair(){
	log("repair")
	ControlSend, , {Alt down}{Shift down}4{Shift up}{Alt up}, ahk_class FFXIVGAME	
	
	
	repair_button:=""
	While (!repair_button) ; ensure repair button is located
	{
		repair_button:=searchImage("images\button\repairAll",,,,,1, GameID) ; pop, check for window
	}
	if(repair_button){ 
		log("repairing all")
		sleep, 500 + Rnd(0,111)
		ControlSend, , {Right}, ahk_class FFXIVGAME
		sleep, 500 + Rnd(0,111)
		ControlSend, , ``, ahk_class FFXIVGAME
		sleep, 500 + Rnd(0,111)
		ControlSend, , {Alt down}{Shift down}4{Shift up}{Alt up}, ahk_class FFXIVGAME	
		sleep, 2500 + Rnd(0,111)
	}
}

bot(){
	Sleep 12 + Rnd(0,111)
	
	dutyCommenced() ; searching for commencement in chatlog
	Sleep 12 + Rnd(0,111)
	
	buffFirstPack()
	Sleep 12 + Rnd(0,111)
	
	movementFirstPack()
	Sleep 12 + Rnd(0,111)
	
	combatFirstPack()
	Sleep 12 + Rnd(0,111)
	
	adjustCameraForSecondPackStep1()
	Sleep 12 + Rnd(0,111)
	
	movementSecondPackStep1()
	Sleep 12 + Rnd(0,111)
	
	;''adjustCameraForSecondPackStep2() ; need another camera turn left
	movementSecondPackStep2()
	Sleep 12 + Rnd(0,111)
	
	combatSecondPack()	
	Sleep 12 + Rnd(0,111)
	
	closeDeathDialog()
	Sleep 12 + Rnd(0,111)
	
	leaveParty()
	Sleep 12 + Rnd(0,111)
	
	safeSpotCheck()
	Sleep 12 + Rnd(0,111)
	
}


safeSpotCheck(){
	dutyEnded:=false
	while(!dutyEnded){ ;when text detected, also means user have reached safe spot, can open duty page again and loop the bot
		sleep, 300
		log("while(!dutyEnded)")
		dutyEnded:=searchImage("images\indicator\dutyEnded",,,,,1, GameID) ; pop, check for window
	}
}

closeDeathDialog() {
	log("closeDeathDialog()")
	
	;wait for window to open
	deathWindow:=false
	while(!deathWindow){ ;when text detected, also means user have reached safe spot, can open duty page again and loop the bot
		sleep, 300 + Rnd(0,111)
		log("while(!deathWindow)")
		deathWindow:=searchImage("images\window\death",,,,,1, GameID) ; pop, check for window
	}
	if(deathWindow) {
		ControlSend, , {Right}, ahk_class FFXIVGAME
		sleep, 200 + Rnd(0,111)
		ControlSend, , ``, ahk_class FFXIVGAME
		sleep, 200 + Rnd(0,111)
	}
}

leaveParty(){
	log("leaveParty()")
	sleep, 2000 + Rnd(0,111)
	ControlSend, , u, ahk_class FFXIVGAME
	sleep, 500 + Rnd(0,111)
	
	ControlSend, , ``, ahk_class FFXIVGAME
	sleep, 300 + Rnd(0,111)
	
	ControlSend, , ``, ahk_class FFXIVGAME	
	
}
movementSecondPackStep1() {
	log("movementSecondPackStep1()")
	ControlSend, , {w down}, ahk_class FFXIVGAME	
	sleep, 6000
	ControlSend, , {PgUp down}, ahk_class FFXIVGAME	
	sleep, 700
	ControlSend, , {PgUp up}, ahk_class FFXIVGAME	
	sleep, 2000
	ControlSend, , {w up}, ahk_class FFXIVGAME	
}
movementSecondPackStep2() {
	log("movementSecondPackStep2()")
	ControlSend, , {w down}, ahk_class FFXIVGAME	
	sleep, 2000
	ControlSend, , {w up}, ahk_class FFXIVGAME	
}
combatSecondPack(){
	ControlSend, , 4, ahk_class FFXIVGAME	
	ControlSend, , {Shift down}e{Shift up}, ahk_class FFXIVGAME	
	sleep, 2500 + Rnd(0,111) ;assuming that quick cast did not go off
	
}
adjustCameraForSecondPackStep1() {
	;while adjusting camera, buff for next pack
	ControlSend, , {PgDn down}, ahk_class FFXIVGAME	
	buffSecondPack()	
	sleep, 700
	ControlSend, , {PgDn up}, ahk_class FFXIVGAME		
}

buffSecondPack(){
	ControlSend, , 5, ahk_class FFXIVGAME	
}

dutyCommenced() {
	log("dutyCommenced()")
	
	begunIndicator:=false
	while(!begunIndicator){
		begunIndicator:=searchImage("images\indicator\dutyStart",,,,,1, GameID) ; pop, check for window
		if(begunIndicator){
			break
		}	
	}
}

buffFirstPack(){
	log("buff()")
	ControlSend, , {Shift down}c{Shift up}, ahk_class FFXIVGAME	
	ControlSend, , x, ahk_class FFXIVGAME		
	sleep, 2500 + Rnd(0,123) ;cast time sleep
	ControlSend, , {Shift down}z{Shift up}, ahk_class FFXIVGAME	
	sleep, 2500 + Rnd(0,123) ;cast time sleep
	
}

movementFirstPack(){
	log("movementFirstPack()")
	ControlSend, , {w down}, ahk_class FFXIVGAME	
	sleep, 7000
	ControlSend, , {w up}, ahk_class FFXIVGAME	
}

combatFirstPack(){
	sleep, 500
	ControlSend, , {Numpad2}, ahk_class FFXIVGAME	
	sleep, 2500
	ControlSend, , {Numpad3}, ahk_class FFXIVGAME
	sleep, 2500
}

dutyPop(){
	log("dutyPop()")
	
	waitButton:=false
	while(!waitButton){
		sleep, 200
		log("while(!waitButton)")
		waitButton:=searchImage("images\button\wait",,,,,1, GameID) ; pop, check for window
		if(!waitButton){
			ControlSend, , {Left}, ahk_class FFXIVGAME		
		}
	}
	
	if(waitButton){ ; if wait button is highlighted
		
		commenceButton:=false
		while(!commenceButton){
			sleep, 200
			log("while(!commenceButton)")
			commenceButton:=searchImage("images\button\commence",,,,,1, GameID) ; pop, check for window
			sleep, 500
			if(commenceButton){
				ControlSend, , ``, ahk_class FFXIVGAME	
			} else {
				ControlSend, , {Left}, ahk_class FFXIVGAME		
			}
		}
	}
}

processDutyQueue(){
	log("processDutyQueue()")
	sleep, 500
	ControlSend, , u, ahk_class FFXIVGAME	
	
	loop {
		gdip:=searchImage("images\button\clearSelection",,,,,1, GameID)
		if(!gdip){ ; clear selection button is NOT highlighted, keep going down
			DebugWindow("clear selection button is NOT highlighted, keep going down",0,1,1,0)
			ControlSend, , {Down}, ahk_class FFXIVGAME	
			sleep, 300
		}
		if(gdip){ ; clear selection button is highlighted, go right to Join button
			DebugWindow("clear selection button is highlighted, go right to Join button",0,1,1,0)
			ControlSend, , {Right}, ahk_class FFXIVGAME		
			
			gdip:=searchImage("images\button\clearSelection",,,,,1, GameID)
			if(gdip){
				DebugWindow("join button is highlighted, ` to join",0,1,1,0)				
				ControlSend, , ``, ahk_class FFXIVGAME	
				break
			}
		}
	}
}






^F4::ExitApp DebugWindow("Terminated Dungeon - The Vault",0,1,200,0)
