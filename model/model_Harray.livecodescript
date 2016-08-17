script "model_Harray"
--> MetaData
-
license: GPLv3
name: model_Harray
type: model
version: 0.8

/*
This model wraps a complex multidimensional array that stores lot's of information about scripts, handlers and objects in the Livecode environment.
It is mistakenly labeled and stored in the global variable gLCW. It should ratehr be called gHarray (for "handler array" or simply gLiveCodeWorld.

Most of the handelrs here have been designed to work with parameters rather than directly with the global variable.
In the future we look to store this data in an sqlite, or possible graph database.
*/


--> hArray | Model
-
command hArray_LoadGlobal
   global gLCW
   put hArray_FetchData() into gLCW
end hArray_LoadGlobal

command hArray_StoreGlobal
   global gLCW
   hArray_StoreData gLCW
end hArray_StoreGlobal

command hArray_DeleteArrayDatabase
   global gLCW
   delete variable gLCW
end hArray_DeleteArrayDatabase

function hArray_FetchData
   put library_FetchArray ("Hkey_Data") into hArray
   return hArray
end hArray_FetchData

command hArray_StoreData hArray
   library_StoreArray "Hkey_Data", hArray
end hArray_StoreData


--> hArray
-
function hArray_ConstructHkeySuiteArray mainstackHarray
   local scriptObjectSuiteArray
   put mainstackHarray ["scriptArray"] into rObjectArray
   repeat for each key rObject in rObjectArray
      put rObjectArray [rObject]["data"]["script_DataArray"] into scriptDataArray
      
      repeat for each key indexNum in scriptDataArray
         put scriptDataArray [indexNum]["hkey"] into hKey
         if hKey is empty then next repeat
         put scriptDataArray [indexNum]["suiteTitle"] into suiteTitle
         if suiteTitle is empty then put "No Suite Title" into suiteTitle
         put item 2 of extents (scriptObjectSuiteArray [rObject]["suite"][suiteTitle]["data"]) + 1 into handlerInSuiteNum
         put empty into scriptObjectSuiteArray [rObject]["suite"][suiteTitle]["data"][handlerInSuiteNum][hKey]
      end repeat
   end repeat
   return scriptObjectSuiteArray
end hArray_ConstructHkeySuiteArray


--> Harray | Handler
-
function hArray_GetHandler hKey, pHarray, pCheckHash
   put item 3 of hKey into hObject
   if exists (hObject) is false then
      breakpoint
      return empty
   end if
   try
      put the script of hObject into someScript
   catch e
      opn_Notify (hObject && "script is locked!"), true
      return empty
   end try
   
   put hArray_GetObjectData (hObject, "script_DataArray", pHarray) into scriptArray
   repeat for each key indexNum in scriptArray
      put scriptArray [indexNum]["hkey"] into testHkey
      if testHkey = hKey then
         put scriptArray [indexNum]["startLineNum"] into startLineNum
         put scriptArray [indexNum]["endLineNum"] into endLineNum
         put line startLineNum to endLineNum of someScript into someHandler
         switch
            case pCheckHash is not false
               return someHandler
            case sha1_Hash (someHandler) = scriptArray [indexNum]["sha1"]
               return someHandler
            default
               return empty
         end switch
      end if
   end repeat
   -- breakpoint -- should re-index and try again
   return empty
end hArray_GetHandler


--> Script | Array
-
function hArray_ConstructScriptArray someScript, someObject, pIndexSuites, pIsExpanded
   -- does the same as script_ConstructArray
   object_AddToGlobalArray someObject, pIsExpanded
   put the object_ScriptDataArray of someObject into dataArray
   if pIndexSuites is false then
      hArray_StripSuitesFromScriptDataArray dataArray
   end if
   return dataArray
end hArray_ConstructScriptArray

command hArray_StripSuitesFromScriptDataArray @dataArray
   repeat for each key indexNum in dataArray
      put dataArray [indexNum]["hKey"] into hKey
      if hKey is empty then
         delete dataArray [indexNum]["hKey"]
      end if
   end repeat
end hArray_StripSuitesFromScriptDataArray


--> hArray | Object | Types
-
function hArray_ListFrontLibraries
   put hArray_ListObjectsOfType ("frontscript") into rObjects
   return rObjects
end hArray_ListFrontLibraries

function hArray_ListBackLibraries
   put hArray_ListObjectsOfType ("backscript") into rObjects
   return rObjects
end hArray_ListBackLibraries

function hArray_ListUsedLibraries
   put hArray_ListObjectsOfType ("library") into rObjects
   return rObjects
end hArray_ListUsedLibraries

function hArray_ListViews
   put hArray_ListObjectsOfType ("view") into rObjects
   return rObjects
end hArray_ListViews

function hArray_ListViewTemplates
   put hArray_ListObjectsOfType ("view template") into rObjects
   return rObjects
end hArray_ListViewTemplates

