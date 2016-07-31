script "lib_Geometry"
--> MetaData
-
name: lib_Geometry
license: GPLv3
type: library
version: 0.8
copyright: David Bovill


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

getprop stack_Dimensions
   put the stack_Object of the target into stackObject
   return the width of stackObject, the height of stackObject
end stack_Dimensions

setprop stack_Dimensions [someMargin] someDimension
   put the stack_Object of the target into stackObject
   put item 1 of someDimension into someWidth
   put item 2 of someDimension into someHeight
   stack_SetDimensions stackObject, someWidth, someHeight, someMargin
   return the result
end stack_Dimensions

setprop stack_RectWithin [pMargin] outsideRect
   if pMargin is not empty then rect_SubtractMargins outsideRect, pMargin
   put the stack_Object of the target into stackObject
   put the rect of stackObject into someRect
   rect_ShiftWithin someRect, outsideRect
   set the rect of stackObject to someRect
   return someRect
end stack_RectWithin

getprop box_Rect [groupRect]
   put the long id of the target into someGroup
   if word 1 of someGroup is not "group" then return groupRect
   if groupRect is empty then put the rect of someGroup into groupRect
   
   if the showname of someGroup is true then
      put the effective textsize of someGroup into tHeight
      if the threeD of someGroup is true then
         add tHeight + 4 to someBit
      else
         add round (tHeight/2) + 0 to someBit
      end if
      add someBit to item 2 of groupRect
   end if
   return groupRect
end box_Rect

getprop inner_Rect [groupRect]
   put the long id of the target into someGroup
   if groupRect is empty then put the rect of someGroup into groupRect
   
   -- put rect_GetInner (groupRect, someGroup) into innerRect
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

function rect_GetInner groupRect, someGroup
   put the inner_Rect [groupRect] of someGroup into innerRect
   return innerRect
end rect_GetInner


--> Scale
-
getprop scaled_Height [newW]
   put the rect of the target into originalRect
   put scale_Height (originalRect, newW) into scaledHeight
   return newW
end scaled_Height

function scale_Height originalRect, newW
   rect_ExtractDimensions originalRect, originalW , originalH
   put newW / originalW into sFactor
   put round (originalH * sFactor) into newH
   return newH
end scale_Height


--> Angle
-
command angle_DegreesToRadians @someDegree
   put pi * someDegree / 180 into someRadians
   put someRadians into someDegree
end angle_DegreesToRadians

command angle_RadiansToDegrees @someRadians
   put 180 * someRadians / pi into someDegrees
   put someDegrees into someRadians
end angle_RadiansToDegrees


--> Margins
-
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


--> Geometry | Card and stack
-
command card_SpaceControls someRect, viewSpacer
   if someRect is empty then put the the rect of me into someRect
   lock screen 
   
   if viewSpacer is empty then put 4 into viewSpacer
   put rect_SubtractMargin (viewSpacer, someRect) into innerRect
   
   put item 1 of innerRect into innerLeft
   put item 2 of innerRect into lastTop
   put item 3 of innerRect into innerRight
   put item 4 of innerRect into innerBottom
   
   put 0 into rowHeight
   put innerLeft into lastLeft
   put item 3 of innerRect - item 1 of innerRect into innerWidth
   put the top_Controls of this card into topControls
   repeat for each line topControl in topControls      
      put the formatted_Width of topControl into fWidth
      if fWidth is empty then put the formattedWidth of topControl into fWidth
      if fWidth is empty then put the width of topControl into fWidth
      
      put the formattedHeight of topControl into fHeight
      if fHeight is empty then put the formatted_Height of topControl into fHeight
      if fHeight is empty then put the height of topControl into fHeight
      
      put lastLeft + fWidth into imageRight
      
      if imageRight > innerRight then
         -- lets move it down a row
         add rowHeight + viewSpacer to lastTop
         put 0 into rowHeight
         put innerLeft into lastLeft
         put lastLeft + fWidth into imageRight
      end if
      
      put lastLeft,lastTop into cRect
      put imageRight into item 3 of cRect
      put lastTop + fHeight into lastBottom
      put lastBottom into item 4 of cRect
      put rect_AddMargin (4, cRect) into cRect
      
      set the rect of topControl to cRect
      
      put max (rowHeight, fHeight) into rowHeight
      add fWidth + viewSpacer to lastLeft
   end repeat
   unlock screen
