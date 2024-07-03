script "behavior_ViewTree"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewTree
type: behavior
version: 0.2

/*
This behavior is a fork of the behavior_DisplayArray behavior used to display arrays.

--> Props | Menu
-
getprop view_EventArray eventArray   
   put the mouse_Target of me into eventArray ["eventTarget"]
   put the mouse_Up of me into eventArray ["mouseUp"]
   put the mouse_DoubleUp of me into eventArray ["mouseDoubleUp"]
   return eventArray
end view_EventArray

setprop view_EventArray eventArray   
   set the mouse_Target of me to eventArray ["eventTarget"]
   set the mouse_Up of me to eventArray ["mouseUp"]
   set the mouse_DoubleUp of me to eventArray ["mouseDoubleUp"]
end view_EventArray

getprop view_MenuArray
   put the title_Menu of me into menuArray ["title"]
   put the line_Menu of me into menuArray ["line"]
   return menuArray
end view_MenuArray

setprop view_MenuArray menuArray
   set the title_Menu of me to menuArray ["title"]
   set the line_Menu of me to menuArray ["line"]
end view_MenuArray

command menuButton_ScriptTextPick mItemPath, mButton
   # Simple version for mController = mButton (updateStyle = "script")
   put the menuButton_Title of mButton into mTitle
   put the menuBar_Owner of mButton into tObject
   put the menuButton_Target of mButton into mTarget
   
   put the menuController_Array [tObject] of mButton into mArray
   mArray_DeconstructPicked mItemPath, mArray, hName, mController, paramValue
   put the result into hKey
   
   # option Edit
   if the optionKey is "down" then
      hkey_OptionEdit hKey
      return "Option edited:" && hKey
   end if
   
   # Do mItemPath
   dispatch hName to mController with mTarget,paramValue
   --
   switch it
      case "handled"
         break -- the message was handled and not passed
      case "unhandled"
         break -- no matching handlers were found
      case "passed"
         break -- the message was handled but passed by all handlers
   end switch
end menuButton_ScriptTextPick
*/


--> Variables
-
local LocalArray
local Header_Height = 55


--> MenuController
-
getprop menuController_Array [tObject]
   # menuButton = menuController  and the menuButton_title is set
   local mArray, recursionArray
   put the long id of the target into mController
   if exists (tObject) is false then
      put the menuBar_Owner of mController into tObject
   end if
   put the menu_Target [tObject] of mController into mTarget
   put the menuButton_Title of mController into mTitle
   --
   _AddScriptMenu mArray, mTitle, tObject, mController, recursionArray, mTarget
   return mArray
end menuController_Array

getprop menu_Controller [mTitle]
   put the long id of the target into tObject
   put _MenuTitleController (mTitle, tObject) into mController
   return mController
end menu_Controller

setprop menu_Controller [pMenuTitle] mController
   put _MenuButton() into mButton
   --
   set the uOPN ["menu_Controller"] of mButton to mController
end menu_Controller

function _MenuTitleController mTitle, tObject
   -- was "_GetTopController" but changed to be logical (mButton instead of tObject)
   -- put the menu_Button of tObject into mButton
   put _MenuButton() into mButton -- Local version
   
   # Stored custom property (ie for script fork)
   put the uOPN ["menu_Controller"] of mButton into mController
   if exists (mController) then return mController
   
   # Default to stack name mTitle
   put menu_GetGlobalController (mTitle) into mController
   if exists (mController) is true then return mController
   
   return mButton
end _MenuTitleController

function menu_GetGlobalController mTitle
   if there is a stack mTitle then
      return the name of stack mTitle
   else
      return empty
   end if
end menu_GetGlobalController


--> Messy | mController
-
private function _GetNewMenuController tObject, mTitle, mController
   -- logic: global, controller (overkill logic)
   
   switch
      case word 1 of mTitle is "Global"
         # Prioritize global Menu
         put menu_GetGlobalController (mTitle) into gMenuController
         
         # Simple Recursion check hack
         if _SimpleRecursionCheck (mController, mTitle) is true then
            -- Not sure what is going on with recursion checking in general
            return empty
         end if
         
         if exists (gMenuController) is true then
            return gMenuController
         else
            return empty
         end if
         break
      case exists (mController)
         # Next the controller
         put the menu_Controller [tObject] of mController into newMenuController -- overkill logic?
         if newMenuController is empty then
            return mController
         else
            # Overriden with a getprop in the controller
            return newMenuController
         end if
         break
      default
         # mController does not exist and it's not global
         -- display_DebugHistory
         breakpoint
         return empty
   end switch
end _GetNewMenuController


--> Working on
-
private function _DefaultMenuTitle
   return "Global | Index | Simple | Menu"
end _DefaultMenuTitle

private function _DefaultMenuTarget
   return the long id of me
end _DefaultMenuTarget

getprop menuButton_UpdateStyle
   put _MenuButton() into mButton
   put the uOPN ["mUpdateStyle"] of mButton into mUpdateStyle
   if mUpdateStyle is empty then
      return "mTitle" -- default
   else
      return mUpdateStyle
   end if
end menuButton_UpdateStyle

setprop menuButton_UpdateStyle mUpdateStyle
   put _MenuButton() into mButton
   --
   set the uOPN ["mUpdateStyle"] of mButton to mUpdateStyle
   --
   switch mUpdateStyle
      case "Rev"
         breakpoint
         put the menuButton_Title of mButton into mName
         set the menuButton_RevText of mButton to mName
         set the menuButton_CachedArray of mButton to empty
         break
      case "cached"
         breakpoint
         put the menuButton_CachedArray of mButton into mArray
         _SetTextFromArray mButton, mArray
         break
      case "live"
         put the live_MenuArray of mButton into mArray
         _SetTextFromArray mButton, mArray
         break
      default
         breakpoint -- do nothing
   end switch
   
   return mButton
end menuButton_UpdateStyle

private command _SetTextFromArray mButton, mArray
   if mArray is not an array then return false
   --
   set the menuButton_CachedArray of mButton to mArray
   --
   put mArray_ToText (mArray) into mText
   set the text of mButton to mText
   set the showBorder of mButton to false
   return true
end _SetTextFromArray

getprop menuButton_UpdateStyles
   -- return "rev,cached,mTitle,live,script"
   return the hkey_CaseConditions ["M menuPick"] of stack "behavior_ViewTree" into 
end menuButton_UpdateStyles

private command _DoButtonDown
   put _MenuButton() into mButton -- set the menumode of mButton to "pulldown" -- seems to be needed!
   --
   switch
      case the controlkey is "Down"
         put _DefaultmenuTitle() into mTitle
         mArray_MouseDown mTitle, mButton -- was "mArray_PullDown"
         break
      default
         put the title_Menu of me into mTitle
         mArray_MouseDown mTitle, mButton
   end switch
end _DoButtonDown

on menuPick mItemPath
   put _MenuButton() into mButton
   put the menuButton_UpdateStyle of mButton into updateStyle
   --
   switch updateStyle
      case "cached"
         put the menuButton_CachedArray of mButton into mArray
         
         # Do menu-item
         menu_DispatchTextPick mItemPath, mArray
         
         # Update Menu
         put the live_MenuArray of mButton into mArray
         set the menuButton_CachedArray of mButton to mArray
      case "rev"
         put the short name of mButton into mName
         ide_RevMenubarMenuPick mName, mItemPath
         break
      case "script"
         -- menuButton_ScriptTextPick mItemPath, mButton
         break
      case "live"
      default
         put the live_MenuArray of mButton into mArray
         menu_DispatchTextPick mItemPath, mArray
         put the result into hKeyLine
         break
   end switch
end menuPick

command menu_DispatchTextPick mItem, pMenuArray
   if pMenuArray is not an array then
      put mArray_GetActiveArray() into pMenuArray
   end if
   --
   mArray_SetActiveItem mItem
   mArray_FindActive pMenuArray, mItem, hKey, paramValue   
   mArray_DoHkey hKey, paramValue
   return hKey
end menu_DispatchTextPick

getprop live_MenuArray
   put the long id of the target into tObject
   put _MenuButton() into mButton
   --
   put the menuButton_Target of mButton into mTarget
   put the menuButton_Title of mButton into mTitle
   if mTitle is empty then return empty
   
   # Live mData
   mArray_ClearActiveMenuArray
   menu_SetTopTargetObject tObject
   put mArray_FromTitleTable (mTitle, mTarget) into mArray
   return mArray
end live_MenuArray

getprop menuController_Array [tObject]
   local mArray, recursionArray
   --
   put the menuButton_Title of me into mTitle
   put the menu_Controller [mTitle] of the target into mController
   put the menu_Target [tObject] of mController into mTarget
   --
   _AddScriptMenu mArray, mTitle, tObject, mController, recursionArray, mTarget
   return mArray
end menuController_Array

getprop menuButton_Title
   put _MenuButton() into mButton
   --
   put the uOPN ["mTitle"] of mButton into mTitle
   return mTitle
end menuButton_Title

private command _NormTargetTitle @mTitle, @newName, tObject
   put newName into oldName
   --
   switch
      case mTitle = "Rev"
      case word 2 of newName = "Rev"
         put word 1 of newName into newName
         if rev_CheckMenuName (newName) is false then
            return "Error, newName is not rev menu"
         end if
         put "Rev" into mTitle
         break
      default
         put the normalized_TitleArray [mTitle] of tObject into normArray
         put normArray ["mTitle"] into mTitle
         if mTitle is empty then return "Error, mTitle is empty"
         put _NameFrom (newName, mTitle) into newName
   end switch
   --
   return oldName
end _NormTargetTitle

private function _NameFrom numOrName, mTitle
   switch
      case numOrName is empty
         -- put mTitle into mName
         set the itemdelimiter to "|"
         put word 1 to -1 of item -2 of mTitle into mName
         break
      case numOrName is a number
         put empty into numOrName
         break
         -- case (the number of words of numOrName = 2) AND (word -1 of numOrName = "Rev")
         -- put word 1 of numOrName into mName
         -- break
      default
         put numOrName into mName
   end switch
   return mName
end _NameFrom

setprop menuButton_Title mTitle
   put _MenuButton() into mButton
   
   # Normalize mTitle
   _NormTargetTitle mTitle, mName, mButton
   if item 1 of the result = "Error" then return empty
   
   # Construct Live  mData
   try
      set the uOPN ["mTitle"] of mButton to mTitle
      set the uOPN ["mUpdateStyle"] of mButton to "mTitle"
      --
      put the live_MenuArray of mButton into mData
   catch sError
      put mTitle into bArray ["mTitle"]
      put revRuggedID (mButton) into bArray ["mUpdateStyle"]
      put "mTitle" into bArray ["mButton"]
      --
      breakpoint -- put error display away from deps
      return empty
   end try
   
   # Set Menu Text
   put mData ["mArray"] into mArray
   put mArray_ToText (mArray) into mText
   set the text of mButton to mText
   
   # Set cache
   set the menuButton_CachedArray of mButton to mArray
   
   return mData
end menuButton_Title

getprop menuButton_Target
   put _MenuButton() into mButton
   --
   put the uOPN ["mTarget"] of mButton into mTarget
   if exists (mTarget) is false then
      put _DefaultMenuTarget() into mTarget
   end if
   return mTarget
end menuButton_Target

setprop menuButton_Target mTarget
   put _MenuButton() into mButton
   --
   set the uOPN ["mTarget"] of mButton to mTarget
   return the result
end menuButton_Target

getprop menuButton_CachedArray
   put _MenuButton() into mButton
   --
   put the uOPN ["cachedArray"] of mButton into mArray
   return mArray
end menuButton_CachedArray

setprop menuButton_CachedArray mArray
   put _MenuButton() into mButton
   --
   set the uOPN ["cachedArray"] of mButton to mArray
   return empty
end menuButton_CachedArray


--> Objects | Illegal (for script widget)
-
getprop tree_IsIndex
   return LocalArray ["isIndex"] is true
end tree_IsIndex

getprop tree_Widget
   put _TreeWidget() into treeWidget
   return treeWidget
end tree_Widget

getprop menu_Button
   return _MenuButton()
end menu_Button

getprop title_View
   put _HeaderWidget() into headerWidget
   return headerWidget
end title_View

getprop header_Widget
   put _HeaderWidget() into headerWidget
   return headerWidget
end header_Widget


