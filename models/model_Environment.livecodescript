﻿script "model_Environment"
--> MetaData
-
license: GPLv3
name: model_Environment
type: model
version: 0.6

/*
An environment contains a list of projects that need to be loaded 
together with and data that the environment may need either loaded into memory or stored on disk.

For instance an environment will typically contain a data stored in a global which determines how LCW Menus are created.
This data needs to be loaded into the enviroment from individual projects.
Therefore this model contains handlers that can load and merge multiple projects, 
providing access to scripts that need it and instructions how to build it from individual projects.

As handlers that work on a set of projects, stroing these in the global vairable gLCW,  we should rename these handlers "env_XXX"

command env_LoadProjectGlobals projectList
   was "environment_LoadProjectGlobals"
   replace CR with comma in projectList
   repeat for each item projectName in projectList
      project_LoadWorkingStackFiles projectName
      -- project_RestoreGlobalPrefs projectName
      project_LoadGlobalPrefs projectName
      project_LoadGlobalHarray projectName 
      project_LoadGlobalArray projectName 
   end repeat
end env_LoadProjectGlobals

*/

--> Working on
-
function project_IsActive projectName
   put env_GetProjectFolder (projectName) is not empty into projectIsLoaded
   return projectIsLoaded
end project_IsActive


--> Environment | Project | Focus
-
/*
An environment no longer has a single project.  Multiple projects can be loaded.
But we may be interested in focussing on one. This utility fuction allows for that.
*/

function env_GetProjectFocus
   global gLCW
   put gLCW ["environment"]["current project"] into currentProjectFocus
   return currentProjectFocus
end env_GetProjectFocus

command env_SetProjectFocus currentProjectFocus
   global gLCW
   put currentProjectFocus into gLCW ["environment"]["current project"]
   return gLCW ["environment"]
end env_SetProjectFocus


--> Private
-
private command _SetProjectNames @pProjectNames
   switch pProjectNames
      case "all"
      case empty
         put env_ListProjects() into pProjectNames
         break
      default
         replace comma with CR in pProjectNames
   end switch
end _SetProjectNames


--> Environment | List
-
function env_ListProjects pListAll
   switch pListAll
      case "true"
      case "all"
         put library_ListProjectNames() into projectNames
         return projectNames
      case empty
         put env_GetProjectArray() into envProjectArray
         put keys (envProjectArray) into envProjectNames
         filter envProjectNames without "View|*"
         sort envProjectNames
         return word 1 to -1 of envProjectNames
      default -- case "with views"
         put env_GetProjectArray() into envProjectArray
         put keys (envProjectArray) into envProjectNames
         sort envProjectNames
         return word 1 to -1 of envProjectNames
   end switch
end env_ListProjects

function env_ListControllerStackNames pProjectNames
   put env_ListControllerPaths (pProjectNames) into activeControllerPaths
   put stack_PathsToNames (activeControllerPaths) into stackNames
   sort stackNames
   return stackNames
end env_ListControllerStackNames

function env_ListControllerPaths pProjectNames
   _SetProjectNames pProjectNames
   repeat for each line projectName in pProjectNames
      -- put project_ListControllerPaths (projectName) into projectControllerPaths
      put library_FetchProjectFolder (projectName) into projectFolder
      put project_ListPaths ("controllers", projectFolder) into projectControllerPaths
      if projectControllerPaths is not empty then
         put projectControllerPaths & CR after environmentControllerPaths
      end if
      
      put project_ListModules (projectName) into moduleNames
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

function env_ListBehaviorPaths pProjectNames
   _SetProjectNames pProjectNames
   repeat for each line projectName in pProjectNames
      put library_FetchProjectFolder (projectName) into projectFolder
      put project_ListPaths ("behaviors", projectFolder) into projectBehaviorPaths
      if projectBehaviorPaths is not empty then
         put projectBehaviorPaths & CR after environmentBehaviorPaths
      end if
      
      put project_ListModules (projectName) into moduleNames
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

