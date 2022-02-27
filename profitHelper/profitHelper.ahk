SetWorkingDir %A_ScriptDir%
#include ..\lib\json\json.ahk
#include ..\lib\utility\utility.ahk
#include ..\lib\gdip\Gdip_All.ahk
#include ..\lib\gdip\imageSearch\Gdip_ImageSearch.ahk

#SingleInstance, Force

log("Eulmore Turnin", clear:=1)

; 1) retrieve the item's last known price in my dc
; 2) 

;global items:=[{"itemID":"", "itemCraftable":"", "itemName":"", "itemLastKnownPrice":"", "materials":[]}] ;materials to store all itemId including parent id and child id
global itemsStruct:=[] ;materials to store all itemId including parent id and child id
global medicineStruct:=[]

;a, b, c(craftable)(show final product price, and show total craft cost), d , total cost, total craft cost including c

readItemsFromDB()

readItemsFromDB(){
	FileRead, var, ..\db\item_profit.json
	obj := JSON.load(var)
	;log(obj)
	
	for i, items in obj.items{ ;mainBox mainscript boxes
		log("----------------------------------------------------------------------------------------------------------------------------------------------------")		
		i:=A_Index
		log("itemID:" obj.items[i].itemID  " | isCraftable:" obj.items[i].isCraftable " | name:" obj.items[i].name " | description:" obj.items[i].description)
		itemsStruct[i]:= {category: obj.items[i].category, itemID: obj.items[i].itemID, name: obj.items[i].name, itemCraftable: obj.items[i].isCraftable, mainRecipeMaterials:[], subRecipeMaterials:[], lastKnownPrice:"", totalCraftingCostMainOnly:"", totalCraftingCostIncludingSub:"", profitExpectedPerCraft:""}
		;log("size of array recipeMaterials: " + obj.items[i].recipeMaterials.length())
		
		for j, recipeMaterials in obj.items[i].mainRecipeMaterials{ ; main recipe materials
			j:=A_Index
		;	log("recipe materials : itemID:" obj.items[i].recipeMaterials[j].itemID " | quantity:" obj.items[i].recipeMaterials[j].quantity " | name:" obj.items[i].recipeMaterials[j].name " | isCraftable:" obj.items[i].recipeMaterials[j].isCraftable)
			;log("obj.items[i].mainRecipeMaterials[j].itemID : " + obj.items[i].mainRecipeMaterials[j].itemID)
			itemsStruct[i].mainRecipeMaterials[j]:={itemID:obj.items[i].mainRecipeMaterials[j].itemID, quantity:obj.items[i].mainRecipeMaterials[j].quantity, isCraftable:obj.items[i].mainRecipeMaterials[j].isCraftable}
			;log("items[i].mainRecipeMaterials size : " + items[i].mainRecipeMaterials.length())
			;log("items[" i "] main recipe materia : " + items[i].mainRecipeMaterials[j])
			if(obj.items[i].mainRecipeMaterials[j].isCraftable=1){ ; this is sub recipe materials
				;log("size of array subRecipeMaterials: " + obj.items[i].recipeMaterials[j].subRecipeMaterials.length())
				for k, subRecipeMaterials in obj.items[i].mainRecipeMaterials[j].subRecipeMaterials{	
					k:=A_Index
					itemsStruct[i].subRecipeMaterials[k]:= {itemID:obj.items[i].mainRecipeMaterials[j].subRecipeMaterials[k].itemID, quantity:obj.items[i].mainRecipeMaterials[j].subRecipeMaterials[k].quantity}
					
					;log("items[i] sub recipe materia : " + items[i].subRecipeMaterials[k])
					;log("--SUB recipe materials : itemID:" obj.items[i].mainRecipeMaterials[j].subRecipeMaterials[k].itemID " | quantity:" obj.items[i].mainRecipeMaterials[j].subRecipeMaterials[k].quantity " | name:" obj.items[i].mainRecipeMaterials[j].subRecipeMaterials[k].name)				
				}
			}
			
		}
	}
	
	showData()
	;splitDataIntoCategories()
	;getSellingPriceFromRavana()
	;getTotalCraftingCost()
	
	/*
	for i in itemsStruct{
		log(itemsStruct[i].name " crafting cost main only is, " itemsStruct[i].totalCraftingCostMainOnly " gils")
		log(itemsStruct[i].name " crafting cost including sub is, " itemsStruct[i].totalCraftingCostIncludingSub " gils")
	}
	*/
}

getSellingPriceFromRavana(){
	for i in itemsStruct{ 
		i:=A_Index
		lastKnownPrice:=getPriceForItemApiFromRavana(itemsStruct[i].itemID)
		itemsStruct[i].lastKnownPrice:=lastKnownPrice
		if(itemsStruct[i].category="medicine"){
			itemsStruct[i].profitExpectedPerCraft:=lastKnownPrice*3			
		} else {
			itemsStruct[i].profitExpectedPerCraft:=lastKnownPrice			
		}
		
		log("profitExpectedPerCraft(): Ravana profitExpectedPerCraft * 3 : " + itemsStruct[i].profitExpectedPerCraft " gils")
	}
}

