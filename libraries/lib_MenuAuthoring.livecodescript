script "lib_MenuAuthoring"
--> MetaData
-
license: GPLv3
name: lib_MenuAuthoring
type: library
version: 0.1


/*
This stack is for autoring menus.

Here we begin to start afresh with new menu model.
Specifically we concentrate on menu_Update and globa; menus for fast indexing.

The dependencies for "menu_Update' are in the stack "lib_Update"
When they have been rationalised we can move them here, or to a new stack "model_Menu"
See also lib_MenuButton for the handlers that draw the actual menus that are used.

See also "menu_ConstructTemplateScript" of stack "lib_ViewTemplate"

*/


--> Working on
-
/*
menu_Title should probably only be hand scripted as a local getprop ???

getprop menu_DefaultTitle
   -- see also "view_MenuTitle"
   put the long id of the target into targetObject
   put the view_Object of targetObject into viewObject
   if exists(viewObject) is false then put targetObject into viewObject
   
   put the view_Name of viewObject into viewName
   if viewName is empty then return empty
   
   set the itemdelimiter to "|"
   if the number of items of viewName > 2 then delete item -1 of viewName -- experimental (default to class of more general owner)
   put menu_TitleFromViewName (viewName) into mTitle
   return mTitle
end menu_DefaultTitle

getprop menu_BurntTitle
   put the long id of the target into targetObject
   put the view_Object of targetObject into someView
   if exists(someView) is false then put targetObject into someView
   
   lock messages
   put the menu_Title of someView into mTitle
   unlock messages
   return mTitle
end menu_BurntTitle

setprop menu_BurntTitle mTitle
   put the long id of the target into targetObject
   put the view_Object of targetObject into someView
   if exists(someView) is false then put targetObject into someView
   
   get the name of someView
   lock messages
   set the menu_Title of someView to mTitle
   unlock messages
   return the result
end menu_BurntTitle

getprop menu_Title
   -- simple version that does not refer to menu_Controller, local burn then default if empty
   -- can be over-ridden by a menu_Title handler in the card script
   -- so try to avoid putting these handers in a views script
   
   put the long id of the target into targetObject
   put the menu_BurntTitle of targetObject into mTitle
   if mTitle is not empty then return mTitle
   put the menu_DefaultTitle of targetObject into mTitle
   
   if mTitle is empty then
      -- quick hack
      -- this version does not getch the first mTitle in the script as arrays are not numerically indexed
      put the menu_DataArray of targetObject into menuDataArray
      put keys (menuDataArray) into mTitles
      -- sort mTitles
      return line 1 of mTitles
   end if
   return mTitle
end menu_Title

getprop menu_Title
   -- simple version that does not refer to menu_Controller, local burn then default if empty
   -- can be over-ridden by a menu_Title handler in the card script
   -- so try to avoid putting these handers in a views script
   
   put the long id of the target into targetObject
   get the name of targetObject
   put the menu_BurntTitle of targetObject into mTitle
   if mTitle is not empty then return mTitle
   put the menu_DefaultTitle of targetObject into mTitle
   -- if mTitle is empty then put "Menu" into mTitle
   return mTitle
end menu_Title

setprop menu_Title mTitle
   set the menu_BurntTitle of the target to mTitle
   return the result
end menu_Title

*/


--> Menu | Update
-
setprop menu_Update someBoolean
   -- let's fix and index the menus 
   global gLCW
   
   menu_DeleteActiveArray
   put the long id of the target into scriptObject
   
   put the script_MenuTitleTableArray of scriptObject into mTitleTableArray
   if mTitleTableArray is not an array then return empty
   if someBoolean is true then
      set the menu_DataArray of scriptObject to mTitleTableArray
   end if
   
   -- now update Global menus
   repeat for each key gMenuTile in mTitleTableArray
      if word 1 of gMenuTile = "Global" and word 2 of gMenuTile = "|" then
         put mTitleTableArray [gMenuTile] into gMenuTable
         
         -- menu_NormalizeTitle gMenuTile
         put gMenuTable into gLCW ["Global Menus"][gMenuTile]["gMenuTable"]
         put scriptObject into gLCW ["Global Menus"][gMenuTile]["mController"]
         
         -- probably not really needed
         put gMenuTable into menuTitleArray [gMenuTile]["gMenuTable"]
         put scriptObject into menuTitleArray [gMenuTile]["mController"]
      end if
   end repeat
   
   return menuTitleArray
