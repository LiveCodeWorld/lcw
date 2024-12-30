script "behavior_CardModule"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_CardModule
type: behavior
version: 0.1

/*
A minimal script to work with the View|Tree module.
*/


--> Working on
-

--> Margins
-
getprop view_RectOnCard [pMargin]
   if pMargin is empty then
      put the card_Margin of me into pMargin
   end if
   
   put the rect of me into sRect
   if pMargin is not 0 then
      rect_SubtractMargins sRect, pMargin
   end if
   return sRect
end view_RectOnCard

getprop card_Margin
   put the uOPN ["card_Margin"] of me into cardMargin
   if cardMargin is empty then put 24 into cardMargin
   return cardMargin
end card_Margin

setprop card_Margin cardMargin
   set the uOPN ["card_Margin"] of me to cardMargin
   LayoutCard
end card_Margin


--> Objects
-
getprop displayed_Object
   return _DisplayedObject()   
end displayed_Object

getprop view_Object
   return _DisplayedObject()   
end view_Object

private function _DisplayedObject
   return the long id of control 1 of me
end _DisplayedObject


--> Layout
-
on LayoutCard
   put the view_RectOnCard of me into viewRect
   dispatch "LayoutControl" to _DisplayedObject() with viewRect
end LayoutCard


--> Events
-
on preOpenCard
   dispatch "view_Init" to _DisplayedObject()
   pass preOpenCard
end preOpenCard

on resizeStack
   LayoutCard
   pass resizeStack
end resizeStack

--> Deps
-
command rect_SubtractMargins @sRect, pMargin
   margin_Normalize pMargin, leftM, topM, rightM, bottomM   
   add leftM to item 1 of sRect
   add topM to item 2 of sRect
   subtract rightM from item 3 of sRect
   subtract bottomM from item 4 of sRect
end rect_SubtractMargins

command margin_Normalize @someMargin, @leftM, @topM, @rightM, @bottomM
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
