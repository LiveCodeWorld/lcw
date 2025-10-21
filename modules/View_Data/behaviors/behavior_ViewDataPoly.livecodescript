script "behavior_ViewDataPoly"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewDataPoly
type: behavior
version: 0.2

--> Variables
-
local LocalArray


--> Working on
-
setprop poly_Rect pRect
   lock screen
   set the rect of me to pRect
   _SetColumns pRect
   unlock screen
end poly_Rect

private command _SetColumns pRect
   if the poly_LayoutName of me is "Grid" then
      put item 3 of pRect - item 1 of pRect into sWidth
      put round (sWidth / 60) - 1 into cNum
      set the numberOfColumns of me to cNum
   end if
end _SetColumns


--> Events
-
on mouseDown
   -- before a click
   switch LocalArray ["subItemName"]
      case "Action"
         put "Global | Data | Menu" into mTitle
         -- put _MenuButton() into mButton
         -- mArray_MouseDown mTitle, mButton
         mArray_PopUp mTitle
         break
      default
         
   end switch
end mouseDown

on itemClick iNum, pMouseButton
   put the data_View of me into dView
   put "Global | Data | Poly | Menu" into mTitle
   if exists (stack mTitle) is false then
      breakpoint
      exit to top
   end if
   
   -- get the hilitedItemData of the target
   set the itemPointer of me to iNum
   put the itemContent of the target into iData
   put iData ["svgPath"] into svgPath
   put iData ["name"] into iName
   
   if the controlKey is "Down" then
      put the menu_Button of me into mButton
      put the long id of me into tObject
      mArray_PopUp mTitle, mButton, tObject, dView
   else
      put the milliseconds into clickMilliseconds
      put LocalArray ["clickMilliseconds"] into lastMilliseconds
      get clickMilliseconds - lastMilliseconds
      if it < the doubleClickInterval then
         put the name of stack mTitle into mController
         -- put the title_Controller of me into mController
         --
         dispatch "poly_DoubleClick" to mController with dView,iData
         switch it
            case "unhandled"
               edit the script of mController
               break
         end switch
      end if
      --
      put clickMilliseconds into LocalArray ["clickMilliseconds"]
   end if
   --
   -- footer_Refresh
end itemClick

on subItemClick iNum, pSubItemName
   local tCurrentVal
   --
   switch pSubItemName
      case "Action"
         break
      case "svgPath"
         set the itemPointer of me to iNum
         set the subItemPointer of me to pSubItemName
         put the subItemContent of me into svgPath
         
         put _ItemContent (iNum, "name") into iName
         if the shiftKey is "Down" then
            display_SvgPathWidget svgPath, iName
         end if
         break
      default
         set the itemPointer of me to iNum
         set the subItemPointer of me to pSubItemName
         -- put the subItemContent of me -- into tCurrentVal
         -- set the subItemContent of me to "#255,255,255#heart empty"
   end switch
end subItemClick

on subItemMouseEnter iNum, subItemName
   put subItemName into LocalArray ["subItemName"]   
   put _ItemContent (iNum, "name") into iName
   --
   set the title_Text of me to iName
end subItemMouseEnter

on subItemMouseLeave iNum, iName
   delete variable LocalArray ["subItemName"]
   --
   put the poly_IconFamily of me into familyName
   set the title_Text of me to familyName
end subItemMouseLeave


--> Private
-
private function _ItemContent iNum, sKey
   set the itemPointer of me to iNum
   put the itemContent of me into iData
   put iData [sKey] into sValue
   return sValue
end _ItemContent


--> Poly
-
getprop poly_Height
   return the dataHeight of _PolyWidget()
end poly_Height

setprop poly_Height dHeight
   if dHeight is not a number then
      put 0 into dHeight
   end if
   
   add the uOPN ["header_Height"] of me to dHeight
   add the uOPN ["footer_Height"] of me to dHeight
   --
   put the rect of me into newRect
   put item 2 of newRect + dHeight into item 4 of newRect
   --
   LayoutControl newRect
end poly_Height

getprop poly_LayoutData
   put _PolyWidget() into pWidget
   --
   put the numberOfColumns of pWidget into layoutData ["numberOfColumns"]
   put the itemHeight of pWidget into layoutData ["itemHeight"]
   put the columnWidth of pWidget into layoutData ["columnWidth"]
   put the margin of pWidget into layoutData ["margin"]
   put the padding of pWidget into layoutData ["padding"]
   put the showGrid of pWidget into layoutData ["showGrid"]
   put the roundedRadius of pWidget into layoutData ["roundedRadius"]
   put the itemRoundedRadius of pWidget into layoutData ["itemRoundedRadius"]
   put the borderwidth of pWidget into layoutData ["borderwidth"]
   put the enableItemCache of pWidget into layoutData ["enableItemCache"]
   put the enableImageCache of pWidget into layoutData ["enableImageCache"]
   --
   put the dataLayout of pWidget into layoutData ["dataLayout"]
   return layoutData
end poly_LayoutData

setprop poly_LayoutData [pName] layoutData
   put _PolyWidget() into pWidget
   if pName is not empty then
      set the uOPN ["poly_LayoutName"] of pWidget to pName
   end if
   
   lock screen
   --
   get layoutData ["dataLayout"]
   if it is an array then -- lazy check
      set the dataLayout of pWidget to it
      --
      set the numberOfColumns of pWidget to layoutData ["numberOfColumns"]
      set the itemHeight of pWidget to layoutData ["itemHeight"]
      set the columnWidth of pWidget to layoutData ["columnWidth"]
      -- set the Margin of pWidget to layoutData ["margin"]
      set the padding of pWidget to layoutData ["padding"]
      set the showGrid of pWidget to layoutData ["showGrid"]
      set the roundedRadius of pWidget to layoutData ["roundedRadius"]
      set the itemRoundedRadius of pWidget to layoutData ["itemRoundedRadius"]
      set the borderwidth of pWidget to layoutData ["borderwidth"]
      set the enableItemCache of pWidget to layoutData ["enableItemCache"]
      set the enableImageCache of pWidget to layoutData ["enableImageCache"]
      --
      put the rect of me into sRect
      _SetColumns sRect
   end if
   --
   unlock screen
   return layoutData
end poly_LayoutData

getprop poly_Layout
   return the dataLayout of _PolyWidget()
end poly_Layout

setprop poly_Layout [pName] sArray
   lock screen
   set the dataLayout of _PolyWidget() to sArray
   set the uOPN ["poly_LayoutName"] of me to pName
   unlock screen
end poly_Layout

getprop poly_Content
   return the dataContent of _PolyWidget()
end poly_Content

setprop poly_Content [sTitle] cData
   lock screen
   set the dataContent of _PolyWidget() to cData
   if sTitle is not empty then
      set the title_Text of me to sTitle
   end if
   unlock screen
end poly_Content


--> Objects
-
private function _PolyWidget
   return the long id of me
end _PolyWidget

