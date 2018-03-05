script "model_ScriptSuite"
--> MetaData
-
license: GPLv3
name: model_ScriptSuite
type: model
version: 1.0

/*
This library stores reerences to all Global script suites

It also includes wrappers that extract arrays for different types of scrupt suite.
These should be changed to store them in different nested arrays,
but for now this is one single flat array.

See also "Old | Suite" of stack "model_ScriptMenu"
*/


--> Script | Suite | Suite Array
-
/*
This suite uses the "script_ConstructArraysFromScript" handler.
*/

function script_SplitIntoSuites someScript
   script_ConstructArraysFromScript someScript, handlerArray, uniqueArray, duplicateArray
   put handlerArray ["handlerLines"] into handlerLines
   sort handlerLines by word 2 of each
   
   put line 1 of handlerLines into nextHandlerLine
   handler_Deconstruct nextHandlerLine, handlerType, handlerName, handlerPrefix, handlerSuffix
   put handlerPrefix into oHandlerPrefix
   
   put empty into bigScript
   put empty into suiteScript
   repeat
      set the cursor to busy
      put line 1 of handlerLines into nextHandlerLine
      handler_Deconstruct nextHandlerLine, handlerType, handlerName, handlerPrefix, handlerSuffix
      
      if handlerPrefix = oHandlerPrefix then
         put false into newSection
         
         script_AddNewHandler handlerType, handlerName, someScript, suiteScript
      else
         put true into newSection
         
         -- a new section, so first construct old suite and add it to end of bigScript
         put toupper(char 1 of oHandlerPrefix) into char 1 of oHandlerPrefix
         get script_ConstructSuite(oHandlerPrefix, suiteScript)
         text_AddParagraph (it & CR), bigScript, CR
         
         -- now clear suiteScript and start new section by adding new handler to suiteScript
         put handlerPrefix into oHandlerPrefix
         put empty into suiteScript
         script_AddNewHandler handlerType, handlerName, someScript, suiteScript
      end if
      
      delete line 1 of handlerLines
      if handlerLines is empty then exit repeat
   end repeat
   
   if newSection is true then
      -- suiteScript needs adding to end with a header
      
      put toupper(char 1 of oHandlerPrefix) into char 1 of oHandlerPrefix
      get script_ConstructSuite(oHandlerPrefix, suiteScript)
      text_AddParagraph (it & CR), bigScript, CR
   else
      -- suiteScript needs adding to end (no header)
      
      text_AddParagraph (suiteScript & CR), bigScript
   end if
   return word 1 to -1 of bigScript
end script_SplitIntoSuites

function script_SuiteNameLinkOutline someScript, scriptObject
   put script_GetSuiteTitles(someScript) into suiteNames
   
   -- lets get the handlers before the first suite title
   put line 1 of suiteNames into firstSuiteName
   put lineoffset(firstSuiteName, someScript) into firstLineNum
   put line 1 to (firstLineNum -1) of someScript into firstScriptBit
   script_ConstructArraysFromScript firstScriptBit, sectionArray, uniqueArray, duplicateArray, scriptObject
   put the result into noSuiteKeys
   repeat for each line hKey in noSuiteKeys
      hkey_Deconstruct hKey, handlerName, handlerType, scriptObject, handlerNum
      put html_ConstructNameLink(handlerName, hKey) & CR after handlerOutline
   end repeat
   
   repeat for each line suiteName in suiteNames
      put suiteName & CR after handlerOutline
      
      put script_GetSuite(suiteName, someScript) into suiteScript
      script_ConstructArraysFromScript suiteScript, sectionArray, uniqueArray, duplicateArray, scriptObject
      put the result into suiteKeys
      
      repeat for each line hKey in suiteKeys
         hkey_Deconstruct hKey, handlerName, handlerType, scriptObject, handlerNum
         put tab & html_ConstructNameLink(handlerName, hKey) & CR after handlerOutline
      end repeat
   end repeat
   delete last char of handlerOutline
   return handlerOutline
