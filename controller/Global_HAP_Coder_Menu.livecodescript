script "Global_HAP_Coder_Menu"
--> MetaData
-
license: GPLv3
name: Global_HAP_Coder_Menu
type: controller
version: 0.2


--> Menu | Props
-
/*
on menu_Init  
   local shortStackArray, filteredStackNameArray, filteredShortStackArray
   
   put library_ListScriptLibNames() into scriptOnlyLibNames
   sort scriptOnlyLibNames
   put scriptOnlyLibNames into LocalArray ["scriptOnlyLibNames"]
   
   put view_ListStackFiles() into serverStackFiles
   put serverStackFiles into LocalArray ["server_StackFiles"]
   
   put view_ListControllerFiles() into LocalArray ["server_ControllerFiles"]
   
   put server_GetURL() into projectName
   stackFile_DeconstructShortFileIndex serverStackFiles, shortStackArray, filteredStackNameArray, filteredShortStackArray
   put keys (filteredStackNameArray) into projectLibraryNames
   sort projectLibraryNames
   put projectLibraryNames into LocalArray ["projectLibraryNames"]
   put shortStackArray into LocalArray ["shortStackArray"]
   put filteredStackNameArray into LocalArray ["filteredStackNameArray"]
   put filteredShortStackArray into LocalArray ["filteredShortStackArray"]
   
   put rev_ListEditedStackNames() into editedStackNames
   put editedStackNames into LocalArray ["editedStackNames"]
   
   put stack_ListEditedScriptOnlyLibraryNames (projectLibraryNames, scriptOnlyLibNames, editedStackNames) into editedScriptOnlyLibraryNames
   put editedScriptOnlyLibraryNames into LocalArray ["editedScriptOnlyLibraryNames"]
end menu_Init

getprop menu_Target
   put menu_GetTargetObject() into mTarget
   put the script_Container of mTarget into scriptContainer
   return scriptContainer
end menu_Target

-- getprop menu_Controller
return the long id of me
end menu_Controller
*/


--> Global | HAP | Coder | Menu
-
on menu_DisplayRigscript
   put the rig_Script of me
end menu_DisplayRigscript

on menu_ChooseLocalRigFolder mTarget
   answer folder "Choose a local revIgniter folder..."
   put it into rigFolder
   if rigFolder is empty then exit to top
   
   set the displayed_RigFolder of mTarget to rigFolder
   put the result into rigCoderArray
end menu_ChooseLocalRigFolder

on menu_SaveNavigationSettings mTarget
   breakPoint
   put the displayed_NavigationSettings of mTarget into navigationSettingsArray
   set the hap_NavigationSettings of mTarget to navigationSettingsArray
end menu_SaveNavigationSettings

on _
end _

on insert_WikiMenu
   return "Global | Wiki | Menu"
end insert_WikiMenu

on _
end _

on menu_GraphController scriptObject
   display_IndexScriptAndDisplaySVG scriptObject
   put the result into rigHkeyArray
end menu_GraphController

on _
end _

on menu_DisplayProcessedHkeyArray scriptObject
   put the project_ProcessedHkeyArray of scriptObject into processedHkeyArray  
   display_Array processedHkeyArray, "processedHkeyArray"
end menu_DisplayProcessedHkeyArray

on menu_DisplayDependencyObjectArray scriptObject
   put the project_DependencyStackArray of scriptObject into depObjectArray
   display_Array depObjectArray
end menu_DisplayDependencyObjectArray

on menu_DependencyObjects scriptObject
   -- put the missing_HkeyArray of scriptObject into missingHkeyArray
   put the project_DependencyStacks of scriptObject -- into dependencyStacks
end menu_DependencyObjects

on _
end _

on menu_DisplayControllerGraph scriptObject
   put the project_MetadataFolder of scriptObject & CR after folderInfo
   
   put folderInfo
   
   -- put overlay_GetImageFile (overlayFolder, "HAP")
end menu_DisplayControllerGraph

on menu_CreateControllerProject scriptObject
   -- put the textStack_Folder of scriptObject into mainStackFolder
   put the project_OverlayFolder of scriptObject into projectOverlayFolder
   put projectOverlayFolder
   finder_Reveal projectOverlayFolder
end menu_CreateControllerProject

on menu_RevealOverlayFolder scriptObject
   put the textStack_Folder of scriptObject into mainStackFolder
   put mainStackFolder
   finder_Reveal mainStackFolder
end menu_RevealOverlayFolder

on _
end _

on menu_UpoadControllerAndStacks scriptObject
   -- menu_SaveTransporterScript scriptObject
   put LocalArray ["editedScriptOnlyLibraryNames"] into editedScriptOnlyLibraryNames
   put LocalArray ["server_StackFiles"] into serverStackFiles
   
   server_UploadStacks editedScriptOnlyLibraryNames
end menu_UpoadControllerAndStacks

on menu_UpoadController scriptObject
   -- rig_ConstructAndSaveController scriptObject, shortControllerFile, serverStackFiles
   
   put LocalArray ["server_StackFiles"] into serverStackFiles
   -- rig_Upload serverStackFiles
   -- server_UploadStacks stackNames
end menu_UpoadController


--> Global | HAP | Coder | Menu | Props
-

--> Global | HAP | Coder | Menu | Disabled
-
getprop disabled_StartWiki
   put the openprocesses contains "wiki" into isRunning
   return isRunning
end disabled_StartWiki

getprop disabled_StopWiki
   put the openprocesses contains "wiki" into isRunning
   return isRunning is false
end disabled_StopWiki


