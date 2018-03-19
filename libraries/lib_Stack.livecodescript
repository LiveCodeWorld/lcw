script "lib_Stack"
--> MetaData
-
license: GPLv3
name: lib_Stack
type: library
version: 0.4
copyright: David Bovill

/*
A library for stuff about stacks.
Todo:  separate out essentials and utilities => lib_StackExtras
*/


--> Props
-
getprop card_Object
   -- ideCoreCardOfcontrol§
   -- always returns an object
   put the long id of the target into targetObject
   switch
      case word 1 of targetObject = "card"
         return targetObject
      case word 1 of targetObject = "stack"
         if the scriptonly of targetObject is true then
            return the long id of card 1 of the defaultstack
         else
            put the currentcard of the defaultstack into cardName
            put the long id of card cardName of the defaultstack into cardObject
            return cardObject
         end if
      case word 1 of targetObject is among the items of "background,bkgnd,bg"
         return empty  -- no such thing as a unique card_Object
      default
         put wordOffset ("card", targetObject) into wNum
         return word wNum to -1 of targetObject
   end switch
end card_Object

getprop stack_Name
   return the short name of the defaultstack
end stack_Name

getprop stack_Object
   -- revTargetStack
   return the defaultstack
end stack_Object

getprop stack_Label
   put the stack_Object of the target into stackObject
   put the label of stackObject into someLabel
   return someLabel
end stack_Label

setprop stack_Label someLabel
   put the stack_Object of the target into stackObject
   set the label of stackObject to someLabel
   return stackObject
end stack_Label

getprop stack_CompressedData
   put the effective filename of the target into someFile
   put "file:" & someFile into someUrl
   put url someUrl into stackData
   return compress(stackData)
end stack_CompressedData

getprop stack_Data
   put the effective filename of the target into someFile
   put "binfile:" & someFile into someUrl
   put url someUrl into stackData
   return stackData
end stack_Data

getprop stack_SisterFolder [projectName]
   put the effective filename of the defaultstack into sisterFolder
   put folder_GetSister (projectName, someFileOrFolder) into sisterFolder
   return sisterFolder
end stack_SisterFolder

getprop stack_IsPalette
   put the stack_Object of the target into stackObject
   return the style of stackObject = "palette"
end stack_IsPalette

setprop stack_IsPalette someBoolean
   put the stack_Object of the target into stackObject
   if someBoolean is true then
      set the style of stackObject to "palette"
   else
      set the style of stackObject to "toplevel"
   end if
end stack_IsPalette

getprop stack_Resizable
   put the stack_Object of the target into stackObject
   if exists(stackObject) then
      return the resizable of stackObject
   else
      return false
   end if
end stack_Resizable

setprop stack_Resizable someBoolean
   put the stack_Object of the target into stackObject
   set the resizable of stackObject to someBoolean
end stack_Resizable

getprop stack_TitleStyle
   put the stack_Object of the target into stackObject
   switch the decorations of stackObject
      case "default"
         return "normal"
      case "noShadow"
         return "no title"
   end switch
end stack_TitleStyle

setprop stack_TitleStyle titleStyle
   put the stack_Object of the target into stackObject
   switch titleStyle
      case "normal"
         set the decorations of stackObject to default
         break
      case "no title"
         set the decorations of stackObject to "noShadow"
         break
   end switch
end stack_TitleStyle

getprop stack_TitleStyles
   return "normal,no title"
end stack_TitleStyles

getprop stack_Type
   put the stack_Object of the target into stackObject
   return the uOPN ["stack_Type"] of stackObject
end stack_Type

setprop stack_Type typePath
   put the stack_Object of the target into stackObject
   set the uOPN ["stack_Type"] of stackObject to typePath
end stack_Type

getprop stack_IsVisible
   put the stack_Object of the target into stackObject
   if the visible of stackObject is true then
      if the blendlevel of stackObject > 5 then
         return false
      else
         return true
      end if
   else
      return false
   end if
end stack_IsVisible

setprop stack_IsVisible someBoolean
   put the stack_Object of the target into stackObject
   set the visible of stackObject to someBoolean
   if someBoolean is true then set the blendlevel of stackObject to 0
end stack_IsVisible

getprop stack_Faded
   put the stack_Object of the target into stackObject
   if the blendlevel of stackObject > 95 then
      return true
   else if the blendlevel of stackObject < 5 then
      return false
   else
      return empty
   end if
end stack_Faded

setprop stack_Faded boolean
   put the long id of the target into targetObject
   put the stack_Name of targetObject into stackName
   if boolean is false then
      stack_BlendIn stackName
   else
      stack_BlendOut stackName
   end if
end stack_Faded

getprop stack_Outline
   put the short name of the stack_Object of the target into stackName
   return stack_SubStackOutline(stackName)
end stack_Outline


--> Working on
-
command stack_RevealInFinder stackName
   put the filename of stack stackName into someFile
   finder_RevealFileOrFolder someFile
   get the result
   return it
