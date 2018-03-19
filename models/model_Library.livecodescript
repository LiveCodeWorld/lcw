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


--> Model | Props
-
/*
Models are stored by default in a folder named after the short name of the stack at the same level as the stack
*/

getprop user_Array [pShortFile]
   return user_GetArray (pShortFile)
end user_Array

setprop user_Array [pShortFile] modelArray
   user_SetArray pShortFile, modelArray
   put the result into modelDataFile
   return modelDataFile
end user_Array

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
   return modelDataFile
end model_Array

getprop model_Names
   put the stack_Name of the target into modelStackName
   put the project_Folder of the target into projectFolder
   put model_ListNames (modelStackName, projectFolder) into shortFiles
   return shortFiles
end model_Names

getprop model_DataFile [pShortFile]
   -- assumes the target is a model stack
   put the stack_Name of the target into modelStackName
   put the stack_Folder of the target into projectFolder
   -- put projectFolder & modelStackName & slash into modelDataFolder
   -- put dataFolder_GetFile (modelDataFolder, pShortFile) into modelDataFile
   
   put the project_Folder of the target into projectFolder
   put model_GetDataFile (modelStackName, projectFolder, pShortFile) into modelDataFile
   
   return modelDataFile
end model_DataFile

getprop model_DataFolder [modelStackName]
   if modelStackName is empty then
      -- we assume the target is a model stack in the "models/" folder
      -- simple utitlity that looks for a sister folder to any stack
      put the stack_Name of the target into modelName
      put the stack_Folder of the target into stackFolder
      put stackFolder & modelName & slash into modelDataFolder
   else
      -- will search for the model data folder in the "models/" folder of the project the target stack is in
      put the project_Folder of the target into projectFolder
      put model_GetDataFolder (modelStackName, projectFolder) into modelDataFolder
   end if
   return modelDataFolder
end model_DataFolder


--> Model | User
-
function user_GetArray shortFile
   put the model_Array [shortFile] of stack "lcw_User" into modelArray
   return modelArray
end user_GetArray

command user_SetArray shortFile, modelArray
   set the model_Array [shortFile] of stack "lcw_User" to modelArray
   put the result into modelDataFile
   return modelDataFile
end user_SetArray
   
   
--> Model | Files
-
function model_GetDataFolder modelStackName, projectFolder
   put project_ConstructFolder ("models", projectFolder) into rootModelsFolder
   put rootModelsFolder & modelStackName & slash into modelDataFolder
   return modelDataFolder
end model_GetDataFolder

function model_GetDataFile modelStackName, projectFolder, pShortFile
   put model_GetDataFolder (modelStackName, projectFolder) into modelDataFolder
   put dataFolder_GetFile (modelDataFolder, pShortFile) into modelDataFile
   return modelDataFile
end model_GetDataFile

private function dataFolder_GetFile modelDataFolder, pShortFile
   if pShortFile is empty then
      set the itemdelimiter to slash
      put item -1 of modelDataFolder into modelName
      put modelName & ".array" into pShortFile
   end if
   put modelDataFolder & pShortFile into modelDataFile
   return modelDataFile
end dataFolder_GetFile



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
   if modelArray is not an array then delete file someFile
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
   return encodedData
end array_SaveModel
