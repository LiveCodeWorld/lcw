script "Global_Library_Set_Menu"
--> MetaData
-
license: GPLv3
name: Global_Library_Set_Menu
type: controller
version: 0.1


--> Global | Project | Set | Menu
-
on menu_GetEnvironmentArray
   put enviroment_GetArray () into environmentArray
   
   put merge ("enviroment_GetArray()") into someTitle
   display_Array environmentArray, someTitle, "Global | Project | Menu"
end menu_GetEnvironmentArray

on menu_FetchProjectArray mTarget, goodProjectName
   put project_FetchArray (goodProjectName) into projectArray
   
   put merge ("project_FetchArray (projectName),[[goodProjectName]]") into someTitle
   display_Array projectArray, someTitle, "Global | Project | Menu"
end menu_FetchProjectArray

on menu_StoreCurrentProjectArray mTarget, goodProjectName
   project_StoreProjectArray goodProjectName
end menu_StoreCurrentProjectArray

on menu_DisplayLibraryProjectArray mTarget, goodProjectName
   put library_FetchProjectArray (goodProjectName) into projectArray
   put merge ("library_FetchProjectArray (projectName),[[goodProjectName]]") into someTitle
   display_Array projectArray, someTitle, "Global | Project | Menu"
end menu_DisplayLibraryProjectArray

on _
end _

on menu_AddNewProject mTarget
   put merge ("Choose a folder for your new project'..") into someComment
   answer folder someComment
   put it into projectFolder
   if projectFolder is empty then exit to top
   
   put project_NameFromFolder (projectFolder) into projectName
   if there is not a stack projectName then
      put merge ("A stack with the same as the project [[projectName]] does not exist!") into someComment
      answer warning someComment
      exit to top
   end if
   
   put project_SearchForProjectFolder (projectName) into testFolder
   if testFolder is empty then
      answer warning "A stack with the same as the project does not exist!"
      exit to top
   end if
   if testFolder is not projectFolder then
      answer warning "A project folder must have a stack with the same as the project at the top level of the folder!"
      exit to top
   end if
   
   put project_ListUsedStacks (projectName) into usedStackObjects
   put the project_NeededStackFiles of stack projectName into pStackFiles
   put project_ListImportantStacks (projectName) into pImportantStackNames
   if pImportantStackNames is empty then put the openstacks into pImportantStackNames
   put project_ConstructArray (projectName, projectFolder, usedStackObjects, pStackFiles, pImportantStackNames) into projectArray
   library_StoreProjectArray projectName, projectArray
   
   -- put library_FetchProjectArray ("Default") into projectArray
   -- library_StoreProjectFolder projectName, projectFolder
   put merge ("Added new project '[[projectName]]' with default values...") into someComment
   answer someComment
end menu_AddNewProject

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
   
   library_StoreProjectArray projectName
   
   if isSame then
      set the displayed_Project of me to "Default" -- also sets the menu choice
   end if
   answer merge ("Deleted project '[[projectName]]' from the library!")
end menu_DeleteProjectSet

on menu_CopyCurrentlyUsedTo ideScriptObject, projectName
   library_StoreCurrentlyUsedToSet projectName
end menu_CopyCurrentlyUsedTo

on _
end _

on menu_SetProjectFolder  mTarget, projectName
   put merge ("Choose a folder for project '[[projectName]]'...") into someComment
   answer folder someComment
   put it into projectFolder
   if projectFolder is empty then exit to top
   
   put project_NameFromFolder (projectFolder) into testProjectName
   if testProjectName is not projectName then
      answer warning "A project folder must be named the same as the project name!"
      exit to top
   end if
   
   put project_SearchForProjectFolder (projectName) into testFolder
   if testFolder is empty then
      answer warning "A stack with the same as the project does not exist!"
      exit to top
   end if
   
   if testFolder is not projectFolder then
      answer warning "A project folder must have a stack with the same as the project at the top level of the folder!"
      exit to top
   end if
   
   library_StoreProjectFolder projectName, projectFolder
   put merge ("Setr project '[[projectName]]'...") into someComment
   answer someComment
end menu_SetProjectFolder


--> Global | Library | Set | Menu | Props
-
getprop goodProjectName
   return project_GetCurrentName()
end goodProjectName

getprop good_ProjectNames
   return library_ListProjectNames ()
end good_ProjectNames

getprop project_Name
   return project_GetCurrentName()
end project_Name

getprop project_Names
   return library_ListProjectNames (true)
   -- & ",-,Add"
   -- put CR & "None" after setNames
end project_Names


--> Deps
-
function project_ConstructArray projectName, projectFolder, pUsedStacks, pStackFiles, pImportantStackNames
   -- was "library_ConstructMenuSetArray"
   put projectFolder into projectArray ["projectPrefsArray"]["gPrefs_Array"]["libraryRepoFolder"]
   put projectName into projectArray ["metadata"]["library_SetName"]
   
   put pImportantStackNames into projectArray ["openStacks"]
   
   put pStackFiles into projectArray ["data"]["stackfiles"]
   put pUsedStacks into projectArray ["data"]["used"]
   return projectArray
end project_ConstructArray

