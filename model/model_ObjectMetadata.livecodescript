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


--> Stack | Folder
-
getprop checkout_Folder [repoType]
   -- important handler needs to be fast and work even if there is no version control
   put the mainstack_File of the target into objectFile
   put checkout_FindRoot (objectFile, repoType) into checkoutFolder
   -- put checkout_ConstructDefaultFolder (objectFile) into checkoutFolder
   return checkoutFolder
end checkout_Folder


--> Currently Working On
-


--> Older way to save important folders to array
-
function project_GetNamedFolder someName, projectName
   -- this is the old way to store folders in the metadata array
   put library_FetchProjectArray (projectName) into projectArray
   put projectArray ["metadata"][someName]["folder"] into standardFolder
   if char -1 of standardFolder is not slash then put slash after standardFolder
   return standardFolder
end project_GetNamedFolder

command project_SetNamedFolder someName, projectName, someFolder
   if char -1 of someFolder is not slash then put slash after someFolder
   put library_FetchProjectArray (projectName) into setArray
   put projectName into setArray ["metadata"]["library_SetName"] -- should be called "project_Name"
   put someFolder into setArray ["metadata"][someName]["folder"]
   library_StoreProjectArray projectName, setArray
end project_SetNamedFolder


--> Project | Metadata | Folder
-
getprop project_OverlayFolder
   put the textStack_Folder of the target into textStackFolder
   put textStackFolder & "metadata/project/overlay/" into projectOverlayFolder
   return projectOverlayFolder
end project_OverlayFolder


--> Object | Folder
-
getprop overlay_Folder [pDontCreate]
   -- /metadata/objects/stack/overlay/ 
   -- which is not the "project" metadata folder
   -- it is the metadata for for a script object
   
   put the object_MetaDataFolder of the target into metadataFolder
   put metadataFolder & "overlay/" into overlayFolder
   if pDontCreate is false then folder_CreateNested overlayFolder
   return overlayFolder
end overlay_Folder

getprop textStackOverlay_Folder [pDontCreate]
   put the textStack_Folder [pDontCreate] of the target into metadataFolder
   put metadataFolder & "metadata/project/overlay/" into overlayFolder
   if pDontCreate is false then folder_CreateNested overlayFolder
   return overlayFolder
end textStackOverlay_Folder

getprop object_MetaDataFolder [pDontCreate]
   -- inside the textStack_Folder
   if pDontCreate is empty then put true into pDontCreate
   put the long id of the target into someObject
   put the stack_Object of the target into stackObject
   put the mainstack of stackObject into mainStackName
   
   put the textStack_Folder of stack mainStackName into mainStackFolder
   return mainstack_MetadataFolder (mainStackFolder, someObject, pDontCreate)
 end object_MetaDataFolder

getprop object_MetaDataFolder [pDontCreate]
   -- metadata/objects/stack/
   -- metadata/objects/button_1006/
   -- this is badly named as it indicates the metadata folder
   -- should be script_MetadataFolder or "object_MetadataFolder"
   
   put the long id of the target into tObject
   put the textStack_Folder of tObject into textStackFolder
   put folder_AddStackBit ("metadata", textStackFolder, tObject) into metadataFolder
   object_AddStackOrObjectBit metadataFolder, tObject
   if pDontCreate is false then folder_CreateNested metadataFolder
   return metadataFolder
end object_MetaDataFolder



--> Project | Folder | Functions
-
function textStack_FindRoot objectFile, repoType
   -- put checkout_FindRoot (objectFile, repoType) into checkOutFolder
   checkout_SetFolderAndRepotype objectFile, repoType
   put the result into checkOutFolder
   
   switch
      case checkoutFolder is empty
         -- not in a repo
         put checkout_ConstructDefaultFolder (objectFile) into textStackFolder
         return textStackFolder
      case checkoutFolder = rev_GetPluginFolder()
         -- this legacy mammoth project is also in "git"
         put checkoutFolder & "opn_Plugins/opn_Text/rev/object/" into textStackFolder
         return textStackFolder
      case (checkoutFolder is not empty and repoType = "fossil")
         -- attempt at catering for legacy fossil projects
         put checkoutFolder & "opn_TextStacks/" into textStackFolder
         return textStackFolder
      case checkoutFolder is not empty and repoType = "git"
         -- it's a new git project
         -- let's use the new folder name
         put checkoutFolder & "liveworld/" into textStackFolder
         return textStackFolder
      case checkoutFolder is not empty
         -- as strange type of repo :)
         put checkoutFolder & "liveworld/" into textStackFolder
         return textStackFolder
   end switch
