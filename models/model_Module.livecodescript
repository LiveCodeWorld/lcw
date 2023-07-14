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

-- getprop module_Array
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
*/


--> Working on
-


--> Module | Name | Utils
-
function module_ConstructGlobalMenuTitle moduleStackName, pMakePretty
   replace "_" with "|" in moduleStackName
   menu_NormalizeTitle moduleStackName, pMakePretty
   set the itemdelimiter to " | "
   if item 1 of moduleStackName is not "Global" then put "Global | " before moduleStackName
   if item 2 of moduleStackName = "View" then delete item 2 of moduleStackName
   if item -1 of moduleStackName is not "Menu" then put " | Menu" after moduleStackName
   return moduleStackName
end module_ConstructGlobalMenuTitle

function module_ViewNameToShortFolder moduleStackName
   put project_NameToShortFolder (moduleStackName) into shortModuleFolder
   return shortModuleFolder
   
   replace "|" with "_" in moduleStackName -- hack
   return shortModuleFolder
end module_ViewNameToShortFolder


--> Working on
-
getprop view_GlobalMenuTitle
   put the view_Name of the target into viewName
   put menu_GlobalTitleFromViewName (viewName) into globalMenuTitle
   return globalMenuTitle
end view_GlobalMenuTitle

getprop project_Menu
   put the project_Name of the target into stackName
   put module_ConstructGlobalMenuTitle (stackName, true) into gMenuTitle 
   return gMenuTitle
end project_menu

function project_GetModuleFolder moduleFolderName, projectName, pRepoFolder
   if projectName is empty then return empty
   put env_ConstructProjectFolder (projectName, pRepoFolder) into projectFolder
   --
   put module_GetFolder (moduleFolderName, projectFolder) into moduleFolder
   return moduleFolder
end project_GetModuleFolder

command stack_Close stackPaths
   -- saves them before closing
   repeat for each line stackPath in stackPaths
      set the cursor to busy
      if there is a stack stackPath then
         save stack stackPath
         delete stack stackPath
      else
         put stackPath & CR after badStackPaths
      end if
   end repeat
   delete char -1 of badStackPaths
   return badStackPaths
end stack_Close


on module_Rename oldModuleStackName, newModuleStackName, projectName
   -- do a whole bunch of safety checks
   if exists (stack oldModuleStackName) is false then
      lcw_AnswerWarning "Cannot locate module stack to rename!"
   end if
   
   put the filename of stack oldModuleStackName into oldFilePath
   put the project_Folder of stack oldModuleStackName into projectFolder
   put the module_Folder of stack oldModuleStackName into oldModuleFolder
   --
   if there is not a folder projectFolder then
      lcw_AnswerWarning "Project folder does not exist!"
   end if
   if there is not a folder oldModuleFolder then
      lcw_AnswerWarning "Module folder does not exist!"
   end if
   
   put env_ListShortModuleFolders() into allModuleNames
   if exists (stack newModuleStackName) then
      go to stack newModuleStackName
      lcw_AnswerWarning "Stack already exists!"
   end if
   -- check in all module names
   if newModuleStackName is among the lines of allModuleNames then
      -- display_ListModules
      display_ModuleArray
      lcw_AnswerWarning "Module already exists!"
   end if
   
   put project_NameToShortFolder (newModuleStackName) into newShortModuleFolder
   put oldModuleFolder & newShortModuleFolder & ".livecode" into tempModulePath
   put project_GetModuleFolder (newShortModuleFolder, projectName) into newModuleFolder
   put the long id of control 1 of cd 1 of stack oldModuleStackName into viewObject
   
   -- rename view and stack, then save before closing
   set lockmessages to true
   set the view_Name of viewObject to newModuleStackName
   set the filename of stack oldModuleStackName to tempModulePath
   set the name of stack oldModuleStackName to newModuleStackName
   save stack newModuleStackName
   set lockmessages to false
   
   put the module_StackPaths of stack newModuleStackName into stackPaths
   --
   stack_Close stackPaths
   rename folder oldModuleFolder to newModuleFolder
   project_InitialiseFolder newModuleFolder
   go to stack newModuleStackName
   --
   -- reindex project and just in case newModuleFolder
   -- project_ExportMenusAndStackFiles projectFolder
   project_ExportMenusAndStackFiles newModuleFolder
end module_Rename

command module_Initialise moduleName, projectName
   -- for convenience
   put project_GetModuleFolder (moduleName, projectName) into moduleFolder
   if there is not a folder moduleFoldeer then return false
   project_InitialiseFolder moduleFolder
   return true
end module_Initialise

command module_CloseStacks moduleStackName
   if exists (stack moduleStackName) is false then
      throw "Error, cannot locate module stack:" && moduleName
   end if
   
   put the module_StackPaths of stack moduleStackName into stackPaths
   stack_Close stackPaths
   put the result into badStackPaths
   return badStackPaths
end module_CloseStacks


--> Module | Names
-
getprop module_Name
   put the module_Folder of the target into moduleFolder
   set the itemdelimiter to slash
   put item -1 of moduleFolder into moduleName
   return moduleName
end module_Name

getprop module_ViewName [moduleName]
   put the module_View [moduleName] of the target into moduleView
   if exists (moduleView) is false then return empty
   put the view_Name of moduleView into viewName
   return viewName
end module_ViewName


--> Module | Props
-
getprop module_HomeStack [moduleName]
   put the module_HomeStackPath [moduleName] of the target into moduleHomeStackPath
   if exists (stack moduleHomeStackPath) is false then return empty
   put the name of stack moduleHomeStackPath into stackObject
   return stackObject