--> Events
-
on preOpenControl
   pass preOpenControl
end preOpenControl

on mouseDown
   switch word 1 of the name of the target
      case "button"
         _DoButtonDown
         break
      case "field"
         _DoFieldDown
         break
   end switch
end mouseDown

on mouseDoubleUp
   breakpoint -- not issued to either widget
end mouseDoubleUp

on mouseUp
   ## Only when the user click on the header
   -- tree widget does not send to mouseUp
   local tActionName
   put the long id of the target into headerWidget
   put the mouseAction of headerWidget into tActionName
   	
   switch tActionName
      case "cog"
         put the clickloc into pLocation
         add 2 to item 1of pLocation
         add 4 to item 2 of pLocation
         --
         put the title_Menu of me into mTitle
         put _MenuButton() into mButton
         --
         try
            mArray_PopUp mTitle, mButton
         catch sError
            mArray_PopUp "Global | Module | Error | Menu", mButton
         end try
      default
         # Clicked on the title
         if the shiftkey is "Down" then
            set the title_Colour of me to colour_GetRandom()
            put the stack_Style of me into oStyle
            switch oStyle
               case "toplevel"
                  set the stack_Style of me to "palette"
                  break
               case "palette"
                  set the stack_Style of me to "toplevel"
                  break
               default
                  put oStyle
                  breakpoint
            end switch
         end if
   end switch
end mouseUp

on actionInspect pPath
   put _GetValue (pathItems) into someValue
   put the mouse_Up of me into mouseUpCommand
   if mouseUpCommand is empty then
      pass actionInspect
   else
      _SetMouseTargets tObject, displayView, mouseTarget
      dispatch mouseUpCommand to mouseTarget with displayView,someValue
   end if
end actionInspect

on hiliteChanged
   -- hack - cant stop the flicker when selecting line that is already selected
   -- called twice due to "set the hilitedElement"
   -- lock messages makes no difference
   if LocalArray ["just set hilitedElement"] is true then
      put false into LocalArray ["just set hilitedElement"]
      return empty
   end if
   
   put _TreeWidget() into treeWidget
   put the hilitedElement of treeWidget into pathItems
   if pathItems is empty then
      put LocalArray ["previousHilitedElement"] into pathItems
      set the hilitedElement of treeWidget to pathItems
      put true into LocalArray ["just set hilitedElement"]
   else
      put pathItems into LocalArray ["previousHilitedElement"]
      put false into LocalArray ["just set hilitedElement"]
   end if
   
   if the controlKey is "Down" then
      put the line_Menu of me into mTitle
      _NormalizeLineMenu mTitle
      --
      if the shiftKey is "Down" then
         put "Global | Array | Line | Menu" into defaultLineMenu
         if mTitle is not defaultLineMenu then
            put defaultLineMenu & tab & "submenu" & tab & "Error" & CR & "-" & CR before mTitle
         end if
      end if
      --
      put _MenuButton() into mButton
      mArray_PopUp mTitle, mButton
   else
      _displaySelectedValue treeWidget
   end if
end hiliteChanged

command actionDoubleClick pathItems
   -- not called
   put the selected_Value of me into someValue
   put the mouse_DoubleUp of me into mouseDoubleUpCommand
   if mouseDoubleUpCommand is empty then
      pass actionDoubleClick
   else
      _SetMouseTargets tObject, displayView, mouseTarget
      replace comma with CR in pathItems
      dispatch mouseDoubleUpCommand to mouseTarget with displayView,someValue,pathItems
      if it is "unhandled" then
         edit the script of mouseTarget
         put mouseDoubleUpCommand
      end if
   end if
end actionDoubleClick


--> Events | Drag Drop
-
on dragDrop
   put the drop_Command of me into dropCommand
   --
   -- put the dragdata ["files"] into someValue
   put the dragdata ["text"] into someValue
   --
   if dropCommand is empty then
      pass dragDrop
   else
      put the long id of the target into displayView
      put the mouse_Target of me into mouseTarget
      if exists (mouseTarget) is false then put displayView into mouseTarget
      dispatch dropCommand to mouseTarget with displayView,someValue
   end if
   --
   pass dragDrop -- needed for drop to occur
end dragDrop

on dragEnter -- show a green outline around the drop target
   set the allowableDragActions to "link"
   set the dragAction to "Link"
   pass dragEnter
end dragEnter

on dragLeave
   -- set the borderColor of the target to ""
   pass dragLeave
end dragLeave


--> Props | Event
-
getprop mouse_DoubleUp
   return the mouse_DoubleUp of me
end mouse_DoubleUp

setprop mouse_DoubleUp mDoubleUp
   set the mouse_DoubleUp of me to mDoubleUp
end mouse_DoubleUp

getprop mouse_Target
   put the long id of the target into tObject
   put the mouse_Target of me into mTarget
   if exists (mTarget) is false then
      put _DefaultMouseTarget (tObject) into mTarget
   end if
   return mTarget
end mouse_Target

setprop mouse_Target mTarget
   set the mouse_Target of me to mTarget
end mouse_Target

getprop menu_Target [mTitlePath]
   put the menu_Target of me into mTarget
   --
   put the displayed_Object of me into displayedObject
   switch 
      case mTarget is not empty
         return mTarget
      case displayedObject is not empty
         return displayedObject
      default
         return the long id of me
   end switch
end menu_Target

setprop menu_Target [mTitlePath] mTarget
   set the menu_Target of me to mTarget
end menu_Target

getprop title_Controller
   put the title_Controller of me into mController
   if exists (mController) then return mController
   
   ## Default
   put the title_Menu of me into titleMenu
   set the menu_Controller [titleMenu] of me to mController
   return mController
end title_Controller

getprop line_Controller
   put the line_Controller of me into mController
   if exists (mController) then return mController
   
   ## Default
   put the line_Menu of me into lineMenu
   put the menu_Controller [lineMenu] of me into mController
   return mController
end line_Controller


--> Geometry
-
getprop header_Height
   return Header_Height
end header_Height

setprop header_Height sHeight
   if sHeight is not a number then return "Error, height is not a number"
   put the rect of me into vRect
   
   lock screen
   put sHeight into Header_Height
   LayoutControl vRect
   unlock screen
end header_Height

private function _headerHeight
   return Header_Height
end _headerHeight

private function _headerRect stackRect
   put item 2 of stackRect + _headerHeight() into item 4 of stackRect
   return stackRect
end _headerRect

private function _fieldRect stackRect
   add _headerHeight() to item 2 of stackRect
   subtract _footerHeight() from item 4 of stackRect
   return stackRect
end _fieldRect

private function _footerRect stackRect
   put item 4 of stackRect - _footerHeight() into item 2 of stackRect
   return stackRect
end _footerRect

private function _footerHeight
   if the show_Footer of me is true then
      return 40
   else
      return 0
   end if
end _footerHeight


--> Event | Handlers
-
private command _DoFieldDown
   put word 2 of the clickline into cNum
   if the controlkey is "Down" then
      set the hilitedlines of the target to cNum
      put the line_Menu of me into lineTitle
      
      # Option Edit
      put the line_Controller [lineTitle] of me into mController
      if exists (mController) is false then
         dispatch "ask_CreateTreeFieldMenu" to me with lineTitle
      else
         put the menu_Button of me into mButton
         mArray_PopUp lineTitle, mButton
      end if
   else
      put the drop_Command of me into dCommand
      if dCommand is empty then return false
      
      put the selectedtext of the target into someText
      -- set the dragImage to 3137
      set the dragAction to "copy"
      set the dragData ["text"] to someText
      return true
   end if
end _DoFieldDown


--> Props | Show
-
getprop show_Field
   return the visible of _IndexField()
end show_Field

setprop show_Field someBoolean
   put the rect of me into vRect
   
   lock screen
   set the visible of _IndexField() to someBoolean
   set the visible of _MenuButton() to someBoolean
   --
   set the visible of _HeaderWidget() to (someBoolean is false)
   set the visible of _TreeWidget() to (someBoolean is false)
   --
   if someBoolean is true then
      put 40 into Header_Height
   else
      put 55 into Header_Height
   end if
   LayoutControl vRect
   unlock screen
end show_Field

getprop show_Footer
   return the visible of _FooterWidget()
end show_Footer

setprop show_Footer someBoolean
   put the rect of me into vRect
   
   lock screen
   set the visible of _FooterWidget() to someBoolean
   LayoutControl vRect
   unlock screen
end show_Footer

getprop show_Separator
   put _TreeWidget() into treeWidget
   return the showSeparator of treeWidget
end show_Separator

setprop show_Separator sBoolean
   put _TreeWidget() into treeWidget
   set the showSeparator of treeWidget to sBoolean
   return treeWidget
end show_Separator

getprop show_Values
   put _TreeWidget() into treeWidget
   return the showValues of treeWidget
end show_Values

setprop show_Values sBoolean
   put _TreeWidget() into treeWidget
   set the showValues of treeWidget to sBoolean
   return treeWidget
end show_Values

getprop show_Numbers
   put _TreeWidget() into treeWidget
   put the charsToTrimFromKey of treeWidget into sNum
   return sNum = 0
end show_Numbers

setprop show_Numbers sBoolean
   put _TreeWidget() into treeWidget
   
   lock screen
   if sBoolean is true then
      set the charsToTrimFromKey of treeWidget to 0
      set the separatorRatio of treeWidget to 0.3
   else
      set the charsToTrimFromKey of treeWidget to 2
      set the separatorRatio of treeWidget to 0
   end if
   unlock screen
end show_Numbers


--> Private | Objects
-
private function _MenuButton
   return the long id of btn "_MenuButton" of me
   -- if exists (stack "View|Index|Simple") is false then return empty
   -- put the long id of btn 1 of cd 1 of stack "View|Index|Simple" into mButton
end _MenuButton

private function _IndexField
   put the long id of field 1 of me into indexField
   return indexField
end _IndexField

private function _HeaderWidget
   put the long id of widget "_Header" of me into headerWidget
   return headerWidget
end _HeaderWidget

private function _TreeWidget
   put the long id of widget "_Tree" of me into arrayWidget
   return arrayWidget
end _TreeWidget

private function _FooterWidget
   put the long id of widget "_Footer" of me into footerWidget
   return footerWidget
end _FooterWidget


--> Layout
-
on resizeControl
   put the rect of me into vRect
   LayoutControl vRect
end resizeControl

command LayoutControl pRect
   if pRect is empty then put the rect of me into pRect
   
   lock screen
   put the inner_Rect [pRect] of me into pRect
   rect_SubtractMargins pRect
   
   # Header
   put _HeaderRect (pRect) into headerRect
   set the rect of _HeaderWidget() to headerRect
   set the rect of _MenuButton() to headerRect
   
   # Middle
   put _fieldRect (pRect) into fieldRect
   set the rect of _TreeWidget() to fieldRect
   set the rect of _IndexField() to fieldRect
   
   # Footer
   set the rect of _FooterWidget() to _footerRect (pRect)
   unlock screen
end LayoutControl


--> Props | Menu | Model
-
getprop title_Menu
   if the controlKey is "Down" then
      return "Global | Array | Menu"
   end if
   
   set the title_Menu of me to "Global | Tree | Menu"
   put the title_Menu of me into titleMenu   
   if titleMenu is empty then 
      return "Global | Tree | Menu"
   else
      return titleMenu
   end if
end title_Menu

setprop title_Menu mName
   set the title_Menu of me to mName
end title_Menu

getprop line_Menu
   put the line_Menu of me into mTitle
   return mTitle
end line_Menu

setprop line_Menu mName
   set the line_Menu of me to mName
end line_Menu


--> Props
-
getprop title_Text
   put _HeaderWidget() into headerWidget
   put the label of headerWidget into displayTitle
   return displayTitle
end title_Text

setprop title_Text displayTitle
   put _HeaderWidget() into headerWidget
   set the label of headerWidget to displayTitle
end title_Text

getprop chars_ToTrim
   put the charsToTrimFromKey of _TreeWidget() into padNum
   return padNum
end chars_ToTrim

setprop chars_ToTrim padNum
   put _TreeWidget() into treeWidget
   set the charsToTrimFromKey of treeWidget to padNum
   return treeWidget
end chars_ToTrim

