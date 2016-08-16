script "Global | ScriptEditor | Watch | Menu"
--> MetaData
-
license: GPLv3
name: Global | ScriptEditor | Watch | Menu
type: controller
copyright: David Bovill
license: GPLv3
version: 0.8

/*
This is designed to be the main or the default menu for manipulating a script in an editor.
As such it is currently used in the Livecode IDE's script editor.
You can attach it anywhere you want. I personally add it to the Script Editors "watch" button on the top right bar of the editor.

Below we include any local variables or constants that this menu needs.
*/

local LocalArray


--> Menu | Props
-
on menu_Init
   put rev_ListEditedStackNames() into editedStacks
   repeat for each line stackName in editedStacks
      switch
         case exists (stack stackName) is false
            next repeat
         case word 1 of stackName = "Untitled"
            next repeat
         default
            put stackName & CR after goodEditedStackNames
      end switch
   end repeat
   delete char -1 of goodEditedStackNames
   put goodEditedStackNames into LocalArray ["editedStacks"]
end menu_Init

function rev_ListEditedStackNames pType
   global gREVStackStatus
   
   repeat for each key stackName in gREVStackStatus
      if exists (stack stackName) is false then next repeat
      switch pType
         case "saved"
            if gREVStackStatus [stackName] = empty then
               put "saved" into stackArray [stackName]
            end if
            break
         default
            if gREVStackStatus [stackName] = "edited" then
               put "edited" into stackArray [stackName]
            end if
      end switch
   end repeat
   return keys (stackArray)
end rev_ListEditedStackNames

getprop menu_Target [mTitlePath]
   put rev_ScriptObject() into scriptObject
   return scriptObject
end menu_Target


--> Global | ScriptEditor | Watch | Menu
-
on menu_DisplayLocalChanges scriptObject
   put the script of scriptObject into nowScript
   put the exported_Script of scriptObject into exportedScript
   terminal_Diff exportedScript, nowScript, "the exported_Script of mTarget", "the script of mTarget"
end menu_DisplayLocalChanges

on menu_RecentScripts scriptObject, recentObject
   put LocalArray ["friendlyArray"][recentObject] into someObject
   if exists (someObject) then
      edit the script of someObject
   else
      breakpoint
   end if
end menu_RecentScripts

on menu_SaveEditedStacks mTarget, editedStackName
   ide_SaveEditedStacks editedStackName
end menu_SaveEditedStacks

on _
end _

on insert_CustomMenu
   return "Global | ScriptEditor | Custom | Menu"
end insert_CustomMenu

on menu_IndexAndExportScript scriptObject
   script_UpdateAndExport scriptObject, true
end menu_IndexAndExportScript

on _
end _

on menu_Go scriptObject, whichStack
   -- bug: menu parsing of case statement is not working
   switch whichStack
      case "Rescue Livecode World"
         go to stack "Rescue Livecode World"
         break
      case "Library Manager"
         go to stack "Library Manager"
         break
      case "View Browser"
         go to stack "libOPN_ViewBrowser"
         break
      case "Display Array"
         go to stack "Display Array"
         break
      case "libOPN_Menus"
         go to stack "libOPN_Menus"
         get library_ListGlobalMenuNames()
         sort it
         display_Lines it
         break
      case "libOPN_GIT"
         go to stack "libOPN_GIT"
         break
      case "-"
      case "Go to Object"
         object_GoTo scriptObject
         break
   end switch
end menu_Go

on _
end _

on menu_SetWorkingProject mTarget, projectName
   project_SetCurrentName projectName
end menu_SetWorkingProject

on menu_DisplayProjectStacks scriptObject
   display_ProjectStacks
end menu_DisplayProjectStacks

on menu_AddStackToProject scriptObject
   put the stack_Name of scriptObject into projectStackName
   project_AddStack projectStackName
   opn_Notify merge("Added stack '[[projectStackName]]' to the project array.")
   display_ProjectStacks
end menu_AddStackToProject

on menu_StoreOpenStacks scriptObject, projectName
   put the openstacks into stackNames
   filter stackNames without "rev*"
   stack_StripUnsaved stackNames
   project_StoreImportantStacks stackNames, projectName
   display_ProjectStacks
end menu_StoreOpenStacks

on menu_StoreLoadedStacks scriptObject, projectName
   put revLoadedStacks() into stackNames
   stack_StripUnsaved stackNames
   project_StoreImportantStacks stackNames, projectName
   display_ProjectStacks
