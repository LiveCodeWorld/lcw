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
getprop menu_IconArray [sView]
   put the menu_ItemArray of me into iconArray
   --
   put the poly_View of sView into polyview
   if the poly_Content of polyview is empty then
      iconArray_Delete iconArray, "Polylist"
   end if
   
   if the browser_View of sView is empty then
      iconArray_Delete iconArray, "Browser"
   end if
   
   if the panel_View of sView is empty then
      iconArray_Delete iconArray, "Panel"
   end if
   return iconArray
end menu_IconArray

command iconArray_Delete @iconArray, hLine
   put indexArray_Find (iconArray, "name", hLine) into iNum
   indexArray_Delete iconArray, iNum
end iconArray_Delete

getprop menu_Target [tObject]
   put the data_View of tObject into dView
   return dView
end menu_Target

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget

getprop type_Param [dView]
   return the body_Type of dView
end type_Param

getprop type_Params [dView]
   return the body_Types of dView
end type_Params

getprop disabled_Body [dView]
   put the body_View of dView into bodyView
   if exists (bodyView) is false then return true
   
   put the menu_Title of bodyView into mTitle
   return mTitle is empty
end disabled_Body

getprop disabled_PanelMargin [dView]
   put the panel_View of dView into panelView
   return exists (panelView) is false
end disabled_PanelMargin


--> Global | Data | Body | Menu
-
on menu_Type dView, sType
   set the body_Type of dView to sType
end menu_Type

on submenu_BodyView dView
   put the body_View of dView into bodyView
   put the menu_Title of bodyView into mTitle
   return mTitle
end submenu_BodyView

private on _
end _

on menu_Tree sView
   set the body_Type of sView to "Tree"
end menu_Tree

on menu_Index sView
   set the body_Type of sView to "Index"
end menu_Index

on menu_Polylist sView
   set the body_Type of sView to "Polylist"
end menu_Polylist

on menu_Browser sView
   set the body_Type of sView to "Browser"
end menu_Browser

on menu_Panel sView
   set the body_Type of sView to "Panel"
end menu_Panel

private on __
end __

on menu_Margin mTarget
   put the panel_View of mTarget into panelView
   --
   put the panel_Margin of panelView into sMargin
   put lcw_Ask ("Set the panel_Margin?", sMargin, dView) into sMargin
   set the panel_Margin of panelView to sMargin
end menu_Margin

on menu_Refresh sView
   put the footer_View of sView into footerView
   dispatch "refresh" to footerView
   --
   set the title_Text of sView to "Module Tools"
end menu_Refresh

on submenu_Dev
   return "Global | Data | Body | Dev | Menu"
end submenu_Dev
