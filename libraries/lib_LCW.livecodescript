script "lib_LCW"
--> MetaData
-
license: GPLv3
name: lib_LCW
type: library
version: 0.7

/*
Here we place all the handlers that need to be in use before project initialisation.
*/


--> Working On
-
command lcw_LoadCustomUserProject
   -- no longer seems to be called
   put lcw_UserProjectFolder() into lcwUserProjectFolder
   project_InitialiseFolder lcwUserProjectFolder
   
   put lcw_UserHomeStackName() into userHomeStackName
   put lcw_UserProjectFolder() into lcwUserProjectFolder
   library_StoreProjectFolder userHomeStackName, lcwUserProjectFolder 
   
   dispatch "project_Init" to stack userHomeStackName
end lcw_LoadCustomUserProject

function project_ConstructFolder shortFolder, projectFolderOrHomeStackFile
   if char -1 of projectFolderOrHomeStackFile is not slash then
      -- assumes if it does not end with "/" it is a file
      -- should not need / do this
      set the itemdelimiter to slash
      put empty into item -1 of projectFolderOrHomeStackFile
   end if
   put projectFolderOrHomeStackFile into standardFolder
   if shortFolder is not empty then put shortFolder & slash after standardFolder
   return standardFolder
end project_ConstructFolder


--> Events
-
on revEditScript
   -- sent by Livecode to registered plugins
   -- this is a hack to fix the losing of the behavior we add to the script editor handler list field.
   -- beep
   rev_AddBehaviorHacks
   pass revEditScript
end revEditScript


--> Working On | Display
-
/*
Move these to a separate library, or remove all platform dependencies.
*/

command display_Loading projectName, pComment
   -- should change to display status in the home stack
   if pComment is empty then
      put merge ("Loading project '[[projectName]]'..."), "Loading projects" into pComment
   end if
   
   try
      lcw_Notify pComment
   catch e
      put pComment
   end try
end display_Loading

command lcw_Notify someMessage, pTitle
   -- needs to work cross platform
   try
      if pTitle is empty then put "LiveCode World Notification" into pTitle
      put "osascript -e" && "'" & "display notification" && quote & someMessage & quote into someShell
      put "with title" && quote & pTitle & quote after someShell
      put "'" after someShell
      put shell (someShell) into shellResult
   catch e
      put someComment
   end try
end lcw_Notify

command lcw_WarnAndExit someComment, pAsSheet
   beep
   if pAsSheet is false then
      answer warning somecomment
   else
      answer warning somecomment as sheet
   end if
   
   exit to top
end lcw_WarnAndExit

command lcw_Answer someQuestion, pButtonName
   if pButtonName is empty then put "OK" into pButtonName
   
   answer someQuestion with "Cancel" or "OK"
   put it into theResult
   if theResult is "Cancel" then exit to top
   return theResult
end lcw_Answer

command lcw_AnswerWarning someQuestion, pButtonName
   if pButtonName is empty then put "OK" into pButtonName
   
   answer warning someQuestion with pButtonName as sheet
   put it into theResult
   if theResult is "Cancel" then exit to top
   return theResult
end lcw_AnswerWarning

command lcw_AnswerSheet someQuestion, pButtonName, pWarning
   -- can be used with dispatch
   -- dispatch "lcw_AnswerSheet" to stack "Catcher" with "Works?"
   if pButtonName is empty then put "OK" into pButtonName
   
   if pWarning is true then
      beep
      answer warning someQuestion with pButtonName as sheet
   else
      answer someQuestion with "Cancel" or pButtonName as sheet
   end if
   put it into theResult
   if theResult is "Cancel" then exit to top
   return theResult
end lcw_AnswerSheet

function lcw_Ask someQuestion, pDefault
   -- was "opn_Ask"
   -- removed complexity of "text_Merge"
   replace "'" with quote in someQuestion
   ask someQuestion with pDefault
   put it into theResult
   if the result is "Cancel" then exit to top
   return theResult
end lcw_Ask

--> Working On | Download Projects
-
command github_DownloadProject projectName, lcwRoot
   -- this should use git to clone a project to the lcwRoot folder
   -- and return the path to the projects home stack folder
   
   -- stub for now
   put empty into projectHomeStackPath
   if projectHomeStackPath is empty then
      put lcwRoot
      answer warning merge ("Failed to download project '[[projectName]]'!")
      exit to top
   end if
end github_DownloadProject


--> Project | Load
-
command project_LoadMenus projectFolder, pCreateindex
   put project_ListPaths ("controllers", projectFolder) into stackPaths
   if pCreateindex is true then
      project_IndexGlobalMenus stackPaths
   else
      -- here we should load from a stored array
      -- project_IndexGlobalMenus stackPaths
      breakpoint
   end if
end project_LoadMenus

command env_ExportMenusAndStackFiles pListAll
   put env_ListProjects (pListAll) into projectNames
   repeat for each line projectName in projectNames
      set the cursor to busy
      put project_GetFolder (projectName) into projectFolder
      project_ExportMenusAndStackFiles projectFolder
   end repeat
end env_ExportMenusAndStackFiles