getprop selected_TopData [sPath]
   -- returns the topKey and not just the contents of the array
   if sPath is empty then
      _SetTop topKey, aData
      put aData [topKey] into topData [topKey]
   else
      put the arrayData of _TreeWidget() into aData
      split sPath with comma
      put aData [sPath] into topData
   end if
   return topData
end selected_TopData

getprop top_Data [pathNum]
   -- put the selected_TopData of me into topData
   put _TreeWidget() into treeWidget
   --
   put the arrayData of treeWidget into aData
   put the hilitedElement of treeWidget into commaPath
   if pathNum is a number then
      -- subtract 1 from pathNum
      put item 1 to pathNum of commaPath into topPath
      split topPath with comma
      put aData [topPath] into topData
   else
      put item 1 of commaPath into topKey
      put aData [topKey] into topData [topKey]
   end if
   return topData
end top_Data

getprop selected_Array
   put _TreeWidget() into treeWidget
   
   put the hilitedElement of treeWidget into commaKeys
   put the arrayData of treeWidget into someArray
   split commaKeys with comma
   put someArray [commaKeys] into selectedValue
   return selectedValue
end selected_Array

setprop tool_MenuBit [projectName] menuBit
   -- used to use "display_SetToolMenus"
   put _MenuButton() into mButton
   --
   set the menumode of mButton to "pulldown"
   set the style of mButton to "menu"
   
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
   set the line_Menu of me to lineMenu
   set the mouse_DoubleUp of me to mDoubleUp
   
   # Create menus if needed
   dispatch "ask_CreateMenuFromObject" to me with titleMenu,projectName
   
   if the optionKey is "Down" then
      dispatch "ask_CreateMenuFromObject" to me with lineMenu,projectName
      dispatch "ask_CreateMouseDoubleUpHandler" to me with mDoubleUp
   end if
   --
   return titleMenu
end tool_MenuBit

getprop tool_MenuBit
   get the title_Menu of me
   set the itemdelimiter to "|"
   put word 1 to -1 of item 2 to -2 of it into menuBit
   return menuBit
end tool_MenuBit


getprop parent_Array [someKey]
   put _TreeWidget() into treeWidget
   
   put the hilitedElement of treeWidget into commaKeys
   if the number of items of commaKeys = 1 then
      return the displayed_Array of me
   end if
   --
   delete item -1 of commaKeys
   put the arrayData of treeWidget into someArray
   split commaKeys with comma
   put someArray [commaKeys] into pArray
   --
   if someKey is empty then
      return pArray
   else
      return pArray [someKey]
   end if
end parent_Array


--> Props | Top
-
getprop top_Key
   return _GetTopKey()
end top_Key

getprop top_Line [pathItemNum]
   put _TreeWidget() into treeWidget
   if pathItemNum is empty then put 1 into pathItemNum
   --
   put the hilitedElement of treeWidget into commaPath
   put item pathItemNum of commaPath into topLine
   return topLine
end top_Line

getprop top_LineKeys
   -- sorts alphabetically the keys
   -- assumes the display does the same?
   
   put the top_Data of me into topArray
   put the keys of topArray into topKeys
   sort topKeys
   return topKeys
end top_LineKeys

getprop trim_Num
   get the charsToTrimFromKey of _TreeWidget()
   return it
end trim_Num

setprop trim_Num sNum
   set the charsToTrimFromKey of _TreeWidget() to sNum
end trim_Num

getprop max_LineNum
   put the displayed_Index of me into dLines
   return the number of lines of dLines
end max_LineNum


--> Model
-
getprop displayed_Data
   if LocalArray ["isIndex"] is true then
      return the displayed_Index of me
   else
      put tree_GetData() into treeData
      return treeData
   end if
end displayed_Data

setprop displayed_Data [someTitle] sData
   lock screen
   if sData is an array then
      set the arrayData of _TreeWidget() to sData
      set the show_Values of me to true
      set the show_Numbers of me to true
      put false into LocalArray ["isIndex"]
   else
      set the displayed_Index of me to sData
   end if
   if someTitle is not empty then
      set the title_Text of me to someTitle
   end if
   unlock screen
end displayed_Data

getprop displayed_Index
   put the arrayData of _TreeWidget() into someArray
   put keys (someArray) into someIndex
   sort lines of someIndex
   return someIndex
end displayed_Index

setprop displayed_Index [someTitle] someIndex
   lock screen
   repeat for each line someLine in someIndex
      put empty into someArray [someLine]
   end repeat
   --
   set the arrayData of _TreeWidget() to someArray
   set the show_Values of me to false
   set the show_Numbers of me to true
   --
   if someTitle is not empty then
      set the stack_Title of me to someTitle
   end if
   unlock screen
   put true into LocalArray ["isIndex"]
end displayed_Index


--> Props | Events | Custom
-
getprop drop_Command
   return the drop_Command of me
end drop_Command

setprop drop_Command dropCommand
   set the drop_Command of me to dropCommand
end drop_Command

getprop mouse_Up
   return the mouse_Up of me
end mouse_Up

setprop mouse_Up mUp
   set the drop_Command of me to mUp
end mouse_Up


--> Props | Array | ViewData
-
getprop view_Data [someKey]
   put the view_Data of me into viewData
   if someKey is empty then return viewData
   return viewData [someKey]
end view_Data

setprop view_Data [someKey] someData   
   if someKey is empty then
      set the view_Data of me to someData
   else
      put the view_Data of me into viewData
      put someData into viewData [someKey]
      set the view_Data of me to viewData
   end if
end view_Data


--> Expanded
-
getprop expanded_Paths
   put the foldState of _TreeWidget() into foldedArray
   repeat for each key someKey in foldedArray
      if foldedArray [someKey]["folded"] is false then
         put someKey & comma after ePaths
      end if 
   end repeat
   delete char -1 of ePaths
   return ePaths
end expanded_Paths

setprop expanded_Paths [pAddState] ePaths
   put display_ConstructFoldState (ePaths) into foldedArray
   set the fold_State [pAddState] of me to foldedArray
   return foldedArray
end expanded_Paths

getprop fold_State
   put the foldState of _TreeWidget() into foldedArray
   return foldedArray 
end fold_State

setprop fold_State [pAddState] foldedArray
   -- sensitive to capitalisation
   put _TreeWidget() into tWidget
   --
   if pAddState is true then
      get the foldState of tWidget
      union foldedArray with it
   end if
   --
   -- put the autoFoldStateReset of tWidget
   set the foldState of tWidget to foldedArray
   return the result
end fold_State


--> Props | Array
-
getprop index_Array
   put the view_Data of me into indexArray
   return indexArray
end index_Array

setprop index_Array [pIndexKey] indexArray
   put indexArray_List (indexArray, pIndexKey) into sLines
   -- 
   set the displayed_Index of me to sLines
   set the view_Data of me to indexArray
   --
   return sLines
end index_Array

getprop top_Array [pKey]
   -- selected_TopArray
   _SetTop topKey, aData
   if pKey is empty then
      return aData [topKey]
   else
      return aData [topKey][pKey]
   end if
end top_Array

setprop top_Array [pPath] sArray
   put _GetTopKey() into topKey
   tree_SetArray sArray, topKey
   --
   put the result into arrayData
   return arrayData
end top_Array

setprop tree_Array [pPath] sArray
   tree_SetArray sArray, pPath
   --
   put the result into arrayData
   return arrayData
end tree_Array

setprop deleted_Path somePath
   tree_DeletePath somePath
end deleted_Path

setprop deleted_Line somePath
   tree_DeletePath somePath
end deleted_Line


--> Props | Selected
-
getprop selected_LineNumber
   return the selected_LineNum of me
end selected_LineNumber

setprop selected_LineNumber lineNum
   set the selected_LineNum of me to lineNum
end selected_LineNumber

getprop selected_LineNum
   -- just top-level lines and assume
   put the selected_Line of me into topLine
   
   set the wholematches to true
   put _SortedTopKeys() into topKeys
   put lineoffset (topLine, topKeys) into topLineNum
   
   return topLineNum
end selected_LineNum

setprop selected_LineNum textOrNumber
   if textOrNumber is a number then
      breakpoint -- fix: not sure how to handle this
   end if
   set the hilited_Element of me to lineNum
end selected_LineNum

getprop selected_Path
   put _TreeWidget() into treeWidget
   put the hilitedElement of treeWidget into commaPath
   if char -1 of commaPath is comma then delete char -1 of commaPath
   return commaPath
end selected_Path

setprop selected_Path commaPath
   put _TreeWidget() into treeWidget
   set the hilitedElement of treeWidget to commaPath
   return treeWidget
end selected_Path

getprop selected_Line
   put _TreeWidget() into treeWidget
   --
   put the hilitedElement of treeWidget into commaPath
   put the pathDelimiter of treeWidget into pDelim
   --
   set the itemdelimiter to pDelim
   put item -1 of commaPath into sLine
   return sLine
end selected_Line

setprop selected_Line commaPath
   put _TreeWidget() into treeWidget
   set the scrollHilitedElementIntoView of treeWidget to true
   set the hilitedElement of treeWidget to commaPath
   --
   put item 1 of commaPath into topLine
   set the wholematches to true
   put _SortedTopKeys() into topKeys
   put lineoffset (topLine, topKeys) into topLineNum
   --
   return topLineNum -- only works for top lines
end selected_Line

getprop selected_Value
   put _TreeWidget() into treeWidget
   
   put the hilitedElement of treeWidget into commaKeys
   put item -1 of commaKeys into lastComma
   
   put the arrayData of treeWidget into someArray
   split commaKeys with comma
   put someArray [commaKeys] into selectedValue
   if selectedValue is empty then
      return lastComma
   else
      return selectedValue
   end if
end selected_Value

getprop top_Lines
   put _TreeWidget() into treeWidget
   --
   put the arrayData of treeWidget into someData
   --
   put keys (someData) into topLines
   if the sortType of treeWidget is "text" then
      if the sortOrder of treeWidget is "ascending" then
         sort ascending lines of topLines
      else
         sort descending lines of topLines
      end if
   else
      sort numeric lines of topLines
   end if
   return topLines
end top_Lines


--> Props | Stack
-
getprop stack_Title
   put word 1 to -1 of the title_Text of me into stackTitle
   put word 1 to -1 of the stack_Label of me into stackLabel
   if stackLabel is not empty then put stackLabel into item 2 of stackTitle
   return stackTitle
end stack_Title

setprop stack_Title stackTitle
   put word 1 to -1 of item 1 of stackTitle into titleText
   put word 1 to -1 of item 2 of stackTitle into stackLabel
   --
   lock screen
   set the title_Text of me to titleText
   if stackLabel is not empty then
      set the stack_Label of me to stackLabel
   end if
   unlock screen
   --
   return the long id of me
end stack_Title

getprop stack_Label
   put the label of the defaultstack into stackLabel
   return stackLabel
end stack_Label

getprop stack_Label stackLabel
   put the defaultstack into myStackObject
   set the label of myStackObject to stackLabel
   return myStackObject
end stack_Label


--> Props | Hilited
-
getprop hilited_Element
   return the selected_Path of me
end hilited_Element

setprop hilited_Element commaPath
   set the selected_Path of me to commaPath
end hilited_Element

getprop hilited_Line
   return the selected_LineNum of me
end hilited_Line

setprop hilited_Line lineNum
   set the hilited_Element of me to lineNum
end hilited_Line


--> Props | Title
-
getprop tree_SortType
   put _TreeWidget() into treeWidget
   put the sortType of treeWidget into treeSortType
   return treeSortType
end tree_SortType

setprop tree_SortType treeSortType
   put _TreeWidget() into treeWidget
   set the sortType of treeWidget to treeSortType
   return treeWidget
end tree_SortType

getprop tree_SortTypes
   return "text,numeric"
end tree_SortTypes

getprop title_Colour
   put the backgroundcolor of _HeaderWidget() into someColour
   return someColour
end title_Colour

setprop title_Colour someColour
   if someColour is "random" then
      put colour_GetRandom() into someColour
   end if
   set the backgroundcolor of _HeaderWidget() to someColour
   return someColour
end title_Colour

getprop title_TextColour
   put the foregroundcolor of _HeaderWidget() into someColour
   return someColour
end title_TextColour

setprop title_TextColour someColour
   if someColour is "random" then
      put colour_GetRandom() into someColour
   end if
   set the foregroundcolor of _HeaderWidget() to someColour
   return someColour
end title_TextColour


