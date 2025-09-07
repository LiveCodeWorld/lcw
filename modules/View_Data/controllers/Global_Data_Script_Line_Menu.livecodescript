script "Global | Data | Script | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Data | Script | Line | Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into LocalArray ["dView"]
   put the displayed_Object of tObject into sObject
   return sObject
end menu_Target

private function _dView
   return LocalArray ["dView"]
end _dView

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | Data | Script | Line | Menu
-
on menu_DataScriptLine dView
   put the params
end menu_DataScriptLine

private on _
end _

on submenu_ModuleTools dView
   return "Global | Module | Tools | Line | Menu"
end submenu_ModuleTools

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Data | Script | Line | Menu")
end submenu_Dev
