script "Global | Script | Stacks | Line | Menu"
--> MetaData
-
license: GPLv3
name: Global | Script | Stacks | Line | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into dView
   put the displayed_Object of tObject into sObject
   --
   put dView into LocalArray ["dView"]
   put sObject into LocalArray ["sObject"]
   --
   return dView
end menu_Target

private function _dView
   return LocalArray ["dView"]
end _dView

private function _TreeView
   put _dView() into dView
   put the tree_View of dView into treeView
   return treeView
end _TreeView

private function _SelArray
   put _TreeView() into treeView
   put the selected_Array of treeView into sArray
   return sArray
end _SelArray

private function _SelPath
   put _TreeView() into treeView
   put the selected_Path of treeView into sPath
   return sPath
end _SelPath

private function _DisplayedHkeyArray
   put _dView() into dView
   put the displayed_HkeyArray of dView into hKeyArray
   return hKeyArray
end _DisplayedHkeyArray

private function _DisplayedArray
   put _TreeView() into treeView
   put the displayed_Array of treeView into dArray
   return dArray
end _DisplayedArray

private function _StackObject
   put _SelPath() into sPath
   put item 1 of sPath into stackObject
   return stackObject
end _StackObject

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | Script | Stacks | Line | Menu
-
on menu_RemoveStack dView
   put _DisplayedArray() into dArray
   put _StackObject() into stackObject
   --
   delete variable dArray [stackObject]
   delete variable dArray ["Missing"]
   --
   set the tree_Data of treeView to dArray
end menu_RemoveStack

on menu_WalkBranch dView
   put _SelArray() into sArray
   put array_List (sArray) into sKeys
   put _DisplayedArray() into dArray
   put _DisplayedHkeyArray() into hkeyArray
   --
   put linkArray_WalkBranch (sKeys, hkeyArray) into branchArray
   display_HkeyArrayGraph branchArray
end menu_WalkBranch

private on _
end _

on menu_Branch dView
   put _SelArray() into sArray
   --
   display_Data sArray, "Branch"
end menu_Branch

on menu_ModuleTools dView
   put the view_Name of dView into viewName
   display_ModuleTools viewName
end menu_ModuleTools

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Script | Stacks | Line | Menu")
end submenu_Dev
