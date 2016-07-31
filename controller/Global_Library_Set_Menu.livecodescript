script "Global_Library_Set_Menu"
--> MetaData
-
license: GPLv3
name: Global_Library_Set_Menu
type: controller
version: 0.1


--> Global | Project | Set | Menu
-
on menu_CreateNewProjectSet
   put opn_Ask ("Give the new project set a name...", "new project name") into newProjectName
   put project_ConstructMenuSetArray (stacksToUse) into projectArray
   project_SaveArray projectArray, newProjectName
end menu_CreateNewProjectSet

on menu_SetProjectUsed mTarget, projectName
   put merge ("Set project '[[projectName]]' to the use the selected stacks?") into someQuestion
   
   put the lib_Group of mTarget into libGroup
   put the selected_Stacks of libGroup into stackObjects
   
   put stackObjects
   answer someQuestion with "Cancel" or "OK"
   if it is "Cancel" then exit to top
   
   project_SetUsedStacks stackObjects, projectName
   dispatch "display_ProjectArray" to mTarget with projectName
   
   answer "Saved stacks to project!"
end menu_SetProjectUsed

on _
end _

on menu_DeleteProjectSet mTarget, projectName
   put project_GetCurrentName() into currentProjectName
   put projectName = currentProjectName into isSame
   if isSame then
      put merge ("The currently loaded project is the same as the library set [[projectName]] you are about to delete. Are you sure you want to do this?") into someQuestion
   else
      put merge ("Sure you want to delete library set [[projectName]]?") into someQuestion
   end if
   opn_Answer someQuestion
   
   project_DeleteArray projectName
   
   if isSame then
      set the displayed_Project of me to "Default" -- also sets the menu choice
   end if
   answer merge ("Deleted project '[[projectName]]' from the library!")
end menu_DeleteProjectSet

on menu_CopyCurrentlyUsedTo ideScriptObject, projectName
   library_StoreCurrentlyUsedToSet projectName
end menu_CopyCurrentlyUsedTo


--> Global | Library | Set | Menu | Props
-
getprop project_Name
   return project_GetCurrentName()
end project_Name

getprop project_Names
   return library_ListSetNames () -- & ",-,Add"
end project_Names


--> Deps
-
function project_ConstructMenuSetArray
   -- was "library_ConstructMenuSetArray"
   put library_FetchSetArray ("Default") into projectArray
   put empty into projectArray ["data"]["used"]
   return projectArray
end project_ConstructMenuSetArray

