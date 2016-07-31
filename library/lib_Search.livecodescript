script "lib_Search"
--> MetaData
-
license: GPLv3
name: lib_Search
type: library
version: 0.4

/*
This library is for searching things.

An objectArray is short for an objectPropertyArray, 
which is an array keyed by an objects name, containing object properties as an (array) value.

That is objectArray's contain propArray's - or object property arrays as returned by "the properties of the target"
*/


--> Search | Props
-
getprop menu_ReIndex
   /*
   Message execution error:
   Error description: Array: bad index expression
   */
   put the stack_Object of the target into stackObject
   put search_StackForResults (stackObject, "script_GetSetHack") into mTitleToControllerArray
   return mTitleToControllerArray
end menu_ReIndex

getprop script_GetSetHack
   -- used above
   try
      set the script_IsIndexed of the target to true
      put the result into mTitleTableArray
   catch e
      answer "?"
   end try
   return mTitleTableArray
end script_GetSetHack

getprop stack_MenuArray
   --- put the someProperty of pControllerObject into objectArray [targetObject]
   put the stack_Object of the target into stackObject
   put empty into controllerObject
   put search_StackForResults (stackObject, "menu_Title", controllerObject) into mTitleToControllerArray
   return mTitleToControllerArray
end stack_MenuArray

getprop stack_Search [someProperty]
   -- indexes objects with the same property
   put item 2 to -1 of someProperty into controllerObject
   if controllerObject = "me" then
      put script_CallingObject() into controllerObject
   end if
   put item 1 of someProperty into someProperty
   put the stack_Object of the target into stackObject
   put search_StackForResults (stackObject, someProperty, controllerObject) into objectArray
   return objectArray
end stack_Search

getprop search_Stack [colonValue]
    set the itemdelimiter to ":"
    put item 1 of colonValue into someProperty
    put item 2 of colonValue into someValue
    put item 3 of colonValue into controllerObject
    put the stack_Object of the target into stackObject
    
    put search_StackForValue (stackObject, someProperty, someValue, controllerObject) into searchResult
    return searchResult
end search_Stack

getprop search_Container [someProperty]
   local objectArray, propertyArray
   put the long id of the target into containerObject
   if word 1 of containerObject is not among the items of "card,group,background" then return empty
   
   put item 3 to -1 of someProperty into controllerObject
   put item 2 of someProperty into objectKeyProperty
   put item 1 of someProperty into someProperty
   
   objectArray_SearchNested containerObject, someProperty, propertyArray, objectKeyProperty, controllerObject, true
   put the result into objectArray
   put propertyArray into objectArray ["@prop"]
   return objectArray
end search_Container

getprop search_FlatContainer [someProperty]
   local objectArray
   put the long id of the target into containerObject
   if word 1 of containerObject is not among the items of "card,group,background" then return empty
   
   put item 3 to -1 of someProperty into controllerObject
   put item 2 of someProperty into pObjectKeyProperty
   if pObjectKeyProperty is empty then put "rugged_ID" into pObjectKeyProperty
   put item 1 of someProperty into someProperty
   
   objectArray_SearchGroupForValue objectArray, propertyArray, containerObject, someProperty, pObjectKeyProperty, controllerObject, pSplitArrays
   return propertyArray
end search_FlatContainer


--> Search | Utils
-
/*
Handy utilities built on top of the search library/
*/

getprop stack_ObjectsWithExternalBehavior
   put the stack_BehaviorArray of the target into behaviorArray
   put behaviorArray ["outside mainstack"] into objectArray
   return keys(objectArray)
end stack_ObjectsWithExternalBehavior

getprop stack_ObjectsWithBehavior
   put the stack_BehaviorArray of the target into behaviorArray
   put behaviorArray ["behavior object"] into objectArray
   
   repeat for each key behaviorObject in objectArray
      put objectArray [behaviorObject] & CR after objectsWithBehavior 
   end repeat
   delete char -1 of objectsWithBehavior
   return objectsWithBehavior
