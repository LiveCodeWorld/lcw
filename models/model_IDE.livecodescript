﻿script "model_IDE"
--> Metadata
-
name: model_IDE
type: model
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
      -- put revListScriptEditors()
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

function scriptEditor_Behavior bStackName
   if exists (stack bStackName) is false then return empty
   put the name of stack bStackName into bObject
   return bObject
end scriptEditor_Behavior

function scriptEditor_HandlerListBehavior
   return scriptEditor_Behavior ("behavior_IdeHandlerListField")
end scriptEditor_HandlerListBehavior

function scriptEditor_ScriptFieldBehavior
   return scriptEditor_Behavior ("behavior_IdeScriptEditorField")
end scriptEditor_ScriptFieldBehavior

function scriptEditor_HistoryButtonBehavior
   return scriptEditor_Behavior ("behavior_IdeRecentButton")
end scriptEditor_HistoryButtonBehavior

function scriptEditor_FindFieldBehavior
   return scriptEditor_Behavior ("behavior_IdeFindField")
end scriptEditor_FindFieldBehavior

function scriptEditor_CompileButtonBehavior
   return scriptEditor_Behavior ("behavior_IdeCompileButton")
end scriptEditor_CompileButtonBehavior

function scriptEditor_DocumentationFieldBehavior
   return empty
   return scriptEditor_Behavior ("behavior_IdeDocField")
end scriptEditor_DocumentationFieldBehavior

function scriptEditor_LaunchDocsBehavior
   return empty
   -- put scriptEditor_GetBehaviorButton ("LiveCode Launch Docs Button Behavior") into someObject
   return scriptEditor_Behavior ("behavior_IdeDocButton")
end scriptEditor_LaunchDocsBehavior