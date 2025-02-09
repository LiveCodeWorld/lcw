script "model_Environment"
--> MetaData
-
license: GPLv3
name: model_Environment
type: model
version: 0.7

/*
An environment contains a list of projects that need to be loaded 
together with and data that the environment may need either loaded into memory or stored on disk.

For instance an environment will typically contain a data stored in a global which determines how LCW Menus are created.
This data needs to be loaded into the enviroment from individual projects.
Therefore this model contains handlers that can load and merge multiple projects, 
providing access to scripts that need it and instructions how to build it from individual projects.

As handlers that work on a set of projects, stroing these in the global vairable gLCW,  we should rename these handlers "env_XXX"
*/

--> Working on
-
/*
The following is a bit of a mess - wether to use the library models
There is the global on - env_GetActiveProjectArray() 
and library_FetchProjectData() -- uses lcw_FetchArray ("lcw_ProjectDataLibrary.array") which is stored in the lcw project.
It's all a bit of a mess - tryig to move over to listing project folder names where possible
-- consider replacing with "env_ListProjectFolders()"
*/

command env_GoToStart
   put pref_FetchValue ("lcwFolder") into lcwFolder
   put env_FetchProjectStartName() into projectName
   --
   put env_ConstructHomePath (projectName, lcwFolder) into homePath
   go to stack homePath
   return homePath 
end env_GoToStart

getprop env_RepoFolder [pShortRepoFolder]
   set the itemdelimiter to slash
   put the project_Folder of target into repoFolder
   delete item -1 of repoFolder
   --
   if pShortRepoFolder is not empty then
      put pShortRepoFolder after repoFolder
   end if
   return repoFolder
end env_RepoFolder

function env_GetRepoFolder pShortRepoFolder
   put env_GetLcwFolder() into repoFolder
   --
   set the itemdelimiter to slash
   delete item -1 of repoFolder
   --
   if pShortRepoFolder is not empty then
      text_AddTrailing pShortRepoFolder, slash
      put pShortRepoFolder after repoFolder
   end if
   return repoFolder
end env_GetRepoFolder

function env_GetLcwFolder
   global gLCW
   put "lcwFolder" into prefName
   --
   put pref_GetValue (prefName) into lcwFolder
   if lcwFolder is not empty then return lcwFolder
   
   put pref_FetchValue (prefName) into lcwFolder
   return lcwFolder
end env_GetLcwFolder

command env_SetLcwFolder pLcwFolder
   if pLcwFolder is empty then
      put the stack_Folder of stack "LCW" into pLcwFolder
      if pLcwFolder is empty then
         breakpoint -- not saved yet
         exit to top
      end if
   end if
   --
   pref_SaveValue "lcwFolder", pLcwFolder
   put the result into prefData
   return prefData
end env_SetLcwFolder

function env_FetchProjectStartName
   put pref_FetchValue ("Name of project to start") into projectName
   return projectName
end env_FetchProjectStartName

command env_SaveProjectStartName projectName
   pref_SaveValue "Name of project to start", projectName
end env_SaveProjectStartName

command env_AddToBash
   shell_AddBashProfileToPath
   /*
   -- put "/usr/bin:/bin:/usr/sbin:/sbin:/opt/local/bin" into $PATH
   if the platform = "MacOS" then -- and it is recent ???
      put url "file:/etc/paths" into systemPaths
      if systemPaths is empty then return empty
      
      put token 1 to -1 of systemPaths into systemPathArray
      
      put $PATH into revPATH
      replace ":" with CR in revPATH
      put systemPathArray & CR & revPATH into combinedPath
      sort combinedPath
      put token 1 to -1 of combinedPath into combinedPath
      split combinedPath with CR and ":"
      put keys (combinedPath) into newPathIndex
      replace CR with ":" in newPathIndex
      put newPathIndex into $PATH
   end if
   */
   return $PATH
end env_AddToBash


