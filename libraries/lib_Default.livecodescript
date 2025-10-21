script "lib_Default"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Default
type: library
version: 0.2


--> Variables
-
local Node_ModulesFolder
local Wiki_ModulesFolder


--> Working on
-


--> Module | Behavior
-
function default_ConstructBehaviorName stackName
   return label_BehaviorName (stackName)
end default_ConstructBehaviorName

function default_BehaviorNameFromShortFolder shortFolder
   put "behavior_" into bName
   --
   set the itemdelimiter to "_"
   if item 1 of shortFolder = "View" then delete item 1 of shortFolder -- new
   repeat for each item sBit in shortFolder
      replace space with empty in sBit -- should be one world
      put text_InitialCaps (sBit) after bName
   end repeat
   return bName
end default_BehaviorNameFromShortFolder

getprop default_ModuleBehaviorName
   put the module_Name of the target into mName
   put label_BehaviorName (mName) into bName
   return bName
end default_ModuleBehaviorName

getprop default_Behavior
   put the default_ModuleBehaviorName of the target into bName
   if exists (stack bName) then return the name of stack bName
   
   -- put the view_Name of the target into vName
   put the short name of the defaultstack into vName
   if vName is empty then return empty
   put default_ModuleBehavior (vName) into bObject
   return bObject
end default_Behavior

function default_ModuleBehavior viewName, pBehaviorName
   put module_GetBehaviorPath (viewName, pBehaviorName) into bPath
   --
   if there is a stack bPath then
      return the long name of stack bPath
   else
      return empty
   end if
end default_ModuleBehavior

function module_GetBehaviorPath viewName, pBehaviorName
   if exists (stack viewName) is false then return empty
   if pBehaviorName is empty then
      put label_BehaviorName (viewName) into pBehaviorName
   end if
   
   -- put default_FirstStackControl (viewName) into mObject
   -- if exists (mObject) is false then return empty
   -- put the module_Folder of mObject into moduleFolder
   --
   put the module_Folder of stack viewName into moduleFolder
   --
   put folder_AddShort (moduleFolder, "behaviors") into bFolder
   put bFolder & pBehaviorName & ".livecodescript" into bPath
   return bPath
end module_GetBehaviorPath

getprop default_ModuleView
   -- use "module_Object"
   -- sounds like "module_View" and is a bit confusing
   return the module_Object of the target
end default_ModuleView

getprop module_Object
   -- was template_Object, view_ModuleObject
   -- there are many views but only one object
   put the view_Name of the target into vName
   if exists (stack vName) is false then return empty
   put module_GetObject (vName) into mObject
   return mObject
end module_Object

function module_GetObject vName
   -- was "view_GetModuleOject" or "view_ModuleObject" or "module_GetTemplateObject"
   view_NormalizeName vName
   if exists (stack vName) is false then return empty
   put the module_View of cd 1 of stack vName into moduleView
   if exists (moduleView) then
      return moduleView
   else
      return default_FirstStackControl (vName)
   end if
end module_GetObject

function default_FirstStackControl viewName
   view_NormalizeName viewName
   put stack_FirstControl (viewName) into mObject
   return mObject
end default_FirstStackControl


--> Props
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
      put the module_MenuTitles of stack stackName into mTitles
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

getprop default_ModuleBehaviorNames
   put the default_ModuleBehaviors of the target into bObjects
   repeat for each line bObject in bObjects
      put the short name of bObject into bName
      put bName & CR after bNames
   end repeat
   delete char -1 of bNames
   return bNames
end default_ModuleBehaviorNames

