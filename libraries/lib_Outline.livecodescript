script "lib_Outline"
--> MetaData
-
license: GPLv3
name: lib_Outline
type: library
version: 0.1

/*
A library for processing tab delimitted "outlines".
*/

--> Outline
-
function outline_TopLevelTitles someOutline
    filter someOutline without (tab & "*")
    return someOutline
end outline_TopLevelTitles

function outline_StripLeadingSpace someOutline
    -- was "outline_StripLeadingTabs"
    repeat for each line someLine in someOutline
        put word 1 to -1 of someLine & CR after someIndex
    end repeat
    delete char -1 of someIndex
    return someIndex
end outline_StripLeadingSpace

function outline_TabLevel someLine
    -- was "titleToTabLevel"
    put 0 into tabLevel
    repeat
        if char (tabLevel+1) of someLine is tab then
            add 1 to tabLevel
        else
            return tabLevel
        end if
    end repeat
end outline_TabLevel

function outline_FilterTabLevel osSection, domainTabLevel
    -- was "filter_TabLevel"
    put text_RepeatString(tab, domainTabLevel) into tabBit
    put tabBit & "[a-zA-Z0-9]*" into filterString
    filter osSection with filterString
    return osSection
end outline_FilterTabLevel

function outline_SetIndent someOsSection, toIndentLevel
    put outline_TabLevel(line 1 of someOsSection) + 1 into osStartLevel
    put toIndentLevel - osStartLevel into byIndentLevel
    put outline_IncreaseIndent (someOsSection, byIndentLevel) into someOsSection
    return someOsSection
end outline_SetIndent

function outline_DecreaseIndent someOsSection, byIndentLevel
    --was "outline_DecreaseIndent"
    if byIndentLevel = 0 then return someOsSection
    repeat with ii = 1 to the number of lines of someOsSection
        put line ii of someOsSection into osTitle
        repeat byIndentlevel
            if char 1 of osTitle is tab then
                delete char 1 of osTitle
            else
                exit repeat
            end if
        end repeat
        put osTitle into line ii of someOsSection
    end repeat
    return someOsSection
end outline_DecreaseIndent

function outline_IncreaseIndent someOsSection, byIndentLevel, indentString
   if indentString is empty then put tab into indentString
   if byIndentLevel is not a number then put 1 into byIndentLevel
   if byIndentLevel = 0 then return someOsSection
   if byIndentLevel < 0 then return outline_DecreaseIndent(someOsSection, abs(byIndentLevel))
   put text_RepeatString(indentString, byIndentLevel) into indentWhiteSpace
   repeat with ii = 1 to the number of lines of someOsSection
      put indentWhiteSpace before line ii of someOsSection
   end repeat
   return someOsSection
end outline_IncreaseIndent


--> Outline | Arrays
-
function outline_ToDatagridArray tabbedText, pFieldNameArray
   local dgArray
   put pFieldNameArray ["title"] into titleFieldName
   if titleFieldName is empty then put "title" into titleFieldName
   
   put pFieldNameArray ["link"] into linkFieldName
   if linkFieldName is empty then put "link" into linkFieldName
   
   put pFieldNameArray ["tabLevel"] into tablevelFieldName
   if tablevelFieldName is empty then put "tabLevel" into tablevelFieldName
   
   set the itemdelimiter to tab
   repeat with lineNum = 1 to the number of lines of tabbedText
      put line lineNum of tabbedText into someLine
      get item -1 of someLine
      html_DeconstructNameLink it, someTitle, someLink
      put someTitle into dgArray [lineNum][titleFieldName]
      put someLink into dgArray [lineNum][linkFieldName]
      put outline_TabLevel(someLine) into dgArray [lineNum][tablevelFieldName]
   end repeat
   return dgArray
end outline_ToDatagridArray

function outline_ToNestedArray tabbedText, pTabChar, pTabsPerLevel
   local outlineArray, keyArray
   if pTabChar is empty then put tab into pTabChar
   if pTabsPerLevel is empty then put 1 into pTabsPerLevel
   
   set the itemdelimiter to pTabChar
   repeat for each line someLine in tabbedText
      put someLine into someKey
      put 0 into tabNum
      repeat the number of chars of someKey
         if char 1 of someKey = pTabChar then
            add 1 to tabNum
            delete char 1 of someKey
         else
            exit repeat
         end if
      end repeat
      put 1 + trunc(tabNum/pTabsPerLevel) into pathLevel
      
      put someKey into keyArray [pathLevel]
      
      -- trim any tail off the array
      put the number of lines of the keys of keyArray into maxNum
      repeat with keyNum = (pathLevel + 1) to maxNum
         delete local keyArray [keyNum]
      end repeat
      
      put keyArray into aboveKeyArray
      delete local aboveKeyArray [pathLevel]
      
      put outlineArray [aboveKeyArray] into aboveValue
      put empty into outlineArray [keyArray]
      if aboveValue is not empty then
         put aboveValue into outlineArray [aboveKeyArray]["@"]
      end if
   end repeat
   return outlineArray
end outline_ToNestedArray

