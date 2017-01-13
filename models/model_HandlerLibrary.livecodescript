script "model_HandlerLibrary"
--> MetaData
-
license: GPLv3
name: model_HandlerLibrary
type: model
version: 0.6

/*
Model for fetching and saving handlers and calls to the new handler library.

We are moving away from the idea of a separate repository for library handlers.
Publishing a handler is now going to be the same as publishing a project - that is a folder in GitHub

These projects will contain libs, and models, and back and front scripts
We will also publish handlers in behaviors that are not marked private or are getprop and setprop handlers
The assumption is that these "could" be used in a general sense. The sense of publishing now is to add them to a globa index of handlers that point to the pubished projects.

This global database does not need to store a separate copies of the handlers.
It should also be used to find dependcies fast, and to be created fast by looping through the project files.

More things named handler_XXX over at suite "--> Handler Index" in stack lib_Hkey

Moving over to storing handler calls in hTableLine format.

The reasons for moving over from old comma based hKeys to new format are:

- 1) revAvailableHandlers returns in the hTableLine word based format
- 2) The tree widget does nto work well with keys that contain commas
- 3) It reads better on screen and in the wiki
*/


--> Working on
-

--> Handler | Library | Props
-
getprop exported_Handler [shortHkey]
   put the data_Folder of the target into dataFolder
   put handler_Fetch (shortHkey, dataFolder) into someHandler
   return someHandler
end exported_Handler

setprop exported_Handler [shortHkey] someHandler
   put the data_Folder of the target into dataFolder
   handler_Save shortHkey, dataFolder, someHandler
end exported_Handler

getprop handler_File [shortHkey]
   put the data_Folder [true] of the target into dataFolder
   put textStack_HandlerFile (shortHkey, dataFolder) into handlerFile
   return handlerFile
end handler_File

getprop handler_Folder [shortHkey]
   -- /lcw_User/lcw_Metadata/LCW/data/objects/stack/handlers/
   put the data_Folder [true] of the target into dataFolder
   if shortHkey is empty then
      put dataFolder & "handlers/" into handlerFolderRoot
      return handlerFolderRoot
   else
      put textStack_HandlerDataFolder (shortHkey, dataFolder) into handlerFolder
      return handlerFolder
   end if
end handler_Folder

--> hKey | Handler | Model
-
function hkey_FetchHandler hKeyLine
   hKey_Deconstruct hKeyLine, hName, hType, hObject, hNum
   if exists (hObject) is false then return empty
   put the data_Folder of hObject into dataFolder
   put handler_Fetch (hKeyLine, dataFolder) into someHandler
   return someHandler
end hkey_FetchHandler

command hkey_StoreHandler hKey, someHandler 
   put hkey_HandlerFile (hKey, false) into someFile
   if someHandler is empty then
      delete file someFile
   else
      script_SaveRaw someFile, someHandler
   end if
end hkey_StoreHandler

command hkey_ExportHandler hKey, pExportCalls
   hKey_Deconstruct hKey, hName, hType, hObject, hNum
   if exists (hObject) is false then return empty
   put the data_Folder of hObject into dataFolder
   put handler_Fetch (hKey, dataFolder) into someHandler
   
   handler_Save hKey, dataFolder, someHandler, pExportCalls
   return someHandler
end hkey_ExportHandler



--> Handler | DataFolder | Model
-
/*
These handlers extract handlers from exported handler files
For handlers that work on exported handlers see "model_Script"
*/

function handler_Fetch shortHkey, dataFolder
   put textStack_HandlerFile (shortHkey, dataFolder, true) into handlerFile
   put script_FetchRaw (handlerFile) into someHandler
   return someHandler
end handler_Fetch

command handler_Save shortHkey, dataFolder, someHandler, pExportCalls
   put textStack_HandlerFile (shortHkey, dataFolder, false) into handlerFile
   script_SaveRaw handlerFile, someHandler
   if pExportCalls is true then
      handler_ProcessAndExportCalls shortHkey, dataFolder, someHandler
      put the result into shortCalls
      put shortHkey & CR & dataFolder & CR & shortCalls
   end if
   return handlerFile
end handler_Save

command handler_ProcessAndExportCalls hkeyLine, dataFolder, someHandler, pSkipHkeyComponents, pSkipHkeyProps
   -- /lcw_User/lcw_Metadata/lib_Update/data/objects/stack/lcw_calls.txt
   
   put handler_ConstructCallArray (someHandler, pSkipHkeyComponents, pSkipHkeyProps) into handlerCallArray
   -- put handlerCallArray ["filteredCalls"] into shortCalls   
   put handlerCallArray ["hkeyCalls"] into shortCalls
   
   handler_StoreCalls hkeyLine, dataFolder, shortCalls  
   return shortCalls 
end handler_ProcessAndExportCalls


--> hkey | Handler | File
-
function hkey_HandlerFile hKey, pDontCreate
   put hkey_DataFolder (hKey, pDontCreate) into dataFolder
   put textStack_HandlerFile (hKey, dataFolder) into handlerFile
   return handlerFile
   -- return hkey_Folder (hKey, pDontCreate) & "script.txt"
end hkey_HandlerFile

function textStack_HandlerFile shortHkey, dataFolder
   -- see also "hkey_HandlerFile"
   put textStack_HandlerDataFolder (shortHkey, dataFolder) & "lcw_handler.txt" into handlerFile
   return handlerFile
end textStack_HandlerFile

command hkey_DeleteHandlerFile hKey
   put hkey_HandlerFile (hKey) into someFile
   delete file someFile
end hkey_DeleteHandlerFile


-->  Hkey | Folder | Model
-
function hkey_Folder hKey
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   if exists (hObject) is false then return empty
   
   put the data_Folder [true] of hObject into dataFolder
   put textStack_HandlerDataFolder (hKey, dataFolder) into handlerFolder
   return handlerFolder
end hkey_Folder

command hkey_DeleteFolder hKey
   put hkey_Folder (hKey) into hkeyFolder
   revDeleteFolder hkeyFolder
end hkey_DeleteFolder


--> Script | General | Model
-
/*
These work for handlers and scripts.
If you use these handlers then we have a single place to test / switch / ensure we use the correct binary or text encoding for stored script files.
At one time Git was not dealing with Livecode OSX files for instance.
*/

function script_FetchRaw scriptFile
   put url ("binfile:" & scriptFile) into someScript
   -- hack_UpdateBinFile someScript, scriptFile
   return someScript
end script_FetchRaw

command script_SaveRaw scriptFile, someScript
   put scriptFile into scriptFolder
   set the itemdelimiter to slash
   put empty into item -1 of scriptFolder
   folder_CreateNested scriptFolder
   
   put someScript into url ("binfile:" & scriptFile)
   return the result
end script_SaveRaw


