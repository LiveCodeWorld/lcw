script "Global_HkeyArray_Hkey_Menu"
--> MetaData
-
license: GPLv3
name: Global_HkeyArray_Hkey_Menu
type: controller
version: 0.1

/*
For trees displaying HkeyArrays of object scripts.
*/

--> Variables
-
local LocalArray


--> Global | HkeyArray | Hkey | Menu
-
on menu_DisplayObjectArray treeView
   put the view_Data of treeView into hkeyArray
   
   put the displayed_Hkey of treeView into hKey
   if hKey is empty then
      put the displayed_Object of treeView into hObject
      display_ObjectHkeyArray hkeyArray, hObject
   else
      display_ObjectHkeyArray hkeyArray, hKey
   end if
end menu_DisplayObjectArray

on _
end _

on menu_EditHkey treeView
   put the displayed_Hkey of treeView into hKey
   hkey_Edit hKey
end menu_EditHkey

on _
end _

on menu_AddAllHandlerToLibrary treeView
   put the displayed_Array of treeView into hKeyArray
   put array_AllNodes (hKeyArray) into hKeys
   repeat for each line hKey in hKeys
      set the cursor to busy
      library_AddHkey hKey
   end repeat
   
   put the displayed_Hkey of treeView into hKey
   display_Hkey hKey, "library"
end menu_AddAllHandlerToLibrary

on menu_CreateAndExportHkeyGraphs treeView
   put the displayed_Array of treeView into hKeyArray
   
   repeat for each key hKey in hKeyArray
      set the cursor to busy
      put hkeyArray_ExtractSubArray (hKey, hkeyArray) into hkeySubArray
      library_CreateHkeyGraph hKey, hKeyArray, "hierarchical"
   end repeat
end menu_CreateAndExportHkeyGraphs

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | HkeyArray | Object | Hkey | Props
-
--> Global | HkeyArray | Object | Hkey | Disabled
-

--> Menu | Props
-
on menu_Init treeView
   put the tree_View of treeView into treeView
   put the displayed_Hkey of treeView into hKey
   put hKey into LocalArray ["hKey"]
   put project_HandlerMetadataFolder (hKey, false) into LocalArray ["overlayFolder"] 
end menu_Init

getprop menu_Target [mTitlePath]
   switch
      case mTitlePath contains "Global | Overlay | Array | Menu"
         return LocalArray ["overlayFolder"] 
      case mTitlePath contains "Global | Handler | Menu"
         return LocalArray ["hKey"]
      default
         pass menu_Target
   end switch
end menu_Target


--> Dev | Menu
-
on menu_DisplayHkeyArray treeView
   -- put the displayed_Data of treeView into treeData
   put the view_Data of treeView into hkeyArray
   
   put the displayed_Object of treeView into hObject
   put the displayed_Hkey of treeView into hKey
   put item 1 of hkey into hName
   put item 3 of hkey into hObject
   
   display_HKeyArray hKeyArray, hKey
end menu_DisplayHkeyArray

on _
end _

on menu_DisplayProjectHkey treeView
   put the displayed_Hkey of treeView into hKey
   display_Hkey hKey, "project"
end menu_DisplayProjectHkey

on menu_DisplayLibraryHkey treeView
   put the displayed_Hkey of treeView into hKey
   display_Hkey hKey, "library"
end menu_DisplayLibraryHkey

