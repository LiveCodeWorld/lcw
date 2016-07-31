script "Global_Script_Mainstack_Menu"
--> MetaData
-
license: GPLv3
name: Global_Script_Mainstack_Menu
type: controller
version: 0.1

/*
This is the menu called by the Script Editor and other tools that work on scriptObjects.
It create and manipulates mainstack metadata for the "script object" referenced.

The menu_target for these handlers is the scriptObject that owns the script currently presented by the Script Editor.
These menu tools should therefore work equally well on any LiveCode object,
and in particular either along side any of the more specific version control tools for GIT or Fossil.
*/


--> Global | Script | Mainstack | Menu
-
on menu_DisplayMainStackOverlay scriptObject
   set the cursor to watch
   put "Mainstack Structure" into overlayName
   put the textStackOverlay_Folder [true] of scriptObject into overlayFolder
   if there is not a folder overlayFolder then
      return empty
   end if
   display_Overlay overlayFolder, overlayName
   return the result
end menu_DisplayMainStackOverlay

on _
end _

on menu_DependencyArrayFromObjects scriptObject, projectName
   put true into pAllCalls
   put the script_FirstHkeys of scriptObject into hKeys
   put hkey_DependencyArrayFromObjects (hKeys, projectName, pAllCalls) into hKeyLinkArray
   display_Array hKeyLinkArray, "hkey_DependencyArrayFromObjects"
end menu_DependencyArrayFromObjects

on _
end _

on menu_SaveMainstackAndExportArrays scriptObject
   deps_SaveMainstackAndExportArrays scriptObject, true
end menu_SaveMainstackAndExportArrays

on menu_ReindexMainstackHkeyArray scriptObject
   -- deps_ConstructDependencyArray scriptObject
   -- put the result into walkArray
   -- taken from above
   put "HAP" into pSetName
   put the mainstack_Harray of scriptObject into hArray
   put empty into pDepObject
   put project_ConstructWalkArray (hArray, pDepObject, pSetName) into walkArray
   set the mainstack_WalkArray of scriptObject to walkArray
   
   put walkArray ["hKeyArray"] into hKeyArray
   
   opn_Answer "Saved dependency array. Do you want to graph the result?"
   hkeyArray_DrawGraph hKeyArray, "undirected spring"
   put the mainstack_WalkArray of scriptObject into walkArray
   display_HkeyWalkArray scriptObject, walkArray
end menu_ReindexMainstackHkeyArray

on menu_CreateMainstackGraph scriptObject
   deps_CreateMainStackOverlay scriptObject, "undirected spring", "display"
end menu_CreateMainstackGraph

on menu_CreatePlainMainstackGraph scriptObject
   deps_CreateMainStackOverlay scriptObject, "undirected spring", "display", "none"
end menu_CreatePlainMainstackGraph

on _
end _

on menu_DisplayExternalDependencies scriptObject
   display_ExternalHkeyArray scriptObject
end menu_DisplayExternalDependencies

on menu_DisplayMainstackMissing scriptObject
   put the mainstack_MissingArray of scriptObject into missingArray
   put "the mainstack_MissingArray of" && the mobile_Name of scriptObject into pDisplayTitle
   display_Array missingArray, pDisplayTitle, "Global | Mainstack | Array | Missing | Menu", "Global | Mainstack | Array | Missing | Line | Menu", 3
end menu_DisplayMainstackMissing

on menu_DisplayMainstackHarray scriptObject
   put the mainstack_Harray of scriptObject into mainStackHarray
   display_Array mainStackHarray, "the mainstack_Harray of scriptObject"
end menu_DisplayMainstackHarray

on menu_DisplayMainstackHkeyArray scriptObject
   put the mainstack_HkeyArray of scriptObject into mainStackHkeyArray   
   display_HkeyArray mainStackHkeyArray, "the mainstack_HkeyArray of scriptObject"
end menu_DisplayMainstackHkeyArray

on menu_DisplayMainstackWalkArray scriptObject
   put the mainstack_WalkArray of scriptObject into mainStackWalkArray   
   display_Array mainStackWalkArray, "the mainstack_WalkArray of scriptObject"
end menu_DisplayMainstackWalkArray

on menu_DisplayMainstackManifestArray scriptObject
   put the mainStack_ManifestArray of scriptObject into manifestArray
   display_Array manifestArray, "the mainStack_ManifestArray of scriptObject"
end menu_DisplayMainstackManifestArray

on _
end _

on menu_AddMainstackHandlersToLibrary scriptObject
   put the mainstack_HkeyArray of scriptObject into mainStackHkeyArray
   put keys (mainStackHkeyArray) into hKeys
   sort hKeys
   put hKeys
end menu_AddMainstackHandlersToLibrary

on _
end _

on submenu_ProjectOverlay
   return "Global | Project | Overlay | Menu"
end submenu_ProjectOverlay

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Script | Mainstack | Menu | Props
-
getprop project_Names
   return "HAP,Default,Menus Only"
end project_Names

getprop graph_Styles
   return dot_AllGraphStyles()
end graph_Styles

function dot_AllGraphStyles
   return "radial,spring,circular,-,hierarchical,-,undirected spring,fast undirected spring" 
end dot_AllGraphStyles


--> Global | Script | Mainstack | Menu | Disabled
-
getprop disabled_DisplayMainStackOverlay [scriptObject]
   put the textStackOverlay_Folder of scriptObject into overlayFolder
   put overlay_GetImageFile (overlayFolder, "Mainstack Structure") into imageFile
   if there is a file imageFile then
      return false
   else
      return true
   end if
end disabled_DisplayMainStackOverlay


--> Dev | Menu
-
on menu_ForceReindexAllArrays scriptObject
   deps_ConstructDependencyArray scriptObject, true
   put the result into walkArray
   put walkArray ["hKeyArray"] into hKeyArray
   
   opn_Answer "Saved Dependency Array. Do you want to graph the result?"
   hkeyArray_DrawGraph hKeyArray, "undirected spring"
   put the mainstack_WalkArray of scriptObject into walkArray
   display_HkeyWalkArray scriptObject, walkArray
end menu_ForceReindexAllArrays


--> Deps
-
function dot_AllGraphStyles
   return "radial,spring,circular,-,hierarchical,-,undirected spring,fast undirected spring" 
end dot_AllGraphStyles
