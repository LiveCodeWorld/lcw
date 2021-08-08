script "Global_ScriptEditor_Script_Default_Menu"
`--> MetaData
-
license: GPLv3
name: Global_ScriptEditor_Script_Default_Menu
type: controller
version: 0.2

local LocalArray


--> Menu  | Props
-
on menu_Init
   put the selectedtext of the clickfield into LocalArray ["selectedtext"]
end menu_Init

getprop editMenu_Param
   return ide_ShortTitle ("Script")
end editMenu_Param

getprop editMenu_Params
   put ide_ListShortMenuTitles ("Script") into shortNames
   return shortNames
end editMenu_Params

getprop setMenu_Param
   return ide_ShortTitle ("Script")
end setMenu_Param

getprop setMenu_Params
   put ide_ListShortMenuTitles ("Script") into shortNames
   return shortNames
end setMenu_Params


--> Global | ScriptEditor | Script | Default | Menu
-
on menu_FindAllHandlers mTarget
   put LocalArray ["selectedtext"] into hName
   --  
   if hName is empty then
      put lcw_Ask ("What handler do you want to search for?", "F someFunction") into shortHkey
   else
      put word 2 of the clickline into lineNum
      put word 1 to -1 of line lineNum of the text of clickfield into scriptLine
      --
      switch
         case word 1 to 2 of scriptLine = "put the"
            put "G" && hName into shortHkey
            break
         case word 1 to 2 of scriptLine = "set the"
            put "S" && hName into shortHkey
            break
         case word 1 of scriptLine = hName
            put "M" && hName into shortHkey
            break
         case firstWord = "put"
         default
            put "F" && hName into shortHkey
      end switch
   end if
   --
   display_FoundLibs shortHkey
   put the result into displayView
   --
   put the stack_Name of displayView into stackName
   put the globalloc of the mouseloc into gLoc
   set the loc of stack stackName to gLoc
end menu_FindAllHandlers

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_SpotlightHandler
   -- these spotlight handlers are not working any more?
   put LocalArray ["selectedtext"] into hName
   put spotlight_FindHandlerFile (hName)
   put spotlight_FindInExportedScript (hName)
end menu_SpotlightHandler

on menu_ScriptFieldBehavior
   edit the script of stack "behavior_IdeScriptEditorField"
end menu_ScriptFieldBehavior

on _
end _

on menu_EditMenu mTarget, mTitle
   ide_EditMenu "Script"
end menu_EditMenu

on menu_SetMenu mTarget, mTitle
   ide_SetMenuTitle "Script", mTitle
end menu_SetMenu


--> Global | ScriptEditor | Script | Authoring | Menu
-
on menu_AuthoringMenu mTarget
   put mTarget
end menu_AuthoringMenu

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
