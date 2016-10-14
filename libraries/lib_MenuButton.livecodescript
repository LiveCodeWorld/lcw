script "lib_MenuButton"
--> MetaData
-
license: GPLv3
name: lib_MenuButton
type: library
version: 0.9

/*
Latest library to implement dynamic menus from script introspection.
These handlers used to be in the standalone "View|Menu|Button" stack script

It is designed to be just the minimal set of handlers needed to implement the handlers
:   menu_PullDown, menu_PopUp
and to support the behavior of the menu_Button.

The menu_Button contains a simple script:

on menuPick menuPath
   menu_SendMessage menuPath
end menuPick

which dispatches the appropriate command to the controller that handles the menu action.
*/

--> Working on
-
function menu_Exists mTitle
   put menu_GetGlobalController (mTitle) into mController
   return exists (mController)
end menu_Exists

command menu_Do mCommand, pMenuTitle, pMenuTarget, pSubMenuPath
   -- if pMenuTitle is empty we search all loaded menus and return the first instance
   if pMenuTarget is empty then put the long id of the target into pMenuTarget -- this is often the wrong target so set the right one with this parameter
   
   put menu_FindGlobalController (mCommand, pMenuTitle) into mController
   if exists (mController) is false then
      breakpoint
      put menu_FindGlobalController (mCommand, pMenuTitle)
      put menu_GetGlobalController (pMenuTitle) into mController
      if exists (mController) then
         edit the script of mController
      end if
      return empty
   end if
   
   dispatch mCommand to mController with mTarget,pSubMenuPath
   switch it
      case "handled"
         return it
      case "passed"
         return it
      case "not handled"
         breakpoint
         -- menu_SendMessageError tError
         return it
   end switch
end menu_Do

function menu_FindGlobalController mCommand, pMenuTitle
   global gLCW
   if pMenuTitle is empty then
      put gLCW ["Global Menus"] into gMenuArray
   else
      put gLCW ["Global Menus"][pMenuTitle] into gMenuArray [mTitle]
   end if
   
   repeat for each key mTitle in gMenuArray
      put gMenuArray [mTitle]["gMenuTable"] into gMenuTable
      repeat for each line mTableLine in gMenuTable
         menu_DeconstructTableLine mTableLine, mController, pigeon, mTitle, mLine, mFormatProp, mItemType, submenuProp, paramProp, mSendLine
         if word 1 of pigeon = mCommand then
            return mController
         end if
      end repeat
   end repeat
   return empty
end menu_FindGlobalController

getprop view_MenuTitle [useGlobalName]
   -- see also menu_DefaultTitle
   put the view_Name of the target into viewName
   put menu_TitleFromViewName (viewName) into mTitle
   if useGlobalName is true then put "Global | " before mTitle
   return mTitle
end view_MenuTitle

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

function menu_GlobalTitleFromViewName vName
   put "Global |" && menu_TitleFromViewName (vName) into globalMenuTitle
   return globalMenuTitle
end menu_GlobalTitleFromViewName

function view_FromModuleStackName moduleStackName
   replace "_" with "|" in moduleStackName
   return moduleStackName
end view_FromModuleStackName

function menu_TitleFromViewName viewName, pLevelAbove
   set the itemdelimiter to "|"
   delete item 1 of viewName
   if pLevelAbove is a number then delete item -1 to - pLevelAbove of viewName   
   menu_NormalizeTitle viewName
   put viewName && "| Menu" after normalizedMenu
   return normalizedMenu
end menu_TitleFromViewName

command menu_NormalizeTitle @mTitle
   set the itemdelimiter to "|"
   repeat for each item someItem in mTitle
      put word 1 to -1 of someItem into someText
      put space & someText & space & "|" after normalizedMenuTitle
   end repeat
   delete char -2 to -1 of normalizedMenuTitle
   delete char 1 of normalizedMenuTitle
   put normalizedMenuTitle into mTitle
end menu_NormalizeTitle

function menu_GetTextFromTitleTable mTitleTable, targetObject, pMenuTarget
   -- repeats over mTitles in table
   -- called by "menu_PullDown" etc to dynamically create and "set the menu_Text of pTargetObject"
   local mText, pTitlePath, mTopTitle
   global gLCW
   
   replace comma with tab in mTitleTable
   set the itemdelimiter to tab
   repeat for each line mTitleLine in mTitleTable
      put item 1 of mTitleLine into mTitle
      put item 2 of mTitleLine into mType
      put item 3 of mTitleLine into pTextPath
      
      if mTitleLine = "-" then
         put "-" & CR after mText
         next repeat
      end if
      
      -- menu_CheckRecursionOnGet mTitle, targetObject
      menu_CheckRecursionOnExtract mTitle, targetObject
      if the result is true then
         breakpoint
         next repeat
      end if
      
      put the menu_Table [mTitle] of targetObject into mTable
      
      switch 
         case mType = "submenu"  
            if pTextPath is empty then put menu_MenuTextFromTitle (mTitle) into pTextPath -- old ?? Why not use "put mType into pTitlePath"
            
            put menu_ConvertTable (mTable, targetObject, pTitlePath, pTextPath, pMenuTarget) into moreMenuText
            if moreMenuText is empty then
               -- submenu is empty
            else
               put pTextPath  & CR after mText
               put outline_IncreaseIndent (moreMenuText) & CR after mText
            end if
            break
         case mType is not empty
            put mType into pTitlePath
            put menu_ConvertTable (mTable, targetObject, pTitlePath, pTextPath, pMenuTarget) into moreMenuText
            if moreMenuText is not empty then
               put moreMenuText & CR after mText
            end if
            break
         default
            put menu_ConvertTable (mTable, targetObject, pTitlePath, pTextPath, pMenuTarget) into moreMenuText
            if moreMenuText is not empty then
               put moreMenuText & CR after mText
            end if
      end switch
   end repeat
   delete char -1 of mText
   return mText
end menu_GetTextFromTitleTable

command menu_DeleteActiveArray
   global gLCW
   delete variable gLCW ["activeMenuArray"]
end menu_DeleteActiveArray

command menu_CheckRecursionOnExtract mTitle, mController
   -- used by "menu_ExtractTableFromScript"
   global gLCW
   
   put menu_TitleIsGlobal (mTitle) into menuIsGlobal
   if menuIsGlobal is true then
      put gLCW ["activeMenuArray"]["Recursion title Check"][mTitle] is not empty into isRepeated
   else
      put gLCW ["activeMenuArray"]["Recursion title Check"][mController][mTitle] is not empty into isRepeated
   end if
   
   -- put gLCW ["activeMenuArray"]["Recursion title Check"] into titlesSoFar
   -- if mTitle is among the lines of titlesSoFar then
   
   if isRepeated is true then
      put merge ("[[menu_CheckRecursionOnExtract]]: Recursion: '[[mTitle]]'. Check for duplicate menus in script.") into errorMessage 
      put errorMessage
      display_ActiveMenuArray mTitle
      edit the script of mController
      
      breakpoint
      return true
   end if
   
   -- this is not checking for recursion (we check for a repeat - which is stronger but has false positives)
   if menuIsGlobal is true then
      put "menu_CheckRecursionOnExtract" into gLCW ["activeMenuArray"]["Recursion title Check"][mTitle]
   else
      put "menu_CheckRecursionOnExtract" into gLCW ["activeMenuArray"]["Recursion title Check"][mController][mTitle]
   end if
   
   /*
   -- should speed up using an array
   line_Insert mTitle, titlesSoFar
   put titlesSoFar into gLCW ["activeMenuArray"]["Recursion title Check"]
   */
   return false
