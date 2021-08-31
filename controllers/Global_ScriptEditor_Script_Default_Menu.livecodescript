script "Global | ScriptEditor | Script | Default | Menu"
--> MetaData
-
license: GPLv3
name: Global | ScriptEditor | Script | Default | Menu
type: controller
version: 0.2


--> Menu  | Props
-


--> Global | ScriptEditor | Script | Default | Menu
-
on menu_FindHandler mTarget
   put the selectedtext of the clickfield into hName
   put word 2 of the clickline into lineNum
   put word 1 to -1 of line lineNum of the text of clickfield into scriptLine
   --
   switch
      case word 1 of scriptLine = "getprop"
      case word 1 to 2 of scriptLine = "put the"
         put "G" && hName into shortHkey
         break
      case word 1 of scriptLine = "setprop"
      case word 1 to 2 of scriptLine = "set the"
         put "S" && hName into shortHkey
         break
      case word 1 of scriptLine = "command"
      case word 1 of scriptLine = "on"
      case word 1 of scriptLine = hName
         put "M" && hName into shortHkey
         break
      case firstWord = "put"
      default
         put "F" && hName into shortHkey
   end switch
   --
   ask_FindHkey shortHkey
end menu_FindHandler

on _
end _

on submenu_Menu
   return "Global | ScriptEditor | Menu"
end submenu_Menu

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_SpotlightHandler
   -- these spotlight handlers are not working any more?
   put the selectedtext of the clickfield into hName
   --
   put spotlight_FindHandlerFile (hName)
   put spotlight_FindInExportedScript (hName)
end menu_SpotlightHandler

on menu_ScriptFieldBehavior
   edit the script of stack "behavior_IdeScriptEditorField"
end menu_ScriptFieldBehavior
