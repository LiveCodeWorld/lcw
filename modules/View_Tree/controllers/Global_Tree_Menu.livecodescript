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
on menu_MyTree sObject
   put the params
end menu_MyTree

on menu_CloneTree
   put _dView() into dView
   --
   module_Clone "Tree", true
end menu_CloneTree

command module_Clone moduleName, pShowTools
   view_NormalizeName moduleName
   --
   stack_Clone moduleName
   put the result into clonedStack
   --
   set the original_ModuleName of clonedStack to moduleName
   put the stack_Name of clonedStack into cStackName
   --
   if pShowTools is true then
      display_CloneTools cStackName
   end if
   return cStackName
end module_Clone

private on _
end _

on insert_Tree
   return "Global | Array | Menu"
end insert_Tree

private on __
end __

on menu_Footer
   put _dView() into treeView
   
end menu_Footer

on menu_ModuleTools sObject
   put the view_Name of dView into viewName
   display_ModuleTools viewName
end menu_ModuleTools

on submenu_Dev
   return menu_DevTitle ("Global | Tree | Menu")
end submenu_Dev