function hArray_ListModels
   put hArray_ListObjectsOfType ("model") into rObjects
   return rObjects
end hArray_ListModels

function hArray_GetNamedObjectType viewName, objectType
   put hArray_GetObjectTypeArray (objectType) into typeArray
   repeat for each key rObject in typeArray
      put hArray_GetUripArray (rObject, "name") into objectViewName
      if objectViewName = viewName then
         return rObject
      end if
   end repeat
   return empty
end hArray_GetNamedObjectType

function hArray_ConstructTypeNameObjectArray
   local typeNameObjectArray
   put hArray_GetObjectTypeData() into objectTypeData
   
   repeat for each key objectType in objectTypeData
      put objectTypeData [objectType] into objectTypeArray
      repeat for each key rObject in objectTypeArray
         put hArray_GetUripArray (rObject, "name") into uripName
         put empty into typeNameObjectArray [objectType][uripName][rObject]
      end repeat
   end repeat
   return typeNameObjectArray
end hArray_ConstructTypeNameObjectArray

function hArray_ListObjectNamesOfType objectType
   put hArray_ConstructNameObjectArray (objectType) into nameObjectArray
   return keys (nameObjectArray)
end hArray_ListObjectNamesOfType

function hArray_ConstructNameObjectArray objectType
   local nameTypeArray
   put hArray_GetObjectTypeArray (objectType) into objectTypeArray
   repeat for each key rObject in objectTypeArray
      if exists (rObject) is false then
         next repeat
      end if
      put hArray_GetUripArray (rObject, "name") into uripName
      if uripName is empty then
         delete variable objectTypeArray [rObject]
         hArray_SetObjectTypeArray objectType, objectTypeArray
         
         put the mobile_Name of rObject into mObject
         put mObject && "has no uRIP ['name']." & CR & CR & "Removed it from gLCW!" into someMessage
         opn_Notify someMessage, true
         next repeat
      else
         put empty into nameTypeArray [uripName][rObject]
      end if
   end repeat
   return nameTypeArray
end hArray_ConstructNameObjectArray

function hArray_ListObjectsOfType objectType
   put hArray_GetObjectTypeArray (objectType) into objectArray
   return keys (objectArray)
end hArray_ListObjectsOfType

function hArray_GetObjectTypeArray objectType
   put hArray_GetObjectTypeData() into objectTypeData
   return objectTypeData [objectType]
end hArray_GetObjectTypeArray

command hArray_SetObjectTypeArray objectType, objectTypeArray, pHarray
   put hArray_GetObjectTypeData (pHarray) into objectTypeData
   put objectTypeArray into objectTypeData [objectType]
   hArray_SetObjectTypeData objectTypeData, pHarray
end hArray_SetObjectTypeArray

function hArray_GetObjectTypeData pHarray
   if pHarray is an array then
      return pHarray ["objectType"]
   else
      global gLCW
      return gLCW ["objectType"]
   end if
end hArray_GetObjectTypeData

command hArray_SetObjectTypeData objectTypeData, pHarray
   if pHarray is an array then
      put objectTypeData into pHarray ["objectType"]
      return pHarray
   else
      global gLCW
      put objectTypeData into gLCW ["objectType"]
      return gLCW
   end if
end hArray_SetObjectTypeData

function hArray_ListObjectTypes
   put hArray_GetObjectTypeData() into objectTypeArray
   return keys (objectTypeArray)
end hArray_ListObjectTypes

function hArray_ListFirstObjectHkeys rObject
   put the hArray_FirstKeyArray of the target into someArray
   put keys(someArray) into shortHkeys
   repeat for each line shortHkey in shortHkeys
      put shortHkey,rObject,1 & CR after hKeys
   end repeat
   delete char -1 of hKeys
   return hKeys
end hArray_ListFirstObjectHkeys

function hArray_GetObjectScriptArray rObject
   return hArray_GetObjectData (rObject, "script_DataArray")
end hArray_GetObjectScriptArray

function hArray_ObjectIsIndexStatus rObject, pHarray
   put hArray_GetObjectMetaData (rObject, "sha1", pHarray) into scriptHash
   try
      put the script of rObject into someScript
      return sha1_Hash (someScript) = scriptHash
   catch e
      return empty
   end try
end hArray_ObjectIsIndexStatus

function hArray_GetObjectData rObject, pKey, pHarray
   put hArray_GetObjectArray (rObject, pHarray) into objectArray  
   if pKey is empty then
      return objectArray ["data"]
   else
      return objectArray ["data"][pKey]
   end if
end hArray_GetObjectData

function hArray_GetUripArray rObject, pKey, pHarray
   put hArray_GetObjectArray (rObject, pHarray) into objectArray
   if pKey is empty then
      return objectArray ["metadata"]["uripArray"]
   else
      return objectArray ["metadata"]["uripArray"][pKey]
   end if
end hArray_GetUripArray