end menu_CheckRecursionOnExtract

-- command menu_CheckRecursionOnGet mTitle, targetObject
-- would be nice to disable or indicate more clearly where the recursion is?
global gLCW

if word 1 of mTitle = "Global" then
   if gLCW ["activeMenuArray"]["recursion check"][mTitle] is true then 
      breakpoint
      return empty
   else
      put true into gLCW ["activeMenuArray"]["recursion check"][mTitle]
   end if
else
   if gLCW ["activeMenuArray"]["recursion check"][mTitle][targetObject] is true then -- recursion check
      breakpoint
      return empty
   else
      put true into gLCW ["activeMenuArray"]["recursion check"][mTitle][targetObject]
   end if
end if
end menu_CheckRecursionOnGet

function menu_TitleIsGlobal mTitle
   set the itemdelimiter to "|"
   return word 1 to -1 of item 1 of mTitle = "Global"
end menu_TitleIsGlobal

command display_ActiveMenuArray mTitle
   global gLCW
   
   put gLCW ["activeMenuArray"] into activeMenuArray
   put merge ("Recursion: '[[mTitle]]',menu_CheckRecursionOnExtract") into someTitle
   display_Array activeMenuArray, someTitle
end display_ActiveMenuArray


--> Menu | Hierarchy
-
/*
This is overly complicated and should be removed.
Searcing for a menu in the script hierarchy is a convenience we can do without.
Or change into a tool.
*/

getprop script_Hierarchy [pProjectName]
   put object_ListFrontScripts (pProjectName) into hObjects
   put CR & the object_Hierarchy [pWhichBehaviors] of the target after hObjects
   put CR & stack_ListUsed() after hObjects
   put CR & object_ListBackScripts (pProjectName) after hObjects
   return word 1 to -1 of hObjects
end script_Hierarchy

function object_ListFrontScripts pProjectName
   -- /Applications/LiveCode Community 8.1.0 (dp 3).app/Contents/Tools/Toolset/libraries/revshortcutslibrary.livecodescript
   put the frontscripts into longIDs
   ide_FilterOutStacks longIDs
   return longIDs
end object_ListFrontScripts

function object_ListBackScripts pProjectName
   -- /Applications/LiveCode Community 8.1.0 (dp 3).app/Contents/Tools/Toolset/libraries/revshortcutslibrary.livecodescript
   put the backscripts into longIDs
   ide_FilterOutStacks longIDs
   return longIDs
end object_ListBackScripts

command ide_FilterOutStacks @longIDs
   put rev_AppContentsFolder() into revAppContentsFolder
   
   set the itemdelimiter to slash
   repeat for each line tObject in longIDs
      if exists(tObject) is false then next repeat
      put token -1 of tObject into stackPath
      if stackPath begins with revAppContentsFolder then next repeat
      put revRuggedId (tObject) & CR after filteredObjects
   end repeat
   delete char -1 of filteredObjects
   put filteredObjects into longIDs
end ide_FilterOutStacks

function rev_AppToolsFolder
   put rev_AppContentsFolder() & "Tools/" into revToolsLibraryFolder
   return revToolsLibraryFolder
end rev_AppToolsFolder

function rev_ToolsLibraryFolder
   put rev_AppContentsFolder() & "Tools/Toolset/libraries/" into revToolsLibraryFolder
   return revToolsLibraryFolder
end rev_ToolsLibraryFolder

function rev_AppContentsFolder
   -- /Applications/LiveCode Community 8.1.0 (dp 3).app/Contents/
   set the itemdelimiter to slash
   put the engine folder into appContentsFolder
   put empty into item -1 of appContentsFolder
   return appContentsFolder
end rev_AppContentsFolder

getprop object_Hierarchy
   put the long id of the target into targetObject
   repeat
      put revRuggedId (targetObject) & CR after hObjects
      put targetObject into someObject
      repeat
         put the behavior of someObject  into bObject
         if exists (bObject) is false then exit repeat
         
         put revRuggedId (bObject) & CR after hObjects
         put bObject into someObject
      end repeat
      
      if word 4 of targetObject is not "of" then
         delete char -1 of hObjects
         return hObjects
      end if
      
      delete word 1 to 4 of targetObject
   end repeat
end object_Hierarchy


--> Menu | Target
-
/*
Aiming to remove  menu_ToolTitle. It is no longer used in this stack.
It overcomplicates things. 

Tool logic should be placed in the details of the tools script - not the library here.
*/

function menu_TargetFromGlobal mPath
   -- used by "menu_ConvertTable" and "menu_SendMessage"
   
   put menu_TitlePathFromPath (mPath) into mTitlePath
   put menu_GetTopController() into mTopController
   
   -- removed "menu_GetTargetOveride"
   -- here we want to be able to change the mTarget depending on mTitlePath
   
   put the menu_Target [mTitlePath] of mTopController into mTarget
   if mTarget is not empty or mTarget is an array then
      put mTarget into gLCW ["activeMenuArray"]["top"]["mTarget"]
      return mTarget
   end if
   
   -- so go get a default!
   put menu_GetTargetObject() into targetObject
   put _GetDefaultMenuTarget (mPath, mTitlePath, targetObject) into mTarget
   put mTarget into gLCW ["activeMenuArray"]["top"]["mTarget"]
   return mTarget
end menu_TargetFromGlobal

private function _GetDefaultMenuTarget mPath, mTitlePath, targetObject
   -- a default can be dynamic and defined in the view using a "getprop menu_Target" handler
   put the menu_Target [mTitlePath] of targetObject into mTarget
   if mTarget is not empty then
      put mTarget into gLCW ["activeMenuArray"]["top"]["mTarget"]
      return mTarget -- could be something other than an object
   end if
   
   -- Finally if all else fails it returns the view or the target object.
   put the view_Object of targetObject into someView
   if exists(someView) is false then put targetObject into someView
   return someView
end _GetDefaultMenuTarget


--> Menu | Edit
-
on menu_EditMenuItem pigeon, foundPath, subMenuPath, mController, sentMenuTarget
   put "What would you like to do with the script of this menu item?" into someQuestion
   answer someQuestion with "Cancel" or "Edit"
   if it = "Edit" then
      menu_EditMenuItemScript pigeon, mController, sentMenuTarget
   else if it = "Export" then
      menu_ExportMenuItemScript pigeon, mController
   end if
   return the result
end menu_EditMenuItem

command menu_EditMenuItemScript pigeon, mController, sentMenuTarget
   put word 1 of pigeon into handlerName
   put hkey_Construct (handlerName, "c", mController) into hKey
   try
      hkey_Edit hKey
   catch e
      edit the script of mController
   end try
   return hKey
end menu_EditMenuItemScript

command menu_ExportMenuItemScript pigeon, mController
   put word 1 of pigeon into handlerName
   put hkey_Construct (handlerName, "c", mController) into hKey
   -- hkey_CreateTest hKey
end menu_ExportMenuItemScript

getprop menu_OptionEdit
   put the uOPN ["menu_OptionEdit"] of me is not false into someBoolean
   return someBoolean
end menu_OptionEdit

getprop menu_Controller [pMenuTitle]
   put the long id of the target into targetObject
   
   -- put the burnt_MenuController [pMenuTitle] of targetObject into mController
   -- if exists(mController) then return mController
   
   -- put menu_GetDefaultController (pMenuTitle, targetObject, false) into mController
   -- check if it is a global menu
   -- if menu_TitleIsGlobal (mTitle) then
   put menu_GetGlobalController (pMenuTitle) into mController
   if exists (mController) is true then
      return mController
   end if
   -- end if
   
   return targetObject