end menu_Update

getprop script_MenuTitleTableArray
   -- this is what constructs the mTitleTableArray from a script
   local mTitleTableArray
   
   put the long id of the target into mController
   put the script of mController into someScript
   put the revAvailableHandlers of mController into hTable
   
   -- put script_OrderedMenuTitles (someScript) into mTitles
   put someScript into mTitleLines
   filter mTitleLines with "--> * Menu"
   
   repeat for each line mTitleLine in mTitleLines
      put word 2 to -1 of mTitleLine into mTitle
      put menu_ExtractTableFromScript (mTitle, someScript, hTable, mController) into mTable
      put mTable into mTitleTableArray [mTitle]
   end repeat
   return mTitleTableArray
end script_MenuTitleTableArray

function menu_ExtractTableFromScript mTitle, someScript, hTable, mController
   -- used by "script_MenuTitleTableArray"
   local mLine, mTableLine, mFormatProp, submenuProp, paramProp, fixedSubMenu
   
   -- need a recursion check here???
   menu_CheckRecursionOnExtract mTitle, mController
   if the result is true then breakpoint
   
   -- is there a clever way to use hTable an "on" ???
   put script_GetSuite (mTitle, someScript) into scriptSuite
   -- let's not allow "command" for "menus" for speed reasons (they are message handlers after all)
   filter scriptSuite with "on *"
   
   put empty into mTable
   repeat for each line scriptLine in scriptSuite
      put word 2 to -1 of of scriptLine into comLine
      
      menu_TableLineFromScript mVersion, mTitle, comLine, mController, someScript, hTable, mLine, mTableLine, mFormatProp, submenuProp, paramProp, fixedSubMenu
      put mTableLine & CR after mTable
      
      -- set the subMenuFixed custom prop
      put the result into mItemType
      menu_SetSubmenuFixedProp mItemType, comLine, mTitle, mController, fixedSubMenu, paramProp
   end repeat
   delete char -1 of mTable
   return mTable
end menu_ExtractTableFromScript

command menu_TableLineFromScript mVersion, mTitle, comLine, scriptObject, someScript, hTable, @mLine, @mTableLine, @mFormatProp, @submenuProp, @paramProp, @fixedSubMenu 
   -- uses "someScript" rather than "scriptSuite" in case usefull bits are outside of suite
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
         
         _extractInsertedTitle mCommand, mController, someScript, hTable, subMenuTitle, customControllerParam, dynamicTitleProp, mLine, pigeon, mItemType
         
         -- find subMenuController
         put menu_GetDefaultController (subMenuTitle, scriptObject, true) into subMenuController
         put revRuggedID (subMenuController) into subMenuController
         
         put _constructDisabledGetpropName (mSuffix,  someScript, hTable) into mFormatProp
         
         put text_SplitCaps (mSuffix) into mLine
         put menu_ConstructTableLine (mController, dynamicTitleProp, mTitle, mLine, mFormatProp, mItemType, subMenuTitle, subMenuController) into mTableLine
         return mItemType
      case mPrefix is "insert"
         put "insert" into mItemType
         put menu_GetDefaultController (mTitle, scriptObject, true) into mController
         
         _extractInsertedTitle mCommand, mController, someScript, hTable, insertedMenuTitle, customControllerParam, dynamicTitleProp, mLine, pigeon, mItemType
         
         if pigeon is empty then -- the number of items of insertedMenuTitle = 1 then
            -- it's a whole menu to insert
            -- could insert the whole thing into the table now rather than late with "menu_CovertTable"
            
            put _constructDisabledGetpropName (mSuffix,  someScript, hTable) into mFormatProp
            
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
            -- lcw_Notify someError, true
            breakpoint
            -- put menu_GetDefaultController (mTitle, scriptObject, true) into mController
            return mItemType
         end if
         menu_DefaultTableLine mVersion, comLine, mCommand, mSuffix, customParam, someScript, hTable, mController, mTitle, mFormatProp, mLine, mTableLine, mItemType, submenuProp, paramProp, fixedSubMenu
         return mItemType
   end switch
end menu_TableLineFromScript

