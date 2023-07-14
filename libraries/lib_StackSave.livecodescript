script "lib_StackSave"
--> MetaData
-
license: GPLv3
name: lib_StackSave
type: library
version: 0.2

/*
This library is [[work-in-progress]]. it is designed to explore different and better ways to save stacks.

At the moment it is used regularly to save all edited stacks (as shown in [[Script Editor]] menubar),
using the stack_SaveEdited ("all") command.

# Future
The aim is to be able to work with stacks in a P2P fashion.
We explore applications using IPFS, DAT and SSB to this end.
*/

--> Working on
-
function folder_GetStackNameArray sFolder
   -- good for presenting as it uses empty array style
   -- use folder_ListStackNames if you just want an index
   text_AddTrailing sFolder, slash
   put files (sFolder) into shortFiles
   repeat for each line shortFile in shortFiles
      put sFolder & shortFile into stackFilePath
      if there is a stack stackFilePath then
         put the short name of stack stackFilePath into stackName
         put empty into stackNameArray [stackName]
      end if
   end repeat
   return stackNameArray
end folder_GetStackNameArray

function folder_ListStackNames someFolder
   -- wil load stacks into memory
   if there is not a folder someFolder then return empty
   text_AddTrailing someFolder, slash
   put the defaultfolder into oFolder
   set the defaultfolder to someFolder
   put the files into shortFiles
   
   set the itemdelimiter to "."
   repeat for each line shortFile in shortFiles
      put someFolder & shortFile into stackFilePath
      if there is a stack stackFilePath then
         put the short name of stack stackFilePath & CR after stackNames
      end if
   end repeat
   delete char -1 of stackNames
   set the defaultfolder to oFolder
   return stackNames
end folder_ListStackNames



--> Props
-
getprop stack_CompressedData
   put the effective filename of the target into someFile
   put "file:" & someFile into someUrl
   put url someUrl into stackData
   return compress(stackData)
end stack_CompressedData

getprop stack_Data
   put the effective filename of the target into someFile
   put "binfile:" & someFile into someUrl
   put url someUrl into stackData
   return stackData
end stack_Data


--> Folder | List | Stacks
-
/*
Should be renamed "file_***" as the return files, or stack fie info.
*/

function folder_ListStackFileNames someFolder
   -- wil load stacks into memory
   if there is not a folder someFolder then return empty
   
   if char -1 of someFolder is not slash then put slash after someFolder
   put the defaultfolder into oFolder
   set the defaultfolder to someFolder
   put the files into shortFiles
   repeat for each line shortFile in shortFiles
      if there is a stack shortFile then
         put someFolder & shortFile & CR after stackFileNames
      end if
   end repeat
   delete char -1 of stackFileNames
   set the defaultfolder to oFolder
   return stackFileNames
end folder_ListStackFileNames

function folder_ListStackPaths someFolder
   -- will load stacks into memory
   if there is not a folder someFolder then return empty
   
   if char -1 of someFolder is not slash then put slash after someFolder
   put the defaultfolder into oFolder
   set the defaultfolder to someFolder
   put the files into shortFiles
   
   set the itemdelimiter to "."
   repeat for each line shortFile in shortFiles
      put someFolder & shortFile into stackFilePath
      if there is a stack stackFilePath then
         put stackFilePath & CR after stackFilePaths
      end if
   end repeat
   delete char -1 of stackFilePaths
   set the defaultfolder to oFolder
   return stackFilePaths
end folder_ListStackPaths

function folder_ListShortStackFiles someFolder
    -- wil load stacks into memory
   if there is not a folder someFolder then return empty
   
   put the defaultfolder into oFolder
   set the defaultfolder to someFolder
   put the files into shortFiles
   repeat for each line shortFile in shortFiles
      if there is a stack shortFile then
         put shortFile & CR after shortStackFiles
      end if
   end repeat
   delete char -1 of shortStackFiles
   set the defaultfolder to oFolder
   return shortStackFiles
end folder_ListShortStackFiles