function array_ToOutline someArray, pSortKeys
   -- recursive version for nested arrays
   local someOutline
   
   if pSortKeys is empty then
      -- faster
      repeat for each key someKey in someArray
         put someKey & CR after someOutline
         get someArray [someKey]
         if it is an array then get array_ToOutline(it)
         if it is not empty then
            put outline_IncreaseIndent (it, 1) & CR after someOutline
         end if
      end repeat
      delete last char of someOutline
      return someOutline
   else
      put keys(someArray) into someKeys
      sort someKeys
      repeat for each line someKey in someKeys
         put someKey & CR after someOutline
         get someArray [someKey]
         if it is an array then get array_ToOutline (it, pSortKeys)
         if it is not empty then
            put outline_IncreaseIndent (it) & CR after someOutline
         end if
      end repeat
      delete last char of someOutline
      return someOutline
   end if
end array_ToOutline

function outline_ToArray tabbedText
    -- this could be done better with clever use of delimiters
    -- itemdelim = CR and tab or funny char insead of CR
    
    local someArray
    replace (CR & tab) with tab in tabbedText
    set the itemdelimiter to tab
    repeat for each line someLine in tabbedText
        put item 1 of someLine into someKey
        put item 2 to -1 of someLine into someValue
        replace tab with CR in someValue
        put someValue into someArray [someKey]
    end repeat
    return someArray
end outline_ToArray

function outline_ConvertToTable tabbedText
    replace (CR & tab) with tab in tabbedText
    return tabbedText
end outline_ConvertToTable

function outline_ToPathArray tabbedOutline
    -- not finished yet 
    repeat with lineNum = 1 to the number of lines of tabbedOutline
        put line lineNum of tabbedOutline into toplevelTitle
        if char 1 of toplevelTitle is tab then next repeat
        
        -- put outline_PathFromLineNum(lineNum, tabbedOutline, "/") into somePath
        put outline_GetChildren(lineNum, tabbedOutline) into osSection
        put osSection into outlineArray [toplevelTitle]
        
        put the number of lines of osSection into skipNum
        add skipNum to lineNum
    end repeat
    return outlineArray
end outline_ToPathArray


--> Outline | Sections
-
command outline_AddTitleSection osTitle, osSection, @someOutline, pIndentLevel
   if osSection is not empty then
      if pIndentLevel is empty then
         put osTitle & CR after someOutline
         put outline_IncreaseIndent (osSection) & CR after someOutline
      else
         put pIndentLevel - 1 into titleLevel
         put outline_IncreaseIndent (osTitle, titleLevel) & CR after someOutline
         put outline_IncreaseIndent (osSection, pIndentLevel) & CR after someOutline
      end if
   end if
end outline_AddTitleSection

function outline_AddSection newOs, someOutline
    -- was "addOutlineSection"
     
    put line 1 of newOs into newOsTitle
    if line_FindInIndex(newOsTitle, someOutline) is 0 then
        line_Insert newOs, someOutline
        return someOutline -- line_InsertIntoIndex(newOs, someOutline)
    else
        return outline_ReplaceSection(newOsTitle, someOutline, newOs)
    end if
end outline_AddSection

on outline_SetSectionOffsets someTitle, tabbedOutline @startLineNum, @lastLineNum
    put outline_LineOffset (someTitle, tabbedOutline) into startLineNum
    put outline_NextSameLevel (startLineNum, tabbedOutline) into lastLineNum
    if lastLineNum = 0 then
        put 0 into lastLineNum
        return empty
    end if
    put the number of lines of tabbedOutline into maxLineNum
    if lastLineNum is not maxLineNum then
        subtract 1 from lastLineNum
    end if
end outline_SetSectionOffsets

function outline_IsLeaf startOsLineNum, tabbedOutline
    return outline_GetChildren(startOsLineNum, tabbedOutline) is empty
end outline_IsLeaf

function outline_ExtractLineSection startOsLineNum, tabbedOutline
    -- (was extractOsSection) -- version original,31/3/01
     
    delete line 1 to (startOsLineNum - 1) of tabbedOutline
    put outline_NextSameLevel(1, tabbedOutline) into outline_NextSameLevelLineNum
    if outline_NextSameLevelLineNum is 0 then
        return tabbedOutline
    else
        return line 1 to outline_NextSameLevelLineNum of tabbedOutline
    end if
end outline_ExtractLineSection

function outline_ExtractSection lineNumOrTitle, someOutLine
    -- renamed from "getOutlineSection", then "outline_ExtractSection"
    -- version original, 7/4/99
     
    if lineNumOrTitle is a number then
        put lineNumOrTitle into osTitleLineNum
        put line osTitleLineNum of someOutLine into someOsTitle
        if osTitleLineNum < 1 then
            put 0 into baseTabLevel
        else
            put outline_TabLevel(someOsTitle) into baseTabLevel
        end if
    else
        put lineNumOrTitle into someOsTitle
        put outline_TabLevel(someOsTitle) into baseTabLevel
        put line_FindInIndex(lineNumOrTitle, someOutLine) into osTitleLineNum
        if osTitleLineNum is 0 then
            return empty
        end if
    end if
     
    put osTitleLineNum + 1 into startLineNum
    put someOsTitle & return into nextLevelTitles
    repeat with lineNum = startLineNum to the number of lines of someOutLine
        put line lineNum of someOutLine into someOsTitle
        put outline_TabLevel(someOsTitle) into someTabLevel
        if someTabLevel is baseTabLevel then
            exit repeat
        else if someTabLevel > baseTabLevel then
            put someOsTitle & CR after nextLevelTitles
        end if
    end repeat
    delete last char of nextLevelTitles
    return nextLevelTitles
end outline_ExtractSection

