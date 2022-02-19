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
;Loop{
	handleCollectableAppraiser()

;}

handleCollectableAppraiser(){
	ControlSend, , {Enter}, ahk_class FFXIVGAME
	sleep, 500
	ControlSend, , /tar Collectable, ahk_class FFXIVGAME
	sleep, 1000
	Send, {Enter}
}


ForceExitApp:
SetTimer,  ForceExitApp, Off
ExitApp