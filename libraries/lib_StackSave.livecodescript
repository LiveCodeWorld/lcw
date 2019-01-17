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
command stack_SaveRecentStacks
   put scriptEditor_ListEditingObjects() into historyObjects
   repeat for each line someObject in historyObjects
      put the stack_Object of someObject into stackObject
      put the mainstack of stackObject into mainStackName
      put stackObject into stackObjectArray [mainStackName]
   end repeat
   
   repeat for each key mainStackName in stackObjectArray
      if exists (stack mainStackName) is false then 
         next repeat
      end if
      save stack mainStackName
      lcw_Notify ("Saved stack" && mainStackName)
   end repeat
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
command stack_SaveEdited editedStackName
   global gREVStackStatus
   local couldntSaveStackNames
   
   if editedStackName is among the items of "All,Save All" then
      put stack_ListEditedNames() into stackNames
   else
      put editedStackName into stackNames
   end if
   
   repeat for each line stackName in stackNames
      set the cursor to busy
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
