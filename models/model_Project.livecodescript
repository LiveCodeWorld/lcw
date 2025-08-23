script "model_Project"
--> MetaData
-
license: GPLv3
name: model_Project
type: model
version: 0.8

/*

*/


--> Working on
-

--> Env
-
getprop env_PathArray
   -- path relative to the LCW Environment Root
   put the dep_StackNames of the target into sNames
   replace comma with CR in sNames
   repeat for each line sName in sNames
      get the env_RelativeFile of stack sName
      put it into dArray [sName]
   end repeat
   return dArray
end env_PathArray


--> Props
-
getprop project_Array
   put the project_Name of the target into projectName
   put project_GetArray (projectName) into projectArray
   return projectArray
   
   put the project_Folder of the target into pFolder
   put project_GetArrayFromFolder (pFolder) into projectArray
   
   put the project_JsonFile of the target into projectArrayFile
   put array_FromFile (sFile) into projectArray
   return projectArray
end project_Array

setprop project_Array projectArray
   put the project_JsonFile of the target into projectArrayFile
   array_ToFile projectArrayFile, projectArray
   return modelDataFile
end project_Array

getprop project_ModuleFolder [pModuleName]
   put the template_Object of the target into tObject
   if exists (tObject) is true then
      -- we are asking about a view
      put the stack_Object of tObject into stackObject
   else
      put the stack_Object of the target into stackObject
   end if
   put the effective filename of stackObject into stackPath
   if stackPath is empty then return empty
   
   ## Find
   put module_FindFolder (stackPath) into maybeModuleFolder
   --
   set the itemdelimiter to slash
   put item -2 of maybeModuleFolder into testPathItem
   switch
      case maybeModuleFolder is empty
         return empty
      case pModuleName is not empty
         put module_GetFolder (pModuleName, maybeModuleFolder) into moduleFolder
         return moduleFolder
      case testPathItem = "modules"
         return maybeModuleFolder
      default
         return empty
   end switch
end project_ModuleFolder

getprop project_UsedStackNames
   local stackNames
   put the project_Name of the target into projectName
   put project_ListUsedStackNames (projectName) after stackNames
   
   if projectName = "LCW" then
      -- here we add the root "LCW" stack
      -- it may be better not to use the home stacks and instead have minmal scripts there.
      put "LCW" & CR & stackNames into usedStackNames
      return word 1 to -1 of usedStackNames
   else
      return stackNames
   end if
end project_UsedStackNames

getprop project_Name
   -- assume folder name = project name
   set the itemdelimiter to slash
   put the project_Folder of the target into projectFolder
   return item -1 of projectFolder
end project_Name

getprop project_Folder
   -- latest simplest version based on naming conventions and folder structure
   -- does not allow projects outside of the LCW reop folder  
   
   put the effective filename of the defaultstack into stackPath
   if stackPath is empty then return empty
   put project_FolderFromPath (stackPath) into projectFolder
   return projectFolder
end project_Folder

getprop project_IsActive
   put the project_Name of the target into projectName
   put env_ProjectIsActive (projectName) into someBoolean
   return someBoolean
end project_IsActive

getprop project_HomeStack
   -- searches the disk based file hierearchy to find the project root
   put the stack_Object of the target into stackObject
   put the effective filename of stackObject into stackPath
   
   put project_FindHomeStackPath (stackPath) into projectStackPath
   if projectStackPath is empty then return empty
   
   put the name of stack projectStackPath into stackObject
   return stackObject 
end project_HomeStack

getprop project_UsedStackPaths
   local stackNames
   put the project_Name of the target into projectName
   put project_ListUsedStackPaths (projectName) after stackPaths
   
   if projectName = "LCW" then
      put the filename of stack projectName & CR & stackPaths into usedStackPaths
      return word 1 to -1 of usedStackPaths
   else
      return stackPaths
   end if
end project_UsedStackPaths

getprop project_DependencyArray
   put the project_Name of the target into projectName
   put env_GetRepoFolder() into repoFolder
   --
   put env_ConstructProjectDepArray (projectName, repoFolder) into projectDepArray
   return projectDepArray
end project_DependencyArray

getprop project_HomeStackBrowser
   put the project_Name of the target into pHomeStackName
   put project_GetHomeStackBrowser (pHomeStackName) into browserWidget
   return browserWidget
end project_HomeStackBrowser


--> Project | Files
-
function project_FolderFromPath stackPath
   set the itemdelimiter to slash
   put env_GetRepoFolder() into repoFolder
   put the number of items of repoFolder + 1 into itemNum
   put item 1 to itemNum of stackPath & slash into projectFolder
   --
   return projectFolder
end project_FolderFromPath


--> Project | Array | Model
-
function project_GetArray projectName
   if exists (stack projectName) is false then return empty
   put the project_Folder of stack projectName into projectFolder
   --
   put project_GetArrayFromFolder (projectFolder) into projectArray
   return projectArray
end project_GetArray

function project_GetArrayFromFolder projectFolder
   put project_ConstructJsonFile (projectFolder) into projectJsonFile
   put array_FromFile (projectJsonFile) into projectArray
   return projectArray
