script "Global | Tree | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Tree | Menu
type: controller
version: 0.1

/*
This menu is for displaying and manipulating array data (trees).
*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into dView
   put dView into LocalArray ["dView"]
   put the displayed_Object of tObject into treeView
   --
   return treeView
end menu_Target

getprop menu_CheckTarget [dView]
   put the tree_View of dView into treeView
   return exists (treeView)
end menu_CheckTarget


--> Global | Tree | Menu
-
on menu_ShowField treeView
   put the show_Field of treeView into sBoolean
   set the show_Field of treeView to (sBoolean is false)
end menu_ShowField

getprop checked_ShowField [treeView]
   put the show_Field of treeView into sBoolean
   return sBoolean
end checked_ShowField

on menu_ShowFooter treeView
   put the show_Footer of treeView into sBoolean
   set the show_Footer of treeView to (sBoolean is false)
end menu_ShowFooter

getprop checked_ShowFooter [treeView]
   put the show_Footer of treeView into sBoolean
   return sBoolean
end checked_ShowFooter

private on _
end _

on menu_TreeModuleFiles treeView
   put the module_Name of treeView into moduleName
   --
   put the card_ViewObject of stack moduleName into moduleViewObject
   put the module_Folder of stack moduleName into moduleFolder
   --
   put directory_NestedArray (moduleFolder) into dArray
   set the displayed_Data of treeView to dArray
   --
   set the displayed_Object of treeView to moduleViewObject
   set the displayed_ModuleFolder of treeView to moduleFolder
end menu_TreeModuleFiles

on menu_UpdateStyle treeView, sStyle
   breakpoint
   set the menuButton_UpdateStyle of treeView to sStyle
end menu_UpdateStyle

getprop updateStyle_Param [treeView]
   put the menuButton_UpdateStyle of treeView into sStyle
   return sStyle
end updateStyle_Param

getprop updateStyle_Params [treeView]
   return the menuButton_UpdateStyles of treeView
end updateStyle_Params

private on __
end __

on menu_MenuButtonHandlers treeView
   put the menu_Button of treeView into mButton
   put the behavior of mButton into bObject
   display_ScriptTools bObject
end menu_MenuButtonHandlers

on menu_MenuButtonBehavior treeView
   put the menu_Button of treeView into mButton
   --
   if _BehaviorIsSet(mButton) is true then
      put "ClearBehavior" && mButton into pigeon
      send pigeon to me in 2 ticks
   else
      put the name of stack "behavior_MenuButton" into bObject
      set the behavior of mButton to bObject
   end if
end menu_MenuButtonBehavior

on ClearBehavior sObject
   if exists (sObject) then
      set the behavior of sObject to empty
   end if
end ClearBehavior

getprop checked_MenuButtonBehavior [treeView]
   put the menu_Button of treeView into mButton
   return _BehaviorIsSet(mButton)
end checked_MenuButtonBehavior

on menu_MenuButtonScript treeView
   put the menu_Button of treeView into mButton
   edit the script of mButton
end menu_MenuButtonScript

private function _BehaviorIsSet sObject
   put the behavior of sObject into bObject
   if bObject is empty then
      return false
   else
      return true
   end if
end _BehaviorIsSet

private on ___
end ___

on menu_TreeBehavior treeView
   if _BehaviorIsSet(treeView) is true then
      put "ClearBehavior" && treeView into pigeon
      send pigeon to me in 2 ticks
   else
      put the name of stack "behavior_ViewTree" into bObject
      set the behavior of treeView to bObject
   end if
end menu_TreeBehavior

getprop checked_TreeBehavior [treeView]
   return _BehaviorIsSet(treeView)
end checked_TreeBehavior

on menu_EditTreeBehavior treeView
   put the behavior of treeView into bObject
   edit the script of bObject
end menu_EditTreeBehavior

on menu_TreeHandlers treeView
   put the behavior of treeView into bObject
   display_ScriptTools bObject
end menu_TreeHandlers

on menu_CardMargin treeView
   put the card_Margin of treeView into cMargin
   --
   put lcw_Ask ("Set teh card_Margin to...", cMargin, treeView) into cMargin
   --
   set the card_Margin of treeView to cMargin
end menu_CardMargin

on submenu_Dev
   return menu_DevTitle ("Global | Tree | Menu")
end submenu_Dev
