script "behavior_Layouts|Vertical|Three"
--> MetaData
-
license: GPLv3
name: View|Layout|Vertical|Three
type: view behavior
version: 0.8
license: GPLv3


/*
This view is an update of older the "View|Layouts|Vertical|3-way" view.

It is work in progress.
Still (I think) need to simplify and:

*  remove references to back_Property
*  remove references to view_DisplayProperty

as these overly complicate things.
Instead the aim is to move forwards with chained behaviors, so we can separate a minimal read-only mode,
and an authoring mode with a bunch of options we can turn on by adding the authroing behavior.

We work out which control is which by the following method.

1)  We get all the childControlIDs of the layout_View
2)  We remove the named header_Divider and footer_Divder
3)  We allocate HeaderView to the top id in what's left of the childControlIDs 
4)  And the second for the body_View and third for the footer_View

See the view_IndexChildren handler for details

The consequence of this is that changing the order / layer of the views and view_IndexChildren
effectively swaps the views around. This is a feature and not a bug :)
*/


--> Variables
-
local LocalArray
local HeaderView, BodyView, FooterView


--> Initialisation
-
command view_IndexChildren
   put word 3 of the header_Divider of me into headerDividerID
   put word 3 of the footer_Divider of me into footerDividerID
   put headerDividerID,footerDividerID into notIDs
   
   repeat for each line shortID in the childcontrolids of me
      if shortID is among the items of notIDs then next repeat
      put shortID & CR after goodIDs
   end repeat
   
   put the long id of control id (line 1 of goodIDs) into HeaderView
   put the long id of control id (line 2 of goodIDs) into BodyView
   put the long id of control id (line 3 of goodIDs) into FooterView
   return HeaderView & CR & BodyView & CR & FooterView
end view_IndexChildren


--> Events
-
on resizeControl
   LayoutControl the rect of me
   pass resizeControl
end resizeControl

on preOpenControl
   view_IndexChildren
   
   put the inner_Height of me into innerHeight
   put the vertical_Spacing of me into vSpacing
   put the header_DefaultHeight of me into minHeaderHeight
   put the body_DefaultHeight of me into minBodyHeight
   put the footer_DefaultHeight of me into minFooterHeight
   
   put the height of the header_View of me into actualHeight
   put innerHeight - minBodyHeight - minFooterHeight - 2 *  vSpacing into maxHeaderHeight
   if maxHeaderHeight > actualHeight > minHeaderHeight then
      put actualHeight into LocalArray ["header_Height"]
   else
      put max (actualHeight, minHeaderHeight) into headerHeight
      put min (headerHeight, maxHeaderHeight) into LocalArray ["header_Height"]
   end if
   
   put the height of the footer_View of me into actualHeight
   put innerHeight - minHeaderHeight - minBodyHeight - 2 *  vSpacing into maxFooterHeight
   if maxFooterHeight > actualHeight > minFooterHeight then
      -- it's OK leave it as it is
      put actualHeight into LocalArray ["footer_Height"]
   else
      put max (actualHeight, minFooterHeight) into footerHeight
      put min (footerHeight, maxFooterHeight) into LocalArray ["footer_Height"]
   end if
   
   put innerHeight - LocalArray ["header_Height"] - LocalArray ["footer_Height"] -  2 *  vSpacing into LocalArray ["body_Height"]
   -- display_Array LocalArray
end preOpenControl

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

