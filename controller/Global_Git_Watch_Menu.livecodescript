script "Global | Git | Watch | Menu"
--> MetaData
-
license: GPLv3
name: Global | Git | Watch | Menu
type: controller
version: 0.1


--> Global | Git | Watch | Menu
-
on insert_GitCommon
   return "Global | ScriptEditor | Watch | Menu"
end insert_GitCommon

on _
end _

on submenu_LocalMenus
   return "Global | Menu | Substack | Menu"
end submenu_LocalMenus

on menu_CutMenu mTarget, scriptMenuTitle
   get "Are you sure you want to cut the menu suites from this script? The suites will be places onto the clipboard, and you can undo the action using the undo button of the Script Editor?"
   opn_Answer it
   
   put rev_ScriptObject() into mController
   put the script of mController into someScript
   
   menu_DeleteTitleSuites scriptMenuTitle, someScript
   put the result into menuScriptSuites
   set the clipboarddata to menuScriptSuites
   
   rev_SetScriptEditorField someScript
   opn_Notify "Copied menu script suites for" && kwote (scriptMenuTitle) && "to clipboard!", true
   return menuScriptSuites
end menu_CutMenu

on _
end _

on submenu_ScriptExport
   return "Global | Script | Exported | Menu"
end submenu_ScriptExport

on submenu_Mainstack
   return "Global | Script | Mainstack | Menu"
end submenu_Mainstack

on submenu_Behavior
   return "Global | Script | Behavior | Menu"
end submenu_Behavior

on submenu_ScriptBehavior
   return "Global | Dependency | Behavior | Menu"
end submenu_ScriptBehavior

on _
end _

on insert_History
   return "Global | GIT | Script | Menu"
end insert_History

on _
end _

on submenu_Template
   return "Global | Script | Template | Menu"
end submenu_Template

on submenu_ScriptArray
   return "Global | Script | Array | Menu"
end submenu_ScriptArray

on submenu_Dependencies
   return "Global | Script | Dependency | Menu"
end submenu_Dependencies

on _
end _

on submenu_Library
   return "Global | Library | Menu"
end submenu_Library

on submenu_ManageLibrary
   return "Global | Library | Manage | Menu"
end submenu_ManageLibrary

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on submenu_Exported
   return "Global | Script | Exported | Menu"
end submenu_Exported

on submenu_Patch
   return "Global | Script | Patch | Menu"
end submenu_Patch

on menu_PreviousScriptCommit scriptObject, previousNum
   put the script_RelativeFile of scriptObject into relativeFile
   
   -- put "HEAD:" & relativeFile into treeish
   -- put "HEAD^:" & relativeFile into treeish
   put "HEAD@{" & previousNum & "}:" & relativeFile into treeish
   
   put git_Show (treeish) into previousScript
   put git_GetCommitFileHash (relativeFile, previousNum) into commitHash
   
   script_CreateAndEditHashCard previousScript
end menu_PreviousScriptCommit

on _
end _

on menu_CompareTest mTarget, menuChoice
   set the cursor to watch
   put the script of mTarget into nowScript
   
   switch menuChoice
      case "exported_Script vs git_LastCommit"
         put the exported_Script of mTarget into exportedScript
         put the git_LastCommit of mTarget into lastCommitedText
         -- put the git_LastScript [0] of mTarget into lastCommitedText
         terminal_Diff lastCommitedText, exportedScript, "git_LastCommit", "exported_Script"
         break
      case "git_LastScript [1] vs exported_Script"
         put the git_LastScript [1] of mTarget into previousScript
         put the exported_Script of mTarget into exportedScript
         terminal_Diff previousScript, exportedScript, "git_LastScript [1]", "exported_Script"
         break
      case "exported_Script vs the script of"
         put the exported_Script of mTarget into exportedScript
         terminal_Diff exportedScript, nowScript, "exported_Script", "Objects script"
         break
   end switch
end menu_CompareTest

on _
end _

on menu_AddFileToGit scriptObject
   if the git_FileIsTracked of scriptObject is true then
      answer warning "File already tracked!"
      return false
   end if
   
   set the git_FileIsTracked of scriptObject to true
   
   put the mobile_Name of scriptObject into paramArray ["mobileObject"]
   put "Added script file for [[mobileObject]] to GIT!" into someText
   opn_Notify someText, false, paramArray
end menu_AddFileToGit

on menu_CommitScript mTarget   
   put the script_File of mTarget into someFile
   put the script of mTarget into someScript
   put someScript into url ("binfile:" & someFile)
   
   put the script_CommitComment of mTarget into commitComment
   git_CommitFile someFile, commitComment, true, true
   put the result into commitResult
   display_Lines commitResult
end menu_CommitScript

on _
end _

on menu_AllTheLastChanges
   put merge ("git diff HEAD^ HEAD") into someShell
   put git_ExecuteShellCommand (someShell) into shellResult
   display_Lines shellResult
end menu_AllTheLastChanges


--> Dev | Menu | Props
-
getprop previous_Nums
   return "1,2,3,4,5,6,7,8,9"
end previous_Nums


--> Dev | Menu | Disabled
-
getprop disabled_ReExport [mTarget]
   if the script_IsDifferent of mTarget is true then
      return false
   else
      return true
   end if
end disabled_ReExport