--> Env | Model
-
function env_GetShortModuleArray pModuleNames
   -- different from env_GetModuleArray
   -- add "default"" to names to protect array overwriting
   
   if pModuleNames is empty then
      put env_ListShortModuleFolders() into pModuleNames
   end if
   --
   set the itemdelimiter to "_"
   repeat for each line moduleName in pModuleNames
      put moduleName into aKey
      split aKey by "_"
      
      get pModuleNames
      filter it with (moduleName & "_*")
      if it is empty then
         put "" into moduleArray [aKey]
      else
         put "" into moduleArray [aKey]["Default"]
      end if
   end repeat
   return moduleArray
end env_GetShortModuleArray

function env_GetModuleArray pProjectNames
   _SetProjectNames pProjectNames
   set the itemdelimiter to slash
   repeat for each line projectName in pProjectNames
      put project_ListModuleFolders (projectName) into moduleFolders
      repeat for each line moduleFolder in moduleFolders
         put item -1 of moduleFolder into moduleName
         --
         put project_PathFromFolder (moduleFolder) into moduleHomeStackPath
         if exists (stack moduleHomeStackPath) is false then
            put projectName into envModuleArray ["broken"][moduleName]["projectName"]
            put moduleFolder into envModuleArray ["broken"][moduleName]["moduleFolder"]
            put moduleHomeStackPath into envModuleArray ["broken"][moduleName]["homeStackPath"]
         else
            put projectName into envModuleArray ["active"][moduleName]["projectName"]
            put moduleFolder into envModuleArray ["active"][moduleName]["moduleFolder"]
            put moduleHomeStackPath into envModuleArray ["active"][moduleName]["homeStackPath"]
            --
            put projectName into envModuleArray ["lists"]["homeStackPaths"][moduleHomeStackPath]
         end if
      end repeat
   end repeat
   return envModuleArray
end env_GetModuleArray


--> Environment | Files
-
function env_ListLibraryStacks
   -- not in any particular order (so not a real hierarchy)
   local objectIndex
   
   put env_ListActiveProjects() into projectNames
   repeat for each line projectName in projectNames
      hkey_AddDevelopmentHierarchy objectIndex, projectName
   end repeat
   return word 1 to -1 of objectIndex
end env_ListLibraryStacks

function env_ListHomeArrayFiles
   put env_GetHomeArrayFileData() into envProjectArrayFileArray
   put envProjectArrayFileArray ["projectArrayFiles"] into projectArrayFiles
   return projectArrayFiles 
end env_ListHomeArrayFiles

function env_GetHomeArrayFileData
   put library_ListProjectNames() into projectNames
   repeat for each line projectName in projectNames
      put project_GetArrayFile (projectName) into projectArrayFile
      if there is a file projectArrayFile then
         put projectArrayFile into envProjectArrayFileArray ["projectNames"][projectName]
         put projectName into envProjectArrayFileArray ["projectArrayFiles"][projectArrayFile]
      end if
   end repeat
   return envProjectArrayFileArray
end env_GetHomeArrayFileData


--> Environment | List
-
function env_ScriptHierarchy pRemoveTransportBehavior
   put env_ListFrontScripts() into frontObjects
   -- _RemoveTransporterTools frontObjects, pRemoveTransportBehavior
   --
   put env_ListBackScripts() into backObjects
   put stack_PathsToObjects (the stacksinUse) into usedStacks
   --
   object_AddBehaviors usedStacks
   object_AddBehaviors frontObjects
   object_AddBehaviors backObjects
   --
   if usedStacks is not empty then put usedStacks into scriptHierarchy
   if backObjects is not empty then put backObjects & CR before scriptHierarchy
   if frontObjects is not empty then put CR & frontObjects after scriptHierarchy
   --
   return scriptHierarchy
end env_ScriptHierarchy

function env_ListBackScripts
   -- /Applications/LiveCode Community 8.1.0 (dp 3).app/Contents/Tools/Toolset/libraries/revshortcutslibrary.livecodescript
   put the backscripts into longIDs
   ide_FilterOutStacks longIDs
   return longIDs
end env_ListBackScripts

