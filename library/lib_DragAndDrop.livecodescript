script "lib_DragAndDrop"
--> MetaData
-
license: GPLv3
name: lib_DragAndDrop
type: library
version: 0.1


/*
The start of a library for all things drag and drop.

This library is a fairly crude hack that allow global drag and dropping onto any Livecode control.

See library script events of stack "libOPN_FrontScript":  "dragEnter" and "dragDrop"
They use "drag_GetGlobalStatus" and "drag_SetGlobalStatus"
*/


-> Events | Drag and Drop
-
on dragEnter
   if drag_GetGlobalStatus() is true then
      put the dragdestination into dropTarget
      put the dragsource into gDragSource
      switch
         case gDragSource = dropTarget
            set the dragAction to "none"
            break
         case the view_Name of dropTarget is empty and word 1 of the owner of dropTarget = "card"
            set the dragAction to "copy"
            break
         default
            -- it's a view
            set the dragAction to "link"
      end switch
   end if
   pass dragEnter
end dragEnter

on dragDrop
   -- just so we don't need to remember to do it in "dragEnd" handler  in the source
   drag_SetGlobalStatus false
   
   -- no passing prevents dropping of text into fields
   pass dragDrop
end dragDrop


--> Drag and Drop
-
on drag_SetGlobalStatus someBoolean
    global OPN
    put someBoolean is true into OPN ["Global_Drag"]
end drag_SetGlobalStatus

function drag_GetGlobalStatus
    global OPN
    return OPN ["Global_Drag"] is true 
end drag_GetGlobalStatus


--> Drag
-
setprop drag_Dropped
   -- a default value 
   -- put here to avoid setting custom properties of things that should not be touched
    -- put the params
end drag_Dropped

getprop dropped_TargetName
   put the long id of the target into targetObject
   put drag_GetDroppedTargetView (targetObject) into targetView
   return targetView
end dropped_TargetName

function drag_GetDroppedTargetView targetObject
   put the name of targetObject
   put the locked_View of targetObject into targetView
   if exists (targetView) is false then return false
   return targetView
end drag_GetDroppedTargetView
