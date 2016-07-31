script "behavior_ViewImageWithText"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewImageWithText
type: behavior
version: 0.6

/*

*/


--> Events
-
on dragEnter
   put the dragData ["files"] into someFiles
   put line 1 of someFiles into someFile
   if there is a file someFile then
      -- could check that it is an image
      -- opn_Notify someFile
      set the dragAction to "link"
   end if
end dragEnter

on dragDrop
   put the dragData ["files"] into someFiles
   put line 1 of someFiles into someFile
   put file_GetType (someFile) into fType
   switch fType
      case "image"
         set the image_File of me to someFile
         break
      case "text"
         put url ("file:" & someFile) into someText
         set the image_Description of me to someText
         break
      default
         opn_Notify fType
   end switch
end dragDrop

on resizeControl
   put the rect of me into groupRect
   LayoutControl groupRect
end resizeControl

on LayoutControl pRect
   if pRect is empty then put the rect of me into pRect
   
   lock screen
   -- set the height to the formatted_Height
   -- text flow happending during resizing will not be taken into account
   -- would need to be done at the end or recursively or ???
   put the formatted_Height of me into fHeight
   put item 2 of pRect + fHeight into item 4 of pRect
   
   put the margins of me into someMargin
   margin_Normalize someMargin, lMargin, tMargin, rMargin, bMargin
   put pRect into innerRect 
   add lMargin to item 1 of innerRect
   add tMargin to item 2 of innerRect
   subtract rMargin from item 3 of innerRect
   
   subtract bMargin from item 4 of innerRect
   
   put the image_Width of me into imageWidth
   put the image_Height of me into imageHeight
   put the view_Spacing of me into viewSpacing
   if viewSpacing is empty then put 4 into viewSpacing
   
   if the image_Position of me = "left" then
      put innerRect into imageRect
      put item 1 of innerRect into imageLeft
      put imageLeft + imageWidth into item 3 of imageRect
      
      put innerRect into fieldRect
      put item 3 of imageRect + viewSpacing into item 1 of fieldRect
   else -- if the image_Position of me = "right" then
      put innerRect into imageRect
      put item 3 of innerRect into imageRight
      put imageRight - imageWidth into item 1 of imageRect
      
      put innerRect into fieldRect
      put item 1 of imageRect - viewSpacing into item 3 of fieldRect
   end if
   put item 2 of innerRect into imageTop
   put imageTop + imageHeight into item 4 of imageRect
   
   -- set the rects
   -- set the view_Rect of image_View() to imageRect
   set the rect of image_View() to imageRect
   -- dispatch "LayoutControl" to image_View() with imageRect
   set the rect of fieldObject() to fieldRect
   -- set the rect of me to pRect
   
   unlock screen
end LayoutControl


--> Controls
-
getprop imageWithText_View
    return the long id of me
end imageWithText_View

getprop view_Object
    return the long id of me
end view_Object

getprop image_View
   return image_View()
end image_View

getprop image_Object
    return the long id of image 1 of me
end image_Object

private function image_View
   return the long id of control "Image View" of me
end image_View

private function image_Object
    return the long id of image 1 of me
end image_Object

private function fieldObject
    return the long id of fld 1 of me
end fieldObject


--> Field
-
getprop field_IsLocked
   return the locktext of fieldObject()
end field_IsLocked

setprop field_IsLocked someBoolean
   set the locktext of fieldObject() to someBoolean
end field_IsLocked


--> Image
-
getprop image_ID
   put image_Object() into imageObject
   put the short ID of imageObject into imageID
   return imageID
end image_ID

getprop image_Contents
   put image_Object() into imageObject
   put the short id of imageObject into imageObjectID
   put image id imageObjectID of me into someImage
   return someImage
end image_Contents

setprop image_Contents someImage
   put image_Object() into imageObject
   put the short id of imageObject into imageObjectID
   put someImage into image id imageObjectID of me
end image_Contents

getprop image_File
   put the filename of image_Object() into someFile
   return someFile
end image_File

setprop image_File someFile
   put image_Object() into imageObject
   lock screen
   set the filename of imageObject to empty
   set the filename of imageObject to someFile
   Layoutcontrol
   unlock screen
end image_File

getprop image_Description [textEncoding]
   return the htmltext of fieldObject()
end image_Description

