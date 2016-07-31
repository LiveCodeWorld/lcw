script "behavior_View|Layouts|Horizontal|LeftToRight"
--> MetaData
-
license: GPLv3
name: behavior_View|Layouts|Horizontal|LeftToRight
type: view behavior
copyright: David Bovill
version: 0.1

/*
was "View|Layouts|Horizontal|Left to Right"
*/

getprop leftToRight_Layout
    return the long id of me
end leftToRight_Layout

getprop layout_View
    return the long id of me
end layout_View

getprop view_Object
    return the long id of me
end view_Object


--> Events
-


--> Record
-
on ResizeLabel recordLabelWidth
   -- upward (top down) chaining
   dispatch "ResizeLabel" to of the owner of me with recordLabelWidth
   if it is not "handled" then set the record_LabelWidth of me to recordLabelWidth
end ResizeLabel
   
getprop record_DefaultLabelWidth
   return 0
end record_DefaultLabelWidth

getprop record_LabelWidth
   -- if the long id of the target is not the long id of me then pass record_LabelWidth
   -- put the view_DisplayProperty ["record_LabelWidth"] of me into recordLabelWidth
   put the customproperties of me into propArray
   put propArray ["record_LabelWidth"] into recordLabelWidth
   
   if recordLabelWidth is empty then put the record_LabelWidth of the owner of me into recordLabelWidth
   if recordLabelWidth is empty then put the record_DefaultLabelWidth of me into recordLabelWidth
   return recordLabelWidth
end record_LabelWidth

setprop record_LabelWidth recordLabelWidth
   set the view_DisplayProperty ["record_LabelWidth"] of me to recordLabelWidth
   dispatch "LayoutControl" to me -- changes the target
end record_LabelWidth

getprop record_Height
   put the customproperties of me into propArray
   put propArray ["record_Height"] into recordHeight
   
   if recordHeight is empty then put the record_Height of the owner of me into recordHeight
   return recordHeight
end record_Height

setprop record_Height recordHeight
   set the view_DisplayProperty ["record_Height"] of me to recordHeight
   dispatch "LayoutControl" to me -- changes the target
   return the result
end record_Height


--> Geometry
-
on resizeControl
    if the long id of the target is not the long id of me then pass resizeControl
    LayoutControl the rect of me
end resizeControl

setprop view_Rect someRect
   if the long id of the target is not the long id of me then pass view_Rect
   lock screen
   set the rect of me to someRect
   LayoutControl someRect
   unlock screen
end view_Rect

on LayoutControl pRect
   if the long id of the target is not the long id of me then return empty -- this is important for nested datagrids at the moment.
   if pRect is empty then put the rect of me into pRect
   
   put the inner_Rect [pRect] of me into innerRect
   
   put the record_LabelWidth of me into recordLabelWidth
   add recordLabelWidth to item 1 of innerRect
   
   put the record_Height of me into recordHeight
   if recordHeight is a number then put item 2 of innerRect + recordHeight into item 4 of innerRect
   
   put the layout_Elements of me into layoutElements
   put the layout_Style of me into layoutStyle
   put the view_Spacing [innerRect] of me into viewSpacing
   
   switch layoutStyle
      case "centred"
         put rect_GetCentre (innerRect) into myCentre
         put the layout_TotalElementWidth of me into totalWidth
         put item 1 of myCentre - trunc(totalWidth/2) into myLeft
         put myLeft into newLeft
         repeat with lineNum = the number of lines of layoutElements down to 1
            put line lineNum of layoutElements into layoutElement
            
            put the layout_ElementWidth [layoutStyle] of layoutElement into someWidth
            
            put innerRect into elementRect
            put newLeft into item 1 of elementRect
            put newLeft + someWidth into elementRight
            put elementRight into item 3 of elementRect
            set the view_Rect of layoutElement to elementRect
            if the test_Layout of me is true then rect_CreateMask elementRect, layoutElement
            put elementRight + viewSpacing into newLeft
         end repeat
         break
      case "right to left"
         put item 3 of innerRect into newRight
         repeat with lineNum = the number of lines of layoutElements down to 1
            put line lineNum of layoutElements into layoutElement
            
            put the layout_ElementWidth [layoutStyle] of layoutElement into someWidth
            
            put innerRect into elementRect
            put newRight into item 3 of elementRect
            put newRight - someWidth into elementLeft
            put elementLeft into item 1 of elementRect
            set the view_Rect of layoutElement to elementRect
            if the test_Layout of me is true then rect_CreateMask elementRect, layoutElement
            put elementLeft - viewSpacing into newRight
         end repeat
         break
      default
         put item 1 of innerRect into newLeft
         if layoutStyle is among the items of "distributed,fixed" then add viewSpacing to newLeft
         repeat for each line layoutElement in layoutElements
            put the layout_ElementWidth [layoutStyle] of layoutElement into someWidth
            put innerRect into elementRect
            put newLeft into item 1 of elementRect
            put newLeft + someWidth into elementRight
            put elementRight into item 3 of elementRect
            set the view_Rect of layoutElement to elementRect
            if the test_Layout of me is true then rect_CreateMask elementRect, layoutElement
            put elementRight + viewSpacing into newLeft
         end repeat
   end switch
