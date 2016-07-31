script "lib_Object"
--> Metadata
-
name: lib_Object
type: script library
version: 1.1
copyright: David Bovill

/*
This eventually stack contains the handlers to help with manipulating Revolution controls as objects.

These are not real "objects" in an "object oriented programming" (OOP) sense, but borrow from the same philosophy.
In some ways it is more flexible in that you are free to throw away OOP techniques and use simpler concepts.

or you can use OOP techniques to develop your project, taking advantage of the maintainability and ease of
updapting and replacing components that are "work in progress" - then "burning" the finished product into a flat,
non-OOP file for speed optimisation or other reasons.
*/


--> Event | Helpers
-
command mouse_ResizeObject someObject
   put mouse_WithinBorder(someObject) into mouseCorner
   
   put the rect of someObject into newRect
   switch mouseCorner
      case "T"
         put item 2 the mouseLoc - item 2 of newRect into vClickOffset
         repeat while the mouse is "Down"
            put item 2 the mouseLoc into item 2 of newRect
            subtract vClickOffset from item 2 of newRect
            set the rect of someObject to newRect
         end repeat
         break
      case "B"
         put item 2 the mouseLoc - item 4 of newRect into vClickOffset	# will be negative
         repeat while the mouse is "Down"
            put item 2 the mouseLoc into item 4 of newRect
            subtract vClickOffset from item 4 of newRect
            set the rect of someObject to newRect
         end repeat
         break
      case "L"
         put item 1 the mouseLoc - item 1 of newRect into hClickOffset
         repeat while the mouse is "Down"
            put item 1 the mouseLoc into item 1 of newRect
            subtract hClickOffset from item 1 of newRect
            set the rect of someObject to newRect
         end repeat
         break
      case "R"
         put item 1 the mouseLoc - item 3 of newRect into hClickOffset	# will be negative
         repeat while the mouse is "Down"
            put item 1 the mouseLoc into item 3 of newRect
            subtract hClickOffset from item 3 of newRect
            set the rect of someObject to newRect
         end repeat
         break
      case "TL"
         put item 1 the mouseLoc - item 1 of newRect into hClickOffset
         put item 2 the mouseLoc - item 2 of newRect into vClickOffset
         repeat while the mouse is "Down"
            put the mouseLoc into item 1 to 2 of newRect
            subtract hClickOffset from item 1 of newRect
            subtract vClickOffset from item 2 of newRect
            set the rect of someObject to newRect
         end repeat
         break
      case "TR"
         put item 1 the mouseLoc - item 3 of newRect into hClickOffset	# will be negative
         put item 2 the mouseLoc - item 2 of newRect into vClickOffset
         repeat while the mouse is "Down"
            put item 1 of the mouseLoc into item 3 of newRect
            put item 2 of the mouseLoc into item 2 of newRect
            subtract vClickOffset from item 2 of newRect
            subtract hClickOffset from item 3 of newRect
            set the rect of someObject to newRect
         end repeat
         break
      case "BL"
         put item 1 the mouseLoc - item 1 of newRect into hClickOffset
         put item 2 the mouseLoc - item 4 of newRect into vClickOffset	# will be negative
         repeat while the mouse is "Down"
            put item 1 of the mouseLoc into item 1 of newRect
            put item 2 of the mouseLoc into item 4 of newRect
            subtract vClickOffset from item 4 of newRect
            subtract hClickOffset from item 1 of newRect
            set the rect of someObject to newRect
         end repeat
         break
      case "BR"
         put item 1 the mouseLoc - item 3 of newRect into hClickOffset	# will be negative
         put item 2 the mouseLoc - item 4 of newRect into vClickOffset	# will be negative
         repeat while the mouse is "Down"
            put item 1 of the mouseLoc into item 3 of newRect
            put item 2 of the mouseLoc into item 4 of newRect
            subtract hClickOffset from item 3 of newRect
            subtract vClickOffset from item 4 of newRect
            set the rect of someObject to newRect
         end repeat
         break
      default
         grab someObject
   end switch
end mouse_ResizeObject

private command mouse_SetResizedRect hClickOffset, vClickOffset, @newRect
   put item 1 of the mouseLoc into item 1 of newRect
   put item 2 of the mouseLoc into item 4 of newRect
   subtract vClickOffset from item 2 of newRect
   subtract hClickOffset from item 3 of newRect
   set the rect of the target to newRect
end mouse_SetResizedRect

function mouse_WithinBorder someObject
   put 14 into someWidth
   put the rect of someObject into objectRect
   
   put item 2 of the mouseLoc into mouseY
   if mouseY < item 2 of objectRect then
      return empty    
   else if mouseY < (item 2 of objectRect + someWidth) then
      put "T" after theResult
   else if mouseY > item 4 of objectRect then
      return empty    
   else if mouseY > (item 4 of objectRect - someWidth) then
      put "B" after theResult
   end if
   
   put item 1 of the mouseLoc into mouseX
   if mouseX < item 1 of objectRect then
      return empty    
   else if mouseX < (item 1 of objectRect + someWidth) then
      put "L" after theResult
      return theResult
   else if mouseX > item 3 of objectRect then
      return empty
   else if mouseX > (item 3 of objectRect - someWidth) then
      put "R" after theResult
      return theResult
   else if theResult = "Inside" then
      return "Inside"
   else
      return theResult 
   end if
end mouse_WithinBorder

function mouse_WithinCorner someObject
   put 14 into someWidth
   put the rect of someObject into objectRect
   
   -- BR (3,4)
   put objectRect into resizeRect
   put item 3 of resizeRect - someWidth into item 1 of resizeRect
   put item 4 of resizeRect - someWidth into item 2 of resizeRect
   if loc_WithinRect(the mouseLoc, resizeRect) then return "BR"
   
   -- TL (1,2)
   put objectRect into resizeRect
   put item 1 of resizeRect + someWidth into item 3 of resizeRect
   put item 2 of resizeRect + someWidth into item 4 of resizeRect
   if loc_WithinRect(the mouseLoc, resizeRect) then return "TL"
   
   -- TR (3,2)
   put objectRect into resizeRect
   put item 3 of resizeRect - someWidth into item 1 of resizeRect
   put item 2 of resizeRect + someWidth into item 4 of resizeRect
   if loc_WithinRect(the mouseLoc, resizeRect) then return "TR"
   
   -- BL (1,4)
   put objectRect into resizeRect
   put item 1 of resizeRect + someWidth into item 3 of resizeRect
   put item 4 of resizeRect - someWidth into item 2 of resizeRect
   if loc_WithinRect(the mouseLoc, resizeRect) then return "BL"
   
   return empty
end mouse_WithinCorner

function mouse_WithinBottomCorner someObject
   put 14 into someWidth
   
   put the bottomRight of someObject into someLoc
   put someLoc into resizeRect
   put someLoc into item 3 of resizeRect
   subtract someWidth from item 1 of resizeRect
   subtract someWidth from item 2 of resizeRect
   
   return loc_WithinRect(the mouseLoc, resizeRect)
end mouse_WithinBottomCorner


--> Field
-
getprop field_Object
   -- a default
   put the long ID of the target into fieldObject
   if word 1 of fieldObject ="field" then
      return fieldObject
   else
      return empty
   end if
end field_Object

getprop field_Locked
   put the field_Object of the target into fieldObject
   if exists(fieldObject) is false then return empty
   return the lockText of fieldObject
end field_Locked

setprop field_Locked someBoolean
   put the field_Object of the target into fieldObject
   if exists(fieldObject) is false then return empty
   set the lockText of fieldObject to someBoolean
   return someBoolean
end field_Locked

getprop field_TextSize
   put the field_Object of the target into fieldObject
   if exists(fieldObject) is false then return empty
   
   return the textSize of fieldObject
end field_TextSize

setprop field_TextSize someSize
   put the field_Object of the target into fieldObject
   if exists(fieldObject) is false then return empty
   
   set the textSize of fieldObject to someSize
end field_TextSize

getprop field_TextSizes
   return"6,8,9,10,11,12,14,18,14,36,48,72"
end field_TextSizes

getprop field_Style
   put the field_Object of the target into fieldObject
   if exists(fieldObject) is false then return empty
   
   put the uOPN ["field_Style"] of fieldObject into fieldStyle
   return fieldStyle
end field_Style

setprop field_Style fieldStyle
   put the field_Object of the target into fieldObject
   if exists(fieldObject) is false then return empty
   
   set the uOPN ["field_Style"] of fieldObject to fieldStyle
   
   switch fieldStyle
      case "Transparent"
         set the style of fieldObject to "transparent"
         break
      case "Scrolling"
         lock screen
         put the rect of fieldObject into oRect
         set the listBehavior of fieldObject to false
         set the dontWrap of fieldObject to false
         if the style of fieldObject is "scrolling" then
            set the style of fieldObject to "plain"
         else
            set the style of fieldObject to "scrolling"
         end if
         set the view_Rect of fieldObject to oRect
         unlock screen
         break
      case "Index"
         set the dontWrap of fieldObject to true
         if the listBehavior of fieldObject is true then
            set the listBehavior of fieldObject to false
         else
            set the listBehavior of fieldObject to true
         end if
         break
      case "Wide margins"
         set the wideMargins of fieldObject to not the wideMargins of fieldObject 
         break
      case "Small scrollbar"
         get the scrollbarWidth of fieldObject
         opn_Notify it
         break
   end switch
end field_Style

getprop field_Styles
   return "Transparent,Scrolling,Index,Wide margins,Small scrollbar"
end field_Styles

getprop field_SelectedIndex
   put the long ID of the target into fieldObject
   if word 1 of fieldObject is not "field" then return empty
   return the selectedText of fieldObject
end field_SelectedIndex

setprop field_SelectedIndex someIndex
   put the long ID of the target into fieldObject
   if word 1 of fieldObject is not "field" then return empty
   
   set the wholeMatches to true
   put the text of fieldObject into fullIndex
   repeat for each line someLine in someIndex
      put lineOffset(someLine, fullIndex) into lineNum
      if lineNum is not 0 then put lineNum & comma after litLines
   end repeat
   delete char -1 of litLines
   set the hilitedlines of fieldObject to litLines
   return litLines
