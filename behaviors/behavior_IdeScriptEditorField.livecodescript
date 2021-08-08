script "behavior_IdeScriptEditorField"
--> MetaData
-
license: GPLv3
copyright: David Bovill
name: behavior_IdeScriptEditorField
type: behavior
version: 0.2


--> Events
-
on mouseDown pMenuButton
   put ide_GetMenuTitle ("Script") into mTitle
   if mTitle is empty then
      put "Global | ScriptEditor | Script | Default | Menu" into mTitle
   end if
   menu_PopUp mTitle
end mouseDown

on tabkey
   if the shiftkey is "Up" then pass tabkey
   put the long id of me into scriptField
   put the selectedText of scriptField into selText
   
   scriptField_DoTabkey selText, scriptField
   if the result is false then
      pass tabkey
   end if
end tabkey
