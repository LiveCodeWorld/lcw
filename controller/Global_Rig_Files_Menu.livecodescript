script "Global_Rig_Files_Menu"
--> MetaData
-
license: GPLv3
name: Global_Rig_Files_Menu
type: controller
version: 0.1


--> Global | Rig | Files | Menu
-
on menu_SwitchServer stackObject, serverURL
   -- put pref_FetchServerArray ("HAP") into serverArray
   -- pref_StoreServerArray serverArray, "Default"
   server_LoadDetails serverURL
   opn_Notify server_GetIPaddress()
end menu_SwitchServer

on menu_FetchRigScript stackObject, rigController
   put rig_FetchControllerFolder() into controllerFolder
   if there is not a folder controllerFolder then
      put controllerFolder
      answer warning "Cannot locate controller folder. Please set one!"
      exit to top
   end if
   
   rig_DownloadScriptAndCreateStack rigController, controllerFolder
   put the result into scriptStackFile
   edit the script of stack scriptStackFile
end menu_FetchRigScript

on _
end _

on menu_DisplayRigScript stackObject
   put the short name of stackObject into shortController
   put rig_ConstructControllerScript (stackObject, shortController) into rigScript
   put rigScript
end menu_DisplayRigScript

on menu_CheckRigScript stackObject
   set the cursor to watch
   
   put the filename of stackObject into stackPath
   set the itemdelimiter to slash
   put item -1 of stackPath into shortControllerFile
   put rig_FetchController (shortControllerFile) into remoteRigScript
   put url ("file:" & stackPath) into localRigScript
   
   put remoteRigScript = localRigScript into areTheSame
   if areTheSame is true then
      answer "The scripts are the same!"
   else
      answer "The script on the server and the local script differ!"
   end if
end menu_CheckRigScript

on menu_UploadRigScript stackObject
   put the short name of stackObject into shortController
   put rig_ConstructControllerScript (stackObject, shortController) into rigScript
   
   rig_StoreController shortController, rigScript
   put the result into shellResult
   if shellResult is empty then
      put rigScript
      answer "Uploaded controller to server!"
   else
      put shellResult
      answer warning "Problem uploading controller to the server!"
   end if
end menu_UploadRigScript

on _
end _

on menu_SetRigScriptFolder
   rig_AskSetLocalControllerFolder
end menu_SetRigScriptFolder

on _
end _

on menu_UploadLocalStack stackObject
   put the short name of stackObject into stackName
   
   set the cursor to watch
   rig_StoreStack stackName
   if the result is not empty then
      put the result
   else
      answer "Re-uploaded local stack to the server"
   end if
end menu_UploadLocalStack

on menu_CheckRemoteStack stackObject
   set the cursor to watch
   
   put _getRemoteStackData (stackObject) into serverStackData
   put the filename of stackObject into localStackFile
   put url ("file:" & localStackFile) into localStackData
   
   put localStackData = serverStackData into stacksAreTheSame
   if stacksAreTheSame is true then
      answer "The stacks are the same!"
   else
      -- display_Lines localStackData, "Local stack"
      -- display_Lines serverStackData, "Remote server stack"
      answer "The stack on the server and the local stack differ!"
   end if
end menu_CheckRemoteStack

getprop disabled_CheckRemoteStack [stackObject]
   put the short name of stackObject into shortControllerFile
   set the itemdelimiter to "."
   if item -1 of shortControllerFile = "lc" then
      -- let's assume it is a rig controller script and not a stack
      return true
   else
      return false
   end if
end disabled_CheckRemoteStack

on _
end _

on menu_FetchServerStack serverStackFile
   breakpoint
   put the hap_StackFolder of me into hapStackFolder
   set the itemdelimiter to "."
   put rig_FetchStack (serverStackFile) into scriptOnlyStack
   put hapStackFolder & serverStackFile into newStackFilePath
   put word 1 of scriptOnlyStack = "Ôªøscript" into isScriptOnly
   if isScriptOnly is true then
      put scriptOnlyStack into url ("file:" & newStackFilePath)
   else
      put scriptOnlyStack into url ("binfile:" & newStackFilePath)
   end if
   set the stack_IsKnow of stack newStackFilePath to true
end menu_FetchServerStack

on menu_DeleteServerStack serverStackFile
   breakpoint
   put merge ("Are you sure you want to delete the stack '[[serverStackFile]]' from the server?") into someWarning
   answer warning someWarning with "OK" or "Cancel"
   if it is "Cancel" then exit to top
   
   set the cursor to watch
   rig_DeleteStack serverStackFile
   refresh
end menu_DeleteServerStack


--> Global | Rig | Files | Menu | Props
-
getprop server_URL
   return server_GetURL()
end server_URL

getprop server_URLs
   put pref_FetchServerArray() into serverArray
   return keys (serverArray)
end server_URLs

getprop rig_Controllers
   -- should work it out
   return "mediawiki.lc,fedwiki.lc,test.lc"
end rig_Controllers


--> Global | Rig | Files | Menu | Disabled
-
getprop disabled_UploadLocalStack
   return LocalArray ["stackExists"] is false
end disabled_UploadLocalStack

getprop disabled_CheckRemoteStack
   return LocalArray ["stackExists"] is false
end disabled_CheckRemoteStack


--> Deps
-
command rig_AskSetLocalControllerFolder
   put rig_FetchControllerFolder() into rigControllerFolder
   answer folder "Select the folder to store all your controllers..." with rigControllerFolder
   put it into rigControllerFolder
   if it is empty then exit to top
   text_AddTrailing rigControllerFolder, slash
   
   rig_StoreControllerFolder rigControllerFolder
   return rigControllerFolder
end rig_AskSetLocalControllerFolder

private function _getRemoteStackData stackObject
   if exists (stackObject) is false then return empty
   -- put the short name of stackObject into shortControllerFile
   put the filename of stackObject into stackPath
   set the itemdelimiter to slash
   put item -1 of stackPath into shortControllerFile
   put rig_FetchStack (shortControllerFile) into serverStackData
   if char 1 to 3 of serverStackData = "Ôªø" then
      delete char 1 to 3 of serverStackData
   end if
   return serverStackData
end _getRemoteStackData
