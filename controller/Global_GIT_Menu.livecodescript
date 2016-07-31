script "Global_GIT_Menu"
--> MetaData
-
license: GPLv3
name: Global_GIT_Menu
type: controller
version: 0.1


--> Global | GIT | Menu
-
on menu_ShowStackLog mTarget, someName
   put menu_GetGlobalController("Global | Git | Stack | Menu") into mController
   dispatch "menu_StackLog" to mController with (the name of stack someName)
end menu_ShowStackLog

on menu_StackHistory scriptObject
   display_StackHistory scriptObject
end menu_StackHistory

on menu_OpenRevision scriptObject, backNum
   put the stack_RelativeFile of scriptObject into relativePath
   put git_GetCommitFileHash (relativePath, backNum) into commitHash
   if commitHash is empty then
      answer warning "Cannot find commit hash for this stack!"
      exit to top
   end if
   
   git_DisplayTempStackRevision scriptObject, commitHash
end menu_OpenRevision

getprop back_Nums
   return "1,2,3,4,5,6"
end back_Nums

on _
end _

on menu_Gitk mTarget, menuChoice
   switch menuChoice
      case "gitk"
         put "gitk" into someShell
         break
      case "all branches"
         put "gitk --all" into someShell
         break
   end switch
   put git_ExecuteShellCommand(someShell) into shellResult
   return shellResult
end menu_Gitk

on menu_ResetHard
   git_HardReset
end menu_ResetHard

on menu_SaveAndCompactMemoryStacks
   stack_SaveLoaded
end menu_SaveAndCompactMemoryStacks

on _
end _

on menu_Search mTarget, menuChoice
   local pTreeMenuTitle, pTreeLineMenuTitle
   
   put the search_Term of me into searchTerm
   put opn_Ask("Search log for string...", searchTerm) into searchTerm
   set the search_Term of me to searchTerm
   
   switch menuChoice
      case "Commit history"
         put git_SearchLog (searchTerm) into foundLog
         put git_LogLinkOutline (foundLog) into someOutline
         
         -- display_Lines foundLog
         put "git log --pretty=oneline -S:" && kwote(searchTerm) into someTitle
         display_Outline someOutline, someTitle, pTreeMenuTitle, pTreeLineMenuTitle
         put the result into treeView
         put the tree_Field of treeView into treeField
         set the menu_Controller ["Log | Menu"] of treeField to the long id of me
         break
      case "Search repository"
         put git_SearchRepository (searchTerm) into foundLog
         display_Lines foundLog
         put git_LogLinkOutline (foundLog) into someOutline
         put "git grep --text -i" && kwote(searchTerm) into someTitle
         display_Outline someOutline, someTitle, pTreeMenuTitle, pTreeLineMenuTitle
         put the result into treeView
         put the tree_Field of treeView into treeField
         set the menu_Controller ["Grep | Menu"] of treeField to the long id of me
         break
   end switch
end menu_Search

on _
end _

on menu_ThrowAwayUncommittedChanges
   /*
   Note: git revert is used to record a new commit to reverse the effect of an earlier commit (often a faulty one). If you want to throw away all uncommitted changes in your working directory, you should see git-
   reset(1), particularly the --hard option. If you want to extract specific files as they were in another commit, you should see git-checkout(1), specifically the git checkout <commit> -- <filename> syntax. Take care
   with these alternatives as both will discard uncommitted changes in your working directory.
   */
   
   put "git reset --hard HEAD" into someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   git_RefreshDisplay true, "Git Status"
   
   if shellResult is not empty then
      opn_Notify shellResult, true
   end if
end menu_ThrowAwayUncommittedChanges

on menu_RevertCommit
   put "git revert --no-edit HEAD" into someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   git_RefreshDisplay true, "Git Status"
   
   if shellResult is not empty then
      beep
      opn_Notify shellResult
   end if
end menu_RevertCommit

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Menu | Props
-
--> Global | GIT | Menu | Props
-
getprop some_Names
   return stack_ListNames()
end some_Names

getprop search_Term
   return the uOPN ["search_Term"] of me
end search_Term

setprop search_Term searchTerm
   set the uOPN ["search_Term"] of me to searchTerm
end search_Term


--> Dev | Menu
-
/*
was "Global | Git | Line | Stack | Log | Menu"
*/

on menu_CloneRevertedStack treeField
   put the tree_SelectedLink of treeField into commitHash
   put the displayed_Object of treeField into stackObject
   
   git_DisplayTempStackRevision stackObject, commitHash
end menu_CloneRevertedStack

on _
end _

on menu_DiffStackBinaries treeField
   put the tree_SelectedLink of treeField into commitHash
   put the displayed_Object of treeField into stackObject
   
   put the filename of stackObject into thisFile
   put the stack_RelativeFile of stackObject into relativePath
   
   git_ExportFileRevision relativePath, commitHash
   put the result into toFile
   
   diff_Files thisFile, toFile
end menu_DiffStackBinaries

on _
end _

on menu_RevertStack treeField
   put the tree_SelectedLink of treeField into commitHash
   put the displayed_Object of treeField into stackObject
   /*
   put the stack_RelativeFile of mTarget into relativeFile
   put git_GetLastRevision (relativeFile, 1) into binaryStackData
   display_Text binaryStackData
   */
   
   -- put the long id of stackObject into stackObject
   -- delete stackObject
   git_RevertStack stackObject, commitHash
   -- go to stackObject
end menu_RevertStack

on menu_StackData treeField
   put the tree_SelectedLink of treeField into commitHash
   put the displayed_Object of treeField into stackObject
   
   put the git_StackTreeish [commitHash] of stackObject into treeish
   put "git show" && kwote (treeish) into someShell
    
   put git_ExecuteShellCommand(someShell) into shellResult
   put shellResult into stackData
   
   display_Text stackData
end menu_StackData

on _
end _

on menu_DisplayCommitInfo treeField
   put the tree_SelectedLink of treeField into commitHash
   put git_HashInfo (commitHash) into hashInfo   
   put "git show" && kwote (commitHash) into someShell
   display_Text hashInfo, someShell
end menu_DisplayCommitInfo

on menu_ListCommitInfo treeField
   put the tree_SelectedLink of treeField into commitHash
   put the displayed_Object of treeField into stackObject
   
   put git_List (commitHash) into logText
   
   put "git ls-tree" && commitHash into someShell
   display_Lines logText, someShell
end menu_ListCommitInfo

on menu_StackHashLog treeField
   -- a log of all the previous commits of a version specified by commitHash
   put the tree_SelectedLink of treeField into commitHash
   put the displayed_Object of treeField into stackObject
   
   put the git_StackHashLog [commitHash] of stackObject into logText
   
   display_Lines logText, ("the git_ObjectHashLog [" & commitHash & "] of" && stackObject)
end menu_StackHashLog


--> Dev | menu | Props
-
/*
Global | Git | Line | Stack | Log | Menu | Props
*/

getprop stack_Hashs [mTarget]
   put the stack_RelativeFile of mTarget into relativePath
   return git_ReverseFileHashes (relativePath)
end stack_Hashs

getprop back_Hashs [mTarget]
   put the script_RelativeFile of mTarget into relativePath
   return git_ReverseFileHashes (relativePath)
end back_Hashs

getprop back_Nums
   return "0,-,1,2,3,4,5,6,7,8,9"
end back_Nums


--> Sketches
-
command display_GitFile relativePath, commitHash
   git_ExportFileRevision relativePath, commitHash
   put the result into tempFile
   -- edit_TextFile tempFile
   launch document tempFile
end display_GitFile
