script "model_Library"
--> MetaData
-
license: GPLv3
name: model_OldLibrary
type: model
version: 0.2

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


--> Project | Model | Array
-
/*
These handlers can be in a separate model library.

Convenience handlers that uses a simple naming convention.
in which a folder placed at the same level of a stack and named the smae as the short name of a stack 
contains any number of named data files.

The default model_DataFile of a stack "model_SivaSiva" in a path of the form /path/to/model_SivaSiva.livecode
for instance would be a /path/to/model_SivaSiva/model_SivaSiva.array

You can give alternative names by passing the param pShortFile. So
- the model_Array ["test.array"] of stack "model_SivaSiva" would get or store an array in the file "/path/to/model_SivaSiva/test.array"

A user_Model is like pref_FetchValue but stored in th lcw_User project 
The lcw_User project should only be stored on GitHub as a private repository to avoid publishing work in progress, and sensitive data.
*/

--> Working on
-
function model_GetData modelDataFolder
   local modelData
   _AddFolderToModel modelData, modelDataFolder
   return modelData   
end model_GetData


--> Module | Model
-
getprop module_Data
   put the module_Object of the target into mObject
   if exists (mObject) is false then return empty
   
   set the customPropertySet of mObject to "uModuleData"
   put the customProperties of mObject into mData
   set the customPropertySet of mObject to empty
   return mData
end module_Data

setprop module_Data mData
   put the module_Object of the target into mObject
   if exists (mObject) is false then return empty
   
   set the customPropertySet of mObject to "uModuleData"
   set the customProperties of mObject to mData
   set the customPropertySet of mObject to empty
   return mObject
end module_Data

getprop module_Array [pShortFile]
   put the module_Object of the target into mObject
   if exists (mObject) is false then return empty
   
   put the uModuleData [pShortFile] of mObject into mArray
   return mArray
end module_Array

setprop module_Array [pShortFile] mArray
   put the module_Object of the target into mObject
   if exists (mObject) is false then return empty
   
   set the uModuleData [pShortFile] of mObject to mArray
   return mObject
end module_Array

-- getprop module_Array
   put the module_JsonFile of the target into jsonFile
   put array_FromFile (jsonFile) into moduleArray
   return moduleArray
end module_Array

-- setprop module_Array moduleArray
   -- put the module_JsonFile of the target into jsonFile
   put the module_Name of the target into moduleName
   put the module_Folder of the target into moduleFolder
   if there is not a folder moduleFolder then return "Error, module_Folder does not exist for:" && the target
   --
   put module_ConstructJsonFile (moduleName, moduleFolder) into jsonFile
   
   if jsonFile is empty then return "Error, module_Folder does not exist for:" && the target
   array_ToFile jsonFile, moduleArray
   return jsonFile
   
   put the module_Folder of the target into moduleFolder
   if there is not a folder moduleFolder then return "Error, module folder does not exist for:" && the target
   project_StoreArray moduleFolder, moduleArray
   return moduleFolder
end module_Array

getprop module_JsonFile
   put the module_Name of the target into moduleName
   put the module_Folder of the target into moduleFolder
   if moduleFolder is empty then return empty
   --
   put module_JsonFile (moduleName, moduleFolder) into jsonFile
   return jsonFile
end module_JsonFile


--> Lcw | Model
-
getprop lcw_Array [pShortFile]
   -- by convention we a model stack
   put the lcw_ModelFile [pShortFile] of the target into mFile
   put array_FromFile (mFile) into mArray
   return mArray
end lcw_Array

setprop lcw_Array [pShortFile] dataArray
   put the lcw_ModelFile [pShortFile] of the target into mFile
   array_ToFile mFile, dataArray
   return the result
end lcw_Array

getprop lcw_ModelFile [pShortFile]
   if pShortFile is empty then put "model.json" into pShortFile
   put the lcw_Folder of the target into lcwFolder
   folder_CreateNested lcwFolder
   return lcwFolder & pShortFile
