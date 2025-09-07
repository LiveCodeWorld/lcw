script "behavior_ViewDataDeps"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewDataDeps
type: behavior
version: 0.1


--> Working on
-


--> Props
-
getprop card_Margin
   put the card_Object of the target into cardObject
   if exists(cardObject) is false then return empty
   
   put the uOPN ["card_Margin"] of cardObject into cardMargin
   return cardMargin
end card_Margin

setprop card_Margin cardMargin
   put the card_Object of the target into cardObject
   if exists(cardObject) is false then return empty
   
   set the uOPN ["card_Margin"] of cardObject to cardMargin
end card_Margin

getprop card_Object
   -- ideCoreCardOfcontrol
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
            if cardName begins with "card id" then
               put word 3 of cardName into cardID
               put the long id of card id cardID of the defaultstack into cardObject
            else
               put the currentcard of the defaultstack into cardName
               put the long id of card cardName of the defaultstack into cardObject
            end if
            return cardObject
         end if
      case word 1 of targetObject is among the items of "background,bkgnd,bg"
         return empty  -- no such thing as a unique card_Object
      default
         put wordOffset ("card", targetObject) into wNum
         return word wNum to -1 of targetObject
   end switch
end card_Object

getprop found_Hkey [shortHkey]
   # Private and non-private handlers in targetObject
   -- and non-private handlers in hkey_ScriptHierarchy
   put the long id of the target into tObject
   --
   put the walk_Hierarchy of tObject into searchObjects
   put hkey_FindShortHkey (shortHkey, tObject, searchObjects) into foundHkey
   return foundHkey
end found_Hkey

getprop hierarchy_ObjectAndBehaviors [pPretty]
   local objectHierarchy
   put pPretty is not false into pPretty
   put the long id of the target into tObject
   
   _AddObjectAndBehaviors objectHierarchy, tObject, pPretty
   return word 1 to -1 of objectHierarchy
end hierarchy_ObjectAndBehaviors

getprop hkey_CaseConditions [shortHKey]
   put the script_Handler [shortHKey] of the target into someHandler
   put handler_ExtractCaseConditions (someHandler) into caseConditions
   return caseConditions
end hkey_CaseConditions

getprop hkey_Commands
   put the revAvailableHandlers of the target into hTable
   return hTable_ListCommands (hTable)
end hkey_Commands

getprop screen_Rect
   put the stack_Name of the target into stackName
   put the loc of stack stackName into gLoc
   --
   screen_SetNum gLoc
   put screen_RectFromLoc (gLoc) into sRect
   return sRect
end screen_Rect

getprop script_Handler [shortHKey]
   if shortHKey is empty then return empty
   
   put the long id of the target into hObject
   put the revAvailableHandlers of hObject into hTable
   put the script of hObject into someScript
   put htable_GetHandler (shortHKey, hTable, someScript) into foundHandler
   return foundHandler
end script_Handler

getprop stack_Name
   return the short name of the defaultstack
end stack_Name

getprop stack_Object
   return the defaultstack
end stack_Object

setprop stack_Rect gStackRect
   -- screen_ProportionalStackRect
   put the stack_name of the target into sName
   set the rect of stack sName to gStackRect
   return sName
end stack_Rect

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

getprop view_Name
   put the long id of the target into tObject   
   -- 
   if the uRIP ["type"] of tObject is not "view" then return empty
   put the uRIP ["name"] of tObject into vName
   return vName
end view_Name

getprop view_StackRect [lastStackRect]
   put the long id of the target into newViewObject
   put the formatted_Rect of newViewObject into fRect
   put the screen_Rect of newViewObject into displayScreenRect
   --
   if lastStackRect is empty then
      put stack_GetLastRect() into lastStackRect
   end if
   --
   put display_GetNewStackRect (lastStackRect, fRect, displayScreenRect) into newRect
   return newRect
end view_StackRect

getprop walk_Hierarchy
   put the long id of the target into tObject
   --
   if the module_Name of tObject is empty then
      put revRuggedID (tObject) into tObject
      put hierarchy_Construct (tObject) into walkHierarchy
      hierarchy_AddEnv walkHierarchy
   else
      put the module_BehaviorHierarchy of tObject into walkHierarchy
   end if
   return walkHierarchy
end walk_Hierarchy


--> Hkeys
-
function colour_GetDarkOrLight someColour
   put colour_RgbToHSV (someColour) into someHSV
   put item 3 of someHSV into howDark
   if howDark > 66 then
      return "10,10,10"
   else
      return "204,204,204"
   end if
end colour_GetDarkOrLight

function colour_RgbToHSV rgbColour
   -- was "rgb_2HSV"
   if rgbColour is not a color then return empty
   
   local maxv, minv, diff, s, rc, gc, bc, h
   
   put item 1 of rgbColour into r
   put item 2 of rgbColour into g
   put item 3 of rgbColour into b
   
   set the numberformat to "0.###############"
   put r / 255 into r
   put g / 255 into g
   put b / 255 into b
   put max(r,g,b) into maxv
   put min(r,g,b) into minv
   put maxv - minv into diff
   if maxv <> 0 and diff <> 0 then
      put diff / maxv into s
      put (maxv - r) / diff into rc
      put (maxv - g) / diff into gc
      put (maxv - b) / diff into bc
      if r = maxv then put bc - gc into h
      else if g = maxv then put 2 + rc - bc into h
      else if b = maxv then put 4 + gc - rc into h
      multiply h by 60
      if h < 0 then
         add 360 to h
      end if
   else
      put 0 into s
      put 0 into h
   end if
   return round(h),round(s * 100),round(maxv * 100)