--> Props | Data
-
getprop displayed_Object
   put the displayed_Object of me into sObject
   if exists (sObject) then
      return sObject
   else
      return the long id of em
   end if
end displayed_Object

setprop displayed_Object sObject
   set the displayed_Object of me to sObject
end displayed_Object

getprop displayed_Array [pathItems]
   -- compatibility with old treeView
   put the displayed_Data of me into someArray
   if pathItems is empty then return someArray
   
   split pathItems with comma
   put someArray [pathItems] into someValue
   return someValue
end displayed_Array

setprop displayed_Array [someTitle] someArray
   -- compatibility with old treeView
   set the displayed_Data [someTitle] of me to someArray
end displayed_Array


--> Objects
-
getprop view_Object
   return the long id of me
end view_Object

getprop array_View
   return the long id of me
end array_View

getprop display_View
   return the long id of me
end display_View


--> Objects | Compatibility
-
getprop tree_Field
   -- for compatibility (experimental)
   return _TreeWidget()
end tree_Field

getprop tree_View
   -- for compatibility (experimental)
   return the long id of me
end tree_View


--> Private | TreeData
-
private function treeData_GetArray treeData, somePath
   split somePath by comma
   put treeData [somePath] into sArray
   return sArray
end treeData_GetArray

private command treeData_SetArray @treeData, somePath, sArray
   split somePath by comma
   put sArray into treeData [somePath]
end treeData_SetArray

private command treeData_Delete @treeData, somePath
   split somePath by comma
   put treeData [somePath] into deletedData
   delete variable treeData [somePath]
   return deletedData
end treeData_Delete


--> Private
-
private command tree_SetArray sArray, pPath
   put _TreeWidget() into treeWidget
   if pPath is empty then
      put the hilitedElement of treeWidget into pPath
   end if
   --
   put the arrayData of treeWidget into treeData
   treeData_SetArray treeData, pPath, sArray
   set the arrayData of treeWidget to treeData
   --
   return arrayData
end tree_SetArray

private function _GetTopKey
   put _TreeWidget() into treeWidget
   put the hilitedElement of treeWidget into commaPath
   put item 1 of commaPath into topKey
   return topKey
end _GetTopKey

private command _SetTop @topKey, @aData
   put _TreeWidget() into treeWidget
   put the arrayData of treeWidget into aData
   put the hilitedElement of treeWidget into commaPath
   --
   put item 1 of commaPath into topKey
   return commaPath
end _SetTop

private command _displaySelectedValue pTreeWidget
   if pTreeWidget is empty then put _TreeWidget() into pTreeWidget
   put the selected_Value of pTreeWidget into selectedValue
   
   dispatch "tree_HilightChanged" to me with selectedValue
end _displaySelectedValue

private function tree_GetData
   put the arrayData of _TreeWidget() into treeData
   return treeData
end tree_GetData

private command tree_SetData treeData
   set the arrayData of _TreeWidget() to treeData
end tree_SetData

private command _NormalizeLineMenu @lineMenuTitle
   switch
      case lineMenuTitle is empty
         put "Global | Array | Line | Menu" into lineMenuTitle
         break
      case _LineMenuControllerExists (lineMenuTitle)
         break
      default
         put "Global | Array | Line | Menu" into lineMenuTitle
         
         # Ask to create here
   end switch
end _NormalizeLineMenu

private function _LineMenuControllerExists lineMenuTitle
   put the menu_Controller [lineMenuTitle] of me into mController
   return exists (mController)
end _LineMenuControllerExists

private command tree_DeletePath somePath
   put _TreeWidget() into treeWidget
   --
   put the arrayData of treeWidget into treeData
   treeData_Delete treeData, somePath
   put the result into deletedData
   set the arrayData of treeWidget to treeData
   --
   return deletedData
end tree_DeletePath

private command _SetMouseTargets @tObject, @displayView, @mouseTarget
   put the long id of the target into tObject
   put the long id of me into displayView
   put the mouse_Target of me into mouseTarget
   if exists (mouseTarget) is false then
      put _DefaultMouseTarget (tObject) into mouseTarget
   end if
end _SetMouseTargets

private function _DefaultMouseTarget tObject
   put the line_Controller of me into mouseTarget
   if exists (mouseTarget) is false then
      put tObject into mouseTarget
   end if
   return mouseTarget
end _DefaultMouseTarget

private function _GetValue pathItems
   put the displayed_Array of me into someArray
   split pathItems with comma
   put someArray [pathItems] into someValue
   return someValue
end _GetValue

function _SortedTopKeys
   put the displayed_Data of me into myData
   put keys (myData) into topKeys
   
   put _TreeWidget() into treeWidget
   put the sortOrder of treeWidget into sOrder
   put the sortType of treeWidget into sType
   
   switch sType
      case "numeric"
         if sOrder = "ascending" then
            sort numeric ascending topKeys
         else
            sort numeric descending topKeys
         end if
         break
      default
         if sOrder = "ascending" then
            sort ascending topKeys
         else
            sort descending topKeys
         end if
   end switch
   return topKeys
end _SortedTopKeys


--> Deps | Original
-
function indexArray_List indexArray, pNameKey
   if pNameKey is empty then put "name" into pNameKey
   repeat with indexNum = 1 to item 2 of the extents of indexArray
      put indexArray [indexNum][pNameKey] into sLine
      put sLine & CR after sLines
   end repeat
   delete char -1 of sLines
   return sLines
end indexArray_List

command lcw_Notify someMessage, pTitle, pMergeValue
   -- needs to work cross platform
   replace quote with empty in someMessage
   replace "'" with empty in someMessage
   text_ReQuote someMessage, pMergeValue
   --
   try
      if pTitle is empty then put "LiveCode World Notification" into pTitle
      put "osascript -e" && "'" & "display notification" && quote & someMessage & quote into someShell
      put "with title" && quote & pTitle & quote after someShell
      put "'" after someShell
      put shell (someShell) into shellResult
   catch e
      put someMessage
   end try
end lcw_Notify

command mArray_MouseDown mTitle, pMenuButton, pTargetObject
   if pTargetObject is empty then
      put the long id of the target into pTargetObject
   end if
   if pMenuButton is empty then
      -- defaults to the target not menu_Button
      put pTargetObject into pMenuButton
   end if
   --
   mArray_ClearActiveMenuArray
   menu_SetTopTargetObject pTargetObject
   --
   switch word 1 of pMenuButton
      case "button"
         put mArray_FromTitleTable (mTitle, pTargetObject) into mArray
         put mArray_ToText (mArray) into mText
         set the text of pMenuButton to mText
         return mArray
      case "widget"
         break
      default
         exit to top
   end switch
end mArray_MouseDown

command mArray_PopUp mTitle, pMenuButton, pTargetObject
   _SetMenuObjectDefaults pTargetObject, pMenuButton
   --
   mArray_MouseDown mTitle, pMenuButton, pTargetObject
   put the result into mArray
   --
   popup pMenuButton -- target changes
   return mArray
end mArray_PopUp

command mArray_PullDown mTitle, pMenuButton, pTargetObject
   _SetMenuObjectDefaults pTargetObject, pMenuButton
   --
   mArray_MouseDown mTitle, pMenuButton, pTargetObject
   put the result into mArray
   --
   put the bottomleft of pTargetObject into popLoc
   add 3 to item 2 of popLoc
   --
   popup pMenuButton at popLoc
   return mArray
end mArray_PullDown

setprop stack_Label someLabel
   put the stack_Object of the target into stackObject
   set the label of stackObject to someLabel
   return stackObject
end stack_Label

getprop stack_Name
   return the short name of the defaultstack
end stack_Name

getprop stack_Object
   -- revTargetStack
   return the defaultstack
end stack_Object

getprop stack_Style
   put the stack_Name of the target into stackName
   put the systemwindow of stack stackName into someBoolean
   if someBoolean is true then return "system"
   
   put the style of stack stackName into sStyle
   return sStyle
end stack_Style

setprop stack_Style sStyle
   put the stack_Name of the target into stackName
   if sStyle is "system" then
      set the systemwindow of stack stackName to true
   else
      set the style of stack stackName to sStyle
      set the systemwindow of stack stackName to false
   end if 
   return stackName
end stack_Style

function display_ConstructFoldState ePaths
   repeat for each item someKey in ePaths
      put false into foldedArray [someKey]["folded"]
   end repeat
   return foldedArray
end display_ConstructFoldState

function colour_GetRandom
   put random(255) into item 1 of someColour
   put random(255) into item 2 of someColour
   put random(255) into item 3 of someColour
   return someColour
end colour_GetRandom


--> Deps | Geometry
-
getprop inner_Rect [groupRect]
   put the long id of the target into someGroup
   if groupRect is empty then put the rect of someGroup into groupRect
   if word 1 of someGroup is not "group" then return groupRect -- only for groups
   
   put rect_GetInner (groupRect, someGroup) into innerRect
   return innerRect
end inner_Rect

command rect_SubtractMargins @someRect, pMargin
   margin_Normalize pMargin, leftM, topM, rightM, bottomM
   put the result into nMargins
   --
   add leftM to item 1 of someRect
   add topM to item 2 of someRect
   subtract rightM from item 3 of someRect
   subtract bottomM from item 4 of someRect
   --
   return nMargins
end rect_SubtractMargins

command margin_Normalize someMargin, @leftM, @topM, @rightM, @bottomM
   if the number of items of someMargin < 4 then
      put item 1 of someMargin into defaultMargin
      put defaultMargin into leftM
      
      put item 2 of someMargin into actualMargin
      if actualMargin is empty then
         put leftM into topM
      else
         put actualMargin into topM
      end if
      
      put item 3 of someMargin into actualMargin
      if actualMargin is empty then
         put leftM into rightM
      else
         put actualMargin into rightM
      end if
      
      put item 4 of someMargin into actualMargin
      if actualMargin is empty then
         put topM into bottomM
      else
         put actualMargin into bottomM
      end if
   else
      put item 1 of someMargin into leftM
      put item 2 of someMargin into topM
      put item 3 of someMargin into rightM
      put item 4 of someMargin into bottomM
   end if
   return leftM,topM,rightM,bottomM
end margin_Normalize

function rect_GetInner groupRect, someGroup, pMargin
   if exists (someGroup) is false then return empty
   if pMargin is empty then
      put the margins of someGroup into pMargin
   end if
   rect_SubtractMargins groupRect, pMargin
   put the result into nMargins
   --
   if the showborder of someGroup is true then
      put the borderwidth of someGroup into bWidth
      rect_SubtractMargins groupRect, bWidth
   end if
   
   if the showname of someGroup is true then
      put the effective textheight of someGroup - bWidth into someBit
      subtract 2 from someBit
      add someBit to item 2 of groupRect
   end if
   
   put the scrollbarwidth of someGroup into scrollBarMargin
   if the vscrollbar of someGroup is true then 
      subtract scrollBarMargin from item 3 of groupRect
   end if
   if the hscrollbar of someGroup is true then
      subtract scrollBarMargin from item 4 of groupRect
   end if
   --
   return groupRect
end rect_GetInner


--> Deps
-
private command _AddDivider @mArray
   put _NextIndexNum (mArray) into indexNum
   put "-" into mArray [indexNum]["name"]
   put "-" into mArray [indexNum]["label"]
   put false into mArray [indexNum]["checked"]
   return indexNum
end _AddDivider

private command _AddMenu @mArray, mTitle, mController, tObject, mTarget, @recursionArray
   put mArray_FromScript (mTitle, tObject, mController, recursionArray) into addMenuArray
   if addMenuArray is not an array then return false
   --
   put keys (addMenuArray) into insertNum
   sort numeric insertNum
   repeat for each line insertNum in insertNum
      put _NextIndexNum (mArray) into indexNum
      put addMenuArray [insertNum] into mArray [indexNum]
   end repeat
   return true
end _AddMenu

