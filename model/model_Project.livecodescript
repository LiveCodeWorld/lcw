script "model_Project"
--> MetaData
-
license: GPLv3
name: model_Project
type: model
version: 0.6

/*
There are currently 5 active globals in use by the LiveCode environment.
These are:

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

-  data         = front, back, used arrays and information like whether to add the ide_AddBehaviorHacks
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
command project_AddStack stackNames
   put project_FetchValue ("openStacks") into oldProjectStackNames
   put stackNames & CR & oldProjectStackNames into newProjectStackNames
   sort newProjectStackNames
   put word 1 to -1 of newProjectStackNames into newProjectStackNames
   project_SaveValue "openStacks", newProjectStackNames
   return newProjectStackNames
end project_AddStack


--> Project | Files | Handler
-
function project_HandlerHelpFile hKey, pDontCreate
   return project_HandlerMetadataFolder (hKey, pDontCreate) & "help.html"
end project_HandlerHelpFile

function project_HandlerFile hKey, pDontCreate
   put project_GetHandlerFolder (hKey, pDontCreate) & "script.txt" into scriptFile
   return scriptFile
end project_HandlerFile


--> Project | Files | Metadata
-
-- getprop hkey_MetadataFolder [hKey]
put project_HandlerMetadataFolder (hKey, true) into hkeyMetadataFolder
return hkeyMetadataFolder
end hkey_MetadataFolder

getprop project_ProcessedHkeyArrayFile
   -- this puts object hkeyarray files in the project overlay folder (wrong place)
   -- fix so it (and related handlers) use 
   put the project_OverlayFolder of the target into projectOverlayFolder
   put projectOverlayFolder & "processedHkey.array" into someFile
   return someFile
end project_ProcessedHkeyArrayFile


--> Project | Folders
-
getprop project_OverlayFolder
   put the textStack_Folder of the target into textStackFolder
   put textStackFolder & "metadata/project/overlay/" into projectOverlayFolder
   return projectOverlayFolder
end project_OverlayFolder


--> Project | Array
-
getprop project_DependencyStacks
   put the project_DependencyStackArray of the target into objectArray
   delete variable objectArray ["Missing"]
   put the stack_Object of the target into longStackObject
   delete variable objectArray ["revIgniter"]
   put the name of longStackObject into myStackObject
   delete variable objectArray [myStackObject]
   put keys (objectArray) into dependencyStacks
   return dependencyStacks
end project_DependencyStacks

getprop project_DependencyStackArray
   put the project_ProcessedHkeyArray of the target into processedHkeyArray  
   put hkeyArray_ConstructObjectArray (processedHkeyArray) into objectArray
   return objectArray
end project_DependencyStackArray

getprop project_ProcessedHkeyArray
   put the project_ProcessedHkeyArrayFile of the target into someFile
   put array_Fetch (someFile) into rigHkeyArray
   return rigHkeyArray
end project_ProcessedHkeyArray

setprop project_ProcessedHkeyArray rigHkeyArray
   put the project_ProcessedHkeyArrayFile of the target into someFile
   array_Save someFile, rigHkeyArray
   return someFile
end project_ProcessedHkeyArray


--> Project | Array | HkeyArray
-
function project_FetchHkeyArray hKey, pOverlayName, pMainStackHash
   -- fetch from hkey overlay
   local overlayArray, mainstackHash
   put project_HandlerMetadataFolder (hKey) into overlayFolder
   project_FetchOverlayArrayAndHash hKey, pOverlayName, overlayArray, mainstackHash
   if pMainStackHash is not empty and pMainStackHash is not mainstackHash then return empty
   put overlayArray_GetLinkArray (overlayArray) into hkeyArray
   return hkeyArray
end project_FetchHkeyArray

command project_StoreHkeyArray hKey, hkeyArray, pOverlayName, pMainstackHash, pGraphStyle
   -- store hKeyArray in hkey project metadata folder
   if pOverlayName is empty then put "hierarchical" into pOverlayName
   put project_HandlerMetadataFolder (hKey) into overlayFolder
   overlay_SetLinkArray overlayFolder, hkeyArray, pOverlayName, pGraphStyle, pMainstackHash
   return hkeyArray
end project_StoreHkeyArray

command project_FetchOverlayArrayAndHash hKey, pOverlayName, @overlayArray, @mainstackHash
   put project_HandlerMetadataFolder (hKey) into overlayFolder
   put overlay_GetArray (overlayFolder, pOverlayName) into overlayArray
   put overlayArray_GetMainStackHash (overlayArray) into mainstackHash
end project_FetchOverlayArrayAndHash


--> Project | Prefs | Model
-
/*
A project array stores everything a project depends on to function, as well as additional authoring metadata.
It is equivalent to the older "library set", and is currently stored as part of the library array keyd under the project name.
In the future we will split this out to metadata stored in the projects folder.
*/

