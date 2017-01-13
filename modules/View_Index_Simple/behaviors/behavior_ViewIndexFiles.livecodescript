script "behavior_ViewIndexFiles"
--> MetaData
-
license: GPLv3
name: behavior_ViewIndexFiles
type: behavior
version: 0.1

/*
An additional behavior to add fetures to "behavior_ViewIndexSimple"
*/


--> ViewIndex | Files
-
getprop selected_ShortStackFiles
   put the selected_Index of me into shortStackFiles 
   return shortStackFiles
end selected_ShortStackFiles

getprop selected_StackObjects
   put the selected_ShortStackFiles of me into shortStackFiles  
   put _getStackObjects (shortStackFiles) into stackObjects
   return stackObjects
end selected_StackObjects

getprop selected_StackNames
   put the selected_ShortStackFiles of me into shortStackFiles  
   put _getStackNames (shortStackFiles) into stackNames
   return stackNames
end selected_StackNames

getprop selected_LongStackFiles
   put the selected_ShortStackFiles of me into shortStackFiles  
   put _getLongStackFiles (shortStackFiles) into longStackFiles
   return longStackFiles
end selected_LongStackFiles

getprop index_StackObjects
   put the index_ShortFiles of me into shortStackFiles  
   put _getStackObjects (shortStackFiles) into stackObjects
   return stackObjects
end index_StackObjects

getprop index_StackNames
   put the index_ShortFiles of me into shortStackFiles  
   put _getStackNames (shortStackFiles) into stackNames
   return stackNames
end index_StackNames

getprop index_LongStackFiles
   put the index_ShortFiles of me into shortStackFiles  
   put _getLongStackFiles (shortStackFiles) into longStackFiles
   return longStackFiles
end index_LongStackFiles

getprop index_ShortStackFiles
   breakpoint
   return the index_ShortFiles of me
end index_ShortStackFiles

getprop index_ShortFiles
   put the view_Index of me into shortStackFiles  
   return shortStackFiles
end index_ShortFiles

getprop index_Files
   put the view_Index of me into shortStackFiles
   put _getLongFiles (shortFiles) into longFiles
   return longFiles
end index_Files

getprop index_Folder
   put LocalArray ["index_Folder"] into indexFolder
   return indexFolder 
end index_Folder

setprop index_Folder indexFolder
   text_AddTrailing indexFolder, slash
   put indexFolder into LocalArray ["index_Folder"]
end index_Folder


--> Private | Files
-
private function _getLongFiles shortFiles
   put the index_Folder of me into indexFolder  
   repeat for each line shortFile in shortFiles
      put indexFolder & shortFile into longFile
      put longFile & CR after longFiles
   end repeat
   delete char -1 of longFiles
   return longFiles
end _getLongFiles

private function known_StackNames shortStackFiles
   put stackFile_NamesFromShortFiles (shortStackFiles) into stackNames
   return stackNames
end known_StackNames

private function known_StackObjects shortStackFiles
   put stackFile_NamesFromShortFiles (shortStackFiles) into stackNames
   repeat for each line stackName in stackNames
      if exists (stack stackName) then
         put the name of stack stackName into stackObject
         put stackObject & CR after stackObjects
      end if
   end repeat
   delete char -1 of stackObjects
   return stackObjects
end known_StackObjects

private function _getStackObjects shortStackFiles
   put the index_Folder of me into indexFolder 
   if indexFolder is empty then
      -- let's assume the stacks are known
      put known_StackObjects (shortStackFiles) into stackObjects
   else 
      repeat for each line shortStackFile in shortStackFiles
         put indexFolder & shortStackFile into longStackFile
         if exists (stack longStackFile) then
            put the name of stack longStackFile into stackObject
            put stackObject & CR after stackObjects
         end if
      end repeat
      delete char -1 of stackObjects
   end if
   return stackObjects
end _getStackObjects

private function _getStackNames shortStackFiles
   put the index_Folder of me into indexFolder  
   if indexFolder is empty then
      -- let's assume the stacks are known
      put stackFile_NamesFromShortFiles (shortStackFiles) into stackNames
   else 
      repeat for each line shortStackFile in shortStackFiles
         put indexFolder & shortStackFile into longStackFile
         if exists (stack longStackFile) then
            put the short name of stack longStackFile into stackName
            put stackName & CR after stackNames
         end if
      end repeat
      delete char -1 of stackNames
   end if
   return stackNames
end _getStackNames

private function _getLongStackFiles shortStackFiles
   put the index_Folder of me into indexFolder  
   if indexFolder is empty then
      -- let's assume the stacks are known
      put stackFile_PathsFromShortFiles (shortStackFiles) into stackPaths
      return stackPaths
   else 
      repeat for each line shortStackFile in shortStackFiles
         put indexFolder & shortStackFile into longStackFile
         if exists (stack longStackFile) then 
            put longStackFile & CR after longStackFiles
         end if
      end repeat
      delete char -1 of longStackFiles
      return longStackFiles
   end if
end _getLongStackFiles


--> Deps
-
command text_AddTrailing @someText, someChar
   if char -1 of someText is not someChar then
      put someChar after someText
   end if
end text_AddTrailing
