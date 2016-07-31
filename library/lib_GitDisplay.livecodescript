script "lib_GitDisplay"
--> MetaData
-
license: GPLv3
name: lib_GitDisplay
type: library
version: 0.1


/*
A library for working with GIT.
It has not been tested on unix (should work fine), or Windows machines (beware of line ending issues).
*/

--> Objects
-
getprop git_Tree
   put _gitTreeView() into gitTreeView
   return gitTreeView
end git_Tree

getprop git_TreeField
   put _gitTreeView() into gitTreeView
   return the tree_Field of gitTreeView
end git_TreeField

private function _gitTreeView
   put the long id of grp 1 of card 1 of stack "libOPN_Git" into gitTreeView
   return gitTreeView
end _gitTreeView


--> Display
-
command display_GitStatus
   set the cursor to watch
   git_RefreshDisplay "Git Status"
   
   put the git_TreeField of me into displayView
   object_GoTo displayView
   set the displayed_File of displayView to empty
   set the displayed_Object of displayView to empty
end display_GitStatus

command display_GitHkeyLog hKey, pDoubleUpThing, pStackLabel
   put hkey_HandlerFile (hKey) into handlerFile
   
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put "History for" && kwote(handler_ConvertType (hType) && hName) into someTitle
   
   put handlerFile into gitRelativeFile
   git_SetRelativePath gitRelativeFile
   
   -- temp set gitRoot
   put git_GetRootFolder() into oRoot
   put git_GetCheckoutFolder (handlerFile) into tempRootFolder
   git_SetRootFolder tempRootFolder
   
   if pStackLabel is empty then put "Hkey Log" into pStackLabel
   put hKey into someTitle
   display_GitFileHistory gitRelativeFile, someTitle, pDoubleUpThing, pStackLabel
   
   put the result into treeView
   put the tree_Field of treeView into treeField
   
   lock messages
   set the displayed_Hkey of treeField to hKey
   set the displayed_Object of treeField to hObject
   set the displayed_File of treeField to handlerFile
   unlock messages
   
   -- reset git root
   git_SetRootFolder oRoot
   return treeView
end display_GitHkeyLog

command display_GitScriptLog someObject, pDoubleUpThing, pStackLabel
   put the script_File of someObject into someFile
   
   -- temp set gitRoot
   -- should maybe do this built in with all git file related handlers?
   put git_GetRootFolder() into oRoot
   put git_GetCheckoutFolder (someFile) into tempRootFolder
   git_SetRootFolder tempRootFolder
   
   if pStackLabel is empty then put "Script Log" into pStackLabel
   put the mobile_Name of someObject into someTitle
   
   git_SetRelativePath someFile
   display_GitFileHistory someFile, someTitle, pDoubleUpThing, pStackLabel
   put the result into treeView
   
   put the tree_Field of treeView into treeField
   set the displayed_Object of treeField to someObject
   
   -- reset git root
   git_SetRootFolder oRoot
   return tempRootFolder
end display_GitScriptLog

command display_GitFileHistory someFile, pTitle, pDoubleUpThing, pStackLabel
   put git_FileLogOutline (someFile) into someOutline
   display_LogOutline someOutline, someFile, pTitle, pDoubleUpThing, pStackLabel
   return the result
end display_GitFileHistory

command display_LogOutline someOutline, someFile, pTitle, pDoubleUpThing, pStackLabel
   put empty into pExpandLevel
   put false into pKeepHidden
   put "palette" into pStackStyle
   display_Outline someOutline, pTitle, "Global | Git | Log | Menu", "Global | Git | Line | Log | Menu", pExpandLevel, pKeepHidden, pStackStyle, pStackLabel
   
   put the result into treeView
   put the tree_Field of treeView into treeField
   
   set the displayed_File of treeField to someFile
   if exists (pDoubleUpThing) then 
      set the trigger_Object ["tree_MouseDoubleUp"] of treeField to pDoubleUpThing
   else if pDoubleUpThing is not empty then
      -- assume it is a trigger_Name
      set the trigger_Name ["mouseDoubleUp"] of treeField to pDoubleUpThing
   end if 
   return treeView
end display_LogOutline

command display_StackHistory someObject
   put the stack_Object of someObject into stackObject
   put the filename of stackObject into stackFile
   
   -- should maybe do this built in with all git file related handlers?
   put git_GetRootFolder() into oRoot
   put the git_CheckoutFolder of someObject into tempRootFolder
   git_SetRootFolder tempRootFolder
   
   put git_FileLogOutline (stackFile) into someOutline
   
   lock screen
   put "Stack Log for:" && the name of stackObject into someTitle
   put empty into pExpandLevel
   
   display_Outline someOutline, someTitle, "Global | Git | Stack | History | Menu", "Global | Git | Line | Stack | Log | Menu", pExpandLevel, false --, "toplevel"
   put the result into treeView
   put the tree_Field of treeView into treeField
   
   set the displayed_Object of treeField to stackObject
   set the displayed_File of treeField to someFile
   unlock screen
   
   git_SetRootFolder oRoot
   return treeView
end display_StackHistory
