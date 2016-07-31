script "model_Dot"
--> MetaData
-
license: GPLv3
name: model_Dot
type: model
version: 0.1

/* 
This model contains handlers that store the arrays (models) required to draw dot graphs.

Arrays can be stored to file, 
but also loaded into global variables where they can be accessed by getprop and setprop handlers.
This allows local getprops to override the behavior of the gloabl model.
*/


--> Dot | Node
-
/*
dot_Nodexxx props allow setting the styles of default nodes for groups of the whole graph.
*/

getprop node_Shape [groupNameOrNum]
   put the dot_GroupStyleArray of the target into dotGroupStyleArray
   put dotGroupStyleArray [groupNameOrNum]["node_StyleArray"] into nodeStyleArray
   return nodeStyleArray ["shape"]
end node_Shape

setprop node_Shape [groupNameOrNum] someShape
   put the dot_GroupStyleArray of the target into dotGroupStyleArray
   put someShape into dotGroupStyleArray [groupNameOrNum]["node_StyleArray"]["shape"]
   set the dot_GroupStyleArray of the target to dotGroupStyleArray
   
   dispatch "dot_Reconstruct" to the target
   return dotGroupStyleArray
end node_Shape

function dot_AllShapes
   -- put "rect,rectangle" & comma after nodeStyles
   put "none" & comma after nodeStyles
   put "-" & comma after nodeStyles
   put "box,ellipse,circle,point,triangle,plaintext" & comma after nodeStyles
   put "-" & comma after nodeStyles
   put "shapefile" & comma after nodeStyles
   put "-" & comma after nodeStyles
   put "polygon,diamond,pentagon,hexagon,septagon,octagon" & comma after nodeStyles
   put "-" & comma after nodeStyles
   put "doublecircle,doubleoctagon,tripleoctagon" & comma after nodeStyles
   put "Mdiamond,Msquare,Mcircle" & comma after nodeStyles
   put "-" & comma after nodeStyles
   put "egg,trapezium,parallelogram,house,invtriangle,invtrapezium,invhouse" & comma after nodeStyles
   
   delete char -1 of nodeStyles
   return nodeStyles
end dot_AllShapes

getprop node_FillColour [groupNameOrNum]
   put the dot_GroupStyleArray of the target into dotGroupStyleArray
   put dotGroupStyleArray [groupNameOrNum]["node_StyleArray"] into nodeStyleArray
   put nodeStyleArray ["fillcolor"] into dotColour
   put text_SplitCaps (dotColour) into someColour
   return someColour
end node_FillColour

setprop node_FillColour [groupNameOrNum] someColour
   put the dot_GroupStyleArray of the target into dotGroupStyleArray
   put someColour into dotGroupStyleArray [groupNameOrNum]["node_StyleArray"]["fillcolor"]
   set the dot_GroupStyleArray of the target to dotGroupStyleArray
   
   dispatch "dot_Reconstruct" to the target
   return dotGroupStyleArray
end node_FillColour

getprop node_BorderColour [groupNameOrNum]
   put the dot_GroupStyleArray of the target into dotGroupStyleArray
   put dotGroupStyleArray [groupNameOrNum]["node_StyleArray"] into nodeStyleArray
   return nodeStyleArray ["color"]
end node_BorderColour

setprop node_BorderColour [groupNameOrNum] someColour
   put the dot_GroupStyleArray of the target into dotGroupStyleArray
   put someColour into dotGroupStyleArray [groupNameOrNum]["node_StyleArray"]["color"]
   set the dot_GroupStyleArray of the target to dotGroupStyleArray
   
   dispatch "dot_Reconstruct" to the target
   return dotGroupStyleArray
end node_BorderColour


--> Overaly | Props | Plurals
-
getprop overlay_Styles
   return dot_AllGraphStyles()
end overlay_Styles

getprop overlay_Sizes
   return dot_GetGraphSizes()
end overlay_Sizes

getprop overlay_FlattenNums
   return dot_AllGraphFlattenNums()
end overlay_FlattenNums

getprop overlay_DefaultMaximumDepths
   return dot_GetGraphMaximumDepths()
end overlay_DefaultMaximumDepths


--> Dot | Node Style
-
getprop dot_NodeStyle [groupNameOrNum]
   put the displayed_OverlayName of the target into pOverlayName
   put the overlay_Array of the target into overlayArray
   put overlayArray_GetGroupStyleArray (overlayArray, pOverlayName) into dotGroupStyleArray
   
   put dotGroupStyleArray [groupNameOrNum] into nodeStyleArray
   return nodeStyleArray
