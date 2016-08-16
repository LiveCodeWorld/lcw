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


## Future Enhancements

In the future we will look at the hash of a handler and check if this is present in the "Handler Library",
If it is we will only store a ling to that particular version of the handler.
For this we need to finsih the "Handler Library" with robust versioning and git integration.
*/


--> Working on
-
/*
This is a global variable at the moment.
Should be changed to use

This model is here as it is used by the front script (which can depend on it being there!), 
and therefore any controls can access it.
*/

command script_IncrementCompileCount scriptObject
   put the hArray_ObjectMetaData ["script_CompileCount"] of scriptObject into someNum
   add 1 to someNum
   set the hArray_ObjectMetaData ["script_CompileCount"] of the target to someNum
end script_IncrementCompileCount


--> Script Export
-
command script_UpdateAndExport scriptObject, pExportHandlersAndCalls
   -- merged with "script_IndexHarrayAndUpateMenus"
   -- this is a simple all in one command that updates and exports everything you need
   global gHkey_Array
   global gTemp_ActiveMenuArray
   delete variable gTemp_ActiveMenuArray
   
   if pExportHandlersAndCalls is empty then put false into pExportHandlersAndCalls
   put pExportHandlersAndCalls is true into createHashArray
   put false into forceIndexHandlerCalls
   
   try
      put the script of scriptObject into someScript
   catch e
      return merge ("error, [[scriptObject]] is probably a locked stack so can't index script.")
   end try
   
   -- update the extensive metadata stored in gHkey_Array
   object_AddToArray gHkey_Array, scriptObject, someScript, createHashArray, forceIndexHandlerCalls, pExportHandlersAndCalls
   put the result into scriptFile
   set the menu_Update of scriptObject to true
   put the result into mTitleTableArray
   
   -- let's set the uRipArray (no reason not to)
   -- this will be lost for script-only stacks
   script_UpdateUrip scriptObject, someScript
   return scriptFile
end script_UpdateAndExport


--> Script Export | Props
-
getprop exported_Script [pDontMerge]
   put the script_File of the target into scriptFile
   put url ("binfile:" & scriptFile) into someScript
   -- hack_UpdateBinFile someScript, scriptFile
   
   if pDontMerge is true then
      return someScript
   else
      put script_MergeHandlers (scriptFile, someScript) into someScript
      return someScript
   end if
end exported_Script

setprop exported_Script [pExportHandlersAndCalls] someScript
   put the long id of the target into scriptObject
   script_UpdateAndExport scriptObject, pExportHandlersAndCalls
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

getprop script_MenuTitleTableArray
   -- this is what constructs the mTitleTableArray from a script
   -- put menu_GetTitleTableArrayGlobal (mController) into mTitleTableArray
   local mTitleTableArray
   
   put the long id of the target into mController
   put the script of mController into someScript
   put script_OrderedMenuTitles (someScript) into mTitles
   repeat for each line mTitle in mTitles
      put menu_ExtractTableFromScript (mTitle, someScript, mController) into mTable
      put mTable into mTitleTableArray [mTitle]
   end repeat
   return mTitleTableArray
end script_MenuTitleTableArray


--> hArray | Status
-
command object_AddToGlobalArray someObject, pExportHandlers, pCreateHashArray
   -- also exports handlers
   global gHkey_Array
   try
      put the script of someObject into someScript
   catch e
      return merge ("error, [[someObject]] is probably a locked stack so can't index script.")
   end try
   object_AddToArray gHkey_Array, someObject, someScript, pCreateHashArray, false, false
   put the result into scriptFile
   return someScript
end object_AddToGlobalArray

