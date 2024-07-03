script "behavior_ViewTemplateCard"
--> MetaData
-
author: David Bovill
copyright: David Bovill
name: behavior_ViewTemplateCard
type: behavior

/*
Was "Card View Behavior" and moved to this script-only behavior.

This behavior makes a view template easy to resize and test it's geometry.
It also provides the default behavior for the views menu.
You can of course override this on the cards script, or set another behavior there.
*/


--> Variables
-
local LocalArray


--> Working on
-
private command _ViewProblemMenu
   menu_PopUp "Global | View | Card | Create | Menu"
end _ViewProblemMenu

getprop displayed_Object
   return the displayed_Object of me
end displayed_Object

setprop displayed_Object sObject
   set the displayed_Object of me to sObject
end displayed_Object


--> Events
--
on openStack
   -- this is called for every view
   put the stack_Name of the target into stackName
   --
   put _templateView() into templateView
   if exists (templateView) is false then pass openStack
   --
   put the urip_Name of templateView into uripName
   if uripName = stackName then template_Check
   --
   pass openStack
end openStack

on preOpenCard
   -- view_FixBehavior templateView -- too aggressive (can cause recursion if we display a view in this handler)
   
   put _templateView() into templateView
   if exists (templateView) is false then pass preOpenCard
   
   if word 1 of templateView is not "group" then
      dispatch "view_Init" to templateView -- as "preOpencontrol" not sent
   end if
   pass preOpenCard
end preOpenCard

on LayoutCard
   put the view_Object of me into viewObject
   if exists (viewObject) is false then return empty
   
   put the view_RectOnCard of me into viewRect
   dispatch "LayoutControl" to viewObject with viewRect
   switch it
      case "unhandled"
         -- for views that do not have LayoutControl
         set the rect of viewObject to viewRect
         break
      default
         -- resized with LayoutControl
   end switch
   return viewObject
end LayoutCard

on resizeStack
   LayoutCard
   pass resizeStack
end resizeStack

on mouseDown whichModifier
   put the long id of the target into tObject
   -- if tObject is not the long id of me then pass mouseDown
   switch
      case whichModifier = 3
         _doViewMenu
         break
      case the shiftKey is "Down"
         -- put "OK"
         break
      case word 1 of tObject = "card"
         -- bug: the target gets set to "card" after events like a drag (not sure when)
         -- this does not happen with mouseStillDown
         -- set the dragAction to "link"
         -- set the dragImage to 3137
         -- put the view_Name of tObject & CR & the mouseControl & CR & tObject
         -- set the dragData ["private"] to "View|Layout|Placeholder"
         break
      default
         -- put tObject
         pass mouseDown
   end switch
end mouseDown

on mouseStillDown
   put the long id of the target into tObject
   switch
      case word 1 of tObject = "card"
         put _templateView() into tView
         if exists (tView) is false then pass mouseStillDown
         
         set the dragAction to "link"
         -- set the dragImage to 3137
         put the view_Name of tView into vName
         set the dragData ["private"] to vName
         break
      default
         pass mouseStillDown
   end switch
end mouseStillDown


--> MenuTitle | Card
-
getprop menu_Title [viewName]
   -- put LocalArray ["mTitle"] into mTitle
   put the menu_Title of me into mTitle
   if mTitle is not empty then return mTitle
   --
   put menu_GlobalTitleFromViewName (viewName) into mTitle
   set the menu_Title of me to mTitle
   --
   return mTitle
   --
   return "Global | View | Card | Tools | Menu"
end menu_Title

setprop menu_Title mTitle
   set the menu_Title of me to mTitle
   -- put mTitle into LocalArray ["mTitle"]
end menu_Title


--> Props
-
getprop view_IsTemplate
   put the stack_Name of the target into stackName
   put the urip_Type of _templateView() into uripType
   put the urip_Name of _templateView() into uripName
   
   return uripName = stackName
end view_IsTemplate

getprop view_BehaviorStackName
   put the view_Name of the target into vName
   replace "|" with empty in vName
   put "behavior_" & vName into stackName
   return stackName
end view_BehaviorStackName

getprop view_RectOnCard [pMargin]
   if pMargin is empty then
      put the card_Margin of me into pMargin
   end if
   
   put the rect of me into sRect
   --
   get the menubar of the defaultstack
   if it is not empty then
      add 21 to item 2 of sRect
   end if
   --
   if pMargin is not 0 then
      rect_SubtractMargins sRect, pMargin
   end if
   return sRect
end view_RectOnCard


--> Props | Margins
-
getprop card_Margin
   -- save with stack for standalone testing and remembering the preference
   put the card_Margin of me into cardMargin
   -- put LocalArray ["cardMargin"] into cardMargin
   if cardMargin is empty then put 24 into cardMargin
   return cardMargin
end card_Margin

setprop card_Margin cardMargin
   -- save with stack for standalone testing and remembering the preference
   -- put cardMargin into LocalArray ["cardMargin"]
   set the card_Margin of me to cardMargin
   LayoutCard
end card_Margin


--> Objects
-
getprop menu_Target
   return the view_Object of me
end menu_Target

getprop view_Template
   return _templateView()
end view_Template

getprop template_Object
   return _templateView()
