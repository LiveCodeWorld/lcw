script "behavior_View_Array"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_View_Array
type: behavior
version: 0.1


--> Working on
-

--> Events
-
on resizeControl
   put the rect of me into viewRect
   LayoutControl viewRect
end resizeControl

command LayoutControl pRect
   lock screen
   if pRect is empty then put the rect of me into pRect
   
   -- do your geometry here
   unlock screen
end LayoutControl


--> Objects
-
getprop view_Object
   return the long id of me
end view_Object
