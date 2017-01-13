script "behavior_ViewIndexSimple"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewIndexSimple
type: view behavior
version: 0.5

/*
This view presents an index in a scrolling field, with full support for dynamic events.
*/

--> Variables
-
local LocalArray


--> Working on
-
--> Events
-
-- on nameChanged oldName, newName
-- here we change field and button names
-- this will break any references to them by name
-- but you shouldn't do that lightly anyway as this view hides it's inner workings.
set the name of _titleView() to newName
set the label of _titleView() to empty
set the name of _fieldObject() to newName
end nameChanged

on mouseDown
   switch word 1 of the name of the target
      case "button"
         _doButtonMenu
         break
      case "field"
         _doFieldDown
         break
   end switch
end mouseDown

on mouseUp
   switch word 1 of the name of the target
      case "button"
         break
      case "field"
         _doFieldClick
         break
   end switch
end mouseUp

on mouseDoubleUp
   switch word 1 of the name of the target
      case "button"
         break
      case "field"
         _doFieldDoubleClick
         break
   end switch
end mouseDoubleUp

on preOpenControl
   local headerHeight
   _setDefaultHeight headerHeight
   if there is a stack "behavior_ViewIndexFiles" then
      put the name of stack "behavior_ViewIndexFiles" into bObject
      set the behavior of stack "behavior_ViewIndexSimple" to bObject
   end if
   pass preOpenControl
end preOpenControl

on resizeControl
   put the rect of me into viewRect
   LayoutControl viewRect
end resizeControl


--> Events | Custom
-
on refreshDisplay
   -- put the rect of this card into cardRect
   put the rect of me into viewRect
   LayoutControl viewRect
end refreshDisplay

command LayoutControl pRect
   lock screen
   if pRect is empty then put the rect of me into pRect
   
   if the showborder of me is true then
      put the borderwidth of me into bWidth
      rect_SubtractMargins pRect, bWidth
   end if
   rect_SubtractMargins pRect, the margins of me
   
   set the rect of _titleView() to _headerRect (pRect)
   set the rect of _fieldObject() to _fieldRect (pRect)
   unlock screen
end LayoutControl

getprop formatted_Rect
   -- utility function not needed for LayoutControl
   
   put _fieldObject() into fieldObject
   put _titleView() into titleView
   put the rect of me into pRect
   
   put the effective height of titleView into titleHeight
   put the formattedheight of fieldObject into formattedFieldHeight
   add 45 to formattedFieldHeight
   put max (90, formattedFieldHeight) into newHeight
   
   put the formattedwidth of titleView into formattedTitleWidth
   put the formattedwidth of fieldObject into formattedFieldWidth
   put max (formattedTitleWidth, formattedFieldWidth) into fWidth
   add 30 to fWidth
   put max (180, fWidth) into newWidth
   
   put item 1 of pRect + newWidth into newRight
   put item 2 of pRect + newHeight into newBottom
   
   put pRect into fRect
   put newRight into item 3 of fRect
   put newBottom into item 4 of fRect
   
   return fRect
end formatted_Rect


--> Menus
-
getprop menu_Target [mTitlePath]
   put LocalArray ["menuTarget"] into mTarget
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
   put mTarget into LocalArray ["menuTarget"]
end menu_Target

getprop view_MenuArray
   put the title_Menu of me into menuArray ["title"]
   put the line_Menu of me into menuArray ["line"]
   return menuArray
end view_MenuArray

setprop view_MenuArray menuArray
   set the title_Menu of me to menuArray ["title"]
   set the line_Menu of me to menuArray ["line"]
end view_MenuArray

getprop title_Menu
   put LocalArray ["title_Menu"] into titleMenuName
   return titleMenuName
end title_Menu

setprop title_Menu titleMenuName
   put titleMenuName into LocalArray ["title_Menu"]
end title_Menu

getprop line_Menu
   put LocalArray ["line_Menu"] into lineMenuTitle
   if lineMenuTitle is empty then
      put "List | Menu" into lineMenuTitle -- a local menu to the field
      put CR & "-" after lineMenuTitle
      put CR & "Global | IndexView | Line | Menu" after lineMenuTitle -- a local menu to the field
      put tab & "submenu" & tab & "Tools" after lineMenuTitle
   end if
   return lineMenuTitle
end line_Menu

setprop line_Menu lineMenuName
   put lineMenuName into LocalArray ["line_Menu"]
end line_Menu


