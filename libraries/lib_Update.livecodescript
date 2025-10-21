script "lib_Update"
--> MetaData
-
license: GPLv3
name: lib_Update
type: library
version: 0.7

/*
Used by the behavior (if running LCW), of the ScriptEditor Apply button. 
This behavior is the LCW Project stack behavior_IdeCompileButton.

Consider simplifying the export to make it a straight unicode script.
We can split into handlers later when we need.
*/


--> Working on
-
command script_ExportAndIndexMenus scriptObject
   -- IDE compile button dispatches "script_ExportAndIndexMenus"
   -- Must be sent after the script is applied.
   
   ## Export Handlers to text files
   script_ExportHandlersAndCalls scriptObject
   put the result into scriptPlaceArray
   put the uRIP["type"] of scriptObject into scriptType
   --
   if the script_IsDifferent of scriptObject is true then
      -- put the script_Diff of scriptObject 
   end if
   
   ## Update Global Menu Index
   if scriptType = "controller" then
      dispatch "menu_ReIndexController" with scriptObject
      put the result into projectArray
   end if
end script_ExportAndIndexMenus

command script_ExportHandlersAndCalls someObject, pExportCalls, pScript
   global gLCW
   
   put the dataObject_Folder [false] of someObject into dataFolder
   folder_CreateFromFile dataFolder
   if pScript is empty then put the script of someObject into pScript
   
   urip_Update someObject, pScript
   
   put the revAvailableHandlers of someObject into handlerTable
   sort numeric handlerTable by word 3 of each
   if handlerTable is empty then return empty -- everything is deleted before re-exporting
   
   -- this also deletes the "lcw_calls.txt" files
   -- which is fine if we are rebuilding them
   -- revDeleteFolder dataFolder -- if disabled old removed handlers also archived
   
   put pScript into mergeScript
   put revRuggedID (someObject) into rObject
   sort numeric descending handlerTable by word 3 of each -- from bottom up
   repeat for each line handlerTableLine in handlerTable
      set the cursor to busy
      put word 1 of handlerTableLine into hType
      put word 2 of handlerTableLine into hName
      if hName = "_" then next repeat -- could check handler is empty
      put word 3 of handlerTableLine into startLineNum
      put word 4 of handlerTableLine into endLineNum
      put line startLineNum to endLineNum of pScript into someHandler
      handler_Save handlerTableLine, dataFolder, someHandler, pExportCalls
      put "[[ _FetchHandler (" & hName, hType & ") ]]" into line startLineNum to endLineNum of mergeScript
      
      put word 1 to 2 of handlerTableLine into shortHkeyLine
      put word 3 to 4 of handlerTableLine into hkeyLineNums
      put hkeyLineNums into gLCW ["Hkey Place Array"][shortHkeyLine][rObject]
      
      -- as we may wish to know the local place array
      put hkeyLineNums into scriptPlaceArray [shortHkeyLine][rObject]
   end repeat
   
   put textStack_ScriptFile (dataFolder, false) into scriptFile
   text_Set scriptFile, mergeScript
   return scriptPlaceArray
end script_ExportHandlersAndCalls

command menu_ReIndexController mController
   project_AddToKnown mController
   menu_AddToProjectArray mController
   put the result into projectArray
   -- menu_AddToModel mController -- no longer using menu model?
   return projectArray
end menu_ReIndexController

getprop template_StackFileArray
   put the view_Name of the target into viewName
   put default_FirstStackControl (viewName) into tObject
   if exists (tObject) is false then return empty
   
   put the stackFile_Array of tObject into stackFileArray
   return stackFileArray
end template_StackFileArray

getprop template_Behaviors
   put the view_Name of the target into viewName
   put default_FirstStackControl (viewName) into tObject
   if exists (tObject) is false then return empty
   
   put the behavior_Objects of tObject into bObjects
   return bObjects
end template_Behaviors

getprop menuBar_StackFileArray
   put the view_Object of the target into moduleObject
   put _MenuBarStackFileArray (moduleObject) into mStackFileArray
   return mStackFileArray
end menuBar_StackFileArray


--> Props
-
setprop menu_Update someBoolean
   -- called by "script_ExportAndIndexMenus" every time we apps (compile) a scriptField 
   put the long id of the target into mController
   menu_ReIndexController mController
   put the result into projectArray
   return projectArray
end menu_Update

getprop script_Diff [pContextLineNums]
   if pContextLineNums is not a number then put 0 into pContextLineNums
   --
   put the script of the target into controlScript
   put the exported_Script of the target into exportedScript
   --
   put DiffCompare (controlScript, exportedScript, pContextLineNums) into uDiff
   return uDiff
end script_Diff


