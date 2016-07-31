script "Global_Library_Manage_Menu"
--> MetaData
-
license: GPLv3
name: Global_Library_Manage_Menu
type: controller
version: 0.1

/*
Lot's of complex code expriments to hack and fix things. Should be some useful stuff in here.
*/

--> Menu | Props
-
getprop menu_Target
   return rev_ScriptObject()
end menu_Target


--> Global | Library | Manage | Menu
-
on menu_GitRevertHkeyData
   ask file "Select a file to save your revision..."
   put it into newFile
   if it is empty then exit to top
   
   put library_ArrayFile ("Hkey_Data") into someFile  
   put git_GetLastRevision (someFile, 0) into encodedDataArray
   put encodedDataArray into url ("binfile:" & newFile)
   put newFile
   
   put url ("binfile:" & newFile) into encodedDataArray
   if encodedDataArray is empty then return empty
   put arraydecode (encodedDataArray) into modelArray
   display_Array modelArray
   -- project_SaveHarray gHkey_Array, pProjectName
end menu_GitRevertHkeyData

on menu_TestRevertedHkeyData
   global gHkey_Array
   
   answer file "Check file..."
   put it into newFile
   if it is empty then exit to top
   
   put url ("binfile:" & newFile) into encodedDataArray
   if encodedDataArray is empty then return empty
   put arraydecode (encodedDataArray) into hArray
   
   display_Array hArray, "hArray"
   
   answer "Is this OK to load into gHKey_Array?" with "OK" or "Cancel"
   if it is "Cancel" then exit to top
   
   union hArray with gHkey_Array recursively
   
   breakpoint
   put hArray into gHkey_Array
   -- project_SaveHarray hArray
end menu_TestRevertedHkeyData

on _
end _

on menu_AddFolderToKnown
   answer folder "Select a folder to search inside..."
   if it is empty then exit to top
   put it into someFolder
   
   library_FixStackFiles
   put the result into resultArray
   put resultArray ["stackFileTable"] into stackFileTable
   put resultArray ["badArray"] into badArray
   
   library_AddFolderToStackFiles someFolder
   put the result into resultArray
   
   put resultArray ["duplicateFileArray"] into duplicateFileArray
   display_Array duplicateFileArray, "duplicateFileArray"
   
   put resultArray ["stackFileArray"] into stackFileArray
   display_Array stackFileArray, "stackFileArray"
end menu_AddFolderToKnown

on menu_AddAllStacksToKnown
   put spotlight_ListStacks() into bigFileIndex
   library_AddFilesToStackFiles bigFileIndex
   put the result into resultArray
   
   put resultArray ["duplicateFileArray"] into duplicateFileArray
   display_Array duplicateFileArray, "duplicateFileArray"
end menu_AddAllStacksToKnown

on menu_TidyKnownLibrary
   library_FixStackFiles
   put the result into resultArray
   put resultArray ["stackFileTable"] into stackFileTable
   put resultArray ["badArray"] into badArray
   display_Array badArray, "bad but fixed stackfiles"
end menu_TidyKnownLibrary

on _
end _

on menu_CheckRecentScriptExports
   put opn_Ask ("Search for scripts that changed in the last howmany minutes?", 20) into pMinutes
   put pMinutes * 60 into pSeconds
   put spotlight_ListRecentlyExportedObjectScripts (pSeconds) into someObjects
   display_Outline someObjects, "Recently Exported Script Objects"
   _DisplayFoundDifferences someObjects, "Could not find any errors in the objects of recently exported scripts!"
end menu_CheckRecentScriptExports

on menu_CheckAllScriptExports
   set the cursor to watch
   put spotlight_ListExportedScriptFiles() into scriptFiles
   put script_FileToObject (scriptFiles) into someObjects
   _DisplayFoundDifferences someObjects, "Could not find any errors in all the objects of exported scripts!"
end menu_CheckAllScriptExports

on _
end _

on menu_CheckExportedLibraryScripts
   -- put library_FetchObjects ("used", "all") into someObjects
   put library_FetchEveryObject() into someObjects
   _DisplayFoundDifferences someObjects, "Could not find any errors in the exported library scripts!"
end menu_CheckExportedlibraryScripts