end script_SuiteNameLinkOutline

function script_GetSuiteOutline someScript
   -- plain outline (no html links)
   -- see "script_ExtractObjectSuiteOutline"
   -- check for private handlers
   local handlerOutline
   
   script_TrimNonSuiteHandlers someScript, nonSuiteHandlers
   if nonSuiteHandlers is not empty then
      -- put script_ExtractHkeys (nonSuiteHandlers) into hKeys
      script_ConstructArraysFromScript nonSuiteHandlers, handlerArray, uniqueArray, duplicateArray
      put handlerArray ["orderedHandlers"] into handlerOutline
   end if
   
   put script_GetSuiteTitles(someScript) into suiteNames
   repeat for each line suiteName in suiteNames
      get script_GetSuiteOrderedHandlerNames (suiteName, someScript)
      if it is empty then next repeat
      put suiteName & CR after handlerOutline
      put outline_IncreaseIndent (it, 1) & CR after handlerOutline
   end repeat
   put word 1 to -1 of handlerOutline into handlerOutline
   return handlerOutline
end script_GetSuiteOutline

function script_GetSuiteOrderedHandlerNames suiteName, someScript
   -- was "script_GetSuiteHandlers"
   put script_GetSuite (suiteName, someScript) into suiteScript
   script_ConstructArraysFromScript suiteScript, handlerArray, uniqueArray, duplicateArray, scriptObject
   
   put script_GetSectionHandlerArray (suiteName, someScript) into handlerArray
   put handlerArray ["orderedHandlers"] into handlerNames
   return handlerNames
end script_GetSuiteOrderedHandlerNames


--> ScriptSuite | Model
-
function script_GetGlobalSuiteArray 
   put lcw_FetchArray ("OPN_GlobalSuite.array") into modelArray
   return modelArray
end script_GetGlobalSuiteArray

command script_SetGlobalSuiteArray dataArray
   lcw_StoreArray "OPN_GlobalSuite.array", dataArray
end script_SetGlobalSuiteArray


--> Working on
-
/*
These script_SuiteOutline handlers are old and not needed?
*/

getprop script_ObjectSuiteOutline
   put the long id of the target into scriptObject
   put the script of scriptObject into someScript
   return script_ExtractObjectSuiteOutline (someScript, scriptObject)
end script_ObjectSuiteOutline

getprop script_SuiteOutline
   put the long id of the target into scriptObject
   put the script of scriptObject into someScript
   -- put script_SuiteNameLinkOutline (someScript, scriptObject) into someOutline
   -- put script_GetSuiteOutline (someScript) into someOutline
   put script_ExtractObjectSuiteOutline (someScript, scriptObject) into someOutline
   return someOutline
   
   return script_SuiteNameLinkOutline(someScript, scriptObject)
   return script_GetSuiteOutline(someScript)
end script_SuiteOutline

getprop script_NestedSuiteOutline [sortHeaders]
   put the long id of the target into scriptObject
   put the script of the target into someScript
   return script_ConstructNestedSuiteOutline(someScript, scriptObject, sortHeaders)
end script_NestedSuiteOutline

function script_ExtractObjectSuiteOutline someScript, scriptObject
   -- creates hKeyLinks
   local handlerOutline
   
   script_TrimNonSuiteHandlers someScript, nonSuiteHandlers
   if nonSuiteHandlers is not empty then
      put script_ExtractHkeys (nonSuiteHandlers, scriptObject) into hKeys      
      repeat for each line hKey in hKeys
         put item 1 of hKey into handlerName
         put html_ConstructNameLink (handlerName, hKey) & CR after handlerOutline
      end repeat
   end if
   
   put script_GetSuiteTitles (someScript) into suiteNames
   repeat for each line suiteName in suiteNames
      put script_GetSuite(suiteName, someScript) into suiteScript
      put script_ExtractHkeys (suiteScript, scriptObject) into hKeys
      
      put suiteName & CR after handlerOutline
      repeat for each line hKey in hKeys
         put item 1 of hKey into handlerName
         put tab & html_ConstructNameLink(handlerName, hKey) & CR after handlerOutline
      end repeat
   end repeat
   delete last char of handlerOutline
   
   if line 1 of handlerOutline = "Metadata" then
      put the object_MetaDataTable ["script_Help"] of scriptObject into metaDataTable
      
      put script_GetMetadataArray(someScript) into metaDataTable
      delete local metaDataTable ["script_Help"]
      combine metaDataTable with CR and tab
      
      replace tab with ": " in metaDataTable
      put outline_IncreaseIndent (metaDataTable) & CR before line 2 of handlerOutline
   end if
   
   return handlerOutline
