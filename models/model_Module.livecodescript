script "model_Module"
--> MetaData
-
license: GPLv3
name: model_Module
type: models
version: 0.5

/*
The model for modules should share many of teh handlers for projects as the structures are the same
*/

--> Project | Name and Short Folder
-
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
   put lcw_PipesToUnderscore (mTitle) & ".livecodescript" into shortFile
   --
   put cFolder & shortFile into cPath
   return cPath
end project_ControllerPath

getprop project_MenuTitle [menuBit]
   if menu_IsGlobal (menuBit) then return menuBit
   
   put the project_Name of the target into projectName
   if char 1 to 4 of projectName = "lcw_" then
      delete char 1 to 4 of projectName
   end if
   
   if menuBit is empty then
      put "Global |" && projectName && "| Menu" into mTitle
   else
      put "Global |" && projectName && "|" && menuBit && "| Menu" into mTitle
   end if
   
   return mTitle
end project_MenuTitle

function menuGroup_Controller mTitle
   put the module_Controller [mTitle] of stack "View|Menu|Group" into mController
   return mController
end menuGroup_Controller

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
   
   /*
   put the module_ViewName of the target into vName
   if vName is empty then return empty
   put menu_GlobalTitleFromViewName (vName) into mTitle
   */
end module_MenuTitle

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
getprop menubar_DefaultTitles
   put the module_Name of the target into stackName
   if stackName is empty then
      put the project_Name of me into stackName
      put the project_MenuTitle of stack stackName into defaultMenu
      -- put the project_ControllerStackNames of stack stackName into mTitles
      put empty into mTitles
   else
      put the module_MenuTitle of stack stackName into defaultMenu
      put the module_ControllerStackNames of stack stackName into mTitles
   end if
   
   if mTitles is empty then
      put defaultMenu into defaultMenuTitles
   else
      filter mTitles without "* | Dev | Menu"
      line_Delete defaultMenu, mTitles
      put defaultMenu & CR & mTitles into defaultMenuTitles
   end if
   
   # Add a Edit Menu if needed
   if line 2 of defaultMenuTitles ends with "| Edit | Menu" is false then
      put CR & "Global | Menu | Group | Edit" after line 1 of defaultMenuTitles
   end if
   
   # Add Help Menu if needed
   put lineOffset (" | Help | Menu", defaultMenuTitles) into lineNum
   if lineNum > 0 then
      put line lineNum of defaultMenuTitles into helpTitle
      delete line lineNum of defaultMenuTitles
      put CR & helpTitle after defaultMenuTitles
   else
      put CR & "Global | Menu | Group | Help" after defaultMenuTitles
   end if
   return word 1 to -1 of defaultMenuTitles
end menubar_DefaultTitles

getprop module_ViewName
   -- Lazy default
   -- Add definitive handler to stack script and card script for clarity
   put the module_TemplateObject of the target into templateObject
   if exists (templateObject) is false then return empty
   
   put the view_Name of templateObject into viewName
   return viewName
end module_ViewName

getprop module_TemplateObject
   -- Lazy default (first control could be something else)
   -- Add definitive handler to stack script and card script for clarity
   
   put the long id of the target into tObject
   put the stack_Name of tObject into moduleName
   
   # Views should define the view_Object property of the stack or card
   put the long id of cd 1 of stack moduleName into firstCard
   put the view_Object of firstCard into viewObject
   if exists (viewObject) then return viewObject
   
   put the module_DefaultViewObject of tObject into fasd
   return safd
end module_TemplateObject

getprop module_DefaultViewObject
   put the long id of cd 1 of the target into firstCard
   if exists (control 1 of firstCard) is false then return empty
   
   put the long id of control 1 of firstCard into viewObject
   put the view_Name of viewObject into vName
   put the stack_Name of viewObject into stackName
   if vName = stackName then
      return viewObject
   else
      return emnpty
   end if
end module_DefaultViewObject

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
      put the stack_Name of cObject into cName
      put cName & CR after cNames 
   end repeat
   delete char -1 of cNames
   sort cNames
   return cNames
end module_ControllerStackNames


--> Module | Folder
-
getprop module_Folder
   put the long id of the target into tObject
   put the effective filename of the defaultstack into stackPath
   put the project_Folder of tObject into projectFolder
   if there is not a folder projectFolder then return empty
   --
   put module_FolderFromPath (stackPath, projectFolder) into moduleFolder
   return moduleFolder
end module_Folder

function module_FolderFromPath stackPath, projectFolder
   set the itemdelimiter to slash
   put the number of items of projectFolder into pNum
   if item (pNum + 1) of stackPath is not "Modules" then return empty
   
   put item 1 to (pNum + 2) of stackPath & slash into moduleFolder
   return moduleFolder
end module_FolderFromPath

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


--> Module | Behaviors
-
function project_DefaultBehaviorName stackName
   return lcw_ConstructBehaviorName (stackName)
end project_DefaultBehaviorName