end lcw_ModelFile


--> Library
-
/*
These handlers store LCW project folders so that they can be in various places.
*/

function library_ListProjectModules
   put library_FetchProjectData() into libraryProjectData
   put "module" into projectType
   repeat for each key projectName in libraryProjectData
      put libraryProjectData [projectName]["projectType"] into someType
      -- put libraryProjectData [projectName]["projectFolder"] into someFolder
      if someType = projectType then
         put projectName & CR after projectNames
      end if
   end repeat
   delete char -1 of projectNames
   return projectNames
end library_ListProjectModules


--> Library | Project | Model | Utils
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


--> Library | Env
-
/*
Env information is also stored in the LCW library.
*/

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

command library_DeleteProjectArray projectName
   put library_FetchProjectData() into libraryProjectData
   delete variable libraryProjectData [projectName]
   library_StoreProjectData libraryProjectData
end library_DeleteProjectArray


--> Model | List
-
function model_ListNames modelStackName, projectFolder
   put projectFolder & "models/" & modelStackName & slash into modelDataFolder
   put file_ListShort (modelDataFolder) into shortFiles
   return shortFiles
end model_ListNames

function model_ListModelFiles pListShort
   put lcw_ArrayFolder() into libraryArrayFolder
   put files (libraryArrayFolder) into shortFiles
   filter shortFiles with "*.array"
   if pListShort is true then
      return shortFiles
   else
      put file_AddFolderToPaths (shortFiles, libraryArrayFolder) into filePaths
      return filePaths
   end if
end model_ListModelFiles


--> Model | Array | Data
-
/*
This is correct version of model_Array
*/

getprop model_Index [pShortFile]
   -- by convention we a model stack
   put the model_TextFile [pShortFile] of the target into indexFile
   put text_Get (indexFile) into sIndex
   return sIndex
end model_Index

setprop model_Index [pShortFile] sIndex
   -- by convention we a model stack
   put the model_TextFile [pShortFile] of the target into indexFile
   text_Set indexFile, sIndex
   return the result
end model_Index

getprop model_TextFile [pShortFile]
   if pShortFile is empty then put "index.txt" into pShortFile
   --
   put the short name of the defaultstack into modelStackName
   put the stack_Folder of the target into projectFolder
   put model_GetDataFile (modelStackName, projectFolder, pShortFile) into modelDataFile
   return modelDataFile
end model_TextFile

getprop model_ArrayFile [modelNameItems]
   put the project_Folder of the target into projectFolder
   --
   put item 1 of modelNameItems into arrayName
   put item 2 of modelNameItems into modelName
   if modelName is empty then
      put the model_Name of the target into modelName
   end if
   --
   return model_GetFile (arrayName, modelName, projectFolder)
end model_ArrayFile

getprop model_Name
   put the stack_Name of the target into modelName
   set the itemdelimiter to "_"
   put item -1 of modelName into modelName
   return modelName
end model_Name


--> Model | Data
-
getprop model_Data [modelStackNames]
   local modelData
   if modelStackNames is empty then
      put the model_Folder of the target into modelFolder
      put folders (modelFolder) into modelStackNames 
   end if
   --
   repeat for each line modelStackName in modelStackNames
      if char 1 of modelStackName = "." then next repeat
      put the model_DataFolder [modelStackName] of the target into modelDataFolder
      _AddFolderToModel modelData, modelDataFolder
   end repeat
   return modelData
end model_Data


--> Model | Props
-
/*
Models are stored by default in a folder named after the short name of the stack at the same level as the stack
*/

getprop model_Value [pKey]
   -- by convention we a model stack
   if pKey is empty then put "default" into pKey
   put the model_Array of the target into mArray
   put mArray [pKey] into sValue
   return sValue
end model_Value

