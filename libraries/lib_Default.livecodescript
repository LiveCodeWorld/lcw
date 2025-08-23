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
--
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

getprop view_ModuleObject [pWithDefault]
   put the view_Name of the target into mName
   
   put default_ModuleView (mName) into mObject
   if exists (mObject) then
      return mObject
   else
      -- return default_FirstStackControl (mName)
      return empty
   end if
end view_ModuleObject

getprop module_Object
   -- was template_Object, view_ModuleObject
   put the view_Name of the target into moduleName
   -- put the module_Name of the target into moduleName
   if exists (stack moduleName) is false then return empty
   
   -- put module_GetTemplateObject (moduleName) into mObject
   put the module_View of stack moduleName into mObject
   if exists (mObject) then return mObject
   
   put default_FirstStackControl (moduleName) into mObject
   return mObject
end module_Object

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
function wikiFile_ConstructLocalHost pSlug
   put wikiFolder_ConstructLocalPages() into localPagesFolder
   if there is not a folder localPagesFolder then return empty
   
   put localPagesFolder & pSlug into pageJsonFile
   return pageJsonFile
end wikiFile_ConstructLocalHost


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
      put wikiFolder_GetLocalHost() into wikiFolder
   else
      put wikiFolder_FromRouter (wDomain) into wikiFolder
   end if
   return wikiFolder
end wikiFolder_SimpleGet

function wikiFolder_GetLocalHost
   -- there are many :(
   put the home folder & "/.wiki/localhost/" into localHostFolder
   if there is a folder localHostFolder then
      return localHostFolder
   else
      return empty
   end if
end wikiFolder_GetLocalHost


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

function wikiFolder_ConstructLocalHost
   put default_FarmFolder() into farmFolder
   put farmFolder & "localhost/" into localHostFolder
   return localHostFolder
end wikiFolder_ConstructLocalHost

function wikiFolder_FindLocalHost ecoFolder, farmFolder
   -- from folders (assume arrays are broken)
   -- simply check for existance of "localhost" folder
   if there is not a folder ecoFolder then return "Error, ecofolder does not exist:" && ecoFolder
   
   # farmFolder
   put default_FarmFolder() into farmFolder
   if there is not a folder farmFolder then return "Error, farmFolder does not exist:" && farmFolder
   if char -1 of farmFolder is not slash then
      put slash after farmFolder
   end if
   file_AddHome farmFolder
   
   put farmFolder & "localhost/" into localHostFolder
   if there is a folder localHostFolder then return localHostFolder
   
   put folder_ListShort (ecoFolder) into gardenNames
   repeat for each line gardenName in gardenNames
      put ecoFolder & gardenName & slash into testFarmFolder
      put testFarmFolder & "localhost/" into localHostFolder
      if there is a folder localHostFolder then
         return localHostFolder
      end if
   end repeat
   return empty
end wikiFolder_FindLocalHost


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
   put module_GetBehavior (vName) into bObject
   return bObject
end default_Behavior

getprop default_ModuleObject
   -- Lazy default
   put the view_Name of the target into mName
   if exists (stack mName) is false then return empty
   
   put default_FirstStackControl (mName) into mObject
   return mObject   
end default_ModuleObject

function default_ModuleView viewName
   view_NormalizeName viewName
   if exists (stack viewName) is false then return empty
   put the module_View of cd 1 of stack viewName into moduleView
   if exists (moduleView) then
      return moduleView
   else
      return empty
   end if
end default_ModuleView

function default_FirstStackControl viewName
   view_NormalizeName viewName
   put stack_FirstControl (viewName) into mObject
   return mObject
end default_FirstStackControl

getprop default_MenuTitle
   -- put the view_ModuleObject of the target into tObject
   put the view_ModuleObject of the target into tObject
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
   
   put the view_ModuleObject of the target into tObject
   put the view_ModuleObject of the target into tObject
   if exists (tObject) is false then return empty
   
   put the effective filename of the defaultstack into sPath
   put module_NameFromPath (sPath) into mName
   put the view_Name of tObject into mName
   return mName
end default_ModuleName

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
   
   put menu_ConstructTitle (vName) into mTitle
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
   
   put menu_ConstructTitle (vName) into mTitle
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
   put menu_ConstructTitle (mName, true) into mTitle
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
   put menu_ConstructTitle (vName) into mTitle
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