end field_SelectedIndex

command field_SelectText startChar, endChar, someField
   put merge("select char [[startChar]] to [[endChar]] of [[someField]]") into doScript
   do doScript
   return the result
end field_SelectText

command field_SelectLines startLineNum, endLineNum, someField
   put merge("select line [[startLineNum]] to [[endLineNum]] of [[someField]]") into doScript
   do doScript
   return the result
end field_SelectLines

command field_DeleteText startChar, endChar, someField
   put merge("delete char [[startChar]] to [[endChar]] of [[someField]]") into doScript
   do doScript
   return the result
end field_DeleteText

command field_DeleteLine lineNum, someField
   put merge("delete line [[lineNum]] of [[someField]]") into doScript
   do doScript
   return the result
end field_DeleteLine

function field_GetLinkText lineNum, someField
   -- also works with trees and selections that include tabs and spaces
   if word 1 of someField is not "field" then return empty
   
   put the short ID of someField into fieldID
   put the stack_Object of someField into stackObject
   get the linkText of word 1 to -1 of line lineNum of field ID fieldID of stackObject
   
   -- in case quotes have been encoded
   -- replace "'" with quote in it
   replace "&quot;" with quote in it
   return it
end field_GetLinkText

command field_HyperText someLink, targetObject
   if targetObject is empty then put the long ID of the target into targetObject
   set the itemDelimiter to ":"
   switch item 1 of someLink
      case "http"
         opn_GoUrl someLink
         break
      default
         if the script_CheckSafe [someLink] of targetObject is not false then
            try
               -- do someLink
               send someLink to targetObject
            catch errorNum
               get the opn_Error [errorNum] of me
            end try
         end if
   end switch
end field_HyperText

command field_HyperMenu
   put the long ID the target into targetObject
   
   if the selection is empty then
      select the clickChunk
   end if
   
   if the selection is empty then
      put the clickLoc into somelocation
      put the textStyle of the clickChunk into selectedStyle
      put the field_Menu [""] of targetObject into menuTitle	# ???
   else
      put the formattedRect of the selectedChunk into selectedRect
      if selectedRect is empty then return false
      
      if loc_WithinRect(the clickLoc, selectedRect) then
         put the field_Menu ["Inside"] of targetObject into menuTitle
      else
         select the clickChunk
         put the formattedRect of the selectedChunk into selectedRect
         if selectedRect is empty then return false
         
         put the field_Menu ["Outside"] of targetObject into menuTitle
      end if
      
      put item 1 of selectedRect into someLocation
      put item 4 of selectedRect + 6 into item 2 of someLocation
      
      put the textStyle of the selectedChunk into selectedStyle
   end if
   
   put the linkText of the selectedChunk into someLink
   switch someLink
      case ""
         menu_PopUp menuTitle, someLocation
         return true
      default
         if word 1 of someLink is "menu_Option" then
            -- this sets the text of the menu
            -- field_HyperText someLink, targetObject
            send someLink to targetObject
            
            put the menu_Button of the target into mButton
            menu_ClearTargetGlobals
            -- should set other stuff here mTitle and mTarget???
            menu_SetTargetObject targetObject
            
            popup mButton at someLocation
            set the menu_Action of mButton to empty
            return true
         else
            return false
         end if
   end switch
end field_HyperMenu

command menu_Option optionList, optionCommand
   /*
   used to show pop up menu on linked text clicked in hypermenu field"
   */
   
   put the name of the target into targetObject
   put the menu_Button of targetObject into mButton
   
   if optionCommand is empty then put "field_SetLinkedText" into optionCommand
   
   replace comma with CR in optionList
   set the text of mButton to optionList
   
   set the menu_Action of mButton to optionCommand
end menu_Option

command field_SetLinkedText newLinkText, startChar, endChar, someField
   if startChar is empty then
      put the selectedChunk into someChunk
      put the selectedField into someField 
      put word 2 of someChunk into startChar
      put word 4 of someChunk into endChar
   end if
   
   put the linkText of someChunk into someLink
   put the textStyle of someChunk into oStyle
   
   set the field_Text [startChar,endChar] of someField to newLinkText
   
   put startChar + the number of chars of newLinkText into endChar
   set the textStyle of char startChar to endChar of someField to oStyle
   set the linkText of char startChar to endChar of someField to someLink
end field_SetLinkedText