getprop module_BehaviorStackNames
   put the module_BehaviorPaths of the target into stackPaths
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      put the short name of stack stackPath & CR after sNames
   end repeat
   delete char -1 of sNames
   return sNames
end module_BehaviorStackNames

-- getprop module_BehaviorStackNames
put the module_Name of the target into mName
put module_ListBehaviorStackNames (mName) into mBehaviorStackNames
return mBehaviorStackNames
end module_BehaviorStackNames

function module_ListBehaviorStackNames moduleName, pProjectName
   put module_ListBehaviorStackPaths (moduleName, pProjectName) into stackPaths
   put stack_PathsToNames (stackPaths) into stackNames
   
   # Make default behavior first
   put lcw_ConstructBehaviorName (moduleName) into bName
   line_Delete bName, stackNames
   put word 1 to -1 of bName & CR & stackNames into stackNames
   --
   return stackNames
end module_ListBehaviorStackNames

getprop module_BehaviorName
   put the module_Name of the target into mName
   put lcw_ConstructBehaviorName (mName) into bName
   return bName
end module_BehaviorName

getprop module_CreateBehaviorName
   put the module_BehaviorName of the target into mName
   replace "_View" with "_" in mName
   put mName & "Create" into bName
   return bName
end module_CreateBehaviorName

getprop module_DevBehaviorName
   put the module_BehaviorName of the target into mName
   put mName & "Dev" into bName
   return bName
end module_DevBehaviorName

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
   put view_GetTemplateObject (moduleName) into mObject
   
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


--> Module
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
   put lcw_ConstructBehaviorName (moduleName) into bName
   line_Delete bName, stackNames
   put word 1 to -1 of bName & CR & stackNames into stackNames
   
   return bObjects
end module_OrderedBehaviors


--> Module | Props
-
getprop module_Array
   put the module_JsonFile of the target into jsonFile
   put array_FromFile (jsonFile) into moduleArray
   return moduleArray
end module_Array

setprop module_Array moduleArray
   -- put the module_JsonFile of the target into jsonFile
   put the module_Name of the target into moduleName
   put the module_Folder of the target into moduleFolder
   if there is not a folder moduleFolder then return "Error, module_Folder does not exist for:" && the target
   --
   put module_ConstructJsonFile (moduleName, moduleFolder) into jsonFile
   
   if jsonFile is empty then return "Error, module_Folder does not exist for:" && the target
   array_ToFile jsonFile, moduleArray
   return jsonFile
   
   put the module_Folder of the target into moduleFolder
   if there is not a folder moduleFolder then return "Error, module folder does not exist for:" && the target
   project_StoreArray moduleFolder, moduleArray
   return moduleFolder
end module_Array

function module_GetArray moduleName
   -- put view_GetTemplateObject (moduleName) into moduleView
   if there is a stack moduleName then
      put the module_Array of stack moduleName into moduleArray
      return moduleArray
   else
      -- if exists (moduleView) is false then
      # Get from Env
      -- return "Error, module does not exists:" && moduleName
      put env_GetModuleArray() into envModuleArray
      put lcw_PipesToUnderscore (moduleName) into moduleFolderName
      put envModuleArray ["active"][moduleFolderName] into moduleArray
      return moduleArray
   end if
end module_GetArray

getprop module_JsonFile
   put the module_Name of the target into moduleName
   put the module_Folder of the target into moduleFolder
   if moduleFolder is empty then return empty
   --
   put module_JsonFile (moduleName, moduleFolder) into jsonFile
   return jsonFile
end module_JsonFile

function module_JsonFile moduleName, projectFolder
   put module_ConstructJsonFile (moduleName, projectFolder) into jsonFile
   if there is a file jsonFile then
      return jsonFile
   else
      return empty
   end if
end module_JsonFile

function module_ConstructJsonFile moduleStackName, projectFolder
   put lcw_PipesToUnderscore (moduleStackName) into shortModuleFolder
   put module_GetFolder (shortModuleFolder, projectFolder) into moduleFolder
   put moduleFolder & "lcw_project.json" into moduleJsonFile
   return moduleJsonFile
end module_ConstructJsonFile

getprop module_Name
   put the module_ShortFolder of the target into moduleName
   replace "_" with "|" in moduleName
   return moduleName
end module_Name


--> ProjectArray
-
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


--> Module | behavior
-
getprop module_Behavior [useDefault]
   breakpoint
   if useDefault is true then
      return the module_DefaultBehavior of the target
   else
      put the module_Behaviors of the target into bObjects
      return line 1 of bObjects
   end if
end module_Behavior

function module_GetBehaviorPath viewName, pBehaviorName
   if pBehaviorName is empty then
      put lcw_ConstructBehaviorName (viewName) into pBehaviorName
   end if
   
   put view_GetTemplateObject (viewName) into mObject
   if exists (mObject) is false then return empty
   --
   put the module_Folder of mObject into moduleFolder
   
   put folder_AddShort (moduleFolder, "behaviors") into bFolder
   put bFolder & pBehaviorName & ".livecodescript" into bPath
   return bPath
