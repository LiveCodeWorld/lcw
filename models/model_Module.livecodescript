script "model_Module"
--> MetaData
-
license: GPLv3
name: model_Module
type: models
version: 0.8

/*
The model for modules should share many of teh handlers for projects as the structures are the same
*/


--> Working on
-
getprop module_MenuTitles
   -- was "module_ControllerStackNames"
   put the long id of the target into tObject
   put the module_Controllers of tObject into cObjects
   repeat for each line cObject in cObjects
      put the stack_Name of cObject into cName
      put cName & CR after cNames 
   end repeat
   delete char -1 of cNames
   sort cNames
   return cNames
end module_MenuTitles

function lcw_GetFolder projectName, pModuleShortFolder
   get lcw_ConstructFolder (projectName, pModuleShortFolder)
   if there is a folder it then
      return it
   else
      return empty
   end if
end lcw_GetFolder

function lcw_ConstructFolder projectName, pModuleShortFolder
   -- module or project
   put env_ProjectFolder (projectName) into projectFolder
   if pModuleShortFolder is empty then
      return projectFolder
   else
      put module_GetFolder (pModuleShortFolder, projectFolder) into moduleFolder
      return moduleFolder
   end if
end lcw_ConstructFolder

function module_GetFolder moduleShortFolder, projectFolder
   put folder_AddShort (projectFolder, "modules") into rootModuleFolder
   put rootModuleFolder & moduleShortFolder & slash into moduleFolder
   if there is a folder moduleFolder then
      return moduleFolder
   else
      return empty
   end if
end module_GetFolder

getprop lcw_Folder [rPath]
   -- module or project
   put the long id of the target into tObject
   --
   put the module_Folder of tObject into mFolder
   if there is not a folder mFolder then
      put the project_Folder of tObject into mFolder
      if there is not a folder mFolder then
         put the project_Folder of me into mFolder -- Outside of LCW (lazy default)
      end if
   end if
   text_AddPath mFolder, rPath, slash -- always a folder
   
   if there is a folder mFolder then
      return mFolder
   else
      return empty
   end if
end lcw_Folder

getprop module_Folder
   put the long id of the target into tObject
   put the effective filename of the defaultstack into stackPath
   if stackPath is empty then return empty
   --
   put the project_Folder of tObject into projectFolder
   if there is not a folder projectFolder then return empty
   --
   put module_FolderFromPath (stackPath, projectFolder) into moduleFolder
   return moduleFolder
end module_Folder

getprop is_Module
   put the module_Folder of the target into mFolder -- lib_LCW
   return mFolder is not empty
end is_Module

getprop module_Behavior [useDefault]
   breakpoint
   if useDefault is true then
      return the default_Behavior of the target
   else
      put the module_Behaviors of the target into bObjects
      return line 1 of bObjects
   end if
end module_Behavior

function module_GetTemplateObject moduleName, pProjectFolder
   put module_ConstructHomeStackPath (moduleName, pProjectFolder) into moduleHomeStackPath
   if exists (control 1 of cd 1 of stack moduleHomeStackPath) is false then return empty
   --
   put the long id of control 1 of cd 1 of stack moduleHomeStackPath into moduleView
   return moduleView
end module_GetTemplateObject

command module_Initialise moduleName, projectName
   -- for convenience
   put project_GetModuleFolder (moduleName, projectName) into moduleFolder
   if there is not a folder moduleFoldeer then return false
   project_InitialiseFolder moduleFolder
   return true
end module_Initialise

function menu_TitleFromController mController
   -- Caution: we assume that the stack is named the same as the global menu
   put the stack_Name of mController into stack_Name
   put the short name of  mController into mTitle
   return mTitle
end menu_TitleFromController


--> Props
-
getprop module_Behaviors
   -- unordered list
   put the module_BehaviorPaths of the target into stackPaths
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      put the name of stack stackPath & CR after moduleBehaviors
   end repeat
   delete char -1 of moduleBehaviors
   return moduleBehaviors
end module_Behaviors

setprop module_Behaviors bObjects
   switch bObjects
      case empty
         set the behavior_Objects of the target to empty
         break
      case true
         put the module_OrderedBehaviors of the target into bObjects
         set the behavior_Objects of the target to bObjects
         break
      default
         set the behavior_Objects of the target to bObjects
   end switch 
