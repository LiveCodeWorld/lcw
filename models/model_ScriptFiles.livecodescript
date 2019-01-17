script "model_ScriptFiles"
--> MetaData
-
license: GPLv3
name: model_ScriptFiles
type: model
version: 0.9

/*
We are moving over from old comma based hKeys to new format.
This is for the following reasons:

- 1) revAvailable handlers returns in this format
- 2) the tree widget does nto work well with keys that contain commas
- 3) It reads better on screen and in the wiki
*/

--> Working on
-
/*
Need to rename these "project" handlers to "object_"
*/

--> Folder | Metadata
-
getprop metadata_Folder [shortHkey]
   if shortHkey is empty then
      return the metadataObject_Folder of the target
   else
      return the metadataHandler_Folder [shortHkey] of the target
   end if
end metadata_Folder

getprop metadataHandler_Folder [shortHkey]
   put the long id of the target into tObject
   --
   put word 1 to 2 of shortHkey into shortHkey
   put shortHkey && "of" && tObject into hKey
   put hkey_MetadataFolder (hKey) into metadataHekyFolder
   --
   return metadataHekyFolder
end metadataHandler_Folder

getprop metadataObject_Folder [pDontCreate]
   -- lib_IDE/metadata/objects/stack/
   -- the objects metadataObject_Folder (not the textStack_MetadataFolder
   -- /lcw_User/lcw_Metadata/LCW/metadata/objects/stack/
   -- where the script_File, handler_Folder and other data related to the object is stored.
   
   put the long id of the target into tObject
   put the metadataObjects_Folder [pDontCreate] of tObject into metadataObjectsFolder
   
   put the defaultstack into tObject
   put the short name of tObject into stackName
   put the mainstack of tObject into mainStackName
   
   if stackName = mainStackName then
      put metadataObjectsFolder into metadataObjectFolder
   else
      put metadataObjectsFolder & "substacks/" & stackName & "/" into metadataObjectFolder
   end if
   --
   switch word 1 of tObject
      case "stack"
         put "stack/" after metadataObjectFolder
         break
      default
         put word 1 of tObject & "_" & word 3 of tObject & "/" after metadataObjectFolder
   end switch
   --
   if pDontCreate is not true then folder_CreateNested metadataObjectFolder
   return metadataObjectFolder
end metadataObject_Folder

getprop metadataObjects_Folder [pDontCreate]
   -- /metadata/objects/ 
   -- /lcw_User/lcw_Metadata/LCW/metadata/objects/
   -- it is the metadata for a script object
   
   put the textStack_MetadataFolder [pDontCreate] of the target into metadataFolder
   put metadataFolder & "objects/" into metadataObjectsFolder
   if pDontCreate is false then folder_CreateNested metadataObjectsFolder
   return metadataObjectsFolder
end metadataObjects_Folder

getprop metadataProject_Folder [pDontCreate]   
   -- /metadata/project/ 
   put the textStack_MetadataFolder of the target into metadataFolder
   put metadataFolder & "project/" into overlayFolder
   if pDontCreate is false then folder_CreateNested overlayFolder
   return overlayFolder
end metadataProject_Folder


--> Folder | Synonyms
-
getprop script_OverlayFolder [pDontCreate]
   -- /metadata/objects/stack/overlay/ 
   -- which is not the "project" metadata folder
   -- it is the metadata for for a script object
   
   put the metadataObject_Folder [pDontCreate] of the target into metadataFolder
   return metadataFolder
end script_OverlayFolder

getprop script_Folder [pDontCreate]
   -- easier to remember synonym for "the dataObject_Folder"
   put the dataObject_Folder [pDontCreate] of the target into scriptFolder
   return scriptFolder
end script_Folder


--> Folder | Data | Objects
-
getprop dataObject_Folder [pDontCreate]
   /*
   -- /lcw_User/lcw_Metadata/LCW/data/objects/stack/
   
   This is an object specific data folder.
   -- where the script_File (lcw_Script.txt), handler_Folder (handlers) and other data related to the object is stored.
   
   All object specific data folders are within "the dataObjects_Folder"
   Which in turn is within "the textStack_DataFolder"
   */
   
   put the long id of the target into tObject
   put the dataObjects_Folder [pDontCreate] of tObject into dataObjectsFolder
   
   put the defaultstack into stackObject
   put the short name of stackObject into stackName
   put the mainstack of stackObject into mainStackName
   
   if stackName = mainStackName then
      put dataObjectsFolder into dataFolder
   else
      put dataObjectsFolder & "substacks/" & stackName & "/" into dataFolder
   end if
   
   switch word 1 of tObject
      case "stack"
         put "stack/" after dataFolder
         break
      default
         put word 1 of tObject & "_" & word 3 of tObject & "/" after dataFolder
   end switch
   if pDontCreate is not true then folder_CreateNested dataFolder
   return dataFolder
end dataObject_Folder

getprop dataObjects_Folder [pDontCreate]
   /*
   -- /lcw_User/lcw_Metadata/LCW/data/objects/
   */
   put the textStack_DataFolder [pDontCreate] of the target into textStackDataFolder
   put textStackDataFolder & "objects/" into dataObjectsFolder
   return dataObjectsFolder
end dataObjects_Folder


--> Script | Object File Properteis
-
getprop script_File [pDontCreate]
   -- /lcw_User/lcw_Metadata/lib_Update/data/objects/stack/script.txt
   put pDontCreate is not false into pDontCreate
   put the dataObject_Folder [true] of the target into dataFolder
   put textStack_ScriptFile (dataFolder, pDontCreate) into scriptFile
   return scriptFile
end script_File

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


--> Files
-
function scriptObject_ImageFile scriptObject, pOverlayName
   put the textStack_MetadataFolder [true] of scriptObject into scriptFolder
   scriptObject_NormalizeGraphName pOverlayName, scriptFolder
   put pOverlayName & "." & "png" into shortFile
   put scriptFolder & shortFile into someFile
   return someFile
end scriptObject_ImageFile

function scriptObject_DotFile scriptObject, pOverlayName
   put the metadataObject_Folder [true] of scriptObject into scriptFolder
   scriptObject_NormalizeGraphName pOverlayName, scriptFolder
   put pOverlayName & ".dot" into shortFile
   put scriptFolder & shortFile into someFile
   return someFile
end scriptObject_DotFile
