script "lib_Files"
--> MetaData
-
license: GPLv3
name: lib_Files
type: script library
copyright: David Bovill
license: GPLv3
version: 0.6


--> Currently Working On
-
function file_StripExtension shortFiles
   set the columndelimiter to "."
   split shortFiles by column
   put shortFiles [1] into shortFileNames
   sort shortFileNames
   return shortFileNames
end file_StripExtension

command folder_Format @someFolder
   text_AddTrailing someFolder, slash
end folder_Format

function file_ShortNameArray someFiles
   set the itemdelimiter to slash
   repeat for each line someFile in someFiles
      put someFile into shortNameArray [item -1 of someFile]
   end repeat
   return shortNameArray
end file_ShortNameArray


--> File | List | Paths
-
/*
Thinking of renaming thes to "path_***" when handlers return long file paths
*/

function path_ListLong someFolder, pShowInvisible, pSomeFilter
   if there is not a folder someFolder then return empty
   put files (someFolder) into shortFiles
   put file_AddFolderToPaths (shortFiles, someFolder, pShowInvisible, pSomeFilter) into filePaths
   return filePaths
end path_ListLong

function file_AddFolderToPaths shortFiles, someFolder, pShowInvisible
   if pShowInvisible is not true then filter shortFiles without ".*"
   text_AddTrailing someFolder, slash
   repeat for each line shortFile in shortFiles
      put someFolder & shortFile & CR after filePaths
   end repeat
   delete last char of filePaths
   return filePaths
end file_AddFolderToPaths


--> File | List | Short
-
/*
These all do the same thing and should be reconciled
*/

function file_ListShort someFolder, pShowInvisible
   if there is not a folder someFolder then return empty
   put files (someFolder) into shortFiles
   if pShowInvisible is not true then filter shortFiles without ".*"
   return shortFiles
end file_ListShort

function folder_ListShortFiles someFolder, pShowInvisible
   return file_ListShort (someFolder, pShowInvisible)
end folder_ListShortFiles

function folder_ShortFiles someFolder
   return file_ListShort (someFolder)
end folder_ShortFiles


--> File | List | Utils
-
command file_SetRelativePath @filePath, baseFolder
   if baseFolder is empty then put folder_Above (the filename of this stack) into baseFolder
   put file_GetRelativePath (filePath, baseFolder, commonPath) into filePath
   return commonPath
end file_SetRelativePath

function file_LongToShort someFile
    -- was "file_ExtractShortFile" "extract_ShortFile"
    file_SetPath someFile, someFolder, shortFile
    return shortFile
end file_LongToShort

command file_ShortToLong @shortFiles, someFolder, pShowInvisible, pSomeFilter
   put file_AddFolderToPaths (shortFiles, someFolder, pShowInvisible, pSomeFilter) into filePaths
   put filePaths into shortFiles
end file_ShortToLong
  
private function file_LinesToNames fileInfo
   put file_LinesToArray (fileInfo) into fileArray
   put keys (fileArray) into fileNames
   return fileNames
end file_LinesToNames

private function file_LinesToArray fileInfo
   repeat for each line fileLine in fileInfo
      put item 1 of fileLine into fName 
      -- put urldecode (item 1 of fileLine) into fName 
      put item 2 of fileLine into fSize
      put fSize into fileArray [fName]["fSize"]
   end repeat
   return fileArray
end file_LinesToArray

private command file_DeconstructLine fileLine, @fName, @fSize
   -- not really used right now
   put item 1 of fileLine into fName -- The file name is URL-encoded. To obtain the name as plain text, use the function.
   put item 2 of fileLine into fSize -- in bytes. On OS X systems, this is the size of the data fork.
   
   /*
   put item 3 of fileLine into fResource -- fork size, in bytes. (OS X only).
   put item 4 of fileLine into fCreationDate -- , in seconds. (OS X and Windows only).
   put item 5 of fileLine into fLastModied --  date, in seconds.
   put item 6 of fileLine into fLastAccess --  date, in seconds.
   put item 7 of fileLine into fLastBackup --  date, in seconds.
   put item 8 of fileLine into fUser --  owner. (Linux and OS X only).
   put item 9 of fileLine into fGroup --  owner. (Linux and OS X only).
   put item 10 of fileLine into fPermissions -- . (Linux and OS X only; see note).
   put item 11 of fileLine into fCreator --  and file type. (OS X only)
   */
end file_DeconstructLine


--> File | List | Paths | Old
-
function folder_ListFiles someFolder, pShowInvisible, pSomeFilter
   return path_ListLong (someFolder, pShowInvisible, pSomeFilter)
end folder_ListFiles

function folder_FilesInside pFolder, pFilter, pQuestion, pShowInvisible
   -- see "folder_ListFiles"
   if pFolder is empty then
      if pQuestion is empty then put "Select a folder..." into pQuestion
      answer folder pQuestion
      put it into pFolder
      if it is empty then return "Error: user cancelled"
   end if
   
   if last char of pFolder is "/" then delete last char of pFolder
   if there is a folder pFolder then
      put the directory into oDirectory
      set the directory to pFolder
      put the files into longFiles
      file_ShortToLong longFiles, pFolder, pShowInvisible, pFilter
      set the directory to oDirectory
      return word 1 to -1 of longFiles
   else
      return empty
   end if
