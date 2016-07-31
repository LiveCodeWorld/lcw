script "Global_GIT_Branch_Menu"
--> MetaData
-
license: GPLv3
name: Global_GIT_Branch_Menu
type: controller
version: 0.1


--> Global | GIT | Branch | Menu
-
on menu_CreateNewBranch
   put opn_Ask("What's the new branch name?", "test") into branchName
   put "git branch" && branchName into someShell
   opn_Notify someShell, true
   put git_ExecuteShellCommand(someShell) into shellResult
   display_Text shellResult
end menu_CreateNewBranch

on menu_SwitchLocalBranch localBranchName
   -- TO switch TO ANOTHER BRANCH
   -- The state of your file system will change after executing this command.
   
   put "git checkout" && kwote(localBranchName) into someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   opn_notify shellResult, true
end menu_SwitchLocalBranch

-- on menu_DiffLocalBranch localBranchName
   put "git diff" into someShell
   put space & "--numstat" after someShell
   -- put space & "--name-status" after someShell
   
   put git_CurrentBranchName() into currentBranchName
   
   shell_BashParamEscape currentBranchName
   shell_BashParamEscape localBranchName
   put space & currentBranchName & ".." & localBranchName after someShell
   
   put git_ExecuteShellCommand(someShell) into someTable
   put "+" & tab & "-" & tab & "relative file name" & CR before someTable
   display_Table someTable, someShell, true, true, true
   put the result into tableView
   -- set the menu_Title of 
end menu_DiffLocalBranch

on menu_DiffLocalBranch localBranchName
   put "git diff" into someShell
   -- put space & "--git-diff-index" after someShell
   put space & "--raw" after someShell
   
   put git_CurrentBranchName() into currentBranchName
   
   shell_BashParamEscape currentBranchName
   shell_BashParamEscape localBranchName
   put space & currentBranchName & ".." & localBranchName after someShell
   
   put git_ExecuteShellCommand(someShell) into rawDiff
   put git_ParseRawDiff (rawDiff) into dataArray
   
   display_Table dataArray, someShell, true, true, true, "status,srcPath,srcHash,dstHash,srcMode,dstMode,dstPath", "status,srcPath,srcHash,dstHash"
   put the result into tableView
    
   -- set the menu_Title of tableView to "Global | Git | Diff | Raw | Menu"
   set the table_BodyTitle of tableView to "Global | Git | Diff | Raw | Menu"
   -- set the table_HeaderTitle ["srcPath"] of tableView to "Global | Git | Diff | Raw | Menu"
end menu_DiffLocalBranch

on menu_MergeLocalBranch localBranchName
   put "git merge" && kwote(localBranchName) into someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   opn_notify shellResult, true
end menu_MergeLocalBranch

on menu_DeleteLocalBranch localBranchName
   put "git branch -d" && kwote(localBranchName) into someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   opn_notify shellResult, true
end menu_DeleteLocalBranch

on _
end _

on menu_RemoteBranch remoteBranchName
   put "git remote show" && remoteBranchName into someShell
   
   -- opn_Notify someShell, true
   put git_ExecuteShellCommand(someShell) into shellResult
   display_Lines shellResult, someShell
end menu_RemoteBranch

on _
end _

on menu_ViewBranches menuChoice
   switch menuChoice
      case "Local branches"
         put "git branch" into someShell
         break
      case "Local and remote brances"
         put "git branch -a" into someShell
         break
   end switch
   
   opn_Notify someShell, true
   put git_ExecuteShellCommand(someShell) into shellResult
   display_Lines shellResult
end menu_ViewBranches


--> Global | GIT | Branch | Menu | Props
-
getprop local_BranchNames
   put "git branch" into someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   
   repeat for each line someLine in shellResult
      if word 1 of someLine = "*" then
         put "(" & word 2 to -1 of someLine & CR after branchNames
         -- put word 2 to -1 of someLine & CR after branchNames
      else
         put word 1 to -1 of someLine & CR after branchNames
      end if
   end repeat
   delete char -1 of branchNames
   return branchNames
end local_BranchNames

getprop remote_BranchNames
   git_DeconstructBranchNames localBranchNames, remoteBranches, remoteNames, remoteBranchNames, remoteMappings
   -- replace "/" with "\/" in remoteBranchNames
   return remoteNames
end remote_BranchNames

getprop branch_Names
   put "git branch" into someShell
   put "git branch -a" into someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   
   repeat for each line someLine in shellResult
      if word 1 of someLine = "*" then
         put "(" & word 2 to -1 of someLine & CR after branchNames
      else
         put word 1 to -1 of someLine & CR after branchNames
      end if
   end repeat
   delete char -1 of branchNames
   return branchNames
end branch_Names


--> Dpes
-
function git_ParseRawDiff rawDiff
   set the itemdelimiter to tab
   put 1 into lineNum
   repeat for each line someLine in rawDiff
      if char 1 of someLine = ":" then
         delete char 1 of someLine
      else
         opn_Notify someLine, true
         next repeat
      end if
      
      put item 1 of someLine into firstBit
      put item 2 of someLine into srcPath
      put item 3 of someLine into dstPath
      
      put word 1 of firstBit into srcMode
      put word 2 of firstBit into dstMode
      
      put word 3 of firstBit into srcHash
      put word 4 of firstBit into dstHash
      put word 5 of firstBit into status
      
      put srcMode into dataArray [lineNum]["srcMode"]
      put dstMode into dataArray [lineNum]["dstMode"]
      put srcHash into dataArray [lineNum]["srcHash"]
      put dstHash into dataArray [lineNum]["dstHash"]
      put srcPath into dataArray [lineNum]["srcPath"]
      put dstPath into dataArray [lineNum]["dstPath"]
      put status into dataArray [lineNum]["status"]
      
      add 1 to lineNum
   end repeat
   return dataArray
end git_ParseRawDiff

command git_DeconstructBranchNames @localBranchNames, @remoteBranches, @remoteNames, @remoteBranchNames, @remoteMappings
   put "git branch -a" into someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   
   set the itemdelimiter to "/"
   repeat for each line someLine in shellResult
      put char 1 to 2 of someLine into starBit
      put char 3 to -1 of someLine into branchBit
      
      if item 1 of branchBit = "remotes" and the number of items of branchBit > 1 then
         if branchBit contains " -> " then
            put branchBit & CR after remoteMappings
         else
            put branchBit & CR after remoteBranches
            put item 2 of branchBit & CR after remoteNames
            put item 3 of branchBit & CR after remoteBranchNames
         end if
      else
         if word 1 of starBit = "*" then
            put "(" & branchBit & CR after localBranchNames
         else
            put branchBit & CR after localBranchNames
         end if
      end if
   end repeat
   delete char -1 of localBranchNames
   delete char -1 of remoteBranches
   delete char -1 of remoteNames
   delete char -1 of remoteBranchNames
   delete char -1 of remoteMappings
end git_DeconstructBranchNames

