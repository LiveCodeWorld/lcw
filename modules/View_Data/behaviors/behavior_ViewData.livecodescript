script "behavior_ViewData"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewData
type: behavior
version: 0.7

/*
This is the lates refactored data / tree module.
It is designed to enable easy display and interaction with internet data.
*/

--> Legacy
-
getprop array_View
   return the tree_View of me
end array_View


--> Working on
-
getprop footer_View
   return _FooterWidget()
end footer_View

getprop default_MenuTitle
   put the uRIP ["name"] of me into vName
   return menu_ConstructTitle (vName)
end default_MenuTitle

getprop default_LineMenuTitle
   put the default_MenuTitle of the target into lineTitle
   put "Line | " before word -1 of lineTitle
   return lineTitle
end default_LineMenuTitle


--> MenuBit
-
getprop menu_TitleBit
   get the title_Menu of me
   set the itemdelimiter to "|"
   put word 1 to -1 of item 2 to -2 of it into menuBit
   return menuBit
end menu_TitleBit

setprop menu_TitleBit [libName] menuBit
   set the tool_Context of me to libName
   put the menu_Button of me into mButton
   
   # Construct Menu Titles
   get "Global |" && menuBit
   put it && "| Menu" into titleMenu
   put it && "| Line | Menu" into lineMenu
   
   # Construct mDoubleUp
   replace "|" with empty in menuBit
   replace space with empty in menuBit
   put "mDoubleUp_" & menuBit into mDoubleUp
   
   # Set menus and mouse
   set the title_Menu of me to titleMenu
   set the doubleClick_Message of me to mDoubleUp
   set the line_Menu of me to lineMenu
   
   # Create menus if needed
   -- dispatch "ask_CreateMenuFromObject" to me with titleMenu,libName
   return titleMenu
end menu_TitleBit

getprop doubleClick_Message
   return the uOPN ["doubleClick_Message"] of me
end doubleClick_Message

setprop doubleClick_Message mDoubleUp
   set the uOPN ["doubleClick_Message"] of me to mDoubleUp
end doubleClick_Message


--> Props
-
getprop stack_Rect [fHow]
   put the long id of me into dView
   --
   put the stack_Name of dView into sName
   put the card_Margin of dView into cMargin
   margin_Normalize cMargin, leftM, topM, rightM, bottomM
   --
   switch fHow
      case "Height"
         put the formatted_Height of dView into fWHeight
         
         put the rect of stack sName into fRect
         get item 2 of fRect + fWHeight + topM + bottomM
         put it into item 4 of fRect
         break
      case "Width"
         put the formatted_Width of dView into fWidth
         
         put the rect of stack sName into fRect
         get item 1 of fRect + fWidth + leftM + rightM
         put it into item 3 of fRect
         break
      case "Rect"
      default
         put the formatted_Rect of dView into fRect
         --
         add (leftM + rightM) to item 3 of fRect
         add (topM + bottomM) to item 4 of fRect
         break
   end switch
   return fRect
end stack_Rect

getprop formatted_Rect [fHow]
   put the formatted_Width of me into fWidth
   put the formatted_Height of me into fHeight
   --
   switch
      case fHow is a rect
      case fHow is a point
         put item 1 to 2 of fHow into sRect
         put (item 1 of sRect + fWidth) into item 3 of sRect
         put (item 2 of sRect + fHeight) into item 4 of sRect
         break
      case fHow = "local"
         put "0,0" into sRect
         put fWidth into item 3 of sRect
         put fHeight into item 4 of sRect
         break
      default
         put the rect of this stack into sRect
         put (item 1 of sRect + fWidth) into item 3 of sRect
         put (item 2 of sRect + fHeight) into item 4 of sRect
   end switch
   return sRect
end formatted_Rect

getprop formatted_Height
   # Index
   put the body_Type of me into bType
   switch bType
      case "Index"
         put the formattedheight of _IndexField() into fHeight
         break
      case "Tree"
         put the short id of _TreeWidget() into widgetID
         put the formattedHeight of widget id widgetID of me into fHeight
         break
   end switch
   
   add the height of _MenuButton() to fHeight
   get the border_Width of me
   add 2 * it to fHeight
   --
   return fHeight
end formatted_Height

