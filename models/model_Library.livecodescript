script "model_Library"
--> MetaData
-
license: GPLv3
name: model_OldLibrary
type: model
version: 0.1

/*
In order for the lcw environment to know where individual project folders are,
and to store other data that applies across all projects
we need to store the information somewhere that is universally accessible to any tools that need it.

Here we define global named arrays that are stored on disc (in a preference file,
and another array broken into project specific keys.

These functions were introduced in v5.5

revEnvironmentUserExternalsPath()  -- The location of the folder to use for additional externals. 
revEnvironmentUserPluginsPath()  -- The location of the folder to use for additional plugins. 
revEnvironmentUserResourcesPath() -- The location of the folder to use for additional resources.

revEnvironmentCustomizationPath()  -- The location of the IDE customization folder.
revEnvironmentUserCachePath()  -- The location of the folder to use for caching files.
revEnvironmentUserPreferencesPath()  -- The location of the folder to use for preference files.

revEnvironmentToolsPath() -- The location containing the main IDE files.
revEnvironmentToolsetPath()  -- The location of the main IDE stacks.
revEnvironmentExternalsPath()  -- The location of the externals that come with the IDE. 
revEnvironmentPluginsPath()  -- The location of the plugins that come with the IDE.
revEnvironmentRuntimePath()  -- The location of the standalones that come with the IDE. 

revEnvironmentDocumentationPath()  -- The location of the documentation files.
revEnvironmentResourcesPath()  -- The location of the resources that come with the IDE. 

This is an old messy naming structure.
The array is stored in a file called "gOPN_LibrarySets" in library_PluginFolder ("opn_Text/array/")
in revEnvironmentUserPluginsPath() & "/opn_Plugins/"
Keys are named  things like "gOPN_LibrarySets"

Need to move the array to either the LCW project folder, or the revEnvironmentUserPluginsPath() folder or equivalent.

*/


--> Working on
-
function env_ListHomeArrayFiles
   put env_GetHomeArrayFileData() into envProjectArrayFileArray
   put envProjectArrayFileArray ["projectArrayFiles"] into projectArrayFiles
   return projectArrayFiles 
end env_ListHomeArrayFiles

function env_GetHomeArrayFileData
   put library_ListProjectNames() into projectNames
   repeat for each line projectName in projectNames
      put project_GetArrayFile (projectName) into projectArrayFile
      if there is a file projectArrayFile then
         put projectArrayFile into envProjectArrayFileArray ["projectNames"][projectName]
         put projectName into envProjectArrayFileArray ["projectArrayFiles"][projectArrayFile]
      end if
   end repeat
   return envProjectArrayFileArray
end env_GetHomeArrayFileData



--> Library | Project | Model | Folders | Naming
-
/*
These handlers define the keys for the 
*/

function library_FetchProjectFolder homeStackName
   put library_FetchProjectArray (homeStackName) into projectArray
   put projectArray ["projectFolder"] into projectFolder
   
   if projectFolder is empty then return projectFolder
   text_AddTrailing projectFolder, slash   
   if there is a folder projectFolder then
      return projectFolder
   else
      return empty
   end if
end library_FetchProjectFolder   

command library_StoreProjectFolder homeStackName, projectFolder
   put library_FetchProjectArray (homeStackName) into projectArray
   --
   put projectFolder into projectArray ["projectFolder"]
   set the itemdelimiter to slash
   if item - 2 of projectFolder = "modules" then
      put "module" into projectArray ["projectType"]
   else
      put "project" into projectArray ["projectType"]
   end if
   --
   library_StoreProjectArray homeStackName, projectArray
end library_StoreProjectFolder

function library_FetchProjectData
   put library_FetchArray ("lcw_ProjectDataLibrary") into libraryProjectData
   return libraryProjectData
end library_FetchProjectData

command library_StoreProjectData libraryProjectData
   library_StoreArray "lcw_ProjectDataLibrary", libraryProjectData
end library_StoreProjectData


--> Library | Project | Model | Folders
-
function library_ListProjectModules
   put library_FetchProjectData() into libraryProjectData
   put _FilterLibraryProjectArray ("module", libraryProjectData) into moduleStackNames
   return moduleStackNames
end library_ListProjectModules

function library_ListProjectNames pProjectType
   put library_FetchProjectData() into libraryProjectData
   switch pProjectType
      case "all"
         put keys (libraryProjectData) into projectNames
         break
      case "module"
         put _FilterLibraryProjectArray ("module", libraryProjectData) into projectNames
         break
      default -- case "project"
         put _FilterLibraryProjectArray ("project", libraryProjectData) into projectNames
   end switch
   sort projectNames
   return projectNames