command env_LoadMenusAndStackFiles pListAll
   put env_ListProjects (pListAll) into projectNames
   repeat for each line projectName in projectNames
      set the cursor to busy
      put project_GetFolder (projectName) into projectFolder
      project_LoadMenusAndStackFiles projectFolder
   end repeat
end env_LoadMenusAndStackFiles

command env_LoadMenus pListAll
   put env_ListProjects (pListAll) into projectNames
   repeat for each line projectName in projectNames
      put project_GetFolder (projectName) into projectFolder
      project_LoadMenus projectFolder, true
   end repeat
end env_LoadMenus

command project_InitialiseFolder projectFolderOrHomeStackFile
   -- does not initialise modules
   
   put projectFolderOrHomeStackFile into projectFolder
   if char -1 of projectFolderOrHomeStackFile is not slash then
      set the itemdelimiter to slash
      put empty into item -1 of projectFolder
   end if
   
   put project_ListUsedPathsFromFolder (projectFolder) into usedStackPaths
   stack_StartUsedPaths usedStackPaths
   
   -- this handler needs less dependencies
   -- project_SetFoundStackFiles projectFolder -- constructs from folder structure
   -- project_LoadMenus projectFolder  -- constructs from menu scripts of controllers
   project_LoadMenusAndStackFiles projectFolder -- loads from stored project_Array
   
   put project_GetHomeStackName (projectFolder) into homeStackName
   env_AddProject homeStackName, projectFolder -- here we could add modules in a different way
   return homeStackName
end project_InitialiseFolder

command project_LoadMenusAndStackFiles projectFolder
   global gLCW
   put project_FetchArray (projectFolder) into projectArray
   --
   put projectArray ["Global Menus"] into projectGlobalMenuArray
   put gLCW ["Global Menus"] into gMenuArray
   union projectGlobalMenuArray with gMenuArray
   put projectGlobalMenuArray into gLCW ["Global Menus"]
   
   put projectArray ["stackFileArray"] into projectStackFileArray
   put stackFile_FromArray (projectStackFileArray) into projectStackFiles
   put project_ConstructHomeStackPath (projectFolder) into projectHomeStackPath
   if exists (stack projectHomeStackPath) is false then
      put "project_LoadMenusAndStackFiles of stack lib_LCW" into gLCW ["Error"][projectHomeStackPath]
      return empty
   end if
   set the stackfiles of stack projectHomeStackPath to projectStackFiles
   return projectArray
end project_LoadMenusAndStackFiles

command project_ExportMenusAndStackFiles projectFolder
   put project_FetchArray (projectFolder) into projectArray
   --
   put project_ConstructFoundStackFileArray (projectFolder) into projectArray ["stackFileArray"]
   
   put project_ListPaths ("controllers", projectFolder) into stackPaths
   project_IndexGlobalMenus stackPaths
   put the result into projectArray ["Global Menus"]
   --
   project_StoreArray projectFolder, projectArray
end project_ExportMenusAndStackFiles

command project_SetFoundStackFiles projectFolder
   put project_ConstructHomeStackPath (projectFolder) into projectHomeStackPath
   if exists (stack projectHomeStackPath) is false then return empty
   
   put project_ConstructFoundStackFileArray (projectFolder) into projectStackFileArray
   put stackFile_FromArray (projectStackFileArray) into projectStackFiles
   
   set the stackfiles of stack projectHomeStackPath to projectStackFiles
   return lcwStackFiles
end project_SetFoundStackFiles

function project_FetchStackFileArray projectName
   put project_FetchValue ("stackFileArray", projectName) into stackFileArray
   return stackFileArray
end project_FetchStackFileArray

command project_StoreStackFileArray projectName, projectStackFileArray
   put the stack_Folder of stack projectName into projectFolder
   project_FetchValue someKey, projectName
end project_StoreStackFileArray

function project_FetchStackFiles projectFolder
   put project_FetchArray (projectFolder) into projectArray
   put projectArray ["stackfiles"] into stackFileTable
   return stackFileTable
end project_FetchStackFiles

command project_StoreStackFiles projectName, stackFileTable
   put project_FetchArray (projectFolder) into projectArray
   put stackFileTable into projectArray ["data"]["stackfiles"]
   project_StoreArray projectFolder, projectArray
end project_StoreStackFiles

command project_IndexGlobalMenus longStackFiles
   -- does not export handlers
   local projectMenuTitleArray
   repeat for each line longStackFile in longStackFiles
      set the cursor to busy
      
      if exists (stack longStackFile) is false then
         next repeat
      end if
      put the name of stack longStackFile into stackObject
      try
         set the menu_Update of stackObject to true -- false
         put the result into mTitleArray
         union projectMenuTitleArray with mTitleArray
      catch e
         put stackObject & CR after problemMenus
      end try
   end repeat
   
   if problemMenus is not empty then
      put problemMenus
      answer warning "The following menus have problems being indexed!"
   end if
   return projectMenuTitleArray
end project_IndexGlobalMenus


--> Project | Stackfiles
-
/*
Here we list the stackfiles based on the structure of a project.
This should probably be changed to a recursive stack search (but has the advantage of enforcing structure).
*/