getprop formatted_Width
   # Index
   put the body_Type of me into bType
   switch bType
      case "Index"
         put the index_FormattedWidth of me into bfWidth
         break
      case "Tree"
         put 192 into bfWidth
         break
   end switch
   
   # Title
   put _MenuButton() into mButton
   put the formattedwidth of mButton into mfWidth
   
   put max (bfWidth,mfWidth) into fWidth
   add 8 to fWidth
   return fWidth
end formatted_Width

getprop border_Width
   if the showborder of me is false then return 0
   return the borderwidth of me
end border_Width

setprop border_Width sWidth
   put the rect of me into oRect
   --
   lock screen
   set the borderwidth of me to sWidth
   LayoutControl oRect
   unlock screen
end border_Width

getprop index_FormattedWidth
   put _IndexField() into indexField
   put the formattedwidth of indexField into bWidth
   if the vScrollbar of indexField is true then
      put the scrollbarWidth of indexField into sWidth
      add sWidth to bWidth
   end if
   return bWidth
end index_FormattedWidth

getprop tree_FormattedHeight
   put _TreeWidget() into sObject
   put the formattedheight of sObject into bWidth
   if the vScrollbar of sObject is true then
      put the scrollbarWidth of sObject into sWidth
      add sWidth to bWidth
   end if
   return bWidth
end tree_FormattedHeight

getprop dataView_Style
   put the uOPN ["dataView_Style"] of me into sStyle
   return sStyle
end dataView_Style

setprop dataView_Style sStyle
   set the uOPN ["dataView_Style"] of me to sStyle
   --
   lock screen
   switch sStyle
      case "Index"
         set the header_IsVisible of me to true
         set the footer_IsVisible of me to false
         set the body_Type of me to "index"
         set the header_Height of me to empty
         break
      case "Simple"
         set the simple_Header of me to true
         set the footer_IsVisible of me to false
         set the body_Type of me to "index"
         break
      case "Polylist"
         set the simple_Header of me to false
         set the footer_IsVisible of me to true
         set the body_IsVisible of me to true
         set the body_Type of me to "Polylist"
         set the header_IsVisible of me to true
         set the header_Height of me to empty
         break
      case "Header"
         set the simple_Header of me to false
         set the footer_IsVisible of me to false
         set the body_IsVisible of me to false
         set the header_IsVisible of me to true
         set the header_Height of me to empty
         break
      case "Footer"
         set the footer_IsVisible of me to true
         set the body_IsVisible of me to false
         set the header_IsVisible of me to false
         set the header_Height of me to empty
         break
      case "Tree"
      default
         set the header_IsVisible of me to true
         set the footer_IsVisible of me to true
         set the body_IsVisible of me to true
         set the header_Height of me to empty
         --
         set the body_Type of me to "Tree"
         put the footer_View of me into footerView
         set the itemStyle of footerView to "icons"
   end switch
   unlock screen
end dataView_Style

getprop dataView_Styles
   put the behavior of me into bObject
   return the hkey_CaseConditions ["S dataView_Style"] of bObject
end dataView_Styles


--> View | Objects
-
getprop data_View
   return the long id of me
end data_View

getprop display_View
   return the long id of me
end display_View

getprop view_Object
   return the long id of me
end view_Object


--> Rename
-
getprop title_Text
   -- rename to "header_Text"?
   put _HeaderWidget() into headerWidget
   put the label of headerWidget into sTitle
   return sTitle
end title_Text

setprop title_Text sTitle
   -- rename to "header_Text"?
   put _HeaderWidget() into headerWidget
   set the label of headerWidget to sTitle
   --
   put _MenuButton() into mButton
   set the label of mButton to sTitle
end title_Text

getprop title_Controller
   put the uOPN ["title_Controller"] of me into mController
   if exists (mController) then return mController
   
   # Default
   put the title_Menu of me into mTitle
   put menu_GetGlobalController (mTitle) into mController
   
   if exists (mController) is false then
      put _DefaultMenuTitle() into mTitle
      put menu_GetGlobalController (mTitle) into mController
   end if
   return mController
end title_Controller

setprop title_Controller mController
   set the uOPN ["title_Controller"] of me to mController
end title_Controller

getprop title_Menu
   -- rename to menu_Title?
   return _MenuTitle()
end title_Menu

setprop title_Menu mTitle
   -- rename to menu_Title?
   set the uOPN ["title_Menu"] of me to mTitle
