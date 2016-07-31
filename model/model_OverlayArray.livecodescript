script "model_OverlayArray"
--> MetaData
-
license: GPLv3
name: model_OverlayArray
type: model
version: 0.1


--> Overlay | Props
-
getprop overlay_Folder [pDontCreate]
   -- /metadata/objects/stack/overlay/ 
   -- which is not the "project" metadata folder
   -- it is the metadata for for a script object
   
   put the object_MetaDataFolder of the target into metadataFolder
   put metadataFolder & "overlay/" into overlayFolder
   if pDontCreate is not true then folder_CreateNested overlayFolder
   return overlayFolder
end overlay_Folder

getprop textStackOverlay_Folder [pDontCreate]
   put the textStack_Folder [pDontCreate] of the target into metadataFolder
   put metadataFolder & "metadata/project/overlay/" into overlayFolder
   if pDontCreate is false then folder_CreateNested overlayFolder
   return overlayFolder
end textStackOverlay_Folder


--> OverlayArray | Hash
-
function overlayArray_GetMainStackHash overlayArray
   put overlayArray_GetMetadataArray (overlayArray) into metadataArray
   put metadataArray ["mainstack_Hash"] into mainstackHash
   return mainstackHash
end overlayArray_GetMainStackHash

command overlayArray_SetMainStackHash @overlayArray, mainstackHash
   put overlayArray_GetMetadataArray (overlayArray) into metadataArray
   put mainstackHash into metadataArray ["mainstack_Hash"]
   overlayArray_SetMetadataArray overlayArray, metadataArray
end overlayArray_SetMainStackHash


--> OverlayArray | Cluster
-
function overlayArray_ConstructDefaultDefSection overlayArray, extraBit
   overlayArray_DeconstructData overlayArray, linkArray, idArray, idLinkArray, reverseIdLinkArray, dotClusterArray
   repeat for each key nodeID in idArray
      put idArray [nodeID] into nodeLabel
      -- put nodeID && "[label=" & kwote(nodeLabel) into nodeDefLine
      put nodeLabel && "["into nodeDefLine
      
      -- put urlencode (hKey) into someUrl
      -- put space & "URL=" & kwote(someUrl) after nodeDefLine
      put space & extraBit after nodeDefLine
      put "];" after nodeDefLine
      put nodeDefLine & CR after dotDefSection
   end repeat
   delete char -1 of dotDefSection
   return dotDefSection
end overlayArray_ConstructDefaultDefSection

function overlayArray_ConstructFlatSubCluster dotClusterArray, someObject, idArray
   put dotClusterArray [someObject] into nodeIds
   repeat for each line nodeID in nodeIds
      put dot_ConstructDefaultDefLine (nodeID, idArray) into nodeDefLine
      put nodeDefLine & CR after nodeSection
   end repeat
   delete char -1 of nodeSection
   return nodeSection
end overlayArray_ConstructFlatSubCluster

function overlayArray_ConstructClusterSection overlayArray, pFlatCluster
   -- general function to construct a cluster section from a overlayArray
   -- start with non-recursive
   overlayArray_DeconstructData overlayArray, linkArray, idArray, idLinkArray, reverseIdLinkArray, dotClusterArray
   
   if pFlatCluster is not true then
      put overlayArray_DotNestedObjectClusters (idArray, linkArray, graphNodeType) into clusterSection
      return clusterSection
   else
      put 1 into clusterNum
      repeat for each key someObject in dotClusterArray -- clusterNames are objects
         put overlayArray_ConstructFlatSubCluster (dotClusterArray, someObject, idArray) into nodeSection
         
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
   end if
end overlayArray_ConstructClusterSection

function overlayArray_DotNestedObjectClusters hIdArray, hLinkArray, graphNodeType
   -- put linkarray_FilterIdArray (hIdArray, hLinkArray) into hIdArray
   put hKeyArray_ConstructObjectIdArray (hIdArray) into linkObjectIdArray
   put keys(linkObjectIdArray) into linkObjects
   sort linkObjects
   put object_OutlineFromIndex (linkObjects) into objectOutline
   put outline_ToXmlStructure (objectOutline)into structureXml
   put hKeyArray_XmlToClusters (structureXml, objectOutline, hIdArray, graphNodeType) into clusterDefs
   return clusterDefs
end overlayArray_DotNestedObjectClusters

