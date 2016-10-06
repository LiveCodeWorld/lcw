script "lib_Update"
--> MetaData
-
license: GPLv3
name: lib_Update
type: library
version: 0.2

/*
Here we put only those handlers that are required to do dynamic indexing of menus for a project,
whether this is when a script is compiled or menu it is indexed when a project is launched or saved.

The key handlers are:

- set the menu_Update
- put the script_MenuTitleTable

We try to make this as fast and simple as possible, 
while making it compatible with more complex indexing.

## Future Enhancements

- Rationalise these scripts to only parse the script once!
- Change the menu tabe to an array

*/


--> Working on
-
--> menu_Update | Deps | From | lib_MenuButton
-
function menu_ExtractTableFromScript mTitle, someScript, mController
   -- used by "script_MenuTitleTableArray"
   local mLine, mTableLine, mFormatProp, submenuProp, paramProp, fixedSubMenu
   
   -- need a recursion check here???
   menu_CheckRecursionOnExtract mTitle, mController
   if the result is true then breakpoint
   
   put script_GetSuite (mTitle, someScript) into scriptSuite
   
   -- put the menu_Version of mController into mVersion -- not needed?
   put empty into mVersion
   
   -- let's not allow "command" for "menus" for speed reasons (they are message handlers after all)
   filter scriptSuite with "on *"
   put empty into mTable
   repeat for each line scriptLine in scriptSuite
      put word 2 to -1 of of scriptLine into comLine
      
      -- work out everything
      menu_TableLineFromScript mVersion, mTitle, comLine, mController, someScript, mLine, mTableLine, mFormatProp, submenuProp, paramProp, fixedSubMenu  -- uses "someScript" rather than "scriptSuite" in case usefull bits are outside of suite
      put mTableLine & CR after mTable
      
      -- set the subMenuFixed custom prop
      put the result into mItemType
      menu_SetSubmenuFixedProp mItemType, comLine, mTitle, mController, fixedSubMenu, paramProp
   end repeat
   delete char -1 of mTable
   return mTable
end menu_ExtractTableFromScript

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
            lcw_Notify someError, true
            -- put menu_GetDefaultController (mTitle, scriptObject, true) into mController
            return mItemType
         end if
         menu_DefaultTableLine mVersion, comLine, mCommand, mSuffix, customParam, someScript, mController, mTitle, mFormatProp, mLine, mTableLine, mItemType, submenuProp, paramProp, fixedSubMenu
         return mItemType
   end switch
end menu_TableLineFromScript

function menu_ConstructTableLine mController, pigeon, mTitle, mLine, mFormatProp, mItemType, submenuProp, paramProp
   set the itemdelimiter to tab
   
   put mLine into item 1 of mTableLine
   put pigeon into item 2 of mTableLine
   if exists(mController) is false then
      -- could have a menu without a defined inserted Global menu?
      put empty into item 3 of mTableLine
   else
      put revRuggedID (mController) into item 3 of mTableLine
      -- put mController into item 3 of mTableLine
   end if
   put mTitle into item 4 of mTableLine
   put mFormatProp into item 5 of mTableLine
   put mItemType into item 6 of mTableLine
   put submenuProp into item 7 of mTableLine
   put paramProp into item 8 of mTableLine
   
   put menu_CleanLine (mLine) into mSendLine
   put mSendLine into item 9 of mTableLine
   
   return mTableLine
end menu_ConstructTableLine

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


--> Update | Script
-
command script_ExportAndIndexMenus scriptObject, pExportCalls
   -- this is watch the IDE compile button dispatches
   -- so far nothing else calls this command
   -- it is designed to update the global menu index, and export handlers (but do nothing else)
   -- it can be optimised to ony loop through the script once (instead of twise as below)
   
   set the menu_Update of scriptObject to true
   script_ExportHandlersAndCalls scriptObject, pExportCalls
   put the script_File of scriptObject into scriptFile
   return scriptFile
end script_ExportAndIndexMenus

