script "model_Environment"
--> MetaData
-
license: GPLv3
name: model_Environment
type: model
version: 0.6

/*
This model wraps the global variables that LCW uses to combine individual projects into a singe environment.
It also contains the code to store and fetch this information from disk.

An environment contains a list of projects that need to be loaded 
together with and data that the environment may need either loaded into memory or stored on disk.

For instance an environment will typically contain a data stored in a global which determines how LCW Menus are created.
This data needs to be loaded into the enviroment from individua projects.
Therefore this model contains handlers that can load and merge this data, providing access to scripts that need it
and instructions how to build it from individual projects.
*/


--> Environment | Events
-
on environment_RegisterProject projectFolder
   put project_NameFromFolder (projectFolder) into projectName
   env_SetProjectFolder projectName, projectFolder
end environment_RegisterProject

on environment_DeregisterProject projectFolder
   put project_NameFromFolder (projectFolder) into projectName
   env_SetProjectFolder projectName
end environment_DeregisterProject


--> Environment | Model
-
function env_GetProjectFolder projectName
   put env_GetProjectArray into envProjectArray
   return envProjectArray [projectName]
end env_GetProjectFolder

command env_SetProjectFolder projectName, pProjectFolder
   put env_GetProjectArray into envProjectArray
   if pProjectFolder is empty then
      delete envProjectArray [projectName]
   else
      put pProjectFolder into envProjectArray [projectName]
   end if
   env_SetProjectArray envProjectArray
   return envProjectArray
end env_SetProjectFolder

function environment_ListProjectNames
   put env_GetProjectArray() into envProjectArray
   put keys(envProjectArray) into envProjectNames
   sort envProjectNames
   return envProjectNames
end environment_ListProjectNames

function env_GetProjectArray
   put LocalArray ["environment"]["project"] into envProjectArray
   return envProjectArray
end env_GetProjectArray

command env_SetProjectArray envProjectArray
   put envProjectArray into LocalArray ["environment"]["project"]
   return LocalArray
end env_SetProjectArray


--> Environment
-
command environment_Start
   env_AddToBash
end environment_Start

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


--> Environment  Load
-
command environment_LoadProjectGlobals projectList
   replace CR with comma in projectList
   repeat for each item projectName in projectList
      project_LoadWorkingStackFiles projectName
      -- project_RestoreGlobalPrefs projectName
      project_LoadGlobalPrefs projectName
      project_LoadGlobalHarray projectName 
      project_LoadGlobalArray projectName 
   end repeat
end environment_LoadProjectGlobals


--> Project | Globals | Load and unload
-
command project_LoadGlobals projectName
   -- we still need to deal with thing like password preferences
   
   environment_Start
   project_LoadWorkingStackFiles projectName
   -- project_RestoreGlobalPrefs projectName
   project_LoadGlobalPrefs projectName
   project_LoadGlobalHarray projectName 
   project_LoadGlobalArray projectName 
   
   /*
   library_CheckEssentialPrefs -- double check critical prefs like git path
   project_ReloadCheckoutGlobals projectName  -- load non user globals
   */
end project_LoadGlobals

command project_StoreGlobals pProjectName
   if pProjectName is empty then put project_GetCurrentName() into projectName
   
   project_SaveGlobalHarray pProjectName
   put the result into hArrayFile
   
   project_SaveGlobalPrefs pProjectName
   
   -- not sure we use this any more
   project_SaveGlobalArray pProjectName
   
   -- don't do yet
   -- wait till this is properly tested
   -- project_ClearGlobals
end project_StoreGlobals

command project_ClearGlobals
   global gTemp_ActiveMenuArray
   global gLibrarySet_Array
   global gHkey_Array
   global gPrefs_Array
   
   delete variable gTemp_ActiveMenuArray
   delete variable gLibrarySet_Array
   delete variable gHkey_Array
   delete variable gPrefs_Array
end project_ClearGlobals


