#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#include C:\Users\teosh\Desktop\ahk\lib\json\json.ahk	; Cococ's JSON lib

FileRead, var, items.json	; get JSON string
;msgbox % var				; show string

obj := JSON.load(var)		; load string into object
;msgbox % obj.statusCode "`n" obj.success "`n" obj.result.totalRecords
;msgbox % obj.items[2].id "`n"  obj.items[2].name
;msgbox % obj.result.items[2].id "`n"  obj.result.items[2].name



for i, items in obj.items{ ;mainBox mainscript boxes
	i:=A_Index
	DebugWindow("id:" obj.items[i].id " | name:" obj.items[i].name " | description:" obj.items[i].description,0,1,200,0)
	for j in obj.items[i].paths{ ;subBox options(parameters)
		j:=A_Index
		DebugWindow("category:" obj.items[i].paths[j].category " | subcategory:" obj.items[i].paths[j].subcategory " | filename:" obj.items[i].paths[j].filename,0,1,200,0)		
	}
}

/*
	DebugWindow("start", 0,1,0,0)
	
	FileRead jsonString, items.json
	Data := JSON.Load(jsonString)
	Orders := Data.Customers[0].Orders
	for each, Order in Orders
		DebugWindow("each:"each, 0,1,0,0)
	
;MsgBox % Order.BillingID ", " Order.Quantity ", " Order.Price
	
*/
/*
	;populating GUI menu
	for i, obj in menuData{ ;mainBox mainscript boxes
		function:=menuData[i].function
		value:=menuData[i].value
		label:=menuData[i].label
		Gui, Add, Checkbox, x25 %function% %value%, %label%
		for key, field in menuData[i].subOptions{ ;subBox options(parameters)
			value:=menuData[i].subOptions[key].value
			label:=menuData[i].subOptions[key].label
			subOptionGuiType:=menuData[i].subOptionGuiType
			subOptionGuiStyle:=menuData[i].subOptionGuiStyle		
			Gui, Add, %subOptionGuiType%, %subOptionGuiStyle% %value%, %label%
		;DebugWindow("Array: " i "`nKey: " key "`nAnimal: " animal,0,1,200,0)
		;Gui, Add, Checkbox, x25 menuData[]i.function menuData[i].value, menuData[i].label
		}
	}
*/