end colour_RgbToHSV

function dataStack_GetValue propName
   put dataStack_Name() into dName
   return the uOPN [propName] of stack dName
end dataStack_GetValue

function dataStack_Name
   -- return "View|Data"
   return the short name of me
end dataStack_Name

command dataStack_SetDefaultFolder
   put default_FarmFolder() into farmFolder
   dataStack_SetValue "default_FarmFolder", farmFolder
end dataStack_SetDefaultFolder

command dataStack_SetValue propName, propValue
   put dataStack_Name() into dName
   set the uOPN [propName] of stack dName to propValue
end dataStack_SetValue

function debug_CallingObject pNum
   -- need to remove reliance on the executioncontexts
   if pNum is empty then put 2 into pNum
   put (pNum + 2) * -1 into lineNum
   get the executioncontexts
   put item 1 of line lineNum of it into callingObject
   return callingObject
end debug_CallingObject

command display_Array sArray, pTitle, pStackLabel, pFoldedArray, pDisplayView, pPalette, pTopLeft
   _NormalizeArrayView pDisplayView, pFoldedArray, pStackLabel, pTitle
   --
   display_InvisibleArray sArray, pTitle, pStackLabel, pFoldedArray, pDisplayView, pPalette, pTopLeft
   put the result into displayView
   if exists (displayView) is false then return empty
   --
   put the stack_Name of displayView into stackName
   show stack stackName
   return displayView
end display_Array

command display_CloneTools cStackName
   if exists (stack cStackName) is false then
      return "Error, cannot locate stack:" && cStackName
   end if
   put the short name of stack cStackName into cStackName -- in case it's a stackPath
   put the original_ModuleName of stack cStackName into moduleName
   
   # Module Directory Array
   put the module_Folder of stack moduleName into moduleFolder
   put directory_NestedArray (moduleFolder) into dArray
   
   # Display 
   display_Tool dArray, cStackName, "Clone Tools"
   put the result into dView
   
   # Set Props
   put the card_ViewObject of stack moduleName into originalView
   put the card_ViewObject of stack cStackName into clonedView
   --
   set the displayed_Object of dView to clonedView
   set the original_View of dView to originalView
   set the displayed_ModuleFolder of dView to moduleFolder
   --
   return dView
end display_CloneTools

command display_Data sData, pTitle, pStackLabel, pDisplayView, pPalette, pTopLeft, pFoldedArray
   lock screen
   if sData is an array then      
      display_Array sData, pTitle, pStackLabel, pFoldedArray, pDisplayView, pPalette, pTopLeft
      put the result into pDisplayView
   else
      _NormalizeView pDisplayView, pStackLabel, pTitle
      if exists (pDisplayView) then
         set the displayed_Index [pTitle] of pDisplayView to sData
         if pStackLabel is not empty then
            put the stack_Name of pDisplayView into stackName
            set the label of stack stackName to pStackLabel
         end if
      else
         display_Lines sData, pTitle, empty, pStackLabel, pPalette, pTopLeft
         put the result into pDisplayView
      end if
   end if
   unlock screen
   --
   object_GoTo pDisplayView, true
   return pDisplayView
end display_Data

function display_FindView displayStackLabel, pDisplayViewTitle, pTypes
   put revLoadedStacks ("application") into dStackNames
   filter dStackNames with "Display *"
   repeat for each line dStackName in dStackNames
      -- could check for type of view
      
      if the label of stack dStackName = displayStackLabel then
         put the long id of group 1 of stack dStackName into displayView
         if pDisplayViewTitle is empty then
            return displayView
         else if the title_Text of displayView = pDisplayViewTitle then
            return displayView
         end if
      end if
   end repeat
   return empty
   
   -- Looks for Display Array, and Display Index views depending on pTypes
   if pTypes is empty then put "Display Index,Display Array" into pTypes
   
   put revLoadedStacks ("application") into dStackNames
   repeat for each line dStackName in dStackNames
      get word 1 to 2 of dStackName
      if it is not among the items of pTypes then next repeat
      if the label of stack dStackName = displayStackLabel then
         put the long id of group 1 of stack dStackName into displayView
         if pDisplayViewTitle is empty then
            return displayView
         else if the title_Text of displayView = pDisplayViewTitle then
            return displayView
         end if
      end if
   end repeat
   return empty
end display_FindView

function display_FirstOpenView viewName, pStackLabel, pViewTitle
   view_NormalizeName viewName
   put "|" after viewName
   --
   put revLoadedStacks ("application") into dStackNames
   repeat for each line dStackName in dStackNames
      # Check exists
      if exists (control 1 of card 1 of stack dStackName) is false then next repeat
      put the long id of control 1 of card 1 of stack dStackName into displayView
      
      # Check viewName is stem of text view name
      if the uRIP ["type"] of displayView is not "view" then next repeat
      put the uRIP ["name"] of displayView into testViewName
      put "|" after testViewName
      if testViewName begins with viewName is false then next repeat
      
      # Refine test
      put the label of stack dStackName into stackLabel
      if stackLabel is empty then
         put dStackName into stackLabel
      end if
      switch
         case pStackLabel is empty
            return displayView
         case stackLabel begins with pStackLabel
            if pViewTitle is empty then
               return displayView
            else if the title_Text of displayView = pViewTitle then
               return displayView
            else
               next repeat
            end if
         default
            -- next repeat
      end switch
   end repeat
   return empty
end display_FirstOpenView

