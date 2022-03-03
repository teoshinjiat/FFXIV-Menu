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
log("Started Retainer Helper", 1)
global GameID:=GameID
global undercutThreshold=0.05 ;if first listed price is undercut more than 5% of my asking price

global myPrice:=""
global latestPrice:=""

;retainerIndex := Array(1, 2, 3, 4, 5, 6)
retainerIndex := Array(1)

log(retainerIndex.size)
for i in retainerIndex{
	if(isRetainerWindowCurrentlyOnFocus()){
		log("i : " + i)
		undercut()
	}
}

undercut(){
	enterRetainer()
	openMarketWindow()
	handleUndercutProcess()
}

handleUndercutProcess(){
	loop, 20 { ; 20 is the maximum number of listed item, need to handle if it's not 20
		ClipSaved = ; free previous clipboard
		
		handleAdjustPrice()
		getMyPrice()
		getFirstListingPrice1()
		if(latestPrice!=""){
			checkThreshold() ; check then list or cancel
		}
		resetVariables()
		goNextItem()
	}
}

goNextItem(){
	ControlSend, , {Down}, ahk_class FFXIVGAME
	sleep, 500
}

checkThreshold(){	
	log("latestPrice-myPrice : " (myPrice-latestPrice))
	log("myPrice * undercutThreshold : " (myPrice * undercutThreshold))
	log("latestPrice-myPrice > myPrice * undercutThreshold : "  (myPrice-latestPrice) > (myPrice * undercutThreshold))
	if((myPrice-latestPrice) > (myPrice * undercutThreshold)){
		log("current seller is selling way too low, not worth to undercut")
		cancelUndercut()
	} else {
		log("current seller is listed price is below my undercutting threshold which is " Ceil(undercutThreshold*100) "%")		
		proceedUndercutWithThreshold()
	}
}

cancelUndercut(){ ; from adjust price window to Markets window
	log("cancelUndercut()")
	ControlSend, , {Esc}, ahk_class FFXIVGAME	
	sleep, 500
}

proceedUndercutWithThreshold(){
	log("proceedUndercutWithThreshold()")
	clickMyPrice()
	; workaround: if no price is copied(because there is no HQ item), proceed pasting with the original clipboard(which is my original price)
	ControlSend, , ^v, ahk_class FFXIVGAME 
	sleep, 500
	ControlSend, , {Enter}, ahk_class FFXIVGAME 
	sleep, 500
}