function outline_ReplaceSection osTitleOrNumber, someOutline, newOs, @oldOsLength
    -- put outline_ReplaceSection(osTitleOrNumber, someOutline, newOs, oldOsLength)
    -- version Tree, 23/1/02
    if osTitleOrNumber is a number then
        put osTitleOrNumber into osTitleLineNum
        put line osTitleLineNum of someOutLine into someOsTitle
        if osTitleLineNum < 1 then
            put 0 into baseTabLevel
        else
            put countStrings(tab, someOsTitle) into baseTabLevel
        end if
    else
        put osTitleOrNumber into someOsTitle
        put countStrings(tab, someOsTitle) into baseTabLevel
        put line_FindInIndex(osTitleOrNumber, someOutLine) into osTitleLineNum
        if osTitleLineNum is 0 then
            -- can't find title in full outline. Insert at end instead...
            put the number of lines of someOutline into lastLineNum
            put outline_IncreaseIndent(newOS, 1) into newOsToInsert
            put someOsTitle & return & newOsToInsert into line (lastLineNum + 1) of someOutline
            put 0 into oldOsLength
            return someOutline
        end if
    end if
     
    put osTitleLineNum + 1 into startLineNum
    put empty into nextLevelTitles
    put the number of lines of someOutLine into lastLineNum
    repeat with endOsLineNum = startLineNum to lastLineNum
        put line endOsLineNum of someOutLine into someOsTitle
        put countStrings(tab, someOsTitle) into someTabLevel
        if someTabLevel is baseTabLevel then
            if newOs is empty then
                delete line osTitleLineNum to (endOsLineNum - 1) of someOutline
            else
                put outline_IncreaseIndent(newOS, baseTabLevel) into newOsToInsert
                put newOsToInsert into line osTitleLineNum to (endOsLineNum - 1) of someOutline
            end if
            put endOsLineNum - osTitleLineNum into oldOsLength
            return someOutline
        end if
    end repeat
     
    put outline_IncreaseIndent(newOS, baseTabLevel) into newOsToInsert
    put newOsToInsert into line osTitleLineNum to lastLineNum of someOutline
    put lastLineNum - osTitleLineNum + 1 into oldOsLength
    return someOutline
end outline_ReplaceSection


--> Outline | Html Index
-
function outline_ReverseNameLinks someOutline
    repeat for each line osLine in someOutline
        put outline_TabLevel(osLine) into tabLevel
        put word 1 to -1 of osLine into someLine
        html_DeconstructNameLink someLine, someText, someLink
        if someLink is empty then
            put osLine & CR after newOutline
        else
            put html_ConstructNameLink(someLink, someText) into newLine
            put outline_IncreaseIndent(newLine, tabLevel) & CR after newOutline
        end if
    end repeat
    return word 1 to -1 of newOutline
end outline_ReverseNameLinks



--> Outline | Paths
-
/*
See also "Object | Outline" section in libOPN_Objects
*/

function outline_FirstColumnFromPathIndex pathIndex, pDelim, pDontSort
   if pDelim is not empty then set the itemDelimiter to pDelim
   repeat for each line someLine in pathIndex
      put item 1 of someLine into newRoot
      if newRoot is not among the lines of rootIndex then
         put newRoot & CR after rootIndex
      end if
   end repeat
   delete char -1 of rootIndex
   if pDontSort is not true then sort rootIndex
   return rootIndex
end outline_FirstColumnFromPathIndex

function outline_LeafIndex someOutline, pDelim, pStem
   if pDelim is empty then put "/" into pDelim
   put empty into pathIndex
   put empty into pathString
   repeat with osLineNum = 1 to the number of lines of someOutline
      put outline_IsLeaf (osLineNum, someOutline) into isLeaf
      
      put line osLineNum of someOutline into osLine
      if pStem is not empty then put pStem & pDelim after pathIndex
      put outline_TabLevel(osLine) into tabLevel
      if tabLevel = 0 then
         put osLine into mainTitle
         put mainTitle into pathString
         if isLeaf is true then 
            put mainTitle & CR after pathIndex
         end if
      else
         set the itemdelimiter to tab
         put item (tabLevel+1) of osLine into subTitle
         set the itemdelimiter to pDelim
         put subTitle into item (tabLevel+1) of pathString
         put item 1 to (tabLevel+1) of pathString into subPath
         if isLeaf is true then 
            put subPath & CR after pathIndex
         end if
      end if
   end repeat
   delete char -1 of pathIndex
   return pathIndex
end outline_LeafIndex

function outline_ToPathIndex someOutline, pathDelim, pathStem
    if pathDelim is empty then put "/" into pathDelim
    put empty into pathIndex
    put empty into pathString
    repeat for each line osLine in someOutline
        if pathStem is not empty then put pathStem & pathDelim after pathIndex
        put outline_TabLevel(osLine) into tabLevel
        if tabLevel = 0 then
            put osLine into mainTitle
            put mainTitle into pathString
            put mainTitle & CR after pathIndex
        else
            set the itemdelimiter to tab
            put item (tabLevel+1) of osLine into subTitle
            set the itemdelimiter to pathDelim
            put subTitle into item (tabLevel+1) of pathString
            put item 1 to (tabLevel+1) of pathString into subPath
            put subPath & CR after pathIndex
        end if
    end repeat
    delete char -1 of pathIndex
    return pathIndex
end outline_ToPathIndex