--> Module | Update
-
getprop module_StackFileArray
   put the view_Name of the target into vName
   if vName is empty then return empty
   put default_FirstStackControl (vName) into vObject
   if exists (vObject) then
      put the stackFile_Array of vObject into stackFileArray
      return stackFileArray
   else
      return empty
   end if
end module_StackFileArray

command module_ExportMenusAndStackFiles moduleFolder
   put module_ConstructArray (moduleFolder) into moduleArray
   
   # Store ModuleArray
   project_StoreArray moduleFolder, moduleArray
   return moduleArray
end module_ExportMenusAndStackFiles

on module_Rename oldModuleStackName, newModuleStackName, projectName
   -- do a whole bunch of safety checks
   if exists (stack oldModuleStackName) is false then
      lcw_AnswerWarning "Cannot locate module stack to rename!"
   end if
   
   put the filename of stack oldModuleStackName into oldFilePath
   put the project_Folder of stack oldModuleStackName into projectFolder
   put the module_Folder of stack oldModuleStackName into oldModuleFolder
   --
   if there is not a folder projectFolder then
      lcw_AnswerWarning "Project folder does not exist!"
   end if
   if there is not a folder oldModuleFolder then
      lcw_AnswerWarning "Module folder does not exist!"
   end if
   
   put env_ListShortModuleFolders() into allModuleNames
   if exists (stack newModuleStackName) then
      go to stack newModuleStackName
      lcw_AnswerWarning "Stack already exists!"
   end if
   -- check in all module names
   if newModuleStackName is among the lines of allModuleNames then
      -- display_ListModules
      display_ModuleArray
      lcw_AnswerWarning "Module already exists!"
   end if
   
   put label_PipesToUnderscore (newModuleStackName) into newShortModuleFolder
   put oldModuleFolder & newShortModuleFolder & ".livecode" into tempModulePath
   put project_GetModuleFolder (newShortModuleFolder, projectName) into newModuleFolder
   put the long id of control 1 of cd 1 of stack oldModuleStackName into viewObject
   
   -- rename view and stack, then save before closing
   set lockmessages to true
   set the view_Name of viewObject to newModuleStackName
   set the filename of stack oldModuleStackName to tempModulePath
   set the name of stack oldModuleStackName to newModuleStackName
   save stack newModuleStackName
   set lockmessages to false
   
   put the module_StackPaths of stack newModuleStackName into stackPaths
   --
   stack_Close stackPaths
   rename folder oldModuleFolder to newModuleFolder
   project_LoadFromFolder newModuleFolder
   go to stack newModuleStackName
   --
   -- reindex project and just in case newModuleFolder
   -- project_ExportMenusAndStackFiles projectFolder
   
   # Construct project array and Store it
   put project_ConstructArrayFromFolder (newModuleFolder) into projectArray
   project_StoreArray newModuleFolder, projectArray
end module_Rename

function module_ConstructArray moduleFolder
   -- depends on private handlers "_AddControllersToProjectArray"
   local moduleArray
   put directory_NestedStackFileArray (moduleFolder, "assets") into stackFileArray
   if stackFileArray is empty then
      return empty
   else
      put stackFileArray into moduleArray ["stackFileArray"]
   end if
   
   # Add controllers to array
   put folder_AddShort (moduleFolder, "controllers") into controllerFolder
   put folder_ListStackPaths (controllerFolder) into controllerPaths
   --
   _AddControllersToProjectArray moduleArray, moduleFolder, controllerPaths
   --
   return moduleArray
end module_ConstructArray


--> Deps
-
command module_Update mStackName, pRepoFolder
   set the cursor to watch
   put default_FirstStackControl (mStackName, pRepoFolder) into mObject
   
   module_UpdateStackFiles mObject
   
   # Export Arrays as json
   module_ExportArray mObject
   put the result into mArray
   
   # Set the default behaviors
   set the module_Behaviors of mObject to true
   
   # Save
   stack_Save mObject
   
   return mArray
end module_Update

command module_ExportArray moduleObject
   put the module_Folder of moduleObject into moduleFolder
   put module_ConstructArray (moduleFolder) into moduleArray
   
   # Store ModuleArray
   project_StoreArray moduleFolder, moduleArray
   return moduleArray
end module_ExportArray

command module_UpdateStackFiles moduleObject
   # Set module stackfiles
   put the folder_StackFileArray of moduleObject into stackFileArray
   put the stackFile_Array of moduleObject into oStackFileArray
   union stackFileArray with oStackFileArray
   
   # Add menubar_View stackFiles
   put _MenuBarStackFileArray (moduleObject) into mStackFileArray
   union stackFileArray with mStackFileArray
   
   set the stackFile_Array of moduleObject to stackFileArray
   return stackFileArray