handleConfirmButton(){
	isConfirmButtonHighlighted:=false
	if(!isConfirmButtonHighlighted){
		isConfirmButtonHighlighted:=searchImage("images/button/confirm_button_highlighted",,,,,5, GameID)	
		if(isConfirmButtonHighlighted){ ; if highlighted then send ` to press
			ControlSend, , {Down}, ahk_class FFXIVGAME 
		} else { ; keep navigating down
			ControlSend, , {Down}, ahk_class FFXIVGAME 
		}
		sleep, 500
	}
	
}


resetVariables(){
	myPrice:=""
	latestPrice:=""
}

getMyPrice(){
	myPrice:=""
	while(myPrice=""){
		clickMyPrice()
		ControlSend, , ^a, ahk_class FFXIVGAME
		sleep, 500
		
		ControlSend, , ^c, ahk_class FFXIVGAME
		sleep, 500
		ClipSaved = ""; free previous clipboard
		
		myPrice:=clipboard
		clipboard:=""
		log("myPrice : " + myPrice)
	}
}

clickMyPrice(){
	MouseClick, left, 668, 625
	sleep, 500
}

getFirstListingPrice1(){
	log("getFirstListingPrice1()")
	navigateToComparePriceButton()
	isLatestPriceCopied()
	sleep, 500
}

isLatestPriceCopied(){
	cancelFlag:=0
	while(latestPrice=""){
		isHitsFound:=false
		while(!isHitsFound){
			log("send ``")
			ControlSend, , ``, ahk_class FFXIVGAME ; entering compare price
			sleep, 500
			
			isHitsFound:=searchImage("images/indicator/hits_found",,,,,5, GameID)	
			sleep, 1000	
			log("isHitsFound : " + isHitsFound)
			if(!isHitsFound){ ; if not found, escape to close search results window, reenter to look for hits indicator again
				ControlSend, , {Esc}, ahk_class FFXIVGAME
			} else{
				latestPrice:=clipboard
				log("latestPrice : " + latestPrice)
				clipboard:=""	
				break
			}
			sleep, 500		
			cancelFlag++
		}
	}	
	ControlSend, , {Esc}, ahk_class FFXIVGAME	
}

closeWindow(){
	isSearchResultWindowExist:=true
	
	while(isSearchResultWindowExist){
		ControlSend, , {Esc}, ahk_class FFXIVGAME		
		isSearchResultWindowExist:=searchImage("images/indicator/latest_price_copied",,,,,1, GameID)	
	}
}

navigateToComparePriceButton(){
	ControlSend, , {Esc}, ahk_class FFXIVGAME ; exit edit asking price
	sleep, 500
	ControlSend, , {Up}, ahk_class FFXIVGAME ; 
	sleep, 500
	ControlSend, , {Up}, ahk_class FFXIVGAME ; reach compare price button
	sleep, 500
}

handleAdjustPrice(){
	log("handleAdjustPrice()")
	isAdjustPriceWindowHighlighted:=false
	while(!isAdjustPriceWindowHighlighted){
		isAdjustPriceWindowHighlighted:=searchImage("images/indicator/adjust_price_window",,,,,2, GameID)
		sleep, 200
		log("isAdjustPriceWindowHighlighted : " + isAdjustPriceWindowHighlighted)
		if(!isAdjustPriceWindowHighlighted){
			ControlSend, , ``, ahk_class FFXIVGAME
			sleep, 200
		}
	}
	
}



enterRetainer(){
	if(i=1){
		; first one always just send `
		ControlSend, , ``, ahk_class FFXIVGAME
		sleep, 500
	} else {
		sleep, 500
		ControlSend, , {Down}, ahk_class FFXIVGAME
		sleep, 500
		ControlSend, , ``, ahk_class FFXIVGAME
		sleep, 500		
	}
}

openMarketWindow(){
	isMarketSelected:=false
	while(!isMarketSelected){
		isMarketSelected:=searchImage("images/indicator/retainer_menu_market_selected",,,,,5, GameID)
		if(!isMarketSelected){
			ControlSend, , {Down}, ahk_class FFXIVGAME
			sleep, 100
		} else {
			ControlSend, , ``, ahk_class FFXIVGAME
			sleep, 100
		}
	}
	
}

isRetainerWindowCurrentlyOnFocus(){
	isRetainerWindowCurrentlyOnFocus:=false
	while(!isRetainerWindowCurrentlyOnFocus){
		isRetainerWindowCurrentlyOnFocus:=searchImage("images/indicator/retainer_window_focus_indicator",,,,,1, GameID)
		if(!isRetainerWindowCurrentlyOnFocus){
			attemptToRegainFocus()
		}
	}
	return isRetainerWindowCurrentlyOnFocus
}

; fallback
attemptToRegainFocus(){ ; this will force mousemovement to the game because controlclick does not work for the game, worth the downside
	isFocused:=1
	while(isFocused=1){
		log("attemptToRegainFocus()")
		;imageSearch, x, y, 0, 164, 490, 641, *30, *TransBlack, elderNutmeg.png
		
		;Run % "images/window/retainer_window_click_position.png"
		log("before()")
		
		ImageSearch, foundX, foundY,0,0,2560,1440, *1 images\window\retainer_window_click_position.png
		log("after()")
		
		isFocused:=ErrorLevel
		if(isFocused=0){
			log("ErrorLevel:" ErrorLevel)
			log("foundX : " + foundX)
			log("foundY : " + foundY)
			MouseClick, left, %foundX%, %foundY%
			sleep, 1000
			break
		}
	}
}


^F4::
log("Terminated Retainer Helper",0,1)
archieveLogFile()
ExitApp 
