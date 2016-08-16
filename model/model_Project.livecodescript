script "model_Project"
--> MetaData
-
license: GPLv3
name: model_Project
type: model
version: 0.7

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


command project_GuessHomeStack @projectHomeStack
   if projectHomeStack is empty then
      put the project_HomeStack of the target into projectHomeStack
      if projectHomeStack is empty then
         put the stack_Object of the target into projectHomeStack
      end if
   end if
end project_GuessHomeStack


--> Old | Library | Sets
-
function library_FetchSetsContaining ruggedObject, libType
   put library_FetchProjectData() into modelArray
   repeat for each key setName in modelArray
      put modelArray [setName]["data"][libType] into libTypeArray
      put keys (libTypeArray) into rObjects
      if ruggedObject is among the lines of rObjects then
         put setName & CR after setNames
      end if
   end repeat
   delete char -1 of setNames
   return setNames
end library_FetchSetsContaining

command library_RemoveSetNamesFromStore ruggedObject, libType, setNames
   put library_FetchProjectData() into setData
   repeat for each line setName in setNames
      delete variable setData [setName]["data"][libType][ruggedObject]
   end repeat
   library_StoreProjectData setData
   return setData
end library_RemoveSetNamesFromStore

command library_StoreSetNames ruggedObject, libType, setNames
   put library_FetchProjectData() into modelArray
   put keys(modelArray) into otherSetNames
   -- add
   repeat for each line setName in setNames
      put empty into modelArray [setName]["data"][libType][ruggedObject]
      line_Delete setName, otherSetNames
   end repeat
   -- remove from the rest
   repeat for each line setName in otherSetNames
      delete variable modelArray [setName]["data"][libType][ruggedObject]
   end repeat
   library_StoreProjectData modelArray
   return modelArray
end library_StoreSetNames


--> Working on
-

--> Project | List
-
function project_ListBehaviorStackNames pProjectNames
   switch pProjectNames
      case empty
         put "LCW" into pProjectNames
         break
      case "All"
         put library_ListProjectNames() into pProjectNames
         break
   end switch
   
   repeat for each line projectName in pProjectNames
      if exists (stack projectName) is false then next repeat
      put the project_StackNames ["behavior"] of stack projectName & CR after bNames
   end repeat
   sort bNames
   put word 1 to -1 of bNames into bNames
   return bNames
end project_ListBehaviorStackNames


--> Project | Stackfiles
-
function project_FetchStackFiles pProjectName
   put library_FetchProjectArray (pProjectName) into projectArray
   put projectArray ["data"]["stackfiles"] into stackFileTable
   return stackFileTable
end project_FetchStackFiles

command project_StoreStackFiles stackFileTable, pProjectName
   put library_FetchProjectArray (pProjectName) into projectArray
   put stackFileTable into projectArray ["data"]["stackfiles"]
   library_StoreProjectArray pProjectName, projectArray
end project_StoreStackFiles


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

function project_ListUsedStacks projectName
   put the project_StackObjects ["library"] of stack projectName into usedStackObjects
   put the project_StackObjects ["model"] of stack projectName & CR before usedStackObjects
   sort usedStackObjects
   return word 1 to -1 of usedStackObjects
end project_ListUsedStacks

getprop project_StackNames [folderName]
   put the project_Folder [folderName] of the target into standardFolder
   if standardFolder is empty then return empty
   put folder_ListStackNames (standardFolder) into stackNames
   return stackNames
end project_StackNames

getprop project_StackObjects [folderName]
   put the project_Folder [folderName] of the target into standardFolder
   if standardFolder is empty then return empty
   put folder_ListStackObjects (standardFolder) into stackObjects
   return stackObjects
end project_StackObjects

getprop project_StackPaths [folderName]
   -- if the folder does not exist this handler return empty
   put the project_Folder [folderName] of the target into standardFolder
   if standardFolder is empty then return empty
   
   -- ensures the returned long paths are valid references to stacks that exist
   put folder_ListStackPaths (standardFolder) into stackPaths
   return stackPaths
end project_StackPaths

getprop project_StackFiles
   put the project_HomeStack of the target into projectHomeStack
   put the stackfiles of projectHomeStack into stackFileTable
   return stackFileTable
end project_StackFiles

setprop project_StackFiles stackFileTable
   put the project_HomeStack of the target into projectHomeStack
   set the stackfiles of projectHomeStack to stackFileTable
   return projectHomeStack
end project_StackFiles


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
   put project_GetNamedFolder ("Views", pProjectName) into viewFolder 
   put folder_ListShortStackFiles (viewFolder) into shortViewFiles
   put project_ConvertShortFilesToStackObjects (shortViewFiles, viewFolder) into viewStacks
   return viewStacks
end project_ListViewStackObjects


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
   put library_FetchProjectData() into librarySetData
   put librarySetData [pSetName]["data"]["rev_AddBehaviorHacks"] is true into someBoolean
   return someBoolean
end project_GetRevHackStatus

command project_SetRevHackStatus someBoolean, pSetName
   if pSetName is empty then put project_GetCurrentName() into pSetName
   put library_FetchProjectData() into librarySetData
   put someBoolean is true into librarySetData [pSetName]["data"]["rev_AddBehaviorHacks"]
   library_StoreProjectData librarySetData
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
   put library_FetchProjectData() into setData
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
   put project_GetNamedFolder (folderGroupName, pProjectName) into someFolder 
   put folder_ListStackFileNames (someFolder) into stackFileNames
   return stackFileNames
end library_ListStackFileNames

function library_ListShortFiles folderGroupName, pProjectName
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   put project_GetNamedFolder (folderGroupName, pProjectName) into someFolder 
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
   put library_FetchProjectData() into librarySetData
   put librarySetData [pProjectName]["data"][libType] into objectArray
   return objectArray
end project_GetObjectTypeArray

command project_SetObjectTypeArray objectArray, libType, pProjectName
   -- was "project_SetLibraryArray"
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   put library_FetchProjectData() into librarySetData
   if objectArray is an array then
      put objectArray into librarySetData [pProjectName]["data"][libType]
   else
      delete variable librarySetData [pProjectName]["data"][libType]
   end if
   library_StoreProjectData librarySetData
   return librarySetData
end project_SetObjectTypeArray


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
   put library_FetchProjectData() into setData
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
   put project_GetNamedFolder ("Views", pProjectName) into viewFolder 
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
      text_AddTrailing objectFolder, slash
   end if
   put objectFolder & "script.txt" into someFile
   return someFile
end objectFolder_ScriptFile

function objectFolder_HandlerFolder shortHkey, objectFolder, pDontCreate
   text_AddTrailing objectFolder, slash
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
