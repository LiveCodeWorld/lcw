script "model_LibraryProjects"
--> MetaData
-
license: GPLv3
name: model_LibraryProjects
type: model
version: 0.1

/*
This model wraps a standard library array for projects.
Here we store links and metadata to project folders ona users local system.
This may also be a place to store an npm style array of remote projects that a user can install with a suitable connection.

The aim is to keep this model minimal, with a focus on where and how the model is stored
and to use the other project models and libraries for more complex access.

command library_StoreProjectMetadata projectMetaData, pSetName
   if pSetName is empty then put project_GetCurrentName() into pSetName
   put library_FetchProjectData() into librarySetData
   put projectMetaData into librarySetData [pSetName]["metadata"]
   library_StoreProjectData librarySetData
   return librarySetData
end library_StoreProjectMetadata
*/


function library_ListProjectNames pBadNames
   -- was "library_ListSetNames"
   put library_FetchProjectData() into libraryProjectData
   put keys (libraryProjectData) into projectNames
   sort projectNames
   if pBadNames is true then return projectNames
   
   repeat for each line projectName in projectNames
      put libraryProjectData [projectName] into projectArray
      put project_GetArrayFolder (projectArray) into projectFolder
      if there is a folder projectFolder then
         put projectName & CR after goodProjectNames
         -- put projectFolder & CR after projectFolders
      end if
   end repeat
   delete char -1 of goodProjectNames
   return goodProjectNames
end library_ListProjectNames


--> Library | Project | Model
-
function library_FetchProjectValue someKey, pProjectName
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   put library_FetchProjectArray (pProjectName) into projectArray
   put projectArray [someKey] into someValue
   return someValue
end library_FetchProjectValue

command library_SaveProjectValue someKey, someValue, pProjectName
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   put library_FetchProjectArray (pProjectName) into projectArray
   put someValue into projectArray [someKey]
   library_StoreProjectArray pProjectName, projectArray
   return projectArray
end library_SaveProjectValue

function library_FetchProjectArray pProjectName
   -- was "library_FetchProjectArray"
   if pProjectName is empty then put project_GetCurrentName() into pProjectName
   put library_FetchProjectData() into libraryProjectData
   put libraryProjectData [pProjectName] into projectArray
   return projectArray
end library_FetchProjectArray

command library_StoreProjectArray projectName, projectArray
   put library_FetchProjectData() into libraryProjectData
   if projectArray is empty then
      delete variable libraryProjectData [projectName]
   else
      put projectArray into libraryProjectData [projectName]
   end if
   library_StoreProjectData libraryProjectData
   return libraryProjectData
end library_StoreProjectArray

function library_FetchProjectData
   put library_FetchArray ("gOPN_LibrarySets") into modelArray
   return modelArray
end library_FetchProjectData

command library_StoreProjectData modelArray
   library_StoreArray "gOPN_LibrarySets", modelArray
end library_StoreProjectData


