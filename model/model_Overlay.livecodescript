script "model_Overlay"
--> MetaData
-
license: GPLv3
name: model_Overlay
type: model
version: 0.4


--> Overlay | Model
-
/*
There are many other model handlers in libOPN_Overlay

OverlayData is a data format which contains multiple named overlayArray's (see libOPN_DotArray).
The data is contained in an arrayencoded text file "overlaydata.array".

These handlers all operate on this data structure (array) wherever it comes from (custom property or file)
*/

function overlay_GetArray overlayFolder, pOverlayName
   put overlay_GetData (overlayFolder) into overlayData
   put overlayData_GetArray (overlayData, pOverlayName) into overlayArray
   return overlayArray
end overlay_GetArray

command overlay_SetArray overlayFolder, overlayArray, pOverlayName, pMainstackHash
   -- empty = "delete"
   if pMainstackHash is not empty then overlayArray_SetMainStackHash overlayArray, pMainstackHash
   put overlay_GetData (overlayFolder) into overlayData
   overlayData_SetArray overlayData, overlayArray, pOverlayName
   overlay_SetData overlayFolder, overlayData
   return overlayData
end overlay_SetArray

function overlay_GetData overlayFolder
   -- was "graphFolder_GetData"
   put overlay_ArrayFile (overlayFolder) into dotArrayFile
   put overlayData_Fetch (dotArrayFile) into overlayData
   return overlayData
end overlay_GetData

command overlay_SetData overlayFolder, overlayData
   put overlay_ArrayFile (overlayFolder) into dotArrayFile
   overlayData_SetGraphProps overlayData, "overlay_Folder", overlayFolder -- just in case
   overlayData_Store dotArrayFile, overlayData
   return dotArrayFile
end overlay_SetData

function overlayData_Fetch dotArrayFile
   put url ("binfile:" & dotArrayFile) into encodedArray
   if encodedArray is empty then return empty
   put arraydecode (encodedArray) into overlayData
   return overlayData
end overlayData_Fetch

command overlayData_Store dotArrayFile, overlayData
   if overlayData is not an array then return empty
   put arrayencode (overlayData) into encodedArray
   
   put dotArrayFile into overlayFolder
   set the itemdelimiter to "/"
   delete item -1 of overlayFolder
   folder_CreateNested overlayFolder
   
   put encodedArray into url ("binfile:" & dotArrayFile)
   return encodedArray
end overlayData_Store

function overlay_ArrayFile overlayFolder
   folder_Format overlayFolder
   put overlayFolder & "overlayData.array" into dotArrayFile
   return dotArrayFile
end overlay_ArrayFile


--> Overlay | Files
-
function overlay_GetCmapFile overlayFolder, pOverlayName
   put overlay_ConstructFile ("cmapx", overlayFolder, pOverlayName) into someFile
   return someFile
end overlay_GetCmapFile

function overlay_LinkFile overlayFolder
   folder_Format overlayFolder
   put overlayFolder & "links.txt" into someFile
   return someFile
end overlay_LinkFile

function overlay_GetFile overlayArray, filePropName
   put overlayArray_GetGraphProperty (overlayArray, "overlay_Folder") into overlayFolder
   put overlayArray_GetGraphProperty (overlayArray, filePropName) into relativeFile
   folder_Format overlayFolder -- should not be needed
   put overlayFolder & relativeFile into someFile
   return someFile
end overlay_GetFile

command overlay_Files overlayFolder, @dotFile, @imageFile, @cmapxFile, @xdotFile, @dotArrayFile, pOverlayName, pImageFormat
   if pOverlayName is empty then
      put overlay_Getdata (overlayFolder) into overlayData
      overlayData_NormalizeName pOverlayName, overlayData
   end if
   folder_Format overlayFolder
   
   overlay_ShortFiles pOverlayName, shortDotFile, shortImageFile, shortCmapxFile, shortXdotFile, shortDotArrayFile, pImageFormat
   
   put overlayFolder & shortDotArrayFile into dotArrayFile
   put overlayFolder & shortDotFile into dotFile
   put overlayFolder & shortImageFile into imageFile
   put overlayFolder & shortCmapxFile into cmapxFile
   put overlayFolder & shortXdotFile into xdotFile
end overlay_Files

command overlay_ShortFiles overlayName, @shortDotFile, @shortImageFile, @shortCmapxFile, @shortXdotFile, @shortDotArrayFile, pImageFormat
   if pImageFormat is empty then put "png" into pImageFormat
   put "overlayData.array" into shortDotArrayFile
   
   put overlayName & ".dot" into shortDotFile
   put overlayName & "." & pImageFormat into shortImageFile
   put overlayName & ".cmapx" into shortCmapxFile
   put overlayName & ".xdot" into shortXdotFile
end overlay_ShortFiles

function overlay_ListAllFiles overlayFolder, pImageFormat
   put overlay_GetData (overlayFolder) into overlayData 
   put overlayData_ListNames (overlayData) into overlayNames
   repeat for each line overlayName in overlayNames
      overlay_Files overlayFolder, dotFile, imageFile, cmapxFile, xdotFile, dotArrayFile, overlayName, pImageFormat
      if there is a file dotFile then put dotFile & CR after overlayFiles
      if there is a file imageFile then put imageFile & CR after overlayFiles
      if there is a file cmapxFile then put cmapxFile & CR after overlayFiles
      if there is a file xdotFile then put xdotFile & CR after overlayFiles
      if there is a file dotArrayFile then put dotArrayFile & CR after overlayFiles
   end repeat
   delete char -1 of overlayFiles
   return overlayFiles
end overlay_ListAllFiles

function overlay_ImageFiles overlayFolder
   folder_Format overlayFolder
   put the directory into oDirectory
   set the directory to overlayFolder
   put the files into shortFiles
   set the itemdelimiter to "."
   repeat for each line shortFile in shortFiles
      if item -1 of shortFile = "png" then
         put overlayFolder & shortFile & CR after imageFiles
      end if
   end repeat
   delete char -1 of imageFiles
   set the directory to oDirectory
   return imageFiles
end overlay_ImageFiles