end module_UpdateStackFiles

command project_UpdateArray projectName
   if exists (stack projectName) is false then return empty
   
   # Construct projectArray and save (including modules)
   put the project_Folder of stack projectName into projectFolder
   project_ExportMenusAndStackFiles projectFolder
   put the result into projectArray
   
   # Set project home stackfiles (requires lib_StackFiles)
   put projectArray ["stackFileArray"] into stackFileArray
   set the stackfile_Array of stack projectName to stackFileArray
   save stack projectName
   
   return projectArray
end project_UpdateArray

command project_ExportMenusAndStackFiles projectFolder 
   # Construct project array and update global menu array
   put project_ConstructArrayFromFolder (projectFolder) into projectArray
   
   # Store project array
   project_StoreArray projectFolder, projectArray
   
   return projectArray
end project_ExportMenusAndStackFiles

command stackFile_FixStackFiles projectName
   put project_ConstructStackFileArray (projectName) into stackFileArray
   set the stackfile_Array of stackFileStack to stackFileArray
   put the result into stackFileTable
   --
   put stackFileTable into resultArray ["stackFileTable"]
   return resultArray
end stackFile_FixStackFiles

command env_ExportMenusAndStackFiles pListAll
   put env_ListActiveProjects (pListAll) into projectNames
   repeat for each line projectName in projectNames
      set the cursor to busy
      project_UpdateArray projectName
      if the result is empty then
         lcw_Notify "problem locatig project!", projectName
      end if
   end repeat
end env_ExportMenusAndStackFiles

command project_UseStackFiles projectName, pFixFirst
   if exists (stack projectName) is false then
      breakpoint
      return empty
   end if
   
   put the project_Folder of stack projectName into projectFolder
   if pFixFirst is true then
      project_UpdateArray projectName
      put the result into projectArray
   else
      put project_ConstructArrayFromFolder (projectFolder) into projectArray
   end if
   --
   put project_ListUsedPathsFromArray (projectArray, projectFolder) into usedStackPaths
   use_StackNames usedStackPaths
   --
   return projectArray
end project_UseStackFiles

function project_ConstructArray projectName
   if exists (stack projectName) is false then return empty
   
   put the project_Folder of stack projectName into projectFolder
   put project_ConstructArrayFromFolder (projectFolder) into projectArray
   return projectArray
end project_ConstructArray

function project_ConstructArrayFromFolder projectFolder
   # Add stackFiles
   put project_ConstructStackFileArrayFromFolder (projectFolder) into stackFileArray
   put stackFileArray into projectArray ["stackFileArray"]
   
   # Add controllers (includes modules)
   put project_ListAllControllers (projectFolder) into controllerPaths
   _AddControllersToProjectArray projectArray, projectFolder, controllerPaths
   
   return projectArray
end project_ConstructArrayFromFolder

function project_ListControllersFromArray projectArray, projectFolder
   text_AddTrailing projectFolder, slash
   put projectArray ["stackFileArray"] into stackFileArray
   set the itemdelimiter to slash
   repeat for each key stackName in stackFileArray
      put stackFileArray [stackName] into relPath
      if "controllers" is among the items of relPath then
         put projectFolder & relPath & CR after controllerPaths 
      end if
   end repeat
   delete char -1 of controllerPaths
   return controllerPaths
end project_ListControllersFromArray


--> Project | StackFileArray
-
function project_ConstructStackFileArray projectName
   if exists (stack projectName) is false then
      breakpoint
      return empty
   end if
   
   put the project_Folder of stack projectName into projectFolder
   put project_ConstructStackFileArrayFromFolder (projectFolder)into stackFileArray
   return stackFileArray
end project_ConstructStackFileArray

function project_ConstructStackFileArrayFromFolder projectFolder
   put directory_NestedStackFileArray (projectFolder, "assets") into stackFileArray
   if stackFileArray is empty then return empty
   
   # No need to add path to home stack file
   set the itemdelimiter to slash
   put item -1 of projectFolder into homeStackName
   --
   delete variable stackFileArray [homeStackName]
   return stackFileArray
end project_ConstructStackFileArrayFromFolder

function project_FetchStackFileArray projectFolder
   put directory_NestedStackFileArray (projectFolder, "assets") into stackFileArray
   if stackFileArray is empty then return empty
   
   # No need to add path to home stack file
   put project_ConstructHomeFromFolder (projectFolder) into homeStackPath
   put the short name of stack homeStackPath into homeStackName
   --
   delete variable stackFileArray [homeStackName]
   return stackFileArray
end project_FetchStackFileArray


