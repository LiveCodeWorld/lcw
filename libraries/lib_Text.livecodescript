﻿script "lib_Text"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Text
type: library
version: 0.9

/*
Basic library of utilities for working with text, lines and indexes.
Currently refactoring as many handlers are very old and predate the introduction of arrays to the language.
Beginning to rename handlers that deal with indexes in a modern way to "index_XXX"
*/


--> Index
-
command index_SetUnique @someIndex, pCaseSensitive
   if pCaseSensitive is false then
      split someIndex by CR and tab
      put the keys of someIndex into uniqueIndex
      put word 1 to -1 of uniqueIndex into someIndex
   else
      repeat for each line someLine in someIndex
         put word 1 to -1 of someLine into someLine
         if someLine is empty then next repeat
         put empty into indexArray [someLine]
      end repeat
      put keys (indexArray) into someIndex
   end if
end index_SetUnique

function index_CheckSameItems index1, index2
   sort lines of index1
   sort lines of index2
   put word 1 to -1 of index1 into index1
   put word 1 to -1 of index2 into index2
   return index1 = index2
end index_CheckSameItems

command index_Filter @someIndex, filterItems
   put index_GetSortedAndFiltered (someIndex, filterItems) into someIndex
end index_Filter

function index_GetSortedAndFiltered someIndex, pFilterItems
   local filteredIndex
   if pFilterItems is empty then return someIndex
   --
   repeat for each item fItem in pFilterItems
      put someIndex into fIndex
      if fItem contains "*" is false then
         put "*" & fItem & "*" into fItem
      end if 
      filter fIndex with fItem
      split fIndex by CR as set
      union filteredIndex with fIndex
   end repeat
   put the keys of filteredIndex into sortedAndFiltered
   sort lines of sortedAndFiltered
   return sortedAndFiltered
end index_GetSortedAndFiltered


--> Working on
-
command text_StripSurroundingQuotes @someText
   -- put token 1 of someText into someText -- does not work with single quotes
   
   get word 1 to -1 of someText
   put quote & "'" into quoteChars
   if char 1 of it is among the chars of quoteChars and char -1 of it is among the chars of quoteChars then
      delete char 1 of someText
      delete char -1 of someText
   end if
   return it = someText
end text_StripSurroundingQuotes

function text_ReplaceWord sString, sWord, newWord
   put "\" & sWord & "\b" into matchExp
   put replaceText (sString, matchExp, newWord) into newString
   return newString
end text_ReplaceWord

command text_PrettyQuote @someText, pParamArray
   if pParamArray is an array then
      put text_Merge (someText, pParamArray) into someText
   end if
   replace "'" with quote in someText
end text_PrettyQuote

function text_Merge mergeText, paramArray
   repeat for each key someKey in paramArray
      put paramArray [someKey] into someValue
      put "put someValue into" && someKey into doScript
      do doScript
   end repeat
   put merge (mergeText) into translatedText
   return translatedText
end text_Merge


--> Text | Hash
-
function sha1_Hash someData
   local hexDigest
   put sha1digest (someData) into someBinaryData
   get binarydecode ("H*", someBinaryData, hexDigest)
   return hexDigest
end sha1_Hash

function md5_Hash someText
   local hexDigest
   put md5digest (someText) into someBinaryData
   get binarydecode ("H*", someBinaryData, hexDigest)
   return hexDigest
end md5_Hash


--> Text
-
function text_Hash someData, pWhichDigest
   if pWhichDigest = "sha1" then
      return sha1_Hash (someData)
   else
      return md5_Hash (someData)
   end if
end text_Hash

command text_StripReg @wikiText, someReg, pReplaceText
   if matchText (someReg, "\(.*\)") is false then
      -- someReg requires "()" in order to return sNum, eNum
      put "(" & word 1 to -1 of someReg & ")" into someReg
   end if
   
   local refStart, refEnd
   put 0 into indexNum
   repeat
      get matchchunk (wikiText, someReg, sNum, eNum)
      if it is false then exit repeat
      if sNum is not a number then exit repeat -- should not happen (see above)
      
      -- this bit not needed (remove for speed)
      put sNum into stripResultArray [indexNum]["sNum"]
      put eNum into stripResultArray [indexNum]["eNum"]
      add 1 to indexNum
      --
      put pReplaceText into char sNum to eNum of wikiText
   end repeat
   return stripResultArray
