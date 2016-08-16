script "model_Global"
--> MetaData
-
license: GPLv3
name: model_Global
type: model
version: 0.1


--> Working on
-
/*
These handlers are required for the menu, and came from lib_Manager library.
They may be best here is a tool menu, or if found to be of more general use, moved to a library
*/


--> hArray | Model
-
command hArray_LoadGlobal
   global gHkey_Array
   put hArray_FetchData() into gHkey_Array
end hArray_LoadGlobal

command hArray_StoreGlobal
   global gHkey_Array
   hArray_StoreData gHkey_Array
end hArray_StoreGlobal

command hArray_DeleteArrayDatabase
   global gHkey_Array
   delete variable gHkey_Array
end hArray_DeleteArrayDatabase

function hArray_FetchData
   put library_FetchArray ("Hkey_Data") into hArray
   return hArray
end hArray_FetchData

command hArray_StoreData hArray
   library_StoreArray "Hkey_Data", hArray
end hArray_StoreData


--> Library | Global Dump | Model
-
command library_RestoreGlobalDump
   put library_FetchGlobalDump() into globalArray
   global_DeleteAll
   global_Load globalArray
   return globalArray
end library_RestoreGlobalDump

function library_FetchGlobalDump
   put library_FetchArray ("library_GlobalDump") into gatheredArray
   return gatheredArray
end library_FetchGlobalDump

command library_StoreGlobalDump gatheredArray
   library_StoreArray "library_GlobalDump", gatheredArray
end library_StoreGlobalDump

command library_DeleteGlobalDump
   library_DeleteArray "library_GlobalDump"
end library_DeleteGlobalDump

function library_GlobalDumpFile
   put library_ArrayFile ("library_GlobalDump") into libraryGlobalDumpFiles
   return libraryGlobalDumpFiles
end library_GlobalDumpFile

function library_GlobalDumpFileMissing
   put library_GlobalDumpFile() into libraryGlobalDumpFile
   put there is not a file libraryGlobalDumpFile into fileMissing
   return fileMissing
end library_GlobalDumpFileMissing


--> Global | Names
-
function global_ListPrefs
   put global_ListNames ("gPrefs_*") into prefGlobalNames
   return prefGlobalNames
end global_ListPrefs

function global_ListOtherNames
   -- globals that are not part of the IDE, or the LCW (was OPN) environment.
   put global_ListNames ("-gOPN*,-gPrefs_*,-gHkey_*,-gLibrarySet_Array") into tempGlobals
   return tempGlobals
end global_ListOtherNames

function global_ListOpnNames
   put global_ListNames ("gOPN*") into opnGlobals
   return opnGlobals
end global_ListOpnNames

function global_ListNames pFilters
   put the globals into gNames
   replace comma with CR in gNames
   
   if pFilters is empty then
      filter gNames without "gTemp_*"
      -- line_Delete "msg", gNames
      filter gNames without "gREV*"
      filter gNames without "$*"
      filter gNames without "each"
      filter gNames without "msg"
   end if
   
   repeat for each item pFilter in pFilters
      switch
         case pFilter is "rev"
            filter gNames with "gREV*"
            break
         case pFilter is "env"
            filter gNames with "$*"
            break
         case pFilter is empty
         case pFilter is true
            break
         case pFilter is false
            -- line_Delete "msg", gNames
            filter gNames without "gREV*"
            filter gNames without "$*"
            filter gNames without "each"
            filter gNames without "msg"
            break
         case char 1 of pFilter = "-"
            delete char 1 of pFilter
            filter gNames without pFilter
            break
         default
            filter gNames with pFilter
            break
      end switch
   end repeat
   return gNames
end global_ListNames


--> Global | Prefs | Model
-
function project_GatherGlobalPrefs
   -- was "library_ConstructPrefsArray" then "project_GatherPrefsArray"
   -- gathers all appropriately named globals into a single array for storage.
   
   put global_Gather ("gPrefs_*") into prefsArray
   return prefsArray
end project_GatherGlobalPrefs


--> Global | Model
-
function global_Gather pFilters
   put global_ListNames (pFilters) into gNames
   repeat for each line gName in gNames  
      put "global" && gName & CR & "get" && gName into doScript   
      do doScript
      put it into prefsArray [gName]
   end repeat
   return prefsArray
end global_Gather