end card_SpaceControls

function stack_GetDimensions someRect, someWidth, someHeight, pMargin, pDontCentre, pDontLimit
   put max (someWidth, 100) into someWidth
   put max (someHeight, 100) into someHeight
   
   if pMargin is not empty then rect_SubtractMargins someRect, pMargin
   rect_SetWidth someRect, someWidth, pDontCentre
   rect_SetHeight someRect, someHeight, pDontCentre
   
   if pDontLimit is not true then
      put rect_GetCentre (someRect) into gLoc
      put loc_WithinWhichScreenRect (gLoc) into sRect
      put rect_SubtractMargin (50, sRect) into outsideRect
      -- rect_Normalize someRect, outsideRect
      rect_ShiftWithin someRect, outsideRect
   end if
   
   return someRect
end stack_GetDimensions

command stack_SetDimensions stackObject, someWidth, someHeight, pMargin, pDontCentre, pDontLimit
   put max (someWidth, 100) into someWidth
   put max (someHeight, 100) into someHeight
   
   put the rect of stackObject into someRect
   if pMargin is not empty then rect_SubtractMargins someRect, pMargin
   rect_SetWidth someRect, someWidth, pDontCentre
   rect_SetHeight someRect, someHeight, pDontCentre
   
   if pDontLimit is not true then
      put rect_GetCentre (someRect) into gLoc
      put loc_WithinWhichScreenRect (gLoc) into sRect
      put rect_SubtractMargin (50, sRect) into outsideRect
      rect_Normalize someRect, outsideRect
   end if
   
   set the rect of stackObject to someRect
   return someRect
end stack_SetDimensions


--> Rect | Scale | Fit
-
function rect_FitToFill originalW, originalH, targetRect
    rect_ExtractDimensions targetRect, newW, newH
     
    put newW / originalW into xScaleFactor
    put newH / originalH into yScaleFactor
    
    put max(xScaleFactor, yScaleFactor) into sFactor
    put round(originalW * sFactor) into newW
    put round(originalH * sFactor) into newH
    put rect_GetCentre(targetRect) into targetLoc
    put rect_LocWidthHeight(targetLoc, newW, newH) into newRect
     
    return newRect
end rect_FitToFill

function rect_FitToHeight originalW, originalH, targetRect
    rect_ExtractDimensions targetRect, someW, newH
    
    put newH / originalH into sFactor
    put round (originalW * sFactor) into newW
    put rect_GetCentre (targetRect) into targetLoc
    put rect_LocWidthHeight (targetLoc, newW, newH) into newRect
    return newRect
end rect_FitToHeight

function rect_FitToWidth originalW, originalH, targetRect
    rect_ExtractDimensions targetRect, newW, someH
    put newW / originalW into sFactor
    put round (originalH * sFactor) into newH
    
    put rect_GetCentre (targetRect) into targetLoc
    put rect_LocWidthHeight (targetLoc, newW, newH) into newRect
    return newRect
end rect_FitToWidth

function rect_ScaleToFitInside originalRect, targetRect
    rect_ExtractDimensions originalRect, originalW, originalH
    put rect_FitInside (originalW, originalH, targetRect) into newRect
    return newRect
end rect_ScaleToFitInside

function rect_FitInside originalW, originalH, targetRect
    if originalW > 0 and originalH > 0 then
        rect_ExtractDimensions targetRect, newW, newH
         
        put newW / originalW into xScaleFactor
        put newH / originalH into yScaleFactor
         
        put min(xScaleFactor, yScaleFactor) into sFactor
        put round(originalW * sFactor) into newW
        put round(originalH * sFactor) into newH
        put rect_GetCentre(targetRect) into targetLoc
        put rect_LocWidthHeight(targetLoc, newW, newH) into newRect
         
        return newRect
    else
        return targetRect
    end if
