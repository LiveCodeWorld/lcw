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


--> Working on
-


--> Props
-
setprop project_Array projectArray
   put the project_JsonFile of the target into projectArrayFile
   array_ToFile projectArrayFile, projectArray
   return modelDataFile
end project_Array


--> Project | Array | Model
-
function project_GetArray projectName
   if exists (stack projectName) is false then return empty
   put the project_Folder of stack projectName into projectFolder
   --
   put project_GetArrayFromFolder (projectFolder) into projectArray
   return projectArray
end project_GetArray

function project_GetArrayFromFolder projectFolder
   put project_ConstructJsonFile (projectFolder) into projectJsonFile
   put array_FromFile (projectJsonFile) into projectArray
   return projectArray
end project_GetArrayFromFolder

command project_StoreArray projectFolder, projectArray
   put project_ConstructJsonFile (projectFolder) into projectJsonFile
   array_ToFile projectJsonFile, projectArray
   return projectJsonFile
end project_StoreArray

command project_DeleteArray projectName
   put project_JsonFile (projectName) into someFile
   delete file someFile
   return someFile
end project_DeleteArray


--> Project | Files | Convert
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
   put project_GetArrayFromFolder (projectFolder) into projectArray
   put projectArray [someKey] into someValue
   return someValue
end project_FetchValue

command project_SaveValue someKey, someValue, projectName
   -- put library_FetchProjectFolder (projectName) into projectFolder
   put the stack_Folder of stack projectName into projectFolder
   put project_GetArrayFromFolder (projectFolder) into projectArray
   put someValue into projectArray [someKey]
   project_StoreArray projectFolder, projectArray
   return projectArray
end project_SaveValue

command project_DeleteValue someKey, projectName
   -- put library_FetchProjectFolder (projectName) into projectFolder
   put the stack_Folder of stack projectName into projectFolder
   put project_GetArrayFromFolder (projectFolder) into projectArray
   delete variable projectArray [someKey]
   project_StoreArray projectFolder, projectArray
   return projectArray
end project_DeleteValue


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
command project_CloseAndDelete projectName, pRepoFolder
   project_CloseOpenStacks projectName
   put the result into closedStackNames
   
   put env_ConstructProjectFolder (projectName, pRepoFolder) into projectFolder
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

function project_ListOpenStackNames projectName, pRepoFolder
   -- also works with modules
   put env_ConstructProjectFolder (projectName, pRepoFolder) into projectFolder
   --
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
