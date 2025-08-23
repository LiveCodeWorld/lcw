script "model_LCW"
--> MetaData
-
license: GPLv3
name: model_LCW
type: model
version: 0.3

/*
This library contains all the key handlers for reading and writing arrays to disk.
It is designed to be standalon and minimal.

It is one of two key libraries that are used when LCW starts up.

There are three basic places for arrays to be stored:

- Model arrays - based on modelStackName, projectFolder, pShortFile 
- LCW arrays - based on "model_Library" and pShortFile
- Library arrays - stored in "lcw_ProjectDataLibrary.array" (contains folder and type info for modules, vies, and projects)

Don't think LCW array models have useful data - see display_LcwModels

Library Data is stored 
*/


--> Working on
-


--> Library | Model
-
function library_FetchProjectArray projectName
   -- was "library_FetchProjectArray"
   -- if projectName is empty then put env_GetProjectFocus() into projectName
   put library_FetchProjectData() into libraryProjectData
   put libraryProjectData [projectName] into projectArray
   return projectArray
end library_FetchProjectArray

command library_StoreProjectArray projectName, projectArray
   put library_FetchProjectData() into libraryProjectData
   put projectArray into libraryProjectData [projectName]
   library_StoreProjectData libraryProjectData
   return libraryProjectData
end library_StoreProjectArray

function library_FetchProjectData
   put lcw_FetchArray ("lcw_ProjectDataLibrary.array") into libraryProjectData
   return libraryProjectData
end library_FetchProjectData

command library_StoreProjectData libraryProjectData
   lcw_StoreArray "lcw_ProjectDataLibrary.array", libraryProjectData
end library_StoreProjectData


--> LCW | Model
-
function lcw_ListModelNames
   -- the short file names of files in the "model_Library" folder
   put "model_Library" into modelName
   put env_GetLcwFolder() into projectFolder
   put model_ListNames (modelName, projectFolder) into shortFiles
   return shortFiles
end lcw_ListModelNames

function lcw_FetchArray pShortFile
   set the itemdelimiter to "."
   if the number of items of pShortFile = 1 then put ".array" after pShortFile -- alows pretty short names
   
   put env_GetLcwFolder() into projectFolder
   put model_FetchArray ("model_Library", projectFolder, pShortFile) into modelArray
   return modelArray
end lcw_FetchArray

command lcw_StoreArray pShortFile, modelArray
   set the itemdelimiter to "."
   if the number of items of pShortFile = 1 then put ".array" after pShortFile -- alows pretty short names
   
   put env_GetLcwFolder() into projectFolder
   model_StoreArray "model_Library", projectFolder, modelArray, pShortFile
   put the result into modelDataFile
   return modelDataFile
end lcw_StoreArray

command lcw_DeleteArray pShortFile
   set the itemdelimiter to "."
   if the number of items of pShortFile = 1 then put ".array" after pShortFile -- alows pretty short names
   
   put lcw_GetArrayFile (pShortFile) into someFile
   delete file someFile
   return someFile
end lcw_DeleteArray


--> LCW | Model | Files
-
function lcw_GetArrayFile shortName, pDontCreate
   -- was "library_GetArrayFile"
   put shortName & ".array" into shortFile
   put lcw_ArrayFolder (shortFile, pDontCreate) into someFile
   return someFile
end lcw_GetArrayFile

function lcw_ArrayFolder pShortFile
   put env_GetLcwFolder() into projectFolder
   put model_GetDataFolder ("model_Library", projectFolder) into libraryArrayFolder
   put pShortFile after libraryArrayFolder
   return libraryArrayFolder
end lcw_ArrayFolder


--> Model | Array
-
function model_FetchArray modelStackName, projectFolder, pShortFile 
   put model_GetDataFolder (modelStackName, projectFolder) into modelDataFolder
   put _ConstructModelDataFile (modelDataFolder, pShortFile) into modelArrayFile
   put array_FromFile (modelArrayFile) into modelArray
   return modelArray
end model_FetchArray

command model_StoreArray modelStackName, projectFolder, modelArray, pShortFile
   put model_GetDataFolder (modelStackName, projectFolder) into modelDataFolder
   put _ConstructModelDataFile (modelDataFolder, pShortFile) into modelArrayFile
   array_ToFile modelArrayFile, modelArray
   return modelArrayFile
end model_StoreArray


--> Model | Files
-
function model_GetDataFile modelStackName, projectFolder, pShortFile
   if projectFolder is empty then return empty
   put model_GetDataFolder (modelStackName, projectFolder) into modelDataFolder
   put _ConstructModelDataFile (modelDataFolder, pShortFile) into modelDataFile
   return modelDataFile
end model_GetDataFile

function model_GetFile arrayName, modelName, projectFolder
   put arrayName & ".array" into shortFile
   put model_GetDataFile (modelName, projectFolder, shortFile) into modelArrayFile
   return modelArrayFile
