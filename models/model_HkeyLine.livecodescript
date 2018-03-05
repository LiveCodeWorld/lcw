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

Here we start to collect handlers specifically created for this format, 
and work-in-progress transitional handlers.

See also lib_FindHkey
*/


--> Working on
-

--> Hkey | Edit
-
command hkey_FancyEdit hKey
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
         return false
      end if
   end if
   
   put the revAvailableHandlers of hObject into hTable
   sort numeric hTable by word 3 of each
   
   set the wholematches to false
   -- put hKeyLine_FromTripple (hName, hType) & space into searchString
   put word 1 to 2 of hkeyLine & space into searchString
   put lineoffset (searchString, hTable) into foundLineNum
   if foundLineNum = 0 then
      breakpoint
      put searchString
      edit the script of hObject
      return false
   end if
   
   get line foundLineNum of hTable
   put word 3 of it into startLineNum
   put word 4 of it into endLineNum
   put line startLineNum to endLineNum of the script of hObject into foundHandler
   
   lock screen
   put scriptEditor_IsOpen() into wasAlreadyOpen
   if wasAlreadyOpen is true then
      scriptEditor_ActivateTab hObject
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
end hkey_FancyEdit


--> hKeyLine
-
command hkeyLine_Normalise @hKey
   put hkeyLine_FromHkey (hKey) into hKey
   put word 1 to 2 of hKey into shortHkey
   return shortHkey
end hkeyLine_Normalise

function hkeyLine_FromHkey hKey
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put hKeyLine_FromTripple (hName, hType, hObject) into hkeyLine
   return hkeyLine
end hkeyLine_FromHkey

function hkeyLine_ToHkey hKeyLine
   -- was "hkey_TableLineToShort"
   hKeyLine_Deconstruct hKeyLine, hName, hType, hObject
   return hName,hType,hObject,1
end hkeyLine_ToHkey

function hkey_FromShort shortHkeys, hObject
   repeat for each line shortHkey in shortHkeys
      hkey_Deconstruct shortHkey, hName, hType, xObject, xNum
      put hKeyLine_FromTripple (hName, hType, hObject) into hkeyLine
      put hkeyLine & CR after hkeyLines
   end repeat
   delete char -1 of hkeyLines
   return hkeyLines
end hkey_FromShort

function hkeyline_MakeShort hTable
   repeat for each line someLine in hTable
      put word 1 to 2 of someLine into hTableLine
      put hTableLine & CR after hTableLines
   end repeat
   delete char -1 of hTableLines
   return hTableLines
end hkeyline_MakeShort


--> hkeyLine | FindInTable
-
/*
Work out if repeat of lineOffset is faster and standardize.
*/

command hkey_FindInTable shortHkey, hTable, @startLineNum, @endLineNum
   -- see also "hkeyLine_FindInTable"
   -- uses repeat instead of lineOffset
   
   if hTable is empty then
      put 0 into startLineNum
      put 0 into endLineNum
      return false
   end if
   hkey_Deconstruct shortHkey, hName, hType, xObject, xNum
   
   switch char -1 of hType
      case "c"
         put "M" into char -1 of hType
         break
      case "o"
         put "M" into char -1 of hType
         break
   end switch
   
   repeat for each line someLine in hTable      
      put word 2 of someLine into hTableName
      if hTableName is not hName then next repeat
      
      put word 1 of someLine into hTableType
      switch
         case hTableType = hType
            put word 3 of someLine into startLineNum
            put word 4 of someLine into endLineNum
            return true
      end switch
      
      add 1 to handlerLineNum
   end repeat
   put 0 into startLineNum
   put 0 into endLineNum
   return false
end hkey_FindInTable


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