function project_FetchPrefs pProjectName
   put project_FetchValue ("projectPrefsArray", pProjectName) into projectPrefsArray
   return projectPrefsArray
end project_FetchPrefs

command project_SavePrefs projectPrefsArray, pProjectName
   project_SaveValue "projectPrefsArray", projectPrefsArray, pProjectName
end project_SavePrefs


--> Project | Prefs | Global | Model
-
command project_DeleteGlobalPrefs
   put the globals into gNames
   replace comma with CR in gNames
   filter gNames with "gPrefs_*"
   repeat for each line gName in gNames  
      put "global" && gName & CR & "delete variable" && gName into doScript   
      do doScript
   end repeat
   return gNames
end project_DeleteGlobalPrefs

command project_LoadGlobalArray pProjectName
   global gLibrarySet_Array
   put project_FetchArray (pProjectName) into gLibrarySet_Array
   return gLibrarySet_Array
end project_LoadGlobalArray

command project_SaveGlobalArray pProjectName
   global gLibrarySet_Array
   project_SaveArray gLibrarySet_Array, pProjectName
   put the result into librarySetData
   return librarySetData
end project_SaveGlobalArray


--> Project | Array | Model
-
function project_FetchValue someKey, pProjectName
   put project_FetchArray (pProjectName) into projectArray
   put projectArray [someKey] into someValue
   return someValue
end project_FetchValue

command project_SaveValue someKey, someValue, pProjectName
   put project_FetchArray (pProjectName) into projectArray
   put someValue into projectArray [someKey]
   project_SaveArray projectArray, pProjectName
   return projectArray
end project_SaveValue

function project_FetchArray pProjectName
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   put library_FetchSetData() into librarySetData
   put librarySetData [pProjectName] into projectArray
   return projectArray
end project_FetchArray

command project_SaveArray projectArray, pProjectName
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   
   put library_FetchSetData() into librarySetData
   put projectArray into librarySetData [pProjectName]
   library_StoreSetData librarySetData
   return librarySetData
end project_SaveArray

command project_DeleteArray projectName
   -- was "library_DeleteStoredSet"
   -- maybe good idea to tidy globals here ???
   put library_FetchSetData() into modelArray
   delete variable modelArray [projectName]
   library_StoreSetData modelArray
   return modelArray
end project_DeleteArray


--> Project | Array | Metadata | Model
-
command project_StoreMetadata projectMetaData, projectName
   if projectName is empty then put project_GetCurrentName() into projectName
   put library_FetchSetData() into librarySetData
   put projectMetaData into librarySetData [projectName]["metadata"]
   library_StoreSetData librarySetData
   return librarySetData
end project_StoreMetadata

function project_GetUsedStacks pProjectName
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   put project_GetObjectTypeArray ("used", pProjectName) into objectArray
   put keys(objectArray) into stackObjects
   return stackObjects
end project_GetUsedStacks

command project_SetUsedStacks stackObjects, pProjectName
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   repeat for each line stackObject in stackObjects
      put empty into objectArray [stackObject]
   end repeat
   project_SetObjectTypeArray objectArray, "used", pProjectName
   put the result into librarySetData
   return librarySetData
end project_SetUsedStacks


--> Project | Array | ObjectTypeArray | Model
-
function project_GetObjectTypeArray libType, pProjectName
   -- was "project_GetLibraryArray"
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   put library_FetchSetData() into librarySetData
   put librarySetData [pProjectName]["data"][libType] into objectArray
   return objectArray
end project_GetObjectTypeArray

