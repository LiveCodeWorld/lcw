script "model_LibraryArray"
project_FixUsedlicense: GPLv3
name: model_LibraryArray
type: model
version: 0.1

/*
This model provides an interface to a databse of objects (stored in the hArray array database)
and "sets" which is an array of "projects" that yu can use.
*/


--> Library | Add
-
command library_AddFrontObject scriptObject, pSetName
   put revRuggedId (scriptObject) into ruggedObject
   library_AddObject ruggedObject, "front", pSetName
   put the result into libName
   return libName
end library_AddFrontObject

command library_AddUsedStack stackObject, pSetName
   if exists(stackObject) is false then return empty
   if word 1 of stackObject is not "stack" then put the stack_Object of stackObject into stackObject
   put the name of stackObject into stackObject
   
   library_AddObject stackObject, "used", pSetName
   put the result into libName
   return libName
end library_AddUsedStack

command library_AddBackObject scriptObject, pSetName
   put revRuggedId (scriptObject) into ruggedObject
   library_AddObject ruggedObject, "back", pSetName
   put the result into libName
   return libName
end library_AddBackObject

command library_AddObject ruggedObject, libType, pSetName 
   put project_GetCurrentName() into currentSetName
   if pSetName is empty then put currentSetName into pSetName
   if pSetName = currentSetName then
      global gLibrarySet_Array
      put empty into gLibrarySet_Array ["data"][libType][ruggedObject]
      
      object_AddToGlobalArray ruggedObject
      put library_FetchSetArray (pSetName) into setArray
      put empty into setArray ["data"][libType][ruggedObject]
      library_StoreSetArray setArray, pSetName
   else
      library_AddSetNamesToStore ruggedObject, libType, pSetName
   end if
   return pSetName
end library_AddObject

command library_DeleteObject ruggedObject, libType, pSetName
   put project_GetCurrentName() into currentSetName
   if pSetName is empty then put currentSetName into pSetName
   if pSetName = currentSetName then
      global gLibrarySet_Array
      delete variable gLibrarySet_Array ["data"][libType][ruggedObject]
   end if
   library_RemoveSetNamesFromStore ruggedObject, libType, pSetName
   return pSetName
end library_DeleteObject


--> Library | Delete
-
command library_DeleteFrontObject someObject, pSetName
   library_DeleteObject someObject, "front", pSetName
   return the result
end library_DeleteFrontObject

command library_DeleteBackObject someObject, pSetName
   library_DeleteObject someObject, "back", pSetName
   return the result
end library_DeleteBackObject

command library_DeleteUsedStack stackObject, pSetName
   -- removed checks so we can delete entires that don't exist
   if pSetName is empty then put project_GetCurrentName() into pSetName
   library_DeleteObject stackObject, "used", pSetName
   return the result
end library_DeleteUsedStack


--> Library | Objects
-
function library_FetchEveryObject pAddHaaray, pAddStandard
   local bigObjectArray
   put library_FetchSetData() into setData
   repeat for each key setName in setData
      repeat for each item libType in "back,used,front"
         put setData [setName]["data"][libType] into rObjectArray
         union bigObjectArray with rObjectArray
      end repeat
   end repeat
   
   repeat for each key rObject in bigObjectArray
      if exists(rObject) then
         put revRuggedID (rObject) into rObject
         put empty into safeBigObjectArray [rObject]
      end if
   end repeat
   
   if pAddStandard is not false then
      objectArray_AddRuggedObject library_ListStandardBackScripts(), safeBigObjectArray
      objectArray_AddRuggedObject library_ListStandardUsedStacks(), safeBigObjectArray
      objectArray_AddRuggedObject library_ListStandardUsedStacks(), safeBigObjectArray
   end if
   
   if pAddHaaray is not false then
      objectArray_AddRuggedObject hArray_ListAllObjects(), safeBigObjectArray
   end if
   put keys (safeBigObjectArray) into everyObject
   sort everyObject
   return everyObject
end library_FetchEveryObject

