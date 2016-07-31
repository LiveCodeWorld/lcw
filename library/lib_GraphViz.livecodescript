script "lib_GraphViz"
--> MetaData
-
license: GPLv3
name: lib_GraphViz
type: library
version: 1.0
copyright: David Bovill


/* libOPN_GraphViz
A library for interfacing with the GraphViz command line utitlites.

What is the coordinate transformation between the graph bb and a .png image?

1. The bb is expanded by 4 graph-units in all directions (pad) to allow for finite line widths.
2. then it is zoomed and/or rotated according to -Gviewport, -Gsize, -Glandscape, -Gorientation options. 
At the default scaling of 1:1, one graph unit = 1 point (1/72 inch).
3. then it is paginated, if requested by -Gpage and if the output format supports it. Not the -Tpng renderer, yet.
4. then a margin is added, -Gmargin, in absolute units (inches). The top/bottom margin can be set independently of the left/right margin.
5. then it is converted to device units, according to -Gdpi, or a dpi value that is given by the output device, or a default that is provided by each render. There are separate dpi values for x and y to allow for non-square pixels. Some renderers invert the Y axis and need an offset to place the origin in the top left corner. The default dpi for -Tpng is 96dpi (approximating the resolution of most computer monitors) so this is where the scaling by 96/72 (4/3) comes from. 

At the renderer api, plugins have a choice of coordinate representation:

* coordinates in graph-units, and composite transformation data consisting of: scaling, rotation, and translation. (used by svg, cairo, ps, renderers)
* coordinates pre-transformed into device units. 

At present, most device-independent units are either inches or points, which we take as 72 points per inch. 
*/


--> Graph | Model
-
/*
This model contains the data needed to determine how a graph is drawn from a given dot file.
*/

getprop graph_Model -- old
   -- add this handler locally to override default bahaviour
   -- and create local models for each graph
   
   return the long id of me
end graph_Model


--> GraphViz
-
function graphviz_ColourOutline
   /*
   Can be used to create a (sub)menu.
   
   Displays all X11 colours,
   or or at least the colours that rev and Graphviz understands
   */
   
   put colour_BaseColourOutline() into graphvizColours
   put "Light Green,Dark Magenta" into dodgyColours
   replace comma with CR in dodgyColours
   line_Delete dodgyColours, graphvizColours
   return graphvizColours
end graphviz_ColourOutline


--> Dot
-
function dot_ConvertToXml dotFile, pOutputFile
   put "gv2gxl" into someShell
   shell_BashParamEscape dotFile
   put space && dotFile after someShell
   if pOutputFile is not empty then
      put "-o" & pOutputFile after someShell -- single space I think
   end if
   put git_ExecuteShellCommand (someShell) into shellResult
   return shellResult
end dot_ConvertToXml

on graph_DeconstructPropertyArray dotPropertyArray, @nodeIDs, @flattenNum
   put dotPropertyArray ["nodeIDs"] into nodeIDs
   put dotPropertyArray ["flattenNum"] into flattenNum
end graph_DeconstructPropertyArray

on graph_ConstructPropertyArray @dotPropertyArray, nodeIDs, flattenNum
   if flattenNum is empty then put the overlay_FlattenNum of the graph_Model of the target into flattenNum
   
   put nodeIDs into dotPropertyArray ["nodeIDs"]
   put flattenNum into dotPropertyArray ["flattenNum"]
end graph_ConstructPropertyArray


--> Dot
-
on dot_NormalizeDotCommand @graphStyle
   -- converts a loosely named "overlay_Style" from a user input, to a formal "dot_OutputFormat"
   
   if graphStyle is empty then put the overlay_Style of me into graphStyle
   switch
      case graphStyle is among the items of "spring,neato"
         /*
         draws undirected graphs using ``spring'' models
         (see Kamada and Kawai, Information Processing Letters 31:1, April 1989).
         */
         put "neato" into graphStyle
         break
      case graphStyle is among the items of "circular,circo"
         /*
         draws graphs using a circular layout (see Six and Tollis, GD '99 and ALENEX '99, and Kaufmann and Wiese, GD '02.)  
         The tool identifies biconnected components and draws the nodes of the component on a circle. 
         The block-cutpoint tree is then laid out using a recursive radial algorithm. 
         Edge crossings within a circle are minimized by placing as many edges on the circle's perimeter as possible.  
         In particular, if the component is outerplanar, the component will have a planar layout.
         
         If a node belongs to multiple non-trivial biconnected components, the layout puts the node in one of them.
         By default, this is the first non-trivial component found in the search from the root component.
         */
         put "circo" into graphStyle
         break
      case graphStyle is among the items of "radial,twopi"
         /*
         draws graphs using a radial layout (see G. Wills, Symposium on Graph Drawing GD'97, September, 1997).  
         Basically, one node is chosen as the center and put at the origin.  
         The remaining nodes are placed on a sequence of concentric circles centered about the origin, 
         each a fixed radial distance from the  previous  circle.   
         All  nodes distance 1 from the center are placed on the first circle;
         all nodes distance 1 from a node on the first circle are placed on the second circle; and so forth.
         */
         put "twopi" into graphStyle
         break
      case graphStyle is among the items of "undirected spring,fdp"
         /*
         filter for drawing undirected graphs
         draws undirected graphs using a "spring'' model. 
         It relies on a force-directed approach in the spirit of Fruchterman and Reingold 
         (cf. Software-Practice & Experience 21(11), 1991, pp. 1129-1164).
         */
         put "fdp" into graphStyle
         break
      case graphStyle is among the items of "fast spring,fast undirected spring,sfdp"
         -- sfdp - filter for drawing large undirected graphs
         /*
         also draws undirected graphs using the "spring'' model described above, 
         but it uses a multi-scale approach to produce layouts of large graphs in a reasonably short time.
         */
         put "fdp" into graphStyle
         break
      default
         /*
         draws  directed  graphs.
         It works well on DAGs and other graphs that can be drawn as hierarchies.  
         */
         put "dot" into graphStyle
   end switch
