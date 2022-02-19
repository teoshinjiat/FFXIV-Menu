WinGet, GameID, ID, ahk_class FFXIVGAME
#MaxThreadsPerHotkey, 2
#Persistent
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, Force
SetMouseDelay, 5

F3::
autoSynthesis()

autoSynthesis() {
	While (ErrorLevel != 0)
	{
		imageSearch, x, y, 0, 0, 2560, 1440, *255, *TransBlack, synthesis_button.png
	}
	if(ErrorLevel=0){
		MouseMove, %x%, %y%
		Mouseclick, left, %x%, %y%
	}
}
