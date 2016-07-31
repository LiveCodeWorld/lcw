script "behavior_ViewImageSVG"
--> MetaData
-
license: GPLv3
name: behavior_ViewImageSVG
type: view behavior
version: 0.3


/*
The idea here is to experiment with layered behaviors.
That is instead of using if-then logic to switch the behavior of a layout,
we simply add or remove a behavior.

The scripts below are just work in progress for now.
*/

local LocalArray


--> Events
-
on browserNavigateBegin clickedURL
   -- "http://libbrowser_dummy_url/list_ImageFileIDs%2Cc%2Cstack+%22behavior_ServerScriptContainer%22%2C1"
   set the itemdelimiter to slash
   put item -1 of clickedURL into urlEncodedHKey
   put urldecode (urlEncodedHKey) into hKey
   
   hKey_Edit hKey
end browserNavigateBegin

-- on browserFrameDocumentLoadBegin
   put the params
end browserFrameDocumentLoadBegin


--> Work in Progress
-
getprop displayed_Object
   put the displayed_Hkey of me into hKey
   put item 3 of hKey into hObject
   return hObject
end displayed_Object

setprop displayed_Object hObject
   put hObject into item 3 of LocalArray ["hKey"]
end displayed_Object

-- getprop displayed_Hkey
   put LocalArray ["hKey"] into hKey
   return hKey
end displayed_Hkey

setprop displayed_Hkey hKey
   put hKey into LocalArray ["hKey"]
end displayed_Hkey

getprop svg_Scale
   put the htmltext of me into someHTML
   
   set the wholematches to false
   put "<g transform=" into tagBit
   put lineOffset (tagBit, someHTML) into lineNum
   
   -- "<g transform='scale([[svgScale]])'>"
   put line lineNum of someHTML into firstLine
   replace quote with "'" in firstLine
   put token 7 of firstLine into svgScale
   
   return svgScale
end svg_Scale

setprop svg_Scale svgScale   
   put the svg_XML of me into svgXML
   -- "<g transform='scale([[svgScale]])'>"
   set the wholematches to false
   put "<g transform=" & quote & "scale(" & svgScale & ")" & quote & ">" into startTag
   put lineOffset ("<g id=", svgXML) into startLineNum
   put startTag & CR before line startLineNum of svgXML
   
   put "</g>" into endTag
   put lineOffset ("</svg>", svgXML) into endLineNum
   put endTag & CR before line endLineNum of svgXML
   --
   set the svg_XML of me to svgXML
end svg_Scale

setprop svg_Scale svgScale
   put the htmltext of me into someHTML
   
   set the wholematches to false
   put "<g transform=" into tagBit
   put lineOffset (tagBit, someHTML) into lineNum
   
   switch
      case lineNum is 0 and svgScale is empty
         -- it's not there and we are trying to delete it
         -- do nothing
         break
      case lineNum is 0 and svgScale is not empty
         -- it's no there and we are trying to add a scale
         
         break
      case svgScale is empty
         delete line lineNum of someHTML
         
         -- now delete the end tag
         
         break
      default
         -- scale is already present and we have a new value to set
         put merge ("<g transform='scale(svgScale)'>") into startTag
         put startTag into line lineNum of someHTML
   end switch
   
   set the htmltext of me to someHTML
end svg_Scale




--> SVG | Props
-
getprop svg_File
   put LocalArray ["svg_URL"] into svgURL
   if char 1 to 5 of svgURL is not "file:" then return empty
   
   delete char 1 to 5 of svgURL
   return svgURL
end svg_File

setprop svg_File [isFluid] svgPath
   put "file:" & svgPath into svgURL
   put url svgURL into svgXML
   if isFluid is true then
      svg_SetDimensions svgXML, "100%", "100%"
   end if
   
   put svgPath into svgTitle
   put svg_GetHTMLTemplate() into htmlTemplate
   put merge (htmlTemplate) into someHtml
   
   set the htmltext of me to someHtml
   put svgURL into LocalArray ["svg_URL"]
   return someHtml
end svg_File

getprop svg_URL svgURL
   return LocalArray ["svg_URL"]
end svg_URL

setprop svg_URL [isFluid] svgURL
   put url svgURL into someHTML
   put svg_Get (someHTML) into svgXML
   if isFluid is true then
      svg_SetDimensions svgXML, "100%", "100%"
   end if
   
   put svgURL into svgTitle
   put svg_GetHTMLTemplate() into htmlTemplate
   put merge (htmlTemplate) into someHtml
   
   set the htmltext of me to someHtml
   put svgURL into LocalArray ["svg_URL"]
   return someHtml
end svg_URL

getprop svg_IsFluid
   put the svg_Dimensions of me into myDimensions
   return myDimensions = "100%,100%"
end svg_IsFluid

setprop svg_IsFluid someBoolean
   if someBoolean is true then
      set the svg_Dimensions of me to "100%,100%"
   else
      put the svg_ViewBoxDimensions of me into originalDimensions
      set the svg_Dimensions of me to originalDimensions
   end if