--> Stack | Recent
-
command stack_SaveRecentStacks
   put scriptEditor_ListEditingObjects() into historyObjects
   repeat for each line someObject in historyObjects
      put the stack_Object of someObject into stackObject
      put the mainstack of stackObject into mainStackName
      put stackObject into stackObjectArray [mainStackName]
   end repeat
   
   repeat for each key mainStackName in stackObjectArray
      set the cursor to busy
      if exists (stack mainStackName) is false then 
         next repeat
      end if
      save stack mainStackName
   end repeat
   return historyObjects
end stack_SaveRecentStacks

command stack_SaveAppStacks
   put revLoadedStacks ("application") into appStackNames
   repeat for each line appStackName in appStackNames
      if the filename of stack appStackName is empty then
         next repeat
      end if
      
      /*
      if the destroywindow of stack appStackName is true then
         next repeat
      end if
      */
      
      save stack appStackName
      lcw_Notify ("Saved stack" && appStackName)
   end repeat
end stack_SaveAppStacks

command stack_SaveToIpfs scriptObject
   put the stack_Name of scriptObject into stackName
   put the mainstack of stack stackName into mStackName
   ipfs_SaveStack mStackName
   put the result
end stack_SaveToIpfs


--> Stack | Edited
-
command stack_SaveEdited pStackNames, pIndexView, pLineColour
   local couldntSaveStackNames
   switch
      case pStackNames is empty
      case pStackNames is among the items of "All,Save All"
         put stack_ListEditedNames() into pStackNames
   end switch
   
   # Save them
   repeat for each line stackName in pStackNames
      try
         display_Spin stackName, pIndexView, pLineColour
      catch e
         -- not important
      end try
      --
      try
         put the effective fileName of stack stackName into pFilePath
         save stack stackName
      catch e
         put stackName & CR after couldntSaveStackNames
      end try
   end repeat
   return couldntSaveStackNames
end stack_SaveEdited

function stack_ListEditedNames pFilterHow
   put the mainstacks into stackNames
   repeat for each line stackName in stackNames   
      put revIDEStackIsEdited (stackName) into someBoolean
      switch
         case someBoolean is true
            put stackName & CR after editedStackNames
            break
         default
      end switch
   end repeat
   delete char -1 of editedStackNames
   return editedStackNames
end stack_ListEditedNames

command stack_MarkEdited stackName, pBoolean
   -- was "rev_MarkStackEdited"
   if stackName is empty then put the short name of this stack into stackName
   if pBoolean is false then
      revIDESetUnedited stackName
   else
      revIDESetEdited stackName
   end if 
   /*
   global gREVStackStatus
   
   if stackName is empty then put the short name of this stack into stackName
   if char 1 to 3 of stackName is not "rev" then
      put "edited" into gREVStackStatus [stackName]
   end if
   */
end stack_MarkEdited

command stack_MarkSaved stackName
   if stackName is empty then put the short name of this stack into stackName
   revIDESetUnedited stackName
end stack_MarkSaved


--> Old | Stack | Files
-
command stack_Rename oldName, pNewName, pDontRenameFile
   if pNewName is empty then
      put lcw_Ask ("What would you like to rename this stack to?", oldName) into pNewName
      repeat
         if exists (stack pNewName) then
            put lcw_Ask ("Stack exists. Try another name?", oldName) into pNewName
         else
            exit repeat
         end if
      end repeat
   end if
   
   -- a check
   put exists(stack oldName) and exists(stack pNewName) is false into okToRename
   if okToRename is false then
      -- should warn?
      return empty
   end if
   
   put the filename of stack oldName into oldFileName
   put oldFileName into newFileName
   put pNewName & ".rev" into newShortFile 
   set the itemdelimiter to "/"
   put newShortFile into item -1 of newFileName
   
   if pDontRenameFile is true then return oldFileName
   
   put the dataObject_Folder of stack oldName into sourceFolder
   
   ## Rename the stack
   git_RenameFile oldFileName, newFileName
   -- rename file fromFile to toFile
   set the name of stack oldName to pNewName
   set the filename of stack pNewName to newFileName
   save stack pNewName
   
   put the dataObject_Folder of stack pNewName into destFolder
   
   ## Now if there is a object script folder for this stack rename
   git_RenameFolder sourceFolder, destFolder
   
   return newFileName