end dot_NormalizeDotCommand

function dot_OutputFormats
   -- was "dot_GetOutputFormats"
   return "jpg,png,gif,-,canon,cmap,cmapx,dia,dot,epdf,fig,hpgl,imap,ismap,mif,mp,pcl,pdf,pic,plain,plain-ext,ps,ps2,svg,svgz,vtx,xdot"
end dot_OutputFormats

function dot_OutputMainFormats
   return "jpg,png,gif,-,pdf,ps,ps2,svg,-,cmapx,dot,plain,plain-ext,xdot"
end dot_OutputMainFormats

function dot_ImageFormats
   -- the ones Rev can render
   return "jpg,png,gif"
end dot_ImageFormats

function dot_OutputImageFormats
   return "jpg,png,gif,pdf,ps,ps2,svg,svgz"
end dot_OutputImageFormats

function dot_OutputTextFormats
   return "cmap,cmapx,dot,imap,ismap,plain,plain-ext,xdot"
end dot_OutputTextFormats

function dot_OutputStrangeFormats
   return "canon,dia,epdf,fig,hpgl,pdf,pic,ps,ps2,vtx"
end dot_OutputStrangeFormats


--> Dot | Overlay
-
function dot_ConstructOverlayArray dotText, graphStyle, pTextFile
   put dot_Render (dotText, graphStyle, pTextFile, "cmapx") into cmapxText
   put imagemap_ParseMap (cmapxText) into dgArray
   put dgArray into graphArray ["data"]
   return graphArray
end dot_ConstructOverlayArray


--> Dot
-
function dot_TestDataFolder shortFile, pDontCreate
   return library_PluginFolder ("opn_TestData/dot/", pDontCreate) & shortFile
end dot_TestDataFolder

function dot_GetTestData shortFile  
   put dot_TestDataFolder (shortFile) into someFile
   put url ("file:" & someFile) into dotText
   return dotText
end dot_GetTestData

command dot_SetTestData shortFile, dotText
   put dot_TestDataFolder () into dotFolder
   folder_CreateNested dotFolder
   put dotFolder & shortFile into someFile
   put dotText into url ("file:" & someFile)
end dot_SetTestData

on dot_DeconstructTextResult dotTextResult, @dotText, @dotError
   repeat with firstLineNum = 1 to the number of lines of dotTextResult
      if word 1 of line firstLineNum of dotTextResult = "digraph" then
         exit repeat
      end if
   end repeat
   put line firstLineNum to -1 of dotTextResult into dotText
   put line 1 to (firstLineNum - 1) of dotTextResult into dotError
end dot_DeconstructTextResult

function dot_GetLinkSection linkArray
    local nodeLinks
    repeat for each key fromLink in linkArray
        put linkArray [fromLink] into toLinks
        dot_NormalizeNode fromLink
        repeat for each line toLink in toLinks
            dot_NormalizeNode toLink
            put fromLink && "->" && toLink & ";" & CR after nodeLinks
        end repeat
    end repeat
    return nodeLinks
end dot_GetLinkSection

on dot_NormalizeNode @someNode
    replace quote with empty in someNode
    if the number of words of someNode > 1 then
        put kwote(someNode) into someNode
    end if
end dot_NormalizeNode

function dot_Construct graphName, nodeSection, graphHeader
   put graphHeader into dotText
   line_Insert nodeSection, dotText
   put "digraph" && kwote(graphName) && "{" & CR & outline_IncreaseIndent (dotText) & CR & "}" into dotText
   return dotText
end dot_Construct