end svg_IsFluid

getprop svg_Width
   put the svg_HeaderArray of me into svgHeaderArray
   put svgHeaderArray ["width"] into svgWidth
   return svgWidth
end svg_Width

setprop svg_Width someWidth
   put svg_CreateXmlTree() into treeID
   revXMLSetAttribute treeID, "/svg","width", someWidth
   put revXMLText (treeID, empty, true) into newSvgXML
   svg_DeleteXmlTree
   delete line 1 of newSvgXML -- the xml header
   put word 1 to -1 of newSvgXML into newSvgXML
   
   set the svg_XML of me to newSvgXML
   return newSvgXML
end svg_Width

getprop svg_Height
   put the svg_HeaderArray of me into svgHeaderArray
   put svgHeaderArray ["height"] into svgHeight
   return svgHeight
end svg_Height

setprop svg_Height svgHeight
   svg_DeleteXmlTree
   put svg_CreateXmlTree() into treeID
   revXMLSetAttribute treeID, "/svg","height", svgHeight
   put revXMLText (treeID, empty, true) into newSvgXML
   svg_DeleteXmlTree
   delete line 1 of newSvgXML -- the xml header
   put word 1 to -1 of newSvgXML into newSvgXML
   
   set the svg_XML of me to newSvgXML
   return newSvgXML
end svg_Height

getprop svg_Header
   -- a hack which asumes the header is on a single line
   put the svg_XML of me into svgXML
   put line 1 of svgXML into svgHeader
   return svgHeader
end svg_Header

setprop svg_Header svgHeader
   -- a hack which asumes the header is on a single line
   put the svg_XML of me into svgXML
   put svgHeader into line 1 of svgXML
   set the svg_XML of me to svgXML
   return svgXML
end svg_Header

getprop svg_HeaderTable
   put svg_CreateXmlTree() into treeID
   put revXMLAttributes (treeID, "/svg", tab, CR) into attributeTable
   svg_DeleteXmlTree
   return attributeTable
end svg_HeaderTable

getprop svg_ViewBoxDimensions
   put the svg_ViewBox of me into svgViewBox
   put word 3 of svgViewBox - word 1 of svgViewBox into originalWidth
   put word 4 of svgViewBox - word 2of svgViewBox into originalHeight
   return originalWidth,originalHeight
end svg_ViewBoxDimensions

getprop svg_ViewBox
   put the svg_HeaderArray of me into svgHeaderArray
   put svgHeaderArray ["viewBox"] into svgViewBox
   return svgViewBox
end svg_ViewBox

getprop svg_HeaderArray
   put the svg_HeaderAttributes of me into attributeTable
   split attributeTable with CR and tab
   return attributeTable
end svg_HeaderArray

setprop svg_HeaderArray svgHeaderArray
   -- combine svgHeaderArray with space and "=" -- does not quote the attributes
   put "<svg" & space into newSvgHeader
   repeat for each key attributeName in svgHeaderArray
      put svgHeaderArray [attributeName] into attributeValue
      put attributeName & "=" & quote & attributeValue & quote & space after newSvgHeader
   end repeat
   delete char -1 of newSvgHeader
   put ">" after newSvgHeader

   set the svg_Header of me to newSvgHeader
   put the result into svgXML
   return svgXML
end svg_HeaderArray

getprop svg_HeaderAttributes
   put svg_CreateXmlTree() into treeID
   put revXMLAttributes (treeID, "/svg", tab, CR) into attributeTable
   svg_DeleteXmlTree
   return attributeTable
end svg_HeaderAttributes

getprop svg_Dimensions
   put the svg_HeaderArray of me into svgHeaderArray
   put svgHeaderArray ["width"] into svgWidth
   put svgHeaderArray ["height"] into svgHeight
   return svgWidth,svgHeight
end svg_Dimensions

setprop svg_Dimensions svgDimensions
   put item 1 of svgDimensions into svgWidth
   put item 2 of svgDimensions into svgHeight
   
   put the svg_XML of me into svgXML
   svg_SetDimensions svgXML, svgWidth, svgHeight
   
   /*
   put svg_CreateXmlTree() into treeID
   revXMLSetAttribute treeID, "/svg","width", svgWidth
   revXMLSetAttribute treeID, "/svg","height", svgHeight
   put revXMLText (treeID, empty, true) into newSvgXML
   svg_DeleteXmlTree
   delete line 1 of newSvgXML -- the xml header
   put word 1 to -1 of newSvgXML into svgXML
   */
   
   set the svg_XML of me to svgXML
   return svgXML
end svg_Dimensions

getprop svg_XML
   put the htmltext of me into someHTML
   put svg_Get (someHTML) into svgXML
   return svgXML
end svg_XML

setprop svg_XML svgXML
   put the htmltext of me into someHTML
   svg_Set someHTML, svgXML
   set the htmltext of me to someHTML