command project_SetObjectTypeArray objectArray, libType, pProjectName
   -- was "project_SetLibraryArray"
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   put library_FetchSetData() into librarySetData
   if objectArray is an array then
      put objectArray into librarySetData [pProjectName]["data"][libType]
   else
      delete variable librarySetData [pProjectName]["data"][libType]
   end if
   library_StoreSetData librarySetData
   return librarySetData
end project_SetObjectTypeArray


--> Project | Stackfiles
-
getprop project_StackFiles
   put the project_HomeStack of the target into stackFileStack
   return the stackfiles of stackFileStack
end project_StackFiles

setprop project_StackFiles stackFileTable
   put the project_HomeStack of me into stackFileStack
   set the stackfiles of stackFileStack to stackFileTable
end project_StackFiles


--> Project | Folder
-
function project_GetFolder someName, projectName
   put library_FetchSetArray (projectName) into setArray
   put setArray ["metadata"][someName]["folder"] into someFolder
   if char -1 of someFolder is not slash then put slash after someFolder
   return someFolder
end project_GetFolder

command project_SetFolder someName, projectName, someFolder
   if char -1 of someFolder is not slash then put slash after someFolder
   put library_FetchSetArray (projectName) into setArray
   put projectName into setArray ["metadata"]["library_SetName"] -- should be called "project_Name"
   put someFolder into setArray ["metadata"][someName]["folder"]
   library_StoreSetArray setArray, projectName
end project_SetFolder


--> Project
-
function project_GetCurrentName
   -- was "project_GetCurrentName"
   global gLibrarySet_Array
   put gLibrarySet_Array ["metadata"]["library_SetName"] into setName
   if setName is empty then put "Default" into setName
   return setName
end project_GetCurrentName

command project_SetCurrentName pSetName
   -- was "library_SetSetName"
   global gLibrarySet_Array
   if pSetName is empty then put "Default" into pSetName
   put pSetName into gLibrarySet_Array ["metadata"]["library_SetName"]
end project_SetCurrentName


--> Project | Start and Stop
-
command project_StartEnvironment projectName
   set the cursor to watch
   if projectName = "none" then return empty
   
   project_LoadGlobals projectName
   
   project_SetCurrentName projectName -- just in case it has been messed up
   project_StartBack projectName
   project_StartUsed projectName
   project_StartFront projectName
   
   put project_GetRevHackStatus (projectName) into someBoolean
   ide_AddBehaviorHacks someBoolean, true
   
   put "Added the Livecode hacks to the environment!" into someComment
   opn_Notify someComment
end project_StartEnvironment

command project_StopEnvironment
   put project_GetCurrentName() into projectName
   
   ide_AddBehaviorHacks false
   put "Removed the Livecode hacks from the environment!" into someComment
   opn_Notify someComment
   
   project_StopFront projectName
   project_StopBack projectName
   project_StopUsed projectName
   
   -- project_StoreGlobals -- too dangerous (do manually)
end project_StopEnvironment


--> Project | Environment
-
command environment_Start
   bash_AddSystemPathsToPATH
end environment_Start

command bash_AddSystemPathsToPATH
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
end bash_AddSystemPathsToPATH


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


--> Project | List
-
function project_ListStandardScriptOnlyFiles
   put project_ListStandardFiles() into longFiles
   filter longFiles with "*.livecodescript"
   return longFiles
end project_ListStandardScriptOnlyFiles

function project_ListStandardFiles pImportantPaths
   put "model,view,controller,library,behavior,library stacks" into folderNames
   repeat for each item folderName in folderNames
      put lcw_ListStackPaths (folderName) & CR after longFiles
   end repeat
   delete char -1 of longFiles
   
   if pImportantPaths is not empty then
      put pImportantPaths & CR before longFiles
   end if
   sort longFiles
   return word 1 to -1 of longFiles
end project_ListStandardFiles

function project_ListViewStackObjects pProjectName
   if pProjectName is empty then put "Default" into pProjectName
   put project_GetFolder ("Views", pProjectName) into viewFolder 
   put folder_ListShortStackFiles (viewFolder) into shortViewFiles
   put project_ConvertShortFilesToStackObjects (shortViewFiles, viewFolder) into viewStacks
   return viewStacks