end text_StripReg

function text_IsCaps someText
   put "^[^a-z]*$" into someReg
   -- put "\b[A-Z]+\b" into someReg
   get matchtext (word 1 to -1 of someText, someReg)
   return it 
   
   repeat for each char testChar in someText
      put chartonum (testChar) into someCharNum
      if someCharNum >= 65 and someCharNum <= 90 then
         return false
      end if
   end repeat
   return true
end text_IsCaps

function text_GetMergeVars mergeText
   -- put text_GetBetween ("[[", "]]", someText, startAfterCharNum)
   put "\[\[" into someReg
   put "[^\]]*" into notaSquareClosingBracket
   put "(" & notaSquareClosingBracket & ")" after someReg
   put "\]\]" after someReg
   --
   repeat 100 -- for safety
      if matchChunk (mergeText, someReg , startMatch, endMatch) is true then
         put char startMatch to endMatch of mergeText into varName
         put varName & CR after varNames
         delete char 1 to (endMatch + 2) of mergeText
      else
         delete char -1 of varNames
         return varNames
      end if
   end repeat
end text_GetMergeVars

function text_Type someText
   set the itemdelimiter to "|"
   put word 1 to -1 of item 1 of someText into firstItem
   put word 1 to -1 of item -1 of someText into lastItem
   switch
      case word 3 of someText = "of" And word 1 of someText is among the items of "O|M|F|G|S|PF|PM"
         return "hKey"
         break
      case firstItem = "Global" AND lastItem = "Menu"
         return "menu"
      case someText begins with "http"
         return "url"
      default
         return "text"
   end switch
end text_Type


--> Text
-
function text_IsEmpty someText
   return text_IsNotEmpty (someText) is false
end text_IsEmpty

function text_IsNotEmpty someText
   switch someText
      case "null"
      case empty
         return false
      default
         return true
   end switch
end text_IsNotEmpty

command text_ClearNull @someText
   if someText is "null" then put empty into someText
end text_ClearNull


--> Text | Caps
-
function text_MakePipeTitle someWord
   put word 1 to -1 of someWord into someWord
   put char 1 of someWord into pipeTitle
   repeat with charNum = 2 to the number of chars of someWord
      put char charNum of someWord into someChar
      if text_StartsWithCaps (someChar) is true then
         put " | "after pipeTitle
      end if
      put someChar after pipeTitle
   end repeat
   return pipeTitle
end text_MakePipeTitle

function text_SplitCaps sWord, pDelimChar
   put word_SplitCaps (sWord, pDelimChar) into sText
   put text_InitialCaps (word 1 of sText) into word 1 of sText
   return sText
end text_SplitCaps

function word_SplitCaps sWord, pDelimChar
   if pDelimChar is empty then put space into pDelimChar
   --
   put 1 into charNum
   repeat the number of chars of sWord
      put char charNum of sWord into sChar
      if text_StartsWithCaps (sChar) is true then
         put pDelimChar before char charNum of sWord
         add 2 to charNum
      else
         add 1 to charNum
      end if
   end repeat
   put the number of chars of pDelimChar into maxNum
   delete char 1 to maxNum of sWord
   return sWord
end word_SplitCaps

function text_InitialCaps someText
   repeat with wordNum = 1 to the number of words of someText
      put tolower (word wordNum of someText) into someWord
      put toupper (char 1 of someWord ) into char 1 of someWord
      put someWord into word wordNum of someText
   end repeat
   return someText
end text_InitialCaps

function text_StartsWithCaps someText
   put char 1 of sometext into testChar
   put nativeCharToNum (testChar) into someCharNum
   if someCharNum >= 97 and someCharNum <= 122 then
      return false
   else
      return true
   end if
end text_StartsWithCaps