on menu_CheckExportedMenuScripts
   put library_ListGlobalMenuObjects() into someObjects
   _DisplayFoundDifferences someObjects, "Could not find any errors in the exported Global Menu scripts!"
end menu_CheckExportedMenuScripts

on _
end _

on menu_SaveLoadedSet
   put project_GetCurrentName() into setName
   library_StoreGlobalPrefs setName, false
   hArray_StoreGlobal
   library_StoreSet setName
   
   put merge ("Stored, prefs, hArray global, and library set '[[setName]]'...") into someComment
   opn_Notify someComment
end menu_SaveLoadedSet

on _
end _

on menu_DisplayCurrentlyLoadedLibraryArray
   put library_GetSetArray() into setArray
   
   put project_GetCurrentName() into currentSetName
   put merge("library_GetSetArray('[[currentSetName]]')") into someTitle
   display_Array setArray, someTitle
end menu_DisplayCurrentlyLoadedLibraryArray

on menu_DisplayLibraryArray ideScriptObject, librarySetName
   put library_FetchSetArray (librarySetName) into setArray
   
   put merge ("library_FetchSetArray ('[[librarySetName]]')") into someTitle
   display_Array setArray, someTitle
end menu_DisplayLibraryArray

on menu_DisplayLibraryData
   put library_FetchSetData () into setData
   
   put merge ("library_FetchSetData()") into someTitle
   display_Array setData, someTitle
end menu_DisplayLibraryData

on _
end _

on menu_LoadLibrarySetOnly ideScriptObject, librarySetName
   library_LoadSet librarySetName
   menu_DisplayCurrentlyLoadedLibraryArray
end menu_LoadLibrarySetOnly

on menu_StartEnvironment ideScriptObject, librarySetName
   library_StartEnvironment librarySetName
end menu_StartEnvironment

on _
end _

on submenu_LibrarySet
   return "Global | Library | Set | Menu"
end submenu_LibrarySet

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Library | Manage | Menu | Disabled
-
getprop disabled_Dev
   if the optionKey is "Down" then
      return false
   else
      return "delete"
   end if
end disabled_Dev


--> Global | Library | Manage | Menu | Props
-
getprop stack_SetName [scriptObject]
   put the stack_Object of scriptObject into stackObject
   put the library_Sets ["used"] of stackObject into setNames
   return setNames
end stack_SetName

getprop stack_SetNames
   return library_ListSetNames()
end stack_SetNames

getprop back_SetName [scriptObject]
   put the library_Sets ["back"] of scriptObject into setNames
   return setNames
end back_SetName

getprop back_SetNames
   return library_ListSetNames()
end back_SetNames

getprop front_SetName [scriptObject]
   put the library_Sets ["front"] of scriptObject into setNames
   return setNames
end front_SetName

getprop front_SetNames
   return library_ListSetNames()
end front_SetNames

getprop set_Name
   return project_GetCurrentName()
end set_Name

getprop set_Names
   return library_ListSetNames () -- & ",-,Add"
end set_Names

getprop library_SetName
   return project_GetCurrentName()
end library_SetName

getprop library_SetNames
   return library_ListSetNames (true)
end library_SetNames


--> Global | Library | Manage | Menu | Deps
-
command _DisplayFoundDifferences someObjects, someComment
   put script_ConstructExportErrorArray (someObjects) into exportErrorArray
   
   if exportErrorArray is not an array then
      opn_Notify someComment, true
      return empty
   end if
   
   put "Scripts which differ from exported scripts" into someTitle
   display_Array exportErrorArray, someTitle, "Global | Script | Duplicates | Menu", "Global | Script | Duplicates | Line | Menu", empty, "display_ObjectScript"
   put the result into treeView
 
   return exportErrorArray
end _DisplayFoundDifferences

command display_ObjectScript treeField
   put the tree_SelectedDepth of treeField into tabLevel
   switch tabLevel
      case 1
         pass display_ObjectScript
      case 2
         put the selected_ArrayValue of treeField into selectedArray
         put line 1 of keys (selectedArray) into rObject
         edit the script of rObject
         pass display_ObjectScript
      case 3
         put the selected_Index of treeField into rObject
         edit the script of rObject
   end switch
end display_ObjectScript


function stack_NameToShortFile stackName
   put word 1 to -1 of stackName into someFile
   replace space with "_" in someFile
   put ".rev" after someFile
   return someFile