function hArray_GetObjectMetaData rObject, pKey, pHarray
   put hArray_GetObjectArray (rObject, pHarray) into objectArray  
   if pKey is empty then
      return objectArray ["metadata"]
   else
      return objectArray ["metadata"][pKey]
   end if
end hArray_GetObjectMetaData

command hArray_SetObjectMetaData rObject, arrayOrValue, pKey
   put hArray_GetObjectArray (rObject) into objectArray  
   if pKey is empty then
      put arrayOrValue into objectArray ["metadata"]
   else
      put arrayOrValue into objectArray ["metadata"][pKey]
   end if
   hArray_SetObjectArray rObject, objectArray
end hArray_SetObjectMetaData


--> hArray | keywords
-
function hArray_ListHkeyObjects hKey
   put item 1 to 2 of hKey into shortHkey
   put hArray_GetFoundHkeyArray (shortHkey) into hkeyArray
   put keys (hkeyArray) into foundHkeys
   repeat for each line foundHkey in foundHkeys
      put item 3 of foundHkey & CR after foundObject
   end repeat
   return foundObject
end hArray_ListHkeyObjects

function hArray_GetHandlerHash hKey, pHArray
   put hArray_GetHkeyDataArray (hKey, pHArray) into handlerArray
   put handlerArray ["sha1"] into handlerHash
   return handlerHash
end hArray_GetHandlerHash

function hArray_GetHandlerLine hKey, pHArray
   put hArray_GetHkeyDataArray (hKey, pHArray) into handlerArray
   put handlerArray ["handlerLine"] into handlerLine
   return handlerLine
end hArray_GetHandlerLine

function hArray_GetHkeyDataArray hKey, pHArray
   put item 3 of hKey into hObject
   put hArray_GetObjectData (hObject, "script_DataArray", pHArray) into scriptArray
   repeat for each key indexNum in scriptArray
      put scriptArray [indexNum]["hkey"] into testHkey
      if testHkey = hKey then
         return scriptArray [indexNum]
      end if
   end repeat
   return empty
end hArray_GetHkeyDataArray

function hArray_FindHkey shortHkey, pHandlerHash
   -- a fast lookup that ignores hierarchy
   put item 1 to 2 of shortHkey into shortHkey
   
   put hArray_GetFoundHkeyArray (shortHkey) into hkeyArray
   if hkeyArray is not an array and char 1 of item 2 of shortHkey is not "p" then
      put "p" before char 1 of item 2 of shortHkey
      put hArray_GetFoundHkeyArray (shortHkey) into hkeyArray
   end if
   
   if pHandlerHash is empty then
      put line 1 of the keys of hkeyArray into foundHKey
      return foundHKey
   else
      repeat for each key hKey in hkeyArray
         if hkeyArray [hKey]["handlerHash"] = pHandlerHash then
            return hKey
         end if
      end repeat
      return empty
   end if
end hArray_FindHkey

function hArray_GetFoundHkeyArray hKey, pHArray
   put item 1 to 2 of hKey into shortHkey
   if pHArray is an array then
      return pHArray ["handlerArray"][shortHkey]
   else
      global gLCW
      return gLCW ["handlerArray"][shortHkey]
   end if
end hArray_GetFoundHkeyArray

function hArray_ShortKeyHash hKey
   global gLCW
   put item 1 to 2 of hKey into shortHkey
   put gLCW ["handlerArray"][shortHkey]["handlerHash"] into latestShortkeyHash
   return latestShortkeyHash
end hArray_ShortKeyHash

function hArray_GetKeywordArray pKWord
   global gLCW
   
   if pKWord is empty then
      return gLCW ["keywordArray"]
   else
      return gLCW ["keywordArray"][pKWord]
   end if
end hArray_GetKeywordArray

command hArray_SetKeywordArray keywordArray, pKWord
   global gLCW
   if kWord is empty then
      put keywordArray into gLCW ["keywordArray"]
   else
      put keywordArray into gLCW ["keywordArray"][pKWord]
   end if
end hArray_SetKeywordArray

function hArray_ListAllObjects pHarray
   if pHarray is an array then
      global gLCW
      put gLCW ["scriptArray"] into rObjectArray
   else
      put pHarray ["scriptArray"] into rObjectArray
   end if
   put keys (rObjectArray) into rObjects
   return rObjects
end hArray_ListAllObjects

function hArray_FetchObjectArray scriptObject
   put revRuggedID (scriptObject) into rObject
   put the textStack_Folder of rObject into mainStackFolder
   put mainstack_FetchHarray (mainStackFolder) into hArray
   return hArray_GetObjectArray (rObject, hArray)
end hArray_FetchObjectArray

function hArray_GetObjectArray rObject, pHarray
   if pHarray is an array then
      if rObject is empty then
         return pHarray ["scriptArray"]
      else
         return pHarray ["scriptArray"][rObject]
      end if
   else
      global gLCW   
      if rObject is empty then
         return gLCW ["scriptArray"]
      else
         return gLCW ["scriptArray"][rObject]
      end if
   end if
