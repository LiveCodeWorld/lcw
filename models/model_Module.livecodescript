script "model_Module"
--> MetaData
-
license: GPLv3
name: model_Module
type: models
version: 0.3

/*
*/

--> Working on
-


--> Module | Behavior
-
getprop module_BehaviorDepScript
   put the module_BehaviorDepHkeyArray of the target into depHkeyArray
   put keys (depHkeyArray) into hkeyDeps
   
   # Collect dependency handlers
   put hkey_CollectFromObjects (hkeyDeps, true) into depScript
   return depScript
end module_BehaviorDepScript

getprop module_BehaviorDepHkeyArray [fromFolder]
   -- just module behaviors (not recursive, not hierarchy)
   local depHkeyArray
   put the long id of the target into bObject
   
   # Fetch hKeyArray
   put the script_HkeyArrayFile of bObject into hKeyArrayFile
   switch
      case (there is a file hKeyArrayFile) AND (fromFolder is not true)
         # Fetch exported hkeyArray
         put the script_HkeyArray of bObject into hKeyArray
         break
      default
         put the walk_ModuleBehaviorHkeyArray [fromFolder] of bObject into hKeyArray
         set the script_HkeyArray of bObject to hKeyArray
   end switch
   
   # Process hKeyArray
   put hkeyArray_GetStackDepArray (hkeyArray) into stackHkeyArray
   put the name of the stack_Object of bObject into stackObject
   delete variable stackHkeyArray [stackObject]
   
   # Extract unique hkey deps (excluding other behaviors) 
   put the module_BehaviorPaths of bObject into bPaths
   repeat for each key stackObject in stackHkeyArray
      if stackObject = "Missing" then
         next repeat
      end if
      
      put the effective filename of stackObject into sPath
      if sPath is among the lines of bPaths then
         next repeat
      end if
      
      get stackHkeyArray [stackObject]
      union depHkeyArray with it recursively
   end repeat
   return depHkeyArray
end module_BehaviorDepHkeyArray


--> Move
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

getprop stack_View
   -- top view of first card (see also "card_ViewObject")
   put the short name of the defaultstack into stackName
   put the long id of cd 1 of stack stackName into cardObject
   if exists (control 1 of cardObject) is false then return empty
   
   put the view_Object of control 1 of cardObject into vObject
   return vObject
end stack_View

getprop card_ViewObject
   -- assumes its the first control (can be a card)
   -- this is a default (should add this getprop to eveny modules card script/behavior)
   -- unless overridden by card_ViewObject getprop
   
   put the long id of cd 1 of the defaultstack into cardObject
   if exists (control 1 of cardObject) then
      return the long id of control 1 of cardObject
   else
      return cardObject
   end if
end card_ViewObject


--> Props | Module
-
getprop is_Module
   put the module_Folder of the target into mFolder -- lib_LCW
   return mFolder is not empty
end is_Module

getprop module_BehaviorPaths
   put the module_Folder of the target into moduleFolder
   put moduleFolder & "behaviors/" into moduleBehaviorFolder
   put folder_ListStackPaths (moduleBehaviorFolder) into stackPaths
   return stackPaths
end module_BehaviorPaths

getprop module_MenuTitle [menuBit]
   if menu_IsGlobal (menuBit) then return menuBit
   
   put the module_Name of the target into moduleName
   if moduleName is empty then
      put the view_Name of the target into moduleName
   end if
   if moduleName is empty then return empty
   
   if menuBit is empty then
      put moduleName into vName
   else
      put moduleName & "|" & menuBit into vName
   end if
   
   put menu_GlobalTitleFromViewName (vName) into globalMenuTitle
   return globalMenuTitle
end module_MenuTitle

getprop module_ControllerStackNames
   put the long id of the target into tObject
   put the module_Controllers of tObject into cObjects
   repeat for each line cObject in cObjects
      put the stack_Name of cObject into cName
      put cName & CR after cNames 
   end repeat
   delete char -1 of cNames
   sort cNames
   return cNames
end module_ControllerStackNames