end stack_RevealInFinder

function stack_ExtractScriptOnlyName stackData
   -- put word 1 of "Ôªøscript "lib_Audioboom"
   get line 1 of stackData
   if word 1 of it is not "Ôªøscript" then return empty
   put token 2 of stackData into stackName
   return stackName
end stack_ExtractScriptOnlyName

command stack_SaveBinaryData stackData, someFile
   put "binfile:" & someFile into stackUrl    
   put the filetype into oFileType
   set the filetype to "revoRSTK"
   put stackData into url stackUrl
   set the filetype to oFileType
end stack_SaveBinaryData


--> Stack | Data
-
command stack_CreateFileFromBinaryData binaryData, newFile
   put "binfile:" & newFile into newUrl
   if the platform is "MacOs" then
      --   Note:  Revolution's creator signature is 'Revo'. The file type for a stack file created by Revolution is 'RSTK'. 
      -- The fileType is an eight-character string. The first four characters are the creator signature, and the last four are the file type. 
      
      put the filetype into oFileType
      set the filetype to "RevoRSTK"
   end if
   
   put binaryData into url newUrl
   if the platform is "MacOs" then
      set the filetype to oFileType
   end if
end stack_CreateFileFromBinaryData


--> Stack | Convert
-
function stack_ConvertNamesToShortPaths stackNames, @badNames
   put empty into badNames
   replace comma with CR in stackNames
   set the itemdelimiter to slash
   repeat for each line stackName in stackNames
      if there is a stack stackName then
         get the filename of stack stackName
         put item -1 of it into shortPath
         put shortPath & CR after shortPaths
      else
         put stackName & CR after badNames
      end if
   end repeat
   delete char -1 of badNames
   delete char -1 of shortPaths
   return shortPaths
end stack_ConvertNamesToShortPaths

function stack_ConvertObjectsToShortPaths stackObjects
   set the itemdelimiter to slash
   repeat for each line stackObject in stackObjects
      get the filename of stackObject
      put item -1 of it into shortPath
      put shortPath & CR after shortPaths
   end repeat
   delete char -1 of shortPaths
   return shortPaths
end stack_ConvertObjectsToShortPaths

function stack_ConvertObjectsToPaths stackObjects
   repeat for each line stackObject in stackObjects
      get the filename of stackObject
      put it & CR after stackPaths
   end repeat
   delete char -1 of stackPaths
   return stackPaths
end stack_ConvertObjectsToPaths

function stack_ConvertPathsToNames stackPaths
   put stack_ConstructNameNameArray (stackPaths) into nameArray
   put keys (nameArray) into stackNames
   sort stackNames
   return stackNames
end stack_ConvertPathsToNames


--> Stack | Memory
-
command stack_CloseLoaded pDontSave
   put revLoadedStacks() into stackNames
   repeat for each line stackName in stackNames
      if pDontSave is not true then
         save stack stackName
      end if
      delete stack stackname
   end repeat
end stack_CloseLoaded

command stack_RevertLoaded pStackNames, pLockMessages
   if pStackNames is empty then put revLoadedStacks() into pStackNames
   if pLockMessages is not false then set the lockmessages to true
   repeat for each line stackName in pStackNames
      -- if we have changed the name of the stack and not saved...
      -- the stack name of the stack on disk may differ from the one in memory
      
      put the filename of stack stackName into someFile
      put shortName into revertedArray [stackName]["old name"]
      put someFile into revertedArray [stackName]["file"]
      
      revert stack someFile
      
      put the short name of stack someFile into newName
      put newName into revertedArray [stackName]["new name"]
   end repeat
   if pLockMessages is not false then set the lockmessages to false
   return revertedArray
end stack_RevertLoaded

command stack_RevertToLocalVersion mainStackName
   breakpoint
   stack_RemoveFromMemory mainStackName
   
   put opn_GetFileName(mainStackName) into someFile
   go to stack someFile
   if the result is empty then
      return stackFile
   else
      lcw_Notify (the result & CR & someFile), true
      return empty
   end if
end stack_RevertToLocalVersion

function stack_GetIsUsed stackName
   set the wholematches to true
   put stackName is among the lines of the stacksinuse into someBoolean
   return someBoolean
end stack_GetIsUsed

command stack_GoLocal someObject
   breakpoint
   put the mainstack of the stack_Object of someObject into mainStackName
   stack_RevertToLocalVersion mainStackName
end stack_GoLocal

command stack_SaveLoaded pDisplayObject
   breakpoint
   put revLoadedStacks ("application") into stackNames
   repeat for each line stackName in stackNames
      set the cursor to busy
      _DisplayStackSave stackName, pDisplayObject
      put the result into stackObject
      if stackObject is empty then next repeat
      
      stack_Save stackObject
   end repeat
end stack_SaveLoaded