function display_GetNewStackRect oStackRect, fRect, displayScreenRect
   if oStackRect is not a rect then
      put 13 into oLeft
      put 41 into oBottom
   else
      put item 1 of oStackRect into oLeft
      put item 4 of oStackRect into oBottom
   end if
   
   put item 3 of fRect - item 1 of fRect into newWidth
   put item 4 of fRect - item 2 of fRect into newHeight
   
   put item 4 of displayScreenRect into screenBottom
   put item 3 of displayScreenRect - item 1 of displayScreenRect - 60 into maxScreenWidth
   put screenBottom - item 2 of displayScreenRect - 60 into maxScreenHeight
   
   put min (newWidth, maxScreenWidth) into newWidth
   put max (newWidth, 240) into newWidth
   put min (newHeight, maxScreenHeight) into newHeight
   
   put 20 into tileBarHeight
   put oLeft into newLeft
   put tileBarHeight + oBottom into newTop
   put newLeft + newWidth into newRight
   put newTop + newHeight into newBottom
   
   -- if newBottom > screenBottom then -- here we could tile it across the screen
   
   return newLeft,newTop,newRight,newBottom
end display_GetNewStackRect

command display_Index someIndex, pDisplayTitle, pTreeMenuTitle, pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pDragCommand, pPalette, pTopLeft
   -- phase out and use "display_Lines" instead
   put empty into oRect
   --
   display_InvisibleIndex someIndex, pDisplayTitle, pTreeMenuTitle, pLineMenuTitle, pMouseUpCommand, pMouseDoubleUpCommand, pDragCommand, pPalette
   put the result into displayView 
   put token -1 of displayView into cloneStackName
   --
   put the view_StackRect [oRect] of displayView into newRect
   stack_Position cloneStackName, newRect
   --
   send "stack_Show displayView" to displayView in 2 ticks -- stops flickr
   return displayView
end display_Index

command display_InvisibleArray sArray, pTitle, pStackLabel, pFoldedArray, pDisplayView, pTopLeft, pPalette
   if exists (pDisplayView) then
      set the displayed_Array [pTitle] of pDisplayView to sArray
      if pFoldedArray is an array then set the fold_State of pDisplayView to pFoldedArray
      if pStackLabel is not empty then
         put the stack_Name of pDisplayView into stackName
         set the label of stack stackName to pStackLabel
      end if
   else
      _CreateInvisibleData sArray, pTitle, pStackLabel, pFoldedArray, pPalette
      put the result into pDisplayView
   end if
   return pDisplayView
end display_InvisibleArray

command display_InvisibleIndex sIndex, pTitle, pLabel, pPalette
   # Clone invisible
   stack_CloneInvisible "View|Data", "Display Index"
   put the result into cStackName   
   put the long id of control 1 of cd 1 of stack cStackName into dView
   
   # Data
   set the displayed_Data [pTitle] of dView to sIndex
   
   # Set Geometry
   set the card_Margin of dView to 0
   -- revIdeEnsureOnscreen cStackName
   
   # Set display
   _SetRandomTitleColour dView
   
   set the label of stack cStackName to pLabel
   set the title_Text of dView to pTitle
   set the multiple_Hilites of dView to false
   --
   switch pPalette
      case "system"
         set the systemWindow of stack cStackName to true
         break
      case false
         break
      default
         set the style of stack cStackName to "palette"
   end switch
   --
   return dView
end display_InvisibleIndex

command display_Lines someIndex, pTitle, pDoubleUp, pStackLabel, pPalette, pTopLeft
   -- does not sort
   local pTitleMenu, pLineMenu, pMouseUp, pDragCommand
   
   if pStackLabel is empty then
      put space into pStackLabel
   else
      put comma & pStackLabel after pTitle
   end if
   --
   display_Index someIndex, pTitle, pTitleMenu, pLineMenu, pMouseUp, pDoubleUp, pDragCommand, pPalette, pTopLeft
   put the result into indexView
   --
   set the field_Style of indexView to "click"
   return indexView
end display_Lines

function display_ListIndexStackNames
   put the openstacks into indexStackNames
   -- filter indexStackNames with "Display Index *"
   sort indexStackNames by word -1 of each
   return indexStackNames
end display_ListIndexStackNames

command display_SetTitleColour displayView, pTitleColour
   if pTitleColour is empty then put "random" into pTitleColour
   
   set the card_Margin of displayView to 0
   set the title_Colour of displayView to pTitleColour
   put the result into titleColour
   
   put colour_GetDarkOrLight (titleColour) into titleTextColour
   set the title_TextColour of displayView to titleTextColour
   return titleColour
end display_SetTitleColour

function env_CheckLcwProject projectName
   -- here we assume we have only one repoFolder with all project at top level
   put env_ConstructHomePath (projectName) into homePath
   put there is a file homePath into projectExists
   return projectExists
end env_CheckLcwProject

function env_ConstructHomePath projectName, pLcwFolder
   if pLcwFolder is empty then put env_GetLcwFolder() into pLcwFolder
   --
   set the itemdelimiter to slash
   put pLcwFolder into repoFolder
   delete item -1 of repoFolder
   put projectName & ".livecode" into shortFile
   put repoFolder & projectName & slash & shortFile into homePath
   return homePath
end env_ConstructHomePath

function env_FolderFromPath sPath
   -- works for any stack within the LiveCodeWorld repo
   constant RootName = "LivecodeWorld"
   
   set the itemdelimiter to slash
   put itemOffset (RootName, sPath) into itemNum
   if itemNum = 0 then return empty
   put item 1 to itemNum of sPath & slash into envFolder
   return envFolder