end stack_ObjectsWithBehavior

getprop stack_Behaviors 
   put the stack_BehaviorArray of the target into behaviorArray
   put behaviorArray ["behavior object"] into objectArray
   put keys (objectArray) into stackBehaviors
   return stackBehaviors
end stack_Behaviors

getprop stack_BehaviorArray
   -- return a list of the views in a stack and all it's substacks
   put the stack_Object of the target into stackObject
   put the mainstack of stackObject into mStackName
   put the long id of stack mStackName into longMainStack
   -- put the name of stack mStackName into mStack
   
   put search_StackForResults (longMainStack, "behavior") into objectArray
   put objectArray into behaviorArray ["behavior object"]
   
   repeat for each key behaviorObject in objectArray
      put the long id of behaviorObject into longBehavior
      
      if longBehavior ends with longMainStack then
         put objectArray [behaviorObject] & CR after objectsWithInternalBehavior
         repeat for each line someObject in objectsWithInternalBehavior
            put behaviorObject into behaviorArray ["within mainstack"][someObject]
         end repeat
      else
         put objectArray [behaviorObject] into objectsWithExternalBehaviors
         repeat for each line someObject in objectsWithExternalBehaviors
            put behaviorObject into behaviorArray ["outside mainstack"][someObject]
         end repeat
      end if
   end repeat
   return behaviorArray
end stack_BehaviorArray

getprop stack_ViewObjects
   -- stack_Views in libOPN_ObjectText
   put the stack_ViewArray of the target into objectArray
   repeat for each key viewName in objectArray
      put objectArray [viewName] & CR after viewObjects 
   end repeat
   delete char -1 of viewObjects
   return viewObjects
end stack_ViewObjects

getprop stack_ViewNames
   -- stack_Views in libOPN_ObjectText
   put the stack_ViewArray of the target into objectArray
   return keys (objectArray)
end stack_ViewNames

getprop stack_ViewArray
   -- return a list of the views in a stack and all it's substacks
   put the stack_Object of the target into stackObject
   put the mainstack of stackObject into mStackName
   put the name of stack mStackName into mStack
   
   put search_StackForResults (mStack, "view_Name") into objectArray
   return objectArray
end stack_ViewArray

getprop object_Name [pObjectKeyProperty]
   switch pObjectKeyProperty
      case empty
         return the rugged_ID of the target
      case "rugged"
         return the rugged_ID of the target
      case "long"
         return the long id of the target
      case "short"
         return the short id of the target
      case empty
         return the abbreviated id of the target
      default
         return the pObjectKeyProperty of the target
   end switch
end object_Name

getprop object_Views
   put the long id of the target into someGroup
   
   put object_SearchGroup (someGroup, "object_IsView") into objectArray
   put empty into viewObjects
   repeat for each key someObject in objectArray
      if objectArray [someObject] is true then
         put someObject & CR after viewObjects
      end if
   end repeat
   delete last char of viewObjects
   return viewObjects
end object_Views

getprop object_SearchArray [someProperty]
   put true into useTargetProperty
   
   put the long id of the target into targetObject
   switch word 1 of targetObject
      case "stack"
         put the name of targetObject into stackObject
         put search_StackForResults (stackObject, someProperty) into objectArray
         return objectArray
      default -- case "card"
         put object_SearchGroup (targetObject, someProperty) into searchArray
         return searchArray
   end switch
end object_SearchArray