end project_GetArrayFromFolder

command project_StoreArray projectFolder, projectArray
   put project_ConstructJsonFile (projectFolder) into projectJsonFile
   array_ToFile projectJsonFile, projectArray
   return projectJsonFile
end project_StoreArray

command project_DeleteArray projectName
   put project_JsonFile (projectName) into someFile
   delete file someFile
   return someFile
end project_DeleteArray


--> Project | Files | Convert
/*
These are generic stack functions?
*/

function project_ConvertStackNamesToShortFiles stackNames
   set the itemdelimiter to slash
   repeat for each line stackName in stackNames
      put the filename of stack stackName into longFile
      put item -1 of longFile into shortFile
      put shortFile & CR after shortFiles
   end repeat
   return shortFiles
end project_ConvertStackNamesToShortFiles

function project_ConvertStackObjectsToShortFiles stackObjects
   set the itemdelimiter to slash
   repeat for each line stackObject in stackObjects
      if exists (stackObject) is false then next repeat
      
      put the filename of stackObject into longFile
      put item -1 of longFile into shortFile
      put shortFile & CR after shortFiles
   end repeat
   return shortFiles
end project_ConvertStackObjectsToShortFiles

function project_ConvertShortFilesToStackObjects shortFiles, someFolder
   local goodStackObjects, badStackFiles
   project_ConvertShortFilesToStackObjects shortFiles, someFolder, goodStackObjects, badStackFiles
   return goodStackObjects
end project_ConvertShortFilesToStackObjects

command project_ConvertShortFilesToStackObjects shortFiles, someFolder, @goodStackObjects, @badStackFiles
   repeat for each line shortFile in shortFiles
      put someFolder & shortFile into longStackFile
      if there is not a file longStackFile then
         put longStackFile & CR after badStackFiles
         next repeat
      end if
      put the name of stack longStackFile & CR after goodStackObjects
   end repeat
   delete char -1 of badStackFiles
   delete char -1 of goodStackObjects
end project_ConvertShortFilesToStackObjects


--> Project | Array | Model
-
function project_FetchValue someKey, projectName
   -- put library_FetchProjectFolder (projectName) into projectFolder
   put the stack_Folder of stack projectName into projectFolder
   put project_GetArrayFromFolder (projectFolder) into projectArray
   put projectArray [someKey] into someValue
   return someValue
end project_FetchValue

command project_SaveValue someKey, someValue, projectName
   -- put library_FetchProjectFolder (projectName) into projectFolder
   put the stack_Folder of stack projectName into projectFolder
   put project_GetArrayFromFolder (projectFolder) into projectArray
   put someValue into projectArray [someKey]
   project_StoreArray projectFolder, projectArray
   return projectArray
end project_SaveValue

command project_DeleteValue someKey, projectName
   -- put library_FetchProjectFolder (projectName) into projectFolder
   put the stack_Folder of stack projectName into projectFolder
   put project_GetArrayFromFolder (projectFolder) into projectArray
   delete variable projectArray [someKey]
   project_StoreArray projectFolder, projectArray
   return projectArray
end project_DeleteValue


--> Project | Set Array
-
function project_CurrentFrontScripts
   -- a lot of IDE backscripts are returned
   -- filter them out
   put the frontscripts into someObjects
   filter someObjects without "*/Contents/Tools/Toolset/libraries/rev*"
   filter someObjects without "*/Contents/Tools/Toolset/palettes/rev*"
   return someObjects
end project_CurrentFrontScripts

function project_CurrentBackScripts
   -- a lot of IDE backscripts are returned
   -- filter them out
   put the backscripts into someObjects
   filter someObjects without "*/Contents/Tools/Toolset/libraries/rev*"
   filter someObjects without "*/Contents/Tools/Toolset/palettes/rev*"
   return someObjects
end project_CurrentBackScripts


--> Project | Delete
-
command project_CloseAndDelete projectName, pRepoFolder
   project_CloseOpenStacks projectName
   put the result into closedStackNames
   
   put env_ConstructProjectFolder (projectName, pRepoFolder) into projectFolder
   revDeleteFolder projectFolder
   
   library_DeleteProjectArray projectName
   return closedStackNames
end project_CloseAndDelete

command project_CloseOpenStacks projectName
   put project_ListOpenStackNames (projectName) into stackNames
   repeat for each line stackName in stackNames
      save stack stackName
      delete stack stackName
   end repeat
   return stackNames
end project_CloseOpenStacks

function project_ListOpenStackNames projectName, pRepoFolder
   -- also works with modules
   put env_ConstructProjectFolder (projectName, pRepoFolder) into projectFolder
   --
   put project_ListAllStackPaths (projectFolder) into projectStackPaths
   put revLoadedStacks ("application") into loadedStackNames
   repeat for each line stackPath in projectStackPaths
      if there is a stack stackPath then
         put the short name of stack stackPath into shortName
         if shortName is among the lines of loadedStackNames then
            put shortName & CR after stackNames
         end if
      end if
   end repeat
   delete char -1 of stackNames
   return stackNames
end project_ListOpenStackNames
