Gui, Add, ListView, x6 y6 w380 h120 vLogbox LVS_REPORT, Item ID | Item Name| Last Known Price | #Sales Past 3 Day
LV_ModifyCol(1, 100)
Gui, Show, w400 h140, LVLogger
settimer, FakeActivity, 500
Return

FakeActivity:
updatelog("Stuff is happening...")
return

updatelog(LogString)
{
 global Logbox
 rownumber := LV_Add("", A_Now, LogString) 
 LV_Modify(rownumber, "Vis") 
}


GuiClose:
ExitApp

Gui, PriceListWindow:Default
Gui, PriceListWindow:+AlwaysOnTop
Gui, PriceListWindow:+resize
Gui, PriceListWindow:Add,Picture, x0 y0 w800 h188,gui.png
Gui, PriceListWindow:Color, 0x808080
Gui, PriceListWindow:Font, s10, Verdana
Gui, PriceListWindow:Font, bold
Gui, PriceListWindow:Add, ListView, r20 w800 gOnDoubleClick, Item ID | Item Name| Last Known Price | #Sales Past 3 Day
Gui, PriceListWindow:Add, Button, gGetMoreData, Show number of sales in the past 3 days ; will make 2 more api calls	

for i, subOptions in menuData[5].subOptions{
	log("priceListWindow menuData[5].subOptions[i].itemID : " + menuData[5].subOptions[i].itemID)
	LV_Add("", menuData[5].subOptions[i].itemID, menuData[5].subOptions[i].label, menuData[5].subOptions[i].price, menuData[5].subOptions[i].numberOfSalesPast1Day)
}

; https://www.autohotkey.com/docs/commands/ListView.htm#LV_ModifyCol for future reference
LV_ModifyCol(1,"AutoHdr")
LV_ModifyCol(2,"AutoHdr")
LV_ModifyCol(3,"AutoHdr")
LV_ModifyCol(3,"Integer")
LV_ModifyCol(3,"SortDesc") ; sort by price
LV_ModifyCol(4,"AutoHdr")