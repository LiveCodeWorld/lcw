script "Global_GIT_Status_Menu"
--> MetaData
-
license: GPLv3
name: Global_GIT_Status_Menu
type: controller
copyright: David Bovill
license: GPLv3
version: 0.1


--> Menu | Props
-
getprop menu_Version
   return 1
end menu_Version

getprop menu_Target [mTitlePath]
   if mTitlePath contains "Global | Git | Stack | Menu" then
      return the displayed_Object of me
   else if mTitlePath contains "GIT | Line | Menu" then
      put the git_Tree of me into cardTree
      put the tree_SelectedIndex of cardTree into relPathLine
      set the itemdelimiter to ":"
      switch item 1 of relPathLine
         case "unmerged"
            delete item 1 of relPathLine
            put word 1 to -1 of relPathLine into shortFile
            return git_GetRootFolder() & shortFile
         case "new file"
            delete item 1 of relPathLine
            put word 1 to -1 of relPathLine into shortFile
            return git_GetRootFolder() & shortFile
      end switch
   else
      pass menu_Target
   end if
end menu_Target

getprop menu_Title
   put the view_Name of the target into vName
   -- if the controlkey is "Down" then
   if vName = "View|Tree|Field" then
      put the card_Tree of me into cardTree
      put the title_Text of cardTree into treeTitle
      set the itemdelimiter to ":"
      switch
         case item 1 of treeTitle = "Found Log"
            return "GIT | Line | Found | Menu"
         case treeTitle = "Files in Repository"
            return "GIT | Line | Files | Menu"
         case item 1 of treeTitle = "Stack Log for"
            return "GIT | Line | Stack | Log | Menu"
         case treeTitle = "Log"
            return "GIT | Line | Log | Menu"
         default
            put the tree_Field of cardTree into treeField
            if the tree_IsLeaf of treeField is true then
               put the tree_ParentTitle of treeField into treeParentTitle
               switch word 1 of treeParentTitle
                  case "Changes"
                     return "GIT | Line | Changes | Menu"
                  case "Changed"
                     return "GIT | Line | Changed | Menu"
                  case "Untracked"
                     return "GIT | Line | Untracked | Menu"
                  default
                     return "GIT | Line | Menu"
               end switch
            else
               switch word 1 of the tree_SelectedIndex of treeField
                  case "Changes"
                     return "GIT | Line | Changes | Menu"
                  case "Changed"
                     return "GIT | Line | Changed | Menu"
                  case "Untracked"
                     return "GIT | Line | Untracked | Title | Menu"
               end switch
            end if
      end switch
   else
      return "Global | GIT | Status | Menu"
   end if
end menu_Title


--> Global | GIT | Status | Menu
-
on menu_GitDocumentation mTarget, menuChoice
   switch menuChoice
      case "Crash course"
         launch url "http://git.or.cz/course/svn.html"
         break
      case "Git Wiki"
         launch url "http://git.or.cz/gitwiki/GitDocumentation"
         break
      case "Git User manual"
         launch url "http://www.kernel.org/pub/software/scm/git/docs/user-manual.html"
         break
   end switch
end menu_GitDocumentation

getprop menu_Choices
   return "Crash course,Git Wiki,Git User manual"
end menu_Choices

on menu_DisplayStatus
   display_GitStatus
end menu_DisplayStatus

on menu_AddAllUntracked
   put the shiftKey is "Down" into shiftStatus
   set the cursor to watch
   put "git add --all" into someShell
   put git_ExecuteShellCommand (someShell) into shellResult
   opn_Notify shellResult, true
   if shiftStatus is false then git_RefreshDisplay
end menu_AddAllUntracked

on menu_StageThenCommit
   put the shiftKey is "Down" into shiftStatus
   put opn_Ask("Comment on this change...") into someComment
   git_CommitChanges someComment, true
   opn_Notify the result, true
   if shiftStatus is false then display_GitStatus
end menu_StageThenCommit

on menu_AddChangesToStage
   git_AddChanged
   display_GitStatus
end menu_AddChangesToStage

on _
end _

on menu_PushCurrentBranch
   -- TO push THE new BRANCH TO A REMOTE REPOSITORY
   
   set the cursor to watch
   put git_CurrentBranchName() into currentBranchName
   put "git push origin" && kwote(currentBranchName) into someShell
   
   put git_ExecuteShellCommand(someShell) into shellResult
   
   switch
      case shellResult begins with "Broken pipe"
         break
      case token 1 of shellResult = "Error"
         /*
         ERROR: Your account is disabled. Please see https://github.com/account/billing
         fatal: Could not read from remote repository.
         
         Please make sure you have the correct access rights
         and the repository exists.
         */
         put "Check billing" into btnText
         answer shellResult with btnText or "Cancel"
         if it is btnText then
            launch url "https://github.com/account/billing"
         end if
         break
      default
         opn_Notify shellResult, true
         display_GitStatus
   end switch
end menu_PushCurrentBranch

on menu_Pull
   -- TO PULL A new BRANCH FROM A REMOTE REPOSITORY
   -- put merge("git pull origin [[remoteBranch]]:[[newLocalBranch]]") into someShell
   -- put "git pull" into someShell
   -- put "git pull origin master" into someShell
   put git_CurrentBranchName() into currentBranchName
   put "git pull origin" && kwote(currentBranchName) into someShell
   
   put git_ExecuteShellCommand(someShell) into shellResult
   display_Lines shellResult, someShell
   
   stack_RevertLoaded
   dispatch "library_StopEnvironment" to stack "OPN"
   dispatch "library_StartEnvironment" to stack "OPN"
   
   put the result into displayView
   set the menu_Title of displayView to "Global | Git | Pull | Menu"
end menu_Pull

on _
end _

on submenu_Stash
   return "Global | GIT | Stash | Menu"
end submenu_Stash

on menu_CompactGit
   put "git gc" into someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   opn_Notify shellResult, true
end menu_CompactGit

on _
end _

on submenu_Git
   return "Global | GIT | Menu"
end submenu_Git

on submenu_GitProjects
   menu_DoSub "Global | GIT | Folder | Menu"
end submenu_GitProjects

on submenu_GitSettings
   return "Global | GIT | Settings | Menu"
end submenu_GitSettings

on _
end _

on submenu_Development
   return "GIT | Dev | Menu"
end submenu_Development


--> Tree | GIT | Menu | Props
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