getprop module_View
   -- a lazy default (should have specific handler in card script or behavior)
   put the short name of the defaultstack into stackName
   put the long id of cd 1 of stack stackName into cardObject
   if exists (control 1 of cardObject) is false then return empty
   
   put the view_Name of control 1 of cardObject into viewName
   if viewName = stackName then
      return the long id of control 1 of cardObject
   end if
end module_View


--> Module | Name and Short Folder
-
getprop module_Name
   put the module_ShortFolder of the target into moduleName
   replace "_" with "|" in moduleName
   return moduleName
end module_Name

getprop module_ShortFolder
   put the module_Folder of the target into moduleFolder
   set the itemdelimiter to slash
   put item -1 of moduleFolder into shortFolder
   return shortFolder
end module_ShortFolder

getprop module_Controller [menuBit]
   put the module_ControllerPath [menuBit] of the target into mPath
   if there is a stack mPath then
      return the long id of stack mPath
   else
      return empty
   end if
end module_Controller

getprop module_ControllerPath [menuBit]
   put the module_Folder of the target into moduleFolder
   put moduleFolder & "controllers/" into cFolder
   --
   put the module_MenuTitle [menuBit] of the target into mTitle
   put lcw_PipesToUnderscore (mTitle) & ".livecodescript" into shortFile
   --
   put cFolder & shortFile into cPath
   return cPath
end module_ControllerPath


--> Working on
-
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

getprop module_BahaviorFolder
   put the module_Folder of the target into moduleFolder
   put moduleFolder & "behaviors/" into moduleBehaviorFolder
   if there is a folder moduleBehaviorFolder then
      return moduleBehaviorFolder
   else
      return empty
   end if
end module_BahaviorFolder

getprop module_Behavior [useDefault]
   breakpoint
   if useDefault is true then
      return the module_DefaultBehavior of the target
   else
      put the module_Behaviors of the target into bObjects
      return line 1 of bObjects
   end if
end module_Behavior

getprop module_DefaultBehavior
   -- put the module_Folder of the target into moduleFolder
   put the view_Name of the target into viewName
   if viewName is empty then return empty
   put the stack_Folder of the target into moduleFolder
   --
   put module_ConstructBehaviorPath (viewName, moduleFolder) into bPath
   if there is a stack bPath then
      return the long name of stack bPath
   else
      return empty
   end if
end module_DefaultBehavior

getprop module_ViewName [moduleName]
   if moduleName is empty then
      put the module_View of the target into moduleView
   else
      put module_GetTemplateObject (moduleName) into moduleView
   end if
   
   if exists (moduleView) is false then return empty
   put the view_Name of moduleView into viewName
   return viewName
end module_ViewName

getprop module_HomeStack [moduleName]
   put the module_HomeStackPath [moduleName] of the target into moduleHomeStackPath
   if exists (stack moduleHomeStackPath) is false then return empty
   put the name of stack moduleHomeStackPath into stackObject
   return stackObject
end module_HomeStack

getprop module_BehaviorStackNames
   put the module_BehaviorPaths of the target into stackPaths
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      put the short name of stack stackPath & CR after sNames
   end repeat
   delete char -1 of sNames
   return sNames
end module_BehaviorStackNames

getprop module_Behaviors
   put the module_BehaviorPaths of the target into stackPaths
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      put the name of stack stackPath & CR after moduleBehaviors
   end repeat
   delete char -1 of moduleBehaviors
   return moduleBehaviors
end module_Behaviors

getprop module_StackPaths
   put the module_Folder of the target into moduleFolder
   put directory_ListNestedPaths (moduleFolder) into stackPaths
   /*
   put the stack_Name of the target into moduleName
   if exists (stack moduleName) is falee then return empty
   --   
   put the effective filename of stack moduleName into moduleStackPath
   put _GetModuleStackPaths (moduleStackPath) into stackPaths
   */
   return stackPaths
end module_StackPaths