end hArray_GetObjectArray

command hArray_SetObjectArray rObject, objectArray, pHarray
   if pHarray is an array then
      put objectArray into pHarray ["scriptArray"][rObject]
      return pHarray
   else
      global gLCW
      put objectArray into gLCW ["scriptArray"][rObject]
      return gLCW
   end if
end hArray_SetObjectArray 
   
function hArray_GetHandlerArray pHkey
   global gLCW
   put item 1 to 2 of pHkey into shortHkey
   if shortHkey is empty then
      return gLCW ["handlerArray"]
   else
      return gLCW ["handlerArray"][shortHkey]
   end if
end hArray_GetHandlerArray

command hArray_SetHandlerArray handlerArray, pHkey
   global gLCW
   put item 1 to 2 of pHkey into shortHkey
   if shortHkey is empty then
      put handlerArray into gLCW ["handlerArray"]
   else
      put handlerArray into gLCW ["handlerArray"][shortHkey]
   end if
end hArray_SetHandlerArray

function hArray_ListHkeys pShortHkey
   if pShortHkey is not empty then
      global gLCW
      put gLCW ["handlerArray"] into handlerArray
      put handlerArray [pShortHkey] into hKeyArray
      put keys (hKeyArray) into hKeys
   else
      put hArray_ConstructHkeyArray() into bigHKeyArray
      put keys (bigHKeyArray) into hKeys
   end if
   sort hKeys by item 1 of each
   return hKeys
end hArray_ListHkeys

function hArray_ConstructHkeyArray
   global gLCW
   local bigHKeyArray
   
   put gLCW ["handlerArray"] into handlerArray
   repeat for each key shortHkey in handlerArray
      if shortHkey = "_,c" then next repeat
      put handlerArray [shortHkey] into hKeyArray
      union bigHKeyArray with hKeyArray
   end repeat
   return bigHKeyArray
end hArray_ConstructHkeyArray

function hArray_GetScriptHash rObject
   put item 3 of hKey into rObject
   put hArray_GetObjectArray (rObject) into objectArray
   put objectArray ["metadata"]["sha1"] into scriptHash
   return scriptHash
end hArray_GetScriptHash

function hArray_ListIdenticalHkeys hKey
   local identicalHkeys, anotherHashArray
   hArray_SetHkeyDifferences hKey, identicalHkeys, anotherHashArray
   return identicalHkeys
end hArray_ListIdenticalHkeys

function hArray_ListDifferentHkeys hKey
   local identicalHkeys, anotherHashArray
   hArray_SetHkeyDifferences hKey, identicalHkeys, anotherHashArray
   repeat for each element handlerHashArray in anotherHashArray
      put keys(handlerHashArray) & CR after differentKeys
   end repeat
   delete char -1 of differentKeys
   sort differentKeys by item 1 of each
   return differentKeys
end hArray_ListDifferentHkeys

command hArray_SetHkeyDifferences hKey, @identicalHkeys, @anotherHashArray
   global gLCW
   
   put item 1 to 2 of hKey into shortHkey 
   put gLCW ["handlerArray"][shortHkey] into hKeyArray
   put hKeyArray [hKey]["handlerHash"] into handlerHash
   
   repeat for each key anotherHkey in hKeyArray
      put hKeyArray [anotherHkey]["handlerHash"] into anotherHash
      if anotherHash = handlerHash then
         put anotherHkey & CR after identicalHkeys
      else
         put anotherHkey & CR after differentHkeys
         put hKey into anotherHashArray [anotherHash][anotherHkey]
      end if
   end repeat
   delete char -1 of identicalHkeys
end hArray_SetHkeyDifferences

function hArray_ListHandlerHashes
   put hArray_ConstructHkeyHashArray() into hkeyHashArray
   put keys (hkeyHashArray) into handlerHashes
   return handlerHashes
end hArray_ListHandlerHashes

function hArray_ConstructHkeyHashArray
   global gLCW
   
   -- timer_Start "hArray_ConstructHkeyHashArray"
   put gLCW ["handlerArray"] into handlerArray
   repeat for each key shortHkey in handlerArray
      if shortHkey = "_,c" then next repeat
      put handlerArray [shortHkey] into hKeyArray
      repeat for each key hKey in hKeyArray
         put hKeyArray [hKey]["handlerHash"] into handlerHash
         
         -- can get anything, could get info from objectArray?
         put hKeyArray [hKey]["scriptLine"] into scriptLine
         put scriptLine into hkeyHashArray [handlerHash][hKey]
      end repeat
   end repeat
   -- timer_Stop "hArray_ConstructHkeyHashArray"
   
   return hkeyHashArray
end hArray_ConstructHkeyHashArray

function hArray_KeywordHkeys pKeyWordList
   -- see also "hArray_ListShortKeys"
   put hArray_KeywordHkeyArray (pKeyWordList) into hKeyArray
   put keys (hKeyArray) into hKeys
   sort hKeys by item 1 of each
   return hKeys
