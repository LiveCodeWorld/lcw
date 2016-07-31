script "Global_Script_Dep_Menu"
--> MetaData
-
license: GPLv3
name: Global_Script_Dep_Menu
type: controller
version: 0.1

/*
This menu is for processing whole scripts to extract their dependencies.
*/

--> Variables
-
local LocalArray


--> Global | Script | Dep | Menu
-
on menu_CreateAndDisplaySvg scriptObject, projectName
   local pGraphStyle, pProcessObject, pForceCreate
   
   display_IndexScriptAndDisplaySVG scriptObject, projectName, pGraphStyle, pProcessObject, false
   put the result into imageFile
   
   put the project_ProcessedHkeyArray of scriptObject into processedHkeyArray
   display_HkeyArray processedHkeyArray, scriptObject
   display_ObjectHkeyArray processedHkeyArray, scriptObject
end menu_CreateAndDisplaySvg

on menu_DisplayProcessedHkeyArray scriptObject
   put the project_ProcessedHkeyArray of scriptObject into processedHkeyArray
   display_HkeyArray processedHkeyArray, scriptObject
   display_ObjectHkeyArray processedHkeyArray, scriptObject
end menu_DisplayProcessedHkeyArray

on menu_DisplaySvg scriptObject
   -- should be a simpler way
   put the project_MetaDataFolder of scriptObject into projectMetaDataFolder
   put empty into pOverlayName
   put overlay_GetArray (projectMetaDataFolder, pOverlayName) into overlayArray
   put overlayArray_GetImageFile (overlayArray, projectMetaDataFolder) into svgFile
   
   display_SVG svgFile
end menu_DisplaySvg

on _
end _

on insert_UploadScriptOnlyLibrary
   return "Global | Rig | Files | Menu"
end insert_UploadScriptOnlyLibrary

on _
end _

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

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev



--> Dev | Menu
-



--> Global | Script | Dep | Menu | Props
-
getprop project_Name
   put project_GetCurrentName() into activeProjectName
   return activeProjectName
end project_Name

getprop project_Names
   put library_ListSetNames() into projectNames
   return projectNames
end project_Names
