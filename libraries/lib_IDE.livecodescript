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


--> Working on
-


--> Props
-
getprop stack_IsEdited
   put the stack_Name of the target into stackName
   -- put stack_ListEditedNames ("edited") into editedStackNames
   --  put stackName is among the lines of editedStackNames into someBoolean
   put revIDEStackIsEdited (stackName) into someBoolean
   return someBoolean
end stack_IsEdited

getprop ide_MenuTitle [shortName]
   put ide_GetMenuTitle (shortName) into mTitle
   return mTitle
end ide_MenuTitle


--> Stack
-
function stack_ListEditedNames pFilterHow
   put the mainstacks into stackNames
   repeat for each line stackName in stackNames   
      put revIDEStackIsEdited (stackName) into someBoolean
      switch
         case someBoolean is true
            put stackName & CR after editedStackNames
            break
         default
      end switch
   end repeat
   delete char -1 of editedStackNames
   return editedStackNames
   
   /*
   global gREVStackStatus
   
   repeat for each key stackName in gREVStackStatus
      if exists (stack stackName) is false then next repeat
      switch pType
         case "saved"
            if gREVStackStatus [stackName] = empty then
               put "saved" into stackArray [stackName]
            end if
            break
         default
            if gREVStackStatus [stackName] = "edited" then
               put "edited" into stackArray [stackName]
            end if
      end switch
   end repeat
   return keys (stackArray)
   */
end stack_ListEditedNames

command stack_SaveEdited editedStackName
   global gREVStackStatus
   
   if editedStackName is among the items of "All,Save All" then
      put stack_ListEditedNames() into stackNames
   else
      put editedStackName into stackNames
   end if
   
   repeat for each line stackName in stackNames
      try
         put the effective fileName of stack stackName into pFilePath
         save stack stackName
         -- stack_MarkEdited stackName, false -- this is done by save
         -- delete global gREVStackStatus [stackName]
         
         lcw_Notify merge ("Saved stack '[[stackName]]'!")
      catch e
         breakpoint
         put stackName & CR after couldntSaveStackNames
         answer warning merge ("Could not save stack '[[stackName]]'!")
      end try
   end repeat
   
   if couldntSaveStackNames is not empty then
      put couldntSaveStackNames
   else
      lcw_Notify "Saved all edited stacks!"
   end if
end stack_SaveEdited

command stack_MarkSaved stackName
   if stackName is empty then put the short name of this stack into stackName
   revIDESetUnedited stackName
   
   /*
   -- was "rev_MarkStackSaved"
   global gREVStackStatus
   delete global gREVStackStatus [stackName]
   */
end stack_MarkSaved

command stack_MarkEdited stackName, pBoolean
   -- was "rev_MarkStackEdited"
   if stackName is empty then put the short name of this stack into stackName
   if pBoolean is false then
      revIDESetUnedited stackName
   else
      revIDESetEdited stackName
   end if 
   /*
   global gREVStackStatus
   
   if stackName is empty then put the short name of this stack into stackName
   if char 1 to 3 of stackName is not "rev" then
      put "edited" into gREVStackStatus [stackName]
   end if
   */
end stack_MarkEdited


--> IDE
-
function ide_ConstructMenuTitle shortName, ideElement
   if word 1 of shortName is "Global" then return shortName
   
   put "Global | ScriptEditor |" && ideElement && "|" && shortName && "| Menu" into mTitle
   return mTitle
end ide_ConstructMenuTitle

function ide_GetMenuController ideElement, pShortTitle
   if pShortTitle is empty then
      put ide_GetMenuTitle (ideElement) into mTitle
   else
      put ide_ConstructMenuTitle (pShortTitle, ideElement) into mTitle
   end if
   
   put menu_GetGlobalController (mTitle) into mController
   return mController
end ide_GetMenuController

function ide_GetMenuTitle ideElement
   put LocalArray ["environment"]["menu"][ideElement] into mTitle
   return mTitle
end ide_GetMenuTitle

function ide_ListMenuTitles pIdeElement
   put menu_ListGlobalTitles() into mTitles
   put "Global | ScriptEditor |" into mTitleStem
   if pIdeElement is not empty then
      put space & pIdeElement && "|" after mTitleStem
   end if
   put mTitleStem & "*" into someFilter
   filter mTitles with someFilter
   return word 1 to -1 of mTitles
end ide_ListMenuTitles

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

function ide_ShortTitle shortName
   set the itemdelimiter to " | "
   put the ide_MenuTitle [shortName] of me into mTitle
   put item 4 of mTitle into shortName
   if shortName is empty then return "Default"
   return shortName
end ide_ShortTitle

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

command ide_EditMenu shortName
   if word 1 of shortName is not "Global" then
      put "Global | ScriptEditor |" && shortName && "| Menu" into mTitle
   end if
   menu_Edit mTitle
