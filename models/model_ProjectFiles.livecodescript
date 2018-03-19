script "model_ProjectFiles"
--> MetaData
-
license: GPLv3
nam: model_ProjectFiles
type: model
version: 0.6

/*
Project folders are the top-level LCW folders as stored in GitHub.

They no longer refer to project-metadata folders, which are now called textstack_Folders, or things like "data_Folder".
Those older names are a bit of a mess.
*/

--> Working on
-
function project_ListUsedDeps projectName
   -- not in order of use?
   put project_ListProjectDepNames (projectName) into depNames
   repeat for each line projectName in depNames
      put project_ListUsedStacks (projectName) & CR after usedStacks
   end repeat
   delete char -1 of usedStacks
   return usedStacks
end project_ListUsedDeps

function project_ListFrontDeps projectName
   -- not in order of use?
   put project_ListProjectDepNames (projectName) into depNames
   repeat for each line projectName in depNames
      put project_ListFrontScripts (projectName) & CR after objectIndex
   end repeat
   delete char -1 of objectIndex
   return objectIndex
end project_ListFrontDeps

function project_ListBackDeps projectName
   -- not in order of use?
   put project_ListProjectDepNames (projectName) into depNames
   repeat for each line projectName in depNames
      put project_ListBackScripts (projectName) & CR after objectIndex
   end repeat
   delete char -1 of objectIndex
   return objectIndex
end project_ListBackDeps


--> Project | Props
-
function project_ListProjectDepNames projectName
   -- lazy: does not return things in the right order
   local projectNameArray
   _addProjectToDeps projectName, projectNameArray
   put keys (projectNameArray) into projectNameIndex
   return word 1 to -1 of projectNameIndex
end project_ListProjectDepNames

getprop project_Folders [pIncludeInvisible]
   put the project_Folder of the target into projectFolder
   put folder_ListLong (projectFolder) into standardFolders
   return standardFolders
end project_Folders

getprop project_ArrayFile
   put the project_Folder of the target into projectFolder
   put projectFolder & "lcw_project.array" into projectArrayFile
   return projectArrayFile
end project_ArrayFile

getprop project_StackNames [folderName]
   if folderName is empty then
      put the project_Name of the target into projectName
      put the stackfile_Names of stack projectName into projectStackNames
   else
      put the project_Folder [folderName] of the target into standardFolder
      if standardFolder is empty then return empty
      put folder_ListStackNames (standardFolder) into projectStackNames
   end if
   return projectStackNames
end project_StackNames

getprop project_StackObjects [folderName]
   if folderName is empty then
      put the project_Name of the target into projectName
      put the stackfile_Names of stack projectName into projectStackNames
      repeat for each line stackName in projectStackNames
         if exists (stack stackName) is false then next repeat
         put the name of stack stackName & CR after stackObjects
      end repeat
      delete char -1 of stackObjects
      return stackObjects
   else
      put the project_Folder [folderName] of the target into standardFolder
      if standardFolder is empty then return empty
      put folder_ListStackObjects (standardFolder) into stackObjects
   end if
   return stackObjects
end project_StackObjects

getprop project_StackFileTable
   put the project_HomeStack of the target into projectHomeStack
   put the stackfiles of projectHomeStack into stackFileTable
   return stackFileTable
end project_StackFileTable

setprop project_StackFileTable stackFileTable
   put the project_HomeStack of the target into projectHomeStack
   set the stackfiles of projectHomeStack to stackFileTable
   return projectHomeStack
end project_StackFileTable

getprop project_Paths [shortFolder]
   put the project_Name of the target into projectName
   put project_ListSubfolderPaths (shortFolder, projectName) into filePaths
   return filePaths
end project_Paths


--> Project | List | Paths
-
/*
Here we try to sue standard names and be as fast and simple as possible.

-- put library_FetchProjectFolder (projectName) into projectFolder
-- put the stack_Folder of stack projectName into projectFolder
-- put project_ListPaths ("controllers", projectFolder) into controllerStackPaths
*/

function project_ListLibraryPaths projectName
   put project_ListSubfolderPaths ("libraries", projectName) into filePaths
   return filePaths
end project_ListLibraryPaths

function project_ListControllerPaths projectName
   put project_ListSubfolderPaths ("controllers", projectName) into filePaths
   return filePaths
end project_ListControllerPaths

function project_ListModelPaths projectName
   put project_ListSubfolderPaths ("models", projectName) into filePaths
   return filePaths
end project_ListModelPaths

function project_ListBehaviorPaths projectName
   put project_ListSubfolderPaths ("behaviors", projectName) into filePaths
   return filePaths
end project_ListBehaviorPaths

function project_ListViewPaths projectName
   put project_ListSubfolderPaths ("views", projectName) into filePaths
   return filePaths