end LayoutControl

getprop test_Layout
   put the uOPN ["test_Layout"] of me into someBoolean
   return someBoolean is true
end test_Layout

setprop test_Layout someBoolean
   set the uOPN ["test_Layout"] of me to someBoolean
end test_Layout

getprop layout_Style
   put the uOPN ["layout_Style"] of me into layoutStyle
   if layoutStyle is empty then return "distributed"
   return layoutStyle
end layout_Style

getprop layout_Styles
   put the hkey_CaseConditions ["layout_ElementWidth,g"] of the behavior of me into layoutStyles
   return layoutStyles
end layout_Styles

setprop layout_Style layoutStyle
   set the uOPN ["layout_Style"] of me to layoutStyle
   LayoutControl
end layout_Style

getprop formatted_Width
   -- in development
   if the long id of the target is not the long id of me then pass formatted_Width
   /*
   put the layout_Style of me into layoutStyle
   switch layoutStyle
      case "fixed"
         -- put the layout_TotalElementWidth of me into fWidth
         -- add 
         break
      default
   end switch
   */
   
   put the left of group 1 of me into innerLeft
   put the right of last group of me into innerRight
   put innerRight - innerLeft into fWidth
   
   put the margins of me into myMargins
   margin_Normalize myMargins, lMargin, tMargin, rMargin, bMargin
   add lMargin to fWidth
   add rMargin to fWidth
   return fWidth
end formatted_Width

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

getprop layout_TotalElementWidth
   put the layout_Elements of me into layoutElements
   put the view_Spacing of me into viewSpacing
   put 0 into layoutElementWidth
   repeat for each line layoutElement in layoutElements
      add the layout_ElementWidth of layoutElement to layoutElementWidth
      add viewSpacing to layoutElementWidth
   end repeat
   subtract viewSpacing from layoutElementWidth
   return layoutElementWidth
end layout_TotalElementWidth

getprop use_FormattedWidth
   put the uOPN ["use_FormattedWidth"] of me into someBoolean
   return someBoolean is true
end use_FormattedWidth

setprop use_FormattedWidth someBoolean
   set the uOPN ["use_FormattedWidth"] of me to someBoolean
end use_FormattedWidth

getprop layout_ElementWidth [layoutStyle]
   -- can be overridden by a prop in the target 
   put the long id of the target into layoutElement
   if layoutStyle is empty then put the layout_Style of me into layoutStyle
   if the long id of the target = the long id of me then pass layout_ElementWidth
   
   put the uOPN ["layout_ElementWidth"] of me into someWidth
   if someWidth is a number then return someWidth
   
   switch layoutStyle
      case "centred"
      case "left to right"
      case "right to left"
      case "edge to edge"
      case "distributed"
      default
         if the view_Name of layoutElement contains "|Divider|" then
            put the width of layoutElement into someWidth
         else
            if the use_FormattedWidth of me is true then
               put the formatted_Width of layoutElement into someWidth
               if someWidth is not empty then return someWidth
               put the formattedwidth of layoutElement into someWidth
               if someWidth is not empty then return someWidth
            end if
            put the width of layoutElement into someWidth
         end if
         return someWidth
   end switch