end rect_FitInside

function rect_GetFitInside targetRect, originalW, originalH
    put item 3 of targetRect - item 1 of targetRect into maxW
    put item 4 of targetRect - item 2 of targetRect into maxH
     
    put maxW / originalW into x_ScaleFactor
    if maxH is empty then
        put round(x_ScaleFactor * originalH) into newH
        put round(x_ScaleFactor * originalW) into newW
    else
        put maxH / originalH into y_ScaleFactor
         
        -- choose the biggest
        if y_ScaleFactor > x_ScaleFactor then
            put y_ScaleFactor into sFactor
        else
            put x_ScaleFactor into sFactor
        end if
         
        put round(sFactor * originalH) into newH
        put round(sFactor * originalW) into newW
         
        if newH > maxH then
            put round(y_ScaleFactor * originalH) into newH
            put round(y_ScaleFactor * originalW) into newW
        else if newW > maxW then
            put round(x_ScaleFactor * originalH) into newH
            put round(x_ScaleFactor * originalW) into newW
        end if
    end if
     
    put "0,0" into testRect
    put newW into item 3 of testRect
    put newH into item 4 of testRect
    
    put rect_GetCentre (targetRect) into targetloc
    put rect_SetCentre (testRect, targetloc) into scaledRect
    return scaledRect
end rect_GetFitInside

command rect_FitAndSetTopLeft @someRect, originalW, originalH
   if not (originalW > 0 and originalH > 0) then return false
   put rect_GetFitAndSetTopLeft (originalW, originalH, someRect) into someRect
   return true
end rect_FitAndSetTopLeft

function rect_GetFitAndSetTopLeft originalW, originalH, someRect
   if not (originalW > 0 and originalH > 0) then return someRect
   
   rect_ExtractDimensions someRect, newW, newH
   put newW / originalW into xScaleFactor
   put newH / originalH into yScaleFactor
   
   put min(xScaleFactor, yScaleFactor) into sFactor
   put round(originalW * sFactor) into newW
   put round(originalH * sFactor) into newH
   
   put rect_FromTopLeft (someRect, newW, newH) into newRect
   return newRect
end rect_GetFitAndSetTopLeft

command rect_ShiftWithin @someRect, outsideRect
   -- first let us check if it will fit at all within the rect
   put item 3 of someRect - item 1 of someRect into someWidth
   put item 3 of outsideRect - item 1 of outsideRect into outsideWidth
   if someWidth > outsideWidth then return empty -- it is too wide to fit
   
   put item 4 of someRect - item 2 of someRect into someHeight
   put item 4 of outsideRect - item 2 of outsideRect into outsideHeight
   if someHeight > outsideHeight then return empty -- it is too high to fit
   
   put item 1 of someRect into someLeft
   put item 1 of outsideRect into outsideLeft
   put item 3  of someRect into someRight
   put item 3 of outsideRect into outsideRight
   
   if someLeft < outsideLeft then
      -- it is too far left shift it right
      put outsideLeft - someLeft into shiftLeft
      add shiftLeft to item 1 of someRect
      add shiftLeft to item 3 of someRect
   else if someRight > outsideRight then
      -- it is too far right shift it left
      put someRight - outsideRight into shiftRight
      subtract shiftRight from item 1 of someRect
      subtract shiftRight from item 3 of someRect
   end if
   
   put item 2 of someRect into someTop
   put item 2 of outsideRect into outsideTop
   put item 4  of someRect into someBottom
   put item 4 of outsideRect into outsideBottom
   
   if someTop < outsideTop then
      -- it is too high shift it down
      put outsideTop - someTop into shiftDown
      add shiftDown to item 2 of someRect
      add shiftDown to item 4 of someRect
   else if someBottom > outsideBottom then
      -- it is too low shift it up
      put someBottom - outsideBottom into shiftUp
      subtract shiftUp from item 2 of someRect
      subtract shiftUp from item 4 of someRect
   end if
