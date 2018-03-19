script "lib_Shell"
--> MetaData
-
license: GPLv3
name: lib_Shell
type: library
version: 0.1


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


--> Shell | SSH
-
command ssh_DoRemoteShell sshUserName, serverAddress, remoteShell
   -- requires public ssh key to be installed on server
   -- would be better as a function
   shell_BashParamEscape remoteShell -- maybe better to kwote()
   
   put "ssh" && sshUserName & "@" & serverAddress && remoteShell into someShell
   put word 1 to -1 of shell (someShell) into shellResult
   return shellResult
end ssh_DoRemoteShell


--> Shell | Delete
-
command shell_DeleteFile sshUser, remoteDomain, somePath
   put "rm" && somePath into remoteCommand
   ssh_DoRemoteShell sshUser, remoteDomain, remoteCommand
   put the result into someData
   return someData
end shell_DeleteFile

command shell_DeleteFolder sshUser, remoteDomain, relativePath
   -- relative to the user specified in sshUser's $HOME directory
   -- https://www.computerhope.com/issues/ch000798.htm
   -- rm -rf mydir
   -- put "rm -R" && relativePath into remoteCommand
   
   put "rm -rf" && relativePath into remoteCommand
   ssh_DoRemoteShell sshUser, remoteDomain, remoteCommand
   put the result into someData
   return someData
end shell_DeleteFolder


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

command diff_Files thisFile, lastFile
   put "opendiff" into someShell
   -- put "sdiff" into someShell
   put space & kwote(thisFile) && kwote(lastFile) after someShell
   put shell (someShell) into shellResult
   return shellResult
end diff_Files


--> Bonjour
-
command bonjour_RegisterPortMapper pMapperPort
   put merge ("dns-sd -R 'LiveCode Port Mapper' _livecode._udp. . [[pMapperPort]] pdl=application/livecode") into someShell
   shell_ExecuteInBackground someShell
   put the result into shellResult
   return shellResult
end bonjour_RegisterPortMapper

function socket_ListUsedPorts
   -- On Linux you can use netstat -atp | grep -i "listen")
   -- To show all open ports applications on your machine are listening to you can use this workaround
   
   if the platform is "MacOS" then
      put osx_DaemonArray() into daemonArray
      return keys(daemonArray)
   else
      -- ???
      return empty
   end if
end socket_ListUsedPorts

function osx_DaemonArray
   put "lsof -i -P | grep -i 'listen'" into someShell
   put shell (someShell) into shellResult
   repeat for each line someLine in shellResult
      /*
      1) the `^' (negated) login name or user ID (UID), specified with the -u option;
      2) the `^' (negated) process ID (PID), specified with the -p option;
      3) the `^' (negated) process group ID (PGID), specified with the -g option;
      4) the `^' (negated) command, specified with the -c option;
      5) the (`^') negated TCP or UDP protocol state names, specified with the -s [p:s] option.
      */
      
      put word 1 of someLine into appName
      put word 2 of someLine into pID
      put word 3 of someLine into uName
      put word 4 of someLine into noIdea
      put word 5 of someLine into ipWhat
      put word 6 of someLine into someHex
      put word 7 of someLine into someThingElse
      put word 8 of someLine into pCol
      put word 9 to -1 of someLine into urlBit
      if word -1 of urlBit = "(LISTEN)" then put word 1 to -2 of urlBit into urlBit
      set the itemdelimiter to ":"
      put item 1 of urlBit into someHost
      put item 2 of urlBit into somePort
      
      put appName into daemonArray [somePort]["appName"]
      put someHost into daemonArray [somePort]["host"]
      put pID into daemonArray [somePort]["process id"]
   end repeat
   return daemonArray
end osx_DaemonArray


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

function shell_FetchFile sshUser, remoteDomain, somePath
   put "cat" && somePath into remoteCommand
   ssh_DoRemoteShell sshUser, remoteDomain, remoteCommand
   put the result into someData
   return someData
