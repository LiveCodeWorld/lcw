script "behavior_ViewIndex"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewIndex
type: behavior
version: 0.2

/*
This view presents an index in a scrolling field, with full support for dynamic events.
This script is activated for every LCW menu call that is not handled locally.
For instance the ScriptEditor menus use the "menuPick" handler below.
*/

--> Variables
-
local LocalArray


--> Working on
-


--> Displayed
-
getprop displayed_HtmlText
   return the htmltext of _FieldObject()
end displayed_HtmlText

setprop displayed_HtmlText someHTML
   set the htmltext of _FieldObject() to someHTML
end displayed_HtmlText

getprop displayed_Index
   return the text of _FieldObject()
end displayed_Index

setprop displayed_Index someIndex
   set the text of _FieldObject() to someIndex
end displayed_Index


--> Mouse
-
getprop mouse_Controller
   -- put the mouse_Target of me into mouseController
   put the uOPN ["mouse_Controller"] of me into mouseController
   if exists (mouseController) is true then return mouseController
   
   put the menu_Controller of me into mouseController
   if exists (mouseController) is true then return mouseController
   
   return the data_View of me
end mouse_Controller

setprop mouse_Controller mouseController
   set the uOPN ["mouse_Controller"] of me to mouseController
end mouse_Controller


--> Events
-
on mouseDoubleUp
   put the clickText into cText
   put the doubleClick_Message of me into mDoubleUp 
   put the mouse_Controller of me into mController
   put the long id of me into tObject
   
   if mDoubleUp is empty then
      pass mouseDoubleUp
   end if
   
   dispatch mDoubleUp to mController with tObject,cText
   switch
      case it is "unhandled"
         breakpoint
         edit the script of mController
         break
      case the optionKey is "Down"
         if exists (mController) then
            put mDoubleUp
            edit the script of mController
         else
            breakpoint
         end if
   end switch
end mouseDoubleUp

getprop doubleClick_Message
   put the uOPN ["doubleClick_Message"] of me into mDoubleUp
   if mDoubleUp is empty then return "doubleClick_Message"
   return mDoubleUp
end doubleClick_Message

setprop doubleClick_Message [mTarget] mDoubleUp
   set the uOPN ["doubleClick_Message"] of me to mDoubleUp
end doubleClick_Message


--> Events | MouseUp
-
on mouseUp
   put the mouse_Up of me into mUpCommand
   if mouseUpEvent is empty then return empty
   
   put the clickText into cText
   put the long id of me into tObject
   put the mouse_Target of me into mTarget
   
   if exists (mTarget) is true then
      dispatch mUpCommand to mTarget with tObject,cText
   else
      dispatch mUpCommand to me with tObject,cText
   end if
end mouseUp

getprop mouse_Up
   put the mouse_Up of me into mUp
   return mUp
end mouse_Up

setprop mouse_Up mouseUpEvent
   set the mouse_Up of me to mUp
end mouse_Up


--> Events | MouseDown
-
on mouseDown
   if the controlkey is "Down" then
      put the menu_Title of me into mTitle
      put the menu_Button of me into mButton
      mArray_PopUp mTitle, mButton
   end if
end mouseDown

on menuPick menuPath
   menu_TextPick menuPath
end menuPick


--> Props | Menu | Model
-
getprop menu_Title
   -- set the uOPN ["menu_Title"] of me to empty
   put the uOPN ["menu_Title"] of me into mTitle
   return mTitle
end menu_Title

setprop menu_Title mTitle
   set the uOPN ["menu_Title"] of me to mTitle
end menu_Title

getprop default_MenuTitle
   put the uRIP ["name"] of me into vName
   return menu_ConstructTitle (vName)
end default_MenuTitle

getprop default_LineMenuTitle
   put the default_MenuTitle of the target into lineTitle
   put "Line | " before word -1 of lineTitle
   return lineTitle
end default_LineMenuTitle

getprop menu_Controller [mTitle]
   put the uOPN ["menu_Controller"] of me into mController
   if exists (mController) then return mController
   
   if mTitle is empty then
      put the menu_Title of me into mTitle
   end if
   if mTitle is empty then return empty
   
   put menu_GetGlobalController (mTitle) into mController
   return mController
end menu_Controller

setprop menu_Controller mController
   set the uOPN ["menu_Controller"] of me to mController
end menu_Controller

getprop menu_Target
   put the uOPN ["menu_Target"] of me into mTarget
   switch 
      case mTarget is not empty
         return mTarget
      default
         return the long id of me
   end switch
