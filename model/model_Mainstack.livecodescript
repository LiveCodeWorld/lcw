script "model_Mainstack"
--> MetaData
-
license: GPLv3
name: model_Mainstack
type: model
version: 0.1


--> Rename
-
getprop missing_ExternalHkeys
   -- these are all the hKeys that are external to the target
   -- taken from stored mainstack arrays
   put the mainstack_WalkArray of the target into mainstackWalkArray
   put mainstackWalkArray ["external"] into externalArray
   put keys (externalArray) into missingHkeys
   return missingHkeys
end missing_ExternalHkeys

getprop dependency_Objects
   put the missing_HkeyArray of the target into missingHkeyArray
   return missingHkeyArray ["depObjects"]
end dependency_Objects

getprop missing_HkeyArray
   put the rugged_ID of the target into rObject
   
   put the mainstack_HkeyArray of rObject into hkeyArray
   put the missing_ExternalHkeys of rObject into externalToObjectHkeys
   
   put hkeyArray_ConstructObjectArray (hkeyArray) into objectArray
   put objectArray [rObject] into internalHkeys
   delete variable objectArray [rObject]
   put keys (objectArray) into depObjects
   -- line_Delete rObject, depObjects
   
   put depObjects into missingArray ["depObjects"]
   put objectArray into missingArray ["externalToObjectArray"]
   put externalToObjectHkeys into missingArray ["externalToObjectHkeys"]
   
   -- could also look for hKeys that can;t be found and get them from the library
   -- and for depObjects that are not stacks / libraries
   
   return missingArray
end missing_HkeyArray


--> Stack
-
getprop stack_BehaviorHkeys [returnShort]
   put the stack_BehaviorButton of the target into depButton
   if exists (depButton) is false then return empty
   put the script_FirstHkeys [returnShort] of depButton into stackHkeyDeps
   sort stackHkeyDeps by item 1 of each
   return stackHkeyDeps
end stack_BehaviorHkeys

function stack_FetchManifestArray textStackFolder
   -- was "mainStack_FetchManifestArray"
   put mainstack_GetManifestArrayFile (textStackFolder) into someFile
   put url ("binfile:" & someFile) into encodedArray
   if encodedArray is empty then return empty -- bug:  arrayDecode crashes with empty data
   put arrayDecode (encodedArray) into manifestArray
   return manifestArray
end stack_FetchManifestArray


--> Mainstack | Props
-
getprop mainstack_Deps
   put the textStack_Folder of the target into mainStackFolder
   return mainstack_FetchDepHkeys (mainStackFolder)
end mainstack_Deps

setprop mainstack_Deps shortHkeys
   put the textStack_Folder of the target into mainStackFolder
   mainstack_StoreDepHkeys mainStackFolder, shortHkeys
   put the result into someFile
   return someFile
end mainstack_Deps

getprop mainstack_DependencySuite
   put the textStack_Folder of the target into mainStackFolder
   return mainstack_ConstructDependencySuite (mainStackFolder)
end mainstack_DependencySuite

getprop mainstack_ManifestArrayFile
   put the textStack_Folder of the target into textStackFolder
   put mainstack_GetManifestArrayFile (textStackFolder) into someFile
   if there is a file someFile then
      return someFile
   else
      return empty
   end if
end mainstack_ManifestArrayFile

getprop mainStack_ManifestArray
   put the textStack_Folder [true] of the target into textStackFolder
   return stack_FetchManifestArray (textStackFolder)
end mainStack_ManifestArray

getprop mainstack_HkeyArray [pCheckHash]
   put the mainstack_WalkArray [pCheckHash] of the target into walkArray
   return walkArray ["hkeyArray"]
end mainstack_HkeyArray

setprop mainstack_HkeyArray hkeyArray
   put the mainstack_WalkArray [pCheckHash] of the target into walkArray
   put hkeyArray into walkArray ["hkeyArray"]
   set the mainstack_WalkArray [pCheckHash] of the target to walkArray
end mainstack_HkeyArray

getprop mainstack_Harray [pCheckHash]
   put the mainstack_WalkArray [pCheckHash] of the target into walkArray
   return walkArray ["hArray"]
end mainstack_Harray

setprop mainstack_Harray hArray
   put the mainstack_WalkArray [pCheckHash] of the target into walkArray
   put hArray into walkArray ["hArray"]
   set the mainstack_WalkArray [pCheckHash] of the target to walkArray
end mainstack_Harray

getprop mainstack_MissingArray [pCheckHash]
   put the mainstack_WalkArray [pCheckHash] of the target into walkArray
   return walkArray ["missing"]
end mainstack_MissingArray

setprop mainstack_MissingArray hArray
   put the mainstack_WalkArray [pCheckHash] of the target into walkArray
   put hArray into walkArray ["missing"]
   set the mainstack_WalkArray [pCheckHash] of the target to walkArray
