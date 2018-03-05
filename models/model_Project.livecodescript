script "model_Project"
--> MetaData
-
license: GPLv3
name: model_Project
type: model
version: 0.8

/*
We now use one global variable gLCW, within which we store:

- Global Menus
- Global Drag
- Hkey Place Array
- Livecode Dictionary Terms
- activeMenuArray
- environment
- prefsArray

of which "Global Menus" and "Hkey Place Array" are essential. 
Looking to adopt a naming convention in which capitalised keys signify data that is essential to operation,
with lower case keys being useful places to store information.

A number of the datasets are large and not needed to be loaded into memory except for seed reasons.
So Livecode Dictionary Terms is used in parsing handlers during every script compile. 
Loading a large array from disk and saving it is too slow, however migration to a database should be easy.
For now we load and unload these datasets into memory as needed.

Previously we used the following memory resident datastructures. They were richer and more complex.
We have now simplified them.
There were 5 globals in use by the old hArray environment. These were:

-  gHkeyArray
-  gLibrarySetArray
-  gPrefs_Array
- gTemp_ActiveMenuArray

gHkeyArray is broken down into:

-  Global Menus = an array of all Global Menus linked to a numerically linked array of menu items, and the ruggedID of the menu_Controller 
-  behaviorArray = an array of objects with behaviors linked to metadata about that object
-  handlerArray = also known as hArray - a huge array of all handlers linked to every object they occur in with metadata such as hash and lineNums in script.
-  keywordArray = keyword automatically extracted from (library handlers) referencing the last object they were exported from
-  objectType = an automatically cahced index of objects tagged using the uRIP metadata convention on script compile
-  scriptArray = metadata about an objects script (without information about depndency calls)

gLibrarySetArray is broken down to data and metadata:

-  data         = front, back, used arrays and information like whether to add the rev_AddBehaviorHacks
- metadata  = the library set name

gOPN at the moment contains just the active library_SetName
gPrefs_Array contains things like paths to command line tools
gTemp_ActiveMenuArray is a global that contains infromation useful to the functioning of the last or current menu being used

These should probably be rationalised into one for clarity, and ease of removal.
Let's call the new array we move over to:  gLiveCodeWorld
But that is for later...

The handlers have a rough equivalent with regard to "library" handlers.

The aim is to move over from one huge library, to individual projects.
Each project would have it's own "home" stack, where we store stackfiles to all the stacks it needs to know about.
Associated with this home stack we can use the standardised technique of logging metadata,
where we can store arbitrary information.

In this way the metadata of the projects home stack contains all the information we need about the project.

For now let's keep using the old "library" rather than "project" based model for stackFiles.
By this I mean we continue to store set array in the global library rather than in a folder associated with the project.
The first stage of teh transition is to see if multiple home stacks with stackfiles works well.
See also "meta_StackArrayFile" for project level stackfile storage
*/


--> Working on (Project | Files | Convert)
-
/*
These are generic stack functions?
*/

function project_ConvertStackNamesToShortFiles stackNames
   set the itemdelimiter to slash
   repeat for each line stackName in stackNames
      put the filename of stack stackName into longFile
      put item -1 of longFile into shortFile
      put shortFile & CR after shortFiles
   end repeat
   return shortFiles
end project_ConvertStackNamesToShortFiles

function project_ConvertStackObjectsToShortFiles stackObjects
   set the itemdelimiter to slash
   repeat for each line stackObject in stackObjects
      if exists (stackObject) is false then next repeat
      
      put the filename of stackObject into longFile
      put item -1 of longFile into shortFile
      put shortFile & CR after shortFiles
   end repeat
   return shortFiles
end project_ConvertStackObjectsToShortFiles

function project_ConvertShortFilesToStackObjects shortFiles, someFolder
   local goodStackObjects, badStackFiles
   project_ConvertShortFilesToStackObjects shortFiles, someFolder, goodStackObjects, badStackFiles
   return goodStackObjects
end project_ConvertShortFilesToStackObjects