function library_FetchObjects libType, setName
   switch setName
      case "none"
         return empty
      case "all"
         put library_FetchAllObjects (libType) into someObjects
         break
      default
         put library_FetchObjectTypeArray (libType, setName) into libTypeArray
         put keys (libTypeArray) into someObjects
   end switch
   sort someObjects
   return someObjects
end library_FetchObjects

function library_FetchAllObjects libType
   --should add any additional objects not stored in standard folders but listed in other sets
   switch libType
      case "back"
         return library_ListStandardBackScripts()
      case "front"
         return library_ListStandardFrontScripts()
      case "used"
         return library_ListStandardUsedStacks()
   end switch
end library_FetchAllObjects


--> Library | List | Objects
-
function library_ListGlobalMenuNames
   global gHkey_Array
   put gHkey_Array ["Global Menus"] into menuArray
   return keys (menuArray)
end library_ListGlobalMenuNames

function library_ListGlobalMenuObjects
   global gHkey_Array
   put gHkey_Array ["Global Menus"] into menuArray
   repeat for each key mTitle in menuArray
      put menuArray [mTitle]["mController"] into mController
      put mController & CR after mControllers
   end repeat
   delete char -1 of mControllers
   return mControllers
end library_ListGlobalMenuObjects

function library_ListFrontObjects pSetName
   return library_ListObjects ("front", pSetName)
end library_ListFrontObjects

function library_ListUsedStacks pSetName
   return library_ListObjects ("used", pSetName)
end library_ListUsedStacks

function library_ListBackObjects pSetName
   return library_ListObjects ("back", pSetName)
end library_ListBackObjects

function library_ListObjects libType, pSetName
   global gLibrarySet_Array
   put gLibrarySet_Array ["data"][libType] into ruggedArray
   return keys (ruggedArray)
end library_ListObjects


--> Library | List | Names
-
function library_ListScriptLibs
   put library_GetScriptLibArray() into typeArray
   put keys (typeArray) into scriptLibs
   return scriptLibs
end library_ListScriptLibs

function library_ListScriptLibNames
   put library_GetScriptLibArray() into typeArray
   repeat for each key rObject in typeArray
      put typeArray [rObject]["uRipName"] into vName
      if vName is empty then next repeat -- should not be
      put empty into nameArray [vName]
   end repeat
   put keys (nameArray) into scriptLibNames
   return scriptLibNames
end library_ListScriptLibNames

function library_ListFrontNames pSetName
   return library_ListNames ("front", pSetName)
end library_ListFrontNames

function library_ListUsedNames pSetName
   return library_ListNames ("used", pSetName)
end library_ListUsedNames

function library_ListBackNames pSetName
   return library_ListNames ("back", pSetName)
end library_ListBackNames

function library_ListNames libType, pSetName
   -- used in general for menus to construct named interfaces
   put library_ConstructNameTypeArray (libType, pSetName) into nameArray
   put keys (nameArray) into someNames
   sort someNames
   return someNames
end library_ListNames


--> Library | Type Array
-
/*
This is still all a bit of a mess until "all" is sorted.
*/

function library_GetScriptLibArray
   put "script library" into objectType
   -- put library_FetchTypeArray (objectType, pSetName) into scriptLibs -- from stored set
   -- put library_ListNames (objectType, pSetName) into scriptLibs -- from stored set
   put hArray_GetObjectTypeArray (objectType) into typeArray -- from global gHkey_Array
   return typeArray
end library_GetScriptLibArray

function library_ConstructNameTypeArray libType, pSetName
   if pSetName is empty then
      put library_GetTypeArray (libType) into ruggedArray
   else
      put library_FetchTypeArray (libType, pSetName) into ruggedArray
   end if
   repeat for each key rObject in ruggedArray
      put hArray_GetUripArray (rObject, "name") into vName
      if vName is empty then next repeat -- should not be
      put empty into nameArray [vName]
   end repeat
   return nameArray
end library_ConstructNameTypeArray