command global_Load globalArray
   repeat for each key gName in globalArray
      if the number of words of gName is not 1 then next repeat -- safety check
      put globalArray [gName] into globalValue
      put "global" && gName & CR & "put globalValue into" && gName into doScript
      do doScript
   end repeat
end global_Load

function global_GetValue gName
   put "global" && gName & CR & "put" && gName && "into gValue" into doScript
   do doScript
   return gValue
end global_GetValue

command global_SetValue gName, gValue
   put "global" && gName & CR & "put" && gValue && "into gName" into doScript
   do doScript
end global_SetValue

command global_Delete gName
   put "global" && gName & CR & "delete variable" && gName into doScript
   do doScript
end global_Delete

command global_DeleteAll pFilter
   if pFilter is empty then put false into pFilter
   put global_ListNames (pFilter) into prefGlobalNames
   repeat for each line gName in prefGlobalNames
      global_Delete gName
   end repeat
end global_DeleteAll


--> Project | hArray
-
/*
For now we don't store this data seperately for each project. We may do this in the future.
For now we just wrap the Library | Model | Array | gHkeyArray handlers
*/

command project_LoadGlobalHarray pProjectName
   global gHkey_Array
   put project_FetchHarray (pProjectName) into gHkey_Array
   return gHkey_Array
end project_LoadGlobalHarray

command project_SaveGlobalHarray pProjectName
   global gHkey_Array
   project_SaveHarray gHkey_Array, pProjectName
   put the result into arrayFile
   return arrayFile
end project_SaveGlobalHarray

function project_FetchHarray pProjectName
   -- if pProjectName is empty then put project_GetCurrentName() into pProjectName
   put library_FetchArray ("Hkey_Data") into hArray
   return hArray
end project_FetchHarray

command project_SaveHarray hArray, pProjectName
   -- if pProjectName is empty then put project_GetCurrentName() into pProjectName
   library_StoreArray "Hkey_Data", hArray
   put the result into arrayFile
   return arrayFile
end project_SaveHarray


--> Project | Globals
-
command project_LoadWorkingStackFiles pProjectName, pProjectHomeStack
   project_GuessHomeStack pProjectHomeStack
   put project_FetchStackFiles (pProjectName) into stackFileTable
   set the project_StackFiles of pProjectHomeStack to stackFileTable
end project_LoadWorkingStackFiles

command project_RestoreGlobalPrefs pProjectName
   -- was "libary_RestoreGlobalPrefs"   
   project_DeleteGlobalPrefs
   project_LoadGlobalPrefs pProjectName
   put the result into projectPrefsArray
   return projectPrefsArray
end project_RestoreGlobalPrefs


--> Project | Prefs
-
command project_LoadGlobalPrefs pProjectName
   -- this loads the globals without clearing any of the others
   put project_FetchPrefs (pProjectName) into projectPrefsArray
   global_Load projectPrefsArray -- now let's load the globals
   return projectPrefsArray
end project_LoadGlobalPrefs

command project_SaveGlobalPrefs pProjectName
   /*
   -- was "library_StoreGlobalPrefs"
   Save the current globals beginning with "gPRefs_" to the project section of the library set array.
   
   Any global beginning with gPrefs_* is automatically stored in the project section of the library set array
   It is no longer stored in the users preference folder (these are project preferences)
   Do not store passwords or other sensitive information, as these may be checked out publicall on GitHub.
   */
   
   put project_GatherGlobalPrefs () into projectPrefsArray
   project_SavePrefs projectPrefsArray, pProjectName
   return prefsArray
end project_SaveGlobalPrefs


--> Project | Prefs | Global | Model
-
command project_DeleteGlobalPrefs
   put the globals into gNames
   replace comma with CR in gNames
   filter gNames with "gPrefs_*"
   repeat for each line gName in gNames  
      put "global" && gName & CR & "delete variable" && gName into doScript   
      do doScript
   end repeat
   return gNames
end project_DeleteGlobalPrefs

command project_LoadGlobalArray pProjectName
   global gLibrarySet_Array
   put library_FetchProjectArray (pProjectName) into gLibrarySet_Array
   return gLibrarySet_Array
end project_LoadGlobalArray

command project_SaveGlobalArray pProjectName
   global gLibrarySet_Array
   library_StoreProjectArray pProjectName, gLibrarySet_Array
   put the result into librarySetData
   return librarySetData
end project_SaveGlobalArray
