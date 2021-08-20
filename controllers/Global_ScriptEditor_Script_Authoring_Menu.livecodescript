script "Global | ScriptEditor | Script | Authoring | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | ScriptEditor | Script | Authoring | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

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