--> Menu | Working on
-
command menu_AddToProjectArray mController, pChecks
   put the menu_GlobalTitle of mController into gMenuTitle
   if gMenuTitle is empty then return "Error, gMenuTitle for mController is faulty:" && mController
   --
   put the project_Name of mController into projectName
   put the project_JsonFile of mController into projectArrayFile
   put array_FromFile (projectArrayFile) into projectArray
   _AddMenuTile projectArray, gMenuTitle, mController, projectName
   array_ToFile projectArrayFile, projectArray
   --
   return projectArray
end menu_AddToProjectArray


--> Env | Fix
-
command env_LoadMenusAndStackFiles
   put env_ListActiveProjects() into projectNames
   repeat for each line projectName in projectNames
      set the cursor to busy
      put project_GetFolder (projectName) into projectFolder
      project_LoadFromFolder projectFolder
   end repeat
end env_LoadMenusAndStackFiles

command script_UpdatePlaceArray someObject
   -- brute force (not optimised for speed)
   hkeyLine_LoadPlaceArray
   hkeyline_DeletePlaceObject someObject
   put hkeyLine_GetPlaceArray() into hkeyPlaceArray
   hkeyline_AddPlaceObject hkeyPlaceArray, someObject
   hkeyLine_SetPlaceArray hkeyPlaceArray
   script_StoreHkeyPlaceArray hkeyPlaceArray
   return hkeyPlaceArray
end script_UpdatePlaceArray


--> Directory | Walk
-
function directory_NestedStackFileArray someFolder, pWithoutFolder
   if there is not a folder someFolder then return empty
   
   # Walk 
   set the itemdelimiter to slash
   put the number of items of someFolder into baseFolderNum
   --
   -- put directory_ListNestedPaths (someFolder) into nPaths
   put directory_ListStackPaths (someFolder, pWithoutFolder) into nPaths
   --
   repeat for each line sFile in nPaths
      if exists (stack sFile) then
         put the short name of stack sFile into stackName
         delete item 1 to baseFolderNum of sFile
         put sFile into sFileArray [stackName]
      end if
   end repeat
   return sFileArray
end directory_NestedStackFileArray


--> Private 
-
private function _MenuBarStackFileArray moduleObject
   put the menubar_View of moduleObject into mBarGroup
   switch
      case exists (mBarGroup) is false
         -- not a menubar_View
      case mBarGroup = moduleObject
         -- it's the menubar group module no need to add
         return empty
      default
         -- see "module_StackFileArray"
         put the view_Name of mBarGroup into mBarViewName
         put default_FirstStackControl (mBarViewName) into mBarTemplateObject
         if exists (mBarTemplateObject) then
            put the stackFile_Array of mBarTemplateObject into mStackFileArray
            return mStackFileArray
         else
            return empty
         end if
   end switch
end _MenuBarStackFileArray

private command _AddControllersToProjectArray @projectArray, projectFolder, controllerPaths, pDontUpdateGlobal
   put menu_GetModel() into menuGlobalArray
   --
   set the itemdelimiter to slash
   put item -1 of projectFolder into projectName
   repeat for each line controllerPath in controllerPaths
      set the cursor to busy  
      if exists (stack controllerPath) is false then next repeat
      put the name of stack controllerPath into mController
      
      # Check mController Nad get gMenuTitle
      put line 1 of the menu_GlobalTitle [false] of mController into gMenuTitle
      if gMenuTitle is empty then
         put empty into badMenuArray [mController] 
         next repeat
      end if
      
      # Add gMenuTitle to projectArray of project projectName
      _AddMenuTile projectArray, gMenuTitle, mController, projectName
      
      # Add to Old global 
      if pDontUpdateGlobal is not true then
         -- menu_AddToGlobalArray menuGlobalArray, gMenuTitle, mController, projectName
      end if
   end repeat
   --
   menu_SetModel menuGlobalArray
   return badMenuArray
end _AddControllersToProjectArray

private command _AddMenuTile @projectArray, gMenuTitle, mController, projectName
   -- delete variable projectArray ["Global Menus"][gMenuTitle] -- just for tyding old stuff
   --
   put revRuggedId (mController) into mController
   put mController into projectArray ["Global Menus"][gMenuTitle]["mController"]
   put projectName into projectArray ["Global Menus"][gMenuTitle]["projectName"]
end _AddMenuTile

private command _WalkAndList @NestedPaths, someFolder, pBaseFolderNum
   put files (someFolder) into shortFiles
   put someFolder into pathFolder
   if pBaseFolderNum is a number then
      set the itemdelimiter to slash
      delete item 1 to pBaseFolderNum of pathFolder
   end if
   
   # Add files (not folders) to NestedPaths
   -- filter shortFiles without ".*"
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
