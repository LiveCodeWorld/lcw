script "Global_HkeyArray_Tree_Filter_Menu"
--> MetaData
-
license: GPLv3
name: Global_HkeyArray_Tree_Filter_Menu
type: controller
version: 0.1

/*
This menu is for checking, comparing and filtering hKeyArrays
*/

local LocalArray


--> Global | HkeyArray | Tree | Filter | Menu
-
on menu_RemoveObject treeView, depObject
   put the displayed_Array of treeView into hKeyArray
   deconstructLocalArray overlayFolder, hKey, stackLabel, scriptObject
   
   hkeyArray_RemoveObjectLinks hkeyArray, depObject
   put hkeyArray_ConstructObjectArray (hkeyArray) into objectArray
   
   put merge ("Filtered hkeyArray") into someTitle
   
   if exists(scriptObject) then
      display_ObjectHKeyArray hKeyArray, scriptObject
   else
      display_HKeyArray hKeyArray, hkey
   end if
   return empty
   
   lock screen
   set the tree_Array [1] of the tree_Field of treeView to objectArray
   set the title_Text of treeView to someTitle
   unlock screen
end menu_RemoveObject

on menu_RemoveObjectLinks treeView, librarySetName
   -- not sure how this is different form "menu_DisplayDependencies"
   
   put the tree_Field of treeView into treeField
   put the displayed_Object of treeView into scriptObject
   
   put the displayed_Array of treeView into hKeyArray
   hkeyArray_RemoveObjectLinks hkeyArray, scriptObject
   
   put library_ListUsedStacks (librarySetName) into stackObjects
   repeat for each line stackObject in stackObjects
      hkeyArray_RemoveObjectLinks hkeyArray, stackObject
   end repeat
   
   put "Dependencies" into someTitle
   display_ObjectOutline hkeyArray, someTitle, treeView
end menu_RemoveObjectLinks

on menu_CheckNestedDeps treeView
   put the displayed_DependencyWalkArray of treeView into dependencyWalkArray
   
   put array_AllNodes (dependencyWalkArray) into allDeps
   put hkey_ConstructShortKeyArray (allDeps) into depShortHkeyArray
   
   put _HkeysInMainstack (treeView) into mainStackHkeys
   put hkey_ConstructShortKeyArray (mainStackHkeys) into mainstackShortHkeyArray
   
   array_Compare depShortHkeyArray, mainstackShortHkeyArray, commonArray, depsWithoutMainStackArray, mainStackWithoutDepsArray
   
   -- display_Array depShortHkeyArray, "depShortHkeyArray"
   display_Array mainstackShortHkeyArray, "mainstackShortHkeyArray"
   display_Array commonArray, "commonArray"
   display_Array depsWithoutMainStackArray, "depsWithoutMainStackArray"
end menu_CheckNestedDeps

on menu_ConstructNestedDependencies treeView
   put the displayed_MainStackWalkArray of treeView into mainStackWalkArray
   put mainStackWalkArray ["external"] into externalArray
   put firstLevelExternalCalls (externalArray) into firstLevelCalls
   
   hArray_FilterHkeys firstLevelCalls
   
   put hArray_WalkHkeyDeps (firstLevelCalls) into dependencyWalkArray
   set the displayed_DependencyWalkArray of treeView to dependencyWalkArray
   
   put dependencyWalkArray ["hKeyArray"] into dependencyHkeyArray
   put array_AllNodes (dependencyHkeyArray) into allDeps
   
   put the displayed_Object of treeView into mainStackObject
   put "Nested Deps for" && mainStackObject into someTitle
   set the tree_Display [someTitle] of treeView to allDeps
end menu_ConstructNestedDependencies

on _
end _

on menu_FilterDependencies treeView
   put the displayed_DependencyWalkArray of treeView into dependencyWalkArray
   put dependencyWalkArray ["hkeyArray"] into hkeyArray
   hArray_FilterHkeyArray hkeyArray
   put array_AllNodes (hKeyArray) into hKeys
   sort hKeys by item 1 of each
   
   -- _DisplayArray treeView, hkeyArray, "Filtered dependencyHkeyArray", 1
   set the tree_Display ["Filtered dependencyHkeyArray"] of treeView to hKeys
   
   display_HkeyArrayGraph hkeyArray, "undirected spring"
end menu_FilterDependencies

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_CheckAllKeyArray treeView
   put the displayed_Array of treeView into hkeyArray
   put array_AllNodes (hkeyArray) = keys (hkeyArray) into someBoolean
   if someBoolean is true then
      answer "Great, the keys of this array are all the nodes!"
   else
      answer "This is an old style array perhaps (as the keys do not equal all the nodes)?"
   end if
end menu_CheckAllKeyArray

on menu_CompareWith treeView
   set the cursor to watch
   put the displayed_Array of treeView into hKeyArray
   put array_AllNodes (hkeyArray) into theseHkeys
   
   put the script_Hkeys of stack "View|Menu|Button" into thoseHkeys
   put hkey_ConstructCompareArray (theseHkeys, thoseHkeys) into compareArray
   
   set the cursor to watch
   display_Array compareArray
end menu_CompareWith

on submenu_Filter
   return "Global | Dependency | Filter | Menu"
end submenu_Filter


--> HkeyArray | Tree | Filter | Menu | Props
-
getprop dep_Objects [treeView]
   put the displayed_Array of treeView into hKeyArray
   put hkeyArray_ConstructObjectArray (hkeyArray) into objectArray
   return keys (objectArray)
end dep_Objects


--> HkeyArray | Tree | Filter | Menu | Disabled
-
getprop disabled_CheckNestedDeps [treeView]
   put the displayed_DependencyWalkArray of treeView into dependencyWalkArray
   if dependencyWalkArray is an array then
      return false
   else
      return true
   end if
end disabled_CheckNestedDeps

getprop disabled_DisplayCollectedDependencies [treeView]
   put the displayed_DependencyWalkArray of treeView into dependencyWalkArray
   if dependencyWalkArray is an array then
      return false
   else
      return true
   end if
end disabled_DisplayCollectedDependencies


--> Deps
-
private function firstLevelExternalCalls externalArray
   repeat for each key shortHkey in externalArray
      put externalArray [shortHkey] into hkeyArray
      repeat for each key parentHkey in hkeyArray
         put hkeyArray [parentHkey] into externalHkeyCall
         put parentHkey into allExternalCallArray [externalHkeyCall]
      end repeat
   end repeat
   put keys (allExternalCallArray) into allFirstlevelCalls
   sort allFirstlevelCalls
   return allFirstlevelCalls
end firstLevelExternalCalls

private function _HkeysInMainstack treeView
   put the displayed_MainStackWalkArray of treeView into mainStackWalkArray
   put mainStackWalkArray ["hKeyArray"] into hKeyArray
   put array_AllNodes (hKeyArray) into hKeys
   sort hKeys by item 1 of each
   return hKeys
end _HkeysInMainstack

command display_ObjectOutline hkeyArray, someTitle, treeView
   put hkeyArray_ConstructObjectArray (hkeyArray) into objectArray
   
   lock screen
   set the tree_Array [1] of the tree_Field of treeView to objectArray
   set the title_Text of treeView to someTitle
   unlock screen
end display_ObjectOutline

