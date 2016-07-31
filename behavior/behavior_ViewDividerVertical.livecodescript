script "behavior_View|Divider|Vertical"
--> MetaData
-
license: GPLv3
name: behavior_View|Divider|Vertical
type: behavior
version: 0.1


--> MetaData
-
author: David Bovill
copyright: David Bovill
name: View|Divider|Vertical
type: view behavior

/*
This is a bit of a mess. Fix it up.

The geometry of this view is not stable 
It can get trapped in a situation where the geometry needs resetting as the local variables are no cleared,
as a mouseUp or mouseLeave event is not sent and so clear_move is never called.

Resizing the view should fix this as a short term hack, but the code needs fixing to make it more robust.
This layout allows you to resize two horzontally divided panes.
It should be updated to use one LocalArray, and maybe dispatch?
*/

getprop view_Object
    return the long id of me
end view_Object

getprop vertical_Divider
    return the long id of me
end vertical_Divider


--> Local Variables
-
local localStartH, localStartV, localOriginalRect, localMouseIsDown, localLeftView, localRightView, localOwnerRect

private command clearLocals
    -- occassional bug where local seems to get wrong initial settin
    -- this hack is supposed to clear them all before moving.
    
    put empty into localStartH
    put empty into localStartV
    put empty into localOriginalRect
    put empty into localMouseIsDown
    put empty into localLeftView
    put empty into localRightView
    put empty into localOwnerRect
end clearLocals


--> Events
-
on mouseDown pMouseBtnNum
   clearLocals
   if pMouseBtnNum = 3 then
      put the menu_ToolTitle of me into mTitle
      menu_PopUp mTitle
   else if the shiftkey is "Down" then
      put the menu_Title of me into mTitle
      menu_PopUp mTitle
   else
      put true into localMouseIsDown
      initialise_Move
      pass mouseDown
   end if
end mouseDown

on mouseEnter
    set the lockcursor to true
    set the cursor to 65
    pass mouseEnter
end mouseEnter

on mouseLeave
    set the lockcursor to false
    pass mouseLeave
end mouseLeave

on mouseMove newMouseH, newMouseV
   if the mouse is "Down" and localMouseIsDown then
      if localStartH is empty then initialise_Move
      
      put newMouseH - localStartH into movedH
      
      put localOriginalRect into dividerRect
      put movedH + item 1 of dividerRect into leftViewRight
      put leftViewRight into item 1 of dividerRect
      put movedH + item 3 of dividerRect into rightViewLeft
      put rightViewLeft into item 3 of dividerRect
      
      put the long id of me into myOwner
      delete word 1 to 4 of myOwner
      put the inner_Rect of myOwner into innerRect
      
      put innerRect into leftViewRect
      put leftViewRight into item 3 of leftViewRect
      
      put innerRect into rightViewRect
      put rightViewLeft into item 1 of rightViewRect
      
      lock screen
      set the rect of me to dividerRect
      if exists (localLeftView) then set the rect of localLeftView to leftViewRect
      if exists (localRightView) then set the rect of localRightView to rightViewRect
      unlock screen
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

command LayoutControl pRect
   if pRect is empty then put the rect of me into pRect
   set the rect of me to pRect
   clear_Move
end LayoutControl


--> Drag Helpers
-
on initialise_Move
   put the mouseh into localStartH
   put the mousev into localStartV
   put the rect of me into localOriginalRect
   
   put the long id of me into myOwner
   delete word 1 to 4 of myOwner
   put the rect of myOwner into localOwnerRect
   
   put the left_View of me into localLeftView
   put the right_View of me into localRightView
end initialise_Move

on clear_Move
    put empty into localStartH
    put empty into localStartV
    put empty into localOriginalRect
    put empty into localOwnerRect
    put empty into localLeftView
    put empty into localRightView
end clear_Move


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


--> Geometry
-
setprop view_Rect someRect
   LayoutControl someRect
end view_Rect
