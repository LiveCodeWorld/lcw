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
   return "View|Data" is among the lines of the stacksinuse
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
   display_ScriptDepGraph sObject
   return empty
   
   set the cursor to watch
   put "undirected spring" into graphStyle
   put the name of sObject into sLabel
   put "stacks" into showHow
   --
   put the script_WalkHandlers of sObject into hKeyArray
   graph_CreateFromScriptHkeyArray hkeyArray, sObject, graphStyle
   put the result into svgFile
   --
   if the shiftKey is "Down" then
      -- reDisplayGraph_HkeyArray hkeyArray, sObject, graphStyle
      display_SVG svgFile, sLabel
      put the result into svgView
      --
      set the displayed_HkeyArray of svgView to hkeyArray
   else
      put the browser_View of dView into svgView
      if exists (svgView) is false then
         set the create_Browser of dView to true
         put the result into svgView
      end if
      put default_ModuleBehavior ( "View|Image|SVG") into bObject
      set the behavior of svgView to bObject
      
      put hkeyArray_DisplayData (hkeyArray, showHow) into dData
      --
      put hKeyStackTable_Construct (hkeyArray, sObject) into hkeyTable
      set the itemdelimiter to tab
      sort numeric lines of hkeyTable by item 2 of each
      --
      put the script_SuiteArray of sObject into scriptArray
      
      
      set the svg_File [true] of svgView to svgFile
      set the tree_Data of svgView to dData
      set the displayed_ScriptArray of dView to scriptArray
      --
      set the body_Type of dView to "Browser"
      
      # Set Table Style and Text
      put the index_View of dView into indexView
      --
      set the tab_Stops  of indexView to 240
      set the field_Style of indexView to "multiselect"
      set the displayed_Index of indexView to hkeyTable
      
      # Set Menu
      -- set the menu_TitleBit ["lcw_Graph"] of dView to "HkeyArray | Table"
      -- set the menu_TitleBit of dView to "Script | Tree"
      -- set the mouse_DoubleUp of dView to "mDoubleUp_DisplayShortHkey"
      set the menu_TitleBit of dView to "Script | Dep"
   end if
   --
   set the uOPN ["hkey_Array"] of dView to hkeyArray
   set the displayed_Object of svgView to sObject
   -- set the uOPN ["displayed_Object"] of dView to sObject
   set the displayed_GraphStyle of svgView to graphStyle
   set the uOPN ["show_How"] of dView to showHow
   --
   set the uOPN ["hkey_Array"] of dView to hkeyArray
   set the uOPN ["stack_DepArray"] of dView to stackDepArray
   set the displayed_Style of dView to "stacks"
   --
   -- set the title_Text of dView to sLabel
   set the displayed_Object of dView to sObject
   set the title_Text of dView to sObject
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

on menu_DisplayDataModule dView
   if the shiftKey is "Down" then
      display_ModuleTools "View|Data"
   else
      # Gather info   
      put the module_Folder of dView into moduleFolder
      put directory_NestedArray (moduleFolder) into dArray
      
      set the displayed_Data ["Module Directory"] of dView to dArray
      
      # Store info
      set the displayed_ModuleFolder of dView to moduleFolder
      set the displayed_Object of dView to dView
      
      # Set Menus and doubleClick_Message
      put the module_MenuTitle of dView into moduleMenu
      set the menu_TitleBit [moduleMenu] of dView to "Module | Tools"
   end if
end menu_DisplayDataModule

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