getprop default_ModuleBehaviors
   local bStackObjects
   
   put the view_Name of the target into moduleName
   if moduleName is empty then return empty
   put revRuggedID (the target) into mObject
   
   # Names and stackPath
   put label_BehaviorName (moduleName) into defaultBehaviorName
   put the effective filename of stack moduleName into moduleStackPath
   
   # Module Behavior Folder
   put project_FolderFromPath (moduleStackPath) into projectFolder
   put module_GetBehaviorFolder (moduleName, projectFolder) into moduleBehaviorFolder
   if there is not a folder moduleBehaviorFolder then return empty
   
   # Init bStackObjects with mObject
   -- put mObject & CR into bStackObjects
   if exists (stack defaultBehaviorName) then
      put the name of stack defaultBehaviorName into defaultBehaviorObject
      put defaultBehaviorObject & CR after bStackObjects
   end if
   
   # Not these
   put defaultBehaviorName into notThese
   put the card_Object of the target into cObject
   put the behavior of cObject into bObject
   if exists (bObject) then
      put comma & the short name of bObject after notThese
   end if
   put the behavior of stack moduleName into bObject
   if exists (bObject) then
      put comma & the short name of bObject after notThese
   end if
   
   
   # Repeat shortfiles
   put the defaultfolder into oFolder
   set the defaultfolder to moduleBehaviorFolder
   put the files into shortFiles
   repeat for each line shortFile in shortFiles
      put moduleBehaviorFolder & shortFile into bFilePath
      if there is a stack bFilePath then
         put the name of stack bFilePath into bStackObject
         put the short name of bStackObject into bName
         
         -- if bName = defaultBehaviorName then
         if bName is among the items of notThese then
            next repeat
         else
            put bStackObject & CR after bStackObjects
         end if
      end if
   end repeat
   delete char -1 of bStackObjects
   set the defaultfolder to oFolder
   
   return bStackObjects   
end default_ModuleBehaviors

getprop stackFile_DepArray [pUseTarget]
   put the stackFile_Root of the target into stackRoot
   put the stackFile_Array of the target into sArray
   put the short name of the defaultstack into stackName
   
   -- put the behavior_IndexArray of the target into bIndexArray
   put the behavior_IndexArray of stack stackName into bIndexArray
   put bIndexArray into depArray ["behavior_IndexArray"]
   
   # Use target stack
   if pUseTarget is not false then
      put empty into depArray ["dep_UsedNames"][stackName]
   end if
   
   set the itemdelimiter to "_"
   delete variable sArray [stackName]
   repeat for each key sName in sArray
      put sArray [sName] into relPath
      put file_FromRelative (relPath, stackRoot) into stackPath
      --
      switch item 1 of sName
         case "model"
         case "lib"
            if exists (stack stackPath) then
               -- put empty into depArray ["dep_UsedPaths"][relPath]
               put empty into depArray ["dep_UsedNames"][sName]
            else
               breakpoint
            end if
            break
         case "be"
         case "behavior"
            -- put empty into depArray ["behavior_StackPaths"][relPath]
            put empty into depArray ["behavior_StackNames"][sName]
            break
         default
            if exists (stack stackPath) then
               -- put empty into depArray ["dep_MenuPaths"][relPath]
               put empty into depArray ["dep_MenuNames"][sName]
            else
               breakpoint
            end if
      end switch 
   end repeat
   return depArray
end stackFile_DepArray

function wikiFolder_FromRouter wikiDomain
   put wikiGarden_GetDomainData() into gardenDomainData
   put gardenDomainData [wikiDomain]["folder"] into gardenWikiFolder
   
   if gardenWikiFolder is empty then -- defaults to farm
      put wikiFolder_ConstructFromFarm (wikiDomain) into wikiFolder
      return wikiFolder
   else
      return gardenWikiFolder
   end if
end wikiFolder_FromRouter


--> WikiFolder | Modules
-
function wikiFolder_Modules
   if Wiki_ModulesFolder is empty then
      -- it's inside the node modules /wiki/node-modules" folder
      put node_GetModulesFolder() into nodeModulesFolder   
      put nodeModulesFolder & "wiki/node_modules/" into wikiModulesFolder
      --
      put wikiModulesFolder into Wiki_ModulesFolder
      --
      if there is not a folder wikiModulesFolder then
         return "Error, folder" && wikiModulesFolder && "does not exist"
      end if
   end if
   
   return Wiki_ModulesFolder