function text_StemCaps someText
   put tolower(word 1 of someText) into stemCaps
   delete word 1 of someText
   get text_InitialCaps(someText)
   replace space with empty in it
   put it after stemCaps
   return stemCaps
end text_StemCaps


--> Line
-
command line_DeleteTail @someIndex
   repeat the number of lines of someIndex
      get word 1 to -1 of line -1 of someIndex
      if it is empty then
         delete line -1 of someIndex
      end if
   end repeat
end line_DeleteTail

function line_BeginsWith startLineChars, someLines, pLinesToSkip
   -- probably a faster way of doing this
   -- find the first line starting with...
   -- set the wholematches to false
   -- put lineoffset ("{{", wikiText) into startLineNum -- though I could do this with wholematches
   
   if pLinesToSkip is a number then delete line 1 to pLinesToSkip of someLines
   
   put CR & startLineChars into startlineChars
   put CR & someLines into testContainer
   put offset (startlineChars, testContainer) into startCharNum
   if startCharNum is 0 then
      return 0
   else
      get char 2 to (startCharNum + the number of chars of startLineChars - 1) of testContainer
      put the number of lines of it into lineNum
      return lineNum
   end if
end line_BeginsWith

function line_FindInIndex someLine, container, partLine, lineAfter
   -- was "whichLine"
   
   if someLine is empty then return 0
   if lineAfter is empty then put 0 into lineAfter
   delete line 1 to lineAfter of container
   if partLine is true then
      put container into testContainer
      put someLine into testLine
   else if partLine contains "start" or partLine contains "whole" then
      put return & container & return into testContainer
      put return & someLine into testLine
   else
      put return & container & return into testContainer
      put return & someLine & return into testLine
   end if
   
   put offset(testLine, testContainer) into start
   if start is 0 then
      return 0
   else
      put the number of lines of char 1 to start of container into line_FindInIndexNum
      if partLine contains "whole" then
         put line line_FindInIndexNum of container into testLine
         if whichWord(someLine, testLine) = 0 then
            return 0
         else
            return (line_FindInIndexNum + lineAfter)
         end if
      else
         return (line_FindInIndexNum + lineAfter)
      end if
   end if
end line_FindInIndex


--> Lines and Indexes
-
command line_Indent @sLines, pTabChars
   -- see "outline_IncreaseIndent"
   if pTabChars is empty then put tab into pTabChars
   --
   repeat with lineNum = 1 to the number of lines of sLines
      put pTabChars before line lineNum of sLines
   end repeat
end line_Indent

command line_CommonDifference @someIndex, linesToDelete
   split someIndex by CR as set
   split linesToDelete by CR as set
   --
   put someIndex into commonArray
   intersect commonArray with linesToDelete
   difference someIndex with linesToDelete
   --
   put the keys of commonArray into someIndex
   return the keys of someIndex
end line_CommonDifference

command line_DeleteIndex @someIndex, someLines
   repeat for each line someLine in someLines
      line_Delete someLine, someIndex
      if lineNum = 0 then
         put lineNum & comma after missingLineList
      end if
   end repeat
   delete char -1 of missingLineList
   return missingLineList
end line_DeleteIndex

command line_Delete someLine, @someIndex
   set the wholematches to true
   put lineoffset (someLine, someIndex) into lineNum
   delete line lineNum of someIndex
   return lineNum
end line_Delete

function line_DeleteFromIndex someLines, someIndex
   line_DeleteIndex someIndex, someLines
   return someIndex
end line_DeleteFromIndex

command line_AddIndex someLines, @someIndex, beforeLineNum
   -- was and see new simpler version "line_Add"
   set the wholematches to true
   repeat for each line someLine in someLines
      get lineoffset(someLine, someIndex)
      put the number of lines of someIndex into maxLine
      if it is 0 then
         if beforeLineNum is a number then
            put someLine & CR before line beforeLineNum of someIndex
         else
            put someLine into line (maxLine + 1) of someIndex
         end if
      end if
   end repeat
   return the number of lines of someIndex
end line_AddIndex

