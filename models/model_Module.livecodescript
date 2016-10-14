script "model_Module"
--> MetaData
-
license: GPLv3
name: model_Module
type: models
version: 0.2

/*
See basic module handlers in LCW

These hacks convert (view) module names to folder names.
This is not consistant yet?
*/

--> Working on
-

--> Module | Name | Utils
-
command menu_NormalizeName @mTitle
   if word 1 of mTitle = "-->" then
      delete word 1 of mTitle
   end if
   view_NormalizePiped mTitle
   replace "|" with " | " in mTitle
end menu_NormalizeName

function module_FolderNameFromTitle gMenuTitle
   view_NormalizePiped gMenuTitle
   replace "|" with "_" in gMenuTitle
   return gMenuTitle
end module_FolderNameFromTitle

function module_ConstructGlobalMenuTitle moduleStackName
   -- put menu_GlobalTitleFromViewName (viewName) into mTitle
   replace "_" with "|" in moduleStackName
   menu_NormalizeTitle moduleStackName
   set the itemdelimiter to " | "
   if item 1 of moduleStackName is not "Global" then put "Global | " before moduleStackName
   if item 2 of moduleStackName = "View" then delete item 2 of moduleStackName
   if item -1 of moduleStackName is not "Menu" then put " | Menu" after moduleStackName
   return moduleStackName
end module_ConstructGlobalMenuTitle

function module_ViewNameToShortFolder moduleName
   replace "|" with "_" in moduleName -- hack
   return moduleName
end module_ViewNameToShortFolder


--> Module | Props
-
getprop module_Array
   put the module_Folder of the target into moduleFolder
   if moduleFolder is empty then return empty
   
   set the itemdelimiter to slash
   put item -1 of moduleFolder into moduleArray ["moduleFolderName"]
   if item -2 of moduleFolder is not "modules" then return empty
   put item -3 of moduleFolder into moduleArray ["projectName"]
   
   put project_ConstructHomeStackPath (moduleFolder) into moduleHomeStackPath
   if exists (stack moduleHomeStackPath) is false then return empty
   put moduleHomeStackPath into moduleArray ["moduleHomeStackPath"]
   
   if exists (control 1 of cd 1 of stack moduleHomeStackPath) is false then return empty
   put the long id of control 1 of cd 1 of stack moduleHomeStackPath into viewObject
   put revRuggedID (viewObject) into moduleArray ["viewObject"]
   
   put the view_Name of viewObject into viewName
   if viewName is empty then return empty
   put viewName into moduleArray ["viewName"]
   
   put moduleFolder & "behaviors/" into moduleBehaviorFolder
   put folder_ListStackPaths (moduleBehaviorFolder) into moduleArray ["moduleBehaviorPaths"]
   put moduleBehaviorFolder into moduleArray ["moduleBehaviorFolder"]
   
   put moduleFolder & "controllers/" into moduleControllerFolder
   put folder_ListStackPaths (moduleControllerFolder) into moduleArray ["moduleControllerPaths"]
   put moduleControllerFolder into moduleArray ["moduleControllerFolder"]
   
   return moduleArray
end module_Array

getprop module_Name
   put the module_Folder of the target into moduleFolder
   set the itemdelimiter to slash
   put item -1 of moduleFolder into moduleName
   return moduleName
end module_Name

getprop module_HomeStack [moduleName]
   put the module_HomeStackPath [moduleName] of the target into moduleHomeStackPath
   if exists (stack moduleHomeStackPath) is false then return empty
   put the name of stack moduleHomeStackPath into stackObject
   return stackObject
end module_HomeStack

getprop module_View [moduleName]
   put the module_HomeStackPath [moduleName] of the target into moduleHomeStackPath
   -- put the template_Object of stack moduleHomeStackPath into moduleView
   if exists (control 1 of cd 1 of stack moduleHomeStackPath) is false then return empty
   put the long id of control 1 of cd 1 of stack moduleHomeStackPath into moduleView
   return moduleView
end module_View

getprop module_ViewName [moduleName]
   put the module_View [moduleName] of the target into moduleView
   if exists (moduleView) is false then return empty
   put the view_Name of moduleView into viewName
   return viewName
end module_ViewName

