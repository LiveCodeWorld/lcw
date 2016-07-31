script "model_OverlayScript"
--> MetaData
-
license: GPLv3
name: model_OverlayScript
type: model
version: 1.5
copyright: David Bovill

/* 
This model contains handlers that store the arrays (models) required to draw dot graphs from scripts.

It provides a series of additional properties for revolution controls, 
specifically related to graph data associated with thier scripts.
This allow easy access to the graph metadata associated with a script.
*/


--> Script | Help | Props
-
/*
At the moment storing and help about an objects properties etc along with the description of the script.
*/

getprop object_Help
   return the script_Help of the target
end object_Help

setprop object_Help someHelp
   set the script_Help of the target to someHelp
end object_Help

getprop script_Markdown
   -- should use pandoc
   -- just a stub for now
   put the script_Help of the target into someHTML
   put html_StripAllTags (someHTML) into someMarkDown
   return someMarkDown
end script_Markdown

getprop script_Help
   put the script_HelpFile of the target into someFile
   if there is not a file someFile then return empty
   put url ("binfile:" & someFile) into someHelp
   hack_UpdateBinFile someHelp, someFile
   return someHelp
end script_Help

setprop script_Help someHelp
   put the script_HelpFile [false] of the target into someFile
   put someHelp into url ("binfile:" & someFile)
   return someFile
end script_Help


--> Script | Graph | Misc
-
getprop script_GeometryArrayFromCmap [pOverlayName]
   put the script_CmapText [pOverlayName] of the target into cmapxText
   put imagemap_ParseMap (cmapxText) into geometryArray
   return geometryArray
end script_GeometryArrayFromCmap

getprop script_CmapText [pOverlayName]
   put the long id of the target into scriptObject
   put the script_CmapFile [pOverlayName] of scriptObject into cmapxFile
   put url ("file:" & cmapxFile) into cmapxText
   return cmapxText
end script_CmapText

function script_GetLinkArrayDotText scriptObject, pGraphStyle, pGraphSize
   put scriptObject_DotFile (scriptObject, pGraphStyle, pGraphSize) into someFile
   put url ("file:" & someFile) into dotText
   return dotText
end script_GetLinkArrayDotText

command script_SetLinkArrayDotText scriptObject, dotText
   put scriptObject_DotFile (scriptObject) into someFile
   put dotText into url ("file:" & someFile)
   return dotText
end script_SetLinkArrayDotText


--> Script | Graph | MetadataArray
-
getprop script_OverlayStyle [pOverlayName]
   put the script_GraphPropertyArray [pOverlayName] of the target into propertyArray
   return propertyArray ["overlay_Style"]
end script_OverlayStyle

setprop script_OverlayStyle [pOverlayName] graphStyle
   put the script_GraphPropertyArray [pOverlayName] of the target into propertyArray
   put graphStyle into propertyArray ["overlay_Style"]
   set the script_GraphPropertyArray [pOverlayName] of the target to propertyArray
   return the result
end script_OverlayStyle

getprop script_OverlayStyles
   return dot_AllGraphStyles()
end script_OverlayStyles

getprop script_GraphPropertyArray [pOverlayName]
   put the long id of the target into scriptObject
   put the script_MetadataArray [pOverlayName] of scriptObject into metadataArray
   return metadataArray ["graph_PropertyArray"]
end script_GraphPropertyArray

setprop script_GraphPropertyArray [pOverlayName] propertyArray
   put the long id of the target into scriptObject
   put the script_MetadataArray [pOverlayName] of scriptObject into metadataArray 
   if propertyArray is an array then
      put propertyArray into metadataArray ["graph_PropertyArray"]
   else
      delete local metadataArray ["graph_PropertyArray"]
   end if
   set the script_MetadataArray [pOverlayName] of scriptObject to metadataArray
   return metadataArray
end script_GraphPropertyArray


--> Script | Graph | DataArray
-
/*
Stores the full link array of a script as an encoded array along side the script in the repository.
*/

getprop script_GeometryArray [pGraphStyle]
   -- see also "script_GeometryArrayFromCmap"
   put the long id of the target into scriptObject
   put the script_DataArray [pOverlayName] of scriptObject into dataArray
   return dataArray ["geometry"]
end script_GeometryArray

setprop script_GeometryArray [pOverlayName] geometryArray
   put the long id of the target into scriptObject
   put the script_DataArray [pOverlayName] of scriptObject into dataArray
   put geometryArray into dataArray ["geometry"]
   set the script_DataArray [pOverlayName] of scriptObject to dataArray
