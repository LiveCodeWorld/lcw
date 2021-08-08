script "lib_LCW"
--> MetaData
-
license: GPLv3
name: lib_LCW
type: library
version: 0.7

/*
Here we place all the handlers that need to be in use before project initialisation.

command project_UpdateMenusAndStackFiles projectFolder, pIndexView, pSaveStack
   -- apppeears to not be needed
   put project_FetchArray (projectFolder) into projectArray
   --
   put project_FetchStackFileArray (projectFolder) into projectArray ["stackFileArray"] -- includes module stacks
   --
   project_AddControllersToArray projectArray, projectFolder
   project_AddModulesToArray @rojectArray, projectFolder
   --
   project_StoreArray projectFolder, projectArray
   return projectArray
end project_UpdateMenusAndStackFiles

command project_AddModulesToArray @projectArray, projectFolder
   put fold (projectFolder, shortFolder)er_AddShort (projectFolder, "modules") into modulesFolder
   put folder_ListLong (modulesFolder) into moduleFolders
   --
   repeat for each line moduleFolder in moduleFolders
      project_AddControllersToArray projectArray, moduleFolder
   end repeat
end project_AddModulesToArray

command project_AddControllersToArray @projectArray, projectFolder
   put project_ListAllControllers (projectFolder) into controllerPaths
   _AddToProjectAndGlobalArray projectArray, projectFolder, controllerPaths
end project_AddControllersToArray

function project_FetchStackFileArray projectFolder
   -- was "project_ConstructFoundStackFileArray"
   -- this gets all the stackfiles (we do menu controllers later)
   
   local stackFileArray
   
   -- put project_GetHomeStackName (projectFolder) into homeStackName
   put project_ConstructHomeFromFolder (projectFolder) into homeStackName
   if exists (stack homeStackName) then
      put the stackFile_Array of stack homeStackName into stackFileArray
   else
      breakpoint
   end if
   
   put folder_ListLong (projectFolder) into standardFolders
   repeat for each line standardFolder in standardFolders
      switch
         case standardFolder ends with "/assets/"
            next repeat  -- stacks within the assets folder will not be indexed
         case standardFolder ends with "/modules/"
            put folder_ListLong (standardFolder) into moduleFolders
            repeat for each line moduleFolder in moduleFolders
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
end project_FetchStackFileArray

command _AddToProjectAndGlobalArray @projectArray, projectFolder, stackPaths
   -- old way that fetches menu table and is too complicated
   menu_LoadFromControllers stackPaths, pIndexView, pSaveStack
   put the result into controllerArray
   --
   put projectArray ["Global Menus"] into globalMenusArray
   union globalMenusArray with controllerArray
   put globalMenusArray into projectArray ["Global Menus"]
end _AddToProjectAndGlobalArray

command menu_LoadFromControllers mControllerPaths, pIndexView, pSaveStack
   -- old way that fetches menu table and is too complicated
   /*
   Does not export handlers.
   
   It loops through each controller
   Reads the script and construct a mTable with "script_MenuTitleTableArray"
   Uses "menu_UpdateGlobalArray" to update the gLCW ["Global Menus"]
   And returns a subset of gLCW ["Global Menus"] for the indexed controllers
   */
   local projectMenuTitleArray, projectMenuArray
   
   repeat for each line longStackFile in mControllerPaths
      if exists (stack longStackFile) is false then next repeat -- just in case
      
      put the name of stack longStackFile into mController
      put the short name of mController into gMenuTitle
      display_Spin gMenuTitle, pIndexView, "blue"
      put the result into lineNum
      --
      try
         -- update Global menus in gLCW
         put the script_MenuTitleTableArray of mController into mTableArray
         menu_UpdateGlobalArray mController, mTableArray
         put the result into mTitleArray
         union projectMenuArray with mTitleArray
         --
         if pSaveStack is true then
            save stack longStackFile
         end if
         --
         if exists (pIndexView) then
            set the line_Colour [lineNum] of pIndexView to "dark green"
         end if
      catch e
         put stackObject & CR after problemMenus
         if exists (pIndexView) then
            set the line_Colour [lineNum] of pIndexView to "red"
         end if
      end try
   end repeat
   
   if problemMenus is not empty then
      put problemMenus
      answer warning "The following menus have problems being indexed!"
   end if
   return projectMenuArray
end menu_LoadFromControllers
*/

--> Working on
-
command project_ExportMenusAndStackFiles projectFolder, pIndexView, pSaveStack
   # Construct project array and update global menu array
   put project_ConstructArray (projectFolder, false) into projectArray
   
   # Store project array
   project_StoreArray projectFolder, projectArray
   return projectArray
end project_ExportMenusAndStackFiles

command project_LoadMenus projectFolder
   put project_FetchArray (projectFolder) into projectArray
   project_AddProjectArrayToGlobal projectArray
   return projectArray
end project_LoadMenus