end rect_ShiftWithin


--> Rect | Boundaries and Limits

command rect_Normalize @someRect, outsideRect
   put max (item 1 of someRect, item 1 of outsideRect) into item 1 of someRect
   put max (item 2 of someRect, item 2 of outsideRect) into item 2 of someRect
   put min (item 3 of someRect, item 3 of outsideRect) into item 3 of someRect
   put min (item 4 of someRect, item 4 of outsideRect) into item 4 of someRect
end rect_Normalize

function rect_Limit someRect, minW, maxW, minH, maxH
    put item 3 of someRect - item 1 of someRect into sWidth
    put number_NormalizeRange(sWidth, maxW, minW) into lWidth
     
    put item 4 of someRect - item 2 of someRect into sHeight
    put number_NormalizeRange(sHeight, maxH, minH) into lHeight
     
    put item 1 of someRect + lWidth into item 3 of someRect
    put item 2 of someRect + lHeight into item 4 of someRect
    return someRect
end rect_Limit

command rect_SetMinimumWidth @someRect, someWidth
    put item 1 of someRect into someLeft
    if item 3 of someRect - someLeft < someWidth then
        put someLeft + someWidth into item 3 of someRect
    end if
end rect_SetMinimumWidth 

function rect_GetRectBoundary rectIndex
    if the number of lines of rectIndex = 1 then
        repeat with paramNum = 1 to the paramcount
            put param(paramNum) into someRect
             
            put item 1 of someRect & "," after rectList_1
            put item 2 of someRect & "," after rectList_2
            put item 3 of someRect & "," after rectList_3
            put item 4 of someRect & "," after rectList_4
        end repeat
    else
        repeat for each line someRect in rectIndex
            put item 1 of someRect & "," after rectList_1
            put item 2 of someRect & "," after rectList_2
            put item 3 of someRect & "," after rectList_3
            put item 4 of someRect & "," after rectList_4
        end repeat
    end if
    delete last char of rectList_1
    delete last char of rectList_2
    delete last char of rectList_3
    delete last char of rectList_4
    
    put min(rectList_1) into item 1 of outsideRect
    put min(rectList_2) into item 2 of outsideRect
    put max(rectList_3) into item 3 of outsideRect
    put max(rectList_4) into item 4 of outsideRect
    return outsideRect
end rect_GetRectBoundary

function rect_GetGroupBoundary objectIndex
    -- was "groupBoundaries"
    repeat for each line someObject in objectIndex
        put the rect of someObject into objectRect
        put item 1 of objectRect & "," after rectList_1
        put item 2 of objectRect & "," after rectList_2
        put item 3 of objectRect & "," after rectList_3
        put item 4 of objectRect & "," after rectList_4
    end repeat
    delete last char of rectList_1
    delete last char of rectList_2
    delete last char of rectList_3
    delete last char of rectList_4
     
    put min(rectList_1) into item 1 of outsideRect
    put min(rectList_2) into item 2 of outsideRect
    put max(rectList_3) into item 3 of outsideRect
    put max(rectList_4) into item 4 of outsideRect
    return outsideRect
end rect_GetGroupBoundary

command rect_SetMaxWidthAndHeight maxW, maxH, originalW, originalH, @newW, @newH
    -- was "rect_SetWidthAndHeight"
    put maxW / originalW into x_ScaleFactor
    if maxH is empty then
        put round(x_ScaleFactor * originalH) into newH
        put round(x_ScaleFactor * originalW) into newW
    else
        put maxH / originalH into y_ScaleFactor
        
        -- choose the biggest and then test
        if y_ScaleFactor > x_ScaleFactor then
            put y_ScaleFactor into sFactor
        else
            put x_ScaleFactor into sFactor
        end if
        put round(sFactor * originalH) into newH
        put round(sFactor * originalW) into newW
         
        if newH > maxH then
            put round(y_ScaleFactor * originalH) into newH
            put round(y_ScaleFactor * originalW) into newW
        else if newW > maxW then
            put round(x_ScaleFactor * originalH) into newH
            put round(x_ScaleFactor * originalW) into newW
        end if
    end if