private command _DisplayStackSave stackName, pDisplayObject
   if exists(stack stackName) is false then
      lcw_Notify merge("Cannot find stack '[[stackName]]'!"), true
      return empty
   else
      put the name of stack stackName into stackObject
      if exists (pDisplayObject) then
         dispatch "display_StackSave stackObject" to pDisplayObject 
      else
         lcw_Notify merge("Saved stack '[[stackName]]'!"), false
      end if
   end if
   return stackObject
end _DisplayStackSave


--> Working on
-
command stack_ConvertScriptOnly stackNameOrPath
   if the scriptOnly of stack stackNameOrPath is false then
      breakpoint
      return empty
   end if
   
   put the short name of stack stackNameOrPath into oStackName
   put the script of stack stackNameOrPath into oStackScript
   put the rect of stack stackNameOrPath into oRect
   
   put the filename of stack stackNameOrPath into oFileName
   set the itemdelimiter to slash
   put item -1 of oFileName into shortFile
   put the tempname & slash into tempFolder
   folder_Createnested tempFolder
   put tempFolder & shortFile into tempFileName
   
   --
   set lockmessages to true    
   set the filename of stack oStackName to tempFileName
   put "temp_" & oStackName into tempStackName
   set the name of stack oStackName to tempStackName
   
   set the destroystack of stack tempStackName to true
   set the destroywindow of stack tempStackName to true
   save stack tempStackName
   
   create invisible stack oStackName
   set the rect of stack oStackName to oRect
   set the filename of stack oStackName to oFileName
   set the script of stack oStackName to oStackScript
   show stack oStackName
   --
   save stack oStackName
   set lockmessages to false
   
   return tempFileName
end stack_ConvertScriptOnly

command stack_ToggleShrink pStackObject
   if pStackObject is empty then
      put the topStack into pStackObject
   end if
   put the scalefactor of pStackObject into oFactor
   if oFactor = 1 then
      stack_Shrink pStackObject, 0.75
   else
      stack_Shrink pStackObject, 1
   end if
end stack_ToggleShrink

command stack_Shrink scriptObject, pScaleFactor
   if pScaleFactor is empty then put 0.7 into pScaleFactor
   
   put the stack_Name of scriptObject into stackName
   lock screen
   put the topleft of stack stackName into oTopLeft
   set the scaleFactor of stack stackName to pScaleFactor
   
   -- bug in screen rects for shrunk stacks
   put pScaleFactor * item 1 of oTopLeft into item 1 of shrunkTopLeft
   put pScaleFactor * item 2 of oTopLeft into item 2 of shrunkTopLeft
   set the topleft of stack stackName to shrunkTopLeft
   unlock screen
   -- put oTopLeft
end stack_Shrink

command stack_SetToMainScreen stackNames, pScreenRect
   if pScreenRect is empty then
      put the working screenrect into pScreenRect
   end if
   put rect_SubtractMargin (60, pScreenRect) into safeRect
   put item 1 to 2 of safeRect into safeTopLeft
   
   repeat for each line stackName in stackNames
      put the rect of stack stackName into stackRect
      if rect_FitsWithin (stackRect, safeRect) is false then
         if the resizable of stack stackName is true then
            rect_MoveTopLeft stackRect, safeTopLeft
            rect_Normalize stackRect, safeRect
            set the rect of stack stackName to stackRect
         else
            set the topleft of stack stackName to safeTopLeft
         end if
      end if
   end repeat
end stack_SetToMainScreen


--> Stack | Utilities
-
command stack_StripUnsaved @stackNames
   repeat for each line stackName in stackNames
      if exists (stack stackName) is false then next repeat
      if the filename of stack stackName is empty then next repeat
      put stackName & CR after goodStackNames
   end repeat
   delete char -1 of goodStackNames
   sort goodStackNames
   put goodStackNames into stackNames
end stack_StripUnsaved

command stack_Drag stackObject
   if stackObject is empty then put the stack_Object of the target into stackObject
   put the rect of stackObject into oRect
   -- put the the globalloc of the clickloc into fromPoint
   put the screenmouseloc into fromPoint
   
   repeat while the mouse is "Down"
      put the screenmouseloc into toPoint
      loc_SetTranslationVector fromPoint, toPoint, xVector, yVector
      put rect_TranslateByVector(oRect, xVector, yVector) into newRect
      set the rect of stackObject to newRect
   end repeat
end stack_Drag

command stack_UseIfNeeded stackName
   if exists(stack stackName) is false then
      put merge("Error: Cannot locate library stack '[[stackName]]'") into someError
      return someError
   end if
   
   set the wholematches to true
   if stackname is not among the lines of the stacksinuse then
      start using stack stackName
   end if
   return empty
end stack_UseIfNeeded

command rect_MoveTopLeft @someRect, newTopLeft
   put item 1 of newTopLeft - item 1 of someRect into xVector
   put item 2 of newTopLeft - item 2 of someRect into yVector
   put rect_TranslateByVector (someRect, xVector, yVector) into someRect
end rect_MoveTopLeft