function env_ListFrontScripts
   -- /Applications/LiveCode Community 8.1.0 (dp 3).app/Contents/Tools/Toolset/libraries/revshortcutslibrary.livecodescript
   put the frontscripts into longIDs
   ide_FilterOutStacks longIDs
   return longIDs
end env_ListFrontScripts


--> Environment | List
-
function env_ListControllerStackNames pProjectNames
   put env_ListControllerPaths (pProjectNames) into activeControllerPaths
   put stack_PathsToNames (activeControllerPaths) into stackNames
   sort stackNames
   return stackNames
end env_ListControllerStackNames

function env_ListControllerPaths pProjectNames, pRepoFolder
   _SetProjectNames pProjectNames
   repeat for each line projectName in pProjectNames
      put project_ListStandardStackPaths ("controllers", projectName) into projectControllerPaths
      
      if projectControllerPaths is not empty then
         put projectControllerPaths & CR after environmentControllerPaths
      end if
      
      put project_ListModuleShortFolders (projectName) into moduleNames
      repeat for each line moduleName in moduleNames
         put module_ListControllerStackNames (moduleName, projectFolder) into moduleControllerPaths
         if moduleControllerPaths is not empty then
            put moduleControllerPaths & CR after environmentControllerPaths
         end if
      end repeat
   end repeat
   delete char -1 of environmentControllerPaths
   sort environmentControllerPaths
   return word 1 to -1 of environmentControllerPaths
end env_ListControllerPaths

function env_ListBehaviorStackNames pProjectNames
   put env_ListBehaviorPaths (pProjectNames) into environmentBehaviorPaths
   put stack_PathsToNames (environmentBehaviorPaths) into stackNames
   sort stackNames
   return stackNames
end env_ListBehaviorStackNames

function env_ListIdeBehaviorStackNames
   put env_ListBehaviorPaths() into bPaths
   set the itemdelimiter to slash
   repeat for each line bPath in bPaths
      if exists (stack bPath) is false then next repeat
      if item -1 of bPath begins with "behavior_Ide" then
         put the short name of stack bPath into bName
         put bName & CR after bNames
      end if
   end repeat
   delete char -1 of bNames
   return bNames
end env_ListIdeBehaviorStackNames

function env_ListBehaviorPaths pProjectNames, pRepoFolder
   _SetProjectNames pProjectNames
   repeat for each line projectName in pProjectNames
      -- put library_FetchProjectFolder (projectName) into projectFolder
      put env_ConstructProjectFolder (projectName, pRepoFolder) into projectFolder
      --
      put project_ListPathsOfType ("behaviors", projectFolder) into projectBehaviorPaths
      if projectBehaviorPaths is not empty then
         put projectBehaviorPaths & CR after environmentBehaviorPaths
      end if
      
      put project_ListModuleShortFolders (projectName) into moduleNames
      repeat for each line moduleName in moduleNames
         put module_ListBehaviorStackNames (moduleName, projectFolder) into moduleBehaviorPaths
         if moduleBehaviorPaths is not empty then 
            put moduleBehaviorPaths & CR after environmentBehaviorPaths
         end if
      end repeat
   end repeat
   delete char -1 of environmentBehaviorPaths
   sort environmentBehaviorPaths
   return word 1 to -1 of environmentBehaviorPaths
end env_ListBehaviorPaths

function env_ListViewStackNames pProjectNames
   put env_ListViewStackPaths (pProjectNames) into stackPaths
   put stack_PathsToNames (stackPaths) into stackNames
   return stackNames
end env_ListViewStackNames

function env_ListViewStackPaths pProjectNames
   _SetProjectNames pProjectNames
   repeat for each line projectName in pProjectNames
      put project_ListViewPaths (projectName) into stackPaths
      if stackPaths is not empty then
         put stackPaths & CR after envViewStackPaths
      end if
   end repeat
   sort envViewStackPaths
   return word 1 to -1 of envViewStackPaths
end env_ListViewStackPaths

function env_ListUsedStackNames pProjectNames
   put env_ListUsedStackPaths (pProjectNames) into stackPaths
   put stack_PathsToNames (stackPaths) into stackNames
   sort stackNames
   return stackNames
