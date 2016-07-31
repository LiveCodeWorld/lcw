script "Global_GIT_Script_Menu"
--> MetaData
-
license: GPLv3
name: Global_GIT_Script_Menu
type: controller
copyright: David Bovill
license: GPLv3
version: 0.2


--> Menu | Props
-
local LocalArray

on menu_Init targetObject, mPath, mTitlePath
   put rev_ScriptObject() into scriptObject
   
   put scriptObject into LocalArray ["scriptObject"]
   put the script_File of scriptObject into LocalArray ["scriptFile"]
   put the git_CheckoutFolder of scriptObject into LocalArray ["checkoutFolder"]
   
   put the overlay_Folder of scriptObject into overlayFolder
   -- put overlay_ListNames (overlayFolder) into LocalArray ["overlayNames"]
end menu_Init

getprop menu_Target [mTitlePath]
   return LocalArray ["scriptObject"]
end menu_Target

getprop menu_CheckTarget [scriptObject]
   -- should maybe check folder as script could be empty? 
   put LocalArray ["scriptFile"] into scriptFile
   put there is a file scriptFile into fileExists
   return fileExists
end menu_CheckTarget


--> Global | GIT | Script | Menu
-
on insert_Gist
   return "Global | Gist | Menu"
end insert_Gist

on _
end _

on menu_GitStatus scriptObject
   put the git_CheckoutFolder of scriptObject into checkoutFolder-- LocalArray ["checkoutFolder"]
   put git_FetchStatusTable (checkoutFolder) into gitTable
   put git_ConstructStatusOutline(gitTable, pTreeTitle, gitHelp) into someOutline
   
   put someOutline
   
   /*
   display_Outline someOutline, "Git Status", "Global | GIT | Status | Menu"
   put the result into treeView
   set the displayed_CheckoutFolder of treeView to checkoutFolder
   */
end menu_GitStatus

on menu_CompareWithLastCommit scriptObject
   put the exported_Script of scriptObject into exportedScript
   put the git_LastCommit of scriptObject into lastCommitedText
   terminal_Diff lastCommitedText, exportedScript, "git_LastCommit", "exported_Script"
end menu_CompareWithLastCommit

on menu_RevertToLastRevision scriptObject
   put the git_LastRevision of scriptObject into previousScript
   rev_SetScriptEditorField previousScript
   
   -- rev_ActivateScriptEditorTab scriptObject, previousScript
   -- display_Lines previousScript
   put the mobile_Name of scriptObject into mObject
   put "Copied previous script to the script editor of" && mObject & ". Apply changes to save them!" into someComment
   opn_Notify mObject, true
end menu_RevertToLastRevision

on menu_DisplayScriptLog scriptObject
   set the cursor to watch
   display_GitScriptLog scriptObject
end menu_DisplayScriptLog

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | GIT | Script | Menu | Props
-
--> Global | GIT | Script | Menu | Disabled
-
getprop disabled_CompareWithLastCommit [scriptObject]
   return LocalArray ["checkoutFolder"] is empty
end disabled_CompareWithLastCommit

getprop disabled_RevertToLastRevision [scriptObject]
   return LocalArray ["checkoutFolder"] is empty
end disabled_RevertToLastRevision

getprop disabled_DisplayScriptLog [scriptObject]
   return LocalArray ["checkoutFolder"] is empty
end disabled_DisplayScriptLog

-- getprop disabled_RevertToLastRevision [scriptObject]
   if there is a file LocalArray ["scriptFile"] then
      return false
   else
      return true
   end if
end disabled_RevertToLastRevision


--> Dev | Menu
-
/*
was "Global | Git | Line | Log | Menu"

A menu for interacting with lines of a git file display tree_Field.

The tree_View requires the properties: displayed_File
which are set by the "display_GitFileHistory handlerFile, someTitle, pDoubleUpThing" command.

   lock messages
   set the displayed_Hkey of treeView to hKey
   set the displayed_Object of treeView to hObject
   set the displayed_File of treeView to handlerFile
   unlock messages
*/

on menu_DisplayHead treeField
   put the displayed_File of treeField into relativeFile
   put "HEAD:" & relativeFile into treeish
   put git_Show (treeish)
end menu_DisplayHead

on menu_DisplayPreviousHead treeField
   put the displayed_File of treeField into relativeFile
   put "HEAD^:" & relativeFile into treeish
   put git_Show (treeish)
end menu_DisplayPreviousHead

on menu_DisplayRevision treeField
   put the displayed_File of treeField into relativeFile
   put the tree_SelectedLink of treeField into cHash
   put cHash & ":" & relativeFile into treeish
   
   put git_Show (treeish) into someData
   
   put data_DuckType (someData) into dataType
   switch dataType
      case "livecode"
         put the displayed_File of treeField into relativeFile
         put rev_PluginFullPath (relativeFile) into someFile
         
         lock messages
         delete stack someFile
         unlock messages
         wait for messages
         go to stack someData
         if the result is not empty then opn_Notify the result, true
         break
      default
         put the stack_object of treeField into displayStack
         if the label of displayStack = "Script Log" then
            put the displayed_Object of treeField into displayedObject -- should be
            
            put the selectedtext of treeField into commitComment
            put "Revision" && cHash && ":  of" && displayedObject into someTitle
            put CR & "Script file:" && relativeFile after someTitle
            
            put someData into someScript
            display_Script someScript, someTitle
            
            display_Text someData, someTitle
         else
            put the selectedtext of treeField into someTitle
            text_UnixToMac someData
            display_Text someData, someTitle
         end if
   end switch
end menu_DisplayRevision

on menu_DisplayHashHistory treeField
   put the tree_SelectedLink of treeField into gitHash
   put git_GetRevisionHistory (gitHash) into logText
   display_Lines logText
end menu_DisplayHashHistory

on _
end _

on menu_UnixDiff treeField
   put the tree_SelectedLink of treeField into gitHash
   put merge("git diff [[gitHash]]") into someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   text_UnixToMac shellResult
   
   display_Text shellResult
end menu_UnixDiff

on menu_ShowPatch treeField
   put the tree_SelectedLink of treeField into gitHash
   put "git log -p" && gitHash into someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   display_Lines shellResult
end menu_ShowPatch

on _
end _

on menu_AmmendCommitMessage
   /*
   In my workflow I try to use the index (staging area) and last commit efficiently. 
   Very often I will commit something partially working with a "work in progress" commit message to tell myself that I am not done. 
   As I work I will git commit --amend to that commit.
   It may look like:
   
   # hack hack hack
   git add foo.c
   git commit -m"WIP: hacking on this and that"
   
   # hack hack hack
   git add -p bar.c
   git commit --amend
   
   I have typed git commit --amend a lot. Typing it is not so bad, but this command also invokes an editor. 
   Most of the time, I am not interested in what the editor is there for -- to update the commit message.
   Enter git amend:
   
   git config --global alias.amend 'commit --amend -C HEAD'
   
   This alias adds a git amend command that will reuse the current commit message when it amend it.
   It's the little things :)
   */
   
   put "git commit --amend" into someShell
   put empty into oldMessage
   put opn_Ask ("Change commit message...", oldMessage) into newMessage
   put space & "-m" && kwote(newMessage) after someShell
   put git_ExecuteShellCommand (someShell)
end menu_AmmendCommitMessage


--> Global | GIT | Line | Log | Menu | Props
-
private function _GetSelectedTreeIsh treeField
   put the displayed_File of treeField into someFile
   put the tree_SelectedLink of treeField into cHash
   put cHash & ":" & someFile into treeish
   return treeish
end _GetSelectedTreeIsh