function project_ConstructFoundStackFileArray projectFolder
   -- this gets all the stackfiles
   -- should use a recursive folder search
   -- but we use modules as inner module home stacks at the moment ?
   
   local stackFileArray
   put folder_ListLong (projectFolder) into standardFolders
   repeat for each line standardFolder in standardFolders
      switch
         case standardFolder ends with "/assets/"
            next repeat  -- stacks within the assets folder will not be indexed
         case standardFolder ends with "/modules/"
            put folder_ListLong (standardFolder) into moduleFolders
            repeat for each line moduleFolder in moduleFolders
               -- use a recursive search or
               -- put project_ConstructFoundStackFileArray (moduleFolder) into moduleFoundStackFileArray -- relative to modulefolder not projectFolder
               
               -- here we are only looking at homeStacks, behaviors and controller
               -- libraries an other folders will not be indexed
               _AddToStackFileArray stackFileArray, moduleFolder, projectFolder
               
               -- add the module controllers
               put moduleFolder & "controllers/" into moduleControllerFolder
               _AddToStackFileArray stackFileArray, moduleControllerFolder, projectFolder
               
               -- add the module behaviors
               put moduleFolder & "behaviors/" into moduleBehaviorFolder
               _AddToStackFileArray stackFileArray, moduleBehaviorFolder, projectFolder
            end repeat
         default      
            _AddToStackFileArray stackFileArray, standardFolder, projectFolder 
      end switch
   end repeat
   return stackFileArray
end project_ConstructFoundStackFileArray


--> Project | Names
-
function project_GetHomeStackName projectFolder
   put project_ConstructHomeStackPath (projectFolder) into projectHomeStackPath
   if exists (stack projectHomeStackPath) is false then return empty
   put the short name of stack projectHomeStackPath into projectName
   return projectName
end project_GetHomeStackName

function project_NameToShortFolder moduleStackName
   set the itemdelimiter to "|"
   repeat for each item someItem in moduleStackName
      put word 1 to -1 of someItem & "_" after shortFolder
   end repeat
   delete char -1 of shortFolder
   return shortFolder
end project_NameToShortFolder

function project_FindHomeStackPath somePath
   -- assumes somePath is a path to a stack or file and not a folder
   put somePath into someFolder
   set the itemdelimiter to slash
   put empty into item -1 of someFolder
   
   project_FindFromFolder someFolder, homeStackName, projectFolder, homeStackPath
   return homeStackPath
end project_FindHomeStackPath

function project_FindFolder somePath
   -- assumes somePath is a path to a stack or file and not a folder
   -- returns the top module or "project folder"
   put somePath into someFolder
   set the itemdelimiter to slash
   put empty into item -1 of someFolder
   
   project_FindFromFolder someFolder, homeStackName, projectFolder, homeStackPath
   return projectFolder
end project_FindFolder

function module_FindFolder somePath
   -- assumes somePath is a path to a stack or file and not a folder
   -- finds the first "module folder" above the path
   -- will also return a toplevel project folder if called on a toplevel path
   -- as "a project is also a module"
   -- test for special cases where you want to distinguish
   -- see "project_FindFolder" to get the top module or project folder
   put somePath into someFolder
   set the itemdelimiter to slash
   put empty into item -1 of someFolder
   
   module_FindFromFolder someFolder, homeStackName, moduleFolder, homeStackPath
   return moduleFolder
end module_FindFolder

function module_IsNotaProject moduleFolder
   set the itemdelimiter to slash
   if item -2 of moduleFolder = "modules" then
      -- when within a modules folder it is considered a module
      return true
   else
      -- otherwise it is a project
      return false
   end if
end module_IsNotaProject

command project_FindFromFolder someFolder, @homeStackName, @projectFolder, @homeStackPath
   set the itemdelimiter to slash
   put the number of items of someFolder into maxItemNum
   repeat with itemNum = maxItemNum down to 1
      -- could look for lcw project array file
      put item -1 of someFolder into folderName
      if module_IsNotaProject (someFolder) then
         -- it's not a top level project folder
         delete item -2 to -1 of someFolder
         next repeat
      end if
      
      put folderName & ".livecode" into shortStackFile -- shame we must insist in this an not allow .livecodescript
      put someFolder & shortStackFile into homeStackPath
      
      if exists (stack homeStackPath) then
         put someFolder into projectFolder
         put the short name of stack homeStackPath into homeStackName
         return true
      else
         delete item -1 of someFolder
      end if
   end repeat
   
   put empty into homeStackName
   put empty into projectFolder
   put empty into homeStackPath
   return false
end project_FindFromFolder

command module_FindFromFolder someFolder, @homeStackName, @projectFolder, @homeStackPath
   set the itemdelimiter to slash
   put the number of items of someFolder into maxItemNum
   repeat with itemNum = maxItemNum down to 1
      -- could look for lcw project array file
      put item -1 of someFolder into folderName
      put folderName & ".livecode" into shortStackFile -- shame we must insist in this an not allow .livecodescript
      put someFolder & shortStackFile into homeStackPath
      
      if exists (stack homeStackPath) then
         put someFolder into projectFolder
         put the short name of stack homeStackPath into homeStackName
         return true
      else
         delete item -1 of someFolder
      end if
   end repeat
   
   put empty into homeStackName
   put empty into projectFolder
   put empty into homeStackPath
   return false
