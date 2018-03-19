script "Global_Library_Project_Model_Menu"
--> MetaData
-
license: GPLv3
name: Global_Library_Project_Model_Menu
type: controller
version: 0.1


--> Global | Library | Project | Model | Menu
-
on menu_CreateNewProject
   project_AskCreate
end menu_CreateNewProject

on menu_AddProject indexView
   answer folder "Select a folder containing a project..."
   put it into someFolder
   if it is empty then exit to top
   
   project_FindFromFolder someFolder, homeStackName, projectFolder, homeStackPath
   if the result is false then
      answer warning "This is not a working project folder!"
      finder_Reveal someFolder
      exit to top
   end if
   
   library_StoreProjectFolder homeStackName, projectFolder
   display_LcwProjectList
end menu_AddProject

on _
end _

on menu_ReFetchArray treeView
   put library_FetchProjectData() into libraryProjectData
   set the displayed_Array of treeView to libraryProjectData
end menu_ReFetchArray

on menu_SaveArray treeView
   put the displayed_Array of treeView into libraryProjectData
   library_StoreProjectData libraryProjectData
end menu_SaveArray

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_MassageArray treeView
   breakpoint
   put the displayed_Array of treeView into libraryProjectData
   set the itemdelimiter to slash
   repeat for each key projectName in libraryProjectData
      put libraryProjectData [projectName] into projectArray
      put projectArray ["projectFolder"] into projectFolder
      if there is not a folder projectFolder then next repeat
      
      put projectFolder into newLibraryProjectData [projectName]["projectFolder"]
      if item - 2 of projectFolder = "modules" then
         put "module" into newLibraryProjectData [projectName]["projectType"]
      else
         put "project" into newLibraryProjectData [projectName]["projectType"]
      end if
   end repeat
   library_StoreProjectData newLibraryProjectData
end menu_MassageArray

on menu_EditBehavior treeView
   edit the script of the behavior of treeView
end menu_EditBehavior


on reloadStack pStackName, pFileName
   
end reloadStack