end module_Behaviors

getprop module_OrderedBehaviors
   -- make sure default behavior is first
   put the view_Name of the target into moduleName
   --
   put module_ListBehaviorStackPaths (moduleName) into sPaths
   repeat for each line sPath in sPaths
      if exists (stack sPath) is true then
         put the name of stack sPath & CR after bObjects
      end if
   end repeat
   delete char -1 of bObjects
   
   # Make default behavior first
   put label_BehaviorName (moduleName) into bName
   line_Delete bName, stackNames
   put word 1 to -1 of bName & CR & stackNames into stackNames
   
   return bObjects
end module_OrderedBehaviors


--> Module | Props
-
getprop module_BahaviorFolder
   put the module_Folder of the target into moduleFolder
   put moduleFolder & "behaviors/" into moduleBehaviorFolder
   if there is a folder moduleBehaviorFolder then
      return moduleBehaviorFolder
   else
      return empty
   end if
end module_BahaviorFolder

getprop module_BehaviorStackNames
   put the module_BehaviorPaths of the target into stackPaths
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      put the short name of stack stackPath & CR after sNames
   end repeat
   delete char -1 of sNames
   return sNames
end module_BehaviorStackNames

getprop module_Objects
   -- should also get other objects
   put the module_Hierarchy of the target into mObjects
   return mObjects
end module_Objects

getprop module_BehaviorHierarchy [fromFolder]
   local oHierarchy, bHierarchy
   put the long id of the target into tObject
   put revRuggedId (tObject) into rObject
   --
   put the module_Name of tObject into moduleName
   put default_FirstStackControl (moduleName) into mObject
   
   # Behaviors and object hieararchy
   if fromFolder is not false then
      put the module_Behaviors of mObject into oHierarchy
   else
      put the behavior_Objects of mObject into oHierarchy
   end if
   --
   line_Delete rObject, oHierarchy
   put rObject & CR before oHierarchy
   put word 1 to -1 of oHierarchy into oHierarchy
   
   # Rest of object hierarchy
   hierachy_AddStackObjects bHierarchy, mObject
   put oHierarchy & CR & word 1 to -1 of bHierarchy into walkHierarchy
   
   # Is this missing stack object?
   
   # Add Env hierarchy
   hierarchy_AddEnv walkHierarchy
   return walkHierarchy
end module_BehaviorHierarchy

getprop module_StackPaths
   put the module_Folder of the target into moduleFolder
   put directory_ListNestedPaths (moduleFolder) into stackPaths
   return stackPaths
end module_StackPaths

getprop project_ShortFolder
   put the project_Folder of the target into projectFolder
   set the itemdelimiter to slash
   put item -1 of projectFolder into shortFolder
   return shortFolder
end project_ShortFolder

getprop project_Controller [menuBit]
   put the project_ControllerPath [menuBit] of the target into mPath
   if there is a stack mPath then
      return the long id of stack mPath
   else
      return empty
   end if
end project_Controller

getprop project_ControllerPath [menuBit]
   put the project_MenuTitle [menuBit] of the target into mTitle
   put the project_Folder of the target into projectFolder
   put projectFolder & "controllers/" into cFolder
   --
   put label_PipesToUnderscore (mTitle) & ".livecodescript" into shortFile
   --
   put cFolder & shortFile into cPath
   return cPath
end project_ControllerPath

getprop project_Array
   put the project_Folder of the target into projectFolder
   if there is not a folder projectFolder then return empty
   --
   put project_ConstructArrayFromFolder (projectFolder) into projectArray
   return projectArray
end project_Array

setprop project_Array projectArray
   put the project_Folder of the target into projectFolder
   if there is not a folder moduleArray then return "Error, project_Folder does not exist for:" && the target
   --
   project_StoreArray projectFolder, projectArray
   return projectFolder
end project_Array

getprop project_ControllerStackNames
   put the long id of the target into tObject
   put the project_Controllers of tObject into cObjects
   repeat for each line cObject in cObjects
      put the stack_Name of cObject into cName
      put cName & CR after cNames 
   end repeat
   delete char -1 of cNames
   sort cNames
   return cNames
end project_ControllerStackNames