--> Field | Scrolling
-
command field_ScrollToLine lineNum, fieldObject, pSelectLine
   -- does not seem accurate for large line numbers (it's an underestimate) ???
   
   if lineNum = 0 then
      put 0 into someScroll
   else if lineNum is a number then
      put the effective textHeight of fieldObject into lineHeight
      put ((lineNum - 1) * lineHeight) - 0 * the height of fieldObject into someScroll
   else -- any text = "bottom"
      -- bit of a hack (but works :)
      put the effective textHeight of fieldObject into lineHeight
      put the number of lines of the text of fieldObject into lineNum
      put ((lineNum - 1) * lineHeight) - 0 * the height of fieldObject into someScroll
   end if
   set the scroll of fieldObject to someScroll
   if pSelectLine is not false then
      select line lineNum of fieldObject
   end if
end field_ScrollToLine


--> Field | Properties
-
getprop field_AutoScrollBar
   put the long ID of the target into someField
   if word 1 of someField is not "field" then return "Error: target is not a field"
   
   if the formattedHeight of someField > the height of someField then
      set the vScrollbar of someField to true
      return true
   else
      set the vScrollbar of someField to false
      return false
   end if
end field_AutoScrollBar

getprop field_Menu [someType]
   -- more complicated but allows local overriding!
   
   switch someType 
      case "Inside"
         -- a click on an existing selection
         -- set the menu_Title of the target to "Field | Menu"
         put the menu_Title of the target into menuTitle
         return menuTitle
      case "Outside"
         -- a click on a new empty selection
         return "Global | HyperField | Menu"
      case empty
         return "Global | Field | Menu"
   end switch
end field_Menu

getprop field_WrappedText
   put the formattedtext of the target into fText
   repeat for each line someLine in fText
      put word 1 to -1 of someLine & "\n" after nText
   end repeat
   delete char -2 to -1 of nText
   return nText
end field_WrappedText

getprop field_Text [charOffsets]
   put the long ID of the target into someField
   
   if charOffsets is empty then
      put "get the text of someField" into doScript
   else
      put item 1 of charOffsets into startChar
      put item 2 of charOffsets into endChar
      
      -- put "get char startChar to endChar of someField" into doScript	# does not work
      -- put "get the text of char startChar to endChar of" && someField into doScript	# does not work
      put "get char startChar to endChar of" && someField into doScript
      -- put merge("get char [[startChar]] to [[endChar]] of [[someField]]") into doScript
   end if
   do doScript
   return it
end field_Text

setprop field_Text [charOffsets] someText
   put the long ID of the target into someField
   
   if charOffsets is eempty then
      put "set the text of someField to someHtml" into doScript
   else
      put item 1 of charOffsets into startChar
      put item 2 of charOffsets into endChar
      put merge("put someText into char [[startChar]] to [[endChar]] of [[someField]]") into doScript
   end if
   do doScript
   return the result
end field_Text

getprop field_HtmlText [charOffsets]
   put the long ID of the target into someField
   
   if charOffsets is eempty then
      put "get the htmltext of someField" into doScript
   else
      put item 1 of charOffsets into startChar
      put item 2 of charOffsets into endChar
      put "get the htmltext of char startChar to endChar of someField" into doScript
   end if
   do doScript
   return it
end field_HtmlText

setprop field_HtmlText [charOffsets] someHtml
   put the long ID of the target into someField
   
   if charOffsets is empty then
      put "set the htmltext of someField to someHtml" into doScript
   else
      put item 1 of charOffsets into startChar
      put item 2 of charOffsets into endChar
      put "set the htmltext of char startChar to endChar of someField to someHtml" into doScript
   end if
   do doScript
   return the result
end field_HtmlText

getprop field_LinkVisited [someWord]
   put the short ID of the target into fieldID
   
   put wordOffset(someWord, the text of field ID fieldID) into wordNum
   if wordnum = 0 then return false
   return the visited of word wordNum of field ID fieldID
end field_LinkVisited

setprop field_LinkVisited [someWord] boolean
   put the short ID of the target into fieldID
   
   put wordOffset(someWord, the text of field ID fieldID) into wordNum
   if wordnum = 0 then return empty
   set the visited of word wordNum of field ID fieldID to boolean
   return wordNum
end field_LinkVisited

getprop field_TextAlign
   put the long ID of the target into someField
   if word 1 of someField is "field" then
      return the textAlign of someField
   else
      return empty
   end if
end field_TextAlign

setprop field_TextAlign fieldTextAlign
   put the long ID of the target into someField
   if word 1 of someField is "field" then
      set the textAlign of someField to fieldTextAlign
      return true
   else
      return false
   end if
end field_TextAlign

getprop field_TextAligns
   get "left,center,right"
   replace comma with CR in it
   return it
end field_TextAligns

getprop field_Locked
   return the lockText of the target
end field_Locked

setprop field_Locked [makeList] someBoolean
   -- was "field_LockText"
   
   put the long ID of the target into fieldObject
   
   if word 1 of fieldObject is "field" then
      set the lockText of fieldObject to someBoolean
      if makeList is not empty then set the listBehavior of fieldObject to makeList is true
      
      if the listBehavior of fieldObject is true then
         if someBoolean is true then
            put the uOPN ["listbehavior"] of fieldObject into oBoolean
            put oBoolean is not false into oBoolean
            
            set listBehavior of fieldObject to oBoolean
         else
            set the uOPN ["listbehavior"] of fieldObject to true
            set listBehavior of fieldObject to false
         end if
      else
         set the traversalOn of fieldObject to true
         set the autoHilite of fieldObject to true
      end if
   end if
end field_Locked


--> Groups
-
getprop object_GroupIndex [setShort]
   -- was "object_GroupIndex"
   put the long ID of the target into containerObject
   return group_GetObjectIndex(containerObject, setShort, false)
end object_GroupIndex

function group_GetObjectIndex containerObject, setShort, visibleOnly
   -- was "object_GetGroupIndex"
   put empty into objectIndex
   
   if setShort is not false then object_SetShortStackName containerObject, stackNameStart, stackNameEnd
   put containerObject & return after objectIndex
   
   get object_ControlsInside(containerObject, setShort, visibleOnly)
   if it is empty then
      delete last char of objectIndex
   else
      put it after objectIndex
   end if
   return objectIndex
end group_GetObjectIndex

command group_SetNameArray someGroup, @groupNameArray, @orderedNames, nested
   -- was "object_SetGroupNameArray"
   repeat with controlNum = 1 to the number of controls in someGroup
      put the long ID of control controlNum of someGroup into controlObject
      if nested is not true and word 1 of controlObject is "group" then
         add the number of layers in controlObject to controlNum
      end if
      
      put the short name of controlObject into objectName
      put objectName & CR after orderedNames
      put controlObject into groupNameArray [objectName]
   end repeat
   delete char -1 of orderedNames    
end group_SetNameArray

function group_NameArray someGroup, nested
   -- was "object_GroupNameArray"
   group_SetNameArray someGroup, groupNameArray, orderedNames, nested
   return groupNameArray
end group_NameArray


--> Library
-
getprop library_Stack
   -- could do clever stuff to fetch linked stacks
   -- but for now
   
   put the stack_Object of the target into libraryStack
   if the object_IsLibrary of libraryStack is true then
      return libraryStack
   else
      return empty
   end if
end library_Stack


--> Object
-
function object_IsSame
   put param (1) into firstObject
   if exists (firstObject) is false then return false
   put the long id of firstObject into firstObject
   repeat with paramNum = 2 to the paramcount
      put param (paramNum) into someObject
      if exists (someObject) is false then return false
      put the long id of someObject = firstObject into someBoolean
      if someBoolean = false then return false
   end repeat
   return true
end object_IsSame

function objects_MakeFriendlyArray someObjects
   objects_MakeFriendly someObjects, friendlyObjects, friendlyArray
   put friendlyArray
end objects_MakeFriendlyArray

command objects_MakeFriendly someObjects, @orderedFriendlyObjects, @friendlyArray
   -- used to make nice freindly menus for instance
   repeat for each line someObject in someObjects
      if exists (someObject) is false then next repeat
      put the long id of someObject into longIDObject
      put object_MakeFriendly (longIDObject) into friendlyObject
      put longIDObject into friendlyArray [friendlyObject]
      put friendlyObject & CR after orderedFriendlyObjects
   end repeat
   delete the last char of orderedFriendlyObjects
end objects_MakeFriendly

function object_MakeFriendly scriptObject
   -- same as Script Editor" function "seFriendlyObject"
   put word 1 of the name of scriptObject & space into tFriendlyName
   
   if the name of scriptObject is the short name of scriptObject then
      -- This means that the object essentially has no name, eg its name is: card id 1002 or similar.
      put word -1 of the short name of scriptObject after tFriendlyName
   else
      put quote & the short name of scriptObject & quote after tFriendlyName
   end if
   return tFriendlyName
end object_MakeFriendly

getprop mainstack_File
   put the stack_Object of the target into stackObject
   return the effective filename of stackObject
end mainstack_File

getprop object_Behaviors
   local objectBehaviors
   put the long id of the target into targetObject
   
   put the behavior of targetObject into someBehavior
   if someBehavior is not empty then put someBehavior & CR after objectBehaviors
   
   repeat with cNum = 1 to the number of controls of targetObject
      put the behavior of control cNum of targetObject into someBehavior
      if someBehavior is not empty then
         put someBehavior & CR after objectBehaviors
      end if
   end repeat
   delete char -1 of objectBehaviors
   return objectBehaviors
end object_Behaviors

getprop object_CantDelete
   put the long ID of the target into someObject
   if word 1 of someObject is among the items of "group,card,stack" then
      return the cantDelete of someObject
   else
      return false
   end if
end object_CantDelete

command object_SelfDelete
   -- not clean redraw
   lock  screen
   put the long ID of the target into emailObject
   send "delete emailObject" to the target in 2 ticks
   unlock screen
end object_SelfDelete

function object_Contains someContainer, testObject
   put the long ID of someContainer into someContainer
   get the long ID of testObject
   if someContainer = it then
      -- inside
      return true
   else if someContainer contains it then
      -- scriptObject is shorter so it is outside
      return false
   else if it contains someContainer then
      -- it is inside
      return true
   else
      -- -- somwhere entirely else
      return false
   end if
end object_Contains


--> Object | Names
-
getprop object_Name
   put the long ID of the target into targetObject
   
   put the object_Metadata ["name"] of targetObject into someName
   set the uRIP ["name"] of targetObject to someName	# in case it has not already been set
   return someName
end object_Name

getprop virtual_Child [fixedName]
   put the long ID of the target into targetObject
   
   -- slower but better would be to restrict to top level
   put the object_RealName [fixedName] of targetObject into realName
   return the long ID of control realName of targetObject
end virtual_Child

getprop virtual_Object [propertyReference]
   -- old so phase out (use "virtual_Child")
   
   put the long ID of the target into someView
   
   replace "_" with space in propertyReference
   put "_" & propertyReference into fixedName
   
   put the object_RealName [fixedName] of someView into realName
   put the long ID of control realName of someView into virtualObject
   return virtualObject
end virtual_Object


--> Object | Names | Real
-
getprop object_RealName [fixedName]
   -- authoring version
   put the long ID of the target into someView
   
   put the uOPN_ObjectNameArray [fixedName] of someView into realName
   if realName is empty then
      -- assume it is first time
      if exists(control fixedName of someView) then
         -- guess that is what we want and initate
         set the uOPN_ObjectNameArray [fixedName] of someView to fixedName
         return fixedName
      else
         return empty
      end if
   end if
   return realName
end object_RealName

setprop object_RealName [fixedName] realName
   put the long ID of the target into someView
   
   set the name of someView to realName
   set the uOPN_ObjectNameArray [fixedName] of someView to realName
   set the name of someView to realName
end object_RealName

command object_RealNameChanged oldName, newName, someView, modelObject
   put the customProperties ["uOPN_ObjectNameArray"] of modelObject into nameArray
   repeat for each key fixedName in nameArray
      put nameArray [fixedName] into oldRealName
      if oldRealName is oldName then
         set the uOPN_ObjectNameArray [fixedName] of modelObject to newName
      end if
   end repeat
end object_RealNameChanged


--> Object | Names | Real | Local Version
-
getprop object_RealName [fixedName]
   -- local version   
   put Local_ObjectNameArray [fixedName] into realName
   if realName is empty then   -- assume it is first time
      if exists (control fixedName of someView) then  -- guess that is what we want and initate
         put fixedName into Local_ObjectNameArray [fixedName]
         return fixedName
      else
         return empty
      end if
   end if
   return realName
end object_RealName

setprop object_RealName [fixedName] realName
   -- local version   
   
   set the name of the target to realName
   put realName into Local_ObjectNameArray [fixedName]
end object_RealName

command object_RealNameChanged oldName, newName
   -- local version
   repeat for each key fixedName in Local_ObjectNameArray
      put Local_ObjectNameArray [fixedName] into oldRealName
      if oldRealName is oldName then
         put newName into Local_ObjectNameArray [fixedName]
      end if
   end repeat
end object_RealNameChanged


--> Object | Containers
-
/*
Not just groups - cards or stacks.
These script should not fail when passed any object.
*/

getprop object_GroupIDs [visibleOnly]
   put the long ID of the target into targetObject
   return object_GroupShortIds(targetObject, visibleOnly)
end object_GroupIDs

function object_GroupShortIds someObject, visibleOnly
   -- was "object_GroupIDs"
   local idIndex
   put visibleOnly is true into visibleOnly
   repeat with groupNum = 1 to the number of groups in someObject
      if the visible of group groupNum of someObject is false and visibleOnly is true then next repeat
      put the short ID of group groupNum of someObject into someID
      put someID & CR after idIndex
   end repeat
   delete last char of idIndex
   return idIndex
end object_GroupShortIds


--> Object | Snapshots
-
getprop object_SnapShot [imageType]
   put the long ID of the target into targetObject
   put the stack_Object of targetObject into stackObject
   
   put the windowID of stackObject into wID
   put the rect of targetObject into localRect
   
   put the defaultStack into oDefault
   set the defaultStack to the stack_Object of targetObject
   
   switch imageType
      case "Simple"
         -- needed because otherwise long reference produces cross hairs
         put the short ID of targetObject into someID
         export snapshot from control ID someID to someImage as PNG
         break
      case "Transparent"
         -- this will also snap any overlying windows
         topLevel stackObject
         put the global_Rect of targetObject into globalRect
         if globalRect is not a rect then return empty
         export snapshot from rect globalRect of targetObject to someImage as PNG
         break
      case "GIF"
         export snapshot from rect localRect of window wID to someImage as GIF
         break
      case "JPG"
         export snapshot from rect localRect of window wID to someImage as JPEG
         break
      case "JPEG"
         export snapshot from rect localRect of window wID to someImage as JPEG
         break
      default
         export snapshot from rect localRect of window wID to someImage as PNG
   end switch
   set the defaultStack to oDefault
   return someImage
end object_SnapShot


--> Object | Geometry
-
getprop object_RelativeRect [referenceObject]
   put the long ID of the target into objectToSet
   put object_GetRelativeRect(referenceObject, objectToSet) into relativeRect
   return relativeRect
end object_RelativeRect

setprop object_RelativeRect [referenceObject] relativeRect
   put the long ID of the target into objectToSet
   object_SetRelativeRect referenceObject, objectToSet, relativeRect
end object_RelativeRect

function object_GetRelativeRect referenceObject, objectToSet
   put the topLeft of referenceObject into topLeftLoc
   put the rect of objectToSet into someRect
   rect_SubtractVector someRect, topLeftLoc
   return someRect
end object_GetRelativeRect

command object_SetRelativeRect referenceObject, objectToSet, relativeRect
   put the topLeft of referenceObject into topLeftLoc
   rect_AddVector relativeRect, topLeftLoc
   set the rect of objectToSet to relativeRect
end object_SetRelativeRect


--> Object | Eric
-
function object_IsVisible pObj
   if not the visible of pObj then return false
   repeat until "Card" is word 1 of the long owner of pObj
      put the long owner of pObj into pObj
      if not the visible of pObj then return false
   end repeat
   return true
end object_IsVisible

function object_ObjOwners pObj
   -- return the owners of any object until the card (not included)
   local tOwner,tOwners
   -----
   put pObj into tOwner
   repeat until "Card" is word 1 of the long owner of tOwner
      put the long owner of tOwner & cr after tOwners
      put the long owner of tOwner into tOwner
   end repeat
   if tOwners = empty then return pObj
   return pObj & cr & line 1 to -1 of tOwners
end object_ObjOwners

function object_OutOfCardWindow pObj,pCard
   -- OutOfCardWindow returns is an object is out of the card window:
   
   if the left of pObj > the right of pCard then return true
   if the right of pObj < 0 then return true
   if the bottom of pObj < 0 then return true
   if the top of pObj > the bottom of pCard then return true
   return false
end object_OutOfCardWindow

function object_IsHiddenByAnotherControl pObj,pCard
   -- IsHiddenByAnotherControl checks if a control can be hidden by another one:
   
   repeat with i = (the layer of pObj + 1) to the number of controls of pCard
      if the topLeft of pObj is within the rect of control i of pCard and the botright of pObj is within the rect of control i of pCard and the opaque of control i of pCard then return true
   end repeat
   return false
end object_IsHiddenByAnotherControl


--> Object | Tests
-
getprop object_IsView
   put the long ID of the target into targetObject
   
   -- chould use custom property (but easy to have errors can't see?)
   -- put the uRIP ["type"] of targetObject
   
   -- so lets use the fact that the script contains getprop view_Object handler
   put the script of targetObject into someScript
   put the parentscript of targetObject into parentScriptObject
   if exists(parentScriptObject) then
      put CR & CR & the script of parentScriptObject after someScript
   end if
   put script_ExtractGetPropHandlers(someScript) into getPropHandlerIndex
   
   set the wholeMatches to true
   return "view_Object" is among the lines of getPropHandlerIndex
end object_IsView

getprop object_IsWithinView
   -- a view which is a shared background would intercept view_object
   -- this script then tests if it is actually within the view and not just on message path of "view_Object
   
   put the long ID of the target into targetObject
   put the view_Object of targetObject into viewObject
   if exists(viewObject) then
      return targetObject contains the long ID of viewObject
   else
      return false
   end if
end object_IsWithinView

getprop object_IsLibrary
   return the uRIP ["type"] of the target is "library"
end object_IsLibrary

function object_WithinStack objectIndex, stackObject
   put the stack_Object of stackObject into stackObject
   repeat for each line someObject in objectIndex
      if exists(someObject) is false then next repeat
      if the stack_Object of someObject = stackObject then
         put someObject & CR after filteredObjects
      end if
   end repeat
   delete char -1 of filteredObjects
   return filteredObjects
end object_WithinStack

getprop object_ScriptSaved
   put the long ID of the target into someObject
   
   --  put the git_RevisionScript of someObject into revisionScript
   put the script of someObject into nowScript
   put the script_File of someObject into someFile
   put URL ("file:" & someFile) into localScript
   return localScript = nowScript
end object_ScriptSaved

function object_IsSame someObject, anotherObject
   if exists(someObject) is false then return empty
   if exists(anotherObject) is false then return empty
   
   put the long ID of someObject into someObject
   put the long ID of anotherObject into anotherObject
   return someObject = anotherObject
end object_IsSame


--> Object | Mobile
-
getprop main_Name
   -- used for cloned substacks
   put the long ID of the target into targetObject
   put the name of targetObject into mobileObject
   put object_ExtractStack (targetObject) into stackObject
   put the mainStack of stackObject into mainName
   get mobileObject && "of stack" && kwote(mainName)
   return it
end main_Name

getprop object_Owner
   -- a safe way to work out the object owner
   put the long id of the target into tObject
   return object_GetOwner (tObject)
end object_Owner

function object_GetOwner tObject
   put the long id of tObject into tOwner
   switch
      case word 1 of tOwner = "stack"
         put the main_Stack of tObject into mainStackObject
         if mainStackObject = tObject then
            return empty
         else
            return mainStackObject
         end if
      case word 1 of tObject = "group" and the backgroundbehavior of tObject is true
         -- easy to get recursion, so let's return the owner of the background group which is the stack
         return the stack_Object of tOwner 
      default
         delete word 1 to 4 of tOwner
         return tOwner
   end switch
end object_GetOwner

function object_ExtractStack someObject
   set the wholematches to true
   put word (wordOffset ("stack", someObject)) to -1 of someObject into stackObject
   return stackObject
end object_ExtractStack

getprop mobile_ID
   put the long name of the target into targetObject
   put the short ID of targetObject into someID
   
   if word 1 of targetObject is "stack" then
      put targetObject into longStackObject
   else
      put object_ExtractStack(targetObject) into stackObject
      put word 1 of targetObject && "id" && someID && "of" && stackObject into longStackObject
   end if
   object_SetShortStackName longStackObject, mainStackStart, mainStackEnd
   return longStackObject
end mobile_ID

getprop object_MobileID
   put the long ID of the target into mobileObject
   object_SetShortStackName mobileObject, mainStackStart, mainStackEnd
   return mobileObject
end object_MobileID

getprop object_LocalID
   put the long ID of the target into someObject
   object_SetShortStackName someObject, mainStackStart, mainStackEnd
   object_WithinStackReference someObject
   return someObject
end object_LocalID

getprop mobile_ControlName
   put the name of the target into nameObject
   put the stack_Name of the target into stackName
   return nameObject && "of stack" && kwote(stackName)
end mobile_ControlName

command object_WithinStackReference @someObject
   -- was "object_SetIdReference"
   put offset(" of stack ", someObject) into lastChar
   if lastChar = 0 then return someObject
   put char 1 to lastChar of someObject into someObject
end object_WithinStackReference


--> Object | Reference
-
/*
Perhaps these should be view properties?
*/

getprop object_FromReferencePath [objectRefPath]
   put the long ID of the target into someObject
   return object_ConstructFromReferencePath(objectRefPath, someObject, "/")
end object_FromReferencePath

function object_ConstructFromReferencePath objectRefPath, someObject, pathDelim
   if pathDelim is empty then put "/" into pathDelim
   set the itemDelimiter to pathDelim
   repeat for each item objectRef in objectRefPath
      if exists(someObject) is false then return empty
      put the objectRef of someObject into someObject
   end repeat
   return someObject
end object_ConstructFromReferencePath

getprop object_FromReference [someReference]
   put the long ID of the target into targetObject
   return object_ReferenceToControl(someReference, targetObject)
end object_FromReference

function object_IndexFromReferences someReferences, targetObject
   put empty into objectIndex
   repeat for each line someReference in someReferences
      put object_ReferenceToControl(someReference, targetObject) & return after objectIndex
   end repeat
   delete last char of objectIndex
   return objectIndex
end object_IndexFromReferences

/*
function object_PropertiesToReferences objectPropertyNames
   put empty into objectReferences
   repeat for each line objectProperty in objectPropertyNames
      put "opnReference" && objectProperty & return after objectReferences
   end repeat
   delete last char of objectReferences
   return objectReferences
end object_PropertiesToReferences

getprop target_Object [someReference]
   put the long id of the target into targetObject
   if someReference is empty then return targetObject
   get object_ReferenceToControl(someReference, targetObject)
   if it is empty then
      return targetObject
   else
      return it
   end if
end target_Object

function object_NameToReference originalName
   if char 1 of originalName is "_" then delete char 1 of originalName	# should be an underScore
   replace space with "_" in originalName
   put "opnReference" && originalName into objectReference
   return objectReference
end object_NameToReference

function object_ReferenceToName objectReference
   if char 1 to 3 of objectReference is "opn" then
      delete word 1 of objectReference
      replace "_" with space in objectReference
      return "_" & objectReference
   else
      -- could try to get from the object?
      return empty
   end if
end object_ReferenceToName

getprop object_ReferenceHandler [handlerName]
   put the long id of the target into targetObject
   return script_ConstructReferenceHandler(targetObject, "", handlerName)
end object_ReferenceHandler
*/


--> Object | Deconstruction
-
command object_SetRelativeGroup @someObject, someGroup
   put " of " before someGroup
   put offset(someGroup, someObject) into startCharNum
   delete char startCharNum to -1 of someObject
   return someObject
end object_SetRelativeGroup


--> Object | Layer
-
getprop object_GroupLayer
   put the long ID of the target into someObject
   put someObject into containerGroup
   delete word 1 to 4 of containerGroup
   
   repeat with controlNum = 1 to the number of controls in containerGroup
      put the long ID of control controlNum of containerGroup into testObject
      if testObject = someObject then
         /*
         lock screen
         put the short id of testObject into someID
         start editing containerGroup
         put the layer of control id someID into withinGroupLayer
         stop editing
         unlock screen
         */
         put the layer of testObject - the layer of containerGroup into withinGroupLayer
         return withinGroupLayer
      end if
   end repeat
   return empty
end object_GroupLayer

setprop object_GroupLayer withinGroupLayer
   put the long ID of the target into someObject
   put someObject into containerGroup
   delete word 1 to 4 of containerGroup
   
   put the short ID of someObject into someID
   
   lock screen
   start editing containerGroup
   set the layer of control ID someID to withinGroupLayer
   stop editing
   unlock screen
end object_GroupLayer

command object_BringToFront someObject, containerGroup
   lock screen
   put the short ID of someObject into someID
   
   start editing containerGroup
   set the layer of control ID someID to top
   stop editing
   unlock screen
end object_BringToFront

command object_SendToBack someObject, containerGroup
   lock screen
   put the short ID of someObject into someID
   
   start editing containerGroup
   set the layer of control ID someID to bottom
   stop editing
   unlock screen
end object_SendToBack


--> Object | Utility
-
function object_FolderOfStack someObject,  localPath
   object_Deconstruct someObject, someControl, cardObject, stackFileName
   put folder_Above(stackFileName) into someFolder
   if localPath is not empty then
      if char 1 of localPath is "/" then delete char 1 of localPath
      if char -1 of localPath is not "/" then put "/" after localPath
      put localPath after someFolder
      if there is not a folder someFolder then
         folder_CreateNested someFolder
      end if
   end if
   return someFolder
end object_FolderOfStack

command object_GoTo someObject, pStackVisible
   if exists (someObject) is false then return merge("Error, [[someObject]] does not exist")
   
   put the stack_Name of someObject into stackName
   put the card_Object of someObject into cardObject
   if exists(cardObject) is false then
      go to stack stackName
   else
      put the short id of cardObject into cardID
      go to card id cardID of stack stackName
   end if
   -- stack_SetToMainScreen stackName
   show stack stackName
   return the result
end object_GoTo

command object_MakeLabelGroup
   -- called by newGroup
   put the long ID of the target into someGroup
   set the margins of someGroup to 0
   repeat with fieldNum = 1 to the number of fields of someGroup
      put the long ID of field fieldNum of someGroup into someField
      if char 1 of the short name of someField is "_" then
         -- assume it is a label
         put the text of someField into groupName
         replace ":" with empty in groupName
         put word 1 to -1 of groupName into groupName
         
         ask "What name would you like to give this new lable group?" with groupName
         if it is empty then exit to top
         put it into groupName
         
         set the name of someGroup to groupName
         -- put merge("Set the name of this group to '[[groupName]]'")
         exit repeat
      end if
   end repeat
end object_MakeLabelGroup


--> Object | Effects
-
command object_PrettyHide someObject
   if "Cross Fade" is among the lines of the QTEffects then
      hide someObject with visual effect "Cross Fade"
   else
      hide someObject with visual effect dissolve
   end if
end object_PrettyHide

command object_PrettyShow someObject
   if "Cross Fade" is among the lines of the QTEffects then
      show someObject with visual effect "Cross Fade"
   else
      show someObject with visual effect dissolve
   end if
end object_PrettyShow


--> Top
-
getprop top_Controls
   put the long ID of the target into targetObject
   return object_GetGroupControls (targetObject, false)
end top_Controls

getprop top_Views
   put the long ID of the target into groupOrCard
   return object_GetTopViews (groupOrCard)
end top_Views


--> Object | Top
-
getprop top_Control [pName]
   put the childcontrolids of the target into topControlIDs
   switch
      case pName is empty
         put line 1 of topControlIDs into cID
         if cID is empty then return empty
         return the long id of control id cID of the target
      case pName is a number
         put line pName of topControlIDs into cID
         if cID is empty then return empty
         return the long id of control id cID of the target
      default
         repeat for each line cID in topControlIDs
            put the long id of control id cID of the target into topControl
            if the short name of topControl = pName then
               return topControl
            end if
         end repeat
         return empty
   end switch
end top_Control

getprop object_TopControls
   put the long ID of the target into targetObject
   return object_GetGroupControls(targetObject, false)
end object_TopControls

function object_TopLevelGroup someCard, testGroupName
   object_SetToplevelGroupArrays topLevel_NameDictionary, topLevel_IdDictionary, someCard
   put keys(topLevel_NameDictionary) into possibleGroupNames
   put keys(topLevel_IdDictionary) into possibleGroupIds
   
   -- guess from the name
   repeat for each line possibleGroup in possibleGroupIds
      if the short name of possibleGroup is testGroupName then
         return possibleGroup
      end if
   end repeat
   return empty
end object_TopLevelGroup

getprop object_TopViews
   put the long ID of the target into groupOrCard
   return object_GetTopViews (groupOrCard)
end object_TopViews

function object_GetTopViews groupOrCard
   put the object_TopControls of groupOrCard into topControls
   put empty into topViews
   repeat for each line someObject in topControls
      if the object_IsView of someObject is true then
         put someObject & CR after topViews
      end if
   end repeat
   delete last char of topViews
   return topViews
end object_GetTopViews

getprop object_TopGroupIDs
   put the long ID of the target into someContainer
   
   local topGroupIDs
   repeat with controlNum = 1 to the number of controls in someContainer
      put the long ID of control controlNum of someContainer into someObject
      if word 1 of someObject is "group" then
         add the number of layers in someObject to controlNum
         put the short ID of someObject & comma after topGroupIDs
      end if
   end repeat
   delete last char of topGroupIDs
   return topGroupIDs
end object_TopGroupIDs

getprop object_TopGroups [visibleOnly]
   put the long ID of the target into someContainer
   return object_GetTopGroups(someContainer, true, visibleOnly)
end object_TopGroups

function object_GetTopGroups someContainer, setShort, visibleOnly
   -- was "object_TopGroups"
   -- this stem technique is not needed (use same as "object_GetGroupControls")
   
   put the long ID of someContainer into someContainer
   put empty into myGroups
   repeat with groupNum = 1 to the number of groups in someContainer
      put the long ID of group groupNum of someContainer into testGroup
      if visibleOnly is true and the visible of testGroup is false then next repeat
      
      put offset(someContainer, testGroup) - 1 into endStem
      put char 1 to endStem of testGroup into groupStem
      put the number of words of groupStem into wordNum
      if wordNum = 4 then
         if setShort is not false then object_SetShortStackName testGroup, stackNameStart, stackNameEnd
         put testGroup & return after myGroups
      end if
   end repeat
   delete last char of myGroups
   return myGroups
end object_GetTopGroups

command object_SetToplevelGroupArrays @topLevel_NameDictionary, @topLevel_IdDictionary, cardObject
   -- should be renamed to "object_SetToplevelCardGroupArrays"?
   if cardObject is empty then put the long ID of this card into cardObject
   put the groupNames of cardObject into topLevelGroupNames
   put the groupIDs of cardObject into topLevelGroupIds
   repeat with lineNum = 1 to the number of lines of topLevelGroupNames
      put line lineNum of topLevelGroupNames into topLevelGroupName
      put line lineNum of topLevelGroupIds into topLevelGroupId
      put the long ID of group ID topLevelGroupId of cardObject into someGroup
      
      put someGroup into topLevel_NameDictionary[topLevelGroupName]
      put topLevelGroupName into topLevel_IdDictionary[someGroup]
   end repeat
end object_SetToplevelGroupArrays


--> Object | Controls
-
/*
The members, elements, objects or rev contols of a group or card.
The list returned does not include the group group called,
only the lements inside that group.
*/

function object_ControlIDs someGroup, visibleOnly
   local idIndex
   put visibleOnly is true into visibleOnly
   repeat with controlNum = 1 to the number of controls in someGroup
      if the visible of control controlNum of someGroup is false and visibleOnly is true then next repeat
      put the short ID of control controlNum of someGroup into someID
      put someID & CR after idIndex
   end repeat
   delete last char of idIndex
   return idIndex
end object_ControlIDs

getprop object_VisibleControls [setShort]
   put the long ID of the target into targetObject
   return object_ControlsInside(targetObject, setShort, true)
end object_VisibleControls

function object_GetTopControl someGroup, pName
   repeat with controlNum = 1 to the number of controls in someGroup
      put the long ID of control controlNum of someGroup into controlObject
      if controlNum = 1 and pName is empty then
         return controlObject
      else if the short name of controlObject = pName then
         return controlObject
      end if
      
      if word 1 of controlObject = "group" then
         add the number of layers in controlObject to controlNum
      end if
   end repeat
   return empty
end object_GetTopControl

function object_GetGroupControls someGroup, nested
   put empty into myControls
   repeat with controlNum = 1 to the number of controls in someGroup
      put the long ID of control controlNum of someGroup into controlObject
      if nested is not true and word 1 of controlObject is "group" then
         add the number of layers in controlObject to controlNum
      end if
      put controlObject & CR after myControls
   end repeat
   delete last char of myControls
   return myControls
end object_GetGroupControls



--> Object | Control | Indexes
-
/*
The indexes and outlines returned here by default,
return the object called as the top level element of the index.
*/

getprop object_ControlIndex [setShort]
   put the long ID of the target into targetObject
   return group_GetObjectIndex(targetObject, setShort, true)
end object_ControlIndex

function object_ConstructMobileIndex someObjects, useID
   repeat for each line someObject in someObjects
      if exists(someObject) is false then next repeat
      if useID is true then
         put the mobile_ID of someObject into someObject
      else
         put the mobile_Name of someObject into someObject
      end if
      put someObject & return after prettyObjects
   end repeat
   delete last char of prettyObjects
   return prettyObjects
end object_ConstructMobileIndex

function object_GetMobileIndex someGroup, nested, useID
   -- was "getMobileObjects"
   if someGroup is empty then put the long ID of the target into someGroup
   put empty into myControls
   repeat with controlNum = 1 to the number of controls in someGroup
      if useID is true then
         put the mobile_ID of control controlNum of someGroup into controlObject
      else
         put the mobile_Name of control controlNum of someGroup into controlObject
      end if
      if nested is not true and word 1 of controlObject is "group" then
         add the number of layers in controlObject to controlNum
      end if
      put controlObject & return after myControls
   end repeat
   delete last char of myControls
   return myControls
end object_GetMobileIndex

function object_GetIdReferenceIndex someGroup, nested
   -- was "getIdObjects"
   if someGroup is empty then put the long ID of the target into someGroup
   put empty into myControls
   repeat with controlNum = 1 to the number of controls in someGroup
      put the long ID of control controlNum of someGroup into controlObject
      object_WithinStackReference controlObject
      if nested is not true and word 1 of controlObject is "group" then
         add the number of layers in controlObject to controlNum
      end if
      put controlObject & return after myControls
   end repeat
   delete last char of myControls
   return myControls
end object_GetIdReferenceIndex

function object_NotInGroupIndex containerObject, visibleCheck
   -- was "notInGroup_Objects"
   put empty into cardObjects
   repeat with controlNum = 1 to the number of controls in containerObject
      put the long ID of control controlNum of containerObject into cardControlObject
      if word 1 of cardControlObject is "group" then
         add the number of controls in cardControlObject to controlNum
      else if word 1 of cardControlObject is not "group" then
         -- do something to cardControlObject
         if visibleCheck is true and the visible of cardControlObject is false then
            next repeat
         end if
         put cardControlObject & return after cardObjects
      end if
   end repeat
   delete last char of cardObjects
   return cardObjects
end object_NotInGroupIndex

function object_NotInBackgroundindex containerObject
   -- was "notInBackground_Objects"
   put empty into cardObjects
   put the backgroundIDs of containerObject into bg_IDs
   repeat with controlNum = 1 to the number of controls in containerObject
      put the long ID of control controlNum of containerObject into cardControlObject
      put word 3 of cardControlObject into someID
      if someID is among the lines of bg_IDs then
         add the number of controls in cardControlObject to controlNum
      else if word 1 of cardControlObject is not "group" then
         -- do something to cardControlObject
         put cardControlObject & return after cardObjects
      end if
   end repeat
   delete last char of cardObjects
   return cardObjects
end object_NotInBackgroundindex


--> Object | Marked
-
function object_MarkedInStack someMark, stackObject, @object_Array, setShort
   -- version latest,5/2/03
   
   if exists(stackObject) is false then
      safeAnswer "Can't find" && stackObject
      return empty
   else
      put the someMark of stackObject into markValue
      put empty into objectIndex
      
      if markValue is not empty then
         if setShort is not false then object_SetShortStackName stackObject, stackNameStart, stackNameEnd
         put markValue into object_Array[stackObject]
         put line_InsertIntoIndex(stackObject, objectIndex) into objectIndex
      else
         -- put empty into object_Array
      end if
      
      -- get the objects in the backgrounds
      repeat for each line someId in the backgroundIDs of stackObject
         set the cursor to busy
         if the controlKey is "Down" then exit repeat
         put the long ID of background ID someId of stackObject into containerObject
         get object_MarkedInContainer(someMark, containerObject, object_Array, setShort)
         put line_InsertIntoIndex(it, objectIndex) into objectIndex
      end repeat
      
      -- get the card only objects of the cards
      -- plus commanddown exit
      put  the cardIDs of stackObject into limitedCardIDs
      repeat for each line cardID in limitedCardIDs
         set the cursor to busy
         if the controlKey is "Down" then exit repeat
         put the long ID of card ID cardId of stackObject into cardObject
         get object_MarkedOnCard(someMark, cardObject, object_Array, setShort)
         put line_InsertIntoIndex(it, objectIndex) into objectIndex
      end repeat
   end if
   -- delete last char of objectIndex
   
   -- local objects
   return objectIndex
   -- not accumulated results
   -- return keys(object_Array)
end object_MarkedInStack

function object_MarkedOnCard someMark, cardObject, @object_Array, setShort
   -- version latest,2/2/03
   
   put the long ID of cardObject into cardObject
   put the someMark of cardObject into markValue
   put empty into objectIndex
   
   if markValue is not empty then
      if setShort is not false then object_SetShortStackName cardObject, stackNameStart, stackNameEnd
      put markValue into object_Array[cardObject]
      put cardObject & return after objectIndex
   end if
   
   put the backgroundIDs of cardObject into bg_IDs
   repeat with controlNum = 1 to the number of controls in cardObject
      put the long ID of control controlNum of cardObject into cardControlObject
      put the someMark of cardControlObject into markValue
      put word 3 of cardControlObject into someID
      if someID is among the lines of bg_IDs then
         add the number of controls in cardControlObject to controlNum
      else if markValue is not empty then
         if setShort is not false then object_SetShortStackName cardControlObject, stackNameStart, stackNameEnd
         put markValue into object_Array[cardControlObject]
         put cardControlObject & return after objectIndex
      end if
   end repeat
   delete last char of objectIndex
   
   -- local objects
   return objectIndex
   -- not accumulated results
   -- return keys(object_Array)
end object_MarkedOnCard

function object_MarkedInContainer someMark, containerObject, @object_Array, setShort
   -- version original,2/2/03
   
   put the someMark of containerObject into markValue
   put empty into objectIndex
   
   if markValue is not empty then
      if setShort is not false then object_SetShortStackName containerObject, stackNameStart, stackNameEnd
      put markValue into object_Array[containerObject]
      put containerObject & return after objectIndex
   else
      -- put empty into object_Array
   end if
   repeat with controlNum = 1 to the number of controls in containerObject
      put the long ID of control controlNum of containerObject into testObject
      put the someMark of testObject into markValue
      if markValue is not empty then
         if setShort is not false then object_SetShortStackName testObject, stackNameStart, stackNameEnd
         put markValue into object_Array[testObject]
         put testObject & return after objectIndex
      end if
   end repeat
   delete last char of objectIndex
   
   -- local objects
   return objectIndex
   -- not accumulated results
   -- return keys(object_Array)
end object_MarkedInContainer


--> Object | Indexes
-
command object_SetIndexArray objectIndex, @shortNameArray, @shortNames
   repeat for each line someObject in objectIndex
      if exists(someObject) then
         put the short name of someObject into shortName
         put someObject into shortNameArray [shortName]
         put shortName & CR after shortNames
      end if
   end repeat
   delete char -1 of shortNames 
end object_SetIndexArray

function object_NameIndex objectIndex, @badObjects, shortOrLong
   put object_IndexArray(objectIndex) into objectArray
   put objectArray ["__BadObjectKey"]  into badObjects
   put "__" & shortOrLong & "NameKey" into someKey
   return objectArray [someKey]
end object_NameIndex

function object_BadIndex objectIndex
   repeat for each line someObject in objectIndex
      if exists(someObject) is false then
         put someObject & CR after badObjects
      end if
   end repeat
   delete char -1 of badObjects
   return badObjects
end object_BadIndex

function object_IndexArray objectIndex
   repeat for each line someObject in objectIndex
      if exists(someObject) is false then
         array_InsertLine someObject, "__BadObjectKey", objectArray
      else
         array_InsertLine someObject, "__GoodObjectKey", objectArray
         
         get the short name of someObject
         put wiki_ConstructID(it) into safeName
         put someObject into objectArray[safeName]
         array_InsertLine it, "__ShortNameKey", objectArray
         
         get the long name of someObject
         array_InsertLine it, "__LongNameKey", objectArray
         
         get the name of someObject
         put wiki_ConstructID(it) into safeName
         put someObject into objectArray[safeName]
         array_InsertLine it, "__NameKey", objectArray
      end if
   end repeat
   return objectArray
end object_IndexArray

function object_MobileIndex objectIndex, @badObjects
   repeat for each line someObject in objectIndex
      if exists(someObject) is false then
         put someObject & return after badObjects
      else
         object_SetShortStackName someObject, mainStackStart, mainStackEnd
         put someObject & return after newObjectObjects
      end if
   end repeat
   delete last char of newObjectObjects
   delete last char of badObjects
   return newObjectObjects
end object_MobileIndex

function object_IndexFromShortNames nameIndex, objectOutline_Array, pathStem
   put empty into objectIndex
   repeat for each line objectName in nameIndex
      put pathStem & objectName into someKey
      put objectOutline_Array[someKey] into someObject
      put someObject & return after objectIndex
   end repeat
   delete last char of objectIndex
   return objectIndex
end object_IndexFromShortNames

function object_NamesFromIndex objectIndex, @index_Array, pathStem
   put empty into objectNames
   repeat for each line someObject in objectIndex
      if exists(someObject) then
         put the name of someObject into someName
         put someObject into index_Array[pathStem & someName]
         put someName & return after objectNames
      end if
   end repeat
   delete last char of objectNames
   return objectNames
end object_NamesFromIndex

function object_ShortNamesFromIndex objectIndex, @index_Array, pathStem
   put empty into objectNames
   repeat for each line someObject in objectIndex
      if exists(someObject) then
         put the short name of someObject into someName
         put someObject into index_Array [pathStem & someName]
         put someName & return after objectNames
      end if
   end repeat
   delete last char of objectNames
   return objectNames
end object_ShortNamesFromIndex


--> Object | Outlines
-
/*
See also "Outline | Paths" section of stack "libOPN_Outline"
*/

getprop object_Outline
   put the long ID of the target into someGroup
   put object_GetNestedDepth(someGroup) into oDepth
   
   put the name of someGroup into objectOutline
   repeat with controlNum = 1 to the number of controls in someGroup
      put the long ID of control controlNum of someGroup into controlObject
      put object_GetNestedDepth(controlObject) into someDepth
      put someDepth - oDepth into repeatNum
      put text_RepeatString(tab, repeatNum) into someIndent
      put CR & someIndent & the name of controlObject after objectOutline
   end repeat
   return objectOutline
end object_Outline

function object_ConstructPropertiesOutline objectOutline, objectIdArray, hIdArray
   repeat with lineNum = 1 to the number of lines of objectOutline
      put empty into htmlLines
      put object_FromOutlineLineNum(lineNum, objectOutline) into someObject
      
      put line lineNum of objectOutline into objectLine
      put outline_TabLevel(objectLine) into tabLevel
      put objectLine & CR after objectPropertyOutline
      
      if exists(someObject) then
         put the mobile_Name of someObject into someObject
      end if
      
      put objectIdArray [someObject] into nodeIDs
      if nodeIDs is not empty then
         repeat for each line nodeID in nodeIDs
            put hIdArray [nodeID] into hKey
            hkey_Deconstruct hKey, handlerName, handlerType, scriptObject, handlerNum
            put html_ConstructNameLink(handlerName, hKey) & CR after htmlLines
         end repeat
         delete char -1 of htmlLines
         sort htmlLines
         get outline_IncreaseIndent(htmlLines, (tabLevel+1))
         put it & CR after objectPropertyOutline
      end if
   end repeat
   delete char -1 of objectPropertyOutline
   return objectPropertyOutline
end object_ConstructPropertiesOutline

function object_OutlineFromIndex objectIndex
   local tabbedOutline
   put numToChar(28) into pathDelim
   repeat for each line someObject in objectIndex
      put object_OutlinePath (someObject, pathDelim) into objectPath
      put outline_AddPath (objectPath, tabbedOutline, pathDelim) into tabbedOutline
   end repeat
   return tabbedOutline
end object_OutlineFromIndex

function object_OutlinePath someObject, someDelim
   object_SetHierarchy someObject, shortObjects, longObjects, objectOutline, namePath
   if someDelim is empty then put numToChar(28) into someDelim
   replace CR with someDelim in shortObjects
   return shortObjects
end object_OutlinePath

function object_IndexFromOutline objectOutline
   repeat with lineNum = 1 to the number of lines of objectOutline
      put object_FromOutlineLineNum(lineNum, objectOutline) & CR after objectIndex
   end repeat
   delete char -1 of objectIndex
   return objectIndex
end object_IndexFromOutline

function object_FromOutlineLineNum lineNum, objectOutline
   put outline_LinePath(lineNum, objectOutline, osLineNumList, CR) into objectHierarchy
   -- put outline_ExtractHierarchy(lineNum, objectOutline, osLineNumList, CR) into objectHierarchy
   put object_FromOutlineHierarchy(objectHierarchy) into someObject
   return someObject
end object_FromOutlineLineNum

function object_GetOutline someObject
   object_SetHierarchy someObject, shortObjects, longObjects, objectOutline, namePath
   return objectOutline
end object_GetOutline

function object_GetControlOutline someObject
   put the long ID of someObject into someObject
   put object_ConstructControlOutline (someObject) into someOutline
   put line 1 of someOutline into stackObject
   put the name of stackObject into line 1 of someOutline
   return someOutline
end object_GetControlOutline

function object_ConstructCardOutline cardObject, @outlineTitle_Array
   put the name of cardObject into newLine
   
   put cardObject into outlineTitle_Array[newLine]
   put cardObject & return into objectIndex
   
   put newLine into someOutline
   put the number of lines of the script of cardObject & return into scriptLines
   
   put " of" && cardObject into someObjectTail
   repeat with controlNum = 1 to the number of controls in cardObject
      put the long ID of control controlNum of cardObject into controlObject
      
      put offset(someObjectTail, controlObject) into objectTail
      put char 1 to (objectTail - 1) of controlObject into stemObject
      put text_StripQuoted(stemObject) into testStem
      replace " of " with return in testStem
      
      put the number of lines of testStem - 0 into indentLevel
      put empty into indentBit
      repeat indentLevel
         put tab after indentBit
      end repeat
      put the number of lines of the script of controlObject into scriptLineNum
      put indentBit & the name of controlObject into newLine
      
      put scriptLineNum & return after scriptLines
      put return & newLine after someOutline
      
      put controlObject into outlineTitle_Array[newLine]
      put controlObject & return after objectIndex
   end repeat
   delete last char of scriptLines
   delete last char of objectIndex
   
   put scriptLines into outlineTitle_Array["Script Lines"]
   put objectIndex into outlineTitle_Array["Object Index"]
   
   -- answer outlineTitle_Array["Script Lines"]
   return someOutline
end object_ConstructCardOutline

command object_OutlineFromNameArray objectArray, @objectOutline, @objectOutline_Array, pathDelim
   if pathDelim is empty then put "/" into pathDelim
   put empty into objectOutline
   repeat for each line someKey in keys(objectArray)
      put objectArray[someKey] into objectIndex
      put somekey & return after objectOutline
      
      put someKey & pathDelim into pathStem
      put object_ShortNamesFromIndex(objectIndex, objectOutline_Array, pathStem) into outlineSection
      if outlineSection is not empty then put outline_IncreaseIndent(outlineSection, 1) & return after objectOutline
   end repeat
   delete last char of objectOutline
   return keys(objectOutline_Array)
end object_OutlineFromNameArray

function object_ConstructFromPath somePath, someDelimiter
   -- was "path_ConvertToObject"
   if someDelimiter is empty then put "/" into someDelimiter
   set the itemDelimiter to someDelimiter
   if somePath is empty then return empty
   
   put "control " into someObject
   repeat with itemNum = (the number of items of somePath) down to 1
      put item itemNum of somePath into objectName
      put kwote(objectName) && "of group " after someObject
   end repeat
   delete word -2 to -1 of someObject
   return someObject
end object_ConstructFromPath

function object_FromPath objectPath, someDelimiter
   if someDelimiter is empty then put "/" into someDelimiter
   set the itemDelimiter to someDelimiter
   if objectPath is empty then return empty
   
   repeat with itemNum = the number of items of objectPath down to 1
      put item itemNum of objectPath && "of"  & space after someObject
   end repeat
   return word 1 to -2 of someObject
end object_FromPath

function object_FromOutlineHierarchy objectHierarchy
   -- was "outLineToObject"
   put objectHierarchy into indexObjectLines
   replace tab with empty in indexObjectLines
   
   put the number of lines of indexObjectLines into lastLine
   put last line of indexObjectLines into someObject
   repeat with lineNum = (lastLine - 1) down to 1
      put line lineNum of indexObjectLines into objectBit
      replace tab with empty in objectBit
      put space & "of" && objectBit after someObject
   end repeat
   return someObject
end object_FromOutlineHierarchy

function object_ConstructControlOutline someControl
   -- was "formatControlAsOutline" then "object_OutlineFromIndex"
   put text_TempReplaceQuoted (someControl, offsetArray) into tempUnQuoted
   replace " of " with CR in tempUnQuoted
   put empty into someOutline
   put empty into someIndent
   repeat with lineNum = the number of lines of tempUnQuoted down to 1
      put someIndent & line lineNum of tempUnQuoted & return after someOutline
      put tab after someIndent
   end repeat
   delete last char of someOutline
   return text_ReReplaceQuoted(someOutline, offsetArray)
end object_ConstructControlOutline

getprop object_NestedDepth
   put the long ID of the target into idObject
   return object_GetNestedDepth(idObject)
end object_NestedDepth

function object_GetNestedDepth idObject
   -- needs to be a long id
   -- put the long id of idObject into idObject
   repeat
      if word 4 of line -1 of idObject is "of" then
         put word 1 to 3 of idObject & CR after objectIndex
         delete word 1 to 4 of idObject
      else
         -- its the stack bit
         put idObject into longStack
         exit repeat
      end if
   end repeat
   return the number of lines of objectIndex
end object_GetNestedDepth


--> Object | Paths
-
getprop object_OutlinePath [someDelim]
   put the mobile_Name of the target into someObject
   return object_OutlinePath(someObject, someDelim)
end object_OutlinePath

getprop object_NameHierarchy
   put the mobile_Name of the target into someObject
   object_SetHierarchy someObject, shortObjects, longObjects, objectOutline, namePath
   return shortObjects
end object_NameHierarchy

function object_PathToControl somePath, someDelimiter
   if someDelimiter is empty then put "/" into someDelimiter
   set the itemDelimiter to someDelimiter
   if somePath is empty then return empty
   
   repeat with itemNum = (the number of items of somePath) down to 1
      put item itemNum of somePath into shortObject
      put space & shortObject && "of" after someObject
   end repeat
   return word 1 to -2 of someObject
end object_PathToControl

getprop object_NamePath [someDelim]
   if someDelim is empty then put "/" into someDelim
   put the mobile_Name of the target into someObject
   put text_ExtractQuoted(someObject) into objectNamePath
   replace CR with someDelim in objectNamePath
   
   set the itemDelimiter to someDelim
   put empty into reversedNamePath
   repeat with itemNum = the number of items of objectNamePath down to 1
      put item itemNum of objectNamePath & someDelim after reversedNamePath
   end repeat
   delete last char of reversedNamePath
   return reversedNamePath
end object_NamePath


--> Object | Arrays
-
function object_NameArray someGroup, nested
   if someGroup is empty then put the long ID of the target into someGroup
   put empty into name_Array
   repeat with controlNum = 1 to the number of controls in someGroup
      put the long ID of control controlNum of someGroup into controlObject
      object_WithinStackReference controlObject
      if nested is not true and word 1 of controlObject is "group" then
         add the number of layers in controlObject to controlNum
      end if
      put the short name of controlObject into objectName
      put controlObject into name_Array[objectName]
   end repeat
   return name_Array
end object_NameArray

function object_GetGroupNameArray someGroup, nested
   if someGroup is empty then put the long ID of the target into someGroup
   put empty into name_Array
   repeat with controlNum = 1 to the number of controls in someGroup
      put the long ID of control controlNum of someGroup into controlObject
      object_WithinStackReference controlObject
      if nested is not true and word 1 of controlObject is "group" then
         add the number of layers in controlObject to controlNum
      end if
      put the short name of controlObject into objectName
      put controlObject into name_Array[objectName]
   end repeat
   return name_Array
end object_GetGroupNameArray

function object_FromShortName someName, objectArray
   put wiki_ConstructID(someName) into safeName
   put objectArray[safeName] into someObject
   return someObject
end object_FromShortName

function object_NamePathToControl namePath, topObject, someDelimiter
   if someDelimiter is empty then put "/" into someDelimiter
   set the itemDelimiter to someDelimiter
   repeat with itemNum = 2 to the number of items of namePath
      put item itemNum of namePath into nestedName
      put the long ID of control nestedName of topObject into topObject
   end repeat   
   return topObject
end object_NamePathToControl


--> Object | Hierarchies
-
/*
Could be sped up and simplified with suggestion from Tereza Snyder <tereza@califex.com>

get the long id of the selectedobject; replace " of " with "," in it; put it

which results in:

field id 226375,group id 226358,group id 226332,card id 224190,stack "..."

then a simple "for each item" loop to traverse it.
*/

getprop view_Objects
   put the long ID of the target into targetObject
   
   put the view_FoundChildren of targetObject into viewObjects
   if the object_IsView of targetObject is true then line_Insert targetObject, viewObjects, 1
   return viewObjects
end view_Objects

getprop object_IsLibraryView
   put the long ID of the target into targetObject
   
   put the view_Name of the target into viewName
   if viewName is empty then return false
   put view_GetTemplateObject (viewName) into libraryObject
   return targetObject = libraryObject
end object_IsLibraryView

getprop object_WithinLibraryStack
   put the long ID of the target into targetObject
   
   put the view_Name of targetObject into viewName
   put the stack_Object of targetObject into stackObject
   put the filename of stackObject into someFile
   put view_FileToPath(someFile, true) into testViewName
   return testViewName = viewName
end object_WithinLibraryStack

getprop object_Hierarchy [pWhichBehaviors]
   -- see also "hkey_SearchHierarchy" 
   put the long id of the target into someObject
   if pWhichBehaviors is empty then put "no library deps" into pWhichBehaviors
   
   put revRuggedId (someObject) into objectHierarchy
   put the behavior of someObject into objectBehavior
   object_MaybeAddBehavior objectHierarchy, objectBehavior, pWhichBehaviors
   
   put someObject into objectOwner
   put empty into skipThisBackgroundID
   repeat
      switch word 1 of objectOwner
         case "stack"
            -- previously added a stack, check if it was a substack
            put objectOwner into stackObject
            put the owner of stackObject into mainStackObject
            if exists(mainStackObject) then
               put mainStackObject & CR before objectHierarchy
               put the behavior of mainStackObject into objectBehavior
               object_MaybeAddBehavior objectHierarchy, objectBehavior, pWhichBehaviors
            end if
            return objectHierarchy
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
               put revRuggedId (backgroundObject) & CR before objectHierarchy
               put the behavior of backgroundObject into objectBehavior
               object_MaybeAddBehavior objectHierarchy, objectBehavior, pWhichBehaviors
            end repeat
            
            delete word 1 to 4 of objectOwner
            
            -- above a card must be a stack
            put name of objectOwner into stackObject
            put stackObject & CR before objectHierarchy
            put the behavior of stackObject into objectBehavior
            object_MaybeAddBehavior objectHierarchy, objectBehavior, pWhichBehaviors
            break
         case "group"
            -- previously added a group, check to see if was a bg
            if the backgroundbehavior of objectOwner is true then
               -- will need to skip it's own "card" background
               put the short ID of objectOwner into skipThisBackgroundID
            end if
            delete word 1 to 4 of objectOwner
            if exists (objectOwner) is false then return objectHierarchy
            put revRuggedId (objectOwner) & CR before objectHierarchy
            put the behavior of objectOwner into objectBehavior
            object_MaybeAddBehavior objectHierarchy, objectBehavior, pWhichBehaviors
            break
         default
            -- previously added a normal control
            delete word 1 to 4 of objectOwner
            if exists (objectOwner) is false then return objectHierarchy
            put revRuggedId (objectOwner) & CR before objectHierarchy
            put the behavior of objectOwner into objectBehavior
            object_MaybeAddBehavior objectHierarchy, objectBehavior, pWhichBehaviors
      end switch
   end repeat
   return "error" -- should never get here!
end object_Hierarchy

command object_AddBehaviors @objectIndex
   repeat for each line someObject in objectIndex
      if exists (someObject) is false then next repeat 
      put the behavior of someObject into objectBehavior
      if exists (objectBehavior) then
         put revRuggedId (objectBehavior) & CR after newObjectIndex
      end if
      put someObject & CR after newObjectIndex
   end repeat
   delete char -1 of newObjectIndex
   put newObjectIndex into objectIndex
end object_AddBehaviors

command object_MaybeAddBehavior @objectHierarchy, objectBehavior, pWhichBehaviors
   if exists (objectBehavior) then
      switch
         case pWhichBehaviors is "no deps"
            -- don't add
            break
         case pWhichBehaviors is "no library deps" and the uRIP ["type"] of objectBehavior is not "behavior/library"
            put revRuggedId (objectBehavior) & CR before objectHierarchy
            break
         default -- case "all"
            put revRuggedId (objectBehavior) & CR before objectHierarchy
            break
      end switch
   end if
end object_MaybeAddBehavior


--> Object | Hierarchies | Behavior
-
getprop object_ScriptHierarchy [nameFormat]
   put the long ID of the target into targetObject
   object_ConstructBehaviorHierarchy targetObject, behaviorObjectMenu, longObjects, shortObjects, shortNames
   switch nameFormat
      case "short"
         return shortObjects
      case "names"
         return shortNames
      default -- case "long"
         return longObjects
   end switch
end object_ScriptHierarchy

getprop object_ScriptHierarchyMenu
   put the long ID of the target into targetObject
   object_ConstructBehaviorHierarchy targetObject, behaviorObjectMenu, longObjects, shortObjects, shortNames, dictionaryArray
   return behaviorObjectMenu
end object_ScriptHierarchyMenu

getprop object_BehaviorHierarchyArray
   local hierarchyArray, dictionaryArray, longObjects, shortObjects, shortNames, behaviorObjectMenu
   put the long ID of the target into targetObject
   
   object_ConstructBehaviorHierarchy targetObject, behaviorObjectMenu, longObjects, shortObjects, shortNames, dictionaryArray
   
   put behaviorObjectMenu into hierarchyArray ["menu"]
   put longObjects into hierarchyArray ["longObjects"]
   put shortObjects into hierarchyArray ["shortObjects"]
   put shortNames into hierarchyArray ["shortNames"]
   put dictionaryArray into hierarchyArray ["dictionary"]
   
   return hierarchyArray
end object_BehaviorHierarchyArray

command object_ConstructBehaviorHierarchy targetObject, @behaviorObjectMenu, @longObjects, @shortObjects, @shortNames, @dictionaryArray
   put the long name of targetObject into someObject
   
   set the wholeMatches to true
   put 0 into skipNum
   repeat
      put wordOffset("of", someObject, skipNum) into wordNum
      if wordNum = 0 then exit repeat
      
      put word (1 + skipNum) to -1 of someObject into longObject
      addObjectToBehaviorHeirarchy longObject, dictionaryArray, longObjects, shortObjects, shortNames, behaviorObjectMenu
      
      add wordNum to skipNum
   end repeat
   
   -- do the last one?
   put word (1 + skipNum) to -1 of someObject into longObject
   addObjectToBehaviorHeirarchy longObject, dictionaryArray, longObjects, shortObjects, shortNames, behaviorObjectMenu
   
   put word 1 to -1 of longObjects into longObjects
   put word 1 to -1 of shortObjects into shortObjects
   put word 1 to -1 of shortNames into shortNames
   delete char 1 of behaviorObjectMenu
end object_ConstructBehaviorHierarchy

private command addObjectToBehaviorHeirarchy longObject, @dictionaryArray, @longObjects, @shortObjects, @shortNames, @behaviorObjectMenu
   put the name of longObject into shortObject
   put token 2 of shortObject into shortName
   
   -- add object to index
   put CR & longObject before longObjects
   put CR & shortObject before shortObjects
   put CR & shortName before shortNames
   put CR & shortObject before behaviorObjectMenu
   
   put longObject into dictionaryArray [shortObject]
   put longObject into dictionaryArray [shortName]
   
   -- add behavior to index
   put the behavior of longObject into behaviorObject
   if exists (behaviorObject) then
      put the long ID of behaviorObject into behaviorObject
      put the name of behaviorObject into shortObject
      put token 2 of shortObject into shortName
      
      put CR & behaviorObject before longObjects
      put CR & shortObject before shortObjects
      put CR & shortName before shortNames
      put CR & tab & "behavior" after line 2 of behaviorObjectMenu
      put CR & tab & "script" after line 2 of behaviorObjectMenu
      
      put behaviorObject into dictionaryArray [shortObject]
      put behaviorObject into dictionaryArray [shortName]
   end if
end addObjectToBehaviorHeirarchy


--> Object | Hierarchies | Stack
-
getprop object_StackHierarchy
   put the long id of the target into someObject
   return object_GetHierarchy (someObject)
end object_StackHierarchy

function object_GetHierarchy someObject
   put the long id of someObject into someObject
   object_SetHierarchy someObject, shortObjects, longObjects, objectOutline, namePath
   return longObjects
end object_GetHierarchy

function object_GetShortHierarchy someObject
   put the long name of someObject into someObject
   object_SetHierarchy someObject, shortObjects, longObjects, objectOutline, namePath
   return shortObjects
end object_GetShortHierarchy

command object_SetHierarchy someObject, @shortObjects, @longObjects, @objectOutline, @namePath, pathDelim
   if pathDelim is empty then put "/" into pathDelim
   put empty into shortObjects
   put empty into longObjects
   put empty into objectOutline
   put empty into namePath
   
   set the wholeMatches to true
   put 0 into skipNum
   put empty into tabBit
   repeat
      put wordOffset("of", someObject, skipNum) into wordNum
      if wordNum = 0 then exit repeat
      
      put word (1 + skipNum) to (wordNum - 1 + skipNum) of someObject into shortObject
      put CR & shortObject before shortObjects
      put word (1 + skipNum) to -1 of someObject into longObject
      put CR & longObject before longObjects
      
      put CR & tabBit & shortObject before objectOutline
      put tab after tabBit
      put word 2 of shortObject into someName
      replace quote with empty in someName
      put pathDelim & someName before namePath
      
      add wordNum to skipNum
   end repeat
   
   put word (1 + skipNum) to -1 of someObject into shortObject
   put CR & shortObject before shortObjects
   put word (1 + skipNum) to -1 of someObject into longObject
   put CR & longObject before longObjects
   
   put CR & tabBit & shortObject before objectOutline
   put tab after tabBit
   
   put word 2 of shortObject into someName
   replace quote with empty in someName
   put pathDelim & someName before namePath
   
   delete char 1 of objectOutline
   delete char 1 of namePath
   delete char 1 of shortObjects
   delete char 1 of longObjects
end object_SetHierarchy

function object_GetFullHierarchy someObject
   -- was getScriptObjectHierachy
   put object_GetLibrariesInUse() into scriptObjectHierachy
   put the object_StackHierarchy of someObject into longObjectNames
   line_Insert longObjectNames, scriptObjectHierachy
   return scriptObjectHierachy
end object_GetFullHierarchy

function object_GetLibrariesInUse
   put the frontScripts into activeLibraries
   get the backScripts
   line_Insert it, activeLibraries
   put the stacksInUse into usedStacks
   repeat for each line stackName in usedStacks
      put return & the name of stack stackName after activeLibraries
   end repeat
   put "*stack" && kwote("/Applications/Revolution*") into revFilter
   filter activeLibraries without revFilter
   return activeLibraries
end object_GetLibrariesInUse