on LayoutControl pRect
   if the long id of the target is not the long id of me then return empty -- this is important for views.
   if pRect is empty then put the rect of me into pRect
   
   put the header_Divider of me into headerBodySpacer
   put the footer_Divider of me into bodyFooterSpacer
   
   view_IndexChildren -- for safety (should only be needed on initialisation)
   put the visible of HeaderView into headerVisible
   put the visible of BodyView into bodyVisible
   put the visible of FooterView into footerVisible
   
   put the vertical_Spacing of me into vSpacing
   put the header_Rect [pRect] of me into headerRect
   put the body_Rect [pRect] of me into bodyRect
   put the footer_Rect [pRect] of me into footerRect
   
   if headerVisible is false then
      put item 2 of headerRect into item 2 of bodyRect
   end if
   
   if bodyVisible is false then
      if the fluid_View of me is "header_View" then
         put item 4 of bodyRect into item 4 of headerRect
      else
         put item 2 of bodyRect into item 2 of footerRect
      end if
   end if
   
   if footerVisible is false then
      put item 4 of footerRect into item 4 of bodyRect
   end if
   
   if the visible of HeaderView is true then
      put bodyRect into headerBodySpacerRect
      put item 4 of headerRect into item 2 of headerBodySpacerRect
      put item 2 of bodyRect into item 4 of headerBodySpacerRect
      
      if exists (headerBodySpacer) then
         set the rect of headerBodySpacer to headerBodySpacerRect
      end if
   end if
   
   if the visible of FooterView is true then
      put bodyRect into bodyFooterSpacerRect
      put item 2 of footerRect into footerTop
      put footerTop into item 4 of bodyFooterSpacerRect
      put footerTop - vSpacing into spacerTop
      put spacerTop into item 2 of bodyFooterSpacerRect
      
      if exists (bodyFooterSpacer) then
         set the rect of bodyFooterSpacer to bodyFooterSpacerRect
      end if
      
      if spacerTop < item 4 of bodyRect then
         -- minimal sized fluid footer won't squash anymore
         put spacerTop into item 4 of bodyRect -- hack
      end if
   end if
   
   -- test_Rect bodyRect, "bodyRect", "red"
   set the rect of HeaderView to headerRect
   set the rect of BodyView to bodyRect
   -- dispatch "LayoutControl" to BodyView with bodyRect
   set the rect of FooterView to footerRect
   -- set the rect of me to pRect
end LayoutControl


--> Controls
-
getprop vertical_Layout
   return the long id of me
end vertical_Layout

getprop layout_View
   return the long id of me
end layout_View

getprop view_Object
   return the long id of me
end view_Object

getprop header_View
   if exists (HeaderView) is false then view_IndexChildren
   return HeaderView
end header_View

getprop body_View
   if exists (BodyView) is false then view_IndexChildren
   return BodyView
end body_View

getprop footer_View
   if exists (FooterView) is false then view_IndexChildren
   return FooterView
end footer_View

getprop header_Divider
   if exists (control "_Header Divider" of me) is false then return empty
   return the long id of control "_Header Divider" of me
end header_Divider

getprop footer_Divider
   if exists (control "_Footer Divider" of me) is false then return empty
   return the long id of control "_Footer Divider" of me
end footer_Divider


--> Top | Children
-
getprop child_Names
   put the layout_Children of me into layoutChildren
   repeat for each line layoutChild in layoutChildren
      put the short name of layoutChild & CR after childNames
   end repeat
   delete char -1 of childNames
   return childNames
end child_Names

setprop child_Names childNames
   replace comma with CR in childNames
   
   -- let's check they are all there and correct
   put child_AllNamesThere (childNames) into allOK
   if allOK is false then return empty
   
   -- ok - so all there but a different order
   put the short name of the header_Divider of me & CR into topNames
   put the short name of the footer_Divider of me & CR after topNames
   put childNames after topNames
   
   set the top_ControlNames of me to topNames
   return the result
end child_Names

getprop layout_Children
   view_IndexChildren
   return the result
end layout_Children

private function child_AllNamesThere childNames
   put the child_Names of me into realChildNames
   if the number of lines of childNames is not the number of lines of realChildNames then
      return false
   end if
   repeat for each line childName in childNames
      if childName is not among the lines of realChildNames then
         return false
      end if
   end repeat
   return true
end child_AllNamesThere


--> Top | controls
-
getprop top_Controls
   put the childcontrolids of me into topIDs
   repeat for each line someID in topIDs
      put the long id of control id someID & CR after topControls
   end repeat
   delete char -1 of topControls
   return topControls
end top_Controls

getprop top_ControlName
   put the childcontrolids of me into topIDs
   if topIDs is empty then return empty
   
   put line 1 of topIDs into topID
   put the short name of control id topID into topControlName
   return topControlName
end top_ControlName

getprop top_Control [topName]
   -- finds or returns the top control
   put the childcontrolids of me into topIDs
   if topIDs is empty then return empty
   if topName is empty then
      put line 1 of topIDs into topID
      put the long id of control id topID into topControl
      return topControl
   end if
   
   -- let's find a top control with the name "topName"
   repeat for each line someID in topIDs
      put the long id of control id someID into someControl
      put the short name of someControl into testName
      if testName = topName then
         return someControl
      end if
   end repeat
   return empty
end top_Control

getprop top_ControlNames
   put the childcontrolids of me into topIDs
   repeat for each line someID in topIDs
      put the short name of control id someID & CR after topNames
   end repeat
   delete char -1 of topNames
   return topNames
end top_ControlNames