end module_FindFromFolder


--> LCW | Names
-
function lcw_HomeFolder
   --  see "project_HomeFolder"
   if the environment is "mobile" then
      put specialFolderPath ("resources") into lcwHomeFolder
      put slash after lcwHomeFolder
   else  
      -- rumour has it that this does not work on mobile?
      put the stack_Folder of of stack "LCW" into lcwHomeFolder
   end if
   return lcwHomeFolder
end lcw_HomeFolder

getprop project_Name
   -- could also be called project_HomeStackName
   -- searches the disk based file hierearchy to find the project root
   put the stack_Object of the target into stackObject
   put the effective filename of stackObject into stackPath
   
   put project_FindFolder (stackPath) into projectFolder
   if projectFolder is empty then return empty
   
   set the itemdelimiter to slash
   return item -1 of projectFolder -- assume folder name = project homestack name
   
   put project_GetHomeStackName (projectFolder) into projectName
   return projectName 
end project_Name

getprop project_HomeStack
   -- searches the disk based file hierearchy to find the project root
   put the stack_Object of the target into stackObject
   put the effective filename of stackObject into stackPath
   
   put project_FindHomeStackPath (stackPath) into projectStackPath
   if projectStackPath is empty then return empty
   
   put the name of stack projectStackPath into stackObject
   return stackObject 
end project_HomeStack

getprop project_Folder [shortSubFolderName]
   -- searches the disk based file hierearchy to find the project root
   put the stack_Object of the target into stackObject
   put the effective filename of stackObject into stackPath
   
   put project_FindFolder (stackPath) into projectFolder
   switch
      case projectFolder is empty
         return empty
      case shortSubFolderName is not empty
         if char 1 of shortSubFolderName = slash then delete char 1 of shortSubFolderName
         put shortSubFolderName after projectFolder
         if char -1 of shortSubFolderName is not slash then put slash after projectFolder
      default
         return projectFolder
   end switch
end project_Folder


--> Working On | Messy
-
getprop project_UsedStackPaths
   local stackNames
   put the project_Name of the target into projectName
   put project_ListUsedStackPaths (projectName) after stackPaths
   
   if projectName = "LCW" then
      put the filename of stack projectName & CR & stackPaths into usedStackPaths
      return word 1 to -1 of usedStackPaths
   else
      return stackPaths
   end if
end project_UsedStackPaths

getprop project_UsedStackNames
   local stackNames
   put the project_Name of the target into projectName
   put project_ListUsedStackNames (projectName) after stackNames
   
   if projectName = "LCW" then
      -- here we add the root "LCW" stack
      -- it may be better not to use the home stacks and instead have minmal scripts there.
      put "LCW" & CR & stackNames into usedStackNames
      return word 1 to -1 of usedStackNames
   else
      return stackNames
   end if
end project_UsedStackNames


--> Events | revEditScript
-
/*
For menus only. move to lcw_Tools
*/

function ide_GetRevEditScriptStack stackName
   global gREVMessageDispatch
   put gREVMessageDispatch ["revEditScript"] into revEditControllerStackNames
   put stackName is among the lines of revEditControllerStackNames into someBoolean
   return someBoolean
end ide_GetRevEditScriptStack

command ide_AddRevEditScriptStack stackName
   -- this adds the stack stackname to the list of stacks that receive the "revEditScript" command
   -- send "revEditScript tObject" to this card of stack tPlugin
   global gREVMessageDispatch
   if stackName is among the lines of gREVMessageDispatch ["revEditScript"] then return false
   
   put stackName & CR before gREVMessageDispatch ["revEditScript"]
   return true
end ide_AddRevEditScriptStack

command ide_RemoveRevEditScriptStack stackName
   global gREVMessageDispatch
   put gREVMessageDispatch ["revEditScript"] into stackNames
   put lineoffset (stackName, stackNames) into lineNum
   delete line lineNum of stackNames
   put stackNames into gREVMessageDispatch ["revEditScript"]
end ide_RemoveRevEditScriptStack


--> Working On | Initialise
-
command project_Start homeStackName
   put library_FetchProjectHomeStackObject (homeStackName) into homeStackObject
   put the short name of stack homeStackObject into homeStackName -- just in case ???
   
   display_Loading homeStackName
   --
   -- could rely on sending "preOpenStack" ???
   dispatch "project_Init" to homeStackObject -- a project specific customised version of below
   
   put the stack_Folder of stack homeStackObject into projectFolder -- just in case ???
   switch it
      case "unhandled"
      case "passed"
         -- it is "passed" because it is trapped but passed by the handler in "LCW"
         -- here we could initialise some basic things by default
         project_InitialiseFolder projectFolder
         project_LoadModules homeStackName
         break
      default
         -- whatever happens let's register the project environment as "loaded"
         env_AddProject homeStackName, projectFolder -- here we could add modules in a different way
   end switch
   
   put merge ("Finished project '[[homeStackName]]'!") into someComment
   display_Loading homeStackName, someComment
end project_Start