end stack_Rename

command stack_Delete stackName
   if there is not a stack stackName then return merge("Error: stack '[[viewName]]' does not exist!")
   put the filename of stack stackName into someFile
   delete stack stackName
   file_Delete someFile, true
   put the result into deleteResult
   
   put the name of stack stackName into oldStack
   library_RemoveStackFromKnown oldStack
   
   return deleteResult
end stack_Delete

command stack_DeleteScriptFolder stackObject
   -- used when deleting a stack
   put the dataObject_Folder of stackObject into scriptFolder
   folder_Delete scriptFolder, true
end stack_DeleteScriptFolder

command stack_Save someObject, pClean, pCleanGeometry, pFilePath, pMacStackFileType
   put the stack_Object of someObject into stackObject
   if pFilePath is empty then put the effective fileName of stackObject into pFilePath
   if pFilePath is empty or theFilePath is "ask" then
      put the short name of stackObject into theTitle
      put ".rev" after theTitle
      ask file "Type a name for this stack and save it:" with theTitle
      put it into pFilePath
      
      if pFilePath is empty then return "cancel"
   end if
   
   if pClean is not false then
      -- cleans every object, then saves and compacts
      rev_CleanStack stackObject, pCleanGeometry
      put the result into cleanInfo
      -- lcw_Notify cleanInfo
   else
      do "compact" && stackObject
      if pMacStackFileType is empty then put "revoRSTK" into pMacStackFileType
      put the filetype into oFiletype
      set the filetype to pMacStackFileType
      lock messages
      save stackObject as pFilePath
      unlock messages
      set the filetype to oFiletype
   end if
   
   global gREVStackStatus
   put the short name of stackObject into stackName
   delete global gREVStackStatus [stackName]
   
   return empty
end stack_Save

