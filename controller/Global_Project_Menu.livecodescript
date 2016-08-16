script "Global_Project_Menu"
--> MetaData
-
license: GPLv3
name: Global_Project_Menu
type: controller
version: 0.3


--> Global | Project | Menu
-
on submenu_LibrarySet
   return "Global | Project | Set | Menu"
end submenu_LibrarySet

on menu_DisplayProject mTarget
   put the index_View of mTarget into indexView
   if exists (indexView) is false then
      display_ProjectStacks
      exit to top
   end if
   
   put project_FetchValue ("openStacks") into stackNames
   sort stackNames
   set the view_Index of indexView to stackNames
end menu_DisplayProject

on menu_DisplayProjectArray mTarget, projectName
   put library_FetchProjectArray (projectName) into projectArray
   put merge ("library_FetchProjectArray (projectName),[[projectName]]") into someTitle
   display_Array projectArray, someTitle, "Global | Project | Menu"
end menu_DisplayProjectArray

on _
end _

on menu_SelectProjectStacks mTarget
   set the multiple_Hilites of mTarget to true
   put project_FetchValue ("openStacks") into stackNames
   sort stackNames
   set the selected_Index of mTarget to stackNames
end menu_SelectProjectStacks

on menu_AddStacksToProject indexView
   put the selected_Index of indexView into projectStackNames
   project_AddStack projectStackNames
   replace CR with comma in projectStackNames
   opn_Notify merge ("Added stacks '[[projectStackNames]]' to the project array.")
end menu_AddStacksToProject

on menu_StoreSelectedProjectStacks indexView
   put the selected_Index of indexView into projectStackNames
   project_SaveValue "openStacks", projectStackNames
   
   opn_Notify "Stored the selected project stack names, to the project array."
end menu_StoreSelectedProjectStacks

on menu_ProjectOnlyStacks mTarget
   put project_FetchValue ("openStacks") into stackNames
   sort stackNames
   set the view_Index of mTarget to stackNames
   set the multiple_Hilites of mTarget to false
end menu_ProjectOnlyStacks

on _
end _

on menu_DisplayOpenStacks
   put the openstacks into stackNames
   display_Index stackNames, "Project", "Global | Project | Menu", "Global | Project | Line | Menu", empty, "project_GoToStack"
   put the result into displayView
   set the multiple_Hilites of displayView to false
end menu_DisplayOpenStacks

on menu_DisplayLoadedStacks
   display_LoadedStacks
end menu_DisplayLoadedStacks

on _
end _

on menu_DisplayGlobalMenu
   display_Menus
end menu_DisplayGlobalMenu

on menu_DisplayBehaviors
   display_Behaviors
end menu_DisplayBehaviors

on menu_DisplayScriptMenus
   put "/Users/BabyBlue/Documents/My Revolution Enterprise/Plugins/opn_Plugins/opn_Libraries/libOPN_Scripts.rev" into longStackFile
   put the cardnames of stack "libOPN_Scripts|OPN Stack Menus" of stack longStackFile into globalMenuCardNames
   sort globalMenuCardNames
   
   put "" into titleMenu
   put "" into lineMenu
   put "opnScripts_EditScript" into upCommand
   put "" into doubleCommand
   put "" into dragCommand
   
   put "Substack Menus,From libOPN_Scripts" into displayTitle
   display_Index globalMenuCardNames, displayTitle, titleMenu, lineMenu, upCommand, doubleCommand, dragCommand
   put the result into displayView
   set the multiple_Hilites of displayView to false
end menu_DisplayScriptMenus

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Project | Menu | Props
-
getprop project_Names
   return library_ListProjectNames()
end project_Names

getprop project_StackNames
   put project_FetchValue ("openStacks") into stackNames
   return stackNames
end project_StackNames


--> Global | Project | Menu | Props
-
getprop disabled_GoToStack
   put project_FetchValue ("openStacks") into stackNames
   if stackNames is empty then
      return true
   else
      return false
   end if
end disabled_GoToStack


--> Global | Project | Line | Menu
-
on menu_TestProjectLine
   put the params
end menu_TestProjectLine

on menu_MultipleHilites indexView, someBoolean
   set the multiple_Hilites of indexView to someBoolean
end menu_MultipleHilites

--> Global | Project | Line | Menu | Props
-
getprop multiple_Hilites [indexView]
   put the multiple_Hilites of indexView into someBoolean
   return someBoolean
end multiple_Hilites


--> Deps
-
private command _safeGoProjectStack projectStackName
   if exists (stack projectStackName) then
      go to stack projectStackName
      show stack projectStackName
   else
      answer merge ("Cannot locate stack '[[projectStackName]]'")
      put projectStackName
   end if
end _safeGoProjectStack


--> Dev | Menu
-
on menu_OpenAllProjectStacks
   put project_FetchValue ("openStacks") into stackNames
   repeat for each line projectStackName in stackNames
      _safeGoProjectStack projectStackName
   end repeat
end menu_OpenAllProjectStacks

on menu_SetMultipleHilites mTarget, someBoolean
   set the multiple_Hilites of mTarget to someBoolean
   set the selected_Index of mTarget to empty
end menu_SetMultipleHilites

on menu_TopLevel mTarget, someBoolean
   put the stack_Name of mTarget into stackName
   if someBoolean is true then
      toplevel stack stackName
   else
      palette stack stackName
   end if
end menu_TopLevel

on _
end _

on menu_EditBehavior mTarget
   put the behavior of mTarget into bStackObject
   edit the script of bStackObject
end menu_EditBehavior

on menu_SaveStack mTarget
   put the stack_Name of mTarget into stackName
   save stack stackName
   put merge ("Saved stack '[[stackName]]'") into someMessage
   opn_Notify someMessage
end menu_SaveStack


--> Dev | Menu | Props
-
getprop set_MultipleHilites [mTarget]
   put the multiple_Hilites of mTarget into someBoolean
   return someBoolean
end set_MultipleHilites

getprop top_Level [mTarget]
   put the stack_Name of mTarget into stackName
   put the mode of stack stackname into someMode
   return someMode is not 4
end top_Level
