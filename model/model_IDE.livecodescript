script "model_IDE"
--> Metadata
-
name: model_IDE
type: model
author: David Bovill
copyright: David Bovill
license: GPLv3
version: 0.9

/*
This library is for customising the livecode IDE, through understandig it's structure.
We can then attach and remove our own behaviors to the IDE, and the Script Editor in particular.
This is not using the official API, so it's brittle but has proven remarkably stable over time.

This model abstracts, both key controls within the Livecode IDE, and behaviors that we can attach to them.

on setBehaviors
   -- from stack "revSEStackbehavior"
   set the behavior of group "Editor" of me to the long id of stack revIDEScriptEditorBehavior("editor")
   set the behavior of group "Menubar" of me to the long id of stack revIDEScriptEditorBehavior("menubar")
   set the behavior of group "Script Tabs" me to the long id of stack revIDEScriptEditorBehavior("scripttabs")
   set the behavior of group "Toolbar" of me to the long id of stack revIDEScriptEditorBehavior("toolbar")
   set the behavior of group "Handler List" of me to the long id of stack revIDEScriptEditorBehavior("handlerlist")
   set the behavior of group "Left Bar" of me to the long id of stack revIDEScriptEditorBehavior("leftbar")
   set the behavior of field "Filter" of group "Left Bar" of me to the long id of stack revIDEScriptEditorBehavior("filterfield")
   set the behavior of group "Variables" of group "Panes" of me to the long id of stack revIDEScriptEditorBehavior("variablespane")
   set the behavior of group "Documentation" of group "Panes" of me to the long id of stack revIDEScriptEditorBehavior("documentationpane")
   set the behavior of field "Filter" of group "Variables" of group "Panes" of me to the long id of stack revIDEScriptEditorBehavior("filterfield")
   set the behavior of button "Show Globals" of group "Variables" of group "Panes" of me to the long id of stack revIDEScriptEditorBehavior("variablescheckbox")
   set the behavior of button "Show Environment Vars" of group "Variables" of group "Panes" of me to the long id of stack revIDEScriptEditorBehavior("variablescheckbox")
   set the behavior of group "Gutter" of group "Editor" of me to the long id of stack revIDEScriptEditorBehavior("gutter")
   set the behavior of group "Interactive Find" of group "Editor" of me to the long id of stack revIDEScriptEditorBehavior("interactive find")
end setBehaviors
*/


--> Variables
-
local LocalArray


--> IDE | MenuTitle
-
command ide_EditMenu shortName
   if word 1 of shortName is not "Global" then
      put "Global | ScriptEditor |" && shortName && "| Menu" into mTitle
   end if
   menu_Edit mTitle
end ide_EditMenu


--> IDE | MenuTitle| Recent
-
getprop ide_RecentChangesMenu
   put ide_GetMenuTitle ("Recent") into mTitle
   if mTitle is empty then put "Global | ScriptEditor | Recent | Default | Menu" into mTitle
   return mTitle
end ide_RecentChangesMenu

setprop ide_RecentChangesMenu shortTitle
   ide_SetMenuTitle "Recent", shortTitle
   return the result
end ide_RecentChangesMenu

function ide_RecentChangesShortTitle
   set the itemdelimiter to " | "
   put the ide_RecentChangesMenu of me into mTitle
   put item 4 of mTitle into shortName
   return shortName
end ide_RecentChangesShortTitle

function ide_RecentChangesShortTitles
   put ide_ListShortMenuTitles ("Recent") into shortNames
   return shortNames
   
   put menu_ListGlobalTitles() into gTitles
   set the itemdelimiter to " | "
   repeat for each line mTitle in gTitles
      if item 2 of mTitle = "ScriptEditor" then
         put item 3 of mTitle into shortName
         if shortName = "Custom" then next repeat
         put shortName & CR after shortNames
      end if
   end repeat
   return shortNames
end ide_RecentChangesShortTitles

function ide_ListMenuTitles pIdeElement
   put menu_ListGlobalTitles() into mTitles
   put "Global | ScriptEditor |" into mTitleStem
   if pIdeElement is not empty then
      put space & pIdeElement && "|" after mTitleStem
   end if
   put mTitleStem & "*" into someFilter
   filter mTitles with someFilter
   return mTitles
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
   return shortNames
end ide_ListShortMenuTitles


--> IDE | MenuTitle | Model | Props
-
getprop ide_ScriptFieldMenuTitle
   if the shiftKey is "Down" then
      put "Global | Script Editor | Extras | Menu" into mTitle
   else
      put ide_GetMenuTitle ("scripteditor field") into mTitle
      if mTitle is empty then
         put "Global | ScriptEditor | Script | Basic | Menu" into mTitle
      end if
   end if
   return mTitle