--> Index | Title
-
getprop stack_Title
   put the title_Text of me into indexDisplayTitle
   put indexDisplayTitle into stackTitle
   
   put the defaultstack into stackObject
   put the label of stackObject into displayStackLabel
   if displayStackLabel is not empty then
      put displayStackLabel into item 2 of stackTitle
   end if
   return stackTitle
end stack_Title

setprop stack_Title displayTitle
   put word 1 to -1 of item 1 of displayTitle into indexDisplayTitle
   put word 1 to -1 of item 2 of displayTitle into displayStackLabel
   
   put the defaultstack into stackObject
   set the label of stackObject to displayStackLabel
   set the title_Text of me to indexDisplayTitle
end stack_Title

getprop title_Text
   put the effective label of _titleView() into someTitle
   -- put the short name of _titleView() into someTitle
   return someTitle
end title_Text

setprop title_Text [setName] someTitle
   lock screen
   if setName is true then
      set the name of me to someTitle
      set the label of _titleView() to empty
   else
      set the label of _titleView() to someTitle
   end if
   unlock screen
end title_Text


--> Index | Selected
-
getprop line_Colour [lineNum]
   put _fieldObject() into fieldObject
   if lineNum is empty then
      put line 1 of the hilitedlines of fieldObject into lineNum
   end if
   put the textcolor of line lineNum of fieldObject into someColour
   return someColour
end line_Colour

setprop line_Colour [lineNumList] someColour
   put _fieldObject() into fieldObject
   if lineNumList is empty then
      put line 1 of the hilitedlines of fieldObject into lineNumList
   end if
   
   lock screen
   repeat for each item lineNum in lineNumList
      set the textcolor of line lineNum of fieldObject to someColour
   end repeat
   unlock screen
end line_Colour

getprop hilited_Lines
   put the hilitedlines of _fieldObject() into lineNumList
   return lineNumList
end hilited_Lines

setprop hilited_Lines lineNumList
   replace CR with comma in lineNumList
   set the hilitedlines of _fieldObject() to lineNumList
   return lineNumList
end hilited_Lines

getprop selected_Line
   put the selected_Index of _fieldObject() into someIndex
   return line 1 of someIndex
end selected_Line

setprop selected_Line someLine
   set the selected_Index of me to line 1 of someLine
end selected_Line

getprop selected_Index
   put the selectedtext of _fieldObject() into someIndex
   return someIndex
end selected_Index

setprop selected_Index someLines
   put the view_Index of me into viewIndex
   set the itemdelimiter to slash
   repeat for each line someLine in someLines
      put lineOffset (someLine, viewIndex) into lineNum
      if lineNum > 0 then
         put lineNum & comma after lineNumList
      end if
   end repeat
   delete char -1 of lineNumList
   
   set the hilitedlines of _fieldObject() to lineNumList
   return lineNumList
end selected_Index


--> Field | Props
-
getprop lock_Text
   put the locktext of _fieldObject() into someBoolean
   return someBoolean
end lock_Text

setprop lock_Text someBoolean
   set the locktext of _fieldObject() to someBoolean
end lock_Text

getprop view_Text
   return the view_Index of me
end view_Text

setprop view_Text someText
   lock screen
   set the view_Index of me to someText
   set the field_Style of me to "text"
   unlock screen
end view_Text

getprop field_Style
   put _fieldObject() into fieldView
   switch
      case the dontwrap of fieldView = false
         return "text"
      case the multiple_Hilites of fieldView = false
         return "scrolling"
      default
         return "multiselect"
   end switch
end field_Style

setprop field_Style someStyle
   put _fieldObject() into fieldView
   lock screen
   switch someStyle
      case "text"
         set the listbehavior of fieldView to false
         set the dontwrap of fieldView to false
         set the locktext of fieldView to false
         break
      case "scrolling"
         set the listbehavior of fieldView to true
         set the multiple_Hilites of fieldView to false
         set the dontwrap of fieldView to true
         set the locktext of fieldView to true
         break
      case "multiselect"
         set the listbehavior of fieldView to true
         set the multiple_Hilites of fieldView to true
         set the dontwrap of fieldView to true
         set the locktext of fieldView to true
         break
   end switch
   unlock screen
end field_Style

getprop field_Styles
   return "text,scrolling,multiselect"
end field_Styles

getprop dont_Wrap
   put the dontwrap of _fieldObject() into someBoolean
   return someBoolean
end dont_Wrap

setprop dont_Wrap someBoolean
   put _fieldObject() into fieldView
   -- set the listbehavior of fieldView to someBoolean
   set the dontwrap of fieldView to someBoolean
   return fieldView
