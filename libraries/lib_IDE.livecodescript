script "lib_IDE"
--> MetaData
-
license: GPLv3
name: lib_IDE
type: library
version: 0.3

local LocalArray

/*
Gloabl gREVStackStatus is no longer used
-- from stack revidelibrary
put sStackEdited into editedStackArray
*/


--> Props
-
getprop stack_IsEdited
   put the stack_Name of the target into stackName
   put revIDEStackIsEdited (stackName) into someBoolean
   return someBoolean
end stack_IsEdited

getprop ide_MenuTitle [shortName]
   put ide_GetMenuTitle (shortName) into mTitle
   return mTitle
end ide_MenuTitle


--> Working on
-
function ide_ListMenuElements
   -- return "Recent,List,Script"
   put LocalArray ["environment"]["menu"] into ideMenuElements
   put keys(ideMenuElements) into mElements
   sort mElements
   return mElements
end ide_ListMenuElements

command ide_EditMenu shortName
   put ide_GetMenuController (shortName) into mController
   edit the script of mController
end ide_EditMenu

command ide_ReIndexLocalIdeMenus
   -- for when things go wrong
   delete variable LocalArray ["environment"]["menu"]
   repeat for each item ideElement in "List,Script,Recent"
      repeat for each item shortTitle in "Default,Authoring, Watch"
         _UpdateAndSet ideElement, shortTitle
      end repeat
   end repeat
   put LocalArray ["environment"]["menu"] into localEnvMenuArray
   return localEnvMenuArray
end ide_ReIndexLocalIdeMenus

private command _UpdateAndSet ideElement, shortTitle
   put ide_ConstructMenuController (ideElement, shortTitle) into mController
   if exists (mController) is true then
      set the menu_Update of mController to true
      ide_SetMenuTitle ideElement, shortTitle
   end if
   return mController
end _UpdateAndSet


--> IDE | Menu | Model
-
function ide_GetMenuTitle pElement
   if pElement is empty then put "Recent" into pElement
   put LocalArray ["environment"]["menu"][pElement] into mTitle
   return mTitle
end ide_GetMenuTitle

command ide_SetMenuTitle ideElement, pShortTitle
   if pShortTitle is empty or pShortTitle is not among the lines of ide_ListShortMenuTitles (ideElement) then
      put "Default" into pShortTitle
   end if  
   put ide_ConstructMenuTitle (ideElement, pShortTitle) into mTitle
   put mTitle into LocalArray ["environment"]["menu"][ideElement]
   return shortTitle
end ide_SetMenuTitle

command ide_ResetMenus
   delete variable LocalArray ["environment"]["menu"]
   ide_ReIndexMenus
   rev_AddBehaviorHacks
end ide_ResetMenus


--> IDE | Menu
-
function ide_ConstructMenuTitle pIdeElement, pShortName
   if pElement is empty then put "Recent" into pElement
   if pShortName is empty then put "Watch" into pShortName
   --
   put "Global | ScriptEditor |" && pIdeElement && "|" && pShortName && "| Menu" into mTitle
   return mTitle
end ide_ConstructMenuTitle


--> IDE | Menu | Global | Set
-
command ide_SetScriptEditorTitles shortTitle
   -- doesn't work with "Authoring", "Default" and "Watch"
   switch shortTitle
      case "Authoring"
      case "Watch"
         ide_SetMenuTitle "Recent", "Watch"
         ide_SetMenuTitle "List", "Authoring"
         ide_SetMenuTitle "Script", "Authoring"
         break
      case"Default"
      default
         ide_SetLocalMenus shortTitle
         /*
         ide_SetMenuTitle "Recent", shortTitle
         ide_SetMenuTitle "List", shortTitle
         ide_SetMenuTitle "Script", shortTitle
         */
   end switch
end ide_SetScriptEditorTitles

command ide_SetLocalMenus shortTitle
   if shortTitle is empty then put "default" into pIdeElement
   --
   put ide_ListMenuElements() into pIdeElements
   repeat for each item pIdeElement in pIdeElements
      ide_SetMenuTitle pIdeElement, shortTitle
   end repeat 
