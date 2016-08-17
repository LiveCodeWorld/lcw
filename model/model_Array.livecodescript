script "model_Array"
--> MetaData
-
license: GPLv3
name: model_Array
type: model
version: 0.1
copyright: David Bovill


/*
This stack contins a start at creating a standard way to make array based models.
The original idea was that you can specify a control to hold the array.
The better idea is to abstract away where you get the arrya from, so we can switch simple models easily.

-- old notes
This stack contains the model, view, controller (MVC) library functions and interfaces.
This is the data model. Could be called the view_DataModel.
We also have view_DisplayModel's and event_Model's
*/

--> Model
-
setprop model_Object [modelName] modelObject
   put the long id of the target into targetObject
   if modelName is empty then put the model_Name of targetObject into modelName
   
   set the uOPN [modelName] of targetObject to the rugged_ID of modelObject
end model_Object

getprop model_Object [modelName]
   put the long id of the target into targetObject
   
   /*
   -- skipping this to speed things up (can override this default getprop locally in any case)
   if modelName is empty then
      put "OPN Model" into modelName
      -- put the model_Name of targetObject into modelName
   end if
   put the uOPN [modelName] of targetObject into modelObject
   -- put object_ReferenceToControl(modelObject, targetObject) into modelObject
   
   if exists(modelObject) is truethen return modelObject
   */
   
   -- return a sensible default
   switch word 1 of targetObject
      case "stack"
         return targetObject
      case "group"
         if the backgroundbehavior of targetObject is true then
            return the stack_Object of targetObject
         else
            return the card_Object of targetObject
         end if
      default
         return the card_Object of targetObject
   end switch
end model_Object

getprop model_Name
   put the view_Stem of the target into viewStem
   if viewStem is empty then return "opn_Model" -- was "OPN Model"
   
   put toupper(char 1 of viewStem) into char 1 of viewStem -- can remove to speed up
   put "uOPN_" & viewStem into modelName
   return modelName
end model_Name


--> Model | Type | Switch
-
/*
model_Type is a property of the model_Object. 
It is used by generic model handlers to access standard array compatable data formats, such as
array, text, html, xml, and database

The default model type is "array". 

It cannot be set by a script and must be overridden
by manually adding a "getprop model_Type" hander to the models script.
You can distinguish multiple models in the same object with the modelName param.

One of the points of using models is to allow the evolution of your data model
from simple arrays to external sources and databases. To achieve this we use a default
mapping of arrays to tex files and database structures, together with a cutom property "switch"
which allows us to move between compatable data sources.

More elaborate customisation requires coding of the custom roperties and funcitons that constitute the data model.
*/

getprop model_Type [modelName]
   return "array"
end model_Type


--> Model | Value
-
/*
This function allows switching between forms of storage for the model.
Returns an array for use in a controller.
"modelType" is often got by reading a custom property of the modelObject

Arrays are always combined with an "global" arrays, 
which is combined with any "local" arrays
Any entries (keys) in the "local" array taking prominence

"Local" arrays default to using a local custom property of an object, but can come from a database.
They are therefore usually specific to the modelObject and are as such local to that specific store.
There can be many models with the same name in different modelObjects,
but only one "global" array for each modelname.
*/

function model_GetValue someKey, modelObject, modelName, modelType
   put model_GetArray (modelName, modelObject, modelType) into dataArray
   put dataArray[someKey] into someValue
   return someValue
end model_GetValue

on model_SetValue someKey, modelObject, someValue, modelName, modelType
   put model_GetArray(modelName, modelObject, modelType) into dataArray
   if someValue is empty then
      -- setting to empty also deletes key option?
      delete local dataArray[someKey]
      if keys(dataArray) is empty then
         model_DeleteArray modelName, modelObject
         return empty
      end if
   else
      put someValue into dataArray[someKey]
   end if
   model_SetArray modelName, modelObject, dataArray, modelType
   return dataArray
end model_SetValue


--> Model | Names
-
getprop model_Names [someFilter]
   if someFilter is empty then put "u*" into someFilter
   put the custompropertysets of the target into customSets
   filter customSets with someFilter
   return customSets
end model_Names

function model_GetNames modelObject
   put the custompropertysets of modelObject into setNames
   filter setNames without "cGLX2*"
   return setNames
end model_GetNames


