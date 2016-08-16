script "model_Prefs"
--> MetaData
-
license: GPLv3
name: model_Prefs
type: model
version: 0.6


--> Currently Working On
-
/*
These are system wide user preferences.
For project preferences use

These utility handlers are for manipulating global variables when you only have there name,
and this is passed to you in a script. Otherwise you can simply decalre the global in your script and do not need to use "do".
*/

function pref_FetchServerArray pName
   if pName is empty then put project_GetCurrentName() into pName
   put pref_FetchValue ("server_Array", pName) into serverArray
   return serverArray
end pref_FetchServerArray

command pref_StoreServerArray serverArray, pName
   if pName is empty then put project_GetCurrentName() into pName
   pref_SaveValue "server_Array", serverArray, pName
   put the result into dataArray
   return dataArray
end pref_StoreServerArray


--> Pref | Shell
-
command pref_SetShellRoot someShellCommand, prefRootName
   put "which" && someShellCommand into someShell
   put line 1 of shell (someShell) into testPath
   if testPath is empty then
      put pref_GetValue (prefRootName) into testFolder
      if there is a folder testFolder then
         return testFolder
      else
         answer warning merge("There is a problem with the path to the shell command [[someShellCommand]]!")
         breakpoint
         return empty
      end if
   else
      set the itemdelimiter to slash
      put empty into item -1 of testPath
      pref_SetValue prefRootName, testPath
      return testPath
   end if
end pref_SetShellRoot


--> Pref
-
function pref_GetValue prefName
   global gPrefs_Array
   return gPrefs_Array [prefName]
end pref_GetValue

command pref_SetValue prefName, someValue
   global gPrefs_Array
   put someValue into gPrefs_Array [prefName]
   return gPrefs_Array
end pref_SetValue

command pref_DeleteValue prefName
   global gPrefs_Array
   delete variable gPrefs_Array [prefName]
   return gPrefs_Array
end pref_DeleteValue

function pref_ListValues
   -- changed to list current global prefs (not stored)
   -- was "pref_GetValues"
   global gPrefs_Array
   return keys (gPrefs_Array)
end pref_ListValues


--> Pref | Global | Model
-
function pref_ListStoredValues pProjectName
   -- was "pref_GetValues"
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   put pref_FetchData() into dataArray
   get dataArray [pProjectName]
   return keys(it)
end pref_ListStoredValues

function pref_FetchGlobal pGlobalName, pProjectName
   if pGlobalName is empty then put "gPrefs_Array" into pGlobalName
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   put pref_FetchData() into dataArray
   return dataArray [pProjectName][pGlobalName]
end pref_FetchGlobal

command pref_StoreGlobal gValue, pGlobalName, pProjectName
   if pGlobalName is empty then put "gPrefs_Array" into gName
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   put pref_FetchData() into dataArray
   put gValue into dataArray [pProjectName][pGlobalName]
   pref_StoreData dataArray
end pref_StoreGlobal


--> Pref | Fetch
-
function pref_FetchValue prefName, pProjectName
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   put pref_FetchArray (pProjectName) into prefArray
   put prefArray [prefName] into someValue
   return someValue
end pref_FetchValue

command pref_SaveValue prefName, someValue, pProjectName
   global gPrefs_Array
   put pref_fetchArray (pProjectName) into prefArray
   put someValue into prefArray [prefName]
   pref_StoreArray prefArray, pProjectName
   put the result into  dataArray
   put prefArray into gPrefs_Array
   return dataArray
end pref_SaveValue

command pref_RemoveValue prefName, pProjectName
   -- was "pref_DeleteValue" but this was a name clash
   pref_DeleteValue prefName
   put the result into prefArray
   pref_StoreArray prefArray, pProjectName
end pref_RemoveValue


--> Pref | Sets
-
function pref_ListSetNames
   put pref_FetchData() into dataArray
   return keys (dataArray)
end pref_ListSetNames

command pref_DeleteSet pProjectName
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   put pref_FetchData() into dataArray
   delete variable dataArray [pProjectName]
   pref_StoreData dataArray
end pref_DeleteSet


--> Pref | Array
-
function pref_FetchArray pProjectName
   -- contains all the preference globals int the set with the keys as global names
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   put pref_FetchData() into dataArray
   return dataArray [pProjectName]
end pref_FetchArray

command pref_StoreArray prefArray, pProjectName
   -- contains all the preference globals int the set with the keys as global names
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   put pref_FetchData() into dataArray
   put prefArray into dataArray [pProjectName]
   pref_StoreData dataArray
   put the result into  someFile
   return dataArray
end pref_StoreArray


--> Pref | Data
-
function pref_FetchData
   put pref_File() into someFile
   put array_Fetch (someFile) into dataArray
   return dataArray
end pref_FetchData

command pref_StoreData dataArray
   put pref_File() into someFile
   array_Save someFile, dataArray
   return someFile
end pref_StoreData


--> Pref | Files and Folders
-
function pref_File pModelName
   put library_PrefFolder ("opn_pref.array") into someFile
   return someFile
end pref_File

function library_PrefFolder shortFile
   put pref_Folder() & "OPN/" into opnPreferenceFolder
   folder_CreateNested opnPreferenceFolder
   put shortFile after opnPreferenceFolder
   return opnPreferenceFolder
end library_PrefFolder

function pref_Folder
   -- "preference" folders are not standard on all operating systems.
   -- In general it may be better, to avoid lot's of nested if thens and instead switch libraries and behaviors for different platform specific code.
   
   if the platform is "MacOS" then
      put specialfolderpath ("preferences") & "/" into prefFolder
   else if the platform is "Win32" then
      put pref_WindowsFolder() into prefFolder
   else
      -- put $HOME & "/Documents/"	# somewhere better?
      put specialfolderpath ("Home") & "/.MyProgram/" into prefFolder
   end if
   return prefFolder
end pref_Folder

function pref_WindowsFolder
   /*
   This is old code, and not tested.
   In general it may be better, to avoid lot's of nested if thens and instead switch libraries and behaviors for different platform specific code.
   
   CSIDL_APPDATA (FOLDERID_RoamingAppData)
   version 4.71. The file system directory that serves as a common repository for application-specific data. 
   A typical path is C:\Documents and Settings\username\Application Data. 
   This CSIDL is supported by the redistributable Shfolder.dll for systems 
   that do not have the Microsoft internet Explorer 4.0 integrated shell installed.
   
   CSIDL_LOCAL_APPDATA (FOLDERID_LocalAppData)
   version 5.0. The file system directory that serves as a data repository for local (nonroaming) applications. 
   A typical path is C:\Documents and Settings\username\Local Settings\Application Data.
   
   CSIDL_APPDATA (0x001a)
   version 4.71. The file system directory that serves as a common repository for application-specific data. 
   A typical path is C:\Documents and Settings\username\Application Data. 
   This CSIDL is supported by the redistributable Shfolder.dll for systems that do not have the Microsoft internet Explorer 4.0 integrated shell installed.
   */
   
   -- not tested
   breakpoint
   put specialfolderpath (baseconvert("0x001a",16,10)) into preferenceFolder
   return preferenceFolder & "/"
   
   put specialfolderpath ("0x001a") & "/MyProgram/" into myPreferences
   put specialfolderpath ("Documents") & merge("/[[username]]/Application Data/") into prefFolder
   return prefFolder
end pref_WindowsFolder


--> Deps
-
function project_GetCurrentName
   global gLibrarySet_Array
   put gLibrarySet_Array ["metadata"]["library_SetName"] into setName
   if setName is empty then put "Default" into setName
   return setName
end project_GetCurrentName