end hArray_KeywordHkeys

function hArray_KeywordHkeyArray pKeyWordList
   -- see also "hArray_ListShortKeys"
   global gLCW
   
   if pKeyWordList is empty then
      -- put hArray_GetHandlerArray() into handlerArray
      put gLCW ["handlerArray"] into handlerArray
      put keys(handlerArray) into shortHKeys
   else
      replace CR with comma in pKeyWordList -- hack to allow passing lines not just lists
      
      put word 1 to -1 of item 1 of pKeyWordList into firstKeyWord
      delete item 1 of pKeyWordList
      put gLCW ["keywordArray"][firstKeyWord] into keywordArray
      
      repeat for each key shortHkey in keywordArray
         put keywordArray [shortHkey]["rugged_ID"] into ruggedID
         put keywordArray [shortHkey]["sha1"] into handlerHash
         put shortHkey,ruggedID,1 into hKey
         put handlerHash into hKeyArray [hKey]
      end repeat
   end if
   return hKeyArray
end hArray_KeywordHkeyArray

function hArray_ListShortKeys pKeyWordList
   global gLCW
   
   if pKeyWordList is empty then
      -- put hArray_GetHandlerArray() into handlerArray
      put gLCW ["handlerArray"] into handlerArray
      put keys(handlerArray) into shortHKeys
   else
      replace CR with comma in pKeyWordList -- hack to allow passing lines not just lists
      
      put word 1 to -1 of item 1 of pKeyWordList into firstKeyWord
      delete item 1 of pKeyWordList
      put gLCW ["keywordArray"][firstKeyWord] into intersectArray
      
      repeat for each item pKeyword in pKeyWordList
         put word 1 to -1 of pKeyword into pKeyword
         put gLCW ["keywordArray"][pKeyword] into keywordArray
         intersect intersectArray with keywordArray
      end repeat
      
      put keys (intersectArray) into shortHkeys
   end if
   sort shortHkeys by item 1 of each
   return shortHkeys
end hArray_ListShortKeys

function hArray_ListAllHkeys
   -- timer_Start
   put hArray_ConstructHkeyArray() into bigHKeyArray
   put keys (bigHKeyArray) into hKeys
   sort hKeys by item 1 of each
   -- timer_Stop
   return hKeys
end hArray_ListAllHkeys

function hArray_ListUniqueHkeys
   local bigHKeyArray
   -- timer_Start
   put hArray_ConstructHkeyHashArray() into hkeyHashArray
   repeat for each key handlerHash in hkeyHashArray
      put hkeyHashArray [handlerHash] into uniqueHkeyArray
      union bigHKeyArray with uniqueHkeyArray
   end repeat
   put keys (bigHKeyArray) into hkeys
   sort hkeys by item 1 of each
   -- timer_Stop
   
   return hkeys
end hArray_ListUniqueHkeys


--> hArray | duplicates
-
function hArray_ListDuplicateHkeys
   local duplicateShortKeyArray, duplicateHkeys
   hArray_ConstructDuplicateHkeyArray duplicateShortKeyArray, duplicateHkeys
   return duplicateHkeys
end hArray_ListDuplicateHkeys

command hArray_ConstructDuplicateHkeyArray @duplicateShortKeyArray, @duplicateHkeys
   local duplicateHKeyArray
   timer_Start "hArray_ConstructDuplicateHkeyArray"
   --
   put hArray_ConstructHkeyHashArray() into hkeyHashArray
   repeat for each key handlerHash in hkeyHashArray
      put hkeyHashArray [handlerHash] into hkeyArray
      if the number of elements of hkeyArray > 1 then
         union duplicateHKeyArray with hkeyArray
         
         repeat for each key hKey in hkeyArray
            put item 1 to 2 of hKey into shortHkey
            -- put handlerHash into duplicateShortKeyArray [shortHkey][hKey]
            put hkeyArray [hKey] into duplicateShortKeyArray [shortHkey][hKey]
            put empty into duplicateShortKeyArray [shortHkey][hKey]
         end repeat
      end if
   end repeat
   
   put keys (duplicateHKeyArray) into duplicateHkeys
   sort duplicateHkeys by item 1 of each
   --
   timer_Stop "hArray_ConstructDuplicateHkeyArray"
   
   return duplicateHkeys
end hArray_ConstructDuplicateHkeyArray