--> Overlay
-
command overlay_Delete overlayFolder, overlayName, pDeleteFiles, pImageFormat
   overlay_SetArray overlayFolder, empty, overlayName
   
   if pDeleteFiles is not false then
      overlay_Files overlayFolder, dotFile, imageFile, cmapxFile, xdotFile, dotArrayFile, overlayName, pImageFormat
      if there is a file dotFile then delete file dotFile
      if there is a file imageFile then delete file imageFile
      if there is a file cmapxFile then delete file cmapxFile
      if there is a file xdotFile then delete file xdotFile
   end if
end overlay_Delete


--> Overlay
-
getprop overlay_IsNew [pOverlayName]
   put the long id of the target into scriptObject
   
   put the script of scriptObject into someScript
   put sha1_Hash (someScript) into hashNow
   
   put the overlay_Folder of scriptObject into overlayFolder
   put overlay_GetGraphValue (overlayFolder, "sha1 of script when overlay created", pOverlayName) into hashWhenCreated
   return hashNow = hashWhenCreated
end overlay_IsNew

function overlay_TestGraph overlayFolder, pOverlayName
   put overlay_GetArray (overlayFolder, pOverlayName) into overlayArray
   put overlayArray_GetGraphProperty (overlayArray, "overlay_Hash") into storedOverlayHash
   if storedOverlayHash is empty then return false
   
   put overlayArray_GetGraphProperty (overlayArray, "image_File") into shortImageFile
   folder_Format overlayFolder
   put overlayFolder & shortImageFile into imageFile
   put file_Hash (imageFile) into imageHash
   
   return imageHash = storedOverlayHash
end overlay_TestGraph

function overlay_GetObjectFromFolder overlayFolder, pOverlayName
   put overlay_GetGraphValue (overlayFolder, "overlay_Of", pOverlayName) into hKeyOrObject
   if exists(hKeyOrObject) is false then return empty
   return hKeyOrObject
end overlay_GetObjectFromFolder

setprop overlay_IsNew [pOverlayName] someBoolean
   put the long id of the target into scriptObject
   put "sha1 of script when overlay created" into pKey
   
   if someBoolean is true then
      put the script of scriptObject into someScript
      put sha1_Hash (someScript) into hashWhenCreated
      
      -- set the hdb_ObjectMetaData [pKey] of scriptObject to hashWhenCreated
      -- set the overlay_GraphProperty [pKey] of scriptObject to hashWhenCreated
      
      put the overlay_Folder of scriptObject into overlayFolder
      overlay_SetGraphValue overlayFolder, pKey, hashWhenCreated, pOverlayName, false
      
      return hashWhenCreated
   else
      -- don't really need to do anything as it will return false when the script hash changes
      -- so may as well keep old hash
      -- set the hdb_ObjectMetaData [pKey] of scriptObject to empty ???
   end if
end overlay_IsNew


--> Overlay | To Sort
-
function overlay_GetNode overlayFolder, pOverlayName
   -- so not to depend of the name of the overlay folder 
   put overlay_GetData (overlayFolder) into overlayData
   put overlayData_GetGraphProperty (overlayData, "overlay_Node", pOverlayName) into overlayNode
   return overlayNode
end overlay_GetNode

command overlay_SetNode overlayFolder, pOverlayName
   -- so not to depend of the name of the overlay folder 
   put overlay_GetData (overlayFolder) into overlayData
   overlayData_SetGraphProperty overlayData, "overlay_Node", overlayNode, pOverlayName
   return overlayData
end overlay_SetNode

function overlay_GetNodeLinks overlayFolder
   put overlay_LinkFile (overlayFolder) into someFile
   put url ("file:" & someFile) into nodeLinks
   return nodeLinks
end overlay_GetNodeLinks

command overlay_SetNodeLinks overlayFolder, nodeLinks
   put overlay_LinkFile (overlayFolder) into someFile
   if nodeLinks is empty then
      -- file_Delete someFile
      delete file someFile
   else
      put nodeLinks into url ("file:" & someFile)
   end if
end overlay_SetNodeLinks


--> Overlay
-
command overlay_SetFileNames overlayFolder, pOverlayNames
   folder_Format overlayFolder
   put overlay_GetData (overlayFolder) into overlayData
   
   if pOverlayNames is empty then put overlayData_ListNames (overlayData) into pOverlayNames
   repeat for each line overlayName in pOverlayNames
      put overlayData [overlayName] into overlayArray
      put overlayFolder into safeOverlayFolder
      file_ReplaceHome safeOverlayFolder
      overlayArray_SetGraphProperty overlayArray, "overlay_Folder", safeOverlayFolder
      
      overlay_ShortFiles overlayName, shortDotFile, shortImageFile, shortCmapxFile, shortXdotFile, shortDotArrayFile
      
      overlayArray_SetGraphProperty overlayArray, "image_File", shortImageFile
      overlayArray_SetGraphProperty overlayArray, "dot_File", shortDotFile
      put overlayArray into overlayData [overlayName]
   end repeat
   overlay_SetData overlayFolder, overlayData
end overlay_SetFileNames

command overlay_ReconstructDotArray overlayFolder, overlayStyle, pLinkArray, pOverlayName, pDotDefaultArray
   put overlay_GetData (overlayFolder) into overlayData
   put overlayData_GetArray (overlayData, pOverlayName) into overlayArray
   
   if pOverlayName is empty then put overlayStyle into pOverlayName
   overlayArray_SetGraphProperty overlayArray, "overlay_Name", pOverlayName
   
   put rev_PluginRelativePath (overlayFolder) into relativeOverlayFolder
   overlayArray_SetGraphProperty overlayArray, "overlay_Folder", relativeOverlayFolder
   overlayArray_SetGraphProperty overlayArray, "overlay_Style", overlayStyle
   
   overlay_ReconstructArray overlayArray, pLinkArray, pDotDefaultArray
   return overlayArray
end overlay_ReconstructDotArray

command overlay_ReconstructArray @overlayArray, pLinkArray, pDotDefaultArray
   if pLinkArray is not an array then put overlayArray_GetLinkArray (overlayArray) into pLinkArray -- reconstruct
   if pDotDefaultArray is an array then overlayArray_AddDefaultUnion overlayArray, pDotDefaultArray
   
   put overlayArray_GetHeaderArray (overlayArray) into dotHeaderArray
   put overlayArray_GetGraphPropertyArray (overlayArray) into graphPropertyArray 
   put overlayArray_FromLinkArray (pLinkArray, dotHeaderArray, graphPropertyArray) into overlayArray
   
   overlayArray_CreateFilesAndSetGeometry overlayArray
   return overlayArray