function library_FetchObjectTypeArray libType, setName
   switch setName
      case "none"
         return empty
      case "all"
         return library_ConstructAllObjectTypeArray (libType)
      default
         put library_FetchSetData() into setData
         put setData [setName]["data"][libType] into libTypeArray
         return libTypeArray
   end switch
end library_FetchObjectTypeArray

function library_FetchTypeArray libType, pSetName
   put library_FetchSetArray (pSetName) into libArray
   put libArray ["data"][libType] into ruggedArray
   return ruggedArray
end library_FetchTypeArray

command library_StoreObjectTypeArray libType, setName, libTypeArray
   put library_FetchSetData() into setData
   put libTypeArray into setData [setName]["data"][libType]
   library_StoreSetData setData
end library_StoreObjectTypeArray

function library_ConstructAllObjectSetArray
   repeat for each item libType in "back,used,front"
      put library_ConstructAllObjectTypeArray (libType) into setArray ["data"][libType]
   end repeat
   return setArray
end library_ConstructAllObjectSetArray

function library_ConstructAllObjectTypeArray libType
   put library_FetchAllObjects (libType) into allObjects
   repeat for each line someObject in allObjects
      if exists(someObject) is false then
         next repeat
      end if
      
      put revRuggedID (someObject) into ruggedObject
      put empty into libTypeArray [ruggedObject]
   end repeat
   return libTypeArray
end library_ConstructAllObjectTypeArray

command library_AddSetNamesToStore ruggedObject, libType, setNames
   put library_FetchSetData() into modelArray
   repeat for each line setName in setNames
      put empty into modelArray [setName]["data"][libType][ruggedObject]
   end repeat
   library_StoreSetData modelArray
   return modelArray
end library_AddSetNamesToStore


--> Library | Get Object
-
function library_GetFrontObject libName, pSetName
   put library_GetObject (libName, "front", pSetName) into someObject
   return someObject
end library_GetFrontObject

function library_GetUsedStack libName, pSetName
   put library_GetObject (libName, "used", pSetName) into someObject
   return someObject
end library_GetUsedStack

function library_GetBackObject libName, pSetName
   put library_GetObject (libName, "back", pSetName) into someObject
   return someObject
end library_GetBackObject


--> Library | Sets
-
command library_RemoveSetNamesFromStore ruggedObject, libType, setNames
   put library_FetchSetData() into setData
   repeat for each line setName in setNames
      delete variable setData [setName]["data"][libType][ruggedObject]
   end repeat
   library_StoreSetData setData
   return setData
end library_RemoveSetNamesFromStore

command library_StoreSetNames ruggedObject, libType, setNames
   put library_FetchSetData() into modelArray
   put keys(modelArray) into otherSetNames
   repeat for each line setName in setNames
      put empty into modelArray [setName]["data"][libType][ruggedObject]
      line_Delete setName, otherSetNames
   end repeat
   repeat for each line setName in otherSetNames
      delete variable modelArray [setName]["data"][libType][ruggedObject]
   end repeat
   library_StoreSetData modelArray
   return modelArray
end library_StoreSetNames

function library_ListSetNames pAddDefaults
   put library_FetchSetData() into modelArray
   put keys (modelArray) into setNames
   sort setNames
   if pAddDefaults is true then
      put CR & "None" after setNames
   end if
   return setNames
end library_ListSetNames

function library_GetSetArray
   global gLibrarySet_Array
   return gLibrarySet_Array
end library_GetSetArray

command library_SetSetArray setArray
   global gLibrarySet_Array
   put setArray into gLibrarySet_Array
end library_SetSetArray

function library_GetTypeArray libType
   global gLibrarySet_Array
   put gLibrarySet_Array ["data"][libType] into ruggedArray
   return ruggedArray
end library_GetTypeArray

function library_GetObject libName, libType, pSetName
   if pSetName is empty then
      put library_GetTypeArray (libType) into ruggedArray
   else
      put library_FetchObjectTypeArray (libType, pSetName) into ruggedArray
   end if
   repeat for each key rObject in ruggedArray
      if exists (rObject) is false then opn_Notify (rObject && "does not exist!")
      
      put hArray_GetUripArray (rObject, "name") into vName
      if vName = libName then
         return rObject
      end if
   end repeat
   return empty