end folder_FilesInside


--> File | List | Stacks
-
/*
Should be renamed "file_***" as the return files, or stack fie info.
*/

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


--> Folder | List
-
/*
These handlers return folders.
*/

function folder_ListShort rootFolder
   -- rename as we tend to imagine this to be for files not folders
   if there is not a folder rootFolder then return empty
   
   put the defaultfolder into oDefault
   set the defaultfolder to rootFolder
   put the folders into shortFolders
   set the defaultfolder to oDefault
   
   -- delete line 1 of shortFolders
   filter shortFolders without ".*"
   return shortFolders
end folder_ListShort

function folder_ListLong someFolder
   if there is not a folder someFolder then return empty
   text_AddTrailing someFolder, slash
   
   put folders (someFolder) into shortFolders
   repeat for each line shortFolder in shortFolders
      if char 1 of shortFolder = "." then next repeat
      put someFolder & shortFolder & slash & CR after longSubFolders
   end repeat
   delete char -1 of longSubFolders
   return longSubFolders
end folder_ListLong

function folder_GetSister shortFolder, someFileOrFolder
   set the itemdelimiter to slash
   if char -1 of someFileOrFolder = slash then
      put shortFolder into item -1 of someFileOrFolder
   else
      put shortFolder into item -2 to -1 of someFileOrFolder
   end if
   put someFileOrFolder & slash into sisterFolder
   return sisterFolder
end folder_GetSister


--> File | Relative
-
function file_GetRelativePath someFileOrFolder, baseFolder, @commonPath
   put the itemdelimiter into originalDelim
   set the itemdelimiter to "/"
   put empty into commonPath
   put someFileOrFolder into relativePath
   put 0 into itemNum
   repeat with itemNum = 1 to the number of items of baseFolder
      put item itemNum of baseFolder into basePathComponent
      put item itemNum of someFileOrFolder into somePathComponent
      
      if somePathComponent is basePathComponent then
         next repeat
      else
         subtract 1 from itemNum
         exit repeat
      end if
   end repeat
   
   put item 1 to itemNum of someFileOrFolder into commonPath
   delete item 1 to itemNum of relativePath
   
   delete item 1 to itemNum of baseFolder
   put the number of items of baseFolder into upBits
   repeat upBits
      put "../" before relativePath
   end repeat
   
   set the itemdelimiter to originalDelim
   put "/" after commonpath
   return relativePath
end file_GetRelativePath

function file_FromRelativeRoot relativeFile, relativeRoot
   -- was "getFile_FromRelativeRoot"
   if last char of relativeRoot is "/" then delete last char of relativeRoot -- it is :)
   put the itemdelimiter into oDelim
   set the itemdelimiter to "/"
   repeat while item 1 of relativeFile is ".."
      delete item 1 of relativeFile
      delete last item of relativeRoot
   end repeat
   set the itemdelimiter to oDelim
   return relativeRoot & "/" & relativeFile
end file_FromRelativeRoot

function folder_Above fileOrFolder
   set the itemdelimiter to "/"
   if char -1 of fileOrFolder is "/" then delete char -1 of fileOrFolder
   delete last item of fileOrFolder
   if fileOrFolder is empty then 
      return "."
   else
      return fileOrFolder & "/"
   end if
end folder_Above

command folder_CreateFromFile someFile
   put someFile into someFolder
   set the itemdelimiter to slash
   put empty into item -1 of someFolder
   folder_CreateNested someFolder
   return someFolder
end folder_CreateFromFile

command folder_CreateNested @someFolder
   text_AddTrailing someFolder, slash
   if there is a folder someFolder then return empty
   set the itemdelimiter to "/"
   repeat with itemNum = 1 to the number of items of someFolder
      put item 1 to itemNum of someFolder & "/" into testFolder
      if there is a folder testFolder then next repeat
      create folder testFolder
   end repeat
end folder_CreateNested


--> Files
-
function file_ConstructFolderArray filePaths, pFilter, pStripRootFolder
   if pStripRootFolder is not empty then
      text_AddTrailing pStripRootFolder, slash
      replace pStripRootFolder with empty in filePaths
   end if
   if pFilter is not empty then filter filePaths with pFilter -- not needed as it's in repeat loop below
   
   repeat for each line somePath in filePaths
      put somePath into someKey
      split someKey with "/"
      put somePath into pathArray [someKey]
   end repeat
   return pathArray
end file_ConstructFolderArray

