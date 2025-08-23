script "lib_Introspection"
--> MetaData
-
license: GPLv3
name: lib_Introspection
type: library
version: 0.3


--> Menu | Titles
-
getprop card_MenuTitle
   put the card_Object of the target into cObject
   return line 1 of the script_MenuTitles of cObject
end card_MenuTitle

getprop stack_MenuTitle
   return line 1 of the script_MenuTitles of the defaultstack
end stack_MenuTitle


--> Hkey | Switch
-
getprop menu_CaseConditions [hName]
   put the long id of the target into sObject
   --
   set the itemdelimiter to "_"
   put "M" && "menu_" & item -1 of hName into shortHkey
   put hkey_GetCaseConditions (shortHkey, sObject) into caseConditions
   return caseConditions
end menu_CaseConditions

getprop menu_PickConditions
   put the long id of the target into scriptObject
   put hkey_GetCaseConditions ("M menuPick", scriptObject) into caseConditions
   return caseConditions
end menu_PickConditions

getprop hkey_CaseConditions [shortHKey]
   put the script_Handler [shortHKey] of the target into someHandler
   put handler_ExtractCaseConditions (someHandler) into caseConditions
   return caseConditions
end hkey_CaseConditions

function hkey_GetCaseConditions hKey, pScriptObject
   if exists (pScriptObject) is false then
      hkey_Deconstruct hKey, hName, hType, pScriptObject, hNum
   end if
   --
   put the script_Handler [hKey] of pScriptObject into someHandler
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
   put someScript into theHandlerGroups
   filter theHandlerGroups with "-->*"
   replace "--> " with empty in theHandlerGroups
   replace "-->" with empty in theHandlerGroups
   return theHandlerGroups
end script_GetSuiteTitles


--> Deps
-
getprop script_Handler [shortHKey]
   if shortHKey is empty then return empty
   
   put the long id of the target into hObject
   put the revAvailableHandlers of hObject into hTable
   put the script of hObject into someScript
   put htable_GetHandler (shortHKey, hTable, someScript) into foundHandler
   return foundHandler
end script_Handler

getprop card_Object
   -- ideCoreCardOfcontrol
   -- always returns an object
   put the long id of the target into targetObject
   switch
      case word 1 of targetObject = "card"
         return targetObject
      case word 1 of targetObject = "stack"
         if the scriptonly of targetObject is true then
            return the long id of card 1 of the defaultstack
         else
            put the currentcard of the defaultstack into cardName
            if cardName begins with "card id" then
               put word 3 of cardName into cardID
               put the long id of card id cardID of the defaultstack into cardObject
            else
               put the currentcard of the defaultstack into cardName
               put the long id of card cardName of the defaultstack into cardObject
            end if
            return cardObject
         end if
      case word 1 of targetObject is among the items of "background,bkgnd,bg"
         return empty  -- no such thing as a unique card_Object
      default
         put wordOffset ("card", targetObject) into wNum
         return word wNum to -1 of targetObject
   end switch
end card_Object

getprop script_MenuTitles
   put the script of the target into someScript
   put script_ExtractMenuSuiteTitles (someScript) into scriptMenuTitles
   return scriptMenuTitles
end script_MenuTitles

getprop stack_MenuTitle
   return line 1 of the script_MenuTitles of the defaultstack
end stack_MenuTitle

command hkey_Deconstruct hKey, @hName, @hType, @hObject, @hNum
-- will deconstruct both
-- move over to hkeyLine_Deconstruct

if the number of items of hkey = 1 then
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   put 1 into hNum
else
   -- old version
   put word 1 to -1 of item 1 of hKey into hName
   put word 1 to -1 of item 2 of hKey into hType
   if hType is empty then put "c" into hType
   put word 1 to -1 of item 3 of hKey into hObject
   put item 4 of hKey into hNum
   if hNum is empty then put 1 into hNum
end if

put hKeyLine_Construct (hName, hType, hObject) into hkeyLine
return hkeyLine
end hkey_Deconstruct

command hkeyLine_Deconstruct hKeyLine, @hName, @hType, @hObject
   put toUpper (word 1 of hKeyLine) into hType
   put word 2 of hKeyLine into hName
   put word 4 to -1 of hKeyLine into hObject
   return hType && hName
end hkeyLine_Deconstruct

getprop card_MenuTitle
   put the card_Object of the target into cObject
   return line 1 of the script_MenuTitles of cObject
end card_MenuTitle

getprop hkey_CaseConditions [shortHKey]
   put the script_Handler [shortHKey] of the target into someHandler
   put handler_ExtractCaseConditions (someHandler) into caseConditions
   return caseConditions
end hkey_CaseConditions

function hkey_GetCaseConditions hKey, pScriptObject
   if exists (pScriptObject) is false then
      hkey_Deconstruct hKey, hName, hType, pScriptObject, hNum
   end if
   --
   put the script_Handler [hKey] of pScriptObject into someHandler
   put handler_ExtractCaseConditions (someHandler) into caseConditions
   return caseConditions
end hkey_GetCaseConditions

function hKeyLine_AddObject hkeyLine, tObject
   -- used quite a lot
   put revRuggedID (tObject) into hObject
   put word 1 to 2 of hkeyLine && "of" && hObject into hKeyLine
   return hKeyLine
end hKeyLine_AddObject

function hKeyLine_Construct hName, hType, tObject
   put hType && hName into shortHkeyLine
   if tObject is empty then return shortHkeyLine
   
   put hKeyLine_AddObject (shortHkeyLine, tObject) into hkeyLine
   return hkeyLine
end hKeyLine_Construct

function hTable_GetHandler hkeyLine, hTable, pSomeScript
   if pSomeScript is empty then
      put word 5 to -1 of line 1 of hTable into scriptObject
      if exists (scriptObject) is false then return "Error, cannot find object in hTable:" && scriptObject
      put the script of scriptObject into pSomeScript
   end if
   hkeyLine_Deconstruct hKeyLine, hName, hType, hObject
   
   # Line numbers
   htable_OrLineOffsets hName, hType, hTable, startLineNum, endLineNum
   -- htable_ExactLineOffsets hkeyLine, hTable, startLineNum, endLineNum
   if endLineNum = 0 then return empty
   
   # Handler
   put line startLineNum to endLineNum of pSomeScript into foundHandler
   return foundHandler
end hTable_GetHandler

command htable_OrLineOffsets hName, hType, hTable, @startLineNum, @endLineNum
   repeat for each line hLine in hTable
      if hName is not word 2 of hLine then next repeat
      
      switch
         case hType = word 1 of hLine
         case (hType = "C") AND (word 1 of hLine = "M")
         case (hType = "M") AND (word 1 of hLine = "C")
            put word 3 of hLine into startLineNum
            put word 4 of hLine into endLineNum
            return true
      end switch
   end repeat
   put 0 into startLineNum
   put 0 into endLineNum
   return false
end htable_OrLineOffsets

function script_ExtractMenuSuiteTitles someScript
   put script_GetSuiteTitles (someScript) into suiteTitles
   -- put script_MenuTitleArrayFromSuiteTitles (suiteTitles) into menuTitleArray
   filter suiteTitles with "* | Menu"
   return suiteTitles
   --  return menuTitleArray ["OrderedMenuTitles"]
end script_ExtractMenuSuiteTitles