end rect_SetMaxWidthAndHeight


--> Rect
-
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

command rect_AddMargins @someRect, pMargin
   margin_Normalize pMargin, leftM, topM, rightM, bottomM   
   subtract leftM from item 1 of someRect
   subtract topM from item 2 of someRect
   add rightM to item 3 of someRect
   add bottomM to item 4 of someRect
end rect_AddMargins

function rect_AddMargin someMargin, someRect
   rect_AddMargins someRect, someMargin
   return someRect
end rect_AddMargin

function rect_GetInnerTabMenu tabButton, someMargin
   -- was "menu_TabInnerGroupRect"
   if someMargin is empty then put 16 into someMargin
   put the rect of tabButton into someRect
   put rect_SubtractMargin(someMargin, someRect) into innerRect
   put the textheight of tabButton into someHeight
   add someHeight to item 2 of innerRect
   
   return innerRect
end rect_GetInnerTabMenu


--> Rect
-
function rect_GetMinimumBoundary firstRect, secondRect
   put 0 into maxRectWidth 
   put 0 into maxRectHeight
   
   repeat with paramNum = 1 to the paramcount
      put param(paramNum) into someRect
      
      get (item 3 of someRect - item 1 of someRect)
      if it > maxRectWidth then put it into maxRectWidth
      
      get (item 4 of someRect - item 2 of someRect)
      if it > maxRectHeight then put it into maxRectHeight
   end repeat
   return 0,0,maxRectWidth,maxRectHeight
end rect_GetMinimumBoundary

function rect_GetGlobal localRect, stackName
   -- was "globalRect" or "localToGlobalRect"
   if stackName is not empty then
      put the defaultstack into oDefault
      set the defaultstack to stackName
   end if
   put globalloc(item 1 to 2 of localRect) into globalStackRect
   put globalloc(item 3 to 4 of localRect) into item 3 of globalStackRect
   if stackName is not empty then set the defaultstack to oDefault
   return globalStackRect
end rect_GetGlobal

function rect_GetCentre someRect
   -- does not always return the same as the loc
   -- out by one pixel (rounding error)?
   -- trunc or round?
   put item 1 of someRect into someLeft
   put trunc((item 3 of someRect - someLeft)/2) into halfWidth
   -- put round((item 3 of someRect - someLeft)/2) into halfWidth
   put item 2 of someRect into someTop
   -- put round((item 4 of someRect - someTop)/2) into halfHeight
   put trunc((item 4 of someRect - someTop)/2) into halfHeight
   put someLeft + halfWidth into item 1 of someMiddle
   put someTop + halfHeight into item 2 of someMiddle
   return someMiddle
end rect_GetCentre

function rect_FromTopLeft rectOrTopLeftLoc, newW, newH
   put item 1 to 2 of rectOrTopLeftLoc into rectOrTopLeftLoc
   put rectOrTopLeftLoc into someRect
   
   put item 1 of someRect + newW into item 3 of someRect
   put item 2 of someRect + newH into item 4 of someRect
   return someRect
end rect_FromTopLeft

function rect_Resize someRect, someWidth, someHeight
   -- a quick hack (speed up and simplify!)
   put rect_GetCentre(someRect) into fromLoc
   if someWidth is not empty then put item 1 of someRect + someWidth into item 3 of someRect
   if someHeight is not empty then put item 2 of someRect + someHeight into item 4 of someRect
   put rect_GetCentre(someRect) into toLoc
   put loc_TranslationVector (fromLoc, toLoc, xVector, yVector) into someVector
   put rect_TranslateByVector (someRect, xVector, yVector) into newRect
   return newRect
end rect_Resize

