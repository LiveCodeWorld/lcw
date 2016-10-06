script "model_HandlerLibrary"
--> MetaData
-
license: GPLv3
name: model_HandlerLibrary
type: model
version: 0.6

/*
We are moving away form the idea of a separate repository for library handlers.
Publishing a handler is now going to be the same as publishing a project - that is a folder in GitHub

These projects will contain libs, and models, and back and front scripts
We will also publish handlers in behaviors that are not marked private or are getprop and setprop handlers
The assumption is that these "could" be used in a general sense. The sense of publishing now is to add them to a globa index of handlers that point to the pubished projects.

This global database does not need to store a separate copies of the handlers.
It should also be used to find dependcies fast, and to be created fast by looping through the project files.

More things named handler_XXX over at suite "--> Handler Index" in stack lib_Hkey
*/


--> Working on
-
/*
Moving over to stroring handler calls in hTableLine format.
This tranlsation is undertaken by  "handler_AddToCallArray" when the calls are extracted and saved

The reasons for moving over from old comma based hKeys to new format are:

- 1) revAvailableHandlers returns in the hTableLine word based format
- 2) The tree widget does nto work well with keys that contain commas
- 3) It reads better on screen and in the wiki
*/

function handler_FetchCalls hkeyLine, dataFolder
   -- changed to new hTableLine
   put textStack_CallsFile (hkeyLine, dataFolder) into callsFile
   put script_FetchRaw (callsFile) into hTableLines
   return hTableLines
end handler_FetchCalls

command handler_SaveCalls shortHkey, dataFolder, someHandler
   -- should change to new hTableLine
   -- currently shortHkey is translated to hTableLines
   
   -- /lcw_User/lcw_Metadata/lib_Update/data/objects/stack/lcw_calls.txt
   
   local pSkipHkeyComponents, pSkipHkeyProps
   put textStack_CallsFile (shortHkey, dataFolder) into callsFile
   
   put handler_ConstructCallArray (someHandler, pSkipHkeyComponents, pSkipHkeyProps) into handlerCallArray
   -- put handlerCallArray ["filteredCalls"] into shortCalls   
   put handlerCallArray ["hkeyCalls"] into shortCalls   
   script_SaveRaw callsFile, shortCalls
   
   return shortCalls 
end handler_SaveCalls

command handler_AddToCallArray @tempArray, shortHKey, handlerArray, someHandler, pSkipHkeyComponents, pSkipHkeyProps  
   put hkeyLine_FromHkey (shortHkey) into hTableLine
   put empty into tempArray ["hkeyCalls"][hTableLine]
   return empty
   
   /*
   put empty into tempArray ["hkeyCalls"][shortHKey]
   put handlerArray ["addCall"] into tempArray ["hkeyCalls"][shortHKey]
   
   -- here we do all the old filtering
   -- now we move that to manual and adding terms to dictionary terms
   if handlerArray ["component"] is true then return false
   
   -- don't index rev handler calls (assume they are IDE handlers)
   put item 1 of shortHKey into hName
   if char 1 to 3 of hName = "rev" and char 4 of hName is not "_" then return false
   
   put handlerArray ["ignoreCall"] into ignoreCalls
   if shortHkey is among the lines of ignoreCalls then return false
   
   set the wholematches to true
   if shortHkey is among the lines of pForgetHkeys then return false
   put empty into tempArray ["filteredCalls"][shortHKey]
   */
end handler_AddToCallArray


--> Handler | List
-
function handler_ListExportedShortHkeys stackName
   put handler_ListShortExportedFolders (stackName) into hkeyFolders
   set the itemdelimiter to "_"
   repeat for each line hkeyFolder in hkeyFolders
      put item -1 of hkeyFolder into hType
      delete item -1 of hkeyFolder
      put hkeyFolder,hType into shortHkey
      put shortHkey & CR after shortHkeys
   end repeat
   delete char -1 of shortHkeys
   return shortHkeys
end handler_ListExportedShortHkeys

function handler_ListShortExportedFolders stackName
   put the handler_Folder of stack stackName into handlerFolder
   put the defaultfolder into oDefault
   set the defaultfolder to handlerFolder
   put the folders into hkeyFolders
   filter hkeyFolders without ".*"
   set the defaultfolder to oDefault
   return hkeyFolders
end handler_ListShortExportedFolders