function overlayArray_ConstructDotClusters objectIDArray, idArray, pNotIfEmpty
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
end overlayArray_ConstructDotClusters


--> overlayArray | Construct
-
command overlayArray_ReconstructAndCreateFiles linkArray, overlayName, overlayFolder, pGraphStyle, dotHeaderArray, graphPropertyArray
   put overlayArray_FromLinkArray (linkArray, dotHeaderArray, graphPropertyArray) into overlayArray
   overlayArray_SetGraphProperty overlayArray, "overlay_Folder", overlayFolder
   overlayArray_SetGraphProperty overlayArray, "overlay_Name", overlayName
   if pGraphStyle is empty then
      if overlayName is among the items of dot_AllGraphStyles() then
         put overlayName into pGraphStyle
      else
         put "hierarchical" into pGraphStyle
      end if
   end if
   overlayArray_SetGraphProperty overlayArray, "overlay_Style", pGraphStyle
   overlayArray_CreateFilesAndSetGeometry overlayArray
   return overlayArray
end overlayArray_ReconstructAndCreateFiles

command overlayArray_CreateFilesAndSetGeometry @overlayArray, pMainstackHash, pImageFormat
   -- does not save overlay array
   if overlayArray is not an array then return empty
   put overlayArray_GetLinkArray (overlayArray) into hkeyArray
   if hkeyArray is not an array then return empty
   
   -- creates all the dot and image files (but does nto save the array files)
   overlay_CreateDotFiles overlayArray, empty, pImageFormat
   put the result into gvResult
   if token 1 of gvResult = "error" then
      opn_Notify gvResult, true
      return gvResult
   end if
   
   put overlayArray_GetGraphProperty (overlayArray, "overlay_Folder") into overlayFolder
   put overlayArray_GetGraphProperty (overlayArray, "overlay_Name") into overlayName
   
   ## now set geometry by using dot to recreate files and then extract geometry array
   put overlay_GetCmapText (overlayFolder, overlayName) into cmapText
   put imagemap_ParseMap (cmapText) into geometryArray
   overlayArray_SetGeometryArray overlayArray, geometryArray
   
   ## Store overlayArray in case not already stored
   overlay_SetArray overlayFolder, overlayArray, overlayName, pMainstackHash
   return geometryArray
end overlayArray_CreateFilesAndSetGeometry

function overlayArray_FromLinkArray linkArray, pDotHeaderArray, pGraphPropertyArray
   local overlayArray
   if linkArray is not an array then return empty
   
   overlayArray_SetData overlayArray, linkArray
   overlayData_ConstructAndSetGroupStyleArray overlayArray, pOverlayName
   put overlayData_ConstructClusterArray (overlayArray) into clusterArray
   overlayArray_SetClusterArray overlayArray, clusterArray
   
   if pDotHeaderArray is an array then overlayArray_SetHeaderArray overlayArray, pDotHeaderArray
   if pGraphPropertyArray is an array then overlayArray_SetGraphPropertyArray overlayArray, pGraphPropertyArray
   
   put overlay_GetDefaultArray() into dotDefaultArray -- not working
   overlayArray_AddDefaultUnion overlayArray, dotDefaultArray
   dot_NormalizeArray overlayArray -- should not be needed if overlay_GetDefaultArray() gets somethign sensible
   
   return overlayArray
end overlayArray_FromLinkArray

function overlay_GetDefaultArray
   return empty
end overlay_GetDefaultArray

function overlayArray_Construct metadataArray, linkArray, pOverlayName
   local overlayArray
   overlayArray_SetMetadataArray overlayArray, metadataArray, pOverlayName
   overlayArray_SetData overlayArray, linkArray
   return overlayArray
end overlayArray_Construct

command overlayArray_ResetData @overlayArray, linkArray
   put overlayArray ["data"] into dataArray
   overlayArray_ConstructDataArray dataArray, linkArray
   put dataArray into overlayArray ["data"]
   put overlay_GetDefaultArray() into dotDefaultArray
   overlayArray_AddDefaultUnion overlayArray, dotDefaultArray
end overlayArray_ResetData

command overlayArray_ConstructDataArray @dataArray, linkArray
   linkArray_IdConstruct linkArray, idLinkArray, idArray
   
   put linkArray into dataArray ["linkArray"]
   put idLinkArray into dataArray ["idLinkArray"]
   put idArray into dataArray ["idArray"]
   
   put array_ConstructReverseDictionary (idArray) into reversedIdArray
   put reversedIdArray into dataArray ["reverseIdArray"]
