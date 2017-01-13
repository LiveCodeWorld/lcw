script "model_ViewTemplate"
--> MetaData
-
license: GPLv3
name: model_ViewTemplate
type: model
version: 0.1

/*
Here we store all reference to view template objects.

A view template is the canocical version of a group. 
The idea being that you can copy / clone this group into multiple locations
and update the template once to help keep things easy to maintain and improve over time.

A views scripts should be stored as a script only stack behavior, along side any menu tools (controllers).
Views should where possible be standalone and not have any dependencies on libraries.

Automating the creation of a standalone stack from all these components is a useful test of a views integrity.
It is also a convenience for creating useful standalone stack components fro a view.

The most flexible place to store all behaviors and menu (controllers) is to keep the code
in a set of buttons placed on a card. 
By default we use separate cards for behaviors and for menu (controllers).

Grouping these buttons allows you to continue to use the behaviors and controllers
as these are stored using rugged_IDs and grouping them has no effect on the reference.

In this way any number of menus, controllers and behaviors can be associated with a single view stack as a standalone entity.
This enables multiple such view stacks can be combined together as substacks.

It would also be possible to have muliple views stored on its own card in a single stack. 
This would not need grouping the bahaviors and controllers for everything to work, 
though some sort of naming convention that links group names to views would help.
*/


--> Working on
-
command view_CreateBehaviorGroup viewObject, pUseBehaviorCard
   put the view_BehaviorGroup of viewObject into viewBehaviorGroup
   if exists (viewBehaviorGroup) then return viewBehaviorGroup
   
   -- does not exist so create it
   -- go and create group
   lock screen
   push cd
   put pUseBehaviorCard is not false into pUseBehaviorCard
   if pUseBehaviorCard is true then
      view_CreateBehaviorCard viewObject
      put the result into viewBehaviorCard
   else
      put the card_Object of viewObject into viewBehaviorCard
      go to viewBehaviorCard
   end if
   
   put the view_Name of viewObject into vName
   put view_ConstructBehaviorGroupName (vName) into gName
   create group gName
   put it into viewBehaviorGroup
   
   set the sharedbackground of viewBehaviorGroup to true
   set the showname of viewBehaviorGroup to true
   pop cd
   unlock screen
   return viewBehaviorGroup
end view_CreateBehaviorGroup

command view_DeleteBehaviorGroup viewObject
   view_ResetImportedBehaviors viewObject
   put the view_BehaviorGroup of viewObject into viewBehaviorGroup
   if exists (viewBehaviorGroup) is false then return empty
   delete viewBehaviorGroup
   return viewBehaviorGroup
end view_DeleteBehaviorGroup


--> Working on | Create Card
-
command view_CreateBehaviorCard viewObject
   put "Imported View Behaviors" into bCardName
   put the stack_Name of viewObject into stackName
   if exists (card bCardName of stack stackName) then
      return the long id of card bCardName of stack stackName
   end if
   
   set the defaultstack to stackName
   create card bCardName
   put it into viewBehaviorCard
   return viewBehaviorCard
end view_CreateBehaviorCard

command view_DeleteBehaviorCard viewObject
   view_ResetImportedBehaviors viewObject
   
   put view_GetBehaviorCard (viewObject) into bCardObject
   if exists (bCardObject) is false then return empty
   
   delete bCardObject
   return bCardObject
end view_DeleteBehaviorCard

function view_GetBehaviorCard viewObject
   put "Imported View Behaviors" into bCardName
   put the stack_Name of viewObject into stackName
   if exists (card bCardName of stack stackName) is false then return empty
   
   put the long id of card bCardName of stack stackName into bCardObject
   return bCardObject
end view_GetBehaviorCard

getprop view_BehaviorCard
   put the view_Object of the target into viewObject
   put view_GetTemplateBehaviorCard (viewObject) into bCardObject
   return bCardObject
end view_BehaviorCard

getprop view_ImportedBehaviorButtons
   put the view_BehaviorGroup of the target into viewBehaviorGroup
   if exists (viewBehaviorGroup) is false then return empty
   put the group_Buttons of viewBehaviorGroup into importedBehaviorButtons
   return importedBehaviorButtons
end view_ImportedBehaviorButtons

getprop view_BehaviorGroup
   put the view_Name of the target into vName
   put view_ConstructBehaviorGroupName (vName) into gName
   if exists (background gName of the defaultStack) is false then return empty
   put the long id of background gName of the defaultStack into viewBehaviorGroup
   return viewBehaviorGroup
end view_BehaviorGroup

getprop view_BehaviorButtons
   put the view_BehaviorGroup of the target into viewBehaviorGroup
   if exists (viewBehaviorGroup) is false then return empty
   put the group_Buttons of viewBehaviorGroup into groupButtons
   return groupButtons
end view_BehaviorButtons


--> View | Template
-
function view_TemplateBehaviorButtons viewName
   put view_GetTemplateObject (viewName) into viewTemplate
   put the view_ImportedBehaviorButtons of viewTemplate into templateBehaviorButtons
   return templateBehaviorButtons
end view_TemplateBehaviorButtons

function view_GetTemplateBehaviorCard viewName
   put view_GetTemplateObject (viewName) into templateObject
   if exists (templateObject) is false then return empty
   
   put view_GetBehaviorCard (templateObject) into bCardObject
   return bCardObject
end view_GetTemplateBehaviorCard

function view_GetTemplateStackName viewName
   -- the templateStackName should be the same as viewName by default
   
   put view_GetTemplateObject (viewName) into templateObject
   if exists (templateObject) is false then return empty
   put the stack_Name of templateObject into templateStackName
   return templateStackName
end view_GetTemplateStackName

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
   put view_GetTemplateObject (viewName) into viewObject
   if exists (viewObject) is false then return empty
   
   view_ResetImportedBehaviors viewObject
   
   put view_GetTemplateBehaviorCard (viewName) into bCardObject
   delete bCardObject
   return bCardObject
end view_DeleteTemplateBehaviorCard


--> View | Template | Wrappers
-
getprop template_Object
   return the view_Template of the target
end template_Object

getprop template_Behavior
   return the view_TemplateBehavior of the target
end template_Behavior


--> Template | Model
-
getprop view_BehaviorTemplateCard
   put the view_Object of the target into viewObject
   put view_GetTemplateBehaviorCard (viewObject) into bCardObject
   return bCardObject
end view_BehaviorTemplateCard

getprop view_Template
   put the view_Name of the target into vName
   put view_GetTemplateObject (vName) into templateObject
   return templateObject
end view_Template

getprop view_TemplateBehavior
   put the view_Name of the target into vName
   put view_GetTemplateBehavior (vName) into bObject
   return bObject
end view_TemplateBehavior

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

function view_GetTemplateBehavior vName
   put view_GetTemplateObject (vName) into templateObject
   put the behavior of templateObject into vBehavior
   return vBehavior
end view_GetTemplateBehavior


--> View | Behavior | Names
-
function view_ConstructBehaviorGroupName vName
   put "Behaviors of" && vName into gName
   return gName
end view_ConstructBehaviorGroupName

function view_DeconstructBehaviorGroupName gName
   if word 1 to 2 of gName = "Behaviors of" then
      delete word 1 to 2 of gName
   end if
   return gName
end view_DeconstructBehaviorGroupName
