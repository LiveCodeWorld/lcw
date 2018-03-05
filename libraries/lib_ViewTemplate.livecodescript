script "lib_ViewTemplate"
--> MetaData
-
license: GPLv3
name: lib_ViewTemplate
type: library
version: 0.3

/*
This script-only library is a utility for browsing, testing and authoring lcw view templates.
It should not required for the functioning of the views to work.
*/


--> Working on
-
command view_CreateImportedBehaviorButtons viewObject, pUseBehaviorCard
   view_CreateBehaviorGroup viewObject, true
   put the result into behaviorGroup
   
   put the stack_Object of viewObject into viewStack
   put the name of stack "behavior_ViewTemplateCard" into templateCardBehavior
   
   put view_GetBehaviorCard (viewObject) into bCardObject
   lock screen
   push cd
   go to bCardObject
   
   put the search_BehaviorArray of the target into stackBehaviorArray
   repeat for each key foundBehavior in stackBehaviorArray
      if foundBehavior ends with viewStack then
         -- it's already  a local behavior in this stack
         breakpoint
         next repeat
      end if
      
      if foundBehavior = templateCardBehavior then
         -- we must remove this
         -- crash: as seting the behavior to something else while the behavior is running causes a reliable crash!
         next repeat
      end if
      
      -- it's external
      -- put the short name of foundBehavior into bName
      if exists (btn foundBehavior) is false then
         create button foundBehavior in behaviorGroup
         put it into createdButton
      else
         put the long id of button foundBehavior into createdButton
      end if
      
      set the width of createdButton to (the formattedwidth of createdButton + 12)
      
      put stackBehaviorArray [foundBehavior] into objectsWithBehavior
      set the custom_Array ["objects_WithBehavior"] of createdButton to objectsWithBehavior
      
      put the script of foundBehavior into bScript
      set the script of createdButton to bScript
      
      -- now reset the views behaviors
      repeat for each line someObject in objectsWithBehavior   
         set the behavior of someObject to createdButton
         set the object_Metadata ["behavior"] of someObject to foundBehavior
      end repeat
   end repeat
   choose browse tool
   pop cd
   unlock screen
   return stackBehaviorArray
end view_CreateImportedBehaviorButtons


--> Template | Behaviors
-
setprop imported_ViewBehaviors [pUseBehaviorCard] someBoolean
   put the view_Object of the target into viewObject
   if exists (viewObject) is empty then return empty
   
   if someBoolean is true then
      view_CreateImportedBehaviorButtons viewObject, pUseBehaviorCard
   else
      switch pUseBehaviorCard
         case true
            view_DeleteBehaviorCard viewObject
            break
         case false
            view_DeleteBehaviorGroup viewObject
            break
         default
            view_ResetImportedBehaviors viewObject
      end switch
   end if
end imported_ViewBehaviors

getprop imported_ViewBehaviors
   put the view_BehaviorGroup of the target into viewBehaviorGroup
   put exists (viewBehaviorGroup) into someBoolean
   return someBoolean
end imported_ViewBehaviors

command view_ResetImportedBehaviors viewObject 
   put the view_ImportedBehaviorButtons of viewObject into importedBehaviorButtons
   repeat for each line importedBehaviorButton in importedBehaviorButtons
      put the custom_Array ["objects_WithBehavior"] of importedBehaviorButton into objectsWithBehavior
      repeat for each line someObject in objectsWithBehavior
         put the object_Metadata ["behavior"] of someObject into oBehavior
         set the behavior of someObject to oBehavior
         set the object_Metadata ["behavior"] of someObject to empty
      end repeat
   end repeat   
end view_ResetImportedBehaviors


--> Working On
-
command view_ExportTemplateBehaviorCardScripts viewName
   put view_TemplateBehaviorButtons (viewName) into templateBehaviorButtons
   
   repeat for each line templateBehaviorButton in templateBehaviorButtons
      put the short name of templateBehaviorButton into scriptOnlyObject
      
      put the script of templateBehaviorButton into buttonScript
      put the script of scriptOnlyObject into scriptOnlyScript
      
      -- now export
      if scriptOnlyScript is not buttonScript then
         display_Text scriptOnlyScript, scriptOnlyObject
         display_Text buttonScript, "Button"
         
         answer "Do you want to export the button behavior and overwrite the scriptonly stack script?" with "Export" and "Cancel"
         if it is "Cancel" then next repeat
         
         set the script of scriptOnlyObject to scriptOnlyScript
         -- save scriptOnlyObject 
      end if
   end repeat   
   return true
