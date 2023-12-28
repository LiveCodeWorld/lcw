script "lib_Symlink"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Symlink
type: library
version: 0.2

/*Some help*/


--> Working on
-
command folder_CreateSymLink fromFolder, toSymFolder, pSomeHow, pXtermView
   symlink_CreateFolder fromFolder, toSymFolder, pSomeHow, pXtermView
   return the result
end folder_CreateSymLink

private command _TrimSymSlash @sFolder
   # Otherwise follows symlink rather than checking it
   if char -1 of sFolder = slash then delete char -1 of sFolder
end _TrimSymSlash

--> Symlink
-
function folder_IsSymLink sFolder
   _TrimSymSlash sFolder
   
   # Need to use folder above
   put "ls -l" && kwote (sFolder) into someShell
   put shell (someShell) into lsResult
   --
   set the itemdelimiter to " -> "
   get the number of items of line 1 of lsResult
   return it = 2
   
   put merge ("[ -L '[[sFolder]]' ] && echo true || echo false") into someShell
   put line 1 of shell (someshell) into sBoolean
   return sBoolean
end folder_IsSymLink

function file_IsSymLink sFile
   set the itemdelimiter to slash
   put item 1 to -2 of sFile into sFolder
   put files (sFolder, outputKind) into dFiles
   return dFiles
end file_IsSymLink

command symlink_CreateFolder fromFolder, toSymFolder, pSomeHow, pXtermView
   if there is not a folder fromFolder then return "Error," && fromFolder && "does not exist."
   --
   if there is a folder toSymFolder then
      breakpoint
      return "Error, not overwriting existing folder" & toSymFolder
   end if
   
   # Tidy for shell
   _TrimSymSlash fromFolder
   _TrimSymSlash toSymFolder
   --
   put merge ("ln -s '[[fromFolder]]' '[[toSymFolder]]'") into someShell
   replace "'" with quote in someShell
   --
   shell_Do someShell, pSomeHow, pXtermView
   return the result
end symlink_CreateFolder

command symlink_Delete sFolder
   # Check
   if there is not a folder sFolder then
      return "Error, [[sFolder]] does not exist"
   end if
   if folder_IsSymLink (sFolder) is false then
      return "Error, [[sFolder]] is not a symlink"
   end if
   
   # Delete
   _TrimSymSlash sFolder
   put "rm" && kwote (sFolder) into someShell
   put shell (someShell) into shellResult
   return shellResult
end symlink_Delete

function symlink_Destination symLinkFile
   _TrimSymSlash symLinkFile
   
   put "ls -l" && kwote (symLinkFile) into someShell
   put shell (someShell) into lsResult
   --
   set the itemdelimiter to " -> "
   if the number of items of line 1 of lsResult = 2 then
      put item -1 of lsResult into symlinkDestination
      return symlinkDestination
   else
      return empty
   end if
end symlink_Destination

function folder_ListShortAll sFolder
   /*
   Note: The second find command lists all types of symlinks, not just those linking to directories. 
   To filter only symlinks that point to directories, a more complex command would be required, 
   typically involving additional scripting to test each symlink's target.
   */
   _TrimSymSlash sFolder
   
   get merge ("find '[[sFolder]]' -maxdepth 1 -type d -exec basename {} \; && find '[[sFolder]]' -maxdepth 1 -type l -exec basename {} \;")
   put shell (it) into allFolderNames
   --
   delete line 1 of allFolderNames
   --
   sort allFolderNames
   return allFolderNames
end folder_ListShortAll

function folder_ShortList rootFolder, pWhich
   switch pWhich
      case "sym"
         put folder_ListSymShort (rootFolder) into shortFolders
         break
      case "all"
         put folder_ListAllShort (rootFolder) into shortFolders
         break
      default
         put folder_ListShort (rootFolder) into shortFolders
   end switch
   return shortFolders
end folder_ShortList

function folder_ListAllShort rootFolder
   -- including sym linked folders
   put _ListFolder (rootFolder, "ls -d */", true) into shortFolders
   return shortFolders
end folder_ListAllShort

function folder_ListSymShort rootFolder
   _TrimSymSlash rootFolder
   
   put "find . -maxdepth 1 -type l -exec test -d '{}' \; -print" into lsShell
   put _ListFolder (rootFolder, lsShell, false) into shortSymFolders
   --
   repeat with lineNum = 1 to the number of lines of shortSymFolders
      delete char 1 to 2 of line lineNum of shortSymFolders
   end repeat
   return shortSymFolders
end folder_ListSymShort

function folder_ListShortNonSymLinked sFolder
   put folder_ShortList (sFolder) into notSymLinkedFolderNames
   return notSymLinkedFolderNames
   
   # Bash
   _TrimSymSlash sFolder
   put merge ("find '[[sFolder]]' -maxdepth 1 -type d ! -lname '*' -exec basename {} \;") into someShell
   put shell (someShell) into notSymLinkedFolderNames
   delete line 1 of notSymLinkedFolderNames -- sFolder name
   return notSymLinkedFolderNames
end folder_ListShortNonSymLinked

function folder_ListNonSymLinked sFolder, pListShort
   put folder_ListShortSymLinked (sFolder) into shortSymLinked
   put folder_ListShortAll (sFolder) into allLocal
   put line_DeleteFromIndex (shortSymLinked, allLocal) into notSymShortFolders
   --
   if pListShort is true then
      return notSymShortFolders
   end if
   --
   repeat for each line shortFolder in notSymShortFolders
      if char 1 of shortFolder = "." then next repeat
      put sFolder & shortFolder & slash & CR after notSymLinkedFolders
   end repeat
   return notSymLinkedFolders
   
   -- contains "//"
   _TrimSymSlash sFolder
   put merge ("find '[[sFolder]]' -maxdepth 1 -type d ! -lname '*'") into someShell
   put shell (someShell) into notSymLinkedFolders
   delete line 1 of notSymLinkedFolders
   return notSymLinkedFolders
end folder_ListNonSymLinked


--> SymLinked
-
function folder_ListSymLinked sFolder
   _TrimSymSlash sFolder
   put merge ("find '[[sFolder]]' -maxdepth 1 -type l") into someShell
   put shell (someShell) into notSymLinkedFolders
   return notSymLinkedFolders
end folder_ListSymLinked

function folder_ListShortSymLinked sFolder
   _TrimSymSlash sFolder
   put merge ("find '[[sFolder]]' -maxdepth 1 -type l -exec basename {} \;") into someShell
   put shell (someShell) into notSymLinkedFolderNames
   return notSymLinkedFolderNames
end folder_ListShortSymLinked

private function _ListFolder rootFolder, lsShell, pStripLast
   if there is not a folder rootFolder then return empty
   --
   put the defaultfolder into oDefault
   set the defaultfolder to rootFolder
   put shell (lsShell) into shortFolders
   set the defaultfolder to oDefault
   
   if pStripLast is true then
      repeat with lineNum = 1 to the number of lines of shortFolders
         delete char -1 of line lineNum of shortFolders
      end repeat
   end if
   return shortFolders
end _ListFolder