end menu_Target

setprop menu_Target [mTitlePath] mTarget
   set the uOPN ["menu_Target"] of me to mTarget
end menu_Target


--> Drag
-
on dragDrop
   put the drop_Command of me into dCommand
   if dCommand is empty then pass dragDrop
   
   put the long id of me into displayView
   put the dragdata ["text"] into dData ["text"]
   put the dragdata ["files"] into dData ["files"]
   put the dragdata ["html"] into dData ["html"]
   put the dragdata ["image"] into dData ["image"]
   put displayView into dData ["displayView"]
   --
   put the drop_Target of me into dTarget
   --
   dispatch dCommand to dTarget with displayView,dData
   switch it
      case "handled"
         break
      case "unhandled"
         put the dragdata ["text"] into someURL
         put someURL
         break
      case "passed"
         break
   end switch
end dragDrop

on dragEnter
   put the drop_Command of me into dCommand
   if dCommand is empty then pass dragEnter
   
   set the dragAction to "link"
end dragEnter

getprop drop_Command
   put LocalArray ["event"]["dragCommand"] into dragCommand
   return dragCommand
end drop_Command

setprop drop_Command dragCommand
   put dragCommand into LocalArray ["event"]["dragCommand"]
end drop_Command

getprop drop_Target
   put LocalArray ["drop_Target"] into darget
   if darget is empty then return the long id of the target
   return darget
end drop_Target

setprop drop_Target darget
   put darget into LocalArray ["drop_Target"]
end drop_Target


--> Props
-
getprop formatted_Height [titleHeight]
   put _FieldObject() into fObject
   put the formattedheight of fObject into fHeight
   add 4 to fHeight
   return fHeight
end formatted_Height

getprop formatted_Width
   put _FieldObject() into fObject
   put the formattedwidth of fObject into fWidth
   
   # Scrollbar
   if the vScrollbar of fObject is true then
      put the scrollbarWidth of fObject into sWidth
      add sWidth to fWidth
   end if
   
   add 8 to fWidth
   return fWidth
end formatted_Width

getprop max_LineNum
   put the displayed_Index of me into dLines
   return the number of lines of dLines
end max_LineNum

setprop deleted_LineNums lineNumList
   replace comma with CR in lineNumList
   sort descending numeric lineNumList
   
   lock screen
   repeat for each line lineNum in lineNumList
      if lineNum is a number then
         put the short id of _FieldObject() into fldID
         delete line lineNum of fld id fldID of me
      end if
   end repeat
   unlock screen
end deleted_LineNums

setprop deleted_Line someLine
   if someLine is a number then
      put someLine into lineNum
   else
      put the line_Number [someLine] of me into lineNum
   end if
   --
   put the short id of _FieldObject() into fldID
   delete line lineNum of fld id fldID of me
   return lineNum
end deleted_Line

getprop tab_Stops tStops
   put the tabstops of _FieldObject() into tStops
   return tStops
end tab_Stops

setprop tab_Stops tStops
   set the tabstops of _FieldObject() to tStops
end tab_Stops


--> Coloured
-
getprop selected_LineColour
   put _FieldObject() into fldObject
   put the hilitedlines of fldObject into lineNumList
   repeat for each line lineNum in lineNumList
      put the textcolor of line lineNum of fldObject & CR after sLineColours
   end repeat
   delete char -1 of sLineColours
   return sLineColours
end selected_LineColour

getprop line_Colour [lineNum]
   put _FieldObject() into fldObject
   if lineNum is empty then
      put line 1 of the hilitedlines of fldObject into lineNum
   end if
   put the effective textcolor of line lineNum of fldObject into someColour
   return someColour
end line_Colour

setprop line_Colour [lineNumList] someColour
   put _FieldObject() into fldObject
   if lineNumList is empty then
      put line 1 of the hilitedlines of fldObject into lineNumList
   end if
   
   lock screen
   put the displayed_Index of me into displayedIndex
   repeat for each item lineNum in lineNumList
      if lineNum is not a number then
         put lineOffset (lineNum, displayedIndex) into lineNum
         if lineNum is not a number then
            next repeat
         end if
      end if
      --
      set the textcolor of line lineNum of fldObject to someColour
   end repeat
   unlock screen
end line_Colour

getprop coloured_Lines [someColour]
   if someColour = "none" then put empty into someColour
   colour_RgbNormalise someColour
   
   put _FieldObject() into fldObject
   put the text of fldObject into displayedIndex
   --
   repeat with lineNum = 1 to the number of lines of displayedIndex
      get the textcolor of line lineNum of fldObject
      if it = someColour then
         put line lineNum of displayedIndex into someLine
         put someLine & CR after colouredLines
      end if
   end repeat
   delete char -1 of colouredLines
   return colouredLines