function outline_FromPathIndex pathIndex, pDelim, pUsePathLinks, pTitleAtEnd
   local tabbedOutline, linkedOutline, beforeTag, afterTag
   repeat for each line somePath in pathIndex
      if pUsePathLinks is true then
         outline_AddHtmlPathLinksPath somePath, tabbedOutline, linkedOutline, pDelim, beforeTag, afterTag, pTitleAtEnd
      else
         put outline_AddPath(somePath, tabbedOutline, pDelim, beforeTag, afterTag, pTitleAtEnd) into tabbedOutline
      end if
   end repeat
   if pUsePathLinks is true then
      return linkedOutline
   else
      return tabbedOutline
   end if
end outline_FromPathIndex

private command outline_AddHtmlPathLinksPath somePath, @tabbedOutline, @linkedOutline, pathDelim, beforeTag, afterTag, insertTitleAtEnd
   -- links whole line muck up tree functions (so disabled)
   if pathDelim is empty then put "/" into pathDelim
   
   set the itemdelimiter to pathDelim
   set the wholematches to true
   put 0 into lastFoundLine
   put empty into tabBit
   
   put the number of items of somePath into lastItemNum
   put 0 into lastFoundLine
   repeat with itemNum = 1 to lastItemNum
      put item itemNum of somePath into pathItem
      put item 1 to itemNum of somePath into pathFragment
      put html_ConstructNameLink (pathItem, pathFragment) into outlineItem
      
      put tabBit & pathItem into osLine
      put lineoffset(osLine, tabbedOutline, lastFoundLine) into foundLineNum
      if foundLineNum is not 0 then
         -- already there
         -- probably the folder part of the outline (not the leaf)
         put tab after tabBit
         add foundLineNum to lastFoundLine
      else
         -- need to add this path to the right place in the outline
         -- lets construct the "osLineSection" to add
         
         if itemNum + 1 > lastItemNum then
            put tabBit & beforeTag & pathItem & afterTag into osLineSection
            put tabBit & beforeTag & outlineItem & afterTag into linkedLineSection
         else
            put osLine into osLineSection
            
            put item 1 to itemNum of somePath into pathFragment
            put tabBit & html_ConstructNameLink (pathItem, pathFragment) into linkedLineSection
            
            repeat with foundItemNum = (itemNum + 1) to lastItemNum
               put item foundItemNum of somePath into foundPathItem
               put item 1 to foundItemNum of somePath into pathFragment
               put html_ConstructNameLink (foundPathItem, pathFragment) into foundOutlineItem
               
               put tab after tabBit
               if foundItemNum is lastItemNum then
                  put CR & tabBit & beforeTag & foundPathItem & afterTag after osLineSection
                  put CR & tabBit & beforeTag & foundOutlineItem & afterTag after linkedLineSection
               else
                  put CR & tabBit & foundPathItem after osLineSection
                  put CR & tabBit & foundOutlineItem after linkedLineSection
               end if
            end repeat
         end if
         
         -- now lets add the new "osLineSection" to the right place in the outline
         if tabbedOutline is empty then
            put osLineSection into tabbedOutline
            put linkedLineSection into linkedOutline
         else
            if lastFoundLine is 0 then put the number of lines of tabbedOutline into lastFoundLine
            
            -- where do we want to add the line ???
            if insertTitleAtEnd is false then
               -- just after the osTitle above
               put CR & osLineSection after line lastFoundLine of tabbedOutline
               put CR & linkedLineSection after line lastFoundLine of linkedOutline
            else
               -- or how about at the end of the section?
               outline_SetChildrenOffsets lastFoundLine, firstOsTitleLineNum, lastOsTitleLineNum, tabbedOutline
               put CR & osLineSection after line lastOsTitleLineNum of tabbedOutline
               put CR & linkedLineSection after line lastOsTitleLineNum of linkedOutline
            end if
         end if
         return linkedOutline
      end if
   end repeat
   return linkedOutline
end outline_AddHtmlPathLinksPath

function outline_AddPath somePath, tabbedOutline, pDelim, pBeforeTag, pAfterTag, insertWhere
   if pDelim is empty then put "/" into pDelim
   
   set the itemdelimiter to pDelim
   set the wholematches to true
   put 0 into lastFoundLine
   put empty into tabBit
   
   put 0 into lastFoundLine
   put the number of items of somePath into lastItemNum
   repeat with itemNum = 1 to lastItemNum
      put item itemNum of somePath into pathItem
      
      put tabBit & pathItem into osLine
      put lineoffset(osLine, tabbedOutline, lastFoundLine) into foundLineNum
      if foundLineNum is not 0 then
         -- already there
         put tab after tabBit
         add foundLineNum to lastFoundLine
      else
         -- need to add this path to the right place in the outline
         
         -- first lets construct osLineSection
         if itemNum + 1 > lastItemNum then
            put tabBit & pBeforeTag & pathItem & pAfterTag into osLineSection
         else
            put osLine into osLineSection
            repeat with foundItemNum = (itemNum + 1) to lastItemNum
               put item foundItemNum of somePath into foundPathItem
               
               put tab after tabBit
               if foundItemNum is lastItemNum then
                  put CR & tabBit & pBeforeTag & foundPathItem & pAfterTag after osLineSection
               else
                  put CR & tabBit & foundPathItem after osLineSection
               end if
            end repeat
         end if
         
         -- now lets add the new "osLineSection" to the right place in the outline
         if tabbedOutline is empty then
            put osLineSection into tabbedOutline
         else
            if lastFoundLine is 0 then put the number of lines of tabbedOutline into lastFoundLine
            
            -- where do we want to add the line ???
            switch insertWhere
               case "if this worked it would be sorted"
                  put outline_LineParent (lastFoundLine, tabbedOutline, parentLineNum) into parentTitle
                  outline_SetChildrenOffsets parentLineNum, firstOsTitleLineNum, lastOsTitleLineNum, tabbedOutline
                  -- put outline_GetChildren (lastFoundLine, tabbedOutline) into osChildren
                  put line firstOsTitleLineNum to lastOsTitleLineNum of tabbedOutline into sortedChildren
                  line_Insert osLineSection, sortedChildren
                  sort sortedChildren
                  put sortedSection into line (firstOsTitleLineNum + 1) to lastOsTitleLineNum of tabbedOutlinecase
                  -- just after the osTitle above
                  put CR & osLineSection after line lastFoundLine of tabbedOutline
                  break
               default -- case "End of section"
                  -- or how about at the end of the section?
                  outline_SetChildrenOffsets lastFoundLine, firstOsTitleLineNum, lastOsTitleLineNum, tabbedOutline
                  put CR & osLineSection after line lastOsTitleLineNum of tabbedOutline
                  break
            end switch
         end if
         return tabbedOutline
      end if
   end repeat
   return tabbedOutline