end ide_EditMenu

command ide_ReIndexMenus
   put ide_GetMenuController ("Recent", "Default") into mController
   set the menu_Update of mController to true
   put the result into mTableArray
   
   put ide_GetMenuController ("Recent", "Watch") into mController
   set the menu_Update of mController to true
   put the result into mTableArray
   
   repeat for each item mElement in "List,Script"
      repeat for each item shortTitle in "Default,Authoring"
         put ide_GetMenuController (mElement, shortTitle) into mController
         if exists (mController) is false then next repeat
         
         set the menu_Update of mController to true
         put the result into mTableArray
      end repeat
   end repeat
end ide_ReIndexMenus

command ide_ResetMenus
   delete variable LocalArray ["environment"]["menu"]
   ide_ReIndexMenus
   rev_AddBehaviorHacks
end ide_ResetMenus

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
         ide_SetMenuTitle "Recent", shortTitle
         ide_SetMenuTitle "List", shortTitle
         ide_SetMenuTitle "Script", shortTitle
   end switch
end ide_SetScriptEditorTitles

command ide_SetMenuTitle ideElement, shortTitle
   if shortTitle is empty or shortTitle is not among the lines of ide_ListShortMenuTitles (ideElement) then
      put "Default" into shortTitle
   end if  
   put ide_ConstructMenuTitle (shortTitle, ideElement) into mTitle
   put mTitle into LocalArray ["environment"]["menu"][ideElement]
   return shortTitle
end ide_SetMenuTitle


--> ScriptField
-
command scriptField_DoTabkey selText, scriptField
   -- if the shiftkey is "Up" then pass tabkey
   
   put word 2 of the selectedChunk of scriptField into firstCharNum
   put word 4 of the selectedChunk of scriptField into lastCharNum
   put the text of scriptField into someScript
   put scriptEditor_Object() into scriptObject
   
   put scriptField_ConstructHkeyLine (selText, someScript, lastCharNum, scriptObject) into hkeyLine
   if hkeyLine is empty then
      return false
   end if
   
   hkey_Edit hkeyLine
   return true
end scriptField_DoTabkey

command scriptField_DoTabCompletion
   scriptField_TabComplete shortHkey, firstCharNum, lastCharNum, selText, scriptObject, scriptField
   if the result is empty then
      put item 1 of shortHkey into hName
      put empty into pTriggerHKey
      hkey_DisplayHandlerKeywordIndex hName, pTriggerHKey
   end if
end scriptField_DoTabCompletion

function scriptField_ConstructHkeyLine selText, someScript, lastCharNum, scriptObject
   put char 1 to lastCharNum of someScript into testScript
   put the number of lines of testScript into lineNum
   put line lineNum of someScript into scriptLine
   put line lineNum of testScript into testScriptLine
   
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
         put token (thisTokenNum - 2) of line lineNum of someScript into setOrGetToken
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
   
   -- simple search of libs for now
   put hkeyline_Find (hName, hType) into hkeyLine
   /*
   put hType && hName into shortHkey
   put hkey_GetPlace (shortHkey) into hObject
   put hKeyLine_FromTripple (hName, hType, hObject) into hkeyLine
   */
   return hkeyLine
end scriptField_ConstructHkeyLine

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

command scriptField_Tabkey selText, scriptField, pNoLibraryBehaviors
   if pNoLibraryBehaviors is empty then put false into pNoLibraryBehaviors -- search normal heirarchy (set to true to skip library behaviors).
   
   put word 2 of the selectedChunk of scriptField into firstCharNum
   put word 4 of the selectedChunk of scriptField into lastCharNum
   put the text of scriptField into someScript
   
   put scriptEditor_Object() into scriptObject
   
   try
      put scriptField_ConstructHkey (selText, someScript, lastCharNum) into shortHkey
      put shortHkey,scriptObject,1 into hKey -- should probably get the full hKey even if not first (ie hNum > 1)
      
      switch
         case shortHkey is empty
            lcw_Notify "It's a Revolution language term or a variable!"
            break
         default
            switch
               case the optionKey is "Down"
                  hArray_SearchAndEdit hKey
                  break
               case the shiftKey is "Down"
                  hArray_SearchHierarchyAndEdit shortHkey, scriptObject, true
                  break
               default
                  scriptField_TabComplete shortHkey, firstCharNum, lastCharNum, selText, scriptObject, scriptField
                  if the result is empty then
                     put item 1 of shortHkey into hName
                     put empty into pTriggerHKey
                     hkey_DisplayHandlerKeywordIndex hName, pTriggerHKey
                  end if
            end switch
      end switch
   catch e
      put e
   end try
end scriptField_Tabkey