function dot_ConstructCluster someLabel, clusterNum, nodeSection, someRank, someStyle, someColour, fillColour
    put "cluster" & clusterNum into subGraphName
    return dot_ConstructSubgraph(subGraphName, nodeSection, someRank, someStyle, someColour, someLabel, fillColour)
    return merge(subGraph)
end dot_ConstructCluster

function dot_ConstructSubgraph subGraphName, nodeSection, someRank, someStyle, someColour, someLabel, fillColour
    put "subgraph" into subGraph
    if subGraphName is not empty then put space & subGraphName after subGraph
    put space & "{" & CR after subGraph
    put dot_SubGraphContents (someLabel, nodeSection, someRank, someStyle, someColour, fillColour) after subGraph
    put CR & "}" after subGraph
    return subGraph
end dot_ConstructSubgraph

function dot_SubGraphContents someLabel, nodeSection, someRank, someStyle, someColour, fillColour
   dot_EscapeQuotes someLabel
   
   -- if someRank is empty then put "same" into someRank
   if someStyle is empty then put "filled" into someStyle
   if someColour is empty then put "grey60" into someColour
   if fillColour is empty then put "grey90" into fillColour
   
   if someLabel is not empty then put tab & "label=" & kwote(someLabel) & ";" after subGraph
   if someRank is not empty then put CR & tab & "rank = [[someRank]];" after subGraph
   put CR & tab & "style=[[someStyle]];" after subGraph
   put CR & tab & "color=[[someColour]];" after subGraph
   put CR & tab & "fillcolor=[[fillColour]];" after subGraph
   
   put CR after subGraph
   if nodeSection is not empty then
      put CR & outline_IncreaseIndent(nodeSection) after subGraph
   end if
   return merge(subGraph)
end dot_SubGraphContents

on dot_SetGraphSectionOffsets @dotText, @startChar, @endChar
   --trims top and tail of dotText
   put word 1 to -1 of dotText into dotText
   put 0 into startChar
   put 0 into endChar
   
   set the wholematches to true
   put wordOffset("graph", dotText) into wordNum
   if wordNum = 0 then return false
   
   put the number of chars of (word 1 to wordNum of dotText) - 4 into startChar
   put offset ("];", dotText, startChar) into skipNum  -- could use a regular expression here
   if wordNum = 0 then
      put 0 into startChar
      return false
   end if
   put startChar + skipNum + 1 into endChar
   return true
   
   -- put "(?Umi)\W*(graph\W\[.*\];)" into someReg -- does not work for multiline's
   -- put "(?Umi)\W(graph\W*\[.*)" into someReg
   put "(?Uim)\W*(graph\W*\[" into someReg
   put CR & ".*" after someReg
   put "\];)" after someReg
   put matchchunk (dotText, someReg, startChar, endChar) into foundGraphSection
   return foundGraphSection
end dot_SetGraphSectionOffsets


--> Dot | Geometry
-
function dot_RectFromSize graphSize
   switch graphSize
      case empty
         return empty
      case "full"
         put "0,0,3000,3000" into someRect
         return someRect
      case "screen"
         put dot_BboxSize (the screenrect) into someRect
         return someRect
      case "image"
         put view_GetTemplateObject ("View|Image|OPN Image") into imageView
         put the rect of imageView into graphRect
         put dot_BboxSize (graphRect) into someRect
         return someRect
      default -- "none"
         if graphSize is a rect then
            put dot_BboxSize (graphSize) into someRect
            return someRect
         else
            return empty
         end if
   end switch 
end dot_RectFromSize

getprop dot_BboxSize
   put the rect of the target into someRect
   put dot_BboxSize (someRect) into targetSize
   return targetSize
end dot_BboxSize

getprop dot_InchSize [expandIfNeeded]
   put the rect of the target into someRect
   put dot_GraphInchSize (someRect, expandIfNeeded) into targetSize
   return targetSize
end dot_InchSize

getprop dot_TargetSizeLine
   put the rect of the target into graphRect
   put dot_ConvertGraphRect (graphRect, false, false) into targetSize
   return targetSize
end dot_TargetSizeLine

function dot_ConvertGraphRect someRect, expandIfNeeded, useBbox
   if useBbox is false then
      put dot_GraphInchSize (someRect, expandIfNeeded) into someRect
   else
      put dot_BboxSize (someRect) into someRect
   end if
   return someRect
end dot_ConvertGraphRect

function dot_BboxSize someRect
   put item 3 of someRect - item 1 of someRect into someWidth
   put item 4 of someRect - item 2 of someRect into someHeight
   put 0,0,someWidth,someHeight into someRect
   return someRect
end dot_BboxSize

function dot_GraphInchSize someRect, expandIfNeeded
   if someRect is empty then return empty
   put item 3 of someRect - item 1 of someRect into someWidth
   put item 4 of someRect - item 2 of someRect into someHeight
   
   put someWidth,someHeight into someSize
   dot_ConvertToInches someSize
   if expandIfNeeded is true then
      put "!" after someSize
   end if
   return someSize