end project_ListViewStackObjects


--> Project | Stackfiles
-
function project_FetchStackFiles pProjectName
   put project_FetchArray (pProjectName) into projectArray
   put projectArray ["data"]["stackfiles"] into stackFileTable
   return stackFileTable
end project_FetchStackFiles

command project_StoreStackFiles stackFileTable, pProjectName
   put project_FetchArray (pProjectName) into setArray
   put stackFileTable into setArray ["data"]["stackfiles"]
   project_SaveArray setArray, pProjectName
end project_StoreStackFiles


--> Project | hArray
-
/*
For now we don't store this data seperately for each project. We may do this in the future.
For now we just wrap the Library | Model | Array | gHkeyArray handlers
*/

command project_LoadGlobalHarray pProjectName
   global gHkey_Array
   put project_FetchHarray (pProjectName) into gHkey_Array
   return gHkey_Array
end project_LoadGlobalHarray

command project_SaveGlobalHarray pProjectName
   global gHkey_Array
   project_SaveHarray gHkey_Array, pProjectName
   put the result into arrayFile
   return arrayFile
end project_SaveGlobalHarray

function project_FetchHarray pProjectName
   -- if pProjectName is empty then put project_GetCurrentName() into pProjectName
   put library_FetchArray ("Hkey_Data") into hArray
   return hArray
end project_FetchHarray

command project_SaveHarray hArray, pProjectName
   -- if pProjectName is empty then put project_GetCurrentName() into pProjectName
   library_StoreArray "Hkey_Data", hArray
   put the result into arrayFile
   return arrayFile
end project_SaveHarray


--> Project | Globals
-
command project_LoadWorkingStackFiles pProjectName, pProjectHomeStack
   project_GuessHomeStack pProjectHomeStack
   put project_FetchStackFiles (pProjectName) into stackFileTable
   set the project_StackFiles of pProjectHomeStack to stackFileTable
end project_LoadWorkingStackFiles

command project_RestoreGlobalPrefs pProjectName
   -- was "libary_RestoreGlobalPrefs"   
   project_DeleteGlobalPrefs
   project_LoadGlobalPrefs pProjectName
   put the result into projectPrefsArray
   return projectPrefsArray
end project_RestoreGlobalPrefs

--> Project | Prefs
-
function project_GatherGlobalPrefs
   -- was "library_ConstructPrefsArray" then "project_GatherPrefsArray"
   -- gathers all appropriately named globals into a single array for storage.
   
   put the globals into gNames
   replace comma with CR in gNames
   filter gNames with "gPrefs_*"
   repeat for each line gName in gNames  
      put "global" && gName & CR & "get" && gName into doScript   
      do doScript
      put it into prefsArray [gName]
   end repeat
   return prefsArray
end project_GatherGlobalPrefs

command project_LoadGlobalPrefs pProjectName
   -- this loads the globals without clearing any of the others
   put project_FetchPrefs (pProjectName) into projectPrefsArray
   global_Load projectPrefsArray -- now let's load the globals
   return projectPrefsArray
end project_LoadGlobalPrefs

command project_SaveGlobalPrefs pProjectName
   /*
   -- was "library_StoreGlobalPrefs"
   Save the current globals beginning with "gPRefs_" to the project section of the library set array.
   
   Any global beginning with gPrefs_* is automatically stored in the project section of the library set array
   It is no longer stored in the users preference folder (these are project preferences)
   Do not store passwords or other sensitive information, as these may be checked out publicall on GitHub.
   */
   
   put project_GatherGlobalPrefs () into projectPrefsArray
   project_SavePrefs projectPrefsArray, pProjectName
   return prefsArray
end project_SaveGlobalPrefs

command project_GuessHomeStack @projectHomeStack
   if projectHomeStack is empty then
      put the project_HomeStack of the target into projectHomeStack
      if projectHomeStack is empty then
         put the stack_Object of the target into projectHomeStack
      end if
   end if
end project_GuessHomeStack


--> Project | Start and Stop | Deps
-
command project_StartUsed pProjectName
   put project_FetchObjects ("used", pProjectName) into stackObjects
   stack_StartUsed stackObjects
   _setRescueStackLabel
