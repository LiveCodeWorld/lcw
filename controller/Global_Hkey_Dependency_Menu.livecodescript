script "Global_Hkey_Dependency_Menu"
--> MetaData
-
license: GPLv3
name: Global_Hkey_Dependency_Menu
type: controller
version: 0.1

--> Variables
-
local LocalArray


--> Global | Hkey | Dependency | Menu
-
on menu_CreateDependencyGraphFromExported hKey, fetchHow
   put hkey_ConstructCallArray (hKey, fetchHow) into hKeyArray
   hkeyArray_DrawGraph hKeyArray, "hierarchical"
end menu_CreateDependencyGraphFromExported

on menu_CreateWithoutObjectClusters hKey
   breakpoint
   deps_CreateMainStackOverlay scriptObject, "hierarchical", "display", true, "none"
   put hkey_DependencyArrayFromObjects (hKey, "Menu Only", true) into hKeyArray
end menu_CreateWithoutObjectClusters

on menu_RecursivelyCreateLibrayDepGraphsFromObjects hKey
   library_ConstructRecurseAddAndCreateHkeyGraph hKey
   display_Hkey hKey
end menu_RecursivelyCreateLibrayDepGraphsFromObjects

on _
end _

on menu_FetchHkeyDependencies hKey
   put hkey_FetchDeps (hKey) into allShortDeps
   sort hKeyDeps
   
   display_Outline allShortDeps, hKey, "Global | HkeyArray | Menu", "Global | HkeyArray | Line | Menu", 1, false,  "palette"
end menu_FetchHkeyDependencies

on menu_DepsFromExportedLinks hKey
   put hkey_FetchDeps (hKey) into allShortDeps
   sort allShortDeps
   display_Outline allShortDeps, hKey, "Global | HkeyArray | Menu", "Global | HkeyArray | Line | Menu", 1, false,  "palette"
end menu_DepsFromExportedLinks

on menu_TestSame hKey
   put hkey_FetchDeps (hKey, true) into allShortDeps
   sort allShortDeps
   put hkey_FetchDeps (hKey) into shortHkeyDeps
   sort shortHkeyDeps
   
   answer shortHkeyDeps = allShortDeps
end menu_TestSame

on _
end _

on menu_FetchDependencyScript hKey
   local missingHkeys, depScript
   put hkey_FetchDeps (hKey) into depHkeys
   script_FetchFromHkeys depHkeys, depScript, missingHkeys, false
   put script_ConstructSuite ("Deps", depScript) into depSuite
   
   display_Lines depSuite, "hkey_FetchDeps (shortHKey)"
end menu_FetchDependencyScript

on menu_DependencyScriptFromArray hKey, overlayName
   set the cursor to watch
   
   put library_HandlerFile (hKey) into hkeyFolder
   put overlay_GetLinkArray (hkeyFolder, overlayName) into hkeyArray
   
   put the strip_HkeyComponents of me is true into stripComponents
   put the strip_HkeyProps of me into stripProps
   -- put the include_HandlersFrom of me into includeHandlersFrom
   put item 3 of hKey of scriptObject
   put empty into pStripObjects
   
   display_HkeyArrayDependencyScript hkeyArray, scriptObject, pStripObjects, stripProps, false
   put the result into someArray
   
   put someArray ["uniqueHkeys"] into uniqueHkeys
   put someArray ["missingHkeys"] into missingHkeys
   put someArray ["duplicateHkeyArray"] into duplicateHkeyArray
   
   display_Outline uniqueHkeys, "uniqueHkeys"
   if missingHkeys is not empty then display_Outline missingHkeys, "missingHkeys"
   if duplicateHkeyArray is not empty then display_Array duplicateHkeyArray, "duplicateHkeyArray"
end menu_DependencyScriptFromArray

on _
end _

on menu_StripHkeyProps hKey, someBoolean
   -- handler in libOPN_Hkey library
   set the strip_HkeyProps of me to someBoolean
end menu_StripHkeyProps

on menu_StripHkeyComponents hKey, someBoolean
   -- handler in libOPN_Hkey library
   set the strip_HkeyComponents of me to someBoolean
end menu_StripHkeyComponents