end module_HomeStack

getprop module_Behavior
   return the module_Behaviors of the target
end module_Behavior

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

getprop module_ControllerStackNames
   put the long id of the target into tObject
   put the module_Controllers of tObject into cObjects
   repeat for each line cObject in cObjects
      put the short name of cObject into cName
      put cName & CR after cNames 
   end repeat
   delete char -1 of cNames
   sort cNames
   return cNames
end module_ControllerStackNames

getprop module_StackPaths
   put the stack_Name of the target into moduleName
   if exists (stack moduleName) is falee then return empty
   --
   put the effective filename of stack moduleName into moduleStackPath
   put _GetModuleStackPaths (moduleStackPath) into stackPaths
   return stackPaths
end module_StackPaths


--> Module | Ojects
-
getprop module_View [moduleName]
   put module_GetTemplateObject (moduleName) into moduleView
   return moduleView
end module_View

function module_GetTemplateObject moduleName, pProjectFolder
   put module_ConstructHomeStackPath (moduleName, pProjectFolder) into moduleHomeStackPath
   if exists (control 1 of cd 1 of stack moduleHomeStackPath) is false then return empty
   --
   put the long id of control 1 of cd 1 of stack moduleHomeStackPath into moduleView
   return moduleView
end module_GetTemplateObject

command module_RemoveFromMemory moduleName, projectFolder
   put module_ListStackPaths (moduleName, projectFolder) into stackPaths
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) then
         delete stack stackPath
         put stackPath & CR into removedStackPaths
      end if
   end repeat
   delete char -1 of removedStackPaths
   return removedStackPaths
end module_RemoveFromMemory


--> View | Name | Utils
-
function view_FromModuleStackName moduleStackName
   replace "_" with "|" in moduleStackName
   return moduleStackName
end view_FromModuleStackName

command view_NormalizeName @viewPath
   if viewPath is empty then return false
   view_NormalizePiped viewPath
   
   set the itemdelimiter to "|"
   if item 1 of viewPath is not among the items of "View|Layout" then put "View|" before viewPath
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


--> Menu | Names
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


--> Module
-
function module_ConstructHomeStackPath moduleName, projectFolder
   put project_NameToShortFolder (moduleName) into moduleFolderName
   put module_GetFolder (moduleFolderName, projectFolder) into moduleFolder
   put project_ConstructHomeStackPath (moduleFolder) into stackPath
   return stackPath
end module_ConstructHomeStackPath

function module_GetHomeStackPath moduleFolderName, projectName
   put project_GetModuleFolder (moduleFolderName, projectName) into moduleFolder
   put project_ConstructHomeStackPath (moduleFolder) into moduleHomeStackPath
   return moduleHomeStackPath
end module_GetHomeStackPath


--> Module | Find
-
function module_FindFolder moduleName
   put module_GetArray (moduleName) into moduleArray
   put moduleArray ["moduleFolder"] into moduleFolder
   return moduleFolder
end module_FindFolder

function module_FindStackPath moduleName
   put module_GetArray (moduleName) into moduleArray
   put moduleArray ["moduleStackath"] into moduleStackath
   return moduleStackath
end module_FindStackPath

function module_FindProject moduleName
   put module_GetArray (moduleName) into moduleArray
   put moduleArray ["projectName"] into projectName
   return projectName
end module_FindProject

function module_GetArray moduleName
   put env_GetModuleArray() into envModuleArray
   put module_ViewNameToShortFolder (moduleName) into moduleFolderName
   put envModuleArray ["active"][moduleFolderName] into moduleArray
   return moduleArray
end module_GetArray


--> Module | List
-
function module_ListStackNames moduleName, projectFolder
   -- loads them all into memory
   put module_ListStackPaths (moduleName, projectFolder) into allStackPaths
   repeat for each line stackPath in allStackPaths
      set the cursor to busy
      if there is a stack stackPath then
         put the short name of stack stackPath & CR after stackNames
      end if
   end repeat
   delete char -1 of stackNames
   return stackNames
end module_ListStackNames

function module_ListStackPaths moduleName, projectFolder
   put module_ConstructHomeStackPath (moduleName, projectFolder) into moduleStackpath
   if exists (stack moduleStackpath) is false then return empty
   put _GetModuleStackPaths (moduleStackPath) into stackPaths
   return stackPaths
end module_ListStackPaths

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
   put folder_AddShort (moduleFolder, "controllers") into moduleControllerFolder
   return moduleControllerFolder
end module_GetControllerFolder

function module_GetBehaviorFolder moduleName, projectFolder
   put project_NameToShortFolder (moduleName) into moduleFolderName
   put module_GetFolder (moduleFolderName, projectFolder) into moduleFolder
   put folder_AddShort (moduleFolder, "behaviors") into moduleBehaviorFolder
   return moduleBehaviorFolder
end module_GetBehaviorFolder


--> Private
-
private function _GetModuleStackPaths moduleStackPath
   set the itemdelimiter to slash
   -- put item 1 to -3 of moduleStackPath & slash into moduleFolder
   put item 1 to -4 of moduleStackPath & slash into projectFolder
   put item -2 of moduleStackPath into shortModuleFolder
   
   put moduleStackPath & CR into stackPaths
   --
   get module_ListBehaviorStackPaths (shortModuleFolder, projectFolder)
   if it is not empty then put it & CR after stackPaths
   --
   get module_ListControllerStackPaths (shortModuleFolder, projectFolder)
   if it is not empty then put it & CR after stackPaths
   --
   return word 1 to -1 of stackPaths
end _GetModuleStackPaths

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
