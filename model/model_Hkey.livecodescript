script "model_Hkey"
--> MetaData
-
license: GPLv3
name: model_Hkey
type: model
version: 0.8


/*
A model for indexing handlers.
*/


--> Hkey
-
function hkey_Construct hName, hType, hObject, pHandlerNum
   if exists (hObject) then
      put revRuggedID (hObject) into hObject
   else
      put "Missing" into hObject	# could add scriptObject info ??? 
   end if
   if pHandlerNum is empty then put 1 into pHandlerNum
   return hName,hType,hObject,pHandlerNum
end hkey_Construct

command hkey_Deconstruct hKey, @hName, @hType, @hObject, @hNum
   put word 1 to -1 of item 1 of hKey into hName
   put word 1 to -1 of item 2 of hKey into hType
   if hType is empty then put "c" into hType
   put word 1 to -1 of item 3 of hKey into hObject
   put item 4 of hKey into hNum
end hkey_Deconstruct


--> Script | scriptLine
-
function hkey_GetScriptLine hKey, pHandler
   switch
      case pHandler is not empty
         return line 1 of pHandler
      case the number of items of hKey = 2
         put library_FetchHandler (hKey) into pHandler
         return line 1 of pHandler
      case the number of items of hKey = 4
         put hkey_ExtractHandlerFromObject (hKey) into pHandler
         return line 1 of pHandler
   end switch
   return empty
end hkey_GetScriptLine

function hkey_ScriptLineNum hKey, someScript
   hkey_FindScriptLine hKey, someScript, scriptLine, lineNum
   return lineNum
end hkey_ScriptLineNum

function hkey_ScriptLine hKey, someScript
   hkey_FindScriptLine hKey, someScript, scriptLine, lineNum
   return scriptLine
end hkey_ScriptLine

command hkey_FindScriptLine hKey, someScript, @scriptLine, @lineNum
   put word 1 to -1 of someScript into someScript
   script_ExtractAndStripMultiLineComments someScript, mulitLineComment
   put script_StripComments (someScript) into someScript
   
   put someScript into testScript
   put text_StripQuoted (testScript, "•••") into testScript
   
   hkey_Deconstruct hKey, hName, hType, scriptObject, hNum
   put empty into scriptLine
   put 0 into lineNum
   put 0 into lastWordNum
   repeat
      put wordoffset (hName, testScript, lastWordNum) into wordNum
      if wordNum = 0 then return false
      
      get testScript
      delete word (wordNum + lastWordNum + 1) to -1 of it
      put the number of lines of it into lineNum
      put word 1 to -1 of line lineNum of someScript into scriptLine
      
      switch hType
         case "g"
            if word (wordNum - 1) of someScript = "the" then return true
         case "s"
            if word (wordNum - 1) of someScript = "the" then return true
         case "c"
            if hName = token 1 of scriptLine then return true
         case "f"
            put someScript into testFunctionScript
            delete word 1 to (wordNum + lastWordNum) of testFunctionScript
            if token 1 of testFunctionScript = "(" then return true
         case "m"
            if hName = token 1 of scriptLine then return true
      end switch
      put empty into scriptLine
      put 0 into lineNum
      put wordNum into lastWordNum
   end repeat
   return false
end hkey_FindScriptLine


--> Hkey | Files
-
function hkey_HandlerFile hKey, pDontCreate
   return hkey_Folder (hKey, pDontCreate) & "script.txt"
end hkey_HandlerFile

function hkey_CallsFile hKey, pDontCreate
   return hkey_Folder (hKey, pDontCreate) & "links.txt"
end hkey_CallsFile

function hkey_ArrayFile hKey, pDontCreate
   return hkey_Folder (hKey, pDontCreate) & "overlaydata.array"
end hkey_ArrayFile

function hkey_DotFile hKey, pVersionName, pDontCreate
   hkey_NormalizeGraphName pOverlayName
   put pOverlayName & "." & "dot" into shortFile
   return hkey_Folder (hKey, pDontCreate) & shortFile
end hkey_DotFile

function hkey_CmapxFile hKey, pOverlayName, pDontCreate
   hkey_NormalizeGraphName pOverlayName
   put pOverlayName & "." & "cmapx" into shortFile
   return hkey_Folder (hKey, pDontCreate) & shortFile