end env_FolderFromPath

function env_GetActiveProjectArray
   global gLCW
   put gLCW ["environment"]["project"] into activeProjectArray
   return activeProjectArray
end env_GetActiveProjectArray

function env_GetLcwFolder
   if exists (stack "LCW") is false then
      put the filename of me into sPath
      return env_FolderFromPath (sPath)
   else
      get the filename of stack "LCW"
      set the itemdelimiter to slash
      put item 1 to -2 of it & slash into lcwFolder
      return lcwFolder
   end if
end env_GetLcwFolder

function env_GetRepoFolder
   put env_GetLcwFolder() into pLcwFolder
   --
   set the itemdelimiter to slash
   delete item -1 of pLcwFolder
   return pLcwFolder
end env_GetRepoFolder

function env_ListLocalProjects
   put env_ListShortProjectFolders() into pProjectNames
   repeat for each line projectName in pProjectNames
      set the cursor to busy
      put env_CheckLcwProject (projectName) into isProject
      --
      if isProject is true then
         put projectName & CR after goodProjectNames
      end if
   end repeat
   --
   delete char -1 of goodProjectNames
   return goodProjectNames
end env_ListLocalProjects

function env_ListShortProjectFolders
   put env_GetRepoFolder() into repoFolder
   put folders (repoFolder) into shortFolders
   --
   filter shortFolders without ".*"
   sort shortFolders
   return shortFolders
end env_ListShortProjectFolders

function env_ListStoppedProjects
   put env_ListLocalProjects() into localProjects
   put env_GetActiveProjectArray() into envProjectArray
   repeat for each line localProject in localProjects
      put envProjectArray [localProject] into projectFolder
      if projectFolder is empty then
         put localProject & CR after stoppedProjects
      end if
   end repeat
   delete char -1 of stoppedProjects
   return stoppedProjects
end env_ListStoppedProjects

function handler_ExtractCaseConditions someHandler
   local switchSection, caseConditions
   handler_ParseSwitchStatement someHandler, switchSection, caseConditions
   return caseConditions
end handler_ExtractCaseConditions

command handler_ParseSwitchStatement someHandler, @switchSection, @caseConditions
   /*
   Many ways to do this, doubtless can be (and should be spead up.
   It is called for every handler in a script that has a menu on complile.
   */
   
   local lineNum, startLineNum
   
   repeat for each line someLine in someHandler
      add 1 to lineNum
      if startLineNum is empty and word 1 of someLine = "switch" then
         put lineNum into startLineNum
      end if
      if startLineNum is empty then next repeat
      
      -- here we look for "case"
      if word 1 of someLine = "case" then
         put token 2 of someLine into caseCondition
         if caseCondition is not empty then
            put caseCondition & CR after caseConditions
         end if
      end if
      
      if word 1 to 2 of someLine = "end switch" then
         put lineNum into endLineNum
         exit repeat
      end if
   end repeat
   delete char -1 of caseConditions
   
   if endLineNum is empty then
      put empty into switchSection
      put empty into caseConditions
      return empty
   end if
   put line startLineNum to endLineNum of someHandler into switchSection
end handler_ParseSwitchStatement

command hierachy_AddStackObjects @objectHierarchy, tObject, pPretty
   if exists (tObject) is false then return false
   put tObject into objectOwner
   put empty into skipThisBackgroundID
   
   repeat
      switch word 1 of objectOwner
         case "stack"
            -- previously added a stack, check if it was a substack
            put objectOwner into stackObject
            put the owner of stackObject into mainStackObject
            if exists (mainStackObject) then
               _AddObjectAndBehaviors objectHierarchy, mainStackObject, pPretty
            end if
            
            delete word 1 to 3 of objectOwner
            if exists (objectOwner) is false then exit repeat
            break
         case "card"
            -- previously added a card, so check for backgrounds
            put objectOwner into cardObject
            put the backgroundIDs of cardObject into bgIDs
            -- need to add in reverse to mirror message path
            repeat with bgNum = the number of lines of bgIDs down to 1
               put line bgNum of bgIDs into someID
               if someID = skipThisBackgroundID then next repeat
               put the long ID of bg ID someID of cardObject into backgroundObject
               _AddObjectAndBehaviors objectHierarchy, backgroundObject
            end repeat
            
            # Above a card must be a stack
            put objectOwner into stackObject
            delete word 1 to 4 of stackObject
            _AddObjectAndBehaviors objectHierarchy, stackObject
            
            exit repeat
            break
         case "group"
            -- previously added a group, check to see if was a bg
            if the backgroundbehavior of objectOwner is true then
               -- will need to skip it's own "card" background
               put the short ID of objectOwner into skipThisBackgroundID
            end if
            --
            delete word 1 to 4 of objectOwner
            if exists (objectOwner) is false then exit repeat
            --
            _AddObjectAndBehaviors objectHierarchy, objectOwner
            break
         default
            -- previously added a normal control
            delete word 1 to 4 of objectOwner
            if exists (objectOwner) is false then exit repeat
            --
            _AddObjectAndBehaviors objectHierarchy, objectOwner
      end switch
   end repeat
   put word 1 to -1 of objectHierarchy into objectHierarchy
   return true
end hierachy_AddStackObjects

command hierarchy_AddEnv @objectHierarchy
   put env_ScriptHierarchy (true) into externalObjects
   if externalObjects is empty then return false
   
   set the wholematches to true
   repeat for each line sObject in objectHierarchy
      put lineOffset (sObject, externalObjects) into lineNum
      delete line lineNum of externalObjects
   end repeat
   if externalObjects is empty then return false
   
   put CR & word 1 to -1 of externalObjects after objectHierarchy
   put word 1 to -1 of objectHierarchy into objectHierarchy
   return true