getprop project_Controllers
   put the project_Folder of the target into projectFolder
   put projectFolder & "controllers/" into projectControllerFolder
   put folder_ListStackPaths (projectControllerFolder) into stackPaths
   
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      put the name of stack stackPath & CR after projectControllers
   end repeat
   delete char -1 of projectControllers
   return projectControllers
end project_Controllers

getprop module_Name
   put the effective filename of the defaultstack into sPath
   put default_ModuleNameFromFolder (sPath) into moduleName
   return moduleName
end module_Name

getprop module_Names
   put the project_Folder of the target into projectFolder
   put projectFolder & "modules/" into modulesFolder
   put folder_ListShort (modulesFolder) into moduleShortFolders
   repeat for each line moduleFolderName in moduleShortFolders
      put module_GetFolder (moduleFolderName, projectFolder) into moduleFolder
      put project_PathFromFolder (moduleFolder) into moduleHomeStackPath
      if exists (stack moduleHomeStackPath) then
         put the short name of stack moduleHomeStackPath into moduleName
         put moduleName & CR after moduleNames
      end if
   end repeat
   delete char -1 of moduleNames
   return moduleNames
end module_Names

getprop module_ShortFolders
   put the project_Folder of the target into projectFolder
   put projectFolder & "modules/" into modulesFolder
   put folder_ListShort (modulesFolder) into moduleShortFolders
   return moduleShortFolders
end module_ShortFolders

getprop module_ControllerPath [menuBit]
   put the module_Folder of the target into moduleFolder
   put moduleFolder & "controllers/" into cFolder
   --
   put the module_MenuTitle [menuBit] of the target into mTitle
   put label_PipesToUnderscore (mTitle) & ".livecodescript" into shortFile
   --
   put cFolder & shortFile into cPath
   return cPath
end module_ControllerPath

getprop module_HomeStack [moduleName]
   put the module_HomeStackPath [moduleName] of the target into moduleHomeStackPath
   if exists (stack moduleHomeStackPath) is false then return empty
   put the name of stack moduleHomeStackPath into stackObject
   return stackObject
end module_HomeStack

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

getprop module_BehaviorDepHkeyArray [fromFolder]
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
   end switch
   return hKeyArray
end module_BehaviorDepHkeyArray

getprop stack_Name
   return the short name of the defaultstack
end stack_Name

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

getprop module_BehaviorDepKeys   
   # List module dependency Hkeys
   put the module_BehaviorDepHkeyArray of the target into hKeyArray
   put array_List (hkeyArray) into hKeys
   
   # Filter out all module objects
   put the module_Objects of the target into mObjects
   repeat for each line mObject in mObjects
      filter hKeys without ("*" && mObject)
   end repeat
   return hKeys
end module_BehaviorDepKeys

getprop module_BehaviorPaths
   put the module_Folder of the target into moduleFolder
   put moduleFolder & "behaviors/" into moduleBehaviorFolder
   put folder_ListStackPaths (moduleBehaviorFolder) into stackPaths
   return stackPaths
end module_BehaviorPaths

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
   put hkeyStackArray_From (hkeyArray) into stackHkeyArray
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


--> Module
-
function module_ConstructShortFolder sPath
   put module_FolderFromStackPath (sPath) into moduleFolder
   set the itemdelimiter to slash
   put item -1 of moduleFolder into shortFolder
   return shortFolder
end module_ConstructShortFolder

function module_FolderFromStackPath stackPath
   put project_FolderFromPath (stackPath) into projectFolder
   if there is not a folder projectFolder then return empty
   
   set the itemdelimiter to slash
   put the number of items of projectFolder into pNum
   get item (pNum + 1) of stackPath
   if it is not "Modules" then return empty
   
   put item 1 to (pNum + 2) of stackPath & slash into moduleFolder
   return moduleFolder
end module_FolderFromStackPath

function module_FolderFromPath stackPath, projectFolder
   set the itemdelimiter to slash
   put the number of items of projectFolder into pNum
   if item (pNum + 1) of stackPath is not "Modules" then return empty
   
   put item 1 to (pNum + 2) of stackPath & slash into moduleFolder
   return moduleFolder
end module_FolderFromPath