end coloured_Lines

setprop coloured_Lines [someColour] someIndex
   if someColour = "none" then put empty into someColour
   
   put _FieldObject() into fldObject
   put the text of fldObject into displayedIndex
   --
   lock screen
   switch
      case someIndex is empty
         put the number of lines of displayedIndex into maxNum
         repeat with lineNum = 1 to maxNum
            set the textcolor of line lineNum of fldObject to empty
         end repeat
         break
      case someIndex = "all"
         put the number of lines of displayedIndex into maxNum
         repeat with lineNum = 1 to maxNum
            set the textcolor of line lineNum of fldObject to someColour
         end repeat
         break
      case someIndex is an array
         put the keys of someIndex into someIndex
      default
         lock screen
         repeat for each line someLine in someIndex
            put lineOffset (someLine, displayedIndex) into lineNum
            set the textcolor of line lineNum of fldObject to someColour
         end repeat
   end switch
   unlock screen
end coloured_Lines

getprop coloured_Array [someColour]
   put _FieldObject() into fldObject
   
   put the number of lines of the text of fldObject into maxNum
   repeat with lineNum = 1 to maxNum
      put the textcolor of line lineNum of fldObject into foundColour
      if foundColour = empty then put "none" into foundColour
      put the textstyle of line lineNum of fldObject into someStyle
      put someStyle into colourArray [foundColour][lineNum]
   end repeat
   
   if someColour is empty then
      return colourArray
   else
      put colourArray [someColour] into lineArray
      put keys (lineArray) into lineNums
      sort numeric lineNums
      return lineNums
   end if
end coloured_Array

setprop coloured_Array colourArray
   put _FieldObject() into fldObject
   
   lock screen
   repeat for each key someColour in colourArray
      put colourArray [someColour] into lineNumArray
      if someColour = "none" then put empty into someColour
      repeat for each key lineNum in lineNumArray
         set the textcolor of line lineNum of fldObject to someColour
      end repeat
   end repeat
   unlock screen
end coloured_Array


--> Selected
-
getprop selected_LineNums
   put the hilitedlines of _FieldObject() into sIndex
   return sIndex
end selected_LineNums

getprop selected_Line
   put the selected_Index of _FieldObject() into someIndex
   return line 1 of someIndex
end selected_Line

setprop selected_Line someLine
   set the selected_Index of me to line 1 of someLine
   put the result into lineNum
   return lineNum
end selected_Line

getprop selected_Index
   put the selectedtext of _FieldObject() into someIndex
   return someIndex
end selected_Index

setprop selected_Index someLines
   put the displayed_Index of me into viewIndex
   set the itemdelimiter to slash
   set the wholematches to true
   repeat for each line someLine in someLines
      put lineOffset (someLine, viewIndex) into lineNum
      if lineNum > 0 then
         put lineNum & comma after lineNumList
      end if
   end repeat
   delete char -1 of lineNumList
   
   set the hilitedlines of _FieldObject() to lineNumList
   return lineNumList
end selected_Index

getprop selected_Value
   put the selectedtext of _FieldObject() into someIndex
   put LocalArray ["displayed_Data"] into someArray
   put someArray [someIndex] into someValue
   return someValue
end selected_Value

setprop selected_Value someValue
   put LocalArray ["displayed_Data"] into someArray
   put the displayed_Index of me into viewIndex
   repeat with lineNum = 1 to the number of lines of viewIndex
      put line lineNum of viewIndex into testLine
      put someArray [testLine] into testValue
      if testValue = someValue then
         set the hilitedlines of _FieldObject() to lineNum
         return lineNum
      end if
   end repeat
   set the hilitedlines of _FieldObject() to 0
   return 0
end selected_Value


--> Line | Number
-
getprop line_Number [someLine]
   if someLine is empty then
      return the hilited_Line of me
   end if
   put the displayed_Index of _FieldObject() into someIndex
   set the wholeMatches to true
   put lineOffset (someLine, someIndex) into lineNum
   return lineNum
end line_Number

setprop line_Number [someLine] someValue
   put the displayed_Index of _FieldObject() into someIndex
   set the wholeMatches to true
   put lineOffset (someLine, someIndex) into lineNum
   if lineNum is 0 then return 0
   
   put the short id of _FieldObject() into fldID
   set the text of line lineNum of fld id fldID of me to someValue
   return lineNum
