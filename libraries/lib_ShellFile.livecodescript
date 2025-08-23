script "lib_ShellFile"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_ShellFile
type: library
version: 0.2

/*
Using quotes:

Wrap the directory path in quotes:
Single Quotes:

ls -d '~/.wiki/hello world/'

Double Quotes:

ls -d "~/.wiki/hello world/"

When to Use Single vs. Double Quotes:

Single quotes (') are more restrictive: the shell interprets the content literally.
Double quotes (") allow variable expansion (e.g., $HOME).

Avoid Quotes for Wildcard Expansion:

ls -d ~/.wiki/*/

This works because ~ and * are expanded by the shell before ls processes them.

Quotes for Direct Paths with Spaces: If specifying a single directory with spaces:

ls -d ~/.wiki/"hello world"/
*/


--> Working on
-
command scp_StoreFile remoteDomain, remotePath, localFile, pSshUser, pSshKeyPath
   put kwote (word 1 to -1 of localFile) into localFile
   put kwote (word 1 to -1 of remotePath) into remotePath
   
   # scpDestination
   if pSshUser is empty then
      put remoteDomain & ":" & remotePath into scpDestination
   else
      put pSshUser & "@" & remoteDomain & ":" & remotePath into scpDestination
   end if
   
   put "scp"  into someShell
   if pSshKeyPath is not empty then
      shell_BashParamEscape pSshKeyPath
      put space & "-i " && pSshKeyPath after someShell
   end if
   put space & localFile && scpDestination after someShell
   
   put shell (someShell) into shellResult
   return shellResult
end scp_StoreFile

function ssh_FetchFile remoteDomain, somePath, pSshUser
   shell_BashParamEscape somePath
   put "cat" && somePath into remoteCommand
   ssh_DoRemoteShell remoteDomain, remoteCommand, pSshUser
   put the result into someData
   return someData
end ssh_FetchFile

command ssh_DoRemoteShell serverAddress, remoteShell, pSshUserName, pWhichKey
   -- requires public ssh key to be installed on server
   put "ssh" into someShell
   if pWhichKey is not empty then
      breakpoint -- not tested
      put the defaultfolder into oFolder
      set the defaultfolder to "~/.ssh"
      put space & "-i" && pWhichKey after someShell
   end if
   --
   if pSshUserName is empty then
      put space & serverAddress && kwote (remoteShell) after someShell
   else
      put space & pSshUserName & "@" & serverAddress && kwote (remoteShell) after someShell
   end if
   --
   put word 1 to -1 of shell (someShell) into shellResult
   --
   if pWhichKey is not empty then
      set the defaultfolder to oFolder
   end if
   return shellResult
end ssh_DoRemoteShell


--> WikiCode
-
command wikiCode_MoveFolder shortFolder, fromPi, toPi, pPiUser, pWikiPath
   if pPiUser is empty then put "david" into pPiUser
   if pWikiPath is empty then put "~/.wiki/" into pWikiPath
   
   
   # Set varaibles in paramArray
   put pPiUser into paramArray ["piUser"]
   put pWikiPath into paramArray ["wikiPath"]
   --
   put shortFolder into paramArray ["shortFolder"]
   put fromPi into paramArray ["fromPi"]
   put toPi into paramArray ["toPi"]
   --
   wikiCode_Set "livecode.wiki", "moving-wiki-folders", codeTemplate, paramArray
   
   # Do Shell
   codeArray_DoShell codeTemplate, paramArray
   put the result into shellResult
   return shellResult
end wikiCode_MoveFolder

command wikiCode_Set wikiDomain, pageSlug, @codeTemplate, @paramArray
   # Fetch code template from wiki
   -- put url "http://livecode.wiki/moving-wiki-folders.json"
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   put pageArray_GetFirstCode (pageArray) into firstCode
   put pageItem_ParseCode (firstCode) into codeArray
   put codeArray ["code"] into codeTemplate
   put codeArray ["params"] into paramArray
   return pageArray
end wikiCode_Set

