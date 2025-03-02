script "behavior_DisplayArray"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_DisplayArray
type: behavior
version: 0.8

/*
This behavior_DisplayArray script only stack behavior controls the properties of the stack "Display Array".
*/

--> Variables
-
local LocalArray


--> Working on
-
getprop displayed_Object [tObject]
   put the uOPN ["displayed_Object"] of me into dView
   if exists (dView) then
      return dView
   else
      return empty
      return the long id of me
   end if
end displayed_Object

setprop displayed_Object dView
   set the uOPN ["displayed_Object"] of me to dView
end displayed_Object

private function _DefaultMouseTarget tObject
   put the line_Controller of me into mouseTarget
   if exists (mouseTarget) is false then
      put tObject into mouseTarget
   end if
   return mouseTarget
end _DefaultMouseTarget

getprop line_Controller
   put the line_Controller of me into mController
   if exists (mController) then return mController
   
   ## Default
   put the line_Menu of me into mTitle
   put menu_GetGlobalController(mTitle) into mController
   return mController
end line_Controller

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

command actionDoubleClick pathItems
   put the selected_Value of me into someValue
   put the mouse_DoubleUp of me into mouseDoubleUpCommand
   --
   if mouseDoubleUpCommand is empty then
      pass actionDoubleClick
   else
      _SetMouseTargets tObject, displayView, mouseTarget
      replace comma with CR in pathItems
      dispatch mouseDoubleUpCommand to mouseTarget with displayView,someValue,pathItems
      if it is "unhandled" then
         -- breakpoint
         dispatch "ask_CreateMouseDoubleUpHandler" to me with mouseDoubleUpCommand
         -- edit the script of mouseTarget
      end if
   end if
end actionDoubleClick

getprop menu_Controller
   -- depends on the target (allows two menus for the titel and the field)
   get the target
   switch word 1 of it
      case "field"
         put the line_Controller of the target into mController
         break
      default
         put the title_Controller of the target into mController
   end switch
   return mController
end menu_Controller

getprop tool_MenuBit
   -- return the tool_MenuBit name = menuBit
   get the title_Menu of me
   set the itemdelimiter to "|"
   put word 1 to -1 of item 2 to -2 of it into menuBit
   return menuBit
end tool_MenuBit

setprop tool_MenuBit [libName] menuBit
   -- used to use "display_SetToolMenus"
   put the menu_Button of me into mButton
   set the tool_LibName of me to libName
   --
   -- set the menumode of mButton to "pulldown"
   -- set the style of mButton to "menu"
   
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
   dispatch "ask_CreateMenuFromObject" to me with titleMenu,libName
   
   if the shiftKey is "Down" then
      dispatch "ask_CreateMenuFromObject" to me with lineMenu,libName
      dispatch "ask_CreateMouseDoubleUpHandler" to me with mDoubleUp
   end if
   --
   return titleMenu
end tool_MenuBit

getprop title_Controller
   put the title_Controller of me into mController
   if exists (mController) then return mController
   
   ## Default
   put the title_Menu of me into mTitle
   put menu_GetGlobalController(mTitle) into mController
   return mController
end title_Controller

getprop tree_IsIndex
   return LocalArray ["isIndex"] is true
end tree_IsIndex

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

private command _SetMouseTargets @tObject, @displayView, @mouseTarget
   put the long id of the target into tObject
   put the long id of me into displayView
   put the mouse_Target of me into mouseTarget
   if exists (mouseTarget) is false then
      put _DefaultMouseTarget (tObject) into mouseTarget
   end if
end _SetMouseTargets


--> Events
-
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
         put the title_menu of me into mTitle
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
   put _getValue (pathItems) into someValue
   put the mouse_Up of me into mouseUpCommand
   if mouseUpCommand is empty then
      pass actionInspect
   else
      _SetMouseTargets tObject, displayView, mouseTarget
      dispatch mouseUpCommand to mouseTarget with displayView,someValue
   end if
end actionInspect

on resizeControl
   put the rect of me into viewRect
   LayoutControl viewRect
end resizeControl

on hiliteChanged
   -- hack - cant stop the flicker when selecting line that is already selected
   -- called twice due to "set the hilitedElement"
   -- lock messages makes no difference
   if LocalArray ["just set hilitedElement"] is true then
      put false into LocalArray ["just set hilitedElement"]
      return empty
   end if
   
   put _treeWidget() into treeWidget
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
      put the line_Controller of me into mController
      --
      switch
         case exists (mController) is false
            breakpoint
            put the tool_LibName of me into libName
            ask_CreateMenuFromObject mTitle, libName
            break
         case mTitle is empty
            put "Global | Array | Line | Menu" into mTitle
            break
      end switch
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

on menuPick menuPath
   menu_DispatchTextPick menuPath
end menuPick


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


