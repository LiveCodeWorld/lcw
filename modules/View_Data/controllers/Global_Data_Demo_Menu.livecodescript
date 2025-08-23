script "Global | Data | Demo | Menu"
--> MetaData
-
license: GPLv3
name: Global | Data | Demo | Menu
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
   put dView into LocalArray ["dView"]
   return dView
end menu_Target

private function _dView
   return LocalArray ["dView"]
end _dView

function script_WalkHierachyMenu sName
   put the name of stack sName into oMenu
   put CR & "-" & CR after oMenu
   put the walk_Hierarchy of stack sName after oMenu 
   return oMenu
end script_WalkHierachyMenu

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget

getprop depGraph_Params
   return script_WalkHierachyMenu ("lib_DisplayData")
end depGraph_Params

getprop checked_StartUsing
   put dataStack_Name() into dName
   return dName is among the lines of the stacksinuse
end checked_StartUsing

getprop checked_DisplayEnvironment
   switch
      case exists (stack "Display Local Projects") is false
      case visible of stack "Display Local Projects" is false
         return false
      default
         return true
   end switch   
end checked_DisplayEnvironment

getprop addLibrary_Params
   return scriptEditor_ListTabScriptObjects()
end addLibrary_Params


--> Global | Data | Demo | Menu
-
on menu_DisplayEnvironment
   display_EnvironmentToggle
end menu_DisplayEnvironment

on menu_DepGraph dView, sObject
   put the script_WalkHandlers of sObject into hKeyArray
   --
   reDisplayGraph_HkeyArray hkeyArray, sObject, "hierarchy"
end menu_DepGraph

on menu_AddLibrary dView, sObject
   set the stackFile_Object of dView to sObject
end menu_AddLibrary

private on _
end _

on menu_DisplayDepArray dView
   put the dep_Array of dView into depArray
   set the displayed_Data ["the dep_Array"] of dView to depArray
end menu_DisplayDepArray

on menu_ModuleTools dView
   -- display_ModuleTools mStackName, pDisplayView
   put the module_Folder of me into moduleFolder
   put directory_NestedArray (moduleFolder) into dArray
   
   set the displayed_Data ["Module Directory"] of dView to dArray
end menu_ModuleTools

on menu_DataDemo dView
   put the module_Array of dView into mArray
   set the displayed_Data ["the module_Array"] of dView to mArray
end menu_DataDemo

private on __
end __

on menu_ResetBehaviors dView
   put the dep_Array of dView into depArray
   put depArray ["behavior_IndexArray"] into bArray
   set the behavior_IndexArray of dView to bArray
end menu_ResetBehaviors

on menu_DisplayBehaviorIndexArray dView
   put the stack_Name of dView into sName
   put the behavior_IndexArray of stack sName into bArray
   -- put the behavior_IndexArray of dView into bArray
   --
   set the displayed_Data ["the behavior_IndexArray"] of dView to bArray
end menu_DisplayBehaviorIndexArray

on menu_SetDepArray dView
   put the stackFile_DepArray of dView into depArray
   set the dep_Array of dView to depArray
   set the displayed_Data ["the dep_Array"] of dView to depArray
end menu_SetDepArray

on menu_StartUsing
   put dataStack_Name() into dName
   if dName is among the lines of the stacksinuse then
      stop using stack dName
   else
      start using stack dName
   end if
end menu_StartUsing

on submenu_Dev
   return "Global | Data | Demo | Dev | Menu"
end submenu_Dev
