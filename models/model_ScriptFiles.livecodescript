script "model_ScriptFiles"
--> MetaData
-
license: GPLv3
name: model_ScriptFiles
type: model
version: 0.9


--> Working on
-
/*
We are moving over from old comma based hKeys to new format.
This is for the following reasons:

- 1) revAvailable handlers returns in this format
- 2) the tree widget does nto work well with keys that contain commas
- 3) It reads better on screen and in the wiki
*/

function textStack_ConstructDataFolder mainStackName, pStackName, pLongObjectID
   -- same functionality as "getprop data_Folder"
   
   put textStack_ConstructFolder (mainStackName) into textStackFolder -- textStack_Folder
   put textStackFolder & "data/" into textStackDataFolder
   
   switch pStackName
      case empty
      case mainStackName
         put textStackDataFolder & "objects/" into dataFolder
         break
      default
         put textStackDataFolder & "objects/substacks/" & pStackName & "/" into dataFolder
   end switch
   
   switch word 1 of pLongObjectID
      case empty
      case "stack"
         put "stack/" after dataFolder
         break
      default
         put word 1 of pLongObjectID & "_" & word 3 of pLongObjectID & "/" after dataFolder
   end switch
   return dataFolder
end textStack_ConstructDataFolder

getprop data_Folder [pDontCreate]
   -- /lcw_User/lcw_Metadata/LCW/data/objects/stack/
   -- where the script_File, handler_Folder and other data related to the object is stored.
   
   put the long id of the target into someObject
   put the textStack_DataFolder [true] of someObject into textStackDataFolder
   
   put the stack_Object of someObject into stackObject
   if exists (stackObject) is false then
      breakpoint
      return empty
   end if
   put the short name of stackObject into stackName
   put the mainstack of stackObject into mainStackName
   
   if stackName = mainStackName then
      put textStackDataFolder & "objects/" into dataFolder
   else
      put textStackDataFolder & "objects/substacks/" & stackName & "/" into dataFolder
   end if
   
   switch word 1 of someObject
      case "stack"
         put "stack/" after dataFolder
         break
      default
         put word 1 of someObject & "_" & word 3 of someObject & "/" after dataFolder
   end switch
   if pDontCreate is not true then folder_CreateNested dataFolder
   return dataFolder
end data_Folder



--> Handler Library | Props
-
getprop handler_Help [shortHkey]
   put item 1 to 2 of shortHkey into hKey
   put the rugged_ID of the target into item 3 of hKey
   put 1 into item 4 of hKey
   return project_FetchHandlerHelp (hKey)
end handler_Help

setprop handler_Help [shortHkey] helpHtml
   put the rugged_ID of the target into rObject
   
   put item 1 to 2 of shortHkey into hKey
   put rObject into item 3 of hKey
   put 1 into item 4 of hKey
   
   put the script_Hkeys of rObject into availableHkeys
   set the wholematches to true
   if hKey is not among the lines of availableHkeys then return empty
   
   project_StoreHandlerHelp hKey, helpHtml
   put the result into helpFile
   return helpFile
end handler_Help


--> Working on
-
/*
Need to rename these "project" handlers to "object_"
*/

getprop project_ProcessedHkeyArrayFile
   -- this puts object hkeyarray files in the project overlay folder (wrong place)
   -- fix so it (and related handlers) use 
   put the project_OverlayFolder of the target into projectOverlayFolder
   put projectOverlayFolder & "processedHkey.array" into someFile
   return someFile
end project_ProcessedHkeyArrayFile

getprop project_OverlayFolder
   -- no such thing anymore? Same as data_Folder?
   
   put the textStack_Folder of the target into textStackFolder
   put textStackFolder & "metadata/project/overlay/" into projectOverlayFolder
   return projectOverlayFolder
end project_OverlayFolder

function project_HandlerMetadataFolder hKey, pDontCreate
   -- for the handler/hkey library metadata is in the same folder as the scripts
   -- in the project handler export - handlers and metadata are in separate roots.
   put item 3 of hKey into hObject
   if exists (hObject) is false then return empty
   
   put the textStack_MetadataFolder [pDontCreate] of hObject into metadataFolder
   
   put item 1 of hKey & "_" & item 2 of hKey into folderName
   put metadataFolder & "handlers/" & folderName & "/" into handlerFolder
   if pDontCreate is false then folder_CreateNested handlerFolder
   return handlerFolder