end mainstack_MissingArray

getprop mainstack_WalkArray [pCheckHash]
   put the textStack_Folder of the target into mainStackFolder
   put mainstack_FetchWalkArray (mainStackFolder) into mainstackWalkArray
   if pCheckHash is true then
      put the mainstack_Hash of the target into mainstackHash
      get walkArray_GetMainstackHash (mainstackWalkArray)
      if it is not mainstackHash then
         return empty
      end if
   end if
   return mainstackWalkArray
end mainstack_WalkArray

setprop mainstack_WalkArray mainstackWalkArray
   put the textStack_Folder of the target into mainStackFolder
   mainstack_StoreWalkArray mainStackFolder, mainstackWalkArray
   put the result into someFile
   return someFile
end mainstack_WalkArray

getprop mainstack_WalkArrayFile
   put the textStack_Folder of the target into mainStackFolder
   put mainstack_GetWalkArrayFile (mainStackFolder) into someFile
   return someFile
end mainstack_WalkArrayFile


--> Mainstack | Sub Arrays
-
getprop mainstack_ExternalParents
   put the mainstack_WalkArray of the target into hKeyWalkArray
   return mainstack_ExtractExternalParentHkeys (hKeyWalkArray)
end mainstack_ExternalParents


--> Metadata | Hash
-
getprop mainstack_HandlerHashArray
   put the textStack_Folder of the target into mainStackFolder
   return mainstack_FetchHandlerHashArray (mainStackFolder)
end mainstack_HandlerHashArray

setprop mainstack_HandlerHashArray handlerHashArray
   put the textStack_Folder of the target into mainStackFolder
   mainstack_StoreHandlerHashArray mainStackFolder, handlerHashArray
   put the result into someFile
   return someFile
end mainstack_HandlerHashArray

getprop mainstack_Hash
   put the main_Stack of the target into mainStackObject
   put the filename of mainStackObject into someFile
   put url ("binfile:" & someFile) into someData
   put sha1_Hash (someData) into mainstackHash
   return mainstackHash
end mainstack_Hash


--> Project | Functions and Commands
-
function mainstack_GetManifestArrayFile textStackFolder, pDontCreate
   folder_Format textStackFolder
   put textStackFolder & "data/manifest.array" into someFile
   if pDontCreate is false then folder_CreateNested textStackFolder
   return someFile
end mainstack_GetManifestArrayFile

function mainstack_FetchHandlerHashArray mainStackFolder
   put mainstack_FetchHarray (mainStackFolder) into hArray
   put hArray_GetHandlerHashArray (hArray) into handlerHashArray
   return handlerHashArray
end mainstack_FetchHandlerHashArray

command mainStack_StoreManifestArray textStackFolder, manifestArray
   put mainstack_GetManifestArrayFile (textStackFolder, false) into someFile
   put arrayEncode (manifestArray) into encodedArray
   put encodedArray into url ("binfile:" & someFile)
   return someFile
end mainStack_StoreManifestArray

command mainstack_StoreHandlerHashArray mainStackFolder, handlerHashArray
   put mainstack_FetchHarray (mainStackFolder) into hArray
   hArray_SetHandlerHashArray hArray, handlerHashArray
   mainstack_StoreHarray hArray, mainStackFolder
   put the result into someFile
   return someFile
end mainstack_StoreHandlerHashArray

function mainstack_ExtractExternalParentHkeys hKeyWalkArray
   put hKeyWalkArray ["external"] into someArray
   repeat for each element parentArray in someArray
      repeat for each key parentKey in parentArray
         put empty into uniqueParentArray [parentKey]
      end repeat
   end repeat
   return keys (uniqueParentArray)
end mainstack_ExtractExternalParentHkeys

/*
Part of mainstack_WalkArray.
*/

function mainstack_FetchHarray mainStackFolder
   -- hack_TidyOldMainstackFiles mainStackFolder
   return mainstack_FetchSomeArray (mainStackFolder, "hArray")
end mainstack_FetchHarray

command mainstack_StoreHarray hArray, mainStackFolder
   mainstack_StoreSomeArray mainStackFolder, hArray, "hArray"
   put the result into someFile
   return someFile
end mainstack_StoreHarray

function mainstack_FetchHkeyArray mainStackFolder
   return mainstack_FetchSomeArray (mainStackFolder, "hkeyArray")
end mainstack_FetchHkeyArray

command mainstack_StoreHkeyArray mainStackFolder, hKeyArray
   mainstack_StoreSomeArray mainStackFolder, hKeyArray, "hkeyArray"
   put the result into someFile
   return someFile
end mainstack_StoreHkeyArray

