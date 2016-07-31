script "behavior_LayoutGroup"
--> MetaData
-
license: GPLv3
name: View|Layout|Group
type: view behavior
version: 0.2

/*
*/


--> Variables
-
local LocalArray


--> Events
-
on preOpenControl
   -- nothing to do here
   pass preOpenControl
end preOpenControl

on resizeControl
   put the rect of me into pRect
   LayoutControl pRect
end resizeControl

on refresh pHow
   LayoutControl
   return the result
end refresh

on LayoutControl pRect
   if pRect is empty then put the rect of me into pRect
   put the top_Controls of me into topControls
   
   lock screen
   repeat for each line topControl in topControls
      set the rect of topControl to pRect
   end repeat
   unlock screen
   return topControls
end LayoutControl


--> Child 
-


--> Controls
-
getprop group_Layout
   return the long id of me
end group_Layout

getprop layout_View
   return the long id of me
end layout_View

getprop view_Object
   return the long id of me
end view_Object


--> Group | Props
-
getprop visible_Object
   put the childcontrolids of me into topIDs
   repeat for each line someID in topIDs
      if the visible of control id someID is true then
         return the long id of control id someID
      end if
   end repeat
   return empty
end visible_Object

getprop visible_Name
   put the childcontrolids of me into topIDs
   repeat for each line someID in topIDs
      if the visible of control id someID is true then
         return the short name of control id someID
      end if
   end repeat
   return empty
end visible_Name

setprop visible_Name someName
   put the childcontrolids of me into topIDs
   repeat for each line someID in topIDs
      put the short name of control id someID = someName into makeVisible
      if makeVisible is true  and doneFirst is not true then
         set the visible of control id someID to true
         put the long id of control id someID into theVisibleOne
         put true into doneFirst
      else
         set the visible of control id someID to false
      end if
   end repeat
   return theVisibleOne
end visible_Name

getprop visible_Names
   return the top_ControlNames of me
end visible_Names



--> Layout | Children
-
getprop layout_Children
   return the top_Controls of me
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
