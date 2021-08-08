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

on _
end _

on menu_MouseDoubleupHandler displayView
   put the mouse_DoubleUp of displayView into hName
   put the mouse_Target of displayView into tObject
   put hKeyLine_Construct (hName, "M", tObject) into hKey
   --
   hKey_Edit hKey
end menu_MouseDoubleupHandler

on _
end _

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

on _
end _

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

on _
end _

on menu_TreeBehavior displayView   
   put the behavior of displayView into bObject
   edit the script of bObject
end menu_TreeBehavior

on menu_Toplevel displayView   
   put the stack_Name of displayView into stackName
   toplevel stack stackName
end menu_Toplevel

on menu_SortType displayView, treeSortType
   put the tree_Widget of displayView into treeWidget
   if exists (treeWidget) is false then return empty
   
   set the sortType of treeWidget to treeSortType
end menu_SortType

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu | Props
-
getprop menuStyle_Param [displayView]
   return the menu_Style of displayView
end menuStyle_Param

getprop menuStyle_Params
   return "Array,Old"
end menuStyle_Params


--> Dev | Menu
-
on menu_MenuStyle displayView, mStyle
   set the menu_Style of displayView to mStyle
end menu_MenuStyle

on menu_UpdateMenu displayView
   put the title_Menu of displayView into mTitle
   put the title_Controller of displayView into mController
   --
   set the menu_Update of mController to true
   --
   put merge ("Updated menu '[[mTitle]]' in case it needed one :)") into someComment
   lcw_Notify someComment
end menu_UpdateMenu

on menu_UpdateProjectMenus displayView
   put the title_Menu of displayView into mTitle
   put the title_Controller of displayView into mController
   --
   put the project_Name of mController into projectName
   put the project_Folder of mController into projectFolder
   --
   put merge ("Update and export all menus in the project '[[projectName]]'") into someQuestion
   lcw_Answer someQuestion, displayView
   --
   project_ExportMenusAndStackFiles projectFolder
   --
   put merge ("Updated all menus' in project '[[projectName]]'") into someComment
   lcw_Notify someComment
end menu_UpdateProjectMenus
