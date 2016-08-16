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
   project_CreateScriptOnlyStack "controller", pQuestion, suggestedAnswer
end menu_CreateMenuStack

on menu_CreateModel scriptObject, projectChoice
   put "Choose a name for your script only model stack...." into someQuestion
   put the script_MetaData ["name"] of scriptObject into scriptName
   if scriptName is empty then put "Example" into scriptName
   put "model_" & scriptName into suggestedAnswer
   
   project_CreateScriptOnlyStack "model", someQuestion, suggestedAnswer, projectChoice
end menu_CreateModel

on menu_CreateBehavior scriptObject
   put "Choose a name for your script-only behavior stack...." into someQuestion
   put the script_MetaData ["name"] of scriptObject into scriptName
   if scriptName is empty then put "Example" into scriptName
   put "behavior_" & scriptName into suggestedAnswer
   
   project_CreateScriptOnlyStack "behavior", someQuestion, suggestedAnswer
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
   
   project_CreateScriptOnlyStack "library", someQuestion, suggestedAnswer
end menu_CreateLibrary

on _
end _

on menu_SetWorkingProject mTarget, projectChoice
   project_SetCurrentName projectChoice
end menu_SetWorkingProject


--> Global | ScriptEditor | Create | Menu | Props
-
getprop project_Choice
   return project_GetCurrentName()
end project_Choice

getprop project_Choices
   return library_ListProjectNames ()
end project_Choices


--> Global | ScriptEditor | Create | Menu | Disabled
-
getprop disabled_CreateView [scriptObject]
   put the view_Name of scriptObject into vName
   return vName is empty
end disabled_CreateView


--> Deps
-
command project_CreateScriptOnlyStack libType, pQuestion, pExample, pProjectName
   -- this handler creates a script only stack in the corresponding folder of the Livecode World Library
   
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   if pQuestion is empty then put "Give your library a name" into pQuestion
   if pExample is empty then put "lib_Example" into pExample
   put opn_Ask (pQuestion, pExample) into libName
   if there is a stack libName then
      put the filename of stack libName
      go to stack libName
      show stack libName
      answer warning "Already a stack with that name!"
      edit the script of stack libName
      exit to top
   end if
   
   put project_GetFolder (pProjectName) into projectFolder
   if projectFolder is empty then
      -- safety check
      answer warning "Cannot locate Livecode World standard model folder!"
      exit to top
   end if
   
   put project_GetStandardFolder (libType, projectFolder) into lcwStandardFolder
   put _constructScriptOnlyMenuFileName (libName) into shortFile
   put lcwStandardFolder & shortFile into lcwLibraryFile
   
   -- revIDENewScriptOnlyStackWithScript pName, pScript
   create script only stack libName
   show stack libName
   set the filename of stack libName to lcwLibraryFile
   
   put metadata_ConstructUripArray (libName, libType) into uRipArray
   set the script_MetaData of stack libName to uRipArray
   
   save stack libName
   set the stack_IsKnown of stack libName to true
   if libType is among the items of "library,model" then
      start using stack libName
   end if
   
   edit the script of stack libName
   opn_Notify ("Stack" && kwote (libName) && "is now known and used!")
   return libName
end project_CreateScriptOnlyStack

private function _constructScriptOnlyMenuFileName libName
   -- set the itemdelimite to " | "
   replace " | " with "_" in libName
   replace "|" with "_" in libName -- just in case
   -- replace space with empty in libName -- maybe good to do this and use initialcaps algo to reconsitute ???
   put libName & ".livecodescript" into shortFile
   return shortFile
end _constructScriptOnlyMenuFileName
