script "Global | System | Drop | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | System | Drop | Line | Menu
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

on mouse_DoubleUp dView, droppedURL
   imagine_AddUrl droppedURL
end mouse_DoubleUp

private function _dView
   return LocalArray ["dView"]
end _dView

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | System | Drop | Line | Menu
-
on menu_SystemDropLine dView
   put the params
end menu_SystemDropLine

private on _
end _

on menu_Behavior dView
   put the behavior of dView into bObject
   edit the script of bObject
end menu_Behavior

on menu_ModuleTools dView
   put the view_Name of dView into viewName
   display_ModuleTools viewName
end menu_ModuleTools

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | System | Drop | Line | Menu")
end submenu_Dev