end outline_AddPath

function outline_HierarchyFromPath somePath, someDelim
    if someDelim is not empty then put "/" into someDelim
    repeat for each item pathBit in somePath
        put pathBit after pathOutlineSection
        put tab after indentBit
        put return & indentBit after pathOutlineSection
    end repeat
    delete last line of pathOutlineSection
    return pathOutlineSection
end outline_HierarchyFromPath

function outline_PathFromLineNum osLineNum, tabbedOutline, pathDelim
    put outline_LinePath(osLineNum, tabbedOutline, osLineNumList, pathDelim) into somePath
    -- replace return with pathDelim in somePath
    return somePath
end outline_PathFromLineNum

function outline_PathOffset somePath, tabbedOutline, pathDelim
    -- was "outLineOffset"
    if pathDelim is empty then put "/" into pathDelim
    set the wholematches to true
    put 0 into tSkip
    put empty into tabBit
    set the itemdelimiter to pathDelim
    repeat for each item osTitle in somePath
        put tabBit & osTitle into osLine
        put lineoffset(osLine, tabbedOutline, tSkip) into foundLineNum
        if foundLineNum is 0 then
            return 0
        else
            put tab after tabBit
            add foundLineNum to tSkip
        end if
    end repeat
    return tSkip
end outline_PathOffset

function outline_GetChildPaths somePath, tabbedOutline, pathDelim
    if somePath is empty then
        return outline_TopChildren(tabbedOutline)
    else
        if pathDelim is empty then put "/" into pathDelim
        put outline_PathOffset(somePath, tabbedOutline, pathDelim) into startOsLineNum
        if startOsLineNum = 0 then return empty
        
        put somePath & pathDelim into pathBit
        return outline_GetChildren(startOsLineNum, tabbedOutline, pathBit)
    end if
end outline_GetChildPaths

function outline_PathChildren somePath, tabbedOutline, pathDelim, noPath
    if somepath is empty then
        return outline_TopChildren(tabbedOutline)
    else
        if pathDelim is empty then put "/" into pathDelim
        put outline_PathOffset(somePath, tabbedOutline, pathDelim) into startOsLineNum
        if startOsLineNum = 0 then return empty
        
        if noPath is true then
            put empty into pathBit
        else
            put somePath & pathDelim into pathBit
        end if
        return outline_GetChildren(startOsLineNum, tabbedOutline, pathBit)
    end if
end outline_PathChildren


--> Outline | Paths | LinkArray
-
/*
Not at all sure about these recursive functions.
*/

function outline_ToLinkArray tabbedOutline, pathDelim, noPath
    local linkArray
    
    put outline_PathChildren(empty, tabbedOutline, pathDelim, false) into pathChildren
    repeat for each line pathChild in pathChildren
        if linkArray [pathChild] is empty then
            outline_AddToLinkArray pathChild, tabbedOutline, linkArray, pathDelim, noPath
        else
            -- beep
        end if
    end repeat
    return linkArray
end outline_ToLinkArray

on outline_AddToLinkArray startPath, tabbedOutline, @linkArray, pathDelim, noPath, alreadyDone
   -- recursive
   -- if startPath is empty then return false
    put outline_PathChildren(startPath, tabbedOutline, pathDelim, false) into pathChildren
    if pathChildren is empty then return false
    
    if noPath is not false then
        set the columndelimiter to pathDelim
        put pathChildren into childTable
        split childTable by column
        set the itemdelimiter to pathDelim
        put the number of items of startPath + 1 into columnNum
        get childTable [columnNum]
        
        put item -1 of startPath into someKey
        put it into linkArray [someKey]
    else
        put pathChildren into linkArray [startPath]
    end if
    
    set the wholematches to true
    put startPath & CR after alreadyDone
    repeat for each line pathChild in pathChildren
        if pathChild is not among the lines of alreadyDone then
            outline_AddToLinkArray pathChild, tabbedOutline, linkArray, pathDelim, noPath, alreadyDone
        else
            -- beep
        end if
    end repeat
    return true
end outline_AddToLinkArray



--> Outline | Parents
-
function outline_LineParent osLineNum, someOutline, @parentLineNum
    put outline_TabLevel(someTitle) into lastTabLevel
    repeat with parentLineNum = osLineNum down to 1
        put line parentLineNum of someOutline into someTitle
        put outline_TabLevel(someTitle) into someTabLevel
        if someTabLevel is 0 then
            return someTitle
        else if someTabLevel < lastTabLevel then
            return someTitle
        end if
    end repeat
    put 0 into parentLineNum
    return empty
