script "lib_Environment"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Environment
type: library
version: 0.8

/*
This library was extracted from lib_LCW as a self-contained librabry.
It is designed to recursively load projects based on the project_Deps property of a stack.
I uses the "env_RecursivelyLoadProjects" command to acheive this.

Aims to be used only for desktop recursion of local files organised in a standardardised way by LCW.
*/

--> Working on
-

--> Missing
-
getprop missing_Hkeys
   return "G project_Deps"
end missing_Hkeys


--> Environment
-
command env_RecursivelyLoadProjects pObject, pForceLoad
   if pObject is empty then put the long id of the target into pObject
   
   put the project_DependencyArray of pObject into projectDepArray
   -- delete variable projectDepArray ["lcw"] -- should already be loaded
   --
   set the itemdelimiter to slash
   repeat for each key projectName in projectDepArray
      set the cursor to busy
      put projectDepArray [projectName]["path"] into homeStackPath
      if there is a stack homeStackPath then
         try
            env_SimpleLoadProject projectName, homeStackPath, pForceLoad
         catch sError
            breakpoint
         end try
      end if
   end repeat        
end env_RecursivelyLoadProjects


--> Props
-
getprop relative_Path [pRoot]
   put the effective filename of the defaultstack into sPath
   put env_RelativePath (sPath, pRoot) into relPath
   return relPath 
end relative_Path

getprop project_DependencyArray
   put the project_Name of the target into projectName
   put env_GetRepoFolder() into repoFolder
   --
   put env_ConstructProjectDepArray (projectName, repoFolder) into projectDepArray
   return projectDepArray
end project_DependencyArray

getprop project_Folder
   -- Latest simplest version based on naming conventions and folder structure
   -- Does not allow projects outside of the LCW repository
   
   put the effective filename of the defaultstack into stackPath
   if stackPath is empty then return empty
   put project_FolderFromPath (stackPath) into projectFolder
   return projectFolder
end project_Folder

getprop project_Name
   set the itemdelimiter to slash
   put the project_Folder of the target into projectFolder
   return item -1 of projectFolder
end project_Name

setprop stackfile_Array sfArray
   put the defaultstack into someStack
   put stackFile_FromArray (sfArray) into sfTable
   sort sfTable by item 1 of each
   set the stackfiles of someStack to sfTable
   return sfTable
end stackfile_Array


--> Hkeys
-
function array_FromFile someFile, pUseMerge
   put url ("binfile:" & someFile) into someData
   if someData is empty then return empty
   
   # Switch depending on file type
   set the itemdelimiter to "."
   switch item -1 of someFile
      case "json"
         put json_ToArray (someData, pUseMerge) into modelArray
         return modelArray
      case "array"
         put arraydecode (someData) into modelArray
         return modelArray
      default
         return someData
   end switch
end array_FromFile

function env_ConstructHomePath projectName, pLcwFolder
   if pLcwFolder is empty then put env_GetLcwFolder() into pLcwFolder
   --
   set the itemdelimiter to slash
   put pLcwFolder into repoFolder
   delete item -1 of repoFolder
   put projectName & ".livecode" into shortFile
   put repoFolder & projectName & slash & shortFile into homePath
   return homePath
end env_ConstructHomePath

function env_ConstructProjectDepArray projectName, repoFolder
   local projectDepArray
   env_CrawlProjectDeps projectDepArray, projectName, repoFolder
   return projectDepArray
end env_ConstructProjectDepArray

command env_CrawlProjectDeps @projectDepArray, projectName
   -- we do not assume the project home stack is loaded into memory
   -- we base everything on naming conventions, and folder structure
   
   -- first we check for recursion
   if projectDepArray [projectName] is an array then
      return "Already added to projectDepArray"
   end if
   
   -- now let's guess the projectHomeStackPath
   put env_GetProjectHomePath (projectName) into stackPath
   if stackPath is empty then
      put merge ("Project home stack does not exist!") into projectDepArray [projectName]["Error"]["msg"]
      put projectName into projectDepArray [projectName]["Error"]["projectName"]
      put stackPath into projectDepArray [projectName]["Error"]["path"]
      return "Already indexed"
   else
      put stackPath into projectDepArray [projectName]["path"]
   end if
   
   -- now recurse
   put the project_Deps of stack projectName into projectDeps
   repeat for each item nextProjectName in projectDeps
      env_CrawlProjectDeps projectDepArray, nextProjectName
   end repeat
   return "Finished deps"
end env_CrawlProjectDeps

function env_RelativePath sPath, pRoot
   if pRoot is empty then
      put env_GetRepoFolder() into pRoot
   end if
   
   if sPath begins with pRoot then
      set the itemdelimiter to slash
      put the number of items of pRoot + 1 into rootNum
      put item rootNum to -1 of sPath into relPath
      return relPath
   else
      return empty
   end if
end env_RelativePath

function env_FolderFromPath sPath
   -- works for any stack within the LiveCodeWorld repo
   constant RootName = "LivecodeWorld"
   
   set the itemdelimiter to slash
   put itemOffset (RootName, sPath) into itemNum
   if itemNum = 0 then return empty
   put item 1 to itemNum of sPath & slash into envFolder
   return envFolder
end env_FolderFromPath

function env_GetActiveProjectArray
   global gLCW
   put gLCW ["environment"]["project"] into activeProjectArray
   return activeProjectArray
end env_GetActiveProjectArray

