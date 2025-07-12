script "behavior_View_System_Drop"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_View_System_Drop
type: behavior
version: 0.1


--> Working on
-
command _DoOK
   put the short name of the defaultstack into sName
   set the visible of stack sName to false
   set the systemwindow of stack sName to false
end _DoOK

command _DoField
   if the optionKey is "Down" then
      put the selected_LineNums of me into lineNum
      set the deleted_LineNums of me to lineNum
   end if
end _DoField


--> Props
-
setprop add_Url sURL
   put the displayed_Urls of me into droppedIndex
   line_Add sURL, droppedIndex
   set the displayed_Urls of me to droppedIndex
   --
   imagine_AddUrl sURL
   --
   return droppedIndex
end add_Url

getprop displayed_Urls
   get the displayed_Index of _TreeGroup()
   return it
end displayed_Urls

setprop displayed_Urls urlIndex
   set the displayed_Index of _TreeGroup() to urlIndex
   return urlIndex
end displayed_Urls


--> Events
-
on mouseUp
   switch
      case the short name of the target = "OK"
         _DoOK
         break
   end switch   
end mouseUp

on dragEnter
   set the dragAction to copy
end dragEnter

on dragDrop
   -- put the keys of the dragData & CR&CR & the keys of the fullDragData & CR&CR & the keys of the rawDragData
   put rawDragData ["public.url"] into publicURL
   --
   -- answer publicURL
   set the add_Url of me to publicURL
end dragDrop


--> Events
-
on resizeControl
   put the rect of me into viewRect
   LayoutControl viewRect
end resizeControl

command LayoutControl pRect
   lock screen
   if pRect is empty then put the rect of me into pRect
   put the footer_Height of me into footerHeight
   
   # Define Objects
   put _TreeGroup() into treeGroup
   put _OkButton() into okButton
   
   put the margins of me into myMargins
   rect_SubtractMargins pRect, myMargins
   
   # Tree Rect
   put pRect into treeRect
   put item 4 of treeRect - footerHeight into treeBottom
   put treeBottom into item 4 of treeRect
   
   # Footer Rect
   put pRect into footerRect
   put treeBottom into item 2 of footerRect
   
   # Button Loc
   put rect_GetCentre (footerRect) into buttonLoc
   
   # Set Positions
   set the rect of treeGroup to treeRect
   set the loc of okButton to buttonLoc
   unlock screen
end LayoutControl

getprop footer_Height
   put the uOPN ["footer_Height"] of me into sHeight
   if sHeight is a number then
      return sHeight
   else
      return 36
   end if
end footer_Height

setprop footer_Height sHeight
   set the uOPN ["footer_Height"] of me to sHeight
end footer_Height


--> Objects | Props
-
private function _OkButtonName
   return the short name of _OkButton()
end _OkButtonName


--> Objects
-
getprop view_Object
   return the long id of me
end view_Object

private function _TreeGroup
   return the long id of grp 1 of me
end _TreeGroup

private function _OkButton
   return the long id of btn "OK" of me
end _OkButton
