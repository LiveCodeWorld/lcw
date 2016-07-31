script "behavior_Geometry"
--> MetaData
-
license: GPLv3
name: behavior_Geometry
type: behavior
version: 0.1

/*
Here we experiment with creating an abstract geometry behavior library that can be used behind view specific libraries.
We do this instead of creating global libraries in order to not polute the name space.

We try to migrate useful handelr shere bit by bit.
*/


--> Geometry | Props
-
getprop smaller_Rect [someMargin]
   if someMargin is empty then put 8 into someMargin
   put the rect of the target into someRect
   rect_SubtractMargins someRect, someMargin
   return someRect
end smaller_Rect

getprop bigger_Rect [someMargin]
   if someMargin is empty then put 8 into someMargin
   put the rect of the target into someRect
   rect_AddMargins someRect, someMargin
   return someRect
end bigger_Rect

getprop inner_Rect [groupRect]
   -- put rect_GetInner (groupRect, someGroup) into innerRect
   
   put the long id of the target into someGroup
   if groupRect is empty then put the rect of someGroup into groupRect
   
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
end inner_Rect




--> Geometry | Margins
-
command rect_SubtractMargins @someRect, pMargin
   margin_Normalize pMargin, leftM, topM, rightM, bottomM   
   add leftM to item 1 of someRect
   add topM to item 2 of someRect
   subtract rightM from item 3 of someRect
   subtract bottomM from item 4 of someRect
end rect_SubtractMargins

command rect_AddMargins @someRect, pMargin
   margin_Normalize pMargin, leftM, topM, rightM, bottomM   
   subtract leftM from item 1 of someRect
   subtract topM from item 2 of someRect
   add rightM to item 3 of someRect
   add bottomM to item 4 of someRect
end rect_AddMargins

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

function margins_Add someMargins, anotherMargins
   margin_Normalize someMargins, leftT, topT, rightT, bottomT  
   margin_Normalize anotherMargins, leftM, topM, rightM, bottomM   
   add leftM to leftT
   add topM to topT
   add rightM to rightT
   add bottomM to bottomT
   
   return leftT,topT,rightT,bottomT  
end margins_Add
