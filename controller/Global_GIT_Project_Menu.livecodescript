script "Global_GIT_Project_Menu"
--> MetaData
-
license: GPLv3
name: Global_GIT_Project_Menu
type: controller
version: 0.1


--> Menu | Props
-
local localArray


--> Global | GIT | Project | Menu
-
on menu_SwitchGitProject projectName
   set the cursor to watch
   git_SetProject projectName
   git_RefreshDisplay true, "Git Status"
   -- display_Lines longGitFolder, "GIT root folder"
end menu_SwitchGitProject

on _
end _

on menu_CloneProject
   put opn_Ask ("Enter a remote url to clone...", "https://github.com/opn/lcVCS.git") into gitURL
   git_CloneAndFetch gitURL
end menu_CloneProject

on menu_InitialiseNewProject
   answer folder "Choose Git Folder" with git_GetRootFolder()
   if the result is "Cancel" then exit to top
   put it into gitRootFolder
   
   git_InitFolder gitRootFolder
   
   display_Lines gitRootFolder, "GIT root folder"
end menu_InitialiseNewProject

on _
end _

on menu_AddExistingProject
   set the cursor to watch
   git_AddAndSetGitFolder
   put the result into longGitFolder
   
   git_RefreshDisplay true, "Git Status"
   display_Lines longGitFolder, "GIT root folder"
end menu_AddExistingProject

on menu_RemoveMissingProjects
   put git_GetProjectArray() into gitProjectArray   
   repeat for each key gitFolder in gitProjectArray
      put gitProjectArray [gitFolder]["project name"] into projectName
      if there is a folder gitFolder then next repeat
      
      put "Remove project" && kwote (projectName) into someQuestion
      answer someQuestion with "Cancel" or "OK"
      if it is "Cancel" then next repeat
      
      delete variable gitProjectArray [gitFolder]
   end repeat
   git_SetProjectArray gitProjectArray
end menu_RemoveMissingProjects


--> Global | GIT | Project | Menu | Props
-
command git_AddAndSetGitFolder pGitFolder
   if pGitFolder is empty then
      answer folder "Choose Git Folder" with git_GetRootFolder()
      if the result is "Cancel" then return empty
      put it into pGitFolder
   end if
   
   git_AddRootFolderToIndex pGitFolder
   if the result is not empty then
      opn_Notify the result, true
      exit to top
   end if
   
   git_SetRootFolder pGitFolder
   -- put the result into pGitFolder
   return pGitFolder
end git_AddAndSetGitFolder

getprop project_Name
   put git_GetRootFolder() into gitFolder
   if there is a folder gitFolder then
      set the itemDelimiter to "/"
      return item -1 of gitFolder
   else
      return "(Error:" && gitFolder
   end if
end project_Name

getprop project_Names
   put git_GetProjectArray() into gitProjectArray   
   repeat for each key gitFolder in gitProjectArray
      put gitProjectArray [gitFolder]["project name"] into projectName
      if there is a folder gitFolder then
         put projectName & CR after projectNames
      else
         if the optionKey is "Down" then
            put "Error:" && projectName & CR after projectNames
         else
            put "(Error:" && projectName & CR after projectNames
         end if
      end if
   end repeat
   delete char -1 of projectNames
   sort projectNames
   return projectNames
end project_Names


--> Dev | Menu
-
