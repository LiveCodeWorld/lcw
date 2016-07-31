script "lib_ObjectLayer"
--> MetaData
-
license: GPLv3
name: lib_ObjectLayer
type: library
version: 0.1


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
