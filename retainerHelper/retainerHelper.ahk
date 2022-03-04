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
global RETAINER_TAG:="Retainer"
global RETAINER_UNDERCUT_TAG:="Retainer Undercut"
;retainerIndex := Array(1, 2, 3, 4, 5, 6)
global retainerIndex := Array(1,2,3,4,5,6)
global currentRetainerIndex:=""
global isMyRetainers:=false
log("retainerIndex size : " + retainerIndex.MaxIndex())

Loop{
	for i in retainerIndex{
		index:=A_Index
		if(isRetainerWindowCurrentlyOnFocus()){
			log("Current retainer index : " i)
			undercut()
			logTag(RETAINER_TAG, "Done with number " index " retainer, going next..")		
			goNextRetainer(index)
		}
	}
}

goNextRetainer(currentRetainerIndex){
	Loop, % currentRetainerIndex {
		log("Looping : " + currentRetainerIndex)		
		ControlSend, , {Down}, ahk_class FFXIVGAME
		sleep, 500
	}
	;ControlSend, , ``, ahk_class FFXIVGAME
	sleep, 500
}

undercut(){
	enterRetainer()
	openMarketWindow()
	handleUndercutProcess()
	goBackRetainerList()
}

goBackRetainerList(){
	ControlSend, , {Esc}, ahk_class FFXIVGAME
	sleep, 500
	ControlSend, , {Esc}, ahk_class FFXIVGAME
	sleep, 500
}

handleUndercutProcess(){
	currentNumberOfListedItem:=getCurrentNumberOfListedItem()
	currentNumberOfListedItem:=currentNumberOfListedItem+0
	log("currentNumberOfListedItem : " currentNumberOfListedItem)
	Loop, % currentNumberOfListedItem { ; 20 is the maximum number of listed item, need to handle if it's not 20
		ClipSaved = ; free previous clipboard
		sleep, 500
		handleAdjustPrice()
		getMyPrice()
		getFirstListingPrice1()
		if(latestPrice!=""){
			;checkThreshold() ; check then list or cancel
		}
		resetVariables()
		goNextItem()
	}
}

goNextItem(){
	ControlSend, , {Down}, ahk_class FFXIVGAME
	sleep, 500
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
				latestPrice:=clipboard+1
				log("isMyRetainers : " + isMyRetainers)
				log("latestPrice : " + latestPrice)			
				clipboard:=""	
				isUndercutValid:=isUndercutValid()
				if(isUndercutValid){ ; if we should undercut, is it our retainer?
					if(!isMyRetainers()){
						proceedUndercutWithThreshold()
					} else {
						cancelUndercut()
					}
				} else {
					cancelUndercut()
				}
				break
			}
			sleep, 500		
		}
	}	
}

isUndercutValid(){	
	priceDiff:=myPrice-latestPrice
	myPriceUndercutThreshold:=Ceil(myPrice*undercutThreshold) ;always up rounded
	
	log("priceDiff : " priceDiff)
	log("myPriceUndercutThreshold : " myPriceUndercutThreshold)
	log("isMyRetainers : " isMyRetainers)
	if(!isMyRetainers && priceDiff >= 0){ ; if same price or someone undercuts me, proceed checking to see if it's worth the undercut, my threshold is 0.5% of my current price
		if(priceDiff > myPriceUndercutThreshold){
			logTag(RETAINER_TAG, "Current seller is selling way too low, not worth to undercut")
			;cancelUndercut()
			return false
		} else {
			logTag(RETAINER_TAG, "First listed item price is " latestPrice " gils, and the difference our listed price is just " priceDiff " gils - which falls below the undercut threshold of " myPriceUndercutThreshold " gils, so we should undercut this!")		
			;proceedUndercutWithThreshold()
			return true
		}
	}
	else {
		logTag(RETAINER_TAG, "Item is already the first listed item or first listed item is from my retainers")
		;cancelUndercut()
		return false		
	}
}

cancelUndercut(){ ; from adjust price window to Markets window
	log("cancelUndercut()")
	ControlSend, , {Esc}, ahk_class FFXIVGAME	
	sleep, 500
	ControlSend, , {Esc}, ahk_class FFXIVGAME	
	sleep, 500
}

proceedUndercutWithThreshold(){
	log("proceedUndercutWithThreshold()")
	ControlSend, , {Esc}, ahk_class FFXIVGAME 
	sleep, 500
	clickMyPrice()
	sleep, 500
	undercutPrice:=latestPrice-1  ; undercut the seller with just 1 gil	
	Clipboard:=undercutPrice
	; workaround: if no price is copied(because there is no HQ item), proceed pasting with the original clipboard(which is my original price)
	ControlSend, , ^v, ahk_class FFXIVGAME 
	sleep, 500
	ControlSend, , {Enter}, ahk_class FFXIVGAME 
	sleep, 500
	logTag(RETAINER_UNDERCUT_TAG, "Successfully undercut an item from seller, my listed item price from " myPrice " gils to below current selling price " latestPrice " gils. Final undercut price is " undercutPrice " gils")
	handleConfirmButton()
}

