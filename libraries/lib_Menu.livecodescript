script "lib_Menu"
--> MetaData
-
license: GPLv3
name: lib_Menu
type: script library
copyright: David Bovill
licence:  GPLv3
version: 0.2

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


--> Menu | Test
-
command display_ActiveMenuArray mTitle
   global gLCW
   
   put gLCW ["activeMenuArray"] into activeMenuArray
   put "Recursion:" && mTitle & ",menu_CheckRecursionOnExtract" into someTitle
   display_Array activeMenuArray, someTitle
end display_ActiveMenuArray


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
      set the menu_DataArray of scriptObject to mTitleTableArray -- local
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

-- getprop menu_Update
local menuTitleArray

put the script_MenuTitleTableArray of the target into mTitleTableArray
repeat for each key gMenuTile in mTitleTableArray
   if word 1 of gMenuTile = "Global" and word 2 of gMenuTile = "|" then
      put mTitleTableArray [gMenuTile] into gMenuTable
      -- menu_SetGlobalTable gMenuTile, gMenuTable
      put gMenuTable into menuTitleArray ["gMenuTable"]
   end if
end repeat
return menuTitleArray
end menu_Update


--> Menu | Global | Model
-
function menu_ListGlobalNames
   global gLCW
   put gLCW ["Global Menus"] into menuArray
   return keys (menuArray)
end menu_ListGlobalNames

function menu_ListGlobalObjects
   global gLCW
   put gLCW ["Global Menus"] into menuArray
   repeat for each key mTitle in menuArray
      put menuArray [mTitle]["mController"] into mController
      put mController & CR after mControllers
   end repeat
   delete char -1 of mControllers
   return mControllers
end menu_ListGlobalObjects


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