function rect_FromWidthAndHeight someRect, someWidth, someHeight
   if someWidth is not empty then put item 1 of someRect + someWidth into item 3 of someRect
   if someHeight is not empty then put item 2 of someRect + someHeight into item 4 of someRect
   return someRect
end rect_FromWidthAndHeight
    
function rect_LocWidthHeight someLoc, newW, newH
   put round(newW/2) into leftBit
   put newW - leftBit into rightBit
   put item 1 of someLoc into someX
   put someX - leftBit into item 1 of someRect
   put someX + rightBit into item 3 of someRect
   
   put round(newH/2) into upBit
   put newH - upBit into downBit
   put item 2 of someLoc into someY
   put someY - upBit into item 2 of someRect
   put someY + downBit into item 4 of someRect
   
   return someRect
end rect_LocWidthHeight

function rect_SetCentre someRect, toLoc
   put rect_GetCentre(someRect) into fromLoc
   put loc_TranslationVector (fromLoc, toLoc, xVector, yVector) into someVector
   put rect_TranslateByVector(someRect, xVector, yVector) into newRect
   return newRect
end rect_SetCentre

function rect_CentreLeft someRect, newW, newH
   -- quick hack (burn to basics instad of using lots of functions)
   put rect_GetCentre(someRect) into someLoc
   put rect_LocWidthHeight(someLoc, newW, newH) into newRect
   put item 1 of someRect into newLeft
   rect_SetLeft newRect, newLeft
   return newRect
end rect_CentreLeft

function rect_CentreRight someRect, newW, newH
   -- quick hack (burn to basics instad of using lots of functions)
   put rect_GetCentre(someRect) into someLoc
   put rect_LocWidthHeight(someLoc, newW, newH) into newRect
   put item 3 of someRect into newRight
   rect_SetRight newRect, newRight
   return newRect
end rect_CentreRight

command rect_SetWidth @someRect, newWidth, pDontCentre
   if pDontCentre is true then
      put item 1 of someRect + newWidth into item 3 of someRect
   else
      put item 1 of rect_GetCentre(someRect) into centreX
      put round(newWidth/2) into leftWidth
      put newWidth - leftWidth into rightWidth
      put centreX - leftWidth into item 1 of someRect
      put centreX + rightWidth into item 3 of someRect
   end if
end rect_SetWidth

command rect_SetHeight @someRect, newHeight, pDontCentre
   if pDontCentre is true then
      put item 2 of someRect + newHeight into item 4 of someRect
   else
      put item 2 of rect_GetCentre(someRect) into centreY
      put round(newHeight/2) into bottomHeight
      put newHeight - bottomHeight into topHeight
      put centreY - topHeight into item 2 of someRect
      put centreY + bottomHeight into item 4 of someRect
   end if
end rect_SetHeight

command rect_SetLeft @someRect, newLeft
   put newLeft - item 1 of someRect into xVector
   put xVector,0 into pointVector
   rect_AddVector someRect, pointVector
end rect_SetLeft

command rect_SetRight @someRect, newRight
   put newRight - item 3 of someRect into xVector
   put xVector,0 into pointVector
   rect_AddVector someRect, pointVector
end rect_SetRight


--> Rect | Dimensions
-
command rect_ExtractDimensions someRect, @someW, @someH
   put item 3 of someRect - item 1 of someRect into someW
   put item 4 of someRect - item 2 of someRect into someH
end rect_ExtractDimensions

function rect_SetDimensions someRect, someDimension, pMargin, pDontCentre, pDontLimit
   put item 1 of someDimension into someWidth
   rect_SetWidth someRect, someWidth, pDontCentre
   put item 2 of someDimension into someHeight
   rect_SetHeight someRect, someHeight, pDontCentre
   put rect_SubtractMargin (pMargin, someRect) into newRect
   
   if pDontLimit is not true then
      put rect_GetCentre (newRect) into gLoc
      put loc_WithinWhichScreenRect (gLoc) into sRect
      put rect_SubtractMargin (40, sRect) into outsideRect
      rect_Normalize newRect, outsideRect
   end if
   return newRect
