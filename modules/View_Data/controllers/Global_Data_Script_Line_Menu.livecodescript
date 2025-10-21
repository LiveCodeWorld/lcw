script "Global | Data | Script | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Data | Script | Line | Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray

--> Events
-
on doubleClick_Tree treeView, sPath
   put item 1 of sPath into hObject
   switch hObject
      case "Missing"
         get item 2 of sPath
         put word 1 to 2 of it into shortHkey
         --
         put the displayed_ScriptArray of dview into scriptArray
         put the uOPN ["displayed_Object"] of dview into depObject
         put the uOPN ["hkey_Array"] of dview into hKeyArray
         -- put the title_Text of treeView into depObject
         --
         put the hkey_InHierarchy [shortHkey] of depObject into foundHkey
         -- put the hkey_FindInFullHierarchy [shortHkey] of depObject
         --
         hkey_Edit foundHkey
         break
      default
         put item 2 of sPath into hKey
         put item 3 of sPath into parentKey
         --
         if parentKey is empty then
            hkey_Edit hKey
         else if the shiftKey is "Down" then
            hkey_Edit parentKey
         else
            hkey_Edit hKey
         end if
   end switch
end doubleClick_Tree


--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into LocalArray ["dView"]
   put the displayed_Object of tObject into sObject
   return sObject
end menu_Target

private function _dView
   return LocalArray ["dView"]
end _dView

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | Data | Script | Line | Menu
-
on menu_DataScriptLine dView
   put the params
end menu_DataScriptLine

private on _
end _

on submenu_ModuleTools dView
   return "Global | Module | Tools | Line | Menu"
end submenu_ModuleTools

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Data | Script | Line | Menu")
end submenu_Dev
