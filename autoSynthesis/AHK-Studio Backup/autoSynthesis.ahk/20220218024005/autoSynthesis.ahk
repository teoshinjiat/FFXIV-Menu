WinGet, GameID, ID, ahk_class FFXIVGAME
#MaxThreadsPerHotkey, 2
#Persistent
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, Force
SetMouseDelay, 5
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

;("done crafting",Clear:=1,LineBreak:=1,Sleep:=500,0)
DebugWindow("Script listening...",1,1,200,0)

DebugWindow("GUI input",0,1,200,0)

Gui, Add, Checkbox, vFoodFlag, Auto refresh food (numpad9) when it's less than 10 minutes
Gui, Add, Checkbox, vMedicineFlag, Auto refresh medicine (numpad8) when it's less than 60 seconds
Gui, Add, Checkbox, vCollectableFlag, Collectable ;if true then send numpad0
Gui, Add, Button, default, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.
Gui, Show,, Simple Input Example
return  ; End of auto-execute section. The script is idle until the user does something.

ButtonCancel:
GuiClose:
GuiEscape:
Gui, Hide
Return   

ButtonOK:
Gui, Submit

;MsgBox vFoodFlag "%vFoodFlag%" | vCollectableFlag "%vCollectableFlag%".

global eatFoodFlag:=FoodFlag
global eatMedicineFlag:=MedicineFlag
DebugWindow("GUI input ::: FoodFlag:" eatFoodFlag,0,1,200,0)
DebugWindow("GUI input ::: MedicineFlag:" eatMedicineFlag,0,1,200,0)


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
	While (ErrorLevel = 0)
	{
		imageSearch, x, y, 0, 852, 351, 994, *30, *TransBlack, still-crafting.png
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
	imageSearch, x, y, 0, 0, 569, 133, *30, *TransBlack, spritbond_full.png
	if(ErrorLevel=0){
		DebugWindow("will extract materia next",0,1,2000,0)		
		buttonToPress:=3
	}
	
	imageSearch, x, y, 0, 0, 569, 133, *30, *TransBlack, durability_yellow.png
	if(ErrorLevel=0){
		DebugWindow("will repair next",0,1,2000,0)
		buttonToPress:=4
	}
		
	if(eatFoodFlag=1){
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, food_refresh.png
		if(ErrorLevel=0){
			DebugWindow("will eat food next",0,1,2000,0)
			buttonToPress:=5
		}
	}
	
	if(eatMedicineFlag=1){
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, medicine_refresh.png
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
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, repair_button.png
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
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, spiritbond_100percent.png
		if(ErrorLevel=0){
			ControlSend, , {Right}, ahk_class FFXIVGAME
			sleep, 1000
			ControlSend, , ``, ahk_class FFXIVGAME
			sleep, 1000
			DebugWindow("EXTRACTING SPIRITBOND",0,1,1000,0)
		} 
	}
	DebugWindow("FINISHED EXTRACTING SPIRITBOND",0,1,200,0)
	sleep, 2000
	ControlSend, , 3, ahk_class FFXIVGAME
	sleep, 3000
	DebugWindow("opening craft item",0,1,200,0)
	ControlSend, , 2, ahk_class FFXIVGAME
	DebugWindow("exiting spiritbond",0,1,200,0)
}

autoSynthesis() {
	DebugWindow("autoSynthesis()",0,1,200,0)
	ErrorLevel:=0
	While (ErrorLevel=0)
	{
		DebugWindow("entered while loop",0,1,200,0)
		
		imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, synthesis_button.png
		if(ErrorLevel=1){
			DebugWindow("breaking while loop",0,1,200,0)
			break
		}
		if(ErrorLevel=0){
			DebugWindow("looping to send ``",0,1,200,0)
			ControlSend, , ``, ahk_class FFXIVGAME
		}
		
	}
}

autoSynthesisFallback() {
	DebugWindow("autoSynthesisFallback()",0,1,200,0)
	
	ErrorLevel:=""
	imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, synthesis_button.png
	
	if(ErrorLevel=0){
		;MouseMove, %x%, %y%
		;Mouseclick, left, %x%, %y%`
		sleep, 500
		ControlSend, , ``, ahk_class FFXIVGAME
	}
	
	ErrorLevel:=""
	imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, synthesis_button.png
	
	if(ErrorLevel=0){
		;MouseMove, %x%, %y%
		;Mouseclick, left, %x%, %y%`
		sleep, 500
		ControlSend, , ``, ahk_class FFXIVGAME
	}
	
	ErrorLevel:=""
	imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, synthesis_button.png
	
	if(ErrorLevel=0){
		;MouseMove, %x%, %y%
		;Mouseclick, left, %x%, %y%`
		sleep, 500
		ControlSend, , ``, ahk_class FFXIVGAME
	}
}

detectDurability(){
	DebugWindow("detectDurability()",0,1,200,0)
	
	durability := ""
	while(durability=""){
		DebugWindow(" while detectDurability()",0,1,200,0)
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

searchDurability(filename){
	imageSearch, x, y, 19, 353, 246, 451, *30, *TransBlack, "C:\Users\teosh\Desktop\ahk\autoSynthesis\"%filename%.png
	msgbox,%a_scriptdir%
	if (ErrorLevel = 2)
		MsgBox Could not conduct the search.
	else if (ErrorLevel = 1)
		MsgBox Icon could not be found on the screen.
	else
		MsgBox The icon was found at %x% : %y%
	return ErrorLevel
}

eatFoodFunc(){
	eatFoodFlag:="1"
}