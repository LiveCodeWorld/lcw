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
   -- Global | ScriptEditor | List | Menu
   if pMenuButton = 3 then
      select the clickline
      put the ide_MenuTitle ["List"] of me into mTitle
      if mTitle is empty then put "Global | ScriptEditor | List | Default | Menu" into mTitle
      menu_PopUp mTitle
   else
      pass mouseDown
   end if
end mouseDown
