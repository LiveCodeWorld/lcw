script "model_Platform"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_Platform
type: model
version: 0.1

/*
Here we explore handlers for the Livecode project and default websites that document the project and host the code.
See also model_Environment.
*/

--> Props
-
getprop env_Paths [pFilter] 
   put the project_Name of the target into projectName
   put project_GetArray (projectName) into projectArray
   put projectArray ["stackFileArray"] into sFileArray
   --
   if pFilter is not empty then
      filter keys of sFileArray with pFilter
   end if
   --
   repeat for each key sName in sFileArray
      get sFileArray [sName]
      put projectName & slash & it into envPath
      put envPath & CR after envPaths
   end repeat
   delete char -1 of envPaths
   return envPaths
end env_Paths

getprop env_PathArray [pFilter]
   put the project_Name of the target into projectName
   put project_GetArray (projectName) into projectArray
   put projectArray ["stackFileArray"] into sFileArray
   --
   put pathArray_Construct (projectName, sFileArray, pFilter) into pathArray
   return pathArray
end env_PathArray

getprop env_RelativeFile
   local commonPath
   put the effective filename of the defaultstack into sFile
   if sFile is empty then return empty
   
   put env_GetRepoFolder() into envFolder
   put file_GetRelativePath (sFile, envFolder, commonPath) into rPath
   return rPath
end env_RelativeFile

getprop env_RepoFolder [pShortRepoFolder]
   set the itemdelimiter to slash
   put the project_Folder of target into repoFolder
   delete item -1 of repoFolder
   --
   if pShortRepoFolder is not empty then
      put pShortRepoFolder after repoFolder
   end if
   return repoFolder
end env_RepoFolder


--> PathArray
-
function pathArray_Construct projectName, sFileArray, pFilter
   repeat for each key sName in sFileArray
      get sFileArray [sName]
      put projectName & slash & it into envPath
      put envPath into envPathArray [sName]
   end repeat
   
   if pFilter is not empty then
      filter keys of envPathArray with pFilter
   end if
   return envPathArray
end pathArray_Construct


--> Platform
-
function platform_RestUrl restBit
   put "http://" & platform_RestDomain() into restURL
   if restBit is not empty then
      put slash & restBit after restURL
   end if
   return restURL
end platform_RestUrl

function platform_RestPort
   constant PlatformRestPort = 9090
   return PlatformRestPort
end platform_RestPort

function platform_RestDomain
   return "rest.livecode.wiki"
end platform_RestDomain

function platform_LivecodeDomain pSubDomain
   put "livecode.wiki" into wDomain
   --
   if pSubDomain is empty then
      return wDomain
   else
      if char -1 of pSubDomain is not "." then
         put "." after pSubDomain
      end if
      return pSubDomain & wDomain
   end if
end platform_LivecodeDomain