end dont_Wrap

getprop multiple_Hilites
   put the multiplehilites of _fieldObject() into someBoolean
   return someBoolean
end multiple_Hilites

setprop multiple_Hilites someBoolean
   set the multiplehilites of _fieldObject() to someBoolean
   set the nonContiguousHilites of _fieldObject() to someBoolean
   set the toggleHilites of _fieldObject() to someBoolean
end multiple_Hilites


--> Events | Handlers
-
private command _doFieldClick
   put the mouse_UpEvent of me into mouseUpEvent
   if mouseUpEvent is empty then return empty
   
   put the clickText into someLine
   put the long id of me into targetControl
   put the event_Target of me into eventTarget
   if exists (eventTarget) is true then
      dispatch mouseUpEvent to eventTarget with targetControl,someLine
   else
      dispatch mouseUpEvent to me with targetControl,someLine
   end if
   return mouseUpEvent
end _doFieldClick

private command _doFieldDoubleClick
   put the mouse_DoubleUpEvent of me into mouseDoubleUpEvent
   if mouseDoubleUpEvent is empty then return empty
   
   put the event_Target of me into eventTarget
   if exists (eventTarget) is true then
      put the long id of me into targetControl
      put the clickText into someLine
      dispatch mouseDoubleUpEvent to eventTarget with targetControl,someLine
   else
      do mouseDoubleUpEvent
   end if
   return mouseDoubleUpEvent
end _doFieldDoubleClick

private command _doButtonMenu
   put the title_Menu of me into mTitle
   switch
      case the controlkey is "Down"
         menu_PullDown "Global | Index | Simple | Menu"
         break
      case mTitle is not empty
         menu_PullDown mTitle
         break
      default
         menu_PullDown "Title | Menu"
   end switch
end _doButtonMenu

private command _doFieldDown
   put word 2 of the clickline into cNum
   if the controlkey is "Down" then
      set the hilitedlines of the target to cNum
      put the line_Menu of me into mTitle
      menu_PopUp mTitle
   else
      put the drag_Command of me into dCommand
      if dCommand is empty then return false
      
      -- this also gets triggered on simple mouseDown
      -- consider using mouseStillDown ?
      
      put the selectedtext of the target into someText
      -- set the dragImage to 3137
      set the dragAction to "copy"
      set the dragData ["text"] to someText
      
      put the long id of me into targetControl
      put the event_Target of me into eventTarget
      dispatch dCommand to eventTarget with targetControl,someText
      put the result into vName
      set the dragData ["private"] to vName
      return true
   end if
end _doFieldDown


--> Index | Displayed
-
getprop displayed_Object
   -- put LocalArray ["displayedObject"] into displayedObject
   put the displayed_Object of me into displayedObject -- so it is stored for each view
   if exists (displayedObject) is false then return the long id of me
   return displayedObject
end displayed_Object

setprop displayed_Object displayedObject
   -- put displayedObject into LocalArray ["displayedObject"]
   set the displayed_Object of me to displayedObject -- so it is stored for each view
end displayed_Object

-- getprop displayed_Data -- not needed???
put the view_Index of me into someIndex
return someIndex
end displayed_Data

-- setprop displayed_Data someIndex -- not needed???
set the view_Index of me to someIndex
end displayed_Data

getprop displayed_Text
   return the view_Index of me
end displayed_Text

setprop displayed_Text someText
   set the view_Index of me to someText
   return the result
end displayed_Text

getprop displayed_Index
   return the view_Index of me
end displayed_Index

setprop displayed_Index someIndex
   set the view_Index of me to someIndex
   return the result
end displayed_Index

getprop view_Index
   put the text of _fieldObject() into someIndex
   return someIndex
end view_Index

setprop view_Index [someTitle] someIndex
   lock screen
   put _fieldObject() into fieldObject
   if someTitle is not empty then
      set the title_Text of me to someTitle
   end if
   set the text of fieldObject to someIndex
   unlock screen
   return fieldObject
end view_Index


--> EventArray
-
getprop view_EventArray eventArray   
   put the event_Target of me into eventArray ["eventTarget"]
   put the drag_Command of me into eventArray ["dragCommand"]
   put the mouse_UpEvent of me into eventArray ["mouseUp"]
   put the mouse_DoubleUpEvent of me into eventArray ["mouseDoubleUp"]
   return eventArray
end view_EventArray