getprop module_Behaviors
   put the module_Folder of the target into moduleFolder
   put moduleFolder & "behaviors/" into moduleBehaviorFolder
   put folder_ListStackPaths (moduleBehaviorFolder) into stackPaths
   
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      put the name of stack stackPath & CR after moduleBehaviors
   end repeat
   delete char -1 of moduleBehaviors
   return moduleBehaviors
end module_Behaviors

getprop module_Controllers
   put the module_Folder of the target into moduleFolder
   put moduleFolder & "controllers/" into moduleControllerFolder
   put folder_ListStackPaths (moduleControllerFolder) into stackPaths
   
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      put the name of stack stackPath & CR after moduleControllers
   end repeat
   delete char -1 of moduleControllers
   return moduleControllers
end module_Controllers


--> Module
-
function module_GetHomeStackPath moduleFolderName, projectName
   put library_FetchProjectFolder (projectName) into projectFolder
   put module_GetFolder (moduleFolderName, projectFolder) into moduleFolder
   put project_ConstructHomeStackPath (moduleFolder) into moduleHomeStackPath
   return moduleHomeStackPath
end module_GetHomeStackPath


--> Module | List
-
function project_ListModules projectName
   put library_FetchProjectFolder (projectName) into projectFolder  
   put project_GetFolder (projectName, "modules") into modulesFolder
   put folder_ListShort (modulesFolder) into moduleNames
   return moduleNames
end project_ListModules

function project_ListModuleHomeStackNames projectName
   put library_FetchProjectFolder (projectName) into projectFolder
   put project_ListModuleFolders (projectName) into moduleFolders
   repeat for each line moduleFolder in moduleFolders
      put project_ConstructHomeStackPath (moduleFolder) into moduleHomeStackPath
      if exists (stack moduleHomeStackPath) is false then next repeat
      
      put the short name of stack moduleHomeStackPath into stackName
      put stackName & CR after moduleStackNames
   end repeat
   delete char -1 of moduleStackNames
   return moduleStackNames
end project_ListModuleHomeStackNames

function project_ListModuleFolders projectName
   put library_FetchProjectFolder (projectName) into projectFolder  
   put project_GetFolder (projectName, "modules") into modulesFolder
   put folder_ListLong (modulesFolder) into moduleFolders
   return moduleFolders
end project_ListModuleFolders


--> Module
-
function module_ListBehaviorStackNames moduleName, projectFolder
   put module_ListBehaviorStackPaths (moduleName, projectFolder) into stackPaths
   put stack_PathsToNames (stackPaths) into stackNames
   return stackNames
end module_ListBehaviorStackNames

function module_ListBehaviorStackPaths moduleName, projectFolder
   put module_GetBehaviorFolder (moduleName, projectFolder) into moduleBehaviorFolder
   put folder_ListStackPaths (moduleBehaviorFolder) into stackPaths
   return stackPaths
end module_ListBehaviorStackPaths

function module_ListControllerStackNames moduleName, projectFolder
   put module_ListControllerStackPaths (moduleName, projectFolder) into stackPaths
   put stack_PathsToNames (stackPaths) into stackNames
   return stackNames
end module_ListControllerStackNames

function module_ListControllerStackPaths moduleName, projectFolder
   put module_GetControllerFolder (moduleName, projectFolder) into moduleControllerFolder
   put folder_ListStackPaths (moduleControllerFolder) into stackPaths
   return stackPaths
end module_ListControllerStackPaths


--> Module | Files
-
function module_GetControllerFolder moduleName, projectFolder
   put project_NameToShortFolder (moduleName) into moduleFolderName
   put module_GetFolder (moduleFolderName, projectFolder) into moduleFolder
   put project_ConstructFolder ("controllers", moduleFolder) into moduleControllerFolder
   return moduleControllerFolder
end module_GetControllerFolder

function module_GetBehaviorFolder moduleName, projectFolder
   put project_NameToShortFolder (moduleName) into moduleFolderName
   put module_GetFolder (moduleFolderName, projectFolder) into moduleFolder
   put project_ConstructFolder ("behaviors", moduleFolder) into moduleBehaviorFolder
   return moduleBehaviorFolder
end module_GetBehaviorFolder


--> Private
-
private function _ProjectStackExists stackPath
   if exists (stack stackPath) is false then return false
   
   put stackPath
   put the short name of stack stackPath into stackName
   answer warning merge ("A stack with the same name as '[[stackName]]' already exists!")
   go to stack stackPath
   show stack stackPath
   edit the script of stack stackPath
   return true
end _ProjectStackExists