--> Stack | Create
-
command palette_View viewName, pCardMargin, pStackRect, pHidden
   view_CloneStack viewName, pCardMargin, pStackRect, pStackStyle, pHidden
   put the result into createdView
   return createdView
end palette_View

command view_CloneStack viewName, pCardMargin, pStackRect, pStackStyle, pHidden
   -- this is not cloning the stack but the view onto a clean stack
   local pCardScript
   put stack_ConstructNewCloneName (viewName) into stackName
   stack_Create stackName, viewName, pCardMargin, pStackRect, pCardScript, pHidden, pStackStyle
   put the result into createdView
   return createdView
end view_CloneStack

command stack_Create stackName, viewName, pCardMargin, pStackRect, pCardScript, pHidden, pStackStyle
   view_CreateHiddenStack viewName, stackName, pCardMargin, pStackStyle, pCardScript
   put the result into createdObject
   
   put the stack_Object of createdObject into stackObject
   if pStackRect is empty then
      put the width of createdObject into sWidth
      put the height of createdObject into sHeight
      stack_SetDimensions stackObject, sWidth, sHeight, pCardMargin
   else
      set the rect of stackObject to pStackRect
   end if
   
   if pHidden is not true then set the visible of stackObject to true
   return createdObject
end stack_Create

command view_CreateHiddenStack controlOrViewName, pStackName, pCardMargin, pStackStyle, pCardScript
   if exists (controlOrViewName) then
      put controlOrViewName into templateObject
      put the view_Name of controlOrViewName into viewName
      if viewName is empty then
         put lcw_Ask ("Give this new control a view_Name...", "View|Something|Or Other") into viewName
      end if
   else
      put controlOrViewName into viewName
      put view_GetTemplateObject (viewName) into templateObject
      if exists(templateObject) is false then return empty
   end if
   
   if pStackName is empty then
      put stack_ConstructNewCloneName (viewName) into pStackName
   else if exists (stack pStackName) is true then
      put stack_ConstructNewCloneName (pStackName) into pStackName
   end if
   
   set lockmessages to true -- Constellation bug
   create invisible stack pStackName
   put it into stackObject
   set lockmessages to false
   set the destroystack of stackObject to true
   set the destroywindow of stackObject to true
   if pStackStyle is not empty then set the style of stackObject to pStackStyle
   
   put the long id of card 1 of stackObject into cardObject
   set the card_Margin of cardObject to pCardMargin
   
   if pCardScript is empty then put scaffold_GetTemplate ("Resize view stack") into pCardScript -- better to use a behavior !!!
   set the script of cardObject to pCardScript
   
   copy templateObject to cardObject
   put it into createdObject
   return createdObject
end view_CreateHiddenStack

function stack_ConstructNewCloneName stackName
   put stack_ClonedStackNames(stackName) into stackNames
   sort numeric descending stackNames by last word of each
   put line 1 of stackNames into realStackName
   put word -1 of realStackName into cloneNumber
   if cloneNumber is a number then
      add 1 to cloneNumber
   else
      put 1 into cloneNumber
   end if
   
   put (stackName && cloneNumber) into newClonedName
   if exists(stack newClonedName) is false then
      return newClonedName
   else
      breakpoint
      return empty
   end if
end stack_ConstructNewCloneName

function stack_ClonedStackNames stackName
   put the mainstacks into stackNames
   filter stackNames with (stackName & "*")
   put word 1 to -1 of stackNames into stackNames
   if stackNames is empty then return stackName
   return stackNames
end stack_ClonedStackNames

function stack_NotNeeded
   -- they may be needed :)
   local mainStackNames
   
   put revLoadedStacks("application") into stackNames
   repeat for each line stackName in stackNames
      get the mainstack of stack stackName
      line_Add it, mainStackNames
   end repeat
   
   repeat for each line usedStackName in the stacksinuse
      put the mainstack of stack usedStackName into mainStackName
      put the short name of stack mainStackName into stackName
      line_Delete stackName, mainStackNames
   end repeat
   
   repeat for each line someObject in the backscripts
      put the stack_Object of someObject into someStack
      put the short name of the mainstack of someStack into stackName
      line_Delete stackName, mainStackNames
   end repeat
   
   repeat for each line someObject in the frontscripts
      put the stack_Object of someObject into someStack
      put the short name of the mainstack of someStack into stackName
      line_Delete stackName, mainStackNames
   end repeat
   return mainStackNames
end stack_NotNeeded


--> Stack | Delete
-
command stack_DeleteFile stackObject
   put the filename of stackObject into someFile
   if there is a file someFile then
      go to stackObject 
      answer merge("Are you sure you want to delete the file [[someFile]]?") with "OK" or "Cancel" as sheet
      try
         set the stack_IsKnown of stackObject to false
         set the stack_IsLibrary ["All"] of stackObject to false
         stack_ClearFrontAndBackLibraries stackObject
         stack_DeleteScriptFolder stackObject
         -- hdb_DeleteStackKeys stackObject, true
         
         delete stackObject
         file_Delete someFile
      catch e
         lcw_Notify e
         answer warning merge("There was a problem deleting [[stackObject]] or file!")
      end try
   else
      lcw_Notify merge("File [[someFile]] does not exist")
      put someFile
   end if
