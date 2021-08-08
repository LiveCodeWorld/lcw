script "lib_Introspection"
--> MetaData
-
license: GPLv3
name: lib_Introspection
type: library
version: 0.3


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


--> Hkey | Switch
-
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


--> Handler
-
function handler_ExtractCaseConditions someHandler
   local switchSection, caseConditions
   handler_ParseSwitchStatement someHandler, switchSection, caseConditions
   return caseConditions
end handler_ExtractCaseConditions

command handler_ParseSwitchStatement someHandler, @switchSection, @caseConditions
   /*
   Many ways to do this, doubtless can be (and should be spead up.
   It is called for every handler in a script that has a menu on complile.
   */
   
   local lineNum, startLineNum
   
   repeat for each line someLine in someHandler
      add 1 to lineNum
      if startLineNum is empty and word 1 of someLine = "switch" then
         put lineNum into startLineNum
      end if
      if startLineNum is empty then next repeat
      
      -- here we look for "case"
      if word 1 of someLine = "case" then
         put token 2 of someLine into caseCondition
         if caseCondition is not empty then
            put caseCondition & CR after caseConditions
         end if
      end if
      
      if word 1 to 2 of someLine = "end switch" then
         put lineNum into endLineNum
         exit repeat
      end if
   end repeat
   delete char -1 of caseConditions
   
   if endLineNum is empty then
      put empty into switchSection
      put empty into caseConditions
      return empty
   end if
   put line startLineNum to endLineNum of someHandler into switchSection
end handler_ParseSwitchStatement


--> Script | Menu | Titles
-
function script_OrderedMenuTitles someScript
   filter someScript with "--> * Menu"
   return menuTitles
end script_OrderedMenuTitles

function script_GetSuiteTitles someScript
   -- get rid of
   put someScript into theHandlerGroups
   filter theHandlerGroups with "-->*"
   replace "--> " with empty in theHandlerGroups
   replace "-->" with empty in theHandlerGroups
   return theHandlerGroups
end script_GetSuiteTitles