handleConfirmButton(){
	log("handleConfirmButton()")
	
	isConfirmButtonHighlighted:=false
	while(!isConfirmButtonHighlighted){
		isConfirmButtonHighlighted:=searchImage("images/button/confirm_button_highlighted",,,,,1, GameID)	
		log("imagesearch isConfirmButtonHighlighted : " + isConfirmButtonHighlighted)
		if(isConfirmButtonHighlighted){ ; if highlighted then send ` to press			
			ControlSend, , ``, ahk_class FFXIVGAME 
			log("Send confirm button")
		} else { ; keep navigating down
			ToolTip, , 1280, 720 ; center of the screen			
			ControlSend, , {Down}, ahk_class FFXIVGAME 
		}
		sleep, 500
	}
}


isMyRetainers(){
	; check if first listed item is from my retainer, if it is my retainer then dont undercut
	; aim is to not make my retainers suspicious because it will be undercutting other players constantly
	if(currentRetainerIndex!=1 && searchImage("images/retainer/firstRetainer",,,,,10, GameID)){
		return true
	} else if(currentRetainerIndex!=2 && searchImage("images/retainer/secondRetainer",,,,,10, GameID)){
		return true
	} else if(currentRetainerIndex!=3 && searchImage("images/retainer/thirdRetainer",,,,,10, GameID)){
		return true
	} else if(currentRetainerIndex!=4 && searchImage("images/retainer/fourthRetainer",,,,,10, GameID)){
		return true
	} else if(currentRetainerIndex!=5 && searchImage("images/retainer/fifthRetainer",,,,,10, GameID)){
		return true
	} else if(currentRetainerIndex!=6 && searchImage("images/retainer/sixthRetainer",,,,,10, GameID)){
		return true		
	} else {
		return false
	}
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
	log("attemptToRegainFocus()")	
	isFocused:=1
	while(isFocused=1){
		ImageSearch, foundX, foundY,0,0,2560,1440, *1 images\window\retainer_window_click_position.png
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

getCurrentNumberOfListedItem(){ ; search in reverse, because it's common to have higher number of selling item
	log("getCurrentNumberOfListedItem()")
	currentNumberOfListedItem:=""
	while(currentNumberOfListedItem=""){
		if(searchImage("images/number/20",,,,,5, GameID)){
			currentNumberOfListedItem:=20
		} else if(searchImage("images/number/19",,,,,5, GameID)){
			currentNumberOfListedItem:=19
		} else if(searchImage("images/number/18",,,,,5, GameID)){
			currentNumberOfListedItem:=18
		} else if(searchImage("images/number/17",,,,,5, GameID)){
			currentNumberOfListedItem:=17
		} else if(searchImage("images/number/16",,,,,5, GameID)){
			currentNumberOfListedItem:=16
		} else if(searchImage("images/number/15",,,,,5, GameID)){
			currentNumberOfListedItem:=15
		} else if(searchImage("images/number/14",,,,,5, GameID)){
			currentNumberOfListedItem:=14
		} else if(searchImage("images/number/13",,,,,5, GameID)){
			currentNumberOfListedItem:=13
		} else if(searchImage("images/number/12",,,,,5, GameID)){
			currentNumberOfListedItem:=12
		} else if(searchImage("images/number/11",,,,,5, GameID)){
			currentNumberOfListedItem:=11
		} else if(searchImage("images/number/10",,,,,5, GameID)){
			currentNumberOfListedItem:=10
		} else if(searchImage("images/number/9",,,,,5, GameID)){
			currentNumberOfListedItem:=9
		} else if(searchImage("images/number/8",,,,,5, GameID)){
			currentNumberOfListedItem:=8
		} else if(searchImage("images/number/7",,,,,5, GameID)){
			currentNumberOfListedItem:=7
		} else if(searchImage("images/number/6",,,,,5, GameID)){
			currentNumberOfListedItem:=6
		} else if(searchImage("images/number/5",,,,,5, GameID)){
			currentNumberOfListedItem:=5
		} else if(searchImage("images/number/4",,,,,5, GameID)){
			currentNumberOfListedItem:=4
		} else if(searchImage("images/number/3",,,,,5, GameID)){
			currentNumberOfListedItem:=3
		} else if(searchImage("images/number/2",,,,,5, GameID)){
			currentNumberOfListedItem:=2
		} else if(searchImage("images/number/1",,,,,5, GameID)){
			currentNumberOfListedItem:=1
		}
	}
	return currentNumberOfListedItem	
}

^F4::
log("Terminated Retainer Helper",0,1)
archieveLogFile()
ExitApp 
