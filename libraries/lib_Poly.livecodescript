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


--> Poly
-
function poly_FetchLayoutData polyName

end poly_FetchLayoutData

function poly_GetLayoutData polyName
   put poly_JsonFile (polyName) into polyFile
   put text_Get (polyFile) into layoutJson
   put json_ToArray (layoutJson) into layoutData
   return layoutData
end poly_GetLayoutData

command poly_SetLayoutData polyName, layoutData
   put json_FromArray (layoutData) into layoutJson
   put poly_JsonFile (polyName) into polyFile
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

function poly_JsonFile polyName
   put poly_JsonFolder() into polyFolder
   put polyFolder & polyName & ".json" into polyFile
   return polyFile
end poly_JsonFile

function poly_JsonFolder
   put wikiFolder_ConstructAssets ("livecode.wiki", "polylist-layout") into polyFolder
   folder_CreateNested polyFolder
   return polyFolder
end poly_JsonFolder

   
   
   --> Deps
   -
