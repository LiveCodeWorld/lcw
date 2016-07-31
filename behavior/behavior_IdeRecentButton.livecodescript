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
   -- put "Global | Git | Watch | Menu" into mTitle
   -- put "Blah | Menu" into mTitle -- bug: no idea why this does not work
   put "Global | ScriptEditor | Watch | Menu" into mTitle
   menu_PullDown mTitle
end mouseDown


--> Menu | Props
-


--> Blah | Menu
-
/* Cannot get local menus to work here???
*/

on menu_ThisDoesNotWork mTarget
   put the params
end menu_ThisDoesNotWork
