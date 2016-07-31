script "behavior_IdeScriptEditorField"
--> MetaData
-
author: David Bovill
copyright: David Bovill
name: behavior_IdeScriptEditorField
type: behavior


--> Events
-
on mouseDown pMenuButton
   if the shiftKey is "Down" then
      menu_PopUp "Global | Script Editor | Extras | Menu"
   else
      menu_PopUp "Global | Script | Editor | Menu"
   end if
end mouseDown

on tabkey
   put the long id of me into scriptField
   put the selectedText of scriptField into selText
   if selText is empty then pass tabkey
   scriptField_Tabkey selText, scriptField
   pass tabkey
end tabkey