end line_Number


--> Selected | LineNumber

getprop selected_LineNumber
   put the hilitedlines of _FieldObject() into lineNumList
   return lineNumList
end selected_LineNumber

setprop selected_LineNumber lineNumList
   put _FieldObject() into fldObject
   replace CR with comma in lineNumList
   set the hilitedlines of fldObject to lineNumList
   return fldObject
end selected_LineNumber

getprop selected_LineNum
   return the selected_LineNumber of me
end selected_LineNum

setprop selected_LineNum lineNumList
   set the selected_LineNumber of me to lineNumList
end selected_LineNum

getprop hilited_Line
   put the selected_LineNumber of me into lineNumList
   return item 1 of lineNumList
end hilited_Line

setprop hilited_Line lineNum
   set the selected_LineNumber of _FieldObject() to lineNum
   put the result into fldObject
   return fldObject
end hilited_Line

getprop hilited_Lines
   return the selected_LineNumber of _FieldObject()
end hilited_Lines

setprop hilited_Lines lineNumList
   set the selected_LineNumber of me to lineNumList
end hilited_Lines


--> Field | Props
-
getprop lock_Text
   put the locktext of _FieldObject() into someBoolean
   return someBoolean
end lock_Text

setprop lock_Text someBoolean
   set the locktext of _FieldObject() to someBoolean
end lock_Text

getprop field_Align
   put _FieldObject() into fieldView
   put the textalign of fieldView into fieldAlign
   return fieldAlign
end field_Align

setprop field_Align fieldAlign
   put _FieldObject() into fieldView
   set the textalign of fieldView to fieldAlign
   return fieldView
end field_Align

getprop field_Aligns
   return "left,right"
end field_Aligns

getprop field_Style
   put _FieldObject() into fieldView
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
   put _FieldObject() into fieldView
   lock screen
   switch someStyle
      case "text"
         set the listbehavior of fieldView to false
         set the dontwrap of fieldView to false
         set the locktext of fieldView to false
         set the autoHilite of fieldView to true
         set the fixedLineHeight of fieldView to false
         break
      case "click"
         set the fixedLineHeight of fieldView to true
         set the listbehavior of fieldView to true
         set the multiple_Hilites of fieldView to false
         set the dontwrap of fieldView to true
         set the locktext of fieldView to true
         set the autoHilite of fieldView to true
         set the toggleHilites of fieldView to false
         break
      case "scrolling"
         set the fixedLineHeight of fieldView to true
         set the listbehavior of fieldView to true
         set the multiple_Hilites of fieldView to false
         set the dontwrap of fieldView to true
         set the locktext of fieldView to true
         set the autoHilite of fieldView to true
         break
      case "multiselect"
         set the fixedLineHeight of fieldView to true
         set the listbehavior of fieldView to true
         set the multiple_Hilites of fieldView to true
         set the dontwrap of fieldView to true
         set the locktext of fieldView to true
         set the autoHilite of fieldView to true
         break
      case "display selected"
         set the fixedLineHeight of fieldView to true
         set the listbehavior of fieldView to true
         set the multiple_Hilites of fieldView to true
         set the toggle_Hilites of fieldView to false
         set the dontwrap of fieldView to true
         set the locktext of fieldView to true
         set the autoHilite of fieldView to false
         break
   end switch
   set the field_Style of me to someStyle
   unlock screen
end field_Style

getprop field_Styles
   return "text,click,scrolling,multiselect,display selected"
end field_Styles

getprop dont_Wrap
   put the dontwrap of _FieldObject() into someBoolean
   return someBoolean
end dont_Wrap

setprop dont_Wrap someBoolean
   put _FieldObject() into fieldView
   set the dontwrap of fieldView to someBoolean
   return fieldView
end dont_Wrap

getprop multiple_Hilites
   put the multiplehilites of _FieldObject() into sBoolean
   return sBoolean
end multiple_Hilites

setprop multiple_Hilites sBoolean
   set the multiplehilites of _FieldObject() to sBoolean
   set the nonContiguousHilites of _FieldObject() to sBoolean
end multiple_Hilites

getprop toggle_Hilites
   put the toggleHilites of _FieldObject() into sBoolean
   return sBoolean
end toggle_Hilites

setprop toggle_Hilites sBoolean
   set the toggleHilites of _FieldObject() to sBoolean
end toggle_Hilites


--> Objects
-
private function _FieldObject
   put the long id of field 1 of me into arrayWidget
   return arrayWidget
end _FieldObject
