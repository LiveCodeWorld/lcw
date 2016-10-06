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
         
         menu_NormalizeTitle gMenuTile
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