setprop top_ControlNames topNames
   replace comma with CR in topNames
   put the long id of me into layoutView
   repeat for each line topName in topNames
      put the top_Control [topName] of me into topControl
      if exists (topControl) is false then next repeat
      
      relayer topControl to front of me
   end repeat
   LayoutControl
   return the top_ControlNames of me
end top_ControlNames

getprop bottom_ControlName
   put the long id of me into layoutView
   
   put the childcontrolids of layoutView into topIDs
   if topIDs is empty then return empty
   
   put line -1 of topIDs into bottomID
   put the short name of control id bottomID into bottomName
   return bottomName
end bottom_ControlName

setprop bottom_ControlName bottomName
   put the long id of me into layoutView
   
   put the top_Control [bottomName] of layoutView into someControl
   if exists (someControl) is false then return empty
   
   relayer someControl to front of layoutView
   dispatch "LayoutControl" to layoutView
   
   return someControl
end bottom_ControlName


-- getprop layout_Elements
if the long id of the target is not the long id of me then pass layout_Elements

repeat for each item objectRef in "header_View,body_View,footer_View"
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

-- getprop placeholder_Num
put 0 into placeholderNum
repeat for each line viewChild in the view_Children of me
   put the view_Name of viewChild into viewChildName
   if viewChildName = "View|Layout|Placeholder" then
      add 1 to placeholderNum
   end if
end repeat
return placeholderNum
end placeholder_Num


--> Layout | Styles
-
getprop layout_Style
   set lockmessages to true
   put the layout_Style of me into someStyle 
   set lockmessages to false
   return someStyle
end layout_Style

setprop layout_Style someStyle
   lock screen
   switch someStyle
      case "browser"
         set the header_Height of me to 64
         set footer_Height of me to 49
         set the fluid_View of me to "body_View"
         
         set the control_Type of the header_View of me to "headerBar"
         set the control_Type of the body_View of me to "browser"
         set the control_Type of the footer_View of me to "navBar"
         
         set the showborder of the footer_View of me to false
         set the itemStyle of the footer_View of me to "icons"
         set the url of the body_View of me to "http://david.bovill.me"
         break
      case "small"
      default
         set the header_Height of me to 30
         set the footer_Height of me to 30
         set the fluid_View of me to "body_View"
         
         set the control_Type ["header_View"] of the header_View of me to "placeholder"
         set the control_Type ["body_View"] of the footer_View of me to "placeholder"
   end switch
   
   set lockmessages to true
   set the layout_Style of me to someStyle 
   set lockmessages to false
   unlock screen
end layout_Style

getprop layout_Styles
   return "small,browser"
end layout_Styles

getprop layout_DividerStyle
   lock messages
   put the layout_DividerStyle of me into someStyle
   unlock messages
   if someStyle is empty then
      put "icon" into someStyle
      set the layout_DividerStyle of me to someStyle
   end if
   return someStyle
end layout_DividerStyle

setprop layout_DividerStyle someStyle
   lock messages
   set the layout_DividerStyle of me to someStyle
   unlock messages
   
   lock screen
   put the header_Divider of me into headerDivider
   put the footer_Divider of me into footerDivider
   
   if exists (headerDivider) then
      set the divider_Style of headerDivider to someStyle
   end if
   if exists (footerDivider) then
      set the divider_Style of footerDivider to someStyle
   end if
   unlock screen
end layout_DividerStyle

getprop layout_DividerStyles
   return "transparent,opaque,icon,-,invisible"
end layout_DividerStyles


--> Props | Geometry | Spacing
-
getprop layout_Spacing
   -- ugly hack
   put the margins of me into myMargins
   return item 1 of myMargins
end layout_Spacing

setprop layout_Spacing someSpacing
   lock screen
   set the margins of me to someSpacing
   set the vertical_Spacing of me to someSpacing
   LayoutControl
   unlock screen 
end layout_Spacing


getprop vertical_Spacing  
   put LocalArray ["verticalSpacing"] into verticalSpacing
   if verticalSpacing is empty then
      -- a default
      put 0 into verticalSpacing
      put verticalSpacing into LocalArray ["verticalSpacing"]
   end if
   return verticalSpacing
end vertical_Spacing

setprop vertical_Spacing verticalSpacing
   put verticalSpacing into LocalArray ["verticalSpacing"]
   dispatch "LayoutControl" to me
   return the result
end vertical_Spacing


--> Props | Geometry | Defaults
-
getprop header_DefaultHeight
   return 30
end header_DefaultHeight

getprop body_DefaultHeight
   return 40