function project_ConstructArray projectFolder, pDontUpdateGlobal
   local projectArray
   put project_FetchStackFileArray (projectFolder) into projectArray ["stackFileArray"] -- includes module stacks
   
   # Add controllers to array
   put project_ListAllControllers (projectFolder) into controllerPaths -- includes module stacks
   _AddToProjectAndGlobalArray projectArray, projectFolder, controllerPaths, pDontUpdateGlobal
   --
   return projectArray
end project_ConstructArray

private command _AddToProjectAndGlobalArray @projectArray, projectFolder, controllerPaths, pDontUpdateGlobal
   -- compatible with both project arrays and gLCW
   set the itemdelimiter to slash
   put item -1 of projectFolder into projectName
   repeat for each line controllerPath in controllerPaths
      set the cursor to busy  
      if exists (stack controllerPath) is false then next repeat
      
      put the name of stack controllerPath into mController
      put the short name of mController into gMenuTitle
      --
      controller_AddToArray projectArray, gMenuTitle, mController, projectName
      --
      if pDontUpdateGlobal is not true then
         mArray_UpdateGlobal gMenuTitle, mController, projectName
      end if
   end repeat
   return projectControllerArray
end _AddToProjectAndGlobalArray

command project_AddProjectArrayToGlobal projectArray
   global gLCW
   
   put projectArray ["Global Menus"] into projectGlobalMenuArray
   put gLCW ["Global Menus"] into gMenuArray
   union projectGlobalMenuArray with gMenuArray
   put projectGlobalMenuArray into gLCW ["Global Menus"]
end project_AddProjectArrayToGlobal


--> Project | StackFileArray
-
function project_FetchStackFileArray projectFolder
   put directory_NestedStackFileArray (projectFolder) into stackFileArray
   
   # No need to add path to home stack file
   put project_ConstructHomeFromFolder (projectFolder) into homeStackPath
   put the short name of stack homeStackPath into homeStackName
   --
   delete variable stackFileArray [homeStackName]
   return stackFileArray
end project_FetchStackFileArray

function directory_NestedStackFileArray someFolder
   set the itemdelimiter to slash
   put the number of items of someFolder into baseFolderNum
   --
   put directory_ListNestedPaths (someFolder) into nPaths
   repeat for each line sFile in nPaths
      if exists (stack sFile) then
         put the short name of stack sFile into stackName
         delete item 1 to baseFolderNum of sFile
         put sFile into sFileArray [stackName]
      end if
   end repeat
   return sFileArray
end directory_NestedStackFileArray 

function directory_ListNestedPaths someFolder, pSetRelative
   local NestedPaths
   --
   set the itemdelimiter to slash
   text_AddTrailing someFolder, slash
   if pSetRelative is true then
      put the number of items of someFolder into baseFolderNum
      _WalkAndList NestedPaths, someFolder, baseFolderNum
   else
      _WalkAndList NestedPaths, someFolder, baseFolderNum
   end if
   delete char -1 of NestedPaths
   return NestedPaths
end directory_ListNestedPaths 

private command _WalkAndList @NestedPaths, someFolder, pBaseFolderNum
   put files (someFolder) into shortFiles
   put someFolder into pathFolder
   if pBaseFolderNum is a number then
      set the itemdelimiter to slash
      delete item 1 to pBaseFolderNum of pathFolder
   end if
   
   # Add files (not folders) to NestedPaths
   filter shortFiles without ".*"
   repeat for each line shortFile in shortFiles
      if char 1 of shortFile = "." then next repeat
      put pathFolder & shortFile into foundPath
      put foundPath & CR after NestedPaths
   end repeat
   
   # Recurse
   put folders (someFolder) into shortChildFolders
   repeat for each line shortChildFolder in shortChildFolders
      if char 1 of shortChildFolder = "." then next repeat
      put someFolder & shortChildFolder & slash into childFolder
      _WalkAndList NestedPaths, childFolder, pBaseFolderNum
   end repeat
end _WalkAndList


--> Working on
-
command mArray_UpdateGlobal mController
   global gLCW
   if exists (mController) is false then
      return "Error, global menu does not exist:" & gMenuTitle,mController,projectName
   end if
   
   # Update gLCW
   put the project_Name of mController into projectName
   put the script_GlobalTitles of mController into gMenuTitles
   repeat for each line gMenuTitle in gMenuTitles
      controller_AddToArray gLCW, gMenuTitle, mController, projectName
      put gLCW ["Global Menus"][gMenuTitle] into resultArray [gMenuTitle]
   end repeat
   return resultArray
end mArray_UpdateGlobal

command controller_AddToArray @projectArray, gMenuTitle, mController, projectName
   -- used by "menu_UpdateFromController" and LCW
   delete variable projectArray ["Global Menus"][gMenuTitle] -- just for tyding old stuff
   --
   put revRuggedId (mController) into mController
   put mController into projectArray ["Global Menus"][gMenuTitle]["mController"]
   put projectName into projectArray ["Global Menus"][gMenuTitle]["projectName"]
   -- put projectFolder into projectArray ["Global Menus"][gMenuTitle]["projectFolder"]
end controller_AddToArray

