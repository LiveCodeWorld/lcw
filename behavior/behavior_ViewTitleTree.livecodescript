script "behavior_ViewTitleTree"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewTitleTree
type: behavior
version: 0.5

/*
A basic title for tree views.
*/


--> Controls
-
getprop view_Object
   return the long id of me
end view_Object

getprop title_View
   return the long id of me
end title_View

getprop tree_Title
   return the long id of me
end tree_Title


--> Standalone
-
private function _IsStandalone
   set the wholematches to true
   put "libOPN_Menus" is not among the lines of the stacksInUse into someBoolean
   return someBoolean
end _IsStandalone


--> Events
-
on mouseDown pMouseBtnNum
   put the long id of of the target into targetObject
   put the icon_Button of me into iconButton
   put title_Button() into titleButton
   
   if the title_IsStackDragger of the target is true then
      stack_Drag
   else
      put the long owner of me into titleOwner
      put the menu_ToolOrTitle of me into mTitle
      if targetObject = iconButton then
         put the bottomleft of iconButton into pLocation
         add 4 to item 1 of pLocation
         menu_PullDown mTitle, pLocation, titleOwner
      else if targetObject = titleButton then
         if the visible of iconButton is false then
            put the bottomleft of me into pLocation
            menu_PullDown mTitle, pLocation, titleOwner
         end if
      end if
   end if
end mouseDown


--> Title
-
getprop menu_ToolOrTitle
    if the controlKey is "Down" then
      return the menu_ToolTitle of the target
   else
      return the menu_Title of the target
   end if
end menu_ToolOrTitle

getprop menu_ToolTitle
   put the long id of me into viewObject
   put menu_GetToolTitle (viewObject) into myToolTitle
   
   put the view_Object of the owner of me into titleOwner
   if exists (titleOwner) is false or word 1 of titleOwner = "card" then return myToolTitle
   
   -- put menu_GetToolTitle (titleOwner) into ownerToolTitle
   put the menu_ToolTitle of titleOwner into ownerToolTitle
   if ownerToolTitle is empty then return myToolTitle
      
   put ownerToolTitle & CR into mToolTable
   put myToolTitle & tab & "submenu" after mToolTable
   return mToolTable
end menu_ToolTitle

function menu_GetToolTitle viewObject
   lock messages
   put the menu_ToolTitle of viewObject into mToolTitle
   unlock messages
   if mToolTitle is not empty then return mToolTitle
   
   put the view_Name of viewObject into viewName
   put "Global |" && menu_TitleFromViewName (viewName) into mToolTitle
   return mToolTitle
end menu_GetToolTitle

-- getprop menu_Target [mTitlePath]
switch
   case mTitlePath contains "Global | Icon | Menu"
      put the title_View of me into titleView
      if exists(titleView) is false then return empty
      put the icon_View of titleView into iconView
      return iconView
   case mTitlePath contains "Global | Title | Icon | Menu"
      put the title_View of me into titleView
      if exists(titleView) is false then return empty
      put the icon_View of titleView into iconView
      return iconView
   case mTitlePath contains "Global | Title |" -- Global | Title | Menu
      put the title_View of me into titleView
      if exists(titleView) is false then return empty
      return titleView
   default
      -- allow an enclosing group to define the mTarget
      pass menu_Target
      
      -- this is a default target (can be overridden at the mTopcontroller)
      put the long owner of me into mTarget
      return mTarget
end switch
end menu_Target
     

--> Icon
-
getprop icon_IsVisible
   put the visible of the icon_Button of me into someBoolean
   return someBoolean
end icon_IsVisible

setprop icon_IsVisible someBoolean
   lock screen
   set the visible of the icon_Button of me to someBoolean
   if someBoolean is true then
      set the title_TextAlign of me to "left"
   else
      set the title_TextAlign of me to "centre"
   end if
   unlock screen
end icon_IsVisible

getprop icon_Style
   if the long id of the target is not the long id of me then pass icon_Style
   put the icon_Button of me into iconView
   put the icon_Style of iconView into iconStyle
   return iconStyle
end icon_Style

setprop icon_Style iconStyle
   if the long id of the target is not the long id of me then pass icon_Style
   put the icon_Button of me into iconView
   set the icon_Style of iconView to iconStyle