end stack_NameToShortFile

function opn_LibraryStackFiles
   put library_StandardFolder() into opnLibraryFolder
   put folder_FilesInside (opnLibraryFolder) into stackNames
   return stackNames
end opn_LibraryStackFiles

-- function opn_GetAllUsedLibraries
   local allUsedArray
   put library_GetModelArray() into modelArray
   repeat for each key setName in modelArray
      put modelArray [setName]["used"] into usedArray
      union allUsedArray with usedArray
   end repeat
   return allUsedArray
end opn_GetAllUsedLibraries


--> Dev | Menu
-
on _
end _

on menu_AddToUsedLibrary ideScriptObject, stackSetName
   put the stack_Object of ideScriptObject into stackObject
   library_AddUsedStack stackObject, stackSetName
end menu_AddToUsedLibrary

on menu_RemoveLibraryFromUsed ideScriptObject, stackSetName
   put the stack_Object of ideScriptObject into stackObject
   library_DeleteUsedStack stackObject, stackSetName
end menu_RemoveLibraryFromUsed

on _
end _

on menu_AddToBackLibrary ideScriptObject, backSetName
   library_AddBackObject ideScriptObject, backSetName
end menu_AddToBackLibrary

on menu_RemoveFromBackLibrary ideScriptObject, backSetName
   library_DeleteBackObject ideScriptObject, backSetName
end menu_RemoveFromBackLibrary

on _
end _

on menu_AddToFrontLibrary ideScriptObject, frontSetName
   library_AddFrontObject ideScriptObject, frontSetName
end menu_AddToFrontLibrary

on menu_RemoveFromFrontLibrary ideScriptObject, frontSetName
   library_DeleteFrontObject ideScriptObject, frontSetName
end menu_RemoveFromFrontLibrary

on _
end _

on submenu_ReindexLibrary
   return "Global | Library | Reindex | Menu"
end submenu_ReindexLibrary

on menu_AddExtraLibrariesTo ideScriptObject, setName
   put library_FetchSetArray (setName) into setArray
   --
   put "Library Manager,View|Menu|Button" into stackNames
   repeat for each item stackName in stackNames
      put the name of stack stackName into rObject
      put empty into setArray ["data"]["used"][rObject]
   end repeat
   
   put scriptEditor_CompileFrontScript() into rObject
   put empty into setArray ["data"]["front"][rObject]
   
   put library_ListStandardBackScripts() into someObjects
   repeat for each line scriptObject in someObjects
      put revRuggedID (scriptObject) into rObject
      put empty into setArray ["data"]["back"][rObject]
   end repeat
   
   put "OPN,View|Tree|With Title" into backNames
   repeat for each item stackName in backNames
      put the name of stack stackName into rObject
      put empty into setArray ["data"]["back"][rObject]
   end repeat
   --
   library_StoreSetArray setArray, setName
   
   put merge ("Added stacks [[stackNames]], the stacks [[backNames]] + library_ListStandardBackScripts() to the back scripts, and the 'scriptEditor_CompileFrontScript()' to the frontscript of the library set '[[setName]]'!") into someComment
   opn_Notify someComment
   menu_DisplayLibraryArray ideScriptObject, setName
end menu_AddExtraLibrariesTo

on menu_AddStandardLibrariesTo ideScriptObject, setName
   put library_FetchSetArray (setName) into setArray
   repeat for each item libType in "back,used,front,script only"
      put library_ConstructAllObjectTypeArray (libType) into allObjectArray
      put setArray ["data"][libType] into setObjectArray
      union setObjectArray with allObjectArray
      put setObjectArray into setArray ["data"][libType]
   end repeat
   library_StoreSetArray setArray, setName
   
   put merge ("Added standard libraries to the stored library set '[[setName]]'!") into someComment
   opn_Notify someComment
   menu_DisplayLibraryArray ideScriptObject, setName
end menu_AddStandardLibrariesTo

on menu_LoadAllStandardLibraries
   library_StartEnvironment "all", true
end menu_LoadAllStandardLibraries

on _
end _

on menu_DisplayKnownStacks
   put the stackfiles of stack "OPN" into opnStackfiles
   display_Lines opnStackfiles
