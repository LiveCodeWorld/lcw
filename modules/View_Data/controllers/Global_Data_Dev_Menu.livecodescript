script "Global | Data | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Data | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this developer menu.
Full help text should be provided on the linked wiki.

Consider improving by creating with same menu_Target as no-developer menu is is based on.
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

getprop menu_CheckTarget [mTarget]
   return exists (mTarget)
end menu_CheckTarget


--> Global | Data | Dev | Menu
-
on menu_PreopenStack dView
   dispatch "preOpenStack" to dView
end menu_PreopenStack

on menu_IdeTools dView
   -- display_ModuleTools "View|Data"
end menu_IdeTools

on menu_ModuleTools dView
   display_ModuleTools "View|Data"
end menu_ModuleTools