end ide_ScriptFieldMenuTitle

setprop ide_ScriptFieldMenuTitle shortName
   if word 1 of shortName is not "Global" then
      put "Global | ScriptEditor |" && shortName && "| Menu" into mTitle
   end if
   ide_SetMenuTitle "scripteditor field", mTitle
   return the result
end ide_ScriptFieldMenuTitle


--> IDE | MenuTitle | Model
-
command ide_ResetMenuTitle
   delete variable LocalArray ["environment"]["menu"]
end ide_ResetMenuTitle

function ide_GetMenuTitle ideElement
   put LocalArray ["environment"]["menu"][ideElement] into mTitle
   return mTitle
end ide_GetMenuTitle

command ide_SetMenuTitle ideElement, shortTitle
   if shortTitle is empty or shortTitle is not among the lines of ide_ListShortMenuTitles (ideElement) then
      put "Default" into shortTitle
   end if  
   put ide_ConstructMenuTitle (shortTitle, ideElement) into mTitle
   put mTitle into LocalArray ["environment"]["menu"][ideElement]
   return shortTitle
end ide_SetMenuTitle

function ide_ConstructMenuTitle shortName, ideElement
   if word 1 of shortName is "Global" then return shortName
   
   put "Global | ScriptEditor |" && ideElement && "|" && shortName && "| Menu" into mTitle
   return mTitle
end ide_ConstructMenuTitle


--> Events
-
on libraryStack
   put the short name of the target into targetStackName
   put the short name of me into myName
   if targetStackName is not myName then pass libraryStack
   
   rev_AddBehaviorHacks true
end libraryStack


--> Stack | Edited
-
/*
Marks whether or not a stack has been edited. Very useful for deciding what needs saving.
*/

getprop stack_IsEdited
   put the stack_Name of the target into stackName
   put stack_ListEditedNames ("edited") into editedStackNames
   return stackName is among the lines of editedStackNames
end stack_IsEdited

setprop stack_IsEdited someBoolean
   put the stack_Name of the target into stackName
   if someBoolean is true then
      stack_MarkEdited stackName
   else
      stack_MarkSaved stackName
   end if
end stack_IsEdited

function stack_ListEditedNames pType
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
end stack_ListEditedNames

command stack_SaveEdited editedStackName
   global gREVStackStatus
   
   if editedStackName = "Save All" then
      put stack_ListEditedNames() into stackNames
   else
      put editedStackName into stackNames
   end if
   
   repeat for each line stackName in stackNames
      try
         put the effective fileName of stack stackName into pFilePath
         save stack stackName
         delete global gREVStackStatus [stackName]
         
         opn_Notify merge ("Saved stack '[[stackName]]'!")
      catch e
         breakpoint
         put stackName & CR after couldntSaveStackNames
         answer warning merge ("Could not save stack '[[stackName]]'!")
      end try
   end repeat
   
   if couldntSaveStackNames is not empty then
      put couldntSaveStackNames
   else
      opn_Notify "Saved all edited stacks!"
   end if
end stack_SaveEdited

command stack_MarkSaved stackName
   -- was "rev_MarkStackSaved"
   global gREVStackStatus
   
   if stackName is empty then put the short name of this stack into stackName
   delete global gREVStackStatus [stackName]
end stack_MarkSaved

command stack_MarkEdited stackName
   -- was "rev_MarkStackEdited"
   global gREVStackStatus
   
   if stackName is empty then put the short name of this stack into stackName
   if char 1 to 3 of stackName is not "rev" then
      put "edited" into gREVStackStatus [stackName]
   end if
end stack_MarkEdited


--> IDE
-
command rev_AddBehaviorHacks pBoolean
   /*
   -- was "rev_AddBehaviorHacks"
   
   This handler has no dependencies other than those in this stack ("model_IDE").
   It turns on and off the behavior based IDE menu hacks.
   */
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
      
      if someBoolean is true then
         set the behavior of scriptField to scriptFieldBehavior
         set the behavior of historyButton to historyBehavior
         set the behavior of handlerTreeField to handlerBehavior
         set the behavior of simpleFindField to simpleFindBehavior
         set the behavior of compileButton to compileButtonBehavior
         set the behavior of scriptEditorDocField to documentationFieldBehavior
         set the behavior of launchDocsButton to launchDocsBehavior
      else
         set the behavior of scriptField to empty
         set the behavior of historyButton to empty
         set the behavior of handlerTreeField to empty
         set the behavior of simpleFindField to empty
         set the behavior of compileButton to empty
         set the behavior of scriptEditorDocField to empty
         set the behavior of launchDocsButton to empty
      end if
   end repeat