end outline_LineParent


--> Outline | Children
-
function outline_ChildDuplicateNum childLineNum, outlineChildren
    put 0 into repeatNum
    put line childLineNum of outlineChildren into chosenChild
    repeat with lineNum = 1 to childLineNum
        put line lineNum of outlineChildren into someChild
        if someChild = chosenChild then
            add 1 to repeatNum
        end if
    end repeat
    return repeatNum
end outline_ChildDuplicateNum

function outline_StripLeaves tabbedOutline
    -- could be optimised up by not using filter
    
    put empty into strippedOutline
    repeat with lineNum = 1 to the number of lines of tabbedOutline
        get outline_GetChildren(lineNum, tabbedOutline)
        if it is not empty then
            put line lineNum of tabbedOutline & return after strippedOutline
        end if
    end repeat
    return strippedOutline
end outline_StripLeaves
    
command outline_AddTitle someTitle, sectionTitle, @tabbedOutline
   put outline_LineOffset (sectionTitle, tabbedOutline) into startOsLineNum
   if startOsLineNum = 0 then
      -- no match for title => create one
      -- only works for top level
      -- fix for nested levels???
      if someTitle is empty then
         line_Insert sectionTitle, tabbedOutline
      else
         put sectionTitle & CR & tab & someTitle into newLines
         line_Insert newLines, tabbedOutline
      end if
   else
      put line startOsLineNum of tabbedOutline into sectionTitleOsLine
      put outline_GetChildren(startOsLineNum, tabbedOutline) into domainIndex
      set the wholematches to true
      put lineoffset(sectionTitle, domainIndex) into lineNum
      if lineNum is 0 then
         -- so add the child title
         put outline_TabLevel(sectionTitleOsLine) + 1 into insertTabLevel
         put outline_IncreaseIndent(someTitle, insertTabLevel) into addOsLine
         put return & addOsLine after line startOsLineNum of tabbedOutline
         return true
      else
         return false
      end if
   end if
end outline_AddTitle

command outline_AddToChildren someTitle, sectionTitle, @tabbedOutline
   put outline_LineOffset(sectionTitle, tabbedOutline) into startOsLineNum
   if startOsLineNum = 0 then
      -- no match for title (leave untouched)
      return false
   end if
   put line startOsLineNum of tabbedOutline into sectionTitleOsLine
   
   put outline_GetChildren(startOsLineNum, tabbedOutline) into domainIndex
   set the wholematches to true
   put lineoffset(sectionTitle, domainIndex) into lineNum
   if lineNum is 0 then
      -- so add the child title
      put outline_TabLevel(sectionTitleOsLine) + 1 into insertTabLevel
      put outline_IncreaseIndent(someTitle, insertTabLevel) into addOsLine
      put return & addOsLine after line startOsLineNum of tabbedOutline
      return true
   else
      return false
   end if
end outline_AddToChildren

function outline_TopChildren tabbedOutline
    filter tabbedOutline without (tab & "*")
    return tabbedOutline
end outline_TopChildren
    
function outline_GetChildren startOsLineNum, tabbedOutline, pathBit
   if startOsLineNum is not a number then
      put outline_LineOffset (startOsLineNum, tabbedOutline) into startOsLineNum
   end if
   if startOsLineNum = 0 then
      filter tabbedOutline without (tab & "*")
      return tabbedOutline
   else
      put line startOsLineNum of tabbedOutline into startOsLine
      put outline_TabLevel(startOsLine) into baseTabLevel
      put baseTabLevel + 1 into domainTabLevel
      
      put empty into childLines
      repeat with lineNum = (startOsLineNum + 1) to the number of lines of tabbedOutline
         put line lineNum of tabbedOutline into osLine
         put outline_TabLevel(osLine) into tabLevel
         if tabLevel = domainTabLevel then
            -- put char (tabLevel + 1) to -1 of osLine & CR after childLines
            put pathBit & word 1 to -1 of osLine & CR after childLines
         else if tabLevel > domainTabLevel then
            next repeat
         else -- if tabLevel < domainTabLevel then
            exit repeat
         end if 
      end repeat
      delete last char of childLines
      return childLines
   end if
end outline_GetChildren

function outline_GetChildLineNums startOsLineNum, tabbedOutline
    put outline_GetChildArray(startOsLineNum, tabbedOutline) into lineNumKeyArray
    return keys(lineNumKeyArray)
end outline_GetChildLineNums

function outline_GetChildArray startOsLineNum, tabbedOutline
    if startOsLineNum = 0 then
        repeat with lineNum = 1 to the number of lines of tabbedOutline
            get line lineNum of tabbedOutline
            if char 1 of it is not tab then
                put it into lineNumKeyArray[lineNum]
            end if
        end repeat
    else
        put line startOsLineNum of tabbedOutline into startOsLine
        put outline_TabLevel(startOsLine) into baseTabLevel
         
        put empty into nextLevelTitles
        repeat with osLineNum = (startOsLineNum + 1) to the number of lines of tabbedOutline
            put line osLineNum of tabbedOutline into someOsLine
            put outline_TabLevel(someOsLine) into someTabLevel
            
            if someTabLevel = (baseTabLevel + 1) then
                -- a child node
                put someOsLine into lineNumKeyArray[osLineNum]
            else if someTabLevel <= baseTabLevel then
                -- end of section
                exit repeat
            end if
        end repeat
    end if
    return lineNumKeyArray
