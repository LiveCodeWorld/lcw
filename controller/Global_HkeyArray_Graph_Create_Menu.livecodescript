script "Global_HkeyArray_Graph_Create_Menu"
--> MetaData
-
license: GPLv3
name: Global_HkeyArray_Graph_Create_Menu
type: controller
version: 0.3

--> Variables
-
local LocalArray


--> Global | HkeyArray | Graph | Create | Menu
-
on menu_CreateSvgGraph treeView, graphStyle
   local pProjectName
   
   put the view_Data of treeView into hkeyArray
   put the displayed_Object of treeView into scriptObject
   
   script_CreateGraph hKeyArray, scriptObject, pProjectName, graphStyle
   put the result into imageFile
   
   display_SVG imageFile, scriptObject
   put the result into displayView
   set the displayed_Object of displayView to scriptObject
end menu_CreateSvgGraph

on menu_CreateAndDisplaySvg scriptObject, projectName
   local pGraphStyle, pProcessObject, pForceCreate
   
   display_IndexScriptAndDisplaySVG scriptObject, projectName, pGraphStyle, pProcessObject, false
   put the result into imageFile
   
   put the project_ProcessedHkeyArray of scriptObject into processedHkeyArray
   display_HkeyArray processedHkeyArray, scriptObject
   display_ObjectHkeyArray processedHkeyArray, scriptObject
end menu_CreateAndDisplaySvg

on menu_DisplayProcessedHkeyArray scriptObject
   put the project_ProcessedHkeyArray of scriptObject into processedHkeyArray
   display_HkeyArray processedHkeyArray, scriptObject
   display_ObjectHkeyArray processedHkeyArray, scriptObject
end menu_DisplayProcessedHkeyArray

on menu_DisplaySvg treeView
   put the displayed_Object of treeView into scriptObject
   put LocalArray ["svgFile"] into svgFile
   display_SVG svgFile
end menu_DisplaySvg

on menu_DisplayProjectMetadataFolder treeView
   put the displayed_Object of treeView into scriptObject
   -- put the project_MetaDataFolder of scriptObject into projectMetaDataFolder
   put the project_OverlayFolder of scriptObject into projectMetaDataFolder
   
   put projectMetaDataFolder
   finder_Reveal projectMetaDataFolder
end menu_DisplayProjectMetadataFolder

getprop disabled_DisplaySvg [treeView]
   -- should be a simpler way
   put the displayed_Object of treeView into scriptObject
   put the project_OverlayFolder of scriptObject into projectMetaDataFolder
   put empty into pOverlayName
   put overlay_GetArray (projectMetaDataFolder, pOverlayName) into overlayArray
   put overlayArray_GetImageFile (overlayArray, projectMetaDataFolder) into svgFile
   put svgFile into LocalArray ["svgFile"]
   if svgFile is empty then
      return true
   else
      return false
   end if
end disabled_DisplaySvg

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Menu | Props
-
/*
This menu is designed to be the title menu of a tree or similar widget that presents an hkeyArray.
it should allow export to the appropriate place on disk, as it can take a long time to process these arrays,
and they may want to be examined before they are saved!
*/

command menu_Init treeView
   put the displayed_Object of treeView into scriptObject
   if exists (scriptObject) is true then
      put empty into hKey
      put the mobile_Name of scriptObject into LocalArray ["stackLabel"]
      put the overlay_Folder of scriptObject into overlayFolder 
   else
      put the displayed_Hkey of treeView into hKey
      -- put the title_Text of treeView into hKey
      put hKey into LocalArray ["stackLabel"]
      put library_HkeyFolder (hKey) into overlayFolder
   end if
   
   put overlayFolder into LocalArray ["overlayFolder"]
   put hKey into LocalArray ["hKey"]
   put scriptObject into LocalArray ["scriptObject"]
   
   return overlayFolder
end menu_Init

function _GetOverlayFolder
   return LocalArray ["overlayFolder"]
end _GetOverlayFolder

command deconstructLocalArray @overlayFolder, @hKey, @stackLabel, @scriptObject
   put LocalArray ["overlayFolder"] into overlayFolder
   put LocalArray ["hKey"] into hKey
   put LocalArray ["stackLabel"] into stackLabel
   put LocalArray ["scriptObject"] into scriptObject
