script "behavior_IdeScriptEditorField"
--> MetaData
-
license: GPLv3
copyright: David Bovill
name: behavior_IdeScriptEditorField
type: behavior
version: 0.1


--> Events
-
on mouseDown pMenuButton
   -- ide_SetMenuTitle "scripteditor field", mTitle
   -- put "Global | Script Editor | Extras | Menu" into mTitle
   put ide_GetMenuTitle ("Script") into mTitle
   if mTitle is empty then
      put "Global | ScriptEditor | Script | Default | Menu" into mTitle
   end if
   menu_PopUp mTitle
end mouseDown

on tabkey
   put the long id of me into scriptField
   put the selectedText of scriptField into selText
   if selText is empty then pass tabkey
   
   scriptField_DoTabkey selText, scriptField
   if the result is false then
      -- pass tabkey
   end if
end tabkey
