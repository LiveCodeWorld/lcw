script "Global | Data | Create | Menu"
--> MetaData
-
license: GPLv3
name: Global | Data | Create | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the data_View of tObject into dView
   return dView
end menu_Target

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget

getprop editBehavior_Params
   return the menu_CaseConditions ["menu_EditBehavior"] of me
end editBehavior_Params


--> Global | Data | Create | Menu
-
on menu_CreateModuleMenu dView
   menu_AskCreate dView
end menu_CreateModuleMenu

on menu_CreateModuleBehavior dView
   put the stack_Name of dView into mName
   --
   ask_CreateModuleBehavior mName, dView
   put the result into bPath
   --
   edit the script of stack bPath
end menu_CreateModuleBehavior

private on _
end _

-- on menu_MouseCommand dView, dCommand
   breakpoint
end menu_MouseCommand

on menu_DragCommand dView, dCommand
   switch dCommand
      case "ask"
         put the drop_Command of dView into dCommand
         put "Set the drop_Command..." into sQuestion
         put lcw_Ask (sQuestion, dCommand, dView) into dCommand
         set the drop_Command of dView to dCommand
         break
      case "Empty"
         set the drop_Command of dView to empty
         break
      default
         set the drop_Command of dView to dCommand
   end switch
end menu_DragCommand

private on __
end __

on menu_UpdateAndExportArray dView
   module_UpdateStackFiles dView
   
   # Export Arrays as json
   module_ExportArray dView
   put the result into moduleArray
   
   # Save
   stack_Save dView
   
   put the name of dView into sTitle
   -- display_Data moduleArray, sTitle, "module_Array"
   set the displayed_Data ["Menus"] of dView to moduleArray
end menu_UpdateAndExportArray

on menu_DisplayControllers dView
   put the module_Controllers of dView into mNames
   set the index_Data ["Menus"] of dView to mNames
end menu_DisplayControllers

private on ___
end ___

on menu_EditBehavior dView, propName
   switch propName
      case "data_View"
         put the behavior of dView into bObject
         break
      case "index_View"
         put the propName of dView into cView
         put the behavior of cView into bObject
         break
      case "tree_View"
         put the propName of dView into cView
         put the behavior of cView into bObject
         break
   end switch
   --
   edit the script of bObject
end menu_EditBehavior

on submenu_Dev
   return "Global | Data | Create | Menu"
end submenu_Dev
