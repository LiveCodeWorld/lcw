script "lib_Shell"
--> MetaData
-
license: GPLv3
name: lib_Shell
type: library
version: 0.2

/*
This library is about interfacing with shell commands and utilities
Aim to spilt out lib_SSH soon, but have to update transporter dependencies for that.
*/

--> Variables
-
local LocalArray


--> Working on
-

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

on sudo_Kill
   put "#!/bin/sh" & cr into tScript
   put "pw="&tPassword & cr after tScript
   put "echo $pw | sudo -S kill -9" && tPID & cr after tScript
   return shell(tScript)
end sudo_Kill

function shell_ListProcessIds bashCommand
   put merge ("ps aux | grep '[[bashCommand]]'") into someShell
   put shell (someShell) into shellResult
   
   get "grep" && bashCommand
   put lineOffset (it, shellResult) into lineNum
   delete line lineNum of shellResult
   --
   repeat for each line sLine in shellResult
      put word 2 of sLine into pid
      put pid & comma after pids
   end repeat
   delete char -1 of pids
   return pids
end shell_ListProcessIds

command shell_Do someShell, pSomeHow, pBrowserView
   switch pSomeHow
      case "execute"
      case "xterm"
         if pBrowserView is empty then put xterm_FindView() into pBrowserView
         --          
         ttyd_Execute someShell, pBrowserView
         put the result into someJS
         return someJS
      case "paste"
         if pBrowserView is empty then put xterm_FindView() into pBrowserView
         --          
         ttyd_Paste someShell, pBrowserView
         put the result into someJS
         return someJS
      case "nohup"
         nohup_DoShell someShell
         put the result into pID
         return pID
      default
         put shell (someShell) into shellResult
         return shellResult
   end switch
end shell_Do


--> Shell | Tree
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


--> Shell | Execute
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