end menu_StoreLoadedStacks

getprop project_Name
   return project_GetCurrentName()
end project_Name

getprop project_Names
   return library_ListProjectNames()
end project_Names

command stack_StripUnsaved @stackNames
   repeat for each line stackName in stackNames
      if exists (stack stackName) is false then next repeat
      if the filename of stack stackName is empty then next repeat
      put stackName & CR after goodStackNames
   end repeat
   delete char -1 of goodStackNames
   sort goodStackNames
   put goodStackNames into stackNames
end stack_StripUnsaved

on menu_DisplayGlobalMenuArray
   put menu_GetGlobalArray() into globalMenuArray
   display_Array globalMenuArray, "menu_GetGlobalArray()", "Global | Menu | Global | Menu"
end menu_DisplayGlobalMenuArray

on _
end _

on submenu_Stack
   return "Global | Stack | Menu"
end submenu_Stack

on submenu_View
   return "Global | View | Authoring | Menu"
end submenu_View

on _
end _

on submenu_Script
   return "Global | Script | Menu"
end submenu_Script

on submenu_Deps
   return "Global | Script | Dep | Menu"
end submenu_Deps

on submenu_Exported
   return "Global | Script | Exported | Menu"
end submenu_Exported

on submenu_EditScripts
   return "Global | Script | Edit | Menu"
end submenu_EditScripts

on submenu_Template
   return "Global | Script | Template | Menu"
end submenu_Template

on _
end _

on submenu_Prefs
   return "Global | Pref | Menu"
end submenu_Prefs

on submenu_LivecodePrefs
   return "Global | Rev | Prefs | Menu"
end submenu_LivecodePrefs

on _
end _

on menu_FindFromKeywords
   put opn_Ask ("Input some handler names or keywords seperated by commas...", "path,array") into keywordList
   put hArray_KeywordHkeys (keywordList) into hKeys
   display_HkeyIndex hKeys
end menu_FindFromKeywords

on menu_RevealProjectFolder scriptObject
   put the project_Folder of scriptObject into projectFolder
   finder_Reveal projectFolder
end menu_RevealProjectFolder

on submenu_Snapshot
   return "Global | View | Wireframe | Menu"
end submenu_Snapshot

on _
end _

on submenu_Gist
   return "Global | Gist | Menu"
end submenu_Gist

on submenu_Git
   return "Global | GIT | Menu"
end submenu_Git

on submenu_GitScript
   return "Global | GIT | Script | Menu"
end submenu_GitScript

-- on submenu_GitFiles
   return "Global | GIT | Files | Menu"
end submenu_GitFiles

on _
end _

on submenu_Create
   return "Global | ScriptEditor | Create | Menu"
end submenu_Create

on submenu_Behavior
   return "Global | Behavior | Menu"
end submenu_Behavior

on submenu_Hacks
   return "Global | IDE | Menu"
end submenu_Hacks

on _
end _

on menu_SetMenu mTarget, mTitle
   set the ide_RecentChangesMenuMenuTitle of mTarget to mTitle
end menu_SetMenu

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | ScriptEditor | Watch | Menu | Props
-
getprop m_Title
   return ide_RecentChangesShortTitle()
end m_Title

getprop m_Titles
   return ide_RecentChangesShortTitles()
end m_Titles

getprop project_StackNames
   put project_FetchValue ("openStacks") into stackNames
   return stackNames
end project_StackNames

getprop which_Stacks
   return "Rescue Livecode World,Library Manager,View Browser,Display Array,libOPN_Menus,libOPN_GIT,-,Go to Object"
end which_Stacks

getprop edited_StackNames
   put LocalArray ["editedStacks"] into editedStacks
   if editedStacks is empty then
      return empty
   else
      return editedStacks & ",-,Save All"
   end if
end edited_StackNames

getprop recent_Objects
   put rev_GetScriptEditorHistoryObjects() into historyObjects
   objects_MakeFriendly historyObjects, orderedFriendlyObjects, friendlyArray
   put friendlyArray into LocalArray ["friendlyArray"]
   return orderedFriendlyObjects
end recent_Objects


--> Global | ScriptEditor | Watch | Menu | Disabled
-
getprop disabled_Dev
   if the optionKey is "Down" then
      return false
   else
      return "delete"
   end if
end disabled_Dev