command project_Stop projectName
   -- with multiple projects that's a bit hard (as other projects 'could' use some of the stacks?)
   put the project_UsedStackNames of stack projectName into usedStackNames
   put the project_Name of stack projectName into projectName
   
   repeat for each line usedStackName in usedStackNames
      set the cursor to busy
      if exists (stack usedStackName) is false then next repeat
      save stack usedStackName
      stop using stack usedStackName
      delete stack usedStackName
   end repeat
   env_RemoveProject projectName
   --
   put merge ("Stopped project '[[projectName]]'!") into someComment
   display_Loading projectName, someComment
end project_Stop

command project_LoadDeps projectDeps, projectHomeStackFile
   replace comma with CR in projectDeps   
   repeat for each line sisterProjectName in projectDeps
      put env_GetProjectFolder (sisterProjectName) into sisterProjectFolder
      if sisterProjectFolder is not empty then next repeat -- already loaded
      
      display_Loading sisterProjectName
      put project_ConstructSisterHomeStackPath (sisterProjectName, projectHomeStackFile) into sisterProjectHomeStackPath
      
      if exists (stack sisterProjectHomeStackPath) is false then
         breakpoint
         next repeat
      end if
      dispatch "project_Init" to stack sisterProjectHomeStackPath
      -- go to stack sisterProjectHomeStackPath
   end repeat
end project_LoadDeps


--> Project | Props
-
/*
Here is a list of naming conventions we use for projects:

A project has a home stack.
The home stack is often a script only stack, but this is not required.
The short name of the homestack is the name of the project.
The short file of the homestack is the name of the project followed by ".livecode" (eg "lcw.livecode").
We use the ".livecode" regardless of whether the stack is a script only stack to make it easier to derive the path from the project name and therfore locate.
The short file of the homestack is in lower case (eg "lcw.livecode" not "LCW.livecode")
*/

getprop project_ViewStackPaths
   put the project_StackPaths ["views"] of the target into stackPaths
   filter stackPaths without "*/behavior_*"
   return stackPaths
end project_ViewStackPaths

getprop project_StackPaths [shortFolder]
   put the project_Folder of the target into projectFolder
   put project_ListPaths (shortFolder, projectFolder) into projectStackPaths
   return projectStackPaths
end project_StackPaths

getprop project_HomeStackBrowser
   put the project_Name of the target into pHomeStackName
   put project_GetHomeStackBrowser (pHomeStackName) into browserWidget
   return browserWidget
end project_HomeStackBrowser

getprop project_FoundStackFiles
   -- not needed
   put the project_Folder of the target into projectFolder
   if projectFolder is empty then return empty
   put project_ConstructFoundStackFileArray (projectFolder) into projectStackFileArray
   put stackFile_FromArray (projectStackFileArray) into projectStackFiles
   return projectStackFiles
end project_FoundStackFiles


--> Project | List
-
function project_ListPaths shortFolder, projectFolder
   switch shortFolder
      case empty
         put project_ListAllStackPaths (projectFolder) into stackPaths
         return stackPaths
      case "modules"
         put project_ConstructFolder ("modules", projectFolder) into viewFolder
         put folder_ListLong (viewFolder) into subViewFolders
         repeat for each line subViewFolder in subViewFolders
            put folder_ListStackPaths (subViewFolder) into stackPaths
            if stackPaths is not empty then
               put stackPaths & CR after projectStackPaths
            end if
         end repeat
         
         put folder_ListStackPaths (viewFolder) into stackPaths
         if stackPaths is not empty then
            put stackPaths & CR after projectStackPaths
         end if
         return projectStackPaths
      default
         put project_ConstructFolder (shortFolder, projectFolder) into standardFolder
         put folder_ListStackPaths (standardFolder) into stackPaths
         return stackPaths
   end switch
   
   -- lists only the top-level stacks in the projectFolder
   -- put project_ConstructFolder (shortFolder, projectFolder) into standardFolder
   -- put folder_ListStackPaths (standardFolder) into stackPaths
   -- return stackPaths
end project_ListPaths

function project_ListAllStackPaths projectFolder
   put project_ConstructHomeStackPath (projectFolder) & CR into projectStackPaths
   put folder_ListLong (projectFolder) into standardFolders
   repeat for each line standardFolder in standardFolders
      if standardFolder ends with "/assets/" then next repeat
      if standardFolder ends with "/modules/" then
         put folder_ListLong (standardFolder) into viewFolders
         repeat for each line viewFolder in viewFolders
            put folder_ListStackPaths (viewFolder) into stackPaths
            if stackPaths is not empty then
               put stackPaths & CR after projectStackPaths
            end if
         end repeat
      end if
      
      put folder_ListStackPaths (standardFolder) into stackPaths
      if stackPaths is not empty then
         put stackPaths & CR after projectStackPaths
      end if
   end repeat
   delete char -1 of projectStackPaths
   return projectStackPaths
end project_ListAllStackPaths


--> Project | Home
-
function project_GetHomeStackBrowser pHomeStackName
   if exists (widget "Home Browser" of cd 1 of stack pHomeStackName) is false then return empty
   put the long id of widget "Home Browser" of cd 1 of stack pHomeStackName into browserWidget
   return browserWidget