end model_GetFile

function model_GetDataFolder modelStackName, projectFolder
   put folder_AddShort (projectFolder, "models") into rootModelsFolder
   put rootModelsFolder & modelStackName & slash into modelDataFolder
   return modelDataFolder
end model_GetDataFolder


--> Array | Model
-
/*
Modified versions of "array_Get" and "array_Set"
Allows storing mmodels as json or other formats based on their file extensions.

The aim is to standarize different ways in which arrays can be stored and fetched,
in order to make it easier to switch models from simple text files, json files, encoded arrays or databases.
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
   put array_FromFile (modelArrayFile) into modelArray
   return modelArray
end array_Data

setprop array_Data [modelNameItems] modelArray
   put the model_ArrayFile [modelNameItems] of the target into modelArrayFile
   array_ToFile modelArrayFile, modelArray
   return modelArrayFile
end array_Data

function array_FromFile sFile, pUseMerge
   put url ("binfile:" & sFile) into someData
   if someData is empty then return empty
   
   # Switch depending on file type
   set the itemdelimiter to "."
   switch item -1 of sFile
      case "json"
         -- put jsonImport (someData) into modelArray
         put json_ToArray (someData, pUseMerge) into modelArray
         return modelArray
      case "array"
         put arraydecode (someData) into modelArray
         return modelArray
      default
         return someData
   end switch
end array_FromFile

command array_ToFile someFile, modelArray, pUseMerge, pPretty, pForceRootType
   if modelArray is not an array then
      delete file someFile
      return "deleted" && someFile
   end if
   
   # Switch depending on file type
   set the itemdelimiter to "."
   switch item -1 of someFile
      case "json"
         -- put jsonExport (modelArray) into encodedData
         put json_FromArray (modelArray, pForceRootType, pPretty, pUseMerge) into encodedData
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
end array_ToFile

function array_Get someFile
   put url ("binfile:" & someFile) into encodedDataArray
   if encodedDataArray is empty then return empty
   put arraydecode (encodedDataArray) into modelArray
   return modelArray
end array_Get

command array_Set someFile, modelArray
   if keys(modelArray) is empty then
      delete file someFile
   else
      set the itemdelimiter to "/"
      put item 1 to -2 of someFile into someFolder
      folder_CreateNested someFolder
      put arrayencode (modelArray) into url ("binfile:" & someFile)
   end if
end array_Set


--> Private
-
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


--> Deps
-
function env_GetLcwFolder
   if exists (stack "LCW") is false then
      put the filename of me into sPath
      return env_FolderFromPath (sPath)
   else
      get the filename of stack "LCW"
      set the itemdelimiter to slash
      put item 1 to -2 of it & slash into lcwFolder
      return lcwFolder
   end if
end env_GetLcwFolder

function env_FolderFromPath sPath
   -- works for any stack within the LiveCodeWorld repo
   constant RootName = "LivecodeWorld"
   
   set the itemdelimiter to slash
   put itemOffset (RootName, sPath) into itemNum
   if itemNum = 0 then return empty
   put item 1 to itemNum of sPath & slash into envFolder
   return envFolder
end env_FolderFromPath

function json_FromArray pArray, pForceRootType, pPretty, pUseMerge
   if pArray is not an array then
      return false
   else if pUseMerge is false then -- not the same
      put jsonExport (pArray) into someJSON -- not the same
      return someJSON
   end if
   
   repeat for each key tKey in pArray
      if pArray[tKey] is an array then
         put "}"&json_FromArray(pArray[tKey]) into pArray[tKey]
      end if
   end repeat
   return (mergJSONEncode("pArray",pForceRootType,pPretty))
end json_FromArray

function json_ToArray pJSON, pUseMerge
   local tArray,tKeys
   if pJSON is empty then
      return false
   else if pUseMerge is false then -- not the same
      put jsonImport (pJSON) into tArray
      return tArray
   end if
   
   try -- as otherwise an error with non-json causes script to exit
      if pJSON is empty then return empty
      repeat for each line tKey in mergJSONDecode(pJSON,"tArray")
         put json_ToArray(tArray[tKey]) into tArray[tKey]
      end repeat
      return tArray
   catch e
      return empty
   end try
end json_ToArray

function folder_AddShort projectFolder, shortFolder
   text_AddPath projectFolder, shortFolder, slash
   return projectFolder
end folder_AddShort

command text_AddPath @sText, pPathItem, pDelim
   -- used by "folder_AddShort" to add
   if pPathItem is empty then return false
   if sText is empty then return false -- return pDelim ?
   --
   if pDelim is empty then put slash into pDelim --lazy default
   
   if char -1 of sText is not pDelim then
      put pDelim after sText
   end if
   put pPathItem & pDelim after sText
end text_AddPath

command text_AddTrailing @someText, someChar
   if char -1 of someText is not someChar then
      put someChar after someText
   end if
end text_AddTrailing
