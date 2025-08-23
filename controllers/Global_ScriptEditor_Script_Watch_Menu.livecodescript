script "Global | ScriptEditor | Script | Watch | Menu"
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


--> Menu | Props
-
getprop menu_Target [fieldObject]
   return fieldObject
end menu_Target


--> Global | ScriptEditor | Script | Watch | Menu
-
on menu_DisplayDictionary fieldObject
   put the selectedText of fieldObject into sText
   --
   put ideDocsFetchLCSEntries() into sIndexArray
   put indexArray_FindArray (sIndexArray, "display name", sText) into foundArray
   if foundArray is empty then
      display_Data sIndexArray, sText, "ideDocsFetchLCSEntries()"
   else
      display_Data foundArray, sText, "ideDocsFetchLCSEntries()"
   end if
end menu_DisplayDictionary

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