end project_GetHomeStackBrowser

command project_CreateHomeBrowser pHomeStackName
   if pHomeStackName is empty then put the short name of the target into pHomeStackName
   if exists (widget "Home Browser" of cd 1 of stack pHomeStackName) is true then return empty
   
   put the long id of card  1 of stack pHomeStackName into cardObject
   if exists (stack "behavior_HomeCard") then
      set the behavior of cardObject to the long id of stack "behavior_HomeCard"
   else
      put "on resizeStack" into someScript
      put CR & "   set the rect of widget 1 of me to the rect of this card" after someScript
      put CR & "end resizeStack" after someScript
      set the script of cardObject to someScript
   end if
   
   go to card 1 of stack pHomeStackName
   create widget "Home Browser" as "com.livecode.widget.browser"
   put it into createdObject
   set the rect of createdObject to the rect of cardObject
   set the url of createdObject to "http://google.com"
   return createdObject
end project_CreateHomeBrowser


--> Project | Files
-
function project_FolderFromName shortFolder, projectName
   if exists (stack projectName) is false then return empty
   put the stack_Folder of stack projectName into projectFolder
   put projectFolder & shortFolder & slash into standardFolder
   return standardFolder
end project_FolderFromName

function project_GetFolder projectName, pSubFolderPath
   put library_FetchProjectFolder (projectName) into projectFolder
   if projectFolder is empty then return empty
   
   if pSubFolderPath is not empty then
      if char 1 of pSubFolderPath = slash then delete char 1 of pSubFolderPath
      put pSubFolderPath after projectFolder
      text_AddTrailing projectFolder, slash
   end if
   return projectFolder
end project_GetFolder

function project_ConstructHomeStackPath projectFolder
   text_AddTrailing projectFolder, slash
   put project_GetShortFolder (projectFolder) into projectShortFolder
   put projectFolder & projectShortFolder & ".livecode" into projectHomeStackPath
   return projectHomeStackPath
end project_ConstructHomeStackPath

function project_GetShortFolder projectFolder
   /*
   You should use project_GetHomeStackName(projectFolder)
   
   While a projects folder should be named the same as the projects home stack,
   we do not guarantee this (work-in-progress).
   */
   
   set the itemdelimiter to slash
   put item -1 of projectFolder into projectName
   return projectName
end project_GetShortFolder

function project_ConstructSisterHomeStackPath sisterProjectName, projectHomeStackFile
   put projectHomeStackFile into sisterFolder
   
   set the itemdelimiter to slash
   put sisterProjectName into item -2 to -1 of sisterFolder
   put slash after sisterFolder
   put sisterFolder & sisterProjectName & ".livecode" into sisterProjectHomeStackPath
   /*
   if exists (stack sisterProjectHomeStackPath) is false then
      -- and if it is not there download from github
      github_DownloadProject sisterProjectName
      put the result into sisterProjectHomeStackPath
   end if
   */
   return sisterProjectHomeStackPath
end project_ConstructSisterHomeStackPath


--> Project | List | Files
-
function project_ListUsedPathsFromFolder projectFolder
   local projectUsedStackPaths
   repeat for each item shortFolder in "libraries,models"
      put project_ConstructFolder (shortFolder, projectFolder) into standardFolder
      if there is not a folder standardFolder then next repeat
      put folder_ListStackPaths (standardFolder) into stackPaths
      put stackPaths & CR after projectUsedStackPaths
   end repeat
   sort projectUsedStackPaths
   put word 1 to -1 of projectUsedStackPaths into projectUsedStackPaths
   return projectUsedStackPaths
end project_ListUsedPathsFromFolder


--> LCW | Folder
-
function lcw_UserHomeStack
   put lcw_UserProjectFolder() into userFolder
   put lcw_UserHomeStackName() into lcwUserHomeStackName
   put userFolder & lcwUserHomeStackName & ".livecode" into userHomePath
   
   if exists (stack userHomePath) is false then
      create script only stack lcwUserHomeStackName
      set the filename of stack lcwUserHomeStackName to userHomePath
      save stack lcwUserHomeStackName
   end if 
   
   put the name of stack lcwUserHomeStackName into stackObject
   return stackObject
end lcw_UserHomeStack

function lcw_UserMetadataFolder
   put lcw_UserProjectFolder ("lcw_Metadata") into lcwUserMetadataFolder
   return lcwUserMetadataFolder
end lcw_UserMetadataFolder

function lcw_UserHomePath
   put lcw_UserProjectFolder() into userFolder
   put lcw_UserHomeStackName() into lcwUserHomeStackName
   put userFolder & lcwUserHomeStackName & ".livecode" into userHomePath
   return userHomePath
end lcw_UserHomePath

function lcw_UserHomeStackName
   return "lcw_User"
end lcw_UserHomeStackName

function lcw_UserProjectFolder pSubFolder
   put revEnvironmentUserPluginsPath() & "/lcw_User/" into userProjectFolder
   if pSubFolder is not empty then
      if char 1 of pSubFolder is slash then delete char 1 of pSubFolder
      text_AddTrailing pSubFolder, slash
      put pSubFolder after userProjectFolder
   end if
   folder_CreateNested userProjectFolder
   return userProjectFolder