function file_GetType filePath
   switch the platform 
      case "MacOS"
         --get file_DetailedInfo (filePath)
         -- put item 11 of it into fType
         put spotlight_Kind (filePath) into fType
         return word -1 of fType
      case "Win32"
         put offset(".",filePath) into tChar
         if tChar <> 0 then
            put char tChar to length(filePath) of filePath into text
            put queryregistry("HKEY_CLASSES_ROOT\"&(queryregistry("HKEY_CLASSES_ROOT\"&tExt& "\")) & "\") into tType
         else
            put "" into tType
            put "" into text
         end if
         if tType = "" then
            if text <> "" then
               delete char 1 of text  -- remove "."
               put toupper(tExt) && "File" into tType
            else
               put "File" into tType
            end if
         end if
         return filePath & numtochar(9) & tType
      default
         return empty
   end switch
end file_GetType

function file_IsAlias someFile
    put the aliasreference of someFile into testAlias
    return someFile is not testAlias or testAlias is empty
end file_IsAlias

function file_ExtensionFromRevFormat dataType
    -- was "revDataFormat_ToExtension"
    switch dataType
        case "rtf"
            return "rtfText"
        case "htm"
            return "htmlText"
        case "html"
            return "htmlText"
        default
            return "text"
    end switch
end file_ExtensionFromRevFormat

function file_ExtensionToRevFormat someExtension
    switch someExtension
        case "rtf"
            return "rtfText"
        case "htm"
            return "htmlText"
        case "html"
            return "htmlText"
        default
            return "text"
    end switch
end file_ExtensionToRevFormat

command file_SetPath someFile, @someFolder, @shortFile
    set the itemdelimiter to "/"
    put item 1 to -2 of someFile into someFolder
    put item -1 of someFile into shortFile
end file_SetPath

function file_ConstructSafeName someName, someExtension
    -- was "construct_SafeFileName"
    put wiki_ConstructID(someName) into sname
    if someExtension is not empty then put "." & someExtension after sname
    return sname
     
    -- lifted from "Metacard Menu Bar" stack script for compatibility
    -- <renamed frome="MCfixpath shortname"/>
    put tolower(someName) into sname
    if someExtension is not empty then put "." & someExtension after sname
    repeat with c = 1 to the length of sname
        if char c of sname is in " :?*<>/\()[]{}|'`" & quote & tab
        then put "_" into char c of sname
    end repeat
    return sname
end file_ConstructSafeName

function file_FixNasPath filePath
    put file_SafeNameReg() into someReg
    return replacetext(filePath, someReg,"_")
end file_FixNasPath

function file_PathIsSafe filePath, maxLength
    if maxLength is empty then 
        -- put 28 into maxLength
        put 255 into maxLength
    end if
    
    set the itemdelimiter to "/"
    put file_SafeNameReg() into someReg
    repeat for each item testItem in filePath
        if the number of chars of testItem > maxLength then
            return false
        else if matchtext(testItem, someReg) then
            return false
        end if
    end repeat
    return true
end file_PathIsSafe

function file_SafeNameReg
    put "[:/?<>/|/*" & quote into someReg
    
    -- how do you escape "\" ???
    -- put "\" after someReg
    -- put "/\" after someReg
    
    put "]" after someReg
    return someReg
end file_SafeNameReg

function file_IndexToOutline filePaths, pType
   switch pType
      case "outline"
         put outline_FromPathIndex (filePaths, "/", true) into someOutline
         return someOutline
         break
      default
         set the itemdelimiter to "/"
         repeat for each line filePath in filePaths
            put the last item of filePath into someText
            put html_ConstructNameLink(someText, filePath) & CR after someOutline
         end repeat
         delete last char of someOutline
         return someOutline
   end switch
end file_IndexToOutline

function file_ExtractFileSuffix filePath
    -- was "extract_FileSuffix"
    put file_LongToShort(filePath) into shortFile
    if shortFile contains "." then
        put the itemdelimiter into oDelim
        set the itemdelimiter to "."
        put last item of shortFile into someSuffix
        set the itemdelimiter to oDelim
        return someSuffix
    else
        return empty
    end if
end file_ExtractFileSuffix

command file_UrlEncode @someFile
    set the itemdelimiter to "/"
    repeat with itemNum = 1 to the number of items of someFile
        put item itemNum of someFile into pathItem
        -- replace "|" with "%7C" in pathItem
        put urlencode(pathItem) into pathItem
        replace "+" with "%20" in pathItem
        put pathItem into item itemNum of someFile
    end repeat
end file_UrlEncode

function file_FromRelativeRoot relativeFile, relativeRoot
    -- was "getFile_FromRelativeRoot"
    if last char of relativeRoot is "/" then delete last char of relativeRoot -- it is :)
    put the itemdelimiter into oDelim
    set the itemdelimiter to "/"
    repeat while item 1 of relativeFile is ".."
        delete item 1 of relativeFile
        delete last item of relativeRoot
    end repeat
    set the itemdelimiter to oDelim
    return relativeRoot & "/" & relativeFile
end file_FromRelativeRoot

function file_DetailedInfo filePath
   if filePath is empty then return empty
   put filePath into someDirectory
   if there is a file filePath then
      set the itemdelimiter to "/"
      put last item of filePath into shortFileName
      delete last item of someDirectory
      
      put the directory into oDirectory
      set the directory to someDirectory
      put the detailed files into detailedFileTable     
      set the directory to oDirectory
      
      put urlencode(shortFileName) into shortFileName -- seems to need it again???
      filter detailedFileTable with (shortFileName & ",*")
      return detailedFileTable
   else if there is a folder filePath then
      put the directory into oDirectory
      set the directory to someDirectory
      put the detailed files into detailedFileTable     
      set the directory to oDirectory
      return detailedFileTable
   else
      return empty
   end if
