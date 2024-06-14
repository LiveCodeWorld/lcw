script "Global | Array | Menu"
--> MetaData
-
license: GPLv3
name: Global | Array | Menu
type: controller
version: 0.7


--> Variables
-
local LocalArray


--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into dView
   return dView
end menu_Target

getprop sortType_Param [dView]
   put the tree_Widget of dView into treeWidget
   if exists (treeWidget) is false then return empty
   put the sortType of treeWidget into treeSortType
   return treeSortType
end sortType_Param

getprop sortType_Params
   return "numeric,text"
end sortType_Params

getprop stackStyle_Param [dView]
   put the stack_Style of dView into sStyle
   return sStyle
end stackStyle_Param

getprop stackStyle_Params
   return "toplevel,palette,system"
end stackStyle_Params

getprop checked_ShowNumbers [dView]
   return the show_Numbers of dView
end checked_ShowNumbers

getprop checked_ShowValues [dView]
   return the show_Values of dView
end checked_ShowValues


--> Global | Array | Menu
-
on menu_StackStyle dView, someStyle
   set the stack_Style of dView to someStyle
end menu_StackStyle

private on _
end _

on menu_MouseDoubleupHandler dView
   put the mouse_DoubleUp of dView into hName
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

on menu_SetMenu dView
   put the title_Menu of dView into mTitle
   put lcw_Ask ("What menu title do you want to attach to the tree_View?", mTitle) into mTitle
   set the title_Menu of dView to mTitle
end menu_SetMenu

on menu_CreateTitleMenu dView
   put the title_Menu of dView into mTitle
   put the project_Name of dView into projectName
   if projectName is empty then put "lcw_Tools" into projectName
   --
   put lcw_Ask ("Where would you like to create the menu [[var]]?", projectName, dView, mTitle) into projectName
   --
   ask_CreateProjectMenu projectName, mTitle
   put the result into mController
   
   # Edit the script
   if pDisplay is true then
      edit the script of mController
   end if
end menu_CreateTitleMenu

getprop disabled_CreateTitleMenu [dView]
   put the title_Menu of dView into mTitle
   -- put the menu_Controller [mTitle] of dView into mController
   put menu_GetGlobalController (mTitle) into mController
   return exists (mController)
end disabled_CreateTitleMenu
   
on menu_EditMenuScript dView
   put the title_Menu of dView into mTitle
   --
   menu_Edit mTitle
end menu_EditMenuScript

private on ___
end ___

on menu_SetLineMenu dView   
   put the line_Menu of dView into mTitle
   put lcw_Ask ("What line-menu do you want to attach to the tree_Field?", mTitle) into mTitle
   set the line_Menu of dView to mTitle
end menu_SetLineMenu

on menu_LineMenuScript dView
   put the line_Menu of dView into mTitle
   --
   menu_Edit mTitle
end menu_LineMenuScript

private on ____
end ____

on menu_ShowNumbers dView
   put the show_Numbers of dView into sBoolean
   set the show_Numbers of dView to (sBoolean is false)
end menu_ShowNumbers

on menu_ShowValues dView
   put the show_Values of dView into sBoolean
   set the show_Values of dView to (sBoolean is false)
end menu_ShowValues

on menu_FoldState dView
   put the fold_State of dView into fState
   display_Data fState, "fold_State", "Tree"
end menu_FoldState

on menu_SortType dView, treeSortType
   put the tree_Widget of dView into treeWidget
   if exists (treeWidget) is false then return empty
   
   set the sortType of treeWidget to treeSortType
end menu_SortType

private on _____
end _____

on menu_TreeBehavior dView   
   put the behavior of dView into bObject
   edit the script of bObject
end menu_TreeBehavior

on menu_TreeInspector dView
   display_ObjectProperties dView
end menu_TreeInspector

private on ______
end ______

on menu_DisplayModuleTools arrayView
   put the view_Name of arrayView into vName
   display_ModuleTools vName
end menu_DisplayModuleTools

on menu_DisplayTemplate arrayView
   put the view_Name of arrayView into vName
   put view_GetTemplateObject (vName) into tObject
   --
   object_GoTo tObject, true
end menu_DisplayTemplate

on submenu_Dev
   return menu_DevTitle()
end submenu_Dev
