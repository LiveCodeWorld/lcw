script "lib_RevXmlDoc"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_RevXmlDoc
type: library
version: 0.1

/*Some help*/


--> Working on
-
function revXmlDoc_ListTerms scriptDictionaryArray
   local dictionaryTerms, dicArray
   revXmlDoc_Parse scriptDictionaryArray, dictionaryTerms, dicArray
   return dictionaryTerms
end revXmlDoc_ListTerms


--> RevXmlDoc
-
function revXmlDoc_ToArray theXML
   -- based on code from BVG Docu
   if char 1 to 5 of word 1 of theXML = "<doc>" then
      put "<?xml version=" & quote & "1.0" & quote & "?>" before theXML
   else if char 1 to 5 of word 1 of theXML <> "<?xml" then
      return "I couldn't understand the file you referenced:" & return & thePath
   end if
   --If you wonder what the hell I did right after this comment, then try this: put the cDictDTD of stack "revDocs"
   --note: as of 3.5 that stack does not exist in the ide, instead it's "revDocumentationLibrary"
   put the DTD of card 1 of this stack after char offset(">",theXML) of theXML
   
   put revXMLCreateTree(theXML,true,true,false) into theID
   replace "><" with ">" & return & "<" in theXML
   set the XMLtext of this stack to theXML
   if theID is not a number then
      return "revXML made a booboo:" & return & theID
   end if
   if revXMLRootNode(theID) is not "doc" then
      return "This is XML, but not the kind I Expected:" & revXMLRootNode(theID)
   end if
   
   put _DocCleanup(revxmltext(theID, "doc/name"),false, "name") into content["name"]
   if content["name"] contains "&gt;" or content["name"] contains "&lt;" then --xml doesn't like < and >
      replace "&gt;" with ">" in content["name"]
      replace "&lt;" with "<" in content["name"]
   else if content["name"] contains "&amp;" then
      replace "&amp;" with "&" in content["name"]
   end if
   put _DocCleanup(revxmltext(theID, "doc/type"),false, "type") into content["type"]
   --put "<p>" & _DocCleanup(revxmltext(theID, "doc/syntax"),false, "syntax") & "</p>" into content["syntax"]
   put _DocCleanup(revxmltext(theID, "doc/syntax"),false, "syntax") into content["syntax"]
   replace "</p><p>" with return in content["syntax"]
   replace "<p>" with empty in content["syntax"]
   replace "</p>" with empty in content["syntax"]
   put word 1 to -1 of content["syntax"] into content["syntax"]
   replace return with "</p><p>" in content["syntax"]
   if char 1 to 3 of content["syntax"] <> "<p>" and content["syntax"] <> "" then
      put "<p>" & content["syntax"] & "</p>" into content["syntax"]
   end if
   put _DocCleanup(revxmlchildcontents(theID, "doc/synonyms",comma,return, false, 1),true) into content["synonyms"]
   put _DocCleanup(revxmlchildcontents(theID, "doc/objects",comma,return, false, 1),true) into content["objects"]
   put _DocCleanup(revxmlchildcontents(theID, "doc/categories",comma,return, false, 1)) into temp
   repeat for each line theLine in temp
      put item 2 to -1 theLine & return after content["categories"]
   end repeat
   delete char -1 of content["categories"]
   set the itemdelimiter to "/"
   put 0 into x
   repeat for revXMLnumberofChildren(theID, "doc/related",,1) times
      add one to x
      if item 1 of revXMLattribute(theID, "doc/related/docRef[" & x & "]","src") = "Dictionary" then
         put revXMLnodecontents(theID, "doc/related/docRef[" & x & "]") after content["related"]
         if word -2 to -1 of line -1 of content["related"] = "control structure" then
            put word 1 to -3 of line -1 of content["related"] & tab & word -2 to -1 of line -1 of content["related"] & return into line -1 of content["related"]
         else
            put word 1 to -2 of line -1 of content["related"] & tab & word -1 of line -1 of content["related"] & return into line -1 of content["related"]
         end if
      end if
   end repeat
   delete char -1 of content["related"]
   set the itemdelimiter to comma
   put _DocCleanup(revXMLattribute(theID, "doc/introduced","version")) into content["introduced"]
   put _DocCleanup(revXMLattribute(theID, "doc/changed","version")) into content["changed"]
   put _DocCleanup(revXMLattribute(theID, "doc/removed","version")) into content["removed"]
   put _DocCleanup(revXMLattribute(theID, "doc/osx","support")) into content["osx"]
   put _DocCleanup(revXMLattribute(theID, "doc/macos","support")) into content["macos"]
   put _DocCleanup(revXMLattribute(theID, "doc/win32","support")) into content["win32"]
   put _DocCleanup(revXMLattribute(theID, "doc/unix","support")) into content["unix"]
   put _DocCleanup(revxmltext(theID, "doc/summary"),false, "summary") into content["summary"]
   put _DocCleanup(revxmltext(theID, "doc/example"),false, "example") into content["example"]
   put _DocCleanup(revxmltext(theID, "doc/description"),false, "description") into content["description"]
   
   revXMLDeleteTree theID
   return content
