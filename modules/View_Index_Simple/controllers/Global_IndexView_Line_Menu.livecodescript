script "Global_IndexView_Line_Menu"
--> MetaData
-
license: GPLv3
name: Global_IndexView_Line_Menu
type: controller
version: 0.2

--> Variables
-
local Localarray


--> Global | IndexView | Line | Menu
-
on menu_BurnLocalMenu mTarget
   put LocalArray ["indexView"] into indexView
   set the line_Menu of indexView to "List | Menu"
end menu_BurnLocalMenu

on menu_SetLineMenu mTarget
   put lcw_Ask ("Enter a title for this line_Menu...", "Global | Display | MenuIndex | Line | Menu") into lineMenuTitle
   put LocalArray ["indexView"] into indexView
   set the line_Menu of indexView to lineMenuTitle
end menu_SetLineMenu

on menu_CreateLineMenu mTarget
   put LocalArray ["indexView"] into indexView
   breakpoint
   
   put the index_Field of me into fieldObject
   put the selectedtext of fieldObject & CR & CR & LocalArray ["viewIndex"]
end menu_CreateLineMenu

on _
end _

on menu_EditMenu
   edit the script of me
end menu_EditMenu

on menu_IndexViewBehavior mTarget
   put LocalArray ["indexView"] into indexView
   
   put the behavior of indexView into bObject
   edit the script of bObject
end menu_IndexViewBehavior


--> Global | IndexView | Line | Menu | Props
-

--> Global | IndexView | Line | Menu | Disabled
-

--> Menu | Props
-
on menu_Init tObject
   put the index_View of tObject into indexView
   put indexView into LocalArray ["indexView"]
end menu_Init
