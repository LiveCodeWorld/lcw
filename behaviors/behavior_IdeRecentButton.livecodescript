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
   put the ide_MenuTitle ["recent"] of me into mTitle
   if mTitle is empty then put "Global | ScriptEditor | Recent | Default | Menu" into mTitle
   menu_PullDown mTitle
end mouseDown


--> Blah | Menu
-
/* Cannot get local menus to work here???

No idea why you cannot place a working menu here?
*/

on menu_ThisDoesNotWork mTarget
   put the params
end menu_ThisDoesNotWork
