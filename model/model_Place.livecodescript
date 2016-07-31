script "model_Place"
--> MetaData
-
license: GPLv3
name: model_Place
type: model
version: 0.1

/*
Some old code here.
The idea is that we should make it sersiously easy to create a model for where stacks or assets are on disk.
*/


--> Folder | Stack Places | Model
-
command folder_AddToStackPlaces someFolder
    set the itemdelimiter to "/"
    put item -1 of someFolder into placeName
    folder_SetPlaceFolder placeName, someFolder
end folder_AddToStackPlaces

command folder_DeleteFromStackPlaces placeNameOrFolder
    if placeNameOrFolder contains "/" then
        set the itemdelimiter to "/"
        put item -1 of someFolder into placeName
    else
        put placeNameOrFolder into placeName
    end if
    
    folder_SetPlaceFolder placeName, empty
end folder_DeleteFromStackPlaces

function folder_GetPlaceFolder placeName
    put the opn_Library of me into modelObject
    return model_GetValue(placeName, modelObject, "uOPN_StackPlace", "array")
end folder_GetPlaceFolder

command folder_SetPlaceFolder placeName, someFolder
    put the opn_Library of me into modelObject
    model_SetValue placeName, modelObject, someFolder, "uOPN_StackPlace", "array"
end folder_SetPlaceFolder

function folder_GetStackPlaceNames
   put the opn_Library of me into modelObject
   put model_GetArrayKeys ("uOPN_StackPlace", modelObject, "array") into placeNames
   return placeNames
end folder_GetStackPlaceNames

function folder_GetStackPlaces
    put the opn_Library of me into modelObject
    return model_GetArrayElements ("uOPN_StackPlace", modelObject, "array")
end folder_GetStackPlaces

function folder_GetStackPlaceArray
   put the opn_Library of me into modelObject
   put model_GetArray ("uOPN_StackPlace", modelObject) into placeNameArray
   return placeNameArray
end folder_GetStackPlaceArray

command folder_SetStackPlaceArray placeNameArray
   put the opn_Library of me into modelObject
   model_SetArray "uOPN_StackPlace", modelObject, placeNameArray
   return placeNameArray
end folder_SetStackPlaceArray
