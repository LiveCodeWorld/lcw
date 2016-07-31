script "Global | Behavior | View | Menu"
--> MetaData
-
license: GPLv3
name: Global | Behavior | View | Menu
type: controller
version: 0.1

local LocalArray


--> Menu | Props
-
getprop menu_CheckTarget [scriptObject]
   -- menu_Target is not set in "menu_Init"
   -- so check it here
   put the object_MetaData ["type"] of scriptObject into mObectType
   put mObectType contains "view" into viewOrViewBehavior
   
   put mObectType into LocalArray ["mObectType"]
   put viewOrViewBehavior into LocalArray ["viewOrViewBehavior"]
   return viewOrViewBehavior is true
end menu_CheckTarget


--> Global | Behavior | View | Menu
-
on menu_GoToView scriptObject
   put the object_MetaData ["name"] of scriptObject into viewName
   put view_GetTemplateObject (viewName) into templateObject
   switch
      case templateObject = empty
         answer warning merge ("The view '[[viewName]]' is not in the database!")
         break
      case exists (templateObject) is false
         put templateObject
         answer warning merge ("I cannot find the view template for view '[[viewName]]'")
         break
      default
         object_GoTo templateObject
   end switch
end menu_GoToView

on menu_CreateView scriptObject
   breakpoint
   -- template_ConstructCloneStack
   template_ConstructStackFromObject scriptObject
end menu_CreateView

on menu_ConvertViewBehavior scriptObject
   put "Choose a name for your script only menu stack...." into pQuestion
   put "Global_Example_Menu" into suggestedAnswer
   
   put the script of scriptObject into bScript
   lcw_CreateLibrary "controller", pQuestion, suggestedAnswer
end menu_ConvertViewBehavior

on _
end _

on menu_SetViewBehavior scriptObject, vbName
   if vbName is "Clear" then put empty into vbName
   set the view_Behavior of scriptObject to vbName
   put the result into someObject
   
   put "Set the view behavior of" && the mobile_Name of scriptObject && "to" && kwote(vbName) into someMessage
   opn_Notify someMessage
   
   edit the script of someObject
end menu_SetViewBehavior

on menu_EditViewBehavior scriptObject, vbName
   if vbName is "Clear" then return false
   
   put hArray_GetNamedObjectType (vbName, "view behavior") into someObject
   edit the script of someObject
end menu_EditViewBehavior


--> Global | Behavior | View | Menu | Props
-
getprop vb_Name [scriptObject]
   put the view_Behavior of scriptObject into vbName
   if vbName is empty then return "Clear"
   return vbName
end vb_Name

getprop vb_Names [scriptObject]
   put object_ListLables ("view behavior") into someMenu
   replace "View|" with empty in someMenu
   sort someMenu
   
   if someMenu is empty then
      return "Clear"
   else
      put CR & "-" & CR & "Clear" after someMenu
      return someMenu
   end if
end vb_Names


--> Global | Behavior | View | Menu | Disabled
-
getprop disabled_GoToView [scriptObject]
   put the object_MetaData ["type"] of scriptObject into mObectType
   put mObectType contains "view" into viewOrViewBehavior
   return viewOrViewBehavior is false
end disabled_GoToView

getprop disabled_ConvertViewBehavior [scriptObject]
   put the object_IsOldBehavior of scriptObject into isOldBehavior
   return isOldBehavior is false
end disabled_ConvertViewBehavior