command script_ExportHandlersAndCalls someObject, pExportCalls, pScript, pDataFolder
   global gLCW
   if the optionKey is "Down" then
      set the cursor to watch
      hkeyline_DeletePlaceObject someObject -- this is too slow
   end if
   
   if pScript is empty then put the script of someObject into pScript
   urip_Update someObject, pScript
   
   put the revAvailableHandlers of someObject into handlerTable
   if handlerTable is empty then return empty -- everything is deleted before re-exporting
   
   if pDataFolder is empty then
      put the data_Folder [true] of someObject into pDataFolder
      if pDataFolder is empty then
         breakpoint
      end if
   end if
   
   if pExportCalls is true then
      -- this also deletes the "lcw_calls.txt" files
      -- which is fine if we are rebuilding them
      -- possible consider saving those files in a separate metadata folder
      revDeleteFolder pDataFolder
   end if
   
   put textStack_ScriptFile (pDataFolder, false) into scriptFile
   put pScript into mergeScript
   
   put revRuggedID (someObject) into rObject
   sort numeric descending handlerTable by word 3 of each -- from bottom up
   repeat for each line handlerTableLine in handlerTable
      set the cursor to busy
      put word 1 of handlerTableLine into hType
      put word 2 of handlerTableLine into hName
      if hName = "_" then next repeat -- could check handler is empty ?
      put word 3 of handlerTableLine into startLineNum
      put word 4 of handlerTableLine into endLineNum
      
      put line startLineNum to endLineNum of pScript into someHandler
      handler_Save handlerTableLine, pDataFolder, someHandler, pExportCalls
      
      put "[[ _FetchHandler (" & hName, hType & ") ]]" into line startLineNum to endLineNum of mergeScript
      
      -- hkeyLine_AddPlace handlerTableLine, rObject
      put word 1 to 2 of handlerTableLine into shortHkeyLine
      put word 3 to 4 of handlerTableLine into hkeyLineNums
      put hkeyLineNums into gLCW ["Hkey Place Array"][shortHkeyLine][rObject]
      
      -- as we may wish to know the local place array
      put hkeyLineNums into scriptPlaceArray [shortHkeyLine][rObject]
   end repeat
   
   script_SaveRaw scriptFile, mergeScript
   
   return scriptPlaceArray
end script_ExportHandlersAndCalls

command script_UpdatePlaceArray someObject
   -- brute force (not optimised for speed)
   hkeyLine_LoadPlaceArray
   hkeyline_DeletePlaceObject someObject
   put hkeyLine_GetPlaceArray() into hkeyPlaceArray
   hkeyline_AddPlaceObject hkeyPlaceArray, someObject
   hkeyLine_SetPlaceArray hkeyPlaceArray
   script_StoreHkeyPlaceArray hkeyPlaceArray
   return hkeyPlaceArray
end script_UpdatePlaceArray


--> menu_Update | Deps | From | model_ScriptExport
-
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


--> menu_Update | Deps | From | model_TextStack
-
function script_OrderedMenuTitles someScript
   put script_MenuToolModeArray (someScript) into menuToolModeArray
   put menuToolModeArray ["OrderedMenuTitles"] into menuTitles
   return menuTitles
end script_OrderedMenuTitles

function script_MenuToolModeArray someScript
   local menuToolModeArray
   put script_GetSuiteTitles (someScript) into suiteTitles
   
   set the itemdelimiter to "|"
   put "Menu \((.*)\)" into regularExpression
   put empty into menuTitles
   set the wholematches to true
   repeat for each line suiteTitle in suiteTitles
      put word 1 to -1 of last item of suiteTitle into lastMenuItem
      if lastMenuItem is among the items of "Menu|Menus|Submenu|Submenus" then
         put suiteTitle & CR after menuTitles
         put empty into menuToolModeArray [suiteTitle]
      else if matchtext (lastMenuItem, regularExpression, toolMode) is true then
         put suiteTitle & CR after menuTitles
         put toolMode into menuToolModeArray [suiteTitle]
      end if
   end repeat
   delete last char of menuTitles
   put menuTitles into menuToolModeArray ["OrderedMenuTitles"]
   return menuToolModeArray