end dot_NodeStyle

setprop dot_NodeStyle [groupNameOrNum] nodeStyleArray
   put the displayed_OverlayName of the target into pOverlayName
   put the overlay_Array of the target into overlayArray
   put overlayArray_GetGroupStyleArray (overlayArray, pOverlayName) into dotGroupStyleArray
   
   put dotGroupStyleArray [groupNameOrNum] into oldStyleArray
   union nodeStyleArray with oldStyleArray
   put nodeStyleArray into dotGroupStyleArray [groupNameOrNum]
   
   overlayArray_SetGroupStyleArray overlayArray, dotGroupStyleArray, pOverlayName
   set the overlay_Array of the target to overlayArray
   return overlayArray
end dot_NodeStyle

setprop dot_NodeAddStyle [groupNameOrNum] nodeStyleArray
   put the displayed_OverlayName of the target into pOverlayName
   put the overlay_Array of the target into overlayArray
   put overlayArray_GetGroupStyleArray (overlayArray, pOverlayName) into dotGroupStyleArray
   
   put dotGroupStyleArray [groupNameOrNum] into oldStyleArray
   union nodeStyleArray with oldStyleArray
   put nodeStyleArray into dotGroupStyleArray [groupNameOrNum]
   
   overlayArray_SetGroupStyleArray overlayArray, dotGroupStyleArray, pOverlayName
   set the overlay_Array of the target to overlayArray
   return overlayArray
end dot_NodeAddStyle

getprop dot_NodeStyleNames
   put the displayed_OverlayName of the target into pOverlayName
   put the overlay_Array of the target into overlayArray
   put overlayArray_GetGroupStyleArray (overlayArray, pOverlayName) into dotGroupStyleArray
   put keys(dotGroupStyleArray) into nodeStyleNames
   return nodeStyleNames
end dot_NodeStyleNames


--> Dot | Model | Props
-
/*
Wrappers around overlay_Array

*/

getprop dot_DefaultShape [pOverlayName]
   return _GetHeaderProperty (word 1 of the params, pOverlayName)
end dot_DefaultShape

setprop dot_DefaultShape [pOverlayName] someShape
   _SetHeaderProperty word 1 of the params, someShape, pOverlayName
   return the result
end dot_DefaultShape

getprop dot_Splines [pOverlayName]
   return _GetHeaderProperty (word 1 of the params, pOverlayName)
end dot_Splines

setprop dot_Splines [pOverlayName] someBoolean
   _SetHeaderProperty word 1 of the params, someBoolean, pOverlayName
   return the result
end dot_Splines

getprop dot_Concentrate [pOverlayName]
   return _GetHeaderProperty (word 1 of the params, pOverlayName)
end dot_Concentrate

setprop dot_Concentrate [pOverlayName] someBoolean
   _SetHeaderProperty word 1 of the params, someBoolean, pOverlayName
   return the result
end dot_Concentrate

getprop dot_Overlap [pOverlayName]
   return _GetHeaderProperty (word 1 of the params, pOverlayName)
end dot_Overlap

setprop dot_Overlap [pOverlayName] someOverlap
   _SetHeaderProperty word 1 of the params, someOverlap, pOverlayName
   return the result
end dot_Overlap

getprop dot_Order [pOverlayName]
   return _GetHeaderProperty (word 1 of the params, pOverlayName)
end dot_Order

setprop dot_Order [pOverlayName] dotOrder
   _SetHeaderProperty word 1 of the params, dotOrder, pOverlayName
   return the result
end dot_Order

getprop dot_ClusterRank [pOverlayName]
   return _GetHeaderProperty (word 1 of the params, pOverlayName)
end dot_ClusterRank

setprop dot_ClusterRank [pOverlayName] someBoolean
   _SetHeaderProperty word 1 of the params, someBoolean, pOverlayName
   return the result
end dot_ClusterRank


--> Dot | Property | Plurals
-
getprop dot_Orders
   return dot_OrderOptions()
end dot_Orders

getprop dot_Shapes
   return dot_AllShapes()
end dot_Shapes

getprop dot_ClusterRanks
   return dot_AllClusters()
end dot_ClusterRanks

getprop dot_Overlaps
   return dot_OverlapOptions()