command hArray_ConstructDuplicateHkeyArray @duplicateShortKeyArray, @duplicateHkeys
   local duplicateHKeyArray
   timer_Start "hArray_ConstructDuplicateHkeyArray"
   --
   put hArray_ConstructHkeyHashArray() into hkeyHashArray
   repeat for each key handlerHash in hkeyHashArray
      put hkeyHashArray [handlerHash] into hkeyArray
      if the number of elements of hkeyArray > 1 then
         union duplicateHKeyArray with hkeyArray
         
         repeat for each key hKey in hkeyArray
            put item 1 to 2 of hKey into shortHkey
            -- put handlerHash into duplicateShortKeyArray [shortHkey][hKey]
            put hkeyArray [hKey] into duplicateShortKeyArray [shortHkey][hKey]
            put empty into duplicateShortKeyArray [shortHkey][hKey]
         end repeat
      end if
   end repeat
   
   put keys (duplicateHKeyArray) into duplicateHkeys
   sort duplicateHkeys by item 1 of each
   --
   timer_Stop "hArray_ConstructDuplicateHkeyArray"
   
   return duplicateHkeys
end hArray_ConstructDuplicateHkeyArray


--> hArray | Tidy
-
command hArray_FindAndRemoveMissingObjects pDontNotify
   global gLCW
   
   put hArray_ListMissingObjects() into missingObjects
   repeat for each line rObject in missingObjects
      hArray_RemoveObjectFromArray rObject, gLCW 
   end repeat
   
   if pDontNotify is true then return missingObjects
   if missingObjects is empty then
      opn_Notify "Did not find any missing objects in the global gLCW array!"
   else
      opn_Notify "Removed the following missing objects from the global gLCW array!", true
      put missingObjects
   end if
   return missingObjects
end hArray_FindAndRemoveMissingObjects

function hArray_ListMissingObjects
   put hArray_GetObjectArray() into scriptArray
   repeat for each key rObject in scriptArray
      if exists (rObject) is false then
         put rObject & CR after missingObjects
      end if
   end repeat
   delete char -1 of missingObjects
   return missingObjects
end hArray_ListMissingObjects

