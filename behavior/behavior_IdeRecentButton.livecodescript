script "behavior_IdeRecentButton"
--> MetaData
-
author: David Bovill
copyright: David Bovill
name: behavior_IdeRecentButton
type: behavior

/*
This behavior alters the menu of the Livecode history Button menu in the revScriptEditor.
*/

local LocalArray


--> Events
-
on mouseDown pMenuButton
   if the shiftKey is "Down" then pass mouseDown
   put _GetRecentChangesMenu() into mTitle
   menu_PullDown mTitle
end mouseDown

private function _GetRecentChangesMenu
   try
      put env_GetRecentChangesMenu() into mTitle
   catch e
      put "Global | ScriptEditor | Watch | Menu" into mTitle
   end try
   return mTitle
end _GetRecentChangesMenu


--> Blah | Menu
-
/* Cannot get local menus to work here???

No idea why you cannot place a working menu here?
*/

on menu_ThisDoesNotWork mTarget
   put the params
end menu_ThisDoesNotWork
