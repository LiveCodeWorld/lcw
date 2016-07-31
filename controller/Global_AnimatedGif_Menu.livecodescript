script "Global_AnimatedGif_Menu"
--> MetaData
-
license: GPLv3
name: Global_AnimatedGif_Menu
type: controller
version: 0.2


--> Global | AnimatedGif | Menu
-
on menu_DownloadYoutubeVideo
   put youtube_DownloadVideo() into downloadedFile
   set the filename of player 1 to downloadedFile
end menu_DownloadYoutubeVideo

on _
end _

on menu_TrimMovieClip
   -- The timestamps need to be in HH:MM:SS.xxx format or in seconds. 
   put get_VideoFileName() into someVideoFile
   put false into useHMSF
   put the clip_StartTime [useHMSF] of player 1 into sTime
   put the clip_Duration [useHMSF] of player 1 into cDuration
   -- put item 1 to 3 of the clip_StartTime [true] of player 1 into sTime
   -- put item 1 to 3 of the clip_Duration [true] of player 1 into cDuration
   
   ffmpeg_TrimVideo someVideoFile, sTime, cDuration
   put the result into exportedVideoPath
   if exportedVideoPath is empty then
      answer warning "Exported file already exists!. Move, trash or rename old file before proceding?"
   else
      set the filename of player 1 to exportedVideoPath
   end if
end menu_TrimMovieClip

on menu_CreateAnimatedGif mTarget, gifSize
   if gifSize is empty then put the gif_Size of me into gifSize
   put get_VideoFileName() into someVideoFile
   file_Deconstruct someVideoFile, someRoot, shortName, fileExtension
   
   put the tempname into someTempFolder
   create folder someTempFolder
   folder_Format someTempFolder
   
   put someTempFolder & shortName & "." & fileExtension into exportFileName
   put exportFileName into exportedVideoPath
   
   revCopyFile someVideoFile, someTempFolder
   put it into someResult
   
   put the defaultFolder into oFolder
   set the defaultFolder to someTempFolder
   
   put shortName & "." & fileExtension into shortVideoFile
   put "recording-%03d.png" into shortExportFile
   put shortName & ".gif" into shortAnimatedGif
   put specialFolderPath ("Desktop") & "/" & shortAnimatedGif into deskTopVideoFile
   put someTempFolder & shortAnimatedGif into shortAnimatedGifFile
   
   shell_BashParamEscape someVideoFile
   shell_BashParamEscape exportFileName
   shell_BashParamEscape shortVideoFile
   shell_BashParamEscape shortExportFile
   shell_BashParamEscape shortAnimatedGif
   
   opn_Notify "Converting video to scaled PNG's"
   
   put "ffmpeg -i" && shortVideoFile into someShell
   put space & "-r 24" after someShell
   
   put space & "-vf scale=" & gifSize & ":-1" after someShell
   
   put space & shortExportFile after someShell
   
   set the cursor to watch
   put shell (someShell) into shellResult
   
   if word 1 to 2 of shellResult is not "ffmpeg version" then
      -- /bin/sh: line 1: ffmpeg: command not found
      put shellResult
      exit to top
   end if
   
   opn_Notify "Exported to PNG's"
   set the cursor to watch
   
   put "convert recording-001.png palette.gif" into someShell
   put shell (someShell) into shellResult
   
   opn_Notify "Created palette.gif"
   set the cursor to watch
   
   put "convert -dither none -remap palette.gif recording-*.png recording-uncompressed.gif" into someShell
   put shell (someShell) into shellResult
   
   opn_Notify "Created recording-uncompressed.gif"
   set the cursor to watch
   
   put "gifsicle --optimize=3 --delay=4 < recording-uncompressed.gif >" && shortAnimatedGif into someShell
   put shell (someShell) into shellResult
   
   opn_Notify ("Created - copying file to Desktop" && shortAnimatedGif)
   revCopyFile shortAnimatedGifFile, deskTopVideoFile
   
   finder_Reveal someTempFolder
   set the defaultFolder to oFolder
end menu_CreateAnimatedGif

on _
end _

on menu_ChooseVideo
   answer file "Choose a video"
   put it into someFileName
   if someFileName is empty then return empty
   
   set the filename of player 1 to someFileName
   return someFileName
end menu_ChooseVideo