end menu_Controller

function menu_ConvertTable mTable, mView, pTitlePath, pTextPath, pMenuTarget, pMenuIsDisabled
   -- ignoreCall:  dynamicSubmenuTitleProp,g
   -- ignoreCall:  •••,c
   -- this is called first for each line of mTable to draw a menu
   -- the only handler to use "menu_GetDefaultController" aside from the "menu_Controller"
   
   global gLCW
   local mPath, mTitlePath, mController, pigeon, mTitle, mLine, mFormatProp, mItemType, submenuProp, paramProp   
   
   repeat for each line mTableLine in mTable
      if mTableLine is "-" then
         put "-" & CR after mText
         next repeat
      end if
      menu_DeconstructTableLine mTableLine, mController, pigeon, mTitle, mLine, mFormatProp, mItemType, submenuProp, paramProp, mSendLine
      
      switch
         case mItemType is among the items of "submenu"
            put submenuProp into subMenuTitle
            
            if pTextPath is empty then
               put mSendLine into mPath
            else
               put pTextPath & "|" & mSendLine into mPath
            end if
            
            if pTitlePath is empty then
               put mTitle & "/" & subMenuTitle into mTitlePath -- first time
               -- should I put something into pTitlePath?
            else
               -- already added subMenuTitle first time above
               put pTitlePath & "/" & mTitle & "/" & subMenuTitle into mTitlePath
               -- breakPoint
            end if
            break
         case mItemType = "insert"
            put pTextPath into mPath
            
            if pTitlePath is empty then
               put mTitle into mTitlePath
            else
               put pTitlePath & "/" & mTitle into mTitlePath     
               -- put pTitlePath into mTitlePath
            end if
            break
         default
            if pTextPath is empty then
               put mSendLine into mPath
            else
               put pTextPath & "|" & mSendLine into mPath
            end if
            
            if pTitlePath is empty then
               put mTitle into mTitlePath
            else
               put pTitlePath & "/" & mTitle into mTitlePath
            end if
      end switch
      if mTitlePath begins with "/" then breakPoint
      addToMenuActiveArray mPath, mTitlePath, pigeon, mController, mView, mItemType, pMenuTarget
      if exists (mController) is false then next repeat
      
      try
         -- first lets allow the mController to initialise itself and avoid repeat calls to common routines
         if initArray [mController]["menu_Init"] is not true then
            -- now it gets sent one time only for each mController, or recursive call to a submenu
            -- could cut out multiple call on recursion with some hacking with locals or globals.
            dispatch "menu_Init" to mController with mView,mPath,mTitlePath -- think mView is the same as targetObject
            put true into initArray [mController]["menu_Init"]
         end if
         
         -- get the mTarget next
         if pMenuTarget is empty then
            put menu_TargetFromGlobal (mPath) into mTarget -- mTarget must be same as what "menu_SendMessage 
         else
            put pMenuTarget into mTarget
         end if
         
         -- now check the mTarget
         -- if pMenuIsDisabled is empty then
         -- first time (not used for recursive sub menus - these are already checked in the recursive handler)
         -- we get an error if mTarget is custom set to an array.
         try
            put initArray [mController]["menu_CheckTarget"][mTarget]["already checked"] is true into menuAlreadyChecked
            if menuAlreadyChecked is true then
               put initArray [mController]["menu_CheckTarget"][mTarget]["targetOK"] into targetOK
            else
               put the menu_CheckTarget [mTarget] of mController into targetOK
               put targetOK into initArray [mController]["menu_CheckTarget"][mTarget]["targetOK"]
               put true into initArray [mController]["menu_CheckTarget"][mTarget]["already checked"]
            end if
         catch e
            put false into targetOK
            
            breakPoint
            put the menu_CheckTarget [mTarget] of mController into targetOK
         end try
         
         switch targetOK
            case "delete"
               next repeat
               break
            case false
               put targetOK is false into menuIsDisabled
               break
            case true
               put targetOK is false into menuIsDisabled
               break
            default
               -- could be used to replace a disabled menu with another menu
               -- use to fix reason why menu is disabled for instance
               put targetOK is false into menuIsDisabled
         end switch
         -- else
         -- allows override (but should false = empty = do another check for recursive menus?)
         -- put pMenuIsDisabled into menuIsDisabled
         -- end if
         
         switch mItemType
            -- case mItemType = "inserted"
            case "insert"
               -- not sure "insert" is working fully (with disabling etc 
               -- needs testing !!!
               -- seems not to check the menu_CheckTarget?
               put pigeon into dynamicSubmenuTitleProp
               
               if subMenuProp is empty then
                  -- old version of mTable
                  put subMenuTitle into insertedMenuTitle
                  put the menu_Controller [insertedMenuTitle] of mController into insertedMenuController
                  -- put menu_GetDefaultController (insertedMenuTitle, mController, false) into insertedMenuController
               else if dynamicSubmenuTitleProp is empty then
                  put subMenuProp into insertedMenuTitle
                  put paramProp into insertedMenuController
               else
                  -- experimental and not tested
                  breakPoint
                  put the dynamicSubmenuTitleProp of mController into insertedMenuTitle
                  put the menu_Controller [insertedMenuTitle] of mController into insertedMenuController
                  -- put menu_GetDefaultController (subMenuTitle, mController, false) into insertedMenuController
               end if
               
               menu_IncludeMenuText mText, insertedMenuTitle, mView, insertedMenuController, menuIsDisabled, mTitlePath, mPath, pMenuTarget
               break
            case "submenu"
               put pigeon into dynamicSubmenuTitleProp
               
               -- if the number of tokens of pigeon < 2 then -- pigeon is empty then
               if true then -- temp hack for now !!!
                  put subMenuProp into subMenuTitle
                  put paramProp into subMenuController
                  if subMenuController is empty then
                     -- a temporary hack for old menu tables
                     -- put menu_GetDefaultController (subMenuTitle, mController, false) into subMenuController
                     put the menu_Controller [subMenuTitle] of mController into subMenuController
                  end if
               else
                  -- experimental and not tested 
                  -- idea is to allow a getprop to dynamicaly return a subMenuTitle based on local conditions
                  breakPoint
                  put the dynamicSubmenuTitleProp of mController into subMenuTitle
                  -- put menu_GetDefaultController (subMenuTitle, mController, false) into subMenuController
                  put the menu_Controller [subMenuTitle] of mController into subMenuController
               end if
               if exists (subMenuController) is false then
                  -- menu needs fixing
                  -- breakPoint
                  next repeat
               end if
               put mPath into subMenuPath
               put mTitlePath into subMenuTitlePath
               put mTarget into subMenuTarget
               
               try
                  if initArray [subMenuController][subMenuTarget]["already checked"] is not true then
                     put the menu_CheckTarget [subMenuTarget] of subMenuController into targetOK
                     put targetOK into initArray [subMenuController][subMenuTarget]["targetOK"]
                     put true into initArray [subMenuController][subMenuTarget]["already checked"]
                  else
                     put initArray [subMenuController][subMenuTarget]["targetOK"] into targetOK
                  end if
               catch e
                  put false into targetOK
               end try
               
               switch targetOK
                  case "delete"
                     next repeat
                     break
                  case false
                     put true into subMenuIsDisabled
                     break
                  case true
                     put menu_CheckDisabled (mFormatProp, mTarget, mController) into subMenuIsDisabled
                     break
                  default
                     -- could be used to replace a disabled menu with another menu
                     -- use to fix reason why menu is disabled for instance
                     put menu_CheckDisabled (mFormatProp, mTarget, mController) into subMenuIsDisabled
               end switch
               
               switch subMenuIsDisabled
                  case "delete"
                     break
                  case true
                     menu_DisableLine mLine
                     menu_InsertSubMenu mText, mLine, subMenuTitle, mView, subMenuController, mTitlePath, mPath, pMenuTarget, subMenuIsDisabled
                     break
                  default
                     menu_InsertSubMenu mText, mLine, subMenuTitle, mView, subMenuController, mTitlePath, mPath, pMenuTarget, subMenuIsDisabled
               end switch
               
               /*
               if subMenuIsDisabled is true then
                  menu_DisableLine mLine
               else if subMenuIsDisabled is not false then
                  -- error_CheckDisabled mController, mTarget, mTitlePath, mTableLine, someError
               end if
               menu_InsertSubMenu mText, mLine, subMenuTitle, mView, subMenuController, mTitlePath, mPath, pMenuTarget, subMenuIsDisabled
               */
               
               break
            default
               -- it is not a recursively called menu insertion
               -- lets check if menu item is disabled
               if menuIsDisabled is true then
                  put true into itemIsDisabled
               else
                  put menu_CheckDisabledItem (mFormatProp, mTarget, mController, false, mTitlePath, mTableLine) into itemIsDisabled
               end if
               
               switch
                  case itemIsDisabled = "delete"
                     -- dont add mLine
                     break
                  case itemIsDisabled =  true or menuIsDisabled is true
                     -- disable mLine
                     menu_DisableLine mLine
                     put mLine & CR after mText
                     break
                  case itemIsDisabled is not false and itemIsDisabled is not empty
                     -- replace mLine with substituted text
                     put itemIsDisabled & CR after mText
                     break
                  case mItemType = "boolean"
                     -- add check sub menu to mLine
                     menu_AddBooleanLine mText, mLine, paramProp, mTarget, mController
                     break
                  case mItemType = "fixed"
                     -- fetch sub menu from custom property and add to mLine
                     menu_InsertFixed mText, mLine, pigeon, mController, paramProp, mTarget, mItemType
                     break
                  case mItemType is among the items of "custom submenu,custom external"
                     -- fetch sub menu from getprop and add to mLine
                     menu_FetchCustomMenuItems mText, mLine, submenuProp, mController, paramProp, mTarget, mItemType
                     break
                  default -- mItemType = empty
                     -- a plain menu item - just add to mLine
                     put mLine & CR after mText
               end switch
         end switch
      catch someError
         -- display_Text (mTableLine & CR & CR & someError), mTableLine
      end try
   end repeat
   menu_TidyText mText
   return mText
end menu_ConvertTable


--> Menu | Controller | Default
-
/*
This fancy default searching etc can be achieved by adding a virtual custom property to the target
Or by adding a before handler in a behavior of this script.

Consequenlty noen of this code in this section is needed.
*/

getprop menu_DefaultController [mTitle]
   put the long id of the target into targetObject
   put menu_GetDefaultController (mTitle, targetObject, false) into mController
   return mController
end menu_DefaultController

function menu_TitleIsGlobal mTitle
   -- check if it is a global menu
   set the itemdelimiter to "|"
   put word 1 to -1 of item 1 of mTitle into mTitleStem
   return mTitleStem is "Global"
end menu_TitleIsGlobal

function menu_GetDefaultController mTitle, targetObject, pSearchScript
   -- careful to avoid recursion 
   -- called repeatedly on menu draw (consider speeding up by using caching / and / or using menu_TitleBurn)
   
   -- check if it is a global menu
   if menu_TitleIsGlobal (mTitle) then
      put menu_GetGlobalController (mTitle) into mController
      if exists (mController) is true then
         return mController
      end if
   end if
   
   -- here we allow sub stack cards to override defaults
   put the menu_SubStackCard [mTitle] of targetObject into mController
   if exists (mController) then return mController
   
   put the menu_FindController [mTitle] of targetObject into mController
   if exists (mController) then return mController
   
   return targetObject
   -- put the card_Object of targetObject into cardObject
   -- return cardObject
end menu_GetDefaultController

getprop menu_FindController [mTitle]
   put the long id of the target into targetObejct
   
   put the script_Hierarchy of targetObejct into scriptHierarchy
   repeat for each line mController in scriptHierarchy
      -- put the menu_Titles of mController into mTitles
      put the script of mController into mControllerScript
      put "-->" && mTitle into mTitleLine
      
      -- should be made fuzzy ussing a regular expression
      if mTitleLine is among the lines of mControllerScript then
         return mController
      end if
   end repeat
   return empty
end menu_FindController

getprop menu_Titles [pUseMenuTables]
   put the long id of the target into scriptObject
   if pUseMenuTables is false then
      put the menu_ScriptTitles of scriptObject into mTitles
   else
      put menu_GetTableTitles (scriptObject) into mTitles
   end if
   return mTitles
end menu_Titles


--> Menu | Title
-
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


--> Menu | Basics
-
command menu_MouseDown pMenuTitleTable, pTargetObject
   if exists(pTargetObject) is false then put the long id of the target into pTargetObject
   if pMenuTitleTable is empty then put the menu_Title of pTargetObject into pMenuTitleTable
   if pMenuTitleTable is empty then put "Menu" into pMenuTitleTable
   set the menu_TextFromTitle of pTargetObject to pMenuTitleTable
   put the result into mText
   if mText is empty then return "false"
end menu_MouseDown

command menu_PopUp pMenuTitle, pLocation, pTargetObject
   if pTargetObject is empty then put the long id of the target into pTargetObject
   if pMenuTitle is empty then put the menu_Title of pTargetObject into pMenuTitle
   if pMenuTitle is empty then put "Menu" into pMenuTitle
   
   set the menu_TextFromTitle of pTargetObject to pMenuTitle
   put the result into mText
   if mText is empty then return "false"
   
   put the menu_Button of pTargetObject into mButton
   if pLocation is not a point then
      popup mButton
   else
      popup mButton at pLocation
   end if
   return true
end menu_PopUp

command menu_PullDown pMenuTitle, pLocation, pTargetObject
   if pTargetObject is empty then put the long id of the target into pTargetObject
   -- if pMenuTitle is empty then put the menu_ToolOrTitle of pTargetObject into pMenuTitle
   if pMenuTitle is empty then put the menu_Title of pTargetObject into pMenuTitle
   if pMenuTitle is empty then put "Menu" into pMenuTitle
   
   set the menu_TextFromTitle of pTargetObject to pMenuTitle
   put the result into mText
   if mText is empty then
      -- lcw_Notify pMenuTitle -- often useful, but also annoying :)
      return "false"
   end if
   
   put the menu_Button of pTargetObject into mButton
   if exists (mButton) is false then return false
   
   if pLocation is not a point then
      put the bottomleft of pTargetObject into pLocation
      add 3 to item 2 of pLocation
   end if
   if exists (mButton) is false then return false
   popup mButton at pLocation
   return true
