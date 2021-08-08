script "behavior_IdeHandlerListField"
--> MetaData
-
license: GPLv3
name: behavior_IdeHandlerListField
type: behavior
version: 0.5

/*
Can't get drag handlers working with fields

on dragEnter
   set the dragAction to "link"
   pass dragEnter
end dragEnter

on dragDrop
   put the dragData ["text"]
end dragDrop
*/

--> Events
-
on mouseDown pMenuButton
   if pMenuButton = 3 then
      select the clickline
      put ide_GetMenuTitle ("List") into mTitle
      menu_PopUp mTitle
   else
      pass mouseDown
   end if
end mouseDown