end dot_GraphInchSize

on dot_ConvertToInches @pixelSize, screenRez
    -- was "dot_ConvertSizeToInches"
    if screenRez is empty then put 96 into screenRez
    set the numberformat to "0.0000"
    repeat with itemNum = 1 to the number of items of pixelSize
        put item itemNum of pixelSize into someNumber
        put someNumber / screenRez  into item itemNum of pixelSize
    end repeat
end dot_ConvertToInches

on dot_ConvertToPngPixels @xdotValue
    -- PNG is 96 dpi and xdot is at 72 dpi
    put round(xdotValue * 96 / 72) into xdotValue 
end dot_ConvertToPngPixels

function dot_ConvertDrawRect drawPoints, gHeight, @pointNum, @revRect
    -- was "graphViz_ConvertDrawRect"
    local revPoints
    if word 1 of drawPoints is "P" then
        put word 2 of drawPoints into pointNum
        put word 3 to -1 of drawPoints into drawPoints
        repeat pointNum
            put word 1 of drawPoints into nodeX
            put word 2 of drawPoints into nodeY
             
            put gHeight - nodeY into reflectedY
            
            dot_ConvertToPngPixels nodeX
            add 7 to nodeX
            dot_ConvertToPngPixels reflectedY
            add 7 to reflectedY
            put nodeX,reflectedY into reflectedLoc
            
            put reflectedLoc & CR after revPoints
            delete word 1 to 2 of drawPoints
        end repeat
    end if
    -- delete last char of revPoints
    put line 1 of revPoints after revPoints
    
    if pointNum = 4 then
        put line 2 of revPoints & "," & line 4 of revPoints into revRect
    else
        put empty into revRect
    end if
    return revPoints
end dot_ConvertDrawRect

function dot_ReflectPoint someLoc, gHeight
    -- was "graphViz_ReflectPoint"
    put item 1 of someLoc into nodeX
    put item 2 of someLoc into nodeY
    
    put gHeight - nodeY into reflectedY
    put nodeX,reflectedY into reflectedLoc
    return reflectedLoc
end dot_ReflectPoint


--> Dot | Files
-
command dot_SaveAndDisplayImage someImage, imageView, imageFile
    if imageView is empty then put view_GetTemplateObject ("View|Image|OPN Image") into imageView
    if imageFile is empty then put dot_LabelFileWithGraphStyle (graphStyle, dotFile) into imageFile
     
    file_CreateImage someImage, imageFile
    set the image_File of imageView to imageFile
    object_GoTo imageView
end dot_SaveAndDisplayImage


--> Dot | Render
-
function dot_Render dotText, pDotCommand, pTextFile, pOutputFormat
   -- pDotCommand is an english equivalent of graphStyle
   dot_SaveTemporaryFile dotText, pTextFile
   put the result into pTextFile
   put dot_DoShell (pTextFile, pDotCommand, pOutputFormat) into shellResult
   if shellResult is false or shellResult is empty then
      exit to top
   else
      return shellResult
   end if
end dot_Render

private function dot_CheckResult gvResult, outputFormat, someShell
   if outputFormat is among the items of "png,jpeg,jpg,gif" then
      set the itemdelimiter to ":"
      switch item 1 of gvResult
         case "Error"
            opn_Notify gvResult
            break
         case "Warning"
            opn_Notify (line 1 of gvResult), true
            repeat while item 1 of line 1 of gvResult is "Warning"
               delete line 1 of gvResult
            end repeat
            return gvResult
         case "Assertion failed"
            opn_Notify (line 1 of gvResult), true
            put gvResult
            return gvResult
         default
            return gvResult
      end switch
   else
      return gvResult
   end if
end dot_CheckResult


--> Dot | Node Defs
-
function dot_NodeDefFromDataArray dgArray
   repeat for each key indexNum in dgArray
      put dgArray [indexNum] into defLineArray
      put defLineArray ["id"] into nodeID
      put dot_NodeDefLineFromArray (nodeID, defLineArray) & CR after nodeDefs
   end repeat
   delete char -1 of nodeDefs
   return nodeDefs
end dot_NodeDefFromDataArray

function dot_NodeDefFromArray nodeDefArray
   repeat for each key nodeID in nodeDefArray
      put nodeDefArray [nodeID] into defLineArray
      put dot_NodeDefLineFromArray (nodeID, defLineArray) & CR after nodeDefs
   end repeat
   delete char -1 of nodeDefs
   return nodeDefs
end dot_NodeDefFromArray