--> Search
-
command stackArray_SearchNestedBackground groupID, stackObject, @propertyArray, containerKey
   local objectArray  
   
   put the object_PropertyArray of group id groupID of stackObject into objectResult
   put objectResult into propertyArray [containerKey]
   put empty into objectArray [containerKey]
   
   repeat with controlNum = 1 to the number of controls in group id groupID of stackObject -- look at contents
      put the short id of control controlNum of group id groupID of stackObject into subID
      put the abbreviated id of control controlNum of group id groupID of stackObject into subKey
      
      if word 1 of subKey = "group" then
         -- recurse
         stackArray_SearchNestedBackground subID, stackObject, propertyArray, subKey
         put the result into subArray -- will be a nested array
         put subArray [subKey] into objectArray [containerKey][subKey]
         add the number of layers in group id subID of stackObject to controlNum
      else
         -- add plain
         put the object_PropertyArray of control id subID of stackObject into subResult
         put subResult into propertyArray [subKey]
         put empty into objectArray [containerKey][subKey]
      end if
   end repeat
   return objectArray
end stackArray_SearchNestedBackground

command stackArray_SearchNested controlID, cardID, stackObject, @propertyArray, containerKey
   -- trying to be careful with object references for shared backgrounds
   -- probably no different in results from "stackArray_SearchNestedBackground"
   local objectArray  
   
   put the object_PropertyArray of control id controlID of card id cardID of stackObject into objectResult
   put objectResult into propertyArray [containerKey]
   put empty into objectArray [containerKey]
   
   /*
   -- RunRev object reference bug !!!
   try 
      put the long id of control id controlID of stackObject into containerObject
   catch e
      breakPoint
      get the long name of control id controlID of card id cardID of stackObject
   end try
   */
   
   put the long id of control id controlID of card id cardID of stackObject into containerObject
   put the number of controls in containerObject into maxNum
   repeat with controlNum = 1 to maxNum -- look at contents
      put the short id of control controlNum of containerObject into subID
      put the abbreviated id of control controlNum of containerObject into subKey
      
      if word 1 of subKey = "group" then
         -- recurse
         stackArray_SearchNested subID, cardID, stackObject, propertyArray, subKey
         put the result into subArray -- will be a nested array
         put subArray [subKey] into objectArray [containerKey][subKey]
         add the number of layers in control id subID of stackObject to controlNum
      else
         -- add plain
         put the object_PropertyArray of control id subID of card id cardID of stackObject into subResult
         put subResult into propertyArray [subKey]
         put empty into objectArray [containerKey][subKey]
      end if
   end repeat
   return objectArray
end stackArray_SearchNested
     

--> Search
-
function search_StackNames stackNames, someProperty, pControllerObject
   local objectArray
   repeat for each line stackName in stackNames
      if exists(stack stackName) is false then next repeat
      
      put the name of stack stackName into stackObject
      search_StackAndSubstacks objectArray, stackObject, someProperty, pControllerObject
   end repeat
   return objectArray
end search_StackNames


--> Object | Search | Stack | For Results
-
command search_Stack stackName, someProperty, @objectArray, pControllerObject
   put the name of stack stackName into stackObject
   opn_Notify ("Searching" && stackObject)
   
   search_SubStackForResult objectArray, stackObject, someProperty, pControllerObject
   put the substacks of stackObject into subStackNames
   repeat for each line subStackName in subStackNames
      set the cursor to busy
      put the long id of stack subStackName of stackObject into stackObject
      search_SubStackForResult objectArray, stackObject, someProperty, pControllerObject
   end repeat
end search_Stack

function search_StackForResults stackObject, someProperty, pControllerObject
   local objectArray
   search_StackAndSubstacks objectArray, stackObject, someProperty, pControllerObject
   return objectArray
end search_StackForResults

command search_StackAndSubstacks @objectArray, stackObject, someProperty, pControllerObject
   put the mainstack of stackObject into mainStackName
   put the name of stack mainStackName into mainStackObject
   
   search_SubStackForResult objectArray, mainStackObject, someProperty, pControllerObject
   
   put the substacks of stack mainStackName into subStackNames
   repeat for each line subStackName in subStackNames
      set the cursor to busy
      -- put the long id of stack subStackName of stackObject into subStackObject -- LiveCode bug - stackObject not working with substack reference
      put the long id of stack subStackName of stack mainStackName into subStackObject
      search_SubStackForResult objectArray, subStackObject, someProperty, pControllerObject
   end repeat