--> Model | Array
-
getprop model_Array [pModelType]
   put the model_Object of the target into modelObject
   if exists(modelObject) is false then put the long id of the target into modelObject
   
   put the model_Name of the target into modelName
   if modelName is empty then put "model" into modelName
   
   if pModelType is empty then put the model_Type of the target into pModelType
   put model_GetArray (modelName, modelObject, pModelType) into modelArray
   return modelArray
end model_Array

setprop model_Array [pModelType] dataArray
   put the model_Object of the target into modelObject
   if exists(modelObject) is false then put the long id of the target into modelObject
   
   put the model_Name of the target into modelName
   if modelName is empty then put "model" into modelName
   
   if pModelType is empty then put the model_Type of the target into pModelType
   model_SetArray modelName, modelObject, pModelType, modelArray
   return modelArray
end model_Array

function model_GetArray modelName, modelObject, pModelType
   switch pModelType
      case "database"
         put the object_DataBaseArray [modelName] of modelObject into tArray
         break
      case "file" -- an array stored as an arrayEncoded binary file
         put the object_FileArray [modelName] of modelObject into tArray
         break
      default -- case "array" 
         -- It is an array stored in a control
         put the customproperties [modelName] of modelObject into tArray
   end switch
   return tArray
end model_GetArray

on model_SetArray modelName, modelObject, dataArray, modelType
   switch pModelType
      case "database"
         set the object_DataBaseArray [modelName] of modelObject to dataArray
         break
      case "file"
         model_GetFileArray
         break
      case "object file" -- an array stored as an arrayEncoded binary file
         set the object_FileArray [modelName] of modelObject to dataArray
         break
      default -- case "array" 
         -- It is an array stored in a control
         set the customproperties [modelName] of modelObject to dataArray
   end switch
   put the model_RefreshDisplays [modelName] of modelObject into updatedViews
   return updatedViews
end model_SetArray

function model_GetFileArray modelName
   put library_ArrayFolder (modelName) into someFile
   put url ("binfile:" & someFile) into encodedDataArray
   if encodedDataArray is empty then return empty
   put arraydecode (encodedDataArray) into metaDataArray
   return metaDataArray
end model_GetFileArray

command model_SetFileArray modelName, modelArray
   put library_ArrayFolder (modelName) into someFile
   if keys (modelArray) is empty then
      file_Delete someFile
   else
      put arrayencode (modelArray) into url ("binfile:" & someFile)
   end if
   return someFile
end model_SetFileArray

on model_DeleteArray modelName, modelObject, modelType
   -- delete the array stored of the control
   put the custompropertysets of modelObject into setNames
   line_Delete modelName, setNames
   set the custompropertysets of modelObject to setNames
   
   put the model_RefreshDisplays [modelName] of modelObject into updatedViews
   return updatedViews
end model_DeleteArray


--> Object | File | Array
-
getprop object_FileArray [pModelName]
   put the model_File [pModelName] of the target into someFile
   put array_Fetch (someFile) into tArray
   return tArray
end object_FileArray

setprop object_FileArray [pModelName] dataArray
   put the model_File [pModelName] of the target into someFile
   array_Save someFile, dataArray
   return someFile
end object_FileArray

getprop model_File [modelName]
   put the model_Object of the target into modelObject
   if exists(modelObject) is false then put the long id of the target into modelObject
   
   if modelName is empty then put "array" into modelName
   put the model_Folder of modelObject into modelFolder
   folder_Format modelFolder
   put modelFolder & modelName into someFile
   return someFile
end model_File


--> Model | Folder
-
/*
The model_Folder is the place where the model data is stored. 
The folder can be moved and reconnected using the model_Folder property of the model_Object, and everything will keep working as normal.
This allows casual scripting with default values and moving the model_Folder into the app when finished.

The default model_Folder is a folder within the opn_Model folder named after the model_Object,
in a similar way to scripts stored externally - that is "stack name / sub stack name / object_ID

The default model_Name is "array".
*/

getprop model_Folder [pDontCreate]
   -- return model_NamedFolder (modelName, pDontCreate) -- use this for a custom model
   breakpoint
   
   -- this is a default
   put the long id of the target into longIDObject
   put library_PluginFolder ("opn_Model") into pObjectFolderRoot
   
   if pObjectFolderRoot is empty then
      put the checkout_Folder of longIDObject into textStackRoot
   else
      folder_Format pObjectFolderRoot
      put pObjectFolderRoot into textStackRoot
      put stack_ConstructFolderBit (longIDObject) after textStackRoot
   end if
   put "objects/" after objectFolder
   object_AddStackOrObjectBit objectFolder, longIDObject
   if pDontCreate is not true then folder_CreateNested objectFolder
   return objectFolder
