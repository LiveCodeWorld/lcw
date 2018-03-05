script "model_ScriptExport"
--> MetaData
-
name: model_ScriptExport
type: model
author: David Bovill
copyright: David Bovill
license: GPLv3
version: 0.9

/*
This model handles exported scripts and handlers.

It uses a "merge" technique to combine individual handlers with an exported script template. This is surprisingly fast and has a number of advantages:

-  changes to individual handlers show up in git
-  spotlight and similar tools can easily find and index handlers
-  avoids duplication of handlers
-- makes it easy to see duplicate handlers and badly formatted scripts

There were problems with text encoding and git - so we started to export scripts as binary and use "hack_UpdateBinFile" to fiddle / fix things
This needs looking into again.
For now we look to move all access to this model so we can make changes globally.
*/

--> Variables
-
/*
localArray is used by the script_MergeLines function to restore the original script.
*/
local LocalArray


--> Working on
-
function hkeyLine_FromHandlerFile handlerPath
   -- is this needed???
   -- lcw_User/lcw_Metadata/lib_Display/data/objects/stack/handlers/M display_SpotlightHandler/lcw_handler.txt
   
   set the itemdelimiter to slash
   if item -1 of handlerPath is not "lcw_handler.txt" then return empty
   put item -2 of handlerPath into shortHkeyLine
   put item 1 to -4 of of handlerPath into somePath
   
   put script_ExportedRootToObject (somePath) into hObject
   put hKeyLine_Construct (shortHkeyLine, hObject) into hkeyLine
   return hkeyLine
end hkeyLine_FromHandlerFile


--> Script Export | Paths
-
function script_FileToObject somePaths
   -- /lcw_User/lcw_Metadata/Global_Project_Menu/data/objects/stack/lcw_script.txt
   -- /lcw_User/lcw_Metadata/Rescue Livecode World/data/objects/button_1209/lcw_script.txt
   
   set the itemdelimiter to slash
   repeat for each line somePath in somePaths
      delete item -1 of somePath
      put script_ExportedRootToObject (somePath) into someObject
      if exists (someObject) is false then next repeat      
      
      put someObject & CR after someObjects
   end repeat
   delete char -1 of someObjects
   return someObjects
end script_FileToObject

function script_ExportedRootToObject somePath
   -- assumes homeStackName = mProjectFolderName
   
   put lcw_UserMetadataFolder() into lcwUserMetadataFolder
   project_FindFromPath somePath, homeStackName, projectFolder, projectStackPath
   put the result into foundBoolean
   
   set the itemdelimiter to slash
   put the number of items of projectFolder into startItemNum
   put item (startItemNum + 2) of somePath into mProjectFolderName
   put item -1 of somePath into objectBit
   put item (startItemNum + 5) of somePath into maybeSubStack
   
   if maybeSubStack = "substacks" then
      put item (startItemNum + 6) of somePath into subStackName
      if exists (stack subStackName of stack mProjectFolderName) is false then return empty
      put the name of stack subStackName of stack mProjectFolderName into stackObject
   else
      if exists (stack mProjectFolderName) is false then return empty
      put the name of stack mProjectFolderName into stackObject
   end if
   
   set the itemdelimiter to "_"
   put item 1 of objectBit into objectType
   switch objectType
      case "stack"
         return stackObject
      case "card"
         put item 2 of objectBit into shortID
         if exists (card id shortID of stackObject) is false then return empty
         put the long id of card id shortID of stackObject into cardObject
         put revRuggedID (cardObject) into cardObject
         return cardObject
      default
         put item 2 of objectBit into shortID
         if exists (control id shortID of stackObject) is false then return empty
         put the long id of control id shortID of stackObject into someObject
         put revRuggedID (someObject) into someObject
         return someObject
   end switch
end script_ExportedRootToObject

private command project_FindFromPath fileOrFolder, @homeStackName, @projectFolder, @homeStackPath
   -- this is overcomplicated (replace with spearate handlers)
   -- only used by "script_ExportedRootToObject"
   
   put fileOrFolder into someFolder
   switch
      case fileOrFolder is empty
         put empty into homeStackName
         put empty into projectFolder
         put empty into homeStackPath
         return false
      case there is a folder fileOrFolder
         text_AddTrailing someFolder, slash
         break
      case there is a file fileOrFolder
         set the itemdelimiter to slash
         put empty into item -1 of someFolder
         break
      default
         put fileOrFolder
         answer warning "Cannot locate a folder or file with this path. Would you like to create a folder?" with "Cancel" or "Create"
         breakpoint
         if it is "Cancel" then exit to top
         
         put empty into homeStackName
         put empty into projectFolder
         put empty into homeStackPath
         return false
         
         put fileOrFolder into someFolder
         if char -1 of someFolder is not slash then
            -- we assume folders end with slash. So this is a file.
            set the itemdelimiter to slash
            put empty into item -1 of someFolder
         end if
         folder_CreateNested someFolder
   end switch
   
   project_FindFromFolder someFolder, homeStackName, projectFolder, homeStackPath
   put the result into someBoolean
   return the result
end project_FindFromPath


--> Script | Export | Props
-
getprop exported_Script [pDontMerge]
   put the data_Folder of the target into dataFolder
   put script_ReconstructFromExported (dataFolder, pDontMerge) into someScript
   return someScript
end exported_Script

