﻿script "behavior_IdeCompileButton"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_IdeCompileButton
type: behavior
version: 0.6

/*
This script is now not required as we use "behavior_RevSEStackBehavior" to
set the behavior of stack "revSEStackBehavior" to (the name of stack "behavior_RevSEStackBehavior")

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

after mouseUp
   if the shiftKey is "Up" then
      set the cursor to watch
      put scriptEditor_Object() into scriptObject
      dispatch "script_ExportAndIndexMenus" with scriptObject
   end if
end mouseUp
*/
