script "lib_Text"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Text
type: script library
version: 0.8


--> Rename
-
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


--> Lines and Indexes
-
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
   return line_DeleteIndex @someIndex, someLines
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

command line_StripDoubleEmpty @someText
    repeat while someText contains (CR & CR & CR)
        replace (CR & CR & CR) with (CR & CR ) in someText
    end repeat
end line_StripDoubleEmpty

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

function line_UniqueIndex someIndex, pCaseSensitive
   line_SetUnique someIndex, pCaseSensitive
   return someIndex
end line_UniqueIndex

command line_SetUnique @someIndex, pCaseSensitive
   if pCaseSensitive is false then
      split someIndex by CR and tab
      put the keys of someIndex into uniqueIndex
      return word 1 to -1 of uniqueIndex
   else
      repeat for each line someLine in someIndex
         put empty into indexArray [someLine]
      end repeat
      return keys(indexArray)
   end if
end line_SetUnique

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


--> Lists
-
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

function text_Strip someContainer, charsToStrip, replaceWith
    repeat for each char someChar in charsToStrip
        replace someChar with replaceWith in someContainer
    end repeat
    return someContainer
end text_Strip


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

command text_StripLeadingSpaces @someText, multiLine
    if multiLine is false then
        put "^ *" into someReg -- may be faster?
    else
        put "(?m)^( +)" into someReg
    end if
    put replacetext(someText, someReg, empty) into someText
end text_StripLeadingSpaces

command text_StripTrailingSpaces @someText, multiLine
    if multiLine is false then
        put " *$" into someReg -- may be faster?
    else
        put "(?m)( +)$" into someReg
    end if
end text_StripTrailingSpaces

command text_ReplaceMultipleSpaces @someText
    put replacetext(someText, "(?m) +", space) into someText
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

function text_WhiteChunk theText
    -- thanx to Mark Schonewille <m.schonewille@economy-x-talk.com>
    return "char 1 to" && (offset(word 1 of theText, theText) - 1)
end text_WhiteChunk

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

function text_Hash someData, pWhichDigest
   if pWhichDigest = "sha1" then
      return sha1_Hash (someData)
   else
      return md5_Hash (someData)
   end if
end text_Hash

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

function text_RepeatString someString, repeatNum
    -- was "text_GetRepeatString"
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

command text_StarQuoted @someText
   local replacedArray

   put someText into replacedArray ["original text"]
   put "(" & quote & "[^" & quote & "]*" & quote & ")" into someReg
   put 1 into indexNum
   repeat
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

function text_StripQuoted someText
   put "(" & quote & "[^" & quote & "]*" & quote & ")" into someReg
   put replaceText (someText, someReg, "•••") into strippedText
   return strippedText
end text_StripQuoted

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

command text_StripSurroundingQuotes @someText
   -- think this should work
   put token 1 of someText into someText
   return empty

   get word 1 to -1 of someText
   put quote & "'" into quoteChars
   if char 1 of it is among the chars of quoteChars and char -1 of it is among the chars of quoteChars then
      delete char 1 of someText
      delete char -1 of someText
   end if
end text_StripSurroundingQuotes


--> Text | Caps
-
function text_InitialCaps someText
    repeat with wordNum = 1 to the number of words of someText
        put tolower(word wordNum of someText) into someWord
        put toupper(char 1 of someWord ) into char 1 of someWord
        put someWord into word wordNum of someText
    end repeat
    return someText
end text_InitialCaps

function text_SplitCaps someWord
    -- was "capsSplit"
    put 1 into charNum
    repeat the number of chars of someWord
        put char charNum of someWord into someChar
        if text_StartsWithCaps(someChar) is true then
            put space before char charNum of someWord
            add 2 to charNum
        else
            add 1 to charNum
        end if
    end repeat
    put text_InitialCaps(word 1 of someWord) into word 1 of someWord
    return word 1 to -1 of someWord
end text_SplitCaps

function text_StartsWithCaps someText
   -- was "startsWithCaps"
   put char 1 of sometext into testChar
   put chartonum(testChar) into someCharNum
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

function text_IsCaps someText
   -- use casesensitive
   return matchtext (word 1 to -1 of someText, "\b[A-Z]+\b", anyThing)

   repeat for each char testChar in someText
      put chartonum (testChar) into someCharNum
      if someCharNum >= 65 and someCharNum <= 90 then
         return false
      end if
   end repeat
   return true
end text_IsCaps
