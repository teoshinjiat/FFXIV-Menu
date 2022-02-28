Gui, Add, ListView, x6 y6 w380 h120 vLogbox LVS_REPORT, %A_Now%|Activity
 LV_ModifyCol(1, 100)
 Gui, Show, w400 h140, LVLogger
 settimer, FakeActivity, 500
Return

FakeActivity:
 updatelog("Stuff is happening...")
return

updatelog(LogString)
{
 rownumber := LV_Add("", A_Now, LogString) 
 LV_Modify(rownumber, "Vis") 
}


GuiClose:
ExitApp