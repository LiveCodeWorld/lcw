script "Global_GIT_Files_Menu"
--> MetaData
-
license: GPLv3
name: Global_GIT_Files_Menu
type: controller
version: 0.1


--> Global | GIT | Files | Menu
-
on menu_FilesInRepository
   set the cursor to watch
   put git_ExecuteShellCommand("git ls-files") into commitedFiles
   put file_IndexToOutline (commitedFiles, "outline") into fileOutline
   
   put fileOutline
   
   -- set the tree_Display ["Files In Repository"] of treeView to fileOutline
   -- display_Outline fileOutline
end menu_FilesInRepository

on _
end _

on menu_RenameFolder
   answer folder "Select a folder..."
   put it into sourceFolder
   if sourceFolder is empty then return empty
   
   set the itemdelimiter to "/"
   put item -1 of sourceFolder into shortDestFolder
   
   put opn_Ask ("Select a new folder name...", shortDestFolder) into shortDestFolder
   put sourceFolder into destFolder
   put shortDestFolder into item -1 of destFolder
   
   git_RenameFolder sourceFolder, destFolder
   if the result is not empty then
      opn_Notify the result, true
   else
      git_RefreshDisplay
   end if
end menu_RenameFolder

on menu_DeleteFolder
   answer folder "Choose a folder to delete..."
   put it into someFolder
   if someFolder is empty then return false 
   
   put false into pForce
   -- put "/" after someFolder
   git_DeleteFolder someFolder, pForce
   put the result into someResult
   if someResult is not empty then
      put someResult
   end if
   git_RefreshDisplay
end menu_DeleteFolder

on _
end _

on menu_DeleteFile
   answer file "Choose a file to delete..."
   put it into someFile
   if someFile is empty then return false 
   
   put false into pForce
   git_DeleteFile someFile, pForce
   git_RefreshDisplay
end menu_DeleteFile

on menu_MoveFile
   answer file "Select a repo file..."
   put it into someFile
   if someFile is empty then return empty
   
   answer folder "Select a folder to move to..."
   put it into someFolder
   if someFolder is empty then return empty
   
   set the itemdelimiter to "/"
   put item -1 of someFile into shortFile
   
   put someFolder & "/" & shortFile into newFile
   
   git_RenameFile someFile, newFile
   if the result is not empty then
      opn_Notify the result, true
   else
      git_RefreshDisplay
   end if
end menu_MoveFile

on menu_RenameFile
   answer file "Select a repo file..."
   put it into someFile
   if someFile is empty then return empty
   
   ask file "Select a new file name..." with someFile
   put it into newFile
   if newFile is empty then return empty
   
   git_RenameFile someFile, newFile
   if the result is not empty then
      opn_Notify the result, true
   else
      git_RefreshDisplay
   end if
end menu_RenameFile

on _
end _

on menu_DisplayOpnUntracked mTarget
   put git_UntrackedFiles() into untrackedFiles
   filter untrackedFiles with "opn*"
   
   put untrackedFiles
   -- set the tree_Outline of mTarget to untrackedFiles
end menu_DisplayOpnUntracked


--> Deps
-
command git_RefreshDisplay
   answer "Here we should refresh any display"
end git_RefreshDisplay

