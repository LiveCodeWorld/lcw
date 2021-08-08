script "lib_StackClone"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_StackClone
type: library
version: 0.1

/*Some help*/


--> Working on
-
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

function stack_ClonedStackNames stackName
   put the mainstacks into stackNames
   filter stackNames with (stackName & "*")
   put word 1 to -1 of stackNames into stackNames
   if stackNames is empty then return stackName
   return stackNames
end stack_ClonedStackNames


--> Stack | Frame
-
getprop stack_Frame
   put the stack_Name of the target into stackName
   --
   put the decorations of stack stackName is empty into isFrameless
   put the mode of stack stackName into sMode
   --
   switch
      case isFrameless
         return "frameless"
      case sMode = 4
         return "palette"
      default
         return "toplevel"
   end switch
end stack_Frame

setprop stack_Frame frameStyle
   put the stack_Name of the target into stackName
   --
   switch frameStyle
      case false
      case empty
      case "frameless"
         set the decorations of stack stackName to empty
         break
      case "palette"
         -- palette of stack stackName
         set the style of stack stackName to "palette"
         set the decorations of stack stackName to "default"
         break
      case true
      case "toplevel"
      default
         set the style of stack stackName to "toplevel"
         set the decorations of stack stackName to "default"
   end switch
end stack_Frame

getprop system_Window
   put the stack_Name of the target into stackName
   put the systemwindow of stack stackName into someBoolean
   return someBoolean
end system_Window

setprop system_Window someBoolean
   put the stack_Name of the target into stackName
   set the systemwindow of stack stackName to someBoolean
   return someBoolean
end system_Window


--> Stack | Display | Outline
-
getprop stack_Outline
   put the short name of the stack_Object of the target into stackName
   return stack_SubStackOutline(stackName)
end stack_Outline


--> Stack | Fade
-
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


--> Stack | Drag
-
command stack_Drag stackObject
   if stackObject is empty then put the stack_Object of the target into stackObject
   put the rect of stackObject into oRect
   put the screenmouseloc into fromPoint
   
   repeat while the mouse is "Down"
      put the screenmouseloc into toPoint
      loc_SetTranslationVector fromPoint, toPoint, xVector, yVector
      put rect_TranslateByVector(oRect, xVector, yVector) into newRect
      set the rect of stackObject to newRect
   end repeat
end stack_Drag


--> Stack | Clone
-
command stack_Clone stackNameToClone, pStackLabel, pCloneName, pDestroyBoolean
   if exists (stack stackNameToClone) is false then return empty
   --
   stack_CloneInvisible stackNameToClone, pCloneName, pDestroyBoolean
   put the result into clonedStackName
   --
   if pStackLabel is not empty then
      set the label of stack clonedStackName to pStackLabel
   end if
   --
   stack_SetToMainScreen clonedStackName
   set the visible of stack clonedStackName to true
   --
   put the name of stack clonedStackName into clonedStack
   return clonedStack
end stack_Clone

command stack_CloneInvisible stackNameToClone, pCloneName, pDestroyBoolean
   if exists (stack stackNameToClone) is false then return empty
   if pCloneName is empty then put stackNameToClone into pCloneName
   --
   _CheckAndResetCloneName pCloneName
   --
   clone invisible stack stackNameToClone as pCloneName
   put it into clonedStack
   if pDestroyBoolean is not false then
      set the destroyStack of clonedStack to true
      set the destroyWindow of clonedStack to true
      -- set the cantmodify of clonedStack to true
   end if
   return pCloneName -- used
end stack_CloneInvisible


--> Stack | Position
-
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


--> Stack | Clone | Substacks
-
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


--> Stack | Create
-
/*
Here we experimeent with creeating new stacks and copying objeects (views) to the newly created stacks.
*/

command stack_CreateWithView viewName, pCardMargin, pStackRect, pStackStyle, pHidden
   -- this is not cloning the stack but copying the view to a clean stack
   local pCardScript
   put stack_ConstructNewCloneName (viewName) into stackName
   stack_Create stackName, viewName, pCardMargin, pStackRect, pCardScript, pHidden, pStackStyle
   put the result into createdView
   return createdView
end stack_CreateWithView

command stack_Create stackName, viewName, pCardMargin, pStackRect, pCardScript, pHidden, pStackStyle
   -- this is not cloning the stack but copying the view to a clean stack
   
   _CreateStackWithView viewName, stackName, pCardMargin, pStackStyle, pCardScript
   put the result into createdObject
   --
   put the stack_Object of createdObject into stackObject
   if pStackRect is empty then
      put the width of createdObject into sWidth
      put the height of createdObject into sHeight
      stack_SetDimensions stackObject, sWidth, sHeight, pCardMargin
   else
      set the rect of stackObject to pStackRect
   end if
   --
   if pHidden is not true then set the visible of stackObject to true
   return createdObject
end stack_Create

private command _CreateStackWithView controlOrViewName, pStackName, pCardMargin, pStackStyle, pCardScript
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
   
   if pCardScript is empty then put scaffold_GetTemplate ("Resize Stack Template") into pCardScript -- better to use a behavior !!!
   set the script of cardObject to pCardScript
   
   copy templateObject to cardObject
   put it into createdObject
   return createdObject
end _CreateStackWithView


--> Stack | Close
-
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
      delete stack theSubStack of stack stackName
   end repeat
end stack_CloseSub


--> Stack | Finder
-
command stack_RevealInFinder stackName
   put the filename of stack stackName into someFile
   finder_RevealFileOrFolder someFile
   get the result
   return it
end stack_RevealInFinder


--> Stack | Shrink
-
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


--> Deps
-
command rect_MoveTopLeft @someRect, newTopLeft
   put item 1 of newTopLeft - item 1 of someRect into xVector
   put item 2 of newTopLeft - item 2 of someRect into yVector
   put rect_TranslateByVector (someRect, xVector, yVector) into someRect
end rect_MoveTopLeft
