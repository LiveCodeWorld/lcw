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


--> Global | Tree | Menu
-
on menu_TreeModuleFiles sObject
   put LocalArray ["dView"] into dView
   put the module_Name of dView into moduleName
   --
   put the card_ViewObject of stack moduleName into moduleViewObject
   put the module_Folder of stack moduleName into moduleFolder
   --
   put directory_NestedArray (moduleFolder) into dArray
   set the displayed_Data of dView to dArray
   --
   set the displayed_Object of dView to moduleViewObject
   set the displayed_ModuleFolder of dView to moduleFolder
end menu_TreeModuleFiles

on menu_CloneTree
   put _dView() into dView
   --
   module_Clone "Tree", true
end menu_CloneTree

private on _
end _

on insert_Tree
   return "Global | Array | Menu"
end insert_Tree

private on __
end __

on menu_MenuButtonScript dView
   put the menu_Button of dView into mButton
   edit the script of mButton
end menu_MenuButtonScript

on menu_ModuleTools dView
   put the view_Name of dView into viewName
   display_ModuleTools viewName
end menu_ModuleTools

on submenu_Dev
   return menu_DevTitle ("Global | Tree | Menu")
end submenu_Dev
