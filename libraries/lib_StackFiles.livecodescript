script "lib_StackFiles"
--> MetaData
-
license: GPLv3
name: lib_StackFiles
type: script library
version: 0.8

/*
This is a library to manipulate and store stackfiles automatically.
*/

--> Working on
-
function stackFile_ConstructShortFileArray pSetName
   -- really not sure if this is useful / broken / needed
   put library_FetchStackFiles (pSetName) into stackFileTable
   repeat for each line someLine in stackFileTable
      set the itemdelimiter to comma
      put item 1 of someLine into stackName
      put item 2 of someLine into relativePath
      
      set the itemdelimiter to "/"
      put item -1 of someLine into shortFile
      
      put stackName into shortStackArray [shortFile]["stackName"]
      put relativePath into shortStackArray [shortFile]["relativePath"]
   end repeat
   return shortStackArray
end stackFile_ConstructShortFileArray

function library_FetchStackFiles pSetName
   -- see also "meta_StackArrayFile" for project level stackfile storage
   put library_FetchSetArray (pSetName) into setArray
   put setArray ["data"]["stackfiles"] into stackFileTable
   return stackFileTable
end library_FetchStackFiles


--> Stackfile | Paths
-
setprop stackFile_AddPaths someFiles
   put the stack_Object of the target into toStackObject
   stackFile_AddStackPaths someFiles, toStackObject   
   put the result into stackFileTable
   return stackFileTable
end stackFile_AddPaths

setprop stackFile_RemovePaths stackPaths
   put the stack_Object of the target into stackObject
   
   put the stackfile_Array of stackObject into stackFileArray
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then
         breakpoint
         next repeat
      end if
      put the short name of stack stackPath into stackName
      delete variable stackFileArray [stackName]
   end repeat
   set the stackfile_Array of stackObject to stackFileArray
   return stackFileArray
end stackFile_RemovePaths

setprop stackFile_AddFolder [askAdd] someFolder
   put the stack_Object of the target into stackObject
   put folder_SearchForStacks (someFolder) into bigFileIndex
   stackFile_AddStackPaths bigFileIndex, stackObject, askAdd
   put the result into stackFileTable
   return stackFileTable
end stackFile_AddFolder

command stackFile_AddStackPaths someFiles, toStackObject
   put the stackfile_Array of toStackObject into stackFileArray
   
   put the filename of toStackObject into rootFile
   put folder_Above (rootFile) into baseFolder
   stackFile_AddToArray stackFileArray, someFiles, baseFolder
   put stackFile_FromArray (stackFileArray) into stackFileTable
   
   sort stackFileTable by item 1 of each
   set the stackfiles of toStackObject to stackFileTable
   return stackFileTable
end stackFile_AddStackPaths

command stackFile_AddToArray @stackFileArray, someFiles, baseFolder
   lock messages
   put the mainstacks into oMainStacks
   set the wholematches to true
   repeat for each line newFile in someFiles
      if there is not a stack newFile then next repeat
      
      put the short name of stack newFile into newStackName
      if newStackName contains comma then
         next repeat -- need another way of dealing with this
      end if
      
      put stackFileArray [newStackName] into oldRelativeFile
      if oldRelativeFile is empty then
         put empty into oldFile
      else
         put baseFolder & oldRelativeFile into oldFile
      end if
      
      put file_GetRelativePath (newFile, baseFolder, commonPath) into newRelativeFile
      switch
         case oldRelativeFile = newRelativeFile and there is a stack oldFile
            -- do nothing, but continue and close stack if it is newly loaded
            break
         case oldFile = empty
            -- lets add it
            put newRelativeFile into stackFileArray [newStackName]
            break
         case there is not a stack oldFile
            -- it was there but must have moved / been deleted
            -- lets add it
            put newRelativeFile into stackFileArray [newStackName]
            break
         default
            -- more than one stack with the same name
            -- let's not add it to stackfile, but store info in resultArray
            put empty into resultArray ["duplicateFileArray"][newStackName][newFile]
      end switch 
      
      put the mainstack of stack newStackName into mainStackName
      if mainStackName is not among the lines of oMainStacks then
         -- close stack as it is newly loaded
         delete stack mainStackName
      end if
   end repeat
   unlock messages
   return resultArray
end stackFile_AddToArray

command stackFile_AddStackNames newStackNames, toStackObject
   put stackFile_ToArray (the stackfiles of toStackObject) into stackFileArray
   put the filename of toStackObject into rootFile	# wiil add to memory -- assume it is OK?
   put folder_Above(rootFile) into baseFolder
   lock messages
   put the mainstacks into oMainStacks
   set the wholematches to true
   repeat for each line newStackName in newStackNames
      if there is not a stack newFile then next repeat
      if newStackName contains comma then
         -- need another way of dealing with this
         next repeat
      end if
      
      put the filename of stack newStackName into newFile
      put file_GetRelativePath (newFile, baseFolder, commonPath) into newRelativeFile
      put newRelativeFile into stackFileArray [newStackName]
      
      put the mainstack of stack newStackName into mainStackName
      if mainStackName is not among the lines of oMainStacks then
         delete stack mainStackName
      end if
   end repeat
   unlock messages
   
   put stackFile_FromArray(stackFileArray) into newStackFiles
   return newStackFiles
