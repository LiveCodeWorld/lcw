script "Global | ScriptEditor | Set | Menu"
--> MetaData
-
license: GPLv3
name: Global | ScriptEditor | Set | Menu
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
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop menu_CheckTarget [cameraView]
   return exists (cameraView)
end menu_CheckTarget


--> Global | ScriptEditor | Set | Menu
-
on menu_SetDynadotToken
   dynadot_SetApiKey
   put dynadot_GetApiKeyI()
end menu_SetDynadotToken

on menu_SetAndLoadApiTokens
   github_SetAccessToken
   dynadot_SetApiKey
   ocean_SetApiKey
   put the result
end menu_SetAndLoadApiTokens