end hkey_CmapxFile

function hkey_ImageFile hKey, pOverlayName, pDontCreate
   hkey_NormalizeGraphName pOverlayName
   put pOverlayName & "." & "png" into shortFile
   return hkey_Folder (hKey, pDontCreate) & shortFile
end hkey_ImageFile

function hkey_HelpFile hKey, pDontCreate
   return hkey_Folder (hKey, pDontCreate) & "help.html"
end hkey_HelpFile


--> Hkey | Folders
-
/*
These handlers refer to the permanent fixed shared location of the files in hkey handler database.
*/

function hkey_Folder hKey, pDontCreate
   if the number of items of hKey = 4 and item 3 of hKey is not "Missing" then
      put item 3 of hKey into hObject
      put the object_Folder of hObject into objectFolder
      put objectFolder_HandlerFolder (hKey, objectFolder, pDontCreate) into hkeyFolder
   else
      put library_HkeyFolder (hKey, pDontCreate) into hkeyFolder
   end if
   return hkeyFolder
end hkey_Folder

command hkey_DeconstructFolder scriptFolder, @shortHkey, @versionName
   set the itemdelimiter to "/"
   get item -1 of scriptFolder
   
   put word 1 of it into shortFolder
   put word 2 of it into versionName
   
   set the itemdelimiter to "_"
   put item 1 to -2 of shortFolder into handlerName
   put item -1 of shortFolder into handlerType
   put handlerName,handlerType into shortHkey
end hkey_DeconstructFolder

function hkey_FromFolder someFolder
   set the itemdelimiter to "/"
   put item - 1 of someFolder into shortFolder
   put hkey_FromShortFolder (shortFolder) into shortHkey
   return shortHkey
end hkey_FromFolder

function hkey_FromShortFolder shortFolder
   put word 1 of shortFolder into handlerInfo
   
   set the itemdelimiter to "_"
   put item -1 of handlerInfo into handlerType
   put item 1 to -2 of handlerInfo into handlerName
   
   set the itemdelimiter to comma
   if handlerType is not among the items of "g,s,c,f,m,pg,ps,pc,pf" then return empty
   return handlerName,handlerType
end hkey_FromShortFolder

function hkey_FolderName hKey
   put item 1 of hKey into hName
   put item 2 of hKey into hType
   if hType = "o" then put "c" into hType -- as "on" and "command" are functionally equivalent
   put hName & "_" & tolower (hType) into folderName
   return folderName
end hkey_FolderName


--> Hkey | Files
-
function hkey_Files hKey, pVersionName
   put library_HandlerFile (hKey, empty, true) into someFolder
   put folder_ShortFiles (someFolder) into someFiles
   return someFiles
end hkey_Files

function hkey_ImageMapPngs hKey, pVersionName
   put hkey_Files (hKey, pVersionName) into somePngs
   filter somePngs with "*.png"
   return somePngs
end hkey_ImageMapPngs

function hkey_GraphFiles hKey, pOverlayName, pVersionName
   put library_HandlerFile (hKey, empty, true) into dotFolder
   overlay_Files dotFolder, dotFile, imageFile, cmapFile, xdotFile, dotArrayFile, pOverlayName
   put dotFile,imageFile,cmapFile,xdotFile,dotArrayFile,pOverlayName into someFiles
   replace comma with  CR in someFiles
   return someFiles
end hkey_GraphFiles


--> Hkey | Files | Delete
-
command hkey_DeleteArrayFile hKey
   put hkey_ArrayFile (hKey) into someFile
   delete file someFile
end hkey_DeleteArrayFile

command hkey_DeleteDotFile hKey
   put hkey_DotFile (hKey) into someFile
   delete file someFile
end hkey_DeleteDotFile

command hkey_DeleteImageMapPngs hKey
   put hkey_ImageMapPngs (hKey) into someFiles
   repeat for each line someFile in someFiles
      delete file someFile
   end repeat
end hkey_DeleteImageMapPngs

command hkey_DeleteImageFile hKey, pGraphStyle
   put hkey_ImageFile (hKey, pGraphStyle) into someFile
   delete file someFile