end stackFile_AddStackNames


--> StackFile | Props
-
getprop stackfile_Names
   put the stackfiles of the target into stackfileArray
   set the columndelimiter to comma
   split stackfileArray by column
   put stackfileArray [1] into projectStackNames
   return projectStackNames
end stackfile_Names

getprop stackfile_RelativePaths
   put the stackfiles of the target into stackfileArray
   set the columndelimiter to comma
   split stackfileArray by column
   put stackfileArray [2] into projectStackNames
   return projectStackNames
end stackfile_RelativePaths

getprop stackfile_Paths
   put the stack_Object of the target into libraryStackFileStack
   put the filename of libraryStackFileStack into stackFileRoot
   put the stackfiles of libraryStackFileStack into stackFileTable
   put stackFile_ConstructFileIndex (stackFileTable, stackFileRoot) into stackPaths
   return stackPaths
end stackfile_Paths

setprop stackfile_Paths [pAskAdd] stackPaths
   put the stack_Object of the target into stackObject
   put stackFile_TableFromPaths (stackPaths, stackObject) into stackFileTable
   set the stackfiles of stackObject to stackFileTable
   return stackFileTable
end stackfile_Paths

getprop stackfile_FileArray
   -- returns an array with long not relative file names
   
   local fileNameArray
   put the stack_Object of the target into stackObject
   put the stackfiles of stackObject into stackFileTable
   put the filename of stackObject into someFile
   put folder_Above(someFile) into baseFolder
   
   repeat for each line someLine in stackFileTable
      put item 1 of someLine into stackName
      put item 2 to -1 of someLine into relativeFile
      put file_FromRelativeRoot (relativeFile, baseFolder) into someFile
      put someFile into fileNameArray [stackName]
   end repeat
   return fileNameArray
end stackfile_FileArray

getprop stackfile_Path [stackName]
   put the stack_Object of the target into stackObject
   put the stackfiles of stackObject into stackFileTable
   
   put the effective filename of stackObject into stackFileRoot
   set the itemdelimiter to slash
   delete item -1 of stackFileRoot -- no trailing slash
   
   put stackFile_ToArray (stackFileTable) into stackFileArray
   put stackfileArray [stackName] into relPath
   if relPath begins with stackFileRoot then return relPath
   
   put stackFileRoot & relPath into stackfilePath
   if exists (stack stackfilePath) then
      return stackfilePath
   else
      return empty
   end if
end stackfile_Path

getprop stackfile_RelativePath [stackName]
   put the stackfile_Array of the target into stackfileArray
   put stackfileArray [stackName] into relativePath
   return relativePath
end stackfile_RelativePath

getprop stackfile_Array
   put the stack_Object of the target into someStack
   put the stackfiles of someStack into stackFileTable
   put stackFile_ToArray (stackFileTable) into stackFileArray
   return stackFileArray
end stackfile_Array

setprop stackfile_Array stackFileArray
   put the stack_Object of the target into someStack
   put stackFile_FromArray (stackFileArray) into stackFileTable
   sort stackFileTable by item 1 of each
   set the stackfiles of someStack to stackFileTable
   return stackFileTable
end stackfile_Array

getprop stackFile_ErrorArray
   put the stack_Object of the target into stackFileStack
   
   put the stackfile_Array of stackFileStack into stackFileArray  
   put the filename of stackFileStack into someRoot
   set the itemdelimiter to "/"
   
   lock messages
   put the mainstacks into oMainStacks
   set the wholematches to true
   repeat for each key stackName in stackFileArray
      put stackFileArray [stackName] into relativeFile
      put someRoot into someFile
      put relativeFile into item -1 of someFile
      
      if there is not a stack someFile then
         -- if there is not a file someFile then -- not sure if non-stacks can be in the stackfiles ?
         delete local stackFileArray [stackName]
         put empty into badArray [stackName][someFile]
      else
         put the mainstack of stack someFile into mainStackName
         if mainStackName is not among the lines of oMainStacks then
            delete stack mainStackName
         end if
      end if
   end repeat
   unlock messages
   
   put stackFileArray into resultArray ["fixedStackFileArray"]
   put badArray into resultArray ["badArray"]
   return resultArray
end stackFile_ErrorArray


--> StackFile | Fix
-
command stackFile_FixStackFiles stackFileStack
   put the stackFile_ErrorArray of stackFileStack into resultArray
   put resultArray ["fixedStackFileArray"] into stackFileArray
   put resultArray ["badArray"] into badArray
   
   set the stackfile_Array of stackFileStack to stackFileArray
   put the result into stackFileTable
   put stackFileTable into resultArray ["stackFileTable"]
   return resultArray
end stackFile_FixStackFiles


--> StackFile | Array
-
function stackFile_GetRelativeArray stackName
   put the stackfiles of stack stackName into stackFileTable
   put stackFile_ToArray (stackFileTable) into stackNameDictionary
   put array_Reverse (stackNameDictionary) into relativeFileDictionary
   return relativeFileDictionary
