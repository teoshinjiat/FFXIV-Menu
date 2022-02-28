SetWorkingDir %A_ScriptDir%

global log:=true ; dont log to AHK Studio Log Window
global lineNumber:=1

 ; default log is verbose log, should log as much as i can about events
log(text, clear:=0, lineBreak:=1, sleep:=0, autoHide:=0, msgBox:=0, tag:="Verbose"){
	if(log){
		;DebugWindow(text,clear,lineBreak,sleep,autoHide)
		logToFile(text, tag) ;logToFile regardless of logFlag			
	}
}

; important log is unhideable log such as ERROR and DEBUG, therefore no checking like the base log()
logTag(text, tag){
	DebugWindow(text)
	logToFile(text, tag)
}

logToFile(text, tag){
	file := FileOpen("C:\ahk\FFXIV\ffxiv.log","a") ; https://www.autohotkey.com/docs/commands/FileOpen.htm#Access_modes
	file.write("[")		
	file.write(currentTimestamp())
	file.write("]|(")	
	file.write(tag)
	file.write(")|")	
	file.write(text)
	file.write("`r`n") ;CR+LF
	file.close()
	lineNumber++
}

archieveLogFile(){ ;used when terminating a script
	FileMove, C:\ahk\FFXIV\ffxiv.log, C:\ahk\FFXIV\ffxiv.log.old, 1
}



; TODO split non dependent functions, otherwise menu will have to import stuff that it dont needle
; for example searchImage
searchImage(pathAndFilename, x1:=0, x2:=0, y1:=2560, y2:=1440, variance:=1, GameID:="", log:=true){
	token := Gdip_Startup()
	if !pBitmap := Gdip_BitmapFromHWND(GameID)
	{
		logTag("Gdip_BitmapFromHWND fail", "ERROR")
		ExitApp
	}
	
	if Gdip_SaveBitmapToFile(pBitmap, img := A_ScriptDir "\screen.png")
	{
		logTag("Gdip_SaveBitmapToFile fail", "ERROR")
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
	
	; defaulted to always log, otherwise can false to turn off spammy logs, such as loop imageSearch
	; log true if found, otherwise its original error value, shown below
	
	if(log) {
		log("searchImage() Result for filename, " pathAndFilename ".png : " result) 		
	}
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

getLastHistoryPriceForItemFromRavana(itemID){ ;current world only
	;log("getPriceForItemApi()")
	oWhr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	endpoint:="https://universalis.app/api/history/ravana/" itemID "?entriesToReturn=800&entriesWithin=300000"
;	log("")	
	;log("endpoint: " endpoint)
	oWhr.Open("GET", endpoint, false)
	oWhr.SetRequestHeader("Content-Type", "application/json")
	oWhr.SetRequestHeader("Authorization", "Bearer 80b44ea9c302237f9178a137d9e86deb-20083fb12d9579469f24afa80816066b")
	oWhr.Send()
	obj := JSON.load(oWhr.ResponseText)	
	return getLastHistoryPrice(obj)
}

getLastHistoryPriceForItemFromDC(itemID){ ;DataCenter = all connected worlds
	;log("getPriceForItemApi()")
	oWhr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	endpoint:="https://universalis.app/api/history/materia/" itemID "?entriesWithin=100000"
	;log("")	
	;log("endpoint: " endpoint)
	oWhr.Open("GET", endpoint, false)
	oWhr.SetRequestHeader("Content-Type", "application/json")
	oWhr.SetRequestHeader("Authorization", "Bearer 80b44ea9c302237f9178a137d9e86deb-20083fb12d9579469f24afa80816066b")
	oWhr.Send()
	obj := JSON.load(oWhr.ResponseText)	
	return getLastHistoryPrice(obj)
}


getLastHistoryPrice(obj){
	lastSoldPrice:=""
	itemId:=""
	numberOfSales:=""
	for i, entries in obj.entries{ ;mainBox mainscript boxes
		if(i=1){
			itemID:= obj.itemID
			lastSoldPrice:=obj.entries[i].pricePerUnit
			numberOfSales:=obj.entries.length()
		}
	}
	return lastSoldPrice
}

; when crafting items, should buy mats from other worlds if they are cheaper
getFirstListingPriceForItemFromDC(itemID){
	;log("getPriceForItemApi()")
	oWhr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	endpoint:="https://universalis.app/api/materia/" itemID "?listings=1&entries=0"
	;log("")	
	;log("endpoint: " endpoint)
	oWhr.Open("GET", endpoint, false)
	oWhr.SetRequestHeader("Content-Type", "application/json")
	oWhr.SetRequestHeader("Authorization", "Bearer 80b44ea9c302237f9178a137d9e86deb-20083fb12d9579469f24afa80816066b")
	oWhr.Send()
	obj := JSON.load(oWhr.ResponseText)	
	log("itemID : " + itemID)
	return getFirstListingPrice(obj)
}

; when selling item, should look for the first item price on listing instead of history
getFirstListingPriceForHQItemFromRavana(itemID){
	;log("getPriceForItemApi()")
	oWhr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	endpoint:="https://universalis.app/api/ravana/" itemID "?listings=1&entries=0&hq=true"
	;log("")	
	;log("endpoint: " endpoint)
	oWhr.Open("GET", endpoint, false)
	oWhr.SetRequestHeader("Content-Type", "application/json")
	oWhr.SetRequestHeader("Authorization", "Bearer 80b44ea9c302237f9178a137d9e86deb-20083fb12d9579469f24afa80816066b")
	oWhr.Send()
	obj := JSON.load(oWhr.ResponseText)	
	log("itemID : " + itemID)
	return getFirstListingPrice(obj)
}

getFirstListingPrice(obj){
	log("@@@@@ obj.listings[1].pricePerUnit : " + obj.listings[1].pricePerUnit)
	return obj.listings[1].pricePerUnit
}

thousandsSeparator(x, s=",") {
	return RegExReplace(x, "\G\d+?(?=(\d{3})+(?:\D|$))", "$0" s)
}

; https://www.autohotkey.com/docs/commands/FormatTime.htm#Date_Formats
currentTimestamp(){
	FormatTime, TimeString, %A_Now%, hh:mm:ss tt
	return TimeString
}