end rect_SetDimensions

command rect_CentreWidthAndHeight @someRect, someWidth, someHeight, pMargin
   rect_SetWidth someRect, someWidth, false
   rect_SetHeight someRect, someHeight, false
   rect_SubtractMargins someRect, pMargin
end rect_CentreWidthAndHeight


--> Rect | Vectors
-
function rect_Scale someRect, someScale
   put round (item 1 of someRect * someScale) into item 1 of scaledRect
   put round (item 3 of someRect * someScale) into item 3 of scaledRect
   put round (item 2 of someRect * someScale) into item 2 of scaledRect
   put round (item 4 of someRect * someScale) into item 4 of scaledRect
   return scaledRect
end rect_Scale

function rect_ScaleByVector someRect, scaleVector
    -- see also image_Scalevector
    put item 1 of scaleVector into scaleX
    put item 2 of scaleVector into scaleY
    put round (item 1 of someRect * scaleX) into item 1 of scaledRect
    put round (item 3 of someRect * scaleX) into item 3 of scaledRect
    put round (item 2 of someRect * scaleY) into item 2 of scaledRect
    put round (item 4 of someRect * scaleY) into item 4 of scaledRect
    return scaledRect
end rect_ScaleByVector

function rect_ShrinkByVector someRect, scaleVector
    -- see also image_Scalevector
    put item 1 of scaleVector into scaleX
    put item 2 of scaleVector into scaleY
    put round(item 1 of someRect / scaleX) into item 1 of scaledRect
    put round(item 3 of someRect / scaleX) into item 3 of scaledRect
    put round(item 2 of someRect / scaleY) into item 2 of scaledRect
    put round(item 4 of someRect / scaleY) into item 4 of scaledRect
    return scaledRect
end rect_ShrinkByVector

function rect_ScaleByVectors someRect, scaleX, scaleY
    -- was "scaleRect"
    put scaleX,scaleY into scaleVector
    return rect_ScaleByVector(someRect, scaleVector)
end rect_ScaleByVectors

function rect_TranslateByVector someRect, xVector, yVector
    put xVector,yVector into pointVector
    rect_AddVector someRect, pointVector
    return someRect
end rect_TranslateByVector

command rect_AddVector @someRect, pointVector
   -- was "rect_Translate"
   put item 1 of pointVector into xVector
   put item 2 of pointVector into yVector
   rect_Translate someRect, xVector, yVector
end rect_AddVector

on rect_SubtractVector @someRect, pointVector
   put -1 * (item 1 of pointVector) into xVector
   put  -1 * (item 2 of pointVector) into yVector
   rect_Translate someRect, xVector, yVector
end rect_SubtractVector

command rect_Translate @someRect, xVector, yVector
   add xVector to item 1 of someRect
   add xVector to item 3 of someRect
   
   add yVector to item 2 of someRect
   add yVector to item 4 of someRect
end rect_Translate



--> Rect | Scale
-
function rect_RelativeRect someRect, someCentre
    put item 1 of someCentre into xCentre
    put item 2 of someCentre into yCentre
    
    subtract xCentre from item 1 of someRect
    subtract xCentre from item 3 of someRect
    subtract yCentre from item 2 of someRect
    subtract yCentre from item 4 of someRect
    
    return someRect
end rect_RelativeRect

function rect_ScaleFromCentre someRect, someMagnification, scaleCentre
    if scaleCentre is empty then put 0,0 into scaleCentre
    
    put item 1 of scaleCentre into xVector
    put item 2 of scaleCentre into yVector
    put rect_TranslateByVector(someRect, -xVector, -yVector) into translatedRect
    put rect_ScaleByVectors(translatedRect, someMagnification, someMagnification) into tScaleRect
    put rect_TranslateByVector(tScaleRect, xVector, yVector) into finalRect
    return finalRect
end rect_ScaleFromCentre