command project_Load projectName
   put project_GetFolder (projectName) into projectFolder
   project_LoadMenusAndStackFiles projectFolder
end project_Load

command project_LoadMenusAndStackFiles projectFolder
   put project_FetchArray (projectFolder) into projectArray
   
   # Add found menus to global gLCW 
   project_AddProjectArrayToGlobal projectArray
   
   # Seet stackfiles
   put projectArray ["stackFileArray"] into projectStackFileArray
   put stackFile_FromArray (projectStackFileArray) into projectStackFiles
   put project_ConstructHomeStackPath (projectFolder) into projectHomeStackPath
   if exists (stack projectHomeStackPath) is false then
      put "project_LoadMenusAndStackFiles of stack lib_LCW" into gLCW ["Error"][projectHomeStackPath]
      return empty
   end if
   set the stackfiles of stack projectHomeStackPath to projectStackFiles
   --
   return projectArray
end project_LoadMenusAndStackFiles


--> Module | Export
-
command module_ExportMenusAndStackFiles moduleFolder, pIndexView, pSaveStack
   put module_ConstructArray (moduleFolder) into moduleArray
   --
   project_StoreArray moduleFolder, moduleArray
   return moduleArray
end module_ExportMenusAndStackFiles

function module_ConstructArray moduleFolder
   local projectArray
   put directory_NestedStackFileArray (moduleFolder) into moduleArray ["stackFileArray"]
   
   # Add controllers to array
   put folder_AddShort (moduleFolder, "controllers") into controllerFolder
   put folder_ListStackPaths (controllerFolder) into controllerPaths
   --
   _AddToProjectAndGlobalArray moduleArray, moduleFolder, controllerPaths
   --
   return moduleArray
end module_ConstructArray


--> Project | Export
-
function project_ListAllControllers projectFolder
   # List controllers
   put folder_AddShort (projectFolder, "controllers") into controllerFolder
   put folder_ListStackPaths (controllerFolder) into controllerPaths
   
   # List module controllers
   put projectFolder & "modules/" into modulesFolder
   put folder_ListShort (modulesFolder) into moduleNames
   repeat for each line moduleName in moduleNames
      put module_ListControllerStackPaths (moduleName, projectFolder) into moduleControllerPaths
      put CR & moduleControllerPaths after controllerPaths
   end repeat
   delete char -1 of controllerPaths
   return controllerPaths
end project_ListAllControllers

command project_SetFoundStackFiles projectFolder
   put project_ConstructHomeStackPath (projectFolder) into projectHomeStackPath
   if exists (stack projectHomeStackPath) is false then return empty
   
   put project_FetchStackFileArray (projectFolder) into projectStackFileArray
   put stackFile_FromArray (projectStackFileArray) into projectStackFiles
   
   set the stackfiles of stack projectHomeStackPath to projectStackFiles
   return lcwStackFiles
end project_SetFoundStackFiles


--> Recent
-
function project_GetFolder projectName, pSubFolderPath
   -- utility to get a project folder from a project name for loaded or unloaded projects
   -- returns empty if the folder does not exist or there is another problem
   if exists (stack projectName) is true then
      put the project_Folder of stack projectName into projectFolder
   else
      put env_ConstructProjectFolder (projectName) into projectFolder
   end if
   folder_Add projectFolder, pSubFolderPath
   if there is not a folder projectFolder then return empty
   --
   return projectFolder
end project_GetFolder

command folder_Add @someFolder, pSubFolderPath
   switch
      case someFolder is empty
         return "Error, folder is empty"
      case pSubFolderPath is not empty
         if char 1 of pSubFolderPath = slash then delete char 1 of pSubFolderPath
         put pSubFolderPath after someFolder
         text_AddTrailing someFolder, slash
   end switch
   return empty
end folder_Add


--> Project | Start
-
/*
Used by display_Environmmeent project env menus
*/

command project_Start projectName, pForceLoad
   -- added forceload
   if exists (stack projectName) then
      put the name of stack projectName into homeStackObject
   else
      -- put env_GetProjectHomePath (projectName) into homeStackpath
      put library_FetchProjectHomeStackObject (projectName) into homeStackObject
      if exists (homeStackObject) is false then
         breakpoint
         display_DebugHistory "project_Start"
         return empty
      end if
   end if
   put the stack_Folder of stack projectName into projectFolder
   --
   display_Loading projectName
   --
   env_RecursivelyLoadProjects homeStackObject, pForceLoad -- not dispatching any more
   --
   project_InitialiseFolder projectFolder
   project_LoadModules projectName
   env_AddProject projectName, projectFolder -- here we could add modules in a different way
   --
   put merge ("Finished project '[[projectName]]'!") into someComment
   display_Loading projectName, someComment
   --
   return homeStackObject
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


--> LCW | New
-
getprop module_Names
   put the project_Folder of the target into projectFolder
   put projectFolder & "modules/" into modulesFolder
   put folder_ListShort (modulesFolder) into moduleNames
   return moduleNames
end module_Names

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

