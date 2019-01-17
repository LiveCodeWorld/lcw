script "model_HkeyLine"
--> MetaData
-
license: GPLv3
name: model_HkeyLine
type: model
version: 0.2

/*
-- M hkeyLine_Deconstruct of stack "lib_ScriptArray"

This is the new version of the hKey syntax which does not use comma's.
It is also more readable (at the cost of inserting "of' at word 3).

Here we start to collect handlers specifically created for this format, 
and work-in-progress transitional handlers.

See also lib_FindHkey
*/


--> Working on
-
getprop hkey_Lines
   -- latest version of hKeys
   -- see "script_Hkeys" and "script_FirstHkeys"
   
   put the long id of the target into hObject
   put the revAvailableHandlers of hObject into hTable
   put hTable_GetHkeys (hTable, hObject) into hkeyLines
   return hkeyLines
end hkey_Lines

function hkeyLine_ConstructStart hKey
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   switch hType
      case "a"
         put "after" into handlerStartLine
         break
      case "b"
         put "before" into handlerStartLine
         break
      case "m"
      case "c"
         put "command" into handlerStartLine
         break
      case "pc"
         put "private command" into handlerStartLine
         break
      case "f"
         put "function" into handlerStartLine
         break
      case "pf"
         put "private function" into handlerStartLine
         break
      case "g"
         put "getprop" into handlerStartLine
         break
      case "s"
         put "setprop" into handlerStartLine
         break
   end switch
   put space & hName after handlerStartLine
   return handlerStartLine
end hkeyLine_ConstructStart


--> Hkey | Do both
-
function hkey_Construct hName, hType, hObject, pHandlerNum
   if exists (hObject) then
      put revRuggedID (hObject) into hObject
   else
      put "Missing" into hObject
   end if
   
   -- new version
   put hKeyLine_FromTripple (hName, hType, hObject) into hKeyLine
   return hKeyLine
   
   -- old version
   if pHandlerNum is empty then put 1 into pHandlerNum
   return hName,hType,hObject,pHandlerNum
end hkey_Construct

function hkey_FromShort shortHkeys, hObject
   repeat for each line shortHkey in shortHkeys
      hkey_Deconstruct shortHkey, hName, hType, xObject, xNum
      put hKeyLine_FromTripple (hName, hType, hObject) into hkeyLine
      put hkeyLine & CR after hkeyLines
   end repeat
   delete char -1 of hkeyLines
   return hkeyLines
end hkey_FromShort

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
   
   put hKeyLine_FromTripple (hName, hType, hObject) into hkeyLine
   return hkeyLine
end hkey_Deconstruct


--> hKeyLine | Handler
-
function hkeyLine_GetHandlers hkeyLines, hTable, someScript
   repeat for each line hkeyLine in hkeyLines
      put hkeyLine_GetHandler (hkeyLine, hTable, someScript) into foundHandler
      if foundHandler is empty then next repeat
      
      put foundHandler & CR & CR after foundHandlers
   end repeat
   delete char -2 to -1 of foundHandlers
   return foundHandlers
end hkeyLine_GetHandlers

function hkeyLine_GetHandler hkeyLine, hTable, someScript
   -- required by "menu_Update" (was in "lib_MenuAuthoring")
   htable_ExactLineOffsets hkeyLine, hTable, startLineNum, endLineNum
   if endLineNum = 0 then return empty
   put line startLineNum to endLineNum of someScript into foundHandler
   return foundHandler
end hkeyLine_GetHandler


--> hKeyLine
-
command hkeyLine_Normalize @hKey
   put hkeyLine_FromHkey (hKey) into hKey
   put word 1 to 2 of hKey into shortHkey
   return shortHkey
end hkeyLine_Normalize

function hkeyLine_FromHkey hKey
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put hKeyLine_FromTripple (hName, hType, hObject) into hkeyLine
   return hkeyLine
end hkeyLine_FromHkey

function hkeyLine_ToHkey hKeyLine
   -- was "hkey_TableLineToShort"
   hkeyLine_Deconstruct hKeyLine, hName, hType, hObject
   return hName,hType,hObject,1
end hkeyLine_ToHkey

command hkeyLine_DeconstructStart handlerLine, @hName, @hType, @privateBit
   if token 1 of handlerLine = "private" then
      put "p" into privateBit
      put token 3 of handlerLine into hName
   else
      put empty into privateBit
      put token 2 of handlerLine into hName
   end if
   put handler_GetType (handlerLine) into hType
end hkeyLine_DeconstructStart

function hKeyLine_Construct hkeyLine, hObject
   put word 1 to 2 of hkeyLine && "of" && hObject into hKeyLine
   return hKeyLine
end hKeyLine_Construct

command hkeyLine_Deconstruct hKeyLine, @hName, @hType, @hObject
   put toUpper (word 1 of hKeyLine) into hType
   put word 2 of hKeyLine into hName
   put word 4 to -1 of hKeyLine into hObject
   return hType && hName
end hkeyLine_Deconstruct

function hKeyLine_FromTripple hName, hType, hObject
   replace "c" with "M" in hType
   put toUpper (hType) && hName into shortHkeyLine
   if hObject is empty then return shortHkeyLine
   
   put hKeyLine_Construct (shortHkeyLine, hObject) into hkeyLine
   return hkeyLine
end hKeyLine_FromTripple
