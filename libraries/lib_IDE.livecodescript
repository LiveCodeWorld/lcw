script "lib_IDE"
--> MetaData
-
license: GPLv3
name: lib_IDE
type: library
version: 0.4

local LocalArray

/*
A library to interface with teh Revolution IDE.
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


--> IDE | Init
-
command ide_InitLcw
   dict_GetAndCacheTerms
   ide_SetScriptEditorTitles "Watch"
   ide_AddBehaviorHacks true
end ide_InitLcw

command ide_AddBehaviorHacks pBoolean
   -- This handler turns on and off the behavior based IDE menu hacks.
   _ReIndexLocalIdeMenus
   
   put pBoolean is not false into someBoolean
   
   put scriptEditor_HandlerListBehavior() into handlerBehavior
   put scriptEditor_ScriptFieldBehavior() into scriptFieldBehavior
   put scriptEditor_HistoryButtonBehavior() into historyBehavior
   put scriptEditor_FindFieldBehavior() into simpleFindBehavior
   put scriptEditor_CompileButtonBehavior() into compileButtonBehavior
   put scriptEditor_DocumentationFieldBehavior() into documentationFieldBehavior
   put scriptEditor_LaunchDocsBehavior() into launchDocsBehavior
   
   put rev_OpenScriptEditorNames() into editorNames
   repeat with someNum = 0 to the number of lines of editorNames
      put rev_ScriptEditorField (someNum) into scriptField
      if exists (scriptField) is false then next repeat
      
      put rev_HistoryButton (someNum) into historyButton
      put rev_HandlerTreeField (someNum) into handlerTreeField
      put rev_SimpleFindField (someNum) into simpleFindField
      put rev_CompileButton (someNum) into compileButton
      put rev_ScriptEditorDocField (someNum) into scriptEditorDocField
      put rev_LaunchDocsButton (someNum) into launchDocsButton
      
      if someBoolean is not false then
         ide_SetAfterActionCompile true
         set the behavior of compileButton to compileButtonBehavior
         --
         set the behavior of scriptField to scriptFieldBehavior
         set the behavior of historyButton to historyBehavior
         set the behavior of handlerTreeField to handlerBehavior
         set the behavior of simpleFindField to simpleFindBehavior        
         set the behavior of scriptEditorDocField to documentationFieldBehavior
         set the behavior of launchDocsButton to launchDocsBehavior
      else
         ide_SetAfterActionCompile false
         set the behavior of compileButton to empty
         --
         set the behavior of scriptField to empty
         set the behavior of historyButton to empty
         set the behavior of handlerTreeField to empty
         set the behavior of simpleFindField to empty
         set the behavior of scriptEditorDocField to empty
         set the behavior of launchDocsButton to empty
      end if
   end repeat
end ide_AddBehaviorHacks

function ide_GetAfterActionCompile
   put the name of stack "behavior_RevSEStackBehavior" into actionBehavior
   put the behavior of stack "revSEStackBehavior" into bObject
   return actionBehavior = bObject
end ide_GetAfterActionCompile

command ide_SetAfterActionCompile pBoolean
   if exists (stack "behavior_RevSEStackBehavior") is false then return empty
   --
   put the name of stack "behavior_RevSEStackBehavior" into actionBehavior
   put the behavior of stack "revSEStackBehavior" into bObject
   if pBoolean is false then
      set the behavior of stack "revSEStackBehavior" to empty
   else
      set the behavior of stack "revSEStackBehavior" to actionBehavior
   end if
   return actionBehavior
end ide_SetAfterActionCompile

command ide_ResetMenus
   delete variable LocalArray ["environment"]["menu"]
   _ReIndexLocalIdeMenus
   ide_AddBehaviorHacks
end ide_ResetMenus


--> IDE | Menu
-
function ide_GetMenuController, pShortTitle
   if pShortTitle is empty then
      put ide_GetMenuTitle (ideElement) into mTitle
   else
      put ide_ConstructMenuTitle (ideElement, pShortTitle) into mTitle
   end if
   --
   put menu_GetGlobalController (mTitle) into mController
   return mController
end ide_GetMenuController

function ide_ConstructMenuTitle pIdeElement, pShortName
   if pElement is empty then put "Recent" into pElement
   if pShortName is empty then put "Watch" into pShortName
   --
   put "Global | ScriptEditor |" && pIdeElement && "|" && pShortName && "| Menu" into mTitle
   return mTitle
end ide_ConstructMenuTitle

function ide_GetMenuTitle pElement
   if pElement is empty then put "Recent" into pElement
   put LocalArray ["environment"]["menu"][pElement] into mTitle
   return mTitle
end ide_GetMenuTitle

function ide_ShortTitle shortName
   set the itemdelimiter to " | "
   put the ide_MenuTitle [shortName] of me into mTitle
   put item 4 of mTitle into shortName
   if shortName is empty then return "Default"
   return shortName
end ide_ShortTitle

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

command ide_SetHanderFieldBehavior sBoolean
   put scriptEditor_HandlerListBehavior() into bObject
   if exists (bObject) is false then
      breakpoint
      return "Error, scriptEditor_HandlerListBehavior() does not exist:" && bObject
   end if
   
   put rev_HandlerTreeField() into sTreeField
   if exists (sTreeField) is false then
      breakpoint
      return "Error, rev_HandlerTreeField() does not exist:" && sTreeField
   end if
   
   if sBoolean  is not false then
      set the behavior of sTreeField to bObject
   else
      set the behavior of sTreeField to empty
   end if
end ide_SetHanderFieldBehavior


--> IDE | Menu | List
-
function ide_ListShortMenuTitles ideElement
   put "Global | ScriptEditor |" && ideElement && "|*" into sFilter
   put menu_ListLoadedTitles (sFilter) into gTitles
   set the itemdelimiter to "|"
   repeat for each line mTitle in gTitles
      put word 1 to -1 of item 4 of mTitle into shortName
      if shortName = "Menu" or shortName = "Custom" then next repeat
      put shortName & CR after shortNames
   end repeat
   return shortNames
   
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

function ide_ListMenuElements
   return ide_ListDefaultMenuElements()
end ide_ListMenuElements

function ide_ListDefaultMenuElements
   get "List,Script,Recent"
   replace comma with CR in it
   return it
end ide_ListDefaultMenuElements

function ide_ListFixedShortTitles
   return "Default,Revigniter,Watch"
end ide_ListFixedShortTitles


--> IDE | Menubar
-
command ide_SaveStack pStackName
   -- dispatch "revIDESaveStack" to stack "revIdeLibrary" with sObject
   -- dispatch "revMenubarFileMenuPick" to stack "revMenuBar" with "Save"
   
   switch
      case pStackName is empty
         put the long id of the topstack into sObject
         break
      case exists (stack pStackName) is false
         return "Error, stack does not exist:" && pStackName
      default
         put the long id of stack pStackName into sObject
   end switch
   
   revIDESaveStack sObject
   return the result
end ide_SaveStack

command ide_RevMenubarMenuPick mName, mItem
   switch mName
      case "File"
         dispatch "revMenubarFileMenuPick" to stack "revMenuBar" with mItem
         break
      case "Edit"
         dispatch "revMenubarEditMenuPick" to stack "revMenuBar" with mItem
         break
      case "Tools"
         dispatch "revMenubarToolsMenuPick" to stack "revMenuBar" with mItem
         break
      case "Object"
         dispatch "revMenubarObjectMenuPick" to stack "revMenuBar" with mItem
         break
      case "Text"
         dispatch "revMenubarTextMenuPick" to stack "revMenuBar" with mItem
         break
      case "Development"
         dispatch "revMenubarDevelopmentMenuPick" to stack "revMenuBar" with mItem
         break
      case "View"
         dispatch "revMenubarViewMenuPick" to stack "revMenuBar" with mItem
         break
      case "Window"
         dispatch "revMenubarWindowMenuPick" to stack "revMenuBar" with mItem
         break
      case "Help"
         dispatch "revMenubarHelpMenuPick" to stack "revMenuBar" with mItem
         break
   end switch
end ide_RevMenubarMenuPick

function ide_RevMenubarText mName, pContext
   put the name of stack "revMenuBar" into revMbar
   --
   switch mName
      case "File"
         return value ("revMenubarFileMenu(pContext)" , revMbar)
      case "Edit"
         return value ("revMenubarEditMenu(pContext)" , revMbar)
      case "Tools"
         return value ("revMenubarToolsMenu(pContext)" , revMbar)
      case "Object"
         return value ("revMenubarObjectMenu(pContext)" , revMbar)
      case "Text"
         return value ("revMenubarTextMenu(pContext)" , revMbar)
      case "Development"         
         return value ("revMenubarDevelopmentMenu(pContext)" , revMbar)
      case "View"
         return value ("revMenubarViewMenu(pContext)" , revMbar)
      case "Window"
         return value ("revMenubarWindowMenu(pContext)" , revMbar)
      case "Help"
         return value ("revMenubarHelpMenu(pContext)" , revMbar)
      default
         break
   end switch
   
   return empty
end ide_RevMenubarText


--> Ide
-
function ide_DefaultMenuBarStack
   put ide_DefaultMenubarStackName() into defaultMenubarStackName
   put the name of stack defaultMenubarStackName into revMenuBarStack
   return revMenuBarStack
end ide_DefaultMenuBarStack

function ide_DefaultMenuGroup
   put ide_DefaultMenuBarStack() into revMenuBarStack
   put the long id of group "revMenuBar" of revMenuBarStack into revMenuGroup
   return revMenuGroup
end ide_DefaultMenuGroup

function ide_DefaultMenubarStackName
   put revIDEPaletteToStackName ("menubar") into revMenuBarStackName
   return revMenuBarStackName
end ide_DefaultMenubarStackName


--> IDE | Menubar
-
command ide_ResetDefaultMenubar
   put ide_DefaultMenuGroup() into defaultMenuBarGroup
   set the defaultMenuBar to defaultMenuBarGroup
end ide_ResetDefaultMenubar

function ide_ListToolBarBehaviorNames
   put the stack_Folder of stack "revSEToolbarBehavior" into toolbarBehaviorFolder
   put folder_ListStackNames (toolbarBehaviorFolder) into bNames
   return bNames
end ide_ListToolBarBehaviorNames


--> IDE
-
command ide_EditMenu shortName
   put ide_GetMenuController (shortName) into mController
   edit the script of mController
end ide_EditMenu


--> IDE | Menu | Model
-
command ide_SetScriptEditorTitles shortTitle
   put ide_ListMenuElements() into ideElements
   repeat for each line ideElement in ideElements
      ide_SetMenuTitle ideElement, shortTitle
   end repeat 
end ide_SetScriptEditorTitles

command ide_SetMenuTitle ideElement, pShortTitle
   get ide_ListShortMenuTitles (ideElement)
   if pShortTitle is empty or pShortTitle is not among the lines of it then
      put "Default" into pShortTitle
   end if  
   put ide_ConstructMenuTitle (ideElement, pShortTitle) into mTitle
   put mTitle into LocalArray ["environment"]["menu"][ideElement]
   return shortTitle
end ide_SetMenuTitle


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
      case dict_IsLanguageTerm (thisToken) is true
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


--> Private
-
private command _ReIndexLocalIdeMenus
   -- for when things go wrong
   delete variable LocalArray ["environment"]["menu"]
   repeat for each item ideElement in "List,Script,Recent"
      repeat for each item shortItem in "Default,Revigniter,Watch" -- "Default,Authoring,Watch"
         put word 1 to -1 of shortItem into shortTitle
         put ide_ConstructMenuController (ideElement, shortTitle) into mController
         if exists (mController) is true then
            ide_SetMenuTitle ideElement, shortTitle
         end if
      end repeat
   end repeat
   put LocalArray ["environment"]["menu"] into localEnvMenuArray
   return localEnvMenuArray
end _ReIndexLocalIdeMenus