function env_GetLcwFolder
   if exists (stack "LCW") is false then
      put the filename of me into sPath
      return env_FolderFromPath (sPath)
   else
      get the filename of stack "LCW"
      set the itemdelimiter to slash
      put item 1 to -2 of it & slash into lcwFolder
      return lcwFolder
   end if
end env_GetLcwFolder

function env_GetProjectHomePath projectName, pLcwFolder
   put env_ConstructHomePath (projectName, pLcwFolder) into projectHomeStackPath
   if there is a stack projectHomeStackPath then -- loads into memory
      return projectHomeStackPath
   else
      return empty
   end if
end env_GetProjectHomePath

function env_GetRepoFolder
   put env_GetLcwFolder() into pLcwFolder
   --
   set the itemdelimiter to slash
   delete item -1 of pLcwFolder
   return pLcwFolder
end env_GetRepoFolder

function env_ProjectIsActive projectName, pRepoFolder
   -- put env_GetProjectFolder (projectName) is not empty into projectIsLoaded
   -- put env_ConstructProjectFolder (projectName, pRepoFolder) is not empty into projectIsLoaded
   
   put env_GetActiveProjectArray() into activeProjectArray
   put activeProjectArray [projectName] is not empty into projectIsLoaded
   return projectIsLoaded
end env_ProjectIsActive

command env_SetActiveProjectArray activeProjectArray
   global gLCW
   put activeProjectArray into gLCW ["environment"]["project"]
   return gLCW
end env_SetActiveProjectArray

command env_SetProjectFolder homeStackName, pProjectFolder
   put env_GetActiveProjectArray() into envProjectArray
   if pProjectFolder is empty then
      delete variable envProjectArray [homeStackName]
   else
      put pProjectFolder into envProjectArray [homeStackName]
   end if
   env_SetActiveProjectArray envProjectArray
   return envProjectArray
end env_SetProjectFolder

command env_SimpleLoadProject projectName, homeStackPath, pForceLoad
   if exists (stack homeStackPath) is false then
      breakpoint
      return "Error, cannot locate stack:" && homeStackPath
   end if
   
   # Init project (nothing recursive)   
   put env_ProjectIsActive (projectName) into isLoaded
   if isLoaded and pForceLoad is not true then
      return merge ("Already loaded project [[projectName]]. Not re-laoding")
   end if
   
   # Load from folder
   set the itemdelimiter to slash
   put homeStackPath into projectFolder
   put empty into item -1 of projectFolder
   project_LoadFromFolder projectFolder
   
   # Trap for Custom behavior
   dispatch "project_PostInit" to stack homeStackPath
   
   # Trap for notification
   dispatch "display_LoadProject" to stack homeStackPath with projectName
   return empty
end env_SimpleLoadProject

function project_ConstructJsonFile projectFolder
   put projectFolder & "lcw_project.json" into projectJsonFile
   return projectJsonFile
end project_ConstructJsonFile

function project_FolderFromPath stackPath
   set the itemdelimiter to slash
   put env_GetRepoFolder() into repoFolder
   put the number of items of repoFolder + 1 into itemNum
   put item 1 to itemNum of stackPath & slash into projectFolder
   --
   return projectFolder
end project_FolderFromPath

function project_GetArrayFromFolder projectFolder
   put project_ConstructJsonFile (projectFolder) into projectJsonFile
   put array_FromFile (projectJsonFile) into projectArray
   return projectArray
end project_GetArrayFromFolder

function project_ListUsedPathsFromArray projectArray, projectFolder
   text_AddTrailing projectFolder, slash
   put projectArray ["stackFileArray"] into stackFileArray
   set the itemdelimiter to slash
   repeat for each key stackName in stackFileArray
      put stackFileArray [stackName] into relPath
      switch
         case "models" is among the items of relPath
         case "libraries" is among the items of relPath
            put projectFolder & relPath & CR after usedPaths 
      end switch
   end repeat
   delete char -1 of usedPaths
   return usedPaths
end project_ListUsedPathsFromArray

command project_LoadFromFolder projectFolder
   if there is not a folder projectFolder then return empty
   put project_GetArrayFromFolder (projectFolder) into projectArray
   
   # First load  libraries for dependencies
   put project_ListUsedPathsFromArray (projectArray, projectFolder) into usedPaths
   use_StackNames usedPaths
   
   # Get ProjectName
   put project_NameFromFolder (projectFolder) into projectName
   if exists (stack projectName) is false then
      return empty
   end if
   
   # Set Home stackfiles
   put projectArray ["stackFileArray"] into stackFileArray
   set the stackfile_Array of stack projectName to stackFileArray
   
   # Add to Env -- do this manually if needed
   -- env_AddProject projectName, projectFolder
   env_SetProjectFolder projectName, projectFolder
   
   return projectArray
end project_LoadFromFolder

function project_NameFromFolder projectFolder
   set the itemdelimiter to slash
   put item -1 of projectFolder into projectName
   return projectName
end project_NameFromFolder

function stackFile_FromArray stackFileArray
   combine stackFileArray using CR and comma
   sort stackFileArray
   return stackFileArray
end stackFile_FromArray

command text_AddTrailing @someText, someChar
   if char -1 of someText is not someChar then
      put someChar after someText
   end if
end text_AddTrailing

command use_StackNames stackPaths, pBoolean
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      --
      if pBoolean is false then
         stop using stack stackPath
      else
         start using stack stackPath
      end if
   end repeat
end use_StackNames


--> Private
-