end overlayArray_ConstructDataArray

command overlayArray_AddToGroupStyleArray nodeIds, nodeStyleArrayOrName, @dotGroupStyleArray, pStyleName
   if pStyleName is empty then
      put the number of lines of keys(dotGroupStyleArray) + 1 into pStyleName
   end if
   put nodeIds into dotGroupStyleArray [pStyleName]["nodeIds"]
   put nodeStyleArrayOrName into dotGroupStyleArray [pStyleName]["node_StyleArray"]
   return pStyleName
end overlayArray_AddToGroupStyleArray

function overlayArray_ConstructGroupStyleArray nodeIds, nodeStyleArrayOrName
   put nodeIds into dotGroupStyleArray ["nodeIds"]
   put nodeStyleArrayOrName into dotGroupStyleArray ["node_StyleArray"]
   return dotGroupStyleArray
end overlayArray_ConstructGroupStyleArray

command overlayArray_DeconstructGroupStyleArray @nodeIds, @nodeStyleArrayOrName, dotGroupStyleArray
   put dotGroupStyleArray ["nodeIds"] into nodeIds
   -- replace comma with ", " in nodeIds
   put dotGroupStyleArray ["node_StyleArray"] into nodeStyleArrayOrName
end overlayArray_DeconstructGroupStyleArray


--> overlayArray | Graph | Props | Toplevel
-
command overlayArray_SetData @overlayArray, linkArray
   linkArray_IdConstruct linkArray, nodeLinkArray, nodeIdArray
   put linkArray_ConstructDataArray (linkArray, nodeLinkArray, nodeIdArray) into dataArray
   put dataArray into overlayArray ["data"]
end overlayArray_SetData

function overlayArray_GetLinkArray overlayArray
   return overlayArray ["data"]["linkArray"]
end overlayArray_GetLinkArray

command overlayArray_SetLinkArray @overlayArray, linkArray
   put linkArray into overlayArray ["data"]["linkArray"]
end overlayArray_SetLinkArray

function overlayArray_GetIdArray overlayArray
   return overlayArray ["data"]["idArray"]
end overlayArray_GetIdArray

command overlayArray_SetIdArray @overlayArray, idArray
   put idArray into overlayArray ["data"]["idArray"]
end overlayArray_SetIdArray

function overlayArray_GetGeometryArray overlayArray
   return overlayArray ["data"]["geometry"]
end overlayArray_GetGeometryArray

command overlayArray_SetGeometryArray @overlayArray, geometryArray
   put geometryArray into overlayArray ["data"]["geometry"]
end overlayArray_SetGeometryArray

command overlayArray_ConstructAndAddGeometry @dataArray, cmapxFile
   -- to add geometryArray need dot to export the file cmapxFile
   put overlayArray_GetGraphProperty (overlayArray, "overlay_Name") into overlayName
   put the script_GeometryArrayFromCmap [overlayName] of scriptObject into geometryArray
   overlayArray_SetGeometryArray overlayArray, geometryArray
end overlayArray_ConstructAndAddGeometry

function overlayArray_GetClusterArray overlayArray
   put overlayArray ["data"] into dotDataArray
   put dotDataArray ["dot_ClusterArray"] into dotClusterArray
   return dotClusterArray
end overlayArray_GetClusterArray

command overlayArray_SetClusterArray @overlayArray, dotClusterArray
   put overlayArray ["data"] into dotDataArray
   put dotClusterArray into overlayArray ["data"]["dot_ClusterArray"]
end overlayArray_SetClusterArray


--> overlayArray | Sections
-
function overlayArray_GetGroupStyleArray overlayArray
   put overlayArray_GetMetadataArray (overlayArray) into metadataArray
   put metadataArray ["dot_GroupStyleArray"] into dotGroupStyleArray
   return dotGroupStyleArray
end overlayArray_GetGroupStyleArray

command overlayArray_SetGroupStyleArray @overlayArray, dotHeaderArray
   if dotHeaderArray is not an array then
      delete local overlayArray ["metadata"]["dot_GroupStyleArray"]
      return empty
   else
      put overlayArray_GetMetadataArray (overlayArray, pOverlayName) into metadataArray
      put dotHeaderArray into metadataArray ["dot_GroupStyleArray"]
      overlayArray_SetMetadataArray overlayArray, metadataArray, pOverlayName
      return metadataArray
   end if