setprop image_Description [textEncoding] someDescription
   set the htmltext of fieldObject() to someDescription
end image_Description


--> Geometry
-
getprop formatted_Height
   put the formattedHeight of fieldObject() into fTextHeight
   put the image_Height of me into iHeight
   put max(iHeight, fTextHeight) into fHeight
   
   -- tweak
   -- add 4 to fHeight
   
   put the margins of me into someMargin
   margin_Normalize someMargin, lMargin, tMargin, rMargin, bMargin
   add tMargin to fHeight
   add bMargin to fHeight
   
   return fHeight
end formatted_Height

setprop view_Rect someRect
   LayoutControl someRect
end view_Rect

setprop view_Spacing viewSpacing
   set the uOPN ["view_Spacing"] of me to viewSpacing
end view_Spacing

getprop view_Spacing
   put the uOPN ["view_Spacing"] of me into viewSpacing
   if viewSpacing is empty then
      return 4
   else
      return viewSpacing
   end if
end view_Spacing

getprop right_Margin
   put the margins of me into someMargin
   margin_Normalize someMargin, lMargin, tMargin, rMargin, bMargin
   return rMargin
end right_Margin

setprop right_Margin rMargin
   put the margins of me into someMargin
   margin_Normalize someMargin, lMargin, tMargin, oldRightMargin, bMargin
   put lMargin,tMargin,rMargin,bMargin into newMargins
   set the margins of me to newMargins
end right_Margin

getprop left_Margin
   put the margins of me into someMargin
   margin_Normalize someMargin, lMargin, tMargin, rMargin, bMargin
   return lMargin
end left_Margin

setprop left_Margin lMargin
   put the margins of me into someMargin
   margin_Normalize someMargin, oldLeftMargin, tMargin, rMargin, bMargin
   put lMargin,tMargin,rMargin,bMargin into newMargins
   set the margins of me to newMargins
end left_Margin

getprop top_Margin
   put the margins of me into someMargin
   margin_Normalize someMargin, lMargin, tMargin, rMargin, bMargin
   return tMargin
end top_Margin

setprop top_Margin tMargin
   put the margins of me into someMargin
   margin_Normalize someMargin, lMargin, oldTopMargin, rMargin, bMargin
   put lMargin,tMargin,rMargin,bMargin into newMargins
   set the margins of me to newMargins
end top_Margin

getprop bottom_Margin
   put the margins of me into someMargin
   margin_Normalize someMargin, lMargin, tMargin, rMargin, bMargin
   return bMargin
end bottom_Margin

setprop bottom_Margin bMargin
   put the margins of me into someMargin
   margin_Normalize someMargin, lMargin, tMargin, rMargin, oldBottomMargin
   put lMargin,tMargin,rMargin,bMargin into newMargins
   set the margins of me to newMargins
end bottom_Margin

getprop image_Height
   put the uOPN ["image_Height"] of me into imageHeight
   if imageHeight is empty then
      return 30
   else
      return imageHeight
   end if
end image_Height

setprop image_Height imageHeight
   set the uOPN ["image_Height"] of me to imageHeight
   set the view_Rect of me to the rect of me
end image_Height

getprop image_Width
   put the uOPN ["image_Width"] of me into imageWidth
   if imageWidth is empty then
      return 40
   else
      return imageWidth
   end if
end image_Width

setprop image_Width imageWidth
   set the uOPN ["image_Width"] of me to imageWidth
   set the view_Rect of me to the rect of me
end image_Width

getprop image_Position
   put the view_DisplayValue ["image_Position"] of me into imagePosition
   if imagePosition is empty then return "right"
   return imagePosition
end image_Position

setprop image_Position imagePosition
    set the view_DisplayValue ["image_Position"] of me to imagePosition
    resizeControl
end image_Position

getprop image_Positions
   return "left,right"
end image_Positions

getprop image_ViewName
   put the image_View of me into imageView
   put the view_Name of imageView into vName
   set the itemdelimiter to "|"
   delete item 1 of vName
   return vName
end image_ViewName

setprop image_ViewName vName
   put the image_View of me into imageView
   set the view_Swap of imageView to vName
   return the result
end image_ViewName

getprop image_ViewNames
   return "Image|Fit Inside,Image|OPN Image,Rev|Image"
end image_ViewNames