end view_ExportTemplateBehaviorCardScripts


--> View | Template
-
command template_ConstructStackFromObject someObject, pCreateBehavior
   put the view_Name of someObject into viewName
   if viewName is empty then
      put lcw_Ask ("Give this new control a view_Name...", "View|Something|Or Other") into viewName
   end if
   
   project_CreateView viewName, pViewFilePath
   
   copy someObject to card 1 of stack viewName
   put it into viewTemplate
   set the view_Name of viewTemplate to viewName
   if pCreateBehavior is not false then
      -- we can create a behavior stack later easily
      -- view_TemplateAddBehavior viewTemplate, viewName
   end if
   
   return viewTemplate
end template_ConstructStackFromObject

command view_TemplateAddBehavior viewTemplate, pEditScripts
   -- old way of imprting a behavior into a view button (before the use of view_BehaviorGroups
   breakpoint
   
   put the view_Name of viewTemplate into vName
   if vName is empty then
      put "The view template has not view_Name set!"
      put viewTemplate
      answer warning someWarning
      breakpoint
      return viewTemplate
   end if
   
   put the stack_Object of viewTemplate into viewTemplateStack
   put the defaultstack into oDefaultStack
   set the defaultstack to viewTemplateStack
   
   if there is a button "View Behavior" of card "View Behavior" then
      -- don't create if it already exists
      set the defaultstack to oDefaultStack
      return the long id of button "View Behavior" of card "View Behavior"
   end if
   
   -- now fetch an appropriate default template behavior script
   put the behavior of viewTemplate into oldBehavior
   if exists(oldBehavior) then
      put the script of oldBehavior into templateBehaviorScript
   else 
      put the script of viewTemplate into templateBehaviorScript
      if the revAvailableHandlers of viewTemplate is empty then
         put the template_DefaultScript ["view behavior"] of viewTemplate into templateBehaviorScript
         put script_GetMetadataArray (templateBehaviorScript) into uRipArray -- ugly, could get from above
         urip_AddDefaults uRipArray, vName, "view behavior"
      else
         put script_GetMetadataArray (templateBehaviorScript) into uRipArray
         urip_AddDefaults uRipArray, vName, "view behavior"
         script_SetMetadataArray templateBehaviorScript, uRipArray
      end if
   end if
   
   lock screen
   --
   put the stack_Object of viewTemplate into viewTemplateStack
   set the defaultstack to viewTemplateStack
   if exists (card "View Behavior") then
      go to card "View Behavior"
   else
      create card "View Behavior"
      repeat for each line gID in the sharedgroupIDs of this card
         -- in case the template is a shared gorup or background
         remove group id gID from this card
      end repeat
   end if
   
   create button "View Behavior"
   put it into createdButton
   
   put vName && "behavior" into someLabel
   set the label of createdButton to someLabel
   set the width of createdButton to (the formattedwidth of createdButton + 12)
   set the topleft of createdButton to "50,50"
   
   set the script of createdButton to templateBehaviorScript
   set the customproperties ["uRIP"] of createdButton to uRipArray
   object_AddToGlobalArray tObject
   
   put "view" into uRipArray ["type"]
   put script_ConstuctMetaDataHeader (uRipArray) into newTemplateScript
   
   set the behavior of viewTemplate to createdButton
   set the script of viewTemplate to newTemplateScript
   -- set the view_Name ["view"] of viewTemplate to vName
   set the customproperties ["uRIP"] of viewTemplate to uRipArray
   
   get the view_IsTemplate of viewTemplate
   object_AddToGlobalArray viewTemplate
   
   go to card 1
   --
   unlock screen
   
   if pEditScripts is not false then
      edit the script of viewTemplate
      edit the script of createdButton
      if the shiftKey is "Down" then
         put view_ConstructBehaviorOutline() into viewFiles
         display_Outline viewFiles, "Behavior outline"
      end if
   end if
   set the defaultstack to oDefaultStack
   return createdButton
end view_TemplateAddBehavior