function dot_NodeDefLineFromArray nodeID, defLineArray
   put nodeID && "[" into defLine
   delete local defLineArray ["id"] -- in case it is a data array with an "id" value"
   repeat for each key defProperty in defLineArray
      put defLineArray [defProperty] into defValue
      if defValue is a number then 
         put defProperty & "=" & defValue after defLine
      else
         put defProperty & "=" & kwote(defValue) after defLine
      end if
      put ", " after defLine
   end repeat
   put "];" into char -2 to -1 defLine
   return defLine
end dot_NodeDefLineFromArray

on dot_AddParamToNodeDef paramTitle, paramContent, @nodeLine, kwoted
    if paramContent is empty then return false
     
    if nodeLine is not empty then put "," & space after nodeLine
    if kwoted is not false then 
        put paramTitle & "=" & kwote(paramContent) after nodeLine
    else
        put paramTitle & "=" & paramContent after nodeLine
    end if
    return true
end dot_AddParamToNodeDef

function dot_ConstructDefLine nodeLabel, nodeShape, nodeStyle, nodeColour, nodeFillColour, polyParams, nodeUrl, nodeToolTip, nodeShapeFile
    -- was "node_ConstructParamLine"
    local nodeLine
    
    if nodeLabel is not empty then
        put "label='[[nodeLabel]]'" into nodeLine
    end if
     
    if nodeShape is not empty then
        if nodeLine is not empty then
            put "," & space after nodeLine
        end if
        put "shape=[[nodeShape]]" after nodeLine
        if nodeShape is "polygon" then
            if polyParams is not empty then
                put "," && polyParams after nodeLine
            end if
        end if
    end if
     
    dot_AddParamToNodeDef "style", nodeStyle, nodeLine, false
    dot_AddParamToNodeDef "color", nodeColour, nodeLine, false
    dot_AddParamToNodeDef "fillcolor", nodeFillColour, nodeLine, false
    dot_AddParamToNodeDef "URL", nodeUrl, nodeLine
    dot_AddParamToNodeDef "tooltip", nodeToolTip, nodeLine
    dot_AddParamToNodeDef "shapefile", nodeShapeFile, nodeLine
    
    replace "'" with quote in nodeLine
    put merge(nodeLine) into nodeLine
     
    return nodeLine
end dot_ConstructDefLine


--> Dot | Node Defs | ShapeFile
-
function dot_ConstructShapeDef someNode, nodeLabel, nodeShape, nodeFillColour, nodeUrl, nodeToolTip, nodeStyle, nodeColour
    dot_NormalizeNode someNode
    if nodeStyle is empty then put "filled" into nodeStyle
    if nodeColour is empty then put nodeFillColour into nodeColour
     
    get dot_ConstructDefLine(nodeLabel, nodeShape, nodeStyle, nodeColour, nodeFillColour, "", nodeUrl, nodeToolTip, "")
    put someNode && "[" & it & "];" into nodeDef
    put nodeDef & CR after nodeDefs
     
    delete last char of nodeDefs
    return nodeDefs
end dot_ConstructShapeDef

function dot_ConstructShapeFileDefs shapeFileArray, someWidth, someHeight, fixedSize
     -- shapefile is deprecated
  local nodeDefs
    
    put shapeFileArray ["Node titles"] into defNodes
    repeat for each line someNode in defNodes
        set the cursor to busy
        
        put shapeFileArray [someNode] into nodeShapeFile
        put shapeFileArray [someNode,"url"] into nodeUrl
        put shapeFileArray [someNode,"tooltip"] into nodeToolTip
        
        get dot_ConstructShapeFileDef(someNode, nodeShapeFile, someWidth, someHeight, fixedSize, nodeUrl, nodeToolTip)   
        put nodeDef & CR after nodeDefs
    end repeat
    delete last char of nodeDefs
    return nodeDefs
end dot_ConstructShapeFileDefs

function dot_ConstructGraphicDef nodeLabel, someWidth, someHeight, fixedSize, nodeUrl, nodeToolTip
   -- shapefile is deprecated
   put "shapeFile" into nodeShape
   put empty into polyParams
   put empty into nodeStyle
   put empty into nodeColour
   put empty into nodeFillColour
   
   get dot_ConstructDefLine(nodeName, nodeLabel, nodeShape, nodeStyle, nodeColour, nodeFillColour, polyParams, nodeUrl, nodeToolTip)
   
   if someWidth is not empty then
      dot_ConvertToInches someWidth
      put ", width=" & someWidth after it
   end if
   if someHeight is not empty then
      dot_ConvertToInches someHeight
      put ", height=" & someHeight after it
   end if
   if fixedsize is not empty then put ", fixedsize=" & fixedsize after it
   
   dot_NormalizeNode nodeName
   put nodeName && "[" & it & "];" into nodeDef
   
   return nodeDef
end dot_ConstructGraphicDef