on menu_SetDownloadFolder
   answer folder "Select a download folder"
   if it is empty then return empty
   set the defaultfolder  to it
   return it
end menu_SetDownloadFolder

on _
end _

on menu_TrimAndCropMovie
   put get_VideoFileName() into someVideoFile
   file_Deconstruct someVideoFile,  someRoot, shortName, fileExtension
   put someRoot & shortName & "_cropped." & fileExtension into exportFileName
   put exportFileName into exportedVideoPath
   
   shell_BashParamEscape someVideoFile
   shell_BashParamEscape exportFileName
   
   -- put "crop=1280:544:0:88" into cropBit
   put 1280 into cWidth
   put 544 into cHeight
   put 0 into cOriginLeft
   put 88 into cOriginTop
   
   put "crop=" & cWidth & ":" & cHeight & ":" & cOriginLeft & ":" & cOriginTop into cropBit
   
   put "ffmpeg -i" && someVideoFile && "-filter:v" &&kwote(cropBit) into someShell
   
   -- trims the end of a movie clip youtube file (they are all the same length)
   put space & "-ss 00:00:00 -t 00:02:12" after someShell
   
   put space & "-c:a copy" after someShell -- keeps the audio codec the same
   
   put space & exportFileName after someShell
   
   set the cursor to watch
   put shell (someShell) into shellResult
   put shellResult
   set the filename of player 1 to exportedVideoPath
end menu_TrimAndCropMovie

on menu_ResizeProportionally
   put the rect of this card into cRect
   rect_SubtractMargin
end menu_ResizeProportionally

on _
end _

on menu_Help
   -- http://livecode.viral.academy/view/welcome-visitors/view/animated-gif-tool
   put the short name of this stack into stackName
   put "http://livecode.viral.academy/view/welcome-visitors/view/" & fedwiki_Slugify (stackName) into someURL
   launch url someURL
end menu_Help


--> Global | AnimatedGif | Menu | Props
-
getprop gif_Size
   return "320"
end gif_Size

getprop gif_Sizes
   return "160,320,480,640,720"
end gif_Sizes


--> ffmpeg
-
command ffmpeg_TrimVideo someVideoFile, sTime, cDuration
   set the cursor to watch
   file_Deconstruct someVideoFile, someRoot, shortName, fileExtension
   put someRoot & "/" & shortName & "_trimmed." & fileExtension into exportFileName
   put exportFileName into exportedVideoPath
   
   shell_BashParamEscape someVideoFile
   shell_BashParamEscape exportFileName
   
   put "ffmpeg -i" && someVideoFile into someShell
   put space & "-ss" && sTime && "-t" && cDuration after someShell
   put space & "-c:a copy" after someShell -- keeps the audio codec the same
   put space & exportFileName after someShell
   
   put shell (someShell) into shellResult
   put line -1 of shellResult into fileBit
   if fileBit ends with "Overwrite ? [y/N] Not overwriting - exiting" then
      -- File '/Users/.../.mp4' already exists. Overwrite ? [y/N] Not overwriting - exiting
      return empty
   else
      return exportedVideoPath
   end if
end ffmpeg_TrimVideo

function youtube_DownloadVideo pTestUrl, pDownloadFolder
   if pTestUrl is empty then
      put "https://www.youtube.com/watch?v=ns-qtoxnAS8" into testUrl
      put opn_Ask ("Enter a YouTube video url...", testUrl) into pTestUrl
   end if
   
   if pDownloadFolder is empty then
      put specialFolderPath("Desktop") into pDownloadFolder
   end if
   folder_Format pDownloadFolder
   put the defaultfolder into oFolder
   set the defaultfolder to pDownloadFolder
   
   set the cursor to watch
   put youtube_ConstructDownloadShell (pTestUrl) into someShell
   put shell (someShell) into shellResult
   
   youtube_DownloadParseShellResult shellResult, shortDownloadedFile
   put pDownloadFolder & shortDownloadedFile into downloadedFile
   set the defaultfolder to oFolder
   return downloadedFile
end youtube_DownloadVideo