end title_Menu


--> Working on
-
private command _DoPoly
   -- beep
end _DoPoly

private command _DoHeaderCog
   put _MenuTitle() into mTitle
   put _MenuButton() into mButton
   mArray_PopUp mTitle, mButton
end _DoHeaderCog

private function _DefaultMouseTarget tObject
   put the title_Controller of me into mouseTarget
   if exists (mouseTarget) is true then return mouseTarget
   
   return tObject
end _DefaultMouseTarget

private function _MenuTitle
   if the controlKey is "Down" then
      return "Global | Data | Menu" -- Tool
   end if
   
   put the uOPN ["title_Menu"] of me into mTitle
   if mTitle is empty then
      put _DefaultMenuTitle() into mTitle
   end if
   return mTitle
end _MenuTitle

private function _DefaultMenuTitle
   -- put the view_Name of me into vName
   put the uRIP ["name"] of me into vName
   put menu_ConstructTitle (vName) into mTitle
   return mTitle
end _DefaultMenuTitle


--> Default
-
getprop default_ToolContext
   -- helpful in authoring menus
   put the effective filename of the defaultstack into sPath
   --
   if sPath is empty then
      # Default to module
      put the view_Name of me into vName
      if exists (stack vName) then
         return vName
      else
         return empty
      end if
   else if exists (stack sPath) then
      return the short name of stack sPath
   else
      return empty
   end if
end default_ToolContext

getprop default_TitleMenu
   return _DefaultMenuTitle()
end default_TitleMenu

getprop default_MouseTarget
   return _DefaultMouseTarget()
end default_MouseTarget

getprop default_LineMenu
   put the index_View of me into indexView
   return the default_MenuTitle of indexView
end default_LineMenu


--> Stack
-
getprop stack_Width
   put the stack_name of the target into sName
   put the width of stack sName into sWidth
   return sWidth
end stack_Width

setprop stack_Width sWidth
   put the stack_name of the target into sName
   set the width of stack sName to sWidth
   return sName
end stack_Width

getprop stack_Height
   put the stack_name of the target into sName
   put the height of stack sName into sHeight
   return sHeight
end stack_Height

setprop stack_Height [fixedPoint] sHeight
   put the stack_name of the target into sName
   switch fixedPoint
      case "centre"
         set the height of stack sName to sHeight
         break
      case "top"
      default
         put the rect of stack sName into sRect
         put item 2 of sRect + sHeight into item 4 of sRect
         set the rect of stack sName to sRect
   end switch
   return sName
end stack_Height


--> Authoring | Props
-
getprop tool_Context
   -- helpful in authoring menus
   return the uOPN ["tool_Context"] of me
end tool_Context

setprop tool_Context libName
   -- helpful in authoring menus
   set the uOPN ["tool_Context"] of me to libName
end tool_Context


--> Easy | Props
-
getprop simple_Header
   put the visible of _HeaderWidget() into hViz
   put the visible of _MenuButton() into mViz
   return mViz AND hViz is false
end simple_Header

setprop simple_Header sBoolean
   lock screen
   set the visible of _MenuButton() to sBoolean
   set the visible of _HeaderWidget() to (sBoolean is false)
   
   if sBoolean is true then
      set the header_Height of me to 36
   else
      set the header_Height of me to empty
   end if
   unlock screen
end simple_Header


--> Mouse
-
getprop mouse_Controller
   put the long id of the target into tObject
   put the uOPN ["mouse_Controller"] of me into mController
   if exists (mController) is false then
      put _DefaultMouseTarget (tObject) into mController
   end if
   return mController
end mouse_Controller

setprop mouse_Controller mController
   set the uOPN ["mouse_Controller"] of me to mController
end mouse_Controller

getprop mouse_Target [pNoDefault]
   put the uOPN ["mouse_Target"] of me into mouseTarget
   if pNoDefault is true then return mouseTarget
   --
   if exists (mouseTarget) is false then 
      put _DefaultMouseTarget() into mouseTarget
   end if
   return mouseTarget
end mouse_Target

setprop mouse_Target mouseTarget
   set the uOPN ["mouse_Target"] of me to mouseTarget
end mouse_Target

private function _DefaultMouseTarget
   put the line_Controller of me into mouseTarget
   if exists (mouseTarget) is false then
      put the long id of me into mouseTarget
   end if
   return mouseTarget
