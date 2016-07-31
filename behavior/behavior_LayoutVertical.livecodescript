script "behavior_View|Layout|Vertical"
--> MetaData
-
license: GPLv3
name: View|Layout|Vertical
type: view behavior
version: 0.1


--> Work in Progress
-
local LocalArray

getprop child_Names
   put the childcontrolids of me into topControlIDs
   put the number of lines of topControlIDs into numberOfChildren
   
   repeat with cNum = 1 to numberOfChildren    
      put line cNum of topControlIDs into topControlID
      
      put the short name of control id topControlID into childName
      put childName & CR after childNames
   end repeat
   delete char -1 of childNames
   return childNames
end child_Names


--> Events
-
on resizeControl pFirstparam
   put the rect of me into pRect
   LayoutControl pRect
end resizeControl


--> Geometry
-
on LayoutControl pRect
   lock screen
   if pRect is empty then put the rect of me into pRect
   put the margins of me into myMargins
   rect_SubtractMargins pRect, myMargins
   
   -- rect_CreateMask pRect, "Inner"
   
   put item 4 of pRect - item 2 of pRect into innerHeight
   
   put the childcontrolids of me into topControlIDs
   put the number of lines of topControlIDs into numberOfChildren
   if numberOfChildren = 0 then return 0
   
   put numberOfChildren - 1 into gutterNum
   put the view_Spacing of me into viewSpacing
   
   put item 2 of pRect into childTop
   repeat with cNum = 1 to numberOfChildren    
      put line cNum of topControlIDs into topControlID
      
      put the effective height of control id topControlID into someHeight
      put childTop + someHeight into childBottom
      
      put pRect into childRect
      put childTop into item 2 of childRect
      put childBottom into item 4 of childRect
      set the rect of control id topControlID to childRect
      
      -- rect_CreateMask childRect, ("Child" && topControlID)
      
      put childBottom + viewSpacing into childTop
   end repeat
   unlock screen
   return numberOfChildren
end LayoutControl

getprop view_Spacing
   put LocalArray ["viewSpacing"] into someNum
   if someNum is not a number then -- let's set a default
      put 20 into someNum
      put someNum into LocalArray ["viewSpacing"]
   end if
   return someNum
end view_Spacing

setprop view_Spacing someNum
   put someNum into LocalArray ["viewSpacing"]
   LayoutControl
end view_Spacing