function env_ConstructProjectFolder projectName, pRepoFolder
   -- rename to env_GetFolder
   if pRepoFolder is empty then put env_GetRepoFolder() into pRepoFolder
   --
   put folder_AddShort (pRepoFolder, projectName) into projectFolder
   if there is a folder projectFolder then
      return projectFolder
   else
      return empty
   end if
end env_ConstructProjectFolder

function env_GetRepoFolder
   -- always loaded
   set the itemdelimiter to slash
   put the stack_Folder of stack "LCW" into envRootFolder
   delete item -1 of envRootFolder
   return envRootFolder
end env_GetRepoFolder

function folder_AddShort projectFolder, shortFolder
   text_AddTrailing projectFolder, slash
   if shortFolder is not empty then put shortFolder & slash after projectFolder
   return projectFolder
end folder_AddShort

function project_ListPaths shortFolder, projectFolder
   switch shortFolder
      case empty
         put project_ListAllStackPaths (projectFolder) into stackPaths
         return stackPaths
      case "modules"
         put folder_AddShort (projectFolder, "modules") into viewFolder
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
      case "all controllers"
         put project_ListAllControllers (projectFolder) into stackPaths
         return stackPaths
      default
         put folder_AddShort (projectFolder, shortFolder) into standardFolder
         put folder_ListStackPaths (standardFolder) into stackPaths
         return stackPaths
   end switch
end project_ListPaths

function lcw_GetAuthor
   put pref_GetValue ("userName") into authorName
   if authorName is empty then put "Anonymous" into authorName
   return authorName
end lcw_GetAuthor

command lcw_SetAuthor authorName
   pref_SetValue "userName", authorName
end lcw_SetAuthor

function project_FirstStackPath projectFolder
   get folder_ListStackPaths (projectFolder)
   return line 1 of it
end project_FirstStackPath


--> Project | Files
-
function project_ConstructHomeStackPath projectFolder
   -- project_FirstStackPath() is more robust
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

function lcw_HomeStackName
   return "LCW"
end lcw_HomeStackName


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
      --
      get the stackFile_Array of stack stackFilePath
      union stackFileArray with it
      --
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

function project_ConstructHomeFromFolder projectFolder
   set the itemdelimiter to slash
   put item -1 of projectFolder into homeStackName
   put projectFolder & homeStackName & ".livecode" into homeStackPath
   return homeStackPath
end project_ConstructHomeFromFolder


--> Props
-
getprop project_Name
   -- assume folder name = project name
   -- only works now for top level stacks, libs, models etc
   set the itemdelimiter to slash
   put the project_Folder of the target into projectFolder
   return item -1 of projectFolder
end project_Name

getprop project_Folder
   -- latest simplest version based on naming conventions and folder structure
   -- does not allow projects outside of the LCW reop folder  
   
   put the effective filename of the defaultstack into stackPath
   --
   set the itemdelimiter to slash
   put env_GetRepoFolder() into repoFolder
   put the number of items of repoFolder + 1 into itemNum
   put item 1 to itemNum of stackPath & slash into projectFolder
   --
   return projectFolder
end project_Folder

function library_FetchProjectFolder projectName, pRepoFolder
   -- put env_GetProjectFolder (projectName, pRepoFolder) into projectFolder
   -- put env_ConstructProjectFolder (projectName, pRepoFolder) into projectFolder
   --
   put library_FetchProjectArray (projectName) into projectArray
   put projectArray ["projectFolder"] into projectFolder
   
   if projectFolder is empty then return projectFolder
   text_AddTrailing projectFolder, slash   
   if there is a folder projectFolder then
      return projectFolder
   else
      return empty
   end if
end library_FetchProjectFolder


--> Env
-
function env_GetProjectFolder projectName
   -- not used
   -- prefer to use env_ConstructProjectFolder() now
   -- this fuction allows folders to be stored anywhere
   -- not just in a standardised repo folder.
   put env_GetActiveProjectArray() into envProjectArray
   return envProjectArray [projectName]
end env_GetProjectFolder

function env_ConstructHomePath projectName, pRepoFolder
   -- here we assume we have only one repoFolder with all project at top level
   -- see also "env_GetProjectHomePath"
   if pRepoFolder is empty then put env_GetRepoFolder() into pRepoFolder
   --
   put pRepoFolder & projectName & slash & projectName & ".livecode" into homePath
   return homePath
end env_ConstructHomePath

command env_SetProjectFolder homeStackName, pProjectFolder
   put env_GetActiveProjectArray() into envProjectArray
   if pProjectFolder is empty then
      delete variable envProjectArray [homeStackName]
   else
      put pProjectFolder into envProjectArray [homeStackName]
   end if
   env_SetActiveProjectArray envProjectArray
   return envProjectArray
end env_SetProjectFolder


--> Project | Menus
-
function project_ListPathSortedControllerNames projectName
   put project_GetFolder (projectName) into projectFolder
   -- put the project_Folder of stack projectName into projectFolder
   
   if there is not a folder projectFolder then return empty
   put project_ListAllControllers (projectFolder) into stackPaths
   --
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) then
         put the short name of stack stackPath into gMenuTitle
         put gMenuTitle & CR after gMenuTitles
      end if
   end repeat
   delete char -1 of gMenuTitles
   return gMenuTitles