end dot_Overlaps

getprop dot_Orders
   return dot_OrderOptions()
end dot_Orders

getprop dot_Clusters
   return dot_AllClusters()
end dot_Clusters

getprop dot_DefaultShapes
   return dot_AllShapes()
end dot_DefaultShapes

getprop dot_NodeColours
   return dot_NodeColourOptions()
end dot_NodeColours

getprop dot_NodeStyles
   return dot_NodeStyleOptions()
end dot_NodeStyles

getprop dot_ClusterTypes
   return dot_ClusterTypeOptions()
end dot_ClusterTypes


--> Dot | Model | Props | Functions
-
private function _GetHeaderProperty propName, pOverlayName
   if pOverlayName is empty then put the displayed_OverlayName of the target into pOverlayName
   put the overlay_Array [pOverlayName] of the target into overlayArray
   put overlayArray_GetHeaderProperty (overlayArray, propName) into propValue
   return propValue
end _GetHeaderProperty

private command _SetHeaderProperty propName, propValue, pOverlayName
   --  _SetDotValue "overlap", someOverlap, "none", pOverlayName
   
   if pOverlayName is empty then put the displayed_OverlayName of the target into pOverlayName
   put the overlay_Array [pOverlayName] of the target into overlayArray
   overlayArray_SetHeaderProperty overlayArray, propName, propValue
   
   ## Recreate files
   overlayArray_CreateFilesAndSetGeometry overlayArray
   
   set the overlay_Array [pOverlayName] of the target to overlayArray
   return the result
end _SetHeaderProperty

function dot_NodeStyleOptions
   return "filled,invisible,diagonals,rounded,dashed,dotted,solid,bold"
end dot_NodeStyleOptions

function dot_ClusterTypeOptions
   get the hKey_CaseConditions ["hkey_DotText,g"] of the dot_Model of the target
   return it & ",-,none"
end dot_ClusterTypeOptions

function dot_OverlapOptions
   return "true,-,false,scale,-,none"
end dot_OverlapOptions

function dot_OrderOptions
   return "out,in,-,none"
end dot_OrderOptions

function dot_AllClusters
   -- return "local,none"
   return "local,-,global,none"
end dot_AllClusters

function dot_NodeColourOptions
   put colour_BaseColourOutline() into colourOutline
   get outline_ConstructBranchSections(colourOutline, true)
   return "Ask,-," & it
end dot_NodeColourOptions

function dot_GetGraphMaximumDepths
   return "1,2,3,4,5,6,7,8,9,-,none"
end dot_GetGraphMaximumDepths

function dot_GetGraphSizes
   return "full,screen,image,-,none"
   -- put the hkey_CaseConditions ["dot_RectFromSize,f"] of stack "libOPN_GraphViz" into dotGraphSizes
   -- put ",-,none" after dotGraphSizes
   -- return dotGraphSizes
end dot_GetGraphSizes


--> overlayArray | Node Style
-
/*
An array that speicifes the definition section of a dot file.
Allows groups of nodes to be share a common style.

Structure:
metadata
- default (ie overlay_Name)
-   dot_NodeStyleArray
-     styleName -> ie 2 or "yellow"
-       nodeIds -> n1....
-       node_StyleArray- > a node_StyleArray or a snode_StyleName ie b"lue box"

Where the syle name refers to an array stored in the display/node_StyleArray/name section of overlay_Array
*/

getprop dot_GroupStyleArray [pOverlayName]
   if pOverlayName is empty then put the displayed_OverlayName of the target into pOverlayName
   put the overlay_Array [pOverlayName] of the target into overlayArray
   put overlayArray_GetGroupStyleArray (overlayArray, pOverlayName) into dotGroupStyleArray
   return dotGroupStyleArray
end dot_GroupStyleArray

setprop dot_GroupStyleArray [pOverlayName] dotGroupStyleArray
   if pOverlayName is empty then put the displayed_OverlayName of the target into pOverlayName
   put the overlay_Array [pOverlayName] of the target into overlayArray
   overlayArray_SetGroupStyleArray overlayArray, dotGroupStyleArray, pOverlayName
   set the overlay_Array [pOverlayName] of the target to overlayArray
   return overlayArray
end dot_GroupStyleArray

function dot_ParamsToStyleArray styleParams
   replace ", " with comma in styleParams
   split styleParams with comma and "="
   return styleParams
end dot_ParamsToStyleArray