end script_ExtractObjectSuiteOutline

getprop object_MetaDataTable [keysToRemove]
   breakpoint
    put the long id of the target into scriptObject
    put the object_MetaData of scriptObject into metaDataArray
    repeat for each item someKey in keysToRemove
        delete local metaDataArray [someKey]
    end repeat
    combine metaDataArray with CR and tab
    return metaDataArray
end object_MetaDataTable


--> Script | Suit | Props
-
getprop script_GlobalTitles [suiteType]
   put the script of the target into someScript
   put script_ExtractGlobalTitles (someScript, suiteType) into globalMenuTitles
   return globalMenuTitles
end script_GlobalTitles

getprop script_SuiteTitles
   put the script of the target into someScript
   return script_GetSuiteTitles (someScript)
end script_SuiteTitles

getprop script_SortedSuite [suiteName]
   put the script_Suite [suiteName] of the target into someScript
   put script_SortHandlers(someScript) into sortedHandlers
   put script_ConstructSuite(suiteName, sortedHandlers) into sortedSuite
   return sortedSuite
end script_SortedSuite

setprop script_Suite [suiteName] newSuite
   put the long id of the target into targetObject
   
   put the script of targetObject into someScript
   put script_ReplaceSuite (suiteName, someScript, newSuite) into newScript
   set the script of targetObject to newScript
end script_Suite


--> Script | Suites
-
function script_GetSuite suiteTitle, someScript
   script_SetSuiteOffsets suiteTitle, someScript, startLineNum, endLineNum
   if the result is true then
      put line startLineNum to endLineNum of someScript into suiteScript
      return word 1 to -1 of suiteScript
   else
      return empty
   end if
end script_GetSuite

function script_GetSuiteHandlers suiteTitle, someScript
    get script_GetSuite (suiteTitle, someScript)
    delete line 1 to 2 of it
    return word 1 to -1 of it
end script_GetSuiteHandlers

function script_GetSuiteContents suiteTitle, someScript
    put script_GetSuite (suiteTitle, someScript) into scriptSuite
    delete line 1 of scriptSuite
    switch char 1 of line 1 of scriptSuite
        case "-"
            delete line 1 of scriptSuite
            break
        case empty
            delete line 1 of scriptSuite
            break
    end switch
    return word 1 to -1 of scriptSuite
end script_GetSuiteContents

function script_GetSuiteTitles someScript
    put someScript into theHandlerGroups
    filter theHandlerGroups with "-->*"
    replace "--> " with empty in theHandlerGroups
    replace "-->" with empty in theHandlerGroups
    return theHandlerGroups
end script_GetSuiteTitles

function script_DeleteSuite suiteTitle, someScript
    script_SetSuiteOffsets suiteTitle, someScript, startLineNum, endLineNum
    if the result is true then
        delete line startLineNum to endLineNum of someScript
        return someScript
    else
        return someScript
    end if
end script_DeleteSuite
 
function script_ReplaceSuite suiteTitle, someScript, newSuite
    script_SetSuiteOffsets suiteTitle, someScript, startLineNum, endLineNum
    if the result is true then
        put word 1 to -1 of newSuite & CR & CR into line startLineNum to endLineNum of someScript
        return someScript
    else
        text_AddParagraph newSuite, someScript
        return someScript
    end if