end deconstructLocalArray

getprop menu_CheckTarget [mTarget]
   if exists (mTarget) is false then return false
   put the tree_View of mTarget into treeView
   if exists (treeView) is false then return false
   put the long id of treeView = the long id of mTarget into someBoolean
   return someBoolean
end menu_CheckTarget


--> Dev | Menu
-
/*
This section looks like a well structured old menu for manipulating hkeyArray grpah data.
needs testing.
*/

on menu_CreateNewGraphFromTree treeView, graphStyle
   put opn_Ask ("What name would you like to give this overlay?", graphStyle) into overlayName
   -- put the displayed_OverlayName of treeView into overlayName
   
   put the view_Data of treeView into hkeyArray
   deconstructLocalArray overlayFolder, hKey, stackLabel, scriptObject
   
   -- hkeyArray_ConstructOverlayAndCreateFiles hKeyArray, graphStyle, overlayFolder, overlayName, true
   put overlayArray_FromLinkArray (hKeyArray) into overlayArray
   overlayArray_SetGraphProperty overlayArray, "overlay_Folder", overlayFolder
   overlayArray_SetGraphProperty overlayArray, "overlay_Style", graphStyle
   if exists(scriptObject) then
      overlayArray_SetGraphProperty overlayArray, "overlay_Of", scriptObject
   else
      overlayArray_SetGraphProperty overlayArray, "overlay_Of", hKey
   end if
   
   -- overlayArray_ConstructOverlayAndCreateFiles overlayArray, overlayFolder, overlayName
   overlay_SetArray overlayFolder, overlayArray, overlayName
   overlayArray_CreateFilesAndSetGeometry overlayArray
   
   local pImageView, pResizeStyle
   display_Overlay overlayFolder, graphStyle, pImageView, pResizeStyle, stackLabel
end menu_CreateNewGraphFromTree

on _
end _

on menu_CreateTemporaryObjectGraphFromTree treeView, graphStyle
   set the cursor to watch
   put the displayed_Array of treeView into hKeyArray
   put the displayed_Object of treeView into scriptObject
   
   put the displayed_OverlayFolder of treeView into overlayFolder
   -- put the textStackOverlay_Folder of scriptObject into overlayFolder
   -- put the overlay_Folder of scriptObject into overlayFolder 
   put the displayed_OverlayName of treeView into overlayName
   
   put overlay_GetData (overlayFolder) into overlayData
   put overlayData_GetGraphPropertyArray (overlayData, overlayName) into graphPropertyArray
   put overlayData_GetHeaderArray (overlayData, overlayName) into dotHeaderArray
   
   put overlayArray_FromLinkArray (hKeyArray, dotHeaderArray, graphPropertyArray) into overlayArray
   overlayArray_SetGraphProperty overlayArray, "overlay_Style", graphStyle
   
   local imageView, resizeStyle
   if exists (scriptObject) then
      put the mobile_Name of scriptObject into stackLabel
   else
      put the title_Text of treeView into stackLabel
   end if
   overlayArray_CreateAndDisplayGraph overlayArray, graphStyle, overlayFolder, imageView, resizeStyle, stackLabel
   put the result into displayView
end menu_CreateTemporaryObjectGraphFromTree

on menu_CreateTemporaryHkeyGraphFromTree treeView, graphStyle
   set the cursor to watch
   put the displayed_Array of treeView into hKeyArray
   put the displayed_Object of treeView into scriptObject
   
   put the displayed_OverlayFolder of treeView into overlayFolder
   put the displayed_OverlayName of treeView into overlayName
   
   put overlay_GetData (overlayFolder) into overlayData
   put overlayData_GetGraphPropertyArray (overlayData, overlayName) into graphPropertyArray
   put overlayData_GetHeaderArray (overlayData, overlayName) into dotHeaderArray
   
   put overlayArray_FromLinkArray (hKeyArray, dotHeaderArray, graphPropertyArray) into overlayArray
   overlayArray_SetGraphProperty overlayArray, "overlay_Style", graphStyle
   
   local imageView, resizeStyle
   if exists (scriptObject) then
      put the mobile_Name of scriptObject into stackLabel
   else
      put the title_Text of treeView into stackLabel
   end if
   overlayArray_CreateAndDisplayGraph overlayArray, graphStyle, overlayFolder, imageView, resizeStyle, stackLabel
   put the result into displayView
