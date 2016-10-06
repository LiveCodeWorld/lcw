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

command view_CreateImportedBehaviorButtons templateBehaviorCard
   if exists (templateBehaviorCard) is false then return empty
   go to templateBehaviorCard
   
   put the stack_Object of templateBehaviorCard into viewTemplateStack
   put the search_BehaviorArray of the target into stackBehaviorArray
   
   -- we must remove this
   -- crash: as seting the behavior to something else while the behavior is running causes a reliable crash!
   put the name of stack "behavior_ViewTemplateCard" into templateCardBehavior
   
   repeat for each key foundBehavior in stackBehaviorArray
      if foundBehavior ends with viewTemplateStack then
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
         create button foundBehavior
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
   return stackBehaviorArray
end view_CreateImportedBehaviorButtons

command view_CreateTemplateBehaviorCard viewName
   put "Imported View Behaviors" into bCardName
   
   put view_GetTemplateStackName (viewName) into templateStackName
   if exists (card bCardName of stack templateStackName) is true then
      put the long id of card bCardName of stack templateStackName into templateBehaviorCard
      return templateBehaviorCard
   end if
   
   set the defaultstack to viewName
   create card bCardName
   put it into templateBehaviorCard
   return templateBehaviorCard
end view_CreateTemplateBehaviorCard

command view_DeleteTemplateBehaviorCard viewName
   put view_TemplateBehaviorButtons (viewName) into templateBehaviorButtons
   repeat for each line templateBehaviorButton in templateBehaviorButtons
      put the short name of templateBehaviorButton into bObject
      put the custom_Array ["objects_WithBehavior"] of templateBehaviorButton into objectsWithBehavior
      repeat for each line someObject in objectsWithBehavior
         set the behavior of someObject to bObject
      end repeat
   end repeat   
   
   put view_GetTemplateBehaviorCard (viewName) into bCardObject
   delete bCardObject
   return true
end view_DeleteTemplateBehaviorCard

function view_TemplateBehaviorButtons viewName
   put view_GetTemplateBehaviorCard (viewName) into bCardObject
   if exists (bCardObject) is false then return false
   
   put the number of buttons of bCardObject into maxNum
   repeat with btnNum = 1 to maxNum
      put the long id of btn btnNum of bCardObject into templateBehaviorButton
      put templateBehaviorButton & CR after templateBehaviorButtons
   end repeat
   delete char -1 of templateBehaviorButtons
   return templateBehaviorButtons
end view_TemplateBehaviorButtons

function view_GetTemplateBehaviorCard viewName
   put "Imported View Behaviors" into bCardName
   put view_GetTemplateStackName (viewName) into templateStackName
   if exists (card bCardName of stack templateStackName) is false then return empty
   
   put the long id of card bCardName of stack templateStackName into bCardObject
   return bCardObject
end view_GetTemplateBehaviorCard

function view_GetTemplateStackName viewName
   -- the templateStackName should be the same as viewName by default
   
   put view_GetTemplateObject (viewName) into templateObject
   if exists (templateObject) is false then return empty
   
   put the stack_Name of templateObject into templateStackName
   return templateStackName
end view_GetTemplateStackName


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


--> Props
-
getprop template_Behavior
   put the view_Name of the target into vName
   put view_GetBehavior (vName) into bObject
   return bObject
end template_Behavior


--> View | Template
-
getprop view_TemplateStack
   put the view_Name of the target into viewName
   if exists (stack viewName) is false then return empty
   put the name of stack viewName into stackObject
   return stackObject
end view_TemplateStack

function view_GetTemplateObject viewName
   view_NormalizeName viewName
   if exists (stack viewName) then
      put the long id of control 1 of stack viewName into templateObject
      return templateObject
   end if
   
   put library_ListProjectModules() into moduleStackNames
   put library_FetchProjectFolder (viewName) into moduleFolder
   if moduleFolder is empty then return empty
   
   put project_ConstructHomeStackPath (moduleFolder) into moduleHomeStackPath
   if exists (control 1 of card 1 of stack moduleHomeStackPath) then
      return the long id of control 1 of card 1 of stack moduleHomeStackPath
   end if
   
   return empty
end view_GetTemplateObject


--> Template | Objects
-
getprop view_Template
   put the view_Name of the target into vName
   put view_GetTemplateObject (vName) into templateObject
   return templateObject
end view_Template

getprop template_Object
   return the view_Template of the target
end template_Object
