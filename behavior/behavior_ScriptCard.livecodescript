script "behavior_DisplayScriptCard"
--> MetaData
-
license: GPLv3
name: behavior_DisplayScriptCard
type: behavior
version: 0.3


--> Menu | Target
-
getprop menu_Target [mTitlePath]
   try
      switch
         case mTitlePath contains "Script | Record | Menu"
            put menu_GetTargetObject() into targetObject
            put the displayed_Hkey of targetObject into hKey
            return hKey
         case mTitlePath contains "Global | Hkey | Calls | Menu"
            put menu_GetTargetObject() into targetObject
            put the displayed_Hkey of targetObject into hKey
            return hKey
         case mTitlePath contains "Global | Dot | Graph Properties | Menu"
            return the long id of me
         case mTitlePath contains "Global | Overlay |" -- Global | Graph | Folder | Array | Menu
            -- put the tree_SelectedLink of treeField into hKey
            return the overlay_Folder of me
         case mTitlePath contains "Global | Graph | Folder |" -- Global | Graph | Folder | Array | Menu
            -- put the tree_SelectedLink of treeField into hKey
            return the overlay_Folder of me
         default
            pass menu_Target
      end switch
   catch e
      pass menu_Target
   end try
end menu_Target

getprop menu_Title
   put the short name of the target into someName
   switch someName
      case "Right Icon"
         return "Script | Record | Menu" -- the default and in the substack
         return "Global | Script | Process | Menu"
         return "Global | Script | Processing | Menu"
      case "Title"
         return "Script | Title | Menu" -- in the substack
         return "Global | Script | Menu" -- in the substack
      default
         pass menu_Title
   end switch
end menu_Title

-- getprop menu_ToolTitle
return "Global | Title | Controller | Menu"
end menu_ToolTitle


--> Menu | Props
-
getprop menu_Version
   return 1
end menu_Version


--> Events
-
on selectionChanged pHilitedIndex, pPrevHilitedIndex
   put the dgDataOfIndex [ pHilitedIndex ] of the target into recordArray
   put recordArray ["hKey"] into hKey
   if hKey is not empty then
      lock screen  
      -- script_SaveDisplayedHelp -- not saving for now
      put hkey_FetchHelp (hKey) into handlerHelp
      set the displayed_Description [hKey] of me to handlerHelp
      unlock screen
   end if
end selectionChanged

on closeField
   put the short name of the target into fieldName
   switch fieldName
      case "Text"
         script_SaveDisplayedHelp
         break
      case "Script"
         break
      default
         opn_Notify fieldName, true
   end switch
   pass closeField
end closeField

command help_SaveAndDisplay scriptObject, pOverlayName
   script_SaveDisplayedHelp
   put the script_Help of scriptObject into scriptHelp
   set the displayed_Description [pOverlayName] of me to scriptHelp
   return scriptHelp
end help_SaveAndDisplay

command script_SaveDisplayedHelp
   put the scriptLibrary_Card of me into scriptLibraryCard
   put the displayed_Object of scriptLibraryCard into displayedObject
   if exists (displayedObject) is false then
      opn_Notify "Error with script_SaveDisplayedHelp!", true
      return empty
   end if
   
   put the displayed_Description of scriptLibraryCard into displayedHelp
   set the script_Help of displayedObject to displayedHelp
   return displayedHelp
end script_SaveDisplayedHelp


--> Events | Custom
-
on button_Up
   put the script_Footer of me into scriptFooter
   put the icon_Name of the target into someName
   put the scriptLibrary_Tree of me into dataTreeView
   switch someName
      case "xchat"
         set the view_Swap of scriptFooter to "Field|HyperText"
         break
      case "icon_logout"
         -- set the view_Swap of scriptFooter to "Layouts|Placeholder"
         set the view_Swap of dataTreeView to "Tree|Datagrid"
         put the result into dataTreeView
         set the record_ViewName of dataTreeView to "Record|Handler"
         break
      case "icon_settings"
         set the view_Swap of scriptFooter to "Layouts|Placeholder"
         set the view_Swap of dataTreeView to "Layouts|Placeholder"
         break
      default
   end switch
end button_Up


--> Datagrid
-
getprop numbers_On
   return false
end numbers_On

setprop numbers_On someBoolean
end numbers_On

-- on disclose_Handler someBoolean
   put the long id of the target into recordView
   -- put the record_Array of recordView into 
   put the record_Title of recordView into hKey
   if someBoolean is true then
      -- put the record_Handler of the target
      put hkey_FetchHelp (hKey) into helpText
      set the displayed_Description of recordView to helpText
   else
      put the displayed_Object of me into scriptObject
      put the script_Help of scriptObject into scriptHelp
      -- script_SaveDisplayedHelp
      set the displayed_Description [scriptObject] of me to scriptHelp
   end if
end disclose_Handler

private function _constructSuiteTitle someTitle
   put ("<b>" & someTitle & "</b>") into suitTitle
   return suitTitle
end _constructSuiteTitle