getprop disabled_SaveEditedStacks
   put LocalArray ["editedStacks"] into editedStacks
   return editedStacks is empty
end disabled_SaveEditedStacks

getprop disabled_DisplayLocalChanges [scriptObject]
   if the script_IsDifferent of scriptObject is true then
      return false
   else
      return true
      return "delete"
   end if
end disabled_DisplayLocalChanges


--> Deps
-
private command _safeGoProjectStack projectStackName
   if exists (stack projectStackName) then
      go to stack projectStackName
      show stack projectStackName
   else
      answer merge ("Cannot locate stack '[[projectStackName]]'")
      put projectStackName
   end if
end _safeGoProjectStack

command terminal_Diff thisText, lastText, pThisShortFile, pLastShortFile
   -- from "libOPN_PatchAndDiff"
   
   if pThisShortFile is empty then put "this.txt" into pThisShortFile
   if pLastShortFile is empty then put "last.txt" into pLastShortFile
   
   put specialfolderpath ("Desktop") into desktopFolder
   put desktopFolder & "/OPN/Temp/Compare/" into compareFolder
   folder_CreateNested compareFolder
   
   put compareFolder & pThisShortFile into thisFile
   put compareFolder & pLastShortFile into lastFile
   
   diff_CreateTempFile thisText, pThisShortFile
   put the result into thisFile
   
   diff_CreateTempFile lastText, pLastShortFile
   put the result into lastFile
   
   diff_Files thisFile, lastFile
   return the result
end terminal_Diff

command diff_CreateTempFile someText, shortFile
   -- from "libOPN_PatchAndDiff"
   
   put specialfolderpath ("Desktop") into desktopFolder
   put desktopFolder & "/OPN/Temp/Compare/" into compareFolder
   folder_CreateNested compareFolder
   
   put compareFolder & shortFile into someFile
   put someText into url ("binfile:" & someFile)
   return someFile
end diff_CreateTempFile

command diff_Files thisFile, lastFile
   -- from "libOPN_PatchAndDiff"
   
   put "opendiff" into someShell
   -- put "sdiff" into someShell
   put space & kwote(thisFile) && kwote(lastFile) after someShell
   put shell (someShell) into shellResult
   return shellResult
end diff_Files

command folder_CreateNested @someFolder
   text_AddTrailing someFolder, slash
   if there is a folder someFolder then return empty
   set the itemdelimiter to "/"
   repeat with itemNum = 1 to the number of items of someFolder
      put item 1 to itemNum of someFolder & "/" into testFolder
      if there is a folder testFolder then next repeat
      create folder testFolder
   end repeat
end folder_CreateNested

command text_AddTrailing @someText, someChar
   if char -1 of someText is not someChar then
      put someChar after someText
   end if
end text_AddTrailing

command objects_MakeFriendly someObjects, @orderedFriendlyObjects, @friendlyArray
   repeat for each line someObject in someObjects
      put the long id of someObject into longIDObject
      put object_MakeFriendly (longIDObject) into friendlyObject
      put longIDObject into friendlyArray [friendlyObject]
      put friendlyObject & CR after orderedFriendlyObjects
   end repeat
   delete the last char of orderedFriendlyObjects
end objects_MakeFriendly

function object_MakeFriendly scriptObject
   -- same as Script Editor" function "seFriendlyObject"
   put word 1 of the name of scriptObject & space into tFriendlyName
   
   if the name of scriptObject is the short name of scriptObject then
      -- This means that the object essentially has no name, eg its name is: card id 1002 or similar.
      put word -1 of the short name of scriptObject after tFriendlyName
   else
      put quote & the short name of scriptObject & quote after tFriendlyName
   end if
   return tFriendlyName
end object_MakeFriendly


--> Dev | Menu
-
on submenu_ProjectTools
   return "Global | Project | Menu"
end submenu_ProjectTools

on submenu_Library
   return "Global | Library | Menu"
end submenu_Library

on submenu_ManageLibrary
   return "Global | Library | Manage | Menu"
end submenu_ManageLibrary

on submenu_Archive
   return "Global | OPN | Save Count | Menu"
end submenu_Archive

on submenu_Mainstack
   return "Global | Script | Mainstack | Menu"
end submenu_Mainstack

on _
end _

on submenu_Teamster
   return "Global | Teamster | Menu"
end submenu_Teamster

on submenu_TextStack
   return "Global | Object | Export | Test | Menu"
end submenu_TextStack