end project_ListPathSortedControllerNames


--> LCW | Dialogues
-
command lcw_Answer someQuestion, pDisplayView, pQVar, pQVar2, pQVar3
   if exists (pDisplayView) then
      dispatch "lcw_Answer" to pDisplayView with someQuestion, empty, pQVar, pQVar2, pQVar3
      return the result
   end if
   put _ConstructDoScript (someQuestion, pQVar, pQVar2, pQVar3) into doScript
   if doScript is not empty then
      do doScript
      put merge (someQuestion) into someQuestion
   end if
   text_ReQuote someQuestion
   --
   answer someQuestion with "Cancel" or "OK" as sheet
   if it is "Cancel" then exit to top
   return it
end lcw_Answer

command lcw_AnswerWarning someQuestion, pDisplayView, pQVar, pQVar2, pQVar3
   -- this is an ugly hack to change the target to pDisplayView
   -- and easily make a mered someQuestion for answer dialogue
   if exists (pDisplayView) then
      dispatch "lcw_AnswerWarning" to pDisplayView with someQuestion, empty, pQVar, pQVar2, pQVar3
      exit to top
   end if
   put _ConstructDoScript (someQuestion, pQVar, pQVar2, pQVar3) into doScript
   if doScript is not empty then
      do doScript
      put merge (someQuestion) into someQuestion
   end if
   text_ReQuote someQuestion
   --
   answer warning someQuestion with "OK" as sheet
   exit to top
end lcw_AnswerWarning

private function _ConstructDoScript someQuestion, pQVar, pQVar2, pQVar3
   put text_GetMergeVars (someQuestion) into mergeVars
   repeat with lineNum = 1 to the number of lines of mergeVars
      put line lineNum of mergeVars into varName
      put lineNum + 1 into pNum
      put param (pNum) into pValue
      replace quote with "'" in pValue
      --
      if pValue is not empty then
         put "put" && kwote (pValue) && "into" && varName & CR after doScript
      end if
   end repeat
   delete char -1 of doScript
   return doScript
end _ConstructDoScript

function lcw_Ask someQuestion, pDefault, pDisplayView
   text_ReQuote someQuestion
   if exists (pDisplayView) then
      -- bug: sheet not working
      ask someQuestion with pDefault as sheet
   else
      ask someQuestion with pDefault
   end if
   put it into theResult
   if the result is "Cancel" then exit to top
   return theResult
end lcw_Ask

function module_ConstructFolder moduleName, projectName
   put module_ViewNameToShortFolder (moduleName) into moduleFolderName
   put project_GetFolder (projectName) into projectFolder
   put module_GetFolder (moduleFolderName, projectFolder) into moduleFolder
   return moduleFolder
end module_ConstructFolder

function module_GetFolder moduleShortFolder, projectFolder
   put folder_AddShort (projectFolder, "modules") into rootModuleFolder
   put rootModuleFolder & moduleShortFolder & slash into moduleFolder
   return moduleFolder
end module_GetFolder


--> Project | Folder | Contruct
-
function env_CheckLcwProject projectName
   -- here we assume we have only one repoFolder with all project at top level
   put env_ConstructHomePath (projectName) into homePath
   put there is a file homePath into projectExists
   return projectExists
end env_CheckLcwProject

function env_GetProjectHomePath projectName, pRepoFolder
   -- see also "env_ConstructHomePath"
   -- return empty if the project does not exist
   if pRepoFolder is empty then
      put env_GetRepoFolder() into pRepoFolder
   end if
   put env_ConstructProjectFolder (projectName, pRepoFolder) into projectFolder
   --
   put projectFolder & projectName & ".livecode" into projectHomeStackPath
   if there is a stack projectHomeStackPath then -- loads into memory
      return projectHomeStackPath
   else
      return empty
   end if
end env_GetProjectHomePath

function project_GetHomeStackName projectFolder
   put project_ConstructHomeStackPath (projectFolder) into projectHomeStackPath
   if exists (stack projectHomeStackPath) is false then return empty
   put the short name of stack projectHomeStackPath into projectName
   return projectName
end project_GetHomeStackName

function env_CheckLcwProject projectName, pRepoFolder
   -- here we assume we have only one repoFolder with all project at top level
   
   put env_GetProjectHomePath (projectName, pRepoFolder) into homePath
   put there is a file homePath into projectExists
   return projectExists
end env_CheckLcwProject


--> Not a good way
-
function project_FolderFromName projectName, pShortFolder
   -- this does not do much checking
   if exists (stack projectName) is false then return empty
   put the stack_Folder of stack projectName into projectFolder
   if pShortFolder is empty then return projectFolder
   put projectFolder & pShortFolder & slash into standardFolder
   return standardFolder
end project_FolderFromName


