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

function scriptObject_ImageFile scriptObject, pOverlayName
   put the textStack_MetadataFolder [true] of scriptObject into scriptFolder
   scriptObject_NormalizeGraphName pOverlayName, scriptFolder
   put pOverlayName & "." & "png" into shortFile
   put scriptFolder & shortFile into someFile
   return someFile
end scriptObject_ImageFile


--> TextStack | Folders
-
getprop data_Folder [pDontCreate]
   -- /lcw_User/lcw_Metadata/LCW/data/objects/stack/
   -- where the script_File, handler_Folder and other data related to the object is stored.
   
   put the long id of the target into someObject
   put the textStack_DataFolder [true] of someObject into textStackDataFolder
   
   put the defaultstack into stackObject
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

getprop metadata_Folder [pDontCreate]
   -- /lcw_User/lcw_Metadata/LCW/metadata/objects/stack/
   -- where the script_File, handler_Folder and other data related to the object is stored.
   
   put the long id of the target into someObject
   put the textStack_MetadataFolder [true] of someObject into textStackMetadataFolder
   
   put the defaultstack into stackObject
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


--> Script | Object File Properteis
-
getprop script_File [pDontCreate]
   -- /lcw_User/lcw_Metadata/lib_Update/data/objects/stack/script.txt
   put pDontCreate is not false into pDontCreate
   put the data_Folder [true] of the target into dataFolder
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

function scriptObject_DotFile scriptObject, pOverlayName
   put the metadata_Folder [true] of scriptObject into scriptFolder
   scriptObject_NormalizeGraphName pOverlayName, scriptFolder
   put pOverlayName & ".dot" into shortFile
   put scriptFolder & shortFile into someFile
   return someFile
end scriptObject_DotFile
