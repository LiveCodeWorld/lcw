script "Global_HkeyArray_Menu"
--> MetaData
-
license: GPLv3
name: Global_HkeyArray_Menu
type: controller
version: 0.1

--> Variables
-
local LocalArray


--> Global | HkeyArray | Menu
-
/*
The menu for tree views of overlay arrays.
See also "Global | Image | Dot | Menu" and "Global | Script | Dependency | Menu"
*/

on submenu_Hkey
   return "Global | HkeyArray | Hkey | Menu"
end submenu_Hkey

on submenu_CreateGraph
   return "Global | HkeyArray | Graph | Create | Menu"
end submenu_CreateGraph

on submenu_OverlayArray
   return "Global | Overlay | Array | Menu"
end submenu_OverlayArray

on _
end _

on submenu_Display
   return "Global | HkeyArray | Tree | Display | Menu"
end submenu_Display

on submenu_Filter
   return "Global | HkeyArray | Tree | Filter | Menu"
end submenu_Filter

on submenu_Deps
   return "Global | HkeyArray | Tree | Deps | Menu"
end submenu_Deps

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | HkeyArray | Menu | Disabled
-
--> Global | HkeyArray | Menu | Props
-

--> Deps
-

--> Dev | Menu
-
on menu_RecreateOverlay treeView, overlayName
   set the cursor to watch
   
   local pImageView, pResizeStyle
   deconstructLocalArray overlayFolder, hKey, stackLabel, scriptObject
   
   put overlay_GetArray (overlayFolder, overlayName) into overlayArray
   overlayArray_ConstructOverlayAndCreateFiles overlayArray, overlayFolder, overlayName
   
   display_Overlay overlayFolder, overlayName, pImageView, pResizeStyle, stackLabel
end menu_RecreateOverlay

on menu_SaveDisplayedOverlayArray treeView, graphStyle
   put the displayed_Object of treeView into scriptObject
   
   put the title_Text of treeView into hKey
   put the displayed_Array of treeView into hKeyArray
   
   -- put the displayed_OverlayFolder of treeView into overlayFolder
   put library_HkeyFolder (hKey) into overlayFolder
   
   -- put the displayed_OverlayName of treeView into overlayName
   put opn_Ask ("What name would you like to give this overlay?", graphStyle) into overlayName
   
   put overlay_GetData (overlayFolder) into overlayData
   put overlayData_GetGraphPropertyArray (overlayData, overlayName) into graphPropertyArray
   put overlayData_GetHeaderArray (overlayData, overlayName) into dotHeaderArray
   
   put overlayArray_FromLinkArray (hKeyArray, dotHeaderArray, graphPropertyArray) into overlayArray
   overlayArray_SetGraphProperty overlayArray, "overlay_Style", graphStyle
   
   overlay_SetArray overlayFolder, overlayArray, overlayName
   
   opn_Notify "Saved array, but not created graph files for this new array!", true
   display_OverlayData overlayFolder, hKey
end menu_SaveDisplayedOverlayArray

on menu_SetOverlayObject treeView
   put the displayed_Object of treeView into scriptObject
   overlay_SetOverlayObject overlayFolder, scriptObject
end menu_SetOverlayObject

on menu_ExportScriptArray treeView
   put the displayed_Array of treeView into hKeyArray
   put the displayed_Object of treeView into scriptObject
   -- set the script_OverlayData of scriptObject
   put the displayed_OverlayName of treeView into overlayName
   set the script_LinkArray [overlayName] of scriptObject to hKeyArray
   put the result into someFile
   finder_Reveal someFile
end menu_ExportScriptArray

on menu_RevealOverlayFolder treeView
   put LocalArray ["overlayFolder"] into overlayFolder
   finder_Reveal overlayFolder
end menu_RevealOverlayFolder


--> Menu | Props
-
/*
This menu is designed to be the title menu of a tree or similar widget that presents an hkeyArray.
it should allow export to the appropriate place on disk, as it can take a long time to process these arrays,
and they may want to be examined before they are saved!
*/

on menu_Init targetObject, mPath, mTitlePath
   put the tree_View of targetObject into treeView
   
   put the displayed_Object of treeView into scriptObject
   if exists (scriptObject) is true then
      put empty into hKey
      put the mobile_Name of scriptObject into stackLabel
      put the overlay_Folder of scriptObject into overlayFolder 
   else
      put the displayed_Hkey of treeView into hKey
      -- put the title_Text of treeView into hKey
      put hKey into stackLabel
      put library_HkeyFolder (hKey) into overlayFolder
   end if
   
   put treeView into LocalArray ["treeView"]
   put targetObject into LocalArray ["targetObject"]
   put overlayFolder into LocalArray ["overlayFolder"]
   put hKey into LocalArray ["hKey"]
   put stackLabel into LocalArray ["stackLabel"]
   put scriptObject into LocalArray ["scriptObject"]
end menu_Init

command deconstructLocalArray @overlayFolder, @hKey, @stackLabel, @scriptObject
   put LocalArray ["overlayFolder"] into overlayFolder
   put LocalArray ["hKey"] into hKey
   put LocalArray ["stackLabel"] into stackLabel
   put LocalArray ["scriptObject"] into scriptObject
end deconstructLocalArray

getprop menu_Target [mTitlePath]
   -- only called if toplevel menu
   switch
      case mTitlePath contains "Global | Overlay | Array | Menu"
         return LocalArray ["overlayFolder"]
      default
         return LocalArray ["treeView"]
   end switch
end menu_Target