function module_ConstructHomeStackPath moduleName, projectFolder
   put label_PipesToUnderscore (moduleName) into moduleFolderName
   put module_GetFolder (moduleFolderName, projectFolder) into moduleFolder
   put project_PathFromFolder (moduleFolder) into stackPath
   return stackPath
end module_ConstructHomeStackPath

function module_GetHomeStackPath moduleFolderName, projectName
   put project_GetModuleFolder (moduleFolderName, projectName) into moduleFolder
   put project_PathFromFolder (moduleFolder) into moduleHomeStackPath
   return moduleHomeStackPath
end module_GetHomeStackPath

function module_GetArray moduleName
   if there is a stack moduleName then
      put the module_Array of stack moduleName into moduleArray
      return moduleArray
   else
      -- if exists (moduleView) is false then
      # Get from Env
      -- return "Error, module does not exists:" && moduleName
      put env_GetModuleArray() into envModuleArray
      put label_PipesToUnderscore (moduleName) into moduleFolderName
      put envModuleArray ["active"][moduleFolderName] into moduleArray
      return moduleArray
   end if
end module_GetArray

function module_JsonFile moduleName, projectFolder
   put module_ConstructJsonFile (moduleName, projectFolder) into jsonFile
   if there is a file jsonFile then
      return jsonFile
   else
      return empty
   end if
end module_JsonFile

function module_ConstructJsonFile moduleStackName, projectFolder
   put label_PipesToUnderscore (moduleStackName) into shortModuleFolder
   put module_GetFolder (shortModuleFolder, projectFolder) into moduleFolder
   put moduleFolder & "lcw_project.json" into moduleJsonFile
   return moduleJsonFile
end module_ConstructJsonFile

command module_Clone moduleName, pShowTools
   view_NormalizeName moduleName
   --
   stack_Clone moduleName
   put the result into clonedStack
   --
   set the original_ModuleName of clonedStack to moduleName
   put the stack_Name of clonedStack into cStackName
   --
   if pShowTools is true then
      display_CloneTools cStackName
   end if
   return cStackName
end module_Clone


--> Module | Behaviors
-
function module_ListBehaviorStackNames moduleName, pProjectName
   put module_ListBehaviorStackPaths (moduleName, pProjectName) into stackPaths
   put stack_PathsToNames (stackPaths) into stackNames
   
   # Make default behavior first
   put label_BehaviorName (moduleName) into bName
   line_Delete bName, stackNames
   put word 1 to -1 of bName & CR & stackNames into stackNames
   --
   return stackNames
end module_ListBehaviorStackNames

function module_ConstructBehaviorPath viewName, moduleFolder, pShortFile
   put folder_AddShort (moduleFolder, "behaviors") into moduleBehaviorFolder
   put moduleBehaviorFolder & pShortFile into moduleControllerPath
   return moduleControllerPath
end module_ConstructBehaviorPath

function module_ConstructBehaviorShortFile moduleStackName
   put label_BehaviorName (moduleStackName) & ".livecodescript" into shortFile  
   return shortFile
end module_ConstructBehaviorShortFile

function module_ConstructBehaviorName viewName
   return label_BehaviorName (stackName)
end module_ConstructBehaviorName

function module_GetBehaviorStackPath behaviorStackName, rootModuleFolder
   put behaviorStackName & ".livecodescript" into shortBehaviorPath
   put rootModuleFolder & "behaviors/" & shortBehaviorPath into moduleBehaviorStackPath
   return moduleBehaviorStackPath
end module_GetBehaviorStackPath

function module_ListBehaviorObjects moduleName, pProjectName
   put module_ListBehaviorStackPaths (moduleName, pProjectName) into sPaths
   repeat for each line sPath in sPaths
      if exists (stack sPath) is true then
         put the name of stack sPath & CR after bObjects
      end if
   end repeat
   delete char -1 of bObjects
   return bObjects
end module_ListBehaviorObjects

function module_ListBehaviorStackPaths moduleName, pProjectName
   switch
      case exists (stack pProjectName)
         put the effective filename of stack pProjectName into stackPath
         break
      case exists (stack moduleName) is false
         return empty
      default
         put the effective filename of stack moduleName into stackPath
   end switch
   put project_FolderFromPath (stackPath) into projectFolder
   
   put module_GetBehaviorFolder (moduleName, projectFolder) into moduleBehaviorFolder
   put folder_ListStackPaths (moduleBehaviorFolder) into stackPaths
   return stackPaths
