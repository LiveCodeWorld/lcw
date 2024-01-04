script "Global | Array | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Array | Line | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target


--> Global | Array | Line | Menu
-
on menu_SelectedLine displayView
   put the selected_Line of displayView
end menu_SelectedLine

on menu_SelectedValue displayView
   put the selected_Value of displayView
end menu_SelectedValue

private on _
end _

on menu_Fetch displayView
   put the top_Line of displayView into someRoute
   put "http://localhost" & someRoute into someURL
   put someURL 
end menu_Fetch

on submenu_Dev
   return menu_DevTitle ("Global | Array | Line | Menu")
end submenu_Dev
