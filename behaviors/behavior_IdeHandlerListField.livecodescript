script "behavior_IdeHandlerListField"
--> MetaData
-
license: GPLv3
name: behavior_IdeHandlerListField
type: behavior
version: 0.5

--> Events
-
on mouseDown pMenuButton
   if pMenuButton = 3 then
      -- select the clickline
      put ide_GetMenuTitle ("List") into mTitle
      menu_GlobalPopUp mTitle
   else
      pass mouseDown
   end if
end mouseDown

getprop menu_Target
   put scriptEditor_Object() into sObject
   return sObject
end menu_Target