end textStack_FindRoot


--> Object | Metadata | Wrappers
-
/*
Difficult naming this well - setting an "object_Type" seems like setting a control_Type - ie swithching form a field to a button etc
Changing back to urip for the name of stuff in the script of custom property.
*/

getprop urip_Type
   -- was "object_Type"
   put the object_MetaData ["type"] of the target into objectType
   return objectType
end urip_Type

setprop urip_Type objectType
   -- this also indexes using "object_AddToGlobalArray"
   set the object_MetaData ["type"] of the target to objectType
   put the result into uRipArray
   return uRipArray
end urip_Type

getprop urip_Version
   put the object_MetaData ["version"] of the target into objectType
   return objectType
end urip_Version

setprop urip_Version someVersion
   -- this also indexes using "object_AddToGlobalArray"
   -- was "object_Version"
   set the object_MetaData ["version"] of the target to objectType
   put the result into uRipArray
   return uRipArray
end urip_Version


--> Object | Metadata
-
/*
See also "script_MetaData"
*/

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

getprop object_MetaDataTable [keysToRemove]
   breakpoint
    put the long id of the target into scriptObject
    put the object_MetaData of scriptObject into metaDataArray
    repeat for each item someKey in keysToRemove
        delete local metaDataArray [someKey]
    end repeat
    combine metaDataArray with CR and tab
    return metaDataArray
end object_MetaDataTable


--> Object | Props
-
getprop object_MetaData [uRipKey]
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

getprop stack_RelativeFile [toWhat]
   put the stack_Object of the target into stackObject
   put the effective filename of stackObject into stackFile
   switch toWhat
      case "plugin folder"
         put revEnvironmentUserPluginsPath() & "/" into baseFolder
         break
      default -- case "checkout folder"
         put checkout_FindRoot (stackFile) into baseFolder
   end switch
   file_SetRelativePath stackFile, baseFolder
   return stackFile
end stack_RelativeFile


--> Object | Urip
-
getprop object_UripArray
   put the customproperties ["uRIP"] of the target into uRipArray
   return uRipArray
end object_UripArray

setprop object_UripArray uRipArray
   set the customproperties ["uRIP"] of the target to uRipArray
   return uRipArray
end object_UripArray

setprop object_AddUripArray uRipArrayToAdd
   put the customproperties ["uRIP"] of the target into uRipArray
   -- union uRipArrayToAdd with oldURipArray -- does not check contents
   repeat for each key someProp in uRipArrayToAdd
      put uRipArrayToAdd [someProp] into uRipArray [someProp] 
   end repeat
   set the customproperties ["uRIP"] of the target to uRipArray
   return uRipArray
end object_AddUripArray


--> Checkout | Folders
-
command checkout_SetFolderAndRepotype objectFile, @repoType
   -- ignoreCall: fossil_FindCheckoutFolder,f
   -- ignoreCall: git_GetCheckoutFolder,f
   
   switch repoType
      case "fossil"
         try
            put fossil_FindCheckoutFolder (objectFile) into checkoutFolder
            put "fossil" into repoType
            return checkoutFolder
         catch e
            return empty 
         end try
      case "git"
         try
            put git_GetCheckoutFolder (objectFile) into checkoutFolder
            put "git" into repoType
            return checkoutFolder
         catch e
            return empty 
         end try
      default
         -- let's try to see if there is a repo
         try
            put git_GetCheckoutFolder (objectFile) into gitCheckoutFolder
         catch e
            put empty into gitCheckoutFolder
         end try
         
         try
            put fossil_FindCheckoutFolder (objectFile) into fossilCheckoutFolder
         catch e
            put empty into fossilCheckoutFolder
         end try
         
         switch
            case gitCheckoutFolder is empty and fossilCheckoutFolder is empty
               put "" into repoType
               return empty
            case gitCheckoutFolder is empty and fossilCheckoutFolder is not empty
               put "fossil" into repoType
               return fossilCheckoutFolder
            case gitCheckoutFolder is not empty and fossilCheckoutFolder is empty
               put "git" into repoType
               return gitCheckoutFolder
            default -- case objectFile begins with gitCheckoutFolder and objectFile begins with fossilCheckoutFolder
               -- it's both ?
               -- let's just return the longest (usually the closest folder above objectFile)
               if the number of chars of gitCheckoutFolder > the number of chars of fossilCheckoutFolder then
                  put "git" into repoType
                  return gitCheckoutFolder
               else
                  put "fossil" into repoType
                  return fossilCheckoutFolder
               end if
         end switch
   end switch
