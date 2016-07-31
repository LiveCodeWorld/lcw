script "Global_Fossil_Watch_Menu"
--> MetaData
-
license: GPLv3
name: Global_Fossil_Watch_Menu
type: controller
version: 0.1


--> Global | Fossil | Watch | Menu
-
on insert_FossilCommon
   return "Script Editor | Watch | Menu"
end insert_FossilCommon

on _
end _

on insert_Fossil
   return "Global | Fossil | Menu"
end insert_Fossil


--> Global | Fossil | Watch | Menu | Disabled
-
getprop disabled_DisplayLocalChanges [mTarget]
   if the script_IsDifferent of mTarget is true then
      return false
   else
      return true -- "delete"
   end if
end disabled_DisplayLocalChanges