end project_HandlerMetadataFolder

function project_HandlerHelpFile hKey, pDontCreate
   return project_HandlerMetadataFolder (hKey, pDontCreate) & "help.html"
end project_HandlerHelpFile


function scriptObject_ImageFile scriptObject, pOverlayName
   put the textStack_MetadataFolder [true] of scriptObject into scriptFolder
   scriptObject_NormalizeGraphName pOverlayName, scriptFolder
   put pOverlayName & "." & "png" into shortFile
   put scriptFolder & shortFile into someFile
   return someFile
end scriptObject_ImageFile

function hkey_ProjectImageFile hKey, pOverlayName
   -- could be "project_HkeyImageFile"
   -- see "script_GraphImageFile" "scriptObject_ImageFile"
   put project_HandlerMetadataFolder (hKey, true) into overlayFolder
   put overlay_GetImageFile (overlayFolder, pOverlayName) into imageFile
   return imageFile
end hkey_ProjectImageFile


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


--> Script | Object File Properteis
-
getprop script_HelpFile [pDontCreate]
   put the long id of the target into scriptObject
   put the textStack_MetadataFolder [pDontCreate] of scriptObject into metadataFolder
   put metadataFolder & "help.html" into someFile
   return someFile
end script_HelpFile

getprop script_HelpFile [pDontCreate]
   put the long id of the target into scriptObject
   put the textStack_MetadataFolder [pDontCreate] of scriptObject into metadataFolder
   put metadataFolder & "help.html" into someFile
   return someFile
end script_HelpFile

getprop script_OverlayFile [pDontCreate]
   put the long id of the target into scriptObject
   put the overlay_Folder [pDontCreate] of scriptObject into overlayFolder
   
   -- put overlayFolder & "overlaydata.array" into someFile
   put overlay_ArrayFile (overlayFolder) into someFile
   return someFile
end script_OverlayFile

getprop script_DotFile [pOverlayName]
   put the long id of the target into scriptObject
   put scriptObject_DotFile (scriptObject, pOverlayName) into scriptArrayFolder
   return scriptArrayFolder
end script_DotFile

getprop script_CmapFile [pOverlayName]
   put the long id of the target into scriptObject
   put the textStack_MetadataFolder [true] of scriptObject into scriptFolder
   
   scriptObject_NormalizeGraphName pOverlayName, scriptFolder
   put pOverlayName & ".cmapx" into shortFile
   put scriptFolder & shortFile into someFile
   return someFile
end script_CmapFile

getprop script_GraphImageFile [pOverlayName]
   put the long id of the target into scriptObject
   return scriptObject_ImageFile (scriptObject, pOverlayName)
end script_GraphImageFile

getprop script_ImageFiles
   put the script_Files of the target into somePngs
   filter somePngs with "*.png"
   return somePngs
end script_ImageFiles

getprop script_Files
   put the long id of the target into scriptObject
   put the textStack_MetadataFolder [true] of scriptObject into metadataFolder
   put folder_ShortFiles (metadataFolder) into someFiles
   return someFiles
end script_Files

function scriptObject_DotFile scriptObject, pOverlayName
   put the metadata_Folder [true] of scriptObject into scriptFolder
   scriptObject_NormalizeGraphName pOverlayName, scriptFolder
   put pOverlayName & ".dot" into shortFile
   put scriptFolder & shortFile into someFile
   return someFile
end scriptObject_DotFile


--> Object | Folder | Functions
-
function project_HandlerFile hKey, pDontCreate
   put item 3 of hKey into hObject
   if exists (hObject) is false then return empty
   put the data_Folder of hObject into dataFolder
   
   put item 1 to 2 of hKey into shortHkey
   put textStack_HandlerFile (shortHkey, dataFolder) into exportedHandlerFile
   if pDontCreate is false then folder_CreateNested exportedHandlerFile
   return exportedHandlerFile
