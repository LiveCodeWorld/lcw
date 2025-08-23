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

getprop restoreDataLayout_Params [dView]
   put _StoreData(dView) into storeData
   return keys (storeData)
end restoreDataLayout_Params

private function _StoreData dView
   set the customPropertySet of dView to "data_Store"
   put the customProperties of dView into storeData
   set the customPropertySet of dView to empty
   return storeData
end _StoreData


--> Global | Poly | Menu
-
on menu_RestoreDataLayout dView, sName
   put _StoreData(dView) into storeData
   put storeData [sName] into polyDataLayout
   --
   set the poly_DataLayout of dView to pData
end menu_RestoreDataLayout

on menu_SaveDataLayout dView
   put lcw_Ask ("Name for data layout?", "pDefault", dView) into sName
   
   put the poly_DataLayout of dView into pData
   breakpoint
   set the data_Store [sName] of dView to pData
end menu_SaveDataLayout

private on _
end _

on menu_DisplayPolyData dView
   put the poly_DataContent of dView into pData
   put the name of dView into sTitle
   --
   display_Data pData, sTitle, "the poly_DataContent"
end menu_DisplayPolyData

on menu_DisplayDataLayout dView
   put the poly_DataLayout of dView into pData
   put the name of dView into sTitle
   --
   display_Data pData, sTitle, "the poly_DataLayout"
end menu_DisplayDataLayout

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
   return "Global | Poly | Menu"
end submenu_Dev