function line_LineNumberStartingWithWord someWord, someText
   -- gets the first line number
   
   put word 1 to -1 of someWord into someWord
   put someText into someLine
   filter someLine with (someWord && "*")
   if someLine is empty then return 0
   
   put line 1 of someLine into someLine
   set the wholematches to true
   return lineoffset(someLine, someText)
end line_LineNumberStartingWithWord

command line_StripDoublempty @someText
   repeat while someText contains (CR & CR & CR)
      replace (CR & CR & CR) with (CR & CR ) in someText
   end repeat
end line_StripDoublempty

function line_ConstructDupicateArray someIndex
   local badLineArray
   
   set the wholematches to true
   repeat while someIndex is not empty
      put line 1 of someIndex into testLine
      delete line 1 of someIndex
      
      put badLineArray [testLine] into howManyBadLines
      if howManyBadLines is empty then
         -- not already a duplicate
         -- see if it is the rest of the container
         put lineoffset(testLine, someIndex) into lineNum
         if lineNum > 0 then
            -- first duplicate
            delete line lineNum of someIndex
            put 1 into badLineArray [testLine]
         end if
      else
         put howManyBadLines + 1 into badLineArray [testLine]
         next repeat
      end if
   end repeat
   return badLineArray
end line_ConstructDupicateArray

command line_Replace replaceLine, newLine, @someIndex
   -- only replaces if it is there
   set the wholematches to true
   put lineoffset(replaceLine, someIndex) into lineNum
   if lineNum is 0 then
      -- uncomment to leave unchanged or
      line_Add newLine, someIndex
   else
      put newLine into line lineNum of someIndex
   end if
end line_Replace

function line_InsertIntoIndex newLine, someIndex, beforeLine
   line_Insert newLine, someIndex, beforeLine
   return someIndex
end line_InsertIntoIndex

command line_InsertBefore someLine, @someIndex
   -- does not work for index with blank line at end
   -- put the number of lines of someIndex into maxLine
   if someIndex is empty then
      put someLine into someIndex
   else if someLine is not empty then
      put someLine & return before someIndex
   end if
end line_InsertBefore

command line_AddToIndex newLines, @someIndex
   repeat for each line someLine in newLines
      line_Add someLine, someIndex
   end repeat
   if line 1 of someIndex is empty then delete line 1 of someIndex
end line_AddToIndex

function line_AddToIndex newLines, someIndex
   repeat for each line someLine in newLines
      line_Add someLine, someIndex
   end repeat
   return someIndex
end line_AddToIndex

function line_ConstructCompareArray leftLines, rightLines
   put leftLines into onlyLeft
   put rightLines into onlyRight
   set the wholematches to true
   repeat with leftLineLineNum = the number of lines of leftLines down to 1
      put line leftLineLineNum of leftLines into someLine
      put lineoffset (someLine, rightLines) into rightLineLineNum
      if rightLineLineNum is not 0 then
         put someLine & CR after commonIndex
         
         delete line leftLineLineNum of onlyLeft
         delete line rightLineLineNum of onlyRight
      end if
      
   end repeat
   delete last char of commonIndex
   
   sort commonIndex
   sort onlyLeft
   sort onlyRight
   
   put commonIndex into compareArray ["common"]
   put onlyLeft into compareArray ["onlyLeft"]
   put onlyRight into compareArray ["onlyRight"]
   return compareArray
end line_ConstructCompareArray

function line_GetCommon index1, index2
   set the wholematches to true
   put empty into commonIndex
   repeat for each line someLine in index1
      if someLine is among the lines of index2 then
         put someLine & return after commonIndex
      end if
   end repeat
   delete last char of commonIndex
   return commonIndex
end line_GetCommon

function line_GetMissing testIndex, referenceIndex
   set the wholematches to true
   put empty into missingIndex
   repeat for each line someLine in testIndex
      if someLine is not among the lines of referenceIndex then
         put someLine & return after missingIndex
      end if
   end repeat
   delete last char of missingIndex
   return missingIndex
end line_GetMissing