setprop view_EventArray eventArray   
   put eventArray ["dragCommand"] into LocalArray ["event"]["dragCommand"]
   put eventArray ["eventTarget"] into LocalArray ["event"]["eventTarget"]
   put eventArray ["mouseUp"] into LocalArray ["event"]["mouseUp"]
   put eventArray ["mouseDoubleUp"] into LocalArray ["event"]["mouseDoubleUp"]
end view_EventArray

getprop event_Target
   put LocalArray ["event"]["eventTarget"] into eventTarget
   return eventTarget
end event_Target

setprop event_Target eventTarget
   put eventTarget into LocalArray ["event"]["eventTarget"]
end event_Target

getprop drag_Command
   put LocalArray ["event"]["dragCommand"] into dragCommand
   return dragCommand
end drag_Command

setprop drag_Command dragCommand
   put eventTarget into LocalArray ["event"]["dragCommand"]
end drag_Command

getprop mouse_UpEvent
   put LocalArray ["event"]["mouseUp"] into mouseUpEvent
   return mouseUpEvent
end mouse_UpEvent

setprop mouse_UpEvent mouseUpEvent
   put mouseUpEvent into LocalArray ["event"]["mouseUp"]
end mouse_UpEvent

getprop mouse_DoubleUpEvent
   put LocalArray ["event"]["mouseDoubleUp"] into mouseDoubleUp
   return mouseDoubleUp
end mouse_DoubleUpEvent

setprop mouse_DoubleUpEvent mouseDoubleUp
   put mouseDoubleUp into LocalArray ["event"]["mouseDoubleUp"]
end mouse_DoubleUpEvent


--> Names and Titles
-
/*
Rationalise these naames and check other external handlers do not reference old ones.
*/

getprop group_Name
   put the short name of me into someTitle
   return someTitle
end group_Name

setprop group_Name [someColour] someTitle
   lock screen
   set the label of _titleView() to someTitle
   set the name of me to someTitle
   set the title_Colour of me to someColour
   unlock screen
end group_Name


--> Title | Colours
-
getprop title_Colour
   return the backgroundcolor of _titleView()
end title_Colour

setprop title_Colour someColour
   if someColour is "random" then put colour_GetRandom() into someColour
   set the backgroundcolor of _titleView() to someColour
   return someColour
end title_Colour

getprop title_TextColour
   return the foregroundcolor of _titleView()
end title_TextColour

setprop title_TextColour someColour
   if someColour is "random" then put colour_GetRandom() into someColour
   set the foregroundcolor of _titleView() to someColour
   return someColour
end title_TextColour


--> Geometry
-
getprop header_Height
   return _headerHeight()
end header_Height

setprop header_Height headerHeight
   put headerHeight into LocalArray ["headerHeight"]
   refreshDisplay
   return the result
end header_Height


--> Objects
-
getprop view_Object
   return the long id of me
end view_Object

getprop index_View
   return the long id of me
end index_View

getprop index_Field
   return _fieldObject()
end index_Field


--> Private
-
private function _titleView
   put the long id of btn 1 of me into headerWidget
   return headerWidget
end _titleView

private function _fieldObject
   put the long id of field 1 of me into arrayWidget
   return arrayWidget
end _fieldObject

private function _headerRect someRect
   put item 2 of someRect + _headerHeight() into item 4 of someRect
   return someRect
end _headerRect

private function _fieldRect someRect
   add _headerHeight() to item 2 of someRect
   return someRect
end _fieldRect

private function _headerHeight
   put LocalArray ["headerHeight"] into headerHeight
   _setDefaultHeight headerHeight
   return headerHeight
end _headerHeight

private command _setDefaultHeight @headerHeight
   if headerHeight is empty then
      -- let's set a default
      put 30 into headerHeight
      put headerHeight into LocalArray ["headerHeight"]
   end if
end _setDefaultHeight


--> Deps
-
function colour_GetRandom
   put random(255) into item 1 of someColour
   put random(255) into item 2 of someColour
   put random(255) into item 3 of someColour
   return someColour
end colour_GetRandom

command rect_SubtractMargins @someRect, pMargin
   margin_Normalize pMargin, leftM, topM, rightM, bottomM   
   add leftM to item 1 of someRect
   add topM to item 2 of someRect
   subtract rightM from item 3 of someRect
   subtract bottomM from item 4 of someRect
end rect_SubtractMargins

command margin_Normalize @someMargin, @leftM, @topM, @rightM, @bottomM
   -- fixed bug in setting bottomM when 4th item is empty
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
   put leftM,topM,rightM,bottomM into someMargin
end margin_Normalize