end file_DetailedInfo

function file_GetSize filePath
   get file_DetailedInfo (filePath)
   return item 2 of it
end file_GetSize

function file_LastModifed filePath
    -- version original,27/12/02
    return item 5 of file_DetailedInfo(filePath)
end file_LastModifed

function file_CreatorAndType filePath
    -- only useful on MacOS
    get file_DetailedInfo(filePath)
    return item 11 of it
end file_CreatorAndType

function file_GetMostRecent fileNames
    -- version original,27/12/02
    -- <scott> Would be nice to have "detailed fileName property modifier" </scott>
    set the itemdelimiter to "/"
    repeat for each line filePath in fileNames
        get file_LastModifed(filePath)
        put filePath & "," & it & return after fileTable
    end repeat
    delete last char of fileTable
    set the itemdelimiter to ","
    sort lines of fileTable numeric descending by item 2 of each
    put urldecode(item 1 of line 1 of fileTable) into filePath
    return filePath
end file_GetMostRecent


--> File | Change
-
command file_Copy filePath, newFile, isText	# if the file exists it does not copy anything???
    -- rename file filePath to newFile
     
    if isText is false then	# does not copy fileTypes and resources / bundles.
        put url ("binfile:" & filePath) into binaryData
        file_CreateBinary binaryData, newFile
    else
        put url ("file:" & filePath) into someText
        file_CreateText someText, filePath
    end if
end file_Copy
 
command file_CreateImage someImage, imageFile
    put image_FileTypeFromPath(imageFile) into someFileType
    file_CreateBinary someImage, imageFile, someFileType
    return the result
end file_CreateImage

command file_CreateText someText, pFile
   if pFile is empty then
      put the tempname into pFile
   end if
   put folder_Above (pFile) into someFolder
   folder_CreateNested someFolder
   put someText into url ("file:" & pFile)
   return pFile
end file_CreateText

command file_CreateBinary binaryData, filePath, someFileType
    if filePath is empty then return the script_Error ["No such file"] of me
    put folder_Above(filePath) into someFolder
    folder_CreateNested someFolder
     
    put there is a file filePath into fileExists
    if someFileType is not empty then
        put the filetype into oFileType
        set the filetype to someFileType
    end if
    put binaryData into url ("binfile:" & filePath)
    if someFileType is not empty then
        set the filetype to oFileType
    end if
    if fileExists is false then
        if file_IsVersioned (filePath) then
            svn_Add filePath
        end if
    end if
end file_CreateBinary


--> File | Standard Paths
-
command file_ReplaceHome @fileOrFolder
   if fileOrFolder begins with $HOME then
      set the itemdelimiter to "/"
      put the number of items of $HOME into itemNum
      put "~" into item 1 to itemNum of fileOrFolder
   end if
end file_ReplaceHome

command file_SetHomeRelative @longFile
    put $HOME into myHome
    put the number of chars of myHome into maxNum
    if char 1 to maxNum of longFile is myHome then
        put "~" into char 1 to maxNum of longFile
    end if
end file_SetHomeRelative


--> File | Hashes
-
function file_HashName someText, pFolder, pExtension
   if pExtension is empty then put "txt" into pExtension
   if pFolder is empty then put file_TemporaryFolder() into pFolder
   text_AddTrailing pFolder, slash
   put text_Hash (someText) into hashName
   put pFolder & hashName & "." & pExtension into someFile
   return someFile
end file_HashName

function file_TemporaryFolder
   put the the tempname into tempFolder
   set the itemdelimiter to "/"
   delete item -1 of tempFolder
   return tempFolder & "/"
end file_TemporaryFolder

function file_FastHashGuess filePath
    -- for now just uses short file
    -- thought is that if you name the file "hash_SomeHash"
    -- then can use fileName except for the first time
    -- when you need to run md5 command line tool over it.
     
    deconstruct_File filePath, someFolder, shortName, someExtension
    return shortName
    put extract_ShortFile(filePath) into shortFile
    return shortFile
     
    -- get binaryEncode("H*", someBinaryData, tHexDigest)
    put the number of chars of shortFile into howLong
    if howLong > 20 then
        return shortFile
    else
        put file_Md5Hash(filePath) into hashFile
        -- rename file?
        return hashFile
    end if
end file_FastHashGuess

function file_Md5Hash filePath
    put file_GetSize(filePath) into someSize
    if someSize > 200000000 then
        breakpoint
        return shell_Md5Hash(filePath)
    else
        put url ("binfile:" & filePath) into someData
        return text_Hash(someData)
    end if
end file_Md5Hash

function file_SafeHashName filePath
    -- need to check. Not tested
    set the cursor to watch
    deconstruct_File filePath, someFolder, shortName, someExtension
    put line 1 of shell_Md5Hash(filePath) into tHexDigest
    -- get binaryDecode("H*", someBinaryData, tHexDigest)
    put "hash_" & tHexDigest into hashName
    put someFolder & "/" & hashName into hashFile
    if someExtension is not empty then put "." & someExtension after hashFile
    return hashFile
end file_SafeHashName

