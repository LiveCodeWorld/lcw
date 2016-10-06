script "Global_Index_Simple_Menu"
--> MetaData
-
license: GPLv3
name: Global | Index | Simple | Menu
type: controller
version: 0.2


--> Menu | Props
-
local LocalArray

on menu_Init
   -- mTarget is set to the displayed_Object of indexView by the indexView
   -- if the displayed_Object is not set it falls back to the indexView itself
   -- here we re-fetch the orginal indexView in orde to guarantee that we operate on the indexView and not the displayed_Object of indexView
   put menu_GetTargetObject() into tObject
   put the index_View of tObject into indexView
   put indexView into LocalArray ["indexView"]
end menu_Init


--> Global | Index | Simple | Menu
-
on menu_PaletteStyle displayedObject, someBoolean
   put LocalArray ["indexView"] into indexView
   put the stack_Name of indexView into stackName
   if someBoolean is false then
      set the style of stack stackName to "toplevel"
   else
      set the style of stack stackName to "palette"
   end if
end menu_PaletteStyle

on menu_SystemWindow displayedObject, someBoolean
   put LocalArray ["indexView"] into indexView
   put the stack_Name of indexView into stackName
   set the systemwindow of stack stackName to someBoolean
end menu_SystemWindow

on _
end _

on menu_FieldStyle displayedObject, fStyle
   put LocalArray ["indexView"] into indexView
   set the field_Style of indexView to fStyle
end menu_FieldStyle

on menu_DontWrap displayedObject, someBoolean
   put LocalArray ["indexView"] into indexView
   set the dont_Wrap of indexView to someBoolean
end menu_DontWrap

on menu_InspectField
   put LocalArray ["indexView"] into indexView
   put the index_Field of indexView into indexField
   object_Inspect indexField
end menu_InspectField

on _
end _

on menu_SetMyName
   put LocalArray ["indexView"] into indexView
   
   put the group_Name of indexView into oldName
   put lcw_Ask ("Give this group and title a name...", oldName) into someName
   
   put the title_Colour of indexView into tColour
   if tColour is empty then put "random" into tColour
   set the group_Name [tColour] of indexView to someName
end menu_SetMyName

on menu_SetMenuTitle
   put LocalArray ["indexView"] into indexView
   
   -- put the displayed_Object of indexView into someView
   put the view_MenuTitle [true] of indexView -- into viewMenuTitle
   put the title_Menu of indexView into mTitleTable
   put lcw_Ask ("Set the menu_Title of this indexView to...", mTitleTable) into mTitleTable
   
   -- put viewMenuTitle & CR & "-" & CR & oTitle into mTitleTable
   set the title_Menu of indexView to mTitleTable
end menu_SetMenuTitle

on _
end _

on menu_SetTitleColour
   put LocalArray ["indexView"] into indexView
   
   answer color
   if it is empty then exit to top
   
   put it into someColour
   set the title_Colour of indexView to someColour
   put the result into titleColour
   
   put colour_GetDarkOrLight (titleColour) into titleTextColour
   set the title_TextColour of indexView to titleTextColour
   
   put colour_RgbToHSV (titleColour) into someHSV
   put titleTextColour & CR & CR & someHSV & CR & titleColour
end menu_SetTitleColour

on menu_SetTitleTextColour
   put LocalArray ["indexView"] into indexView
   
   answer color
   if it is empty then exit to top
   
   put it into someColour
   set the title_TextColour of indexView to someColour
end menu_SetTitleTextColour

on _
end _

on menu_BlackAndWhiteTitle
   put LocalArray ["indexView"] into indexView
   
   put the title_Colour of indexView into titleColour
   put colour_GetDarkOrLight (titleColour) into titleTextColour
   set the title_TextColour of indexView to titleTextColour
   
   put colour_RgbToHSV (titleColour) into someHSV
   put titleTextColour & CR & CR & someHSV & CR & titleColour
end menu_BlackAndWhiteTitle

on menu_ReverseTitleColour
   put LocalArray ["indexView"] into indexView
   
   put the title_Colour of indexView into titleColour
   put colour_GetReverse (titleColour) into titleTextColour
   set the title_TextColour of indexView to titleTextColour
   
   put colour_RgbToHSV (titleColour) into someHSV
   put titleTextColour & CR & CR & someHSV & CR & titleColour
end menu_ReverseTitleColour

on _
end _

on menu_EditTitleMenus displayedObject
   put LocalArray ["indexView"] into indexView
   put the title_Menu of indexView into mTitles
   set the itemdelimiter to tab
   repeat for each line titleLine in mTitles
      if titleLine = "-" then next repeat
      put item 1 of titleLine into mTitle
      menu_Edit mTitle
   end repeat
end menu_EditTitleMenus

on menu_EditLineMenu displayedObject
   put LocalArray ["indexView"] into indexView
   put the line_Menu of indexView into mTitle
   menu_Edit mTitle
end menu_EditLineMenu

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Index | Simple | Menu | Props
-
getprop palette_Style [displayedObject]
   put LocalArray ["indexView"] into indexView
   put the stack_Name of indexView into stackName
   put the style of stack stackName is "palette" into isPalette
   return isPalette
end palette_Style

getprop system_Window [displayedObject]
   put LocalArray ["indexView"] into indexView
   put the stack_Name of indexView into stackName
   put the systemwindow of stack stackName into someBoolean
   return someBoolean
end system_Window

getprop dont_Wrap [displayedObject]
   put LocalArray ["indexView"] into indexView
   put the dont_Wrap of indexView into someBoolean
   return someBoolean
end dont_Wrap

getprop f_Style [displayedObject]
   put LocalArray ["indexView"] into indexView
   put the field_Style of indexView into fStyle
   return fStyle
end f_Style

getprop f_Styles [displayedObject]
   put LocalArray ["indexView"] into indexView
   put the field_Styles of indexView into fStyles
   return fStyles
end f_Styles


--> Global | Index | Simple | Menu | Disabled
-


--> Dev | Menu
-
on menu_EditBehavior
   put LocalArray ["indexView"] into indexView
   
   put the behavior of indexView into bObject
   edit the script of bObject
end menu_EditBehavior

on menu_SetStandardBehavior
   put LocalArray ["indexView"] into indexView
   
   put the view_BehaviorStackName of indexView into stackName
   put the name of stack stackName into bObject
   set the behavior of indexView to bObject
end menu_SetStandardBehavior

on _
end _

on menu_ShowIndexTemplate
   put LocalArray ["indexView"] into indexView
   
   put the view_Name of indexView into viewName
   put view_GetTemplateObject (viewName) into templateObject
   object_GoTo templateObject
end menu_ShowIndexTemplate

on menu_EditThisMenu
   menu_Edit "Global | Index | Simple | Menu"
end menu_EditThisMenu

on _
end _

on menu_TestMenuTarget displayedObject
   put LocalArray ["indexView"] into indexView
   
   put the view_Name of mTarget & CR & the name of mTarget & CR & indexView
end menu_TestMenuTarget
