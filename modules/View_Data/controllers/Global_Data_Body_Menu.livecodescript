script "Global | Data | Body | Menu"
--> MetaData
-
license: GPLv3
name: Global | Data | Body | Menu
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


--> Global | Data | Body | Menu
-
on menu_DataBody dView
   put the params
end menu_DataBody

private on _
end _

on menu_Type dView, sType
   set the body_Type of dView to sType
end menu_Type

getprop type_Param [dView]
   return the body_Type of dView
end type_Param

getprop type_Params [dView]
   return the body_Types of dView
end type_Params

private on __
end __

on submenu_Dev
   return "Global | Data | Body | Menu"
end submenu_Dev
