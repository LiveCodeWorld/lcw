script "Global | Data | Show | Menu"
--> MetaData
-
license: GPLv3
name: Global | Data | Show | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the data_View of tObject into dView
   return dView
end menu_Target

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget

getprop checked_ShowHeader [dView]
   put the header_IsVisible of dView into sBoolean
   return sBoolean
end checked_ShowHeader

getprop checked_ShowFooter [dView]
   put the footer_IsVisible of dView into sBoolean
   return sBoolean
end checked_ShowFooter

getprop checked_ShowBody [dView]
   put the body_IsVisible of dView into sBoolean
   return sBoolean
end checked_ShowBody

getprop checked_ShowSimple [dView]
   put the simple_Header of dView into sBoolean
   return sBoolean
end checked_ShowSimple

getprop style_Param [dView]
   return the dataView_Style of dView
end style_Param

getprop style_Params [dView]
   return the dataView_Styles of dView
end style_Params


--> Global | Data | Show | Menu
-
on menu_Style dView, sStyle
   set the dataView_Style of dView to sStyle
end menu_Style

on menu_ShowSimple dView
   put the simple_Header of dView into sBoolean
   set the simple_Header of dView to (sBoolean is false)
end menu_ShowSimple

private on _
end _

on menu_ShowHeader dView
   put the header_IsVisible of dView into sBoolean
   set the header_IsVisible of dView to (sBoolean is false)
end menu_ShowHeader

on menu_ShowBody dView
   put the body_IsVisible of dView into sBoolean
   set the body_IsVisible  of dView to (sBoolean is false)
end menu_ShowBody

on menu_ShowFooter dView
   put the footer_IsVisible of dView into sBoolean
   set the footer_IsVisible of dView to (sBoolean is false)
end menu_ShowFooter

private on __
end __

on submenu_Dev
   return "Global | Data | Show | Menu"
end submenu_Dev
