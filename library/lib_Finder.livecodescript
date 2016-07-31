script "lib_Finder"
--> MetaData
-
license: GPLv3
name: lib_Finder
type: library
version: 0.1


--> Finder | Wrappers
-
command wrangler_Open
   -- tell application "Finder" to open file "Macintosh HD:Users:david:Documents:My Revolution Enterprise:Plugins:opn_Plugins:opn_Text:rev:handlers:card_Object_g:hierarchical_dot.xdot" using "Macintosh HD:Applications:TextEdit.app:"
   -- finder_Open someFile, "Macintosh HD:Applications:TextEdit.app:"
   finder_Open someFile, "Macintosh HD:Applications:TextWrangler.app:"
   return the result
end wrangler_Open

command preview_Image imagePath
   finder_Open imagePath, "Macintosh HD:Applications:Preview.app:"
   return the result
end preview_Image


--> Finder | Prefs
-
function finder_GetShowInvisibleFiles
   put shell ("defaults read com.apple.finder AppleShowAllFiles") into shellResult
   return word 1 of shellResult = "YES"
end finder_GetShowInvisibleFiles

command finder_SetShowInvisibleFiles someBoolean
   if someBoolean is true then
      put shell ("defaults write com.apple.finder AppleShowAllFiles YES") into shellResult
   else
      put shell ("defaults write com.apple.finder AppleShowAllFiles NO") into shellResult
   end if
end finder_SetShowInvisibleFiles

command finder_Restart
   put shell ("killall Finder") into shellResult
end finder_Restart


--> Finder
-
command finder_PositionWindow appName, someRect, windowName
    -- not really scripting the Finder it depends on the Apps support for "bounds of window"
    if windowName is empty then
        put 1 into windowName	# Skype Video
    else if windowName is not a number then
        put kwote(windowName) into windowName
    end if
    
    put merge("set the bounds of window [[windowName]] to {[[someRect]]}") into appleScriptLine
    return appleScript_DoLine(appleScriptLine, appName, true)	
end finder_PositionWindow

function finder_GetFrontApplication
    -- more useful to get all the application names
    return appleScript_DoLine("system Events", "set myApp to name of first application process whose frontmost is true")	
end finder_GetFrontApplication

function finder_Disks
    put "tell application" && kwote("Finder") into someAppleScript
    put return & "disks" after someAppleScript
    put return & "end tell" after someAppleScript
    -- return someAppleScript
    
    do someAppleScript as AppleScript
    put the result into diskRecord
    delete char 1 of diskRecord
    delete char -1 of diskRecord
    return diskRecord
end finder_Disks

command finder_EjectDisk diskName
    put "tell application" && kwote("Finder") into someAppleScript
    put return & "eject disk" && kwote(diskName) && "of application" && kwote("Finder") after someAppleScript
    put return & "end tell" after someAppleScript
    
    do someAppleScript as AppleScript
    return the result
end finder_EjectDisk

command finder_Reveal pFileOrFolder
   -- does not work for package contents?
   
   if pFileOrFolder is empty then
      put the stack_Object of the target into stackObject
      put the effective filename of stackObject into pFileOrFolder
   end if
   
   put there is a folder pFileOrFolder is true into isFolder
   if isFolder is false then
      if there is a file pFileOrFolder is false then
         put empty into isFolder
      end if
   end if
   
   put folder_Above(pFileOrFolder) into enclosingFolder
   
   applescript_ConvertPath pFileOrFolder
   applescript_ConvertPath enclosingFolder
   
   put "tell application" && kwote("Finder") into someAppleScript
   put CR & tab & "activate" after someAppleScript
   put CR & tab & "open folder" && enclosingFolder after someAppleScript
   
   put CR & "if file" && pFileOrFolder && "exists then" after someAppleScript
   put CR & tab & "set appleScriptPath to file" && pFileOrFolder after someAppleScript
   put CR & "else" after someAppleScript
   put CR & tab & "set appleScriptPath to folder" && pFileOrFolder after someAppleScript
   put CR & "end if" after someAppleScript
   
   put CR & tab & "set toselectList to {}" after someAppleScript
   put CR & tab & "set end of toselectList to appleScriptPath" after someAppleScript
   put CR & tab & "select toselectList" after someAppleScript
   
   put CR & "end tell" after someAppleScript
   
   do someAppleScript as AppleScript
   -- put someAppleScript
   return the result
end finder_Reveal

command folder_Open someFolder
   finder_Reveal someFolder
end folder_Open

command finder_SelectFileOrFolder pFileOrFolder
    applescript_ConvertPath pFileOrFolder
    
    put "tell application" && kwote("Finder") into someAppleScript
    put CR & tab & "set appleScriptPath to file" && pFileOrFolder after someAppleScript
    put CR & tab & "set toselectList to {}" after someAppleScript
    put CR & tab & "set end of toselectList to appleScriptPath" after someAppleScript
    put CR & tab & "select toselectList" after someAppleScript
    put CR & "end tell" after someAppleScript
    
    do someAppleScript as AppleScript
    put someAppleScript
    return the result
end finder_SelectFileOrFolder

command finder_BringToFront appName
    if appName is empty then put "Revolution" into appName
    put "tell application '[[appName]]'" into doScript
    put cr & "activate" after doScript
    put cr & "end tell"  after doScript
    replace "'" with quote in doScript
    get merge(doScript)
    do it as AppleScript
    return the result
end finder_BringToFront

command finder_Open someFile, pUsingAppleScriptAppPath, pStripQuotes, pDisplayScript
   -- tell application "Finder" to open file "Macintosh HD:Users:david:Documents:My Revolution Enterprise:Plugins:opn_Plugins:opn_Text:rev:handlers:card_Object_g:hierarchical_dot.png"
   applescript_ConvertPath someFile
   put "open file" && someFile into aLine
   if pUsingAppleScriptAppPath is not empty then put space & "using" && kwote(pUsingAppleScriptAppPath) after aLine
   put appleScript_DoLine (aLine, "Finder", pStripQuotes, pDisplayScript) into someResult
   return someResult
end finder_Open
