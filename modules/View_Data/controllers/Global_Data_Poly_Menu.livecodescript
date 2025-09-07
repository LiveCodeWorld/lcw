script "Global | Data | Poly | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Data | Poly | Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray

--> Events
-
on poly_DoubleClick sView, iData
   menu_DisplayIcon sView
end poly_DoubleClick


--> Menu | Props
-
getprop menu_Target [tObject]
   put the data_View of tObject into dView
   return dView
end menu_Target

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget

private function _ItemArray dView
   put the poly_View of dView into polyView
   --
   -- put the hilitedItemIndex of polyView into iNum
   put the hilitedItemData of polyView into iData
   return iData
end _ItemArray


--> Global | Data | Poly | Menu
-
on menu_DraftWikiPage dView
   put the poly_View of dView into polyView
   --
   put _ItemArray(dView) into iArray
   put iArray ["svgPath"] into svgPath
   put iArray ["name"] into iName
   --
   put pageArray_Construct (iName, "Here is an svg:") into pageArray
   --
   draft_PageArray "svg.livecode.wiki", pageArray
end menu_DraftWikiPage

private on _
end _

on menu_DisplaySvgWiki
   display_Wiki "svg.livecode.wiki"
end menu_DisplaySvgWiki

on menu_DisplayIcon sView
   -- put the footer_View of sView into footerView
   put the poly_View of sView into polyView
   --
   -- put the hilitedItemData of polyView into itemData
   put the dataContent of polyView into iData
   put the hilitedItemIndex of polyView into itemIndex
   repeat for each item iNum in itemIndex
      put iData [iNum] into iArray
      put iArray ["svgpath"] into svgpath
      put iArray ["name"] into iName
      --
      display_SvgPathWidget svgPath, iName
   end repeat
   -- display_ObjectProperties footerView
end menu_DisplayIcon

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Data | Poly | Menu")
end submenu_Dev