on dg_FillInData recordArray, recordView
    -- for script title sections
   lock screen
   put recordArray ["startLineNum"] into startLineNum
   put recordArray ["lineType"] into lineType
   put recordArray ["isExpanded"] into isExpanded
   put recordArray ["scriptLine"] into someTitle
   
   -- handlers also have these sections
   put recordArray ["endLineNum"] into endLineNum
   put recordArray ["handler"] into handler
   put recordArray ["hKey"] into hKey
   
   -- set the background_Colour of recordView to orange
   
   switch
      case handler is empty and isExpanded is true -- an opened suite
         put _constructSuiteTitle (someTitle) into suitTitle
         set the record_HtmlText of recordView to suitTitle
         break
      case handler is empty and isExpanded is false -- a closed suite
         put _constructSuiteTitle (someTitle) into suitTitle
         set the title_HtmlText of recordView to suitTitle
         break
      case handler is not empty and isExpanded is true -- an opened handler
         set the record_Handler [startLineNum] of recordView to handler
         break
      case handler is not empty and isExpanded is false -- a closed handler
         set the hkey_Title of recordView to hKey
         break
   end switch
   
   set the record_IsExpanded of recordView to isExpanded
   if the displayed_lineNumbers of me is true then
      set the lineNumbers_Visible of recordView to true
      set the lineNumbers_Start of recordView to startLineNum
   else
      set the lineNumbers_Visible of recordView to false
   end if
   unlock screen
end dg_FillInData


--> Display
-
local LocalArray

getprop vertical_Spacing
   return 8
end vertical_Spacing

private command display_UpdateDatagrid
   put the scriptLibrary_Tree of me into dataTreeView
   if the view_Name of dataTreeView = "View|Tree|Datagrid" then
      set the view_Swap of dataTreeView to "Layouts|Placeholder"
   else
      set the view_Swap of dataTreeView to "Tree|Datagrid"
      put the result into dataTreeView
      set the record_ViewName of dataTreeView to "Record|Handler"
   end if
end display_UpdateDatagrid

private command display_ScriptArray pScriptArray
   set the cursor to watch
   if pScriptArray is not an array then
      put the displayed_ScriptArray of me into pScriptArray
   else
      set the displayed_ScriptArray of me to pScriptArray
   end if
   
   put the scriptLibrary_Tree of me into scriptLibraryTree
   set the dg_Data of scriptLibraryTree to pScriptArray
end display_ScriptArray

private command _displayScriptObject pScriptObject, pOverlayName
   set the cursor to watch
   put false into pIndexSuites
   
   if pScriptObject is empty then
      put the displayed_Object of me into pScriptObject
   else
      put pScriptObject into LocalArray ["displayed_Object"]
   end if
   
   -- put the exported_Script of scriptObject into someScript
   put the script of pScriptObject into someScript
   set the displayed_Script [pOverlayName] of me to someScript
   
   lock screen  
   set the displayed_Title of me to the mobile_Name of pScriptObject
   help_SaveAndDisplay pScriptObject, pOverlayName
   put script_ConstructArray (someScript, pScriptObject, pIndexSuites) into scriptArray
   display_ScriptArray scriptArray
   
   put the overlay_ImageFile [pOverlayName] of pScriptObject into imageFile
   if there is a file imageFile then
      set the visible_Status of the description_Header of me to true
      
      put the scriptLibrary_Image of me into imageView
      put the overlay_Folder of pScriptObject into overlayFolder
      display_Overlay overlayFolder, pOverlayName, imageView
   else
      set the visible_Status of the description_Header of me to false
   end if
   unlock screen
   
   return scriptArray
end _displayScriptObject

getprop displayed_ScriptArray
   return LocalArray ["scriptArray"]
end displayed_ScriptArray

setprop displayed_ScriptArray scriptArray
   put scriptArray into  LocalArray ["scriptArray"]
end displayed_ScriptArray

getprop displayed_lineNumbers
   lock messages
   put the displayed_lineNumbers of me into someBoolean
   unlock messages
   return someBoolean is true
end displayed_lineNumbers

setprop displayed_lineNumbers someBoolean
   lock messages
   set the displayed_lineNumbers of me to someBoolean
   unlock messages
end displayed_lineNumbers


--> Displayed
-
getprop displayed_Script
   return LocalArray ["displayed_Script"]
end displayed_Script

setprop displayed_Script [pOverlayName] someScript
   put someScript into LocalArray ["displayed_Script"]
end displayed_Script

getprop displayed_Object
   return LocalArray ["displayed_Object"]
end displayed_Object

setprop displayed_Object [pOverlayName] scriptObject
   _displayScriptObject scriptObject, pOverlayName
   put the result into scriptArray
   return scriptArray
end displayed_Object


--> Field | HyperText | Menu
-
on menu_Link hyperField
   put hyperField
end menu_Link


--> Display | Basic Props
-
/*
From these properties everything else is derived.
*/

getprop displayed_OverlayFolder
   put the displayed_Object of me into scriptObject
   put the overlay_Folder of scriptObject into overlayFolder
   return overlayFolder
end displayed_OverlayFolder


--> Displayed | Overlay
-
/*
These basic properties are all that are needed for overlay libraries and tools to operate.
*/

getprop displayed_OverlayArray [pOverlayName]
   breakpoint
   put the displayed_Object of me into scriptObject
   put the overlay_Array of scriptObject into overlayArray
   return overlayArray
end displayed_OverlayArray

setprop displayed_OverlayArray [pOverlayName] overlayArray
   breakpoint
   put the displayed_Object of me into scriptObject
   set the overlay_Array [pOverlayName] of scriptObject to overlayArray
end displayed_OverlayArray
