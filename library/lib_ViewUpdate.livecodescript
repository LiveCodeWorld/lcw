script "lib_ViewUpdate"
--> MetaData
-
license: GPLv3
name: lib_ViewUpdate
type: script library
version: 0.8


--> Control
-
getprop control_IsTop
   put the long id of the target into targetObject
   put the long id of the owner of targetObject into targetOwner
   
   put the layer of targetOwner into targetOwnerLayer
   put the layer of targetObject into targetObjectLayer
   put targetObjectLayer = targetOwnerLayer + 1 into isTopLayer
   return isTopLayer
end control_IsTop

getprop child_ControlTypes
   put the long id of the target into targetObject
   
   put the childcontrolids of targetObject into topIDs
   repeat for each line someID in topIDs
      put the long id of control id someID into someControl
      put the control_Type of someControl into controlType
      put controlType & CR after controlTypes
   end repeat
   delete char -1 of controlTypes
   return controlTypes
end child_ControlTypes

setprop child_ControlTypes controlTypes
   replace comma with CR in controlTypes
   put the long id of the target into layoutView
   
   put the childcontrolids of layoutView into topIDs
   repeat with lineNum = 1 to the number of lines of topIDs
      put line lineNum of controlTypes into controlType
      
      put line lineNum of topIDs into someID
      if someID is empty then
         breakpoint
         -- here we create new things
         put controlType into someName
         put toUpper (char 1 of someName) into char 1 of someName
         put control_ConstructCreateDoScript (controlType, someName, layoutView) into doScript
         if doScript is empty then next repeat
         do doScript
         put it into newControl
      else
         put the long id of control id someID into someControl
         set the control_Type of someControl to controlType
         put the result into newControl
      end if
      
      put newControl & CR after newControls
   end repeat
   delete char -1 of newControls
   return newControls
end child_ControlTypes

getprop control_Type
   put the long id of the target into targetObject
   
   put the view_Name of targetObject into vName
   switch
      case word 1 of targetObject = "widget"
         put the kind of targetObject into someKind
         set the itemdelimiter to "."
         return item -1 of someKind
      case vName is "View|Layout|Placeholder"
         return "placeholder"
      case vName is not empty
         return vName
      default
         return word 1 of targetObject
   end switch
end control_Type

setprop control_Type [pClassOrViewName] controlType
   lock screen
   -- 
   put the long id of the target into targetObject
   put the long id of the owner of targetObject into targetOwner
   
   put the short name of targetObject into oName
   put the short id of targetObject into originalID
   put the rect of targetObject into oRect
   
   put control_ConstructCreateDoScript (controlType, oName, targetOwner, pClassOrViewName) into doScript
   if doScript is empty then return empty
   
   do doScript
   put it into tempCreatedObject
   if exists (tempCreatedObject) is false then
      breakpoint
      return empty
   end if
   set the rect of tempCreatedObject to oRect
   
   relayer tempCreatedObject before targetObject
   
   -- some utitlity hacks
   switch
      case controlType is empty
      case controlType = "View|Layout|Placeholder"
      case controlType = "placeholder"
         -- it's a placeholder view
         if pClassOrViewName is empty then
            put "random" into someColour
         else
            put pClassOrViewName into someColour
         end if
         set the view_Colour of tempCreatedObject to someColour
         set the urip_Type of tempCreatedObject to "view"
         break
      case controlType = "view"
         -- put pClassOrViewName into viewName
         set the urip_Type of tempCreatedObject to "view"
         break
      case controlType contains "|"
         -- put controlType into viewName
         set the urip_Type of tempCreatedObject to "view"
         break
      default
         -- it's a standard Livecode control
         -- here we could look at "pClassOrViewName" and 
         -- add some customisation to things list list fields
   end switch
   
   object_Delete targetObject
   
   set the name of tempCreatedObject to oName
   show tempCreatedObject
   set the id of tempCreatedObject to originalID
   dispatch "view_IndexChildren" to targetOwner -- should not be need as the id is the same
   
   -- does not seem to work well without sending in 2 ticks
   -- dispatch "LayoutControl" to targetOwner
   send "LayoutControl" to targetOwner in 2 ticks
   -- 
   unlock screen
   
   -- this is a pretty useless reference as the id has been reset
   -- so the original "targetObject" is what you need
   -- here for interest / testing
   return tempCreatedObject
