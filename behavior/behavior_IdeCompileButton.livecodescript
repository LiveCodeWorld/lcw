script "behavior_IdeCompileButton"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_IdeCompileButton
type: behavior
version: 0.4

/*
Was "Livecode Compile Button". We now use before and after handlers.
It may be more robust to wrap "actionCompile" with an after handler rather than "mouseUp"

The command "actionCompile pIgnoreErrors" can be found in the stack "revSEStackbehavior"
# Parameters
#   pIgnoreErrors : whether or not to ignore compilation errors (optional, defaults to false)
# Returns
#   the number of compilation errors encountered.
# Description
#   Attempts to compile the script of object currently being edited. If compile errors occur, adds these to the errors pane,
#   the script is applied regardless of whether errors ocurred or not. The stack is marked as edited.
*/


--> Events
-
after mouseUp
   if the shiftKey is "Up" then
      put rev_ScriptObject() into scriptObject
      
      set the menu_Update of scriptObject to true
      put the script of scriptObject into someScript
      object_ExportScript scriptObject, someScript, true
      put the result into scriptFile
      
      -- script_JustCompiled scriptObject
   end if
end mouseUp

command script_JustCompiled scriptObject
   /*
   -- the IDE does this already
   put the stack_Name of scriptObject into stackName
   stack_MarkEdited stackName
   */
   
   put the stack_Object of scriptObject into stackObject
   put the mainstack of stackObject into mainStackName
   put the filename of stack mainStackName into someFile
   -- put the effective filename of scriptObject into someFile -- throws an error if no filename
   if someFile is empty then
      put merge ("Not exporting or indexing as [[scriptObject]] has no filename and is not saved anywhere!")
      return false
   end if
   
   script_UpdateAndExport scriptObject, true
   put the result into scriptFile
   
   /*
   -- for debugging
   put the rugged_ID of scriptObject into ruggedID
   put merge ("The script_IsDifferent of [[ruggedID]]:") && the script_IsDifferent of scriptObject into someInfo
   put CR & CR after someInfo
   put merge ("The script_File of [[ruggedID]]:") && scriptFile after someInfo
   put CR & CR after someInfo
   put line 1 to 20 of url ("file:" & scriptFile)  after someInfo
   put someInfo
   */
   
   put the name of scriptObject into cName
   opn_Notify merge ("Exported and indexed script of [[cName]]")
   return scriptFile
end script_JustCompiled