--> Props | Menu | Model
-
getprop title_Menu
   if the controlKey is "Down" then
      return "Global | Array | Menu"
   end if
   
   -- put the menu_Title of headerWidget into mTitle
   put the title_Menu of me into titleMenu
   if titleMenu is empty then 
      return "Global | Array | Menu"
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
   put the charsToTrimFromKey of _treeWidget() into padNum
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
   put _treeWidget() into treeWidget
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
   put _treeWidget() into treeWidget
   
   put the hilitedElement of treeWidget into commaKeys
   put the arrayData of treeWidget into someArray
   split commaKeys with comma
   put someArray [commaKeys] into selectedValue
   return selectedValue
end selected_Array

getprop menu_Button
   return _MenuButton()
end menu_Button

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
   put _treeWidget() into treeWidget
   
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
   put _treeWidget() into treeWidget
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


--> Props | Show
=
getprop show_Separator
   put _treeWidget() into treeWidget
   return the showSeparator of treeWidget
end show_Separator

setprop show_Separator sBoolean
   put _treeWidget() into treeWidget
   set the showSeparator of treeWidget to sBoolean
   return treeWidget
end show_Separator

getprop show_Values
   put _treeWidget() into treeWidget
   return the showValues of treeWidget
end show_Values

setprop show_Values sBoolean
   put _treeWidget() into treeWidget
   set the showValues of treeWidget to sBoolean
   return treeWidget
end show_Values

getprop show_Numbers
   put _treeWidget() into treeWidget
   put the charsToTrimFromKey of treeWidget into sNum
   return sNum = 0
end show_Numbers

setprop show_Numbers sBoolean
   put _treeWidget() into treeWidget
   
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

getprop trim_Num
   get the charsToTrimFromKey of _treeWidget()
   return it
end trim_Num

setprop trim_Num sNum
   set the charsToTrimFromKey of _treeWidget() to sNum
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
      set the arrayData of _treeWidget() to sData
      set the show_Values of me to true
      set the show_Numbers of me to true
      put false into LocalArray ["isIndex"]
      --
      if someTitle is not empty then
         set the title_Text of me to someTitle
      end if
   else
      set the displayed_Index [someTitle] of me to sData
   end if
   unlock screen
end displayed_Data

setprop displayed_Index [someTitle] someIndex
   lock screen
   repeat for each line someLine in someIndex
      put empty into someArray [someLine]
   end repeat
   --
   set the arrayData of _treeWidget() to someArray
   set the show_Values of me to false
   set the show_Numbers of me to true
   --
   if someTitle is not empty then
      -- set the stack_Title of me to someTitle
      set the title_Text of me to someTitle
   end if
   unlock screen
   put true into LocalArray ["isIndex"]
end displayed_Index

getprop displayed_Index
   put the arrayData of _treeWidget() into someArray
   put keys (someArray) into someIndex
   sort lines of someIndex
   return someIndex
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


--> ViewData | Model
-
getprop view_Data [someKey]
   -- put LocalArray ["view_Data"] into viewData
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
   put the foldState of _treeWidget() into foldedArray
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
   put the foldState of _treeWidget() into foldedArray
   return foldedArray 
end fold_State

setprop fold_State [pAddState] foldedArray
   -- sensitive to capitalisation
   put _treeWidget() into tWidget
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


--> Props | Menu
-
getprop view_MenuArray
   put the title_Menu of me into menuArray ["title"]
   put the line_Menu of me into menuArray ["line"]
   return menuArray
end view_MenuArray

setprop view_MenuArray menuArray
   set the title_Menu of me to menuArray ["title"]
   set the line_Menu of me to menuArray ["line"]
end view_MenuArray


--> Model | ArrayIndex
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


--> Top | Array
-
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
getprop selected_Path
   put _treeWidget() into treeWidget
   put the hilitedElement of treeWidget into commaPath
   if char -1 of commaPath is comma then delete char -1 of commaPath
   return commaPath
end selected_Path

setprop selected_Path commaPath
   put _treeWidget() into treeWidget
   set the hilitedElement of treeWidget to commaPath
   return treeWidget
end selected_Path

getprop selected_Line
   put _treeWidget() into treeWidget
   --
   put the hilitedElement of treeWidget into commaPath
   put the pathDelimiter of treeWidget into pDelim
   --
   set the itemdelimiter to pDelim
   put item -1 of commaPath into sLine
   return sLine
end selected_Line

setprop selected_Line commaPath
   put _treeWidget() into treeWidget
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
   put _treeWidget() into treeWidget
   
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
   put _treeWidget() into treeWidget
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


--> Private
-
private command tree_SetArray sArray, pPath
   put _treeWidget() into treeWidget
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
   put _treeWidget() into treeWidget
   put the hilitedElement of treeWidget into commaPath
   put item 1 of commaPath into topKey
   return topKey
end _GetTopKey

private command _SetTop @topKey, @aData
   put _treeWidget() into treeWidget
   put the arrayData of treeWidget into aData
   put the hilitedElement of treeWidget into commaPath
   --
   put item 1 of commaPath into topKey
   return commaPath
end _SetTop