end menu_PullDown


--> Menu | Checks
-
function menu_CheckTitleController mTitle, mController
   put menu_GetTableTitles (mController) into mTitles
   return mTitle is among the lines of mTitles
end menu_CheckTitleController


--> Menu | SendMessage
-
/*
These handlers could be in the menu_Button's behavior.
*/

command menu_SendMessage mPath, pMenuTarget, pCreateActiveArray
   -- ignoreCall: mCommand,c
   -- ignoreCall: callCommand,c
   -- ignoreCall: menu_Version,g
   
   menu_DeconstructPath mPath, foundPath, subMenuPath, pigeon, mController, mTitlePath, mItemType -- look up in array
   if the result is false then return empty  -- when frontscript is active will be called by every menu (even Rev Ide menus)
   if exists (mController) is false then breakPoint -- something wrong
   
   if exists (pMenuTarget) then
      menu_SetItemTargetOveride mPath, pMenuTarget
      put pMenuTarget into mTarget
   else
      put menu_TargetFromGlobal (mPath) into mTarget
   end if
   
   menu_SetSentPath mPath -- everything can be derived from that
   menu_SetTitlePath mTitlePath     
   
   -- set the defaultstack to the stack_Object of mTarget
   -- set the defaultstack to the stack_Object of menu_GetTargetObject() -- dispatch changes this that
   
   if the menu_OptionEdit of me is true and the optionkey is "Down" then
      dispatch "menu_EditMenuItem" to mController with pigeon,foundPath,subMenuPath,mController,mTarget
   else
      put token 1 of pigeon into mCommand
      put token 2 of pigeon into firstParamName
      put token 4 of pigeon into secondParamName
      
      -- should we "call"?
      dispatch mCommand to mController with mTarget, subMenuPath
   end if
   send "menu_DeleteActiveArray" to mController in 2 ticks
