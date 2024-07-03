script "Global | Tree | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Tree | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here we put experimental in-development tools for trees and array structures.
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


--> Global | Tree | Dev | Menu
-
on menu_CloneTree
   dispatch "module_Clone" with "Tree",true
end menu_CloneTree

on menu_ModuleTools dView
   put the view_Name of dView into viewName
   dispatch "display_ModuleTools" with viewName
end menu_ModuleTools

private on _
end _

on menu_DisplayTemplate arrayView
   put the view_Name of arrayView into vName
   put view_GetTemplateObject (vName) into tObject
   --
   object_GoTo tObject, true
end menu_DisplayTemplate

on menu_FoldState dView
   put the fold_State of dView into fState
   display_Data fState, "fold_State", "Tree"
end menu_FoldState

on menu_AddMenuButton arrayView
   put menu_SimpleButton() into simpleMenuButton
   put the name of simpleMenuButton
   --
   copy simpleMenuButton to arrayView
   put it into newButton
   set the label of newButton to empty
   set the name of newButton to "_Menu Button"
   set the visible of newButton to false
   dispatch "LayoutControl" to arrayView
end menu_AddMenuButton

private on __
end __

on insert_Tree
   return "Global | Array | Menu"
end insert_Tree