end control_Type

getprop control_Types
   return the child_ControlTypes of the target
end control_Types

setprop control_Types controlTypes
   set the child_ControlTypes of the target to controlTypes
   put the result into newControls
   return newControls
end control_Types

setprop view_Replacement [sendReplace] anotherView
   if exists (anotherView) is false then return empty
   put the long id of the target into viewToReplace
   put the long id of anotherView into anotherView
   if anotherView = viewToReplace then 
      return empty
   else if word 1 of viewToReplace is "stack" then
      return empty
   end if
   put viewToReplace into viewOwner
   delete word 1 to 4 of viewOwner
   
   put the rect of viewToReplace into oRect
   put the short name of viewToReplace into oName
   -- put the object_GroupLayer of viewToReplace into oGroupLayer
   put the view_StyleArray of viewToReplace into viewStyleArray
   put the view_CustomStyleArray of viewToReplace into bigStyleArray
   if word 1 of viewToReplace is "group" then set the cantdelete of viewToReplace to false
   
   put word 1 of viewOwner = "group" into ownerIsGroup
   if ownerIsGroup then  -- lock so that copied view does not change owner groups rect
      put the lockloc of viewOwner into oLock
      set the lockloc of viewOwner to true
   end if
   
   put revRuggedID (viewToReplace) into viewToReplace
   put revRuggedID (anotherView) into anotherView
   
   lock screen
   copy anotherView to viewOwner
   put it into copiedView
   
   relayer copiedView before viewToReplace
   
   try
      delete viewToReplace
   catch e
      send "delete viewToReplace" to viewToReplace in 2 ticks
   end try
   try
      put word 3 of viewToReplace into previousID
      set the id of copiedView to previousID
      put viewToReplace into copiedView
   catch e
      -- breakpoint
   end try
   set the name of copiedView to oName
   
   set the view_StyleArray of copiedView to bigStyleArray
   -- set the object_GroupLayer of copiedView to oGroupLayer
   if "view_Rect" is among the lines of the script_SetPropHandlers of copiedView then
      set the view_Rect of copiedView to oRect  -- this will force a redraw
   else
      set the rect of copiedView to oRect
   end if
   
   if ownerIsGroup then set the lockloc of viewOwner to oLock
   unlock screen
   -- get the view_UpdateIndex of copiedView
   put the long id of copiedView into copiedView
   return copiedView
end view_Replacement

--> Bottome | Controls
-
getprop bottom_ControlName
   put the long id of the target into targetObject
   
   put the childcontrolids of targetObject into topIDs
   if topIDs is empty then return empty
   
   put line -1 of topIDs into bottomID
   put the short name of control id bottomID into bottomName
   return bottomName
end bottom_ControlName

setprop bottom_ControlName bottomName
   put the long id of the target into layoutView
   
   put the top_Control [bottomName] of layoutView into someControl
   if exists (someControl) is false then return empty
   
   relayer someControl to front of layoutView
   dispatch "LayoutControl" to layoutView
   
   return someControl
end bottom_ControlName


--> Top | Controls
-
getprop top_ControlName
   put the long id of the target into targetObject
   
   put the childcontrolids of targetObject into topIDs
   if topIDs is empty then return empty
   
   put line 1 of topIDs into topID
   put the short name of control id topID into topName
   return topName
end top_ControlName

setprop top_ControlName topName
   put the long id of the target into layoutView
   
   put the top_Control [topName] of layoutView into topControl
   if exists (topControl) is false then return empty
   
   relayer topControl to back of layoutView
   dispatch "LayoutControl" to layoutView
   
   return topControl
end top_ControlName