end svg_XML


getprop view_Object
   return the long id of me
end view_Object


--> SVG
-
function svg_Get someHTML
   local startChar, endChar
   text_SetOffsets "<svg ", "</svg>", someHTML, startChar, endChar
   put the result into svgXML
   return svgXML
   
   -- brain dead but brittle way
   set the wholematches to false
   put lineOffset ("<svg ", someHTML) into startNum
   put lineOffset ("</svg>", someHTML) into endNum
   put line startNum to endNum of someHTML into svgXML
   return word 1 to -1 of svgXML
end svg_Get

command svg_Set @someHTML, newSvgXml
   local startChar, endChar
   text_SetOffsets "<svg ", "</svg>", someHTML, startChar, endChar
   put the result into oldSvgXML
   put newSvgXml into char startChar to endChar of someHTML
   return oldSvgXML
end svg_Set

command svg_SetDimensions @svgXML, svgWidth, svgHeight
   put svg_CreateXmlTree (svgXML) into treeID
   revXMLSetAttribute treeID, "/svg","width", svgWidth
   revXMLSetAttribute treeID, "/svg","height", svgHeight
   put revXMLText (treeID, empty, true) into svgXML
   svg_DeleteXmlTree
   
   delete line 1 of svgXML -- the xml header
   put word 1 to -1 of svgXML into svgXML
end svg_SetDimensions

private function svg_CreateXmlTree pSvgXML
   if pSvgXML is empty then
      put the svg_XML of me into pSvgXML -- in case we have other HTML displayed
   end if
   put true into pGoodXML
   put revCreateXMLTree (pSvgXML, pGoodXML, true, false) into svgXmlTreeID
   put svgXmlTreeID into LocalArray ["svgXmlTreeID"]
   return svgXmlTreeID
end svg_CreateXmlTree

private command svg_DeleteXmlTree
   put LocalArray ["svgXmlTreeID"] into svgXmlTreeID
   if svgXmlTreeID is not a number then return svgXmlTreeID
   revDeleteXMLTree svgXmlTreeID
   delete variable LocalArray ["svgXmlTreeID"]
   return svgXmlTreeID
end svg_DeleteXmlTree

command text_SetOffsets startText, endText, someText, @startChar, @endChar, pStartAfterCharNum
   if pStartAfterCharNum is a number then   
      delete char 1 to pStartAfterCharNum of someText
   end if
   
   put offset (startText, someText) into startChar
   if startChar is 0 then
      put 0 into startChar
      put 0 into endChar
      return empty
   end if
   put the length of startText - 1 into startBit
   if endText = empty then
      put startChar + startBit into endChar
   else
      put text_OffsetAfter (endText, someText, startChar + startBit) into endChar
      if endChar is 0 then
         put 0 into startChar
         put 0 into endChar
         return empty
      end if
      add the length of endText - 1 to endChar
   end if
   
   add startAfterCharNum to startChar
   add startAfterCharNum to endChar
   return char startChar to endChar of someText
end text_SetOffsets

command old_ExtractDimensions svgXML, @svgWidth, @svgHeight, @lineNum
   -- <svg width="880pt" height="480pt"  
   set the wholematches to false
   put lineOffset ("<svg ", svgXML) into lineNum
   put line lineNum of svgXML into firstLine
   put "<svg width=\'(.+)pt\' height=\'(.+)pt\'" into someReg
   replace "'" with quote in someReg
   get matchText (firstLine, someReg, svgWidth, svgHeight)
end old_ExtractDimensions

command old_SetDimensions @svgXML, svgWidth, svgHeight
   -- <svg width="880pt" height="480pt"  
   set the wholematches to false
   put lineOffset ("<svg ", svgXML) into lineNum
   put line lineNum of svgXML into firstLine
   put "<svg width=\'(.+)pt\' height=\'(.+)pt\'" into someReg
   replace "'" with quote in someReg
   get matchChunk (firstLine, someReg, sWidth, eWidth, sHeight, eHeight)
   
   put char sWidth to eWidth of line lineNum of svgXML into oldWidth
   put char sHeight to eHeight of line lineNum of svgXML into oldHeight
   
   put svgWidth into char sWidth to eWidth of line lineNum of svgXML
   put svgHeight into char sHeight to eHeight of line lineNum of svgXML
   return oldWidth,oldHeight
end old_SetDimensions


--> SVG | Templates
-
function svg_GetHTMLTemplate
   /*
   <!DOCTYPE html>
   <html>
   <head>
   <title>[[svgTitle]]</title>
   </head>
   <body>
   [[svgXML]]
   </body>
   </html>
   */
   -- put script_GetCommentAboveMe() into htmlTemplate
   put "<!DOCTYPE html><html><head><title>[[svgTitle]]</title></head><body>[[svgXML]]</body></html>" into htmlTemplate
   return htmlTemplate
end svg_GetHTMLTemplate
