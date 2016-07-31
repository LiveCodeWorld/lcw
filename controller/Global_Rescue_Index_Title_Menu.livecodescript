script "Global | Rescue | Index | Title | Menu"
--> MetaData
-
license: GPLv3
name: Global | Rescue | Index | Title | Menu
type: controller
version: 0.4

/*
This global menu contains the shared code for the menu of the "Title" buttons of the group "Stacks and Libraries" 
*/


--> Global | Rescue | Index | Title | Menu
-
on menu_UseAllLibs indexView, someBoolean
   put the index_LongStackFiles of indexView into longStackFiles
   
   -- temporary hack
   put the search_LongStackFile ["lib_MenuUtils"] of indexView into utilPath
   line_Delete longStackFiles, utilPath
   
   repeat for each line longStackFile in longStackFiles
      set the cursor to busy
      if someBoolean is true then
         start using stack longStackFile
      else
         stop using stack longStackFile
      end if
   end repeat
end menu_UseAllLibs

on menu_KnowAllLibs indexView
   put the index_LongStackFiles of indexView into longStackFiles
   repeat for each line longStackFile in longStackFiles
      set the cursor to busy
      set the stack_IsKnown of stack longStackFile to true
      set the stack_IsUsed of stack longStackFile to true
      go to stack longStackFile
   end repeat
   answer "Everything seems OK?"
   set the hilite_Used of me to true
end menu_KnowAllLibs

on _
end _

on menu_OpenFolder indexView
   put the index_Folder of indexView into indexFolder
   finder_Reveal indexFolder
end menu_OpenFolder

on menu_RefreshIndex indexView
   dispatch "refresh" to indexView with false
end menu_RefreshIndex

on menu_SetIndexFolder indexView
   put the index_Folder of indexView into defaultPath
   put merge ("Where is the [[groupName]] folder?") into someComment
   answer folder someComment with defaultPath
   if it is empty then exit to top
   put it into someFolder
   text_AddTrailing someFolder, slash
   
   set the index_Folder of indexView to someFolder
   -- put folder_ListShortStackFiles (someFolder) into shortStackFiles
   put folder_ListShortLivecodeFiles (someFolder) into shortStackFiles
   set the view_Index of indexView to shortStackFiles
end menu_SetIndexFolder

on _
end _

on menu_AddSelectedToProject indexView
   put the index_View of indexView into indexView
   display_AddSelectedShortFilesToUsed indexView
end menu_AddSelectedToProject

on menu_RemoveSelectedFromProject indexView
   put the index_View of indexView into indexView
   display_RemoveSelectedShortFilesFromUsed indexView
end menu_RemoveSelectedFromProject

on _
end _

on menu_MoveToNewFolder indexView
   put the lcw_FolderName of indexView into folderName -- new name
   put lcw_GetFolder (folderName) into lcwFolder
   if lcwModelFolder is empty then
      answer warning "LCW folder does not exist!"
      breakpoint
      exit to top
   end if
   
   put the index_LongStackFiles of indexView into longStackFiles
   
   set the itemdelimiter to slash
   repeat for each line longStackFile in longStackFiles
      set the cursor to busy
      if exists (stack longStackFile) is false then next repeat
      
      put the short name of stack longStackFile into stackName
      
      put item -1 of longStackFile into shortFile
      put lcwFolder & shortFile into newFile
      
      set the wholematches to true
      put stackName is among the lines of the stacksinuse into isUsed
      
      -- if isUsed is true then stop using stack stackName
      -- delete stack stackName
      -- set the stack_IsKnown of stack longStackFile to false
      rename file longStackFile to newFile
      -- set the stack_IsKnown of stack newFile to true
      -- if isUsed is true then start using stack stackName
   end repeat
   
   dispatch "refresh" to indexView
   answer "Moved everything!"
   finder_Reveal lcwFolder
end menu_MoveToNewFolder

on menu_TrashStacks indexView
   put the index_Field of indexView into indexField
   
   -- not tested
   breakpoint
   
   -- let's get basic stack and file info
   put the hilitedlines of indexField into hLineNums
   put the selected_StackObjects of indexField into stackObjects
   put the selected_ShortStackFiles of indexField into shortStackFiles
   put the selected_LongStackFiles of indexField into longStackFiles
   
   -- ask
   put shortStackFiles
   answer warning "Would you like to move the selected stacks to the trash?" with "OK" or "Cancel"
   if it is "Cancel" then exit to top
   --
   
   -- now remove
   library_RemoveStackFromAllProjects stackObjects
   
   -- and delete
   put the short id of indexField into someID
   repeat with lineNum = the number of lines of stackObjects down to 1
      put item lineNum of hLineNums into hLineNum
      delete line hLineNum of field id someID
      
      put line lineNum of stackObjects into stackObject
      put line lineNum of longStackFiles into longStackFile
      
      stop using stackObject
      delete stackObject
      delete file longStackFile
   end repeat
end menu_TrashStacks

on _
end _

on menu_HiliteUsed indexView
   set the cursor to watch
   put the used_ShortStackFiles of indexView into usedShortViewStackFiles
   set the selected_Index of indexView to usedShortViewStackFiles
end menu_HiliteUsed

on menu_HiliteAll indexView
   put the view_Index of indexView into shortFiles
   set the selected_Index of indexView to shortFiles
end menu_HiliteAll

on menu_HiliteNone indexView
   set the selected_Index of indexView to empty
end menu_HiliteNone

on _
end _

on submenu_Script
   return "Tools | Script | Menu"
end submenu_Script

on submenu_IndexView
   return "Global | Index | Simple | Menu"
end submenu_IndexView


--> Tools | Script | Menu
-
on menu_IndexGroupScript indexView
   edit the script of indexView
end menu_IndexGroupScript

on menu_IndexBehaviorScript indexView
   put the behavior of indexView into bObject
   edit the script of bObject
end menu_IndexBehaviorScript

on menu_HorizontalLayoutScript indexView
   -- View|Index|Group
   put the horizontal_Layout of indexView into layoutView
   edit the script of layoutView
end menu_HorizontalLayoutScript

on menu_HorizontalBehaviorScript indexView
   put the horizontal_Layout of indexView into layoutView
   put the behavior of layoutView into bObject
   edit the script of bObject
end menu_HorizontalBehaviorScript

on menu_VerticalLayoutScript indexView
   -- View|Index|Group
   put the vertical_Layout of indexView into layoutView
   edit the script of layoutView
end menu_VerticalLayoutScript

on menu_VerticalBehaviorScript indexView
   put the vertical_Layout of indexView into layoutView
   put the behavior of layoutView into bObject
   edit the script of bObject
end menu_VerticalBehaviorScript


--> Menu | Props
-
-- getprop menu_Target
-- also this is not called at all when a submenu
-- bug in menus - first time this menu is called mTarget is set wrong
put menu_GetTargetObject() into tObject
put the index_View of tObject into indexView
return indexView
end menu_Target


--> Deps
-
command display_AddSelectedShortFilesToUsed indexView, pShortFiles
   if pShortFiles is empty then
      put the selected_Index of indexView into pShortFiles
   end if
   
   put the displayed_Project of indexView into projectName
   put the index_Folder of indexView into indexFolder
   
   repeat for each line shortFile in pShortFiles
      set the cursor to busy
      put indexFolder & shortFile into longStackFile
      
      try
         put the name of stack longStackFile into stackObject
         start using stackObject 
         library_AddUsedStack stackObject, projectName
      catch e
         put stackObject
         breakpoint 
      end try
   end repeat
   
   dispatch "refresh" to indexView
end display_AddSelectedShortFilesToUsed
