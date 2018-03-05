script "Global_ScriptEditor_List_Default_Menu"
--> MetaData
-
license: GPLv3
name: Global_ScriptEditor_List_Default_Menu
type: controller
version: 0.2

--> Variables
-
local LocalArray


--> Menu | Props
-
on menu_Init
   put word 2 of the clickline into lineNum
   put scriptEditor_Object() into hObject
   put the revAvailableHandlers of hObject into hTable
   sort numeric hTable by word 3 of each
   put line lineNum of hTable into hTableLine
   put hKeyLine_Construct (hTableLine, hObject) into hkeyLine
   
   put hkeyLine into LocalArray ["hkeyLine"]
end menu_Init

getprop menu_Target
   return LocalArray ["hkeyLine"]
end menu_Target


--> Global | ScriptEditor | List | Default | Menu
-
on menu_ListDefaultMenu mTarget
   put word 1 to -1 of the clickText & CR & mTarget
end menu_ListDefaultMenu

on _
end _

on menu_SetMenu mTarget, mTitle
   ide_SetMenuTitle "List", mTitle
end menu_SetMenu


--> Global | ScriptEditor | Recent | Default | Menu | Props
-
getprop m_Title
   return ide_ShortTitle ("List")
end m_Title

getprop m_Titles
   put ide_ListShortMenuTitles ("List") into shortNames
   return shortNames
end m_Titles