setprop model_Value [pKey] sValue
   -- by convention we a model stack
   if pKey is empty then put "default" into pKey
   put the model_Array of the target into mArray
   put sValue into mArray [pKey]
   set the model_Array of the target to mArray
   return the result
end model_Value

getprop model_Array [pShortFile]
   -- by convention we a model stack
   put the model_DataFile [pShortFile] of the target into modelDataFile
   put array_FromFile (modelDataFile) into modelArray
   return modelArray
end model_Array

setprop model_Array [pShortFile] dataArray
   -- by convention we a model stack
   put the model_DataFile [pShortFile] of the target into modelDataFile
   array_ToFile modelDataFile, dataArray
   return the result
end model_Array

getprop model_Names
   -- by convention we a model stack
   put the short name of the defaultstack into modelStackName
   put the project_Folder of the target into projectFolder
   put model_ListNames (modelStackName, projectFolder) into shortFiles
   return shortFiles
end model_Names

getprop model_DataFile [pShortFile]
   -- by convention we a model stack
   put the short name of the defaultstack into modelStackName
   put the stack_Folder of the target into projectFolder
   put model_GetDataFile (modelStackName, projectFolder, pShortFile) into modelDataFile
   return modelDataFile
end model_DataFile

getprop model_DataFolder [modelStackName]
   if modelStackName is empty then
      -- we assume the target is a model stack in the "models/" folder
      -- simple utitlity that looks for a sister folder to any stack
      put the short name of the defaultstack into modelName
      put the stack_Folder of the target into stackFolder
      put stackFolder & modelName & slash into modelDataFolder
   else
      -- will search for the model data folder in the "models/" folder of the project the target stack is in
      put the project_Folder of the target into projectFolder
      put model_GetDataFolder (modelStackName, projectFolder) into modelDataFolder
   end if
   return modelDataFolder
end model_DataFolder

getprop model_Folder
   put the project_Folder of the target into projectFolder
   put folder_AddShort (projectFolder, "models") into rootModelsFolder
   return rootModelsFolder
end model_Folder


--> Private
-
private function _FilterLibraryProjectArray projectType, libraryProjectData
   repeat for each key projectName in libraryProjectData
      put libraryProjectData [projectName]["projectType"] into someType
      if someType = projectType then
         put projectName & CR after projectNames
      end if
   end repeat
   delete char -1 of projectNames
   return projectNames
end _FilterLibraryProjectArray

private function _ConstructModelDataFile modelDataFolder, pShortFile
   -- rename / replace
   if pShortFile is empty then
      set the itemdelimiter to slash
      put item -1 of modelDataFolder into modelName
      put modelName & ".array" into pShortFile
   end if
   put modelDataFolder & pShortFile into modelDataFile
   return modelDataFile
end _ConstructModelDataFile

private command _AddFolderToModel @modelData, modelDataFolder
   put files (modelDataFolder) into shortFiles
   repeat for each line shortFile in shortFiles
      put _ConstructModelDataFile (modelDataFolder, shortFile) into modelDataFile
      put array_FromFile (modelDataFile) into modelArray
      put modelArray into modelData [shortFile]
   end repeat
end _AddFolderToModel


--> Deps
-
getprop stack_Folder
   put the effective filename of the defaultstack into stackFolder
   set the itemdelimiter to slash
   put empty into item -1 of stackFolder
   return stackFolder
end stack_Folder

function text_Get someFile
   put url ("binfile:" & someFile) into binaryData
   put textDecode (binaryData, "UTF-8") into sText
   -- put url ("file:" & someFile) into sText
   return sText
end text_Get

command text_Set someFile, someText
   put someFile into scriptFolder
   set the itemdelimiter to slash
   put empty into item -1 of scriptFolder
   folder_CreateNested scriptFolder
   --
   put textEncode (word 1 to -1 of someText, "UTF-8") into binText
   put binText into url ("binfile:" & someFile)
   -- put word 1 to -1 of someText into url ("file:" & someFile)
   return the result
end text_Set