--> Handler | Model
-
/*
This is the new - all handlers are exported to objects lcw_User textStack folder and nowhere else (no separate library).
*/

getprop exported_Handler [shortHkey]
   put the data_Folder of the target into dataFolder
   put handler_Fetch (shortHkey, dataFolder) into someHandler
   return someHandler
end exported_Handler

setprop exported_Handler [shortHkey] someHandler
   put the data_Folder of the target into dataFolder
   handler_Save shortHkey, dataFolder, someHandler
end exported_Handler

getprop handler_Calls [shortHkey]
   put the data_Folder of the target into dataFolder
   put handler_FetchCalls (shortHkey, dataFolder) into shortCalls
   return shortCalls
end handler_Calls

setprop handler_Calls [shortHkey] shortCalls
   put the data_Folder of the target into dataFolder
   handler_SaveCalls shortHkey, dataFolder, shortCalls
   return the result
end handler_Calls

function handler_Fetch shortHkey, dataFolder
   put textStack_HandlerFile (shortHkey, dataFolder, true) into handlerFile
   put script_FetchRaw (handlerFile) into someHandler
   return someHandler
end handler_Fetch

command handler_Save shortHkey, dataFolder, someHandler, pExportCalls
   put textStack_HandlerFile (shortHkey, dataFolder, false) into handlerFile
   script_SaveRaw handlerFile, someHandler
   if pExportCalls is true then
      handler_SaveCalls shortHkey, dataFolder, someHandler
      put the result into shortCalls
      put shortHkey & CR & dataFolder & CR & shortCalls
   end if
   return handlerFile
end handler_Save


--> Handler | Model | Files
-
getprop handler_File [shortHkey]
   put the data_Folder [true] of the target into dataFolder
   put textStack_HandlerFile (shortHkey, dataFolder) into handlerFile
   return handlerFile
end handler_File

getprop handler_Folder [shortHkey]
   -- /lcw_User/lcw_Metadata/LCW/data/objects/stack/handlers/
   put the data_Folder [true] of the target into dataFolder
   if shortHkey is empty then
      put dataFolder & "handlers/" into handlerFolderRoot
      return handlerFolderRoot
   else
      put textStack_HandlerDataFolder (shortHkey, dataFolder) into handlerFolder
      return handlerFolder
   end if
end handler_Folder

function handler_ConstructFolder hKeyLine
   hkey_Deconstruct hKeyLine, hName, hType, hObject, hNum
   if exists (hObject) is false then return empty
   
   put the data_Folder [true] of hObject into dataFolder
   put textStack_HandlerDataFolder (hKeyLine, dataFolder) into handlerFolder
   return handlerFolder
end handler_ConstructFolder


--> Handler | Stuff
-
getprop handler_InHierarchy [hKey]
   put the long id of the target into tObject
   put item 1 to 2 of hKey into shortHkey
   
   put hkey_FoundArray (shortHKey, tObject) into foundArray
   put foundArray ["foundHkey"] into foundHkey
   if foundHkey is empty then return empty
   
   put item 3 of foundHkey into foundObject
   put foundArray ["startLineNum"] into startLineNum
   put foundArray ["endLineNum"] into endLineNum
   
   try
      put line startLineNum to endLineNum of the script of foundObject into foundHandler
      return foundHandler
   catch e
      return empty -- stack locked
   end try
end handler_InHierarchy

