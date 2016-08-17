script "behavior_IdeHandlerListField"
--> MetaData
-
license: GPLv3
name: behavior_IdeHandlerListField
type: behavior
version: 0.3


--> Events
-
on mouseDown pMenuButton
   -- put the params
   if pMenuButton = 3 then
      put the ide_HandlerListMenuTitle of me into mTitle
      if mTitle is empty then put "Global | ScriptEditor | List | Menu" into mTitle
      menu_PopUp mTitle
   else if the optionKey is "Down" then
      put rev_GetFirstScriptEditorSelectedHkey() into hKey
      display_Hkey hKey
   else
      pass mouseDown
   end if
end mouseDown