end library_GetObject

command library_Delete pLibType
   global gLibrarySet_Array
   delete variable gLibrarySet_Array
end library_Delete


--> Library | Sets
-
command library_DeleteStoredSet setName
   put library_FetchSetData() into modelArray
   delete local modelArray [setName]
   library_StoreSetData modelArray
   library_SetSetName "Default"
end library_DeleteStoredSet

function library_FetchSetArray pSetName
   if pSetName is empty then put project_GetCurrentName() into pSetName
   switch pSetName
      case "all"
         put library_ConstructAllObjectSetArray () into setArray
         return setArray
      case "none"
         return empty
      default
         put library_FetchSetData() into setData
         return setData [pSetName]
   end switch
end library_FetchSetArray

command library_StoreSetArray setArray, pSetName
   -- don't store anything for the standard sets "all" and "none" which are calculated from other info.
   switch pSetName
      case "all"
         return empty
      case "none"
         return empty
      default
         if pSetName is empty then put project_GetCurrentName() into pSetName
         
         put library_FetchSetData() into setData
         put setArray into setData [pSetName]
         library_StoreSetData setData
   end switch
end library_StoreSetArray

function library_FetchSetData
   -- the stored checkout array "gOPN_LibrarySets" does not store sets "none" or "all"
   put library_FetchArray ("gOPN_LibrarySets") into modelArray
   return modelArray
end library_FetchSetData

command library_StoreSetData modelArray
   -- careful not to store data for sets "none" or "all"
   -- as these are constructed
   library_StoreArray "gOPN_LibrarySets", modelArray
end library_StoreSetData

function library_FetchSetsContaining ruggedObject, libType
   put library_FetchSetData() into modelArray
   repeat for each key setName in modelArray
      put modelArray [setName]["data"][libType] into libTypeArray
      put keys (libTypeArray) into rObjects
      if ruggedObject is among the lines of rObjects then
         put setName & CR after setNames
      end if
   end repeat
   delete char -1 of setNames
   return setNames
end library_FetchSetsContaining

command library_RemoveSetNamesFromStore ruggedObject, libType, setNames
   put library_FetchSetData() into setData
   repeat for each line setName in setNames
      delete variable setData [setName]["data"][libType][ruggedObject]
   end repeat
   library_StoreSetData setData
   return setData
end library_RemoveSetNamesFromStore

command library_StoreSetNames ruggedObject, libType, setNames
   put library_FetchSetData() into modelArray
   put keys(modelArray) into otherSetNames
   -- add
   repeat for each line setName in setNames
      put empty into modelArray [setName]["data"][libType][ruggedObject]
      line_Delete setName, otherSetNames
   end repeat
   -- remove from the rest
   repeat for each line setName in otherSetNames
      delete variable modelArray [setName]["data"][libType][ruggedObject]
   end repeat
   library_StoreSetData modelArray
   return modelArray
end library_StoreSetNames

function library_ListSetNames pAddDefaults
   put library_FetchSetData() into modelArray
   put keys (modelArray) into setNames
   sort setNames
   if pAddDefaults is true then
      put CR & "None" after setNames
   end if
   return setNames
end library_ListSetNames


--> Library | Private ?
-
command objectArray_AddRuggedObject someObjects, @rObjectArray
   repeat for each line someObject in someObjects
      if exists(someObject) then
         put revRuggedID (someObject) into rObject
         put empty into rObjectArray [rObject]
      end if
   end repeat
end objectArray_AddRuggedObject

command objectArray_AddLongIdObject someObjects, @longIdObjectArray
   repeat for each line someObject in someObjects
      if exists(someObject) then
         put the long id of someObject into longIDObject
         put empty into longIdObjectArray [longIDObject]
      end if
   end repeat
end objectArray_AddLongIdObject