function dot_ConstructShapeFileDef nodeName, nodeShapeFile, someWidth, someHeight, fixedSize, nodeUrl, nodeToolTip
    put "shapeFile" into nodeShape
    put empty into polyParams
    put empty into nodeStyle
    put empty into nodeColour
    put empty into nodeFillColour
    
    put " " into nodeLabel
    get dot_ConstructDefLine(nodeName, nodeLabel, nodeShape, nodeStyle, nodeColour, nodeFillColour, polyParams, nodeUrl, nodeToolTip, nodeShapeFile)
     
    if someWidth is not empty then
        dot_ConvertToInches someWidth
        put ", width=" & someWidth after it
    end if
    if someHeight is not empty then
        dot_ConvertToInches someHeight
        put ", height=" & someHeight after it
    end if
    if fixedsize is not empty then put ", fixedsize=" & fixedsize after it
    
    dot_NormalizeNode nodeName
    put nodeName && "[" & it & "];" into nodeDef
     
    return nodeDef
end dot_ConstructShapeFileDef


--> Dot | Node Defs | Poly
-
function dot_ConstructPolyDefs someNodes, polyStyle, polySkew, polyDistortion, nodeColour, nodeFillColour, nodeUrl, nodeToolTip, regular, peripheries, polyOrientation
    return "Not done yet!"
    
    local nodeDefs
    put "polygon" into nodeShape
    put empty into polyParams
    put empty into nodeShapeFile
    repeat for each line someNode in someNodes
        set the cursor to busy
        dot_NormalizeNode someNode
         
        get dot_ConstructDefLine(someNode, nodeShape, nodeStyle, nodeColour, nodeFillColour, polyParams, nodeUrl, nodeToolTip, nodeShapeFile)
        put someNode && "[" & it & "];" into nodeDef
        put nodeDef & CR after nodeDefs
    end repeat
    delete last char of nodeDefs
    return nodeDefs
end dot_ConstructPolyDefs


--> Dot | Node Defs | Defaults
-
function dot_ConstructDefaultNodeDefs nodeShape, nodeStyle, nodeColour, nodeFillColour, nodeUrl, nodeToolTip
    --   node [URL="http://wiki.architex.tv/\N", shape=box, fontsize=22, fontname=arial, style=filled];
    get dot_ConstructDefLine(empty, nodeShape, nodeStyle, nodeColour, nodeFillColour, "", nodeUrl, nodeToolTip, "")
    return "node [" & it & "];"
end dot_ConstructDefaultNodeDefs

function dot_ConstructDefaultEdgeDefs edgeColour, edgeStyle, arrowhead, edgeWidth
    --  edge [color=cyan, style=solid, arrowhead=none, width=2]
    put dot_ConstructEdgeDefParams(edgeColour, edgeStyle, arrowhead, edgeWidth) into nodeLine
    return "edge [" & nodeLine & "];"
end dot_ConstructDefaultEdgeDefs

function dot_ConstructEdgeDefParams edgeColour, edgeStyle, arrowhead, edgeWidth
    local nodeLine
    dot_AddParamToNodeDef "style", edgeStyle, nodeLine, false
    dot_AddParamToNodeDef "color", edgeColour, nodeLine, false
    dot_AddParamToNodeDef "arrowhead", arrowhead, nodeLine, false
    dot_AddParamToNodeDef "width", edgeWidth, nodeLine, false
    return nodeLine
end dot_ConstructEdgeDefParams



--> Dot | Formats
-
function dot_MakeSpringText dotFile
    -- neato /Users/david/.Trash/dot.dot -Tepdf
    shell_BashParamEscape dotFile
    put merge("neato [[dotFile]]") into someShell
    
    put graphViz_GetShellPath() into gvPath
    put gvPath & someShell into someShell
    return shell(someShell)
end dot_MakeSpringText


--> Dot | Draw
-
function dot_MakeSpringImage dotFile
    -- neato /Users/david/.Trash/dot.dot -Tepdf
    shell_BashParamEscape dotFile
    put merge("neato -Tpng [[dotFile]]") into someShell
    
    put graphViz_GetShellPath() into gvPath
    put gvPath & someShell into someShell
    return shell(someShell)
end dot_MakeSpringImage

function dot_MakeCircular dotFile
    /*
    circodraws graphs using a circular layout (see Six and Tollis, GD ’99 and ALENEX ’99, and Kaufmann 
    and Wiese, GD ’02.) The tool identifies biconnected components and draws the nodes of the component on 
    acircle. The block-cutpoint tree is then laid out using a recursive radial algorithm. Edge crossings within a 
    circle are minimized by placing as manyedges on the circle’sperimeter as possible. In particular, if the 
    component is outerplanar,the component will have a planar layout. 
    If a node belongs to multiple non-trivial biconnected components, the layout puts the node in one of them. 
    By default, this is the first non-trivial component found in the search from the root component. 
    
    circo ["Gname=value] ["Nname=value]["Ename=value]["Tlang]["llibfile]["ooutfile]["vV][files] 
    */
    
    shell_BashParamEscape dotFile
    put merge("circo -Tpng [[dotFile]]") into someShell
    
    put graphViz_GetShellPath() into gvPath
    put gvPath & someShell into someShell
    return shell(someShell)
