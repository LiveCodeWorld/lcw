script "model_HkeyLine"
--> MetaData
-
license: GPLv3
name: model_HkeyLine
type: model
version: 0.2

/*
-- M hKeyLine_Deconstruct of stack "lib_ScriptArray"

This is the new version of the hKey syntax which does not use comma's.
It is also more readable (at the cost of inserting "of' at word 3).

here we start to collect handlers specifically created for this format, 
and work-in-progress transitional handlers.
*/


--> Working on
-
-- function hkeyLine_ExtractExternal hTableLines, hkeyPlaceArray
-- was "script_ExtractExternalHkeys"
repeat for each line hTableLine in hTableLines
   put hkey_GetPlace (hTableLine, hkeyPlaceArray) into cObject
   put hTableLine,cObject into externalKey
   put externalKey & CR after externalKeys
end repeat
delete char -1 of externalKeys
return externalKeys
end hkeyLine_ExtractExternal

function hkeyline_MakeShort handlerTable
   repeat for each line someLine in handlerTable
      put word 1 to 2 of someLine into hTableLine
      put hTableLine & CR after hTableLines
   end repeat
   delete char -1 of hTableLines
   return hTableLines
end hkeyline_MakeShort


--> Hkey
-
command hkey_Edit hKey
   -- use instead of "hkey_EditFoundHandler"   
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the result into hkeyLine
   
   if exists (hObject) is false then
      put hkeyLine_GetPlaces (hkeyLine) into hObjects
      switch
         case hObjects is empty
            display_SpotlightHandler hkeyLine
            return false
         case the number of lines of  hObjects > 1
            repeat for each line hObject in hObjects
               put hKeyLine_Construct (hkeyLine, hObject) & CR after  hkeyLines
            end repeat
            delete char -1 of hkeyLines
            
            put handler_ConstructStartLine (hkeyLine) into handlerStartLine
            put merge ("[[handlerStartLine]],hkeyLine_GetPlaces() found") into someTitle
            display_HkeyLines hkeyLines, someTitle
            return false
         default
            put line 1 of hObjects into hObject
      end switch
      
      if exists (hObject) is false then
         put hObject & CR & hKey
         breakpoint
         return fale
      end if
   end if
   
   put the revAvailableHandlers of hObject into hTable
   sort numeric hTable by word 3 of each
   
   set the wholematches to false
   -- put hKeyLine_FromTripple (hName, hType) & space into searchString
   put word 1 to 2 of hkeyLine & space into searchString
   put lineoffset (searchString, hTable) into foundLineNum
   if foundLineNum = 0 then
      display_ExecutionContexts
      breakpoint
      
      -- could find another version?
      hkeyline_DeletePlaceArray hkeyLine
      -- could remove old version?
      
      put searchString
      edit the script of hObject
      return false
   end if
   
   get line foundLineNum of hTable
   put word 3 of it into startLineNum
   put word 4 of it into endLineNum
   put line startLineNum to endLineNum of the script of hObject into foundHandler
   
   lock screen
   put rev_ScriptEditorIsOpen() into wasAlreadyOpen
   if wasAlreadyOpen is true then
      rev_ActivateScriptEditorTab hObject
      if the result is false then
         edit the script of hObject
      end if
   else
      edit the script of hObject
      wait 5 ticks
   end if
   
   rev_SetSelectedHandlerTreeLineNum foundLineNum   
   unlock screen
   return true
end hkey_Edit

function hkey_Construct hName, hType, hObject, pHandlerNum
   if exists (hObject) then
      put revRuggedID (hObject) into hObject
   else
      put "Missing" into hObject
   end if
   if pHandlerNum is empty then put 1 into pHandlerNum
   return hName,hType,hObject,pHandlerNum
end hkey_Construct

command hkey_Deconstruct hKey, @hName, @hType, @hObject, @hNum
   if the number of items of hkey = 1 then
      hKeyLine_Deconstruct hKey, hName, hType, hObject
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


--> hKeyLine | Fetch
-
function hkeyLine_FetchHandler hKeyLine
   hKeyLine_Deconstruct hKeyLine, hName, hType, hObject
   if exists (hObject) is false then return empty
   put the data_Folder of hObject into dataFolder
   put handler_Fetch (hKeyLine, dataFolder) into someHandler
   return someHandler
end hkeyLine_FetchHandler

function hkeyLine_FetchCalls hKeyLine
   hKeyLine_Deconstruct hKeyLine, hName, hType, hObject
   if exists (hObject) is false then return empty
   put the data_Folder of hObject into dataFolder
   put handler_FetchCalls (hKeyLine, dataFolder) into shortCalls
   return shortCalls
end hkeyLine_FetchCalls

command hkeyLine_FindInTable hkeyLine, hTable, @startLineNum, @endLineNum
   set the wholematches to false
   put word 1 to 2 of hkeyLine & space into searchString
   put lineOffset (searchString, hTable) into lineNum
   if lineNum = 0 then
      put 0 into startLineNum
      put 0 into endLineNum
      return false
   end if
   
   put line lineNun of hTable into hTableLine
   put word 3 of hTableLine into startLineNum
   put word 4 of hTableLine into endLineNum
   return true
end hkeyLine_FindInTable


--> hKeyLine
-
function hkeyLine_ToHkey hKeyLine
   -- was "hkey_TableLineToShort"
   hKeyLine_Deconstruct hKeyLine, hName, hType, hObject
   return hName,hType,hObject,1
end hkeyLine_ToHkey

function hKeyLine_FromTripple hName, hType, hObject
   replace "c" with "M" in hType
   put toUpper (hType) && hName into shortHkeyLine
   if hObject is empty then return shortHkeyLine
   
   put hKeyLine_Construct (shortHkeyLine, hObject) into hkeyLine
   return hkeyLine
end hKeyLine_FromTripple

function hKeyLine_Construct hkeyLine, hObject
   put word 1 to 2 of hkeyLine && "of" && hObject into hKeyLine
   return hKeyLine
end hKeyLine_Construct

command hKeyLine_Deconstruct hKeyLine, @hName, @hType, @hObject
   put word 1 of hKeyLine into hType
   put word 2 of hKeyLine into hName
   put word 4 to -1 of hKeyLine into hObject
   return hType && hName
end hKeyLine_Deconstruct

command hkeyLine_Normalise @hKey
   put hkeyLine_FromHkey (hKey) into hKey
end hkeyLine_Normalise

function hkeyLine_FromHkey hKey
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put hKeyLine_FromTripple (hName, hType, hObject) into hkeyLine
   return hkeyLine
end hkeyLine_FromHkey


--> Handler | Construct
-
function handler_ConstructStartLine hKey
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
end handler_ConstructStartLine

command handler_Deconstruct handlerLine, @handlerName, @hType, @privateBit
   if token 1 of handlerLine = "private" then
      put "p" into privateBit
      put token 3 of handlerLine into handlerName
   else
      put empty into privateBit
      put token 2 of handlerLine into handlerName
   end if
   put handler_GetType (handlerLine) into hType
end handler_Deconstruct
