script "Global | Wiki | Tools | Menu"
--> MetaData
-
license: GPLv3
name: Global | Wiki | Tools | Menu
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
   put the data_View of tObject into dView
   return dView
end menu_Target

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | Wiki | Tools | Menu
-
on menu_WikiTools dView
   put the name of dView
end menu_WikiTools

private on _
end _

on menu_GhostTest sView
   put the browser_View of sView into browserView
   --
   get the last_PageInfo of browserView
   put item 1 of it into wikiDomain
   put item 2 of it into pSlug
   --
   put pageArray_Fetch (wikiDomain, pSlug) into pageArray
   set the ghost_PageArray of browserView to pageArray
end menu_GhostTest

private on __
end __

on submenu_Dev
   return "Global | Wiki | Tools | Dev | Menu"
end submenu_Dev