end project_StartUsed

command project_StopUsed pProjectName
   put project_FetchObjects ("used", pProjectName) into stackObjects
   stack_StopUsed stackObjects
end project_StopUsed

command project_StartBack pProjectName
   put project_FetchObjects ("back", pProjectName) into backObjects
   repeat for each line someObject in backObjects
      if exists(someObject) then
         insert the script of someObject into back
      end if
   end repeat
end project_StartBack

command project_StopBack pProjectName
   put project_FetchObjects ("back", pProjectName) into backObjects
   repeat for each line someObject in backObjects
      if exists(someObject) then
         remove the script of someObject from back
      end if
   end repeat
end project_StopBack

command project_StartFront pProjectName
   put project_FetchObjects ("front", pProjectName) into frontObjects
   repeat for each line someObject in frontObjects
      if exists(someObject) then
         insert the script of someObject into front
      end if
   end repeat
   return frontObjects
end project_StartFront

command project_StopFront pProjectName
   -- renamed from "library_StopFront"
   put project_FetchObjects ("front", pProjectName) into frontObjects
   repeat for each line someObject in frontObjects
      if exists(someObject) then
         remove the script of someObject from front
      end if
   end repeat
end project_StopFront

function project_GetRevHackStatus pSetName
   if pSetName is empty then put project_GetCurrentName() into pSetName
   put library_FetchSetData() into librarySetData
   put librarySetData [pSetName]["data"]["rev_AddBehaviorHacks"] is true into someBoolean
   return someBoolean
end project_GetRevHackStatus

command project_SetRevHackStatus someBoolean, pSetName
   if pSetName is empty then put project_GetCurrentName() into pSetName
   put library_FetchSetData() into librarySetData
   put someBoolean is true into librarySetData [pSetName]["data"]["rev_AddBehaviorHacks"]
   library_StoreSetData librarySetData
   return librarySetData
end project_SetRevHackStatus

function project_FetchObjects libType, pProjectName
   -- renamed to project and removed switch complexity from "library_FetchObjectTypeArray"
   put project_FetchObjectTypeArray (libType, pProjectName) into libTypeArray
   put keys (libTypeArray) into someObjects
   sort someObjects
   return someObjects
end project_FetchObjects

function project_FetchObjectTypeArray libType, pProjectName
   -- renamed to project and removed switch complexity from "library_FetchObjectTypeArray"
   put library_FetchSetData() into setData
   put setData [pProjectName]["data"][libType] into libTypeArray
   return libTypeArray
end project_FetchObjectTypeArray


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

function project_FindShortUsedViewFiles pProjectName
   put project_FindUsedViewStacks (pProjectName) into stackObjects
   put project_ConvertStackObjectsToShortFiles (stackObjects) into usedShortViewStackFiles
   return usedShortViewStackFiles
end project_FindShortUsedViewFiles

function project_FindUsedViewStacks pProjectName
   put project_ListViewStackObjects (pProjectName) into viewStacks
   put stack_CheckStackMetadata (viewStacks) into usedViewStacks
   return usedViewStacks
end project_FindUsedViewStacks

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


--> Project | Start and Stop | Deps
-
command _setRescueStackLabel
   put _constructRescueStackLabel() into rescueStackLabel
   set the label of this stack to rescueStackLabel
end _setRescueStackLabel

private function _constructRescueStackLabel
   put project_GetCurrentName() into currentProjectName
   put the short name of this stack into rescueStackName
   put rescueStackName && "(" & currentProjectName & ")" into rescueStackLabel
   return rescueStackLabel
end _constructRescueStackLabel

command stack_StartUsed stackObjects
   repeat for each line stackObject in stackObjects
      if exists(stackObject) and word 1 of stackObject is "stack" then
         try
            start using stackObject
         catch someError
            put stackObject
            answer someError
         end try
      end if
   end repeat
end stack_StartUsed

command stack_StopUsed stackObjects
   repeat for each line stackObject in stackObjects
      if exists(stackObject) and word 1 of stackObject is "stack" then
         stop using stackObject
      end if
   end repeat
end stack_StopUsed