end library_ListProjectNames

function library_ListProjectFolders
   put library_FetchProjectData() into libraryProjectArray
   repeat for each key projectName in libraryProjectArray
      put libraryProjectArray [projectName] into projectArray
      put projectArray ["projectFolder"] into libraryRepoFolder
      if there is not a folder libraryRepoFolder then
         next repeat
      end if
      put projectName into libraryRepoFolderArray [libraryRepoFolder]
   end repeat
   put keys (libraryRepoFolderArray) into libraryRepoFolders
   sort libraryRepoFolders
   return word 1 to -1 of libraryRepoFolders
end library_ListProjectFolders


--> Library | Project | Model | Stacks
-
function library_FetchProjectHomeStackObject projectName
   put library_FetchProjectHomeStackPath (projectName) into homeStackPath
   if exists (stack homeStackPath) is false then return empty
   return the long id of stack homeStackPath
end library_FetchProjectHomeStackObject

function library_FetchProjectHomeStackPath projectHomeStackName
   put library_FetchProjectFolder (projectHomeStackName) into projectFolder
   if projectFolder is empty then return empty
   text_AddTrailing projectFolder, slash
   put project_NameToShortFolder (projectHomeStackName) into projectShortFolder
   put projectFolder & projectShortFolder & ".livecode" into homeStackPath
   return homeStackPath
end library_FetchProjectHomeStackPath


--> Library | Project | Model
-
command library_TidyProjectModel
   put library_FetchProjectData() into libraryProjectData
   repeat for each key projectName in libraryProjectData
      put libraryProjectData [projectName]["projectType"] into someType
      put libraryProjectData [projectName]["projectFolder"] into someFolder
      switch
         case projectName is empty
            delete variable libraryProjectData [projectName]
            break
         case someType is not among the items of "project,module"
            delete variable libraryProjectData [projectName]
            break
         case there is not a folder someFolder
            delete variable libraryProjectData [projectName]
            break
         default
            -- all is fine
      end switch
   end repeat
   library_StoreProjectData libraryProjectData
end library_TidyProjectModel

function library_FetchProjectValue someKey, pProjectName
   if pProjectName is empty then put env_GetProjectFocus() into pProjectName
   put library_FetchProjectArray (pProjectName) into projectArray
   put projectArray [someKey] into someValue
   return someValue
end library_FetchProjectValue

command library_SaveProjectValue someKey, someValue, pProjectName
   if pProjectName is empty then put env_GetProjectFocus() into pProjectName
   put library_FetchProjectArray (pProjectName) into projectArray
   put someValue into projectArray [someKey]
   library_StoreProjectArray pProjectName, projectArray
   return projectArray
end library_SaveProjectValue

function library_FetchProjectArray pProjectName
   -- was "library_FetchProjectArray"
   if pProjectName is empty then put env_GetProjectFocus() into pProjectName
   put library_FetchProjectData() into libraryProjectData
   put libraryProjectData [pProjectName] into projectArray
   return projectArray
end library_FetchProjectArray

command library_StoreProjectArray projectName, projectArray
   put library_FetchProjectData() into libraryProjectData
   put projectArray into libraryProjectData [projectName]
   library_StoreProjectData libraryProjectData
   return libraryProjectData
end library_StoreProjectArray

command library_DeleteProjectArray projectName
   put library_FetchProjectData() into libraryProjectData
   delete variable libraryProjectData [projectName]
   library_StoreProjectData libraryProjectData
end library_DeleteProjectArray


--> Library | Array | Model
-
/*
For storing arbitrary system wide named arrays.
*/

function library_ListArrayNames
   put library_ListArrayFiles (true) into shortFiles
   set the columndelimiter to "."
   split shortFiles by column
   put shortFiles [1] into libraryArrayNames
   sort libraryArrayNames
   return libraryArrayNames
end library_ListArrayNames

function library_ListArrayFiles pListShort
   put shortName & ".array" into shortFile
   put library_ArrayFolder () into libraryArrayFolder
   -- put folder_ListFiles (someFolder)
   put files (libraryArrayFolder) into shortFiles
   filter shortFiles with "*.array"
   if pListShort is true then
      return shortFiles
   else
      put file_AddFolderToPaths (shortFiles, libraryArrayFolder) into filePaths
      return filePaths
   end if
end library_ListArrayFiles

