script "model_ModuleData"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_ModuleData
type: model
version: 0.1


--> Layout | Object | Model
-
getprop layout_ObjectData [nameOrID]
   if nameOrID is empty then
      
   end if
   --
   put _GetModelData (nameOrID) into modelArray
   return modelArray
end layout_ObjectData

private function _GetModelData modelName
   put the module_ModelFile [modelName] of the target into modelDataFile
   if modelDataFile is empty then return empty
   -- 
   put array_FetchModel (modelDataFile) into modelArray
   put modelName into modelArray ["modelName"]
   return modelArray
end _GetModelData


--> Module | Model
-
getprop module_Model [pModelName]
   put the view_ModelName [pModelName] of me into modelName
   -- 
   put _GetModelData (modelName) into modelArray
   return modelArray
end module_Model

setprop module_Model [pModelName] dataArray
   put the module_ModelFile [pModelName] of the target into mFile   
   if mFile is empty then return empty
   -- 
   array_SaveModel mFile, dataArray
   return mFile
end module_Model


--> Module | Model | Names
-
getprop view_ModelName [pModelName]
   if pModelName is empty then put the short name of the target into pModelName
   
   if char 1 to 5 of pModelName = "View|" then
      delete char 1 to 5 of pModelName
   end if
   return pModelName
end view_ModelName

getprop view_ModelShortFile [pModelName]
   put the view_ModelName [pModelName] of me into pModelName
   put model_ConstructShortFile (pModelName) into shortFile
   return shortFile
end view_ModelShortFile

getprop module_ModelFile [pModelName]
   put the view_ModelShortFile [pModelName] of the target into shortFile
   put the template_Object of the target into templateObject
   if exists (templateObject) is false then return empty
   --
   put the module_ModelFolder of templateObject into modelDataFolder
   put dataFolder_GetFile (modelDataFolder, shortFile) into mFile
   return mFile
end module_ModelFile

getprop module_ModelFolder
   put the module_Folder of the target into moduleFolder
   put folder_AddShort (moduleFolder, "models") into moduleModelFolder
   return moduleModelFolder
end module_ModelFolder

getprop module_ModelNames [listShortFiles]
   put the module_ModelFolder of the target into modelDataFolder
   put folder_ListShortFiles (modelDataFolder) into shortFiles
   if listShortFiles is not true then
      replace ".array" with empty in shortFiles
   end if
   return shortFiles
end module_ModelNames


--> View | Model | List
-
function module_ListModelNames moduleStackName, projectName
   put module_ListModelShortFiles (moduleStackName, projectName) into modelNames
   replace ".array" with empty in modelNames
   return modelNames
end module_ListModelNames

function module_ListModelShortFiles moduleStackName, projectName
   put module_ConstructModelFolder (moduleStackName, projectName) into moduleModelFolder
   put folder_ListShortFiles (moduleModelFolder) into shortFiles
   return shortFiles
end module_ListModelShortFiles


--> View | Model
-
function module_GetModel shortNameOrFile, moduleStackName, projectName
   put module_ConstructModelFile (shortNameOrFile, moduleStackName, projectName) into mFile
   if there is a file mFile then
      put array_FetchModel (mFile) into modelArray
      return modelArray
   else
      return empty
   end if
end module_GetModel

command module_SetModel shortNameOrFile, moduleStackName, projectName, modelArray
   put module_ConstructModelFile (shortNameOrFile, moduleStackName, projectName) into mFile
   array_SaveModel mFile, modelArray
   return mFile
end module_SetModel

on module_DuplicateModel shortNameOrFile, moduleStackName, projectName
   put module_ConstructModelFile (shortNameOrFile, moduleStackName, projectName) into fileToCopy
   put module_ConstructModelFolder (moduleStackName, projectName) into folderToCopyTo
   --
   revCopyFile fileToCopy, folderToCopyTo
   return the result
end module_DuplicateModel

command module_DeleteModel shortNameOrFile, moduleStackName, projectName
   put module_ConstructModelFile (shortNameOrFile, moduleStackName, projectName) into mFile
   revDeleteFile mFile
   return the result
end module_DeleteModel


--> View | Model | Files
-
function model_ConstructShortFile sName
   set the itemdelimiter to "."
   if the number of items of sName = 1 then
      return sName & ".array"
   else
      return sName
   end if
end model_ConstructShortFile

function module_ConstructModelFile shortNameOrFile, moduleStackName, projectName
   if shortNameOrFile contains "." then
      put shortNameOrFile into shortFile
   else
      put model_ConstructShortFile (shortNameOrFile) into shortFile
   end if
   put module_ConstructModelFolder (moduleStackName, projectName) into moduleModelFolder
   put dataFolder_GetFile (moduleModelFolder, shortFile) into mFile
   return mFile
end module_ConstructModelFile

function module_ConstructModelFolder moduleStackName, projectName
   put project_NameToShortFolder (moduleStackName) into shortModuleFolder
   put project_GetModuleFolder (shortModuleFolder, projectName) into moduleFolder
   put folder_AddShort (moduleFolder, "models") into moduleModelFolder
   return moduleModelFolder
end module_ConstructModelFolder