end stack_DeleteFile

command stack_ClearFrontAndBackLibraries stackObject
   -- used when deleting a stack (dummy for now)
   -- should check for front and back scripts libraries withing the stack
   -- then remove from library database
end stack_ClearFrontAndBackLibraries

command stack_DeleteScriptFolder stackObject
   -- used when deleting a stack
   put the data_Folder of stackObject into scriptFolder
   folder_Delete scriptFolder, true
end stack_DeleteScriptFolder


--> Stack | Visual Effects
-
command stack_Display someObject, someRect, fadeIn
   put the stack_Object of someObject into stackObject
   go invisible stackObject
   if someRect is a rect then set the rect of stackObject to someRect
   if fadeIn is true then
      set the blendlevel of stackObject to 100
      set the stack_Faded of stackObject to false
   else
      set the visible of stackObject to true
   end if
end stack_Display

command stack_BlendIn stackName, someDelay
   if someDelay is empty then put 5 into someDelay
   if the visible of stack stackName is false then
      set the blendlevel of stack stackName to 100
      set the visible of stack stackName to true
   end if
   
   put the blendlevel of stack stackName into someValue
   subtract 1 from someValue
   set the blendlevel of stack stackName to someValue
   if someValue <= 0 then
      set the blendlevel of stack stackName to 0
      return true
   else
      put "stack_BlendIn" && kwote(stackName) into pigeon
      send pigeon to me in someDelay milliseconds
      return false
   end if
end stack_BlendIn

command stack_BlendOut stackName, someDelay
   if someDelay is empty then put 5 into someDelay
   
   put the blendlevel of stack stackName into someValue
   add 1 to someValue
   set the blendlevel of stack stackName to someValue
   if someValue >= 100 then
      set the blendlevel of stack stackName to 100
      return true
   else
      put "stack_BlendOut" && kwote(stackName) into pigeon
      send pigeon to me in someDelay milliseconds
      return false
   end if
end stack_BlendOut


--> Stack | Utilities
-
command stack_SetViewSize someSize
   switch someSize
      case "Full screen"
         put the loc of this stack into someLoc
         repeat for each line someRect in the screenrects
            if loc_WithinRect(someLoc, someRect) then
               set the rect of this stack to someRect
            end if
         end repeat
         break
      case "1280 x 800"
         put the rect of this stack into someRect
         if item 2 of someRect < 44 then put 44 into item 2 of someRect
         put rect_FromWidthAndHeight(someRect, 1280, 800) into newRect
         set the rect of this stack to newRect
         break
      case "1024 x 768"
         put the rect of this stack into someRect
         if item 2 of someRect < 44 then put 44 into item 2 of someRect
         put rect_FromWidthAndHeight(someRect, 1024, 768) into newRect
         set the rect of this stack to newRect
         
         break
      case "800 x 600"
         put the rect of this stack into someRect
         if item 2 of someRect < 44 then put 44 into item 2 of someRect
         put rect_FromWidthAndHeight(someRect, 800, 600) into newRect
         set the rect of this stack to newRect
         break
   end switch
end stack_SetViewSize

command stack_PlaceGroupOnAllCards groupName, stackName
   -- was "opn_PlaceGroupOnAllCards"
   if stackName is empty then
      put the long id of this stack into stackObject
   else
      put the long id of stack stackName into stackObject
   end if
   put the cardids of stackObject into idIndex
   
   put the defaultstack into oDefault
   set the defaultstack to stackObject
   set the wholematches to true
   put empty into placedIDs
   repeat for each line someID in idIndex
      if groupName is not among the lines of (the groupnames of card id someID) then
         place group groupName onto card id someID
         put someID & return after placedIDs
      end if
   end repeat
   delete last char of placedIDs
   set the defaultstack to oDefault
   return placedIDs
end stack_PlaceGroupOnAllCards


--> Stack | Open, Close and Move
-
command stack_Rename oldName, pNewName, pDontRenameFile
   if pNewName is empty then
      put lcw_Ask ("What would you like to rename this stack to?", oldName) into pNewName
      repeat
         if exists (stack pNewName) then
            put lcw_Ask ("Stack exists. Try another name?", oldName) into pNewName
         else
            exit repeat
         end if
      end repeat
   end if
   
   -- a check
   put exists(stack oldName) and exists(stack pNewName) is false into okToRename
   if okToRename is false then
      -- should warn?
      return empty
   end if
   
   put the filename of stack oldName into oldFileName
   put oldFileName into newFileName
   put pNewName & ".rev" into newShortFile 
   set the itemdelimiter to "/"
   put newShortFile into item -1 of newFileName
   
   if pDontRenameFile is true then return oldFileName
   
   put the data_Folder of stack oldName into sourceFolder
   
   ## Rename the stack
   git_RenameFile oldFileName, newFileName
   -- rename file fromFile to toFile
   set the name of stack oldName to pNewName
   set the filename of stack pNewName to newFileName
   save stack pNewName
   
   put the data_Folder of stack pNewName into destFolder
   
   ## Now if there is a object script folder for this stack rename
   git_RenameFolder sourceFolder, destFolder
   
   return newFileName
