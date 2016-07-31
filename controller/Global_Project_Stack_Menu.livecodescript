script "Global | Project | Stack | Menu"
--> MetaData
-
license: GPLv3
name: Global | Project | Stack | Menu
type: controller
version: 0.3


--> Menu | Props
-
/*
Submenus are not taking the menu_Target property.
This seesm to only work now for the top_MenuController.
*/


--> Global | Project | Stack | Menu
-
on menu_GoToStack stackObject
   object_GoTo stackObject
end menu_GoToStack

on menu_EditStackScript stackObject
   put the name of stackObject
   edit the script of stackObject
end menu_EditStackScript

on menu_UseStack stackObject, someBoolean
   if someBoolean is true then
      start using stackObject
      opn_Notify merge ("Started using [[stackObject]]")
   else
      stop using stackObject
      opn_Notify merge ("Stopped using [[stackObject]]")
   end if
end menu_UseStack

on _
end _

on menu_RefreshIndex
   dispatch "refresh" to _indexView() 
end menu_RefreshIndex

on menu_IndexScript stackObject
   script_IndexAndCreateOverlay stackObject
end menu_IndexScript

on _
end _

on submenu_Script
   return "Global | Script | Menu"
end submenu_Script

on menu_DisplayDependencyObjectArray stackObject
   put the project_DependencyStackArray of stackObject into depObjectArray
   display_Array depObjectArray
end menu_DisplayDependencyObjectArray

on menu_DependencyObjects stackObject
   put the project_DependencyStacks of stackObject -- into dependencyStacks
end menu_DependencyObjects

on menu_RevealProjectOverlayFolder stackObject
   put the project_OverlayFolder of stackObject into projectOverlayFolder
   put projectOverlayFolder
   finder_Reveal projectOverlayFolder
end menu_RevealProjectOverlayFolder

on _
end _

on menu_TrashStack stackObject
   put merge ("Are you sure you want to delete the file, and remove the [[stackObject]] from all projects?") into someQuestion
   answer someQuestion with "OK" or "Cancel"
   if it is "Cancel" then exit to top
   
   breakpoint
   put the filename of stackObject into longStackFile
   library_RemoveStackFromAllProjects stackObject
   
   stop using stackObject
   set the stack_IsKnow of stack longStackFile to false -- do this for all projects ?
   
   delete stackObject
   delete file longStackFile
   
   dispatch "refresh" to _indexView() 
end menu_TrashStack

on menu_DisplaySubstack stackObject, subStackName
   put the short name of stackObject into stackName
   go to stack subStackName of stack stackName
end menu_DisplaySubstack

on _
end _

on menu_AddToThisProject stackObject
   if exists (stackObject) is false then
      answer warning merge ("I cannot locate [[stackObject]]. Please locate and add to the stackfiles.")
      exit to top
   end if
   
   put _indexView() into indexView
   put the displayed_project of indexView into projectName
   
   library_AddUsedStack stackObject, projectName
   
   put the short name of stackObject into stackName
   start using stack stackName
   start using stackObject -- seems to have changed
   
   dispatch "refresh" to indexView
   set the hilite_Used of indexView to true
end menu_AddToThisProject

on menu_AddToAllProjects stackObject
   put _indexView() into indexView
   
   start using stackObject
   put lcw_ListProjects() into projectNames
   repeat for each line projectName in projectNames   
      library_AddUsedStack stackObject, projectName
   end repeat
   
   dispatch "refresh" to indexView
   set the hilite_Used of indexView to true
end menu_AddToAllProjects

on _
end _

on menu_RemoveFromThisProject stackObject
   stop using stackObject 
   library_DeleteUsedStack stackObject
   _displayAndHilite
end menu_RemoveFromThisProject

on menu_RemoveFromAllProjects stackObject
   stop using stackObject 
   library_RemoveStackFromAllProjects stackObject
   _displayAndHilite
end menu_RemoveFromAllProjects


--> Global | Project | Stack | Menu | Props
-
getprop use_Stack [stackObject]
   set the wholematches to true
   put the short name of stackObject is among the lines of the stacksinuse into isUsed
   return isUsed
end use_Stack

getprop sub_StackNames [stackObject]
   put the substacks of stackObject into subStackNames
   return subStackNames
end sub_StackNames


--> Global | Project | Stack | Menu | Disabled
-
getprop disabled_DisplayDependencyObjectArray [stackObject]
   put the project_ProcessedHkeyArrayFile of stackObject into processedHkeyArrayFile
   put there is a file processedHkeyArrayFile into fileExists
   return fileExists is false
end disabled_DisplayDependencyObjectArray

getprop disabled_TrashStack [stackObject]
   put the substacks of stackObject into subStackNames
   return subStackNames is not empty
end disabled_TrashStack

getprop disabled_DisplaySubstack [stackObject]
   put the substacks of stackObject into subStackNames
   return subStackNames is empty
end disabled_DisplaySubstack


--> Deps
-
command _displayAndHilite
   put _rescueDisplayCard() into displayCard
   if exists(displayCard) is false then return empty
   
   lock screen
   set the hilite_Used of displayCard to true
   dispatch "display_ProjectArray" to displayCard
   unlock screen
   return displayCard
end _displayAndHilite



--> Objects
-
function _indexView
   put menu_GetTargetObject() into tObject
   put the index_View of tObject into indexView
   return indexView
end _indexView

function _rescueDisplayCard
   if there is a stack "Rescue livecode World" then
      put the long id of card 1 of stack "Rescue livecode World" into displayCard
      return displayCard
   else
      return empty
   end if
end _rescueDisplayCard