end overlay_ReconstructArray


--> Overlay
-
/*
Some default values that can be calculated for "the overlay_Data of the target" 
Override locally for fine grain control.
*/

getprop textStackOverlay_Data  [pOverlayName]
   put the textStackOverlay_Folder [true] of the target into overlayFolder
   if there is not a folder overlayFolder then return empty
   put overlay_GetData (overlayFolder) into overlayData
   if pOverlayName is empty then return overlayData
   return overlayData [pOverlayName]
end textStackOverlay_Data

getprop overlay_Array [pOverlayName]
   put the overlay_Folder of the target into overlayFolder
   if pOverlayName is empty then put the overlay_Name of the target into pOverlayName
   put overlay_GetArray (overlayFolder, pOverlayName) into overlayArray
   return overlayArray
end overlay_Array

setprop overlay_Array [pOverlayName] overlayArray
   put the overlay_Folder of the target into overlayFolder
   if pOverlayName is empty then put the overlay_Name of the target into pOverlayName
   overlay_SetArray overlayFolder, overlayArray, pOverlayName
   return the result
end overlay_Array

getprop overlay_Data
   put the overlay_Folder of the target into overlayFolder
   put overlay_GetData (overlayFolder) into overlayData
   return overlayData
end overlay_Data

setprop overlay_Data overlayData
   put the overlay_Folder of the target into overlayFolder
   overlay_SetData overlayFolder, overlayData
   return the result
end overlay_Data

getprop overlay_Name
   -- stored with the card (not the target) to indicate which overly is being displayed
   put the long id of the target into targetObject
   put the stack_Object of targetObject into stackObject
   if exists(stackObject) is false then
      beep
      return targetObject
   end if
   put the uOPN ["overlay_Name"] of stackObject into overlayName
   return overlayName
end overlay_Name

setprop overlay_Name overlayName
   -- stored with the stack (not the target) to indicate which overly is being displayed
   put the stack_Object of the target into stackObject
   set the uOPN ["overlay_Name"] of stackObject to overlayName
   return overlayName
end overlay_Name

getprop overlay_Names
   put the overlay_Folder of the target into overlayFolder
   put overlay_ListNames (overlayFolder) into overlayNames
   return overlayNames
end overlay_Names

getprop overlay_DefaultName
   put the overlay_Folder of the target into overlayFolder
   put overlay_GetDefaultName (overlayFolder) into overlayName
   return overlayName
end overlay_DefaultName

setprop overlay_DefaultName overlayName
   put the overlay_Folder of the target into overlayFolder
   overlay_SetDefaultName overlayFolder, overlayName
   put the result into overlayData
   return overlayData
end overlay_DefaultName

getprop overlay_Node [pOverlayName]
   -- so not to depend of the name of the overlay folder 
   put the overlay_Folder of the target into overlayFolder
   put overlay_GetNode (overlayFolder, pOverlayName) into overlayNode
   return overlayNode
end overlay_Node

setprop overlay_Node [pOverlayName]
   -- so not to depend of the name of the overlay folder 
   put the overlay_Folder of the target into overlayFolder
   overlay_SetNode overlayFolder, pOverlayName
   put the result into overlayData
   return overlayData
end overlay_Node

getprop overlay_Files [pOverlayName]
   put the overlay_Folder of the target into overlayFolder
   overlay_Files overlayFolder, dotFile, imageFile, cmapFile, xdotFile, dotArrayFile, pOverlayName
   put dotFile,imageFile,cmapFile,xdotFile into graphFiles
   replace comma with CR in graphFiles
   return graphFiles
end overlay_Files


--> Graph | Property
-
getprop overlay_Style [pOverlayName]
   put _GetGraphProperty (word 1 of the params, pOverlayName) into someValue
   return someValue
end overlay_Style

setprop overlay_Style [pOverlayName] graphStyle
   _SetGraphProperty word 1 of the params, graphStyle, pOverlayName
   return the result
end overlay_Style

getprop overlay_Styles
   return dot_AllGraphStyles()
end overlay_Styles

getprop overlay_MaximumDepth [pOverlayName]
   put _GetGraphProperty (word 1 of the params, pOverlayName) into someValue
   return someValue
end overlay_MaximumDepth

setprop overlay_MaximumDepth [pOverlayName] maxDepth
   put the overlay_Folder of the target into overlayFolder
   overlay_SetGraphValue overlayFolder, "overlay_MaximumDepth", maxDepth, pOverlayName
   return the result
end overlay_MaximumDepth

getprop overlay_MaximumDepths
   return dot_GetGraphMaximumDepths()
end overlay_MaximumDepths

getprop overlay_Controller [pOverlayName]
   put _GetGraphProperty (word 1 of the params, pOverlayName) into someValue
   return someValue
end overlay_Controller

setprop overlay_Controller [pOverlayName] graphController
   _SetGraphProperty word 1 of the params, graphController, pOverlayName
   return the result
end overlay_Controller

getprop overlay_Of [pOverlayName]
   put _GetGraphProperty (word 1 of the params, pOverlayName) into someValue
   return someValue
end overlay_Of

setprop overlay_Of [pOverlayName] graphOf
   _SetGraphProperty word 1 of the params, graphOf, pOverlayName
   return the result
end overlay_Of

getprop overlay_Size [pOverlayName]
   put _GetGraphProperty (word 1 of the params, pOverlayName) into someValue
   return someValue
end overlay_Size

setprop overlay_Size [pOverlayName] graphSize
   _SetGraphProperty word 1 of the params, graphSize, pOverlayName
   return the result
end overlay_Size

getprop overlay_Sizes
   return dot_GetGraphSizes()
end overlay_Sizes

getprop overlay_FlattenNum [pOverlayName]
   put _GetGraphProperty (word 1 of the params, pOverlayName) into someValue
   return someValue
end overlay_FlattenNum