end project_ListViewPaths

function project_ListModulePaths projectName
   put project_FolderFromName ("modules", projectName) into standardFolder
   put folder_ListLong (standardFolder) into longFolders
   return longFolders
end project_ListModulePaths
   

--> Project | List
-
/*
Tries to be as fast and minimal as possible.
*/

function project_ListSubfolderPaths shortFolder, projectName
   put project_FolderFromName (shortFolder, projectName) into standardFolder
   put path_ListLong (standardFolder, pShowInvisible) into filePaths
   return filePaths
end project_ListSubfolderPaths

function project_ListStackNames shortFolder, projectName
   put project_ListStackPaths (shortFolder, projectName) into longFiles
   repeat for each line longFile in longFiles
      if exists (stack longFile) is false then next repeat
      put the short name of stack longFile into stackName
      put stackName & CR after stackNames
   end repeat
   delete char -1 of stackNames
   return longFiles
end project_ListStackNames

function project_ListShortFiles shortFolder, projectName
   put the stack_Folder of stack projectName into standardFolder
   put file_ListShort (standardFolder) into shortFiles
   return shortFiles
end project_ListShortFiles


--> Project | Start
-
command project_StartUsed projectName
   put project_ListUsedStackPaths (projectName) into stackPaths
   stack_StartUsedPaths stackPaths
end project_StartUsed


--> Project | List | Standard
-
function project_ListStandardScriptOnlyFiles
   put project_ListStandardFiles() into longFiles
   filter longFiles with "*.livecodescript"
   return longFiles
end project_ListStandardScriptOnlyFiles

function project_ListStandardFiles pImportantPaths
   put "models,views,controllers,libraries,behaviors,stacks" into folderNames
   repeat for each item folderName in folderNames
      put lcw_ListStackPaths (folderName) & CR after longFiles
   end repeat
   delete char -1 of longFiles
   
   if pImportantPaths is not empty then
      put pImportantPaths & CR before longFiles
   end if
   sort longFiles
   return word 1 to -1 of longFiles
end project_ListStandardFiles


--> Project | List
-
/*
These functions return the paths to stacks in standard toplevel project folders.
They should work for modules as well as projects as they have the same structure.
*/

function project_ListControllerStackNames projectName
   -- put project_ListControllerPaths (projectName) into controllerPaths
   put project_ListPaths ("controllers", projectFolder) into controllerPaths
   put stack_PathsToNames (controllerPaths) into stackNames
   return stackNames
end project_ListControllerStackNames

function project_ListBehaviorStackNames pProjectNames  
   repeat for each line projectName in pProjectNames
      if exists (stack projectName) is false then next repeat
      put the project_StackNames ["behaviors"] of stack projectName & CR after bNames
   end repeat
   sort bNames
   put word 1 to -1 of bNames into bNames
   return bNames
end project_ListBehaviorStackNames

function project_ListBehaviorPaths projectName
   -- put library_FetchProjectFolder (projectName) into projectFolder
   put the stack_Folder of stack projectName into projectFolder
   put project_ListPaths ("behaviors", projectFolder) into controllerStackPaths
   return controllerStackPaths
end project_ListBehaviorPaths

function project_ListStackPaths projectName
   -- put library_FetchProjectFolder (projectName) into projectFolder
   put the stack_Folder of stack projectName into projectFolder
   put project_ListPaths ("stacks", projectFolder) into stackStackPaths
   return stackStackPaths
end project_ListStackPaths

function project_ListViewPaths projectName
   -- put library_FetchProjectFolder (projectName) into projectFolder
   put the stack_Folder of stack projectName into projectFolder
   put project_ListPaths ("views", projectFolder) into viewPaths
   return viewPaths
end project_ListViewPaths

function project_ListFrontScripts projectName
   put project_ListFrontScriptPaths (projectName) into stackPaths
   return stack_PathsToObjects (stackPaths)
end project_ListFrontScripts

function project_ListFrontScriptPaths projectName
   -- put library_FetchProjectFolder (projectName) into projectFolder
   put the stack_Folder of stack projectName into projectFolder
   put project_ListPaths ("frontscripts", projectFolder) into viewPaths
   return viewPaths
end project_ListFrontScriptPaths

function project_ListBackScripts projectName
   put project_ListBackScriptPaths (projectName) into stackPaths
   return stack_PathsToObjects (stackPaths)
end project_ListBackScripts

function project_ListBackScriptPaths projectName
   -- put library_FetchProjectFolder (projectName) into projectFolder
   put the stack_Folder of stack projectName into projectFolder
   put project_ListPaths ("backscripts", projectFolder) into viewPaths
   return viewPaths
end project_ListBackScriptPaths


