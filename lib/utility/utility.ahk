log(text, clear:=0, lineBreak:=1, sleep:=0, autoHide:=0, msgBox:=0){
	DebugWindow(text,clear,lineBreak,sleep,autoHide, msgBox)
}

searchImage(pathAndFilename, x1:=0, x2:=0, y1:=2560, y2:=1440, variance:=1, GameID:="a"){
	token := Gdip_Startup()
	if !pBitmap := Gdip_BitmapFromHWND(GameID)
	{
		log("Gdip_BitmapFromHWND fail")
		ExitApp
	}
	
	if Gdip_SaveBitmapToFile(pBitmap, img := A_ScriptDir "\screen.png")
	{
		log("Gdip_SaveBitmapToFile fail")
		ExitApp
	}
	haystack:=Gdip_CreateBitmapFromFile("screen.png")
	
	needleFilename:=pathAndFilename ".png"
	needlePath:=A_ScriptDir "\" needleFilename
	needle:=Gdip_CreateBitmapFromFile(needlePath)
	result:=Gdip_ImageSearch(haystack,needle,LIST,x1,x2,y1,y2,variance,0,1,0)
	Gdip_DisposeImage(haystack)
	Gdip_DisposeImage(needle)
	Gdip_Shutdown(token)	
	log("result for filename, " pathAndFilename ".png : " result)
	
; ++ RETURN VALUES ++
;
; -1001 ==> invalid haystack and/or needle bitmap pointer
; -1002 ==> invalid variation value
; -1003 ==> X1 and Y1 cannot be negative
; -1004 ==> unable to lock haystack bitmap bits
; -1005 ==> unable to lock needle bitmap bits
; any non-negative value ==> the number of instances found
;
	return result > 0 ? true : false ; remap results for better readability, but will still log result here because the original return values are useful
}

Rnd(a=0.0,b=1) {
	IfEqual,a,,Random,,% r := b = 1 ? Rnd(0,0xFFFFFFFF) : b ;%
	Else Random,r,a,b
		Return r
}