end checkout_SetFolderAndRepotype

function script_OrderedMenuTitles someScript
   put script_MenuToolModeArray(someScript) into menuToolModeArray
   put menuToolModeArray ["OrderedMenuTitles"] into menuTitles
   return menuTitles
end script_OrderedMenuTitles

function script_MenuToolModeArray someScript
   local menuToolModeArray
   put script_GetSuiteTitles(someScript) into suiteTitles
   
   set the itemdelimiter to "|"
   put "Menu \((.*)\)" into regularExpression
   put empty into menuTitles
   set the wholematches to true
   repeat for each line suiteTitle in suiteTitles
      put word 1 to -1 of last item of suiteTitle into lastMenuItem
      if lastMenuItem is among the items of "Menu|Menus|Submenu|Submenus" then
         put suiteTitle & CR after menuTitles
         put empty into menuToolModeArray [suiteTitle]
      else if matchtext(lastMenuItem, regularExpression, toolMode) is true then
         put suiteTitle & CR after menuTitles
         put toolMode into menuToolModeArray [suiteTitle]
      end if
   end repeat
   delete last char of menuTitles
   put menuTitles into menuToolModeArray ["OrderedMenuTitles"]
   return menuToolModeArray
end script_MenuToolModeArray

function checkout_ConstructDefaultFolder objectFile
   put objectFile into checkoutFolder
   set the itemdelimiter to "/"
   -- put "opn_TextStacks/" into item -1 of checkoutFolder
   put "liveworld/" into item -1 of checkoutFolder
   return checkoutFolder
end checkout_ConstructDefaultFolder

-- function checkout_ConstructDefaultFolder objectFile
put objectFile into checkoutFolder
set the itemdelimiter to "/"
put "opn_TextStacks/" into item -1 of checkoutFolder
return checkoutFolder
end checkout_ConstructDefaultFolder

function checkout_FindRoot objectFile, repoType
   -- ignoreCall: fossil_FindCheckoutFolder,f
   -- ignoreCall: git_GetCheckoutFolder,f
   
   switch repoType
      case "fossil"
         try
            put fossil_FindCheckoutFolder (objectFile) into checkoutFolder
            return checkoutFolder
         catch e
            return empty 
         end try
      case "git"
         try
            put git_GetCheckoutFolder (objectFile) into checkoutFolder
            return checkoutFolder
         catch e
            return empty 
         end try
      default
         -- let's try to see if there is a repo
         try
            put git_GetCheckoutFolder (objectFile) into gitCheckoutFolder
         catch e
            put empty into gitCheckoutFolder
         end try
         
         try
            put fossil_FindCheckoutFolder (objectFile) into fossilCheckoutFolder
         catch e
            put empty into fossilCheckoutFolder
         end try
         
         switch
            case gitCheckoutFolder is empty and fossilCheckoutFolder is empty
               return empty
            case gitCheckoutFolder is empty and fossilCheckoutFolder is not empty
               return fossilCheckoutFolder
            case gitCheckoutFolder is not empty and fossilCheckoutFolder is empty
               return gitCheckoutFolder
            default -- case objectFile begins with gitCheckoutFolder and objectFile begins with fossilCheckoutFolder
               -- let's just return the longest (usually the closest folder above objectFile)
               if the number of chars of gitCheckoutFolder > the number of chars of fossilCheckoutFolder then
                  return gitCheckoutFolder
               else
                  return fossilCheckoutFolder
               end if
         end switch
   end switch
end checkout_FindRoot

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


--> Mainstack and Objects | To Sort
-
function mainstack_MetadataFolder mainStackFolder, pObject, pDontCreate
   put mainStackFolder & "metadata/" into metadataFolder
   if pObject is not empty then object_AddStackOrObjectBit metadataFolder, pObject
   if pDontCreate is not true then folder_CreateNested metadataFolder
   return metadataFolder
end mainstack_MetadataFolder

function project_GetObjectFolder someObject, stackName, mainStackName, pDontCreate
   -- put the stackDataObjects_Folder [pDontCreate] of someObject into objectFolder
   put stackData_GetFolder (someObject, stackName, mainStackName, pDontCreate) into objectFolder
   object_AddStackOrObjectBit objectFolder, someObject
   if pDontCreate is false then folder_CreateNested objectFolder
   return objectFolder
end project_GetObjectFolder

