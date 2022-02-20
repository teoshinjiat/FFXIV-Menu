if(ErrorLevel=0){
	DebugWindow("Coordinates found at x:" %x% ", y:" %y%",0,1,0,0)
} else if(ErrorLevel=1){
	DebugWindow("Not found", 0,1,0,0)
} else {
	DebugWindow("Could not conduct search", 0,1,0,0)	
}