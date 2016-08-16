script "lib_Menu"
--> MetaData
-
license: GPLv3
name: lib_Menu
type: script library
copyright: David Bovill
licence:  GPLv3
version: 0.1


--> Menu | Global
-


--> Menu | Template
-
function menu_ConstructTemplateScript mTitle
   put menu_ConstructSubMenuScript (mTitle) into upSubMenus
   if upSubMenus is not empty then put CR & upSubMenus & CR into upSubMenus
   
   put mTitle into MenuTitle
   put script_GetTemplate ("Menu Script") into menuScriptTemplate
   put merge (menuScriptTemplate) into someScript
   return someScript
end menu_ConstructTemplateScript

function menu_ConstructSubMenuScript mTitle
   put menu_SubMenuHierarchy (mTitle) into mTitleHierarchy
   repeat for each line subMenuTitle in mTitleHierarchy
      put "return" && kwote(subMenuTitle) into hBody
      replace " | " with comma in subMenuTitle
      put item 2 to -2 of subMenuTitle into pigeonBit
      replace comma with empty in pigeonBit
      put "submenu_" & pigeonBit into pigeon
      put script_ConstructCommand (pigeon, hBody, true) into someScript
      put someScript & CR & CR after subMenuScript
   end repeat
   delete char -2 to -1 of subMenuScript
   return subMenuScript
end menu_ConstructSubMenuScript

function menu_SubMenuHierarchy mTitle
   put menu_GlobalTitles() into gMenuNames
   set the wholematches to true
   repeat
      replace " | " with comma in mTitle
      delete item -2 of mTitle
      if the number of items of mTitle < 3 then exit repeat
      replace comma with " | " in mTitle
      put lineOffset (mTitle, gMenuNames) into lineNum
      if lineNum = 0 then next repeat
      
      put mTitle & CR after mTitleHierarchy
   end repeat
   delete char -1 of mTitleHierarchy
   return mTitleHierarchy
end menu_SubMenuHierarchy


--> Menu | Utilities
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