setprop overlay_FlattenNum [pOverlayName] graphFlattenNum
   put the overlay_Folder of the target into overlayFolder
   overlay_SetGraphValue overlayFolder, "overlay_FlattenNum", graphFlattenNum, pOverlayName
   return the result
end overlay_FlattenNum

getprop overlay_FlattenNums
   return dot_AllGraphFlattenNums()
end overlay_FlattenNums

getprop overlay_UseInches [pOverlayName]
   put the overlay_Array [pOverlayName] of the target into overlayArray
   put overlayArray_GetGraphProperty (overlayArray, word 1 of the params) into someValue
   return someValue
end overlay_UseInches

setprop overlay_UseInches [pOverlayName] someBoolean
   put the overlay_Folder of the target into overlayFolder
   overlay_SetGraphValue overlayFolder, "overlay_UseInches", someBoolean, pOverlayName
   return the result
end overlay_UseInches


--> Overaly | Property | Array
-
/*
Short cuts.
*/

getprop overlay_ImageFile [pOverlayName]
   put the overlay_Folder of the target into overlayFolder
   put overlay_GetImageFile (overlayFolder, pOverlayName) into imageFile
   return imageFile
end overlay_ImageFile

getprop overlay_GraphProperty [propName]
   put the overlay_Folder of the target into overlayFolder
   put overlay_GetGraphValue (overlayFolder, propName) into propValue
   return propValue
end overlay_GraphProperty

setprop overlay_GraphProperty [propName] propValue
   -- for the default overlay, and don;t recreate
   put the overlay_Folder of the target into overlayFolder
   overlay_SetGraphValue overlayFolder, propName, propValue, empty, false
end overlay_GraphProperty

function overlay_GetGraphValue overlayFolder, propName, pOverlayName
   put overlay_GetData (overlayFolder) into overlayData
   put overlayData_GetGraphProperty (overlayData, propName, pOverlayName) into propValue
   return propValue
end overlay_GetGraphValue

command overlay_SetGraphValue overlayFolder, propName, propValue, pOverlayName, pRecreate
   put overlay_GetData (overlayFolder) into overlayData
   overlayData_SetGraphProperty overlayData, propName, propValue, pOverlayName
   if pRecreate is true then
      overlayArray_CreateFilesAndSetGeometry overlayArray
      put overlay_GetData (overlayFolder) into overlayData
   else
      overlay_SetData overlayFolder, overlayData
   end if
   return overlayData
end overlay_SetGraphValue

getprop overlay_PropertyArray [pOverlayName]
   put the overlay_Array [pOverlayName] of the target into overlayArray
   put overlayArray ["graph_PropertyArray"] into propertyArray
   return propertyArray
end overlay_PropertyArray

setprop overlay_PropertyArray [pOverlayName] propertyArray
   put the overlay_Array [pOverlayName] of the target into overlayArray
   if propertyArray is an array then
      put propertyArray into overlayArray ["graph_PropertyArray"]
   else
      delete local overlayArray ["graph_PropertyArray"]
   end if
   set the overlay_Array [pOverlayName] of the target to overlayArray
   return overlayArray
end overlay_PropertyArray


--> Overlay | Props
-
function overlay_GetDefaultName overlayFolder
   put overlay_GetData (overlayFolder) into overlayData
   put overlayData_GetDefaultName (overlayData) into overlayName
   return overlayName
end overlay_GetDefaultName

command overlay_SetDefaultName overlayFolder, overlayName
   put overlay_GetData (overlayFolder) into overlayData
   overlayData_SetDefaultName overlayData, overlayName
   overlay_SetData overlayFolder, overlayData
   return overlayData
end overlay_SetDefaultName

function overlay_ListNames overlayFolder
   put overlay_GetData (overlayFolder) into overlayData
   put overlayData_ListNames (overlayData) into overlayNames
   return overlayNames
end overlay_ListNames

function overlay_GetOverlayObject overlayFolder, pOverlayName
   put overlay_GetData (overlayFolder) into overlayData
   if pOverlayName is empty then put overlayData_GetDefaultName (overlayData) into pOverlayName
   
   put overlayData [pOverlayName] into overlayArray
   put overlayArray_GetGraphProperty (overlayArray, "overlay_Of") into scriptObject
   return scriptObject
end overlay_GetOverlayObject

command overlay_SetOverlayObject overlayFolder, scriptObject, pOverlayName
   put overlay_GetData (overlayFolder) into overlayData
   
   if pOverlayName is empty then
      repeat for each key pOverlayName in overlayData
         put overlayData [pOverlayName] into overlayArray
         overlayArray_SetGraphProperty overlayArray, "overlay_Of", scriptObject
         put overlayArray into overlayData [pOverlayName]
      end repeat
   else
      put overlayData [pOverlayName] into overlayArray
      overlayArray_SetGraphProperty overlayArray, "overlay_Of", scriptObject
      put overlayArray into overlayData [pOverlayName]
   end if
   
   overlay_SetData overlayFolder, overlayData
   return overlayData
end overlay_SetOverlayObject

function overlay_GetXdotText overlayFolder, pOverlayName
   put overlay_ConstructFile ("xdot", overlayFolder, pOverlayName) into someFile
   put url ("file:" & someFile) into xdotText
   return xdotText
end overlay_GetXdotText

command overlay_SetXdotText overlayFolder, xdotText, pOverlayName
   put overlay_ConstructFile ("xdot", overlayFolder, pOverlayName) into someFile
   put xdotText into url ("file:" & someFile)
   return someFile
end overlay_SetXdotText

function overlay_GetDotText overlayFolder, pOverlayName
   put overlay_ConstructFile ("dot", overlayFolder, pOverlayName) into someFile
   put url ("file:" & someFile) into dotText
   return dotText
end overlay_GetDotText

command overlay_SetDotText overlayFolder, dotText, pOverlayName
   put overlay_ConstructFile ("dot", overlayFolder, pOverlayName) into someFile
   put dotText into url ("file:" & someFile)
   return someFile
end overlay_SetDotText

function overlay_GetCmapText overlayFolder, pOverlayName
   put overlay_GetCmapFile (overlayFolder, pOverlayName) into cmapFile
   put url ("file:" & cmapFile) into cmapText
   return cmapText
end overlay_GetCmapText

