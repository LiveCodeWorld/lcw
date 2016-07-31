script "Global_Mainstack_Test_Menu"
--> MetaData
-
license: GPLv3
name: Global_Mainstack_Test_Menu
type: controller
version: 0.1

/*
Changed this menu to be a general hKey menu. 
The menu_Init code has been removed so it can be placed in the local mController that calls the hkey menu.
See the behavior "Livecode Script History Button"
*/

--> Variables
-
local LocalArray


--> Global | Mainstack | Test | Menu
-
on menu_ExportProjectFilesAndCreateHarray scriptObject
   deps_SaveMainstackAndExportArrays scriptObject
end menu_ExportProjectFilesAndCreateHarray

on menu_CreateDependencyArray scriptObject   
   -- as we have no way right now of checking that this is up to date
   deps_SaveMainstackAndExportArrays scriptObject
   deps_ConstructDependencyArray scriptObject, true
   put the result into hKeyArray
   display_Array hKeyArray, scriptObject
end menu_CreateDependencyArray

on _
end _

on menu_DisplayProjectDependencyGraph scriptObject
   set the cursor to watch
   put the textStackOverlay_Folder [true] of scriptObject into overlayFolder
   display_Overlay overlayFolder, "Mainstack Structure"
end menu_DisplayProjectDependencyGraph

on menu_CreateProjectDependencyGraph scriptObject, graphStyle
   deps_CreateMainStackOverlay scriptObject, graphStyle, "display"
end menu_CreateProjectDependencyGraph

on menu_DrawWithoutSubGraphs scriptObject
   deps_CreateMainStackOverlay scriptObject, "hierarchical", "display", "none"
end menu_DrawWithoutSubGraphs

on _
end _

on menu_DisplayMainStackHkeyWalkArray scriptObject
   set the cursor to watch
   put the mainstack_WalkArray of scriptObject into mainStackHkeyWalkArray
   display_HkeyWalkArray scriptObject, mainStackHkeyWalkArray
end menu_DisplayMainStackHkeyWalkArray

on menu_DisplayMainStackHkeyArray scriptObject
   set the cursor to watch
   put the mainstack_WalkArray of scriptObject into mainStackHkeyWalkArray
   put mainStackHkeyWalkArray ["hkeyArray"] into hkeyArray
   display_Array hKeyArray, scriptObject
end menu_DisplayMainStackHkeyArray

on menu_DisplayMainStackHarray scriptObject
   set the cursor to watch
   put the mainstack_Harray of scriptObject into mainStackHarray
   display_Array mainStackHarray, "the mainstack_Harray"
end menu_DisplayMainStackHarray

on menu_DisplayProjectManifest scriptObject
   set the cursor to watch   
   put the mainStack_ManifestArray of scriptObject into manifestArray
   display_Array manifestArray, "the mainStack_ManifestArray of hObject"
end menu_DisplayProjectManifest

on _
end _

on menu_RevealProjectMetadataFolder scriptObject
   put the project_MetaDataFolder of scriptObject into projectMetaDataFolder
   finder_Reveal projectMetaDataFolder
end menu_RevealProjectMetadataFolder

on menu_RevealTextStackFolder scriptObject
   put the textStack_Folder of scriptObject into someFolder
   finder_Reveal someFolder
end menu_RevealTextStackFolder


--> Global | Mainstack | Test | Menu | Props
-
getprop graph_Styles
   return dot_AllGraphStyles()
end graph_Styles

function dot_AllGraphStyles
   return "radial,spring,circular,-,hierarchical,-,undirected spring,fast undirected spring" 
end dot_AllGraphStyles


--> Global | Mainstack | Test | Menu | Disabled
-
getprop disabled_DisplayProjectDependencyGraph [scriptObject]
   put the project_MetaDataFolder of scriptObject into projectMetaDataFolder
   put overlay_ImageFile (projectMetaDataFolder, "Mainstack Structure") into imageFile
   if there is a file imageFile then
      return false
   else
      return true
   end if
end disabled_DisplayProjectDependencyGraph

getprop disabled_CreateDependencyArray [scriptObject]   
   put the mainStack_Hash of scriptObject into stackHash
   put the mainStack_ManifestArray of scriptObject into manifestArray
   put manifestArray ["sha1"] into storedHash
   
   if stackHash = storedHash then
      return true
   else
      return false
   end if
end disabled_CreateDependencyArray

getprop disabled_ExportProjectFilesAndCreateHarray
   put LocalArray ["walkArrayFile"] into walkArrayFile
   if there is a file walkArrayFile then
      return false
   else
      return true
   end if
end disabled_ExportProjectFilesAndCreateHarray

getprop disabled_DisplayMainStackHarray
   put LocalArray ["walkArrayFile"] into walkArrayFile
   if there is a file walkArrayFile then
      return false
   else
      return true
   end if
end disabled_DisplayMainStackHarray

getprop disabled_DisplayMainStackHarray
   put LocalArray ["walkArrayFile"] into walkArrayFile
   if there is a file walkArrayFile then
      return false
   else
      return true
   end if
end disabled_DisplayMainStackHarray

getprop disabled_DisplayProjectManifest
   put LocalArray ["manifestFile"] into manifestFile
   if there is a file manifestFile then
      return false
   else
      return true
   end if
end disabled_DisplayProjectManifest

getprop disabled_DisplayMainStackHkeyArray
   put LocalArray ["walkArrayFile"] into walkArrayFile
   if there is a file walkArrayFile then
      return false
   else
      return true
   end if
end disabled_DisplayMainStackHkeyArray

getprop disabled_DisplayMainStackHkeyWalkArray
   put LocalArray ["walkArrayFile"] into walkArrayFile
   if there is a file walkArrayFile then
      return false
   else
      return true
   end if
end disabled_DisplayMainStackHkeyWalkArray


--> Menu | Props
-
getprop menu_CheckTarget [scriptObject]
   put the textStack_Folder of scriptObject into mainStackFolder
   if there is not a folder mainStackFolder then return false
   
   put mainstack_GetManifestArrayFile (mainStackFolder) into LocalArray ["manifestFile"]
   put mainstack_GetWalkArrayFile (mainStackFolder) into LocalArray ["walkArrayFile"]
   
   return true
end menu_CheckTarget