function library_FetchArray shortName
   put library_GetArrayFile (shortName) into someFile
   put array_Fetch (someFile) into modelArray
   return modelArray
end library_FetchArray

command library_StoreArray shortName, dataArray
   put library_GetArrayFile (shortName) into someFile
   array_Save someFile, dataArray
   return someFile
end library_StoreArray

command library_DeleteArray shortName
   put library_GetArrayFile (shortName) into someFile
   delete file someFile
   return someFile
end library_DeleteArray


--> Project | Array | Model
-
function project_FetchValue someKey, pProjectName
   put project_FetchArray (pProjectName) into projectArray
   put projectArray [someKey] into someValue
   return someValue
end project_FetchValue

command project_SaveValue someKey, someValue, pProjectName
   if pProjectName is empty then put env_GetProjectFocus() into pProjectName
   put project_FetchArray (pProjectName) into projectArray
   put someValue into projectArray [someKey]
   project_StoreArray pProjectName, projectArray
   return projectArray
end project_SaveValue

command project_DeleteValue someKey, pProjectName
   if pProjectName is empty then put env_GetProjectFocus() into pProjectName
   put project_FetchArray (pProjectName) into projectArray
   delete variable projectArray [someKey]
   project_StoreArray pProjectName, projectArray
   return projectArray
end project_DeleteValue

command project_AddArrayToGlobal projectArray, pRecursively
   /*
   By default (if pRecursively is false or empty), this command merges the all keys recursively, adding new items to gLCW from projectArray
   but keeping any old items that are not in projectArray.
   Consequenlty this "adds" the contents of the projectArray to gLCW with the exception of leaf contents which are updated or replaced.
   So if you want a merge - store your data as an array not an index.
   
   if pRecursively is false then this command replaces items that are already there with the contents of projectArray
   Consequenlty this adds or "sets" the contents of the variable
   */
   global gLCW
   
   if pRecursively is not false then
      union projectArray with gLCW recursively
   else
      union projectArray with gLCW
   end if
   put projectArray into gLCW
   return gLCW
end project_AddArrayToGlobal

function project_FetchArray pProjectName
   if pProjectName is empty then put env_GetProjectFocus() into pProjectName
   put project_GetArrayFile (pProjectName) into projectArrayFile
   put array_Fetch (projectArrayFile) into projectArray
   return projectArray
end project_FetchArray

command project_StoreArray projectName, projectArray
   put project_GetArrayFile (projectName) into projectArrayFile
   array_Save projectArrayFile, projectArray
   return projectArrayFile
end project_StoreArray


--> Project | Array | Model | Files
-
function project_GetArrayFile projectName
   put project_GetFolder (projectName) & "lcw_project.array" into projectArrayFile
   return projectArrayFile
end project_GetArrayFile

function project_GetJsonFile projectName
   put project_GetFolder (projectName) & "lcw_project.json" into arrayFile
   return arrayFile
end project_GetJsonFile


--> Model | Files
-
function library_GetArrayFile shortName, pDontCreate
   put shortName & ".array" into shortFile
   put library_ArrayFolder (shortFile, pDontCreate) into someFile
   return someFile
end library_GetArrayFile

function library_ArrayFolder shortFileBit, pDontCreate  
   -- return library_PluginFolder ("opn_Text/array/", pDontCreate) & shortFileBit
   
   put lcw_GetRootFolder() into projectFolder
   put model_GetDataFolder ("model_Library", projectFolder) into libraryArrayFolder
   put shortFileBit after libraryArrayFolder
   return libraryArrayFolder
end library_ArrayFolder


--> Model | Props
-
getprop project_Array
   put the project_ArrayFile of the target into projectArrayFile
   put array_Fetch (projectArrayFile) into projectArray
   return projectArray
end project_Array

getprop project_ArrayFile
   put the project_Folder of the target into projectFolder
   put projectFolder & "lcw_project.array" into projectArrayFile
   return projectArrayFile
end project_ArrayFile

getprop project_JsonFile
   put the stack_Name of the target into stackName
   put project_GetJsonFile (stackName) into arrayFile
   return arrayFile
end project_JsonFile


--> Private
-
private function _FilterLibraryProjectArray projectType, libraryProjectData
   repeat for each key projectName in libraryProjectData
      put libraryProjectData [projectName]["projectType"] into someType
      -- put libraryProjectData [projectName]["projectFolder"] into someFolder
      if someType = projectType then
         put projectName & CR after projectNames
      end if
   end repeat
   delete char -1 of projectNames
   return projectNames
end _FilterLibraryProjectArray