end hkey_DeleteImageFile

command hkey_DeleteHandlerFile hKey
   put hkey_HandlerFile (hKey) into someFile
   delete file someFile
end hkey_DeleteHandlerFile

command hkey_DeleteHelpFile hKey
   put hkey_HelpFile (hKey) into someFile
   delete file someFile
end hkey_DeleteHelpFile


--> Hkey | Data
-
function hkey_ListShortFolders
   put library_PluginFolder ("opn_Text/rev/handlers/") into helpFolder
   put the defaultfolder into oFolder
   set the defaultfolder to helpFolder
   put the folders into tFolders
   filter tFolders without ".*"
   set the defaultfolder to oFolder  
   return tFolders
end hkey_ListShortFolders 

function hkey_ListShortVersionFolders hKey
   local versionNames
   put hkey_ListShortFolders() into shortFolders
   
   put hkey_FolderName (hKey) into folderName
   filter shortFolders with (folderName & " *")
   return shortFolders
end hkey_ListShortVersionFolders

function hkey_ListVersionNames hKey
   put hkey_ListShortVersionFolders (hKey) into shortFolders
   repeat for each line shortFolder in shortFolders
      put word 2 to -1 of shortFolder & CR after versionNames
   end repeat
   delete char -1 of versionNames
   return versionNames
end hkey_ListVersionNames


--> Hkey | Handler
-
function library_FetchHandler hKey
   put hkey_HandlerFile (hKey) into someFile
   put url ("binfile:" & someFile) into someHandler
   hack_UpdateBinFile someHandler, someFile
   return someHandler
end library_FetchHandler

command hkey_StoreHandler hKey, someHandler
   put hkey_HandlerFile (hKey, false) into someFile
   if someHandler is empty then
      delete file someFile
   else
      put someHandler into url ("binfile:" & someFile)
   end if
end hkey_StoreHandler


--> hkey | Handler | Export and Import
-
command hkey_Export hKey, pHandler
   -- exports basic info (the handler and the short hKey calls) from an objects script
   if pHandler is empty then
      put item 3 of hKey into hObject
      if exists (hObject) is false then
         put library_FetchHandler (hKey) into pHandler
      else
         put the script_Handler [hKey] of hObject into pHandler
      end if
   end if
   if pHandler is empty then return empty
   
   library_AddHkey hKey, pHandler
   put the result into hKeyData
   return hKeyData
end hkey_Export