end module_ListBehaviorStackPaths

function module_ListStackPaths moduleName, pProjectFolder
   if pProjectFolder is empty then
      switch
         case exists (stack moduleName) is false
            return empty
         default
            put the effective filename of stack moduleName into stackPath
            --
            put project_FolderFromPath (stackPath) into projectFolder
            put module_FolderFromPath (stackPath, projectFolder) into moduleFolder
            --
            put directory_ListNestedPaths (moduleFolder) into stackPaths
            return stackPaths
      end switch
   else
      put module_ConstructHomeStackPath (moduleName, pProjectFolder) into moduleStackPath
      if exists (stack moduleStackpath) is false then return empty
      put _ListBehaviorStackPaths (moduleStackPath) into stackPaths
      return stackPaths
   end if
end module_ListStackPaths


--> Module | List
-
function module_ListControllerStackNames moduleName, projectFolder
   put module_ListControllerStackPaths (moduleName, projectFolder) into stackPaths
   put stack_PathsToNames (stackPaths) into stackNames
   return stackNames
end module_ListControllerStackNames

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


--> Module | Files
-
function module_GetControllerFolder moduleName, projectFolder
   put label_PipesToUnderscore (moduleName) into moduleFolderName
   put module_GetFolder (moduleFolderName, projectFolder) into moduleFolder
   put folder_AddShort (moduleFolder, "controllers") into moduleControllerFolder
   return moduleControllerFolder
end module_GetControllerFolder

function module_GetBehaviorFolder moduleName, projectFolder
   put label_PipesToUnderscore (moduleName) into moduleFolderName
   put module_GetFolder (moduleFolderName, projectFolder) into moduleFolder
   put folder_AddShort (moduleFolder, "behaviors") into moduleBehaviorFolder
   return moduleBehaviorFolder
end module_GetBehaviorFolder


--> Deps
-
function project_GetModuleFolder moduleFolderName, projectName, pRepoFolder
   if projectName is empty then return empty
   put env_ConstructProjectFolder (projectName, pRepoFolder) into projectFolder
   --
   put module_GetFolder (moduleFolderName, projectFolder) into moduleFolder
   return moduleFolder
end project_GetModuleFolder

function module_ListControllerStackPaths moduleName, projectFolder
   put module_GetControllerFolder (moduleName, projectFolder) into moduleControllerFolder
   put folder_ListStackPaths (moduleControllerFolder) into stackPaths
   return stackPaths
end module_ListControllerStackPaths

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

function label_PipesToUnderscore moduleName
   set the itemdelimiter to "|"
   repeat for each item someItem in moduleName
      put word 1 to -1 of someItem & "_" after shortFolder
   end repeat
   delete char -1 of shortFolder
   return shortFolder
end label_PipesToUnderscore

function menuGroup_Controller mTitle
   put the module_Controller [mTitle] of stack "View|Menu|Group" into mController
   return mController
end menuGroup_Controller

function project_FolderFromPath stackPath
   set the itemdelimiter to slash
   put env_GetRepoFolder() into repoFolder
   put the number of items of repoFolder + 1 into itemNum
   put item 1 to itemNum of stackPath & slash into projectFolder
   --
   return projectFolder
end project_FolderFromPath


--> Private
-
private function _ListBehaviorStackPaths moduleStackPath
   breakpoint
   set the itemdelimiter to slash
   put item 1 to -4 of moduleStackPath & slash into projectFolder
   put item 1 to -2 of moduleStackPath & slash into moduleFolder
   put item -2 of moduleStackPath into moduleShortFolder
   put folder_AddShort (moduleFolder, "behaviors") into moduleBehaviorFolder
   --
   put moduleStackPath & CR into stackPaths
   --
   get folder_ListStackPaths (moduleBehaviorFolder)
   if it is not empty then put it & CR after stackPaths
   get module_ListControllerStackPaths (moduleShortFolder, projectFolder)
   if it is not empty then put it & CR after stackPaths
   --
   return word 1 to -1 of stackPaths
end _ListBehaviorStackPaths

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