command line_Add someLines, @someIndex
   repeat for each line someLine in someLines
      if someLine is empty then next repeat
      set the wholematches to true
      put lineoffset(someLine, someIndex) into lineNum
      if lineNum is 0 then
         put the number of lines of someIndex into maxLine
         put maxLine + 1 into lineNum
         put someLine into line lineNum of someIndex
      else
         put lineNum & comma after lineNums
      end if
   end repeat
   delete char -1 of lineNums
   return lineNums
end line_Add

command line_Insert someLine, @someIndex, beforeLineNum
   if someIndex is empty then
      put someLine into someIndex
   else if someLine is not empty then
      if beforeLineNum is a number then
         put someLine & CR before line beforeLineNum of someIndex
      else
         put CR & someLine after someIndex
      end if
   end if
end line_Insert

command line_DeleteEmpty @someLines
   put CR before someLines
   put CR & "[" & space & tab & "]*" & CR into emptyLineReg
   put replacetext (someLines, emptyLineReg, return) into someLines
   delete char 1 of someLines
end line_DeleteEmpty


--> Lists
-
function item_Add someItems, someList, pPartLine, pSkipLines
   list_Add someItems, someList, pPartLine, pSkipLines
   return someList
end item_Add

command list_Add someItems, @someList, pPartLine, pSkipLines
   set the wholematches to (pPartLine is empty)
   repeat for each item someItem in someItems
      if someItem is empty then next repeat
      put itemoffset (someItem, someList, pSkipLines) into itemNum
      if itemNum is 0 then
         put the number of items of someList into maxItem
         put maxItem + 1 into itemNum
         put someItem into item itemNum of someList
      else
         add pSkipLines to itemNum
         put itemNum & comma after itemNums
      end if
   end repeat
   delete char -1 of itemNums
   return itemNums
end list_Add

command list_Delete someItems, @someList, pPartLine, pSkipLines
   set the wholematches to (pPartLine is empty)
   repeat for each item someItem in someItems
      if someItem is empty then next repeat
      put itemoffset (someItem, someList, pSkipLines) into itemNum
      if it is not 0 then
         add pSkipLines to itemNum
         delete item itemNum of someList
      end if
   end repeat
   return the number of items of someList
end list_Delete

command list_Tidy @someList
   repeat for each item someItem in someList
      get word 1 to -1 of someItem
      if it is not empty then
         put it & "," after tidyList
      end if
   end repeat
   delete char -1 of tidyList
   put tidyList into someList
end list_Tidy

command list_MakePretty @someList
   repeat for each item someItem in someList
      put word 1 to -1 of someItem & ", " after prettyList
   end repeat
   delete char -2 to -1 of prettyList
   put prettyList into someList
end list_MakePretty

function list_ToIndex someList
   repeat for each item someItem in someList
      put word 1 to -1 of someItem & CR after someIndex
   end repeat
   delete char -1 of someIndex
   return someIndex
end list_ToIndex

function list_FromIndex someIndex
   repeat for each line someLine in someIndex
      put word 1 to -1 of someLine & comma after someList
   end repeat
   delete char -1 of someList
   return someList
end list_FromIndex


--> Text
-
function text_OffsetAfter stringToFind, textToSearch, pStartSearchAt
   put offset (stringToFind, textToSearch, pStartSearchAt) into foundCharNum
   if foundCharNum is not 0 then
      add pStartSearchAt to foundCharNum
   end if
end text_OffsetAfter

function text_OffsetBefore someString, someText, beforeHere
   -- was "offsetBefore"
   if beforeHere is not empty then
      delete char beforeHere to -1 of someText
   end if
   put 1 into offsetNum
   put 0 into lastOffset
   repeat
      get text_OffsetAfter(someString, someText, lastOffset)
      if it is 0 then
         return lastOffset
      else
         put it into lastOffset
         add 1 to offsetNum
      end if
   end repeat
end text_OffsetBefore

command text_SetOffsets startText, endText, someText, @startChar, @endChar, startAfterCharNum
   -- version whereIsText 8.9,30/4/02
   
   delete char 1 to startAfterCharNum of someText
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