getTotalCraftingCost() {
	for i in itemsStruct{
		mainCost:=0
		subCost:=0
		
		i:=A_Index
		;log("ravana finalProductPrice : " + itemsStruct[i].lastKnownPrice " gils")
		for j, itemID in itemsStruct[i].mainRecipeMaterials{ 
			j:=A_Index
			lastSoldPriceWithQuantity:=(getPriceForItemApiFromDC(itemsStruct[i].mainRecipeMaterials[j].itemID) * itemsStruct[i].mainRecipeMaterials[j].quantity)
			mainCost:=mainCost + lastSoldPriceWithQuantity
			subCost:=subCost + lastSoldPriceWithQuantity
			;log(itemsStruct[i].name "'s mainCost : " + mainCost " gils")
			;log("itemsStruct[i].mainRecipeMaterials[j].isCraftable : " + itemsStruct[i].mainRecipeMaterials[j].isCraftable)
			log(itemsStruct[i].name "'s subCost : " + subCost)
			if(itemsStruct[i].mainRecipeMaterials[j].isCraftable){
				log("isCraftable?")
				subCost:=subCost-lastSoldPriceWithQuantity ; delete the craftable item for this variable
				log("lastSoldPriceWithQuantity : " + lastSoldPriceWithQuantity)
				log(itemsStruct[i].name "'s subCost : " + subCost)
				
				for k, itemID in itemsStruct[i].mainRecipeMaterials[j].subRecipeMaterials{ 
					log("should log 4 and 2 times")
					k:=A_Index
					;log("itemsStruct[i].mainRecipeMaterials[j].subRecipeMaterials[k].itemID) : " + itemsStruct[i].mainRecipeMaterials[j].subRecipeMaterials[k].itemID)
					lastSoldPriceWithQuantity:=(getPriceForItemApiFromDC(itemsStruct[i].mainRecipeMaterials[j].subRecipeMaterials[k].itemID) * itemsStruct[i].mainRecipeMaterials[j].subRecipeMaterials[k].quantity)
					subCost:=subCost + lastSoldPriceWithQuantity
				}
			}
		}
		itemsStruct[i].totalCraftingCostMainOnly:=mainCost
		itemsStruct[i].totalCraftingCostIncludingSub:=subCost
		
	}
}

splitDataIntoCategories(){
	for i in itemsStruct{ 
		i:=A_Index
		if(itemsStruct[i].category="medicine"){
			medicineStruct.push(itemsStruct[i])
		}
	}
}

showData(){
	for i in itemsStruct{ 
		i:=A_Index
		for j, itemID in itemsStruct[i].mainRecipeMaterials{ 
			j:=A_Index
			log("main:" itemsStruct[i].name " : " itemsStruct[i].mainRecipeMaterials[j].itemID " | quantity : " itemsStruct[i].mainRecipeMaterials[j].quantity)
			if(itemsStruct[i].mainRecipeMaterials[k].isCraftable){
				log("isCraftable true")
			}
		}
	}
	
	for i in itemsStruct{ 
		i:=A_Index
		for j, itemID in itemsStruct[i].subRecipeMaterials{ 
			j:=A_Index
			;log("sub:" itemsStruct[i].name " : " itemsStruct[i].subRecipeMaterials[j].itemID " | quantity : " itemsStruct[i].subRecipeMaterials[j].quantity)
		}
	}
	
}

/*
	PriceListWindow:
	Gui, PriceListWindow:Default
	Gui, PriceListWindow:+AlwaysOnTop
	Gui, PriceListWindow:+resize
	Gui, PriceListWindow:Color, 0x808080
	Gui, PriceListWindow:Font, s10, Verdana
	Gui, PriceListWindow:Font, bold
	Gui, PriceListWindow:Add, ListView, r20 w1800 LV0x400000 gOnDoubleClick, Item Name| Last Known Price | Total Crafting Cost
	
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
	
	Gui, PriceListWindow:Show
	return
	
	GetMoreData:
	return
	
; to select the listbox in the first gui window
	OnDoubleClick:
	if (A_GuiEvent = "DoubleClick")
	{
		LV_GetText(ItemID, A_EventInfo)
		selectedItemID:=ItemID
		log("double clicked row number " %A_EventInfo% ", ItemID: " %ItemID%)
		Gui, Destroy
	}
	return
	
	PriceListWindowButtonCancel:
	PriceListWindowGuiClose:
	PriceListWindowGuiEscape:
	Gui, Menu:Destroy
	ExitApp
*/