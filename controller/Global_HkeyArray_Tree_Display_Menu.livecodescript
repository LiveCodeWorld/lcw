script "Global_HkeyArray_Tree_Display_Menu"
--> MetaData
-
license: GPLv3
name: Global_HkeyArray_Tree_Display_Menu
type: controller
version: 0.1

/*
This menu is for checking, comparing and filtering hKeyArrays
*/

--> Variables
-
local LocalArray


--> Global | HkeyArray | Tree | Display | Menu
-
on menu_EditMenuCard treeView, mCard
   put the menu_SubStack of stack "libOPN_HkeyArray" into subStackObject
   put "card" && kwote(mCard) && "of" && subStackObject into cardObject
   set the visible of subStackObject to true
   if exists(cardObject) then
      if the shiftkey is "Down" then go to cardObject
      edit the script of cardObject
   end if
end menu_EditMenuCard

on menu_DisplayStyle treeView, displayStyle
   set the display_Style [treeView] of me to displayStyle
end menu_DisplayStyle

on _
end _

on menu_DisplayDependencies treeView
   put the displayed_Array of treeView into hKeyArray
   put the displayed_Object of treeView into scriptObject
   
   put array_AllNodes (hkeyArray) into allCalls
   put the rugged_ID of scriptObject into scriptObject
   filter allCalls without ("*," & scriptObject & ",*")
   sort allCalls by item 1 of each
   
   put the mobile_Name of scriptObject into prettyObject
   put merge ("Deps for [[prettyObject]]") into someTitle
   set the tree_Display [someTitle] of treeView to allCalls
end menu_DisplayDependencies

on menu_ConstructMainStackSuiteArray treeView
   put the displayed_Object of treeView into mainStackObject
   put the mainstack_Harray of mainStackObject into mainstackHarray
   
   put hArray_ConstructHkeySuiteArray (mainstackHarray) into scriptObjectSuiteArray
   _DisplayArray treeView, scriptObjectSuiteArray, "hArray_ConstructHkeySuiteArray()", 1
end menu_ConstructMainStackSuiteArray


--> HkeyArray | Tree | Display | Menu | Props
-
getprop m_Cards [treeView]
   if exists (stack "libOPN_HkeyArray") is false then return empty
   return the menu_CardMenu of stack "libOPN_HkeyArray"
end m_Cards

getprop display_Style [treeView]
   lock messages
   put the display_Style of treeView into someStyle
   unlock messages
   return someStyle
end display_Style

setprop display_Style [treeView] someStyle
   put the displayed_Array of treeView into hKeyArray
   
   switch someStyle
      case "hkeyArray"
         put keys (hKeyArray) into someKeys
         sort someKeys by item 1 of each
         repeat for each line someKey in someKeys
            put someKey & CR after someOutline
            get hKeyArray [someKey]
            if it is not empty then
               put outline_IncreaseIndent (it) & CR after someOutline
            end if
         end repeat
         delete last char of someOutline
         set the tree_Outline [1] of treeView to someOutline
         break
      case "index"
         -- set the title_Text of treeView to hKey
         put array_AllNodes (hkeyArray) into allCalls
         sort allCalls by item 1 of each
         set the tree_Outline of treeView to allCalls
         break
      default -- case "object outline"
         put the title_Text of treeView into someTitle
         display_ObjectOutline hkeyArray, someTitle, treeView
   end switch
   
   lock messages
   set the display_Style of treeView to someStyle
   unlock messages
end display_Style

getprop display_Styles [treeView]
   return "object outline,-,hkeyArray,index"
end display_Styles


--> Deps
-
command display_ObjectOutline hkeyArray, someTitle, treeView
   put hkeyArray_ConstructObjectArray (hkeyArray) into objectArray
   
   lock screen
   set the tree_Array [1] of the tree_Field of treeView to objectArray
   set the title_Text of treeView to someTitle
   unlock screen
end display_ObjectOutline

private command _DisplayArray treeView, someArray, displayHow, pExpandNum
   set the cursor to watch
   lock screen
   set the tree_Array [pExpandNum] of treeView to someArray
   set the title_Text of treeView to displayHow
   unlock screen
end _DisplayArray
