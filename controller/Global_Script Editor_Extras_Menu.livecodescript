script "Global_Script Editor_Extras_Menu"
--> MetaData
-
license: GPLv3
name: Global_Script Editor_Extras_Menu
type: controller
version: 0.1


--> Global | Script Editor | Extras | Menu
-
on menu_FindHandlerInHierarchy
   -- this looks for a handler not a string
   -- put rev_ScriptEditorField() into fieldObject
   -- put hkey_GetSelected (fieldObject) into hKey
   put LocalArray ["selectedHkey"] into hKey
   
   hkey_Edit hKey
end menu_FindHandlerInHierarchy

on menu_SearchkeyWords
   put rev_ScriptEditorField() into fieldObject
   put hkey_GetSelected (fieldObject) into hKey
   put hkey_SearchDatabase (hKey, true) into intersectArray
   
   hkey_ConstructAndArray intersectArray
   display_ScriptKeywordLinks intersectArray
end menu_SearchkeyWords

on submenu_Menu
   return "Global | Menu | Table | Menu"
end submenu_Menu

on _
end _

on submenu_ScriptArray
   return "Global | Script | Array | Menu"
end submenu_ScriptArray

on submenu_Dependencies
   return "Global | Script | Dependency | Menu"
end submenu_Dependencies

on _
end _

on submenu_Search
   return "Global | Search | Scripts | Menu"
end submenu_Search

on submenu_View
   return "Global | View | Update | Menu"
end submenu_View

on submenu_Card
   return "Global | Card | Menu"
end submenu_Card

on menu_EditScriptEditorMenu
    menu_Edit "Global | Script | Editor | Menu"
end menu_EditScriptEditorMenu