end script_ReplaceSuite

command script_SetSuiteOffsets suiteTitle, someScript, @startLineNum, @endLineNum
    set wholematches to true
    put 0 into startLineNum
    put 0 into endLineNum
    put lineoffset("-->" &&  suiteTitle, someScript) into startLineNum
    if startLineNum is zero then
        put lineoffset("-->" &  suiteTitle, someScript) into startLineNum
    end if
    if startLineNum is zero then return false
    
    put someScript into suiteTitleLines
    filter suiteTitleLines with "-->*"
    put lineoffset("-->" &&  suiteTitle, suiteTitleLines) into titleLineNum
    put line titleLineNum + 1 of suiteTitleLines into nextTitleLine
    if nextTitleLine is empty then
        put the number of lines in someScript into endLineNum
    else
        put lineoffset(nextTitleLine, someScript, startLineNum) into afterStartlineNum
         
        if afterStartlineNum is zero then
            put the number of lines in someScript into endLineNum
        else
            put startLineNum + afterStartlineNum - 1 into endLineNum
        end if
    end if
    return true
end script_SetSuiteOffsets


--> Script  | Suite
-
function script_GetGlobalMenuArray
   put script_ExtractGlobalSuiteArray ("Menu") into menuArray
   return menuArray
end script_GetGlobalMenuArray

function script_GetGlobalControllerArray
   return script_ExtractGlobalSuiteArray("Controller")
end script_GetGlobalControllerArray

function script_GetGlobalModelNames
   return script_GetGlobalSuiteTitles("Model")
end script_GetGlobalModelNames


--> Script  | Suite | Titles
-
function script_ExtractGlobalTitles someScript, suiteType
   put script_GetSuiteTitles (someScript) into suiteTitles
   put "Global | *" into someFilter
   if suiteType is not empty then put space & "|" && suiteType after someFilter
   filter suiteTitles with someFilter
   return suiteTitles
end script_ExtractGlobalTitles

function script_GetGlobalSuiteTitles suiteType
   get script_ExtractGlobalSuiteArray (suiteType)
   put keys(it) into suiteTitles
   sort suiteTitles
   return word 1 to -1 of suiteTitles
end script_GetGlobalSuiteTitles

function script_GetGlobalSuiteObjects suiteType
   local globalSuiteObjects
   put script_ExtractGlobalSuiteArray (suiteType) into dataArray
   repeat for each element someObject in dataArray
      line_Add someObject, globalSuiteObjects
   end repeat
   return globalSuiteObjects
end script_GetGlobalSuiteObjects


--> Script  | Suite | Model
-
function script_GetGlobalModelArray
   return script_ExtractGlobalSuiteArray("Model")
end script_GetGlobalModelArray


--> Script  | Suite | Model (extract)
-
function script_GetGlobalModelObject modelName
    put script_ExtractGlobalSuiteArray("Model") into dataArray
    put dataArray [modelName] into someObject
    return someObject
end script_GetGlobalModelObject

function script_ExtractGlobalSuiteArray suiteType
    local newArray
    put script_GetGlobalSuiteArray() into dataArray
    
    if suiteType is empty then return dataArray
    repeat for each key suiteTitle in dataArray
        if word -1 of suiteTitle is suiteType then
            put dataArray [suiteTitle] into newArray [suiteTitle]
        end if
    end repeat
    return newArray
end script_ExtractGlobalSuiteArray


--> Script  | Suite | Model
-
function script_GetGlobalObject suiteTitle
   put script_GetGlobalSuiteArray() into dataArray
   return dataArray [suiteTitle]
end script_GetGlobalObject

