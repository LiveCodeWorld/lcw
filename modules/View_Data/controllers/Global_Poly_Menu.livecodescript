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


--> Global | Poly | Menu
-
on menu_RestoreDataLayout dView, sName
   put the module_Array [sName] of dView into pLayoutData
   --
   set the poly_Layout of dView to pLayoutData
end menu_RestoreDataLayout

on menu_SaveDataLayout dView
   put the title_Text of dView into sTitle
   put lcw_Ask ("Name for data layout?", sTitle, dView) into sName
   
   put the poly_Layout of dView into pData
   set the module_Array [sName] of dView to pData
   --
   stack_Save dView
end menu_SaveDataLayout

getprop restoreDataLayout_Params [dView]
   put the module_Data of dView into mData
   return keys (mData)
end restoreDataLayout_Params

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