end icon_Style


--> Title
-
getprop title_Text
   put title_Button() into titleButton
   get the label of titleButton
   return it
end title_Text

setprop title_Text someTitle
    put title_Button() into titleButton
    set the label of titleButton to someTitle
end title_Text

getprop title_TextAlign
    put title_Button() into titleButton
    return the textalign of titleButton
end title_TextAlign

setprop title_TextAlign alignHow
   put title_Button() into titleButton
   lock screen
   switch alignHow
      case "left"
         set the margins of titleButton to "16,7,4,4"
         break
      case "center"
         set the margins of titleButton to "4,7,4,4"
         break
      case "right"
         set the margins of titleButton to "4,7,16,4"
         break
   end switch
   set the textalign of titleButton to alignHow
   unlock screen
end title_TextAlign

getprop title_IsStackDragger
    get the uOPN [word 1 of the params] of me
    return it is true
end title_IsStackDragger

setprop title_IsStackDragger boolean
    set the uOPN [word 1 of the params] of me to boolean
end title_IsStackDragger


--> Title | Colours
-
getprop colour_Palette
   put title_Button() into titleButton
   put the foregroundcolor of titleButton into colourPaletteArray[1]
   put the backgroundcolor of titleButton into colourPaletteArray[2]
   put the backgroundcolor of me into colourPaletteArray[4]
   return colourPaletteArray
end colour_Palette

setprop colour_Palette colourPaletteArray
   put title_Button() into titleButton
   lock screen   
   set the foregroundcolor of titleButton to colourPaletteArray[1]
   set the backgroundcolor of titleButton to colourPaletteArray[2]
   set the backgroundcolor of me to colourPaletteArray[4]
   unlock screen
end colour_Palette

getprop title_TextColour
   return the foregroundcolor of title_Button()
end title_TextColour

setprop title_TextColour someColour
   set the foregroundcolor of title_Button() to someColour
end title_TextColour

getprop title_Colour
   put title_Button() into titleButton
   put background_Button() into iconBackground
   
   if the visible of iconBackground is true then
      return empty
   else
      return the backgroundcolor of titleButton
   end if
end title_Colour

setprop title_Colour someColour
   put background_Button() into iconBackground
   put title_Button() into titleButton
   
   if someColour is empty or someColour is "none" then
      -- set the backgroundColor of titleButton to empty
      set the opaque of titleButton to false
      set the visible of iconBackground to true
   else
      set the backgroundcolor of titleButton to someColour
      set the opaque of titleButton to true
      set the visible of iconBackground to false
   end if
end title_Colour


--> View
-
getprop view_Text
    put title_Button() into labelButton
    put the label of labelButton into someTitle
    return someTitle
end view_Text

setprop view_Text someTitle
    put title_Button() into labelButton
    set the label of labelButton to someTitle
end view_Text


--> Objects
-
getprop menu_Button
    return the long id of btn "_Title Menu" of me
end menu_Button
    
private function title_Button
    return the long id of btn "_Title Button" of me
end title_Button

private function background_Button
   return the long id of btn "_Title Background" of me
end background_Button


--> View Children
-
getprop icon_View
   return the icon_Button of me
end icon_View

getprop icon_Button
   -- should be a better way of doing this rather than searching
   repeat with btnNum = the number of btns of me down to 1
      if the short name of btn btnNum of me is not among the items of "_Title Menu,_Title Button,_Title Background" then
         return the long id of btn btnNum of me
      end if
   end repeat
   return empty
end icon_Button


--> Geometry
-
on resizeControl
   LayoutControl the rect of me
end resizeControl

setprop view_Rect someRect
   LayoutControl someRect
end view_Rect

on LayoutControl pRect
   if pRect is empty then put the rect of me into pRect
   
   put background_Button() into titleBackground
   put title_Button() into titleMenu
   put the icon_Button of me into titleRightIconButton
   put the menu_Button of me into titleMenuButton
   
   put rect_SubtractMargin (4, pRect) into rightIconRect
   put item 4 of rightIconRect - item 2 of rightIconRect into rightIconHeight
   put item 3 of rightIconRect - rightIconHeight into item 1 of rightIconRect
   
   set the rect of titleBackground to pRect
   set the rect of titleMenu to pRect
   set the rect of titleMenuButton to pRect
   
   set the rect of titleRightIconButton to rightIconRect
   
   -- dispatch view_HeightResized to me with pRect