command project_ConvertShortFilesToStackObjects shortFiles, someFolder, @goodStackObjects, @badStackFiles
   repeat for each line shortFile in shortFiles
      put someFolder & shortFile into longStackFile
      if there is not a file longStackFile then
         put longStackFile & CR after badStackFiles
         next repeat
      end if
      put the name of stack longStackFile & CR after goodStackObjects
   end repeat
   delete char -1 of badStackFiles
   delete char -1 of goodStackObjects
end project_ConvertShortFilesToStackObjects


--> Project | Array | Model
-
function project_FetchValue someKey, projectName
   -- put library_FetchProjectFolder (projectName) into projectFolder
   put the stack_Folder of stack projectName into projectFolder
   put project_FetchArray (projectFolder) into projectArray
   put projectArray [someKey] into someValue
   return someValue
end project_FetchValue

command project_SaveValue someKey, someValue, projectName
   -- put library_FetchProjectFolder (projectName) into projectFolder
   put the stack_Folder of stack projectName into projectFolder
   put project_FetchArray (projectFolder) into projectArray
   put someValue into projectArray [someKey]
   project_StoreArray projectFolder, projectArray
   return projectArray
end project_SaveValue

command project_DeleteValue someKey, projectName
   -- put library_FetchProjectFolder (projectName) into projectFolder
   put the stack_Folder of stack projectName into projectFolder
   put project_FetchArray (projectFolder) into projectArray
   delete variable projectArray [someKey]
   project_StoreArray projectFolder, projectArray
   return projectArray
end project_DeleteValue


--> Project | Array
-
getprop project_Array
   -- put the project_ArrayFile of the target into projectArrayFile
   put the project_JsonFile of the target into projectArrayFile
   -- put array_Fetch (projectArrayFile) into projectArray
   put array_FetchModel (projectArrayFile) into projectArray
   return projectArray
end project_Array

setprop project_Array projectArray
   put the project_JsonFile of the target into projectArrayFile
   array_SaveModel projectArrayFile, projectArray
   return modelDataFile
end project_Array

function project_FetchArray projectFolder
   put project_ConstructJsonFile (projectFolder) into projectJsonFile
   put array_FetchModel (projectJsonFile) into projectArray
   return projectArray
end project_FetchArray

command project_StoreArray projectFolder, projectArray
   put project_ConstructJsonFile (projectFolder) into projectJsonFile
   array_SaveModel projectJsonFile, projectArray
   return projectJsonFile
end project_StoreArray

command project_DeleteArray projectName
   put project_GetJsonFile (projectName) into someFile
   delete file someFile
   return someFile
end project_DeleteArray


--> Project | Array | Files
-
getprop project_ArrayFile
   put the project_Name of the target into projectName
   put project_GetArrayFile (projectName) into projectArrayFile
   return projectArrayFile
end project_ArrayFile

getprop project_JsonFile
   put the project_Name of the target into projectName
   put project_GetJsonFile (projectName) into projectArrayFile
   return projectArrayFile
end project_JsonFile

function project_GetArrayFile projectName
   put project_GetFolder (projectName) & "lcw_project.array" into projectArrayFile
   return projectArrayFile
end project_GetArrayFile

function project_GetJsonFile projectName
   put project_GetFolder (projectName) into projectFolder
   put project_ConstructJsonFile (projectFolder) into projectJsonFile
   return projectJsonFile
end project_GetJsonFile

function project_ConstructJsonFile projectFolder
   put projectFolder & "lcw_project.json" into projectJsonFile
   return projectJsonFile
end project_ConstructJsonFile


--> Project | Set Array
-
function project_CurrentFrontScripts
   -- a lot of IDE backscripts are returned
   -- filter them out
   put the frontscripts into someObjects
   filter someObjects without "*/Contents/Tools/Toolset/libraries/rev*"
   filter someObjects without "*/Contents/Tools/Toolset/palettes/rev*"
   return someObjects
end project_CurrentFrontScripts