function dot_StyleArrayToParams styleArray
   repeat for each key someParam in styleArray
      put styleArray [someParam] into someValue
      if someValue is not empty then
         put someParam & "=" & kwote(someValue) after styleParams
         put ", " after styleParams
      end if
   end repeat
   delete char -2 to -1 of styleParams
   return styleParams
end dot_StyleArrayToParams


--> Dot | Plurals
-
function dot_AllGraphStyles
   return "radial,spring,circular,-,hierarchical,-,undirected spring,fast undirected spring" 
end dot_AllGraphStyles

function dot_AllGraphFlattenNums
   return "0,1,2,3,4,5,6,7,8,9,10,11,12,-,none"
end dot_AllGraphFlattenNums


--> Dot | MetaData | Array
-
/*
The overlay_Array of an (image) view contains both the dot and the graph values in a flat property array.
To extract the overlay_PropertyArray, or the dot_HeaderArray
*/

-- getprop overlay_Array [pOverlayName]
   -- a default (for a single graph)
   -- will often be customised locally and stored in a file
   if pOverlayName is empty then put "hierarchical" into pOverlayName
   
   put the uOPN_OverlayData of the target into overlayData
   put overlayData [pOverlayName] into overlayArray
   dot_NormalizeArray overlayArray
   return overlayArray
end overlay_Array

-- setprop overlay_Array [pOverlayName] overlayArray
   if pOverlayName is empty then put "hierarchical" into pOverlayName
   
   put the uOPN_OverlayData of the target into overlayData
   put overlayArray into overlayData [pOverlayName]
   set the uOPN_OverlayData of the target to overlayArray
end overlay_Array

getprop dot_DataArray [pOverlayName]
   put the overlay_Array [pOverlayName] of the target into overlayArray
   put overlayArray ["data"] into dotDataArray
   return dotDataArray
end dot_DataArray

setprop dot_DataArray [pOverlayName] dotDataArray
   put the overlay_Array [pOverlayName] of the target into overlayArray
   put dotDataArray into overlayArray ["data"]
   set the overlay_Array [pOverlayName] of the target to overlayArray
   return overlayArray
end dot_DataArray

getprop dot_MetadataArray [pOverlayName]
   put the overlay_Array [pOverlayName] of the target into overlayArray
   put overlayArray_GetMetadataArray (overlayArray) into metadataArray
   return metadataArray
end dot_MetadataArray

setprop dot_MetadataArray [pOverlayName] metadataArray
   put the overlay_Array [pOverlayName] of the target into overlayArray
   overlayArray_SetMetadataArray overlayArray, metadataArray
   set the overlay_Array [pOverlayName] of the target to overlayArray
   return overlayArray
end dot_MetadataArray

getprop dot_HeaderArray [pOverlayName]
   put the overlay_Array [pOverlayName] of the target into overlayArray
   put overlayArray_GetHeaderArray (overlayArray) into propertyArray
   return propertyArray
end dot_HeaderArray

setprop dot_HeaderArray [pOverlayName] propertyArray
   put the overlay_Array [pOverlayName] of the target into overlayArray
   overlayArray_SetHeaderArray overlayArray, propertyArray
   set the overlay_Array [pOverlayName] of the target to overlayArray
   return overlayArray
end dot_HeaderArray

getprop dot_HeaderValue [someKey]
   put the long id of the target into targetObject
   put dot_GetHeaderValue (targetObject, someKey) into headerValue
   return headerValue
end dot_HeaderValue

setprop dot_HeaderValue [someKey] headerValue
   put the long id of the target into targetObject
   dot_SetHeaderValue targetObject, someKey, headerValue
   return the result
end dot_HeaderValue

function dot_GetHeaderValue targetObject, someKey
   put the displayed_OverlayName of targetObject into pOverlayName
   put the overlay_Array [pOverlayName] of targetObject into overlayArray
   
   put overlayArray_GetHeaderArray (overlayArray) into headerArray
   put headerArray [someKey] into someValue
   return someValue
end dot_GetHeaderValue

command dot_SetHeaderValue targetObject, someKey, someValue
   put the displayed_OverlayName of targetObject into pOverlayName
   put the overlay_Array [pOverlayName] of targetObject into overlayArray
   
   put overlayArray_GetHeaderArray (overlayArray) into headerArray
   put someValue into headerArray [someKey]
   overlayArray_SetHeaderArray overlayArray, headerArray
   
   set the overlay_Array [pOverlayName] of targetObject to overlayArray
   return headerArray
