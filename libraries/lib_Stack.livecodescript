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
getprop card_Rect
   -- relies on a unique card name (but simpler than card_Object)
   put the currentcard of the defaultstack into cardName
   return the rect of card cardName of the defaultstack
end card_Rect

getprop current_Card
   -- relies on a unique card name (but simpler than card_Object)
   put the currentcard of the defaultstack into cardName
   put the long id of card cardName of the defaultstack into cardObject
   return cardObject
end current_Card

getprop current_CardName
   put the currentcard of the defaultstack into cardName
   return cardName
end current_CardName

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

getprop stack_IsUsed
   put the short name of the defaultstack into sName
   put sName is among the lines of the stacksinuse into sBoolean
   return sBoolean
end stack_IsUsed

getprop stack_Name
   return the short name of the defaultstack
end stack_Name

getprop stack_Object
   -- revTargetStack
   return the defaultstack
end stack_Object


--> Working on
-

--> Stack | Props
-
getprop stack_File
   return the effective filename of the defaultstack
end stack_File

getprop stack_RelativeFile [baseStackName]
   if exists (stack baseStackName) is false then
      return merge ("error, stack '[[baseStackName]]' does not exist")
   end if
   
   local commonPath
   put the stack_File of the target into linkFile
   put the stack_Folder of stack baseStackName into baseFolder
   put file_GetRelativePath (linkFile, baseFolder, commonPath) into stackRelativeFile
   return stackRelativeFile
end stack_RelativeFile

getprop stack_Rect
   put the stack_name of the target into sName
   put the rect of stack sName into gStackRect
   return gStackRect
end stack_Rect

setprop stack_Rect gStackRect
   -- screen_ProportionalStackRect
   put the stack_name of the target into sName
   set the rect of stack sName to gStackRect
   return sName
end stack_Rect

getprop stack_Loc
   put the stack_name of the target into sName
   put the loc of stack sName into gStackLoc
   return gStackLoc
end stack_Loc

setprop stack_Loc gStackLoc
   put the stack_name of the target into sName
   set the loc of stack sName to gStackLoc
   return sName
end stack_Loc

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

getprop stack_Style
   put the stack_Name of the target into stackName
   put the systemwindow of stack stackName into someBoolean
   if someBoolean is true then return "system"
   
   put the style of stack stackName into sStyle
   return sStyle
end stack_Style

setprop stack_Style sStyle
   put the stack_Name of the target into stackName
   if sStyle is "system" then
      set the systemwindow of stack stackName to true
   else
      set the style of stack stackName to sStyle
      set the systemwindow of stack stackName to false
   end if 
   return stackName
end stack_Style

getprop stack_Styles
   return "toplevel,modeless,modal,palette,-,system"
end stack_Styles
   
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


--> Stack | Paths
-
function stack_ConvertPathsToNames stackPaths
   put stack_ConstructNameNameArray (stackPaths) into nameArray
   put keys (nameArray) into stackNames
   sort stackNames
   return stackNames
end stack_ConvertPathsToNames

function stack_ConstructNameNameArray stackPaths
   local nameArray
   
   -- will not add stack to memory
   repeat for each line stackPath in stackPaths
      -- if exists (stack stackPath) is false then next repeat
      put stack_GetShortName (stackPath) into stackName
      if stackName is not empty then
         put stackPath into nameArray [stackName]
      end if
   end repeat
   return nameArray
end stack_ConstructNameNameArray

function stack_GetShortName someFile
   -- will not add stack to memory
   
   set lockmessages to true
   put the mainstacks into oMainStacks
   if exists (stack someFile) is false then
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
   
   put the short name of stack someFile into oldName
   set the name of stack someFile to newName
   
   if not(oldName is among the lines of oMainStacks) then delete stack someFile
   set lockmessages to false
   return oldName
end stack_SetShortName

function stack_Exists someName
   -- will not add stack to memory
   
   set lockmessages to true
   put the mainstacks into stacksInMemory
   put empty into shortStackName
   if exists(stack someName) then
      put true into safeExistence
      put not(shortStackName is among the lines of stacksInMemory) into needToClose
      if needToClose then
         delete stack someFile
      end if
   else
      put false into safeExistence
   end if
   set lockmessages to false
   return safeExistence
end stack_Exists