end stack_Rename

command stack_Delete stackName
   if there is not a stack stackName then return merge("Error: stack '[[viewName]]' does not exist!")
   put the filename of stack stackName into someFile
   stack_RemoveFromMemory stackName
   file_Delete someFile, true
   put the result into deleteResult
   
   put the name of stack stackName into oldStack
   library_RemoveStackFromKnown oldStack
   
   -- opn_DeleteFromObjectIndex someName, objectType, someObject
   -- opn_DeleteLibraryType libraryType
   return deleteResult
end stack_Delete

command stack_MoveFile fromFile, toFile
   breakpoint
   if exists(the svn_Library of me) then
      svn_Move fromFile, toFile
   else
      rename file fromFile to toFile
   end if
end stack_MoveFile

command stack_Save someObject, pClean, pCleanGeometry, pFilePath, pMacStackFileType
   put the stack_Object of someObject into stackObject
   if pFilePath is empty then put the effective fileName of stackObject into pFilePath
   if pFilePath is empty or theFilePath is "ask" then
      put the short name of stackObject into theTitle
      put ".rev" after theTitle
      ask file "Type a name for this stack and save it:" with theTitle
      put it into pFilePath
      
      if pFilePath is empty then return "cancel"
   end if
   
   if pClean is not false then
      -- cleans every object, then saves and compacts
      rev_CleanStack stackObject, pCleanGeometry
      put the result into cleanInfo
      -- lcw_Notify cleanInfo
   else
      do "compact" && stackObject
      if pMacStackFileType is empty then put "revoRSTK" into pMacStackFileType
      put the filetype into oFiletype
      set the filetype to pMacStackFileType
      lock messages
      save stackObject as pFilePath
      unlock messages
      set the filetype to oFiletype
   end if
   
   global gREVStackStatus
   put the short name of stackObject into stackName
   delete global gREVStackStatus [stackName]
   
   return empty
end stack_Save

