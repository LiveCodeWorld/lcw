script "Global | Data | Stack | Menu"
--> MetaData
-
license: GPLv3
name: Global | Data | Stack | Menu
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
   put the data_View of tObject into dView
   return dView
end menu_Target

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget

private function _dView
   return LocalArray ["dView"]
end _dView

getprop cardMargin_Param [dView]
   get the card_Margin of dView
   switch it
      case empty
         return 0
      default
         return it
   end switch
end cardMargin_Param

getprop cardMargin_Params
   return "0,4,8,24,-,Ask"
end cardMargin_Params

getprop checked_SystemWindow [dView]
   put the stack_Name of dView into sName
   return the systemwindow of stack sName
end checked_SystemWindow

getprop stackStyle_Param [dView]
   put the stack_Style of dView into sStyle
   return sStyle
end stackStyle_Param

getprop stackStyle_Params
   return "toplevel,palette,-,system"
end stackStyle_Params

getprop stackRect_Params
   return "Height,Width,Rect,-,Top Left"
end stackRect_Params


--> Global | Data | Stack | Menu
-
on menu_Clone dView
   put the stack_Name of dView into moduleName
   --
   module_Clone moduleName, true
end menu_Clone

on menu_ToggleOthers dView
   put the stack_Name of dView into sName
   --
   put display_GetHidden() is empty into sBoolean
   display_SetHidden sBoolean, sName
end menu_ToggleOthers

getprop checked_ToggleOthers
   put display_GetHidden() is empty into sBoolean
   return sBoolean is false
end checked_ToggleOthers

private on _
end _

on menu_StackStyle dView, sStyle
   set the stack_Style of dView to sStyle
end menu_StackStyle

on menu_CardMargin dView, sMargin
   if sMargin = "Ask" then
      put the card_Margin of dView into sMargin
      put "Set the card_Margin..." into sQuestion
      put lcw_Ask (sQuestion, sMargin, dView) into sMargin
   end if
   
   set the card_Margin of dView to sMargin
end menu_CardMargin

on menu_StackRect dView, fHow
   if fHow = "Top Left" then
      put the formatted_Rect ["200,200"] of dView into sRect
   else
      put the stack_Rect [fHow] of dView into sRect
   end if
   --
   put the stack_Name of dView into sName
   set the rect of stack sName to sRect
end menu_StackRect

private on __
end __

on submenu_Dev
   return "Global | Data | Stack | Menu"
end submenu_Dev