end hierarchy_AddEnv

function hierarchy_Construct tObject, pPretty
   -- was "object_GetHierarchy"
   local objectHierarchy
   put the long id of tObject into tObject
   put pPretty is not false into pPretty
   
   put the hierarchy_ObjectAndBehaviors [pPretty] of tObject into objectHierarchy
   hierachy_AddStackObjects objectHierarchy, tObject, pPretty
   return word 1 to -1 of objectHierarchy
end hierarchy_Construct

function hkey_FindShortHkey shortHkey, pObject, pSearchObjects
   put word 1 to 2 of shortHkey into shortHkey
   
   # Make shortHkey public
   if char 1 of shortHkey = "P" then delete char 1 of shortHkey
   
   if exists (pObject) then
      # Search for private handlers
      put the hkey_Either [shortHkey] of pObject into foundHkey
      if foundHkey is not empty then
         return foundHkey
      end if
      line_Delete pSearchObjects, pObject -- so we dont search it again later
   end if
   
   # Search for public handlers in pSearchObjects
   repeat for each line foundObject in pSearchObjects
      if exists (foundObject) is false then next repeat
      
      put the hkey_Or [shortHkey] of foundObject into foundHkey
      if foundHkey is not empty then
         return foundHkey
      end if
   end repeat
   return empty  
end hkey_FindShortHkey

command hkeyLine_Deconstruct hKeyLine, @hName, @hType, @hObject
   put toUpper (word 1 of hKeyLine) into hType
   put word 2 of hKeyLine into hName
   put word 4 to -1 of hKeyLine into hObject
   return hType && hName
end hkeyLine_Deconstruct

function hTable_GetHandler hkeyLine, hTable, pSomeScript
   if pSomeScript is empty then
      put word 5 to -1 of line 1 of hTable into scriptObject
      if exists (scriptObject) is false then return "Error, cannot find object in hTable:" && scriptObject
      put the script of scriptObject into pSomeScript
   end if
   hkeyLine_Deconstruct hKeyLine, hName, hType, hObject
   
   # Line numbers
   htable_OrLineOffsets hName, hType, hTable, startLineNum, endLineNum
   -- htable_ExactLineOffsets hkeyLine, hTable, startLineNum, endLineNum
   if endLineNum = 0 then return empty
   
   # Handler
   put line startLineNum to endLineNum of pSomeScript into foundHandler
   return foundHandler
end hTable_GetHandler

function hTable_ListCommands hTable
   repeat for each line someLine in hTable
      if word 1 of someLine is among the items of "M,C" then
         put word 2 of someLine & CR after shortHkeys
      end if
   end repeat
   delete char -1 of shortHkeys
   return shortHkeys
end hTable_ListCommands

command htable_OrLineOffsets hName, hType, hTable, @startLineNum, @endLineNum
   repeat for each line hLine in hTable
      if hName is not word 2 of hLine then next repeat
      
      switch
         case hType = word 1 of hLine
         case (hType = "C") AND (word 1 of hLine = "M")
         case (hType = "M") AND (word 1 of hLine = "C")
            put word 3 of hLine into startLineNum
            put word 4 of hLine into endLineNum
            return true
      end switch
   end repeat
   put 0 into startLineNum
   put 0 into endLineNum
   return false
end htable_OrLineOffsets

function kwote someText, pQuoteChar
   if pQuoteChar is empty then put quote into pQuoteChar
   return pQuoteChar & someText & pQuoteChar
end kwote

command lcw_AnswerWarning someQuestion, pDisplayView, pQVar
   put param (4) into pQVar2
   put param (5) into pQVar3
   --
   if exists (pDisplayView) then
      -- this is an ugly hack to change the target to pDisplayView
      dispatch "lcw_AnswerWarning" to pDisplayView with someQuestion, empty, pQVar, pQVar2, pQVar3
      exit to top
   end if
   --
   put lcw_Question (someQuestion, pQVar, pQVar2, pQVar3) into someQuestion
   answer warning someQuestion with "OK" as sheet
   exit to top
end lcw_AnswerWarning

function lcw_Ask someQuestion, pDefault, pDisplayView, pVarValue
   text_ReQuote someQuestion, pVarValue
   --
   if exists (pDisplayView) then
      if pTitle is not empty then -- makes no difference on MacOS
         ask someQuestion with pDefault titled pTitle as sheet
      else
         ask someQuestion with pDefault as sheet
      end if
   else
      ask someQuestion with pDefault
   end if
   put it into theResult
   if the result is "Cancel" then exit to top
   return theResult
end lcw_Ask

function lcw_Question someQuestion, pQVar, pQVar2, pQVar3
   -- put param (4) into pQVar2
   -- put param (5) into pQVar3
   --
   put _ConstructDoScript (someQuestion, pQVar, pQVar2, pQVar3) into doScript
   if doScript is not empty then
      do doScript
      put merge (someQuestion) into someQuestion
   end if
   text_ReQuote someQuestion
   return someQuestion
end lcw_Question

command line_Delete someLine, @someIndex
   set the wholematches to true
   put lineoffset (someLine, someIndex) into lineNum
   delete line lineNum of someIndex
   return lineNum
end line_Delete