end layout_ElementWidth

setprop layout_ElementWidth layoutElementWidth
   set the uOPN ["layout_ElementWidth"] of me to layoutElementWidth
   set the view_Rect of me to the rect of me
end layout_ElementWidth

private function _ElementWidthSum
   put the layout_Elements of me into layoutElements
   put 0 into layoutElementWidth
   repeat for each line layoutElement in layoutElements
      add the layout_ElementWidth of layoutElement to layoutElementWidth
   end repeat
   return layoutElementWidth
end _ElementWidthSum

getprop view_Spacing [innerRect]
   put the layout_Style of me into layoutStyle
   switch layoutStyle 
      case "edge to edge"
         -- would be faster if calculated within the LayoutControl handler
         if innerRect is empty then put the inner_Rect of me into innerRect
         put item 3 of innerRect - item 1 of innerRect into innerWidth
         
         put the layout_Elements of me into layoutElements
         put 0 into layoutElementWidth
         repeat for each line layoutElement in layoutElements
            add the layout_ElementWidth of layoutElement to elementWidth
         end repeat
         
         put the number of lines of layoutElements - 1 into spacerNum
         if spacerNum = 0 then
            put 0 into viewSpacing
         else
            put round ((innerWidth - elementWidth) / spacerNum) into viewSpacing
         end if
         break
      case "distributed"
         -- would be faster if calculated within the LayoutControl handler
         if innerRect is empty then put the inner_Rect of me into innerRect
         put item 3 of innerRect - item 1 of innerRect into innerWidth
         
         put the layout_Elements of me into layoutElements
         put 0 into layoutElementWidth
         repeat for each line layoutElement in layoutElements
            add the layout_ElementWidth of layoutElement to elementWidth
         end repeat
         
         put the number of lines of layoutElements + 1 into spacerNum
         put round ((innerWidth - elementWidth) / spacerNum) into viewSpacing
         break
      default -- case "fixed"
         put the uOPN ["view_Spacing"] of me into viewSpacing
         if viewSpacing is empty then return 0
   end switch
   return viewSpacing
end view_Spacing

setprop view_Spacing viewSpacing
   set the uOPN ["view_Spacing"] of me to viewSpacing
   LayoutControl
end view_Spacing

command layout_RestDividers layoutElements
   layout_DeleteDividers
end layout_RestDividers

on layout_DeleteDividers
   put the object_TopControls of me into topControls
   repeat for each line someObject in topControls
      put the view_Name of someObject into vName
      if vName begins with "View|Divider|" then
         delete someObject
      end if
   end repeat
end layout_DeleteDividers

on layout_DeleteElements
   put the object_TopControls of me into topControls
   repeat for each line someObject in topControls
      delete someObject
   end repeat
end layout_DeleteElements


--> Layout
-
getprop layout_ViewNames
   local vNames
   put the object_TopControls of me into topControls
   repeat for each line someObject in topControls
      put the view_Name of someObject into vName 
      put vName & CR after vNames
   end repeat
   delete last char of vNames
   return vNames
end layout_ViewNames

setprop layout_ViewNames vNames
   replace comma with CR in vNames
   layout_DeleteElements
   repeat for each line vName in vNames
      set the view_Insert of me to vName
   end repeat
end layout_ViewNames


--> Objects
-
getprop view_Children
   return the layout_Elements of me
end view_Children

getprop layout_Element [elementNum]
   if elementNum is empty then put 1 into elementNum
   put the layout_Elements of me into layoutElements
   return line elementNum of layoutElements
end layout_Element

getprop layout_Elements
   put the object_TopControls of me into topControls
   return topControls
end layout_Elements


--> View | Object | Children
-