end ide_SetLocalMenus


--> IDE | Menu | List
-
function ide_ListFixedShortTitles
   return "Default,Revigniter,Watch"
end ide_ListFixedShortTitles

function ide_ListShortMenuTitles ideElement
   set the itemdelimiter to " | "
   put menu_ListGlobalTitles() into gTitles
   put "Global | ScriptEditor |" && ideElement && "|" into mTitleStem
   repeat for each line mTitle in gTitles
      if mTitle begins with mTitleStem then
         put item 4 of mTitle into shortName
         if shortName = "Menu" or shortName = "Custom" then next repeat
         put shortName & CR after shortNames
      end if
   end repeat
   return word 1 to -1 of shortNames
end ide_ListShortMenuTitles

function ide_ListMenuTitles ideElement
   put menu_ListGlobalTitles() into mTitles
   put "Global | ScriptEditor |" into mTitleStem
   if pIdeElement is not empty then
      put space & ideElement && "|" after mTitleStem
   end if
   put mTitleStem & "*" into someFilter
   filter mTitles with someFilter
   return word 1 to -1 of mTitles
end ide_ListMenuTitles


--> IDE | Menu | Global
-
function ide_GetMenuController ideElement, pShortTitle
   if pShortTitle is empty then
      put ide_GetMenuTitle (ideElement) into mTitle
   else
      put ide_ConstructMenuTitle (ideElement, pShortTitle) into mTitle
   end if
   --
   put menu_GetGlobalController (mTitle) into mController
   return mController
end ide_GetMenuController

function ide_GetMenuController pElement
   put ide_GetMenuTitle (pElement) into mTitle
   put menu_GetGlobalController (mTitle) into mController
   return mController
end ide_GetMenuController

function ide_ConstructMenuController pIdeElement, pShortName
   put ide_ConstructMenuTitle (pIdeElement, pShortName) into mTitle
   put menu_GetGlobalController (mTitle) into mController
   --
   if exists (mController) is true then
      return mController
   else
      return empty
   end if
end ide_ConstructMenuController

function ide_ShortTitle shortName
   set the itemdelimiter to " | "
   put the ide_MenuTitle [shortName] of me into mTitle
   put item 4 of mTitle into shortName
   if shortName is empty then return "Default"
   return shortName
end ide_ShortTitle


--> IDE | Other
-
function ide_VisibleStackNames pListWhich
   put the openstacks into stackNames
   switch pListWhich
      case "all"
         break
      case "display"
         filter stackNames with "Display *"
         break
      case "view"
         filter stackNames with "View|*"
         break
      case "rev"
         filter stackNames with "rev*"
         break
      default
         filter stackNames without "rev*"
   end switch
   
   repeat for each line stackName in stackNames
      if the visible of stack stackName is true then
         put stackName & CR after visibleStackNames
      end if
   end repeat
   delete char -1 of visibleStackNames
   return visibleStackNames
end ide_VisibleStackNames


--> ScriptField
-
command scriptField_DoTabkey selText, scriptField
   -- put word 2 of the selectedChunk of scriptField into firstCharNum
   put word 4 of the selectedChunk of scriptField into lastCharNum
   put scriptEditor_Object() into scriptObject
   put the text of scriptField into someScript
   
   put char 1 to lastCharNum of someScript into testScript
   put the number of lines of testScript into lineNum
   --
   put line lineNum of someScript into scriptLine
   put line lineNum of testScript into testScriptLine
   if word 1 to -1 of scriptLine is empty then return false
   
   put scriptField_ConstructShortHkey (scriptLine, testScriptLine, lastCharNum, scriptObject) into shortHkey
   if shortHkey is empty then return false
   --
   if selText is empty then
      scriptField_DoTabCompletion shortHkey, scriptObject
      return false
   end if
   
   put the found_Hkey [shortHkey] of scriptObject into foundHkey
   --
   hkey_Deconstruct foundHkey, hName, hType, hObject, hNum
   if hObject is empty then
      lcw_Notify merge ("Could not find handler '[[shortHkey]]")
      display_SpotlightHandler shortHkey
      return true
   end if
   --
   hkey_Edit foundHkey
   --
   return true