command overlay_SetCmapText overlayFolder, cmapText, pOverlayName
   put overlay_ConstructFile ("dot", overlayFolder, pOverlayName) into someFile
   put cmapText into url ("file:" & someFile)
   return someFile
end overlay_SetCmapText

function overlay_GetLinkArray overlayFolder, pOverlayName
   put overlay_GetArray (overlayFolder, pOverlayName) into overlayArray
   put overlayArray_GetLinkArray (overlayArray) into linkArray
   return linkArray
end overlay_GetLinkArray

command overlay_SetLinkArray overlayFolder, hKeyArray, pOverlayName, pGraphStyle, pMainstackHash, pImageFormat
   put overlay_GetArray (overlayFolder, pOverlayName) into overlayArray
   if pGraphStyle is empty or hKeyArray is not an array then
      put overlayArray_GetHeaderArray (overlayArray) into dotHeaderArray
      put overlayArray_GetGraphPropertyArray (overlayArray) into graphPropertyArray
      put overlayArray_FromLinkArray (hkeyArray, dotHeaderArray, graphPropertyArray) into overlayArray
      -- overlayArray_SetLinkArray overlayArray, hKeyArray
      overlay_SetArray overlayFolder, overlayArray, pOverlayName, pMainstackHash
   else
      local pDotCluster
      overlay_CreateGraph overlayFolder, hKeyArray, pOverlayName, pOverlayOf, pGraphStyle, pDotCluster, pMainstackHash, pImageFormat
      put the result into overlayArray
   end if
   return overlayArray
end overlay_SetLinkArray

function overlay_GetImageFile overlayFolder, pOverlayName
   put overlay_GetArray (overlayFolder, pOverlayName) into overlayArray
   put overlayArray_GetImageFile (overlayArray, overlayFolder) into imageFile
   return imageFile
end overlay_GetImageFile

function overlayArray_GetImageFile overlayArray, overlayFolder
   put overlayArray_GetGraphProperty (overlayArray, "image_File") into shortImageFile
   if shortImageFile is empty then return empty
   text_AddTrailing overlayFolder, slash
   put overlayFolder & shortImageFile into imageFile
   return imageFile
end overlayArray_GetImageFile


--> Overlay | File | Utilities
-
command overlay_RecreateFromLinkArray dotFolder, overlayName, pGraphStyle
   put overlay_GetData (dotFolder) into overlayData
   --
   put overlayData_GetArray (overlayData, overlayName) into overlayArray
   put overlayArray_GetHeaderArray (overlayArray) into dotHeaderArray
   put overlayArray_GetGraphPropertyArray (overlayArray) into graphPropertyArray
   put overlayArray_GetLinkArray (overlayArray) into linkArray
   overlayArray_ReconstructAndCreateFiles linkArray, overlayName, dotFolder, pGraphStyle, dotHeaderArray, graphPropertyArray
   overlayData_SetArray overlayData, overlayArray, overlayName
   --
   overlay_SetData dotFolder, overlayData
end overlay_RecreateFromLinkArray

command overlay_CreateFilesAndSetGeometry overlayFolder, overlayName, pOverlayStyle, pImageFormat
   put overlay_GetData (overlayFolder) into overlayData
   put overlayData_GetArray (overlayData, overlayName) into overlayArray
   
   overlayArray_SetGraphProperty overlayArray, "overlay_Folder", overlayFolder
   overlayArray_SetGraphProperty overlayArray, "overlay_Name", overlayName
   overlayArray_SetGraphProperty overlayArray, "overlay_Style", pOverlayStyle
   
   overlayArray_CreateFilesAndSetGeometry overlayArray, empty, pImageFormat
   
   overlayData_SetArray overlayData, overlayArray, overlayName
   overlay_SetData overlayFolder, overlayData
   return overlayArray
end overlay_CreateFilesAndSetGeometry

command overlay_CreateDotFiles @overlayArray, pOverlayFolder, pImageFormat
   -- creates all the dot and image files (but does not save the array files)
   if pImageFormat is empty then put "png" into pImageFormat
   
   put overlayArray_GetLinkArray (overlayArray) into hkeyArray
   if hkeyArray is not an array then return empty
   
   put dot_FromArray (overlayArray) into dotText
   
   if pOverlayFolder is not empty then
      folder_CreateNested pOverlayFolder
      overlayArray_SetGraphProperty overlayArray, "overlay_Folder", pOverlayFolder
   else
      put overlayArray_GetGraphProperty (overlayArray, "overlay_Folder") into pOverlayFolder
      if pOverlayFolder is empty then
         put the tempname & "/" into pOverlayFolder
         folder_CreateNested pOverlayFolder
         overlayArray_SetGraphProperty overlayArray, "overlay_Folder", pOverlayFolder
      end if
   end if
   
   put overlayArray_GetGraphProperty (overlayArray, "overlay_Style") into graphStyle
   if graphStyle is empty then
      put "hierarchical" into graphStyle
      overlayArray_SetGraphProperty overlayArray, "overlay_Style", graphStyle
   end if
   
   put overlayArray_GetGraphProperty (overlayArray, "overlay_Name") into overlayName
   if overlayName is empty then
      put graphStyle into overlayName
      overlayArray_SetGraphProperty overlayArray, "overlay_Name", overlayName
   end if
   
   overlay_Files pOverlayFolder, dotFile, imageFile, cmapxFile, xdotFile, dotArrayFile, overlayName, pImageFormat
   dot_SaveTemporaryFile dotText, dotFile
   
   if graphStyle = "hierarchical" then -- lets flatten it ?
      put overlayArray_GetGraphProperty (overlayArray, "overlay_FlattenNum") into overlayFlattenNum
      if overlayFlattenNum is a number and overlayFlattenNum > 0 then
         put dot_UnFlatten (dotFile, overlayFlattenNum) into unFlatDotText
         if word 1 of unFlatDotText is among the items of "digraph,graph" then
            file_CreateText unFlatDotText, dotFile
         end if
      end if
   end if
   
   dot_DoImageMapShell graphStyle, dotFile, imageFile, cmapxFile, xdotFile, pImageFormat
   put the result into gvResult
   if word 1 of gvResult = "Error" then
      return gvResult
   end if
   
   -- now set relative files
   overlay_SetAndStoreFileRelative overlayArray, "dot_File", dotFile
   overlay_SetAndStoreFileRelative overlayArray, "image_File", imageFile
   overlay_SetAndStoreFileRelative overlayArray, "cmapx_File", cmapxFile
   overlay_SetAndStoreFileRelative overlayArray, "xdot_File", xdotFile
   
   return gvResult