end menu_SendMessage


--> Deps | Menu | Title
-
setprop menu_Title mTitle
   set the menu_BurntTitle of the target to mTitle
   return the result
end menu_Title

setprop menu_Controller [pMenuTitle] mController
   if mController is empty then
      put the long id of the target into targetObject
      put the view_Object of targetObject into someView
      if exists(someView) is false then put targetObject into someView
      custom_DeleteProperty "menu_Title", someView
      custom_DeleteProperty pMenuTitle, someView, "menu_Controller"
   else
      set the burnt_MenuController [pMenuTitle] of the target to mController
   end if
   return the result
end menu_Controller

getprop menu_Table [pMenuTitle]
   if pMenuTitle is empty then put the menu_Title of the target into pMenuTitle
   if pMenuTitle is empty then return empty
   
   if word 1 of pMenuTitle = "Global" and word 2 of pMenuTitle = "|" then
      put menu_GetGlobalTable (pMenuTitle) into mTable
   else
      put the menu_Controller [pMenuTitle] of the target into mController
      put the menu_DataArray of mController into menuTableArray
      put menuTableArray [pMenuTitle] into mTable
   end if
   return mTable
end menu_Table

getprop menu_Text [mTopTitle]
   put the long id of the target into tObject
   
   if mTopTitle is empty then
      if the controlkey is "Down" then
         -- put the menu_ToolTitle of tObject into mTopTitle
         put the menu_Title of tObject into mTopTitle
      else
         put the menu_Title of tObject into mTopTitle
      end if
   end if
   put the menu_Controller [mTopTitle] of tObject into mTopController
   
   menu_DeleteActiveArray
   menu_SetTargetObject tObject
   menu_SetTopTitle mTopTitle
   menu_SetTopController mTopController
   
   put menu_GetTextFromTitleTable (mTopTitle, tObject) into mText
   return mText
end menu_Text

setprop menu_Text menuText
   put the long id of the target into targetObject
   put the menu_Button of targetObject into mButton
   if mButton is empty then return empty
   -- if the object_IsMenuButton of mButton is false then return  empty
   
   set the text of mButton to menuText
   return mButton
end menu_Text

getprop menu_Array
   put the long id of the target into mController
   lock messages
   put the menu_Array of mController into mArray
   unlock messages
   return mArray
end menu_Array

getprop menu_CheckTarget [topMenuTarget]
   /*
   This is a default sent by  "menu_ConvertTable" 
   Usually - all you want to do is check that the topMenuTarget exists.
   But it could be a file or some other non-Rev structure.
   */
   return true
end menu_CheckTarget


--> Menu | Extras
-
setprop menu_BurntTitle mTitle
   -- set the view_Value ["menu_Title"] of the target to mTitle
   put the long id of the target into targetObject
   put the view_Object of targetObject into someView
   if exists(someView) is false then put targetObject into someView
   
   get the name of someView
   lock messages
   set the menu_Title of someView to mTitle
   unlock messages
   return the result
end menu_BurntTitle

getprop menu_BurntTitle
   -- put the view_Value ["menu_Title"] of the target into mTitle
   put the long id of the target into targetObject
   put the view_Object of targetObject into someView
   if exists(someView) is false then put targetObject into someView
   
   get the name of someView
   lock messages
   put the menu_Title of someView into mTitle
   unlock messages
   return mTitle
end menu_BurntTitle


--> Deps | Menu | Controller
-
/*
Views can have attached menus. 
These menus are defined and controlled by scripts that reside in a revolution object. 
The object that contains this script is a "menu_Controller", and we store the link to this menu_Controller
as a view_Value. 
If not value is set then we return a default value, which for views is the card the view is on.

It is possible to set the "menu_Controller" to another object, and so move the scripts controlling the menu arround.
This is often simpler to do with a "global menu".
*/

getprop burnt_MenuController [pMenuTitle]
   put the long id of the target into targetObject
   put the view_Object of targetObject into someView
   if exists(someView) is false then put targetObject into someView
   
   if pMenuTitle is empty then put the menu_Title of targetObject into pMenuTitle
   
   set lockmessages to true
   put the menu_Controller [pMenuTitle] of someView into mController
   set lockmessages to false
   return mController
end burnt_MenuController

setprop burnt_MenuController [pMenuTitle] mController
   put the long id of the target into targetObject
   put the view_Object of targetObject into someView
   if exists(someView) is false then put targetObject into someView
   
   if pMenuTitle is empty then
      put the menu_Title of targetObject into pMenuTitle
   else
      -- for convenience lets switch the menu_Title as well!
      set the menu_BurntTitle of targetObject to pMenuTitle
   end if
   
   if mController is empty then
      custom_DeleteProperty "menu_Controller", someView
   else
      set lockmessages to true
      set the menu_Controller [pMenuTitle] of someView to mController
      set lockmessages to false
   end if
   return pMenuTitle
end burnt_MenuController


--> Menu | Sub Stacks
-
/*
Menu sub-stacks allow you to separate out menus onto their own sel-contained cards,
without haivng to go to create a Global menu.

These are used by "menu_TableLineFromScript"
*/

getprop menu_Cards
   put the menu_CardArray of the target into mCardArray
   return keys (mCardArray ["rugged_ID"])
end menu_Cards

getprop menu_CardNames
   put the menu_SubStack of the target into menuSubStack
   if exists (menuSubStack) is false then return empty
   put the cardNames of stack menuSubStack into mCardNames
   filter mCardNames with "* | Menu"
   return mCardNames
end menu_CardNames

getprop menu_CardMenu
   put the menu_CardNames of the target into mCards
   return menu_ConstructCardMenu (mCards)
end menu_CardMenu

function menu_ConstructCardMenu mCards
   sort mCards
   put mCards into globalMenuTitles
   filter globalMenuTitles with "Global |*"
   
   put mCards into mCardMenu
   filter mCardMenu without "Global |*"
   
   if mCardMenu is not empty and globalMenuTitles is not empty then put ",-," after mCardMenu
   if globalMenuTitles is not empty then put globalMenuTitles after mCardMenu
   return mCardMenu