end body_DefaultHeight

getprop footer_DefaultHeight
   return 30
end footer_DefaultHeight


--> Props | Geometry
-
getprop title_Height
   return the header_Height of me
end title_Height

setprop title_Height someHeight
   set the header_Height of me to someHeight
end title_Height

getprop header_Height
   if the visible of the header_View of me = false then return 0
   switch the fluid_View of me
      case "header_View" -- calculate from other views
         put the inner_Height of me into headerHeight
         subtract the body_Height of me from headerHeight
         subtract the footer_Height of me from headerHeight
         subtract 2 * the vertical_Spacing of me from headerHeight
         break
      default
         put LocalArray ["header_Height"] into someHeight
   end switch
   
   if someHeight is a number then
      return someHeight
   else
      put the header_Height of the owner of me into someHeight
      if someHeight is a number then
         return someHeight
      else
         return the header_DefaultHeight of me
      end if
   end if
end header_Height

setprop header_Height someHeight
   put someHeight into LocalArray ["header_Height"]
   LayoutControl
   return the result
end header_Height

getprop body_Height
   if the visible of the body_View of me = false then return 0
   switch the fluid_View of me
      case "body_View" -- calculate from other views
         put the inner_Height of me into someHeight
         subtract the header_Height of me from someHeight
         subtract the footer_Height of me from someHeight
         subtract 2 * the vertical_Spacing of me from someHeight
         break
      default
         put LocalArray ["body_Height"] into someHeight
   end switch
   
   if someHeight is a number then
      return someHeight
   else
      put the body_Height of the owner of me into someHeight
      if someHeight is a number then
         return someHeight
      else
         return the body_DefaultHeight of me
      end if
   end if
end body_Height

setprop body_Height someHeight
   put someHeight into LocalArray ["body_Height"]
   dispatch "LayoutControl" to me -- resets the target
   return the result
end body_Height

getprop footer_Height
   if the visible of the footer_View of me = false then return 0
   switch the fluid_View of me
      case "footer_View" -- calculate from other views
         put the inner_Height of me into someHeight
         subtract the header_Height of me from someHeight
         subtract the body_Height of me from someHeight
         subtract 2 * the vertical_Spacing of me from someHeight
         break
      default
         put LocalArray ["footer_Height"] into someHeight
   end switch
   
   if someHeight is a number then
      return someHeight
   else
      put the footer_Height of the owner of me into someHeight
      if someHeight is a number then
         return someHeight
      else
         return the footer_DefaultHeight of me
      end if
   end if
end footer_Height

setprop footer_Height someHeight
   put someHeight into LocalArray ["footer_Height"]
   dispatch "LayoutControl" to me -- resets the target
   return the result
end footer_Height


--> Layout | Props
-
getprop title_Visible
   return the visible of the header_View of me
end title_Visible

setprop title_Visible someBoolean
   set the visible_Status of the header_View of me to someBoolean
end title_Visible

getprop header_Visible
   return the visible of the header_View of me
end header_Visible

setprop header_Visible someBoolean
   set the visible_Status of the header_View of me to someBoolean
end header_Visible

getprop body_Visible
   return the visible of the body_View of me
end body_Visible

setprop body_Visible someBoolean
   set the visible_Status of the body_View of me to someBoolean
end body_Visible

getprop footer_Visible
   return the visible of the footer_View of me
end footer_Visible

setprop footer_Visible someBoolean
   set the visible_Status of the footer_View of me to someBoolean
end footer_Visible


--> Props | Children
-
getprop visible_Status
   return the visible of the target
end visible_Status

setprop visible_Status someBoolean
   put the long id of the target into tObject
   
   lock screen
   put the rect of me into oRect
   set the visible of tObject to someBoolean
   put the layout_DividerStyle of me into dividerStyle
   if dividerStyle is not "invisible" then
      put the header_Divider of me into headerDivider
      put the footer_Divider of me into footerDivider
      
      switch -- now figure out which dividers to show or hide 
         case tObject = the header_View of me
            if exists (headerDivider) then
               set the visible of headerDivider to someBoolean
            end if
            break
         case tObject = the body_View of me
            if exists (headerDivider) then
               set the visible of headerDivider to someBoolean
            end if
            break
         case tObject = the footer_View of me
            if exists (footerDivider) then
               set the visible of footerDivider to someBoolean
            end if
            break
      end switch
   end if
   dispatch "LayoutControl" to me with oRect -- fixes target
   unlock screen
end visible_Status