end scriptField_DoTabkey

command scriptField_DoTabCompletion shortHkey, scriptObject
   put the found_HandlerLine [shortHkey] of scriptObject into firstHandlerLine
   --
   if word 1 of firstHandlerLine = "private" then
      delete word 1 of firstHandlerLine
   end if
   --
   put word 3 to -1 of firstHandlerLine into hParams 
   put char -1 of word 1 of shortHkey into hType
   switch hType
      case "G"
      case "S"
         break
      case "F"
         if hParams is empty then
            put "()" into hParams
         else
            put "(" before hParams
            put ")" after hParams
            put space before hParams
         end if
         break
      default
         if hParams is empty then
            return false 
         else
            replace "@" with empty in hParams
            put space before hParams
         end if
   end switch
   --
   put hParams into the selectedChunk
   -- set the clipboarddata to hParams
   -- paste 
   -- lcw_Notify "Copied parameters to clipboard!"
   return true
end scriptField_DoTabCompletion

function scriptField_ConstructShortHkey scriptLine, testScriptLine, lastCharNum
   scriptField_SetTokenInfo scriptLine, testScriptLine, thisTokenNum, nextTokenNum, prevTokenNum, thisToken, nextToken, previousToken
   switch
      case previousToken is among the items of "then,else"
         delete token 1 to prevTokenNum of scriptLine
         delete token 1 to prevTokenNum of testScriptLine
         scriptField_SetTokenInfo scriptLine, testScriptLine, thisTokenNum, nextTokenNum, prevTokenNum, thisToken, nextToken, previousToken
         break
   end switch
   
   -- put selText into hName
   put thisToken into hName
   switch
      case ide_IsDictionaryTerm (thisToken) is true
         return empty
      case previousToken = "command" and thisTokenNum = 2
      case thisTokenNum = 1
         -- maybe complete / incomplete command
         -- put "c" into hType
         put "M" into hType
         break
      case nextToken = "("
         put "f" into hType
         break
      case previousToken = "the"
         -- put token (thisTokenNum - 2) of line lineNum of someScript into setOrGetToken
         put token (thisTokenNum - 2) of scriptLine into setOrGetToken
         if setOrGetToken = "set" then 
            put "s" into hType
         else
            put "g" into hType
         end if
         break
      case previousToken = "function" and thisTokenNum = 2
      case previousToken = "put"
         -- an unfinished function
         put "f" into hType
         break
      case previousToken is among the items of "call,send,dispatch"
         put token 1 of thisToken into hName
         put "M" into hType
         -- put "c" into hType
         break 
      case the number of words of thisToken > 1
         -- it was a quoted string
         return empty
      default
         return empty
   end switch
   
   put hType && hName into shortHkey
   return shortHkey
end scriptField_ConstructShortHkey

command scriptField_SetTokenInfo scriptLine, testScriptLine, @thisTokenNum, @nextTokenNum, @prevTokenNum, @thisToken, @nextToken, @previousToken
   if word 1 of scriptLine is among the items of "--,#,/*" then
      -- another hack to allow looking up words in comments
      delete word 1 of scriptLine
      delete word 1 of testScriptLine
   end if
   
   -- hack in case a piece of quoted text is chopped in half
   put quote after testScriptLine
   
   put the number of tokens of testScriptLine into thisTokenNum
   put token thisTokenNum of scriptLine into thisToken
   
   put thisTokenNum + 1 into nextTokenNum
   put token nextTokenNum of scriptLine into nextToken
   
   put thisTokenNum - 1 into prevTokenNum
   if prevTokenNum = 0 then
      put empty into previousToken -- LiveCode bug: token 0 = the whole line
   else
      put token prevTokenNum of scriptLine into previousToken
   end if
end scriptField_SetTokenInfo
