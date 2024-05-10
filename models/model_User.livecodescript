script "model_User"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_User
type: model
version: 0.1


--> User
-
getprop user_Array [pShortFile]
   return user_GetArray (pShortFile)
end user_Array

setprop user_Array [pShortFile] modelArray
   if modelArray is empty then
      breakpoint
   end if
   user_SetArray pShortFile, modelArray
   put the result into modelDataFile
   return modelDataFile
end user_Array

function user_GetFolder
   /*
   Updated this function so that it should work without stack "lcw_user" existing or known.
   Still probably a good idea to create a project and store it for use customisation.
   When starting a nre LCW project we cannot reply on having data in lcw_User project as it is usr specific.
   */
   -- /Users/david/Documents/My Revolution Enterprise/lcw_User/
   -- Should it be "revUserPluginsFolder" or "revMyDocumentsFolder"?
   -- put the stack_Folder of stack "lcw_User" into projectFolder
   put the documents folder & "/My Revolution Enterprise/lcw_User/" into projectFolder
   return projectFolder
end user_GetFolder


--> Model | User
-
function user_GetValue someKey, shortArrayFile
   put user_GetArray (shortArrayFile) into userArray
   put userArray [someKey] into someValue
   return someValue
end user_GetValue

command user_SetValue someKey, shortArrayFile, someValue
   put user_GetArray (shortArrayFile) into userArray
   put someValue into userArray [someKey]
   user_SetArray shortArrayFile, userArray
   put the result into modelDataFile
   return modelDataFile
end user_SetValue

function user_GetModelFile shortFile
   put user_GetFolder() into projectFolder
   put model_GetDataFile ("lcw_User", projectFolder, shortFile) into modelFile
   return modelFile
end user_GetModelFile

function user_GetArray shortFile
   if the environment = "server" then
      -- put gConfig ["dropBoxAuthToken"] into dropBoxAuthToken
      -- put rigFetchConfigItem ("dropBoxAuthToken") into dropBoxAuthToken
      put rigLoadConfigFile (shortFile, TRUE) into modelArray
   else
      -- put the model_Array [shortFile] of stack "lcw_User" into modelArray
      
      put user_GetModelFile (shortFile) into modelFile
      put array_FromFile (modelFile) into modelArray
   end if
   return modelArray
end user_GetArray

command user_AddArray shortFile, newArray
   put user_GetArray (shortFile) into userArray
   --
   difference userArray with newArray
   union userArray with newArray
   --
   user_SetArray shortFile, userArray
   put the result into modelFile
   return modelFile
end user_AddArray

command user_SetArray shortFile, modelArray
   if the platform is "server" then
      
   else
      -- set the model_Array [shortFile] of stack "lcw_User" to modelArray
      -- put the result into modelFile
      put user_GetModelFile (shortFile) into modelFile
      array_ToFile modelFile, modelArray
   end if
   return modelFile
end user_SetArray
