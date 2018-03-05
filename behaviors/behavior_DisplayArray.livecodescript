script "behavior_DisplayArray"
--> MetaData
-
license: GPLv3
name: behavior_DisplayArray
type: behavior
version: 0.5

/*
This behavior_DisplayArray script only stack behavior controls the properties of the stack "Display Array".

To do: Should consider moving it to the behavior of the view rather than the stack -,
so that if the view is cloned and not the whole stack the view keeps working.
*/

--> Variables
-
local LocalArray


--> Working On
-
private function _getValue pathItems
   put the displayed_Array of me into someArray
   split pathItems with comma
   put someArray [pathItems] into someValue
   return someValue
end _getValue

private command _displaySelectedValue pTreeWidget
   -- if the optionkey is "Down" then breakpoint -- interferes with a menu option edit
   
   if pTreeWidget is empty then put _treeWidget() into pTreeWidget
   put the selected_Value of pTreeWidget into selectedValue
   
   if the shiftKey is "Up" then return selectedValue
   
   if selectedValue is an array then
      display_Array selectedValue
      -- put the hilitedElement of me into commaKeys
   else
      put selectedValue
   end if
end _displaySelectedValue


--> Props | Selected
-
getprop top_Array
   put the hilited_Element of me into hItems
   if the number of items of hItems = 1 then
      put the selected_Array of me into topArray
   else
      put the parent_Array of me into topArray
   end if
   return topArray
end top_Array

getprop parent_Array
   put _treeWidget() into treeWidget
   
   put the hilitedElement of treeWidget into commaKeys
   delete item -1 of commaKeys
   put the arrayData of treeWidget into someArray
   split commaKeys with comma
   put someArray [commaKeys] into selectedValue
   return selectedValue
end parent_Array

getprop selected_Array
   put _treeWidget() into treeWidget
   
   put the hilitedElement of treeWidget into commaKeys
   put the arrayData of treeWidget into someArray
   split commaKeys with comma
   put someArray [commaKeys] into selectedValue
   return selectedValue
end selected_Array

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

getprop selected_Path
   return the hilited_Element of me
end selected_Path

setprop selected_Path commaPath
   set the hilited_Element of me to commaPath
end selected_Path

getprop hilited_Element
   put _treeWidget() into treeWidget
   put the hilitedElement of treeWidget into commaPath
   return commaPath
end hilited_Element

setprop hilited_Element commaPath
   put _treeWidget() into treeWidget
   set the hilitedElement of treeWidget to commaPath
   return treeWidget
end hilited_Element


--> Events
-
on mouseUp
   -- called only when the user click on the header as a tree widget does not send to mouseUp
   local tActionName
   put the long id of the target into headerWidget
   put the mouseAction of headerWidget into tActionName
   	
   switch tActionName
      case "cog"
         put the clickloc into pLocation
         add 2 to item 1of pLocation
         add 4 to item 2 of pLocation
         put the menu_Title of headerWidget into mTitle
         menu_PopUp mTitle, pLocation
      default
         -- clicked on the title
   end switch
end mouseUp

on hiliteChanged
   -- hack
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
      -- put the line_Menu of me into lineMenu
      menu_PopUp -- lineMenu
   else
      _displaySelectedValue treeWidget
   end if
end hiliteChanged

on actionInspect pPath
   put _getValue (pathItems) into someValue
   put the action_InspectCommand of me into mouseUpCommand
   if mouseUpCommand is empty then
      put someValue
   else
      put the display_MouseTarget of me into displayMouseTarget
      put the long id of the target into treeWidget
      dispatch mouseUpCommand to displayMouseTarget with treeWidget,someValue
   end if
end actionInspect

command actionDoubleClick pathItems
   put the selected_Value of me into someValue
   put the action_DoubleClickCommand of me into mouseDoubleUpCommand
   if mouseDoubleUpCommand is empty then
      put someValue
   else
      put the display_MouseTarget of me into displayMouseTarget
      put the long id of me into treeWidget
      replace comma with slash in pathItems
      dispatch mouseDoubleUpCommand to displayMouseTarget with treeWidget,someValue,pathItems
   end if
end actionDoubleClick

on resizeControl
   put the rect of me into viewRect
   LayoutControl viewRect
end resizeControl

on refreshDisplay
   put the rect of this card into cardRect
   LayoutControl cardRect
end refreshDisplay

