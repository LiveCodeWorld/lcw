script "Global_Script_Changes_Menu"
--> MetaData
-
license: GPLv3
name: Global_Script_Changes_Menu
type: controller
version: 0.1


--> Global | Script | Changes | Menu
-
on menu_LoadServer
   server_LoadDetails "rest.livecode.world"
   display_RigControllerArray
end menu_LoadServer

on menu_SetMenus
   
end menu_SetMenus

on menu_DisplayLocalChanges indexView
   put the selected_Index of indexView into scriptObject
   
   put the script of scriptObject into nowScript
   put the exported_Script of scriptObject into exportedScript
   terminal_Diff exportedScript, nowScript, "the exported_Script of mTarget", "the script of mTarget"
end menu_DisplayLocalChanges

on menu_FilterForChanged indexView
   put the displayed_Index of indexView into scriptObjects
   repeat for each line scriptObject in scriptObjects
      if the script_IsDifferent of scriptObject is true then
         put scriptObject & CR after changedScriptObjects
      end if
   end repeat
   delete char -1 of changedScriptObjects
   set the displayed_Index of indexView to changedScriptObjects
end menu_FilterForChanged

on _
end _

on menu_DisplayRecentExports indexView, howLong
   display_RecentExports howLong, indexView
end menu_DisplayRecentExports


--> Global | Script | Changes | Menu | Props
-
getprop how_Longs
   return "5 min,10 min,20 min,30 min,300 min"
end how_Longs


--> Global | Script | Changes | Menu | Disabled
-