--> Props | Geometry | Fluid
-
getprop fluid_View
   put the back_Property ["fluid_View"] of me into fluidView
   if fluidView is empty then return "body_View"
end fluid_View

setprop fluid_View fluidView
   set the back_Property ["fluid_View"] of me to fluidView
   
   put the height of the header_View of me into LocalArray ["header_Height"]
   put the height of the body_View of me into LocalArray ["body_Height"]
   put the height of the footer_View of me into LocalArray ["footer_Height"]
   
   LayoutControl
   return the result
end fluid_View

getprop fluid_Views
   return "header_View,body_View,footer_View"
end fluid_Views


--> Events | Divider
-
command layout_MoveTopDivider newHeaderHeight, newBodyHeight
   put newHeaderHeight into LocalArray ["header_Height"]
   put newBodyHeight into LocalArray ["body_Height"]
   
   # moved back to local variable for this dynamic property
   -- set the view_DisplayProperty ["header_Height"] of me to newHeaderHeight
   -- set the view_DisplayProperty ["body_Height"] of me to newBodyHeight
   LayoutControl
end layout_MoveTopDivider

command layout_MoveBottomDivider newBodyHeight, newFooterHeight
   put newBodyHeight into LocalArray ["body_Height"]
   put newFooterHeight into LocalArray ["footer_Height"]
   
   # moved back to local variable for this dynamic property
   -- set the view_DisplayProperty ["body_Height"] of me to newBodyHeight
   -- set the view_DisplayProperty ["footer_Height"] of me to newFooterHeight
   LayoutControl
end layout_MoveBottomDivider


--> View | Props
-
getprop view_Label
   if the long id of the target is not the long id of me then return empty
   return the view_Text of the header_View of me
end view_Label

setprop view_Label someText
   if the long id of the target is not the long id of me then return empty
   set the view_Text of the header_View of me to someText
end view_Label

getprop view_Text
   if the long id of the target is not the long id of me then return empty
   return the view_Text of the body_View of me
end view_Text

setprop view_Text someText
   if the long id of the target is not the long id of me then return empty
   set the view_Text of the body_View of me to someText
end view_Text

getprop view_HtmlText
   if the long id of the target is not the long id of me then return empty
   return the view_HtmlText of the body_View of me
end view_HtmlText

setprop view_HtmlText someText
   if the long id of the target is not the long id of me then return empty
   set the view_HtmlText of the body_View of me to someText
end view_HtmlText

getprop view_IsLocked
   if the long id of the target is not the long id of me then return empty
   return the view_IsLocked of the header_View of me
end view_IsLocked

setprop view_IsLocked someBoolean
   if the long id of the target is not the long id of me then return empty
   lock screen
   set the view_IsLocked of the header_View of me to someBoolean
   set the view_IsLocked of the body_View of me to someBoolean
   set the view_IsLocked of the footer_View of me to someBoolean
   unlock screen
end view_IsLocked


--> Geometry | Props
-
getprop header_Rect [pRect]
   put the inner_Rect [pRect] of me into headerRect
   put item 2 of headerRect + the header_Height of me into item 4 of headerRect
   return headerRect
end header_Rect

getprop body_Rect [pRect]
   put the inner_Rect [pRect] of me into bodyRect
   put the vertical_Spacing of me into vSpacing
   add the header_Height of me + vSpacing to item 2 of bodyRect
   put item 2 of bodyRect + the body_Height of me into item 4 of bodyRect
   
   -- a hack
   subtract 1 from item 2 of bodyRect
   
   return bodyRect
end body_Rect

getprop footer_Rect [pRect]
   put the inner_Rect [pRect] of me into footerRect
   put item 4 of footerRect - the footer_Height of me into item 2 of footerRect
   return footerRect
end footer_Rect


--> Geometry
-
-- setprop view_Rect someRect
-- this allows for nested views with or without "setprop view_Rect" handlers
if the long id of the target = the long id of me then
   LayoutControl someRect
else
   set the rect of the target to someRect
end if
end view_Rect

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
   
   /*
   put the header_View of me into HeaderView
   put the body_View of me into BodyView
   put the footer_View of me into FooterView
   */
   
   put the formatted_Width [viewID] of HeaderView into fHeaderWidth
   if fHeaderWidth is empty then put the formattedwidth of HeaderView into fHeaderWidth
   put fHeaderWidth & comma after widthList
   
   put the formatted_Width [viewID] of BodyView into fBodyWidth
   if fBodyWidth is empty then put the formattedwidth of BodyView into fBodyWidth
   put fBodyWidth & comma after widthList
   
   put the formatted_Width [viewID] of FooterView into fFooterWidth
   if fFooterWidth is empty then put the formattedwidth of FooterView into fFooterWidth
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