function script_ReconstructFromExported dataFolder, pDontMerge
   put textStack_ScriptFile (dataFolder, pDontCreate) into scriptFile
   put script_FetchRaw (scriptFile) into rawScript
   
   if pDontMerge is true then
      return rawScript
   else
      -- put script_MergeHandlers (scriptFile, rawScript) into someScript
      put dataFolder into LocalArray ["objectScriptFolder"]
      put dataFolder & "handlers/" into handlersFolder
      if there is a folder handlersFolder then
         put merge (rawScript) into fullScript
         return fullScript
      else
         return rawScript
      end if
   end if
end script_ReconstructFromExported

setprop exported_Script [pExportCalls] someScript
   put the long id of the target into scriptObject
   -- script_UpdateHarrayAndExport scriptObject, pExportCalls
   script_ExportAndIndexMenus scriptObject, pExportCalls
   put the result into someFile
   return someFile
end exported_Script

getprop script_IsDifferent
   -- even if the only difference is whitespace
   -- which means a diff program may show no diference when this returns true
   put the long id of the target into targetObject
   try
      put the script of targetObject into someScript
      put the exported_Script of targetObject into exportedScript
      if exportedScript is empty then return false -- added as if there is no exported script to compare it is no different
      put exportedScript is not someScript into someBoolean
      return someBoolean
   catch someError
      return empty  -- script may be protected
   end try
end script_IsDifferent

setprop script_IsIndexed someBoolean
   put the long id of the target into scriptObject
   if someBoolean is true then
      script_IndexHarrayAndUpateMenus scriptObject
      put the result into mTitleTableArray
      return mTitleTableArray
   else
      breakpoint -- not done yet
      return empty
   end if
end script_IsIndexed


--> Script Export | Model
-
getprop script_Raw
   put the script_File of the target into scriptFile
   put script_FetchRaw (scriptFile) into rawScript
   return rawScript
end script_Raw


--> Script Export | Merge
-
/*
This suite of handlers uses LocalArray so that the merge function can work across handlers.
It depends of a particular file and folder structure of the exported script template and handlers.
*/

function script_MergeHandlers scriptFile, someScript
   put scriptFile into objectScriptFolder
   set the itemdelimiter to "/"
   delete item -1 of objectScriptFolder
   put objectScriptFolder into LocalArray ["objectScriptFolder"]
   
   put objectScriptFolder & "/handlers/" into handlersFolder
   if there is a folder handlersFolder then
      return merge (someScript)
   else
      return someScript
   end if
end script_MergeHandlers

function object_ConstructMergeScriptArray tObject
   put the script of tObject into someScript
   return script_ConstructMergeArray (someScript)
end object_ConstructMergeScriptArray

function script_ConstructMergeArray someScript
   -- 20% faster than not using revAvailableHandlers
   -- 50% slower than fetching from disk
   -- 10x slower than just using revAvailableHandlers
   -- hashing ony makes 5% difference
   put the revAvailableHandlers of tObject into handlerTable
   put handlerTable into mergeScriptArray ["handlerTable"]
   
   sort numeric descending handlerTable by word 3 of each
   repeat for each line handlerTableLine in handlerTable
      put word 1 of handlerTableLine into hType
      put word 2 of handlerTableLine into hName
      put word 3 of handlerTableLine into startLineNum
      put word 4 of handlerTableLine into endLineNum
      
      put hName,hType into shortHkey
      put line startLineNum to endLineNum of someScript into someHandler
      put sha1_Hash (someHandler) into mergeScriptArray ["handler"][shortHkey]["sha1"]
      put someHandler into mergeScriptArray ["handler"][shortHkey]
      
      put "[[ library_FetchHandler (" & shortHkey & ") ]]" into line startLineNum to endLineNum of someScript
   end repeat
   put someScript into mergeScriptArray ["mergeScript"]
   return mergeScriptArray
end script_ConstructMergeArray

private function _FetchHandler hName, hType, pObject
   put LocalArray ["objectScriptFolder"] into objectScriptFolder
   
   put hName,hType into shortHkey
   put textStack_HandlerFile (shortHkey, objectScriptFolder) into handlerFile
   if handlerFile is empty then return empty
   put script_FetchRaw (handlerFile) into someHandler
   return someHandler
end _FetchHandler

private function mainStack_FetchHandler hName, hType, pObject
   return _FetchHandler (hName, hType, pObject)
end mainStack_FetchHandler

function script_MergeLines mergeScript, handlerTable
   -- put merge (mergeScript) into remergedScript -- not safe when mergeScript contains odd chars?
   sort numeric ascending handlerTable by word 3 of each
   
   repeat for each line handlerTableLine in handlerTable
      put word 1 of handlerTableLine into hType
      put word 2 of handlerTableLine into hName
      put word 3 of handlerTableLine into startLineNum
      put word 4 of handlerTableLine into endLineNum
      
      put hName,hType into shortHkey
      put library_FetchHandler (shortHkey) into someHandler
      put someHandler into line startLineNum of mergeScript
   end repeat
   return mergeScript
end script_MergeLines


--> Object | Script | Export
-
command hkey_NormalizeType @hType
   -- standardize revAvailableHandlers hType for hKeys
   replace "M" with "c" in hType
   put tolower (hType) into hType
end hkey_NormalizeType

-- command hack_UpdateBinFile @someData, someFile
if someData contains numtochar (13) then
   -- old "file" export
   replace numtochar (13) with CR in someData
   put someData into url ("binfile:" & someFile)
end if
end hack_UpdateBinFile