command margin_Normalize someMargin, @leftM, @topM, @rightM, @bottomM
   if the number of items of someMargin < 4 then
      put item 1 of someMargin into defaultMargin
      put defaultMargin into leftM
      
      put item 2 of someMargin into actualMargin
      if actualMargin is empty then
         put leftM into topM
      else
         put actualMargin into topM
      end if
      
      put item 3 of someMargin into actualMargin
      if actualMargin is empty then
         put leftM into rightM
      else
         put actualMargin into rightM
      end if
      
      put item 4 of someMargin into actualMargin
      if actualMargin is empty then
         put topM into bottomM
      else
         put actualMargin into bottomM
      end if
   else
      put item 1 of someMargin into leftM
      put item 2 of someMargin into topM
      put item 3 of someMargin into rightM
      put item 4 of someMargin into bottomM
   end if
   return leftM,topM,rightM,bottomM
end margin_Normalize

function menu_Bit mTitle
   set the itemdelimiter to "|"
   put mTitle into middleBit
   put word 1 to -1 of item 1 of mTitle into firstBit
   switch firstBit
      case "View"
      case "Layout"
      case "Global"
         delete item 1 of middleBit
         break
   end switch
   --
   put word 1 to -1 of item -1 of mTitle into lastBit
   if lastBit = "Menu" then
      delete item -1 of middleBit
   end if
   --
   return word 1 to -1 of middleBit
end menu_Bit

command module_Clone moduleName, pShowTools
   view_NormalizeName moduleName
   --
   stack_Clone moduleName
   put the result into clonedStack
   --
   set the original_ModuleName of clonedStack to moduleName
   put the stack_Name of clonedStack into cStackName
   --
   if pShowTools is true then
      display_CloneTools cStackName
   end if
   return cStackName
end module_Clone

command object_GoTo someObject, pMakeVisible
   if exists (someObject) is false then return "Error, object does not exist:" && someObject
   
   put the stack_Name of someObject into stackName
   put the card_Object of someObject into cardObject
   if exists(cardObject) is false then
      go to stack stackName
   else
      put the short id of cardObject into cardID
      go to card id cardID of stack stackName
   end if
   --
   put the result into goResult
   if goResult is not empty then
      breakpoint
   end if
   --
   if pMakeVisible is true then
      stack_SetToMainScreen stackName
      show stack stackName
   end if
   return the result
end object_GoTo

function rect_FitsWithin testRect, someRect
   put item 1 to 2 of testRect into testTopLeft
   if testTopLeft is not within someRect then return false
   
   put item 3 to 4 of testRect into testBottomRight
   return testBottomRight is within someRect
end rect_FitsWithin

command rect_MoveTopLeft @someRect, newTopLeft
   put item 1 of newTopLeft - item 1 of someRect into xVector
   put item 2 of newTopLeft - item 2 of someRect into yVector
   put rect_TranslateByVector (someRect, xVector, yVector) into someRect
end rect_MoveTopLeft

command rect_Normalize @someRect, outsideRect
   put max (item 1 of someRect, item 1 of outsideRect) into item 1 of someRect
   put max (item 2 of someRect, item 2 of outsideRect) into item 2 of someRect
   put min (item 3 of someRect, item 3 of outsideRect) into item 3 of someRect
   put min (item 4 of someRect, item 4 of outsideRect) into item 4 of someRect
end rect_Normalize

function rect_Subtract someMargin, someRect
   rect_SubtractMargins someRect, someMargin
   return someRect
end rect_Subtract

command rect_SubtractMargins @someRect, pMargin
   margin_Normalize pMargin, leftM, topM, rightM, bottomM
   put the result into nMargins
   --
   add leftM to item 1 of someRect
   add topM to item 2 of someRect
   subtract rightM from item 3 of someRect
   subtract bottomM from item 4 of someRect
   --
   return nMargins
end rect_SubtractMargins

command rect_Translate @someRect, xVector, yVector
   add xVector to item 1 of someRect
   add xVector to item 3 of someRect
   
   add yVector to item 2 of someRect
   add yVector to item 4 of someRect
end rect_Translate

function rect_TranslateByVector someRect, xVector, yVector
   rect_Translate someRect, xVector, yVector
   return someRect
end rect_TranslateByVector

function screen_NumberFromLoc gLoc
   get the screenRects
   repeat with lineNum =1 to the number of lines of it
      put line lineNum of it into sRect
      if gLoc is within sRect then
         return lineNum
      end if
   end repeat
   return 0
end screen_NumberFromLoc

function screen_RectFromLoc gLoc
   get the screenRects
   repeat with lineNum = 1 to the number of lines of it
      put line lineNum of it into sRect
      if gLoc is within sRect then
         return sRect
      end if
   end repeat
   return empty
end screen_RectFromLoc

command screen_SetNum screenNumOrLoc
   switch
      case screenNumOrLoc is an integer
         put screenNumOrLoc into screenNum
         break
      case screenNumOrLoc is a point
         put screen_NumberFromLoc (screenNumOrLoc) into screenNum
         break
      default
         put globalloc (the mouseloc) into gLoc
         put screen_NumberFromLoc (gLoc) into screenNum
   end switch
   --
   put screenNum into LocalArray ["screenNum"]
   return true
end screen_SetNum

function stack_CleanName stackName
   replace "'" with empty in stackName
   replace quote with empty in stackName
   return stackName
end stack_CleanName

command stack_Clone stackNameToClone, pStackLabel, pCloneName, pDestroyBoolean
   if exists (stack stackNameToClone) is false then return empty
   --
   stack_CloneInvisible stackNameToClone, pCloneName, pDestroyBoolean
   put the result into cloneStackName
   --
   if pStackLabel is not empty then
      set the label of stack cloneStackName to pStackLabel
   end if
   --
   stack_SetToMainScreen cloneStackName
   set the visible of stack cloneStackName to true
   --
   put the name of stack cloneStackName into clonedStack
   return clonedStack