command stack_CopyFile oldStackFile, newStackFile
   -- one way of doing it (using url's)
   -- may be the most reliable?
   -- revCopyFile longFile, opnArchiveFile (uses applescript etc)
   -- put the result
   
   put "binfile:" & oldStackFile into oldStackUrl
   put "binfile:" & newStackFile into newStackUrl
   
   put the filetype into oFileType
   set the filetype to "revoRSTK"
   put url oldStackUrl into url newStackUrl
   set the filetype to oFileType
end stack_CopyFile

command stack_CloneAndMakeSubStack toCloneNames, pMyStackname
   if pMyStackname is empty then 
      put the short name of the target into pMyStackname
   end if
   replace comma with CR in toCloneNames
   
   repeat for each line toCloneName in toCloneNames
      set the cursor to busy
      if there is not a stack toCloneName then next repeat
      
      clone stack toCloneName
      put it into clonedStack
      put the short name of clonedStack into clonedName
      set the mainstack of clonedStack to pMyStackname
      set the name of stack clonedName of stack pMyStackname to toCloneName
   end repeat
end stack_CloneAndMakeSubStack

command stack_DeleteSubStackClones stackNameList, myStackName
   replace comma with CR in stackNameList
   repeat for each line toDeleteName in stackNameList
      set the cursor to busy
      if there is not a stack toDeleteName of stack myStackname then next repeat
      delete stack toDeleteName of stack myStackname
   end repeat
   save stack myStackName
end stack_DeleteSubStackClones

command stack_CloseSub stackName
   put the substacks of stack stackName into theSubStacks
   repeat for each line theSubStack in theSubStacks
      send "stack_RemoveFromMemory stackName" to me in 10 millisecs
   end repeat
end stack_CloseSub


--> Stack | Is
-
function stack_CheckProtected stackName
   put the password of stack stackName into pWord
   return pWord is true
   
   -- this doe snot waork for new versions of LiveCode
   put the passKey of stack stackName into pKey
   put pWord <>  pKey into isProtected
   return isProtected
end stack_CheckProtected

getprop stack_IsProtected
   put the stack_Name of the target into stackName
   return stack_CheckProtected (stackName)
end stack_IsProtected

function stack_Exists someName
   -- will not add stack to memory
   
   set lockmessages to true
   put the mainstacks into stacksInMemory
   put empty into shortStackName
   if exists(stack someName) then
      put true into safeExistence
      put not(shortStackName is among the lines of stacksInMemory) into needToClose
      if needToClose then
         stack_RemoveFromMemory someFile
      end if
   else
      put false into safeExistence
   end if
   set lockmessages to false
   return safeExistence
end stack_Exists

function stack_IsOpen stackName
   set the wholematches to true
   return stackName is among the lines of the openstacks
end stack_IsOpen

getprop stack_IsLoaded
   put the stack_Object of the target into stackObject
   put stack_GetIsLoaded (stackObject) into someBoolean
   return someBoolean
end stack_IsLoaded

function stack_GetIsLoaded stackObject
   if there is a stackObject then
      return true
   else
      return false
   end if
   if stackObject is empty then return false
   
   put stack_LoadedPaths() into stackNamePaths
   put word -1 of stackObject into theStackPath
   replace quote with empty in theStackPath
   if theStackPath is among the lines of stackNamePaths then
      return true
   else
      return false
   end if
end stack_GetIsLoaded

getprop stack_IsUsed
   put the stack_Name of the target into stackName
   put stack_GetIsUsed (stackName) into someBoolean
   return someBoolean
end stack_IsUsed

function stack_GetIsUsed stackName
   set the wholematches to true
   put stackName is among the lines of the stacksinuse into someBoolean
   return someBoolean
end stack_GetIsUsed

function stack_LoadedPaths
   put the mainstacks into stackNames
   repeat for each line stackName in stackNames
      put the filename of stack stackName into theFilePath
      if theFilePath is empty then put stackName into theFilePath
      put theFilePath & CR after stackNamePaths
   end repeat
   delete char -1 of stackNamePaths
   return stackNamePaths
end stack_LoadedPaths

function stack_IsClosed stackName
   set the wholematches to true
   put stackName is not among the lines of the mainstacks into stackIsClosed
   return stackIsClosed
end stack_IsClosed


--> Stack | Names
-
function stack_ConstructNameNameArray stackPaths
   local nameArray
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      
      put the short name of stack stackPath into stackName
      put stackPath into nameArray [stackName]
   end repeat
   return nameArray
end stack_ConstructNameNameArray

function stack_ListNames pWhichNames
   switch pWhichNames
      default -- case "open but not rev"
         put the openstacks into someNames
         filter someNames without "rev*"
         line_Delete "Message Box", someNames
         sort someNames
         return someNames
   end switch
end stack_ListNames

function stack_ListObjects pWhichNames
   put stack_ListNames (pWhichNames) into stackNames
   repeat for each line stackName in stackNames
      put the name of stack stackName into stackObject
      put stackObject & CR after stackObjects
   end repeat
   delete char -1 of stackObjects
   return stackObjects
end stack_ListObjects

function stack_LoadedWithoutFiles
    repeat for each line stackName in the mainstacks
        if the filename of stack stackName is empty then
            put stackName & CR after stackNamesWithoutFiles
        end if
    end repeat
    filter stackNamesWithoutFiles without "rev*"
    return word 1 to -1 of stackNamesWithoutFiles
end stack_LoadedWithoutFiles

function stack_GetShortName someFile
    set lockmessages to true
    put the mainstacks into oMainStacks
    if exists(stack someFile) is false then
        -- can't have been loaded
        return empty
    end if
    
    -- this will also load the stack into memory
    put the short name of stack someFile into shortName
     
    -- the problem here is what to do if we had a stack with the same name loaded a stack into memory. 
    
    set the wholematches to true
    -- lets check
    if not(shortName is among the lines of oMainStacks) then
        delete stack someFile
    end if
    set lockmessages to false
    return shortName
end stack_GetShortName

command stack_SetShortName someFile, newName
    set lockmessages to true
    set the wholematches to true
    put the mainstacks into oMainStacks
    if newName is among the lines of oMainStacks then
        put merge("A stack called [[newName]] is already in memory!")
        answer warning someWarning
        exit to top
    end if
    if exists(stack someFile) is false then return empty
    
    put the short name of stack someFile to oldName
    set the name of stack someFile to newName
     
    if not(oldName is among the lines of oMainStacks) then delete stack someFile
    set lockmessages to false
    return oldName
end stack_SetShortName

function stack_GetSubStacks someFile
    set lockmessages to true
    put the mainstacks into oMainStacks
    if exists(stack someFile) is false then return empty
    
    put the short name of stack someFile into shortName
    put the substacks of stack someFile into subStackNames
     
    set the wholematches to true
    if not(shortName is among the lines of oMainStacks) then delete stack someFile
    set lockmessages to false
    return subStackNames
end stack_GetSubStacks


--> Stack | Outlines
-
function stack_SubStackOutline stackNames
    put empty into stackNameOutline
    repeat for each line stackName in stackNames
        put the substacks of stack stackname into subStackNames
        put stackName & return after stackNameOutline
        if subStackNames is not empty then
            put outline_IncreaseIndent(subStackNames, 1) & return after stackNameOutline
        end if
    end repeat
    delete last char of stackNameOutline
    return stackNameOutline
end stack_SubStackOutline

function stack_ConstructHtmlIndex someFiles, unknownColour
    set the itemdelimiter to "/"
    repeat for each line someFile in someFiles
        put stack_GetShortName(someFile) into stackName
        put opn_GetFileName(stackName) into opnFile
        if opnFile is empty then
            if unknownColour is empty then
                put html_ConstructNameLink(stackName, someFile) & CR after someOutline
            else
                put html_ConstructNameLink(stackName, someFile) into someLink
                put html_ConstructColouredText(someLink, unknownColour) & CR after someOutline
            end if
        else
            put html_ConstructNameLink(stackName, someFile) & CR after someOutline
        end if
    end repeat
    delete last char of someOutline
    return someOutline
end stack_ConstructHtmlIndex

function stack_ConstructHtmlOutline someFolder, rootFolder, unknownColour, tabBit
    local htmlOutline
    set the cursor to busy
     
    put the directory into oDirectory
    set the directory to someFolder
    
    put the files into shortFiles
    filter shortFiles without ".*"
    repeat for each line shortFile in shortFiles
        put someFolder & shortFile into someFile
        put stack_GetShortName(someFile) into stackName
        
        -- this also checks that the file is a stack
        if stackName is empty then next repeat
        if rootFolder is empty then
            put someFile into fileLink
        else
            put file_GetRelativePath(someFile, rootFolder, commonPath) into fileLink
        end if
        
        -- put html_ConstructNameLink(stackName, fileLink) into nameLink
        put opn_GetFileName(stackName) into opnFile
        if opnFile is empty then
            if unknownColour is empty then
                put html_ConstructNameLink(stackName, fileLink) into nameLink
            else
                get html_ConstructNameLink(stackName, fileLink)
                put html_ConstructColouredText(it, unknownColour) into nameLink
            end if
        else
            put html_ConstructNameLink(stackName, fileLink) into nameLink
        end if
         
        put tabBit & nameLink into osTilte
        put osTilte & CR after htmlOutline
    end repeat
     
    put the folders into newShortFolders
    filter newShortFolders without ".*"
    
    repeat for each line shortFolder in newShortFolders
        put someFolder & shortFolder & "/" into nestedFolder
        put tabBit & tab into nextTabBit
        put stack_ConstructHtmlOutline (nestedFolder, rootFolder, unknownColour, nextTabBit) into nestedOutline
         
        put tabBit & shortFolder into osTilte
        if nestedOutline is empty then
            -- don't bother if there are no stacks there.
        else
            put osTilte & CR after htmlOutline
            put nestedOutline & CR after htmlOutline
        end if
    end repeat
    delete char -1 of htmlOutline
     
    set the directory to oDirectory
    return htmlOutline
end stack_ConstructHtmlOutline

function stack_ConstructNameOutline someFolder, @infoArray, excludeFolderList, includeInvisible, tabBit
    local shortFileOutline
     
    set the cursor to busy
     
    put infoArray["FolderIndex"] into folderIndex
    put infoArray["FileIndex"] into fileIndex 
    line_Insert someFolder, folderIndex
    put folderIndex into infoArray["FolderIndex"]
     
    put the directory into oDirectory
    set the directory to someFolder
    put the files into shortFiles
    if includeInvisible is not false then filter shortFiles without ".*"
     
    put the mainstacks into stacksInMemory
    repeat for each line shortFile in shortFiles
        put someFolder & shortFile into someFile
        
        line_Insert someFile, fileIndex
        try
            put the short name of stack someFile into stackName
            if stackName is not among the lines of stacksInMemory then stack_RemoveFromMemory stackName
            put tabBit & stackName into osTilte
            line_Insert osTilte, shortFileOutline
        catch tError
            -- lcw_Notify someFile
        end try
    end repeat
    put fileIndex into infoArray["FileIndex"]
     
    put the folders into newShortFolders
    if includeInvisible is not false then filter newShortFolders without ".*"
    
    repeat for each line shortFolder in newShortFolders
        if shortFolder is among the items of excludeFolderList then next repeat
        put someFolder & shortFolder & "/" into nestedFolder
         
        put tabBit & tab into nextTabBit
        put stack_ConstructNameOutline(nestedFolder, infoArray, excludeFolderList, includeInvisible, nextTabBit) into nestedOutline
         
        put tabBit & shortFolder into osTilte
        if nestedOutline is empty then
            -- don't bother if there are no stacks there.
            -- line_Insert osTilte, shortFileOutline
        else
            line_Insert osTilte, shortFileOutline
            put return & nestedOutline after shortFileOutline
        end if
    end repeat
     
    set the directory to oDirectory
    return shortFileOutline
end stack_ConstructNameOutline

function stack_OutlineFromObjectArray objectArray
    local stackArray
    repeat for each key objectName in objectArray
        put objectArray [objectName] into someObject
        object_Deconstruct someObject, someControl, cardObject, stackName
        array_AddToIndex objectName, stackName, stackArray
    end repeat
    put array_ExpandSorted(stackArray, true) into stackOutline
    return stackOutline
end stack_OutlineFromObjectArray
