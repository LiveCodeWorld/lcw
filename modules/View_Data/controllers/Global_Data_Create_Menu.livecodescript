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

getprop objectProperties_Params
   return _ViewMenu()
end objectProperties_Params

getprop editBehavior_Params
   return _ViewMenu()
   -- return the menu_CaseConditions ["menu_EditBehavior"] of me
end editBehavior_Params

getprop checked_SetBehavior [dView]
   put the poly_View of dView into polyView
   put the behavior of polyView into bObject
   --
   return bObject = the name of stack "behavior_ViewDataPoly"
end checked_SetBehavior

private function _ViewBehavior dView, propName
   put _ViewObject (dView, propName) into cView
   put the behavior of cView into bObject
   return bObject
end _ViewBehavior

private function _ViewObject dView, propName
   put the propName of dView into cView
   return cView
end _ViewObject

private function _ViewMenu
   return "data_View,-,index_View,tree_View,poly_View,footer_View"
end _ViewMenu

getprop setPanel_Param [sView]
   put the panel_View of sView into panelView
   if exists (panelView) then
      -- return the view_Name of panelView
      return the uRIP["name"] of panelView
   else
      return empty
   end if
end setPanel_Param

getprop setPanel_Params
   put view_ListOpen() into vNames
   filter vNames without "View|Data*"
   return vNames
end setPanel_Params

getprop checked_BrowserView [sView]
   put the data_View of sView into dView
   put the browser_View of sView into browserView
   return exists (browserView)
end checked_BrowserView

getprop checked_PanelView [sView]
   put the data_View of sView into dView
   put the panel_View of sView into panelView
   return exists (panelView)
end checked_PanelView


--> Global | Data | Create | Menu
-
on menu_SetPanel sView, vName
   if vName is empty then
      put "View|Button|Svg" into vName
   end if
   put the data_View of sView into dView
   put the panel_View of sView into panelView
   --
   lock screen
   if exists (panelView) then
      set the view_Swap of panelView to vName
   else
      view_InsertFromPath vName, dView -- set the view_Replacement (copy sView to dView)
      put the result into copiedView
      set the name of copiedView to "Panel"
   end if
   dispatch "LayoutControl" to dView
   set the body_Type of dView to "Panel"
   unlock screen
end menu_SetPanel

on menu_DeletePanelView sView
   put the data_View of sView into dView
   put the panel_View of sView into panelView
   --
   set the body_Type of dView to "Tree"
   delete panelView
end menu_DeletePanelView

getprop disabled_DeletePanelView [sView]
   put the panel_View of sView into panelView
   return exists (panelView) is false
end disabled_DeletePanelView

on menu_BrowserView dView
   put the browser_View of dView into browserView
   if exists (browserView) then
      set the create_Browser of dView to false
   else
      set the create_Browser of dView to true
      set the body_Type of dView to "browser"
   end if
end menu_BrowserView

on menu_CreateModuleMenu dView
   ask_CreateModuleMenu "View|Data", empty, dView
   --
   put the result into mController
   edit the script of mController
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

on menu_ObjectProperties dView, propName
   put _ViewObject (dView, propName) into cView
   display_ObjectProperties cView
end menu_ObjectProperties

on menu_EditBehavior dView, propName
   put _ViewBehavior (dView, propName) into bObject
   edit the script of bObject
end menu_EditBehavior

on menu_SetBehavior dView, propName
   # PolyList
   put the name of stack "behavior_ViewDataPoly" into bObject
   put the poly_View of dView into polyView
   set the behavior of polyView to bObject
end menu_SetBehavior

on submenu_Dev
   return "Global | Data | Create | Menu"
end submenu_Dev
