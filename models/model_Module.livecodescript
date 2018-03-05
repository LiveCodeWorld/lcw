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
getprop project_Menu
   put the project_Name of the target into stackName
   put module_ConstructGlobalMenuTitle (stackName, true) into gMenuTitle 
   return gMenuTitle
end project_menu

getprop view_GlobalMenuTitle
   put the view_Name of the target into viewName
   put menu_GlobalTitleFromViewName (viewName) into globalMenuTitle
   return globalMenuTitle
end view_GlobalMenuTitle


--> Module | Name | Utils
-
function module_FolderNameFromTitle gMenuTitle
   view_NormalizePiped gMenuTitle
   replace "|" with "_" in gMenuTitle
   return gMenuTitle
end module_FolderNameFromTitle

function view_FromModuleStackName moduleStackName
   replace "_" with "|" in moduleStackName
   return moduleStackName
end view_FromModuleStackName

function module_ConstructGlobalMenuTitle moduleStackName, pMakePretty
   replace "_" with "|" in moduleStackName
   menu_NormalizeTitle moduleStackName, pMakePretty
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


--> View and Menu Names
-
/*
A collection of handlers that deal with view and menu (default) names.
*/

command menu_NormalizeTitle @mTitle, pMakePretty
   set the itemdelimiter to "|"
   repeat for each item someItem in mTitle
      if pMakePretty is true then
         put empty into prettyItem
         repeat for each word someWord in someItem
            put toUpper (char 1 of someWord) into char 1 of someWord
            put someWord & space after prettyItem
         end repeat
         put char 1 to -2 of prettyItem into someText
      else
         put word 1 to -1 of someItem into someText
      end if
      put space & someText & space & "|" after normalizedMenuTitle
   end repeat
   delete char -2 to -1 of normalizedMenuTitle
   delete char 1 of normalizedMenuTitle
   put normalizedMenuTitle into mTitle
end menu_NormalizeTitle

command menu_NormalizeName @mTitle
   if word 1 of mTitle = "-->" then
      delete word 1 of mTitle
   end if
   view_NormalizePiped mTitle
   replace "|" with " | " in mTitle
end menu_NormalizeName

command view_NormalizeName @viewPath
   if viewPath is empty then return false
   view_NormalizePiped viewPath
   set the itemdelimiter to "|"
   if item 1 of viewPath is not "View" then put "View|" before viewPath
   return true
end view_NormalizeName

command view_NormalizePiped @viewPath, pMakePretty
   if viewPath is empty then return false
   put word 1 to -1 of viewPath into viewPath
   
   set the itemdelimiter to "|"
   repeat with itemNum = 1 to the number of items of viewPath
      put word 1 to -1 of item itemNum of viewPath into someItem
      if pMakePretty is true then
         repeat for each word someWord in someItem
            put toUpper (char 1 of someWord) into char 1 of someWord
            put someWord & space after prettyItem
         end repeat
         put char 1 to -2 of prettyItem into someItem
      end if
      put someItem into item itemNum of viewPath
   end repeat
   return true
end view_NormalizePiped

function menu_GlobalTitleFromViewName vName
   put "Global |" && menu_TitleFromViewName (vName) into globalMenuTitle
   return globalMenuTitle
end menu_GlobalTitleFromViewName

function menu_TitleFromViewName viewName, pLevelAbove, pMakePretty
   set the itemdelimiter to "|"
   delete item 1 of viewName
   if pLevelAbove is a number then delete item -1 to - pLevelAbove of viewName   
   menu_NormalizeTitle viewName, pMakePretty
   put viewName && "| Menu" after normalizedMenu
   return normalizedMenu
end menu_TitleFromViewName


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
   put the module_BehaviorPaths of the target into stackPaths
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      put the name of stack stackPath & CR after moduleBehaviors
   end repeat
   delete char -1 of moduleBehaviors
   return moduleBehaviors
end module_Behaviors

getprop module_BehaviorPaths
   put the module_Folder of the target into moduleFolder
   put moduleFolder & "behaviors/" into moduleBehaviorFolder
   put folder_ListStackPaths (moduleBehaviorFolder) into stackPaths
   return stackPaths
end module_BehaviorPaths

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
   put project_GetModuleFolder (moduleFolderName, projectName) into moduleFolder
   put project_ConstructHomeStackPath (moduleFolder) into moduleHomeStackPath
   return moduleHomeStackPath
end module_GetHomeStackPath

function project_GetModuleFolder moduleFolderName, projectName
   put library_FetchProjectFolder (projectName) into projectFolder
   put module_GetFolder (moduleFolderName, projectFolder) into moduleFolder
   return moduleFolder
end project_GetModuleFolder


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
