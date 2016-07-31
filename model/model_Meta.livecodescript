script "model_Meta"
--> MetaData
-
license: GPLv3
name: model_Meta
type: model
version: 0.9


--> Meta | Data
-
/*
Meta refers to props not stored in the object but in named files associated with the object.

The newer metadata stored in text files / encoded arrays as part of the text based stack export format.
These depend on the textStack_Folder.

An objects script is stored as a text file, so it can be versioned in a repository.
The file is stored inside a folder named after the stack the object is in, 
not nested, but in a flat namespace, derived from the rugged_ID
*/


--> Currently Working On | Metadata | Missing
-
getprop meta_Script
   put the object_Folder of the target into objectFolder
   put object_FetchScript (objectFolder) into someScript
   return someScript
end meta_Script

setprop meta_Script [pExportHandlers] someScript
   put the long id of the target into someObject
   put the object_Folder of someObject into objectFolder
   object_ExportScript objectFolder, someScript, pExportHandlers
   put the result into someFile
   return someFile
end meta_Script

getprop meta_MetaArray
   put the object_Folder of the target into objectFolder
   put object_FetchMetadataArray (objectFolder) into objectMetaArray
   return objectMetaArray
end meta_MetaArray

setprop meta_MetaArray metadataArray
   put the object_Folder of the target into objectFolder
   object_ExportMetadataArray objectFolder, metadataArray
   return the result
end meta_MetaArray


--> Meta
-
getprop meta_Image
   put the object_Folder of the target into objectFolder
   put object_FetchMetaImage (objectFolder) into someImage
   return someImage
end meta_Image

setprop meta_Image someImage
   put the object_Folder of the target into objectFolder
   object_ExportMetaImage objectFolder, someImage
   return the result
end meta_Image

getprop meta_ManifestArray
   put the textStack_Folder of the target into mainStackFolder
   put mainstack_FetchHarray (mainStackFolder) into hArray
   return manifestArray
end meta_ManifestArray