end model_Folder

function stack_ConstructFolderBit someObject
   local mainStackStart, mainStackEnd, substackStart, substackEnd
   
   object_StackNameOffsets someObject, mainStackStart, mainStackEnd, substackStart, substackEnd
   put char mainStackStart to mainStackEnd of someObject into longStackName
   put the short name of stack longStackName into mainStackName
   put char substackStart to substackEnd of someObject into subStackName
   
   put mainStackName & "/" into objectPath
   if subStackName is not empty then
      put "substacks/" & subStackName & "/" after objectPath
   end if
   return objectPath
end stack_ConstructFolderBit

function model_NamedFolder modelName, pDontCreate
   folder_Format modelName
   put "opn_Model/" & modelName into relativeFolder
   put library_PluginFolder (relativeFolder, pDontCreate) into modelFolder
   return modelFolder
end model_NamedFolder

function opn_ModelFolder pDontCreate
   -- a default place to store models until they are moved to their final destination
   put library_PluginFolder ("opn_Model", pDontCreate) into modelFolder
   return modelFolder
end opn_ModelFolder


--> Object | Database
-
/*
Not done yet!
*/

getprop object_DataBaseArray [modelName]
   answer warning "Database model not implemented!"
   return empty
   
   put the object_DataBaseFile [modelName] of the target into someFile
   put array_FetchFromDataBase (someFile) into tArray
   return tArray
end object_DataBaseArray

setprop object_DataBaseArray [modelName] dataArray
   answer warning "Database model not implemented!"
   return empty
   
   put the object_DataBaseFile [modelName] of the target into someFile
   put array_FetchFromDataBase (someFile) into tArray
   return tArray
end object_DataBaseArray

getprop object_DataBaseFile [modelName]
   answer warning "Database model not implemented!"
   return empty
   
   put the model_Object of the target into modelObject
   if exists(modelObject) is false then put the long id of the target into modelObject
   
   if modelName is empty then put "array" into modelName
   put the model_Folder of modelObject into modelFolder
   put modelFolder & modelName into someFile
   return someFile
end object_DataBaseFile


--> Model | View Links
-
/*
A model can be linked to any number of views for display purposes.

The model "knows" about these views through its "model_ViewLinks".
In turn the view knows about which models it is linked to.
Views are usually linked to only one model,
if a view needs to refer to data from more than one model it does this via a controller
one controller per view-model link.

At the present these are global and not local links.
It should be made easy to move the links to local objects for distribution.
At the moment this can be done by intercepting the library getprop / setprop handlers locally.
Simply copy them locally if you want to do somethng special.

As these links do not require non-standard messages (as with controllers),
we do not need to store complex tables.
Views refer to models through the standard "array-based" interface,
and models just send "view_Refresh" getprop messages to views when they are updated.
*/

getprop model_RefreshDisplays [modelName]
   local updatedViews
   
   put the long id of me into linkedViewModelObject
   put the model_ViewLinks [modelName] of linkedViewModelObject into linkedViews
   repeat for each line linkedView in linkedViews
      if exists(linkedView) then
         get the view_Refresh [modelName] of linkedView
         if it is true then
            put linkedView & CR after updatedViews
         end if
      end if
   end repeat
   return updatedViews
end model_RefreshDisplays

getprop model_ViewLinks [modelName]
   -- was "model_LinkedViews" then "model_Links"
   put the long id of me into modelObject
   return model_GetValue(modelName, modelObject, "uOPN_LinkedViewsOfModel", "array")
end model_ViewLinks

setprop model_ViewLinks [modelName] someViews
   -- put the linked_Views of model modelName into linkedViews	# would be nice syntax!
   local mobileViews
   put the long id of me into modelObject
   repeat for each line someView in someViews
      put the mobile_Name of someView into mobileView
      put mobileView & CR after mobileViews
   end repeat
   delete last char of mobileViews
   model_SetValue modelName, modelObject, mobileViews, "uOPN_LinkedViewsOfModel", "array"
end model_ViewLinks