end template_Object

getprop template_View
   return _templateView()
end template_View

getprop menubar_View
   if exists (group "View|Menu|Group" of me) then
      return the long id of group "View|Menu|Group" of me
   else
      return empty
   end if
end menubar_View

getprop view_Object
   if exists (control 1 of me) is false then return empty
   
   put the view_Name of control 1 of me into vName
   if vName is empty then return empty
   
   return the long id of control 1 of me
end view_Object


--> Private
-
private command _doViewMenu
   if exists (control 1 of me) is false then _ViewProblemMenu
   --
   put the long id of control 1 of me into viewObject
   put the view_Name of viewObject into viewName
   if viewName is empty then _ViewProblemMenu
   
   put the module_Name of viewObject into shortModuleFolder
   put shortModuleFolder into testViewName
   replace "_" with "|" in testViewName
   --
   put the stack_Name of viewObject into stackName
   put the short name of viewObject into shortName
   --
   switch
      -- case viewName is not stackName -- modules are often cloned
      case the optionKey is "Down"
         _ViewProblemMenu
         break
      case viewName is not shortName
         _ViewProblemMenu
         break
      case shortModuleFolder is empty
      case viewName = testViewName
         _ViewGoodMenu viewObject, viewName
         break
      default
         _ViewProblemMenu
   end switch
end _doViewMenu

private command _ViewGoodMenu viewObject, viewName
   put the menu_Title [viewName] of me into mTitle
   --
   put menu_GetGlobalController (mTitle) into mController
   if exists (mController) is false then
      put the module_ControllerFolder of viewObject into mFolder
      --
      put merge ("Menu '[[mTitle]]' not created yet. Create it?") into sQuestion
      menu_CreateController mTitle, mFolder, sQuestion, viewObject
   end if
   --
   menu_PopUp mTitle, empty, viewObject
end _ViewGoodMenu

private function drop_Target tObject
   if exists (tObject) is false then
      -- does not exist (maybe dropped onto the desktop / background)
      put empty into LocalArray ["dropTarget"] 
      return empty
   end if
   
   put the view_Object of tObject into viewObject
   switch
      case dropTarget contains sourceCardObject
         put "gDragSource = dropTarget"
         put empty into dropTarget
         break
      case the shiftKey is "Down" and the optionKey is "Down"
         -- raw
         put the long owner of tObject into dropTarget
         break
      case the optionKey is "Down"
         -- raw
         put tObject into dropTarget
         break
      case the shiftKey is "Down" and exists (viewObject)
         put the view_Above of tObject into viewAbove
         put viewAbove into dropTarget
         break
      case the shiftKey is "Down"
         put the long owner of tObject into tOwner
         put tOwner into dropTarget
         break
      case exists (viewObject)
         put viewObject into dropTarget
         break
      default
         put tObject into dropTarget
   end switch
   
   put dropTarget into LocalArray ["dropTarget"]
   return dropTarget
end drop_Target

private function view_Source sourceCardObject
   put the dragdata ["private"] into sourceViewName
   if sourceViewName is not empty then
      put view_GetTemplateObject (sourceViewName) into viewSource
   else
      if exists (sourceCardObject) is false then return empty
      put the view_Object of sourceCardObject into viewSource
   end if
   return viewSource
end view_Source


--> Deps
-
command view_FixBehavior templateView
   put the behavior of templateView into bObject
   switch
      case bObject is empty
         -- a module does not have to have a behavior
         break
      case exists (bObject) is false
         -- be careful the behavior is broken 
         -- probably it is not in the stackfiles
         breakpoint
         break
      default
         set the behavior of templateView to bObject -- quick ugly hack
         
         -- what about nested views?
         put the card_Object of templateView into cardObject
         put the behavior_BrokenArray of cardObject into testArray
   end switch
end view_FixBehavior

command template_Check
   put _templateView() into templateView
   put the urip_Type of templateView into uripType     
   switch uripType
      case "view"
         -- could update card menus?
         -- set the menu_Update of templateView to true -- slows down displaying a view
         break
      case "view template"
         lcw_Notify "View marked with old 'view template' markup!. Check the script and alter :)"
         edit the script of templateView
         break
      default
   end switch
end template_Check

private function _templateView 
   if exists (control 1 of me) then
      put the view_Name of control 1 of me into viewName
      put view_GetTemplateObject (viewName) into templateObject
      if exists (templateObject) then return templateObject
      
      -- maybe we return empty here?
      -- this will allow things to work even if the views metadata is not set
      lcw_Notify merge ("The view '[[viewName]]' does not have it's metadata and stack named properly!")
      put the long id of control 1 of me into templateObject
      return templateObject
   else
      return empty
   end if
end _templateView

command rect_SubtractMargins @sRect, pMargin
   margin_Normalize pMargin, leftM, topM, rightM, bottomM   
   add leftM to item 1 of sRect
   add topM to item 2 of sRect
   subtract rightM from item 3 of sRect
   subtract bottomM from item 4 of sRect
end rect_SubtractMargins

command margin_Normalize @someMargin, @leftM, @topM, @rightM, @bottomM
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
   put leftM,topM,rightM,bottomM into someMargin
end margin_Normalize