function text_StripJunk someString
   -- was "makeNeat"
   put "\" & tab & quote & "\[\]|*.?()" into specialChars
   -- put empty into specialChars
   put "[" && specialChars & ";/{}=#&_!,-]" into regEx
   -- put someString
   -- put regEx
   put replacetext(someString, regEx, empty) into cleanText
   return cleanText
end text_StripJunk

command text_ReQuote @someText, pMergeValue, pMergeKey
   replace "'" with quote in someText
   if pMergeValue is not empty then
      if pMergeKey is empty then put "var" into pMergeKey
      do "put pMergeValue into pMergeKey"
      put merge (someText) into someText
   end if
end text_ReQuote

function text_Strip someContainer, charsToStrip, replaceWith
   repeat for each char someChar in charsToStrip
      replace someChar with replaceWith in someContainer
   end repeat
   return someContainer
end text_Strip


--> Text | lib
-
command text_TopAndTail @someText, someChar
   if char 1 of someText is someChar then delete char 1 of someText
   if char -1 of someText is someChar then delete char -1 of someText
end text_TopAndTail

command text_DecodeUTF8 @someText
   put unidecode (uniencode (someText,"UTF8")) into someText
end text_DecodeUTF8

command number_PadLeft @someNum, padNum
   put "%0" & padNum & "d" into fString
   put format (fString, someNum) into someNum
end number_PadLeft

command text_AddTrailing @someText, someChar
   if char -1 of someText is not someChar then
      put someChar after someText
   end if
end text_AddTrailing

function text_IndexFromList someList
   return list_ToIndex (someList)
end text_IndexFromList

function text_ListFromIndex someIndex
   return list_FromIndex (someIndex)
end text_ListFromIndex

function text_WhiteChunk theText
   -- thanx to Mark Schonewille <m.schonewille@economy-x-talk.com>
   return "char 1 to" && (offset(word 1 of theText, theText) - 1)
end text_WhiteChunk

function text_RemoveEndWhiteSpace someLines
   text_StripTrailingSpaces someLines
   return someLines
end text_RemoveEndWhiteSpace

command text_StripTrailingSpaces @someText, pMultiLine
   if pMultiLine is false then
      put " *$" into someReg -- may be faster?
   else
      put "(?m)( +)$" into someReg
   end if
   put replacetext (someText, someReg, empty) into someText
end text_StripTrailingSpaces

command text_StripLeadingSpaces @someText, pMultiLine
   if pMultiLine is false then
      put "^ *" into someReg -- may be faster?
   else
      put "(?m)^( +)" into someReg
   end if
   put replacetext (someText, someReg, empty) into someText
end text_StripLeadingSpaces

command text_ReplaceMultipleSpaces @someText
   put replacetext (someText, "(?m) +", space) into someText
end text_ReplaceMultipleSpaces

command text_ConstructLineChunk charNum, someText, @charOfLine, @wordOfLine, @itemOfLine, @lineNum
   get char 1 to charNum of someText
   if someText is empty then
      put 1 into lineNum
      put 1 into itemOfLine
      put 1 into wordOfLine
      put 1 into charOfLine
   else
      put the number of lines of it into lineNum
      put the number of items of line lineNum of it into itemOfLine
      put the number of words of item itemOfLine of line lineNum of it into wordOfLine
      put the number of chars of line lineNum of it into charOfLine
   end if
end text_ConstructLineChunk

function text_TokenOffset someString, someContainer
   repeat with tokenNum = 1 to the number of tokens in someContainer
      put token tokenNum of someContainer into someToken
      if someToken = someString then
         return tokenNum
      end if
   end repeat
   return 0
end text_TokenOffset

function text_FirstLetter theText
   return offset(word 1 of theText, theText)
end text_FirstLetter

function text_ContainsItem someText, itemList
   repeat for each item testItem in itemList
      if someText contains testItem then return true
   end repeat
   return false
end text_ContainsItem