command hArray_RemoveObject someObject
   global gLCW
   if exists (someObject) then
      put revRuggedID (someObject) into rObject
      put the object_Metadata of rObject into uRipArray
   else
      put someObject into rObject -- assume it is in the right format (won't do anythign if it is not)
      put empty into uRipArray -- won;t strip same name / type objects
   end if
   
   global gLCW
   hArray_RemoveObjectFromArray rObject, gLCW, uRipArray
end hArray_RemoveObject

command hArray_RemoveObjectFromArray rObject, @hArray, pUripArray
   delete variable hArray ["scriptArray"][rObject]
   hArray_RemoveObjectFromHandlerArray rObject, hArray
   hArray_RemoveObjectFromTypeArray rObject, hArray
   if pUripArray is an array then
      hArray_RemoveSameNameTypeObjects rObject, hArray, pUripArray
   end if
end hArray_RemoveObjectFromArray

command hArray_RemoveObjectFromHandlerArray rObject, @hArray, pSlowClean
   if pSlowClean is not false then
      -- this is slower but thorough (should not be needed with a tidy db)
      put hArray ["handlerArray"] into handlerArray
      repeat for each key shortHkey in handlerArray
         put handlerArray [shortHkey] into shortKeyArray
         repeat for each key hkey in shortKeyArray
            if item 3 of hkey = rObject then
               put keys(shortKeyArray) into hKeys
               if the number of lines of hKeys = 1 then
                  delete variable hArray ["handlerArray"][shortHkey]
               else
                  delete variable hArray ["handlerArray"][shortHkey][hkey]
               end if
            end if
         end repeat
      end repeat
   else
      put hArray_GetObjectData (rObject, "script_DataArray", hArray) into scriptData -- should be old handlers and work
      repeat for each key indexNum in scriptData
         put scriptData [indexNum]["hKey"] into hKey
         if hKey is empty then next repeat
         
         put item 1 to 2 of hKey into shortHKey
         put hArray ["handlerArray"][shortHKey] into shortKeyArray
         if shortKeyArray is an array then -- not sure if we really need to check this for speed reasons
            delete variable hArray ["handlerArray"][shortHKey][hKey]
            put hArray ["handlerArray"][shortHKey] into shortKeyArray
            if shortKeyArray is not an array then
               delete variable hArray ["handlerArray"][shortHKey] -- to tidy empty arrays
            end if
         end if
      end repeat
   end if
end hArray_RemoveObjectFromHandlerArray
   
command hArray_RemoveObjectFromTypeArray rObject, @hArray
   put hArray ["objectType"] into objectTypeArray
   repeat for each key objectType in objectTypeArray
      -- remove the object from every object type
      delete variable hArray ["objectType"][objectType][rObject]
      if objectTypeArray [typePath] is not an array then
         delete variable hArray ["objectType"][typePath]
      end if
   end repeat
end hArray_RemoveObjectFromTypeArray

command hArray_RemoveSameNameTypeObjects rObject, @hArray, uRipArray 
   put uRipArray ["name"] into uripName
   put uRipArray ["type"] into objectType
   if objectType is "view" and the view_IsTemplate of rObject is true then
      put "view template" into objectType
   end if
   
   -- only for the particular type
   -- an object with the same uRipName can have different "types"
   -- but the uripName / type cobination must be unique
   -- so here we delete any other objects of the same type and uRipName
   put hArray ["objectType"][objectType] into rObjectTypeArray
   repeat for each key testObject in rObjectTypeArray
      put rObjectTypeArray [testObject]["uripName"] into testName
      if testName is empty then next repeat
      if testName = uripName then
         delete variable hArray ["objectType"][objectType][testObject]
      end if
   end repeat
end hArray_RemoveSameNameTypeObjects


--> View | Model
-
/*
These handlers are the current way views store their metadata.
Eventually the aim is to update this to the way stacks in general store their metadata for any object,
which is based on the standard stack export model (with it's associated metadata folders for each exported object).
These handlers have been place here in order to encourage this migration :)
*/

command view_RenameTemplate oldViewName, newViewName
   view_NormalizeName oldViewName
   view_NormalizeName newViewName
   
   put view_GetTemplateObject (oldViewName) into templateObject
   if exists (templateObject) is false then return "error, cannot locate view tempate for stack" && kwote (oldViewName)
   
   put there is a stack oldViewName and oldViewName begins with "View|" into oldViewStack
   if oldViewStack is false then
      -- lets not rename the stack - but just update the view metadata
      set the view_NewName of templateObject to newViewName
   else
      put the filename of stack oldViewName into oldFile
      
      if there is a stack newViewName then return "error, there is already a stack" && kwote (newViewName)
      put view_NameToFile (newViewName) into newFile
      
      put the short id of templateObject into newTemplateID
      put "control id" && newTemplateID && "of stack" && kwote (newViewName) into newTemplateObject
      put the stack_SubName ["OPN Stack Menus"] of templateObject into subStackName
      
      set the object_IsIndexed of templateObject to false
      
      put the behavior of templateObject into templateBehavior
      if exists (templateBehavior) then
         set the object_IsIndexed of templateBehavior to false
         
         put the stack_Name of templateBehavior into templateStackName
         put the short id of templateBehavior into newBehaviorID
         switch templateStackName
            case oldViewName
               -- it is in the stack of the view being renamed
               put "control id" && newBehaviorID && "of stack" && kwote (newViewName) into newTemplateBehavior
               break
            case subStackName
               -- it is in the sub-stack of the view being renamed
               put newViewName & "|" & "OPN Stack Menus" into newSubStackName
               put "control id" && newBehaviorID && "of stack" && kwote (newSubStackName) into newTemplateBehavior
               break
            default
               -- it is a linked behavior in a stack that is not being renamed
               put templateBehavior into newTemplateBehavior
         end switch
      else
         put empty into newTemplateBehavior
      end if
      
      if exists (stack subStackName) then
         -- lets rename the substack first
         -- first a quick safety check
         put newViewName & "|" & "OPN Stack Menus" into newSubStackName
         if there is a stack newSubStackName then
            -- should not be let's exit
            return "error, for some strange reason there is already a sub-stack" && kwote (newSubStackName)
         end if
         
         -- now rename the substack
         
         set the object_IsIndexed of stack newSubStackName to false
         set the stack_IsKnown of stack subStackName to false
         set the name of stack subStackName to newSubStackName
      end if
      
      -- now rename the mainstack, it's file on disk (keeping it in the same folder), and set the new mainstacks fileName
      set the object_IsIndexed of stack oldViewName to false
      set the stack_IsKnown of stack oldViewName to false
      set the name of stack oldViewName to newViewName
      set the filename of stack newViewName to newFile
      -- file_Rename oldFile, newFile
      rename file oldFile to newFile
      set the stack_IsKnown of stack newViewName to true
      set the object_IsIndexed of stack newViewName to true
      
      if exists (stack newSubStackName) then
         set the stack_IsKnown of stack newSubStackName to true
         set the object_IsIndexed of stack newSubStackName to true
      end if
      
      -- done renaming, lets fix the uRip properties, and update hArray
      set the view_NewName of newTemplateObject to newViewName
   end if
end view_RenameTemplate

command view_DeleteTemplate vName
   view_NormalizeName vName
   if there is a stack vName then
      put the filename of stack vName into someFile
      delete stack vName
   else
      put view_NameToFile (vName) into someFile
   end if
   
   if there is a file someFile then delete file someFile
   view_DeleteMetaData vName
   view_DeleteHelpText vName
   view_DeleteIcon vName
   return someFile
end view_DeleteTemplate

command view_CreateIcon libraryView, pIconView
   if exists(libraryView) is false then
      beep
      opn_Notify "Library (mTarget) view does not exist!"
      exit to top
   end if
   
   get the mobile_Name of libraryView
   put the rect of libraryView into someRect
   put rect_SubtractMargin (-2, someRect) into someRect
   
   put the stack_Name of libraryView into stackName
   put the windowid of stack stackName into someWindowID
   
   put the view_IconFile [false] of libraryView into imageFile
   
   set the wholeMatches to true
   put stackName is among the lines of the openstacks into stackOpen
   if stackOpen is false then object_GoTo libraryView
   
   if pIconView is empty then
      export snapshot from rect someRect of window someWindowID to file imageFile as PNG
   else
      export snapshot from rect someRect of window someWindowID to iconImage as PNG
      set the resized_Image ["60,60"] of pIconView to iconImage
      put the result into resizedImage
      put resizedImage into url ("binfile:" & imageFile)
      set the image_File of pIconView to imageFile
   end if
   
   if stackOpen is false then close stack stackName
   return imageFile
end view_CreateIcon

function view_IconUrl vName, pDontCreate
   put library_TextUrl ("icon.png", vName, "view", pDontCreate) into someUrl
   return someUrl
end view_IconUrl

function view_LocalIconFile vName, pDontCreate
   view_NormalizeName vName
   put library_TextFile ("icon.png", vName, "view", pDontCreate) into localFile
   return localFile
end view_LocalIconFile

command view_DeleteIcon vName
   view_NormalizeName vName
   put library_TextFile ("icon.png", vName, "view", true) into someFile
   delete file someFile
   return someFile
end view_DeleteIcon

function view_GetHelpHtml vName, pOnLineMode
   view_NormalizeName vName
   put library_TextUrl ("help.html", vName, "view", true) into someUrl
   if someUrl is empty then return empty
   put url someUrl into helpHtml
   return helpHtml
end view_GetHelpHtml

on view_SetHelpHtml vName, someHtml, pOnLineMode
   view_NormalizeName vName
   put library_TextUrl ("help.html", vName, "view", false) into someUrl
   if someUrl is not empty then put someHtml into url someUrl
   return someUrl
end view_SetHelpHtml

command view_DeleteHelpText vName
   view_NormalizeName vName
   put library_TextFile ("help.html", vName, "view", true) into someFile
   delete file someFile
   return someFile
end view_DeleteHelpText

function view_GetMetaData vName
   put view_GetFileMetaArray() into metaDataArray
   return metaDataArray [vName]
end view_GetMetaData

command view_SetMetaData vName, vMetaArray
   put view_GetFileMetaArray() into metaDataArray
   put vMetaArray into metaDataArray [vName]
   view_SetFileMetaArray metaDataArray
end view_SetMetaData

command view_DeleteMetaData vName
   put view_GetFileMetaArray() into metaDataArray
   delete variable metaDataArray [vName]
   view_SetFileMetaArray metaDataArray
end view_DeleteMetaData

function view_GetPublished vName
   put view_GetFileMetaArray() into metaDataArray
   put metaDataArray [vName]["isPublished"] into someBoolean
   return someBoolean is true
end view_GetPublished

command view_SetPublished vName, someBoolean
   put view_GetFileMetaArray() into metaDataArray
   put someBoolean into metaDataArray [vName]["isPublished"]
   view_SetFileMetaArray metaDataArray
end view_SetPublished

function view_GetFavourite vName
   put view_GetFileMetaArray() into metaDataArray
   put metaDataArray [vName]["isFavourite"] into someBoolean
   return someBoolean is true
end view_GetFavourite

command view_SetFavourite vName, someBoolean
   put view_GetFileMetaArray() into metaDataArray
   put someBoolean into metaDataArray [vName]["isFavourite"]
   view_SetFileMetaArray metaDataArray
end view_SetFavourite

function view_GetTested vName
   put view_GetFileMetaArray() into metaDataArray
   put metaDataArray [vName]["isTested"] into someBoolean
   return someBoolean is true
end view_GetTested

command view_SetTested vName, someBoolean
   put view_GetFileMetaArray() into metaDataArray
   put someBoolean into metaDataArray [vName]["isTested"]
   view_SetFileMetaArray metaDataArray
end view_SetTested

function view_GetOld vName
   put view_GetFileMetaArray() into metaDataArray
   put metaDataArray [vName]["isOld"] into someBoolean
   return someBoolean is true
end view_GetOld

command view_SetOld vName, someBoolean
   put view_GetFileMetaArray() into metaDataArray
   put someBoolean into metaDataArray [vName]["isOld"]
   view_SetFileMetaArray metaDataArray
end view_SetOld


--> View | File | Model
-
/*
Text and data for browsing and navigating view templates,
but not needed for functioning of view - simply house-keeping.

Not necessary to distribute with working views.

Used for things like presenting and browsing library metadata.
Stored as a text file (an encoded array), and is not need ed to be distribute with view stack for it to work.
*/

function view_GetFileMetaArray
   put model_GetFileArray ("viewMetaData.array") into viewMetaDataArray
   return viewMetaDataArray
end view_GetFileMetaArray

command view_SetFileMetaArray viewMetaDataArray
   model_SetFileArray "viewMetaData.array", viewMetaDataArray
   put the result into someFile
   return someFile
end view_SetFileMetaArray
