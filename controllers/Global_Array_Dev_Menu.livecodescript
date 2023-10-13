script "Global | Array | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Array | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop menu_IsSimple
   return true
end menu_IsSimple


--> Global | Array | Dev | Menu
-
on menu_Behavior displayView
   put the behavior of displayView into bObject
   edit the script of bObject
end menu_Behavior

private on _
end _

on menu_MenuEdit displayView
   menu_Edit "Global | Array | Dev | Menu"
end menu_MenuEdit