end project_HandlerFile


--> Script | Files
-
getprop script_File [pDontCreate]
   -- /lcw_User/lcw_Metadata/lib_Update/data/objects/stack/script.txt
   put pDontCreate is not false into pDontCreate
   put the data_Folder [true] of the target into dataFolder
   put textStack_ScriptFile (dataFolder, pDontCreate) into scriptFile
   return scriptFile
end script_File

getprop metadata_Folder [pDontCreate]
   -- /lcw_User/lcw_Metadata/LCW/metadata/objects/stack/
   -- where the script_File, handler_Folder and other data related to the object is stored.
   
   put the long id of the target into someObject
   put the textStack_MetadataFolder [true] of someObject into textStackMetadataFolder
   
   put the stack_Object of someObject into stackObject
   put the short name of stackObject into stackName
   put the mainstack of stackObject into mainStackName
   
   if stackName = mainStackName then
      put textStackMetadataFolder & "objects/" into metadataFolder
   else
      put textStackMetadataFolder & "objects/substacks/" & stackName & "/" into metadataFolder
   end if
   
   switch word 1 of someObject
      case "stack"
         put "stack/" after metadataFolder
         break
      default
         put word 1 of someObject & "_" & word 3 of someObject & "/" after metadataFolder
   end switch
   if pDontCreate is not true then folder_CreateNested metadataFolder
   return metadataFolder
end metadata_Folder


--> TextStack | Folders
-
getprop textStack_MetadataFolder [pDontCreate]
   -- /lcw_User/lcw_Metadata/LCW/metadata/
   put the textStack_Folder of the target into textStackFolder
   put textStackFolder & "metadata/" into objectMetaDataFolder
   if pDontCreate is not true then folder_CreateNested objectMetaDataFolder
   return objectMetaDataFolder
end textStack_MetadataFolder

getprop textStack_DataFolder [pDontCreate]
   -- /lcw_User/lcw_Metadata/LCW/data/
   put the textStack_Folder of the target into textStackFolder
   put textStackFolder & "data/" into textStackDataFolder
   if pDontCreate is not true then folder_CreateNested textStackDataFolder
   return textStackDataFolder
end textStack_DataFolder

getprop textStack_Folder [pDontCreate]  
   put the stack_Object of the target into stackObject
   put the mainstack of stackObject into mainStackName
   put textStack_ConstructFolder (mainStackName) into textStackFolder
   return textStackFolder
end textStack_Folder

function textStack_ConstructFolder mainStackName
   -- mainStackName is the same as the name of the folder in the datafolder
   put lcw_UserMetadataFolder() into textStackRoot
   put textStackRoot & mainStackName & "/" into textStackFolder
   if pDontCreate is false then folder_CreateNested textStackFolder
   return textStackFolder
end textStack_ConstructFolder

getprop textStack_Root
   put lcw_UserMetadataFolder() into lcwUserMetadataFolder
   return lcwUserMetadataFolder
end textStack_Root


--> TextStack | Files | Construct
-
function textStack_CallsFile shortHkey, dataFolder
   put textStack_HandlerDataFolder (shortHkey, dataFolder) & "lcw_calls.txt" into handlerFile
   return handlerFile
end textStack_CallsFile

function textStack_HandlerFile shortHkey, dataFolder
   put textStack_HandlerDataFolder (shortHkey, dataFolder) & "lcw_handler.txt" into handlerFile
   return handlerFile
end textStack_HandlerFile

function textStack_ScriptFile dataFolder, pDontCreate
   if pDontCreate is false then
      folder_CreateNested dataFolder
   else
      text_AddTrailing dataFolder, slash
   end if
   put dataFolder & "lcw_script.txt" into someFile
   return someFile
end textStack_ScriptFile

function textStack_HandlerDataFolder hKeyLine, dataFolder
   hkeyLine_Normalise hKeyLine
   text_AddTrailing dataFolder, slash
   put word 1 to 2 of hKeyLine into folderName
   put dataFolder & "handlers/" & folderName & "/" into handlerFolder
   return handlerFolder
end textStack_HandlerDataFolder
