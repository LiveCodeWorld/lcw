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