command stack_CopyFile oldStackFile, newStackFile
   -- one way of doing it (using url's)
   -- may be the most reliable?
   -- revCopyFile longFile, opnArchiveFile (uses applescript etc)
   -- put the result
   
   put "binfile:" & oldStackFile into oldStackUrl
   put "binfile:" & newStackFile into newStackUrl
   
   put the filetype into oFileType
   set the filetype to "revoRSTK"
   put url oldStackUrl into url newStackUrl
   set the filetype to oFileType
end stack_CopyFile


--> Old | Other
-
command stack_ConvertScriptOnly stackNameOrPath
   if the scriptOnly of stack stackNameOrPath is false then
      breakpoint
      return empty
   end if
   
   put the short name of stack stackNameOrPath into oStackName
   put the script of stack stackNameOrPath into oStackScript
   put the rect of stack stackNameOrPath into oRect
   
   put the filename of stack stackNameOrPath into oFileName
   set the itemdelimiter to slash
   put item -1 of oFileName into shortFile
   put the tempname & slash into tempFolder
   folder_Createnested tempFolder
   put tempFolder & shortFile into tempFileName
   
   --
   set lockmessages to true    
   set the filename of stack oStackName to tempFileName
   put "temp_" & oStackName into tempStackName
   set the name of stack oStackName to tempStackName
   
   set the destroystack of stack tempStackName to true
   set the destroywindow of stack tempStackName to true
   save stack tempStackName
   
   create invisible stack oStackName
   set the rect of stack oStackName to oRect
   set the filename of stack oStackName to oFileName
   set the script of stack oStackName to oStackScript
   show stack oStackName
   --
   save stack oStackName
   set lockmessages to false
   
   return tempFileName
end stack_ConvertScriptOnly


--> Stack | Memory
-
command stack_CloseLoaded pDontSave
   put revLoadedStacks() into stackNames
   repeat for each line stackName in stackNames
      if pDontSave is not true then
         save stack stackName
      end if
      delete stack stackname
   end repeat
end stack_CloseLoaded


--> Stack | Revert
-
command stack_RevertLocal someObject
   breakpoint
   put the mainstack of the stack_Object of someObject into mainStackName
   stack_RevertToLocalVersion mainStackName
end stack_RevertLocal

command stack_RevertLoaded pStackNames, pLockMessages
   if pStackNames is empty then put revLoadedStacks() into pStackNames
   if pLockMessages is not false then set the lockmessages to true
   repeat for each line stackName in pStackNames
      -- if we have changed the name of the stack and not saved...
      -- the stack name of the stack on disk may differ from the one in memory
      
      put the filename of stack stackName into someFile
      put shortName into revertedArray [stackName]["old name"]
      put someFile into revertedArray [stackName]["file"]
      
      revert stack someFile
      
      put the short name of stack someFile into newName
      put newName into revertedArray [stackName]["new name"]
   end repeat
   if pLockMessages is not false then set the lockmessages to false
   return revertedArray
end stack_RevertLoaded

command stack_RevertToLocalVersion mainStackName
   breakpoint
   delete stack mainStackName
   
   put opn_GetFileName(mainStackName) into someFile
   go to stack someFile
   if the result is empty then
      return stackFile
   else
      lcw_Notify (the result & CR & someFile), true
      return empty
   end if
end stack_RevertToLocalVersion

function stack_GetIsUsed stackName
   set the wholematches to true
   put stackName is among the lines of the stacksinuse into someBoolean
   return someBoolean
end stack_GetIsUsed

command stack_SaveLoaded pDisplayObject
   breakpoint
   put revLoadedStacks ("application") into stackNames
   repeat for each line stackName in stackNames
      set the cursor to busy
      _DisplayStackSave stackName, pDisplayObject
      put the result into stackObject
      if stackObject is empty then next repeat
      
      stack_Save stackObject
   end repeat
end stack_SaveLoaded


--> Stack | Data
-
command stack_SaveBinaryData stackData, someFile
   put "binfile:" & someFile into stackUrl    
   put the filetype into oFileType
   set the filetype to "revoRSTK"
   put stackData into url stackUrl
   set the filetype to oFileType
end stack_SaveBinaryData

command stack_CreateFileFromBinaryData binaryData, newFile
   put "binfile:" & newFile into newUrl
   if the platform is "MacOs" then
      --   Note:  Revolution's creator signature is 'Revo'. The file type for a stack file created by Revolution is 'RSTK'. 
      -- The fileType is an eight-character string. The first four characters are the creator signature, and the last four are the file type. 
      
      put the filetype into oFileType
      set the filetype to "RevoRSTK"
   end if
   
   put binaryData into url newUrl
   if the platform is "MacOs" then
      set the filetype to oFileType
   end if
end stack_CreateFileFromBinaryData


--> Stack | Delete
-
command stack_DeleteFile stackObject
   put the filename of stackObject into someFile
   if there is a file someFile then
      go to stackObject 
      answer merge("Are you sure you want to delete the file [[someFile]]?") with "OK" or "Cancel" as sheet
      try
         set the stack_IsKnown of stackObject to false
         set the stack_IsLibrary ["All"] of stackObject to false
         _ClearFrontAndBackLibraries stackObject
         stack_DeleteScriptFolder stackObject
         -- hdb_DeleteStackKeys stackObject, true
         
         delete stackObject
         file_Delete someFile
      catch e
         lcw_Notify e
         answer warning merge("There was a problem deleting [[stackObject]] or file!")
      end try
   else
      lcw_Notify merge("File [[someFile]] does not exist")
      put someFile
   end if
end stack_DeleteFile


--> Private
-
private command _ClearFrontAndBackLibraries stackObject
   -- used when deleting a stack (dummy for now)
   -- should check for front and back scripts libraries withing the stack
   -- then remove from library database
end _ClearFrontAndBackLibraries

private command _DisplayStackSave stackName, pDisplayObject
   if exists(stack stackName) is false then
      lcw_Notify merge("Cannot find stack '[[stackName]]'!"), true
      return empty
   else
      put the name of stack stackName into stackObject
      if exists (pDisplayObject) then
         dispatch "display_StackSave stackObject" to pDisplayObject 
      else
         lcw_Notify merge("Saved stack '[[stackName]]'!"), false
      end if
   end if
   return stackObject
end _DisplayStackSave