private command _AddMenuItem @mArray, hName, mController, mTarget
   _DeconstructHandlerName hName, propLabel, shortCut
   --
   put mArray_GetParamValues (propLabel, mController, mTarget) into paramValues
   put paramValues into LocalArray ["Params"][mController][hName]["mParams"]
   --
   put _NextIndexNum (mArray) into indexNum
   put mArray_ConstructHkey (hName, mController) into mArray [indexNum]["name"]
   put text_SplitCaps (propLabel) into mArray [indexNum]["label"] -- menu_CommandToText (hName)
   put shortCut into mArray [indexNum]["shortCut"]
   --
   if paramValues is empty then
      put mArray_GetCheckItem (hName, mController, mTarget) into hNameIsChecked
      put mTarget into LocalArray ["Params"][mController][hName]["hNameIsChecked"][hNameIsChecked]
      --
      -- bizarre bug in Livecode widget being strict on boolean type an text type
      -- put true into mArray [indexNum]["disabled"] does not seem possible
      -- put itemChecked into mArray [indexNum]["checked"] -- does nto work!
      
      -- put item 2 of the extents of mArray into indexNum
      -- number_PadLeft indexNum, 2
      put hNameIsChecked is true into mArray [indexNum]["checked"]
   else
      put mArray_GetCheckParams (propLabel, mController, mTarget) into checkParams
      put checkParams into LocalArray ["Params"][mController][hName]["mCheckParams"]
      --
      _SetParamMenuItem mArray, propLabel, hName, mController, paramValues, checkParams, indexNum
   end if
   return true
end _AddMenuItem

private command _AddNextItem @mArray, subMenuArray, mName, mLabel
   put _NextIndexNum (mArray) into indexNum
   put subMenuArray into mArray [indexNum]["menu"]
   put mName into mArray [indexNum]["name"]
   put mLabel into mArray [indexNum]["label"]
end _AddNextItem

private command _AddObjectAndBehaviors @objectHierarchy, tObject, pPretty
   if exists (tObject) is false then return empty
   
   if pPretty is not false then
      -- put the long id of tObject into tObject
      put CR & the name of tObject after objectHierarchy
   else
      put CR & revRuggedId (tObject) after objectHierarchy
   end if
   
   put the behavior_Objects of tObject into bObjects
   if bObjects is empty then return false
   put CR & bObjects after objectHierarchy
   return true
end _AddObjectAndBehaviors

private command _AddScriptMenu @mArray, mTitle, tObject, newMenuController, @recursionArray, mTarget
   -- this is the one place where menu drawing happens that dispatches a message
   -- it contains the core logic and messaging order
   -- messaging logic: menu_Target, menu_CheckTarget, menu_Init
   if exists (newMenuController) is false then
      return false
   end if
   
   ## Menu Target
   if exists (mTarget) is false then
      put mArray_FindMenuTarget (newMenuController, tObject) into mTarget
   end if
   put the menu_CheckTarget [mTarget] of newMenuController into targetOK
   if targetOk is false then return false
   
   # Checks and logging
   switch
      case exists (newMenuController) is false
      case _RecursionCheck (recursionArray, tObject, newMenuController, mTitle) is false
      case _MenuLogActivated (newMenuController, tObject, mTitle) is true
         return false
   end switch
   
   # Get Handlers
   put _MenuHandlerNames (newMenuController) into scriptHandlers
   --
   repeat for each line hName in scriptHandlers       
      if hName ends with "_" then
         _AddDivider mArray
         next repeat
      end if
      
      put mArray_GetDisabled (hName, newMenuController, mTarget) into isDisabled
      switch
         -- case isDisabled = true -- we can delete it as right now there is no graying out
         case isDisabled = "delete"
            next repeat
         case hName begins with "submenu_"
            _SubmenuBit mArray, hName, newMenuController, tObject, recursionArray, mTarget
            _SetDisabled mArray, isDisabled
            break
         case hName begins with "insert_"
            _InsertBit mArray, hName, newMenuController, tObject, mTarget, recursionArray
            _SetDisabled mArray, isDisabled
            break
         default
            _AddMenuItem mArray, hName, newMenuController, mTarget
            _SetDisabled mArray, isDisabled
      end switch
   end repeat
   return true
end _AddScriptMenu

private command _AddSubmenu @mArray, mName, mLabel, mTitle, tObject, mController, @recursionArray
   put mArray_FromScript (mTitle, tObject, mController, recursionArray) into subMenuArray
   if subMenuArray is not an array then
      return false
   end if
   --
   _AddNextItem mArray, subMenuArray, mName, mLabel
   return true
end _AddSubmenu

private function _ConstructDoScript someQuestion, pQVar, pQVar2, pQVar3
   put text_GetMergeVars (someQuestion) into mergeVars
   repeat with lineNum = 1 to the number of lines of mergeVars
      put line lineNum of mergeVars into varName
      put lineNum + 1 into pNum
      put param (pNum) into pValue
      replace quote with "'" in pValue
      --
      if pValue is not empty then
         put "put" && kwote (pValue) && "into" && varName & CR after doScript
      end if
   end repeat
   delete char -1 of doScript
   return doScript
end _ConstructDoScript

private command _DeconstructHandlerName hName, @propLabel, @shortCut
   set the itemdelimiter to "_"
   get item 2 of hName
   set the itemdelimiter to "."
   put item 1 of it into propLabel
   put item 2 to -1 of it into shortCut
end _DeconstructHandlerName

command mArray_FindActive mArray, mItemPath, @hkey, @paramValue
   -- only used by "menu_DispatchTextPick" (was "_FindActiveHkey")
   set the itemdelimiter to "|"
   put mItemPath into subItemPath
   repeat the number of items of mItemPath
      put item 1 of subItemPath into itemText
      put _FindItemArray (mArray, itemText) into nextItemArray
      --
      if nextItemArray is not an array then
         -- was the last one -- probably because itemText caontained a param like "Hello|World"
         exit repeat
      else
         put nextItemArray into itemArray
      end if
      
      delete item 1 of subItemPath
      --
      put itemArray ["menu"] into subMenuArray
      if subMenuArray is an array then
         -- do we need to check that mItemPath is not emmpty?
         put itemArray ["name"] into hkey
         put subMenuArray into mArray
      else
         exit repeat -- at end (no more submenus)
      end if
   end repeat
   --
   put itemArray ["name"] into itemName
   if word 1 of itemName is "param" then
      put word 2 to -1 of itemName into paramValue
   else
      put itemName into hkey
      put subItemPath into paramValue -- should be empty unless parramm contains "|"
   end if
end mArray_FindActive

private function _FindItemArray mArray, itemText
   -- forgot why this is indexed with "01" rather thaan "1"
   -- something to do with display sorting, but a bad solution I think
   -- repeat with indexNum = 1 to item 2 of the extents of mArray
   put keys (mArray) into orderedNums
   sort numeric orderedNums
   repeat for each line indexNum in orderedNums
      put mArray [indexNum] into itemArray
      if itemArray ["label"] = itemText then
         return itemArray
      end if
   end repeat
   return empty
end _FindItemArray

private command _InsertBit @mArray, hName, mController, tObject, mTarget, @recursionArray
   dispatch hName to mController with mTarget
   put the result into insertMenuTitle
   --
   switch
      case insertMenuTitle is empty
         return false
      case menu_IsGlobal (insertMenuTitle)
         put _GetNewMenuController (tObject, insertMenuTitle, mController) into insertController
         break
      default
         -- assume it is a non-global menu in the same mController
         put mController into insertController
   end switch
   --
   -- mArray_SetActiveTitle insertMenuTitle
   --
   _AddMenu mArray, insertMenuTitle, insertController, tObject, mTarget, recursionArray
   return the result
end _InsertBit

private function _MenuCheckFailed mTitle, mType, tObject, titleMenuController, mTitleTable, mArray
   # Error due to "menu_CheckTarget" returns false (or menu does not exist)
   # We should just disable the menu, but now there is an issue with that that is hard to debug.
   
   # Gather info
   put mTitle into errorData ["mTitle"]
   put mType into errorData ["mType"]
   put mType into errorData ["mType"]
   put titleMenuController into errorData ["titleMenuController"]
   put mTitleTable into errorData ["mTitleTable"]
   put mArray into errorData ["mArray"]
   --
   global gLCW
   put errorData into gLCW ["Error"]["menu_CheckTarget"]
   
   # Get a simple safe menu to display
   local recursionArray
   put mArray_FromScript ("Global | Menu | Error | Menu", tObject, tObject, recursionArray) into mArray
   return mArray
   
   # Don't do this
   -- AddScriptMenu mArray, "Global | Menu | Error | Menu", tObject, tObject, recursionArray -- error, recurses!
end _MenuCheckFailed

private function _MenuHandlerNames mController
   local hNames
   /*
   Assumes only one menu and all named "menu_"
   */
   
   put the revAvailableHandlers of mController into hTable
   sort numeric hTable by word 3 of each
   -- filter hTable with "M menu_*"
   repeat for each line hLine in hTable
      put word 1 to 2 of hLine into shortKey
      put word 2 of hLine into hName
      --
      switch
         case shortKey = "M submenu_Dev"
            if the shiftKey is "Down" then
               put hName & CR after hNames
            end if
            break
         case hName = "menu_Init"
            break
         case hName ends with "_"
            ## Divider is a command ending with "_"
            put "_" & CR after hNames
            break
         case hLine begins with "M submenu_"
         case hLine begins with "M insert_"
         case hLine begins with "M menu_"
            put word 2 of hLine into hName
            put hName & CR after hNames
            break
         default
            -- not a menu
      end switch
   end repeat
   delete char -1 of hNames
   return hNames
end _MenuHandlerNames

private function _MenuLogActivated newMenuController, tObject, mTitle
   -- checks for double menus in an object
   -- and logs menus that have been activated
   
   put LocalArray ["MenuControllerInit"][newMenuController]["mInitialised"] is true into mInitialised
   if mInitialised is not true then      
      put mInitialised into LocalArray ["MenuControllerInit"][newMenuController]["mInitialised"] -- check recursion
      
      -- for debugging
      put mTitle into LocalArray ["MenuControllerInit"][newMenuController]["mTitle"] -- to find mController from mTitle
      put tObject into LocalArray ["MenuControllerInit"][newMenuController]["tObject"]
   end if
   return mInitialised
end _MenuLogActivated

private function _NextIndexNum mArray
   -- padding added due to ordering issue with widget
   if mArray is an array then
      put item 2 of the extents of mArray into indexNum
      add 1 to indexNum
   else
      put 01 into indexNum
   end if
   number_PadLeft indexNum, 2
   return indexNum
end _NextIndexNum

private function _PropLabel hName
   _DeconstructHandlerName hName, propLabel, shortCut
   return propLabel
end _PropLabel

private function _RecursionCheck @recursionArray, tObject, mController, mTitle
   put recursionArray [mController][mTitle] into testObject
   if testObject is not empty then
      -- already indexed. Don't allow a menu to be there twice.
      return false
   else
      put tObject into recursionArray [mController][mTitle]
      return true
   end if
end _RecursionCheck

private command _SetDisabled @mArray, isDisabled
   if isDisabled is not empty then
      put item 2 of the extents of mArray into indexNum
      number_PadLeft indexNum, 2
      put isDisabled is true into mArray [indexNum]["disabled"]
   end if
end _SetDisabled

private command _SetMenuObjectDefaults @tObject, @mButton
   if exists (tObject) is false then
      put the long id of the target into tObject
   end if
   if exists (mButton) is false then
      -- defaults to the target rather than the global menu_Button
      put the long id of the target into mButton
   end if
end _SetMenuObjectDefaults

private command _SetParamMenuItem @mArray, propLabel, hName, mController, paramValues, checkParams, indexNum
   replace comma with CR in paramValues
   replace comma with CR in checkParams
   set the wholematches to true
   
   -- not safe for widget bug ordering
   put 1 into subIndexNum
   repeat for each line paramValue in paramValues
      put paramValue into subMenuArray [subIndexNum]["label"]
      --
      put "param" && paramValue into subMenuArray [subIndexNum]["name"]
      --
      put paramValue is among the lines of checkParams into someBoolean
      put someBoolean is true into subMenuArray [subIndexNum]["checked"]
      --
      add 1 to subIndexNum
   end repeat
   
   put subMenuArray into mArray [indexNum]["menu"]
   
   # Set mArray
   -- put mArray_ConstructHkey (hName, mController) into mArray [indexNum]["name"]
   -- put text_SplitCaps (propLabel) into mArray [indexNum]["label"]
end _SetParamMenuItem

private function _SimpleRecursionCheck mController, mTitle
   put mArray_GetActiveControllerArray() into mControllerArray
   put mControllerArray [mController] into testArray
   return testArray is an array
end _SimpleRecursionCheck