end overlayArray_SetGroupStyleArray

function overlayArray_GetHeaderArray overlayArray
   put overlayArray_GetMetadataArray (overlayArray) into metadataArray
   put metadataArray ["dot_HeaderArray"] into dotHeaderArray
   return dotHeaderArray
end overlayArray_GetHeaderArray

command overlayArray_SetHeaderArray @overlayArray, dotHeaderArray
   if dotHeaderArray is not an array then return empty
   put overlayArray_GetMetadataArray (overlayArray) into metadataArray
   put dotHeaderArray into metadataArray ["dot_HeaderArray"]
   overlayArray_SetMetadataArray overlayArray, metadataArray
   return metadataArray
end overlayArray_SetHeaderArray

function overlayArray_GetGraphPropertyArray overlayArray
   put overlayArray ["metadata"]["graph_PropertyArray"] into graphPropertyArray
   return graphPropertyArray
end overlayArray_GetGraphPropertyArray  

command overlayArray_SetGraphPropertyArray @overlayArray, graphPropertyArray
   if graphPropertyArray is not an array then
      delete local overlayArray ["metadata"]["graph_PropertyArray"]
   else
      put graphPropertyArray into overlayArray ["metadata"]["graph_PropertyArray"]
   end if
end overlayArray_SetGraphPropertyArray

function overlayArray_GetMetadataArray overlayArray
   put overlayArray ["metadata"] into metadataArray
   return metadataArray
end overlayArray_GetMetadataArray

command overlayArray_SetMetadataArray @overlayArray, metadataArray
   put metadataArray into overlayArray ["metadata"]
   return overlayArray
end overlayArray_SetMetadataArray


--> Dot | MetaData | Arrays
-
function overlayArray_GetHeaderProperty overlayArray, propName
   put overlayArray ["metadata"]["dot_HeaderArray"][propName] into propValue
   return propValue
end overlayArray_GetHeaderProperty  

command overlayArray_SetHeaderProperty @overlayArray, propName, propValue
   if propValue is empty then
      delete local overlayArray ["metadata"]["dot_HeaderArray"][propName]
   else
      put propValue into overlayArray ["metadata"]["dot_HeaderArray"][propName]
   end if
end overlayArray_SetHeaderProperty

function overlayArray_GetGraphProperty overlayArray, propName
   put overlayArray ["metadata"]["graph_PropertyArray"][propName] into propValue
   return propValue
end overlayArray_GetGraphProperty  

command overlayArray_SetGraphProperty @overlayArray, propName, propValue
   if propValue is empty then
      delete local overlayArray ["metadata"]["graph_PropertyArray"][propName]
   else
      put propValue into overlayArray ["metadata"]["graph_PropertyArray"][propName]
   end if
end overlayArray_SetGraphProperty

command overlayArray_StripDefaultProps @overlayArray, defaultArray
   -- was "hkey_StripDefaultProps"
   
   put defaultArray ["metadata"] into defaultMetadataArray
   
   put defaultMetadataArray ["dot_HeaderArray"] into dotHeaderArray
   repeat for each key dotHeaderKey in dotHeaderArray
      delete local overlayArray ["metadata"]["dot_HeaderArray"][dotHeaderKey]
   end repeat
   put overlayArray ["metadata"]["dot_HeaderArray"] into fileDotHeaderArray
   if keys (fileDotHeaderArray) is empty then delete local overlayArray ["metadata"]["dot_HeaderArray"]
   
   put defaultMetadataArray ["graph_PropertyArray"] into graphPropertyArray
   repeat for each key graphPropertyKey in graphPropertyArray
      delete local overlayArray ["metadata"]["graph_PropertyArray"][graphPropertyKey]
   end repeat
   put overlayArray ["metadata"]["graph_PropertyArray"] into fileGraphPropertyArray
   if keys (fileGraphPropertyArray) is empty then delete local overlayArray ["metadata"]["graph_PropertyArray"]
   
   put overlayArray ["metadata"] into metadataArray
   put metadataArray ["dot_GroupStyleArray"] into dotGroupStyleArray
   repeat for each key styleKey in dotGroupStyleArray
      delete local overlayArray ["metadata"]["dot_GroupStyleArray"][styleKey]["node_StyleArray"]
   end repeat
   put overlayArray ["metadata"]["dot_GroupStyleArray"] into dotGroupStyleArray
   if keys (dotGroupStyleArray) is empty then delete local overlayArray ["metadata"]["dot_GroupStyleArray"]