end dot_MakeCircular

function dot_MakeRadial dotFile
   /*
   draws graphs using a radial layout. 
   Basically, one node is chosen as the center and put at the origin. 
   The remaining nodes are placed on a sequence of concentric circles centered about the origin, 
   each a fixed radial distance from the previous circle.
   */
   
   -- twopi /Users/david/.Trash/dot.dot -Tepdf
   shell_BashParamEscape dotFile
   put merge("twopi [[dotFile]] -Tepdf") into someShell
   
   put graphViz_GetShellPath() into gvPath
   put gvPath & someShell into someShell
   return shell(someShell)
end dot_MakeRadial

function dot_MakeRadialImage dotFile
    -- twopi /Users/david/.Trash/dot.dot -Tepdf
    shell_BashParamEscape dotFile
    put merge("twopi [[dotFile]] -Tpng") into someShell
    
    put graphViz_GetShellPath() into gvPath
    put gvPath & someShell into someShell
    put shell(someShell) into gvResult
    return dot_CheckResult(gvResult)
end dot_MakeRadialImage



--> Dot | Shell
-
command dot_DoImageMapShell dotCommand, dotFile, imageFile, pCmapFile, pXdotFile, pImageFormat
   -- dot foo.gv -Tpng -o foo.png -Tcmapx -o foo.cmapx
   dot_NormalizeDotCommand dotCommand -- converts a graphStyle to a dotCommand
   if pImageFormat is empty then put "png" into pImageFormat
   put graphViz_GetShellPath() into gvPath
   
   shell_BashParamEscape dotFile
   shell_BashParamEscape imageFile
   shell_BashParamEscape pCmapFile
   shell_BashParamEscape pXdotFile
   
   put gvPath & dotCommand into someShell
   -- put space & quote & dotFile & quote after someShell
   put space & dotFile after someShell
   
   put space & "-T" & pImageFormat after someShell
   -- put space & "-o" && quote & imageFile & quote after someShell
   put space & "-o" && imageFile after someShell
   
   if pCmapFile is not empty then
      put space & "-Tcmapx" after someShell
      -- put space & "-o" && quote & pCmapFile & quote after someShell
      put space & "-o" && pCmapFile after someShell
   end if
   
   if pXdotFile is not empty then
      put space & "-Txdot" after someShell
      -- put space & "-o" && quote & pXdotFile & quote after someShell
      put space & "-o" && pXdotFile after someShell
   end if
   
   put shell (someShell) into gvResult
   put dot_CheckResult (gvResult, "png", someShell) into shellResult
   return shellResult
end dot_DoImageMapShell
  
function dot_DoShell imageFile, pDotCommand, pImageFormat
   dot_NormalizeDotCommand pDotCommand
   if pImageFormat is empty then put "png" into pImageFormat
   put graphViz_GetShellPath() into gvPath
   
   put gvPath & pDotCommand into someShell
   put space & "-T" & pImageFormat after someShell
   put space & quote & imageFile & quote after someShell
   
   put shell(someShell) into gvResult
   put dot_CheckResult(gvResult, "png", someShell) into shellResult
   return shellResult
end dot_DoShell

-- function dot_DoShell someFile, pDotCommand, pOutputFormat
   dot_NormalizeDotCommand pDotCommand
   if pImageFormat is empty then put "png" into pImageFormat
   put graphViz_GetShellPath() into gvPath
   
   put gvPath & pDotCommand into someShell
   if pOutputFormat is not empty then put space & "-T" & pOutputFormat after someShell
   put space & quote & someFile & quote after someShell
   
   put shell(someShell) into gvResult
   put dot_CheckResult(gvResult, "png", someShell) into shellResult
   return shellResult
end dot_DoShell

function graphViz_GetShellPath
   put pref_GetValue ("dotPath") into dotPath
   return dotPath
   
   return "/opt/local/bin/"
   return "/Applications/Graphviz.app" & "/Contents/MacOS/" into graphVizShellPath
end graphViz_GetShellPath

on graphViz_SetShellPath dotPath
   pref_SetValue "dotPath", dotPath
end graphViz_SetShellPath


--> Dot | Shell | Text
-
function graphViz_CreateCmapx dotText
    -- dot foo.dot -Nhref=\\N -Tcmpax -o foo.map -Tpng -o foo.png
    file_CreateText dotText
    put the result into someFile
     
    put graphViz_GetShellPath() into gvPath
    put gvPath & "dot -Nhref=\\N -Tcmapx" && quote & someFile & quote into someShell
    get shell(someShell)
    return it
