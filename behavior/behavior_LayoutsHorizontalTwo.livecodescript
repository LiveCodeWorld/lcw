script "behavior_View|Layouts|Horizontal|Two"
--> MetaData
-
license: GPLv3
name: behavior_View|Layouts|Horizontal|Two
type: view behavior
version: 0.1
copyright: David Bovill

/*
This layout allows you to resize two horzontally divided panes.

There seems to be a bug regarding resizing - the veritcal bar and the margin.
*/


--> Variables
-
local LocalArray
local LeftView, RightView


--> Initialisation
-
command view_IndexChildren
   put word 3 of the vertical_Divider of me into verticalDividerID
   
   put the childcontrolids of me into childIDs
   set the wholematches to true
   put lineOffset (verticalDividerID, childIDs) into lineNum
   delete line lineNum of childIDs
   
   put the long id of control id (line 1 of childIDs) into LeftView
   put the long id of control id (line 2 of childIDs) into RightView
   return LeftView & CR & RightView
end view_IndexChildren


--> Views
-
getprop horizontal_Layout
   return the long id of me
end horizontal_Layout

getprop layout_View
   return the long id of me
end layout_View

getprop view_Object
   return the long id of me
end view_Object

getprop left_View
   if exists (LeftView) is false then view_IndexChildren
   return LeftView
end left_View

getprop right_View
   if exists (RightView) is false then view_IndexChildren
   return RightView
end right_View

getprop vertical_Divider
    return the long id of control "_VerticalDivider View" of me
end vertical_Divider


--> Events
-
on preOpenControl
   view_IndexChildren
end preOpenControl

on resizeControl
   if the long id of the target = the long id of me then
      LayoutControl the rect of me
   end if
end resizeControl

on refresh pHow
   lock screen
   view_IndexChildren
   switch pHow
      case "placeholders"
         set the control_Type ["left_View"] of the left_View of me to "placeholder"
         set the control_Type ["right_View"] of the right_View of me to "placeholder"
         break
      default
   end switch
   LayoutControl
   unlock screen
   return the result
end refresh

--> Currently Working On
-
getprop layout_Elements
   if the long id of the target is not the long id of me then pass layout_Elements
   
   repeat for each item objectRef in "left_View,right_View"
      put the objectRef of me into someView
      put the layout_Elements of someView into viewElements
      if viewElements is empty then
         put someView & CR after layoutElements
      else
         put viewElements & CR after layoutElements
      end if
   end repeat
   delete char -1 of layoutElements
   return layoutElements
end layout_Elements

getprop view_Children
   -- view_IndexChildren
   return HeaderView & CR & BodyView & CR & FooterView
end view_Children

getprop top_ControlNames
   put the childcontrolids of me into topIDs
   repeat for each line someID in topIDs
      put the short name of control id someID & CR after topNames
   end repeat
   delete char -1 of topNames
   return topNames
end top_ControlNames

getprop top_Controls
   put the childcontrolids of me into topIDs
   repeat for each line someID in topIDs
      put the long id of control id someID & CR after topControls
   end repeat
   delete char -1 of topControls
   return topControls
end top_Controls


--> Geometry | Layout
-
getprop horizontal_Spacing
   put LocalArray ["horizontal_Spacing"] into someSpacing
   if someSpacing is empty then put 4 into someSpacing
   return someSpacing
end horizontal_Spacing

setprop horizontal_Spacing [dontLayout] someSpacing
   put someSpacing into LocalArray ["horizontal_Spacing"]
   if dontLayout is not true then dispatch "LayoutControl" to me
end horizontal_Spacing

setprop layout_Margins someMargin
   lock screen
   put the rect of me into oRect
   set the margins of me to someMargin
   LayoutControl oRect
   unlock screen
end layout_Margins

getprop layout_Margins
    return the margins of me
end layout_Margins

getprop fixed_View
   put LocalArray ["fixed_View"] into leftOrRight
   if leftOrRight is empty then return "left"
   return leftOrRight
end fixed_View

setprop fixed_View leftOrRight
   put leftOrRight into LocalArray ["fixed_View"]
end fixed_View

getprop fixed_Views
   return "left,right,formatted,proportional"
end fixed_Views

getprop layout_DividerStyle
    return the divider_Style of the vertical_Divider of me
end layout_DividerStyle

setprop layout_DividerStyle someStyle
    set the divider_Style of the vertical_Divider of me to someStyle
end layout_DividerStyle

getprop layout_DividerStyles
    return "invisible,transparent,opaque,icon"
end layout_DividerStyles


--> Show and Hide
-
getprop hidden_View
   switch
      case the visible of the left_View of me = false
         return "left"
      case the visible of the right_View of me = false
         return "right"
      default
         return empty
   end switch      
end hidden_View

