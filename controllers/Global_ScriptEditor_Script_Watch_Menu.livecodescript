﻿script "Global | ScriptEditor | Script | Watch | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | ScriptEditor | Script | Watch | Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray

--> Global | ScriptEditor | Script | Watch | Menu
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
