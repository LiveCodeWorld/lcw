script "lib_Shell"
--> MetaData
-
license: GPLv3
name: lib_Shell
type: library
version: 0.1

/*
This library is about interfacing with shell commands and utilities
Aim to spilt out lib_SSH soon, but have to update transporter dependencies for that.

command ssh_DeleteFolder sshUser, remoteDomain, relativePath
   -- be super careful! 
   -- Not used so far. Consider backing everything up to git before using
   -- relative to the user specified in sshUser's $HOME directory
   -- https://www.computerhope.com/issues/ch000798.htm
   -- rm -rf mydir
   -- put "rm -R" && relativePath into remoteCommand
   
   put "rm -rf" && relativePath into remoteCommand
   ssh_DoRemoteShell sshUser, remoteDomain, remoteCommand
   put the result into someData
   return someData
end ssh_DeleteFolder
*/


--> Terminal
-
command terminal_PasteScript shellScript, pDelayTime
   if pDelayTime is empty then put 0.25 into pDelayTime
   --
   put "tell application 'Terminal'" into tScript
   put CR & "activate" after tScript
   put CR & "delay [[pDelayTime]]" after tScript
   put CR & "tell application 'System Events'" after tScript
   put CR & "keystroke '[[shellScript]]'" after tScript
   put CR & "end tell" after tScript
   put CR & "end tell" after tScript
   --
   put merge (tScript) into  mScript
   replace "'" with quote in mScript
   --
   do mScript as AppleScript
   put the result into someText
   --
   return mScript
end terminal_PasteScript

command terminal_PasteInNewTab shellScript, pDelayTime
   if pDelayTime is empty then put 0.25 into pDelayTime
   --
   put "tell application 'Terminal'" into tScript
   put CR & "activate" after tScript
   put CR & "delay [[pDelayTime]]" after tScript
   --
   put CR & "tell application 'System Events'" after tScript
   put CR & "keystroke 't' using {command down}" after tScript
   --
   put CR & "keystroke '[[shellScript]]'" after tScript
   put CR & "end tell" after tScript
   put CR & "end tell" after tScript
   --
   replace "'" with quote in tScript
   put merge (tScript) into  mScript
   --
   do mScript as AppleScript
   put the result into someText
   --
   return mScript
end terminal_PasteInNewTab


--> Working on
-
function shell_TreeSearch filePattern, pFolder, pNotPattern
   -- was "shell_GetGoodNestedFiles"
   -- put "*.html|*.xml" into filePattern
   -- put ""*-sidebar.html"" into pNotPattern
   
   put the defaultFolder into oFolder
   if there is a folder pFolder then set the defaultFolder to pFolder
   put shell_ConstructTreeCommand (filePattern, pNotPattern) into someShell
   --
   put shell (someShell) into someFiles
   set the defaultFolder to oFolder
   return someFiles
end shell_TreeSearch

function shell_ConstructTreeCommand filePattern, pNotPattern
   -- put "tree -afi --noreport --prune -P '*.html|*.xml' -I *-sidebar.html" into someShell
   put merge ("tree -afi --noreport --prune -P '[[filePattern]]'") into someShell
   if pNotPattern is not empty then
      put space & "-I" && notPattern after someShell
   end if
   return someShell
end shell_ConstructTreeCommand

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

command ssh_DoRemoteShell sshUserName, serverAddress, remoteShell, pWhichKey
   -- requires public ssh key to be installed on server
   put "ssh" into someShell
   if pWhichKey is not empty then
      breakpoint -- not tested
      put the defaultfolder into oFolder
      set the defaultfolder to "~/.ssh"
      put space & "-i" && pWhichKey after someShell
   end if
   --
   put space & sshUserName & "@" & serverAddress && remoteShell after someShell
   --
   put word 1 to -1 of shell (someShell) into shellResult
   --
   if pWhichKey is not empty then
      set the defaultfolder to oFolder
   end if
   return shellResult
end ssh_DoRemoteShell