--> Environment | List
-
function env_ListLocalProjects
   put env_ListShortProjectFolders() into pProjectNames
   repeat for each line projectName in pProjectNames
      set the cursor to busy
      put env_CheckLcwProject (projectName) into isProject
      --
      if isProject is true then
         put projectName & CR after goodProjectNames
      end if
   end repeat
   --
   delete char -1 of goodProjectNames
   return goodProjectNames
end env_ListLocalProjects

function env_ListActiveProjects
   put env_GetActiveProjectArray() into envProjectArray
   return keys (envProjectArray)
end env_ListActiveProjects

function env_ListStoppedProjects
   put env_ListLocalProjects() into localProjects
   put env_GetActiveProjectArray() into envProjectArray
   repeat for each line localProject in localProjects
      put envProjectArray [localProject] into projectFolder
      if projectFolder is empty then
         put localProject & CR after stoppedProjects
      end if
   end repeat
   delete char -1 of stoppedProjects
   return stoppedProjects
end env_ListStoppedProjects


--> Project | Active
-
getprop project_IsActive
   put the project_Name of the target into projectName
   put env_ProjectIsActive (projectName) into someBoolean
   return someBoolean
end project_IsActive

function env_ProjectIsActive projectName, pRepoFolder
   put env_GetActiveProjectArray() into activeProjectArray
   put activeProjectArray [projectName] is not empty into projectIsLoaded
   -- put env_GetProjectFolder (projectName) is not empty into projectIsLoaded
   -- put env_ConstructProjectFolder (projectName, pRepoFolder) is not empty into projectIsLoaded
   return projectIsLoaded
end env_ProjectIsActive

function project_Exists projectName, pRepoFolder
   -- put env_GetProjectFolder (projectName) into projectFolder
   put env_ConstructProjectFolder (projectName, pRepoFolder) into projectFolder
   --
   if projectFolder is empty then
      return false
   else
      return true
   end if
end project_Exists


--> Events
-
on revEditScript
   -- sent by Livecode to registered plugins
   -- this is a hack to fix the losing of the behavior we add to the script editor handler list field.
   -- beep
   rev_AddBehaviorHacks
   pass revEditScript
end revEditScript


--> Props | Project
-
getprop project_DependencyArray
   put the project_Folder of the target into projectFolder
   env_DeconstructProjectFolder projectFolder, projectName, repoFolder
   put env_ConstructProjectDepArray (projectName, repoFolder) into projectDepArray
   return projectDepArray
end project_DependencyArray


--> LCW | Folders | List
-
function env_ListProjectFolders pListLong
   -- see also "env_ListActiveProjects()"
   put env_ConstructProjectFolder() into rootFolder
   if pListLong is true then
      put folder_ListLong (rootFolder) into lcwFolders
   else
      put folder_ListShort (rootFolder) into lcwFolders
   end if
   return lcwFolders
end env_ListProjectFolders

function env_ListShortProjectFolders
   put env_GetRepoFolder() into repoFolder
   put folders (repoFolder) into shortFolders
   delete line 1 of shortFolders
   sort shortFolders
   return shortFolders
end env_ListShortProjectFolders


--> Env
-
command env_AddProject homeStackName, pProjectFolder
   if exists (stack homeStackName) is false then return false
   if pProjectFolder is empty then
      -- put library_FetchProjectFolder (homeStackName) into pProjectFolder
      put env_ConstructProjectFolder (projectName) into pProjectFolder
   else
      if there is not a folder pProjectFolder then
         return false
      else
         library_StoreProjectFolder homeStackName, pProjectFolder
      end if
   end if
   if there is not a folder pProjectFolder then return false
   
   env_SetProjectFolder homeStackName, pProjectFolder
   return true
end env_AddProject

command env_RemoveProject projectName
   put env_GetActiveProjectArray() into envProjectArray
   delete variable envProjectArray [projectName]
   env_SetActiveProjectArray envProjectArray
end env_RemoveProject

function env_GetActiveProjectArray
   global gLCW
   put gLCW ["environment"]["project"] into activeProjectArray
   return activeProjectArray
end env_GetActiveProjectArray

command env_SetActiveProjectArray activeProjectArray
   global gLCW
   put activeProjectArray into gLCW ["environment"]["project"]
   return gLCW
end env_SetActiveProjectArray


--> Project
-
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


--> Project | Folder | Guess
-
function lcw_GuessLcwHomePath pHomePath
   -- only works now for top level stacks, libs, models etc
   if pHomePath is empty then put the effective filename of the defaultstack into pHomePath
   set the itemdelimiter to slash
   
   -- hack (simple check "project_FindFolder()")
   get item -2 of pHomePath
   if it is among the items of "libraries/models/controllers/stacks/views/behaviors" then
      -- not accounting for modules
      put "lcw/lcw.livecode" into item -3 to -1 of pHomePath
   else
      put "lcw/lcw.livecode" into item -2 to -1 of pHomePath
   end if
   
   return pHomePath
end lcw_GuessLcwHomePath

