script "Global | ScriptEditor | Create | Menu"
--> MetaData
-
license: GPLv3
name: Global | ScriptEditor | Create | Menu
type: controller
version: 0.2

local LocalArray


--> Global | ScriptEditor | Create | Menu
-
/*
This menu is for creating standard script only stcks in the right library folders.
*/

on menu_CreateView scriptObject
   -- template_ConstructCloneStack
   template_ConstructStackFromObject scriptObject
end menu_CreateView

on menu_CreateMenuStack
   put "Choose a name for your script only menu stack...." into pQuestion
   put the clipboarddata ["text"] into maybeMenuTitle
   if word -1 of maybeMenuTitle = "Menu" then
      replace " | " with "_" in maybeMenuTitle
      put maybeMenuTitle into suggestedAnswer
   else
      put "Global_Example_Menu" into suggestedAnswer
   end if
   lcw_CreateLibrary "controller", pQuestion, suggestedAnswer
end menu_CreateMenuStack

on menu_CreateModel scriptObject
   put "Choose a name for your script only model stack...." into someQuestion
   put the script_MetaData ["name"] of scriptObject into scriptName
   if scriptName is empty then put "Example" into scriptName
   put "model_" & scriptName into suggestedAnswer
   
   lcw_CreateLibrary "model", someQuestion, suggestedAnswer
end menu_CreateModel

on menu_CreateBehavior scriptObject
   put "Choose a name for your script-only behavior stack...." into someQuestion
   put the script_MetaData ["name"] of scriptObject into scriptName
   if scriptName is empty then put "Example" into scriptName
   put "behavior_" & scriptName into suggestedAnswer
   
   lcw_CreateLibrary "behavior", someQuestion, suggestedAnswer
end menu_CreateBehavior

on menu_CreateLibrary scriptObject
   put "Choose a name for your script-only library stack...." into someQuestion
   put the script_MetaData ["name"] of scriptObject into scriptName
   if scriptName is empty then put "Example" into scriptName
   if char 1 to 4 of scriptName is not "lib_" then
      put "lib_" & scriptName into suggestedAnswer
   else
      put scriptName into suggestedAnswer
   end if
   
   lcw_CreateLibrary "library", someQuestion, suggestedAnswer
end menu_CreateLibrary


--> Global | ScriptEditor | Create | Menu | Disabled
-
getprop disabled_CreateView [scriptObject]
   put the view_Name of scriptObject into vName
   return vName is empty
end disabled_CreateView
