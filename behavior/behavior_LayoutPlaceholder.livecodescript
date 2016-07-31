script "behavior_ViewLayoutPlaceholder"
--> MetaData
-
license: GPLv3
name: behavior_View|Layout|Placeholder
type: view behavior
version: 0.4
copyright: David Bovill

/*
This "placeholder" view is useful for experimentign with a layout. 
Drag and drop views onto a placeholder to replace them.
It's also a great way to test the robsutness of your layout.
Can you replace all your views with placeholders and back and everything still work?
*/

local LocalArray

getprop view_Name
   -- here so all we need to do is set the behavior
   return "View|Layout|Placeholder"
end view_Name


--> Events
-
on mouseDown pMouseBtnNum
   put "Global | Layout | Placeholder | Menu" into mTitle
   menu_PopUp mTitle
end mouseDown


--> Drag
-
setprop drag_Hilite someBoolean
   if someBoolean is true then
      put the backgroundcolor of me into LocalArray ["originalColour"]
      set the dragAction to "link"
      set the backgroundcolor of me to "red"
      
      put the dragdata ["private"] into viewName
      put "About to drop view" & CR & kwote(viewName) into dropInfo
      set the label of me to dropInfo
   else
      set the backgroundcolor of me to LocalArray ["originalColour"]
      set the label of me to empty
      set the dragAction to "none"
   end if
end drag_Hilite


--> Events | Drag
-
on dragEnter   
   put the dragdata ["private"] into privateFlag
   put privateFlag
   switch
      case privateFlag is empty
         break
      case privateFlag = "behavior"
         break
      case privateFlag contains "|"
         put privateFlag into viewName
         put view_GetTemplateObject (viewName) into libraryObject
         if libraryObject is empty then
            opn_Notify merge("Not a view being dropped, [[viewName]] has no library object!"), true
            beep
         else
            set the drag_Hilite of me to true
         end if
         break
      default
   end switch
   pass dragEnter
end dragEnter

on dragLeave
   put the dragdata ["private"] into privateFlag
   switch
      case privateFlag is empty
         break
      case privateFlag = "behavior"
         break
      case privateFlag contains "|"
         set the drag_Hilite of me to false
         break
      default
   end switch
   pass dragLeave
end dragLeave


--> Menu | Target
-
getprop menu_Target [targetObject]
   return the long id of me
end menu_Target


--> View
-
getprop view_IsOpaque
   put the opaque of me into someBoolean
   return someBoolean
end view_IsOpaque

setprop view_IsOpaque someBoolean
   set the opaque of me to someBoolean
   set the showname of me to someBoolean
end view_IsOpaque

getprop view_Label
    return the effective label of the placeHolder_Button of me
end view_Label

setprop view_Label someText
    put the placeHolder_Button of me into placeHolderButton
    if the short name of placeHolderButton = someText then
        set the label of placeHolderButton to empty
    else
        set the label of placeHolderButton to someText
    end if
end view_Label

getprop view_Colour
    return the effective backgroundcolor of the placeHolder_Button of me
end view_Colour

setprop view_Colour someColour
   if someColour is "random" then put colour_GetRandom() into someColour
   set the backgroundcolor of the placeHolder_Button of me to someColour
end view_Colour


--> Geometry
-
getprop view_Height
   return the height of me
end view_Height

setprop view_Height someHeight
   if the height of me = someHeight then pass view_Height -- should we only do this when it has changed?
   
   lock screen
   put the long owner of me into myOwner
   put the rect of myOwner into oRect
   set the height of me to someHeight 
   dispatch "LayoutControl" to myOwner with oRect -- experimental  allows a container to resize itself
   unlock screen
end view_Height


--> Controls
-
getprop placeHolder_Button
    return the long id of me
end placeHolder_Button

getprop view_Object
    return the long id of me
end view_Object


--> Deps
-
function colour_GetRandom
   -- was "randomColour"
   put random(255) into item 1 of someColour
   put random(255) into item 2 of someColour
   put random(255) into item 3 of someColour
   return someColour
end colour_GetRandom
