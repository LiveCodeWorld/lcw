script "model_IDE"
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

See stack "lib_ScriptEditor" for code related to script editor tabs.
This model abstracts, both key controls within the Livecode IDE, and behaviors that we can attach to them.
*/

local Rev_MenuNameList = "File,Edit,Tools,Object,Text,Development,View,Window,Help"

--> Working on
-
function rev_CheckMenuName revName, pConstruct
   put rev_GetMenuNameList (pConstruct) into revMenuNameList
   set the wholematches to true
   return revName is among the items of revMenuNameList
end rev_CheckMenuName

function rev_GetMenuNameList pConstruct
   if (pConstruct is true) OR (Rev_MenuNameList is empty) then
      -- we store the values in teh scripts case conditions
      put "behavior_ViewMenuGroup" into bName
      if exists (stack bName) is false then return empty
      put the hkey_CaseConditions ["M ide_RevMenubarMenuPick"] of stack bName into Rev_MenuNameList
      replace CR with comma in Rev_MenuNameList
   end if
   return Rev_MenuNameList
end rev_GetMenuNameList


--> SE
-
getprop se_DisplayedObject
   put the se_Name of the target into seName
   if exists (stack seName) is false then return empty
   --
   dispatch "revSEGetCurrentObject" to stack seName
   put the result into someObject
   return someObject
end se_DisplayedObject

getprop se_Stack
   put the se_Name of the target into seName
   if exists (stack seName) is false then return empty
   --
   return the name of stack seName
end se_Stack

getprop se_Name
   -- must be a control in a revScripteditor
   put the stack_Name of the target into seName
   if word 1 of seName is "revNewScriptEditor" then
      return seName
   else
      return empty
   end if
end se_Name

getprop se_Script
   put the se_Name of the target into seName
   if exists (stack seName) is false then return empty
   --
   dispatch function "revSEGetScript" to stack seName
   put the result into seScript
   return seScript
end se_Script

setprop se_Script seScript
   put the se_Name of the target into seName
   if exists (stack seName) is false then return empty
   --
   put word 1 to -1 of seScript into seScript
   put CR after seScript
   --
   dispatch "revSESetScript" to stack seName with seScript
   return seName
end se_Script

getprop se_AvailableHandlers
   put the se_Name of the target into seName
   if exists (stack seName) is false then return empty
   --
   dispatch "revSEGetHandlerList" to stack seName
   put the result into aHandlers
   return aHandlers
end se_AvailableHandlers

command se_Clean seName, pFormat, pApply
   if exists (stack seName) is false then return empty
   --
   if pFormat is true then
      dispatch "revSEIndentScript" to stack seName
   end if
   --
   put the se_Script of stack seName into seScript
   put the se_AvailableHandlers of stack seName into hTable
   
   ## Tidy first and last lines of each handler
   repeat for each line hKeyLine in hTable
      htable_ExactLineOffsets hkeyLine, hTable, startLineNum, endLineNum
      --
      _TidyScriptLine seScript, startLineNum
      _TidyScriptLine seScript, endLineNum
   end repeat
   --
   set the se_Script of stack seName to seScript
   --
   if pApply is true then
      try
         dispatch "revSEApply" to stack seName
      catch e
         breakpoint
      end try
   end if
   return seScript
end se_Clean

command se_FormatAndApply seName
   if exists (stack seName) is false then return empty
   --
   dispatch "revSEIndentScript" to stack seName
   try
      dispatch "revSEApply" to stack seName
   catch e
      breakpoint
   end try
end se_FormatAndApply

private command _TidyScriptLine @seScript, sLineNum
   get line sLineNum of seScript
   --
   repeat for each word sWord in it
      put sWord & space after goodline
   end repeat
   delete char -1 of goodline
   -- put word 1 to -1 of it into goodLine
   -- put (word 1 of goodLine && word 2 of goodLine) into word 1 to 2 of goodLine
   --
   if goodLine = it then
      -- all good
   else
      put goodLine into line sLineNum of seScript
   end if 
end _TidyScriptLine


--> ScriptEditor
-
function scriptEditor_GetSelectedText pScriptEditorName
   if exists (stack pScriptEditorName) then
      put pScriptEditorName into seName
   else
      put rev_ScriptEditorField() into scriptEditorField
      put the se_Name of scriptEditorField into seName
   end if
   
   dispatch function "revSEGetSelectedText" to stack seName
   put the result into sText   
   return sText
   
   put the selectedtext of scriptEditorField into sText
   return sText
end scriptEditor_GetSelectedText