end wikiFolder_Modules

function wikiFolder_ConstructAssets wDomain, pShortFolder
   put wikiFolder_SimpleGet (wDomain) into wikiFolder
   --
   put wikiFolder & "assets/" into assetsFolder
   if pShortFolder is not empty then
      if char -1 of pShortFolder is not slash then
         put slash after pShortFolder
      end if
      put pShortFolder after assetsFolder
   end if
   return assetsFolder
end wikiFolder_ConstructAssets

function wikiFolder_SimpleGet wDomain
   if wDomain = "localhost" then
      put wikiFolder_LocalHost() into wikiFolder
   else
      put wikiFolder_FromRouter (wDomain) into wikiFolder
   end if
   return wikiFolder
end wikiFolder_SimpleGet


--> WikiFolder | FromRouter
-
function wikiFolder_Get wikiDomain
   put wikiFolder_FromRouter (wikiDomain) into wikiFolder
   if there is a folder wikiFolder then 
      return wikiFolder
   else
      return empty
   end if
end wikiFolder_Get

function wikiFolder_ConstructFromFarm wikiDomain
   put ecoData_GetFarmFolder() into wikiFarm
   if there is not a folder wikiFarm then
      put default_FarmFolder() into wikiFarm
   end if
   
   put wikiFarm & wikiDomain & slash into wikiFolder
   return wikiFolder
end wikiFolder_ConstructFromFarm


--> Default | FarmFolder
-
/*
This is the fallback for restarting and reconstituting the routing table. 
Saved in the ecodata project array.*/

function default_FarmFolder
   -- see "ecoData_GetFarmFolder"
   put wikiGarden_GetModel() into ecoData
   put ecoData ["Farm"]["folder"] into farmFolder
   --
   file_AddHome farmFolder
   return farmFolder
end default_FarmFolder

command wikiFarm_SetDefaultFolder farmFolder
   if there is not a folder farmFolder then
      return "Error, farm folder does not exist:" && farmFolder
   end if
   file_StripHome farmFolder
   
   put wikiGarden_GetModel() into ecoData
   put farmFolder into ecoData ["Farm"]["folder"]
   wikiGarden_SetModel ecoData
   --
   return ecoData
end wikiFarm_SetDefaultFolder


--> Nvm & Node | Paths
-
function node_GetModulesFolder pUseNpm
   if Node_ModulesFolder is empty then
      # Node version
      if pUseNpm is true then
         put line 1 of shell ("npm root -g") & "/" into nodeModulesFolder
      else
         # NVM version
         set the itemdelimiter to slash
         put nvm_GetBin() into nodeModulesFolder
         put "lib/node_modules/" into item -1 of nodeModulesFolder
      end if
      --
      put nodeModulesFolder into Node_ModulesFolder
      --
      if there is not a folder nodeModulesFolder then
         return "Error, folder" && nodeModulesFolder && "does not exist"
      end if
   end if
   
   return Node_ModulesFolder
end node_GetModulesFolder

function node_WikiModulesFolder
   put node_GetModulesFolder() & "wiki/node_modules/" into wikiModulesFolder
   return wikiModulesFolder
end node_WikiModulesFolder

function node_GetNodeBinaryPath
   return line 1 of shell ("npm bin -g") & "/npm"
end node_GetNodeBinaryPath

function nvm_Directory
   return shell ("source ~/.zshrc; echo $NVM_DIR")
end nvm_Directory

function nvm_GetBin
   -- put "/Users/david/.nvm/versions/node/v21.0.0/bin/" before wikiBinFile
   get shell ("source ~/.zshrc; echo $NVM_BIN")
   return word 1 to -1 of line 1 of it
end nvm_GetBin


--> Default
-
getprop default_ModuleObject
   -- Lazy default
   put the view_Name of the target into mName
   if exists (stack mName) is false then return empty
   
   put default_FirstStackControl (mName) into mObject
   return mObject   