end rev_AddBehaviorHacks


--> IDE | Rev
-
function rev_GetModifiedObjects pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   dispatch "revSEGetModifiedObjects" to editorStack
   return the result
end rev_GetModifiedObjects

function rev_GetScriptEditorHistoryObjects pEditorNum
   put rev_HistoryButton (pEditorNum) into historyButton
   put value ("seHistoryGet()", historyButton) into someObjects
   return someObjects
end rev_GetScriptEditorHistoryObjects

function rev_ScriptEditorIsOpen
   return rev_OpenScriptEditorNames() is not empty
end rev_ScriptEditorIsOpen


--> IDE | ScriptEditor | Rev
-
function rev_LaunchDocsButton pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   if exists (btn "LaunchDocs" of group "Documentation" of cd "Main" of editorStack) is false then return empty
   put the long id of btn "LaunchDocs" of group "Documentation" of cd "Main" of editorStack into someObject
   return revRuggedID (someObject)
end rev_LaunchDocsButton

function rev_ScriptEditorStack pEditorNum
   switch
      case pEditorNum is empty
         return rev_TopScriptEditor()
      case pEditorNum = 0
         put the long id of stack "revSETemplate" of stack "revNewScriptEditor" into stackObject
         return revRuggedID (stackObject)
      case pEditorNum is a number
         put "revNewScriptEditor" && pEditorNum into stackName
         if exists (stack stackName) is false then return empty
         return the name stack stackName
      default
         return rev_TopScriptEditor()
   end switch
end rev_ScriptEditorStack

function rev_TopScriptEditor
   put the stack_Name of the target into stackName
   if word 1 of stackName is "revNewScriptEditor" then
      return the long id of stack stackName
   else 
      put the openstacks into stackNames
      filter stackNames with "revNewScriptEditor*"
      if stackNames is empty then return empty
      put line 1 of stackNames into stackName
      if exists(stack stackName) is false then
         put the stack_Name of the target into stackName
      end if
      return the long id of stack stackName
   end if
end rev_TopScriptEditor

function rev_ScriptObject
   put rev_TopScriptEditor() into stackObject
   if exists(stackObject) is false then return empty
   dispatch "revSEGetCurrentObject" to stackObject
   put the result into someObject
   return someObject
end rev_ScriptObject

function rev_OpenScriptEditorNames
   put the openstacks into stackNames
   -- filter stackNames with "revscripteditor *" -- old version ???
   filter stackNames with "revNewScriptEditor *"
   return stackNames
end rev_OpenScriptEditorNames

function rev_ScriptEditorField pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   if exists (fld "Script" of group "Editor" of cd "Main" of editorStack) is false then return empty
   put the long id of fld "Script" of group "Editor" of cd "Main" of editorStack into someObject
   return revRuggedID (someObject)
end rev_ScriptEditorField

function rev_HistoryButton pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   if exists (btn "history" of group "Script Tabs" of cd "Main" of editorStack) is false then return empty
   put the long id of btn "history" of group "Script Tabs" of cd "Main" of editorStack into someObject
   return revRuggedID (someObject)
end rev_HistoryButton

function rev_HandlerTreeField pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   if exists (field "handlers" of group "Left Bar" of cd "Main" of editorStack) is false then return empty
   put the long id of field "handlers" of group "Left Bar" of cd "Main" of editorStack into someObject
   return revRuggedID (someObject)
end rev_HandlerTreeField

function rev_SimpleFindField pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   if exists (btn "history" of group "Script Tabs" of cd "Main" of editorStack) is false then return empty
   put the long id of fld "find" of group "Interactive Find" of cd "Main" of editorStack into someObject
   return revRuggedID (someObject)
end rev_SimpleFindField

function rev_CompileButton pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   if exists (btn "compile" of group "Toolbar" of cd "Main" of editorStack) is false then return empty
   put the long id of btn "compile" of group "Toolbar" of cd "Main" of editorStack into someObject
   return revRuggedID (someObject)
end rev_CompileButton

function rev_ScriptEditorDocField pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   if exists (field "View" of group "Documentation" of cd "Main" of editorStack) is false then return empty
   put the long id of field "View" of group "Documentation" of cd "Main" of editorStack into someObject
   return revRuggedID (someObject)
end rev_ScriptEditorDocField