on rect_ScaleGroup someGroup, sFactor, scaleCentre, scaleGroup
    lock screen
    put the rect of someGroup into groupRect
     
    put the object_Controls of someGroup into groupElements
    repeat for each line groupElement in groupElements
        get the name of groupElement
        put the rect of groupElement into elementRect
        put rect_ScaleFromCentre(elementRect, sFactor, scaleCentre) into newElementRect
        set the rect of groupElement to newElementRect
    end repeat
    
    if the locklocation of someGroup is true and scaleGroup is not false then 
        put rect_ScaleFromCentre(groupRect, sFactor, scaleCentre) into newGroupRect
        -- rect_CreateTestButton newGroupRect
        set the rect of someGroup to newGroupRect
    end if
    unlock screen
end rect_ScaleGroup

on rect_SetScaleVectors someRect, targetRect, @scaleX, @scaleY
    -- work out the scale factor
    -- was "set_scaleVector"
    put item 3 of someRect - item 1 of someRect into someWidth
    put item 3 of targetRect - item 1 of targetRect into targetWidth
    put targetWidth/someWidth into scaleX
     
    put item 4 of someRect - item 2 of someRect into someHeight
    put item 4 of targetRect - item 2 of targetRect into targetHeight
    put targetHeight/someHeight into scaleY
     
    return scaleX,scaleY
end rect_SetScaleVectors


--> Loc
-
function loc_DistanceBetween startLocation, endLocation
   get ((item 1 of endLocation - item 1 of startLocation)^2 + (item 2 of endLocation - item 2 of startLocation)^2) ^ 0.5
   return it
end loc_DistanceBetween

function loc_GetTranslation fromPoint, toPoint, @x, @y
   put item 1 of toPoint - item 1 of fromPoint into x
   put item 2 of toPoint - item 2 of fromPoint into y
   return x,y
end loc_GetTranslation

function loc_TranslateByVector someLoc, xVector, yVector
   -- was translateLoc
   add xVector to item 1 of someLoc
   add yVector to item 2 of someLoc
   return someLoc
end loc_TranslateByVector

function loc_TranslationVector fromPoint, toPoint, @xVector, @yVector
   loc_SetTranslationVector fromPoint, toPoint, xVector, yVector
   put xVector into tVector[1,1]
   put yVector into tVector[1,2]
   return tVector
end loc_TranslationVector

on loc_GetPercentagePoints someLoc, someRect, @percentageX, @percentageY
   put item 1 of someLoc - item 1 of someRect into relativeX
   put item 2 of someLoc- item 2 of someRect into relativeY
   rect_ExtractDimensions someRect, someW, someH
   put relativeX/someW into percentageX
   put relativeY/someH into percentageY
end loc_GetPercentagePoints

on loc_SetTranslationVector fromPoint, toPoint, @xVector, @yVector
   put item 1 of toPoint - item 1 of fromPoint into xVector
   put item 2 of toPoint - item 2 of fromPoint into yVector
end loc_SetTranslationVector

function loc_WithinWhichScreenRect gLoc
   repeat for each line sRect in the working screenrects
      if gLoc is within sRect then
         return sRect
      end if
   end repeat
   return empty
end loc_WithinWhichScreenRect

function loc_Normalise someLoc, someRect
    put item 1 of someLoc into someX
    if someX <= item 1 of someRect then
        put item 1 of someRect into item 1 of someLoc
    else if someX >= item 3 of someRect then
        put item 3 of someRect into item 1 of someLoc
    end if
    
    put item 2 of someLoc into someY
    if someY <= item 2 of someRect then
        put item 2 of someRect into item 2 of someLoc
    else if someY >= item 4 of someRect then
        put item 4 of someRect into item 2 of someLoc
    end if
    return someLoc
end loc_Normalise


--> Handlers
-
function number_NormalizeRange someValue, maxValue, minValue
   -- was "number_Normalise"
    if someValue < minValue then
        return minValue
    else if someValue > maxValue then
        return maxValue
    else
        return someValue
    end if
end number_NormalizeRange
