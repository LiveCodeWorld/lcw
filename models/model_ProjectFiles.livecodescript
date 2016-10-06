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

--> Project | Props
-
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
   put project_ListControllerPaths (projectName) into controllerPaths
   put stack_PathsToNames (controllerPaths) into stackNames
   return stackNames
end project_ListControllerStackNames

function project_ListControllerPaths homeStackName
   put library_FetchProjectFolder (homeStackName) into projectFolder
   put project_ListPaths ("controllers", projectFolder) into controllerStackPaths
   return controllerStackPaths
end project_ListControllerPaths

function project_ListBehaviorStackNames pProjectNames  
   repeat for each line projectName in pProjectNames
      if exists (stack projectName) is false then next repeat
      put the project_StackNames ["behaviors"] of stack projectName & CR after bNames
   end repeat
   sort bNames
   put word 1 to -1 of bNames into bNames
   return bNames
end project_ListBehaviorStackNames

function project_ListBehaviorPaths homeStackName
   put library_FetchProjectFolder (homeStackName) into projectFolder
   put project_ListPaths ("behaviors", projectFolder) into controllerStackPaths
   return controllerStackPaths
end project_ListBehaviorPaths

function project_ListStackPaths homeStackName
   put library_FetchProjectFolder (homeStackName) into projectFolder
   put project_ListPaths ("stacks", projectFolder) into stackStackPaths
   return stackStackPaths
end project_ListStackPaths

function project_ListViewPaths projectName
   put library_FetchProjectFolder (projectName) into projectFolder
   put project_ListPaths ("views", projectFolder) into viewPaths
   return viewPaths
end project_ListViewPaths


--> Project | List | Custom
-
function project_ListModuleFolders projectName
   put library_FetchProjectFolder (projectName) into projectFolder
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
   put library_FetchProjectFolder (projectName) into projectFolder
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
   put library_FetchProjectFolder (projectName) into projectFolder  
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
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      put the name of stack stackPath & CR after usedStackObjects
   end repeat
   delete char -1 of usedStackObjects
   sort usedStackObjects
   return usedStackObjects
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

function project_GetHomeStackPath projectName
   put library_FetchProjectFolder (projectName) into projectFolder
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