command script_SetGlobalObject suiteTitle, scriptObject
   put script_GetGlobalSuiteArray() into dataArray
   if suiteTitle is empty then return "Error: suiteTitle is empty"
   if exists(scriptObject) then
      put the rugged_ID of scriptObject into scriptObject
      put scriptObject into dataArray [suiteTitle]
      script_SetGlobalSuiteArray dataArray
      return true
   else
      delete local dataArray [suiteTitle]
      script_SetGlobalSuiteArray dataArray
      return false
   end if
end script_SetGlobalObject


function script_ConstructSuite suiteName, suiteScript
   put word 1 to -1 of suiteScript into suiteScript
   put script_ConstructSuiteHeader(suiteName) & CR & suiteScript into scriptSuite
   return scriptSuite
end script_ConstructSuite

function script_ConstructSuiteHeader suiteName
   put "-->" && suiteName into suiteHeader
   put cr & "-" after suiteHeader
   return suiteHeader
end script_ConstructSuiteHeader

function script_GetSuiteTitles someScript
   filter someScript with "-->*"
   replace "--> " with empty in someScript
   replace "-->" with empty in someScript
   return word 1 to -1 of someScript
end script_GetSuiteTitles

function script_GetSuiteHelp suiteScript
   set the wholematches to false
   put lineoffset("/*", suiteScript) into startLineNum
   if startLineNum is zero then return empty
   put lineoffset("*/", suiteScript, startLineNum) into skipEnd
   if skipEnd is zero then return empty
   
   put skipEnd + startLineNum into endLineNum
   put line startLineNum to endLineNum of suiteScript into suiteHelp
   return word 1 to -1 of suiteHelp
end script_GetSuiteHelp

function stripHandlersFromSuite handlersToStrip, suiteScripts
   -- version original,6/9/01
   put line 1 of handlersToStrip into oldCommandNames
   put line 2 of handlersToStrip into oldFunctionNames
   
   put andLists(newCommandNames, oldCommandNames) into commandsToRemove
   repeat with ii = 1 to the number of items of commandsToRemove
      put item ii of commandsToRemove into someCommandName
      put replaceCommand(someCommandName, suiteScripts) into suiteScripts
   end repeat
   
   put andLists(newFunctionNames, oldFunctionNames) into functionsToRemove
   repeat with ii = 1 to the number of items of functionsToRemove
      put item ii of functionsToRemove into functionName
      put replaceFunction(functionName, suiteScripts) into suiteScripts
   end repeat
   return suiteScripts
end stripHandlersFromSuite


--> Script | Suite | Outline
-
function script_ConstructNestedSuiteOutline someScript, scriptObject, sortHeaders
   -- slow ugly hack
   -- does not return suites in exactly the same order as they are found when unsorted
   
   put tab into someDelim
   put script_GetSuiteTitles(someScript) into suiteNames
   
   -- lets get the handlers before the first suite title
   put line 1 of suiteNames into firstSuiteName
   put lineoffset(firstSuiteName, someScript) into firstLineNum
   put line 1 to (firstLineNum -1) of someScript into firstScriptBit
   
   put script_ExtractHkeys(firstScriptBit, scriptObject) into noSuiteKeys
   repeat for each line hKey in noSuiteKeys
      hkey_Deconstruct hKey, handlerName, handlerType, scriptObject, handlerNum
      put html_ConstructNameLink(handlerName, hKey) & CR after handlerOutline
   end repeat
   
   repeat for each line suiteName in suiteNames
      put script_GetSuite(suiteName, someScript) into suiteScript
      put script_ExtractHkeys(suiteScript, scriptObject) into hKeys
      
      put script_SuiteNameToPath(suiteName, someDelim) into suitePath
      repeat for each line hKey in hKeys
         put item 1 of hKey into handlerName
         put suitePath & someDelim & html_ConstructNameLink(handlerName, hKey) & CR after handlerPaths
      end repeat
   end repeat
   delete last char of handlerPaths
   
   if sortHeaders is true then sort handlerPaths
   put outline_FromPathIndex(handlerPaths, someDelim) after handlerOutline
   return handlerOutline
