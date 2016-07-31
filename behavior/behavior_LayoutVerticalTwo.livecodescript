script "behavior_View|Layouts|Vertical|Two"
--> MetaData
-
license: GPLv3
name: behavior_View|Layouts|Vertical|Two
type: view behavior
version: 0.5
author: David Bovill
copyright: David Bovill

/*
*/

--> Variables
-
local TopView
local BottomView
local LocalArray


--> Events
-
on preOpenControl
   view_IndexChildren
   
   -- maybe set initial geometry here?
   
   pass preOpenControl
end preOpenControl

on resizeControl
   LayoutControl the rect of me
   pass resizeControl
end resizeControl

on refresh pHow
   lock screen
   view_IndexChildren
   switch pHow
      case "placeholders"
         set the control_Type ["header_View"] of the header_View of me to "placeholder"
         set the control_Type ["body_View"] of the body_View of me to "placeholder"
         set the control_Type ["footer_View"] of the footer_View of me to "placeholder"
         break
      default
   end switch
   LayoutControl
   unlock screen
   return the result
end refresh


--> Initialisation
-
command view_IndexChildren
   put the childcontrolids of me into topIDs
   
   put the vertical_Divider of me into verticalDivider
   put the short id of verticalDivider into verticalDividerID
   set the wholematches to true
   put lineOffset (verticalDividerID, topIDs) into lineNum
   delete line lineNum of topIDs
   
   put the long id of control id (line 1 of topIDs) into TopView
   put the long id of control id (line 2 of topIDs) into BottomView
   return TopView & CR & BottomView
end view_IndexChildren


--> Layout | Children
-
getprop layout_Children
   return TopView & CR & BottomView
end layout_Children

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

-- getprop placeholder_Num
put 0 into placeholderNum
repeat for each line viewChild in the layout_Children of me
   put the view_Name of viewChild into viewChildName
   if viewChildName = "View|Layout|Placeholder" then
      add 1 to placeholderNum
   end if
end repeat
return placeholderNum
end placeholder_Num


--> Layout | Divider | Props
-
getprop layout_DividerStyle
   put the divider_Style of the vertical_Divider of me into someStyle
   return someStyle
end layout_DividerStyle

setprop layout_DividerStyle someStyle
   set the divider_Style of the vertical_Divider of me to someStyle
end layout_DividerStyle

getprop layout_DividerStyles
   put the divider_Style of the vertical_Divider of me into someStyles
   return someStyles 
end layout_DividerStyles


--> Layout | Props
-
getprop vertical_Spacing
   put LocalArray ["vertical_Spacing"] into someSpacing
   if someSpacing is empty then
      put _defaultVerticalSpacing() into defaultVerticalSpacing
      put defaultVerticalSpacing into LocalArray ["vertical_Spacing"]
      return defaultVerticalSpacing
   end if
   
   return someSpacing
end vertical_Spacing

setprop vertical_Spacing someSpacing
   put someSpacing into LocalArray ["vertical_Spacing"]
   LayoutControl
end vertical_Spacing

getprop default_Height
   return _defaultVerticalSpacing()
end default_Height

setprop default_Height defaultHeight
   put defaultHeight into LocalArray ["default_Height"]
   Layoutcontrol
end default_Height

getprop resize_Style
   put LocalArray ["resize_Style"] into resizeStyle
   if resizeStyle is empty then
      put _defaultResizeStyle() into defaultResizeStyle
      put defaultResizeStyle into LocalArray ["resize_Style"]
      return defaultResizeStyle
   end if
   
   return resizeStyle
end resize_Style

setprop resize_Style resizeStyle
   put resizeStyle into LocalArray ["resize_Style"]
   Layoutcontrol
end resize_Style

getprop resize_Styles
   return "top fixed,bottom fixed,equal,-,fluid"
end resize_Styles

getprop top_Factor [pRecalulate]
   lock messages
   put the top_Factor of me into fluidFactor
   unlock messages
   
   if fluidFactor is empty or pRecalulate is true then
      put _calculateTopFactor() into fluidFactor
      set the top_Factor of me to fluidFactor
   end if
   return fluidFactor
end top_Factor

setprop top_Factor fluidFactor
   if fluidFactor is empty then put _calculateTopFactor() into fluidFactor
   lock messages
   set the top_Factor of me to fluidFactor
   unlock messages
   return fluidFactor
end top_Factor

command layout_StopHorizontalDividerMove
   set the top_Factor of me to empty
end layout_StopHorizontalDividerMove