end menu_ConstructCardMenu

getprop menu_CardArray
   put the menu_CardNames of the target into mCardNames
   repeat for each line mCardName in mCardNames
      put the long id of card mCardName of stack menuSubStack into cardObject
      put revRuggedID (cardObject) into rObject
      put rObject into mCardArray ["mTitle"][mCardName]
      put mCardName into mCardArray ["rugged_ID"][rObject]
   end repeat
   return mCardArray
end menu_CardArray

getprop menu_SubStackCard [mTitle]
   put the stack_SubName ["OPN Stack Menus"] of the target into subStackName
   if exists (card mTitle of stack subStackName) then
      return the long id of card mTitle of stack subStackName
   else
      return empty
   end if
end menu_SubStackCard

getprop menu_SubStackName
   put the stack_SubName ["OPN Stack Menus"] of the target into subStackName
   return subStackName
end menu_SubStackName

getprop menu_SubStack
   put the stack_Object of the target into stackObject
   put the mainstack of stackObject into mainStackName
   -- put the stack_Name of the target into mainStackName -- give a substack name
   
   put the stack_SubName ["OPN Stack Menus"] of stackObject into subStackName
   -- put the menu_SubStackName of the target into subStackName
   
   if exists(stack subStackName of stack mainStackName) then
      put the long name of stack subStackName of stack mainStackName into stackObject
      return stackObject
   else
      return empty
   end if
end menu_SubStack

command menu_IndexStackMenuCards pStackObject
   if pStackObject is empty then put the stack_Object of the target into pStackObject
   
   repeat for each line someID in the cardids of pStackObject
      set the cursor to busy
      put the long id of card id someID of pStackObject into cardObject
      
      set the menu_Update of cardObject to true
           
      lcw_Notify ("Updated index for menu" && kwote (the short name of cardObject) & "!")
   end repeat
end menu_IndexStackMenuCards

command menu_CreateSubStack someObject
   stack_CreateSubStack someObject, "OPN Stack Menus"
   return the result
end menu_CreateSubStack


--> Deps | Menu | Text
-
/*
menu_Text is a property of the targetObject.
the text is derived from the menu_Table
which is in turn stored with the menu_Controller 

menu_Text is now quickly constructed from the menu_Table (cached with the menu_Controller)
Submenus are created by recursively calling menu_Text on the submenu menu_Title
So script should be modified to prevent recursion.

While fetching the text (usually on a mousedown)
the menu_Table is also converted to an array
and added to the global gTemp_ActiveMenuArray
*/

setprop menu_TextFromTitle [pMenuTarget] mTitleTable
   -- don't like the syntax of this
   put the long id of the target into tObject
   
   set the itemdelimiter to tab
   put item 1 of line 1 of mTitleTable into mTopTitle
   
   if mTopTitle is empty then
      if the controlkey is "Down" then
         -- put the menu_ToolTitle of tObject into mTopTitle
         put the menu_Title of tObject into mTopTitle
      else
         put the menu_Title of tObject into mTopTitle
      end if
   end if
   put the menu_Controller [mTopTitle] of tObject into mTopController
   
   menu_DeleteActiveArray
   menu_SetTargetObject tObject
   menu_SetTopController mTopController
   
   put menu_GetTextFromTitleTable (mTitleTable, tObject, pMenuTarget) into mText
   menu_SetActiveText mText 
   if mText is not empty then set the menu_Text of tObject to mText
   return mText
end menu_TextFromTitle


--> Deps | Menu
-
command menu_AddBooleanLine @mText, mLine, paramProp, topMenuTarget, mController
   -- ignoreCall: paramProperty,g
   
   put mLine & CR after mText
   if the number of tokens of paramProp = 1 then
      put paramProp & "[" & topMenuTarget & "]" into paramProperty
   else
      put paramProp into paramProperty
   end if
   try
      put the paramProperty of mController into someBoolean
      
      if someBoolean is true then
         put "!ctrue" & CR & "!nfalse" into subMenu
      else if someBoolean is false then
         put "!ntrue" & CR & "!cfalse" into subMenu
      else
         put "true" & CR & "false" into subMenu
      end if
      put outline_IncreaseIndent (subMenu) into subMenu
      put subMenu & CR after mText
      return empty
   catch tError
      put merge("Error: fetching boolean custom property '[[paramProperty]]' of mController") & CR into someError
      put CR after someError
      put "mController:" && mController after someError
      lcw_Notify someError, true
      
      put someError -- so we can dig into what went wrong
      -- error_LogBoolean mController, mTableLine, mTitle, mTitlePath, mLine, tError
      
      return someError
   end try
end menu_AddBooleanLine

function menu_CheckDisabled mFormatProp, mTarget, mController
   -- ignoreCall: mFormatProperty,g
   
   if mFormatProp is empty then return false
   try
      put mFormatProp & "[" & mTarget & "]" into mFormatProperty
      put the mFormatProperty of mController into itemIsDisabled
      return itemIsDisabled
   catch someError
      return someError
   end try
end menu_CheckDisabled

function menu_CheckDisabledItem mFormatProp, mTarget, mController, menuIsDisabled
   -- ignoreCall: mFormatProperty,g
   
   if menuIsDisabled is true then return true
   if mFormatProp is empty then return false
   try
      put mFormatProp & "[" & mTarget & "]" into mFormatProperty
      put the mFormatProperty of mController into itemIsDisabled
   catch someError
      -- error_CheckDisabled mController, mTarget, mTitlePath, mTableLine, someError
   end try
   return itemIsDisabled
end menu_CheckDisabledItem

command menu_CheckSub @subMenu, paramProp, mController, mTarget, mItemType
   -- ignoreCall: paramProperty,g
   
   if paramProp is empty then return empty
   -- passing parameter can cause a custom property to fail to return when no getprop is there.
   put paramProp & "[" & mTarget & "]" into paramProperty
   try
      put the paramProperty of mController into checkedItems
      if checkedItems is empty and mItemType is among the items of "custom,fixed" then
         -- a hack ???
         -- put the paramProp of mController into checkedItems
      end if
      
      replace comma with CR in checkedItems
      repeat for each line checkedItem in checkedItems
         menu_SetCheckedItem checkedItem, subMenu, true
      end repeat
   catch tError
      put paramProperty & CR & mController into errorInfo
      if exists (mController) then edit the script of mController
   end try
end menu_CheckSub

function menu_CleanLine mLine  
   if char 1 to 2 of mLine is among the items of "!c,!n" then delete char 1 to 2 of mLine
   if char 1 of mLine = "(" then delete char 1 of mLine
   -- replace "(" with empty in someMenu	# only at start!
   -- put replacetext (mLine, "/.*", empty) into mLine
   
   -- accelerator keys
   set the itemdelimiter to "/"
   put item 1 of mLine into mSendLine
   
   if mLine is not mSendLine then breakpoint
   return mSendLine
end menu_CleanLine

function menu_CleanMarks mText  
   menu_CleanCheckMarks mText
   -- replace "(" with empty in mText	# only at start!
   put replacetext (mText, "(?m)^\(", empty) into mText
   put replacetext (mText, "/.*", empty) into mText
   return mText
end menu_CleanMarks

command menu_CleanCheckMarks @mText
   replace "!c" with empty in mText
   replace "!n" with empty in mText
end menu_CleanCheckMarks