--> Shell | Hash
-
function shell_Md5Hash someFile
   -- On Linux you can use the "md5sum" utility, 
   -- on OSX the "md5" command 
   -- On Win you may need to build your own utility 
   -- but there are many very simple, single file sources available, with no library dependencies, 
   -- so you could build and distribute your own executable for Win32.
   -- (Or you could download the Microsoft utility to do this - fciv - from http://support.microsoft.com/?kbid=841290 )
   
   put "md5 -q" && shell_EscapeFile (someFile) into someShell
   put shell (someShell) into fileHash
   return fileHash
end shell_Md5Hash

command diff_Files thisFile, lastFile
   -- this fixed upgrade error -- https://stackoverflow.com/questions/17980759/xcode-select-active-developer-directory-error
   -- can we open in background
   -- put "sdiff" into someShell
   put "opendiff" into someShell
   put space & kwote(thisFile) && kwote(lastFile) after someShell
   
   -- try to run in the background
   -- put "(" & someShell && "&)" into someShell -- makes no difference
   -- put "screen" && someShell into someShell -- does not work (needs to attach screen)
   
   put shell (someShell) into shellResult
   return shellResult
end diff_Files


--> SSH
-
function ssh_FetchFile sshUser, remoteDomain, somePath
   shell_BashParamEscape somePath
   put "cat" && somePath into remoteCommand
   ssh_DoRemoteShell sshUser, remoteDomain, remoteCommand
   put the result into someData
   return someData
end ssh_FetchFile

command ssh_DeleteFile sshUser, remoteDomain, somePath
   -- can we ensure it only deletes a single file?
   shell_BashParamEscape somePath
   --
   put "rm" && somePath into remoteCommand
   ssh_DoRemoteShell sshUser, remoteDomain, remoteCommand
   put the result into shellResult
   return shellResult
end ssh_DeleteFile


--> Working On
-
function shell_ExecuteAtRoot someShell, pExecuteWhere, pShellCommandRoot
   if pExecuteWhere is empty then put library_PluginFolder() into pExecuteWhere
   if pShellCommandRoot is not empty then
      text_AddTrailing pShellCommandRoot, slash
      if there is a folder pShellCommandRoot then
         shell_BashParamEscape pShellCommandRoot
         put pShellCommandRoot before someShell
      else
         lcw_Notify merge("Cannot locate folder '[[pShellCommandRoot]]'!"), true
      end if
   end if
   
   put the defaultfolder into oFolder
   set the defaultfolder to pExecuteWhere
   put shell (someShell) into shellResult
   set the defaultfolder to oFolder
   return shellResult
end shell_ExecuteAtRoot

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


--> Shell | Store and Fetch
-
command shell_StoreFile sshUser, remoteDomain, remotePath, localFile, pSshKeyPath
   /*
   scp –P 40050 Desktop/url.txt yatri@192.168.1.50:~/Desktop/url.txt
   scp hierarchical.png root@178.62.43.72:~/.wiki/actual.world/pages/hierarchical.png
   
   -- https://superuser.com/questions/1022976/scp-copy-has-error-ambiguous-target
   If you have white space in a path, you have to escape the characters by using double backslashes \\ and enclosing the entire path in quotes:
         scp myfile.txt user@192.168.1.100:"/file\\ path\\ with\\ spaces/myfile.txt"
   
   */
   
   -- shell_BashParamEscape localFile
   put kwote (word 1 to -1 of localFile) into localFile
   
   -- shell_BashParamEscape fullPath
   -- The outside set of quotes are for the local shell, and the inside quotes are for the remote shell.
   --    scp "my local file.txt" user@192.168.1.100:"'/folder/my spacey folder name/'"
   put word 1 to -1 of remotePath into remotePath
   put "'" before remotePath
   put "'" after remotePath
   put kwote (remotePath) into remotePath
   
   put sshUser & "@" & remoteDomain & ":" & remotePath into scpDestination
   put "scp"  into someShell
   if pSshKeyPath is not empty then
      shell_BashParamEscape pSshKeyPath
      put space & "-i " && pSshKeyPath after someShell
   end if
   put space & localFile && scpDestination after someShell
   
   put shell (someShell) into shellResult
   return shellResult
end shell_StoreFile


--> Shell | Network
-
command terminal_Diff thisText, lastText, pThisShortFile, pLastShortFile
   if pThisShortFile is empty then put "this.txt" into pThisShortFile
   if pLastShortFile is empty then put "last.txt" into pLastShortFile
   
   put specialfolderpath ("Desktop") into desktopFolder
   put desktopFolder & "/OPN/Temp/Compare/" into compareFolder
   folder_CreateNested compareFolder
   
   put compareFolder & pThisShortFile into thisFile
   put compareFolder & pLastShortFile into lastFile
   
   diff_CreateTempFile thisText, pThisShortFile
   put the result into thisFile
   
   diff_CreateTempFile lastText, pLastShortFile
   put the result into lastFile
   
   diff_Files thisFile, lastFile
   return the result
end terminal_Diff

command diff_CreateTempFile someText, shortFile
   put specialfolderpath ("Desktop") into desktopFolder
   put desktopFolder & "/OPN/Temp/Compare/" into compareFolder
   folder_CreateNested compareFolder
   
   put compareFolder & shortFile into someFile
   put someText into url ("binfile:" & someFile)
   return someFile
end diff_CreateTempFile


--> Shell
-
function shell_ConvertHtmlToXML someHTML
   return shell_Tidy (someHTML, "-asxml")
end shell_ConvertHtmlToXML

function shell_ConvertHtmlToXHTML  someHTML
   return shell_Tidy (someHTML, "-asxhtml")
end shell_ConvertHtmlToXHTML

function shell_Tidy someHTML, pOptions
   -- https://en.wikipedia.org/wiki/HTML_Tidy
   -- put "<html> <head> <title>Hello David!</title> </head> <body> <h1>Hello World!</h1> </body> </html>" into $LIVECODEVAR
   
   put someHTML into $TEMPLIVECODEVAR
   put "echo $TEMPLIVECODEVAR | tidy" into someShell
   if pOptions is not empty then put space & pOptions after someShell
   
   put shell (someShell) into tidyResult
   set the wholematches to true
   put lineoffset (empty, tidyResult) into emptyLineNum
   put line 1 to emptyLineNum of tidyResult into someInfo
   delete line 1 to emptyLineNum of tidyResult
   return tidyResult
end shell_Tidy

command shell_ExecuteInBackground someShell
   put the tempname & ".sh" into shellFile
   put someShell into url ("file:" & shellFile)
   
   shell_makeExecutable shellFile
   launch shellFile
   put the result into shellResult
   return shellResult
end shell_ExecuteInBackground

command shell_MakeExecutable someFile
   shell_Chmod "+x", someFile
   return the result
end shell_MakeExecutable

command shell_Chmod plusStuff, someFile
   shell_BashParamEscape someFile
   put "chmod" && plusStuff && someFile into someShell
   put shell (someShell) into shellResult
   return shellResult
end shell_Chmod

function shell_ListProcesses grepFilter
   /*
   The biggest change is in the interpretation of the -u option, 
   which now displays processes belonging to the specified username(s). 
   Thus, "ps -aux" will fail (unless you want to know about user "x"). 
   As a convenience, however, "ps aux" still works as it did in Mac OS X v.10.4.
*/
   put "grep" && grepFilter into filterBit
   
   shell_BashParamEscape grepFilter
   -- put "ps -ef | grep grepFilter" into someShell
   put "grep" && grepFilter into grepBit
   put "ps aux |" && grepBit into someShell
   put shell (someShell) into shellResult
   
   filter shellResult without ("*" & filterBit)
   return shellResult
end shell_ListProcesses

function shell_ManPage someShell
   put shell ("man " & someShell & " | col -b") into manpage
   return manpage
end shell_ManPage

command shell_BashParamEscape @someParam
   put word 1 to -1 of someParam into someParam
   if text_IsQuoted(someParam) is false then
      repeat for each char someChar in " |()"
         replace someChar with ("\" & someChar) in someParam
      end repeat
   end if
end shell_BashParamEscape

command shell_AddBashParam @someShell, paramContents, paramFlag
    if paramFlag is not empty then put space & paramFlag after someShell
    if paramContents is not empty then
        shell_BashParamEscape paramContents
        put space & paramContents after someShell
    end if
end shell_AddBashParam

function shell_EscapeFile someFile
    replace space with "\ " in someFile
    replace "(" with "\(" in someFile
    replace ")" with "\)" in someFile
    return someFile
end shell_EscapeFile

command shell_BashParamEscape @someParam
    replace space with ("\" & space) in someParam
    replace "|" with ("\" & "|") in someParam
end shell_BashParamEscape

on sudo_Kill
    put "#!/bin/sh" & cr into tScript
    put "pw="&tPassword & cr after tScript
    put "echo $pw | sudo -S kill -9" && tPID & cr after tScript
    return shell(tScript)
end sudo_Kill


--> Linux
-
on linux_Sudo
    put "#!/bin/sh" & cr into tScript
    put "pw="&tPassword & cr into tScript
    put "echo $pw | sudo -S kill -9" && tPID & cr after tScript
    get shell(tScript)
end linux_Sudo

on linux_Mount mountPath
  if linux_CheckMounted() contains mountPath then
    return "Already Mounted"
  else
    put "mount" && mountPath into someShellCommand
    put shell(someShellCommand) into shellResult
    return shellResult
  end if
end linux_Mount

function linux_CheckMounted
  put url "file:/etc/mtab" into mountedFiles
  return mountedFiles
end linux_CheckMounted


--> Shell | To Sort
-
function sha1_HashFile pPath
   -- for hash of a file:
   return word -1 of shell ("openssl dgst -sha1" && pPath)
end sha1_HashFile

function sha1_HashString pText
    -- Other hashes are available --> man pages sha1
    -- Option to sign a file by adding a flag --> man pages sha1
    -- Other services of openssl --> man pages openssl
    
    put the tempName&".tmp" into tPath
    put pText into url ("file:"&tPath)
    ## adapt time  according to rig (may be not necessary)
    wait 0 with messages
    return word -1 of shell("openssl dgst -sha1" &&tPath)
end sha1_HashString

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
function ijwAPLIB_MakeOSXShellPath tPath
    -- Ian Wood <revlist@azurevision.co.uk>
    put "set tOut to POSIX path of tPath" into tScript
    replace "tPath" with quote & revMacFromUnixPath(tPath) & quote in tScript
    do tScript as applescript
    
    put the result into tNewPath
    delete char 1 of tNewPath
    delete last char of tNewPath
    replace space with "\" & space in tNewPath
    replace quote with "\" & quote in tNewPath
    replace "'" with "\" & "'" in tNewPath
    replace "*" with "\" & "*" in tNewPath
    replace "?" with "\" & "?" in tNewPath
    replace "[" with "\" & "[" in tNewPath
    replace "]" with "\" & "]" in tNewPath
    replace "{" with "\" & "{" in tNewPath
    replace "}" with "\" & "}" in tNewPath
    replace "$" with "\" & "$" in tNewPath
    replace "!" with "\" & "!" in tNewPath
    replace "&" with "\" & "&" in tNewPath
    replace "|" with "\" & "|" in tNewPath
    replace ">" with "\" & ">" in tNewPath
    replace "<" with "\" & "<" in tNewPath
    replace ";" with "\" & ";" in tNewPath
    replace "(" with "\" & "(" in tNewPath
    replace "(" with "\" & ")" in tNewPath
    return tNewPath
end ijwAPLIB_MakeOSXShellPath

function date_MonthToMonthNumber monthName
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


--> Deps
-
function text_IsQuoted someText, pString
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