function project_CurrentBackScripts
   -- a lot of IDE backscripts are returned
   -- filter them out
   put the backscripts into someObjects
   filter someObjects without "*/Contents/Tools/Toolset/libraries/rev*"
   filter someObjects without "*/Contents/Tools/Toolset/palettes/rev*"
   return someObjects
end project_CurrentBackScripts


--> Project | Delete
-
command project_CloseAndDelete projectName
   project_CloseOpenStacks projectName
   put the result into closedStackNames
   
   put library_FetchProjectFolder (projectName) into projectFolder
   revDeleteFolder projectFolder
   
   library_DeleteProjectArray projectName
   return closedStackNames
end project_CloseAndDelete

command project_CloseOpenStacks projectName
   put project_ListOpenStackNames (projectName) into stackNames
   repeat for each line stackName in stackNames
      save stack stackName
      delete stack stackName
   end repeat
   return stackNames
end project_CloseOpenStacks
   
function project_ListOpenStackNames projectName
   -- also works with modules
   put library_FetchProjectFolder (projectName) into projectFolder
   put project_ListAllStackPaths (projectFolder) into projectStackPaths
   put revLoadedStacks ("application") into loadedStackNames
   repeat for each line stackPath in projectStackPaths
      if there is a stack stackPath then
         put the short name of stack stackPath into shortName
         if shortName is among the lines of loadedStackNames then
            put shortName & CR after stackNames
         end if
      end if
   end repeat
   delete char -1 of stackNames
   return stackNames
end project_ListOpenStackNames


--> Library | Project | Model | Folders | Naming
-
/*
These handlers define the keys for the 
*/

function library_FetchProjectFolder homeStackName  
   put library_FetchProjectArray (homeStackName) into projectArray
   put projectArray ["projectFolder"] into projectFolder
   
   if projectFolder is empty then return projectFolder
   text_AddTrailing projectFolder, slash   
   if there is a folder projectFolder then
      return projectFolder
   else
      return empty
   end if
end library_FetchProjectFolder   

command library_StoreProjectFolder homeStackName, projectFolder
   put library_FetchProjectArray (homeStackName) into projectArray
   --
   put projectFolder into projectArray ["projectFolder"]
   set the itemdelimiter to slash
   if item - 2 of projectFolder = "modules" then
      put "module" into projectArray ["projectType"]
   else
      put "project" into projectArray ["projectType"]
   end if
   --
   library_StoreProjectArray homeStackName, projectArray
end library_StoreProjectFolder

function library_FetchProjectData
   put lcw_FetchArray ("lcw_ProjectDataLibrary.array") into libraryProjectData
   return libraryProjectData
end library_FetchProjectData

command library_StoreProjectData libraryProjectData
   lcw_StoreArray "lcw_ProjectDataLibrary.array", libraryProjectData
end library_StoreProjectData


--> Library | Project | Model | Folders
-
function library_ListProjectModules
   put library_FetchProjectData() into libraryProjectData
   put _FilterLibraryProjectArray ("module", libraryProjectData) into moduleStackNames
   return moduleStackNames
end library_ListProjectModules

function library_ListProjectNames pProjectType
   put library_FetchProjectData() into libraryProjectData
   switch pProjectType
      case "all"
         put keys (libraryProjectData) into projectNames
         break
      case "module"
         put _FilterLibraryProjectArray ("module", libraryProjectData) into projectNames
         break
      default -- case "project"
         put _FilterLibraryProjectArray ("project", libraryProjectData) into projectNames
   end switch
   sort projectNames
   return projectNames
end library_ListProjectNames

function library_ListProjectFolders
   put library_FetchProjectData() into libraryProjectArray
   repeat for each key projectName in libraryProjectArray
      put libraryProjectArray [projectName] into projectArray
      put projectArray ["projectFolder"] into libraryRepoFolder
      if there is not a folder libraryRepoFolder then
         next repeat
      end if
      put projectName into libraryRepoFolderArray [libraryRepoFolder]
   end repeat
   put keys (libraryRepoFolderArray) into libraryRepoFolders
   sort libraryRepoFolders
   return word 1 to -1 of libraryRepoFolders
end library_ListProjectFolders


