script "Global_Menu_Table_Menu"
--> MetaData
-
license: GPLv3
name: Global_Menu_Table_Menu
type: controller
version: 0.1


--> Global | Menu | Table | Menu
-
/*
Seems to be a problem with an error: of mController: card "Menu Table Menus" of stack "libOPN_Menus"
*/

on submenu_GlobalMenu
   return "Global | Menu | Global Cards | Menu"
end submenu_GlobalMenu

on menu_ListGlobalMenus
   put menu_ListGlobalNames() into globalMenuTitles
   put empty into pLineMenuTitle
   display_Outline globalMenuTitles, "Global Menus", "Global | Menu | Tree | Menu", pLineMenuTitle
   put the result into treeView
   put the tree_Field of treeView into treeField
   put the object_Hkey ["editTreeMenu,c"] of me into hKey
   set the event_Trigger ["mouseDoubleUp"] of treeField to hKey
end menu_ListGlobalMenus

command editTreeMenu treeField
   put the selected_Index of treeField into globalMenuTitle
   menu_Edit globalMenuTitle
end editTreeMenu

on menu_DisplayMenuPickHandler  scriptObject, cachedMenuTitle
   -- crude simplification for now
   local handlerBody
   put the menu_Target of scriptObject into mTarget
   if mTarget is empty then put the long id of the target into mTarget
   put the menu_Table [cachedMenuTitle] of scriptObject into mTable
   
   put "put the long id of" && mTarget && "into mTarget" & CR after handlerBody
   put "someChoice" into hParam
   put "switch" && hParam & CR after handlerBody
   set the itemdelimiter to tab
   repeat for each line mTableLine in mTable
      menu_DeconstructTableLine mTableLine, mController, pigeon, mTitle, mLine, mFormatProp, mItemType, submenuProp, paramProp, mSendLine
      
      put "  case" && kwote (mLine) & CR after handlerBody
      put "    " & pigeon & CR after handlerBody
      put "    break" & CR after handlerBody
   end repeat
   put "end switch" & CR after handlerBody
   
   put script_ConstructCommandHandler ("menuPick", handlerBody, hParam) into someHandler
   display_Lines someHandler
end menu_DisplayMenuPickHandler

on _
end _

on submenu_LocalMenus
   return "Global | Menu | Substack | Menu"
end submenu_LocalMenus

on _
end _

on menu_CutMenu mTarget, scriptMenuTitle
   get "Are you sure you want to cut the menu suites from this script? The suites will be places onto the clipboard, and you can undo the action using the undo button of the Script Editor?"
   opn_Answer it
   
   put rev_ScriptObject() into mController
   put the script of mController into someScript
   
   menu_DeleteTitleSuites scriptMenuTitle, someScript
   put the result into menuScriptSuites
   set the clipboarddata to menuScriptSuites
   
   rev_SetScriptEditorField someScript
   opn_Notify "Copied menu script suites for" && kwote (scriptMenuTitle) && "to clipboard!", true
   return menuScriptSuites
end menu_CutMenu

on _
end _

on submenu_Development
   return "Dev | Menu"
end submenu_Development


--> Global | Menu | Table | Menu | Props
-
getprop show_MenuStack
   put rev_ScriptObject() into mController
   put the menu_SubStack of mController into subStackObject
   if exists(subStackObject) then
      return the visible of subStackObject 
   else
      return empty
   end if
end show_MenuStack

getprop script_MenuTitles
   return LocalArray ["menu_ScriptTitles"] & CR & "-,All"
end script_MenuTitles

getprop cached_MenuTitles
    return LocalArray ["menu_TableTitles"]
end cached_MenuTitles


--> Global | Menu | Table | Menu | Disabled
-

--> Dev | Menu
-
on menu_MenuTableArray mTarget, cachedMenuTitle
   put rev_ScriptObject() into mController
   put the menu_TableArray [cachedMenuTitle] of mController into mTableArray
   display_Array mTableArray, cachedMenuTitle
   put the result into treeView
   set the menu_Controller of treeView to the long id of me
   
   edit the script of treeView
   edit the script of the behavior of treeView
end menu_MenuTableArray

on menu_CachedMenuTable mTarget, cachedMenuTitle
   put rev_ScriptObject() into mController
   put the menu_Table [cachedMenuTitle] of mController into mTable
   
   put script_ConstructSuiteHeader (cachedMenuTitle) into menuHeader
   script_Edit mController, menuHeader, true
   
   display_MenuTable mTable, mController, cachedMenuTitle
end menu_CachedMenuTable

on menu_CachedMenuArray mController, cachedMenuTitle
   put rev_ScriptObject() into mController
   put the menu_TableArray [cachedMenuTitle] of mController into mTableArray
   display_Array mTableArray
end menu_CachedMenuArray

