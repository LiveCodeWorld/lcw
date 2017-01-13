script "model_ScriptHierarchy"
--> MetaData
-
license: GPLv3
name: model_ScriptHierarchy
type: model
version: 0.2


--> Script | Hierarchy
-
getprop script_Hierarchy [pProjectName]
   put the long id of the target into targetObject
   put the object_Hierarchy of targetObject into scriptHierarchy
   hkey_AddDevelopmentHierarchy scriptHierarchy, pProjectName, targetObject
   return scriptHierarchy
end script_Hierarchy

-- getprop script_Hierarchy [pProjectName]
put object_ListFrontScripts (pProjectName) into hObjects
put CR & the object_Hierarchy of the target after hObjects
put CR & stack_ListUsed (pProjectName) after hObjects
put CR & object_ListBackScripts (pProjectName) after hObjects
return word 1 to -1 of hObjects
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

command hkey_AddDevelopmentHierarchy @scriptHierarchy, pProjectName
   /*
   If pProjectName is empty we take the current environment (all the stacksInUse)
   */
   local frontObjects, usedStacks, backObjects
   
   switch pProjectName
      case empty
         put stack_PathsToObjects (the stacksinUse) into usedStacks
         put the frontscripts into frontObjects
         filter frontObjects without "*.app/Contents/Tools/*"
         put the backscripts into backObjects
         filter backObjects without "*.app/Contents/Tools/*"
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

function object_ListFrontScripts pProjectName
   -- /Applications/LiveCode Community 8.1.0 (dp 3).app/Contents/Tools/Toolset/libraries/revshortcutslibrary.livecodescript
   put the frontscripts into longIDs
   ide_FilterOutStacks longIDs
   return longIDs
end object_ListFrontScripts

function object_ListBackScripts pProjectName
   -- /Applications/LiveCode Community 8.1.0 (dp 3).app/Contents/Tools/Toolset/libraries/revshortcutslibrary.livecodescript
   put the backscripts into longIDs
   ide_FilterOutStacks longIDs
   return longIDs
end object_ListBackScripts

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


--> Deps
-
command script_AddLibrariesToHierarchy @objectIndex, frontObjects, usedStacks, backObjects 
   if usedStacks is not empty then put usedStacks & CR before objectIndex
   if backObjects is not empty then put backObjects & CR before objectIndex
   if frontObjects is not empty then put CR & frontObjects after objectIndex
end script_AddLibrariesToHierarchy

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
