script "behavior_ViewDataPoly"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewDataPoly
type: behavior
version: 0.1


--> Working on
-

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

getprop poly_Name
   put the uOPN ["poly_Name"] of me into pName
   return pName
end poly_Name

setprop poly_Name pName
   set the uOPN ["poly_Name"] of me to pName
end poly_Name

getprop poly_DataLayout
   return the dataLayout of _PolyWidget()
end poly_DataLayout

setprop poly_DataLayout [pName] layoutData
   lock screen
   set the dataLayout of _PolyWidget() to layoutData
   set the uOPN ["poly_Name"] of me to pName
   unlock screen
end poly_DataLayout

getprop poly_DataContent
   return the dataContent of _PolyWidget()
end poly_DataContent

setprop poly_DataContent [sTitle] cData
   lock screen
   set the dataContent of _PolyWidget() to cData
   if sTitle is not empty then
      set the title_Text of me to sTitle
   end if
   unlock screen
end poly_DataContent


--> Objects
-
private function _PolyWidget
   return the long id of me
end _PolyWidget

