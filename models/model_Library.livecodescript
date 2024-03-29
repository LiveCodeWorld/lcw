﻿script "model_Library"
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
function user_GetFolder
   /*
   Updated this function so that it should work without stack "lcw_user" existing or known.
   Still probably a good idea to create a project and store it for use customisation.
   When starting a nre LCW project we cannot reply on having data in lcw_User project as it is usr specific.
   */
   -- /Users/david/Documents/My Revolution Enterprise/lcw_User/
   -- Should it be "revUserPluginsFolder" or "revMyDocumentsFolder"?
   -- put the stack_Folder of stack "lcw_User" into projectFolder
   put the documents folder & "/My Revolution Enterprise/lcw_User/" into projectFolder
   return projectFolder
end user_GetFolder

command display_Secrets pArrayKey
   put tolower(pArrayKey) & "_Authentication.array" into shortArrayFile
   put user_GetArray (shortArrayFile) into userArray
   --
   display_Data userArray, "Hubspot", "Secrets"
end display_Secrets

private function _ConstructShortArrayFile pArrayKey
   -- "pinterest_Authentication.array" or "secret_Authentication.array" (default)
   if pArrayKey is empty then put "secret" into pArrayKey
   put tolower(pArrayKey) & "_Authentication.array" into shortFile
   return shortFile
end _ConstructShortArrayFile


--> Model | User
-
function user_GetValue someKey, shortArrayFile
   put user_GetArray (shortArrayFile) into userArray
   put userArray [someKey] into someValue
   return someValue
end user_GetValue

command user_SetValue someKey, shortArrayFile, someValue
   put user_GetArray (shortArrayFile) into userArray
   put someValue into userArray [someKey]
   user_SetArray shortArrayFile, userArray
   put the result into modelDataFile
   return modelDataFile
end user_SetValue

function user_GetModelFile shortFile
   put user_GetFolder() into projectFolder
   put model_GetDataFile ("lcw_User", projectFolder, shortFile) into modelFile
   return modelFile
end user_GetModelFile

function user_GetArray shortFile
   if the environment = "server" then
      -- put gConfig ["dropBoxAuthToken"] into dropBoxAuthToken
      -- put rigFetchConfigItem ("dropBoxAuthToken") into dropBoxAuthToken
      put rigLoadConfigFile (shortFile, TRUE) into modelArray
   else
      -- put the model_Array [shortFile] of stack "lcw_User" into modelArray
      
      put user_GetModelFile (shortFile) into modelFile
      put array_FetchModel (modelFile) into modelArray
   end if
   return modelArray
end user_GetArray

command user_AddArray shortFile, newArray
   put user_GetArray (shortFile) into userArray
   --
   difference userArray with newArray
   union userArray with newArray
   --
   user_SetArray shortFile, userArray
   put the result into modelFile
   return modelFile
end user_AddArray

command user_SetArray shortFile, modelArray
   if the platform is "server" then
      
   else
      -- set the model_Array [shortFile] of stack "lcw_User" to modelArray
      -- put the result into modelFile
      put user_GetModelFile (shortFile) into modelFile
      array_SaveModel modelFile, modelArray
   end if
   return modelFile
end user_SetArray


--> Model | Array | Data
-
/*
This is correct version of model_Array
*/

getprop array_Models [pModelName]
   if pModelName is empty then
      put the model_Name of the target into pModelName
   end if
   
   put the project_Folder of the target into projectFolder
   put model_ListNames (pModelName, projectFolder) into modelNames
   return modelNames
end array_Models

getprop array_Data [modelNameItems]
   put the model_ArrayFile [modelNameItems] of the target into modelArrayFile
   put array_FetchModel (modelArrayFile) into modelArray
   return modelArray
end array_Data

setprop array_Data [modelNameItems] modelArray
   put the model_ArrayFile [modelNameItems] of the target into modelArrayFile
   array_SaveModel modelArrayFile, modelArray
   return modelArrayFile
end array_Data

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
      model_AddData modelData, modelDataFolder
   end repeat
   return modelData
end model_Data

function model_GetData modelDataFolder
   local modelData
   model_AddData modelData, modelDataFolder
   return modelData   
end model_GetData

private command model_AddData @modelData, modelDataFolder
   put files (modelDataFolder) into shortFiles
   repeat for each line shortFile in shortFiles
      put dataFolder_GetFile (modelDataFolder, shortFile) into modelDataFile
      put array_FetchModel (modelDataFile) into modelArray
      put modelArray into modelData [shortFile]
   end repeat
end model_AddData


--> Model | Props
-
/*
Models are stored by default in a folder named after the short name of the stack at the same level as the stack
*/

getprop user_Array [pShortFile]
   return user_GetArray (pShortFile)
end user_Array