end search_StackAndSubstacks

command search_SubStackForResult @objectArray, stackObject, someProperty, pControllerObject
   search_ForValue objectArray, stackObject, someProperty, pControllerObject
   -- search_ForResults objectArray, stackObject, someProperty, pControllerObject
   
   -- get the objects in the backgrounds
   put the backgroundids of stackObject into someBgIds
   repeat for each line someId in someBgIds
      set the cursor to busy
      put the long id of background id someId of stackObject into someBackground
      search_ForValue objectArray, someBackground, someProperty, pControllerObject
      -- search_ForResults objectArray, someBackground, someProperty, pControllerObject
      
      repeat with controlNum = 1 to the number of controls in someBackground
         put the long id of control controlNum of someBackground into someObject
         search_ForValue objectArray, someObject, someProperty, pControllerObject
         -- search_ForResults objectArray, someObject, someProperty, pControllerObject
      end repeat
   end repeat
   
   -- get the card only objects of the cards
   put the cardids of stackObject into someCardIDs
   repeat for each line cardID in someCardIDs
      set the cursor to busy
      put the long id of card id cardId of stackObject into cardObject
      search_ForValue objectArray, cardObject, someProperty, pControllerObject
      -- search_ForResults objectArray, cardObject, someProperty, pControllerObject
      
      repeat with controlNum = 1 to the number of controls in cardObject
         set the cursor to busy
         put the long id of control controlNum of cardObject into someObject
         
         put word 3 of someObject into someID
         if someID is among the lines of someBgIds then
            add the number of controls in someObject to controlNum
         else
            search_ForValue objectArray, someObject, someProperty, pControllerObject
            -- search_ForResults objectArray, someObject, someProperty, pControllerObject
         end if
      end repeat
   end repeat
   return objectArray
end search_SubStackForResult

private command search_ForValue @objectArray, targetObject, someProperty, pControllerObject
   if pControllerObject is empty then
      put the someProperty of targetObject into someValue
   else
      -- a getprop controller somewhere (most likely where search is called from) 
      put someProperty & "[" & targetObject & "]" into someProp
      put the someProp of pControllerObject into someValue
   end if
   if someValue is empty then return empty
   
   put objectArray [someValue] into foundObjects
   put the rugged_ID of targetObject into targetObject
   line_Add targetObject, foundObjects
   put foundObjects into objectArray [someValue]
   return someValue
end search_ForValue

private command search_ForResults @objectArray, targetObject, someProperty, pControllerObject
    if pControllerObject is empty then
        put the someProperty of targetObject into objectArray [targetObject]
    else
        -- a getprop controller somewhere (most likely where search is called from) 
        put someProperty & "[" & targetObject & "]" into someProperty
        put the someProperty of pControllerObject into objectArray [targetObject]
    end if
end search_ForResults


--> Object | Search | Stack | For Value
-
function search_StackForValue stackObject, someProperty, someValue, controllerObject
    put object_SearchSubStackForValue(stackObject, someProperty, someValue, controllerObject) into objectArray
    
    put the substacks of stackObject into subStackNames
    repeat for each line subStackName in subStackNames
        put the long id of stack subStackName of stackObject into stackObject
        put search_SubStackForValue (stackObject, someProperty, someValue, controllerObject) & CR after foundObjects
    end repeat
    delete char -1 of foundObjects
    return foundObjects
end search_StackForValue
   
