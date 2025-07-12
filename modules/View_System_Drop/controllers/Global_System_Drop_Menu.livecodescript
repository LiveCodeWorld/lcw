script "Global | System | Drop | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | System | Drop | Menu
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


--> Global | System | Drop | Menu
-
on menu_SystemDrop dView
   put the params
end menu_SystemDrop

private on _
end _

on menu_SystemWindow dView
   put the stack_Name of dView into sName
   put the systemwindow of stack sName into sBoolean
   set the systemwindow of stack sName to (sBoolean is false)
end menu_SystemWindow

getprop checked_SystemWindow [dView]
   put the stack_Name of dView into sName
   put the systemwindow of stack sName into sBoolean
   return sBoolean
end checked_SystemWindow

on menu_ClearIndex dView
   set the displayed_Index of dView to empty
end menu_ClearIndex

on menu_SaveStack dView
   put the stack_Name of dView into sName
   lcw_Answer "Save stack '[[sName]]'?", dView, sName
   --
   save stack sName
end menu_SaveStack

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | System | Drop | Menu")
end submenu_Dev
