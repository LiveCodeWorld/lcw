script "Global_GIT_Stash_Menu"
--> MetaData
-
license: GPLv3
name: Global_GIT_Stash_Menu
type: controller
version: 0.1


--> Menu | Target
-
local StashNames

getprop menu_CheckTarget
   put git_ListStashes() into StashNames
   return true
end menu_CheckTarget


--> Global | GIT | Stash | Menu
-
/*
git stash list [<options>] 
git stash show [<stash>] 
git stash drop [-q|--quiet] [<stash>] 
git stash ( pop | apply ) [--index] [-q|--quiet] [<stash>] 
git stash branch <branchname> [<stash>] 
git stash [save [--patch] [-k|--[no-]keep-index] [-q|--quiet] [<message>]] 
git stash clear 
git stash create
*/

on menu_Stash
   git_ExecuteShell "git stash"
   git_RefreshDisplay
end menu_Stash

on menu_PopStash
   git_ExecuteShell "git stash pop"
   git_RefreshDisplay
end menu_PopStash

on _
end _

on menu_ShowStash stashName
   /*
   show [<stash>]
   
   Show the changes recorded in the stash as a diff between the stashed state and its original parent. 
   When no <stash> is given, shows the latest one. By default, the command shows the diffstat, 
   but it will accept any format known to git diff (e.g., git stash show -p stash@{1} to view the second most recent stash in patch form).
   */
   
   put "git stash show" into someShell
   -- put space & "-p " after someShell
   put space & "--numstat " after someShell
   put space & stashName after someShell
   git_ExecuteShell someShell
   put the result into gitResult
   
   put git_ParseShowStash (gitResult) into someOutline
   
   display_Outline someOutline, stashName, "Global | GIT | Stash | Menu", "Global | GIT | Stash | Line | Menu", 2
end menu_ShowStash

on menu_DropStash stashName
   /*
   drop [-q|--quiet] [<stash>]
   
   Remove a single stashed state from the stash list. 
   When no <stash> is given, it removes the latest one. i.e. stash@{0}, otherwise <stash> must a valid stash log reference of the form stash@{<revision>}.
   */
   
   put "git stash drop" && stashName into someShell
   git_ExecuteShell someShell
   put the result into gitResult
   
   display_Lines gitResult
end menu_DropStash

on menu_ClearStash
   git_ExecuteShell "git stash clear"
end menu_ClearStash

on _
end _

on submenu_Development
   return "Dev | Menu"
end submenu_Development


--> Dev | Menu
-
on menu_DisplayStashFile treeField
   put the title_Text of treeField into stashName
   set the tree_Delimiter of treeField to tab
   set the itemdelimiter to tab
   get the tree_SelectedPath of treeField
   put item 1 of it into someTitle
   put item 2 of it into relpath
   shell_BashParamEscape relpath
   
   put merge("git show [[stashName]]:[[relpath]]") into someShell
   git_ExecuteShell someShell
   put the result into theResult
   
   if someTitle = "Text" then
      display_Lines theResult
   else
      put git_GetRootFolder() into gitRootFolder
      put gitRootFolder & relpath into someFile
      
      -- set the itemdelimiter to "."
      if there is a stack someFile then
         put the name of stack someFile into stackObject
         git_DisplayTempStackRevision stackObject, stashName
      else
         breakPoint
      end if
   end if
end menu_DisplayStashFile

on menu_ReExportStash
   put the stack_Array of stack "libOPN_Menus stash@{0}" into stackArray
   put "libOPN_Menus" into stackName
   put the name of stack stackName into stackArray ["@manifest"]["abbreviated object"]
   put stackName into stackArray ["@manifest"]["name"]
   put the stack_RelativeFile of stack stackName into stackArray ["@manifest"]["filename"]
   -- display_Array stackArray
   stackArray_ExportAsFiles stackArray
end menu_ReExportStash

on menu_Reflog
   put "git reflog" into someShell
   -- put " --all" after someShell
   
   git_ExecuteShell someShell
   put the result into gitResult
   
   display_Lines gitResult
end menu_Reflog

on menu_StashDocs
   launch url "http://www.kernel.org/pub/software/scm/git/docs/git-stash.html"
end menu_StashDocs


--> Global | GIT | Stash | Menu | Props
-
getprop stash_Names
   return StashNames
end stash_Names


--> Global | GIT | Stash | Menu | Disabled
-
getprop disabled_ClearStash [mTarget]
   return StashNames is empty
end disabled_ClearStash

getprop disabled_PopStash [mTarget]
   return StashNames is empty
end disabled_PopStash

getprop disabled_ShowStash [mTarget]
   return StashNames is empty
end disabled_ShowStash

getprop disabled_DropStash [mTarget]
   return StashNames is empty
end disabled_DropStash


--> Global | GIT | Stash | Menu | Deps
-
function git_ParseShowStash gitResult
   set the itemdelimiter to tab
   put "Text" & CR Into textOutline
   put "Binary" & CR Into binaryOutline
   repeat for each line someLine in gitResult
      put word 1 to -1 of item 1 of someLine into insertNum
      put word 1 to -1 of item 2 of someLine into deleteNum
      put word 1 to -1 of item 3 of someLine into relPath
      
      if insertNum is a number then
         put tab & relPath & CR after textOutline
      else
         put tab & relPath & CR after binaryOutline
      end if
   end repeat
   put textOutline & binaryOutline into someOutline
   put word 1 to -1 of someOutline into someOutline
   return someOutline
end git_ParseShowStash
