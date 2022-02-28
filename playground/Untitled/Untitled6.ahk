#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
#include C:\ahk\FFXIV\lib\json\json.ahk
#include C:\ahk\FFXIV\lib\utility\utility.ahk
#include C:\ahk\FFXIV\lib\gdip\Gdip_All.ahk
#include C:\ahk\FFXIV\lib\gdip\imageSearch\Gdip_ImageSearch.ahk
log("Started playground")

log:="[04:40:53 PM]|(Verbose)|nameWithSpace :| Craftsmans Command Materia X"
logArray:=StrSplit(log, "|",,3)

log("logArray1 : " + logArray[1])
log("logArray1 : " + logArray[2])
log("logArray1 : " + logArray[3])
log("logArray1 : " + logArray[4])