private command menu_TidyText @mText
   put word 1 to -1 of mText into mText
   
   -- remove double dividers
   replace (CR & "-" & CR & "-" & CR) with (CR & "-" & CR) in mText
   
   -- removes things like blank missing menu spaces
   repeat while (word 1 to -1 of line 1 of mText = "-")
      delete line 1 of mText
   end repeat
   repeat while (word 1 to -1 of line -1 of mText = "-")
      delete line -1 of mText
   end repeat
end menu_TidyText

command addToMenuActiveArray mPath, mTitlePath, pigeon, mController, mView, mItemType, pMenuTarget
   if mPath is empty then return empty -- an insert?
   global gLCW
   
   if mItemType is among the items of "insert" then
      -- may need to disable a submenu, and need gLCW ["activeMenuArray"]to work out mTarget
      return empty
   end if
   if pMenuTarget is not empty then
      menu_SetItemTargetOveride mPath, pMenuTarget
   end if
   
   -- lets set work in progress mPath, mTitlePath so that submenus etc can use them to automatically gather context
   menu_SetTitlePath mTitlePath
   menu_SetSentPath mPath
   
   put pigeon into gLCW ["activeMenuArray"]["mPath"][mPath]["pigeon"]
   put mController into gLCW ["activeMenuArray"]["mPath"][mPath]["mController"]
   put mItemType into gLCW ["activeMenuArray"]["mPath"][mPath]["mItemType"]
   put mTitlePath into gLCW ["activeMenuArray"]["mPath"][mPath]["mTitlePath"]
   
   put mController into gLCW ["activeMenuArray"]["mTitlePath"][mTitlePath]["mController"]
   return empty
end addToMenuActiveArray

command menu_DeconstructPath mPath, @foundPath, @foundParam, @pigeon, @mController, @mTitlePath, @mItemType
   -- lets search to see if there is a param being sent with the menu
   -- pity menus don't use a different delimiter like tab
   -- as the text of the menu item could include "|" we can't just check the first item
   -- but should search back down through all items
   
   global gLCW
   
   put empty into foundParam
   put empty into pigeon
   put empty into mController
   put empty into mTitlePath
   put empty into mItemType
   
   set the itemdelimiter to "|"
   put the number of items of mPath into maxNum
   repeat with itemNum = maxNum down to 1
      put item 1 to itemNum of mPath into foundPath
      put gLCW ["activeMenuArray"]["mPath"][foundPath] into foundArray
      
      if foundArray is an array then
         -- found a mPath in active menu global
         
         put foundArray ["pigeon"] into pigeon
         put foundArray ["mController"] into mController
         put foundArray ["mItemType"] into mItemType
         put foundArray ["mTitlePath"] into mTitlePath
         
         put item (itemNum + 1) to maxNum of mPath into foundParam
         return true
      end if
   end repeat
   
   put empty into foundPath
   return false
end menu_DeconstructPath

command menu_DeconstructTableLine mTableLine, @mController, @pigeon, @mTitle, @mLine, @mFormatProp, @mItemType, @submenuProp, @paramProp, @mSendLine
   set the itemdelimiter to tab
   
   put item 1 of mTableLine into mLine
   put item 2 of mTableLine into pigeon
   put item 3 of mTableLine into mController
   put item 4 of mTableLine into mTitle
   put item 5 of mTableLine into mFormatProp
   put item 6 of mTableLine into mItemType
   put item 7 of mTableLine into submenuProp
   put item 8 of mTableLine into paramProp
   
   put item 9 of mTableLine into mSendLine
   if mSendLine is empty then
      put menu_CleanLine (mLine) into mSendLine -- for now while the mTables have not all been updated
      
      -- could update menu table here
   end if
end menu_DeconstructTableLine

command menu_DisableLine @mLine
   if char 1 of word 1 of mLine is not "(" then put "(" before word 1 of mLine
end menu_DisableLine

command menu_FetchCustomMenuItems @mText, mLine, submenuProp, mController, paramProp, mTarget, mItemType
   -- ignoreCall:  submenuProperty,g
   try
      put mLine & CR after mText
      
      put submenuProp & "[" & mTarget & "]" into submenuProperty
      put the submenuProperty of mController into subMenu
      
      if subMenu is not empty then
         -- check submenu
         replace comma with CR in subMenu
         menu_CheckSub subMenu, paramProp, mController, mTarget, mItemType
         put outline_IncreaseIndent (subMenu, 1) into subMenu
         put subMenu & CR after mText
      end if
   catch someError
      -- error_LogCustomMenuItems mController, submenuProperty, someError
   end try
end menu_FetchCustomMenuItems

function menu_GetItemTargetOveride sentMenuItemPath
   -- search for exact match in each item of path
   -- will return empty if match does not exist perhaps because stack is not known.
   global gLCW
   
   -- if the overide is an exact path return any match immediately
   put gLCW ["activeMenuArray"]["overide"]["mItem"][sentMenuItemPath]["mTarget"] into mItemTarget
   if exists(mItemTarget) then return mItemTarget
   
   -- faster to search through any stored overides
   put gLCW ["activeMenuArray"]["overide"]["mItem"] into itemMatchArray
   set the itemdelimiter to "/"
   repeat for each key mItemToMatch in itemMatchArray
      if mItemToMatch is among the items of sentMenuItemPath then
         put itemMatchArray [mItemToMatch]["mTarget"] into mItemTarget
         if exists(mItemTarget) then return mItemTarget
      end if
   end repeat
   return empty
end menu_GetItemTargetOveride

function menu_GetLineNum someMenuItem, someMenu
   set the itemdelimiter to tab
   repeat with lineNum = 1 to the number of lines of someMenu
      put item -1 of line lineNum of someMenu into lastItem
      
      if char 1 of lastItem = "!" then delete char 1 to 2 of lastItem
      if char 1 of lastItem = "(" then delete char 1 of lastItem
      if lastItem = someMenuItem then
         return lineNum
      end if
   end repeat
   return 0
   
   replace "/" with "\/" in someMenuItem
   put menu_CleanMarks (someMenu) into testMenu
   
   -- does not return the title with the greatest indent
   -- and so does not deal with titles which include subtitles of the same name ie colour names
   -- return outline_LineOffset(someMenuItem, testMenu)
   
   -- needs to be fast (repeats are)
   set the itemdelimiter to tab
   repeat with lineNum = the number of lines of someMenu down to 1
      get item -1 of line lineNum of someMenu
      if it = someMenuItem then
         return lineNum
      end if
   end repeat
   return 0
end menu_GetLineNum

function menu_GetTopController
   -- could probably work out from mTitlePath (by getting first items mController)
   global gLCW
   put gLCW ["activeMenuArray"]["top"]["mController"] into mTopController
   return mTopController
end menu_GetTopController

function menu_GetTopTitle
   global gLCW
   put gLCW ["activeMenuArray"]["top"]["mTitlePath"] into mTopTitle
   return mTopTitle
end menu_GetTopTitle

command menu_IncludeMenuText @mText, insertedMenuTitle, targetObject, insertedMenuController, menuIsDisabled, pTitlePath, pTextPath, pMenuTarget
   -- recursive handler so be careful here to avoid infinite loops
   put menu_GetTable (insertedMenuTitle, insertedMenuController) into insertedMenuTable
   -- set the itemdelimiter to "/"
   -- delete item - 1 of pTitlePath
   put menu_ConvertTable (insertedMenuTable, targetObject, pTitlePath, pTextPath, pMenuTarget, menuIsDisabled) into insertedMenu
   if insertedMenu is not empty then put insertedMenu & CR after mText
   return empty