end default_ModuleObject

getprop default_MenuTitle
   put the module_Object of the target into tObject
   if exists (tObject) is false then return empty
   
   put default_ModuleMenuTitle (tObject) into mTitle
   return mTitle
end default_MenuTitle

getprop default_ModuleName
   /* complicated
   Take from the path (ie filename) of the target
   Uses env_GetLcwFolder() and extracts module short folder.
   Use this default to set the module_MenuName
   */
   
   put the module_Object of the target into tObject
   if exists (tObject) is false then return empty
   
   put the effective filename of the defaultstack into sPath
   put default_ModuleNameFromFolder (sPath) into mName
   put the view_Name of tObject into mName
   return mName
end default_ModuleName

function default_ModuleNameFromFolder sPath
   put module_ConstructShortFolder (sPath) into moduleName
   replace "_" with "|" in moduleName
   return moduleName
end default_ModuleNameFromFolder

function default_ProjectMenuTitle tObject, pMenuBit
   if menu_IsGlobal (pMenuBit) then return menuBit
   
   put the project_Name of tObject into projectName
   if projectName is empty then
      put the view_Name of tObject into projectName
   end if
   if projectName is empty then return empty
   
   if pMenuBit is empty then
      put projectName into vName
   else
      put projectName & "|" & pMenuBit into vName
   end if
   
   put default_ConstructMenuTitle (vName) into mTitle
   return mTitle   
end default_ProjectMenuTitle

function default_ModuleMenuTitle tObject, pMenuBit
   if menu_IsGlobal (pMenuBit) then return menuBit
   
   put the module_Name of tObject into moduleName
   if moduleName is empty then
      put the view_Name of tObject into moduleName
   end if
   if moduleName is empty then return empty
   
   if pMenuBit is empty then
      put moduleName into vName
   else
      put moduleName & "|" & pMenuBit into vName
   end if
   
   put default_ConstructMenuTitle (vName) into mTitle
   return mTitle   
end default_ModuleMenuTitle


--> Working on
-
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

getprop module_MenuTitle
   put the short name of the defaultstack into mName
   if mName is empty then return empty
   put default_ConstructMenuTitle (mName, true) into mTitle
   return mTitle
end module_MenuTitle

getprop module_MenuTitle [menuBit]
   -- another way?
   if menu_IsGlobal (menuBit) then return menuBit
   put the module_Name of the target into moduleName
   if moduleName is empty then
      put the view_Name of the target into vName
   end if
   if moduleName is empty then return empty
   if menuBit is empty then
      put moduleName into vName
   else
      put moduleName & "|" & menuBit into vName
   end if
   put default_ConstructMenuTitle (vName) into mTitle
   return mTitle
end module_MenuTitle


--> Deps
-
getprop stackfile_Array
   put the stackfiles of the defaultstack into stackFileArray
   split stackFileArray by CR and comma
   return stackFileArray
end stackfile_Array

getprop stackFile_Root
   put the filename of the defaultstack into stackRoot
   set the itemdelimiter to slash
   put empty into item -1 of stackRoot
   return stackRoot
end stackFile_Root

function stackFile_ConstructFileIndex stackFileTable, stackFile
   put folder_Above (stackFile) into stackRoot
   put stackFile into longFileNames
   repeat for each line stackFileLine in stackFileTable
      delete item 1 of stackFileLine
      put file_FromRelative (stackFileLine, stackRoot) into newLine
      if newLine is not among the lines of longFileNames then
         put return & newLine after longFileNames
      end if
   end repeat
   return longFileNames
end stackFile_ConstructFileIndex

function file_FromRelative relPath, relRoot
   if last char of relRoot is "/" then delete last char of relRoot
   set the itemdelimiter to "/"
   repeat while item 1 of relPath is ".."
      delete item 1 of relPath
      delete last item of relRoot
   end repeat
   return relRoot & "/" & relPath
end file_FromRelative