end dot_SetHeaderValue

getprop dot_DefaultHeaderValue [someKey]
   put the long id of the target into targetObject
   put dot_GetDefaultHeaderValue (targetObject, someKey) into headerValue
   return headerValue
end dot_DefaultHeaderValue

setprop dot_DefaultHeaderValue [someKey] headerValue
   put the long id of the target into targetObject
   dot_SetDefaultHeaderValue targetObject, someKey, headerValue
   return the result
end dot_DefaultHeaderValue

function dot_GetDefaultHeaderValue targetObject, someKey
   -- put the long id of the target into targetObject
   put the overlay_DefaultArray of targetObject into overlayDefaultArray
   put overlayArray_GetHeaderArray (overlayDefaultArray) into headerArray
   put headerArray [someKey] into someValue
   return someValue
end dot_GetDefaultHeaderValue

command dot_SetDefaultHeaderValue targetObject, someKey, someValue
   -- put the long id of the target into targetObject
   put the overlay_DefaultArray of targetObject into overlayDefaultArray
   
   put overlayArray_GetHeaderArray (overlayDefaultArray) into headerArray
   put someValue into headerArray [someKey]
   overlayArray_SetHeaderArray overlayDefaultArray, headerArray
   
   set the overlay_DefaultArray of targetObject to overlayDefaultArray
   return headerArray
end dot_SetDefaultHeaderValue


--> Dot | Data | Array
-
getprop dot_GeometryArray [pOverlayName]
   put the dot_DataArray [pOverlayName] of the target into dataArray
   return dataArray ["geometry"]
end dot_GeometryArray

setprop dot_GeometryArray [pOverlayName] geometryArray
   put the dot_DataArray [pOverlayName] of the target into dataArray
   put geometryArray into dataArray ["geometry"]
   set the dot_DataArray [pOverlayName] of the target to dataArray
   return dataArray
end dot_GeometryArray

getprop dot_LinkArray [pOverlayName]
   put the dot_DataArray [pOverlayName] of the target into dataArray
   return dataArray ["linkArray"]
end dot_LinkArray

setprop dot_LinkArray [pOverlayName] linkArray
   put the dot_DataArray [pOverlayName] of the target into dataArray
   put linkArray into dataArray ["linkArray"]
   set the dot_DataArray [pOverlayName] of the target to dataArray
   return dataArray
end dot_LinkArray

getprop dot_IdLinkArray [pOverlayName]
   put the dot_DataArray [pOverlayName] of the target into dataArray
   return dataArray ["idLinkArray"]
end dot_IdLinkArray

setprop dot_IdLinkArray [pOverlayName] idLinkArray
   put the dot_DataArray [pOverlayName] of the target into dataArray
   put idLinkArray into dataArray ["idLinkArray"]
   set the dot_DataArray [pOverlayName] of the target to dataArray
   return dataArray
end dot_IdLinkArray

getprop dot_IdArray [pOverlayName]
   put the dot_DataArray [pOverlayName] of the target into dataArray
   return dataArray ["idArray"]
end dot_IdArray

setprop dot_IdArray [pOverlayName] idArray
   put the dot_DataArray [pOverlayName] of the target into dataArray
   put idArray into dataArray ["idArray"]
   put array_ConstructReverseDictionary (idArray) into dataArray ["reverseIdArray"]  -- lets also set the reverse lookup
   set the dot_DataArray [pOverlayName] of the target to dataArray
   return dataArray
end dot_IdArray

getprop dot_ReverseIdArray [pOverlayName]
   put the dot_DataArray [pOverlayName] of the target into dataArray
   return dataArray ["reverseIdArray"]
end dot_ReverseIdArray

setprop dot_ReverseIdArray [pOverlayName] reverseIdArray
   put the dot_DataArray [pOverlayName] of the target into dataArray
   put reverseIdArray into dataArray ["reverseIdArray"]
   set the dot_DataArray [pOverlayName] of the target to dataArray
   return dataArray
end dot_ReverseIdArray


--> Dot | Data | Array | dot_ClusterArray
-
getprop dot_ClusterArray [pOverlayName]
   put the overlay_Array [pOverlayName] of the target into overlayArray
   put overlayArray_GetClusterArray (overlayArray) into propertyArray
   return propertyArray