--> Model | View Links | Utilities
-
setprop model_AddLink [modelName] someView
   put the long id of me into modelObject
   model_RegisterView modelName, someView, modelObject
   return the result
end model_AddLink

on model_RegisterView modelName, someView, modelObject
   put the mobile_Name of someView into mobileView
   model_AddToIndex mobileView, modelName, modelObject, "uOPN_LinkedViewsOfModel", "array"
   return the result
end model_RegisterView

setprop model_DeleteLink [modelName] someView
   put the long id of me into modelObject
   model_UnregisterView modelName, someView, modelObject
   return the result
end model_DeleteLink

on model_UnregisterView modelName, someView, modelObject
   put the mobile_Name of someView into mobileView
   model_DeleteFromIndex mobileView, modelName, modelObject, "uOPN_LinkedViewsOfModel", "array"
end model_UnregisterView


--> Model | Two Way
-
function model_TwoWayKeyIndex modelName, modelObject, modelType
   put model_GetArray(modelName, modelObject, modelType) into dataArray
   return dictionary_KeyIndex(dataArray)
end model_TwoWayKeyIndex

function model_TwoWayValueIndex modelName, modelObject, modelType
   put model_GetArray(modelName, modelObject, modelType) into dataArray
   return dictionary_ValueIndex (dataArray)
end model_TwoWayValueIndex

on model_TwoWayAdd someKey, someValue, modelName, modelObject, modelType
   put model_GetArray(modelName, modelObject, modelType) into dataArray
   dictionary_Set dataArray, someKey, someValue
   model_SetArray modelName, modelObject, dataArray, modelType
end model_TwoWayAdd


--> Model | Utilities
-
on model_AddToArray newArray, modelName, modelType, modelObject
   if keys(newArray) is empty then return empty
   
   put model_GetArray(modelName, modelObject, modelType) into dataArray
   array_AddNew newArray, dataArray
   put the result into addedKeys
   model_SetArray modelName, modelObject, dataArray, modelType
   
   return addedKeys
end model_AddToArray

on model_AddToIndex someLine, indexKey, modelObject, modelName, modelType
   -- was "index_AddTo"
   if indexKey is empty then return "Error: indexname is empty"
   
   put model_GetValue (indexKey, modelObject, modelName, modelType) into someIndex
   line_Add someLine, someIndex
   model_SetValue indexKey, modelObject, someIndex, modelName, modelType
   return someIndex
end model_AddToIndex

on model_DeleteFromIndex someLine, indexKey, modelObject, modelName, modelType
   put model_GetValue(indexKey, modelObject, modelName, modelType) into oldIndex
   put line_DeleteFromIndex(someLine, oldIndex) into newIndex
   if newIndex is empty then -- might as well tidy?
      model_DeleteArrayKey indexKey, modelObject, modelName, modelType
      put the result into newKeys
      if newKeys is empty then
         model_DeleteArray modelName, modelObject, modelType
      end if
   else
      model_SetValue indexKey, modelObject, newIndex, modelName, modelType
   end if
   return newIndex
end model_DeleteFromIndex

getprop model_ArrayKeys [modelName]
   put the long id of the target into modelObject
   return model_GetArrayKeys(modelName, modelObject)
end model_ArrayKeys

function model_GetArrayKeys modelName, modelObject, modelType
   put model_GetArray(modelName, modelObject) into dataArray
   return keys(dataArray)
end model_GetArrayKeys

function model_GetArrayElements modelName, modelObject, modelType
   put model_GetArray(modelName, modelObject, modelType) into dataArray
   
   put empty into someElements
   repeat for each element someElement in dataArray
      put someElement & CR after someElements
   end repeat
   delete last char of someElements
   return someElements
end model_GetArrayElements


--> Model | Simple Properties
-
getprop model_Index [indexKey]
   if indexKey is empty then put "Default" into indexKey
   put the long id of the target into modelObject
   
   put model_GetValue(indexKey, modelObject, "uOpn", "array") into someValue
   return someValue
end model_Index

setprop model_Index [indexKey] someIndex
   if indexKey is empty then put "Default" into indexKey
   put the long id of the target into modelObject
   
   model_SetValue indexKey, modelObject, someValue, "uOpn", "array"
   return the result
end model_Index

setprop model_NewLine [indexKey] someLine
   put the long id of the target into modelObject
   model_AddToIndex someLine, indexKey, modelObject, "uOPN", "array"
   return the result
