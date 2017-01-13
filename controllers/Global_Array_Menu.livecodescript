script "Global_Array_Menu"
--> MetaData
-
license: GPLv3
name: Global_Array_Menu
type: controller
version: 0.7

--> Variables
-
local LocalArray


--> Menu | Props
-
on menu_Init tObject
   put the array_View of tObject into LocalArray ["arrayView"]
end menu_Init



--> Global | Array | Menu
-
/*
Menus in behaviors are a bit odd - as "me" does not work
*/

on menu_TestArray
   put LocalArray ["arrayView"] into arrayView
   put the tree_Widget of arrayView into treeWidget
   _displaySelectedValue treeWidget
end menu_TestArray

on menu_SetMenuTitle mTarget
   put LocalArray ["arrayView"] into arrayView
   
   put the title_Menu of arrayView into mTitle
   put lcw_Ask ("What menu title do you want to attach to the tree_View?", mTitle) into mTitle
   set the title_Menu of arrayView to mTitle
end menu_SetMenuTitle

on _
end _

on menu_TreeBehavior
   put LocalArray ["arrayView"] into arrayView
   
   put the behavior of arrayView into bObject
   edit the script of bObject
end menu_TreeBehavior

on menu_Toplevel treeView
   put LocalArray ["arrayView"] into arrayView
   
   put the stack_Name of arrayView into stackName
   toplevel stack stackName
end menu_Toplevel

on menu_SortType displayedObject, treeSortType
   put LocalArray ["arrayView"] into arrayView
   put the tree_Widget of arrayView into treeWidget
   if exists (treeWidget) is false then return empty
   
   set the sortType of treeWidget to treeSortType
end menu_SortType


--> Global | Array | Menu | Props
-
getprop tree_SortType
   put LocalArray ["arrayView"] into arrayView
   put the tree_Widget of arrayView into treeWidget
   if exists (treeWidget) is false then return empty
   put the sortType of treeWidget into treeSortType
   return treeSortType
end tree_SortType

getprop tree_SortTypes
   return "numeric,text"
end tree_SortTypes


--> Deps
-
private command _displaySelectedValue pTreeWidget
   if pTreeWidget is empty then
      put _treeWidget() into pTreeWidget
   end if
   
   put the selected_Value of pTreeWidget into selectedValue
   if selectedValue is an array then
      display_Array selectedValue
   else
      put selectedValue
   end if
end _displaySelectedValue