on menu_IncludeHandlersFrom hKey, includeHandlersFrom
   set the include_HandlersFrom of me to includeHandlersFrom
end menu_IncludeHandlersFrom

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_FetchHkeyLinkArray hKey, oldFetchHow
   put hkey_FetchLinkArray (hKey, fetchHow) into hKeyArray
   display_HKeyArray hKeyArray, hkey
end menu_FetchHkeyLinkArray

on menu_DepsFromStoredHkeyLinkArray hKey
   put hkey_FetchDepsFromLinkArray (hKey) into hKeyDeps
   display_Outline hKeyDeps
end menu_DepsFromStoredHkeyLinkArray

on menu_DepsFromObjectsScriptLinkArray hKey
   put hkey_FetchDeps (hKey, "stored script_LinkArray") into hKeyDeps
   display_Outline hKeyDeps
end menu_DepsFromObjectsScriptLinkArray

on menu_AllDepsFromObjects hKey
   /*
   Fetch the handlers directly from the objects
   Extract the calls and store the handler and calls.
   Recurse
   */ 
   local pSetName, pTestExceptions
   
   timer_Start "library_HkeyFolder"
   --
   put library_HkeyFolder (hKey, pSetName, pTestExceptions) into hKeyArray
   --
   timer_Stop "library_HkeyFolder", true
   
   display_HKeyArray hKeyArray, hkey
end menu_AllDepsFromObjects



--> Global | Hkey | Dependency | Menu | Props
-
getprop fetch_How
   return LocalArray ["fetch_How"]
end fetch_How

getprop fetch_Hows
   return "filtered,all"
end fetch_Hows

getprop old_FetchHow [hKey]
   -- put hkey_GetLinkArray (hKey) into hkeyLinkArray
   put hkey_ArrayFile (hKey) into someFile
   if there is a file someFile then put "stored hkeyLinkArray" & CR after fetchHows
   
   -- put the script_LinkArray of hObject into hkeyLinkArray
   put item 3 of hKey into hObject
   put the script_OverlayFile of hObject into someFile
   if there is a file someFile then put "stored script_LinkArray" & CR after fetchHows
   
   put "from object" after fetchHows
   return fetchHows
end old_FetchHow

getprop old_FetchHows
   put hArray_FindHkey ("hkey_FetchLinkArray,f") into hKey
   if hKey is empty then return empty
   put item 3 of hKey into foundObject
   put the hkey_CaseConditions ["hkey_FetchLinkArray,f"] of foundObject into caseConditions
   return caseConditions
end old_FetchHows

getprop overlay_Names [hKey]
   put library_HandlerFile (hKey) into overlayFolder
   put overlay_ListNames (overlayFolder) into overlayNames
   return overlayNames
end overlay_Names

getprop include_HandlersFrom
   lock messages
   put the include_HandlersFrom of me into includeHandlersFrom
   unlock messages
   if includeHandlersFrom is empty then return "stack"
   return includeHandlersFrom
end include_HandlersFrom

setprop include_HandlersFrom includeHandlersFrom
   lock messages
   set the include_HandlersFrom of me to includeHandlersFrom
   unlock messages
end include_HandlersFrom

getprop include_HandlersFroms
   get "stack,application,development,-,full"
   replace comma with CR in it
   return it
end include_HandlersFroms


--> Global | Hkey | Dependency | Menu | Disabled
-
getprop disabled_DepsFromStoredHkeyLinkArray [hKey]
   put hkey_ArrayFile (hKey) into someFile
   if there is a file someFile then
      return false
   else
      return true
   end if
end disabled_DepsFromStoredHkeyLinkArray

getprop disabled_DepsFromScriptLinkArray [hKey]
   put item 3 of hKey into scriptObject
   put the script_OverlayFile of scriptObject into someFile
   if there is a file someFile then
      return false
   else
      return true
   end if
end disabled_DepsFromScriptLinkArray


--> Menu | Props
-
getprop menu_CheckTarget [hKey]
   return is_Hkey (hKey)
end menu_CheckTarget

getprop menu_Target [mTitlePath]
   switch
      case mTitlePath contains "Global | Script | Log | Menu"
         breakPoint
         return LocalArray ["scriptObject"]
      default
         return LocalArray ["hKey"]
   end switch
end menu_Target