end script_ConstructNestedSuiteOutline


--> Script | Suite 
-
function script_SuiteNameToPath suiteName, someDelim
   if someDelim is emty then put "/" into someDelim
   set the itemdelimiter to "|"
   repeat for each item pathBit in suiteName
      put word 1 to -1 of pathBit & someDelim after suitePath
   end repeat
   delete char -1 of suitePath
   return suitePath
end script_SuiteNameToPath

command script_TrimNonSuiteHandlers @someScript, @nonSuiteHandlers
   put CR before someScript
   put empty into nonSuiteHandlers
   put offset (CR & "-->", someScript) into lastChar
   if lastChar = 0 then
      -- not suites
      put someScript into nonSuiteHandlers
      delete char 1 of nonSuiteHandlers
      put empty into someScript
      return false
   end if
   
   get char 2 to lastChar of someScript
   put word 1 to -1 of it into nonSuiteHandlers
   
   delete char 1 to lastChar of someScript
   put word 1 to -1 of someScript into someScript
   return true
end script_TrimNonSuiteHandlers


-->Private
-
-- function script_AddHandlerToSuite suiteTitle, someScript, newHandler
-- not finished (tricky one)
    put word 1 to -1 of newHandler into newHandler
    put line 1 of newHandler into handlerLine
    handler_Deconstruct handlerLine, handlerName, hType, privateBit
    script_SetHandlerOffsets startFirstFunction, endFirstFunction, ".+", "function", someScript
     
    put script_GetSuite(suiteTitle, someScript) into oldSuite
    text_AddParagraph newHandler, someScript
end script_AddHandlerToSuite

private function addSuiteScripts suiteName, suiteScripts, oldObjectScript, scriptHierachy
   -- not currently used ?
   -- version addSuiteScripts 8.9
   put getHandlerNames(oldObjectScript) into handlersToStrip
   -- remove all handlers from suite that are in the objects script
   put stripHandlersFromSuite(handlersToStrip, suiteScripts) into suiteScriptsToPaste
   
   if scriptHierachy <> empty then
      repeat with ii = 1 to then number of lines of scriptHierachy
         put line ii of scriptHierachy into scriptHierachyObject
         put the script of scriptHierachyObject into usedObjectScript
         put getHandlerNames(usedObjectScript) into handlersToStrip
         -- remove all handlers from suite that are in the objects script
         put stripHandlersFromSuite(handlersToStrip, suiteScriptsToPaste) into suiteScriptsToPaste
      end repeat
   end if
   
   -- don't overwrite suite script add them
   put getScriptSection(suiteName, oldObjectScript) into oldSuiteScripts
   if oldSuiteScripts <> empty then
      put addHandlersToSuite(oldSuiteScripts, suiteScriptsToPaste) into suiteScriptsToPaste
   end if
   put replaceScriptSection(suiteName, oldPasteObjectScript, suiteScriptsToPaste) into newPasteObjectScripts
   return newPasteObjectScripts
end addSuiteScripts

function addHandlersToSuite scriptsToAdd, suiteScripts
   -- not currently used ?
   -- version original,6/9/01
   put getHandlerNames(scriptsToAdd) into handlerNames
   put line 1 of handlerNames into commandsToAdd
   put line 2 of handlerNames into functionsToAdd
   
   repeat with ii = 1 to the number of items of commandsToAdd
      put item ii of commandsToAdd into newCommandName
      put script_GetCommand(newCommandName, scriptsToAdd) into newCommand
      put replaceCommand(newCommandName, suiteScripts, newCommand) into suiteScripts
   end repeat
   
   repeat with ii = 1 to the number of items of functionsToAdd
      put item ii of functionsToAdd into newFunctionName
      put script_GetFunction(newFunctionName, scriptsToAdd) into newFunction
      put replaceCommand(newFunctionName, suiteScripts, newFunction) into suiteScripts
   end repeat
   return suiteScripts
end addHandlersToSuite