function file_IsHashName filePath
    -- need to check. Not tested
    deconstruct_File filePath, someFolder, shortName, someExtension
    if char 1 to 5 of shortName is "hash_" then
        put shortName into tHexDigest
        delete char 1 to 5 of tHexDigest
        put binaryencode("H*", tHexDigest) into someBinaryData
        if the number of chars of someBinaryData = 16 then
            return true
        else
            return false
        end if
    else
        return false
    end if
end file_IsHashName

function file_CheckHashName filePath
    -- need to check. Not tested
    deconstruct_File filePath, someFolder, shortName, someExtension
    put file_SafeHashName(filePath, someExtension) into realHashName
    put shortName into shortFile
    if someExtension is not empty then put "." & someExtension after shortFile
    if realHashName is shortFile then
        return true
    else
        return false
    end if
end file_CheckHashName


--> File | Choose
-
function file_ChooseImage preferredFolder, anyFile, someType, comment
    -- was "ask_ImageFile" (param order changed)
    
    if comment is empty then put "Select an image..." into comment
     
    if anyFile is true then
        put file_ChooseAny(preferredFolder, comment) into imageFile
        -- now could do a check to see if it is an image?
    else if the platform is "MacOs" then
        put _askMacImage(someType, preferredFolder, comment) into imageFile
    else if the platform is "Linux" then
        put _askLinuxImage(someType, preferredFolder, comment) into imageFile
    else
        put _askWindowsImage(someType, preferredFolder, comment) into imageFile
    end if
     
    if imageFile is empty then
        exit to top
    else
        return imageFile
    end if
end file_ChooseImage

function file_ChooseAny preferredFolder, comment
    if comment is empty then put "Select a file..." into comment
    answer file comment with preferredFolder
    if the result is "Cancel" then exit to top
    return it
end file_ChooseAny

function file_ChooseStack comment
    -- was "askStack"
    
    if comment is empty then put "Select a stack..." into comment
    if the platform is "MacOS" then
        answer file comment of type "MSTK"
    else if the platform is "Linux" then
        answer file comment with filter "*.mc"
    else if the platform is "Windows" then
    else
    end if
    put line 1 of it into longStackName
    return longStackName
end file_ChooseStack

function _askLinuxImage someType, preferredFolder, comment
    if someType is empty then put _getLinuxImageTypes() into someType
    
    answer file comment with preferredFolder with filter someType
    if the result is "Cancel" then exit to top
    return it
end _askLinuxImage

function _askMacImage someType, preferredFolder, comment
    if someType is empty then put _getMacImageTypes() into someType
    if preferredFolder is empty then
        answer file comment of type someType titled "Choose an Image"
    else
        answer file comment with preferredFolder of type someType titled "Choose an Image"
    end if
    put it into filePath
    if filePath is empty then
        exit to top
    else
        return filePath
    end if
end _askMacImage

function _askWindowsImage someType, preferredFolder, comment
    if someType is empty then put _getWindowsImageTypes() into someType
    if preferredFolder is empty then
        answer file comment with filter someType
    else
        answer file comment with preferredFolder with filter someType
    end if
    put it into filePath
    if filePath is empty then
        exit to top
    else
        return filePath
    end if
end _askWindowsImage

function _getMacImageTypes
    -- there are others like PBM...
    return "JPEGPNGfGIFfPICTBMP "
end _getMacImageTypes

function _getLinuxImageTypes
    -- there are others like PBM...
    return "*.jpg"
end _getLinuxImageTypes
 
function _getWindowsImageTypes
    return "Images (*.jpg,*.gif,*.png),*.jpg,*.gif,*.png"
end _getWindowsImageTypes


--> Folder
-
function folder_GetSize folderPath
   get folder_DetailedInfo (folderPath)
   put item 2 of it into someSize
   if someSize is empty then return 0
   return someSize
end folder_GetSize

function folder_DetailedInfo folderPath
   put the directory into oDirectory
   set the directory to folderPath
   get the detailed folders
   set the directory to oDirectory
   
   return it
end folder_DetailedInfo

function folder_GetDocuments
    if the platform is "MacOS" then
        if the systemversion >=10 then
            return specialfolderpath("docs") & "/"
        else
            return specialfolderpath("Desktop") & "/"	# somewhere better?
        end if
    else if the platform is "Win32" then
        /*
        CSIDL_MYDOCUMENTS (0x000c)
        version 6.0. The virtual folder representing the My Documents desktop item.
        return specialfolderpath(baseconvert("0x000c",16,10))
        */
        return specialfolderpath("Documents") & "/"
    else
        return $HOME & "/Documents/"	# somewhere better?
    end if
end folder_GetDocuments

command folder_CreateNested @someFolder
   text_AddTrailing someFolder, slash
   if there is a folder someFolder then return empty
   set the itemdelimiter to "/"
   repeat with itemNum = 1 to the number of items of someFolder
      put item 1 to itemNum of someFolder & "/" into testFolder
      if there is a folder testFolder then next repeat
      create folder testFolder
   end repeat
end folder_CreateNested