setprop meta_ManifestArray manifestArray
   breakPoint -- should delte as syntax is ugly (use dispatch instead"
   put the textStack_Folder of the target into mainStackFolder
   mainStack_StoreManifestArray mainStackFolder, manifestArray
   return manifestArray
end meta_ManifestArray

getprop meta_CustomArray
   put the object_Folder of the target into objectFolder
   put the meta_CustomArrayFile of the target is empty into pUseCustomFolders
   put object_FetchCustomArray (objectFolder, pUseCustomFolders) into customArray
   return customArray
end meta_CustomArray

setprop meta_CustomArray customArray
   breakPoint -- should delte as syntax is ugly (use dispatch instead"
   put the object_Folder of the target into objectFolder
   object_ExportCustomArray objectFolder, customArray
   return the result
end meta_CustomArray

getprop meta_Html
   put the object_Folder of the target into objectFolder
   put object_FetchMetaHtml (objectFolder) into objectHtml
   return objectHtml
end meta_Html

setprop meta_Html objectHtml
   put the object_Folder of the target into objectFolder
   object_ExportMetaHtml objectFolder, objectHtml
   return the result
end meta_Html

getprop meta_Text
   put the object_Folder of the target into objectFolder
   put object_FetchMetaText (objectFolder) into objectText
   return objectText
end meta_Text

setprop meta_Text objectText
   put the object_Folder of the target into objectFolder
   object_ExportMetaText objectFolder, objectText
   return the result
end meta_Text

getprop meta_RevPropText
   put the object_Folder of the target into objectFolder
   put object_FetchRevPropText (objectFolder) into revPropText
   return revPropText
end meta_RevPropText

setprop meta_RevPropText revPropText
   put the object_Folder of the target into objectFolder
   object_ExportRevPropText objectFolder, revPropText
   return the result
end meta_RevPropText

getprop meta_Data
   put the meta_ScriptMetaDataFile of the target into scriptMetaDataFile
   put url ("binfile:" & scriptMetaDataFile) into encodedArray
   put arraydecode (encodedArray) into scriptMetaDataArray
   return scriptMetaDataArray
end meta_Data

setprop meta_Data scriptMetaDataArray
   put the meta_ScriptMetaDataFile of the target into scriptMetaDataFile
   put arrayencode (scriptMetaDataArray) into encodedArray
   put encodedArray into url ("binfile:" & scriptMetaDataFile)
   return scriptMetaDataFile
end meta_Data


--> Object | Metadata
-
function object_FetchMetadataArray objectFolder
   -- object_ConstructMetadataFolder is missing / renamed?
   put object_ConstructMetadataFolder (objectFolder) into metaFolder
   put array_FromFolder (metaFolder) into metadataArray
   return metadataArray
end object_FetchMetadataArray

command object_ExportMetadataArray objectFolder, metadataArray
   -- object_ConstructMetadataFolder is missing / renamed?
   if metadataArray is not an array then return false
   
   put object_ConstructMetadataFolder (objectFolder) into metaFolder
   array_ToFolder metaFolder, metadataArray
   return metaFolder
end object_ExportMetadataArray


--> Meta | Html
-
function object_FetchMetaHtml objectFolder
   put meta_HtmlFile (objectFolder) into someFile
   put url ( "binfile:" & someFile) into objectHtml
   return objectHtml
end object_FetchMetaHtml

command object_ExportMetaHtml objectFolder, objectHtml
   put meta_HtmlFile (objectFolder, false) into someFile
   put objectHtml into url ( "binfile:" & someFile)
   return someFile
end object_ExportMetaHtml


--> Meta | Text
-
function object_FetchMetaText objectFolder
   put meta_TextFile (objectFolder) into someFile
   put url ( "binfile:" & someFile) into objectText
   return objectText
end object_FetchMetaText

command object_ExportMetaText objectFolder, objectText
   put meta_TextFile (objectFolder, false) into someFile
   put objectText into url ( "binfile:" & someFile)
   return someFile
end object_ExportMetaText


--> Meta | Image
-
function object_FetchMetaImage objectFolder, pExtension
   put meta_ImageFile (objectFolder, pExtension) into someFile
   put url ( "binfile:" & someFile) into someImage
   return someImage
end object_FetchMetaImage

command object_ExportMetaImage objectFolder, someImage, pExtension
   put meta_ImageFile (objectFolder, pExtension, false) into someFile
   put someImage into url ( "binfile:" & someFile)
   return someFile
end object_ExportMetaImage


--> Meta | RevPropText
-
function object_FetchRevPropText objectFolder
   put meta_PropTextFile (objectFolder) into someFile
   put url ( "binfile:" & someFile) into revPropText
   return revPropText
end object_FetchRevPropText

command object_ExportRevPropText objectFolder, revPropText
   put meta_PropTextFile (objectFolder, false) into someFile
   if revPropText is empty then
      delete file someFile
      return empty
   else
      put revPropText into url ( "binfile:" & someFile)
      return someFile
   end if
end object_ExportRevPropText


--> Meta | Files
-
getprop meta_CustomArrayFile
   put the object_Folder of the target into objectFolder
   put meta_GetCustomArrayFile (objectFolder) into someFile
   if there is a file someFile then
      return someFile
   else
      return empty
   end if
end meta_CustomArrayFile

getprop meta_ScriptMetaDataFile
   put the object_Folder of the target into objectFolder
   put meta_ScriptMetaDataFile (objectFolder) into someFile
   return someFile
end meta_ScriptMetaDataFile

/*
These are not done yet, manifests are stored at the stack level, and sub-stack level.
Consider creating a mainstack manifest
*/

getprop meta_ManifestArray
   -- extract the manifest array from the mainstackManifestArray
   put the long id of the target into tObject
   put the mainStack_ManifestArray [true] of the target into mainStackManifestArray
   
   object_RuggedDeconstruct tObject, mainstackName, substackName, controlType, someID
   if substackName is empty then
      put mainStackManifestArray into manifestArray
      delete variable manifestArray ["substacks"]
   else
      put mainStackManifestArray ["substacks"][substackName] into manifestArray
   end if
   return manifestArray
end meta_ManifestArray

function meta_ScriptMetaDataFile objectFolder, pDontCreate
   folder_Format objectFolder
   put objectFolder & "scriptMetaData.array" into someFile
   if pDontCreate is false then folder_CreateNested objectFolder
   return someFile
end meta_ScriptMetaDataFile

function meta_GetCustomArrayFile objectFolder
   folder_Format objectFolder
   put objectFolder & "custom.array" into someFile
   if pDontCreate is false then folder_CreateNested objectFolder
   return someFile
end meta_GetCustomArrayFile

function meta_StackArrayFile objectFolder, pDontCreate
   -- see also "library_FetchStackFiles"
   folder_Format objectFolder
   put objectFolder & "stackfiles.txt" into someFile
   if pDontCreate is false then folder_CreateNested objectFolder
   return someFile
end meta_StackArrayFile

function meta_PropTextFile objectFolder, pDontCreate
   folder_Format objectFolder
   put objectFolder & "props.txt" into someFile
   if pDontCreate is false then folder_CreateNested objectFolder
   return someFile
end meta_PropTextFile

function meta_HtmlFile objectFolder, pDontCreate
   folder_Format objectFolder
   put objectFolder & "objectText.html" into someFile
   if pDontCreate is false then folder_CreateNested objectFolder
   return someFile
end meta_HtmlFile

function meta_TextFile objectFolder, pDontCreate
   folder_Format objectFolder
   put objectFolder & "objectText.txt" into someFile
   if pDontCreate is false then folder_CreateNested objectFolder
   return someFile
end meta_TextFile

function meta_ImageFile objectFolder, pExtension, pDontCreate
   folder_Format objectFolder
   put objectFolder & "image" into someFile
   if pExtension is not empty then put "." & pExtension after someFile
   if pDontCreate is false then folder_CreateNested objectFolder
   return someFile
end meta_ImageFile


--> Script | Metadata | Export
-
/*
Not sure about these....
*/

getprop script_MetaTable
   put the script_MetaArray of the target into ripArray
   combine ripArray with CR and tab
   return ripArray
end script_MetaTable

getprop script_MetaXML
   put the script_MetaTable of the target into ripTable
   return script_MetaTableToXml(ripTable)
end script_MetaXML

getprop script_MetaHtmlTable
   put the script_MetaTable of the target into ripTable
   return script_MetaTableToXhtml(ripTable)
end script_MetaHtmlTable

getprop script_MetaHtml
   put the script_MetaTable of the target into ripTable
   put script_MetaTableToXhtml(ripTable) into bodyText
   return html_AddHeaders(bodyText, "RIP")
end script_MetaHtml

function script_MetaTableToXml ripTable
   put "<rip>" into ripXML
   put CR & tab & "<file>" after ripXML
   
   set the itemdelimiter to tab
   repeat for each line someLine in ripTable
      put item 1 of someLine into someKey
      put item 2 of someLine into someValue
      
      get xml_Tag(someValue, someKey)
      put CR & tab & tab & it after ripXML
   end repeat
   put CR & tab & "</file>" after ripXML
   put CR & "</rip>" after ripXML
   return ripXML
end script_MetaTableToXml

function script_MetaTableToXhtml ripTable, headerList, tableSummary, someCaption
   put "<table summary=" & quote & tableSummary & quote & ">" into htmlTable
   put CR & tab & xml_Tag(someCaption, "caption") after htmlTable
   
   put "Property" & tab & "Value" into headerLine
   put table_ConstructHeader (headerLine) into htmlHeader
   put table_ConstructBody (ripTable) into htmlBody
   get htmlHeader & CR & htmlBody
   
   put CR & outline_IncreaseIndent (it, 1) after htmlTable
   put CR & "</table>" after htmlTable
   return htmlTable
end script_MetaTableToXhtml

function script_GetUniqueTitle
   put script_GetGlobalSuiteTitles() into globalSuiteTitles
   return "Untitled" && the number of lines of globalSuiteTitles
end script_GetUniqueTitle

function script_FileFromMetadataArray metadataArray
   put metadataArray ["script_Name"] into scriptName
   put scriptName &".txt" into shortFile
   
   put metadataArray ["script_Type"] into scriptType
   switch scriptType
      case "menu"
         return opn_GetMenuScriptFolder(shortFile)
      case "library"
         return opn_GetLibraryScriptFolder(shortFile)
      case "controller"
         return opn_GetLibraryScriptFolder(shortFile)
      default
         return empty
   end switch
end script_FileFromMetadataArray