setprop user_Array [pShortFile] modelArray
   if modelArray is empty then
      breakpoint
   end if
   user_SetArray pShortFile, modelArray
   put the result into modelDataFile
   return modelDataFile
end user_Array

getprop model_Value [pKey]
   if pKey is empty then put "default" into pKey
   put the model_Array of the target into mArray
   put mArray [pKey] into sValue
   return sValue
end model_Value

setprop model_Value [pKey] sValue
   if pKey is empty then put "default" into pKey
   put the model_Array of the target into mArray
   put sValue into mArray [pKey]
   set the model_Array of the target to mArray
   return the result
end model_Value

getprop model_Array [pShortFile]
   -- assumes the target is a model stack
   put the model_DataFile [pShortFile] of the target into modelDataFile
   put array_FetchModel (modelDataFile) into modelArray
   return modelArray
end model_Array

setprop model_Array [pShortFile] dataArray
   -- assumes the target is a model stack
   put the model_DataFile [pShortFile] of the target into modelDataFile
   array_SaveModel modelDataFile, dataArray
   return the result
end model_Array

getprop model_Names
   put the short name of the defaultstack into modelStackName
   put the project_Folder of the target into projectFolder
   put model_ListNames (modelStackName, projectFolder) into shortFiles
   return shortFiles
end model_Names

getprop model_DataFile [pShortFile]
   -- assumes the target is a model stack
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


--> Model | Files
-
function model_GetDataFolder modelStackName, projectFolder
   put folder_AddShort (projectFolder, "models") into rootModelsFolder
   put rootModelsFolder & modelStackName & slash into modelDataFolder
   return modelDataFolder
end model_GetDataFolder

function model_GetDataFile modelStackName, projectFolder, pShortFile
   put model_GetDataFolder (modelStackName, projectFolder) into modelDataFolder
   put dataFolder_GetFile (modelDataFolder, pShortFile) into modelDataFile
   return modelDataFile
end model_GetDataFile



--> Model | List
-
function model_ListNames modelStackName, projectFolder
   put projectFolder & "models/" & modelStackName & slash into modelDataFolder
   put folder_ListShortFiles (modelDataFolder) into shortFiles
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


--> Model | Array
-
function model_GetFile arrayName, modelName, projectFolder
   put arrayName & ".array" into shortFile
   put model_GetDataFile (modelName, projectFolder, shortFile) into modelArrayFile
   return modelArrayFile
end model_GetFile

function model_FetchArray modelStackName, projectFolder, pShortFile 
   put model_GetDataFolder (modelStackName, projectFolder) into modelDataFolder
   put dataFolder_GetFile (modelDataFolder, pShortFile) into modelArrayFile
   put array_FetchModel (modelArrayFile) into modelArray
   return modelArray
end model_FetchArray

command model_StoreArray modelStackName, projectFolder, modelArray, pShortFile
   put model_GetDataFolder (modelStackName, projectFolder) into modelDataFolder
   put dataFolder_GetFile (modelDataFolder, pShortFile) into modelArrayFile
   array_SaveModel modelArrayFile, modelArray
   return modelArrayFile
end model_StoreArray


--> Array | Model
-
/*
Modified versions of "array_Fetch" and "array_Save"
Allows storing mmodels as json or other formats based on their file extensions.

The aim is to standarize different ways in which arrays can be stored and fetched,
in order to make it easier to switch models from simple text files, json files, encoded arrays or databases.
*/

function array_FetchModel someFile
   -- allows for simple switching of models
   put url ("binfile:" & someFile) into someData
   if someData is empty then return empty
   set the itemdelimiter to "."
   switch item -1 of someFile
      case "json"
         put jsonImport (someData) into modelArray
         return modelArray
      case "array"
         put arraydecode (someData) into modelArray
         return modelArray
      default
         return someData
   end switch
end array_FetchModel

command array_SaveModel someFile, modelArray
   if modelArray is not an array then
      delete file someFile
      return "deleted" && someFile
   end if
   
   set the itemdelimiter to "."
   switch item -1 of someFile
      case "json"
         put jsonExport (modelArray) into encodedData
         break
      case "array"
         put arrayencode (modelArray) into encodedData
         break
      default -- case "array"
         put modelArray into encodedData
   end switch
   
   folder_CreateFromFile someFile -- create folder if it does not exist
   put encodedData into url ("binfile:" & someFile)
   --
   return someFile
end array_SaveModel

function dataFolder_GetFile modelDataFolder, pShortFile
   if pShortFile is empty then
      set the itemdelimiter to slash
      put item -1 of modelDataFolder into modelName
      put modelName & ".array" into pShortFile
   end if
   put modelDataFolder & pShortFile into modelDataFile
   return modelDataFile
end dataFolder_GetFile
