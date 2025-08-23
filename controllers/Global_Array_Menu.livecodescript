script "Global | Array | Menu"
--> MetaData
-
license: GPLv3
name: Global | Array | Menu
type: controller
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

getprop checked_DefaultTitle [dView]
   put the title_Menu of dView into mTitle
   get the default_MenuTitle of dView
   return it = dView
end checked_DefaultTitle

getprop disabled_CreateTitleMenu [dView]
   put the title_Menu of dView into mTitle
   -- put the menu_Controller [mTitle] of dView into mController
   put menu_GetGlobalController (mTitle) into mController
   return exists (mController)
end disabled_CreateTitleMenu

getprop checked_ShowField [dView]
   put the show_Field  of dView into sBoolean
   return sBoolean
end checked_ShowField

getprop checked_ShowFooter [dView]
   put the footer_IsVisible of dView into sBoolean
   return sBoolean
end checked_ShowFooter

getprop checked_ShowNumbers [dView]
   return the show_Numbers of dView
end checked_ShowNumbers

getprop checked_ShowValues [dView]
   return the show_Values of dView
end checked_ShowValues


--> Global | Array | Menu
-
on menu_MouseDoubleupHandler dView
   put the doubleClick_Message of dView into hName
   put the mouse_Target of dView into tObject
   put hKeyLine_Construct (hName, "M", tObject) into hKey
   --
   hKey_Edit hKey
end menu_MouseDoubleupHandler

on menu_SetDropCommand dView
   put the drop_Command of dView into dropCommand
   put lcw_Ask ("Set the drop_Command...", dropCommand, "Drop Command", dView) into dropCommand
   set the drop_Command of dView to dropCommand
end menu_SetDropCommand

private on __
end __

private on _____
end _____

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

private on ______
end ______

on menu_TreeBehavior dView   
   put the behavior of dView into bObject
   edit the script of bObject
end menu_TreeBehavior

on menu_TreeInspector dView
   display_ObjectProperties dView
end menu_TreeInspector

on menu_TreeStackInspector dView
   put the stack_Object of dView into stackObject
   display_ObjectProperties stackObject
end menu_TreeStackInspector

private on ______
end ______

on menu_InspectTemplate dView
   put the template_Object of dView into tObject
   object_GoTo tObject, false
   --
   put the behavior of tObject into bObject
   edit the script of bObject
   --
   put the stack_Name of me into mStackName
   display_ModuleTools mStackName
end menu_InspectTemplate


