script "model_LCW"
--> MetaData
-
license: GPLv3
name: model_LCW
type: model
version: 0.2

/*
For storing arbitrary system wide named arrays.
*/


--> LCW | Model | List
-
function lcw_ListModelNames
   -- the short file names of files in the "model_Library" folder
   put "model_Library" into modelName
   put lcw_GetRootFolder() into projectFolder
   put model_ListNames (modelName, projectFolder) into shortFiles
   return shortFiles
end lcw_ListModelNames


--> LCW | Model
-
function lcw_FetchArray pShortFile
   set the itemdelimiter to "."
   if the number of items of pShortFile = 1 then put ".array" after pShortFile -- alows pretty short names
   
   -- put the model_Array [pShortFile] of stack "model_Library" into modelArray
   put lcw_GetRootFolder() into projectFolder
   put model_FetchArray ("model_Library", projectFolder, pShortFile) into modelArray
   return modelArray
end lcw_FetchArray

command lcw_StoreArray pShortFile, modelArray
   set the itemdelimiter to "."
   if the number of items of pShortFile = 1 then put ".array" after pShortFile -- alows pretty short names
   
   -- set the model_Array [pShortFile] of stack "model_Library" to modelArray
   put lcw_GetRootFolder() into projectFolder
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
   put lcw_GetRootFolder() into projectFolder
   put model_GetDataFolder ("model_Library", projectFolder) into libraryArrayFolder
   put pShortFile after libraryArrayFolder
   return libraryArrayFolder
end lcw_ArrayFolder

function lcw_GetRootFolder
   -- put env_GetRepoFolder() & "lcw/" into lcwGetRootFolder
   put lcw_HomeStackName() into lcwHomeStackName
   put the stack_Folder of stack lcwHomeStackName into lcwGetRootFolder
   return lcwGetRootFolder
end lcw_GetRootFolder