function search_SubStackForValue stackObject, someProperty, someValue, controllerObject
    local objectArray
    
    if the someProperty of stackObject = someValue then
        put stackObject & CR after foundObjects
    end if
     
    -- get the objects in the backgrounds
    put the backgroundids of stackObject into someBgIds
    repeat for each line someId in someBgIds
        put the long id of background id someId of stackObject into someBackground
         
        if the someProperty of someBackground = someValue then
            put someBackground & CR after foundObjects
        end if
         
        repeat with controlNum = 1 to the number of controls in someBackground
            put the long id of control controlNum of someBackground into someObject
            if the someProperty of someObject = someValue then
                put someObject & CR after foundObjects
            end if
        end repeat
    end repeat
    
    -- get the card only objects of the cards
    put the cardids of stackObject into someCardIDs
    repeat for each line cardID in someCardIDs
        put the long id of card id cardId of stackObject into cardObject
         
        if the someProperty of cardObject = someValue then
            put cardObject & CR after foundObjects
        end if
         
        repeat with controlNum = 1 to the number of controls in cardObject
            put the long id of control controlNum of cardObject into someObject
            
            put word 3 of someObject into someID
            if someID is among the lines of someBgIds then
                add the number of controls in someObject to controlNum
            else
                if the someProperty of someObject = someValue then
                    put someObject & CR after foundObjects
                end if
            end if
        end repeat
    end repeat
    delete char -1 of foundObjects
    return foundObjects
end search_SubStackForValue

private command search_TestObject @foundObjects, targetObject, someProperty, someValue, controllerObject
    if someValue is empty then put true into someValue
    if controllerObject is empty then
        if the someProperty of targetObject = someValue then
            put targetObject & CR after foundObjects
        end if
    else
        -- a getprop controller somewhere (most likely where search is called from) 
        put someProperty & "[" & targetObject & "]" into someProperty
        if the someProperty of controllerObject = someValue then
            put targetObject & CR after foundObjects
        end if
    end if
end search_TestObject


--> OPN | Search
-
function opn_SearchLibraries
   local objectIndex
   put "All" into pSetName
   put library_ListUsedStacks (pSetName) after objectIndex
   return objectIndex
end opn_SearchLibraries

function object_SearchGroupForProperty someGroup, someProperty, someValue
   if someGroup is empty then put the long id of the target into someGroup
   local myControls
   
   -- search the group / object first
   put the someProperty of someGroup into testValue
   if testValue is someValue then
      put someGroup & return after myControls
   end if
   
   repeat with controlNum = 1 to the number of controls in someGroup
      put the long id of control controlNum of someGroup into controlObject
      put the someProperty of controlObject into testValue
      if testValue is someValue then
         put controlObject & return after myControls
      end if
   end repeat
   delete last char of myControls
   return myControls
end object_SearchGroupForProperty


-->Search | Object | Index
-
function opn_ObjectSearch booleanProperty, pIsTrue, pFormat
   put library_ListBackObjects ("all") into objectIndex
   put object_SearchForProperty (objectIndex, booleanProperty, pIsTrue) into foundObjects
   put object_ConstructMobileIndex(foundObjects, false) into foundBackObjects
   
   put library_ListFrontObjects ("all") into objectIndex
   put object_SearchForProperty (objectIndex, booleanProperty, pIsTrue) into foundObjects
   put object_ConstructMobileIndex(foundObjects, false) into foundFrontObjects
   
   put library_ListUsedStacks ("all") into objectIndex
   put object_SearchForProperty (objectIndex, booleanProperty, pIsTrue) into foundUsedObjects
   
   put view_TemplateObjects() into objectIndex
   put object_SearchForProperty (objectIndex, booleanProperty, pIsTrue) into foundObjects
   put object_ConstructMobileIndex(foundObjects, false) into foundViewObjects
   
   put behavior_Objects() into objectIndex
   put object_SearchForProperty (objectIndex, booleanProperty, pIsTrue) into foundObjects
   put object_ConstructMobileIndex(foundObjects, false) into foundBehaviorObjects
   
   put menu_GlobalControllers() into objectIndex
   put object_SearchForProperty (objectIndex, booleanProperty, pIsTrue) into foundMenuObjects
   
   switch pFormat
      case "Index"
         if foundBackObjects is not empty then put foundBackObjects & CR after foundOutline
         if foundFrontObjects is not empty then put foundFrontObjects & CR after foundOutline
         if foundUsedObjects is not empty then put foundUsedObjects & CR after foundOutline
         if foundViewObjects is not empty then put foundViewObjects & CR after foundOutline
         if foundBehaviorObjects is not empty then put foundBehaviorObjects & CR after foundOutline
         if foundMenuObjects is not empty then put foundMenuObjects & CR after foundOutline
         break
      default -- "outline"
         if foundBackObjects is not empty then put "Back Libraries" & CR & outline_IncreaseIndent(foundBackObjects) & CR after foundOutline
         if foundFrontObjects is not empty then put "Front Libraries" & CR & outline_IncreaseIndent(foundFrontObjects) & CR after foundOutline
         if foundUsedObjects is not empty then put "Used Libraries" & CR & outline_IncreaseIndent(foundUsedObjects) & CR after foundOutline
         if foundViewObjects is not empty then put "Views" & CR & outline_IncreaseIndent(foundViewObjects) & CR after foundOutline
         if foundBehaviorObjects is not empty then put "Behaviors" & CR & outline_IncreaseIndent(foundBehaviorObjects) & CR after foundOutline
         if foundMenuObjects is not empty then put "Global Menus" & CR & outline_IncreaseIndent(foundMenuObjects) & CR after foundOutline
   end switch
   
   return foundOutline