setprop hidden_View whichView
   -- opn_Notify whichView
   lock screen
   put the rect of me into oRect
   put the left_View of me into leftView
   put the right_View of me into rightView
   put the vertical_Divider of me into verticalDivider
   
   switch word 1 of whichView
      case "left"
         set the visible of leftView to false
         set the visible of rightView to true
         set the visible of verticalDivider to false
         break
      case "right"
         set the visible of leftView to true
         set the visible of rightView to false
         set the visible of verticalDivider to false
         break
      default -- case "none" or empty or...
         set the visible of leftView to true
         set the visible of rightView to true
         set the visible of verticalDivider to true
         
         get item 1 of whichView
         if it is a number then
            set the width of leftView to it
         else if LocalArray ["lastLeft"] is a number then
            set the width of leftView to LocalArray ["lastLeft"]
         end if
   end switch
   LayoutControl oRect
   unlock screen
end hidden_View


--> Geometry
-
setprop view_Rect someRect
   -- this allows for nested views with or without "setprop view_Rect" handlers
   if the long id of the target = the long id of me then
      LayoutControl someRect
   else
      set the rect of the target to someRect
   end if
end view_Rect

on LayoutControl pRect
   if the long id of the target is not the long id of me then return empty -- this is important for nested datagrids at the moment.
   if pRect is empty then put the the rect of me into pRect
   
   put the left_View of me into leftView
   if exists (leftView) is false then return false
   put the right_View of me into rightView
   if exists (rightView) is false then return false
   
   put the vertical_Divider of me into verticalDividerView
   
   put the inner_rect [pRect] of me into innerRect
   
   switch
      case the visible of leftView is false
         put innerRect into leftViewRect
         put innerRect into rightViewRect
         put innerRect into verticalDividerRect
         set the visible of verticalDividerView to false
         break
      case the visible of rightView is false
         put innerRect into leftViewRect
         put innerRect into rightViewRect
         put innerRect into verticalDividerRect
         set the visible of verticalDividerView to false
         break
      default -- they are both visible
         set the visible of verticalDividerView to true
         
         put the horizontal_Spacing of me into viewSpacing
         put item 3 of pRect - item 1 of pRect into newLayoutWidth
         
         put layout_GetLeftViewWidth (newLayoutWidth, leftView, rightView, verticalDividerView) into leftViewWidth
         
         -- left_View rect
         put innerRect into leftViewRect
         put item 1 of leftViewRect + leftViewWidth into leftViewRight
         put leftViewRight into item 3 of leftViewRect
         
         -- vertical_Divider Rect
         put innerRect into verticalDividerRect
         put leftViewRight into item 1 of verticalDividerRect
         put leftViewRight + viewSpacing into rightViewLeft
         put rightViewLeft into item 3 of verticalDividerRect
         
         -- right_View rect
         put innerRect into rightViewRect
         put rightViewLeft into item 1 of rightViewRect
         
         put leftViewWidth into LocalArray ["lastLeft"]
         put newLayoutWidth into LocalArray ["lastTotalWidth"]
   end switch
   
   -- Set Rects
   lock screen
   set the rect of leftView to leftViewRect
   set the view_Rect of verticalDividerView to verticalDividerRect -- to rest locals for stability hack
   set the rect of rightView to rightViewRect
   unlock screen   
end LayoutControl


--> Geometry | Right View | Width
-
/*
I think this needs tidying to work like title_Height
*/

getprop right_Width
    return the width of the right_Width of me
end right_Width

setprop right_Width someWidth
   lock screen
   put the the rect of me into oRect
   set the fixed_View of me to "right"
   set the width of the right_View of me to someWidth
   LayoutControl oRect
   unlock screen
end right_Width


--> Geometry | Left View | Width
-
/*
I think this needs tidying to work like title_Height
*/

getprop left_Width
    return the width of the left_View of me
end left_Width

setprop left_Width someWidth
   lock screen
   put the the rect of me into oRect
   set the fixed_View of me to "left"
   set the width of the left_View of me to someWidth
   LayoutControl oRect
   unlock screen
end left_Width

private function layout_GetLeftViewWidth newLayoutWidth, leftView, rightView, verticalDividerView
   put the fixed_View of me into fixedView
   switch fixedView
      case "right"
         put the width of rightView into rightViewWidth
         put the width of verticalDividerView into leftViewWidth
         
         put the margins of me into someMargin
         margin_Normalize someMargin, left_Margin, top_Margin, right_Margin, bottom_Margin
         put right_Margin + left_Margin into extraBit
         if the showborder of me is true then
            add 2 * the borderwidth of me to extraBit
         end if
         
         return newLayoutWidth - rightViewWidth - leftViewWidth - extraBit
      case "formatted"
         put the formatted_Width of leftView into leftViewWidth
         put the width of me into totalWidth
         put leftViewWidth / totalWidth into widthProportion
         return round(newLayoutWidth * widthProportion)
      case "half"
         return round(newLayoutWidth / 2)
      case "proportional"	# free
         put LocalArray ["lastLeft"] into lastLeft
         if lastLeft is empty then put the width of leftView into lastLeft
         put LocalArray ["lastTotalWidth"] into lastTotalWidth
         if lastTotalWidth is empty then put the width of me into lastTotalWidth
         
         put lastLeft / lastTotalWidth into widthProportion
         put round(newLayoutWidth * widthProportion) into newLeftWidth
         return newLeftWidth
      default -- case "left"
         return the width of leftView
   end switch
end layout_GetLeftViewWidth


--> Geometry | Subview Defaults
-
getprop formatted_Width
    return the width of the target
end formatted_Width


--> Deps
-