function lcw_GetProjectFolder projectHomePath
   set the itemdelimiter to slash
   put lcw_GuessLcwHomePath (projectHomePath) into lcwHomePath
   
   -- let's check that stack LCW.livecode is there (will load stack into memory but not initialise)
   if there is a stack lcwHomePath then
      put item 1 to (the number of items of lcwHomePath - 1) of projectHomePath into projectFolder
      put slash after projectFolder
      return projectFolder
   else -- could check for the stack being a module here
      return empty
   end if
end lcw_GetProjectFolder


--> Project | Folder | Old
-
function project_FindFolder somePath
   -- assumes somePath is a path to a stack or file and not a folder
   -- returns the top module or "project folder"
   put somePath into someFolder
   set the itemdelimiter to slash
   put empty into item -1 of someFolder
   
   project_FindFromFolder someFolder, homeStackName, projectFolder, homeStackPath
   return projectFolder
end project_FindFolder


--> Env
-
/*
Can we move this to "model_Environment"
*/

command env_DeconstructProjectFolder projectFolder, @projectName, @repoFolder
   set the itemdelimiter to slash
   put item -1 of projectFolder into projectName
   put item 1 to -2 of projectFolder & slash into repoFolder
end env_DeconstructProjectFolder

function env_ConstructProjectDepArray projectName, repoFolder
   local projectDepArray
   env_CrawlProjectDeps projectDepArray, projectName, repoFolder
   return projectDepArray
end env_ConstructProjectDepArray

command env_CrawlProjectDeps @projectDepArray, projectName, repoFolder
   -- we do not assume the project home stack is loaded into memory
   -- we base everything on naming conventions, and folder structure
   
   -- first we check for recursion
   if projectDepArray [projectName] is an array then
      return "Already added to projectDepArray"
   end if
   
   -- now let's guess the projectHomeStackPath
   put env_GetProjectHomePath (projectName, repoFolder) into stackPath
   if stackPath is empty then
      put merge ("Project home stack does not exist!") into projectDepArray [projectName]["Error"]["msg"]
      put projectName into projectDepArray [projectName]["Error"]["projectName"]
      put stackPath into projectDepArray [projectName]["Error"]["path"]
      return "Already indexed"
   else
      put stackPath into projectDepArray [projectName]["path"]
   end if
   
   -- now recurse
   put the project_Deps of stack projectName into projectDeps
   repeat for each item nextProjectName in projectDeps
      env_CrawlProjectDeps projectDepArray, nextProjectName, repoFolder
   end repeat
   return "Finished deps"
end env_CrawlProjectDeps

command env_DisplayErrorLoading projectName, projectDepArray
   try
      put projectDepArray [projectName]["error"] into errorArray
      throw "LCW Dep Error"
   catch e
      put "Error loading dependency" && projectName
   end try
end env_DisplayErrorLoading

command env_DisplayLoading projectName
   -- tell the word we found project dependency
   put "Loading project '[[projectName]]'..." into commentTemplate
   put merge (commentTemplate) into someComment
   dispatch "lcw_Notify" with someComment,"Loading projects"
end env_DisplayLoading


--> LCW | Initialise
-
command env_RecursivelyLoadProjects pObject, pForceLoad
   -- think this does the same as old "project_Init" (which is a better name)
   -- order of loading must not be unimportant
   if pObject is empty then put the long id of the target into pObject
   
   put the project_DependencyArray of pObject into projectDepArray
   --
   set the itemdelimiter to slash
   repeat for each key projectName in projectDepArray
      set the cursor to busy
      put projectDepArray [projectName]["path"] into homeStackPath
      if homeStackPath is empty then
         -- something like "lcw_User", but that is OK let's skip
         next repeat
      end if
      env_SimpleLoadProject projectName, homeStackPath, pForceLoad
   end repeat        
end env_RecursivelyLoadProjects

command lcw_LoadCustomUserProject pForceLoad
   -- initialises non-version controlled private project
   put lcw_UserProjectFolder() into lcwUserProjectFolder
   project_InitialiseFolder lcwUserProjectFolder
   
   put lcw_UserHomeStackName() into userHomeStackName
   put lcw_UserProjectFolder() into lcwUserProjectFolder
   library_StoreProjectFolder userHomeStackName, lcwUserProjectFolder 
   if there is a stack userHomeStackName then
      put the name of stack userHomeStackName into homeStackObject
      env_RecursivelyLoadProjects homeStackObject, pForceLoad
   end if
end lcw_LoadCustomUserProject

command project_LoadDeps projectDeps, projectHomeStackFile
   replace comma with CR in projectDeps   
   repeat for each line sisterProjectName in projectDeps
      -- put env_GetProjectFolder (sisterProjectName) into sisterProjectFolder
      put env_ConstructProjectFolder (sisterProjectName) into sisterProjectFolder
      if sisterProjectFolder is not empty then next repeat -- already loaded
      
      display_Loading sisterProjectName
      put project_ConstructSisterHomeStackPath (sisterProjectName, projectHomeStackFile) into sisterProjectHomeStackPath
      
      if exists (stack sisterProjectHomeStackPath) is false then
         breakpoint
         next repeat
      end if
      dispatch "env_RecursivelyLoadProjects" to stack sisterProjectHomeStackPath -- was "project_Init"
      -- go to stack sisterProjectHomeStackPath
   end repeat