--> Library | To Sort
-
function library_ListStackFileNames folderGroupName, pProjectName
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   put project_GetFolder (folderGroupName, pProjectName) into someFolder 
   put folder_ListStackFileNames (someFolder) into stackFileNames
   return stackFileNames
end library_ListStackFileNames

function library_ListShortFiles folderGroupName, pProjectName
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   put project_GetFolder (folderGroupName, pProjectName) into someFolder 
   put folder_ListShortStackFiles (someFolder) into goodShortFiles
   return goodShortFiles
end library_ListShortFiles

function folder_ListStackFileNames someFolder
   if char -1 of someFolder is not slash then put slash after someFolder
   put the defaultfolder into oFolder
   set the defaultfolder to someFolder
   put the files into shortFiles
   repeat for each line shortFile in shortFiles
      if there is a stack shortFile then
         put someFolder & shortFile & CR after stackFileNames
      end if
   end repeat
   delete char -1 of stackFileNames
   set the defaultfolder to oFolder
   return stackFileNames
end folder_ListStackFileNames

command library_SetUsed shortStackNames, pSetName
   if pSetName is empty then put project_GetCurrentName() into pSetName
   
   repeat for each line shortStackName in shortStackNames
      put the name of stack shortStackName into stackObject
      put empty into objectArray [stackObject]
   end repeat
   
   project_SetObjectTypeArray objectArray, "used", pSetName
   put the result into librarySetData
   return librarySetData
end library_SetUsed

command library_SetFrontArray frontArray, pSetName
   project_SetObjectTypeArray frontArray, "front", pSetName
   return the result
end library_SetFrontArray

command library_SetBackArray backArray, pSetName
   project_SetObjectTypeArray backArray, "back", pSetName
   return the result
end library_SetBackArray


--> Library | Model | Array
-
function library_FetchArray shortName
   put library_ArrayFile (shortName) into someFile
   put array_Fetch (someFile) into modelArray
   return modelArray
end library_FetchArray

command library_StoreArray shortName, dataArray
   put library_ArrayFile (shortName) into someFile
   array_Save someFile, dataArray
   return someFile
end library_StoreArray

function library_ArrayFile shortName, pDontCreate
   put shortName & ".array" into shortFile
   put library_ArrayFolder (shortFile, pDontCreate) into someFile
   return someFile
end library_ArrayFile

function library_ArrayFolder shortFileBit, pDontCreate
   return library_PluginFolder ("opn_Text/array/", pDontCreate) & shortFileBit
end library_ArrayFolder

function library_PluginFolder pSubFolder, pDontCreate
   put revEnvironmentUserPluginsPath() & "/" into opnRootFolder
   put opnRootFolder & "opn_Plugins/" into someFolder
   
   if pSubFolder is not empty then
      folder_Format pSubFolder   
      put pSubFolder after someFolder
   end if
   
   if pDontCreate is not true then folder_CreateNested someFolder
   return someFolder
end library_PluginFolder


--> From older model_Project (all handlers below so some duplication with older versions below)
-
function project_GetUsedStacks pProjectName
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   put project_GetObjectTypeArray ("used", pProjectName) into objectArray
   put keys(objectArray) into stackObjects
   return stackObjects
end project_GetUsedStacks

command project_SetUsedStacks stackObjects, pProjectName
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   repeat for each line stackObject in stackObjects
      put empty into objectArray [stackObject]
   end repeat
   project_SetObjectTypeArray objectArray, "used", pProjectName
   put the result into librarySetData
   return librarySetData
end project_SetUsedStacks

function project_GetObjectTypeArray libType, pProjectName
   -- was "project_GetLibraryArray"
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   put library_FetchSetData() into librarySetData
   put librarySetData [pProjectName]["data"][libType] into objectArray
   return objectArray
end project_GetObjectTypeArray

command project_SetObjectTypeArray objectArray, libType, pProjectName
   -- was "project_SetLibraryArray"
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   put library_FetchSetData() into librarySetData
   if objectArray is an array then
      put objectArray into librarySetData [pProjectName]["data"][libType]
   else
      delete variable librarySetData [pProjectName]["data"][libType]
   end if
   library_StoreSetData librarySetData
   return librarySetData
end project_SetObjectTypeArray