end script_GeometryArray

getprop script_LinkArray [pOverlayName]
   put the long id of the target into scriptObject
   put the script_DataArray [pOverlayName] of scriptObject into dataArray
   return dataArray ["linkArray"]
end script_LinkArray

setprop script_LinkArray [pOverlayName] linkArray
   put the long id of the target into scriptObject
   put the script_DataArray [pOverlayName] of scriptObject into dataArray
   put linkArray into dataArray ["linkArray"]
   
   -- now update the other arrays
   linkArray_IdConstruct linkArray, idLinkArray, idArray
   put idLinkArray into dataArray ["idLinkArray"]
   put idArray into dataArray ["idArray"]
   
   set the script_DataArray [pOverlayName] of scriptObject to dataArray
end script_LinkArray

getprop script_IDLinkArray [pOverlayName]
   put the long id of the target into scriptObject
   put the script_DataArray [pOverlayName] of scriptObject into dataArray
   return dataArray ["idLinkArray"]
end script_IDLinkArray

setprop script_IDLinkArray [pOverlayName] idLinkArray
   put the long id of the target into scriptObject
   put the script_DataArray [pOverlayName] of scriptObject into dataArray
   put idLinkArray into dataArray ["idLinkArray"]
   set the script_DataArray [pOverlayName] of scriptObject to dataArray
end script_IDLinkArray

getprop script_IDArray [pOverlayName]
   put the long id of the target into scriptObject
   put the script_DataArray [pOverlayName] of scriptObject into dataArray
   return dataArray ["idArray"]
end script_IDArray

setprop script_IDArray [pOverlayName] idArray
   put the long id of the target into scriptObject
   put the script_DataArray [pOverlayName] of scriptObject into dataArray
   put idArray into dataArray ["idArray"]
   set the script_DataArray [pOverlayName] of scriptObject to dataArray
end script_IDArray


--> Script | Graph | Arrays
-
/*
Top level arrays
*/

getprop script_MetadataArray [pOverlayName]
   put the long id of the target into scriptObject
   put the script_OverlayArray [pOverlayName] of scriptObject into overlayArray
   put overlayArray ["metadata"] into metadataArray
   return metadataArray
end script_MetadataArray

setprop script_MetadataArray [pOverlayName] metadataArray
   put the long id of the target into scriptObject
   put the script_OverlayArray [pOverlayName] of scriptObject into overlayArray
   put metadataArray into overlayArray ["metadata"]
   set the script_OverlayArray [pOverlayName] of scriptObject to overlayArray
   return the result
end script_MetadataArray

getprop script_DataArray [pOverlayName]
   put the long id of the target into scriptObject
   put the script_OverlayArray [pOverlayName] of scriptObject into overlayArray
   put overlayArray ["data"] into dataArray
   return dataArray
end script_DataArray

setprop script_DataArray [pOverlayName] dataArray
   put the long id of the target into scriptObject
   put the script_OverlayArray [pOverlayName] of scriptObject into overlayArray
   put dataArray into overlayArray ["data"]
   set the script_OverlayArray [pOverlayName] of scriptObject to overlayArray
end script_DataArray

getprop script_OverlayArray  [pOverlayName]
   put the long id of the target into scriptObject
   put the script_OverlayData of scriptObject into overlayData
   if pOverlayName is empty then put overlayData_GetDefaultName (overlayData) into pOverlayName
   put overlayData [pOverlayName] into overlayArray
   return overlayArray
end script_OverlayArray

setprop script_OverlayArray [pOverlayName] overlayArray
   put the long id of the target into scriptObject
   if pOverlayName is empty then
      put overlayArray_GetGraphProperty (overlayArray, "overlay_Name") into pOverlayName
      if pOverlayName is empty then
         put "hierarchical" into pOverlayName
      end if
   end if
   put the script_OverlayData of scriptObject into overlayData
   if overlayArray is an array then
      put overlayArray into overlayData [pOverlayName]
   else
      delete local overlayData [pOverlayName]
   end if
   set the script_OverlayData of scriptObject to overlayData
   return the result
end script_OverlayArray

getprop script_OverlayData
   -- was "script_GraphArray" then "script_GraphData"
   put the long id of the target into scriptObject
   put the script_OverlayFile of scriptObject into someFile
   
   put url ("binfile:" & someFile) into encodedArray
   if encodedArray is empty then return empty
   put arraydecode (encodedArray) into overlayData
   return overlayData
