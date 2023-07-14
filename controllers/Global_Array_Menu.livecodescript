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
   put the display_View of tObject into displayView
   return displayView
end menu_Target

getprop sortType_Param [displayView]
   put the tree_Widget of displayView into treeWidget
   if exists (treeWidget) is false then return empty
   put the sortType of treeWidget into treeSortType
   return treeSortType
end sortType_Param

getprop sortType_Params
   return "numeric,text"
end sortType_Params

getprop stackStyle_Param [displayView]
   put the stack_Style of displayView into sStyle
   return sStyle
end stackStyle_Param

getprop stackStyle_Params
   return "toplevel,palette,system"
end stackStyle_Params


--> Global | Array | Menu
-
on menu_StackStyle displayView, someStyle
   set the stack_Style of displayView to someStyle
end menu_StackStyle

private on _
end _

on menu_MouseDoubleupHandler displayView
   put the mouse_DoubleUp of displayView into hName
   put the mouse_Target of displayView into tObject
   put hKeyLine_Construct (hName, "M", tObject) into hKey
   --
   hKey_Edit hKey
end menu_MouseDoubleupHandler

private on __
end __

on menu_SetTitleMenu displayView
   put the title_Menu of displayView into mTitle
   put lcw_Ask ("What menu title do you want to attach to the tree_View?", mTitle) into mTitle
   set the title_Menu of displayView to mTitle
end menu_SetTitleMenu

on menu_EditTitleMenu displayView
   put the title_Menu of displayView into mTitle
   --
   menu_Edit mTitle
end menu_EditTitleMenu

private on ___
end ___

on menu_SetLineMenu displayView   
   put the line_Menu of displayView into mTitle
   put lcw_Ask ("What line-menu do you want to attach to the tree_Field?", mTitle) into mTitle
   set the line_Menu of displayView to mTitle
end menu_SetLineMenu

on menu_EditLineMenu displayView
   put the line_Menu of displayView into mTitle
   --
   menu_Edit mTitle
end menu_EditLineMenu

private on ____
end ____

on menu_TreeBehavior displayView   
   put the behavior of displayView into bObject
   edit the script of bObject
end menu_TreeBehavior

on menu_FoldState displayView   
   put the fold_State of displayView into fState
   display_Data fState, "fold_State", "Tree"
end menu_FoldState

on menu_SortType displayView, treeSortType
   put the tree_Widget of displayView into treeWidget
   if exists (treeWidget) is false then return empty
   
   set the sortType of treeWidget to treeSortType
end menu_SortType