function mainstack_ConstructDependencySuite mainStackFolder
   put mainstack_FetchDepHkeys (mainStackFolder) into shortHkeys
   put hkey_CollectExported (shortHkeys) into depScript
   put script_ConstructSuite ("Deps", depScript) into depSuite
   return depSuite
end mainstack_ConstructDependencySuite

command mainstack_AddHkeyToDeps hKeys, mainStackFolder
   -- was "mainstack_AddHkeyToDepArray"
   -- would be quicker with an array but here we have readable text file
   -- ensures that all the hKeys added are short hKeys for library
   put mainstack_FetchDepHkeys (mainStackFolder) into depHkeys
   set the wholematches to true
   repeat for each line hKey in hKeys
      if hKey is empty then next repeat
      put item 1 to 2 of hKey into shortHkey
      put lineoffset (shortHkey, depHkeys) into lineNum
      if lineNum is 0 then
         put the number of lines of depHkeys into maxLine
         put maxLine + 1 into lineNum
         put shortHkey into line lineNum of depHkeys
      end if
   end repeat
   mainstack_StoreDepHkeys mainStackFolder, depHkeys
end mainstack_AddHkeyToDeps

command mainstack_RemoveHkeyFromDeps hKeys, mainStackFolder
   put mainstack_FetchDepHkeys (mainStackFolder) into depHkeys
   line_Delete hKeys, depHkeys
   mainstack_StoreDepHkeys mainStackFolder, depHkeys
end mainstack_RemoveHkeyFromDeps

function mainstack_FetchDepHkeys mainStackFolder
   put mainstack_FetchText (mainStackFolder, "short_hkey_deps.txt") into shortHkeys
   return shortHkeys
end mainstack_FetchDepHkeys

command mainstack_StoreDepHkeys mainStackFolder, shortHkeys
   sort shortHkeys by item 1 of each
   mainstack_StoreText mainStackFolder, "short_hkey_deps.txt", shortHkeys
   put the result into someFile
   return someFile
end mainstack_StoreDepHkeys


--> Mainstack | WalkArray
-
function mainstack_FetchText mainStackFolder, shortFile
   put mainstack_MetadataFolder (mainStackFolder, empty, pDontCreate) & shortFile into someFile
   put url ("binfile:" & someFile) into someData
   return someData
end mainstack_FetchText

command mainstack_StoreText mainStackFolder, shortFile, someData
   put mainstack_MetadataFolder (mainStackFolder, empty, pDontCreate) & shortFile into someFile
   if someData is empty then
      delete file someFile
      return empty
   else
      put someData into url ("binfile:" & someFile)
      return someFile
   end if
end mainstack_StoreText

function mainstack_FetchSomeArray mainStackFolder, someKey
   put mainstack_FetchWalkArray (mainStackFolder) into walkArray
   return walkArray [someKey]
end mainstack_FetchSomeArray

command mainstack_StoreSomeArray mainStackFolder, someArray, someKey
   put mainstack_FetchWalkArray (mainStackFolder) into walkArray
   if someArray is an array then
      put someArray into walkArray [someKey]
   else
      delete variable walkArray [someKey]
   end if
   mainstack_StoreWalkArray mainStackFolder, walkArray
   put the result into someFile
   return someFile
end mainstack_StoreSomeArray

function mainstack_FetchWalkArray mainStackFolder
   put mainstack_GetWalkArrayFile (mainStackFolder) into someFile
   put url ("binfile:" & someFile) into encodedArray
   if encodedArray is empty then return empty
   put arrayDecode (encodedArray) into walkArray
   return walkArray
end mainstack_FetchWalkArray

command mainstack_StoreWalkArray mainStackFolder, walkArray
   put mainstack_GetWalkArrayFile (mainStackFolder) into someFile
   if walkArray is an array then
      put arrayEncode (walkArray) into encodedArray
      put encodedArray into url ("binfile:" & someFile)
      return someFile
   else
      delete file someFile
      return empty
   end if
end mainstack_StoreWalkArray

function mainstack_GetWalkArrayFile mainStackFolder
   -- hack_MoveOldWalkArrayFile mainStackFolder
   put mainstack_MetadataFolder (mainStackFolder, empty, pDontCreate) & "walk.array" into someFile
   return someFile
end mainstack_GetWalkArrayFile


--> Deps
-
command object_RuggedDeconstruct someObject, @mainstackName, @substackName, @controlType, @someID
   put the long id of someObject into someObject
   put token 1 of someObject into controlType
   put revRuggedID (someObject) into rObject
   put token - 1 of rObject into mainstackName
   if token -5 of rObject  = "stack" then
      put token - 4 of rObject into substackName
      delete token -5 to -1 of rObject
   else
      put empty into substackName
      delete token -2 to -1 of rObject
   end if
   
   if rObject is empty then
      put empty into someID
   else
      put token 3 of rObject into someID
   end if
end object_RuggedDeconstruct
