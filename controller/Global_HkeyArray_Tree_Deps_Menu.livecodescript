script "Global_HkeyArray_Tree_Deps_Menu"
--> MetaData
-
license: GPLv3
name: Global_HkeyArray_Tree_Deps_Menu
type: controller
version: 0.1

/*
This menu is designed to be the title menu of a tree or similar widget that presents an hkeyArray.
it should allow export to the appropriate place on disk, as it can take a long time to process these arrays,
and they may want to be examined before they are saved!
*/

--> Variables
-
local LocalArray


--> Global | HkeyArray | Tree | Deps | Menu
-
on menu_CollectDependencyScript treeView
   local stripObjects
   
   set the cursor to watch
   put the displayed_Array of treeView into hKeyArray
   put the displayed_Object of treeView into scriptObject
   
   put pref_GetValue ("skip_HkeyProps") is not false into stripProps
   
   put the include_HandlersFrom of me into includeHandlersFrom
   if includeHandlersFrom = "none" then
      put empty into stripObjects
   else
      put the hkey_SearchHierarchy [includeHandlersFrom] of scriptObject into stripObjects
   end if
   
   put pref_GetValue ("skip_HkeyComponents") is not false into stripComponents
   if stripComponents is true then
      put script_ListComponentObjects() into componentObjects
      line_Add componentObjects, stripObjects
   end if
   
   display_HkeyArrayDependencyScript hkeyArray, scriptObject, stripObjects, stripProps, stripComponents
   put the result into someArray
   
   put someArray ["uniqueHkeys"] into uniqueHkeys
   put someArray ["duplicateHkeyArray"] into duplicateHkeyArray
   put someArray ["missingHkeys"] into missingHkeys
   
   display_Outline uniqueHkeys, "uniqueHkeys"
   if missingHkeys is not empty then display_Outline missingHkeys, "missingHkeys"
   display_Array duplicateHkeyArray, "duplicateHkeyArray"
end menu_CollectDependencyScript

on _
end _

on menu_StripHkeyProps scriptObject, someBoolean
   pref_SetValue "skip_HkeyProps", someBoolean
end menu_StripHkeyProps

on menu_StripHkeyComponents scriptObject, someBoolean
   pref_SetValue "skip_HkeyComponents", someBoolean
end menu_StripHkeyComponents

on menu_IncludeHandlersFrom scriptObject, includeHandlersFrom
   set the include_HandlersFrom of me to includeHandlersFrom
end menu_IncludeHandlersFrom

on _
end _

on menu_CreateAndExportHkeyGraphs treeView
   put the displayed_Array of treeView into hKeyArray
   deconstructLocalArray overlayFolder, hKey, stackLabel, scriptObject
   
   repeat for each key hKey in hKeyArray
      set the cursor to busy
      put hkeyArray_ExtractSubArray (hKey, hkeyArray) into hkeySubArray
      library_CreateHkeyGraph hKey, hKeyArray, "hierarchical"
   end repeat
end menu_CreateAndExportHkeyGraphs

on menu_CreateLongHkeyArray treeView
   put the displayed_Hkey of treeView into hKey
   put the displayed_Array of treeView into shortHkeyArray
   put the set_Name of me into pSetName
   
   timer_Start "hkeyArray_ConstructLongArray"
   --
   put hkeyArray_ConstructLongArray (hKey, shortHkeyArray, pSetName) into longHkeyArray
   --
   timer_Stop "hkeyArray_ConstructLongArray", true
   
   put "Long Hkey Deps" into pStackLabel
   display_HKeyArray longHkeyArray, hkey
end menu_CreateLongHkeyArray

on menu_SearchSetFirst scriptObject, setName
   lock messages
   set the set_Name of me to setName
   unlock messages
   return setName
end menu_SearchSetFirst

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> HkeyArray | Tree | Deps | Menu | Props
-
getprop set_Name
   lock messages
   put the set_Name of me into setName
   unlock messages
   return setName
end set_Name

getprop set_Names
   return library_ListSetNames()
end set_Names

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
   get "none,-,stack,application,development,-,full"
   replace comma with CR in it
   return it
end include_HandlersFroms


--> HkeyArray | Tree | Deps | Menu | Disabled
-
getprop disabled_CreateLongHkeyArray [treeView]
   put the displayed_Hkey of treeView into hKey
   return hKey is empty
end disabled_CreateLongHkeyArray


--> Dev | Menu
-
on menu_DisplayCollectedDependencies treeView
   put the displayed_DependencyWalkArray of treeView into dependencyWalkArray
   put dependencyWalkArray ["hKeyArray"] into dependencyHkeyArray
   put array_AllNodes (dependencyHkeyArray) into allDeps
   
   put the displayed_Object of treeView into mainStackObject
   put "Nested Deps for" && mainStackObject into someTitle
   set the tree_Display [someTitle] of treeView to allDeps
end menu_DisplayCollectedDependencies

on menu_ConstructMenuLibraryHandlers treeView
   set the cursor to watch
   put the displayed_Array of treeView into hKeyArray
   put the displayed_Object of treeView into scriptObject
   
   put "menu_PopUp,c|menu_PullDown,c|menu_SendMessage,c" into shortHkeys
   set the itemdelimiter to "|"
   repeat for each item shortHkey in shortHkeys
      put the hkey_Find [shortHkey] of scriptObject & CR after hKeys
   end repeat
   delete char -1 of hKeys
   
   put hkey_DependencyArrayFromObjects (hKeys) into hkeyArray
   
   display_ObjectHkeyArray hkeyArray, scriptObject, "pop,pull,send"
   return empty
   
   set the cursor to watch
   put the displayed_Array of treeView into hKeyArray
   put the displayed_Object of treeView into scriptObject
   
   put pref_GetValue ("skip_HkeyComponents") is not false into stripComponents
   put pref_GetValue ("skip_HkeyProps") is not false into stripProps
   
   display_HkeyArrayDependencyScript hkeyArray, scriptObject, false, stripProps
   put the result into missingKeys
end menu_ConstructMenuLibraryHandlers


--> Deps
-
function script_ListComponentObjects
   -- stub for now
   put the name of stack "View|Menu|Button" into componentObjects
   put CR & the behavior of stack "View|Menu|Button" after componentObjects
   return componentObjects
end script_ListComponentObjects