end dot_ClusterArray

setprop dot_ClusterArray [pOverlayName] propertyArray
   put the overlay_Array [pOverlayName] of the target into overlayArray
   overlayArray_SetClusterArray overlayArray, propertyArray
   set the overlay_Array [pOverlayName] of the target to overlayArray
   return overlayArray
end dot_ClusterArray


command dot_ConstructPropertyArray @propertyArray, overlap, concentrate, splines, cluster, direction, dotOrder, defaultShape, defaultUrl
   -- wa "dot_ConstructHeaderArray"
   put overlap into propertyArray ["overlap"]
   put concentrate into propertyArray ["concentrate"]
   put splines into propertyArray ["splines"]
   put cluster into propertyArray ["cluster"]
   put direction into propertyArray ["direction"]
   put dotOrder into propertyArray ["dotOrder"]
   put defaultShape into propertyArray ["defaultShape"]
   put defaultUrl into propertyArray ["defaultUrl"]
end dot_ConstructPropertyArray

on dot_DeconstructPropertyArray pDotPropertyArray, @overlap, @concentrate, @splines, @cluster, @direction, @dotOrder, @defaultShape, @defaultUrl
   put pDotPropertyArray ["graphRect"] into graphRect
   put pDotPropertyArray ["overlap"] into overlap
   put pDotPropertyArray ["concentrate"] into concentrate
   put pDotPropertyArray ["splines"] into splines
   put pDotPropertyArray ["cluster"] into cluster
   put pDotPropertyArray ["direction"] into direction
   put pDotPropertyArray ["dotOrder"] into dotOrder
   put pDotPropertyArray ["defaultShape"] into defaultShape
   put pDotPropertyArray ["defaultUrl"] into defaultUrl
end dot_DeconstructPropertyArray


--> Dot | Model | Files
-
/*
Conventions for naming and organising files realted to scripts and their graphs.
*/

command dot_FilesFromHkey hKey, graphStyle, @dotFile, @imageFile, @cmapxFile, @xdotFile, pVersionName
   put hkey_DotFile (hKey, pVersionName, false) into dotFile
   
   put dotFile into dotFolder
   set the itemdelimiter to "/"
   delete item -1 of dotFolder
   put "/" after dotFolder
   overlay_Files dotFolder, dotFile, imageFile, cmapxFile, xdotFile, dotArrayFile, graphStyle
end dot_FilesFromHkey

command dot_SaveTemporaryFile dotText, dotFile
   if dotFile is empty then put dot_NewTemporaryFilePath (dotText) into dotFile
   file_CreateText dotText, dotFile
   put the result into dotFile
   return the result
end dot_SaveTemporaryFile

function dot_LabelFileWithGraphStyle graphStyle, dotFile, pImageFormat
   -- adds graphStyle_ before the short file name
   if dotFile is empty then put dot_NewTemporaryFilePath() into dotFile
   if pImageFormat is empty then put "png" into pImageFormat
   file_Deconstruct dotFile, rootFolder, shortName, dotFileFormat
   if graphStyle is not empty then
      set the itemdelimiter to "_"
      if the number of items of shortName > 1 then
         put graphStyle into item 1 of shortName
      else
         put graphStyle & "_" before shortName
      end if
   end if
   put file_Construct (rootFolder, shortName, pImageFormat) into imageFile
   return imageFile
end dot_LabelFileWithGraphStyle

function dot_NameFromImageFile imageFile
   file_Deconstruct imageFile, someRoot, shortName, fileExtension
   set the itemdelimiter to "."
   put item 1 of shortName into graphName
   return graphName
end dot_NameFromImageFile

command dot_FilesFromScriptObject scriptObject, graphStyle, pGraphSize, @dotFile, @imageFile, @cmapxFile, @xdotFile
   put scriptObject_DotFile (scriptObject, graphStyle, pGraphSize) into dotFile
   
   put dotFile into dotFolder
   set the itemdelimiter to "/"
   delete item -1 of dotFolder
   put "/" after dotFolder
   overlay_Files dotFolder, dotFile, imageFile, cmapxFile, xdotFile, dotArrayFile, graphStyle
end dot_FilesFromScriptObject

function dot_NewTemporaryFilePath dotText
   put the tempname & "/" into dotFolder
   folder_CreateNested dotFolder
   put dotFolder & "dot.txt" into dotFile
   return dotFile
end dot_NewTemporaryFilePath