end lcw_UserProjectFolder

function lcw_GetStandardFolder shortFolder
   put lcw_GetRootFolder() into lcwRootFolder
   put project_ConstructFolder (shortFolder, lcwRootFolder) into lcwStandardFolder
   return lcwStandardFolder
end lcw_GetStandardFolder

function lcw_GetRootFolder
   put lcw_HomeStackName() into lcwHomeStackName
   put the stack_Folder of stack lcwHomeStackName into lcwGetRootFolder
   return lcwGetRootFolder
end lcw_GetRootFolder

function lcw_HomeStackName
   return "LCW"
end lcw_HomeStackName


--> Env
-
function project_IsActive projectName
   put env_GetProjectFolder (projectName) is not empty into projectIsLoaded
   return projectIsLoaded
end project_IsActive

function env_GetProjectFolder homeStackName
   put env_GetProjectArray() into envProjectArray
   return envProjectArray [homeStackName]
end env_GetProjectFolder

command env_SetProjectFolder homeStackName, pProjectFolder
   put env_GetProjectArray() into envProjectArray
   if pProjectFolder is empty then
      delete variable envProjectArray [homeStackName]
   else
      put pProjectFolder into envProjectArray [homeStackName]
   end if
   env_SetProjectArray envProjectArray
   return envProjectArray
end env_SetProjectFolder

function env_GetProjectArray
   global gLCW
   put gLCW ["environment"]["project"] into envProjectArray
   return envProjectArray
end env_GetProjectArray

command env_SetProjectArray envProjectArray
   global gLCW
   put envProjectArray into gLCW ["environment"]["project"]
   return LocalArray
end env_SetProjectArray


--> Modules
-
command project_LoadModules homeStackNameOrPath
   -- modules can be loaded in the same way a project is loaded
   -- this can be slow as there are often a lot of modules with menus
   put the module_Names of stack homeStackNameOrPath into moduleNames
   repeat for each line moduleName in moduleNames
      -- could notify
      put module_GetFolder (moduleName, homeStackNameOrPath) into moduleFolder
      project_InitialiseFolder moduleFolder
   end repeat
end project_LoadModules

getprop module_Names
   -- a module_Name is the same as a (sub) project_Name
   put the project_Folder ["modules"] of the target into modulesFolder
   put folder_ListShort (modulesFolder) into moduleNames
   return moduleNames
end module_Names

getprop module_HomeStackPath [moduleName]
   put the module_Folder [moduleName] of the target into moduleFolder
   put project_ConstructHomeStackPath (moduleFolder) into moduleHomeStackPath
   if exists (stack moduleHomeStackPath) is false then return empty
   return moduleHomeStackPath
end module_HomeStackPath

getprop module_Folder [moduleName]
   put the stack_Object of the target into stackObject
   put the effective filename of stackObject into stackPath
   put module_FindFolder (stackPath) into maybeModuleFolder
   
   set the itemdelimiter to slash
   put item -2 of maybeModuleFolder into testPathItem
   switch
      case maybeModuleFolder is empty
         return empty
      case moduleName is not empty
         put module_GetFolder (moduleName, maybeModuleFolder) into moduleFolder
         return moduleFolder
      case testPathItem = "modules"
         -- asssume the found "project" folder is a module folder
         return maybeModuleFolder
      default
         return empty
   end switch
end module_Folder

function module_GetFolder moduleShortFolder, projectFolder
   put project_ConstructFolder ("modules", projectFolder) into rootModuleFolder
   put rootModuleFolder & moduleShortFolder & slash into moduleFolder
   return moduleFolder
end module_GetFolder


--> Private
-
private command _AddToStackFileArray @stackFileArray, someFolder, pHomeFolder
   if there is not a folder someFolder then return false
   
   if char -1 of someFolder is not slash then put slash after someFolder
   put the defaultfolder into oFolder
   set the defaultfolder to someFolder
   put the files into shortFiles
   
   set the itemdelimiter to slash
   put the number of items of pHomeFolder + 1 into startItemNum
   repeat for each line shortFile in shortFiles
      if shortFile begins with "." then next repeat
      put someFolder & shortFile into stackFilePath
      if exists (stack stackFilePath) is false then
         next repeat -- no need to index things that aren't stacks
      end if
      
      put the short name of stack stackFilePath into stackName
      if pHomeFolder is empty then
         put stackRelPath into stackFileArray [stackName]
      else
         -- make a relative path
         put item startItemNum to -1 of stackFilePath into stackRelPath
         put stackRelPath into stackFileArray [stackName]
      end if
   end repeat
   set the defaultfolder to oFolder
   return true
end _AddToStackFileArray


--> Deps
-
/*
Here we put deps that the project needs.
These could be in a backscript named after the project like: back_LcwCommon or lib_LcwCommon
*/