end shell_FetchFile

command shell_StoreFile sshUser, remoteDomain, fullPath, localFile, pSshKeyPath
   -- scp –P 40050 Desktop/url.txt yatri@192.168.1.50:~/Desktop/url.txt
   -- scp hierarchical.png root@178.62.43.72:~/.wiki/actual.world/pages/hierarchical.png
   
   shell_BashParamEscape localFile
   shell_BashParamEscape fullPath
   
   put sshUser & "@" & remoteDomain & ":" & fullPath into scpDestination
   put "scp"  into someShell
   if pSshKeyPath is not empty then
      shell_BashParamEscape pSshKeyPath
      put space & "-i " && pSshKeyPath after someShell
   end if
   put space & localFile && scpDestination after someShell
   
   -- ssh_DoRemoteShell sshUser, remoteDomain, remoteCommand
   put shell (someShell) into shellResult
   return shellResult
end shell_StoreFile

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

function shell_Md5Hash someFile
  -- On Linux you can use the "md5sum" utility, 
  -- on OSX the "md5" command 
  -- On Win you may need to build your own utility 
  -- but there are many very simple, single file sources available, with no library dependencies, 
  -- so you could build and distribute your own executable for Win32.
  -- (Or you could download the Microsoft utility to do this - fciv - from http://support.microsoft.com/?kbid=841290 )
  put "md5 -q" && shell_EscapeFile(someFile) into someShell
  return shell(someShell)
end shell_Md5Hash

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


--> Shell | Path
-
command shell_AddBashProfileToPath pNewItems
    /*
    -- was "shell_BashAddToPATH"
    if pNewItems is empty then put shell_GetBashPathExtraItems() into pNewItems
    set the itemdelimiter to ":"
    repeat for each item someItem in pNewItems
        if someItem is not among the items of $PATH then
            put the number of items of $PATH into maxItem
            put someItem into item (maxItem + 1) of $PATH
        end if
    end repeat
    */
    
    put "/usr/bin:/bin:/usr/sbin:/sbin:/opt/local/bin" into $PATH
    return $PATH
end shell_AddBashProfileToPath

function shell_GetBashPathExtraItems
   -- PATH should be set to correspond to users .bash stuff
   -- put "/opt/local/bin:/opt/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin" into $PATH
   
   -- put "/opt/local/bin:/opt/local/sbin:" into newItems
   
   put shell_GetBashProfile() into bashProfile
   filter bashProfile with "export PATH=*"
   
   put empty into newItems
   put quote & "'" into kwotes
   repeat for each line exportLine in bashProfile
      set the itemdelimiter to "="
      put item 2 to -1 of exportLine into pathItems
      if char 1 of pathItems is among the chars of kwotes then delete char 1 of pathItems
      if char -1 of pathItems is among the chars of kwotes then delete char -1 of pathItems
      
      replace ":$PATH" with empty in pathItems
      put pathItems & ":" after newItems
   end repeat
   delete last char of newItems
   
   set the itemdelimiter to ":"
   repeat for each item testPath in newItems
      if testPath is not among the items of extraItems then
         put testPath & ":" after extraItems
      end if
      -- put 0 into testArray [testpath]
   end repeat
   delete last char of extraItems
   return extraItems
   
   return keys (testArray)
end shell_GetBashPathExtraItems

function shell_GetBashProfile
    put shell_GetBashProfileUrl() into someURL
    return url someURL
end shell_GetBashProfile
 
function shell_GetBashProfileUrl
    put $HOME & "/.profile" into someFile -- for Tiger?
    -- put $HOME & "/.bash_profile" into someFile
    return "file:" & someFile
end shell_GetBashProfileUrl

function shell_GetBashHistory
    put $HOME & "/.bash_history" into someFile
    return url ("file:" & someFile)
end shell_GetBashHistory


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
