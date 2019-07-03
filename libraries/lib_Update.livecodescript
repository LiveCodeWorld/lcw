script "lib_Update"
--> MetaData
-
license: GPLv3
name: lib_Update
type: library
version: 0.2

/*
Used by the behavior (if running LCW), of the ScriptEditor Apply button. This behavior is the LCW Project stack behavior_IdeCompileButton.
*/



--> Working on
-
command script_ExportAndIndexMenus scriptObject, pDeleteOldExports
   -- this is what the IDE compile button dispatches
   -- so far nothing else calls this command
   -- it is designed to update the global menu index, and export handlers (but do nothing else)
   -- it can be optimised to ony loop through the script once (instead of twise as below)
   
   dispatch "script_Compile" to scriptObject with scriptObject,pDeleteOldExports
   switch it
      case "passed"
      case "unhandled"
         set the menu_Update of scriptObject to true
         script_ExportHandlersAndCalls scriptObject, pDeleteOldExports
         put the script_File of scriptObject into scriptFile
         break
      case "handled"
      default
         -- skip as we assume it is already handled at script level
         break
   end switch
   return scriptFile
end script_ExportAndIndexMenus


--> Update | Script
-
command script_ExportHandlersAndCalls someObject, pDeleteOldExports, pScript, pDataFolder
   global gLCW
   -- if the optionKey is "Down" then hkeyline_DeletePlaceObject someObject -- this is too slow
   if pScript is empty then put the script of someObject into pScript
   urip_Update someObject, pScript
   
   put the revAvailableHandlers of someObject into handlerTable
   sort numeric handlerTable by word 3 of each
   if handlerTable is empty then return empty -- everything is deleted before re-exporting
   
   if pDataFolder is empty then
      put the dataObject_Folder [false] of someObject into pDataFolder
      if there is not a folder pDataFolder is empty then
         -- check
         breakpoint
      end if
   end if
   
   if pDeleteOldExports is true then
      -- this also deletes the "lcw_calls.txt" files
      -- which is fine if we are rebuilding them
      revDeleteFolder pDataFolder
   end if
   
   put textStack_ScriptFile (pDataFolder, false) into scriptFile -- dep in authoring
   put pScript into mergeScript
   put revRuggedID (someObject) into rObject
   sort numeric descending handlerTable by word 3 of each -- from bottom up
   repeat for each line handlerTableLine in handlerTable
      set the cursor to busy
      put word 1 of handlerTableLine into hType
      put word 2 of handlerTableLine into hName
      if hName = "_" then next repeat -- could check handler is empty
      put word 3 of handlerTableLine into startLineNum
      put word 4 of handlerTableLine into endLineNum
      put line startLineNum to endLineNum of pScript into someHandler
      handler_Save handlerTableLine, pDataFolder, someHandler, pDeleteOldExports
      put "[[ _FetchHandler (" & hName, hType & ") ]]" into line startLineNum to endLineNum of mergeScript
      
      put word 1 to 2 of handlerTableLine into shortHkeyLine
      put word 3 to 4 of handlerTableLine into hkeyLineNums
      put hkeyLineNums into gLCW ["Hkey Place Array"][shortHkeyLine][rObject]
      
      -- as we may wish to know the local place array
      put hkeyLineNums into scriptPlaceArray [shortHkeyLine][rObject]
   end repeat
   
   text_Set scriptFile, mergeScript
   return scriptPlaceArray
end script_ExportHandlersAndCalls

command script_UpdatePlaceArray someObject
   -- brute force (not optimised for speed)
   hkeyLine_LoadPlaceArray
   hkeyline_DeletePlaceObject someObject
   put hkeyLine_GetPlaceArray() into hkeyPlaceArray
   hkeyline_AddPlaceObject hkeyPlaceArray, someObject
   hkeyLine_SetPlaceArray hkeyPlaceArray
   script_StoreHkeyPlaceArray hkeyPlaceArray
   return hkeyPlaceArray
end script_UpdatePlaceArray


--> Old
-
/*
function menu_GetDefaultController mTitle, targetObject, pSearchScript
   -- key handler in menu_Authoring used by the menu_Update
   -- careful to avoid recursion 
   
   -- check if it is a global menu
   if menu_TitleIsGlobal (mTitle) then
      put menu_GetGlobalController (mTitle) into mController
      if exists (mController) is true then
         return mController
      end if
   end if
   
   -- here we allow sub stack cards to override defaults
   -- put the menu_SubStackCard [mTitle] of targetObject into mController
   -- if exists (mController) then return mController
   
   -- look up menu in script hierarchy (adds a lot of complexity)
   -- put the menu_FindController [mTitle] of targetObject into mController
   -- if exists (mController) then return mController
   
   -- only look in targetObject (not needed as default is targetObject)
   -- put the script of targetObject into mControllerScript
   -- put "-->" && mTitle into mTitleLine
   -- if mTitleLine is among the lines of mControllerScript then return targetObject
   
   return targetObject
end menu_GetDefaultController

getprop menu_FindController [mTitle]
   -- not used for simple "menu_GetDefaultController"
   put the long id of the target into targetObejct
   
   put the script_Hierarchy of targetObejct into scriptHierarchy
   repeat for each line mController in scriptHierarchy
      -- put the menu_Titles of mController into mTitles
      put the script of mController into mControllerScript
      put "-->" && mTitle into mTitleLine
      
      -- should be made fuzzy ussing a regular expression
      if mTitleLine is among the lines of mControllerScript then
         return mController
      end if
   end repeat
   return empty
end menu_FindController
*/