private command _SubmenuBit @mArray, hName, mController, tObject, @recursionArray, mTarget
   -- bug: can recurse
   dispatch hName to mController with mTarget
   put the result into subMenuTitle
   if subMenuTitle is empty then return false
   --
   -- mArray_SetActiveTitle subMenuTitle
   put _GetNewMenuController (tObject, subMenuTitle, mController) into newMenuController
   put menu_CommandToText (hName) into mLabel
   _AddSubmenu mArray, hName, mLabel, subMenuTitle, tObject, newMenuController, recursionArray
   --
   return true
end _SubmenuBit

function array_Get someFile
   put url ("binfile:" & someFile) into encodedDataArray
   if encodedDataArray is empty then return empty
   put arraydecode (encodedDataArray) into modelArray
   return modelArray
end array_Get

function behavior_GetHierarchy tObject, pUseRugged
   repeat
      put the behavior of tObject into bObject
      if exists (bObject) is false then exit repeat
      if pUseRugged is not false then
         put revRuggedId (bObject) into bObject
      end if
      put bObject & CR after bObjects
      put bObject into tObject
   end repeat
   delete char -1 of bObjects
   return bObjects
end behavior_GetHierarchy

getprop behavior_Objects [useRugged]
   put the long id of the target into tObject
   put behavior_GetHierarchy (tObject, useRugged) into bObjects
   return bObjects
end behavior_Objects

function env_GetLcwFolder
   global gLCW
   put "lcwFolder" into prefName
   --
   put pref_GetValue (prefName) into lcwFolder
   if lcwFolder is not empty then return lcwFolder
   
   put pref_FetchValue (prefName) into lcwFolder
   return lcwFolder
end env_GetLcwFolder

function env_GetRepoFolder
   put env_GetLcwFolder() into pLcwFolder
   --
   set the itemdelimiter to slash
   delete item -1 of pLcwFolder
   return pLcwFolder
end env_GetRepoFolder

function env_ListBackScripts
   -- /Applications/LiveCode Community 8.1.0 (dp 3).app/Contents/Tools/Toolset/libraries/revshortcutslibrary.livecodescript
   put the backscripts into longIDs
   ide_FilterOutStacks longIDs
   return longIDs
end env_ListBackScripts

function env_ListFrontScripts
   -- /Applications/LiveCode Community 8.1.0 (dp 3).app/Contents/Tools/Toolset/libraries/revshortcutslibrary.livecodescript
   put the frontscripts into longIDs
   ide_FilterOutStacks longIDs
   return longIDs
end env_ListFrontScripts

function env_ScriptHierarchy pRemoveTransportBehavior
   put env_ListFrontScripts() into frontObjects
   -- _RemoveTransporterTools frontObjects, pRemoveTransportBehavior
   --
   put env_ListBackScripts() into backObjects
   put stack_PathsToObjects (the stacksinUse) into usedStacks
   --
   object_AddBehaviors usedStacks
   object_AddBehaviors frontObjects
   object_AddBehaviors backObjects
   --
   if usedStacks is not empty then put usedStacks into scriptHierarchy
   if backObjects is not empty then put backObjects & CR before scriptHierarchy
   if frontObjects is not empty then put CR & frontObjects after scriptHierarchy
   --
   return scriptHierarchy
end env_ScriptHierarchy