end graphViz_CreateCmapx


--> Dot | Shell | Other
-
function dot_StripLeastConected dotFile, minConnected
    if minConnected is empty then put 1 into minConnected
    shell_BashParamEscape dotFile
    
    put merge("gvpr -i 'N[$.degree > [[minConnected]]]'") && dotFile into someShell
    
    put graphViz_GetShellPath() into gvPath
    put gvPath & someShell into someShell
    return shell(someShell)
end dot_StripLeastConected

function dot_ExtractConnected dotFile
    shell_BashParamEscape dotFile
    put merge("sccmap -d [[dotFile]]") into someShell
    
    put graphViz_GetShellPath() into gvPath
    put gvPath & someShell into someShell
    return shell(someShell)
end dot_ExtractConnected

function dot_Biconected dotFile
   /*
   decomposes graphs into their biconnected components, printing the components to standard output. 
   */
   
   shell_BashParamEscape dotFile
   put merge("bcomps [[dotFile]]") into someShell
   
   put graphViz_GetShellPath() into gvPath
   put gvPath & someShell into someShell
   return shell(someShell)
end dot_Biconected

function dot_Tred dotFile
   /*
   Computes the transitive reduction of directed graphs, and prints the resulting graphs to standard output. 
   This removes edges implied by transitivity. Nodes and subgraphs are not otherwise affected. 
   The “meaning” and validity of the reduced graphs is application dependent. 
   tred is particularly useful as a preprocessor to dot to reduce clutter in dense layouts. 
   */
    shell_BashParamEscape dotFile
    put merge("tred [[dotFile]]") into someShell
    
    put graphViz_GetShellPath() into gvPath
    put gvPath & someShell into someShell
    return shell(someShell)
end dot_Tred

function dot_UnFlatten dotFile, someNum
   -- unflatten[?f][?llen][?clen][?ooutfile][files ] 
   
   put url ("file:" & dotFile) into dotText
   shell_BashParamEscape dotFile
   if someNum is empty then put 12 into someNum
   put merge("unflatten -f -l [[someNum]] -c [[someNum]] [[dotFile]]") into someShell
   
   put graphViz_GetShellPath() into gvPath
   put gvPath & someShell into someShell
   
   put shell(someShell) into gvResult
   return gvResult
   put dot_CheckResult(gvResult, "png", someShell) into shellResult
   return shellResult
end dot_UnFlatten

function dot_MakeAcyclic dotFile
    /*
    acyclicis a filter that takes a directed graph as input and outputs a copyofthe graph with sufficient edges 
    reversed to makethe graph acyclic. The reversed edge inherits all of the attributes of the original edge. The 
    optional file argument specifies where the the input graph is stored; by default, the program reads from 
    stdin. 
    */
    -- acyclic[?nv? ][?ooutfile][ file]
    shell_BashParamEscape dotFile
    put merge("acyclic [[dotFile]]") into someShell
    
    put graphViz_GetShellPath() into gvPath
    put gvPath & someShell into someShell
    return shell(someShell)
end dot_MakeAcyclic

function dot_AcyclicInfo dotFile, acyclicFile
    shell_BashParamEscape dotFile
    shell_BashParamEscape acyclicFile
    put merge("acyclic -v -o [[acyclicFile]] [[dotFile]]") into someShell
    
    put graphViz_GetShellPath() into gvPath
    put gvPath & someShell into someShell
    return shell(someShell)
end dot_AcyclicInfo


--> Dot | Colours
-
function dot_RGBToHex rgbColour
    -- was "graphViz_RGBToHex"
    if rgbColour is empty or rgbColour is "none" then
        return empty
    else if rgbColour is among the lines of the colornames then
        return rgbColour
    else
        put quote & colour_RgbToHex (rgbColour) & quote into webColour
        return webColour
    end if
end dot_RGBToHex
  
function dot_ConvertRevShape revShape, pSides
    -- was "graphViz_ConvertRevShape"
    if revShape is empty then
        return "ellipse"
    else if revShape is "regular" then
        switch pSides
            case 3
                return "triangle"
            case 4
                return "rectangle"
            case 5
                return "pentagon"
            case 6
                return "hexagon"
        end switch
    else if revShape is "oval" then
        return "ellipse"
    else
        return revShape
    end if
end dot_ConvertRevShape


--> Dot | Utilities
-
on dot_EscapeQuotes @someLabel
    replace quote with ("\" & quote) in someLabel
end dot_EscapeQuotes

function dot_QuoteNode someNodeID
    -- comma's and other chars can also result in badly named nodes.
    if the number of words of someNodeID > 1 or char 1 of someNodeID is a number then
        return kwote(someNodeID)
    else
        return someNodeID
    end if
end dot_QuoteNode

