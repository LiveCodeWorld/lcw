script "Global_Array_Menu"
--> MetaData
-
license: GPLv3
name: Global_Array_Menu
type: controller
version: 0.7


--> Menu | Props
-
-- getprop menu_Controller
return the name of stack "behavior_DisplayArray"
end menu_Controller


--> Global | Array | Menu
-
/*
Menus in behaviors are a bit odd - as "me" does not work
*/

on menu_TestArray treeView
   put the tree_Widget of treeView into treeWidget
   _displaySelectedValue treeWidget
end menu_TestArray

on _
end _

on menu_TreeBehavior treeView
   put the behavior of treeView into bObject
   edit the script of bObject
end menu_TreeBehavior

on menu_Toplevel treeView
   put the stack_Name of treeView into stackName
   toplevel stack stackName
end menu_Toplevel

on menu_SortType treeView, treeSortType
   put the tree_Widget of treeView into treeWidget
   if exists (treeWidget) is false then return empty
   
   set the sortType of treeWidget to treeSortType
end menu_SortType


--> Global | Array | Menu | Props
-
getprop tree_SortType [treeView]
   put the tree_Widget of treeView into treeWidget
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