function folder_Above fileOrFolder
    set the itemdelimiter to "/"
    if char -1 of fileOrFolder is "/" then delete char -1 of fileOrFolder
    delete last item of fileOrFolder
    if fileOrFolder is empty then 
        return "."
    else
        return fileOrFolder & "/"
    end if
end folder_Above

command folder_Rename fromFolder, toFolder, someMessage
    svn_Move fromFolder, toFolder, someMessage
    if matchchunk(the result, "svn: '(.*)' is not a working copy") then
        rename folder fromFolder to toFolder
        return the result
    else
        return the result
    end if
end folder_Rename

command folder_Delete someFolder
   git_DeleteFolder someFolder, true
   -- revDeleteFolder someFolder
end folder_Delete

function folder_GetInfoTable someFolder, maxFileSize
   put the defaultfolder into oDefault
   text_AddTrailing someFolder, slash
   
   set the itemdelimiter to "/"
   put the number of items of someFolder into baseItemNum
   folder_ConstructInfoTable infoTable, someFolder, baseItemNum, maxFileSize
   set the defaultfolder to oDefault
   return word 1 to -1 of infoTable
end folder_GetInfoTable

command folder_ConstructInfoTable @infoTable, someFolder, baseItemNum, maxFileSize
   -- as fast as possible
   -- make sure initial folder is formatted (folder_Format)
   set the directory to someFolder
   put the detailed files into detailedFiles
   repeat for each line someLine in detailedFiles
      put urldecode(item 1 of someLine) into shortName
      if char 1 of shortName is "." then next repeat
      
      put someFolder & shortName into someFile
      put item 2 of someLine into fileSize
      put item 4 of someLine into creationDate
      
      if fileSize < maxFileSize or maxFileSize is empty then
         -- put file_Md5Hash(someFile) into fileHash
         put url ("binfile:" & someFile) into someData
         put text_Hash(someData) into fileHash
      else
         put empty into fileHash
      end if
      get folder_ConstructInfoTableLine(someFile, fileSize, creationDate, fileHash, baseItemNum)
      put it & CR after infoTable
   end repeat
   
   put the folders into folderNames
   repeat for each line folderName in folderNames
      if char 1 of folderName is "." then next repeat
      put someFolder & folderName & "/" into subFolder
      folder_ConstructInfoTable infoTable, subFolder, baseItemNum, maxFileSize
   end repeat
end folder_ConstructInfoTable

private function folder_ConstructInfoTableLine someFile, fileSize, creationDate, fileHash, baseItemNum
set the itemdelimiter to "/"
put "." into item 1 to baseItemNum of someFile
 
put someFile & tab after tableLine
put fileSize & tab after tableLine
put creationDate & tab after tableLine
put fileHash after tableLine
 
return tableLine
end folder_ConstructInfoTableLine

function folder_NestedFilesInside someFolder
    put folder_ConstructFileOutline(someFolder, outlineArray) into fileOutline
    return outlineArray ["FileIndex"]
end folder_NestedFilesInside

function folder_ShortFoldersInside someFolder
   put the directory into originalDirectory
   set the directory to someFolder
   put the folders into shortFolders
   set the directory to originalDirectory
   filter shortFolders without ".*"
   return shortFolders
end folder_ShortFoldersInside

function folder_FoldersInside someFolder, pFilter, pShowInvisible
   if last char of someFolder is "/" then delete last char of someFolder
   if there is a folder someFolder then
      put the directory into originalDirectory
      set the directory to someFolder
      put the folders into shortFolders
      
      -- what else needs escaping?
      replace "/" with ":" in shortFolders
      
      if pShowInvisible is not false then filter shortFolders without ".*"
      if pFilter is not empty then filter shortFolders with someFilter
      
      repeat for each line shortFolder in shortFolders
         put someFolder & "/" & shortFolder & "/" & CR after foldersInside
      end repeat
      delete last char of foldersInside
      set the directory to originalDirectory
      return foldersInside
   else
      return empty
   end if
end folder_FoldersInside

function folder_ExtensionFiles someFolder, pExtension
   text_AddTrailing someFolder, slash
   put the directory into oDirectory
   set the directory to someFolder
   put the files into shortFiles
   set the itemdelimiter to "."
   repeat for each line shortFile in shortFiles
      if item -1 of shortFile = pExtension then
         put someFolder & shortFile & CR after extensionFiles
      end if
   end repeat
   delete char -1 of extensionFiles
   set the directory to oDirectory
   return extensionFiles
end folder_ExtensionFiles

function folder_ShortNameAboveFile filePath
    -- was "extract_ShortFolder"
     
    if filePath is empty then
        put the effective filename of this stack into filePath
    end if
    set the itemdelimiter to "/"
    delete last item of filePath
    return last item of filePath
end folder_ShortNameAboveFile

function folder_ConstructArray someFolder
   local dataArray
   text_AddTrailing someFolder, slash
   put the directory into oDirectory
   set the directory to someFolder
   
   put the folders into newShortFolders
   if includeInvisible is not false then filter newShortFolders without ".*"
   -- what else needs escaping?
   replace "/" with ":" in newShortFolders
   
   repeat for each line shortFolder in newShortFolders
      put someFolder & shortFolder & "/" into nestedFolder
      set the directory to nestedFolder
      put the files into shortFiles
      if includeInvisible is not false then filter shortFiles without ".*"
      repeat for each line shortFile in shortFiles
         put nestedFolder & shortFile into filePath
         
         put dataArray [shortFolder] into fileIndex
         line_Insert shortFile, fileIndex
         put fileIndex into dataArray [shortFolder]
      end repeat
   end repeat
   set the directory to someFolder
   return dataArray