function text_GetPlural someText
   if char -1 of someText is "y" then
      put "ies" into char -1 of someText
   else
      put "s" after someText
   end if
   return someText
end text_GetPlural

function text_GetSingular someText
   switch char -1 of someText
      case "ies"
         put "y" into char -1 to -3 of someText
         break
      case "s"
         delete char -1 of someText
   end switch
   return someText
end text_GetSingular

command text_AddParagraph newText, @someText, crNum
   set the wholematches to true
   if newText is among the lines of someText then return false
   -- if newText is in someText then return false
   text_InsertParagraph newText, someText, crNum
   return true
end text_AddParagraph

function text_GetBetween startText, endText, someText, startAfterCharNum
   -- was "getTextBetween"
   text_SetOffsets startText, endText, someText, startChar, endChar, startAfterCharNum
   if startChar = 0 or endChar = 0 then return empty
   add the number of chars of startText to startChar
   subtract the number of chars of endText from endChar
   return char startChar to endChar of someText
end text_GetBetween

command text_SetBetween startText, endText, @someText, newSection, startAfterCharNum
   text_SetOffsets startText, endText, someText, startChar, endChar, startAfterCharNum
   if startChar = 0 or endChar = 0 then return empty
   
   put newSection into char startChar to endChar of someText
end text_SetBetween

function text_StringCount charOrString, someText
   put 0 into startSearchHere
   put 0 into charCount
   repeat
      put text_OffsetAfter(charOrString, someText, startSearchHere) into startSearchHere
      if startSearchHere is 0 then
         exit repeat
      else
         add 1 to charCount
      end if
   end repeat
   return charCount
end text_StringCount

command text_InsertParagraph newText, @someText, pCrNum
   put word 1 to -1 of newText into newText
   put word 1 to -1 of someText into someText
   if pCrNum is empty then
      put CR & CR into crBit
   else if pCrNum is a number then
      put text_RepeatString (CR, pCrNum) into crBit
   else
      put crNum & CR & CR into crBit
   end if
   
   if newText is not empty then
      if someText is empty then
         put newText into someText
      else
         put crBit & newText after someText
      end if
   end if
end text_InsertParagraph

function text_RepeatString someString, repeatNum
   repeat repeatNum
      put someString after repeatString
   end repeat
   return repeatString
end text_RepeatString


--> Text | Tags
-
command text_StripTags @someXml
   put word 1 to -1 of replacetext (someXml, "(<(.|\n)+?>)", empty) into someXml
end text_StripTags

function text_StripAllTags someXml
   put word 1 to -1 of replacetext (someXml, "(<(.|\n)+?>)", empty) into someText
   return someText
end text_StripAllTags


--> Text | Quotes
-
function kwote someText, pQuoteChar
   if pQuoteChar is empty then put quote into pQuoteChar
   return pQuoteChar & someText & pQuoteChar
end kwote

function text_ExtractQuoted someText
   local quotedLines
   put 0 into startAfterCharNum
   repeat
      text_SetOffsets quote, quote, someText, startChar, endChar, startAfterCharNum
      if startChar = 0 or endChar = 0 then return quotedLines
      put char (startChar + 1) to (endChar - 1) of someText into quotedText
      line_Insert quotedText, quotedLines
      put endChar into startAfterCharNum
   end repeat
end text_ExtractQuoted

function text_IsQuoted someText, pString
   local quotedText
   put "['" & quote & "]" into someQuote
   if pString is empty then
      put "(?m)" & someQuote & "(.*)" & someQuote into someReg
   else
      put "(?m)" & someQuote & "(.*" & pString & ".*)" & someQuote into someReg
   end if
   put matchtext (someText, someReg, quotedText) into someBoolean
   return someBoolean
end text_IsQuoted

function text_GetQuoted someText
   local quotedText
   put "['" & quote & "]" into someQuote
   put "(?m)" & someQuote & "(.*)" & someQuote into someReg
   put matchtext (someText, someReg, quotedText) into someBoolean
   return quotedText
end text_GetQuoted