end menu_IncludeMenuText

command menu_InsertFixed @mText, mLine, pigeon, mController, paramProp, topMenuTarget, mItemType
   -- it's OK for there to be no submenu_Fixed getprop present and just get the objects custom property
   -- ignoreCall:  submenu_Fixed,g
   
   put mLine & CR after mText
   put word 1 of pigeon into mCommand
   put the submenu_Fixed [mCommand] of mController into subMenu
   if subMenu is not empty then
      menu_CheckSub subMenu, paramProp, mController, topMenuTarget, mItemType
      put outline_IncreaseIndent(subMenu) into subMenu
      put subMenu & CR after mText
   end if
end menu_InsertFixed

command menu_InsertSubMenu @mText, mLine, subMenuTitle, mView, subMenuController, pTitlePath, pTextPath, pMenuTarget, pSubMenuIsDisabled
   global gLCW
   
   put menu_GetTable (subMenuTitle, subMenuController) into mTable
   
   -- hack
   set the itemdelimiter to "/" 
   delete item -1 of pTitlePath
   put menu_ConvertTable (mTable, mView, pTitlePath, pTextPath, pMenuTarget, pSubMenuIsDisabled) into subMenu
   
   if subMenu is empty then
      -- don't do anything (ie also remove the submenu_Title "mLine"
   else
      put mLine & CR after mText
      put outline_IncreaseIndent (subMenu, 1) into subMenu
      put subMenu & CR after mText
   end if
end menu_InsertSubMenu

function menu_MenuTextFromTitle mTitle
   set the itemdelimiter to "|"
   delete item - 1 of mTitle
   if word 1 to -1 of item 1 of mTitle = "Global" then delete item 1 of mTitle
   
   replace " | " with " " in mTitle
   return word 1 to -1 of mTitle
end menu_MenuTextFromTitle

getprop menu_ScriptTitles
   put the long id of the target into mController
   put the script of mController into someScript
   put script_ExtractMenuSuiteTitles (someScript) into scriptMenuTitles
   return scriptMenuTitles
end menu_ScriptTitles

function menu_LineNumFromPath mPath, mText
   menu_CleanCheckMarks mText
   put outline_PathOffset (mPath, mText, "|") into lineNum
   return lineNum
end menu_LineNumFromPath

command menu_SetCheckedItem someMenuItem, @someMenu, someBoolean
    put someBoolean is not false into someBoolean
    put menu_GetLineNum (someMenuItem, someMenu) into lineNum
    if lineNum = 0 then return someMenu
     
    put menu_SetCheckedLine(lineNum, someMenu, someBoolean) into someMenu
end menu_SetCheckedItem

function menu_SetCheckedLine lineNum, someMenuText, someBoolean
   -- replace (return & "!c") with (return & "!n") in 
   
   put line lineNum of someMenuText into menuLine
   if someBoolean is true then 
      put "c" into checkValue
   else 
      put "n" into checkValue
   end if
   
   if char 1 of word 1 of menuLine is "!" then
      if char 2 of word 1 of menuLine is "n" then
         put checkValue into char 2 of word 1 of menuLine 
      else if char 2 of word 1 of menuLine is "c" then
         put checkValue into char 2 of word 1 of menuLine 
      else
         -- put checkValue into char 2 of word 1 of menuLine -- not sure
      end if
   else
      put "!" & checkValue before of word 1 menuLine 
   end if    
   put menuLine into line lineNum of someMenuText
   return someMenuText
end menu_SetCheckedLine

command menu_SetItemTargetOveride mItemToMatch, mTarget
   global gLCW
   put mTarget into gLCW ["activeMenuArray"]["overide"]["mItem"][mItemToMatch]["mTarget"]
end menu_SetItemTargetOveride

command menu_SetSentPath mPath
   global gLCW
   put mPath into gLCW ["activeMenuArray"]["sent"]["mPath"]
end menu_SetSentPath

command menu_SetTargetObject targetObject
   -- the target clicked on by the user
   global gLCW
   put targetObject into gLCW ["activeMenuArray"]["top"]["targetObject"]
end menu_SetTargetObject

command menu_SetTitlePath mTitlePath
   -- could be called "menu_SetSentTitlePath"
   global gLCW
   put mTitlePath into gLCW ["activeMenuArray"]["sent"]["mTitlePath"]
end menu_SetTitlePath

command menu_SetTopController mTopController
   global gLCW
   put mTopController into gLCW ["activeMenuArray"]["top"]["mController"]
end menu_SetTopController

command menu_SetTopTitle mTopTitle
   global gLCW
   put mTopTitle into gLCW ["activeMenuArray"]["top"]["mTitlePath"]
end menu_SetTopTitle


--> Menu | Deps
-
command menu_DeconstructCommandLine mVersion, handlerLine, @handlerName, @handlerPrefix, @handlerSuffix, @customParam
   put token 1 of handlerLine into handlerName
   put token 2 of item 1 of handlerLine into firstParam
   put token 1 of item 2 of handlerLine into secondParam
   
   /*
   -- old way which switches depending on the menu_Version (too complicated)
   if mVersion is empty then
      if param_IsObject (firstParam) then
         put empty into customParam
      else
         put firstParam into customParam 
      end if
   else
      put secondParam into customParam
   end if
   */
   
   put secondParam into customParam -- new way (always pass mTarget as first param)
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
   
   -- new way (assumes mTarget is always passed as the ifirst param
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
   
   return mTableLine
end menu_DefaultTableLine

command menu_DeleteTables mController
   put the custompropertysets of mController into setNames
   line_Delete "uOPN_MenuTable", setNames
   set the custompropertysets of mController to setNames
end menu_DeleteTables


--> Deps | actionCompile,c
-
command menu_ConstructParamProp someScript, mCommand, customParam, mController, @paramProp, @submenuProp, @fixedSubMenu
   -- ignoreCall: submenuProperty,g
   -- deps: script_GetCommand, handler_ExtractCaseConditions, line_Delete, script_GetGetProp, script_ParamToHandlerName

   /*
   Some strange bugs that have been got around here.
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
         -- put getPropName & comma & "g" into shortHkey
         -- put the script_Handler [shortHKey]
         if script_GetGetProp (getPropName, someScript) is not empty then
            -- there is a getprop submenuProp handler in the mController script
            return "custom submenu"
         else
            -- this hack allows global submenu properties to be defined
            try
               -- should be same as menu_ConvertTable (but on compile I do not know mTarget)
               put submenuProp into submenuProperty
               put the submenuProperty of mController into testSubMenu
               if testSubMenu is not empty then return "custom external"
            catch tError
               -- looks like submenuProperty could require mTarget param
               put submenuProp & "[" & mTarget & "]" into submenuProperty
               lcw_Notify "Error: with" && submenuProperty
            end try
            
            -- is there a "case" statement in the script?
            put script_GetCommand (mCommand, someScript) into menuHandler
            put handler_ExtractCaseConditions (menuHandler) into fixedSubMenu
            line_Delete "default", fixedSubMenu
            if fixedSubMenu is not empty then
               put "submenu_Fixed[" & mCommand & "]" into submenuProp
               return "fixed"
            else if customParam is "menuChoice" then -- are you sure ???
               put empty into paramProp
               put empty into submenuProp
               return empty
            else
               --in this case it can be useful to allow getprop handlers outside of the controller
               return "custom external"
            end if
         end if
   end switch
end menu_ConstructParamProp

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
