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


--> Props
-
setprop menu_Update someBoolean
   -- called by "script_ExportAndIndexMenus" every time we apps (compile) a scriptField 
   put the long id of the target into mController
   menu_ReIndexController mController
   put the result into projectArray
   return projectArray
end menu_Update


--> Working on
-
command menu_ReIndexController mController
   project_AddToKnown mController
   menu_AddToProjectArray mController
   menu_AddToModel mController
   return projectArray
end menu_ReIndexController

command menu_AddToProjectArray mController
   put the menu_GlobalTitle of mController into gMenuTitle
   if gMenuTitle is empty then return "Error, gMenuTitle for mController is faulty:" && mController
   --
   put the project_Name of mController into projectName
   put the project_JsonFile of mController into projectArrayFile
   put array_FetchModel (projectArrayFile) into projectArray
   controller_AddToArray projectArray, gMenuTitle, mController, projectName
   array_SaveModel projectArrayFile, projectArray
   --
   return projectArray
end menu_AddToProjectArray
 

--> Script
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

command script_ExportAndIndexMenus scriptObject, pDeleteOldExports
   -- this is what the IDE compile button dispatches
   -- it is designed to update the global menu index, and export handlers (but do nothing else)
   
   dispatch "script_Compile" to scriptObject with scriptObject,pDeleteOldExports
   switch it
      case "unhandled"
         -- a default
         script_ExportHandlersAndCalls scriptObject, pDeleteOldExports
         put the result into scriptPlaceArray
         put the uRIP["type"] of scriptObject into scriptType
         --
         if scriptType = "controller" then
            menu_ReIndexController scriptObject
            put the result into projectArray
         end if
         break
      case "passed"
      case "handled"
   end switch
end script_ExportAndIndexMenus


--> Menu | Update
-
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