end _DefaultMouseTarget


--> Click
-
getprop click_Controller
   put the mouse_Target of me into mTarget
   if exists (mTarget) then
      return mTarget
   else
      return the long id of me
   end if
end click_Controller

getprop doubleClick_Controller
   set the uOPN ["doubleClick_Controller"] of me to sController
   if exists (sController) then
      return sController
   else
      put the line_Controller of me into sController
      return sController
   end if
end doubleClick_Controller

setprop doubleClick_Controller sController
   set the uOPN ["doubleClick_Controller"] of me to sController
end doubleClick_Controller


--> Poly
-
getprop poly_Data
   put _PolyWidget() into pWidget
   put the dataLayout of pWidget into pData ["poly_DataLayout"]
   put the dataContent of pWidget into pData ["poly_DataContent"]
   return pData
end poly_Data

setprop poly_Data pData
   put _PolyWidget() into pWidget
   lock screen
   set the dataLayout of pWidget to pData ["poly_DataLayout"]
   set the dataContent of pWidget to pData ["poly_DataContent"]
   unlock screen
end poly_Data


--> Tree
-
getprop tree_Behavior
   put the tree_View of me into treeView
   put the behavior of treeView into bObject
   return bObject
end tree_Behavior

getprop tree_Data
   put the arrayData of _TreeWidget() into sArray
   return sArray
end tree_Data

setprop tree_Data [pTitle] sArray
   put _TreeWidget() into tWidget
   lock screen
   set the arrayData of tWidget to sArray
   set the body_Type of me to "Tree"
   --
   if pTitle is not empty then
      set the title_Text of me to pTitle
   end if
   unlock screen
end tree_Data

getprop tree_View
   return _TreeWidget()
end tree_View

getprop tree_Widget
   return _TreeWidget()
end tree_Widget


--> Index
-
getprop index_Data
   return the displayed_Index of _IndexField()
end index_Data

setprop index_Data [pTitle] sIndex
   lock screen
   if pTitle is not empty then
      set the title_Text of me to pTitle
   end if
   set the displayed_Index of _IndexField() to sIndex
   set the body_Type of me to "index"
   unlock screen
end index_Data

getprop index_View
   return _IndexField()
end index_View

getprop index_Field
   return _IndexField()
end index_Field


--> Props | Body
-
getprop body_View
   return _VisibleBodyView()
end body_View

getprop body_Type
   put _ListBodyTypes() into bTypes
   repeat for each item bType in bTypes
      if exists (control bType of me) is false then next repeat
      if the visible of control bType of me is true then
         return bType
      end if
   end repeat
   return empty
end body_Type

setprop body_Type sType
   put _ListBodyTypes() into bTypes
   lock screen
   repeat for each item bType in bTypes
      if exists (control bType of me) is false then next repeat
      if bType = sType then
         set the visible of control bType of me to true
      else
         set the visible of control bType of me to false
      end if
   end repeat
   
   put _FooterWidget() into footerWidget
   if the visible of footerWidget is true then
      put the short id of footerWidget into wID
      set lockmessages to true -- not working
      set the hilitedItemName of widget id wID of me to sType -- triggered
      set lockmessages to false
   end if
   unlock screen
end body_Type

getprop body_Types
   return _ListBodyTypes()
end body_Types

getprop body_IsVisible
   put _VisibleBodyView() into bodyView
   if exists (bodyView) is false then return empty
   --
   return the visible of bodyView
end body_IsVisible

setprop body_IsVisible sBoolean
   put _VisibleBodyView() into bodyView
   if exists (bodyView) is false then
      -- put _TreeWidget() into bodyView
      return empty
   end if
   
   put the rect of me into oRect
   --
   lock screen
   set the visible of bodyView to sBoolean
   LayoutControl oRect
   unlock screen
end body_IsVisible


--> Props | Menu
-
getprop menu_Button
   return _MenuButton()
end menu_Button

-- getprop menu_Target
return the long id of me
end menu_Target

getprop menu_Controller
   return _MenuController()
end menu_Controller

setprop menu_Controller mController
   set the uOPN ["menu_Controller"] of me to mController
end menu_Controller


--> LineMenu | Props
-
getprop line_Controller
   put the index_View of me into indexView
   put the menu_Controller of indexView into lineController
   return lineController
end line_Controller