end opn_ObjectSearch

function object_SearchForProperty objectIndex, booleanProperty, pIsTrue
   local foundObjects, cantFindObjects
   put pIsTrue is not false into pIsTrue
   repeat for each line someObject in objectIndex
      if exists(someObject) is false then
         -- opn_Notify ("Cannot find object" && someObject), true
         line_Add someObject, cantFindObjects
         next repeat
      end if
      
      set the cursor to busy
      if the booleanProperty of someObject is pIsTrue then
         -- put someObject & CR after foundObjects
         line_Add someObject, foundObjects
      end if
   end repeat
   
   return word 1 to -1 of foundObjects
end object_SearchForProperty


--> Search | Object | Group
-
function object_SearchGroup containerObject, someProperty, controllerObject, pObjectKeyProperty
   local objectArray
   put the long id of the target into containerObject
   objectArray_SearchGroupForValue objectArray, propertyArray, containerObject, someProperty, pObjectKeyProperty, controllerObject
   return objectArray
end object_SearchGroup

function object_SearchGroupElements containerObject, someProperty, useTargetProperty
   local objectArray
   put the long id of the target into targetObject
   
   repeat with controlNum = 1 to the number of controls in containerObject
      put the long id of control controlNum of containerObject into someObject
      
      if useTargetProperty is true then
         put someObject into propertyObject
         put someProperty into searchProperty
      else
         put targetObject into propertyObject
         put someProperty & "[" & someObject & "]" into searchProperty
      end if
      put the searchProperty of propertyObject into objectResult
      
      put objectResult into objectArray [someObject]
   end repeat
   
   return objectArray
end object_SearchGroupElements

function object_SearchGroupArray containerObject, someProperty, useTargetProperty
   local objectArray
   put the long id of the target into targetObject
   
   if useTargetProperty is true then
      put containerObject into propertyObject
      put someProperty into searchProperty
   else
      put targetObject into propertyObject
      put someProperty & "[" & containerObject & "]" into searchProperty
   end if
   
   put the searchProperty of propertyObject into objectArray
   
   repeat with controlNum = 1 to the number of controls in containerObject
      put the long id of control controlNum of containerObject into someObject
      
      if useTargetProperty is true then
         put someObject into propertyObject
         put someProperty into searchProperty
      else
         put targetObject into propertyObject
         put someProperty & "[" & someObject & "]" into searchProperty
      end if
      put the searchProperty of propertyObject into objectArray
      
      if keys(objectArray) is empty then
         put objectArray into objectArray
      else if keys(objectArray) is not empty then
         union objectArray with objectArray
      end if
   end repeat
   
   return objectArray