end overlay_CreateDotFiles

function overlay_AllStyles overlayFolder
   put overlay_Getdata (overlayFolder) into overlayData
   repeat for each key overlayName in overlayData
      get overlayData_GetGraphProperty (overlayData, "overlay_MaximumDepth", pOverlayName)
   end repeat
end overlay_AllStyles


--> Overlay | File | Bits
-
private command overlay_SetAndStoreFileRelative @overlayArray, filePropName, someFile
   put overlayArray_GetGraphProperty (overlayArray, "overlay_Folder") into overlayFolder
   overlay_SetFileRelative someFile, overlayFolder
   overlayArray_SetGraphProperty overlayArray, filePropName, someFile
end overlay_SetAndStoreFileRelative

command overlay_SetFileRelative @someFile, overlayFolder
   set the itemdelimiter to "/"
   put the number of items of overlayFolder into itemNum 
   if item 1 to itemNum of someFile = item 1 to itemNum overlayFolder then
      delete item 1 to itemNum of someFile
   end if
end overlay_SetFileRelative

function overlay_ConstructFile fileSuffix, overlayFolder, pOverlayName
   if pOverlayName is empty then put overlay_GetDefaultName (overlayFolder) into pOverlayName
   folder_Format overlayFolder
   put pOverlayName & "." & fileSuffix into shortFile
   put overlayFolder & shortFile into someFile
   return someFile
end overlay_ConstructFile


--> OverlayData
-
/*
OverlayData is a data format which contains multiple named overlayArray's (see libOPN_DotArray).
The data is contained in an arrayencoded text file "overlaydata.array".

These handlers all operate on this data structure (array) wherever it comes from (custom property or file)
*/

function overlayData_ListNames overlayData
   -- simple for now - but array structure could be expanded to include metadata
   put keys(overlayData) into overlayNames
   return overlayNames
end overlayData_ListNames

command overlayData_NormalizeName @overlayName, overlayData
   if overlayName is empty then
      if overlayData is an array then
         put overlayData_GetDefaultName (overlayData) into overlayName
      end if
   end if
end overlayData_NormalizeName

function overlayData_GetDefaultName overlayData 
   -- search for a overlayArray labled "overlay_IsDefault"
   put keys(overlayData) into overlayNames
   repeat for each line overlayName in overlayNames
      put overlayData [overlayName] into overlayArray
      put overlayArray_GetGraphProperty (overlayArray, "overlay_IsDefault") into graphIsDefault
      if graphIsDefault is true then
         return overlayName
      end if
   end repeat
   return line 1 of overlayNames
end overlayData_GetDefaultName

command overlayData_SetDefaultName @overlayData, defaultGraphName
   put keys(overlayData) into overlayNames
   set the wholematches to true
   if defaultGraphName is among the lines of overlayNames then
      repeat for each line overlayName in overlayNames
         put overlayData [overlayName] into overlayArray
         put overlayName = defaultGraphName into someBoolean
         overlayArray_SetGraphProperty overlayArray, "overlay_IsDefault", someBoolean
         
         put overlayArray into overlayData [overlayName]
      end repeat
   else
      -- could fix here
   end if
end overlayData_SetDefaultName

function overlayData_GetArray overlayData, pOverlayName
   overlayData_NormalizeName pOverlayName, overlayData
   put overlayData [pOverlayName] into overlayArray
   return overlayArray
end overlayData_GetArray

command overlayData_SetArray @overlayData, overlayArray, pOverlayName
   overlayData_NormalizeName pOverlayName, overlayData
   if overlayArray is not an array then
      delete local overlayData [pOverlayName]
   else
      put overlayArray into overlayData [pOverlayName]
   end if
end overlayData_SetArray


--> overlayData | Data
-
function overlayData_GetLinkArray overlayData, pOverlayName
   overlayData_NormalizeName pOverlayName, overlayData
   put overlayData_GetDataArray (overlayData, pOverlayName) into dataArray
   put dataArray ["linkArray"] into linkArray
   return linkArray
end overlayData_GetLinkArray

command overlayData_SetLinkArray @overlayData, linkArray, pOverlayName
   put overlayData_GetDataArray (overlayData, pOverlayName) into dataArray
   put linkArray into dataArray ["linkArray"]
   overlayData_SetDataArray overlayData, dataArray, pOverlayName
end overlayData_SetLinkArray

function overlayData_GetDataArray overlayData, pOverlayName
   overlayData_NormalizeName pOverlayName, overlayData
   put overlayData [pOverlayName]["data"] into dotHeaderArray
   return dotHeaderArray
end overlayData_GetDataArray

command overlayData_SetDataArray @overlayData, dotHeaderArray, pOverlayName
   overlayData_NormalizeName pOverlayName, overlayData
   put dotHeaderArray into overlayData [pOverlayName]["data"]
end overlayData_SetDataArray


--> overlayData | Metadata
-
function overlayData_GetGroupStyleArray overlayData, pOverlayName
   overlayData_NormalizeName pOverlayName, overlayData
   put overlayData [pOverlayName]["metadata"]["dot_GroupStyleArray"] into dotGroupStyleArray
   return dotGroupStyleArray
end overlayData_GetGroupStyleArray

command overlayData_SetGroupStyleArray @overlayData, dotGroupStyleArray, pOverlayName
   overlayData_NormalizeName pOverlayName, overlayData
   put dotGroupStyleArray into overlayData [pOverlayName]["metadata"]["dot_GroupStyleArray"]
end overlayData_SetGroupStyleArray

function overlayData_GetHeaderArray overlayData, pOverlayName
   overlayData_NormalizeName pOverlayName, overlayData
   put overlayData [pOverlayName]["metadata"]["dot_HeaderArray"] into dotHeaderArray
   return dotHeaderArray
end overlayData_GetHeaderArray