end folder_ConstructArray

function folder_ConstructDatagridArray someFolder, pIsExpanded
   local dgArray
   text_AddTrailing someFolder, slash
   put the directory into oDirectory
   set the directory to someFolder
   
   put the folders into newShortFolders
   if includeInvisible is not false then filter newShortFolders without ".*"
   -- what else needs escaping?
   replace "/" with ":" in newShortFolders
   
   repeat with lineNum = 1 to the number of lines of newShortFolders
      put pIsExpanded is true into dgArray [lineNum]["isExpanded"]
      put line lineNum of newShortFolders into shortFolder
      put shortFolder into dgArray [lineNum]["title"]
      
      put someFolder & shortFolder & "/" into nestedFolder
      put nestedFolder into dgArray [lineNum]["folder"]
      
      set the directory to nestedFolder
      put the files into shortFiles
      if includeInvisible is not false then filter shortFiles without ".*"
      repeat for each line shortFile in shortFiles
         put nestedFolder & shortFile into filePath
         
         put dgArray [lineNum]["files"] into fileIndex
         line_Insert shortFile, fileIndex
         put fileIndex into dgArray [lineNum]["files"]
      end repeat
   end repeat
   set the directory to someFolder
   return dgArray
end folder_ConstructDatagridArray

function folder_ConstructFileOutline someFolder, @infoArray, excludeFolderList, includeInvisible, tabBit, pUseHtmlLinks
   local shortFileOutline
   
   if there is not a folder someFolder then return empty
   text_AddTrailing someFolder, slash
   put infoArray["FolderIndex"] into folderIndex 
   put infoArray["FileIndex"] into fileIndex 
   line_Insert someFolder, folderIndex
   put folderIndex into infoArray["FolderIndex"]
   
   put the directory into oDirectory
   set the directory to someFolder
   put the files into shortFiles
   if includeInvisible is not false then filter shortFiles without ".*"
   
   repeat for each line shortFile in shortFiles
      put someFolder & shortFile into filePath
      line_Insert filePath, fileIndex
      
      if pUseHtmlLinks is not true then
         put tabBit & shortFile into osTitle
      else
         put tabBit & html_ConstructNameLink(shortFile, filePath) into osTitle
      end if
      line_Insert osTitle, shortFileOutline
   end repeat
   put fileIndex into infoArray["FileIndex"]
   
   put the folders into newShortFolders
   if includeInvisible is not false then filter newShortFolders without ".*"
   
   -- what else needs escaping?
   replace "/" with ":" in newShortFolders
   
   repeat for each line shortFolder in newShortFolders
      if shortFolder is among the items of excludeFolderList then next repeat
      put someFolder & shortFolder & "/" into nestedFolder
      
      if pUseHtmlLinks is not true then
         put tabBit & shortFolder into osTitle
      else
         put tabBit & html_ConstructNameLink (shortFolder, nestedFolder) into osTitle
      end if
      line_Insert osTitle, shortFileOutline
      
      put tabBit & tab into nextTabBit
      put folder_ConstructFileOutline (nestedFolder, infoArray, excludeFolderList, includeInvisible, nextTabBit, pUseHtmlLinks) into nestedOutline
      line_Insert nestedOutline, shortFileOutline
   end repeat
   
   set the directory to oDirectory
   return shortFileOutline
end folder_ConstructFileOutline

function folder_GetNestedIndex someFolder
   -- a nested index of folders
   local foundFolders
   
   text_AddTrailing someFolder, slash
   put someFolder & return after foundFolders
   
   put the directory into oFolder
   set the directory to someFolder
   put the folders into folderIndex
   filter folderIndex without ".*"
   repeat for each line shortFolder in folderIndex
      put someFolder & shortFolder & "/" into nestedFolder
      put folder_GetNestedIndex (nestedFolder) & CR after foundFolders
   end repeat
   set the directory to oFolder
   delete last char of foundFolders
   return foundFolders
end folder_GetNestedIndex


