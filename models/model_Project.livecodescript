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


--> Project | Model | Props
-
getprop model_Array [pArrayName]
   -- convenience utility that uses a file called "lcw_model.array" by default
   -- placed in a model_DataFolder of the target which should be a model stack
   put the project_Name of the target into projectName
   if projectName is empty then return empty
   put the stack_Name of the target into modelName
   
   -- let's check it is a model stack
   set the itemdelimiter to slash
   put the filename of stack modelName into stackPath
   if item -2 of stackPath is not "models" then return empty
   
   put model_FetchArray (modelName, projectName, pArrayName) into modelArray
   return modelArray
end model_Array

setprop model_Array [pArrayName] modelArray
   -- convenience utility that uses a file called "lcw_model.array"
   -- placed in a model_DataFolder of the target which should be a model stack
   put the project_Name of the target into projectName
   if projectName is empty then return empty
   put the stack_Name of the target into modelName
   
   -- let's check it is a model stack
   set the itemdelimiter to slash
   put the filename of stack modelName into stackPath
   if item -2 of stackPath is not "models" then return empty
   
   model_StoreArray modelName, projectName, modelArray, pArrayName
   put the result into modelArrayFile
   return modelArrayFile
end model_Array


--> Project | Model
-
function model_GetArray modelStackName, pArrayName
   if exists (stack modelStackName) is false then return empty
   put the project_Name of stack modelStackName into projectName
   put model_FetchArray (modelStackName, projectName, pArrayName) into modelArray
   return modelArray
end model_GetArray

command model_SetArray modelStackName, dataArray, pArrayName
   if exists (stack modelStackName) is false then return empty
   put the project_Name of stack modelStackName into projectName
   model_StoreArray modelStackName, projectName, dataArray, pArrayName
   put the result into modelArrayFile
   return modelArrayFile
end model_SetArray

function model_FetchArray modelStackName, projectName, pArrayName
   if projectName is empty then return empty
   put model_ConstructArrayFile (modelStackName, projectName, pArrayName) into modelArrayFile
   put array_Fetch (modelArrayFile) into modelArray
   return modelArray
end model_FetchArray

command model_StoreArray modelStackName, projectName, dataArray, pArrayName
   -- will create a model data folder
   if projectName is empty then return empty
   put model_ConstructArrayFile (modelStackName, projectName, pArrayName) into modelArrayFile
   array_Save modelArrayFile, dataArray
   return modelArrayFile
end model_StoreArray


--> Project | Models | Names
-
function model_ConstructArrayShortFile pArrayName
   if pArrayName is empty then
      put "lcw_model.array" into shortFile
   else
      put "lcw_" & pArrayName & ".array" into shortFile
   end if
   return shortFile
end model_ConstructArrayShortFile

function model_ExtractArrayName shortFile
   if char 1 to 4 of shortFile is not "lcw_" then return empty
   delete char 1 to 4 of shortFile
   if char -6 to -1 of shortFile is not ".array" then return empty
   put char 1 to -7 of shortFile into arrayName
   return arrayName
end model_ExtractArrayName


--> Project | Models | Files
-
function model_ConstructArrayFile modelStackName, projectName, pArrayName
   put model_ConstructArrayShortFile (pArrayName) into shortFile
   put project_GetFolder (projectName) into projectFolder
   put model_GetDataFolder (modelStackName, projectFolder) into libraryArrayFolder
   put libraryArrayFolder & shortFile into modelArrayFile
   return modelArrayFile
end model_ConstructArrayFile

getprop model_DataFolder [modelStackName]
   put the stack_Object of the target into stackObject
   put the effective filename of stackObject into somePath
   project_FindFromPath somePath, homeStackName, projectFolder, projectStackPath
   
   set the itemdelimiter to slash
   switch
      case projectFolder is empty
         return empty
      case modelName is not empty
         put model_GetDataFolder (modelStackName, projectFolder) into modelDataFolder
         return modelDataFolder
      case item -2 of somePath = "models"
         put item -1 of somePath into shortStackFile
         set the itemdelimiter to "."
         put item 1 of shortStackFile into modelStackName
         put model_GetDataFolder (modelStackName, projectFolder) into modelDataFolder
         return modelDataFolder
      default
         return empty
   end switch
end model_DataFolder

function model_GetDataFolder modelStackName, projectFolder
   put project_ConstructFolder ("models", projectFolder) into rootModelsFolder
   put rootModelsFolder & modelStackName & slash into modelDataFolder
   return modelDataFolder
end model_GetDataFolder


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


--> Project | Files | Convert
-
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
