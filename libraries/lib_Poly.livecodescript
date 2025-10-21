script "lib_Poly"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Poly
type: library
version: 0.1


--> Working on
-
command display_PolyData layoutName
   put iconLibrary_GetLayoutArray (layoutName) into layoutData
   -- put poly_GetLayoutData (layoutName) into layoutData
   display_Data layoutData
end display_PolyData

function poly_FetchLayoutData layoutName
   
end poly_FetchLayoutData

getprop poly_LayoutName
   put the poly_View of the target into polyView
   if exists (polyView) is false then return "Error, not  poly_View"
   --
   put the uOPN ["poly_LayoutName"] of polyView into layoutName
   if layoutName is empty then return "Grid"
   return layoutName
end poly_LayoutName

setprop poly_LayoutName layoutName
   put the poly_View of the target into polyView
   if exists (polyView) is false then return "Error, not  poly_View"
   --
   set the uOPN ["poly_LayoutName"] of polyView to layoutName
   -- put iconLibrary_GetLayoutArray (layoutName) into layoutArray
   put poly_GetLayoutData (layoutName) into layoutArray
   set the poly_LayoutData of me to layoutArray
   return layoutArray
end poly_LayoutName

getprop poly_LayoutNames
   return iconLibrary_ListLayouts()
end poly_LayoutNames

function poly_LayoutArray layoutName
   put data_PolyView() into polyView
   put the module_Array [layoutName] of polyView into layoutIndexArray
   return layoutIndexArray
end poly_LayoutArray

function poly_ListLayouts
   put data_PolyView() into polyView
   put the module_Data of polyView into mData
   return keys (mData)
end poly_ListLayouts

function data_PolyView
   put module_GetObject ("View|Data") into dView
   put the poly_View of dView into polyView
   return polyView
end data_PolyView


--> Poly
-
function poly_GetLayoutData layoutName
   put poly_JsonFile (layoutName) into polyFile
   put text_Get (polyFile) into layoutJson
   put json_ToArray (layoutJson) into layoutData
   if layoutData is not an array then return empty
   return layoutData
end poly_GetLayoutData

command poly_SetLayoutData layoutName, layoutData
   put json_FromArray (layoutData) into layoutJson
   put poly_JsonFile (layoutName) into polyFile
   text_Set polyFile, layoutJson
   return the result
end poly_SetLayoutData

function poly_ListNames
   put poly_ListShortFiles() into polyNames
   filter polyNames with "*.json"
   replace ".json" with empty in polyNames
   return polyNames
end poly_ListNames

function poly_ListShortFiles
   put poly_JsonFolder() into polyFolder
   put files (polyFolder) into shortFiles
   return shortFiles
end poly_ListShortFiles

function poly_JsonFile layoutName
   put poly_JsonFolder() into polyFolder
   put polyFolder & layoutName & ".json" into polyFile
   return polyFile
end poly_JsonFile

function poly_JsonFolder
   put wikiFolder_ConstructAssets ("livecode.wiki", "polylist-layout") into polyFolder
   folder_CreateNested polyFolder
   return polyFolder
end poly_JsonFolder