end stack_Clone

function stack_ClonedStackNames stackName
   put the mainstacks into stackNames
   filter stackNames with (stackName & "*")
   put word 1 to -1 of stackNames into stackNames
   if stackNames is empty then return stackName
   return stackNames
end stack_ClonedStackNames

command stack_CloneInvisible stackNameToClone, pCloneName, pDestroyBoolean
   if exists (stack stackNameToClone) is false then return empty
   if pCloneName is empty then put stackNameToClone into pCloneName
   
   # Check name
   if exists (stack pCloneName) is true then
      # Make numbered version
      put stack_ConstructNewCloneName (pCloneName) into newStackName
      if exists (stack newStackName) is true then
         -- should never happen
         throw "Error, command '_CheckAndResetCloneName' made a clone name that already exists (which is strange):" && newStackName
      end if
      put newStackName into pCloneName
   end if
   
   # Clone
   clone invisible stack stackNameToClone as pCloneName
   put it into clonedStack
   
   # Memory Defaults
   if pDestroyBoolean is not false then
      set the destroyStack of clonedStack to true
      set the destroyWindow of clonedStack to true
   end if
   return pCloneName -- used
end stack_CloneInvisible

function stack_ConstructNewCloneName stackName
   -- use this when you want multiple stacks of the same numbered name style
   
   put stack_ClonedStackNames (stackName) into stackNames
   
   -- let's find the last number that is still open
   sort numeric descending stackNames by last word of each
   put line 1 of stackNames into realStackName
   put word -1 of realStackName into cloneNumber
   
   -- let's add 1 to get the new cloneNumber
   if cloneNumber is a number then
      add 1 to cloneNumber
   else
      put 1 into cloneNumber
   end if
   
   -- now construct the name
   put (stackName && cloneNumber) into newClonedName
   if exists (stack newClonedName) is false then
      return newClonedName
   else
      -- should never happen
      return empty
   end if
end stack_ConstructNewCloneName

function stack_GetLastRect
   put line -1 of display_ListIndexStackNames() into lastIndexStackName
   if lastIndexStackName is empty then
      put stack_GetTop (true) into stackName 
      if exists (stack stackName) is false then return empty
      put the rect of stack stackName into pRect
   else
      put the rect of stack lastIndexStackName into pRect
   end if
   return pRect   
end stack_GetLastRect

function stack_GetTop pWithoutDisplay
   put the openstacks into stackList
   --
   if pWithoutDisplay is not false then
      filter stackList without "Display*"
   end if
   --
   filter stackList without "rev*"
   filter stackList without "Message Box"
   filter stackList without "com.*"
   filter stackList without "Global |*"
   sort stackList
   put line 1 of stackList into stackName
   return stackName
end stack_GetTop

command stack_Position stackName, pLocOrRect
   switch
      case pLocOrRect = "click"
      case pLocOrRect = "mouse"
         -- put globalLoc (the mouseloc) into mGlobalLoc
         put the screenmouseloc into mGlobalLoc
         set the topLeft of stack stackName to mGlobalLoc
         break
      case pLocOrRect is a point
         set the topLeft of stack stackName to pLocOrRect
         break
      case pLocOrRect is a rect
         set the rect of stack stackName to pLocOrRect
         break
      default
         revIDEEnsureOnscreen stackName
   end switch
end stack_Position

command stack_SetStyle cloneStackName, pPalette
   switch pPalette
      case "system"
         set the systemWindow of stack cloneStackName to true
         break
      case false
         break
         -- case empty
         -- case true
      default
         set the style of stack cloneStackName to "palette"
   end switch
end stack_SetStyle

command stack_SetToMainScreen stackNames, pScreenRect
   if pScreenRect is empty then
      put the working screenrect into pScreenRect
   end if
   put rect_Subtract (60, pScreenRect) into safeRect
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

command stack_Show displayView
   -- stops flickr
   if exists (displayView) is false then
      put the stack_Name of the target into stackName
   else
      put the the stack_Name of displayView into stackName
   end if
   show stack stackName
   go to stack stackName
end stack_Show

function text_GetMergeVars mergeText
   -- put text_GetBetween ("[[", "]]", someText, startAfterCharNum)
   put "\[\[" into someReg
   put "[^\]]*" into notaSquareClosingBracket
   put "(" & notaSquareClosingBracket & ")" after someReg
   put "\]\]" after someReg
   --
   repeat 100 -- for safety
      if matchChunk (mergeText, someReg , startMatch, endMatch) is true then
         put char startMatch to endMatch of mergeText into varName
         put varName & CR after varNames
         delete char 1 to (endMatch + 2) of mergeText
      else
         delete char -1 of varNames
         return varNames
      end if
   end repeat
end text_GetMergeVars

function text_InitialCaps someText
   repeat with wordNum = 1 to the number of words of someText
      put tolower(word wordNum of someText) into someWord
      put toupper(char 1 of someWord ) into char 1 of someWord
      put someWord into word wordNum of someText
   end repeat
   return someText
end text_InitialCaps

command text_ReQuote @someText, pMergeValue
   replace "'" with quote in someText
   if pMergeValue is not empty then
      put pMergeValue into var
      put merge (someText) into someText
   end if
end text_ReQuote

