script "behavior_View|Index|Simple"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewIndexSimple
type: view behavior
version: 0.5

/*
Was "View|Index|Simple" - now moverd to this script-ony behavior.
This view presents an index in a scrolling field, with full support for dynamic events.
*/


--> Variables
-
local LocalArray


--> Field | Props
-
getprop lock_Text
   put the locktext of _fieldView() into someBoolean
   return someBoolean
end lock_Text

setprop lock_Text someBoolean
   set the locktext of _fieldView() to someBoolean
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
   put _fieldView() into fieldView
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
   put _fieldView() into fieldView
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

getprop multiple_Hilites
   put the multiplehilites of _fieldView() into someBoolean
   return someBoolean
end multiple_Hilites

setprop multiple_Hilites someBoolean
   set the multiplehilites of _fieldView() to someBoolean
   set the nonContiguousHilites of _fieldView() to someBoolean
   set the toggleHilites of _fieldView() to someBoolean
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
      if mTitle is empty then put "List | Menu" into mTitle
      menu_PopUp mTitle
   else
      drag_SetGlobalStatus true
      
      put the selectedtext of the target into someText
      -- set the dragImage to 3137
      set the dragAction to "copy"
      set the dragData ["text"] to someText
      set the dragData ["private"] to someText
   end if
end _doFieldDown


--> Events
-
-- on dragEnd
   drag_SetGlobalStatus false
   
   -- put the dragdata ["private"] into viewName
   put the dragdata ["text"] into viewName
   
   put the dragDestination into targetObject
   if exists (targetObject) is false then return false
   
   put viewName & CR & targetObject
end dragEnd

on nameChanged oldName, newName
   -- here we change field and button names
   -- this will break any references to them by name
   -- but you shouldn't do that lightly anyway as this view hides it's inner workings.
   set the name of _titleView() to newName
   set the label of _titleView() to empty
   set the name of _fieldView() to newName
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
   set the rect of _fieldView() to _fieldRect (pRect)
   unlock screen
end LayoutControl


--> Display | Props
-
-- getprop displayed_Url
   put LocalArray ["displayed_Url"] into displayedUrl
   return displayedUrl
end displayed_Url
 
-- setprop displayed_Url someURL
   put someURL into LocalArray ["displayed_Url"]
end displayed_Url

getprop displayed_Data
   put the view_Index of me into someIndex
   return someIndex
end displayed_Data

setprop displayed_Data someIndex
   set the view_Index of me to someIndex
end displayed_Data


--> Index | Stack | Selected
-
getprop selected_ShortStackFiles
   put the selected_Index of me into shortStackFiles 
   return shortStackFiles
end selected_ShortStackFiles

getprop selected_StackObjects
   put the selected_ShortStackFiles of me into shortStackFiles  
   put _getStackObjects (shortStackFiles) into stackObjects
   return stackObjects
end selected_StackObjects

getprop selected_StackNames
   put the selected_ShortStackFiles of me into shortStackFiles  
   put _getStackNames (shortStackFiles) into stackNames
   return stackNames
end selected_StackNames

getprop selected_LongStackFiles
   put the selected_ShortStackFiles of me into shortStackFiles  
   put _getLongStackFiles (shortStackFiles) into longStackFiles
   return longStackFiles
end selected_LongStackFiles


--> Index | Stack
-
getprop index_StackObjects
   put the index_ShortFiles of me into shortStackFiles  
   put _getStackObjects (shortStackFiles) into stackObjects
   return stackObjects
end index_StackObjects

getprop index_StackNames
   put the index_ShortFiles of me into shortStackFiles  
   put _getStackNames (shortStackFiles) into stackNames
   return stackNames
end index_StackNames

getprop index_LongStackFiles
   put the index_ShortFiles of me into shortStackFiles  
   put _getLongStackFiles (shortStackFiles) into longStackFiles
   return longStackFiles
end index_LongStackFiles

getprop index_ShortStackFiles
   breakpoint
   return the index_ShortFiles of me
end index_ShortStackFiles

getprop index_ShortFiles
   put the view_Index of me into shortStackFiles  
   return shortStackFiles
end index_ShortFiles

getprop index_Files
   put the view_Index of me into shortStackFiles
   put _getLongFiles (shortFiles) into longFiles
   return longFiles
end index_Files


--> Folder
-
getprop index_Folder
   put LocalArray ["index_Folder"] into indexFolder
   return indexFolder 
end index_Folder

setprop index_Folder indexFolder
   text_AddTrailing indexFolder, slash
   put indexFolder into LocalArray ["index_Folder"]
end index_Folder

-
-> Index
-
getprop selected_Index
   put the selectedtext of _fieldView() into someIndex
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
   
   set the hilitedlines of _fieldView() to lineNumList
   return lineNumList
end selected_Index

getprop view_Index
   put the text of _fieldView() into someIndex
   return someIndex
end view_Index