end menu_CreateTemporaryHkeyGraphFromTree

on _
end _

on menu_CreateLibraryHkeyDependencyGraph treeView, graphStyle
   deconstructLocalArray overlayFolder, hKey, stackLabel, scriptObject
   put the displayed_Array of treeView into hKeyArray
   put item 3 of hKey into hObject
   put the overlay_Folder of hObject into overlayFolder

   library_CreateHkeyGraph hKey, hKeyArray, graphStyle, pOverlayName, pDotCluster, pOverlayHash
end menu_CreateLibraryHkeyDependencyGraph

on menu_CreateLibraryObjectHkeyDependencyGraph treeView, graphStyle
   deconstructLocalArray overlayFolder, hKey, stackLabel, scriptObject
   put the displayed_Array of treeView into hKeyArray
   put library_HandlerFile (hKey) into overlayFolder
   
   library_CreateHkeyGraph hKey, hKeyArray, graphStyle, pOverlayName, pDotCluster, pOverlayHash
end menu_CreateLibraryObjectHkeyDependencyGraph

on _
end _

on menu_DisplayHkeyOverlayGraph treeView, hkeyOverlayName
   set the cursor to watch
   deconstructLocalArray overlayFolder, hKey, stackLabel, scriptObject
   put item 3 of hKey into hObject
   put the overlay_Folder of hObject into overlayFolder
   
   display_Overlay overlayFolder, hkeyOverlayName
end menu_DisplayHkeyOverlayGraph

on menu_DisplayExternalMainStackHkeyArray treeView
   deconstructLocalArray overlayFolder, hKey, stackLabel, scriptObject
   put item 3 of hKey into hObject
   put the mainstack_WalkArray of hObject into mainStackHkeyWalkArray
   put mainStackHkeyWalkArray ["external"] into externalArray
   
   local hKeyArray
   repeat for each key shortCall in externalArray
      put externalArray [shortCall] into leafArray
      put line 1 of keys (leafArray) into leafkey
      put leafArray [leafkey] into externalKey
      
      get hkey_DependencyArrayFromObjects (externalKey)
      if it is not an array then
         put empty into it [externalKey]
      end if
      union hKeyArray with it
      
      /*
      put hArray_GetShortCalls (externalKey) into shortCalls
      repeat for each line shortCall in shortCalls
         hArray_DependencyWalk shortCall, externalKey, hKeyWalkArray
      end repeat
      */
   end repeat
   
   display_Array hKeyArray, hkey
end menu_DisplayExternalMainStackHkeyArray

on menu_RevealHkeyGraphFolder treeView
   deconstructLocalArray overlayFolder, hKey, stackLabel, scriptObject
   put item 3 of hKey into hObject
   put the overlay_Folder of hObject into overlayFolder
   
   finder_Reveal overlayFolder
end menu_RevealHkeyGraphFolder

on _
end _

on menu_DisplayOverlayGraph treeView, overlayName
   set the cursor to watch
   deconstructLocalArray overlayFolder, hKey, stackLabel, scriptObject
   
   local pImageView, pResizeStyle
   display_Overlay overlayFolder, overlayName, pImageView, pResizeStyle, stackLabel
end menu_DisplayOverlayGraph


--> HkeyArray | Graph | Create | Menu | Props
-
getprop graph_Styles
   return dot_AllGraphStyles()
end graph_Styles

getprop overlay_Names [treeView]
   put _GetOverlayFolder (treeView) into overlayFolder
   put overlay_ListNames (overlayFolder) into overlayNames
   return overlayNames
end overlay_Names


--> HkeyArray | Graph | Create | Menu | Disabled
-

--> Deps
-
function dot_AllGraphStyles
   return "radial,spring,circular,-,hierarchical,-,undirected spring,fast undirected spring" 
end dot_AllGraphStyles
