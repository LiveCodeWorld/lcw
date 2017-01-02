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
   if pName is empty then put env_GetProjectFocus() into pName
   put pref_FetchValue ("server_Array", pName) into serverArray
   return serverArray
end pref_FetchServerArray

command pref_StoreServerArray serverArray, pName
   if pName is empty then put env_GetProjectFocus() into pName
   pref_SaveValue "server_Array", serverArray, pName
   put the result into dataArray
   return dataArray
end pref_StoreServerArray


--> Pref | Project | Model
-
/*
Here we store preferences related to a given project in the users LCW preference array.
*/

--> Pref | Project | Model
-
function pref_FetchValue prefName, pProjectName
   if pProjectName is empty then put env_GetProjectFocus() into pProjectName
   put pref_FetchArray (pProjectName) into prefArray
   put prefArray [prefName] into someValue
   return someValue
end pref_FetchValue

command pref_SaveValue prefName, someValue, pProjectName
   global gLCW
   put pref_fetchArray (pProjectName) into prefArray
   put someValue into prefArray [prefName]
   pref_StoreArray prefArray, pProjectName
   put the result into dataArray
   put prefArray into gLCW ["prefsArray"]
   return dataArray
end pref_SaveValue

command pref_RemoveValue prefName, pProjectName
   -- was "pref_DeleteValue" but this was a name clash
   pref_DeleteValue prefName
   put the result into prefArray
   pref_StoreArray prefArray, pProjectName
end pref_RemoveValue

function pref_ListStoredValues pProjectName
   -- was "pref_GetValues"
   if pProjectName is empty then put env_GetProjectFocus() into pProjectName
   put pref_FetchData() into libraryPreferenceArray
   put libraryPreferenceArray [pProjectName] into libraryProjectPreferenceArray
   put keys (libraryProjectPreferenceArray) into libraryProjectPreferenceKeys
   sort libraryProjectPreferenceKeys
   return libraryProjectPreferenceKeys
end pref_ListStoredValues

function pref_FetchGlobal pPrefKey, pProjectName
   if pPrefKey is empty then put "gPrefs_Array" into pPrefKey
   if pProjectName is empty then put env_GetProjectFocus() into pProjectName
   put pref_FetchData() into dataArray
   return dataArray [pProjectName][pPrefKey]
end pref_FetchGlobal

command pref_StoreGlobal prefValue, pPrefKey, pProjectName
   if pPrefKey is empty then put "gPrefs_Array" into pPrefKey
   if pProjectName is empty then put env_GetProjectFocus() into pProjectName
   put pref_FetchData() into dataArray
   put prefValue into dataArray [pProjectName][pPrefKey]
   pref_StoreData dataArray
end pref_StoreGlobal


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


--> Pref | Global | Model
-
function pref_GetValue prefName
   global gLCW
   return gLCW ["prefsArray"][prefName]
end pref_GetValue

command pref_SetValue prefName, someValue
   global gLCW
   put someValue into gLCW ["prefsArray"][prefName]
   return gLCW ["prefsArray"]
end pref_SetValue

command pref_DeleteValue prefName
   global gLCW
   delete variable gLCW ["prefsArray"][prefName]
   return gLCW ["prefsArray"]
end pref_DeleteValue

function pref_ListValues
   global gLCW
   put gLCW ["prefsArray"] into prefArray
   put keys (prefArray) into prefNames
   sort prefNames
   return prefNames
end pref_ListValues


--> Pref | Sets
-
function pref_ListSetNames
   put pref_FetchData() into dataArray
   return keys (dataArray)
end pref_ListSetNames

command pref_DeleteSet pProjectName
   if pProjectName is empty then put env_GetProjectFocus() into pProjectName
   put pref_FetchData() into dataArray
   delete variable dataArray [pProjectName]
   pref_StoreData dataArray
end pref_DeleteSet


--> Pref | Array
-
function pref_FetchArray pProjectName
   -- contains all the preference globals int the set with the keys as global names
   if pProjectName is empty then put env_GetProjectFocus() into pProjectName
   put pref_FetchData() into dataArray
   return dataArray [pProjectName]
end pref_FetchArray

command pref_StoreArray prefArray, pProjectName
   -- contains all the preference globals int the set with the keys as global names
   if pProjectName is empty then put env_GetProjectFocus() into pProjectName
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
function pref_File
   put specialfolderpath ("preferences") & "/lcw_Preferences.array" into prefFile
   return prefFile
end pref_File

function library_PrefFolder
   put specialfolderpath ("preferences") & "/" into prefFolder
   return prefFolder
end library_PrefFolder
