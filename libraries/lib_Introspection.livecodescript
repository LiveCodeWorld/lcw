script "lib_Introspection"
--> MetaData
-
license: GPLv3
name: lib_Introspection
type: library
version: 0.3


--> Working on
-
--> Update | Script
-
command script_ExportAndIndexMenus scriptObject, pExportCalls
   -- this is watch the IDE compile button dispatches
   -- so far nothing else calls this command
   -- it is designed to update the global menu index, and export handlers (but do nothing else)
   -- it can be optimised to ony loop through the script once (instead of twise as below)
   
   set the menu_Update of scriptObject to true
   script_ExportHandlersAndCalls scriptObject, pExportCalls
   put the script_File of scriptObject into scriptFile
   return scriptFile
end script_ExportAndIndexMenus

command script_ExportHandlersAndCalls someObject, pExportCalls, pScript, pDataFolder
   global gLCW
   if the optionKey is "Down" then
      set the cursor to watch
      hkeyline_DeletePlaceObject someObject -- this is too slow
   end if
   
   if pScript is empty then put the script of someObject into pScript
   urip_Update someObject, pScript
   
   put the revAvailableHandlers of someObject into handlerTable
   if handlerTable is empty then return empty -- everything is deleted before re-exporting
   
   if pDataFolder is empty then
      put the data_Folder [true] of someObject into pDataFolder
      if pDataFolder is empty then
         breakpoint
      end if
   end if
   
   if pExportCalls is true then
      -- this also deletes the "lcw_calls.txt" files
      -- which is fine if we are rebuilding them
      -- possible consider saving those files in a separate metadata folder
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
      if hName = "_" then next repeat -- could check handler is empty ?
      put word 3 of handlerTableLine into startLineNum
      put word 4 of handlerTableLine into endLineNum
      
      put line startLineNum to endLineNum of pScript into someHandler
      handler_Save handlerTableLine, pDataFolder, someHandler, pExportCalls
      
      put "[[ _FetchHandler (" & hName, hType & ") ]]" into line startLineNum to endLineNum of mergeScript
      
      -- hkeyLine_AddPlace handlerTableLine, rObject
      put word 1 to 2 of handlerTableLine into shortHkeyLine
      put word 3 to 4 of handlerTableLine into hkeyLineNums
      put hkeyLineNums into gLCW ["Hkey Place Array"][shortHkeyLine][rObject]
      
      -- as we may wish to know the local place array
      put hkeyLineNums into scriptPlaceArray [shortHkeyLine][rObject]
   end repeat
   
   script_SaveRaw scriptFile, mergeScript
   
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


--> menu_Update | Deps
-
function script_OrderedMenuTitles someScript
   filter someScript with "--> * Menu"
   return menuTitles
end script_OrderedMenuTitles

function script_MenuToolModeArray someScript
   local menuToolModeArray
   put script_GetSuiteTitles (someScript) into suiteTitles
   
   set the itemdelimiter to "|"
   put "Menu \((.*)\)" into regularExpression
   put empty into menuTitles
   set the wholematches to true
   repeat for each line suiteTitle in suiteTitles
      put word 1 to -1 of last item of suiteTitle into lastMenuItem
      if lastMenuItem is among the items of "Menu|Menus|Submenu|Submenus" then
         put suiteTitle & CR after menuTitles
         put empty into menuToolModeArray [suiteTitle]
      else if matchtext (lastMenuItem, regularExpression, toolMode) is true then
         put suiteTitle & CR after menuTitles
         put toolMode into menuToolModeArray [suiteTitle]
      end if
   end repeat
   delete last char of menuTitles
   put menuTitles into menuToolModeArray ["OrderedMenuTitles"]
   return menuToolModeArray
end script_MenuToolModeArray

function script_GetSuiteTitles someScript
   -- get rid of
    put someScript into theHandlerGroups
    filter theHandlerGroups with "-->*"
    replace "--> " with empty in theHandlerGroups
    replace "-->" with empty in theHandlerGroups
    return theHandlerGroups
 end script_GetSuiteTitles
 
 
 --> Hkey | Switch
 -
 getprop menu_PickConditions
   put the long id of the target into scriptObject
   put hkey_GetCaseConditions ("menuPick,m", scriptObject) into caseConditions
   return caseConditions
end menu_PickConditions

getprop hkey_CaseConditions [shortHKey]
   put the long id of the target into scriptObject
   put hkey_GetCaseConditions (shortHKey, scriptObject) into caseConditions
   return caseConditions
end hkey_CaseConditions

function hkey_GetCaseConditions hKey, scriptObject
   if the number of items of hKey = 4 and scriptObject is empty then put item 3 of hKey into scriptObject
   put the script_Handler [hKey] of scriptObject into someHandler
   put handler_ExtractCaseConditions (someHandler) into caseConditions
   return caseConditions
end hkey_GetCaseConditions

function script_ExtractSwitchSection someHandler
   local switchSection, caseConditions
   handler_ParseSwitchStatement someHandler, switchSection, caseConditions
   return switchSection
end script_ExtractSwitchSection