end env_ListUsedStackNames

function env_ListModuleHomeStackNames pProjectNames
   -- searches folders
   -- see : put library_ListProjectModules() into stackNames for extracting from global project array
   put env_ListModuleHomeStackPaths (pProjectNames) into stackPaths
   put stack_PathsToNames (stackPaths) into stackNames
   sort stackNames
   return stackNames
end env_ListModuleHomeStackNames

function env_ListModuleHomeStackPaths pProjectNames
   local activeStackPaths
   put env_GetModuleArray (pProjectNames) into envModuleArray
   put envModuleArray ["lists"]["homeStackPaths"] into homeStackPathArray
   put the keys of homeStackPathArray into homeStackPaths
   sort homeStackPaths
   return homeStackPaths
end env_ListModuleHomeStackPaths

function env_ListShortModuleFolders pProjectNames
   put env_GetModuleArray (pProjectNames) into envModuleArray
   put envModuleArray ["active"] into activeModuleArray
   put the keys of activeModuleArray into activeModuleNames
   sort activeModuleNames
   return activeModuleNames
end env_ListShortModuleFolders


--> Env | Export
-
command env_ExportAndIndexProjects pProjectNames
   if pProjectNames is empty then put library_ListProjectNames() into pProjectNames
   ide_LoadDictionaryTerms
   repeat for each line projectName in pProjectNames
      -- this add to global placeArray
      env_ExportAndIndexProject projectName
   end repeat
   env_ReLoadMenus pProjectNames
end env_ExportAndIndexProjects

command env_CreateNewPlaceArray pStackPaths
   if pStackPaths is empty then put env_ListUsedStackPaths() into pStackPaths
   
   local hkeyPlaceArray
   repeat for each line stackPath in pStackPaths
      set the cursor to busy
      put the long id of of stack stackPath into stackObject
      hkeyline_AddPlaceObject hkeyPlaceArray, stackObject
   end repeat
   script_StoreHkeyPlaceArray hkeyPlaceArray
   return hkeyPlaceArray
end env_CreateNewPlaceArray

command env_ExportAndIndexProject projectName, pRepoFolder
   local bigPlaceArray
   -- put library_FetchProjectFolder (projectName) into projectFolder
   put env_ConstructProjectFolder (projectName, pRepoFolder) into projectFolder
   --
   put project_ListAllStackPaths (projectFolder) into stackPaths
   repeat for each line stackPath in stackPaths
      set the cursor to watch
      put the name of stack stackPath into stackObject
      script_ExportHandlersAndCalls stackObject, true
      put the result into placeArray
      union bigPlaceArray with placeArray recursively
   end repeat
   return bigPlaceArray
end env_ExportAndIndexProject

command env_ReLoadMenus pProjectNames, pRepoFolder
   if pProjectNames is empty then
      put library_ListProjectNames() into pProjectNames
   else
      replace comma with CR in pProjectNames
   end if
   repeat for each line projectName in pProjectNames
      -- put library_FetchProjectFolder (projectName) into projectFolder
      put env_ConstructProjectFolder (projectName, pRepoFolder) into projectFolder
      --
      if there is not a folder projectFolder then next repeat
      project_LoadMenus projectFolder
   end repeat
end env_ReLoadMenus

function env_ListUsedStackPaths pProjectNames
   _SetProjectNames pProjectNames
   repeat for each line projectName in pProjectNames
      put env_ConstructHomePath (projectName) into homeStackPath
      if exists (stack homeStackPath) is false then next repeat
      --
      put the project_UsedStackPaths of stack homeStackPath into stackPaths
      if stackPaths is not empty then
         put stackPaths & CR after envUsedStackPaths
      end if
   end repeat
   sort envUsedStackPaths
   return word 1 to -1 of envUsedStackPaths
end env_ListUsedStackPaths


--> Private
-
private command _SetProjectNames @pProjectNames
   switch pProjectNames
      case "all"
      case empty
         put env_ListActiveProjects() into pProjectNames
         break
      default
         replace comma with CR in pProjectNames
   end switch
end _SetProjectNames