function scriptEditor_Object
   -- was "rev_ScriptObject"
   put scriptEditor_GetTop() into stackObject
   if exists(stackObject) is false then return empty
   dispatch "revSEGetCurrentObject" to stackObject
   put the result into someObject
   return someObject
end scriptEditor_Object

function scriptEditor_GetTop
   -- was "scriptEditor_GetTop()"
   
   put the short name of the defaultstack into stackName
   if word 1 of stackName is "revNewScriptEditor" then
      return the long id of stack stackName
   else
      put the openstacks into stackNames
      filter stackNames with "revNewScriptEditor*"
      if stackNames is empty then return empty
      put line 1 of stackNames into firstEditorStackName
      return the long id of stack firstEditorStackName
   end if
end scriptEditor_GetTop


--> ScriptEditor | Hkey
-
function scriptEditor_GetHkey
   put scriptEditor_Object() into sObject
   put rev_HandlerTreeField() into handlerField
   put the hilitedLine of handlerField into lineNum
   --
   put the cHandlers of handlerField into hTable
   put line lineNum of hTable into hKeyLine
   --
   hkeyLine_Deconstruct hKeyLine, hName, hType, emptyObject
   put hKeyLine_Construct (hName, hType, sObject) into hkey
   --
   return hkey
end scriptEditor_GetHkey

function scriptEditor_GetHkeyLine
   -- was "rev_GetHandlerTreeSelectedInfo"
   put rev_HandlerTreeField() into handlerField
   put the hilitedLine of handlerField into lineNum
   --
   put the cHandlers of handlerField into hTable
   put line lineNum of hTable into hKeyLine
   --
   return hKeyLine
end scriptEditor_GetHkeyLine


--> IDE | ScriptEditor | Pane | Model
-
function rev_ScriptEditorPanesGroup pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   if exists (group "Panes" of cd "Main" of editorStack) is false then return empty
   put the long id of group "Panes" of cd "Main" of editorStack into someObject
   return revRuggedID (someObject)
end rev_ScriptEditorPanesGroup

function rev_ScriptEditorPaneTabsGroup pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   if exists (group "Pane Tabs" of cd "Main" of editorStack) is false then return empty
   put the long id of group "Pane Tabs" of cd "Main" of editorStack into someObject
   return revRuggedID (someObject)
end rev_ScriptEditorPaneTabsGroup


--> IDE | ScriptEditor | Rev
-
function rev_LaunchDocsButton pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   if exists (btn "LaunchDocs" of group "Documentation" of cd "Main" of editorStack) is false then return empty
   put the long id of btn "LaunchDocs" of group "Documentation" of cd "Main" of editorStack into someObject
   return revRuggedID (someObject)
end rev_LaunchDocsButton

function rev_HandlerTreeField pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   if exists (field "handlers" of group "Left Bar" of cd "Main" of editorStack) is false then return empty
   put the long id of field "handlers" of group "Left Bar" of cd "Main" of editorStack into someObject
   return revRuggedID (someObject)
end rev_HandlerTreeField

function rev_ScriptEditorStack pEditorNum
   switch
      case pEditorNum is empty
         return scriptEditor_GetTop()
      case pEditorNum = 0
         put the long id of stack "revSETemplate" of stack "revNewScriptEditor" into stackObject
         return revRuggedID (stackObject)
      case pEditorNum is a number
         put "revNewScriptEditor" && pEditorNum into stackName
         if exists (stack stackName) is false then return empty
         return the name stack stackName
      default
         return scriptEditor_GetTop()
   end switch
end rev_ScriptEditorStack

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


--> ScriptEditor | List
-
function rev_OpenScriptEditorNames
   put revListScriptEditors() into stackObjects
   repeat for each line stackObject in stackObjects
      put the short name of stackObject & CR after stackNames
   end repeat
   delete char -1 of stackNames
   /*
   put the openstacks into stackNames
   filter stackNames with "revNewScriptEditor *"
   */
   return stackNames
end rev_OpenScriptEditorNames

function rev_GetModifiedObjects pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   dispatch "revSEGetModifiedObjects" to editorStack
   return the result
end rev_GetModifiedObjects

function scriptEditor_ListEditingObjects pEditorNum
   -- see also "revIDEScriptEditingObjects()"
   put rev_HistoryButton (pEditorNum) into historyButton
   put value ("seHistoryGet()", historyButton) into someObjects
   return someObjects
end scriptEditor_ListEditingObjects

function scriptEditor_IsOpen
   return rev_OpenScriptEditorNames() is not empty
end scriptEditor_IsOpen


--> ScriptEditor | Behaviors
-
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