private function _MyMenuButton
   if there is a btn "_Menu Button" of me then
      return the long id of btn "_Menu Button" of me
   else
      return empty    
   end if
end _MyMenuButton

private function _MenuButton
   put _MyMenuButton() into myMenuButton
   if exists (myMenuButton) then
      return myMenuButton
   else
      return menu_SimpleButton()      
   end if
end _MenuButton

function menu_SimpleButton
   if exists (stack "View|Index|Simple") is false then return empty
   put the long id of btn 1 of cd 1 of stack "View|Index|Simple" into mButton
   return mButton
end menu_SimpleButton

private command _displaySelectedValue pTreeWidget
   if pTreeWidget is empty then put _treeWidget() into pTreeWidget
   put the selected_Value of pTreeWidget into selectedValue
   
   dispatch "tree_HilightChanged" to me with selectedValue
end _displaySelectedValue

private function tree_GetData
   put the arrayData of _treeWidget() into treeData
   return treeData
end tree_GetData

private command tree_SetData treeData
   set the arrayData of _treeWidget() to treeData
end tree_SetData

private command tree_DeletePath somePath
   put _treeWidget() into treeWidget
   --
   put the arrayData of treeWidget into treeData
   treeData_Delete treeData, somePath
   put the result into deletedData
   set the arrayData of treeWidget to treeData
   --
   return deletedData
end tree_DeletePath


--> TreeData
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


--> Layout
-
on refreshDisplay
   put the rect of this card into cardRect
   LayoutControl cardRect
end refreshDisplay

command LayoutControl cardRect
   put _MyMenuButton() into myMenuButton
   
   lock screen
   put the inner_Rect [cardRect] of me into cardRect
   rect_SubtractMargins cardRect
   
   put _headerRect (cardRect) into headerRect
   set the rect of _headerWidget() to headerRect
   if exists (myMenuButton) then
      set the rect of myMenuButton to headerRect
   end if
   --
   set the rect of _treeWidget() to _fieldRect (cardRect)
   set the rect of _footerWidget() to _footerRect (cardRect)
   unlock screen
end LayoutControl


--> Props | Title
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


--> Props | Display
-
getprop footer_IsVisible
   return the visible of _footerWidget()
end footer_IsVisible

setprop footer_IsVisible someBoolean
   lock screen
   set the visible of _footerWidget() to someBoolean
   dispatch "refreshDisplay" to cd 1 of me
   unlock screen
end footer_IsVisible


--> Props | Title
-
getprop tree_SortType
   put _treeWidget() into treeWidget
   put the sortType of treeWidget into treeSortType
   return treeSortType
end tree_SortType

setprop tree_SortType treeSortType
   put _treeWidget() into treeWidget
   set the sortType of treeWidget to treeSortType
   return treeWidget
end tree_SortType

getprop tree_SortTypes
   return "text,numeric"
end tree_SortTypes

getprop title_Colour
   put the backgroundcolor of _headerWidget() into someColour
   return someColour
end title_Colour

setprop title_Colour someColour
   if someColour is "random" then
      put colour_GetRandom() into someColour
   end if
   set the backgroundcolor of _headerWidget() to someColour
   return someColour
end title_Colour

getprop title_TextColour
   put the foregroundcolor of _headerWidget() into someColour
   return someColour
end title_TextColour

setprop title_TextColour someColour
   if someColour is "random" then
      put colour_GetRandom() into someColour
   end if
   set the foregroundcolor of _headerWidget() to someColour
   return someColour
end title_TextColour


--> Data
-
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


--> Geometry
-
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

private function _headerHeight
   return 55
end _headerHeight

private function _footerHeight
   if the footer_IsVisible of me is true then
      return 40
   else
      return 0
   end if
end _footerHeight


--> Controls
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

getprop tree_Widget
   put _treeWidget() into treeWidget
   return treeWidget
end tree_Widget

getprop title_View
   put _headerWidget() into headerWidget
   return headerWidget
end title_View

getprop header_Widget
   put _headerWidget() into headerWidget
   return headerWidget
end header_Widget


--> Objects | Compatibility
-
getprop tree_Field
   -- for compatibility (experimental)
   return _treeWidget()
end tree_Field

getprop tree_View
   -- for compatibility (experimental)
   return the long id of me
end tree_View


--> Private
-
private function _headerWidget
   put the long id of widget "Array Header" of me into headerWidget
   return headerWidget
end _headerWidget

private function _treeWidget
   put the long id of widget "Array" of me into arrayWidget
   return arrayWidget
end _treeWidget

private function _footerWidget
   put the long id of widget "Array Footer" of me into footerWidget
   return footerWidget
end _footerWidget


--> Deps
-
private function _getValue pathItems
   put the displayed_Array of me into someArray
   split pathItems with comma
   put someArray [pathItems] into someValue
   return someValue
end _getValue

function _SortedTopKeys
   put the displayed_Data of me into myData
   put keys (myData) into topKeys
   
   put _treeWidget() into treeWidget
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
