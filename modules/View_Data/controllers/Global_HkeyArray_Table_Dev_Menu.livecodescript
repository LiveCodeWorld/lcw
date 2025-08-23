script "Global | HkeyArray | Table | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | HkeyArray | Table | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this developer menu.
Full help text should be provided on the linked wiki.

Consider improving by creating with same menu_Target as no-developer menu is is based on.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   return the data_View of tObject
end menu_Target

getprop menu_CheckTarget [mTarget]
   return exists (mTarget)
end menu_CheckTarget


--> Global | HkeyArray | Table | Dev | Menu
-
on menu_DisplayHkeyArray
   put _HkeyArray() into hkeyArray
   put _ScriptObject() into sObject
   --
   display_ScriptHkeyArray hkeyArray, sObject
end menu_DisplayHkeyArray

on menu_ListExternalStacks
   put _dView() into dView
   put the uOPN ["displayed_Object"] of dView into sObject
   put the uOPN ["hkey_Array"] of dView into hkeyArray
   
   -- display_HkeyArrayDepTable hkeyArray, sObject
   put stackHkeyTable_Construct (hkeyArray, sObject) into hkeyTable
   set the displayed_Index of dView to hkeyTable
end menu_ListExternalStacks

on menu_RemoveSelected dView
   put the selected_LineNums of dView into lineList
   set the deleted_LineNums of dView to lineList 
end menu_RemoveSelected

private on _
end _

on menu_DisplayWithoutHkeys
   put _FilteredHkeys() into hKeys
   set the displayed_Index of _dView() to hKeys
end menu_DisplayWithoutHkeys

on menu_MenuEdit displayView
   menu_Edit "Global | HkeyArray | Table | Dev | Menu"
end menu_MenuEdit