setprop view_Index [someTitle] someIndex
   lock screen
   put _fieldView() into fieldObject
   if someTitle is not empty then
      set the view_Label of me to someTitle
   end if
   set the text of fieldObject to someIndex
   unlock screen
   return fieldObject
end view_Index


--> Menus
-
-- getprop menu_Controller [mTitle]
   put menu_GetTargetObject() into mController
   return mController
end menu_Controller

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
   put LocalArray ["line_Menu"] into lineMenuName
   return lineMenuName
end line_Menu

setprop line_Menu lineMenuName
   put lineMenuName into LocalArray ["line_Menu"]
end line_Menu


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


--> Title | Props
-
getprop view_Title
   breakpoint
   -- rename to this as we sound like the view object not the text
   -- also this is what we used more generally
   return the title_Text of me
 end view_Title

setprop view_Title [someColour] someTitle
   breakpoint
   -- rename to this as we sound like the view object not the text
   -- also this is what we used more generally
   set the title_Text [someColour] of me to someTitle
end view_Title

getprop view_Label
   put the label of _titleView() into someLabel
   return someLabel
end view_Label

setprop view_Label someLabel
   set the label of _titleView() to someLabel
end view_Label

getprop title_Text
   -- put the label of _titleView() into someTitle
   put the short name of _titleView() into someTitle
   return someTitle
end title_Text

setprop title_Text [someColour] someTitle
   lock screen
   set the name of me to someTitle
   if someColour is not empty then
      set the title_Colour of me to someColour
   end if
   unlock screen
end title_Text

getprop title_Colour
   return the backgroundcolor of _titleView()
end title_Colour

setprop title_Colour someColour
   if someColour is "random" then put colour_GetRandom() into someColour
   set the backgroundcolor of _titleView() to someColour
end title_Colour

getprop title_TextColour
   return the foregroundcolor of _titleView()
end title_TextColour

setprop title_TextColour someColour
   if someColour is "random" then put colour_GetRandom() into someColour
   set the foregroundcolor of _titleView() to someColour
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
   return _fieldView()
end index_Field


--> Private
-
private function _titleView
   put the long id of btn 1 of me into headerWidget
   return headerWidget
end _titleView

private function _fieldView
   put the long id of field 1 of me into arrayWidget
   return arrayWidget
end _fieldView

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

private function _getLongFiles shortFiles
   put the index_Folder of me into indexFolder  
   repeat for each line shortFile in shortFiles
      put indexFolder & shortFile into longFile
      put longFile & CR after longFiles
   end repeat
   delete char -1 of longFiles
   return longFiles
end _getLongFiles

private function known_StackNames shortStackFiles
   put stackFile_NamesFromShortFiles (shortStackFiles) into stackNames
   return stackNames
end known_StackNames

private function known_StackObjects shortStackFiles
   put stackFile_NamesFromShortFiles (shortStackFiles) into stackNames
   repeat for each line stackName in stackNames
      if exists (stack stackName) then
         put the name of stack stackName into stackObject
         put stackObject & CR after stackObjects
      end if
   end repeat
   delete char -1 of stackObjects
   return stackObjects
end known_StackObjects

private function _getStackObjects shortStackFiles
   put the index_Folder of me into indexFolder 
   if indexFolder is empty then
      -- let's assume the stacks are known
      put known_StackObjects (shortStackFiles) into stackObjects
   else 
      repeat for each line shortStackFile in shortStackFiles
         put indexFolder & shortStackFile into longStackFile
         if exists (stack longStackFile) then
            put the name of stack longStackFile into stackObject
            put stackObject & CR after stackObjects
         end if
      end repeat
      delete char -1 of stackObjects
   end if
   return stackObjects
end _getStackObjects

private function _getStackNames shortStackFiles
   put the index_Folder of me into indexFolder  
   if indexFolder is empty then
      -- let's assume the stacks are known
      put stackFile_NamesFromShortFiles (shortStackFiles) into stackNames
   else 
      repeat for each line shortStackFile in shortStackFiles
         put indexFolder & shortStackFile into longStackFile
         if exists (stack longStackFile) then
            put the short name of stack longStackFile into stackName
            put stackName & CR after stackNames
         end if
      end repeat
      delete char -1 of stackNames
   end if
   return stackNames
end _getStackNames

private function _getLongStackFiles shortStackFiles
   put the index_Folder of me into indexFolder  
   if indexFolder is empty then
      -- let's assume the stacks are known
      put stackFile_PathsFromShortFiles (shortStackFiles) into stackPaths
      return stackPaths
   else 
      repeat for each line shortStackFile in shortStackFiles
         put indexFolder & shortStackFile into longStackFile
         if exists (stack longStackFile) then 
            put longStackFile & CR after longStackFiles
         end if
      end repeat
      delete char -1 of longStackFiles
      return longStackFiles
   end if
end _getLongStackFiles


--> Deps
-
command text_AddTrailing @someText, someChar
   if char -1 of someText is not someChar then
      put someChar after someText
   end if
end text_AddTrailing

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