end model_NewLine

setprop model_DeleteLine [indexKey] someLine
   put the long id of the target into modelObject
   model_DeleteFromIndex someLine, indexKey, modelObject, "uOPN", "array"
   return the result
end model_DeleteLine


--> Model | Value
-
/*
Models are objects which have access to and methods (command and functions) to access this data in a controlled way.

The default technique is to store and retrieve the data as arrays.

A model object can store several arrays (known as dictionaries).
For this reason and as there are already a number of libraries out there (libDatabase for instance)...
Complex models are implemented as libraries - follwing the ECMI specification.

The arrays are often stored as named custom property sets. 
These custom property sets are named according to the ECMI specification - ie "uOPNTree_Table".

Arrays can also be stored as text files, or XML, or in a database.
and to allow porting of this data, the default methods: model_GetArray and model_SetArray
Allow switching between these forms of storage.

Models (as any other object) can also have property handlers to allow getting ans setting of simple properties.
*/

setprop model_AddValue [somekey] someValue
   put the long id of the target into modelObject
   if someKey is empty then put "Default" into somekey
   put cModelDefaultArrayName into modelName
   model_AddToIndex someValue, somekey, modelObject, modelName, "array"
end model_AddValue

setprop model_DeleteValue [somekey] someValue
   put the long id of the target into modelObject
   if someKey is empty then put "Default" into somekey
   put cModelDefaultArrayName into modelName
   model_DeleteFromIndex someValue, somekey, modelObject, modelName, "array"
end model_DeleteValue

getprop model_Array [modelName]
   put the long id of the target into modelObject
   if modelName is empty then put cModelDefaultArrayName into modelName
   return model_GetArray(modelName, modelObject, "array")
end model_Array


--> Model | Command and Functions
-
on model_MoveArray modelName, oldDataObject, newDataObject, modelType
   custom_CopySet modelName, oldDataObject, newDataObject
   custom_DeleteSet modelName, oldDataObject
end model_MoveArray

on model_DeleteArrayKey someKey, modelObject, modelName, modelType
   put model_GetArray(modelName, modelObject) into dataArray
   delete local dataArray[someKey]
   put keys(dataArray) into dictionaryKeys
   if dictionaryKeys is empty then
      model_DeleteArray modelName, modelObject
      return empty
   else
      model_SetArray modelName, modelObject, dataArray
      return dictionaryKeys
   end if
end model_DeleteArrayKey

on model_MoveArrays modelNames, controllerObject, modelReference, oldModelReference, modelType
   repeat for each item modelName in modelNames
      put model_GetArray(modelName, controllerObject, oldModelReference)
      model_SetArray modelName, controllerObject, dataArray, modelReference
      model_DeleteArray modelName, controllerObject, oldModelReference
   end repeat
end model_MoveArrays


--> Model | XML
-
getprop model_Table [modelName]
   put the long id of the target into modelObject
   get model_GetArray(modelName, modelObject, "array")
   combine it using CR and tab
   return it
end model_Table

getprop model_XML [modelName]
   put the mobile_Name of the target into modelObject
   put model_GetArray(modelName, modelObject, "array") into modelArray
   
   local someXML
   repeat for each key tagName in modelArray
      put modelArray [tagName] into someContents
      put xml_Tag(someContents, tagName) after someXML
   end repeat
   put xml_Tag(someXML, modelName) after someXML
   return someXML
end model_XML

getprop model_PList [modelName]
   put the mobile_Name of the target into modelObject
   put model_GetArray(modelName, modelObject, "array") into modelArray
   
   put plist_DictFromArray(modelArray) into dictXML
   
   put modelName into pListArray ["Name"]
   put modelObject into pListArray ["Object"]
   put dictXML into pListArray ["Model"]
   
   put plist_DictFromArray(pListArray) into baseDict
   put xml_Tag(baseDict, "plist", "version", "1.0") after someXML
   return someXML
end model_PList

function model_XmlToTable someXML
   -- only for simple XML
   put revCreateXMLTree(someXML,true,true,false) into treeID
   if treeID is not a number then
      return treeID
   else
      put revXMLRootNode(treeID) into rootNode
      put revXMLChildContents(treeID, rootNode, tab, CR, true, 1) into dataTable
      revDeleteXMLTree treeID
      return dataTable
   end if
end model_XmlToTable
