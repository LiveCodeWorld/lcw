script "Global | Data | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Data | Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray


--> Menu | Props
-
getprop menu_Target [tObject]
   put the data_View of tObject into dataView
   if exists (dataView) is false then return empty
   return dataView
end menu_Target

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget

private function _dView
   return LocalArray ["dView"]
end _dView

getprop lineMenu_Param [dView]
   -- put the uOPN ["line_Menu"] of dView into lineMenu
   put the line_Menu of dView into lineMenu
   put the default_LineMenuTitle of dView into dTitle
   return _ReturnTitle (lineMenu, dTitle)
end lineMenu_Param

getprop lineMenu_Params
   return the menu_CaseConditions ["menu_LineMenu"] of me
end lineMenu_Params

getprop titleMenu_Param [dView]
   put the uOPN ["title_Menu"] of dView into titleMenu
   -- put the title_Menu of dView into titleMenu
   put the default_MenuTitle of dView into dTitle
   return _ReturnTitle (titleMenu, dTitle)
end titleMenu_Param

getprop titleMenu_Params
   return the menu_CaseConditions ["menu_TitleMenu"] of me
end titleMenu_Params

private function _ReturnTitle mTitle, dTitle
   switch
      case mTitle is empty
         return "Empty"
      case mTitle is  "View"
      case mTitle is  "Card"
      case mTitle is  "Stack"
         return mTitle
      case mTitle = dTitle
         return "Default"
      default
         return "Global"
   end switch
end _ReturnTitle

getprop dragCommand_Param [dView]
   get the drop_Command of dView
   if it is empty then return "Empty"
   return it
end dragCommand_Param

getprop dragCommand_Params
   return "Empty,display_TargetData,-,Ask"
end dragCommand_Params

command _CreateTitleMenu dView
   breakpoint
   put the title_Menu of dView into mTitle
   put the project_Name of dView into projectName
   if projectName is empty then put "lcw_Tools" into projectName
   --
   put lcw_Ask ("Where would you like to create the menu [[var]]?", projectName, dView, mTitle) into projectName
   --
   ask_CreateProjectMenu projectName, mTitle
   put the result into mController
   
   # Edit the script
   if pDisplay is true then
      edit the script of mController
   end if
   return mTitle
end _CreateTitleMenu


--> Global | Data | Menu
-
on submenu_Demo
   return "Global | Data | Demo | Menu"
end submenu_Demo

private on _
end _

on submenu_Stack
   return "Global | Data | Stack | Menu"
end submenu_Stack

on submenu_Show
   return "Global | Data | Show | Menu"
end submenu_Show

on submenu_Body
   return "Global | Data | Body | Menu"
end submenu_Body

on submenu_Footer
   return "Global | Data | Footer | Menu"
end submenu_Footer

private on __
end __

on submenu_Index
   return "Global | Data | Index | Menu"
end submenu_Index

on submenu_Tree
   return "Global | Data | Tree | Menu"
end submenu_Tree

on submenu_Poly
   return "Global | Poly | Menu"
end submenu_Poly

private on ___
end ___

on menu_TitleMenu dView, whichMenu
   switch whichMenu
      case "Empty"
         put empty into titleMenu
         break
      case "-"
      case "View"
      case "Card"
      case "Stack"
         put whichMenu into titleMenu
         break
      case "-"
      case "Default"
         put the default_MenuTitle of dView into titleMenu
         break
      case "Global"
         put the title_Menu of dView into titleMenu
         put lcw_Ask ("Set the title_Menu...", titleMenu, dView) into titleMenu
         break
      case "Create"
         breakpoint
         _CreateTitleMenu
         put the result into titleMenu
         break
   end switch
   --
   set the title_Menu of dView to titleMenu
end menu_TitleMenu

on menu_LineMenu dView, whichMenu 
   switch whichMenu
      case "Empty"
         put empty into mTitle
         break
      case "-"
      case "View"
      case "Card"
      case "Stack"
         put whichMenu into mTitle
         break
      case "-"
      case "Default"
         put _DefaultLineTitle (dView) into mTitle
         breakpoint
         break
      case "Global"
         put the line_Menu of dView into mTitle
         put lcw_Ask ("What line-menu do you want to attach to the tree_Field?", mTitle) into mTitle
         break
      case "Create"
         breakpoint
         _CreateTitleMenu
         put the result into mTitle
         break
   end switch
   --
   set the line_Menu of dView to mTitle
end menu_LineMenu

private on ____
end ____

on submenu_Create
   return "Global | Data | Create | Menu"
end submenu_Create

on menu_ClearData dView
   set the index_Data of dView to empty
   set the tree_Data of dView to empty
   set the poly_Data of dView to empty
end menu_ClearData

on submenu_Dev
   return menu_DevTitle ("Global | Data | Menu")
end submenu_Dev
