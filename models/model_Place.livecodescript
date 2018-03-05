script "model_Place"
--> MetaData
-
license: GPLv3
name: model_Place
type: model
version: 0.2

/*
The idea is that we should make it seriously easy to create a model for where stacks or assets are on disk.
*/


--> Working on
-

--> Place | Get
-
function hkey_GetPlace hTableLine, pHkeyPlaceArray
   put hkeyLine_GetPlaces (hTableLine, pHkeyPlaceArray) into hKeyObjects
   
   -- hack to fix broken indexing due to not removing old places when a script moves
   if the number of lines of hKeyObjects > 1 then
      breakpoint
   end if
   put line 1 of hKeyObjects into cObject
   return cObject
end hkey_GetPlace

function hkeyLine_GetPlaces hTableLine, pHkeyPlaceArray
   put word 1 to 2 of hTableLine into shortHkeyLine
   if pHkeyPlaceArray is not an array then
      put hkeyLine_GetPlaceArray() into pHkeyPlaceArray
   end if
   put pHkeyPlaceArray [shortHkeyLine] into objectPlaceArray
   return keys (objectPlaceArray)
end hkeyLine_GetPlaces


--> Script | HkeyPlaceArray | Model
-
function script_FetchHkeyPlaceArray
   put lcw_FetchArray ("lcw_HkeyPlaceObject.array") into hkeyPlaceArray
   return hkeyPlaceArray
end script_FetchHkeyPlaceArray

command script_StoreHkeyPlaceArray hkeyPlaceArray
   lcw_StoreArray "lcw_HkeyPlaceObject.array", hkeyPlaceArray
   return the result
end script_StoreHkeyPlaceArray


--> hkeyLine | Utils
-
getprop script_HkeyPlaceArray
   -- make as fast as possible as we use to generate index for entire project
   local hkeyPlaceArray
   put the long id of the target into tObject
   hkeyline_AddPlaceObject hkeyPlaceArray, tObject
   return hkeyPlaceArray
end script_HkeyPlaceArray


--> Script | HkeyPlaceArray
-
command hkeyline_AddPlaceObject @hkeyPlaceArray, someObject
   -- we try here as this is used in repeat loops to create long indexes and we don't want to loose the work
   try
      put the revAvailableHandlers of someObject into handlerTable
      put revRuggedID (someObject) into rObject
      hkeyLine_AddToPlaceArray hkeyPlaceArray, rObject, handlerTable
   catch someError
      return empty -- a locked stack (or object does not exist)
   end try
end hkeyline_AddPlaceObject

command hkeyLine_AddPlace handlerTableLine, rObject
   -- could add someHandler or a hash?
   -- needs to be as fast as possible (used on compile)
   
   global gLCW
   put word 1 to 2 of handlerTableLine into shortHkeyLine
   put word 3 to 4 of handlerTableLine into hkeyLineNums
   put hkeyLineNums into gLCW ["Hkey Place Array"][shortHkeyLine][rObject]
end hkeyLine_AddPlace

command hkeyline_DeletePlaceObject someObject
   -- not called on compile anymore
   
   global gLCW
   put the long id of someObject into someObject
   put gLCW ["Hkey Place Array"] into hkeyPlaceArray
   repeat for each key shortHkeyLine in hkeyPlaceArray
      put hkeyPlaceArray [shortHkeyLine] into shortPlaceArray
      repeat for each key tObject in shortPlaceArray
         put shortPlaceArray [tObject] into lineNumWords
         if exists (tObject) is false then
            next repeat
         end if
         
         put the long id of tObject into testLongObject
         if testLongObject = someObject then
            put hKeyLine_Construct (shortHkeyLine, tObject) into hKeyLine
            put lineNumWords into deletedHkeyArray [hKeyLine][shortHkeyLine][tObject]
            delete variable gLCW ["Hkey Place Array"][shortHkeyLine][tObject]
         end if
      end repeat
   end repeat
   
   put the keys of deletedHkeyArray into deletedHkeyLines
   return deletedHkeyLines
end hkeyline_DeletePlaceObject

command hkeyLine_AddToPlaceArray @hkeyPlaceArray, rObject, handlerTable
   repeat for each line someLine in handlerTable
      put word 1 to 2 of someLine into hTableKey
      put word 3 to 4 of someLine into hTableLines
      put hTableLines into hkeyPlaceArray [hTableKey][rObject]
   end repeat
end hkeyLine_AddToPlaceArray


--> hkeyLine | Place
-
command hkeyLine_LoadPlaceArray
   -- combines what is in the global with the stored array on disk
   -- preserving the values in the global
   -- it does not save the new global array to disk
   -- but return ti so that you can save it yourself in your script
   
   put script_FetchHkeyPlaceArray() into storedPlaceArray
   put hkeyLine_GetPlaceArray() into placeArray
   union placeArray with storedPlaceArray
   hkeyLine_SetPlaceArray placeArray
   return placeArray
end hkeyLine_loadPlaceArray

function hkeyLine_GetPlaceArray
   global gLCW
   put gLCW ["Hkey Place Array"] into placeArray
   return placeArray
end hkeyLine_GetPlaceArray

command hkeyLine_SetPlaceArray placeArray
   global gLCW
   put placeArray into gLCW ["Hkey Place Array"]
end hkeyLine_SetPlaceArray


--> Script | HkeyPlaceArray
-
command hkeyline_DeletePlaceArray hkeyLine
   hKeyLine_Deconstruct hKeyLine, hName, hType, hObject
   put hkeyLine_FetchDuplicateArray (hkeyLine) into duplicateArray
   delete variable duplicateArray [hObject]
   hkeyLine_StoreDuplicateArray hkeyLine, duplicateArray
   return duplicateArray
end hkeyline_DeletePlaceArray


--> Script | HkeyPlaceArray | Duplicates
-
function hkeyLine_FetchDuplicateArray hkeyLine, pHkeyPlaceArray
   if pHkeyPlaceArray is empty then put script_FetchHkeyPlaceArray() into pHkeyPlaceArray
   put word 1 to 2 of hkeyLine into shortHkeyLine
   put pHkeyPlaceArray [shortHkeyLine] into duplicateArray
   return duplicateArray
end hkeyLine_FetchDuplicateArray

command hkeyLine_StoreDuplicateArray hkeyLine, duplicateArray
   put script_FetchHkeyPlaceArray() into hkeyPlaceArray
   put word 1 to 2 of hkeyLine into shortHkeyLine
   put duplicateArray into hkeyPlaceArray [shortHkeyLine]
   script_StoreHkeyPlaceArray hkeyPlaceArray
   return duplicateArray
end hkeyLine_StoreDuplicateArray
