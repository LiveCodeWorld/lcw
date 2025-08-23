script "Global | Data | Demo | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Data | Demo | Dev | Menu
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


--> Global | Data | Demo | Dev | Menu
-
on menu_LoadMenus dView
   put the dep_MenuPaths of dView into mPaths
   repeat for each line mPath in mPaths
      close stack mPath
      if there is a stack mPath then
         -- 
      else
         breakpoint
      end if
   end repeat
end menu_LoadMenus