getprop top_Control [topName]
   put the long id of the target into targetObject
   
   -- finds or returns the top control
   put the childcontrolids of targetObject into topIDs
   if topIDs is empty then return empty
   if topName is empty then
      put line 1 of topIDs into topID
      put the long id of control id topID into topControl
      return topControl
   end if
   
   -- let's find a top control with the name "topName"
   repeat for each line someID in topIDs
      put the long id of control id someID into someControl
      put the short name of someControl into testName
      if testName = topName then
         return someControl
      end if
   end repeat
   return empty
end top_Control

getprop top_ControlNames
   put the long id of the target into targetObject
   
   put the childcontrolids of targetObject into topIDs
   repeat for each line someID in topIDs
      put the short name of control id someID & CR after topNames
   end repeat
   delete char -1 of topNames
   return topNames
end top_ControlNames

setprop top_ControlNames topNames
   replace comma with CR in topNames
   put the long id of the target into layoutView
   
   repeat for each line topName in topNames
      put the top_Control [topName] of layoutView into topControl
      if exists (topControl) is false then next repeat
      
      relayer topControl to front of layoutView
   end repeat
   dispatch "LayoutControl" to layoutView
   return the top_ControlNames of layoutView
end top_ControlNames

getprop top_Controls
   put the long id of the target into targetObject
   
   put the childcontrolids of targetObject into topIDs
   repeat for each line someID in topIDs
      put the long id of control id someID & CR after topControls
   end repeat
   delete char -1 of topControls
   return topControls
end top_Controls


--> Handlers
-
getprop widget_Names
   -- useful for menus
   -- these names correspond to the case conditions of the "control_ConstructCreateDoScript" function below
   return "headerBar,navBar,segmented,browser,tree"
end widget_Names

function control_ConstructCreateDoScript controlType, someName, targetOwner, pClassOrViewName
   switch
      case controlType is empty
      case controlType = "placeholder"
         put view_GetTemplateObject ("View|Layout|Placeholder") into templateObject
         if exists (templateObject) is false then return empty
         put "copy" && templateObject && "to" && targetOwner into doScript
         return doScript
      case controlType = "view"
         put view_GetTemplateObject (pClassOrViewName) into templateObject 
         if exists (templateObject) is false then return empty
         put "copy" && templateObject && "to" && targetOwner into doScript
         return doScript
      case controlType contains "|"
         put controlType into viewName
         put view_GetTemplateObject (viewName) into templateObject 
         if exists (templateObject) is false then return empty
         put "copy" && templateObject && "to" && targetOwner into doScript
         return doScript
      case controlType = "headerBar"
         put widget_ConstructCreateDoScript (someName, "com.livecode.widget.headerBar", targetOwner) into doScript
         return doScript
      case controlType = "navBar"
         put widget_ConstructCreateDoScript (someName, "com.livecode.widget.navBar", targetOwner) into doScript
         return doScript
      case controlType = "segmented"
         put widget_ConstructCreateDoScript (someName, "com.livecode.widget.segmented", targetOwner) into doScript
         return doScript
      case controlType = "browser"
         put widget_ConstructCreateDoScript (someName, "com.livecode.widget.browser", targetOwner) into doScript
         return doScript
      case controlType = "treeView"
         put widget_ConstructCreateDoScript (someName, "com.livecode.widget.treeView", targetOwner) into doScript
         return doScript
      case controlType = "widget"
         put widget_ConstructCreateDoScript (someName, pClassOrViewName, targetOwner) into doScript
         return doScript
      default
         if word 1 of targetOwner is "group" then
            put "create invisible" && controlType && quote & someName & quote && "in" && targetOwner into doScript
         else
            put "create invisible" && controlType && quote & someName & quote into doScript
         end if
         return doScript
   end switch
end control_ConstructCreateDoScript

function widget_ConstructCreateDoScript someName, widgetClass, pTargetOwner
   if word 1 of pTargetOwner is "group" then
      put "create invisible widget" && quote & someName & quote && "as" && quote & widgetClass & quote && "in" && pTargetOwner into doScript
   else
      put "create invisible widget" && quote & someName & quote && "as" && quote & widgetClass & quote into doScript
   end if
   return doScript