command project_StoreMetadata projectMetaData, pSetName
   if pSetName is empty then put project_GetCurrentName() into pSetName
   put library_FetchSetData() into librarySetData
   put projectMetaData into librarySetData [pSetName]["metadata"]
   library_StoreSetData librarySetData
   return librarySetData
end project_StoreMetadata

--> Project | Objects
-
function project_FetchObjects libType, pProjectName
   -- renamed to project and removed switch complexity from "library_FetchObjectTypeArray"
   put project_FetchObjectTypeArray (libType, pProjectName) into libTypeArray
   put keys (libTypeArray) into someObjects
   sort someObjects
   return someObjects
end project_FetchObjects

function project_FetchObjectTypeArray libType, pProjectName
   -- renamed to project and removed switch complexity from "library_FetchObjectTypeArray"
   put library_FetchSetData() into setData
   put setData [pProjectName]["data"][libType] into libTypeArray
   return libTypeArray
end project_FetchObjectTypeArray


--> Project | Handler
-
function project_FetchHandlerHelp hKey
   put project_HandlerHelpFile (hKey) into someFile
   if someFile is empty then return empty
   put url ("binfile:" & someFile) into helpHtml
   return helpHtml
end project_FetchHandlerHelp

command project_StoreHandlerHelp hKey, helpHtml
   put project_HandlerHelpFile (hKey, false) into someFile
   if someFile is empty then return empty
   put helpHtml into url ("binfile:" & someFile)
   return someFile
end project_StoreHandlerHelp

function project_FetchHandler hKey  
   put project_HandlerFile (hKey) into someFile
   if someFile is empty then return empty
   put url ("binfile:" & someFile) into someHandler
   return someHandler
end project_FetchHandler

command project_StoreHandler hKey, someHandler
   put project_HandlerFile (hKey, false) into someFile
   if someFile is empty then return empty
   put someHandler into url ("binfile:" & someFile)
end project_StoreHandler


--> Project | Files | List
-
function project_ListViewStackObjects pProjectName
   if pProjectName is empty then put "Default" into pProjectName
   put project_GetFolder ("Views", pProjectName) into viewFolder 
   put folder_ListShortStackFiles (viewFolder) into shortViewFiles
   put project_ConvertShortFilesToStackObjects (shortViewFiles, viewFolder) into viewStacks
   return viewStacks
end project_ListViewStackObjects

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


--> Project | Folders | Handlers
-
function project_HandlerMetadataFolder hKey, pDontCreate
   -- for the handler/hkey library metadata is in the same folder as the scripts
   -- in the project handler export - handlers and metadata are in separate roots.
   put item 3 of hKey into hObject
   if exists (hObject) is false then return empty
   
   put the object_MetaDataFolder [pDontCreate] of hObject into metadataFolder
   
   put item 1 of hKey & "_" & item 2 of hKey into folderName
   put metadataFolder & "handlers/" & folderName & "/" into handlerFolder
   if pDontCreate is false then folder_CreateNested handlerFolder
   return handlerFolder
end project_HandlerMetadataFolder

function project_GetHandlerFolder hKey, pDontCreate
   put item 3 of hKey into hObject
   if exists (hObject) is false then return empty
   put the object_Folder of hObject into objectFolder
   
   put item 1 to 2 of hKey into shortHkey
   put objectFolder_HandlerFolder (shortHkey, objectFolder, pDontCreate) into projectHandlerFolder
   return projectHandlerFolder
end project_GetHandlerFolder


--> Deps
-
command global_Load globalDataArray
   repeat for each key gName in globalDataArray
      if the number of words of gName is not 1 then next repeat -- safety check
      put globalDataArray [gName] into globalValue
      put "global" && gName & CR & "put globalValue into" && gName into doScript
      do doScript
   end repeat
end global_Load


--> Currently Working On | Rename
-
function scriptObject_ImageFile scriptObject, pOverlayName
   put the object_MetaDataFolder [true] of scriptObject into scriptFolder
   scriptObject_NormalizeGraphName pOverlayName, scriptFolder
   put pOverlayName & "." & "png" into shortFile
   put scriptFolder & shortFile into someFile
   return someFile
end scriptObject_ImageFile