end module_GetBehaviorPath

function module_GetBehavior viewName, pBehaviorName
   put module_GetBehaviorPath (viewName, pBehaviorName) into bPath
   --
   if there is a stack bPath then
      return the long name of stack bPath
   else
      return empty
   end if
end module_GetBehavior

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


--> Module | Behavior
-
getprop module_DefaultBehavior
   put the module_BehaviorName of the target into bName
   if exists (stack bName) then
      return the name of stack bName
   else
      put the view_Name of the target into viewName
      if viewName is empty then return empty
      
      put module_Getbehavior (viewName) into bObject
      return bObject
   end if
end module_DefaultBehavior

function module_ConstructBehaviorPath viewName, moduleFolder, pShortFile
   put folder_AddShort (moduleFolder, "behaviors") into moduleBehaviorFolder
   put moduleBehaviorFolder & pShortFile into moduleControllerPath
   return moduleControllerPath
end module_ConstructBehaviorPath


--> Module | Behaviors
-
getprop module_DefaultHierarchy
   put the view_Name of the target into moduleName
   if moduleName is empty then return empty
   put revRuggedID (the target) into mObject
   
   # Names and stackPath
   put lcw_ConstructBehaviorName (moduleName) into defaultBehaviorName
   put the effective filename of stack moduleName into moduleStackPath
   
   # Module Behavior Folder
   put project_FolderFromPath (moduleStackPath) into projectFolder
   put module_GetBehaviorFolder (moduleName, projectFolder) into moduleBehaviorFolder
   if there is not a folder moduleBehaviorFolder then return empty
   
   # Init bStackObjects with mObject
   put mObject & CR into bStackObjects
   if exists (stack defaultBehaviorName) then
      put the name of stack defaultBehaviorName into defaultBehaviorObject
      put defaultBehaviorObject & CR after bStackObjects
   end if
   
   # Repeat shortfiles
   put the defaultfolder into oFolder
   set the defaultfolder to moduleBehaviorFolder
   put the files into shortFiles
   repeat for each line shortFile in shortFiles
      put moduleBehaviorFolder & shortFile into bFilePath
      if there is a stack bFilePath then
         put the name of stack bFilePath into bStackObject
         if the short name of bStackObject = defaultBehaviorName then
            next repeat
         else
            put bStackObject & CR after bStackObjects
         end if
      end if
   end repeat
   delete char -1 of bStackObjects
   set the defaultfolder to oFolder
   
   return bStackObjects   
end module_DefaultHierarchy

function module_ConstructBehaviorShortFile moduleStackName
   put lcw_ConstructBehaviorName (moduleStackName) & ".livecodescript" into shortFile  
   return shortFile
end module_ConstructBehaviorShortFile

function module_ConstructBehaviorName viewName
   return lcw_ConstructBehaviorName (stackName)
end module_ConstructBehaviorName

function module_GetBehaviorStackPath behaviorStackName, rootModuleFolder
   put behaviorStackName & ".livecodescript" into shortBehaviorPath
   put rootModuleFolder & "behaviors/" & shortBehaviorPath into moduleBehaviorStackPath
   return moduleBehaviorStackPath
end module_GetBehaviorStackPath

getprop module_StackPaths
   put the module_Folder of the target into moduleFolder
   put directory_ListNestedPaths (moduleFolder) into stackPaths
   return stackPaths
end module_StackPaths

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


--> Views
-
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


--> Props
-
getprop is_Module
   put the module_Folder of the target into mFolder -- lib_LCW
   return mFolder is not empty
end is_Module


--> Props | Module | Behavior
-
getprop module_BehaviorDepKeys   
   # List module dependency Hkeys
   put the module_BehaviorDepHkeyArray of the target into hKeyArray
   put array_ListKeys (hkeyArray) into hKeys
   
   # Filter out all module objects
   put the module_Objects of the target into mObjects
   repeat for each line mObject in mObjects
      filter hKeys without ("*" && mObject)
   end repeat
   return hKeys
end module_BehaviorDepKeys


--> Props | Module
-
getprop module_BehaviorPaths
   put the module_Folder of the target into moduleFolder
   put moduleFolder & "behaviors/" into moduleBehaviorFolder
   put folder_ListStackPaths (moduleBehaviorFolder) into stackPaths
   return stackPaths
end module_BehaviorPaths


--> Module | Name and Short Folder
-
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


--> Project
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


--> Module | Ojects
-
function module_GetTemplateObject moduleName, pProjectFolder
   put module_ConstructHomeStackPath (moduleName, pProjectFolder) into moduleHomeStackPath
   if exists (control 1 of cd 1 of stack moduleHomeStackPath) is false then return empty
   --
   put the long id of control 1 of cd 1 of stack moduleHomeStackPath into moduleView
   return moduleView
end module_GetTemplateObject


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


--> Private
-
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
