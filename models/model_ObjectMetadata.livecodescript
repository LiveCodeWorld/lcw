script "model_ObjectMetadata"
--> MetaData
-
license: GPLv3
copyright: David Bovill
name: model_ObjectMetadata
type: model
version: 0.8

/*
Combines both the uRip value of the object and the script metadata of the object

Prioritises the script value over the objects script metadata
Sets both the uRip value of the object and the script of the object

getprop stack_Folder [pDontCreate]
   put the long ID of the target into someObject
   
   put the textStack_Folder [pDontCreate] of someObject into textStackFolder
   put the stack_Object of someObject into stackObject
   put the short name of stackObject into stackName
   put the mainstack of stackObject into mainStackName
   
   if stackName = mainStackName then
      return textStackFolder
   else
      put textStackFolder & "objects/substacks/" & stackName & "/" into stackFolder
      if pDontCreate is false then folder_CreateNested stackFolder
      return stackFolder
   end if
end stack_Folder
*/


--> Currently Working On
-
command urip_Update someObject, pSomeScript
   if pSomeScript is empty then put the script of someObject into pSomeScript
   put script_GetMetadataArray (pSomeScript) into uRipArray
   -- urip_AddDefaults uRipArray
   set the urip_Array of someObject to uRipArray
end urip_Update


--> URIP | Metadata | Construct
-
function metadata_ConstructUripArray pScriptName, pScriptType, pVersion, pDeps, pCopyrightHolder, pScriptHelp, pLibLicense  
   urip_AddDefaults uRipArray, pScriptName, pScriptType, pVersion, pDeps, pCopyrightHolder, pScriptHelp, pLibLicense  
   return uRipArray
end metadata_ConstructUripArray

command urip_AddDefaults @uRipArray, pScriptName, pScriptType, pVersion, pDeps, pCopyrightHolder, pScriptHelp, pLibLicense   
   if pLibLicense is empty then put pref_GetValue ("userName") into pCopyrightHolder 
   if pLibLicense is empty then put pref_GetValue ("default copyright license") into pLibLicense
   if pLibLicense is empty then put "GPLv3" into pLibLicense
   if pVersion is empty then put "0.1" into pVersion
   
   put pLibLicense into uRipArray ["license"]
   put pVersion into uRipArray ["version"]
   
   if pScriptName is not empty then put pScriptName into uRipArray ["name"]
   if pScriptType is not empty then put pScriptType into uRipArray ["type"]
   if pCopyrightHolder is not empty then put pCopyrightHolder into uRipArray ["copyright"]
   if pDeps is not empty then put pDeps into uRipArray ["deps"]
   if pScriptHelp is not empty then put pScriptHelp into uRipArray ["script_Help"]
end urip_AddDefaults


--> Object | Metadata
-
/*
See also "script_MetaData"
*/

getprop custom_Array [someKey]
   put the customproperties ["lcw"] of the target into customArray
   if someKey is empty then
      return customArray
   else
      return customArray [someKey]
   end if
end custom_Array

setprop custom_Array [someKey] arrayOrValue
   if someKey is empty then
      set the customproperties ["lcw"] of the target to arrayOrValue
      return arrayOrValue
   else
      put the customproperties ["lcw"] of the target into customArray
      put arrayOrValue into customArray [someKey]
      set the customproperties ["lcw"] of the target to customArray
      return customArray
   end if
end custom_Array

getprop object_MetaData [uRipKey]
   -- a union of script_MetaData and an objects uRIP custom props
   
   put the long id of the target into scriptObject
   put the script of scriptObject into someScript
   put script_GetMetadataArray (someScript) into scriptMetaDataArray
   put the customproperties ["uRIP"] of scriptObject into uRipArray
   
   union scriptMetaDataArray with uRipArray
   if uRipKey is empty then
      return scriptMetaDataArray
   else
      return scriptMetaDataArray [uRipKey]
   end if
end object_MetaData

setprop object_MetaData [uRipKey] uRipArray
   -- this also indexes using "object_AddToGlobalArray"
   
   if uRipKey is empty and uRipArray is an array then
      set the script_MetaData of the target to uRipArray
   else
      put uRipArray into newValue
      put the object_MetaData of the target into uRipArray
      put newValue into uRipArray [uRipKey]
      set the script_MetaData of the target to uRipArray
   end if
   return uRipArray
end object_MetaData


--> URIP | Model
-
/*
Difficult naming this well - setting an "object_Type" seems like setting a control_Type - ie swithching form a field to a button etc
Changing back to urip for the name of stuff in the script of custom property.
*/

getprop urip_Name
   put the urip_Array ["name"] of the target into uripName
   return uripName
end urip_Name

setprop urip_Name uripName
   set the urip_Array ["name"] of the target to uripName
   put the result into uRipArray
   return uRipArray
end urip_Name

getprop urip_Type
   put the urip_Array ["type"] of the target into objectType
   return objectType
end urip_Type

setprop urip_Type objectType
   set the urip_Array ["type"] of the target to objectType
   put the result into uRipArray
   return uRipArray
end urip_Type

getprop urip_Version
   put the urip_Array ["version"] of the target into objectType
   return objectType
end urip_Version

setprop urip_Version someVersion
   set the urip_Array ["version"] of the target to objectType
   put the result into uRipArray
   return uRipArray
end urip_Version

getprop urip_Array [someKey]
   put the customproperties ["uRIP"] of the target into uRipArray
   if someKey is empty then
      return uRipArray
   else
      return uRipArray [someKey]
   end if
end urip_Array

setprop urip_Array [someKey] arrayOrValue
   if someKey is empty then
      set the customproperties ["uRIP"] of the target to arrayOrValue
      return arrayOrValue
   else
      put the customproperties ["uRIP"] of the target into uRipArray
      put arrayOrValue into uRipArray [someKey]
      set the customproperties ["uRIP"] of the target to uRipArray
      return uRipArray
   end if
end urip_Array