end script_MenuToolModeArray


--> menu_Update | Deps | From | model_ScriptSuite
-
function script_GetSuiteTitles someScript
   -- get rid of
    put someScript into theHandlerGroups
    filter theHandlerGroups with "-->*"
    replace "--> " with empty in theHandlerGroups
    replace "-->" with empty in theHandlerGroups
    return theHandlerGroups
end script_GetSuiteTitles

function script_GetSuite suiteTitle, someScript
   -- get rid of
   script_SetSuiteOffsets suiteTitle, someScript, startLineNum, endLineNum
   if the result is true then
      put line startLineNum to endLineNum of someScript into suiteScript
      return word 1 to -1 of suiteScript
   else
      return empty
   end if
end script_GetSuite

command script_SetSuiteOffsets suiteTitle, someScript, @startLineNum, @endLineNum
   -- get rid of
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


--> Deps
-
command custom_DeleteProperty propName, targetObject, pSetName
   put the custompropertyset of targetObject into oSetName
   set the custompropertyset of targetObject to pSetName
   put the customproperties of targetObject into propArray
   put propArray [propName] into propValue
   put the customkeys of targetObject into cKeys
   line_Delete propName, cKeys
   set the customkeys of targetObject to cKeys
   if cKeys is empty then
      custom_DeleteSet pSetName, targetObject
   end if
   set the custompropertyset of targetObject to oSetName
   return propValue
end custom_DeleteProperty

command custom_DeleteSet setName, someObject
   put the custompropertysets of someObject into setNames
   line_Delete setName, setNames
   set the custompropertysets of someObject to setNames
   return setNames
end custom_DeleteSet

private command extractInsertedTitle mCommand, mController, someScript, @insertedMenuTitle, @customControllerParam, @dynamicTitleProp, @mLine, @pigeon, mItemType
   -- ignoreCall: mCommand,c
   
   if mItemType = "insert" then -- inserted version
      -- this is a single menu script item!
      -- should be the same structure as an mvc controller
      -- "Global | Library | Menu,menu_StartupLibrary sillyChoice, mTarget"
      -- with the first item refering to the controller object (or named shortcut), and the second the command
      
      try
         send mCommand to mController
         put the result into insertedInfo
      catch someError -- often a compile error
         return empty
      end try
      
      put item 1 of insertedInfo into insertedMenuTitle
      put item 2 to -1 of insertedInfo into pigeon
      put menu_CommandToText (word 1 of pigeon) into mLine
      
      put empty into customControllerParam
      put empty into dynamicTitleProp
   else if mItemType = "submenu" then -- submenu version
      
      put empty into mLine
      put script_GetCommand (mCommand, someScript) into menuHandler
      
      set the wholematches to true
      put wordoffset ("menu_DoSub", menuHandler) into wordNum
      if wordNum = 0 then
         -- now lets try the return technique used by "insert"
         try
            send mCommand to mController
            put the result into insertedInfo
            put item 1 of insertedInfo into insertedMenuTitle
            put item 2 of insertedInfo into customControllerParam
         catch someError -- often a compile error
            put empty into insertedMenuTitle
            put empty into customControllerParam
            return empty
         end try
      else
         delete word 1 to wordNum of menuHandler
         put token 1 of line 1 of menuHandler into insertedMenuTitle
         put token 3 of line 1 of menuHandler into customControllerParam
      end if
      
      -- no longer stores pigeon to send, but calculates from subMenuTitle + scriptObject
      -- put mCommand && "subMenuPath, mTarget" into pigeon
      put empty into pigeon
      put empty into dynamicTitleProp
   end if
end extractInsertedTitle

private function menu_CommandToText handlerName
   -- was "menu_TextFromCommand"
   -- used only by "extractInsertedTitle"
   
   set the itemdelimiter to "_"
   put item 2 of handlerName into mSuffix
   put text_SplitCaps(mSuffix) into mLine
   return mLine
end menu_CommandToText