--> IDE | ScriptEditor | Rev | Pane
-
function rev_ListScriptEditorPaneNames pEditorNum
   put rev_ScriptEditorPanesGroup (pEditorNum) into scriptEditorPanesGroup
   return value ("seAvailablePanes()", scriptEditorPanesGroup)
end rev_ListScriptEditorPaneNames

function rev_ScriptEditorPaneTabsGroup pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   if exists (group "Pane Tabs" of cd "Main" of editorStack) is false then return empty
   put the long id of group "Pane Tabs" of cd "Main" of editorStack into someObject
   return revRuggedID (someObject)
end rev_ScriptEditorPaneTabsGroup

function rev_ScriptEditorPanesGroup pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   if exists (group "Panes" of cd "Main" of editorStack) is false then return empty
   put the long id of group "Panes" of cd "Main" of editorStack into someObject
   return revRuggedID (someObject)
end rev_ScriptEditorPanesGroup


--> IDE | Behavios
-
/*
We need a model for this.
*/

function scriptEditor_HandlerListBehavior
   -- behavior_IdeHandlerListField
   if exists (stack "behavior_IdeHandlerListField") then
      put the name of stack "behavior_IdeHandlerListField" into someObject
   else
      -- this is the old way of doing things and is too fragile
      breakpoint
      put scriptEditor_GetBehaviorButton ("Livecode Handler List Field") into someObject
   end if
   if exists(someObject) is false then return empty
   return revRuggedID (someObject)
end scriptEditor_HandlerListBehavior

function scriptEditor_ScriptFieldBehavior
   if exists (stack "behavior_IdeScriptEditorField") then
      put the name of stack "behavior_IdeScriptEditorField" into bObject
      return bObject
   else
      put scriptEditor_GetBehaviorButton ("LiveCode Script Editor Field") into someObject
      if exists(someObject) is false then return empty
      return revRuggedID (someObject)
   end if
end scriptEditor_ScriptFieldBehavior

function scriptEditor_HistoryButtonBehavior
   if exists (stack "behavior_IdeRecentButton") then
      put the name of stack "behavior_IdeRecentButton" into bObject
      return bObject
   else
      -- this is the old way of doing things and is too fragile
      breakpoint
      put scriptEditor_GetBehaviorButton ("Livecode Script History Button") into bObject
      if exists(bObject) is false then return empty
      return revRuggedID (bObject)
   end if
end scriptEditor_HistoryButtonBehavior

function scriptEditor_FindFieldBehavior
   if exists (stack "behavior_IdeFindField") then
      put the name of stack "behavior_IdeFindField" into bObject
      return bObject
   else
      -- this is the old way of doing things and is too fragile
      breakpoint
      put scriptEditor_GetBehaviorButton ("Livecode Simple Find Field") into someObject
      if exists(someObject) is false then return empty
      return revRuggedID (someObject)
   end if
end scriptEditor_FindFieldBehavior

function scriptEditor_CompileButtonBehavior
   if exists (stack "behavior_IdeCompileButton") then
      put the name of stack "behavior_IdeCompileButton" into bObject
      return bObject
   else
      -- this is the old way of doing things and is too fragile
      breakpoint
      put the long id of control id 1014 of stack "View|Menu|Button" into compileButtonBehavior
      return revRuggedID (compileButtonBehavior)
   end if
end scriptEditor_CompileButtonBehavior

function scriptEditor_DocumentationFieldBehavior
   if exists (stack "behavior_IdeRecentButton") then
      put the name of stack "behavior_IdeFindField" into bObject
      return bObject
   else
      -- this is the old way of doing things and is too fragile
      breakpoint
      put scriptEditor_GetBehaviorButton ("LiveCode Script Documentation Field Behavior") into someObject
      if exists(someObject) is false then return empty
      return revRuggedID (someObject)
   end if
end scriptEditor_DocumentationFieldBehavior

function scriptEditor_LaunchDocsBehavior
   if exists (stack "behavior_IdeRecentButton") then
      put the name of stack "behavior_IdeFindField" into bObject
      return bObject
   else
      put scriptEditor_GetBehaviorButton ("LiveCode Launch Docs Button Behavior") into someObject
      if exists(someObject) is false then return empty
      return revRuggedID (someObject)
   end if
end scriptEditor_LaunchDocsBehavior



--> old hArray way of doing things (a bit brittle)
-
/*
Not needed in this library except for compatability.
It is a powerful and flexibe way of naming things though.
*/

function scriptEditor_GetBehaviorButton bName   
   put hArray_GetNamedObjectType (bName, "behavior") into behaviorButton
   return behaviorButton
end scriptEditor_GetBehaviorButton
