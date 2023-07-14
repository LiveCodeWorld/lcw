script "lib_ShellProfile"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_ShellProfile
type: library
version: 0.1

/*
/sbin:/bin:/usr/local/bin:/usr/sbin:/System/Cryptexes/App/usr/bin:/usr/bin
/Users/david/.nvm/versions/node/v19.8.1/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin
*/


--> Working on
-
command shell_AddBashProfileToPath pNewItems
   put shell_GetMergedPath (pNewItems) into $PATH
   -- put "/usr/bin:/bin:/usr/sbin:/sbin:/opt/local/bin" into $PATH
   return $PATH
end shell_AddBashProfileToPath

function shell_GetMergedPath pNewItems
   -- copied from Terminal using "echo $PATH"
   get "/Users/david/.nvm/versions/node/v19.8.1/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin"
   split it by ":" as set
   --
   put $Path into pathArray
   split pathArray by ":" as set
   union pathArray with it 
   --
   if pNewItems is not empty then
      split pNewItems by ":" as set
      union pathArray with pNewItems 
   end if
   --
   combine pathArray with ":" as set
   return pathArray
end shell_GetMergedPath

function shell_AddZsh
   get "/Users/david/.nvm/versions/node/v19.8.1/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin"
   
   if pNewItems is empty then put shell_GetBashPathExtraItems() into pNewItems
   set the itemdelimiter to ":"
   repeat for each item someItem in pNewItems
      if someItem is not among the items of $PATH then
         put the number of items of $PATH into maxItem
         put someItem into item (maxItem + 1) of $PATH
      end if
   end repeat
end shell_AddZsh

function shell_GetZshrc
   put "source ~/.zshrc" into myCommand
   return shell(myCommand)
end shell_GetZshrc

function shell_GetPathEnv
   put "env" into myCommand
   put shell(myCommand) into myOutput
   
   repeat for each line myLine in myOutput
      if myLine begins with "PATH=" then
         put myLine into myPathLine
         exit repeat
      end if
   end repeat
   if myPathLine is empty then return empty
   
   put offset("=", myPathLine) + 1 into myPathStart
   -- put offset(":", myPathLine) into myPathEnd
   if myPathEnd = 0 then put -1 into myPathEnd
   put char myPathStart to -1 of myPathLine into myPath
   return myPath
   -- set the environment["PATH"] to myPath
end shell_GetPathEnv


--> Shell | Profile
-


--> Shell | Path
-
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


--> Not Working | Applescript
-
function appleScript_GetPathEnvironentalVariable
   put "echo $PATH" into aScript
   terminal_DoShell aScript
   put word 6 of the result into wID
   put "contents of window id" && wID into terminalShell
   put appleScript_DoLine (terminalShell, "terminal") into echoResult
   
   put "close window id" && wID into aScript
   put appleScript_DoLine (aScript, "terminal") into closeResult
   
   return  line 4 of echoResult
end appleScript_GetPathEnvironentalVariable

function appleScript_GetLiveCodePathEnvironmentalVariable
   -- totally useless, but shows how shell inherits LiveCodes value for $PATH
   -- put $PATH = appleScript_GetLiveCodePathEnvironmentalVariable() = true
   do "do shell script" && kwote ("echo $PATH") as AppleScript
   put the result into liveCodeInheritedPathVariable
   if char 1 of liveCodeInheritedPathVariable is quote then delete char 1 of liveCodeInheritedPathVariable
   if char -1 of liveCodeInheritedPathVariable is quote then delete char -1 of liveCodeInheritedPathVariable
   return liveCodeInheritedPathVariable
end appleScript_GetLiveCodePathEnvironmentalVariable