function handler_ConstructCallArray someHandler, pSkipHkeyComponents, pSkipHkeyProps
   -- this is slow, and needs to be as fast as possible as we want to call it on every script compile!
   -- should be modified to include "pass"
   
   local allCalls
   
   put word 1 to -1 of someHandler into someHandler
   delete line 1 of someHandler
   delete line -1 of someHandler
   
   put false into repeatUntilEndOfComment
   repeat for each line someLine in someHandler
      if repeatUntilEndOfComment is true then
         put char -2 to -1 of someLine into endCommentBit
         if endCommentBit = "*/" then
            put false into repeatUntilEndOfComment
         end if
         next repeat
      else if char 1 to 2 of word 1 of someLine = "/*" then
         put true into repeatUntilEndOfComment
         next repeat
      else
         -- first lt's deal with single line comments
         repeat for each item commentBlock in "--,#"
            if someLine contains commentBlock then
               put text_StripQuoted (someLine) into commentLine
               
               put wordOffset (commentBlock, commentLine) into wordNum
               if wordNum > 0 then
                  put word wordNum to -1 of commentLine into someComment
                  
                  if char -1 of word 2 of someComment = ":" then
                     set the itemdelimiter to ":"
                     put word 2 of item 1 of someComment into someKey
                     put word 1 to -1 of item 2 of commentLine into someValue
                     set the itemdelimiter to ","
                     
                     put metadataArray [someKey] into someIndex
                     line_Add someValue, someIndex
                     put someIndex into metadataArray [someKey]
                  end if
                  
                  -- delete the comments part
                  delete word wordNum to -1 of someLine
               end if
            end if
         end repeat
         
         if the number of words of someLine = 0 then next repeat
         
         put someLine into testLine
         replace " then " with CR in testLine
         replace " else " with CR in testLine
         repeat for each line testBit in testLine
            put token 1 of testBit into testComand
            if testComand is empty then next repeat
            
            switch
               case ide_IsDictionaryTerm (testComand) is true
                  break
               case testComand = "dispatch"
                  put token 2 of testBit into dispatchCommand
                  put dispatchCommand,"c" into shortHKey
                  
                  handler_AddToCallArray tempArray, shortHKey, metadataArray, someHandler, pSkipHkeyComponents, pSkipHkeyProps
                  
                  delete token 1 to 3 of someLine  -- let's look at the rest of the line
                  break
               case testComand is among the items of "send,call"
                  put token 2 of testBit into sendMessage
                  put token 1 of sendMessage into sendComand
                  put sendComand,"c" into shortHKey
                  
                  handler_AddToCallArray tempArray, shortHKey, metadataArray, someHandler, pSkipHkeyComponents, pSkipHkeyProps
                  
                  delete token 1 to 3 of someLine  -- let's look at the rest of the line
                  break
               default
                  -- first word and not a LiveCode term
                  put testComand,"c" into shortHKey
                  
                  handler_AddToCallArray tempArray, shortHKey, metadataArray, someHandler, pSkipHkeyComponents, pSkipHkeyProps
                  
                  delete token 1 of someLine  -- let's look at the rest of the line
            end switch
         end repeat
         
         put script_ExtractFunctionCalls (someLine, false) into fNames
         repeat for each line fName in fNames
            put fName,"f" into shortHKey
            
            handler_AddToCallArray tempArray, shortHKey, metadataArray, someHandler, pSkipHkeyComponents, pSkipHkeyProps
         end repeat
         
         -- could still have other stuff on line
         set the wholematches to true
         put wordoffset ("the", someLine) into theWordNum
         if theWordNum is 0 then next repeat
         
         put theWordNum - 1 into setGetPutWordNum
         put word setGetPutWordNum to -1 of someLine into testLineBit
         
         put 3 into handlerTokenNum
         put token handlerTokenNum of testLineBit into handlerName
         if ide_IsDictionaryTerm (handlerName) is true then next repeat
         
         -- now check getprop / setprop calls ("the xxx [zzz] of")
         
         put handlerTokenNum + 1 into ofTokenNum
         get token ofTokenNum of testLineBit
         if it is "[" then
            put handlerTokenNum + 4 into ofTokenNum
            get token ofTokenNum of testLineBit
         end if
         
         if it is "of" then
            put token 1 of testLineBit into setGetPut
            if setGetPut is "set" and "to" is among the words of someLine then
               put handlerName,"s" into shortHKey
               
               handler_AddToCallArray tempArray, shortHKey, metadataArray, someHandler, pSkipHkeyComponents, pSkipHkeyProps
            else -- if setGetPut is among the items of "case,if,get,put" then
               put handlerName,"g" into shortHKey
               
               handler_AddToCallArray tempArray, shortHKey, metadataArray, someHandler, pSkipHkeyComponents, pSkipHkeyProps
            end if
         end if
      end if
   end repeat
   
   put tempArray ["hkeyCalls"] into someArray
   put keys (someArray) into metadataArray ["hkeyCalls"]
   put tempArray ["filteredCalls"] into someArray
   put keys (someArray) into metadataArray ["filteredCalls"]
   
   put sha1_Hash (someHandler) into handlerHash
   put handlerHash into metadataArray ["sha1"]
   -- hkey_AddToKeyWordArray metadataArray, hKey, handlerHash
   
   return metadataArray
end handler_ConstructCallArray