function hkey_LibraryImagetFile hKey, pOverlayName
   put library_HandlerMetadataFolder (hKey, true) into overlayFolder
   put overlay_GetImageFile (overlayFolder, pOverlayName) into imageFile
   return imageFile
end hkey_LibraryImagetFile

function hkey_ProjectImageFile hKey, pOverlayName
   -- could be "project_HkeyImageFile"
   -- see "script_GraphImageFile" "scriptObject_ImageFile"
   put project_HandlerMetadataFolder (hKey, true) into overlayFolder
   put overlay_GetImageFile (overlayFolder, pOverlayName) into imageFile
   return imageFile
end hkey_ProjectImageFile

function stackArray_ConstructObjectFolder textStackFolder, objectBit, pSubStackName
   put "data" into dataOrMetadata
   set the itemdelimiter to "/"
   put item -1 of textStackFolder into mainstackName
   if pSubStackName is empty then
      put textStackFolder & dataOrMetadata & "/objects/" into stackFolder
   else
      put textStackFolder & dataOrMetadata & "/objects/substacks/" & pSubStackName & "/" into stackFolder
      -- put dataOrMetadata & "/objects/"  after stackFolder
   end if 
   put stackFolder & objectBit into objectFolder
   return objectFolder
end stackArray_ConstructObjectFolder

function objectFolder_ScriptFile objectFolder, pDontCreate
   -- was "project_ScriptFile"
   -- returns the same as the script_File
   if pDontCreate is false then
      folder_CreateNested handlerFolder
   else
      folder_Format objectFolder
   end if
   put objectFolder & "script.txt" into someFile
   return someFile
end objectFolder_ScriptFile

function objectFolder_HandlerFolder shortHkey, objectFolder, pDontCreate
   folder_Format objectFolder
   put item 1 shortHkey & "_" & item 2 of shortHkey into folderName
   put objectFolder & "handlers/" & folderName & "/" into handlerFolder
   if pDontCreate is false then folder_CreateNested handlerFolder
   return handlerFolder
end objectFolder_HandlerFolder

function object_FromScriptFolder scriptFileOrFolder
   set the itemdelimiter to "/"
   
   if item -1 of scriptFileOrFolder = "script.txt" then delete item -1 of scriptFileOrFolder
   if item -2 of scriptFileOrFolder = "handlers" then delete item -2 to -1 of scriptFileOrFolder
   
   put item -1 of scriptFileOrFolder into objectBit
   replace "_" with " id " in objectBit
   
   if item -3 of scriptFileOrFolder = "substacks" then
      put item -2 of scriptFileOrFolder into subStackName
      put item -6 of scriptFileOrFolder into mainStackName
      if objectBit = "stack" then
         put "stack" && kwote (subStackName) && "of stack" && kwote (mainStackName) into someObject
      else
         put objectBit && "of stack" && kwote (subStackName) && "of stack" && kwote (mainStackName) into someObject
      end if
   else
      put item -4 of scriptFileOrFolder into mainStackName
      if objectBit = "stack" then
         put "stack" && kwote (mainStackName) into someObject
      else
         put objectBit && "of stack" && kwote (mainStackName) into someObject
      end if
   end if
   return someObject
end object_FromScriptFolder

function folder_ListShortStackFiles someFolder
   put the defaultfolder into oFolder
   set the defaultfolder to someFolder
   put the files into shortFiles
   repeat for each line shortFile in shortFiles
      if there is a stack shortFile then
         put shortFile & CR after shortStackFiles
      end if
   end repeat
   delete char -1 of shortStackFiles
   set the defaultfolder to oFolder
   return shortStackFiles
end folder_ListShortStackFiles

function folder_ListShortLivecodeFiles someFolder
   put the defaultfolder into oFolder
   set the defaultfolder to someFolder
   put the files into shortFiles
   set the itemdelimiter to "."
   repeat for each line shortFile in shortFiles
      if item -1 of shortFile is among the items of "lc.livecode.livecodescript.rev.mc" then
         put shortFile & CR after shortStackFiles
      end if
   end repeat
   delete char -1 of shortStackFiles
   set the defaultfolder to oFolder
   return shortStackFiles
end folder_ListShortLivecodeFiles