end overlayArray_StripDefaultProps

command overlayArray_AddDefaults @overlayArray, defaultDataArray, defaultMetadataArray
   -- does not construct geometry array (for that need dot and files)
   put overlayArray ["metadata"] into metadataArray
   put overlayArray ["data"] into dataArray
   
   put dataArray ["linkArray"] into graphLinkArray
   overlayArray_ConstructDataArray dataArray, graphLinkArray
   
   -- overlayArray_ConstructAndAddGeometry dataArray, cmapxFile
   
   -- set "linkArray"
   -- use default data in case graph data is empty, do not make union for data
   if graphLinkArray is an array then
      put graphLinkArray into overlayArray ["data"]["linkArray"]
   else
      put defaultDataArray ["linkArray"] into overlayArray ["data"]["linkArray"]
   end if
   
   -- for the rest of the props use a "union" 
   
   -- merge "graph_PropertyArray"
   put metadataArray ["graph_PropertyArray"] into graphPropertyArray
   put defaultMetadataArray ["graph_PropertyArray"] into defaultGraphPropertyArray
   array_Union graphPropertyArray, defaultGraphPropertyArray
   put graphPropertyArray into overlayArray ["metadata"]["graph_PropertyArray"]
   
   -- merge "dot_HeaderArray"
   put metadataArray ["dot_HeaderArray"] into graphPropertyArray
   put defaultMetadataArray ["dot_HeaderArray"] into defaultGraphPropertyArray
   array_Union graphPropertyArray, defaultGraphPropertyArray
   put graphPropertyArray into overlayArray ["metadata"]["dot_HeaderArray"]
   
   -- merge "dot_HeaderArray"
   put metadataArray ["dot_GroupStyleArray"] into groupStyleArray
   repeat for each key handlerType in groupStyleArray
      put defaultMetadataArray ["dot_GroupStyleArray"][handlerType]["node_StyleArray"] into defaultHandlerTypeStyleArray
      put groupStyleArray [handlerType]["node_StyleArray"] into handlerTypeStyleArray
      
      array_Union handlerTypeStyleArray, defaultHandlerTypeStyleArray
      
      if handlerTypeStyleArray is an array then
         put handlerTypeStyleArray into overlayArray ["metadata"]["dot_GroupStyleArray"][handlerType]["node_StyleArray"]
      else
         delete local overlayArray ["metadata"]["dot_GroupStyleArray"][handlerType]["node_StyleArray"]
      end if
   end repeat
end overlayArray_AddDefaults

command overlayArray_AddDefaultUnion @overlayArray, dotDefaultArray
   put overlayArray ["metadata"] into metadataArray
   
   put dotDefaultArray ["metadata"] into defaultNamedMetadataArray
   put overlayArray ["metadata"] into namedMetadataArray
   
   put namedMetadataArray ["graph_PropertyArray"] into graphArray
   put defaultNamedMetadataArray ["graph_PropertyArray"] into defaultGraphArray
   array_Union graphArray, defaultGraphArray
   put graphArray into overlayArray ["metadata"]["graph_PropertyArray"]
   
   put namedMetadataArray ["dot_HeaderArray"] into headerArray
   put defaultNamedMetadataArray ["dot_HeaderArray"] into defaultHeaderArray
   array_Union headerArray, defaultHeaderArray
   put headerArray into overlayArray ["metadata"]["dot_HeaderArray"]
   
   put namedMetadataArray ["dot_GroupStyleArray"] into groupStyleArray
   repeat for each key handlerType in groupStyleArray
      put defaultNamedMetadataArray ["dot_GroupStyleArray"][handlerType]["node_StyleArray"] into defaultHandlerTypeStyleArray
      put groupStyleArray [handlerType]["node_StyleArray"] into handlerTypeStyleArray
      array_Union handlerTypeStyleArray, defaultHandlerTypeStyleArray
      if handlerTypeStyleArray is an array then
         put handlerTypeStyleArray into overlayArray ["metadata"]["dot_GroupStyleArray"][handlerType]["node_StyleArray"]
      else
         delete local overlayArray ["metadata"]["dot_GroupStyleArray"][handlerType]["node_StyleArray"]
      end if
   end repeat
