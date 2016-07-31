script "behavior_View|Layouts|Vertical|Two|Divider"
--> MetaData
-
license: GPLv3
name: behavior_View|Layouts|Vertical|Two|Divider
version: 0.4
copyright: David Bovill
type: view behavior

/*
This layout allows you to resize a top_View and a bottom_View in a 2-way vertical layout.

The top_View refers to a view in the same layout_View (a sister view) which is meant to be the top or header view.
The bottom_View refers to a view in the same layout_View (a sister view) which is meant to be the bottom or footer view.

Requirements: for this view to have any effect there needs to be be teh following handlers somewhere in the script heirarchy above:

-  getprop top_View
-  getprop bottom_View

These handlers should return the long id of the appropriate view.
*/

--> Variables
-
local LocalArray


--> Objects
-
getprop header_Divider
    return the long id of me
end header_Divider

getprop view_Object
    return the long id of me
end view_Object


--> Geometry
-
setprop view_Rect someRect
    set the rect of me to someRect
end view_Rect

getprop owner_Rect
    put the long id of me into myOwner
    delete word 1 to 4 of myOwner
    return the inner_Rect of myOwner
end owner_Rect


--> Divider
-
getprop divider_Style
   switch
      case the visible of me is false
         return "invisible"
      case the icon of me is 205232
         return "icon"
      case the style of me is "transparent"
         return "transparent"
      case the style of me is "opaque"
         return "opaque"
   end switch
end divider_Style

setprop divider_Style someStyle
   lock screen
   switch someStyle
      case "invisible"
         set the visible of me to false
         set the icon of me to empty
         break
      case "transparent"
         set the style of me to "transparent"
         set the icon of me to empty
         break
      case "opaque"
         set the style of me to "opaque"
         set the icon of me to empty
         break
      case "icon"
         set the style of me to "transparent"
         set the icon of me to 205232
         break
   end switch
   unlock screen
end divider_Style

getprop divider_Styles
    return "invisible,transparent,opaque,icon"
end divider_Styles


--> Initialise
-
private command clearLocals
    -- occassional bug where local seems to get wrong initial setting    
    put empty into LocalArray ["StartV"]
    put empty into LocalArray ["ViewAbove"]
    put empty into LocalArray ["ViewAboveRect"]
    put empty into LocalArray ["ViewBelow"]
    put empty into LocalArray ["ViewBelowRect"]
end clearLocals

on initialise_Move
   put the top_View of me into topView
   put the bottom_View of me into bottomView
   
   put topView into LocalArray ["ViewAbove"]
   put bottomView into LocalArray ["ViewBelow"]
   put the rect of LocalArray ["ViewAbove"] into LocalArray ["ViewAboveRect"]
   put the rect of LocalArray ["ViewBelow"] into LocalArray ["ViewBelowRect"]
   put the mousev into LocalArray ["StartV"]
   
   dispatch "layout_StartHorizontalDividerMove" to the owner of me
end initialise_Move

on clear_Move
   if LocalArray ["StartV"] is not empty then
      dispatch "layout_StopHorizontalDividerMove" to the owner of me
   end if
   
   get line 3 of the localnames
   repeat for each item varName in it
      do ("put empty into" && varName)
   end repeat
end clear_Move


--> Events
-
on mouseDown pMouseBtnNum
    clearLocals
    initialise_Move
    pass mouseDown
end mouseDown

on mouseEnter
   set the lockcursor to true
   set the cursor to 64
   clearLocals
   pass mouseEnter
end mouseEnter

on mouseLeave
    set the lockcursor to false
    pass mouseLeave
end mouseLeave

on mouseMove newMouseH, newMouseV
   if the mouse is "Down" then
      if LocalArray ["StartV"] is empty then initialise_Move
      
      if LocalArray ["ViewAboveRect"] is not empty then
         -- work out the geometry
         put newMouseV - LocalArray ["StartV"] into movedV
         
         put LocalArray ["ViewAboveRect"] into newAboveRect
         put item 4 of LocalArray ["ViewAboveRect"] + movedV into newAboveBottom
         put newAboveBottom into item 4 of newAboveRect
         
         put LocalArray ["ViewBelowRect"] into newBelowRect
         put item 2 of LocalArray ["ViewBelowRect"] + movedV into newBelowTop
         put newBelowTop into item 2 of newBelowRect
         
         put LocalArray ["ViewAboveRect"] into newSpacerRect
         put newAboveBottom into item 2 of newSpacerRect
         put newBelowTop into item 4 of newSpacerRect
         
         if newAboveBottom < item 2 of LocalArray ["ViewAboveRect"] then return false
         if newBelowTop > item 4 of LocalArray ["ViewBelowRect"] then return false
         
         put LocalArray ["ViewAbove"] into viewAbove
         put LocalArray ["ViewBelow"] into viewBelow
         
         -- set the rects
         set the rect of me to newSpacerRect
         if exists (viewAbove) then set the rect of viewAbove to newAboveRect 
         if exists (viewAbove) then set the rect of viewBelow to newBelowRect
         return true
      end if
   end if
   pass mouseMove
end mouseMove

on mouseUp
   clear_Move
   pass mouseUp
end mouseUp

on mouseRelease
   clear_Move
   pass mouseRelease
end mouseRelease