end revXmlDoc_ToArray


--> Rev | Dictionary | Styles
-
function rev_DictionaryStyleArray
   put the customproperties ["cStyles"] of revDocumentationStack() into someArray
   return someArray
end rev_DictionaryStyleArray

function rev_FormatXMLFontFace pTag
   -- Given a tag name, returns the font that the contents of this
   -- tag should be displayed in.
   local tFace
   put item 1 of the cStyles[pTag] of revDocumentationStack() into tFace
   if tFace is "default" then return empty
   return tFace
end rev_FormatXMLFontFace

function rev_FormatXMLFontSize pTag
   -- Given a tag name, returns the size that the contents of this 
   -- tag should be displayed in.
   local tSize
   put item 2 of the cStyles[pTag] of revDocumentationStack() into tSize
   if tSize is "default" then return empty
   return tSize
end rev_FormatXMLFontSize

function rev_FormatXMLFontColor pTag
   -- Given a tag name, returns the color that the contents of this tag
   -- should be displayed in.
   local tColor
   put item 3 of the cStyles[pTag] of revDocumentationStack() into tColor
   if tColor is "default" then return empty
   return tColor
end rev_FormatXMLFontColor

-- Given a tag name, returns the style that the contents of this
-- tag should be displayed in.
function rev_FormatXMLFontStyle pTag
  local tStyle
  put item 4 to -1 of the cStyles[pTag] of revDocumentationStack() into tStyle
  if tStyle is default then return empty
  return tStyle
end rev_FormatXMLFontStyle


--> Private
-
private function _DocCleanup theStuff needsP tagToRemove
   -- from BVG
   if char 1 to 6 of theStuff  = "xmlerr" then
      return ""
   end if
   if tagToRemove <>  "" then
      replace "<" & tagToRemove & ">" with "" in theStuff
      replace "</" & tagToRemove & ">" with "" in theStuff
      replace "<" & tagToRemove & "/>" with "" in theStuff
   end if
   if theStuff contains "<docRef" then
      set the itemdelimiter to "<"
      set the linedelimiter to ">"
      put "" into temp
      put false into theSkip
      repeat for each line theLine in theStuff
         --add your own glossary handling in the next if statement
         if item -1 of theLine contains "src=" & quote & "glossary/" or item -1 of theLine contains "src=" & quote & "../glossary/" or item -1 of theLine contains "src=" & quote & "reference/" then
            put item 1 to -2 of theLine after temp
            put true into theSkip
         else if item -1 of theLine contains "src=" & quote & "dictionary/" then
            put item 1 to -2 of theLine after temp
            set the itemdelimiter to "/"
            put "<docRef src=" & quote & item -1 of theLine & ">" after temp
            set the itemdelimiter to "<"
         else
            if theSkip and item -1 of theLine = "/docRef" then
               put item 1 to -2 of theLine after temp
               put false into theSkip
            else
               put theLine & ">" after temp
            end if
         end if
      end repeat
      put temp into theStuff
      replace "<docRef src=" with "<a href=" in theStuff
      replace "</docRef>" with "</a>" in theStuff
      set the itemdelimiter to comma
      set the linedelimiter to return
   end if
   if needsP then
      put "" into temp
      repeat for each line theLine in theStuff
         put "<p>" & item 2 of theLine & "</p>" & return after temp
      end repeat
      put char 1 to -2 of temp into theStuff
   end if
   replace "<p/>" with "<p></p>" in theStuff
   return theStuff
end _DocCleanup


--> Deps
-
