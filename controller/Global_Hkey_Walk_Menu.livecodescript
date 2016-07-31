script "Global_Hkey_Walk_Menu"
--> MetaData
-
license: GPLv3
name: Global_Hkey_Walk_Menu
type: controller
version: 0.2

/*
This menu concentrates on walking the dependency tree of a handler.
*/

--> Variables
-
local LocalArray


--> Global | Hkey | Walk | Menu
-
on menu_WalkHkey hKey, projectName
   /*
   Bug to Fix:
   
   At the moment the files:
   -  processedHkey.array
   -  overlayData.array
   - LCW.svg (ie [[projectName]].svg
   -  etc
   
   are bieng stored in the project_OverlayFolder
   instead of something more suitable for hander dependencies!
   
   Should use:
   
   -  put project_HandlerMetadataFolder (hKey, true) into hkeyMetadataFolder
   
   */
   
   local pSetName, pAllCalls
   project_WalkAndStoreObjectDependencies hKey, pAllCalls, projectName
   put the result into hKeyArray
   display_HKeyArray hKeyArray, hkey
   
   -- this shoud be an hKey graph (not a script graph)
   -- stored in the hkeyMetadataFolder -- project_HandlerMetadataFolder (heky)
   put item 3 of hkey into scriptObject
   script_CreateGraph hKeyArray, scriptObject, projectName, "hierarchical"
   put the result into imageFile
   
   put hkey into stackLabel
   display_SVG imageFile, stackLabel
   put the result into displayView
   set the displayed_Hkey of displayView to hkey
   
   finder_Reveal imageFile
end menu_WalkHkey

on _
end _

on menu_FetchStoredHkeyArray hKey
   put LocalArray ["project_FetchHkeyArray"] into hKeyArray
   -- put project_FetchHkeyArray (hKey) into hKeyArray
   display_HKeyArray hKeyArray, hkey
end menu_FetchStoredHkeyArray

on menu_RevealFolder hKey
   put project_HandlerMetadataFolder (hKey) into overlayFolder
   finder_Reveal overlayFolder
end menu_RevealFolder


--> Global | Hkey | Walk | Menu | Props
-
getprop project_Name
   put project_GetCurrentName() into activeProjectName
   return activeProjectName
end project_Name

getprop project_Names
   put library_ListSetNames() into projectNames
   return projectNames
end project_Names


--> Global | Hkey | Walk | Menu | Disabled
-
getprop disabled_FetchStoredHkeyArray [hKey]
   put project_FetchHkeyArray (hKey) into hKeyArray
   if hKeyArray is an array then
      put hKeyArray into LocalArray ["project_FetchHkeyArray"]
      return false
   else
      return true
   end if
end disabled_FetchStoredHkeyArray


--> Deps
-
command project_WalkAndStoreObjectDependencies hKey, pAllCalls, pSetName 
   put hkey_DependencyArrayFromObjects (hKey, pSetName, pAllCalls) into hKeyArray
   
   -- let's store the overlay in the project handler metadata folder (and create a hierarchical graph)
   put empty into pOverlayName 
   put item 3 of hKey into hObject
   put the mainstack_Hash of hObject into mainstackHash
   project_StoreHkeyArray hKey, hkeyArray, pOverlayName, mainstackHash, "hierarchical"
   return hkeyArray
end project_WalkAndStoreObjectDependencies

-- function project_HackExtractHkeyArray hKey, pReIndexFromObjects, pSetName, pAllCalls
   -- was "project_GetHkeyArray"
   
   -- get the best option
   -- try mainstack walkarray first, then project hkey overlay, and finally walk the objects
   -- check hashes to ensure only up to date returned
   -- create new project hkey overlay from object walk if no up-to-date hKeyArray present
   
   if pReIndexFromObjects is not true then
      put item 3 of hKey into hObject
      if exists (hObject) is false then 
         breakpoint
         return empty
      end if
      put the mainstack_Hash of hObject into mainstackHash
      
      -- first choice get from the mainstack walk array if it is indexed and up to date
      put project_HkeyArrayFromMainstackWalkArray (hKey, mainstackHash) into hKeyArray
      if hKeyArray is an array then return hKeyArray
      
      -- next let's look for a locally stored hKeyArray as part of an project hKey overlay
      put empty into pOverlayName 
      
      -- put project_FetchHkeyArray (hKey, pOverlayName, mainstackHash) into hKeyArray
      local overlayArray, storedStackHash
      put project_HandlerMetadataFolder (hKey) into overlayFolder
      project_FetchOverlayArrayAndHash hKey, pOverlayName, overlayArray, storedStackHash
      put overlayArray_GetLinkArray (overlayArray) into hkeyArray
      if storedStackHash = mainstackHash then return hkeyArray
   end if
   
   -- finally let's walk the dependency graph of each object
   project_WalkAndStoreObjectDependencies hKey, pAllCalls, pSetName
   put the result into hkeyArray
   return hkeyArray
end project_HackExtractHkeyArray


--> Private
-