setprop line_Controller mController
   put the index_View of me into indexView
   set the menu_Controller of indexView to indexField
end line_Controller

getprop line_Menu
   put the index_View of me into indexView
   put the menu_Title of indexView into mTitle
   return mTitle
end line_Menu

setprop line_Menu mTitle
   put the index_View of me into indexView
   set the menu_Title of indexView to mTitle
end line_Menu


--> Events
-
on menuPick menuPath
   menu_TextPick menuPath
end menuPick

on mouseDown
   if the short name of the target = "_Menu Button" then
      if the shiftkey is "Down" then
         put "Global | Data | Menu" into mTitle
      else
         put _MenuTitle() into mTitle
      end if
      put _MenuButton() into mButton
      mArray_MouseDown mTitle, mButton
      --
      set the menuMode of mButton to pulldown
   end if
   pass mouseDown
end mouseDown

on mouseUp
   switch the short name of the target
      case "_Header"
         _DoHeader
         break
      case "PolyList"
         _DoPoly
         break
      case "_Footer"
         breakpoint -- never happens
         break
      default
         --
   end switch
end mouseUp

on itemClick pItemIndex, pMouseButton
   -- get the hilitedItemData of the target
   put the itemContent of the target into iData
   
   put iData ["library"] into libName
   put iData ["Associations"] into aArray
   put iData ["name"] into iName
   put iData ["Summary"] into iSummary
   put iData ["Description"] into iDescription
   --
   put iDescription
end itemClick

on resizeControl
   local sRect
   put the rect of me into sRect
   LayoutControl sRect
end resizeControl


--> Displayed | Model
-
getprop displayed_Object
   put the uOPN ["displayed_Object"] of me into dView
   if exists (dView) then
      return dView
   else
      return empty
   end if
end displayed_Object

setprop displayed_Object dView
   set the uOPN ["displayed_Object"] of me to dView
end displayed_Object

getprop displayed_Array
   return the tree_Data of me
end displayed_Array

setprop displayed_Array [pTitle] sArray
   lock screen
   set the tree_Data [pTitle] of me to sArray
   set the footer_IsVisible of me to false
   unlock screen
end displayed_Array

getprop displayed_Data [bType]
   switch dData
      case "index"
         put the index_Data [pTitle] of me into dData
         break
      case "polylist"
         put the poly_Data of me into dData
         break
      default
         put the tree_Data of me into dData
   end switch
   return dData
end displayed_Data

setprop displayed_Data [pTitle] dData
   # Duck type the data
   lock screen
   if dData is an array then
      if dData [1] is an array then
         -- set the poly_DataContent [pTitle] of me to dData
         set the footer_IsVisible of me to true
         set the displayed_Array [pTitle] of me to dData
      else
         set the displayed_Array [pTitle] of me to dData
      end if
   else
      set the footer_IsVisible of me to false
      set the index_Data [pTitle] of me to dData
   end if
   unlock screen
end displayed_Data


--> Title | Props
-
getprop title_Colour
   put the backgroundcolor of _headerWidget() into sColour
   return sColour
end title_Colour

setprop title_Colour sColour
   if sColour is "random" then
      put colour_GetRandom() into sColour
   end if
   lock screen
   set the backgroundcolor of _HeaderWidget() to sColour
   set the backgroundcolor of _MenuButton() to sColour
   unlock screen
   return sColour
end title_Colour

getprop title_TextColour
   put the foregroundcolor of _headerWidget() into sColour
   return sColour
end title_TextColour

setprop title_TextColour sColour
   if someColour is "random" then
      put colour_GetRandom() into sColour
   end if
   lock screen
   set the foregroundcolor of _HeaderWidget() to sColour
   set the hilitecolor of _HeaderWidget() to sColour
   set the foregroundcolor of _MenuButton() to sColour
   unlock screen
   return someColour
end title_TextColour


--> Menu | Dispatch
-
command menu_DispatchTextPick mItemPath
   -- simple
   put the long id of the target into tObject
   --
   put the menu_Target of tObject into mTarget
   put the menu_Controller of mTarget into mController
   
   # Construct hName
   set the itemdelimiter to "|"
   put item 1 of mItemPath into hPostFix
   replace space with empty in hPostFix
   put "menu_" & hPostFix into hName
   
   if the optionKey is "down" then
      menu_OptionAnswer hName, mController
      return "menu_OptionAnswer"
   else
      # Construct callCOmmand
      put item 2 of mItemPath into pValue
      put hName && "mTarget,pValue" into callCommand
      --
      call callCommand of mController
      return callCommand
   end if
