script "Global | Data | Footer | Menu"
--> MetaData
-
license: GPLv3
name: Global | Data | Footer | Menu
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
   -- put the data_View of tObject into dView
   put the footer_View of tObject into footerView
   --
   return footerView
end menu_Target

getprop menu_CheckTarget [footerView]
   return exists (footerView)
end menu_CheckTarget

getprop itemStyle_Param [footerView]
   put the itemStyle of footerView into sStyle
   return sStyle
end itemStyle_Param

getprop itemStyle_Params
   return the menu_CaseConditions ["menu_ItemStyle"] of me
end itemStyle_Params

private function _MenuController pTitle
   if pTitle is empty then
      put "Global | Data | Line | Menu" into mTitle
   end if
   put the name of stack mTitle into mController
   return mController
end _MenuController

private function _MenuItemArray mTitle
   put _MenuController (mTitle) into mController
   put the menu_ItemArray of mController into itemArray
   return itemArray
end _MenuItemArray

getprop deleteItem_Params [footerView]
   return the footer_ItemLabels of footerView
end deleteItem_Params

getprop icon_Param [footerView]
   put the hilitedItem of footerView into iNum
   --
   get the footer_ItemIcon [iNum] of footerView
   set the itemdelimiter to slash
   return item -1 of it
end icon_Param

getprop icon_Params [footerView]
   -- this may not be the right family for the icon
   put the hilitedItem of footerView into iNum
   --
   get the footer_ItemIcon [iNum] of footerView
   set the itemdelimiter to slash
   if the number of items of it = 1 then
      put empty into sFamily
   else
      put item 1 of it into sFamily
   end if
   
   put iconFamilies() into fNames
   
   switch
      case sFamily is empty
      case the number of items of it = 1 or the shiftKey is "Down"
         return iconNames()
      case sFamily is not among the lines of fNames
         return "Import Library" && sFamily
         break
      default
         return iconNamesForFamily (sFamily)
   end switch
end icon_Params

getprop handler_Param [footerView]
   put the hilitedItem of footerView into iNum
   --
   put the footer_ItemName [iNum] of footerView into iName
   return iName
end handler_Param

getprop handler_Params
   -- return se_HandlerLabels()
   put se_HandlerIndexArray() into hIndexArray
   put hIndexArray into LocalArray ["hIndexArray"]
   put indexArray_List (hIndexArray, "label") into hLabels
   sort hLabels
   if hLabels is not empty then
      put CR & "-,Clear Hkey" after hLabels
   end if
   return hLabels
end handler_Params

getprop footerTitle_Params
   -- return "Global | GIT | Stage | Menu,Global | GIT | Line | File | Menu"
   put the shiftKey is "Down" into sBoolean
   put se_ListTabMenus (sBoolean) into mTitles
   return mTitles
end footerTitle_Params


--> Global | Data | Footer | Menu
-
on menu_DisplayIconDialogue footerView
   display_IconDialogue footerView
end menu_DisplayIconDialogue

on menu_FooterTitle footerView, mTitle
   if the shiftKey is "Down" then
      menu_Edit mTitle
   else
      set the footer_Title of footerView to mTitle
   end if
end menu_FooterTitle

on menu_ConstructGetProp footerView
   put the footer_GetProp of footerView into sHandler
   --
   display_Script sHandler, "menu_IconArray"
end menu_ConstructGetProp

on submenu_Library
   return "Global | Svg | Library | Menu"
end submenu_Library

private on ___
end ___

on menu_ItemStyle footerView, sStyle
   put toLower (sStyle) into lowStyle
   switch lowStyle
      case "Icons"
         set the itemStyle of footerView to lowStyle
         break
      case "Text"
         set the itemStyle of footerView to lowStyle
         break
      case "-"
      case "Both"
         set the itemStyle of footerView to lowStyle
   end switch
end menu_ItemStyle

on menu_Icon footerView, sIconName
   put the hilitedItem of footerView into iNum
   --
   if word 1 to 2 of sIconName = "Import Library" then
      put word 3 of sIconName into fName
      lcw_Answer "Import missing icon library '[[fName]]'?", footerView, fName
      
      menu_Do "menu_ImportIconFolder", "Global | Svg | IconLibrary | Menu", footerView
      exit to top
   end if
   
   put getCurrentIconFamily() into fName
   put fName & slash before sIconName
   set the footer_ItemIcon [iNum] of footerView to sIconName
   if the shiftKey is "down" then
      set the footer_ItemName [iNum] of footerView to sIconName
   end if
end menu_Icon

on menu_DeleteItem footerView, iLabel
   put the footer_ItemArray of footerView into sArray
   --
   put indexArray_Find (sArray, "label", iLabel) into iNum
   indexArray_Delete sArray, iNum
   --
   set the footer_ItemArray of footerView to sArray
end menu_DeleteItem

private on __
end __

on menu_ItemLabel footerView
   put the hilitedItem of footerView into iNum
   --
   put the footer_ItemLabel [iNum] of footerView into sLabel
   put lcw_Ask ("Choose a label for this item...", sLabel, footerView) into sLabel
   set the footer_ItemLabel [iNum] of footerView to sLabel
end menu_ItemLabel

on menu_ItemName footerView
   put the hilitedItem of footerView into iNum
   --
   put the footer_ItemName [iNum] of footerView into sName
   put lcw_Ask ("Choose a name for this item...", sName, footerView) into sName
   set the footer_ItemName [iNum] of footerView to sName
end menu_ItemName

on menu_Handler footerView, hkeyLine
   put the hilitedItem of footerView into iNum
   --
   if hLine = "Clear Hkey" then
      put empty into hKey
      put empty into iName
   else
      put LocalArray ["hIndexArray"] into hIndexArray
      put indexArray_FindArray (hIndexArray, "label", hkeyLine) into iName
      put itemArray ["hkey"] into hKey
   end if
   --
   set the footer_ItemHkey [iNum] of footerView to hKey
   set the footer_ItemBane [iNum] of footerView to iName
end menu_Handler

private on _
end _

on menu_DisplayIconFamilies
   -- display_IconLibrary
   display_IconFamilies
end menu_DisplayIconFamilies

on menu_DisplayItemArray footerView
   put the footer_ItemArray of footerView into iArray
   put the stack_Name of footerView into sName
   --
   put empty into iArray [4]["icon"]
   set the footer_ItemArray of footerView to iArray
   --
   display_Data iArray, sName, "the footer_ItemArray"
end menu_DisplayItemArray

on menu_DisplayMenuItemArray footerView
   put the menu_ItemArray of footerView into iArray
   put the stack_Name of footerView into sName
   display_Data iArray, sName, "the menu_ItemArray"
end menu_DisplayMenuItemArray

on menu_FooterHeight footerView
   put the footer_height of footerView into sHeight
   put lcw_Ask ("Set the footer height...", sHeight, footerView) into sHeight
   set the footer_height of footerView to sHeight
end menu_FooterHeight

on submenu_Dev
   return "Global | Data | Footer | Dev | Menu"
end submenu_Dev