end script_OverlayData

setprop script_OverlayData overlayData
   put the long id of the target into scriptObject
   put the script_OverlayFile [false] of scriptObject into someFile
   put arrayencode (overlayData) into encodedArray
   put encodedArray into url ("binfile:" & someFile)
   return someFile
end script_OverlayData


--> Script | Object | Graph | Construct
-
command scriptObject_ReconstructGraphArray scriptObject, pOverlayName, pGraphStyle
   put the script_Hkeys of scriptObject into hKeys
   put the script_DependencyArray [hKeys] of scriptObject into linkArray
   put the object_Folder of scriptObject into graphFolder
   
   overlay_ReconstructDotArray graphFolder, pGraphStyle, linkArray, pOverlayName
   overlay_Draw graphFolder, pOverlayName
end scriptObject_ReconstructGraphArray

command scriptObject_NormalizeGraphName @pOverlayName, overlayFolder
   if pOverlayName is empty then
      put overlay_GetData (overlayFolder) into overlayData
      put overlayData_GetDefaultGraphName (overlayData) into pOverlayName
      if pOverlayName is empty then put "undirected spring" into pOverlayName
   end if
   return pOverlayName
end scriptObject_NormalizeGraphName


--> Global | Script | Export | Line | Menu | Utilities
-
function scriptObject_ConstructBadExportArray
   set the cursor to watch
   
   set the itemdelimiter to "/"
   put library_GetTextStackFolder() into someFolder
   put the number of items of someFolder + 1 into scriptFolderItemNum
   
   put folder_NestedFilesInside (someFolder) into scriptFiles
   filter scriptFiles with "*/script.txt"
   
   repeat for each line scriptFile in scriptFiles
      put item 1 to -2 of scriptFile into dotFolder
      put scriptObject_ReferenceFromFolder (dotFolder) into scriptObject
      
      if exists (scriptObject) then
         put the script of scriptObject into nowScript
         put url ("file:" & scriptFile) into localObjectScript
         
         put the rugged_ID of scriptObject into scriptObject
         put the mobile_Name of scriptObject into objectName
         if nowScript = localObjectScript then
            put scriptObject & CR after goodExports
         else
            put scriptObject & CR after badExports
            put html_ConstructNameLink (objectName, scriptObject) & CR after badExportOutline
         end if
      else
         put scriptObject & CR after unkownExports
         put html_ConstructNameLink (objectName, scriptObject) & CR after unkownExportOutline
      end if
   end repeat
   
   delete char -1 of goodExports
   delete char -1 of badExports
   delete char -1 of badExportOutline
   delete char -1 of unkownExports
   delete char -1 of unkownExportOutline
   
   put goodExports into exportArray ["goodExports"]
   put badExports into exportArray ["badExports"]
   put badExportOutline into exportArray ["badExportOutline"]
   put unkownExports into exportArray ["unkownExports"]
   put unkownExportOutline into exportArray ["unkownExportOutline"]
   
   return exportArray
end scriptObject_ConstructBadExportArray

command scriptObject_ExportScript scriptObject
   put the script of scriptObject into nowScript
   put the script_File of scriptObject into scriptFile
   put nowScript into url ("file:" & scriptFile)
   return nowScript
end scriptObject_ExportScript

command scriptObject_RevertToExportedFile scriptObject
   put rev_ListTabScriptObjects() into scriptEditorObjects
   if scriptObject is among the lines of scriptEditorObjects then
      return merge("Error: close script editor tab for [[scriptObject]] before using this tool")
   end if
   
   put the script of scriptObject into nowScript
   put the script_File of scriptObject into scriptFile
   put url ("file:" & scriptFile) into fileScript
   
   display_Lines nowScript, "The old script of the object"
   put the result into treeView
   set the displayed_Object of treeView to scriptObject
   
   set the script of scriptObject to fileScript
end scriptObject_RevertToExportedFile

command scriptObject_FileExportDiff scriptObject
   set the cursor to watch
   put the script of scriptObject into nowScript
   put the script_File of scriptObject into scriptFile
   put url ("file:" & scriptFile) into localObjectScript
   
   terminal_Diff localObjectScript, nowScript, "script_File of mTarget", "Objects script"
end scriptObject_FileExportDiff
