script "model_ObjectMetadata"
--> MetaData
-
license: GPLv3
copyright: David Bovill
name: model_ObjectMetadata
type: model
version: 0.8

/*
A urip_Array is based on cutomo properties. This is an old technique.
We use the properties of the script directly now, as we have script libraries that have no custom properties when loaded.

See "model_Meta" for text file based metadata of scripts.
*/


--> Working On
-
command urip_Update someObject, pSomeScript
   if pSomeScript is empty then put the script of someObject into pSomeScript
   put script_GetMetadataArray (pSomeScript) into uRipArray
   -- urip_AddDefaults uRipArray
   set the urip_Array of someObject to uRipArray
end urip_Update


--> Object | Metadata
-
/*
Combines both the uRip value of the object and the script metadata of the object
Prioritises the script value over the objects script metadata
Sets both the uRip value of the object and the script of the object
*/

--> Object | Metadata
-
getprop object_Yaml
   put the object_Metadata of the target into metadataArray
   delete variable metadataArray ["script_Help"]
   put metadata_ArrayToYaml (metadataArray) into objectYaml
   return objectYaml
end object_Yaml

getprop object_Metadata [uRipKey]
   -- see also "meta_Data" of "model_Meta"
   put the long id of the target into sObject
   --
   put the script_Metadata of sObject into metadataArray
   -- _AddUrip metadataArray, sObject -- can phase this out
   --
   put the project_Name of sObject into metadataArray ["project"]
   put the github_RelativePath of sObject into metadataArray ["github"]
   --
   if uRipKey is empty then
      return metadataArray
   else
      return metadataArray [uRipKey]
   end if
end object_Metadata

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


--> URIP | Model
-
/*
Based on custom properties. An olde technique.
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


--> URIP | Metadata | Construct
-
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


--> Meta
-
function metadata_ArrayToYaml metadataArray
   put "name,type,project,license,version,deps" into firstMeta
   repeat for each item someKey in firstMeta
      put word 1 to -1 of metadataArray [someKey] into metaValue
      if metaValue is not empty then
         put someKey & ":" && metaValue & CR after metaYaml
      end if
      delete variable metadataArray [someKey]
   end repeat
   
   put keys (metadataArray) into metaKeys
   sort lines of metaKeys
   repeat for each line someKey in metaKeys
      put word 1 to -1 of metadataArray [someKey] into metaValue
      if metaValue is not empty then
         put someKey & ":" && metaValue & CR after metaYaml
      end if
   end repeat
   delete char -1 of metaYaml
   return metaYaml
end metadata_ArrayToYaml

function metadata_ConstructUripArray pScriptName, pScriptType, pVersion, pDeps, pCopyrightHolder, pScriptHelp, pLibLicense  
   urip_AddDefaults uRipArray, pScriptName, pScriptType, pVersion, pDeps, pCopyrightHolder, pScriptHelp, pLibLicense  
   return uRipArray
end metadata_ConstructUripArray


--> Private
-
private command _AddUrip @metadataArray, sObject
   put the customproperties ["uRIP"] of sObject into uRipArray
   union metadataArray with uRipArray
end _AddUrip