command field_ScrollToLine lineNum, fieldObject, pSelectLine
   -- does not seem accurate for large line numbers (it's an underestimate) ???
   
   if lineNum = 0 then
      put 0 into someScroll
   else if lineNum is a number then
      put the effective textHeight of fieldObject into lineHeight
      put ((lineNum - 1) * lineHeight) - 0 * the height of fieldObject into someScroll
   else -- any text = "bottom"
      -- bit of a hack (but works :)
      put the effective textHeight of fieldObject into lineHeight
      put the number of lines of the text of fieldObject into lineNum
      put ((lineNum - 1) * lineHeight) - 0 * the height of fieldObject into someScroll
   end if
   set the scroll of fieldObject to someScroll
   if pSelectLine is not false then
      select line lineNum of fieldObject
   end if
end field_ScrollToLine

function folder_ListStackPaths someFolder
   if there is not a folder someFolder then return empty
   
   if char -1 of someFolder is not slash then put slash after someFolder
   put the defaultfolder into oFolder
   set the defaultfolder to someFolder
   put the files into shortFiles
   
   set the itemdelimiter to "."
   repeat for each line shortFile in shortFiles
      put someFolder & shortFile into stackFilePath
      if there is a stack stackFilePath then
         put stackFilePath & CR after stackFilePaths
      end if
   end repeat
   delete char -1 of stackFilePaths
   set the defaultfolder to oFolder
   return stackFilePaths
end folder_ListStackPaths

getprop found_Hkey [shortHkey]
   # Private and non-private handlers in targetObject
   -- and non-private handlers in hkey_ScriptHierarchy
   put the long id of the target into tObject
   --
   put the walk_Hierarchy of tObject into searchObjects
   put hkey_FindShortHkey (shortHkey, tObject, searchObjects) into foundHkey
   return foundHkey
end found_Hkey

command handler_Do hName, hObject, pTarget, pValue
   if exists (hObject) is false then
      -- display_DebugHistory hName
      return "Error, hObject does not exists."
   end if
   
   put hName && "pTarget,pValue" into callCommand
   call callCommand of hObject
   return the result
end handler_Do

command hierachy_AddStackObjects @objectHierarchy, tObject, pPretty
   if exists (tObject) is false then return false
   put tObject into objectOwner
   put empty into skipThisBackgroundID
   
   repeat
      switch word 1 of objectOwner
         case "stack"
            -- previously added a stack, check if it was a substack
            put objectOwner into stackObject
            put the owner of stackObject into mainStackObject
            if exists (mainStackObject) then
               _AddObjectAndBehaviors objectHierarchy, mainStackObject, pPretty
            end if
            
            delete word 1 to 3 of objectOwner
            if exists (objectOwner) is false then exit repeat
            break
         case "card"
            -- previously added a card, so check for backgrounds
            put objectOwner into cardObject
            put the backgroundIDs of cardObject into bgIDs
            -- need to add in reverse to mirror message path
            repeat with bgNum = the number of lines of bgIDs down to 1
               put line bgNum of bgIDs into someID
               if someID = skipThisBackgroundID then next repeat
               put the long ID of bg ID someID of cardObject into backgroundObject
               _AddObjectAndBehaviors objectHierarchy, backgroundObject
            end repeat
            
            # Above a card must be a stack
            put objectOwner into stackObject
            delete word 1 to 4 of stackObject
            _AddObjectAndBehaviors objectHierarchy, stackObject
            
            exit repeat
            break
         case "group"
            -- previously added a group, check to see if was a bg
            if the backgroundbehavior of objectOwner is true then
               -- will need to skip it's own "card" background
               put the short ID of objectOwner into skipThisBackgroundID
            end if
            --
            delete word 1 to 4 of objectOwner
            if exists (objectOwner) is false then exit repeat
            --
            _AddObjectAndBehaviors objectHierarchy, objectOwner
            break
         default
            -- previously added a normal control
            delete word 1 to 4 of objectOwner
            if exists (objectOwner) is false then exit repeat
            --
            _AddObjectAndBehaviors objectHierarchy, objectOwner
      end switch
   end repeat
   put word 1 to -1 of objectHierarchy into objectHierarchy
   return true
end hierachy_AddStackObjects

command hierarchy_AddEnv @objectHierarchy
   put env_ScriptHierarchy (true) into externalObjects
   if externalObjects is empty then return false
   
   set the wholematches to true
   repeat for each line sObject in objectHierarchy
      put lineOffset (sObject, externalObjects) into lineNum
      delete line lineNum of externalObjects
   end repeat
   if externalObjects is empty then return false
   
   put CR & word 1 to -1 of externalObjects after objectHierarchy
   put word 1 to -1 of objectHierarchy into objectHierarchy
   return true
end hierarchy_AddEnv

function hierarchy_Construct tObject, pPretty
   -- was "object_GetHierarchy"
   local objectHierarchy
   put the long id of tObject into tObject
   put pPretty is not false into pPretty
   
   put the hierarchy_ObjectAndBehaviors [pPretty] of tObject into objectHierarchy
   hierachy_AddStackObjects objectHierarchy, tObject, pPretty
   return word 1 to -1 of objectHierarchy
end hierarchy_Construct

getprop hierarchy_ObjectAndBehaviors [pPretty]
   local objectHierarchy
   put pPretty is not false into pPretty
   put the long id of the target into tObject
   
   _AddObjectAndBehaviors objectHierarchy, tObject, pPretty
   return word 1 to -1 of objectHierarchy
end hierarchy_ObjectAndBehaviors

function hkey_Construct hName, hType, tObject
   if exists (tObject) is false then
      put "Missing" into hObject
   end if
   replace "C" with "M" in hType
   put hKeyLine_Construct (hName, hType, tObject) into hKeyLine
   return hKeyLine
end hkey_Construct

command hkey_Deconstruct hKey, @hName, @hType, @hObject, @hNum
   -- will deconstruct both
   -- move over to hkeyLine_Deconstruct
   
   if the number of items of hkey = 1 then
      hkeyLine_Deconstruct hKey, hName, hType, hObject
      put 1 into hNum
   else
      -- old version
      put word 1 to -1 of item 1 of hKey into hName
      put word 1 to -1 of item 2 of hKey into hType
      if hType is empty then put "c" into hType
      put word 1 to -1 of item 3 of hKey into hObject
      put item 4 of hKey into hNum
      if hNum is empty then put 1 into hNum
   end if
   
   put hKeyLine_Construct (hName, hType, hObject) into hkeyLine
   return hkeyLine
end hkey_Deconstruct

command hKey_Do hKey, pTarget, pValue, pQuestion
   if the optionKey is "Down" then
      put scriptEditor_GetTop() into stackObject
      if pQuestion is empty then
         put "Edit script for this handler?" into pQuestion
      end if
      lcw_Answer pQuestion, stackObject
      --
      hkey_Edit hKey
      return empty
   end if
   
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   handler_Do hName, hObject, pTarget, pValue
   return the result
end hKey_Do

command hkey_Edit hKey
   if hKey is empty then
      return "Error, hkey is empty"
      -- put debug_GetCallingHkey() into hkeyLine
      -- hkey_Deconstruct hkeyLine, fName, fType, fObject, fNum
   end if
   
   # Find Hkey
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the result into hkeyLine
   if exists (hObject) is true then
      put the found_Hkey [hkeyLine] of hObject into foundHkey
   else
      put hkey_Find (hKey) into foundHkey          
   end if
   
   # Edit found script and scroll
   hkey_Deconstruct foundHkey, fName, fType, fObject, fNum
   if exists (fObject) is false then return empty
   put the hkey_StartLine [hkeyLine] of fObject into scriptLineNum
   scriptEditor_EditAndScroll fObject, scriptLineNum, fName  
   
   return foundHkey
end hkey_Edit

getprop hkey_Either [shortHkey]
   -- returns public or private hkey in tObject
   put the revAvailableHandlers of the target into hTable
   put hTable_GetEither (shortHkey, hTable) into foundHkey
   return foundHkey
end hkey_Either

function hkey_Find hKey, pSearchObjects
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   put the result into shortHkey
   
   if pSearchObjects is empty then
      if exists (hObject) then
         put the walk_Hierarchy of hObject into pSearchObjects
      else
         put env_ScriptHierarchy (true) into pSearchObjects
      end if
   end if
   --
   put hkey_FindShortHkey (shortHkey, hObject, pSearchObjects) into foundHkey
   return foundHkey
end hkey_Find

function hkey_FindShortHkey shortHkey, pObject, pSearchObjects
   put word 1 to 2 of shortHkey into shortHkey
   
   # Make shortHkey public
   if char 1 of shortHkey = "P" then delete char 1 of shortHkey
   
   if exists (pObject) then
      # Search for private handlers
      put the hkey_Either [shortHkey] of pObject into foundHkey
      if foundHkey is not empty then
         return foundHkey
      end if
      line_Delete pSearchObjects, pObject -- so we dont search it again later
   end if
   
   # Search for public handlers in pSearchObjects
   repeat for each line foundObject in pSearchObjects
      if exists (foundObject) is false then next repeat
      
      put the hkey_Or [shortHkey] of foundObject into foundHkey
      if foundHkey is not empty then
         return foundHkey
      end if
   end repeat
   return empty  
end hkey_FindShortHkey

getprop hkey_Or [shortHkey]
   put the revAvailableHandlers of the target into hTable
   put htable_GetOr (shortHkey, hTable) into foundHkey
   return foundHkey
end hkey_Or

getprop hkey_StartLine [hkeyLine]
   put word 1 to 2 of hkeyLine into shortHkey
   put the revAvailableHandlers of the target into hTable
   repeat for each line someLine in hTable
      if word 1 to 2 of someLine = shortHkey then
         put word 3 of someLine into startLineNum
         return startLineNum
      end if
   end repeat
   return 0
end hkey_StartLine

function hKeyLine_AddObject hkeyLine, tObject
   -- used quite a lot
   put revRuggedID (tObject) into hObject
   put word 1 to 2 of hkeyLine && "of" && hObject into hKeyLine
   return hKeyLine
end hKeyLine_AddObject

function hKeyLine_Construct hName, hType, tObject
   put hType && hName into shortHkeyLine
   if tObject is empty then return shortHkeyLine
   
   put hKeyLine_AddObject (shortHkeyLine, tObject) into hkeyLine
   return hkeyLine
end hKeyLine_Construct

command hkeyLine_Deconstruct hKeyLine, @hName, @hType, @hObject
   put toUpper (word 1 of hKeyLine) into hType
   put word 2 of hKeyLine into hName
   put word 4 to -1 of hKeyLine into hObject
   return hType && hName
end hkeyLine_Deconstruct

function htable_GetEither searchHkeyLine, hTable
   -- matches either private of public handlers
   -- returns just the foundHkey (we dont need line numbers)
   put char -1 of word 1 of searchHkeyLine into hType
   put word 2 of searchHkeyLine into searchName
   
   repeat for each line hLine in hTable
      put word 2 of hLine into foundName
      put word 1 of hLine into foundPublicType
      if foundName is not searchName then next repeat
      
      put char -1 of foundPublicType into fType
      switch
         case hType = fType
         case (hType = "C") AND (fType = "M")
         case (hType = "M") AND (fType = "C")
            put word 5 to -1 of line 1 of hTable into hObject
            put hKeyLine_Construct (foundName, foundPublicType, hObject) into foundHkey
            return foundHkey
      end switch
   end repeat
   return empty
end htable_GetEither

function htable_GetOr searchHkeyLine, hTable
   put word 1 of searchHkeyLine into hType
   put word 2 of searchHkeyLine into hName
   --
   htable_OrLineOffsets hName, hType, hTable, startLineNum, endLineNum
   if the result is false then return empty
   
   put word 5 to -1 of line 1 of hTable into tObject
   put word 1 of searchHkeyLine into hType
   put word 2 of searchHkeyLine into hName
   put hKeyLine_Construct (hName, hType, tObject) into foundHkey
   return foundHkey
end htable_GetOr

command htable_OrLineOffsets hName, hType, hTable, @startLineNum, @endLineNum
   repeat for each line hLine in hTable
      if hName is not word 2 of hLine then next repeat
      
      switch
         case hType = word 1 of hLine
         case (hType = "C") AND (word 1 of hLine = "M")
         case (hType = "M") AND (word 1 of hLine = "C")
            put word 3 of hLine into startLineNum
            put word 4 of hLine into endLineNum
            return true
      end switch
   end repeat
   put 0 into startLineNum
   put 0 into endLineNum
   return false
end htable_OrLineOffsets

command ide_FilterOutStacks @longIDs
   put rev_AppContentsFolder() into revAppContentsFolder
   
   set the itemdelimiter to slash
   repeat for each line tObject in longIDs
      if exists(tObject) is false then next repeat
      put token -1 of tObject into stackPath
      if stackPath begins with revAppContentsFolder then next repeat
      put revRuggedId (tObject) & CR after filteredObjects
   end repeat
   delete char -1 of filteredObjects
   put filteredObjects into longIDs
end ide_FilterOutStacks

function kwote someText, pQuoteChar
   if pQuoteChar is empty then put quote into pQuoteChar
   return pQuoteChar & someText & pQuoteChar
end kwote

command lcw_Answer someQuestion, pDisplayView, pQVar
   put param (4) into pQVar2
   put param (5) into pQVar3
   --
   if exists (pDisplayView) then
      dispatch "lcw_Answer" to pDisplayView with someQuestion, empty, pQVar, pQVar2, pQVar3
      return the result
   end if
   put lcw_Question (someQuestion, pQVar, pQVar2, pQVar3) into someQuestion
   --
   answer someQuestion with "Cancel" or "OK" as sheet
   if it is "Cancel" then exit to top
   return it
end lcw_Answer

function lcw_Question someQuestion, pQVar
   put param (4) into pQVar2
   put param (5) into pQVar3
   --
   put _ConstructDoScript (someQuestion, pQVar, pQVar2, pQVar3) into doScript
   if doScript is not empty then
      do doScript
      put merge (someQuestion) into someQuestion
   end if
   text_ReQuote someQuestion
   return someQuestion
end lcw_Question

command line_Delete someLine, @someIndex
   set the wholematches to true
   put lineoffset (someLine, someIndex) into lineNum
   delete line lineNum of someIndex
   return lineNum
end line_Delete

command mArray_ClearActiveMenuArray
   delete variable LocalArray
end mArray_ClearActiveMenuArray

function mArray_ConstructHkey hName, mController
   put hkey_Construct (hName, "M", mController) into hkeyController
   mArray_Marshal hkeyController
   return hkeyController
end mArray_ConstructHkey

command mArray_DoHkey hKey, pValue
   -- changed "dispatch" to "call" which keeps the context of the target
   mArray_UnMarshal hKey
   hkeyLine_Deconstruct hKey, hName, hType, mController
   
   put menu_GetTopTargetObject() into tObject
   put mArray_FindMenuTarget (mController, tObject) into mTarget
   --
   hKey_Do hKey, mTarget, pValue
   return the result
end mArray_DoHkey

function mArray_FindMenuTarget mController, tObject
   -- logic: controller, target (called for every nested menu)
   
   if exists (tObject) is false then
      put menu_GetTopTargetObject() into tObject -- bug: should exist
   end if
   --
   if exists (mController) is true then
      put the menu_Target [tObject] of mController into mTarget
      if mTarget is not empty then return mTarget
   end if
   --
   put the menu_Target [tObject] of tObject into mTarget
   if mTarget is empty then
      return tObject
   else
      return mTarget
   end if
end mArray_FindMenuTarget

function mArray_FromScript mTitle, tObject, mController, @recursionArray
   local mArray
   put _GetNewMenuController (tObject, mTitle, mController) into newMenuController
   _AddScriptMenu mArray, mTitle, tObject, newMenuController, recursionArray
   return mArray
end mArray_FromScript

function mArray_FromTitleTable mTitleTable, tObject
   local mArray, recursionArray
   --
   replace comma with tab in mTitleTable
   set the itemdelimiter to tab
   repeat for each line mTitleLine in mTitleTable
      -- tables are not often used
      put item 1 of mTitleLine into mTitle
      
      put item 2 of mTitleLine into mType
      if mTitle = "-" then
         _AddDivider mArray
         next repeat
      end if
      
      put _MenuTitleController (mTitle, tObject) into titleMenuController
      if exists (titleMenuController) is false then next repeat
      
      mArray_SetTopTitle mTitle
      dispatch "menu_Init" to titleMenuController with tObject -- top only
      
      -- insert has not been done for tables yet
      switch mType
         case "insert"
            breakpoint
            break
         case "submenu"
            try
               put item 3 of mTitleLine into prettyTitle
               if prettyTitle is empty then
                  put menu_ConstructItemText (mTitle) into prettyTitle
               end if
               _AddSubmenu mArray, prettyTitle, prettyTitle, mTitle, tObject, titleMenuController, recursionArray
               put the result into goodMenu
            catch e
               -- next repeat
               put false into goodMenu
            end try
            break
         default
            # Guess controller
            put _GetNewMenuController (tObject, mTitle, titleMenuController) into newMenuController
            if exists (newMenuController) is false then
               -- breakpoint 
               put false into goodMenu
            else
               _AddScriptMenu mArray, mTitle, tObject, newMenuController, recursionArray
               put the result into goodMenu
            end if
      end switch
      
      if goodMenu is false then
         get _MenuCheckFailed (mTitle, mType, tObject, titleMenuController, mTitleTable, mArray)
         put menu_GetGlobalController ("Global | Menu | Error | Menu") into mController
         _AddMenuItem mArray, "display_Error", mController, tObject
         -- exit repeat -- ideally we add and loop
      end if
   end repeat
   --
   mArray_SetActiveArray mArray
   --
   return mArray
end mArray_FromTitleTable

function mArray_GetActiveArray
   return LocalArray ["active_MenuArray"]
end mArray_GetActiveArray

function mArray_GetActiveControllerArray
   put LocalArray ["MenuControllerInit"] into mControllerArray
   return mControllerArray
end mArray_GetActiveControllerArray

function mArray_GetCheckItem hName, mController, mTarget
   if exists (mController) is false then return false--
   put _PropLabel(hName) into hText
   put "checked_" & hText & "[" & mTarget & "]" into mProperty
   put the mProperty of mController into someBoolean
   return someBoolean is true
end mArray_GetCheckItem

function mArray_GetCheckParams propLabel, mController, mTarget
   put propLabel & "_Param" & "[" & mTarget & "]" into mProperty
   put the mProperty of mController into checkParams
   return checkParams
end mArray_GetCheckParams

function mArray_GetDisabled hName, mController, mTarget
   put _PropLabel(hName) into hText
   put "disabled_" & hText & "[" & mTarget & "]" into mProperty
   put the mProperty of mController into isDisabled
   return isDisabled
end mArray_GetDisabled

function mArray_GetParamValues propLabel, mController, mTarget
   put propLabel & "_Params" & "[" & mTarget & "]" into mProperty
   try
      put the mProperty of mController into paramValues
      return paramValues
   catch e
      -- edit the script of mController
      lcw_Notify the params
   end try
end mArray_GetParamValues

command mArray_Marshal @hkeyController
   replace "|" with "\" in hkeyController
end mArray_Marshal

command mArray_SetActiveArray mArray
   put mArray into LocalArray ["active_MenuArray"]
end mArray_SetActiveArray

command  mArray_SetActiveItem mItem
   put mItem into LocalArray ["active_MenuItemPath"]
end mArray_SetActiveItem

command mArray_SetTopTitle mTitle
   put mTitle into LocalArray ["active_TopMenuTitle"]
end mArray_SetTopTitle

command mArray_TextRecurse @mText, someIndent, mArray, pController, pMenuTarget
   put keys (mArray) into indexNums
   sort numeric indexNums
   repeat for each line indexNum in indexNums
      put mArray [indexNum] into itemArray
      --
      put itemArray ["name"] into mController
      put itemArray ["label"] into itemText
      
      # Set disabled
      if pController is empty then
         put itemArray ["checked"] into isChecked
         put itemArray ["disabled"] into isDisabled
      else
         -- check live (not sure if this is ever used?)
         -- put mArray_GetObjectCheckStatus (hName, pController, pMenuTarget) into isDisabled
         put mArray_GetDisabled (hName, pController, pMenuTarget) into isDisabled
      end if
      if isDisabled is true then put "(" before itemText
      
      # Set Shortcut
      put itemArray ["shortcut"] into shortcut
      if shortcut is not empty then
         put "/" & shortCut after itemText
      end if
      
      # Set checked
      if isChecked is true then
         put "!c" before itemText
      else
         -- put "!n" before itemText
      end if
      put someIndent & itemText & CR after mText
      
      # Recurse
      put itemArray ["menu"] into subArray
      if subArray is an array then
         put tab & someIndent into nextIndent
         mArray_TextRecurse mText, nextIndent, subArray
      end if
   end repeat
end mArray_TextRecurse

function mArray_ToText mArray
   local mText
   put empty into someIndent
   mArray_TextRecurse mText, someIndent, mArray
   delete char -1 of mText
   return mText
end mArray_ToText

command mArray_UnMarshal @hkeyController
   replace "\" with "|" in hkeyController
end mArray_UnMarshal

getprop menu_CheckTarget [mTarget]
   /*
   This is a default sent by  "menu_ConvertTable" 
   Usually - all you want to do is check that the topMenuTarget exists.
   But it could be a file or some other non-Rev structure.
   */
   return true
end menu_CheckTarget

function menu_CommandToText hName
   _DeconstructHandlerName hName, propLabel, shortCut
   put text_SplitCaps (propLabel) into mLine
   return mLine
end menu_CommandToText

function menu_ConstructItemText mTitle
   set the itemdelimiter to "|"
   delete item - 1 of mTitle
   if word 1 to -1 of item 1 of mTitle = "Global" then delete item 1 of mTitle
   
   replace " | " with " " in mTitle
   return word 1 to -1 of mTitle
end menu_ConstructItemText

function menu_GetTopTargetObject
   return LocalArray ["active_TopTargetObject"]
end menu_GetTopTargetObject

function menu_IsGlobal mTitle
   set the itemdelimiter to "|"
   if word 1 to -1 of item 1 of mTitle = "Global" \
         AND word 1 to -1 of item -1 of mTitle = "Menu" then
      return true
   else
      return false
   end if
end menu_IsGlobal

command menu_SetTopTargetObject tObject
   put tObject into LocalArray ["active_TopTargetObject"]
end menu_SetTopTargetObject

getprop module_BehaviorHierarchy [fromFolder]
   local oHierarchy, bHierarchy
   put the long id of the target into tObject
   put revRuggedId (tObject) into rObject
   --
   put the module_Name of tObject into moduleName
   put view_GetTemplateObject (moduleName) into mObject
   
   # Behaviors and object hieararchy
   if fromFolder is not false then
      put the module_Behaviors of mObject into oHierarchy
   else
      put the behavior_Objects of mObject into oHierarchy
   end if
   --
   line_Delete rObject, oHierarchy
   put rObject & CR before oHierarchy
   put word 1 to -1 of oHierarchy into oHierarchy
   
   # Rest of object hierarchy
   hierachy_AddStackObjects bHierarchy, mObject
   put oHierarchy & CR & word 1 to -1 of bHierarchy into walkHierarchy
   
   # Is this missing stack object?
   
   # Add Env hierarchy
   hierarchy_AddEnv walkHierarchy
   return walkHierarchy
end module_BehaviorHierarchy

getprop module_BehaviorPaths
   put the module_Folder of the target into moduleFolder
   put moduleFolder & "behaviors/" into moduleBehaviorFolder
   put folder_ListStackPaths (moduleBehaviorFolder) into stackPaths
   return stackPaths
end module_BehaviorPaths

getprop module_Behaviors
   -- unordered list
   put the module_BehaviorPaths of the target into stackPaths
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      put the name of stack stackPath & CR after moduleBehaviors
   end repeat
   delete char -1 of moduleBehaviors
   return moduleBehaviors
end module_Behaviors

getprop module_Folder
   put the long id of the target into tObject
   put the effective filename of the defaultstack into stackPath
   put the project_Folder of tObject into projectFolder
   if there is not a folder projectFolder then return empty
   --
   put module_FolderFromPath (stackPath, projectFolder) into moduleFolder
   return moduleFolder
end module_Folder

function module_FolderFromPath stackPath, projectFolder
   set the itemdelimiter to slash
   put the number of items of projectFolder into pNum
   if item (pNum + 1) of stackPath is not "Modules" then return empty
   
   put item 1 to (pNum + 2) of stackPath & slash into moduleFolder
   return moduleFolder
end module_FolderFromPath

getprop module_Name
   put the module_ShortFolder of the target into moduleName
   replace "_" with "|" in moduleName
   return moduleName
end module_Name

getprop module_ShortFolder
   put the module_Folder of the target into moduleFolder
   set the itemdelimiter to slash
   put item -1 of moduleFolder into shortFolder
   return shortFolder
end module_ShortFolder

private command number_PadLeft @someNum, padNum
   put "%0" & padNum & "d" into fString
   put format (fString, someNum) into someNum
end number_PadLeft

command object_AddBehaviors @objectIndex
   repeat for each line someObject in objectIndex
      if exists (someObject) is false then next repeat 
      put the behavior of someObject into objectBehavior
      if exists (objectBehavior) then
         put revRuggedId (objectBehavior) & CR after newObjectIndex
      end if
      put someObject & CR after newObjectIndex
   end repeat
   delete char -1 of newObjectIndex
   put newObjectIndex into objectIndex
end object_AddBehaviors

function pref_FetchArray pProjectName
   if pProjectName is empty then put "Default" into pProjectName
   put pref_FetchData() into dataArray
   return dataArray [pProjectName]
end pref_FetchArray

function pref_FetchData
   put pref_File() into someFile
   put array_Get (someFile) into dataArray
   return dataArray
end pref_FetchData

function pref_FetchValue prefName, pPrefKey
   if pPrefKey is empty then put "Default" into pPrefKey
   --
   put pref_FetchArray (pPrefKey) into prefArray
   put prefArray [prefName] into someValue
   return someValue
end pref_FetchValue

function pref_File
   put specialfolderpath ("preferences") & "/lcw_Preferences.array" into prefFile
   return prefFile
end pref_File

function pref_GetValue prefName
   global gLCW
   return gLCW ["prefsArray"][prefName]
end pref_GetValue

getprop project_Folder
   -- latest simplest version based on naming conventions and folder structure
   -- does not allow projects outside of the LCW reop folder  
   
   put the effective filename of the defaultstack into stackPath
   put project_FolderFromPath (stackPath) into projectFolder
   return projectFolder
end project_Folder

function project_FolderFromPath stackPath
   set the itemdelimiter to slash
   put env_GetRepoFolder() into repoFolder
   put the number of items of repoFolder + 1 into itemNum
   put item 1 to itemNum of stackPath & slash into projectFolder
   --
   return projectFolder
end project_FolderFromPath

function rev_AppContentsFolder
   -- /Applications/LiveCode Community 8.1.0 (dp 3).app/Contents/
   set the itemdelimiter to slash
   put the engine folder into appContentsFolder
   put empty into item -1 of appContentsFolder
   return appContentsFolder
end rev_AppContentsFolder

function rev_HandlerTreeField pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   if exists (field "handlers" of group "Left Bar" of cd "Main" of editorStack) is false then return empty
   put the long id of field "handlers" of group "Left Bar" of cd "Main" of editorStack into someObject
   return revRuggedID (someObject)
end rev_HandlerTreeField

function rev_ScriptEditorField pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   if exists (fld "Script" of group "Editor" of cd "Main" of editorStack) is false then return empty
   put the long id of fld "Script" of group "Editor" of cd "Main" of editorStack into someObject
   return revRuggedID (someObject)
end rev_ScriptEditorField

function rev_ScriptEditorStack pEditorNum
   switch
      case pEditorNum is empty
         return scriptEditor_GetTop()
      case pEditorNum = 0
         put the long id of stack "revSETemplate" of stack "revNewScriptEditor" into stackObject
         return revRuggedID (stackObject)
      case pEditorNum is a number
         put "revNewScriptEditor" && pEditorNum into stackName
         if exists (stack stackName) is false then return empty
         return the name stack stackName
      default
         return scriptEditor_GetTop()
   end switch
end rev_ScriptEditorStack

command scriptEditor_EditAndScroll hObject, scriptLineNum, hName
   edit the script of hObject
   put rev_HandlerTreeField() into handlerTreeField
   put rev_ScriptEditorField() into scriptEditorField
   --
   put the text of handlerTreeField into hIndex
   --
   try
      lock screen
      if hName is not empty then
         put lineOffset (hName, hIndex) into hLineNum
         set the hilitedLine of handlerTreeField to hLineNum
      end if
      --
      field_ScrollToLine scriptLineNum, scriptEditorField, true
      dispatch "closeAccept" to handlerTreeField
      unlock screen
      --
      return empty
   catch e
      return the executioncontexts
   end try
end scriptEditor_EditAndScroll

function scriptEditor_GetTop
   -- was "scriptEditor_GetTop()"
   
   put the short name of the defaultstack into stackName
   if word 1 of stackName is "revNewScriptEditor" then
      return the long id of stack stackName
   else
      put the openstacks into stackNames
      filter stackNames with "revNewScriptEditor*"
      if stackNames is empty then return empty
      put line 1 of stackNames into firstEditorStackName
      return the long id of stack firstEditorStackName
   end if
end scriptEditor_GetTop

function stack_FirstControl sPath
   if exists (control 1 of card 1 of stack sPath) then
      return the long id of control 1 of card 1 of stack sPath
   else
      return empty
   end if
end stack_FirstControl

function stack_PathsToObjects stackNameOrPaths
   repeat for each line stackName in stackNameOrPaths
      if exists (stack stackName) is false then next repeat
      put the name of stack stackName & CR after stackObjects
   end repeat
   delete char -1 of stackObjects
   return word 1 to -1 of stackObjects
end stack_PathsToObjects

function text_GetMergeVars mergeText
   -- put text_GetBetween ("[[", "]]", someText, startAfterCharNum)
   put "\[\[" into someReg
   put "[^\]]*" into notaSquareClosingBracket
   put "(" & notaSquareClosingBracket & ")" after someReg
   put "\]\]" after someReg
   --
   repeat 100 -- for safety
      if matchChunk (mergeText, someReg , startMatch, endMatch) is true then
         put char startMatch to endMatch of mergeText into varName
         put varName & CR after varNames
         delete char 1 to (endMatch + 2) of mergeText
      else
         delete char -1 of varNames
         return varNames
      end if
   end repeat
end text_GetMergeVars

function text_InitialCaps someText
   repeat with wordNum = 1 to the number of words of someText
      put tolower (word wordNum of someText) into someWord
      put toupper (char 1 of someWord ) into char 1 of someWord
      put someWord into word wordNum of someText
   end repeat
   return someText
end text_InitialCaps

command text_ReQuote @someText, pMergeValue
   replace "'" with quote in someText
   if pMergeValue is not empty then
      put pMergeValue into var
      put merge (someText) into someText
   end if
end text_ReQuote

function text_SplitCaps someWord
   -- was "capsSplit"
   put 1 into charNum
   repeat the number of chars of someWord
      put char charNum of someWord into someChar
      if text_StartsWithCaps(someChar) is true then
         put space before char charNum of someWord
         add 2 to charNum
      else
         add 1 to charNum
      end if
   end repeat
   put text_InitialCaps(word 1 of someWord) into word 1 of someWord
   return word 1 to -1 of someWord
end text_SplitCaps

function text_StartsWithCaps someText
   put char 1 of sometext into testChar
   put nativeCharToNum (testChar) into someCharNum
   if someCharNum >= 97 and someCharNum <= 122 then
      return false
   else
      return true
   end if
end text_StartsWithCaps

function view_GetTemplateObject viewName, pRepoFolder
   view_NormalizeName viewName
   put stack_FirstControl (viewName) into mObject
   --
   -- if exists (mObject) is false then put module_FromViewName (viewName, pRepoFolder) into mObject
   return mObject
end view_GetTemplateObject

command view_NormalizeName @viewPath
   if viewPath is empty then return false
   view_NormalizePiped viewPath
   
   set the itemdelimiter to "|"
   if item 1 of viewPath is not among the items of "View|Layout" then put "View|" before viewPath
   return true
end view_NormalizeName

command view_NormalizePiped @viewPath, pMakePretty
   if viewPath is empty then return false
   put word 1 to -1 of viewPath into viewPath
   
   set the itemdelimiter to "|"
   repeat with itemNum = 1 to the number of items of viewPath
      put word 1 to -1 of item itemNum of viewPath into someItem
      if pMakePretty is true then
         repeat for each word someWord in someItem
            put toUpper (char 1 of someWord) into char 1 of someWord
            put someWord & space after prettyItem
         end repeat
         put char 1 to -2 of prettyItem into someItem
      end if
      put someItem into item itemNum of viewPath
   end repeat
   return true
end view_NormalizePiped

getprop walk_Hierarchy
   put the long id of the target into tObject
   --
   if the module_Name of tObject is empty then
      put revRuggedID (tObject) into tObject
      put hierarchy_Construct (tObject) into walkHierarchy
      hierarchy_AddEnv walkHierarchy
   else
      put the module_BehaviorHierarchy of tObject into walkHierarchy
   end if
   return walkHierarchy
end walk_Hierarchy