end widget_ConstructCreateDoScript

command object_Delete deadObjects
   lock screen
   repeat for each line someObject in deadObjects
      if exists(someObject) then
         try
            delete someObject
         catch e
            -- in case the script is executing in the context of the object itself
            send "delete someObject" to someObject in 2 ticks
         end try
      end if
   end repeat
   unlock screen
end object_Delete


--> View | Update
-
command view_Update pSomeView, pSendReplace
   -- replaces a view with a library version if the library version is more up-to-date
   -- wraps the "view_Replacement"
   
   if exists (pSomeView) is false then put the view_Object of the target into pSomeView
   if exists (pSomeView) is false then return merge ("Error: view [[the name of pSomeView]] does not exist.")
   put pSendReplace is not false into pSendReplace
   put the view_Template of pSomeView into libraryView
   if exists (libraryView) is false then return "Error: library view does not exist. maybe target is not a view?"
   
   set the view_Replacement [pSendReplace] of pSomeView to libraryView
   return the result
end view_Update


--> View | Update | Props
-
setprop view_Swap [sendReplace] vName
   view_NormalizeName vName
   put view_GetTemplateObject (vName) into anotherView
   if exists(anotherView) is false then
      beep
      return merge("Error: library [[viewPath]] view does not exist.")
   end if
   set the view_Replacement [sendReplace] of the target to anotherView
   put the result into copiedView
   
   -- refresh display
   set the wholematches to true
   if "opn_ViewOutline" is among the lines of the openstacks then
      set the displayed_ViewOutline of stack "opn_ViewOutline" to the displayed_ViewOutline of stack "opn_ViewOutline"
   end if
   return copiedView
end view_Swap


--> View | Insert
-
setprop view_Insert [someRect] viewPath
   put the long id of the target into groupOrCard
   view_InsertFromPath viewPath, groupOrCard, someRect
   put the result into createdView
   return createdView
end view_Insert

command view_InsertFromPath viewPath, groupOrCard, someRect
   if word 1 of groupOrCard is not among the items of "group,background,card" then
      get merge ("Error: trying to insert view into wrong type of object [[name of the target]]!")
      return the script_Error [it] of me
   end if
   
   put view_NameToFile (viewPath) into viewFile
   put view_GetTemplateObject (viewPath) into libraryView
   if exists (libraryView) is false then
      get merge("Cannot find library object '[[viewPath]]'")
      return the script_Error [it] of me
   end if
   view_InsertObject libraryView, groupOrCard, someRect
   put the result into createdView
   return createdView
end view_InsertFromPath

command view_InsertObject someObject, viewOrCard, someRect
   lock screen
   put the loc of viewOrCard into oLoc
   put the rect of viewOrCard into oRect
   
   copy someObject to viewOrCard
   put it into viewInstance
   
   if someRect is not empty then
      set the rect of viewInstance to someRect
   else
      set the loc of viewInstance to oLoc
   end if
   
   set the view_Rect of viewOrCard to oRect
   unlock screen
   return viewInstance
end view_InsertObject

setprop object_Replacement [sendReplace] anotherView
   put the long id of the target into viewToReplace
   put the long id of anotherView into anotherView
   if anotherView = viewToReplace then 
      log_Error "Cannot replace a view with itself!", the params, true
      return empty
   else if word 1 of viewToReplace is "stack" then
      log_Error merge("Cannot replace a [[viewToReplace]] with the script 'view_Replace'!"), the params, true
      return empty
   end if
   
   put viewToReplace into viewOwner
   delete word 1 to 4 of viewOwner
   
   put the rect of viewToReplace into oRect
   put the short name of viewToReplace into oName
   
   lock screen
   copy anotherView to viewOwner
   put it into copiedView
   
   if sendReplace is true then
      send "delete viewToReplace" to viewToReplace in 2 ticks
   else
      delete viewToReplace
   end if	# but this is prettier!
   
   set the rect of copiedView to oRect
   set the name of copiedView to oName
   unlock screen
   
   return copiedView
end object_Replacement