--> Folder | Search
-
function folder_SearchForFiles someFolder, searchString, recurseFolders, includeInvisible, excludeFolderList
   -- was "searchFolder", then "file_SearchInFolder"
   local foundFiles
   put the directory into oFolder
   set the directory to someFolder
   put the files into shortFiles
   text_AddTrailing someFolder, slash
   
   if includeInvisible is not true then filter shortFiles without ".*"
   if excludeFolderList is not empty then
      set the itemdelimiter to "/"
      put last item of someFolder into shortFolder
      set the itemdelimiter to comma
      if shortFolder is among the items of excludeFolderList then
         return empty
      end if
   end if
   
   repeat for each line filePath in shortFiles
      if matchtext(tFile, searchString) then
         -- if searchString is filePath then
         put someFolder & filePath into tFilePath
         if foundFiles is empty then
            put tFilePath into foundFiles
         else
            put the number of lines of foundFiles into lastLineNum
            put tFilePath into line lastLineNum + 1 of foundFiles
         end if
      end if
   end repeat
   
   -- if recurseFolders is true then CheckFolders someFolder, searchString
   if recurseFolders is true then
      put the folders into tFolderList
      delete line 1 of tFolderList
      repeat for each line tFolder in tFolderList
         put someFolder & tFolder & "/" into tNuFolder
         get folder_SearchForFiles(tNuFolder, searchString, true, includeInvisible, excludeFolderList)
         -- put it after foundFiles
         put the number of lines of foundFiles into lastLineNum
         put it into line lastLineNum + 1 of foundFiles
      end repeat
   end if
   set the directory to oFolder
   return foundFiles
end folder_SearchForFiles

function folder_SearchForStacks someFolder, searchString, recurseFolders, skipArchives, excludedFolderList
   -- was "folder_SearchForFiles", "file_SearchForStacks"
   -- recursive function
   local foundFiles
   if there is not a folder someFolder then
      return empty
   end if
   
   if excludedFolderList is empty then put "CVS,retired,archive" into excludedFolderList
   if skipArchives is not false and (char 1 of someFolder is "." or someFolder is among the items of excludedFolderList) then
      return empty	# skip CVS folders
   end if
   
   put the directory into oFolder
   set the directory to someFolder
   put the files into shortFiles
   text_AddTrailing someFolder, slash
   
   put shortFiles into filteredFiles
   filter filteredFiles with "*.mc"
   
   put shortFiles into revFiles
   filter revFiles with "*.rev"
   line_Insert revFiles, filteredFiles
   
   repeat for each line filePath in filteredFiles
      if matchtext(tFile, searchString) then
         put someFolder & filePath into tFilePath
         line_Insert tFilePath, foundFiles
      end if	
   end repeat
   
   if recurseFolders is not false then
      put the folders into tFolderList
      filter tFolderList without ".*"
      repeat for each line tFolder in tFolderList
         if skipArchives is not false and (char 1 of tFolder is "." or tFolder is among the items of excludedFolderList) then
            next repeat	# skip CVS folders
         end if
         put someFolder & tFolder & "/" into tNuFolder
         get folder_SearchForStacks(tNuFolder, searchString, true, skipArchives, excludedFolderList)
         line_Insert it, foundFiles
      end repeat
   end if
   set the directory to oFolder
   return foundFiles
end folder_SearchForStacks

command folder_ConstructStackArrays @stackNameArray, @bigFileIndex, someFolder, searchNested, skipArchives, excludedFolderList	# recursive function
   -- was "file_RecursiveStackSearch"
   -- seems to look at files several times ???
   if excludedFolderList is empty then put "CVS,retired,archive" into excludedFolderList
   if skipArchives is not false and (char 1 of someFolder is "." or someFolder is among the items of excludedFolderList) then
      return empty	# skip CVS folders
   end if
   
   put the directory into oFolder
   set the directory to someFolder
   put the files into shortFiles
   
   text_AddTrailing someFolder, slash
   _FilterAndAddStacks shortFiles, someFolder, stackNameArray, bigFileIndex
   
   if searchNested is not false then
      put the folders into tFolderList
      delete line 1 of tFolderList
      repeat for each line tFolder in tFolderList
         if the controlkey is "Down" then return foundFiles	# allow an exit?
         if skipArchives is not false and (char 1 of tFolder is "." or tFolder is among the items of excludedFolderList) then
            next repeat	# skip CVS folders
         end if
         
         put someFolder & tFolder & "/" into tNuFolder
         folder_ConstructStackArrays stackNameArray, bigFileIndex, tNuFolder, searchNested, skipArchives, excludedFolderList
      end repeat
   end if
   
   set the directory to oFolder
   return ""
end folder_ConstructStackArrays

private command _FilterAndAddStacks shortFiles, someFolder, @stackNameArray, @bigFileIndex
    local filteredFiles
    
    put shortFiles into mcFiles
    filter mcFiles with "*.mc"
    line_Insert mcFiles, filteredFiles
     
    put shortFiles into revFiles
    filter revFiles with "*.rev"
    line_Insert revFiles, filteredFiles
     
    if filteredFiles is not empty then
        repeat for each line filePath in filteredFiles
            put someFolder & filePath into tFilePath
             
            -- this is where you can test individual files
            set lockmessages to true
            if exists(stack tFilePath) then
                put the short name of stack tFilePath into stackName
                put the long name of stack tFilePath into mainStackObject
                 
                array_AddToIndex mainStackObject, stackName, stackNameArray
                
                put the substacks of stack tFilePath into subStackNames
                repeat for each line subStackName in subStackNames
                    put the long name of stack subStackName of stack tFilePath into subStackObject
                     
                    array_AddToIndex subStackObject, subStackName, stackNameArray
                end repeat
                 
                put tFilePath & return after foundFiles
            end if
            set lockmessages to false
        end repeat
         
        put foundFiles after bigFileIndex
    end if
    return foundFiles
end _FilterAndAddStacks