end menu_DisplayKnownStacks

on menu_CleanKnownStacks
   opn_Answer "Remove all entries from the OPN stackfiles that do not exist?"
   opn_CheckStackFiles
end menu_CleanKnownStacks

on _
end _

on menu_RemoveLibraryFromAll ideScriptObject, allStack
   library_DeleteUsedStack allStack, "All"
   
   put opn_LibraryStackFiles ("All") into stackNames
   display_Lines stackNames
end menu_RemoveLibraryFromAll

on menu_AddLibraryFilesToAllUsed
   put "All" into pSetName
   put opn_LibraryStackFiles() into stackNames
   -- set the itemdelimiter to "/"
   repeat for each line stackName in stackNames
      set the cursor to busy
      put "stack" && kwote(stackName) into stackObject
      library_AddUsedStack stackObject, pSetName
   end repeat
   
   put library_ListUsedStacks ("All") into usedLibraries
   display_Lines usedLibraries, "Library files plus any extra"
end menu_AddLibraryFilesToAllUsed

on _
end _

on menu_CreateNewLibrary
   repeat
      put opn_Ask ("What do you want to call this new library?" , "libOPN_Example") into libName
      if exists (stack libName) then
         put merge("Can't create stack [['libName']] as a stack of this name already exists! Try again?") into someQuestion
         answer warning someQuestion with "OK" or "Open and Cancel"
         if it is "Open and Cancel" then
            toplevel stack libName
            exit to top
         end if
      else
         exit repeat
      end if
   end repeat
   
   create stack libName
   put stack_NameToShortFile (libName) into shortFile
   put library_StandardFolder(shortFile) into someFile
   set the filename of stack libName to someFile
   
   set the destroystack of stack libName to false
   set the destroywindow of stack libName to false
   
   /*
   name: libOPN_Yoga
   type: library
   version: 1.2
   copyright: OPN Technologies LLP
   */
   
   put libName into metadataArray ["name"]
   put "library" into metadataArray ["type"]
   put "0.1" into metadataArray ["version"]
   put "OPN Technologies LLP" into metadataArray ["copyright"]
   put "Some brief help about this library..." into metadataArray ["script_Help"]
   
   set the script_MetaData of stack libName to metadataArray
   save stack libName
   
   set the stack_IsKnown of stack libName to true
   set the stack_IsLibrary of stack libName to true
   start using stack libName
   
   edit the script of stack libName
   put merge("This new library stack has been saved to file '[[someFile]]' and added to the OPN environment!") into someQuestion
   opn_Notify (someComment, true)
end menu_CreateNewLibrary

-- on menu_ExportAllLibraryHkeys
put opn_LibraryStackFiles() into stackNames
repeat for each line stackName in stackNames
   set the cursor to busy
   put "stack" && kwote(stackName) into scriptObject
   scriptObject_ExportHkeys scriptObject
end repeat
end menu_ExportAllLibraryHkeys


on menu_DisplayUsedLibraries ideScriptObject, setName
   -- put project_GetCurrentName() into setName
   put library_ListUsedStacks (setName) into usedLibraries
   display_Lines usedLibraries, setName
end menu_DisplayUsedLibraries

on menu_DisplayLibrarySet ideScriptObject, setName
   put library_FetchSetArray (setName) into someArray
   put "Library set" && kwote(setName) into someTitle
   display_Array someArray, someTitle
end menu_DisplayLibrarySet

on menu_RevealLibraryFolder
   put library_StandardFolder() into opnLibraryFolder
   finder_Reveal opnLibraryFolder
end menu_RevealLibraryFolder

on menu_DisplayLibraryFolderStacks
   put opn_LibraryStackFiles() into stackNames
   display_Lines stackNames
end menu_DisplayLibraryFolderStacks

on _
end _

on menu_SaveAllLibraries
   put library_ListUsedStacks ("All") into usedLibraries
   repeat for each line stackName in usedLibraries
      set the cursor to busy
      if there is a stack stackName then
         save stack stackName
      end if
   end repeat
end menu_SaveAllLibraries


--> Dep | Menu | Props
-
getprop all_Stacks
   put library_ListUsedStacks ("All") into usedLibraries
   put word 1 to -1 of usedLibraries into usedLibraries
   return usedLibraries
end all_Stacks
