#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
;#include C:\ahk\FFXIV\lib\json\json.ahk
#include C:\ahk\FFXIV\lib\utility\utility.ahk
#include C:\ahk\FFXIV\lib\gdip\Gdip_All.ahk
#include C:\ahk\FFXIV\lib\gdip\imageSearch\Gdip_ImageSearch.ahk
log("Started playground")


haystack22:="[05:03:53 PM]| (Verbose) |searchImage() Result for filename, 40.png : 0"

IfInString, haystack22, 
{
	log("found")
	
}