function withinQuotes textOrOffset, someContainer
   -- version latest, 2/2/00
   
   put item 1 of textOrOffset into startCharNum
   put item 2 of textOrOffset into endCharNum
   if endCharNum is empty then put startCharNum into endCharNum
   if startCharNum is a number and endCharNum is a number then
   else
      put offset(textOrOffset, someContainer) into startCharNum
      put startCharNum + the length of textOrOffset - 1 into endCharNum
   end if
   
   if startCharNum is 0 then
      return "Not Found"
   else
      put char 1 to (startCharNum - 1) of someContainer into textBefore
      put text_StringCount(quote, textBefore) into quotesBefore
      put the number of chars of someContainer into lastCharNum
      put char (endCharNum + 1) to lastCharNum of someContainer into textAfter
      put text_StringCount(quote, textAfter) into quotesAfter
      if math_IsOdd(quotesBefore) and quotesAfter >= 1 then
         return true
      else
         return false
      end if
   end if
end withinQuotes

function text_StripQuoted someText
   put _ConstructQuoteReg() into someReg
   put replaceText (someText, someReg, "•••") into strippedText
   return strippedText
end text_StripQuoted

command text_StipQuoted @someText
   put "(" & quote & "[^" & quote & "]*" & quote & ")" into quoteReg
   text_StripReg someText, quoteReg, "•••"
end text_StipQuoted

command text_StarQuoted @someText
   local replacedArray
   
   put someText into replacedArray ["original text"]
   -- put _ConstructQuoteReg() into someReg
   put "(" & quote & "[^" & quote & "]*" & quote & ")" into someReg
   put 1 into indexNum
   repeat 100
      if matchchunk (someText, someReg, startChar, endChar) is false then
         exit repeat
      else
         put char startChar to endChar of someText into replacedArray [indexNum]["someString"]
         put startChar into replacedArray [indexNum]["startChar"]
         put endChar into replacedArray [indexNum]["endChar"]
         repeat with charNum = startChar to endChar
            put "•" into char charNum of someText
         end repeat
         add 1 to indexNum
      end if
   end repeat
   return replacedArray
end text_StarQuoted

private function _ConstructQuoteReg
   -- put "(" & quote & "[^" & quote & "]*" & quote & ")" into someReg
   get "•([^•\\]|\\.)*•|'([^'\\]|\\.)*'"
   replace "•" with quote in it
   return it
end _ConstructQuoteReg

function text_TempReplaceQuoted someText, @offsetArray
   -- was "temptext_StripQuoted"
   -- version original,18/9/01
   
   put "(" & quote & "[^" & quote & "]*" & quote & ")" into someReg
   put 1 into dummyNum
   repeat
      if matchchunk(someText, someReg, startChar, endChar) then
         put char startChar to endChar of someText into quotedText
         put "<dummy id=" & dummyNum & "/>" into safeReplaceMent
         put safeReplaceMent into char startChar to endChar of someText
         put quotedText into offsetArray[safeReplaceMent]
         add 1 to dummyNum
      else
         return someText
      end if
   end repeat
end text_TempReplaceQuoted

function text_ReReplaceQuoted someStrippedText, offsetArray
   -- was "untext_StripQuoted"
   -- version original,18/9/01
   
   put keys(offsetArray) into dummyTags
   repeat for each line dummyTag in dummyTags
      put offsetArray[dummyTag] into quotedText
      replace dummyTag with quotedText in someStrippedText
   end repeat
   return someStrippedText
end text_ReReplaceQuoted

function replaceQuotedItems someList
   put "•|comma|•" into opfSafeComma
   repeat
      get whereIsText(quote, quote, someList)
      if it is "Not Found" then
         exit repeat
      else
         put item 1 of it into startChar
         put item 2 of it into endChar
         put char startChar to endChar of somelist into quotedItem
         put replaceAll(",", quotedItem, opfSafeComma) into safeItem
         if char 1 of safeItem is quote then delete char 1 of safeItem
         if last char of safeItem is quote then delete last char of safeItem
         put safeItem into char startChar to endChar of someList
      end if
   end repeat
   return someList
end replaceQuotedItems