--> Deps | Props | Back
-
/*
Factor these out. They are too complicated.
*/

getprop back_Property [propName]
   put the long id of the target into tObject
   
   put the customproperties of tObject into propArray
   put propArray [propName] into titlePosistion
   if titlePosistion is empty then
      put object_GetOwner (tObject) into tOwner
      put the propName of tOwner into propValue
   end if
   return propValue
end back_Property

setprop back_Property [propName] someValue
   -- place in behavior (references "me")
   set the view_DisplayProperty [propName] of me to someValue
   -- dispatch "LayoutControl" to me -- changes the target (allowing lower level control use)
   return the result
end back_Property

setprop view_DisplayProperty [someProp] someValue
   put the long id of the target into targetObject
   
   -- put the view_DisplayArray of targetObject into displayArray
   -- put someValue into displayArray [someProp]
   -- set the view_DisplayArray of targetObject to displayArray
   
   -- lock messages
   -- set the someProp of targetObject to someValue
   -- to avoid recursion possibility
   put the customproperties of targetObject into cArray
   put someValue into cArray [someProp]
   set the customproperties of targetObject to cArray
   
   repeat with cNum = 1 to the number of controls of targetObject
      put the long id of control cNum of targetObject into cObject
      custom_DeleteProperty someProp, cObject
   end repeat
   -- unlock messages
end view_DisplayProperty


--> Deps | Geometry
-
getprop inner_Height [pRect]
   put the long id of the target into targetObject
   if pRect is empty then put the rect of targetObject into pRect
   put rect_GetInner (pRect, targetObject) into innerRect
   put item 4 of innerRect - item 2 of innerRect into innerHeight
   return innerHeight
end inner_Height

getprop inner_Rect [groupRect]
   put the long id of the target into someGroup
   if groupRect is empty then put the rect of someGroup into groupRect
   put rect_GetInner (groupRect, someGroup) into innerRect
   return innerRect
end inner_Rect

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

function rect_GetInner groupRect, someGroup
   if word 1 of someGroup is not "group" then return groupRect
   put the margins of someGroup into someMargin
   
   put the scrollbarwidth of someGroup into scrollBarMargin
   if the vscrollbar of someGroup is true then subtract scrollBarMargin from item 3 of groupRect
   if the hscrollbar of someGroup is true then subtract scrollBarMargin from item 4 of groupRect
   
   if the showborder of someGroup is true then
      put the borderwidth of someGroup into bWidth
      
      if the showname of someGroup is true then
         put the effective textheight of someGroup - bWidth - 1 into someBit
         add someBit to item 2 of someMargin
      end if
      
      rect_SubtractMargins groupRect, bWidth
   end if
   
   rect_SubtractMargins groupRect, someMargin
   return groupRect
end rect_GetInner

command rect_SubtractMargins @someRect, pMargin
   margin_Normalize pMargin, leftM, topM, rightM, bottomM   
   add leftM to item 1 of someRect
   add topM to item 2 of someRect
   subtract rightM from item 3 of someRect
   subtract bottomM from item 4 of someRect
end rect_SubtractMargins

getprop view_Height
   -- dangerous to put in a library in this general way
   -- allow views to define them
   -- returning empty is the same as undefined.
   return the height of the target	# a default (can over-ride locally)
end view_Height

setprop view_Height someHeight
   set the height of the target to someHeight	# a default (can over-ride locally)
   return the result
end view_Height


--> Deps | View
-
getprop view_AboveTarget
   -- use when you don't want a "view_Object" to trap things
   -- like when a datagrid is within a view object
   -- works even for datagrids, and objects without "view_Object" handlers
   put the long id of the target into targetObject
   repeat
      if the view_Name of targetObject is not empty then return targetObject
      if word 1 of targetObject = "group" and the selectGroupedControls of targetObject then return targetObject 
      if word 1 of targetObject = "stack" or targetObject = empty then return empty
      
      delete word 1 to 4 of targetObject -- does not work for substacks
   end repeat
end view_AboveTarget

getprop view_Name
   put the object_MetaData of the target into mData
   put word 1 to -1 of mData ["type"] into oType
   if oType is not among the items of "view,view template" then return empty
   put word 1 to -1 of mData ["name"] into viewName
   return viewName
end view_Name