command object_AddToArray @hArray, someObject, someScript, pCreateHashArray, pForceIndexHandlerCalls, pExportHandlersAndCalls
   -- bug:  this means that fetching the object_Array also exports the script
   if pCreateHashArray is not true then
      delete variable hArray ["handlerHashArray"]
   end if
   
   put the stack_Object of someObject into stackObject
   put the mainstack of stackObject into mainStackName
   put the name of stack mainStackName into ruggedMainStack
   put the filename of stack mainStackName into stackFile
   file_SetHomeRelative stackFile
   
   put the rugged_ID of someObject into ruggedObject
   
   if pExportHandlersAndCalls is true then
      object_ExportScript someObject, someScript, pExportHandlersAndCalls, false  -- here we can export the script
      put the result into scriptFile
      file_SetHomeRelative scriptFile
   else
      put the object_Folder [true] of someObject into objectFolder
      put objectFolder_ScriptFile (objectFolder) into someFile
   end if
   
   put the ticks into indexTime
   put sha1_Hash (someScript) into scriptHash
   
   put script_GetMetadataArray (someScript) into objectMetaData
   put the customproperties ["uRIP"] of someObject into uRipArray
   union objectMetaData with uRipArray
   
   -- first let's delete any old entries for this object
   hArray_RemoveObjectFromArray ruggedObject, hArray, uRipArray
   delete variable hArray ["scriptArray"][ruggedObject]
   
   -- now let's index object types
   put objectMetaData ["type"] into uRipType
   if uRipType is not empty then
      put objectMetaData ["name"] into uRipName
      -- with the info below you can get rugged_IDs fast, and hkeys in them pretty fast
      -- after this you can use the hKey to get handler info from the "handlerArray" below
      if uRipType = "view" and the view_IsTemplate of someObject is true then
         put "view template" into uRipType
      end if
      put scriptHash into hArray ["objectType"][uRipType][ruggedObject]["scriptHash"] 
      put objectMetaData ["name"] into hArray ["objectType"][uRipType][ruggedObject]["uRipName"] 
   end if
   
   -- Add script details to object metadata
   put scriptHash into hArray ["scriptArray"][ruggedObject]["metadata"]["sha1"]
   
   put objectMetaData into hArray ["scriptArray"][ruggedObject]["metadata"]["uripArray"]
   put scriptFile into hArray ["scriptArray"][ruggedObject]["metadata"]["scriptFile"]
   put stackFile into hArray ["scriptArray"][ruggedObject]["metadata"]["stackFile"]
   put ruggedMainStack into hArray ["scriptArray"][ruggedObject]["metadata"]["main stack object"]
   put indexTime into hArray ["scriptArray"][ruggedObject]["metadata"]["indexTime"]
   
   -- index any behaviors
   put the behavior of someObject into behaviorObject
   if behaviorObject is not empty then
      put scriptHash into hArray ["behaviorArray"][behaviorObject]["data"]["object"][ruggedObject]["scriptHash"]
   end if
   
   -- fast and simple (to get comments and metadata will need to process later
   put false into pIsExpanded
   local suiteTitle
   put 1 into indexNum
   put 1 into lineNum
   
   -- same logic as "the script_Array"
   put false into commentBlock
   repeat with lineNum = 1 to the number of lines of someScript
      put line lineNum of someScript into scriptLine
      switch
         case word 1 of scriptLine = "/*"
            put true into commentBlock
            break
         case commentBlock is true
            -- keep looping till end of block
            if word -1 of scriptLine = "*/" then
               -- could put this commented out section in the index?
               put false into commentBlock
            end if
            break
         case word 1 of scriptLine = "-->" 
            put word 2 to -1 of scriptLine into suiteTitle
            
            put "t" into hArray ["scriptArray"][ruggedObject]["data"]["script_DataArray"][indexNum]["lineType"]
            put lineNum into hArray ["scriptArray"][ruggedObject]["data"]["script_DataArray"][indexNum]["startLineNum"]
            put suiteTitle into hArray ["scriptArray"][ruggedObject]["data"]["script_DataArray"][indexNum]["scriptLine"]
            put pIsExpanded into hArray ["scriptArray"][ruggedObject]["data"]["script_DataArray"][indexNum]["isExpanded"]
            
            add 1 to indexNum
            break    
         case word 1 of scriptLine is among the items of "command,on,function,getprop,setprop,private"
            put true into indexingHandler
            
            if word 1 of scriptLine is "private" then
               put "p" into pBit
               delete word 1 of scriptLine
            else
               put empty into pBit
            end if
            
            get char 1 of scriptLine
            if it = "o" then
               put true into isOnMessage
               put pBit & "c" into lineType
            else
               put false into isOnMessage
               put pBit & it into lineType
            end if
            
            put word 2 of scriptLine into hName
            
            put countArray [hName][lineType] into hNum
            add 1 to hNum
            put hNum into countArray [hName][lineType]
            
            put hName,lineType into shortHKey
            put shortHKey,ruggedObject,hNum into hKey
            put lineNum into startLineNum
            
            put hKey into hArray ["scriptArray"][ruggedObject]["data"]["script_DataArray"][indexNum]["hKey"]
            put lineType into hArray ["scriptArray"][ruggedObject]["data"]["script_DataArray"][indexNum]["lineType"]
            put suiteTitle into hArray ["scriptArray"][ruggedObject]["data"]["script_DataArray"][indexNum]["suiteTitle"]
            put pIsExpanded is true into hArray ["scriptArray"][ruggedObject]["data"]["script_DataArray"][indexNum]["isExpanded"]
            put startLineNum into hArray ["scriptArray"][ruggedObject]["data"]["script_DataArray"][indexNum]["startLineNum"]
            
            put scriptLine into startScriptLine
            put startScriptLine into hArray ["scriptArray"][ruggedObject]["data"]["script_DataArray"][indexNum]["handlerLine"]
            
            break
         case word 1 of scriptLine = "end" and word 2 of scriptLine = hName and indexingHandler is true
            put false into indexingHandler
            put lineNum into endLineNum
            
            put endLineNum into hArray ["scriptArray"][ruggedObject]["data"]["script_DataArray"][indexNum]["endLineNum"]
            
            put line startLineNum to endLineNum of someScript into someHandler
            put sha1_Hash (someHandler) into handlerHash
            put handlerHash into hArray ["scriptArray"][ruggedObject]["data"]["script_DataArray"][indexNum]["sha1"]
            
            /*
            -- too slow
            if pCreateHashArray is true then
               -- this is slow
               -- here we check to see if the handlerHash already exists for that mainstack object
               -- this only happens if hArray ["handlerHashArray"] is added to hArray before walking
               -- this can be initialised by adding a previously stored handlerHashArray from disk
               -- or simply doing something like 'put empty into hArray ['"handlerHashArray"]["new"]'
               
               hArray_AddHandlerHash hArray, hKey, someHandler, handlerHash, indexTime, pForceIndexHandlerCalls
               put empty into hArray ["handlerHashArray"]["actual"][handlerHash]
            end if
            */
            
            -- now index unique global suites
            if word -1 of suiteTitle = "Menu" and word -2 of suiteTitle = "|" then
               -- it's a menu
               _addMenuToHarray hArray, suiteTitle, shortHkey, ruggedObject, ruggedMainStack, isOnMessage, lineType, handlerHash, scriptHash, shortkeySuiteArray, thisScriptsMenuArray
            end if
            
            -- now index first (not last!) hKeys of object
            if hArray ["scriptArray"][ruggedObject]["data"]["firstHKeyArray"][shortHKey]["sha1"] is empty then
               -- only index first handler with this array
               put handlerHash into hArray ["scriptArray"][ruggedObject]["data"]["firstHKeyArray"][shortHKey]["sha1"]
               
               -- only firstHkeys can ever get called so only these go in handlerArray
               put startScriptLine into hArray ["handlerArray"][shortHKey][hKey]["scriptLine"]
               put handlerHash into hArray ["handlerArray"][shortHKey][hkey]["handlerHash"]
               put startLineNum into hArray ["handlerArray"][shortHKey][hKey]["startLineNum"]
               put endLineNum into hArray ["handlerArray"][shortHKey][hkey]["endLineNum"]
               
               -- now let's extract keywords and index shortHkey against each (no point doing it for non first Hkeys
               -- hkey_AddToKeyWordArray hArray, hKey, handlerHash -- could index twice with same hash in different places
            end if
            
            add 1 to indexNum
            break
         case token 1 of scriptLine is empty
            -- it's a comment or some junk
            -- however script suites are also comments (so put at end of tests)!
            -- not actually needed
            break
         default
            /*
            should modify to collect stuff here, and add to metadata outside of handlers
            */
      end switch
   end repeat
   
   -- having gone through every line of the script we can do something like
   -- put the script_MenuTitleTableArray of stackObject into mTitleTableArray
   -- menu_SetTitleTableArrayGlobal stackObject, mTitleTableArray, suiteTitle
   
   return scriptFile
end object_AddToArray

private command _addMenuToHarray @hArray, suiteTitle, shortHkey, ruggedObject, ruggedMainStack, isOnMessage, lineType, handlerHash, scriptHash, @shortkeySuiteArray, @thisScriptsMenuArray
   -- here we want to look at automatically indexing and creating global menu_Table / array
   -- and then
   -- menu_SetTitleTableArrayGlobal stackObject, mTitleTableArray, suiteTitle
   
   switch
      case word 1 of suiteTitle = "Global" and word 2 of suiteTitle = "|"
         menu_AddGlobalHarray suiteTitle, shortHkey, ruggedObject, handlerHash, isOnMessage, lineType, thisScriptsMenuArray, hArray
         break
      default
         menu_AddLocalHarray suiteTitle, shortHkey, ruggedObject, ruggedMainStack, handlerHash, scriptHash, isOnMessage, lineType, thisScriptsMenuArray, hArray
   end switch
end _addMenuToHarray

private command menu_AddLocalHarray suiteTitle, shortHkey, ruggedObject, ruggedMainStack, handlerHash, scriptHash, isOnMessage, lineType, @thisScriptsMenuArray, @hArray
   -- store local menu with the mainstack section of the array
   
   if ruggedMainStack is not among the keys of thisScriptsMenuArray then
      delete variable hArray ["scriptArray"][ruggedMainStack]["data"]["menu_SuiteArray"]
      put empty into thisScriptsMenuArray [ruggedMainStack]
   end if
   
   put ruggedObject into hArray ["scriptArray"][ruggedMainStack]["data"]["menu_SuiteArray"][suiteTitle]["mController"]
   put scriptHash into hArray ["scriptArray"][ruggedMainStack]["data"]["menu_SuiteArray"][suiteTitle]["scriptHash"]
   
   if isOnMessage is true and lineType = "c" then
      put hArray ["scriptArray"][ruggedMainStack]["data"]["menu_SuiteArray"][suiteTitle]["item"] into shortkeySuiteArray
      if shortkeySuiteArray is not an array then
         put 1 into itemNum
      else
         put (the number of elements of shortkeySuiteArray) + 1 into itemNum
      end if
      
      put shortHkey into hArray ["scriptArray"][ruggedMainStack]["data"]["menu_SuiteArray"][suiteTitle]["item"][itemNum]["shortHkey"]
      put handlerHash into hArray ["scriptArray"][ruggedMainStack]["data"]["menu_SuiteArray"][suiteTitle]["item"][itemNum]["sha1"]
   end if            
end menu_AddLocalHarray

private command menu_AddGlobalHarray suiteTitle, shortHkey, ruggedObject, handlerHash, isOnMessage, lineType, @thisScriptsMenuArray, @hArray
   -- updates hArray ["Global Menus"][suiteTitle]
   
   if suiteTitle is not among the keys of thisScriptsMenuArray then  -- a new global menu for this script
      delete variable hArray ["Global Menus"][suiteTitle]
      put empty into thisScriptsMenuArray [suiteTitle]
   end if
   
   put ruggedObject into hArray ["Global Menus"][suiteTitle]["mController"]
   if isOnMessage is true and lineType = "c" then
      put hArray ["Global Menus"][suiteTitle]["item"] into shortkeySuiteArray
      if shortkeySuiteArray is not an array then
         put 1 into itemNum
      else
         put (the number of elements of shortkeySuiteArray) + 1 into itemNum
      end if
      put shortHkey into hArray ["Global Menus"][suiteTitle]["item"][itemNum]["shortHkey"]
      put handlerHash into hArray ["Global Menus"][suiteTitle]["item"][itemNum]["sha1"]
   end if
end menu_AddGlobalHarray

command hkey_AddToKeyWordArray @hArray, hKey, handlerHash
   put hkey_ConstructKeywords (item 1 of hKey) into kWords
   put item 1 to 2 of hKey into shortHKey
   repeat for each line kWord in kWords
      put handlerHash into hArray ["keywordArray"][kWord][shortHKey]["sha1"]
      put item 3 of hKey into hObject
      if hObject is not empty then put hObject into hArray ["keywordArray"][kWord][shortHKey]["rugged_ID"]
   end repeat
end hkey_AddToKeyWordArray


--> Object | Script | Export
-
function object_FetchScript objectFolder
   folder_Format objectFolder
   put objectFolder & "script.txt" into someFile
   put url ("binfile:" & someFile) into someScript
   -- hack_UpdateBinFile someScript, someFile
   return someScript
end object_FetchScript

command object_ExportScript someObject, pSomeScript, pExportHandlersAndCalls, pDontExportScript
   -- simply export the objects script to the right place (see also "exported_Script")
   -- note use of binFile to avoid translating of LF to CR on Macs by Revolution (which causes difficulties for git)
   
   if pSomeScript is empty then put the script of someObject into pSomeScript
   put the object_Folder of someObject into objectFolder
   put objectFolder_ScriptFile (objectFolder) into someFile
   if pDontExportScript is true then return someFile
   
   if pExportHandlersAndCalls is not false then
      script_ExportHandlersAndCalls pSomeScript, objectFolder, someObject
      put the result into someFile
   else
      if pSomeScript is empty then
         delete file someFile
         put empty into someFile
      else
         put pSomeScript into url ("binfile:" & someFile)
      end if
   end if
   return someFile
end object_ExportScript

command script_ExportHandlersAndCalls mergeScript, objectFolder, someObject
   -- here we export a script as a folder of handlers and calls
   if exists (someObject) is false then
      breakpoint
      put object_FromScriptFolder (objectFolder) into someObject
      return empty
   end if
   
   put the revAvailableHandlers of someObject into handlerTable
   if handlerTable is empty then
      return empty -- everything is deleted before re-exporting
   end if
   
   sort numeric descending handlerTable by word 3 of each
   repeat for each line handlerTableLine in handlerTable
      set the cursor to busy
      put word 1 of handlerTableLine into hType
      put word 2 of handlerTableLine into hName
      if hName = "_" then next repeat -- could check handler is empty ?
      put word 3 of handlerTableLine into startLineNum
      put word 4 of handlerTableLine into endLineNum
      
      put line startLineNum to endLineNum of mergeScript into someHandler
      hkey_NormalizeType hType
      put hName,hType into shortHkey
      
      -- project_StoreHandler hKey, someHandler
      put objectFolder_HandlerFolder (shortHkey, objectFolder, false) & "script.txt" into someFile
      put someHandler into url ( "binfile:" & someFile)
      
      put "[[ _FetchHandler (" & hName, hType & ") ]]" into line startLineNum to endLineNum of mergeScript
      -- put "[[ _FetchHandler (" & kwote(hName) & "," && kwote(hType) & ") ]]" into line startLineNum to endLineNum of mergeScript
   end repeat
   
   put objectFolder_ScriptFile (objectFolder, false) into someFile
   put mergeScript into url ( "binfile:" & someFile)
   return someFile
end script_ExportHandlersAndCalls

command hkey_NormalizeType @hType
   -- standardize revAvailableHandlers hType for hKeys
   replace "M" with "c" in hType
   put tolower (hType) into hType
end hkey_NormalizeType

command script_UpdateUrip scriptObject, someScript
   -- careful with script only stacks as these changes will not be stored
   put script_GetMetadataArray (someScript) into uRIPArray
   delete local uRIPArray ["date"]
   set the object_UripArray of scriptObject to uRipArray
   return uRipArray
end script_UpdateUrip


--> Menu | Table | Construct
-
command menu_DeleteTables mController
   put the custompropertysets of mController into setNames
   line_Delete "uOPN_MenuTable", setNames
   set the custompropertysets of mController to setNames
end menu_DeleteTables

command menu_SetSubmenuFixedProp mItemType, comLine, mTitle, scriptObject, fixedSubMenu, paramProp
   -- ignoreCall: submenu_Fixed,s
   switch mItemType
      case empty
         break
      case "submenu"
         break
      case "fixed"
         put token 1 of comLine into mCommand
         put menu_GetDefaultController (mTitle, scriptObject, true) into mController
         set the submenu_Fixed [mCommand] of mController to fixedSubMenu
         break
      default
         if paramProp is not empty then
            put menu_GetDefaultController (mTitle, scriptObject, true) into mController
            custom_DeleteProperty paramProp, mController, "submenu_Fixed"	# lets clear it to be tidy ?
         end if
   end switch
end menu_SetSubmenuFixedProp

command menu_TableLineFromScript mVersion, mTitle, comLine, scriptObject, someScript, @mLine, @mTableLine, @mFormatProp, @submenuProp, @paramProp, @fixedSubMenu 
   -- see "menu_ConvertTable" for counterpart that creates menu from the stored mTable created here
   
   menu_DeconstructCommandLine mVersion, comLine, mCommand, mPrefix, mSuffix, customParam
   put empty into mItemType
   switch
      case mSuffix is empty
         put "-" into mLine
         put mLine into mTableLine
         put empty into mFormatProp
         put empty into submenuProp
         put empty into paramProp
         put empty into fixedSubMenu
         return empty
      case mPrefix is "submenu"
         -- see function menu_ConstructSubmenuTableLine for how it should be done
         put "submenu" into mItemType
         put menu_GetDefaultController (mTitle, scriptObject, true) into mController
         
         extractInsertedTitle mCommand, mController, someScript, subMenuTitle, customControllerParam, dynamicTitleProp, mLine, pigeon, mItemType
         
         -- find subMenuController
         put menu_GetDefaultController (subMenuTitle, scriptObject, true) into subMenuController
         put revRuggedID (subMenuController) into subMenuController
         
         put "disabled_" & mSuffix into mFormatProp
         if script_GetGetProp (mFormatProp, someScript) is empty then put empty into mFormatProp
         
         put text_SplitCaps (mSuffix) into mLine
         put menu_ConstructTableLine (mController, dynamicTitleProp, mTitle, mLine, mFormatProp, mItemType, subMenuTitle, subMenuController) into mTableLine
         return mItemType
      case mPrefix is "insert"
         put "insert" into mItemType
         put menu_GetDefaultController (mTitle, scriptObject, true) into mController
         
         extractInsertedTitle mCommand, mController, someScript, insertedMenuTitle, customControllerParam, dynamicTitleProp, mLine, pigeon, mItemType
         
         if pigeon is empty then -- the number of items of insertedMenuTitle = 1 then
            -- it's a whole menu to insert
            -- could insert the whole thing into the table now rather than late with "menu_CovertTable"
            
            put "disabled_" & mSuffix into mFormatProp
            if script_GetGetProp (mFormatProp, someScript) is empty then put empty into mFormatProp
            
            -- find inserted mControllers
            put menu_GetDefaultController (insertedMenuTitle, scriptObject, true) into insertedMenuController
            put revRuggedID (insertedMenuController) into insertedMenuController
            put menu_ConstructTableLine (mController, dynamicTitleProp, mTitle, "insert", mFormatProp, mItemType, insertedMenuTitle, insertedMenuController) into mTableLine
         else
            -- this is a single menu script item!
            put menu_GetDefaultController (insertedMenuTitle, scriptObject, true) into insertedMenuController
            put revRuggedID (insertedMenuController) into insertedMenuController
            put menu_ConstructTableLine (mController, dynamicTitleProp, mTitle, mLine, mFormatProp, "inserted", insertedMenuTitle, insertedMenuController) into mTableLine
         end if
         return "insert"
      default
         put menu_GetDefaultController (mTitle, scriptObject, true) into mController
         if exists(mController) is false then
            put "Cannot find Global menu" && kwote(mTitle) & "!" into someError
            opn_Notify someError, true
            -- put menu_GetDefaultController (mTitle, scriptObject, true) into mController
            return mItemType
         end if
         menu_DefaultTableLine mVersion, comLine, mCommand, mSuffix, customParam, someScript, mController, mTitle, mFormatProp, mLine, mTableLine, mItemType, submenuProp, paramProp, fixedSubMenu
         return mItemType
   end switch
end menu_TableLineFromScript

function menu_ConstructSubmenuTableLine mLine, subMenuTitle, mTitle, targetObject, mController
   breakpoint
   put menu_GetDefaultController (subMenuTitle, targetObject, true) into subMenuController
   put revRuggedID (subMenuController) into subMenuController
   
   put mLine into mSuffix
   replace space with empty in mSuffix
   put "disabled_" & mSuffix into disabledProp
   if script_GetGetProp (disabledProp, someScript) is empty then put empty into disabledProp
   
   put menu_ConstructTableLine (mController, empty, mTitle, mLine, disabledProp, "submenu", subMenuTitle, subMenuController) into mTableLine
   return mTableLine
end menu_ConstructSubmenuTableLine


--> Menu | Param Order
-
command menu_DeconstructCommandLine mVersion, handlerLine, @handlerName, @handlerPrefix, @handlerSuffix, @customParam
   put token 1 of handlerLine into handlerName
   put token 2 of item 1 of handlerLine into firstParam
   put token 1 of item 2 of handlerLine into secondParam
   
   -- the menu_Version
   if mVersion is empty then
      if param_IsObject (firstParam) then
         put empty into customParam
      else
         put firstParam into customParam -- old way ???
      end if
   else
      put secondParam into customParam -- old way ???
   end if
   
   set the itemdelimiter to "_"
   put item 1 of handlerName into handlerPrefix
   put item 2 of handlerName into handlerSuffix
end menu_DeconstructCommandLine

command menu_DefaultTableLine mVersion, comLine, mCommand, mSuffix, customParam, someScript, mController, mTitle, @mFormatProp, @mLine, @mTableLine, @mItemType, @submenuProp, @paramProp, @fixedSubMenu
   -- ignoreCall: menu_Version
   -- only add disabled_Prop if it exists in the menu_Controller (optional)
   put "disabled_" & mSuffix into mFormatProp
   if script_GetGetProp (mFormatProp, someScript) is empty then put empty into mFormatProp
   
   put text_SplitCaps (mSuffix) into mLine
   
   if the menu_Version of mController is not empty then
      if the number of items of comLine > 1 then
         -- there is more than one param
         menu_ConstructParamProp someScript, mCommand, customParam, mController, paramProp, submenuProp, fixedSubMenu
         put the result into mItemType
         put mCommand && "subMenuPath," && mTarget into pigeon
         put menu_ConstructTableLine (mController, pigeon, mTitle, mLine, mFormatProp, mItemType, submenuProp, paramProp) into mTableLine
      else
         put mCommand && "mTarget" into pigeon
         put menu_ConstructTableLine (mController, pigeon, mTitle, mLine, mFormatProp, mItemType) into mTableLine
      end if
   else
      if customParam is empty or param_IsObject (customParam) then
         put mCommand && "mTarget" into pigeon
         put menu_ConstructTableLine (mController, pigeon, mTitle, mLine, mFormatProp, mItemType) into mTableLine
      else
         menu_ConstructParamProp someScript, mCommand, customParam, mController, paramProp, submenuProp, fixedSubMenu
         put the result into mItemType
         put mCommand && "subMenuPath," && mTarget into pigeon
         put menu_ConstructTableLine (mController, pigeon, mTitle, mLine, mFormatProp, mItemType, submenuProp, paramProp) into mTableLine
      end if
   end if
   return mTableLine
end menu_DefaultTableLine


--> Script Export | Merge
-
/*
This suite of handlers uses a local array so that the merge function can work across handlers.
It depends of a particular file and folder structure of the exported script template and handlers.
*/

local LocalArray

function script_MergeHandlers scriptFile, someScript
   put scriptFile into objectFolder
   set the itemdelimiter to "/"
   delete item -1 of objectFolder
   put objectFolder into LocalArray ["ObjectFolder"]
   
   put objectFolder & "/handlers/" into handlersFolder
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


--> Deps
-
command folder_CreateNested @someFolder
   text_AddTrailing someFolder, slash
   if there is a folder someFolder then return empty
   set the itemdelimiter to "/"
   repeat with itemNum = 1 to the number of items of someFolder
      put item 1 to itemNum of someFolder & "/" into testFolder
      if there is a folder testFolder then next repeat
      create folder testFolder
   end repeat
end folder_CreateNested


--> Private
-
private function _FetchHandler hName, hType, pObject
   put LocalArray ["ObjectFolder"] into objectFolder
   
   put hName,hType into shortHkey
   put objectFolder_HandlerFolder (shortHkey, objectFolder) & "script.txt" into someFile
   
   if someFile is empty then return empty
   put url ("binfile:" & someFile) into someHandler
   -- hack_UpdateBinFile someHandler, someFile
   
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
      
      put library_FetchHandler (hName, hType) into someHandler
      put someHandler into line startLineNum of mergeScript
   end repeat
   return mergeScript
end script_MergeLines

command export_Script pAutoCommit, pObject
   -- same as when pressing compile, so may do other fancy stuff liek index menus
   if pObject is empty then put the long id of the target into pObject
   put the script of pObject into someScript
   set the exported_Script [pAutoCommit] of pObject to someScript
   put the result into scriptFile
   return scriptFile
end export_Script

private command newUpdate someScript, scriptObject, relativeFile, someFile
   -- timer_Add "git_ScriptDiff"
   -- put the git_ScriptDiff of scriptObject into gitDiif
   -- timer_Add "git_ScriptDiff"
   
   timer_Add "hdb_ScriptUpdate"
   hdb_ScriptUpdate someScript, scriptObject, relativeFile
   timer_Add "hdb_ScriptUpdate"
   
   timer_Add "git_CommitFile"
   -- if pAutoCommit is true then  
   put the script_CommitComment of the target into commitComment
   git_CommitFile someFile, commitComment, true, true
   put the result into commitResult
   timer_Add "git_CommitFile"
   
   timer_Display
   display_Lines gitDiif, "gitDiif"
   display_Lines commitResult, "commitResult"
   return someDiff
end newUpdate

command hack_UpdateBinFile @someData, someFile
   if someData contains numtochar (13) then
      -- old "file" export
      replace numtochar (13) with CR in someData
      put someData into url ("binfile:" & someFile)
   end if
end hack_UpdateBinFile

