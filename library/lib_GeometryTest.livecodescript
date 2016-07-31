script "lib_GeometryTest"
--> MetaData
-
license: GPLv3
name: lib_GeometryTest
type: library
version: 0.1


--> Create
-
command create_PlaceHolder someName, pRect, pGroupID, pColour, pShowName
   if someRect is a rect then
      set the rect of the templateButton to someRect
   end if
   
   switch pColour
      case empty
      case "random"
         put colour_GetRandom() into pColour
      default
         set the backgroundcolor of the templateButton to pColour
   end switch
   
   set the style of the templateButton to "rectangle"
   set the autohilite of the templateButton to false
   set the showfocusborder of the templateButton to false
   set the traversalon of the templateButton to false
   set the threed of the templateButton to false
   set the showname of the templateButton to (pShowName is not false)
   set the borderwidth of the templateButton to 1
   
   if the platform contains "Mac" then
      set the ink of the templateButton to "blend"
   else
      set the ink of the templateButton to "srcAnd"
   end if
   
   if exists (stack "behavior_ViewLayoutPlaceholder") then
      put the name of stack "behavior_ViewLayoutPlaceholder" into stackObject
      set the behavior of the templateButton to stackObject
   else
      put script_SelfDeleteScript() into someScript
   end if
   
   if pGroupID is empty then
      create button someName
   else
      create button someName in group id pGroupID
   end if
   put it into placeholderButton
   
   choose browse tool
   reset the templateButton
   return placeholderButton
end create_PlaceHolder

setprop rect_Mask [someRect] someColour
   put the long id of the target into targetObject
   if someRect is empty then put the rect of targetObject into someRect
   put the short name of targetObject && someColour into someName
   
   switch
      case exists (btn someName)
         put the long id of btn someName into placeholderButton
         
         if someRect is a rect then
            set the rect of placeholderButton to someRect
         end if
         
         switch someColour
            case empty
            case "random"
               put colour_GetRandom() into someColour
            default
               set the backgroundcolor of placeholderButton to someColour
         end switch
         return placeholderButton
      default
         create_Placeholder someName, pRect, pGroupID, someColour
         put the result into placeholderButton
         return placeholderButton
   end switch
end rect_Mask


--> Create | Test Button
-
command test_Rect someRect, someName, pColour
   -- this puts the button inside the group
   put script_CallingObject() into callingObject
   put the short id of callingObject into pGroupID
   
   switch
      case exists (btn someName)
         put the long id of btn someName into placeholderButton
         if someRect is a rect then
            set the rect of placeholderButton to someRect
         end if
         return placeholderButton
      default
         create_Placeholder someName, someRect, pGroupID, pColour
         put the result into placeholderButton
         return placeholderButton
   end switch
end test_Rect

command rect_Test someRect
   -- this puts the button on the card
   put script_CallingObject() into callingObject
   if the rect of callingObject is not someRect then
      set the rect_Mask [someRect] of callingObject to "red"
   end if
end rect_Test

setprop rect_MaskName [someColour] someName
    put the long id of the target into targetObject
     
    put the rect of targetObject into someRect
    switch word 1 of targetObject 
        case "group"
            put the short id of targetObject into insideID
            rect_CreateTestButton someRect, someName, empty, insideID, someColour, empty
            break
        case "background"
            put the short id of targetObject into insideID
            rect_CreateTestButton someRect, someName, empty, insideID, someColour, empty
            break
        default
            rect_CreateTestButton someRect, someName, empty, empty, someColour, empty
    end switch
    return the result
end rect_MaskName

command rect_CreateMask someRect, someName, targetObject, pColour
   local someScript, insideID, createInvisible
   put the defaultstack into oDefault
   if exists(targetObject) then
      set the defaultstack to the stack_Object of targetObject
   end if
   
   rect_CreateTestButton someRect, someName, someScript, insideID, pColour, createInvisible
   put the result into createdButton
   set the defaultstack to oDefault
   return createdButton
end rect_CreateMask

command rect_CreateTestButton someRect, someName, someScript, insideID, someColour, createInvisible   
   if exists (btn someName) then
      put the long id of btn someName into placeholderButton
      
      if someRect is a rect then
         set the rect of placeholderButton to someRect
      end if
      
      switch someColour
         case empty
         case "random"
            put colour_GetRandom() into someColour
         default
            set the backgroundcolor of placeholderButton to someColour
      end switch
      return placeholderButton
   end if
   
   create_Placeholder someName, pRect, pGroupID, someColour
   put the result into placeholderButton
   return placeholderButton
end rect_CreateTestButton

command rect_MouseDownDraw startLoc, imageView
    if imageView is empty then
        put the image_View of the target into imageView
        if exists(imageView) is false then return empty
    end if
    if startLoc is empty then put the clickloc into startLoc
    put the short id of the view_Object of the target into insideID
     
    put startLoc & "," & the mouseloc into someRect
    if someRect is not a rect then return empty
    
    put empty into someScript
    rect_CreateTestButton someRect, "_ZoomRectSelector", someScript, insideID, "yellow"
    put the result into zoomButton
    unlock screen
    
    repeat until the mouse is "Up"
        put startLoc & "," & the mouseloc into someRect
        if someRect is a rect then
            set the rect of zoomButton to someRect
        end if
        -- unlock screen
    end repeat
    put the rect of zoomButton into zoomRect
    delete zoomButton
    
    -- image_ScaleWithin zoomRect, imageView
    return zoomRect
end rect_MouseDownDraw

function script_SelfDeleteScript
    put "on mouseUp" & return into someScript
    put "put the long id of the target into targetObject" & return after someScript
    put "send" && kwote("delete targetObject") && " to the target in 2 ticks" & return after someScript
    put "end mouseUp" after someScript
    return someScript
end script_SelfDeleteScript