command LayoutControl cardRect
   lock screen
   put the inner_Rect [cardRect] of me into cardRect
   rect_SubtractMargins cardRect
   
   set the rect of _headerWidget() to _headerRect (cardRect)
   set the rect of _treeWidget() to _fieldRect (cardRect)
   set the rect of _footerWidget() to _footerRect (cardRect)
   unlock screen
end LayoutControl


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

getprop menu_Title
   if word 1 of the target is not "widget" then
      pass menu_Title
   end if
   
   put the kind of the target into targetKind
   switch targetKind
      case "com.livecode.widget.treeView"
         put the line_Menu of me into mTitle
         return mTitle
      case "com.livecode.widget.headerBar"
         if the controlKey is "Down" then
            put "Global | Array | Menu" into mTitle
         else if the optionKey is "Down" then
            put "Local | Array | Menu" into mTitle
         else
            put the title_Menu of me into mTitle
         end if
         return mTitle
      default
         pass menu_Title
   end switch
end menu_Title

getprop title_Menu
   put LocalArray ["title_Menu"] into titleMenuName
   if titleMenuName is empty then put "Global | Array | Menu" into titleMenuName
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

getprop view_MenuArray
   put the title_Menu of me into menuArray ["title"]
   put the line_Menu of me into menuArray ["line"]
   return menuArray
end view_MenuArray

setprop view_MenuArray menuArray
   set the title_Menu of me to menuArray ["title"]
   set the line_Menu of me to menuArray ["line"]
end view_MenuArray


--> Props | Events
-
getprop display_MouseTarget
   -- should call this mouse_Target ???
   put LocalArray ["display_MouseTarget"] into displayMouseTarget
   return displayMouseTarget
end display_MouseTarget
    
setprop display_MouseTarget displayMouseTarget
   put displayMouseTarget into LocalArray ["display_MouseTarget"]
end display_MouseTarget

getprop view_EventArray eventArray   
   put the display_MouseTarget of me into eventArray ["eventTarget"]
   put the action_InspectCommand of me into eventArray ["mouseUp"]
   put the action_DoubleClickCommand of me into eventArray ["mouseDoubleUp"]
   return eventArray
end view_EventArray

setprop view_EventArray eventArray   
   set the display_MouseTarget of me to eventArray ["eventTarget"]
   set the action_InspectCommand of me to eventArray ["mouseUp"]
   set the action_DoubleClickCommand of me to eventArray ["mouseDoubleUp"]
end view_EventArray

getprop action_InspectCommand
   put LocalArray ["action_InspectCommand"] into mouseUpCommand
   return mouseUpCommand
end action_InspectCommand

setprop action_InspectCommand mouseUpCommand
   put mouseUpCommand into LocalArray ["action_InspectCommand"]
end action_InspectCommand

getprop action_DoubleClickCommand
   put LocalArray ["action_DoubleClickCommand"] into mouseDoubleUpCommand
   return mouseDoubleUpCommand
end action_DoubleClickCommand

setprop action_DoubleClickCommand mouseDoubleUpCommand
   put mouseDoubleUpCommand into LocalArray ["action_DoubleClickCommand"]
end action_DoubleClickCommand


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

getprop title_Text
   put the label of _headerWidget() into displayTitle
   return displayTitle
end title_Text

setprop title_Text displayTitle
   if displayTitle is empty then put "Array" into displayTitle
   set the label of _headerWidget() to displayTitle
end title_Text

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

setprop displayed_Array someArray
   -- compatibility with old treeView
   set the displayed_Data of me to someArray
end displayed_Array

getprop displayed_Data
   put the arrayData of _treeWidget() into someArray
   return someArray
end displayed_Data

setprop displayed_Data someArray
   set the arrayData of _treeWidget() to someArray
end displayed_Data

getprop view_Data [someKey]
   put LocalArray ["view_Data"] into viewData
   if someKey is empty then return viewData
   return viewData [someKey]
end view_Data

setprop view_Data [someKey] someData
   if someKey is empty then
      put someData into LocalArray ["view_Data"]
   else   
      put someData into LocalArray ["view_Data"][someKey]
   end if
end view_Data


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
   return _treeWidget
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
function colour_GetRandom
   put random(255) into item 1 of someColour
   put random(255) into item 2 of someColour
   put random(255) into item 3 of someColour
   return someColour
end colour_GetRandom