command youtube_DownloadParseShellResult shellResult, @shortDownloadedFile
   /*
   [youtube] ns-qtoxnAS8: Downloading webpage
   [youtube] ns-qtoxnAS8: Downloading video info webpage
   [youtube] ns-qtoxnAS8: Extracting video information
   [youtube] ns-qtoxnAS8: Searching for annotations.
   [youtube] ns-qtoxnAS8: Downloading MPD manifest
   [info] Writing video description to: Paddy's Lamentation - Gangs of New York (6_12) Movie CLIP (2002) HD-ns-qtoxnAS8.description
   [info] Writing video annotations to: Paddy's Lamentation - Gangs of New York (6_12) Movie CLIP (2002) HD-ns-qtoxnAS8.annotations.xml
   [info] Writing video description metadata as JSON to: Paddy's Lamentation - Gangs of New York (6_12) Movie CLIP (2002) HD-ns-qtoxnAS8.info.json
   [download] Destination: Paddy's Lamentation - Gangs of New York (6_12) Movie CLIP (2002) HD-ns-qtoxnAS8.mp4
   [download]   0.0% of 33.43MiB at Unknown speed ETA Unknown ETA
   [download]   0.0% of 33.43MiB at 138.07KiB/s ETA 04:08
   [download]   0.0% of 33.43MiB at 316.21KiB/s ETA 
   */
   
   -- [download] Destination: Paddy's Lamentation - Gangs of New York (6_12) Movie CLIP (2002) HD-ns-qtoxnAS8.mp4
   set the wholematches to false
   put lineoffset ("[download] Destination: ", shellResult) into lineNum
   put line lineNum of shellResult into downloadLine
   set the itemdelimiter to ":"
   delete item 1 of downloadLine
   put word 1 to -1 of downloadLine into shortDownloadedFile
end youtube_DownloadParseShellResult

function youtube_ConstructDownloadShell youtubeVideoURL
   /*
   --write-description
   Write video description to a .description file
   
   --write-info-json
   Write video metadata to a .info.json file
   
   --write-annotations
   Write video annotations to a .annotations.xml file
   */
   
   shell_BashParamEscape youtubeVideoURL
   put "youtube-dl -f mp4" && youtubeVideoURL into someShell
   put space & "--write-description" after someShell
   put space & "--write-info-json" after someShell
   put space & "--write-annotations" after someShell
   return someShell
end youtube_ConstructDownloadShell

--> Date and Time
-
function time_HmsfToSeconds hmsf
    set the itemdelimiter to ":"
    put item 1 of hmsf into someHours
    put item 2 of hmsf into someMinutes
    put item 3 of hmsf into someSeconds
    put item 4 of hmsf into someFrames
     
    add someHours * 3600 to someSeconds
    add someMinutes * 60 to someSeconds
    add someFrames / 25 to someSeconds
     
    return someSeconds
end time_HmsfToSeconds

function time_SecondsToHMSF someSeconds, someFrames
    put the numberformat into oFormat
    set the numberformat to "##"
     
    put someSeconds div 3600 into someHours 
    put someSeconds mod 3600 into secondsLeft
     
    put secondsLeft div 60 into someMinutes
    put secondsLeft mod 60 into secondsLeft
     
    put trunc(secondsLeft) into someSeconds
    put secondsLeft - someSeconds into someFraction
     
    if someFrames is empty then put round(someFraction * 25) into someFrames
    add 0 to someFrames
     
    get someHours & ":" & someMinutes  & ":" & someSeconds  & ":" & someFrames
    set the numberformat to oFormat
    return it
end time_SecondsToHMSF

function fedwiki_Slugify someTitle
   put tolower (someTitle) into someSlug
   replace space with "-" in someSlug
   return someSlug
end fedwiki_Slugify


--> Deps
-
command url_Deconstruct someURL, @someProtocol, @urlDomain, @urlPath, @shortName, @fileExtension --, @userName, @pissWord
   -- https://www.youtube.com/watch?v=jNQXAC9IVRw
   set the itemdelimiter to ":"
   put item 1 of someURL into someProtocol
   if someProtocol is not among the items of "http:https:ftp:mailto" then return false
   get item 2 to -1 of someURL
   repeat 2
      if char 1 of it = "/" then
         delete char 1 of it
      else
         exit repeat
      end if
   end repeat
   
   set the itemdelimiter to "/"
   put item 1 of it into urlDomain
   
   get item 2 to -1 of it
   set the itemdelimiter to "?"
   put item 1 of it into urlPath
   
   put item 2 to -1 of it into fileExtension
   set the itemdelimiter to "."
   put item 1 of fileExtension into shortName
   delete item 1 of fileExtension
   return true