--> Library | Project | Model | Stacks
-
function library_FetchProjectHomeStackObject projectName
   put library_FetchProjectHomeStackPath (projectName) into homeStackPath
   if exists (stack homeStackPath) is false then return empty
   return the long id of stack homeStackPath
end library_FetchProjectHomeStackObject

function library_FetchProjectHomeStackPath projectHomeStackName
   put library_FetchProjectFolder (projectHomeStackName) into projectFolder
   if projectFolder is empty then return empty
   text_AddTrailing projectFolder, slash
   put project_NameToShortFolder (projectHomeStackName) into projectShortFolder
   put projectFolder & projectShortFolder & ".livecode" into homeStackPath
   return homeStackPath
end library_FetchProjectHomeStackPath


--> Library | Project | Model
-
command library_TidyProjectModel
   put library_FetchProjectData() into libraryProjectData
   repeat for each key projectName in libraryProjectData
      put libraryProjectData [projectName]["projectType"] into someType
      put libraryProjectData [projectName]["projectFolder"] into someFolder
      switch
         case projectName is empty
            delete variable libraryProjectData [projectName]
            break
         case someType is not among the items of "project,module"
            delete variable libraryProjectData [projectName]
            break
         case there is not a folder someFolder
            delete variable libraryProjectData [projectName]
            break
         default
            -- all is fine
      end switch
   end repeat
   library_StoreProjectData libraryProjectData
end library_TidyProjectModel

function library_FetchProjectValue someKey, pProjectName
   if pProjectName is empty then put env_GetProjectFocus() into pProjectName
   put library_FetchProjectArray (pProjectName) into projectArray
   put projectArray [someKey] into someValue
   return someValue
end library_FetchProjectValue

command library_SaveProjectValue someKey, someValue, pProjectName
   if pProjectName is empty then put env_GetProjectFocus() into pProjectName
   put library_FetchProjectArray (pProjectName) into projectArray
   put someValue into projectArray [someKey]
   library_StoreProjectArray pProjectName, projectArray
   return projectArray
end library_SaveProjectValue

function library_FetchProjectArray projectName
   -- was "library_FetchProjectArray"
   -- if projectName is empty then put env_GetProjectFocus() into projectName
   put library_FetchProjectData() into libraryProjectData
   put libraryProjectData [projectName] into projectArray
   return projectArray
end library_FetchProjectArray

command library_StoreProjectArray projectName, projectArray
   put library_FetchProjectData() into libraryProjectData
   put projectArray into libraryProjectData [projectName]
   library_StoreProjectData libraryProjectData
   return libraryProjectData
end library_StoreProjectArray

command library_DeleteProjectArray projectName
   put library_FetchProjectData() into libraryProjectData
   delete variable libraryProjectData [projectName]
   library_StoreProjectData libraryProjectData
end library_DeleteProjectArray


command project_AddArrayToGlobal projectArray, pRecursively
   /*
   By default (if pRecursively is false or empty), this command merges the all keys recursively, adding new items to gLCW from projectArray
   but keeping any old items that are not in projectArray.
   Consequenlty this "adds" the contents of the projectArray to gLCW with the exception of leaf contents which are updated or replaced.
   So if you want a merge - store your data as an array not an index.
   
   if pRecursively is false then this command replaces items that are already there with the contents of projectArray
   Consequenlty this adds or "sets" the contents of the variable
   */
   global gLCW
   
   if pRecursively is not false then
      union projectArray with gLCW recursively
   else
      union projectArray with gLCW
   end if
   put projectArray into gLCW
   return gLCW
end project_AddArrayToGlobal


--> Private
-
private function _FilterLibraryProjectArray projectType, libraryProjectData
   repeat for each key projectName in libraryProjectData
      put libraryProjectData [projectName]["projectType"] into someType
      -- put libraryProjectData [projectName]["projectFolder"] into someFolder
      if someType = projectType then
         put projectName & CR after projectNames
      end if
   end repeat
   delete char -1 of projectNames
   return projectNames
end _FilterLibraryProjectArray