--> Project
-
function project_GetModuleFolder moduleFolderName, projectName, pRepoFolder
   if projectName is empty then return empty
   put env_ConstructProjectFolder (projectName, pRepoFolder) into projectFolder
   --
   put module_GetFolder (moduleFolderName, projectFolder) into moduleFolder
   return moduleFolder
end project_GetModuleFolder

function project_DefaultBehaviorName moduleStackName
   view_NormalizePiped moduleStackName -- just in case
   replace "|" with empty in moduleStackName
   replace "_" with empty in moduleStackName
   --
   put "behavior_" & moduleStackName into behaviorStackName
   return behaviorStackName
end project_DefaultBehaviorName

command module_Initialise moduleName, projectName
   -- for convenience
   put project_GetModuleFolder (moduleName, projectName) into moduleFolder
   if there is not a folder moduleFoldeer then return false
   project_InitialiseFolder moduleFolder
   return true
end module_Initialise

command module_CreateBehaviorDepStack sObject, depScript
   put the stack_name of sObject into bName
   put bName & "Deps" into depStackName
   if exists (stack depStackName) is true then
      return "Error, stack already exists"
   end if
   
   # Create behavior stack (don't save)
   create stack depStackName
   --
   put the module_BahaviorFolder of sObject into bFolder
   put bFolder & depStackName & ".livecodescript" into bPath
   set the filename of stack depStackName to bPath
   set the destroyStack of stack depStackName to true
   set the destroyWindow of stack depStackName to true
   --
   go to stack depStackName
   
   # Add handlers to behavior created stack (don't save)
   set the script of stack depStackName to depScript
   return depStackName
end module_CreateBehaviorDepStack


function menu_TitleFromController mController
   -- Caution: we assume that the stack is named the same as the global menu
   put the stack_Name of mController into stack_Name
   put the short name of  mController into mTitle
   return mTitle
end menu_TitleFromController

function module_ConstructGlobalMenuTitle moduleStackName, pMakePretty
   -- see "menu_GlobalTitleFromViewName"
   
   replace "_" with "|" in moduleStackName
   menu_NormalizeTitle moduleStackName, pMakePretty
   set the itemdelimiter to " | "
   if item 1 of moduleStackName is not "Global" then put "Global | " before moduleStackName
   if item 2 of moduleStackName = "View" then delete item 2 of moduleStackName
   if item -1 of moduleStackName is not "Menu" then put " | Menu" after moduleStackName
   return moduleStackName
end module_ConstructGlobalMenuTitle

function module_ListControllerStackPaths moduleName, projectFolder
   put module_GetControllerFolder (moduleName, projectFolder) into moduleControllerFolder
   put folder_ListStackPaths (moduleControllerFolder) into stackPaths
   return stackPaths
end module_ListControllerStackPaths


--> Module | List
-
function module_ListControllerStackNames moduleName, projectFolder
   put module_ListControllerStackPaths (moduleName, projectFolder) into stackPaths
   put stack_PathsToNames (stackPaths) into stackNames
   return stackNames
end module_ListControllerStackNames

function module_ListStackPaths moduleName, projectFolder
   put module_ConstructHomeStackPath (moduleName, projectFolder) into moduleStackpath
   if exists (stack moduleStackpath) is false then return empty
   put _GetModuleStackPaths (moduleStackPath) into stackPaths
   return stackPaths
end module_ListStackPaths

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


--> Module | Ojects
-
function module_GetTemplateObject moduleName, pProjectFolder
   put module_ConstructHomeStackPath (moduleName, pProjectFolder) into moduleHomeStackPath
   if exists (control 1 of cd 1 of stack moduleHomeStackPath) is false then return empty
   --
   put the long id of control 1 of cd 1 of stack moduleHomeStackPath into moduleView
   return moduleView
end module_GetTemplateObject

function module_ConstructHomeStackPath moduleName, projectFolder
   put lcw_PipesToUnderscore (moduleName) into moduleFolderName
   put module_GetFolder (moduleFolderName, projectFolder) into moduleFolder
   put project_PathFromFolder (moduleFolder) into stackPath
   return stackPath
end module_ConstructHomeStackPath