function stack_ListUsed pProjectName
   -- should add functionalty for pProjectName (used by the script_Hierarchy [pProjectName])
   put the stacksinuse into usedStackNames
   put stack_PathsToObjects (usedStackNames) into stackObjects
   return stackObjects
end stack_ListUsed

function stack_ObjectsToProjectNames stackObjects
   put stack_ProjectNameArray (stackObjects) into projectNames
   return projectNames
end stack_ObjectsToProjectNames

function stack_ProjectNameArray stackObjects
   repeat for each line stackObject in stackObjects
      if exists (stackObject) is false then
         put stackObject into resultArray ["Does not exist"]
         next repeat
      end if
      
      put the project_Name of stackObject into projectName
      if projectName is empty then put "Project has no name" into projectName
      put empty into resultArray [projectName][stackObject]
   end repeat
   return resultArray
end stack_ProjectNameArray

function stack_ObjectsToNames stackObjects
   repeat for each line stackObject in stackObjects
      if exists (stackObject) is false then next repeat
      put the short name of stackObject & CR after stackNames
   end repeat
   delete char -1 of stackNames
   return stackNames
end stack_ObjectsToNames

function stack_PathsToNames stackNameOrPaths
   repeat for each line stackName in stackNameOrPaths
      if exists (stack stackName) is false then next repeat
      put the short name of stack stackName & CR after stackNames
   end repeat
   delete char -1 of stackNames
   return stackNames
end stack_PathsToNames

function stack_PathsToObjects stackNameOrPaths
   repeat for each line stackName in stackNameOrPaths
      if exists (stack stackName) is false then next repeat
      put the name of stack stackName & CR after stackObjects
   end repeat
   delete char -1 of stackObjects
   return stackObjects
end stack_PathsToObjects


--> Stack | Type
-
getprop stack_Type
   -- see also "script_Type"
   put the filename of the defaultstack into stackPath
   put stack_TypeFromPath (stackPath) into stackType
   return stackType
end stack_Type

function stack_TypeFromPath stackPath
   set the itemdelimiter to slash
   --
   if stackPath is empty then return "stack"
   put the project_Folder of stack stackPath into projectFolder
   if projectFolder is empty then return "stack"
   if not (stackPath begins with projectFolder) then return "stack"
   
   put the number of items of projectFolder into eNum
   put stackPath into stackPathBit
   delete item 1 to eNum of stackPathBit
   put the number of items of stackPathBit into pathNum
   if pathNum > 2 then return "stack"
   if pathNum = 1 then
      put item - 1 of projectFolder into projectName
      put projectFolder & projectName & ".livecode" into testPath
      if stackPath = testPath then
         return "project"
      else
         return "stack"
      end if
   end if
   
   -- can only be 2 items
   put item 1 of stackPathBit into stackTypes
   -- put item 2 of stackPathBit into shortFile
   put stack_NormalizeType (stackTypes) into stackType
   return stackType
end stack_TypeFromPath

function stack_NormalizeType stackType
   -- put "assets/behaviors/controllers/libraries/models/modules/views"
   switch
      case stackType = "libraries"
         return "library"
      case stackType is "assets"
         return "asset"
      case stackType = "behaviors"
         return "behavior"
      case stackType is "controllers"
         return "menu"
      case stackType is "models"
         return "model"
      case stackType = "modules"
         return "module"
      case stackType = "views"
         return "view"
      default
         return "stack"
   end switch
end stack_NormalizeType


--> Stack
-
function stack_ExtractScriptOnlyName stackData
   -- put word 1 of "Ôªøscript "lib_Audioboom"
   get line 1 of stackData
   if word 1 of it is not "Ôªøscript" then return empty
   put token 2 of stackData into stackName
   return stackName
end stack_ExtractScriptOnlyName


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
   replace comma with CR in stackObjects -- just in case
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

function stack_ConvertObjectsToNames stackObjects
   repeat for each line stackObject in stackObjects
      if exists (stackObject) then
         put the short name of stackObject & CR after stackNames
      end if
   end repeat
   delete char -1 of stackNames
   return stackNames
end stack_ConvertObjectsToNames

function stack_ConvertNamesToObjects stackNames
   repeat for each line stackName in stackNames
      if exists (stack stackName) then
         put the name of stack stackName & CR after stackObjects
      end if
   end repeat
   delete char -1 of stackObjects
   return stackObjects
end stack_ConvertNamesToObjects


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
         delete stack someFile
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