end outline_GetChildArray

on outline_SetChildrenOffsets nodeLineNum, @firstOsTitleLineNum, @lastOsTitleLineNum, tabbedOutline
    -- was "set_DomainOffsets"
    -- a domain is index of children that are descendent of a node
    if nodeLineNum is 0 then
        put 1 into firstOsTitleLineNum
        put the number of lines of tabbedOutline into lastOsTitleLineNum
    else
        put nodeLineNum + 1 into firstOsTitleLineNum
        put outline_NextSameLevel(nodeLineNum, tabbedOutline) into nextNode_OfSameLevel
        if nextNode_OfSameLevel is 0 then
            put the number of lines of tabbedOutline into lastOsTitleLineNum
        else
            put nextNode_OfSameLevel - 1 into lastOsTitleLineNum
        end if
    end if
end outline_SetChildrenOffsets

function outline_GetNestedChildren thisNode, tabbedOutline
    -- version original,3/3/03
    -- a domain_OutlineSection is children and all their nested children of a node
    -- could be called get_NestedChildren
     
    outline_SetChildrenOffsets thisNode, first_OsLine, last_OsLine, tabbedOutline
    put outline_TabLevel(line thisNode of tabbedOutline) + 1 into domainTabLevel
    put line first_OsLine to last_OsLine of tabbedOutline into osSection
    return osSection
end outline_GetNestedChildren

on outline_SetChildren thisNode, newDomain, @tabbedOutline
    -- version original,3/3/03
    -- a domain is index of children that are descendent of a node
     
    outline_SetChildrenOffsets thisNode, first_OsLine, last_OsLine, tabbedOutline
    put outline_TabLevel(line thisNode of tabbedOutline) + 1 into domainTabLevel
    put outline_IncreaseIndent(newDomain, domainTabLevel) into newOsSection
     
    if last_OsLine < first_OsLine then
        put return & newOsSection after line thisNode of tabbedOutline
    else
        put newOsSection into line first_OsLine to last_OsLine of tabbedOutline
    end if
end outline_SetChildren

function outline_IsAmongChildren lineToTest, someNode, tabbedOutline
    -- version domainIndex,3/3/03
    put outline_GetChildren(someNode, tabbedOutline) into domainIndex
    set the wholematches to true
    put lineoffset(lineToTest, domainIndex) into lineNum
    if lineNum is 0 then
        return false
    else
        return true
    end if
end outline_IsAmongChildren


--> Outline | Hierarchy
-
function outline_ExtractMainHierarchySection osLineNum, tabbedOutline, pathDelim
    put outline_LinePath(osLineNum, tabbedOutline, osLineNumList, pathDelim) into outlineHierarchy
    put item 1 of osLineNumList into startOsLineNum
    put outline_EndOfSection(osLineNum, tabbedOutline) into endOsLineNum
    return line startOsLineNum to endOsLineNum of tabbedOutline
end outline_ExtractMainHierarchySection

function outline_LinePath osLineNum, tabbedOutline, @osLineNumList, pathDelim
    if pathDelim is empty then put "/" into pathDelim
    put tabbedOutline into someIndex
    replace tab with empty in someIndex
    
    put empty into outlineHierarchy
    repeat with lineNum = osLineNum down to 1
        put line lineNum of tabbedOutline into tabTitle
        put line lineNum of someIndex into someTitle
        put outline_TabLevel(tabTitle) into someTabLevel
        if someTabLevel is 0 then
            -- should always really return here
            put someTitle & pathDelim before outlineHierarchy
            delete last char of outlineHierarchy
            
            put lineNum & "," before osLineNumList
            delete last char of osLineNumList
             
            return outlineHierarchy
            exit repeat
        else if someTabLevel < lastTabLevel then
            put someTitle & pathDelim before outlineHierarchy
            put lineNum & "," before osLineNumList
            put someTabLevel into lastTabLevel
        end if
    end repeat
    
    -- bit funny but i guess first line could start with a tab
    put someTitle & pathDelim before outlineHierarchy
    delete last char of outlineHierarchy
    put lineNum & "," before osLineNumList
    delete last char of osLineNumList
    return outlineHierarchy
end outline_LinePath

-- function extractOutlineHierarchy osLineNum, someOutline
    -- version latest, 10/27/00
    put empty into outlineHierarchy
    repeat with lineNum = osLineNum down to 1
        put line lineNum of someOutline into someTitle
        put outline_TabLevel(someTitle) into someTabLevel
        if someTabLevel is 0 then
            put someTitle & return before outlineHierarchy
            exit repeat
        else if someTabLevel < lastTabLevel then
            put someTitle & return before outlineHierarchy
            put someTabLevel into lastTabLevel
        end if
    end repeat
    if last char of outlineHierarchy is return then delete last char of outlineHierarchy
    return outlineHierarchy
end extractOutlineHierarchy


--> Outline | Searching
-
function outline_TabTitleOffset someTitle, tabLevel, fullOutline
    -- was "osTitleOffset"
    -- this finds a title of a given tab level
    put text_RepeatString(tab, tabLevel) & someTitle into osLine
    set the wholematches to true
    put lineoffset(osLine, fullOutline) into foundLineNum
    return foundLineNum
end outline_TabTitleOffset