command env_AddToBash
   -- put "/usr/bin:/bin:/usr/sbin:/sbin:/opt/local/bin" into $PATH
   if the platform = "MacOS" then -- and it is recent ???
      put url "file:/etc/paths" into systemPaths
      if systemPaths is empty then return empty
      
      put token 1 to -1 of systemPaths into systemPathArray
      
      put $PATH into revPATH
      replace ":" with CR in revPATH
      put systemPathArray & CR & revPATH into combinedPath
      sort combinedPath
      put token 1 to -1 of combinedPath into combinedPath
      split combinedPath with CR and ":"
      put keys (combinedPath) into newPathIndex
      replace CR with ":" in newPathIndex
      put newPathIndex into $PATH
   end if
   return $PATH
end env_AddToBash

function folder_ListStackPaths someFolder
   if there is not a folder someFolder then return empty
   
   if char -1 of someFolder is not slash then put slash after someFolder
   put the defaultfolder into oFolder
   set the defaultfolder to someFolder
   put the files into shortFiles
   
   set the itemdelimiter to "."
   repeat for each line shortFile in shortFiles
      put someFolder & shortFile into stackFilePath
      if there is a stack stackFilePath then
         put stackFilePath & CR after stackFilePaths
      end if
   end repeat
   delete char -1 of stackFilePaths
   set the defaultfolder to oFolder
   return stackFilePaths
end folder_ListStackPaths

function folder_ListShort rootFolder
   if there is not a folder rootFolder then return empty
   
   put the defaultfolder into oDefault
   set the defaultfolder to rootFolder
   put the folders into shortFolders
   set the defaultfolder to oDefault
   
   filter shortFolders without ".*"
   return shortFolders
end folder_ListShort

function folder_ListLong someFolder
   if there is not a folder someFolder then return empty
   text_AddTrailing someFolder, slash
   
   put folders (someFolder) into shortFolders
   repeat for each line shortFolder in shortFolders
      if char 1 of shortFolder = "." then next repeat
      put someFolder & shortFolder & slash & CR after longSubFolders
   end repeat
   delete char -1 of longSubFolders
   return longSubFolders
end folder_ListLong

command folder_CreateFromFile someFile
   put someFile into someFolder
   set the itemdelimiter to slash
   put empty into item -1 of someFolder
   folder_CreateNested someFolder
   return someFolder
end folder_CreateFromFile

command folder_CreateNested @someFolder
   if there is a folder someFolder then return empty   
   set the itemdelimiter to "/"
   repeat with itemNum = 2 to the number of items of someFolder
      put item 1 to itemNum of someFolder & "/" into testFolder
      if there is a folder testFolder then next repeat
      create folder testFolder
   end repeat
   text_AddTrailing someFolder, slash
end folder_CreateNested

function folder_GetSister shortFolder, someFileOrFolder
   set the itemdelimiter to slash
   if char -1 of someFileOrFolder = slash then
      put shortFolder into item -1 of someFileOrFolder
   else
      put shortFolder into item -2 to -1 of someFileOrFolder
   end if
   put someFileOrFolder & slash into sisterFolder
   return sisterFolder
end folder_GetSister

getprop stack_SisterFolder [projectName]
   put the effective filename of the defaultstack into sisterFolder
   put folder_GetSister (projectName, someFileOrFolder) into sisterFolder
   return sisterFolder
end stack_SisterFolder


--> Objects
-
getprop card_Object
   -- ideCoreCardOfcontrol§
   -- always returns an object
   put the long id of the target into targetObject
   switch
      case word 1 of targetObject = "card"
         return targetObject
      case word 1 of targetObject = "stack"
         if the scriptonly of targetObject is true then
            return the long id of card 1 of the defaultstack
         else
            put the currentcard of the defaultstack into cardName
            put the long id of card cardName of the defaultstack into cardObject
            return cardObject
         end if
      case word 1 of targetObject is among the items of "background,bkgnd,bg"
         return empty  -- no such thing as a unique card_Object
      default
         put wordOffset ("card", targetObject) into wNum
         return word wNum to -1 of targetObject
   end switch
end card_Object

getprop stack_Name
   return the short name of the defaultstack
end stack_Name

getprop stack_Object
   return the defaultstack
end stack_Object

getprop stack_Folder
   put the effective filename of the defaultstack into stackFolder
   set the itemdelimiter to slash
   put empty into item -1 of stackFolder
   return stackFolder
end stack_Folder

function stackFile_FromArray stackFileArray
   combine stackFileArray using CR and comma
   sort stackFileArray by item 1 of each
   return stackFileArray
end stackFile_FromArray

command stack_StartUsedPaths stackPaths
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      start using stack stackPath
   end repeat
end stack_StartUsedPaths

command stack_StartUsed stackObjects
   -- not used?
   repeat for each line stackObject in stackObjects
      if exists(stackObject) and word 1 of stackObject is "stack" then
         try
            start using stackObject
         catch someError
            put stackObject
            answer someError
         end try
      end if
   end repeat
end stack_StartUsed

command stack_StopUsed stackObjects
   -- not used?
   repeat for each line stackObject in stackObjects
      if exists(stackObject) and word 1 of stackObject is "stack" then
         stop using stackObject
      end if
   end repeat
end stack_StopUsed

command text_AddTrailing @someText, someChar
   if char -1 of someText is not someChar then
      put someChar after someText
   end if
end text_AddTrailing