end stackFile_GetRelativeArray

function stackFile_ToArray stackFileTable
   split stackFileTable by CR and comma
   return stackFileTable
end stackFile_ToArray

function stackFile_FromArray stackFileArray
   combine stackFileArray using CR and comma
   sort stackFileArray
   return stackFileArray
end stackFile_FromArray

function stackfile_ConvertArray oldStackObject, newStackObject
   put the filename of newStackObject into baseStackFile
   put folder_Above (baseStackFile) into baseFolder
   
   put the stackfile_FileArray of oldStackObject into someArray
   repeat for each key someKey in someArray
      put someArray [ someKey] into someFile
      put file_GetRelativePath (someFile, baseFolder, commonPath) into relativePath
      put relativePath into newArray [ someKey] 
   end repeat
   return newArray
end stackfile_ConvertArray


--> Stackfile | Shorfiles
-
function stackfile_FilterShortFilesForKnown shortFileIndex, pSetName
   local shortStackArray, filteredStackNameArray
   stackFile_DeconstructShortFileIndex shortFileIndex, shortStackArray, filteredStackNameArray, filteredShortStackArray, pSetName
   return keys (filteredShortStackArray)
end stackfile_FilterShortFilesForKnown

function stackfile_FilterStackNamesForKnown shortFileIndex, pSetName
    return stackFile_NamesFromShortFiles (shortFileIndex, pSetName)
end stackfile_FilterStackNamesForKnown

function stackFile_ContainsShortFile shortFile
   put stackFile_NameFromShortFile (shortFile) into stackName
   return stackName is not empty
end stackFile_ContainsShortFile

function stackFile_NameFromShortFile shortFile, pSetName
   put stackFile_ConstructShortFileArray (pSetName) into shortStackArray
   return shortStackArray [shortFile]["stackName"]
end stackFile_NameFromShortFile

function stackFile_NamesFromShortFiles shortFileIndex, pSetName
   local shortStackArray, filteredStackNameArray
   stackFile_DeconstructShortFileIndex shortFileIndex, shortStackArray, filteredStackNameArray, filteredShortStackArray, pSetName
   return keys (filteredStackNameArray)
end stackFile_NamesFromShortFiles

function stackFile_PathFromShortFile shortFile, pSetName
   put stackFile_ConstructShortFileArray (pSetName) into shortStackArray
   return shortStackArray [shortFile]["relativePath"]
end stackFile_PathFromShortFile

function stackFile_PathsFromShortFiles shortFileIndex, pSetName
   local shortStackArray, filteredStackNameArray
   stackFile_DeconstructShortFileIndex shortFileIndex, shortStackArray, filteredStackNameArray, filteredShortStackArray, pSetName
   return keys (filteredStackNameArray)
end stackFile_PathsFromShortFiles

command stackFile_DeconstructShortFileIndex shortFileIndex, @shortStackArray, @filteredStackNameArray, @filteredShortStackArray, pSetName
   put stackFile_ConstructShortFileArray (pSetName) into shortStackArray
   repeat for each line shortFile in shortFileIndex
      put shortStackArray [shortFile]["stackName"] into stackName
      put shortStackArray [shortFile]["relativePath"] into relativePath
      if stackName is not empty then
         put relativePath into filteredStackNameArray [stackName]
         put relativePath into filteredShortStackArray [shortFile]
      end if
   end repeat
end stackFile_DeconstructShortFileIndex


--> Stackfile | Utils
-
function stackFile_TableFromPaths someFiles, homeStackObject
   local stackFileArray
   put the filename of homeStackObject into rootFile
   put folder_Above (rootFile) into baseFolder
   stackFile_AddToArray stackFileArray, someFiles, baseFolder
   put stackFile_FromArray (stackFileArray) into stackFileTable
   sort stackFileTable by item 1 of each
   return stackFileTable
end stackFile_TableFromPaths

function stackFile_GetRelativeFileIndex stackName
   put stackFile_GetRelativeArray (stackName) into relativeFileDictionary
   return keys (relativeFileDictionary)
end stackFile_GetRelativeFileIndex

function stackFile_GetStackNameIndex stackName
   -- was "getLinked_StackNames"
   put the stackfiles of stack stackName into stackFileTable
   put stackFile_ToArray (stackFileTable) into stackNameDictionary
   return keys (stackNameDictionary)
end stackFile_GetStackNameIndex

function stackFile_ConstructFileIndex stackFileTable, stackFile
   -- was fileIndex_FromStackFiles
   put folder_Above (stackFile) into stackRoot
   -- add the stack as the stackFiles may not be linked to itself (unless there are substacks)
   -- bit odd to do this generally?
   put stackFile into longFileNames
   repeat for each line stackFileLine in stackFileTable
      delete item 1 of stackFileLine
      put file_FromRelativeRoot (stackFileLine, stackRoot) into newLine
      if newLine is not among the lines of longFileNames then
         put return & newLine after longFileNames
      end if
   end repeat
   return longFileNames
end stackFile_ConstructFileIndex
