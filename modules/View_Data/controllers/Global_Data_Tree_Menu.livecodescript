script "Global | Data | Tree | Menu"
--> MetaData
-
license: GPLv3
name: Global | Data | Tree | Menu
type: controller
author: David Bovill
version: 0.7

/*
This is the orginal menu for the tree array viewer
Now mving it to a local mmenu for the View|Data module.
*/

--> Variables
-
local LocalArray


--> Menu | Props
-
getprop menu_Target [tObject]
   put the tree_View of tObject into treeView
   if exists (treeView) is false then return empty
   
   put the tree_Widget of treeView into treeWidget
   return treeView
end menu_Target

getprop menu_CheckTarget [treeView]
   return exists (treeView)
end menu_CheckTarget

getprop sortType_Param [dView]
   put the tree_Widget of dView into treeWidget
   if exists (treeWidget) is false then return empty
   put the sortType of treeWidget into treeSortType
   return treeSortType
end sortType_Param

getprop sortType_Params
   return "numeric,text"
end sortType_Params

getprop checked_ShowNumbers [dView]
   return the show_Numbers of dView
end checked_ShowNumbers

getprop checked_ShowValues [dView]
   return the show_Values of dView
end checked_ShowValues


--> Global | Data | Tree | Menu
-
on menu_ShowNumbers dView
   put the show_Numbers of dView into sBoolean
   set the show_Numbers of dView to (sBoolean is false)
end menu_ShowNumbers

on menu_ShowValues dView
   put the show_Values of dView into sBoolean
   set the show_Values of dView to (sBoolean is false)
end menu_ShowValues

on menu_SortType dView, treeSortType
   put the tree_Widget of dView into treeWidget
   if exists (treeWidget) is false then return empty
   
   set the sortType of treeWidget to treeSortType
end menu_SortType

private on _
end _

on menu_DoubleupClickHandler treeView
   put the doubleClick_Message of treeView into hName
   put the mouse_Target of treeView into tObject
   put hKeyLine_Construct (hName, "M", tObject) into hKey
   --
   hKey_Edit hKey
end menu_DoubleupClickHandler

getprop checked_DoubleupClickHandler [treeView]
   put the doubleClick_Message of treeView into mDoubleUp
   put the mouse_Target of treeView into tObject
   --
   put the hkey_Commands of tObject into hCommands
   put mDoubleUp is among the lines of hCommands into sBoolean
   return sBoolean
end checked_DoubleupClickHandler

on menu_ChangeDoubleClick treeView
   put the doubleClick_Message of treeView into mDoubleUp
   put lcw_Ask ("Edit the doubleClick_Message of indexView", mDoubleUp) into mDoubleUp
   --
   set the doubleClick_Message of treeView to mDoubleUp
end menu_ChangeDoubleClick

on menu_SetDropCommand dView
   put the drop_Command of dView into dropCommand
   put lcw_Ask ("Set the drop_Command...", dropCommand, "Drop Command", dView) into dropCommand
   set the drop_Command of dView to dropCommand
end menu_SetDropCommand

private on __
end __

on menu_TreeInspector treeView
   revIDEInspectObjects treeView
end menu_TreeInspector

on menu_TreeStackInspector treeView
   put the stack_Object of treeView into stackObject
   revIDEInspectObjects stackObject
end menu_TreeStackInspector

private on ___
end ___

on menu_TreeBehavior dView   
   put the behavior of dView into bObject
   edit the script of bObject
end menu_TreeBehavior

on submenu_Dev
   return "Global | Data | Tree | Menu"
end submenu_Dev