end url_Deconstruct

command folder_Format @someFolder
   -- should be renamed "folder_Normalize"
   if someFolder is empty then return empty
   repeat while last char of someFolder is "/"
      delete last char of someFolder
   end repeat
   put "/" after someFolder
end folder_Format

command opn_Notify someText
   do "display notification" && kwote (someText) as AppleScript
end opn_Notify

function get_VideoFileName
   put the filename of player 1 into someFileName
   return someFileName
end get_VideoFileName

function opn_Ask someQuestion, pDefault
   replace "'" with quote in someQuestion
   ask someQuestion with pDefault
   put it into theResult
   if the result is "Cancel" then exit to top
   return theResult
end opn_Ask

command shell_BashParamEscape @someParam
   put word 1 to -1 of someParam into someParam
   if text_IsQuoted(someParam) is false then
      repeat for each char someChar in " |()"
         replace someChar with ("\" & someChar) in someParam
      end repeat
   end if
end shell_BashParamEscape

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

command file_Deconstruct someFile, @someRoot, @shortName, @fileExtension
    -- was "deconstruct_File"
    -- should turn someRoot into someFolder and add "/" to end
    
    if someFile is empty then
        put the effective filename of this stack into someFile
    end if
    put someFile into someRoot
    put the itemdelimiter into originalDelim
     
    set the itemdelimiter to "/"
    put last item of someFile into shortName
    delete last item of someRoot
     
    if shortName contains "." then
        set the itemdelimiter to "."
        put last item of shortName into fileExtension
        delete last item of shortName
    else
        put empty into fileExtension
    end if
    set the itemdelimiter to originalDelim
end file_Deconstruct

function kwote someText, pQuoteChar
   if pQuoteChar is empty then put quote into pQuoteChar
   return pQuoteChar & someText & pQuoteChar
end kwote

command applescript_ConvertPath @pFileOrFolder
   -- "Macintosh HD:Applications:Revolution 2.6.1:"
   put revMacFromUnixPath (pFileOrFolder) into pFileOrFolder
   put kwote(pFileOrFolder) into pFileOrFolder
   return empty
end applescript_ConvertPath

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

function object_ExtractStack someObject
   -- was "extract_StackObject"
   if someObject is empty then put the long ID of the target into someObject
   object_StackNameOffsets someObject, mainStackStart, mainStackEnd, substackStart, substackEnd
   put the result into stackObject
   return stackObject
end object_ExtractStack

command object_StackNameOffsets someObject, @mainStackStart, @mainStackEnd, @substackStart, @substackEnd
   -- now modified to look for substacks
   
   put the number of chars of someObject into lastQuoteCharNum
   put lastQuoteCharNum - 1 into mainStackEnd
   put text_OffsetBefore(quote, someObject, lastQuoteCharNum) + 1 into mainStackStart
   
   put someObject into testSubStack
   delete char (mainStackStart - 7) to -1 of testSubStack
   
   -- put offset(space & "stack" && quote, testSubStack) into substackStart
   put offset("stack" && quote, testSubStack) into substackStart
   -- put wordoffset("stack" && quote, testSubStack) into substackStart
   
   if substackStart = 0 then
      put 0 into substackEnd
      return char (mainStackStart - 7) to -1 of someObject
   else
      put 8 - 1 into tweek
      put substackStart + tweek into tSkip
      put offset(quote, testSubStack, tSkip) into substackEnd
      
      put substackStart + tweek into substackStart
      put substackEnd + tSkip - 1 into substackEnd
      return char (substackStart - 7) to -1 of someObject
   end if
end object_StackNameOffsets

getprop stack_Object
   put the long ID of the target into targetObject
   get object_ExtractStack (targetObject)
   return it
end stack_Object

function text_OffsetBefore someString, someText, beforeHere
   if beforeHere is not empty then
      delete char beforeHere to -1 of someText
   end if
   put 0 into skipNum
   repeat
      get offset (someString, someText, skipNum)
      if it is 0 then
         return skipNum
      else
         add it to skipNum
      end if
   end repeat
end text_OffsetBefore
