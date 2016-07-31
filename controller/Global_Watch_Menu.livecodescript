script "Global | Watch | Menu"
--> MetaData
-
license: GPLv3
name: Global | Watch | Menu
type: controller
version: 0.2


--> Global | Watch | Menu
-
/*
This menu is for projects that are not in fossil or git repos.
that is normal stacks :)
*/

on menu_DisplayLocalChanges scriptObject
   put the script of scriptObject into nowScript
   put the exported_Script of scriptObject into exportedScript
   terminal_Diff exportedScript, nowScript, "the exported_Script of mTarget", "the script of mTarget"
end menu_DisplayLocalChanges

on menu_RevealProjectFolder scriptObject
   put the project_Folder of scriptObject into projectFolder
   finder_Reveal projectFolder
end menu_RevealProjectFolder

on submenu_FossilCommon
   return "Script Editor | Watch | Menu"
end submenu_FossilCommon

on _
end _

on submenu_EditScripts
   return "Global | Script | Edit | Menu"
end submenu_EditScripts

on submenu_Teamster
   return "Global | Teamster | Menu"
end submenu_Teamster

on submenu_Script
   return "Global | Script | Menu"
end submenu_Script

on _
end _

on submenu_CreateFossil
   return "Global | Fossil | Menu"
end submenu_CreateFossil

on submenu_NewFossil
   return "Global | Fossil | New | Menu"
end submenu_NewFossil

on _
end _

on submenu_Script
   return "Global | Script | Menu"
end submenu_Script

on submenu_Export
   return "Global | Object | Export | Menu"
end submenu_Export


--> Global | Watch | Menu | Disabled
-
getprop disabled_DisplayLocalChanges [mTarget]
   if the script_IsDifferent of mTarget is true then
      return false
   else
      return true
   end if
end disabled_DisplayLocalChanges