--> Project | List | Custom
-
function project_ListModuleFolders projectName
   -- put library_FetchProjectFolder (projectName) into projectFolder
   put the stack_Folder of stack projectName into projectFolder
   put project_ConstructFolder ("modules", projectFolder) into rootModuleFolder
   put folder_ListLong (rootModuleFolder) into moduleFolders
   return moduleFolders
end project_ListModuleFolders

function project_ListViewStackNames projectName
   put project_ListViewPaths (projectName) into viewPaths
   put stack_PathsToNames (viewPaths) into stackNames
   -- filter stackNames without "behavior_*"
   -- filter stackNames with "View|*"
   return stackNames
end project_ListViewStackNames

function project_GetViewStackArray projectName
   -- put library_FetchProjectFolder (projectName) into projectFolder
   put the stack_Folder of stack projectName into projectFolder
   put project_ListPaths ("views", projectFolder) into viewPaths
   put stack_PathsToNames (viewPaths) into stackNames
   repeat for each line stackName in stackNames
      put the object_MetaData ["type"] of stack stackName into objectType
      switch
         -- case 
      end switch
   end repeat
   
   -- filter stackNames without "behavior_*"
   filter stackNames with "View|*"
   return stackNames
end project_GetViewStackArray

function project_ListUsedStackPaths projectName
   -- put library_FetchProjectFolder (projectName) into projectFolder  
   put the stack_Folder of stack projectName into projectFolder
   put project_ListUsedPathsFromFolder (projectFolder) into projectUsedStackPaths
   return projectUsedStackPaths
end project_ListUsedStackPaths

function project_ListUsedStackNames projectName
   put project_ListUsedStackPaths (projectName) into stackPaths
   put stack_ConvertPathsToNames (stackPaths) into stackNames
   return stackNames
end project_ListUsedStackNames

function project_ListUsedStacks projectName
   put project_ListUsedStackPaths (projectName) into stackPaths
   return stack_PathsToObjects (stackPaths)
end project_ListUsedStacks


--> Project | Files
-
/*
Here is a list of naming conventions we use for projects:

A project has a home stack.
The home stack is often a script only stack, but this is not required.
The short name of the homestack is the name of the project.
The short file of the homestack is the name of the project followed by ".livecode" (eg "lcw.livecode").
We use the ".livecode" regardless of whether the stack is a script only stack to make it easier to derive the path from the project name and therfore locate.
The short file of the homestack is in lower case (eg "lcw.livecode" not "LCW.livecode")
*/

function project_GetHomeView projectName
   if exists (stack projectName) is false then
      put project_GetHomeStackPath (projectName) into homeStackPath
      put homeStackPath into projectName
   end if
   if exists (control 1 of stack projectName) is false then return empty
   
   put the long id of control 1 of stack projectName into projectHomeView
   return projectHomeView
end project_GetHomeView

function project_GetHomeStackPath projectName
   if exists (stack projectName) is false then
      return empty
   end if
   
   put the stack_Folder of stack projectName into projectFolder
   if projectFolder is empty then return empty
   put project_ConstructHomeStackPath (projectFolder) into homeStackPath
   if exists (stack homeStackPath) is false then return empty
   return homeStackPath
end project_GetHomeStackPath

function project_FolderFromFile objectFile
   put library_ListProjectFolders() into projectFolders
   repeat for each line projectFolder in projectFolders
      if objectFile begins with projectFolder then
         return projectFolder
      end if
   end repeat
   return empty
end project_FolderFromFile


--> Private
-
private command _addProjectToDeps projectName, @projectNameArray
   -- recursive
   if projectName is among the keys of projectNameArray then return false
   
   put empty into projectNameArray [projectName]
   
   put the project_Deps of stack projectName into projectDepItems
   repeat for each item projectDepName in projectDepItems
      if projectDepName is among the keys of projectNameArray then next repeat
      
      _addProjectToDeps projectDepName, projectNameArray
   end repeat
   return true
end _addProjectToDeps


--> Deps
-
function stack_ListUsed pProjectName
   -- should add functionalty for pProjectName (used by the script_Hierarchy [pProjectName])
   put the stacksinuse into usedStackNames
   put stack_PathsToObjects (usedStackNames) into stackObjects
   return stackObjects
end stack_ListUsed

function stack_PathsToNames stackNameOrPaths
   repeat for each line stackName in stackNameOrPaths
      if exists (stack stackName) is false then next repeat
      put the short name of stack stackName & CR after stackNames
   end repeat
   delete char -1 of stackNames
   return stackNames
end stack_PathsToNames

function stack_PathsToObjects stackNameOrPaths
   repeat for each line stackName in stackNameOrPaths
      if exists (stack stackName) is false then next repeat
      put the name of stack stackName & CR after stackObjects
   end repeat
   delete char -1 of stackObjects
   return stackObjects
end stack_PathsToObjects