command codeArray_DoShell codeTemplate, paramArray
   ## Load values into variable
   put codeArray_MergeVariables (codeTemplate, paramArray) into someShell
   
   ## Do
   put shell (someShell) into shellResult
   return shellResult
end codeArray_DoShell

function codeArray_MergeVariables codeTemplate, paramArray
   repeat for each key sKey in paramArray
      put paramArray [sKey] into sValue
      get "put sValue into" && sKey
      do it
   end repeat
   
   ## Merge
   put merge (codeTemplate) into someShell
   return someShell
end codeArray_MergeVariables


--> Shell | File
-
function shell_ConstructLs folderPath, pListAll
   put "ls" into remoteShell
   if pListAll is true then put space & "-la" after remoteShell
   
   shell_BashParamEscape folderPath
   put space & folderPath after remoteShell
   return remoteShell
end shell_ConstructLs


--> Rsync
-
command rsync_OpenProcess localFile, wikiDomain, pShortFolder
   set the itemdelimiter to slash
   put item -1 of localFile into shortFile
   put atopia_WikiAssetFile (wikiDomain, shortFile, pShortFolder) into fullPath
   atopia_CreateAssetFolder wikiDomain, pShortFolder
   --
   set the itemdelimiter to slash
   put localFile into newFolder
   delete item -1 of newFolder
   put the defaultFolder into oFolder
   set the defaultFolder to newFolder
   
   put rsync_ConstructFolderPushShell (newFolder, fullPath, "root", "fedwiki.club") into someShell
   -- replace "'" with quote in someShell
   --
   set the cursor to watch
   open process someShell for update
   --
   repeat 1000
      set the cursor to busy
      if the shiftKey is "Down" then exit repeat
      --
      read from process someShell until empty
      put the result into maybeEOF
      put it into someInfo
      put maybeEOF
      --
      if someInfo is not empty then
         --    "  16,004,711 100%  146.13kB/s    0:01:46 (xfr#1, to-chk=2/8)"
         put word 1 to -1 of someInfo into someInfo
         --
         put word 1 of someInfo into bitesSent
         put word 2 of someInfo into somePercent
         put word 3 of someInfo into kbs
         put word 4 of someInfo into timeleft
         put word 5 to -1 of someInfo into maybeEnd -- (xfr#1, to-chk=2/8)
         
         display_Data someInfo, wikiDomain, "Assets"
      end if
   end repeat
   
   set the defaultFolder to oFolder
   close process someShell
end rsync_OpenProcess

function rsync_ConstructFolderPushShell localFile, fullPath, sshUser, serverDomain
   -- https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories
   -- https://unix.stackexchange.com/questions/104618/how-to-rsync-over-ssh-when-directory-names-have-spaces
   -- rsync -a ~/dir1 username@remote_host:destination_directory
   
   put "rsync -aP" into someShell
   put space & kwote (localFile) after someShell
   --
   put sshUser & "@" after remoteBit
   put serverDomain & ":" after remoteBit
   --
   -- shell_BashParamEscape fullPath
   put kwote (fullPath) after remoteBit
   put space & remoteBit after someShell
   return someShell
end rsync_ConstructFolderPushShell


--> Server | File
-
function server_ListLongFolders serverAddress, folderPath, pSshUser, pSshKeyPath
   shell_BashParamEscape folderPath
   text_AddTrailing folderPath, slash
   
   -- ls -d ~/.wiki/*/
   put "ls -d" && folderPath & "*/" into remoteShell
   put ssh_Construct (serverAddress, pSshUser, pSshKeyPath) into sshShell
   put sshShell && kwote (remoteShell) into someShell
   
   put shell (someShell) into fileListing
   return word 1 to -1 of fileListing
end server_ListLongFolders

function server_ListShortFolders serverAddress, folderPath, pSshUser, pSshKeyPath
   put ssh_Construct (serverAddress, pSshUser, pSshKeyPath) into someShell
   --
   -- put shell_ConstructLs (serverPath) into remoteShell
   put "ls" into remoteShell
   shell_BashParamEscape folderPath
   put space & folderPath after remoteShell
   
   # Pipe the output through basename to get only the directory names:
   put space & "| xargs -n 1 basename" after remoteShell
   
   # Quote remote shell
   put space & kwote (remoteShell) after someShell
   put shell (someShell) into fileListing
   return word 1 to -1 of fileListing
end server_ListShortFolders

function server_ListShortFiles serverAddress, serverPath, pListAll, pSshUser, pSshKeyPath
   put ssh_ConstructLsShell (serverAddress, serverPath, pListAll, pSshUser, pSshKeyPath) into someShell
   put word 1 to -1 of shell (someShell) into fileListing
   return fileListing
end server_ListShortFiles

function server_FetchFileArray serverAddress, sshUser, serverPath, pSshKeyPath
   if the environment = "server" then
      breakpoint
   else
      put server_ListShortFiles (serverAddress, serverPath, true, sshUser, pSshKeyPath) into lsResult
      switch lsResult
         case "Host key verification failed."
            /*
            This is usually because the server fingerprint has changed. need to research more about whu this happens.
            Head over to the terminal and try:
            */
            return empty
         default
            put shell_ConstructLSArray (lsResult, true) into fileArray
      end switch
   end if
   return fileArray
end server_FetchFileArray

function server_FileInfoArray someFile
   put server_GetURL() into remoteDomain
   put server_GetSshUser() into sshUser
   
   put someFile into bashFile
   shell_BashParamEscape bashFile
   put "ls -la" && bashFile into remoteShell
   ssh_DoRemoteShell remoteDomain, remoteShell, sshUser
   put the result into lsResult
   
   put lsResult into fileArray ["ls_la_Result"]
   switch
      case word 1 of lsResult = "total"
         -- it's a folder
         put someFile into fileArray ["file"]
         put char 1 of line 2 of of lsResult = "d" into fileArray ["isFolder"]
         return fileArray
      case lsResult ends with ": No such file or directory"
         -- file or folder is missing
         return fileArray
      default
         put shell_ConstructLSArray (lsResult, true) into lsArray
         put lsArray ["file"] into filesArray
         put line 1 of keys (filesArray) into filePath
         put filesArray [filePath] into fileArray
         
         put filePath into fileArray ["file"]
         put remoteDomain into fileArray ["domain"]
         
         set the itemdelimiter to "/"
         put item -1 of filePath into shortFile
         put shortFile into fileArray ["shortFile"]
         
         if shortFile contains "." then
            set the itemdelimiter to "."
            put item -1 of shortFile into fileArray ["fileExtension"]
         else
            put empty into fileArray ["fileExtension"]
         end if
         return fileArray
   end switch
end server_FileInfoArray

function server_FetchFile pathToFetch, serverAddress, pSshUser
   if char 1 of pathToFetch is "/" then
      put pathToFetch into fullPath
   else
      put "~/" & pathToFetch into fullPath
   end if
   shell_BashParamEscape fullPath
   
   put ssh_FetchFile (serverAddress, fullPath, pSshUser) into someData
   set the itemdelimiter to ":"
   if (item 1 of someData = "cat" and item -1 of someData = " No such file or directory") then return empty
   return someData
end server_FetchFile

command server_StoreFile localFile, pathToStore, serverAddress, sshUser, pSshKeyPath
   -- uses "scp" and private keys for security
   if serverAddress is empty or sshUser is empty then
      return "Error, serverAddress is empty or sshUser is empty"
   end if
   
   if char 1 of pathToStore is "/" then
      put pathToStore into fullPath
   else
      put "~/" & pathToStore into fullPath
   end if
   scp_StoreFile serverAddress, fullPath, localFile, sshUser, pSshKeyPath
   put the result into shellResult
   return shellResult
end server_StoreFile

command server_DeleteFile pathToDelete, serverAddress, sshUser
   -- do we want to check if the file exists?
   if serverAddress is empty or sshUser is empty then
      return "Error, serverAddress is empty or sshUser is empty"
   end if
   
   -- relatively safe no recursive delete
   -- put "rm" && somePath into remoteCommand 
   ssh_DeleteFile sshUser, serverAddress, pathToDelete
   put the result into shellResult
   return shellResult
end server_DeleteFile


--> Ssh | File
-
command ssh_DeleteFile sshUser, remoteDomain, somePath
   -- can we ensure it only deletes a single file?
   shell_BashParamEscape somePath
   --
   put "rm" && somePath into remoteCommand
   ssh_DoRemoteShell remoteDomain, remoteCommand, sshUser
   put the result into shellResult
   return shellResult
end ssh_DeleteFile

function ssh_ConstructLsShell serverAddress, serverPath, pListAll, pSshUser, pSshKeyPath
   put ssh_Construct (serverAddress, pSshUser, pSshKeyPath) into someShell
   --
   put shell_ConstructLs (serverPath, pListAll) into remoteShell
   put space & kwote (remoteShell) after someShell
   --
   return someShell
end ssh_ConstructLsShell

function ssh_Construct serverAddress, pSshUser, pSshKeyPath
   put "ssh" into someShell
   if pSshUser is empty then
      -- put "david" into pSshUser
      put space & serverAddress after someShell
   else
      put space & pSshUser & "@" & serverAddress after someShell
   end if
   --
   if pSshKeyPath is not empty then
      shell_BashParamEscape pSshKeyPath
      put space & "-i " && pSshKeyPath after someShell
   end if
   --
   return someShell
end ssh_Construct

function ssh_ConstructRemoteShell remoteShell, serverAddress, sshUserName, pWhichKey
   -- allows complex multi-command single line remoteShell shell scripts
   -- as remoteShell is quoted with "'"
   -- means that the script should not use "'" quoting
   if remoteShell contains "'" then
      breakpoint
      return "error, remoteShell contains '"
   end if
   
   put "ssh" into someShell
   if pWhichKey is not empty then
      breakpoint -- not tested
      put the defaultfolder into oFolder
      set the defaultfolder to "~/.ssh"
      put space & "-i" && pWhichKey after someShell
   end if
   
   -- in case remoteShell is multiple lines separated by something like ";"
   put "'" before remoteShell
   put "'" after remoteShell
   --
   put space & sshUserName & "@" & serverAddress && remoteShell after someShell
   --
   return someShell
end ssh_ConstructRemoteShell

--> Shell | LS
-
function shell_ConstructLSArray lsResult, pShowInvisible
   if word 1 of lsResult = "total" then
      put word 2 of lsResult into totalEntries
      delete line 1 of lsResult
   end if
   
   repeat for each line someLine in lsResult
      shell_DeconstructLS someLine, shortFileName, filePermissions, ownerName, groupName, fSize, lastModified, lsType, numberOfLinks
      put the result into typeExplanation
      
      if shortFileName is among the items of ".,.." then next repeat
      if pShowInvisible is not true then
         if char 1 of shortFileName = "." then next repeat
      end if
      
      put filePermissions into lsArray [typeExplanation][shortFileName]["filePermissions"]
      put ownerName into lsArray [typeExplanation][shortFileName]["ownerName"]
      put groupName into lsArray [typeExplanation][shortFileName]["groupName"]
      put fSize into lsArray [typeExplanation][shortFileName]["fileSize"]
      put lastModified into lsArray [typeExplanation][shortFileName]["lastModified"]
      put lsType into lsArray [typeExplanation][shortFileName]["lsType"]
      put numberOfLinks into lsArray [typeExplanation][shortFileName]["numberOfLinks"]
   end repeat
   return lsArray
end shell_ConstructLSArray

command shell_DeconstructLS someLine, @shortFileName, @filePermissions, @ownerName, @groupName, @fileSize, @lastModified, @lsType, @numberOfLinks
   -- file mode
   put word 1 of someLine into fileMode
   put char 1 of fileMode into lsType
   put char 2 to -1 of fileMode into filePermissions
   
   -- number of links
   put word 2 of someLine into numberOfLinks
   
   -- owner name
   put word 3 of someLine into ownerName
   
   -- group name
   put word 4 of someLine into groupName
   
   -- number of bytes in the file
   put word 5 of someLine into fileSize
   
   put word 6 of someLine into shortMonth   -- abbreviated month
   put word 7 of someLine into dayNum   -- day-of-month file was last modified
   put word 8 of someLine into timeModified
   
   if timeModified is a number then
      /*
      if the modification time of the file is more than 6 months in the past or
      future, then the year of the last modification is displayed in place of
      the hour and minute fields.
      */
      
      put timeModified into yearModified
      put 02 into hourModified  -- hour file last modified
      put 00 into minuteModified   -- minute file last modified
   else
      set the itemdelimiter to ":"
      put item 1 of timeModified into hourModified  -- hour file last modified
      put item 2 of timeModified into minuteModified   -- minute file last modified
      
      set the itemdelimiter to comma
      put the date into today
      convert today to dateItems
      put item 1 of today into thisYear
      put item 2 of today into thisMonth
      
      put date_MonthToMonthNumber(shortMonth) into monthNumber
      if monthNumber - thisMonth > 6 then 
         put thisYear - 1 into yearModified
      else
         put thisYear into yearModified
      end if
   end if
   
   -- "Oct 10, 2006"
   put shortMonth && dayNum & "," && yearModified into lastModified
   convert lastModified to dateItems
   
   put hourModified into item 4 of lastModified
   put minuteModified into item 5 of lastModified
   put 0 into item 6 of lastModified
   convert lastModified to internet date
   
   -- path name
   delete word 1 to 8 of someLine
   put word 1 to -1 of someLine into shortFileName
   
   switch lsType
      case "b"
         put "block special file" into typeExplanation
         break
      case "c"
         put "character special file" into typeExplanation
         break
      case "d"
         put "folder" into typeExplanation
         break
      case "l"
         put "symbolic link" into typeExplanation
         break
      case "s"
         put "socket link" into typeExplanation
         break
      case "p"
         put "fifo" into typeExplanation
         break
      case "-"
         put "file" into typeExplanation
         break
      default
   end switch
   return typeExplanation
end shell_DeconstructLS


--> Deps
-
private command shell_BashParamEscape @someParam
   put word 1 to -1 of someParam into someParam
   if text_IsQuoted(someParam) is false then
      repeat for each char someChar in " |()"
         replace someChar with ("\" & someChar) in someParam
      end repeat
   end if
end shell_BashParamEscape

private function date_MonthToMonthNumber monthName
   -- "Oct 10, 2006"
   put char 1 to 3 of monthName into shortMonth
   set the wholematches to true
   return itemoffset(shortMonth, "Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec")
   
   put the date into testDate
   convert testDate to abbreviated date
   put char 1 to 3 of monthName into word 1 of item 2 of testDate
   convert testDate to dateItems
   return item 2 of testDate
end date_MonthToMonthNumber

private function text_IsQuoted someText, pString
   local quotedText
   put "['" & quote & "]" into someQuote
   if pString is empty then
      put "(?m)" & someQuote & "(.*)" & someQuote into someReg
   else
      put "(?m)" & someQuote & "(.*" & pString & ".*)" & someQuote into someReg
   end if
   put matchtext (someText, someReg, quotedText) into someBoolean
   return someBoolean
end text_IsQuoted

private command shell_BashParamEscape @someParam
   put word 1 to -1 of someParam into someParam
   if text_IsQuoted(someParam) is false then
      repeat for each char someChar in " |()"
         replace someChar with ("\" & someChar) in someParam
      end repeat
   end if
end shell_BashParamEscape

private function kwote someText, pQuoteChar
   if pQuoteChar is empty then put quote into pQuoteChar
   return pQuoteChar & someText & pQuoteChar
end kwote

