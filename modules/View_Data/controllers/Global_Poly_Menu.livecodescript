script "Global | Poly | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Poly | Menu
type: controller
version: 0.2


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the data_View of tObject into dataView
   if exists (dataView) is false then return empty
   put the poly_View of dataView into polyView
   return polyView
end menu_Target

getprop menu_CheckTarget [polyView]
   return exists (polyView)
end menu_CheckTarget

getprop restoreDataLayout_Param [polyView]
   return the poly_LayoutName of polyView
end restoreDataLayout_Param

getprop restoreDataLayout_Params [polyView]
   put the module_Data of polyView into mData
   return keys (mData)
end restoreDataLayout_Params

getprop svgDataLayout_Param [polyView]
   return the poly_LayoutName of polyView
end svgDataLayout_Param

getprop svgDataLayout_Params [polyView]
   return iconLibrary_ListLayouts()
end svgDataLayout_Params

getprop storedDataLayout_Params [polyView]
   return poly_ListNames()
end storedDataLayout_Params


--> Global | Poly | Menu
-
on menu_RestorePolyLayout polyView, layoutName
   put poly_GetLayoutData (polyName) into layoutData
   set the poly_LayoutData [layoutName] of polyView to layoutData
end menu_RestorePolyLayout

on menu_SavePolyLayout polyView   
   put the poly_LayoutName of polyView into layoutName
   put lcw_Ask ("Name for data layout?", layoutName, polyView) into layoutName
   
   put the poly_LayoutData of polyView into layoutData
   poly_SetLayoutData layoutName, layoutData
   /*
   put the poly_Layout [layoutName] of polyView into pData
   set the module_Array [layoutName] of dView to pData
   stack_Save dView
   */
end menu_SavePolyLayout

private on _
end _

on menu_DisplayPolyData polyView
   put the poly_Content of polyView into pData
   put the name of polyView into sTitle
   --
   display_Data pData, sTitle, "the poly_Content"
end menu_DisplayPolyData

on menu_DisplayDataLayout polyView
   put the poly_Layout of polyView into pData
   put the name of polyView into sTitle
   --
   display_Data pData, sTitle, "the poly_Layout"
end menu_DisplayDataLayout

on menu_ExportDataLayout polyView
   put the poly_Layout of polyView into pData
   --
   set the module_Array [sName] of dView to pData
end menu_ExportDataLayout

on menu_RevealModelFile polyView
   put the data_View of polyView into dView
   put the module_Object of dView into mObject
   --
   put the model_DataFile ["poly_Layout"] of mObject
end menu_RevealModelFile

private on __
end __

getprop disabled_EditBehavior [polyView]
   return exists (stack "behavior_ViewDataPoly") is false
end disabled_EditBehavior

getprop checked_EditBehavior [polyView] 
   put the behavior of polyView into bObject
   if exists (bObject) is false then return false
   return the name of bObject = the name of stack "behavior_ViewDataPoly" 
end checked_EditBehavior

on menu_EditBehavior polyView
   put the behavior of polyView into bObject
   if exists (bObject) then
      edit the script of bObject
   else if exists (stack "behavior_ViewDataPoly") then
      put the name of stack "behavior_ViewDataPoly" into bObject
      set the behavior of polyView to bObject
   else
      breakpoint
   end if
end menu_EditBehavior

on submenu_Dev
   return "Global | Poly | Dev | Menu"
end submenu_Dev

on menu_StoredDataLayout polyView, layoutName
   put poly_GetLayoutData (layoutName) into layoutData
   display_Data layoutData
end menu_StoredDataLayout

on menu_SvgDataLayout polyView, layoutName
   put iconLibrary_GetLayoutArray (layoutName) into layoutData
   --
   poly_SetLayoutData layoutName, layoutData
   -- set the poly_Layout [layoutName] of polyView to layoutData
end menu_SvgDataLayout

on menu_RestoreDataLayout polyView, sName
   put the module_Array [sName] of polyView into pLayoutData
   --
   set the poly_Layout [sName] of polyView to pLayoutData
end menu_RestoreDataLayout

on menu_RestoreDataLayout polyView, sName
   put the module_Array [sName] of polyView into pLayoutData
   --
   set the poly_Layout [sName] of polyView to pLayoutData
end menu_RestoreDataLayout
