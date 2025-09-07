script "Global | Data | Script | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Data | Script | Dev | Menu
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


--> Global | Data | Script | Dev | Menu
-
on submenu_ScriptDep
   return "Global | Script | Dep | Menu"
end submenu_ScriptDep

on submenu_ScriptTree
   return "Global | Script | Tree | Menu"
end submenu_ScriptTree

on submenu_HkeyArrayTable
   return "Global | HkeyArray | Table | Menu"
end submenu_HkeyArrayTable

on menu_DraftHelp dView, overlayName
   breakpoint
   --
   put _ScriptObject (dView) into sObject
   draft_ScriptHelp sObject, overlayName
end menu_DraftHelp

on menu_ReWalk dView
   breakpoint
   --
   _ReWalkHkeyArray dView
   put the result into hkeyArray
   --
   put _ShowHow() into showHow
   set the hkeyStackArray_ShowHow of dView to showHow
   --
   put _ScriptObject (dView) into sObject
   put _ExportedStyles (sObject) into graphStyle
   reDisplayGraph_HkeyArray hkeyArray, sObject, graphStyle
end menu_ReWalk

on menu_OldScriptWalk mTarget
   put _ScriptObject (mTarget) into sObject
   --
   -- menu_WalkAndGraphScript sObject, graphStyle
   
   put the walk_HkeyArray of sObject into hKeyArray
   set the script_HkeyArray of sObject to hKeyArray
   reDisplayGraph_HkeyArray hkeyArray, sObject, graphStyle
   put the result into svgView
   
   # Optionaly show script
   display_ScriptTools sObject
end menu_OldScriptWalk

on menu_SetFooter mTarget
   put the footer_View of mTarget into footerView
   --
   set the footer_Title of footerView to "Global | Data | Script | Menu"
end menu_SetFooter

private on _
end _
