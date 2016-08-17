script "model_TextStack"
--> MetaData
-
license: GPLv3
name: model_TextStack
type: model
version: 0.6

/*
A "text stack" is a representation of a stack, together with any metadata in a simple text format.
All the text files are contained in a single folder.

It should be possible to reconstruct the entire stack from the "data" folder,
while the metadata folder should contain any information which desribes or graphs any dependencies for the stack.
*/

--> Working on
-
 getprop script_File [pDontCreate]
   put pDontCreate is not false into pDontCreate
   put the object_Folder [pDontCreate] of the target into objectFolder
   put objectFolder & "script.txt" into someFile
   return someFile
end script_File

getprop object_Folder [pDontCreate]
   put the long id of the target into someObject
   put the stackDataObjects_Folder [pDontCreate] of someObject into objectFolder
   object_AddStackOrObjectBit objectFolder, someObject
   if pDontCreate is not true then folder_CreateNested objectFolder
   return objectFolder
end object_Folder

getprop stackDataObjects_Folder [pDontCreate]
   put the long ID of the target into someObject
   put the textStack_Folder [pDontCreate] of someObject into textStackFolder
   put folder_AddStackBit ("data", textStackFolder, someObject) into stackFolder
   if pDontCreate is false then folder_CreateNested stackFolder
   return stackFolder
end stackDataObjects_Folder

getprop stackData_Folder [pDontCreate]
   -- lazy, manifest is in inconsistant place, but prob best until merge into one mainstack manifest
   put the long ID of the target into someObject
   put the stack_Object of someObject into stackObject
   put the short name of stackObject into stackName
   put the mainstack of stackObject into mainStackName
   
   put stackData_GetFolder (someObject, stackName, mainStackName, pDontCreate) into stackDataFolder
   return stackDataFolder
end stackData_Folder

function stackData_GetFolder someObject, stackName, mainStackName, pDontCreate
   put the textStack_Folder [pDontCreate] of someObject into textStackFolder
   put folder_AddStackBit ("data", textStackFolder, someObject) into stackDataFolder
   
   if stackName = mainStackName then
      put textStackFolder & "data/" into stackDataFolder
   else
      put textStackFolder & "data/objects/substacks/" & stackName & "/" into stackDataFolder
   end if
   if pDontCreate is false then folder_CreateNested stackDataFolder
   return stackDataFolder
end stackData_GetFolder

function folder_AddStackBit dataOrMetadata, textStackFolder, someObject
   put the stack_Object of someObject into stackObject
   put the short name of stackObject into stackName
   put the mainstack of stackObject into mainStackName
   
   if stackName = mainStackName then
      put textStackFolder & dataOrMetadata & "/objects/" into stackFolder
   else
      put textStackFolder & dataOrMetadata & "/objects/substacks/" & stackName & "/" into stackFolder
      -- put dataOrMetadata & "/objects/"  after stackFolder
   end if
   return stackFolder
end folder_AddStackBit

getprop textStack_Folder [pDontCreate]  
   put lcw_UserMetadataFolder() into textStackRoot
   put the stack_Object of the target into stackObject
   put the mainstack of stackObject into mainStackName
   put textStackRoot & mainStackName & "/" into textStackFolder
   if pDontCreate is false then folder_CreateNested textStackFolder
   return textStackFolder
end textStack_Folder

getprop textStack_Root
   put lcw_UserMetadataFolder() into lcwUserMetadataFolder
   return afds
end textStack_Root


--> Old
-
getprop old_TextStackFolder [pDontCreate]
   -- was "textStack_Folder"
   put the stack_Object of someObject into stackObject
   put the mainstack of stackObject into mainStackName
   put lcw_UserMetadataFolder() into lcwUserMetadataFolder
   put lcwUserMetadataFolder & mainStackName & "/" into textStackFolder
   
   put the mainstack_File of the target into objectFile
   put project_FolderAboveFile (objectFile) into textStackRoot
   
   if there is not a folder textStackRoot then
      -- should not needed except in authoring
      put textStack_FindRoot (objectFile) into textStackRoot
      if there is not a folder textStackRoot then
         return empty
      else
         -- add to library
         put project_NameFromFolder (projectFolder) into projectName
         library_StoreProjectFolder projectName, projectFolder
      end if
   end if
   
   put the stack_Object of the target into stackObject
   put the mainstack of stackObject into mainStackName
   put textStackRoot & mainStackName & "/" into stackFolder
   if pDontCreate is false then folder_CreateNested stackFolder
   return stackFolder
end old_TextStackFolder

getprop old_TextStackRoot [repoType]
   put the mainstack_File of the target into objectFile
   put textStack_FindRoot (objectFile, repoType) into textStackRoot
   return textStackRoot
end old_TextStackRoot

getprop old_ObjectFolder
   put the long id of the target into someObject
   put the stackDataObjects_Folder [pDontCreate] of someObject into objectFolder
   object_AddStackOrObjectBit objectFolder, someObject
   if pDontCreate is not true then folder_CreateNested objectFolder
   return objectFolder
end old_ObjectFolder