end object_SearchGroupArray

command objectArray_AddProperty @objectArray, @propertyArray, containerObject, someProperty, pObjectKeyProperty, pControllerObject, pSplitArrays
   -- add the values of the top object
   put the object_Name [pObjectKeyProperty] of containerObject into containerKey
   put object_GetCustomProperty (containerObject, someProperty, pControllerObject) into objectResult
   if pSplitArrays is not false then
      put objectResult into propertyArray [containerKey][someProperty]
      put empty into objectArray [containerKey]
   else
      put objectResult into objectArray [containerKey]["@prop"][someProperty]
   end if
   return containerKey
end objectArray_AddProperty

command objectArray_SearchNested containerObject, someProperty, @propertyArray, pObjectKeyProperty, pControllerObject, pSplitArrays
   local objectArray
   -- faster
   
   objectArray_AddProperty objectArray, propertyArray, containerObject, someProperty, pObjectKeyProperty, pControllerObject, pSplitArrays
   put the result into containerKey
   
   -- look at contents
   repeat with controlNum = 1 to the number of controls in containerObject
      put the long id of control controlNum of containerObject into subObject
      put the object_Name [pObjectKeyProperty] of subObject into subKey
      
      if word 1 of subObject = "group" then -- recurse
         objectArray_SearchNested subObject, someProperty, propertyArray, pObjectKeyProperty, pControllerObject, pSplitArrays
         put the result into subArray -- will be a nested array
         if pSplitArrays is not false then
            -- put subArray ["@prop"][subKey] into objectArray ["@prop"][subKey]
            put subArray [subKey] into objectArray [containerKey][subKey]
         else
            put subArray [subKey] into objectArray [containerKey][subKey]
         end if
         add the number of layers in subObject to controlNum
      else -- add plain
         put object_GetCustomProperty (subObject, someProperty, pControllerObject) into subResult -- will often be a plain value
         if pSplitArrays is not false then
            put subResult into propertyArray [subKey][someProperty]
            put empty into objectArray [containerKey][subKey]
         else
            put subResult into objectArray [containerKey][subKey]["@prop"][someProperty]
         end if
      end if
   end repeat
   
   return objectArray
end objectArray_SearchNested

function objectArray_SearchNestedGroup containerObject, someProperty, pObjectKeyProperty, pControllerObject
   -- works but is slow due to required unions
   local objectArray
   
   put the object_Name [pObjectKeyProperty] of containerObject into containerKey
   
   -- add the values of the top object
   put object_GetCustomProperty (containerObject, someProperty, pControllerObject) into objectResult
   put objectResult into objectArray [containerKey]["@prop"][someProperty]
   
   -- look at contents
   repeat with controlNum = 1 to the number of controls in containerObject
      put the long id of control controlNum of containerObject into subObject
      put the object_Name [pObjectKeyProperty] of subObject into subKey
      
      if word 1 of subObject = "group" then -- recurse
         put objectArray_SearchNestedGroup (subObject, someProperty, pObjectKeyProperty, pControllerObject) into subArray -- will be a nested array
         -- put subArray into objectArray [containerKey] -- will clobber @props
         put objectArray [containerKey] into oldSubArray
         union subArray with oldSubArray
         put subArray into objectArray [containerKey]
         add the number of layers in subObject to controlNum
      else -- add plain
         put object_GetCustomProperty (subObject, someProperty, pControllerObject) into subResult -- will often be a plain value
         put subResult into objectArray [containerKey][subKey]["@prop"][someProperty]
      end if
   end repeat
   
   return objectArray
end objectArray_SearchNestedGroup

command objectArray_SearchGroupForValue @objectArray, @propertyArray, containerObject, someProperty, pObjectKeyProperty, pControllerObject, pSplitArrays
   -- same a "objectArray_FlatSearchGroup", but includes the actual group itself
   
   objectArray_AddProperty objectArray, propertyArray, containerObject, someProperty, pObjectKeyProperty, pControllerObject, pSplitArrays
   objectArray_FlatSearchGroup objectArray, propertyArray, containerObject, someProperty, pObjectKeyProperty, pControllerObject
