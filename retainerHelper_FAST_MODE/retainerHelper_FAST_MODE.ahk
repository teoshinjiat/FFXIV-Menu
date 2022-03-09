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
log("Started Retainer Helper - FAST MODE", 1)
global GameID:=GameID
global undercutThreshold=0.10 ;if first listed price is undercut more than 10% of my asking price
global myPrice:=""
global latestPrice:=""
global RETAINER_TAG:="Retainer"
global RETAINER_UNDERCUT_TAG:="Retainer Undercut"
;retainerIndex := Array(1, 2, 3, 4, 5, 6)
global retainerIndex := Array(1,2,3,4,5,6)
global currentRetainerIndex:=""
global isMyRetainers:=false
global fixedAfkTimer:=60000 ; 4 minutes
global shouldUndercutMyRetainer:=true ; should be on the GUI


^F4::
log("Terminated Retainer Helper - FAST MODE",0,1)
archieveLogFile()
ExitApp 