end menu_DispatchTextPick

command menu_OptionAnswer hName, mController
   put hKeyLine_Construct (hName, "M", mController) into hKey
   mArray_OptionAnswer hKey
end menu_OptionAnswer


--> Props
-
getprop view_Name
   if the uRIP ["type"] of me is not "view" then return empty
   put the uRIP ["name"] of me into vName
   return vName
end view_Name


--> Props | Events
-
getprop drop_Command
   return the uOPN ["drop_Command"] of me
end drop_Command

setprop drop_Command dCommand
   set the uOPN ["drop_Command"] of me to dCommand
end drop_Command


--> Events | Resize
-
command LayoutControl sRect
   if the short id of the target is not the short id of me then
      get the target
      return "Error" -- resizing polyList seems to trigger
   end if
   if sRect is empty then 
      put the rect of me into sRect
   end if
   
   # Objects
   put _MenuButton() into myMenuButton
   put _PolyWidget() into pWidget
   put _BrowserWidget() into browserWidget
   put _IndexField() into indexField
   put _TreeWidget() into treeWidget
   
   put the margins of me into myMargins
   if the showborder of me is true then
      add the borderwidth of me to myMargins
   end if
   
   # Geometry
   put rect_SubtractNum (sRect, myMargins) into iRect
   --
   put _headerRect (iRect) into hRect
   put _BodyRect (iRect) into pRect
   put _footerRect (iRect) into fRect
   
   # Set Rects
   lock screen
   set the rect of _HeaderWidget() to hRect
   set the rect of myMenuButton to hRect
   set the rect of _FooterWidget() to fRect
   --
   if exists (pWidget) then
      set the rect of pWidget to pRect
   end if
   if exists (browserWidget) then
      set the rect of browserWidget to pRect
   end if
   if exists (indexField) then
      set the rect of indexField to pRect
   end if
   set the rect of treeWidget to pRect
   --
   -- set the rect of me to sRect
   unlock screen
end LayoutControl


--> Events | Drag Drop
-
on dragDrop
   _DoDrop
   pass dragDrop
end dragDrop

on dragEnter
   get the drop_Command of me
   if it is not empty then
      set the dragAction to "link" -- "none,move,copy"
   end if
   pass dragEnter
end dragEnter

on dragLeave
   if the drop_Command of me is not empty then
      set the dragAction to "none"
   end if
   pass dragLeave
end dragLeave


--> Header | Props
-
getprop header_IsVisible
   return the visible of _headerWidget()
end header_IsVisible

setprop header_IsVisible sBoolean
   put the rect of me into oRect
   --
   lock screen
   set the visible of _headerWidget() to sBoolean
   LayoutControl oRect
   unlock screen
end header_IsVisible

getprop header_Height
   return _HeaderHeight()
end header_Height

setprop header_Height sHeight
   set the uOPN ["header_Height"] of me to sHeight
   LayoutControl
end header_Height


--> Footer | Props
-
getprop footer_Height
   return _FooterHeight()
end footer_Height

setprop footer_Height sHeight
   set the uOPN ["footer_Height"] of me to sHeight
   LayoutControl
end footer_Height

getprop footer_IsVisible
   return the visible of _footerWidget()
end footer_IsVisible

setprop footer_IsVisible sBoolean
   put the rect of me into oRect
   --
   lock screen
   set the visible of _footerWidget() to sBoolean -- changes rect
   LayoutControl oRect
   unlock screen
end footer_IsVisible


--> Private
-
private function _MenuController  
   put the uOPN ["menu_Controller"] of me into mController
   if exists (mController) then return mController
   
   ## Default
   put _MenuTitle() into mTitle
   put menu_GetGlobalController (mTitle) into mController
   return mController
end _MenuController

private function _HeaderHeight
   get the uOPN ["header_Height"] of me
   if it is empty then
      return 55
   else
      return it
   end if
end _HeaderHeight

private function _ListBodyTypes
   repeat with cNum = 1 to the number of controls of me
      put the short name of control cNum of me into cName
      if cName is among the items of "_Menu Button,_Header,_Footer" then
         next repeat
      else
         put cName & comma after bodyTypes
      end if
   end repeat
   delete char -1 of bodyTypes
   return bodyTypes
