script "Global_ScriptEditor_Script_Default_Menu"
`--> MetaData
-
license: GPLv3
name: Global_ScriptEditor_Script_Default_Menu
type: controller
version: 0.2

local LocalArray


--> Menu  | Props
-
on menu_Init
   put the selectedtext of the clickfield into LocalArray ["selectedtext"]
end menu_Init



--> Global | ScriptEditor | Script | Default | Menu
-
on menu_ScriptDefaultMenu mTarget
   put mTarget
end menu_ScriptDefaultMenu

on menu_SpotlightHandler
   -- put LocalArray ["clicktext"]
   put the clicktext into hName
   put spotlight_FindExportedHandler (hName)
end menu_SpotlightHandler

on _
end _

on menu_EditMenu mTarget, mTitle
   ide_EditMenu "Script"
end menu_EditMenu

on menu_SetMenu mTarget, mTitle
   ide_SetMenuTitle "Script", mTitle
end menu_SetMenu


--> Global | ScriptEditor | Script | Default | Menu | Props
-
getprop m_Title
   return ide_ShortTitle ("Script")
end m_Title

getprop m_Titles
   put ide_ListShortMenuTitles ("Script") into shortNames
   return shortNames
end m_Titles


--> Global | ScriptEditor | Script | Authoring | Menu
-
on menu_AuthoringMenu mTarget
   put mTarget
end menu_AuthoringMenu

on _
end _

on insert_ScriptFieldMenu
   put "Global | Script | Editor | Menu" into mTitle
   return mTitle
end insert_ScriptFieldMenu

on _
end _

on menu_SetMenu mTarget, mTitle
   ide_SetMenuTitle "Script", mTitle
end menu_SetMenu