command overlayData_SetHeaderArray @overlayData, dotHeaderArray, pOverlayName
   overlayData_NormalizeName pOverlayName, overlayData
   put dotHeaderArray into overlayData [pOverlayName]["metadata"]["dot_HeaderArray"]
end overlayData_SetHeaderArray

function overlayData_GetGraphPropertyArray overlayData, pOverlayName
   overlayData_NormalizeName pOverlayName, overlayData
   put overlayData [pOverlayName]["metadata"]["graph_PropertyArray"] into graphPropertyArray
   return graphPropertyArray
end overlayData_GetGraphPropertyArray

command overlayData_SetGraphPropertyArray @overlayData, graphPropertyArray, pOverlayName
   overlayData_NormalizeName pOverlayName, overlayData
   put graphPropertyArray into overlayData [pOverlayName]["metadata"]["graph_PropertyArray"]
end overlayData_SetGraphPropertyArray

function overlayData_GetMetadataArray overlayData, pOverlayName
   overlayData_NormalizeName pOverlayName, overlayData
   put overlayData [pOverlayName]["metadata"] into metadataArray
   return metadataArray
end overlayData_GetMetadataArray

command overlayData_SetMetadataArray @overlayData, metadataArray, pOverlayName
   overlayData_NormalizeName pOverlayName, overlayData
   if metadataArray is an array then
      put metadataArray into overlayData [pOverlayName]["metadata"]
   else
      delete local overlayData [pOverlayName]["metadata"]
   end if
end overlayData_SetMetadataArray


--> overlayData | Graph Property
-
function overlayData_GetGraphProperty overlayData, propName, pOverlayName
   put overlayData_GetArray (overlayData, pOverlayName) into overlayArray
   put overlayArray_GetGraphProperty (overlayArray, propName) into propValue
   return propValue
end overlayData_GetGraphProperty

command overlayData_SetGraphProperty @overlayData, propName, propValue, pOverlayName
   put overlayData_GetArray (overlayData, pOverlayName) into overlayArray
   overlayArray_SetGraphProperty overlayArray, propName, propValue
   overlayData_SetArray overlayData, overlayArray, pOverlayName
end overlayData_SetGraphProperty

command overlayData_SetGraphProps @overlayData, propName, propValue
   repeat for each key overlayName in overlayData
      put overlayData [overlayName] into overlayArray
      overlayArray_SetGraphProperty overlayArray, propName, propValue
      put overlayArray into overlayData [overlayName]
   end repeat
end overlayData_SetGraphProps


--> Hkey | overlayArray | Group Style
-
command overlayData_ConstructAndSetGroupStyleArray @overlayArray
   put overlayArray ["metadata"]["dot_GroupStyleArray"] into dotGroupStyleArray
   put overlayArray ["data"]["idArray"] into idArray
   
   repeat for each key nodeID in idArray
      put idArray [nodeID] into hKey
      hkey_Deconstruct hKey, handlerName, handlerType, scriptObject, handlerNum
      
      put dotGroupStyleArray [handlerType]["nodeIDs"] into nodeIDs
      put nodeID & comma after nodeIDs
      put nodeIDs into dotGroupStyleArray [handlerType]["nodeIDs"]
   end repeat
   
   overlayData_SetFunctionStyle dotGroupStyleArray
   overlayData_SetCommandStyle dotGroupStyleArray
   
   overlayData_SetGetPropStyle dotGroupStyleArray
   overlayData_SetSetPropStyle dotGroupStyleArray
   
   overlayData_SetMessageStyle dotGroupStyleArray
   overlayData_SetMissingStyle dotGroupStyleArray
   
   repeat for each item handlerType in "c,f,g,s,m,missing"
      put dotGroupStyleArray [handlerType]["nodeIDs"] into nodeIDs
      delete char -1 of nodeIDs
      if nodeIDs is not empty then
         put nodeIDs into dotGroupStyleArray [handlerType]["nodeIDs"]
      else
         delete local dotGroupStyleArray [handlerType]
      end if
   end repeat
   
   put dotGroupStyleArray into overlayArray ["metadata"]["dot_GroupStyleArray"]
end overlayData_ConstructAndSetGroupStyleArray

command overlayData_SetFunctionStyle @dotGroupStyleArray  
   put "LightBlue" into dotGroupStyleArray ["c"]["node_StyleArray"]["fillcolor"]
   put "Blue" into dotGroupStyleArray ["c"]["node_StyleArray"]["color"]
   put "filled" into dotGroupStyleArray ["c"]["node_StyleArray"]["style"]
end overlayData_SetFunctionStyle

command overlayData_SetCommandStyle @dotGroupStyleArray    
   put "GreenYellow" into dotGroupStyleArray ["f"]["node_StyleArray"]["fillcolor"]
   put "Green4" into dotGroupStyleArray ["f"]["node_StyleArray"]["color"]
   put "filled" into dotGroupStyleArray ["f"]["node_StyleArray"]["style"]
end overlayData_SetCommandStyle

command overlayData_SetGetPropStyle @dotGroupStyleArray
   put "grey50" into dotGroupStyleArray ["g"]["node_StyleArray"]["fillcolor"]
   put "white" into dotGroupStyleArray ["g"]["node_StyleArray"]["color"]
   put "filled" into dotGroupStyleArray ["g"]["node_StyleArray"]["style"]
end overlayData_SetGetPropStyle

command overlayData_SetSetPropStyle @dotGroupStyleArray
   put "grey" into dotGroupStyleArray ["s"]["node_StyleArray"]["fillcolor"]
   put "white" into dotGroupStyleArray ["s"]["node_StyleArray"]["color"]
   put "filled" into dotGroupStyleArray ["s"]["node_StyleArray"]["style"]
end overlayData_SetSetPropStyle

command overlayData_SetMessageStyle @dotGroupStyleArray   
   put "Orange" into dotGroupStyleArray ["m"]["node_StyleArray"]["fillcolor"]
   put "Red" into dotGroupStyleArray ["m"]["node_StyleArray"]["color"]
   put "filled" into dotGroupStyleArray ["m"]["node_StyleArray"]["style"]
end overlayData_SetMessageStyle

