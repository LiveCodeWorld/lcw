script "Global | Data | Script | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Data | Script | Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_IconArray [mTarget]
   put the menu_ItemArray of me into iconArray
   put the script_Hkey ["M setTable"] of me into hkey
   put hkey into iconArray [3]["hkey"]
   --
   iconData_AddIcon iconArray, "menu_Tree", "sitemap"
   iconData_AddIcon iconArray, "menu_Index", "list"
   iconData_AddIcon iconArray, "menu_Table", "table"
   iconData_AddIcon iconArray, "menu_Browser", "globe"
   iconData_AddIcon iconArray, "menu_Refresh", "cog"
   --
   return iconArray
end menu_IconArray

on setTable sView
   put the data_View of sView into dView
   --
   put _HkeyArray (dView) into hkeyArray
   put _ScriptObject (dView) into sObject
   --
   put hKeyStackTable_Construct (hkeyArray, sObject) into hkeyTable
   set the itemdelimiter to tab
   sort numeric lines of hkeyTable by item 2 of each
   --
   put the index_View of dView into indexView
   set the displayed_Index of indexView to hkeyTable
   set the body_Type [true] of dView to "Index"
end setTable

getprop menu_Target [tObject]
   put the data_View of tObject into dView
   return dView
end menu_Target

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget

getprop display_Param [dView]
   return the uOPN ["show_How"] of dView
end display_Param

getprop display_Params
   return "projects,stacks,hKeys,-,hkeyArray"
end display_Params

-- getprop oldScriptWalk_Params
return script_WalkHierachyMenu ("lib_DisplayData")
end oldScriptWalk_Params

getprop checked_Tree [sView]
   return _DisplayedName (sView, "Tree")
end checked_Tree

getprop checked_Index [sView]
   return _DisplayedName (sView, "Index")
end checked_Index

getprop checked_Table [sView]
   return _DisplayedName (sView, "Table")
end checked_Table

getprop checked_Browser [sView]
   return _DisplayedName (sView, "Browser")
end checked_Browser

private function _DisplayedName sView, sName
   -- if the body_Type of sView = "Index"
   put the footer_View of sView into footerView
   return the hilitedItemName of footerView = sName
end _DisplayedName

private command _SetMenus dView, showHow
   put "Global | Script | Dep | Line | Menu" into mTitle
   if showHow = "hkeys" then
      put the index_Field of dView into indexField
      set the line_Menu of indexField to "Global | Script | Hkey | Line | Menu"
   else
      set the itemdelimiter to " | "
      put text_InitialCaps (showHow) into item 3 of mTitle
      put the tree_View of dView into arrayView
      set the line_Menu of arrayView to mTitle
   end if
end _SetMenus

private function _ScriptObject sView
   put the data_View of sView into dView
   return the uOPN ["displayed_Object"] of dView
end _ScriptObject

private function _HkeyArray sView
   put the data_View of sView into dView
   return the uOPN ["displayed_HkeyArray"] of dView
end _HkeyArray

private function _GetShowHow sView
   put the data_View of sView into dView
   return the uOPN ["show_How"] of dView
end _GetShowHow

private command _SetShowHow sView, showHow
   put the data_View of sView into dView
   set the uOPN ["show_How"] of dView to showHow
end _SetShowHow

private function _StripMissing sView
   put the data_View of sView into dView
   return the uOPN ["strip_MissingProps"] of dView
end _StripMissing

private function _GetData sView, showHow
   put the data_View of sView into dView
   --
   put _HkeyArray (dView) into hkeyArray
   put _StripMissing (dView) into stripMissing
   -- put _GetShowHow (dView) into showHow
   --
   put hkeyArray_DisplayData (hkeyArray, showHow, stripMissing) into dData
   return dData
end _GetData

getprop graph_Param [sView]
   put _ScriptObject (sView) into sObject
   return _ExportedStyles (sObject)
end graph_Param

getprop graph_Params
   return _GraphStyles()
end graph_Params

private function _GraphStyles
   return dot_ListGraphStyles()
end _GraphStyles

private function _ExportedStyles sObject
   put the script_MetadataFiles [false] of sObject into dotFiles
   filter dotFiles with "*.dot" into graphStyles
   replace ".dot" with empty in graphStyles
   return graphStyles
end _ExportedStyles


--> Global | Data | Script | Menu
-
on menu_Display mTarget, showHow
   put the data_View of mTarget into dView
   --
   put _HkeyArray (dView) into hkeyArray
   put _StripMissing (dView) into stripMissing
   --
   put hkeyArray_DisplayData (hkeyArray, showHow, stripMissing) into dData
   --
   if dData is an array then
      set the tree_Data of dView to dData
   else
      set the index_Data of dView to dData
   end if
   set the uOPN ["show_How"] of dView to showHow
end menu_Display

on menu_Graph mTarget, graphStyle
   set the cursor to watch
   
   put _ScriptObject (mTarget) into sObject
   put _HkeyArray (mTarget) into hkeyArray
   
   if hkeyArray is not an array Or the shiftKey is "Down" then
      breakpoint
      _ReWalkHkeyArray dView
      put the result into hkeyArray
   end if
   
   -- reDisplayGraph_HkeyArray hkeyArray, sObject, graphStyle
   
   # Re-Draw
   graph_CreateFromScriptHkeyArray hkeyArray, sObject, graphStyle
   put the result into svgFile
   
   # Display
   put the browser_View of mTarget into svgView
   set the svg_File [true] of svgView to svgFile
   set the displayed_GraphStyle of svgView to graphStyle
   
   wait 5 ticks
   set the body_Type of mTarget to "Browser"
end menu_Graph

private on _
end _

on menu_Index sView
   put _GetData (sView, "Hkeys") into dData
   set the index_Data of sView to dData
   set the body_Type of sView to "Index"
   _SetShowHow sView, "Index"
end menu_Index

on menu_Tree sView
   put _GetData (sView, "Stacks") into dData
   set the tree_Data of sView to dData
   set the body_Type of sView to "Tree"
   _SetShowHow sView, "Tree"
end menu_Tree

on menu_Table sView
   setTable sView
   --
   put the footer_View of sView into footerView
   set the hilitedItemName of footerView to "Table"
end menu_Table

on menu_Browser sView
   put _ScriptObject (sView) into sObject
   put _HkeyArray (sView) into hkeyArray
   
   # Draw and Display Graph
   -- reDisplayGraph_HkeyArray hkeyArray, sObject, graphStyle
   set the body_Type of sView to "Browser"
end menu_Browser

private on __
end __

on menu_Refresh sView
   if the shiftKey is "Down" then
      put _ScriptObject (sView) into sObject
      display_ScriptTools sObject
      --
      display_ModuleTools "View|Data"
   else
      put the data_View of sView into dView
      put the body_IsVisible of dView into sBoolean
      -- put the rect of dView into oRect
      put the card_Rect of dView into oRect
      
      lock screen
      --
      set the header_IsVisible of dView to (sBoolean is false)
      set the body_IsVisible  of dView to (sBoolean is false)
      --
      dispatch "LayoutControl" to dView with oRect
      -- set the topleft of dView to 0,0
      unlock screen
   end if
   -- set the body_Type of sView to "Tree"
   -- set the dataView_Style of sView to "Tree"
   dispatch "Refresh" to the footer_View of sView
end menu_Refresh

on menu_Script mTarget
   put _ScriptObject (mTarget) into sObject
   display_ScriptTools sObject
end menu_Script

private on _
end _

on submenu_Dev
   return "Global | Data | Script | Dev | Menu"
end submenu_Dev
