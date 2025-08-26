script "Global | Data | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Data | Line | Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray


--> Messages
-
on footer_HiliteChange fWidget, fName, fNum
   if the optionKey is "Down" then breakpoint
   put the footer_ItemArray of fWidget into iArray
   --
   put fName &&  fNum
end footer_HiliteChange

on doubleClick_Tree dView, sPath
   if the optionKey is "down" then breakpoint
   put item 2 of sPath into stackName
   put the selected_Value of dView into sValue
   --
   put sValue
end doubleClick_Tree


--> Menu | Props
-
getprop menu_Target [arrayWidget]
   put the hilitedElement of arrayWidget into sLine
   put the selected_Path of arrayWidget into sPath
   --
   put the data_View of arrayWidget into dView
   put the tree_View of arrayWidget into treeView
   put the displayed_Object of dView into sObject
   
   put dView into LocalArray ["dView"]
   put sLine into LocalArray ["sLine"]
   put sPath into LocalArray ["sPath"]
   put sObject into LocalArray ["sObject"]
   --
   return treeView
end menu_Target

getprop menu_CheckTarget [treeView]
   return exists (treeView)
end menu_CheckTarget

private function _dView
   return LocalArray ["dView"]
end _dView

private function _TopPath
   return item 1 of LocalArray ["sPath"]
end _TopPath

private function _StackName
   return item 2 of LocalArray ["sPath"]
end _StackName

private function _SelLine
   return LocalArray ["sLine"]
end _SelLine

getprop disabled_DepKeys
   return _TopPath() = "behavior_IndexArray"
end disabled_DepKeys


--> Global | Data | Line | Menu
-
on menu_Keys treeView
   put _StackName() into sName
   put the dep_StackNames of stack sName
end menu_Keys

private on _
end _

on insert_Tree
   return "Global | Array | Line | Menu"
end insert_Tree

on menu_Behavior arrayWidget
   put the behavior of arrayWidget into bObject
   edit the script of bObject
end menu_Behavior

on menu_Tools arrayWidget
   put the data_View of arrayWidget into dView
   put the view_Name of dView into viewName
   display_ModuleTools viewName
end menu_Tools

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Data | Line | Menu")
end submenu_Dev