command overlayData_SetMissingStyle @dotGroupStyleArray   
   put "red" into dotGroupStyleArray ["missing"]["node_StyleArray"]["fillcolor"]
   put "red" into dotGroupStyleArray ["missing"]["node_StyleArray"]["color"]
   put "filled" into dotGroupStyleArray ["missing"]["node_StyleArray"]["style"]
end overlayData_SetMissingStyle


--> Hkey | overlayArray | Clusters
-
function overlayData_ConstructClusterArray overlayArray
   put overlayArray ["data"]["idArray"] into idArray
   put hKeyArray_ConstructObjectIDArray (idArray) into objectIDArray
   return objectIDArray
end overlayData_ConstructClusterArray

function hKeyArray_ConstructObjectIdArray hIdArray, hIDs
   local objectIdArray
   if hIDs is empty then put keys(hIdArray) into hIDs
   repeat for each line nodeID in hIDs
      put hIdArray [nodeID] into hKey
      if hKey is empty then next repeat
      hkey_Deconstruct hKey, handlerName, handlerType, scriptObject, handlerNum
      -- if exists(scriptObject) then put the mobile_Name of scriptObject into scriptObject
      array_AddToIndex nodeID, scriptObject, objectIdArray
   end repeat
   return objectIdArray
end hKeyArray_ConstructObjectIdArray

function overlayData_ConstructClusterSection overlayArray
   --  put hKeyArray_DotObjectClusters (hLinkArray, hIdArray, false, true, graphNodeType, pTargetObject) into clusterDefs
   put false into labelNodes
   put true into notIfEmpty
   overlayArray_DeconstructData overlayArray, linkArray, idArray, idLinkArray, reverseIdLinkArray, dotClusterArray
   
   put hKeyArray_ConstructObjectIDArray (idArray) into objectIDArray
   put overlayData_ConstructDotClusters (objectIDArray, idArray) into clusterSection
   
   return clusterSection
end overlayData_ConstructClusterSection

function overlayData_ConstructDotClusters objectIDArray, idArray, pNotIfEmpty
   -- was "hKeyArray_ConstructDotClusters"   
   put 1 into clusterNum
   repeat for each key someObject in objectIDArray
      put empty into nodeSection
      put objectIDArray [someObject] into nodeIds
      repeat for each line nodeID in nodeIds
         put dot_ConstructDefaultDefLine (nodeID, idArray) into nodeDefLine
         put nodeDefLine & CR after nodeSection
      end repeat
      delete char -1 of nodeSection
      
      if pNotIfEmpty is not false and nodeSection is empty then next repeat
      
      put "" into someRank
      put "" into someStyle
      if clusterNum is even then
         put "grey60" into someColour
         put "grey60" into fillColour
      else
         put "grey60" into someColour
         put "grey90" into fillColour
      end if
      
      if exists(someObject) then
         put the name of someObject into subGraphName
         -- put the short name of someObject into subGraphName
      else
         put someObject into subGraphName
      end if
      
      get dot_ConstructCluster (subGraphName, clusterNum, nodeSection, someRank, someStyle, someColour, fillColour)
      put it & CR after clusterSection
      
      add 1 to clusterNum
   end repeat
   delete char -1 of clusterSection
   return clusterSection
end overlayData_ConstructDotClusters


--> LinkArray | Model
-
/*
This is old!
Use overlay_Folder related stuff now.

A LinkArray is used to graph arrays. To do this LinkArrays provide a suite of tools that take complex keys and convert them into simple IDs,
and dictionaries to translate from these IDS to the orginal keys.

This new model uses default custom properties that can be used to get and set each of the three inter-connected arrays.
As these are default custom properties, they can be over-ridden locally.

The default behavior is to store the array in a file, in a default folder (named after the object), inside the opn_Model folder.
Later this folder can be moved, and the scripts re-directed to this model folder using the "model_Folder" property (see model_File).
*/

on linkArray_Get modelObject, @idLinkArray, @idArray, pModelName
   put the model_IdArray [pModelName] of modelObject into idArray
   put the model_IdLinkArray [pModelName] of modelObject into idLinkArray
end linkArray_Get

command linkArray_Set modelObject, idLinkArray, idArray
   set the model_IdArray [pModelName] of modelObject to idArray
   set the model_IdLinkArray [pModelName] of modelObject to idLinkArray
end linkArray_Set

getprop model_LinkArray [modelName]
   put the long id of the target into modelObject
   if modelName is empty then put "model_LinkArray" into modelName
   put model_GetArray (modelName, modelObject, "file") into linkArray
   return linkArray
end model_LinkArray

setprop model_LinkArray [modelName] linkArray
   put the long id of the target into modelObject
   if modelName is empty then put "model_LinkArray" into modelName
   model_SetArray modelName, modelObject, linkArray, "file"
end model_LinkArray

getprop model_IdArray [modelName]
   put the long id of the target into modelObject
   if modelName is empty then put "model_IdArray" into modelName
   put model_GetArray (modelName, modelObject, "file") into idArray
   return idArray
end model_IdArray

getprop model_IdLinkArray [modelName]
   put the long id of the target into modelObject
   if modelName is empty then put "model_IdLinkArray" into modelName
   put model_GetArray (modelName, modelObject, "file") into idArray
   return idArray
end model_IdLinkArray


--> Deps
-
private function _GetGraphProperty propName, pOverlayName
   if pOverlayName is empty then put the overlay_Name of the target into pOverlayName
   put the overlay_Array [pOverlayName] of the target into overlayArray
   put overlayArray_GetGraphProperty (overlayArray, propName) into propValue
   return propValue
   
   if pOverlayName is empty then put the overlay_Name of the target into pOverlayName
   put the overlay_Folder of the target into overlayFolder
   put overlay_GetGraphValue (overlayFolder, propName, pOverlayName) into propValue
   return propValue
end _GetGraphProperty

private command _SetGraphProperty propName, propValue, pOverlayName, pRecreateDot
   if pOverlayName is empty then put the overlay_Name of the target into pOverlayName
   put the overlay_Array [pOverlayName] of the target into overlayArray
   overlayArray_SetGraphProperty overlayArray, propName, propValue
   
   ## Recreate files
   if pRecreateDot is not false  then overlayArray_CreateFilesAndSetGeometry overlayArray
   
   set the overlay_Array [pOverlayName] of the target to overlayArray
   return the result
end _SetGraphProperty