end project_LoadDeps


--> Env | Load projects
-
command env_SimpleLoadProject projectName, homeStackPath, pForceLoad
   -- just initialise the project itself (nothing recursive)
   -- safe recusive collection of deps was handled with "env_ConstructProjectDepArray()"
   
   put env_ProjectIsActive (projectName) into isLoaded
   if isLoaded and pForceLoad is not true then
      return merge ("Already loaded project [[projectName]]. Not re-laoding")
   end if
   --
   project_InitialiseFolder homeStackPath
   project_LoadModules homeStackPath
   
   -- opportunity to customise (see "lcw_Authoring")
   dispatch "project_CustomInit" to stack homeStackPath
   switch it
      case "handled"
      case "unhandled"
      case "passed"
   end switch
   
   -- prety display as everything is slow
   env_DisplayLoading projectName
   return empty
end env_SimpleLoadProject


--> Display
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
   text_ReQuote someMessage
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
command env_ExportMenusAndStackFiles pListAll
   put env_ListActiveProjects (pListAll) into projectNames
   repeat for each line projectName in projectNames
      set the cursor to busy
      put project_GetFolder (projectName) into projectFolder
      project_ExportMenusAndStackFiles projectFolder
   end repeat
end env_ExportMenusAndStackFiles

command env_LoadMenusAndStackFiles
   put env_ListActiveProjects() into projectNames
   repeat for each line projectName in projectNames
      set the cursor to busy
      put project_GetFolder (projectName) into projectFolder
      project_LoadMenusAndStackFiles projectFolder
   end repeat
end env_LoadMenusAndStackFiles

command env_LoadMenus
   put env_ListActiveProjects() into projectNames
   repeat for each line projectName in projectNames
      put project_GetFolder (projectName) into projectFolder
      project_LoadMenus projectFolder, true
   end repeat
end env_LoadMenus

command project_InitialiseFolder projectFolderOrHomeStackFile
   -- is use to initialise mmodules as well
   
   put projectFolderOrHomeStackFile into projectFolder
   if char -1 of projectFolderOrHomeStackFile is not slash then
      set the itemdelimiter to slash
      put empty into item -1 of projectFolder
   end if
   
   put project_ListUsedPathsFromFolder (projectFolder) into usedStackPaths
   stack_StartUsedPaths usedStackPaths
   --
   project_LoadMenusAndStackFiles projectFolder -- loads from stored project_Array
   --
   put project_GetHomeStackName (projectFolder) into homeStackName
   env_AddProject homeStackName, projectFolder -- here we could add modules in a different way
   return homeStackName
end project_InitialiseFolder

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


--> Project | Names
-
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

getprop project_HomeStack
   -- searches the disk based file hierearchy to find the project root
   put the stack_Object of the target into stackObject
   put the effective filename of stackObject into stackPath
   
   put project_FindHomeStackPath (stackPath) into projectStackPath
   if projectStackPath is empty then return empty
   
   put the name of stack projectStackPath into stackObject
   return stackObject 
end project_HomeStack


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


--> Project | List
-
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


--> Project | List | Files
-
function project_ListUsedPathsFromFolder projectFolder
   local projectUsedStackPaths
   repeat for each item shortFolder in "libraries,models"
      put folder_AddShort (projectFolder, shortFolder) into standardFolder
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

command folder_CreateNested someFolder
   if there is a folder someFolder then return empty   
   set the itemdelimiter to "/"
   repeat with itemNum = 2 to the number of items of someFolder
      put item 1 to itemNum of someFolder & "/" into testFolder
      if there is a folder testFolder then next repeat
      create folder testFolder
   end repeat
   text_AddTrailing someFolder, slash
   return someFolder
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

getprop stackfile_Array
   put the stack_Object of the target into someStack
   put the stackfiles of someStack into stackFileArray
   split stackFileArray by CR and comma
   return stackFileArray
end stackfile_Array

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

command text_ReQuote @someText
   replace "'" with quote in someText
end text_ReQuote

command text_AddTrailing @someText, someChar
   if char -1 of someText is not someChar then
      put someChar after someText
   end if
end text_AddTrailing

function text_GetMergeVars mergeText
   -- put text_GetBetween ("[[", "]]", someText, startAfterCharNum)
   put "\[\[" into someReg
   put "[^\]]*" into notaSquareClosingBracket
   put "(" & notaSquareClosingBracket & ")" after someReg
   put "\]\]" after someReg
   --
   repeat 100 -- for safety
      if matchChunk (mergeText, someReg , startMatch, endMatch) is true then
         put char startMatch to endMatch of mergeText into varName
         put varName & CR after varNames
         delete char 1 to (endMatch + 2) of mergeText
      else
         delete char -1 of varNames
         return varNames
      end if
   end repeat
end text_GetMergeVars