-- function env_ListUsedStackNames pProjectNames
if pProjectNames is empty then
   put library_ListProjectNames() into pProjectNames
   -- put env_ListProjects() into pProjectNames
end if

repeat for each line projectName in pProjectNames
   put library_FetchProjectHomeStackPath (projectName) into homeStackPath  
   if exists (stack homeStackPath) is false then next repeat
   put the project_UsedStackNames of stack homeStackPath into stackNames
   put stackNames & CR after envUsedStackNames
end repeat
sort envUsedStackNames
return word 1 to -1 of envUsedStackNames
end env_ListUsedStackNames

function env_ListUsedStackNames pProjectNames
   put env_ListUsedStackPaths (pProjectNames) into stackPaths
   put stack_PathsToNames (stackPaths) into stackNames
   return stackNames
end env_ListUsedStackNames

function env_ListUsedStackPaths pProjectNames
   _SetProjectNames pProjectNames
   repeat for each line projectName in pProjectNames
      put library_FetchProjectHomeStackPath (projectName) into homeStackPath  -- this should already be added?
      if exists (stack homeStackPath) is false then next repeat
      put the project_UsedStackPaths of stack homeStackPath into stackPaths
      if stackPaths is not empty then
         put stackPaths & CR after envUsedStackPaths
      end if
   end repeat
   sort envUsedStackPaths
   return word 1 to -1 of envUsedStackPaths
end env_ListUsedStackPaths

function env_ListModuleHomeStackNames pProjectNames
   -- searches folders
   -- see : put library_ListProjectModules() into stackNames for extracting from global project array
   put env_ListModuleHomeStackPaths (pProjectNames) into stackPaths
   put stack_PathsToNames (stackPaths) into stackNames
   sort stackNames
   return stackNames
end env_ListModuleHomeStackNames

function env_ListModuleHomeStackPaths pProjectNames
   _SetProjectNames pProjectNames
   repeat for each line projectName in pProjectNames
      put project_ListModuleFolders (projectName) into moduleFolders
      repeat for each line moduleFolder in moduleFolders
         put project_ConstructHomeStackPath (moduleFolder) into moduleHomeStackPath
         if exists (stack moduleHomeStackPath) is false then
            breakpoint
            next repeat
         end if
         put moduleHomeStackPath & CR after activeModuleHomeStackPaths
      end repeat
   end repeat
   delete char -1 of activeModuleHomeStackPaths
   sort activeModuleHomeStackPaths
   return word 1 to -1 of activeModuleHomeStackPaths
end env_ListModuleHomeStackPaths


--> Environment | Model
-
function env_ListProjects
   put env_GetProjectArray() into envProjectArray
   return keys (envProjectArray)
end env_ListProjects

command env_AddProject homeStackName, pProjectFolder
   if exists (stack homeStackName) is false then return false
   if pProjectFolder is empty then
      put library_FetchProjectFolder (homeStackName) into pProjectFolder
   else
      if there is not a folder pProjectFolder then
         return false
      else
         library_StoreProjectFolder homeStackName, pProjectFolder
      end if
   end if
   if there is not a folder pProjectFolder then return false
   
   env_SetProjectFolder homeStackName, pProjectFolder
   return true
end env_AddProject

command env_RemoveProject projectName
   put env_GetProjectArray() into envProjectArray
   delete variable envProjectArray [projectName]
   env_SetProjectArray envProjectArray
end env_RemoveProject


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

command env_ExportAndIndexProject projectName
   local bigPlaceArray
   put library_FetchProjectFolder (projectName) into projectFolder
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

command env_ReLoadMenus pProjectNames
   if pProjectNames is empty then
      put library_ListProjectNames() into pProjectNames
   else
      replace comma with CR in pProjectNames
   end if
   repeat for each line projectName in pProjectNames
      put library_FetchProjectFolder (projectName) into projectFolder
      if there is not a folder projectFolder then next repeat
      project_LoadMenus projectFolder
   end repeat
end env_ReLoadMenus

command env_AddToBash
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
   return $PATH
end env_AddToBash