getprop formatted_Width [layoutID]
   -- should work out the largest fWidth of the 3 subviews
   -- unfortunately lockmessages does not allow view property to be fetched
   
   put the short id of me into viewID
   if layoutID is viewID then
      -- cannot work out how to do this nested!
      -- can use the executioncontexts but
      -- try layoutID?
      return empty
   end if
   
   put the top_View of me into headerView
   put the bottom_View of me into bodyView
   put the footer_View of me into footerView
   
   put the formatted_Width [viewID] of headerView into fHeaderWidth
   if fHeaderWidth is empty then put the formattedwidth of headerView into fHeaderWidth
   put fHeaderWidth & comma after widthList
   
   put the formatted_Width [viewID] of bodyView into fBodyWidth
   if fBodyWidth is empty then put the formattedwidth of bodyView into fBodyWidth
   put fBodyWidth & comma after widthList
   
   put the formatted_Width [viewID] of footerView into fFooterWidth
   if fFooterWidth is empty then put the formattedwidth of footerView into fFooterWidth
   put fFooterWidth & comma after widthList
   
   delete last char of widthList
   if widthList is empty then 
      put the width of me into fWidth
   else
      put max(widthList) into fWidth
   end if
   
   put the margins of me into someMargin
   margin_Normalize someMargin, left_Margin, top_Margin, right_Margin, bottom_Margin
   add left_Margin to fWidth
   add right_Margin to fWidth
   return fWidth
end formatted_Width


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
   if pRect is empty then put the rect of me into pRect
   
   put the top_View of me into layoutTopView
   put the bottom_View of me into layoutBottomView
   put the vertical_Divider of me into verticalDivider
   
   -- Get Position Properties
   put the vertical_Spacing of me into viewSpacing
   
   put the inner_Rect [pRect] of me into innerRect
   put item 4 of innerRect - item 2 of innerRect into innerHeight
   
   switch the resize_Style of me
      case "top fixed"
         put the height of layoutTopView into topHeight
         put innerHeight - topHeight - viewSpacing into bottomHeight
         break
      case "bottom fixed"
         put the height of layoutBottomView into bottomHeight
         put innerHeight - bottomHeight - viewSpacing into topHeight
         break
      case "equal"
         put round (innerHeight/2) into topHeight 
         put rectHeight - topHeight - viewSpacing into bottomHeight
         break
      default -- case "fluid"
         put the top_Factor of me into topFactor
         put round (topFactor * innerHeight) into topHeight 
         put innerHeight - topHeight into bottomHeight
         break
   end switch
   
   -- Top Rect
   put innerRect into topRect
   put item 2 of topRect + topHeight into topBottom
   put topBottom into item 4 of topRect
   
   -- Spacer Rect
   put innerRect into spacerRect
   put topBottom into item 2 of spacerRect
   put topBottom + viewSpacing into spacerBottom
   put spacerBottom into item 4 of spacerRect
   
   -- Bottom Rect
   put innerRect into bottomRect
   put spacerBottom into item 2 of bottomRect
   
   -- Set Rects
   set the rect of layoutTopView to topRect
   
   set the rect of verticalDivider to spacerRect
   set the rect of layoutBottomView to bottomRect
   
   set the rect of me to pRect
end LayoutControl


--> Controls
-
getprop layout_View
    return the long id of me
end layout_View

getprop view_Object
    return the long id of me
end view_Object

getprop top_View
   if exists (TopView) is false then view_IndexChildren
   return TopView
end top_View

getprop bottom_View
   if exists (BottomView) is false then view_IndexChildren
   return BottomView
end bottom_View

getprop vertical_Divider
   return the long id of control "Vertical Divider" of me
end vertical_Divider


--> Private
-
private function _defaultResizeStyle
   return "fluid"
end _defaultResizeStyle

private function _defaultVerticalSpacing
   put LocalArray ["default_Height"] into defaultHeight
   if defaultHeight is empty then
      return 12
   else
      return defaultHeight
   end if
end _defaultVerticalSpacing

private function _defaultVerticalSpacing
   return item 1 of the margins of me
end _defaultVerticalSpacing

private function _calculateTopFactor
   put the top_View of me into layoutTopView
   put the bottom_View of me into layoutBottomView
   
   put the inner_Rect of me into innerRect
   put item 4 of innerRect - item 2 of innerRect into innerHeight
   
   put the vertical_Spacing of me into viewSpacing
   
   put innerHeight - viewSpacing into oldHeightTotal
   put the height of layoutTopView into oldTopHeight
   put oldTopHeight/oldHeightTotal into topFactor
   return topFactor
end _calculateTopFactor