end _ListBodyTypes

private command _DoHeader -- mouseUp in _HeaderWidget()
   local tActionName
   put the mouseAction of the target into tActionName
   -- put the short id of the target into wID
   -- put the mouseAction of widget id wID into tActionName
   
   switch tActionName
      case "cog"
         _DoHeaderCog
         break
      default
         -- clicked on the header-widget background
   end switch
end _DoHeader

command _DoDrop
   put the long id of me into dView
   put the drop_Command of me into dCommand
   if dCommand is empty then
      return "Error, the drop_Command is empty"
   end if
   
   put _DragData() into dData 
   put the mouse_Controller of me into mController
   if exists (mController) is false then
      dispatch dCommand to me with dView,dData
   else
      dispatch dCommand to mController with dView,dData
   end if
   return dCommand
end _DoDrop

private function _DragData
   -- horrible hack to fix dragData
   -- If you don't specify a dataType, the dragData property reports or sets the dragData["text"].
   local dData
   put the keys of the dragdata into dKeys
   repeat for each line dKey in dKeys
      put the dragData [dKey] into dData [dKey]
   end repeat
   return dData
end _DragData

private function _FooterHeight
   get the uOPN ["footer_Height"] of me
   if it is empty then
      return 40
   else
      return it
   end if
end _FooterHeight

private function _headerRect cRect
   get _HeaderHeight()
   put item 2 of cRect + it into item 4 of cRect
   return cRect
end _headerRect

private function _BodyRect cRect
   switch
      case the simple_Header of me is true
      case the visible of _HeaderWidget() is true
         get _HeaderHeight()
         add it to item 2 of cRect
   end switch
   
   if the visible of _footerWidget() is true then
      get _FooterHeight()
      subtract it from item 4 of cRect
   end if
   return cRect
end _BodyRect

private function _footerRect cRect
   get _FooterHeight()
   put item 4 of cRect - it into item 2 of cRect
   return cRect
end _footerRect

private function _HeaderWidget
   return the long id of widget "_Header" of me
end _HeaderWidget

private function _VisibleBodyView
   get _IndexField()
   if _IsVisible (it) then return it
   
   get _PolyWidget()
   if _IsVisible (it) then return it
   
   get _TreeWidget()
   if _IsVisible (it) then return it
   
   # This one should be dynamic
   get _BrowserWidget()
   if _IsVisible (it) then return it
end _VisibleBodyView

private function _IsVisible sObject
   if exists (sObject) then
      return the visible of sObject is true
   else
      return empty
   end if
end _IsVisible

private function _IndexField
   if exists (field 1 of me) then
      return the long id of field 1 of me
   else
      return empty
   end if
end _IndexField

private function _BrowserWidget
   if exists (widget "Browser" of me) then
      return the long id of widget "Browser" of me
   else
      return empty
   end if
end _BrowserWidget

private function _PolyWidget
   if exists (widget "PolyList" of me) then
      return the long id of widget "PolyList" of me
   else
      return empty
   end if
end _PolyWidget

private function _TreeWidget
   return the long id of widget "Tree" of me
end _TreeWidget

private function _FooterWidget
   return the long id of widget "_Footer" of me
end _FooterWidget

private function _MenuButton
   return the long id of btn "_Menu Button" of me
end _MenuButton


--> NotUsed
-
on toggle_Header
   put the header_IsVisible of me into sBoolean
   set the header_IsVisible of me to (sBoolean is false)
end toggle_Header


--> Deps
-
function menu_GetGlobalController mTitle, pWithModel
   if there is a stack mTitle then
      return the name of stack mTitle
   else
      return empty
   end if
end menu_GetGlobalController

function colour_GetRandom
   put random(255) into item 1 of someColour
   put random(255) into item 2 of someColour
   put random(255) into item 3 of someColour
   return someColour
end colour_GetRandom

function rect_SubtractNum sRect, pNum
   put item 1 of pNum into pNum
   if pNum is not a number then return sRect
   
   add pNum to item 1 of sRect
   add pNum to item 2 of sRect
   subtract pNum from item 3 of sRect
   subtract pNum from item 4 of sRect
   return sRect
end rect_SubtractNum