command view_NormalizeName @viewPath
   if viewPath is empty then return false
   view_NormalizePiped viewPath
   
   set the itemdelimiter to "|"
   if item 1 of viewPath is not among the items of "View|Layout" then put "View|" before viewPath
   return true
end view_NormalizeName

command view_NormalizePiped @viewPath, pMakePretty
   if viewPath is empty then return false
   put word 1 to -1 of viewPath into viewPath
   
   set the itemdelimiter to "|"
   repeat with itemNum = 1 to the number of items of viewPath
      put word 1 to -1 of item itemNum of viewPath into someItem
      if pMakePretty is true then
         repeat for each word someWord in someItem
            put toUpper (char 1 of someWord) into char 1 of someWord
            put someWord & space after prettyItem
         end repeat
         put char 1 to -2 of prettyItem into someItem
      end if
      put someItem into item itemNum of viewPath
   end repeat
   return true
end view_NormalizePiped





--> Private
-
private command _AddObjectAndBehaviors @objectHierarchy, tObject, pPretty
   if exists (tObject) is false then return empty
   
   if pPretty is not false then
      -- put the long id of tObject into tObject
      put CR & the name of tObject after objectHierarchy
   else
      put CR & revRuggedId (tObject) after objectHierarchy
   end if
   
   put the behavior_Objects of tObject into bObjects
   if bObjects is empty then return false
   put CR & bObjects after objectHierarchy
   return true
end _AddObjectAndBehaviors

private command _CheckAndResetCloneName @pCloneName
   if exists (stack pCloneName) is false then
      -- let's just use it
      return false 
   end if
   
   -- otherwise let's make up a numbered version
   put stack_ConstructNewCloneName (pCloneName) into newStackName
   if exists (stack newStackName) is true then
      -- should never happen
      throw "Error, command '_CheckAndResetCloneName' made a clone name that already exists (which is strange):" && newStackName
   end if
   put newStackName into pCloneName
   return true
end _CheckAndResetCloneName

private function _ConstructDoScript someQuestion, pQVar, pQVar2, pQVar3
   put text_GetMergeVars (someQuestion) into mergeVars
   repeat with lineNum = 1 to the number of lines of mergeVars
      put line lineNum of mergeVars into varName
      put lineNum + 1 into pNum
      put param (pNum) into pValue
      replace quote with "'" in pValue
      --
      if pValue is not empty then
         put "put" && kwote (pValue) && "into" && varName & CR after doScript
      end if
   end repeat
   delete char -1 of doScript
   return doScript
end _ConstructDoScript

private command _CreateInvisibleData someArray, pTitle, pStackLabel, pFoldedArray, pLocOrRect, pPalette
   -- constant ArrayViewName = "View|Tree|Widget with Title"
   constant ArrayViewName = "View|Data"
   
   put ArrayViewName into viewName
   if pTitle is empty then put "Array" into pTitle
   
   -- clone invisible
   stack_CloneInvisible viewName, "Display Array"
   put the result into cloneStackName
   if exists (stack cloneStackName) is false then return empty
   
   put _DisplayView (cloneStackName) into displayView
   --
   set the displayed_Array of displayView to someArray
   if pFoldedArray is an array then
      -- sensitive to capitalisation
      set the fold_State of displayView to pFoldedArray
   end if
   
   # Title Colour
   display_SetTitleColour displayView
   --
   if line 1 of keys (someArray) is a number then
      set the tree_SortType of displayView to "numeric"
   end if
   --
   set the title_Text of displayView to pTitle
   if pStackLabel is not empty then
      set the label of stack cloneStackName to pStackLabel
   end if
   --
   stack_Position cloneStackName, pLocOrRect
   stack_SetStyle cloneStackName, pPalette
   --
   return displayView
end _CreateInvisibleData

private function _DisplayView cloneStackName
   put the long id of cd 1 of stack cloneStackName into firstCard
   
   -- hacky (change to view_Object or displayed_Object of card?)
   put the long id of control 1 of firstCard into displayView
   return displayView
end _DisplayView

private command _NormalizeArrayView @pDisplayView, @pFoldedArray, pStackLabel, pTitle
   if exists (pDisplayView) is true then
      -- assumes we do not want to change the folded state
      put empty into pFoldedArray
   else
      put display_FindView (pStackLabel, pTitle, "Display Array") into pDisplayView
      if exists (pDisplayView) is true then
         -- assumes we do not want to change the folded state
         put empty into pFoldedArray
      else
         -- change the foldState
      end if
   end if
end _NormalizeArrayView

private command _NormalizeView @pDisplayView, pStackLabel, pTitle
   if exists (pDisplayView) is false then
      switch
         case someContent is empty
            put display_FindView (pStackLabel, pTitle) into pDisplayView
            break
         case someContent is an array
            put display_FirstOpenView ("Tree", pStackLabel, pTitle) into pDisplayView
            -- put display_FindView (pStackLabel, pTitle, "Display Array") into pDisplayView
            break
         default
            put display_FirstOpenView ("Index", pStackLabel, pTitle) into pDisplayView
            -- put display_FindView (pStackLabel, pTitle, "Display Index") into pDisplayView
      end switch
   end if
end _NormalizeView

private command _setTitles @widgetDisplayTitle, @displayStackLabel, pDisplayTitle, pDefault
   if pDisplayTitle is empty then
      put pDefault into widgetDisplayTitle
      put empty into displayStackLabel
   else
      put word 1 to -1 of item 1 of pDisplayTitle into widgetDisplayTitle
      put word 1 to -1 of item 2 of pDisplayTitle into displayStackLabel
   end if
end _setTitles