on menu_LiveMenuTable mTarget, scriptMenuTitle
   put rev_ScriptObject() into mController
   
   put script_ConstructSuiteHeader(scriptMenuTitle) into menuHeader
   script_Edit mController, menuHeader, true
   
   put the menu_TableFromScript [scriptMenuTitle] of mController into mTable
   display_MenuTable mTable, mController, scriptMenuTitle
end menu_LiveMenuTable

on _
end _

on menu_ClearCachedMenuTable scriptObject, cachedMenuTitle
    put rev_ScriptObject() into scriptObject
    set the menu_Table [cachedMenuTitle] of scriptObject to empty
end menu_ClearCachedMenuTable

on menu_ClearEntireCache
    put rev_ScriptObject() into scriptObject
    menu_DeleteTables scriptObject
end menu_ClearEntireCache

on _
end _

on menu_BurnMenu mTarget
   put rev_ScriptObject() into mController
   put the mobile_Name of mController into mController
   
   put the mobile_Name of mTarget into mTarget
   put the menu_Button of mTarget
end menu_BurnMenu

on _
end _

on menu_MenuControllerCustomProperty
   put rev_ScriptObject() into scriptObject
   -- put the mobile_Name of scriptObject into scriptObject
   put the menu_Controller of scriptObject into menuModel
   object_EditProperty menuModel
end menu_MenuControllerCustomProperty

on _
end _

on menu_DisplayMenuText mTarget, scriptMenuTitle
   put rev_ScriptObject() into scriptObject
   put the menu_Text [scriptMenuTitle] of scriptObject into someOutline
   display_Outline someOutline
end menu_DisplayMenuText

on menu_DisplayMenuObjects
   put rev_ScriptObject() into mTarget
   display_MenuTitles pTargetObject
end menu_DisplayMenuObjects

on menu_Reindex mTarget, scriptMenuTitle
   put rev_ScriptObject() into mController
   
   if scriptMenuTitle is "All" then
      opn_Answer "Are you sure you want to update all stored menu tables?"
      script_UpdateMenuTables mController
   else
      menu_UpateMenuTable mTitle, mController
   end if
   put mTable
end menu_Reindex

on _
end _

on menu_DisplayMenuExtras
    go to stack "libOPN_MenuExtras"
end menu_DisplayMenuExtras

on menu_MenuOptionEdit someBoolean
    set the menu_OptionEdit of me to someBoolean
end menu_MenuOptionEdit


--> Deps
-
function menu_GetItemScript handlerName, mController, mFormatProp
   put script_ExtractMenuSuiteTitles (someScript) into scriptMenuTitles
   
   put hkey_Construct (handlerName, "c", mController) into hKey
   put the script_StandAlone [hKey] of mController into someScript
   -- put the script_Command [handlerName] of mController into someScript
   return someScript
end menu_GetItemScript


--> Tree | Menu
-
on menu_TestFirstRecord treeView
   put the displayed_Array of treeView into menuTableArray
   put menuTableArray [1] into recordArray
   display_FormArray recordArray
end menu_TestFirstRecord

command display_FormArray recordArray
   view_CloneHidden "Form|Simple", 12
   put the result into formView
   set the form_Array of formView to recordArray
   set textfont of formView to empty
   set textsize of formView to empty
   dispatch "LayoutControl" to formView
   set the stack_Visible of formView to true
end display_FormArray

private command display_MenuTable mTable, mController, mTitle
   put the mobile_Name of mController into mController
   put "the menu_Table  [" & kwote(mTitle) & "] of" && mController into someTitle
   
   put "mLine,pigeon,mController,mTitle,mFormatProp,mItemType,submenuProp,paramProp,mSendLine" into headerLine
   replace comma with tab in headerLine
   put headerLine & CR before mTable
   
   -- display_Lines mTable, someTitle
   display_Table mTable, someTitle, true, true
end display_MenuTable


--> Dev | Menu | Disabled
-
getprop disabled_CachedMenuTable
    return LocalArray ["menu_TableTitles"] is empty
end disabled_CachedMenuTable

getprop disabled_LiveMenuTable
    return LocalArray ["menu_ScriptTitles"] is empty
end disabled_LiveMenuTable

getprop disabled_DisplayMenuText
    return LocalArray ["menu_TableTitles"] is empty
end disabled_DisplayMenuText

getprop disabled_ClearCachedMenuTable
    return LocalArray ["menu_TableTitles"] is empty
end disabled_ClearCachedMenuTable

-- getprop disabled_ClearEntireCache
    return LocalArray ["menu_TableTitles"] is empty
end disabled_ClearEntireCache


--> Menu | Props
-
local LocalArray

getprop menu_CheckTarget [mTarget]
   -- lets load cache here
   put rev_ScriptObject() into scriptObject
   if exists(scriptObject) is false then return false
   
   put the menu_TableTitles of scriptObject into LocalArray ["menu_TableTitles"]
   put the menu_ScriptTitles of scriptObject into LocalArray ["menu_ScriptTitles"]
   return true -- mTarget = scriptObject
end menu_CheckTarget