end LayoutControl

getprop view_Height
    return the height of me
end view_Height

setprop view_Height someHeight
    put the long id of me into titleView
    put titleView into viewAbove
    delete word 1 to 4 of viewAbove
    
    lock screen
    put the rect of me into newRect
    put item 2 of newRect + someHeight into item 4 of newRect
    set the view_Rect of me to newRect
    
    get the view_Refresh of viewAbove
    unlock screen
end view_Height


--> Deps
-
on loc_SetTranslationVector fromPoint, toPoint, @xVector, @yVector
   put item 1 of toPoint - item 1 of fromPoint into xVector
   put item 2 of toPoint - item 2 of fromPoint into yVector
end loc_SetTranslationVector

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

function object_ExtractStack someObject
   set the wholematches to true
   put word (wordOffset ("stack", someObject)) to -1 of someObject into stackObject
   return stackObject
end object_ExtractStack

command rect_AddVector @someRect, pointVector
    -- was "rect_Translate"
    put item 1 of pointVector into xVector
    put item 2 of pointVector into yVector
     
    add xVector to item 1 of someRect
    add xVector to item 3 of someRect
     
    add yVector to item 2 of someRect
    add yVector to item 4 of someRect
end rect_AddVector

function rect_SubtractMargin someMargin, someRect
   rect_SubtractMargins someRect, someMargin
   return someRect
end rect_SubtractMargin

command rect_SubtractMargins @someRect, pMargin
   margin_Normalize pMargin, leftM, topM, rightM, bottomM   
   add leftM to item 1 of someRect
   add topM to item 2 of someRect
   subtract rightM from item 3 of someRect
   subtract bottomM from item 4 of someRect
end rect_SubtractMargins

function rect_TranslateByVector someRect, xVector, yVector
    put xVector,yVector into pointVector
    rect_AddVector someRect, pointVector
    return someRect
end rect_TranslateByVector

command stack_Drag stackObject
    if stackObject is empty then put the stack_Object of the target into stackObject
    put the rect of stackObject into oRect
    -- put the the globalloc of the clickloc into fromPoint
    put the screenmouseloc into fromPoint
     
    repeat while the mouse is "Down"
        put the screenmouseloc into toPoint
        loc_SetTranslationVector fromPoint, toPoint, xVector, yVector
        put rect_TranslateByVector(oRect, xVector, yVector) into newRect
        set the rect of stackObject to newRect
    end repeat
end stack_Drag

getprop stack_Object
    return the defaultstack
    
    -- old version
    put the long id of the target into targetObject
    return object_ExtractStack(targetObject)
end stack_Object

function text_OffsetAfter string, someText, startChar
    -- version 9.0
    if startChar < 0 then put 0 into startChar
    delete char 1 to startChar of someText
    get offset(string, someText)
    if it is 0 then return 0
    else return it + startChar
end text_OffsetAfter

function text_OffsetBefore someString, someText, beforeHere
  -- was "offsetBefore"
  if beforeHere is not empty then
    delete char beforeHere to -1 of someText
  end if
  put 1 into offsetNum
  put 0 into lastOffset
  repeat
    get text_OffsetAfter(someString, someText, lastOffset)
    if it is 0 then
      return lastOffset
    else
      put it into lastOffset
      add 1 to offsetNum
    end if
  end repeat
end text_OffsetBefore

getprop view_Name
   -- a value of the target (property is not inherited by objects below)  
   put the uRIP ["name"] of the target into vName
   if the dgProps ["style"] of the target is among the items of "table,form" then
      -- it is a datagrid
      if vName is empty then
         -- in case it is not named (ie a vanilla Rev control)
         return "View|Rev|Datagrid"
      else
         return vName
      end if
   else if the uRIP ["type"] of the target is not "view" then
      -- it is not only views that have uRip names
      return empty
   else
      return vName
   end if
end view_Name
