script "model_ScriptHierarchy"
--> MetaData
-
license: GPLv3
name: model_ScriptHierarchy
type: model
version: 0.2


--> Working on
-

--> Script| Hierarchy
-
getprop hkey_ScriptHierarchy [externalObjects]
   if externalObjects is empty then
      put stack_PathsToObjects (the stacksinUse) into externalObjects
   end if
   put the long id of the target into targetObject
   put the behavior_Objects of the target into bObjects
   
   -- let's just do used stacks for now
   put bObjects & CR & externalObjects into scriptHierarchy
   put word 1 to -1 of scriptHierarchy into scriptHierarchy
   --
   return scriptHierarchy
end hkey_ScriptHierarchy

getprop script_Hierarchy [pProjectName]
   -- surpisingly complex dependencies if we include pProjectName
   put the long id of the target into targetObject
   put the object_Hierarchy of targetObject into scriptHierarchy
   hkey_AddDevelopmentHierarchy scriptHierarchy, pProjectName
   return scriptHierarchy
end script_Hierarchy

getprop object_Hierarchy
   put the long id of the target into targetObject
   repeat
      put revRuggedID (targetObject) & CR after hObjects
      put targetObject into someObject
      repeat
         put the behavior of someObject  into bObject
         if exists (bObject) is false then exit repeat
         
         put revRuggedId (bObject) & CR after hObjects
         put bObject into someObject
      end repeat
      
      if word 4 of targetObject is not "of" then
         delete char -1 of hObjects
         return hObjects
      end if
      
      delete word 1 to 4 of targetObject
   end repeat
end object_Hierarchy


--> Script| Hierarchy | Development
-
function env_ScriptHierarchy
   put stack_PathsToObjects (the stacksinUse) into usedStacks
   put env_ListFrontScripts() into frontObjects
   put env_ListBackScripts() into backObjects
   --
   object_AddBehaviors usedStacks
   object_AddBehaviors frontObjects
   object_AddBehaviors backObjects
   script_AddLibrariesToHierarchy scriptHierarchy, frontObjects, usedStacks, backObjects
   --
   return scriptHierarchy
end env_ScriptHierarchy

command hkey_AddDevelopmentHierarchy @scriptHierarchy, pProjectName
   local frontObjects, usedStacks, backObjects
   
   switch pProjectName
      case empty
         put stack_PathsToObjects (the stacksinUse) into usedStacks
         put env_ListFrontScripts() into frontObjects
         put env_ListBackScripts() into backObjects
         break
      case "none"
         break
      default
         put project_ListUsedDeps (pProjectName) into usedStacks
         put project_ListFrontDeps (pProjectName) into frontObjects
         put project_ListBackScripts (pProjectName) into backObjects
   end switch
   
   object_AddBehaviors usedStacks
   object_AddBehaviors frontObjects
   object_AddBehaviors backObjects
   script_AddLibrariesToHierarchy scriptHierarchy, frontObjects, usedStacks, backObjects
end hkey_AddDevelopmentHierarchy

command object_AddBehaviors @objectIndex
   repeat for each line someObject in objectIndex
      if exists (someObject) is false then next repeat 
      put the behavior of someObject into objectBehavior
      if exists (objectBehavior) then
         put revRuggedId (objectBehavior) & CR after newObjectIndex
      end if
      put someObject & CR after newObjectIndex
   end repeat
   delete char -1 of newObjectIndex
   put newObjectIndex into objectIndex
end object_AddBehaviors

command script_AddLibrariesToHierarchy @objectIndex, frontObjects, usedStacks, backObjects 
   if usedStacks is not empty then put usedStacks & CR before objectIndex
   if backObjects is not empty then put backObjects & CR before objectIndex
   if frontObjects is not empty then put CR & frontObjects after objectIndex
end script_AddLibrariesToHierarchy


--> Deps
-
function stack_PathsToObjects stackNameOrPaths
   repeat for each line stackName in stackNameOrPaths
      if exists (stack stackName) is false then next repeat
      put the name of stack stackName & CR after stackObjects
   end repeat
   delete char -1 of stackObjects
   return stackObjects
end stack_PathsToObjects

command ide_FilterOutStacks @longIDs
   put rev_AppContentsFolder() into revAppContentsFolder
   
   set the itemdelimiter to slash
   repeat for each line tObject in longIDs
      if exists(tObject) is false then next repeat
      put token -1 of tObject into stackPath
      if stackPath begins with revAppContentsFolder then next repeat
      put revRuggedId (tObject) & CR after filteredObjects
   end repeat
   delete char -1 of filteredObjects
   put filteredObjects into longIDs
end ide_FilterOutStacks

function env_ListFrontScripts
   -- /Applications/LiveCode Community 8.1.0 (dp 3).app/Contents/Tools/Toolset/libraries/revshortcutslibrary.livecodescript
   put the frontscripts into longIDs
   ide_FilterOutStacks longIDs
   return longIDs
end env_ListFrontScripts

function env_ListBackScripts
   -- /Applications/LiveCode Community 8.1.0 (dp 3).app/Contents/Tools/Toolset/libraries/revshortcutslibrary.livecodescript
   put the backscripts into longIDs
   ide_FilterOutStacks longIDs
   return longIDs
end env_ListBackScripts

function rev_AppToolsFolder
   put rev_AppContentsFolder() & "Tools/" into revToolsLibraryFolder
   return revToolsLibraryFolder
end rev_AppToolsFolder

function rev_ToolsLibraryFolder
   put rev_AppContentsFolder() & "Tools/Toolset/libraries/" into revToolsLibraryFolder
   return revToolsLibraryFolder
end rev_ToolsLibraryFolder

function rev_AppContentsFolder
   -- /Applications/LiveCode Community 8.1.0 (dp 3).app/Contents/
   set the itemdelimiter to slash
   put the engine folder into appContentsFolder
   put empty into item -1 of appContentsFolder
   return appContentsFolder
end rev_AppContentsFolder

getprop behavior_Objects
   put the long id of the target into targetObject
   put behavior_GetHierarchy (targetObject) into bObjects
   return bObjects
end behavior_Objects

function behavior_GetHierarchy targetObject
   repeat
      put the behavior of targetObject into bObject
      if exists(bObject) is false then exit repeat
      put bObject & CR after bObjects
      put bObject into targetObject
   end repeat
   delete char -1 of bObjects
   return bObjects
end behavior_GetHierarchy