end overlayArray_AddDefaultUnion

command overlayArray_DeconstructMetadata overlayArray, @graphPropertyArray, @dotHeaderArray, @nodePropertyArray, @edgePropertyArray, @dotGroupStyleArray
   -- overlayArray_DeconstructMetadata overlayArray, graphPropertyArray, dotHeaderArray, nodePropertyArray, edgePropertyArray, dotGroupStyleArray, pOverlayName
   put overlayArray ["metadata"] into metadataArray
   
   put metadataArray ["graph_PropertyArray"] into graphPropertyArray
   put metadataArray ["dot_HeaderArray"] into dotHeaderArray
   put metadataArray ["node_PropertyArray"] into nodePropertyArray
   put metadataArray ["edge_PropertyArray"] into edgePropertyArray
   put metadataArray ["dot_GroupStyleArray"] into dotGroupStyleArray
end overlayArray_DeconstructMetadata

command overlayArray_DeconstructData overlayArray, @linkArray, @idArray, @idLinkArray, @reverseIdArray, @dotClusterArray
   -- overlayArray_DeconstructData overlayArray, linkArray, idArray, idLinkArray, reverseIdArray, dotClusterArray
   put overlayArray ["data"] into dataArray
   linkArray_DeconstructDataArray dataArray, linkArray, idLinkArray, idArray, reverseIdArray
   put dataArray ["dot_ClusterArray"] into dotClusterArray
   -- put dataArray ["linkArray"] into linkArray
   -- put dataArray ["idArray"] into idArray
   -- put dataArray ["idLinkArray"] into idLinkArray
   -- put dataArray ["reverseIdLinkArray"] into reverseIdLinkArray
end overlayArray_DeconstructData

function overlayArray_ConstructDefaultDefSection overlayArray, extraBit
   overlayArray_DeconstructData overlayArray, linkArray, idArray, idLinkArray, reverseIdLinkArray, dotClusterArray
   repeat for each key nodeID in idArray
      put idArray [nodeID] into nodeLabel
      replace quote with "'" in nodeLabel
      put nodeID && "[label=" & kwote(nodeLabel) into nodeDefLine
      -- put nodeLabel && "["into nodeDefLine
      
      -- put urlencode (hKey) into someUrl
      -- put space & "URL=" & kwote(someUrl) after nodeDefLine
      put space & extraBit after nodeDefLine
      put "];" after nodeDefLine
      put nodeDefLine & CR after dotDefSection
   end repeat
   return dotDefSection
end overlayArray_ConstructDefaultDefSection


--> Deps
-
function imagemap_ParseMap someXml
   if someXml is empty then return empty
   replace ("\" & CR) with empty in someXml
   
   put revCreateXMLTree (someXml, false, true, false) into treeID
   if item 1 of treeID is "xmlerr" then return empty
   
   put revXMLRootNode(treeID) into rootNode
   put revXMLAttribute (treeID, rootNode, "id") into mapID
   put revXMLAttribute (treeID, rootNode, "name") into mapName
   
   put revXMLChildNames(treeID, rootNode, CR, "", true) into nodeIndex
   put 1 into indexNum
   repeat for each line shortNode in nodeIndex
      put rootNode & "/" & shortNode into childNode
      put revXMLAttributes(treeID, childNode, tab, CR) into tagArray
      split tagArray using CR and tab
      
      put tagArray into dgArray [indexNum]["area"]
      
      put tagArray ["href"] into someUrl
      put someUrl into dgArray [indexNum]["rev"]["url"] -- useful for images or nodes without labels
      put tagArray ["id"] into dgArray [indexNum]["rev"]["name"]
      put tagArray ["title"] into dgArray [indexNum]["rev"]["label"]
      -- put tagArray ["alt"] into dgArray [indexNum]["rev"]["name"] -- = "label" in nodeDef
      put tagArray ["shape"] into someShape
      put someShape into dgArray [indexNum]["rev"]["style"]
      put tagArray ["coords"] into dgArray [indexNum]["rev"]["rect"]
      put tagArray ["coords"] into dgArray [indexNum]["rev"][someShape]
      add 1 to indexNum
   end repeat
   revDeleteXMLTree treeID
   return dgArray
end imagemap_ParseMap