end objectArray_SearchGroupForValue

command objectArray_FlatSearchGroup @objectArray, @propertyArray, containerObject, someProperty, pObjectKeyProperty, pControllerObject, pSplitArrays
   repeat with controlNum = 1 to the number of controls in containerObject
      put the long id of control controlNum of containerObject into someObject
      objectArray_AddProperty objectArray, propertyArray, someObject, someProperty, pObjectKeyProperty, pControllerObject, pSplitArrays
   end repeat
end objectArray_FlatSearchGroup

-- private command objectArray_AddProperty @objectArray, containerObject, someProperty, pObjectKeyProperty, pControllerObject
put object_GetCustomProperty (containerObject, someProperty, pControllerObject) into objectResult
if pObjectKeyProperty is empty then
   put objectResult into objectArray [containerObject]
else
   put the pObjectKeyProperty of containerObject into formattedObject
   put objectResult into objectArray [formattedObject]
end if
end objectArray_AddProperty

private function object_GetCustomProperty containerObject, someProperty, pControllerObject
   if pControllerObject is empty then
      put containerObject into propertyObject
      put someProperty into objectProperty
   else
      put pControllerObject into propertyObject
      put someProperty & "[" & containerObject & "]" into objectProperty
   end if
   put the objectProperty of propertyObject into objectResult
   return objectResult
end object_GetCustomProperty


--> Object | Search | Group | For Value
-
function object_SearchGroupForValue containerObject, someProperty, useTargetProperty
    local objectArray
    put the long id of the target into targetObject
     
    if useTargetProperty is true then
        put containerObject into propertyObject
        put someProperty into searchProperty
    else
        put targetObject into propertyObject
        put someProperty & "[" & containerObject & "]" into searchProperty
    end if
     
    put the searchProperty of propertyObject into objectResult
    put objectResult into objectArray [containerObject]
     
    repeat with controlNum = 1 to the number of controls in containerObject
        put the long id of control controlNum of containerObject into someObject
         
        if useTargetProperty is true then
            put someObject into propertyObject
            put someProperty into searchProperty
        else
            put targetObject into propertyObject
            put someProperty & "[" & someObject & "]" into searchProperty
        end if
        put the searchProperty of propertyObject into objectResult
        
        put objectResult into objectArray [someObject]
    end repeat
     
    return objectArray
end object_SearchGroupForValue

function object_SearchGroupArrayForValue containerObject, someProperty, useTargetProperty
    local objectArray
    put the long id of the target into targetObject
     
    if useTargetProperty is true then
        put containerObject into propertyObject
        put someProperty into searchProperty
    else
        put targetObject into propertyObject
        put someProperty & "[" & containerObject & "]" into searchProperty
    end if
     
    put the searchProperty of propertyObject into objectArray
     
    repeat with controlNum = 1 to the number of controls in containerObject
        put the long id of control controlNum of containerObject into someObject
         
        if useTargetProperty is true then
            put someObject into propertyObject
            put someProperty into searchProperty
        else
            put targetObject into propertyObject
            put someProperty & "[" & someObject & "]" into searchProperty
        end if
        put the searchProperty of propertyObject into objectArray
        
        if keys(objectArray) is empty then
            put objectArray into objectArray
        else if keys(objectArray) is not empty then
            union objectArray with objectArray
        end if
    end repeat
     
    return objectArray
end object_SearchGroupArrayForValue

function object_SearchGroupElementsForValue containerObject, someProperty, useTargetProperty
   local objectArray
   put the long id of the target into targetObject
   objectArray_FlatSearchGroup objectArray, propertyArray, containerObject, someProperty, pUseTargetProperty
   return objectArray
end object_SearchGroupElementsForValue