command menu_DefaultTableLine mVersion, comLine, mCommand, mSuffix, customParam, someScript, hTable, mController, mTitle, @mFormatProp, @mLine, @mTableLine, @mItemType, @submenuProp, @paramProp, @fixedSubMenu
   -- ignoreCall: menu_Version
   -- only add disabled_Prop if it exists in the menu_Controller (optional)
   put "disabled_" & mSuffix into mFormatProp
   
   put "G" && mFormatProp into shortHkeyLine
   put hkeyLine_GetHandler (shortHkeyLine, hTable, someScript) into getpropHandler  -- doing this twice
   if getpropHandler is empty then put empty into mFormatProp
   -- if script_GetGetProp (mFormatProp, someScript) is empty then put empty into mFormatProp
   
   put text_SplitCaps (mSuffix) into mLine
   
   -- new way (assumes mTarget is always passed as the ifirst param
   if the number of items of comLine > 1 then
      -- there is more than one param
      menu_ConstructParamProp someScript, hTable, mCommand, customParam, mController, paramProp, submenuProp, fixedSubMenu
      put the result into mItemType
      put mCommand && "subMenuPath," && mTarget into pigeon
      put menu_ConstructTableLine (mController, pigeon, mTitle, mLine, mFormatProp, mItemType, submenuProp, paramProp) into mTableLine
   else
      put mCommand && "mTarget" into pigeon
      put menu_ConstructTableLine (mController, pigeon, mTitle, mLine, mFormatProp, mItemType) into mTableLine
   end if
   
   return mTableLine
end menu_DefaultTableLine


--> menu_ConstructParamProp
-
command menu_ConstructParamProp someScript, hTable, mCommand, customParam, mController, @paramProp, @submenuProp, @fixedSubMenu
   /*
   A complicated handler that introspects to check if there are disables_ and getprops for menus.
   
   These issues may not still be true???
   Putting a cProp handler with a param into a variable works
   But no space between handler and "["
   Also no quotes around variable
   */
   
   put empty into mFormatProp
   put empty into submenuProp
   put empty into paramProp
   put empty into fixedSubMenu
   
   switch
      case customParam is empty
         return empty
      case param_IsBoolean (customParam)
         set the itemdelimiter to "_"
         put item 2 of mCommand into commandBody
         if commandBody is empty then return empty
         
         put script_ParamToHandlerName (commandBody) into paramProp
         put "submenu_Boolean" into submenuProp
         return "boolean"
      default
         -- not a special case
         -- so it is either a fixed menu based on the "Case conditions"
         -- or a "custom" menu based on a getprop submenuProp handler
         
         put script_ParamToHandlerName (customParam) into paramProp
         if last char of paramProp = "y" then
            put char 1 to -2 of paramProp & "ies" into submenuProp
         else
            put paramProp & "s" into submenuProp
         end if
         
         put token 1 of submenuProp into getPropName
         
         put "G" && getPropName into shortHkeyLine
         put hkeyLine_GetHandler (shortHkeyLine, hTable, someScript) into getpropHandler
         
         if getpropHandler is not empty then
            -- there is a getprop submenuProp handler in the mController script
            return "custom submenu"
         end if
         
         try
            -- should be same as menu_ConvertTable (but on compile I do not know mTarget)
            put submenuProp into submenuProperty
            put the submenuProperty of mController into testSubMenu
            if testSubMenu is not empty then
               -- allows global submenu properties to be defined
               return "custom external"
            end if
         catch tError
            -- looks like submenuProperty could require a param (ie mTarget)
            -- so let's see if we can find some case conditions
         end try
         
         -- is there a "case" statement in the script?
         put "M" && mCommand into shortHkeyLine
         put hkeyLine_GetHandler (shortHkeyLine, hTable, someScript) into menuHandler
         -- put script_GetCommand (mCommand, someScript) into menuHandler
         
         put handler_ExtractCaseConditions (menuHandler) into fixedSubMenu
         
         line_Delete "default", fixedSubMenu
         if fixedSubMenu is not empty then
            put "submenu_Fixed[" & mCommand & "]" into submenuProp
            return "fixed"
         else
            -- even though the custom prop has failed
            -- this may just be a requirement for a param (and so is fine in real use)
            -- allows (global) getprop handlers outside of the controllers script
            return "custom external"
         end if
   end switch
end menu_ConstructParamProp


--> Private
-
private function _constructDisabledGetpropName mSuffix, someScript, hTable
   /*
   To save a lot of dependency code we could use:
   -- put the revAvailableHandlers of scriptObject into mTable
   for speed we should work out mTable in advance (when we get the script) and pass it as a param
   */
   
   put "disabled_" & mSuffix into mFormatProp
   
   -- put script_GetGetProp (mFormatProp, someScript) into getpropHandler
   put "G" && mFormatProp into shortHkeyLine
   put hkeyLine_GetHandler (shortHkeyLine, hTable, someScript) into getpropHandler
   
   if getpropHandler is empty then put empty into mFormatProp
   return mFormatProp
end _constructDisabledGetpropName

private command _extractInsertedTitle mCommand, mController, someScript, hTable, @insertedMenuTitle, @customControllerParam, @dynamicTitleProp, @mLine, @pigeon, mItemType
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
      
      -- put script_GetCommand (mCommand, someScript) into menuHandler
      put "M" && mCommand into shortHkeyLine
      put hkeyLine_GetHandler (shortHkeyLine, hTable, someScript) into getpropHandler
      
      
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
end _extractInsertedTitle

private function menu_CommandToText handlerName
   -- was "menu_TextFromCommand"
   -- used only by "_extractInsertedTitle"
   
   set the itemdelimiter to "_"
   put item 2 of handlerName into mSuffix
   put text_SplitCaps (mSuffix) into mLine
   return mLine
end menu_CommandToText

private function script_ParamToHandlerName customParam
   put word 1 of customParam into customParam
   put tolower(char 1 of customParam) into char 1 of customParam
   
   repeat with charNum = 1 to the number of chars of customParam
      if text_StartsWithCaps(char charNum of customParam) is true then
         put "_" before char charNum of customParam
         return customParam
      end if
   end repeat
   return customParam
end script_ParamToHandlerName

private function param_IsBoolean customParam
   return customParam is among the items of "boolean,someBoolean,isBoolean"
end param_IsBoolean


--> Menu | Edit
-
command menu_Edit pMenuTitle
   if pMenuTitle is empty then put menu_GetSentTitle() into pMenuTitle
   
   set the itemdelimiter to "|"
   if word 1 to -1 of item 1 of pMenuTitle is "Global" then
      put menu_GetGlobalController (pMenuTitle) into mController
   else if pMenuTitle is empty then
      put menu_GetSentTitle() into pMenuTitle
      put menu_ControllerFromTitlePath (pMenuTitle) into mController
   else
      put menu_ControllerFromTitlePath (pMenuTitle) into mController
   end if
   
   if exists (mController) is false then
      answer warning merge ("Cannot locate controller for menu '[[pMenuTitle]]'!")
      exit to top
   end if
   
   -- Let's edit the mController
   edit the script of mController
   put the script of mController into someScript
   
   -- Find the place and scroll to the mTitle
   put "-->" && pMenuTitle into suiteTitle
   script_ScrollToLine suiteTitle, someScript
 end menu_Edit

command script_ScrollToLine suiteTitle, someScript
   set the wholematches to true
   put lineOffset (suiteTitle, someScript) into lineNum
   if lineNum = 0 then return empty
   
   put rev_ScriptEditorField() into someField   
   field_ScrollToLine lineNum, someField
end script_ScrollToLine

command field_ScrollToLine lineNum, fieldObject, pSelectLine
   -- does not seem accurate for large line numbers (it's an underestimate) ???
   
   if lineNum = 0 then
      put 0 into someScroll
   else if lineNum is a number then
      put the effective textHeight of fieldObject into lineHeight
      put ((lineNum - 1) * lineHeight) - 0 * the height of fieldObject into someScroll
   else -- any text = "bottom"
      -- bit of a hack (but works :)
      put the effective textHeight of fieldObject into lineHeight
      put the number of lines of the text of fieldObject into lineNum
      put ((lineNum - 1) * lineHeight) - 0 * the height of fieldObject into someScroll
   end if
   set the scroll of fieldObject to someScroll
   if pSelectLine is not false then
      select line lineNum of fieldObject
   end if
end field_ScrollToLine

