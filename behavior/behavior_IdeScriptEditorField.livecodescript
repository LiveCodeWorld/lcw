script "behavior_IdeScriptEditorField"
--> MetaData
-
author: David Bovill
copyright: David Bovill
name: behavior_IdeScriptEditorField
type: behavior


--> Global | ScriptEditor | Script | Basic | Menu
-
on menu_Test
 
end menu_Test


--> Events
-
on mouseDown pMenuButton
   put the ide_ScriptFieldMenuTitle of me into mTitle
   if mTitle is empty then
      put "Global | ScriptEditor | Script | Basic | Menu" into mTitle
   end if
   menu_PopUp mTitle
end mouseDown

on tabkey
   put the long id of me into scriptField
   put the selectedText of scriptField into selText
   if selText is empty then pass tabkey
   scriptField_Tabkey selText, scriptField
   pass tabkey
end tabkey
