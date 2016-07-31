script "Global_View_Authoring_Menu"
--> MetaData
-
license: GPLv3
name: Global_View_Authoring_Menu
type: controller
version: 0.1


--> Global | View | Authoring | Menu
-
on menu_DisplayViewTemplate scriptObject
   put the view_Template of scriptObject
end menu_DisplayViewTemplate

on _
end _

on insert_Menu
   return "Global | View | Wireframe | Menu"
end insert_Menu