function module_GetHomeStackPath moduleFolderName, projectName
   put project_GetModuleFolder (moduleFolderName, projectName) into moduleFolder
   put project_PathFromFolder (moduleFolder) into moduleHomeStackPath
   return moduleHomeStackPath
end module_GetHomeStackPath


--> Module | Names
-
function module_BehaviorPathFromFolder moduleFolder
   # Module Behavior folder
   put folder_AddShort (moduleFolder, "behaviors") into moduleBehaviorFolder
   
   # Construct short file for behavior
   set the itemdelimiter to slash
   put item -1 of moduleFolder into moduleShortFolder
   put module_ConstructBehaviorShortFile (moduleShortFolder) into bShortFile
   
   # Construct behavior path
   put moduleBehaviorFolder & bShortFile into moduleBehaviorPath
   return moduleBehaviorPath
end module_BehaviorPathFromFolder

function module_ConstructBehaviorPath viewName, moduleFolder, pShortFile
   put lcw_PipesToUnderscore (viewName) into moduleName
   if pShortFile is empty then
      put module_ConstructBehaviorShortFile (moduleName) into pShortFile
   end if
   put folder_AddShort (moduleFolder, "behaviors") into moduleControllerFolder
   put moduleControllerFolder & pShortFile into moduleControllerPath
   return moduleControllerPath
end module_ConstructBehaviorPath

function module_GetBehaviorStackPath behaviorStackName, rootModuleFolder
   put behaviorStackName & ".livecodescript" into shortBehaviorPath
   put rootModuleFolder & "behaviors/" & shortBehaviorPath into moduleBehaviorStackPath
   return moduleBehaviorStackPath
end module_GetBehaviorStackPath

function module_ConstructBehaviorName viewName
   put lcw_PipesToUnderscore (viewName) into moduleFolderName
   put project_DefaultBehaviorName (moduleFolderName) into bStackName
   return bStackName
end module_ConstructBehaviorName

function module_ConstructBehaviorShortFile moduleStackName
   put project_DefaultBehaviorName (moduleStackName) & ".livecodescript" into shortFile
   return shortFile
end module_ConstructBehaviorShortFile

command module_CloseStacks moduleStackName
   if exists (stack moduleStackName) is false then
      throw "Error, cannot locate module stack:" && moduleName
   end if
   
   put the module_StackPaths of stack moduleStackName into stackPaths
   stack_Close stackPaths
   put the result into badStackPaths
   return badStackPaths
end module_CloseStacks


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
   put lcw_PipesToUnderscore (moduleName) into moduleFolderName
   put envModuleArray ["active"][moduleFolderName] into moduleArray
   return moduleArray
end module_GetArray


--> Module | Files
-
function module_GetControllerFolder moduleName, projectFolder
   put lcw_PipesToUnderscore (moduleName) into moduleFolderName
   put module_GetFolder (moduleFolderName, projectFolder) into moduleFolder
   put folder_AddShort (moduleFolder, "controllers") into moduleControllerFolder
   return moduleControllerFolder
end module_GetControllerFolder

function module_GetBehaviorFolder moduleName, projectFolder
   put lcw_PipesToUnderscore (moduleName) into moduleFolderName
   put module_GetFolder (moduleFolderName, projectFolder) into moduleFolder
   put folder_AddShort (moduleFolder, "behaviors") into moduleBehaviorFolder
   return moduleBehaviorFolder
end module_GetBehaviorFolder


--> Deps
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


--> Private
-
private function _GetModuleStackPaths moduleStackPath
   set the itemdelimiter to slash
   -- put item 1 to -3 of moduleStackPath & slash into moduleFolder
   put item 1 to -4 of moduleStackPath & slash into projectFolder
   put item -2 of moduleStackPath into moduleShortFolder
   
   put moduleStackPath & CR into stackPaths
   --
   get module_ListBehaviorStackPaths (moduleShortFolder, projectFolder)
   if it is not empty then put it & CR after stackPaths
   --
   get module_ListControllerStackPaths (moduleShortFolder, projectFolder)
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