--> Handler | Is
-
function handler_IsComponent someHandler
   -- this uses regular expression (http://www.regextester.com/pregsyntax.html)
   -- may be faster way of checking
   put "--\s*component\s*:\s*true\b" into someReg
   put matchtext (someHandler, someReg) into someBoolean
   return someBoolean
end handler_IsComponent


--> Hkey | MetaData | DotText
-
function hkey_GetDotText hKey, pVersionName
   put hkey_DotFile (hKey, pVersionName) into someFile
   get url ("file:" & someFile) into encodedArray
   return it
end hkey_GetDotText

command hkey_SetDotText hKey, dotText, pVersionName
   put hkey_DotFile (hKey, pVersionName) into someFile
   put dotText into url ("file:" & someFile)
end hkey_SetDotText


--> Hkey | MetaData | Image
-
function hkey_GetImage hKey, pGraphStyle
   put hkey_ImageFile (hKey, pGraphStyle) into someFile
   get url ("binfile:" & someFile)
   return it
end hkey_GetImage

command hkey_SetImage hKey, imageFile, pGraphStyle
   put hkey_ImageFile (hKey, pGraphStyle) into someFile
   put imageFile into url ("binfile:" & someFile)
end hkey_SetImage


--> Hkey | Help
-
function hkey_FetchHelp hKey
   put hkey_HelpFile (hKey, true) into someFile
   put url ("file:" & someFile) into helpText
   hack_UpdateBinFile helpText, someFile
   return helpText
end hkey_FetchHelp

command hkey_StoreHelp hKey, helpText
   put hkey_HelpFile (hKey, false) into someFile
   if helptext is empty then
      delete file someFile
   else
      put helpText into url ("binfile:" & someFile)
   end if
   return someFile
end hkey_StoreHelp


--> Handler | Calls | Old
-
function hkey_ExtractCalls hKey, pSetName
   breakPoint -- old
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   if exists (hObject) is false then return empty
   
   put the script_Handler [hKey] of hObject into someHandler
   put handler_ExtractCalls (someHandler) into shortCalls
   put hkey_ShortToLongCalls (shortCalls, hObject, pSetName) into longHkeyCalls
   return longHkeyCalls
   
   -- old "hkey_ExtractCalls hKey, pIncludePass, pEnvironmentFilter"
   put the hkey_SearchHierarchy of hObject into scriptHierarchy
   put script_ParseHandlerForCalls (someHandler, scriptHierarchy, hObject) into handlerCalls
   
   if pIncludePass is not true then return handlerCalls
   
   -- now lets look for message passing
   if script_HandlerContainsPass (hName, someHandler) is true then
      put the hkey_SearchHierarchy [pEnvironmentFilter] of hObject into passHierarchy
      put hkey_SearchObjectHierarchy (hKey, passHierarchy) into foundHierarchy
      
      put line -1 of foundHierarchy into passObject
      put hkey_Construct (hName, hType, passObject) into pKey
      line_Insert pKey, handlerCalls
   end if
   return handlerCalls
end hkey_ExtractCalls

/*
Old and dodgy handlers that try to follow getprop and setprop references to objects (not used anymore?)
*/

function hkey_ConstructPropertyCall linkCall, linkName, linkType, linkObject, linkNum, someHandler
   -- total hack !!!
   put script_GetPropertyTarget (linkName, someHandler, someObject) into propertyTarget
   if exists (propertyTarget) is false then
      put "script_GetPropertyTarget" && linkName & "," && someObject into someError
      opn_Notify someError, true
      put someObject into propertyTarget -- total hack !!!
   end if
   
   -- now find property linkName in the hkey_SearchHierarchy of propertyTarget
   put hkey_Construct (linkName, linkType, propertyTarget, linkNum) into testKey
   put the hkey_InHierarchy [testKey] of propertyTarget into propertyHandlerObject
   
   if exists (propertyHandlerObject) is false then
      -- it is a plain custom property
      put propertyTarget into propertyHandlerObject 
      put "Custom property of" && propertyHandlerObject into missingPropertyCall
      put hkey_Construct (linkName, linkType, missingPropertyCall, linkNum) into linkCall
   else
      -- we have found a custom property handler in the hierarchy
      -- not sure how but should mark property as plain custom property (not handled by a custom handler)
      put hkey_Construct (linkName, linkType, propertyHandlerObject, linkNum) into linkCall
   end if
   return linkCall
end hkey_ConstructPropertyCall

-- getprop hkey_Calls [hKey]
put the long id of the target into scriptObject
put hkey_FindAndExtractCalls (hKey, scriptObject) into handlerCalls
return handlerCalls
end hkey_Calls

function script_ParseHandlerForCalls someHandler, scriptHierarchy, someObject
   put empty into allCalls
   put someHandler into oHandler
   script_CleanForCalls someHandler -- clean and remove first and last lines
   
   repeat for each line someLine in someHandler
      set the itemdelimiter to "#"
      put word 1 to -1 of item 1 of someLine into someLine
      if char 1 to 2 of someLine is "--" then next repeat
      
      put token 1 of someLine into testComand
      if testComand is empty then next repeat
      
      if script_DictionaryTerm (testComand) is false then
         script_AddToExtractCalls testComand, "c", scriptHierarchy, allCalls
      end if
      
      put script_ExtractFunctionCalls (someLine, false) into fNames
      -- script_ExtractFunctionCallOfLine someLine, fName, bracketedStuff
      -- if fName is "(" then breakpoint
      script_AddToExtractCalls fNames, "f", scriptHierarchy, allCalls
      
      set the wholematches to true
      -- could still have other stufff on line
      put wordoffset ("the", someLine) into wordNum
      if wordNum is 0 then next repeat
      
      put word (wordNum + 1) of someLine into handlerName
      -- get word (wordNum + 1) to -1 of someLine
      -- put token 1 of it into handlerName
      if script_DictionaryTerm (handlerName) is true then next repeat
      
      -- now check getprop / setprop calls
      -- "the xxx [zzz] of"  (should change to use tokens)
      put wordNum + 2 into ofWordNum
      get word ofWordNum of someLine
      if it contains "[" then
         put wordNum + 5 into ofWordNum
         get word ofWordNum of someLine
      end if
      if it is "of" then
         put word (wordNum - 1) of someLine into setGetPut
         put scriptHierarchy into sendHierarchy -- default
         
         -- Here we can "try" to work out which object is being called
         put word (ofWordNum + 1) of someLine into objectWord
         if script_DictionaryTerm(objectWord) is true then
            -- probably "stack,background,group etc
            -- give up for now
         else
            -- lets assume it is a customproperty
            -- find the line which defines the object objectWord int the handler
            script_ExtractPutTheInto someHandler, objectWord, objectReference, targetObject
            if objectReference is empty then
               opn_Notify ("Can't find reference for object" && kwote(objectWord))
            else
               if targetObject is among the items of "me,target" then put someObject into targetObject
               
               if exists(targetObject) is false then
                  opn_Notify someHandler
               else
                  put the objectReference of targetObject into sendObject
                  if exists(sendObject) then
                     put the hkey_SearchHierarchy of sendObject into sendHierarchy
                  end if
               end if
            end if
         end if
         
         if setGetPut is "set" and "to" is among the words of someLine then
            script_AddToExtractCalls handlerName, "s", sendHierarchy, allCalls
         else -- if setGetPut is among the items of "case,if,get,put" then
            script_AddToExtractCalls handlerName, "g", sendHierarchy, allCalls
         end if
      end if
   end repeat
   
   -- sort allCalls
   return allCalls
end script_ParseHandlerForCalls

command script_AddToExtractCalls handlerNames, handlerType, scriptHierarchy, @allCalls
   put false into notPrivate -- bug! Need to change so it only searches objects script for private
   repeat for each line handlerName in handlerNames
      if scriptHierarchy is empty then
         put handlerName,handlerType into hKey
      else
         put hkey_SearchHierarchy (handlerName, handlerType, scriptHierarchy, notPrivate) into hKey
      end if
      line_Add hKey, allCalls
   end repeat
end script_AddToExtractCalls

function script_ExtractFunctionCalls scriptLine, pIncludeBuiltinFunctions
   local fNames
   
   put text_StripQuoted (scriptLine) into scriptLine
   -- put "(\w+)\s*" & "\((.*)\)" into greedyExpression -- error with handlers that use "." notation
   -- if matchtext(scriptLine, greedyExpression, wordBefore, bracketedStuff) is true then
   
   put "\((.*)\)" into bracketExpression
   if matchchunk (scriptLine, bracketExpression, startBracketedStuff, endBracketedStuff) is true then
      put char startBracketedStuff to endBracketedStuff of scriptLine into bracketedStuff
      get char 1 to (startBracketedStuff - 1) of scriptLine
      put token -2 of it into wordBefore
      if wordBefore is among the chars of "[()]" then
         -- hack
         put empty into wordBefore
      end if
      
      if bracketedStuff contains "(" then
         put script_ExtractFunctionCalls (bracketedStuff, pIncludeBuiltinFunctions) into innerFunctions
         
         if pIncludeBuiltinFunctions is true then
            repeat for each line innerFunction in innerFunctions
               line_Add innerFunction, fNames
            end repeat
         else
            repeat for each line innerFunction in innerFunctions
               if script_DictionaryTerm(innerFunction) is false then
                  line_Add innerFunction, fNames
               end if
            end repeat
         end if
      end if
      
      if wordBefore is not empty then
         if pIncludeBuiltinFunctions is true then
            line_Add wordBefore, fNames
         else
            if script_DictionaryTerm (wordBefore) is false then
               line_Add wordBefore, fNames
            end if
         end if
      end if
      return word 1 to -1 of fNames
   else
      return empty
   end if
end script_ExtractFunctionCalls


--> Overlay | Hkey | Links
-
/*
These handler extract links (calls) from the general link array used in graphing.
Don't use unless for graphing.
*/


function overlay_GetHkeyLinks hKey, pOverlayName
   put hkey_GetLinkArray (hKey, pOverlayName) into hkeyArray
   put hkeyArray [hKey] into hKeyCalls
   return hKeyCalls
end overlay_GetHkeyLinks

command overlay_SetHkeyLinks hKey, hKeyCalls, pOverlayName
   put hkey_GetLinkArray (hKey, pOverlayName) into hkeyArray
   put hKeyCalls into hkeyArray [hKey]
   hkey_SetLinkArray hKey, hkeyArray, pOverlayName
   return hkeyArray
end overlay_SetHkeyLinks


--> hkey | Model | BackLinks
-
/*
Probably better done with a live database, rather than this cache approach.
*/

command hkey_AddBackLink backKey, hKey
   put hkey_GetBackLinks (hKey) into backLinks
   line_Add backKey, backLinks
   hkey_SetBackLinks hKey, backLinks
end hkey_AddBackLink

function hkey_GetBackLinks hKey, pOverlayName
   put hkey_GetOverlayArray (hKey, pOverlayName) into overlayArray
   put overlayArray ["data"]["backLinks"] into backLinks
   return backLinks
end hkey_GetBackLinks

command hkey_SetBackLinks hKey, backLinks, pOverlayName
   put hkey_GetOverlayArray (hKey, pOverlayName) into overlayArray
   if backLinks is empty then
      delete local overlayArray ["data"]["backLinks"]
   else
      put backLinks into overlayArray ["data"]["backLinks"]
   end if
   hkey_SetOverlayArray hKey, overlayArray, pOverlayName
   return the result
end hkey_SetBackLinks

command hkey_AddToBackLinks overlayData
   -- for each frontKey add the backKey to the backLinks
   put overlayData ["data"]["linkArray"] into hkeyArray
   repeat for each key backKey in hkeyArray
      put hkeyArray [backKey] into frontKeys
      repeat for each line frontKey in frontKeys
         set the cursor to busy
         put hkey_GetBackLinks (frontKey) into backLinks
         -- hkey_CheckBackLinks backLinks
         line_Add backKey, backLinks
         hkey_SetBackLinks frontKey, backLinks
      end repeat
   end repeat
end hkey_AddToBackLinks

command hkey_CheckBackLinks @backLinks
   -- line_Delete "backLinks", backLinks
   -- put empty into backLinks
   -- loop through the backLinks and check they are still current
end hkey_CheckBackLinks


--> hkey | Model | Deps
-
function hkey_FetchDeps hKey, pFetchHow  
   local hKeyArray
   hkey_RecurseCallArray hKey, hkeyArray, pFetchHow
   put array_AllNodes (hKeyArray) into allShortDeps
   put item 1 to 2 of hKey into shortKey
   line_Delete shortKey, allShortDeps
   return allShortDeps
end hkey_FetchDeps

-- function hkey_FetchFilteredDeps shortHKey
   return library_HkeyDeps (shortHKey)
   
   -- fetches all deps from link text files
   local hKeyArray
   hkey_RecurseCallArray shortHKey, hkeyArray, "filtered"
   put array_AllNodes (hKeyArray) into allShortDeps
   put item 1 to 2 of shortHKey into shortKey
   line_Delete shortKey, allShortDeps
   return allShortDeps
end hkey_FetchFilteredDeps

function hkey_FetchDepsFromLinkArray hKey, pReturnShortHkey
   put item 1 to 2 of hKey into shortHKey
   put hkey_GetLinkArray (shortHKey, "hierarchical") into hkeyDepArray
   return deps_FromHkeyArray (hKey, hkeyDepArray, pReturnShortHkey)
end hkey_FetchDepsFromLinkArray

function script_FetchDepsFromScriptArray hKey, pReturnShortHkey
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the script_LinkArray of hObject into scriptLinkArray
   put hkeyArray_ExtractSubArray (hKey,scriptLinkArray) into hkeyLinkArray
   return deps_FromHkeyArray (hKey, hkeyLinkArray, pReturnShortHkey)
end script_FetchDepsFromScriptArray

function deps_FromHkeyArray hKey, hkeyDepArray, pReturnShortHkey
   put array_AllNodes (hkeyDepArray) into allHkeys
   sort allHkeys by item 1 of each
   repeat for each line depKey in allHkeys
      put item 1 to 2 of depKey into shortDepKey
      if shortDepKey =  item 1 to 2 of hKey then next repeat
      if pReturnShortHkey is not false then
         put shortDepKey & CR after hKeyDeps
      else
         put depKey & CR after hKeyDeps
      end if
   end repeat
   delete char -1 of hKeyDeps
   return hKeyDeps
end deps_FromHkeyArray

function hkeyArray_ShortNodes hkeyArray
   local indexArray
   repeat for each key hKey in hkeyArray
      put item 1 to 2 of hKey into shortHkey
      put empty into indexArray [shortHkey]
      put hkeyArray [hKey] into childHkeys
      repeat for each line childHkey in childHkeys
         put item 1 to 2 of childHkey into shortHkey
         put empty into indexArray [shortHkey]
      end repeat
   end repeat
   return keys (indexArray)
end hkeyArray_ShortNodes

function hkey_ExternalHkeysFromArray externalHkeyArray
   repeat for each key shortExternalCall in externalHkeyArray
      put externalHkeyArray [shortExternalCall] into callArray
      put line 1 of keys (callArray) into parentKey
      put callArray [parentKey] into externalHkey
      put externalHkey & CR after externalHkeys
   end repeat
   delete char -1 of externalHkeys
   return externalHkeys
end hkey_ExternalHkeysFromArray 

function hArray_FetchHkeyDeps hKey
   put item 3 of hKey into hObject
   if exists (hObject) is false then return false -- maybe it is a shortheky in a library?
   put the mainstack_WalkArray of hObject into mainstackHkeyWalkArray
   if mainstackHkeyWalkArray is not an array then return false
   put mainstackHkeyWalkArray ["hkeyArray"] into hkeyArray
   if mainstackHkeyWalkArray is not an array then return false
   put hkeyArray_ExtractSubArray (hKey, hkeyArray) into hkeySubArray
   
   put array_AllNodes (hkeySubArray) into hKeyDeps
   line_Delete hKey, hKeyDeps
   sort hKeyDeps by item 1 of each
   return hKeyDeps
end hArray_FetchHkeyDeps

function hkey_FetchLinkArray hKey, pFetchHow
   -- this handler is mainly to show the different ways of fetching hkeyLinkArray
   switch pFetchHow
      case "stored hkeyLinkArray"
         put hkey_GetLinkArray (hKey) into hkeyLinkArray
         return hkeyLinkArray
      case "stored script_LinkArray"
         hkey_Deconstruct hKey, hName, hType, hObject, hNum
         put the script_LinkArray of hObject into scriptLinkArray
         put hkeyArray_ExtractSubArray (hKey,scriptLinkArray) into hkeyLinkArray
         return hkeyLinkArray
      case "from object"
         -- does not use hArray
         put hkey_ScriptDependencyArray (hKey) into hkeyLinkArray
         return hkeyLinkArray
      case "library_HkeyFolder()"
         -- mixture of hArray and walking
         put library_HkeyFolder (hKey) into hkeyLinkArray
         return hkeyLinkArray
      default  -- everywhere but fastest first
         put hkey_GetLinkArray (hKey) into hkeyLinkArray
         if hkeyLinkArray is an array then return hkeyLinkArray
         
         hkey_Deconstruct hKey, hName, hType, hObject, hNum
         if exists (hObject) is false then
            -- breakpoint
            return empty
         end if
         
         put the script_LinkArray of hObject into hkeyLinkArray
         if hkeyLinkArray is an array then return hkeyLinkArray
         
         put library_HkeyFolder (hKey) into hkeyLinkArray
         return hkeyLinkArray
   end switch
end hkey_FetchLinkArray


--> hkey | Model | Global
-
/*
A LinkArray is used to graph arrays. To do this LinkArrays provide a suite of tools that take complex keys and convert them into simple IDs,
and dictionaries to translate from these IDS to the orginal keys.
*/

function hkey_GetLinkArray hKey, pOverlayName
   put hkey_GetOverlayArray (hKey, pOverlayName) into overlayArray
   put overlayArray ["data"]["linkArray"] into hkeyArray
   return hkeyArray
end hkey_GetLinkArray

command hkey_SetLinkArray hKey, hkeyArray, pOverlayName, pGraphStyle
   -- makes no sense to set hkeyArray without setting the rest of the derived arrays
   put library_HandlerFile (hKey, empty, false) into overlayFolder
   overlay_SetLinkArray overlayFolder, hkeyArray, pOverlayName, pGraphStyle
   put the result into overlayArray
   return overlayArray
end hkey_SetLinkArray

function hkey_GetGeometryArray hKey, pOverlayName
   put hkey_GetOverlayArray (hKey, pOverlayName) into overlayArray
   put hFileArray ["data"]["geometry"] into geometryArray
   return geometryArray
end hkey_GetGeometryArray

command hkey_SetGeometryArray hKey, geometryArray, pOverlayName
   put hkey_GetOverlayArray (hKey, pOverlayName) into overlayArray
   put geometryArray into overlayArray ["data"]["geometry"]
   hkey_SetOverlayArray hKey, overlayArray, pOverlayName
end hkey_SetGeometryArray

command hkey_StripDefaultDotArray overlayArray
   put overlay_GetDefaultArray() into defaultArray
   overlayArray_StripDefaultProps overlayArray, defaultArray
end hkey_StripDefaultDotArray

command hkey_StripDefaultProps @overlayData
   repeat for each key graphName in overlayData
      put overlayData [graphName] into overlayArray
      overlayArray_StripDefaultProps overlayArray
      put overlayArray into overlayData [graphName]
   end repeat
end hkey_StripDefaultProps

command hkey_NormalizeGraphName @pOverlayName
   if pOverlayName is empty then
      put hkey_GetDefaultGraphName() into pOverlayName
   end if
end hkey_NormalizeGraphName

function hkey_GetDefaultGraphName
   put overlay_GetDefaultArray() into overlayDefaultArray
   put overlayArray_GetGraphProperty (overlayDefaultArray, "overlay_Name") into graphName
   return graphName
end hkey_GetDefaultGraphName

function hkey_GetOverlayArray hKey, pOverlayName
   put hkey_GetOverlayData (hKey) into overlayData
   overlayData_NormalizeName pOverlayName, overlayData
   put overlayData [pOverlayName] into overlayArray
   return overlayArray
end hkey_GetOverlayArray

command hkey_SetOverlayArray hKey, overlayArray, pOverlayName
   hkey_StripDefaultDotArray overlayArray
   
   put hkey_GetOverlayData (hKey) into overlayData
   overlayData_NormalizeName pOverlayName, overlayData
   put overlayArray into overlayData [pOverlayName]
   hkey_SetOverlayData hKey, overlayData
end hkey_SetOverlayArray

function hkey_GetOverlayData hKey
   put hkey_ArrayFile (hKey) into someFile
   put url ("binfile:" & someFile) into encodedArray
   if encodedArray is empty then return empty
   put arraydecode (encodedArray) into overlayData
   return overlayData
end hkey_GetOverlayData 

command hkey_SetOverlayData hKey, overlayData
   put hkey_ArrayFile (hKey) into someFile
   
   if overlayData is an array then
      put arrayencode (overlayData) into encodedArray
      put encodedArray into url ("binfile:" & someFile)
      return someFile
   else if overlayData is empty then
      put hkey_Files (hKey, pVersionName) into someFiles
      set the itemdelimiter to "/"
      repeat for each line someFile in someFiles
         put item -1 of someFile into shortFile
         if shortFile is among the items of "handler.txt/help.html" then next repeat
         delete file someFile
      end repeat
      return empty
   end if
end hkey_SetOverlayData


--> Hkey | Wrappers
-
command hKey_DeconstructStoredArray hKey, @hKeyCalls, @backLinks, @allCalls, pVersionName, pOverlayName
   put hkey_GetOverlayArray (hKey, pOverlayName, pVersionName) into overlayArray
   put overlayArray ["data"]["backLinks"] into backLinks
   overlayArray_DeconstructData overlayArray, linkArray, idArray, idLinkArray, reverseIdArray, dotClusterArray
   
   put linkArray [hKey] into hKeyCalls
   put array_AllNodes (linkArray) into allCalls
   sort allCalls
   line_Delete hKey, allCalls -- just in case
end hKey_DeconstructStoredArray
