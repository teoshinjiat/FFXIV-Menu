WinGet, GameID, ID, ahk_class FFXIVGAME
#MaxThreadsPerHotkey, 2
#Persistent
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, Force
SetMouseDelay, 5
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
SetTimer, ForceExitApp,  3600000 ; 60 minutes
SetTimer, EatFoodTimer,  2000 ; 30 minutes

eatFoodFlag:="0"
;("done crafting",Clear:=1,LineBreak:=1,Sleep:=500,0)

DebugWindow("Script listening...",1,1,200,0)
F1::

imageSearch, x, y, 0, 0, 2560, 1440, *30, *TransBlack, food_lessthan300second.png
if (ErrorLevel = 2)
	MsgBox Could not conduct the search.
else if (ErrorLevel = 1)
	MsgBox Icon could not be found on the screen.
else
	MsgBox The icon was fouwdnd at %x% : %y%

EatFoodTimer:
Loop{
	DebugWindow("EatFoodTimer:",0,1,200,0)
	sleep, 1800000
}


eatFoodFunc:
DebugWindow("eatFoodFunc:",0,1,200,0)
eatFoodFlag:="1"

ForceExitApp:
SetTimer,  ForceExitApp, Off
ExitApp