function outline_EndOfSection startOsLineNum, tabbedOutline
    put line startOsLineNum of tabbedOutline into startOsLine
    put outline_TabLevel(startOsLine) into baseTabLevel
     
    add 1 to startOsLineNum
    put empty into nextLevelTitles
    repeat with osLineNum = startOsLineNum to the number of lines of tabbedOutline
        put line osLineNum of tabbedOutline into someOsLine
        put outline_TabLevel(someOsLine) into someTabLevel
        if someTabLevel < baseTabLevel then
            return (osLineNum - 1)
        end if
    end repeat
    return osLineNum
end outline_EndOfSection

function outline_NextSameLevel startOsLineNum, tabbedOutline
    -- was "nextOsTitle"
    put line startOsLineNum of tabbedOutline into startOsLine
    put outline_TabLevel(startOsLine) into baseTabLevel
     
    add 1 to startOsLineNum
    put empty into nextLevelTitles
    repeat with osLineNum = startOsLineNum to the number of lines of tabbedOutline
        put line osLineNum of tabbedOutline into someOsLine
        put outline_TabLevel(someOsLine) into someTabLevel
        if someTabLevel <= baseTabLevel then
            return osLineNum
        end if
    end repeat
    return 0
end outline_NextSameLevel


--> Outline | XML
-
/*
See also OPML section in libOPN_Data
*/

function outline_Simplify tabbedOutline, @idArray, @keyArray
    repeat for each line someLine in tabbedOutline
        put word 1 to -1 of someLine into someText
        put array_ConstructSimpleKeys(someText, idArray, keyArray) into nodeID
        put nodeID into word 1 to -1 of someLine
        put someLine & CR after simpleOutline
    end repeat
    delete char -1 of simpleOutline
    return simpleOutline
end outline_Simplify

function outline_ToXmlStructure tabbedOutline
   put outline_Simplify (tabbedOutline, idArray, keyArray) into simpleOutline
   put outline_ToXML (simpleOutline) into someXml
   put xml_Nodes (someXml) into allNodes
   
   put revCreateXMLTree (someXml, true, true, false) into treeID
   set the itemdelimiter to "/"
   repeat for each line someNode in allNodes
      revAddXMLNode treeID, someNode, "contents", "", "before"
      put the result into createdNode
      
      set the itemdelimiter to "/"
      put item -1 of someNode into attributeValue
      revSetXMLAttribute treeID, createdNode, "nodeID", attributeValue
   end repeat
   put revXMLText (treeID, "", true) into someXml
   revDeleteXMLTree treeID
   xml_TidySpace someXML
   return someXml
end outline_ToXmlStructure

function outline_ToXML tabbedOutline, propertyArray
   -- local lineNumber
   -- outline_RecurseToXML someOutline, someXml, 0, lineNumber, "Test XML"
   
   outline_ToXMLRecurse tabbedOutline, propertyArray
   put the result into treeID
   put revXMLText (treeID, "", true) into someXml
   revDeleteXMLTree treeID
   return someXml
end outline_ToXML

private command outline_ToXMLRecurse tabbedOutline, propertyArray, treeNode, treeID
   put propertyArray [treeNode] into nodeContents
   
   put "tree" into rootNode
   if treeNode is empty then
      -- can do a header here?
      xml_CreateTree rootNode, treeID
   else
      put rootNode & "/" & treeNode into someNode
      
      set the itemdelimiter to "/"
      put item -1 of someNode into nodeName
      put item 1 to -2 of someNode into parentPath
      
      put propertyArray [someNode] into nodeContents
      revAddXMLNode treeID, parentPath, nodeName, nodeContents
      put the result into createdNode
   end if
   
   put outline_PathChildren(treeNode, tabbedOutline) into childNodes
   repeat for each line childNode in childNodes
      outline_ToXMLRecurse tabbedOutline, propertyArray, childNode, treeID
   end repeat
   return treeID
end outline_ToXMLRecurse


--> Outline | Utilities
-
function outline_ConstructBranchSections someOutline, addDividers
    -- needs fixing
    local newOutline
    put addDividers is not false into addDividers
    put word 1 to -1 of someOutline into someOutline
    
    put the number of lines of someOutline into maxLine
    repeat with lineNum = 1 to (maxLine - 1)
        put line lineNum of someOutline into someLine
        
        put someLine into dividerLine
        put "-" into word 1 to -1 of dividerLine
         
        put line (lineNum+1) of someOutline into nextLine
        put outline_TabLevel(someLine) into thisTabLevel
        if outline_TabLevel(nextLine) > thisTabLevel then
            put word 1 to -1 of line -1 of newOutline = "-" into lastLineIsDivider
            if addDividers is true and lastLineIsDivider is false then put dividerLine & CR after newOutline
             
            put someLine & CR after newOutline
            put someLine & CR after newOutline
        else
            put word 1 to -1 of line -1 of newOutline = "-" into lastLineIsDivider
            -- if addDividers is true and lastLineIsDivider is false then put dividerLine & CR after newOutline
             
            put someLine & CR after newOutline
        end if
    end repeat
    put line maxLine of someOutline after newOutline
    
    if word 1 to -1 of line 1 of newOutline = "-" then delete line 1 of newOutline
    -- put newOutline
    return newOutline
 end outline_ConstructBranchSections
 
 
 --> Deps
 -
 private function text_RepeatString someString, repeatNum
   -- was "text_GetRepeatString"
   repeat repeatNum
      put someString after repeatString
   end repeat
   return repeatString
end text_RepeatString
